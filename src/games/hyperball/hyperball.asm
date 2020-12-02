;*****************************************************************************
;* Williams Level 7 Flipper Code
;***************************************************************************
;* Code copyright Williams Electronic Games Inc.
;* Written/Decoded by Jess M. Askey (jess@askey.org)
;* For use with TASMx Assembler
;* Visit http://www.gamearchive.com/pinball/manufacturer/williams/pinbuilder
;* for more information.
;* You may redistribute this file as long as this header remains intact.
;***************************************************************************
;* This file is set up with tab stops at 6
;*****************************************************************************
;* DB pointed out that this is probably a good idea.
.msfirst	

#include "68logic.asm"		;68XX Logic Definitions

#include "wvm7.asm"		;Virtual Machine Instruction Definitions

;Requires game definition file, link to the export file
#include "gamerom.exp"

;*****************************************************************************
;* Some Global Equates
;*****************************************************************************

irq_per_minute =	$0EFF

;***********************************************************
;* Level 7 Hardware Definitions                            *
;* 1999-2001 Jess M. Askey                                 *
;***********************************************************
;* This file defines the RAM structure and the actual      *
;* hardware contained on the Level 7 CPU board.            *
;***********************************************************
	.org $0000

ram_base	
vm_reg_a			.block	1		;Virtual Machine Register A
vm_reg_b			.block	1		;Virtual Machine Register B
game_ram_2			.block	1
game_ram_3			.block	1
game_ram_4			.block	1
game_ram_5			.block	1
game_ram_6			.block	1
game_ram_7			.block	1
game_ram_8			.block	1
game_ram_9			.block	1
game_ram_a			.block	1
game_ram_b			.block	1
game_ram_c			.block	1
game_ram_d			.block	1
game_ram_e			.block	1
game_ram_f			.block	1
lampbuffer0			.block	12		;Lamp Buffer 0
bitflags			.block	8
lampbufferselect		.block	8		;Lamp Buffer Selection Bit
lampbuffer1			.block	8		;Lamp Buffer 1
lampflashflag		.block	8		;Lamp Flashing Bits
score_p1_b0			.block	4
score_p2_b0			.block	4
score_p3_b0			.block	4
score_p4_b0			.block	4
score_p1_b1			.block	4
score_p2_b1			.block	4
score_p3_b1			.block	4
score_p4_b1			.block	4
mbip_b0			.block	1
mbip_b1			.block	1
cred_b0			.block	1		;$119A  TODO: this is WAY off from L7 which is 
cred_b1			.block	1
dmask_p1			.block	1
dmask_p2			.block	1
dmask_p3			.block	1
dmask_p4			.block	1
comma_flags			.block	1
switch_debounced		.block	8
switch_masked		.block	8
switch_pending		.block	8
switch_aux			.block	8
switch_b4			.block	8
irq_counter			.block	1
lamp_index_word		.block	2		;This will always be $00 in the MSB, will be a rotating bit in LSB
lamp_bit			.block	1		;
comma_data_temp		.block	1
credp1p2_bufferselect	.block	1
mbipp3p4_bufferselect	.block	1
swap_player_displays	.block	1
solenoid_address		.block	2
solenoid_bitpos		.block	1
solenoid_counter		.block	1
irqcount16			.block	1
switch_queue_pointer	.block	2		;switch_queue_pointer
solenoid_queue_pointer	.block	2		;solenoid_queue_pointer
temp1				.block	2
temp2				.block	2
temp3				.block	2		;$00BC
sys_temp1			.block	1
sys_temp2			.block	1
sys_temp3			.block	1
sys_temp4			.block	1
sys_temp5			.block	1
sw_encoded			.block	1
sys_temp_w2			.block	2
sys_temp_w3			.block	2
thread_priority		.block	1
unused_ram1			.block	1		;$00
irqcount			.block	1
vm_base			.block	2
vm_nextslot			.block	2
current_thread		.block	2
vm_tail_thread		.block	2
lamp_flash_rate		.block	1		;lamp_flash_rate
lamp_flash_count		.block	1
thread_timer_byte		.block	1
soundcount			.block	1
lastsound			.block	1
cur_sndflags		.block	1		;$00
soundptr			.block	2
soundirqcount		.block	2
soundindex_com		.block	2
sys_soundflags		.block	1
soundindex			.block	1
csound_timer		.block	2		;$00
next_sndflags		.block	1		;$00
next_sndcnt		      .block	1		;$00
next_sndcmd		      .block	1		;$00
flag_tilt			.block	1
flag_gameover		.block	1
aud_totalballs		.block	1
flags_selftest		.block	1
num_players			.block	1
player_up			.block	1
pscore_buf			.block	2
num_eb			.block	1
vm_pc				.block	2		;$00EF
num_tilt			.block	1
minutetimer			.block	2
flag_timer_bip		.block	1
randomseed			.block	1
x_temp_1			.block	2		;$00
eb_x_temp			.block	2		;$00
credit_x_temp		.block	2		;$00
x_temp_2			.block	2

;***************************************************************
;* Spare RAM: The last 32 bytes are available to the GAME ROM
;*            if needed. Only the first 8 are defined by name.
;***************************************************************
spare_ram			.block	1
spare_ram+1			.block	1
spare_ram+2			.block	1
spare_ram+3			.block	1
spare_ram+4			.block	1
spare_ram+5			.block	1
spare_ram+6			.block	1
spare_ram+7			.block	1

;***************************************************************
;* CMOS RAM - The cmos RAM data bus is only 4-bits wide, so
;*            each byte of data takes two consecutive address
;*            locations. The lower address is the most 
;*            significant nibble in the byte.
;***************************************************************
	.org $0100

cmos_base
cmos_csum			.block	2

;* First section is game audits
aud_base
aud_leftcoins		.block	4	;0102-0105	"Coins, Left Chute"
aud_centercoins		.block	4	;0106-0109	"Coins, Center Chute"
aud_rightcoins		.block	4	;010A-010D	"Coins, Right Chute"
aud_paidcredits		.block	4	;010E-0111	Total Paid Credits
aud_specialcredits	.block	4	;0112-0115	Special Credits
aud_replaycredits		.block	4	;0116-0119	Replay Score Credits
aud_matchcredits		.block	4	;011A-011D	Match Credits
aud_totalcredits		.block	4	;011E-0121	Total Credits
aud_extraballs		.block	4	;0122-0125	Total Extra Balls
aud_avgballtime		.block	4	;0126-0129	Ball Time in Minutes
aud_totalballs		.block	4	;aud_totalballs-012D	Total Balls Played
aud_game1			.block	4	;012E-0131	Game Specific Audit#1
aud_game2			.block	4	;0132-0135	Game Specific Audit#2
aud_game3			.block	4	;0136-0139	Game Specific Audit#3
aud_game4			.block	4	;013A-013D	Game Specific Audit#4
aud_game5			.block	4	;013E-0141	Game Specific Audit#5
aud_game6			.block	4	;0142-0145	Game Specific Audit#6
aud_game7			.block	4	;0146-0149	Game Specific Audit#7
aud_autocycles		.block	4	;014A-014D	Number of Auto Cycles Completed
aud_hstdcredits		.block	2	;014E-014F	2 -HSTD Credits Awarded
aud_replay1times		.block	4	;0150-0153	2 -Times Exceeded
aud_replay2times		.block	4	;0154-0157	2 -Times Exceeded
aud_replay3times		.block	4	;0158-015B	2 -Times Exceeded
aud_replay4times		.block	4	;015C-015F	2 -Times Exceeded
				.block	2	;0160-0161	Unknown
cmos_bonusunits		.block	2	;0162-1063	Hold Over Bonus Coin Units
cmos_coinunits		.block	2	;0164-0165	Hold Over Total Coin Units
aud_reset_end					;Defines upper bound of RAM to clear on reset	
				
aud_currenthstd		.block	8	;0166-016D	Current HSTD
aud_currentcredits	.block	2	;016D-016F  Current Credits			
aud_command			.block	2	;0170-0171	Command Entry

				.block	11




;* Then adjustments
adj_base
adj_cmoscsum			.block	4	;017D-0180	"Game #, ROM Revision"                                     
adj_backuphstd			.block	2     ;0181-0182	Backup HSTD                                                
adj_replay1				.block	2     ;0183-0184	Replay 1 Score                                             
adj_replay2				.block	2     ;0185-0186	Replay 2 Score                                             
adj_replay3				.block	2     ;0187-0188	Replay 3 Score                                             
adj_replay4				.block	2     ;0189-018A	Replay 4 Score                                             
adj_matchenable			.block	2     ;018B-018C	Match: 00=On 01=OFF                                        
adj_specialaward			.block	2     ;018D-018E	Special:00=Awards Credit 01=Extra Ball 02=Awards Points    
adj_replayaward			.block	2     ;018F-0190	Replay Scores: 00=Awards Credit 01=Extra Ball              
adj_maxplumbbobtilts		.block	2     ;0191-0192	Max Plumb Bob Tilts                                        
adj_numberofballs			.block	2     ;0193-0194	Number of Balls (3 or 5)                                   
adj_gameadjust1			.block	2     ;0195-0196	Game Specific Adjustment#1                                 
adj_gameadjust2			.block	2     ;0197-0198	Game Specific Adjustment#2                                 
adj_gameadjust3			.block	2     ;0199-019A	Game Specific Adjustment#3                                 
adj_gameadjust4			.block	2     ;019B-019C	Game Specific Adjustment#4                                 
adj_gameadjust5			.block	2     ;019D-019E	Game Specific Adjustment#5                                 
adj_gameadjust6			.block	2     ;019F-01A0	Game Specific Adjustment#6                                 
adj_gameadjust7			.block	2     ;01A1-01A2	Game Specific Adjustment#7                                 
adj_gameadjust8			.block	2     ;01A3-01A4	Game Specific Adjustment#8                                 
adj_gameadjust9			.block	2     ;01A5-01A6	Game Specific Adjustment#9                                 
adj_hstdcredits			.block	2     ;01A7-01A8	High Score Credit Award                                    
adj_max_extraballs		.block	2     ;01A9-019A	Maximum Extra Balls 00=No Extra Balls                      
adj_max_credits			.block	2     ;01AB-01AC	Maximum Credits                                            
adj_pricecontrol			.block	2     ;01AD-01AE	Standard/Custom Pricing Control   

cmos_pricingbase                         
cmos_leftcoinmult			.block	2     ;01AF-01B0	Left Coin Slot Multiplier                                  
cmos_centercoinmult		.block	2     ;01B1-01B2	Center Coin Slot Multiplier    
cmos_rightcoinmult		.block	2     ;01B3-01B4	Right Coin Slot Multiplier     
cmos_coinsforcredit		.block	2     ;01B5-01B6	Coin Units Required for Credit 
cmos_bonuscoins			.block	2     ;01B7-01B8	Coin Units Bonus Point         
cmos_minimumcoins			.block	2     ;01B9-01BA	Minimum Coin Units             



;***************************************************************
;* Extended RAM area. This RAM space was added in Level 7 games
;* for extended flexibility. The HYPERBALL space is a little
;* different than regular Level 7 games in that the solenoid
;* space is only 8 bytes (instead of 16)
;***************************************************************
	.org $1100

switch_queue		.block	18
switch_queue_end

sol_queue			.block	16
sol_queue_end

score_queue			.block	8
score_queue_end

	.org $1130
exe_buffer			.block	16		;Temp code buffer for exe macro

;define the size of each player data block first
_gamedata_size		.equ		$24
;then apply it to all players
p1_gamedata			.block	_gamedata_size
p2_gamedata			.block	_gamedata_size

threadpool_base		.block	$13ff-$

;***************************************************************
;* PIA Input/Output hardware
;***************************************************************
;* Some equates for indexing
pia_pir			.equ		0
pia_control			.equ		1
pia_pir_a			.equ		0
pia_control_a		.equ		1
pia_pir_b			.equ		2
pia_control_b		.equ		3

pia_sound_data		.equ		$2100
pia_sound_ctrl		.equ		$2101
pia_comma_data		.equ		$2102
pia_comma_ctrl		.equ		$2103

pia_sol_low_data		.equ		$2200
pia_sol_low_ctrl		.equ		$2201
pia_sol_high_data		.equ		$2202
pia_sol_high_ctrl		.equ		$2203

pia_lamp_row_data		.equ		$2400
pia_lamp_row_ctrl		.equ		$2401
pia_lamp_col_data		.equ		$2402
pia_lamp_col_ctrl		.equ		$2403

pia_disp_digit_data	.equ		$2800
pia_disp_digit_ctrl	.equ		$2801
pia_disp_seg_data		.equ		$2802
pia_disp_seg_ctrl		.equ		$2803

pia_switch_return_data	.equ		$3000
pia_switch_return_ctrl	.equ		$3001
pia_switch_strobe_data	.equ		$3002
pia_switch_strobe_ctrl	.equ		$3003

;*******************************************
;* Special PIA for Hyperball Driver Boards *
;* Controls the Alpha-Numeric Display      *
;*******************************************
pia_alphanum_digit_data	.equ		$4000
pia_alphanum_digit_ctrl	.equ		$4001
pia_alphanum_seg_data	.equ		$4002
pia_alphanum_seg_ctrl	.equ		$4003









;*****************************************************************************
;* Some Global Equates
;*****************************************************************************



 	.org $d000
;---------------------------------------------------------------------------
;  Default game data and basic system tables start at $D000, these can not  
;  ever be moved
;---------------------------------------------------------------------------

gr_gamenumber		.dw $2503
gr_romrevision		.db $F4   

gr_defaudit 
gr_cmoscsum			.db $B2,$A5 
gr_backuphstd		.db $05
gr_replay1			.db $00
gr_replay2			.db $00
gr_replay3			.db $00
gr_replay4			.db $00   

gr_matchenable		.db $01
gr_specialaward		.db $01
gr_replayaward		.db $00
gr_maxplumbbobtilts	.db $03
gr_numberofballs		.db $02
gr_gameadjust1		.db $03
gr_gameadjust2		.db $05
gr_gameadjust3		.db $04
gr_gameadjust4		.db $12
gr_gameadjust5		.db $05
gr_gameadjust6		.db $05
gr_gameadjust7		.db $05
gr_gameadjust8		.db $00
gr_gameadjust9		.db $00
gr_hstdcredits		.db $00
gr_max_extraballs		.db $00
gr_max_credits		.db $30
    

;---------------
;Pricing Data  |
;---------------

gr_pricingdata		.db $01	;Left Coin Mult
				.db $04	;Center Coin Mult
				.db $01	;Right Coin Mult
				.db $01	;Coin Units Required
				.db $00	;Bonus Coins
				.db $00	;Minimum Coin Units

				.db $09	;Left Coin Mult
				.db $45	;Center Coin Mult
				.db $18	;Right Coin Mult
				.db $05	;Coin Units Required
				.db $45	;Bonus Coins
				.db $00	;Minimum Coin Units

				.db $01	;Left Coin Mult
				.db $04	;Center Coin Mult
				.db $01	;Right Coin Mult
				.db $02	;Coin Units Required
				.db $04	;Bonus Coins
				.db $00	;Minimum Coin Units

				.db $01	;Left Coin Mult
				.db $16	;Center Coin Mult
				.db $06	;Right Coin Mult
				.db $02	;Coin Units Required
				.db $00	;Bonus Coins
				.db $00	;Minimum Coin Units

				.db $03	;Left Coin Mult
				.db $15	;Center Coin Mult
				.db $03	;Right Coin Mult
				.db $04	;Coin Units Required
				.db $15	;Bonus Coins
				.db $00	;Minimum Coin Units

				.db $01	;Left Coin Mult
				.db $00	;Center Coin Mult
				.db $04	;Right Coin Mult
				.db $01	;Coin Units Required
				.db $00	;Bonus Coins
				.db $00	;Minimum Coin Units

				.db $01	;Left Coin Mult
				.db $00	;Center Coin Mult
				.db $02	;Right Coin Mult
				.db $01	;Coin Units Required
				.db $00	;Bonus Coins
				.db $00	;Minimum Coin Units

				.db $01	;Left Coin Mult
				.db $00	;Center Coin Mult
				.db $02	;Right Coin Mult
				.db $02	;Coin Units Required
				.db $00	;Bonus Coins
				.db $00	;Minimum Coin Units
    
;--------------
;System Data  |
;--------------

gr_maxthreads		.db $1C
gr_extendedromtest	.db $03
gr_lastswitch		.db (switchtable_end-switchtable)/3
gr_numplayers		.db $01
gr_lamptable_ptr		.dw lamptable		;D04F
gr_switchtable_ptr	.dw switchtable
gr_soundtable_ptr		.dw soundtable
gr_lampflashrate		.db $05
     
D056: 0D       
D057: 03       
D058: 03       
D059: 1A       
D05A: 11       
D05B: gr_gameoversound		.db $1A       
D05C: gr_creditsound		.db $00		;credit sound       
D05D: gr_gameover_lamp		.db $5F		;Game Over Lamp Location      
D05E: gr_tilt_lamp		.db $5F       
D05F: gr_gameoverthread_ptr	.dw $DEA7	 	;Game Over Init Thread 
D061: character_defs		.dw $E4CB       
D063: gr_coinlockout		.db $05		;Coin Lockout Solenoid    
D064: gr_highscoresound		.dw $E189 
    
D066: 00       
D067: 02       
D068: 00       
D069: 09       
D06A: 00       
D06B: 04       
D06C: 00       
D06D: 01       
D06E: 02       
D06F: 05       
D070: 08       
D071: 05       
D072: 00       
D073: 00 

gr_playerstartdata    
  
		.db $00,$00,$00,$00  
		.db $00,$00,$00,$00     
		.db $00,$00,$00,$00     
		.db $00,$00,$00,$00      
		.db $00,$00,$00,$00
		.db $00,$00,$00,$00
		.db $00,$00,$00,$00
		.db $00,$00   
      
gr_playerresetdata
D092: 00
D093: 00       
D094: 00       
D095: 00       
D096: 00       
D097: 00       
D098: 00       
D099: 00       
D09A: 00       
D09B: 00       
D09C: FF 03 00 
D09F: 00       
D0A0: 00       
D0A1: 00       
D0A2: 00       
D0A3: 00       
D0A4: 00       
D0A5: 00       
D0A6: 00       
D0A7: 00       
D0A8: 00       
D0A9: 00       
D0AA: 00       
D0AB: 00       
D0AC: 00       
D0AD: 00       
D0AE: 00       
D0AF: 00       
D0B0: 39 00
D0B2: 39 DD

gr_score_event		rts .db 0
gr_eb_event			rts .db 0
gr_special_event		bra	gr_special   
gr_macro_event		rts .db 0	;Main Loop Begin Hook - rts
gr_ballstart_event	rts .db 0
gr_addplayer_event 	rts .db 0
gr_gameover_event		rts .db 0
D0C2: 			rts .db 0

;********************************************************
;* System Hooks:
;* These are pointers to code blocks that can be run at
;* certain times within the system. This allows the game
;* to expand upon the system quite a bit in it's functionality.
;* All hooks are pointers to code entry points. You cannot
;* run code here like the event entry points above. If you
;* want to return, then you have to point to an 'rts'  
;* opcode somewhere else, like the sacrificial rts above.
;* You should leave these alone at first until you start
;* getting more complex game rules that need to take 
;* advantage of this flexibility.
;********************************************************
;this should be @$DOC4 for Hyperball, if it isn't, something is wrong
gr_reset_hook_ptr			.dw $D108 
gr_main_hook_ptr			.dw $D0BA
gr_coin_hook_ptr			.dw $E172
gr_game_hook_ptr			.dw $D120 
gr_player_hook_ptr		.dw $D3B0
gr_outhole_hook_ptr		.dw $D1FF 

;*** Game IRQ Entry ***
gr_irq_entry
	jmp   sys_irq_entry


;*** Game SWI Entry ***
gr_swi_entry
D0D3: 0E          CLI   
D0D4: 31          INS   
D0D5: 31          INS   
D0D6: 31          INS   
D0D7: 31          INS   
D0D8: 31          INS   
D0D9: 7E F4 32    jmp   $F432		Begin Macro's

gr_special
D0DC: CE 01 99    ldx   #0199
D0DF: BD EE A2    jsr   cmosinc_b		 ( CMOS,X++ -> B)
D0E2: 27 DE       beq   $D0C2
D0E4: DE FA       ldx   credit_x_temp
D0E6: 09          DEX   
D0E7: 09          DEX   
D0E8: BD FD DB    jsr   cmos_a		 ( CMOS, X -> A )
D0EB: 1B          ABA   
D0EC: 19          DAA   
D0ED: 8D 4C       bsr   $D13B
D0EF: 86 12       ldaa   #12
D0F1: BD EC 3B    jsr   isnd_once
D0F4: C6 01       ldab   #01
D0F6: BD D9 CB    jsr   $D9CB
D0F9: CE 00 5E    ldx   cred_b0
D0FC: 96 EB       ldaa   player_up
D0FE: 27 03       beq   $D103
D100: CE 00 5C    ldx   mbip_b0
D103: 86 01       ldaa   #01
D105: 7E D1 CC    jmp   $D1CC

Game Reset Hook:
D108: BD EE DC    jsr   $EEDC	 Restore Backup High Score
D10B: CE 01 2E    ldx   #012E
D10E: DF B8       stx   temp1
D110: CE E5 D0    ldx   #E5D0
D113: E6 00       ldab   $00,X
D115: C4 0F       andb  #0F
D117: 08          inx   
D118: 7E EF 23    jmp   copyblock2

D11B: 8D EB       bsr   $D108
D11D: 7E E9 C4    jmp   $E9C4	Remove Current Thread from Control Stack

D120: CE 13 A0    ldx   #13A0
D123: 6F 00       CLR   $00,X
D125: 08          inx   
D126: 8C 13 A7    CMPX  #13
D129: 26 F8       bne   $D123
D12B: CE 01 99    ldx   #0199
D12E: 86 F3       ldaa   #F3
D130: BD EA 83    jsr   solbuf
D133: BD D1 B9    jsr   $D1B9
D136: CE 01 46    ldx   #0146
D139: 8D 00       bsr   $D13B
D13B: 7E EE EE    jmp   a_cmosinc

D13E: 4F          clra  
D13F: 4C          inca  
D140: D6 E7       ldab   flag_gameover
D142: 27 2E       beq   $D172
D144: B7 13 9E    staa   $139E
D147: 16          tab   
D148: CE 01 AB    ldx   #01AB
D14B: 8D 6C       bsr   $D1B9
D14D: 27 08       beq   $D157
D14F: CE 01 6E    ldx   #016E
D152: 8D 65       bsr   $D1B9
D154: 11          CBA   
D155: 25 C6       bcs   $D11D
D157: 86 08       ldaa   #08
D159: CE FB A5    ldx   #FBA5
D15C: BD D5 0E    jsr   $D50E
D15F: 5A          decb  
D160: 26 F5       bne   $D157
D162: CE 03 03    ldx   #0303
D165: FF 13 9A    stx   $139A
D168: 8D 5A       bsr   $D1C4
D16A: 27 B1       beq   $D11D
D16C: 3F          SWI   
D16D: 52          --------------------
D16E: 48          ASLA  
D16F: 75          --------------------
D170: 8F          --------------------
D171: FD          --------------------
D172: B1 13 9E    cmpa  $139E
D175: 26 A6       bne   $D11D
D177: 86 48       ldaa   #48
D179: C6 FF       ldab   #FF
D17B: BD EA 60    jsr   check_threadid
D17E: 25 69       bcs   $D1E9
D180: BD D1 FA    jsr   $D1FA
D183: F6 13 9E    ldab   $139E
D186: CE 01 AB    ldx   #01AB
D189: 8D 2E       bsr   $D1B9
D18B: 27 06       beq   $D193
D18D: B6 11 9A    ldaa   current_credits
D190: 11          CBA   
D191: 25 56       bcs   $D1E9
D193: C1 02       CMPB  #02
D195: 26 10       bne   $D1A7
D197: 8D 23       bsr   $D1BC
D199: F6 13 9B    ldab   $139B
D19C: 36          psha  
D19D: 1B          ABA   
D19E: B7 13 9B    staa   $139B
D1A1: 32          pula  
D1A2: CE 00 5C    ldx   mbip_b0
D1A5: 8D 25       bsr   $D1CC
D1A7: 8D 13       bsr   $D1BC
D1A9: F6 13 9A    ldab   $139A
D1AC: 36          psha  
D1AD: 1B          ABA   
D1AE: B7 13 9A    staa   $139A
D1B1: 32          pula  
D1B2: CE 00 5E    ldx   cred_b0
D1B5: 8D 15       bsr   $D1CC
D1B7: 20 30       bra   $D1E9

D1B9: 7E FD DB    jmp   cmos_a

D1BC: CE 01 6E    ldx   #016E
D1BF: 8D F8       bsr   $D1B9
D1C1: BD FB DF    jsr   $FBDF
D1C4: CE 01 95    ldx   #0195
D1C7: 8D F0       bsr   $D1B9
D1C9: 84 0F       anda  #0F
D1CB: 39          rts   

D1CC: E6 00       ldab   $00,X
D1CE: 2A 02       BPL   $D1D2
D1D0: C4 0F       andb  #0F
D1D2: 1B          ABA   
D1D3: 19          DAA   
D1D4: 81 09       cmpa  #09
D1D6: 2E 02       BGT   $D1DA
D1D8: 8A F0       oraa   #F0
D1DA: A7 00       staa   $00,X
D1DC: 39          rts   

D1DD: CE 00 66    ldx   #0066
D1E0: FF 11 8E    stx   $118E
D1E3: CE E5 5F    ldx   #msg_game
D1E6: BD D2 49    jsr   $D249
D1E9: 7E E9 C4    jmp   $E9C4	Remove Current Thread from Control Stack

D1EC: CE 00 65    ldx   #0065
D1EF: FF 11 92    stx   $1192
D1F2: CE E5 65    ldx   #msg_over
D1F5: BD D2 58    jsr   $D258
D1F8: 20 EF       bra   $D1E9

D1FA: C6 FF       ldab   #FF
D1FC: 7E EA 5B    jmp   kill_threads

D1FF: 86 78       ldaa   #78
D201: 8D F7       bsr   $D1FA
D203: 96 E8       ldaa   random_bool
D205: 26 05       bne   $D20C
D207: 86 29       ldaa   #29
D209: BD EB 3D    jsr   $EB3D
D20C: 7C 00 E6    INC   flag_tilt
D20F: D6 5E       ldab   cred_b0
D211: 96 EB       ldaa   player_up
D213: 27 02       beq   $D217
D215: D6 5C       ldab   mbip_b0
D217: C1 F0       CMPB  #F0
D219: 26 2B       bne   $D246
D21B: CE E5 58    ldx   #msg_player
D21E: BD D3 0B    jsr   $D30B
D221: 8B 1C       ADDA  #1C
D223: DE B8       ldx   temp1
D225: A7 02       staa   $02,X
D227: 96 EA       ldaa   num_players
D229: 27 04       beq   $D22F
D22B: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
D22E: 60 

D22F: CE D1 DD    ldx	#D1DD
D232: BD EA 24    jsr   newthread_06	 Push Control Stack: Data in A,B,X,$A6,$A7,$AA=#06
D235: CE D1 EC    ldx   #D1EC
D238: BD EA 24    jsr   newthread_06	 Push Control Stack: Data in A,B,X,$A6,$A7,$AA=#06
D23B: 8D 09       bsr   $D246
D23D: 86 09       ldaa   #09
D23F: BD EC 3B    jsr   isnd_once
D242: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
D245: F0 

D246: 7E D2 D6	  jmp 	$D2D6   
D249: A6 00       ldaa   $00,X
D24B: 84 0F       anda  #0F
D24D: BD EE 3E    jsr   xplusa	 ( X = X + A)
D250: E6 00       ldab   $00,X
D252: 09          DEX   
D253: 8D 21       bsr   $D276
D255: 26 F9       bne   $D250
D257: 39          rts   

D258: A6 00       ldaa   $00,X
D25A: 84 0F       anda  #0F
D25C: 08          inx   
D25D: E6 00       ldab   $00,X
D25F: 8D 2A       bsr   $D28B
D261: 26 F9       bne   $D25C
D263: 39          rts   

D264: 8D 55       bsr   $D2BB
D266: 8D E1       bsr   $D249
D268: 5F          clrb  
D269: 86 01       ldaa   #01
D26B: 20 E6       bra   $D253

D26D: 8D 41       bsr   $D2B0
D26F: 8D E7       bsr   $D258
D271: 5F          clrb  
D272: 86 01       ldaa   #01
D274: 20 E9       bra   $D25F

D276: 36          psha  
D277: 37          PSHB  
D278: FF 11 8C    stx   $118C
D27B: CE 00 60    ldx   #0060
D27E: 17          TBA   
D27F: E6 00       ldab   $00,X
D281: A7 00       staa   $00,X
D283: 08          inx   
D284: BC 11 8E    CPX   $118E
D287: 26 F5       bne   $D27E
D289: 20 13       bra   $D29E

D28B: 36          psha  
D28C: 37          PSHB  
D28D: FF 11 8C    stx   $118C
D290: CE 00 6B    ldx   #006B
D293: 17          TBA   
D294: E6 00       ldab   $00,X
D296: A7 00       staa   $00,X
D298: 09          DEX   
D299: BC 11 92    CPX   $1192
D29C: 26 F5       bne   $D293
D29E: FE 11 8C    ldx   $118C
D2A1: 33          PULB  
D2A2: 96 0A       ldaa   $000A
D2A4: 26 02       bne   $D2A8
D2A6: 86 09       ldaa   #09
D2A8: 97 D5       staa   thread_timer_byte
D2AA: 32          pula  
D2AB: BD E9 71    jsr   delaythread
D2AE: 4A          deca  
D2AF: 39          rts   

D2B0: FF 11 90    stx   $1190
D2B3: CE 00 5F    ldx   #005F
D2B6: FF 11 92    stx   $1192
D2B9: 20 09       bra   $D2C4

D2BB: FF 11 90    stx   $1190
D2BE: CE 00 6C    ldx   #006C
D2C1: FF 11 8E    stx   $118E
D2C4: FE 11 90    ldx   $1190
D2C7: 39          rts   

D2C8: 8D E6       bsr   $D2B0
D2CA: 8D BF       bsr   $D28B
D2CC: 26 FC       bne   $D2CA
D2CE: 39          rts   

D2CF: 8D EA       bsr   $D2BB
D2D1: 8D A3       bsr   $D276
D2D3: 26 FC       bne   $D2D1
D2D5: 39          rts   

D2D6: 36          psha  
D2D7: 37          PSHB  
D2D8: DF C2       stx   sys_temp5
D2DA: CE 00 60    ldx   #0060
D2DD: DF B8       stx   temp1
D2DF: 8D 73       bsr   $D354
D2E1: DE C2       ldx   sys_temp5
D2E3: E6 00       ldab   $00,X
D2E5: DE B8       ldx   temp1
D2E7: BD EC 32    jsr   split_ab
D2EA: F7 11 88    stab   $1188
D2ED: BD EE 8C    jsr   xplusb
D2F0: DF B8       stx   temp1
D2F2: DE C2       ldx   sys_temp5
D2F4: 33          PULB  
D2F5: 32          pula  
D2F6: 39          rts   

D2F7: 36          psha  
D2F8: 37          PSHB  
D2F9: 86 26       ldaa   #26
D2FB: 5A          decb  
D2FC: 27 F6       beq   $D2F4
D2FE: A7 00       staa   $00,X
D300: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
D303: 02   

D304: 4C          inca  
D305: 81 2A       cmpa  #2A
D307: 27 F0       beq   $D2F9
D309: 20 F3       bra   $D2FE

D30B: 8D C9       bsr   $D2D6
D30D: E6 00       ldab   $00,X
D30F: C4 0F       andb  #0F
D311: 08          inx   
D312: 7E EE FB    jmp   $EEFB

D315: 8D BF       bsr   $D2D6
D317: A6 00       ldaa   $00,X
D319: 84 0F       anda  #0F
D31B: C6 0B       ldab   #0B
D31D: 36          psha  
D31E: 08          inx   
D31F: FF 11 8A    stx   $118A
D322: A6 00       ldaa   $00,X
D324: 97 6B       staa   $006B
D326: CE 00 6A    ldx   #006A
D329: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
D32C: 04 

D32D: A6 01       ldaa   $01,X
D32F: A7 00       staa   $00,X
D331: 4F          clra  
D332: A7 01       staa   $01,X
D334: 09          DEX   
D335: 5A          decb  
D336: F1 11 88    CMPB  $1188
D339: 26 EE       bne   $D329
D33B: FE 11 8A    ldx   $118A
D33E: 7C 11 88    INC   $1188
D341: 32          pula  
D342: 4A          deca  
D343: 26 D6       bne   $D31B
D345: 39          rts   

D346: BD EA F8    jsr   $EAF8
D349: 5F          clrb  
D34A: 20 02       bra   $D34E

D34C: C6 7F       ldab   #7F
D34E: BD D8 58    jsr   $D858
D351: CE 00 6C    ldx   #006C
D354: 4F          clra  
D355: C6 0C       ldab   #0C
D357: 7E F8 A9    jmp   write_range

D35A: 5A          decb  
D35B: FE F2 FF    ldx   $F2FF
D35E: C0 10       subb  #10
D360: 48          ASLA  
D361: CE D3 71    ldx   #D371
D364: BD EA 24    jsr   newthread_06	 Push Control Stack: Data in A,B,X,$A6,$A7,$AA=#06
D367: F5 57 FB    BITB  $57FB
D36A: FD          --------------------
D36B: 5A          decb  
D36C: F0 09 31    subb  $0931
D36F: 46          RORA  
D370: 03          --------------------
D371: 3F          SWI   
D372: 52          --------------------
D373: C0 53       subb  #53
D375: 18          --------------------
D376: 03          --------------------
D377: 31          INS   
D378: F6 52 A0    ldab   $52A0
D37B: 55          --------------------
D37C: 08          inx   
D37D: 00          --------------------
D37E: 93          --------------------
D37F: 8A 04       oraa   #04
D381: CE E5 F4    ldx   #E5F4
D384: 8D 85       bsr   $D30B
D386: 8D C4       bsr   $D34C
D388: 86 31       ldaa   #31
D38A: BD D8 53    jsr   $D853
D38D: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
D390: 06      

D391: 4A          deca  
D392: 26 F6       bne   $D38A
D394: CE 00 00    ldx   #0000
D397: FF 11 98    stx   $1198
D39A: 3F          SWI   
D39B: AF 39       STS   $39,X
D39D: A4 B9       anda  $B9,X
D39F: 51          --------------------
D3A0: 60 34       NEG   $34,X
D3A2: 06          TAP   
D3A3: 01          NOP   
D3A4: 02          --------------------
D3A5: 07          TPA   
D3A6: 52          --------------------
D3A7: 00          --------------------
D3A8: A5 DD       BITA  $DD,X
D3AA: 57          ASRB  
D3AB: EA F8       ORB   $F8,X
D3AD: 5C          incb  
D3AE: FA 43 7C    ORB   $437C
D3B1: 00          --------------------
D3B2: E6 CE       ldab   $CE,X
D3B4: E5 58       BITB  $58,X
D3B6: BD D3 0B    jsr   $D30B
D3B9: DE CF       ldx   current_thread
D3BB: E7 0D       stab   $0D,X
D3BD: 96 EB       ldaa   player_up
D3BF: 8B 1C       ADDA  #1C
D3C1: DE B8       ldx   temp1
D3C3: A7 02       staa   $02,X
D3C5: BD D3 4C    jsr   $D34C
D3C8: BD DF 11    jsr   $DF11
D3CB: CE E3 34    ldx   #E334
D3CE: BD D5 0D    jsr   $D50D
D3D1: 8D 20       bsr   $D3F3
D3D3: 7F 13 9D    CLR   $139D
D3D6: 3F          SWI   
D3D7: 5B          --------------------
D3D8: FC          --------------------
D3D9: E6 00       ldab   $00,X
D3DB: 06          TAP   
D3DC: C2 00       SBCB  #00
D3DE: C6 05       ldab   #05
D3E0: 18          --------------------
D3E1: 0A          CLV   
D3E2: 19          DAA   
D3E3: 4F          clra  
D3E4: 29 40       BVS   $D426
D3E6: B0 0B 5A    SUBA  $0B5A
D3E9: FC          --------------------
D3EA: E1 00       CMPB  $00,X
D3EC: 12          --------------------
D3ED: A5 FF       BITA  $FF,X
D3EF: B1 FF 8F    cmpa  $FF8F
D3F2: F5 D6 EB    BITB  $D6EB
D3F5: 17          TBA   
D3F6: CE 13 9A    ldx   #139A
D3F9: BD EE 8C    jsr   xplusb
D3FC: E6 00       ldab   $00,X
D3FE: 39          rts   

