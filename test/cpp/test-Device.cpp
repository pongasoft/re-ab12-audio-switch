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
#include <re/mock/DeviceTesters.h>
#include <re_cmake_build.h>

using namespace re::mock;

auto newAB12SwitchTester()
{
  auto c = DeviceConfig<Device>::fromJBoxExport(RE_CMAKE_MOTHERBOARD_DEF_LUA, RE_CMAKE_REALTIME_CONTROLLER_LUA);
  return HelperTester<Device>(c);
}

// Device - SampleRate
TEST(Device, SampleRate)
{
  auto tester = newAB12SwitchTester();

  ASSERT_EQ(44100, tester.device()->getSampleRate());
}
