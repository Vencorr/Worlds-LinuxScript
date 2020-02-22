#!/bin/bash
export TITLE="Worlds Linux"
export WORLDSDIR="$(dirname "$(readlink -f "$0")")"
export WINEPREFIX=$WORLDSDIR/prefix
export WORLDSINSTALL="$WINEPREFIX/drive_c/Program Files/Worlds/WorldsPlayer by Worlds.com"

mkdir -p $WORLDSDIR/backups $WORLDSDIR/themes

if [ -f "$WORLDSDIR/wine.worldslinux" ]; then
  export WINE=$(cat "$WORLDSDIR/wine.worldslinux")
fi
if [ -f "$WORLDSDIR/wineprefix.worldslinux" ]; then
  export WINEPREFIX=$(cat "$WORLDSDIR/wineprefix.worldslinux")
fi
if [ -f "$WORLDSDIR/worlds.worldslinux" ]; then
  export WORLDSINSTALL=$(cat "$WORLDSDIR/worlds.worldslinux")
fi
cd "$WORLDSINSTALL"

main() {
  sel=$(zenity \
    --list \
	   --title="$TITLE" \
	   --window-icon="$WORLDSDIR/icon.png" \
   	--width=300 \
	   --height=340 \
	   --cancel-label='Quit' \
	   --list \
	   --text 'WorldsPlayer Linux' \
	   --column 'Options' \
    --hide-header \
		  'Launch Worlds' \
		  'Open Logger' \
    'Open Worlds folder' \
		  'Edit worlds.ini' \
    'Backup Worlds files' \
    'Restore from backup' \
    'Set theme' \
    'Settings' \
		  'Clear Cache' \
    'FORCE KILL' 2>/dev/null)
	case $sel in
    'Launch Worlds')
		    launch ;;
    'Open Logger')
      logger ;;
    'Open Worlds folder')
      folder ;;
    'Edit worlds.ini')
		    ini ;;
    'Backup Worlds files')
      backup ;;
    'Restore from backup')
      restore ;;
    'Set theme' )
      theme ;;
    'Settings' )
      settings ;;
    'Clear Cache')
      cache ;;
    'FORCE KILL' )
      kill ;;
	esac
}

launch () {
  WORLDSNEW="WorldsPlayer.exe"
  WORLDSOLD="run.exe"
  WORLDSLEGACY="run.bat"
  if [ -f "$WORLDSINSTALL/$WORLDSNEW" ]; then
    $WINE "$WORLDSINSTALL/$WORLDSNEW"
  elif [ -f "$WORLDSINSTALL/$WORLDSOLD" ]; then
    $WINE "$WORLDSINSTALL/$WORLDSOLD"
  else
    $WINE "$WORLDSINSTALL/$WORLDSLEGACY"
  fi
}

logger () {
  tail -F "$WORLDSINSTALL/Gamma.Log.open" | zenity --text-info --auto-scroll --height=400 --width=500 --title="$TITLE - Log" --window-icon="$WORLDSDIR/icon.png" --text="Gamma.Log.open"
  main
}

folder () {
  gio open "$WORLDSINSTALL"
  main
}

ini () {
  xdg-open "$WORLDSINSTALL/worlds.ini"
  main
}

backup () {
  mkdir -p "$WORLDSDIR/backups"
  bkup=$(zenity  --file-selection --title="$TITLE - Backup" --text="Select Backup folder to backup to" --directory --filename="$WORLDSDIR/backups/" --save --confirm-overwrite --window-icon="$WORLDSDIR/icon.png")
  if [[ ! $? -eq 1 ]]; then
    cp -r "$WORLDSINSTALL/worlds.ini" "$bkup/worlds.ini"
    cp -r "$WORLDSINSTALL/gamma.avatars" "$bkup/gamma.avatars"
    cp -r "$WORLDSINSTALL/gamma.worldsmarks" "$bkup/gamma.worldsmarks"
    if [[ $? -eq 1 ]]; then
      zenity --error --text="Could not successfully backup files." --width=240 --height=40  --title="$TITLE - Backup" --window-icon="$WORLDSDIR/icon.png"
    else
      zenity --info --text="Personal world files successfully backed up." --width=240 --height=40  --title="$TITLE - Backup" --window-icon="$WORLDSDIR/icon.png"
    fi
  fi
  main
}

