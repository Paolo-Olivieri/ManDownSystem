//
// Created by Paolo Olivieri on 23/12/24.
//

#ifndef CONFIG_H
#define CONFIG_H

// Include necessari per il sistema
#include "Arduino.h"
#include <Nicla_System.h>
#include "Arduino_BHY2.h"
#include <ArduinoBLE.h>
#include <cmath>
#include <algorithm>

// Debug
// #define DEBUG_MODE    

// ======================================
// Configurazione sensori e campionamento
// ======================================
#define ACCEL_8G_CONV_FACTOR 0.00024414  // Fattore di conversione per accelerometro +-8G
#define SEND_RATE 16                     // Frequenza di invio dati in Hz
const unsigned long sendInterval = 1000 / SEND_RATE;  // Intervallo tra le letture (16Hz = 62.5ms)
#define BATTERY_UPDATE_INTERVAL 60000     // Intervallo aggiornamento batteria in ms

// ===================================
// Configurazione BLE
// ===================================
// UUID per i servizi BLE
#define BLE_SENSE_UUID(val) ("19b10000-" val "-537e-4f6c-d104768a1214")
#define BATTERY_SERVICE_UUID "180F"
#define BATTERY_LEVEL_CHAR_UUID "2A19"

// ===================================
// Parametri algoritmo Man Down
// ===================================
// Configurazione buffer
constexpr size_t BUFFER_SIZE = 256;              // Dimensione massima del buffer circolare


// Soglie di rilevamento caduta
constexpr float VALLEY_THRESHOLD = 0.74883;      // Soglia minima accelerazione (caduta libera)
constexpr float PEAK_THRESHOLD = 1.6489;         // Soglia massima accelerazione (impatto)
constexpr float PRESSURE_FALL_THRESHOLD = 0.07;  // Soglia variazione pressione per caduta (~60cm)
constexpr float PRESSURE_RECOVERY_THRESHOLD = 0.07; // Soglia pressione per recupero

// Finestre temporali
constexpr unsigned long MAX_PEAK_DELAY = 1000;    // Ritardo massimo tra valley e peak (1s)
constexpr unsigned long RECOVERY_WINDOW = 30000;   // Finestra di recupero dopo caduta (30s)
constexpr unsigned long SLIDING_WINDOW = 2000;     // Finestra in area recovery (2s)

// Parametri di analisi
constexpr double PRECISION_FACTOR = 100000.0;      // Fattore di precisione per calcoli
constexpr float ACCEL_VARIANCE_THRESHOLD = 0.0015; // Soglia varianza accelerazione post-caduta



// ===================================
// Colori LED
// ===================================
struct RGBColor {
    uint8_t r;
    uint8_t g;
    uint8_t b;
};

// Definizione dei colori
const RGBColor LED_OFF = {0, 0, 0};
const RGBColor LED_RED = {255, 0, 0};
const RGBColor LED_GREEN = {0, 255, 0};
const RGBColor LED_BLUE = {0, 0, 255};
const RGBColor LED_ORANGE = {252, 161, 3};
const RGBColor LED_PURPLE = {255, 0, 255};
const RGBColor LED_WHITE = {255, 255, 255};

/*
const uint8_t LED_OFF[3] = {0, 0, 0};
const uint8_t LED_RED[3] = {255, 0, 0};
const uint8_t LED_GREEN[3] = {0, 255, 0};
const uint8_t LED_BLUE[3] = {0, 0, 255};
const uint8_t LED_ORANGE[3] = {252, 161, 3};
const uint8_t LED_PURPLE[3] = {255, 0, 255};
*/
#endif // CONFIG_H
