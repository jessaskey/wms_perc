Jungle Lord L3 Software Release Notes

Copyright 2005 Jess M. Askey(jess@askey.org)

Goals:

	1. Add more sound effects to make the game less monotonous
	2. Add more complex lighting effects
	4. Remove the long annoying bell ring during mutiball start
	5. Fix the Left Magna Save button bug during multiball start
	6. Improve the multiball sound effects to remove the endlessly repeating elephant trumpet
	7. Change no gameplay rules whatsoever (for D)
	8. Change the strange UFO background sound to something a little more 'junglelike'.

Change:

	CPU Board
	
		The upgrade to Jungle Lord L3 requires two new game ROM's at IC26(2716) and IC14(2716). If you have EPROM's
		in these locations, they may be erased and re-burned as the size requirements for them are the same.
		You may also burn new EPROM's if you want to save your original Jungle Lord L2 Game ROM's. This is 
		the only change to the Level 7 CPU board. When the game is put into test mode, the player 1 score display
		should show '2503 3' after the upgrade.
		   
	Sound Board
	
		To support the added sounds and speech, the sound board will need two changes.
		
		1. Speech ROM's - The production L2 sound ROM set included a single 2716 Sound ROM and (3)2532 
		   speech EPROM's or mask ROM's. L3 requires (1) 2716 sound ROM and (4) 2532 Speech ROM's. 
		   
		2. In order for the new software to accomodate the extended sounds. A jumper wire needs to be changed 
		   on the sound board. In stock Jungle Lord sound boards, W9 is in place. This jumper wire needs to be 
		   removed, and W4 needs to be inserted. This will allow the sound board to take up to 64 sound 
		   commands from the CPU board instead of the default 32. Because of this modification, DIP switch
		   #2 which normally controls the enabling/disabling of speech in the game is non-functional. All
		   Jungle Lord games with L3 software will have speech regardless of this setting. Also, to 
		   conserve space in the L3 sound software, all chime sounds have been removed. This effects DIP 
		   switch #1 which controls the enabling/disabling of the chime sounds. All L3 games will not have
		   the ability to play electronic chime sounds.
		   
Instructions:

	The jngld_l3.zip file contains the following files...
	
	readme.txt 	- this file
	ic14.716 	- the ROM image for the 2716 EPROM at location IC14
	ic26.716	- the ROM image for the 2716 EPROM at location IC26
	sound3a.716	- the ROM image for the 2716 EPROM on the sound board.
	speech4.532 - the ROM image for the 2532 EPROM on the speech board at location 4.
	speech5.532 - the ROM image for the 2532 EPROM on the speech board at location 5.
	speech6.532 - the ROM image for the 2532 EPROM on the speech board at location 6.
	speech7.532 - the ROM image for the 2532 EPROM on the speech board at location 7.
	
	I am not going to go into how to program EPROM's here since there are many different devices that can do 
	this and have specialized instructions. You do need to replace all 7 ROM's for the L3 upgrade.
	
	If you have problems or questions, please let me know at jess@askey.org