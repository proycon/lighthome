#!/bin/sh

EXIT=0

die() {
    NOW=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$NOW] FATAL ERROR: $*">&2
    exit 2
}

error() {
    NOW=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$NOW] ERROR: $*">&2
}

info() {
    NOW=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$NOW] INFO: $*">&2
}

debug() {
    NOW=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$NOW] DEBUG: $*">&2
}

settrap() {
    #kill all chlidren on when dying
    [ "$EXIT" = "" ] && EXIT=0
    trap "EXIT=1 && trap - TERM && info \"exiting on signal\" && kill -- 0" INT TERM EXIT
}


havedep() {
    command -v "$1" >/dev/null 2>/dev/null || die "missing dependency $1"
}

havevar() {
    VALUE=$(eval "echo \$$1")
    [ -n "$VALUE" ] || die "missing variable: $1"
}


if [ -z "$HAROOT" ]; then
    die "$HAROOT not set"
fi

if [ -e "$HAROOT/private/secrets.sh" ]; then
    . "$HAROOT/private/secrets.sh"
fi

havedep mosquitto_pub
havedep mosquitto_sub

mqttcheck() {
    [ -n "$MQTT_USER" ] || die "No MQTT user defined"
    [ -n "$MQTT_PASSWORD" ] || die "No MQTT password defined"
    [ -n "$MQTT_HOST" ] || MQTT_HOST="anaproy.nl"
    [ -n "$MQTT_PORT" ] || MQTT_PORT=8883
    if [ -e /etc/ssl/certs/ca-cert-ISRG_Root_X1.pem ]; then
        CACERT="/etc/ssl/certs/ca-cert-ISRG_Root_X1.pem"
    elif [ -e /etc/ssl/certs/ISRG_Root_X1.pem ]; then
        CACERT="/etc/ssl/certs/ISRG_Root_X1.pem"
    elif [ -e /etc/ssl/certs/ca-cert-ISRG_Root_X1.pem ]; then
        CACERT="/etc/ssl/certs/ca-cert-ISRG_Root_X1.pem"
    elif [ -e /etc/ssl/certs/DST_Root_CA_X3.pem ]; then
        CACERT="/etc/ssl/certs/DST_Root_CA_X3.pem"
    elif [ -e /etc/ssl/certs/ca-cert-DST_Root_CA_X3.pem ]; then
        CACERT="/etc/ssl/certs/ca-cert-DST_Root_CA_X3.pem"
    else
        die "mqttcheck: CA Certificate not found"
    fi
}

