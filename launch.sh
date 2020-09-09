#!/bin/bash
export TITLE="Worlds Linux"
export WORLDSDIR="$(dirname "$(readlink -f "$0")")"
export WINEPREFIX=$WORLDSDIR/prefix
export WORLDSINSTALL="$WINEPREFIX/drive_c/Program Files/Worlds/WorldsPlayer by Worlds.com"
export SETTHEME="DEFAULT"
export WINE="/usr/bin/wine"

mkdir -p $WORLDSDIR/backups $WORLDSDIR/themes

if [ -f "$WORLDSDIR/wrldslinux" ]; then
	source "$WORLDSDIR/wrldslinux"
fi
cd "$WORLDSINSTALL"

main() {
	if [[ -f "$WORLDSDIR/.update.sh" ]]; then
		rm "$WORLDSDIR/.update.sh"
	fi
	sel=$(zenity \
		--list \
		--title="$TITLE" \
		--window-icon="$WORLDSDIR/icon.png" \
		--width=300 \
		--height=360 \
		--cancel-label='Quit' \
		--radiolist \
		--text 'WorldsPlayer Linux' \
		--column '' \
		--column 'Options' \
		--hide-header \
		  TRUE 'Launch Worlds' \
		  FALSE 'Launch Worlds with Logger' \
		  FALSE 'Worlds Organizer' \
		  FALSE 'Open Worlds folder' \
		  FALSE 'Settings' \
		  FALSE 'Clear Cache' \
		  FALSE 'Force Kill' \
		  FALSE 'Update' \
		  FALSE 'Open Github page' 2>/dev/null)
	case $sel in
		'Launch Worlds')
			launch ;;
		'Launch Worlds with Logger')
			launch && tail -F "$WORLDSINSTALL/Gamma.Log.open" | zenity --text-info --auto-scroll --height=480 --width=768 --title="$TITLE - Log" --window-icon="$WORLDSDIR/icon.png" --text="Gamma.Log.open" ;;
		'Worlds Organizer')
			if [[ ! -f "$WORLDSDIR/WorldsOrganizer.jar" ]]; then
				wget -O"$WORLDSDIR/WorldsOrganizer.jar" "https://wirlaburla.site/projects/WorldsOrganizer/dw/0.9.64/WorldsOrganizer-linux.jar"
			fi
			java -jar "$WORLDSDIR/WorldsOrganizer.jar"
			main ;;
		'Open Worlds folder')
			gio open "$WORLDSINSTALL" ;;
		'Settings' )
			settings
			main ;;
		'Clear Cache')
			cache
			main ;;
		'Force Kill' )
			killw
			main ;;
		'Update' )
			update ;;
		'Open Github page' )
			xdg-open "https://github.com/Vencorr/Worlds-LinuxScript"
			main ;;
	esac
	if [ "$?" != 0 ]
	then
		exit
	fi
}

launch () {
	source "$WORLDSDIR/wrldscmd"
	WORLDSNEW="WorldsPlayer.exe"
	WORLDSOLD="run.exe"
	WORLDSLEGACY="run.bat"
	if [ -f "$WORLDSINSTALL/$WORLDSNEW" ]; then
		$WINE "$WORLDSINSTALL/$WORLDSNEW"
	elif [ -f "$WORLDSINSTALL/$WORLDSOLD" ]; then
		$WINE "$WORLDSINSTALL/$WORLDSOLD"
	else
		$WINE cmd /c "$WORLDSINSTALL/$WORLDSLEGACY"
	fi
}

