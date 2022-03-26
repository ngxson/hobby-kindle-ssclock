#!/bin/sh

source ./libkohelper.sh

SSCLOCK_X=100 # unit: pixel
SSCLOCK_Y=100 # unit: pixel
SSCLOCK_FONT_SIZE=32 # unit: pt

while true; do
  STATE=$(lipc-get-prop com.lab126.powerd state)

  if [[ "$STATE" = "screenSaver" || "$STATE" = "readyToSuspend" || "$STATE" = "suspended" ]]; then
    # set RTC alarm
    NOW=$(date +%s)
    WAKEUP_TIME=$((((($NOW+59)/60)*60)))
    SLEEP_SECS=$(($WAKEUP_TIME-$NOW))
    rtcwake -d /dev/rtc1 -m no -s $SLEEP_SECS > /dev/null 2>&1

    # print current time
    TIME_STR=$(date +"%H:%M")
    print_clock_white_background ${SSCLOCK_X} ${SSCLOCK_Y} ${SSCLOCK_FONT_SIZE}
    print_clock_text "$TIME_STR" ${SSCLOCK_X} ${SSCLOCK_Y} ${SSCLOCK_FONT_SIZE}

    # go to sleep
    sleep 0.5
    rtcwake -d /dev/rtc1 -m mem -s $SLEEP_SECS > /dev/null 2>&1
  else
    # wait until user pressing power button
    lipc-wait-event com.lab126.powerd goingToScreenSaver,readyToSuspend >/dev/null
    sleep 1
  fi
  sleep 0.5
done
