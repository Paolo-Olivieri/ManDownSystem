//
// Created by Paolo Olivieri on 23/12/24.
//

#ifndef BLE_HANDLERS_H
#define BLE_HANDLERS_H

#include "config.h"
#include "utilities.h"
#include "state_machine.h"

// Servizi BLE
extern BLEService fallDetectionService;
extern BLEService batteryService;

// Caratteristiche BLE
extern BLEByteCharacteristic fallAlarmCharacteristic;
extern BLEByteCharacteristic batteryLevelCharacteristic;

// Inizializzazione BLE
bool initializeBLE();
void setupBLEServices();

// Gestione batteria
void updateBatteryLevel();


#endif // BLE_HANDLERS_H