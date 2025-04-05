% E' stato riscontrato un problema di rilevazione dei picchi e delle valli,
% in quanto, in questo script, non vengono "selezionate" le valli minori,
% bensì la prima valle.


%% INIT
clc;
clear;
close all;
set(0,'DefaultLineLineWidth', 1.5);
set(0,'defaultAxesFontSize', 20);
set(0,'DefaultFigureWindowStyle', 'docked'); 
set(0,'defaulttextInterpreter','latex');
rng('default');

%% LOAD DATA
data = readtable("/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/Test/Fall&Rest/fall&rest1.csv");
acc = data.AccMagnitude;
pressure = data.Pressure;
time = data.Timestamp_Matlab;

%% THRESHOLDS AND TIME INTERVALS
th_valley = 0.7;            % [g]   Threshold della valle (1g corrisponde a 9.81 m/s^2)
th_peak = 1.8;              % [g]   Threshold per il picco
th_pressure_fall = 0.06;   % [hPa] Threshold per variazione di pressione [hPa]. considerando 0.12hPa/m * 0.8m
th_movement = 1.2;          % [g]   Threshold per movimento successivo
th_GU_P = th_pressure_fall; % [hPa] Threshold per variazione di pressione per il get up

t_valleyWindow = 0.8;                   % [s] Intervallo entro il quale, a partire dalla prima valle, deve essere trovata la valle minima
t_peakWindow = 1;                   % [s] Intervallo entro il quale, a partire dalla valle, deve essere trovato un picco
t_recoveryWindow = 60;                  % [s] Intervallo in cui vengono verificate variazioni di accelerazione e pressione significative

%% ALGORITHM
fall_alert = false;
fall_motionless= false;
i=1;
while i<=length(acc)
    % Step 1: verifica se si presenta una valle (indice di possibile esistenza di picco)
    if acc(i) < th_valley
        
        % Step 2: verifica se esiste un picco entro t_pw secondi dalla
        % valle
        window_valley_end = min(i + round(t_valleyWindow / mean(diff(time))), length(acc));
        
        % Trova tutti gli indici dove acc < th_valley
        valley_indices = find(acc(i:window_valley_end) < th_valley) + i - 1;

        if ~isempty(valley_indices)
        % Cerca il valore di accelerazione minore (valle più profonda) tra quelli sotto la soglia
        [valley_value, min_valley_index] = min(acc(valley_indices));
        valley_index = valley_indices(min_valley_index);
        
        window_peak_end = min(valley_index + round(t_peakWindow / mean(diff(time))), length(acc));
       
        
        % Ricerca del picco
            if any(acc(valley_index:window_peak_end) > th_peak)
                disp('Possible Fall');
                % Preleva picco massimo
                [peak_value, peak_relative_index] = max(acc(valley_index:window_peak_end));
                peak_index = peak_relative_index + valley_index - 1;
                
                % Timestamp di valle e picco
                time_peak = time(peak_index);
                time_valley = time(valley_index);

                % Transition Time
                TT_time = (time_peak + time_valley)/2;
                TT_index = round(peak_index + valley_index)/2;

                % Pre-transition region
                preTransition_start = max(TT_time-6,0);
                preTransition_end = max(TT_time-2,0);
                
                % Post-transition region
                postTransition_start = min(TT_time+2,time(length(acc)));
                postTransition_end = min(TT_time+6,time(length(acc)));

                postTransition_start_index = round(TT_index + 2/mean(diff(time)));

                preTransition_pressure = pressure(time >= preTransition_start & time <= preTransition_end);
                postTransition_pressure = pressure(time >= postTransition_start & time <= postTransition_end);

                % Step 3: verifica a variazione della pressione
                meanPressure_preTransition = mean(preTransition_pressure);
                meanPressure_postTransition = mean(postTransition_pressure);
                
                delta_pressure = meanPressure_postTransition - meanPressure_preTransition; % [hPa]
                
                if delta_pressure > th_pressure_fall
                    % Step 4: verifica movimenti da sdraiato entro t_GU
                    % Ultimo punto della finestra di recovery
                    recovery_end = min(postTransition_start_index + round(t_recoveryWindow / mean(diff(time))), length(acc));

                    if any(acc(postTransition_start_index:recovery_end) > th_movement)
                        % Step 5: Verifica variazioni di pressione
                        
                        % Calcola il numero di campioni per 5 secondi
                        samples_5sec = round(5 / mean(diff(time)));
                        
                        % Indici per gli ultimi 5 secondi dell'intervallo di recovery
                        recovery_5sec_start = max(recovery_end - samples_5sec + 1, postTransition_start_index);
                        recovery_5sec_end = recovery_end;
                        
                        meanPressure_recovery = mean(pressure(recovery_5sec_start:recovery_5sec_end));

                        % Calcolo variazione di pressione
                        delta_pressure_recovery = abs(meanPressure_recovery - meanPressure_postTransition);

                        if delta_pressure_recovery < th_GU_P
                            fprintf('Fallen but still moving slightly\n');
                            fall_alert = true;
                            fall_motionless = false;
                            break;
                        else
                            fprintf('Recovered from fall\n');
                            fall_alert = false;
                            fall_motionless = false;
                            i = recovery_end;
                        end
                    else
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

