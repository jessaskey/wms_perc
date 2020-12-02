;***************************************************************************
;* Williams Level 7 Game ROM Template: 
;* File Version 0.29 Updated 10-18-2004
;* Check back for more recent versions.
;***************************************************************************
;* While this file describes and works with the Wiliams Level 7 Flipper OS
;* there is no code contained in this file, it is simply a description and
;* implementation of an interface to the copyrighted code used by Williams
;* Electronic Games Inc.
;***************************************************************************
;* I belive this code was the creation of Larry Demar and the group of 
;* inventive programmers at Williams during 1980. If you have information
;* on the origins of this system and would like to share them, please email
;* me.
;***************************************************************************
;* Written/Decoded by Jess M. Askey (jess@askey.org)
;* More info at...
;*    http://www.gamearchive.com/pinball/manufacturer/williams/pinbuilder
;***************************************************************************
;* The following included file contains the name exports for common system
;* calls.
;***************************************************************************
#include "level7.exp"
#include "wvm7.asm"
#include "7gen.asm"


;*****************************************************************
;* Define Our Solenoids and the time they should be on for each
;* trigger. This is very handy for using the solenoid routines
;* later. This table is an example for Jungle Lord Solenoids.
;*****************************************************************
outhole_on        .equ	$00+SOLENOID_ON_2_CYCLES
outhole_off       .equ	$00+SOLENOID_OFF
trough_on         .equ	$01+SOLENOID_ON_2_CYCLES
trough_off        .equ	$01+SOLENOID_OFF
gi_on	            .equ	$02+SOLENOID_ON_LATCH
gi_off            .equ  $02+SOLENOID_OFF
dtleft_on         .equ	$03+SOLENOID_ON_3_CYCLES
dtleft_off        .equ	$03+SOLENOID_OFF
dtright_on        .equ	$04+SOLENOID_ON_3_CYCLES
dtright_off       .equ	$04+SOLENOID_OFF
buzzer_on         .equ	$05+SOLENOID_ON_LATCH
buzzer_off        .equ	$05+SOLENOID_OFF
lowereject_on     .equ	$06+SOLENOID_ON_2_CYCLES
lowereject_off    .equ	$06+SOLENOID_OFF
uppereject_on     .equ	$07+SOLENOID_ON_2_CYCLES
uppereject_off    .equ	$07+SOLENOID_OFF
dt1_on	      .equ	$08+SOLENOID_ON_2_CYCLES
dt1_off 	      .equ	$08+SOLENOID_OFF
dt2_on            .equ	$09+SOLENOID_ON_2_CYCLES
dt2_off           .equ	$09+SOLENOID_OFF
dt3_on            .equ	$0A+SOLENOID_ON_2_CYCLES
dt3_off    	      .equ	$0A+SOLENOID_OFF
dt4_on	      .equ	$0B+SOLENOID_ON_2_CYCLES
dt4_off	      .equ	$0B+SOLENOID_OFF
dt5_on	      .equ	$0C+SOLENOID_ON_2_CYCLES
dt5_off	      .equ	$0C+SOLENOID_OFF
dtrelease_on	.equ	$0D+SOLENOID_ON_3_CYCLES
dtrelease_off     .equ	$0D+SOLENOID_OFF
bell_on_short     .equ	$0E+SOLENOID_ON_6_CYCLES
bell_on	      .equ	$0E+SOLENOID_ON_LATCH
bell_off	      .equ	$0E+SOLENOID_OFF
minikick_on       .equ	$13+SOLENOID_ON_1_CYCLES
minikick_on_hard  .equ	$13+SOLENOID_ON_2_CYCLES
minikick_off      .equ	$13+SOLENOID_OFF
leftmag_on        .equ	$14+SOLENOID_ON_LATCH
leftmag_off       .equ	$14+SOLENOID_OFF
rightmag_on       .equ	$15+SOLENOID_ON_LATCH
rightmag_off      .equ	$15+SOLENOID_OFF
flippers_on       .equ	$18+SOLENOID_ON_LATCH
flippers_off      .equ	$18+SOLENOID_OFF

;***************************************************************************
;* Game ROM Required tables start at $E000. Keep in mind that you may also 
;* used the ROM space between $D000-$E000 with the correct jumper settings.
;* This data located here is required to begin at $E000. These data tables
;* define a basic setup for the game. Specific code needs to then be 
;* implemented for all system events and all switch inputs.
;*****************************************************************************
      .org $d800
      .nocodes		;So we dont have list file buffer overflows

gr_low_start  .fill      gr_high_start-gr_low_start,$00


;***********************************************
;* Expanded Game ROM goes here, use only if you run out of space following 
;* the data tables from $E0BF

	.org $e000

