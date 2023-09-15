#!/bin/sh
case $1 in #upper case parameter indicated something contextual
    NIGHT)
        case "$(hostname)" in
            pi2)
                ~/scripts/numen/send_wrapper.sh home/command/lights/bedroom_ambilight/on
                ;;
            *)
                ~/scripts/numen/send_wrapper.sh home/command/lights/night
                ;;
        esac
        ;;
    TV_ON)
        case "$(hostname)" in
            pi2)
                ~/lighthome/send.sh --notify home/command/media_bedroom/tv
                ;;
            *)
                ~/lighthome/send.sh --notify home/command/media/tv
                ;;
        esac
        ;;
    TV_OFF)
        case "$(hostname)" in
            pi2)
                ~/lighthome/send.sh --notify home/command/media_bedroom/off
                ;;
            *)
                ~/lighthome/send.sh --notify home/command/media/off
                ;;
        esac
        ;;
    MUSIC_ON)
        case "$(hostname)" in
            pi2)
                ~/lighthome/send.sh --notify home/command/media_bedroom/music
                ;;
            *)
                ~/lighthome/send.sh --notify home/command/media/music
                ;;
        esac
        ;;
    MUSIC_OFF)
        case "$(hostname)" in
            pi2)
                ~/lighthome/send.sh --notify home/command/music2/off
                ;;
            *)
                ~/lighthome/send.sh --notify home/command/music/off
                ;;
        esac
        ;;
    KODI_ON)
        case "$(hostname)" in
            pi2)
                ~/lighthome/send.sh --notify home/command/media_bedroom/centre
                ;;
            *)
                ~/lighthome/send.sh --notify home/command/media/centre
                ;;
        esac
        ;;
    KODI_OFF)
        case "$(hostname)" in
            pi2)
                ~/lighthome/send.sh --notify home/command/kodi2/off
                ;;
            *)
                ~/lighthome/send.sh --notify home/command/kodi/off
                ;;
        esac
        ;;
    DESKTOP_ON)
        case "$(hostname)" in
            pi2)
                ~/lighthome/send.sh --notify home/command/media_bedroom/desktop
                ;;
            *)
                ~/lighthome/send.sh --notify home/command/media/desktop
                ;;
        esac
        ;;
    DESKTOP_OFF)
        case "$(hostname)" in
            pi2)
                ~/lighthome/send.sh --notify home/command/media_bedroom/off
                ;;
            *)
                ~/lighthome/send.sh --notify home/command/media/off
                ;;
        esac
        ;;
    TVDECODER:*)
        COMMAND="$(echo "$1" | cut -d ":" -f 2)"
        case "$(hostname)" in
            pi2)
                ~/lighthome/send.sh --notify "home/command/tvdecoder2/$COMMAND"
                ;;
            *)
                ~/lighthome/send.sh --notify "home/command/tvdecoder/$COMMAND"
                ;;
        esac
        ;;
    MUTE)
        case "$(hostname)" in
            pi2)
                ~/lighthome/send.sh --notify home/command/mute
                ;;
            *)
                ~/lighthome/send.sh --notify home/command/mute
                ;;
        esac
        ;;
    SPOTS_ON)
        case "$(hostname)" in
            pi2)
                ~/lighthome/send.sh --notify home/command/lights/bedroom_highspots/on
                ;;
            *)
                ~/lighthome/send.sh --notify home/command/lights/midspots/on
                ;;
        esac
        ;;
    SPOTS_OFF)
        case "$(hostname)" in
            pi2)
                ~/lighthome/send.sh --notify home/command/lights/bedroom_highspots/off
                ;;
            *)
                ~/lighthome/send.sh --notify home/command/lights/midspots/off
                ;;
        esac
        ;;
    TV_SPOTS_ON)
        case "$(hostname)" in
            pi2)
                ~/lighthome/send.sh --notify home/command/lights/bedroom/on
                ;;
            *)
                ~/lighthome/send.sh --notify home/command/lights/tv_spots/on
                ;;
        esac
        ;;
    TV_SPOTS_OFF)
        case "$(hostname)" in
            pi2)
                ~/lighthome/send.sh --notify home/command/lights/bedroom/off
                ;;
            *)
                ~/lighthome/send.sh --notify home/command/lights/tv_spots/off
                ;;
        esac
        ;;
    AMBIANCE_ON)
        case "$(hostname)" in
            pi2)
                ~/lighthome/send.sh --notify home/command/lights/bedroom_ambilight/on
                ;;
            *)
                ~/lighthome/send.sh --notify home/command/lights/ambilight/on
                ~/lighthome/send.sh --notify home/command/lights/fireplace/on
                ;;
        esac
        ;;
    AMBIANCE_OFF)
        case "$(hostname)" in
            pi2)
                ~/lighthome/send.sh --notify home/command/lights/bedroom_ambilight/off
                ;;
            *)
                ~/lighthome/send.sh --notify home/command/lights/ambilight/off
                ~/lighthome/send.sh --notify home/command/lights/fireplace/off
                ;;
        esac
        ;;
    AIRCO_ON)
        case "$(hostname)" in
            pi2)
                ~/lighthome/send.sh --notify home/command/airco/bedroom/cool
                ;;
            *)
                ~/lighthome/send.sh --notify home/command/airco/living/cool
                ;;
        esac
        ;;
    AIRCO_OFF)
        case "$(hostname)" in
            pi2)
                ~/lighthome/send.sh --notify home/command/airco/bedroom/off
                ;;
            *)
                ~/lighthome/send.sh --notify home/command/airco/living/off
                ;;
        esac
        ;;
    *)
        #normal pass-through
        ~/lighthome/send.sh --notify "$1" $2
        ;;
esac
touch "$NUMEN_STATE_DIR/acted"
