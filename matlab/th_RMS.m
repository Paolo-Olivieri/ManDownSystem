%% INIT
clear;
clc;
close all;
set(0,'DefaultLineLineWidth', 1.5);
set(0,'defaultAxesFontSize', 20);
set(0,'DefaultFigureWindowStyle', 'docked');
set(0,'defaulttextInterpreter','latex');
rng('default');

%% SETUP
% In questo script sono stati considerati i dati di "Acceleration
% Magnitude" relativi ai test "Stairs", in cui il soggetto scende le scale.
% Vengono valutati i valori di RMS in finestre di 2 secondi

% Percorso della cartella contenente i file CSV di 'Stairs'
% Percorso della cartella contenente i file CSV di 'Stairs'

folderPath = '/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/Test/LyingMovement';

% Inizializzazione dei vettori per salvare le varianze medie
mean_RMSs = [];
all_RMSs = [];
% Durata della finestra in secondi
window_duration = 2;

disp("LYING MOVEMENT")

% Ciclo per caricare e analizzare ogni file CSV
for i = 1:20
    % Nome del file CSV
    csvName = sprintf('lyingMovement%d.csv', i);

    fprintf('Lying Movement %d\n', i);
    % Percorso completo del file
    csvPath = fullfile(folderPath, csvName); % fullfile per costruire il percorso

    % Dati dal file CSV
    data = readtable(csvPath); % Leggo il CSV usando il percorso completo

    % Estraggo i dati di accelerazione e timestamp
    accMagnitude = data.AccMagnitude;
    timestamps = data.Timestamp_Matlab;

    % Calcolo della frequenza di campionamento per determinare la dimensione della finestra in campioni
    sampling_frequency = 1 / mean(diff(timestamps)); % Frequenza in Hz
    window_size = round(window_duration * sampling_frequency); % Dimensione della finestra in campioni

    % Inizializzazione del vettore per le varianze
    RMSs = [];

    % Calcolo della RMS su finestre di due secondi
    for j = 1:window_size:length(accMagnitude) - window_size + 1
        % Estrazione dei dati di accelerazione per la finestra corrente
        window_data = accMagnitude(j:j + window_size - 1);
        
        % Calcolo della RMS della finestra corrente
        RMS_value = rms(window_data);
        
        % Salvo la RMS calcolata
        RMSs = [RMSs RMS_value];
    end
    disp(RMSs);

    all_RMSs = [all_RMSs RMSs];

    % Calcolo della media delle varianze per il file corrente
    mean_RMS = mean(RMSs);
    
    % Salvo la media delle varianze in un vettore
    mean_RMSs = [mean_RMSs; mean_RMS];
end

% Risultato finale: vettore mean_RMSs contiene la media delle varianze per ciascun file
disp(mean_RMSs);





%% PERCENTILI MIN
% utili per definire una soglia che sia robusta ad outlier e
% rappresentativa della distribuzione dei dati.

% Esempio: 95° Percentile: significa che solo il 5% dei picchi supererà
% questa soglia Utile per rilevare eventi rari come le cadute.

% 5° Percentile: significa che il 95% dei picchi sarà sopra questa soglia.
% Utile per rilevare eventi che sono molto meno intensi rispetto ai picchi
% normali.

% Calcolo dei percentili
percMean = prctile(mean_RMSs, [0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100]);
percAll = prctile(all_RMSs, [0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100]);


% Creazione del grafico a barre
figure('Name','LyingMovement')
subplot(2,2,1);
bar([0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100], percMean);
title('Percentili delle varianze medie LyingMovement');
xlabel('Percentile');
ylabel('RMS [$g$]');

subplot(2,2,2);
bar([0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100], percAll);
title('Percentili delle varianze LyingMovement');
xlabel('Percentile');
ylabel('RMS [$g$]');

subplot(2,2,3);
title('Istogramma delle varianze medie di LyingMovement');
histogram(mean_RMSs);

subplot(2,2,4);
title('Istogramma delle varianze totali di LyingMovement');
histogram(all_RMSs);