gr_high_start
;*****************************************************************************
;* GameNumber: This is the Williams assigned game number. From what I can tell
;* 		   all games that had the possibility of being produced were 
;*             assigned a game number. Some game numbers are skipped suggesting
;*             that those games were scrapped along the way and didn't make
;*             it to production. If you are planning on making a game with 
;*             this source code, then please visit the pinbuilder website at
;*
;*             http://www.gamearchive.com/pinball/manufacturer/williams/pinbuild
;*
;*             I will assign you a game number, I want to keep a list of games
;*             produced with this framework if possible. You will also be
;*             given space on gamearchive.com to display info on your game and
;*             any other info.
;*             Williams game numbers used were as follows:
;*
;*			Game Name				Model 	Production Run
;*                --------------------------------------------------------
;*			Black Knight			#500		13075
;*			Cosmic Gunfight (Dragonfly)	#502		1008
;*			Jungle Lord				#503		6000
;*			Pharaoh				#504		2500
;*			Cyclone				#505		-
;*			Black Knight Limited Edition	#506		600
;*			Solar Fire				#507		782
;*			Thunderball				#508		10
;*			Hyperball				#509		??
;*			Barracora				#510		2350
;*			Varkon				#512		90
;*			Spellbinder				#513		-
;*			Reflex				#514		-
;*			Time Fantasy			#515		608
;*			Warlok				#516		412
;*			Defender				#517		369
;*			Joust					#519		402
;*			Laser Cue				#520		2800
;*			Firepower II			#521		3400
;*			Guardian				#523		-
;*			Star Fighter			#524		-
;*			Pennant Fever (level 8)		#526		??
;*			Rat Race				#527		10
;*			Light Speed				#528		-
;*			
;*		   New games will start at game #900
;*********************************************************************************
;*
;* ROM Revision:  This is the revision level of the game. The example below is set
;*                to game number #900 and ROM revision level 1.
;*********************************************************************************

gr_gamenumber			.db $F9,$00
gr_romrevision			.db $01

;*********************************************************************************
;* CMOS Checksum: These two bytes must always add up to equal $57, this is how
;*                the system determines if the CMOS RAM data is valid. If they 
;*                do not add up correctly, then factory settings are restors
;*                and the audits are reset. These values are part of the default
;*                data used when factory settings are restored. You should leave
;*                them with the default values.
;*********************************************************************************
gr_cmoscsum				.db $B2,$A5

;*********************************************************************************
;* Factory Settings Data: This is the data the is used on a factory settings 
;*                        restore. They are pretty self explanitory and match
;*                        with functions 13-40 in the game adjustments.
;*********************************************************************************
gr_backuphstd			.db $25	; 2,500,000
gr_replay1				.db $10	; 1,000,000
gr_replay2				.db $20	; 2,000,000
gr_replay3				.db $00	; 0,000,000 (disabled)
gr_replay4				.db $00	; 0,000,000 (disabled)
gr_matchenable			.db $00	; 00=match on, 01=match off
gr_specialaward			.db $00	; 00=credit, 01=extraball, 02=points
gr_replayaward			.db $00	; 00=credit, 01=extraball, 02=points
gr_maxplumbbobtilts		.db $03	
gr_numberofballs			.db $05	

;*********************************************************************************
;* Game Specific Adjustments: There are 9 placeholders that the GAME ROM is allowed
;*                            to use for game specific adjustments. These are not
;*                            for system variables but should be for your game
;*                            specifically (ex.. Drop Target Reset Time, etc).
;*********************************************************************************
gr_gameadjust1			.db $00	
gr_gameadjust2			.db $00
gr_gameadjust3			.db $00
gr_gameadjust4			.db $00
gr_gameadjust5			.db $00
gr_gameadjust6			.db $00
gr_gameadjust7			.db $00
gr_gameadjust8			.db $00
gr_gameadjust9			.db $00


gr_hstdcredits			.db $03
gr_max_extraballs			.db $04
gr_max_credits			.db $30