D3FF: B0 43 31    SUBA  $4331
D402: 06          TAP   
D403: 17          TBA   
D404: 00          --------------------
D405: C1 10       CMPB  #10
D407: E7 7A       stab   $7A,X
D409: B1 FF 5B    cmpa  $FF5B
D40C: FC          --------------------
D40D: E1 00       CMPB  $00,X
D40F: F7 14 00    stab   $1400
D412: D9 30       ADCB  $0030
D414: AE C0       LDS   $C0,X
D416: 31          INS   
D417: F9 53 40    ADCB  $5340
D41A: 55          --------------------
D41B: FF 48 04    stx   $4804
D41E: 4F          clra  
D41F: 97 E6       staa   flag_tilt
D421: 97 0A       staa   $000A
D423: CE 01 97    ldx   #0197
D426: BD EE A2    jsr   cmosinc_b		 ( CMOS,X++ -> B)
D429: 86 11       ldaa   #11
D42B: C4 0F       andb  #0F
D42D: 27 0A       beq   $D439
D42F: 4A          deca  
D430: 5A          decb  
D431: 26 FC       bne   $D42F
D433: 81 04       cmpa  #04
D435: 2E 02       BGT   $D439
D437: 86 04       ldaa   #04
D439: 97 0C       staa   $000C
D43B: 96 05       ldaa   $0005
D43D: D6 03       ldab   $0003
D43F: 26 32       bne   $D473
D441: 8B 01       ADDA  #01
D443: 19          DAA   
D444: 97 05       staa   $0005
D446: 36          psha  
D447: C6 0F       ldab   #0F
D449: D7 07       stab   $0007
D44B: C6 04       ldab   #04
D44D: CE 01 9F    ldx   #019F
D450: BD EE 92    jsr   cmosinc_a		 ( CMOS,X++ -> A)
D453: 84 0F       anda  #0F
D455: 27 0A       beq   $D461
D457: 7A 00 07    DEC   $0007
D45A: D1 07       CMPB  $0007
D45C: 27 03       beq   $D461
D45E: 4A          deca  
D45F: 26 F6       bne   $D457
D461: D6 05       ldab   $0005
D463: BD F8 9D    jsr   $F89D
D466: 96 07       ldaa   $0007
D468: 81 04       cmpa  #04
D46A: 27 04       beq   $D470
D46C: 4A          deca  
D46D: 5A          decb  
D46E: 26 F8       bne   $D468
D470: 97 07       staa   $0007
D472: 32          pula  
D473: 5F          clrb  
D474: 36          psha  
D475: 96 0C       ldaa   $000C
D477: 4A          deca  
D478: 81 03       cmpa  #03
D47A: 2D 02       BLT   $D47E
D47C: 97 0C       staa   $000C
D47E: 32          pula  
D47F: 8B 99       ADDA  #99
D481: 19          DAA   
D482: 27 07       beq   $D48B
D484: 5C          incb  
D485: C1 05       CMPB  #05
D487: 27 EA       beq   $D473
D489: 20 F4       bra   $D47F

D48B: 96 05       ldaa   $0005
D48D: C1 04       CMPB  #04
D48F: 27 70       beq   $D501
D491: 7D 00 03    TST   $0003
D494: 26 0E       bne   $D4A4
D496: CE E4 A2    ldx   #E4A2
D499: BD D3 F9    jsr   $D3F9
D49C: 81 09       cmpa  #09
D49E: 2D 02       BLT   $D4A2
D4A0: C6 20       ldab   #20
D4A2: D7 03       stab   $0003
D4A4: 96 04       ldaa   $0004
D4A6: 26 04       bne   $D4AC
D4A8: 86 14       ldaa   #14
D4AA: 97 04       staa   $0004
D4AC: CE 01 9B    ldx   #019B
D4AF: BD EE A2    jsr   cmosinc_b		 ( CMOS,X++ -> B)
D4B2: C1 20       CMPB  #20
D4B4: 2F 02       BLE   $D4B8
D4B6: C6 20       ldab   #20
D4B8: BD F8 9D    jsr   $F89D
D4BB: 17          TBA   
D4BC: D6 05       ldab   $0005
D4BE: BD F8 9D    jsr   $F89D
D4C1: C1 01       CMPB  #01
D4C3: 27 01       beq   $D4C6
D4C5: 58          ASLB  
D4C6: 10          SBA   
D4C7: 25 04       bcs   $D4CD
D4C9: 81 06       cmpa  #06
D4CB: 2C 02       BGE   $D4CF
D4CD: 86 06       ldaa   #06
D4CF: 97 09       staa   $0009
D4D1: CE D5 13    ldx   #D513
D4D4: 8D 29       bsr   $D4FF
D4D6: CE DD 87    ldx   #DD87
D4D9: 8D 24       bsr   $D4FF
D4DB: BD FB 94    jsr   $FB94
D4DE: C6 06       ldab   #06
D4E0: 81 25       cmpa  #25
D4E2: 22 0C       BHI   $D4F0
D4E4: C6 04       ldab   #04
D4E6: CE DA AE    ldx   #DAAE
D4E9: 8D 14       bsr   $D4FF
D4EB: CE DA 86    ldx   #DA86
D4EE: 8D 0F       bsr   $D4FF
D4F0: D7 08       stab   $0008
D4F2: CE D8 85    ldx   #D885
D4F5: 8D 08       bsr   $D4FF
D4F7: CE D5 AA    ldx   #D5AA
D4FA: 8D 03       bsr   $D4FF
D4FC: CE DB E5    ldx   #DBE5
D4FF: 20 0C       bra   $D50D

D501: 86 2E       ldaa   #2E
D503: BD F1 FD    jsr   $F1FD
D506: 86 10       ldaa   #10
D508: 97 0F       staa   $000F
D50A: CE DF F0    ldx   #DFF0
D50D: 4F          clra  
D50E: 97 C8       staa   thread_priority
D510: 7E E9 D8    jmp   newthread_sp	Push Control Stack: Data in A,B,X,$AA,$A6,$A7

D513: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
D516: 03   

D517: 96 08       ldaa   $0008
D519: 27 F8       beq   $D513
D51B: CE D9 F1    ldx   #D9F1
D51E: 8D ED       bsr   $D50D
D520: CE 01 9D    ldx   #019D
D523: BD EE 92    jsr   cmosinc_a		 ( CMOS,X++ -> A)
D526: 84 0F       anda  #0F
D528: D6 05       ldab   $0005
D52A: C1 09       CMPB  #09
D52C: 2F 02       BLE   $D530
D52E: C6 09       ldab   #09
D530: 10          SBA   
D531: 24 01       bcc   $D534
D533: 4F          clra  
D534: 8B 0B       ADDA  #0B
D536: D6 09       ldab   $0009
D538: C1 0C       CMPB  #0C
D53A: 2F 01       BLE   $D53D
D53C: 54          LSRB  
D53D: D7 D5       stab   thread_timer_byte
D53F: BD E9 71    jsr   delaythread
D542: 4A          deca  
D543: 26 F1       bne   $D536
D545: 20 D0       bra   $D517

D547: 52          --------------------
D548: B0 5B FB    SUBA  $5BFB
D54B: D0 30       subb  $0030
D54D: FE F2 F0    ldx   $F2F0
D550: F2 F0 09    SBCB  $F009
D553: 5A          decb  
D554: FE F2 F0    ldx   $F2F0
D557: B0 0A 71    SUBA  $0A71
D55A: 8F          --------------------
D55B: ED          --------------------
D55C: 52          --------------------
D55D: F0 E4 57    subb  $E457
D560: FE CC 7B    ldx   $CC7B
D563: 03          --------------------
D564: 3F          SWI   
D565: 74 5A FE    LSR   $5AFE
D568: F2 F0 A0    SBCB  $F0A0
D56B: F9 52 A1    ADCB  $52A1
D56E: AD D6       jsr   $D6,X
D570: AD 64       jsr   $64,X
D572: 48          ASLA  
D573: CE E5 6B    ldx   #E56B
D576: BD D3 0B    jsr   $D30B
D579: C0 14       subb  #14
D57B: A2 D6       SBCA  $D6,X
D57D: F1 31 F6    CMPB  $31F6
D580: 78 31 06    ASL   $3106
D583: 78 B0 FF    ASL   $B0FF
D586: 5B          --------------------
D587: FC          --------------------
D588: E0 00       subb  $00,X
D58A: F0 F8 C1    subb  $F8C1
D58D: 00          --------------------
D58E: A2 C8       SBCA  $C8,X
D590: 03          --------------------
D591: 71          --------------------
D592: 5B          --------------------
D593: F6 4E 02    ldab   $4E02
D596: 19          DAA   
D597: 4E          --------------------
D598: A0 5B       SUBA  $5B,X
D59A: 5A          decb  
D59B: FD          --------------------
D59C: E0 0D       subb  $0D,X
D59E: F2 51 10    SBCB  $5110
D5A1: B1 3A 5A    cmpa  $3A5A
D5A4: D0 E1       subb  $00E1
D5A6: EA DC       ORB   $DC,X
D5A8: 01          NOP   
D5A9: 02          --------------------
D5AA: 8D 49       bsr   $D5F5
D5AC: 26 01       bne   $D5AF
D5AE: 4C          inca  
D5AF: 3F          SWI   
D5B0: 52          --------------------
D5B1: 00          --------------------
D5B2: 53          COMB  
D5B3: 70 B0 FF    NEG   $B0FF
D5B6: 5B          --------------------
D5B7: FC          --------------------
D5B8: E0 00       subb  $00,X
D5BA: F7 7A 5A    stab   $7A5A
D5BD: FE F2 F0    ldx   $F2F0
D5C0: A0 F9       SUBA  $F9,X
D5C2: 52          --------------------
D5C3: A6 9F       ldaa   $9F,X
D5C5: CB 45       ADDB  #45
D5C7: B7 11 9B    staa   $119B
D5CA: 5B          --------------------
D5CB: FD          --------------------
D5CC: E0 0B       subb  $0B,X
D5CE: 2B 5A       BMI   $D62A
D5D0: FC          --------------------
D5D1: E0 0D       subb  $0D,X
D5D3: 0A          CLV   
D5D4: 5A          decb  
D5D5: F4 3C EC    andb  $3CEC
D5D8: 13          --------------------
D5D9: BA BB 3C    oraa   $BB3C
D5DC: 80 24       SUBA  #24
D5DE: 5A          decb  
D5DF: F4 45 E2    andb  $45E2
D5E2: 13          --------------------
D5E3: C3          --------------------
D5E4: C4 45       andb  #45
D5E6: 80 1A       SUBA  #1A
D5E8: 7E FB 94    jmp   $FB94

D5EB: 8D FB       bsr   $D5E8
D5ED: 84 03       anda  #03
D5EF: 39          rts   

D5F0: 8D F6       bsr   $D5E8
D5F2: 84 07       anda  #07
D5F4: 39          rts   

D5F5: 8D F1       bsr   $D5E8
D5F7: 84 0F       anda  #0F
D5F9: 39          rts   

D5FA: A0 C3       SUBA  $C3,X
D5FC: 5A          decb  
D5FD: F4 E0 C4    andb  $E0C4
D600: 17          TBA   
D601: 00          --------------------
D602: CA 04       ORB   #04
D604: 04          --------------------
D605: CE E5 AC    ldx   #msg_hit
D608: BD D2 6D    jsr   $D26D
D60B: F6 11 9B    ldab   $119B
D60E: CE E4 94    ldx   #E494
D611: BD EE 8C    jsr   xplusb
D614: E6 00       ldab   $00,X
D616: BD D2 72    jsr   $D272
D619: C6 26       ldab   #26
D61B: BD D2 72    jsr   $D272
D61E: CE 13 A7    ldx   #13A7
D621: 8D C8       bsr   $D5EB
D623: 27 01       beq   $D626
D625: 4A          deca  
D626: B7 13 9F    staa   $139F
D629: 26 07       bne   $D632
D62B: 96 04       ldaa   $0004
D62D: BD DF D2    jsr   $DFD2
D630: 20 1C       bra   $D64E

D632: 6F 01       CLR   $01,X
D634: C6 1C       ldab   #1C
D636: E7 02       stab   $02,X
D638: C6 26       ldab   #26
D63A: E7 03       stab   $03,X
D63C: 81 02       cmpa  #02
D63E: 27 06       beq   $D646
D640: 86 5A       ldaa   #5A
D642: C6 42       ldab   #42
D644: 20 04       bra   $D64A

D646: 86 45       ldaa   #45
D648: C6 55       ldab   #55
D64A: A7 04       staa   $04,X
D64C: E7 05       stab   $05,X
D64E: 86 05       ldaa   #05
D650: A7 00       staa   $00,X
D652: BD D2 6D    jsr   $D26D
D655: 97 0A       staa   $000A
D657: DE CF       ldx   current_thread
D659: 86 A4       ldaa   #A4
D65B: A7 0D       staa   $0D,X
D65D: 86 02       ldaa   #02
D65F: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
D662: C0 

D663: 4A  	  deca
D664: 26 F9       bne   $D65F
D666: B6 11 9B    ldaa   $119B
D669: 3F          SWI   
D66A: 52          --------------------
D66B: A1 5A       cmpa  $5A,X
D66D: FD          --------------------
D66E: E0 0B       subb  $0B,X
D670: 06          TAP   
D671: A0 4C       SUBA  score_p1_b0,X
D673: 15          --------------------
D674: 00          --------------------
D675: 80 0B       SUBA  #0B
D677: 5A          decb  
D678: FC          --------------------
D679: E0 0D       subb  $0D,X
D67B: 04          --------------------
D67C: 19          DAA   
D67D: 10          SBA   
D67E: 80 02       SUBA  #02
D680: 19          DAA   
D681: 11          CBA   
D682: CA 04       ORB   #04
D684: 04          --------------------
D685: 86 0C       ldaa   #0C
D687: 5F          clrb  
D688: BD D2 CF    jsr   $D2CF
D68B: 97 0A       staa   $000A
D68D: 7E D5 AA    jmp   $D5AA

D690: 3F          SWI   
D691: 74 5A FE    LSR   $5AFE
D694: F2 FF 68    SBCB  $FF68
D697: F9 52 68    ADCB  $5268
D69A: EE 33       ldx   $33,X
D69C: F1 F2 F7    CMPB  $F2F7
D69F: 74 33 01    LSR   $3301
D6A2: 02          --------------------
D6A3: 07          TPA   
D6A4: 03          --------------------
D6A5: 36          psha  
D6A6: CE D6 90    ldx   #D690
D6A9: BD D5 0D    jsr   $D50D
D6AC: 96 06       ldaa   $0006
D6AE: 8B 99       ADDA  #99
D6B0: 19          DAA   
D6B1: 97 06       staa   $0006
D6B3: 81 01       cmpa  #01
D6B5: 26 06       bne   $D6BD
D6B7: CE D5 64    ldx   #D564
D6BA: BD D5 0D    jsr   $D50D
D6BD: 32          pula  
D6BE: 39          rts   

D6BF: CE E4 71    ldx   #E471
D6C2: BD EE 3E    jsr   xplusa	 ( X = X + A)
D6C5: A6 00       ldaa   $00,X
D6C7: 39          rts   

D6C8: 36          psha  
D6C9: 37          PSHB  
D6CA: 4A          deca  
D6CB: BD F3 6F    jsr   $F36F
D6CE: 27 04       beq   $D6D4
D6D0: 86 01       ldaa   #01
D6D2: 20 09       bra   $D6DD

D6D4: 4C          inca  
D6D5: 4C          inca  
D6D6: BD F3 6F    jsr   $F36F
D6D9: 27 05       beq   $D6E0
D6DB: 86 02       ldaa   #02
D6DD: B7 13 9D    staa   $139D
D6E0: 33          PULB  
D6E1: 32          pula  
D6E2: 39          rts   

D6E3: 36          psha  
D6E4: 37          PSHB  
D6E5: 16          tab   
D6E6: 8B 41       ADDA  #41
D6E8: 8D DE       bsr   $D6C8
D6EA: BD F2 04    jsr   $F204
D6ED: C0 08       subb  #08
D6EF: CE E4 B4    ldx   #E4B4
D6F2: BD D3 F9    jsr   $D3F9
D6F5: F7 13 9C    stab   $139C
D6F8: FE 11 96    ldx   $1196
D6FB: 27 E3       beq   $D6E0
D6FD: E1 00       CMPB  $00,X
D6FF: 26 DF       bne   $D6E0
D701: 08          inx   
D702: FF 11 96    stx   $1196
D705: 74 11 98    LSR   $1198
D708: 20 D6       bra   $D6E0

D70A: D8 30       EORB  $0030
D70C: 19          DAA   
D70D: CF          --------------------
D70E: 4D          TSTA  
D70F: 29 C0       BVS   $D6D1
D711: 00          --------------------
D712: CA 00       ORB   #00
D714: 57          ASRB  
D715: F9 22 AC    ADCB  $22AC
D718: 2D 4C       BLT   $D766
D71A: 7C 00 E6    INC   flag_tilt
D71D: D6 EB       ldab   player_up
D71F: BD FA 63    jsr   $FA63
D722: D6 EB       ldab   player_up
D724: 57          ASRB  
D725: F9 EA 02    ADCB  $EA02
D728: AF B9       STS   $B9,X
D72A: 44          LSRA  
D72B: 80 12       SUBA  #12
D72D: 5B          --------------------
D72E: D0 E0       subb  $00E0
D730: 42          --------------------
D731: DD          --------------------
D732: 00          --------------------
D733: 4C          inca  
D734: C6 21       ldab   #21
D736: D7 C8       stab   thread_priority
D738: CE DD 76    ldx   #DD76
D73B: BD E9 D8    jsr   newthread_sp	Push Control Stack: Data in A,B,X,$AA,$A6,$A7
D73E: 42          --------------------
D73F: 0B          SEV   
D740: E8 B3       EORB  $B3,X
D742: FF 5A FB    stx   $5AFB
D745: FB F3 FC    ADDB  $F3FC
D748: E3          --------------------
D749: 00          --------------------
D74A: D0 2E       subb  $002E
D74C: D0 2F       subb  $002F
D74E: 24 55       bcc   $D7A5
D750: 08          inx   
D751: 00          --------------------
D752: E5 A2       BITB  $A2,X
D754: 32          pula  
D755: 9F B3       STS   irqcount16
D757: 57          ASRB  
D758: DF 64       stx   $0064
D75A: A0 18       SUBA  lampbuffer0x
D75C: A4 2A       anda  $2A,X
D75E: 55          --------------------
D75F: 08          inx   
D760: 00          --------------------
D761: 47          ASRA  
D762: D6 EB       ldab   player_up
D764: BD F9 EA    jsr   $F9EA
D767: 4A          deca  
D768: 97 F4       staa   flag_timer_bip
D76A: CE F9 75    ldx   #F975
D76D: BD D5 0E    jsr   $D50E
D770: 57          ASRB  
D771: D3          --------------------
D772: CB 03       ADDB  #03
D774: CE E5 74    ldx   #msg_wave
D777: BD D3 0B    jsr   $D30B
D77A: BD E6 D2    jsr   $E6D2
D77D: 8D 06       bsr   $D785
D77F: CE E5 79    ldx   #msg_completed
D782: BD D3 0B    jsr   $D30B
D785: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
D788: 45    

D789: 39          rts   

D78A: AF 57       STS   $57,X
D78C: 5B          --------------------
D78D: F4 43 2E    andb  $432E
D790: 19          DAA   
D791: 11          CBA   
D792: 80 19       SUBA  #19
D794: AF 4D       STS   $4D,X
D796: 5B          --------------------
D797: F4 3A 24    andb  $3A24
D79A: 19          DAA   
D79B: 10          SBA   
D79C: 80 0F       SUBA  #0F
D79E: C6 3D       ldab   #3D
D7A0: 20 02       bra   $D7A4

D7A2: C6 3E       ldab   #3E
D7A4: 3F          SWI   
D7A5: AF 3C       STS   lampbuffer1x
D7A7: 5B          --------------------
D7A8: F4 E1 13    andb  $E113
D7AB: 15          --------------------
D7AC: 01          NOP   
D7AD: 96 87       ldaa   $0087
D7AF: 5A          decb  
D7B0: FE F2 F4    ldx   $F2F4
D7B3: A4 27       anda  $27,X
D7B5: 5A          decb  
D7B6: D0 2E       subb  $002E
D7B8: 05          --------------------
D7B9: E0 42       subb  $42,X
D7BB: 2B 8F       BMI   $D74C
D7BD: 83          --------------------
D7BE: 03          --------------------
D7BF: C6 46       ldab   #46
D7C1: 20 E1       bra   $D7A4

D7C3: C6 47       ldab   #47
D7C5: 20 DD       bra   $D7A4

D7C7: 16          tab   
D7C8: C0 08       subb  #08
D7CA: CE E4 73    ldx   #E473
D7CD: BD D3 F9    jsr   $D3F9
D7D0: 20 D2       bra   $D7A4

D7D2: 3F          SWI   
D7D3: 5A          decb  
D7D4: FE F2 F6    ldx   $F2F6
D7D7: A4 18       anda  lampbuffer0x
D7D9: 72          --------------------
D7DA: 8F          --------------------
D7DB: F7 45 B6    stab   $45B6
D7DE: 13          --------------------
D7DF: 9C 5A       CPX   $005A
D7E1: FE F2 F6    ldx   $F2F6
D7E4: A4 03       anda  $03,X
D7E6: 76 8F F7    ROR   $8FF7
D7E9: 44          LSRA  
D7EA: D6 64       ldab   $0064
D7EC: 5B          --------------------
D7ED: FC          --------------------
D7EE: E0 E1       subb  $E1,X
D7F0: C4 55       andb  #55
D7F2: F1 A0 52    CMPB  $A052
D7F5: A1 AD       cmpa  $AD,X
D7F7: F3          --------------------
D7F8: 04          --------------------
D7F9: 9B 04       ADDA  $0004
D7FB: 19          DAA   
D7FC: 97 04       staa   $0004
D7FE: C6 01       ldab   #01
D800: B6 13 9F    ldaa   $139F
D803: 27 0D       beq   $D812
D805: 46          RORA  
D806: 24 05       bcc   $D80D
D808: BD D9 CB    jsr   $D9CB
D80B: 20 0A       bra   $D817

D80D: BD D9 DA    jsr   $D9DA
D810: 20 05       bra   $D817

D812: CE 00 66    ldx   #0066
D815: 8D 1D       bsr   $D834
D817: BD D3 46    jsr   $D346
D81A: C6 10       ldab   #10
D81C: 86 01       ldaa   #01
D81E: BD EC 3B    jsr   isnd_once
D821: 96 7B       ldaa   dmask_p4
D823: 43          COMA  
D824: 84 3F       anda  #3F
D826: 97 7B       staa   dmask_p4
D828: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
D82B: 05 

D82C: 5A          decb  
D82D: 26 F2       bne   $D821
D82F: D7 7B       stab   dmask_p4
D831: 7E D6 66    jmp   $D666

D834: E6 01       ldab   $01,X
D836: C4 3F       andb  #3F
D838: C0 1B       subb  #1B
D83A: 27 08       beq   $D844
D83C: 86 0B       ldaa   #0B
D83E: BD EB 3D    jsr   $EB3D
D841: 5A          decb  
D842: 26 FA       bne   $D83E
D844: E6 00       ldab   $00,X
D846: 27 0A       beq   $D852
D848: C0 1B       subb  #1B
D84A: 86 0C       ldaa   #0C
D84C: BD EB 3D    jsr   $EB3D
D84F: 5A          decb  
D850: 26 FA       bne   $D84C
D852: 39          rts   

D853: D6 7A       ldab   dmask_p3
D855: 53          COMB  
D856: C4 7F       andb  #7F
D858: D7 7A       stab   dmask_p3
D85A: D7 7B       stab   dmask_p4
D85C: 39          rts   

D85D: 36          psha  
D85E: BD D5 EB    jsr   $D5EB
D861: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
D864: 01 

D865: 27 14       beq   $D87B
D867: 81 03       cmpa  #03
D869: 27 F3       beq   $D85E
D86B: 81 02       cmpa  #02
D86D: 26 0C       bne   $D87B
D86F: 86 0A       ldaa   #0A
D871: BD F3 45    jsr   $F345
D874: 25 04       bcs   $D87A
D876: 86 02       ldaa   #02
D878: 20 01       bra   $D87B

D87A: 4F          clra  
D87B: B7 13 9E    staa   $139E
D87E: 32          pula  
D87F: 39          rts   

D880: DE CF       ldx   current_thread
D882: 6F 0D       CLR   $0D,X
D884: 39          rts   

D885: 8D F9       bsr   $D880
D887: CE 00 00    ldx   #0000
D88A: FF 11 96    stx   $1196
D88D: 8D 7D       bsr   $D90C
D88F: A6 00       ldaa   $00,X
D891: B7 13 9E    staa   $139E
D894: EE 01       ldx   $01,X
D896: FF 11 98    stx   $1198
D899: 26 31       bne   $D8CC
D89B: 3F          SWI   
D89C: 53          COMB  
D89D: 40          NEGA  
D89E: 5A          decb  
D89F: FE F2 F0    ldx   $F2F0
D8A2: A0 F8       SUBA  $F8,X
D8A4: 52          --------------------
D8A5: A0 04       SUBA  $04,X
D8A7: CE E5 83    ldx   #msg_spell
D8AA: BD D3 0B    jsr   $D30B
D8AD: BD D3 4C    jsr   $D34C
D8B0: 86 10       ldaa   #10
D8B2: 8D 9F       bsr   $D853
D8B4: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
D8B7: 08 

D8B8: 4A          deca  
D8B9: 26 F7       bne   $D8B2
D8BB: BD D5 F0    jsr   $D5F0
D8BE: 26 01       bne   $D8C1
D8C0: 4C          inca  
D8C1: 8D 9A       bsr   $D85D
D8C3: 4A          deca  
D8C4: B7 11 99    staa   $1199
D8C7: 86 20       ldaa   #20
D8C9: B7 11 98    staa   $1198
D8CC: BD D9 71    jsr   $D971
D8CF: 24 FB       bcc   $D8CC
D8D1: BD D3 4C    jsr   $D34C
D8D4: 8D 51       bsr   $D927
D8D6: CE 13 AD    ldx   #13AD
D8D9: DF B8       stx   temp1
D8DB: B6 11 98    ldaa   $1198
D8DE: 27 71       beq   $D951
D8E0: 85 20       BITA  #20
D8E2: 26 06       bne   $D8EA
D8E4: 48          ASLA  
D8E5: 27 6A       beq   $D951
D8E7: 08          inx   
D8E8: 20 F6       bra   $D8E0

D8EA: FF 11 96    stx   $1196
D8ED: BD D3 54    jsr   $D354
D8F0: 8D 53       bsr   $D945
D8F2: 8D 8C       bsr   $D880
D8F4: 86 7F       ldaa   #7F
D8F6: 97 7A       staa   dmask_p3
D8F8: 84 7F       anda  #7F
D8FA: 97 7B       staa   dmask_p4
D8FC: 8D 73       bsr   $D971
D8FE: 24 17       bcc   $D917
D900: 8D 7A       bsr   $D97C
D902: 27 4D       beq   $D951
D904: 43          COMA  
D905: 9A 7B       oraa   dmask_p4
D907: B8 11 98    EORA  $1198
D90A: 20 EC       bra   $D8F8

D90C: CE 13 A0    ldx   #13A0
D90F: D6 EB       ldab   player_up
D911: 27 03       beq   $D916
D913: 08          inx   
D914: 08          inx   
D915: 08          inx   
D916: 39          rts   

D917: 5F          clrb  
D918: BD D8 58    jsr   $D858
D91B: 8D 5F       bsr   $D97C
D91D: 27 32       beq   $D951
D91F: 8D 50       bsr   $D971
D921: 24 F8       bcc   $D91B
D923: 8D 02       bsr   $D927
D925: 20 CD       bra   $D8F4

D927: BD D2 D6    jsr   $D2D6
D92A: CE 00 6C    ldx   #006C
D92D: DF B8       stx   temp1
D92F: CE E5 BC    ldx   #E5BC
D932: B6 13 9E    ldaa   $139E
D935: 27 09       beq   $D940
D937: CE E5 B6    ldx   #E5B6
D93A: 46          RORA  
D93B: 25 03       bcs   $D940
D93D: CE E5 B0    ldx   #E5B0
D940: 8D 0C       bsr   $D94E
D942: 7C 00 B9    INC   temp1+1
D945: CE E4 A6    ldx   #E4A6
D948: B6 11 99    ldaa   $1199
D94B: BD F5 28    jsr   gettabledata_b
D94E: 7E D3 0D    jmp   $D30D

D951: CE 00 00    ldx   #0000
D954: FF 11 96    stx   $1196
D957: FF 11 98    stx   $1198
D95A: 8D 2B       bsr   $D987
D95C: CE 13 AD    ldx   #13AD
D95F: BD D3 54    jsr   $D354
D962: C6 03       ldab   #03
D964: B6 13 9E    ldaa   $139E
D967: 27 34       beq   $D99D
D969: 81 02       cmpa  #02
D96B: 27 2C       beq   $D999
D96D: 8D 5C       bsr   $D9CB
D96F: 20 31       bra   $D9A2

D971: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
D974: 05     

D975: 86 A0       ldaa   #A0
D977: C6 F0       ldab   #F0
D979: 7E EA 60    jmp   check_threadid

D97C: FE 11 96    ldx   $1196
D97F: A6 00       ldaa   $00,X
D981: 27 03       beq   $D986
D983: B6 11 98    ldaa   $1198
D986: 39          rts   

D987: 8D 83       bsr   $D90C
D989: B6 13 9E    ldaa   $139E
D98C: A7 00       staa   $00,X
D98E: B6 11 98    ldaa   $1198
D991: A7 01       staa   $01,X
D993: B6 11 99    ldaa   $1199
D996: A7 02       staa   $02,X
D998: 39          rts   

D999: 8D 3F       bsr   $D9DA
D99B: 20 05       bra   $D9A2

D99D: 86 4C       ldaa   #4C
D99F: BD EB 3D    jsr   $EB3D
D9A2: 86 06       ldaa   #06
D9A4: BD EC 3B    jsr   isnd_once
D9A7: 8D C8       bsr   $D971
D9A9: 24 1A       bcc   $D9C5
D9AB: DE CF       ldx   current_thread
D9AD: 86 A1       ldaa   #A1
D9AF: A7 0D       staa   $0D,X
D9B1: 86 7F       ldaa   #7F
D9B3: 97 7B       staa   dmask_p4
D9B5: 86 10       ldaa   #10
D9B7: D6 7A       ldab   dmask_p3
D9B9: 53          COMB  
D9BA: C4 7F       andb  #7F
D9BC: D7 7A       stab   dmask_p3
D9BE: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
D9C1: 05   

D9C2: 4A          deca  
D9C3: 26 F2       bne   $D9B7
D9C5: BD D3 46    jsr   $D346
D9C8: 7E D8 85    jmp   $D885

D9CB: 37          PSHB  
D9CC: BD D3 F3    jsr   $D3F3
D9CF: 17          TBA   
D9D0: 33          PULB  
D9D1: 1B          ABA   
D9D2: A7 00       staa   $00,X
D9D4: 96 EB       ldaa   player_up
D9D6: 8B 0B       ADDA  #0B
D9D8: 20 0E       bra   $D9E8

D9DA: 96 06       ldaa   $0006
D9DC: 1B          ABA   
D9DD: 81 05       cmpa  #05
D9DF: 2F 02       BLE   $D9E3
D9E1: 86 05       ldaa   #05
D9E3: 97 06       staa   $0006
D9E5: 86 0A       ldaa   #0A
D9E7: 58          ASLB  
D9E8: 8D 04       bsr   $D9EE
D9EA: 5A          decb  
D9EB: 26 FB       bne   $D9E8
D9ED: 39          rts   

D9EE: 7E F2 64    jmp   $F264

D9F1: 3F          SWI   
D9F2: AB F4       ADDA  $F4,X
D9F4: 44          LSRA  
D9F5: 84 02       anda  #02
D9F7: 5B          --------------------
D9F8: D0 2F       subb  $002F
D9FA: 01          NOP   
D9FB: 03          --------------------
D9FC: 52          --------------------
D9FD: 50          NEGB  
D9FE: 5A          decb  
D9FF: FC          --------------------
DA00: E8 00       EORB  $00,X
DA02: F8 B8 FF    EORB  $B8FF
DA05: 5A          decb  
DA06: FC          --------------------
DA07: E0 02       subb  $02,X
DA09: 2C C1       BGE   $D9CC
DA0B: 36          psha  
DA0C: 5A          decb  
DA0D: F4 E1 09    andb  $E109
DA10: 14          --------------------
DA11: 01          NOP   
DA12: 69 69       rol   $69,X
DA14: 5B          --------------------
DA15: E1 DB       CMPB  $DB,X
DA17: 15          --------------------
DA18: 01          NOP   
DA19: 5A          decb  
DA1A: FC          --------------------
DA1B: E1 3E       CMPB  $3E,X
DA1D: 69 5B       rol   $5B,X
DA1F: FC          --------------------
DA20: E1 3C       CMPB  lampbuffer1x
DA22: 02          --------------------
DA23: 19          DAA   
DA24: 10          SBA   
DA25: B1 01 5B    cmpa  $015B
DA28: FC          --------------------
DA29: E1 3A       CMPB  $3A,X
DA2B: E0 B1       subb  $B1,X
DA2D: 02          --------------------
DA2E: 5A          decb  
DA2F: F4 E1 F3    andb  $E1F3
DA32: 18          --------------------
DA33: 10          SBA   
DA34: 8F          --------------------
DA35: DA C1       ORB   sys_temp4
DA37: 3F          SWI   
DA38: 5A          decb  
DA39: F4 E1 09    andb  $E109
DA3C: 14          --------------------
DA3D: 01          NOP   
DA3E: 69 69       rol   $69,X
DA40: 5B          --------------------
DA41: E1 AF       CMPB  $AF,X
DA43: 15          --------------------
DA44: 01          NOP   
DA45: 5A          decb  
DA46: FC          --------------------
DA47: E1 47       CMPB  $47,X
DA49: 65          --------------------
DA4A: 5B          --------------------
DA4B: FC          --------------------
DA4C: E1 45       CMPB  $45,X
DA4E: 02          --------------------
DA4F: 19          DAA   
DA50: 11          CBA   
DA51: B1 01 5B    cmpa  $015B
DA54: FC          --------------------
DA55: E1 43       CMPB  $43,X
DA57: E0 B1       subb  $B1,X
DA59: 02          --------------------
DA5A: 5A          decb  
DA5B: F4 E1 F3    andb  $E1F3
DA5E: 18          --------------------
DA5F: 11          CBA   
DA60: 8F          --------------------
DA61: DA 37       ORB   $0037
DA63: 16          tab   
DA64: BD DD 17    jsr   $DD17
DA67: 3F          SWI   
DA68: 5A          decb  
DA69: FB D0 E0    ADDB  $D0E0
DA6C: F3          --------------------
DA6D: F5 E0 13    BITB  $E013
DA70: DC          --------------------
DA71: 00          --------------------
DA72: 14          --------------------
DA73: 01          NOP   
DA74: 69 69       rol   $69,X
DA76: 5A          decb  
DA77: D0 E0       subb  $00E0
DA79: 04          --------------------
DA7A: C0 00       subb  #00
DA7C: 80 05       SUBA  #05
DA7E: DD          --------------------
DA7F: 00          --------------------
DA80: 57          ASRB  
DA81: F2 1D 04    SBCB  $1D04
DA84: 33          PULB  
DA85: 39          rts   

