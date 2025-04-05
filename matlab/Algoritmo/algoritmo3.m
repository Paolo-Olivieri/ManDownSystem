% Correzione del problema riscontrato in "algoritmo2.m". Uno dei problemi
% principali è stato quello di discriminare le scale da una caduta. Per
% questo, è stato aggiunto un controllo 
% if ((delta_pressure_fall > th_pressure_fall) &&
% (all(acc(postTransition_start_index:postTransition_end_index) <
% th_movement))) in cui tutte le accelerazioni nella finestra temporale
% postTransitionRegion devono essere minori di una soglia th_movement. 

% VERSIONE 0.1

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

%% LOAD DATA
%data = readtable("/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/Test/Stairs/stairs5.csv");
data = readtable("/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/Test/Fall&Recovery/fall&recovery19.csv");
acc = data.AccMagnitude;
pressure = data.Pressure;
time = data.Timestamp_Matlab;
filt_pressure = butterworthFilter(pressure,time,0.7,1);

%% THRESHOLDS AND TIME INTERVALS
valley_threshold = 0.6;                        %[g]
peak_threshold = 1.80;                         %[g]
pressure_fall_threshold = 0.07;                %[hPa]
max_still_threshold = 1.1;                     %[g]
min_still_threshold = 0.9 ;                    %[g]
pressure_getUp_threshold = pressure_fall_threshold;   %[hPa]
peak_window_time = 2;                       %[s]
recovery_window_time = 60;                  %[s]

%% ALGORITHM
fall_alert = false;
fall_motionless= false;
fall_recovered=false;

i=1;
while i<=length(acc)
    % Step 1: verifica se si presenta una valle (indice di possibile
    % esistenza di picco)
    if acc(i) < valley_threshold

        % Finestra entro cui è necessario trovare un picco (impatto)
        peak_window_end =min(i + round(peak_window_time / mean(diff(time))), length(acc));

        % Step 2: Ricerca del picco massimo entro 1s dalla prima valle
        % identificata
        if any(acc(i:peak_window_end) > peak_threshold)

            % Preleva picco massimo trovato nella finestra
            [peak_value, peak_relative_index] = max(acc(i:peak_window_end));
            peak_index = peak_relative_index + i - 1;

            % Trova tutti gli indici dove acc < th_valley
            valley_indices = find(acc(i:peak_index) < valley_threshold) + i - 1;

            if ~isempty(valley_indices)

                % Cerca il valore di accelerazione minore (valle più
                % profonda) tra quelli sotto la soglia
                [valley_value, min_valley_index] = min(acc(valley_indices));
                valley_index = valley_indices(min_valley_index);

                % Timestamp di valle e picco
                time_peak = time(peak_index);
                time_valley = time(valley_index);

                % Transition Time: istante temporale di mezzo tra il picco
                % massimo e la valle minima
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

                % Step 3: verifica a variazione della pressione tra le due
                % regioni

                % Calcolo della media delle pressioni in ciascuna delle due
                % regioni sopraindicate (pre-transition e post-transition)
                preTransition_pressure = pressure(time >= preTransition_start & time <= preTransition_end);
                postTransition_pressure = pressure(time >= postTransition_start & time <= postTransition_end);

                meanPressure_preTransition = mean(preTransition_pressure);
                meanPressure_postTransition = mean(postTransition_pressure);

                % misurazione della variazione di pressione (se è una
                % caduta sarà sicuramente positiva)
                delta_pressure_fall = meanPressure_postTransition - meanPressure_preTransition; % [hPa]

                % Verifica che la variazione di pressione sia maggiore di
                % una soglia, oltre la quale viene identificata la caduta,
                % e verifica che tutte le accelerazioni nella regione di
                % post transition siano tutte comprese tra la soglia
                % th_min_still e th_max_still (significa che il soggetto è
                % fermo). Nel particolare caso delle scale, chiaramente,
                % una caduta viene rilevata quando la pressione aumenta. Se
                % la pressione diminuisce non si prende nemmeno in
                % considerazione
                if ((delta_pressure_fall > pressure_fall_threshold) && ...
                        (all(acc(postTransition_start_index:postTransition_end_index) <= max_still_threshold) && ...
                        all(acc(postTransition_start_index:postTransition_end_index) >= min_still_threshold)))

                    % Step 4: verifica movimenti da sdraiato entro
                    % t_recoveryWindow

                    % La finestra di recovery si estende dalla fine del
                    % post-TT fino alla fine dei dati
                    recovery_end = min(postTransition_end_index + round(recovery_window_time / mean(diff(time))), length(acc));

                    % Se almeno un valore dell'accelerazione nella regione
                    % tra fine dell'intervallo di post transizione e
                    % termine del tempo di recupero disponibile, supera
                    % th_max_still o è minore di th_min_still ==> SOGGETTO
                    % SI MUOVE
                    if (any(acc(postTransition_end_index:recovery_end) >= max_still_threshold) ...
                            || (any(acc(postTransition_end_index:postTransition_end_index) <= min_still_threshold)))
                        % Step 5: Verifica variazioni di pressione

                        % Calcola il numero di campioni per 5 secondi
                        samples_5sec = round(5 / mean(diff(time)));

                        % Indici per gli ultimi 5 secondi dell'intervallo
                        % di recovery su cui valutare la media della
                        % pressione
                        recovery_5sec_start = max(recovery_end - samples_5sec + 1, postTransition_end_index);
                        recovery_5sec_end = recovery_end;

                        meanPressure_recovery = mean(pressure(recovery_5sec_start:recovery_5sec_end));

                        % Calcolo variazione di pressione
                        delta_pressure_recovery = abs(meanPressure_recovery - meanPressure_postTransition);

                        if delta_pressure_recovery < pressure_getUp_threshold
                            fprintf('Detected fall at %.2f sec\n', TT_time);

                            fprintf('Fallen but still moving slightly\n');
                            fall_alert = true;
                            fall_motionless = false;
                            break;
                        else
                            fprintf('Detected fall at %.2f sec\n', TT_time);
                            fprintf('Recovered from fall\n');
                            fall_alert = false;
                            fall_motionless = false;
                            fall_recovered = true;
                            i = recovery_end;
                        end

                    else
                        fprintf('Detected fall at %.2f sec\n', TT_time);
                        fprintf('Fallen and motionless\n');
                        fall_alert = true;
                        fall_motionless = true;
                        break;
                    end
                end
            end
        end
    end
    i = i+1;