;************************************************************************
;* Pricing Data: These are the preset coin data that can be loaded via 
;*               Game Function 19. You probably do not need to change these
;*               as Williams has them working quite well as is. :-)
;************************************************************************
gr_pricingdata		
	
	;usa (1/25c,4/$1)
	.db	$01		;Left Coin Slot Multiplier
	.db	$04		;Center Coin Slot Multiplier
	.db	$01		;Right Coin Slot Multiplier
	.db	$01		;Coin Units Required for Coin
	.db	$00		;Bonus Coins
	.db	$00		;Unknown

	;germany (1/1DM,3/2DM,10/5DM)
	.db	$09		;Left Coin Slot Multiplier
	.db	$45		;Center Coin Slot Multiplier
	.db	$18		;Right Coin Slot Multiplier
	.db	$05		;Coin Units Required for Coin
	.db	$45		;Bonus Coins
	.db	$00		;Unknown

	;usa-alt (1/50c,3/$1,6/$2)
	.db	$01		;Left Coin Slot Multiplier    
	.db 	$04		;Center Coin Slot Multiplier  
	.db 	$01		;Right Coin Slot Multiplier   
	.db 	$02		;Coin Units Required for Coin 
	.db 	$04		;Bonus Coins                  
	.db 	$00		;Unknown                      
	
	;france (1/2F,3/5F only,8/10F only)
	.db 	$01		;Left Coin Slot Multiplier    
	.db 	$16		;Center Coin Slot Multiplier  
	.db 	$06		;Right Coin Slot Multiplier   
	.db 	$02		;Coin Units Required for Coin 
	.db 	$00		;Bonus Coins                  
	.db 	$00		;Unknown                      
	
	;usa-alt (1/50c,2/75c,3/4x25c,4/$1,4/5x25c)
	.db 	$03		;Left Coin Slot Multiplier    
	.db 	$15		;Center Coin Slot Multiplier  
	.db 	$03		;Right Coin Slot Multiplier   
	.db 	$04		;Coin Units Required for Coin 
	.db 	$15		;Bonus Coins                  
	.db 	$00		;Unknown                      
	
	;netherlands (1/25c,4/1G)
	.db 	$01		;Left Coin Slot Multiplier    
	.db 	$00		;Center Coin Slot Multiplier  
	.db 	$04		;Right Coin Slot Multiplier   
	.db 	$01		;Coin Units Required for Coin 
	.db 	$00		;Bonus Coins                  
	.db 	$00		;Unknown                      
	
	;france-alt (1/5F,2/10F)
	.db 	$01		;Left Coin Slot Multiplier    
	.db 	$00		;Center Coin Slot Multiplier  
	.db 	$02		;Right Coin Slot Multiplier   
	.db 	$01		;Coin Units Required for Coin 
	.db 	$00		;Bonus Coins                  
	.db 	$00		;Unknown                      
	
	;france-alt (1/10F)
	.db 	$01		;Left Coin Slot Multiplier    
	.db 	$00		;Center Coin Slot Multiplier  
	.db 	$02		;Right Coin Slot Multiplier   
	.db 	$02		;Coin Units Required for Coin 
	.db 	$00		;Bonus Coins                  
	.db 	$00		;Unknown                       
	
;********************************************************
;* More Game Variables
;********************************************************
gr_maxthreads			.db $1d	;IMPORTANT: This is the size of the vm. It should be tweaked so that your vm 
							;           and stack do not clobber each other. vm builds up from the bottom
							;		and stack comes down from the top. I put in a safe value of $1d
							;		for now. If the game gets overwhelmed with tasks, you may need to 
							;		increase this value to give the vm more threads to work with.
							
gr_extendedromtest		.db $FF	;If this value is negative the self test procedure does not test for ROM 
							;at location $D800-$DFFF. If the value is positive, then the Low GameROM 
							;will be tested. 

gr_lastswitch			.db (switchtable_end-switchtable)/3	;This is simply the length of the switchtable

gr_numplayers			.db $03	;default 4 players possible to play in a single game.

;********************************************************
;* Table Pointers: This are pointers to the start of
;* each table required by the system. Descriptions of the
;* tables and their data are described with the tables. 
;* You may put the actual tables anywhere in the GAME ROM,
;* but they must exist and these pointers must contain
;* their locations.
;********************************************************
gr_lamptable_ptr			.dw lampgrouptable
gr_switchtable_ptr		.dw switchtable
gr_soundtable_ptr			.dw soundtable


gr_lampflashrate			.db $05	;This set the flash speed of all lamps

;********************************************************
;* Defines the system sound events for this game. The 
;* value is the sound command sent when the event occurs.
;* For initial simplicity, you may want to pick an existing
;* games Sound ROM and then copy the default sound data
;* for that game. Once you get gameplay rules defined and
;* working, then concentrate on the sound implementation.
;********************************************************
gr_specialawardsound		.db $00
gr_p1_startsound			.db $00
gr_p2_startsound			.db $00
gr_p3_startsound			.db $00
gr_p4_startsound			.db $00
gr_matchsound			.db $00
gr_highscoresound 		.db $00
gr_gameoversound			.db $00
gr_creditsound			.db $00

;********************************************************
;* Defines the location for system lamps. These are all
;* lamps that the system expects to exist since they 
;* respond to system status. There are two Extra Ball lamps
;* since there is typically a backbox lamp and a playfield
;* lamp. Most of these are defaultly located in the same
;* locations on the lamp matrix, so you probably don't need
;* to change them.
;********************************************************
gr_eb_lamp_1      		.db $00	;default location
gr_eb_lamp_2			.db $00	
gr_lastlamp				.db $00	
gr_hs_lamp				.db $05	;default location
gr_match_lamp			.db $04	;default location
gr_bip_lamp				.db $01	;default location
gr_gameover_lamp			.db $03	;default location
gr_tilt_lamp			.db $02	;default location


