//
// Created by Paolo Olivieri on 23/12/24.
//


// state_machine.cpp
#include "state_machine.h"

// Inizializzazione variabili di stato
static DetectionState currentState = IDLE;
static unsigned long lastLedToggle = 0;
static bool ledOn = false;

// Inizializzazione variabili di rilevamento caduta
static float preciseValleyAccel = 0;
static float precisePeakAccel = 0;
static float postTTMean = 0.0;
static unsigned long valleyTimestamp = 0;
static unsigned long peakTimestamp = 0;
static unsigned long transitionTime = 0;
static unsigned long postTT_endTime = 0;
static unsigned long recoveryWindowStart = 0;

// Inizializzazione variabili temporanee
static float currentMinAccel = std::numeric_limits<float>::max();
static float currentMaxAccel = std::numeric_limits<float>::lowest();
static unsigned long currentMinTimestamp = 0;
static unsigned long currentMaxTimestamp = 0;

bool requiresSensing(DetectionState state) {
    return state >= SENSE_WAITING_VALLEY;
}

void updateSystem(unsigned long currentTime) {

  // Gestione BLE
    BLE.poll();

    // Gestione batteria
    static unsigned long lastBatteryUpdate = 0;
    if(currentTime - lastBatteryUpdate >= BATTERY_UPDATE_INTERVAL) {
        lastBatteryUpdate = currentTime;
        updateBatteryLevel();
    }
    
    // Gestione timing generale del sistema
    static unsigned long lastReadTime = 0;
    if (currentTime - lastReadTime >= sendInterval) {
        lastReadTime = currentTime;
        BHY2.update();
        processState(currentTime);
    }
}

/*
void processBLEStatus(unsigned long currentTime) {
    switch (currentState) {
        case IDLE:
            handleIdleState();
            break;
        case CONNECTED:
            handleConnectedState();
            break;
        case DISCONNECTED:
            handleDisconnectedState();
            break;
        case UNSUBSCRIBED:
            handleUnsubscribedState();
            break;
    }
}*/

void processState(unsigned long currentTime) {
    if (requiresSensing(currentState)) {
        float accel = readAccelerometer();
        float pressure = readPressure();
        
        // Aggiungi il campione al buffer
        addSample(pressure, accel, currentTime);
        
        switch (currentState) {
            case SENSE_WAITING_VALLEY:
                handleWaitingValley(accel, currentTime);
                break;
            case SENSE_IDENTIFYING_VALLEY:
                handleIdentifyingValley(accel, currentTime);
                break;
            case SENSE_WAITING_PEAK:
                handleWaitingPeak(accel, currentTime);
                break;
            case SENSE_IDENTIFYING_PEAK:
                handleIdentifyingPeak(accel, currentTime);
                break;
            case SENSE_ANALYZING_FALL:
                handleAnalyzingFall(currentTime);
                break;
            case SENSE_MONITORING_RECOVERY:
                handleMonitoringRecovery(currentTime);
                break;
            case SENSE_ALARM_TRIGGER:
                handleAlarmTrigger();
                break;
        }
    } else {
        switch (currentState) {
            case IDLE:
                handleIdleState();
                break;
            case CONNECTED:
                handleConnectedState();
                break;
            case DISCONNECTED:
                handleDisconnectedState();
                break;
        }
    }
}

// Handler stati BLE
void handleIdleState() {
    toggleLED(LED_BLUE, lastLedToggle, ledOn, 700);
}

void handleConnectedState() {
    toggleLED(LED_BLUE, lastLedToggle, ledOn, 100);
    if (fallAlarmCharacteristic.subscribed()) {
        //currentState = SUBSCRIBED;
        currentState = SENSE_WAITING_VALLEY;
    }
}

void handleDisconnectedState() {
    blinkLED(LED_RED, 300, 100, 2);
    debugPrint("Dispositivo disconnesso, reset algoritmo");
    resetDetectionParameters();
    currentState = IDLE;
}

