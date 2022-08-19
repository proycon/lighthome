# Lighthome - Lightweight Home Automation

This repository contains part of my home automation configuration.

## Introduction

Though I'm using [Home Assistant](https://home-assistant.io) on the central
server at the heart of my home automation ([configuration
here](https://github.com/proycon/homeassistant-config), I have various
Raspberry Pis and other devices that are part of or connected to my home
automation system.

To keep things on the various devices as lightweight and as portable as
possible, I wrote 'lighthome'. It consists of various shell scripts and some
simple programs to read/write several sensors. Central in the communication
between all devices is the MQTT broker.

## Architecture

* `scripts/common/include.sh` - Defines common functions, including:
    * ``mqtt_receiver *[handlers]*`` - Subscribes to MQTT and registers one or more handler scripts, takes care of reconnect logic in case of failures, parallelisation, and runs asynchronously
    * ``mqtt_transmitter *[senders]*`` - Takes input and publishes it on MQTT, takes care of reconnect logic in case of failures, parallelisation, and runs asynchronously
    * ``mqttpub *[topic]* *[payload]*``- Publish a single MQTT message
* **handler scripts** (``scripts/mqtthandlers/*``) - Receives MQTT stream on standard input and should invoke scripts that perform the action by calling an action script. 
    * These scripts are sourced and everything inside should be run asynchronously!
    * The script doesn't have to deal with MQTT itself, except if it wants to publish feedback (using ``mqttpub``)
* **sender scripts** (``scripts/mqttsenders/*``) - Monitors some device/sensor (preferably via an independent action script or program) and then translates its output for MQTT (standard output) 
    * These scripts are run normally, either over and over at a specified interval or as a one-shot script that runs indefinitely by itself.
    * Standard output serves as payload for MQTT (the script doesn't have to deal with MQTT itself)
* **actions scripts and programs** (``scripts/``, ``programs/``) - Perform any action, completely MQTT unaware, can also be invoked independently from command line for low-level testing

## Devices

### Raspberry Pi 1  (RaspiOS)

* GPIO: 433.92Mhz Transmitter for lights (see also https://github.com/proycon/433mhzforrpi/)
* GPIO: Door/doorbell sensors (wired, reed contacts)
* GPIO: IR LED for remote control of TV/audio

![GPIO wiring schematic](docs/pi1.svg)

### Raspberry Pi 2 (RaspiOS) 

* GPIO: 433.92Mhz Transmitter for lights
* GPIO: Door/window sensors (wired, reed contacts)
* GPIO: Neopixels LED (WS2812B) for ambilight in living room
* GPIO: IR LED for remote control of TV/audio
* GPIO: IR Receiver
* USB: [RFLink Transceiver](http://www.rflink.nl/), 433.92Mhz, based on Arduino Mega

![GPIO wiring schematic](docs/pi2.svg)

### Raspberry Pi 3 (RaspiOS)

* GPIO: [DHT-22 temperature/humidity sensor](https://www.adafruit.com/product/385)
* GPIO: Neopixels LED (WS2912B) fireplace ([video](https://www.youtube.com/watch?v=i18eXQIXzXg))
* GPIO: [PIR sensor](https://www.adafruit.com/product/189)
* GPIO: [MH-Z19 CO2 sensor](https://www.tinytronics.nl/shop/nl/winsen-mh-z19b-co2-sensor-met-kabel')
* USB: [RFLink Transceiver](http://www.rflink.nl/), 868.3Mhz, based on Arduino Mega

### Raspberry Pi 4 (RaspiOS)

* GPIO: Neopixels LED (WS2912B)

![GPIO wiring schematic](docs/pi4.svg)
