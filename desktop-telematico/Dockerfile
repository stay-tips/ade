FROM lscr.io/linuxserver/webtop:arch-i3

# Il sandbox seccomp di pacman non funziona sotto emulazione (Rosetta/qemu)
RUN sed -i '/^\[options\]/a DisableSandbox' /etc/pacman.conf && \
    pacman -Sy --noconfirm --needed \
      jre-openjdk \
      gtk3 \
      webkit2gtk-4.1 \
      unzip \
      wget && \
    (pacman -S --noconfirm --needed jre8-openjdk || true) && \
    pacman -Scc --noconfirm

# La SWT di Desktop Telematico (era Eclipse 4.3) richiede GTK2, dismesso dai
# repo Arch: si installa dall'Arch Linux Archive (atk è fornito da at-spi2-core)
RUN curl -sfLo /tmp/gtk2.pkg.tar.zst \
      "https://archive.archlinux.org/packages/g/gtk2/gtk2-2.24.33-3-x86_64.pkg.tar.zst" && \
    pacman -U --noconfirm --needed /tmp/gtk2.pkg.tar.zst && \
    rm /tmp/gtk2.pkg.tar.zst

# Locale: senza, SWT crasha all'avvio (wcsToMbcs)
RUN sed -i "s/^#en_US.UTF-8/en_US.UTF-8/; s/^#it_IT.UTF-8/it_IT.UTF-8/" /etc/locale.gen && locale-gen

# I server di download AdE non inviano l'intermedio TLS (Sectigo OV R36)
COPY sectigo-ov-r36.pem /etc/ca-certificates/trust-source/anchors/
RUN update-ca-trust

# Desktop Telematico viene scaricato dal server pubblico AdE e COTTO
# NELL'IMMAGINE in fase di build: a runtime il container non scarica nulla.
# ADE_DT_URL può essere aggiornato a nuove versioni con --build-arg.
ARG ADE_DT_URL="https://swdownload1.agenziaentrate.gov.it/repos/DesktopTelematico-linux64_140.zip"
RUN curl -sfL "$ADE_DT_URL" -o /tmp/dt.zip && \
    mkdir -p /opt/DT-pristine && \
    unzip -oq /tmp/dt.zip -d /opt/DT-pristine && \
    chmod +x /opt/DT-pristine/DesktopTelematico && \
    rm /tmp/dt.zip

# All'avvio: popola il volume dell'app alla prima esecuzione (vedi init script)
COPY init-desktop-telematico.sh /custom-cont-init.d/10-desktop-telematico
RUN chmod +x /custom-cont-init.d/10-desktop-telematico && \
    printf '#!/bin/bash\ncd /opt/DT\nexport DISPLAY=:1 LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 _JAVA_AWT_WM_NONREPARENTING=1\nexec ./DesktopTelematico\n' \
      > /usr/local/bin/dt-start && \
    chmod +x /usr/local/bin/dt-start
