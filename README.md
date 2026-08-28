# Desktop Telematico chiavi in mano

Usa **Desktop Telematico** dell'Agenzia delle Entrate (controllo, autenticazione e invio di F24 e dichiarazioni) **dal browser**, senza installare nulla sul tuo computer: l'applicazione gira in un container Docker e tu la vedi su una pagina web.

```
┌─────────────────────┐         ┌──────────────────────────────┐
│  Il tuo computer     │         │  Container Docker            │
│                      │  http   │  ┌────────────────────────┐  │
│  Chrome ────────────────────►  │  │ Desktop Linux (i3)     │  │
│  localhost:3000      │         │  │  └─ Desktop Telematico │  │
│                      │         │  └────────────────────────┘  │
│  cartella data/  ◄──────────────►  /config   (persistente)    │
│  cartella f24/   ◄──────────────►  /config/f24 (scambio file) │
└─────────────────────┘         └──────────────────────────────┘
```

**Per chi è**: contribuenti con partita IVA (o loro delegati) che devono trasmettere file telematici all'Agenzia delle Entrate — tipicamente F24 — e non vogliono installare Java e software datato sulla propria macchina.

---

## 1. Cosa ti serve prima di iniziare

### ✅ Docker
[Docker Desktop](https://www.docker.com/products/docker-desktop/) per macOS o Windows, oppure Docker su Linux. Funziona anche su Mac Apple Silicon (M1–M4).

### 🪪 SPID o CIE (per accedere all'area riservata AdE)
Se non li hai ancora, i percorsi **a costo zero**:

| Strada | Come | Tempi |
|---|---|---|
| **CIE ID** | Se hai la Carta d'Identità Elettronica e il suo PIN (metà consegnata al rilascio, metà arrivata per posta): installa l'app "CIE ID" e sei operativo | subito |
| **SPID con PosteID** | App PosteID → registrazione con riconoscimento via CIE o passaporto elettronico | 1 giorno |
| **SPID con Lepida ID** | Registrazione con CIE/CNS/firma digitale | 1–2 giorni |

Oppure scegli fra uno di questi [provider accreditati](https://www.agid.gov.it/it/piattaforme/spid/identity-provider-accreditati) (elenco ufficiale AgID).

⚠️ Il video-riconoscimento è quasi sempre a pagamento: se hai la CIE, usala per il riconoscimento e non paghi nulla.

### 🔑 Credenziali Fisconline (PIN + password telematica)
Sono **diverse** da SPID: servono a Desktop Telematico per autenticare i file da inviare.

1. Vai su [telematici.agenziaentrate.gov.it](https://telematici.agenziaentrate.gov.it) e accedi con SPID/CIE
2. Apri il **Profilo utente**
3. Visualizza (o genera) il **codice PIN** e imposta la **password telematica**
4. Conservali: li userai dentro Desktop Telematico

---

## 2. Installazione (una volta sola)

```bash
git clone https://github.com/stay-tips/ade.git
cd ade/desktop-telematico
docker compose up -d
```

Tutto qui: viene scaricata l'**immagine già pronta** da Docker Hub, con Desktop Telematico incorporato. Nessuna build, nessun download di software AdE da parte tua.

Poi:

1. Apri **http://localhost:3000** con **Chrome** (su macOS evita Safari: lo streaming del desktop non funziona bene)
2. Desktop Telematico compare da solo entro un minuto
3. Alla prima apertura clicca **"Nuovo utente"** e crea l'utenza locale (nome e password a piacere: proteggono solo i dati nel container, non c'entrano con Fisconline)

Per aggiornare quando esce una nuova immagine: `docker compose pull && docker compose up -d`. (Per i manutentori: `docker-compose.build.yml` ricostruisce l'immagine da zero, anche con un nuovo pacchetto AdE via `--build-arg ADE_DT_URL=...`.)

---

## 3. Uso quotidiano

| Vuoi... | Fai così |
|---|---|
| Aprire il desktop remoto | http://localhost:3000 (Chrome) |
| Avviare Desktop Telematico | parte da solo; manualmente **Ctrl+Alt+t** o `dt-start` da terminale |
| Aprire un terminale | **Ctrl+Alt+Invio** |
| Chiudere una finestra | **Ctrl+Alt+q** |
| Passare file al container | mettili in `data/` → li trovi in `/config` |
| Recuperare tracciati e ricevute F24 | cartella `f24/` ↔ `/config/f24` |
| Spegnere tutto | `docker compose down` (i dati restano in `data/`) |

💡 Su Mac le scorciatoie usano **Ctrl+Option**: Option da solo genera caratteri speciali e non arriva al desktop remoto.

### Le cartelle che usi ogni giorno

```
ade/desktop-telematico/               ← sul tuo computer      nel container
│
├── docker-compose.yml                   avvio/stop
│
├── f24/                              ◄─────────────────────►  /config/f24
│   ├── F24_2026-09.f24                  tracciato da inviare (lo metti tu)
│   ├── F24_2026-09.f24.dgn              esito del controllo (lo crea DT)
│   ├── F24_2026-09.ccf                  file autenticato     (lo crea DT)
│   └── ricevuta_prot_1234.pdf           ricevuta scaricata   (la salvi qui)
│
└── data/                             ◄─────────────────────►  /config
    ├── .Xresources                      DPI dello schermo (Xft.dpi: 168)
    └── .config/i3/config                scorciatoie e autostart

volume Docker "dt-app"                ◄─────────────────────►  /opt/DT
    (non è una cartella visibile)        app, utenza locale, database
```

Regola pratica: **tutto ciò che entra ed esce passa da `f24/`** — il tracciato ce lo metti tu, controlli ed esiti li trovi lì, la ricevuta la salvi lì.

---

## 4. Inviare un F24: il flusso completo

```
                      SUL TUO COMPUTER                NEL DESKTOP REMOTO (container)
                                                              (Desktop Telematico)
 ┌──────────────────┐
 │ gestionale /     │
 │ software di      │
 │ compilazione     │
 └────────┬─────────┘
          │  produce il tracciato
          ▼
 ┌──────────────────┐    visibile come     ┌─────────────────────────────┐
 │  f24/mio.f24     │ ───────────────────► │ 1. Documenti → Controlla    │
 └──────────────────┘   /config/f24        │    esito: 0 errori (.dgn)   │
                                           └──────────────┬──────────────┘
                                                          ▼
                                           ┌─────────────────────────────┐
                              PIN e        │ 2. Documenti → Autentica    │
                              password ──► │    produce il file .ccf     │
                              telematica   └──────────────┬──────────────┘
                                                          ▼
                                           ┌─────────────────────────────┐
                                           │ 3. Documenti → Invia        │
                                           │    ⚠️ da qui il versamento  │
                                           │    è reale → protocollo     │
                                           └──────────────┬──────────────┘
                                                          ▼
 ┌──────────────────┐    la salvi in       ┌─────────────────────────────┐
 │ f24/ricevuta.pdf │ ◄─────────────────── │ 4. Ricevute (entro qualche  │
 └──────────────────┘   /config/f24        │    ora, anche in area AdE)  │
                                           └─────────────────────────────┘
```

1. **Configura File Internet** (prima volta): dentro Desktop Telematico installa l'applicazione **File Internet** e il **modulo di controllo F24** (menu delle applicazioni), poi inserisci nelle impostazioni codice fiscale, PIN e password telematica
2. **Prepara il file F24** (tracciato telematico) e mettilo in `f24/`
3. **Controlla**: Documenti → Controlla → seleziona il file → esito atteso "0 errori"
4. **Autentica e invia**: File Internet → Autentica → Invia. Annota il protocollo di trasmissione
5. **Ricevuta**: entro qualche ora in area riservata → Ricevute. Scaricala e salvala in `f24/`

⚠️ **L'invio è un versamento vero**: l'importo viene addebitato sull'IBAN indicato nel file alla data di scadenza. Ricontrolla importi e coordinate prima del passo 4.

### Dove va messo il tracciato e come si invia

Il **tracciato** è il file telematico dell'F24 (formato definito dalle [specifiche tecniche AdE](https://www.agenziaentrate.gov.it/portale/web/guest/schede/pagamenti/f24/software-f24)), generato dal tuo gestionale o dal software di compilazione.

1. **Mettilo nella cartella `f24/`** accanto al `docker-compose.yml`: dentro il desktop remoto lo trovi in **`/config/f24`**
2. In Desktop Telematico: **Documenti → Controlla** → sfoglia fino a `/config/f24`, seleziona il file e come tipo documento scegli F24 → il controllo deve chiudersi con **0 errori** (l'esito, file `.dgn`, resta accanto al tracciato)
3. **Documenti → Autentica**: seleziona il file controllato; ti verranno chieste le credenziali dei servizi telematici (PIN e password). Viene prodotto il file autenticato `.ccf`
4. **Documenti → Invia** (o dal sito, area riservata → Servizi → Invio, caricando il `.ccf`): annota il **protocollo di trasmissione**
5. La **ricevuta** arriva in area riservata → Ricevute (o Documenti → Ricevute in Desktop Telematico): scaricala in `/config/f24` così te la ritrovi in `f24/` sul tuo computer

Documentazione ufficiale:
- [Pagina del servizio Desktop Telematico](https://www.agenziaentrate.gov.it/portale/servizi/servizitrasversali/altri/desktoptelematico) (Agenzia delle Entrate)
- [Manuale di installazione e gestione](https://telematici.agenziaentrate.gov.it/pdf/Manuale_di_installazione_Desktop_Telematico.pdf) (PDF AdE)
- [Assistenza: gestire il Desktop Telematico](https://assistenza.agenziaentrate.gov.it/portale/gestire-il-desktop-telematico) — installazione applicazioni, controllo, autenticazione, invio e ricevute

### Procedura guidata
Per il primo invio c'è un wizard interattivo che ti accompagna passo-passo (apre le pagine giuste, aspetta le tue conferme, annota il protocollo):

```bash
bash desktop-telematico/wizard-f24.sh
```

---

## 5. Domande frequenti

**Il desktop è nero, è rotto?**
No: i3 a schermo vuoto è così. Apri un terminale con Ctrl+Alt+Invio o aspetta che Desktop Telematico compaia (all'avvio serve fino a un minuto).

**Non riesco a cliccare/digitare nel desktop remoto.**
Ricarica la pagina e usa Chrome. Se il video si blocca spesso, riduci la finestra del browser: meno pixel da trasmettere, stream più fluido.

**I caratteri sono piccolissimi (schermo Retina).**
Modifica `data/.Xresources` (default `Xft.dpi: 168`; prova 144 o 192) e poi `docker compose restart`.

**Alla finestra "Login" non so cosa mettere.**
La prima volta non esiste nessun utente: clicca **Nuovo utente** e crealo tu. Sono credenziali locali del container.

**Ho ricreato il container: ho perso qualcosa?**
No: l'app e i suoi dati (utenza, database, ambiente di sicurezza) vivono nel volume Docker `dt-app`, la configurazione del desktop in `data/`. Si perde tutto solo cancellando esplicitamente il volume (`docker volume rm`).

**Posso pagare l'F24 in un altro modo?**
Sì: F24 Web nell'area riservata AdE (compilazione online, addebito su IBAN) o l'home banking, se la tua banca supporta l'F24. Questo container serve quando vuoi il flusso "da tracciato" completo o hai più deleghe da gestire.

**Funziona su Apple Silicon?**
Sì, via emulazione Rosetta (`platform: linux/amd64`). L'avvio dell'app è più lento (30–60 s); il resto è normale.

---

## Licenza

Questo repo (infrastruttura e script): MIT, vedi [LICENSE](LICENSE). **Desktop Telematico è software dell'Agenzia delle Entrate**, soggetto alle sue condizioni: il repo non lo contiene — l'immagine pubblicata lo incorpora prelevandolo dal server di distribuzione pubblico AdE in fase di build. Nel repo non viaggiano credenziali né dati fiscali (`data/` e `f24/` sono in `.gitignore`).

---

<p align="center">
  Brought to you with ❤️ by the team behind <a href="https://stay.tips"><b>stay.tips</b></a> — <i>the PMS from the future</i>
</p>
