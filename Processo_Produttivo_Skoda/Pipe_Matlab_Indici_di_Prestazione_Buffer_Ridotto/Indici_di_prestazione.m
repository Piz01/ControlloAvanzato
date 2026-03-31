clear;
clc;

load('Workspace_Buffer_Ridotto.mat');

disp(' ');
disp('==================================================');
disp('      ANALISI DEGLI INDICI DI PRESTAZIONE         ');
disp('==================================================');

disp('--- WIP PER OGNI POSTO (Numero medio di token) ---');

nomi_posti = {
    'Ant_Post_Conforme';
    'Ant_Post_Disp_Buffer';
    'Ant_Post_Disp_Conforme';
    'Ant_Post_Grezzo';
    'Ant_Post_Lavorato';
    'Ant_Post_Pezzi_Buffer';
    'Ant_Post_Tagl_Press';
    'Ant_Post_Tagliatrice_Pressa';
    'Carrozzeria_Pronta';
    'Disp_Muletto1';
    'Laminati';
    'Laminati_Trasportati';
    'Laminati su Muletto';       
    'Lat_Dx_Conforme';
    'Lat_Dx_Disp_Buffer';
    'Lat_Dx_Disp_Conforme';
    'Lat_Dx_Grezzo';
    'Lat_Dx_Lavorato';
    'Lat_Dx_Pezzi_Buffer';
    'Lat_Dx_Tagl_Press';
    'Lat_Dx_Tagliatrice_Pressa';
    'Lat_Sx_Conforme';
    'Lat_Sx_Disp_Buffer';
    'Lat_Sx_Disp_Conforme';
    'Lat_Sx_Grezzo';
    'Lat_Sx_Lavorato';
    'Lat_Sx_Pezzi_Buffer';
    'Lat_Sx_Tagl_Press';  
    'Lat_Sx_Tagliatrice_Pressa';
};         

Mean_Tokens = Prob * list; 
for p = 1:size(list, 2)
    if Mean_Tokens(p) > 0.001 % Stampa solo i posti non vuoti
        fprintf('%s: %.4f token medi\n', nomi_posti{p}, Mean_Tokens(p));
    end
end
disp(' ');

disp('--- THROUGHPUT TRANSIZIONI TEMPORIZZATE ---');
Throughput = zeros(1, length(rates));
for i = tan 
    if Prob(i) > 0
        for t = Ragg(i).abi
            if maschera_trans(t) == 0 % Temporizzata
                % Calcolo grado di abilitazione e gestione server
                p_ing = find(pre(:,t)~=0);
                tok_ing = list(i, p_ing);
                pesi_ing = pre(p_ing, t)';
                ED = min(floor(tok_ing ./ pesi_ing));
                
                if servers(t) == 0
                    f = 1; % Single server di default se lasciato a 0
                else
                    f = min(ED, servers(t));
                end
                
                % Calcolo Throughput
                Throughput(t) = Throughput(t) + Prob(i) * rates(t) * f;
            end
        end
    end
end
for t = 1:length(rates)
    if Throughput(t) > 0
        fprintf('Transizione %d: %.4f scatti/unita_di_tempo\n', t, Throughput(t));
    end
end
disp(' ');


disp('--- UTILIZZO RISORSE (Efficienza Macchine) ---');

idx_Muletto = 10;
idx_PressaTaglAnt = 8;
idx_PressaTaglSx = 29;
idx_PressaTaglDx = 21;

Utilizzo_Muletto = 1 - Mean_Tokens(idx_Muletto);
Utilizzo_PressaTaglAnt = 1 - Mean_Tokens(idx_PressaTaglAnt);
Utilizzo_PressaTaglSx = 1 - Mean_Tokens(idx_PressaTaglSx);
Utilizzo_PressaTaglDx = 1 - Mean_Tokens(idx_PressaTaglDx);

fprintf('Utilizzo Muletto: %.2f %%\n', Utilizzo_Muletto * 100);
fprintf('Utilizzo Pressa-Tagliatrice Anteriore-Posteriore: %.2f %%\n', Utilizzo_PressaTaglAnt * 100);
fprintf('Utilizzo Pressa-Tagliatrice Laterale Sx: %.2f %%\n', Utilizzo_PressaTaglSx * 100);
fprintf('Utilizzo Pressa-Tagliatrice Laterale Dx: %.2f %%\n', Utilizzo_PressaTaglDx * 100);
disp(' ');


disp('--- TEMPO MEDIO DI ATTESA NEI BUFFER (E[T]p) ---');
% Matrice Post (I+) per calcolare chi inserisce token nel buffer
post = I + pre; 


nomi_posti_buffer = {'Ant_Post_Pezzi_Buffer', 'Lat_Dx_Pezzi_Buffer', 'Lat_Sx_Pezzi_Buffer'};
posti_buffer = [6, 19, 27]; 

% Usiamo 'k' come indice che va da 1 a 3
for k = 1:length(posti_buffer)
    
    p = posti_buffer(k); % 'p' è l'indice del posto 
    T_in_totale = 0;
    
    % Trova transizioni in ingresso al posto p
    trans_ingresso = find(post(p, :) > 0); 
    
    for t = trans_ingresso
        if maschera_trans(t) == 0 % Consideriamo il flusso delle temporizzate
            T_in_totale = T_in_totale + (Throughput(t) * post(p, t));
        end
    end
    
    if T_in_totale > 0
        Attesa_Media = Mean_Tokens(p) / T_in_totale;
        % Usiamo 'k' per pescare il nome corretto dal cell array
        fprintf('%s: Tempo attesa medio = %.4f unita_tempo\n', nomi_posti_buffer{k}, Attesa_Media);
    end
end
disp(' ');

%% ======================================================================
%      ANALISI DI SISTEMA: WIP TOTALE E MANUFACTURING LEAD TIME (MLT)
% =======================================================================
disp('--- ANALISI GLOBALE DI SISTEMA ---');

posti_pezzi_fisici = [1, 4, 5, 6, 7, 9, 11, 12, 13, 14, 17, 18, 19, 20, 22, 25, 26, 27, 28]; 

WIP_Totale = sum(Mean_Tokens(posti_pezzi_fisici));

% Indica la transizione finale che "sforna" il prodotto (ovvero la Saldatura)
idx_Saldatura = 16; 

if Throughput(idx_Saldatura) > 0
    MLT = WIP_Totale / Throughput(idx_Saldatura);
    fprintf('WIP Totale (Pezzi fisici nel sistema): %.4f\n', WIP_Totale);
    fprintf('Throughput Globale (Uscita sistema): %.4f\n', Throughput(idx_Saldatura));
    fprintf('MANUFACTURING LEAD TIME (MLT): %.4f unita_tempo\n', MLT);
else
    disp('Attenzione: Il Throughput della transizione finale e nullo.');
end