Sonic is the name of a franchise so there are more sonic characters than just Sonic unless you #!/bin/bash
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
   mv Worlds*.exe Worlds.exe
   mv jre*.exe java.exe
   mv K-Lite*.exe K-Lite.exe
   mv LAV*.exe LAV.exe
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
	echo "Installing Worlds 1900. Please complete the setup."
	wine Worlds.exe /s
	killall run.exe Worlds1900.exe javaw.exe
	audio
}

audio () {
	echo "Setting up Audio prerequisites. Please complete the setups."
	cd "$WORLDSDIR/downloads"
	wine K-Lite.exe /s
	wine LAV.exe /s
	script
}

script () {
	mv "$WORLDSDIR/downloads/launch.sh" "$WORLDSDIR/launch.sh"
 	chmod +x "$WORLDSDIR/launch.sh"
 	mv "$WINEPREFIX"/drive_c/Program\ Files/Worlds/WorldsPlayer\ by\ Worlds.com/* "$WINEPREFIX/drive_c/Program Files/Worlds/"
}

start
