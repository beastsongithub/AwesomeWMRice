#!/bin/sh

run() {
  if ! pgrep -f "$1" ;
  then
    "$@" &
  fi
}

# exe xfce4-clipman
run "nm-applet"
run "/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1"
run "picom"
# exe xcompmgr -C
# exe udiskie
run "xidlehook" "--not-when-fullscreen" "--timer"  320  'xkb-switch -s us && betterlockscreen -l' '' 

if pgrep -f copyq; then
    pkill copyq
    sleep 1
    copyq --start-server
else
    sleep 2
    copyq --start-server
fi
#exe pasystray