/*
void handleSubscribedState() {
    blinkLED(LED_GREEN, 200, 100, 2);
    currentState = WAITING_VALLEY;
}
*/

/*
void handleUnsubscribedState() {
    blinkLED(LED_ORANGE, 400, 100, 2);
    currentState = CONNECTED;
}
*/

// Handler stati di rilevamento caduta
void handleWaitingValley(float accel, unsigned long currentTime) {
    toggleLED(LED_WHITE,lastLedToggle, ledOn, 500);

    currentMinAccel = std::numeric_limits<float>::max();
    currentMinTimestamp = 0;

    if (accel <= VALLEY_THRESHOLD) {
        currentMinAccel = accel;
        currentMinTimestamp = currentTime;
        currentState = SENSE_IDENTIFYING_VALLEY;
    }
}

void handleIdentifyingValley(float accel, unsigned long currentTime) {
    toggleLED(LED_WHITE,lastLedToggle, ledOn, 500);

    if (accel <= VALLEY_THRESHOLD) {
        if (accel <= currentMinAccel) {
            currentMinAccel = accel;
            currentMinTimestamp = currentTime;
        }
    } else {
        preciseValleyAccel = currentMinAccel;
        valleyTimestamp = currentMinTimestamp;
        currentState = SENSE_WAITING_PEAK;
    }
}

void handleWaitingPeak(float accel, unsigned long currentTime) {
    toggleLED(LED_WHITE,lastLedToggle, ledOn, 500);

    currentMaxAccel = std::numeric_limits<float>::lowest();
    currentMaxTimestamp = 0;

    if (currentTime - valleyTimestamp <= MAX_PEAK_DELAY && accel >= PEAK_THRESHOLD) {
        currentMaxAccel = accel;
        currentMaxTimestamp = currentTime;
        currentState = SENSE_IDENTIFYING_PEAK;
    } else if (currentTime - valleyTimestamp >= MAX_PEAK_DELAY) {
        currentState = SENSE_WAITING_VALLEY;
    }
}

void handleIdentifyingPeak(float accel, unsigned long currentTime) {
    toggleLED(LED_WHITE,lastLedToggle, ledOn, 500);

    if (accel >= PEAK_THRESHOLD) {
        if (accel >= currentMaxAccel) {
            currentMaxAccel = accel;
            currentMaxTimestamp = currentTime;
        }
    } else {
        precisePeakAccel = currentMaxAccel;
        peakTimestamp = currentMaxTimestamp;
        transitionTime = (valleyTimestamp + peakTimestamp) / 2;
        postTT_endTime = transitionTime + 3000;
        currentState = SENSE_ANALYZING_FALL;
    }
}

void handleAnalyzingFall(unsigned long currentTime) {
    toggleLED(LED_PURPLE,lastLedToggle, ledOn, 500);

    if (currentTime >= postTT_endTime) {
        float preTTMean = calculateMeanInTimeWindow(
            pressureBuffer,
            transitionTime - 3000,
            transitionTime - 1000
        );

        postTTMean = calculateMeanInTimeWindow(
            pressureBuffer,
            transitionTime + 1000,
            transitionTime + 3000
        );

        float postTTAccelVariance = calculateVarianceInTimeWindow(
            accelBuffer,
            transitionTime + 1000,
            transitionTime + 3000
        );

        // Debug info
        #ifdef DEBUG_MODE
        debugTimeWindow("PRE TT", transitionTime - 3000, transitionTime - 1000, preTTMean);
        debugTimeWindow("POST TT", transitionTime + 1000, transitionTime + 3000, postTTMean);
        //debugPrint("Varianza Accelerazione:", postTTAccelVariance);
        #endif
        float pressureDelta = postTTMean - preTTMean;

        if (pressureDelta >= PRESSURE_FALL_THRESHOLD &&
            postTTAccelVariance <= std::round(ACCEL_VARIANCE_THRESHOLD * PRECISION_FACTOR)) {
            reportFall(preciseValleyAccel, precisePeakAccel, pressureDelta, transitionTime);
            fallAlarmCharacteristic.writeValue(0x01);
            currentState = SENSE_MONITORING_RECOVERY;
        } else {
            currentState = SENSE_WAITING_VALLEY;
        }
    }
}

