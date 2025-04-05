% Rispetto ad "Algoritmo 3"
% 
% Modifica dell'algoritmo tramite creazione di una FSM (Finite State
% Machine).

% Modifica relativa all'identificazione della variazione di pressione post
% caduta: invece di considerare la variazione tra la media di pressione negli ultimi 5 secondi
% della recovery area e la media di pressione nella PostTransition, è
% meglio identificare la variazione di pressione tra l'istante corrente e
% la media nella PostTransition. In questo modo, una volta identificato un
% "Recovery", l'algoritmo riparte da quello specifico istante, e non dopo
% l'intera recovery area

% Modifica della condizione di rilevamento di caduta tramite utilizzo della
% varianza var(acc(postTransition_start_index:postTransition_end_index)) <= th_var
% (e della variazione di pressione).
% Questo riduce anche il numero di falsi negativi: talvolta i valori di
% accelerazione possono eccedere dai limiti imposti dalle soglie th_still
% nell'area di postTransition a causa dell'assestamento dell'accelerometro.
% L'utilizzo della varianza migliora il tutto.

% VERSIONE 0.2

%% INIT
clc;
clear;
close all;
set(groot,'DefaultLineLineWidth', 1.5);
set(groot,'defaultAxesFontSize', 40);
set(groot,'DefaultFigureWindowStyle', 'docked'); 
set(groot,'defaulttextInterpreter','latex');
set(groot, 'defaultAxesTickLabelInterpreter','latex');  
set(groot, 'defaultLegendInterpreter','latex');
rng('default');

addpath '/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis'
load('/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/Training/prctile.mat');

%% LOAD DATA
%data = readtable("/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/Test/Stairs/stairs5.csv");
data = readtable("/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/Test/Fall&Recovery/fall&recovery12.csv");
%data = readtable("/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/Test/Fall&Rest/fall&rest5.csv");
%data = readtable("/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/Test/Crouch/crouch4.csv");
%data = readtable("/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/Test/VerticalFall/verticalFall11.csv");
%data = readtable("/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/Test/Appoggio/test5.csv");
%data = readtable("/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/Test/Strambling/strambling5.csv");

acc = data.AccMagnitude;
pressure = data.Pressure;
time = data.Timestamp_Matlab;


%% THRESHOLDS AND TIME INTERVALS
valley_threshold = 0.76178;                                 %[g]
peak_threshold = 1.6489;                                 %[g]
pressure_fall_threshold = 0.06;                         %[hPa]
%max_still_threshold = 1.1;                              %[g]
%min_still_threshold = 0.9 ;                             %[g]
pressure_getUp_threshold = pressure_fall_threshold;     %[hPa]
peak_window_time = 2;                                   %[s]
recovery_window_time = 60;                              %[s]
variance_threshold= 0.0015;                               %[g]

%% FSM Initialization
stato = 'Iniziale';
fall_alert = false;
fall_motionless = false;
fall_recovered = false;

