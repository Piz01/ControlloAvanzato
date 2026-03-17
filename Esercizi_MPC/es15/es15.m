%% Esercizio 15 - Modello linearizzato del Serbatoio
clear; clc;

% Matrici del modello di stato linearizzato a tempo continuo
A = -0.7;
B = [1, 1, -2];
C = 1;
D = [0, 0, 0];

% Creazione del modello State-Space a tempo continuo
tank_sys = ss(A, B, C, D);

% --- IMPOSTAZIONE DELLE PROPRIETA' DEL MODELLO ---

% Ingressi: Q1 (pompa 1), Q2 (pompa 2), X (valvola)
tank_sys.InputName = {'Q1', 'Q2', 'X'};
tank_sys.InputUnit = {'l/min', 'l/min', '%'};

% Uscite: V (Volume)
tank_sys.OutputName = {'V'};
tank_sys.OutputUnit = {'l'};

% Variabili di Stato: V (Volume)
tank_sys.StateName = {'V'};
tank_sys.StateUnit = {'l'};

% Unità di tempo
tank_sys.TimeUnit = 'minutes';

% Mostra il modello a schermo per verifica
disp('Modello del Serbatoio configurato:');
disp(tank_sys);

% Salvataggio del modello in un file .mat
save('Modello_Serbatoio.mat', 'tank_sys');
fprintf('Modello linearizzato salvato con successo in "Modello_Serbatoio.mat"\n');