//
// Created by Yan Pujante on 5/23/15.
//

#include "DeviceState.h"

#define NEW_SWITCH(b, i) fSwitchedInputStates[k ## b ## i] = \
  new SwitchedInputState(k ## b ## i, \
                         kBank ## b, \
                         CONCAT(STR(b), STR(i)), \
                         fMotherboard.fSwitchedInputs[k ## b ## i])

DeviceState::DeviceState() : fSingleStateKeySwitch(kNone)
{
  NEW_SWITCH(A, 1);
  NEW_SWITCH(A, 2);
  NEW_SWITCH(A, 3);
  NEW_SWITCH(A, 4);
  NEW_SWITCH(A, 5);
  NEW_SWITCH(A, 6);
  NEW_SWITCH(B, 1);
  NEW_SWITCH(B, 2);
  NEW_SWITCH(B, 3);
  NEW_SWITCH(B, 4);
  NEW_SWITCH(B, 5);
  NEW_SWITCH(B, 6);

  for (int i = static_cast<int>(kA1); i < static_cast<int>(kEnd); ++i)
  {
    fSelectedSwitches[i] = false;
    fSelectedAndConnectedSwitches[i] = false;
  }
}

void DeviceState::init()
{
  fSingleStateKeySwitch = kNone;
}

void DeviceState::update(const DeviceState &rhs)
{
  fMotherboard.update(rhs.fMotherboard);
  for (int i = static_cast<int>(kA1); i < static_cast<int>(kEnd); ++i)
  {
    fSwitchedInputStates[i]->update(*rhs.fSwitchedInputStates[i]);
    fSelectedSwitches[i] = rhs.fSelectedSwitches[i];
    fSelectedAndConnectedSwitches[i] = rhs.fSelectedAndConnectedSwitches[i];
  }
  fSingleStateKeySwitch = rhs.fSingleStateKeySwitch;
}

bool DeviceState::onNoteReceived(const TJBox_PropertyDiff &iPropertyDiff)
{
  TJBox_Tag noteIndex = iPropertyDiff.fPropertyTag;
      
  int inputIndex = (noteIndex % 12) + static_cast<int>(kA1);

  JBOX_ASSERT(inputIndex >= kA1 && inputIndex < kEnd);

  SwitchedInputState *input = fSwitchedInputStates[inputIndex];
      
  bool cur = JBox::toJBoxFloat64(iPropertyDiff.fCurrentValue) != 0;
  bool prev = JBox::toJBoxFloat64(iPropertyDiff.fPreviousValue) != 0;

  if(cur != prev)
  {
    if(cur && isSingleMode() && isKeyboardEnabled())
      fSingleStateKeySwitch = input->getId();
    input->setNoteSelection(cur);
    return true;
  }

  return false;
}

bool DeviceState::afterMotherboardUpdate(bool motherboardStateChanged,
                                         DeviceState const &previousState)
{
  bool res = motherboardStateChanged;

  // adjust midi and volume
  for (int i = static_cast<int>(kA1); i < static_cast<int>(kEnd); ++i)
  {
    SwitchedInputState *input = fSwitchedInputStates[i];

    res |= input->afterMotherboardUpdate(motherboardStateChanged,
                                         fMotherboard.fPropVolumeChangeFilter.getValue());
  }

  if(motherboardStateChanged)
  {
    if(previousState.isKeyboardEnabled() && !isKeyboardEnabled())
      fSingleStateKeySwitch = kNone;

    // handle CV (single state)
    TJBox_Float64 stateSingleCV = previousState.fMotherboard.fPropStateSingleCV.getValue();

    // if there is UI override, it trumps everything
    if(fMotherboard.fPropStateSingle.isNotSameValue(previousState.fMotherboard.fPropStateSingle) ||
      fMotherboard.fPropStateSingleOverrideCV.isNotSameValue(previousState.fMotherboard.fPropStateSingleOverrideCV))
    {
      fSingleStateKeySwitch = kNone;
      stateSingleCV = 0;
    }
    else
    {
      // keyboard trumps cv (if enabled)
      if(previousState.fSingleStateKeySwitch != fSingleStateKeySwitch && isKeyboardEnabled())
      {
        stateSingleCV = fSingleStateKeySwitch;
      }
      else
      {
        // no longer connected => no state from CV
        if(!fMotherboard.fCVInStateSingle.isConnected() && previousState.fMotherboard.fCVInStateSingle.isConnected())
          stateSingleCV = fSingleStateKeySwitch;
        else
        {
          if(fMotherboard.fCVInStateSingle.isNotSameValue(previousState.fMotherboard.fCVInStateSingle)) // only when CV changes
          {
            TJBox_Int32 noteValue = fMotherboard.fCVInStateSingle.getValue();
            if(noteValue >= kMidiC0)
            {
              stateSingleCV = (noteValue % 12) + 1; // Cx maps to A1
            }
          }
        }
      }
    }

    res |= fMotherboard.fPropStateSingleCV.storeValueToMotherboardOnUpdate(stateSingleCV);

    // handle CV (bank)
    TJBox_Float64 bankCV = previousState.fMotherboard.fPropBankCV.getValue();

    if(!fMotherboard.fCVInBank.isConnected() ||
      fMotherboard.fPropBankOverrideCV.isNotSameValue(previousState.fMotherboard.fPropBankOverrideCV))
    {
      // not connected or UI forced change => revert to no CV
      bankCV = 0;
    }
    else
    if(fMotherboard.fCVInBank.isNotSameValue(previousState.fMotherboard.fCVInBank)) // only when CV changes
    {
      TJBox_Float64 value = fMotherboard.fCVInBank.getValue();

      switch(fMotherboard.fPropBankCVMapping.getValue())
      {
        case kBankCVMappingBipolar:
          if(value <= -1.0)
            bankCV = 1;
          else
          if(value < 0)
            bankCV = 2;
          else
          if(value < 1.0)
            bankCV = 3;
          else
            bankCV = 4;
          break;

        case kBankCVMappingUnipolar:
          if(value < 0.25)
            bankCV = 1;
          else
          if(value < 0.5)
            bankCV = 2;
          else
          if(value < 0.75)
            bankCV = 3;
          else
            bankCV = 4;
          break;

        case kBankCVMappingNote:
        {
          TJBox_Int32 note = JBox::toNote(value) % 12; // to bring back to 1 octave
          if(note < 3) // Cx - Dx
            bankCV = 1;
          else
          if(note < 6) // D#x - Fx
            bankCV = 2;
          else
          if(note < 9) // F#x - G#x
            bankCV = 3;
          else
            bankCV = 4; // Ax - Bx
        }
          break;

        default:
          JBOX_ASSERT_MESSAGE(true, "not reached");
      }
    }

    res |=
      fMotherboard.fPropBankCV.storeValueToMotherboardOnUpdate(bankCV);
  }

  if(res)
  {
    // compute state of switches
    for (int i = static_cast<int>(kA1); i < static_cast<int>(kEnd); ++i)
    {
      SwitchedInputState *input = fSwitchedInputStates[i];
      bool selected = isSelected(input);
      fSelectedSwitches[i] = selected;
      fSelectedAndConnectedSwitches[i] = selected && input->isConnected();

      input->adjustGateOut(selected);
    }
  }

  return res;
}

bool DeviceState::haveInputsChanged(DeviceState const &previousState)
{
  for (int i = static_cast<int>(kA1); i < static_cast<int>(kEnd); ++i)
  {
    if(fSelectedAndConnectedSwitches[i] != previousState.fSelectedAndConnectedSwitches[i])
      return true;
  }

  return false;
}

/*
 * Read audio according to state of the switch.
 *
 * @return iAudioBuffer or nullptr if no input selected at all
 */
StereoAudioBuffer *DeviceState::readAudio(StereoAudioBuffer *iAudioBuffer) const
{
  StereoAudioBuffer *buf = nullptr;

  StereoAudioBuffer acc;
  acc.clear();

  for(int i = static_cast<int>(kA1); i < static_cast<int>(kEnd); ++i)
  {
    SwitchedInputState *input = fSwitchedInputStates[i];

    if(fSelectedAndConnectedSwitches[i])
    {
      if(buf == nullptr)
        buf = iAudioBuffer;

      input->readAudio(*buf);

      acc.accumulate(*buf);
    }
  }

  if(buf != nullptr)
    buf->copy(acc);

  return buf;
}

/*
 * Read audio according to state of the switch. Handle cross fading.
 *
 * @return iBuf1
 */
StereoAudioBuffer *DeviceState::readAudio(StereoAudioBuffer *iBuf1,
                                          const DeviceState &previousState,
                                          XFade<kBatchSize> const &iXFade) const
{

  StereoAudioBuffer accCur;
  accCur.clear();
  StereoAudioBuffer accPrev;
  accPrev.clear();

  for(int i = static_cast<int>(kA1); i < static_cast<int>(kEnd); ++i)
  {
    StereoAudioBuffer *buf = nullptr;
    SwitchedInputState *curInput = fSwitchedInputStates[i];

    if(fSelectedAndConnectedSwitches[i])
    {
      buf = iBuf1;

      curInput->readAudio(*buf);

      accCur.accumulate(*buf);
    }

    if(previousState.fSelectedAndConnectedSwitches[i])
    {
      if(buf == nullptr)
      {
        buf = iBuf1;

        // reading via curInput to take into account new volume!
        curInput->readAudio(*buf);
      }

      accPrev.accumulate(*buf);
    }
  }

  iBuf1->xFade(iXFade, accCur, accPrev);

  return iBuf1;
}