;********************************************************
;* Game Over Entry Point Pointer. This is the pointer to 
;* the GAME ROM code that is to be run when a game is over.
;* You should do things here like eject captured balls, or
;* reset drop targets etc. This is basicaly the place to 
;* do your post game cleanup.
;********************************************************
gr_gameoverthread_ptr		.dw gameover_entry

;*******************************************************
;* Switch Characteristics Table
;*******************************************************
;* Max Length = 7 Switch Types!!     *
;*************************************
;* This set of data describes the switch types installed
;* on the game. You can have up to 7 switch types in which
;* the switch table references. These types define how
;* responsive a switch is and how it reacts. They seem
;* to be pretty standard for most games and this table
;* probably does not need to change. These switch types
;* are part of the switch table so that every switch in
;* your game is categorized into one of these. Each type 
;* consists of two pieces of data...
;* 
;*	Trigger Time Down - byte 1
;*	Trigger Time Up	- byte 2
;*
;* Examples:
;*	$00,$02 (quick response, 10-point switches, slings)
;*	$00,$09 (typical stand-up targets, ball-roll tilt)
;*	$00,$04 (typical rollover lane)
;*	$1A,$14 (kickout holes, plumb-bob tilt)
;*	$02,$05 (drop target)
;*	$08,$05 (outhole)
;*	$00,$24 (ballshooter trough)
;*	$00,$01 (spinner)
;*
;*********************************************************
gr_switchtypetable		

swtype0	.db 	$00,$02
swtype1	.db 	$00,$09
swtype2	.db 	$00,$04
swtype3	.db 	$1A,$14
swtype4	.db 	$02,$05
swtype5	.db 	$08,$05
swtype6	.db 	$00,$24

;*******************************************************
;* Player Initial Data:
;* Each player has a section of RAM dedicated to their 
;* specific game data. It is 20 bytes long for each 
;* player and you may divide it up and define it however
;* you want for your game. The data in this table is the
;* data that is initially loaded into each players data
;* area on their game start.
;*******************************************************
gr_playerstartdata		

	.db $00,$00,$00,$00,$00
	.db $00,$00,$00,$00,$00
	.db $00,$00,$00,$00,$00
	.db $00,$00,$00,$00,$00

;*******************************************************
;* Player Data Reset Flags:
;* This is the mask that is applied to the player data
;* at the start of every new ball. It allows you to reset
;* specific bits of your game data at the start of every
;* new ball. This mask is applied at the end of *every*
;* ball, even extra balls. It is not applied on ball 
;* captures (unless you want it to, but then you would
;* have to code that yourself into the GAME ROM). If a 
;* bit is set here, then that bit in the player data is 
;* reset on next ball.
;*
;* It is an inverse mask. The defaults shown below will
;* reset every bit.
;*******************************************************
gr_playerresetdata		

	.db $FF,$FF,$FF,$FF,$FF
	.db $FF,$FF,$FF,$FF,$FF
	.db $FF,$FF,$FF,$FF,$FF
	.db $FF,$FF,$FF,$FF,$FF

;********************************************************
;* Event Entry Points:
;* These are locations that are jumped to on certain 
;* events. Because they are only two bytes long each, 
;* you have to branch to your code block or simply put
;* an 'rts' for the unused ones plus a dummy byte.
;* These event hooks allow you to add additional functionality
;* at each of these events. For example, Jungle Lord rings
;* the bell in a specific pattern when a credit is earned.
;*
;* These defaults all return without any additional actions.
;********************************************************
gr_switch_event			.db $39,$00
gr_sound_event   			.db $39,$00
gr_score_event			.db $39,$00
gr_eb_event				.db $39,$00
gr_special_event			.db $39,$00
gr_macro_event			.db $39,$00
gr_ready_event			.db $39,$00
gr_addplayer_event		.db $39,$00
gr_gameover_event 		.db $39,$00
gr_hstdtoggle_event		.db $39,$00

;********************************************************
;* System Hooks:
;* These are pointers to code blocks that can be run at
;* certain times within the system. This allows the game
;* to expand upon the system quite a bit in it's functionality.
;* All hooks are pointers to code entry points. You cannot
;* run code here like the event entry points above. If you
;* want to return, then you have to point to an 'rts'  
;* opcode somewhere else, like the sacrificial RTS above.
;* You should leave these alone at first until you start
;* getting more complex game rules that need to take 
;* advantage of this flexibility.
;********************************************************
gr_reset_hook_ptr			.dw gr_rts
gr_main_hook_ptr			.dw gr_rts
gr_coin_hook_ptr			.dw gr_rts
gr_game_hook_ptr			.dw gr_rts
gr_player_hook_ptr		.dw gr_rts
gr_outhole_hook_ptr		.dw gr_rts

