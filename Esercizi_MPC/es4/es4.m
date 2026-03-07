%% ESERCIZIO 4 - Creazione Modello CSTR con ingresso aggiuntivo
clear; clc;

% Matrici del modello a tempo continuo originale
A = [ -5     -0.3427;
      47.68   2.785 ];

% La matrice B originale era 2x2. 
% Il disturbo non misurato è il secondo ingresso (C_A_f).
% Aggiungiamo una terza colonna identica alla seconda colonna.
B = [ 0   1   1;
      0.3 0   0 ];

% La matrice C rimane inalterata (2x2)
C = flipud(eye(2)); 

% La matrice D originale era 2x2 di zeri. Ora diventa 2x3.
D = zeros(2, 3);

% Creazione del modello State-Space (LTI) in tempo continuo
CSTR = ss(A, B, C, D);

% Assegnazione dei nomi (il nuovo ingresso ha lo stesso nome del disturbo)
CSTR.InputName = {'T_c', 'C_A_f', 'C_A_f'}; 
CSTR.OutputName = {'T', 'C_A'}; 
CSTR.StateName = {'C_A', 'T'}; 

% Assegnazione delle unità di misura (aggiunta la terza per il nuovo ingresso)
CSTR.InputUnit = {'K', 'kmol/m3', 'kmol/m3'}; 
CSTR.OutputUnit = {'K', 'kmol/m3'}; 
CSTR.StateUnit = {'kmol/m3', 'K'}; 

% Assegnazione delle categorie dei segnali per l'MPC:
% MV = Manipulated Variable (Ingresso 1)
% UD = Unmeasured Disturbance (Ingressi 2 e 3)
% MO = Measured Output (Uscita 1)
% UO = Unmeasured Output (Uscita 2)
CSTR = setmpcsignals(CSTR, 'MV', 1, 'UD', [2, 3], 'MO', 1, 'UO', 2);

% Salvataggio del modello in un file .mat come richiesto dalla traccia
save('CSTRlinearmodel_label.mat', 'CSTR');

disp('Modello CSTR esteso creato e salvato con successo nel file Dati_Esercizio_4.mat');