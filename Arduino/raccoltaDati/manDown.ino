#include "mbed.h"
#include <Nicla_System.h>
#include "Arduino.h"
#include "Arduino_BHY2.h"
#include <ArduinoBLE.h>
#include <Wire.h>

#define ACCEL_4G_CONV_FACTOR 0.00012207 // [1/8192]
#define ACCEL_8G_CONV_FACTOR 0.00024414 // [1/4096]
#define GYRO_2Kdps_CONV_FACTOR 0.06075609 // [1/16.4]


// Frequenze di campionamento
#define SEND_RATE 16        // 16Hz invio dei dati
//#define GYRO_RATE 100       // 100Hz per il giroscopio
#define ACCEL_RATE 100      // 100Hz per l'accelerometro
#define BARO_RATE 16        // 16Hz per il barometro

unsigned long sendInterval = 1000 / SEND_RATE;  // intervallo di invio dati in ms

#define BLE_SENSE_UUID(val) ("19b10000-" val "-537e-4f6c-d104768a1214") // UUID per servizi BLE personalizzati

// Sensor initialization
SensorXYZ accel(SENSOR_ID_ACC);
//SensorXYZ gyro(SENSOR_ID_GYRO);
Sensor pressure(SENSOR_ID_BARO);

BLEService mainService(BLE_SENSE_UUID("0000"));
BLECharacteristic mainCharacteristic(BLE_SENSE_UUID("1001"), BLERead | BLENotify, 20);

struct SensorData {
    unsigned long timestamp;
    
    float pressure;
    
    float accelX;
    float accelY;
    float accelZ;

  /*
    float gyroX;
    float gyroY;
    float gyroZ;
  */
};

enum State {
  IDLE,
  CONNECTED,
  DISCONNECTED,
  SUBSCRIBED,
  UNSUBSCRIBED
};

State currentState = IDLE;

//------------------ SETUP ------------------//
void setup()
{
  Serial.begin(115200);

  while(!Serial);

  // BEGIN
  BHY2.begin();

  accel.begin(ACCEL_RATE,1);
  accel.setRange(8);
  //gyro.begin(GYRO_RATE,1); //di default a +-2000 dpi
  pressure.begin(BARO_RATE,1);

  nicla::begin();
  nicla::leds.begin(); // Start the LED functionality


  if (!BLE.begin()) { // Bluetooth Low Energy (BLE)
    nicla::leds.setColor(red);  
    delay(1000);                
    nicla::leds.setColor(off);
    while (1);
  }

  // BLE CONFIG
  BLE.setLocalName("ManDown");
  BLE.setDeviceName("ManDown");
  BLE.setAdvertisedService(mainService);
  mainService.addCharacteristic(mainCharacteristic);
  BLE.addService(mainService);
  BLE.advertise();



  // CALLBACK SUBSCRIBE AND UNSUBSCRIBE
  mainCharacteristic.setEventHandler(BLESubscribed, onBLESubscribed);
  mainCharacteristic.setEventHandler(BLEUnsubscribed, onBLEUnsubscribed);


  // CALLBACK CONNECTED AND DISCONNECTED
  BLE.setEventHandler(BLEConnected, onBLEConnected);
  BLE.setEventHandler(BLEDisconnected, onBLEDisconnected);
  
}



//------------------ LOOP ------------------//
void loop() {
  static auto lastCheck = millis();
  static auto lastLedToggle = millis(); // Variabile per il lampeggio del LED
  static bool ledOn = false;            // Variabile per memorizzare lo stato del LED

  // Update function should be continuously polled
  BHY2.update();
  BLE.poll();



  switch (currentState){
    case IDLE:
      handleIdleState(lastLedToggle, ledOn);
    break;

    case CONNECTED:
      handleConnectedState(lastCheck, lastLedToggle, ledOn);
    break;

    case DISCONNECTED:
      handleDisconnectedState();
    break;

    case SUBSCRIBED:
      handleSubscribedState(lastCheck, lastLedToggle, ledOn);
    break;

    case UNSUBSCRIBED:
      handleUnsubscribedState();
    break;
  }
}

