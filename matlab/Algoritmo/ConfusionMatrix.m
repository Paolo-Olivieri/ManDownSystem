%% INIT
clc;
clear;
close all;
set(0,'DefaultLineLineWidth', 1.5);
set(0,'defaultAxesFontSize', 40);
set(0,'DefaultFigureWindowStyle', 'docked'); 
set(0,'defaulttextInterpreter','latex');
set(groot, 'defaultAxesTickLabelInterpreter','latex');  
set(groot, 'defaultLegendInterpreter','latex');
rng('default');

load('/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/Training/prctile.mat');

%% DESCRIZIONE METRICHE
% ACCURACY: Indica la proporzione di casi corretti (positivi e negativi)
% sul totale. (TP+TN)/(TP+TN+FP+FN)

% PRECISION (o Positive Predictive Value - PPV): Indica la proporzione di
% veri positivi tra tutti i risultati che il sistema ha classificato come
% positivi. TP/(TP+FP)

% RECALL (o Sensitivity o True Positive Rate - TPR): Indica la proporzione
% di veri positivi tra tutti i casi che erano effettivamente positivi.
% TP/(TP+FN)

% SPECIFICITY (o True Negative Rate - TNR): Indica la proporzione di veri
% negativi tra tutti i casi realmente negativi. TN/(TN+FP)

% F1-SCORE: L'F1-Score è definito come la media armonica tra precision e
% recall 
% F1-Score alto: Significa che il sistema ha sia una buona precision
% (pochi FP) sia un buon recall (pochi FN). 
% F1-Score basso: Indica che il sistema è debole in almeno una delle due
% metriche, o in entrambe. 
% 2 * (precision .* recall) ./ (precision + recall);

% FUNZIONE LOSS: è uno strumento matematico che serve a valutare le
% prestazioni di un sistema o modello mettendo più peso sugli errori
% considerati maggiormente critici rispetto ad altri. Nel caso del sistema di fall
% detection, i FN (allarme erroneamente non generato) sono MOLTO PIU'
% CRITICI rispetto ai FP (allarme erroneamente generato), quindi è bene
% trattarli in modo diverso. Questo avviene assegnando un peso maggiore
% agli errori più gravi, in questo caso ai FN.
% loss = alfa * FN + beta * FP

%% NOT FALL
dataBendOver = load('/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/Test/BendOver/ConfusionMatrix/matrixBendOver.mat');
dataCrouch = load('/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/Test/Crouch/ConfusionMatrix/matrixCrouch.mat');
dataSit= load('/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/Test/Sit/ConfusionMatrix/matrixSit.mat');
dataStairs= load('/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/Test/Stairs/ConfusionMatrix/matrixStairs.mat');
dataStrambling = load('/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/Test/Strambling/ConfusionMatrix/matrixStrambling.mat');
dataWalk = load('/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/Test/Walk/ConfusionMatrix/matrixWalk.mat');
dataElevator = load('/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/Test/Elevator/ConfusionMatrix/matrixElevator.mat');


TP_matrix_BendOver = dataBendOver.TP_matrix;
FP_matrix_BendOver = dataBendOver.FP_matrix;
FN_matrix_BendOver = dataBendOver.FN_matrix;
TN_matrix_BendOver = dataBendOver.TN_matrix;

TP_matrix_Crouch = dataCrouch.TP_matrix;
FP_matrix_Crouch = dataCrouch.FP_matrix;
FN_matrix_Crouch = dataCrouch.FN_matrix;
TN_matrix_Crouch = dataCrouch.TN_matrix;

TP_matrix_Sit = dataSit.TP_matrix;
FP_matrix_Sit = dataSit.FP_matrix;
FN_matrix_Sit = dataSit.FN_matrix;
TN_matrix_Sit = dataSit.TN_matrix;

TP_matrix_Stairs = dataStairs.TP_matrix;
FP_matrix_Stairs = dataStairs.FP_matrix;
FN_matrix_Stairs = dataStairs.FN_matrix;
TN_matrix_Stairs = dataStairs.TN_matrix;