DA86: 3F          SWI   
DA87: 90 D0       SUBA  $00D0
DA89: 5A          decb  
DA8A: D0 2F       subb  $002F
DA8C: 5F          clrb  
DA8D: C0 00       subb  #00
DA8F: B0 01 5A    SUBA  $015A
DA92: FA D0 E0    ORB   $D0E0
DA95: F3          --------------------
DA96: FC          --------------------
DA97: E0 E1       subb  $E1,X
DA99: F5 5A FE    BITB  $5AFE
DA9C: F2 F0 30    SBCB  $F030
DA9F: 4C          inca  
DAA0: AF C0       STS   $C0,X
DAA2: 5A          decb  
DAA3: FC          --------------------
DAA4: E0 00       subb  $00,X
DAA6: 45          --------------------
DAA7: 5A          decb  
DAA8: FC          --------------------
DAA9: E0 E1       subb  $E1,X
DAAB: 28 8F       BVC   $DA3C
DAAD: E1 3F       CMPB  $3F,X
DAAF: 90 A8       SUBA  lamp_bit
DAB1: 5A          decb  
DAB2: D0 2F       subb  $002F
DAB4: 37          PSHB  
DAB5: C0 0A       subb  #0A
DAB7: B0 FF 5A    SUBA  $FF5A
DABA: FA D0 E0    ORB   $D0E0
DABD: F3          --------------------
DABE: FC          --------------------
DABF: E0 E1       subb  $E1,X
DAC1: F5 5A FE    BITB  $5AFE
DAC4: F2 F0 30    SBCB  $F030
DAC7: 24 AF       bcc   $DA78
DAC9: 98 5A       EORA  $005A
DACB: FC          --------------------
DACC: E0 00       subb  $00,X
DACE: 1D          --------------------
DACF: 5B          --------------------
DAD0: FC          --------------------
DAD1: E0 E1       subb  $E1,X
DAD3: E3          --------------------
DAD4: 5A          decb  
DAD5: FA F5 E0    ORB   $F5E0
DAD8: F3          --------------------
DAD9: D0 E0       subb  $00E0
DADB: 03          --------------------
DADC: 71          --------------------
DADD: 8F          --------------------
DADE: F5 DC 00    BITB  $DC00
DAE1: AF 0B       STS   $0B,X
DAE3: 5A          decb  
DAE4: F6 E0 08    ldab   $E008
DAE7: 69 5A       rol   $5A,X
DAE9: D0 E0       subb  $00E0
DAEB: F5 93 48    BITB  $9348
DAEE: 03          --------------------
DAEF: 57          ASRB  
DAF0: F2 E1 57    SBCB  $E157
DAF3: F2 F2 5A    SBCB  $F25A
DAF6: F5 E0 07    BITB  $E007
DAF9: 74 5B D0    LSR   $5BD0
DAFC: E0 EE       subb  $EE,X
DAFE: 8F          --------------------
DAFF: EF DD       stx   $DD,X
DB01: 00          --------------------
DB02: 52          --------------------
DB03: 00          --------------------
DB04: 93          --------------------
DB05: 30          TSX   
DB06: AB 9D       ADDA  switch_b4,X
DB08: 1C          --------------------
DB09: 8A 0A       oraa   #0A
DB0B: B2 04 5B    SBCA  $045B
DB0E: FC          --------------------
DB0F: E6 00       ldab   $00,X
DB11: DC          --------------------
DB12: 55          --------------------
DB13: 08          inx   
DB14: 00          --------------------
DB15: 31          INS   
DB16: F6 9B F1    ldab   $9BF1
DB19: C0 05       subb  #05
DB1B: C1 05       CMPB  #05
DB1D: 14          --------------------
DB1E: 01          NOP   
DB1F: 5A          decb  
DB20: FC          --------------------
DB21: E1 35       CMPB  $35,X
DB23: 04          --------------------
DB24: B1 06 8F    cmpa  $068F
DB27: F5 5B 05    BITB  $5B05
DB2A: 0D          SEC   
DB2B: B0 FF 5A    SUBA  $FF5A
DB2E: FC          --------------------
DB2F: E0 00       subb  $00,X
DB31: 22 EE       BHI   $DB21
DB33: 34          DES   
DB34: 40          NEGA  
DB35: 41          --------------------
DB36: 42          --------------------
DB37: 47          ASRA  
DB38: 1D          --------------------
DB39: 81 82       cmpa  #82
DB3B: 83          --------------------
DB3C: 84 85       anda  #85
DB3E: 86 87       ldaa   #87
DB40: 88 09       EORA  #09
DB42: 77 5B 00    ASR   $5B00
DB45: E2 10       SBCB  $10,X
DB47: BE BD C6    LDS   $BDC6
DB4A: 47          ASRA  
DB4B: 48          ASLA  
DB4C: CE DD B0    ldx   #DDB0
DB4F: BD EA 24    jsr   newthread_06	 Push Control Stack: Data in A,B,X,$A6,$A7,$AA=#06
DB52: 8F          --------------------
DB53: D4 C6       andb  sys_temp_w3
DB55: 00          --------------------
DB56: 5F          clrb  
DB57: D3          --------------------
DB58: A1 71       cmpa  $71,X
DB5A: 5A          decb  
DB5B: FE F2 F1    ldx   $F2F1
DB5E: 21          --------------------
DB5F: F9 52 20    ADCB  $5220
DB62: 5B          --------------------
DB63: F6 4D 02    ldab   $4D02
DB66: 19          DAA   
DB67: 4D          TSTA  
DB68: A0 13       SUBA  $13,X
DB6A: B1 30 5A    cmpa  $305A
DB6D: FB FB D0    ADDB  $FBD0
DB70: E1 D0       CMPB  $D0,X
DB72: E0 D0       subb  $D0,X
DB74: F9 E1 23    ADCB  $E123
DB77: E1 DC       CMPB  $DC,X
DB79: 01          NOP   
DB7A: 51          --------------------
DB7B: 10          SBA   
DB7C: 02          --------------------
DB7D: BD D5 F5    jsr   $D5F5
DB80: 81 08       cmpa  #08
DB82: 2F 01       BLE   $DB85
DB84: 44          LSRA  
DB85: 4C          inca  
DB86: 16          tab   
DB87: 39          rts   

DB88: BD D2 D6    jsr   $D2D6
DB8B: CE 00 60    ldx   #0060
DB8E: DF B8       stx   temp1
DB90: CE E5 C8    ldx   #E5C8
DB93: BD D3 0D    jsr   $D30D
DB96: CE E5 8D    ldx   #msg_bonus
DB99: BD D3 0D    jsr   $D30D
DB9C: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
DB9F: 25 

DBA0: BD D2 D6    jsr	$D2D6
DBA3: D6 06       ldab   $0006
DBA5: CE 00 61    ldx   #0061
DBA8: BD EC 32    jsr   split_ab
DBAB: 5D          TSTB  
DBAC: 27 04       beq   $DBB2
DBAE: CB 1B       ADDB  #1B
DBB0: E7 00       stab   $00,X
DBB2: D6 06       ldab   $0006
DBB4: C4 0F       andb  #0F
DBB6: CB 1B       ADDB  #1B
DBB8: E7 01       stab   $01,X
DBBA: 86 18       ldaa   #18
DBBC: A7 03       staa   $03,X
DBBE: 96 05       ldaa   $0005
DBC0: 81 09       cmpa  #09
DBC2: 23 02       BLS   $DBC6
DBC4: 86 09       ldaa   #09
DBC6: 16          tab   
DBC7: CB 9B       ADDB  #9B
DBC9: E7 05       stab   $05,X
DBCB: C6 1B       ldab   #1B
DBCD: E7 06       stab   $06,X
DBCF: E7 07       stab   $07,X
DBD1: E7 08       stab   $08,X
DBD3: 48          ASLA  
DBD4: 48          ASLA  
DBD5: 48          ASLA  
DBD6: 8A 03       oraa   #03
DBD8: D6 06       ldab   $0006
DBDA: BD EB 3D    jsr   $EB3D
DBDD: 5A          decb  
DBDE: 26 FA       bne   $DBDA
DBE0: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
DBE3: 25 

DBE4: 39          rts

DBE5: D6 05       ldab   $0005
DBE7: BD F8 9D    jsr   $F89D
DBEA: 86 7F       ldaa   #7F
DBEC: 80 04       SUBA  #04
DBEE: 81 09       cmpa  #09
DBF0: 2D 05       BLT   $DBF7
DBF2: 5A          decb  
DBF3: 26 F7       bne   $DBEC
DBF5: 20 02       bra   $DBF9

DBF7: 86 08       ldaa   #08
DBF9: 3F          SWI   
DBFA: CE 00 67    ldx   #0067
DBFD: BE 01 5A    LDS   $015A
DC00: D0 2F       subb  $002F
DC02: F9 45 D6    ADCB  $45D6
DC05: E8 4A       EORB  $4A,X
DC07: 5A          decb  
DC08: FC          --------------------
DC09: E0 00       subb  $00,X
DC0B: 09          DEX   
DC0C: 5B          --------------------
DC0D: FA FC E1    ORB   $FCE1
DC10: 00          --------------------
DC11: FD          --------------------
DC12: EE 30       ldx   $30,X
DC14: E7 71       stab   $71,X
DC16: 45          --------------------
DC17: 7F 13 96    CLR   $1396
DC1A: AF 61       STS   $61,X
DC1C: 5A          decb  
DC1D: FB F3 F5    ADDB  $F3F5
DC20: E0 D0       subb  $D0,X
DC22: E0 F1       subb  $F1,X
DC24: B0 53 A0    SUBA  $53A0
DC27: EF 52       stx   $52,X
DC29: 30          TSX   
DC2A: CE 06 DC    ldx   #06DC
DC2D: 00          --------------------
DC2E: 14          --------------------
DC2F: 01          NOP   
DC30: D5 01       BITB  vm_reg_b
DC32: 26 01       bne   $DC35
DC34: E2 67       SBCB  $67,X
DC36: 5B          --------------------
DC37: D0 E0       subb  $00E0
DC39: 20 BE       bra   $DBF9

DC3B: FF 5B FC    stx   $5BFC
DC3E: EE 00       ldx   $00,X
DC40: F1 24 01    CMPB  LAMP_PIA3_CRTL_A
DC43: A0 3F       SUBA  $3F,X
DC45: 25 01       bcs   $DC48
DC47: 15          --------------------
DC48: 01          NOP   
DC49: 5B          --------------------
DC4A: D0 E0       subb  $00E0
DC4C: 0D          SEC   
DC4D: DD          --------------------
DC4E: 00          --------------------
DC4F: A0 D2       SUBA  $D2,X
DC51: 5B          --------------------
DC52: FC          --------------------
DC53: E1 00       CMPB  $00,X
DC55: D4 52       andb  $0052
DC57: 00          --------------------
DC58: 8E B8 15    LDS   #B8
DC5B: 01          NOP   
DC5C: 25 01       bcs   $DC5F
DC5E: 52          --------------------
DC5F: 00          --------------------
DC60: 42          --------------------
DC61: 0C          CLC   
DC62: 5A          decb  
DC63: FC          --------------------
DC64: E7 04       stab   $04,X
DC66: 02          --------------------
DC67: B7 FF A9    staa   $FFA9
DC6A: 85 44       BITA  #44
DC6C: 9B 03       ADDA  $0003
DC6E: FB 5A FD    ADDB  $5AFD
DC71: E5 09       BITB  $09,X
DC73: 02          --------------------
DC74: 53          COMB  
DC75: 20 7F       bra   $DCF6

DC77: 5A          decb  
DC78: D0 2F       subb  $002F
DC7A: F4 B0 FF    andb  $B0FF
DC7D: 5B          --------------------
DC7E: FC          --------------------
DC7F: E0 00       subb  $00,X
DC81: ED          --------------------
DC82: 8F          --------------------
DC83: 91 36       cmpa  $0036
DC85: 37          PSHB  
DC86: BD D5 EB    jsr   $D5EB
DC89: 97 0E       staa   $000E
DC8B: 33          PULB  
DC8C: 32          pula  
DC8D: 27 2D       beq   $DCBC
DC8F: 36          psha  
DC90: B6 13 96    ldaa   $1396
DC93: 81 03       cmpa  #03
DC95: 32          pula  
DC96: 2E 24       BGT   $DCBC
DC98: 36          psha  
DC99: 86 30       ldaa   #30
DC9B: 97 C8       staa   thread_priority
DC9D: 32          pula  
DC9E: CE DC BD    ldx   #DCBD
DCA1: BD E9 D8    jsr   newthread_sp	Push Control Stack: Data in A,B,X,$AA,$A6,$A7
DCA4: 3F          SWI   
DCA5: FD          --------------------
DCA6: 7A 5A FE    DEC   $5AFE
DCA9: F2 FF 30    SBCB  $FF30
DCAC: F9 04 8D    ADCB  $048D
DCAF: 5F          clrb  
DCB0: 27 0A       beq   $DCBC
DCB2: 7D 13 9D    TST   $139D
DCB5: 26 05       bne   $DCBC
DCB7: 7A 00 0E    DEC   $000E
DCBA: 26 DC       bne   $DC98
DCBC: 39          rts   

DCBD: 97 0D       staa   $000D
DCBF: 80 53       SUBA  #53
DCC1: BD F3 7D    jsr   $F37D
DCC4: 8A C0       oraa   #C0
DCC6: BD F2 7E    jsr   $F27E
DCC9: 84 8F       anda  #8F
DCCB: 36          psha  
DCCC: 17          TBA   
DCCD: F6 13 96    ldab   $1396
DCD0: BD F1 DA    jsr   $F1DA
DCD3: 32          pula  
DCD4: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
DCD7: 08  

DCD8: 36          psha  
DCD9: 37          PSHB  
DCDA: 96 0D       ldaa   $000D
DCDC: BD F3 6F    jsr   $F36F
DCDF: 33          PULB  
DCE0: 32          pula  
DCE1: 27 21       beq   $DD04
DCE3: BD F2 F2    jsr   $F2F2
DCE6: 5C          incb  
DCE7: C1 05       CMPB  #05
DCE9: 23 E9       BLS   $DCD4
DCEB: 8D 05       bsr   $DCF2
DCED: 3F          SWI   
DCEE: 52          --------------------
DCEF: 00          --------------------
DCF0: 8E 14 36    LDS   #14
DCF3: 37          PSHB  
DCF4: 86 2F       ldaa   #2F
DCF6: BD F3 6F    jsr   $F36F
DCF9: 33          PULB  
DCFA: 32          pula  
DCFB: 26 BF       bne   $DCBC
DCFD: 8D 02       bsr   $DD01
DCFF: 8A C0       oraa   #C0
DD01: 7E F2 1D    jmp   $F21D

DD04: 36          psha  
DD05: 86 0B       ldaa   #0B
DD07: BD EB 3D    jsr   $EB3D
DD0A: 32          pula  
DD0B: 8D E5       bsr   $DCF2
DD0D: 20 75       bra   $DD84

DD0F: 36          psha  
DD10: 37          PSHB  
DD11: BD F3 6F    jsr   $F36F
DD14: 33          PULB  
DD15: 32          pula  
DD16: 39          rts   

DD17: 36          psha  
DD18: 4F          clra  
DD19: 5A          decb  
DD1A: 27 04       beq   $DD20
DD1C: 8B 06       ADDA  #06
DD1E: 20 F9       bra   $DD19

DD20: 16          tab   
DD21: 32          pula  
DD22: 39          rts   

DD23: 36          psha  
DD24: B6 13 96    ldaa   $1396
DD27: 4C          inca  
DD28: B7 13 96    staa   $1396
DD2B: 81 06       cmpa  #06
DD2D: 32          pula  
DD2E: 26 02       bne   $DD32
DD30: 5F          clrb  
DD31: 39          rts   

DD32: 74 13 9D    LSR   $139D
DD35: 25 11       bcs   $DD48
DD37: 74 13 9D    LSR   $139D
DD3A: 25 15       bcs   $DD51
DD3C: 36          psha  
DD3D: BD FB 94    jsr   $FB94
DD40: 46          RORA  
DD41: 85 08       BITA  #08
DD43: 32          pula  
DD44: 25 18       bcs   $DD5E
DD46: 27 09       beq   $DD51
DD48: 4A          deca  
DD49: 81 53       cmpa  #53
DD4B: 27 0D       beq   $DD5A
DD4D: C0 05       subb  #05
DD4F: 20 0E       bra   $DD5F

DD51: 4C          inca  
DD52: 81 5D       cmpa  #5D
DD54: 27 07       beq   $DD5D
DD56: CB 07       ADDB  #07
DD58: 20 05       bra   $DD5F

DD5A: 4C          inca  
DD5B: 20 01       bra   $DD5E

DD5D: 4A          deca  
DD5E: 5C          incb  
DD5F: 36          psha  
DD60: 37          PSHB  
DD61: 80 53       SUBA  #53
DD63: BD F3 54    jsr   $F354
DD66: 24 05       bcc   $DD6D
DD68: BD F3 6F    jsr   $F36F
DD6B: 27 A7       beq   $DD14
DD6D: 33          PULB  
DD6E: 32          pula  
DD6F: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
DD72: 01     

DD73: 5A          decb  
DD74: 20 BC       bra   $DD32

DD76: BD F2 E1    jsr   $F2E1
DD79: BD F3 54    jsr   $F354
DD7C: 25 06       bcs   $DD84
DD7E: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
DD81: 04  

DD82: 20 F2       bra   $DD76

DD84: 7E E9 C4    jmp   $E9C4	Remove Current Thread from Control Stack

DD87: C6 0F       ldab   #0F
DD89: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
DD8C: 40    

DD8D: 5A          decb  
DD8E: 26 F9       bne   $DD89
DD90: 96 09       ldaa   $0009
DD92: 4A          deca  
DD93: 97 09       staa   $0009
DD95: 81 09       cmpa  #09
DD97: 2E EE       BGT   $DD87
DD99: 20 E9       bra   $DD84

DD9B: 5A          decb  
DD9C: FB F3 F1    ADDB  $F3F1
DD9F: D0 30       subb  $0030
DDA1: 1E          --------------------
DDA2: 52          --------------------
DDA3: 10          SBA   
DDA4: 55          --------------------
DDA5: FF 10 57    stx   $1057
DDA8: D2 D6       SBCB  soundcount
DDAA: 57          ASRB  
DDAB: D3          --------------------
DDAC: 49          ROLA  
DDAD: 5C          incb  
DDAE: DE EE       ldx   $00EE
DDB0: 3F          SWI   
DDB1: C0 09       subb  #09
DDB3: 1D          --------------------
DDB4: 96 15       ldaa   $0015
DDB6: EF 75       stx   $75,X
DDB8: B0 FF 5B    SUBA  $FF5B
DDBB: FC          --------------------
DDBC: E0 00       subb  $00,X
DDBE: F4 03 5A    andb  $035A
DDC1: FB D0 2F    ADDB  $D02F
DDC4: D0 30       subb  $0030
DDC6: F8 4A BD    EORB  $4ABD
DDC9: D3          --------------------
DDCA: F3          --------------------
DDCB: 27 03       beq   $DDD0
DDCD: 5A          decb  
DDCE: E7 00       stab   $00,X
DDD0: B0 0B 5A    SUBA  $0B5A
DDD3: F5 E0 E9    BITB  $E0E9
DDD6: 5A          decb  
DDD7: FD          --------------------
DDD8: E1 02       CMPB  $02,X
DDDA: 03          --------------------
DDDB: 57          ASRB  
DDDC: F2 E1 D8    SBCB  $E1D8
DDDF: 2F 42       BLE   $DE23
DDE1: 09          DEX   
DDE2: 52          --------------------
DDE3: A1 29       cmpa  $29,X
DDE5: 52          --------------------
DDE6: 19          DAA   
DDE7: CF          --------------------
DDE8: D3          --------------------
DDE9: 12          --------------------
DDEA: C1 00       CMPB  #00
DDEC: 5B          --------------------
DDED: FE F2 FF    ldx   $F2FF
DDF0: 50          NEGB  
DDF1: 0B          SEV   
DDF2: B8 01 B1    EORA  $01B1
DDF5: 01          NOP   
DDF6: 42          --------------------
DDF7: 2B 54       BMI   $DE4D
DDF9: FF 50 8F    stx   $508F
DDFC: EF 5B       stx   $5B,X
DDFE: FE F2 FF    ldx   $F2FF
DE01: 20 0B       bra   $DE0E

DE03: 42          --------------------
DE04: 0B          SEV   
DE05: B1 01 B8    cmpa  $01B8
DE08: 01          NOP   
DE09: 54          LSRB  
DE0A: FF 20 8F    stx   $208F
DE0D: EF 5B       stx   $5B,X
DE0F: FE F2 F4    ldx   $F2F4
DE12: A4 07       anda  $07,X
DE14: 48          ASLA  
DE15: CE D7 D2    ldx   #D7D2
DE18: BD D5 0D    jsr   $D50D
DE1B: 28 54       BVC   $DE71
DE1D: 90 19       SUBA  $0019
DE1F: 4A          deca  
DE20: 96 03       ldaa   $0003
DE22: 10          SBA   
DE23: 2E 01       BGT   $DE26
DE25: 4F          clra  
DE26: 97 03       staa   $0003
DE28: A0 16       SUBA  $16,X
DE2A: EB A0       ADDB  $A0,X
DE2C: 4D          TSTA  
DE2D: 19          DAA   
DE2E: 12          --------------------
DE2F: 29 54       BVS   $DE85
DE31: D9 2F       ADCB  $002F
DE33: 89 0E       ADCA  #0E
DE35: 03          --------------------
DE36: B8 01 5B    EORA  $015B
DE39: FD          --------------------
DE3A: E8 06       EORB  $06,X
DE3C: 02          --------------------
DE3D: C8 06       EORB  #06
DE3F: 02          --------------------
DE40: CE E6 32    ldx   #E632
DE43: 08          inx   
DE44: 8C E6 82    CMPX  #E6
DE47: 27 17       beq   $DE60
DE49: E6 00       ldab   $00,X
DE4B: 17          TBA   
DE4C: 84 7F       anda  #7F
DE4E: BD F1 E8    jsr   $F1E8
DE51: 5D          TSTB  
DE52: 2B EF       BMI   $DE43
DE54: 86 0F       ldaa   #0F
DE56: BD EC 3B    jsr   isnd_once
DE59: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
DE5C: 02     

DE5D: 20 E4       bra   $DE43

DE5F: 39          rts   

DE60: CE E6 32    ldx   #E632
DE63: 08          inx   
DE64: 8C E6 82    CMPX  #E6
DE67: 27 F6       beq   $DE5F
DE69: E6 00       ldab   $00,X
DE6B: 17          TBA   
DE6C: 84 7F       anda  #7F
DE6E: BD F1 EF    jsr   $F1EF
DE71: 5D          TSTB  
DE72: 2B EF       BMI   $DE63
DE74: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
DE77: 02  

DE78: 20 E9       bra   $DE63

DE7A: CE E6 32    ldx   #E632
DE7D: FF 13 98    stx   $1398
DE80: 08          inx   
DE81: 8C E6 82    CMPX  #E6
DE84: 27 D9       beq   $DE5F
DE86: E6 00       ldab   $00,X
DE88: 17          TBA   
DE89: 84 7F       anda  #7F
DE8B: BD F1 E8    jsr   $F1E8
DE8E: 5D          TSTB  
DE8F: 2B EF       BMI   $DE80
DE91: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
DE94: 03  

DE95: FE 13 98    ldx   $1398
DE98: 08          inx   
DE99: E6 00       ldab   $00,X
DE9B: 17          TBA   
DE9C: 84 7F       anda  #7F
DE9E: BD F1 EF    jsr   $F1EF
DEA1: 5D          TSTB  
DEA2: 2B F4       BMI   $DE98
DEA4: 20 D7       bra   $DE7D

DEA6: 00          --------------------

gameover_init
DEA7: 3F          SWI   
DEA8: 36          psha  
DEA9: 01          NOP   
DEAA: 02          --------------------
DEAB: 03          --------------------
DEAC: 06          TAP   
DEAD: 07          TPA   
DEAE: 09          DEX   
DEAF: F8 19 14    EORB  $1914
DEB2: 29 D4       BVS   $DE88
DEB4: 14          --------------------
DEB5: 52          --------------------
DEB6: 10          SBA   
DEB7: 04          --------------------
DEB8: CE DF 6F    ldx   #DF6F
DEBB: BD D5 0D    jsr   $D50D
DEBE: 7F 00 E6    CLR   flag_tilt
DEC1: 7F 00 22    CLR   $0022
DEC4: CE E5 29    ldx   #msg_williams
DEC7: 8D 45       bsr   show_message
DEC9: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
DECC: 90 

DECD: CE E5 32    ldx   #msg_electronics
DED0: 8D 3C       bsr   show_message
DED2: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
DED5: 90 

DED6: CE E5 3E    ldx   #msg_presents
DED9: 8D 33       bsr   show_message
DEDB: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
DEDE: 70 

DEDF: CE E5 47    ldx   #msg_hyperball
DEE2: 5F          clrb  
DEE3: BD D3 15    jsr   $D315
DEE6: C6 25       ldab   #25
DEE8: CE 00 6B    ldx   #006B
DEEB: BD D2 F7    jsr   $D2F7
DEEE: 7C 00 22    INC   $0022
DEF1: BD E2 E7    jsr   $E2E7
DEF4: BD D2 D6    jsr   $D2D6
DEF7: BD D3 49    jsr   $D349
DEFA: 97 22       staa   $0022
DEFC: CE E5 51    ldx   #msg_credit
DEFF: BD D3 0B    jsr   $D30B
DF02: B6 11 9A    ldaa   current_credits
DF05: BD E6 D4    jsr   $E6D4
DF08: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
DF0B: E0 

DF0C: 20 B6       bra	$

show_message
DF0E: BD D3 0B    jsr	$D30B
DF11: BD D3 4C    jsr   $D34C
DF14: 86 04       ldaa   #04
DF16: CE 00 6C    ldx   #006C
DF19: 8D 1D       bsr   $DF38
DF1B: BD EA E5    jsr   hex2bitpos	Convert Hex(A&07) into Bitpos(B)
DF1E: 53          COMB  
DF1F: D4 7A       andb  dmask_p3
DF21: D7 7A       stab   dmask_p3
DF23: 08          inx   
DF24: 4A          deca  
DF25: 2A F2       BPL   $DF19
DF27: 86 06       ldaa   #06
DF29: 8D 0D       bsr   $DF38
DF2B: BD EA E5    jsr   hex2bitpos	Convert Hex(A&07) into Bitpos(B)
DF2E: 53          COMB  
DF2F: D4 7B       andb  dmask_p4
DF31: D7 7B       stab   dmask_p4
DF33: 08          inx   
DF34: 4A          deca  
DF35: 2A F2       BPL   $DF29
DF37: 39          rts   

DF38: 36          psha  
DF39: 37          PSHB  
DF3A: C6 01       ldab   #01
DF3C: 86 18       ldaa   #18
DF3E: A7 00       staa   $00,X
DF40: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
DF43: 02 

DF44: 86 2B       ldaa   #2B
DF46: A7 00       staa   $00,X
DF48: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
DF4B: 02   

DF4C: 5A          decb  
DF4D: 26 ED       bne   $DF3C
DF4F: 20 07       bra   $DF58

DF51: 36          psha  
DF52: 37          PSHB  
DF53: 8D 06       bsr   $DF5B
DF55: BD F1 BE    jsr   $F1BE
DF58: 33          PULB  
DF59: 32          pula  
DF5A: 39          rts   

DF5B: CE E4 7D    ldx   #E47D
DF5E: BD EE 8C    jsr   xplusb
DF61: A6 00       ldaa   $00,X
DF63: 39          rts   

DF64: CE DF 74    ldx   #DF74
DF67: 8D 03       bsr   $DF6C
DF69: CE E3 5E    ldx   #E35E
DF6C: 7E D5 0D    jmp   $D50D

DF6F: CE E3 34    ldx   #E334
DF72: 8D F8       bsr   $DF6C
DF74: CE DF B0    ldx   #DFB0
DF77: 8D F3       bsr   $DF6C
DF79: CE E6 81    ldx   #E681
DF7C: 08          inx   
DF7D: 8C E6 D2    CMPX  #E6
DF80: 27 14       beq   $DF96
DF82: A6 00       ldaa   $00,X
DF84: 16          tab   
DF85: 84 7F       anda  #7F
DF87: BD F1 91    jsr   $F191
DF8A: BD F1 D3    jsr   $F1D3
DF8D: 5D          TSTB  
DF8E: 2B EC       BMI   $DF7C
DF90: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
DF93: 05   

DF94: 20 E6       bra   $DF7C

DF96: CE E6 81    ldx   #E681
DF99: 08          inx   
DF9A: 8C E6 D2    CMPX  #E6
DF9D: 27 DA       beq   $DF79
DF9F: A6 00       ldaa   $00,X
DFA1: 16          tab   
DFA2: 84 7F       anda  #7F
DFA4: BD F1 B0    jsr   $F1B0
DFA7: 5D          TSTB  
DFA8: 2B EF       BMI   $DF99
DFAA: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
DFAD: 05 

DFAE: 20 E9       bra   $DF99

DFB0: 86 D4       ldaa   #D4
DFB2: BD F2 3D    jsr   $F23D
DFB5: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
DFB8: 04      

DFB9: 20 F5       bra   $DFB0

DFBB: 86 08       ldaa   #08
DFBD: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
DFC0: 40   

DFC1: 4A          deca  
DFC2: 26 F9       bne   $DFBD
DFC4: 86 09       ldaa   #09
DFC6: BD EA 83    jsr   solbuf
DFC9: 7E E9 C4    jmp   $E9C4	Remove Current Thread from Control Stack

DFCC: 5F          clrb  
DFCD: 86 0C       ldaa   #0C
DFCF: 7E D2 C8    jmp   $D2C8

DFD2: 16          tab   
DFD3: 84 0F       anda  #0F
DFD5: 8B 1B       ADDA  #1B
DFD7: 8A 80       oraa   #80
DFD9: A7 02       staa   $02,X
DFDB: BD EC 32    jsr   split_ab
DFDE: 4F          clra  
DFDF: 5D          TSTB  
DFE0: 27 03       beq   $DFE5
DFE2: CB 1B       ADDB  #1B
DFE4: 17          TBA   
DFE5: A7 01       staa   $01,X
DFE7: 86 1B       ldaa   #1B
DFE9: A7 03       staa   $03,X
DFEB: A7 04       staa   $04,X
DFED: A7 05       staa   $05,X
DFEF: 39          rts   

DFF0: CE E5 A5    ldx   #msg_reflex
DFF3: 86 04       ldaa   #04
DFF5: 97 0A       staa   $000A
DFF7: BD D2 6D    jsr   $D26D
DFFA: CE E5 74    ldx   #msg_wave
DFFD: BD D2 6D    jsr   $D26D
E000: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
E003: 40  

E004: 8D C6       bsr   $DFCC
E006: 97 0E       staa   $000E
E008: 97 0A       staa   $000A
E00A: BD D2 D6    jsr   $D2D6
E00D: 7C 00 0E    INC   $000E
E010: 86 14       ldaa   #14
E012: 91 0E       cmpa  $000E
E014: 26 53       bne   $E069
E016: BD D2 D6    jsr   $D2D6
E019: 86 10       ldaa   #10
E01B: BD EC 3B    jsr   isnd_once
E01E: 86 01       ldaa   #01
E020: 97 22       staa   $0022
E022: CE E5 FD    ldx   #E5FD
E025: BD D2 6D    jsr   $D26D
E028: 8D A2       bsr   $DFCC
E02A: CE 00 60    ldx   #0060
E02D: 96 05       ldaa   $0005
E02F: 81 06       cmpa  #06
E031: 2E 0B       BGT   $E03E
E033: 86 2C       ldaa   #2C
E035: BD EB 3D    jsr   $EB3D
E038: 86 50       ldaa   #50
E03A: 8D 96       bsr   $DFD2
E03C: 20 11       bra   $E04F

E03E: 86 0D       ldaa   #0D
E040: BD EB 3D    jsr   $EB3D
E043: 86 1C       ldaa   #1C
E045: A7 00       staa   $00,X
E047: 86 9B       ldaa   #9B
E049: A7 02       staa   $02,X
E04B: 86 1B       ldaa   #1B
E04D: 8D 96       bsr   $DFE5
E04F: CE 00 67    ldx   #0067
E052: DF B8       stx   temp1
E054: CE E5 8D    ldx   #msg_bonus
E057: BD D3 0D    jsr   $D30D
E05A: 3F          SWI   
E05B: 55          --------------------
E05C: 08          inx   
E05D: 00          --------------------
E05E: 56          RORB  
E05F: D7 0A       stab   $000A
E061: AF 01       STS   $01,X
E063: ED          --------------------
E064: 53          COMB  
E065: 50          NEGB  
E066: 5F          clrb  
E067: D7 5E       stab   cred_b0
E069: 3F          SWI   
E06A: 52          --------------------
E06B: 00          --------------------
E06C: 71          --------------------
E06D: 57          ASRB  
E06E: FB 94 44    ADDB  $9444
E071: 84 1F       anda  #1F
E073: 5A          decb  
E074: FB FD E0    ADDB  $FDE0
E077: 16          tab   
E078: D0 2F       subb  $002F
E07A: F1 5B F6    CMPB  $5BF6
E07D: 57          ASRB  
E07E: 02          --------------------
E07F: 19          DAA   
E080: 57          ASRB  
E081: 51          --------------------
E082: 10          SBA   
E083: B1 31 5B    cmpa  $315B
E086: D0 E1       subb  $00E1
E088: 04          --------------------
E089: B0 01 8F    SUBA  $018F
E08C: E3          --------------------
E08D: DC          --------------------
E08E: 01          NOP   
E08F: 51          --------------------
E090: 10          SBA   
E091: B0 49 DC    SUBA  $49DC
E094: 00          --------------------
E095: 5A          decb  
E096: FB FC E1    ADDB  $FCE1
E099: 16          tab   
E09A: FC          --------------------
E09B: E1 08       CMPB  $08,X
E09D: 04          --------------------
E09E: AE B1       LDS   $B1,X
E0A0: 80 0F       SUBA  #0F
E0A2: 5A          decb  
E0A3: FD          --------------------
E0A4: E1 08       CMPB  $08,X
E0A6: 06          TAP   
E0A7: 13          --------------------
E0A8: BA BB 3C    oraa   $BB3C
E0AB: 80 04       SUBA  #04
E0AD: 13          --------------------
E0AE: C3          --------------------
E0AF: C4 45       andb  #45
E0B1: 04          --------------------
E0B2: 36          psha  
E0B3: 37          PSHB  
E0B4: CE 00 62    ldx   #0062
E0B7: 96 0F       ldaa   $000F
E0B9: BD DF D2    jsr   $DFD2
E0BC: 33          PULB  
E0BD: 32          pula  
E0BE: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
E0C1: 30    

E0C2: 36          psha  
E0C3: 96 0C       ldaa   $000C
E0C5: 97 0D       staa   $000D
E0C7: 96 0D       ldaa   $000D
E0C9: 81 04       cmpa  #04
E0CB: 2D 03       BLT   $E0D0
E0CD: 7A 00 0D    DEC   $000D
E0D0: 97 D5       staa   thread_timer_byte
E0D2: 86 01       ldaa   #01
E0D4: BD EC 3B    jsr   isnd_once
E0D7: BD E9 71    jsr   delaythread
E0DA: 32          pula  
E0DB: BD DD 0F    jsr   $DD0F
E0DE: 27 2F       beq   $E10F
E0E0: CE 00 63    ldx   #0063
E0E3: 36          psha  
E0E4: BD E1 37    jsr   $E137
E0E7: 26 DE       bne   $E0C7
E0E9: 96 0E       ldaa   $000E
E0EB: 81 05       cmpa  #05
E0ED: 2F 1B       BLE   $E10A
E0EF: 32          pula  
E0F0: 86 1E       ldaa   #1E
E0F2: 97 E6       staa   flag_tilt
E0F4: BD EC 3B    jsr   isnd_once
E0F7: BD D2 D6    jsr   $D2D6
E0FA: 86 01       ldaa   #01
E0FC: 97 22       staa   $0022
E0FE: CE E5 9A    ldx   #msg_youmissed
E101: BD D2 6D    jsr   $D26D
E104: BD DF CC    jsr   $DFCC
E107: 7E E0 5A    jmp   $E05A

E10A: 32          pula  
E10B: 8D 46       bsr   $E153
E10D: 20 25       bra   $E134

E10F: 8D 42       bsr   $E153
E111: CE 00 63    ldx   #0063
E114: BD D8 34    jsr   $D834
E117: BD D3 46    jsr   $D346
E11A: 86 06       ldaa   #06
E11C: BD D8 53    jsr   $D853
E11F: 36          psha  
E120: 86 0E       ldaa   #0E
E122: BD EC 3B    jsr   isnd_once
E125: 32          pula  
E126: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
E129: 05  

