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
% Vengono valutati i valori di varianza in finestre di 2 secondi

% Percorso della cartella contenente i file CSV di 'Stairs'
% Percorso della cartella contenente i file CSV di 'Stairs'

folderPath = '/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/Test/LyingMovement';

% Inizializzazione dei vettori per salvare le varianze medie
mean_variances = [];
all_variances = [];
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
    variances = [];

    % Calcolo della varianza su finestre di due secondi
    for j = 1:window_size:length(accMagnitude) - window_size + 1
        % Estrazione dei dati di accelerazione per la finestra corrente
        window_data = accMagnitude(j:j + window_size - 1);
        
        % Calcolo della varianza della finestra corrente
        variance_value = var(window_data);
        
        % Salvo la varianza calcolata
        variances = [variances variance_value];
    end
    disp(variances);

    all_variances = [all_variances variances];

    % Calcolo della media delle varianze per il file corrente
    mean_variance = mean(variances);
    
    % Salvo la media delle varianze in un vettore
    mean_variances = [mean_variances; mean_variance];
end

% Risultato finale: vettore mean_variances contiene la media delle varianze per ciascun file
disp(mean_variances);





%% PERCENTILI MIN
% utili per definire una soglia che sia robusta ad outlier e
% rappresentativa della distribuzione dei dati.

% Esempio: 95° Percentile: significa che solo il 5% dei picchi supererà
% questa soglia Utile per rilevare eventi rari come le cadute.

% 5° Percentile: significa che il 95% dei picchi sarà sopra questa soglia.
% Utile per rilevare eventi che sono molto meno intensi rispetto ai picchi
% normali.

% Calcolo dei percentili
percMean = prctile(mean_variances, [0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100]);
percAll = prctile(all_variances, [0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100]);


% Creazione del grafico a barre
figure('Name','LyingMovement')
subplot(2,2,1);
bar([0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100], percMean);
title('Percentili delle varianze medie LyingMovement');
xlabel('Percentile');
ylabel('Varianza [$g^2$]');

subplot(2,2,2);
bar([0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100], percAll);
title('Percentili delle varianze LyingMovement');
xlabel('Percentile');
ylabel('Varianza [$g^2$]');

subplot(2,2,3);
title('Istogramma delle varianze medie di LyingMovement');
histogram(mean_variances);

subplot(2,2,4);
title('Istogramma delle varianze totali di LyingMovement');
histogram(all_variances);


min_prctile = 5;
max_prctile = 95;

fprintf("%d-Percentile Valore massimo: %.4f\n" ,max_prctile, prctile(mean_variances,max_prctile));


fprintf("%d-Percentile Valore Minimi: %.4f\n",min_prctile , prctile(mean_variances,min_prctile));


%
% str3 = sprintf("Media Valore massimo: %.4f" , mean(max_peak_vec));
% disp(str3);
%
% str4 = sprintf("Media Valore minimo: %.4f" , mean(min_valley_vec));
% disp(str4)


%%
folderPath = '/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/Test/LyingStill';

% Inizializzazione dei vettori per salvare le varianze medie
mean_variances = [];
all_variances = [];

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
    variances = [];

    % Calcolo della varianza su finestre di due secondi
    for j = 1:window_size:length(accMagnitude) - window_size + 1
        % Estrazione dei dati di accelerazione per la finestra corrente
        window_data = accMagnitude(j:j + window_size - 1);
        
        % Calcolo della varianza della finestra corrente
        variance_value = var(window_data);
        
        % Salvo la varianza calcolata
        variances = [variances variance_value];
    end

    disp(variances);
    all_variances = [all_variances variances];
    % Calcolo della media delle varianze per il file corrente
    mean_variance = mean(variances);
    
    % Salvo la media delle varianze in un vettore
    mean_variances = [mean_variances; mean_variance];
end

% Risultato finale: vettore mean_variances contiene la media delle varianze per ciascun file
disp(mean_variances);





%% PERCENTILI MIN
% utili per definire una soglia che sia robusta ad outlier e
% rappresentativa della distribuzione dei dati.

% Esempio: 95° Percentile: significa che solo il 5% dei picchi supererà
% questa soglia Utile per rilevare eventi rari come le cadute.

% 5° Percentile: significa che il 95% dei picchi sarà sopra questa soglia.
% Utile per rilevare eventi che sono molto meno intensi rispetto ai picchi
% normali.

% Calcolo dei percentili
percentili = prctile(mean_variances, [0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100]);


percMean = prctile(mean_variances, [0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100]);
percAll = prctile(all_variances, [0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100]);


% Creazione del grafico a barre
figure('Name','LyingStill')
subplot(2,2,1);
bar([0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100], percMean);
title('Percentili delle varianze medie LyingStill');
xlabel('Percentile');
ylabel('Varianza [$g^2$]');

subplot(2,2,2);
bar([0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100], percAll);
title('Percentili delle varianze LyingStill');
xlabel('Percentile');
ylabel('Varianza [$g^2$]');