TP_matrix_Strambling = dataStrambling.TP_matrix;
FP_matrix_Strambling = dataStrambling.FP_matrix;
FN_matrix_Strambling = dataStrambling.FN_matrix;
TN_matrix_Strambling = dataStrambling.TN_matrix;

TP_matrix_Walk = dataWalk.TP_matrix;
FP_matrix_Walk = dataWalk.FP_matrix;
FN_matrix_Walk = dataWalk.FN_matrix;
TN_matrix_Walk = dataWalk.TN_matrix;

TP_matrix_Elevator = dataElevator.TP_matrix;
FP_matrix_Elevator = dataElevator.FP_matrix;
FN_matrix_Elevator = dataElevator.FN_matrix;
TN_matrix_Elevator = dataElevator.TN_matrix;



TP_matrixNotFall_total = TP_matrix_BendOver + TP_matrix_Crouch + TP_matrix_Sit + TP_matrix_Stairs + TP_matrix_Strambling + TP_matrix_Walk + TP_matrix_Elevator;
FP_matrixNotFall_total = FP_matrix_BendOver + FP_matrix_Crouch + FP_matrix_Sit + FP_matrix_Stairs + FP_matrix_Strambling + FP_matrix_Walk + FP_matrix_Elevator;
FN_matrixNotFall_total = FN_matrix_BendOver + FN_matrix_Crouch + FN_matrix_Sit + FN_matrix_Stairs + FN_matrix_Strambling + FN_matrix_Walk + FN_matrix_Elevator;
TN_matrixNotFall_total = TN_matrix_BendOver + TN_matrix_Crouch + TN_matrix_Sit + TN_matrix_Stairs + TN_matrix_Strambling + TN_matrix_Walk + TN_matrix_Elevator;

NotFall_total = TP_matrixNotFall_total+FP_matrixNotFall_total+FN_matrixNotFall_total+TN_matrixNotFall_total;

% Plot NOT FALL

fig1 = figure('Name','Not Fall');
title('Matrice di Confusione per eventi di Non Caduta');
subplot(2, 2, 1);
% h1 = heatmap(prctile_peak_vec, prctile_valley_vec, round(TP_matrixNotFall_total ./ 120 * 100,2), 'Colormap', sky);
% %h1.ColorLimits = [0 120];
% xlabel('Soglia di Picco [g]');
% ylabel('Soglia di Valle [g]');
% title('True Positive (TP) [%]');
h1 = heatmap(prctile_peak_vec, prctile_valley_vec, round(TP_matrixNotFall_total ./ NotFall_total * 100,2), 'Colormap', sky);
h1.FontSize = 25;
h1.Interpreter = "latex";
h1.XLabel = 'Soglia di Picco [g]';
h1.YLabel = 'Soglia di Valle [g]';
h1.Title = '\textbf{True Positive (TP)[\%]}';

% Ripeti lo stesso per gli altri heatmap (h2, h3, h4)

subplot(2, 2, 2);
h3 = heatmap(prctile_peak_vec, prctile_valley_vec, round(FN_matrixNotFall_total ./ NotFall_total * 100,2), 'Colormap', sky);
%h3.ColorLimits = [0 120];
% xlabel('Soglia di Picco [g]');
% ylabel('Soglia di Valle [g]');
% title('False Negative (FN) [%]');
h3.FontSize = 25;
h3.Interpreter = "latex";
h3.XLabel = 'Soglia di Picco [g]';
h3.YLabel = 'Soglia di Valle [g]';
h3.Title = '\textbf{False Negative (FN)[\%]}';

subplot(2, 2, 3);
h2 = heatmap(prctile_peak_vec, prctile_valley_vec, round(FP_matrixNotFall_total ./ NotFall_total * 100,2), 'Colormap', sky);
%h2.ColorLimits = [0 120];
% xlabel('Soglia di Picco [g]');
% ylabel('Soglia di Valle [g]');
% title('False Positive (FP) [%]');
h2.FontSize = 25;
h2.Interpreter = "latex";
h2.XLabel = 'Soglia di Picco [g]';
h2.YLabel = 'Soglia di Valle [g]';
h2.Title = '\textbf{False Positive (FP)[\%]}';


