%% INIT
clear;
close all;
set(0,'DefaultLineLineWidth', 1.5);
set(0,'defaultAxesFontSize', 20);
set(0,'DefaultFigureWindowStyle', 'docked'); 
set(0,'defaulttextInterpreter','latex');
rng('default');

%% SETUP
% In questo script sono stati considerati i dati di Pressione
% relativi ai test "GetUp", in cui il soggetto si alza da terra al fine di
% poter rilevare le variazioni di pressione da terra

% Percorso della cartella contenente i file CSV di 'Fall&Rest'
folderPath = '/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/Test/GetUp';

figure;
hold on;

delta_pressure_vec = [];

mean_pressure_upper_vec = [];
mean_pressure_bottom_vec = [];



% Ciclo per caricare dati GetUp
for i = 1:10

    % Nome del file CSV
    csvName = sprintf('getUp%d.csv', i);
    
    % Percorso completo del file
    csvPath = fullfile(folderPath, csvName); % fullfile per costruire il percorso
    
    % Dati dal file CSV
    data = readtable(csvPath); % Leggo il CSV usando il percorso completo
    
    pressure = data.Pressure;
    timestamps = data.Timestamp_Matlab;


    % 3 secondi di dati
    num_samples = round(3 / mean(diff(timestamps)));
    mean_pressure_upper = mean(pressure(1:num_samples));
    mean_pressure_bottom = mean(pressure(end-num_samples:end));

    mean_pressure_upper_vec = [mean_pressure_upper_vec,mean_pressure_upper];
    mean_pressure_bottom_vec = [mean_pressure_bottom_vec,mean_pressure_bottom];
    
    delta_pressure = abs(mean_pressure_bottom - mean_pressure_upper);
    delta_pressure_vec = [delta_pressure_vec,delta_pressure];


    plot(timestamps, pressure, 'LineWidth', 1);
end



delta_pressure_mean = mean(delta_pressure_vec);
% Personalizzazione del grafico
xlabel('Timestamp');
ylabel('Pressure');

yline(mean(mean_pressure_upper_vec),'Label','Upper Pressure','FontSize',16, ...
    'LineWidth', 3,  'Color','r','LineStyle',':','LabelVerticalAlignment','middle');

yline(mean(mean_pressure_bottom_vec),'Label','Bottom Pressure','FontSize',16, ...
    'LineWidth', 3, 'Color','r','LineStyle',':','LabelVerticalAlignment','middle');

title('Sovrapposizione pressioni e visualizzazioni medie');
grid on;
hold off;


%% PRCTILE
prctile5 = prctile(delta_pressure_vec,5)