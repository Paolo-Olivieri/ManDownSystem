%% Script dedicato all'analisi dei consumi della scheda in fase operativa

%% SETUP
clc;
clear;
close all;
set(0,'DefaultLineLineWidth', 1.5);
set(0,'defaultAxesFontSize', 30);
set(0,'DefaultFigureWindowStyle', 'docked'); 
set(0,'defaulttextInterpreter','latex');
set(groot, 'defaultAxesTickLabelInterpreter','latex');  
set(groot, 'defaultLegendInterpreter','latex');
rng('default');

%% Lettura dati 

%% ATTESA BLE
bleDatas = readtable("/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/powerConsumption/data/waitingBLE.csv");
bleDatas.Properties.VariableNames{'Var1'} = 'Timestamp';
bleDatas.Properties.VariableNames{'Var2'} = 'Current';

bleDatas(bleDatas.Timestamp > 30000, :) = [];

% Creazione grafico
fig1 = figure();
%plot(bleDatas.Timestamp/1000, bleDatas.Current/1000,"Color","b");
plot(bleDatas.Timestamp/1000, bleDatas.Current/1000, 'DisplayName', 'Corrente','Color','b');
xlabel('Tempo [s]');
ylabel('Corrente [mA]', 'Interpreter', 'latex');
meanValue = mean(bleDatas.Current)/1000;

% Traccia la linea della media
yline(meanValue, "Color", "r", "LineWidth", 3, "DisplayName", "Media");

% Aggiungere etichetta con sfondo bianco
text(2, meanValue, [' Media = ' num2str(meanValue, '%.2f') ' mA'], ...
    'VerticalAlignment', 'middle', ...  % Cambiato da 'middle' a 'bottom'
    'HorizontalAlignment', 'left', ...
    'Color', 'k', ...
    'FontSize', 25, ...
    'BackgroundColor', 'white', ...
    'EdgeColor', 'k', ...
    'Margin', 1, 'Layer', 'front');

% Traccia la linea del valore massimo
maxValue = max(bleDatas.Current)/1000;
yline(maxValue, "Color", [0,0.7,0], "LineStyle", "-.", "LineWidth", 3, "DisplayName", "Massimo");

% Aggiungere etichetta con sfondo bianco
text(2, maxValue, [' Massimo = ' num2str(maxValue, '%.2f') ' mA'], ...
    'VerticalAlignment', 'middle', ...  % Cambiato da 'middle' a 'bottom'
    'HorizontalAlignment', 'left', ...
    'Color', 'k', ...
    'FontSize', 25, ...
    'BackgroundColor', 'white', ...
    'EdgeColor', 'k', ...
    'Margin', 1, 'Layer', 'front');

% Traccia la linea del valore minimo
minValue = min(bleDatas.Current)/1000;
yline(minValue, "Color", [1,0.67,0], "LineStyle","-.", "LineWidth", 3, "DisplayName", "Minimo");

% Aggiungere etichetta con sfondo bianco
text(2, minValue, [' Minimo = ' num2str(minValue, '%.2f') ' mA'], ...
    'VerticalAlignment', 'middle', ...  % Cambiato da 'middle' a 'bottom'
    'HorizontalAlignment', 'left', ...
    'Color', 'k', ...
    'FontSize', 25, ...
    'BackgroundColor', 'white', ...
    'EdgeColor', 'k', ...
    'Margin', 1, 'Layer', 'front');

legend("Interpreter","latex");


grid on;
%exportgraphics(gcf, '/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/ImgTesi/ConsumiBatteria/waitingBle_CurrentAnalysis.pdf', 'Resolution', 300)

%% ADL
adlDatas = readtable("/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/powerConsumption/data/adlOnlyAccBaro.csv");
adlDatas.Properties.VariableNames{'Var1'} = 'Timestamp';
adlDatas.Properties.VariableNames{'Var2'} = 'Current';


adlDatas(adlDatas.Timestamp < 60000 | adlDatas.Timestamp > 90000, :) = [];

% Creazione grafico
fig2 = figure();
plot(adlDatas.Timestamp/1000 - 60, adlDatas.Current/1000, 'DisplayName', 'Corrente','Color','b');
xlabel('Tempo [s]');
ylabel('Corrente [mA]', 'Interpreter', 'latex');
ylim([5,13]);
% Calcolare la media della corrente
meanValue = mean(adlDatas.Current)/1000;

