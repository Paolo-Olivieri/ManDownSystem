//
// Created by Paolo Olivieri on 23/12/24.
//

#include "ble_handlers.h"

// Inizializzazione servizi BLE
BLEService fallDetectionService(BLE_SENSE_UUID("0000"));
BLEService batteryService(BATTERY_SERVICE_UUID);

// Inizializzazione caratteristiche BLE
BLEByteCharacteristic fallAlarmCharacteristic(BLE_SENSE_UUID("1111"), BLERead | BLENotify | BLEWrite);
BLEByteCharacteristic batteryLevelCharacteristic(BATTERY_LEVEL_CHAR_UUID, BLERead | BLENotify);

bool initializeBLE() {
    if (!BLE.begin()) {
        debugPrint("Inizializzazione BLE fallita!");
        blinkLED(LED_RED, 1000, 500, 3);
        return false;
    }

    // Configurazione BLE
    BLE.disconnect();
    BLE.setConnectionInterval(6, 12);  // 7.5-15 ms
    BLE.setSupervisionTimeout(1000);   // Timeout in 4 secondi
    BLE.setLocalName("Man Down");
    BLE.setDeviceName("Man Down");

    setupBLEServices();
    updateBatteryLevel();
    fallAlarmCharacteristic.writeValue(0x00);

    debugPrint("Bluetooth Low Energy inizializzato con successo");

    return true;
}

void setupBLEServices() {
    // Configurazione servizi
    BLE.setAdvertisedService(fallDetectionService);
    BLE.setAdvertisedService(batteryService);

    // Aggiunta caratteristiche ai servizi
    fallDetectionService.addCharacteristic(fallAlarmCharacteristic);
    batteryService.addCharacteristic(batteryLevelCharacteristic);

    // Aggiunta servizi al BLE
    BLE.addService(fallDetectionService);
    BLE.addService(batteryService);

    // Setup event handlers
    fallAlarmCharacteristic.setEventHandler(BLESubscribed, onBLESubscribed);
    fallAlarmCharacteristic.setEventHandler(BLEUnsubscribed, onBLEUnsubscribed);
    fallAlarmCharacteristic.setEventHandler(BLEWritten, onAlarmReset);

    BLE.setEventHandler(BLEConnected, onBLEConnected);
    BLE.setEventHandler(BLEDisconnected, onBLEDisconnected);

    BLE.advertise();
    
}

void updateBatteryLevel() {
    uint8_t batteryLevel = nicla::getBatteryVoltagePercentage();
    batteryLevelCharacteristic.writeValue(batteryLevel);

    #ifdef DEBUG_MODE
    debugPrint("Livello Batteria: ", batteryLevel, "%");
    #endif

}
