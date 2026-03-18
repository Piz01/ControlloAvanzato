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

Il progetto è organizzato in cartelle principali per separare agevolmente i due macro-argomenti trattati:

- **`Processo produttivo skoda/`**
  Questa cartella contiene i file di modellazione per il software **PIPE** e le sotto-cartelle relative ai vari scenari industriali analizzati. Nello specifico, i casi di studio sono suddivisi in:
  - `Classica` (Linea base)
  - `AGV` (Integrazione di veicoli a guida autonoma)
  - `Buffer ridotto`
  - `Guasto`
  - `Guasto + AGV`
  - `Guasto + Buffer ridotto`

  All'interno di ciascuna di queste sotto-cartelle sono presenti gli script MATLAB pre-impostati per calcolare rapidamente gli indici di prestazione della specifica configurazione.

- **`Esercizi MPC/`** _(o nome della cartella che hai usato per l'MPC)_
  Contiene gli script MATLAB, le sessioni salvate (`.mat`) e i controllori progettati tramite l'applicativo _mpcDesigner_.

---

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
