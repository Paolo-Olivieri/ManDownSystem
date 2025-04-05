%% DESCRIZIONE SCRIPT
% Questo script viene realizzato per provare ad identificare il Transition
% Time, ovvero il tempo intermedio della tranzisione da inizio caduta e
% l'impatto vero e proprio. Il TT viene poi utilizzato per identificare due
% regioni temporali su cui valutare la variazione di pressione, al fine di
% poter confermare un'ipotetico evento di caduta

%% SETUP
clear;
close all;
clc;
set(0,'DefaultLineLineWidth', 1.5);
set(0,'defaultAxesFontSize', 20);
set(0,'DefaultFigureWindowStyle', 'docked'); 
set(0,'defaulttextInterpreter','latex');
rng('default');

%% INIT
% Dataset di test
folderPath = '/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/Test/Fall&Rest';
csvName = 'fall&rest11.csv';
% Percorso completo del file
csvPath = fullfile(folderPath, csvName); % fullfile per costruire il percorso

% Dati dal file CSV
data = readtable(csvPath); % Leggo il CSV usando il percorso completo

accMagnitude = data.AccMagnitude;
pressure = data.Pressure;
timestamp = data.Timestamp_Matlab;



%% Definizione soglie (ora sono semplicemente di test) per identificare i
% minimi (valli), i quali potrebbero indicare una fase di discesa, ed i
% massimi (picchi), i quali indicano un impatto

valley_threshold = 0.8;
peak_threshold = 1.6;

valleysIndex = find(accMagnitude < valley_threshold);
peaksIndex = find(accMagnitude > peak_threshold);

[minValley, minValleyIndex] = min(accMagnitude(valleysIndex));
[maxPeak, maxPeakIndex]  = max(accMagnitude(peaksIndex));

% Per trovare il timestamp della valle
minValleyIndex = valleysIndex(minValleyIndex);
time_minValley = timestamp(minValleyIndex);

% Per trovare il timestamp del picco
maxPeakIndex = peaksIndex(maxPeakIndex);
time_maxPeak = timestamp(maxPeakIndex);

%Tempo di caduta
fall_duration = time_maxPeak - time_minValley;
str = sprintf("Fall Duration: %.3f s",fall_duration);
disp(str);

% TT timestamp
TT_time = (time_maxPeak + time_minValley)/2;

%% Definizione delle regioni temporali

%Pre-transition regione
preTransition_start = TT_time-10;
preTransition_end = TT_time-3;

%Post-transition regione
postTransition_start = TT_time+3;
postTransition_end = TT_time+10;

%% VARIAZIONE DI PRESSIONE
% Calcolo della variazione di pressione tra le due regioni come
% delta_pressure = median(pressure in post_region) - median(pressure in pre_region)

preTransition_pressure = pressure(timestamp >= preTransition_start & timestamp <= preTransition_end);
postTransition_pressure = pressure(timestamp >= postTransition_start & timestamp <= postTransition_end);

% Calcolare la mediana della pressione nelle due regioni
meanPressure_preTransition = mean(preTransition_pressure);
meanPressure_postTransition = mean(postTransition_pressure);

delta_pressure = meanPressure_postTransition - meanPressure_preTransition % [hPa]

% Variazione di altitudine corrispondente
% Si consideri il tasso di variazione standard di 12hPa/100m

delta_std_altitude = 0.12; %[0.12hPa/m]

delta_altitude = delta_pressure/delta_std_altitude; %[m]

str = sprintf("Delta Altitude: %.3f m",delta_altitude);
disp(str);


%% PLOT
figure;
subplot(2,1,1);
plot(timestamp, accMagnitude, 'b', 'DisplayName', 'Original Data');
hold on;
plot(time_maxPeak, maxPeak, 'ko', 'MarkerFaceColor', 'g', 'MarkerSize', 10,'LineWidth',1.2);
plot(time_minValley, minValley, 'ko', 'MarkerFaceColor', 'g', 'MarkerSize', 10,'LineWidth',1.2);
xline(TT_time,'Color', 'k', 'LineStyle', '--','LabelVerticalAlignment','bottom', ...
    'LabelOrientation','horizontal','Label','TT','FontSize',20,'LabelColor','k','LineWidth',2,'Alpha',1);

