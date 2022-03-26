#!/bin/sh

# We need to get the proper constants for our model...
kmfc="$(cut -c1 /proc/usid)"
if [ "${kmfc}" == "B" ] || [ "${kmfc}" == "9" ] ; then
	# Older device ID scheme
	kmodel="$(cut -c3-4 /proc/usid)"
	case "${kmodel}" in
		"13" | "54" | "2A" | "4F" | "52" | "53" )
			# Voyage...
			SCREEN_X_RES=1088	# NOTE: Yes, 1088, not 1072 or 1080...
			SCREEN_Y_RES=1448
			EIPS_X_RES=16
			EIPS_Y_RES=24		# Manually measured, should be accurate.
		;;
		"24" | "1B" | "1D" | "1F" | "1C" | "20" | "D4" | "5A" | "D5" | "D6" | "D7" | "D8" | "F2" | "17" | "60" | "F4" | "F9" | "62" | "61" | "5F" )
			# PaperWhite...
			SCREEN_X_RES=768	# NOTE: Yes, 768, not 758...
			SCREEN_Y_RES=1024
			EIPS_X_RES=16
			EIPS_Y_RES=24		# Manually measured, should be accurate.
		;;
		"C6" | "DD" )
			# KT2...
			SCREEN_X_RES=608
			SCREEN_Y_RES=800
			EIPS_X_RES=16
			EIPS_Y_RES=24
		;;
		"0F" | "11" | "10" | "12" )
			# Touch
			SCREEN_X_RES=600	# _v_width @ upstart/functions
			SCREEN_Y_RES=800	# _v_height @ upstart/functions
			EIPS_X_RES=12		# from f_puts @ upstart/functions
			EIPS_Y_RES=20		# from f_puts @ upstart/functions
		;;
		* )
			# Handle legacy devices...
			if [ -f "/etc/rc.d/functions" ] && grep -q "EIPS" "/etc/rc.d/functions" ; then
				. /etc/rc.d/functions
			else
				# Fallback... We shouldn't ever hit that.
				SCREEN_X_RES=600
				SCREEN_Y_RES=800
				EIPS_X_RES=12
				EIPS_Y_RES=20
			fi
		;;
	esac
else
	# Try the new device ID scheme...
	kmodel="$(cut -c4-6 /proc/usid)"
	case "${kmodel}" in
		"0G1" | "0G2" | "0G4" | "0G5" | "0G6" | "0G7" | "0KB" | "0KC" | "0KD" | "0KE" | "0KF" | "0KG" | "0LK" | "0LL" )
			# PW3...
			SCREEN_X_RES=1088
			SCREEN_Y_RES=1448
			EIPS_X_RES=16
			EIPS_Y_RES=24
		;;
		"0GC" | "0GD" | "0GR" | "0GS" | "0GT" | "0GU" )
			# Oasis...
			SCREEN_X_RES=1088
			SCREEN_Y_RES=1448
			EIPS_X_RES=16
			EIPS_Y_RES=24
		;;
		"0DU" | "0K9" | "0KA" )
			# KT3...
			SCREEN_X_RES=608
			SCREEN_Y_RES=800
			EIPS_X_RES=16
			EIPS_Y_RES=24
		;;
		"0LM" | "0LN" | "0LP" | "0LQ" | "0P1" | "0P2" | "0P6" | "0P7" | "0P8" | "0S1" | "0S2" | "0S3" | "0S4" | "0S7" | "0SA" )
			# Oasis 2...
			SCREEN_X_RES=1280
			SCREEN_Y_RES=1680
			EIPS_X_RES=16
			EIPS_Y_RES=24
		;;
		"0PP" | "0T1" | "0T2" | "0T3" | "0T4" | "0T5" | "0T6" | "0T7" | "0TJ" | "0TK" | "0TL" | "0TM" | "0TN" | "102" | "103" | "16Q" | "16R" | "16S" | "16T" | "16U" | "16V" )
			# PW4...
			SCREEN_X_RES=1088
			SCREEN_Y_RES=1448
			EIPS_X_RES=16
			EIPS_Y_RES=24
		;;
		"10L" | "0WF" | "0WG" | "0WH" | "0WJ" | "0VB" )
			# KT4...
			SCREEN_X_RES=608
			SCREEN_Y_RES=800
			EIPS_X_RES=16
			EIPS_Y_RES=24
		;;
		"11L" | "0WQ" | "0WP" | "0WN" | "0WM" | "0WL" )
			# Oasis 3...
			SCREEN_X_RES=1280
			SCREEN_Y_RES=1680
			EIPS_X_RES=16
			EIPS_Y_RES=24
		;;
		"1LG" | "1Q0" | "1PX" | "1VD" | "219" | "21A" | "2BH" | "2BJ" )
			# PaperWhite 5...
			SCREEN_X_RES=1236
			SCREEN_Y_RES=1648
			EIPS_X_RES=16
			EIPS_Y_RES=24
		;;
		* )
			# Fallback... We shouldn't ever hit that.
			SCREEN_X_RES=600
			SCREEN_Y_RES=800
			EIPS_X_RES=12
			EIPS_Y_RES=20
		;;
	esac
fi
# And now we can do the maths ;)
EIPS_MAXCHARS="$((${SCREEN_X_RES} / ${EIPS_X_RES}))"
EIPS_MAXLINES="$((${SCREEN_Y_RES} / ${EIPS_Y_RES}))"