i = 1;
while i <= length(acc)
    switch stato
        case 'Iniziale'
            % Step 1: Verifica se si presenta una valle (indice di possibile esistenza di picco)
            if acc(i) <= valley_threshold

                % FInestra temporale entro cui si cerca un picco (impatto)
                peak_window_end = min(i + round(peak_window_time / mean(diff(time))), length(acc));
                stato = 'Possibile Caduta';
            else
                i = i + 1;
            end

        case 'Possibile Caduta'
            % Step 2: Cerca picco massimo entro finestra di tempo
            if any(acc(i:peak_window_end) >= peak_threshold)

                [peak_value, peak_relative_index] = max(acc(i:peak_window_end));
                peak_index = peak_relative_index + i - 1;
                valley_indices = find(acc(i:peak_index) <= valley_threshold) + i - 1;

                % Estrazione della valle minima e individuazione delle
                % regioni pre-transition e post-transition
                if ~isempty(valley_indices)
                    [valley_value, min_valley_index] = min(acc(valley_indices));
                    valley_index = valley_indices(min_valley_index);

                    % Time picco e valle
                    time_peak = time(peak_index);
                    time_valley = time(valley_index);

                    % Time e indice TransitionTime
                    TT_time = (time_peak + time_valley)/2;
                    TT_index = round(peak_index + valley_index)/2;

                    % Pre-TT: regione precedente alla caduta
                    preTransition_start = max(TT_time-3,0);
                    preTransition_end = max(TT_time-1,0);
                    preTransition_start_index = max(round(TT_index - 3/mean(diff(time))),0);
                    preTransition_end_index = max(round(TT_index - 1/mean(diff(time))),0);

                    % Post-TT: regione successiva alla caduta
                    postTransition_start = min(TT_time+1,time(length(acc)));
                    postTransition_end = min(TT_time+3,time(length(acc)));
                    postTransition_start_index = min(round(TT_index + 1/mean(diff(time))),length(acc));
                    postTransition_end_index = min(round(TT_index + 3/mean(diff(time))),length(acc));

                    % Estrazione vettori di pressione nelle regioni
                    % preTransition_pressure = pressure(time >= preTransition_start & time <= preTransition_end);
                    % postTransition_pressure = pressure(time >= postTransition_start & time <= postTransition_end);
                    preTransition_pressure = pressure(time >= preTransition_start & time <= preTransition_end);
                    postTransition_pressure = pressure(time >= postTransition_start & time <= postTransition_end);

                    % Calcolo della media di pressione in ciascuna regione
                    meanPressure_preTransition = mean(preTransition_pressure);
                    meanPressure_postTransition = mean(postTransition_pressure);


                    % Calcolo di variazione di pressione tra le due regioni
                    delta_pressure_fall = meanPressure_postTransition - meanPressure_preTransition;


                    % Se il deltaPressione supera una soglia e
                    % l'accelerazione è compresa tra due soglie che
                    % indicano che il soggetto è fermo, allora viene
                    % confermata la caduta
                    if delta_pressure_fall >= pressure_fall_threshold && ...
                        var(acc(postTransition_start_index:postTransition_end_index)) <= variance_threshold
                        %(all(acc(postTransition_end_index:min(postTransition_end_index+round(1/mean(diff(time))),length(acc))) <= th_max_still) && ...
                        %all(acc(postTransition_end_index:min(postTransition_end_index+round(1/mean(diff(time))),length(acc))) >= th_min_still))
                        % (all(acc(postTransition_end_index - round(1/mean(diff(time))):min(postTransition_end_index+round(2/mean(diff(time))),length(acc))) <= th_max_still) && ...
                        %  all(acc(postTransition_end_index - round(1/mean(diff(time))):min(postTransition_end_index+round(2/mean(diff(time))),length(acc))) >= th_min_still))
                        

                        % Utile per i plot, in modo da visualizzare le
                        % regioni quando effettivamente vi è una caduta

                        preTransition_start_fall = preTransition_start;
                        preTransition_end_fall = preTransition_end;

                        postTransition_start_fall = postTransition_start;
                        postTransition_end_fall = postTransition_end;


                        meanPressure_postFall = meanPressure_postTransition;
                        meanPressure_preFall = meanPressure_preTransition;

                        impact_value = acc(peak_index);
                        impact_time = time(peak_index);

                        min_valley_value = acc(valley_index);
                        min_valley_time = time(valley_index);

                        % disp(meanPressure_preTransition )
                        % disp(meanPressure_postTransition )
                        % disp(delta_pressure_fall)

                        stato = 'Caduta Confermata';
                    else
                        stato = 'Iniziale';
                        i = i + 1;
                    end
                else
                    stato = 'Iniziale';
                    i = i + 1;
                end

            else
                stato = 'Iniziale';
                i = i + 1;
            end

        case 'Caduta Confermata'
            fprintf('A %.2f m fall was detected at %.2f sec with an Picco of %.2f g\n',(delta_pressure_fall/0.12), TT_time, impact_value);

            % Indice del termine della finestra di recovery
            recovery_window_end = min(postTransition_end_index + round(recovery_window_time / mean(diff(time))), length(acc));

            % Se almeno un'accelerazione eccede i limiti della soglia di
            % immobilità, allora il soggetto si è mosso o si muove
            %if any(acc(postTransition_end_index:recovery_window_end) >= max_still_threshold) || ...
                    %any(acc(postTransition_end_index:recovery_window_end) <= min_still_threshold)

                window_2sec = round(2/mean(diff(time)));  % Finestra di 2 secondi

                j = postTransition_end_index;

                while (j + window_2sec - 1 <= recovery_window_end && ~fall_recovered)
                    % Calcolare la media della pressione nella finestra di 2 secondi
                    pressure_mean_2sec = mean(pressure(j:j + window_2sec - 1));

                    % Calcolare la differenza di pressione per la finestra corrente
                    delta_pressure_recovery = meanPressure_postTransition - pressure_mean_2sec;

                    if (delta_pressure_recovery >= pressure_getUp_threshold)
                        % RECUPERO rilevato
                        fall_alert = false;
                        fall_motionless = false;
                        fall_recovered = true;
                        i = j + window_2sec - 1 ;
                        stato = 'Iniziale';
                        fprintf('Recovered from fall between %.2f sec and %.2f sec\n', time(j),time(j+window_2sec-1));
                        break;
                    end

                    % Avanza di un campione per scorrere la finestra
                    j = j + 1;
                end

                % Se non è stato rilevato nessun Monitoraggio tramite variazione di pressione
                if ~fall_recovered
                    fall_alert = true;
                    fall_motionless = false;
                    stato = 'Allerta';
                    fprintf('Fallen but still moving slightly\n');
                end

            % else
            %     fall_alert = true;
            %     fall_motionless = true;
            %     fprintf('Fallen and motionless\n');
            %     stato = 'Allerta';
            % end

        case 'Allerta'
            if fall_alert
                if fall_motionless
                    disp('FALL ALERT TRIGGERED: MOTIONLESS PERSON');
                    stato = 'Fine';
                else
                    disp('FALL ALERT TRIGGERED: MOVING PERSON');
                    stato = 'Fine';
                end
            end


        case 'Fine'
            disp('Assistance notified');
            break;

        otherwise
            stato = 'Iniziale';
            i = i + 1;
    end
