//
// Created by Paolo Olivieri on 23/12/24.
//
#ifndef UTILITIES_H
#define UTILITIES_H

#include "config.h"

// Gestione LED
/*
void toggleLED(unsigned long& lastToggle, bool& ledState,
               unsigned long interval, uint8_t r, uint8_t g, uint8_t b);
void blinkLED(uint8_t r, uint8_t g, uint8_t b,
              unsigned long onTime, unsigned long offTime, int times);
*/

void toggleLED(const RGBColor& color, unsigned long& lastToggle, bool& ledState, unsigned long interval);
void blinkLED(const RGBColor& color, unsigned long onTime, unsigned long offTime, int times);


// Debug e reporting
void reportFall(float minAccel, float maxAccel, float pressureDelta, unsigned long tt);
void debugPrint(const char* message, float value, const char* unit);
void debugPrint(const char* message, float value);
void debugPrint(const char* message);
void debugTimeWindow(const char* regionName, unsigned long startTime,
                    unsigned long endTime, float mean);

#endif // UTILITIES_H
