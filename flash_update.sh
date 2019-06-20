#!/bin/bash

# Version:    1.1.8
# Author:     KeyofBlueS
# Repository: https://github.com/KeyofBlueS/flashupdate
# License:    GNU General Public License v3.0, https://opensource.org/licenses/GPL-3.0

# set to "true" to enable autoupdate of this script
UPDATE=true

if echo $UPDATE | grep -Eq '^(true|True|TRUE|si|NO|no)$'; then
echo -e "\e[1;34mControllo aggiornamenti per questo script...\e[0m"
if curl -s github.com > /dev/null; then
	SCRIPT_LINK="https://raw.githubusercontent.com/KeyofBlueS/flashupdate/master/flash_update.sh"
	UPSTREAM_VERSION="$(timeout -s SIGTERM 15 curl -L "$SCRIPT_LINK" 2> /dev/null | grep "# Version:" | head -n 1)"
	LOCAL_VERSION="$(cat "${0}" | grep "# Version:" | head -n 1)"
	REPOSITORY_LINK="$(cat "${0}" | grep "# Repository:" | head -n 1)"
	if echo "$LOCAL_VERSION" | grep -q "$UPSTREAM_VERSION"; then
		echo -e "\e[1;32m
## Questo script risulta aggiornato alla versione upstream
\e[0m
"
	else
		echo -e "\e[1;33m-----------------------------------------------------------------------------------	
## ATTENZIONE: questo script non risulta aggiornato alla versione upstream, visita:
\e[1;32m$REPOSITORY_LINK

\e[1;33m$LOCAL_VERSION (locale)
\e[1;32m$UPSTREAM_VERSION (upstream)
\e[1;33m-----------------------------------------------------------------------------------

\e[1;35mPremi invio per aggiornare questo script o attendi 10 secondi per andare avanti normalmente
\e[1;31m## ATTENZIONE: eventuali modifiche effettuate a questo script verranno perse!!!
\e[0m
"
		if read -t 10 _e; then
			echo -e "\e[1;34m	Aggiorno questo script...\e[0m"
			if [[ -L "${0}" ]]; then
				scriptpath="$(readlink -f "${0}")"
			else
				scriptpath="${0}"
			fi
			if [ -z "${scriptfolder}" ]; then
				scriptfolder="${scriptpath}"
				if ! [[ "${scriptpath}" =~ ^/.*$ ]]; then
					if ! [[ "${scriptpath}" =~ ^.*/.*$ ]]; then
					scriptfolder="./"
					fi
				fi
				scriptfolder="${scriptfolder%/*}/"
				scriptname="${scriptpath##*/}"
			fi
			if timeout -s SIGTERM 15 curl -s -o /tmp/"${scriptname}" "$SCRIPT_LINK"; then
				if [[ -w "${scriptfolder}${scriptname}" ]] && [[ -w "${scriptfolder}" ]]; then
					mv /tmp/"${scriptname}" "${scriptfolder}"
					chown root:root "${scriptfolder}${scriptname}" > /dev/null 2>&1
					chmod 755 "${scriptfolder}${scriptname}" > /dev/null 2>&1
					chmod +x "${scriptfolder}${scriptname}" > /dev/null 2>&1
				elif which sudo > /dev/null 2>&1; then
					while true
					do
					echo -e "\e[1;33mPer proseguire con l'aggiornamento occorre concedere i permessi di amministratore\e[0m"
					if sudo -v; then
						break
					else
						echo -e "\e[1;31mPermesso negato! Premi invio per uscire o attendi 5 secondi per riprovare\e[0m"
						if read -t 5 _e; then
							exit 1
						fi
					fi
					done
					sudo mv /tmp/"${scriptname}" "${scriptfolder}"
					sudo chown root:root "${scriptfolder}${scriptname}" > /dev/null 2>&1
					sudo chmod 755 "${scriptfolder}${scriptname}" > /dev/null 2>&1
					sudo chmod +x "${scriptfolder}${scriptname}" > /dev/null 2>&1
				else
					echo -e "\e[1;31m	Errore durante l'aggiornamento di questo script!
Permesso negato!
\e[0m"
				fi
			else
				echo -e "\e[1;31m	Errore durante il download!
\e[0m"
			fi
			LOCAL_VERSION="$(cat "${0}" | grep "# Version:" | head -n 1)"
			if echo "$LOCAL_VERSION" | grep -q "$UPSTREAM_VERSION"; then
				echo -e "\e[1;34m	Fatto!
\e[0m"
				exec "${scriptfolder}${scriptname}"
			else
				echo -e "\e[1;31m	Errore durante l'aggiornamento di questo script!
\e[0m"
			fi
		fi
	fi
fi
fi

FLASH_ABOUT_LINK=http://get.adobe.com/flashplayer/about/

UNAME="$(uname -a)"
if echo $UNAME | grep -q "x86_64"; then
	echo -e "\e[1;34mL'architettura è 64bit\e[0m"
	ARCH="x86_64"
elif echo $UNAME | grep -q "i686"; then
	echo -e "\e[1;34mL'architettura è 32bit\e[0m"
	ARCH="i386"
else
	echo -e "\e[1;31mATTENZIONE: Architettura non compatibile con Adobe Flash Player!\e[0m"
	exit 1
fi

#echo -n "Checking dependencies... "
for name in awk aria2c curl grep sed tar
do
if which $name > /dev/null; then
	echo -n
else
	if echo $name | grep -xq "awk"; then
		name="gawk"
	fi
	if echo $name | grep -xq "aria2c"; then
		name="aria2"
	fi
	if [ -z "${missing}" ]; then
		missing="$name"
	else
		missing="$missing $name"
	fi
fi
done
if ! [ -z "${missing}" ]; then
	echo -e "\e[1;31mQuesto script dipende da \e[1;34m$missing\e[1;31m. Utilizza \e[1;34msudo apt-get install $missing
\e[1;31mInstalla le dipendenze necessarie e riavvia questo script.\e[0m"
	exit 1
fi

flash_check(){
while true
do
if curl -s get.adobe.com > /dev/null; then
	break
else
	echo -e "\e[1;34m
get.adobe.com è\e[0m" "\e[1;31mOFFLINE o rete non raggiungibile
Premi INVIO per uscire, o attendi 1 secondo per riprovare\e[0m"
	if read -t 1 _e; then
		exit 0
	fi
fi
done
echo -e "\e[1;34m### Controllo aggiornamenti per Adobe Flash Player $ARCH Linux:
## VERSIONE DI ADOBE FLASH PLAYER ATTUALMENTE INSTALLATA:\e[0m"
cat /usr/lib/flashplugin-nonfree/readme.txt | grep "Version " | awk '{print $2}'
echo -e "\e[1;34m## VERSIONE DI ADOBE FLASH PLAYER UPSTREAM:\e[0m"
FLASH_UPSTREAM_VERSION="$(curl -s $FLASH_ABOUT_LINK | grep -A4 "Linux" | grep -A2 "Firefox" | sed -e 's/<[^>][^>]*>//g' -e '/^ *$/d' | tail -n 1 | awk '{print $1}' | tr -d "\r")"
echo "$FLASH_UPSTREAM_VERSION
--"
if cat "/usr/lib/flashplugin-nonfree/readme.txt" | grep -q "$FLASH_UPSTREAM_VERSION"; then
	echo -e "\e[1;34m## Adobe Flash Player risulta aggiornato alla versione upstream.\e[0m"
	QUESTION="Vuoi forzare l'aggiornamento?"
	#exit 0
	menu
else
	echo -e "\e[1;34m## Adobe Flash Player non risulta aggiornato alla versione upstream.\e[0m"
	QUESTION="Vuoi procedere con l'aggiornamento?"
	$STEP
fi
}

menu(){
echo -e "\e[1;35m$QUESTION
(A)ggiorna
(E)sci\e[0m"
read -p "Scelta (A/E): " testo

case $testo in
    A|a)
	{
	echo -e "\e[1;34m
## HAI SCELTO DI AGGIORNARE ADOBE FLASH PLAYER\e[0m"
	flash_updating
	}
    ;;
    E|e|"")
	{
	echo -e "\e[1;34mEsco dal programma\e[0m"
	desktopfile
	}
    ;;
    *)
	echo -e "\e[1;31m## HAI SBAGLIATO TASTO.......cerca di stare un po' attento\e[0m"
	flash_manual_update
    ;;
esac
}

flash_updating(){
echo -e "\e[0;32m--
\e[1;34m## Scaricamento versione upstream\e[0m"
while true
do
if curl -s fpdownload.adobe.com > /dev/null; then
	break
else
	echo -e "\e[1;34m
fpdownload.adobe.com è\e[0m" "\e[1;31mOFFLINE o rete non raggiungibile
Premi INVIO per uscire, o attendi 1 secondo per riprovare\e[0m"
	if read -t 1 _e; then
	exit 0
	fi
fi
done
aria2c -d /tmp/flashtmp https://fpdownload.adobe.com/get/flashplayer/pdc/$FLASH_UPSTREAM_VERSION/flash_player_npapi_linux."$ARCH".tar.gz
echo -e "\e[1;34m## Installazione\e[0m"
tar -C /tmp/flashtmp/ -zxvf /tmp/flashtmp/flash_player_npapi_linux."$ARCH".tar.gz
while true
do
echo -e "\e[1;33mPer proseguire con l'aggiornamento occorre concedere i permessi di amministratore\e[0m"
if sudo -v; then
	break
else
	echo -e "\e[1;31mPermesso negato! Premi invio per uscire o attendi 5 secondi per riprovare\e[0m"
	if read -t 5 _e; then
		rm -rf /tmp/flashtmp 2> /dev/null
		exit 1
	fi
fi
done
sudo mkdir -p /usr/lib/flashplugin-nonfree/
sudo mkdir -p /etc/alternatives/
sudo mkdir -p /usr/lib/mozilla/plugins/
sudo cp -R /tmp/flashtmp/usr/* /usr/
sudo cp /tmp/flashtmp/libflashplayer.so /usr/lib/flashplugin-nonfree/
sudo cp /tmp/flashtmp/readme.txt /usr/lib/flashplugin-nonfree/
sudo ln -s -f /usr/lib/flashplugin-nonfree/libflashplayer.so /etc/alternatives/flash-mozilla.so
sudo ln -s -f /etc/alternatives/flash-mozilla.so /usr/lib/mozilla/plugins/flash-mozilla.so
sudo chmod 644 /usr/lib/flashplugin-nonfree/libflashplayer.so
sudo chown root:root /usr/lib/flashplugin-nonfree/libflashplayer.so
rm -Rf $HOME/.adobe/ 2> /dev/null
rm -Rf $HOME/.macromedia/ 2> /dev/null
rm -rf /tmp/flashtmp 2> /dev/null
flash_check
}

desktopfile(){
if [ -e /usr/local/share/applications/flashupdate.desktop ]; then
	exit 0
else
	while true
	do
	echo -e "\e[1;34m## Creating flashupdate.desktop file
\e[1;33mPer proseguire occorre concedere i permessi di amministratore\e[0m"
		if sudo -v; then
			break
		else
			echo -e "\e[1;31mPermesso negato! Premi invio per uscire o attendi 5 secondi per riprovare\e[0m"
			if read -t 5 _e; then
				exit 1
			fi
		fi
	done
	sudo sh -c 'echo "
[Desktop Entry]
Name=Adobe Flash Player Updater
Exec=flashupdate
Icon=flash-player-properties
Terminal=true
Type=Application
StartupNotify=true
Categories=Settings;GNOME;GTK;X-GNOME-PersonalSettings;
NotShowIn=KDE;" > /usr/local/share/applications/flashupdate.desktop'
	exit 0
fi
}

givemehelp(){
echo "
# flashupdate

# Version:    1.1.8
# Author:     KeyofBlueS
# Repository: https://github.com/KeyofBlueS/flashupdate
# License:    GNU General Public License v3.0, https://opensource.org/licenses/GPL-3.0

### DESCRIZIONE
Questo script permette di installare ed aggiornare adobe flash player per sistemi Linux

### UTILIZZO
È possibile utilizzare le seguenti opzioni:
--manual      Controlla la versione upstream e chiede all'utente se installare o aggiornare

--automatic   Controlla se la versione locale è presente/differrente da quella upstream, in caso positivo installa quella upstream

--help        Visualizza una descrizione ed opzioni di flashupdate
"
exit 0
}

if [ "$1" = "--manual" ]; then
	STEP=menu
	flash_check
elif [ "$1" = "--automatic" ]; then
	STEP=flash_updating
	flash_check
elif [ "$1" = "--help" ]; then
	givemehelp
else
#	STEP=flash_manual_update
	STEP=flash_updating
	flash_check
fi