% Traccia la linea della media
yline(meanValue, "Color", "r", "LineWidth", 3, "DisplayName", "Media");

% Aggiungere etichetta con sfondo bianco
text(2, meanValue, [' Media = ' num2str(meanValue, '%.2f') ' mA'], ...
    'VerticalAlignment', 'middle', ...  % Cambiato da 'middle' a 'bottom'
    'HorizontalAlignment', 'left', ...
    'Color', 'k', ...
    'FontSize', 25, ...
    'BackgroundColor', 'white', ...
    'EdgeColor', 'k', ...
    'Margin', 1, 'Layer', 'front');

% Traccia la linea del valore massimo
maxValue = max(adlDatas.Current)/1000;
%yline(maxValue, "Color", [0,0.7,0], "LineStyle", "-.", "LineWidth", 3, "DisplayName", "Massimo");
yline(maxValue, "Color", [0,0.7,0], "LineStyle", "-.", "LineWidth", 3, "DisplayName", "Massimo");

% Aggiungere etichetta con sfondo bianco
text(2, maxValue, [' Massimo = ' num2str(maxValue, '%.2f') ' mA'], ...
    'VerticalAlignment', 'middle', ...  % Cambiato da 'middle' a 'bottom'
    'HorizontalAlignment', 'left', ...
    'Color', 'k', ...
    'FontSize', 25, ...
    'BackgroundColor', 'white', ...
    'EdgeColor', 'k', ...
    'Margin', 1, 'Layer', 'front');

% Traccia la linea del valore minimo
minValue = min(adlDatas.Current)/1000;
yline(minValue, "Color", [1,0.67,0], "LineStyle","-.", "LineWidth", 3, "DisplayName", "Minimo");

% Aggiungere etichetta con sfondo bianco
text(2, minValue, [' Minimo = ' num2str(minValue, '%.2f') ' mA'], ...
    'VerticalAlignment', 'middle', ...  % Cambiato da 'middle' a 'bottom'
    'HorizontalAlignment', 'left', ...
    'Color', 'k', ...
    'FontSize', 25, ...
    'BackgroundColor', 'white', ...
    'EdgeColor', 'k', ...
    'Margin', 1, 'Layer', 'front');
legend;

grid on;
%exportgraphics(gcf, '/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/ImgTesi/ConsumiBatteria/connectedBle_CurrentAnalysis.pdf', 'Resolution', 300)

%% FALL
falldatas = readtable("/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/powerConsumption/data/fall.csv");
falldatas.Properties.VariableNames{'Var1'} = 'Timestamp';
falldatas.Properties.VariableNames{'Var2'} = 'Current';

falldatas(falldatas.Timestamp < 40000 | falldatas.Timestamp > 75000, :) = [];

% Creazione grafico
fig3 = figure();
plot(falldatas.Timestamp/1000 - 40 , falldatas.Current/1000, 'DisplayName', 'Corrente','Color','b');
xlabel('Tempo [s]');
ylabel('Corrente [mA]', 'Interpreter', 'latex');
meanValue = mean(falldatas.Current)/1000;

% Traccia la linea della media
yline(meanValue, "Color", "r", "LineWidth", 3, "DisplayName", "Media");

% Aggiungere etichetta con sfondo bianco
text(2, meanValue, [' Media = ' num2str(meanValue, '%.2f') ' mA'], ...
    'VerticalAlignment', 'middle', ...  % Cambiato da 'middle' a 'bottom'
    'HorizontalAlignment', 'left', ...
    'Color', 'k', ...
    'FontSize', 25, ...
    'BackgroundColor', 'white', ...
    'EdgeColor', 'k', ...
    'Margin', 1, 'Layer', 'front');


% Traccia la linea del valore massimo
maxValue = max(falldatas.Current)/1000;
yline(maxValue, "Color", [0,0.7,0], "LineStyle", "-.", "LineWidth", 3, "DisplayName", "Massimo");

