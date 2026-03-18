# ControlloAvanzato

# Progetto di Controllo Avanzato, Ottimizzazione e Analisi di Processi

Questo repository contiene il codice, i modelli e la documentazione relativi al progetto finale del corso di _Controllo Avanzato, Ottimizzazione e Analisi di Processi_. L'elaborato documenta in modo chiaro e ordinato le attività svolte, le quali si articolano in due sezioni principali.

## 📝 Descrizione del Progetto

1. **Modellazione di un Processo Produttivo (Reti di Petri)**
   La prima parte riguarda la modellazione di un processo produttivo industriale, sviluppata a partire dall'analisi del video dedicato alla linea di assemblaggio delle autovetture [Skoda Octavia](https://www.youtube.com/watch?v=Tr1B18XJ8Z8). L'obiettivo è descrivere il funzionamento logico del processo, evidenziarne le fasi principali e individuare gli elementi utili alla rappresentazione del sistema per la valutazione delle sue prestazioni.

2. **Model Predictive Control (MPC)**
   La seconda parte è dedicata alla progettazione e alla simulazione di sistemi di controllo predittivo (MPC) in ambiente MATLAB. L'intento è quello di applicare i concetti teorici studiati a casi pratici (es. reattori chimici, sistemi di livello fluidi) per comprendere a fondo il comportamento, il _tuning_ e la reazione ai disturbi di un controllore avanzato.

---

## 📂 Struttura della Repository

Il progetto è organizzato in due cartelle principali per separare agevolmente i due macro-argomenti trattati. Di seguito la struttura della repository con la descrizione di ogni file e cartella:

```text
📦 ControlloAvanzato
 ┣ 📂 Processo_Produttivo_Skoda                            <-- Prima parte del progetto (Reti di Petri)
 ┃ ┣ 📂 File_Pipe                                          <-- File di modellazione per il software PIPE
 ┃ ┃ ┣ 📜 Lavorazione_Laminati.xml                         <-- Prima lavorazione della Rete completa
 ┃ ┃ ┣ 📜 Processo_Produttivo_Skoda_AGV.xml                <-- Rete ridotta caso AGV
 ┃ ┃ ┣ 📜 Processo_Produttivo_Skoda_Buffer_Ridotto.xml     <-- Rete ridotta caso buffer ridotto
 ┃ ┃ ┣ 📜 Processo_Produttivo_Skoda_Classica.xml           <-- Rete ridotta caso classico
 ┃ ┃ ┣ 📜 Processo_Produttivo_Skoda_Guasto.xml             <-- Rete ridotta caso guasto macchina
 ┃ ┃ ┣ 📜 Processo_Produttivo_Skoda_Guasto_AGV.xml         <-- Rete ridotta caso guasto + AGV
 ┃ ┃ ┣ 📜 Processo_Produttivo_Skoda_Guasto_Buffer_Ridotto.xml <-- Rete ridotta caso guasto + buffer ridotto
 ┃ ┃ ┣ 📜 Saldatura.xml                                    <-- Seconda lavorazione della Rete completa
 ┃ ┃ ┗ 📜 Verniciatura.xml                                 <-- Terza lavorazione della Rete completa
 ┃ ┃
 ┃ ┣ 📂 Pipe_Matlab_Indici_di_Prestazione_Classica         <-- Scenario: Linea base (Caso Classico)
 ┃ ┃ ┣ 📂 FOLDER                                           <-- Cartella utilizzata nel codice MATLAB
 ┃ ┃ ┣ 📜 Calcola_Marc_Ragg.m                              <-- Script utilizzato dal Main
 ┃ ┃ ┣ 📜 Crea_Struttura.m                                 <-- Script utilizzato dal Main
 ┃ ┃ ┣ 📜 GSPN_main.m                                      <-- Script Main pesante (simulazione pre-calcolata)
 ┃ ┃ ┣ 📜 Indici_di_Prestazione.m                          <-- Script veloce per calcolare gli indici
 ┃ ┃ ┣ 📜 matrici_pre_I.m                                  <-- Script utilizzato dal Main
 ┃ ┃ ┗ 📜 Workspace_Classica.mat                           <-- Dati grezzi ottenuti dal Main
 ┃ ┃
 ┃ ┣ 📂 AGV                                                <-- Scenario: AGV al posto del muletto
 ┃ ┃ ┗ 📜 ...
 ┃ ┣ 📂 Buffer_ridotto                                     <-- Scenario: Capacità buffer limitata
 ┃ ┃ ┗ 📜 ...
 ┃ ┣ 📂 Guasto                                             <-- Scenario: Presenza di guasto a una macchina
 ┃ ┃ ┗ 📜 ...
 ┃ ┣ 📂 Guasto_AGV                                         <-- Scenario: Guasto combinato con AGV
 ┃ ┃ ┗ 📜 ...
 ┃ ┗ 📂 Guasto_Buffer_ridotto                              <-- Scenario: Guasto combinato con buffer ridotto
 ┃   ┗ 📜 ...
 ┃
 ┣ 📂 Esercizi_MPC                                         <-- Esercizi sviluppati in MATLAB sull'MPC
 ┃ ┣ 📂 es1
 ┃ ┗ 📂 ...
 ┃
 ┗ 📜 README.md                                            <-- Questo file
```

## 🚀 Come utilizzare la Repository

Per testare e riprodurre i risultati del progetto sul proprio ambiente di lavoro, seguire questi passaggi:

1. **Scaricare il codice:** Clonare o scaricare questa repository come file ZIP ed estrarla sul proprio computer.
2. **Calcolo degli Indici di Prestazione (Skoda):** \* Aprire **MATLAB**.
   - Navigare all'interno della cartella `Processo produttivo skoda/` e aprire la sotto-cartella relativa al caso di studio che si desidera analizzare (es. `Classica`).
   - Eseguire lo script denominato `Indici_di_prestazione.m`. Il programma sfrutterà i dati di simulazione già calcolati per stampare istantaneamente a schermo tutti gli indici di performance (Throughput, WIP, MLT, ecc.).
3. **Analisi MPC:** Gli script degli esercizi MPC possono essere eseguiti singolarmente aprendoli in MATLAB per visualizzare l'evoluzione temporale di ingressi e uscite.

---

## 📄 Documentazione Completa

Per qualsiasi ulteriore chiarimento, per l'analisi dettagliata dei grafici o per comprendere le scelte implementative effettuate durante la scrittura del codice, all'interno di questa repository è presente una **Relazione Tecnica completa in formato PDF**. Si raccomanda la lettura del documento per avere una visione approfondita e completa di tutti gli aspetti del progetto.
