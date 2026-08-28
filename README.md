# ade — Desktop Telematico in Docker

Strumenti per usare il software dell'Agenzia delle Entrate senza installare nulla sulla propria macchina.

Il pezzo principale è **[`desktop-telematico/`](desktop-telematico/)**: un container Arch Linux con desktop i3 accessibile dal browser, pronto a far girare **Desktop Telematico** (l'applicazione AdE per controllo, autenticazione e invio dei file telematici: F24, dichiarazioni, ecc.).

## Perché esiste

Desktop Telematico è un'applicazione Eclipse/Java del 2013 che su un sistema moderno non parte più così com'è. Questo container risolve, già preconfigurati, tutti i problemi trovati sul campo:

| Problema | Soluzione nel container |
|---|---|
| La SWT richiede **GTK2**, dismesso dalle distro moderne | gtk2 installato dall'[Arch Linux Archive](https://archive.archlinux.org/) |
| Serve un **locale generato** (altrimenti crash `wcsToMbcs` all'avvio) | `en_US.UTF-8` e `it_IT.UTF-8` generati in build |
| Le app Java mostrano **finestre grigie** sotto window manager tiling | `_JAVA_AWT_WM_NONREPARENTING=1` |
| Eclipse/Derby si corrompono sui **filesystem condivisi** (virtiofs di Docker Desktop) | l'app viene copiata all'avvio su filesystem interno (`/opt/DT`) |
| Lo zip AdE perde il **bit di esecuzione** del launcher | ripristinato automaticamente all'avvio |
| Il **sandbox di pacman** non funziona sotto emulazione | disabilitato in build |
| Su **Apple Silicon** il pacchetto AdE è solo x86_64 | `platform: linux/amd64`, gira via Rosetta |

## Requisiti

- Docker (Docker Desktop su macOS/Windows)
- Il pacchetto **Desktop Telematico per Linux 64 bit** (`DesktopTelematico-linux64_*.zip`), da scaricare con le proprie credenziali dall'[area riservata AdE](https://telematici.agenziaentrate.gov.it) → Desktop telematico. **Non è incluso nel repo**: è software dell'Agenzia delle Entrate e va scaricato dal proprio account.
- Credenziali Fisconline/Entratel (PIN e password telematica) per autenticare e inviare i file. L'accesso all'area riservata richiede SPID o CIE.

## Avvio rapido

```bash
cd desktop-telematico
docker compose up -d --build      # la prima build richiede qualche minuto
```

1. Apri **http://localhost:3000** nel browser (⚠️ su macOS usa **Chrome**: Safari ha problemi con lo streaming del desktop).
2. Copia lo zip di Desktop Telematico in `desktop-telematico/data/` — comparirà nel container come `/config/DesktopTelematico-linux64_*.zip`.
3. Nel desktop remoto apri un terminale (**Ctrl+Alt+Invio**) e scompatta l'app:
   ```bash
   cd /config && mkdir -p DT && unzip DesktopTelematico-linux64_*.zip -d DT
   ```
4. Riavvia il container (`docker compose restart`): al boot l'app viene copiata su `/opt/DT`, sistemata e avviata automaticamente.
5. Alla prima apertura crea l'**utenza locale** (nome e password a piacere: proteggono solo i dati nel container, non c'entrano con Fisconline).

## Uso quotidiano

| Azione | Come |
|---|---|
| Aprire il desktop | http://localhost:3000 (Chrome) |
| Avviare Desktop Telematico | parte da solo al boot; manualmente: `dt-start` da terminale, o **Ctrl+Alt+t** |
| Aprire un terminale | **Ctrl+Alt+Invio** |
| Launcher applicazioni | **Ctrl+Alt+d** |
| Chiudere una finestra | **Ctrl+Alt+q** |
| Scambiare file col container | cartella `data/` ↔ `/config` |
| Tracciati F24 e ricevute | cartella `f24/` ↔ `/config/f24` |
| Fermare tutto | `docker compose down` (i dati in `data/` restano) |

Su Mac le scorciatoie usano **Ctrl+Option**: Option da solo compone caratteri speciali e non arriva al desktop remoto.

I dati persistenti (utenza locale, ambiente di sicurezza, app scompattata) vivono in `data/`, montata su `/config`: il container si può ricostruire senza perdere nulla; basta il riavvio per ricopiare l'app in `/opt/DT`.

## Primo invio F24 guidato

`desktop-telematico/wizard-f24.sh` è una procedura interattiva da terminale che accompagna passo-passo il primo invio di un F24: recupero PIN Fisconline, installazione delle applicazioni (File Internet + modulo di controllo F24), controllo del file, autenticazione, invio e ricevuta.

```bash
bash desktop-telematico/wizard-f24.sh
```

## Note e limiti

- **Prestazioni su Apple Silicon**: l'app gira emulata (Rosetta); l'avvio richiede 30–60 secondi. Tenere la finestra del browser a dimensioni contenute riduce il carico dello streaming video.
- Il **DPI** del desktop remoto è regolabile in `data/.Xresources` (`Xft.dpi: 168` di default per schermi Retina); dopo la modifica serve `docker compose restart`.
- Questo repo contiene solo l'infrastruttura: **nessun software AdE, nessuna credenziale, nessun dato fiscale**. `data/` e `f24/` sono in `.gitignore`.

## Licenza

MIT (vedi [LICENSE](LICENSE)). Desktop Telematico è software dell'Agenzia delle Entrate, soggetto alle sue condizioni d'uso.
