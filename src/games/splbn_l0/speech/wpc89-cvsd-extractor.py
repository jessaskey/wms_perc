#!/usr/bin/env python3

import sys
import os
import struct
import cvsdchip
import wave
from bitarray import bitarray

def decode_bank_selector(bank_selector):
  
  # to get the rom chip, we read bits 5 to 7
  rom_chip = 'invalid'
  value = bank_selector & 0xe0
  if value == 0xc0:
    rom_chip = 'u14'
  elif value == 0xa0:
    rom_chip = 'u15'
  elif value == 0x60:
    rom_chip = 'u18'
 
  # to get the rom bank we take bit 0 to 5
  rom_bank = bank_selector & 0x1f

  return rom_chip, rom_bank

def extract_cvsd_audio(rom_chip, offset, size, output_file_name):

  rom_file = open(rom_chip, 'rb')
  rom_file.seek(offset)

  cvsd_data = rom_file.read(size)

  #raw_file = open(output_file_name + '.raw', 'wb')

  # mono, 8-bit unsigned
  wav_file = wave.open(output_file_name + '.wav', 'wb')
  wav_file.setnchannels(1)
  wav_file.setsampwidth(1)
  wav_file.setframerate(22372)

  #cvsd_file = open(output_file_name + '.cvsd', 'wb')
  #cvsd_file.write(cvsd_data)
  #cvsd_file.close() 

  bits = bitarray(endian='little')
  bits.frombytes(cvsd_data)

  cvsd_chip = cvsdchip.CvsdChip()

  for bit in bits:
    cvsd_chip.process_bit(bit)
    #print(cvsd_chip.integrator)
    values = struct.pack('B', int(max(min(cvsd_chip.integrator * 200, 127), -128)) + 128)
    #raw_file.write(values)
    wav_file.writeframesraw(values)

  #raw_file.close() 
  wav_file.close() 

if not os.path.isfile('u18'):
  print('make sure you have the sound system ROM file u18 (exactly named like this) in the same folder where you run this script')
  sys.exit(1)

u18 = open('u18', 'rb')
u18_rom_offset = os.path.getsize('u18') - 0x20000

# the cvsd table pointer is at offset 0x4015, this maps diffrently on diffrent ROM sizes
u18.seek(u18_rom_offset + 0x15)
cvsd_table_pointer = struct.unpack('>H', u18.read(2))[0]

# the bank switching hardware on the sound board, maps the ROM ICs to 0x4000 - 0xbfff
# since we access the ROM as files and not as mapped devices, we need some recalculations
cvsd_table_pointer = cvsd_table_pointer - 0x4000 + u18_rom_offset

# seek to the table
u18.seek(cvsd_table_pointer)

# read first entry of the table
cvsd_entry_pointer = struct.unpack('>H', u18.read(2))[0]
# fix the offset thing
cvsd_entry_pointer = cvsd_entry_pointer - 0x4000 + u18_rom_offset

counter = 0
# extract audio until we reached the end of the table
print('Entry  Chip  Bank   Offset    Size')
while True:

  # seek to the table entry
  u18.seek(cvsd_entry_pointer)

  # read the data
  bank_selector = struct.unpack('B', u18.read(1))[0]
  cvsd_data_start = struct.unpack('>H', u18.read(2))[0]
  cvsd_data_end = struct.unpack('>H', u18.read(2))[0]

  rom_chip, rom_bank = decode_bank_selector(bank_selector)
  if rom_chip == 'invalid':
    print('could not parse rom chip number correctly, most probably reached the end of the cvsd table')
    sys.exit(1)
  elif not os.path.isfile(rom_chip):
    print('could not find ROM file "' + rom_chip + '". make sure you have the ROM file exactly named like this in the same folder where you run this script')
    sys.exit(1)

  rom_chip_size = os.path.getsize(rom_chip)
  # here we do some math to convert from the bank switching offsets to rom file offsets 
  offset = rom_bank * 0x8000 - (0x100000 - rom_chip_size) + cvsd_data_start - 0x4000
  size = cvsd_data_end - cvsd_data_start

  #print(str(counter)+' '+hex(cvsd_entry_pointer)+' '+hex(bank_selector)+' '+hex(cvsd_data_start)+' '+hex(cvsd_data_end))
  print("{:03d}".format(counter) + '    '+rom_chip+'   '+hex(rom_bank)+'   ' + "0x{:05x}".format(offset)+'   '+hex(size))
  output_file_name = "{:03d}".format(counter) + '_' + rom_chip + '_' + str(offset) + '_' + str(size)
  extract_cvsd_audio(rom_chip, offset, size, output_file_name)

  # seek back to the table and the next entry
  counter += 1
  u18.seek(cvsd_table_pointer + (counter * 2))
  cvsd_entry_pointer = struct.unpack('>H', u18.read(2))[0]
  cvsd_entry_pointer = cvsd_entry_pointer - 0x4000 + u18_rom_offset