min_prctile = 5;
max_prctile = 95;

fprintf("%d-Percentile Valore massimo: %.4f\n" ,max_prctile, prctile(mean_RMSs,max_prctile));


fprintf("%d-Percentile Valore Minimi: %.4f\n",min_prctile , prctile(mean_RMSs,min_prctile));


%
% str3 = sprintf("Media Valore massimo: %.4f" , mean(max_peak_vec));
% disp(str3);
%
% str4 = sprintf("Media Valore minimo: %.4f" , mean(min_valley_vec));
% disp(str4)


%%
folderPath = '/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/Test/LyingStill';

% Inizializzazione dei vettori per salvare le varianze medie
mean_RMSs = [];
all_RMSs = [];

% Durata della finestra in secondi
window_duration = 2;

disp("LYING STILL")
% Ciclo per caricare e analizzare ogni file CSV
for i = 1:20
    % Nome del file CSV
    csvName = sprintf('lyingStill%d.csv', i);
    fprintf('Lying Still %d\n', i);

    % Percorso completo del file
    csvPath = fullfile(folderPath, csvName); % fullfile per costruire il percorso

    % Dati dal file CSV
    data = readtable(csvPath); % Leggo il CSV usando il percorso completo

    % Estraggo i dati di accelerazione e timestamp
    accMagnitude = data.AccMagnitude;
    timestamps = data.Timestamp_Matlab;

    % Calcolo della frequenza di campionamento per determinare la dimensione della finestra in campioni
    sampling_frequency = 1 / mean(diff(timestamps)); % Frequenza in Hz
    window_size = round(window_duration * sampling_frequency); % Dimensione della finestra in campioni

    % Inizializzazione del vettore per le varianze
    RMSs = [];

    % Calcolo della RMS su finestre di due secondi
    for j = 1:window_size:length(accMagnitude) - window_size + 1
        % Estrazione dei dati di accelerazione per la finestra corrente
        window_data = accMagnitude(j:j + window_size - 1);
        
        % Calcolo della RMS della finestra corrente
        RMS_value = rms(window_data);
        
        % Salvo la RMS calcolata
        RMSs = [RMSs RMS_value];
    end

    disp(RMSs);
    all_RMSs = [all_RMSs RMSs];
    % Calcolo della media delle varianze per il file corrente
    mean_RMS = mean(RMSs);
    
    % Salvo la media delle varianze in un vettore
    mean_RMSs = [mean_RMSs; mean_RMS];
end

% Risultato finale: vettore mean_RMSs contiene la media delle varianze per ciascun file
disp(mean_RMSs);





%% PERCENTILI MIN
% utili per definire una soglia che sia robusta ad outlier e
% rappresentativa della distribuzione dei dati.

% Esempio: 95° Percentile: significa che solo il 5% dei picchi supererà
% questa soglia Utile per rilevare eventi rari come le cadute.

% 5° Percentile: significa che il 95% dei picchi sarà sopra questa soglia.
% Utile per rilevare eventi che sono molto meno intensi rispetto ai picchi
% normali.

% Calcolo dei percentili
percentili = prctile(mean_RMSs, [0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100]);


percMean = prctile(mean_RMSs, [0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100]);
percAll = prctile(all_RMSs, [0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100]);


% Creazione del grafico a barre
figure('Name','LyingStill')
subplot(2,2,1);
bar([0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100], percMean);
title('Percentili delle varianze medie LyingStill');
xlabel('Percentile');
ylabel('RMS [$g$]');

subplot(2,2,2);
bar([0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100], percAll);
title('Percentili delle varianze LyingStill');
xlabel('Percentile');
ylabel('RMS [$g$]');

subplot(2,2,3);
title('Istogramma delle varianze medie di LyingStill');
histogram(mean_RMSs);

subplot(2,2,4);
title('Istogramma delle varianze totali di LyingStill');
histogram(all_RMSs);



min_prctile = 5;
max_prctile = 95;

