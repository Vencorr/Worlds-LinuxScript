#!/bin/bash
export WINEPREFIX=$HOME/.local/share/wineprefixes/worlds
export WINEARCH=win32
export DIR="$WINEPREFIX/drive_c/Program Files/Worlds/WorldsPlayer by Worlds.com/"
export DIREXE="$DIR/run.exe"

prefix () {
	echo "Settings up the Wine prefix..."
	wine init
	if ! [ -x "$(command -v winetricks)" ]; then
		echo "Error: 'winetricks' not found! Please add it to your path or install it via your package manager."
		exit 1
	fi
	echo "Self updating winetricks..."
	sudo winetricks --self-update
	echo "Installing components..."
	winetricks gdiplus ddr=gdi glsl=disabled allfonts l3codecx devenum quartz wmp10 ie8 win7
	install
}

install () {
	mkdir -p "$DIR/downloads"
	cd "$DIR/downloads"
	echo "Downloading Java 6u45 Windows i586..."
	wget --user=$(zenity --forms --title="Oracle Login" --text="An Oracle account is required to download the installer" --add-entry="Email") --ask-password https://download.oracle.com/otn/java/jdk/6u45-b06/jre-6u45-windows-i586.exe
	if ! [ -f "$DIR/downloads/jre-6u45-windows-i586.exe" ]; then
		echo "JRE6 installer not found! Aborting!"
		exit 1
	fi
	wine "jre-6u45-windows-i586 /s"
	echo "Downloading Installer..."
	wget "http://cache.worlds.com/downloads/1900/Worlds1900.exe"
	echo "Installing Worlds 1900. Please complete the setup."
	wine "Worlds1900.exe"
	audio
}

audio () {
	echo "Setting up Audio prerequisites..."
	cd "$DIR/downloads"
	wget https://www.dropbox.com/s/el0co8k0n0ps6a2/BCM1043.exe
	wget wget https://github.com/Nevcairiel/LAVFilters/releases/download/0.74.1/LAVFilters-0.74.1-Installer.exe
	wine "$DIR/downloads/BCM1043.exe /s"
	wine "$DIR/downloads/LAVFilters-0.74.1-Installer.exe /s"
	script
}

script () {
	WORLDSSCRIPT=$HOME/worlds.sh
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

prefix