subplot(2,2,3);
title('Istogramma delle varianze medie di LyingStill');
histogram(mean_variances);

subplot(2,2,4);
title('Istogramma delle varianze totali di LyingStill');
histogram(all_variances);



min_prctile = 5;
max_prctile = 95;

fprintf("%d-Percentile Valore massimo: %.4f\n" ,max_prctile, prctile(mean_variances,max_prctile));


fprintf("%d-Percentile Valore Minimi: %.4f\n",min_prctile , prctile(mean_variances,min_prctile));


%
% str3 = sprintf("Media Valore massimo: %.4f" , mean(max_peak_vec));
% disp(str3);
%
% str4 = sprintf("Media Valore minimo: %.4f" , mean(min_valley_vec));
% disp(str4)


%%
folderPath = '/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/Test/Walk';

% Inizializzazione dei vettori per salvare le varianze medie
mean_variances = [];
all_variances = [];

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
    variances = [];

    % Calcolo della varianza su finestre di due secondi
    for j = 1:window_size:length(accMagnitude) - window_size + 1
        % Estrazione dei dati di accelerazione per la finestra corrente
        window_data = accMagnitude(j:j + window_size - 1);
        
        % Calcolo della varianza della finestra corrente
        variance_value = var(window_data);
        
        % Salvo la varianza calcolata
        variances = [variances variance_value];
    end

    disp(variances)
    all_variances = [all_variances variances];
    % Calcolo della media delle varianze per il file corrente
    mean_variance = mean(variances);
    
    % Salvo la media delle varianze in un vettore
    mean_variances = [mean_variances; mean_variance];
end

% Risultato finale: vettore mean_variances contiene la media delle varianze per ciascun file
disp(mean_variances);





%% PERCENTILI MIN
% utili per definire una soglia che sia robusta ad outlier e
% rappresentativa della distribuzione dei dati.

% Esempio: 95° Percentile: significa che solo il 5% dei picchi supererà
% questa soglia Utile per rilevare eventi rari come le cadute.

% 5° Percentile: significa che il 95% dei picchi sarà sopra questa soglia.
% Utile per rilevare eventi che sono molto meno intensi rispetto ai picchi
% normali.

% Calcolo dei percentili
percentili = prctile(mean_variances, [0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100]);

percMean = prctile(mean_variances, [0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100]);
percAll = prctile(all_variances, [0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100]);


% Creazione del grafico a barre
figure('Name','Walk')
subplot(2,2,1);
bar([0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100], percMean);
title('Percentili delle varianze medie Walk');
xlabel('Percentile');
ylabel('Varianza [$g^2$]');

subplot(2,2,2);
bar([0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100], percAll);
title('Percentili delle varianze Walk');
xlabel('Percentile');
ylabel('Varianza [$g^2$]');

subplot(2,2,3);
title('Istogramma delle varianze medie di Walk');
histogram(mean_variances);

subplot(2,2,4);
title('Istogramma delle varianze totali di Walk');
histogram(all_variances);


min_prctile = 5;
max_prctile = 95;

fprintf("%d-Percentile Valore massimo: %.4f\n" ,max_prctile, prctile(mean_variances,max_prctile));


fprintf("%d-Percentile Valore Minimi: %.4f\n",min_prctile , prctile(mean_variances,min_prctile));


%
% str3 = sprintf("Media Valore massimo: %.4f" , mean(max_peak_vec));
% disp(str3);
%
% str4 = sprintf("Media Valore minimo: %.4f" , mean(min_valley_vec));
% disp(str4)


%%
folderPath = '/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/Test/Stairs';

% Inizializzazione dei vettori per salvare le varianze medie
mean_variances = [];
all_variances = [];
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
    variances = [];

    % Calcolo della varianza su finestre di due secondi
    for j = 1:window_size:length(accMagnitude) - window_size + 1
        % Estrazione dei dati di accelerazione per la finestra corrente
        window_data = accMagnitude(j:j + window_size - 1);
        
        % Calcolo della varianza della finestra corrente
        variance_value = var(window_data);
        
        % Salvo la varianza calcolata
        variances = [variances variance_value];
    end

    disp(variances);
    all_variances = [all_variances variances];
    % Calcolo della media delle varianze per il file corrente
    mean_variance = mean(variances);
    
    % Salvo la media delle varianze in un vettore
    mean_variances = [mean_variances; mean_variance];
end

% Risultato finale: vettore mean_variances contiene la media delle varianze per ciascun file
disp(mean_variances);





%% PERCENTILI MIN
% utili per definire una soglia che sia robusta ad outlier e
% rappresentativa della distribuzione dei dati.

% Esempio: 95° Percentile: significa che solo il 5% dei picchi supererà
% questa soglia Utile per rilevare eventi rari come le cadute.

% 5° Percentile: significa che il 95% dei picchi sarà sopra questa soglia.
% Utile per rilevare eventi che sono molto meno intensi rispetto ai picchi
% normali.

% Calcolo dei percentili
percentili = prctile(mean_variances, [0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100]);


