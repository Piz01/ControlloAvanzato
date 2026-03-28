%% ESERCIZIO 1 e 2 - Controllo Predittivo (MPC)
clear; clc; close all;

% --- Parametri del Processo ---
num = 1.3; den = [1 -0.7]; Ts = 3; Hp = 3; Hu = 1; set_point = 2.5; Tref = 0;
u_prec = 0.3; y_prec = 1.3; y_attuale = 1.3;

%% --- ESERCIZIO 1: Calcolo all'istante k ---
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

%% --- GRAFICI ESERCIZIO 1 ---
time_pred = (-1:Hp) * Ts;
y_pred_plot = [y_prec, y_attuale, zeros(1,Hp)];
for i=1:Hp, y_pred_plot(2+i) = 0.7*y_pred_plot(2+i-1) + 1.3*u_hat; end

fig1 = create_fig('MPC Esercizio 1 - Predizione Open-Loop');
subplot(2,1,1);
plot(time_pred, y_pred_plot, '-o', 'Color', [0 0.447 0.741], 'LineWidth', 1.5, 'MarkerSize', 6, 'MarkerFaceColor', [0 0.447 0.741]); hold on;
plot(time_pred, [y_prec, set_point*ones(1,Hp+1)], '--', 'Color', [0.85 0.325 0.098], 'LineWidth', 1.5);
format_ax('Tempo (s)', 'Uscita y(k+i|k)', 'Predizione dell''uscita all''istante k (Orizzonte Hp=3)', {'y predetta', 'Reference Trajectory'});

subplot(2,1,2);
stairs(time_pred, [u_prec, u_hat*ones(1,Hp+1)], '-s', 'Color', [0.466 0.674 0.188], 'LineWidth', 1.5, 'MarkerSize', 6, 'MarkerFaceColor', [0.466 0.674 0.188]);
format_ax('Tempo (s)', 'Ingresso u(k+i|k)', 'Sequenza di controllo ottima (Hu=1)', {});

%% --- ESERCIZIO 2: Calcolo all'istante k+1 ---
fprintf('\n--- ESERCIZIO 2: Calcolo all''istante k+1 ---\n');
y_next = 0.7 * y_attuale + 1.3 * u_hat;

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

fprintf('y(k+1): %.4f\n', y_next);
fprintf('y_free(k+4|k+1): %.4f\n', y_free_finale_2);
fprintf('delta_u(k+1|k+1): %.4f\n', delta_u_hat_2);
fprintf('u(k+1|k+1) ottima: %.4f\n', u_hat_2);

%% --- SIMULAZIONE E GRAFICI ---
N_sim = 10; time = (0:N_sim-1) * Ts;
y_sim = zeros(1, N_sim); u_sim = zeros(1, N_sim);
[y_sim(1), u_sim(1)] = deal(y_prec, u_hat); 

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

fig2 = create_fig('MPC Esercizi 1 e 2');
subplot(2,1,1);
plot(time, y_sim, '-o', 'Color', [0 0.447 0.741], 'LineWidth', 1.5, 'MarkerSize', 6, 'MarkerFaceColor', [0 0.447 0.741]); hold on;
plot(time, set_point*ones(1, N_sim), '--', 'Color', [0.85 0.325 0.098], 'LineWidth', 1.5);
format_ax('Tempo (s)', 'Uscita y(k)', 'Evoluzione della risposta del sistema con MPC', {'y(k) simulata', 'Setpoint r(k)'});

subplot(2,1,2);
stairs(time, u_sim, '-s', 'Color', [0.466 0.674 0.188], 'LineWidth', 1.5, 'MarkerSize', 6, 'MarkerFaceColor', [0.466 0.674 0.188]);
format_ax('Tempo (s)', 'Ingresso di controllo u(k)', 'Andamento del segnale di controllo', {});

save('Dati_Esercizio_1_2.mat');

%% --- FUNZIONI LOCALI ---
function fig = create_fig(name)
    fig = figure('Name', name, 'Color', 'w', 'Position', [100, 100, 800, 600]);
end

function format_ax(xl, yl, tit, leg_num)
    xlabel(xl, 'FontSize', 11, 'FontName', 'Helvetica', 'Color', 'k');
    ylabel(yl, 'FontSize', 11, 'FontName', 'Helvetica', 'Color', 'k');
    title({tit; ''}, 'FontSize', 12, 'FontName', 'Helvetica', 'FontWeight', 'bold', 'Color', 'k');
    if ~isempty(leg_num)
        leg = legend(leg_num, 'Location', 'southeast', 'FontSize', 10, 'Box', 'off');
        set(leg, 'TextColor', 'k');
    end
    grid on;
    set(gca, 'Color', 'w', 'XColor', 'k', 'YColor', 'k', 'FontSize', 10, 'FontName', 'Helvetica', 'LineWidth', 0.8, 'GridAlpha', 0.2);
end