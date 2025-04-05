%% INIT
clc;
clear;
close all;
set(0,'DefaultLineLineWidth', 1.5);
set(0,'defaultAxesFontSize', 20);
set(0,'DefaultFigureWindowStyle', 'docked'); 
set(0,'defaulttextInterpreter','latex');
rng('default');

%% SETUP
% In questo script sono stati considerati i dati di "Acceleration Magnitude"
% relativi ai test "Lying Still", in cui il soggetto rimane fermo mentre è
% sdraiato dopo una caduta.

% Percorso della cartella contenente i file CSV di 'LyingMovement'
folderPath = '/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/Test/LyingMovement';

max_peak_vec = [];
min_valley_vec = [];

acceleration_data = [];

BA_SMA_vec = [];
BA_SVM_vec = [];

% figure("Name",'LyingStill','NumberTitle','off');
% hold on;

% Ciclo per caricare per caduta Fall&Rest
for i = 1:30
    % Nome del file CSV
    csvName = sprintf('lyingMovement%d.csv', i);

    % Percorso completo del file
    csvPath = fullfile(folderPath, csvName); % fullfile per costruire il percorso

    % Dati dal file CSV
    data = readtable(csvPath); % Leggo il CSV usando il percorso completo

    accMagnitude = data.AccMagnitude;
    ax = data.AccX;
    ay = data.AccY;
    az = data.AccZ;
    timestamps = data.Timestamp_Matlab;

    %% CALCOLO SVM BA (Compensato)
    % Parametri del filtro passa-alto
    fs = 1/mean(diff(timestamps)); % Frequenza di campionamento in Hz (adatta il valore in base ai tuoi dati)
    cutoff_frequency = 0.4; % Frequenza di taglio in Hz per rimuovere la gravità (tipicamente  0.3-0.5 Hz sono sufficienti)

    % Creazione del filtro passa-alto
    [b, a] = butter(1, cutoff_frequency / (fs / 2), 'high');

    % Applica il filtro alle componenti x, y e z
    ax_BA = filtfilt(b, a, ax); % Body Acceleration su asse x
    ay_BA = filtfilt(b, a, ay); % Body Acceleration su asse y
    az_BA = filtfilt(b, a, az); % Body Acceleration su asse z

    BA_SVM = sqrt(ax_BA.^2 + ay_BA.^2 + az_BA.^2);
    BA_SVM_vec = [BA_SVM_vec;BA_SVM];

    %% CALCOLO SMA BA (Compensato)
    % Parametri
    window_duration = 1; % durata della finestra in secondi

    % Calcola il numero di campioni per una finestra di 1 secondo
    sampling_interval = mean(diff(timestamps)); % intervallo di campionamento medio
    samples_per_window = round(window_duration / sampling_interval); % campioni per finestra

    % Numero totale di finestre di 1 secondo
    num_windows = floor(length(timestamps) / samples_per_window);

    % Inizializzo un array per conservare i valori SMA
    sma_values = zeros(num_windows, 1);

    % Calcolo della SMA per ciascuna finestra
    for w = 1:num_windows
        % Indici di inizio e fine della finestra corrente
        start_idx = (w - 1) * samples_per_window + 1;
        end_idx = w * samples_per_window;

        % Estrai i dati della finestra corrente
        ax_window = ax_BA(start_idx:end_idx);
        ay_window = ay_BA(start_idx:end_idx);
        az_window = az_BA(start_idx:end_idx);

        % Calcola la SMA per la finestra corrente
        sma_values(w) = mean(abs(ax_window) + abs(ay_window) + abs(az_window));
    end

    BA_SMA_vec = [BA_SMA_vec;sma_values];
    % Array dei tempi per ogni finestra (centro della finestra)
    window_times = (0:num_windows - 1) * window_duration + window_duration / 2;

    
    %% SVM GA
    acceleration_data = [acceleration_data; accMagnitude];
    [max_peak, max_peak_index] = max(accMagnitude);
    max_peak_vec = [max_peak_vec, max_peak];

    [min_valley, min_valley_index] = min(accMagnitude);
    min_valley_vec = [min_valley_vec, min_valley];

    

    % Trova il picco massimo e il corrispondente timestamp

    max_peak_time = timestamps(max_peak_index);
    min_valley_time = timestamps(min_valley_index);


    % plot(timestamps, accMagnitude, 'LineWidth', 1.5);
    % % Aggiungi un triangolo sui picchi massimi
    % plot(max_peak_time, max_peak, 'rv', 'MarkerFaceColor', 'r', 'MarkerSize', 8); % Triangolo rosso
    % plot(min_valley_time, min_valley, 'rv', 'MarkerFaceColor', 'r', 'MarkerSize', 8); % Triangolo rosso
