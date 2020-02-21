//
// Created by Yan Pujante on 5/27/15.
//

#include "Motherboard.h"

#define NEW_SWITCH(s) fSwitchedInputs[k ## s] = \
  new SwitchedInput(CONCAT("/audio_inputs/audioInputLeft", STR(s)), CONCAT("/audio_inputs/audioInputRight", STR(s)), \
                    CONCAT("/cv_inputs/cv_in_gate_", STR(s)), \
                    CONCAT("/cv_outputs/cv_out_gate_", STR(s)), \
                    CONCAT("/custom_properties/prop_state_multi_", STR(s)), \
                    CONCAT("/custom_properties/prop_state_midi_", STR(s)), \
                    CONCAT("/custom_properties/prop_volume_", STR(s)) \
                   )

Motherboard::Motherboard():
    fAudioOutput("/audio_outputs/audioOutputLeft", "/audio_outputs/audioOutputRight"),
    fCVInStateSingle("/cv_inputs/cv_in_state_single"),
    fCVInBank("/cv_inputs/cv_in_bank"),
    fNoteStates(),
    fPropMode("/custom_properties/prop_mode"),
    fPropStateSingle("/custom_properties/prop_state_single"),
    fPropStateSingleCV("/custom_properties/prop_state_single_cv"),
    fPropStateSingleOverrideCV("/custom_properties/prop_state_single_override_cv"),
    fPropStateSingleKeyboardEnabled("/custom_properties/prop_state_single_keyboard_enabled"),
    fPropVolumeChangeFilter("/custom_properties/prop_volume_change_filter"),
    fPropSoften("/custom_properties/prop_soften"),
    fPropBank("/custom_properties/prop_bank"),
    fPropBankOverrideCV("/custom_properties/prop_bank_override_cv"),
    fPropBankCV("/custom_properties/prop_bank_cv"),
    fPropBankCVMapping("/custom_properties/prop_bank_cv_mapping")
{
  NEW_SWITCH(A1);
  NEW_SWITCH(A2);
  NEW_SWITCH(A3);
  NEW_SWITCH(A4);
  NEW_SWITCH(A5);
  NEW_SWITCH(A6);
  NEW_SWITCH(B1);
  NEW_SWITCH(B2);
  NEW_SWITCH(B3);
  NEW_SWITCH(B4);
  NEW_SWITCH(B5);
  NEW_SWITCH(B6);
}

void Motherboard::update(Motherboard const &rhs)
{
  fAudioOutput = rhs.fAudioOutput;
  fCVInStateSingle = rhs.fCVInStateSingle;
  fCVInBank = rhs.fCVInBank;
  fPropMode = rhs.fPropMode;
  fPropStateSingle = rhs.fPropStateSingle;
  fPropStateSingleCV = rhs.fPropStateSingleCV;
  fPropStateSingleOverrideCV = rhs.fPropStateSingleOverrideCV;
  fPropVolumeChangeFilter = rhs.fPropVolumeChangeFilter;
  fPropSoften = rhs.fPropSoften;
  fPropBank = rhs.fPropBank;
  fPropBankOverrideCV = rhs.fPropBankOverrideCV;
  fPropBankCV = rhs.fPropBankCV;
  fPropBankCVMapping = rhs.fPropBankCVMapping;
  fPropStateSingleKeyboardEnabled = rhs.fPropStateSingleKeyboardEnabled;

  for(int i = static_cast<int>(kA1); i < static_cast<int>(kEnd); ++i)
  {
    *fSwitchedInputs[i] = *rhs.fSwitchedInputs[i];
  }
}

void Motherboard::registerForUpdate(JBoxPropertyManager &manager)
{
  fAudioOutput.registerForUpdate(manager);
  fCVInStateSingle.registerForUpdate(manager);
  fCVInBank.registerForUpdate(manager);

  manager.registerNoteStates(fNoteStates);

  manager.registerForInit(fPropStateSingleCV);
  manager.registerForInit(fPropBankCV);

  manager.registerForUpdate(fPropMode, PROP_MODE_TAG);
  manager.registerForUpdate(fPropStateSingle, PROP_STATE_SINGLE_TAG);
  manager.registerForUpdate(fPropStateSingleOverrideCV, PROP_STATE_SINGLE_OVERRIDE_CV_TAG);
  manager.registerForUpdate(fPropStateSingleKeyboardEnabled, PROP_STATE_SINGLE_KEYBOARD_ENABLED_TAG);
  manager.registerForUpdate(fPropVolumeChangeFilter, PROP_VOLUME_CHANGE_FILTER_TAG);
  manager.registerForUpdate(fPropSoften, PROP_SOFTEN_TAG);
  manager.registerForUpdate(fPropBank, PROP_BANK_TAG);
  manager.registerForUpdate(fPropBankOverrideCV, PROP_BANK_OVERRIDE_CV_TAG);
  manager.registerForUpdate(fPropBankCVMapping, PROP_BANK_CV_MAPPING_TAG);

  for(int i = static_cast<int>(kA1); i < static_cast<int>(kEnd); ++i)
  {
    fSwitchedInputs[i]->registerForUpdate(manager, static_cast<ESwitchedInput>(i));
  }
}
