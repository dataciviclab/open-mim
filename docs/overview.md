# Overview - Scuola statale italiana (MIM)

## Cos'è il dataset

Questo progetto organizza i dati pubblici del Ministero dell'Istruzione e del
Merito (MIM) sulla scuola statale italiana. Il primo dataset copre il **corpo
docente a tempo indeterminato**: quanti sono, per provincia, ordine scolastico,
tipo posto e fascia d'età, e come cambia la loro composizione nel tempo.

## Unità di analisi e chiavi

- unità di analisi: provincia × ordine scolastico × tipo posto × fascia d'età
- granularità temporale: anno scolastico (a.s. 2016/17 → 2024/25)
- chiavi principali: `anno`, `provincia`, `ordine_scuola`, `tipo_posto`, `fascia_eta`

## Copertura

- anni coperti: a.s. 2016/17 → 2024/25 (9 anni scolastici)
- territorio coperto: 104 province italiane (scuola statale)
- note sulla copertura: esclusa la scuola dell'infanzia paritaria e le scuole
  delle province autonome non equiparate; escluso l'a.s. 2015/16 per un
  prefisso file diverso (`AS1516DOCTIT`)

## Domande civiche che puoi esplorare

- come varia la quota di docenti donne tra ordini e territori
- quanto è invecchiato il corpo docente (fasce d'età) in ogni provincia
- dove il sostegno pesa di più sull'organico docente
- quali province perdono o guadagnano docenti di ruolo nel tempo
- come si confronta il proprio territorio con la media nazionale

## Limiti e caveat

- i dati sono aggregati per provincia: non permettono analisi a livello di
  singola scuola o comune
- la provincia è una **denominazione testuale**, non un codice ISTAT: i join
  territoriali richiedono una normalizzazione esplicita
- le definizioni MIM possono cambiare tra un anno scolastico e l'altro
- il dataset descrive i titolari, non i supplenti: la lettura dell'organico
  completo richiede i dataset successivi (roadmap in README)

## Metodo

Il progetto organizza i dati in tre passaggi: raccolta del CSV ufficiale MIM,
pulizia e normalizzazione (clean), produzione di tabelle finali (mart) per
analisi e output pubblici. Per dettagli tecnici, vedi il repository Toolkit
DataCivicLab.
