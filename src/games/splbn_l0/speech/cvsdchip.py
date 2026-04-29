#!/usr/bin/env python3

CHARGE = 0.984496437005408453
DECAY = 0.939413062813475808
SHIFTMASK = 0x07
V_HIGH = 1.7
V_LOW = 0.0

class CvsdChip:

  integrator = 0
  sylLevel = 0
  shiftreg = 0

  def process_bit(self, bit):

    di = (1.0 - DECAY) * CvsdChip.sylLevel
    if(bit != 0):
      CvsdChip.integrator += di
    else:
      CvsdChip.integrator -= di

    CvsdChip.integrator *= DECAY

    CvsdChip.shiftreg = ((CvsdChip.shiftreg << 1) | bit) & SHIFTMASK

    CvsdChip.sylLevel *= CHARGE
    if(CvsdChip.shiftreg == 0 or CvsdChip.shiftreg == SHIFTMASK):
      CvsdChip.sylLevel += (1.0 - CHARGE) * V_HIGH
    else:
      CvsdChip.sylLevel += (1.0 - CHARGE) * V_LOW

