%% DESCRIZIONE DELLO SCRIPT:
% Questo script è stato realizzato per leggere le proprietà relative allo
% stato della batteria collegata a Nicla Sense Me.

%% INIT
clear;
close all;

%%
% Scansione e connessione al dispositivo BLE
disp('Scansione dei dispositivi BLE...');
deviceList = blelist; % Lista dei dispositivi disponibili
disp(deviceList); % Mostra i dispositivi trovati

% Inserisci il nome del dispositivo, ad esempio "NiclaSenseME"
deviceName = 'NiclaSenseME';
bleDevice = ble(deviceName);

% Mostra i servizi disponibili
disp('Servizi BLE disponibili:');
disp(bleDevice.Services);

% Identifica il servizio e le caratteristiche interessate
serviceUUID = "19b10000-0000-537e-4f6c-d104768a1214"; % UUID del servizio della batteria
batteryService = characteristic(bleDevice, serviceUUID, "19b10000-1001-537e-4f6c-d104768a1214"); % Percentuale batteria

batteryVoltageChar = characteristic(bleDevice, serviceUUID, "19b10000-1002-537e-4f6c-d104768a1214"); % Tensione batteria
batteryChargeLevelChar = characteristic(bleDevice, serviceUUID, "19b10000-1003-537e-4f6c-d104768a1214"); % Livello di carica batteria
runsOnBatteryChar = characteristic(bleDevice, serviceUUID, "19b10000-1004-537e-4f6c-d104768a1214"); % Funziona su batteria
isChargingChar = characteristic(bleDevice, serviceUUID, "19b10000-1005-537e-4f6c-d104768a1214"); % Stato di carica

% Funzione per leggere i dati dalle caratteristiche
function readBatteryData(batteryService, batteryVoltageChar, batteryChargeLevelChar, runsOnBatteryChar, isChargingChar)
    % Leggi il livello di percentuale della batteria
    batteryPercentage = read(batteryService);
    perc = double(typecast(uint8(batteryPercentage),'uint32'));
    disp(['Battery Percentage: ', num2str(perc), '%']);
    
    % Leggi la tensione della batteria
    batteryVoltage = read(batteryVoltageChar);
    volt = double(typecast(uint8(batteryVoltage),'single'));
    disp(['Battery Voltage: ', num2str(volt), ' V']);
    
    % Leggi il livello di carica della batteria
    batteryChargeLevel = read(batteryChargeLevelChar);
    disp(['Battery Charge Level: ', num2str(batteryChargeLevel)]);
    
    % Leggi se il dispositivo sta funzionando a batteria
    runsOnBattery = read(runsOnBatteryChar);
    disp(['Runs on Battery: ', num2str(runsOnBattery)]);
    
    % Leggi lo stato di carica della batteria
    isCharging = read(isChargingChar);
    disp(['Is Charging: ', num2str(isCharging)]);
end

% Esegui lettura dati
disp('Lettura delle caratteristiche della batteria...');
readBatteryData(batteryService, batteryVoltageChar, batteryChargeLevelChar, runsOnBatteryChar, isChargingChar);
