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


accData = readtable("/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/Test/Stairs/stairs5.csv");
ax = accData.AccX;
ay = accData.AccY;
az = accData.AccZ;
svm = sqrt(ax.^2 + ay.^2 + az.^2);

timestamps = accData.Timestamp_Matlab;

pressure = accData.Pressure;

%%
fig1 = figure();
% Plot delle componenti AccX, AccY, AccZ
plot(timestamps, ax, 'r', 'LineWidth', 1); % AccX in rosso
hold on;
plot(timestamps, ay, 'g', 'LineWidth', 1); % AccY in verde
plot(timestamps, az, 'b', 'LineWidth', 1); % AccZ in blu

% Plot della SVM
plot(timestamps, svm, 'k', 'LineWidth', 2); % SVM in nero
xlim([0,5]);

% Aggiunta della legenda
legend('AccX', 'AccY', 'AccZ', 'SVM', 'Location', 'northeast');

% Aggiunta di etichette e titolo
xlabel('Tempo [s]');
ylabel('Accelerazione [g]');
grid on;

%export_fig 'fig1' '/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/ImgTesi/03-Percentili+Fasi/frontFall_Acc' -pdf '-transparent';
%exportgraphics(gcf, '/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/ImgTesi/03-Percentili+Fasi/frontFall_AccNew.pdf', 'Resolution', 300)

%%
fig2 = figure();
% Plot delle componenti AccX, AccY, AccZ
plot(timestamps, pressure, 'b', 'LineWidth', 2); % AccZ in blu

xlim([0,5]);
% Aggiunta della legenda
legend('Pressione', 'Location', 'northeast');

% Aggiunta di etichette e titolo
xlabel('Tempo [s]');
ylabel('Pressione [hPa]');
grid on;


%export_fig 'fig2' '/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/ImgTesi/03-Percentili+Fasi/frontFall_Pressure' -pdf '-transparent';
%exportgraphics(gcf, '/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/ImgTesi/03-Percentili+Fasi/frontFall_PressureNew.pdf', 'Resolution', 300)

%%
fig3 = figure();
plot(timestamps, svm, 'b', 'LineWidth', 2); 

xlim([1,3.5]);
ylim([0,5]);
% Aggiunta della legenda
legend('SVM', 'Location', 'northeast');

% Aggiunta di etichette e titolo
xlabel('Tempo [s]');
ylabel('Accelerazione [g]');
grid on;


%export_fig 'fig3' '/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/ImgTesi/03-Percentili+Fasi/frontFall_AccSVM' -pdf '-transparent';
%exportgraphics(gcf, '/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/ImgTesi/03-Percentili+Fasi/frontFall_AccSVMNew.pdf', 'Resolution', 300)

%%
valley_threshold = 0.76178;                                 %[g]
peak_threshold = 1.6489; 
fig4 = figure();

% Creazione del grafico con due assi y
yyaxis left;
plot(timestamps, svm, 'b', 'LineWidth', 2); 
hold on;
ylabel('Accelerazione [g]','Color',"b");
%yline(valley_threshold,'LineStyle','--','Color',[1, 0.5, 0],'LineWidth',2,'DisplayName','Soglia di Valle');
yline(valley_threshold,'LineStyle','--','Color',[1, 0.5, 0],'LineWidth',2);

% % Aggiungere etichetta con sfondo bianco
% text(16, valley_threshold, 'Soglia di Picco', ...
%     'VerticalAlignment', 'middle', ...  % Cambiato da 'middle' a 'bottom'
%     'HorizontalAlignment', 'left', ...
%     'Color', [1, 0.5, 0], ...
%     'FontSize', 30, ...
%     'BackgroundColor', 'white', ...
%     'EdgeColor', 'k', ...
%     'Margin', 1, 'Layer', 'front');


%yline(peak_threshold,'LineStyle','--','Color','r','LineWidth',2, 'DisplayName','Soglia di Picco');
yline(peak_threshold,'LineStyle','--','Color','r','LineWidth',2);

% % Aggiungere etichetta con sfondo bianco
% text(16, peak_threshold, 'Soglia di Valle', ...
%     'VerticalAlignment', 'middle', ...  % Cambiato da 'middle' a 'bottom'
%     'HorizontalAlignment', 'left', ...
%     'Color', 'r', ...
%     'FontSize', 30, ...
%     'BackgroundColor', 'white', ...
%     'EdgeColor', 'k', ...
%     'Margin', 1, 'Layer', 'front');


grid on;


yyaxis right;
plot(timestamps, pressure, 'r', 'LineWidth', 2); 
ylabel('Pressione [hPa]','Color',"r");

% Aggiunta delle etichette comuni
xlabel('Tempo [s]');
legend('SVM', "Soglia di Picco","Soglia di Valle",'Pressione', 'Location', 'northeast');
xlim([16,24]);

ax = gca; % Ottiene l'oggetto dell'asse corrente
ax.YAxis(1).Color = 'b'; % Colore asse Y sinistro
ax.YAxis(2).Color = 'r'; % Colore asse Y destro

% Salvataggio della figura
%export_fig 'fig5' '/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/ImgTesi/03-Percentili+Fasi/frontFall_AccPressure_Overlay' -pdf '-transparent';
exportgraphics(gcf, '/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/ImgTesi/03-Percentili+Fasi/frontFall_AccPressure_OverlayScale.pdf', 'Resolution', 300)

%%
% accData = readtable("/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/Training/VerticalFall/verticalFall40.csv");
% ax = accData.AccX;
% ay = accData.AccY;
% az = accData.AccZ;
% svm = sqrt(ax.^2 + ay.^2 + az.^2);
% 
% timestamps = accData.Timestamp_Matlab;
% 
% pressure = accData.Pressure;
% 
% fig4 = figure();
% % Plot delle componenti AccX, AccY, AccZ
% plot(timestamps, ax, 'r', 'LineWidth', 1); % AccX in rosso
% hold on;
% plot(timestamps, ay, 'g', 'LineWidth', 1); % AccY in verde
% plot(timestamps, az, 'b', 'LineWidth', 1); % AccZ in blu
% 
% % Plot della SVM
% plot(timestamps, svm, 'k', 'LineWidth', 2); % SVM in nero
% xlim([0,7]);
% % Aggiunta della legenda
% legend('AccX', 'AccY', 'AccZ', 'SVM', 'Location', 'northeast');
% 
% % Aggiunta di etichette e titolo
% xlabel('Tempo [s]');
% ylabel('Accelerazione [g]');
% grid on;
% 
% export_fig 'fig4' '/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/ImgTesi/03-Percentili+Fasi/verticalFall_Acc' -pdf '-transparent';
% 
% fig5 = figure();
% % Plot delle componenti AccX, AccY, AccZ
% plot(timestamps, pressure, 'b', 'LineWidth', 2); % AccZ in blu
% 
% xlim([0,7]);
% % Aggiunta della legenda
% legend('Pressione', 'Location', 'northeast');
% 
% % Aggiunta di etichette e titolo
% xlabel('Tempo [s]');
% ylabel('Pressione [hPa]');
% grid on;
% 
% 
% export_fig 'fig5' '/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/ImgTesi/03-Percentili+Fasi/verticalFall_pressure' -pdf '-transparent';