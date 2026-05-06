local GV_EXPO = 0 -- GV1, EdgeTX Lua indexes from 0.
local EDGE_MIN = -1024
local EDGE_MAX = 1024
local EDGE_SPAN = 2048
local EXPO_MIN = 0.00
local EXPO_MAX = 0.80
local EXPO_STEP = 0.01

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

local function currentFlightMode()
  local fm = getFlightMode()
  return fm or 0
end

local function rawToExpo(raw)
  local gv = clamp(raw or EDGE_MIN, EDGE_MIN, EDGE_MAX)
  return ((gv - EDGE_MIN) / EDGE_SPAN) * EXPO_MAX
end

local function expoToRaw(expo)
  local value = clamp(expo or EXPO_MIN, EXPO_MIN, EXPO_MAX)
  return clamp(round((value / EXPO_MAX) * EDGE_SPAN + EDGE_MIN), EDGE_MIN, EDGE_MAX)
end

local function getExpo()
  return rawToExpo(model.getGlobalVariable(GV_EXPO, currentFlightMode()))
end

local function setExpo(expo)
  model.setGlobalVariable(GV_EXPO, currentFlightMode(), expoToRaw(expo))
end

local function isIncEvent(event)
  return event == EVT_PLUS_BREAK
    or event == EVT_PLUS_REPT
    or event == EVT_VIRTUAL_INC
    or event == EVT_VIRTUAL_INC_REPT
    or event == EVT_ROT_RIGHT
end

local function isDecEvent(event)
  return event == EVT_MINUS_BREAK
    or event == EVT_MINUS_REPT
    or event == EVT_VIRTUAL_DEC
    or event == EVT_VIRTUAL_DEC_REPT
    or event == EVT_ROT_LEFT
end

local function drawScreen(expo)
  lcd.clear()

  lcd.drawText(2, 1, "THRHOV EXPO", MIDSIZE)
  lcd.drawLine(0, 14, LCD_W, 14, SOLID, FORCE)

  lcd.drawText(2, 23, "Expo", 0)
  lcd.drawText(42, 20, string.format("%.2f", expo), DBLSIZE)

  local barX = 2
  local barY = LCD_H - 14
  local barW = LCD_W - 4
  local fillW = math.floor((expo / EXPO_MAX) * barW)

  lcd.drawRectangle(barX, barY, barW, 8)
  if fillW > 1 then
    lcd.drawFilledRectangle(barX + 1, barY + 1, fillW - 1, 6)
  end
end

local function run(event)
  local expo = getExpo()

  if isIncEvent(event) then
    expo = clamp(expo + EXPO_STEP, EXPO_MIN, EXPO_MAX)
    setExpo(expo)
  elseif isDecEvent(event) then
    expo = clamp(expo - EXPO_STEP, EXPO_MIN, EXPO_MAX)
    setExpo(expo)
  end

  drawScreen(getExpo())
end

return {
  run = run,
}