subplot(2, 2, 4);
h4 = heatmap(prctile_peak_vec, prctile_valley_vec, round(TN_matrixNotFall_total ./ NotFall_total * 100,2), 'Colormap', sky);
% %h4.ColorLimits = [0 120];
% xlabel('Soglia di Picco [g]');
% ylabel('Soglia di Valle [g]');
% title('True Negative (TN) [%]');
h4.FontSize = 25;
h4.Interpreter = "latex";
h4.XLabel = 'Soglia di Picco [g]';
h4.YLabel = 'Soglia di Valle [g]';
h4.Title = '\textbf{True Negative (TN)[\%]}';


format = "%.3g";
h1.CellLabelFormat = format;
h2.CellLabelFormat = format;
h3.CellLabelFormat = format;
h4.CellLabelFormat = format;

exportgraphics(gcf, '/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/ImgTesi/04-Algoritmo/Metrics/NotFall_Confusion_percentage.pdf', 'Resolution', 300)


% Not Fall metrics
accuracy_matrix_NF = (TP_matrixNotFall_total + TN_matrixNotFall_total) ./ (TP_matrixNotFall_total + FP_matrixNotFall_total + FN_matrixNotFall_total + TN_matrixNotFall_total);
precision_matrix_NF = (TP_matrixNotFall_total) ./ (TP_matrixNotFall_total + FP_matrixNotFall_total);
recall_matrix_NF = (TP_matrixNotFall_total) ./ (TP_matrixNotFall_total + FN_matrixNotFall_total);
specificity_matrix_NF = TN_matrixNotFall_total ./ (TN_matrixNotFall_total + FP_matrixNotFall_total);
f1score_matrix_NF = 2 * (precision_matrix_NF .* recall_matrix_NF) ./ (precision_matrix_NF + recall_matrix_NF);

fig2 = figure('Name','Not Fall Metrics');

%subplot(2, 3, 1);
h5 = heatmap(prctile_peak_vec, prctile_valley_vec, accuracy_matrix_NF.*100, 'Colormap', sky, 'CellLabelFormat','%.2f');
% xlabel('Soglia di Picco [g]');
% ylabel('Soglia di Valle [g]');
% title('Not Falls - Accuracy [%]');
h5.FontSize = 40;
h5.Interpreter = "latex";
h5.XLabel = 'Soglia di Picco [g]';
h5.YLabel = 'Soglia di Valle [g]';
h5.Title = '\textbf{Non caduta - Accuratezza [\%]}';

format = "%.3g";
h5.CellLabelFormat = format;


%export_fig 'fig2' '/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/Algoritmo/Metrics_Img/NotFall_Accuracy_percentage' '-pdf' '-transparent';
exportgraphics(gcf, '/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/ImgTesi/04-Algoritmo/Metrics/NotFall_Accuracy_percentage.pdf', 'Resolution', 300)




% subplot(2, 3, 2); heatmap(prctile_peak_vec, prctile_valley_vec,
% precision_matrix_NF, 'Colormap', sky, 'CellLabelFormat','%.2f');
% xlabel('Soglia di Picco [g]'); ylabel('Soglia di Valle [g]');
% title('Precision Matrix');
%
% subplot(2, 3, 5); heatmap(prctile_peak_vec, prctile_valley_vec,
% recall_matrix_NF, 'Colormap', sky, 'CellLabelFormat','%.2f');
% xlabel('Soglia di Picco [g]'); ylabel('Soglia di Valle [g]');
% title('Recall/Sensitivity (TPR) Matrix');
%
% subplot(2, 3, 4); heatmap(prctile_peak_vec, prctile_valley_vec,
% specificity_matrix_NF, 'Colormap', sky, 'CellLabelFormat','%.2f');
% xlabel('Soglia di Picco [g]'); ylabel('Soglia di Valle [g]');
% title('Specificity Matrix (TNR)');
%
% subplot(2, 3, [3,6]); heatmap(prctile_peak_vec, prctile_valley_vec,
% f1score_matrix_NF, 'Colormap', sky, 'CellLabelFormat','%.2f');
% xlabel('Soglia di Picco [g]'); ylabel('Soglia di Valle [g]');
% title('F1-Score Matrix');


