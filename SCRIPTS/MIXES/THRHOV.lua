local EDGE_MIN = -1024
local EDGE_MAX = 1024
local EDGE_SPAN = 2048

local X_MIN = 0.20
local X_MAX = 0.80
local X_RANGE = X_MAX - X_MIN

local GV_EXPO_DOWN = 0 -- GV1, EdgeTX Lua indexes from 0.
local GV_EXPO_UP = 1 -- GV2
local GV_UP_SCALE = 2 -- GV3
local GV_MAX = 3 -- GV4

local EXPO_MIN = 0.00
local EXPO_MAX = 0.95
local SCALE_MIN = 0.00
local SCALE_MAX = 1.00
local MAX_MIN = 0.30
local MAX_MAX = 1.00

local S1_TOLERANCE = 164 -- About 8% of the full -1024..+1024 range.
local ARM_THRESHOLD = 0
local ALARM_PERIOD = 100 -- getTime() ticks are 1/100s, so this is about 1s.

local xLocked = 0.50
local wasArmed = false
local lastAlarmAt = -ALARM_PERIOD

local inputs = {
  { "Thr", SOURCE },
  { "S1", SOURCE },
  { "Arm", SOURCE },
}

local outputs = { "ThrOut" }

local function clamp(value, minValue, maxValue)
  if value == nil then
    return minValue
  end
  if value < minValue then
    return minValue
  end
  if value > maxValue then
    return maxValue
  end
  return value
end

local function round(value)
  if value >= 0 then
    return math.floor(value + 0.5)
  end
  return math.ceil(value - 0.5)
end

local function isArmed(arm)
  if type(arm) == "boolean" then
    return arm
  end
  return (arm or EDGE_MIN) > ARM_THRESHOLD
end

local function getCurrentFlightMode()
  local fm = getFlightMode()
  return fm or 0
end

local function rawToValue(raw, minValue, maxValue)
  local gv = clamp(raw or EDGE_MIN, EDGE_MIN, EDGE_MAX)
  return minValue + ((gv - EDGE_MIN) / EDGE_SPAN) * (maxValue - minValue)
end

local function getSetting(gvIndex, minValue, maxValue)
  local gv = model.getGlobalVariable(gvIndex, getCurrentFlightMode())
  gv = clamp(gv or EDGE_MIN, EDGE_MIN, EDGE_MAX)
  return rawToValue(gv, minValue, maxValue)
end

local function getThrottleSettings()
  return {
    expoDown = getSetting(GV_EXPO_DOWN, EXPO_MIN, EXPO_MAX),
    expoUp = getSetting(GV_EXPO_UP, EXPO_MIN, EXPO_MAX),
    upScale = getSetting(GV_UP_SCALE, SCALE_MIN, SCALE_MAX),
    maxPct = getSetting(GV_MAX, MAX_MIN, MAX_MAX),
  }
end

local function xFromS1(s1)
  local raw = clamp(s1 or 0, EDGE_MIN, EDGE_MAX)
  return X_MIN + ((raw - EDGE_MIN) / EDGE_SPAN) * X_RANGE
end

local function s1FromX(x)
  local bounded = clamp(x or 0.50, X_MIN, X_MAX)
  return EDGE_MIN + ((bounded - X_MIN) / X_RANGE) * EDGE_SPAN
end

local function s1MatchesLockedX(s1)
  local raw = clamp(s1 or 0, EDGE_MIN, EDGE_MAX)
  local expected = s1FromX(xLocked)
  return math.abs(raw - expected) <= S1_TOLERANCE
end

local function alarmPreArm()
  local now = getTime()
  if now - lastAlarmAt < ALARM_PERIOD then
    return
  end

  lastAlarmAt = now
  playTone(880, 120, 0)
  if type(playHaptic) == "function" then
    playHaptic(120, 0)
  end
end

local function expoCurve(u, expo)
  local boundedU = clamp(u or -1, -1, 1)
  local boundedExpo = clamp(expo or 0, 0, EXPO_MAX)
  return (1 - boundedExpo) * boundedU + boundedExpo * boundedU * boundedU * boundedU
end

local function throttleToOutput(thr, x, settings)
  local u = clamp(thr or EDGE_MIN, EDGE_MIN, EDGE_MAX) / EDGE_MAX
  local hover = clamp(x or xLocked, X_MIN, X_MAX)
  local maxPct = clamp(settings.maxPct or MAX_MAX, hover, MAX_MAX)
  local shaped
  local pct

  if u < 0 then
    shaped = clamp(expoCurve(u, settings.expoDown), -1, 0)
    pct = hover * (shaped + 1)
  else
    shaped = clamp(expoCurve(u, settings.expoUp) * clamp(settings.upScale, SCALE_MIN, SCALE_MAX), 0, 1)
    pct = hover + (maxPct - hover) * shaped
  end

  return clamp(round(pct * EDGE_SPAN + EDGE_MIN), EDGE_MIN, EDGE_MAX)
end

local function run(thr, s1, arm)
  local armed = isArmed(arm)

  if armed and not wasArmed and not s1MatchesLockedX(s1) then
    alarmPreArm()
    wasArmed = false
    return EDGE_MIN
  end

  if armed then
    xLocked = xFromS1(s1)
  end

  wasArmed = armed
  return throttleToOutput(thr, xLocked, getThrottleSettings())
end

return {
  input = inputs,
  output = outputs,
  run = run,
}
