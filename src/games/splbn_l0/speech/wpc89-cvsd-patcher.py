#!/usr/bin/env python3

import sys
import os
import struct
import cvsdchip
import wave
import shutil
from bitarray import bitarray

if not os.path.isfile('u14') or not os.path.isfile('u15') or not os.path.isfile('u18'):
  print('make sure you have the sound ROM files u14, u15, u18 (exactly named like this) in the same folder where you run this script')
  sys.exit(1)

if len(sys.argv) < 2:
  print('provide a wav file for ROM patching')
  sys.exit(1)

wav_file_name = sys.argv[1]
if len(wav_file_name.split('.')) < 2 or len(wav_file_name.split('.')[0].split('_')) < 4:
  print('provide a correctly named wav file for ROM patching')
  sys.exit(1)

wav_file_name_parts = wav_file_name.split('.')[0].split('_')
rom_chip = wav_file_name_parts[1]
offset = int(wav_file_name_parts[2])
size = int(wav_file_name_parts[3])

wav_file = wave.open(sys.argv[1])
if wav_file.getnchannels() != 1 or wav_file.getsampwidth() != 1:
  print('incompatible wav file format, mono 8-bit unsigned required')
  sys.exit(1)

if wav_file.getnframes() > size * 8:
  print('WARNING: wav files size is bigger than size in file name')

if wav_file.getnframes() < size * 8:
  print('WARNING: wav files size is smaller than size in file name')

bits = bitarray(endian='little')
cvsd_chip = cvsdchip.CvsdChip()

for i in range(size * 8):

  input_value = struct.unpack('B', wav_file.readframes(1))[0]
  # make signed again
  input_value -= 128
  input_value *= 0.005

  #print(str(input_value) + ' > ' + str(cvsd_chip.integrator))

  output_value = 0
  if input_value > cvsd_chip.integrator:
    output_value = 1

  bits.append(output_value)
  cvsd_chip.process_bit(output_value)

cvsd_data = bits.tobytes()

patched_file_name = rom_chip + '_patched'
if not os.path.isfile(patched_file_name):
  shutil.copyfile(rom_chip, patched_file_name)

rom_file = open(patched_file_name, 'rb+')
rom_file.seek(offset)
rom_file.write(cvsd_data)
rom_file.close()

print('patched rom file "' + patched_file_name + '" at offset ' + str(offset) + ' with ' + str(len(cvsd_data)) + ' bytes')
