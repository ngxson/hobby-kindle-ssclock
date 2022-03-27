#!/usr/bin/env luajit

local cfg = require("config")
local ffi = require("ffi")
local C = ffi.C
local _ = require("ffi/fbink_h")
local FBInk = ffi.load("lib/libfbink.so.1.0.0")
print("Loaded FBInk " .. ffi.string(FBInk.fbink_version()))
local haslipc, lipc = pcall(require, "liblipclua")
local fbink_state = ffi.new("FBInkState")
local fbink_cfg = ffi.new("FBInkConfig")
local fbink_ot = ffi.new("FBInkOTConfig")

function os.executeCaptured(cmd)
  local f = assert(io.popen(cmd, "r"))
  local s = assert(f:read("*a"))
  f:close()
  s = string.gsub(s, "^%s+", "")
  s = string.gsub(s, "%s+$", "")
  s = string.gsub(s, "[\n\r]+", " ")
  return s
end

function getBatteryLevel()
	local lvl = os.executeCaptured("lipc-get-prop com.lab126.powerd battLevel")
	return tonumber(lvl)
end

-- Open the FB
local fbfd = FBInk.fbink_open()
if fbfd == -1 then
	print("Failed to open the framebuffer, aborting . . .")
	os.exit(-1)
end



-- Prepare
-- fbink_cfg.is_quiet = true
fbink_cfg.no_refresh = true
FBInk.fbink_add_ot_font_v2(
	cfg.FONT_FILE,
	0, -- regular
	fbink_ot
)
FBInk.fbink_init(fbfd, fbink_cfg)
FBInk.fbink_get_state(fbink_cfg, fbink_state)
local SCREEN_WIDTH = fbink_state.screen_width
local SCREEN_HEIGHT = fbink_state.screen_height
local LAST_DATE = ""

-- Set margins
local BORDER = cfg.DIALOG_BORDER
local DIALOG_PADDING_RIGHT = SCREEN_WIDTH - cfg.DIALOG_POSITION_X - cfg.DIALOG_SIZE_W
local DIALOG_PADDING_BOTTOM = SCREEN_HEIGHT - cfg.DIALOG_POSITION_Y - cfg.DIALOG_SIZE_H
fbink_ot.padding = 3 -- full padding
print()

function displayClock(battery_percent)
	local display_time = os.date(cfg.CLOCK_TIME_FORMAT)
	local display_date = os.date(cfg.CLOCK_DATE_FORMAT) .. "  | " .. battery_percent .. "%%"
	-- draw time
	fbink_ot.margins.left = cfg.TIME_X
	fbink_ot.margins.top = cfg.TIME_Y
	fbink_ot.margins.bottom = SCREEN_HEIGHT - (cfg.TIME_Y + cfg.TIME_FONT_SIZE_PX)
	fbink_ot.size_px = cfg.TIME_FONT_SIZE_PX
	FBInk.fbink_printf(fbfd, fbink_ot, fbink_cfg, display_time)
	-- draw date
	if LAST_DATE ~= display_date then
		fbink_ot.margins.left = cfg.DATE_X
		fbink_ot.margins.top = cfg.DATE_Y
		fbink_ot.margins.bottom = SCREEN_HEIGHT - (cfg.DATE_Y + cfg.DATE_FONT_SIZE_PX)
		fbink_ot.size_px = cfg.DATE_FONT_SIZE_PX
		FBInk.fbink_printf(fbfd, fbink_ot, fbink_cfg, display_date)
	end
	LAST_DATE = display_date
	-- flush to screen
	fbink_cfg.no_refresh = false
	FBInk.fbink_refresh(
		fbfd,
		cfg.DIALOG_POSITION_X - BORDER,
		cfg.DIALOG_POSITION_Y - BORDER,
		cfg.DIALOG_SIZE_W + 2*BORDER,
		cfg.DIALOG_SIZE_H + 2*BORDER,
		fbink_cfg
	)
	fbink_cfg.no_refresh = true
end

function drawDialogBackground()
	local inner_top = cfg.DIALOG_POSITION_Y
	local inner_right = DIALOG_PADDING_RIGHT
	local inner_left = cfg.DIALOG_POSITION_X
	local inner_bottom = DIALOG_PADDING_BOTTOM
	fbink_ot.size_px = cfg.TIME_FONT_SIZE_PX
	-- draw outer
	fbink_cfg.is_inverted = true
	fbink_ot.margins.top = inner_top - BORDER
	fbink_ot.margins.right = inner_right - BORDER
	fbink_ot.margins.left = inner_left - BORDER
	fbink_ot.margins.bottom = inner_bottom - BORDER
	FBInk.fbink_printf(fbfd, fbink_ot, fbink_cfg, " ")
	-- draw inner
	fbink_cfg.is_inverted = false
	fbink_ot.margins.top = inner_top
	fbink_ot.margins.right = inner_right
	fbink_ot.margins.left = inner_left
	fbink_ot.margins.bottom = inner_bottom
	FBInk.fbink_printf(fbfd, fbink_ot, fbink_cfg, " ")
end

-- for testing
-- drawDialogBackground()
-- displayClock(getBatteryLevel())
-- os.exit(0)



-- Main loop
while true do
	local state = os.executeCaptured("lipc-get-prop com.lab126.powerd state")
	local battery_percent = getBatteryLevel()

	if (state == "screenSaver" or state == "readyToSuspend" or state == "suspended") then
		-- screensaver is showing
		local current_seconds = os.time() % 60
		local wait_seconds = 60 - current_seconds + 1
		os.executeCaptured("rtcwake -d /dev/rtc1 -m no -s " .. wait_seconds)

		-- update the clock
		displayClock(battery_percent)

		-- put back to sleep mode
		os.execute("sleep 0.5")
		os.executeCaptured("rtcwake -d /dev/rtc1 -m mem -s " .. wait_seconds)
		os.execute("sleep 0.2")
	else
		-- screensaver is NOT showing
		-- we wait for user to enter screensaver mode
		LAST_DATE = ""
		os.executeCaptured("lipc-wait-event com.lab126.powerd goingToScreenSaver,readyToSuspend")
		os.execute("sleep 1.5")
		drawDialogBackground()
	end
end
