#!/bin/sh

source ./libkohelper.sh

kill `ps aux | grep ssclock.lua | grep -v grep | awk '{ print $2 }'`

cd lua
(./bin/luajit ssclock.lua)&

eips_print_bottom_centered "ssclock started" 3
