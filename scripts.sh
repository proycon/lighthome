#!/bin/sh

reset_notification_lights() {
    mqttpub "home/technofire/pi2/jsonset" '{"scene":"off","brightness":"0"}'
    mqttpub "home/technofire/pi3/jsonset" '{"scene":"off","brightness":"0"}'
    mqttpub "home/technofire/pi4/jsonset" '{"scene":"off","brightness":"0"}'
}

yellow_notification_lights() {
    mqttpub "home/technofire/pi2/jsonset" '{"scene":"yellow_notice","brightness":"255","iterations":"5"}'
    mqttpub "home/technofire/pi3/jsonset" '{"scene":"yellow_notice","brightness":"255","iterations":"5"}'
    mqttpub "home/technofire/pi4/jsonset" '{"scene":"yellow_notice","brightness":"255","iterations":"5"}'
}

alarm_lights() {
    mqttpub "home/technofire/pi2/jsonset" '{"scene":"redalert","brightness":"255","iterations":"0"}'
    mqttpub "home/technofire/pi3/jsonset" '{"scene":"redalert","brightness":"255","iterations":"0"}'
    mqttpub "home/technofire/pi4/jsonset" '{"scene":"redalert","brightness":"255","iterations":"0"}'
}

