%% INIT
clc;
clear;
close all;
set(0,'DefaultLineLineWidth', 1.5);
set(0,'defaultAxesFontSize', 40);
set(0,'DefaultFigureWindowStyle', "docked"); 
set(0,'defaulttextInterpreter','latex');
set(groot, 'defaultAxesTickLabelInterpreter','latex');  
set(groot, 'defaultLegendInterpreter','latex');
rng('default');


%% SETUP
% In questo script sono stati considerati i dati di "Acceleration Magnitude"
% relativi ai test 'Fall&Rest' e 'Fall&Recovery', in modo da avere 40 set
% di dati per trovare una migliore soglia.

max_peak_vec = [];
min_valley_vec = [];

acceleration_data = [];



%% FRONT FALL
% Percorso della cartella contenente i file CSV di 'Fall&Rest'
folderPath = '/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/Training/Fall4Threshold';

for i = 1:50
    % Nome del file CSV
    csvName = sprintf('fall%d.csv', i);

    % Percorso completo del file
    csvPath = fullfile(folderPath, csvName); % fullfile per costruire il percorso

    % Dati dal file CSV
    data = readtable(csvPath); % Leggo il CSV usando il percorso completo

    accMagnitude = data.AccMagnitude;
    ax = data.AccX;
    ay = data.AccY;
    az = data.AccZ;
    timestamps = data.Timestamp_Matlab;

    % SVM
    acceleration_data = [acceleration_data; accMagnitude];
    [max_peak, max_peak_index] = max(accMagnitude);
    max_peak_vec = [max_peak_vec, max_peak];

    [min_valley, min_valley_index] = min(accMagnitude(1:max_peak_index));
    min_valley_vec = [min_valley_vec, min_valley];

    

    % Trova il picco massimo e il corrispondente timestamp

    max_peak_time = timestamps(max_peak_index);
    min_valley_time = timestamps(min_valley_index);

end

%% Vertical Fall
folderPath = '/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/Training/VerticalFall';

for i = 1:50
    % Nome del file CSV
    csvName = sprintf('verticalFall%d.csv', i);

    % Percorso completo del file
    csvPath = fullfile(folderPath, csvName); % fullfile per costruire il percorso

    % Dati dal file CSV
    data = readtable(csvPath); % Leggo il CSV usando il percorso completo

    accMagnitude = data.AccMagnitude;
    ax = data.AccX;
    ay = data.AccY;
    az = data.AccZ;
    timestamps = data.Timestamp_Matlab;

    % SVM
    acceleration_data = [acceleration_data; accMagnitude];
    [max_peak, max_peak_index] = max(accMagnitude);
    max_peak_vec = [max_peak_vec, max_peak];

    [min_valley, min_valley_index] = min(accMagnitude(1:max_peak_index));
    min_valley_vec = [min_valley_vec, min_valley];

    

    % Trova il picco massimo e il corrispondente timestamp

    max_peak_time = timestamps(max_peak_index);
    min_valley_time = timestamps(min_valley_index);

end
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
x = linspace(0, 8, 100); % Intervallo dei valori su cui calcolare la gaussiana
gaussian = (1/(std_dev_peak * sqrt(2*pi))) * exp(-0.5 * ((x - mean_value_peak) / std_dev_peak).^2);

% Creazione di un secondo asse y per la densità di probabilità
yyaxis right
plot(x, gaussian, 'b-', 'LineWidth', 3,'DisplayName','Gaussian');
ylabel("Densit\`a di probabilit\`a",'Color','k');

% Aggiunta della linea di soglia
xline(th_accPeak, 'Color', '#D7263D', 'LineStyle', '--', ...
    'Label', 'Acceleration threshold', 'FontSize', 20, ...
    'LineWidth', 3, 'LabelVerticalAlignment', 'bottom','DisplayName','Max Acceleration Threshold' );