end


if fall_alert
    if fall_motionless
        disp('FALL ALERT TRIGGERED: MOTIONLESS PERSON');
    else
        disp('FALL ALERT TRIGGERED: MOVING PERSON');
    end
else
    disp('NO FALL ALERT TRIGGERED!');
end

%% PLOT
% if(fall_recovered)
%     figure;
%     subplot(2,1,1);
%     plot(time, acc, 'b', 'DisplayName', 'Acceleration Magnitude');
%     hold on;
%     yline(valley_threshold,'LineStyle','--','Color','k','LineWidth',1.5, ...
%         'Label','Valley Threshold','LabelHorizontalAlignment','left','LabelVerticalAlignment','bottom','FontSize',14);
%     yline(peak_threshold,'LineStyle','--','Color','k','LineWidth',1.5, ...
%         'Label','Peak Threshold','LabelHorizontalAlignment','left','LabelVerticalAlignment','top','FontSize',14);
%     yline(max_still_threshold,'LineStyle','--','Color','r','LineWidth',1.5, ...
%         'Label','Max Movement Threshold','LabelHorizontalAlignment','left','LabelVerticalAlignment','top','FontSize',14);
%     yline(min_still_threshold,'LineStyle','--','Color','r','LineWidth',1.5, ...
%         'Label','Min Movement Threshold','LabelHorizontalAlignment','left','LabelVerticalAlignment','top','FontSize',14);
% 
%     xline(postTransition_start);
%     xline(postTransition_end);
%     hold off;
% 
%     subplot(2,1,2);
%     plot(time, pressure, 'b', 'DisplayName', 'Pressure');
% end
% 
% 
% if fall_alert
%     figure;
%     subplot(2,1,1);
%     plot(time_peak, peak_value, 'rx', 'MarkerFaceColor', 'r', 'MarkerSize', 10); % Triangolo rosso
%     hold on;
%     plot(time_valley, valley_value,  'x', 'MarkerFaceColor', 'r', 'MarkerSize', 10); % Triangolo rosso
%     plot(time, acc, 'b', 'DisplayName', 'Acceleration Magnitude');
% 
% 
%     % Regioni
%     fill([preTransition_start preTransition_start preTransition_end preTransition_end], ...
%         [(valley_value - 0.2) (peak_value + 0.2) (peak_value + 0.2) (valley_value - 0.2)], ...
%         'g', 'FaceAlpha', 0.3, 'EdgeColor', 'k', 'DisplayName', 'Pre-TT');
% 
%     text((preTransition_start + preTransition_end) / 2, peak_value + 0.2, 'Pre-TT', ...
%         'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 15, 'FontWeight', 'bold');
% 
% 
%     fill([postTransition_start postTransition_start postTransition_end postTransition_end], ...
%         [(valley_value - 0.2) (peak_value + 0.2) (peak_value + 0.2) (valley_value - 0.2)], ...
%         'g', 'FaceAlpha', 0.3, 'EdgeColor', 'k', 'DisplayName', 'Pre-TT');
% 
%     text((postTransition_start + postTransition_end) / 2, peak_value + 0.2, 'Post-TT', ...
%         'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 15, 'FontWeight', 'bold');
% 
% 
%     fill([postTransition_end postTransition_end time(recovery_end) time(recovery_end)], ...
%         [(valley_value - 0.2) (peak_value + 0.2) (peak_value + 0.2) (valley_value - 0.2)], ...
%         'c', 'FaceAlpha', 0.3, 'EdgeColor', 'k', 'DisplayName', 'Recovery Area');
% 
%     text((postTransition_end + time(recovery_end)) / 2, peak_value + 0.2, 'Recovery Area', ...
%         'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 15, 'FontWeight', 'bold');
% 
%     yline(valley_threshold,'LineStyle','--','Color','k','LineWidth',1.5, ...
%         'Label','Valley Threshold','LabelHorizontalAlignment','left','LabelVerticalAlignment','bottom','FontSize',14);
%     yline(peak_threshold,'LineStyle','--','Color','k','LineWidth',1.5, ...
%         'Label','Peak Threshold','LabelHorizontalAlignment','left','LabelVerticalAlignment','top','FontSize',14);
%     yline(max_still_threshold,'LineStyle','--','Color','r','LineWidth',1.5, ...
%         'Label','Max Movement Threshold','LabelHorizontalAlignment','left','LabelVerticalAlignment','top','FontSize',14);
%     yline(min_still_threshold,'LineStyle','--','Color','r','LineWidth',1.5, ...
%         'Label','Min Movement Threshold','LabelHorizontalAlignment','left','LabelVerticalAlignment','top','FontSize',14);
% 
% 
%     % fill([time(recovery_5sec_start) time(recovery_5sec_start)
%     % time(recovery_end) time(recovery_end)], ...
%     %      [(valley_value - 0.2) (peak_value + 0.2) (peak_value + 0.2)
%     %      (valley_value - 0.2)], ... 'c', 'FaceAlpha', 0.3, 'EdgeColor',
%     %      'k');
%     %
%     % text((time(recovery_5sec_start) + time(recovery_end)) / 2, peak_value
%     % + 0.6, '5 Second area', ...
%     %      'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom',
%     %      'FontSize', 15, 'FontWeight', 'bold');
% 
% 
%     hold off;
%     xlabel('Timestamp');
%     ylabel('Magnitudine dell''accelerazione');
%     title('Plot della magntiude dell''accelerazione');
%     legend( 'Max Peak (Impact)', 'Min Valley (Falling)','Acceleration Magnitude','Location','northeast');
%     grid on;
% 
%     subplot(2,1,2);
%     plot(time, pressure, 'b', 'DisplayName', 'Pressure');
%     hold on;
%     plot(time, filt_pressure, 'r', 'DisplayName', 'Filt Pressure');
% 
%     % Regioni
%     fill([preTransition_start preTransition_start preTransition_end preTransition_end], ...
%         [(min(pressure)-0.5) (max(pressure)+0.05) (max(pressure)+0.05) (min(pressure)-0.5)], ...
%         'g', 'FaceAlpha', 0.3, 'EdgeColor', 'k');
% 
%     text((preTransition_start + preTransition_end) / 2, max(pressure) + 0.2, 'Pre-TT', ...
%         'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 15, 'FontWeight', 'bold');
% 
% 
%     fill([postTransition_start postTransition_start postTransition_end postTransition_end], ...
%         [(min(pressure)-0.5) (max(pressure)+0.05) (max(pressure)+0.05) (min(pressure)-0.5)], ...
%         'g', 'FaceAlpha', 0.3, 'EdgeColor', 'k');
% 
%     text((postTransition_start + postTransition_end) / 2, max(pressure) + 0.2, 'Post-TT', ...
%         'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 15, 'FontWeight', 'bold');
% 
% 
%     fill([postTransition_start postTransition_start time(recovery_end) time(recovery_end)], ...
%         [(min(pressure)-0.5) (max(pressure)+0.05) (max(pressure)+0.05) (min(pressure)-0.5)], ...
%         'c', 'FaceAlpha', 0.3, 'EdgeColor', 'k');
% 
%     text((postTransition_start + time(recovery_end)) / 2, max(pressure) + 0.2, 'Recovery Area', ...
%         'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 15, 'FontWeight', 'bold');
% 
%     % fill([time(recovery_5sec_start) time(recovery_5sec_start)
%     % time(recovery_end) time(recovery_end)], ...
%     %      [(min(pressure)-0.5) (max(pressure)+0.05) (max(pressure)+0.05)
%     %      (min(pressure)-0.5)], ... 'c', 'FaceAlpha', 0.3, 'EdgeColor',
%     %      'k');
%     %
%     % text((time(recovery_5sec_start) + time(recovery_end)) / 2,
%     % max(pressure) + 0.2, '5 Second area', ...
%     %      'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom',
%     %      'FontSize', 15, 'FontWeight', 'bold');
%     %
% 
%     xlabel('Timestamp');
%     ylabel('Pressione');
%     title('Plot della pressione');
%     grid on;
% 
% end
% 
