/*
 * Copyright (c) 2021 pongasoft
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 *
 * @author Yan Pujante
 */

#include <gtest/gtest.h>
#include <Device.h>
#include <re/mock/Rack.h>
#include <re/mock/MockDevices.h>

using namespace re::mock;

auto newAB12Switch(Rack &iRack)
{
  Config c = Config::byDefault<Device>([](LuaJbox &jbox, MotherboardDef &def, RealtimeController &rtc, Realtime &rt) {
    // rt
    rt.create_native_object = JBox_Export_CreateNativeObject; // use actual function for test
    rt.render_realtime = JBox_Export_RenderRealtime;          // use actual function for test
  });

  return iRack.newDevice<Device>(c);
}

// Device - SampleRate
TEST(Device, SampleRate)
{
  Rack rack{};

  // this tests the creation of the device
  auto abSwitch = newAB12Switch(rack);

  ASSERT_EQ(44100, abSwitch->getSampleRate());
}
