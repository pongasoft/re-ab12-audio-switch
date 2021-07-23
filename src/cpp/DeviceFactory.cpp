#include "JukeboxExports.h"
#include "Device.h"
#include <logging/logging.h>

CommonDevice *createDevice([[maybe_unused]] const TJBox_Value iParams[], [[maybe_unused]] TJBox_UInt32 iCount)
{
  DLOG_F(INFO, "AB12AudioSwitch - New Instance");
  TJBox_Float64 sampleRate = JBox_GetNumber(iParams[0]);
  return new Device(static_cast<int>(sampleRate));
}