fprintf("%d-Percentile Valore massimo: %.4f\n" ,max_prctile, prctile(mean_RMSs,max_prctile));


fprintf("%d-Percentile Valore Minimi: %.4f\n",min_prctile , prctile(mean_RMSs,min_prctile));


%
% str3 = sprintf("Media Valore massimo: %.4f" , mean(max_peak_vec));
% disp(str3);
%
% str4 = sprintf("Media Valore minimo: %.4f" , mean(min_valley_vec));
% disp(str4)


%%
folderPath = '/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/Test/Walk';

% Inizializzazione dei vettori per salvare le varianze medie
mean_RMSs = [];
all_RMSs = [];

% Durata della finestra in secondi
window_duration = 2;

disp("Walk")
% Ciclo per caricare e analizzare ogni file CSV
for i = 1:20
    % Nome del file CSV
    csvName = sprintf('walk%d.csv', i);
    fprintf('Walk %d\n', i);

    % Percorso completo del file
    csvPath = fullfile(folderPath, csvName); % fullfile per costruire il percorso

    % Dati dal file CSV
    data = readtable(csvPath); % Leggo il CSV usando il percorso completo

    % Estraggo i dati di accelerazione e timestamp
    accMagnitude = data.AccMagnitude;
    timestamps = data.Timestamp_Matlab;

    % Calcolo della frequenza di campionamento per determinare la dimensione della finestra in campioni
    sampling_frequency = 1 / mean(diff(timestamps)); % Frequenza in Hz
    window_size = round(window_duration * sampling_frequency); % Dimensione della finestra in campioni

    % Inizializzazione del vettore per le varianze
    RMSs = [];

    % Calcolo della RMS su finestre di due secondi
    for j = 1:window_size:length(accMagnitude) - window_size + 1
        % Estrazione dei dati di accelerazione per la finestra corrente
        window_data = accMagnitude(j:j + window_size - 1);
        
        % Calcolo della RMS della finestra corrente
        RMS_value = rms(window_data);
        
        % Salvo la RMS calcolata
        RMSs = [RMSs RMS_value];
    end

    disp(RMSs)
    all_RMSs = [all_RMSs RMSs];
    % Calcolo della media delle varianze per il file corrente
    mean_RMS = mean(RMSs);
    
    % Salvo la media delle varianze in un vettore
    mean_RMSs = [mean_RMSs; mean_RMS];
end

% Risultato finale: vettore mean_RMSs contiene la media delle varianze per ciascun file
disp(mean_RMSs);





%% PERCENTILI MIN
% utili per definire una soglia che sia robusta ad outlier e
% rappresentativa della distribuzione dei dati.

% Esempio: 95° Percentile: significa che solo il 5% dei picchi supererà
% questa soglia Utile per rilevare eventi rari come le cadute.

% 5° Percentile: significa che il 95% dei picchi sarà sopra questa soglia.
% Utile per rilevare eventi che sono molto meno intensi rispetto ai picchi
% normali.

% Calcolo dei percentili
percentili = prctile(mean_RMSs, [0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100]);

percMean = prctile(mean_RMSs, [0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100]);
percAll = prctile(all_RMSs, [0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100]);


% Creazione del grafico a barre
figure('Name','Walk')
subplot(2,2,1);
bar([0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100], percMean);
title('Percentili delle varianze medie Walk');
xlabel('Percentile');
ylabel('RMS [$g$]');

subplot(2,2,2);
bar([0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100], percAll);
title('Percentili delle varianze Walk');
xlabel('Percentile');
ylabel('RMS [$g$]');

subplot(2,2,3);
title('Istogramma delle varianze medie di Walk');
histogram(mean_RMSs);

subplot(2,2,4);
title('Istogramma delle varianze totali di Walk');
histogram(all_RMSs);


min_prctile = 5;
max_prctile = 95;

fprintf("%d-Percentile Valore massimo: %.4f\n" ,max_prctile, prctile(mean_RMSs,max_prctile));


fprintf("%d-Percentile Valore Minimi: %.4f\n",min_prctile , prctile(mean_RMSs,min_prctile));


