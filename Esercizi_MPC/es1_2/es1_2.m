%% ESERCIZIO 1 e 2 - Controllo Predittivo (MPC)
clear; clc; close all;

% --- Parametri del Processo ---
num = 1.3;
den = [1 -0.7];
Ts = 3;              % Tempo di campionamento (sec)

Hp = 3;              % Orizzonte di predizione (9 sec)
Hu = 1;              % Orizzonte di controllo (singola mossa)
set_point = 2.5;     % Traiettoria di set-point s(k+i)
Tref = 0;            % Costante di tempo della reference trajectory

u_prec = 0.3;        % u(k-1)
y_prec = 1.3;        % y(k-1)
y_attuale = 1.3;     % y(k)

fprintf('--- ESERCIZIO 1: Calcolo all''istante k ---\n');

% 1. Calcolo della Reference Trajectory all'istante Hp
epsilon = set_point - y_attuale; 
if Tref == 0
    epsilon_finale = 0;
else
    epsilon_finale = epsilon * exp(-Hp*Ts/Tref);
end
r_finale = set_point - epsilon_finale; 

% 2. Risposta Libera del sistema all'istante Hp
y_free = zeros(1, Hp);
y_free(1) = 0.7 * y_attuale + 1.3 * u_prec;
for i = 2:Hp
    y_free(i) = 0.7 * y_free(i-1) + 1.3 * u_prec;
end
y_free_finale = y_free(end);

% 3. Risposta Forzata al gradino unitario (Step Response) all'istante Hp
step_response = zeros(1, Hp);
step_response(1) = 1.3; % Risposta al primo istante
for i = 2:Hp
    step_response(i) = 0.7 * step_response(i-1) + 1.3;
end
y_step_finale = step_response(end);

% 4. Calcolo della mossa di controllo ottima (unico punto di coincidenza)
delta_u_hat = (r_finale - y_free_finale) / y_step_finale;
u_hat = u_prec + delta_u_hat;

fprintf('y_free(k+3|k): %.4f\n', y_free_finale);
fprintf('y_step(3): %.4f\n', y_step_finale);
fprintf('delta_u(k|k): %.4f\n', delta_u_hat);
fprintf('u(k|k) ottima: %.4f\n', u_hat);

