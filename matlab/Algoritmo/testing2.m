% TESTING AUTOMATIZZATO PER OGNI CATEGORIA

%% INIT
clc;
clear;
close all;
set(0,'DefaultLineLineWidth', 1.5);
set(0,'defaultAxesFontSize', 20);
set(0,'DefaultFigureWindowStyle', 'docked');
set(0,'defaulttextInterpreter','latex');
rng('default');

addpath '/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis';
load('/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/Training/prctile.mat');


%% LOAD DATA
%folderPath = '/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/Test/Fall&Recovery';
folderPath = '/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/Test/Fall&Rest';
%folderPath = '/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/Test/LateralFall';
%folderPath = '/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/Test/BackwardFall';
%folderPath = '/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/Test/VerticalFall';
%folderPath = '/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/Test/BendOver';
%folderPath = '/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/Test/Crouch';
%folderPath = '/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/Test/Elevator';
%folderPath = '/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/Test/Sit';
%folderPath = '/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/Test/Stairs';
%folderPath = '/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/Test/Strambling';
%folderPath = '/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/Test/Walk';

countCorrect = 0;
countIncorrect = 0;

vecCorrect = [];
vecIncorrect = [];
pressure_slope_vec = [];
variance_vec = [];

countAlarmTriggered = 0;

%% THRESHOLDS AND TIME INTERVALS
%valley_threshold = 0.6;                                 %[g]
%peak_threshold = 1.80;                                  %[g]
pressure_fall_threshold = 0.06;                         %[hPa]
max_still_threshold = 1.08;                             %[g]
min_still_threshold = 0.92;                             %[g]
pressure_getUp_threshold = pressure_fall_threshold;     %[hPa]
peak_window_time = 2;                                   %[s]
recovery_window_time = 60;                              %[s]
variance_threshold= 0.0015;                              %[g] 

FN_matrix = zeros(length(prctile_valley_vec), length(prctile_peak_vec)); % Matrice FN
FP_matrix = zeros(length(prctile_valley_vec), length(prctile_peak_vec)); % Matrice FP
TP_matrix = zeros(length(prctile_valley_vec), length(prctile_peak_vec)); % Matrice TP
TN_matrix = zeros(length(prctile_valley_vec), length(prctile_peak_vec)); % Matrice TN