void handleMonitoringRecovery(unsigned long currentTime) {
    toggleLED(LED_ORANGE,lastLedToggle, ledOn, 100);

    if (recoveryWindowStart == 0) {
        recoveryWindowStart = postTT_endTime;
    }

    unsigned long recoveryMonitorEndTime = postTT_endTime + RECOVERY_WINDOW;
    bool bufferFilled = false;

    while (recoveryWindowStart <= recoveryMonitorEndTime) {
        unsigned long recoveryWindowEnd = recoveryWindowStart + SLIDING_WINDOW;

        if (!bufferFilled) {
            if (currentTime >= recoveryWindowStart + SLIDING_WINDOW) {
                bufferFilled = true;
            } else {
                break;
            }
        }

        if (currentTime >= recoveryWindowEnd) {
            float recoveryPressureMean = calculateMeanInTimeWindow(
                pressureBuffer,
                recoveryWindowStart,
                recoveryWindowEnd
            );

            #ifdef DEBUG_MODE
            debugPrint("Media Pressione Post-TT: ", postTTMean, " hPa" );
            debugPrint("Media Pressione Recovery: ", recoveryPressureMean, " hPa" );
            debugPrint("Delta Pressione: ", postTTMean - recoveryPressureMean, " hPa" );
            debugPrint("==========================================");
            #endif

            if (postTTMean - recoveryPressureMean >= PRESSURE_RECOVERY_THRESHOLD) {
                debugPrint("Recupero completato");
                fallAlarmCharacteristic.writeValue(0x00);
                nicla::leds.setColor(0, 255, 0);
                currentState = SENSE_WAITING_VALLEY;
                recoveryWindowStart = 0;
                break;
            }

            recoveryWindowStart = recoveryWindowEnd;
        }

        if (recoveryWindowStart >= recoveryMonitorEndTime) {
            debugPrint("Nessun recupero - MAN DOWN!");
            currentState = SENSE_ALARM_TRIGGER;
            recoveryWindowStart = 0;
            break;
        }
        break;
    }
}

void handleAlarmTrigger() {
    debugPrint("ALLARME ATTIVO - RICHIESTA AIUTO...");
    fallAlarmCharacteristic.writeValue(0x02);
    while (true) {
        toggleLED(LED_RED,lastLedToggle, ledOn, 100);
    }
}


// Event handlers
void onBLEConnected(BLEDevice central) {
    debugPrint("Dispositivo connesso!");
    currentState = CONNECTED;
}

void onBLEDisconnected(BLEDevice central) {
    debugPrint("Dispositivo disconnesso!");
    currentState = DISCONNECTED;
}

void onBLESubscribed(BLEDevice central, BLECharacteristic characteristic) {
    debugPrint("Client sottoscritto alle notifiche");
    currentState = SENSE_WAITING_VALLEY;
}

void onBLEUnsubscribed(BLEDevice central, BLECharacteristic characteristic) {
    debugPrint("Client non più sottoscritto");
    currentState = CONNECTED;
}

void onAlarmReset(BLEDevice central, BLECharacteristic characteristic) {

    byte value = fallAlarmCharacteristic.value();
    debugPrint("Valore reset allarme: 0x", value);

    if (value == 0x00) {
        debugPrint("Reset allarme");
        resetDetectionParameters();
        currentState = SENSE_WAITING_VALLEY;
    }
}

void resetDetectionParameters() {
    currentMinAccel = std::numeric_limits<float>::max();
    currentMaxAccel = std::numeric_limits<float>::lowest();
    currentMinTimestamp = 0;
    currentMaxTimestamp = 0;

    preciseValleyAccel = 0;
    precisePeakAccel = 0;
    postTTMean = 0.0;

    valleyTimestamp = 0;
    peakTimestamp = 0;

    transitionTime = 0;
    postTT_endTime = 0;
    recoveryWindowStart = 0;
}