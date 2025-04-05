//
// Created by Paolo Olivieri on 23/12/24.
//
#ifndef SENSORS_H
#define SENSORS_H

#include "config.h"

// Funzioni di inizializzazione
void initializeSensors();

// Funzioni di lettura
float readAccelerometer();
float readPressure();

// Funzioni di debug
void printSensorValues();

#endif // SENSORS_H