end

if ~fall_alert
    disp('NO FALL ALERT TRIGGERED');
end

%% PLOT
% if(fall_recovered)
%     figure;
%      
%     plot(time, acc, 'b', 'DisplayName', 'Acceleration Magnitude');
%     hold on;
%     plot(impact_time, impact_value, 'ro','MarkerEdgeColor', 'r', 'MarkerFaceColor', 'none', 'MarkerSize', 15); % Triangolo rosso
%     yline(th_valley,'LineStyle','--','Color','k','LineWidth',1.5, ...
%         'Label','Soglia di Valle','LabelHorizontalAlignment','left','LabelVerticalAlignment','bottom','FontSize',14);
%     yline(th_peak,'LineStyle','--','Color','k','LineWidth',1.5, ...
%         'Label','Soglia di Picco','LabelHorizontalAlignment','left','LabelVerticalAlignment','top','FontSize',14);
%     yline(th_max_still,'LineStyle','--','Color','r','LineWidth',1.5, ...
%         'Label','Max Movement Threshold','LabelHorizontalAlignment','left','LabelVerticalAlignment','top','FontSize',14);
%     yline(th_min_still,'LineStyle','--','Color','r','LineWidth',1.5, ...
%         'Label','Min Movement Threshold','LabelHorizontalAlignment','left','LabelVerticalAlignment','top','FontSize',14);
%     xline(time(j),'LineStyle','--','Color','r','LineWidth',1.5, ...
%         'Label','Fall Recovery Time','LabelHorizontalAlignment','left','LabelVerticalAlignment','top','FontSize',14);
%
%     % xline(postTransition_start);
%     % xline(postTransition_end);
%     % xline(preTransition_start);
%     % xline(preTransition_end);
%
%     hold off;
%
%     subplot(2,1,2);
%     plot(time, pressure, 'b', 'DisplayName', 'Pressione');
%     hold on;
%     plot(time, filt_pressure, 'r', 'DisplayName', 'Pressione');
%     xline(time(j),'LineStyle','--','Color','r','LineWidth',1.5, ...
%     'Label','Fall Recovery Time','LabelHorizontalAlignment','left','LabelVerticalAlignment','top','FontSize',14);
%
% end

%%
fig1 = figure();
 
plot(time, acc, 'b', 'DisplayName', 'SVM',"LineWidth",2);
hold on;
%plot(min_valley_time, min_valley_value,  'v','MarkerEdgeColor', 'r', 'MarkerFaceColor', 'none', 'MarkerSize', 20, 'DisplayName','Valle',"LineWidth",3); % Triangolo rosso
yline(valley_threshold,'LineStyle','--','Color',[1, 0.5, 0],'LineWidth',2, "DisplayName","Soglia di Valle");   
      
