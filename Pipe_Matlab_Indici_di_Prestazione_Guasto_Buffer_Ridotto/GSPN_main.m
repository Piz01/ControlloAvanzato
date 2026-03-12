%% Inizializzazione
clear;
clc;
format short;

% pre: matrice di posti in ingreso alle transizioni
% I: matrice d'incidenza posti-transizioni
% H: matrice delle inibizioni
% m_ini: marcatura iniziale
% maschera_trans: vettore classificazione transizioni (1 immediate, 0 temporizzate)
% rates: vettore rates delle transiz. temporizzate (0 se immediata)
% weights: vettore pesi delle transiz. immediate (0 se temporizzata)
% t_pr: vettore priorità transiz. (0 se temporizzate)
% servers: vettore numero server delle transizioni
% we_ra: combinazione dei vettori dei rates e dei pesi
% list: lista marcature
% Ragg: struttura con gli stati raggiungibili, le transiz attive in essi e
%       i relativi output di questi

%% Raccolta dati strutturali
load('FOLDER/MATLAB.mat') % contiene filemane e indici
[pre, I, H, m_ini, maschera_trans, rates, weights, t_pr, servers] = matrici_pre_I(filename,indici);
we_ra = weights+rates;

%% Calcolo grafo di Raggiungibilità
list=[];
Ragg=[];
% genera la lista degli stati raggiungibili a partire dalla marcatura iniziale m0
[list,Ragg]=Calcola_Marc_Ragg(m_ini,list,Ragg,I,pre,H,t_pr);
%il numero degli stati è dato dalle righe della lista delle marcature raggiungibili
[ns, ~]=size(Ragg);      %provare con lenght

%% CALCOLO DELLA MATRICE A
disp(datetime)
disp('Calcolo matrice A')
A=zeros(ns,ns);
v=zeros(ns,1);
for i=1:ns
    for k = 1:Ragg(i).out.num
        for j=1:ns
            if strmatch(Ragg(i).out.value(k,:),Ragg(j).value)
                A(i,j)=Ragg(i).abi(k);
            end
        end
    end
end
%%  CALCOLO VETTORE qi
disp(datetime)
disp('Calcolo vettore qi')
qi = zeros(ns,1);
ind_multiple = find(servers>0);

for i=1:ns
    for t = Ragg(i).abi % scorre le transizioni attive in i
        if isempty(find(ind_multiple == t, 1)) % se la transizione non è multiple server
           qi(i) = qi(i) + we_ra(t);
        else
            p_ing = find(pre(:,t)~=0);          % si prendono i posti in ingresso alla transizione t
            tok_ing = Ragg(i).value(p_ing);     % si prendono i token nei posti in ingresso a t
            pesi_ing = pre(:,t);                % si prendono i pesi degli archi in ingresso a t
            ED = min(floor(tok_ing./pesi_ing)); % si calcola il grado di abilitazione di t
            K = servers(t);                     % si prende il grado di parallelismo di t
            f = min(ED,K);                      % f: funzione di dipendenza dalla marcatura
            qi(i) = qi(i) + we_ra(t)*f;         %il rate è moltiplicato per f
        end
    end
end

%% indici stati tangibili e vanescenti in Ragg
tan = []; van = [];
for i = 1:ns
    % FIX: Controllo preventivo se lo stato è un Deadlock (abi vuoto)
    if isempty(Ragg(i).abi)
        % Se non ci sono transizioni abilitate, è un Deadlock.
        % Lo consideriamo "Tangibile" perché il sistema ci rimane per sempre.
        tan = [tan, i]; 
        fprintf('Attenzione: Lo stato %d è un Deadlock (nessuna uscita).\n', i);
    elseif maschera_trans(Ragg(i).abi(1)) == 0
        % Se la prima transizione abilitata è temporizzata (0), lo stato è Tangibile
        tan = [tan, i];
    else
        % Se la prima transizione abilitata è immediata (1), lo stato è Vanescente
        van = [van, i];
    end
end


%% CALCOLO SOJOURN TIME
 SJ = zeros(length(qi),1);
 for i = tan                % si considerano solo le marcature tangible
     if qi(i)~=0           
        SJ(i) = 1/qi(i);
     else
         disp('Lo stato non ha uscite')
     end
 end

