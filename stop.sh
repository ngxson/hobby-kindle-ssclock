#!/bin/sh

source ./libkohelper.sh

kill `ps aux | grep ssclock.lua | grep -v grep | awk '{ print $2 }'`

eips_print_bottom_centered "ssclock stopped" 3
