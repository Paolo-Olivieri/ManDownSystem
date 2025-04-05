//
// Created by Paolo Olivieri on 23/12/24.
//

#ifndef STATE_MACHINE_H
#define STATE_MACHINE_H

#include "config.h"
#include "buffer.h"
#include "sensors.h"
#include "utilities.h"
#include "ble_handlers.h"

// ===================================
// Stati del sistema
// ===================================
enum DetectionState {
    // Stati BLE
    IDLE,           // In attesa di connessione
    CONNECTED,      // Dispositivo connesso
    DISCONNECTED,   // Dispositivo disconnesso
    //SUBSCRIBED,     // Client sottoscritto alle notifiche
    //UNSUBSCRIBED,   // Client non sottoscritto

    // Stati rilevamento caduta - richiedono il supertstato SENSE (implicito)
    SENSE_WAITING_VALLEY,      // In attesa di rilevare una caduta libera
    SENSE_IDENTIFYING_VALLEY,  // Analisi della caduta libera
    SENSE_WAITING_PEAK,       // In attesa di rilevare l'impatto
    SENSE_IDENTIFYING_PEAK,   // Analisi dell'impatto
    SENSE_ANALYZING_FALL,     // Analisi della potenziale caduta
    SENSE_MONITORING_RECOVERY,// Monitoraggio recupero post-caduta
    SENSE_ALARM_TRIGGER      // Allarme attivato
};


// Helper per verificare se lo stato richiede sensing, ovvero l'utilizzo di sensori per l'acquisizione dati
bool requiresSensing(DetectionState state);

// Funzioni di gestione stato
void updateSystem(unsigned long currentTime);
void processState(unsigned long currentTime);

// Handler stati BLE
void handleIdleState();
void handleConnectedState();
void handleDisconnectedState();
//void handleSubscribedState();
//void handleUnsubscribedState();

// Handler stati di rilevamento caduta
void handleWaitingValley(float accel, unsigned long currentTime);
void handleIdentifyingValley(float accel, unsigned long currentTime);
void handleWaitingPeak(float accel, unsigned long currentTime);
void handleIdentifyingPeak(float accel, unsigned long currentTime);
void handleAnalyzingFall(unsigned long currentTime);
void handleMonitoringRecovery(unsigned long currentTime);
void handleAlarmTrigger();

// BLE Event handlers
void onBLEConnected(BLEDevice central);
void onBLEDisconnected(BLEDevice central);
void onBLESubscribed(BLEDevice central, BLECharacteristic characteristic);
void onBLEUnsubscribed(BLEDevice central, BLECharacteristic characteristic);
void onAlarmReset(BLEDevice central, BLECharacteristic characteristic);

// Reset parametri
void resetDetectionParameters();

#endif // STATE_MACHINE_H