E12A: 4A          deca  
E12B: 26 EF       bne   $E11C
E12D: 96 0F       ldaa   $000F
E12F: 8B 01       ADDA  #01
E131: 19          DAA   
E132: 97 0F       staa   $000F
E134: 7E E0 0A    jmp   $E00A

E137: A6 01       ldaa   $01,X
E139: 81 9B       cmpa  #9B
E13B: 27 05       beq   $E142
E13D: 4A          deca  
E13E: A7 01       staa   $01,X
E140: 20 10       bra   $E152

E142: A6 00       ldaa   $00,X
E144: 27 0C       beq   $E152
E146: 4A          deca  
E147: 81 1B       cmpa  #1B
E149: 26 01       bne   $E14C
E14B: 4F          clra  
E14C: A7 00       staa   $00,X
E14E: 86 A4       ldaa   #A4
E150: A7 01       staa   $01,X
E152: 39          rts   

E153: 3F          SWI   
E154: DD          --------------------
E155: 00          --------------------
E156: 5A          decb  
E157: FB FC E1    ADDB  $FCE1
E15A: 16          tab   
E15B: FC          --------------------
E15C: E1 08       CMPB  $08,X
E15E: 06          TAP   
E15F: AD FA       jsr   $FA,X
E161: 15          --------------------
E162: 00          --------------------
E163: 80 0B       SUBA  #0B
E165: 5A          decb  
E166: FD          --------------------
E167: E1 08       CMPB  $08,X
E169: 04          --------------------
E16A: 19          DAA   
E16B: 10          SBA   
E16C: 80 02       SUBA  #02
E16E: 19          DAA   
E16F: 11          CBA   
E170: 04          --------------------
E171: 39          rts   

E172: 3F          SWI   
E173: E6 5A       ldab   $5A,X
E175: FB FB F0    ADDB  $FBF0
E178: D0 30       subb  $0030
E17A: F3          --------------------
E17B: F1 F3 55    CMPB  $F355
E17E: FF 10 04    stx   $1004
E181: 86 10       ldaa   #10
E183: CE DE F4    ldx   #DEF4
E186: 7E D5 0E    jmp   $D50E

E189: C6 0A       ldab   #0A
E18B: 7F 00 E6    CLR   flag_tilt
E18E: 96 BF       ldaa   sys_temp2
E190: B7 13 B7    staa   $13B7
E193: 97 E7       staa   flag_gameover
E195: B6 D0 5A    ldaa   $D05A
E198: BD EC 3B    jsr   isnd_once
E19B: CE E5 58    ldx   #msg_player
E19E: 37          PSHB  
E19F: BD D3 0B    jsr   $D30B
E1A2: 33          PULB  
E1A3: B6 13 B7    ldaa   $13B7
E1A6: 40          NEGA  
E1A7: 8B 1E       ADDA  #1E
E1A9: DE B8       ldx   temp1
E1AB: A7 01       staa   $01,X
E1AD: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
E1B0: 08     

E1B1: BD D2 D6    jsr   $D2D6
E1B4: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
E1B7: 08   

E1B8: 5A          decb  
E1B9: 26 DA       bne   $E195
E1BB: CE E6 1E    ldx   #E61E
E1BE: BD D3 0B    jsr   $D30B
E1C1: DE B8       ldx   temp1
E1C3: C6 10       ldab   #10
E1C5: BD D2 F7    jsr   $D2F7
E1C8: 86 18       ldaa   #18
E1CA: BD EC 3B    jsr   isnd_once
E1CD: 86 05       ldaa   #05
E1CF: C6 40       ldab   #40
E1D1: E7 00       stab   $00,X
E1D3: BD D2 C8    jsr   $D2C8
E1D6: CE E6 0A    ldx   #E60A
E1D9: BD D2 6D    jsr   $D26D
E1DC: CE E6 15    ldx   #E615
E1DF: BD D2 6D    jsr   $D26D
E1E2: 86 05       ldaa   #05
E1E4: C6 40       ldab   #40
E1E6: BD D2 C8    jsr   $D2C8
E1E9: BD E6 E8    jsr   $E6E8
E1EC: CE 00 60    ldx   #0060
E1EF: FF 13 A7    stx   $13A7
E1F2: 86 2E       ldaa   #2E
E1F4: A7 00       staa   $00,X
E1F6: BD E2 28    jsr   $E228
E1F9: A6 00       ldaa   $00,X
E1FB: 81 2D       cmpa  #2D
E1FD: 26 09       bne   $E208
E1FF: 6F 00       CLR   $00,X
E201: 09          DEX   
E202: A6 00       ldaa   $00,X
E204: 26 F0       bne   $E1F6
E206: 20 EA       bra   $E1F2

E208: 81 2E       cmpa  #2E
E20A: 26 04       bne   $E210
E20C: 86 00       ldaa   #00
E20E: A7 00       staa   $00,X
E210: 08          inx   
E211: 8C 00 63    CMPX  #00
E214: 26 DC       bne   $E1F2
E216: CE 01 2E    ldx   #012E
E219: DF B8       stx   temp1
E21B: C6 0C       ldab   #0C
E21D: CE 00 60    ldx   #0060
E220: BD EF 23    jsr   copyblock2
E223: D7 22       stab   $0022
E225: 7E FB 3E    jmp   $FB3E

E228: A6 00       ldaa   $00,X
E22A: B7 13 B6    staa   $13B6
E22D: 86 60       ldaa   #60
E22F: B7 13 B8    staa   $13B8
E232: 86 06       ldaa   #06
E234: B7 13 B7    staa   $13B7
E237: 7A 13 B8    DEC   $13B8
E23A: 26 06       bne   $E242
E23C: 31          INS   
E23D: 31          INS   
E23E: 6F 00       CLR   $00,X
E240: 20 D4       bra   $E216

E242: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
E245: 02  

E246: 96 80       ldaa   $0080
E248: 2A 0C       BPL   $E256
E24A: BD E2 DF    jsr   $E2DF
E24D: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
E250: 02   

E251: 96 80       ldaa   $0080
E253: 2B F8       BMI   $E24D
E255: 39          rts   

E256: 96 81       ldaa   $0081
E258: 84 03       anda  #03
E25A: 26 14       bne   $E270
E25C: 7A 13 B7    DEC   $13B7
E25F: 26 E1       bne   $E242
E261: A6 00       ldaa   $00,X
E263: 27 04       beq   $E269
E265: 6F 00       CLR   $00,X
E267: 20 C9       bra   $E232

E269: B6 13 B6    ldaa   $13B6
E26C: A7 00       staa   $00,X
E26E: 20 C2       bra   $E232

E270: BD E2 DF    jsr   $E2DF
E273: C6 20       ldab   #20
E275: F7 13 B7    stab   $13B7
E278: 46          RORA  
E279: 25 18       bcs   $E293
E27B: 8D 2D       bsr   $E2AA
E27D: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
E280: 01  

E281: 96 81       ldaa   $0081
E283: 85 02       BITA  #02
E285: 27 A1       beq   $E228
E287: 7A 13 B7    DEC   $13B7
E28A: 26 F1       bne   $E27D
E28C: 86 05       ldaa   #05
E28E: B7 13 B7    staa   $13B7
E291: 20 E8       bra   $E27B

E293: 8D 32       bsr   $E2C7
E295: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
E298: 01     

E299: 96 81       ldaa   $0081
E29B: 46          RORA  
E29C: 24 8A       bcc   $E228
E29E: 7A 13 B7    DEC   $13B7
E2A1: 26 F2       bne   $E295
E2A3: 86 05       ldaa   #05
E2A5: B7 13 B7    staa   $13B7
E2A8: 20 E9       bra   $E293

E2AA: A6 00       ldaa   $00,X
E2AC: 4C          inca  
E2AD: 81 2E       cmpa  #2E
E2AF: 26 02       bne   $E2B3
E2B1: 86 2E       ldaa   #2E
E2B3: 81 2F       cmpa  #2F
E2B5: 26 02       bne   $E2B9
E2B7: 86 01       ldaa   #01
E2B9: 81 1B       cmpa  #1B
E2BB: 26 07       bne   $E2C4
E2BD: 8C 00 60    CMPX  #00
E2C0: 27 EF       beq   $E2B1
E2C2: 86 2D       ldaa   #2D
E2C4: A7 00       staa   $00,X
E2C6: 39          rts   

E2C7: A6 00       ldaa   $00,X
E2C9: 4A          deca  
E2CA: 26 02       bne   $E2CE
E2CC: 86 2E       ldaa   #2E
E2CE: 81 2C       cmpa  #2C
E2D0: 26 02       bne   $E2D4
E2D2: 86 1A       ldaa   #1A
E2D4: 81 2D       cmpa  #2D
E2D6: 26 EC       bne   $E2C4
E2D8: 8C 00 60    CMPX  #00
E2DB: 27 F5       beq   $E2D2
E2DD: 20 E3       bra   $E2C2

E2DF: 36          psha  
E2E0: B6 13 B6    ldaa   $13B6
E2E3: A7 00       staa   $00,X
E2E5: 32          pula  
E2E6: 39          rts   

E2E7: BD FA B1    jsr   $FAB1
E2EA: D6 7C       ldab   comma_flags
E2EC: F7 13 B6    stab   $13B6
E2EF: 43          COMA  
E2F0: 7D 00 54    TST   $0054
E2F3: 26 06       bne   $E2FB
E2F5: 97 54       staa   $0054
E2F7: 97 58       staa   $0058
E2F9: 86 33       ldaa   #33
E2FB: 97 7C       staa   comma_flags
E2FD: 86 7F       ldaa   #7F
E2FF: BD F9 27    jsr   $F927
E302: CE E6 2A    ldx   #E62A
E305: BD D3 0B    jsr   $D30B
E308: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
E30B: 30   

E30C: 86 0C       ldaa   #0C
E30E: B7 13 A9    staa   $13A9
E311: CE 13 AA    ldx   #13AA
E314: DF B8       stx   temp1
E316: CE 01 2E    ldx   #012E
E319: C6 0C       ldab   #0C
E31B: BD FF CD    jsr   $FFCD
E31E: CE 13 A9    ldx   #13A9
E321: BD D2 B0    jsr   $D2B0
E324: BD D2 58    jsr   $D258
E327: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
E32A: A0 

E32B: F6 13 B6	  ldab   $13B6	  
E32E: D7 7C       stab   comma_flags
E330: 4F          clra  
E331: 7E F9 27    jmp   $F927

E334: CE 55 01    ldx   #5501
E337: DF 32       stx   $0032
E339: 86 80       ldaa   #80
E33B: D6 EB       ldab   player_up
E33D: 27 01       beq   $E340
E33F: 44          LSRA  
E340: 97 31       staa   $0031
E342: CE E3 58    ldx   #E358
E345: BD D5 0D    jsr   $D50D
E348: 3F          SWI   
E349: 5B          --------------------
E34A: F1 05 18    CMPB  $0518
E34D: 0A          CLV   
E34E: 1C          --------------------
E34F: 8A 0A       oraa   #0A
E351: 29 0A       BVS   $E35D
E353: 75          --------------------
E354: 2F 4A       BLE   $E3A0
E356: 8F          --------------------
E357: FB 3F 62    ADDB  $3F62
E35A: 1E          --------------------
E35B: 0A          CLV   
E35C: 8F          --------------------
E35D: FB 86 40    ADDB  $8640
E360: BD EA 83    jsr   solbuf
E363: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
E366: 0A    

E367: 20 F5       bra   $E35E


lamptable
E369: 00          --------------------
E36A: 5F          clrb  
E36B: 00          --------------------
E36C: 05          --------------------
E36D: 06          TAP   
E36E: 0B          SEV   
E36F: 0C          CLC   
E370: 11          CBA   
E371: 12          --------------------
E372: 17          TBA   
E373: 18          --------------------
E374: 1D          --------------------
E375: 1E          --------------------
E376: 23 24       BLS   $E39C
E378: 29 2A       BVS   $E3A4
E37A: 2F 30       BLE   $E3AC
E37C: 35          TXS   
E37D: 50          NEGB  
E37E: 59          ROLB  
E37F: 48          ASLA  
E380: 4A          deca  
E381: 4B          --------------------
E382: 4D          TSTA  
E383: 31          INS   
E384: 39          rts   
E385: 3A          --------------------
E386: 47          ASRA  
E387: 49          ROLA  
E388: 5F          clrb  
E389: 3A          --------------------
E38A: 3C          --------------------
E38B: 43          COMA  
E38C: 45          --------------------
E38D: 00          --------------------
E38E: 47          ASRA  
E38F: 01          NOP   
E390: 09          DEX   
E391: 00          --------------------
E392: 4F          clra  
E393: 36          psha  
E394: 3E          --------------------
E395: 3F          SWI   
E396: 47          ASRA  
E397: 31          INS   
E398: 47          ASRA 

 
soundtable
E399: 22 30       BHI   $E3CB
E39B: 3C          --------------------
E39C: 23 10       BLS   $E3AE
E39E: 3B          RTI   
E39F: 22 20       BHI   $E3C1
E3A1: 3A          --------------------
E3A2: E3          --------------------
E3A3: FB FF E3    ADDB  $FFE3
E3A6: F6 FF E4    ldab   $FFE4
E3A9: 06          TAP   
E3AA: FF 22 30    stx   $2230
E3AD: 36          psha  
E3AE: 22 20       BHI   $E3D0
E3B0: 35          TXS   
E3B1: 22 20       BHI   $E3D3
E3B3: 34          DES   
E3B4: E4 01       andb  $01,X
E3B6: FF 22 20    stx   $2220
E3B9: 30          TSX   
E3BA: 22 20       BHI   $E3DC
E3BC: 2F 22       BLE   $E3E0
E3BE: 20 2E       bra   $E3EE

E3C0: 22 20       BHI   $E3E2
E3C2: 2D 22       BLT   $E3E6
E3C4: 20 2C       bra   $E3F2

E3C6: 22 20       BHI   $E3E8
E3C8: 2B 83       BMI   $E34D
E3CA: 50          NEGB  
E3CB: 2A 22       BPL   $E3EF
E3CD: 20 29       bra   $E3F8

E3CF: 83          --------------------
E3D0: 40          NEGA  
E3D1: 32          pula  
E3D2: 22 20       BHI   $E3F4
E3D4: 28 22       BVC   $E3F8
E3D6: 20 27       bra   $E3FF

E3D8: 23 20       BLS   $E3FA
E3DA: 3D          WAI   

E3DB: 22 20       BHI   $E3FD
E3DD: 26 22       bne   $E401
E3DF: 20 25       bra   $E406

E3E1: 24 20       bcc   $E403
E3E3: 3E          --------------------
E3E4: 22 20       BHI   $E406
E3E6: 24 22       bcc   $E40A
E3E8: 20 23       bra   $E40D

E3EA: 22 20       BHI   $E40C
E3EC: 22 22       BHI   $E410
E3EE: 20 31       bra   $E421

E3F0: 22 20       BHI   $E412
E3F2: 21          --------------------
E3F3: 23 30       BLS   $E425
E3F5: 20 21       bra   $E418

E3F7: 92 38       SBCA  $0038
E3F9: 3E          --------------------
E3FA: 3F          SWI   
E3FB: 26 F5       bne   $E3F2
E3FD: 2E C0       BGT   $E3BF
E3FF: 2D 3F       BLT   $E440
E401: 26 FF       bne   $E402
E403: 37          PSHB  
E404: 2D 3F       BLT   $E445
E406: 26 FF       bne   $E407
E408: 24 2D       bcc   $E437
E40A: 3F          SWI  


switchtable
E40B: 93          --------------------
E40C: D3          --------------------
E40D: 5A          decb  
E40E: 71          --------------------
E40F: D1 3F       CMPB  $003F
E411: 71          --------------------
E412: D1 3E       CMPB  $003E
E414: F2 F8 0A    SBCB  $F80A
E417: F2 F8 0A    SBCB  $F80A
E41A: F2 F8 0A    SBCB  $F80A
E41D: 71          --------------------
E41E: E7 30       stab   $30,X
E420: 71          --------------------
E421: D1 1B       CMPB  $001B
E423: 11          CBA   
E424: D7 C7       stab   $00C7
E426: 11          CBA   
E427: D7 C7       stab   $00C7
E429: 11          CBA   
E42A: D7 C7       stab   $00C7
E42C: 11          CBA   
E42D: D7 C7       stab   $00C7
E42F: 11          CBA   
E430: D7 C7       stab   $00C7
E432: 11          CBA   
E433: D7 C7       stab   $00C7
E435: 11          CBA   
E436: D7 C7       stab   $00C7
E438: 11          CBA   
E439: D7 C7       stab   $00C7
E43B: 91 D7       cmpa  lastsound
E43D: 94 11       anda  $0011
E43F: D7 9E       stab   $009E
E441: 11          CBA   
E442: D7 A2       stab   $00A2
E444: 8F          --------------------
E445: D7 28       stab   $0028
E447: 8F          --------------------
E448: D7 28       stab   $0028
E44A: 8F          --------------------
E44B: D7 28       stab   $0028
E44D: 8F          --------------------
E44E: D7 28       stab   $0028
E450: 8F          --------------------
E451: D7 28       stab   $0028
E453: 8F          --------------------
E454: D7 28       stab   $0028
E456: 8F          --------------------
E457: D7 28       stab   $0028
E459: 8F          --------------------
E45A: D7 28       stab   $0028
E45C: 8F          --------------------
E45D: D7 28       stab   $0028
E45F: 11          CBA   
E460: D7 C3       stab   sw_encoded
E462: 11          CBA   
E463: D7 BF       stab   sys_temp2


E465: 91 D7       cmpa  lastsound
E467: 8A B3       oraa   #B3
E469: DD          --------------------
E46A: 9B 94       ADDA  $0094
E46C: D5 47       BITB  $0047
E46E: 94 D5 47  


switchtable_end



E471: 3D          WAI   

E472: 3E          --------------------
E473: 36          psha  
E474: 37          PSHB  
E475: 38          --------------------
E476: 39          rts   

E477: 3F          SWI   
E478: 40          NEGA  
E479: 41          --------------------
E47A: 42          --------------------
E47B: 46          RORA  
E47C: 47          ASRA  
E47D: 36          psha  
E47E: 37          PSHB  
E47F: 38          --------------------
E480: 39          rts   

E481: 3F          SWI   
E482: 40          NEGA  
E483: 41          --------------------
E484: 42          --------------------
E485: 00          --------------------
E486: 3D          WAI   

E487: 3E          --------------------
E488: 00          --------------------
E489: 06          TAP   
E48A: 0C          CLC   
E48B: 12          --------------------
E48C: 18          --------------------
E48D: 1E          --------------------
E48E: 24 2A       bcc   $E4BA
E490: 30          TSX   
E491: 47          ASRA  
E492: 46          RORA  
E493: 00          --------------------
E494: 06          TAP   
E495: 07          TPA   
E496: 01          NOP   
E497: 02          --------------------
E498: 03          --------------------
E499: 04          --------------------
E49A: 19          DAA   
E49B: 17          TBA   
E49C: 16          tab   
E49D: 15          --------------------
E49E: 13          --------------------
E49F: 12          --------------------
E4A0: 05          --------------------
E4A1: 14          --------------------
E4A2: 0C          CLC   
E4A3: 0F          SEI   
E4A4: 13          --------------------
E4A5: 15          --------------------
E4A6: E5 93       BITB  $93,X
E4A8: E5 8D       BITB  switch_pending,X
E4AA: E5 C2       BITB  $C2,X
E4AC: E5 DD       BITB  $DD,X
E4AE: E5 EA       BITB  $EA,X
E4B0: E5 E4       BITB  $E4,X
E4B2: E5 F0       BITB  $F0,X
E4B4: 01          NOP   
E4B5: 02          --------------------
E4B6: 03          --------------------
E4B7: 04          --------------------
E4B8: 19          DAA   
E4B9: 17          TBA   
E4BA: 16          tab   
E4BB: 15          --------------------
E4BC: 05          --------------------
E4BD: 06          TAP   
E4BE: 07          TPA   
E4BF: 08          inx   
E4C0: 09          DEX   
E4C1: 0A          CLV   
E4C2: 0B          SEV   
E4C3: 0C          CLC   
E4C4: 0D          SEC   
E4C5: 0E          CLI   
E4C6: 0F          SEI   
E4C7: 10          SBA   
E4C8: 12          --------------------
E4C9: 13          --------------------
E4CA: 14          --------------------

character_defs
E4CB: .dw $0000   ;Space
E4CD: .dw $3706   ;A
E4CF: .dw $8F14   ;B 
E4D1: .dw $3900   ;C 
E4D3: .dw $8F10   ;D 
E4D5: .dw $3902   ;E 
E4D7: .dw $3102   ;F 
E4D9: .dw $3D04   ;G 
E4DB: .dw $3606   ;H 
E4DD: .dw $8910   ;I 
E4DF: .dw $1E00   ;J 
E4E1: .dw $3023 	;K
E4E3: .dw $3800   ;L 
E4E5: .dw $7601 	;M
E4E7: .dw $7620 	;N
E4E9: .dw $3F00   ;O 
E4EB: .dw $3306   ;P 
E4ED: .dw $3F20	;Q
E4EF: .dw $3326	;R
E4F1: .dw $2D06   ;S 
E4F3: .dw $8110   ;T 
E4F5: .dw $3E00   ;U 
E4F7: .dw $3009   ;V   
E4F9: .dw $3628   ;W
E4FB:	.dw $4029	;X
E4FD:	.dw $2216   ;Y   
E4FF: .dw $0909   ;Z   
E501: .dw $3F09         
E503: .dw $8010   
E505: .dw $0B0C          
E507: .dw $0D05          
E509: .dw $2606       
E50B: .dw $2922       
E50D: .dw $3D06          
E50F: .dw $0700          
E511: .dw $3F06          
E513: .dw $2F06       
E515: .dw $8200       
E517: .dw $0006 
E519: .dw $4020
E51B:	.dw $8010    
E51D: .dw $0009          
E51F: .dw $BB04
E521:	.dw $8016          
E523: .dw $C03F       
E525: .dw $0025	;*
E527:	.dw $0800   
       
; WILLIAMS
msg_williams	.db $28,$17,$09,$0C,$0C,$09,$01,$0D,$13 
; ELECTRONICS
msg_electronics 	.db $0B,$05,$0C,$05,$03,$14,$12,$0F,$0E,$09,$03,$13          
; PRESENTS
msg_presents 	.db $28,$10,$12,$05,$13,$05,$0E,$14,$13
; HYPERBALL
msg_hyperball 	.db $19,$08,$19,$10,$05,$12,$02,$01,$0C,$0C
; CREDIT
msg_credit		.db $16,$03,$12,$05,$04,$09,$14   
; PLAYER      
msg_player 		.db $26,$10,$0C,$01,$19,$05,$12    
; GAME
msg_game		.db $05,$00,$07,$01,$0D,$05  
; OVER 
msg_over		.db $05,$0F,$16,$05,$12,$00
; CRITICAL
msg_critical	.db $28,$03,$12,$09,$14,$09,$03,$01,$0C 
; WAVE        
msg_wave		.db $24,$17,$01,$16,$05
; COMPLETED
msg_completed: 	.db $19,$03,$0F,$0D,$10,$0C,$05,$14,$05,$04
; * SPELL *
msg_spell		.db $19,$2C,$00,$13,$10,$05,$0C,$0C,$00,$2C
; BONUS
msg_bonus		.db $05,$02,$0F,$0E,$15,$13 
; ENERGY
msg_energy		.db $06,$05,$0E,$05,$12,$07,$19    
; YOU MISSED
msg_youmissed	.db $0A,$19,$0F,$15,$00,$0D,$09,$13,$13,$05,$04  
; REFLEX   
msg_reflex		.db $06,$12,$05,$06,$0C,$05,$18   
; HIT
msg_hit		.db $03,$08,$09,$14
; 
E5B0: .db $15,$1E,$26,$45,$55,$00 
;         
E5B6: .db $15,$1E,$26,$5A,$42,$00  
;         
E5BC: .db $05,$24,$9B,$1B,$1B,$1B   
; HYPER      
E5C2: .db $05,$08,$19,$10,$05,$12 
; E UNIT 
E5C8: .db $07,$05,$26,$15,$0E,$09,$14,$00   
; *_SSR__EJS_*     
E5D0: .db $0C,$2C,$00,$13,$13,$12,$00,$00,$05,$0A,$13,$00,$2C 
; CANNON
E5DD: .db $06,$03,$01,$0E,$0E,$0F,$0E    
; ALIEN
E5E4: .db $05,$01,$0C,$09,$05,$0E 
; LASER    
E5EA: .db $05,$0C,$01,$13,$05,$12 
; RAY    
E5F0: .db $03,$12,$01,$19
; *_TILT_*
E5F4: .db $28,$2C,$00,$14,$09,$0C,$14,$00,$2C
; GREAT REFLEX
E5FD: .db $0C,$07,$12,$05,$01,$14,$00,$12,$05,$06,$0C,$05,$18   
; ENTER YOUR
E60A: .db $0A,$05,$0E,$14,$05,$12,$00,$19,$0F,$15,$12
; INITIALS  
E615: .db $08,$09,$0E,$09,$14,$09,$01,$0C,$13 
; GREAT SCORE
E61E: .db $0B,$07,$12,$05,$01,$14,$00,$13,$03,$0F,$12,$05  
; HY SCORE
E62A: .db $28,$08,$19,$00,$13,$03,$0F,$12,$05    

E633: 1B          ABA   
E634: 95 21       BITA  $0021
E636: A7 A2       staa   $A2,X
E638: 9C 96       CPX   $0096
E63A: 8F          --------------------
E63B: 1A          --------------------
E63C: A0 AD       SUBA  $AD,X
E63E: A8 90       EORA  $90,X
E640: 89 14       ADCA  #14
E642: A6 B3       ldaa   $B3,X
E644: AE 8A       LDS   $8A,X
E646: 83          --------------------
E647: 0E          CLI   
E648: AC A9       CPX   $A9,X
E64A: A3          --------------------
E64B: 9D          --------------------
E64C: 97 91       staa   $0091
E64E: 84 B4       anda  #B4
E650: 08          inx   
E651: B2 B5 AF    SBCA  $B5AF
E654: 8B 85       ADDA  #85
E656: 02          --------------------
E657: CE CF C8    ldx   #CFC8
E65A: CB 93       ADDB  #93
E65C: 99 1F       ADCA  $001F
E65E: CD          --------------------
E65F: CC          --------------------
E660: C9 CA       ADCB  #CA
E662: 81 87       cmpa  #87
E664: 8D A5       bsr   $E60B
E666: AB 31       ADDA  $31,X
E668: C7          --------------------
E669: C3          --------------------
E66A: C2 BA       SBCB  #BA
E66C: B9 3E C6    ADCA  $3EC6
E66F: C4 C1       andb  #C1
E671: B8 BB BD    EORA  $BBBD
E674: 92 98       SBCA  $0098
E676: 1E          --------------------
E677: A4 AA       anda  $AA,X
E679: B0 C5 BF    SUBA  $C5BF
E67C: B6 B7 BC    ldaa   $B7BC
E67F: 80 86       SUBA  #86
E681: 0C          CLC   
E682: B6 3F B7    ldaa   $3FB7
E685: 40          NEGA  
E686: B8 C1 CA    EORA  $C1CA
E689: 4D          TSTA  
E68A: C9 CC       ADCB  #CC
E68C: 85 8B       BITA  #8B
E68E: 91 97       cmpa  $0097
E690: 9D          --------------------
E691: A3          --------------------
E692: A9 AF       ADCA  $AF,X
E694: 35          TXS   
E695: C8 CB       EORB  #CB
E697: 84 8A       anda  #8A
E699: 90 96       SUBA  $0096
E69B: 9C A2       CPX   $00A2
E69D: A8 AE       EORA  $AE,X
E69F: 34          DES   
E6A0: C2 CF       SBCB  #CF
E6A2: B9 4E 83    ADCA  $4E83
E6A5: 89 8F       ADCA  #8F
E6A7: 95 9B       BITA  $009B
E6A9: A1 A7       cmpa  $A7,X
E6AB: AD 33       jsr   $33,X
E6AD: BA C3 82    oraa   $C382
E6B0: 88 8E       EORA  #8E
E6B2: 94 9A       anda  $009A
E6B4: A0 A6       SUBA  $A6,X
E6B6: AC 32       CPX   $32,X
E6B8: BB 44 C6    ADDA  $44C6
E6BB: C7          --------------------
E6BC: BC 81 87    CPX   $8187
E6BF: 8D 93       bsr   $E654
E6C1: 99 9F       ADCA  $009F
E6C3: A5 AB       BITA  $AB,X
E6C5: 31          INS   
E6C6: BD C5 3E    jsr   $C53E
E6C9: 80 86       SUBA  #86
E6CB: 8C 92 98    CMPX  #92
E6CE: 9E A4       LDS   $00A4
E6D0: AA 30       oraa   $30,X
E6D2: 96 05       ldaa   $0005
E6D4: 16          tab   
E6D5: 84 0F       anda  #0F
E6D7: 8B 1B       ADDA  #1B
E6D9: DE B8       ldx   temp1
E6DB: A7 02       staa   $02,X
E6DD: BD EC 32    jsr   split_ab
E6E0: 5D          TSTB  
E6E1: 27 02       beq   $E6E5
E6E3: CB 1B       ADDB  #1B
E6E5: E7 01       stab   $01,X
E6E7: 39          rts   

E6E8: CE 13 A7    ldx   #13A7
E6EB: DF B8       stx   temp1
E6ED: 8D E3       bsr   $E6D2
E6EF: 86 08       ldaa   #08
E6F1: A7 00       staa   $00,X
E6F3: 86 13       ldaa   #13
E6F5: A7 08       staa   $08,X
E6F7: 6F 03       CLR   $03,X
E6F9: CE 13 AB    ldx   #13AB
E6FC: DF B8       stx   temp1
E6FE: CE E5 74    ldx   #msg_wave
E701: BD D3 0D    jsr   $D30D
E704: BD D2 B0    jsr   $D2B0
E707: 5F          clrb  
E708: 86 04       ldaa   #04
E70A: BD D2 C8    jsr   $D2C8
E70D: CE 13 A7    ldx   #13A7
E710: 7E D2 58    jmp   $D258

;**************************************
;* Main Entry from Reset
;**************************************
reset			sei	
			lds	#pia_ddr_data-1		;Point stack to start of init data
			ldab	#$0C				;Number of PIA sections to initialize
			ldx	#pia_sound_data		;Start with the lowest PIA
			ldaa	#$04
			staa	pia_control,X		;Select control register
			ldaa	#$7F				
			staa	pia_pir,X
			stx	temp1
			cpx	temp1
			ifeq
				begin
nxt_pia				ldx	temp1			;Get next PIA address base
					begin
						clr	pia_control,X	;Initialize all PIA data direction registers
						pula				;Get DDR data
						staa	pia_pir,X
						pula	
						staa	pia_control,X	;Get Control Data
						cpx	#pia_sound_data	;This is the last PIA to do in shooter games
						ifne
							clr	pia_pir,X		;If we are on the sound PIA, then clear the PIR 
						endif
						inx	
						inx	
						decb	
						beq	init_done
						bitb	#$01
					eqend
					ldaa	temp1			;Get current PIA address MSB
					asla	
					anda	#$1F			;Move to next PIA
					ifeq
						ldaa	#$40
						staa	temp1
						bra	nxt_pia
					endif
					oraa	#$20
					staa	temp1			;Store it
				loopend
			endif
			jmp	diag					;NMI Entry

;***************************************************
;* System Checksum #1: Set to make ROM csum from
;*                     $E000-$EFFF equal to $00
;***************************************************		
	
csum1	.db $C0 	 


;***************************************************************
;* PIA initialization is done now, set up the vm etc.
;***************************************************************			
init_done		ldx	#$13FF				;\
			txs						;|
			begin						;|
				clr	$00,X				;Clear RAM 1000-13FF
				dex					;|
				cpx	#$0FFF			;|
			eqend						;/
			jsr	setup_vm_stack			;Initially Set up the VM
			ldaa	gr_lampflashrate			;Get Lamp Flash Rate
			staa	lamp_flash_rate
			ldx	#switch_queue
			stx	switch_queue_pointer
			ldx	#sol_queue				;Works from top down
			stx	solenoid_queue_pointer		;Set up Solenoid Buffer Pointer
			ldx	#adj_cmoscsum			;CMOS Checksum
			jsr	cmosinc_a				;CMOS,X++ -> A
			jsr	cmosinc_b				;CMOS,X++ -> B
			aba	
			cmpa	#$57					;CSUM CMOS RAM
			ifne
clear_all			jsr	factory_zeroaudits		;Restore Factory Settings and Zero Audit Totals
			endif
			ldx	#aud_currentcredits		;Current Credits
			jsr	cmosinc_a				;CMOS,X++ -> A
			staa	cred_b0
			jsr	cmos_a				;CMOS, X -> A Audit 50 Command
			clr	$00,X
			clr	$01,X
			cmpa	#$15					;Auto-Cycle?
			ifeq
				ldx	#st_autocycle			;Set-Up Auto Cycle Mode
				jsr	newthread_06			;Push VM: Data in A,B,X,$A6,$A7,$AA=#06
			endif
			cmpa	#$45
			beq	clear_all				;Restore Factory Setting/Zero Audits
			cmpa	#$35
			ifeq						;Zero Audits
				jsr	reset_audits			;(Reset Audits 0100-0165)
			endif
			jsr	coinlockout				;Check Max Credits, Adjust Coin Lockout If Necessary
			dec	switch_debounced
			jsr	clear_displays			;Blank all Player Displays (buffer 0)
			staa	score_p1_b0+3			;Set player one score to '00'
			cli	
			ldx	gr_reset_hook_ptr
			jsr	$00,X					;jsr GameROM
			ldx	#powerup_init			;Jump to Game Over Mode
			jsr	newthread_06			;Start the thread
			jmp	check_threads			;Run the loop
			
;************************************************************************************
;* Begin Main Loop - This is the end of all initialization and the start of the loop
;*                   that runs consistently to support the VM.
;************************************************************************************
main			ldx	#vm_base
			stx	vm_tail_thread			;Current VM Routine being run
			stx	current_thread			;Current VM Routine being run
			ldx	gr_main_hook_ptr
			jsr	$00,X					;Game ROM:Main Loop Hook
			sei	
			ldaa	irqcount16				;IRQ Counter, Incremented every 16 IRQ's
			clr	irqcount16				;Reset the counter
			cli	
			staa	irqcount				;Put the data into counter holder, use later
			ldaa	flags_selftest			;See if we are in test mode
			ifne
				jmp	vm_irqcheck				;If so, then skip a bunch of stuff...
			endif
			ldaa	pia_disp_digit_ctrl		;Check the Advance Switch
			ifmi
				ldx	#selftest_entry
				jsr	newthread_06			;Create the diagnostics thread
			endif
checkswitch		ldx	#0000
			begin
				ldaa	switch_b4,X
				coma	
				anda	switch_pending,X
				ifne
					jsr	check_sw_close				;Switch Closed?
				endif
				ldaa	switch_b4,X
				anda	switch_aux,X
				ifne
					jsr	check_sw_open				;Switch Open?
				endif
				inx	
				cpx	#$0008
			eqend
time			ldab	flag_timer_bip			;Ball Timer Flag
			ifne
				ldaa	irqcount				;Number of IRQ's since last
				ldx	minutetimer
				jsr	xplusa				;X = X + A
				stx	minutetimer
				cpx	#irq_per_minute
				bmi	switches				;Not 1 minute yet
				clrb	
				stab	minutetimer				;Clear the Minute Timer
				stab	minutetimer+1
				ldx	#aud_avgballtime			;AUD: Ball time in Minutes
				jsr	ptrx_plus_1				;Add 1 to data at X
			endif
switches		ldx	#switch_queue
next_sw		cpx	switch_queue_pointer		;Check Buffer Pointer
			ifne
				ldaa	$00,X					;Command Timer
				suba	irqcount				;Subtract our IRQ's
				iflo						;Ready to run?
					stx	sys_temp_w3				;Yes!
					ldaa	$01,X					;Encoded Switch #
					staa	sw_encoded
					clr	sys_temp1
					tab	
					asrb	
					asrb	
					asrb	
					stab	sys_temp2
					jsr	hex2bitpos				;Convert Hex (A&07) into bitpos (B)
					stab	sys_temp3
					ldx	sys_temp1
					ldaa	switch_debounced,X
					staa	sys_temp5
					jsr	sw_down
					ldx	sys_temp_w3
					bcc	sw_break
					jsr	copy_word				;Copy Word: $96--  Data,$96 -> Data,X
					bra	next_sw
				endif
				staa	$00,X
