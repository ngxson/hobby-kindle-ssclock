#!/bin/sh

source ./libkohelper.sh

kill `ps aux | grep ssclock.sh | grep -v grep | awk '{ print $2 }'`

(./ssclock.sh)&

eips_print_bottom_centered "ssclock started" 3