for valleyMatrix_idx = 1:length(prctile_valley_vec)
    for peakMatrix_idx = 1:length(prctile_peak_vec)
        valley_threshold = prctile_valley_vec(valleyMatrix_idx);
        peak_threshold = prctile_peak_vec(peakMatrix_idx);

        FN = 0;
        FP = 0;
        TP = 0;
        TN = 0;
        is_fall_test = true;

        for k = 1:20

            fprintf("\n-------- TEST %d | Peak %.4f | Valley %.4f--------\n",k,peak_threshold, valley_threshold);
            % Nome del file CSV
            %csvName = sprintf('fall&recovery%d.csv', k);
            %csvName = sprintf('verticalFall%d.csv', k);
            csvName = sprintf('fall&rest%d.csv', k);
            %csvName = sprintf('lateralFall%d.csv', k);
            %csvName = sprintf('backwardFall%d.csv', k);
            %csvName = sprintf('crouch%d.csv', k);
            %csvName = sprintf('elevator%d.csv', k);
            %csvName = sprintf('sit%d.csv', k);
            %csvName = sprintf('stairs%d.csv', k);
            %csvName = sprintf('strambling%d.csv', k);
            %csvName = sprintf('walk%d.csv', k);
            
            % Percorso completo del file
            csvPath = fullfile(folderPath, csvName); % fullfile per costruire il percorso

            % Dati dal file CSV
            data = readtable(csvPath); % Leggo il CSV usando il percorso completo

            time = data.Timestamp_Matlab;
            acc = data.AccMagnitude;
            pressure = data.Pressure;
            


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
                                fprintf("Pressure variation: %.4f\n",delta_pressure_fall);


                                % Se il deltaPressione supera una soglia e
                                % l'accelerazione è compresa tra due soglie che
                                % indicano che il soggetto è fermo, allora viene
                                % confermata la caduta
                                % + round(1/mean(diff(time)))
                                if delta_pressure_fall >= pressure_fall_threshold && ...
                                        var(acc(postTransition_start_index :postTransition_end_index)) <= (variance_threshold)
                                    % Utile per i plot, in modo da visualizzare le
                                    % regioni quando effettivamente vi è una caduta
                                    pressure_slope = delta_pressure_fall / (time_peak - time(preTransition_end_index));
                                    pressure_slope_vec = [pressure_slope_vec,pressure_slope];
                                    fprintf("Slope fall: %.8f\n",pressure_slope);
                                    fprintf("PostTT variance: %.8f\n",var(acc(postTransition_start_index:postTransition_end_index)));

                                    variance_vec = [variance_vec,var(acc(postTransition_start_index :postTransition_end_index))];
                                    preTransition_start_fall = preTransition_start;
                                    preTransition_end_fall = preTransition_end;

                                    postTransition_start_fall = postTransition_start;
                                    postTransition_end_fall = postTransition_end;


                                    meanPressure_postFall = meanPressure_postTransition;
                                    meanPressure_preFall = meanPressure_preTransition;

                                    impact_value = acc(peak_index);
                                    impact_time = time(peak_index);

                                    

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
                        if any(acc(postTransition_end_index:recovery_window_end) >= max_still_threshold) || ...
                                any(acc(postTransition_end_index:recovery_window_end) <= min_still_threshold)

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

                        else
                            fall_alert = true;
                            fall_motionless = true;
                            fprintf('Fallen and motionless\n');
                            stato = 'Allerta';
                        end

                    case 'Allerta'
                        if fall_alert
                            if fall_motionless
                                fprintf('FALL ALERT TRIGGERED: MOTIONLESS PERSON (Test %d)\n',k);
                                stato = 'Fine';
                            else
                                fprintf('FALL ALERT TRIGGERED: MOVING PERSON (Test %d)\n',k);
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
                fprintf('NO FALL ALERT TRIGGERED (Test %d)\n',k);
            end

            % Verifica se il risultato è FN o FP
            if is_fall_test && ~fall_alert  % is_fall_test indica se il dataset rappresenta una caduta
                FN = FN + 1;  % Non ha rilevato una caduta reale
            elseif ~is_fall_test && fall_alert
                FP = FP + 1;  % Ha rilevato una caduta quando non c'era
            elseif is_fall_test && fall_alert
                TP = TP+1;
            elseif ~is_fall_test && ~fall_alert
                TN = TN+1;
            end

        end

        % Memorizza i risultati nella matrice
        FN_matrix(valleyMatrix_idx, peakMatrix_idx) = FN;
        FP_matrix(valleyMatrix_idx, peakMatrix_idx) = FP;
        TP_matrix(valleyMatrix_idx, peakMatrix_idx) = TP;
        TN_matrix(valleyMatrix_idx, peakMatrix_idx) = TN;
    end
end


%%
fig = figure('Name','LateralFall');

subplot(2, 2, 1);
h1 = heatmap(prctile_peak_vec, prctile_valley_vec, TP_matrix, 'Colormap', sky);
h1.ColorLimits = [0 20];
xlabel('Peak Threshold [g]');
ylabel('Valley Threshold [g]');
title('True Positive (TP)');

subplot(2, 2, 2);
h2 = heatmap(prctile_peak_vec, prctile_valley_vec, FP_matrix, 'Colormap', sky);
h2.ColorLimits = [0 20];
xlabel('Peak Threshold [g]');
ylabel('Valley Threshold [g]');
title('False Positives (FP)');

subplot(2, 2, 3);
h3 = heatmap(prctile_peak_vec, prctile_valley_vec, FN_matrix, 'Colormap', sky);
h3.ColorLimits = [0 20];
xlabel('Peak Threshold [g]');
ylabel('Valley Threshold [g]');
title('False Negatives (FN)');

subplot(2, 2, 4);
h4 = heatmap(prctile_peak_vec, prctile_valley_vec, TN_matrix, 'Colormap', sky);
h4.ColorLimits = [0 20];
xlabel('Peak Threshold [g]');
ylabel('Valley Threshold [g]');
title('True Negative (TN)');

sgtitle('Lateral Fall Confusion Matrix');

 % savefig(gcf, '/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/Test/LateralFall/ConfusionMatrix/LateralFall_ConfusionMatrix.fig');
 % save(fullfile('/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/Test/LateralFall/ConfusionMatrix/','matrixLateralFall'),'TP_matrix','FP_matrix','TN_matrix','FN_matrix');