sw_break			inx	
				inx	
				bra	next_sw
			endif
;Entry here if we are in auto-cycle mode...						
vm_irqcheck		ldx	vm_base				;Check the start of the vm loop
			begin
				beq	flashlamp
				ldaa	$02,X
				suba	irqcount			;Subtract the number of IRQ loops completed
				ifcs
					clra					;Clear it so it can be run next loop
				endif
				staa	$02,X
				ldx	$00,X
			loopend
flashlamp		ldaa	lamp_flash_count		;Timer for Flashing Lamps
			suba	irqcount			;Subtract the IRQ's
			iflo
				ldx	#ram_base
				ldab	#$0C				;12 rows in Hyperball games, instead of 8
				begin
					ldaa	lampbuffer0,X			;Invert Selected Lamps.
					eora	lampflashflag,X
					staa	lampbuffer0,X
					inx	
					decb	
				eqend
				ldaa	lamp_flash_rate		;Get Reset Value
			endif
			staa	lamp_flash_count			;Reset the Lamp Timer
solq			ldaa	solenoid_counter			;Solenoid Counter
			ifeq						;Skip if Counter hasnt Expired
				ldx	#sol_queue				;Start at bottom of Queue
				cpx	solenoid_queue_pointer		
				ifne						;Do we have any to do?
					ldaa	$00,X					;Takes lowest Solenoid # into A
											;We only do 1 solenoid at a time
					begin
						ldab	$01,X					;Moves the rest down into place
						stab	$00,X
						inx	
						cpx	solenoid_queue_pointer
					eqend
					dex	
					stx	solenoid_queue_pointer		;Adjust Pointer to end of list
					jsr	set_solenoid			;Turn On/Off Solenoid (Solenoid # in A)
				endif
			endif
snd_queue		ldaa	sys_soundflags			;Sound Flag??
			ifne						;If not zero, time to check for the score queue sound/pts
				ldaa	cur_sndflags
				bita	#$10					;Is this an immediate or timed sound?
				ifne
					ldab	pia_comma_data			;Do immediate, but only if sound board is not busy.
					andb	#$20
					beq	check_threads			;Get Outta Here
				else
					ldaa	soundirqcount+1			;LSB Sound IRQ Counter
					suba	irqcount				;Subtract the number of IRQ's that have cycled
					staa	soundirqcount+1
					ldaa	soundirqcount			;Update the counter
					sbca	#$00
					staa	soundirqcount			;Carry over to MSB of couter as well
					bcc	check_threads			;Leave if counter has not gone under zero.
				endif
				ldaa	#$7F
				jsr	send_snd			;Send A->Sound Board (mute?)
				ldaa	cur_sndflags		;Is this a simple sound
				ifpl					;yes
					dec	soundcount
					beq	_sndnext			;Sound Repeat Counter
					ldab	sys_soundflags		;
					ifpl
						ldx	soundindex_com
						stx	soundirqcount
						ldaa	lastsound
						jsr	send_snd_save		;Send the Command, Save in 'lastsound'
						bra	check_threads		;Get Outta here.
					endif
					oraa	#$80
					staa	cur_sndflags		;make it a complex sound now.
					ldx	soundindex_com
					stx	soundptr
				endif
				jsr	do_complex_snd
				bra	check_threads		;Get Outta Here.
_sndnext			ldab	next_sndcnt			;Here if we are done iterating the sound command.
				ifne			;Check the scoring queue
					ldaa	next_sndcmd
					jsr	isnd_mult			;Play Sound Index(A),(B)Times
					clr	next_sndcnt
					bra	check_threads		;Get Outta Here.
				endif
			endif
doscoreq		clr	sys_soundflags		;Reset the Sound Flag??
			ldx	#$1127			;See if there is something in this stack
			ldaa	#$08
			begin
				inx	
				deca	
				bmi	check_threads		;Nuttin' Honey, Skip this Sound Crap!
				ldab	$00,X
			neend					;Nuttin' Honey, Check next Entry!
			dec	$00,X				;Re-Adjust the Sound Command So Sound #00 will still work!
			oraa	#$08
			jsr	dsnd_pts			;Add Points(A),Play Digit Sound

check_threads	ldx	#vm_base
			begin
nextthread			ldx	$00,X				;Check to see if we have a routine to do?
				ifeq
					jmp main				;Back to the start of the main loop
				endif
				ldaa	$02,X				;Timer expired?
			eqend					;No, goto next one.
			stx	current_thread		;Yes, lets do this one now.
			stx	vm_tail_thread		;Current VM Routine being run
			ldaa	$03,X
			psha	
			ldaa	$04,X
			psha	
			ldaa	$05,X
			psha	
			ldaa	$06,X
			psha
			ldab	$07,X
			psha
			ldx	$08,X
			psha
			ldx	$09,X
			psha
			ldx	$0A,X
			psha
			ldx	$0C,X
			psha
			ldx	$0B,X
			psha
			ldaa	$0E,X
			ldab	$0F,X
			ldx	$10,X
			rts					;Jump to the offending routine.

;**************************************************************************
;* This is similar to 'addthread' below but the timer data does not follow
;* the jsr. Instead, the timer data is pre-loaded into 'thread_timer_byte'.
;* The thread is started in the same manner as described below.
;**************************************************************************			
delaythread		staa	temp2				;Routine returns here when done
			stx	temp1
			ldaa	thread_timer_byte
			tsx					;Get where we came from
			ldx	$00,X				;Get the address of the new thread
			bra	dump_thread

;**************************************************************************
;* Adds a new thread to the VM. The data for this routine is contained 
;* directly after the jsr to this routine. A single byte follows the
;* jsr and is the timer byte used for the delay until the thread starts.
;* The actual address directly after the timer byte is where the thread
;* will start running. Example:
;*
;* 	jsr addthread
;*    .db 05		;This is the timer byte
;*	ldaa #FF		;This code is executed as the thread.
;***************************************************************************
addthread		stx	temp1
			staa	temp2
			tsx	
			ldx	$00,X				;Return Address from rts to $EA2F
			ldaa	$00,X				;New Timer Value
			inx	

;**************************************************************************
;* Will take all variables in RAM and dump them into the thread data 
;* structure for next time. This gives the thread memory over executions
;* until it is killed.
;**************************************************************************			
dump_thread		stx	temp3				;Now X points the the replacement address
			ldx	current_thread		;Current VM Routine being run
			staa	$02,X				;Timer For next Time
			ldaa	temp3
			staa	$0B,X
			ldaa	temp3+1
			staa	$0C,X
			stab	$0F,X
			ldaa	temp2
			staa	$0E,X
			ldaa	temp1
			staa	$10,X
			ldaa	temp1+1
			staa	$11,X
			ins	
			ins	
			staa	$0A,X
			pula
			staa	$09,X
			pula
			staa	$08,X
			pula
			staa	$07,X
			pula
			staa	$06,X
			pula
			staa	$05,X
			pula
			staa	$04,X
			pula
			staa	$03,X
			ldx	current_thread			;Current VM Routine being run
			begin
				lds	#$13F7			;Restore the stack.
				bra	nextthread			;Go check the Control Routine for another job.
killthread			ldx	#vm_base
				begin
					stx	temp2					;Thread that points to killed thread
					ldx	$00,X
					ifeq
						jmp	check_threads			;Nothing on VM
					endif
					cpx	current_thread			;Current VM Routine being run
				eqend						;If $B1 != *$00AD check next entry
				bsr	killthread_sp			;Remove Entry (X)($B1) From VM
			loopend
			
;****************************************************************************
;* This is the main routine in charge of adding new threads to the
;* virtual machine. The following variables are passed.
;*
;*	A: Pushed into VMregA
;* 	B: Pushed into VMregB
;*	X: Thread Initial Program Counter
;* 	
;* In addition, the following two variables contain data for the
;* thread.
;*	thread_priority:		Unique Identifier to classify thread
;*	system_temp_word2:	???
;*
;* See header definition file for specifics on thread class structure
;*
;* Returns: Carry Cleared if New Thread was added
;*          Carry Set if VM was full
;*
;**************************************************************************** 
newthread_sp	stx	temp1
			sec	
			ldx	vm_nextslot			;Get Next Available Slot Address
			ifne
				psha	
				ldaa	$00,X				;\
				staa	vm_nextslot			;|---- Set New Next Available Slot Address
				ldaa	$01,X				;|
				staa	vm_nextslot+1		;/
				stx	temp2				;Temp2 = New Thread Base Address
				ldx	vm_tail_thread		;This is the last thread in the vm, it has the tail
				ldaa	$00,X				;\
				staa	temp3				;|
				ldaa	$01,X				;|---- Store the running threads next pointer in temp3
				staa	temp3+1			;/
				ldaa	temp2				;\
				staa	$00,X				;|
				ldaa	temp2+1			;|---- Put the new thread into the running threads next pointer
				staa	$01,X				;/
				ldx	$00,X
				stx	vm_tail_thread		;Make the new thread the last thread
				ldaa	temp3				;\
				staa	$00,X				;|
				ldaa	temp3+1			;|---- Set the Next pointer of the new thread to the 
				staa	$01,X				;/     previous threads next pointer.
				ldaa	temp1
				staa	$0B,X
				ldaa	temp1+1
				staa	$0C,X
				ldaa	thread_priority		;Store the priority
				staa	$0D,X
				ldaa	sys_temp_w2			;Push variables from sys_temp_w2
				staa	$10,X
				ldaa	sys_temp_w2+1
				staa	$11,X
				pula	
				staa	$0E,X				;Store reg A
				stab	$0F,X				;Store reg B
				clr	$02,X				;Reset the counter
			endif
			rts	

newthread_06	psha	
			ldaa	#$06
			staa	thread_priority
			pula	
			bra	newthread_sp			;Push VM: Data in A,B,X,threadpriority,$A6,$A7

;***************************************************************************
;* This will remove the current thread from the VM. 
;*
;* Requires: temp2 holds the thread that points to the thread to be killed	
;***************************************************************************		
killthread_sp	psha	
			ldaa	$00,X					;\
			staa	temp1					;|--  Get 'next'
			ldaa	$01,X					;|
			staa	temp1+1				;/
			ldaa	vm_nextslot				;\
			staa	$00,X					;|--  Kill this one by setting next to 0
			ldaa	vm_nextslot+1			;|
			staa	$01,X					;/
			stx	vm_nextslot				;Make this new blank spot the next one
			cpx	vm_tail_thread			;Unless this was the tail thread
			ifeq
				ldx	current_thread			;Make the current thread the tail
				stx	vm_tail_thread
			endif
			ldx	temp2					;Get Parent Thread
			ldaa	temp1					;Store killed thread 'next' into parents 'next'
			staa	$00,X
			ldaa	temp1+1
			staa	$01,X
			pula						;Save A
			rts	

;*************************************************
;* Kill Single thread with the given ID
;*
;* Requires: 	A - Level Defintion
;* 			B - Select Mask
;* 
;* If B is $00, then all threads are cleared
;*************************************************			
kill_thread		bsr	check_threadid		;Test Thread ID Mask
			ifcc					;Return with Carry Set
				bsr	killthread_sp		;Remove Entry (X)($B1) From VM
				clc	
			endif
			rts

;*************************************************
;* Kill All threads with the given ID
;*
;* Requires: 	A - Level Definition
;* 			B - Select Mask
;* 
;* If B is $00, then all threads are cleared
;*************************************************
kill_threads	begin
				bsr	kill_thread		;Kill first One
			csend				;Repeat if Carry Clear
			rts

;*************************************************
;* Checks the VM thread list for threads that 
;* qualify agains the bitmasks defined in A and B.
;* If a thread qualifies, then this routine will
;* return with carry cleared.
;*************************************************		
check_threadid	pshb	
			stab	temp1
			ldx	#vm_base		;Load Start Address
			stx	temp2			;Store it
			ldx	vm_base		;Load End Address
pri_next		sec	
			ifne				;Branch if we have reached the end of the VM (Next = 0000)
				tab	
				eorb	threadobj_id,X		;EOR with Type Code in Current Routine
				comb	
				andb	temp1
				cmpb	temp1
				ifne				;Branch if Bits Dont work
pri_skipme				stx	temp2
					ldx	threadobj_next,X
					bra	pri_next		;Goto Next Thread ->
				endif
				cpx	current_thread	;Make sure it isn't this thread
				beq	pri_skipme		;If it is this thread, skip it!
			endif
			pulb	
			rts	
	
;*****************************************************************	
;* Solenoid Queue Processing: This is the routine that is called
;* to fire a specific solenoid. It will add the solenoid to the 
;* queue. Works from top down. Solenoid Number is in A along with
;* data on how to handle solenoid. Format of A is ...
;*
;*  	XXXZZZZZ	Where: ZZZZZ is solenoid number 00-07
;*                       XXX is timer/command
;*
;* NOTE: Hyperball only allows 8 solenoids
;*****************************************************************		
solbuf		psha					;Push Solenoid #
			pshb	
			stx	temp1				;Put X into Temp1
			ldx	solenoid_queue_pointer	;Check Solenoid Buffer
			cpx	#sol_queue	
			ifne					;Buffer not full
				sec					;Carry Set if Buffer Full
				cpx	#sol_queue_end		;Buffer end
				ifne
_sb01					staa	$00,X				;Insert Solenoid Into Buffer
					inx	
					stx	solenoid_queue_pointer	;Update Pointer
_sb02					clc					;Carry Cleared on Buffer Add
				endif
				pulb	
				pula					;Pull Solenoid #
				ldx	temp1				;Get Back X
				rts	
			endif
			ldab	solenoid_counter		;Solenoid Counter
			bne	_sb01
			bsr	set_solenoid		;Turn On/Off Solenoid (Solenoid # in A)
			bra	_sb02

;***************************************************
;* Turns On/Off solenoid.
;*
;* Requires:	A - XXXXZZZZ
;*					
;* Where XXXX 	= Solenoid Timer/Command
;*       ZZZZ	= Solenoid Number
;*
;* Example: A = 20 turns on solenoid #00 for 2 IRQ's
;*              F8 turns on solenoid #08 idefinitely
;*              C3 turns on solenoid #03 for 12 IRQ's
;*              03 turns off solenoid #03 indefinitely
;***************************************************
set_solenoid	pshb	
			tab	
			andb	#$F0
			ifne
				cmpb	#$F0
				ifne
					;1-15 goes into counter
set_sol_counter			stab	solenoid_counter		;Restore Solenoid Counter to #E0
					bsr	soladdr			;Get Solenoid PIA address and bitpos
					stx	solenoid_address
					stab	solenoid_bitpos
				else
					;Do it now... if at 0
					bsr	soladdr			;Get Solenoid PIA address and bitpos
				endif
				bcs	set_ss_on			;Carry Set: Special Solenoid, these work in reverse
				;Here to turn solenoid ON
set_ss_off			sei	
				orab	$00,X
set_s_pia			stab	$00,X			;Write Solenoid Data to PIA
				cli	
				pulb	
				rts					;Outta here!
			endif
			bsr	soladdr				;Get Solenoid PIA address and bitpos
			bcs	set_ss_off				;Special Solenoids work in reverse
			;Here to turn solenoid OFF			
set_ss_on		comb	
			sei	
			andb	$00,X
			bra	set_s_pia				;Store it now.


EAD1: 84 0F       anda  #0F
EAD3: CE 22 02    ldx   #SOLENOID_PIA4_DATA_B
EAD6: 81 07       cmpa  #07
EAD8: 2F 0B       BLE   hex2bitpos	Convert Hex(A&07) into Bitpos(B)
EADA: 08          inx   
EADB: C6 08       ldab   #08
EADD: 11          CBA   
EADE: 26 04       bne   $EAE4
EAE0: CE 22 01    ldx   #SOLENOID_PIA4_CRTL_A
EAE3: 0D          SEC   
EAE4: 39          rts   


;*************************************************
;* Get Physical Address and Bitposition of 
;* solenoid number.
;*
;* Requires:	A - Solenoid Number
;* Output:		B - PIA bit position
;*			X - PIA address
;*************************************************	
soladdr		anda	#$0F				;Mask to under 16 Solenoids
			ldx	#pia_sol_low_data
			cmpa	#$07				;Normal solenoids or ball shooter/ball lift
			ifgt					;Get Regular Solenoid Address (PIA)
				inx
				ldab	#$08
				cba
				ifeq
					;this is the ball shooter coil
					ldx   #SOLENOID_PIA4_CRTL_A
					sec 
				endif
			endif
			rts	

;********************************************************
;* Convert Hex value in A to a single bit positioned at
;* the value of (A&7). Bitpos is returned in B
;*
;* Requires:	Data in A
;* Protects:	A,X
;* Destroys:	B
;* Output:		Bitpos in B
;********************************************************
hex2bitpos		psha	
			anda	#$07
			clrb	
			sec	
			begin
				rolb	
				deca	
			miend
			pula	
			rts	

;********************************************************
;* Checks the current score shown and updates the comma
;* flags accordingly to show the relavant ones.
;********************************************************			
comma_million	.db $40,$04,$80,$08
comma_thousand	.db $10,$01,$20,$02

update_commas	ldab	#$40				;Million digit
			bsr	test_mask_b			;Bittest Current Player Display Toggles against B
			ifeq					;Branch if it is already set
				ldx	pscore_buf			;Start of Current Player Score Buffer
				ldab	$00,X
				incb	
				ifne					;Is MSD at FF (blank0?
					ldx	#comma_million		;No.. we have a million digit.
					bsr	set_comma_bit		;Set the appropriate bit
				endif
			endif
			ldab	#$08				;1000's Digit
			bsr	test_mask_b			;Bittest Current Player Display Toggles against B
			ifeq
				ldx	pscore_buf			;Start of Current Player Score Buffer
				ldab	$02,X
				cmpb	#$F0
				ifcs
					ldx	#comma_thousand			;Get the appropriate bit for the thousand digit	
set_comma_bit			ldaa	player_up				;Current Player Up (0-3)
					jsr	xplusa				;X = X + A
					ldaa	$00,X
					oraa	comma_flags
					staa	comma_flags
				endif
			endif
			rts	
			

test_mask_b		ldaa	player_up				;Current Player Up (0-1)
			ldx	#dmask_p1
			jsr	xplusa				;X = X + A
			bitb	$00,X
			rts	


;**********************************************************
;* Point based sounds (chime type).
;**********************************************************			
isnd_pts		psha	
			tba	
			bra	snd_pts
dsnd_pts		psha	
			anda	#$07
snd_pts		jsr	isnd_once			;Play Sound Index(A) Once
			pula
			;Fall Through to points 

score_main		psha	
			pshb	
			dec	randomseed			;Change the Random # seed
			stx	x_temp_1			;Protect X
			jsr	gr_score_event		;Check Game ROM Hook
			ldab	random_bool
			ifeq
				com	random_bool
			endif
			bsr	score_update		;Add Points to Current Score, Data in A:
			bsr	update_commas		;Update Master Display Toggle From Current Player
			jsr	checkreplay			;Check Current Player Score against all Replay Levels
			ldx	x_temp_1			;Get it back
			pulb	
			pula	
			rts	
			

;**********************************************
; Update Score Routine: Score to add is in A
;**********************************************
score_update	ldx	pscore_buf			;Start of Current Player Score Buffer
			ldx	$00,X				;Get XX,XX_,b__
			stx	x_temp_2			;Store it!
			ldx	pscore_buf			;Start of Current Player Score Buffer
			ldab	#$04
			stab	flag_timer_bip		;Run Ball Play Timer (Audit)
			stab	sys_temp1			;Number of Ram Location to iterate (4)
			staa	sys_temp3
			clrb	
			stab	sys_temp4
			stab	sys_temp2
			tab					;Get Points data
			andb	#$07
_su01			bne	_su04
			incb	
			stab	temp3				;Store (data&07)+1
_su02			ldab	sys_temp3
			lsrb	
			lsrb	
			lsrb	
			bsr	score2hex			;Convert MSD Blanks to 0's on (X+03)
			begin
				adda	temp3				;(data&07)+1
				bsr	hex2dec			;Decimal Adjust A, sys_temp2 incremented if A flipped
				decb					
			eqend
_su03			ldab	sys_temp2
			beq	_su05			;A didn't Flip, Branch.
			staa	$03,X			;Store this digit
			dex	
			dec	sys_temp1			;Do next set of digits
			ifne
				bsr	score2hex				;Convert MSD Blanks to 0's on (X+03)
				clr	sys_temp2
				aba	
				bsr	hex2dec				;Decimal Adjust A, sys_temp2 incremented if A flipped
				bra	_su03
_su04				decb	
				ifeq
					ldab	#$10
					stab	temp3
					bra	_su02
				endif
				bsr	score2hex				;Convert MSD Blanks to 0's on (X+03)
				staa	$03,X
				dec	sys_temp1
				dex	
				decb	
				bra	_su01
_su05				ldab	sys_temp4
				ifne
					cmpa	#$10
					ifcs
						adda	#$F0
					endif
				endif
				staa	$03,X
			endif
			rts	

;******************************************************************************
; Convert Hex to Decimal: If value was above 9 then sys_temp2 is incremented 
;******************************************************************************
hex2dec		daa	
			ifcs
				inc	sys_temp2
			endif
			rts	

score2hex		ldaa	$03,X
			inca	
			ifne					;Leave if both digits are blanked
				deca	
				cmpa	#$F0
				bcs	sh_exit			;if A was less than #F0
				adda	#$10				;Set High Digit to a 0
			endif
			inc	sys_temp4			;Digit was cleared
sh_exit		rts 

;**************************************************************
;* Add points to Scoring Queue
;**************************************************************	
add_points		psha	
			pshb	
			tab	
			andb	#$07
			ldx	#score_queue_end	
			begin
				dex	
				decb	
			miend
			lsra	
			lsra	
			lsra	
			adda	$00,X
			staa	$00,X
			pulb	
			pula	
			rts	
 
;**********************************************************
;* Checks the current player score against the energy base
;* award level multiplier. 
;**********************************************************
checkreplay		ldx	#x_temp_2
			bsr	get_hs_digits		;Put Player High Digits into A&B, convert F's to 0's
			stab	x_temp_2
			ldx	pscore_buf			;Current Player Score Buffer Pointer
			bsr	get_hs_digits		;Put Player High Digits into A&B, convert F's to 0's
			nop
			nop
			nop
			nop
			jsr	get_aud_baseawd		;loads the P1 or P1 audit location for base awards
			jsr	cmosinc_a
			cba
			iflo
				stx	thread_priority
				nop
				nop
				nop
				nop
				nop
				nop
				ldx	#0152
				nop
				jsr	ptrx_plus_1			;add 1 to address in X
				ldx	thread_priority
				jsr	award_special
			endif
			nop
			nop
			nop
			nop
			nop
			rts
			
;*********************************************************
;* Load Million and Hundred Thousand Score digits into
;* A and B. Player score buffer pointer is in X. Routine
;* will convert blanks($ff) into 0's
;*********************************************************			
get_hs_digits	ldaa	$00,X
			anda	#0F
			ldab	$01,X
			bsr	b_plus10		;If B minus then B = B + 0x10
			bsr	split_ab		;Shift A<<4 B>>4
			aba	
			tab
			cmpb	#A0
b_plus10		ifmi
				addb	#$10
			endif
			rts	
			
;*********************************************************
;* Shifts A and B to convert million and hundred thousand
;* score digits into a single byte.
;*********************************************************
split_ab		asla	
			asla	
			asla	
			asla	
			lsrb	
			lsrb	
			lsrb	
			lsrb	
			rts	 

;*********************************************************
;* Sound Routines 
;*********************************************************
;* isnd_once - will play index sound in A one time by 
;*             loading B with 01 and calling the main
;*             sound subroutine.
;*********************************************************			
isnd_once		pshb	
			ldab	#$01
			bsr	sound_sub
			pulb	
			rts

;*********************************************************
;* This is the main sound subroutine. It will play index
;* sound contained in A, B times.
;*********************************************************				
sound_sub		stx	thread_priority
			psha	
			pshb	
			ldab	sys_soundflags			;Sound Status
			beq	b_04E					;Goto Sound Routine #2
			tab						
			asla	
			aba	                              ;A=A*3
			ldx	gr_soundtable_ptr			;Game ROM Table: Sounds
			jsr	xplusa				;X = X + A
			ldaa	$02,X                         ;get the actual sound command that will be sent
			inca	
			ifeq						;If value is $FF, then this is complex sound
				ldx	$00,X
			endif
			ldaa	$00,X
			ldab	cur_sndflags
			bitb	#$40
			ifeq
				bsr	isnd_test				;If (A&0f)&(B&0f)=0) & (B&20=00) Then Set Carry
				ifcc
b_04E					pulb	
					pula	
					bra	b_051
				endif
			endif
b_050			tsta	
			bpl	snd_exit_pull			;pula,pulb,rts.
			ldab	next_sndcnt
			ifne
      			ldab	next_sndflags
      			bsr	isnd_test				;If (A&0f)&(B&0f)=0) & (B&20=00) Then Set Carry
      			bcs	snd_exit_pull			;pula,pulb,rts.
      		endif
			staa	next_sndflags
			pulb	
			pula	
			staa	next_sndcmd
			stab	next_sndcnt
			bra	snd_exit					;rts
			
isnd_test		psha	
			pshb	
			anda	#$0F
			andb	#$0F
			cba	
			pulb	
			pula	
			ifeq
				bitb	#$20
				ifeq
					sec
				endif
			endif
			rts
			
;A=sound command
;B=count
isnd_mult		stx	thread_priority
b_051			psha	
			pshb	
			stab	soundcount
			tab	                              ;store our sound in B temporarily
			ldaa	#$7F
			bsr	send_snd				;Send Sound Stop Command
			tba	                              ;get it back
			staa	soundindex				;Sound Command Table Index
			asla	
			aba						;Index * 3
			ldx	gr_soundtable_ptr			;Game ROM: Sound Table Pointer
isnd_mult_x		jsr	xplusa				;X = X + A
			ldaa	$02,X					;Sound Command
			cmpa	#$FF
			ifne						;Simple Sound
				ldab	$00,X
				andb	#$7F
				stab	cur_sndflags			
				ldab	$01,X
				stab	soundirqcount+1			
				clr	soundirqcount
				ldx	soundirqcount			;Clear the MSB of the word counter ($BD,$BE)
				stx	soundindex_com			;Store the whole counter in the Common Sound Index
				ldab	#$40
				stab	sys_soundflags			;Sound Flag?
				bsr	send_snd_save			;Send the Command, Save in 'lastsound'
			else						;Complex Sound
				ldx	$00,X					;Here if Complex Sound Command
				ldab	#$80
				stab	sys_soundflags			;Set Status Flag
				orab	$00,X
				stab	cur_sndflags
				inx	
				stx	soundindex_com
				stx	soundptr
				bsr	do_complex_snd			;Process it and send
			endif
snd_exit_pull	pulb	
			pula	
snd_exit		ldx	thread_priority
			rts	

;*****************************************************************
;* Send the command to the sound board, stores the command sent
;* in 'lastsound' for reference.
;*****************************************************************			
send_snd_save	staa	lastsound
send_snd		jsr	gr_sound_event			
			staa	pia_sound_data
			rts	

;*****************************************************************
;* This routine will send the next item in a complex sound
;* index to the Sound board PIA.
;*****************************************************************			
do_complex_snd	ldx	soundptr
_csnd_loop		ldaa	$00,X				;Load the first byte of this sequence
			tab	
			andb	#$C0
			ifne					;Check bits $80 or $40
				ifpl				;If bit $80 is set, then sound is immediate
					anda	#$3F
					staa	csound_timer
					inx	
					ldaa	$00,X
b_05B					staa	csound_timer+1
					ldaa	cur_sndflags
					anda	#$EF			;Flag this sound as non-immediate (timer based)
store_csndflg			staa	cur_sndflags	;Store Flag
					inx	
					bra	_csnd_loop
				endif
				clr	csound_timer
				anda	#$7F
				bne	b_05B			;If the timer is not zero, then flag this sound as non-immediate
				ldaa	cur_sndflags
				oraa	#$10			;Flag as non-immediate
				bra	store_csndflg
			endif
			bsr	send_snd_save		;Send the Command, Save in 'lastsound'
			inx	
			stx	soundptr			;Move pointer to next byte
			ldaa	$00,X
			cmpa	#$3F				;Are we done?
			ifeq
				ldaa	cur_sndflags		;Yes 
				anda	#$7F				;Mark it as a simple sound now
				staa	cur_sndflags
			endif
			ldx	csound_timer
			stx	soundirqcount
			rts	

;**********************************************************
;* This routine will check two of the switch flags in the
;* B register (byte 1 of switch table). If the switch 
;* is disabled for either flag (tilt and gameover) then
;* the routine returns with the carry flag set.
;**********************************************************			
check_sw_mask	psha	
			ldaa	gr_lastswitch			;Last Switch # for Game
			cmpa	sw_encoded				;Switch #
			ifgt						;Out of Range!
				bitb	#$40					;Flag 40: Active on Game Tilt
				ifeq
					tst	flag_tilt				;Tilt Flag
					bne	sw_ignore
				endif
				bitb	#$20					;Flag 20: Active on Game Over
				bne	sw_active
				tst	flag_gameover			;Game Over?
				beq	sw_active
			endif
sw_ignore		sec						;Ignore this switch when carry is set
sw_active		pula	
			rts

;**********************************************************
;* Switch is in down position, see if we should run it.
;**********************************************************			
sw_down		jsr	sw_tbl_lookup		;Loads X with pointer to switch table entry
			ldab	$00,X				;GAME ROM Switch Data 1(Flags,etc)
			ldaa	sys_temp5
			bita	sys_temp3
			beq	sw_dtime			;Is switch still down?
			bitb	#$08				;No, but check Flag 08 which is Instant Trigger
			ifne					;Not instant,.. leave now.
				bra	sw_trig_yes			;Must have been instant, do it now.	
sw_dtime			bitb	#$10				;Switch has been down enough, but is it enabled?
				ifne					;no.. leave now.
sw_trig_yes				bsr	check_sw_mask		;Checks Switch Flags for Tilt and Gameover and if switch is in range
					ifcc					;If not okay to run... leave
						clra	
						bitb	#$40				;Is it Active on Game Tilt?
						ifne					
							oraa	#$04				;Give this thread a different priority then
						endif
						staa	thread_priority
						ldaa	sw_encoded			;Switch # (encoded)
						ldx	$01,X
						bitb	#$07				;Was this a inline defined switch type? Type = 0
						ifeq					;Always?
							ldx	$02,X				;Get handler address at base pointer + 2
						endif
						tstb					;Is the handler code WML7 or Native?
						ifmi					;Minus = WML7
							stx	sys_temp_w2			;X = Handler Address
							ldx	#switch_entry		;Will put this routine into VM.
						endif
						jsr	gr_switch_event		;Game ROM switch event hook
						jsr	newthread_sp		;Push VM: Data in A,B,X,threadpriority,$A6,$A7
						bcs	_clc_rts			;Carry set if VM was full and thread not added
											;Exit now and don't mark switch as attended too.
					endif
				endif
			endif
			ldx	sys_temp1
			ldaa	sys_temp3
			eora	switch_debounced,X		;Clear Switch Matrix Flag (switch attended too)
			staa	switch_debounced,X
sw_proc		ldx	sys_temp1
			ldab	sys_temp3
			comb	
			tba	
			andb	switch_masked,X
			stab	switch_masked,X
			tab	
			andb	switch_pending,X
			stab	switch_pending,X
			tab	
			anda	switch_aux,X
			staa	switch_aux,X
			andb	switch_b4,X
			stab	switch_b4,X
			rts	
			
;****************************************************************************
;*
;****************************************************************************			
check_sw_close	stx	sys_temp1
			ldab	switch_debounced,X
			stab	sys_temp5				;Store 
			staa	sys_temp4
_sc01			bsr	getswitch				;Clear Carry if Switch Active or Done
			bcs	to_ldx_rts				;get outta here!
			bsr	sw_pack				;$A5 = ($A1<<3)+BitPos($A2)
			bsr	sw_get_time				;Gets Switch Trigger Data
			ifne						;If it is not 0 then we must time it
				adda	irqcount				;Number of IRQ's since last loop
				ldx	switch_queue_pointer
				cpx	#switch_queue_end
				beq	_sc01
				staa	$00,X
				ldaa	sw_encoded				;Encoded Switch Number
				staa	$01,X
				inx	
				inx	
				stx	switch_queue_pointer
				ldx	sys_temp1
				ldaa	switch_b4,X
				oraa	sys_temp3
				staa	switch_b4,X
				bra	_sc01
			endif
			jsr	sw_down				;Ready to do switch now!
			bra	_sc01
to_ldx_rts		ldx	sys_temp1
			rts
			
;****************************************************************************
;*
;****************************************************************************				
getswitch		clra	
			sec	
			ldab	sys_temp4			;Switch Data
			ifne
				begin
					rola	
					bita	sys_temp4
				neend
				staa	sys_temp3
				eora	sys_temp4
				staa	sys_temp4
_clc_rts			clc	
			endif
			rts 

;****************************************************************************
;* Takes the decimal representation of the switch number contained in 
;* sys_temp2 and sys_temp3 and converts it into a more compact form of 
;* 	
;* AAAAABBB
;* 
;* where AAAAA is the column number of the switch (sw 17 = 2)
;*       BBB   is the bit position of the current switch (sw 17 = $01)
;****************************************************************************	
sw_pack		ldaa	sys_temp2
			asla	
			asla	
			asla	
			ldab	sys_temp3
			begin
				rorb	
				bcs	pack_done
				inca	
			loopend
pack_done		staa	sw_encoded
			rts

;****************************************************************************
;*
;****************************************************************************				
check_sw_open	staa	sys_temp4
			stx	sys_temp1
next_switch		bsr	getswitch				;Clear Carry if Switch Activated
			bcs	to_ldx_rts				;ldx $A0, rts.
			bsr	sw_pack				;$A5(A) = ($A1<<3)+BitPos($A2) Encode Matrix Position
			ldx	#switch_queue
			begin
				cpx	switch_queue_pointer
				beq	next_switch
				cmpa	$01,X					;Is this switch in the buffer?
				ifeq
					bsr	copy_word				;Copy Word: $96--  Data,$96 -> Data,X
					jsr	sw_proc
					bra	next_switch
				endif
				inx	
				inx	
			loopend


;****************************************************************************
;* Looks up the trigger data (time up and time down requirements) for the
;* switch contained in 'sw_encoded'. If the switch table lists the trigger
;* type as 0, then the trigger data is pulled from the location in bytes
;* 2 and 3 of the switch table entry.
;****************************************************************************				
sw_get_time		bsr	sw_tbl_lookup		;X = Data@ (E051 + $A5*3)
			ldaa	$00,X
			anda	#$07				;Get the trigger type for this switch
			ifne					;If 1-7, then look up data in switch type table
				asla						
				ldx	#gr_switchtypetable-2		;Game ROM Table: Switch Trigger Table
				bsr	xplusa				;X = X + A
			else					;Otherwise, this switch has inline trigger data pointer
				ldx	$01,X
			endif
			ldaa	sys_temp5			;Matrix Data
			anda	sys_temp3			;Bit Position
			ifne
				inx					;Point to Switch Close Trigger data instead
			endif
			ldaa	$00,X				;Load Trigger Data
			rts
			
sw_tbl_lookup	ldaa	sw_encoded
			tab	
			asla					;Times 3 for switch table entry length
			aba	
			ldx	gr_switchtable_ptr		;*** Table Pointer ***
xplusa		psha	
			stx	sys_temp_w2
			adda	sys_temp_w2+1
			staa	sys_temp_w2+1
			ifcs
				inc	sys_temp_w2
			endif 
			ldx	sys_temp_w2
			pula	
			rts	  

copy_word		stx	sys_temp_w2
			ldx	switch_queue_pointer
			dex	
			dex	
			stx	switch_queue_pointer
			ldaa	$00,X
			ldab	$01,X
			ldx	sys_temp_w2
			staa	$00,X
			stab	$01,X
			rts	

;**************************************************
;* Initializes the Virtual Machine stack. Routine
;* will set up all 'next' pointers for each thread
;* placeholder. The VM size is determined by the 
;* settings in the game ROM. This must be balanced
;* properly for each game so that the created
;* threads do not clobber the cpu stack since they
;* grow towards each other.
;**************************************************
setup_vm_stack	ldab	gr_maxthreads		;Max Size of VM
			ldx	#threadpool_base
			stx	vm_nextslot
			begin
				stx	temp2
				ldaa	temp2+1
				adda	#$12
				staa	$01,X
				ldaa	#$00
				adca	temp2
				staa	$00,X
				decb	
				beq	stack_done
				ldx	$00,X
			loopend
stack_done		stab	$00,X
			stab	$01,X
			stab	vm_base
			stab	vm_base+1
			ldx	#vm_base
			stx	vm_tail_thread
			rts

;**************************************************
;* Adds B to X, Protects A
;**************************************************				
xplusb		psha	
			tba	
			bsr	xplusa		;X = X + A
			pula	
			rts	

;**************************************************
;* Pulls data from CMOS location in X and X+1
;* and puts it in A. X is double incremented.
;*
;* Requires:	X
;* Protects:	B
;* Output:		A
;**************************************************		
cmosinc_a		pshb	
			ldaa	$00,X
			ldab	$01,X
			inx	
			inx	
			andb	#$0F
			asla	
			asla	
			asla	
			asla	
			aba	
			pulb	
			rts

;**************************************************
;* Pulls data from CMOS location in X and X+1
;* and puts it in B. X is double incremented.
;*
;* Requires:	X
;* Protects:	A
;* Output:		B
;**************************************************				
cmosinc_b		psha	
			bsr	cmosinc_a
			tab	
			pula	
			rts

;**************************************************
;* Transfers the byte value in B to the CMOS RAM
;* location contained in X. The byte is stored in
;* two consecutive nybbles in CMOS. X is double 
;* incremented.
;*
;* Requires: 	B,X
;* Protects:	A
;**************************************************
b_cmosinc		psha	
			tba	
			bsr	a_cmosinc		;A -> CMOS,X++
			pula	
			rts	
			
;**************************************************
;* Reset Game Audits only
;**************************************************			
reset_audits	ldx	#aud_reset_end-aud_base		;Clear RAM from 0100-0165
			bra	clr_ram
clr_ram_100		ldx	#cmos_base
clr_ram		begin
				clr	$FF,X
				dex	
			eqend
			rts	

;**************************************************
;* Restores Factory Settings and resets all audit 
;* information, reloads pricing data and restores 
;* the backup high score.
;**************************************************			
factory_zeroaudits	
			bsr	clr_ram_100				;Clear RAM 0100-01FF
			ldx	#adj_base
			stx	temp1
			ldx	#gr_defaudit			;Begining of Default Audit Data
			ldab	#$18
			bsr	copyblock2				;Transfer Audit Data
			ldab	#$01
			ldaa	pia_sound_data			;Read W29 Jumper Setting
			ifmi
				incb
			endif
			bsr	loadpricing				;Load Pricing Data
			bsr	restore_hstd			;Restore Backup High Score
			ldx	#to_audadj
			jmp	newthread_06			;Push VM: Data in A,B,X,$A6,$A7,$AA=#06

;**************************************************
;* Clears the CMOS High Score RAM then copies
;* the backup high score.
;**************************************************			
restore_hstd	clra	
			jsr	fill_hstd_digits			;Fill HSTD Digits with A
			ldx	#adj_backuphstd
			bsr	cmosinc_a				;CMOS,X++ -> A
			tab	
			jsr	split_ab				;Shift A<<4 B>>4
			ldx	#aud_currenthstd			;CMOS: Current HSTD
			bsr	b_cmosinc				;B -> CMOS,X++

			
;**************************************************
;* Transfers the byte value in A to the CMOS RAM
;* location contained in X. The byte is stored in
;* two consecutive nybbles in CMOS. X is double 
;* incremented.
;*
;* Requires: 	A,X
;* Protects:	B
;**************************************************			
a_cmosinc		psha	
			staa	$01,X
			lsra	
			lsra	
			lsra	
			lsra	
			staa	$00,X
			inx	
			inx	
			pula	
			rts	 

;********************************************************
;* Copies B bytes of data from address in X(temp2) to 
;* address in temp1
;*
;* Requires:	B,X,temp1
;* Protects:	A
;* Destroys:	B,X,temp1,temp2
;* Output:		B = 0
;******************************************************** 			
copyblock		psha	
			begin
				ldaa	$00,X
				inx	
				stx	temp2
				ldx	temp1
				staa	$00,X
				inx	
				stx	temp1
				ldx	temp2
				decb	
			eqend
			pula	
			rts

;************************************************
;* Copies the default pricing data block from
;* the game ROM to CMOS RAM. Register B contains
;* either $01 or $02 which specifies which 
;* default table to copy based on MPU jumper W29
;*
;* Requires: B
;************************************************				
loadpricing		stab	adj_pricecontrol+1		;Get the LSB of the pricing index
			ldx	#cmos_pricingbase   
			stx	temp1
			aslb						
			tba	
			asla	
			aba	
			ldx	#gr_gameadjust7			;*** Table Pointer ***
			jsr	xplusa				;X = X + A
			ldab	#$06
copyblock2		psha
			begin	
				ldaa	$00,X
				inx	
				stx	temp2
				ldx	temp1
				bsr	a_cmosinc				;A -> CMOS,X++
				stx	temp1
				ldx	temp2
				decb	
			eqend
			pula	
			rts
			
;******************************************************
;* IRQ Routine
;*
;* This is the main timekeeping section of the code. 
;* All events are kept track of by couting the IRQ's
;* that have run.
;*
;* Tasks processed in the IRQ:
;*		
;*		Update Next Lamp
;******************************************************
sys_irq_entry
	ldab   irq_counter
			dec   randomseed
			rorb  
			ifcc
				inc   lamp_index_wordx
				ldaa   lamp_bit
				asla  
				ifeq
					staa   lamp_index_wordx
					staa   irq_counter
					staa   $00AE
					inca  
				endif
				staa   lamp_bit
			endif
			ldx   lamp_index_word
			ldab   irq_counter
			andb  #07
			ifeq
				ldaa  #FF
				staa  DISPLAY_PIA1_DATA_B
				clr	ALPHA/NUM_PIA2_DATA_A
				clr   ALPHA/NUM_PIA2_DATA_B
				ldab  irq_counter
				stab  DISPLAY_PIA1_DATA_A
				beq   b_082
				jmp   b_081
			endif
			stab   swap_player_displays
			decb  
			ifne   
				subb  #03
				bne   snd_wr0
			endif
			rol   comma_data_temp
			rorb  
			rol   comma_data_temp
			rorb  
			orb   SOUND_PIA5_DATA_B
			bra   snd_wr
b_082			inc   irqcount16
			ldaa  comma_flags
			staa  comma_data_temp
			ldaa  dmask_p1
			staa  credp1p2_bufferselect
			ldaa  dmask_p3
			staa  mbipp3p4_bufferselect
			ldab  cred_b0
			rol   credp1p2_bufferselect
			ifcs
				ldab   cred_b1
			endif
			ldaa  mbip_b0
			rol   mbipp3p4_bufferselect
			bcc   b_083
			ldaa  mbip_b1
			bra   b_083

			;***********************************
			;* Sound command clear
			;***********************************
snd_wr0		ldab   SOUND_PIA5_DATA_B
			andb  #3F
snd_wr		stab   SOUND_PIA5_DATA_B

			;reset displays
			clr   ALPHA/NUM_PIA2_DATA_A
			clr   ALPHA/NUM_PIA2_DATA_B
			ldaa   #FF
			staa   DISPLAY_PIA1_DATA_B
			ldaa   irq_counter
			staa   DISPLAY_PIA1_DATA_A
			
			
			ldaa   score_p1_b0,X
			rol   credp1p2_bufferselect
			ifcs
				ldaa   score_p1_b1,X
			endif
			ldab   #03
			cmpb  irq_counter
			ifgt
				rol   mbipp3p4_bufferselect
			else
				ldx	alpha_digit_cur
				inc   alpha_digit_cur+1 	;increment LSB
				ldab  alpha_b0,X
				rol   mbipp3p4_bufferselect
				ifcs
					ldab   alpha_b1,X
				endif
				ldx   character_defs		;This is the index table for all characters
				psha  
				tba   
				andb  #3F				;max 3F characters in lookup table
				aslb  
				stx   character_ptr
				addb  character_ptr+1
				stab  character_ptr+1
				ifcs
					inc   character_ptr
				endif
				ldx   character_ptr
				ldab   $00,X
				stab   ALPHA/NUM_PIA2_DATA_A	;write character data
				ldab   $01,X
				bita  #80
				ifne
					orb   #40
				endif
				bita  #40
				ifne   
					orb   #80
				endif
				stab   ALPHA/NUM_PIA2_DATA_B	;write comma/dot data
				pula  
				ldab   #FF
			endif

			ror	swap_player_displays
			ifcc
b_083				lsrb						;Show BA
				lsrb	
				lsrb	
				lsrb	
				anda	#$F0
				bra	b_08A					;Goto Display End
b_081				ldaa	dmask_p2
				staa	credp1p2_bufferselect
				ldaa	dmask_p4
				staa	mbipp3p4_bufferselect
				ldab	cred_b0
				rol	credp1p2_bufferselect
				ifcs
					ldab	cred_b1
				endif
				ldaa	mbip_b0
				rol	mbipp3p4_bufferselect
				ifcs
					ldaa	mbip_b1
				endif
			endif
			asla						;Show AB
			asla	
			asla	
			asla	
			andb	#$0F					;Fall through to end
b_08A			aba	
			staa	pia_disp_seg_data			;Store Digit BCD Data

			;***********************************
			;* Now do lamps...
			;***********************************
			ldaa	#$FF
			ldab	irq_counter
			rorb	
			ifcc						;Do Lamps every other IRQ
				ldx	#pia_lamp_row_data			;Lamp PIA Offset
				staa	$00,X					;Blank Lamp Rows with an $FF
				staa	#pia_sol_low_data
				ldab	$03,X
				clr	$03,X
				staa	$02,X					;Blank Lamp Columns with $FF
				stab	$03,X
				ldaa	lamp_bit				;Which strobe are we on
				staa	$02,X				;Put the strobe out there
				cmpa	$02,X				;Did it take?
				ifeq
					ldx	lamp_index_word			;This will always be $0001-$0080, it is
											;used to index the lamp buffer bit positions.			
					ldaa	lampbufferselect,X		;0=buffer_0 1=buffer_1
					tab	
					comb	
					andb	lampbuffer0,X
					anda	lampbuffer1,X
					aba	
					coma	
					staa	pia_lamp_row_data			;Store Lamp Row Data
				endif
			

				;* In Hyperball we have another half matrix of lamps too
				ldaa  lamp_index_wordx
				tab   
				lsra  
				staa	lamp_index_wordx
				ldx   lamp_index_word
				stab  lamp_index_wordx
				ldaa  lampbufferselectx,X
				tab   
				comb  
				andb  lampbuffer0x
				anda  lampbuffer1x
				aba   
				coma  
				ldb   lamp_index_wordx
				clc   
				rorb  
				ifcs
					lsra  
					lsra  
					lsra  
					lsra  
				endif
				anda  #0F
				staa   pia_sol_low_data

			endif
			
			;***********************************
			;* Done with Displays
			;* Increment the IRQ counter
			;***********************************
			ldaa	irq_counter				;We need to increment this every time.
			inca	
			staa	irq_counter

			;******************************************************************
			;* Now do switches, The switch logic has a total of 5 data buffers.
			;* These are used for debouncing the switch through software. The
			;* original Level7 code used an X indexed loop to do this, which was
			;* much more compact, however because of the indexed addressing it
			;* was substantially slower, while this takes more ROM space it ends
			;* up being about 100 clock cycles faster
			;******************************************************************
			rora	
			ifcs
				jmp	irq_sol
			else
				ldaa	#$01
				staa	pia_switch_strobe_data		;Store Switch Column Drives
							
				ldaa	switch_debounced
				eora	pia_switch_return_data		;Switch Row Return Data
				tab	
				anda	switch_masked
				oraa	switch_pending
				staa	switch_pending
				stab	switch_masked
				comb	
				andb	switch_pending
				orab	switch_aux
				stab	switch_aux
				asl	pia_switch_strobe_data		;Shift to Next Column Drive
				ldaa	switch_debounced+1
				eora	pia_switch_return_data		;Switch Row Return Data
				tab	
				anda	switch_masked+1
				oraa	switch_pending+1
				staa	switch_pending+1
				stab	switch_masked+1
				comb	
				andb	switch_pending+1
				orab	switch_aux+1
				stab	switch_aux+1
				asl	pia_switch_strobe_data		;Shift to Next Column Drive
				ldaa	switch_debounced+2
				eora	pia_switch_return_data		;Switch Row Return Data
				tab	
				anda	switch_masked+2
				oraa	switch_pending+2
				staa	switch_pending+2
				stab	switch_masked+2
				comb	
				andb	switch_pending+2
				orab	switch_aux+2
				stab	switch_aux+2
				asl	pia_switch_strobe_data		;Shift to Next Column Drive
				ldaa	switch_debounced+3
				eora	pia_switch_return_data		;Switch Row Return Data
				tab	
				anda	switch_masked+3
				oraa	switch_pending+3
				staa	switch_pending+3
				stab	switch_masked+3
				comb	
				andb	switch_pending+3
				orab	switch_aux+3
				stab	switch_aux+3
				asl	pia_switch_strobe_data		;Shift to Next Column Drive
				ldaa	switch_debounced+4
				eora	pia_switch_return_data		;Switch Row Return Data
				tab	
				anda	switch_masked+4
				oraa	switch_pending+4
				staa	switch_pending+4
				stab	switch_masked+4
				comb	
				andb	switch_pending+4
				orab	switch_aux+4
				stab	switch_aux+4
				asl	pia_switch_strobe_data		;Shift to Next Column Drive
				ldaa	switch_debounced+5
				eora	pia_switch_return_data		;Switch Row Return Data
				tab	
				anda	switch_masked+5
				oraa	switch_pending+5
				staa	switch_pending+5
				stab	switch_masked+5
				comb	
				andb	switch_pending+5
				orab	switch_aux+5
				stab	switch_aux+5
				asl	pia_switch_strobe_data		;Shift to Next Column Drive
				ldaa	switch_debounced+6
				eora	pia_switch_return_data		;Switch Row Return Data
				tab	
				anda	switch_masked+6
				oraa	switch_pending+6
				staa	switch_pending+6
				stab	switch_masked+6
				comb	
				andb	switch_pending+6
				orab	switch_aux+6
				stab	switch_aux+6
				asl	pia_switch_strobe_data		;Shift to Next Column Drive
				ldaa	switch_debounced+7
				eora	pia_switch_return_data		;Switch Row Return Data
				tab	
				anda	switch_masked+7
				oraa	switch_pending+7
				staa	switch_pending+7
				stab	switch_masked+7
				comb	
				andb	switch_pending+7
				orab	switch_aux+7
				stab	switch_aux+7
				asl	pia_switch_strobe_data		;Shift to Next Column Drive
			endif
			;***********************************
			;* Now do solenoids
			;***********************************
irq_sol		ldaa	solenoid_counter			;Solenoid Counter
			ifne
				dec	solenoid_counter			;Solenoid Counter
				ifeq
					ldx	solenoid_address
					ldaa	$00,X
					eora	solenoid_bitpos
					staa	$00,X
				endif
			endif
			rti

;*************************************************************************
;* End IRQ
;*************************************************************************

;*************************************************************************
;* PIA Data Direction Register Data - Loaded on Initialization
;*************************************************************************
pia_ddr_data	.db $7F,$3E,$C0,$3E	;$2100 - Sound PIA
			.db $FF,$3C,$FF,$34	;$2200 - Solenoid PIA
			.db $FF,$3C,$FF,$3C	;$2400 - Lamp PIA
			.db $FF,$3C,$FF,$3C	;$2800 - Display PIA
			.db $00,$3C,$FF,$3C	;$3000 - Switch PIA
			.db $FF,$3C,$FF,$3C	;$4000 - Alpha PIA

lampbuffers		.db $00,$10,$00,$1C,$00,$34,$00,$28

;*************************************************************************
;* Turn On Lamp: Lamp number is in A (packed format). This can also be 
;*               used to set a bitflag.
;*************************************************************************
lamp_on		stx	temp3
			ldx	#lampbuffer0			;Set up correct index to lampbuffer
lamp_or		pshb	
			bsr	unpack_byte				
			pshb						;B now contains the bitpos
			orab	$00,X
lamp_commit		stab	$00,X					;turn it on
			stx	temp2
			ldab	temp2+1				;was item worked on within lampbuffer0
			cmpb	#(bitflags)&$FF			;compare index against start of bitflags
			pulb	
			bcc	lamp_done
			comb						;If we are here, then we must switch buffers.
			andb	lampbufferselectx,X		;We are now on buffer 0
			stab	lampbufferselectx,X
lamp_done		pulb	
			ldx	temp3
			rts

;*************************************************************************
;* Turn Off Lamp: Lamp number is in A (packed format). This can also be 
;*               used to clear a bitflag.
;*************************************************************************			
lamp_off		stx	temp3
			ldx	#lampbuffer0
lamp_and		pshb	
			bsr	unpack_byte				;seperate into X and B
			pshb	
			comb	
			andb	$00,X
			bra	lamp_commit

;*************************************************************************
;* Sets a Lamp to 'flashing' state
;*************************************************************************			
lamp_flash		stx	temp3
			ldx	#lampflashflag
			bra	lamp_or

;*************************************************************************
;* Toggle Lamp from existing state. This may be used on bitflags as well.
;*************************************************************************			
lamp_invert		stx	temp3
			ldx	#lampbuffer0
lamp_eor		pshb	
			bsr	unpack_byte				;(X = X + A>>3), B = (bitpos(A&07))
			eorb	$00,X
			stab	$00,X
			bra	lamp_done				;Leave now
				
lamp_on_b		ldx	#lampbufferselect
			bra	lamp_or

lamp_off_b		ldx	#lampbufferselect
			bra	lamp_and

lamp_invert_b	ldx	#lampbufferselect
			bra	lamp_eor

lamp_on_1		ldx	#lampbuffer1
			bra	lamp_or

lamp_off_1		ldx	#lampbuffer1
			bra	lamp_and

lamp_invert_1	ldx	#lampbuffer1
			bra	lamp_eor
			
lamp_on_f		ldx	#bitflags
			bra	lamp_or

lamp_off_f		ldx	#bitflags
			bra	lamp_and

lamp_invert_f	ldx	#bitflags
			bra	lamp_eor

;*********************************************************
;* Converts Packed Byte data into an Index in X and a
;* bitpos in B
;*
;* Packed Data Format: IIII IBBB
;*
;*	Where IIIII is the index to the lamp buffers.
;*    Values between 
;*      0-7		lampbuffer0
;*      7-15	
;*********************************************************	
unpack_byte		psha	
			lsra	
			lsra	
			lsra	
			jsr	xplusa				;X = X + A
			pula	
			jmp	hex2bitpos				;Convert Hex (A&07) into bitpos (B)

;***************************************************************
;* Lamp Range Manipulation Code Start Here
;***************************************************************
;Clears all lamps in specified buffer, sets active buffer to 0		
lampm_clr0		bsr	lampr_start				;A=Current State,B=Bitpos,X=Lamp Byte Postion
			begin
				tba	
				coma	
				anda	$00,X
				bsr	lampm_buf0			;Set Lamp to Buffer 0
				jsr	lamp_left			;Shift Lamp Bit Left, De-increment Lamp Counter, Write it
			csend						;Loop it!
			bra	abx_ret

lampm_buf0		staa	$00,X
			stx	temp2
			ldaa	temp2+1
			cmpa	#$1C					;If we are not using Buffer $0010 then skip this
			ifcs
				tba	
				coma	
				anda	lampbufferselectx,X
				staa	lampbufferselectx,X
			endif
			rts	 

;Invert entire range
lampm_f		bsr	lampr_start				;A=Current State,B=Bitpos,X=Lamp Byte Postion
			begin
				tba	
				eora	$00,X
				staa	$00,X
				jsr	lamp_left				;Shift Lamp Bit Left, De-increment Lamp Counter, Write it
			csend
			bra	abx_ret

;This is unused in the macros. You must call it directly at $F1D5
;The behavior of this command is probably the most complex. It 
;starts at the last lamp in the range. If it is already set, then
;the routine simply exits. If the last lamp is not set, the routine
;goes down through each lamp in the range. If if finds a lamp on,
;then it turns off that lamp, then goes back up to the next lamp
;and turns it on. If no lamps are on in the range, then the first
;lamp in the range is turned on.
;The best example of this routine is for the 10-20-30 lamps on 
;Jungle Lord. It will simply incrment the 10-20-30 lamps sequentially
;and then stop at 30. If none are on, then it will turn on 10.
lampm_g				
			bsr	lampr_end				;A = Last Lamp Level, B = Last Lamp BitPos
			bne	abx_ret
			begin
				jsr	lamp_right				;Shift Lamp Bit Right, De-increment Lamp Counter, Write it
				bcs	b_098
			neend
			tba	
			coma	
			anda	$00,X
			staa	$00,X
b_098			bsr	lamp_left				;Shift Lamp Bit Left, De-increment Lamp Counter, Write it
b_09A			orab	$00,X
			stab	$00,X
			bra	abx_ret

;***************************************************
;* Goes through range bits from low to high and
;* finds first cleared bit, sets it and exits.	
;***************************************************	
lampm_a		bsr	lampr_start				;A=Current State,B=Bitpos,X=Lamp Byte Postion
			begin
				beq	b_09A
				bsr	lamp_left				;Shift Lamp Bit Left, De-increment Lamp Counter, Write it
				bcs	abx_ret				;Return if we have reached end lamp
			loopend

;***************************************************
;* Goes through range bits from low to high and
;* finds first cleared bit, sets it and exits. If 
;* all bits in range are already set, then routine 
;* clears all bits in range.
;***************************************************			
lampm_b		bsr	lampr_start				;A=Current State,B=Bitpos,X=Lamp Byte Postion
			begin
				beq	b_09A
				bsr	lamp_left				;Shift Lamp Bit Left, De-increment Lamp Counter, Write it
			csend
			ldx	temp3
			ldaa	sys_temp1
			ldab	sys_temp2
			bra	lampm_clr0				;Turn OFF All lamps in Range

;Sets all lamp bits specified buffer, sets active buffer to 0 if action is on buffer 0			
lampm_set0		bsr	lampr_start				;A=Current State,B=Bitpos,X=Lamp Byte Postion
			begin
				tba	
				oraa	$00,X
				bsr	lampm_buf0			;Set Lamp to Buffer 0
				bsr	lamp_left			;Shift Lamp Bit Left, De-increment Lamp Counter, Write it
			csend
abx_ret		ldaa	sys_temp1
			ldab	sys_temp2
			ldx	temp3
			rts	 

;************************************************************
;* Lamp Range Routines: This take care of manipulating
;*                      a collection of sequential lamps
;*                      to create various lighting effects.
;************************************************************
;* Loads the Lamp range data
;*
;* sys_temp2 = start lamp
;* sys_temp3 = end lamp
;* A = Byte data anded with curent bit
;* B = Bitpos
;* X = Lamp Byte Postion
;*
;************************************			
lampr_start		jsr	lampr_setup				;Set up Lamp: $A2=start $A3=last B=Bitpos X=Buffer
			ldaa	sys_temp3				;Starting lamp in range
lr_ret		jsr	unpack_byte				;(X = X + A>>3), B = (bitpos(A&07))
			tba	
			anda	$00,X
			rts	 

lampr_end		bsr	lampr_setup				;Set up Lamp: $A2=start $A3=last B=Bitpos X=Buffer
			ldaa	sys_temp4				;End Lamp In range
			bra	lr_ret
			
lampr_setup		stx	temp3
			staa	sys_temp1
			stab	sys_temp2
			ldx	gr_lamptable_ptr			;Game ROM: Lamp Range Table
			tab	
			aslb	
			andb	#$7F
			jsr	xplusb
			ldx	$00,X
			stx	sys_temp3				;Save Lamp Range
			ldx	#lampbuffers			;Lamp Buffer Locations
			rola	
			rola	
			rola	
			asla	
			anda	#$07
			jsr	xplusa				;X = X + A
			ldx	$00,X					;Get the Buffer Pointer Specified
			ldab	sys_temp4
			subb	sys_temp3
			stab	temp1					;Store how many lamps affected
			rts	 

;*************************************************************
;* Moves current lamp bit up one bit. If shifted off end of 
;* current lamp buffer byte, then byte is incremented and bit
;* is reset to $01.
;*************************************************************			
lamp_left		aslb					;shift it
			ifcs					;did it go off end
				rolb					;yes, rolb to #$01
				inx					;increment the byte position
			endif
ls_ret		ldaa	temp1				;load up the original lamp counter until end lamp
			suba	#$01				;take one off
			staa	temp1				;store it again
			tba					;get the bit back again
			anda	$00,X				;AND accum A with current buffer location
			rts	

;*************************************************************
;* Moves current lamp bit down one bit. If shifted off start of 
;* current lamp buffer byte, then byte is deincremented and bit
;* is reset to #$80
;*************************************************************			
lamp_right		lsrb	
			bcc	ls_ret
			rorb	
			dex	
			bra	ls_ret

;***************************************************
;* Goes through range bits from high to low, routine
;* finds first bit in range that is set and clears
;* it and then exits.
;***************************************************			
lampm_c		bsr	lampr_end				;A=Current State,B=Bitpos,X=Lamp Byte Postion
lm_test		ifeq
				bsr	lamp_right				;Shift Lamp Bit Right, De-increment Lamp Counter, Write it
				bcc	lm_test
				bra	abx_ret
			endif
			comb	
			andb	$00,X
			stab	$00,X
			bra	abx_ret

;Rotate Up			
lampm_e		bsr	lampr_start				;A=Current State,B=Bitpos,X=Lamp Byte Postion
			stx	temp2
			stab	temp1+1
			begin
				staa	sys_temp5
				bsr	lamp_left				;Shift Lamp Bit Left, De-increment Lamp Counter, Write it
				bcs	b_0A2					;Branch if we are at the end of the range
				bsr	b_0A3
			loopend
			
b_0A2			ldx	temp2					;Get the last Byte location
			ldab	temp1+1				;Get the last Bitpos
			bsr	b_0A3
			bra	to_abx_ret

;Rotate Down			
lampm_d		bsr	lampr_end				;A = Last Lamp Level, B = Last Lamp BitPos
			stx	temp2
			stab	temp1+1
			begin
				staa	sys_temp5
				bsr	lamp_right				;Shift Lamp Bit Right, De-increment Lamp Counter, Write it
				bcs	b_0A2
				bsr	b_0A3
			loopend

b_0A3			psha					
			tba					;B has the bitpos
			coma	
			anda	$00,X				;Mask it off
			tst	sys_temp5			;sys_temp5 has the first bit in range's value or 0s
			ifne					;if it was on
				aba					;make it on again
			endif
			staa	$00,X				;store it
			pula	
			rts

lampm_z		jsr	lampr_end				;A = Last Lamp Level, B = Last Lamp BitPos
			ifeq
				begin
					bsr	lamp_right				;Shift Lamp Bit Right, De-increment Lamp Counter, Write it
					bcs	to_abx_ret
				neend
			endif
			tba	
			eora	$00,X
			staa	$00,X
			jsr	lamp_right				;Shift Lamp Bit Right, De-increment Lamp Counter, Write it
			bcs	to_abx_ret
			orab	$00,X
			stab	$00,X
to_abx_ret		jmp	abx_ret

			jsr	lampr_start				;A=Current State,B=Bitpos,X=Lamp Byte Postion
b_0AB			ifne
				jsr	lamp_left				;Shift Lamp Bit Left, De-increment Lamp Counter, Write it
				bcc	b_0AB
				bra	to_abx_ret
			endif
b_0AA			clc	
			bra	to_abx_ret
			jsr	lampr_start				;A=Current State,B=Bitpos,X=Lamp Byte Postion
b_0AC			bne	b_0AA
			jsr	lamp_left				;Shift Lamp Bit Left, De-increment Lamp Counter, Write it
			bcc	b_0AC
			bra	to_abx_ret

bit_switch		ldx	#switch_debounced
			bra	bit_main
bit_lamp_flash	ldx	#lampflashflag
			bra	bit_main
bit_lamp_buf_1	ldx	#lampbuffer1
			bra	bit_main
bit_lamp_buf_f	ldx	#bitflags
			bra	bit_main
bit_lamp_buf_0	ldx	#lampbuffer0
bit_main		jsr	unpack_byte				;(X = X + A>>3), B = (bitpos(A&07))
			bitb	$00,X
			rts	

F393: D8 

lampm_x		anda	#$3F
			jsr	lampr_start				;A=Current State,B=Bitpos,X=Lamp Byte Postion
			begin
				staa	thread_priority			;This is probably just a temp location?
				tba	
				coma	
				anda	bitflagsx,X
				oraa	thread_priority			;Recall temp
				staa	bitflagsx,X
				jsr	lamp_left				;Shift Lamp Bit Left, De-increment Lamp Counter, Write it
			csend
			bra	to_abx_ret
			
;***************************************************
;* System Checksum #2: Set to make ROM csum from
;*                     $F000-F7FF equal to $00
;***************************************************
	
csum2			.db $D8

;***************************************************
;* VM Macro Pointers: Master Lookup Table
;***************************************************
				
master_vm_lookup	.dw vm_control_0x		;Misc Functions
			.dw vm_control_1x		;Lamp Functions
			.dw vm_control_2x		;Lamp Functions
			.dw vm_control_3x		;Solenoid Functions
			.dw vm_control_4x		;Sound, Immediate Exe Functions
			.dw vm_control_5x		;RAM,Delay,Jump,SimpleBransh Functions
			.dw vm_control_6x		;Indexed Delay Functions
			.dw vm_control_7x		;Immediate Delay Functions
			.dw vm_control_8x		;Jump Relative 
			.dw vm_control_9x		;jsr Relative
			.dw vm_control_ax		;jsr to Code Relative
			.dw vm_control_bx		;Add RAM
			.dw vm_control_cx		;Set RAM
			.dw vm_control_dx		;Play Sound Multiple
			.dw vm_control_ex		;Play Sound Once
			.dw vm_control_fx		;Play Sound Once

vm_lookup_0x	.dw macro_pcminus100
			.dw macro_go
			.dw macro_rts
			.dw killthread
			.dw macro_code_start
			.dw macro_special
			.dw macro_extraball
	
vm_lookup_1x_a	.dw lampm_set0
			.dw lampm_clr0
			.dw lampm_a
			.dw lampm_b
			.dw lampm_c
			.dw lampm_d
			.dw lampm_e
			.dw lampm_f 
  
vm_lookup_1x_b	.dw lamp_on
			.dw lamp_off
			.dw lamp_invert
			.dw lamp_flash

vm_lookup_2x
F3DC: $F1DA 
F3DE: $F1E1 

vm_lookup_2x_b
F3E0: $F1E8 
F3E2: $F1EF 
F3E4: $F1F6 

vm_lookup_2x_c
F3E6: $F1FD  
F3E8: $F204 
F3EA: $F20B  

vm_lookup_4x
F3EC: $EBD3    
F3EE: $EB3D     
F3F0: dsnd_pts 

vm_lookup_5x    
F3F2: $F544 
F3F4: $F559     
F3F6: $F564 
F3F8: $F56C 
F3FA: $F589 
F3FC: $F590 
F3FE: $F597 
F400: $F5C1 
F402: $F667 
F404: $F667 
F406: $F667 
F408: $F667 
F40A: $F5E9 
F40C: $F63E  
F40E: $F656 
F410: $F600

branch_lookup
F412: $F6F3 
F414: $F6FA 
F416: $F52F   
F418: $F6D6 
F41A: $F6DB 
F41C: $F6E7 
F41E: $F6EE 
F420: $F701    
F422: $F70D 
F424: $F717   
F426: $F712 
F428: $F719
F42A: $F71E 
F42C: $F723 
F42E: $F726 
F430: $F72D 

;*************************************************************
;* Virtual Machine Routines:
;*
;* These are the main routines that are called to interpret
;* the commands written in WML7.
;*************************************************************
macro_start		
			staa	ram_base
			stab	ram_base+1
macro_rts		
			pula	
			staa	vm_reg_a
			pula	
			staa	vm_reg_b
macro_go		
			jsr	gr_macro_event
			jsr	macro_getnextbyte			;Macro Data: A = Next Byte $D1+1
			tab	
			lsrb	
			lsrb	
			lsrb	
			andb	#$1E
			ldx	#master_vm_lookup
			jsr	xplusb
			ldx	$00,X
			jmp	$00,X

switch_entry	stx	vm_pc
			staa	vm_reg_a
breg_sto		stab	vm_reg_b
			bra	macro_go
			

vm_control_0x	ldx	#vm_lookup_0x
			jsr	gettabledata_b			;X = data at (X + (A*2))
			jmp	$00,X
			
macro_pcminus100	ldx	vm_pc
			dex	
			stx	vm_pc
			bra	macro_go

macro_code_start	ldx	vm_pc
			ldaa	ram_base
			ldab	ram_base+1
			jmp	$00,X

macro_special	jsr	award_special			;Award Special
			bra	macro_go

macro_extraball	jsr	award_extraball				;Award Extra Ball
			bra	macro_go
			
vm_control_1x	tab	
			andb	#$0F
			subb	#$08
			bcs	macro_17				;Branch for Macros 10-17
macro_x8f		aslb	
			ldx	#vm_lookup_1x_a
			jsr	xplusb				;X = X + B)
			ldx	$00,X
			tab						;Original Command #
			aslb	
			aslb	
			andb	#$80
