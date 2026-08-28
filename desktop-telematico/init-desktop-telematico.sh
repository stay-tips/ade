#!/bin/bash
# Prepara Desktop Telematico all'avvio del container.
# L'app è già dentro l'immagine (/opt/DT-pristine, cotta in build): alla prima
# esecuzione viene copiata nel volume persistente /opt/DT, dove restano anche
# utenza locale, database e ambiente di sicurezza. Nessun download a runtime.

set -u

if [ -d /opt/DT-pristine ] && [ ! -e /opt/DT/DesktopTelematico ]; then
  echo "[desktop-telematico] prima esecuzione: preparo l'applicazione..."
  mkdir -p /opt/DT
  cp -a /opt/DT-pristine/. /opt/DT/
fi

if [ -d /opt/DT ]; then
  chmod +x /opt/DT/DesktopTelematico 2>/dev/null
  chown -R abc:abc /opt/DT
  echo "[desktop-telematico] pronto"
fi

# configurazione i3: autostart e scorciatoie (idempotente)
CFG=/config/.config/i3/config
if [ -f "$CFG" ] && ! grep -q "dt-start" "$CFG"; then
  cat >> "$CFG" <<'EOF'

# Desktop Telematico: avvio automatico e scorciatoie (Ctrl+Alt per i Mac)
exec --no-startup-id dt-start
bindsym $mod+t exec --no-startup-id dt-start
bindsym Control+Mod1+Return exec i3-sensible-terminal
bindsym Control+Mod1+t exec --no-startup-id dt-start
bindsym Control+Mod1+d exec --no-startup-id dmenu_run
bindsym Control+Mod1+q kill
EOF
fi
