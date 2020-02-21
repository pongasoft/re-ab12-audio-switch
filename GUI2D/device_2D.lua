format_version = "1.0"

local banks = {
  columns = { 228, 906, 2218, 2896 },
  rows = { 40, 245, 455 }
}

function computeOffset(absoluteCenter, absoluteCoordinates)
  return { absoluteCoordinates[1] - absoluteCenter[1], absoluteCoordinates[2] - absoluteCenter[2] }
end

function computeAbsolute(absoluteCenter, offsetCoordinates)
  return { absoluteCenter[1] + offsetCoordinates[1], absoluteCenter[2] + offsetCoordinates[2] }
end

local offsets = {
  -- left column (1)
  left = {
    label = computeOffset({banks["columns"][1], banks["rows"][1]}, { 260, 100 }),
    switch = computeOffset({banks["columns"][1], banks["rows"][1]}, { 730, 90 }),
    volume = computeOffset({banks["columns"][1], banks["rows"][1]}, { 590, 90 }),
  },

  -- right column (2)
  right = {
    label = computeOffset({banks["columns"][2], banks["rows"][1]}, { 1220, 100 }),
    switch = computeOffset({banks["columns"][2], banks["rows"][1]}, { 950, 90 }),
    volume = computeOffset({banks["columns"][2], banks["rows"][1]}, { 1080, 90 }),
  },
}

local foldedFrontA1 = { 600, 30 }
local foldedFrontB1 = { 2270, 30 }
local foldedFrontSpacing = 160

local audioJackA1 = { 275, 150 }
local audioJackRightOffset = computeOffset(audioJackA1, {275, 265})
local gateInOffset = computeOffset(audioJackA1, {280, 400})
local gateOutOffset = computeOffset(audioJackA1, {280, 505})

local audioJackB1 = { 1180, 150 }

-- audio jacks
local inputSpacingX = computeOffset( audioJackA1, {390,150})[1]

local audioJackleftRightSpacing = { 100, 0 }

local inputs = {
  A1 = { f = { c = 1, r = 1, o = "left"}, b = {c = 1, r = 1 }, ff = 0 },
  A2 = { f = { c = 1, r = 2, o = "left"}, b = {c = 2, r = 1 }, ff = 1},
  A3 = { f = { c = 1, r = 3, o = "left"}, b = {c = 3, r = 1 }, ff = 2 },
  A4 = { f = { c = 2, r = 1, o = "right"}, b = {c = 4, r = 1 }, ff = 3 },
  A5 = { f = { c = 2, r = 2, o = "right"}, b = {c = 5, r = 1 }, ff = 4 },
  A6 = { f = { c = 2, r = 3, o = "right"}, b = {c = 6, r = 1 }, ff = 5 },
  B1 = { f = { c = 3, r = 1, o = "left"}, b = {c = 1, r = 2 }, ff = 0 },
  B2 = { f = { c = 3, r = 2, o = "left"}, b = {c = 2, r = 2 }, ff = 1 },
  B3 = { f = { c = 3, r = 3, o = "left"}, b = {c = 3, r = 2 }, ff = 2 },
  B4 = { f = { c = 4, r = 1, o = "right"}, b = {c = 4, r = 2 }, ff = 3 },
  B5 = { f = { c = 4, r = 2, o = "right"}, b = {c = 5, r = 2 }, ff = 4 },
  B6 = { f = { c = 4, r = 3, o = "right"}, b = {c = 6, r = 2 }, ff = 5 },
}

for k, input in pairs(inputs) do
  local back = input["b"]
  local audioJack = audioJackA1
  local ffSwitch = foldedFrontA1
  if back["r"] == 2 then
    audioJack = audioJackB1
    ffSwitch = foldedFrontB1
  end

  -- back
  input.audioJackLeft = computeAbsolute(audioJack, { inputSpacingX * (back["c"] - 1), 0 })

  -- front
  local front = input["f"]
  input["label"] =  computeAbsolute({banks["columns"][front["c"]], banks["rows"][front["r"]]}, offsets[front["o"]]["label"])
  input["switch"] = computeAbsolute({banks["columns"][front["c"]], banks["rows"][front["r"]]}, offsets[front["o"]]["switch"])
  input["volume"] = computeAbsolute({banks["columns"][front["c"]], banks["rows"][front["r"]]}, offsets[front["o"]]["volume"])

  -- folded front
  input["switchFF"] = computeAbsolute(ffSwitch, { foldedFrontSpacing * input["ff"], 0 })

end