;********************************************************
;* Game ROM IRQ Entry: Use this for game specific processing
;*                     on the IRQ interrupt. Typicall there
;* 			     is nothing here except a jump to the
;*                     system irq entry. If you want to 
;*                     run additional code, then jump to
;*                     your code block here. 
;*
;* NOTE!!! You must jump to the 'sys_irq' when done with 
;*         your code. If you dont you will find your game 
;*         will not *do* anything since the system IRQ 
;*         code never gets called.
;********************************************************
gr_irq_entry	
		;Put your IRQ code (if any) here
		
		
		
		;this next line must be the last line of your irq code
		jmp sys_irq	

;********************************************************
;* Game ROM SWI Entry: This is the System Hook for the 
;*                     CPU's SWI instruction. Unless you
;*                     plan on using the SWI instruction
;*                     This can be blank. I have the default
;*                     set to go to the system reset.
;********************************************************
gr_swi_entry	jmp reset

;********************************************************
;********************************************************
;* THIS IS THE END OF THE REQUIRED LENGTH GAME ROM TABLES.
;* IF ALL IS SET UP CORRECTLY THEN THE FOLLOWING CODE 
;* SHOULD BEGIN AT $E0C5. IF YOUR ADDRESS IS OFF, THEN
;* YOUR GAME CODE IS MOST LIKELY GOING TO CRASH.
;*
;********************************************************
;* This is the dummy return location that most of the
;* above hooks use when 'not used' 
;********************************************************
;********************************************************
gr_rts		.db $39,$00

