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

%% % Dati della tabella
% Dati della tabella
categorie = {...
    'Colpito da oggetto in movimento', ...
    'Scivolamenti/inciampi', 'Cadute dall''alto', ...
    'Atti di violenza', 'Movimentazione/trasporto'};

valori = [10,31,8,9,17];

% Creazione del grafico a barre orizzontali
figure;
barh(valori, 'b'); % Barre orizzontali blu
set(gca, 'YTickLabel', categorie, 'YTick', 1:length(categorie));
xlabel('Percentuale [\%]');
grid on;

%exportgraphics(gcf, '/Users/paolo/Downloads/infortuni.pdf', 'Resolution', 300)

%%
% Dati della tabella
% Dati della tabella
categorie = {...
    'Colpito da oggetto in movimento', ...
    'Scivolamenti/inciampi', 'Cadute dall''alto', ...
    'Atti di violenza', 'Movimentazione/trasporto'};

valori = [10,31,8,9,17];

% Creazione del grafico a torta
figure;
h = pie(valori, '%.0f%%'); % Pie chart con le categorie

for i = 1:length(h)
    if ishandle(h(i)) && strcmp(get(h(i), 'Type'), 'text') % Verifica se l'oggetto è un testo
        % Cambia la dimensione del testo
        set(h(i), 'FontSize', 25, 'Interpreter','latex'); % Imposta la dimensione a 14 (modifica come preferisci)
    end
end


legend(categorie, "Location", "eastoutside", "Orientation", "vertical");


% Esportazione del grafico
exportgraphics(gcf, '/Users/paolo/Downloads/infortuni_torta.pdf', 'Resolution', 300);
