# flashupdate

# Version:    1.1.8
# Author:     KeyofBlueS
# Repository: https://github.com/KeyofBlueS/flashupdate
# License:    GNU General Public License v3.0, https://opensource.org/licenses/GPL-3.0

### DESCRIZIONE
Questo script permette di installare ed aggiornare adobe flash player per sistemi Linux

### INSTALLAZIONE
```sh
curl -o /tmp/flash_update.sh 'https://raw.githubusercontent.com/KeyofBlueS/flashupdate/master/flash_update.sh'
sudo mkdir -p /opt/flash-update/
sudo mv /tmp/flash_update.sh /opt/flash-update/
sudo chown root:root /opt/flash-update/flash_update.sh
sudo chmod 755 /opt/flash-update/flash_update.sh
sudo chmod +x /opt/flash-update/flash_update.sh
sudo ln -s /opt/flash-update/flash_update.sh /usr/local/bin/flashupdate
```

### UTILIZZO
Da terminale digitare:
```sh
$ flashupdate
```

flashupdate controllerà se la versione locale è presente/differrente da quella upstream, in caso positivo installa quella upstream

Al primo avvio creerà un avviatore in Applicazioni > Impostazioni > Adobe Flash Player Updater

È possibile utilizzare le seguenti opzioni:
```
--manual      Controlla la versione upstream e chiede all'utente se installare o aggiornare

--automatic   Controlla se la versione locale è presente/differrente da quella upstream, in caso positivo installa quella upstream

--help        Visualizza una descrizione ed opzioni di flashupdate
```
