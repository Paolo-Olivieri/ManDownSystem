%% INIT
clc;
clear;
close all;
set(0,'DefaultLineLineWidth', 1.5);
set(0,'defaultAxesFontSize', 20);
set(0,'DefaultFigureWindowStyle', 'docked'); 
set(0,'defaulttextInterpreter','latex');
set(groot, 'defaultAxesTickLabelInterpreter','latex');  
set(groot, 'defaultLegendInterpreter','latex');
rng('default');


addpath '/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis';
load('/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/Training/prctile.mat');


%% LOAD DATA

folderPath = '/Users/paolo/Desktop/ProgettoTesi/matlabManDown_Thesis/matlabManDown_Thesis/Test/Stairs';

vecCorrect = [];
vecIncorrect = [];
pressure_slope_vec = [];

countAlarmTriggered = 0;

%% THRESHOLDS AND TIME INTERVALS
    valley_threshold = 0.74883;                                 %[g]
    peak_threshold = 1.6489;                                  %[g]
    pressure_fall_threshold = 0.07;                         %[hPa]
    max_still_threshold = 1.08;                             %[g]
    min_still_threshold = 0.92;                             %[g]
    pressure_getUp_threshold = pressure_fall_threshold;     %[hPa]
    peak_window_time = 2;                                   %[s]
    recovery_window_time = 60;                              %[s]
    variance_threshold= 0.0015;                              %[g] Ricava da th_variance relativa ai test "LyingMovement"



    csvName = sprintf('stairs%d.csv', 1);

    % Percorso completo del file
    csvPath = fullfile(folderPath, csvName); % fullfile per costruire il percorso

    % Dati dal file CSV
    data = readtable(csvPath); % Leggo il CSV usando il percorso completo

    acc = data.AccMagnitude;
    pressure = data.Pressure;
    time = data.Timestamp_Matlab;


    