mqttpub() {
    #Publish a single message
    mqttcheck

    if [ $# -eq 2 ]; then
        #explicit topic and payload
        TOPIC="$1"
        shift
    elif [ -n "$TOPIC" ]; then
        #only one argument, topic already set in environment, assume argument is payload
        true #noop, nothing to do
    elif [ -n "$1" ]; then
        #only one argument, no topic provided yet so assume argument is topic, set automatic payload
        TOPIC="$1"
        shift
    else
        error "No topic provided"
        return 2
    fi

    if [ -n "$1" ]; then
        PAYLOAD="$1"
    else
        PAYLOAD="ON"
    fi

    info "MQTT OUT $TOPIC: $PAYLOAD"
    if ! mosquitto_pub -I "$HOSTNAME$MQTT_SESSION_SUFFIX" -h "$MQTT_HOST" -p "$MQTT_PORT" -u "$MQTT_USER" -P "$MQTT_PASSWORD" --cafile "$CACERT" -t "$TOPIC" -m "$PAYLOAD" --qos 1 $MQTT_OPTIONS; then
        error "mqttpub failed"
        return 1
    fi
}

mqtt_receiver() {
    #Subscribes to MQTT and registers one or more mqtthandler scripts

    mqttcheck
    #run asynchronously
    (
        settrap
        while [ $EXIT -eq 0 ]; do
            info "mqttsub: $*"
            #shellcheck disable=SC2068,SC2086
            if ! mosquitto_sub -c -q 1 -i "$HOSTNAME" -h "$MQTT_HOST" -p "$MQTT_PORT" -u "$MQTT_USER" -P "$MQTT_PASSWORD" --cafile "$CACERT" -t '#' -F "@H:@M:@S|%t|%p" $MQTT_OPTIONS | "$HAROOT/scripts/common/mqtthandler.sh" $@; then
                #small delay before reconnecting
                error "mqttsub failed ($*)"
            fi
            #note: mqtthandler is a separate script rather than inline here because it requires bash rather than posix shell
            if [ $EXIT -ne 0 ]; then
                error "mqtt_receiver $*: reconnecting after 10s grace period..."
                sleep 10
            fi
        done
        info "mqtt_receiver $*: exiting after signal"
    ) &
}


mqtt_transmitter() {
    #Registers one or more mqttsender scripts and publishes their output to MQTT
    mqttcheck


    if [ -n "$1" ]; then
        TOPIC="$1"
        shift
    else
        error "No topic provided"
        return 2
    fi

    if [ -n "$1" ]; then
        case $1 in
            (*[!0-9]*|'') die "expected polling interval integer, got $1 instead";;
            *) ;;
        esac
        INTERVAL="$1"
        shift
    else
        error "No polling interval provided"
        return 2
    fi

    [ -n "$1" ] || die "no sender specified"
    SENDER=$1
    [ ! -e "$HAROOT/scripts/mqttsenders/$SENDER.sh" ] && die "Script mqttsenders/$SENDER.sh not found"
    shift
    (
        settrap
        while [ $EXIT -eq 0 ]; do
            #shellcheck disable=SC2068,SC2086
            if [ $INTERVAL -gt 0 ]; then
                #sender runs at specified interval
                PAYLOAD=$("$HAROOT/scripts/mqttsenders/$SENDER.sh" $@)
                info "mqtt_transmitter: $SENDER $*; interval=$INTERVAL; topic=$TOPIC; payload=$PAYLOAD"
                #shellcheck disable=SC2181 #--> usage of $?
                if [ $? -ne 0 ]; then
                    #small delay before reconnecting
                    error "mqtt sender script failed ($SENDER.sh $*), reconnecting after 10s grace period..."
                    sleep 10
                elif ! mosquitto_pub -I "$HOSTNAME" -h "$MQTT_HOST" -p "$MQTT_PORT" -u "$MQTT_USER" -P "$MQTT_PASSWORD" --cafile "$CACERT" -t "$TOPIC" -m "$PAYLOAD" --qos 1 $MQTT_OPTIONS; then
                    #small delay before reconnecting
                    error "mqtt publish for sender failed ($SENDER.sh $*), reconnecting after 10s grace period..."
                    sleep 10
                else
                    #normal behaviour
                    sleep $INTERVAL
                fi
            elif [ $TOPIC = "CUSTOM" ]; then
                info "mqtt_transmitter: $SENDER $*; interval=0; topic=$TOPIC"
                #sender runs continuously (invoked once) and takes care of its own mqtt sending
                "$HAROOT/scripts/mqttsenders/$SENDER.sh" $@ 
                #shellcheck disable=SC2181 #--> usage of $?
                error "mqtt sender failed ($SENDER.sh $*), reconnecting after 10s grace period..."
                sleep 10
            else
                info "mqtt_transmitter: $SENDER $*; interval=0; topic=$TOPIC"
                #sender runs continuously (invoked once), each outputted line is transmitted over mqtt as payload
                "$HAROOT/scripts/mqttsenders/$SENDER.sh" $@ | while IFS= read -r PAYLOAD; do
                    info "mqtt_transmitter: $SENDER $*; interval=$INTERVAL; topic=$TOPIC; payload=$PAYLOAD"
                    if ! mosquitto_pub -I "$HOSTNAME" -h "$MQTT_HOST" -p "$MQTT_PORT" -u "$MQTT_USER" -P "$MQTT_PASSWORD" --cafile "$CACERT" -t "$TOPIC" -m "$PAYLOAD" --qos 1 $MQTT_OPTIONS; then
                        error "mqttpub from sender failed ($SENDER.sh $*)..."
                        return 1
                    fi
                done
                #shellcheck disable=SC2181 #--> usage of $?
                error "mqtt sender failed ($SENDER.sh $*), reconnecting after 10s grace period..."
                sleep 10
            fi
        done
        info "mqtt_transmitter $SENDER $*: exiting after signal"
    ) &
}

