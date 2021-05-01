format_version = "1.0"

local inputs = { "A1", "A2", "A3", "A4", "A5", "A6", "B1", "B2", "B3", "B4", "B5", "B6" }

local propStateMultiStartTag = 2000
local propStateMidiStartTag = 3000
local propVolumeStartTag = 4000

local documentOwnerProperties = {}
local rtOwnerProperties = {}
local guiOwnerProperties = {}

-- control the mode for selecting the inputs
-- 0 = single, 1 = multi, 2 = midi1
documentOwnerProperties["prop_mode"] = jbox.number {
  property_tag = 1000,
  default = 0,
  steps = 3,
  ui_name = jbox.ui_text("propertyname prop_mode"),
  ui_type = jbox.ui_selector({
    jbox.ui_text("ui_selector prop_mode_single"),
    jbox.ui_text("ui_selector prop_mode_multi"),
    jbox.ui_text("ui_selector prop_mode_midi1"),
  })
}

local propStateRadioUISelector = {
  jbox.ui_text("propertyname prop_state_radio_selector_NONE")
}

local volumeGroupProperties = {}
local stateMultiGroupProperties = {}

for k, input in pairs(inputs) do

  -- contains the state of the individual switch when in multiple mode (one boolean per input)
  documentOwnerProperties["prop_state_multi_" .. input] = jbox.boolean{
    property_tag = propStateMultiStartTag + k - 1,
    default = false,
    ui_name = jbox.ui_text("propertyname prop_state_multi_" .. input),
    ui_type = jbox.ui_selector({jbox.UI_TEXT_OFF, jbox.UI_TEXT_ON})
  }

  stateMultiGroupProperties[#stateMultiGroupProperties + 1] = "/custom_properties/prop_state_multi_" .. input

  -- contains the state of the individual switch when in midi mode (one boolean per input)
  rtOwnerProperties["prop_state_midi_" .. input] = jbox.boolean{
    property_tag = propStateMidiStartTag + k - 1,
    default = false,
    ui_name = jbox.ui_text("propertyname prop_state_midi_" .. input),
    ui_type = jbox.ui_selector({jbox.UI_TEXT_OFF, jbox.UI_TEXT_ON})
  }
  -- number, nonlinear decibel:
  documentOwnerProperties["prop_volume_" .. input] = jbox.number{
    property_tag = propVolumeStartTag + k - 1,
    default = 0.7,
    ui_name = jbox.ui_text("propertyname prop_volume_" .. input),
    ui_type = jbox.ui_nonlinear{
      -- convert data range 0-1 to dB value using an x^3 curve. Data value 0.7 is 0 dB.
      data_to_gui = function(data_value)
        local gain = math.pow(data_value / 0.7, 3)
        local ui_value =  20 * math.log10(gain)
        return ui_value
      end,
      -- convert UI dB value to data range 0-1
      gui_to_data = function(gui_value)
        local data_value = math.pow(math.pow(10, gui_value / 20), 1/3) * 0.7
        return data_value
      end,
      units = {
        {min_value=0, unit = {template=jbox.ui_text("ui_type template prop_volume"), base=1}, decimals=2},
      },
    },
  }

  volumeGroupProperties[#volumeGroupProperties + 1] = "/custom_properties/prop_volume_" .. input

  -- label for switch
  guiOwnerProperties["prop_label_" .. input] = jbox.string {
    persistence = "patch",
    default = input
  }

  propStateRadioUISelector[#propStateRadioUISelector + 1] = jbox.ui_text("propertyname prop_state_radio_selector_" .. input)
end

-- contains the state of the switch when in single mode (1 - 12) / 0 is nothing selected
documentOwnerProperties["prop_state_single"] = jbox.number {
  property_tag = 1010,
  default = 1,
  steps = #inputs + 1,
  ui_name = jbox.ui_text("propertyname prop_state_single"),
  ui_type = jbox.ui_selector(propStateRadioUISelector)
}

-- contains the state of the switch coming from CV input (1 - 12) / 0 is nothing selected
rtOwnerProperties["prop_state_single_cv"] = jbox.number {
  default = 0,
  steps = #inputs + 1,
  ui_name = jbox.ui_text("propertyname prop_state_single_cv"),
  ui_type = jbox.ui_selector(propStateRadioUISelector)
}

-- this property is only used to tell c++ code to override cv (note that it is used as a toggle, not absolute value!)
documentOwnerProperties["prop_state_single_override_cv"] = jbox.boolean{
  property_tag = 1020,
  default = false,
  persistence="none",
  ui_name = jbox.ui_text("TBD"),
  ui_type = jbox.ui_selector({jbox.UI_TEXT_OFF, jbox.UI_TEXT_ON})
}

-- this property is a toggle to turn volume change filtering on or off
documentOwnerProperties["prop_volume_change_filter"] = jbox.boolean{
  property_tag = 1030,
  default = true,
  ui_name = jbox.ui_text("propertyname prop_volume_change_filter"),
  ui_type = jbox.ui_selector {
    jbox.ui_text("propertyname prop_volume_change_filter off"),
    jbox.ui_text("propertyname prop_volume_change_filter on")
  },
}

-- this property toggles soften mode (short xfade when inputs change)
documentOwnerProperties["prop_soften"] = jbox.boolean{
  property_tag = 1040,
  default = false,
  ui_name = jbox.ui_text("propertyname prop_soften"),
  ui_type = jbox.ui_selector {
    jbox.ui_text("propertyname prop_soften off"),
    jbox.ui_text("propertyname prop_soften on")
  },
}

-- control which bank is selected
-- 0 = none, 1 = A, 2 = B, 3 = A+B
documentOwnerProperties["prop_bank"] = jbox.number {
  property_tag = 1050,
  default = 3,
  steps = 4,
  ui_name = jbox.ui_text("propertyname prop_bank"),
  ui_type = jbox.ui_selector({
    jbox.ui_text("ui_selector prop_bank_none"),
    jbox.ui_text("ui_selector prop_bank_A"),
    jbox.ui_text("ui_selector prop_bank_B"),
    jbox.ui_text("ui_selector prop_bank_AB"),
  })
}

-- this property is only used to tell c++ code to override cv (note that it is used as a toggle, not absolute value!)
documentOwnerProperties["prop_bank_override_cv"] = jbox.boolean{
  property_tag = 1060,
  default = false,
  persistence="none",
  ui_name = jbox.ui_text("TBD"),
  ui_type = jbox.ui_selector({jbox.UI_TEXT_OFF, jbox.UI_TEXT_ON})
}

-- contains the bank coming from CV input / 0 = no cv / 1 = none, 2 = A, 3 = B, 4 = A+B
rtOwnerProperties["prop_bank_cv"] = jbox.number {
  default = 0,
  steps = 5,
  ui_name = jbox.ui_text("propertyname prop_bank"),
  ui_type = jbox.ui_selector({
    jbox.ui_text("TBD"),
    jbox.ui_text("TBD"),
    jbox.ui_text("TBD"),
    jbox.ui_text("TBD"),
    jbox.ui_text("TBD"),
  })
}

-- this property is no longer used (replaced by prop_bank_toggle_number)
guiOwnerProperties["prop_bank_toggle"] = jbox.boolean {
  default = false,
  persistence="none",
  ui_name = jbox.ui_text("TBD"),
  ui_type = jbox.ui_selector({jbox.UI_TEXT_OFF, jbox.UI_TEXT_ON})
}

-- this property is only used by the UI/custom display momentary button to display the right image
guiOwnerProperties["prop_bank_toggle_number"] = jbox.number {
  default = 0,
  steps = 2,
  persistence="none",
  ui_name = jbox.ui_text("TBD"),
  ui_type = jbox.ui_selector({jbox.UI_TEXT_OFF, jbox.UI_TEXT_ON})
}

-- control how to map prop bank cv to prop_bank property
-- 0 = unipolar, 1 = bipolar, 2 = note
documentOwnerProperties["prop_bank_cv_mapping"] = jbox.number {
  property_tag = 1070,
  default = 1, -- bipolar
  steps = 3,
  ui_name = jbox.ui_text("propertyname prop_bank_cv_mapping"),
  ui_type = jbox.ui_selector({
    jbox.ui_text("ui_selector prop_bank_cv_mapping_unipolar"),
    jbox.ui_text("ui_selector prop_bank_cv_mapping_bipolar"),
    jbox.ui_text("ui_selector prop_bank_cv_mapping_note"),
  })
}

-- this property enables keyboard in single mode (default is for backward compatibility)
documentOwnerProperties["prop_state_single_keyboard_enabled"] = jbox.boolean{
  property_tag = 1080,
  default = false,
  ui_name = jbox.ui_text("propertyname prop_state_single_keyboard_enabled"),
  ui_type = jbox.ui_selector {
    jbox.ui_text("propertyname prop_state_single_keyboard_enabled off"),
    jbox.ui_text("propertyname prop_state_single_keyboard_enabled on")
  },
}

--[[
Custom properties
--]]
custom_properties = jbox.property_set {
  gui_owner = {
    properties = guiOwnerProperties
  },

  document_owner = {
    properties = documentOwnerProperties
  },
	
  rtc_owner = {
    properties = {
      instance = jbox.native_object{ },
    }
  },
	
  rt_owner = {
    properties = rtOwnerProperties
  }
}

--[[ 
Inputs/Outputs
--]]


audio_inputs = {}
cv_inputs = {}
cv_outputs = {}

for k, input in pairs(inputs) do
  -- defines the audio socket (left)
  local leftSocket = "audioInputLeft" .. input
  audio_inputs[leftSocket] = jbox.audio_input {
    ui_name = jbox.ui_text(leftSocket)
  }
  -- defines the audio socket (right)
  local rightSocket = "audioInputRight" .. input
  audio_inputs[rightSocket] = jbox.audio_input {
    ui_name = jbox.ui_text(rightSocket)
  }
  -- it is a stereo pair => should be auto routed
  jbox.add_stereo_audio_routing_pair {
    left = "/audio_inputs/" .. leftSocket,
    right = "/audio_inputs/" .. rightSocket
  }
end

audio_outputs = {
  audioOutputLeft = jbox.audio_output {
    ui_name = jbox.ui_text("audio output main left")
  },
  audioOutputRight = jbox.audio_output {
    ui_name = jbox.ui_text("audio output main right")
  }
}

-- defines routing pairs for stereo (Reason will wire left and right automatically)

jbox.add_stereo_audio_routing_pair {
  left = "/audio_outputs/audioOutputLeft",
  right = "/audio_outputs/audioOutputRight"
}

-- The 45 should be routed as a stereo instrument
jbox.add_stereo_instrument_routing_hint {
  left_output = "/audio_outputs/audioOutputLeft",
  right_output = "/audio_outputs/audioOutputRight"
}
-- Sockets on the back panel of the 45 that the host can auto-route to
jbox.add_stereo_audio_routing_target{
  signal_type = "normal",
  left = "/audio_outputs/audioOutputLeft",
  right = "/audio_outputs/audioOutputRight",
  auto_route_enable = true
}

-- defines the cv socket
cv_inputs["cv_in_state_single"] = jbox.cv_input {
  ui_name = jbox.ui_text("propertyname cv_in_state_single")
}

cv_inputs["cv_in_bank"] = jbox.cv_input {
  ui_name = jbox.ui_text("propertyname cv_in_bank")
}

-- new in 1.1.0 (need to be after!)
for k, input in pairs(inputs) do
  -- defines the gate in cv socket
  cv_inputs["cv_in_gate_" .. input] = jbox.cv_input {
    ui_name = jbox.ui_text("propertyname cv_in_gate_" .. input)
  }
  -- defines the gate out cv socket
  cv_outputs["cv_out_gate_" .. input] = jbox.cv_output {
    ui_name = jbox.ui_text("propertyname cv_out_gate_" .. input)
  }

end

-- groupings
ui_groups = {
  {
    ui_name = jbox.ui_text("ui_group state_multi"),
    properties = stateMultiGroupProperties
  },
  {
    ui_name = jbox.ui_text("ui_group volume"),
    properties = volumeGroupProperties
  },
}

-- allow for automation
midi_implementation_chart = {
  midi_cc_chart = {
    [12] = "/custom_properties/prop_state_single",
    [13] = "/custom_properties/prop_bank",
    [14] = "/custom_properties/prop_mode",
    [15] = "/custom_properties/prop_soften",
  }
}

local volumeCCChart = 16
local stateMultiCCChart = 40

remote_implementation_chart = {
  ["/custom_properties/prop_state_single"] = {
    internal_name = "Switch State Single",
    short_ui_name = jbox.ui_text("ric short_ui_name prop_state_single"),
    shortest_ui_name = jbox.ui_text("ric shortest_ui_name prop_state_single")
  },
  ["/custom_properties/prop_bank"] = {
    internal_name = "A/B Bank Selection",
    short_ui_name = jbox.ui_text("ric short_ui_name prop_bank"),
    shortest_ui_name = jbox.ui_text("ric shortest_ui_name prop_bank")
  },
  ["/custom_properties/prop_mode"] = {
    internal_name = "A/B Mode",
    short_ui_name = jbox.ui_text("ric short_ui_name prop_mode"),
    shortest_ui_name = jbox.ui_text("ric shortest_ui_name prop_mode")
  },
  ["/custom_properties/prop_soften"] = {
    internal_name = "Soften",
    short_ui_name = jbox.ui_text("ric short_ui_name prop_soften"),
    shortest_ui_name = jbox.ui_text("ric shortest_ui_name prop_soften")
  },
}

for k, input in pairs(inputs) do
  midi_implementation_chart["midi_cc_chart"][volumeCCChart + k - 1] = "/custom_properties/prop_volume_" .. input
  remote_implementation_chart["/custom_properties/prop_volume_" .. input] = {
    internal_name = "Volume [" .. input .. "]",
    short_ui_name = jbox.ui_text("ric short_ui_name prop_volume_" .. input),
    shortest_ui_name = jbox.ui_text("ric shortest_ui_name prop_volume_" .. input)
  }
end

for k, input in pairs(inputs) do
  midi_implementation_chart["midi_cc_chart"][stateMultiCCChart + k - 1] = "/custom_properties/prop_state_multi_" .. input
  remote_implementation_chart["/custom_properties/prop_state_multi_" .. input] = {
    internal_name = "Multi [" .. input .. "]",
    short_ui_name = jbox.ui_text("ric short_ui_name prop_state_multi_" .. input),
    shortest_ui_name = jbox.ui_text("ric shortest_ui_name prop_state_multi_" .. input)
  }
end