// Funzione per leggere i dati dai sensori, solo se tutti sono disponibili
SensorData readSensorData() {
    SensorData sensor_data;

    sensor_data.timestamp = millis();

    // Leggi e converte i dati dell'accelerometro
    sensor_data.accelX = accel.x() * ACCEL_8G_CONV_FACTOR;
    sensor_data.accelY = accel.y() * ACCEL_8G_CONV_FACTOR;
    sensor_data.accelZ = accel.z() * ACCEL_8G_CONV_FACTOR;
    accel.clearDataAvailFlag(); // Pulisce il flag solo dopo la lettura

/*
    // Leggi e converte i dati del giroscopio
    sensor_data.gyroX = gyro.x() * GYRO_2Kdps_CONV_FACTOR;
    sensor_data.gyroY = gyro.y() * GYRO_2Kdps_CONV_FACTOR;
    sensor_data.gyroZ = gyro.z() * GYRO_2Kdps_CONV_FACTOR;
    gyro.clearDataAvailFlag(); // Pulisce il flag solo dopo la lettura
*/

    // Leggi i dati del barometro
    sensor_data.pressure = pressure.value();
    pressure.clearDataAvailFlag(); // Pulisce il flag solo dopo la lettura
    

    return sensor_data;
}

// Funzione per inviare i dati del sensore via BLE
void sendSensorData(SensorData& sensor_data) {
  uint8_t data[sizeof(SensorData)];
  memcpy(data, &sensor_data, sizeof(SensorData));
  mainCharacteristic.writeValue(data, sizeof(data));
}

/**************** FSW STATE HANDLING ****************/

// IDLE STATE
void handleIdleState(unsigned long& lastLedToggle, bool& ledOn) {
    if (millis() - lastLedToggle >= 500) {
      lastLedToggle = millis();
      ledOn = !ledOn;
      nicla::leds.setColor(ledOn ? blue : off);
    }
}

// CONNECTED STATE
void handleConnectedState(unsigned long& lastCheck, unsigned long& lastLedToggle, bool& ledOn) {
  // Lampeggio del LED bianco durante l'invio dei dati con intensità ridotta
    if (millis() - lastLedToggle >= 400) {  // Intervallo di 100 ms per il lampeggio
      lastLedToggle = millis();
      ledOn = !ledOn;  // Inverte lo stato del LED
      if (ledOn) {
        nicla::leds.setColor(white);  
      } else {
        nicla::leds.setColor(off); 
      }
    }
  if (mainCharacteristic.subscribed()) {
    currentState = SUBSCRIBED;
  }
}

// DISCONNECTED STATE
void handleDisconnectedState() {
    currentState = IDLE;
    Serial.println("Device disconnected, returning to IDLE state");
}

// SUBSCRIBED STATE
void handleSubscribedState(unsigned long& lastCheck, unsigned long& lastLedToggle, bool& ledOn) {

    // Lampeggio del LED bianco durante l'invio dei dati con intensità ridotta
    if (millis() - lastLedToggle >= 400) {  // Intervallo di 100 ms per il lampeggio
      lastLedToggle = millis();
      ledOn = !ledOn;  // Inverte lo stato del LED
      if (ledOn) {
        nicla::leds.setColor(green);  
      } else {
        nicla::leds.setColor(off); 
      }
    }

    if (millis() - lastCheck >= sendInterval && (accel.dataAvailable() && pressure.dataAvailable())) {
      lastCheck = millis();
      SensorData sensor_data = readSensorData();
      sendSensorData(sensor_data);
    }

}

// UNSUBSCRIBED STATE
void handleUnsubscribedState() {
  nicla::leds.setColor(252,161,3); 
  delay(400);                  
  nicla::leds.setColor(off);
  delay(100);
  nicla::leds.setColor(252,161,3); 
  delay(400);                  
  nicla::leds.setColor(off);    
    
  currentState = CONNECTED;
}


//------------------ CALLBACK BLE SUBSCRIPTION ------------------//
void onBLESubscribed(BLEDevice central, BLECharacteristic characteristic) {
  Serial.println("SUBSCRIBED");
  currentState = SUBSCRIBED;
}

void onBLEUnsubscribed(BLEDevice central, BLECharacteristic characteristic) {
  Serial.println("UNSUBSCRIBED");
  currentState = UNSUBSCRIBED;
}

//------------------ CALLBACK BLE CONNECTION ------------------//
void onBLEConnected(BLEDevice central){
  Serial.println("CONNECTED");
  currentState = CONNECTED;

}

void onBLEDisconnected(BLEDevice central){
  Serial.println("DISCONNECTED");
  currentState = DISCONNECTED;

  nicla::leds.setColor(red);  
  delay(300);
  nicla::leds.setColor(off);
  delay(100);
  nicla::leds.setColor(red);
  delay(300);
  nicla::leds.setColor(off);
}
