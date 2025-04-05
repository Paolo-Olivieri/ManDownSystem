// main.ino
#include "mbed.h"
#include "Arduino.h"
#include "config.h"
#include "sensors.h"
#include "buffer.h"
#include "state_machine.h"
#include "ble_handlers.h"
#include "utilities.h"

// Variabili di temporizzazione
unsigned long lastBatteryUpdate = 0;
unsigned long lastReadTime = 0;

void setup() {
    // Inizializzazione seriale
    Serial.begin(115200);

    // Inizializzazione sistema Nicla
    nicla::begin();
    nicla::leds.begin();
    nicla::enableCharging(100);

    // Inizializzazione sensori
    BHY2.begin();
    initializeSensors();

    // Inizializzazione buffer
    initializeBuffers();

    // Inizializzazione BLE
    initializeBLE();

    debugPrint("Sistema inizializzato e pronto all'uso!");
}

void loop() {
    updateSystem(millis());
}