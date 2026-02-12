function [m0, m1] = Crea_Struttura(m,C,pre,H,t_pr) 
    %Tale funzione viene utilizzata per calcolare le marcature raggiunte da
    %uno stato creando un elemento avente la seguente struttura:
    
    %m0.value=marcature dello stato 
    %m0.abi=transizioni abilitate 
    %m0.out.num=numero di posti raggiungibili ad un passo dallo stato 
    %m0.out.value=stati raggiungibili dallo stato m0

    %%% Parametri in ingresso: 
    %m stato iniziale 
    %I matrice di incidenza 
    %pre matrice pre 

    %%% Parametri in uscita: 
    %m0 struttura suddetta 
    %m1 marcature raggiunte dallo stato m0 
%% Inizializzazione    
    m0.value=m;         %inserisco la marcatura iniziale nelle possibili marcature dello stato
    [np,nt]=size(pre);  %acquisisco il numero dei posti ed il numero delle 
                        %transizioni dalla matrice pre inserita
    m0v=zeros(np,np);   %Inizializzo la matrice che contiene i risultati delle
                        %differenze tra la marcatura considerata e le varie colonne della pre
    m0Abi=zeros(1,nt);  %Inizializzo il vettore delle transizioni abilitate a m0 

 
%% Controlla se l'eventuale scatto della transizione i-esima porta ad una marcatura negativa 
    for i=1:1:nt 
        inib_ok = 1;
        if ~isequal(H(:,i),zeros(np,1))     %se ci sono archi inibitori
            posti_inibiti = find(H(:,i));   %trovo i posti inibitori
            for j = posti_inibiti           %per tutti i posti inibitori
                if m0.value(j) == 0         %se ha zero token
                    inib_ok = inib_ok*1;    %ok
                else                        %altrimenti
                    inib_ok = 0;            %non ok 
                end
            end
        end
        if (isempty(find(m0.value'-pre(:,i)<0)) && inib_ok) % se la transizione i è abilitta e non ci sono posti inibitori
            m0Abi(i)=1;                                     % la transizione i-esima è abilitata 
        end
    end 

%% Applicazione delle priorità        
    a1 = find(m0Abi>0);           % vettore delle transizioni abilitate (no priorità)
    max_pri = max(t_pr(a1));      % priorità massima fra le transizioni attivabili
    for i = a1
        if t_pr(i) < max_pri
            m0Abi(i) = 0;
        end
    end
    a2 = find(m0Abi>0);           % vett transiz. abilitate considerando le priorità
    
%% Calcolo marcature uscenti
    m0.out.num = sum(m0Abi);      %numero transizioni abilitate 
    if sum(m0Abi)>=1              %se ci sono transizioni abilitate 
        for i=1:1:m0.out.num 
                    m0.out.value(i,:) = m0.value+C(:,a2(i))'; %la fa scattare  
        end
    end  
%% Assegno i valori alla struttura 
    m0.abi=a2;
    m1=m0.out.value;
end

