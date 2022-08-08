#!/bin/bash
imagenr=$(( ( RANDOM % 6 )  + 1 ))
feh --bg-scale $HAROOT/media/sunrise$imagenr.jpg &
conky -c $HAROOT/scripts/wakeup/wakeup.conkyrc &
sleep 1; xset s off -dpms
sleep 60
play $HAROOT/media/morningbells_long.ogg &
exec dwm
