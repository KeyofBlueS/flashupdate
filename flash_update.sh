#!/bin/bash

# Version:    1.0.0
# Author:     KeyofBlueS
# Repository: https://github.com/KeyofBlueS/current-ip
# License:    GNU General Public License v3.0, https://opensource.org/licenses/GPL-3.0

FLASH_ABOUT_LINK=http://get.adobe.com/flashplayer/about/

arch(){
uname -a | grep "x86_64"
if [ $? = 0 ]
then
echo "L'architettura è 64bit"
ARCH="x86_64"
flash_check
else
echo "L'architettura è 32bit"
ARCH="i386"
flash_check
fi
}

#echo -n "Checking dependencies... "
for name in fping curl aria2c tar sed grep gawk 
do
  [[ $(which $name 2>/dev/null) ]] || { echo -en "\n$name è richiesto da questo script. Utilizza 'sudo apt-get install $name'";deps=1; }
done
[[ $deps -ne 1 ]] && echo "" || { echo -en "\nInstalla le dipendenze necessarie e riavvia questo script\n";exit 1; }

rm -f $HOME/.flashplayer-upstream

flash_check(){
while true
do
  fping -r0 -t 3000 get.adobe.com | grep "alive"
  if [ $? = 0 ]; then
	break
  fi
	echo -e "\e[1;34m
get.adobe.com è\e[0m" "\e[1;31mOFFLINE o rete non raggiungibile\e[0m"
	echo -e "\e[1;31mPremi INVIO per uscire, o attendi 1 secondo per riprovare\e[0m"
  if read -t 1 _e; then
        exit 0
  fi
	done
echo -e "\e[1;34m### Controllo aggiornamenti per Adobe Flash Player $ARCH Linux:\e[0m"
	echo -e "\e[1;34m## VERSIONE DI ADOBE FLASH PLAYER ATTUALMENTE INSTALLATA:\e[0m"
	cat /usr/lib/flashplugin-nonfree/readme.txt | grep "Version " | cut -d " " -f2
	echo -e "\e[1;34m## VERSIONE DI ADOBE FLASH PLAYER UPSTREAM:\e[0m"
	curl -s $FLASH_ABOUT_LINK | grep -A4 "Linux" | grep -A2 "Firefox" | sed -e 's/<[^>][^>]*>//g' -e '/^ *$/d' |  tail -n 1 | awk '{print $1}' |tr -d "\r" > $HOME/.flashplayer-upstream
	FLASH_UPSTREAM_VERSION=`cat $HOME/.flashplayer-upstream`
	cat $HOME/.flashplayer-upstream
	echo "--"
cat "/usr/lib/flashplugin-nonfree/readme.txt" | grep "$FLASH_UPSTREAM_VERSION"
if [ $? = 0 ]
then
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
echo -e "\e[1;31m$QUESTION
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
			rm -f $HOME/.flashplayer-upstream
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
	echo "--"
	echo -e "\e[1;34m## Scaricamento versione upstream\e[0m"
	mkdir flashtmp
	cd flashtmp
while true
do
  fping -r0 -t 3000 fpdownload.adobe.com | grep "alive"
  if [ $? = 0 ]; then
	break
  fi
	echo -e "\e[1;34m
fpdownload.adobe.com è\e[0m" "\e[1;31mOFFLINE o rete non raggiungibile\e[0m"
	echo -e "\e[1;31mPremi INVIO per uscire, o attendi 1 secondo per riprovare\e[0m"
  if read -t 1 _e; then
        exit 0
  fi
	done
	aria2c https://fpdownload.adobe.com/get/flashplayer/pdc/$FLASH_UPSTREAM_VERSION/flash_player_npapi_linux."$ARCH".tar.gz
	echo -e "\e[1;34m## Installazione\e[0m"
	tar -zxvf *.tar.gz
	sudo mkdir -p /usr/lib/flashplugin-nonfree/
	sudo mkdir -p /etc/alternatives/
	sudo mkdir -p /usr/lib/mozilla/plugins/
	sudo cp -R ./usr/* /usr/
	sudo cp ./libflashplayer.so /usr/lib/flashplugin-nonfree/
	sudo cp ./readme.txt /usr/lib/flashplugin-nonfree/
	sudo ln -s -f /usr/lib/flashplugin-nonfree/libflashplayer.so /etc/alternatives/flash-mozilla.so
	sudo ln -s -f /etc/alternatives/flash-mozilla.so /usr/lib/mozilla/plugins/flash-mozilla.so
	sudo chmod 644 /usr/lib/flashplugin-nonfree/libflashplayer.so
	sudo chown root:root /usr/lib/flashplugin-nonfree/libflashplayer.so
	rm -Rf $HOME/.adobe/ 2> /dev/null
	rm -Rf $HOME/.macromedia/  2> /dev/null
	cd ..
	rm -rf ./flashtmp
	rm -f $HOME/.flashplayer-upstream
	flash_check
}

desktopfile(){
if [ -e /usr/local/share/applications/flashupdate.desktop ]
then
exit 0
else
echo -e "\e[1;34m## Creating flashupdate.desktop file\e[0m"
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

# Version:    1.0.0
# Author:     KeyofBlueS
# Repository: https://github.com/KeyofBlueS/current-ip
# License:    GNU General Public License v3.0, https://opensource.org/licenses/GPL-3.0

### DESCRIZIONE
Questo script permette di installare ed aggiornare adobe flash player per sistemi Linux

È possibile utilizzare le seguenti opzioni:
--manual      Controlla la versione upstream e chiede all'utente se installare o aggiornare

--automatic   Controlla se la versione locale è presente/differrente da quella upstream, in caso positivo installa quella upstream

--help        Visualizza una descrizione ed opzioni di flashupdate
"
exit 0
}

if [ "$1" = "--manual" ]
then
   STEP=menu
   arch
elif [ "$1" = "--automatic" ]
then
   STEP=flash_updating
   arch
elif [ "$1" = "--help" ]
then
   givemehelp
else
#   STEP=flash_manual_update
   STEP=flash_updating
   arch
fi