% Aggiungere etichetta con sfondo bianco
text(2, maxValue, [' Massimo = ' num2str(maxValue, '%.2f') ' mA'], ...
    'VerticalAlignment', 'middle', ...  % Cambiato da 'middle' a 'bottom'
    'HorizontalAlignment', 'left', ...
    'Color', 'k', ...
    'FontSize', 25, ...
    'BackgroundColor', 'white', ...
    'EdgeColor', 'k', ...
    'Margin', 1, 'Layer', 'front');

% Traccia la linea del valore minimo
minValue = min(falldatas.Current)/1000;
yline(minValue, "Color",  [1,0.67,0], "LineStyle","-.", "LineWidth", 3, "DisplayName", "Minimo");

% Aggiungere etichetta con sfondo bianco
text(2, minValue, [' Minimo = ' num2str(minValue, '%.2f') ' mA'], ...
    'VerticalAlignment', 'middle', ...  % Cambiato da 'middle' a 'bottom'
    'HorizontalAlignment', 'left', ...
    'Color', 'k', ...
    'FontSize', 25, ...
    'BackgroundColor', 'white', ...
    'EdgeColor', 'k', ...
    'Margin', 1, 'Layer', 'front');
legend;
grid on;


%exportgraphics(gcf, '/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/ImgTesi/ConsumiBatteria/postFall_CurrentAnalysis.pdf', 'Resolution', 300)

%% 5 minute test
testDatas = readtable("/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/powerConsumption/data/5MinuteTest.csv");
testDatas.Properties.VariableNames{'Var1'} = 'Timestamp';
testDatas.Properties.VariableNames{'Var2'} = 'Current';

testDatas(testDatas.Timestamp > 300000, :) = [];
testDatas(testDatas.Timestamp == 168450, :) = [];
testDatas(testDatas.Current == 0, :) = [];
% Creazione grafico
fig4 = figure();
plot(testDatas.Timestamp/1000 , testDatas.Current/1000, 'DisplayName', 'Corrente','Color','b',"LineWidth",0.5);
xlabel('Tempo [s]');
ylabel('Corrente [mA]', 'Interpreter', 'latex');
meanValue = mean(testDatas.Current)/1000;

% Traccia la linea della media
yline(meanValue, "Color", "r", "LineWidth", 3, "DisplayName", "Media");

% Aggiungere etichetta con sfondo bianco
text(2, meanValue, [' Media = ' num2str(meanValue, '%.2f') ' mA'], ...
    'VerticalAlignment', 'middle', ...  % Cambiato da 'middle' a 'bottom'
    'HorizontalAlignment', 'left', ...
    'Color', 'k', ...
    'FontSize', 25, ...
    'BackgroundColor', 'white', ...
    'EdgeColor', 'k', ...
    'Margin', 1, 'Layer', 'front');


% Traccia la linea del valore massimo
maxValue = max(testDatas.Current)/1000;
yline(maxValue, "Color", [0,0.7,0], "LineStyle", "-.", "LineWidth", 3, "DisplayName", "Massimo");

% Aggiungere etichetta con sfondo bianco
text(2, maxValue, [' Massimo = ' num2str(maxValue, '%.2f') ' mA'], ...
    'VerticalAlignment', 'middle', ...  % Cambiato da 'middle' a 'bottom'
    'HorizontalAlignment', 'left', ...
    'Color', 'k', ...
    'FontSize', 25, ...
    'BackgroundColor', 'white', ...
    'EdgeColor', 'k', ...
    'Margin', 1, 'Layer', 'front');

% Traccia la linea del valore minimo
minValue = min(testDatas.Current)/1000;
yline(minValue, "Color",  [1,0.67,0], "LineStyle","-.", "LineWidth", 3, "DisplayName", "Minimo");

% Aggiungere etichetta con sfondo bianco
text(2, minValue, [' Minimo = ' num2str(minValue, '%.2f') ' mA'], ...
    'VerticalAlignment', 'middle', ...  % Cambiato da 'middle' a 'bottom'
    'HorizontalAlignment', 'left', ...
    'Color', 'k', ...
    'FontSize', 25, ...
    'BackgroundColor', 'white', ...
    'EdgeColor', 'k', ...
    'Margin', 1, 'Layer', 'front');
legend;
grid on;

%exportgraphics(gcf, '/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/ImgTesi/ConsumiBatteria/5MinuteTest_CurrentAnalysis.pdf', 'Resolution', 500)
