function [m0, m1] = Crea_Struttura(m,C,pre,H,t_pr) 
    % Inizializzazione    
    m0.value = m;         
    [np, nt] = size(pre);  
    m0Abi = zeros(1,nt);  
 
    % Controlla abilitazione transizioni
    for i=1:1:nt 
        inib_ok = 1;
        if ~isequal(H(:,i),zeros(np,1))     
            posti_inibiti = find(H(:,i));   
            for j = posti_inibiti'          
                if m0.value(j) == 0         
                    inib_ok = inib_ok*1;    
                else                        
                    inib_ok = 0;             
                end
            end
        end
        % Controllo token sufficienti e inibizione
        if (isempty(find(m0.value'-pre(:,i)<0, 1)) && inib_ok) 
            m0Abi(i)=1;                                     
        end
    end 

    % Applicazione priorità
    a1 = find(m0Abi>0);           
    if ~isempty(a1)
        max_pri = max(t_pr(a1));      
        for i = a1
            if t_pr(i) < max_pri
                m0Abi(i) = 0;
            end
        end
    end
    a2 = find(m0Abi>0);           
    
    % Calcolo marcature uscenti (CORREZIONE QUI)
    m0.out.num = sum(m0Abi);      
    m0.out.value = []; % Inizializza SEMPRE come vuoto per evitare l'errore
    
    if m0.out.num >= 1              
        for i=1:1:m0.out.num 
            m0.out.value(i,:) = m0.value + C(:,a2(i))';   
        end
    end  

    % Assegno i valori alla struttura 
    m0.abi = a2;
    m1 = m0.out.value;
end