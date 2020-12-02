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
lampbuffer0			.block	8		;Lamp Buffer 0
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
cred_b0			.block	1
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
lamp_bit			.block	1		;$008C
comma_data_temp		.block	1
credp1p2_bufferselect	.block	1
mbipp3p4_bufferselect	.block	1
swap_player_displays	.block	1
solenoid_address		.block	2
solenoid_bitpos		.block	1
solenoid_counter		.block	1
irqcount16			.block	1
switch_queue_pointer	.block	2
solenoid_queue_pointer	.block	2
temp1				.block	2
temp2				.block	2
temp3				.block	2
sys_temp1			.block	1
sys_temp2			.block	1
sys_temp3			.block	1
sys_temp4			.block	1
sys_temp5			.block	1
sw_encoded			.block	1
sys_temp_w2			.block	2
sys_temp_w3			.block	2
thread_priority		.block	1
unused_ram1			.block	1		;$00AB
irqcount			.block	1
vm_base			.block	2
vm_nextslot			.block	2
current_thread		.block	2
vm_tail_thread		.block	2
lamp_flash_rate		.block	1
lamp_flash_count		.block	1
thread_timer_byte		.block	1
soundcount			.block	1
lastsound			.block	1
cur_sndflags		.block	1		;$00BA
soundptr			.block	2
soundirqcount		.block	2
soundindex_com		.block	2
sys_soundflags		.block	1
soundindex			.block	1
csound_timer		.block	2		;$00C3
next_sndflags		.block	1		;$00C5
next_sndcnt		      .block	1		;$00C6
next_sndcmd		      .block	1		;$00C7
flag_tilt			.block	1
flag_gameover		.block	1
flag_bonusball		.block	1
flags_selftest		.block	1
num_players			.block	1
player_up			.block	1
pscore_buf			.block	2
num_eb			.block	1
vm_pc				.block	2
num_tilt			.block	1
minutetimer			.block	2
flag_timer_bip		.block	1
randomseed			.block	1
x_temp_1			.block	2		;$00D8-D9
eb_x_temp			.block	2		;$00DA-DB
credit_x_temp		.block	2		;$00DC-DD
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
aud_totalballs		.block	4	;012A-012D	Total Balls Played
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
adj_energystandard		.block	2     ;0193-0194	Number of Balls (3 or 5)                                   
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
;* for extended flexibility.
;***************************************************************
	.org $1100

switch_queue		.block	24

switch_queue_full
sol_queue			.block	16

sol_queue_full
score_queue			.block	8

score_queue_full
exe_buffer			.block	16		;Temp code buffer for exe macro

;define the size of each player data block first
_gamedata_size		.equ		$26
;then apply it to all players
p1_gamedata			.block	_gamedata_size
p2_gamedata			.block	_gamedata_size
p3_gamedata			.block	_gamedata_size
p4_gamedata			.block	_gamedata_size

unknown_xxx			.block	4
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
