//
// Created by Yan Pujante on 5/23/15.
//

#ifndef __pongasoft__DeviceState_h__
#define __pongasoft__DeviceState_h__


#include "JBoxPropertyManager.h"
#include "AudioSocket.h"
#include "ProjectConstants.h"
#include "Motherboard.h"
#include "SwitchedInputState.h"

class DeviceState : public JBoxNoteListener
{
public:
  DeviceState();

  ~DeviceState()
  {
  }

  /*
   * Called to initialize the state on first batch
   */
  void init();

  inline bool isMultiMode() const
  {
    return getSwitchMode() == kModeMulti;
  }

  inline bool isSingleMode() const
  {
    return getSwitchMode() == kModeSingle;
  }

  inline bool isKeyboardEnabled() const
  {
    return fMotherboard.fPropStateSingleKeyboardEnabled.getValue();
  }

  inline ESwitchMode getSwitchMode() const
  {
    return fMotherboard.fPropMode.getValue();
  }

  inline ESwitchBank getSwitchBank() const
  {
    if(fMotherboard.fPropBankCV.getValue() > 0)
      return static_cast<ESwitchBank>(static_cast<int>(fMotherboard.fPropBankCV.getValue()) - 1);

    return fMotherboard.fPropBank.getValue();
  }

  inline ESwitchedInput getSingleStateSwitch() const
  {
    return static_cast<ESwitchedInput>(static_cast<int>(fMotherboard.fPropStateSingle.getValue()));
  };

  inline ESwitchedInput getSingleStateCVSwitch() const
  {
    return static_cast<ESwitchedInput>(static_cast<int>(fMotherboard.fPropStateSingleCV.getValue()));
  };

  virtual bool onNoteReceived(const TJBox_PropertyDiff &iPropertyDiff);

  bool afterMotherboardUpdate(bool motherboardStateChanged,
                              DeviceState const &previousState);

  bool haveInputsChanged(DeviceState const &previousState);

  /*
   * Read audio according to state of the switch.
   *
   * @return iAudioBuffer or nullptr if no input selected at all
   */
  StereoAudioBuffer *readAudio(StereoAudioBuffer *iAudioBuffer) const;

  /*
   * Read audio according to state of the switch. Handle cross fading.
   *
   * @return iBuf1
   */
  StereoAudioBuffer *readAudio(StereoAudioBuffer *iBuf1,
                               const DeviceState &previousState,
                               XFade<kBatchSize> const &iXFade) const;

  void update(const DeviceState &rhs);

private:
  bool isSelected(SwitchedInputState *input) const
  {
    ESwitchBank bank = getSwitchBank();

    if(bank != kBankAB && bank != input->getBank())
      return false;

    switch(getSwitchMode())
    {
      case kModeSingle:
        return input->getId() ==
          (getSingleStateCVSwitch() != kNone ? getSingleStateCVSwitch() : getSingleStateSwitch());

      case kModeMulti:
        return input->isMultiSelected();

      case kModeMidi1:
        return input->isMidiSelected();

      default:
        return false;
    }
  };

public:
  Motherboard fMotherboard;

private:
  SwitchedInputState *fSwitchedInputStates[kEnd];
  bool fSelectedSwitches[kEnd];
  bool fSelectedAndConnectedSwitches[kEnd];
  ESwitchedInput fSingleStateKeySwitch;
};


#endif //__pongasoft__DeviceState_h__
