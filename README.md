# flashupdate

# Version:    1.0.0
# Author:     KeyofBlueS
# Repository: https://github.com/KeyofBlueS/flashupdate
# License:    GNU General Public License v3.0, https://opensource.org/licenses/GPL-3.0

### DESCRIZIONE
Questo script permette di installare ed aggiornare adobe flash player per sistemi Linux

### INSTALLAZIONE
```sh
sudo mkdir -p /opt/flash-update/
sudo cp /percorso/dello/script/flash_update.sh /opt/flash-update/flash_update.sh
sudo chmod +x /opt/flash-update/flash_update.sh
sudo ln -s /opt/flash-update/current_ip.sh /usr/local/bin/flashupdate
```

### UTILIZZO
Da terminale digitare:
```sh
flashupdate
```

flashupdate controllerà se la versione locale è presente/differrente da quella upstream, in caso positivo installa quella upstream

È possibile utilizzare le seguenti opzioni:
```sh
--manual      Controlla la versione upstream e chiede all'utente se installare o aggiornare

--automatic   Controlla se la versione locale è presente/differrente da quella upstream, in caso positivo installa quella upstream

--help        Visualizza una descrizione ed opzioni di flashupdate
```
