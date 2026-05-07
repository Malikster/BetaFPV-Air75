local GV_EXPO_DOWN = 0 -- GV1, EdgeTX Lua indexes from 0.
local GV_EXPO_UP = 1 -- GV2
local GV_UP_SCALE = 2 -- GV3
local GV_MAX = 3 -- GV4

local EDGE_MIN = -1024
local EDGE_MAX = 1024
local EDGE_SPAN = 2048
local VALUE_STEP = 0.01

local selected = 1

local fields = {
  { label = "Expo Down", gv = GV_EXPO_DOWN, min = 0.00, max = 0.95 },
  { label = "Expo Up", gv = GV_EXPO_UP, min = 0.00, max = 0.95 },
  { label = "Up Scale", gv = GV_UP_SCALE, min = 0.00, max = 1.00 },
  { label = "Max", gv = GV_MAX, min = 0.30, max = 1.00 },
}

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

local function rawToValue(raw, minValue, maxValue)
  local gv = clamp(raw or EDGE_MIN, EDGE_MIN, EDGE_MAX)
  return minValue + ((gv - EDGE_MIN) / EDGE_SPAN) * (maxValue - minValue)
end

local function valueToRaw(value, minValue, maxValue)
  local bounded = clamp(value or minValue, minValue, maxValue)
  return clamp(round(((bounded - minValue) / (maxValue - minValue)) * EDGE_SPAN + EDGE_MIN), EDGE_MIN, EDGE_MAX)
end

local function getValue(field)
  return rawToValue(model.getGlobalVariable(field.gv, currentFlightMode()), field.min, field.max)
end

local function setValue(field, value)
  model.setGlobalVariable(field.gv, currentFlightMode(), valueToRaw(value, field.min, field.max))
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

local function isEnterEvent(event)
  return event == EVT_ENTER_BREAK
    or event == EVT_VIRTUAL_ENTER
    or event == EVT_ROT_BREAK
end

local function drawRow(y, field, value, isSelected)
  local flags = isSelected and INVERS or 0
  if isSelected then
    lcd.drawFilledRectangle(0, y - 1, LCD_W, 9, SOLID)
  end
  lcd.drawText(2, y, field.label, flags)
  lcd.drawText(LCD_W - 34, y, string.format("%.2f", value), flags)
end

local function drawScreen()
  lcd.clear()

  lcd.drawText(2, 1, "THRHOV SETTINGS", 0)
  lcd.drawLine(0, 14, LCD_W, 14, SOLID, FORCE)

  for index, field in ipairs(fields) do
    drawRow(17 + (index - 1) * 10, field, getValue(field), index == selected)
  end

  lcd.drawText(2, LCD_H - 8, "ENTER=next +/-=edit", SMLSIZE)
end

local function run(event)
  local field = fields[selected]

  if isEnterEvent(event) then
    selected = selected + 1
    if selected > #fields then
      selected = 1
    end
  elseif isIncEvent(event) then
    setValue(field, clamp(getValue(field) + VALUE_STEP, field.min, field.max))
  elseif isDecEvent(event) then
    setValue(field, clamp(getValue(field) - VALUE_STEP, field.min, field.max))
  end

  drawScreen()
end

return {
  run = run,
}