%% FALL
dataVerticalFall = load('/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/Test/VerticalFall/ConfusionMatrix/matrixVerticalFall.mat');
dataFallRest = load('/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/Test/Fall&Rest/ConfusionMatrix/matrixFall&Rest.mat');
dataFallRecovery = load('/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/Test/Fall&Recovery/ConfusionMatrix/matrixFall&Recovery.mat');
dataLateralFall = load('/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/Test/LateralFall/ConfusionMatrix/matrixLateralFall.mat');
dataBackwardFall = load('/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/Test/BackwardFall/ConfusionMatrix/matrixBackwardFall.mat');

TP_matrix_VF = dataVerticalFall.TP_matrix;
FP_matrix_VF = dataVerticalFall.FP_matrix;
FN_matrix_VF = dataVerticalFall.FN_matrix;
TN_matrix_VF = dataVerticalFall.TN_matrix;

TP_matrix_FRest = dataFallRest.TP_matrix;
FP_matrix_FRest = dataFallRest.FP_matrix;
FN_matrix_FRest = dataFallRest.FN_matrix;
TN_matrix_FRest = dataFallRest.TN_matrix;

TP_matrix_FRecovery = dataFallRecovery.TP_matrix;
FP_matrix_FRecovery = dataFallRecovery.FP_matrix;
FN_matrix_FRecovery = dataFallRecovery.FN_matrix;
TN_matrix_FRecovery = dataFallRecovery.TN_matrix;

TP_matrix_LateralFall = dataLateralFall.TP_matrix;
FP_matrix_LateralFall = dataLateralFall.FP_matrix;
FN_matrix_LateralFall = dataLateralFall.FN_matrix;
TN_matrix_LateralFall = dataLateralFall.TN_matrix;

TP_matrix_BackwardFall = dataBackwardFall.TP_matrix;
FP_matrix_BackwardFall = dataBackwardFall.FP_matrix;
FN_matrix_BackwardFall = dataBackwardFall.FN_matrix;
TN_matrix_BackwardFall = dataBackwardFall.TN_matrix;


TP_matrixFall_total = TP_matrix_VF + TP_matrix_FRest + TP_matrix_FRecovery + TP_matrix_LateralFall + TP_matrix_BackwardFall;
FP_matrixFall_total = FP_matrix_VF + FP_matrix_FRest + FP_matrix_FRecovery + FP_matrix_LateralFall + FP_matrix_BackwardFall;
FN_matrixFall_total = FN_matrix_VF + FN_matrix_FRest + FN_matrix_FRecovery + FN_matrix_LateralFall + FN_matrix_BackwardFall;
TN_matrixFall_total = TN_matrix_VF + TN_matrix_FRest + TN_matrix_FRecovery + TN_matrix_LateralFall + TN_matrix_BackwardFall;

fall_total = TP_matrixFall_total + FP_matrixFall_total + FN_matrixFall_total + TN_matrixFall_total;

fig3 = figure('Name','Fall');
subplot(2, 2, 1);
h1 = heatmap(prctile_peak_vec, prctile_valley_vec, round(TP_matrixFall_total ./ fall_total * 100,2) , 'Colormap', sky);
% %h1.ColorLimits = [0 40];
% xlabel('Soglia di Picco [g]');
% ylabel('Soglia di Valle [g]');
% title('True Positive (TP) [%]');
h1.FontSize = 25;
h1.Interpreter = "latex";
h1.XLabel = 'Soglia di Picco [g]';
h1.YLabel = 'Soglia di Valle [g]';
h1.Title = '\textbf{True Positive (TP)[\%]}';