b_0AF			begin
				jsr	macro_getnextbyte			;Macro Data: A = Next Byte $D1+1
				psha	
				anda	#$7F
				aba	
				jsr	$00,X
				pula	
				tsta	
			plend
			bra	macro_go
			
macro_17		ldx	#vm_lookup_1x_b
macro_x17		tab						;A = still instruction #
			anda	#$03
			jsr	gettabledata_b			;X = data at (X + (A*2))
			bitb	#$04
			ifeq					;Branch on 14-17
				clrb	
				bra	b_0AF
			endif
			begin
				bsr	macro_getnextbyte			;Macro Data: A = Next Byte $D1+1
				tab	
				stx	temp3
				jsr	macro_b_ram				;$00,LSD(A)->A
				jsr	$00,X
				ldx	temp3
				tstb	
			plend
to_macro_go1	jmp	macro_go

vm_control_2x	tab						;A= macro
			andb	#$0F
			subb	#$08
			bcc	macro_x8f				;Branch for Macros 28-2F
			ldx	#vm_lookup_2x
			bra	macro_x17

			ldx   #vm_lookup_2x_b
			tab   
			andb  #0F
			subb  #08
			bcs   macro_x17
			ldx   #vm_lookup_2x_c
			bra   macro_x17

vm_control_3x	tab	
			andb	#$0F					;16 Solenoids Max 
			begin
				bsr	macro_getnextbyte			;Macro Data: A = Next Byte $D1+1
				jsr	solbuf				;Turn On/Off Solenoid
				decb	
			eqend
			bra	to_macro_go1

vm_control_4x	anda	#$0F
			ifeq
				jsr	macro_get2bytes			;Macro Data: Next Two Bytes into B & A:
				jsr	isnd_pts				;Play Sound Index(B)Once, Add Points(A)
				bra	to_macro_go1
			endif
			cmpa	#$04
			bcc	macro_exec				;Branch for Macros 44-4F (execute cpu)
			ldx	#vm_lookup_4x-2
			jsr	gettabledata_b			;X = data at (X + (A*2))
			bsr	macro_getnextbyte			;Macro Data: A = Next Byte $D1+1
			jsr	$00,X
			bra	to_macro_go1			;Continue Executing Macros

macro_exec		tab	
			subb	#$02
			ldx	#exe_buffer
			begin
				bsr	macro_getnextbyte			;Macro Data: A = Next Byte $D1+1
				staa	$00,X
				inx	
				decb	
			eqend						;Add B bytes to Buffer at #1130
			ldaa	#$7E
			staa	$00,X
			ldaa	#((switch_entry>>8)&$FF)
			staa	$01,X
			ldaa	#((switch_entry)&$FF)		;Tack a jmp switch_entry at the end of the routine
			staa	$02,X
			ldaa	vm_reg_a
			ldab	vm_reg_b
			jmp	exe_buffer				;Go there Now, put return A and B into RAM $00 and $01 

gettabledata_w	anda	#$0F
gettabledata_b	asla	
			jsr	xplusa
			ldx	$00,X
			rts
			
