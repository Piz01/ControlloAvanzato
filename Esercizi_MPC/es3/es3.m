%% ESERCIZIO 3 - Controllo Predittivo (MPC) con c = 3
clear; clc; close all;

% --- Parametri del Processo ---
num = 1.3;
den = [1 -0.7];
Ts = 3;              % Tempo di campionamento (sec)

Hp = 3;              % Orizzonte di predizione (9 sec)
Hu = 3;              % Orizzonte di controllo (3 mosse)
set_point = 2.5;     % Traiettoria di set-point s(k+i)
Tref = 9;            % Costante di tempo della reference trajectory

u_prec = 0.3;        % u(k-1)
y_prec = 1.3;        % y(k-1)
y_attuale = 1.3;     % y(k)

fprintf('--- ESERCIZIO 3: Calcolo matrice ottima all''istante k ---\n');

% 1. Calcolo della Reference Trajectory agli istanti P1=1, P2=2, P3=3
epsilon_attuale = set_point - y_attuale; 

% La formula per l'errore è: e(k+i) = e(k) * exp(-i * Ts / Tref)
epsilon_P1 = epsilon_attuale * exp(-(1 * Ts) / Tref);
epsilon_P2 = epsilon_attuale * exp(-(2 * Ts) / Tref);
epsilon_P3 = epsilon_attuale * exp(-(3 * Ts) / Tref);

ref_P1 = set_point - epsilon_P1;
ref_P2 = set_point - epsilon_P2;
ref_P3 = set_point - epsilon_P3;

% Vettore colonna della traiettoria di riferimento
R_ref = [ref_P1; ref_P2; ref_P3];

% 2. Risposta Libera del sistema negli istanti P1, P2, P3
y_libera_P1 = 0.7 * y_attuale + 1.3 * u_prec;
y_libera_P2 = 0.7 * y_libera_P1 + 1.3 * u_prec;
y_libera_P3 = 0.7 * y_libera_P2 + 1.3 * u_prec;

% Vettore colonna della risposta libera
Y_free = [y_libera_P1; y_libera_P2; y_libera_P3];

% 3. Risposta Forzata al gradino unitario
step_response = zeros(Hu, 1);
step_response(1) = 1.3;
for j = 2:Hu
    step_response(j) = 0.7 * step_response(j-1) + 1.3;
end

% 4. Creazione della Matrice Dinamica S (triangolare inferiore)
% Poiché abbiamo 3 incognite e 3 equazioni
Matrice_Step = [
    step_response(1), 0,                0;
    step_response(2), step_response(1), 0;
    step_response(3), step_response(2), step_response(1)
];

% 5. Risoluzione del sistema lineare per trovare le 3 mosse ottime
% Y_predetta = Y_free + Matrice_Step * Delta_U
% Imponendo Y_predetta = R_ref, troviamo Delta_U:
Delta_U = Matrice_Step \ (R_ref - Y_free);

% Estraiamo la prima mossa, che è l'unica che verrà effettivamente applicata (Receding Horizon)
delta_u_hat_1 = Delta_U(1);
delta_u_hat_2 = Delta_U(2);
delta_u_hat_3 = Delta_U(3);

u_hat_1 = u_prec + delta_u_hat_1;
u_hat_2 = u_hat_1 + delta_u_hat_2;
u_hat_3 = u_hat_2 + delta_u_hat_3;

% Stampe a video dei risultati
fprintf('Traiettoria di riferimento R:\n');
disp(R_ref);
fprintf('Risposta libera Y_free:\n');
disp(Y_free);
fprintf('Matrice Dinamica S:\n');
disp(Matrice_Step);
fprintf('Vettore delle variazioni di controllo ottime Delta_U:\n');
disp(Delta_U);
fprintf('----> u(k|k) OTTIMA DA APPLICARE: %.4f\n\n', u_hat_1);

%% --- GRAFICI ESERCIZIO 3 (Mostrati a video ma non salvati) ---
% Calcolo dell'uscita predetta totale
Y_pred = Y_free + Matrice_Step * Delta_U;

% Generazione degli assi per il plot (da k-1 a k+3)
time_pred = (-1:Hp) * Ts; % Array dei tempi: -3, 0, 3, 6, 9 sec

% Vettori per il plot
y_plot = [y_prec, y_attuale, Y_pred(1), Y_pred(2), Y_pred(3)];
u_plot = [u_prec, u_hat_1, u_hat_2, u_hat_3, u_hat_3]; % L'ultimo valore si mantiene costante
ref_plot = [y_prec, y_attuale, ref_P1, ref_P2, ref_P3];

figure('Name', 'MPC Esercizio 3 - Predizione k');
subplot(2,1,1);
plot(time_pred, y_plot, '-o', 'LineWidth', 1.5); hold on;
plot(time_pred, ref_plot, '--r', 'LineWidth', 1.5);
xlabel('Tempo (s)'); ylabel('Uscita y(k+i|k)');
title('Predizione dell''uscita all''istante k (Hp=3, Hu=3)');
legend('y predetta', 'Reference Trajectory', 'Location', 'SouthEast');
grid on;

subplot(2,1,2);
stairs(time_pred, u_plot, '-s', 'LineWidth', 1.5);
xlabel('Tempo (s)'); ylabel('Ingresso u(k+i|k)');
title('Sequenza di controllo ottima (Hu=3)');
grid on;

% Salva SOLO il file .mat nel Workspace per la professoressa
save('Dati_Esercizio_3.mat');