settings () {
	SETSEL=$(zenity --list --title="$TITLE - Settings" --text="Settings for Worlds Linux" --column='Option' --column='Value' --cancel-label="Back" --width=540 --height=360 --window-icon="$WORLDSDIR/icon.png" \
		"Wine Location" "$WINE" \
		"Prefix Location" "$WINEPREFIX" \
		"Worlds Location" "$WORLDSINSTALL" \
		"Edit worlds.ini" "" \
		"Wine Configuration" "" \
        "Winetricks" "" \
		"Set Theme" "$SETTHEME" \
		"Backup" "" \
		"Restore" "" \
		2>/dev/null)
	case $SETSEL in
		'Wine Location')
			WINESEL=$(zenity --entry --title="$WTITLE - Wine Binary Location" --text="Path to wine binary" --entry-text="$WINE" --window-icon="$WORLDSDIR/icon.png")
			if [[ ! $? -eq 1 ]]; then
				export WINE=$WINESEL
			fi
			settings ;;
		'Prefix Location')
			PREFSEL=$(zenity --entry --title="$WTITLE - Wine Prefix Location" --text="Path to Wine Prefix." --entry-text="$WINEPREFIX" --window-icon="$WORLDSDIR/icon.png")
			if [[ ! $? -eq 1 ]]; then
				export WINEPREFIX=$PREFSEL
			fi
			settings ;;
		'Worlds Location')
			WORLDSEL=$(zenity --entry --title="$WTITLE - Worlds Location" --text="Path to Worlds Folder" --entry-text="$WORLDSINSTALL" --window-icon="$WORLDSDIR/icon.png")
			if [[ ! $? -eq 1 ]]; then
				export WORLDSINSTALL=$WORLDSEL
			fi
			settings ;;
		'Edit worlds.ini')
			xdg-open "$WORLDSINSTALL/worlds.ini"
			settings ;;
		'Wine Configuration')
			"$WINE"cfg
			settings ;;
        'Winetricks')
			winetricks
			settings ;;
		'Set Theme')
			theme
			settings ;;
		'Backup')
			backup
			settings ;;
		'Restore')
			restore
			settings ;;
	esac
	echo "# Configuration for Worlds on Linux." > "$WORLDSDIR/wrldslinux"
	echo "export WINE=\"$WINE\"" >> "$WORLDSDIR/wrldslinux"
	echo "export WINEPREFIX=\"$WINEPREFIX\"" >> "$WORLDSDIR/wrldslinux"
	echo "export WORLDSINSTALL=\"$WORLDSINSTALL\"" >> "$WORLDSDIR/wrldslinux"
	echo "export SETTHEME=\"$SETTHEME\"" >> "$WORLDSDIR/wrldslinux"
	echo "source \"$WORLDSDIR/wrldscmd\"" >> "$WORLDSDIR/wrldslinux"
}