end

% % Personalizzazione del grafico
% xlabel('Timestamp');
% ylabel('Magnitudine dell''accelerazione');
% title('Sovrapposizione delle magnitudini di accelerazione per ogni test LyingMovement');
% grid on;
% hold off;



%% VERIFICA DISTRIBUZIONE NORMALE DEI PICCHI MASSIMI RILEVATI 

%   Osservazioni relative al risultato: 
% 1. Linea retta: I punti nel grafico seguono abbastanza bene una linea retta, 
% specialmente nella parte centrale. Questo suggerisce che i dati sono approssimativamente 
% normali nella parte centrale della distribuzione.

% 2. Deviazioni alle estremità: Notiamo che ci sono alcune deviazioni dalla 
% linea retta alle estremità. Questo potrebbe indicare che i dati hanno code più 
% pesanti o più leggere rispetto a una distribuzione normale, quindi la presenza
% di valori estremi (o outliers).

% figure;
% h = qqplot(max_peak_vec);
% set(h, 'Marker', 'o', 'MarkerSize', 8, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'b');

%% VERIFICA DISTRIBUZIONE NORMALE DELLE VALLI MINIME RILEVATE

%   Osservazioni relative al risultato: 
% 1. Linea retta: I punti nel grafico seguono abbastanza bene una linea retta, 
% specialmente nella parte centrale. Questo suggerisce che i dati sono approssimativamente 
% normali nella parte centrale della distribuzione.

% 2. Deviazioni alle estremità: Notiamo che ci sono alcune deviazioni dalla 
% linea retta alle estremità. Questo potrebbe indicare che i dati hanno code più 
% pesanti o più leggere rispetto a una distribuzione normale, quindi la presenza
% di valori estremi (o outliers).

% figure;
% h = qqplot(min_valley_vec);
% set(h, 'Marker', 'o', 'MarkerSize', 8, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'b');


%% HISTOGRAM MAX PEAKS
figure("Name",'Peaks & Valleys','NumberTitle','off');
subplot(2,1,1);
h1 = histogram(max_peak_vec,'LineWidth',1.8,'FaceColor','#FFA500','DisplayName','Peak'); % Istogramma per il conteggio dei campioni #40E0D0 cyan
ylabel('Conteggio dei campioni','Color','k');
% Impostazioni titolo e asse X comuni
title('Distribuzione dei picchi massimi di accelerazione (SVM non compensata)');
xlabel('Accelerazione [g]','Color','k');

hold on

% MEAN e STD DEV
mean_value_peak = mean(max_peak_vec);
std_dev_peak = std(max_peak_vec);

% THRESHOLD
th_accPeak = mean_value_peak - std_dev_peak;

% Creazione della seconda figura con la distribuzione gaussiana
x = linspace(0.2, 2.2, 100); % Intervallo dei valori su cui calcolare la gaussiana
gaussian = (1/(std_dev_peak * sqrt(2*pi))) * exp(-0.5 * ((x - mean_value_peak) / std_dev_peak).^2);

% Creazione di un secondo asse y per la densità di probabilità
yyaxis right
plot(x, gaussian, 'b-', 'LineWidth', 3,'DisplayName','Gaussian');
ylabel("Densit\`a di probabilit\`a",'Color','k');

% Aggiunta della linea di soglia
xline(th_accPeak, 'Color', '#D7263D', 'LineStyle', '--', ...
       'Label', 'Acceleration threshold', 'FontSize', 20, ...
       'LineWidth', 3, 'LabelVerticalAlignment', 'bottom','DisplayName','Max Acceleration Threshold' );

% Colore etichette assi (valori) nero
ax = gca;
ax.YAxis(1).Color = 'k'; % Asse y sinistro
ax.YAxis(2).Color = 'k'; % Asse y destro
legend;
grid on;


