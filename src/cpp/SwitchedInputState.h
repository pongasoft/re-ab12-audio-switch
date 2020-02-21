//
// Created by Yan Pujante on 5/27/15.
//


#ifndef __SwitchedInput_H_
#define __SwitchedInput_H_

#include "AudioSocket.h"
#include "ProjectConstants.h"
#include "Motherboard.h"

class SwitchedInputState
{
public:
  SwitchedInputState(ESwitchedInput iId,
                     ESwitchBank iBank,
                     char const *iName,
                     SwitchedInput *iSwitchedInput):
    fId(iId),
    fBank(iBank),
    fName(iName),
    fSwitchedInput(iSwitchedInput),
    fNoteCount(0),
    fVolume(1.0, true)
  {}

  void update(const SwitchedInputState &rhs)
  {
    fVolume.update(rhs.fVolume);
  }

  inline bool isMultiSelected() const { return fSwitchedInput->fPropStateMulti.getValue(); }
  inline bool isCVSelected() const { return fSwitchedInput->fCVInGate.isConnected() && fSwitchedInput->fCVInGate.getValue() != 0; }
  inline bool isNoteSelected() const { return fNoteCount > 0; }
  inline bool isMidiSelected() const { return isNoteSelected() || isCVSelected(); }
  inline bool isConnected() const { return fSwitchedInput->fAudioInput.isConnected(); }
  inline char const *getName() const { return fName; }
  inline ESwitchedInput getId() const { return fId; }
  inline ESwitchBank getBank() const { return fBank; }
  inline void readAudio(StereoAudioBuffer &iStereoAudioBuffer) const {
    fSwitchedInput->fAudioInput.readAudio(iStereoAudioBuffer);
    iStereoAudioBuffer.adjustGain(fVolume.getVolume());
  }

  inline void adjustGateOut(bool isSelected)
  {
    if(fSwitchedInput->fCVOutGate.isConnected())
      fSwitchedInput->fCVOutGate.storeValueToMotherboardOnUpdate(isSelected ? 1.0 : 0.0);
  }

  inline bool afterMotherboardUpdate(bool motherboardStateChanged,
                                     bool volumeChangeFilter)
  {
    bool res = false;

    fVolume.setFilterOn(volumeChangeFilter);

    if(motherboardStateChanged)
    {
      res |=
        fSwitchedInput->fPropStateMidi.storeValueToMotherboardOnUpdate(isMidiSelected() ? TJbox_TRUE : TJbox_FALSE);
    }

    res |= fVolume.adjustVolume(fSwitchedInput->fPropVolume.getValue());

    return res;
  }

  inline void setNoteSelection(bool selected)
  {
    if(selected)
      fNoteCount++;
    else
      fNoteCount--;

    JBOX_ASSERT(fNoteCount >= 0);
  }

private:
  const ESwitchedInput fId;
  const ESwitchBank fBank;
  char const *fName;
  SwitchedInput * const fSwitchedInput;

  // count how many midi inputs we are getting for this switch (multiple notes (1 octave apart) can be held at the same
  // time)
  int fNoteCount;
  VolumeState fVolume;
};

#endif //__SwitchedInput_H_
