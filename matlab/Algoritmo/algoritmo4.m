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
set(0,'DefaultLineLineWidth', 1.5);
set(0,'defaultAxesFontSize', 20);
set(0,'DefaultFigureWindowStyle', 'docked');
set(0,'defaulttextInterpreter','latex');
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
pressure_fall_threshold = 0.07;                         %[hPa]
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

variance_vec = [];

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

                    % Timestamp picco e valle
                    time_peak = time(peak_index);
                    time_valley = time(valley_index);

                    % Timestamp e indice TransitionTime
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
                        variance_vec = [variance_vec,var(acc(postTransition_start_index:postTransition_end_index)) ];
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
            fprintf('A %.2f m fall was detected at %.2f sec with an impact of %.2f g\n',(delta_pressure_fall/0.12), TT_time, impact_value);

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
                        % Recupero rilevato
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

                % Se non è stato rilevato nessun recupero tramite variazione di pressione
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
%     subplot(2,1,1);
%     plot(time, acc, 'b', 'DisplayName', 'Acceleration Magnitude');
%     hold on;
%     plot(impact_time, impact_value, 'rx', 'MarkerFaceColor', 'r', 'MarkerSize', 15); % Triangolo rosso
%     yline(th_valley,'LineStyle','--','Color','k','LineWidth',1.5, ...
%         'Label','Valley Threshold','LabelHorizontalAlignment','left','LabelVerticalAlignment','bottom','FontSize',14);
%     yline(th_peak,'LineStyle','--','Color','k','LineWidth',1.5, ...
%         'Label','Peak Threshold','LabelHorizontalAlignment','left','LabelVerticalAlignment','top','FontSize',14);
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
%     plot(time, pressure, 'b', 'DisplayName', 'Pressure');
%     hold on;
%     plot(time, filt_pressure, 'r', 'DisplayName', 'Pressure');
%     xline(time(j),'LineStyle','--','Color','r','LineWidth',1.5, ...
%     'Label','Fall Recovery Time','LabelHorizontalAlignment','left','LabelVerticalAlignment','top','FontSize',14);
%
% end


if fall_alert || fall_recovered
    figure;
    subplot(2,1,1);
    plot(impact_time, impact_value, 'rx', 'MarkerFaceColor', 'r', 'MarkerSize', 15, 'DisplayName','Impact'); % Triangolo rosso
    hold on;
    plot(min_valley_time, min_valley_value,  'v', 'MarkerFaceColor', 'r', 'MarkerSize', 10, 'DisplayName','Valley'); % Triangolo rosso
    plot(time, acc, 'b', 'DisplayName', 'Acceleration Magnitude');


    % Regioni
    fill([preTransition_start_fall preTransition_start_fall preTransition_end_fall preTransition_end_fall], ...
        [(valley_value - 0.2) (peak_value + 0.2) (peak_value + 0.2) (valley_value - 0.2)], ...
        'g', 'FaceAlpha', 0.3, 'EdgeColor', 'k', 'DisplayName', 'Pre-Transition Time Region');

    fill([postTransition_start_fall postTransition_start_fall postTransition_end_fall postTransition_end_fall], ...
        [(valley_value - 0.2) (peak_value + 0.2) (peak_value + 0.2) (valley_value - 0.2)], ...
        'g', 'FaceAlpha', 0.3, 'EdgeColor', 'k', 'DisplayName', 'Post-Transition Time Region');

    fill([postTransition_end_fall postTransition_end_fall time(recovery_window_end) time(recovery_window_end)], ...
        [(valley_value - 0.2) (peak_value + 0.2) (peak_value + 0.2) (valley_value - 0.2)], ...
        'c', 'FaceAlpha', 0.3, 'EdgeColor', 'k', 'DisplayName', 'Recovery Area');


    yline(valley_threshold,'LineStyle','--','Color','k','LineWidth',1.5, ...
        'Label','Valley Threshold','LabelHorizontalAlignment','left','LabelVerticalAlignment','bottom','FontSize',14,'DisplayName','Valley threshold');
    yline(peak_threshold,'LineStyle','--','Color','k','LineWidth',1.5, ...
        'Label','Peak Threshold','LabelHorizontalAlignment','left','LabelVerticalAlignment','top','FontSize',14, 'DisplayName','Peak threshold');
    hold off;
    xlabel('Timestamp');
    ylabel('Magnitudine dell''accelerazione');
    title('Plot della magntiude dell''accelerazione');
    legend('Location','eastoutside');
    grid on;




    subplot(2,1,2);
    plot(time, pressure, 'b', 'DisplayName', 'Pressure');
    axis([0 time(length(acc)) meanPressure_preFall-0.2 meanPressure_postFall+0.2]);
    hold on;

    % Regioni
    fill([preTransition_start_fall preTransition_start_fall preTransition_end_fall preTransition_end_fall], ...
        [(meanPressure_preFall-0.1) (meanPressure_postFall+0.1) (meanPressure_postFall+0.1) (meanPressure_preFall-0.1)], ...
        'g', 'FaceAlpha', 0.3, 'EdgeColor', 'k', 'DisplayName', 'Pre-Transition Time Region');

    fill([postTransition_start_fall postTransition_start_fall postTransition_end_fall postTransition_end_fall], ...
        [(meanPressure_preFall-0.1) (meanPressure_postFall+0.1) (meanPressure_postFall+0.1) (meanPressure_preFall-0.1)], ...
        'g', 'FaceAlpha', 0.3, 'EdgeColor', 'k', 'DisplayName', 'Post-Transition Time Region');

    fill([postTransition_end_fall postTransition_end_fall time(recovery_window_end) time(recovery_window_end)], ...
        [(meanPressure_preFall-0.1) (meanPressure_postFall+0.1) (meanPressure_postFall+0.1) (meanPressure_preFall-0.1)], ...
        'c', 'FaceAlpha', 0.3, 'EdgeColor', 'k', 'DisplayName', 'Recovery Area');


    xlabel('Timestamp');
    ylabel('Pressione');
    title('Plot della pressione');
    legend('Location','eastoutside');
    grid on;

end

