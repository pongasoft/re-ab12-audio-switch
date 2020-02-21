//
//  Device.h
//

#pragma once
#ifndef __pongasoft__Device__
#define __pongasoft__Device__

#include "Jukebox.h"
#include "CommonDevice.h"
#include "DeviceState.h"

class Device : public CommonDevice
{
public:
  Device();
  virtual ~Device();

  /**
  * @brief	Main starting point for rendering audio
  **/
  virtual void renderBatch(const TJBox_PropertyDiff iPropertyDiffs[], TJBox_UInt32 iDiffCount);

private:
  void doInitDevice(TJBox_PropertyDiff const iPropertyDiffs[], TJBox_UInt32 iDiffCount);
  bool doRenderBatch(bool propertyStateChange);

private:
  bool fFirstBatch;
  JBoxPropertyManager fJBoxPropertyManager;
  DeviceState fPreviousDeviceState;
  DeviceState fCurrentDeviceState;

  LinearXFade<kBatchSize> fXFade;
};

#endif /* defined(__pongasoft__Device__) */
