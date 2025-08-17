#include "Device.h"

Device::Device(int iSampleRate): CommonDevice(), fSampleRate{iSampleRate}, fFirstBatch(true)
{
  DLOG_F(INFO, "Device(%d)", iSampleRate);
  fCurrentDeviceState.fMotherboard.registerForUpdate(fJBoxPropertyManager);
}

Device::~Device()
{
  // nothing to do
  DLOG_F(INFO, "~Device()");
}

void Device::renderBatch(TJBox_PropertyDiff const iPropertyDiffs[], TJBox_UInt32 iDiffCount)
{
  bool stateChanged = false;

  if(fFirstBatch)
  {
    doInitDevice(iPropertyDiffs, iDiffCount);
    stateChanged = true;
    fFirstBatch = false;
  }
  else
  {
    if(iDiffCount > 0)
    {
      stateChanged |= fJBoxPropertyManager.onUpdate(iPropertyDiffs, iDiffCount);

      stateChanged |= fJBoxPropertyManager.onNotesUpdate(iPropertyDiffs, iDiffCount, &fCurrentDeviceState);
    }
  }

  stateChanged = fCurrentDeviceState.afterMotherboardUpdate(stateChanged, fPreviousDeviceState);

  stateChanged |= doRenderBatch(stateChanged);

  if(stateChanged)
    fPreviousDeviceState.update(fCurrentDeviceState);
}

bool Device::doRenderBatch(bool propertyStateChange)
{
  bool stateChanged = propertyStateChange;

  if(!fCurrentDeviceState.fMotherboard.fAudioOutput.isConnected())
  {
    return stateChanged;
  }

  bool soften =
    stateChanged && // if state has not changed then inputs have not changed
      fCurrentDeviceState.fMotherboard.fPropSoften.getValue() && // is soften turned on?
      fCurrentDeviceState.haveInputsChanged(fPreviousDeviceState); // have inputs actually changed?

  StereoAudioBuffer buf;

  StereoAudioBuffer *audioBuffer = soften ?
    fCurrentDeviceState.readAudio(&buf,
                                  fPreviousDeviceState,
                                  fXFade) :
    fCurrentDeviceState.readAudio(&buf);

  // is something selected?
  if(audioBuffer != nullptr)
  {
    bool silent = audioBuffer->isSilent();

    if(!silent)
      fCurrentDeviceState.fMotherboard.fAudioOutput.writeAudio(*audioBuffer);
  }

  return stateChanged;
}

void Device::doInitDevice(TJBox_PropertyDiff const iPropertyDiffs[], TJBox_UInt32 iDiffCount)
{
  DLOG_F(INFO, "doInitDevice()");

  // initialize properties
  fJBoxPropertyManager.initProperties();

  // processes the updates
  fJBoxPropertyManager.onUpdate(iPropertyDiffs, iDiffCount);

  // processes the notes
  fJBoxPropertyManager.onNotesUpdate(iPropertyDiffs, iDiffCount, &fCurrentDeviceState);

  // initialize current device
  fCurrentDeviceState.init();

  // copy to previous state to initialize it too!
  fPreviousDeviceState.update(fCurrentDeviceState);
}