yline(peak_threshold,'LineStyle','--','Color','r','LineWidth',2, 'DisplayName','Soglia di Picco');
     
hold off;
ylim([0,6]);
    xlabel('Tempo [s]');
    ylabel('Accelerazione [g]');
    %title('SVM plot');
    legend('Location','northeast','NumColumns',2);
    grid on;
%%export_fig 'fig1' '/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/ImgTesi/04-Algoritmo/Algorithm1' '-pdf' '-transparent';
%%
fig2 = figure();
 
plot(time, acc, 'b', 'DisplayName', 'SVM',"LineWidth",2);
hold on;
plot(min_valley_time, min_valley_value,  'v','MarkerEdgeColor', 'r', 'MarkerFaceColor', 'none', 'MarkerSize', 20, 'DisplayName','Valle',"LineWidth",3); % Triangolo rosso
yline(valley_threshold,'LineStyle','--','Color',[1, 0.5, 0],'LineWidth',2, "DisplayName","Soglia di Valle");   
      
yline(peak_threshold,'LineStyle','--','Color','r','LineWidth',2, 'DisplayName','Soglia di Picco');
     
hold off;
ylim([0,6]);
    xlabel('Tempo [s]');
    ylabel('Accelerazione [g]');
    %title('SVM plot');
    legend('Location','northeast','NumColumns',2);
    grid on;
%%export_fig 'fig2' '/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/ImgTesi/04-Algoritmo/Algorithm2' '-pdf' '-transparent';

%%
fig3 = figure();
 
plot(time, acc, 'b', 'DisplayName', 'SVM',"LineWidth",2);
hold on;
plot(min_valley_time, min_valley_value,  'v','MarkerEdgeColor', 'r', 'MarkerFaceColor', 'none', 'MarkerSize', 20, 'DisplayName','Valle',"LineWidth",3); % Triangolo rosso
plot(impact_time, impact_value, 'ro','MarkerEdgeColor', 'r', 'MarkerFaceColor', 'none', 'MarkerSize', 20, 'DisplayName','Picco',"LineWidth",3); % X rosso
yline(valley_threshold,'LineStyle','--','Color',[1, 0.5, 0],'LineWidth',2, "DisplayName","Soglia di Valle");   
      
yline(peak_threshold,'LineStyle','--','Color','r','LineWidth',2, 'DisplayName','Soglia di Picco');
     
hold off;
ylim([0,6]);
    xlabel('Tempo [s]');
    ylabel('Accelerazione [g]');
    %title('SVM plot');
    legend('Location','northeast','NumColumns',2);
    grid on;
%export_fig 'fig3' '/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/ImgTesi/04-Algoritmo/01_ValleyPeak' '-pdf' '-transparent';
exportgraphics(gcf, '/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/ImgTesi/04-Algoritmo/01_ValleyPeak.pdf', 'Resolution', 300)

%%
fig4 = figure();
 
plot(time, acc, 'b', 'DisplayName', 'SVM',"LineWidth",2);
hold on;
plot(min_valley_time, min_valley_value,  'v','MarkerEdgeColor', 'r', 'MarkerFaceColor', 'none', 'MarkerSize', 20, 'DisplayName','Valle',"LineWidth",3); % Triangolo rosso
plot(impact_time, impact_value, 'ro','MarkerEdgeColor', 'r', 'MarkerFaceColor', 'none', 'MarkerSize', 20, 'DisplayName','Picco',"LineWidth",3); % X rosso
yline(valley_threshold,'LineStyle','--','Color',[1, 0.5, 0],'LineWidth',2, "DisplayName","Soglia di Valle");   
      
yline(peak_threshold,'LineStyle','--','Color','r','LineWidth',2, 'DisplayName','Soglia di Picco');
     
xline(TT_time, 'LineStyle', '-.', 'LineWidth', 3,'DisplayName', 'TT');
xlim([5 18]);
hold off;
ylim([0,6]);
    xlabel('Tempo [s]');
    ylabel('Accelerazione [g]');
    %title('SVM plot');
    legend('Location','northeast','NumColumns',2);
    grid on;

%%
fig5 = figure();
 