theme () {
	declare -a acceptimg=(
		"actb.gif"
		"actm.gif"
		"actt.gif"
		"back.gif"
		"changeav.gif"
		"drive.gif"
		"dyrwtq.gif"
		"explore.gif"
		"friends.gif"
		"hangong.gif"
		"mfriends.gif"
		"moreinfo.gif"
		"notavail.gif"
		"opnscrnc.gif"
		"override.ini"
		"pwc.gif"
		"quit.gif"
		"rtpanel.gif"
	)
	declare -A map
	for key in "${!acceptimg[@]}"; do map[${acceptimg[$key]}]="$key"; done


	mkdir -p "$WORLDSDIR/themes"
	cd "$WORLDSDIR/themes"
	# Due to some bug, this won't even accept a directory despite the option being defined. Instead using text entry.
	# seltheme=$(zenity --file-selection --directory --title="Select a theme folder" --window-icon="$WORLDSDIR/icon.png")
	seltheme=$(zenity --entry --title="$WTITLE - Worlds Theme" --text="Enter a theme directory." --entry-text="$WORLDSDIR/themes/" --window-icon="$WORLDSDIR/icon.png")
	if [[ ! $? -eq 1 ]]; then
		rename 'y/A-Z/a-z/' "$seltheme/*"
		for i in $seltheme/*;
			do FILENAME="$(basename $i)"
			if [[ -n "${map[$i]}" ]]; then
				echo "$seltheme/$FILENAME >> $WORLDSINSTALL/$FILENAME"
				ln -sf "$seltheme/$FILENAME" "$WORLDSINSTALL/$FILENAME"
			fi
		done
		export SETTHEME="$(basename $seltheme)"
		zenity --info --text="Successfully set theme to $(basename $seltheme)." --width=240 --height=40  --title="$TITLE - Theme" --window-icon="$WORLDSDIR/icon.png"
	else
		zenity --error --text="Couldn't set $(basename $seltheme). Does it exist?" --width=240 --height=40  --title="$TITLE - Theme" --window-icon="$WORLDSDIR/icon.png"
	fi
	cd "$WORLDSINSTALL"
	settings
}

backup () {
	mkdir -p "$WORLDSDIR/backups"
	bkup=$(zenity  --file-selection --title="$TITLE - Backup" --text="Select Backup folder to backup to" --directory --filename="$WORLDSDIR/backups/" --save --confirm-overwrite --window-icon="$WORLDSDIR/icon.png")
	if [[ ! $? -eq 1 ]]; then
		cp -r "$WORLDSINSTALL/worlds.ini" "$bkup/worlds.ini"
		cp -r "$WORLDSINSTALL/gamma.avatars" "$bkup/gamma.avatars"
		cp -r "$WORLDSINSTALL/gamma.worldsmarks" "$bkup/gamma.worldsmarks"
		if [[ $? -eq 1 ]]; then
			zenity --error --text="Could not backup files." --width=240 --height=40  --title="$TITLE - Backup" --window-icon="$WORLDSDIR/icon.png"
		else
			zenity --info --text="Personal world files successfully backed up." --width=240 --height=40  --title="$TITLE - Backup" --window-icon="$WORLDSDIR/icon.png"
		fi
	fi
}

restore () {
	mkdir -p "$WORLDSDIR/backups"
	rbkup=$(zenity  --file-selection --title="Select Backup folder to restore from" --directory --filename="$WORLDSDIR/backups/" --window-icon="$WORLDSDIR/icon.png")
	if [[ ! $? -eq 1 ]]; then
		cp -r "$rbkup/worlds.ini" "$WORLDSINSTALL/worlds.ini"
		cp -r "$rbkup/gamma.avatars" "$WORLDSINSTALL/gamma.avatars"
		cp -r "$rbkup/gamma.worldsmarks" "$WORLDSINSTALL/gamma.worldsmarks"
		if [[ $? -eq 1 ]]; then
			zenity --error --text="Could not restore files." --width=240 --height=40  --title="$TITLE - Restore" --window-icon="$WORLDSDIR/icon.png"
		else
			zenity --info --text="Personal world files successfully restored." --width=240 --height=40 --title="$TITLE - Restore" --window-icon="$WORLDSDIR/icon.png"
		fi
	fi
}

cache () {
	CDSIZE=$(du -sh "$WORLDSINSTALL/cachedir" | cut -f1)
	if [ -d "$WORLDSINSTALL/cachedir" ]; then
		rm -rf "$WORLDSINSTALL/cachedir" | zenity --progress --no-buttons --text="Removing cachedir..." -title="$TITLE - Removing Cachedir" --window-icon="$WORLDSDIR/icon.png" --auto-close --auto-kill
		if [ ! -d "$WORLDSINSTALL/cachedir" ]; then
			zenity --info --text="$CDSIZE were successfully cleared." --width=240 --height=40 --title="$TITLE - Cachedir" --window-icon="$WORLDSDIR/icon.png"
		else
			zenity --error --text="Something went wrong." --width=240 --height=40 --title="$TITLE - Cachedir" --window-icon="$WORLDSDIR/icon.png"
		fi
	else
		zenity --error --text="Cachedir doesn't exist! Was it already cleared?" --width=240 --height=40 --title="$TITLE - Cachedir" --window-icon="$WORLDSDIR/icon.png"
	fi
}

update () {
	NEWLAUNCHFILE="https://raw.githubusercontent.com/Vencorr/Worlds-LinuxScript/master/launch.sh"
	UPDATEFILE="$WORLDSDIR/.update.sh"
	touch "$UPDATEFILE"
	echo "wget -N -O\"$WORLDSDIR/launch.sh\" \"$NEWLAUNCHFILE\"" >> "$UPDATEFILE"
	echo "chmod +x \"$WORLDSDIR/launch.sh\"" >> "$UPDATEFILE"
	echo "\"$WORLDSDIR/launch.sh\"" >> "$UPDATEFILE"
	chmod +x "$UPDATEFILE"
	sh "$UPDATEFILE"
}

killw () {
	killall WorldsPlayer.exe run.exe javaw.exe jrew.exe run.bat | zenity --progress --no-buttons --title="$TITLE - Killing Processes" --width=300 --height=50 --auto-close --auto-kill
	zenity --error --text="Killed all possible running processes of Worlds." --width=240 --height=40 --title="$TITLE - Kill" --window-icon="$WORLDSDIR/icon.png"
}

main
