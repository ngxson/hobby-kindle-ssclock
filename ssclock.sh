#!/bin/sh

source ./libkohelper.sh

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
    print_clock_text "$TIME_STR"

    # go to sleep
    sleep 1
    rtcwake -d /dev/rtc1 -m mem -s $SLEEP_SECS > /dev/null 2>&1
  else
    # wait until user pressing power button
    lipc-wait-event com.lab126.powerd goingToScreenSaver,readyToSuspend >/dev/null
    sleep 1
  fi
  sleep 0.5
done
