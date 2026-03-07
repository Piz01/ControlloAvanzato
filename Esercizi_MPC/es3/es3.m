%% ESERCIZIO 3 - Controllo Predittivo (MPC) con c = 3
clear; clc; close all;

% --- Parametri del Processo ---
num = 1.3; den = [1 -0.7]; Ts = 3; Hp = 3; Hu = 3; set_point = 2.5; Tref = 9;
u_prec = 0.3; y_prec = 1.3; y_attuale = 1.3;

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
Matrice_Step = [
    step_response(1), 0,                0;
    step_response(2), step_response(1), 0;
    step_response(3), step_response(2), step_response(1)
];

% 5. Risoluzione del sistema lineare per trovare le 3 mosse ottime
% Y_predetta = Y_free + Matrice_Step * Delta_U
% Imponendo Y_predetta = R_ref, troviamo Delta_U:
Delta_U = Matrice_Step \ (R_ref - Y_free);

u_hat_1 = u_prec + Delta_U(1);
u_hat_2 = u_hat_1 + Delta_U(2);
u_hat_3 = u_hat_2 + Delta_U(3);

fprintf('Traiettoria di riferimento R:\n'); disp(R_ref);
fprintf('Risposta libera Y_free:\n'); disp(Y_free);
fprintf('Matrice Dinamica S:\n'); disp(Matrice_Step);
fprintf('Vettore delle variazioni di controllo ottime Delta_U:\n'); disp(Delta_U);
fprintf('----> u(k|k) OTTIMA DA APPLICARE: %.4f\n\n', u_hat_1);

%% --- GRAFICI ESERCIZIO 3 ---
Y_pred = Y_free + Matrice_Step * Delta_U;

% Generazione degli assi per il plot (da k-1 a k+3)
time_pred = (-1:Hp) * Ts; % Array dei tempi: -3, 0, 3, 6, 9 sec

% Vettori per il plot
y_plot = [y_prec, y_attuale, Y_pred(1), Y_pred(2), Y_pred(3)];
u_plot = [u_prec, u_hat_1, u_hat_2, u_hat_3, u_hat_3]; % L'ultimo valore si mantiene costante
ref_plot = [y_prec, y_attuale, ref_P1, ref_P2, ref_P3];

fig1 = create_fig('MPC Esercizio 3 - Predizione k');
subplot(2,1,1);
plot(time_pred, y_plot, '-o', 'Color', [0 0.447 0.741], 'LineWidth', 1.5, 'MarkerSize', 6, 'MarkerFaceColor', [0 0.447 0.741]); hold on;
plot(time_pred, ref_plot, '--', 'Color', [0.85 0.325 0.098], 'LineWidth', 1.5);
format_ax('Tempo (s)', 'Uscita y(k+i|k)', 'Predizione dell''uscita all''istante k (Hp=3, Hu=3)', {'y predetta', 'Reference Trajectory'});

subplot(2,1,2);
stairs(time_pred, u_plot, '-s', 'Color', [0.466 0.674 0.188], 'LineWidth', 1.5, 'MarkerSize', 6, 'MarkerFaceColor', [0.466 0.674 0.188]);
format_ax('Tempo (s)', 'Ingresso u(k+i|k)', 'Sequenza di controllo ottima (Hu=3)', {});

save('Dati_Esercizio_3.mat');

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