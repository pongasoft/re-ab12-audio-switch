local inputs = { "A1", "A2", "A3", "A4", "A5", "A6", "B1", "B2", "B3", "B4", "B5", "B6" }

local output = {}

for k, input in pairs(inputs) do
  output[#output + 1] = string.format("SwitchGesture%s = gestureFunction{ on_tap = \"SwitchTap%s\" }", input, input)
  output[#output + 1] = string.format("SwitchTap%s = switchTapFunction(%d, \"%s\")", input, k, input)
  output[#output + 1] = string.format("SwitchDraw%s = switchDrawFunction(%d, \"%s\")", input, k, string.sub(input, 1, 1))
end

for k, output in pairs(output) do
  print(output)
end