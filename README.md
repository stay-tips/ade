# Desktop Telematico in Docker — Guida utente

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

⚠️ Il video-riconoscimento è quasi sempre a pagamento: se hai la CIE, usala per il riconoscimento e non paghi nulla.

### 🔑 Credenziali Fisconline (PIN + password telematica)
Sono **diverse** da SPID: servono a Desktop Telematico per autenticare i file da inviare.

1. Vai su [telematici.agenziaentrate.gov.it](https://telematici.agenziaentrate.gov.it) e accedi con SPID/CIE
2. Apri il **Profilo utente**
3. Visualizza (o genera) il **codice PIN** e imposta la **password telematica**
4. Conservali: li userai dentro Desktop Telematico

### 📦 Il pacchetto Desktop Telematico per Linux
Dall'area riservata: **Servizi → Desktop telematico → Scarica l'applicazione**, versione **Linux 64 bit** (`DesktopTelematico-linux64_*.zip`). Non è incluso in questo repo: è software AdE e ognuno lo scarica dal proprio account.

---

## 2. Installazione (una volta sola)

```bash
git clone git@github.com:stay-tips/ade.git
cd ade/desktop-telematico
docker compose up -d --build        # la prima build richiede qualche minuto
```

Poi:

1. Copia lo zip scaricato dall'AdE nella cartella `desktop-telematico/data/`
2. Apri **http://localhost:3000** con **Chrome** (su macOS evita Safari: lo streaming del desktop non funziona bene)
3. Nel desktop remoto apri un terminale con **Ctrl+Alt+Invio** e scompatta l'app:
   ```bash
   cd /config && mkdir -p DT && unzip DesktopTelematico-linux64_*.zip -d DT
   ```
4. Riavvia il container: `docker compose restart` — al riavvio l'app viene preparata e **si avvia da sola**
5. Nella finestra di Login clicca **"Nuovo utente"** e crea l'utenza locale (nome e password a piacere: proteggono solo i dati nel container, non c'entrano con Fisconline)

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

---

## 4. Inviare un F24: il flusso completo

```
 PIN Fisconline      File F24         Modulo di        File Internet      Ricevuta
 (una volta)    ─►   pronto      ─►   controllo   ─►   autentica     ─►   in area
                     in /config/f24   (0 errori)       e invia            riservata
```

1. **Configura File Internet** (prima volta): dentro Desktop Telematico installa l'applicazione **File Internet** e il **modulo di controllo F24** (menu delle applicazioni), poi inserisci nelle impostazioni codice fiscale, PIN e password telematica
2. **Prepara il file F24** (tracciato telematico) e mettilo in `f24/`
3. **Controlla**: Documenti → Controlla → seleziona il file → esito atteso "0 errori"
4. **Autentica e invia**: File Internet → Autentica → Invia. Annota il protocollo di trasmissione
5. **Ricevuta**: entro qualche ora in area riservata → Ricevute. Scaricala e salvala in `f24/`

⚠️ **L'invio è un versamento vero**: l'importo viene addebitato sull'IBAN indicato nel file alla data di scadenza. Ricontrolla importi e coordinate prima del passo 4.

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
No, se `data/` è intatta: contiene utenza, app e configurazione. Al riavvio tutto viene ripristinato automaticamente.

**Posso pagare l'F24 in un altro modo?**
Sì: F24 Web nell'area riservata AdE (compilazione online, addebito su IBAN) o l'home banking, se la tua banca supporta l'F24. Questo container serve quando vuoi il flusso "da tracciato" completo o hai più deleghe da gestire.

**Funziona su Apple Silicon?**
Sì, via emulazione Rosetta (`platform: linux/amd64`). L'avvio dell'app è più lento (30–60 s); il resto è normale.

---

## Licenza

Questo repo (infrastruttura e script): MIT, vedi [LICENSE](LICENSE). **Desktop Telematico è software dell'Agenzia delle Entrate**, soggetto alle sue condizioni: non è incluso né ridistribuito. Nel repo non viaggiano credenziali né dati fiscali (`data/` e `f24/` sono in `.gitignore`).
