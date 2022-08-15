#!/bin/bash
#(POSIX shell doesn't suffice here)

# Receives notifications from MQTT

if [ -z "$HAROOT" ]; then
    echo "$HAROOT not set">&2
    exit 2
fi

. "$HAROOT/scripts/common/include.sh"

HANDLERS="$*"
#source all requested mqtt handlers
for handler in $HANDLERS; do
    handler=$(echo "$handler" | cut -d '@' -f 1) #@ is used to separate arguments
    # shellcheck disable=SC1090
    if [ -e "$HAROOT/scripts/mqtthandlers/$handler.sh" ]; then
        . "$HAROOT/scripts/mqtthandlers/$handler.sh"
    else
        die "Requested handler $handler not found!"
    fi
done

declare -a fields
declare -a payloadfields

while IFS= read -r line
do
	IFS="|" read -ra fields <<< $line; #-a is bash, not posix
	RECEIVETIME=${fields[0]} #time of reception
	TOPIC=${fields[1]}
	PAYLOAD="${fields[2]}"

    NOW=$(date +%s | tr -d '\n')

    #parse payload
    IFS=":" read -ra payloadfields <<< "$PAYLOAD";
    set -- "${payloadfields[@]}"
    MSGTIME=$NOW
    TIMEDELTA=0
    if [ $# -gt 1 ] && [[ "$1" =~ ^[0-9]+$ ]]; then
        #assume to be a timestamp if first is numeric and NOT the only argument
        MSGTIME=$1
        shift
        PAYLOAD=$(echo -e "$@" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//') #trim
        echo "MQTT IN [@$MSGTIME] $TOPIC> $PAYLOAD" >&2
        TIMEDELTA=$(( NOW - MSGTIME ))
    else
        #no timestamp
        echo "MQTT IN $TOPIC> $PAYLOAD" >&2
    fi

    for handler in $HANDLERS; do
        #A handler may contain contain arguments, separated by @
        case $handler in
            *@*)
                args=$(echo "$handler" | cut -d '@' -f '2-' | sed 's/@/ /g' ) #@ is used to separate arguments
                handler=$(echo "$handler" | cut -d '@' -f 1) #@ is used to separate arguments
                ;;
            *)
                args=
                ;;
        esac
        #shellcheck disable=SC2086
        handle_$handler $args && break   #break as soon as a handler completes successfully
    done

done < /dev/stdin