percMean = prctile(mean_variances, [0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100]);
percAll = prctile(all_variances, [0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100]);


% Creazione del grafico a barre
figure('Name','Stairs')
subplot(2,2,1);
bar([0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100], percMean);
title('Percentili delle varianze medie Stairs');
xlabel('Percentile');
ylabel('Varianza [$g^2$]');

subplot(2,2,2);
bar([0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100], percAll);
title('Percentili delle varianze Stairs');
xlabel('Percentile');
ylabel('Varianza [$g^2$]');

subplot(2,2,3);
title('Istogramma delle varianze medie di Stairs');
histogram(mean_variances);

subplot(2,2,4);
title('Istogramma delle varianze totali di Stairs');
histogram(all_variances);



min_prctile = 5;
max_prctile = 95;

fprintf("%d-Percentile Valore massimo: %.4f\n" ,max_prctile, prctile(mean_variances,max_prctile));
fprintf("%d-Percentile Valore Minimi: %.4f\n",min_prctile , prctile(mean_variances,min_prctile));


%
% str3 = sprintf("Media Valore massimo: %.4f" , mean(max_peak_vec));
% disp(str3);
%
% str4 = sprintf("Media Valore minimo: %.4f" , mean(min_valley_vec));
% disp(str4)






%% SETUP
% In questo script sono stati considerati i dati di "Acceleration Magnitude"
% relativi ai test 'Fall&Rest' e 'Fall&Recovery', in modo da avere 40 set
% di dati per trovare una migliore soglia.

max_peak_vec = [];
min_valley_vec = [];

acceleration_data = [];
variance_vec = [];
rms_vec = [];

% Percorso della cartella contenente i file CSV di 'Fall&Rest'
folderPath = '/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/Training/Fall4Threshold';

for i = 1:50
    % Nome del file CSV
    csvName = sprintf('fall%d.csv', i);

    % Percorso completo del file
    csvPath = fullfile(folderPath, csvName);

    % Dati dal file CSV
    data = readtable(csvPath);

    accMagnitude = data.AccMagnitude;
    timestamps = data.Timestamp_Matlab;

    % Trova il picco massimo
    [max_peak, max_peak_index] = max(accMagnitude);

    % Salva il massimo di questa tabella
    max_peak_vec = [max_peak_vec, max_peak];

    % Trova il timestamp corrispondente al massimo
    max_peak_time = timestamps(max_peak_index);

    % Definisci l'intervallo da 1s a 3s dopo il massimo
    start_time = max_peak_time + 1;
    end_time = max_peak_time + 3;

    % Filtra i dati nell'intervallo di interesse
    interval_indices = timestamps >= start_time & timestamps <= end_time;
    interval_acc = accMagnitude(interval_indices);

    % Calcola la varianza nell'intervallo
    interval_variance = var(interval_acc);
    interval_rms = rms(interval_acc);
    % Salva la varianza in un vettore
    variance_vec = [variance_vec, interval_variance];
    rms_vec =[rms_vec interval_rms];
end

% Percorso della cartella contenente i file CSV di 'Fall&Rest'
folderPath = '/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/Training/VerticalFall';


for i = 1:50
    % Nome del file CSV
    csvName = sprintf('verticalFall%d.csv', i);

    % Percorso completo del file
    csvPath = fullfile(folderPath, csvName);

    % Dati dal file CSV
    data = readtable(csvPath);

    accMagnitude = data.AccMagnitude;
    timestamps = data.Timestamp_Matlab;

    % Trova il picco massimo
    [max_peak, max_peak_index] = max(accMagnitude);

    % Salva il massimo di questa tabella
    max_peak_vec = [max_peak_vec, max_peak];

    % Trova il timestamp corrispondente al massimo
    max_peak_time = timestamps(max_peak_index);

    % Definisci l'intervallo da 1s a 3s dopo il massimo
    start_time = max_peak_time + 1;
    end_time = max_peak_time + 3;

    % Filtra i dati nell'intervallo di interesse
    interval_indices = timestamps >= start_time & timestamps <= end_time;
    interval_acc = accMagnitude(interval_indices);

    % Calcola la varianza nell'intervallo
    interval_variance = var(interval_acc);
    interval_rms = rms(interval_acc);
    % Salva la varianza in un vettore
    variance_vec = [variance_vec, interval_variance];
    rms_vec =[rms_vec interval_rms];
end

mean(variance_vec);
% Calcola i percentili delle varianze
percentili = [10, 25, 50, 75, 90]; % Percentili desiderati
percentili_values = prctile(variance_vec, percentili);

% Crea il grafico a barre
figure;
bar(percentili, percentili_values, 'FaceColor', [0.4 0.7 0.2], 'EdgeColor', 'k');
xlabel('Percentili');
ylabel('Varianza');
title('Grafico dei Percentili della Varianza');
grid on;

% Aggiungi etichette ai valori
for i = 1:length(percentili)
    text(percentili(i), percentili_values(i) + 0.01, sprintf('%.2f', percentili_values(i)), ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 10);
end
