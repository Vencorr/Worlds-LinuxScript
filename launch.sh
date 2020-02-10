#!/bin/bash
export WORLDSDIR="$(dirname "$(readlink -f "$0")")"
export WINEPREFIX=$WORLDSDIR/prefix
export WORLDSINSTALL="$WINEPREFIX/drive_c/Program Files/Worlds/"
export WINEARCH=win32
cd "$WORLDSINSTALL"
mkdir -p $WORLDSDIR/backups $WORLDSDIR/themes

main() {
  sel=$(zenity \
		--title="Worlds" \
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
		FALSE 'Clear Cache' 2>/dev/null )
	case $sel in
	'Start Worlds')
		$WORLDSDIR/proton/dist/bin/wine "$WORLDSINSTALL/run.exe" ;;
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
      echo "$WORLDSINSTALL/worlds.ini >> $bkup/worlds.ini"
      cp -r "$WORLDSINSTALL/worlds.ini" "$bkup/worlds.ini"
      echo "$WORLDSINSTALL/gamma.avatars >> $bkup/gamma.avatars"
      cp -r "$WORLDSINSTALL/gamma.avatars" "$bkup/gamma.avatars"
      echo "$WORLDSINSTALL/gamma.worldsmarks >> $bkup/gamma.worldsmarks"
      cp -r "$WORLDSINSTALL/gamma.worldsmarks" "$bkup/gamma.worldsmarks"
      main
    fi ;;
  'Restore from backup')
    mkdir -p "$WORLDSDIR/backups"
    rbkup=$(zenity  --file-selection --title="Select Backup folder to restore from" --directory --filename="$WORLDSDIR/backups/")
    if [[ $? -eq 1 ]]; then
      main
    else
      echo "$rbkup/worlds.ini >> $WORLDSINSTALL/worlds.ini"
      cp -r "$rbkup/worlds.ini" "$WORLDSINSTALL/worlds.ini"
      echo "$rbkup/gamma.avatars >> $WORLDSINSTALL/gamma.avatars"
      cp -r "$rbkup/gamma.avatars" "$WORLDSINSTALL/gamma.avatars"
      echo "$rbkup/gamma.worldsmarks >> $WORLDSINSTALL/gamma.worldsmarks"
      cp -r "$rbkup/gamma.worldsmarks" "$WORLDSINSTALL/gamma.worldsmarks"
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
      main
    fi ;;
  'Clear Cache')
		  rm -rf "$WORLDSINSTALL/cachedir"
      main ;;
	esac
}

main
