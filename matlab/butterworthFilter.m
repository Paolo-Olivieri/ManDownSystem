%% DESCRIZIONE FUNZIONE
% butterworthFilter applica un filtro passa-basso di Butterworth ai dati del segnale.
%
% Parametri di Input:
%   data - Vettore contenente i dati del segnale da filtrare.
%   timestamp - Vettore contenente i timestamp corrispondenti ai dati del segnale.
%   cutoff_freq - Frequenza di taglio del filtro in Hz.
%   order - Ordine del filtro Butterworth.
%
% Output:
%   filtered_data - Vettore contenente i dati del segnale filtrato.
    

function [filtered_data] = butterworthFilter(data,timestamp,cutoff_freq, order)

    % sampling rate (dovrebbe essere ~16Hz)
    sampling_rate = 1/mean(diff(timestamp)); % Frequenza di campionamento [Hz] precisa
    
    % Normalizzazione della frequenza di taglio rispetto alla frequenza di
    % Nyquist
    nyquist_freq = sampling_rate / 2;
    normalized_cutoff = cutoff_freq / nyquist_freq;
    
    % Creazione del filtro Butterworth passa-basso
    % butter richiede una frequenza di cutoff normalizzata
    [b, a] = butter(order, normalized_cutoff, 'low');
    
    % Applicazione del filtro al segnale di pressione
    filtered_data = filtfilt(b, a, data);
end