mqtt_say() {
    TARGETHOST=$1
    shift
    mqttpub "home/say/$TARGETHOST" "$@"
}

mqtt_sound() {
    TARGETHOST=$1
    shift
    mqttpub "home/sound/$TARGETHOST" "$@"
}

if [ -z "$USER" ]; then
    USER="$(whoami)"
fi
if [ -z "$HOSTNAME" ]; then
    HOSTNAME="$(hostname)"
fi

[ -z "$PLAY" ] && export PLAY="timeout --kill-after=12s --signal=9 10s mpv --no-video --really-quiet"

[ -z "$TMPDIR" ] && export TMPDIR=/tmp

[ -z "$HASTATEDIR" ] && export HASTATEDIR="$TMPDIR/homestatus"

readstate() {
    if [ -n "$2" ]; then
        die "readstate expects a variable name as second parameter"
    fi
    if [ -e "$HASTATEDIR/$1" ]; then
        read -r "$2" <"$HASTATEDIR/$1"
    else
        return 1
    fi
}

teststate() {
    if [ -n "$2" ]; then
        die "teststate expects a test value as second parameter"
    fi
    if [ -e "$HASTATEDIR/$1" ]; then
        read -r "" state <"$HASTATEDIR/$1"
        if [ "$state" = "$2" ]; then
            return 0
        fi
    else
        return 1
    fi
}

#write a state, first argument is a target (without $HASTATEDIR), second is the payload:
writestate() {
    if [ -n "$1" ]; then
        die "writestate expects a target as first parameter"
    fi
    if [ -n "$2" ]; then
        die "writestate expects a payload as second parameter"
    fi
    d=$(dirname "$1")
    if [ "$d" != "." ] && [ ! -e "$HASTATEDIR/$d" ]; then
        mkdir -p "$HASTATEDIR/$d"
    fi
    if readstate "$1" OLDPAYLOAD; then
        if [ "$OLDPAYLOAD" != "$2" ]; then
            #shellcheck disable=SC2028 #(echo instead of printf is fine here)
            [ -n "$HASTATELOGFILE" ] && echo "$(date "+%Y-%M-%D %H:%M:%S")\t$1\t$2" >> "$HASTATELOGFILE"
        else
            #state didn't change
            return 0
        fi
    fi
    age=$(lastchanged "$1")
    echo "$2" > "$HASTATEDIR/$1"
    #run callback function if it exists and is not already running (based on lock file)
    #shellcheck disable=SC3060 #(string expansion is not POSIX, but works in ash)
    f="${1//\//_}"
    if command -v "$f"; then
        if [ ! -e "$TMPDIR/$f.runlock" ]; then
            touch "$TMPDIR/$f.runlock" &&\
            "$f" "$2" "$OLDPAYLOAD" "$age" &&\
            rm "$TMPDIR/$f.runlock" && "${f}_cleanup" "$2" &
        fi
    fi
}

#returns the age of a state in seconds
lastchanged() {
    if [ -e "$HASTATEDIR/$1" ]; then
        if [ -n "$2" ]; then
            now=$2 
        else
            now=$(date +"%s")
        fi
        mtime=$(stat -c "%Y")
        echo $((now - mtime))
    else
        return 1
    fi
}

playsound() {
    FILENAME="$HAROOT/media/$1"
    if [ -e "$FILENAME" ]; then
        $PLAY "$FILENAME"
    else
        error "Unable to play $FILENAME, file not found"
    fi
}
