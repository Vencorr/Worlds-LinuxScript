#!/bin/bash
export WINEPREFIX=$HOME/.local/share/wineprefixes/worlds
export WINEARCH=win32
export DIR="$WINEPREFIX/drive_c/Program Files/Worlds/WorldsPlayer by Worlds.com"
export DIREXE="$DIR/run.exe"

start () {
	rm -rf "$DIR/downloads"
	mkdir -p "$DIR/downloads"
	if [ $1 == "fresh" ]; then
		rm -rf $WINEPREFIX
	fi
	download
}

download () {
 cd "$DIR/downloads"
 wget https://github.com/Vencorr/Worlds-LinuxScript/blob/master/files.txt
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
	cd "$DIR/downloads"
	echo "Downloading Java 6u45 Windows i586..."
	#wget --user=$(zenity --forms --title="Oracle Login" --text="An Oracle account is required to download the installer" --add-entry="Email") --password=$(zenity --forms --title="Oracle Login" --text="An Oracle account is required to download the installer" --add-password="Password") https://download.oracle.com/otn/java/jdk/6u45-b06/jre-6u45-windows-i586.exe
	#if ! [ -f "$DIR/downloads/jre-6u45-windows-i586.exe" ]; then
	#	echo "JRE6 installer not found! Aborting!"
	#	exit 1
	#fi
	echo "Installing Worlds 1900. Please complete the setup."
 wine jre-6u23-windows-i586-s /s
	wine Worlds1900.exe /s
	killall run.exe Worlds1900.exe javaw.exe
	audio
}

audio () {
	echo "Setting up Audio prerequisites. Please complete the setups."
	cd "$DIR/downloads"
	wine K-Lite_Codec_Pack_1535_Full.exe /s
	wine LAVFilters-0.74.1-Installer.exe /s
	script
}

script () {
	WORLDSSCRIPT=$HOME/worlds.sh
	rm $WORLDSSCRIPT
	touch "$WORLDSSCRIPT"
	echo "#!/bin/sh" >> "$WORLDSSCRIPT"
	echo "export WINEPREFIX=$WINEPREFIX" >> "$WORLDSSCRIPT"
	echo "export WINEARCH=win32" >> "$WORLDSSCRIPT"
	echo "export DIR=\"$DIR\"" >> "$WORLDSSCRIPT"
	echo "cd \"$DIR\"" >> "$WORLDSSCRIPT"
	echo "rm -rf \"\$DIR/cachedir\"" >> "$WORLDSSCRIPT"
	echo "wine \"\$DIR/run.exe\" $*" >> "$WORLDSSCRIPT"
	chmod +u $WORLDSSCRIPT
	echo "A worlds startup script is available at $WORLDSSCRIPT!"
	echo "Setup done!"
}

start