%
% str3 = sprintf("Media Valore massimo: %.4f" , mean(max_peak_vec));
% disp(str3);
%
% str4 = sprintf("Media Valore minimo: %.4f" , mean(min_valley_vec));
% disp(str4)


%%
folderPath = '/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/Test/Stairs';

% Inizializzazione dei vettori per salvare le varianze medie
mean_RMSs = [];
all_RMSs = [];
% Durata della finestra in secondi
window_duration = 2;

disp("STAIRS")
% Ciclo per caricare e analizzare ogni file CSV
for i = 1:20
    % Nome del file CSV
    csvName = sprintf('stairs%d.csv', i);
    fprintf('Stairs %d\n', i);

    % Percorso completo del file
    csvPath = fullfile(folderPath, csvName); % fullfile per costruire il percorso

    % Dati dal file CSV
    data = readtable(csvPath); % Leggo il CSV usando il percorso completo

    % Estraggo i dati di accelerazione e timestamp
    accMagnitude = data.AccMagnitude;
    timestamps = data.Timestamp_Matlab;

    % Calcolo della frequenza di campionamento per determinare la dimensione della finestra in campioni
    sampling_frequency = 1 / mean(diff(timestamps)); % Frequenza in Hz
    window_size = round(window_duration * sampling_frequency); % Dimensione della finestra in campioni

    % Inizializzazione del vettore per le varianze
    RMSs = [];

    % Calcolo della RMS su finestre di due secondi
    for j = 1:window_size:length(accMagnitude) - window_size + 1
        % Estrazione dei dati di accelerazione per la finestra corrente
        window_data = accMagnitude(j:j + window_size - 1);
        
        % Calcolo della RMS della finestra corrente
        RMS_value = rms(window_data);
        
        % Salvo la RMS calcolata
        RMSs = [RMSs RMS_value];
    end

    disp(RMSs);
    all_RMSs = [all_RMSs RMSs];
    % Calcolo della media delle varianze per il file corrente
    mean_RMS = mean(RMSs);
    
    % Salvo la media delle varianze in un vettore
    mean_RMSs = [mean_RMSs; mean_RMS];
end

% Risultato finale: vettore mean_RMSs contiene la media delle varianze per ciascun file
disp(mean_RMSs);





%% PERCENTILI MIN
% utili per definire una soglia che sia robusta ad outlier e
% rappresentativa della distribuzione dei dati.

% Esempio: 95° Percentile: significa che solo il 5% dei picchi supererà
% questa soglia Utile per rilevare eventi rari come le cadute.

% 5° Percentile: significa che il 95% dei picchi sarà sopra questa soglia.
% Utile per rilevare eventi che sono molto meno intensi rispetto ai picchi
% normali.

% Calcolo dei percentili
percentili = prctile(mean_RMSs, [0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100]);


percMean = prctile(mean_RMSs, [0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100]);
percAll = prctile(all_RMSs, [0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100]);


% Creazione del grafico a barre
figure('Name','Stairs')
subplot(2,2,1);
bar([0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100], percMean);
title('Percentili delle varianze medie Stairs');
xlabel('Percentile');
ylabel('RMS [$g$]');

subplot(2,2,2);
bar([0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100], percAll);
title('Percentili delle varianze Stairs');
xlabel('Percentile');
ylabel('RMS [$g$]');

subplot(2,2,3);
title('Istogramma delle varianze medie di Stairs');
histogram(mean_RMSs);

subplot(2,2,4);
title('Istogramma delle varianze totali di Stairs');
histogram(all_RMSs);



min_prctile = 5;
max_prctile = 95;

fprintf("%d-Percentile Valore massimo: %.4f\n" ,max_prctile, prctile(mean_RMSs,max_prctile));
fprintf("%d-Percentile Valore Minimi: %.4f\n",min_prctile , prctile(mean_RMSs,min_prctile));


