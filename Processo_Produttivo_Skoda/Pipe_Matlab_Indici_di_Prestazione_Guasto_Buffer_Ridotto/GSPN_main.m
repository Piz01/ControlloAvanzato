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

save('Workspace_Guasto_Buffer_Ridotto.mat');
