clc;
clear;
close all;
set(0,'DefaultLineLineWidth', 1.5);
set(0,'defaultAxesFontSize', 20);
set(0,'DefaultFigureWindowStyle', 'docked'); 
set(0,'defaulttextInterpreter','latex');
set(groot, 'defaultAxesTickLabelInterpreter','latex');  
set(groot, 'defaultLegendInterpreter','latex');
rng('default');

folderPath = '/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/Test/Fall&Recovery';
% csvName = 'fall17.csv';
csvName = 'fall&recovery12.csv';

% Percorso completo del file
csvPath = fullfile(folderPath, csvName); % fullfile per costruire il percorso

% Dati dal file CSV
data = readtable(csvPath); % Leggo il CSV usando il percorso completo

acc = data.AccMagnitude;
pressure = data.Pressure;
time = data.Timestamp_Matlab;
ax = data.AccX;
ay = data.AccY;
az = data.AccZ;


% filtered_pressure = butterworthFilter(pressure,time,2,1);
% 
% %%
% 
% g_x = mean(ax);
% g_y = mean(ay);
% g_z = mean(az);
% 
% gravity_vector = [g_x, g_y, g_z];
% 
% % Ora, per ogni campione successivo, sottrai la componente gravitazionale
% acc_no_gravity_x = ax - g_x;
% acc_no_gravity_y = ay - g_y;
% acc_no_gravity_z = az - g_z;
% 
% figure;
% plot(time,acc_no_gravity_x);
% hold on;
% plot(time,acc_no_gravity_y);
% plot(time,acc_no_gravity_z);
% legend;
% 
% %%
% % Parametri del filtro passa-alto
% fs = 1/mean(diff(time)); % Frequenza di campionamento in Hz (adatta il valore in base ai tuoi dati)
% cutoff_frequency = 0.4; % Frequenza di taglio in Hz per rimuovere la gravità (tipicamente  0.3-0.5 Hz sono sufficienti)
% 
% % Creazione del filtro passa-alto
% [b, a] = butter(1, cutoff_frequency / (fs / 2), 'high');
% 
% % Applica il filtro alle componenti x, y e z
% ax_BA = filtfilt(b, a, ax); % Body Acceleration su asse x
% ay_BA = filtfilt(b, a, ay); % Body Acceleration su asse y
% az_BA = filtfilt(b, a, az); % Body Acceleration su asse z
% 
% BA_SVM = sqrt(ax_BA.^2 + ay_BA.^2 + az_BA.^2);
% BA_SVM_test = abs(acc - 1);
% 
% 
% 
% 
% %% SMA
% % Parametri
% window_duration = 0.5; % durata della finestra in secondi
% 
% % Calcola il numero di campioni per una finestra di 1 secondo
% sampling_interval = mean(diff(time)); % intervallo di campionamento medio
% samples_per_window = round(window_duration / sampling_interval); % campioni per finestra
% 
% % Numero totale di finestre di 1 secondo
% num_windows = floor(length(time) / samples_per_window);
% 
% % Inizializzo un array per conservare i valori SMA
% sma_values = zeros(num_windows, 1);
% sma_valuess_filter = zeros(num_windows, 1);
% sma_values_test = zeros(num_windows, 1);
% 
% % Calcolo della SMA per ciascuna finestra
% for w = 1:num_windows
%     % Indici di inizio e fine della finestra corrente
%     start_idx = (w - 1) * samples_per_window + 1;
%     end_idx = w * samples_per_window;
% 
%     % Estrai i dati della finestra corrente
%     ax_window = ax_BA(start_idx:end_idx);
%     ay_window = ay_BA(start_idx:end_idx);
%     az_window = az_BA(start_idx:end_idx);
% 
%     % Calcola la SMA per la finestra corrente
%     sma_values(w) = mean(abs(ax_window) + abs(ay_window) + abs(az_window));
%     sma_values_filter(w) = mean(BA_SVM(start_idx:end_idx));
%     sma_values_test(w) = mean(BA_SVM_test(start_idx:end_idx));
% end
% 
% % Array dei tempi per ogni finestra (centro della finestra)
% window_times = (0:num_windows - 1) * window_duration + window_duration / 2;
% 
% 
% %% PLOT
% figure;
% subplot(3,1,1);
% plot(time, acc, 'b', 'DisplayName', 'SVM');
% hold on;
% plot(time, BA_SVM, 'r', 'DisplayName', 'SVM_{BA filtered}','LineWidth',1.2);
% plot(time, BA_SVM_test, 'DisplayName', 'SVM_{BA}','LineWidth',1.2);
% % plot(time, ax, 'DisplayName', 'ax','LineWidth',1.2);
% % plot(time, ay, 'DisplayName', 'ay','LineWidth',1.2);
% % plot(time, az, 'DisplayName', 'az','LineWidth',1.2);
% ylabel('Acceleration')
% legend;
% 
% subplot(3,1,2)
% plot(time, BA_SVM, 'DisplayName', 'SVM_{BA}','LineWidth',1.2);
% hold on;
% plot(time, BA_SVM_test, 'DisplayName', 'SVM_{BA}_{TEST}','LineWidth',1.2);
% stem(window_times, sma_values, 'filled','DisplayName','SMA_{BA}'); % 'filled' per evidenziare i punti
% stem(window_times, sma_values_filter, 'filled','DisplayName','SMA_{BA} test1'); % 'filled' per evidenziare i punti
% stem(window_times, sma_values_test, 'filled','DisplayName','SMA_{BA} test2'); % 'filled' per evidenziare i punti
% 
% ylabel('Acceleration')
% legend;
% 
% subplot(3,1,3);
% plot(time, pressure, 'b', 'DisplayName', 'Original Pressure Data');
% hold on;
% plot(time, filtered_pressure, 'r', 'DisplayName', 'Filtered Pressure Data','LineWidth',1.2);
% ylabel('Pressure')
% xlabel('Time')
% legend;
% 
% 
% figure;
% plot(time, acc, 'b', 'DisplayName', 'SVM');
% hold on;
% plot(time, BA_SVM, 'r', 'DisplayName', 'SVM_{BA filtered}','LineWidth',1.2);
% plot(time, BA_SVM_test, 'DisplayName', 'SVM_{BA}','LineWidth',1.2);
% ylabel('Timestamp [s]')
% ylabel('Acceleration [g]')
% legend;
% 
% 
% %%
% fprintf("Varianza SVM non comepnsata: %.2f",var(acc))


%%
fig1 = figure();
subplot(2,1,1);
plot(time, acc, 'DisplayName', 'SVM','Color','b');
xlabel('Timestamp [s]')
ylabel('Acceleration [g]')
yline(1.8,'r-.','Peak threshold','LabelHorizontalAlignment','left','FontSize',14,'DisplayName','Peak Threshold','LineWidth',2)
yline(0.6,'g-.','Valley threshold','LabelHorizontalAlignment','left','LabelVerticalAlignment','bottom','FontSize',14,'DisplayName','Valley Threshold','LineWidth',2)
legend;

subplot(2,1,2);
plot(time, pressure, 'b','DisplayName', 'Pressure');
xlabel('Timestamp [s]')
ylabel('Pressure [hPa]')
legend;

fig2 = figure();
plot(time, acc, 'DisplayName', 'SVM','Color','b');
xlabel('Timestamp [s]')
ylabel('Acceleration [g]')
xlim([5 18]);

export_fig 'fig1' '/Users/paolo/Desktop/ProgettoTesi/Presentazioni/Algorithm' '-pdf' '-transparent';
export_fig 'fig2' '/Users/paolo/Desktop/ProgettoTesi/Presentazioni/AlgorithmRegion' '-pdf' '-transparent';