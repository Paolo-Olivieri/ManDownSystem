//
// Created by Paolo Olivieri on 23/12/24.
//

#ifndef BUFFER_H
#define BUFFER_H

#include "config.h"
#include "utilities.h"

// Buffer circolari
extern float pressureBuffer[BUFFER_SIZE];
extern float accelBuffer[BUFFER_SIZE];
extern unsigned long timestampBuffer[BUFFER_SIZE];

// Funzioni di gestione buffer
void initializeBuffers();
void addSample(float pressure, float accel, unsigned long timestamp);
void clearBuffers();

// Funzioni di analisi
float calculateMeanInTimeWindow(float* buffer, unsigned long startTime, unsigned long endTime);

float calculateVarianceInTimeWindow(float* buffer, unsigned long startTime, unsigned long endTime);

#endif // BUFFER_H