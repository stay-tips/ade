FROM lscr.io/linuxserver/webtop:arch-i3

# Desktop Telematico: app Eclipse/Java x86_64. Su Arch installiamo il JRE
# corrente più, se ancora in repo, il JRE 8 (runtime storico richiesto AdE).
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

RUN sed -i "s/^#en_US.UTF-8/en_US.UTF-8/; s/^#it_IT.UTF-8/it_IT.UTF-8/" /etc/locale.gen && locale-gen

# All'avvio: copia DT dal volume condiviso al filesystem interno (Eclipse/Derby
# hanno problemi di file locking su virtiofs) e ripristina il bit di esecuzione
RUN mkdir -p /custom-cont-init.d && \
    printf '#!/bin/bash\nif [ -d /config/DT ] && [ ! -d /opt/DT ]; then cp -r /config/DT /opt/DT; fi\nif [ -d /opt/DT ]; then chmod +x /opt/DT/DesktopTelematico; chown -R abc:abc /opt/DT; fi\n' \
      > /custom-cont-init.d/10-desktop-telematico && \
    chmod +x /custom-cont-init.d/10-desktop-telematico && \
    printf '#!/bin/bash\ncd /opt/DT\nexport DISPLAY=:1 LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 _JAVA_AWT_WM_NONREPARENTING=1\nexec ./DesktopTelematico\n' \
      > /usr/local/bin/dt-start && \
    chmod +x /usr/local/bin/dt-start