xline(mean_value_peak, 'LineStyle', '--', ...
    'Label', 'Mean', 'FontSize', 20, ...
    'LineWidth', 3, 'LabelVerticalAlignment', 'bottom','DisplayName','Mean Acceleration');

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
x = linspace(0, 1, 100); % Intervallo dei valori su cui calcolare la gaussiana
gaussian = (1/(std_dev_valley * sqrt(2*pi))) * exp(-0.5 * ((x - mean_value_valley) / std_dev_valley).^2);

% Creazione di un secondo asse y per la densità di probabilità
yyaxis right
plot(x, gaussian, 'b-', 'LineWidth', 3, 'DisplayName','Gaussian');
ylabel("Densit\`a di probabilit\`a",'Color','k');

% Aggiunta della linea di soglia
xline(th_accValley, 'Color', '#D7263D', 'LineStyle', '--', ...
    'Label', 'Acceleration threshold', 'FontSize', 20, ...
    'LineWidth', 3, 'LabelVerticalAlignment', 'bottom','DisplayName','Min Acc Threshold');

xline(mean_value_valley, 'LineStyle', '--', ...
    'Label', 'Mean', 'FontSize', 20, ...
    'LineWidth', 3, 'LabelVerticalAlignment', 'bottom','DisplayName','Mean Acceleration');
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
prctile_peak_vec = prctile(max_peak_vec, [1 2 3 4 5 6 7 8 9 10]);


% Creazione del grafico a barre
fig1 = figure();
b = bar([1 2 3 4 5 6 7 8 9 10], prctile_peak_vec);
b.FaceColor="blue";
%b.FaceAlpha = 0.8;
title('Percentili dei picchi massimi');
xlabel('Percentile');
ylabel('Accelerazione [g]');
grid on;

% Scrivere i valori sopra ogni barra
for i = 1:length(prctile_peak_vec)
    % Posizione del testo sopra la barra
    text(i, prctile_peak_vec(i), sprintf('%.4f', prctile_peak_vec(i)), ...
        'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center', 'FontSize', 28);
end

prctile_peak = 5;



disp("PEAKS PERCENTILE")
fprintf("(NON COMPENSATO) %d-Percentile Picco: %.4f\n\n",prctile_peak , prctile(max_peak_vec,prctile_peak));

export_fig 'fig1' '/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/ImgTesi/03-Percentili/prct_peak' -pdf '-transparent';

%print(gcf, '-dpdf', '/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/ImgTesi/03-Percentili/prct_peak.pdf'); 

%% PERCENTILI MIN
% utili per definire una soglia che sia robusta ad outlier e
% rappresentativa della distribuzione dei dati.

% Esempio:
% 95° Percentile: significa che solo il 5% dei picchi supererà questa soglia 
% Utile per rilevare eventi rari come le cadute.

% 5° Percentile: significa che il 95% dei picchi sarà sopra questa soglia. 
% Utile per rilevare eventi che sono molto meno intensi rispetto ai picchi normali.

% Calcolo dei percentili
prctile_valley_vec = prctile(min_valley_vec, [90 91 92 93 94 95 96 97 98 99]);


% Creazione del grafico a barre
fig2 = figure();
b = bar([90 91 92 93 94 95 96 97 98 99], prctile_valley_vec);
b.FaceColor=[84/255,196/255,94/255];
%b.FaceAlpha = 0.6;
title('Percentili delle valli minime');
xlabel('Percentile');
ylabel('Accelerazione [g]');
ylim([0,0.9])
grid on;

for i = 1:length(prctile_valley_vec)
    text(i+89, prctile_valley_vec(i), sprintf('%.4f', prctile_valley_vec(i)), ...
        'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center', 'FontSize', 28);
end


valley_prctile = 95;

disp("VALLEYS PERCENTILE")
fprintf("(NON COMPENSATO) %d-Percentile Valle: %.4f\n" ,valley_prctile, prctile(min_valley_vec,valley_prctile));

export_fig 'fig2' '/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/ImgTesi/03-Percentili/prct_valley' -pdf '-transparent';