subplot(2, 2, 2);
h2 = heatmap(prctile_peak_vec, prctile_valley_vec, round(FP_matrixFall_total ./ fall_total * 100,2) , 'Colormap', sky);
%h2.ColorLimits = [0 60];
% xlabel('Soglia di Picco [g]');
% ylabel('Soglia di Valle [g]');
% title('False Positive (FP) [%]');
h2.FontSize = 25;
h2.Interpreter = "latex";
h2.XLabel = 'Soglia di Picco [g]';
h2.YLabel = 'Soglia di Valle [g]';
h2.Title = '\textbf{False Positive (FP)[\%]}';

subplot(2, 2, 3);
h3 = heatmap(prctile_peak_vec, prctile_valley_vec, round(FN_matrixFall_total ./ fall_total * 100,2) , 'Colormap', sky);
%h3.ColorLimits = [0 40];
% xlabel('Soglia di Picco [g]');
% ylabel('Soglia di Valle [g]');
% title('False Negative (FN) [%]');
h3.FontSize = 25;
h3.Interpreter = "latex";
h3.XLabel = 'Soglia di Picco [g]';
h3.YLabel = 'Soglia di Valle [g]';
h3.Title = '\textbf{False Negative (FN)[\%]}';


subplot(2, 2, 4);
h4 = heatmap(prctile_peak_vec, prctile_valley_vec, round(TN_matrixFall_total ./ fall_total * 100,2), 'Colormap', sky);
%h4.ColorLimits = [0 60];
% xlabel('Soglia di Picco [g]');
% ylabel('Soglia di Valle [g]');
% title('True Negative (TN) [%]');
h4.FontSize = 25;
h4.Interpreter = "latex";
h4.XLabel = 'Soglia di Picco [g]';
h4.YLabel = 'Soglia di Valle [g]';
h4.Title = '\textbf{True Negative (TN)[\%]}';

%sgtitle('Falls Confusion Matrix');
format = "%.3g";
h1.CellLabelFormat = format;
h2.CellLabelFormat = format;
h3.CellLabelFormat = format;
h4.CellLabelFormat = format;

exportgraphics(gcf, '/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/ImgTesi/04-Algoritmo/Metrics/Fall_Confusion_percentage.pdf', 'Resolution', 300)


%  Fall metrics
accuracy_matrix_F = (TP_matrixFall_total + TN_matrixFall_total) ./ (TP_matrixFall_total + FP_matrixFall_total + FN_matrixFall_total + TN_matrixFall_total);
precision_matrix_F = (TP_matrixFall_total) ./ (TP_matrixFall_total + FP_matrixFall_total);
recall_matrix_F = (TP_matrixFall_total) ./ (TP_matrixFall_total + FN_matrixFall_total);
specificity_matrix_F = TN_matrixFall_total ./ (TN_matrixFall_total + FP_matrixFall_total);
f1score_matrix_F = 2 * (precision_matrix_F .* recall_matrix_F) ./ (precision_matrix_F + recall_matrix_F);

fig4 = figure('Name','Fall Metrics');

%subplot(2, 3, 1);
h5 = heatmap(prctile_peak_vec, prctile_valley_vec, accuracy_matrix_F.*100, 'Colormap', sky, 'CellLabelFormat','%.2f');
% xlabel('Soglia di Picco [g]');
% ylabel('Soglia di Valle [g]');
% title('Fall - Accuracy [%]');
h5.FontSize = 40;
h5.Interpreter = "latex";
h5.XLabel = 'Soglia di Picco [g]';
h5.YLabel = 'Soglia di Valle [g]';
h5.Title = '\textbf{Caduta - Accuratezza [\%]}';

h5.CellLabelFormat = format;



%export_fig 'fig4' '/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/Algoritmo/Metrics_Img/Fall_Accuracy_percentage' '-pdf' '-transparent';
exportgraphics(gcf, '/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/ImgTesi/04-Algoritmo/Metrics/Fall_Accuracy_percentage.pdf', 'Resolution', 300)