-- front
front = {
  Bg = {
    { path = "Panel_Front" },
  },

  TapeFront = {
    offset = { 52, 147 },
    { path = "TapeVert" },
  },
  
  -- mode Buttons
  {
    ModeSingleButton = {
      offset = { 1705, 452 },
      { path = "Button_Single_2frames", frames = 2 },
    },

    ModeMultiButton = {
      offset = { 1850, 452 },
      { path = "Button_Multi_2frames", frames = 2 },
    },

    ModeMidi1Button = {
      offset = { 1990, 452 },
      { path = "Button_Midi_2frames", frames = 2 },
    },
  },

  -- Bank Buttons
  {
    BankToggle = {
      offset = { 1800, 270 },
      { path = "BankToggleCustomDisplay" },

    }
  },

  {
    BankToggleA = {
      offset = { 1660, 300 },
      { path = "BankToggleACustomDisplay" },
    }
  },

  {
    BankToggleB = {
      offset = { 2010, 300 },
      { path = "BankToggleBCustomDisplay" },
    }
  },

  -- soften
  {
    SoftenButton = {
      offset = { 1791, 588 },
      { path = "Button_18_2frames", frames = 2 },
    },

  },

  -- CV Single State LED
  {
    SingleStateCVLED = {
      offset = { 2127, 585 },
      { path = "Lamp_Bank_CV_13frames", frames = 13 },
    },

  },

  -- CV Bank LED
  {
    BankCVLED = {
      offset = { 2127, 633 },
      { path = "Lamp_Bank_CV_5frames", frames = 5 },
    },

  },

}

-- back
back = {
  Bg = {
    { path = "Panel_Back" },
  },

  TapeBack = {
    offset = { 3100, 190 },
    { path = "TapeHoriz" },
  },

  Placeholder = {
    offset = { 1715, 15 },
    { path = "Placeholder" }
  },

  -- main audio out
  {
    offset = { 2745, 510 },
    audioOutputStereoPairLeft = {
      offset = { 0, 0 },
      { path = "SharedAudioJack", frames = 3 }
    },
    audioOutputStereoPairRight = {
      offset = audioJackleftRightSpacing,
      { path = "SharedAudioJack", frames = 3 }
    },
  },

  -- cv in state single
  CVInStateSingle = {
    offset = { 2005, 545 },
    { path = "SharedCVJack", frames = 3 }
  },

  -- state single keyboard enabled
  StateSingleKeyboardEnabled = {
    offset = { 2175, 530},
    { path = "Toggle_2frames", frames = 2 }
  },

  -- cv in state single
  CVInBank = {
    offset = { 2020, 190},
    { path = "SharedCVJack", frames = 3 }
  },

  -- toggle filter on volume change
  VolumeChangeFilter = {
    offset = { 2665, 170},
    { path = "Toggle_2frames", frames = 2 }
  },

  -- toggle bank cv mapping
  BankCV = {
    offset = { 2132, 143},
    { path = "Toggle_Fader_3frames", frames = 3 }
  },
}

-- folded front
folded_front = {
  Bg = {
    { path = "Panel_Folded_Front" },
  },

  TapeFoldedFront = {
    offset = { 130, 42 },
    { path = "TapeHoriz" },
  },
}


for k, input in pairs(inputs) do
  -- back extras
  back[#back + 1] = {
    -- audio/cv inputs
    offset = input.audioJackLeft,
    ["audioInputStereoPairLeft" .. k] = {
      offset = { 0, 0 },
      { path = "SharedAudioJack", frames = 3 }
    },
    ["audioInputStereoPairRight" .. k] = {
      offset = audioJackRightOffset,
      { path = "SharedAudioJack", frames = 3 }
    },
    ["CVInGate" .. k] = {
      offset = gateInOffset,
      { path = "SharedCVJack", frames = 3 }
    },
    ["CVOutGate" .. k] = {
      offset = gateOutOffset,
      { path = "SharedCVJack", frames = 3 }
    },
  }

  -- volume knob
  front[#front +1] = {
    offset = input.volume,
    ["Volume" .. k] = {
      { path = "Knob_94_63frames", frames = 63 }
    }
  }

  -- switch
  front[#front + 1] = {
    ["Switch" .. k] = {
      offset = input.switch,
      { path = "SwitchCustomDisplay" },
    },
  }

  -- label
  front[#front + 1] = {
    ["Label" .. k] = {
    offset = input.label,
      { path = "SmallDisplaySurface" },
    }
  }

  -- folded front switch
  folded_front[#folded_front + 1] = {
    ["SwitchFolded" .. k] = {
      offset = input.switchFF,
      { path = "SwitchCustomDisplay" },
    }
  }
end

-- folded back
folded_back = {
  Bg = {
    { path = "Panel_Folded_Back" },
  },

  TapeFoldedBack = {
    offset = { 230, 40 },
    { path = "TapeHoriz" },
  },

  CableOrigin = {
    offset = { 1875, 75 },
  },
}