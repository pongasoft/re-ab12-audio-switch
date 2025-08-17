# Copyright (c) 2020 pongasoft
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License. You may obtain a copy of
# the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations under
# the License.
#
# @author Yan Pujante

cmake_minimum_required(VERSION 3.13)

# Capturing root of project
set(RE_PROJECT_ROOT_DIR "${CMAKE_CURRENT_LIST_DIR}")

# No HD custom display
set(RE_CMAKE_RE_2D_RENDER_HI_RES_OPTION "hi-res" CACHE STRING "Option for invoking RE2DRender for hi res build (hi-res or hi-res-only)")

# Using RE SDK version 4.2.0
set(RE_SDK_VERSION 4.6.0)

include(cmake/options.cmake)  # (optional) override versions used
include(cmake/re-cmake.cmake) # include re-cmake (BEFORE project() definition)

# Setting up project (note that the version is defined in lua.info)
project(re-ab12-audio-in-switch LANGUAGES CXX)

# Using C++17
set(CMAKE_CXX_STANDARD 17)

# Initializes re-cmake (re-mock for unit testing)
re_cmake_init(INCLUDES re-logging re-mock)

# re-common
fetch_content(NAME re-common)
include("${re-common_ROOT_DIR}/re-common.cmake")

# Defining where the sources of the plugin live
set(RE_CPP_SRC_DIR "${CMAKE_CURRENT_LIST_DIR}/src/cpp")

# Defining all the source files for the project
# Although you could use a file(GLOB ...) pattern, it is NOT recommended as the CMake generation would happen on
# every single build!
set(re_sources_cpp
    ${RE_CPP_SRC_DIR}/Device.cpp
    ${RE_CPP_SRC_DIR}/DeviceFactory.cpp
    ${RE_CPP_SRC_DIR}/DeviceState.cpp
    ${RE_CPP_SRC_DIR}/Motherboard.cpp
)

# Defining where the local GUI2D files live
set(RE_2D_SRC_DIR ${CMAKE_CURRENT_LIST_DIR}/GUI2D)

# Defining all the 2D source files
# Although you could use a file(GLOB ...) pattern, it is NOT recommended as the CMake generation would happen on
# every single build!
set(re_sources_2d

    # lua files describing the GUI
    ${RE_2D_SRC_DIR}/device_2D.lua
    ${RE_2D_SRC_DIR}/hdgui_2D.lua

    # Images for the device
    ${RE_2D_SRC_DIR}/BankToggleACustomDisplay.png
    ${RE_2D_SRC_DIR}/BankToggleACustomDisplayBackground.png
    ${RE_2D_SRC_DIR}/BankToggleAOff.png
    ${RE_2D_SRC_DIR}/BankToggleAOn.png
    ${RE_2D_SRC_DIR}/BankToggleBCustomDisplay.png
    ${RE_2D_SRC_DIR}/BankToggleBCustomDisplayBackground.png
    ${RE_2D_SRC_DIR}/BankToggleBOff.png
    ${RE_2D_SRC_DIR}/BankToggleBOn.png
    ${RE_2D_SRC_DIR}/BankToggleCustomDisplay.png
    ${RE_2D_SRC_DIR}/BankToggleCustomDisplayBackground.png
    ${RE_2D_SRC_DIR}/BankTogglePressed.png
    ${RE_2D_SRC_DIR}/BankToggleReleased.png
    ${RE_2D_SRC_DIR}/Button_18_2frames.png
    ${RE_2D_SRC_DIR}/Button_Midi_2frames.png
    ${RE_2D_SRC_DIR}/Button_Multi_2frames.png
    ${RE_2D_SRC_DIR}/Button_Single_2frames.png
    ${RE_2D_SRC_DIR}/Cable_Attachment_Audio_01_1frames.png
    ${RE_2D_SRC_DIR}/Cable_Attachment_CV_01_1frames.png
    ${RE_2D_SRC_DIR}/Knob_94_63frames.png
    ${RE_2D_SRC_DIR}/Lamp_Bank_CV_13frames.png
    ${RE_2D_SRC_DIR}/Lamp_Bank_CV_5frames.png
    ${RE_2D_SRC_DIR}/Panel_Back.png
    ${RE_2D_SRC_DIR}/Panel_Folded_Back.png
    ${RE_2D_SRC_DIR}/Panel_Folded_Front.png
    ${RE_2D_SRC_DIR}/Panel_Front.png
    ${RE_2D_SRC_DIR}/Placeholder.png
    ${RE_2D_SRC_DIR}/SmallDisplaySurface.png
    ${RE_2D_SRC_DIR}/SwitchCustomDisplayBackground-HD.png
    ${RE_2D_SRC_DIR}/SwitchCustomDisplayBackground.png
    ${RE_2D_SRC_DIR}/Tape_Horizontal_1frames.png
    ${RE_2D_SRC_DIR}/Tape_Vertical_1frames.png
    ${RE_2D_SRC_DIR}/Toggle_2frames.png
    ${RE_2D_SRC_DIR}/Toggle_Fader_3frames.png
  )

# Location of the test cases
set(TEST_DIR "${CMAKE_CURRENT_LIST_DIR}/test/cpp")

# List of test cases
set(re_test_cpp
    "${TEST_DIR}/test-Device.cpp"
    )

# Adding the RE plugin
add_re_plugin(
    RE_SDK_VERSION         "${RE_SDK_VERSION}"
    RE_SDK_ROOT            "${RE_SDK_ROOT}"
    RE_2D_RENDER_ROOT      "${RE_2D_RENDER_ROOT}"
    BUILD_SOURCES          "${re_sources_cpp}" "${re-common_BUILD_SOURCES}"
    NATIVE_BUILD_SOURCES   "${re-logging_SOURCES}" "${re-common_NATIVE_BUILD_SOURCES}"
    RENDER_2D_SOURCES      "${re_sources_2d}"
    INCLUDE_DIRECTORIES    "${re-logging_INCLUDE_DIRS}" "${re-common_INCLUDE_DIRECTORIES}" # plugin uses loguru
    #   COMPILE_OPTIONS        -Wall
    #   NATIVE_COMPILE_OPTIONS -Wall                     # Ok for macOS, try -W4 instead for Windows/Clang
    JBOX_COMPILE_OPTIONS   -Wall
    ENABLE_DEBUG_LOGGING                             # turn on JBOX_TRACE and loguru

    # Testing
    TEST_CASE_SOURCES        "${re_test_cpp}"        # the source files containing the test cases
    TEST_INCLUDE_DIRECTORIES "${RE_CPP_SRC_DIR}"     # tests include plugin classes
    TEST_LINK_LIBS           "native-test-lib" "${re-mock_LIBRARY_NAME}"  # tests link with plugin classes and re-mock
)
