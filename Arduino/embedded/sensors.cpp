//
// Created by Paolo Olivieri on 23/12/24.
//

#include "sensors.h"
#include "utilities.h"

// Inizializzazione oggetti sensore
static SensorXYZ accel(SENSOR_ID_ACC);
static Sensor pressure(SENSOR_ID_BARO);

void initializeSensors() {
    // Inizializzazione accelerometro
    accel.begin();
    accel.setRange(8);  // Range ±8g

    // Inizializzazione barometro
    pressure.begin();

    debugPrint("Sensori inizializzati con successo");
}

float readAccelerometer() {
    // Lettura delle tre componenti
    float ax = accel.x() * ACCEL_8G_CONV_FACTOR;
    float ay = accel.y() * ACCEL_8G_CONV_FACTOR;
    float az = accel.z() * ACCEL_8G_CONV_FACTOR;

    // Calcolo della magnitudine dell'accelerazione
    float magnitude = std::sqrt(ax * ax + ay * ay + az * az);

    return magnitude;
}

float readPressure() {
    return pressure.value();
}

void printSensorValues() {
    float acc = readAccelerometer();
    float press = readPressure();

    debugPrint("Accelerazione (g): ", acc);
    debugPrint("Pressione (hPa): ", press);
}