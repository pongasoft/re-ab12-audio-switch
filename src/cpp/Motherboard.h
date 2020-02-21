//
// Created by Yan Pujante on 5/27/15.
//


#ifndef __Motherboard_H_
#define __Motherboard_H_

#include "AudioSocket.h"
#include "ProjectConstants.h"
#include "CVSocket.h"
#include "Volume.h"

const TJBox_Tag PROP_MODE_TAG = 1000;
const TJBox_Tag PROP_STATE_SINGLE_TAG = 1010;
const TJBox_Tag PROP_STATE_SINGLE_OVERRIDE_CV_TAG = 1020;
const TJBox_Tag PROP_VOLUME_CHANGE_FILTER_TAG = 1030;
const TJBox_Tag PROP_SOFTEN_TAG = 1040;
const TJBox_Tag PROP_BANK_TAG = 1050;
const TJBox_Tag PROP_BANK_OVERRIDE_CV_TAG = 1060;
const TJBox_Tag PROP_BANK_CV_MAPPING_TAG = 1070;
const TJBox_Tag PROP_STATE_SINGLE_KEYBOARD_ENABLED_TAG = 1080;
const TJBox_Tag PROP_STATE_MULTI_START_TAG = 2000;
const TJBox_Tag PROP_VOLUME_START_TAG = 4000;

// start at C3
const TJBox_Tag PROP_NOTE_STATE_START_TAG = 60;

class SwitchedInput
{
public:
  SwitchedInput(
    char const *iAudioInputLeft,
    char const *iAudioInputRight,
    char const *iCVInGate,
    char const *iCVOutGate,
    char const *iStateMulti,
    char const *iStateMidi,
    char const *iVolume
  ):
    fAudioInput(iAudioInputLeft, iAudioInputRight),
    fCVInGate(iCVInGate),
    fCVOutGate(iCVOutGate),
    fPropStateMulti(iStateMulti),
    fPropStateMidi(iStateMidi),
    fPropVolume(iVolume)
  {}

  SwitchedInput(SwitchedInput const &other) = delete;

  void registerForUpdate(JBoxPropertyManager &manager, ESwitchedInput idx)
  {
    fAudioInput.registerForUpdate(manager);
    fCVInGate.registerForUpdate(manager);
    fCVOutGate.registerForUpdate(manager);
    fPropStateMulti.registerForUpdate(manager, PROP_STATE_MULTI_START_TAG + idx - kA1);
    manager.registerForInit(fPropStateMidi);
    fPropVolume.registerForUpdate(manager, PROP_VOLUME_START_TAG + idx - kA1);
  }

public:
  StereoInPair fAudioInput;
  CVInSocket fCVInGate;
  CVOutSocket fCVOutGate;
  BooleanJBoxProperty fPropStateMulti;
  BooleanJBoxProperty fPropStateMidi;
  VolumeCubeJBoxProperty fPropVolume;
};

class Motherboard
{
public:
  Motherboard();

  void registerForUpdate(JBoxPropertyManager &manager);
  void update(Motherboard const &rhs);

public:
  StereoOutPair fAudioOutput;
  CVInNote fCVInStateSingle;
  CVInSocket fCVInBank;

  JBoxNoteStates fNoteStates; // any note on the keyboard
  ESwitchModeJBoxProperty fPropMode;
  Float64JBoxProperty fPropStateSingle; // stepped number starts at 0 (0 means nothing selected)
  Float64JBoxProperty fPropStateSingleCV; // stepped number starts at 0
  BooleanJBoxProperty fPropStateSingleOverrideCV; // this property acts as a toggle!!!
  BooleanJBoxProperty fPropStateSingleKeyboardEnabled; // whether keyboard is enabled on not in single mode
  BooleanJBoxProperty fPropVolumeChangeFilter; // whether to filter on volume change or not
  BooleanJBoxProperty fPropSoften; // whether to xfade or not
  ESwitchBankJBoxProperty fPropBank;
  BooleanJBoxProperty fPropBankOverrideCV; // this property acts as a toggle!!!
  Float64JBoxProperty fPropBankCV; // 0 means no CV, then 1-4 is ESwitchBank + 1
  EBankCVMappingJBoxProperty fPropBankCVMapping;

  SwitchedInput *fSwitchedInputs[kEnd];
};


#endif //__Motherboard_H_
