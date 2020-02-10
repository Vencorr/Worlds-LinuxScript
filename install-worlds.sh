#!/bin/bash
export WORLDSDIR="$(dirname "$(readlink -f "$0")")/Worlds"
export WINEPREFIX="$WORLDSDIR/prefix"
export WINEARCH=win32
export WORLDSINSTALL="$WINEPREFIX/drive_c/Program Files/Worlds"

start () {
	rm -rf "$WORLDSDIR/downloads"
	if [ $1 == "fresh" ]; then
		rm -rf $WORLDSDIR
	fi
	mkdir -p $WORLDSDIR
  	mkdir -p "$WORLDSDIR/downloads"
	download
}

download () {
  	cd "$WORLDSDIR/downloads"
  	wget https://raw.githubusercontent.com/Vencorr/Worlds-LinuxScript/master/files.txt
  	wget -i files.txt
  	prefix
}

prefix () {
  	echo "Installing components..."
	if ! [ -x "$(command -v winetricks)" ]; then
		echo "Error: 'winetricks' not found! Please add it to your path or install it via your package manager."
		exit 1
	fi
	sudo winetricks --self-update
	winetricks win7 corefonts droid ddr=gdi ie8 devenum wmp9 dmsynth wmv9vcm directplay quartz
	install
}

install () {
	cd "$WORLDSDIR/downloads"
	echo "Downloading Java 6u45 Windows i586..."
	echo "Installing Worlds 1900. Please complete the setup."
 	wine jre-6u23-windows-i586-s /s
	wine Worlds1900.exe /s
	killall run.exe Worlds1900.exe javaw.exe
	audio
}

audio () {
	echo "Setting up Audio prerequisites. Please complete the setups."
	cd "$WORLDSDIR/downloads"
	wine K-Lite_Codec_Pack_1535_Full.exe /s
	wine LAVFilters-0.74.1-Installer.exe /s
	script
}

script () {
	mv "$WORLDSDIR/downloads/launch.sh" "$WORLDSDIR/launch.sh"
 	chmod +x "$WORLDSDIR/launch.sh"
 	mv "$WINEPREFIX"/drive_c/Program\ Files/Worlds/WorldsPlayer\ by\ Worlds.com/* "$WINEPREFIX/drive_c/Program Files/Worlds/"
}

start