macro_getnextbyte	
			stx	temp1
			ldx	vm_pc
			ldaa	$00,X
			inx	
			stx	vm_pc
getx_rts		ldx	temp1
			rts	

vm_control_5x	ldx	#vm_lookup_5x
			tab						;Move our Data into B
			jsr	gettabledata_w			;X = data at (X + LSD(A)*2)
			jmp	$00,X

macro_ramadd	bsr	macro_getnextbyte			;Macro Data: A = Next Byte $D1+1
			tab	
			bsr	macro_b_ram				;$00,LSD(A)->A
			staa	temp3
			lsrb	
			lsrb	
			lsrb	
			lsrb	
			tba	
			bsr	macro_b_ram				;$00,LSD(A)->A
			adda	temp3
ram_sto2		bsr	macro_a_ram				;A->$00,LSD(B)
to_macro_go2	jmp	macro_go

macro_ramcopy	bsr	macro_getnextbyte			;Macro Data: A = Next Byte $D1+1
			tab	
			bsr	macro_b_ram				;$00,LSD(A)->A
			lsrb	
			lsrb	
			lsrb	
			lsrb	
			bra	ram_sto2				;A->$00,LSD(B),jmp $F3B5

macro_set_pri	bsr	macro_getnextbyte			;Macro Data: A = Next Byte $D1+1
			ldx	current_thread			;Current VM Routine being run
			staa	threadobj_id,X
			bra	to_macro_go2			;Continue Executing Macros

macro_delay_imm_b	
			bsr	macro_getnextbyte			;Macro Data: A = Next Byte $D1+1
dly_sto		staa	thread_timer_byte
			ldx	vm_pc
			ldaa	vm_reg_a
			ldab	vm_reg_b
			jsr	delaythread				;Push Next Address onto VM, Timer at thread_timer_byte
			jmp	switch_entry

macro_getnextword		
			bsr	macro_get2bytes			;Macro Data: Next Two Bytes into B & A:
			stab	temp1
			staa	temp1+1
			bra	getx_rts
			
macro_get2bytes	bsr	macro_getnextbyte			;Macro Data: A = Next Byte $D1+1
			tab	
			bra	macro_getnextbyte			;Macro Data: A = Next Byte $D1+1
			
macro_rem_th_s	bsr	macro_get2bytes			;Macro Data: Next Two Bytes into B & A:
			jsr	kill_thread
			bra	to_macro_go2			;Continue Executing Macros
			
macro_rem_th_m	bsr	macro_get2bytes			;Macro Data: Next Two Bytes into B & A:
			jsr	kill_threads
			bra	to_macro_go2			;Continue Executing Macros

macro_jsr_noreturn	
			bsr	macro_getnextword			;Macro Data: Load X with Next Two Bytes
			ldaa	vm_pc+1
			psha	
			ldaa	vm_pc
			psha	
pc_sto2		stx	vm_pc
			bra	to_macro_go2			;jContinue Executing Macros
			
macro_a_ram		stx	temp1
			andb	#$0F
			stab	temp2+1
			clr	temp2
			ldx	temp2
			staa	$00,X
to_getx_rts		bra	getx_rts

macro_b_ram		stx	temp1
			anda	#$0F
			staa	temp2+1
			clr	temp2
			ldx	temp2
			ldaa	$00,X
			bra	to_getx_rts				;ldx temp1, rts.

macro_jsr_return	bsr	macro_getnextword			;Macro Data: Load X with Next Two Bytes
ret_sto		ldaa	vm_pc+1
			psha	
			ldaa	vm_pc
			psha						;Push Macro PC
			ldaa	ram_base
			ldab	ram_base+1
			jsr	$00,X
			staa	ram_base
			pula	
			staa	vm_pc					;Pull Macro PC
			pula	
			staa	vm_pc+1
			jmp	breg_sto

vm_control_6x	bsr	macro_b_ram				;Load RAM Data
			bra	dly_sto				;Delay it
			
vm_control_7x	anda	#$0F
			bra	dly_sto				;Delay it
			
vm_control_8x	bsr	macro_pcadd				;Add LSD(A)+NextByte to $D1,$D2 -> X
pc_sto		stx	vm_pc					;Store X into VMPC
to_macro_go4	jmp	macro_go

macro_jmp_cpu	jsr	macro_getnextword			;Macro Data: Load X with Next Two Bytes
			ldaa	vm_reg_a
			ldab	vm_reg_b
			jmp	$00,X
			
vm_control_9x	bsr	macro_pcadd				;Add LSD(A)+NextByte to $D1,$D2 -> X
			ldab	vm_pc+1
			pshb	
			ldab	vm_pc
			pshb	
			bra	pc_sto				;Store X into VMPC, continue

vm_control_ax	bsr	macro_pcadd				;Add LSD(A)+NextByte to $D1,$D2 -> X
			bra	ret_sto
			
macro_jmp_abs	jsr	macro_getnextword			;Macro Data: Load X with Next Two Bytes
			bra	pc_sto
			
vm_control_bx	tab	
			bsr	macro_b_ram				;RAM Data (A&0f)->A
			staa	temp2
			bsr	to_macro_getnextbyte
			adda	temp2
ram_sto		bsr	macro_a_ram				;A->RAM(B&0f)
			bra	to_macro_go4

vm_control_cx	tab	
			bsr	to_macro_getnextbyte
			bra	ram_sto				;Save to RAM and continue
			
vm_control_dx	anda	#$0F
			tab	
			bsr	to_macro_getnextbyte		;Macro Data: A = Next Byte $D1+1
			jsr	sound_sub
			bra	to_macro_go4			;jmp  $F3B5 

vm_control_ex
vm_control_fx	anda	#$1F
			jsr	isnd_once				;Play Sound Index(A) Once
			bra	to_macro_go4
			
macro_pcadd		anda	#$0F
			bita	#$08
			ifne
				oraa	#$F0
			endif
			tab	
			bsr	to_macro_getnextbyte		;Macro Data: A = Next Byte $D1+1
			adda	vm_pc+1
			staa	temp1+1
			adcb	vm_pc
			stab	temp1
			ldx	temp1
			rts	

macro_setswitch	bsr	load_sw_no				;Get switch number from the data
			orab	$00,X
			stab	$00,X
			ldaa	sys_temp_w3
			bmi	macro_setswitch
			bra	to_macro_go3			;jmp  $F3B5
			
load_sw_no		bsr	to_macro_getnextbyte		;Macro Data: A = Next Byte $D1+1
			staa	sys_temp_w3
			anda	#$3F
			ldx	#switch_debounced
			jmp	unpack_byte				;(X = X + A>>3), B = (bitpos(A&07))

macro_clearswitch	bsr	load_sw_no				;Get switch number from the data
			comb	
			andb	$00,X
			stab	$00,X
			ldaa	sys_temp_w3
			bmi	macro_clearswitch
to_macro_go3	jmp	macro_go

to_macro_getnextbyte			
			jmp	macro_getnextbyte			;Macro Data: A = Next Byte $D1+1

macro_branch	pshb	
			bsr	branchdata				;Gets Main Result
			jsr	test_a				;Returns #80 or #81 in (A) based on Test of A
			pulb						;Get Back Command in B
			aba	
			psha	
			bitb	#$02					;Relative or Absolute Branch Flag
			ifeq
				jsr	macro_getnextword			;Macro Data: Load X with Next Two Bytes
			else
				bsr	to_macro_getnextbyte		;Macro Data: A = Next Byte $D1+1
				ldab	#$FF
				cmpa	#$80
				adcb	#$00
				adda	vm_pc+1
				adcb	vm_pc
				staa	temp1+1
				stab	temp1
				ldx	temp1
			endif
			pula						;Get our result from above push
			rora						;Test LSB
			bcc	to_macro_go3			;If result was #80, then ignore this branch (jmp  $F3B5)
			jmp	pc_sto2				;Else, we will branch now. (stx  $D1, jmp $F3B5)


branchdata		bsr	to_macro_getnextbyte		;Macro Data: A = Next Byte $D1+1
			cmpa	#$D0
			bcs	to_rts3				;(rts) if data is below #D0
			cmpa	#$F0
			bcc	complexbranch			;Branch if #F0 or above (Complex)
			cmpa	#$E0
			ifcc						;Branch if less than #E0
				jmp	macro_b_ram				;RAM Data (A&0f)->A (Data is E_)
			endif
			ldx	#adj_gameadjust1-2		;Pointer to Bottom of Game Adjustments
			anda	#$0F					;A = Index for Game Adjustment Lookup
			asla	
			jsr	xplusa				;X = X + A
			jmp	cmosinc_a				;CMOS,X++ -> A

complexbranch	cmpa	#$F3
			ifcc							;data is below #F3 (not complex)
				psha						;Push Current Branch Inst.
				bsr	branchdata				;Gets Encoded Data Type
				tab	
				stab	temp1
				pula	
				cmpa	#$F9
				ifcc						;Branch if below #F9 (Lamp or Bit Test)
					psha	
					pshb	
					bsr	branchdata				;Gets Encoded Data Type
					staa	temp1
					pulb	
					pula	
				endif
			endif
			cmpa	#D0
			beq	$F706
			ldx	#branch_lookup
			jsr	gettabledata_w			;X = data at (X + LSD(A)*2)
			ldaa	temp1
			jmp	$00,X

branch_invert	bsr	test_a
			eora	#$01
to_rts3		rts	

branch_lamp_on	jsr	bit_lamp_buf_0			;Bit Test B with Lamp Data (A)
			bne	ret_true				;return true
			jsr	bit_lamp_flash			;Check Encoded #(A) with $0030
test_z		bne	ret_true				;return true
			bra	ret_false				;return false
			
branch_lamprangeoff	
			jsr	$F2DE
test_c		bcs	ret_true				;return true
			bra	ret_false				;return false
			
branch_lamprangeon	
			jsr	$F2CF
			bra	test_c

branch_tilt		ldaa	flag_tilt				;tilt flag?
			bne	ret_true				;return true
ret_false		ldaa	#$80					;return false
			rts	
			
branch_gameover	ldaa	flag_gameover			;game over?
			beq	ret_false				;return false
ret_true		ldaa	#$81
			rts

branch_lampbuf1	jsr	bit_lamp_buf_1			;Check Encoded #(A) with $0028
			bra	test_z				;Return Bool based on Z


branch_lampflag	ldaa  temp1				;Check Encoded #(A) with bitflags
			jsr   bit_lamp_buf_f
			bra	test_z				;Return Boolean based on Z

branch_switch	jsr	bit_switch				;Check Encoded #(A) with $0061:
			bra	test_z				;Return Boolean based on Z
			
branch_and		bsr	set_logic
			anda	temp1
			rts	
			
branch_add		aba	
			rts	
branch_or		bsr	set_logic
			oraa	temp1
			rts	
			
branch_equal	cba	
			beq	ret_true				;lda  #$81, rts
			bra	ret_false				;lda  #$80, rts
			
branch_ge		cba	
			bra	test_c

branch_threadpri	jsr	check_threadid
			bcc	ret_true				;lda  #$81, rts
			bra	ret_false				;lda  #$80, rts
			
branch_bitwise	stab	temp1
			anda	temp1
to_rts4		rts	

set_logic		psha	
			tba	
			bsr	test_a
			staa	temp1
			pula	
test_a		tsta	
			bmi	to_rts4				;rts
			jsr	bit_lamp_buf_0			;Bit Test B with Lamp Data (A)
			beq	ret_false				;return false
			cmpa	#$40					;Check Encoded Lamp #
			bcc	ret_true				;return true
			jsr	bit_lamp_flash			;Bittest with $0030
			bne	ret_false				;return false
			bra	ret_true				;return true
			
;*******************************************************
;* End VM Code Section
;*******************************************************			

award_replay	psha	
			stx   credit_x_temp
			ldx	#aud_replaycredits		;AUD: Replay Score Credits
			jsr	ptrx_plus_1				;Add 1 to data at X
			jsr	gr_special_event			;Game ROM Hook
			ldx   credit_x_temp
			bra	eb_rts  

extraball		psha	
do_eb			stx	eb_x_temp				;Save X for later
			jsr	gr_eb_event
			ldx	#aud_extraballs			;AUD: Total Extra Balls
			jsr	ptrx_plus_1				;Add 1 to data at X
			ldx	eb_x_temp				;Restore X
eb_rts		pula	
			rts

addcredits		stx	credit_x_temp			;Save X
			psha	
addcredit2		pshb	
			bsr	checkmaxcredits			;Check Max Credits (Carry Set if Okay)
			ifcs						;No more if Carry Clear.
				jsr	cmosinc_b				;CMOS,X++ -> B
				dex	
				dex	
				aba						;Add the new credits.
				daa						;Adjust
				ifcs
					ldaa	#$99					;If it rolled, set it to 99
				endif
				jsr	a_cmosinc				;A -> CMOS,X++
				cmpb	current_credits			;Actual Credits
				ifeq						;Check against shown credits
					ldab	#$0E
					stab	thread_priority
					ldx	#creditq				;Thread: Add on Queued Credits
					jsr	newthread_sp			;Push VM: Data in A,B,X,threadpriority,$A6,$A7
					ifcs						;If Carry is set, thread was not added
						staa	current_credits			;Actual Credits
					endif
				endif
				bsr	coinlockout				;Check Max Credits, Adjust Coin Lockout If Necessary
			endif
			ldx	credit_x_temp			;Restore X
			bra	pull_ba_rts				;pulb,pula,rts

;**********************************************
;* Adjust the coin lockout solenoid and the 
;* credit lamp on playfield if installed.
;**********************************************			
coinlockout		psha	
			jsr	checkmaxcredits			;Check Max Credits (Carry Set if Okay)
			ldaa	gr_coinlockout			;Get coil number
			ora	#$F0
			ifcc
				anda	#$0F
			endif
			jsr	solbuf				;Turn Off Lockout Coils
			pula	
			rts	

;**********************************************
;* See if we are at the adjustable maximum 
;* credits allowed. If we are at max then
;* carry flag is cleared, if we are not at
;* max then the carry flag is set.
;**********************************************			
checkmaxcredits	psha	
			pshb	
			ldx	#adj_max_credits			;ADJ: Max Credits
			jsr	cmosinc_b				;CMOS,X++ -> B
			ldx	#aud_currentcredits		;CMOS: Current Credits
			tstb						;Max Credits allowed
			sec	
			ifne
				jsr	cmos_a				;CMOS, X -> A
				cba	
			endif
pull_ba_rts		pulb	
			pula	
			rts

;***********************************************
;* This routine is spawned as a thread when the
;* credits in memory space do not match
;* the number of credits in the CMOS RAM. It 
;* Takes care of bringing them equal in a timely
;* fashion and calling the game ROM hook each
;* time a credit is added to the memory location. 
;* With this, the game ROM can control the credit 
;* award process.
;***********************************************			
creditq		ldx	#aud_currentcredits		;CMOS: Current Credits
			jsr	cmosinc_b				;CMOS,X++ -> B
			cmpb	cred_b0
			ifne
				ldaa	cred_b0
				adda	#$01
				daa	
				staa	cred_b0
				ldx	gr_coin_hook_ptr			;Game ROM:
				cba	
				ifne
					jsr	$00,X					;jsr to Game ROM Credit Hook
					bra	creditq				;Loop it.
				endif
				jsr	$00,X					;jsr to Game ROM/bell?
			endif
			jmp	killthread				;Remove Current Thread from VM

;*************************************************
;* Some utility routines for getting data from
;* the CMOS RAM areas.
;*************************************************
ptrx_plus_1		psha	
			ldaa	#$01
			bra	ptrx_plus
ptrx_plus_a		psha	
ptrx_plus		pshb	
			stx	temp1
			jsr	cmosinc_b				;CMOS,X++ -> B
			pshb	
			jsr	cmosinc_b				;CMOS,X++ -> B
			aba	
			daa	
			tab	
			pula	
			adca	#$00
			daa	
			ldx	temp1
			jsr	a_cmosinc				;A -> CMOS,X++
			jsr	b_cmosinc				;B -> CMOS,X++
			ldx	temp1
			bra	pull_ba_rts				;pula, pulb, rts.
	
coin_accepted	
			;Starts with Macros
			.db $90,$03 	;MJSR $F7A7
			.db $7E,$E9,$C4  	;Push $EA67 into Control Loop with delay of #0E
			PRI_($0E) 		;Set this loops priority to #0E
			SLEEP_($20) 	;Delay $20
			CPUX_			;Resume CPU execution
			
			coma 
			adda	#$06
			asla 
			tab  					;A is 0,2,4  
			aslb 					;B is 0,4,8
			ldx  	#aud_leftcoins		;AUD: Coins Left/Center/Right Chute Base for counter
			jsr  	xplusb			;Adjust Pointer
			jsr  	ptrx_plus_1   		;Add 1 click to the counter
			ldx  	#cmos_pricingbase		;AUD: Coin Slot Multiplier Base
			jsr  	xplusa   			;Adjust Pointer
			jsr  	cmosinc_b    		;Get Multiplier into B
			bsr  	dec2hex    			;Make it hex
			ldx  	#cmos_bonusunits	
			bsr  	cmos_a_plus_b_cmos    	;Load Previous Coin Count, Add B, Save it in CMOS++
			bsr  	cmos_a_plus_b_cmos    	;Load A with CMOS $0164, add B, Save in CMOS++
			ldx  	#cmos_minimumcoins	;ADJ: Minimum Coin Units
			jsr  	cmosinc_b    		;Get Minimum Coin Amount into B
			cba  
			ifcc					;Have we met inserted minimum coins?
									;Yes!
				ldx  	#cmos_coinsforcredit	;ADJ: Coin Units required for Credit
				jsr  	cmosinc_b    		;Get Value
				bsr  	dec2hex    			;Convert Decimal(B) to Hex(B)
				bsr  	divide_ab
				staa  temp1
				ldx  	#cmos_coinunits		;Save remainder coin units for next time
				jsr  	b_cmosinc   		;( B -> CMOS,X++)
				ldx  	#cmos_bonuscoins		;ADJ: Coin Unit Bonus Point
				jsr  	cmosinc_b    		;( CMOS,X++ -> B )
				ldx  	#cmos_bonusunits	
				jsr  	cmosinc_a 			;( CMOS,X++ -> A )
				bsr  	dec2hex    			;Convert Decimal(B) to Hex(B)
				bsr  	divide_ab
				tsta 
				ifne
					bsr	clr_bonus_coins
				endif
				adda 	temp1
				daa  
				ldx  	#aud_paidcredits		;AUD: Total Paid Credits
				jsr  	ptrx_plus_a    		;Add A to data at X:
				jmp  	addcredits    		;Add Credits if Possible
			endif
			ldaa 	gr_creditsound		;Game ROM Data: Credit Sound
			jmp  	isnd_once			;Play Sound Index(A) Once

;*********************************************************
;* Load A with value in X, Add B, Save to CMOS and 
;* post increment
;*********************************************************
cmos_a_plus_b_cmos	
			jsr	cmos_a			;CMOS, X -> A 
			aba	
			jmp	a_cmosinc			;A -> CMOS,X++

;********************************************************
;* Divides A by B, returns result in A and remainder in
;* B. Input values are in Hex and not decimal.
;********************************************************			
divide_ab		stab	temp2+1
			ifne
				tab	
				ldaa	#$99	
				begin
					adda	#$01
					daa	
					subb	temp2+1
				csend
				addb	temp2+1
				rts	
			endif
			tba	
			rts

;********************************************************
;* Cleans out any half credits and bonus coins
;********************************************************			
clr_bonus_coins	ldx	#0000
			stx	cmos_coinunits
			stx	cmos_bonusunits
			rts	

;********************************************************
;* Convert 2 digit decimal value into a hex number
;*
;* Requires:	Decimal Number in B
;* Protects:	A
;* Destroys:	
;* Output:		Hex Number in B
;********************************************************
dec2hex		psha	
			tba	
			clrb	
			begin
				tsta	
				beq	to_pula_rts		;done
				adda	#$99
				daa	
				incb	
			loopend			;Loop forever

;*********************************************************
;* Stores A from X to X+B
;* 
;* Requires:	A,B,X
;* Destroys:	B
;********************************************************			
write_range		
			begin
				staa	$00,X
				inx	
				decb	
			eqend
			rts	

;*********************************************************
;* Initialzes a new game.
;*********************************************************			
do_game_init	ldx	gr_game_hook_ptr			;Game Start Hook
			jsr	$00,X					;jsr to Game ROM Hook
			jsr	dump_score_queue			;Clean the score queue
			bsr	clear_displays			;Blank all Player Displays (buffer 0)
			deca
			staa	mbip_b0
			bsr	initialize_game			;Remove one Credit, init some game variables
			bsr	add_player				;Add one Player
			jmp	init_player_up

			
F8C4: BD D0 BE    jsr   $D0BE
F8C7: 7C 00 EA    INC   num_players
F8CA: D6 EA       ldab   num_players
F8CC: 8D 5E       bsr   $F92C

F8CE: CE D0 57    ldx   #D057
F8D1: BD EE 8C    jsr   xplusb
F8D4: A6 00       ldaa   $00,X
F8D6: BD EC 3B    jsr   isnd_once
F8D9: CE 01 93    ldx   #adj_energystandard
F8DC: BD EE 92    jsr   cmosinc_a		 ( CMOS,X++ -> A)
F8DF: 8A F0       oraa   #F0
F8E1: 5D          TSTB  
F8E2: 27 04       beq   $F8E8
F8E4: 97 5C       staa   mbip_b0
F8E6: 20 02       bra   $F8EA

;****************************************************
;* Add Player: Increments player count and loads    
;*             default game data for that player.  
;*             Plays start sound and inits display.
;*
;* Requires:   No Variables
;****************************************************			
add_player		jsr	gr_addplayer_event		;(RTS)
			inc	num_players				;Add One Player
			ldab	num_players
			bsr	init_player_game			;Put the Default(game start) data into Current Players Game Data Buffer
			ldx	#gr_p1_startsound			;Game ROM Table: Player Start Sounds
			jsr	xplusb				;X = X + B)
			ldaa	$00,X
			jsr	isnd_once				;Play Player Start Sound From Game ROM Table
			ldx	#score_p1_b0
			jsr	xplusb				;X = X + B)
			ora	#$F0
			tstb
			ifne
				staa	mbip_b0
			else
				staa	cred_b0
			endif
			aslb
			aslb
			ldx	#score_p1_b0
			clr	$03,X
			rts

;****************************************************	
;* Sets up all gameplay variables for a new game.
;****************************************************		
initialize_game	clra	
			staa	flag_timer_bip			;Ball in Play Flag
			staa	player_up				;Default player 1 DOH
			staa	flag_gameover			;Game Play On
			staa	comma_flags
			ldab	#$08
			jsr	kill_threads
			deca	
			staa	num_players				;Subtract one Credit
			ldab	#$0C
			ldx	#$0022				;Clear RAM $0022-002E
clear_range		psha	
			clra	
			bsr	write_range				;Store A from X to X+B
to_pula_rts		pula	
			rts	

;******************************************************
;* Resets all player display scores to Blank 'FFFFFFFF'
;******************************************************			
clear_displays	ldaa	#$FF
			ldab	#$10
			ldx	#score_p1_b0
			bsr	write_range				;Store A from X to X+B
			clra	
			ldab	#$0C
			ldx	#alpha_b0
			bsr	write_range
			
store_display_mask
			clra
			staa	dmask_p1				;These are the Display Buffer Toggles
			staa	dmask_p2
			staa	dmask_p3
			staa	dmask_p4
			rts	

;**********************************************************
;* Loads the default game data into the player number 
;* passed in B.
;*
;* Requires:    	Player Number to init in B
;* Destroys:    	X
;* Protects:	A,B
;**********************************************************			
init_player_game	psha	
			pshb	
			bsr	setplayerbuffer			;Set up the Pointer to the Players Buffer
			bsr	copyplayerdata			;Copy Default Player Data into Player Buffer (X)
			ldx	temp1
			ldab	#$06
			bsr	clear_range				;Clear Remaining Part of Player Game Data Buffer
			pulb	
			pula	
			rts	

;**********************************************************
;* Will set up X to point at the start of the player 
;* specified in B.
;*
;* Requires:   	Player Number in B
;* Destroys:	A,B
;* Protects:	None
;* Output:		X
;**********************************************************			
setplayerbuffer	ldaa	#_gamedata_size			;Length of Player Buffer
			ldx	#(p1_gamedata-_gamedata_size)	;Player 1 base
			begin
				jsr	xplusa	;X = X + A
				decb	
			miend
			rts	

;***********************************************************
;* Copies Player default data from game ROM to the player 
;* buffer specified by X.
;*
;* Requires: Player Buffer to Fill in X
;***********************************************************			
copyplayerdata	stx	temp1
			ldx	#gr_playerstartdata		;*** Table Pointer ***
			ldab	#$1E
			jmp	copyblock				;Copy Block: X -> temp1 B=Length

;***********************************************************
;
;***********************************************************
init_player_up	bsr   init_player_sys
			ldx   cred_b0
			ldab   player_up
			ifne
				ldx   mbip_b0
			endif
			ldaa   $00,X
			ifmi
				anda  #0F
			endif
			adda  #99
			daa   
			cmpa  #10
			iflt
				oraa   #F0
			endif
			staa	$00,X
			bsr   resetplayerdata
			ldx   gr_player_hook_ptr
			jsr   $00,X
			begin
player_ready		jsr   addthread		;Push Following Routine onto Control Stack with Timer
				.db $05          		;Timer Data
				;This following loop makes the current players
				;score flash until any score is made.
				bsr   disp_mask
				coma  
				anda  comma_flags
				staa  comma_flags
				bsr   disp_clear
				ldx   current_thread
				ldaa  #07
				staa  threadobj_id,X
				ldx   dmask_p1
				jsr   xplusb
				ldaa  $00,X
				oraa	#7F
				staa  $00,X
				jsr   addthread				;Push Following Routine onto Control Stack with Timer
				.db	$05
				jsr   gr_ready_event			;Game ROM Hook
				ldaa  $00,X
				anda  #$80
				staa  $00,X
				jsr   update_commas
				ldx   current_thread
				ldaa  #04
				staa  threadobj_id,X
				ldaa  flag_timer_bip
			neend
			jmp   killthread			;Remove Current Thread from Control Stack

disp_mask		ldab	player_up				;Current Player Up (0-3)
			ldx	#comma_million			;Comma Tables
			jsr	xplusb				;X = X + B)
			ldaa	$00,X					;comma_million: 40 04 80 08
			oraa	$04,X					;comma_thousand: 10 01 20 02
			rts	
			
disp_clear		ldx	pscore_buf				;Start of Current Player Score Buffer
			ldaa	#$FF
			staa	$08,X
			staa	$09,X
			staa	$0A,X
			staa	$0B,X
			rts	

;********************************************************
;* Initializes new player. Clears tilt counter, reset 
;* bonus ball enable, enables flippers, Loads Player 
;* score buffer pointer.
;********************************************************			
init_player_sys	ldaa	switch_debounced
			anda	#$FE
			staa	switch_debounced				;Blank the Tilt Lines?
			clra	
			staa	flag_tilt				;Clear Tilt Flag
			staa	num_tilt				;Clear Plumb Bob Tilts
			staa	random_bool			;Enable Bonus Ball
			ldaa	#$F9
			jsr	solbuf				;Turn on Solenoid $18 (Flipper Enable?)
			ldaa	player_up				;Current Player Up (0-3)
			asla	
			asla	
			ldx	#score_p1_b0
			jsr	xplusa				;X= P1:0038 P2:003C P3:0040 P4:0044
			stx	pscore_buf				;Pointer to Start of Score Buffer 0
			rts	

;*********************************************************
;* Applies Game ROM mask to player game data to reset 
;* specific bits of data. Loads the flashing lamp data
;* Resets Player game data at start of RAM.
;*********************************************************	
resetplayerdata	ldx	#lampbuffer0
			stx	temp1					;temp1 Points to Base of Lamp Matrix Data
			jsr	setplayerbuffer			
			stx	temp2					;temp2 Points to Base of Player Game Data Buffer
			ldx	#gr_playerstartdata		;X points to base of default player data
			begin
				ldaa	$1E,X					;Get Game Data Reset Data
				tab	
				comb	
				andb	$00,X					;AND !B with Players Last Lamps
				inx	
				stx	temp3					;X points to base of default player data +1
				ldx	temp2					;Player Game Data Buffer
				anda	$00,X
				inx	
				stx	temp2
				aba	
				ldx	temp1
				staa	$00,X
				inx	
				cpx	#$0022
				ifeq
					ldx	#lampflashflag
				endif
				stx	temp1
				ldx	temp3
				cpx	#gr_playerresetdata		;End of Default Player Game Data
			eqend						;Loop it!
			ldx	#$0002
			stx	temp1
			ldx	temp2
			ldab	#$06
			bsr	to_copyblock			;Copy Data Block: Current Game Data 0-6 -> Player Game Data 0-6
			jmp	coinlockout				;Check Max Credits, Adjust Coin Lockout If Necessary 

;*********************************************************************
;* Scoring Queue: This will bring all scores up to date with current *
;*                scores waiting to be applied.                      *
;*********************************************************************			
dump_score_queue	ldx	#score_queue
			ldaa	#$0F
			begin
				ldab	$00,X
				ifne
					begin
						jsr	score_main				;Main Add Points Routine
						dec	$00,X
					eqend
				endif
				inx	
				deca	
				bita	#$08
			eqend
			rts	

;*********************************************************************
;* Main Outhole Routine: The outhole switch will jump here on closure
;*********************************************************************			
outhole_main	bsr	dump_score_queue			
			jsr	macro_start				;Start Executing Macros
			
			.db $71          			;Delay 1
			.db $5A,$FE,$01,$01,$FA 	;Branch if Priority #01 to $F9B0
			.db $55,$0A,$00  			;Reset Threads Based on Priority #0A	
			CPUX_ 				;Resume CPU Execution

			ldx  	gr_outhole_hook_ptr		;Game ROM: Pointer
			jsr  	$00,X  				;JSR to GameROM
			clr  	flag_timer_bip			;Ball in Play Flag (Stop Timer)
			ldab  player_up     			;Current Player Up (0-3)
			bsr  	saveplayertobuffer    		;Save Player Data to Buffer
			bsr  	balladjust				;Do Outhole Processing (EB, Bonus Ball)
			jmp  	init_player_up			;Init New Player Up

;*********************************************************************
;* Save Player Data: This will save lamp and game specific data to   
;*                   the holding area so information can carrry from 
;*                   ball to ball.            
;*********************************************************************
saveplayertobuffer	
			jsr	setplayerbuffer			;X=#1126+((B+1)*#1A))
			stx	temp1
			ldx	#lampbuffer0
			ldab	#$12
			bsr	to_copyblock			;Save current lamp settings
			ldx	#lampflashflag
			ldab	#$0C
			bsr	to_copyblock			;Save Flashing lamps too!
			ldx	#$0002
			ldab	#$06
to_copyblock	jmp	copyblock				;Finally, save player game data.

;*********************************************************************
;* Ball Update: This will increment to next player if there is one   
;*              or will increment to next ball. If we are on the last
;*              ball then it jumps to the gameover handler.
;*********************************************************************
balladjust		ldx   #aud_totalballs
			jsr   ptrx_plus_1	 Add 1 to data in X
badj_loop		clrb  
			ldaa   num_players
			ifne
				ldaa   player_up
				ifeq
					incb
				endif
				stab   player_up
				ifeq
					bsr   chk_p1
					beq   badj_p2
badj_rts				rts 
				endif
				ldaa   mbip_b0
				cmpa  #F0
				bne   badj_rts
badj_p2		      bsr   chk_p1
				bne   badj_loop
				cmpa  mbip_b0
				bne   badj_loop
			else
				bsr   chk_p1
				ifne
					rts 
chk_p1			      ldaa   cred_b0
					cmpa  #F0
					rts   
					ldx   #0054
					stx   temp1
					ldaa   #02
					begin
						ldab   #04
						ldx   #0166
						jsr   $FFCD
						deca  
					eqend
					rts  
				endif
			endif

gameover		jsr   gr_gameover_event
			ldx   #lampflashflag
			ldab  #$0C
			jsr   clear_range
			bra   check_hstd

endgame		ldaa  gr_gameoversound
			jsr   isnd_once
			;fall through to init

powerup_init	ldaa	gr_gameover_lamp			;Game ROM: Game Over Lamp Location
			jsr	macro_start				;Start Macro Execution
			
			SOL_($F8)				;Turn Off Solenoid: Shooter/BallLift Disabled
			.db $17,$00 			;Flash Lamp: Lamp Locatation at RAM $00
			CPUX_ 				;Resume CPU execution
set_gameover	inc	flag_gameover			;Set Game Over
			ldx	gr_gameoverthread_ptr		;Game ROM: Init Pointer
			jsr	newthread_06			;Push VM: Data in A,B,X,$A6,$A7,$AA=#06
			bne	store_display_mask		
			jmp	killthread				;Remove Current Thread from VM


get_aud_baseawd
			ldx   #0146
			ldaa   player_up
			ifne   
				ldx   #0148
			rts   

check_hstd		ldx	#adj_backuphstd			;CMOS: Backup HSTD
			jsr	cmosinc_a				;CMOS,X++ -> A
			ifne						;No award if backup HSTD is 0,000,000
				clr	sys_temp2
				ldab	#$04
				stab	sys_temp1
				ldx	#score_p1_b0-3			;Start High and work down low on the digits
				stx	sys_temp5
				begin
					ldab	#$04
					stab	sys_temp_w3				;Number of score Bytes Per Player
					ldx	#aud_currenthstd			;CMOS: Current HSTD
					begin
						jsr	cmosinc_b				;CMOS,X++ -> B
						stx	sys_temp_w2
						ldx	sys_temp5
						jsr	score2hex				;Convert MSD Blanks to 0's on (X+03)
						cba	
						bhi	update_hstd				;HSTD beat by this digit, adjust HSTD so we dont have multiple awards by each player beating HSTD.
						bne	hstd_adddig				;$A4=$A4+$A8
						inx						;Next Digit
						stx	sys_temp5				;Store it
						ldx	sys_temp_w2				;Next HSDT Digit (pointer)
						dec	sys_temp_w3				;Goto Next Set of Digits
					eqend						;Loop for all (4)2 digits
hstd_nextp			dec	sys_temp1				;Goto Next Player
				eqend						;Loop for all 4 Players
				ldaa	sys_temp2
				ifne
					ldx	gr_highscoresound			;Game ROM Data: High Score Sound
					jmp   $00,X
set_hstd				ldaa	aud_currenthstd			;HSTD High Digit
					anda	#$0F
					ifne					;Branch if Score is under 10 million
						ldaa	#$99
						bsr	fill_hstd_digits			;Set HSTD to 9,999,999
						clr	aud_currenthstd			;Clear 10 Million Digit
					endif
				endif
			endif
			jmp   endgame

update_hstd		ldx	#aud_currenthstd			;Current HSTD
			ldaa	sys_temp1
			staa	sys_temp2
			stx	temp1
			bsr	wordplusbyte			;Add Byte to Word: $A4=$A4+$A8 00->$A8
			ldab	#$04
			dex	
			jsr	copyblock2				;Transfer Data Block at X to temp1, Length B
			inc	aud_currenthstd			;Adjust HSTD to new player score
			ldaa	aud_currenthstd+1
			inca	
			anda	#$0F
			bne	hstd_nextp				;Go Check Next Player Score
			clr	aud_currenthstd+1
hstd_adddig		bsr	wordplusbyte			;Add Byte to Word: $A4=$A4+$A8 00->$A8
			bra	hstd_nextp				;Go Check Next Player Score
			
;*************************************************
;* Add LSB of sys_temp_w3 to sys_temp5
;*************************************************
wordplusbyte	ldx	sys_temp5
			ldaa	sys_temp_w3
			clr	sys_temp_w3
			jsr	xplusa				;X = X + A
			stx	sys_temp5
to_rts1		rts	
			
;**************************************************
;* This routine will fill the value of A into all
;* high score digit data.
;**************************************************
fill_hstd_digits	ldx	#aud_currenthstd			;CMOS: Current HSTD
			ldab	#$04
			begin
				jsr	a_cmosinc				;A -> CMOS,X++)
				decb	
			eqend
			rts
				
send_sound		begin
				jsr	addthread				;End This Routine, Replace with next routine, next byte is timer.
				.db 	$02
				ldaa  $C1					;Sound Flag?
		      eqend
		      rts 

