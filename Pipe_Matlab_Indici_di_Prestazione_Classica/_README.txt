
**************Istruzioni simulazione di una nuova rete***********************

1) Creare la rete di petri da analizzare con il software PIPE 4.3.0
2) Calcolare le matrici con il tasto 'Incidence & Marking'
3) Premere 'copy' nella finestra di dialogo 
5) Creare una nuova cartella "FOLDER" nella stessa cartella in cui è presente GSPN_main.m
4) Creare un file Excel "EXCEL.xlsx" (all'interno della cartella "FOLDER") e incollare nella prima cella le matrici copiate da PIPE
5) Aggiungere nella riga successiva alla matrice Enabled Transition cinque righe che indicano:
	- Maschera (1 = immediate, 0 = temporizzate)
	- rates
	- pesi
	- priorità
	- servers
6) creare un file Matlab Data MATLAB.mat (all'interno della cartella "FOLDER") contenente due variabili:
	- filename: che dovrà contenere il path del file Excel rispetto alla posizione del main "FOLDER/EXCEL.xlsx".
	- indici: che sarà una matrice 2x9 in cui vengono indicati per ogni riga la cella iniziale e finale delle matrici presenti nel file Excel creato:
		o Forwards incidence matrix I+: matrice di posti in ingresso alle transizioni
		o Combined incidence matrix I:  matrice d'incidenza posti-transizioni
		o Inhibition matrix H: 	     	matrice delle inibizioni
		o Marking: 			marcatura iniziale
		o Maschera:			vettore classificazione transizioni (1 immediate, 0 temporizzate)
		o Rates: 			vettore rates delle transizioni temporizzate (0 se immediata)
		o weights:			vettore pesi delle transizioni immediate (0 se temporizzata)
		o priority: 			vettore priorità transizioni (0 se temporizzate)
		o servers: 			vettore numero server delle transizioni
7) Aprire lo script GSPN_main.m e inserire nella riga 21:
	load('FOLDER/MATLAB.mat')
8) Eseguire


**************Istruzioni simulazione di una vecchia rete in FOLDER*******************************

1) Aprire lo script GSPN_main.m e inserire nella riga 21:
	load('FOLDER/MATLAB.mat')
2) Eseguire


**********************************************La cartella contiene***************************************************

> Cartelle vecchie simulazioni: è presente una cartella X per ogni simulazione effettuata e contiene:
	- X.xml: rete di petri (PIPE 4.3.0)
	- X.xlsx: file Excel con le matrici della rete in esame
	- X.mat: MATLAB Data con:
		- filename: path del file X.xlsx
		- indici: matrice 2x9 con la cella iniziale e finale delle matrici presenti nel file X.xlsx

	NOTA: per ogni simulazione tutti i file necessari sono stati chiamati con lo stesso nome "X"

> Script MATLAB
    - GSPN_main.m
        È lo script principale per avviare l'analisi della rete, fa uso delle altre funzioni presenti nella cartella.
        Il file excell corrispondente alla rete da analizzare deve essere presente nella cartella, assieme all'omonimo file.mat

> Funzioni MATLAB
    - Calcolo_Marc_Ragg.m
        Funzione ricorsiva che costruisce la struttura del grafo di raggiungibilità, al suo interno richiama la funzione Crea_Struttura.m
        Ingressi → (a,list,Ragg,I,pre,H, t_pr): 
            a = vettore delle marcature iniziali 
            list = valore attuale dell'elenco degli stati raggiunti (inizialmente è una stringa nulla) 
            Ragg = valore attuale dell'elenco della struttura relativa agli stati 
        Uscite → [list,Ragg]:
            list=elenco aggiornato delle marcature raggiunte 
            Ragg=elenco aggiornato delle strutture relative alle marcature raggiunte

    - Crea_Struttura.m
        Funzione che a partire da una marcatura m calcola un elemento m0 dalla seguente struttura:
            m0.value = marcatura dello stato 
            m0.abi = transizioni abilitate 
            m0.out.num = numero di posti raggiungibili ad un passo dallo stato 
            m0.out.value = stati raggiungibili dallo stato m0
        Ingressi → (m,C,pre,H,t_pr): 
            m = stato iniziale 
            C = matrice di incidenza 
            pre = matrice pre 
            H = matrice di inibizione
            t_pr = vettore delle priorità
        Uscite → [m0,m1]: 
            m0 = struttura suddetta 
            m1 = marcature raggiunte dallo stato m0

    - matrici_pre_I.m
        Funzione utilizzata per caricare nel workspace i seguenti output della funzione
        Uscite → [pre, I, H, M0, m_trans, rates, weights, priority, servers]:
            pre = matrice pre
            I = matrice di incidenza
            H = matrrice di inibizione
            M0 = marcatura iniziale
            m_trans = maschera delle transizioni immediate e temporizzate
            rates = vettore dei rates
            weights = vettore dei pesi
            priority = vettore delle priorità
            servers = vettore dei server
        Per funzionare ha bisogno dei dati contenuti nel workspace corrispondente alla rete da analizzare che contiene gli input della funzione
        Ingressi → (filename,ind):
            filename = nome del file excell da caricare
            ind = indici ai quali prendere le matrici all'interno del file excell
