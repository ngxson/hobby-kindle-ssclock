local ssclockConfig = {
  CLOCK_TIME_FORMAT = "%H:%M", -- see below
  CLOCK_DATE_FORMAT = "%a, %d/%m", -- see below
  POSITION_X = 100, -- unit: pixel
  POSITION_Y = 100, -- unit: pixel
  TIME_FONT_SIZE_PX = 150, -- unit: pixel
  DATE_FONT_SIZE_PX = 50, -- unit: pixel
  DATE_LEFT_PADDING = 40, -- unit: pixel
  FONT_FILE = "/mnt/us/extensions/ssclock/IBMPlexSansArabic.ttf", -- ttf file
  DISABLE_BATT_LOWER_THAN = 10, -- disable when battery is lower than X percent
}

--[[
  TIME FORMAT:
  %H	hour, using a 24-hour clock (23) [00-23]
  %I	hour, using a 12-hour clock (11) [01-12]
  %M	minute (48) [00-59]
  %p	either "am" or "pm" (pm)

  DATE FORMAT:
  %a	abbreviated weekday name (e.g., Wed)
  %A	full weekday name (e.g., Wednesday)
  %b	abbreviated month name (e.g., Sep)
  %m	month (09) [01-12]
  %B	full month name (e.g., September)
  %c	date and time (e.g., 09/16/98 23:48:10)
  %d	day of the month (16) [01-31]
  %w	weekday (3) [0-6 = Sunday-Saturday]
  %x	date (e.g., 09/16/98)
  %X	time (e.g., 23:48:10)
  %Y	full year (1998)
  %y	two-digit year (98) [00-99]
  %%	the character `%´
--]]

return ssclockConfig