%% HISTOGRAM MIN VALLEYS
subplot(2,1,2);
h2 = histogram(min_valley_vec,'LineWidth',1.8,'FaceColor','#FFA500','DisplayName','Valley'); % Istogramma per il conteggio dei campioni #40E0D0 cyan
ylabel('Conteggio dei campioni','Color','k');
% Impostazioni titolo e asse X comuni
title('Distribuzione delle valli minime di accelerazione (SVM non compensata)');
xlabel('Accelerazione [g]','Color','k');

hold on

% MEAN e STD DEV
mean_value_valley = mean(min_valley_vec);
std_dev_valley = std(min_valley_vec);

% THRESHOLD
th_accValley = mean_value_valley + std_dev_valley;

% Creazione della seconda figura con la distribuzione gaussiana
x = linspace(0.2, 1.4, 100); % Intervallo dei valori su cui calcolare la gaussiana
gaussian = (1/(std_dev_valley * sqrt(2*pi))) * exp(-0.5 * ((x - mean_value_valley) / std_dev_valley).^2);

% Creazione di un secondo asse y per la densità di probabilità
yyaxis right
plot(x, gaussian, 'b-', 'LineWidth', 3, 'DisplayName','Gaussian');
ylabel("Densit\`a di probabilit\`a",'Color','k');

% Aggiunta della linea di soglia
xline(th_accValley, 'Color', '#D7263D', 'LineStyle', '--', ...
       'Label', 'Acceleration threshold', 'FontSize', 20, ...
       'LineWidth', 3, 'LabelVerticalAlignment', 'bottom','DisplayName','Min Acc Threshold');

% Colore etichette assi (valori) nero
ax = gca;
ax.YAxis(1).Color = 'k'; % Asse y sinistro
ax.YAxis(2).Color = 'k'; % Asse y destro
legend;
grid on;

%% PERCENTILI MAX
% utili per definire una soglia che sia robusta ad outlier e
% rappresentativa della distribuzione dei dati.

% Esempio:
% 95° Percentile: significa che solo il 5% dei picchi supererà questa soglia 
% Utile per rilevare eventi rari come le cadute.

% 5° Percentile: significa che il 95% dei picchi sarà sopra questa soglia. 
% Utile per rilevare eventi che sono molto meno intensi rispetto ai picchi normali.

% Calcolo dei percentili
percentili = prctile(max_peak_vec, [0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100]);

% Creazione del grafico a barre
figure("Name",'Percentili','NumberTitle','off');
subplot(2,1,1);
bar([0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100], percentili);
title('Percentili dei picchi massimi');
xlabel('Percentile');
ylabel('Accelerazione [g]');

%% PERCENTILI MIN
% utili per definire una soglia che sia robusta ad outlier e
% rappresentativa della distribuzione dei dati.

% Esempio:
% 95° Percentile: significa che solo il 5% dei picchi supererà questa soglia 
% Utile per rilevare eventi rari come le cadute.

% 5° Percentile: significa che il 95% dei picchi sarà sopra questa soglia. 
% Utile per rilevare eventi che sono molto meno intensi rispetto ai picchi normali.

% Calcolo dei percentili
percentili = prctile(min_valley_vec, [0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100]);

% Creazione del grafico a barre
subplot(2,1,2);
bar([0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100], percentili);
title('Percentili delle valli minime');
xlabel('Percentile');
ylabel('Accelerazione [g]');


min_prctile = 5;
max_prctile = 95;

str1 = sprintf("%d-Percentile Valore massimo: %.4f" ,max_prctile, prctile(max_peak_vec,max_prctile));
disp(str1);

str2 = sprintf("%d-Percentile Valore Minimi: %.4f",min_prctile , prctile(min_valley_vec,min_prctile));
disp(str2);


%% HISTOGRAM SMA
figure("Name",'SMA','NumberTitle','off');
subplot(2,1,1);
histogram(BA_SMA_vec);
title('Istogramma della SMA compensata');
xlabel('SMA [g]');
ylabel('Samples');
fprintf("MEAN SMA: %.3f\n", mean(BA_SMA_vec));
fprintf("MAX SMA: %.3f\n", max(BA_SMA_vec));
fprintf("MIN SMA: %.3f\n", min(BA_SMA_vec));

% PERCENTILI
percentili = prctile(BA_SMA_vec, [0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100]);


% Creazione del grafico a barre
subplot(2,1,2);
bar([0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100], percentili);
title('Percentili di SMA compensata');
xlabel('Percentile');
ylabel('SMA [g]');
