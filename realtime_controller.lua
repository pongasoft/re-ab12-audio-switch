format_version = "1.0"

rtc_bindings = {
  -- this will initialize the C++ object
  { source = "/environment/instance_id", dest = "/global_rtc/init_instance" },
}

global_rtc = {
  init_instance = function(source_property_path, instance_id)
    local new_no = jbox.make_native_object_rw("Instance", { instance_id })
    jbox.store_property("/custom_properties/instance", new_no);
  end,
}

local rtInputSetupNotify = {
  "/audio_outputs/audioOutputLeft/connected",
  "/audio_outputs/audioOutputRight/connected",
  "/custom_properties/prop_mode",
  "/custom_properties/prop_bank",
  "/custom_properties/prop_bank_override_cv",
  "/custom_properties/prop_bank_cv_mapping",
  "/custom_properties/prop_state_single",
  "/custom_properties/prop_state_single_override_cv",
  "/custom_properties/prop_volume_change_filter",
  "/custom_properties/prop_state_single_keyboard_enabled",
  "/custom_properties/prop_soften",
  "/cv_inputs/cv_in_state_single/connected",
  "/cv_inputs/cv_in_state_single/value",
  "/cv_inputs/cv_in_bank/connected",
  "/cv_inputs/cv_in_bank/value",
  "/note_states/*"
}

local inputs = { "A1", "A2", "A3", "A4", "A5", "A6", "B1", "B2", "B3", "B4", "B5", "B6" }

for k, input in pairs(inputs) do
  rtInputSetupNotify[#rtInputSetupNotify + 1] = "/audio_inputs/audioInputLeft" .. input .. "/connected"
  rtInputSetupNotify[#rtInputSetupNotify + 1] = "/audio_inputs/audioInputRight" .. input .. "/connected"
  rtInputSetupNotify[#rtInputSetupNotify + 1] = "/cv_inputs/cv_in_gate_" .. input .. "/connected"
  rtInputSetupNotify[#rtInputSetupNotify + 1] = "/cv_inputs/cv_in_gate_" .. input .. "/value"
  rtInputSetupNotify[#rtInputSetupNotify + 1] = "/cv_outputs/cv_out_gate_" .. input .. "/connected"
  rtInputSetupNotify[#rtInputSetupNotify + 1] = "/custom_properties/prop_state_multi_" .. input
  rtInputSetupNotify[#rtInputSetupNotify + 1] = "/custom_properties/prop_volume_" .. input
end

rt_input_setup = {
  notify = rtInputSetupNotify
}

sample_rate_setup = {
	native = {
		22050,
		44100,
		48000,
		88200,
		96000,
		192000
	},
	
}