yline(valley_threshold,'LineStyle','--','Color',[1, 0.5, 0],'LineWidth',2, "DisplayName","Soglia di Valle");   
      
hold on;
yline(peak_threshold,'LineStyle','--','Color','r','LineWidth',2, 'DisplayName','Soglia di Picco');
     
xline(TT_time, 'LineStyle', '-.', 'LineWidth', 3, 'DisplayName', 'TT');

plot(min_valley_time, min_valley_value,  'v','MarkerEdgeColor', 'r', 'MarkerFaceColor', 'none', 'MarkerSize', 20, 'DisplayName','Valle',"LineWidth",3); % Triangolo rosso
plot(impact_time, impact_value, 'ro','MarkerEdgeColor', 'r', 'MarkerFaceColor', 'none', 'MarkerSize', 20,'DisplayName','Picco',"LineWidth",3); % X rosso

xlim([5 18]);

% Regioni
    fill([preTransition_start_fall preTransition_start_fall preTransition_end_fall preTransition_end_fall], ...
        [(valley_value - 0.2) (peak_value + 0.2) (peak_value + 0.2) (valley_value - 0.2)], ...
        [1, 0.996, 0], 'FaceAlpha', 0.3, 'EdgeColor', 'k', 'DisplayName', 'Regione Pre-Caduta');

    fill([postTransition_start_fall postTransition_start_fall postTransition_end_fall postTransition_end_fall], ...
        [(valley_value - 0.2) (peak_value + 0.2) (peak_value + 0.2) (valley_value - 0.2)], ...
        'r', 'FaceAlpha', 0.3, 'EdgeColor', 'k', 'DisplayName', 'Regione Post-Caduta');

    % fill([postTransition_end_fall postTransition_end_fall time(recovery_window_end) time(recovery_window_end)], ...
    %     [(valley_value - 0.2) (peak_value + 0.2) (peak_value + 0.2) (valley_value - 0.2)], ...
    %     'c', 'FaceAlpha', 0.3, 'EdgeColor', 'k', 'DisplayName', 'Regione di Monitoraggio');

plot(time, acc, 'b', 'DisplayName', 'SVM',"LineWidth",2);

hold off;
    xlabel('Tempo [s]');
    ylabel('Accelerazione [g]');
    %title('SVM plot');
    legend('Location','northeast','NumColumns',1);
    grid on;
%export_fig 'fig5' '/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/ImgTesi/04-Algoritmo/03_RegionPrePostAcc' '-pdf' '-png' '-transparent';
exportgraphics(gcf, '/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/ImgTesi/04-Algoritmo/03_RegionPrePostAcc.pdf', 'Resolution', 300)


%%
fig6 = figure();
 

    axis([0 time(length(acc)) meanPressure_preFall-0.2 meanPressure_postFall+0.2]);


    % Regioni
    fill([preTransition_start_fall preTransition_start_fall preTransition_end_fall preTransition_end_fall], ...
        [(meanPressure_preFall-0.05) (meanPressure_postFall+0.1) (meanPressure_postFall+0.1) (meanPressure_preFall-0.05)], ...
        [1, 0.996, 0], 'FaceAlpha', 0.3, 'EdgeColor', 'k', 'DisplayName', 'Regione Post-Caduta');
    hold on;
    fill([postTransition_start_fall postTransition_start_fall postTransition_end_fall postTransition_end_fall], ...
        [(meanPressure_preFall-0.05) (meanPressure_postFall+0.1) (meanPressure_postFall+0.1) (meanPressure_preFall-0.05)], ...
        'r', 'FaceAlpha', 0.3, 'EdgeColor', 'k', 'DisplayName', 'Regione Post-Caduta');

    % fill([postTransition_end_fall postTransition_end_fall time(recovery_window_end) time(recovery_window_end)], ...
    %     [(meanPressure_preFall-0.1) (meanPressure_postFall+0.1) (meanPressure_postFall+0.1) (meanPressure_preFall-0.1)], ...
    %     'c', 'FaceAlpha', 0.3, 'EdgeColor', 'k', 'DisplayName', 'Regione di Monitoraggio');
    % 
xlim([5 18]);
ylim([989.8,990.05])
    plot(time, pressure, 'b', 'DisplayName', 'Pressione',"LineWidth",2);
     xlabel('Tempo [s]');
    ylabel('Pressione [hPa]');
    %title('Pressione plot');
    legend('Location','northeast','NumColumns',1);
    grid on;