%
% str3 = sprintf("Media Valore massimo: %.4f" , mean(max_peak_vec));
% disp(str3);
%
% str4 = sprintf("Media Valore minimo: %.4f" , mean(min_valley_vec));
% disp(str4)


%%
folderPath = '/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/Test/Convulsioni';

% Inizializzazione dei vettori per salvare le varianze medie
mean_RMSs = [];
all_RMSs = [];
% Durata della finestra in secondi
window_duration = 2;

disp("CONVULSIONI")

% Ciclo per caricare e analizzare ogni file CSV
for i = 1:5
    % Nome del file CSV
    csvName = sprintf('convulsioni%d.csv', i);

    fprintf('Convulsioni %d\n', i);
    % Percorso completo del file
    csvPath = fullfile(folderPath, csvName); % fullfile per costruire il percorso

    % Dati dal file CSV
    data = readtable(csvPath); % Leggo il CSV usando il percorso completo

    % Estraggo i dati di accelerazione e timestamp
    accMagnitude = data.AccMagnitude;
    timestamps = data.Timestamp_Matlab;

    % Calcolo della frequenza di campionamento per determinare la dimensione della finestra in campioni
    sampling_frequency = 1 / mean(diff(timestamps)); % Frequenza in Hz
    window_size = round(window_duration * sampling_frequency); % Dimensione della finestra in campioni

    % Inizializzazione del vettore per le varianze
    RMSs = [];

    % Calcolo della RMS su finestre di due secondi
    for j = 1:window_size:length(accMagnitude) - window_size + 1
        % Estrazione dei dati di accelerazione per la finestra corrente
        window_data = accMagnitude(j:j + window_size - 1);
        
        % Calcolo della RMS della finestra corrente
        RMS_value = rms(window_data);
        
        % Salvo la RMS calcolata
        RMSs = [RMSs RMS_value];
    end
    disp(RMSs);

    all_RMSs = [all_RMSs RMSs];

    % Calcolo della media delle varianze per il file corrente
    mean_RMS = mean(RMSs);
    
    % Salvo la media delle varianze in un vettore
    mean_RMSs = [mean_RMSs; mean_RMS];
end

% Risultato finale: vettore mean_RMSs contiene la media delle varianze per ciascun file
disp(mean_RMSs);





%% PERCENTILI MIN
% utili per definire una soglia che sia robusta ad outlier e
% rappresentativa della distribuzione dei dati.

% Esempio: 95° Percentile: significa che solo il 5% dei picchi supererà
% questa soglia Utile per rilevare eventi rari come le cadute.

% 5° Percentile: significa che il 95% dei picchi sarà sopra questa soglia.
% Utile per rilevare eventi che sono molto meno intensi rispetto ai picchi
% normali.

% Calcolo dei percentili
percMean = prctile(mean_RMSs, [0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100]);
percAll = prctile(all_RMSs, [0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100]);


% Creazione del grafico a barre
figure('Name','Convulsioni')
subplot(2,2,1);
bar([0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100], percMean);
title('Percentili delle varianze medie Convulsioni');
xlabel('Percentile');
ylabel('RMS [$g$]');

subplot(2,2,2);
bar([0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100], percAll);
title('Percentili delle varianze Convulsioni');
xlabel('Percentile');
ylabel('RMS [$g$]');

subplot(2,2,3);
title('Istogramma delle varianze medie di Convulsioni');
histogram(mean_RMSs);

subplot(2,2,4);
title('Istogramma delle varianze totali di Convulsioni');
histogram(all_RMSs);


min_prctile = 5;
max_prctile = 95;

fprintf("%d-Percentile Valore massimo: %.4f\n" ,max_prctile, prctile(mean_RMSs,max_prctile));


fprintf("%d-Percentile Valore Minimi: %.4f\n",min_prctile , prctile(mean_RMSs,min_prctile));


%
% str3 = sprintf("Media Valore massimo: %.4f" , mean(max_peak_vec));
% disp(str3);
%
% str4 = sprintf("Media Valore minimo: %.4f" , mean(min_valley_vec));
% disp(str4)
