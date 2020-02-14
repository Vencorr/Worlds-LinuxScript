#!/bin/bash
export TITLE="Worlds Linux Wrapper"
export WORLDSDIR="$(dirname "$(readlink -f "$0")")"
export WINEPREFIX=$WORLDSDIR/prefix
export WORLDSINSTALL="$WINEPREFIX/drive_c/Program Files/Worlds/"
export WINEARCH=win32
cd "$WORLDSINSTALL"
mkdir -p $WORLDSDIR/backups $WORLDSDIR/themes

export WINE=$(which wine)

main() {
  sel=$(zenity \
		--title="$TITLE" \
		--window-icon="$WORLDSDIR/icon.png" \
		--width=360 \
		--height=280 \
		--cancel-label='Exit' \
		--list \
		--text 'WorldsPlayer Linux Wrapper' \
		--radiolist \
		--column '' \
		--column 'Options' \
		TRUE 'Start Worlds' \
		FALSE 'Open Worlds folder' \
		FALSE 'Edit worlds.ini' \
		FALSE 'Backup Worlds files' \
		FALSE 'Restore from backup' \
		FALSE 'Set theme' \
		FALSE 'Clear Cache' \
		FALSE 'FORCE KILL' 2>/dev/null )
  	case $sel in
  'Start Worlds')
  	$WINE "$WORLDSINSTALL/run.exe" ;;
  'Open Worlds folder')
  	gio open "$WORLDSINSTALL"
  	main ;;
  'Edit worlds.ini')
	xdg-open "$WORLDSINSTALL/worlds.ini"
	main ;;
  'Backup Worlds files')
	mkdir -p "$WORLDSDIR/backups"
    	bkup=$(zenity  --file-selection --title="Select Backup folder to backup to" --directory --filename="$WORLDSDIR/backups/" --save)
    	if [[ $? -eq 1 ]]; then
	      	main
    	else
	      	cp -r "$WORLDSINSTALL/worlds.ini" "$bkup/worlds.ini"
      		cp -r "$WORLDSINSTALL/gamma.avatars" "$bkup/gamma.avatars"
      		cp -r "$WORLDSINSTALL/gamma.worldsmarks" "$bkup/gamma.worldsmarks"
      		if [[ $? -eq 1 ]]; then
        		zenity --error --text="Could not successfully backup files." --width=240 --height=40  --title="$TITLE - Backup"
      		else
        		zenity --info --text="Personal world files successfully backed up." --width=240 --height=40  --title="$TITLE - Backup"
      		fi
      	main
    	fi ;;
  'Restore from backup')
    mkdir -p "$WORLDSDIR/backups"
    rbkup=$(zenity  --file-selection --title="Select Backup folder to restore from" --directory --filename="$WORLDSDIR/backups/")
    if [[ $? -eq 1 ]]; then
      main
    else
      cp -r "$rbkup/worlds.ini" "$WORLDSINSTALL/worlds.ini"
      cp -r "$rbkup/gamma.avatars" "$WORLDSINSTALL/gamma.avatars"
      cp -r "$rbkup/gamma.worldsmarks" "$WORLDSINSTALL/gamma.worldsmarks"
      if [[ $? -eq 1 ]]; then
        zenity --error --text="Could not successfully restore files." --width=240 --height=40  --title="$TITLE - Restore"
      else
        zenity --info --text="Personal world files successfully restored." --width=240 --height=40 --title="$TITLE - Restore"
      fi
      main
    fi ;;
  'Set theme' )
    mkdir -p "$WORLDSDIR/themes"
    seltheme=$(zenity  --file-selection --title="Select a theme folder" --directory --filename="$WORLDSDIR/themes/")
    if [[ $? -eq 1 ]]; then
      main
    else
      for i in $seltheme/*;
        do FILENAME="$(basename $i)"
        echo "$seltheme/$FILENAME >> $WORLDSINSTALL/$FILENAME"
        ln -sf "$seltheme/$FILENAME" "$WORLDSINSTALL/$FILENAME"
      done
      zenity --info --text="Successfully set theme to $(basename $seltheme)." --width=240 --height=40  --title="$TITLE - Theme"
      main
    fi ;;
  'Clear Cache')
    	CDSIZE=$(du -sh "$WORLDSINSTALL/cachedir" | cut -f1)
    	if [ -d "$WORLDSINSTALL/cachedir" ]; then
      		rm -rf "$WORLDSINSTALL/cachedir"
      	if [ ! -d "$WORLDSINSTALL/cachedir" ]; then
        	zenity --info --text="$CDSIZE were successfully cleared." --width=240 --height=40 --title="$TITLE - Cachedir"
      	else
        	zenity --error --text="Something went wrong." --width=240 --height=40 --title="$TITLE - Cachedir"
      	fi
    	else
    		zenity --error --text="Cachedir doesn't exist! Was it already cleared?" --width=240 --height=40 --title="$TITLE - Cachedir"
    	fi
	main ;;
  'FORCE KILL' )
    	killall WorldsPlayer.exe run.exe javaw.exe jrew.exe
    	zenity --error --text="Killed all possible running processes of Worlds." --width=240 --height=40 --title="$TITLE - Kill"
    	main ;;
esac
}

main
