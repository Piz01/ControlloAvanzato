function [list,Ragg] = Calcola_Marc_Ragg(a,list,Ragg,I,pre,H, t_pr) 
%% Parametri in ingresso: 
    %a=vettore delle marcature iniziali 
    %list = valore attuale dell'elenco degli stati raggiunti (inizialmente 
    %è una stringa nulla) 
    %Ragg= valore attuale dell'elenco della struttura relativa agli stati 

%% Parametri in uscita 
    %list=elenco aggiornato delle marcature raggiunte 
    %Ragg=elenco aggiornato delle strutture relative alle marcature 
    %raggiunte

    [m0, m1]=Crea_Struttura(a,I,pre,H,t_pr); %calcola la struttura della matrice 
                                            %m è la struttura con marcature e transizioni abilitate 
                                            %m2 contiene le marcature raggiunte dallo stato considerato (a)
    if isempty(Ragg)
        Ragg = m0;
        list = m0.value;
    end

    m1=m0.out.value; %ricava gli stati uscenti dallo stato 
    [nm, mm]=size(m1); 
    for i=1:nm 
        if strmatch(m1(i,:),list)>0                      % se la marcatura è gia stata vista
        else                                             % se m2 non è nella lista delle marcature raggiungibili 
            list=[list;m1(i,:)];                         % aggiunge m2 alla lista 
            [m0, l]=Crea_Struttura(m1(i,:),I,pre,H,t_pr); % richiama la funzione per ogni stato uscente dalla marcatura 
            Ragg=[Ragg;m0];                               % aggiunge la struttura relativa a Ragg 
            [list,Ragg]=Calcola_Marc_Ragg(m1(i,:),list,Ragg,I,pre,H,t_pr);  %si richiama ricorsivamente la funzione stessa per ogni nuovo 
                                                                            %stato fino a quando gli stati raggiunti sono tutti collezionati in list 
        end
    end
end