if fall_alert
    figure;
    subplot(2,1,1);
    plot(time_peak, peak_value, 'rx', 'MarkerFaceColor', 'r', 'MarkerSize', 10); % Triangolo rosso
    hold on;
    plot(time_valley, valley_value,  'x', 'MarkerFaceColor', 'r', 'MarkerSize', 10); % Triangolo rosso
    plot(time, acc, 'b', 'DisplayName', 'Acceleration Magnitude');
    
    yline(th_valley,'LineStyle','--','Color','k','LineWidth',1.5, ...
        'Label','Valley Threshold','LabelHorizontalAlignment','left','LabelVerticalAlignment','bottom','FontSize',14);
    yline(th_peak,'LineStyle','--','Color','k','LineWidth',1.5, ...
        'Label','Peak Threshold','LabelHorizontalAlignment','left','LabelVerticalAlignment','top','FontSize',14);
    
    % Regioni
    fill([preTransition_start preTransition_start preTransition_end preTransition_end], ...
         [(valley_value - 0.5) (peak_value + 0.5) (peak_value + 0.5) (valley_value - 0.5)], ...
         'g', 'FaceAlpha', 0.3, 'EdgeColor', 'k', 'DisplayName', 'Pre-Transition Region');
     
    text((preTransition_start + preTransition_end) / 2, peak_value + 0.6, 'Pre-Transition Region', ...
         'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 15, 'FontWeight', 'bold');
    
    
    fill([postTransition_start postTransition_start postTransition_end postTransition_end], ...
         [(valley_value - 0.5) (peak_value + 0.5) (peak_value + 0.5) (valley_value - 0.5)], ...
         'g', 'FaceAlpha', 0.3, 'EdgeColor', 'k', 'DisplayName', 'Pre-Transition Region');
    
    text((postTransition_start + postTransition_end) / 2, peak_value + 0.6, 'Post-Transition Region', ...
         'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 15, 'FontWeight', 'bold');
    
    
    fill([postTransition_start postTransition_start time(recovery_end) time(recovery_end)], ...
         [(valley_value - 0.5) (peak_value + 0.5) (peak_value + 0.5) (valley_value - 0.5)], ...
         'c', 'FaceAlpha', 0.3, 'EdgeColor', 'k', 'DisplayName', 'Recovery Area');
    
    text((postTransition_start + time(recovery_end)) / 2, peak_value + 0.6, 'Recovery Area', ...
         'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 15, 'FontWeight', 'bold');
    
    
    % fill([time(recovery_5sec_start) time(recovery_5sec_start) time(recovery_end) time(recovery_end)], ...
    %      [(valley_value - 0.5) (peak_value + 0.5) (peak_value + 0.5) (valley_value - 0.5)], ...
    %      'c', 'FaceAlpha', 0.3, 'EdgeColor', 'k');
    % 
    % text((time(recovery_5sec_start) + time(recovery_end)) / 2, peak_value + 0.6, '5 Second area', ...
    %      'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 15, 'FontWeight', 'bold');
    
    
    hold off;
    xlabel('Timestamp');
    ylabel('Magnitudine dell''accelerazione');
    title('Plot della magntiude dell''accelerazione');
    legend( 'Max Peak (Impact)', 'Min Valley (Falling)','Acceleration Magnitude','Location', 'best');
    grid on;
    
    subplot(2,1,2);
    plot(time, pressure, 'b', 'DisplayName', 'Pressure');
    hold on;
    
    % Regioni
    fill([preTransition_start preTransition_start preTransition_end preTransition_end], ...
         [(min(pressure)-0.5) (max(pressure)+0.05) (max(pressure)+0.05) (min(pressure)-0.5)], ...
         'g', 'FaceAlpha', 0.3, 'EdgeColor', 'k');
    
    text((preTransition_start + preTransition_end) / 2, max(pressure) + 0.2, 'Pre-Transition Region', ...
         'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 15, 'FontWeight', 'bold');
     
    
    fill([postTransition_start postTransition_start postTransition_end postTransition_end], ...
         [(min(pressure)-0.5) (max(pressure)+0.05) (max(pressure)+0.05) (min(pressure)-0.5)], ...
         'g', 'FaceAlpha', 0.3, 'EdgeColor', 'k');
    
    text((postTransition_start + postTransition_end) / 2, max(pressure) + 0.2, 'Post-Transition Region', ...
         'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 15, 'FontWeight', 'bold');
    
    
    fill([postTransition_start postTransition_start time(recovery_end) time(recovery_end)], ...
         [(min(pressure)-0.5) (max(pressure)+0.05) (max(pressure)+0.05) (min(pressure)-0.5)], ...
         'c', 'FaceAlpha', 0.3, 'EdgeColor', 'k');
    
    text((postTransition_start + time(recovery_end)) / 2, max(pressure) + 0.2, 'Recovery Area', ...
         'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 15, 'FontWeight', 'bold');
    
    % fill([time(recovery_5sec_start) time(recovery_5sec_start) time(recovery_end) time(recovery_end)], ...
    %      [(min(pressure)-0.5) (max(pressure)+0.05) (max(pressure)+0.05) (min(pressure)-0.5)], ...
    %      'c', 'FaceAlpha', 0.3, 'EdgeColor', 'k');
    % 
    % text((time(recovery_5sec_start) + time(recovery_end)) / 2, max(pressure) + 0.2, '5 Second area', ...
    %      'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 15, 'FontWeight', 'bold');
    % 
    
    xlabel('Timestamp');
    ylabel('Pressione');
    title('Plot della pressione');
    grid on;

end