% Regioni
fill([preTransition_start preTransition_start preTransition_end preTransition_end], ...
     [(min(accMagnitude)-0.5) (max(accMagnitude)+0.5) (max(accMagnitude)+0.5) (min(accMagnitude)-0.5)], ...
     'g', 'FaceAlpha', 0.3, 'EdgeColor', 'k', 'DisplayName', 'Pre-Transition Region: [TT-10, TT-3]');
 
fill([postTransition_start postTransition_start postTransition_end postTransition_end], ...
     [(min(accMagnitude)-0.5) (max(accMagnitude)+0.5) (max(accMagnitude)+0.5) (min(accMagnitude)-0.5)], ...
     'g', 'FaceAlpha', 0.3, 'EdgeColor', 'k', 'DisplayName', 'Post-Transition Region: [TT+3, TT+10]');

text((preTransition_start + preTransition_end) / 2, max(accMagnitude) - 0.5, ...
     'Pre-Transition Region', 'Color', 'k', 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');

text((postTransition_start + postTransition_end) / 2, max(accMagnitude) - 0.5, ...
     'Post-Transition Region', 'Color', 'k', 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');


xlabel('Timestamp [s]');
ylabel('Acceleration Magnitude [g]');
title('Original Acceleration Magnitude');
legend('Original Data', 'Max Peak', 'Min Valley', 'TT', 'Location', 'best');

% % Zoom
% zoom_area = [(time_minValley - 0.5),  (time_maxPeak + 0.5)];
% axes_zoom = axes('Position',[0.6 0.6 0.2 0.3]); % posizione e dimensione del riquadro
% box on;
% plot(timestamp, accMagnitude, 'b');
% hold on;
% plot(timestamp, accMagnitude, 'r', 'LineWidth', 1.2);
% plot(time_maxPeak, maxPeak, 'ko', 'MarkerFaceColor', 'g', 'MarkerSize', 10, 'LineWidth', 1.2);
% plot(time_minValley, minValley, 'ko', 'MarkerFaceColor', 'g', 'MarkerSize', 10, 'LineWidth', 1.2);
% xline(TT_time,'Color', 'k', 'LineStyle', '--','LabelVerticalAlignment','bottom', ...
%     'LabelOrientation','horizontal','Label','TT','FontSize',20,'LabelColor','k','LineWidth',3,'Alpha',1);
% xlim(zoom_area);
% set(axes_zoom, 'xtick', [], 'ytick', []);
% hold off;


subplot(2,1,2);
plot(timestamp, pressure, 'b', 'DisplayName', 'Original Data');
hold on;

% Regioni
fill([preTransition_start preTransition_start preTransition_end preTransition_end], ...
     [(min(pressure)-0.05) (max(pressure)+0.05) (max(pressure)+0.05) (min(pressure)-0.05)], ...
     'g', 'FaceAlpha', 0.3, 'EdgeColor', 'k', 'DisplayName', 'Pre-Transition Region: [TT-10, TT-3]');
 
fill([postTransition_start postTransition_start postTransition_end postTransition_end], ...
     [(min(pressure)- 0.05) (max(pressure)+0.05) (max(pressure) + 0.05) (min(pressure)-0.05)], ...
     'g', 'FaceAlpha', 0.3, 'EdgeColor', 'k', 'DisplayName', 'Post-Transition Region: [TT+3, TT+10]');

text((preTransition_start + preTransition_end) / 2, max(pressure) - 0.05, ...
     'Pre-Transition Region', 'Color', 'k', 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');

text((postTransition_start + postTransition_end) / 2, max(pressure) - 0.05, ...
     'Post-Transition Region', 'Color', 'k', 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');

xlabel('Timestamp [s]');
ylabel('Pressure [hPa]');
legend;
title('Original Pressure');
hold off;


