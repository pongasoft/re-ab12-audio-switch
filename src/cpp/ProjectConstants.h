#pragma once
#ifndef __pongasoft__ProjectConstants__
#define __pongasoft__ProjectConstants__

#include "Constants.h"

enum ESwitchedInput {
  kNone = 0,
  kA1 = 1,
  kA2,
  kA3,
  kA4,
  kA5,
  kA6,
  kB1,
  kB2,
  kB3,
  kB4,
  kB5,
  kB6,
  kEnd
};

enum ESwitchMode {
  kModeSingle = 0,
  kModeMulti = 1,
  kModeMidi1 = 2
};

typedef JBoxProperty<ESwitchMode, JBox::toEnum<ESwitchMode>, JBox::fromEnum<ESwitchMode> > ESwitchModeJBoxProperty;

enum ESwitchBank {
  kBankNone = 0,
  kBankA = 1,
  kBankB = 2,
  kBankAB = 3
};

typedef JBoxProperty<ESwitchBank, JBox::toEnum<ESwitchBank>, JBox::fromEnum<ESwitchBank> > ESwitchBankJBoxProperty;

enum EBankCVMapping
{
  kBankCVMappingUnipolar = 0,
  kBankCVMappingBipolar = 1,
  kBankCVMappingNote = 2
};

typedef JBoxProperty<EBankCVMapping, JBox::toEnum<EBankCVMapping>, JBox::fromEnum<EBankCVMapping> > EBankCVMappingJBoxProperty;

#endif /* define(__pongasoft__ProjectConstants__) */
