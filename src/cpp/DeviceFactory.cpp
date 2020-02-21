#include "JukeboxExports.h"
#include "Device.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-parameter"
CommonDevice *createDevice(const TJBox_Value iParams[], TJBox_UInt32 iCount)
{
  return new Device();
}
#pragma clang diagnostic pop