;********************************************************
;* Game Lamp Group Table: This table defines the specific
;*                        lamp grouping by index so that 
;*                        effects can be performed on 
;*                        those groups. Each entry has
;*                        two bytes the first defines
;*                        the first lamp in the group,
;*                        the second defines the last
;*                        lamp in the group. All lamps
;*                        in between are part of the 
;*                        group as well. This table is
;*                        used for lamp effects. For 
;*                        instance, you typically group
;*                        lamps together in the way that
;*                        you want to present your effects.
;*
;* Example: All multipler lamps are in a group. All lamps
;*          that spell out words are typically in a group.
;*
;* NOTE: This table is limited to 32 entries or $1F hex
;*       There are really no methods to check if you 
;*       expand beyond the end of this table so be sure
;*       you do not specify an index past the end of the
;*       table else you may run into funky problems. The
;*       index to each group is used in the lamp effect
;*       macros to apply an effect to the group instaed
;*       of manually having to change each lamp. The OS
;*       is smart enought to do everything for you. Nice
;*       ehhh? You proabaly need to define some basic
;*       groups or at least one so you can fiddle with
;*       the effects and learn how they work.
;*
;* WORKSHEET: Put your Lamp Matrix in Here
;*
;*    #     ROW   COL   DESCRIPTION
;*    01    1     1     
;*    02    2     1     
;*    03    3     1
;*    04    4     1
;*    05    5     1
;*    06    6     1
;*    07    7     1
;*    08    8     1
;*    09    1     2
;*    10    2     2
;*    11    3     2
;*    12    4     2
;*    13    5     2
;*    14    6     2
;*    15    7     2
;*    16    8     2
;*    17    1     3
;*    18    2     3
;*    19    3     3
;*    20    4     3
;*    21    5     3
;*    22    6     3
;*    23    7     3
;*    24    8     3
;*    25    1     4
;*    26    2     4
;*    27    3     4
;*    28    4     4
;*    29    5     4
;*    30    6     4
;*    31    7     4
;*    32    8     4
;*    33    1     5
;*    34    2     5
;*    35    3     5
;*    36    4     5
;*    37    5     5
;*    38    6     5
;*    39    7     5
;*    40    8     5
;*    41    1     6
;*    42    2     6
;*    43    3     6
;*    44    4     6
;*    45    5     6
;*    46    6     6
;*    47    7     6
;*    48    8     6
;*    49    1     7
;*    50    2     7
;*    51    3     7
;*    52    4     7
;*    53    5     7
;*    54    6     7
;*    55    7     7
;*    56    8     7
;*    57    1     8
;*    58    2     8
;*    59    3     8
;*    60    4     8
;*    61    5     8
;*    62    6     8
;*    63    7     8
;*    64    8     8
;*
;********************************************************
lampgrouptable

      ;here is an example lamp group that includes eight groups
      ;of eight lamps that correspond to each column
      
      .db $00 ,$07	;(Lamp#01 - Lamp#08
      .db $08 ,$1F	;(Lamp#09 - Lamp#16
      .db $10 ,$17	;(Lamp#17 - Lamp#24
      .db $18 ,$1F	;(Lamp#25 - Lamp#32
      .db $20 ,$27	;(Lamp#33 - Lamp#40
      .db $28 ,$2F	;(Lamp#41 - Lamp#48
      .db $30 ,$37	;(Lamp#49 - Lamp#54
      .db $38 ,$3F	;(Lamp#55 - Lamp#64


;********************************************************
;* Game Switch Table: Contains 3 bytes per switch.
;*
;* Byte 1 - Switch Flags
;*          $80:	Entry Code Type (1=Macro 0=Native Code)
;*          $40:	Active on Tilt Status
;*          $20:	Active on Game Over Status
;*          $10:	Switch Enabled
;*          $08:	Instant Trigger 
;*          
;*          Mask $07: Defines switch type index
;*
;* Byte 2,3: Pointer to switch handing routine or Pointer
;*           to custom switch type data followed by 
;*           handler routine (see below)
;*
;* An important note is the switch type index. If this
;* is equal to 1 thru 7, then the switch type is defined
;* by the index 1-7 into the switch type table. If the
;* value of the switch type index is equal to 0, then
;* the following two bytes are a pointer to the handler
;* PRECEEDED by two bytes defining the switch type.
;* 
;* EXAMPLE:
;*
;*  .db %10010000  \.dw mycustomswitchtype
;*  <snip>
;* 
;*  mycustomswitchtype
;*			  .db $01.$20
;*                  <now handler code or WML7 follows>
;*   
;* You can also use some defines instead of binary if you want
;* to organize the flags better. They are..
;*
;*    sf_wml7	      .equ	$80
;*    sf_code 	      .equ 	$00
;*    sf_tilt	      .equ	$40
;*    sf_notilt         .equ  $00
;*    sf_gameover	      .equ	$20
;*    sf_nogameover     .equ  $00
;*    sf_enabled	      .equ	$10
;*    sf_disabled       .equ  $00
;*    sf_instant	      .equ	$08
;*    sf_delayed        .equ  $00
;*
;* The switch table contains one entry for every switch
;* up to 'maxswitch'. Make sure that you get your table 
;* row count correct (this should be done automatically
;* actually). 
;*
;* Here are some example entries, the '%' percent character
;* is my 'binary' number specifier in TASMx. Your assembler
;* may be different. I put them in binary for ease of sight.
;*
;*  .db %10010011  \.dw gr_plumbtilt    ;(1) Plumb Bob Tilt
;*  .db %10010001  \.dw gr_balltilt     ;(2) Ball Roll Tilt
;*  .db %11110001  \.dw gr_creditbtn    ;(3) Credit Button
;*  .db %11110010  \.dw gr_coin_r       ;(4) Right Coin
;*  .db %11110010  \.dw gr_coin_c       ;(5) Center Coin
;*  .db %11110010  \.dw gr_coin_l       ;(6) Left Coin
;*  .db %01110001  \.dw reset          ;(7) Slam
;*  .db %01110001  \.dw gr_hstd         ;(8) High Score Reset
;*
;* OR ALTERNATIVELY USING DEFINES
;*
;*  .db sf_wml7+sf_enabled+swtype3                          \.dw gr_plumbtilt    ;(1) Plumb Bob Tilt
;*  .db sf_wml7+sf_enabled+swtype1                          \.dw gr_balltilt     ;(2) Ball Roll Tilt
;*  .db sf_wml7+sf_tilt+sf_gameover+sf_enabled1+swtype1     \.dw gr_creditbtn    ;(3) Credit Button
;*  .db sf_wml7+sf_tilt+sf_gameover+sf_enabled1+swtype2     \.dw gr_coin_r       ;(4) Right Coin
;*  .db sf_wml7+sf_tilt+sf_gameover+sf_enabled1+swtype2     \.dw gr_coin_c       ;(5) Center Coin
;*  .db sf_wml7+sf_tilt+sf_gameover+sf_enabled1+swtype2     \.dw gr_coin_l       ;(6) Left Coin
;*  .db sf_code+sf_tilt+sf_gameover+sf_enabled1+swtype1     \.dw reset          ;(7) Slam
;*  .db sf_code+sf_tilt+sf_gameover+sf_enabled1+swtype1     \.dw gr_hstd         ;(8) High Score Reset
;*
;* See how the Tilt switches are ignored if the game is already tilted.
;* Coin and credit buttons aways work, so does the slam and HSTD reset.
;* The last two bytes are the pointer to the code entry point
;* when that switch is activated and it passes all of it's flags.
;* Flag $80 is important to note as it defines which language the 
;* code pointed to will be in. It can be either native 68XX code 
;* or the VM Macro Language at entry. All switches above use WML 
;* at the start of their code entry except for Slam and HSTD reset.
;* 
;* WORKSHEET: Put your Switch Matrix in Here
;*
;*    #     ROW   COL   DESCRIPTION
;*    01    1     1     
;*    02    2     1     
;*    03    3     1
;*    04    4     1
;*    05    5     1
;*    06    6     1
;*    07    7     1
;*    08    8     1
;*    09    1     2
;*    10    2     2
;*    11    3     2
;*    12    4     2
;*    13    5     2
;*    14    6     2
;*    15    7     2
;*    16    8     2
;*    17    1     3
;*    18    2     3
;*    19    3     3
;*    20    4     3
;*    21    5     3
;*    22    6     3
;*    23    7     3
;*    24    8     3
;*    25    1     4
;*    26    2     4
;*    27    3     4
;*    28    4     4
;*    29    5     4
;*    30    6     4
;*    31    7     4
;*    32    8     4
;*    33    1     5
;*    34    2     5
;*    35    3     5
;*    36    4     5
;*    37    5     5
;*    38    6     5
;*    39    7     5
;*    40    8     5
;*    41    1     6
;*    42    2     6
;*    43    3     6
;*    44    4     6
;*    45    5     6
;*    46    6     6
;*    47    7     6
;*    48    8     6
;*    49    1     7
;*    50    2     7
;*    51    3     7
;*    52    4     7
;*    53    5     7
;*    54    6     7
;*    55    7     7
;*    56    8     7
;*    57    1     8
;*    58    2     8
;*    59    3     8
;*    60    4     8
;*    61    5     8
;*    62    6     8
;*    63    7     8
;*    64    8     8
;*
;********************************************************
switchtable

      ; These are actually standard on level 7 games, so I will
      ; leave them here.
      .db %10010011  \.dw sw_plumbtilt    ;(1) Plumb Bob Tilt
      .db %10010001  \.dw sw_balltilt     ;(2) Ball Roll Tilt
      .db %11110001  \.dw credit_button    ;(3) Credit Button
      .db %11110010  \.dw sw_coin_r       ;(4) Right Coin
      .db %11110010  \.dw sw_coin_c       ;(5) Center Coin
      .db %11110010  \.dw sw_coin_l       ;(6) Left Coin
      .db %01110001  \.dw reset          ;(7) Slam
      .db %01110001  \.dw sw_hstd_res     ;(8) High Score Reset



switchtable_end

;********************************************************
;* Game Sound Table: 3 Bytes per entry
;*
;*   If sound is 'complex', then Byte 1-2 is a pointer to the entry
;*   of the extended data
;*
;*        Byte 1 - Sound Flags
;*        Byte 2 - Timer until next sound can be played
;*        Byte 3 - Sound Command (or FF if 'extended intruction sound')
;*
;********************************************************	
soundtable

      ; example
      .db $23, $06,	$3A;(05)	;(00) Credit Sound on most sound ROMS

;********************************************************
;* Complex Sound Data Format
;*
;* This is optional since it is only required if you 
;* decide to use complex sounds. Sound effects are an
;* art and I can't say Im that great at it yet. Use lables
;* to your complex sound data streams as the first two
;* bytes of the index sound table above, followed by $FF
;* to flag it as a complex sound run.
;*
;* The format of the complex sound stream can be different
;* lengths depending on the data.
;*
;* Byte 1: Timer Flags and Sound Command
;*   
;*         Format: LXSSSSSS
;*
;*         Where: L selects high or low resolution timer (0=low 1=high)
;*                X enables a sound timer if length is word (1=enabled 0=disabled)
;*                SSSSSS is the sound command sent to the sound board.
;*
;* No matter which resolution is selected, the timer is a word length. If 
;* low resolution is selected, then the value in SSSSS is stored in the
;* low byte of the counter and the high byte is zeroed. If high res is
;* selected, then there will be two databytes to follow in the stream.
;* First byte is MSB and second is LSB.
;*		
;* Byte 2 and possibly 3:
;*         Contains a time value to allow this sound to play before 
;*         continuing on to the next entry in the complex sound stream.
;*         
;* The complex sound stream continues until the Byte 1 value is $3F.
;* NOTE: No count values can be negative, sign bit is always dropped 
;*       and set to positive.
;*
;* Example:
;* 
;* my_sound	.byte $C3,$91,$29,$88,$29,$3F
;*
;* First Sound: Sends a sound command of $29 and waits $0311 
;*              IRQ's before sending the next. 
;*              of $29. 
;* Second Snd : Sends a sound command of $29 and waits $08 
;*              IRQ's before sending the next. 
;* Third Sound: None, finished.
;********************************************************
; You can put your complex sound stream data anywhere
;********************************************************

;********************************************************
;* Game Over Entry: This is the required code that we 
;* talked about above for Game Over cleanup. It can exist
;* anywhere but it has to at least exist.
;********************************************************
gameover_entry	rts
					
;**********************************************************
;* HSTD Reset Switch: 
;**********************************************************
sw_hstd_res		JSRD_(restore_hstd)		
			KILL_					;Remove This Thread
								
;************************************************************
;* Coin Routines, this simply plays sound $00 and jumps to 
;* the system coin routine which does all the coin code and
;* then plays sound $00 again.
;************************************************************	
sw_coin_c
sw_coin_l
sw_coin_r		SSND_($00)				;Credit Sound
			JMP_(coin_accepted)		

;************************************************************
;* Tilt Routines:
;************************************************************
sw_pf_tilt
sw_plumbtilt	EXE_
			      NEWTHREAD(min_tilt)
			EXEEND_
			IFNER_($FB,$40,$F0)	      ;BEQR_(TILT || BIT#00)
      			SSND_($08)				;Sound #08
      			JSRD_(tilt_warning)		
      			BEQR_($F0,you_tilted)		;BEQR_TILT to you_tilted
      			JSRR_(gi_off_inc)			
      			SLEEP_(2)
      			JSRR_(gi_on_dec)
      	      ENDIF_			
			KILL_					;Remove This Thread

sw_balltilt		IFNER_($40)			      ;BEQR_BIT#00
      			SSND_($08)				;Sound #08
      			JSRD_(do_tilt)			
you_tilted      		JSR_(gi_off_inc)
			
			      ;insert any game specific tilt cleanup code here
			      ;   clear switches for kickout holes so they will eject
			      ;   set any game specific flags
			      
      			SLEEP_(156)
      			SSND_($1C)				;Sound #1C
      	      ENDIF_
			KILL_					;Remove This Thread

;**********************************************************
;* This thread runs for 160 irq's and makes sure that 
;* tilts can only happen every 2.5 seconds at a minimum.
;**********************************************************
min_tilt		jsr	macro_start
			REMTHREADS_($F8,$A0)		;Remove Multiple Threads Based on Priority
			PRI_($A6)				;Priority=#A6
			BITON_($51)				;Turn ON: Bit#11
			SLEEP_(160)
			BITOFF_($51)			;Turn OFF: Bit#11
			KILL_					;Remove This Thread
			
			
;************************************************************		
;* General Illumination Routines
;************************************************************
gi_on_dec		IFNER_($FC,$EC,$00)	      ;BEQR_RAM$0C==#0
			      ADDRAM_($0C,-1)			;RAM$0C-=1
			      BNER_($FC,$EC,$00,gi_on_dec_end)	;BNER_RAM$0C==#0 to gi_on_dec_end
			ENDIF_
			SOL_(gi_off)			;Turn OFF Sol#3:gi
gi_on_dec_end	MRTS_					;Macro RTS, Save MRA,MRB


gi_off_inc		ADDRAM_($0C,$01)			;RAM$0C+=$01
			SOL_(gi_on)			      ;Turn ON Sol#3:gi
			MRTS_					;Macro RTS, Save MRA,MRB					
					
					
					
					
					
					
.end
	

;***********************************************************************************************************
;* Define Exports: You dont need these, they are here for tesing on my end. You may delete them if you wish
;***********************************************************************************************************
.export	gr_gamenumber,gr_romrevision,gr_cmoscsum,gr_backuphstd,gr_replay1,gr_replay2,gr_replay3,gr_replay4
.export	gr_matchenable,gr_specialaward,gr_replayaward,gr_maxplumbbobtilts,gr_numberofballs,gr_gameadjust1
.export 	gr_gameadjust2,gr_gameadjust3,gr_gameadjust4,gr_gameadjust5,gr_gameadjust6,gr_gameadjust7
.export 	gr_gameadjust8,gr_gameadjust9,gr_hstdcredits,gr_max_extraballs,gr_max_credits,gr_pricingdata
.export 	gr_maxthreads,gr_extendedromtest,gr_lastswitch,gr_numplayers,gr_lamptable_ptr,gr_switchtable_ptr
.export	gr_soundtable_ptr,gr_lampflashrate,gr_specialawardsound,gr_p1_startsound,gr_p2_startsound
.export	gr_p3_startsound,gr_p4_startsound,gr_matchsound,gr_highscoresound,gr_gameoversound,gr_creditsound
.export	gr_eb_lamp_1,gr_eb_lamp_2,gr_lastlamp,gr_hs_lamp,gr_match_lamp,gr_bip_lamp,gr_gameover_lamp
.export	gr_tilt_lamp,gr_gameoverthread_ptr,gr_switchtypetable,gr_playerstartdata,gr_playerresetdata
.export	gr_switch_event,gr_sound_event,gr_score_event,gr_eb_event,gr_special_event,gr_macro_event
.export	gr_ready_event,gr_addplayer_event,gr_gameover_event,gr_rts,gr_reset_hook_ptr,gr_main_hook_ptr
.export	gr_coin_hook_ptr,gr_game_hook_ptr,gr_player_hook_ptr,gr_outhole_hook_ptr,gr_irq_entry,gr_swi_entry
.export	gr_hstdtoggle_event,gameover_entry,lampgrouptable,switchtable,switchtable_end,soundtable
