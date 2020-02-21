format_version = "1.0"

local inputs = { "A1", "A2", "A3", "A4", "A5", "A6", "B1", "B2", "B3", "B4", "B5", "B6" }

-- front Widgets
frontWidgets = {

  -- device name / tape
  jbox.device_name {
    graphics = {
      node = "TapeFront",
    },
  },

  -- prop_mode
  jbox.radio_button{
    graphics = {
      node = "ModeSingleButton",
    },
    value = "/custom_properties/prop_mode",
    index = 0,
  },

  jbox.radio_button{
    graphics = {
      node = "ModeMultiButton",
    },
    value = "/custom_properties/prop_mode",
    index = 1,
  },

  jbox.radio_button{
    graphics = {
      node = "ModeMidi1Button",
    },
    value = "/custom_properties/prop_mode",
    index = 2,
  },

  -- prop_bank
  jbox.custom_display{
    graphics = {
      node = "BankToggle",
    },
    background = jbox.image{path = "BankToggleCustomDisplayBackground"},
    display_width_pixels = math.floor(160 / 5),
    display_height_pixels = math.floor(145 / 5),
    draw_function = "BankToggleDraw",
    gesture_function ="BankToggleGesture",
    values = {
      "/custom_properties/prop_bank",
      "/custom_properties/prop_bank_cv",
      "/custom_properties/prop_bank_override_cv",
      "/custom_properties/prop_bank_toggle"
    },
  },

  jbox.custom_display{
    graphics = {
      node = "BankToggleA",
    },
    background = jbox.image{path = "BankToggleACustomDisplayBackground"},
    display_width_pixels = math.floor(100 / 5),
    display_height_pixels = math.floor(90 / 5),
    draw_function = "BankToggleDrawA",
    gesture_function ="BankToggleGestureA",
    values = {
      "/custom_properties/prop_bank",
      "/custom_properties/prop_bank_cv",
      "/custom_properties/prop_bank_override_cv",
    },
  },

  jbox.custom_display{
    graphics = {
      node = "BankToggleB",
    },
    background = jbox.image{path = "BankToggleBCustomDisplayBackground"},
    display_width_pixels = math.floor(100 / 5),
    display_height_pixels = math.floor(90 / 5),
    draw_function = "BankToggleDrawB",
    gesture_function ="BankToggleGestureB",
    values = {
      "/custom_properties/prop_bank",
      "/custom_properties/prop_bank_cv",
      "/custom_properties/prop_bank_override_cv",
    },
  },

  -- prop_soften
  jbox.toggle_button {
    graphics = {
      node = "SoftenButton",
    },
    value = "/custom_properties/prop_soften"
  },

  -- prop_state_single_cv
  jbox.sequence_meter {
    graphics = {
      node = "SingleStateCVLED",
    },
    value = "/custom_properties/prop_state_single_cv"
  },

  -- prop_bank_cv
  jbox.sequence_meter {
    graphics = {
      node = "BankCVLED",
    },
    value = "/custom_properties/prop_bank_cv"
  },

}

-- front
front = jbox.panel {
  graphics = {
    node = "Bg",
  },
  widgets = frontWidgets,
}

-- backWidgets
backWidgets = {

  -- device name / tape
  jbox.device_name {
    graphics = {
      node = "TapeBack",
    },
  },

  -- placeholder
  jbox.placeholder {
    graphics = {
      node = "Placeholder",
    },
  },

  -- audio output
  jbox.audio_output_socket {
    graphics = {
      node = "audioOutputStereoPairLeft",
    },
    socket = "/audio_outputs/audioOutputLeft",
  },
  jbox.audio_output_socket {
    graphics = {
      node = "audioOutputStereoPairRight",
    },
    socket = "/audio_outputs/audioOutputRight",
  },

  -- cv input
  jbox.cv_input_socket{
    graphics = {
      node = "CVInStateSingle",
    },
    socket = "/cv_inputs/cv_in_state_single",
  },

  jbox.toggle_button {
    graphics = {
      node = "StateSingleKeyboardEnabled",
    },
    value = "/custom_properties/prop_state_single_keyboard_enabled"
  },

  jbox.cv_input_socket{
    graphics = {
      node = "CVInBank",
    },
    socket = "/cv_inputs/cv_in_bank",
  },

  jbox.toggle_button {
    graphics = {
      node = "VolumeChangeFilter",
    },
    value = "/custom_properties/prop_volume_change_filter"
  },

  jbox.sequence_fader {
    graphics = {
      node = "BankCV",
    },
    value = "/custom_properties/prop_bank_cv_mapping",
    orientation = "vertical",
    inverted = true,
    handle_size = 43
  },
}

