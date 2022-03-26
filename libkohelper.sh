#!/bin/sh

source ./libkindle.sh

## A bit of helper functions...
# Check which type of init system we're running on
if [ -d /etc/upstart ]; then
    export INIT_TYPE="upstart"
    # We'll need that for logging
    # shellcheck disable=SC1091
    [ -f /etc/upstart/functions ] && . /etc/upstart/functions
else
    export INIT_TYPE="sysv"
    # We'll need that for logging
    # shellcheck disable=SC1091
    [ -f /etc/rc.d/functions ] && . /etc/rc.d/functions
fi

# Adapted from libkh[5]
## Check if we have an FBInk binary available somewhere...
# Default to something that won't horribly blow up...
FBINK_BIN="true"
for my_dir in /var/tmp /mnt/us/koreader /mnt/us/libkh/bin /mnt/us/linkss/bin /mnt/us/linkfonts/bin /mnt/us/usbnet/bin; do
    my_fbink="${my_dir}/fbink"
    if [ -x "${my_fbink}" ]; then
        FBINK_BIN="${my_fbink}"
        # Got it!
        break
    fi
done

has_fbink() {
    # Because the fallback is the "true" binary/shell built-in ;).
    if [ "${FBINK_BIN}" != "true" ]; then
        # Got it!
        return 0
    fi

    # If we got this far, we don't have fbink installed
    return 1
}

# NOTE: Yeah, the name becomes a bit of a lie now that we're (hopefully) exclusively using FBInk ;p.
eips_print_bottom_centered() {
    # We need at least two args
    if [ $# -lt 2 ]; then
        echo "not enough arguments passed to eips_print_bottom ($# while we need at least 2)"
        return
    fi

    kh_eips_string="${1}"
    kh_eips_y_shift_up="${2}"

    # Unlike eips, we need at least a single space to even try to print something ;).
    if [ "${kh_eips_string}" = "" ]; then
        kh_eips_string=" "
    fi

    # Sleep a tiny bit to workaround the logic in the 'new' (K4+) eInk controllers that tries to bundle updates,
    # otherwise it may drop part of our messages because of other screen updates from KUAL...
    # Unless we really don't want to sleep, for special cases...
    if [ -z "${EIPS_NO_SLEEP}" ]; then
        usleep 150000 # 150ms
    fi

    # NOTE: FBInk will handle the padding. FBInk's default font is square, not tall like eips,
    #       so we compensate by tweaking the baseline ;). This matches the baseline we use on Kobo, too.
    if has_fbink; then
        ${FBINK_BIN} -qpm -y $((-4 - kh_eips_y_shift_up)) "${kh_eips_string}"
    else
        # Crappy fallback
        eips 0 0 "${kh_eips_string}" >/dev/null
    fi
}

FONT_MONO="/usr/java/lib/fonts/Caecilia_LT_65_Medium.ttf"
if [ -f "/mnt/us/extensions/ssclock/IBMPlexSansArabic.ttf" ]; then
    FONT_MONO="/mnt/us/extensions/ssclock/IBMPlexSansArabic.ttf"
fi

print_clock_text() {
    MESSAGE="${1}"
    POSITION_X=${2}
    POSITION_Y=${3}
    FONT_SIZE=${4}

    # draw background
    ${FBINK_BIN} -b -C WHITE -t regular=${FONT_MONO},size=${FONT_SIZE},top=${POSITION_Y},bottom=0,left=${POSITION_X},right=0,format ".${MESSAGE}." > /dev/null 2>&1

    # draw text
    ${FBINK_BIN} -b -t regular=${FONT_MONO},size=${FONT_SIZE},top=${POSITION_Y},bottom=0,left=${POSITION_X},right=0,format " ${MESSAGE}" > /dev/null 2>&1

    # update to screen
    RECT_SIZE_W=$((${SCREEN_X_RES} - ${POSITION_X} - 50))
    RECT_SIZE_H=$((${SCREEN_Y_RES} - ${POSITION_Y} - 50))
    ${FBINK_BIN} -w -s top=${POSITION_Y},left=${POSITION_X},width=${RECT_SIZE_W},height=${RECT_SIZE_H} > /dev/null 2>&1
}