restore () {
  mkdir -p "$WORLDSDIR/backups"
  rbkup=$(zenity  --file-selection --title="Select Backup folder to restore from" --directory --filename="$WORLDSDIR/backups/" --window-icon="$WORLDSDIR/icon.png")
  if [[ ! $? -eq 1 ]]; then
    cp -r "$rbkup/worlds.ini" "$WORLDSINSTALL/worlds.ini"
    cp -r "$rbkup/gamma.avatars" "$WORLDSINSTALL/gamma.avatars"
    cp -r "$rbkup/gamma.worldsmarks" "$WORLDSINSTALL/gamma.worldsmarks"
    if [[ $? -eq 1 ]]; then
      zenity --error --text="Could not successfully restore files." --width=240 --height=40  --title="$TITLE - Restore" --window-icon="$WORLDSDIR/icon.png"
    else
      zenity --info --text="Personal world files successfully restored." --width=240 --height=40 --title="$TITLE - Restore" --window-icon="$WORLDSDIR/icon.png"
    fi
  fi
  main
}

theme () {
  mkdir -p "$WORLDSDIR/themes"
  seltheme=$(zenity  --file-selection --title="Select a theme folder" --directory --filename="$WORLDSDIR/themes/" --window-icon="$WORLDSDIR/icon.png")
  if [[ ! $? -eq 1 ]]; then
    for i in $seltheme/*;
      do FILENAME="$(basename $i)"
      echo "$seltheme/$FILENAME >> $WORLDSINSTALL/$FILENAME"
      ln -sf "$seltheme/$FILENAME" "$WORLDSINSTALL/$FILENAME"
    done
    zenity --info --text="Successfully set theme to $(basename $seltheme)." --width=240 --height=40  --title="$TITLE - Theme" --window-icon="$WORLDSDIR/icon.png"
  fi
  main
}

settings () {
  SETSEL=$(zenity --list --title="$TITLE - Settings" --text="Settings for Worlds Linux" --column='Option' --column='Value' --cancel-label="Back" --width=300 --height=300 --window-icon="$WORLDSDIR/icon.png" \
    "Wine Location" "$WINE" \
    "Prefix Location" "$WINEPREFIX" \
    "Worlds Location" "$WORLDSINSTALL" \
    2>/dev/null)
  case $SETSEL in
    'Wine Location')
      WINESEL=$(zenity --entry --title="$WTITLE - Wine Binary Location" --text="Path to wine binary" --entry-text="$WINE" --window-icon="$WORLDSDIR/icon.png")
      if [[ ! $? -eq 1 ]]; then
        export WINE=$WINESEL
        echo "$WINESEL" > "$WORLDSDIR/wine.worldslinux"
      fi
      settings ;;
    'Prefix Location')
      PREFSEL=$(zenity --entry --title="$WTITLE - Wine Prefix Location" --text="Path to Wine Prefix." --entry-text="$WINEPREFIX" --window-icon="$WORLDSDIR/icon.png")
      if [[ ! $? -eq 1 ]]; then
        export WINEPREFIX=$PREFSEL
        echo "$PREFSEL" > "$WORLDSDIR/wineprefix.worldslinux"
      fi
      settings ;;
    'Worlds Location')
      WORLDSEL=$(zenity --entry --title="$WTITLE - Worlds Location" --text="Path to Worlds Folder" --entry-text="$WORLDSINSTALL" --window-icon="$WORLDSDIR/icon.png")
      if [[ ! $? -eq 1 ]]; then
        export WORLDSINSTALL=$WORLDSEL
        echo "$WORLDSEL" > "$WORLDSDIR/worlds.worldslinux"
      fi
      settings ;;
  esac
  main
}

cache () {
  CDSIZE=$(du -sh "$WORLDSINSTALL/cachedir" | cut -f1)
  if [ -d "$WORLDSINSTALL/cachedir" ]; then
    rm -rf "$WORLDSINSTALL/cachedir"
    if [ ! -d "$WORLDSINSTALL/cachedir" ]; then
      zenity --info --text="$CDSIZE were successfully cleared." --width=240 --height=40 --title="$TITLE - Cachedir" --window-icon="$WORLDSDIR/icon.png"
    else
      zenity --error --text="Something went wrong." --width=240 --height=40 --title="$TITLE - Cachedir" --window-icon="$WORLDSDIR/icon.png"
    fi
  else
	   zenity --error --text="Cachedir doesn't exist! Was it already cleared?" --width=240 --height=40 --title="$TITLE - Cachedir" --window-icon="$WORLDSDIR/icon.png"
  fi
  main
}

kill () {
  killall WorldsPlayer.exe run.exe javaw.exe jrew.exe
  zenity --error --text="Killed all possible running processes of Worlds." --width=240 --height=40 --title="$TITLE - Kill" --window-icon="$WORLDSDIR/icon.png"
  main
}

main