%% --- GRAFICI ESERCIZIO 1 (Predizione all'istante k) ---
% Vogliamo plottare l'andamento da k-1 (passato) fino a k+Hp (futuro predetto)
time_pred = (-1:Hp) * Ts; % Asse dei tempi da -3 sec a +9 sec

y_pred_plot = zeros(1, length(time_pred));
u_pred_plot = zeros(1, length(time_pred));
ref_plot = zeros(1, length(time_pred));

% Valori al tempo k-1 (istante -3s)
y_pred_plot(1) = y_prec;
u_pred_plot(1) = u_prec;
ref_plot(1) = y_prec; % Prima del gradino

% Valori al tempo k (istante 0s)
y_pred_plot(2) = y_attuale;
u_pred_plot(2) = u_hat; % Da qui in poi applichiamo la mossa calcolata
ref_plot(2) = set_point;

% Calcoliamo l'evoluzione futura predetta per i prossimi Hp passi
for i = 1:Hp
    if i == 1
        y_pred_plot(2+i) = 0.7 * y_attuale + 1.3 * u_hat;
    else
        y_pred_plot(2+i) = 0.7 * y_pred_plot(2+i-1) + 1.3 * u_hat;
    end
    u_pred_plot(2+i) = u_hat; % Essendo Hu=1, l'ingresso rimane costante
    ref_plot(2+i) = set_point; % Tref=0, quindi reference coincide con set_point
end

% Generazione della figura
figure('Name', 'MPC Esercizio 1 - Predizione Open-Loop');
subplot(2,1,1);
plot(time_pred, y_pred_plot, '-o', 'LineWidth', 1.5); hold on;
plot(time_pred, ref_plot, '--r', 'LineWidth', 1.5);
xlabel('Tempo (s)'); ylabel('Uscita y(k+i|k)');
title('Predizione dell''uscita all''istante k (Orizzonte Hp=3)');
legend('y predetta', 'Reference Trajectory', 'Location', 'SouthEast');
grid on;

subplot(2,1,2);
stairs(time_pred, u_pred_plot, '-s', 'LineWidth', 1.5);
xlabel('Tempo (s)'); ylabel('Ingresso u(k+i|k)');
title('Sequenza di controllo ottima (Hu=1)');
grid on;

%% --- ESERCIZIO 2: Calcolo all'istante k+1 ---
fprintf('\n--- ESERCIZIO 2: Calcolo all''istante k+1 ---\n');

% Applico l'ingresso calcolato per trovare la vera nuova uscita y(k+1)
y_next = 0.7 * y_attuale + 1.3 * u_hat;

% Aggiorno le condizioni iniziali per il passo k+1
y_attuale_2 = y_next;
u_prec_2 = u_hat;

% Reference trajectory a k+1 (Tref=0 quindi coincide istantaneamente col set_point)
r_finale_2 = set_point;

% Risposta libera a k+1
y_free_2 = zeros(1, Hp);
y_free_2(1) = 0.7 * y_attuale_2 + 1.3 * u_prec_2;
for i = 2:Hp
    y_free_2(i) = 0.7 * y_free_2(i-1) + 1.3 * u_prec_2;
end
y_free_finale_2 = y_free_2(end);

% La step response rimane invariata per sistemi lineari tempo-invarianti
% Calcolo mossa ottima k+1
delta_u_hat_2 = (r_finale_2 - y_free_finale_2) / y_step_finale;
u_hat_2 = u_prec_2 + delta_u_hat_2;

fprintf('y(k+1): %.4f\n', y_attuale_2);
fprintf('y_free(k+4|k+1): %.4f\n', y_free_finale_2);
fprintf('delta_u(k+1|k+1): %.4f\n', delta_u_hat_2);
fprintf('u(k+1|k+1) ottima: %.4f\n', u_hat_2);

%% --- SIMULAZIONE E GRAFICI ---
% Eseguiamo una simulazione per mostrare l'andamento effettivo
N_sim = 10;
y_sim = zeros(1, N_sim);
u_sim = zeros(1, N_sim);

y_sim(1) = y_prec;
u_sim(1) = u_hat; 

for k = 2:N_sim
    y_sim(k) = 0.7 * y_sim(k-1) + 1.3 * u_sim(k-1);
    
    % Ricalcoliamo l'MPC ad ogni passo (logica receding horizon)
    y_f = zeros(1, Hp);
    y_f(1) = 0.7 * y_sim(k) + 1.3 * u_sim(k-1);
    for i = 2:Hp
        y_f(i) = 0.7 * y_f(i-1) + 1.3 * u_sim(k-1);
    end
    du = (set_point - y_f(end)) / y_step_finale;
    u_sim(k) = u_sim(k-1) + du;
end

time = (0:N_sim-1) * Ts;

figure('Name', 'MPC Esercizi 1 e 2');
subplot(2,1,1);
plot(time, y_sim, '-o', 'LineWidth', 1.5); hold on;
plot(time, set_point*ones(1, N_sim), '--r', 'LineWidth', 1.2);
xlabel('Tempo (s)'); ylabel('Uscita y(k)');
title('Evoluzione della risposta del sistema con MPC');
legend('y(k) simulata', 'Setpoint r(k)', 'Location', 'SouthEast');
grid on;

subplot(2,1,2);
stairs(time, u_sim, '-s', 'LineWidth', 1.5);
xlabel('Tempo (s)'); ylabel('Ingresso di controllo u(k)');
title('Andamento del segnale di controllo');
grid on;

save('Dati_Esercizio_1_2.mat');