%export_fig 'fig6' '/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/ImgTesi/04-Algoritmo/04_RegionPrePostPressure' '-pdf' '-png' '-transparent';
exportgraphics(gcf, '/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/ImgTesi/04-Algoritmo/04_RegionPrePostPressure.pdf', 'Resolution', 300)

%%
fig7 = figure();
 
    % Regioni
    fill([preTransition_start_fall preTransition_start_fall preTransition_end_fall preTransition_end_fall], ...
        [(meanPressure_preFall-0.1) (meanPressure_postFall+0.1) (meanPressure_postFall+0.1) (meanPressure_preFall-0.1)], ...
        [1, 0.996, 0], 'FaceAlpha', 0.4, 'EdgeColor', 'k', 'DisplayName', 'Regione Pre-Caduta');
 hold on;
    fill([postTransition_start_fall postTransition_start_fall postTransition_end_fall postTransition_end_fall], ...
        [(meanPressure_preFall-0.1) (meanPressure_postFall+0.1) (meanPressure_postFall+0.1) (meanPressure_preFall-0.1)], ...
        "r", 'FaceAlpha', 0.4, 'EdgeColor', 'k', 'DisplayName', 'Regione Post-Caduta');

    fill([postTransition_end_fall postTransition_end_fall time(recovery_window_end) time(recovery_window_end)], ...
        [(meanPressure_preFall-0.1) (meanPressure_postFall+0.1) (meanPressure_postFall+0.1) (meanPressure_preFall-0.1)], ...
        [1, 0.6, 0], 'FaceAlpha', 0.4, 'EdgeColor', 'k', 'DisplayName', 'Regione di Monitoraggio');

    
    plot(time, pressure, 'b', 'DisplayName', 'Pressione',"LineWidth",2);
    axis([0 time(length(acc)) meanPressure_preFall-0.2 meanPressure_postFall+0.2]);

     xlabel('Tempo [s]');
    ylabel('Pressione [hPa]');
    %title('Pressione plot');
    legend('Location','northeast','NumColumns',2);
    grid on;


%%
fig8 = figure();
 

    %hold on;

    % Regioni
    fill([preTransition_start_fall preTransition_start_fall preTransition_end_fall preTransition_end_fall], ...
        [989.81 (meanPressure_postFall+0.1) (meanPressure_postFall+0.1) 989.81], ...
        [1, 0.996, 0], 'FaceAlpha', 0.4, 'EdgeColor', 'k', 'DisplayName', 'Regione Pre-Caduta');
 hold on;
    fill([postTransition_start_fall postTransition_start_fall postTransition_end_fall postTransition_end_fall], ...
       [989.81 (meanPressure_postFall+0.1) (meanPressure_postFall+0.1) 989.81], ...
        "r", 'FaceAlpha', 0.4, 'EdgeColor', 'k', 'DisplayName', 'Regione Post-Caduta');

    fill([postTransition_end_fall postTransition_end_fall time(j) time(j)], ...
        [989.81 (meanPressure_postFall+0.1) (meanPressure_postFall+0.1) 989.81], ...
        [1, 0.6, 0], 'FaceAlpha', 0.4, 'EdgeColor', 'k', 'DisplayName', 'Regione di Monitoraggio');

    fill([time(j) time(j) time(j+window_2sec-1) time(j+window_2sec-1)], ...
        [989.81 (meanPressure_postFall+0.1) (meanPressure_postFall+0.1) 989.81], ...
        'g', 'FaceAlpha', 0.5, 'EdgeColor', 'k', 'DisplayName', 'Recupero');

    plot(time, pressure, 'b', 'DisplayName', 'Pressione',"LineWidth",2);
    axis([0 time(length(acc)) 989.8 meanPressure_postFall+0.2]);
    xlabel('Tempo [s]');
    ylabel('Pressione [hPa]');
    %title('Pressione plot');
    legend('Location','northeast','NumColumns',2);
    grid on;

%export_fig 'fig8' '/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/ImgTesi/04-Algoritmo/06_Recupero' '-png' '-transparent';
exportgraphics(gcf, '/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/ImgTesi/04-Algoritmo/06_Recupero.pdf', 'Resolution', 300)