%%  CALCOLO DELLA MATRICE U
disp(datetime)
disp('Calcolo matrice U')
U_g = zeros(ns,ns);     % U grezza
for i=1:ns              % costruzione della matrice U_g
    for j=1:ns
        t = A(i,j);
        if t ~= 0      
            if isempty(find(ind_multiple == t, 1)) % se la transizione non è multiple server
                U_g(i,j) = U_g(i,j) + we_ra(t);
            else
                p_ing = find(pre(:,t)~=0);
                tok_ing = Ragg(i).value(p_ing);
                pesi_ing = pre(:,t);
                ED = min(floor(tok_ing./pesi_ing));
                K = servers(t);
                f = min(ED,K);
                U_g(i,j) = U_g(i,j) + we_ra(t)*f;
            end
        end
    end
    U_g(i,:) = U_g(i,:)/qi(i);
end                         

% VERIFICA DELLA U: somma per righe della U (devono essere pari a 1)
test=[];
for i=1:ns
    test=[test sum(U_g(i,:))];
end
if isequal(round(test,4), ones(1,ns))
    disp('matrice U ok');
else
    disp('matrice U no ok');
end

%% Trasformazione di coordinate
disp(datetime)
disp('Calcolo U_p (cambio di coordinate)')
C = []; D = []; E = []; F = [];
ci = 1; cj = 1; di = 1; dj = 1; ei = 1; ej = 1; fi = 1; fj = 1;
for i=1:ns
    cj = 1; dj = 1; ej = 1; fj = 1;
    c0 = 0; e0 = 0;
    for j=1:ns
        if(maschera_trans(Ragg(i).abi(1))==1)       % basta guardare solo la prima transizione abilitata 
                                                    % perché o sono tutte immediate o tutte temporizzate,
                                                    % non è possibile un mix come quello di baggiogero
            if(maschera_trans(Ragg(j).abi(1))==1)
                C(ci,cj)=U_g(i,j);
                cj=cj+1;
            else
                D(ci,dj)=U_g(i,j);
                dj=dj+1;
            end
            c0 = 1;
        else
            if(maschera_trans(Ragg(j).abi(1))==1)
                E(ei,ej)=U_g(i,j);
                ej=ej+1;
            else
                F(ei,fj)=U_g(i,j);
                fj=fj+1;
            end
            e0 = 1;
        end
    end
    ci = ci + c0;
    ei = ei + e0;
end
U = [C D; E F];

%% ======================================================================
%      CALCOLO DELLE PROBABILITÀ DI STATO STAZIONARIO (\pi)
% =======================================================================
disp(' ');
disp('Calcolo probabilità stazionarie...');

% 1. Ricostruzione indici Tangibili e Vanescenti (per mappare su list)
tan = []; van = [];
for i = 1:ns
    if isempty(Ragg(i).abi) || maschera_trans(Ragg(i).abi(1)) == 0
        tan = [tan, i]; % Tangibile (o Deadlock)
    else
        van = [van, i]; % Vanescente
    end
end
nt = length(tan);
nv = length(van);

