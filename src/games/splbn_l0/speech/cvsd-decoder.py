#!/usr/bin/env python3

import sys
import os
import pyaudio
import struct
import cvsdchip
import wave
from bitarray import bitarray

if len(sys.argv) <= 1 or not os.path.isfile(sys.argv[1]):
  print('usage: cvsd-decoder.py inputfile [samplerate] [outputfile]')
  sys.exit(1)

sampleRate = 22372
if len(sys.argv) > 2:
  try:
    sampleRate = int(sys.argv[2])
  except ValueError:
    print('usage: cvsd-decoder.py inputfile [samplerate (default=22372)] [outputfile]')
    sys.exit(1)

output_to_file = False
if len(sys.argv) > 3:
  output_to_file = True

if not output_to_file:
  audio = pyaudio.PyAudio()
  stream = audio.open(format=pyaudio.paUInt8, channels=1, rate=sampleRate, output=True)

file = open(sys.argv[1], 'rb')
if output_to_file:
  # mono, 8-bit unsigned
  wav_file = wave.open(sys.argv[3], 'wb')
  wav_file.setnchannels(1)
  wav_file.setsampwidth(1)
  wav_file.setframerate(sampleRate)

bits = bitarray(endian='little')
bits.fromfile(file);

cvsd_chip = cvsdchip.CvsdChip()

for bit in bits:
  cvsd_chip.process_bit(bit)
  #print(cvsd_chip.integrator)
  values = struct.pack('B', int(max(min(cvsd_chip.integrator * 200, 127),-128)+128))
  if output_to_file:
    wav_file.writeframesraw(values)
  else:
    stream.write(values)

if not output_to_file:
  stream.stop_stream()
  stream.close()
  audio.terminate()
else:
  wav_file.close()

file.close()
