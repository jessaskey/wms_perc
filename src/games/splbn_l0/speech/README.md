# Pinball CVSD Patcher

These scripts can be used to play, extract, patch and therefore customize speech data (encoded CVSD data) on Williams/Bally pinball machines that use the CVSD chip "Harris HC-55516 / HC-55532 / HC-55564".

## Instructions
### How to Patch WPC-89 Games
1. Create a folder in the cloned directory and name it after the machine you want to patch (e.g. cftbl).
2. Copy all sound ROMs into the folder and name them "u14", "u15", "u18".
3. Run "../wpc98-extractor.py", this will generate a WAV file for every CVSD data entry.
4. Open the WAV file you want to patch in an audio editing software (e.g. Audacity).
5. Record your new audio. Note that it has to be the same length.
6. Save your adjusted WAV file (e.g. name it "008_u14_327682_4919_patched.wav").
7. Patch the ROM by running "../wpc98-patcher.py 008_u14_327682_4919_patched.wav".
8. Burn the generated "u14_patched / u15_patched / u18_patched" ROM files to the correctly sized EPROM chip.

### How to Patch Other Games (currently rather tedious...)
1. Run "cvsd-decoder.py" on a ROM file to find the audio you want to patch. You may fiddle with the sample rate to get it correct.
2. After you have the correct sample rate, rerun "cvsd-decoder.py" with an output file name to generate a WAV file from the whole ROM.
3. Open the WAV file you want to patch in an audio editing software (e.g. Audacity).
4. Identify the audio you want to patch and note down the sample offset and length.
5. Record your new audio with exact the same length.
6. Export the new audio as Unsigned 8-bit WAV.
7. Run "cvsd-encoder.py" on the file to generate the CVSD data.
8. Patch the generated CVSD data into the ROM manually with "dd" or a hex editor.
   The offset to where to put it, is the sample offset you got from the Audio software previously divided by 8.
9. Burn the patched ROM file to the correctly sized EPROM chip.

## Description
### cvsd-decoder.py / cvsd-encoder.py
These are rather low level tools, that can be used to quickly listen to CVSD data, extract and encode them.
However, patching ROMs with them requires manual labor: The exact offsets and sizes need to be calculated manually
and the patching has to be done with other tools like "dd" or a hex editor.

#### cvsd-decoder.py
This script decodes all bytes in a file as CVSD data and plays it on the computers speaker.
Instead of sending the data to the speaker, it can also be saved as a WAV file.

It can be run for example over any pinball ROM file to identify and convert speech data.

#### cvsd-encoder.py
This scripts converts a WAV file to CVSD data, that can be patched into a ROM file.

### cvsdchip.py
This is the actual simulation of the CVSD chip "Harris HC55536". I more or less [copied](https://github.com/vpinball/pinmame/blob/master/src/sound/hc55516.c) from the PinMAME project.

### wpc89-extractor.py / wpc89-patcher.py
These tools make patching of CVSD data easier and also more exact, but only work on WPC89 ROM sets.

#### wpc89-extractor.py
This script parses the CVSD data table, used by the WPC sound board system software and extracts and converts the according CVSD data into WAV files.

#### wpc98-patcher.py
This scripts patches ROM files. Adjusted WAV files, which were initially created by wpc98-extractor.py, are used as input data.

## TODO
- Create extractor / patcher scripts for System 11 and other machine types. So one does need to rely on the "tedious approach".
- Extend functionality to create completely new CVSD data tables and therefore allow sounds with different lengths.

## Technical Notes
### EPROM Chips
I use the Flash Chip "Microchip SST39SF040" instead of EPROMs. This allows me to burn ROMS over and over on the same chip with my "TL866 II Plus".
However, if the ROM is 512K, the address line A18 is used, which is unfortunatley mapped diffrently on the SST39SF040 than on a M27C4001.

A better alternative could be the "Winbond W27E040" chip, which is pin-compatible with the M27C4001. 
But I also made an adapter for the SST39DF040: https://github.com/nerdprojects/eprom-adapters

### WPC89 Sound Board
The sound board system software is stored at the end of U18 and is mapped into the 6809 memory at location 0xc000.
U18 also contains the table with the CVSD data. The pointer to it is at 0x4015, which may end up at different offsets in the ROM file,
depending on the ROM file size.
#### Memory Map
     _____________
    |             |
    | 0000 - 1FFF | RAM
    |_____________|
    |             |
    | 2000 - 2001 | BANK SWITCHER
    |_____________|
    |             |
    | 2400 - 2401 | YM2151
    |_____________|
    |             |
    | 2800 - 2801 | DAC
    |_____________|
    |             |
    | 2C00 - 2C01 | HC55536 SET
    |_____________|
    |             |
    | 3000 - 3001 | WPC LATCH READ
    |_____________|
    |             |
    | 3400 - 3401 | HC55536 CLEAR
    |_____________|
    |             |
    | 3800 - 3801 | WPC VOLUME
    |_____________|
    |             |
    | 3C00 - 3C01 | WPC LATCH WRITE
    |_____________|
    |             |
    | 4000 - BFFF | BANKED ROM
    |_____________|
    |             |
    | C000 - FFFF | SYSTEM ROM
    |_____________|


## Thanks
Many thanks to the [PinMAME](https://github.com/vpinball/pinmame) team that created the HC55536 emulation and reversed the bank switching logic, they did the hard work.
Also thanks goes out to [Jeri Ellsworth](https://www.youtube.com/watch?v=2FRGwuxFDE4). I got the idea from her YouTube video, how the CVSD encoder can be implemented.