% 2. Matrice di Transizione degli Stati Tangibili (P')
I_C = eye(nv) - C;
P_prime = F + E * (I_C \ D);

% 3. Risoluzione sistema lineare discreto (\nu * P' = \nu)
A_sys = P_prime' - eye(nt);
A_sys(end, :) = 1; % Vincolo di normalizzazione
b_sys = zeros(nt, 1);
b_sys(end) = 1;
nu = (A_sys \ b_sys)'; 

% 4. Probabilità a tempo continuo (\pi)
SJ_tang = SJ(tan); 
pi_tang = (nu .* SJ_tang') / sum(nu .* SJ_tang');

% Vettore globale 'Prob' lungo 'ns' (0 per i vanescenti)
Prob = zeros(1, ns);
Prob(tan) = pi_tang;
disp('Probabilità stazionarie calcolate con successo!');

%% ======================================================================
%      CALCOLO DEGLI INDICI DI PRESTAZIONE (Rif. Slide 17-20 + Relazione)
% =======================================================================
disp(' ');
disp('==================================================');
disp('      ANALISI DEGLI INDICI DI PRESTAZIONE         ');
disp('==================================================');

% --- Valore atteso di token nei posti (WIP locale) ---
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
    'Ant_Post_Tagliatrice_Pressa_Guasta';
    'Carrozzeria_Pronta';          
    'Disp_Muletto1';               
    'Laminati';                    
    'Laminati_Trasportati';        
    'Laminati su Mulettto';        
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

% --- INDICE 3 (Slide 19): Throughput delle Transizioni ---
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

% --- INDICE 1 (Slide 18): Probabilità di condizione (Utilizzo Macchine) ---
disp('--- UTILIZZO RISORSE (Efficienza Macchine) ---');
% Mappa qui gli indici dei posti che rappresentano macchine/robot liberi
idx_Muletto = 11;
idx_PressaTaglAnt = 8;
idx_PressaTaglAnt_Guasta = 9;
idx_PressaTaglSx = 30;
idx_PressaTaglDx = 22;

Utilizzo_Muletto = 1 - Mean_Tokens(idx_Muletto);
Utilizzo_PressaTaglAnt = 1 - Mean_Tokens(idx_PressaTaglAnt) - Mean_Tokens(idx_PressaTaglAnt_Guasta);
Utilizzo_PressaTaglSx = 1 - Mean_Tokens(idx_PressaTaglSx);
Utilizzo_PressaTaglDx = 1 - Mean_Tokens(idx_PressaTaglDx);

fprintf('Utilizzo Muletto: %.2f %%\n', Utilizzo_Muletto * 100);
fprintf('Utilizzo Reale Pressa Anteriore: %.2f %%\n', Utilizzo_PressaTaglAnt * 100);
fprintf('Tempo di DOWN (Guasto) Pressa Anteriore: %.2f %%\n', Mean_Tokens(idx_PressaTaglAnt_Guasta) * 100);
fprintf('Utilizzo Pressa-Tagliatrice Laterale Sx: %.2f %%\n', Utilizzo_PressaTaglSx * 100);
fprintf('Utilizzo Pressa-Tagliatrice Laterale Dx: %.2f %%\n', Utilizzo_PressaTaglDx * 100);
disp(' ');

% --- INDICE 4 (Slide 20): Tempo medio di attesa nel posto (Legge di Little locale) ---
disp('--- TEMPO MEDIO DI ATTESA NEI BUFFER (E[T]p) ---');
% Matrice Post (I+) per calcolare chi inserisce token nel buffer
post = I + pre; 

% Nomi e rispettivi indici (Assicurati che l'ordine corrisponda!)
nomi_posti_buffer = {'Ant_Post_Pezzi_Buffer', 'Lat_Dx_Pezzi_Buffer', 'Lat_Sx_Pezzi_Buffer'};
posti_buffer = [6, 20, 28]; % SOSTITUISCI con gli indici esatti del tuo Excel

% Usiamo 'k' come indice che va da 1 a 3
for k = 1:length(posti_buffer)
    
    p = posti_buffer(k); % 'p' ora è il vero indice del posto (es. 4, poi 16...)
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
        % Ora usiamo 'k' per pescare il nome corretto dal cell array
        fprintf('%s: Tempo attesa medio = %.4f unita_tempo\n', nomi_posti_buffer{k}, Attesa_Media);
    end
end
disp(' ');

%% ======================================================================
%      ANALISI DI SISTEMA: WIP TOTALE E MANUFACTURING LEAD TIME (MLT)
% =======================================================================
disp('--- ANALISI GLOBALE DI SISTEMA ---');

% Mappa qui TUTTI E SOLI gli indici dei posti che rappresentano pezzi fisici 
% (Grezzi, Tagliati, Buffer, Conforme). Escludi Muletti, Robot e Operatori.
posti_pezzi_fisici = [1, 4, 5, 6, 7, 10, 12, 13, 14, 15, 18, 19, 20, 21, 23, 26, 27, 28, 29]; 

WIP_Totale = sum(Mean_Tokens(posti_pezzi_fisici));

% Indica la transizione finale che "sforna" il prodotto (es. Saldatura)
idx_Saldatura = 18; 

if Throughput(idx_Saldatura) > 0
    MLT = WIP_Totale / Throughput(idx_Saldatura);
    fprintf('WIP Totale (Pezzi fisici nel sistema): %.4f\n', WIP_Totale);
    fprintf('Throughput Globale (Uscita sistema): %.4f\n', Throughput(idx_Saldatura));
    fprintf('MANUFACTURING LEAD TIME (MLT): %.4f unita_tempo\n', MLT);
else
    disp('Attenzione: Il Throughput della transizione finale e nullo.');
end