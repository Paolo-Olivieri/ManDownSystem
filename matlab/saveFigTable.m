%% Funzione dedita al salvataggio dei file .fig e .csv corrispondenti ad uno specifico test

function saveFigTable(subDirectory, name, tableValues)    

    % Percorso di base
    baseDirectory = '/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis';

    % Crea i percorsi completi per la figura e la tabella

    fullDirectory = fullfile(baseDirectory, subDirectory);
    figFullPath = fullfile(fullDirectory, [name, '.fig']);
    tableFullPath = fullfile(fullDirectory, [name, '.csv']);
    
    % Salva la figura
    saveas(gcf, figFullPath);
    
    % Salva la tabella
    writetable(tableValues, tableFullPath);
    
    disp(['Figura salvata in: ', figFullPath]);
    disp(['Tabella salvata in: ', tableFullPath]);
end

