%% DESCRIZIONE DELLO SCRIPT:
% Questo script è stato realizzato per la raccolta dati provenienti dalla
% Nicla Sense Me connessa tramite BLE.

%% SETUP 
clear
close all

%% INIT
WarnWave = [sin(1:.6:400), sin(1:.7:400), sin(1:.4:400)];
Audio = audioplayer(WarnWave, 22050);

plotTitle = 'convulsioni5';
folderName = '/Test/Convulsioni';

%% BLE initialization
% Find all nearby BLE devices
deviceList = blelist("Timeout",5);

% List of available devices
disp(deviceList);
  
% Connection to Arduino device via name or address  
device = ble("0AFB472B-3B8B-1416-4809-8A590CB9F2CC");

disp(device.Characteristics);

% Main characteristic
mainCharacteristic = characteristic(device,"19B10000-0000-537E-4F6C-D104768A1214","19B10000-1001-537E-4F6C-D104768A1214");


% Subscribe
subscribe(mainCharacteristic);
%play(Audio);

%% Acquisizione dati senza plot in tempo reale


disp("Inizio acquisizione dati...");


startTime = datetime('now');
duration = 10;  % Durata lettura [s]

% Sensor data vector
accelVec = [];
gyroVec = [];
pressureVec = [];
relativePressureVec = [];

firstPressureValue = NaN;

% TimeStamp vector
timestampVec_Matlab = [];
timestampVec_Nicla = [];

% Ciclo per l'acquisizione dei dati

while (seconds(datetime('now') - startTime) < duration)
    % Tempo corrente
    timestamp_Matlab = seconds(datetime('now') - startTime)
    
    data = read(mainCharacteristic);

    % Data extraction
    timestamp_Nicla = double(typecast(uint8(data(1:4)),'uint32'));

    % Barometer
    pressureValue = typecast(uint8(data(5:8)), 'single');      % Pressione (float)

    % Salva il primo valore di pressione
    if isnan(firstPressureValue)
        firstPressureValue = pressureValue;  % Assegna il primo valore
    end

    % Calcola la pressione relativa come differenza rispetto al primo campione
    relativePressureValue = pressureValue - firstPressureValue; 
    

    % Accelerometer
    accelX = typecast(uint8(data(9:12)), 'single');     % Accel X
    accelY = typecast(uint8(data(13:16)), 'single');    % Accel Y
    accelZ = typecast(uint8(data(17:20)), 'single');    % Accel Z
    accMagnitude = sqrt(accelX^2 + accelY^2 + accelZ^2);

    % Gyroscope
    gyroX = typecast(uint8(data(21:24)), 'single');     % Gyro X
    gyroY = typecast(uint8(data(25:28)), 'single');     % Gyro Y
    gyroZ = typecast(uint8(data(29:32)), 'single');     % Gyro Z
    gyroMagnitude = sqrt(gyroX^2 + gyroY^2 + gyroZ^2);

    % Aggiungi i dati ai vettori
    timestampVec_Matlab = [timestampVec_Matlab; timestamp_Matlab];
    timestampVec_Nicla = [timestampVec_Nicla; timestamp_Nicla];
    pressureVec = [pressureVec; pressureValue];
    relativePressureVec = [relativePressureVec; relativePressureValue];
    accelVec = [accelVec; accelX, accelY, accelZ, accMagnitude];
    gyroVec = [gyroVec; gyroX,gyroY,gyroZ, gyroMagnitude];

    % Pausa breve per sincronizzarsi con la frequenza di acquisizione (se necessario)
    pause(0.0625);  % Considerando che i dati arrivano ogni 50ms

end

disp("Fine acquisizione dati");
%play(Audio);

%%
% Disconnessione al termine della lettura
 unsubscribe(mainCharacteristic);
 pause(2);
 clear device;


%% Calcolo della pressione relativa (differenza tra pressioni successive)

%% Plot dei dati al termine dell'acquisizione
figure('Name', plotTitle , 'NumberTitle', 'off');

% Creazione del subplot per la pressione
subplot(3, 1, 1);
plot(timestampVec_Matlab, pressureVec, 'b', 'LineWidth', 1.5);
title('Pressure');
xlabel('Time [s]');
ylabel('Pressure [hPa]');
grid on;
xticks(0:5:max(timestampVec_Matlab));

% Creazione del subplot per i dati dell'accelerometro
subplot(3, 1, 2);
plot(timestampVec_Matlab, accelVec(:, 1), 'r', 'LineWidth', 1.5); hold on;
plot(timestampVec_Matlab, accelVec(:, 2), 'g', 'LineWidth', 1.5);
plot(timestampVec_Matlab, accelVec(:, 3), 'b', 'LineWidth', 1.5);
plot(timestampVec_Matlab, accelVec(:, 4), '-.k', 'LineWidth', 1.2);
title('Accelerometer');
xlabel('Time [s]');
ylabel('Acceleration [g]');
grid on;
legend({'$X$', '$Y$', '$Z$' , '$Magnitude$'}, 'Interpreter', 'latex', 'Location', 'best');
xticks(0:5:max(timestampVec_Matlab));

% Creazione del subplot per i dati del gyro
subplot(3, 1, 3);
plot(timestampVec_Matlab, gyroVec(:, 1), 'r', 'LineWidth', 1.5); hold on;
plot(timestampVec_Matlab, gyroVec(:, 2), 'g', 'LineWidth', 1.5);
plot(timestampVec_Matlab, gyroVec(:, 3), 'b', 'LineWidth', 1.5);
plot(timestampVec_Matlab, gyroVec(:, 4), '-.k', 'LineWidth', 1.2);
title('Gyro');
xlabel('Time [s]');
ylabel('Angular Velocity [deg/s]');
grid on;
legend({'$X$', '$Y$', '$Z$' , '$Magnitude$'}, 'Interpreter', 'latex', 'Location', 'best');
xticks(0:5:max(timestampVec_Matlab));



%% delta TimeStamp
delta_Timestamp_Matlab = diff(timestampVec_Matlab);
delta_Timestamp_Nicla = diff(timestampVec_Nicla);


%% Dati completi [timestamp Matlab,delta Timestamp , Pressure Vec, accel Vec]
dataValues = [timestampVec_Matlab,timestampVec_Nicla, pressureVec, relativePressureVec, accelVec, gyroVec];
tableValues = array2table(dataValues,"VariableNames",{'Timestamp_Matlab','Timestamp_Nicla','Pressure','Relative_Pressure','AccX','AccY','AccZ','AccMagnitude','GyroX','GyroY','GyroZ','GyroMagnitude'});

%% Salvataggio
% saveFigTable('/testName','nomeFile',tableValues)
saveFigTable(folderName,plotTitle,tableValues)


%% PLOT ACC
figure;
plot(timestampVec_Matlab,accelVec(:, 4));