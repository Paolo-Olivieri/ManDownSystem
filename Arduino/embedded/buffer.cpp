//
// Created by Paolo Olivieri on 23/12/24.
//

#include "buffer.h"

// Inizializzazione buffer circolari
float pressureBuffer[BUFFER_SIZE] = {0};
float accelBuffer[BUFFER_SIZE] = {0};
unsigned long timestampBuffer[BUFFER_SIZE] = {0};

// Inizializzazione indici
static size_t bufferHead = 0;
static size_t bufferCount = 0;

void initializeBuffers() {
    bufferHead = 0;
    bufferCount = 0;
    clearBuffers();
}

void clearBuffers() {
    for(size_t i = 0; i < BUFFER_SIZE; i++) {
        pressureBuffer[i] = 0;
        accelBuffer[i] = 0;
        timestampBuffer[i] = 0;
    }
}

void addSample(float pressure, float accel, unsigned long timestamp) {
    // Inserimento nel buffer circolare
    pressureBuffer[bufferHead] = pressure;
    accelBuffer[bufferHead] = accel;
    timestampBuffer[bufferHead] = timestamp;

    // Aggiornamento indice di testa
    bufferHead = (bufferHead + 1) % BUFFER_SIZE;

    // Aggiornamento contatore elementi
    if(bufferCount < BUFFER_SIZE) {
        bufferCount++;
    }

#ifdef DEBUG_MODE  // Se definito in config.h
    debugPrint("Campione aggiunto - Pressione: ", pressure," hPa");
    debugPrint("Accelerazione: ", accel," g");
    debugPrint("Timestamp: ", timestamp," ms");
#endif
}

float calculateMeanInTimeWindow(float* buffer, unsigned long startTime, unsigned long endTime) {
    float sum = 0;
    size_t count = 0;

    for(size_t i = 0; i < bufferCount; i++) {
        // Calcolo indice nel buffer circolare
        size_t idx = (bufferHead + BUFFER_SIZE - bufferCount + i) % BUFFER_SIZE;

        // Verifica se il timestamp è nella finestra temporale
        if(timestampBuffer[idx] >= startTime && timestampBuffer[idx] <= endTime) {
            sum += buffer[idx];
            count++;
        }
    }

    return (count > 0) ? (sum / count) : 0;
}

float calculateVarianceInTimeWindow(float* buffer, unsigned long startTime, unsigned long endTime) {
    float mean = calculateMeanInTimeWindow(buffer, startTime, endTime);
    float sumSquaredDiff = 0;
    size_t count = 0;

    for(size_t i = 0; i < bufferCount; i++) {
        size_t idx = (bufferHead + BUFFER_SIZE - bufferCount + i) % BUFFER_SIZE;

        if(timestampBuffer[idx] >= startTime && timestampBuffer[idx] <= endTime) {
            float diff = buffer[idx] - mean;
            sumSquaredDiff += diff * diff;
            count++;
        }
    }

    // Arrotondamento per gestire la precisione dei decimali
    return (count > 0) ? std::round((sumSquaredDiff / count) * PRECISION_FACTOR) : 0;
}
