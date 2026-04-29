#!/usr/bin/env python3

import sys
import os
import pyaudio
import struct
import cvsdchip
import wave
from bitarray import bitarray

if len(sys.argv) < 3 or not os.path.isfile(sys.argv[1]):
  print('usage: cvsd-encoder.py inputfile outputfile')
  sys.exit(1)

wav_file = wave.open(sys.argv[1], 'rb')
if wav_file.getnchannels() != 1 or wav_file.getsampwidth() != 1:
  print('incompatible wav file format, mono 8-bit unsigned required')
  sys.exit(1)

output_file = open(sys.argv[2], 'wb')

bits = bitarray(endian='little')

cvsd_chip = cvsdchip.CvsdChip()

byte = wav_file.readframes(1)
while byte != b'':

  input_value = struct.unpack('B', byte)[0]
  # make signed again
  input_value -= 128
  input_value *= 0.005

  #print(str(input_value) + ' > ' + str(cvsd_chip.integrator))

  output_value = 0
  if input_value > cvsd_chip.integrator:
    output_value = 1

  bits.append(output_value)
  cvsd_chip.process_bit(output_value)
  byte = wav_file.readframes(1)

bits.tofile(output_file)
 
wav_file.close()
output_file.close()