% subplot(2, 3, 2); heatmap(prctile_peak_vec, prctile_valley_vec,
% precision_matrix_F, 'Colormap', sky, 'CellLabelFormat','%.2f');
% xlabel('Soglia di Picco [g]'); ylabel('Soglia di Valle [g]');
% title('Precision Matrix');
%
% subplot(2, 3, 5); heatmap(prctile_peak_vec, prctile_valley_vec,
% recall_matrix_F, 'Colormap', sky, 'CellLabelFormat','%.2f'); xlabel('Peak
% Threshold [g]'); ylabel('Soglia di Valle [g]');
% title('Recall/Sensitivity (TPR) Matrix');
%
% subplot(2, 3, 4); heatmap(prctile_peak_vec, prctile_valley_vec,
% specificity_matrix_F, 'Colormap', sky, 'CellLabelFormat','%.2f');
% xlabel('Soglia di Picco [g]'); ylabel('Soglia di Valle [g]');
% title('Specificity Matrix (TNR)');
%
% subplot(2, 3, [3,6]); heatmap(prctile_peak_vec, prctile_valley_vec,
% f1score_matrix_F, 'Colormap', sky, 'CellLabelFormat','%.2f');
% xlabel('Soglia di Picco [g]'); ylabel('Soglia di Valle [g]');
% title('F1-Score Matrix');




%% TOTAL
% 
TP_matrix_total = TP_matrixFall_total + TP_matrixNotFall_total;
FP_matrix_total = FP_matrixFall_total + FP_matrixNotFall_total;
FN_matrix_total = FN_matrixFall_total + FN_matrixNotFall_total;
TN_matrix_total = TN_matrixFall_total + TN_matrixNotFall_total;
% 
% 
% total = TP_matrix_total + FP_matrix_total + FN_matrix_total + TN_matrix_total;
% fig5 = figure('Name','Total');
% 
% subplot(2, 2, 1);
% heatmap(prctile_peak_vec, prctile_valley_vec, round(TP_matrix_total ./ total * 100,2) , 'Colormap', sky);
% %h1.ColorLimits = [0 180];
% xlabel('Soglia di Picco [g]');
% ylabel('Soglia di Valle [g]');
% title('True Positive (TP) [%]');
% 
% 
% subplot(2, 2, 2);
% heatmap(prctile_peak_vec, prctile_valley_vec, round(FP_matrix_total ./ total * 100,2) , 'Colormap', sky);
% %h2.ColorLimits = [0 180];
% xlabel('Soglia di Picco [g]');
% ylabel('Soglia di Valle [g]');
% title('False Positive (FP) [%]');
% 
% subplot(2, 2, 3);
% heatmap(prctile_peak_vec, prctile_valley_vec, round(FN_matrix_total ./ total * 100,2) , 'Colormap', sky);
% %h3.ColorLimits = [0 180];
% xlabel('Soglia di Picco [g]');
% ylabel('Soglia di Valle [g]');
% title('False Negative (FN) [%]');
% 
% subplot(2, 2, 4);
% heatmap(prctile_peak_vec, prctile_valley_vec, round(TN_matrix_total ./ total * 100,2) , 'Colormap', sky);
% % h4.ColorLimits = [0 180];
% xlabel('Soglia di Picco [g]');
% ylabel('Soglia di Valle [g]');
% title('True Negative (TN) [%]');
% 
% %sgtitle('Total Confusion Matrix');
% %export_fig 'fig5' '/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/Algoritmo/Metrics_Img/All_ConfusionMatrix_percentage' '-pdf' '-transparent';
% exportgraphics(gcf, '/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/ImgTesi/04-Algoritmo/Metrics/All_ConfusionMatrix_percentage.pdf', 'Resolution', 300)

%% METRICHE

accuracy_matrix = ((TP_matrix_total + TN_matrix_total) ./ (TP_matrix_total + FP_matrix_total + FN_matrix_total + TN_matrix_total)) * 100;
precision_matrix = ((TP_matrix_total) ./ (TP_matrix_total + FP_matrix_total)) * 100;
recall_matrix = ((TP_matrix_total) ./ (TP_matrix_total + FN_matrix_total)) * 100;
specificity_matrix = (TN_matrix_total ./ (TN_matrix_total + FP_matrix_total)) * 100;
f1score_matrix = (2 * (precision_matrix .* recall_matrix) ./ (precision_matrix + recall_matrix));

% LOSS
alfa = 5;
beta = 1;
loss_matrix = (alfa .* FN_matrix_total) + (beta .* FP_matrix_total);

fig6 = figure('Name','Metrics');

subplot(2, 3, 1);
h1 = heatmap(prctile_peak_vec, prctile_valley_vec, accuracy_matrix, 'Colormap', sky);
% xlabel('Soglia di Picco [g]');
% ylabel('Soglia di Valle [g]');
% title('Accuracy [\%]');
h1.FontSize = 20;
h1.Interpreter = "latex";
h1.XLabel = 'Soglia di Picco [g]';
h1.YLabel = 'Soglia di Valle [g]';
h1.Title = '\textbf{Accuratezza [\%]}';


subplot(2, 3, 2);
h2 = heatmap(prctile_peak_vec, prctile_valley_vec, precision_matrix, 'Colormap', sky);
% xlabel('Soglia di Picco [g]');
% ylabel('Soglia di Valle [g]');
% title('Precision [%]');
h2.FontSize = 20;
h2.Interpreter = "latex";
h2.XLabel = 'Soglia di Picco [g]';
h2.YLabel = 'Soglia di Valle [g]';
h2.Title = '\textbf{Precisione [\%]}';

subplot(2, 3, 5);
h3 = heatmap(prctile_peak_vec, prctile_valley_vec, recall_matrix, 'Colormap', sky);
% xlabel('Soglia di Picco [g]');
% ylabel('Soglia di Valle [g]');
% title('Recall/Sensitivity (TPR) [%]');
h3.FontSize = 20;
h3.Interpreter = "latex";
h3.XLabel = 'Soglia di Picco [g]';
h3.YLabel = 'Soglia di Valle [g]';
h3.Title = '\textbf{Sensibilit\`a (TPR) [\%]}';

subplot(2, 3, 4);
h4 = heatmap(prctile_peak_vec, prctile_valley_vec, specificity_matrix, 'Colormap', sky);
% xlabel('Soglia di Picco [g]');
% ylabel('Soglia di Valle [g]');
% title('Specificity (TNR) [%]');
h4.FontSize = 20;
h4.Interpreter = "latex";
h4.XLabel = 'Soglia di Picco [g]';
h4.YLabel = 'Soglia di Valle [g]';
h4.Title = '\textbf{Specificit\`a (TNR) [\%]}';

subplot(2, 3, 3);
h5 = heatmap(prctile_peak_vec, prctile_valley_vec, f1score_matrix, 'Colormap', sky);
% xlabel('Soglia di Picco [g]');
% ylabel('Soglia di Valle [g]');
% title('F1-Score [%]');
h5.FontSize = 20;
h5.Interpreter = "latex";
h5.XLabel = 'Soglia di Picco [g]';
h5.YLabel = 'Soglia di Valle [g]';
h5.Title = '\textbf{F1-Score [\%]}';


subplot(2, 3, 6);
h6 = heatmap(prctile_peak_vec, prctile_valley_vec, loss_matrix, 'Colormap', sky);
% xlabel('Soglia di Picco [g]');
% ylabel('Soglia di Valle [g]');
% title('Loss Function');
%sgtitle('Metrics Matrix');
h6.FontSize = 20;
h6.Interpreter = "latex";
h6.XLabel = 'Soglia di Picco [g]';
h6.YLabel = 'Soglia di Valle [g]';
h6.Title = '\textbf{Loss Function}';


format = "%.3g";
h1.CellLabelFormat = format;
h2.CellLabelFormat = format;
h3.CellLabelFormat = format;
h4.CellLabelFormat = format;
h5.CellLabelFormat = format;
h6.CellLabelFormat = format;



%export_fig 'fig6' '/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/Algoritmo/Metrics_Img/All_metrics_percentage' '-pdf' '-transparent';
exportgraphics(gcf, '/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/ImgTesi/04-Algoritmo/Metrics/All_metrics.pdf', 'Resolution', 300)