foldedFrontWidgets = {
  -- device name / tape
  jbox.device_name {
    graphics = {
      node = "TapeFoldedFront",
    },
  },
}

folded_front = jbox.panel {
  graphics = {
    node = "Bg",
  },

  widgets = foldedFrontWidgets
}

for k, input in pairs(inputs) do
  -- audio inputs
  backWidgets[#backWidgets + 1] = jbox.audio_input_socket {
    graphics = {
      node = "audioInputStereoPairLeft" .. input,
    },
    socket = "/audio_inputs/audioInputLeft" .. input,
  }
  backWidgets[#backWidgets + 1] = jbox.audio_input_socket {
    graphics = {
      node = "audioInputStereoPairRight" .. input,
    },
    socket = "/audio_inputs/audioInputRight" .. input,
  }

  -- cv gate in
  backWidgets[#backWidgets + 1] = jbox.cv_input_socket{
    graphics = {
      node = "CVInGate" .. input,
    },
    socket = "/cv_inputs/cv_in_gate_" .. input,
  }

  -- cv gate out
  backWidgets[#backWidgets + 1] = jbox.cv_output_socket{
    graphics = {
      node = "CVOutGate" .. input,
    },
    socket = "/cv_outputs/cv_out_gate_" .. input,
  }

  -- volume knobs
  frontWidgets[#frontWidgets + 1] = jbox.analog_knob{
    graphics= {
      node="Volume" .. input,
      hit_boundaries = {left = 0, top = 0, right = 0, bottom = 40}
    },
    value="/custom_properties/prop_volume_" .. input,
  }

  -- switch custom display
  frontWidgets[#frontWidgets + 1] = jbox.custom_display{
    graphics = {
      node = "Switch" .. input,
    },
    background = jbox.image{path = "SwitchCustomDisplayBackground"},
    display_width_pixels = math.floor(100 / 5),
    display_height_pixels = math.floor(95 / 5),
    draw_function = "SwitchDraw" .. input,
    gesture_function ="SwitchGesture" .. input,
    values = {
      "/custom_properties/prop_mode",
      "/custom_properties/prop_state_single",
      "/custom_properties/prop_state_single_cv",
      "/custom_properties/prop_state_single_override_cv",
      "/custom_properties/prop_state_multi_" .. input,
      "/custom_properties/prop_state_midi_" .. input,
      "/custom_properties/prop_bank",
      "/custom_properties/prop_bank_cv",
    },
  }

  -- label
  frontWidgets[#frontWidgets + 1] = jbox.value_display{
    graphics = {
      node = "Label" .. input,
    },
    value = "/custom_properties/prop_label_" .. input,
    text_color = { 38, 152, 162 },
    text_style = "Small LCD font",
  }

  -- switch custom display (folded front)
  foldedFrontWidgets[#foldedFrontWidgets + 1] = jbox.custom_display{
    graphics = {
      node = "SwitchFolded" .. input,
    },
    background = jbox.image{path = "SwitchCustomDisplayBackground"},
    display_width_pixels = math.floor(100 / 5),
    display_height_pixels = math.floor(95 / 5),
    draw_function = "SwitchDraw" .. input,
    gesture_function ="SwitchGesture" .. input,
    values = {
      "/custom_properties/prop_mode",
      "/custom_properties/prop_state_single",
      "/custom_properties/prop_state_single_cv",
      "/custom_properties/prop_state_single_override_cv",
      "/custom_properties/prop_state_multi_" .. input,
      "/custom_properties/prop_state_midi_" .. input,
      "/custom_properties/prop_bank",
      "/custom_properties/prop_bank_cv",
    },
  }
end

back = jbox.panel {
  graphics = {
    node = "Bg"
  },
  widgets = backWidgets
}


folded_back = jbox.panel {
  graphics = {
    node = "Bg",
  },
  cable_origin = {
    node = "CableOrigin",
  },
  widgets = {

    -- device name / tape
    jbox.device_name {
      graphics = {
        node = "TapeFoldedBack",
      },
    },

  },
}