;******************************************************
;* Get Random: Will pull various system variables and
;*             calculate a pseudo-random number.
;******************************************************			
get_random		pshb	
			ldaa	randomseed				;This is changed by Switch Closures
			tab	
			rorb	
			rorb	
			staa	temp1					;Use some Temp variables for data
			eorb	temp1
			rolb	
			rola	
			staa	randomseed
			adda	irq_counter					;Throw in some switch matrix stuff
			pulb	
to_rts2		rts

;********************************************************
;* Credit Button Press: 
;********************************************************
credit_button	ldx	#adj_max_credits			;CMOS: Max. Credits
			jsr	cmosinc_b				;CMOS,X++ -> B
			ldx	#aud_currentcredits		;CMOS: Current Credits
			jsr	cmos_a				;CMOS, X -> A )
			bne	has_credit
			tstb						;No credits, check for free play
			ifeq						;No Free Play, get outta here.
has_credit			ldab	flag_gameover			;Has valid credit or freeplay, is Game Over?
				bne	start_new_game			;No, goto Start New Game
				stx	sys_temp_w2
				ldx	#adj_energystandard
				jsr	cmosinc_b				;CMOS,X++ -> B
				ldx	sys_temp_w2
				decb
				orab	#$F0
				cmpb	cred_b0
				ifle
					ldab	num_players				;Current # of Players
					cmpb	gr_numplayers			;Max # of Players (Game ROM data)
				ifcs						;Already 4 players, outta here.
					bsr	lesscredit				;Subtract a credit
					jsr	add_player				;Add a player.
				endif
			endif
			jmp	killthread				;Remove Current Thread from VM

;*********************************************************
;* Resets Games and Starts Anew
;*********************************************************
start_new_game	bsr	lesscredit				;Subtract a credit
			jmp	do_game_init			;Init Player 1

;*********************************************************
;* Removes a credit and adjusts coin lockout and credit 
;* lamp appropriately. Also updates audits.
;*
;* 	Current Credits in A.
;*********************************************************
lesscredit		tsta	
			ifne						;Is it Zero?
				adda	#$99					;Subtract 1 credit
				daa						;dont' forget to adjust
				jsr	a_cmosinc				;A -> CMOS,X++)
				ldaa	current_credits				;Current Credits
				adda	#$99					;Subtract 1
				daa	
				staa	current_credits				;Store Credits
			endif
			jsr	coinlockout				;Check Max Credits, Adjust Coin Lockout If Necessary
			jsr	clr_bonus_coins			;Reset Any Bonus Coins... too bad!
			ldx	#aud_totalcredits			;Audit: Total Credits
			jmp	ptrx_plus_1				;Add 1 to data at X

;*********************************************************
;* Tilt Contacts
;*********************************************************			
tilt_warning	inc	num_tilt				;Add 1 Tilt
			ldaa	adj_maxplumbbobtilts+1		;ADJ: LSD Max Plumb Bob Tilts
			anda	#$0F
			cmpa	num_tilt				;Current # of Plumb Bob Tilts
			bhi	to_rts2				;Not enough warnings yet.. Leave now!
do_tilt		ldaa	gr_tilt_lamp			;Game ROM: Tilt Lamp Location
			staa	flag_tilt				;Tilt Flag
			jsr	macro_start				;Start Macro Execution-
			
			.db $14,$00 		;Turn on Tilt Lamp
			REMTHREADS_($0C,$00)	;.db $55,$0C,$00  	;Get Rid of non-tilt threads
			CPUX_				;Return to Program Execution 
			rts


;***********************************************************
;* Self Test Routines Begin Here, first some data tables
;***********************************************************
;* Define our test entry points
;***********************************************
testdata		.dw st_display
			.dw st_sound
			.dw st_lamp
			.dw st_solenoid
			.dw st_switch

;***********************************************
;* This table defines which routines
;* handel the various adjustment displays.
;***********************************************			
testlists		.db $00		;Function 00:    Game Identification
			.dw fn_gameid	;$FD,$23
			.db $01		;Function 01-11: System Audits
			.dw fn_sysaud	;$FD,$30
			.db $0C		;Function 12:    Current HSTD
			.dw fn_hstd		;$FD,$A9
			.db $0D		;Function 13-17: Backup HSTD and Replays
			.dw fn_replay	;$FD,$B1
			.db $12		;Function 18:    Max Credits
			.dw fn_credit	;$FE,$26
			.db $13		;Function 19:    Pricing Control
			.dw fn_pricec	;$FD,$EF
			.db $14		;Function 20-25: Pricing Settings
			.dw fn_prices	;$FE,$09
			.db $1A		;Function 26-41: System and Game Adjustments
			.dw fn_adj		;$FE,$33
			.db $2A		;Function 42-49: Game Audits
			.dw fn_gameaud	;$FD,$2E
			.db $32		;Function 50:    Command Mode
			.dw fn_command	;$FE,$3E
			.db $33

;************************************************
;* Main Self-Test Routine
;************************************************
test_number =	$000e			;RAM Location to store where we are...
test_lamptimer =	$000f			;Timer for Lamp test loop

selftest_entry	bsr	check_adv				;Advance: - if Triggered
			ifpl
				jmp	killthread				;Kill Current Thread
			endif
			ldaa	#09
			jsr	solbuf
			bsr	st_init				;Set up self test
			bsr	check_aumd				;AUMD: + if Manual-Down
			bmi	do_audadj				;Auto-Up, go do audits and adjustments instead
			clra	
st_diagnostics	clr	test_number				;Start at 0
			ldx	#testdata				;Macro Pointer
			psha	
			ldaa	#09
			jsr	solbuf
			pula
			psha
			jsr	gettabledata_b			;Load up the pointer to our test routine in X
			pula	
			tab	
			decb						;Adjust back down to where it was before table lookup incremented it
			stab	cred_b0				;Show the test number in display
			jsr	newthread_06			;Start a new thread with our test routine
			jsr	addthread				;End This Routine, Replace with next routine, next byte is timer.
			.db	$10	
			;This is the Advance button handler, it runs as a seperate thread to the test routine
			begin
				begin
					bsr	check_adv			;Advance: Stay here forever until pressed			   
				miend
				bsr	check_aumd				;AUMD: + if Manual-Down
				bmi	st_nexttest				;Do next test...
				stab	test_number
				begin
					bsr	check_adv			;Advance: Stay here forever until released
				plend
			loopend

;*******************************************************
;*
;*******************************************************			
do_aumd		psha	
			ldaa	flags_selftest
			ifpl
				bsr	check_aumd					;AUMD: + if Manual-Down
				ifpl
					ldaa	test_number
					ifne
						clra	
						staa	test_number
						deca	
					endif
				endif
			endif
			pula	
			rts

;*********************************************************
;* This will check the state of the advance switch and
;* return the control register results
;*********************************************************				
check_adv		ldab	pia_disp_digit_data		;Dummy read to clear previous results
			jsr	addthread				;End This Routine, Replace with next routine, next byte is timer.
			.db	$02
			ldab	pia_disp_digit_ctrl
			rts

;*********************************************************
;* This routine will check the state of the Up/Down toggle
;* switch. First do a dummy read to clear previous results
;*********************************************************
check_aumd		ldab	pia_disp_seg_data			;Dummy read to clear previous results
			jsr	addthread				;End This Routine, Replace with next routine, next byte is timer.
			.db	$02
			ldab	pia_disp_seg_ctrl
			rts 

;**************************************************
;* Self Test Initializations:
;*	Remove all VM Threads
;*	Disable Solenoids
;*	Clear RAM
;**************************************************
st_init		clrb	
			jsr	kill_threads			;Remove All VM Threads 
			inc	flags_selftest			;Set Test Flag
			ldx	#ram_base
			ldab	#$A5
to_clear_range	jmp	clear_range				;Clear RAM from $0000-0089

;**************************************************
;* Next Test: Will advance diagnostics to next
;*            test in sequence, if done, then fall
;*            through to audits/adjustments
;**************************************************
st_nexttest		ldab	#$3C
			ldx	#lampbuffer0
			bsr	to_clear_range			;Clear RAM from $0010-0038
			jsr	kill_threads			;Remove all VM Threads
			inca	
			cmpa	#$05					;are we done yet?
			bne	st_diagnostics			;Goto back to Self-Test Diagnostics routine
			;Fall through if finished
			
;**************************************************
;* Main Audit/Adjustments Process Entry
;**************************************************			
to_audadj		bsr	st_init				;Clear all RAM and set up self testing
do_audadj		clr	mbip_b0
			ldaa	#$04					;Show test 04 by default
			staa	cred_b0
			jsr	addthread				;Wait $10
			.db 	$10
			begin
				jsr	clear_displays			;Blank all Player Displays (buffer 0)
				bsr	b_129					;#08 -> $0F
				ldab	mbip_b0
				jsr	dec2hex				;Convert Decimal(B) to Hex(B)
				ldx	#testlists-3
				begin
					inx	
					inx	
					inx	
					cmpb	$03,X					;Are we at next handler?
				csend
				ldx	$01,X					;Load the routine
				jsr	$00,X					;Do the routine to load up data into displays
				begin
					bsr	check_adv			;Advance: - if Triggered
				miend
b_133				bsr	b_129					;#08 -> $0F
show_func			bsr	check_adv				;Advance: - if Triggered
			miend
			bsr	b_12D
			bne	show_func				;Look at the buttons again
			bsr	adjust_func				;Add or subtract the function number?
			adda	mbip_b0				;Change it
			daa	
			cmpa	#$51					;Are we now on audit 51??
			beq	st_reset				;Yes, Blank displays, reboot game
			cmpa	#$99					;Going down, are we minus now??
			ifeq
				ldaa	#$50					;Yes, wrap around to 50
			endif
			staa	mbip_b0				;Store new value
			bra	show_func				;Look at the buttons again

b_129			ldaa	#$08
			staa	$000F
			rts	
			
b_12D			ldaa	$000F
			ifne
				dec	$000F
				cmpa	#$08
			endif
			rts

			begin
				bsr	b_129					;#08 -> $0F
b_135				jsr	check_adv				;Advance: - if Triggered
				bmi	b_133
				ldaa	switch_masked
				bita	#$04
			neend
			bsr	b_12D
			bne	b_135
adjust_func		ldaa	#$99
			jsr	check_aumd				;AUMD: + if Manual-Down
			ifmi
				ldaa	#$01
			endif
			tab	
			rts

st_reset		ldaa	#$FF
			staa	mbip_b0
			staa	cred_b0
			jsr	addthread				;End This Routine, Replace with next routine, next byte is timer.
			.db 	$50
			jmp	reset					;Goto Reset Entry

;************************************************************
;* Self Test Audit and Adjustment Handlers:
;* 	These routines are in charge of the functions shown
;* 	in the self test routines. Each one handles one or
;*    more functions to retrieve and display the proper 
;*    data on the various displays.
;************************************************************			
fn_gameid		ldx	gr_gamenumber
			stx	score_p1_b0+1			;Game # -> Player 1 Display
			ldaa	gr_romrevision
			staa	score_p1_b0+3			;ROM Rev -> Player Display
			rts	   

fn_gameaud		subb	#$1E
fn_sysaud		aslb	
			aslb	
			ldx	#$00FE
			jsr	xplusb				;X = X + B)
			jsr	cmosinc_a				;CMOS,X++ -> A
			staa	score_p1_b0+2
			jsr	cmosinc_a				;CMOS,X++ -> A
			staa	score_p1_b0+3			;Show Data in Player 1 Display
			rts

fn_hstd		jsr	show_hstd				;Puts HSTD in All Player Displays(Buffer 1)
			ldaa	#$7F
			staa	dmask_p1
			rts

fn_replay		ldx	#adj_backuphstd			;Offset to Replay Levels
			subb	#$0D					;Subtract 13 to get correct base
			aslb						;*2  2 bytes data per level(replay score)
			jsr	xplusb				;X = X + B)
			stx	vm_pc					;Pointer to Current Replay Level Data
			aslb						;*2  4 bytes data per level(times exceeded)
			ldx	#aud_hstdcredits			;Offset to Replay Level Times Exceeded
			jsr	xplusb				;X = X + B)
			jsr	cmosinc_a				;CMOS,X++ -> A
			staa	score_p2_b0+2			;Show Times Exceeded MSD's in Player 2 Display
			jsr	cmosinc_a				;CMOS,X++ -> A
			staa	score_p2_b0+3			;Show Times Exceeded LSD's in Player 2 Display
			clrb	
			begin
				ldx	vm_pc					;reload current offset * 2
				bsr	cmos_add_d				;Decimal Add B to CMOS,X(nopostinc), Tst A
				tab	
				jsr	split_ab				;Shift the digits around for display
				anda	#$F0					;Blank MSD (10,000,000 digit)
				stab	score_p1_b0				;Show it.
				staa	score_p1_b0+1			;Player 1 Display
				clrb	
				stab	score_p1_b0+2			;Lay down some Zero's
				stab	score_p1_b0+3			
				jsr	b_135
			loopend

cmos_add_d		bsr	cmos_a				;CMOS, X -> A )
			aba	
			daa	
			jsr	a_cmosinc				;A -> CMOS,X++)
			bra	fn_ret				;dex,dex,tsta,rts.

fn_pricec		clrb	
			begin
				begin
					ldx	#adj_pricecontrol			;Standard/Custom Pricing Control
					jsr	cmos_add_d				;Decimal Add B to CMOS,X(nopostinc), Tst A
					ldab	#$99
					cmpa	#$09
				csend					;Custom Pricing = 09?
				staa	score_p1_b0+3			;Player 1 Display
				tab	
				ifne
					jsr	loadpricing
				endif
				jsr	b_135
			loopend

fn_prices		ldx	#cmos_leftcoinmult		;Left Coin Slot Multiplier
			subb	#$14
			aslb	
			jsr	xplusb				;X = X + B)
			jsr	cmos_a				;CMOS, X -> A )
			staa	score_p1_b0+3			;Player 1 Display
			ldaa	adj_pricecontrol+1		;Standard/Custom Pricing Control LSD
			anda	#$0F
			beq	fn_cdtbtn
			rts 

cmos_a		jsr	cmosinc_a				;CMOS,X++ -> A
fn_ret		dex	
			dex	
			tsta	
			rts

fn_credit		ldx	#adj_max_credits			;RAM Pointer Base
fn_cdtbtn		clrb
			begin
				bsr	cmos_add_d				;Decimal Add B to CMOS,X(nopostinc), Tst A
				staa	score_p1_b0+3			;Player 1 Display
				jsr	b_135
			loopend

fn_adj		ldx	#adj_matchenable			;RAM Pointer Base
			subb	#$1A
			aslb	
			jsr	xplusb				;X = X + B)
			bra	fn_cdtbtn
			
fn_command		ldx	#aud_command			;RAM Pointer Base
			bra	fn_cdtbtn

;****************************************************
;* Main Display Test Routine - Cycles all score 
;*                             displays through 0-9
;****************************************************			
st_display		begin
				clra
				begin	
					begin
						ldx	#score_p1_b0
						ldab	#$14
						jsr	write_range				;RAM $38-$5B = A: Clear all Displays
						psha
						bita	#$01
						ifne
							ldaa	#$CF
						else
							ldaa	#$2C
						endif
						ldab	#$0C
						ldx	#alpha_b0
						jsr	write_range
						pula
						jsr	addthread				;End This Routine, Replace with next routine, next byte is timer.
						.db	$18
						jsr	do_aumd				;Check Auto/Manual, return + if Manual
					miend
					com	comma_flags				;Toggle commas on each count
					adda	#$11					;Add one to each digit
					daa	
				csend
				ldab	flags_selftest
			miend				;Clear All Displays
			rts

;****************************************************
;* Main Sound Routine - Toggles each of the sound 
;*                      command line individually.
;****************************************************			
st_sound		jsr	clear_displays			;Blank all Player Displays (buffer 0)
			begin
				clra	
				staa	comma_flags				;Turn off commas
				staa	mbip_b0				;Match/Ball in Play Display = 00
				ldaa	#$FE					;Initial Sound Command $1E
				begin
					begin
						ldab	#$FF
						stab	pia_sound_data			;Sound Blanking
						jsr	addthread				;Delay enough for sound board to stop
						.db	$00	
						staa	pia_sound_data			;Commands.. $1E,$1D,$1B,$17,$0F
						jsr	addthread				;Delay $40 IRQ's
						.db	$40
						jsr	do_aumd				;Either repeat same sound or move on to next
					miend
					inc	mbip_b0				;Increment Match/Ball in Play Display
					asla	
					inca	
				plend
				ldab	flags_selftest
			miend					;Start Over
			rts

;****************************************************
;* Main Lamp Routine - Flashes all lamps 
;****************************************************			
st_lamp		ldab	#$AA
			stab	mbip_b0				;Match/Ball in Play Display Buffer 0
			stab	test_lamptimer
			begin
				begin
					ldaa	lampbuffer0
					coma	
					ldx	#lampbuffer0
					ldab	#$0C
					jsr	write_range				;Store A from $0010-0017
					jsr	addthread				;End This Routine, Replace with next routine, next byte is timer.
					.db	$1B
					dec  	test_lamptimer
				eqend
				ldab  flags_selftest			;Auto-Cycle??
			miend
			rts 

;****************************************************
;* Auto-Cycle Routine - This is the timing thread to
;*                      allow each test routine to 
;*                      repeat indefinitely.
;****************************************************			
st_autocycle	jsr  	st_init
			decb 
			stab  flags_selftest
			begin
				jsr  	st_display    		;Clear All Displays
				clr  	cred_b0
				bsr  	st_sound
				inc  	cred_b0
				bsr  	st_lamp
				inc  	cred_b0
				bsr  	st_solenoid
				ldx  	#aud_autocycles		;Audit: Auto-Cycles
				jsr  	ptrx_plus_1 		;Add 1 to data at X
			loopend

st_solenoid
FE9C: 86 F9       ldaa   #F9
FE9E: BD EA 83    jsr   solbuf
FEA1: C6 01       ldab   #01
FEA3: D7 5C       stab   mbip_b0
FEA5: 86 20       ldaa   #20
FEA7: 85 08       BITA  #08
FEA9: 27 04       beq   $FEAF
FEAB: 8D 1F       bsr   $FECC
FEAD: 20 07       bra   $FEB6
FEAF: BD EA 83    jsr   solbuf
FEB2: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
FEB5: 20 
FEB6: BD E9 7C    jsr	$E97C	Push Following Routine onto Control Stack with Timer
FEB9: 20 
FEBA: BD FC 81 	jsr	$FC81
EFBD: 2A E8	  	BPL	$ 
FEBF: 4C          inca
FEC0: 7C 00 5C    INC   mbip_b0
FEC3: 81 09       cmpa  #09
FEC5: 26 E0       bne   $FEA7
FEC7: D6 E9       ldab   flags_selftest
FEC9: 2A D6       BPL   $FEA1
FECB: 39          rts   

;****************************************************
;* Main Solenoid Routine - Steps through each solenoid 
;****************************************************			
st_solenoid		ldaa	#$F9
			jsr	solbuf
			begin
				ldab  #$01
				stab 	mbip_b0	 
				ldaa 	#$20
				begin
					begin
						bita	#$08
						ifne
							bsr   solenoid_wait
						else
							jsr  	solbuf			;Turn On Outhole Solenoid
							jsr  	addthread    		;End This Routine, Replace with next routine, next byte is timer.
							.db	$20
							
						endif
						jsr  	addthread    		;End This Routine, Replace with next routine, next byte is timer.
						.db	$20
						jsr  	do_aumd			;AUMD: + if Manual-Down
					miend
					inca
					cmpa	#$09
				eqend
				ldab  flags_selftest			;Auto-Cycle??
			miend
			rts  

solenoid_wait
			begin
				ldab   solenoid_counter
			eqend
			ldaa   #08
			ldab   #0E
			pshb  
			jmp   set_sol_counter

st_switch
FED8: 86 FF       ldaa   #FF
FEDA: 97 5C       staa   mbip_b0
FEDC: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
FEDF: 00
FEE0: B6 D0 4D    ldaa   $D04D
FEE3: 4A          deca  
FEE4: 36          psha  
FEE5: FE D0 51    ldx   $D051
FEE8: C6 03       ldab   #03
FEEA: 4A          deca  
FEEB: 2B 05       BMI   $FEF2
FEED: BD EE 8C    jsr   xplusb
FEF0: 20 F8       bra   $FEEA
FEF2: A6 00       ldaa   $00,X
FEF4: 84 10       anda  #10
FEF6: 97 00       staa   vm_reg_a
FEF8: 32          pula  
FEF9: CE 00 85    ldx   #0085
FEFC: BD F2 12    jsr   $F212
FEFF: 7D 00 00    TST   vm_reg_a
FF02: 26 06       bne   $FF0A
FF04: E5 00       BITB  $00,X
FF06: 26 18       bne   $FF20
FF08: 20 04       bra   $FF0E

;****************************************************
;* Main Switch Routine - Scans for closed switches
;****************************************************			
st_switch		begin
				ldaa	#$FF
				staa  mbip_b0
				jsr  	addthread    		;End This Routine, Replace with next routine, next byte is timer.
				.db	$00
				ldaa 	gr_lastswitch		;Game ROM: Last Switch Used
				deca 
st_swnext			psha
				ldx  	#gr_switchtable_ptr
				ldab	#$03
				begin
					deca					;Switchtable entries are 3 bytes each
					bmi	st_dosw		
					jsr	xplusb
				loopend
st_dosw			ldaa	$00,X
				anda	$$10
				staa	vm_reg_a
				pula
				ldx	#switch_masked
				jsr  	unpack_byte    		;Unpack Switch
				tst	vm_reg_a
				ifeq
					bitb 	$00,X
					bne	$FF20
				else
					bitb 	$00,X
					beq   $FF20
				endif
				psha  
				inca  
				ldab  #01
				jsr   divide_ab
				staa   mbip_b0
				clra  
				jsr   isnd_once
				pula  
				jsr  	addthread    		;End This Routine, Replace with next routine, next byte is timer.
				.db	$30
				deca  
			plend
			bra 	st_swnext

;**********************************************************************************
;* NMI Routines - This section of code is run only when the 
;*                diagnostic switch on the CPU board is pressed.
;*                It will test the hardware and report any errors
;*                via the LED display on the CPU board. If all tests
;*                are passed, the LED display will show '0' and
;*                the code jumps to the normal power-up routines.
;*
;* Errors are as Follows:
;*
;*      0 - Test Passed
;*      1 - IC13 RAM Fault (Most Significant Nybble)
;*      2 - IC16 RAM Fault (Least Significant Nybble)
;*      3 - IC17 ROM 2 Fault (Location $F000-$FFFF)
;*      4 - IC14 ROM 1 Fault (Location $E000-$EFFF)
;*      5 - IC20 ROM 0 Fault (Location $D000-$DFFF)
;*      6 - Not Used
;*      7 - Not Used
;*      8 - IC19 CMOS RAM Fault or Memory Protect Failure
;*      9 - Coin Door Closed or Memory Protect Failure or IC19 CMOS RAM Fault
;**********************************************************************************
rambad		ldab	#$20
			eora	$00,X
			anda	#$F0
			beq	diag_showerror
			ldab	#$10
			bra	diag_showerror

;*******************************************************************
;* Main NMI Entry 
;*******************************************************************
diag			sei	
			ldx	#pia_disp_digit_data
			clr	$01,X
			ldaa	#$F0
			staa	$00,X
			ldab	#$3C
			stab	$01,X
			staa	$00,X			;Blank Diagnostic Display
			clra	
			begin
				ldx	#$1000
				begin					;\
					staa	$00,X			;|
					inx				;| Clear RAM $1000-13FF
					cpx	#$1400		;|
				eqend					;/
				txs	
				begin
					dex	
					cmpa	$00,X			;Test
					bne	rambad		;Bad RAM
					cpx	#$1000
				eqend
				coma					;Test with #FF
			eqend
			ldab	#$20					;Begin ROM Test
			ldx	#$FFFF
			begin
				stx	temp1
				addb	#$10
				dec	temp2
				bhi	diag_ramtest
				ldaa	temp1					
				suba	#$10
				staa	temp1					;Set our stopping address
				clra	
				begin
					adca	$00,X					;Add with carry!!
					dex	
					cpx	temp1
				eqend
				cmpa	#$80					;Done changing data?
			neend						;CSUM must be = #00
			;fall through on error, B contains error code
			
diag_showerror	comb	
			stab	pia_disp_digit_data		;Dump Error to Display
tightloop		bra	tightloop				;Stay Here forever


;Define a single CMOS location to write test
cmos_byteloc	=	$01BB

diag_ramtest	ldab	#$90					;Begin CMOS RAM Test
			ldaa	cmos_byteloc			;Test a single byte
			inc	cmos_byteloc
			cmpa	cmos_byteloc
			beq	diag_showerror			;Wrong
			ldab	#$80					;Backup CMOS data now
			ldx	#$1200
			stx	temp1
			ldx	#cmos_base
			bsr	block_copy					;Copy Block from X -> temp1, Length = B
			ldaa	#$F1
			staa	temp3
			begin				
				ldx	#cmos_base
				ldaa	temp3
				begin
					staa	$00,X
					bsr	adjust_a
				eqend
				ldx	#cmos_base
				ldaa	temp3
				begin
					tab	
					eorb	$00,X
					andb	#$0F
					bne	cmos_error
					bsr	adjust_a
				eqend
				inc	temp3
			eqend
			bsr	cmos_restore			;Put back original CMOS data
			jmp	reset					;Goto Reset Entry, Everything OK.

cmos_error		bsr	cmos_restore
			ldab	#$80
			bra	diag_showerror
			
block_copy		psha	
			begin
				jsr	cmosinc_a				;CMOS,X++ -> A
				stx	temp2
				ldx	temp1
				staa	$00,X
				inx	
				stx	temp1
				ldx	temp2
				decb	
			eqend
			pula	
			rts  

cmos_restore	ldx	#$0100
			stx	temp1
			ldx	#$1200
			ldab	#$80
			jmp	copyblock2				;Transfer Data Block at X to temp1, Length B
			
adjust_a		inca	
			ifeq
				ldaa	#$F1
			endif
			inx
			cmpx	#$02
			rts	

;*******************************************
;* CPU Startup/Interrupt Vectors go here.
;*******************************************
	
irq_entry		.dw gr_irq_entry	;Goes to Game ROM
swi_entry		.dw gr_swi_entry	;Goes to Game ROM 
nmi_entry		.dw diag
res_entry		.dw reset

	.end

;*******************************************
;* Exports for the Game ROM
;*******************************************

.export vm_reg_a,vm_reg_b,game_ram_2,game_ram_3,game_ram_4,game_ram_5,game_ram_6,game_ram_7,game_ram_8
.export game_ram_9,game_ram_a,game_ram_b,game_ram_c,game_ram_d,lampbuffer0,bitflags,lampbufferselect,lampbuffer1,lampflashflag
.export score_p1_b0,score_p3_b0,score_p4_b0,score_p1_b1,score_p2_b1,score_p3_b1,score_p4_b1,mbip_b0,mbip_b1,cred_b0,cred_b1
.export dmask_p1,dmask_p2,dmask_p3,dmask_p4,comma_flags,switch_debounced,switch_masked,switch_pending,switch_aux,switch_b4,irq_counter
.export lamp_index_word,lamp_bit,comma_data_temp,credp1p2_bufferselect,mbipp3p4_bufferselect,swap_player_displays,solenoid_address
.export solenoid_bitpos,solenoid_counter,irqcount16,switch_queue_pointer,solenoid_queue_pointer
.export temp1,temp2,temp3,sys_temp1,sys_temp2,sys_temp3,sys_temp4,sys_temp5,sw_encoded,sys_temp_w2,sys_temp_w3,thread_priority
.export unused_ram1,irqcount,vm_base,vm_nextslot,current_thread,vm_tail_thread,lamp_flash_rate,lamp_flash_count,thread_timer_byte
.export soundcount,lastsound,cur_sndflags,soundptr,soundirqcount,soundindex_com,sys_soundflags,soundindex,csound_timer,next_sndflags
.export next_sndcnt,next_sndcmd,flag_tilt,flag_gameover,flag_bonusball,flags_selftest,num_players,player_up
.export pscore_buf,num_eb,vm_pc,num_tilt,minutetimer,flag_timer_bip,randomseed,x_temp_1,eb_x_temp,credit_x_temp,x_temp_2,spare_ram
.export cmos_base,cmos_csum,aud_leftcoins
.export aud_centercoins,aud_rightcoins,aud_paidcredits,aud_specialcredits,aud_replaycredits,aud_matchcredits,aud_totalcredits
.export aud_extraballs,aud_avgballtime,aud_totalballs,aud_game1,aud_game2,aud_game3,aud_game4,aud_game5,aud_game6,aud_game7
.export aud_autocycles,aud_hstdcredits,aud_replay1times,aud_replay2times,aud_replay3times,aud_replay4times,cmos_bonusunits
.export cmos_coinunits,aud_currenthstd,aud_currentcredits,aud_command,adj_cmoscsum,adj_backuphstd,adj_replay1,adj_replay2
.export adj_replay3,adj_replay4,adj_matchenable,adj_specialaward,adj_replayaward,adj_maxplumbbobtilts,adj_numberofballs
.export adj_gameadjust1,adj_gameadjust2,adj_gameadjust3,adj_gameadjust4
.export adj_gameadjust5,adj_gameadjust6,adj_gameadjust7,adj_gameadjust8,adj_gameadjust9,adj_hstdcredits,adj_max_extraballs
.export adj_max_credits,adj_pricecontrol,cmos_leftcoinmult,cmos_centercoinmult,cmos_rightcoinmult,cmos_coinsforcredit
.export cmos_bonuscoins,cmos_minimumcoins,cmos_byteloc,switch_queue,sol_queue,score_queue,exe_buffer,p1_gamedata,p2_gamedata
.export p3_gamedata,p4_gamedata,pia_sound_data,pia_sound_ctrl,pia_comma_data,pia_comma_ctrl,pia_sol_low_data,pia_sol_low_ctrl
.export pia_sol_high_data,pia_sol_high_ctrl,pia_lamp_row_data,pia_lamp_row_ctrl,pia_lamp_col_data,pia_lamp_col_ctrl,pia_disp_digit_data
.export pia_disp_digit_ctrl,pia_disp_seg_data,pia_disp_seg_ctrl,pia_switch_return_data,pia_switch_return_ctrl
.export pia_switch_strobe_data,pia_switch_strobe_ctrl,pia_alphanum_digit_data,pia_alphanum_digit_ctrl,pia_alphanum_seg_data
.export pia_alphanum_seg_ctrl,reset,csum1,init_done,clear_all,main,checkswitch,time,switches,next_sw,sw_break,vm_irqcheck
.export flashlamp,solq,snd_queue,check_threads,nextthread,delaythread,addthread,dump_thread,killthread
.export newthread_sp,newthread_06,killthread_sp,kill_thread,kill_threads,check_threadid,pri_next,pri_skipme
.export solbuf,set_solenoid,set_ss_off,set_s_pia,set_ss_on,soladdr,ssoladdr,hex2bitpos,comma_million,comma_thousand
.export update_commas,set_comma_bit,test_mask_b,update_eb_count,isnd_pts,dsnd_pts,snd_pts,score_main,score_update
.export hex2dec,score2hex,sh_exit,add_points,checkreplay,get_hs_digits,b_plus10,split_ab,isnd_once,sound_sub,isnd_test
.export isnd_mult,snd_exit_pull,snd_exit,send_snd_save,send_snd,do_complex_snd,store_csndflg,check_sw_mask,sw_ignore
.export sw_active,sw_down,sw_dtime,sw_trig_yes,sw_proc,check_sw_close,to_ldx_rts,getswitch,sw_pack,pack_done
.export check_sw_open,sw_get_time,sw_tbl_lookup,xplusa,copy_word,setup_vm_stack,stack_done,xplusb,cmosinc_a,cmosinc_b,b_cmosinc
.export reset_audits,clr_ram_100,clr_ram,factory_zeroaudits,restore_hstd,a_cmosinc,copyblock,loadpricing,copyblock2,sys_irq
.export pia_ddr_data,spec_sol_def,lampbuffers,lamp_on,lamp_or,lamp_commit,lamp_done,lamp_off,lamp_and,lamp_flash,lamp_invert
.export lamp_eor,lamp_on_b,lamp_off_b,lamp_invert_b,lamp_on_1,lamp_off_1,lamp_invert_1,unpack_byte,lampm_clr0,lampm_buf0
.export lampm_f,lampm_a,lampm_b,lampm_set0,abx_ret,lampr_start,lr_ret,lampr_end
.export lampr_setup,lamp_left,ls_ret,lamp_right,lampm_c,lm_test,lampm_e,lampm_d,bit_switch,bit_lamp_flash,bit_lamp_buf_1,bit_lamp_buf_0
.export lampm_z,lampm_x,bit_main,csum2,master_vm_lookup,vm_lookup_0x,vm_lookup_1x_a,vm_lookup_1x_b,vm_lookup_2x,vm_lookup_4x,vm_lookup_5x
.export branch_lookup,macro_start,macro_rts,macro_go,switch_entry,breg_sto,vm_control_0x,macro_pcminus100,macro_code_start
.export macro_special,macro_extraball,vm_control_1x, macro_x8f,macro_17,macro_x17,to_macro_go1,vm_control_2x,vm_control_3x
.export vm_control_4x,macro_exec,gettabledata_w,gettabledata_b,macro_getnextbyte,getx_rts,vm_control_5x,macro_ramadd,ram_sto2
.export to_macro_go2,macro_ramcopy,macro_set_pri,macro_delay_imm_b,dly_sto,macro_getnextword,macro_get2bytes,macro_rem_th_s
.export macro_rem_th_m,macro_jsr_noreturn,pc_sto2,macro_a_ram,to_getx_rts,macro_b_ram,macro_jsr_return,ret_sto,vm_control_6x
.export vm_control_7x,vm_control_8x,pc_sto,to_macro_go4,macro_jmp_cpu,vm_control_9x,vm_control_ax,macro_jmp_abs,vm_control_bx
.export ram_sto,vm_control_cx,vm_control_dx,vm_control_ex,vm_control_fx,macro_pcadd,macro_setswitch,load_sw_no,macro_clearswitch
.export to_macro_go3,to_macro_getnextbyte,macro_branch,branchdata,complexbranch,branch_invert,to_rts3,branch_lamp_on,test_z
.export branch_lamprangeoff,test_c,branch_lamprangeon,branch_tilt,ret_false,branch_gameover,ret_true,branch_lampbuf1
.export branch_switch,branch_and,branch_add,branch_or,branch_equal,branch_ge,branch_threadpri,branch_bitwise,to_rts4,set_logic
.export award_special,credit_special,award_replay,give_credit,extraball,do_eb,addcredits,addcredit2,coinlockout,checkmaxcredits
.export pull_ba_rts,creditq,ptrx_plus_1,ptrx_plus_a,ptrx_plus,coin_accepted,cmos_a_plus_b_cmos,divide_ab,clr_bonus_coins,csum3
.export dec2hex,write_range,do_game_init,add_player,initialize_game,clear_range,to_pula_rts,clear_displays,store_display_mask
.export init_player_game,setplayerbuffer,copyplayerdata,init_player_up,disp_mask,disp_clear,init_player_sys,resetplayerdata
.export dump_score_queue,outhole_main,saveplayertobuffer,to_copyblock,balladjust,show_hstd,gameover,powerup_init,set_gameover
.export show_all_scores,check_hstd,hstd_nextp,set_hstd,update_hstd,hstd_adddig,wordplusbyte,to_rts1,fill_hstd_digits,send_sound
.export do_match,get_random,to_rts2,credit_button,has_credit,start_new_game,lesscredit,tilt_warning,do_tilt,testdata,testlists
.export selftest_entry,st_diagnostics,do_aumd,check_adv,check_aumd,st_init,to_clear_range,st_nexttest,to_audadj,do_audadj
.export show_func,adjust_func,st_reset,fn_gameid,fn_gameaud,fn_sysaud,fn_hstd,fn_replay,cmos_add_d,fn_pricec,fn_prices
.export cmos_a,fn_ret,fn_credit,fn_cdtbtn,fn_adj,fn_command,st_display,st_sound,st_lamp,st_autocycle,st_solenoid,st_switch
.export st_swnext,rambad,diag,diag_showerror,tightloop,diag_ramtest,cmos_error,block_copy,cmos_restore,adjust_a,irq_entry
.export swi_entry,nmi_entry,res_entry,player_ready,isnd_mult_x