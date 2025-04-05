//
// Created by Paolo Olivieri on 23/12/24.
//

#include "utilities.h"

/*
void toggleLED(unsigned long& lastToggle, bool& ledState,
               unsigned long interval, uint8_t r, uint8_t g, uint8_t b) {
    if (millis() - lastToggle >= interval) {
        lastToggle = millis();
        ledState = !ledState;

        if (ledState) {
            nicla::leds.setColor(r, g, b);
        } else {
            nicla::leds.setColor(LED_OFF[0], LED_OFF[1], LED_OFF[2]);
        }
    }
}

void blinkLED(uint8_t r, uint8_t g, uint8_t b,
              unsigned long onTime, unsigned long offTime, int times) {
    for(int i = 0; i < times; i++) {
        nicla::leds.setColor(r, g, b);
        delay(onTime);
        nicla::leds.setColor(LED_OFF[0], LED_OFF[1], LED_OFF[2]);
        if(i < times - 1) {  // Non fare delay dopo l'ultimo spegnimento
            delay(offTime);
        }
    }
}
*/

void toggleLED(const RGBColor& color, unsigned long& lastToggle, bool& ledState, unsigned long interval) {
    if (millis() - lastToggle >= interval) {
        lastToggle = millis();
        ledState = !ledState;

        if (ledState) {
            nicla::leds.setColor(color.r, color.g, color.b);
        } else {
            nicla::leds.setColor(LED_OFF.r, LED_OFF.g, LED_OFF.b);
        }
    }
}

void blinkLED(const RGBColor& color, unsigned long onTime, unsigned long offTime, int times) {
    for(int i = 0; i < times; i++) {
        nicla::leds.setColor(color.r, color.g, color.b);
        delay(onTime);
        nicla::leds.setColor(LED_OFF.r, LED_OFF.g, LED_OFF.b);
        if(i < times - 1) { //Evita pausa dopo l'ultimo ciclo
            delay(offTime);
        }
    }
}

void reportFall(float minAccel, float maxAccel, float pressureDelta, unsigned long tt) {
    Serial.println("==========================================");
    Serial.println("         CADUTA RILEVATA!               ");
    Serial.println("==========================================");

    #ifdef DEBUG_MODE
    Serial.print("Accelerazione Minima (Caduta Libera): ");
    Serial.print(minAccel);
    Serial.println(" g");

    Serial.print("Accelerazione Massima (Impatto): ");
    Serial.print(maxAccel);
    Serial.println(" g");

    Serial.print("Variazione Pressione: ");
    Serial.print(pressureDelta);
    Serial.println(" hPa");

    Serial.print("Variazione altitudine: ");
    Serial.print(pressureDelta/0.12);
    Serial.println(" m");
    Serial.println("==========================================");
    #endif
}

void debugPrint(const char* message, float value, const char* unit) {
    Serial.print(message);
    Serial.print(value);
    Serial.println(unit);
}

void debugPrint(const char* message, float value) {
    Serial.print(message);
    Serial.println(value);
}


void debugPrint(const char* message) {
    Serial.println(message);
}

void debugTimeWindow(const char* regionName, unsigned long startTime,
                    unsigned long endTime, float mean) {
    Serial.println("----------------------------------------");
    Serial.print("Regione: ");
    Serial.println(regionName);
    Serial.print("Intervallo: [");
    Serial.print(startTime);
    Serial.print(", ");
    Serial.print(endTime);
    Serial.println("] ms");
    Serial.print("Media: ");
    Serial.print(mean);
    Serial.println(" hPa");
    Serial.println("----------------------------------------");
}