;************************************************************
;* Jungle Lord Sound/Speech Code
;* Version 2.0
;*
;* This code is a modification of the orginal Jungle Lord Sound ROM to                         
;* try and make the game sound less flat than the original. In order to
;* expand the sound capabilities the support for tones and nospeech has
;* been removed. We are still limited 0x1F sounds for now however.
;*
;* Jess M. Askey
;* 04-11-2001
;************************************************************
;* Memory Map:
;*
;*	B000-BFFF	Speech ROM 7
;*	C000-CFFF	Speech ROM 5
;*	D000-DFFF	Speech ROM 6
;*	E000-EFFF	Speech ROM 4
;*	F000-F7FF	4K Sound ROM 
;*	F800-FFFF	2K Sound ROM
;************************************************************
;*
;*	Sound List - There are only 32 sounds available in 
;*                 level 7 games so that the DIP switches
;*                 can properly adjust the commands.
;*
;*  Command	Sound		
;*  --------------------------------------------------------------------------------------------------			
;*	01	Tilt
;*	02	Electric Melt
;*	03	"You  Win! You Jungle Lord"
;*	04	"Jungle Lord, (Trumpet)"
;*	05	Time Fantasy Credit
;*	06	Double Trouble Miss
;*	07	Thud
;*	08	Game Over (+sp follow)
;*	09	Bonus Count
;*	0A	"Jungle Lord in Double Trouble" OR "You in Double Trouble"
;*	0B	TF Loop Forward
;*	0C	Jungle Lord Credit
;*	0D	TF Complete Rollovers
;*	0E	"Fight Tiger Again"
;*	0F	"Stampede, (trumpet)" 
;*	10	Pop Bumper Thud
;*	11	"You Jungle Lord"
;*	12	Funky repeat forever
;*	13	Kill All Background
;*	14	Long Slow Explosion
;*	15	Spooky BG
;*	16	"Me Jungle Lord"
;*	17	Explosion
;*	18	"You Win! Fight in Jungle Again"
;*	19	"Fight Jungle Tiger and Win!" OR "Can you be Jungle Lord?" OR "Beat Tiger and be Jungle Lord" OR "Can you fight in Jungle?"
;*	1A	Electric Game Over
;*	1B	Stellar Warp (+sp follow)
;*	1C	High Score
;*	1D	Match Sound	
;*	1E	"(trumpet)"
;*	1F	"(trumpet)"
;*
;************************************************************
	.msfirst
#include  "68logic.asm"		;680X logic definitions

;*************************************************************
;* Set the emulation flag to make our file on the $8000 boundary
;* in order for the eprom emulator to work correctly. The 
;* emulator will cover the block from $8000-$ffff. 
;*************************************************************
emulate .equ 1
;*************************************************************

	.org 0000

last_speech_cmd	.block	1
sp_last_random	.block	1	;Stored the value of the last command 0-3 used for 'random' phrase
sp_phrase_tog	.block	1	;Used by command 3 to toggle between phrase_3 and phrase_4
sp_nextwordcmd	.block	1	;If a phrase requires another word, then it is stored here 
bg_pri_cnt		.block	1     ;this is no longer used, we will keep it here in case of shift errors
bg_sec_cnt		.block	1
counter1		.block	1
counter2		.block	1
counter3		.block	1
semi_random		.block	1
temp1			.block	1
temp2			.block	1
xtemp1		.block	2
xtemp2		.block	2
xtemp3		.block	2
wave_index
X0012			.block	1
sp_pending_com
X0013			.block	1

;***********************************************************
;* Open RAM space begins here for each routine.
;* This space can be used for local sound routines and
;* are not held outside their scope.
;***********************************************************
local_base		.block	1

;*******************************************
;* Speech Variables
.org			local_base
sp_start_ptr	.block	2
sp_end_ptr		.block	2
sp_phrase_ptr	.block	2
sp_base_ptr		.block	2
sp_currentbyte	.block	1
sp_currentpitch	.block	1
sp_utindex		.block	1
sp_pitchload	.block	1
delaybuf		.block	1

;*******************************************
;* Low Res Sounds
.org			local_base
lr_timer		.block	1
lr_dac		.block	1
lr_x_ptr		.block	1

;*******************************************
;* Waveform Defined Sounds
.org			local_base+8

ptr_sweep_start	.block	2	;001C
ptr_sweep_end	.block	2	;001E
ptr_sweep_last	.equ		$0020

;*******************************************
;* Modulated Sounds
.org			local_base



;*******************************************
;* Additive Sounds
.org			local_base
sum_t1_init		.block	1
sum_t2_init		.block	1
sum_t1_adder	.block	1
sum_t2_adder	.block	1
sum_t2_max		.block	1
sum_all_max		.block	2
sum_t1_ext		.block	1
sum_dac		.block	1
sum_t1_value	.block	1
sum_t2_value	.block	1

;*******************************************
;* Simple Sounds
.org			local_base+2
sim_delay		.block	1
sim_non		.block	3
sim_initial		.block	1
sim_adder		.block	1

;*******************************************
;* Special Sounds
.org			local_base
ssnd_adder		.block	1
ssnd_dac		.block	1
ssnd_cycles		.block	1
ssnd_period		.block	2
ssnd_flag		.block	1

;*******************************************
X0014			.equ		$0014
X0015			.equ		$0015
X0016			.equ		$0016
X0017			.equ		$0017
X0018			.equ		$0018
X0019			.equ		$0019
X001B			.equ		$001B
X0022			.equ		$0022
X0023			.equ		$0023
X0024			.equ		$0024

;*******************************************
;* Hardware Definitions
;*******************************************	
pia_dac_out		.equ	$0400
pia_speech_data	.equ	$0401
pia_sound_command	.equ	$0402
pia_speech_clk	.equ	$0403


#IF emulate
	.org	$8000
#ELSE
	.org	$b000
#ENDIF
			
;*****************************************************
;* Begin CVSD Speech Data Streams
;*
;* Data must start with #AA or it will not be played.
;*****************************************************			
ut_01_beg	.db	$AA,$34,$5A,$1E
			.db	$E0,$02,$70,$9E
			.db	$38,$8E,$A9,$96
			.db	$A3,$8E,$73,$CE
			.db	$A7,$19,$0E,$C3
			.db	$18,$CD,$B1,$87
			.db	$E3,$E3,$38,$8E
			.db	$8D,$E3,$38,$0E
			.db	$C7,$E1,$39,$2E
			.db	$2E,$93,$C6,$71
			.db	$18,$9E,$C7,$71
			.db	$AE,$19,$C7,$71
			.db	$8C,$E3,$71,$1C
			.db	$87,$E3,$E1,$78
			.db	$3C,$1C,$47,$4A
			.db	$39,$3C,$9E,$8F
			.db	$C7,$61,$A4,$8C
			.db	$2E,$1E,$CE,$D1
			.db	$E1,$78,$3C,$4E
			.db	$C7,$51,$2D,$46
			.db	$AF,$6A,$D3,$A8
			.db	$18,$55,$18,$2C
			.db	$BF,$BF,$5F,$05
			.db	$40,$D0,$B8,$3C
			.db	$4D,$A5,$55,$AF
			.db	$AB,$E2,$F0,$70
			.db	$7A,$BD,$88,$07
			.db	$0F,$07,$20,$FE
			.db	$FF,$EB,$02,$04
			.db	$2E,$1B,$42,$E1
			.db	$D3,$D7,$E1,$F2
			.db	$F2,$F3,$00,$1E
			.db	$FF,$F9,$80,$DF
			.db	$0F,$A0,$F0,$01
			.db	$85,$3F,$08,$1F
			.db	$FF,$0F,$E0,$FF
			.db	$0F,$FC,$FF,$01
			.db	$B6,$3E,$80,$6A
			.db	$6F,$A9,$FF,$0F
			.db	$F8,$8F,$1F,$FD
			.db	$8F,$2F,$FA,$0E
			.db	$D2,$DD,$44,$F5
			.db	$07,$FC,$07,$FF
			.db	$E0,$1F,$E8,$F1
			.db	$16,$E0,$0B,$7E
			.db	$C0,$1F,$E0,$0F
			.db	$F8,$02,$2F,$F0
			.db	$00,$BE,$02,$FC
			.db	$07,$FC,$01,$FF
			.db	$C1,$3C,$0A,$A3
			.db	$F0,$01,$FE,$81
			.db	$7F,$C0,$3F,$D0
			.db	$27,$E9,$02,$E0
			.db	$5F,$F8,$17,$FC
			.db	$07,$00,$52,$07
			.db	$18,$DC,$EF,$D0
			.db	$0F,$FC,$87,$7E
			.db	$C0,$02,$F8,$7F
			.db	$FE,$07,$FF,$83
			.db	$7F,$00,$5B,$C0
			.db	$7F,$EE,$15,$FE
			.db	$3D,$F0,$C1,$0F
			.db	$00,$FF,$D5,$2F
			.db	$FE,$17,$DA,$03
			.db	$A0,$00,$FF,$07
			.db	$1F,$F8,$B3,$2A
			.db	$BF,$04,$00,$7E
			.db	$E7,$5F,$7A,$85
			.db	$FE,$03,$10,$C0
			.db	$8A,$FE,$6F,$EA
			.db	$FA,$17,$61,$05
			.db	$00,$FC,$81,$FF
			.db	$A5,$1F,$B2,$02
			.db	$00,$E1,$E9,$7F
			.db	$E5,$0F,$F0,$0F
			.db	$BC,$01,$00,$C0
			.db	$BB,$FF,$9F,$FA
			.db	$01,$FC,$00,$30
			.db	$20,$DE,$FB,$7B
			.db	$AD,$4A,$3F,$80
			.db	$07,$00,$40,$F9
			.db	$FF,$BF,$A8,$EE
			.db	$03,$18,$00,$C4
			.db	$C1,$FD,$EF,$AB
			.db	$78,$F5,$10,$86
			.db	$01,$00,$30,$FF
			.db	$FF,$2F,$FA,$03
			.db	$E8,$00,$28,$80
			.db	$F8,$FD,$FF,$4D
			.db	$0E,$E4,$4A,$95
			.db	$00,$00,$A0,$FE
			.db	$FF,$3F,$00,$13
			.db	$74,$02,$80,$04
			.db	$E0,$FB,$FF,$13
			.db	$3A,$B8,$82,$55
			.db	$01,$00,$80,$F7
			.db	$FC,$FF,$51,$12
			.db	$99,$82,$1F,$80
			.db	$01,$70,$7D,$FF
			.db	$5F,$04,$AA,$D7
			.db	$EC,$09,$00,$00
			.db	$A0,$FF,$FF,$BF
			.db	$54,$A5,$14,$0A
			.db	$00,$0A,$E4,$41
			.db	$F9,$FF,$FF,$AF
			.db	$02,$42,$00,$95
			.db	$80,$FB,$91,$7A
			.db	$F5,$FF,$BE,$04
			.db	$42,$82,$E0,$FF
			.db	$00,$FE,$00,$DC
			.db	$41,$FF,$B5,$FE
			.db	$B1,$9F,$FB,$07
			.db	$18,$03,$04,$A0
			.db	$5F,$FF,$9F,$62
			.db	$D5,$F7,$E7,$00
			.db	$00,$A0,$1C,$80
			.db	$FF,$FE,$7F,$0B
			.db	$84,$CF,$E1,$01
			.db	$00,$31,$FE,$03
			.db	$F0,$DF,$FF,$01
			.db	$00,$30,$FF,$5C
			.db	$00,$00,$F5,$0F
			.db	$80,$3F,$FF,$07
			.db	$10,$D0,$FF,$C7
			.db	$03,$00,$F0,$FC
			.db	$05,$C0,$7D,$FF
			.db	$1F,$00,$D6,$01
			.db	$B1,$02,$00,$E8
			.db	$E8,$0F,$C0,$FF
			.db	$FD,$1F,$00,$DE
			.db	$FF,$07,$00,$00
			.db	$E0,$DF,$36,$00
			.db	$FE,$FF,$FF,$01
			.db	$C0,$FE,$4D,$00
			.db	$80,$E8,$FF,$4E
			.db	$34,$00,$FF,$FF
			.db	$D1,$00,$C0,$FF
			.db	$95,$22,$C0,$AA
			.db	$54,$55,$38,$00
			.db	$FF,$BF,$E1,$03
			.db	$C0,$FF,$29,$04
			.db	$A5,$B1,$54,$79
			.db	$D4,$3F,$00,$FC
			.db	$BF,$FA,$01,$C0
			.db	$FF,$AF,$05,$E0
			.db	$51,$40,$41,$F0
			.db	$3F,$00,$FE,$7F
			.db	$FA,$07,$C0,$9F
			.db	$3C,$06,$00,$A4
			.db	$F7,$CA,$51,$F9
			.db	$0F,$80,$FF,$2F
			.db	$FA,$01,$C0,$0D
			.db	$DF,$47,$10,$D1
			.db	$2C,$5D,$97,$EF
			.db	$0F,$80,$FF,$43
			.db	$FA,$01,$E0,$5F
			.db	$94,$0F,$A1,$BF
			.db	$22,$09,$78,$0F
			.db	$FB,$00,$E0,$FF
			.db	$BD,$1E,$00,$FE
			.db	$FF,$24,$00,$C8
			.db	$5F,$04,$14,$52
			.db	$FF,$7F,$00,$F8
			.db	$9F,$FF,$07,$00
			.db	$7C,$F5,$1F,$00
			.db	$88,$DB,$7F,$09
			.db	$A0,$FE,$3F,$00
			.db	$FD,$23,$FF,$0F
			.db	$00,$50,$F8,$3F
			.db	$45,$05,$A8,$BE
			.db	$5C,$49,$EB,$7F
			.db	$00,$FC,$D3,$FF
			.db	$07,$00,$D0,$FC
			.db	$3F,$00,$09,$F5
			.db	$AD,$D5,$4B,$EB
			.db	$BF,$01,$E8,$01
			.db	$FC,$7F,$80,$06
			.db	$E2,$FF,$AA,$14
			.db	$82,$A6,$B5,$96
			.db	$88,$FC,$0F,$00
			.db	$7F
ut_02_beg		.db	$AA,$E1,$FF,$07
			.db	$10,$28,$FE,$4F
			.db	$85,$A0,$54,$B5
			.db	$54,$FA,$D3
ut_01_end		.db	$70
			.db	$80,$FA,$EB
			.db	$FF,$0B,$50,$40
			.db	$ED,$AB,$55,$42
			.db	$A2,$58,$95,$7F
			.db	$05,$FC,$03,$F0
			.db	$3F,$F6,$5F,$81
			.db	$85,$84,$DF,$6E
			.db	$51,$20,$80,$F4
			.db	$5F,$02,$5F,$BA
			.db	$00,$EF,$8B,$FF
			.db	$D7,$A8,$00,$A4
			.db	$AD,$F6,$0A,$80
			.db	$F0,$D7,$A0,$3E
			.db	$4A,$FF,$00,$FB
			.db	$83,$FE,$1F,$54
			.db	$84,$70,$95,$5A
			.db	$11,$E8,$8F,$42
			.db	$2B,$B8,$FF,$AF
			.db	$00,$F0,$C6,$FB
			.db	$3F,$00,$2D,$72
			.db	$1F,$00,$95,$BB
			.db	$9E,$52,$41,$FC
			.db	$FF,$F6,$00,$F0
			.db	$FF,$E7,$1B,$00
			.db	$FE,$5F,$51,$00
			.db	$FE,$2F,$45,$00
			.db	$DD,$FF,$AB,$EA
			.db	$01,$C0,$FF,$17
			.db	$07,$00,$FF,$0B
			.db	$0E,$01,$FF,$0A
			.db	$1A,$80,$FB,$FB
			.db	$1A,$CA,$3F,$00
			.db	$FC,$3F,$E0,$01
			.db	$F0,$7F,$00,$5B
			.db	$40,$7F,$00,$A9
			.db	$6A,$FE,$13,$A8
			.db	$FA,$1F,$00,$FE
			.db	$3F,$E0,$08,$E8
			.db	$FF,$81,$00,$5A
			.db	$57,$A3,$A0,$7D
			.db	$5F,$43,$62,$FD
			.db	$3F,$00,$F8,$7F
			.db	$C0,$03,$C0,$FF
			.db	$03,$30,$40,$FF
			.db	$0B,$A2,$E5,$FA
			.db	$26,$C8,$EB,$FA
			.db	$01,$C0,$FF,$07
			.db	$38,$03,$FE,$1F
			.db	$00,$8C,$FA,$6F
			.db	$00,$F4,$BE,$57
			.db	$80,$F4,$AB,$DE
			.db	$01,$C0,$FF,$47
			.db	$1D,$00,$FE,$0F
			.db	$58,$00,$FE,$4F
			.db	$A0,$68,$FD,$FE
			.db	$B1,$B2,$AA,$BA
			.db	$00,$C0,$FF,$01
			.db	$38,$08,$FF,$07
			.db	$C0,$19,$7E,$0B
			.db	$80,$7F,$6B,$09
			.db	$20,$FD,$2E,$C4
			.db	$7F,$00,$F8,$3F
			.db	$C0,$07,$F0,$7F
			.db	$00,$3E,$82,$DF
			.db	$02,$F2,$5A,$BA
			.db	$06,$C5,$FA,$1F
			.db	$00,$7E,$00,$FC
			.db	$3F,$80,$AF,$F0
			.db	$3F,$00,$7E,$20
			.db	$DF,$00,$FD,$2B
			.db	$A9,$A4,$FF,$00
			.db	$E8,$8D,$F7,$01
			.db	$B1,$FF,$07,$3E
			.db	$00,$FF,$07,$D0
			.db	$05,$FA,$0B,$E8
			.db	$9B,$FA,$0F,$80
			.db	$DF,$68,$16,$8A
			.db	$FF,$05,$C0,$FF
			.db	$01,$3E,$D0,$FF
			.db	$00,$7C,$42,$BF
			.db	$00,$FF,$07,$E0
			.db	$AA,$F5,$1D,$00
			.db	$EF,$D5,$6D,$01
			.db	$0E,$E0,$FF,$81
			.db	$2B,$F0,$7F,$00
			.db	$27,$FD,$0F,$80
			.db	$3F,$F1,$2B,$C0
			.db	$AF,$4B,$53,$4A
			.db	$F4,$5B,$88,$D2
			.db	$0F,$E0,$FF,$D0
			.db	$0F,$F0,$7F,$00
			.db	$E0,$1B,$5D,$0F
			.db	$E0,$BF,$70,$2D
			.db	$52,$BD,$16,$D1
			.db	$91,$FA,$92,$12
			.db	$E5,$FF,$00,$F0
			.db	$07,$FE,$03,$F8
			.db	$C2,$87,$3B,$A0
			.db	$FE,$A0,$2F,$90
			.db	$7A,$EB,$0A,$8A
			.db	$FD,$45,$55,$08
			.db	$FE,$1F,$00,$BF
			.db	$E8,$2F,$88,$FE
			.db	$25,$C0,$0F,$FE
			.db	$E1,$02,$56,$F8
			.db	$8F,$50,$45,$7B
			.db	$BA,$40,$F7,$0B
			.db	$C0,$3F,$B2,$55
			.db	$E0,$BF,$A0,$55
			.db	$A9,$B7,$00,$7F
			.db	$47,$55,$85,$AA
			.db	$E2,$07,$7E,$F0
			.db	$07,$5F,$28,$80
			.db	$3F,$7C,$21,$A5
			.db	$3F,$F4,$82,$FA
			.db	$0F,$A8,$16,$F5
			.db	$16,$51,$B5,$6A
			.db	$AB,$85,$AA,$AF
			.db	$5A,$F0,$0F,$60
			.db	$27,$FC,$21,$A8
			.db	$FF,$7D,$B5,$4A
			.db	$D0,$56,$AF,$2A
			.db	$D0,$42,$AA,$17
			.db	$7F,$F9,$A3,$1D
			.db	$69,$88,$00,$77
			.db	$8F,$5C,$F4,$1F
			.db	$3E,$C0,$53,$DF
			.db	$4E,$58,$F5,$F5
			.db	$05,$15,$F8,$A9
			.db	$AA,$A2,$5E,$BB
			.db	$60,$43,$1B,$7C
			.db	$A5,$AE,$2A,$F0
			.db	$AB,$A7,$57,$D8
			.db	$6D,$21,$09,$F2
			.db	$07,$2E,$E0,$E3
			.db	$BF,$56,$68,$EA
			.db	$57,$25,$2A,$DC
			.db	$F5,$25,$9A,$A8
			.db	$A4,$AA,$8D,$3E
			.db	$10,$FF,$B6,$B4
			.db	$80,$D6,$5A,$5B
			.db	$80,$D2,$FD,$B5
			.db	$5A,$AB,$FF,$40
			.db	$01,$58,$F0,$AB
			.db	$5F,$55,$55,$6B
			.db	$AD,$AA,$52,$48
			.db	$AB,$BD,$AD,$05
			.db	$FE,$B0,$40,$A5
			.db	$B6,$37,$55,$F4
			.db	$26,$5D,$51,$A5
			.db	$6A,$45,$AB,$BF
			.db	$FD,$55,$97,$02
			.db	$12,$50,$A1,$56
			.db	$F6,$F5,$EE,$AB
			.db	$4A,$AA,$A8,$02
			.db	$5E,$F9,$47,$2B
			.db	$49,$6A,$49,$49
			.db	$A5,$7E,$DD,$52
			.db	$55,$D5,$56,$14
			.db	$51,$43,$5F,$FE
			.db	$BA,$AD,$2A,$45
			.db	$40,$88,$14,$B5
			.db	$55,$FB,$BD,$BD
			.db	$45,$3D,$EA,$82
			.db	$06,$B5,$FA,$AA
			.db	$8A,$4A,$B5,$EA
			.db	$A2,$AA,$DE,$EA
			.db	$AA,$2A,$45,$15
			.db	$54,$55,$51,$7F
			.db	$BF,$5D,$A5,$10
			.db	$22,$45,$24,$92
			.db	$D6,$DD,$B7,$DA
			.db	$B7,$BE,$A8,$82
			.db	$2A,$D5,$DA,$AA
			.db	$94,$4A,$A5,$AA
			.db	$AD,$AA,$52,$55
			.db	$3F,$D0,$A5,$96
			.db	$14,$54,$F5,$B7
			.db	$AF,$6E,$AA,$20
			.db	$84,$90,$92,$2A
			.db	$FB,$E0,$8F,$1F
			.db	$3F,$BA,$4A,$2D
			.db	$78
ut_02_end		.db	$E1
			.db	$D1,$2A
			.db	$AE,$C2,$3B,$95
			.db	$52,$59,$B9,$EA
ut_03_beg		.db	$AA,$49,$4B,$A5
			.db	$4E,$AB,$A8,$2E
			.db	$4E,$F5,$6A,$54
			.db	$15,$AB,$65,$5D
			.db	$74,$54,$55,$53
			.db	$BB,$54,$85,$D5
			.db	$8A,$D6,$69,$45
			.db	$1D,$3A,$9A,$C6
			.db	$D2,$71,$5C,$95
			.db	$A3,$B8,$4C,$4E
			.db	$A3,$A9,$34,$5A
			.db	$AD,$D2,$E2,$A8
			.db	$9A,$2A,$8F,$EA
			.db	$A5,$A9,$6A,$35
			.db	$69,$F2,$0B,$87
			.db	$95,$56,$5E,$46
			.db	$75,$A5,$96,$6B
			.db	$91,$AB,$54,$B5
			.db	$50,$5D,$15,$55
			.db	$B5,$28,$5D,$47
			.db	$A5,$5A,$8D,$D2
			.db	$75,$16,$4B,$C7
			.db	$AA,$2C,$AA,$D3
			.db	$A5,$2A,$7A,$09
			.db	$EA,$5B,$A8,$BA
			.db	$52,$51,$45,$75
			.db	$49,$54,$D7,$A3
			.db	$20,$D4,$DF,$7F
			.db	$55,$A9,$14,$20
			.db	$49,$55,$52,$BD
			.db	$BB,$CA,$B7,$75
			.db	$BD,$95,$F6,$B1
			.db	$00,$80,$FF,$3F
			.db	$06,$FE,$07,$28
			.db	$F0,$1F,$84,$F3
			.db	$2F,$28,$BE,$87
			.db	$42,$F9,$FF,$C1
			.db	$7F,$00,$0E,$F0
			.db	$07,$78,$00,$1F
			.db	$C0,$E3,$38,$18
			.db	$0F,$C3,$21,$58
			.db	$1E,$E7,$1F,$FC
			.db	$07,$E0,$80,$3F
			.db	$C0,$07,$F0,$30
			.db	$00,$FE,$80,$69
			.db	$1C,$D8,$03,$FC
			.db	$0F,$FC,$03,$F7
			.db	$E0,$0B,$FC,$00
			.db	$AF,$38,$E0,$17
			.db	$84,$B3,$A0,$3E
			.db	$ED,$E1,$3F,$60
			.db	$0E,$1F,$E0,$03
			.db	$7C,$78,$01,$6F
			.db	$30,$39,$86,$FF
			.db	$81,$7F,$F0,$0D
			.db	$3F,$F0,$87,$2B
			.db	$FC,$80,$8F,$43
			.db	$7D,$1F,$F8,$87
			.db	$0F,$F8,$83,$1F
			.db	$3C,$F0,$83,$13
			.db	$1F,$AC,$3E,$F0
			.db	$EF,$1F,$F0,$C1
			.db	$03,$7C,$7E,$C0
			.db	$E1,$07,$2F,$07
			.db	$FF,$FE,$80,$83
			.db	$3F,$00,$F8,$87
			.db	$07,$E0,$1F,$0C
			.db	$FE,$FF,$81,$E0
			.db	$1F,$07,$E8,$FE
			.db	$00,$F0,$D7,$03
			.db	$FF,$7F,$10,$F0
			.db	$8F,$19,$C0,$BF
			.db	$81,$02,$7F,$F0
			.db	$F0,$DF,$0F,$DE
			.db	$FC,$31,$C3,$BF
			.db	$03,$FE,$80,$3F
			.db	$FF,$1E,$78,$E0
			.db	$FB,$B0,$C1,$87
			.db	$E7,$07,$1E,$3E
			.db	$FE,$E1,$C1,$F0
			.db	$E3,$07,$C3,$87
			.db	$0F,$1C,$BC,$FF
			.db	$F9,$60,$80,$C7
			.db	$E3,$0F,$E0,$03
			.db	$1C,$BC,$FF,$7F
			.db	$70,$40,$EC,$F5
			.db	$79,$10,$FC,$20
			.db	$70,$FC,$E7,$C3
			.db	$01,$C0,$C3,$EF
			.db	$53,$28,$00,$0E
			.db	$87,$7F,$3E,$07
			.db	$03,$20,$38,$FE
			.db	$0F,$03,$04,$06
			.db	$8F,$FF,$FF,$07
			.db	$06,$00,$94,$C7
			.db	$DF,$E3,$00,$C0
			.db	$70,$D8,$F0,$FF
			.db	$63,$00,$58,$60
			.db	$F8,$7F,$05,$06
			.db	$1F,$0C,$80,$FB
			.db	$BB,$FF,$CF,$07
			.db	$80,$C1,$33,$FA
			.db	$F3,$03,$0C,$1E
			.db	$0C,$84,$BF,$BF
			.db	$FF,$EE,$C0,$1D
			.db	$10,$60,$F8,$FC
			.db	$C3,$C1,$93,$03
			.db	$0F,$38,$7E,$76
			.db	$E8,$D8,$DF,$C7
			.db	$03,$02,$4A,$13
			.db	$1F,$FF,$FC,$18
			.db	$80,$C1,$E3,$07
			.db	$8F,$07,$E7,$09
			.db	$FF,$F8,$38,$8C
			.db	$E1,$E1,$43,$89
			.db	$C2,$D1,$75,$E0
			.db	$EF,$E3,$80,$07
			.db	$8F,$D7,$03,$07
			.db	$C3,$6A,$F5,$7E
			.db	$3C,$0E,$70,$10
			.db	$9F,$7E,$F3,$30
			.db	$14,$5A,$9E,$7E
			.db	$3C,$4C,$20,$0C
			.db	$BE,$FE,$6B,$0A
			.db	$07,$8A,$CB,$F7
			.db	$C7,$E1,$C1,$02
			.db	$42,$F7,$F9,$E8
			.db	$F1,$10,$69,$5F
			.db	$1E,$FC,$78,$0C
			.db	$11,$13,$24,$4E
			.db	$DF,$4F,$97,$71
			.db	$01,$C3,$6F,$3C
			.db	$7C,$5C,$0D,$11
			.db	$18,$66,$EE,$C7
			.db	$F8,$79,$63,$E0
			.db	$90,$4F,$47,$1B
			.db	$1D,$EE,$70,$70
			.db	$E2,$C4,$0C,$0D
			.db	$8F,$3F,$2F,$55
			.db	$35,$1C,$C1,$E1
			.db	$F9,$89,$07,$47
			.db	$5D,$1E,$1E,$8A
			.db	$1B,$E2,$E1,$B9
			.db	$9A,$87,$43,$57
			.db	$AB,$96,$46,$65
			.db	$03,$A3,$C7,$17
			.db	$1E,$8D,$26,$1F
			.db	$3D,$4D,$4A,$95
			.db	$70,$3C,$BE,$EA
			.db	$31,$54,$58,$E3
			.db	$F1,$3A,$55,$6A
			.db	$70,$78,$EA,$69
			.db	$1E,$28,$54,$B5
			.db	$3A,$BD,$2C,$86
			.db	$22,$C7,$E3,$AD
			.db	$1F,$13,$A1,$D1
			.db	$CA,$E5,$AD,$92
			.db	$28,$7A,$F0,$F0
			.db	$DC,$99,$39,$2B
			.db	$1A,$4C,$56,$4D
			.db	$D3,$0F,$17,$6A
			.db	$7A,$70,$AC,$DC
			.db	$B9,$9A,$2A,$22
			.db	$67,$98,$54,$F3
			.db	$63,$2B,$96,$2E
			.db	$35,$3A,$C9,$F1
			.db	$B1,$E3,$AA,$4E
			.db	$19,$16,$2A,$B5
			.db	$56,$75,$D9,$E3
			.db	$C1,$A4,$16,$8F
			.db	$56,$2C,$9D,$3C
			.db	$27,$B5,$C5,$C3
			.db	$54,$4A,$97,$2B
			.db	$95,$F0,$1C,$E7
			.db	$18,$CF,$38,$E2
			.db	$69,$9C,$4A,$1C
			.db	$6F,$8C,$15,$9D
			.db	$99,$33,$E2,$CC
			.db	$C3,$D1,$9C,$53
			.db	$CE,$98,$31,$CE
			.db	$9A,$E3,$E2,$8C
			.db	$63,$CC,$D9,$71
			.db	$52,$8E,$31,$63
			.db	$CE,$1C,$47,$C7
			.db	$8C,$1C,$3B,$E7
			.db	$CC,$98,$18,$C7
			.db	$D3,$99,$63,$E1
			.db	$25,$2D,$C6,$AA
			.db	$72,$FA,$D4,$C4
			.db	$92,$45,$AB,$6B
			.db	$26,$45,$55,$E7
			.db	$E2,$18,$35,$D5
			.db	$97,$D2,$5A,$55
			.db	$8A,$4A,$B9,$6A
			.db	$55,$A9,$4A,$AB
			.db	$96,$53,$27,$AA
			.db	$B4,$F5,$5D,$29
			.db	$95,$AA,$EA,$94
			.db	$2A,$57,$AF,$58
			.db	$58,$AA,$6A,$55
			.db	$A5,$B4,$A8,$4E
			.db	$4F,$55,$15,$55
			.db	$5A,$AD,$C1,$38
			.db	$E5,$34,$4D,$B3
			.db	$4A,$E5,$D2,$EA
			.db	$30,$56
ut_03_end		.db	$AD
ut_04_beg		.db	$AA
			.db	$95,$63,$71,$8E
			.db	$8E,$65,$35,$2C
			.db	$A7,$E3,$38,$16
			.db	$C7,$E3,$38,$9A
			.db	$8E,$63,$E3,$98
			.db	$8E,$A6,$E9,$58
			.db	$96,$AA,$3C,$35
			.db	$55,$55,$55,$2D
			.db	$2D,$AD,$54,$59
			.db	$AB,$8A,$C5,$AA
			.db	$2E,$5A,$F5,$2A
			.db	$74,$A5,$4A,$75
			.db	$43,$D5,$E8,$0A
			.db	$AF,$54,$5D,$D4
			.db	$B1,$2A,$EC,$2B
			.db	$4A,$6D,$2A,$BA
			.db	$D2,$82,$FE,$A0
			.db	$6A,$2F,$94,$5B
			.db	$C1,$CB,$15,$59
			.db	$7B,$B8,$B8,$A2
			.db	$93,$87,$4E,$DC
			.db	$E2,$42,$5D,$7A
			.db	$94,$8B,$C7,$56
			.db	$78,$31,$7C,$05
			.db	$C0,$FF,$54,$ED
			.db	$45,$B4,$55,$A8
			.db	$15,$24,$A9,$0E
			.db	$3E,$F8,$E5,$E6
			.db	$E8,$7C,$0A,$C0
			.db	$FF,$B8,$C0,$7F
			.db	$C0,$E8,$01,$1E
			.db	$1E,$F0,$43,$7A
			.db	$B4,$EF,$83,$FF
			.db	$0F,$FC,$07,$3F
			.db	$F8,$07,$1F,$FC
			.db	$23,$F4,$07,$AD
			.db	$B6,$E0,$65,$57
			.db	$F5,$80,$7F,$E0
			.db	$81,$3F,$38,$E8
			.db	$83,$01,$3F,$68
			.db	$AA,$0E,$EE,$1F
			.db	$F8,$8F,$1F,$FE
			.db	$E1,$87,$1F,$3E
			.db	$DC,$CA,$C2,$BF
			.db	$EE,$01,$7F,$FC
			.db	$C0,$3F,$3E,$F0
			.db	$FB,$C0,$D3,$07
			.db	$8F,$1F,$FC,$F9
			.db	$07,$9F,$7F,$70
			.db	$F8,$67,$C1,$C7
			.db	$3F,$F0,$F0,$0F
			.db	$0F,$7F,$3C,$F8
			.db	$F9,$E0,$E3,$03
			.db	$1E,$3F,$F0,$F0
			.db	$E3,$C3,$E3,$87
			.db	$47,$0F,$78,$FC
			.db	$F1,$C1,$C3,$87
			.db	$87,$8F,$1F,$07
			.db	$07,$FF,$1F,$1C
			.db	$F8,$3F,$0E,$5E
			.db	$03,$07,$E7,$3F
			.db	$34,$1C,$BF,$1A
			.db	$83,$E0,$81,$FB
			.db	$7F,$00,$F6,$F7
			.db	$E1,$08,$0C,$9C
			.db	$FF,$17,$10,$BC
			.db	$FF,$E3,$01,$F0
			.db	$FC,$FF,$F1,$A0
			.db	$CE,$FF,$63,$C0
			.db	$F0,$FC,$7F,$29
			.db	$FC,$01,$3C,$3C
			.db	$84,$9F,$3F,$4F
			.db	$C5,$27,$1C,$1C
			.db	$0E,$8F,$3F,$EE
			.db	$C3,$07,$06,$C6
			.db	$C3,$C3,$EF,$63
			.db	$79,$08,$F6,$81
			.db	$81,$1F,$78,$F1
			.db	$F3,$20,$3A,$0E
			.db	$1E,$F4,$C3,$83
			.db	$3F,$3E,$70,$78
			.db	$C0,$E0,$C3,$C5
			.db	$7D,$3C,$F8,$C1
			.db	$03,$03,$07,$87
			.db	$57,$AF,$FE,$71
			.db	$C0,$C1,$07,$06
			.db	$0E,$1F,$5F,$3E
			.db	$1F,$1E,$44,$78
			.db	$F0,$00,$F8,$7A
			.db	$B5,$3D,$0E,$0E
			.db	$3A,$71,$20,$58
			.db	$9D,$B7,$C7,$0F
			.db	$21,$E3,$1F,$08
			.db	$C0,$A5,$FD,$3C
			.db	$18,$5A,$7D,$1D
			.db	$14,$42,$A5,$F7
			.db	$41,$00,$DE,$F3
			.db	$2F,$1C,$0C,$E7
			.db	$E7,$20,$20,$F0
			.db	$F8,$F0,$7D,$78
			.db	$78,$0E,$3C,$70
			.db	$70,$E0,$E0,$F1
			.db	$F9,$59,$24,$F8
			.db	$A2,$07,$3F,$18
			.db	$1C,$3C,$3E,$3E
			.db	$1C,$AA,$6B,$C3
			.db	$0F,$08,$70,$F8
			.db	$FD,$75,$40,$A1
			.db	$D7,$8F,$07,$00
			.db	$78,$F8,$FF,$C3
			.db	$00,$87,$1F,$3F
			.db	$0A,$00,$FC,$FD
			.db	$FF,$03,$06,$BF
			.db	$7F,$2E,$00,$E0
			.db	$F0,$FF,$AF,$04
			.db	$38,$FE,$7D,$10
			.db	$08,$00,$0F,$7F
			.db	$FF,$C4,$01,$CF
			.db	$6F,$05,$10,$1E
			.db	$07,$0E,$7E,$FF
			.db	$8D,$00,$5C,$DF
			.db	$0F,$04,$54,$FE
			.db	$80,$83,$DF,$7F
			.db	$E0,$00,$AF,$BF
			.db	$0A,$80,$EA,$DD
			.db	$03,$70,$F0,$FF
			.db	$0F,$08,$70,$FD
			.db	$B7,$40,$A0,$DB
			.db	$6A,$D0,$01,$3C
			.db	$FC,$FF,$03,$56
			.db	$FC,$F7,$03,$03
			.db	$D4,$F8,$A9,$25
			.db	$B5,$1F,$F0,$E0
			.db	$FF,$3F,$10,$E0
			.db	$0F,$3F,$70,$A0
			.db	$07,$BF,$F8,$E0
			.db	$E0,$A8,$D7,$00
			.db	$0F,$FE,$FF,$12
			.db	$38,$F0,$C1,$01
			.db	$DA,$3A,$1F,$1A
			.db	$70,$FC,$F3,$C0
			.db	$80,$B2,$3F,$C0
			.db	$03,$FF,$FC,$C1
			.db	$81,$E1,$81,$03
			.db	$7E,$F0,$E1,$2A
			.db	$75,$F5,$0F,$1C
			.db	$30,$E8,$8D,$0F
			.db	$5A,$02,$E0,$D7
			.db	$7F,$7E,$00,$18
			.db	$FC,$C4,$0B,$58
			.db	$AC,$AF,$94,$34
			.db	$FD,$07,$0F,$08
			.db	$EA,$E7,$0D,$14
			.db	$5A,$FD,$AA,$0B
			.db	$00,$FE,$F8,$07
			.db	$07,$F0,$FA,$16
			.db	$40,$A0,$5F,$B7
			.db	$04,$BA,$F4,$3F
			.db	$3C,$40,$D0,$5F
			.db	$B1,$80,$A5,$6F
			.db	$4F,$1B,$69,$F2
			.db	$C3,$01,$FC,$F0
			.db	$07,$03,$F0,$D9
			.db	$17,$14,$68,$D5
			.db	$C5,$0F,$6A,$F4
			.db	$F1,$C2,$85,$CA
			.db	$0F,$1E,$50,$E2
			.db	$5E,$F9,$E0,$CB
			.db	$57,$94,$22,$0D
			.db	$5E,$3A,$80,$71
			.db	$FB,$D3,$05,$F8
			.db	$81,$07,$78,$70
			.db	$E7,$EA,$C1,$07
			.db	$17,$EA,$A8,$A9
			.db	$6A,$51,$85,$7E
			.db	$FC,$78,$41,$8B
			.db	$5C,$AA,$FE,$00
			.db	$05,$78,$F8,$5E
			.db	$F1,$C0,$4A,$BD
			.db	$35,$59,$D4,$15
			.db	$2A,$05,$1B,$3F
			.db	$1D,$45,$54,$74
			.db	$AD,$A2,$84,$56
			.db	$FE,$1F,$F0,$C0
			.db	$8F,$3F,$A2,$A2
			.db	$DA,$D5,$0A,$12
			.db	$D1,$55,$83,$0D
			.db	$3C,$FC,$71,$C1
			.db	$D0,$A5,$97,$0E
			.db	$15,$5A,$7A,$A9
			.db	$A1,$A6,$3F,$E0
			.db	$81,$8F,$BD,$C4
			.db	$94,$DA,$F5,$FE
			.db	$B1,$17,$3C,$B5
			.db	$D0,$A2,$A3,$95
			.db	$06,$1E,$7C,$B1
			.db	$52,$A2,$C5,$45
			.db	$8B,$56,$8F,$5E
			.db	$74,$E8,$D0,$47
			.db	$47,$42,$2B,$7D
			.db	$C1,$17,$7B,$E1
			.db	$8A,$A4,$94,$8B
			.db	$AE,$F4,$42,$4B
			.db	$2B,$B5,$54,$57
			.db	$50,$E1,$A9,$4B
			.db	$B5,$52,$25,$45
			.db	$3F,$BE,$E4,$40
			.db	$A9,$A5,$8E,$5A
			.db	$A2,$D2,$AA
ut_04_end		.db	$95
ut_05_beg		.db	$AA,$BA,$AA,$A6
			.db	$AA,$AA,$AA,$AA
			.db	$69,$AA,$B5,$AA
			.db	$AA,$54,$55,$8E
			.db	$99,$66,$95,$39
			.db	$D3,$94,$AA,$63
			.db	$39,$63,$AC,$AA
			.db	$59,$9A,$A9,$AA
			.db	$AA,$CA,$8A,$E3
			.db	$4C,$69,$CC,$A9
			.db	$8A,$33,$CE,$4C
			.db	$33,$D3,$2A,$AD
			.db	$B2,$4A,$39,$CD
			.db	$AA,$2A,$67,$A9
			.db	$1A,$AB,$CA,$AA
			.db	$AA,$72,$C6,$AA
			.db	$B2,$CA,$38,$56
			.db	$39,$65,$55,$55
			.db	$55,$55,$95,$AA
			.db	$AA,$AA,$AA,$AA
			.db	$AA,$AA,$54,$55
			.db	$55,$95,$AA,$AA
			.db	$AA,$AA,$AA,$AA
			.db	$AA,$AA,$AA,$AA
			.db	$AA,$AA,$AA,$AA
			.db	$AA,$AA,$AA,$AA
			.db	$AA,$AA,$AA,$AA
			.db	$AA,$AA,$AA,$AA
			.db	$AA,$AA,$AA,$AA
			.db	$AA,$AA,$AA,$AA
			.db	$AA,$AA,$AA,$AA
			.db	$AA,$AA,$AA,$AA
			.db	$AA,$AA,$AA,$AA
			.db	$AA,$AA,$AA,$AA
			.db	$AA,$AA,$AA,$2A
			.db	$55,$B5,$AA,$AA
			.db	$AA,$AA,$AA,$AA
			.db	$AA,$AA,$AA,$AA
			.db	$AA,$AA,$CA,$2C
			.db	$55,$55,$AB,$AA
			.db	$AA,$AA,$56,$55
			.db	$55,$AB,$AA,$AA
			.db	$AA,$52,$55,$55
			.db	$55,$B5,$AA,$9A
			.db	$AA,$9C,$73,$0E
			.db	$7A,$15,$CF,$58
			.db	$15,$B3,$6A,$9C
			.db	$E5,$69,$14,$E5
			.db	$71,$3C,$8E,$E3
			.db	$38,$8E,$E3,$B8
			.db	$E8,$2C,$AB,$D1
			.db	$E1,$01,$18,$FC
			.db	$FF,$F3,$40,$81
			.db	$96,$0D,$0A,$74
			.db	$FD,$D2,$CB,$F3
			.db	$1C,$00,$FE,$FF
			.db	$09,$DC,$0F,$21
			.db	$38,$28,$DA,$72
			.db	$D0,$B5,$D7,$8F
			.db	$0F,$F8,$FF,$87
			.db	$01,$7F,$3E,$60
			.db	$F0,$C1,$C0,$CB
			.db	$C3,$8A,$97,$1E
			.db	$EF,$03,$3F,$FE
			.db	$F8,$F8,$C7,$83
			.db	$1F,$0F,$1C,$7B
			.db	$6D,$3A,$5E,$B9
			.db	$F1,$6E,$C1,$9F
			.db	$3F,$FE,$F8,$E1
			.db	$E1,$87,$07,$87
			.db	$0F,$8F,$17,$BD
			.db	$7E,$81,$8F,$1F
			.db	$1C,$F8,$E1,$C1
			.db	$83,$07,$07,$0F
			.db	$0F,$1E,$3F,$1D
			.db	$F8,$F8,$E1,$87
			.db	$1F,$1E,$3C,$7C
			.db	$38,$F0,$F0,$D4
			.db	$D1,$03,$1F,$1F
			.db	$7C,$F0,$E1,$81
			.db	$87,$0F,$0E,$1E
			.db	$1C,$38,$1E,$7C
			.db	$7C,$E0,$C3,$07
			.db	$0F,$1E,$3C,$38
			.db	$78,$F0,$E1,$C0
			.db	$C1,$E3,$07,$1F
			.db	$7C,$F8,$E0,$C1
			.db	$83,$07,$0F,$1F
			.db	$1C,$0E,$0E,$1E
			.db	$FC,$F0,$C1,$83
			.db	$0F,$1F,$3E,$F8
			.db	$F0,$A0,$17,$F8
			.db	$F0,$C0,$1F,$1F
			.db	$DC,$F0,$E0,$84
			.db	$0F,$0F,$7C,$78
			.db	$00,$1F,$FE,$F8
			.db	$C3,$87,$2F,$1E
			.db	$38,$72,$8E,$9A
			.db	$C3,$83,$0F,$3E
			.db	$FC,$F3,$0F,$FC
			.db	$C1,$D0,$1F,$1C
			.db	$7C,$78,$81,$8F
			.db	$0F,$F0,$E2,$F8
			.db	$FD,$7C,$78,$06
			.db	$FA,$C0,$81,$87
			.db	$0E,$7C,$F8,$78
			.db	$E0,$E0,$FC,$7D
			.db	$1F,$1F,$1F,$18
			.db	$F0,$C0,$C3,$87
			.db	$0F,$1E,$3E,$E0
			.db	$C0,$E3,$FB,$FD
			.db	$F0,$60,$08,$0E
			.db	$0E,$7E,$F8,$F0
			.db	$F0,$C1,$03,$38
			.db	$3C,$1F,$1F,$BF
			.db	$76,$C0,$C0,$81
			.db	$87,$1F,$3E,$3C
			.db	$78,$B8,$1C,$38
			.db	$78,$F2,$CF,$9F
			.db	$0F,$18,$70,$E0
			.db	$E8,$A5,$2F,$FA
			.db	$C3,$81,$0B,$70
			.db	$F8,$F8,$FF,$87
			.db	$0F,$0C,$70,$E0
			.db	$E1,$7D,$78,$B0
			.db	$82,$0F,$1F,$E0
			.db	$F0,$F9,$FE,$1F
			.db	$2D,$0A,$0A,$7C
			.db	$E0,$40,$23,$FA
			.db	$E1,$97,$15,$60
			.db	$F8,$B9,$FF,$3F
			.db	$1A,$44,$03,$0B
			.db	$81,$E1,$D0,$B3
			.db	$F9,$C2,$0F,$0C
			.db	$BC,$FC,$FF,$A7
			.db	$C5,$03,$82,$20
			.db	$A1,$B8,$78,$F8
			.db	$F9,$A1,$27,$0B
			.db	$8C,$FA,$FA,$F7
			.db	$8F,$16,$04,$80
			.db	$82,$C3,$CF,$5D
			.db	$79,$78,$D0,$D1
			.db	$4B,$8B,$46,$FE
			.db	$EA,$73,$38,$30
			.db	$A0,$C8,$87,$0F
			.db	$1F,$2E,$BA,$F0
			.db	$F0,$D1,$A5,$F1
			.db	$E1,$41,$05,$1C
			.db	$3F,$FE,$F4,$C1
			.db	$42,$15,$95,$74
			.db	$85,$0F,$1F,$FD
			.db	$E0,$81,$11,$8E
			.db	$3E,$BD,$7A,$45
			.db	$0B,$47,$E1,$E3
			.db	$53,$17,$5C,$E8
			.db	$C5,$81,$42,$C8
			.db	$BA,$7A,$7D,$76
			.db	$E0,$C7,$4B,$D5
			.db	$48,$4B,$2C,$F5
			.db	$C3,$41,$05,$51
			.db	$78,$ED,$35,$37
			.db	$5D,$57,$8D,$83
			.db	$8A,$A2,$2A,$FC
			.db	$F8,$50,$21,$09
			.db	$3D,$9B,$7E,$9E
			.db	$AE,$AE,$86,$85
			.db	$43,$A9,$5C,$5C
			.db	$DE,$AA,$42,$81
			.db	$82,$2E,$BF,$BE
			.db	$5B,$1F,$0E,$54
			.db	$A8,$D0,$F0,$52
			.db	$63,$A3,$E3,$E3
			.db	$C2,$85,$E3,$AB
			.db	$C7,$47,$07,$0D
			.db	$4D,$C5,$D2,$32
			.db	$0F,$9F,$9F,$2B
			.db	$05,$03,$0B,$3D
			.db	$3C,$74,$58,$6A
			.db	$7D,$7C,$3C,$1D
			.db	$87,$2B,$78,$70
			.db	$30,$FF,$FF,$77
			.db	$20,$00,$50,$69
			.db	$3A,$0E,$97,$D7
			.db	$83,$81,$C2,$EF
			.db	$FF,$FF,$07,$01
			.db	$40,$A8,$54,$A9
			.db	$AA,$00,$00,$FD
			.db	$FF,$FF,$5F,$00
			.db	$00,$20,$57,$67
			.db	$03,$00,$00,$FE
			.db	$FF,$FF,$0B,$00
			.db	$00,$D4,$FF,$02
			.db	$03,$83,$F7,$FF
			.db	$FF,$01,$00,$20
			.db	$BC,$0F,$06,$87
			.db	$C3,$FF,$FF,$E7
			.db	$41,$30,$38,$E0
			.db	$60,$78,$FC,$FF
			.db	$1E,$0E,$82,$E3
			.db	$13,$07,$83,$E1
ut_0f_beg
ut_16_beg		.db	$AA,$FF,$78,$1C
			.db	$0C,$06,$06,$83
			.db	$E1,$FB,$FB,$78
			.db	$1C,$0E,$07,$01
			.db	$40,$F8,$FF,$7D
			.db	$1E,$0E,$C7,$61
			.db	$00,$08,$BF,$FF
			.db	$8F,$C7,$E1,$30
ut_14_beg		.db	$AA,$80,$F0,$F7
			.db	$FF,$71,$18,$0C
			.db	$C2,$10,$1C,$BF
			.db	$FF,$9F,$C3,$C1
			.db	$10,$04,$81,$F0
			.db	$F9,$FB,$3A,$1E
			.db	$9F,$70,$10,$10
			.db	$9E,$FF,$FF,$53
ut_14_end		.db	$10,$00,$00,$C1
			.db	$F2,$FF,$7F,$1F
			.db	$06,$F3,$70,$20
			.db	$00,$84,$DF,$FF
			.db	$FF,$38,$0C,$04
			.db	$42,$BE,$FA,$7C
			.db	$1C,$0C,$CF,$C7
			.db	$61,$00,$78,$FF
			.db	$FD,$CF,$40,$30
			.db	$38,$1C,$06,$C7
			.db	$FF,$E7,$F1,$10
			.db	$0C,$18,$1A,$12
			.db	$E7,$FF,$7F,$1E
			.db	$0E,$03,$01,$C1
			.db	$F0,$FE,$FF,$3E
			.db	$1E,$0C,$83,$41
			.db	$60,$70,$3C,$FF
			.db	$FF,$E3,$20,$08
			.db	$81,$E1,$70,$78
			.db	$FF,$BF,$C7,$41
			.db	$30,$38,$0C,$86
			.db	$C3,$FB,$FD,$3D
			.db	$0C,$06,$C3,$E1
			.db	$60,$58,$BC,$00
			.db	$CF,$E3,$30,$38
			.db	$1E,$1C,$1C,$0E
			.db	$C7,$E7,$F3,$38
			.db	$0E,$86,$C7,$44
			.db	$86,$C0,$F8,$FC
			.db	$BF,$1E,$4F,$CB
			.db	$51,$08,$00,$82
			.db	$F3,$FB,$3F,$8F
			.db	$87,$E3,$31,$30
			.db	$00,$0C,$CF,$FF
			.db	$FF,$78,$28,$08
			.db	$C7,$23,$03,$43
			.db	$E2,$FB,$FF,$4E
			.db	$C1,$C0,$F0,$3C
			.db	$0D,$C3,$61,$70
			.db	$7C,$3E,$1F,$C7
			.db	$E3,$70,$78,$1E
			.db	$0E,$06,$C1,$E1
			.db	$F9,$7D,$3E,$0F
			.db	$83,$E1,$70,$08
			.db	$C1,$E1,$78,$FD
			.db	$BF,$CF,$C3,$40
			.db	$20,$38,$DE,$8F
			.db	$07,$87,$C1,$F3
			.db	$F9,$3C,$0E,$86
			.db	$C1,$F1,$FC,$3C
			.db	$1E,$02,$81,$E0
			.db	$F9,$FF,$3E,$0F
			.db	$83,$C1,$71,$38
			.db	$1E,$0E,$83,$C1
			.db	$F0,$F8,$FE,$BF
			.db	$87,$03,$02,$E0
			.db	$78,$3E,$9F,$C7
			.db	$E1,$60,$70,$18
			.db	$9E,$DF,$CF,$E3
			.db	$41,$60,$70,$3C
			.db	$1F,$8F,$C3,$60
			.db	$38,$8C,$C1,$F1
			.db	$F9,$7F,$1F,$07
			.db	$03,$81,$E0,$BC
			.db	$BE,$9E,$67,$A5
			.db	$44,$04,$85,$C1
			.db	$F0,$7C,$BE,$9F
			.db	$8F,$87,$41,$21
			.db	$70,$38,$3E,$9F
			.db	$47,$C3,$61,$74
			.db	$7C,$3E,$0F,$1C
			.db	$0C,$83,$E7,$F3
			.db	$FB,$38,$08,$04
			.db	$8F,$8F,$D7,$E3
			.db	$60,$30,$1C,$9E
			.db	$CF,$EB,$38,$2C
			.db	$0C,$0E,$8F,$F7
			.db	$F3,$71,$30,$18
			.db	$1C,$8E,$C7,$E3
			.db	$F1,$78,$3C,$0E
			.db	$87,$C3,$E0,$70
			.db	$3C,$1F,$8F,$C3
			.db	$E1,$F9,$FC,$1E
			.db	$0F,$01,$81,$A0
			.db	$78,$FA,$7E,$5E
			.db	$47,$C3,$60,$B4
			.db	$2C,$AB,$C7,$E3
			.db	$F5,$30,$30,$18
ut_0f_end	.db	$3C,$FF,$DF,$C7
			.db	$40,$20,$28,$AE
			.db	$E7,$F3,$5A,$8D
			.db	$81,$41,$61,$7A
			.db	$3E,$9F,$97,$96
			.db	$A2,$82,$A2,$F4
			.db	$FD,$FD,$3D,$1A
			.db	$06,$82,$A0,$38
			.db	$3C,$3D,$AF,$AB
			.db	$CB,$C6,$62,$A8
			.db	$A8,$AC,$4E,$AF
			.db	$55,$C1,$61,$F8
			.db	$F8,$7A,$3E,$06
			.db	$06,$C3,$F1,$74
			.db	$59,$34,$1C,$8E
			.db	$D7,$EB,$E5,$B4
			.db	$28,$14,$A6,$CA
			.db	$F9,$78,$38,$1A
			.db	$16,$8E,$C7,$E7
			.db	$79,$B9,$34,$0C
			.db	$06,$A3,$E1,$78
			.db	$3C,$3D,$4F,$A7
			.db	$A3,$D1,$B0,$3C
			.db	$0E,$87,$C5,$D0
			.db	$78,$7A,$9F,$57
			.db	$4B,$45,$A1,$52
			.db	$B9,$3C,$97,$95
			.db	$42,$91,$28,$0D
			.db	$97,$CB,$D7,$EB
			.db	$F1,$30,$14,$2A
			.db	$9D,$AF,$EB,$6A
			.db	$52,$14,$A5,$B2
			.db	$3A
ut_16_end		.db	$AA,$57,$CB
			.db	$D1,$52,$A9,$34
			.db	$1A,$15,$8D,$8A
			.db	$82,$42,$A5,$F5
			.db	$FD,$BE,$9E,$AB
			.db	$45,$A1,$30,$2A
			.db	$AA,$AA,$9A,$AE
			.db	$AB,$AB,$55,$91
			.db	$28
ut_15_beg		.db	$AA,$DF,$D7
			.db	$53,$43,$61,$70
			.db	$58,$2C,$4D,$4D
			.db	$D7,$EB,$EA,$D5
			.db	$68,$28,$8A,$A6
			.db	$D5,$B5,$B5,$34
			.db	$AA,$42,$D3,$F3
			.db	$EA,$3A,$2C,$04
			.db	$8B,$D5,$EB,$75
			.db	$75,$2A,$0A,$0A
			.db	$45,$D1,$B4,$7A
			.db	$BD,$AE,$AB,$55
			.db	$B1,$50,$2C,$AD
			.db	$96,$A3,$51,$A9
			.db	$54,$AD,$DE,$AE
			.db	$55,$A1,$50,$59
			.db	$DF,$DE,$5A,$55
			.db	$28,$08,$12,$8A
			.db	$A6,$EB,$EB,$F5
			.db	$6A,$55,$2A,$8A
			.db	$92,$AA,$5A,$AD
			.db	$6B,$B5,$32,$2A
			.db	$2D,$AD,$AA,$6B
			.db	$49,$94,$AA,$FA
			.db	$BB,$AD,$55,$81
			.db	$10,$84,$28,$A9
			.db	$B6,$6F,$EF,$ED
			.db	$5A,$55,$29,$24
			.db	$92,$2A,$D5,$D6
			.db	$EB,$6A,$55,$24
			.db	$AA,$AA,$5E,$57
			.db	$8B,$A2,$52,$B5
			.db	$5E,$55,$25,$0A
			.db	$85,$44,$A9,$AA
			.db	$AE,$DE,$EE,$BA
			.db	$B6,$7C,$15,$04
ut_15_end		.db	$8A,$A6,$F5,$BA
			.db	$D5,$2A,$8A,$2A
			.db	$15,$3D,$BE,$4E
			.db	$14,$D6,$F6,$BD
			.db	$52,$00,$41,$55
			.db	$AF,$57,$55,$A8
			.db	$94,$BE,$6F,$2B
			.db	$51,$A8,$D8,$DA
ut_05_end
ut_06_beg		.db	$AA,$3C,$8E,$03
			.db	$1E,$73,$F8,$7B
			.db	$8E,$81,$61,$38
			.db	$1E,$CF,$E3,$71
			.db	$18,$0E,$C7,$F3
			.db	$70,$18,$8D,$C7
			.db	$D5,$7A,$B4,$48
			.db	$86,$16,$6B,$75
			.db	$51,$55,$9F,$07
			.db	$0C,$FC,$FF,$8F
			.db	$03,$60,$F0,$67
			.db	$07,$10,$F4,$CF
			.db	$07,$78,$F8,$0F
			.db	$1F,$68,$E8,$13
			.db	$1D,$7C,$1B,$F0
			.db	$E1,$FF,$79,$80
			.db	$87,$7F,$80,$01
			.db	$7F,$D5,$01,$96
			.db	$AE,$3F,$AC,$41
			.db	$3F,$A8,$40,$3F
			.db	$FD,$01,$FC,$FF
			.db	$0F,$C0,$C3,$3F
			.db	$00,$06,$FF,$01
			.db	$38,$FA,$1A,$E0
			.db	$A7,$4B,$C0,$07
			.db	$B2,$F6,$3F,$E0
			.db	$FF,$FC,$01,$FE
			.db	$03,$0B,$F0,$0F
			.db	$60,$F5,$1F,$D0
			.db	$B7,$62,$90,$EE
			.db	$FB,$07,$FE,$0F
			.db	$60,$80,$FF,$00
			.db	$20,$FF,$01,$C0
			.db	$2F,$14,$40,$3F
			.db	$E1,$FA,$E0,$7F
			.db	$00,$1C,$F0,$0F
			.db	$C0,$E3,$18,$00
			.db	$DE,$40,$A3,$F8
			.db	$3F,$B8,$7F,$84
			.db	$03,$FE,$07,$60
			.db	$D5,$07,$C0,$13
			.db	$DC,$1E,$C0,$FF
			.db	$23,$0C,$F0,$1F
			.db	$C0,$FB,$1C,$80
			.db	$DF,$02,$82,$F9
			.db	$4F,$10,$80,$FF
			.db	$01,$E0,$7F,$00
			.db	$F8,$01,$FC,$BF
			.db	$F3,$00,$FF,$07
			.db	$CE,$F7,$3B,$F0
			.db	$00,$FC,$0F,$38
			.db	$80,$FF,$41,$78
			.db	$37,$78,$01,$F8
			.db	$7F,$18,$00,$FF
			.db	$07,$F8,$37,$00
			.db	$C0,$FF,$C7,$1B
			.db	$F0,$FF,$D0,$FF
			.db	$01,$E0,$FF,$FB
			.db	$09,$F0,$FF,$81
			.db	$DF,$00,$F8,$0F
			.db	$FC,$03,$F8,$FF
			.db	$EB,$17,$00,$FE
			.db	$0F,$E8,$00,$FC
			.db	$7F,$F0,$01,$C0
			.db	$FF,$77,$3C,$00
			.db	$FE,$9F,$02,$00
			.db	$FC,$FF,$FF,$0B
			.db	$80,$FF,$0F,$00
			.db	$00,$32,$E5,$FF
			.db	$01,$AC,$75,$05
			.db	$60,$08,$F9,$7F
			.db	$00,$F9,$7C,$00
			.db	$FE,$01,$40,$FD
			.db	$85,$54,$FF,$FF
			.db	$00,$E6,$20,$04
			.db	$A0,$DF,$44,$FD
			.db	$FF,$A8,$7F,$00
			.db	$00,$C3,$29,$F0
			.db	$FF,$B7,$8A,$EA
			.db	$E2,$3F,$00,$C0
			.db	$F8,$0F,$FA,$D7
			.db	$4A,$F5,$92,$1F
			.db	$00,$E0,$F8,$2F
			.db	$D0,$FF,$4A,$7B
			.db	$FD,$00,$00,$87
			.db	$EC,$A3,$FC,$2F
			.db	$AE,$FF,$01,$A0
			.db	$41,$BA,$00,$F8
			.db	$7F,$F5,$FF,$00
			.db	$6E,$28,$A7,$00
			.db	$40,$4B,$FF,$7F
			.db	$00,$FF,$52,$1F
			.db	$00,$AA,$C0,$7F
			.db	$03,$F0,$F7,$F8
			.db	$3F,$00,$56,$FB
			.db	$0F,$00,$90,$AA
			.db	$FF,$AF,$80,$FF
			.db	$6B,$0C,$29,$05
			.db	$40,$57,$29,$D5
			.db	$FF,$DB,$DD,$02
			.db	$D4,$8B,$B0,$48
			.db	$15,$A0,$57,$B7
			.db	$B5,$FF,$56,$02
			.db	$E8,$2F,$E2,$15
			.db	$75,$00,$48,$BB
			.db	$AB,$EE,$BB,$F0
			.db	$6F,$54,$47,$29
			.db	$00,$00,$AB,$FE
			.db	$FF,$06,$FE,$17
			.db	$E4,$A8,$BE,$02
			.db	$00,$F0,$6F,$FF
			.db	$FF,$00,$B0,$D5
			.db	$FF,$0A,$25,$00
			.db	$C0,$FF,$FF,$FF
			.db	$00,$C0,$FF,$DF
			.db	$52,$2A,$00,$E0
			.db	$FF
ut_08_beg		.db	$AA,$7F,$01
			.db	$E0,$FF,$2B,$E5
			.db	$6B,$01,$80,$FF
			.db	$FF,$FF,$00,$C0
			.db	$FF,$6F,$05,$F6
			.db	$17,$00,$FC,$FF
			.db	$FF,$0F,$00,$FF
			.db	$C1,$7F,$A0,$FF
			.db	$01,$C0,$FF,$FF
			.db	$7F,$00,$F0,$0F
			.db	$FC,$07,$F8,$7F
			.db	$00,$C0,$FF,$FF
			.db	$2F,$00,$F0,$55
			.db	$FD,$03,$F8,$5F
			.db	$00,$00,$FF,$FF
			.db	$5F,$00,$80,$FF
			.db	$6F,$09,$E0,$FF
			.db	$02,$00,$E0,$FF
			.db	$7F,$00,$00,$F8
			.db	$FF,$08,$09,$75
			.db	$7F,$03,$00,$80
			.db	$FF,$3F,$00,$00
			.db	$F0,$FF,$01,$40
			.db	$ED,$BF,$01,$00
			.db	$00,$E0,$FF,$0F
			.db	$20,$00,$F8,$FF
			.db	$00,$40,$E2,$DE
			.db	$00,$64,$15,$00
			.db	$FE,$FF,$E8,$0F
			.db	$00,$FE,$03,$80
			.db	$5F,$BA,$0A,$00
			.db	$DD,$2F,$00,$F8
			.db	$FF,$2F,$15,$00
			.db	$FF,$1F,$00,$90
			.db	$FC,$FF,$03,$40
			.db	$6E,$29,$00,$F8
			.db	$FF,$FF,$16,$00
			.db	$F8,$FF,$01,$00
			.db	$C0,$FF,$0F,$00
			.db	$DA,$B5,$2B,$00
			.db	$FC,$FF,$1F,$00
			.db	$00,$FF,$7F,$00
			.db	$00,$F8,$FF,$01
			.db	$A8,$FF,$1F,$08
			.db	$00,$E0,$FF,$5F
			.db	$44,$00,$F0,$FF
			.db	$21,$1A,$10,$FF
			.db	$07,$80,$6B,$FF
			.db	$05,$D2,$2A,$00
			.db	$FC,$FF,$6B,$1D
			.db	$00,$F8,$1F,$C4
			.db	$06,$80,$FF,$5F
			.db	$44,$A2,$6A,$25
			.db	$ED,$FF,$07,$00
			.db	$F8,$FF,$FF,$05
			.db	$00,$FE,$1F,$8E
			.db	$00,$D0,$FF,$FB
			.db	$0D,$00,$FC,$42
			.db	$FD,$03,$F4,$FF
			.db	$01,$00,$FE,$FF
			.db	$7F,$01,$80,$FF
			.db	$03,$0A,$00,$F4
			.db	$3F,$A1,$AE,$52
			.db	$7F,$05,$42,$D5
			.db	$DD,$ED,$F5,$77
			.db	$00,$80,$FF,$FF
			.db	$7F,$00,$E0,$7F
			.db	$EB,$05,$00,$FF
			.db	$47,$AA,$02,$FC
			.db	$FF,$00,$20,$D5
			.db	$FF,$0F,$00,$D5
			.db	$EF,$D7,$02,$00
			.db	$FF,$FF,$2A,$00
			.db	$E8,$FF,$03,$00
			.db	$10,$FE,$FF,$10
			.db	$A9,$A4,$FC,$BF
			.db	$10,$35,$55,$2D
			.db	$49,$36,$49,$F7
			.db	$FF,$00,$80,$01
			.db	$FC,$FF,$87,$4B
			.db	$00,$FC,$0F,$22
			.db	$13,$D4,$5F,$45
			.db	$5D,$01,$EC,$FB
			.db	$FF,$00,$40,$D5
			.db	$FF,$17,$80,$B6
			.db	$DA,$7E,$01,$A8
			.db	$A5,$7D,$00,$FF
			.db	$7F,$69,$09,$00
			.db	$FA,$FD,$2D,$00
			.db	$40,$7F,$FF,$03
			.db	$C0,$BE,$5D,$77
			.db	$11,$54,$57,$11
			.db	$15,$55,$DF,$2D
			.db	$11,$49,$55,$05
			.db	$D3,$FF,$0F,$00
			.db	$F8,$FF,$7F,$01
			.db	$00,$B7,$6F,$0B
			.db	$02,$6A,$EF,$AE
			.db	$00,$B4,$FB,$5D
			.db	$11,$A9,$AA,$DF
			.db	$0A,$44,$CA,$FE
			.db	$07,$80,$6A,$DD
			.db	$77,$11,$A8,$DF
			.db	$5D,$1B,$01,$80
ut_06_end		.db	$FF,$5F,$95,$00
			.db	$E0,$BB,$AA,$94
			.db	$20,$ED,$5D,$AB
			.db	$02,$E9,$7F,$65
			.db	$5F,$00,$D0,$AD
			.db	$BA,$97,$40,$DD
			.db	$AD,$B6,$0A,$A9
			.db	$AD,$54,$B5,$08
			.db	$81,$EA,$DF,$25
			.db	$00,$F4,$FF,$55
			.db	$09,$01,$BA,$AF
			.db	$2A,$85,$D0,$7B
			.db	$84,$AA,$49,$FF
			.db	$9F,$22,$41,$F9
			.db	$6F,$25,$08,$A8
			.db	$BE,$AB,$50,$92
			.db	$AA,$7B,$25,$A9
			.db	$D5,$BA,$0A,$92
			.db	$56,$AB,$02,$A8
			.db	$FF,$4B,$50,$5A
			.db	$55,$52,$08,$AA
			.db	$DF,$AD,$2A,$AA
			.db	$F7,$AE,$12,$12
			.db	$55,$6F,$25,$51
			.db	$AA,$EB,$D6,$2A
			.db	$52,$B5,$AE,$15
			.db	$A0,$F6,$AB,$90
			.db	$A4,$52,$7B,$45
			.db	$08,$D5,$FE,$7F
			.db	$05,$20,$55,$ED
			.db	$B7,$11,$52,$D5
			.db	$76,$6B,$91,$54
			.db	$B5,$57,$05,$52
			.db	$15,$B5,$BF,$12
			.db	$55,$29,$F5,$56
			.db	$91,$AA,$AA,$5A
			.db	$25,$25,$EA,$5B
			.db	$25,$AD,$40,$52
			.db	$B5,$AF,$02,$49
			.db	$6B,$F7,$6E,$09
			.db	$A5,$56,$DD,$0A
			.db	$A9,$B7,$AA,$56
			.db	$10,$55,$DB,$AB
			.db	$22,$52,$F7,$B6
			.db	$2D,$48,$EA,$D6
			.db	$AA,$92,$48,$55
			.db	$55,$A5,$24,$B5
			.db	$56,$AA,$AA,$FA
			.db	$05,$94,$BA,$AB
			.db	$54,$55,$D5,$6D
			.db	$15,$22,$55,$55
			.db	$AB,$A8,$54,$7D
			.db	$6B,$55,$A4,$EA
			.db	$A5,$4A,$4A,$55
			.db	$75,$5D,$52,$AA
			.db	$EA,$AB,$44,$D5
			.db	$56,$55,$55,$A1
			.db	$7A,$AD,$4A,$10
			.db	$AA,$7E,$5B,$55
			.db	$24,$A9,$BB,$55
			.db	$25,$A5,$AA,$B5
			.db	$AA,$24,$AA,$DE
			.db	$2A,$55,$45,$A2
			.db	$6A,$B5,$56,$85
			.db	$54,$55,$55,$55
			.db	$55,$6D,$B5,$45
			.db	$AA,$5A,$55,$D7
			.db	$4A,$89,$54,$AF
			.db	$2A,$92,$92,$52
			.db	$BB,$AA,$2A,$49
			.db	$AF,$93,$AA,$AA
			.db	$6A,$6F,$25,$A9
			.db	$AA
ut_08_end		.db	$EE
ut_07_beg		.db	$AA,$F1
			.db	$92,$8E,$1E,$75
			.db	$D1,$C9,$8B,$6A
			.db	$E1,$B4,$78,$C4
			.db	$95,$E3,$A1,$87
			.db	$87,$87,$4E,$39
			.db	$95,$5E,$F0,$E0
			.db	$83,$C7,$E1,$43
			.db	$0F,$1D,$87,$17
			.db	$1D,$7A,$E1,$45
			.db	$5D,$54,$17,$8F
			.db	$6A,$78,$C3,$A9
			.db	$E8,$E1,$96,$4E
			.db	$74,$78,$9C,$E4
			.db	$85,$3E,$F8,$82
			.db	$57,$78,$B1,$D4
			.db	$C3,$8B,$95,$6A
			.db	$E1,$43,$57,$51
			.db	$5D,$96,$07,$7D
			.db	$F0,$22,$EB,$05
			.db	$1F,$AA,$07,$5F
			.db	$A4,$27,$EA,$81
			.db	$2F,$EA,$41,$2F
			.db	$AE,$A8,$95,$CC
			.db	$8B,$2E,$B1,$2B
			.db	$79,$A1,$5E,$A8
			.db	$17,$36,$D1,$2B
			.db	$E9,$23,$37,$E8
			.db	$16,$EA,$41,$EB
			.db	$E8,$2A,$AA,$8B
			.db	$D5,$15,$F6,$C1
			.db	$A3,$A5,$8B,$D2
			.db	$83,$DD,$E0,$95
			.db	$EC,$22,$B5,$51
			.db	$8F,$5A,$0A,$BA
			.db	$51,$5F,$F9,$D2
			.db	$16,$17,$C4,$27
			.db	$AD,$54,$14,$2A
			.db	$BA,$54,$B5,$EA
			.db	$97,$7B,$72,$4D
			.db	$2E,$F4,$42,$0F
			.db	$6D,$00,$F0,$DF
			.db	$FF,$90,$00,$A9
			.db	$D5,$5B,$54,$44
			.db	$2B,$F5,$5F,$74
			.db	$85,$92,$8A,$AD
			.db	$EA,$AB,$6E,$E5
			.db	$46,$BE,$20,$00
			.db	$FC,$FF,$1F,$00
			.db	$A8,$B6,$5F,$02
			.db	$41,$6A,$FB,$B7
			.db	$92,$AA,$22,$95
			.db	$54,$55,$FD,$EA
			.db	$96,$EA,$AF,$2E
			.db	$00,$C0,$FF,$FF
			.db	$01,$C0,$8F,$7F
			.db	$00,$C0,$AD,$FF
			.db	$A0,$A4,$AB,$0B
			.db	$94,$52,$BF,$EC
			.db	$92,$DF,$1D,$80
			.db	$FF,$FF,$1F,$C0
			.db	$EF,$0F,$00,$F8
			.db	$F8,$E2,$80,$5F
			.db	$5F,$26,$F8,$74
			.db	$E1,$41,$FF,$3F
			.db	$80,$FF,$CF,$11
			.db	$E0,$9F,$01,$43
			.db	$F8,$08,$8C,$C7
			.db	$71,$B8,$1E,$C4
			.db	$E3,$F1,$B4,$0F
			.db	$F6,$FF,$61,$00
			.db	$BE,$07,$80,$F3
			.db	$2B,$00,$9E,$87
			.db	$63,$E9,$18,$9C
			.db	$A6,$FF,$C1,$FC
			.db	$3F,$0C,$C0,$FF
			.db	$40,$30,$3E,$05
			.db	$CF,$C0,$39,$78
			.db	$0E,$DF,$41,$FF
			.db	$81,$F9,$E7,$38
			.db	$80,$FF,$81,$60
			.db	$F8,$06,$0E,$C3
			.db	$B3,$F0,$0C,$BC
			.db	$C7,$FE,$20,$FE
			.db	$1F,$87,$E0,$7F
			.db	$30,$0C,$DF,$01
			.db	$F1,$38,$1D,$E6
			.db	$47,$F9,$FC,$03
			.db	$F1,$FF,$38,$80
			.db	$FF,$01,$60,$F8
			.db	$0F,$82,$E7,$71
			.db	$F0,$1C,$96,$CF
			.db	$0F,$C4,$FF,$E3
			.db	$00,$BC,$1F,$01
			.db	$E0,$3F,$00,$9C
			.db	$E7,$01,$FA,$8E
			.db	$76,$1D,$10,$FF
			.db	$8F,$03,$80,$FE
			.db	$0F,$00,$C6,$59
			.db	$7D,$00,$80,$FF
			.db	$21,$A8,$FF,$01
			.db	$F8,$7F,$9E,$01
			.db	$C0,$FF,$40,$10
			.db	$68,$3D,$C3,$07
			.db	$80,$7F,$3C,$02
			.db	$7F,$00,$F8,$FF
			.db	$5F,$01,$C2,$AA
			.db	$B0,$5A,$48,$2F
			.db	$80,$DF,$00,$F7
			.db	$78,$03,$CC,$87
			.db	$F2,$30,$5E,$FE
			.db	$8F,$FA,$48,$14
			.db	$04,$45,$E0,$3F
			.db	$C0,$3C,$EF,$81
			.db	$F1,$74,$1E,$94
			.db	$C7,$71,$28,$FD
			.db	$CF,$DE,$C5,$00
ut_07_end		.db	$DF,$00
ut_09_beg		.db	$AA,$BE
			.db	$7E,$9F,$0E,$AD
			.db	$00,$83,$C3,$E7
			.db	$FF,$FF,$07,$03
			.db	$01,$80,$E5,$ED
			.db	$D7,$D7,$07,$0E
			.db	$0F,$8F,$FF,$3F
			.db	$1F,$0E,$04,$00
			.db	$02,$8F,$9F,$07
			.db	$07,$87,$CF,$FF
			.db	$1F,$1F,$0E,$04
			.db	$04,$06,$0E,$0F
			.db	$0F,$0F,$9F,$FF
			.db	$3F,$1C,$18,$18
			.db	$18,$1C,$1C,$E0
			.db	$E0,$F1,$F3,$F3
			.db	$C3,$03,$02,$06
			.db	$07,$0F,$70,$F0
			.db	$F0,$F9,$F1,$C7
			.db	$01,$00,$03,$8F
			.db	$07,$07,$0F,$DF
			.db	$FF,$3F,$0C,$10
			.db	$70,$F0,$80,$83
			.db	$87,$DF,$BF,$3F
			.db	$20,$C0,$E0,$03
			.db	$18,$78,$F8,$FF
			.db	$FB,$01,$04,$1C
			.db	$38,$F8,$F0,$F1
			.db	$FF,$3F,$3E,$70
			.db	$78,$08,$1C,$7C
			.db	$FC,$FF,$0F,$0E
			.db	$18,$3C,$00,$83
			.db	$CF,$FF,$FF,$C1
			.db	$01,$3F,$80,$03
			.db	$3F,$FF,$FF,$0F
			.db	$1C,$18,$06,$1E
			.db	$FC,$FE,$3F,$7F
			.db	$08,$00,$0F,$7C
			.db	$B0,$7F,$7F,$7C
			.db	$00,$1C,$18,$78
			.db	$78,$FC,$FF,$7C
			.db	$38,$38,$18,$78
			.db	$60,$FC,$FF,$FD
			.db	$38,$F0,$00,$38
			.db	$C0,$FF,$FF,$07
			.db	$0D,$FE,$07,$18
			.db	$00,$FF,$FF,$A3
			.db	$C0,$C0,$03,$80
			.db	$90,$FF,$FF,$1F
			.db	$00,$3C,$0E,$1C
			.db	$00,$FE,$FF,$3F
			.db	$E0,$CB,$01,$08
			.db	$0E,$FE,$7F,$3F
			.db	$60,$FF,$07,$00
			.db	$00,$FC,$FF,$75
			.db	$00,$F0,$1F,$00
			.db	$10,$F0,$FF,$F3
			.db	$01,$80,$7E,$00
			.db	$00,$80,$FF,$FF
			.db	$38,$00,$F0,$1D
			.db	$00,$00,$F0,$FF
			.db	$3F,$02,$80,$F6
			.db	$07,$00,$00,$FF
			.db	$FF,$37,$00,$80
			.db	$FF,$06,$00,$1C
			.db	$FE,$FF,$01,$00
			.db	$F8,$FF,$0F,$00
			.db	$F0,$FE,$7F,$10
			.db	$00,$90,$FF,$3D
			.db	$00,$40,$F8,$FF
			.db	$3F,$30,$00,$FC
			.db	$FF,$00,$00,$A0
			.db	$FF,$FF,$21,$38
			.db	$C0,$5F,$07,$01
			.db	$00,$EE,$FF,$FF
			.db	$01,$00,$60,$FF
			.db	$7F,$03,$00,$FF
			.db	$FF,$7F,$00,$00
			.db	$F0,$FF,$BF,$1E
			.db	$00,$70,$FD,$FF
			.db	$2F,$00,$00,$FF
			.db	$FF,$3F,$00,$80
			.db	$FF,$FF,$FF,$05
			.db	$00,$40,$F4,$7F
			.db	$40,$00,$C0,$FF
			.db	$FF,$FF,$03,$00
			.db	$E1,$FF,$FF,$A0
			.db	$01,$00,$FF,$FF
			.db	$FF,$5F,$00,$80
			.db	$FC,$FF,$2F,$00
			.db	$00,$80,$FF,$FF
			.db	$FF,$1F,$00,$00
			.db	$00,$FE,$6F,$5B
			.db	$01,$00,$FC,$FF
			.db	$FF,$1B,$00,$A0
			.db	$FF,$F6,$3F,$2C
			.db	$50,$00,$00,$FE
			.db	$FF,$FF,$0F,$00
			.db	$F0,$F7,$FA,$0B
			.db	$00,$F8,$61,$00
			.db	$E0,$F5,$FF,$FF
			.db	$03,$00,$40,$B5
			.db	$FE,$07,$50,$5F
			.db	$0B,$00,$40,$65
			.db	$FD,$FF,$3F,$00
			.db	$00,$AB,$FF,$1F
			.db	$00,$00,$D0,$73
			.db	$D5,$F5,$EB,$7B
			.db	$FA,$09,$00,$10
			.db	$F5,$FF,$9F,$0A
			.db	$00,$50,$70,$FF
			.db	$FF,$85,$04,$62
			.db	$D5,$6B,$D5,$83
			.db	$A5,$6F,$FF,$05
			.db	$00,$00,$F0,$FF
			.db	$FF,$0B,$00,$A4
			.db	$D5,$FF,$0F,$50
			.db	$05,$40,$55,$4B
			.db	$FD,$B7,$A9,$FF
			.db	$5F,$7A,$10,$40
			.db	$0B,$A8,$EE,$2B
			.db	$21,$B0,$F8,$FF
			.db	$B6,$FF,$07,$00
			.db	$F8,$91,$FA,$3F
			.db	$00,$00,$C8,$FE
			.db	$FF,$BB,$BF,$02
			.db	$00,$EF,$40,$FF
			.db	$0F,$00,$80,$FF
			.db	$FF,$6F
ut_09_end		.db	$05
ut_0a_beg		.db	$AA
			.db	$FB,$3F,$A0,$00
			.db	$00,$F8,$FF,$7F
			.db	$AF,$00,$E0,$FF
			.db	$17,$34,$00,$C0
			.db	$FF,$5F,$95,$01
			.db	$D2,$FF,$1F,$00
			.db	$00,$FF,$FF,$7F
			.db	$00,$00,$FF,$1F
			.db	$00,$80,$FE,$FF
			.db	$7F,$00,$E0,$FF
			.db	$0B,$00,$D0,$FF
			.db	$FF,$03,$C0,$FF
			.db	$3F,$00,$60,$FF
			.db	$FF,$0F,$80,$D7
			.db	$7F,$00,$60,$98
			.db	$FF,$03,$F8,$DF
			.db	$1F,$00,$0C,$FE
			.db	$3F,$E0,$5F,$FD
			.db	$01,$E0,$E1,$FF
			.db	$00,$3F,$FC,$0F
			.db	$20,$03,$FF,$81
			.db	$07,$FC,$1F,$00
			.db	$C0,$FF,$F9,$0C
			.db	$FF,$FF,$00,$02
			.db	$FE,$F7,$31,$FE
			.db	$FF,$01,$00,$FF
			.db	$F7,$07,$FC,$FF
			.db	$01,$06,$FF,$C3
			.db	$03,$FC,$FC,$83
			.db	$07,$FF,$F1,$83
			.db	$DF,$FF,$80,$81
			.db	$FF,$FF,$E0,$E3
			.db	$FF,$C0,$C1,$FF
			.db	$3F,$70,$F8,$FF
			.db	$E0,$E0,$F3,$7F
			.db	$7E,$7E,$3C,$70
			.db	$F8,$FF,$1F,$0E
			.db	$FE,$1F,$1C,$7C
			.db	$FC,$C7,$CF,$0F
			.db	$0F,$1E,$3E,$3E
			.db	$C0,$C1,$EF,$07
			.db	$07,$9F,$FF,$FB
			.db	$F0,$E0,$C3,$C3
			.db	$87,$CF,$7F,$FC
			.db	$FC,$E0,$E1,$C1
			.db	$C3,$AF,$7F,$7E
			.db	$70,$F0,$E0,$F1
			.db	$83,$FF,$3F,$38
			.db	$78,$F8,$F8,$C1
			.db	$FF,$1F,$38,$3C
			.db	$7C,$FE,$E0,$FD
			.db	$1F,$1C,$1C,$7E
			.db	$7F,$F8,$FC,$1F
			.db	$0C,$0E,$3E,$7F
			.db	$78,$FC,$1F,$0C
			.db	$0E,$3E,$7F,$38
			.db	$FC,$1F,$1C,$0E
			.db	$3F,$7F,$70,$F8
			.db	$1F,$1C,$1C,$BF
			.db	$7F,$70,$F8,$3F
			.db	$18,$78,$FC,$FF
			.db	$E0,$F0,$FF,$00
			.db	$F0,$F0,$F7,$83
			.db	$E1,$E7,$83,$81
			.db	$C3,$E7,$07,$FE
			.db	$FF,$07,$04,$3C
			.db	$7E,$78,$F0,$F8
			.db	$F1,$60,$E0,$E0
			.db	$E1,$9F,$2E,$BF
			.db	$07,$06,$0E,$1E
			.db	$3E,$3C,$78,$F8
			.db	$C0,$C0,$C3,$8F
			.db	$0F,$1E,$3E,$3E
			.db	$00,$F8,$F3,$E3
			.db	$C3,$C3,$C7,$07
			.db	$02,$8F,$0F,$3F
			.db	$70,$F8,$F0,$C1
			.db	$C1,$83,$87,$1F
			.db	$3E,$70,$FC,$E0
			.db	$C0,$C1,$87,$1F
			.db	$0E,$FC,$FC,$40
			.db	$C0,$C3,$8F,$1F
			.db	$7C,$7C,$FC,$80
			.db	$80,$87,$0F,$7F
			.db	$7C,$78,$F8,$01
			.db	$01,$0C,$FC,$FC
			.db	$38,$40,$F0,$27
			.db	$00,$F8,$F8,$FF
			.db	$0B,$D0,$F7,$71
			.db	$C0,$C0,$95,$7E
			.db	$FF,$60,$80,$E3
			.db	$FF,$81,$00,$83
			.db	$FF,$0F,$04,$DE
			.db	$9F,$2F,$00,$C0
			.db	$81,$9F,$7F,$3C
			.db	$70,$F0,$F3,$01
			.db	$80,$C3,$FF,$EF
			.db	$80,$91,$75,$6B
			.db	$01,$38,$3C,$78
			.db	$FC,$F0,$F0,$71
			.db	$C1,$C7,$07,$00
			.db	$0C,$7C,$FE,$5E
			.db	$FA,$F0,$80,$43
			.db	$01,$00,$07,$BF
			.db	$FF,$1F,$0C,$0A
			.db	$F6,$E1,$00,$80
			.db	$87,$8F,$BF,$0F
			.db	$2E,$58,$51,$C1
			.db	$C7,$03,$04,$04
			.db	$FE,$FF,$E0,$C0
			.db	$C3,$87,$07,$0F
			.db	$00,$F0,$E0,$FB
			.db	$DF,$07,$0E,$34
			.db	$F0,$F0,$21,$00
			.db	$8B,$9F,$FF,$E1
			.db	$E0,$E1,$C0,$05
			.db	$F6,$F7,$00,$00
			.db	$A1,$FF,$5F,$45
			.db	$17,$83,$43,$31
			.db	$7C,$48,$00,$07
			.db	$05,$FF,$FF,$8F
			.db	$03,$00,$5E,$3C
			.db	$3C,$0E,$20,$51
			.db	$83,$7F,$3F,$F8
			.db	$E4,$40,$41,$C3
			.db	$DF,$0F,$06,$00
			.db	$80,$CF,$FF,$AF
			.db	$AA,$55,$50,$70
			.db	$60,$F1,$E1,$82
			.db	$00,$08,$8F,$FF
			.db	$FF,$3A,$28,$40
			.db	$A4,$C0,$E9,$AB
			.db	$D6,$07,$00,$4A
			.db	$64,$FE,$7F,$F5
			.db	$0A,$80,$42,$D3
			.db	$2F,$0E,$0E,$0C
			.db	$20,$30,$6B,$FF
			.db	$BF,$87,$2F,$04
			.db	$24,$00,$F5,$E7
			.db	$83,$07,$0F,$02
			.db	$38,$D7,$F7,$AF
			.db	$02,$17,$2A,$2C
			.db	$D0,$E2,$C3,$B7
			.db	$0F,$29,$28,$00
			.db	$A0,$C7,$FF,$FF
			.db	$97,$02,$C0,$C3
			.db	$40,$35,$49,$DD
			.db	$2B,$2A,$0B,$05
			.db	$00,$E6,$FB,$FF
			.db	$3F,$15,$00,$00
			.db	$29,$FA,$BE,$DA
			.db	$BA,$50,$A8,$45
			.db	$13,$00,$30,$EB
			.db	$FF,$DF,$93,$03
			.db	$02,$04,$4D,$FD
			.db	$3F,$96,$02,$88
			.db	$94,$A6,$7D,$00
			.db	$58,$EF,$FF,$DF
			.db	$CA,$05,$10,$08
			.db	$80,$74,$FB,$EE
			.db	$6B,$55,$85,$04
			.db	$A9,$0A,$10,$DE
			.db	$F7,$FF,$A5,$88
			.db	$01,$30,$2E,$8D
			.db	$95,$5C,$BA,$6E
			.db	$F5,$31,$01,$09
			.db	$84,$1E,$00,$EE
			.db	$FB
ut_0a_end		.db	$FF
ut_0b_beg		.db	$AA,$FC
			.db	$FF,$F8,$12,$20
			.db	$DD,$94,$17,$84
			.db	$BF,$41,$52,$3E
			.db	$05,$AE,$80,$FF
			.db	$07,$F0,$FF,$FD
			.db	$00,$F4,$DE,$04
			.db	$49,$F9,$0F,$E8
			.db	$13,$70,$CB,$A9
			.db	$FB,$F6,$00,$FC
			.db	$FF,$1F,$C0,$CD
			.db	$7F,$80,$52,$FF
			.db	$F9,$04,$50,$57
			.db	$F9,$B7,$EA,$1F
			.db	$E0,$FF,$7F,$00
			.db	$81,$FF,$91,$00
			.db	$B6,$EF,$13,$10
			.db	$D8,$D5,$7F,$A4
			.db	$B6,$01,$FF,$FF
			.db	$29,$00,$3C,$FF
			.db	$02,$01,$FE,$FD
			.db	$82,$80,$3A,$FC
			.db	$CD,$52,$1F,$F0
			.db	$E0,$FF,$1F,$30
			.db	$F0,$FB,$09,$04
			.db	$FE,$7F,$03,$81
			.db	$D1,$77,$5F,$52
			.db	$1B,$70,$F0,$F1
			.db	$F3,$41,$10,$1E
			.db	$3C,$3F,$1C,$3E
			.db	$80,$D5,$C3,$E5
			.db	$A5,$89,$6B,$01
			.db	$0F,$1E,$3E,$3E
			.db	$1E,$1C,$0C,$1E
			.db	$15,$FF,$02,$38
			.db	$65,$BF,$50,$D1
			.db	$BA,$B2,$12,$FA
			.db	$02,$EB,$55,$B9
			.db	$55,$21,$09,$3F
			.db	$00,$82,$FE,$47
			.db	$1D,$F2,$AB,$4A
			.db	$A0,$4A,$7D,$2B
			.db	$9A,$0A,$94,$16
			.db	$FE,$27,$30,$B0
			.db	$1F,$2B,$80,$AB
			.db	$BD,$92,$84,$F7
			.db	$ED,$12,$14,$A0
			.db	$55,$55,$7F,$60
			.db	$80,$EB,$7D,$30
			.db	$68,$BF,$3E,$82
			.db	$08,$5B,$AB,$D0
			.db	$22,$B5,$76,$F4
			.db	$87,$07,$10,$F6
			.db	$E3,$83,$46,$7B
			.db	$5D,$81,$A0,$6E
			.db	$9F,$56,$92,$D2
			.db	$AA,$E8,$87,$07
			.db	$02,$87,$DF,$ED
			.db	$E8,$E1,$E0,$61
			.db	$61,$5B,$2A,$2E
			.db	$95,$2C,$AD,$54
			.db	$F5,$F0,$E0,$E0
			.db	$E0,$F9,$F1,$70
			.db	$A1,$52,$40,$FB
			.db	$62,$AD,$64,$AF
			.db	$96,$42,$12,$55
			.db	$45,$7D,$A5,$AA
			.db	$4A,$A5,$5A,$35
			.db	$E0,$5F,$5A,$04
			.db	$5D,$65,$85,$28
			.db	$A5,$56,$2A,$45
			.db	$F5,$75,$FB,$AA
			.db	$50,$00,$EE,$CA
			.db	$4B,$B4,$EA,$9D
			.db	$24,$89,$AA,$32
			.db	$C8,$31,$BE,$C7
			.db	$E3,$30,$0C,$E1
			.db	$A9,$1E,$C7,$E3
			.db	$B6,$26,$10,$4A
			.db	$D7,$EB,$28,$55
			.db	$4D,$B7,$82,$A0
			.db	$7C,$FC,$7F,$28
			.db	$00,$8D,$AE,$AA
ut_0d_beg		.db	$AA,$55,$AF,$55
			.db	$30,$9A,$CE,$EB
			.db	$16,$00,$8E,$FF
			.db	$7F,$2A,$08,$A1
			.db	$28,$25,$D5,$BE
			.db	$5E,$1D,$22,$75
			.db	$CE,$D7,$07,$87
			.db	$E7,$FF,$83,$83
			.db	$E3,$71,$A0,$D0
			.db	$BC,$FF,$38,$16
			.db	$D2,$FB,$3F,$18
			.db	$3E,$3F,$3F,$38
			.db	$3C,$1E,$07,$A3
			.db	$1C,$9F,$CF,$45
			.db	$D4,$FF,$E1,$F0
			.db	$F8,$E1,$C3,$C1
			.db	$E3,$E1,$E0,$C1
			.db	$E1,$E3,$A2,$E9
			.db	$07,$87,$6F,$0F
			.db	$1E,$1E,$1E,$1E
			.db	$16,$2E,$1C,$1B
			.db	$2B,$5E,$C3,$E1
			.db	$9B,$07,$8F,$07
			.db	$1E,$0F,$23,$1C
			.db	$8E,$0A,$A7,$3F
			.db	$1C,$FE,$70,$F0
			.db	$F0,$E0,$E1,$A8
			.db	$61,$E1,$A0,$B8
			.db	$0F,$8E,$7F,$7C
			.db	$78,$78,$F0,$78
			.db	$B8,$E0,$A4,$52
			.db	$E1,$1F,$1E,$7F
			.db	$78,$F0,$E0,$F1
			.db	$E2,$C1,$E1,$10
			.db	$8E,$1B,$70,$FC
			.db	$F1,$E3,$81,$3D
			.db	$3C,$0C,$0C,$2D
			.db	$9C,$C5,$0F,$8F
			.db	$7F,$7C,$38,$E1
			.db	$E1,$E1,$C3,$C2
			.db	$E1,$70,$C0,$F1
			.db	$E7,$CF,$2D,$3C
			.db	$3C,$78,$B0,$50
			.db	$D0,$F2,$81,$8F
			.db	$8F,$0F,$3F,$38
			.db	$BC,$A2,$47,$42
			.db	$0A,$03,$C6,$FF
			.db	$3F,$7E,$18,$50
			.db	$F9,$78,$50,$18
			.db	$78,$83,$C3,$7F
			.db	$BE,$79,$E0,$1C
			.db	$07,$17,$1C,$38
			.db	$04,$38,$FF,$FD
			.db	$CF,$A2,$50,$A8
			.db	$F2,$71,$A0,$82
			.db	$81,$20,$FF,$EF
			.db	$7F,$0E,$C3,$41
			.db	$93,$7C,$38,$40
			.db	$80,$E1,$EF,$FF
			.db	$77,$05,$06,$5A
			.db	$B4,$86,$F0,$30
			.db	$C0,$E1,$F9,$CF
			.db	$7F,$16,$0E,$83
			.db	$36,$4E,$E1,$83
			.db	$00,$01,$E7,$FF
			.db	$FF,$F9,$38,$10
			.db	$54,$54,$87,$7C
			.db	$18,$E0,$70,$B8
			.db	$CF,$CF,$3F,$0F
			.db	$83,$82,$E3,$07
			.db	$01,$06,$8D,$EE
			.db	$60,$FC,$EF,$FF
			.db	$AB,$02,$02,$0F
			.db	$38,$1C,$2E,$7A
			.db	$70,$69,$07,$F1
			.db	$7F,$FF,$5F,$08
			.db	$00,$70,$F1,$F1
			.db	$32,$61,$C1,$D3
			.db	$33,$84,$3F,$EF
			.db	$7D,$D0,$82,$05
			.db	$79,$38,$F5,$F0
			.db	$30,$F8,$B0,$60
			.db	$00,$BE,$FF,$FF
			.db	$86,$03,$83,$52
			.db	$27,$8F,$47,$10
			.db	$08,$71,$7B,$0B
			.db	$D3,$FF,$F3,$FF
			.db	$21,$15,$00,$44
			.db	$14,$97,$5B,$BD
			.db	$A2,$AA,$7A,$07
			.db	$E3,$DF,$EF,$8F
			.db	$20,$00,$54,$7C
			.db	$36,$55,$69,$15
			.db	$1F,$27,$E1,$01
			.db	$00,$C7,$F7,$FF
			.db	$E7,$20,$A0,$7C
			.db	$68,$98,$00,$A7
			.db	$1F,$20,$DF,$FD
			.db	$FF,$F5,$20,$00
			.db	$1C,$54,$6A,$F4
			.db	$72,$DB,$0B,$A0
			.db	$AF,$F8,$FF,$E0
			.db	$81,$40,$2F,$88
			.db	$55,$F4,$E3,$63
			.db	$17,$02,$00,$DF
			.db	$FF,$FF,$A4,$01
			.db	$1C,$1E,$D0,$A0
			.db	$70,$5B,$77,$57
			.db	$2B,$E5,$81,$C3
			.db	$63,$FE,$8F,$F2
			.db	$20,$98,$02,$AE
			.db	$1E,$F6,$F3,$A0
ut_0d_end		.db	$14,$C0,$75,$BD
			.db	$13,$88,$DF,$F7
			.db	$7F,$03,$21,$00
			.db	$B0,$12,$DF,$AF
			.db	$7A,$BA,$D0,$C1
			.db	$3F,$0E,$8A,$40
			.db	$01,$CE,$DF,$FF
			.db	$7E,$B0,$C0,$00
			.db	$1F,$1C,$ED,$A0
			.db	$5A,$87,$D7,$56
			.db	$AE,$6A,$4A,$0E
			.db	$FF,$0D,$00,$8E
			.db	$F1,$7F,$36,$4B
			.db	$80,$2A,$4D,$EF
			.db	$54,$F8,$53,$90
			.db	$08,$D0,$56,$FF
			.db	$ED,$E8,$AA,$D5
			.db	$01,$C0,$F3,$FC
			.db	$1F,$18,$01,$50
			.db	$0F,$AD,$DB,$72
			.db	$5F,$D5,$82,$14
			.db	$16,$F5,$F6,$33
			.db	$18,$02,$D1,$B5
			.db	$BE,$80,$F2,$BF
			.db	$FF,$03,$45,$08
			.db	$52,$95,$4A,$3F
			.db	$0E,$CF,$60,$75
			.db	$8D,$D7,$A9,$75
			.db	$89,$D2,$80,$95
			.db	$27,$7B,$57,$21
			.db	$40,$FD,$6F,$9E
			.db	$02,$48,$2E,$D5
			.db	$A7,$A5,$7A,$A8
			.db	$52,$D1,$A5,$0B
			.db	$1F,$E2,$74,$55
			.db	$9F,$7A,$18,$18
			.db	$45,$D1,$EB,$AD
			.db	$17,$F0,$F5,$EA
			.db	$2B,$08,$45,$A2
			.db	$58,$A9,$56,$BB
			.db	$BC,$04,$F7,$BB
			.db	$58,$03,$62,$69
			.db	$D5,$AF,$AA,$54
			.db	$A4,$AA,$03,$5F
			.db	$D7,$7A,$13,$11
			.db	$40,$B6
ut_0b_end		.db	$AF
ut_0c_beg	
ut_17_beg		.db	$AA
			.db	$C7,$F3,$F0,$38
			.db	$8E,$D2,$92,$C7
			.db	$A3,$3C,$8E,$C6
			.db	$F1,$B8,$2C,$4D
			.db	$AB,$D5,$28,$54
			.db	$A9,$D5,$67,$59
			.db	$28,$8E,$C7,$E3
			.db	$F0,$38,$1C,$8F
			.db	$E3,$68,$3C,$1C
			.db	$4B,$35,$8F,$87
			.db	$E3,$38,$1E,$35
			.db	$AC,$E1,$F4,$34
			.db	$8E,$C3,$C3,$F1
			.db	$38,$1E,$C7,$E1
			.db	$78,$1C,$C5,$E3
			.db	$71,$38,$9E,$E3
			.db	$70,$28,$D1,$E5
			.db	$B3,$96,$16,$E3
			.db	$F1,$38,$1C,$A6
			.db	$E3,$79,$9C,$87
			.db	$E3,$70,$2C,$87
			.db	$63,$31,$8D,$87
			.db	$A2,$C0,$F0,$FF
			.db	$CF,$C1,$A0,$F2
			.db	$55,$41,$A5,$D1
			.db	$A8,$92,$E4,$E9
ut_17_end
ut_12_beg		.db	$AA,$DE,$E3,$68
			.db	$80,$E3,$FF,$0F
			.db	$07,$47,$55,$08
			.db	$14,$97,$A4,$72
			.db	$39,$2C,$0D,$8F
			.db	$4F,$AF,$FD,$7F
			.db	$80,$E1,$FF,$07
			.db	$0F,$3E,$1C,$30
			.db	$7C,$20,$F0,$7A
			.db	$51,$B1,$AB,$0A
			.db	$49,$76,$7D,$7C
			.db	$1C,$3C,$FE,$F1
			.db	$F0,$E1,$83,$83
			.db	$87,$07,$82,$47
			.db	$8B,$C2,$E7,$85
			.db	$14,$8F,$CF,$F7
			.db	$83,$E3,$0F,$1E
			.db	$7E,$F8,$70,$F0
			.db	$F0,$E0,$F0,$68
			.db	$D1,$E2,$D5,$8A
			.db	$AA,$F9,$3D,$3C
			.db	$FE,$E0,$F1,$C3
			.db	$87,$87,$87,$01
			.db	$87,$C7,$43,$87
			.db	$0F,$97,$DF,$83
			.db	$C3,$0F,$1E,$1E
			.db	$7C,$70,$F8,$70
			.db	$E0,$F0,$78,$70
			.db	$71,$EA,$FD,$E0
			.db	$E0,$87,$87,$0F
			.db	$1F,$1E,$0E,$0E
			.db	$3C,$3C,$1E,$3E
			.db	$BE,$C1,$C1,$0F
			.db	$0F,$6F,$3E,$38
			.db	$3C,$3C,$38,$38
			.db	$F8,$E3,$08,$1E
			.db	$FE,$F0,$F0,$F5
			.db	$C3,$C3,$C3,$83
			.db	$83,$87,$0F,$07
			.db	$0F,$7F,$7C,$F8
			.db	$F1,$F1,$F0,$E0
			.db	$C3,$C3,$C3,$07
			.db	$78,$FE,$F3,$E3
			.db	$E7,$07,$8F,$0F
			.db	$0F,$1F,$AF,$00
			.db	$8E,$9F,$79,$F8
			.db	$FC,$E0,$E1,$E3
			.db	$C3,$C3,$07,$3C
			.db	$FE,$F3,$F1,$EB
			.db	$87,$C7,$C7,$F7
			.db	$38,$00,$8E,$FF
			.db	$FC,$FC,$E7,$E1
			.db	$F7,$8F,$C7,$05
			.db	$E0,$F8,$C7,$87
			.db	$1F,$0F,$3E,$7C
			.db	$7C,$68,$C0,$E1
			.db	$9F,$1F,$7F,$3D
			.db	$9C,$FF,$7C,$D0
			.db	$83,$87,$3F,$1E
			.db	$FE,$7C,$78,$FC
			.db	$FB,$71,$00,$83
			.db	$3F,$3E,$DF,$13
			.db	$38,$3C,$EF,$71
			.db	$00,$C2,$3F,$7E
			.db	$FC,$31,$E8,$FD
			.db	$7C,$40,$80,$C3
			.db	$9F,$9F,$FF,$5B
			.db	$1E,$EF,$5F,$05
			.db	$00,$0E,$7F,$F8
			.db	$F8,$E3,$C1,$F5
			.db	$C7,$07,$01,$0C
			.db	$FF,$F8,$E0,$87
			.db	$43,$8D,$3F,$1F
			.db	$00,$38,$FC,$F1
			.db	$3F,$1E,$0C,$F1
			.db	$F8,$F8,$03,$80
			.db	$C3,$1F,$9F,$FF
			.db	$38,$C0,$C1,$C7
			.db	$07,$03,$40,$FA
			.db	$E3,$CF,$3F,$0E
			.db	$F0,$F0,$C0,$87
			.db	$03,$10,$FE,$E7
			.db	$DF,$3B,$14,$F8
			.db	$A1,$0E,$3F,$0A
			.db	$C0,$F8,$FF,$CF
			.db	$72,$3A,$07,$97
			.db	$3F,$58,$5E,$01
			.db	$80,$CF,$4F,$3F
			.db	$7C,$FC,$E0,$70
			.db	$0C,$E9,$FF,$07
			.db	$00,$A0,$1F,$FF
			.db	$F8,$79,$08,$6A
			.db	$F5,$07,$AB,$0E
			.db	$00,$40,$F3,$FF
			.db	$7F,$FC,$E9,$87
			.db	$11,$3C,$8C,$F1
			.db	$75,$1C,$00,$40
			.db	$FB,$FE,$7F,$F5
			.db	$E1,$40,$03,$83
			.db	$42,$AF,$BF,$1F
			.db	$00,$80,$F0,$FF
			.db	$9F,$BF,$14,$0C
			.db	$28,$3D,$30,$F1
			.db	$C3,$38,$1C,$00
			.db	$C0,$EC,$FF,$FF
			.db	$8F,$05,$14,$00
			.db	$E0,$F8,$B5,$C3
			.db	$A7,$0E,$1E,$00
			.db	$80,$E7,$FF,$FC
			.db	$DF,$C0,$80,$00
			.db	$86,$7F,$BC,$C4
			.db	$43,$45,$31,$00
			.db	$00,$FB,$FD,$FF
			.db	$FF,$43,$00,$08
			.db	$88,$A2,$E9,$BE
			.db	$DE,$78,$50,$44
			.db	$FD,$00,$00,$9C
			.db	$FE,$FF,$EB,$43
			.db	$81,$28,$00,$81
			.db	$F7,$B7,$2C,$1E
ut_12_end		.db	$AA,$A0,$A2,$AC
			.db	$A4,$02,$80,$F7
			.db	$FF,$FF,$8F,$01
			.db	$00,$28,$88,$05
			.db	$9F,$BD,$FA,$6C
			.db	$13,$45,$D8,$5B
			.db	$45,$42,$20,$00
			.db	$B0,$BF,$FF,$7F
			.db	$1B,$05,$08,$40
			.db	$B8,$AF,$C5,$21
			.db	$15,$1D,$D5,$7A
			.db	$34,$4B,$F0,$B0
			.db	$42,$03,$20,$FD
			.db	$FF,$FF,$04,$84
			.db	$04,$4A,$34,$58
			.db	$EB,$E3,$89,$4E
			.db	$8F,$5C,$59,$FA
			.db	$2B,$0A,$02,$68
			.db	$30,$A9,$02,$F3
			.db	$FF,$FF,$6B,$51
			.db	$04,$0C,$82,$B0
			.db	$BA,$8A,$45,$40
			.db	$5A,$85,$FF,$BB
			.db	$BA,$2A,$53,$21
ut_0c_end		.db	$48
ut_0e_beg		.db	$AA,$AA,$AA
			.db	$AA,$AA,$AA,$AA
			.db	$AA,$AA,$AA,$AA
			.db	$AA,$AA,$AA,$AA
			.db	$AA,$AA,$AA,$AA
			.db	$AA,$AA,$AA,$AA
			.db	$AA,$AA,$AA,$AA
			.db	$AA,$AA,$AA,$AA
			.db	$AA,$AA,$AA,$AA
			.db	$AA,$AA,$AA,$AA
			.db	$AA,$AA,$AA,$AA
			.db	$AA,$AA,$AA,$AA
			.db	$AA,$AA,$AA,$AA
			.db	$AA,$AA,$AA,$AA
			.db	$AA,$AA,$AA,$AA
			.db	$AA,$AA,$AA,$AA
			.db	$AA,$AA,$AA,$AA
			.db	$AA,$AA,$AA,$AA
			.db	$AA,$AA,$AA,$AA
			.db	$AA,$AA,$AA,$AA
			.db	$AA,$AA,$AA,$AA
			.db	$AA,$AA,$AA,$AA
			.db	$AA,$AA,$AA,$AA
			.db	$AA,$AA,$AA,$AA
			.db	$AA,$AA,$AA,$AA
			.db	$AA,$AA,$AA,$AA
			.db	$AA,$AA,$AA,$AA
			.db	$AA,$AA,$AA,$AA
			.db	$AA,$AA,$AA,$AA
			.db	$AA,$AA,$AA,$AA
			.db	$AA,$AA,$AA,$AA
			.db	$AA,$AA,$AA,$AA
			.db	$AA,$AA,$AA,$AA
			.db	$AA,$AA,$AA,$AA
			.db	$AA,$AA,$AA,$AA
			.db	$AA,$AA,$AA,$AA
			.db	$AA,$AA,$AA,$AA
			.db	$AA,$AA,$AA,$AA
			.db	$AA,$AA,$AA,$AA
			.db	$AA,$AA,$AA,$AA
			.db	$AA,$AA,$AA,$AA
			.db	$AA,$AA,$AA,$AA
			.db	$AA,$AA,$AA,$AA
			.db	$AA,$AA,$AA,$AA
			.db	$AA,$AA,$AA,$AA
			.db	$AA,$AA,$AA,$AA
			.db	$AA,$AA,$AA,$AA
			.db	$AA,$AA,$DB,$5A
			.db	$AB,$2A,$89,$52
			.db	$A9,$AA,$AA,$D6
			.db	$D6,$AA,$0A,$49
			.db	$FF,$FF,$77,$19
			.db	$0A,$00,$41,$54
			.db	$AD,$F5,$DD,$B6
			.db	$AB,$6A,$55,$55
			.db	$45,$2A,$25,$55
			.db	$55,$55,$48,$FE
			.db	$FF,$FF,$73,$11
			.db	$00,$08,$A0,$AA
			.db	$EA,$ED,$BA,$AD
			.db	$AA,$AB,$6A,$AD
			.db	$AA,$12,$15,$49
			.db	$29,$92,$CA,$FF
			.db	$FF,$FF,$0E,$03
			.db	$00,$20,$A8,$AA
			.db	$ED,$5E,$D7,$55
			.db	$B5,$2A,$AD,$A4
			.db	$4A,$45,$55,$54
			.db	$4A,$FC
ut_0e_end		.db	$AA

ut_11_beg
ut_13_beg
ut_18_beg		.db	$AA
			.db	$95,$48
ut_18_end		.db	$D5,$DF
			.db	$DD,$6D,$AB,$0A
			.db	$84,$10,$22,$49
			.db	$A9,$D6,$DD,$7B
			.db	$BB,$B5,$2A,$11
			.db	$92,$24,$55,$B5
			.db	$D6,$2A,$55,$FD
			.db	$DE,$BD,$6D,$55
			.db	$09,$44,$10,$22
			.db	$52,$AA,$B6,$77
			.db	$DF,$DD,$5A,$95
			.db	$42,$24,$92,$52
			.db	$55,$B5,$56,$D5
			.db	$7B,$DF,$5D,$5B
			.db	$55,$82,$08,$22
			.db	$12,$29,$55,$DD
			.db	$BE,$77,$B7,$56
			.db	$09,$11,$91,$54
			.db	$AA,$D5,$5A,$55
			.db	$DD,$FB,$76,$6B
			.db	$55,$21,$82,$10
			.db	$91,$94,$AA,$DA
			.db	$DD,$77,$77,$5B
			.db	$55,$08,$11,$49
			.db	$A9,$AA,$AA,$F6
			.db	$7D,$DF,$BD,$56
			.db	$55,$20,$04,$11
			.db	$92,$4A,$B5,$ED
			.db	$F7,$DE,$D6,$2A
			.db	$11,$11,$49,$49
			.db	$A4,$48,$FD,$FE
			.db	$7E,$F7,$56,$55
			.db	$20,$08,$44,$54
			.db	$6A,$F5,$F5,$95
			.db	$5F,$FD,$11,$10
			.db	$20,$F0,$F8,$FF
			.db	$3F,$00,$82,$E0
			.db	$F9,$FD,$98,$90
			.db	$E2,$1D,$1C,$1C
			.db	$BF,$FF,$3F,$1C
			.db	$0C,$00,$85,$0F
			.db	$0F,$86,$C3,$C1
			.db	$F1,$FF,$E7,$E3
			.db	$01,$00,$E8,$F9
			.db	$F9,$38,$60,$E0
			.db	$F8,$FF,$FB,$79
			.db	$00,$00,$30,$7F
			.db	$3F,$30,$18,$3E
			.db	$FF,$7F,$1F,$0C
			.db	$00,$80,$EF,$30
			.db	$10,$62,$FC,$FF
			.db	$7F,$0E,$80,$C4
			.db	$0B,$07,$43,$CE
			.db	$FF,$FF,$C1,$00
			.db	$B8,$3D,$1C,$00
			.db	$18,$FF,$FF,$8F
			.db	$03,$60,$18,$0C
			.db	$84,$DC,$FF,$FF
			.db	$97,$61,$78,$87
			.db	$01,$90,$F9,$FF
			.db	$FF,$33,$84,$07
			.db	$0C,$84,$8D,$FF
			.db	$FF,$3B,$31,$3C
			.db	$30,$10,$32,$FF
			.db	$FF,$E7,$C1,$60
			.db	$30,$20,$34,$FE
			.db	$FF,$FF,$C1,$39
			.db	$30,$00,$78,$FE
			.db	$FF,$7F,$F1,$38
			.db	$18
ut_13_end		.db	$08,$0C,$FF
			.db	$FF,$7F,$6F,$0F
			.db	$06,$80,$80,$EF
			.db	$FF,$FF,$FF,$83
			.db	$01,$60,$F8,$FF
			.db	$FF,$47,$C0,$60
			.db	$20,$38,$FE,$FF
			.db	$FF,$F9,$79,$18
			.db	$00,$00,$F1,$FF
			.db	$7F,$3E,$0E,$04
			.db	$C0,$E0,$F1,$F9
			.db	$3E,$9F,$0F,$03
			.db	$40,$70,$FE,$FF
			.db	$0F,$87,$03,$03
			.db	$40,$60,$FC,$FE
			.db	$DF,$C3,$10,$00
			.db	$00,$C1,$F3,$FF
			.db	$7F,$0F,$03,$40
			.db	$00,$0C,$9E,$DF
			.db	$FF,$F3,$19,$04
			.db	$00,$00,$C3,$F3
			.db	$FF,$7E,$1E,$07
			.db	$81,$20,$10,$02
			.db	$E7,$FB,$FB,$3D
			.db	$0C,$06,$03,$07
			.db	$E1,$F0,$FC,$BE
			.db	$0E,$C5,$58,$1C
			.db	$C5,$31,$19,$23
			.db	$60,$F4,$FE,$EF
			.db	$E0,$78,$38,$1C
			.db	$42,$00,$24,$47
			.db	$7F,$FF,$7F,$0F
			.db	$02,$80,$B0,$B9
			.db	$9F,$1F,$03,$03
			.db	$42,$E6,$FF,$CF
			.db	$E7,$E1,$20,$10
			.db	$0C,$C7,$C3,$F1
			.db	$F9,$B9,$1B,$02
			.db	$82,$E1,$7C,$FC
			.db	$DE,$8F,$81,$81
			.db	$21,$78,$1C,$3F
			.db	$BF,$CF,$61,$20
			.db	$30,$3C,$0E,$5F
			.db	$EF,$E7,$E3,$40
			.db	$20,$8C,$CD,$F9
			.db	$7C,$1E,$0D,$81
			.db	$61,$70,$5E,$EF
			.db	$C7,$E7,$38,$18
			.db	$0C,$0C,$C3,$79
			.db	$FD,$F9,$3D,$06
			.db	$43,$C0,$E0,$38
			.db	$5F,$DF,$F3,$71
			.db	$34,$04,$81,$C1
			.db	$F1,$7A,$1E,$2F
			.db	$4F,$87,$43,$30
			.db	$AC,$9E,$A7,$D5
			.db	$1C,$8D,$B1,$39
			.db	$E7,$63,$60,$50
			.db	$C6,$C3,$E9,$F8
			.db	$78,$77,$73,$2A
			.db	$24,$10,$08,$5D
			.db	$7D,$BF,$57,$A5
			.db	$10,$0C,$1D,$9F
			.db	$9F,$27,$45,$44
			.db	$0C,$87,$C7,$FB
			.db	$BA,$9C,$86,$87
			.db	$C3,$C0,$98,$B9
			.db	$9F,$A7,$C3,$60
			.db	$70,$0C,$4F,$CF
			.db	$C7,$D3,$58,$34
			.db	$38,$14,$CE,$F3
			.db	$EA,$B9,$38,$1C
			.db	$2A,$0A,$C3,$D5
			.db	$E7,$75,$9A,$8A
			.db	$61,$68,$5C,$9E
			.db	$97,$73,$31,$52
			.db	$14,$46,$E3,$EA
			.db	$7C,$BD,$1C,$87
			.db	$91,$88,$51,$39
			.db	$5F,$B7,$E7,$E2
			.db	$50,$28,$8A,$A3
			.db	$79,$75,$9F,$C7
			.db	$85,$A1,$68,$1C
			.db	$35,$2E,$97,$67
			.db	$55,$29,$4A,$96
			.db	$D5,$B4,$8E,$93
			.db	$19,$43,$D3,$7B
			.db	$55,$25,$87,$C3
			.db	$A9,$12,$A3,$6A
			.db	$75,$7D,$75,$B5
			.db	$44,$11,$18,$9C
			.db	$73,$BE,$C5,$18
			.db	$31,$A5,$9A,$77
			.db	$63,$37,$16,$97
			.db	$42,$8C,$63,$73
			.db	$CC,$CD,$D3,$19
			.db	$8C,$C9,$B1,$B6
			.db	$AB,$66,$C3,$18
			.db	$33,$A3,$A5,$9D
			.db	$E3,$DC,$38,$87
			.db	$8C,$31,$C7,$CC
			.db	$39,$73,$2E,$33
			.db	$66,$8C,$71,$E6
			.db	$1C,$73,$C6,$18
			.db	$73,$8C,$31,$E6
			.db	$9C,$73,$CE,$19
			.db	$63,$9C,$31,$C6
			.db	$38,$67,$8C,$71
			.db	$E3,$18,$63,$C6
			.db	$71,$6E,$9C,$93
			.db	$63,$31,$46,$8D
			.db	$E3,$38,$1F,$27
			.db	$E3,$C6,$31,$33
			.db	$1E,$55,$E6,$5C
			.db	$63,$E2,$8C,$C7
			.db	$C5,$71,$1C,$1D
			.db	$E3,$78,$1C,$A7
			.db	$69,$71,$CC,$19
ut_10_beg		.db	$AA,$C5,$1C
ut_11_end		.db	$AA
			.db	$22,$1F,$FD,$56
			.db	$C0,$02,$FF,$07
			.db	$58,$93,$FE,$22
			.db	$BA,$E8,$45,$13
			.db	$7F,$50,$F8,$81
			.db	$FE,$05,$B8,$81
			.db	$BF,$25,$5E,$C0
			.db	$B7,$EA,$07,$C0
			.db	$8F,$FE,$01,$F0
			.db	$57,$A5,$56,$91
			.db	$C2,$7F,$03,$F0
			.db	$F5,$07,$D0,$7A
			.db	$57,$02,$3F,$F0
			.db	$0F,$2A,$44,$FF
			.db	$07,$5C,$D0,$BF
			.db	$90,$64,$5F,$80
			.db	$FE,$0F,$C0,$D7
			.db	$1D,$52,$74,$57
			.db	$C0,$FE,$40,$FC
			.db	$D1,$E0,$D3,$1A
			.db	$60,$FF,$04,$1C
			.db	$F8,$1F,$E0,$03
			.db	$FE,$03,$1E,$F0
			.db	$1F,$E0,$F2,$43
			.db	$97,$C0,$2F,$FE
			.db	$01,$AC,$5F,$0B
			.db	$D8,$2F,$C0,$3F
			.db	$B4,$01,$7E,$FC
			.db	$03,$3C,$F0,$0F
			.db	$6A,$C1,$1F,$F8
			.db	$07,$F0,$E5,$1F
			.db	$00,$FE,$81,$1F
			.db	$FC,$00,$7E,$5E
			.db	$02,$FC,$3F,$80
			.db	$C1,$FF,$00,$87
			.db	$FF,$00,$E9,$FF
			.db	$03,$E0,$0F,$F8
			.db	$F9,$01,$F0,$FF
			.db	$01,$80,$FF,$81
			.db	$80,$FF,$00,$C7
			.db	$7F,$00,$F5,$3F
			.db	$80,$E8,$8F,$26
			.db	$EA,$83,$1F,$7C
			.db	$C0,$0F,$7E,$F0
			.db	$80,$7F,$34,$C0
			.db	$0F,$7F,$C0,$87
			.db	$1F,$F8,$E0,$0F
			.db	$0E,$F0,$07,$3C
			.db	$F0,$87,$0F,$3E
			.db	$5C,$70,$FE,$01
			.db	$FC,$FE,$00,$0F
			.db	$7F,$70,$C0,$FF
			.db	$01,$FC,$F8,$0B
			.db	$18,$FE,$03,$1E
			.db	$FF,$80,$07,$7F
			.db	$C0,$E1,$1F,$40
			.db	$FC,$07,$E8,$7F
			.db	$20,$C0,$3F,$01
			.db	$FC,$EB,$01,$F0
			.db	$0F,$E0,$7F,$00
			.db	$3E,$FE,$80,$E3
			.db	$0F,$E0,$3F,$70
			.db	$F8,$03,$3F,$2A
			.db	$F8,$07,$F0,$47
			.db	$0F,$1F,$7C,$C0
			.db	$F3,$0D,$B0,$3F
			.db	$80,$FF,$00,$FF
			.db	$03,$F8,$73,$80
			.db	$0F,$3F,$00,$FE
			.db	$07,$FC,$07,$FC
			.db	$11,$FA,$C0,$3F
			.db	$00,$3F,$1E,$FC
			.db	$03,$C7,$07,$3F
			.db	$80,$FE,$F0,$F0
			.db	$01,$FF,$00,$F8
			.db	$1F,$F0,$07,$F0
			.db	$1F,$FC,$01,$F8
			.db	$03,$F0,$73,$88
			.db	$FE,$80,$BF,$00
			.db	$9F,$03,$7F,$81
			.db	$FE,$03,$FE,$03
			.db	$FC,$03,$FE,$03
			.db	$FC,$01,$FE,$01
			.db	$FE,$03,$FE,$03
			.db	$FC,$03,$FE,$03
			.db	$FC,$01,$FE,$07
			.db	$FC,$07,$FC,$07
			.db	$F8,$07,$F8,$07
			.db	$F0,$0F,$EC,$0F
			.db	$F0,$0F,$E0,$1F
			.db	$E0,$0F,$F0,$0F
			.db	$E0,$1F,$E0,$1F
			.db	$E0,$0F,$E0,$1F
			.db	$E0,$3F,$C0,$1F
			.db	$E0,$3F,$E0,$3F
			.db	$C0,$7F,$00,$7F
			.db	$00,$FF,$80,$F9
			.db	$00,$FE,$06,$F8
			.db	$0F,$F8,$09,$FC
			.db	$03,$FC,$03,$F8
			.db	$1F,$F0,$09,$FC
			.db	$21,$F0,$67,$E0
			.db	$3F,$C0,$1D,$F8
			.db	$71,$E0,$21,$E1
			.db	$E7,$85,$CF,$61
			.db	$F0,$83,$F3,$07
			.db	$FA,$03,$F8,$65
			.db	$E0,$07,$F0,$07
			.db	$F8,$0F,$F0,$E7
			.db	$60,$3F,$60,$7B
			.db	$F0,$F8,$E0,$0F
			.db	$E0,$EF,$E0,$F0
			.db	$E1,$E0,$E1,$E1
			.db	$C1,$C7,$83,$F8
			.db	$83,$FC,$07,$E8
			.db	$67,$E0,$87,$83
			.db	$0F,$3E,$1E,$A0
			.db	$FF,$C0,$77,$00
			.db	$3F,$10,$7F,$00
			.db	$FE,$03,$FE,$04
			.db	$FE,$00,$FF,$00
			.db	$FC,$03,$FC,$03
			.db	$F8,$03,$FC,$03
			.db	$FC,$03,$F8,$07
			.db	$F0,$0F,$F0,$07
			.db	$F0,$0F,$C0,$1F
			.db	$E0,$1F,$E0,$3F
			.db	$C0,$7F,$80,$3F
			.db	$C0,$3F,$80,$7F
			.db	$80,$FF,$00,$7F
			.db	$02,$FF,$00,$FF
			.db	$00,$FE,$80,$FF
			.db	$00,$FC,$01,$F8
			.db	$07,$F8,$03,$F8
			.db	$03,$F8,$03,$F0
			.db	$0F,$F0,$0F,$F0
			.db	$0F,$F0,$07,$E0
			.db	$7F,$C0,$1F,$C0
			.db	$3F,$C0,$67,$80
			.db	$7F,$80,$FF,$00
			.db	$FE,$08,$FE,$01
			.db	$1F,$00,$FF,$03
			.db	$F8,$07,$F0,$0F
			.db	$E8,$03,$DC,$0F
			.db	$F8,$07,$F0,$0F
			.db	$E0,$3F,$E0,$1F
			.db	$80,$3F,$E0,$3F
			.db	$E0,$3F,$E0,$7F
			.db	$C0,$7F,$80,$7F
			.db	$00,$FF,$60,$7F
			.db	$E0,$DE,$C0,$1F
			.db	$80,$BF,$01,$FF
			.db	$01,$FE,$03,$F0
			.db	$C3,$C1,$87,$87
			.db	$07,$BF,$07,$F8
			.db	$07,$E0,$0F,$C0
			.db	$1F,$80,$FF,$00
			.db	$7C,$1E,$52,$87
			.db	$1F,$80,$FF,$00
			.db	$FE,$01,$FC,$03
			.db	$F0,$3F,$C0,$3F
			.db	$F8,$01,$FC,$03
			.db	$FC,$01,$F8,$0F
			.db	$F8,$0F,$F8,$07
			.db	$F8,$03,$F8,$0F
			.db	$F0,$0F,$E0,$1F
			.db	$E0,$07,$F8,$1F
			.db	$F0,$0F,$E0,$3F
			.db	$C0,$3F,$C0,$1F
			.db	$E0,$3F,$C0,$1F
			.db	$A0,$7F,$C0,$3F
			.db	$80,$7F,$80,$FF
			.db	$00,$FF,$00,$FE
			.db	$81,$FF,$00,$FE
			.db	$C0,$FF,$03,$FC
			.db	$81,$3F,$03,$FC
			.db	$01,$FF,$03,$FE
			.db	$03,$F6,$89,$07
			.db	$C3,$EF,$03,$DF
			.db	$07,$F4,$07,$07
			.db	$3F,$0E,$FC,$0F
			.db	$1C,$3F,$B0,$E7
			.db	$09,$BC,$F0,$07
			.db	$F8,$0F,$F0,$3F
			.db	$80,$7F,$01,$FE
			.db	$81,$8F,$C7,$17
			.db	$C0,$1F,$80,$FF
			.db	$01,$FF,$03,$F8
			.db	$0F,$C6,$1F,$1E
			.db	$00,$FF,$03,$FC
			.db	$03,$F8,$0F,$FC
			.db	$1F,$D8,$1F,$7C
			.db	$5C,$F8,$07,$F8
			.db	$1F,$F0,$1F,$80
			.db	$7F,$B0,$F8,$E0
			.db	$07,$F0,$3F,$80
			.db	$3F,$80,$FF,$00
			.db	$FF,$00,$FE,$01
			.db	$FA,$21,$BC,$41
			.db	$EF,$04,$FE,$01
			.db	$E3,$1F,$F8,$EF
			.db	$81,$1F,$FC,$61
			.db	$F9,$07,$F8,$0F
			.db	$31,$3E,$E2,$E1
			.db	$8F,$3F,$C0,$CF
			.db	$03,$FC,$87,$C3
			.db	$79,$8E,$00,$FE
			.db	$01,$F8,$1F,$80
			.db	$FF,$03,$C7,$FC
			.db	$40,$E0,$1F,$98
			.db	$E1,$0F,$0E,$FC
			.db	$02,$C1,$7F,$00
			.db	$7E,$3E,$20,$FF
			.db	$01,$DC,$7F,$00
			.db	$F8,$47,$E0,$7F
			.db	$0E,$FE,$7C,$D0
			.db	$E3,$03,$1E,$1E
			.db	$7C,$3C,$FC,$01
			.db	$FC,$07,$E0,$17
			.db	$F8,$78,$F0,$03
			.db	$F8,$07,$C0,$7F
			.db	$18,$F0,$E3,$07
			.db	$0F,$7F,$00,$FF
			.db	$E0,$F0,$07,$1F
			.db	$3C,$FE,$81,$8D
			.db	$37,$70,$07,$FF
			.db	$00,$FC,$83,$E0
			.db	$1F,$C0,$0F,$CF
			.db	$71,$F0,$07,$C0
			.db	$7F,$00,$9F,$07
			.db	$F8,$C1,$3B,$60
			.db	$FC,$00,$7E,$1E
			.db	$E0,$83,$7F,$C0
			.db	$FF,$03,$F8,$E7
			.db	$80,$3F,$F0,$07
			.db	$CE,$1F,$E0,$0F
			.db	$00,$7E,$E0,$0F
			.db	$0C,$3F,$00,$1F
			.db	$F1,$E1,$01,$FF
			.db	$38,$38,$38,$F8
			.db	$01,$3F,$06,$E2
			.db	$CF,$E0,$E1,$79
			.db	$18,$FC,$01,$9F
			.db	$63,$E0,$67,$38
			.db	$F8,$21,$87,$DF
			.db	$60,$F0,$EE,$0C
			.db	$E0,$1F,$01,$FF
			.db	$C0,$F1,$3C,$73
			.db	$80,$7F,$08,$F3
			.db	$03,$C7,$74,$CE
			.db	$00,$FF,$31,$E0
			.db	$7F,$00,$F3,$17
			.db	$F0,$F9,$03,$3C
			.db	$7E,$03,$F3,$D5
			.db	$C0,$0F,$3F,$F8
			.db	$E0,$0F,$20,$FF
			.db	$03,$39,$7E,$D0
			.db	$87,$78,$38,$E1
			.db	$0F,$86,$1D,$77
			.db	$F0,$E8,$1F,$10
			.db	$FE,$20,$FE,$F0
			.db	$E0,$11,$3E,$0C
			.db	$AF,$0F,$8E,$F1
			.db	$03,$C7,$FC,$19
			.db	$38,$7E,$03,$9E
			.db	$0F,$30,$FB,$61
			.db	$C0,$7F,$30,$F8
			.db	$97,$08,$F0,$67
			.db	$08,$FE,$1C,$07
			.db	$78,$DF,$01,$FE
			.db	$03,$F0,$3F,$10
			.db	$FE,$01,$F6,$1F
			.db	$84,$AF,$83,$D9
			.db	$F1,$43,$F0,$79
			.db	$38,$3C,$F0,$07
			.db	$84,$BF,$01,$FE
			.db	$27,$E0,$8D,$1F
			.db	$F0,$E1,$0F,$FC
			.db	$C0,$83,$5F,$F0
			.db	$38,$7C,$1E,$18
			.db	$1F,$0F,$9C,$5F
			.db	$00,$FE,$03,$E0
			.db	$7F,$00,$FF,$C8
			.db	$01,$3F,$07,$E0
			.db	$1F,$1C,$F8,$43
			.db	$98,$FE,$01,$86
			.db	$FF,$80,$80,$FF
			.db	$00,$F1,$0F,$60
			.db	$FE,$3C,$90,$FF
			.db	$03,$E0,$7F,$00
			.db	$FE,$11,$C0,$7F
			.db	$18,$F8,$3E,$00
			.db	$FE,$0F,$E0,$1F
			.db	$01,$3F,$F8,$01
			.db	$F6,$3F,$00,$FF
			.db	$07,$E0,$BF,$03
			.db	$F0,$FF,$00,$F8
			.db	$3F,$40,$FF,$81
			.db	$19,$FC,$3F,$00
			.db	$FF,$01,$E4,$1F
			.db	$07,$F3,$BF,$00
			.db	$F8,$1F,$E0,$7C
			.db	$07,$78,$F0,$FF
			.db	$00,$F8,$07,$60
			.db	$7F,$60,$16,$B8
			.db	$1F,$00,$FE,$78
			.db	$18,$F8,$0F,$00
			.db	$FF,$03,$E6,$3F
			.db	$C0,$3F,$80,$FF
			.db	$00,$FF,$03,$F8
			.db	$8F,$E0,$F8,$27
			.db	$70,$F0,$8F,$21
			.db	$FC,$C3,$39,$C0
			.db	$FF,$03,$F8,$C7
			.db	$00,$FE,$71,$0E
			.db	$80,$FF,$01,$FE
			.db	$3F,$80,$F7,$1F
			.db	$C0,$7F,$0E,$E0
			.db	$3F,$82,$E3,$0F
			.db	$E3,$61,$F8,$4F
			.db	$C0,$FE,$07,$E0
			.db	$FF,$00,$F8,$0F
			.db	$B0,$F8,$0F,$E6
			.db	$E0,$89,$5F,$E0
			.db	$E1,$1F,$80,$FF
			.db	$05,$84,$FF,$08
			.db	$F0,$1F,$06,$FC
			.db	$17,$82,$FF,$18
			.db	$C3,$07,$FC,$03
			.db	$C7,$7F,$02,$F2
			.db	$7F,$00,$FF,$3F
			.db	$00,$FF,$0F,$C0
			.db	$3F,$00,$FC,$1F
			.db	$80,$BF,$03,$F8
			.db	$1F,$08,$F9,$0F
			.db	$F0,$3F,$08,$F1
			.db	$1B,$0E,$FC,$01
			.db	$9C,$FF,$20,$30
			.db	$FF,$01,$B0,$FF
			.db	$01,$F0,$7F,$00
			.db	$F8,$3F,$00,$FE
			.db	$1F,$00,$FE,$0F
			.db	$E0,$FF,$01,$7C
			.db	$1F,$00,$E7,$1F
			.db	$06,$FA,$83,$07
			.db	$FE,$C0,$C3,$3E
			.db	$E0,$67,$0F,$E0
			.db	$F1,$53,$E0,$F9
			.db	$01,$F0,$FD,$00
			.db	$78,$3F,$00,$3E
			.db	$1F,$78,$C0,$3F
			.db	$1C,$E0,$3F,$00
			.db	$FC,$0B,$1D,$F0
			.db	$7F,$00,$F8,$3F
			.db	$00,$FE,$1F,$80
			.db	$FF,$13,$E0,$FC
			.db	$3E,$00,$FF,$23
			.db	$80,$FF,$0B,$00
			.db	$FF,$03,$C0,$FB
			.db	$39,$C0,$FE,$1C
			.db	$50,$3F,$3E,$A0
			.db	$3E,$7D,$00,$FF
			.db	$38,$C0,$1F,$7C
			.db	$80,$1F,$3E,$80
			.db	$1F,$9E,$83,$3F
			.db	$00,$1F,$3F,$80
			.db	$EB,$3F,$00,$AF
			.db	$3F,$60,$9E,$3F
			.db	$80,$1F,$0F,$E0
			.db	$1F,$07,$8E,$0F
			.db	$8F,$83,$3F,$0C
			.db	$1B,$CE,$0F,$82
			.db	$FF,$03,$06,$FF
			.db	$83,$03,$FE,$E1
			.db	$03,$FC,$1F,$00
			.db	$FE,$07,$F0,$F1
			.db	$78,$38,$3C,$7E
			.db	$00,$7E,$1E,$86
			.db	$3F,$C0,$1F,$1E
			.db	$C2,$C7,$23,$7C
			.db	$C4,$1F,$7C,$80
			.db	$7F,$10,$1F,$3E
			.db	$06,$0F,$F7,$E0
			.db	$E1,$E1,$03,$FC
			.db	$03,$1F,$FC,$07
			.db	$8C
ut_10_end	.db	$18

;***********************************************************
;* GRAND LIZARD UTTERANCES
;***********************************************************
start_speechdata
;ut2_cry_beg    .db   $CD,$BE
;      		.db	$A0,$F2,$2E,$A8
;      		.db	$BC,$07,$AA,$7E
;      		.db	$81,$AA,$5F,$60
;      		.db	$E9,$17,$54,$F9
;      		.db	$05,$95,$7E,$41
;      		.db	$A5,$3F,$50,$E9
;      		.db	$17,$54,$FA,$05
;      		.db	$95,$7E,$41,$A5
;      		.db	$5F,$50,$E9,$17
;      		.db	$54,$FA,$05,$25
;      		.db	$7F,$41,$C9,$5F
;      		.db	$50,$F2,$17,$94
;      		.db	$FC,$05,$25,$7F
;      		.db	$41,$C9,$5F,$50
;      		.db	$F2,$17,$94,$FC
;      		.db	$05,$25,$7F,$41
;      		.db	$C9,$5F,$28,$F2
;      		.db	$17,$8A,$FA,$85
;      		.db	$A2,$7E,$A1,$A8
;      		.db	$5F,$28,$F2,$17
;      		.db	$89,$FC,$45,$22
;      		.db	$7F,$91,$C8,$5F
;      		.db	$22,$F2,$97,$88
;      		.db	$7A,$17,$22,$DF
;      		.db	$05,$49,$7F,$41
;      		.db	$D2,$5F,$90,$EA
;      		.db	$17,$A4,$FC,$05
;      		.db	$29,$7F,$09,$A9
;      		.db	$5F,$42,$EA,$2F
;      		.db	$48,$F9,$0B,$52
;      		.db	$FE,$82,$94,$F7
;      		.db	$20,$E5,$3D,$48
;      		.db	$B9,$0F,$92,$FA
;      		.db	$83,$A4,$FE,$04
;      		.db	$A5,$BF,$20,$D5
;      		.db	$2F,$48,$F5,$0B
;      		.db	$52,$FD,$82,$54
;      		.db	$BF,$20,$E5,$2F
;      		.db	$48,$F9,$0B,$52
;      		.db	$FE,$82,$52,$BF
;      		.db	$A0,$D4,$6F,$20
;      		.db	$F5,$17,$A8,$FC
;      		.db	$05,$29,$7F,$41
;      		.db	$AA,$5F,$50,$EA
;      		.db	$17,$94,$7A,$07
;      		.db	$29,$DF,$41,$4A
;      		.db	$7F,$84,$AA,$5F
;      		.db	$90,$EA,$17,$A4
;      		.db	$FA,$05,$A5,$7E
;      		.db	$41,$A9,$5F,$50
;      		.db	$EA,$17,$94,$FC
;      		.db	$05,$25,$7F,$41
;      		.db	$C9,$5F,$50,$EA
;      		.db	$97,$90,$FA,$0B
;      		.db	$54,$FE,$82,$92
;      		.db	$BF,$A0,$E4,$3B
;      		.db	$24,$F9,$0E,$51
;      		.db	$FA,$23,$94,$FE
;      		.db	$02,$95,$BF,$A0
;      		.db	$D4,$2F,$24,$F5
;      		.db	$0B,$49,$7D,$0B
;      		.db	$4A,$FD,$82,$52
;      		.db	$BF,$A0,$D4,$2F
;      		.db	$A4,$F4,$0D,$29
;      		.db	$7D,$0B,$4A,$FD
;      		.db	$82,$52,$BF,$90
;      		.db	$D2,$3B,$A4,$F4
;      		.db	$2E,$28,$7D,$07
;      		.db	$29,$BD,$43,$2A
;      		.db	$EF,$90,$CA,$3B
;      		.db	$A4,$F2,$1E,$A8
;      		.db	$DA,$0E,$9A,$BC
;      		.db	$83,$26,$FB,$A0
;      		.db	$49,$BF,$60,$C9
;      		.db	$1F,$34,$F1,$0D
;      		.db	$35,$7A,$43,$8D
;      		.db	$FC,$42,$07,$DF
;      		.db	$D0,$C1,$37,$74
;      		.db	$D0,$1B,$35,$F8
;      		.db	$8A,$0E,$7A,$A3
;      		.db	$83,$5E,$A9,$41
;      		.db	$CF,$74,$C1,$67
;      		.db	$5A,$F0,$B1,$16
;      		.db	$F4,$AC,$06,$BE
;      		.db	$AC,$81,$3D,$73
;      		.db	$41,$AF,$5A,$D0
;      		.db	$CE,$16,$E8,$B3
;      		.db	$16,$F4,$B2,$05
;      		.db	$F6,$AC,$82,$BE
;      		.db	$AA,$A0,$5D,$2B
;      		.db	$A8,$CF,$92,$E8
;      		.db	$6B,$28,$EA,$1B
;      		.db	$8A,$FA,$16,$8A
;      		.db	$BE,$86,$A2,$AF
;      		.db	$A1,$52,$6F,$B0
;      		.db	$E8,$1B,$34,$FA
;      		.db	$06,$95,$FA,$05
;      		.db	$93,$7E,$41,$A5
;      		.db	$3F,$D0,$E4,$0F
;      		.db	$34,$F9,$06,$95
;      		.db	$BE,$41,$25,$7F
;      		.db	$90,$C9,$1F,$64
;      		.db	$F2,$0D,$A9,$F4
;      		.db	$83,$2A,$FE,$82
;      		.db	$4A,$BF,$90,$D2
;      		.db	$2F,$A4,$F4,$8D
;      		.db	$28,$F9,$0B,$4A
;      		.db	$FE,$42,$85,$FE
;      		.db	$48,$91,$6F,$4A
;      		.db	$E8,$9B,$0A,$F2
;      		.db	$CD,$0A,$7C,$D5
;      		.db	$01,$7D,$F5,$00
;      		.db	$9F,$BE,$80,$97
;      		.db	$BE,$40,$A7,$1F
;      		.db	$D0,$AA,$1F,$D0
;      		.db	$EA,$17,$D0,$D5
;      		.db	$17,$D0,$D5,$17
;      		.db	$D0,$6B,$17,$D0
;      		.db	$5B,$17,$D0,$57
;      		.db	$1B,$D0,$57,$AD
;      		.db	$C0,$5E,$B9,$A0
;      		.db	$6E,$56,$49,$5A
;      		.db	$97,$5A,$D0,$17
;      		.db	$DE,$40,$2F,$F5
;      		.db	$20,$ED,$CA,$16
;      		.db	$E8,$17,$5E,$60
;      		.db	$9F,$E8,$41,$7B
;      		.db	$42,$AF,$70,$8B
;      		.db	$FC,$04,$BB,$E8
;      		.db	$0B,$74,$D3,$5A
;      		.db	$44,$AF,$54,$13
;      		.db	$5D,$B5,$A4,$AA
;      		.db	$7A,$C4,$23,$7D
;      		.db	$A1,$25,$ED,$2A
;      		.db	$D1,$A5,$5E,$D0
;      		.db	$0B,$5F,$68,$A5
;      		.db	$2E,$55,$A5,$A5
;      		.db	$2E,$E9,$50,$2F
;      		.db	$BA,$D0,$AA,$16
;      		.db	$B5,$A8,$0F,$3E
;      		.db	$68,$27,$8F,$E8
;      		.db	$D2,$27,$B4,$E4
;      		.db	$2B,$AA,$F4,$8A
;      		.db	$13,$3D,$E9,$42
;      		.db	$2F,$EA,$42,$8F
;      		.db	$BA,$A4,$A5,$1E
;      		.db	$EA,$A1,$2E,$BA
;      		.db	$A4,$56,$56,$6A
;      		.db	$D1,$8E,$3A,$E8
;      		.db	$43,$2F,$D4,$49
;      		.db	$97,$B4,$D4,$45
;      		.db	$1B,$EA,$45,$17
;      		.db	$DA,$62,$47,$55
;      		.db	$E9,$51,$55,$DC
;      		.db	$64,$15,$AE,$6A
;      		.db	$85,$56,$DD,$A0
;      		.db	$55,$5E,$A1,$55
;      		.db	$75,$51,$55,$55
;      		.db	$55,$D6,$A2,$56
;      		.db	$D5,$A1,$5A,$55
;      		.db	$25,$6D,$A9,$4A
;      		.db	$7D,$94,$AA,$BA
;      		.db	$50,$AB,$5A,$A1
;      		.db	$B6,$2A,$A9,$EA
;      		.db	$29,$B4,$AA,$56
;      		.db	$D4,$4E,$AA,$52
;      		.db	$2F,$D4,$CA,$4B
;      		.db	$54,$EB,$42,$55
;      		.db	$F5,$82,$B6,$BA
;      		.db	$42,$B5,$2B,$15
;      		.db	$EA,$8B,$9A,$E8
;      		.db	$45,$9D,$D4,$52
;		      .db	$97,$4A,$D9,$D2
;		      .db	$86
;ut2_cry_end      
ut2_chrp1_beg	.db   $F6,$3E,$40
      		.db	$BD,$BE,$80,$76
      		.db	$7D,$80,$5B,$5F
      		.db	$40,$B7,$3E,$A0
      		.db	$B6,$3D,$A0,$B6
      		.db	$BD,$80,$B6,$BD
      		.db	$80,$AE,$BE,$80
      		.db	$B6,$7E,$40,$AD
      		.db	$7E,$01,$AD,$7E
      		.db	$81,$B4,$EE,$05
      		.db	$B4,$F5,$15,$B0
      		.db	$B6,$17,$C8,$56
      		.db	$5F,$40,$5D,$7B
      		.db	$01,$75,$ED,$05
      		.db	$B4,$AD,$57,$A0
      		.db	$17,$7D,$81,$5E
      		.db	$F4,$05,$B5,$52
      		.db	$5F,$42,$55,$F9
      		.db	$0B,$54,$E9,$1F
      		.db	$50,$D5,$FA,$01
      		.db	$D5,$EA,$2B,$50
      		.db	$DD,$DA,$02,$F5
      		.db	$96,$56,$A8,$5B
      		.db	$A2,$AB,$56,$A4
      		.db	$D1,$5F,$A0,$A5
      		.db	$FA,$8A,$48,$5B
      		.db	$D5,$0B,$D4,$4B
      		.db	$D5,$05,$B5,$27
      		.db	$55,$AA,$EA,$15
      		.db	$E4,$17,$BA,$44
      		.db	$7D,$15,$29,$AB
      		.db	$B7,$20,$AD,$BE
      		.db	$42,$55,$DA,$8B
      		.db	$54,$A5,$DD,$48
      		.db	$A5,$55,$5D,$A1
      		.db	$56,$D2,$57,$58
      		.db	$43,$FA,$85,$95
      		.db	$68,$AF,$45,$54
      		.db	$D5,$6E,$50,$2D
      		.db	$ED,$A2,$2A,$F5
      		.db	$85,$AC,$D2,$2B
      		.db	$A4,$AD,$BA,$82
      		.db	$7A,$B5,$42,$55
      		.db	$DB,$0A,$D5,$AA
      		.db	$AA,$4A,$AD,$52
      		.db	$AA,$5D,$49,$AA
      		.db	$EA,$17,$A8,$A9
      		.db	$AF,$A8,$54,$AF
      		.db	$A8,$8A,$EE,$50
      		.db	$27,$7A,$51,$17
      		.db	$DA,$91,$2B,$6A
      		.db	$55,$55,$AA,$4A
      		.db	$2F,$AA,$2A,$B5
      		.db	$2A,$2B,$A5,$B6
      		.db	$4A,$15,$75,$17
      		.db	$55,$E8,$4B,$55
      		.db	$54,$97,$56,$49
      		.db	$4F,$B4,$95,$AA
      		.db	$4A,$BA,$AA,$2A
      		.db	$54,$57,$5D,$50
      		.db	$AD,$BE,$A0,$AA
      		.db	$DE,$82,$5A,$75
      		.db	$45,$6A,$D5,$45
      		.db	$EA,$4A,$17,$A9
      		.db	$55,$55,$AA,$95
      		.db	$5E,$A8,$1D,$55
      		.db	$93,$7A,$49,$4D
      		.db	$A9,$9D,$AA,$A4
      		.db	$5A,$55,$25,$BA
      		.db	$AA,$2A,$55,$B5
      		.db	$AA,$0E,$6A,$4B
      		.db	$1F,$A2,$B5,$5A
      		.db	$A1,$DA
ut2_chrp1_end
ut2_chrp2_beg    .db   $DA,$55
      		.db	$4A,$D5,$5E,$C8
      		.db	$A5,$5E,$C1,$56
      		.db	$55,$49,$AB,$56
      		.db	$62,$AB,$AA,$C4
      		.db	$D5,$95,$44,$57
      		.db	$5D,$A2,$56,$B5
      		.db	$A2,$6A,$55,$A5
      		.db	$56,$55,$A5,$4B
      		.db	$E9,$0A,$6D,$E9
      		.db	$07,$5A,$E5,$07
      		.db	$5C,$E5,$0F,$70
      		.db	$E7,$07,$58,$F7
      		.db	$03,$B4,$F5,$03
      		.db	$6A,$F5,$03,$6A
      		.db	$F5,$05,$5A,$FD
      		.db	$02,$B6,$FC,$80
      		.db	$D6,$FC,$80,$B6
      		.db	$BE,$80,$AE,$BE
      		.db	$80,$AD,$BE,$80
      		.db	$AD,$BE,$80,$AD
      		.db	$BE,$80,$AD,$BE
      		.db	$40,$AB,$BE,$40
      		.db	$AB,$5F,$40,$AB
      		.db	$5F,$40,$6B,$5F
      		.db	$81,$5A,$DF,$80
      		.db	$DA,$F6,$02,$EA
      		.db	$75,$0B,$E8,$D5
      		.db	$2D,$D0,$56,$AF
      		.db	$40,$5B,$BB,$82
      		.db	$74,$CB,$2D,$E0
      		.db	$17,$7E,$40,$1F
      		.db	$FA,$82,$5A,$A9
      		.db	$57,$91,$5A,$FC
      		.db	$05,$6A,$AA,$5F
      		.db	$88,$B4,$DB,$2A
      		.db	$E0,$AB,$B6,$90
      		.db	$DA,$16,$75,$85
      		.db	$5D,$D0,$AF,$42
      		.db	$29,$F5,$4F,$A0
      		.db	$AA,$BE,$25,$A8
      		.db	$5D,$FA,$02,$B5
      		.db	$49,$7B,$05,$E9
      		.db	$8A,$7E,$05,$BA
      		.db	$11,$FF,$02,$B5
      		.db	$A8,$BF,$02,$D9
      		.db	$6A,$5D,$44,$EA
      		.db	$2B,$D4,$45,$BD
      		.db	$42,$6A,$57,$A5
      		.db	$4A,$5A,$D9,$56
      		.db	$54,$45,$FA,$53
      		.db	$99,$48,$5F,$A5
      		.db	$4A,$AA,$BE,$88
      		.db	$6A,$EA,$AB,$50
      		.db	$6A,$B5,$55,$A2
      		.db	$5A,$51,$5F,$A9
      		.db	$42,$EC,$5B,$85
      		.db	$A4,$FA,$2B,$A8
      		.db	$AA,$BA,$4A,$55
      		.db	$29,$E9,$AB,$2A
      		.db	$A2,$F6,$6A,$21
      		.db	$55,$7B,$85,$AA
      		.db	$AA,$4D,$25,$BA
      		.db	$4A,$57,$A4,$56
      		.db	$55,$B5,$52,$95
      		.db	$AA,$BE,$A2,$0A
      		.db	$ED,$55,$2A,$95
      		.db	$EA,$2B,$EA,$90
      		.db	$AD,$AA,$4A,$2B
      		.db	$D5,$4A,$AD,$AA
      		.db	$A4,$55,$B5,$52
      		.db	$95,$6A,$D5,$16
      		.db	$D4,$91,$7E,$A1
      		.db	$2A,$D5,$AA,$AA
      		.db	$A4,$EA,$AE,$42
      		.db	$AA,$DE,$2A,$A4
      		.db	$B6,$AA,$A8,$AA
      		.db	$55,$52,$AB,$56
      		.db	$21,$B7,$D2,$8A
      		.db	$D4,$96,$AA,$56
      		.db	$A8,$8B,$EA,$0B
      		.db	$55,$55,$AF,$4A
      		.db	$54,$AB,$AE,$24
      		.db	$D5,$2E,$55,$51
      		.db	$AD,$4A,$B5,$2A
      		.db	$55,$FA,$8A,$52
      		.db	$FA,$15,$AA,$AA
      		.db	$2F,$A4,$DA,$D6
      		.db	$42,$DA,$AA,$4A
      		.db	$AA,$AF,$48,$AD
      		.db	$AE,$44,$AD,$AE
      		.db	$44,$AB,$AA,$4A
      		.db	$AF,$2A,$A2,$AF
      		.db	$55,$50,$AB,$6B
      		.db	$A1,$5A,$55,$A9
      		.db	$56,$A9,$4A,$AB
      		.db	$5A,$A8,$AB,$52
      		.db	$A9,$55,$55,$A4
      		.db	$BF,$50,$25,$F7
      		.db	$8A,$8A,$F6,$2A
      		.db	$45,$BA,$AA,$2A
      		.db	$EA,$55,$2A,$6A
      		.db	$AB,$AA,$50,$57
      		.db	$55,$49,$AD,$6A
      		.db	$25,$6A,$D5,$2A
      		.db	$AA,$FA,$4A,$8A
      		.db	$FA,$55,$A4,$54
      		.db	$5F,$85,$54,$6F
      		.db	$15,$A9,$17
ut2_chrp2_end 
	
ut2_drum_beg	.db   $00,$C0,$FE
      		.db	$FF,$BF,$44,$48
      		.db	$22,$02,$08,$A9
      		.db	$BD,$FF,$FF,$AD
      		.db	$4A,$04,$11,$22
      		.db	$12,$A9,$DA,$FF
      		.db	$FF,$AE,$2A,$29
      		.db	$42,$00,$A2,$54
      		.db	$BB,$DF,$DF,$B6
      		.db	$AA,$12,$22,$44
      		.db	$44,$49,$D5,$FE
      		.db	$FE,$BB,$55,$25
      		.db	$88,$88,$48,$49
      		.db	$55,$7B,$EF,$FB
      		.db	$B6,$55,$09,$02
      		.db	$82,$48,$D5,$DA
      		.db	$BB,$DD,$DD,$6D
      		.db	$55,$82,$40,$40
      		.db	$4A,$6D,$FB,$DE
      		.db	$6F,$5B,$55,$21
      		.db	$42,$08,$49,$AA
      		.db	$6D,$77,$DF,$77
      		.db	$AB,$2A,$21,$84
      		.db	$10,$A9,$6A,$7B
      		.db	$EF,$6E,$6B,$AD
      		.db	$AA,$20,$08,$91
      		.db	$A4,$EA,$F6,$B6
      		.db	$ED,$BA,$5B,$2B
      		.db	$41,$88,$44,$2A
      		.db	$55,$D5,$7E,$EF
      		.db	$6E,$DB,$4A,$81
      		.db	$20,$10,$49,$D5
      		.db	$F6,$DE,$7B,$6F
      		.db	$5B,$25,$01,$01
      		.db	$21,$A5,$DA,$F6
      		.db	$BE,$77,$B7,$56
      		.db	$12,$04,$21,$24
      		.db	$A9,$6A,$F7,$F7
      		.db	$BE,$6D,$55,$12
      		.db	$08,$42,$A4,$AA
      		.db	$F6,$EE,$ED,$DD
      		.db	$56,$55,$08,$81
      		.db	$88,$A4,$D4,$DA
      		.db	$EF,$7D,$B7,$55
      		.db	$25,$22,$84,$88
      		.db	$A4,$54,$DB,$EF
      		.db	$7B,$B7,$55,$25
      		.db	$22,$04,$21,$29
      		.db	$D5,$B6,$F7,$BE
      		.db	$B7,$55,$95,$10
      		.db	$42,$88,$A4,$AA
      		.db	$ED,$FB,$EE,$AE
      		.db	$55,$89,$88,$08
      		.db	$91,$A4,$AA,$DD
      		.db	$F7,$DE,$B6,$56
      		.db	$49,$10,$22,$92
      		.db	$52,$B5,$F6,$BD
      		.db	$6D,$5B,$55,$15
      		.db	$89,$88,$48,$92
      		.db	$AA,$F5,$7B,$B7
      		.db	$AD,$55,$55,$91
      		.db	$88,$90,$44,$A9
      		.db	$56,$EF,$EE,$6E
      		.db	$6B,$55,$22,$12
      		.db	$22,$92,$AA,$D6
      		.db	$F6,$76,$B7,$5B
      		.db	$AB,$12,$22,$21
      		.db	$92,$4A,$B5,$ED
      		.db	$6E,$DB,$B6,$55
      		.db	$55,$88,$48,$24
      		.db	$A5,$AA,$6A,$7B
      		.db	$BB,$DB,$B6,$AA
      		.db	$0A,$91,$88,$44
      		.db	$4A,$55,$B5,$7D
      		.db	$B7,$DB,$5A,$55
      		.db	$48,$44,$44,$4A
      		.db	$55,$ED,$DD,$ED
      		.db	$6E,$AD,$AA,$10
      		.db	$11,$89,$94,$AA
      		.db	$DA,$BE,$DB,$6D
      		.db	$AD,$AA,$10,$89
      		.db	$24,$29,$55,$D5
      		.db	$7A,$77,$B7,$B5
      		.db	$AA,$22,$12,$91
      		.db	$28,$95,$AA,$D6
      		.db	$DE,$EE,$B6,$AD
      		.db	$AA,$90,$48,$44
      		.db	$92,$AA,$AA,$FB
      		.db	$6E,$B7,$AD,$AA
      		.db	$42,$24,$22,$49
      		.db	$4A,$B5,$EE,$DD
      		.db	$ED,$56,$AB,$14
      		.db	$22,$91,$A4,$54
      		.db	$55,$EB,$DB,$DD
      		.db	$5A,$AB,$0A,$89
      		.db	$24,$92,$A4,$AA
      		.db	$76,$EF,$76,$DB
      		.db	$AA,$2A,$12,$89
      		.db	$44,$52,$AA,$EA
      		.db	$DE,$DD,$B6,$AD
      		.db	$AA,$90,$88,$44
      		.db	$92,$52,$B5,$7D
      		.db	$77,$DB,$B6,$AA
      		.db	$22,$22,$22,$49
      		.db	$AA,$AA,$ED,$BB
      		.db	$6B,$5B,$55,$85
      		.db	$44,$12,$49,$52
      		.db	$55,$BB,$77,$BB
      		.db	$B5,$55,$45,$92
      		.db	$48,$92,$94,$AA
      		.db	$D6,$BE,$ED,$B6
      		.db	$55,$55,$24,$91
      		.db	$48,$52,$A9,$5A
      		.db	$DB,$BB,$6D,$5B
      		.db	$55,$85,$44,$24
      		.db	$52,$AA,$AA,$6D
      		.db	$DF,$B6,$AD,$56
      		.db	$85,$24,$92,$24
ut2_drum_end
ut2_shriek_beg    .db	$4E,$56,$4A,$55
      		.db	$CD,$34,$E9,$54
      		.db	$27,$D5,$8A,$C7
      		.db	$2A,$6B,$55,$55
      		.db	$94,$A7,$92,$63
      		.db	$CE,$68,$53,$55
      		.db	$CD,$49,$66,$69
      		.db	$DA,$68,$2D,$A6
      		.db	$0E,$6B,$5A,$5A
      		.db	$8F,$52,$69,$53
      		.db	$ED,$C1,$E1,$78
      		.db	$7C,$E1,$30,$E3
      		.db	$F8,$F0,$F0,$E2
      		.db	$F8,$F0,$D0,$71
      		.db	$7C,$F0,$E1,$E1
      		.db	$38,$8E,$C7,$8C
      		.db	$E3,$09,$0F,$1F
      		.db	$C7,$C3,$03,$C7
      		.db	$3B,$1C,$2E,$CF
      		.db	$F0,$F0,$78,$E8
      		.db	$C1,$E3,$F0,$E1
      		.db	$E1,$85,$C3,$C7
      		.db	$19,$0E,$1F,$C7
      		.db	$F1,$8C,$71,$1E
      		.db	$0E,$1C,$C7,$70
      		.db	$9C,$71,$86,$E3
      		.db	$C4,$C9,$0F,$9E
      		.db	$8F,$87,$19,$8F
      		.db	$03,$1D,$8F,$87
      		.db	$8E,$C7,$63,$C6
      		.db	$C7,$63,$C6,$C3
      		.db	$87,$8C,$23,$1D
      		.db	$27,$4F,$3C,$D6
      		.db	$38,$7D,$78,$70
      		.db	$F8,$70,$F1,$78
      		.db	$B0,$E1,$78,$C8
      		.db	$39,$3C,$3C,$0E
      		.db	$0F,$8E,$79,$DC
      		.db	$18,$0E,$9E,$E3
      		.db	$91,$E3,$70,$C2
      		.db	$F8,$F0,$C8,$F1
      		.db	$70,$CC,$F1,$78
      		.db	$C0,$F1,$78,$C8
      		.db	$78,$3C,$70,$1C
      		.db	$0E,$8E,$79,$CC
      		.db	$0D,$0F,$CE,$70
      		.db	$3C,$8C,$07,$CF
      		.db	$F0,$E0,$0D,$C7
      		.db	$8D,$C3,$61,$C7
      		.db	$E1,$F0,$F1,$70
      		.db	$D0,$78,$78,$70
      		.db	$1C,$47,$CE,$70
      		.db	$F8,$0C,$0F,$67
      		.db	$78,$38,$8B,$C3
      		.db	$19,$8F,$C7,$38
      		.db	$F6,$86,$C7,$71
      		.db	$3C,$73,$86,$03
      		.db	$C7,$F0,$E0,$18
      		.db	$1E,$39,$C7,$2B
      		.db	$67,$3C,$78,$C6
      		.db	$A3,$63,$3C,$7A
      		.db	$E3,$C1,$0F,$0F
      		.db	$E7,$78,$18,$C3
      		.db	$E1,$18,$47,$67
      		.db	$78,$38,$C7,$C3
      		.db	$33,$3C,$7A,$83
      		.db	$23,$67,$38,$71
      		.db	$86,$87,$67,$38
      		.db	$7A,$C3,$C3,$31
      		.db	$1C,$8E,$F1,$E1
      		.db	$A4,$27,$2F,$3C
      		.db	$9C,$F1,$68,$8C
      		.db	$87,$67,$38,$1C
      		.db	$C7,$83,$75,$3C
      		.db	$78,$86,$03,$E7
      		.db	$78,$F0,$8E,$47
      		.db	$67,$38,$36,$87
      		.db	$A3,$3D,$3E,$8D
      		.db	$E1,$E9,$24,$87
      		.db	$33,$4E,$8C,$70
      		.db	$F8,$8C,$87,$77
      		.db	$3C,$1C,$E3,$C1
      		.db	$18,$9E,$CC,$E3
      		.db	$D1,$1B,$8E,$9E
      		.db	$E1,$C0,$1D,$8E
      		.db	$C6,$F0,$34,$8E
      		.db	$A3,$B1,$1C,$CF
      		.db	$78,$38,$C6,$C3
      		.db	$39,$1E,$4F,$F1
      		.db	$78,$8A,$C3,$19
      		.db	$1E,$DE,$78,$3C
      		.db	$0C,$C7,$4E,$38
      		.db	$B6,$87,$83,$37
      		.db	$3C,$7C,$E1,$E1
      		.db	$03,$0F,$77,$38
      		.db	$78,$E1,$E1,$24
      		.db	$8F,$C3,$3C,$4E
      		.db	$E6,$71,$86,$87
      		.db	$33,$3C,$1C,$C3
      		.db	$E1,$39,$8E,$9D
      		.db	$E3,$D0,$1B,$8E
      		.db	$9D,$E1,$E1,$0C
      		.db	$0E,$E7,$E1,$38
      		.db	$CB,$D3,$18,$87
      		.db	$C6,$38,$38,$CB
      		.db	$C3,$39,$1E,$8E
      		.db	$F1,$E0,$0C,$47
      		.db	$CE,$70,$E2,$0C
      		.db	$1F,$CE,$F0,$70
      		.db	$0C,$07,$6F,$F8
      		.db	$78,$C3,$C3,$5B
      		.db	$1E,$56,$F8,$38
      		.db	$CB,$E1,$28,$0E
      		.db	$E7,$F1,$38,$86
      		.db	$87,$33,$3C,$9C
      		.db	$C3,$C1,$19,$1E
      		.db	$AD,$E1,$C9,$0B
      		.db	$1E,$DE,$F0,$F0
      		.db	$84,$87,$27,$3C
      		.db	$3C,$F9,$E1,$84
      		.db	$87,$27,$3C,$38
      		.db	$C3,$C3,$33,$1E
      		.db	$BC,$C3,$A1,$33
      		.db	$1E,$39,$C3,$C1
      		.db	$1B,$1E,$BC,$E1
      		.db	$E1,$09,$0F,$E7
      		.db	$78,$78,$D2,$C3
      		.db	$91,$0F,$CE,$70
      		.db	$F0,$86,$87,$67
      		.db	$38,$78,$C7,$43
      		.db	$6F,$78,$70,$86
      		.db	$83,$67,$38,$78
      		.db	$86,$C3,$67,$3C
      		.db	$3C,$C3,$C3,$1B
      		.db	$1E,$9E,$F0,$B4
      		.db	$A5,$87,$1D,$1E
      		.db	$8C,$E1,$E1,$1C
      		.db	$0E,$CE,$F1,$F0
      		.db	$19,$0E,$9E,$F0
      		.db	$E0,$09,$0F,$DE
      		.db	$F0,$F0,$0C,$0F
      		.db	$6F,$78,$78,$C3
      		.db	$C3,$13,$3E,$9E
      		.db	$F0,$F0,$86,$87
      		.db	$63,$38,$78,$86
      		.db	$C3,$6F,$38,$78
      		.db	$86,$83,$67,$38
      		.db	$7C,$C6,$C3,$33
      		.db	$3C,$7C,$C3,$C3
      		.db	$33,$1E,$9E,$E1
      		.db	$F0,$85,$87,$2F
      		.db	$3C,$5C,$C3,$C3
      		.db	$35,$1C,$7E,$C2
      		.db	$C1,$27,$3C,$7C
      		.db	$C6,$83,$27,$3C
      		.db	$3C,$C7,$C3,$07
      		.db	$1E,$3E,$E3,$E1
      		.db	$51,$1E,$8E,$F3
      		.db	$F0,$20,$47,$CF
      		.db	$7A,$F0,$8C,$07
      		.db	$CF,$F0,$F0,$1C
      		.db	$0E,$8F,$E1,$F8
      		.db	$18,$1E,$8F,$E1
      		.db	$69,$1C,$0E,$E7
      		.db	$F0,$30,$0E,$8F
      		.db	$E3,$78,$1C,$8F
      		.db	$C3,$73,$3C,$0C
      		.db	$C7,$B1,$73,$38
      		.db	$73,$86,$87,$CF
      		.db	$70,$EC,$0D,$C7
      		.db	$9E,$F0,$E0,$89
      		.db	$8F,$9E,$F0,$F8
      		.db	$84,$87,$6B,$78
      		.db	$38,$C3,$C3,$B1
      		.db	$3C,$3C,$C3,$83
      		.db	$73,$78,$78,$0E
      		.db	$07,$CF,$F1,$E4
      		.db	$1C,$0F,$9E,$E1
      		.db	$C1,$1B,$1E,$BE
      		.db	$F0,$E0,$07,$0F
      		.db	$6B,$78,$78,$87
      		.db	$87,$73,$78,$3C
      		.db	$83,$CB,$73,$38
      		.db	$38,$86,$87,$E7
      		.db	$70,$E8,$0C,$4F
      		.db	$DE,$F0,$E0,$19
      		.db	$0F,$DE,$F0,$70
      		.db	$86,$87,$63,$78
      		.db	$3C,$C7,$C3,$71
      		.db	$3C,$9E,$C1,$E1
      		.db	$39,$1C,$1E,$87
      		.db	$D3,$F1,$78,$A4
      		.db	$0E,$67,$DE,$F0
      		.db	$E0,$1D,$0F,$9E
      		.db	$F0,$E0,$0D,$0F
      		.db	$6F,$70,$F8,$86
      		.db	$87,$67,$78,$78
      		.db	$8E,$07,$C7,$F0
      		.db	$F0,$18,$1E,$3D
      		.db	$C3,$C1,$67,$3C
      		.db	$F0,$8C,$07,$CF
      		.db	$F0,$F0,$18,$0F
      		.db	$8F,$F1,$F0,$08
      		.db	$0F,$4F,$78,$F0
      		.db	$0C,$07,$CF,$F0
      		.db	$F0,$19,$0F,$3B
      		.db	$E6,$11,$8F,$3C
      		.db	$F1,$98,$0F,$8E
      		.db	$E3,$E1,$38,$1E
      		.db	$1E,$E3,$E1,$11
      		.db	$1E,$1E,$E1,$E1
      		.db	$39,$1E,$1E,$E3
      		.db	$E1,$63,$3C,$F4
      		.db	$98,$0E,$3C,$87
      		.db	$87,$C7,$F0,$F8
      		.db	$18,$8E,$87,$E3
      		.db	$F1,$38,$1C,$1E
      		.db	$C7,$C3,$73,$3C
      		.db	$3C,$C6,$C3,$63
      		.db	$38,$7A,$8E,$07
      		.db	$8F,$F1,$C1,$73
      		.db	$78,$78,$1C,$8E
      		.db	$2F,$C3,$39,$67
      		.db	$1E,$E3,$87,$23
      		.db	$7E,$78,$B0,$0F
      		.db	$0F,$C7,$F0,$F0
      		.db	$18,$0F,$1E,$E3
      		.db	$C1,$63,$38,$78
      		.db	$3C,$1E,$3B,$0E
      		.db	$6F,$1C,$83,$8F
      		.db	$67,$72,$F0,$0C
      		.db	$0F,$CF,$F0,$F0
      		.db	$0C,$0F,$CF,$E1
      		.db	$E1,$09,$8F,$9E
      		.db	$E1,$D8,$33,$1C
      		.db	$7F,$4C,$C3,$0E
      		.db	$C3,$31,$E7,$70
      		.db	$CE,$19,$8E,$BC
      		.db	$E3,$C1,$37,$3C
      		.db	$38,$C3,$C3,$33
      		.db	$3C,$1C,$C3,$C3
      		.db	$71,$38,$3C,$0E
      		.db	$87,$8F,$E1,$E1
      		.db	$F1,$70,$FC,$78
      		.db	$38,$71,$1C,$3E
      		.db	$3C,$C7,$83,$C7
      		.db	$78,$FC,$88,$07
      		.db	$F7,$78,$F0,$0C
      		.db	$0F,$1F,$E1,$E1
      		.db	$31,$1F,$38,$0E
      		.db	$8F,$8F,$C3,$E3
      		.db	$E3,$E1,$C0,$F3
      		.db	$F8,$70,$1C,$1E
      		.db	$1E,$C3,$E1,$71
      		.db	$3C,$3C,$C6,$C3
      		.db	$63,$78,$3C,$0C
      		.db	$87,$87,$E3,$B9
      		.db	$F0,$70,$87,$73
      		.db	$F8,$70,$3C,$3C
      		.db	$1E,$8E,$47,$CF
      		.db	$70,$D8,$39,$1E
      		.db	$3E,$E3,$C1,$35
      		.db	$3C,$1A,$86,$C3
      		.db	$C7,$F1,$F0,$38
      		.db	$3C,$5A,$0E,$67
      		.db	$3C,$87,$07,$8F
      		.db	$C3,$E3,$E3,$78
      		.db	$F0,$31,$8F,$78
      		.db	$A6,$21,$CF,$7C
      		.db	$F0,$19,$0F,$C6
      		.db	$F3,$C1,$71,$3C
      		.db	$70,$1C,$1E,$3C
      		.db	$0E,$0F,$1E,$8F
      		.db	$87,$87,$87,$C7
      		.db	$87,$87,$C3,$E3
      		.db	$E1,$E1,$19,$0F
      		.db	$8F,$C3,$C3,$71
      		.db	$3C,$78,$C6,$C3
      		.db	$C7,$F0,$F0,$70
      		.db	$3C,$7C,$1C,$1C
      		.db	$3C,$1E,$1E,$1F
      		.db	$0F,$8F,$33,$1E
      		.db	$1E,$1E,$87,$87
      		.db	$CF,$F0,$E0,$11
      		.db	$1F,$EE,$E1,$83
      		.db	$E7,$F0,$E0,$31
      		.db	$FC,$70,$1C,$7E
      		.db	$3C,$0E,$0F,$1D
      		.db	$0F,$87,$1E,$0F
      		.db	$87,$8F,$C3,$C1
      		.db	$33,$3E,$19,$8E
      		.db	$87,$8F,$F1,$E0
      		.db	$71,$38,$DE,$1C
      		.db	$1E,$3C,$0E,$0F
      		.db	$1F,$0F,$0F,$1F
      		.db	$1E,$0E,$37,$1E
      		.db	$0E,$1E,$1E,$0E
      		.db	$1F,$0F,$07,$C7
      		.db	$E1,$E1,$71,$38
      		.db	$79,$CC,$07,$1F
      		.db	$D3,$03,$C7,$E1
      		.db	$A1,$E3,$F1,$31
      		.db	$CB,$C3,$61,$C6
      		.db	$C7,$C3,$9E,$87
      		.db	$83,$87,$87,$87
      		.db	$C7,$E1,$C3,$63
      		.db	$78,$F8,$38,$3C
      		.db	$3C,$0E,$0F,$1F
      		.db	$0F,$87,$0B,$1F
      		.db	$8F,$27,$1C,$1C
      		.db	$8F,$79,$78,$9C
      		.db	$E3,$E1,$70,$E3
      		.db	$E1,$E1,$C3,$E1
      		.db	$E1,$C3,$E1,$E1
      		.db	$E1,$F0,$38,$F9
      		.db	$F0,$70,$C6,$E1
      		.db	$E5,$1C,$97,$0F
      		.db	$33,$3E,$0E,$4F
      		.db	$B8,$3C,$9C,$F1
      		.db	$E1,$30,$E3,$C1
      		.db	$E1,$C0,$C3,$C3
      		.db	$A1,$47,$87,$E7
      		.db	$9C,$78,$8E,$79
      		.db	$72,$38,$E6,$EC
      		.db	$E4,$B8,$33,$B1
      		.db	$61,$CC,$E4,$8E
      		.db	$F3,$73,$1B,$8E
      		.db	$0E,$0F,$18,$3F
      		.db	$2E,$C7,$FC,$B0
      		.db	$1C,$E3,$85,$47
      		.db	$8C,$17,$1B,$63
      		.db	$DE,$DC,$8C,$E3
      		.db	$20,$73,$8C,$9F
      		.db	$D8,$71,$7C,$E0
      		.db	$C3,$F1,$83,$03
      		.db	$87,$0F,$8E,$3C
      		.db	$3E,$70,$E0,$F1
      		.db	$F0,$03,$8F,$23
      		.db	$9D,$6C,$9E,$E1
      		.db	$41,$F3,$4C,$9E
      		.db	$38,$C7,$E4,$E0
      		.db	$61,$0F,$47,$1E
      		.db	$DE,$F0,$E2,$F1
      		.db	$0C,$87,$1F,$E7
      		.db	$E4,$A0,$61,$1C
      		.db	$1E,$3E,$F4,$E1
      		.db	$19,$C7,$3F,$78
      		.db	$78,$F8,$0C,$0F
      		.db	$0F,$8F,$C3,$C3
      		.db	$C7,$C7,$E1,$B0
      		.db	$E6,$E1,$E1,$E1
      		.db	$E1,$E1,$C1,$C3
      		.db	$83,$E3,$13,$FE
      		.db	$70,$78,$1C,$7C
      		.db	$78,$78,$1C,$3D
      		.db	$3C,$78,$F8,$F0
      		.db	$91,$A4,$E3,$E0
      		.db	$E1,$E1,$C1,$83
      		.db	$C7,$87,$0F,$DE
      		.db	$F0,$70,$70,$F1
      		.db	$F8,$F8,$F0,$70
      		.db	$71,$71,$F8,$38
      		.db	$9C,$32,$3E,$74
      		.db	$72,$E1,$1A,$1E
      		.db	$3C,$4E,$7C,$F0
      		.db	$F0,$83,$C7,$0F
      		.db	$2F,$3C,$3C,$5C
      		.db	$0E,$1E,$3E,$3C
      		.db	$74,$C3,$F1,$84
      		.db	$D3,$E3,$E4,$E1
      		.db	$C3,$A1,$B1,$1C
      		.db	$1D,$3E,$E1,$91
      		.db	$C3
ut2_shriek_end
ut2_tgrowl_beg    .db   $A9,$AA,$4A
      		.db	$AA,$AA,$6A,$55
      		.db	$B5,$55,$55,$55
      		.db	$55,$55,$55,$55
      		.db	$25,$55,$05,$5D
      		.db	$52,$AB,$AA,$5F
      		.db	$51,$15,$A8,$DB
      		.db	$A5,$1F,$F0,$45
      		.db	$6A,$23,$B5,$52
      		.db	$D5,$42,$BB,$BA
      		.db	$5B,$01,$94,$A4
      		.db	$7F,$77,$05,$92
      		.db	$AA,$FA,$AA,$56
      		.db	$85,$4A,$A4,$FA
      		.db	$7B,$77,$09,$00
      		.db	$52,$FB,$DF,$56
      		.db	$41,$4A,$51,$6A
      		.db	$EF,$DE,$2A,$00
      		.db	$21,$ED,$F7,$BB
      		.db	$24,$80,$AA,$FA
      		.db	$AD,$6A,$AB,$0A
      		.db	$22,$88,$EA,$EF
      		.db	$BF,$AA,$00,$12
      		.db	$A5,$FE,$5E,$89
      		.db	$B6,$55,$84,$20
      		.db	$F5,$FF,$57,$01
      		.db	$44,$BB,$AF,$40
      		.db	$A4,$FE,$2B,$4A
      		.db	$90,$FE,$0B,$DD
      		.db	$AA,$42,$20,$ED
      		.db	$FE,$AB,$02,$A0
      		.db	$EE,$AF,$00,$A9
      		.db	$FB,$AB,$02,$22
      		.db	$DB,$7F,$15,$80
      		.db	$EA,$DF,$12,$90
      		.db	$B6,$DF,$2A,$10
      		.db	$B4,$FB,$AF,$00
      		.db	$5B,$1B,$11,$D9
      		.db	$FE,$AE,$12,$80
      		.db	$57,$7D,$A9,$DD
      		.db	$4A,$04,$42,$FB
      		.db	$7F,$97,$00,$F8
      		.db	$25,$52,$F5,$5E
      		.db	$25,$21,$A8,$EE
      		.db	$FF,$96,$00,$7E
      		.db	$A1,$A2,$EA,$B7
      		.db	$2A,$10,$A8,$FB
      		.db	$DF,$2A,$00,$6A
      		.db	$F7,$17,$C0,$7D
      		.db	$25,$90,$DA,$7E
      		.db	$57,$11,$80,$FE
      		.db	$BB,$04,$A4,$FD
      		.db	$2B,$80,$EA,$BB
      		.db	$15,$82,$D4,$FE
      		.db	$57,$01,$A8,$BF
      		.db	$2B,$80,$FA,$EE
      		.db	$0A,$E0,$95,$DA
      		.db	$D7,$4A,$00,$FC
      		.db	$57,$41,$F5,$BD
      		.db	$02,$90,$F7,$53
      		.db	$40,$3F,$A4,$DD
      		.db	$76,$25,$00,$FA
      		.db	$5F,$90,$74,$DF
      		.db	$4A,$08,$A4,$76
      		.db	$FF,$4D,$00,$EC
      		.db	$5F,$09,$54,$DF
      		.db	$57,$02,$92,$5F
      		.db	$76,$AB,$22,$02
      		.db	$BE,$AA,$DB,$B7
      		.db	$25,$00,$E8,$8F
      		.db	$7B,$2B,$28,$51
      		.db	$B5,$BB,$6F,$01
      		.db	$F0,$8A,$C8,$F6
      		.db	$6F,$15,$11,$22
      		.db	$75,$BF,$AF,$0A
      		.db	$81,$50,$DD,$FB
      		.db	$AD,$12,$08,$54
      		.db	$FB,$7E,$57,$81
      		.db	$10,$D4,$EE,$FD
      		.db	$AA,$00,$A8,$5F
      		.db	$D4,$BD,$55,$10
      		.db	$91,$EA,$DE,$DF
      		.db	$12,$00,$6E,$A9
      		.db	$DA,$7D,$AB,$00
      		.db	$54,$E9,$DE,$BF
      		.db	$4A,$00,$2C,$F5
      		.db	$1F,$D0,$5F,$80
      		.db	$1F,$E8,$1F,$D0
      		.db	$93,$BE,$95,$00
      		.db	$F5,$DB,$AA,$C0
      		.db	$8A,$AA,$7F,$30
      		.db	$E9,$0B,$5C,$48
      		.db	$D7,$FB,$56,$02
      		.db	$E0,$CB,$7E,$05
      		.db	$5C,$45,$AA,$EF
      		.db	$56,$25,$80,$D4
      		.db	$FD,$3F,$51,$01
      		.db	$E8,$5F,$48,$EF
      		.db	$AA,$04,$42,$B5
      		.db	$77,$DF,$4A,$20
      		.db	$A0,$6F,$DB,$BD
      		.db	$25,$08,$24,$B5
      		.db	$EF,$7D,$53,$00
      		.db	$20,$FD,$D5,$DE
      		.db	$55,$44,$10,$D5
      		.db	$DE,$FB,$56,$11
      		.db	$00,$F8,$5B,$6D
      		.db	$5F,$25,$81,$50
      		.db	$ED,$BD,$DF,$12
      		.db	$01,$40,$7F,$D5
      		.db	$F6,$55,$22,$08
      		.db	$69,$FB,$7E,$9B
      		.db	$04,$00,$FA,$55
      		.db	$DB,$DB,$24,$08
      		.db	$A2,$F6,$BD,$5F
      		.db	$25,$00,$D0,$5F
      		.db	$D5,$DE,$55,$04
      		.db	$21,$D5,$7E,$DF
      		.db	$4B,$02,$04,$FA
      		.db	$AB,$B6,$B7,$22
      		.db	$04,$A2,$DD,$F7
      		.db	$B7,$24,$00,$D0
      		.db	$5F,$B5,$7B,$4B
      		.db	$08,$44,$DA,$7D
      		.db	$EF,$55,$04,$00
      		.db	$F9,$6D,$ED,$DE
      		.db	$12,$82,$A0,$EA
      		.db	$7E,$F7,$55,$04
      		.db	$00,$F9,$6E,$DB
      		.db	$DB,$12,$08,$A2
      		.db	$DA,$EF,$DE,$4B
      		.db	$02,$20,$D4,$7B
      		.db	$B7,$B7,$0A,$82
      		.db	$90,$EA,$7E,$F7
      		.db	$56,$04,$80,$68
      		.db	$F7,$BD,$B7,$12
      		.db	$04,$91,$DA,$F7
      		.db	$DD,$2B,$11,$00
      		.db	$D2,$DD,$F7,$5B
      		.db	$09,$04,$51,$F5
      		.db	$BD,$7B,$95,$40
      		.db	$80,$B4,$F7,$FD
      		.db	$2A,$41,$10,$69
      		.db	$F7,$BD,$57,$11
      		.db	$00,$51,$7B,$DF
      		.db	$AF,$84,$10,$A2
      		.db	$F6,$DD,$B7,$8A
      		.db	$00,$21,$ED,$5F
      		.db	$77,$4B,$02,$A0
      		.db	$B6,$DF,$AF,$84
      		.db	$10,$51,$ED,$D7
      		.db	$B7,$4A,$00,$A8
      		.db	$DD,$7F,$2B,$21
      		.db	$44,$AA,$FB,$76
      		.db	$AB,$04,$00,$B5
      		.db	$F7,$6F,$89,$10
      		.db	$49,$DD,$AF,$B7
      		.db	$0A,$00,$D2,$EE
      		.db	$BF,$4A,$24,$84
      		.db	$FA,$57,$5F,$25
      		.db	$01,$90
ut2_tgrowl_end

;ut2_squawk_beg    .db   $5F
;      		.db	$00,$FE,$53,$80
;      		.db	$FE,$6B,$01,$F0
;      		.db	$7F,$80,$ED,$27
;      		.db	$E0,$C1,$FF,$00
;      		.db	$3F,$F8,$21,$F0
;      		.db	$A7,$40,$FF,$03
;      		.db	$07,$FE,$04,$3D
;      		.db	$7E,$1C,$F0,$4F
;      		.db	$E8,$E0,$3B,$F0
;      		.db	$07,$F8,$57,$05
;      		.db	$F0,$0F,$5E,$45
;      		.db	$0D,$FE,$00,$FF
;      		.db	$83,$C0,$2F,$AD
;      		.db	$1E,$38,$FC,$01
;      		.db	$FA,$C3,$07,$C7
;      		.db	$C5,$1F,$80,$3F
;      		.db	$E0,$1F,$C4,$1F
;      		.db	$E0,$1F,$E0,$0F
;      		.db	$FA,$03,$FC,$83
;      		.db	$7F,$80,$3F,$E0
;      		.db	$07,$F8,$01,$3F
;      		.db	$C0,$0F,$F8,$03
;      		.db	$FC,$80,$1F,$E0
;      		.db	$07,$FE,$1C,$7C
;      		.db	$E0,$0F,$F0,$C1
;      		.db	$3F,$C0,$07,$FC
;      		.db	$80,$1F,$F0,$07
;      		.db	$7C,$C0,$1F,$F0
;      		.db	$03,$7F,$80,$07
;      		.db	$FF,$00,$3E,$F8
;      		.db	$03,$F0,$C3,$1F
;      		.db	$C0,$1F,$F8,$81
;      		.db	$1F,$F0,$03,$3E
;      		.db	$8C,$0F,$F0,$01
;      		.db	$3F,$C0,$07,$FC
;      		.db	$00,$1F,$E0,$03
;      		.db	$7C,$80,$1F,$F0
;      		.db	$01,$7F,$80,$0F
;      		.db	$F8,$01,$3E,$C0
;      		.db	$0F,$F0,$01,$7C
;      		.db	$C0,$0F,$F0,$03
;      		.db	$3E,$C0,$0F,$F0
;      		.db	$01,$7E,$80,$0F
;      		.db	$F0,$03,$7E,$80
;      		.db	$1F,$F0,$41,$7E
;      		.db	$80,$0F,$F0,$03
;      		.db	$7E,$80,$0F,$F0
;      		.db	$01,$7E,$80,$0F
;      		.db	$F0,$03,$7E,$80
;      		.db	$1F,$F0,$01,$FE
;      		.db	$80,$0F,$F8,$03
;      		.db	$7E,$C0,$1F,$F0
;      		.db	$03,$7E,$80,$1F
;      		.db	$E0,$07,$7C,$80
;      		.db	$1F,$E0,$03,$FC
;      		.db	$80,$1F,$F0,$07
;      		.db	$FC,$80,$3F,$C0
;      		.db	$03,$FF,$00,$3F
;      		.db	$F8,$03,$F8,$01
;      		.db	$3F,$C0,$0F,$F0
;      		.db	$03,$7E,$80,$1F
;      		.db	$E0,$03,$FC,$01
;      		.db	$3F,$E0,$0F,$F8
;      		.db	$01,$7E,$80,$0F
;      		.db	$F0,$03,$FC,$80
;      		.db	$1F,$C0,$07,$F8
;      		.db	$01,$7E,$C0,$0F
;      		.db	$E0,$07,$FE,$00
;      		.db	$7E,$C0,$1F,$84
;      		.db	$0F,$F0,$07,$E1
;      		.db	$03,$FE,$01,$F8
;      		.db	$80,$3F,$30,$3F
;      		.db	$F0,$0F,$1E,$1F
;      		.db	$DC,$0F,$0F,$1F
;      		.db	$E0,$0F,$8C,$0F
;      		.db	$FE,$03,$0F,$1E
;      		.db	$87,$CF,$03,$1F
;      		.db	$E0,$07,$1E,$03
;      		.db	$FE,$81,$0F,$FC
;      		.db	$C0,$C1,$1F,$F8
;      		.db	$00,$FF,$81,$87
;      		.db	$87,$07,$F8,$07
;      		.db	$F8,$E0,$BF,$C0
;      		.db	$1B,$3E,$1E,$BC
;      		.db	$1F,$04,$3F,$F8
;      		.db	$0F,$F0,$07,$3F
;      		.db	$C0,$5F,$E3,$80
;      		.db	$3F,$F1,$C3,$F0
;      		.db	$61,$FC,$C8,$E3
;      		.db	$F8,$01,$7C,$DF
;      		.db	$03,$F0,$FB,$1E
;      		.db	$E0,$77,$F5,$00
;      		.db	$FF,$0D,$B8,$1E
;      		.db	$3F,$18,$FE,$B4
;      		.db	$34,$7C,$FC,$03
;      		.db	$7E,$F0,$3F,$C0
;      		.db	$1F,$FC,$81,$1F
;      		.db	$FC,$03,$FC,$E0
;      		.db	$1F,$F8,$01,$FF
;      		.db	$E0,$1A,$FC,$C0
;      		.db	$2F,$F0,$0F,$7C
;      		.db	$F0,$1D,$F8,$48
;      		.db	$F9,$C1,$0F,$FC
;      		.db	$D2,$17,$E0,$0F
;      		.db	$FC,$81,$3F,$F0
;      		.db	$07,$FE,$01,$3F
;      		.db	$F0,$0F,$7C,$81
;      		.db	$7F,$F0,$41,$3F
;      		.db	$78,$87,$C7,$63
;      		.db	$6D,$09,$FF,$C2
;      		.db	$C3,$E1,$E3,$0F
;      		.db	$F4,$81,$7F,$80
;      		.db	$EF,$E1,$C1,$78
;      		.db	$FE,$00,$3F,$F0
;      		.db	$0F,$F8,$C1,$1F
;      		.db	$E0,$07,$FE,$03
;      		.db	$7E,$E0,$0F,$F0
;      		.db	$83,$FF,$80,$1F
;      		.db	$FC,$03,$FC,$81
;      		.db	$1F,$F0,$07,$7E
;      		.db	$C0,$1F,$F0,$03
;      		.db	$7F,$C0,$3F,$F0
;      		.db	$03,$FE,$80,$1F
;      		.db	$FA,$03,$FC,$C1
;      		.db	$1F,$F0,$07,$7E
;      		.db	$C0,$1F,$F8,$81
;      		.db	$7F,$C0,$07,$FC
;      		.db	$81,$7F,$C0,$0F
;      		.db	$F8,$07,$FC,$10
;      		.db	$FF,$C0,$3F,$38
;      		.db	$46,$1F,$D6,$03
;      		.db	$FF,$00,$7F,$D0
;      		.db	$0F,$F8,$43,$3D
;      		.db	$78,$57,$2E,$F0
;      		.db	$2F,$F8,$16,$F4
;      		.db	$07,$BF,$C0,$1F
;      		.db	$3E,$C0,$3F,$A5
;      		.db	$03,$FC,$17,$0C
;      		.db	$1F,$FB,$80,$F6
;      		.db	$0F,$E8,$83,$5F
;      		.db	$60,$D5,$0F,$A3
;      		.db	$23,$7E,$A8,$0F
;      		.db	$3E,$C5,$0F,$F8
;      		.db	$07,$FC,$81,$DF
;      		.db	$03,$3F,$E0,$07
;      		.db	$3F,$6C,$F0,$81
;      		.db	$3F,$F8,$92,$E1
;      		.db	$07,$3E,$F8,$35
;      		.db	$F0,$78,$B9,$62
;      		.db	$8B,$87,$E7,$E0
;      		.db	$2F,$5C,$F0,$E1
;      		.db	$07,$FE,$00,$1F
;ut2_squawk_end      		
;ut2_caw_beg    .db	$78,$78,$78,$83
;      		.db	$87,$C3,$3F,$70
;      		.db	$3C,$FC,$81,$87
;      		.db	$0F,$FB,$70,$78
;      		.db	$F8,$07,$C7,$87
;      		.db	$3C,$38,$3C,$E8
;      		.db	$C3,$E1,$C1,$3F
;      		.db	$08,$1F,$F0,$C3
;      		.db	$F0,$C1,$3E,$0C
;      		.db	$0F,$FE,$61,$78
;      		.db	$E0,$07,$C3,$07
;      		.db	$7E,$30,$3E,$F0
;      		.db	$83,$F1,$C1,$1F
;      		.db	$0C,$0F,$FE,$E0
;      		.db	$78,$E0,$07,$E6
;      		.db	$C1,$3F,$38,$1E
;      		.db	$FC,$C3,$F0,$E0
;      		.db	$0F,$86,$87,$7F
;      		.db	$30,$3C,$F8,$83
;      		.db	$E1,$E1,$1F,$0C
;      		.db	$0F,$E7,$E1,$70
;      		.db	$38,$0F,$C7,$83
;      		.db	$3F,$1C,$1E,$F8
;      		.db	$E1,$78,$E0,$0F
;      		.db	$C6,$83,$7F,$30
;      		.db	$1E,$FC,$C1,$F0
;      		.db	$E0,$0F,$86,$07
;      		.db	$7F,$30,$3C,$F8
;      		.db	$C3,$E1,$81,$3F
;      		.db	$0C,$0F,$FC,$61
;      		.db	$78,$F8,$07,$C3
;      		.db	$C3,$3F,$1C,$1E
;      		.db	$FC,$41,$F0,$F0
;      		.db	$0F,$8E,$07,$FF
;      		.db	$E0,$78,$F0,$0F
;      		.db	$C6,$07,$7F,$60
;      		.db	$3C,$FC,$81,$C7
;      		.db	$C3,$1F,$38,$3C
;      		.db	$FC,$81,$C7,$C3
;      		.db	$1D,$7C,$3C,$DC
;      		.db	$E0,$C3,$07,$7D
;      		.db	$3E,$78,$30,$8F
;      		.db	$81,$0F,$FC,$81
;      		.db	$F3,$81,$1F,$78
;      		.db	$3C,$F8,$83,$0F
;      		.db	$8E,$37,$F8,$C1
;      		.db	$E3,$18,$BF,$F0
;      		.db	$01,$3F,$78,$3C
;      		.db	$F8,$83,$0F,$0F
;      		.db	$1E,$F8,$07,$1E
;      		.db	$87,$7C,$1E,$3C
;      		.db	$3C,$8E,$87,$C3
;      		.db	$E3,$F0,$F0,$81
;      		.db	$87,$1F,$BE,$80
;      		.db	$8F,$E7,$F0,$03
;      		.db	$0F,$C7,$C7,$2F
;      		.db	$70,$3E,$E4,$07
;      		.db	$FE,$C0,$7E,$E0
;      		.db	$11,$7E,$F0,$11
;      		.db	$EF,$03,$BF,$C0
;      		.db	$2F,$F8,$03,$DE
;      		.db	$81,$3F,$F0,$05
;      		.db	$FE,$C0,$E7,$E0
;      		.db	$07,$7C,$C6,$47
;      		.db	$E0,$F1,$7C,$C0
;      		.db	$0F,$FC,$81,$3F
;      		.db	$90,$0F,$BF,$42
;      		.db	$3C,$3E,$5C,$F0
;      		.db	$17,$1E,$1C,$3F
;      		.db	$7C,$E0,$07,$8F
;      		.db	$C6,$57,$A0,$27
;      		.db	$6F,$09,$1C,$FF
;      		.db	$03,$0E,$7F,$1C
;      		.db	$85,$FA,$E1,$71
;      		.db	$E0,$2B,$0F,$1E
;      		.db	$9E,$AB,$70,$F8
;      		.db	$C1,$07,$87,$FB
;      		.db	$30,$3C,$C8,$1F
;      		.db	$F0,$E1,$E1,$1C
;      		.db	$1E,$FC,$C0,$EB
;      		.db	$B0,$0E,$DE,$C1
;      		.db	$3D,$E0,$1F,$F0
;      		.db	$83,$4F,$70,$1F
;      		.db	$1E,$0F,$FE,$C1
;      		.db	$03,$7C,$1E,$8E
;      		.db	$C3,$57,$F0,$38
;      		.db	$3E,$04,$8F,$E3
;      		.db	$07,$F8,$98,$BE
;      		.db	$C0,$2F,$78,$F0
;      		.db	$0E,$8D,$0F,$F8
;      		.db	$03,$FF,$00,$7F
;      		.db	$E0,$27,$F8,$03
;      		.db	$AF,$E0,$79,$38
;      		.db	$0E,$5F,$E1,$63
;      		.db	$F0,$07,$7E,$81
;      		.db	$BF,$E0,$17,$F8
;      		.db	$E1,$71,$E0,$57
;      		.db	$AC,$03,$9F,$53
;      		.db	$78,$F0,$C1,$27
;      		.db	$E0,$07,$3E,$05
;      		.db	$3F,$F8,$15,$F8
;      		.db	$C0,$3F,$80,$A7
;      		.db	$F9,$41,$3E,$F8
;      		.db	$02,$5F,$C1,$E7
;      		.db	$F0,$03,$FE,$80
;      		.db	$3F,$E0,$17,$F8
;      		.db	$02,$7F,$E0,$07
;      		.db	$7E,$0C,$1F,$3C
;      		.db	$7C,$F0,$E1,$C1
;      		.db	$87,$0F,$3E,$78
;      		.db	$7C,$E0,$E1,$F0
;      		.db	$07,$1E,$1E,$1F
;      		.db	$F8,$E1,$78,$80
;      		.db	$3F,$D8,$83,$FB
;      		.db	$81,$0E,$9F,$87
;      		.db	$A1,$77,$F4,$81
;      		.db	$07,$3F,$E0,$87
;      		.db	$56,$F8,$E0,$F1
;      		.db	$82,$8F,$0F,$17
;      		.db	$E3,$1B,$F8,$E0
;      		.db	$F1,$03,$EF,$C0
;      		.db	$1F,$F8,$30,$1F
;      		.db	$78,$7C,$80,$0F
;      		.db	$FE,$80,$4F,$74
;      		.db	$78,$F8,$03,$1F
;      		.db	$0F,$E3,$E1,$1F
;      		.db	$F8,$10,$7F,$E0
;      		.db	$07,$7E,$05,$E3
;      		.db	$83
;ut2_caw_end      		

ut2_tiger1_beg    .db   $0F,$B1
      		.db	$14,$91,$BA,$FF
      		.db	$56,$0A,$20,$B4
      		.db	$DD,$7D,$2B,$42
      		.db	$C0,$54,$F7,$7F
      		.db	$A8,$96,$00,$A9
      		.db	$ED,$FD,$0D,$A8
      		.db	$84,$D0,$7E,$FB
      		.db	$2E,$C0,$25,$48
      		.db	$FD,$0F,$D8,$17
      		.db	$80,$FF,$02,$F5
      		.db	$9F,$80,$5F,$01
      		.db	$F9,$17,$D0,$7E
      		.db	$05,$DC,$0B,$F4
      		.db	$D4,$BE,$0A,$E0
      		.db	$1F,$F0,$17,$A4
      		.db	$FD,$E0,$D0,$2B
      		.db	$90,$FA,$0F,$0E
      		.db	$F9,$1B,$A0,$5F
      		.db	$E0,$17,$52,$FF
      		.db	$02,$6A,$AF,$02
      		.db	$AF,$90,$FE,$A2
      		.db	$7A,$0B,$F0,$8A
      		.db	$50,$FF,$03,$FE
      		.db	$02,$F4,$17,$F0
      		.db	$2B,$D0,$2F,$24
      		.db	$FB,$0B,$E8,$17
      		.db	$E8,$97,$40,$7F
      		.db	$41,$BF,$01,$F4
      		.db	$17,$C8,$3F,$50
      		.db	$EF,$12,$E0,$2F
      		.db	$A1,$FA,$07,$74
      		.db	$0B,$A1,$BF,$48
      		.db	$FB,$06,$2E,$20
      		.db	$FF,$50,$77,$93
      		.db	$12,$91,$EA,$1F
      		.db	$B5,$AB,$40,$48
      		.db	$D5,$FD,$2F,$AA
      		.db	$04,$A0,$FF,$44
      		.db	$ED,$5B,$01,$03
      		.db	$F4,$1F,$D8,$1F
      		.db	$D0,$0F,$D0,$3F
      		.db	$90,$BF,$02,$7E
      		.db	$01,$7F,$82,$FA
      		.db	$0B,$F8,$82,$F4
      		.db	$07,$FA,$0D,$F8
      		.db	$05,$E9,$0F,$EC
      		.db	$4D,$40,$BF,$50
      		.db	$7F,$41,$2F,$C0
      		.db	$3F,$48,$FD,$16
      		.db	$E0,$2B,$A2,$5E
      		.db	$DD,$15,$C0,$07
      		.db	$FD,$0B,$F4,$27
      		.db	$F8,$02,$F5,$83
      		.db	$FA,$15,$F0,$83
      		.db	$F4,$53,$5B,$01
      		.db	$7E,$21,$F5,$43
      		.db	$6F,$02,$F4,$07
      		.db	$ED,$17,$F0,$45
      		.db	$A8,$FE,$02,$7F
      		.db	$02,$BF,$80,$FA
      		.db	$83,$DE,$25,$50
      		.db	$B7,$D2,$BE,$01
      		.db	$AD,$00,$FF,$42
      		.db	$FF,$05,$E8,$03
      		.db	$FA,$B0,$2F,$B8
      		.db	$22,$55,$DB,$3F
      		.db	$A0,$17,$C0,$87
      		.db	$FA,$A7,$AA,$40
      		.db	$B9,$5A,$FB,$16
      		.db	$C0,$87,$0A,$AF
      		.db	$EE,$6F,$80,$17
      		.db	$A0,$FE,$0B,$D0
      		.db	$5F,$E0,$A4,$EA
      		.db	$5F,$C1,$30,$7E
      		.db	$01,$F5,$1F,$E0
      		.db	$17,$50,$7F,$C0
      		.db	$5F,$40,$7F,$A0
      		.db	$1F,$E8,$5E,$01
      		.db	$7E,$A8,$7E,$D0
      		.db	$AD,$10,$F8,$A5
      		.db	$EA,$0F,$F4,$02
      		.db	$F8,$0B,$F5,$B6
      		.db	$95,$00,$BF,$12
      		.db	$75,$5B,$B7,$12
      		.db	$00,$7F,$A8,$7F
      		.db	$05,$DC,$F0,$83
      		.db	$07,$E8,$BF,$80
      		.db	$FA,$1B,$14,$AA
      		.db	$FD,$0B,$C0,$BF
      		.db	$02,$FA,$0B,$F8
      		.db	$0B,$D4,$AF,$80
      		.db	$FE,$02,$F5,$5B
      		.db	$80,$97,$D4,$FE
      		.db	$02,$7C,$05,$F4
      		.db	$07,$F5,$43,$DB
      		.db	$00,$FE,$A0,$5F
      		.db	$A0,$F6,$2B,$60
      		.db	$51,$FF,$16,$A0
      		.db	$EF,$12,$B0,$7A
      		.db	$7D,$4B,$00,$FD
      		.db	$B6,$02,$F8,$17
      		.db	$7A,$1F,$C0,$2F
      		.db	$20,$FF,$02,$FA
      		.db	$1B,$C0,$4F,$E8
      		.db	$F3,$70,$C0,$6F
      		.db	$08,$F5,$17,$E8
      		.db	$57,$D0,$13,$D2
      		.db	$7F,$05,$E8,$AF
      		.db	$80,$7E,$90,$BF
      		.db	$02,$F2,$AF,$60
      		.db	$A4,$FE,$05,$FA
      		.db	$02,$7D,$11,$E9
      		.db	$5F,$40,$BF,$05
      		.db	$F0,$07,$E9,$5F
      		.db	$C0,$5F,$C0,$9F
      		.db	$A0,$7E,$05,$E1
      		.db	$8B,$FA,$05,$DA
      		.db	$9B,$00,$7F,$A1
      		.db	$0F,$B7,$4D,$C0
      		.db	$47,$54,$FF,$02
      		.db	$D4,$5F,$01,$55
      		.db	$ED,$EF,$02,$C0
      		.db	$BF,$02,$E9,$FE
      		.db	$0A,$20,$FF,$05
      		.db	$E8,$2F,$50,$7F
      		.db	$81,$15,$D5,$5F
      		.db	$A0,$B7,$10,$54
      		.db	$FF,$05,$B4
ut2_tiger1_end      		
ut2_tiger2_beg    .db   $B4
      		.db	$B7,$54,$08,$6A
      		.db	$FF,$97,$08,$E8
      		.db	$BF,$00,$FF,$02
      		.db	$FA,$15,$70,$FD
      		.db	$40,$ED,$55,$81
      		.db	$A4,$ED,$7E,$4B
      		.db	$22,$08,$EA,$BF
      		.db	$D0,$DE,$AA,$00
      		.db	$E0,$1F,$EA,$5F
      		.db	$A0,$4F,$40,$7F
      		.db	$90,$FD,$01,$FA
      		.db	$09,$D4,$1F,$E8
      		.db	$AF,$C0,$47,$A8
      		.db	$FD,$05,$D0,$5F
      		.db	$A0,$1F,$E8,$2F
      		.db	$E0,$C7,$26,$A1
      		.db	$DA,$F7,$02,$F4
      		.db	$05,$F8,$4F,$A0
      		.db	$BF,$80,$7D,$13
      		.db	$38,$A9,$FE,$4D
      		.db	$80,$BF,$80,$7F
      		.db	$C0,$5F,$90,$DA
      		.db	$97,$0A,$41,$FD
      		.db	$83,$EC,$57,$E0
      		.db	$22,$EA,$5F,$40
      		.db	$7F,$A8,$8D,$A0
      		.db	$FA,$1F,$C0,$5F
      		.db	$81,$49,$FD,$17
      		.db	$A0,$5F,$80,$BF
      		.db	$A0,$DE,$2E,$01
      		.db	$D2,$FE,$03,$B4
      		.db	$5F,$80,$BF,$40
      		.db	$7F,$A0,$DF,$08
      		.db	$F4,$17,$D0,$5F
      		.db	$40,$7F,$01,$FB
      		.db	$05,$FA,$05,$7A
      		.db	$E8,$5E,$01,$3A
      		.db	$F5,$BB,$00,$72
      		.db	$BF,$12,$22,$AD
      		.db	$FF,$02,$FC,$0A
      		.db	$FC,$84,$F4,$5F
      		.db	$80,$BF,$80,$FC
      		.db	$2B,$F0,$13,$D4
      		.db	$5F,$40,$BF,$02
      		.db	$FE,$02,$F5,$17
      		.db	$E8,$17,$E0,$0F
      		.db	$52,$7F,$C0,$3D
      		.db	$01,$FD,$05,$D5
      		.db	$5F,$C0,$2F,$C0
      		.db	$7E,$81,$FA,$0B
      		.db	$F8,$25,$48,$FF
      		.db	$80,$FA,$42,$5F
      		.db	$08,$D5,$7F,$01
      		.db	$DA,$47,$2B,$10
      		.db	$FF,$41,$FD,$2A
      		.db	$40,$BF,$C0,$5F
      		.db	$01,$FD,$2D,$80
      		.db	$3E,$47,$ED,$0D
      		.db	$E0,$2D,$D0,$3F
      		.db	$A8,$7E,$03,$75
      		.db	$02,$ED,$A3,$DD
      		.db	$02,$F4,$97,$90
      		.db	$DA,$7D,$55,$00
      		.db	$FC,$83,$FC,$17
      		.db	$D0,$BE,$00,$6F
      		.db	$A8,$DF,$02,$F0
      		.db	$2F,$50,$7F,$A0
      		.db	$5F,$A0,$8B,$D4
      		.db	$FB,$4A,$00,$FD
      		.db	$2B,$48,$B5,$BF
      		.db	$02,$EC,$8B,$A0
      		.db	$FA,$5F,$40,$DF
      		.db	$12,$50,$4F,$BF
      		.db	$0B,$A0,$BF,$04
      		.db	$AA,$FF,$02,$F4
      		.db	$5B,$00,$FF,$42
      		.db	$D4,$7E,$E8,$0A
      		.db	$E0,$5F,$44,$F5
      		.db	$5E,$01,$F4,$97
      		.db	$40,$2F,$DD,$5B
      		.db	$09,$C0,$FB,$25
      		.db	$F0,$A5,$B6,$57
      		.db	$09,$80,$FE,$07
      		.db	$EA,$5F,$A0,$2F
      		.db	$84,$D4,$7F,$01
      		.db	$F5,$2D,$10,$FD
      		.db	$48,$F7,$03,$EA
      		.db	$8A,$48,$DB,$76
      		.db	$B7,$0A,$00,$F4
      		.db	$3F,$50,$FF,$09
      		.db	$E8,$17,$90,$FD
      		.db	$05,$F4,$0B,$F8
      		.db	$17,$C8,$DF,$80
      		.db	$7E,$05,$D4,$4B
      		.db	$7B,$03,$D8,$5F
      		.db	$C0,$4F,$A8,$FD
      		.db	$02,$F2,$5B,$E0
      		.db	$16,$F4,$4F,$50
      		.db	$BF,$41,$0A,$55
      		.db	$FF,$0A,$90,$FD
      		.db	$15,$48,$BA,$FE
      		.db	$15,$40,$7F,$91
      		.db	$44,$B5,$FF,$0A
      		.db	$C0,$DF,$02,$54
      		.db	$FB,$57,$02,$AA
      		.db	$7F,$A9,$04,$E8
      		.db	$BF,$40,$FD,$96
      		.db	$10,$54,$FF,$0B
      		.db	$A8,$7D,$25,$40
      		.db	$FB,$D5,$25,$A0
      		.db	$F6,$17,$A0,$AF
      		.db	$07,$5E,$84,$FA
      		.db	$2F,$E0,$D1,$5D
      		.db	$09,$A8,$FB,$69
      		.db	$01,$EA,$2F,$48
      		.db	$DF,$56,$10,$E8
      		.db	$3F,$A1,$7E,$17
      		.db	$E0,$0B,$A2,$FE
      		.db	$0B,$68,$6F,$21
      		.db	$C8,$FE,$22,$5D
      		.db	$AD,$2A,$80,$EA
      		.db	$FF,$02,$D4,$BB
      		.db	$12,$40,$7F,$E8
      		.db	$6F,$01,$F8,$57
      		.db	$E0,$8D,$EC,$5B
      		.db	$00,$7E,$0B,$D4
      		.db	$BF,$C0,$DB,$00
      		.db	$1F,$1F,$7C,$19
      		.db	$D8,$87,$48,$FF
      		.db	$0A,$A4,$F7,$4A
      		.db	$80,$FA,$07,$EA
      		.db	$2F,$50,$ED,$42
      		.db	$54,$FF,$81,$EE
      		.db	$02,$F8,$0B,$D4
      		.db	$BF,$80,$7E,$13
      		.db	$D0,$BF,$C0,$4B
      		.db	$A1,$5F,$50,$BF
      		.db	$80,$FC,$15,$E8
      		.db	$2F,$D0,$FA,$E1
      		.db	$00,$FB,$56,$10
      		.db	$75,$F5,$2F,$01
      		.db	$7B,$15,$F0,$95
      		.db	$54,$7F,$0B,$50
      		.db	$BB,$04,$A9,$FF
      		.db	$0B,$3C,$81,$FE
      		.db	$09,$54,$EF,$2B
      		.db	$80,$FE,$01,$F5
      		.db	$17,$F0,$5B,$20
      		.db	$F5,$3B,$01,$ED
      		.db	$57,$88,$AA,$DD
      		.db	$57,$01,$E8,$1F
      		.db	$90,$FE,$C1,$6D
      		.db	$09,$42,$EF,$17
      		.db	$90,$FD,$15,$82
      		.db	$F4,$F7,$02,$A8
      		.db	$7F,$01,$69,$7F
      		.db	$05,$A8,$FE,$55
      		.db	$40,$F5,$6F,$01
      		.db	$72,$BF,$00,$F5
      		.db	$2F,$01,$F5,$AF
      		.db	$00,$F5,$B7,$00
      		.db	$D5,$BF,$80,$D4
      		.db	$6F,$05,$D0,$BF
      		.db	$A0,$76,$17,$AA
      		.db	$A4,$D0,$DD,$B7
      		.db	$02,$54,$7F,$05
      		.db	$50,$DF,$9B,$80
      		.db	$EA,$5F,$02,$7B
      		.db	$AB,$00,$B2,$FF
      		.db	$02,$A9,$EF,$2A
      		.db	$00,$F5,$DF,$12
      		.db	$A8,$7D,$97,$04
      		.db	$60,$FF,$15,$29
      		.db	$DD,$2B,$11,$54
      		.db	$AA,$75,$FF,$56
      		.db	$88,$04,$F6,$2A
      		.db	$A5,$7E,$2F,$A1
      		.db	$02,$F6,$AF,$08
      		.db	$A9,$FE,$AA,$50
      		.db	$AB,$55,$24,$49
      		.db	$69,$FF,$AD,$0B
      		.db	$40,$5A,$15,$A9
      		.db	$EE,$5F,$8B,$0A
      		.db	$5C,$04,$DA,$BE
      		.db	$B7,$AA,$55,$82
      		.db	$40,$54,$F7,$EF
      		.db	$6D,$AB,$00,$01
      		.db	$A2,$F6,$FE,$97
      		.db	$52,$45,$12,$41
      		.db	$DA,$FF,$57,$04
      		.db	$D4,$5D,$84,$DA
      		.db	$2B,$B5,$92,$DE
      		.db	$2E,$2A,$44,$4B
      		.db	$24,$DD,$EF,$2A
      		.db	$55,$55,$04,$25
      		.db	$B5,$7E,$7F,$91
      		.db	$52,$15,$00,$D4
      		.db	$FD,$57,$49,$DB
      		.db	$2A,$40,$AA,$F6
      		.db	$6E,$DB,$6A,$55
      		.db	$02,$00,$A8,$DF
      		.db	$BB,$6D,$B7,$8A
      		.db	$00,$90,$ED,$BD
      		.db	$B5,$AD,$42,$20
      		.db	$52,$DA,$DE,$BF
      		.db	$55,$4A,$24,$25
      		.db	$09,$D9,$FB,$AA
      		.db	$ED,$55,$2D,$01
      		.db	$A2,$2A,$D2,$FE
      		.db	$B6,$DB,$8D,$00
      		.db	$5A,$15,$21,$B5
      		.db	$DF,$6E,$75,$25
      		.db	$A8,$4E,$10,$75
      		.db	$FB,$0B,$A0,$7F
      		.db	$05,$A4,$F6,$AD
      		.db	$8A,$54,$5D,$68
      		.db	$B5,$D5,$B6,$B7
      		.db	$09,$80,$AA,$12
      		.db	$91,$FE,$7F,$49
      		.db	$BA,$55,$51,$95
      		.db	$94,$12,$55,$55
      		.db	$F5,$EE,$DD,$12
      		.db	$08,$08,$B4,$DB
      		.db	$DD,$EF,$5D,$15
      		.db	$80,$94,$22,$AA
      		.db	$FF,$AE,$AA,$55
      		.db	$11,$88,$A8,$5A
      		.db	$FB,$7E,$6F,$4B
      		.db	$02,$11,$A1,$AA
      		.db	$D5,$EE,$FB,$8A
      		.db	$90,$5A,$01,$D2
      		.db	$BB,$52,$EA,$56
      		.db	$6B,$5B,$5D,$15
      		.db	$84,$44,$A4,$6A
      		.db	$F7,$7F,$AB,$AA
      		.db	$00,$A1,$8A,$20
      		.db	$FD,$FF,$4A,$D5
      		.db	$B5,$4A,$00,$75
      		.db	$AB,$24,$A9,$F6
      		.db	$6D,$D5,$BB,$82
      		.db	$90,$44,$94,$DA
      		.db	$FE,$B7,$AA,$DE
      		.db	$02,$48,$12,$49
      		.db	$6D,$7B,$B7,$DD
      		.db	$AD,$00,$91,$4A
      		.db	$24,$F5,$BF,$AD
      		.db	$6D,$AB,$40,$92
      		.db	$44,$48,$ED,$DF
      		.db	$AA,$DE,$AA,$20
      		.db	$55,$85,$A0,$7F
      		.db	$55,$DA,$AE,$4A
      		.db	$35,$44,$52,$AA
      		.db	$AD,$AE,$6D,$6F
      		.db	$81,$50,$AB,$A4
      		.db	$D4,$DF,$AA,$AD
      		.db	$80,$94,$4A,$54
      		.db	$5B,$BD,$F7,$56
      		.db	$55,$15,$24,$51
      		.db	$42,$74,$BF,$A2
      		.db	$BE,$95,$A0,$BE
      		.db	$15,$24,$ED,$AD
      		.db	$22,$55,$7B,$15
      		.db	$75,$2B,$28,$6D
      		.db	$15,$A4,$D6,$4A
ut2_tiger2_end      
		
;ut2_tiger3_beg    .db	$75,$A5,$AA,$87
;      		.db	$AA,$AE,$AA,$A8
;      		.db	$D4,$D7,$55,$54
;      		.db	$55,$AD,$4A,$55
;      		.db	$45,$A9,$5A,$FA
;      		.db	$E8,$AB,$05,$5D
;      		.db	$5A,$92,$50,$DB
;      		.db	$17,$55,$BD,$8A
;      		.db	$E8,$AE,$90,$FA
;      		.db	$6F,$01,$AA,$1E
;      		.db	$50,$EA,$EB,$8A
;      		.db	$57,$B7,$54,$68
;      		.db	$FD,$05,$42,$D5
;      		.db	$1E,$80,$BE,$75
;      		.db	$A2,$E8,$97,$0B
;      		.db	$7E,$F8,$F1,$01
;      		.db	$0B,$3F,$5A,$E0
;      		.db	$E2,$C3,$0A,$0B
;      		.db	$FE,$BB,$80,$EA
;      		.db	$7F,$11,$E8,$7B
;      		.db	$81,$00,$FD,$55
;      		.db	$80,$F6,$2F,$A4
;      		.db	$7E,$5B,$51,$55
;      		.db	$03,$F8,$35,$80
;      		.db	$F5,$7F,$80,$FA
;      		.db	$57,$A0,$BA,$55
;      		.db	$00,$FD,$95,$00
;      		.db	$FA,$7F,$08,$FA
;      		.db	$D3,$AA,$02,$78
;      		.db	$FD,$0F,$00,$FE
;      		.db	$AE,$10,$D2,$FE
;      		.db	$05,$48,$56,$AE
;      		.db	$FE,$5B,$49,$2F
;      		.db	$80,$D4,$57,$0B
;      		.db	$D1,$F7,$0B,$A0
;      		.db	$FE,$10,$C0,$FF
;      		.db	$03,$96,$7F,$1C
;      		.db	$F0,$A1,$83,$8A
;      		.db	$5D,$2E,$F4,$7E
;      		.db	$F0,$A3,$03,$00
;      		.db	$FF,$17,$00,$FF
;      		.db	$1F,$00,$FA,$FF
;      		.db	$24,$40,$FD,$85
;      		.db	$A8,$F4,$DF,$02
;      		.db	$20,$FA,$EF,$01
;      		.db	$A2,$5F,$3F,$40
;      		.db	$F8,$B3,$83,$1B
;      		.db	$2E,$F8,$74,$41
;      		.db	$5F,$7A,$C0,$C0
;      		.db	$8F,$0F,$7E,$FF
;      		.db	$02,$00,$FF,$2F
;      		.db	$00,$D4,$FF,$02
;      		.db	$A0,$FE,$1F,$80
;      		.db	$FD,$57,$00,$54
;      		.db	$7B,$F1,$E7,$01
;      		.db	$04,$FF,$3F,$00
;      		.db	$EA,$7F,$00,$E8
;      		.db	$FF,$03,$00,$FF
;      		.db	$3D,$00,$D3,$FF
;      		.db	$16,$00,$F5,$BF
;      		.db	$00,$B4,$FF,$03
;      		.db	$00,$FF,$1F,$80
;      		.db	$FE,$77,$00,$D0
;      		.db	$FF,$28,$80,$AF
;      		.db	$3F,$0A,$7C,$FD
;      		.db	$80,$F0,$03,$7F
;      		.db	$5F,$00,$F0,$7F
;      		.db	$02,$FC,$1F,$08
;      		.db	$BE,$FA,$81,$D0
;      		.db	$57,$16,$E0,$EF
;      		.db	$07,$40,$FF,$23
;      		.db	$C0,$CF,$5E,$6E
;      		.db	$00,$61,$FF,$03
;      		.db	$E0,$FF,$00,$D0
;      		.db	$FF,$07,$80,$FD
;      		.db	$2B,$80,$DE,$FF
;      		.db	$38,$80,$E5,$07
;      		.db	$56,$F8,$EF,$02
;      		.db	$00,$FF,$3F,$00
;      		.db	$FC,$DF,$02,$10
;      		.db	$FF,$5F,$00,$E8
;      		.db	$3F,$80,$FA,$3F
;      		.db	$00,$FA,$D5,$03
;      		.db	$A5,$FE,$07,$00
;      		.db	$FE,$3F,$00,$FA
;      		.db	$8F,$06,$7D,$09
;      		.db	$D5,$0F,$3C,$E0
;      		.db	$F4,$FD,$01,$40
;      		.db	$FF,$0F,$C0,$F4
;      		.db	$AF,$02,$B0,$FE
;      		.db	$2F,$01,$F0,$DF
;      		.db	$02,$58,$FD,$97
;      		.db	$00,$F8,$BF,$08
;      		.db	$FA,$AE,$80,$8A
;      		.db	$F6,$FF,$02,$80
;      		.db	$FF,$0F,$00,$FE
;      		.db	$3F,$00,$FC,$3F
;      		.db	$00,$F8,$BF,$01
;      		.db	$F0,$FF,$01,$A0
;      		.db	$FF,$17,$00,$FE
;      		.db	$1B,$00,$F2,$FF
;      		.db	$02,$50,$FE,$67
;      		.db	$80,$7B,$9B,$42
;      		.db	$C8,$DF,$0A,$C2
;      		.db	$BB,$06,$AC,$BE
;      		.db	$50,$BD,$27,$20
;      		.db	$F6,$FA,$4B,$01
;      		.db	$D0,$FF,$0B,$C0
;      		.db	$7F,$29,$C0,$EE
;      		.db	$AD,$BA,$00,$6C
;      		.db	$DF,$00,$D5,$FF
;      		.db	$03,$00,$DC,$7F
;      		.db	$01,$FC,$7F,$01
;      		.db	$C0,$FF,$03,$C0
;      		.db	$7F,$0B,$80,$BF
;      		.db	$7E,$50,$F0,$E5
;      		.db	$04,$EA,$FF,$09
;      		.db	$80,$7F,$17,$80
;      		.db	$FE,$B5,$84,$D0
;      		.db	$5F,$2E,$A8,$F0
;      		.db	$BF,$00,$D4,$EA
;      		.db	$0F,$06,$7F,$3F
;      		.db	$00,$FC,$2B,$00
;      		.db	$FE,$6F,$41,$A5
;      		.db	$83,$AD,$3F,$49
;      		.db	$D0,$AB,$26,$22
;      		.db	$F8,$FF,$03,$80
;      		.db	$F7,$06,$D4,$7F
;      		.db	$11,$50,$AF,$6A
;      		.db	$FA,$5F,$04,$E0
;      		.db	$8E,$6F,$40,$FA
;      		.db	$57,$02,$D0,$7F
;      		.db	$08,$F6,$53,$09
;      		.db	$D4,$FF,$54,$40
;      		.db	$F7,$13,$00,$FF
;      		.db	$17,$85,$4F,$0E
;      		.db	$7E,$29,$80,$F7
;      		.db	$4F,$00,$FC,$7E
;      		.db	$50,$E1,$5F,$01
;      		.db	$AE,$3F,$04,$E0
;      		.db	$FF,$03,$C0,$FF
;      		.db	$0B,$80,$FF,$A5
;      		.db	$80,$7A,$6F,$00
;      		.db	$C8,$FF,$0F,$00
;      		.db	$FF,$2A,$A1,$B0
;      		.db	$FF,$55,$00,$F8
;      		.db	$FF,$00,$F8,$BF
;      		.db	$01,$C0,$FE,$57
;      		.db	$80,$EA,$9B,$42
;      		.db	$F2,$CD,$87,$86
;      		.db	$2E,$4C,$F5,$AC
;      		.db	$D6,$14,$B4,$FE
;      		.db	$00,$C0,$FF,$27
;      		.db	$A8,$5B,$71,$8B
;      		.db	$14,$E5,$85,$1E
;      		.db	$5D,$2E,$A0,$FE
;      		.db	$7F,$10,$D0,$FE
;      		.db	$02,$A0,$6B,$BB
;      		.db	$AA,$FC,$85,$00
;      		.db	$B7,$3F,$00,$FC
;      		.db	$7F,$00,$E8,$7F
;      		.db	$04,$74,$F7,$4A
;      		.db	$00,$B5,$FF,$05
;      		.db	$F4,$7E,$02,$C0
;      		.db	$FF,$07,$48,$3F
;      		.db	$2D,$50,$55,$AD
;      		.db	$BF,$08,$AA,$36
;      		.db	$35,$F5,$BE,$00
;      		.db	$C2,$7B,$D1,$C5
;      		.db	$C5,$EA,$AF,$00
;      		.db	$E8,$FF,$01,$80
;      		.db	$FF,$4A,$C8,$6F
;      		.db	$1B,$86,$38,$FA
;      		.db	$79,$20,$61,$BF
;      		.db	$42,$4A,$FF,$17
;      		.db	$00,$FA,$17,$08
;      		.db	$FF,$16,$C0,$FE
;      		.db	$05,$D2,$FF,$05
;      		.db	$00,$FB,$07,$A0
;      		.db	$FE,$17,$40,$FA
;      		.db	$AB,$AA,$DD,$55
;      		.db	$80,$D8,$57,$28
;      		.db	$AF,$AD,$48,$70
;      		.db	$A5,$EA,$AF,$9B
;      		.db	$00,$F0,$BF,$00
;      		.db	$F8,$FF,$02,$E8
;      		.db	$6B,$85,$6E,$5B
;      		.db	$52,$2A,$40,$AB
;      		.db	$2F,$BA,$96,$1A
;      		.db	$2A,$79,$FF,$02
;      		.db	$5F,$2D,$00,$F4
;      		.db	$5F,$41,$BF,$48
;      		.db	$EA,$A4,$A2,$AF
;      		.db	$17,$A8,$AA,$00
;      		.db	$FE,$7F,$01,$F0
;      		.db	$7F,$01,$C0,$FE
;      		.db	$1F,$20,$F5,$96
;      		.db	$94,$68,$F5,$A1
;      		.db	$42,$E7,$1A,$D4
;      		.db	$FF,$22,$A9,$57
;      		.db	$11,$25,$F8,$7E
;      		.db	$01,$E0,$FF,$0A
;      		.db	$F4,$2E,$81,$D6
;      		.db	$1E,$7A,$75,$A0
;      		.db	$D2,$57,$4D,$75
;      		.db	$B7,$02,$00,$EE
;      		.db	$1E,$82,$F7,$4F
;      		.db	$12,$2F,$BD,$7E
;      		.db	$28,$60,$F5,$15
;      		.db	$02,$F4,$FF,$02
;      		.db	$A0,$FF,$0F,$10
;      		.db	$FA,$BD,$20,$61
;      		.db	$BF,$25,$C0,$DA
;      		.db	$DB,$95,$95,$9A
;      		.db	$12,$92,$F6,$2D
;      		.db	$B5,$AA,$80,$E8
;      		.db	$DF,$AA,$F0,$97
;      		.db	$03,$48,$7F,$2B
;      		.db	$A8,$5B,$15,$49
;      		.db	$2D,$F2,$BD,$00
;      		.db	$E8,$DF,$0B,$F4
;      		.db	$AF,$42,$92,$CA
;      		.db	$2D,$36,$FA,$A8
;      		.db	$80,$FA,$AF,$44
;      		.db	$B7,$02,$24,$6B
;      		.db	$6F,$1D,$12,$7D
;      		.db	$3B,$A8,$FF,$87
;      		.db	$20,$A4,$A2,$B6
;      		.db	$12,$88,$F7,$AB
;      		.db	$44,$FF,$AF,$80
;      		.db	$D4,$AA,$41,$55
;      		.db	$3F,$24,$50,$FD
;      		.db	$B7,$20,$EB,$16
;      		.db	$02,$EC,$FA,$90
;      		.db	$EB,$2E,$48,$B9
;      		.db	$EF,$4A,$55,$11
;      		.db	$42,$B5,$44,$FD
;      		.db	$7F,$00,$C9,$7F
;      		.db	$23,$B6,$5B,$00
;      		.db	$64,$B5,$52,$AF
;      		.db	$57,$8C,$FA,$7A
;      		.db	$75,$49,$15,$02
;      		.db	$A0,$AD,$AD,$16
;      		.db	$6F,$5F,$5A,$6D
;      		.db	$7F,$11,$A2,$8A
;      		.db	$04,$A0,$FF,$0B
;      		.db	$A0,$F7,$5F,$09
;      		.db	$BD,$5D,$04,$A4
;      		.db	$B6,$2B,$48,$E8
;      		.db	$CF,$02,$ED,$FF
;      		.db	$0B,$40,$ED,$16
;      		.db	$20,$FA,$6B,$85
;      		.db	$3A,$AA,$D9,$EA
;      		.db	$B5,$47,$21,$CA
;      		.db	$42,$A2,$EB,$97
;      		.db	$85,$AE,$9E,$5A
;      		.db	$BA,$5A,$40,$94
;      		.db	$D6,$46,$A8,$FF
;      		.db	$0F,$02,$FD,$7F
;      		.db	$09,$A4,$2A,$84
;      		.db	$94,$DA,$BF,$12
;      		.db	$94,$FE,$5E,$B4
;      		.db	$F7,$4A,$00,$A2
;      		.db	$AA,$AA,$D4,$CA
;      		.db	$2E,$DB,$DE,$DD
;      		.db	$2A,$02,$A9,$2A
;      		.db	$21,$A2,$BF,$06
;      		.db	$91,$BD,$FF,$55
;      		.db	$82,$BA,$0B,$00
;      		.db	$FA,$57,$91,$84
;      		.db	$5F,$AB,$4A,$DE
;      		.db	$BD,$11,$A4,$56
;      		.db	$89,$A8,$BD,$2E
;      		.db	$F1,$F6,$52,$80
;      		.db	$F5,$B7,$82,$AA
;      		.db	$2A,$41,$54,$BF
;      		.db	$7B,$D4,$EA,$42
;      		.db	$69,$DB,$AA,$0A
;      		.db	$21,$92,$A4,$A2
;      		.db	$F7,$AB,$BE,$5B
;      		.db	$28,$F5,$7F,$05
;      		.db	$24,$25,$81,$A0
;      		.db	$ED,$57,$15,$B5
;      		.db	$DE,$BE,$AD,$B6
;      		.db	$2D,$00,$A0,$6A
;      		.db	$52,$A9,$D5,$AA
;      		.db	$B7,$6B,$AB,$56
;      		.db	$5D,$29,$A4,$20
;      		.db	$48,$55,$AD,$6A
;      		.db	$5F,$7D,$5D,$52
;      		.db	$E8,$6B,$0B,$55
;      		.db	$09,$50,$49,$25
;      		.db	$DD,$B7,$2A,$FE
;      		.db	$5B,$04,$7D,$6F
;      		.db	$24,$22,$49,$52
;      		.db	$91,$52,$FB,$53
;      		.db	$D5,$5F,$55,$DB
;      		.db	$5E,$49,$24,$00
;      		.db	$A5,$0A,$D4,$EA
;      		.db	$AF,$56,$DD,$FE
;      		.db	$5B,$09,$75,$21
;      		.db	$20,$2A,$49,$55
;      		.db	$5A,$BD,$FA,$7A
;      		.db	$FD,$B5,$52,$55
;      		.db	$24,$88,$A4,$44
;      		.db	$91,$AA,$7B,$D7
;      		.db	$AB,$9D,$B7,$5D
;      		.db	$2A,$15,$22,$A8
;      		.db	$94,$A8,$DA,$EA
;      		.db	$15,$AA,$FE,$5F
;      		.db	$82,$FA,$2A,$20
;      		.db	$A9,$55,$92,$54
;      		.db	$FB,$57,$0B,$3F
;      		.db	$B5,$A0,$76,$55
;      		.db	$A8,$14,$21,$A9
;      		.db	$55,$D5,$F7,$DD
;      		.db	$52,$B1,$DB,$4A
;      		.db	$A4,$52,$04,$41
;      		.db	$AA,$2A,$D5,$7D
;      		.db	$DB,$FA,$AB,$97
;      		.db	$AA,$A4,$82,$42
;      		.db	$22,$45,$24,$55
;      		.db	$AD,$FD,$7B,$5B
;      		.db	$6B,$2F,$55,$15
;      		.db	$15,$09,$82,$22
;      		.db	$45,$AA,$5E,$57
;      		.db	$ED,$EF,$56,$D5
;      		.db	$56,$4B,$49,$48
;      		.db	$11,$15,$91,$94
;      		.db	$AA,$BA,$77,$BB
;      		.db	$BB,$AD,$AA,$AA
;      		.db	$15,$8A,$44,$24
;      		.db	$49,$A5,$92,$6A
;      		.db	$FB,$D6,$6D,$DF
;      		.db	$56,$29,$AA,$2A
;      		.db	$89,$A4,$94,$94
;      		.db	$A4,$AA,$F6,$DA
;      		.db	$B6,$BB,$5A,$55
;      		.db	$AD,$2A,$49,$A2
;      		.db	$92,$A2,$52,$A5
;      		.db	$AA,$AA,$56,$DB
;      		.db	$D7,$56,$55,$6D
;      		.db	$AB,$24,$55,$55
;      		.db	$24,$4A,$55,$4A
;      		.db	$55,$55,$55,$AB
;      		.db	$AA,$B6,$AA,$7D
;      		.db	$DB,$AA,$92,$54
;      		.db	$92,$94,$24,$89
;      		.db	$14,$95,$AA,$AA
;      		.db	$B5,$55,$AD,$AA
;      		.db	$AA,$AA,$AA,$12
;      		.db	$95,$2A,$95,$8A
;      		.db	$90,$A4,$A4,$AA
;      		.db	$56,$AB,$BA,$AF
;      		.db	$B6,$AB,$B5,$56
;      		.db	$91,$52,$52,$92
;      		.db	$54
;ut2_tiger3_end      		

;*************************************************************
;* Phrase Data Strings
;*************************************************************
phrase_1		.db	$89,$8A,$70,$89,$28,$81,$02				;"You  Win! You Jungle Lord"
phrase_2		.db	$81,$82,$60,$10						;"Jungle Lord, (Trumpet)" 
phrase_3		.db	$81,$82,$28,$8D,$20,$95,$86,$87,$08			;"Jungle Lord in Double Trouble"
phrase_4		.db	$89,$30,$8D,$20,$95,$86,$87,$08			;"You in Double Trouble"
phrase_5		.db	$83,$20,$84,$0B						;"Fight Tiger Again"
phrase_6		.db	$85,$20,$90,$90,$10					;"Stampede, (trumpet)"
phrase_7		.db	$89,$40,$81,$02,						;"You Jungle Lord"
phrase_8		.db	$8E,$96,$30,$81,$02					;"Me Jungle Lord"
phrase_9		.db	$89,$8A,$A0,$83,$20,$8D,$28,$81,$0B			;"You Win! Fight in Jungle Again"
phrase_a		.db	$83,$20,$81,$20,$84,$20,$92,$95,$1D,$0A		;"Fight Jungle Tiger and Win!"
phrase_b		.db	$97,$92,$50,$89,$28,$93,$8F,$20,$81,$02		;"Can you be Jungle Lord?"
phrase_c		.db	$91,$30,$84,$20,$92,$95,$20,$93,$8F,$20,$81,$02	;"Beat Tiger and be Jungle Lord"
phrase_d		.db	$97,$92,$40,$89,$30,$83,$20,$8D,$28,$01		;"Can you fight in Jungle?"
phrase_e		.db	$10,$19							;(trumpet)

;***********************************************
;* Speech Start/End Pointers
;***********************************************
speech_data_tbl	.dw	ut_01_beg,ut_01_end	;81 - "Jungle"
			.dw 	ut_02_beg,ut_02_end	;82 - "Lord"
			.dw	ut_03_beg,ut_03_end	;83 - "Fight"
			.dw	ut_04_beg,ut_04_end	;84 - "Tiger"
			.dw	ut_05_beg,ut_05_end	;85 - "Stampede!"
			.dw	ut_06_beg,ut_06_end	;86 - "Double"
			.dw	ut_07_beg,ut_07_end	;87 - "Trou-"
			.dw	ut_08_beg,ut_08_end	;88 - "-ble"
			.dw	ut_09_beg,ut_09_end	;89 - "You"
			.dw	ut_0a_beg,ut_0a_end	;8A - "Win"
			.dw	ut_0b_beg,ut_0b_end	;8B - "Again"
			.dw	ut_0c_beg,ut_0c_end	;8C - "Can"
			.dw	ut_0d_beg,ut_0d_end	;8D - "in"
			.dw	ut_0e_beg,ut_0e_end	;8E - "M-"
			.dw	ut_0f_beg,ut_0f_end	;8F - "-e"
			.dw	ut_10_beg,ut_10_end	;90 - (trumpet)
			.dw	ut_11_beg,ut_11_end	;91 - "Beat"
			.dw	ut_12_beg,ut_12_end	;92 - "an" 
			.dw	ut_13_beg,ut_13_end	;93 - "be-"
			.dw	ut_14_beg,ut_14_end	;94 - "e"
			.dw	ut_15_beg,ut_15_end	;95 - "-d"
			.dw	ut_16_beg,ut_16_end	;96 - "-m"
			.dw	ut_17_beg,ut_17_end	;97 - "Ca"
			.dw	ut_01_beg,ut_10_end	;98 - All Speech
			.dw	ut_18_beg,ut_18_end	;99 - "Be"

;**************************************************************
;* This table indexes all phrases that can be spoken, they
;* point to the word/utterance data strings
;**************************************************************
phrase_data_ptrs	.dw	phrase_1	;01
			.dw	phrase_2	;02
			.dw	phrase_3	;03
			.dw	phrase_4	;04
			.dw	phrase_5	;05
			.dw	phrase_6	;06
			.dw	phrase_7	;07
			.dw	phrase_8	;08
			.dw	phrase_9	;09
			.dw	phrase_a	;0A
			.dw	phrase_b	;0B
			.dw	phrase_c	;0C
			.dw	phrase_d	;0D
			.dw	phrase_e	;0E

;*********************************************************
;* A Little Note
;*********************************************************	

	.text "COPYRIGHT-WILLIAMS ELECTRONICS-DOH!-JMA-"		

;**********************************************************
;* Speech Test Entry: This routine will play all speech
;*                    and then return.
;**********************************************************
speech_test
			ldx	#phrase_1-1
			bra	speech_loop

;**********************************************************
;* Speech Handler: If a command comes in that is a speech
;*                 command, then the IRQ code jumps here.
;*                 the A register contains the command.
;*			 the B register contains the next command.
;**********************************************************
speech_entry	
			;ldx	#speech_lookup-2
			staa	last_speech_cmd
			staa	sp_pending_com		;Store this for later
			anda	#$1F
			ifne					;Is this command greater than zero and less than $20?
				;asla					;times 2 for master table lookup
				;jsr	to_xplusa			;Add the offset
				;ldab	$01,X
				stab	sp_nextwordcmd		;Store the next word needed command here for now
				;ldaa	$00,X
				ldaa	last_speech_cmd
			endif
			ifne	;If there is speech, then this will be non-zero
				cli
				cmpa	#$03				;Is it command $03
				ifeq					;yes
					com	sp_phrase_tog		;Which phrase did it play last
					bmi	speech_set			;Play phrase_3
					inca					;Do phrase_4 instead
					bra	speech_set
				endif
				cmpa	#$0A				;Is it command $0A
				ifeq
					ldx	#$B000			;Point to some random data
					psha
					ldaa	semi_random			;Get a semi-random number
					begin
						inx
						jsr	to_xplusa
						ldab	$00,X
						andb	#$03				;Range from 0-3
						cmpb	sp_last_random		;Is it the same as last time, if so, try again
					neend
					pula					;Get base value
					stab	sp_last_random		;save new index for next time
					aba					;Add index to base
				endif
speech_set			asla
				ldx	#phrase_data_ptrs-2	;Load up the phrase index pointer 
				jsr	to_xplusa
				ldx	$00,X				;Point to the start of the phrase data string
				ldaa	#$C8				
				begin
					bsr	delay_150			;Delay 30ms for good measure
					deca
				eqend
speech_loop			begin
					stx	sp_phrase_ptr		;Save pointer for last half of loop
					ldaa	$00,X
					anda	#$7F
					cmpa	#$19
					bhi	delay_var			;Delay amount in data if higher than $19
					asla
					asla
					ldx	#speech_data_tbl-4	;Base of table
					jsr	to_xplusa
					stx	sp_base_ptr
					ldx	$00,X				;Get data start address
					stx	sp_start_ptr		;Save it for the speech routine
					ldx	sp_base_ptr
					ldx	$02,X				;Get data end address
					stx	sp_end_ptr			;Save it too!
					bsr	play_speech			;Play data now!!!!!!!!
sp_loop2				ldx	sp_phrase_ptr		;Get it back
					ldaa	$00,X				;Delay amount if first byte if less than $19
					cmpa	#$19
					bls	delay_75_ret		;If we were less than $19 then we are done
					inx
				loopend
			endif
			bra	sp_get_return

;***********************************************
;* Variable Delay: Can delay from 150us to 38.25ms
;***********************************************
delay_var		ldaa	$00,X
			begin
				bsr	delay_150
				deca
			eqend
			staa	last_speech_cmd
			bra	sp_loop2

;***********************************************
;* Delay 7.5ms and fall through to return
;***********************************************
delay_75_ret	ldaa	#$32
			begin
				bsr	delay_150			;Delay 150us
				deca
			eqend

;***********************************************
;* Will return last speech command or ??
;***********************************************			
sp_get_return	ldaa	last_speech_cmd
			tst	sp_pending_com			;Was speech played succesfully. 0 if yes
			ifeq
				ldaa	#$00		                  ;Yes, always return 0
			endif
			ldab	pia_sound_command
			cli
			rts
			
;***********************************************
;* Delay of 150 cycles or 150us
;***********************************************
delay_150		ldab	#$94		;2 cycles
			begin
				decb			;1 cycle
			eqend
			rts			
	
;*********************************************************
;* Play Speech Stream: Will play a stream until it is done
;*********************************************************
play_speech		ldx	sp_start_ptr
			ldaa	$00,X			;get the first speech data stream byte
			cmpa	#$AA			;Is it is not $AA, then dont play it.
			ifeq
				clr	sp_pending_com	;Indicated that speech was dumped
				inx
				ldab	#$01
sp_data_loop		ldaa	#$3F
				staa	pia_speech_clk	;Clock a 1
				anda	#$F7
				staa	pia_speech_clk	;Clock a 0
				aslb
				bne	sp_do_data		;Are we done with this byte?
				rolb				;Yes, roll the 1 back into position 1
				inx				;Increment the pointer
				cpx	sp_end_ptr		;Are we at the end?
				bne	sp_data2		;no, do shorter code
			endif
			rts
			

sp_do_data		tst	$00,X		;7 cycles
			tst	$00,X		;7 cycles
sp_data2		bra	spd2
spd2			bra	spd3
spd3			nop
			bitb	$00,X
			ifne
				ldaa	#$3C
				staa	pia_speech_data		;Send a 1
				bra	sp_data_loop
			endif
			ldaa	#$34
			staa	pia_speech_data		;Send a 0
			bra	sp_data_loop


;*********************************************************
; Grand Lizard Speech Code
;*********************************************************


___shnum = 1
___snumh = 32d	;this defines the max size of the speech handlers
___seng = $
___scsy = ___seng+(___snumh*2)

#define 	reg_speech(name,start,end)  \ .org ___seng
#defcont   \ .dw start, end
#defcont   \___seng .set ___seng+4
#defcont   \name = ___shnum
#defcont   \___shnum .set ___shnum+1
#defcont   \ .org ___scsy
#defcont   \___scsy .set ___scsy+2	

#define 	l7delay(dval)  .word ((1-(dval*435d))/10)

speech_data_tbl2		;reg_speech(ut2_cry,ut2_cry_beg,ut2_cry_end)			
				reg_speech(ut2_chrp1,ut2_chrp1_beg,ut2_chrp1_end)      	
				reg_speech(ut2_chrp2,ut2_chrp2_beg,ut2_chrp2_end)      	
				reg_speech(ut2_drum,ut2_drum_beg,ut2_drum_end)      	
				reg_speech(ut2_shriek,ut2_shriek_beg,ut2_shriek_end)      
				reg_speech(ut2_tgrowl,ut2_tgrowl_beg,ut2_tgrowl_end)          	
				;reg_speech(ut2_squawk,ut2_squawk_beg,ut2_squawk_end)      
				;reg_speech(ut2_caw,ut2_caw_beg,ut2_caw_end)      		
				reg_speech(ut2_tiger1,ut2_tiger1_beg,ut2_tiger1_end)      
				reg_speech(ut2_tiger2,ut2_tiger2_beg,ut2_tiger2_end)      
				;reg_speech(ut2_tiger3,ut2_tiger3_beg,ut2_tiger3_end)     
				reg_speech(ut_01x,ut_01_beg,ut_01_end)    
		            reg_speech(ut_02x,ut_02_beg,ut_02_end)    
		            reg_speech(ut_03x,ut_03_beg,ut_03_end)    
		            reg_speech(ut_04x,ut_04_beg,ut_04_end)    
		            reg_speech(ut_05x,ut_05_beg,ut_05_end)    
		            reg_speech(ut_06x,ut_06_beg,ut_06_end)    
		            reg_speech(ut_07x,ut_07_beg,ut_07_end)    
		            reg_speech(ut_08x,ut_08_beg,ut_08_end)    
		            reg_speech(ut_09x,ut_09_beg,ut_09_end)    
		            reg_speech(ut_0ax,ut_0a_beg,ut_0a_end)    
		            reg_speech(ut_0bx,ut_0b_beg,ut_0b_end)    
		            reg_speech(ut_0cx,ut_0c_beg,ut_0c_end)    
		            reg_speech(ut_0dx,ut_0d_beg,ut_0d_end)    
		            reg_speech(ut_0ex,ut_0e_beg,ut_0e_end)    
		            reg_speech(ut_0fx,ut_0f_beg,ut_0f_end)    
		            reg_speech(ut_10x,ut_10_beg,ut_10_end)    
		            reg_speech(ut_11x,ut_11_beg,ut_11_end)    
		            reg_speech(ut_12x,ut_12_beg,ut_12_end)    
		            reg_speech(ut_13x,ut_13_beg,ut_13_end)    
		            reg_speech(ut_14x,ut_14_beg,ut_14_end)    
		            reg_speech(ut_15x,ut_15_beg,ut_15_end)    
		            reg_speech(ut_16x,ut_16_beg,ut_16_end)    
		            reg_speech(ut_17x,ut_17_beg,ut_17_end)    
		            reg_speech(ut_18x,ut_18_beg,ut_18_end)    
		            
speech_phrases		.dw   simple_chrp1	;80
				.dw	simple_drum		;81
				.dw	simple_shriek	;82
				.dw	simple_tgrowl	;83
				.dw	simple_tiger1	;84
				.dw	simple_tiger2	;85
				.dw	monkeytune		;86
				.dw	monkey_oohooh		;87
				.dw	monkey_oohooh2		;88
				.dw	drum_beat		;89
				.dw	drum_roll1		;8a
				.dw	simple_none		;8b
				.dw	simple_none		;8c
				.dw	simple_none		;8d
				.dw	simple_none		;8e
				.dw	simple_none		;8f
				.dw	jlsp1			;90
				.dw	jlsp2			;91
				.dw	jlsp3		;92
				.dw	jlsp4		;93
				.dw	jlsp5			;94
				.dw	jlsp6			;95
				.dw	jlsp7			;96
				.dw	jlsp8			;97
				.dw	jlsp9			;98
				.dw	jlspa			;99
				.dw	jlspb			;9A
				.dw	jlspc				;9B
				.dw	jlspd				;9C
				.dw	jlspe				;9D
				.dw	simple_none			;9E
				.dw	simple_none			;9f



;*******************************************************************		
;* Phrase Structure     
;*		            
;* First Byte non-negative = Speech Item, 2nd Byte is pitch delay > $00 (smaller values, shorter delay, higher pitch)
;* First Byte negative     = Silence, 2nd byte is LSB of 2's complement value * 5us
;* First Byte Zero	   = End of Phrase
;*******************************************************************
#define	phrase_end		.dw 	$00
; Unused Phrases
; 
					

;Library of Utterances
simple_none		phrase_end	

;Shortest Chirp		      
simple_chrp1	.db	ut2_chrp1,$04
			phrase_end				

;Drum
simple_drum		.db	ut2_drum,$04
			phrase_end					

;Shriek
simple_shriek	.db	ut2_shriek,$04
			phrase_end			

;Throaty Growl
simple_tgrowl	.db	ut2_tgrowl,$04
			phrase_end								


;Tiger Start
simple_tiger1	.db	ut2_tiger1,$04
			phrase_end			

;Tiger End
simple_tiger2	.db	ut2_tiger2,$04
			phrase_end		

monkeytune		.db	ut2_chrp1,$01	
			.db	ut2_chrp1,$01
			.db	ut2_chrp1,$18
			.db	ut2_shriek,$01
			phrase_end			

monkey_oohooh	.db	ut2_chrp1,$01
			.db	ut2_chrp1,$01
			.db	ut2_chrp1,$01
			.db	ut2_chrp1,$01
			phrase_end
			
monkey_oohooh2	.db	ut2_chrp1,$01
			.db	ut2_chrp2,$01
			.db	ut2_chrp1,$01
			.db	ut2_chrp2,$01
			phrase_end	
					
tiger_norm		.db	ut2_tiger1,$04
			.db	ut2_tiger2,$04
			phrase_end	
			
tiger_slow		.db	ut2_tiger1,$18
			.db	ut2_tiger2,$18
			phrase_end	

tiger_slowest	.db	ut2_tiger1,$40   ;This is probabaly a bit too slow
			.db	ut2_tiger2,$40
			phrase_end
			
tiger_norm_x	.db	ut2_tiger1,$04
			.db	ut2_tiger1,$04
			.db	ut2_tiger2,$04
			phrase_end	
					
tiger_up		.db	ut2_tiger1,$48 
			.db	ut2_tiger1,$40 
			.db	ut2_tiger1,$38
			.db	ut2_tiger1,$30 
			.db	ut2_tiger1,$28
			.db	ut2_tiger1,$20  
			.db	ut2_tiger1,$18 
			.db	ut2_tiger1,$10 
			.db	ut2_tiger1,$0C  
			.db	ut2_tiger1,$08   
			.db	ut2_tiger1,$04       
			phrase_end
			
tiger_down		.db	ut2_tiger1,$04   
			.db	ut2_tiger1,$08
			.db	ut2_tiger1,$0C  
			.db	ut2_tiger1,$10   
			.db	ut2_tiger1,$18   
			.db	ut2_tiger1,$20 
			.db	ut2_tiger1,$28
			.db	ut2_tiger1,$30 
			.db	ut2_tiger1,$38
			.db	ut2_tiger1,$40
			.db	ut2_tiger1,$48     
			phrase_end
			
drum_beat		.db	ut2_drum,$02
			phrase_end
			
drum_roll1		.db	ut2_drum,$02
			.db	ut2_drum,$02
			.db	ut2_drum,$08
			.db	ut2_drum,$08
			phrase_end

;****************************************************************************			
;Original Jungle Lord Speech Here but converted to use the new speech engine
;****************************************************************************		
jlsp1			;"You Win! You Jungle Lord"
			.db	ut_09x,$0d
			.db	ut_0ax,$0d
			l7delay($70)
			.db	ut_09x,$0d
			l7delay($28)
			.db	ut_01x,$0d
			.db	ut_02x,$0d
			phrase_end

jlsp2			;"Jungle Lord, (Trumpet)" 
			.db	ut_01x,$0d
			.db	ut_02x,$0d
			l7delay($60)
			.db	ut_10x,$0d
			phrase_end
			
jlsp3			;"Jungle Lord in Double Trouble"
			.db	ut_01x,$0d
			.db	ut_02x,$0d
			l7delay($28)
			.db	ut_0dx,$0d
			l7delay($20)
			.db	ut_15x,$0d
			.db	ut_06x,$0d
			.db	ut_07x,$0d
			.db	ut_08x,$0d
			phrase_end
			
jlsp4			;"You in Double Trouble"
			.db	ut_09x,$0d
			l7delay($30)
			.db	ut_0dx,$0d
			l7delay($20)
			.db	ut_15x,$0d
			.db	ut_06x,$0d
			.db	ut_07x,$0d
			.db	ut_08x,$0d
			phrase_end
			
jlsp5			;"Fight Tiger Again"
			.db	ut_03x,$0d
			l7delay($20)
			.db	ut_04x,$0d
			.db	ut_0bx,$0d
			phrase_end
			
jlsp6			;"Stampede, (trumpet)"
			.db	ut_05x,$0d
			l7delay($20)
			.db	ut_10x,$0d
			.db	ut_10x,$0d
			.db	ut_10x,$0d
			phrase_end
			
jlsp7			;"You Jungle Lord"
			.db	ut_09x,$0d
			l7delay($40)
			.db	ut_01x,$0d
			.db	ut_02x,$0d
			phrase_end
			
jlsp8			;"Me Jungle Lord"
			.db	ut_0ex,$0d
			.db	ut_16x,$0d
			l7delay($30)
			.db	ut_01x,$0d
			.db	ut_02x,$0d
			phrase_end
			
jlsp9			;"You Win! Fight in Jungle Again"
			.db	ut_09x,$0d
			.db	ut_0ax,$0d
			l7delay($A0)
			.db	ut_03x,$0d
			l7delay($20)
			.db	ut_0dx,$0d
			l7delay($28)
			.db	ut_01x,$0d
			.db	ut_0bx,$0d
			phrase_end
			
jlspa			;"Fight Jungle Tiger and Win!"
			.db	ut_03x,$0d
			l7delay($20)
			.db	ut_01x,$0d
			l7delay($20)
			.db	ut_04x,$0d
			l7delay($20)
			.db	ut_12x,$0d
			.db	ut_15x,$0d
			l7delay($1D)
			.db	ut_0ax,$0d
			phrase_end
	
jlspb			;"Can you be Jungle Lord?"
			.db	ut_17x,$0d
			.db	ut_12x,$0d
			l7delay($50)
			.db	ut_09x,$0d
			l7delay($28)
			.db	ut_13x,$0d
			.db	ut_0fx,$0d
			l7delay($20)
			.db	ut_01x,$0d
			.db	ut_02x,$0d
			phrase_end

jlspc			;"Beat Tiger and be Jungle Lord"
			.db	ut_11x,$0d
			l7delay($30)
			.db	ut_04x,$0d
			l7delay($20)
			.db	ut_12x,$0d
			.db	ut_15x,$0d
			l7delay($20)
			.db	ut_13x,$0d
			.db	ut_0fx,$0d
			l7delay($20)
			.db	ut_01x,$0d
			.db	ut_02x,$0d
			phrase_end

jlspd			;"Can you fight in Jungle?"
			.db	ut_17x,$0d
			.db	ut_12x,$0d
			l7delay($40)
			.db	ut_09x,$0d
			l7delay($30)
			.db	ut_03x,$0d
			l7delay($20)
			.db	ut_0dx,$0d
			l7delay($28)
			.db	ut_01x,$0d
			phrase_end
			
jlspe			;(trumpet)
			.db	ut_10x, $0d
			l7delay($19)
			phrase_end
			
									
;*************************************************************************
;* SPEECH ROUTINES START HERE!!
;*************************************************************************

play_all_speech2
		ldx	#start_speechdata
		stx	xtemp1
		ldx	#speech_data_tbl2-6
		stx	xtemp2
		jmp	utter_start

;**************************************************************************
;* This is the main speech entry point from the sound command controller
;* 
;* Phrase number is in A
;**************************************************************************
speech2_start     ldx	#speech_phrases               ;Load up the phrase index pointer 
      		asla
      		jsr	xplusa
      		ldx	$00,x                         ;Point to the start of the phrase data string
phrase_loop       stx	sp_phrase_ptr                 ;Save pointer for last half of loop
phrase_next       ldx	sp_phrase_ptr
      		ldaa	$00,x                         ;Get command byte
      		ifne	
            		bpl	utter_load
phrase_wait             ldab	$01,x
                        begin
                              begin
                  		      tst	$00,x                   ;waste 2 cycles
                  		      tst	$00,x                   ;waste 2 cycles
                  		      incb                          ;1 cycle
                  		eqend
            		      inca
            		eqend
            		inx
            		inx
            		bra	phrase_loop
                  endif
      		inx
      		ldaa	$00,x
      		bne	phrase_wait
      		;double $00 ends phrase
      		ldx	xtemp2
      		rts      		

;**************************************************************
;* This routine will play a specific utterance at the speed
;* defined
;**************************************************************
utter_load	staa	sp_utindex              ;Utterance index
		clrb
		asla	
		asla					;A*4
		adda	#((speech_data_tbl2-4)&$FF)
		staa	xtemp1+1                ;Load speech data LSB
		adcb	#((speech_data_tbl2-4)>>8)
		stab	xtemp1                  ;Load speech data MSB
		stx	xtemp2			;Save our current X value
		ldx	xtemp1
		ldx	$02,x				;Get speech end address
		stx	sp_end_ptr
		ldx	xtemp2
		ldaa	sp_pitchload
		ifeq	
		      ldaa	$01,x
            endif
		staa	sp_currentpitch		;save the speech pitch
		inx
		inx
		stx	sp_phrase_ptr
		jsr	sp_fill_ramexec		;based on our pitch, set up the delay buffer
		ldx	xtemp1
		ldx	$00,x
		stx	xtemp1			;save the current speech data pointer at $00
		jsr	utter_start			;play the utterance loaded
		bra	phrase_next
		
;**************************************************************
;* This is the main routine for playing a complete utterance
;* It will play the utterance loaded above
;**************************************************************
utter_start
		ldx	xtemp1				;X contains the speech data byte pointer
		clrb						;clear b and set carry so that it shifts into first pos
		sec
sp_getnextbyte
		rolb						;B contains the bit that we are on as a mask
		ldaa	$00,x					;Get a fresh byte of speech data
		inx						;Point to next byte for next time
		staa	sp_currentbyte			;Save the byte for later
		ldaa	sp_currentpitch			;get the speech pitch
		ifeq
		      jmp	sploop
		endif
		
;***********************************************
;* This is the rountine that jumps to the delay
;* program in RAM. This is used to set the delay
;* between speech data bits sent to the CVSD IC.
;***********************************************
sp_delay
		jmp	delaybuf

;***********************************************
;* This routine is called always at the end of
;* the speech delay routine
;***********************************************
sp_delay_ret
		ldaa	#$37
		staa	pia_speech_clk               
		bitb	sp_currentbyte			;apply the current bit mask, if result is 0, the bit is 0, etc
		ifeq
			ldaa	#$34
			staa	pia_speech_data               ;Send a 0
			ldaa	#$3F
			staa	pia_speech_clk
			aslb
			bcs	sp_getnextbyte			;Get next data byte, this one is done being shifted
			bpl	sp_delayplus			;not done, are we at the last bit, if not, add some more time
			cpx	sp_end_ptr
			bne	sp_delay				;if not at end of speech bytes, then fall through and this will
									;end after sending a 1
			rts						;THIS IS THE WAY OUT. Only here if all speech data was sent
		endif
		ldaa	#$3C					;send a 1
		staa	pia_speech_data
		ldaa	#$3F
		staa	pia_speech_clk			;send final bits properly
		aslb
		bcs	sp_getnextbyte				;get next data byte, we are done with this one
		ifmi						;not done, are we at the last bit? If not, add some more time
			cpx	sp_end_ptr				;Are we at the end of the speech data bytes yet?
			bne	sp_delay				;branch if not
			rts						;THIS IS THE WAY OUT. Only here if all speech data was sent
		endif
sp_delayplus					;We are here for all but final bit position in speech data byte
		nop					;this is here to make these bytes take just as long as the routine
		nop					;that gets the next speech data byte.
		bra	sp_delay
		
;
sploop      begin
                  begin
                        begin
                  		ldaa	#$37
                  		staa	pia_speech_clk
                  		bitb	sp_currentbyte
                  		bne	sploopbr_1
                  		ldaa	#$34
                  		staa	pia_speech_data
                  		ldaa	#$3F
                  		staa	pia_speech_clk
                  		aslb
                  		bcs	sp_getnextbyte			;Are we done with this byte?
                  		bpl	sploopbr_2
                  		cpx	sp_end_ptr
            		loopend
            		rts
sploopbr_1
            		ldaa	#$3C
            		staa	pia_speech_data
            		ldaa	#$3F
            		staa	pia_speech_clk
            		aslb
            		bcs	sp_getnextbyte			;Are we done with this byte?
            		bpl	sploopbr_2
            		cpx	sp_end_ptr
      		loopend
      		rts
sploopbr_2
      		nop
      		nop
		loopend
;******************************************************************
; This routine takes a X byte (largest value known so far is $5B)
; buffer and it fills it with NOP commands that are the length of
; A/2, if A is odd, then something happens with the buffer data
; having a CMPA at the end for some reason.
;******************************************************************
sp_fill_ramexec
		ldx	#delaybuf
		suba	#$02					;A contains the pitch value
            begin
      		bls	sp_fill_end				;If A is less than zero, then we are done filling
      		cmpa	#$03
      		beq	sp_fill_odd				;if it ended on an $03, then put in a $91,$00
      		ldab	#$01					;this is a NOP command here
      		stab	$00,x					;put it in the buffer
      		inx
      		suba	#$02
		loopend

sp_fill_odd
		ldab	#$91
		stab	$00,x
		clr	$01,x
		inx
		inx
sp_fill_end
		ldab	#$7E					;This puts a JMP to sp_delay_ret at the end of the buffer
		stab	$00,x
		ldab	#(sp_delay_ret>>8)
		stab	$01,x
		ldab	#(sp_delay_ret&$FF)
		stab	$02,x
		rts						;return, buffer is set up properly now
		
		
;*******************************************************************
;* END OF SPEECH FOR GRAND LIZARD STUFF
;*******************************************************************
;***********************************************************
;* Required Speech Pointers
;***********************************************************
#IF *>$effa 
	.error "Speech ROM Overflow."
#ENDIF 

#IF emulate
	.org $effa
#ELSE
	.org $dffa
#ENDIF
	

speech_test_ptr		jmp speech_test
speech_entry_ptr	      jmp speech_entry

;*************************************************************************************************
;* Sound ROM Start
;*
;* Jungle Lord uses a 2716(2kx8) ROM, it is possible to expand this up to 4K if needed.
;*************************************************************************************************

.org $f800

;***************************************
;* checksum must be here for system test
;***************************************	
csum	.db	$45

swi_entry
reset
			sei
			lds	#$007F
			ldx	#$0400		;Set up the PIA
			clr	$01,X			;Clear Control Register A
			clr	$03,X			;Clear Control Register B
			ldaa	#$FF
			staa	$00,X			;Set DDRA to Outputs
			ldab	#$80
			stab	$02,X			;Set DDRB to Inputs except for PB7	
			ldaa	#$37
			staa	$03,X
			ldaa	#$3C
			staa	$01,X			;Set up CA2 and CB2 as outputs
			staa	temp1
			stab	$02,X
			clra
			staa	counter2
			staa	counter3	
			staa	bg_sec_cnt        ;Reset background sounds
			staa	counter1
			cli				;Ready for commands
			bra	$			;Stay Here forever!!!!!!!!!!!!!!!
			
;********************************************************************
;* Copy Sum based sound data to RAM
;********************************************************************
load_sum_data	tab
			asla
			asla
			asla
			aba				;Times 9
			ldx	#local_base
			stx	xtemp3
			ldx	#sum_table
			jsr	xplusa
			ldab	#$09
			jmp	copy_block		;Copy block from X to xtemp3, B bytes

;*******************************************************************
;* Play Sum Based Sound
;*******************************************************************
play_sum_snd	ldaa	sum_dac
			staa	pia_dac_out
LF848			ldaa	sum_t1_init
			staa	sum_t1_value
			ldaa	sum_t2_init
			staa	sum_t2_value
			begin
				ldx	sum_all_max
LF852				ldaa	sum_t1_value
				com	pia_dac_out
LF857				dex
				ifne
					deca
					bne	LF857
					com	pia_dac_out
					ldaa	sum_t2_value
LF862					dex
					ifne
						deca
						bne	LF862
						bra	LF852
					endif
				endif
				ldaa	pia_dac_out
				ifpl
					coma
				endif
				adda	#$00
				staa	pia_dac_out
				ldaa	sum_t1_value
				adda	sum_t1_adder
				staa	sum_t1_value
				ldaa	sum_t2_value
				adda	sum_t2_adder
				staa	sum_t2_value
				cmpa	sum_t2_max
			eqend
			ldaa	sum_t1_ext
			ifne
				adda	sum_t1_init
				staa	sum_t1_init
				bne	LF848
			endif
			rts
			
;**********************************************************
;* Simple Sounds: These take 3 params
;*
;* A:
;* B:
;* sim_adder:
;**********************************************************
simple_snd1		ldaa	#$01
			staa	sim_adder
			ldab	#$03
			bra	simple_snd

simple_snd2		ldaa	#$FF
			staa	sim_adder
			ldaa	#$60
			ldab	#$FF
			bra	simple_snd

simple_snd		staa	sim_initial
			ldaa	#$FF
			staa	pia_dac_out
			stab	sim_delay
			begin
				ldab	sim_delay
				begin
					ldaa	temp2
					lsra
					lsra
					lsra
					eora	temp2
					lsra
					ror	temp1
					ror	temp2
					ifcs
						com	pia_dac_out
					endif
					ldaa	sim_initial
					begin
						deca
					eqend
					decb
				eqend
				ldaa	sim_initial
				adda	sim_adder
				staa	sim_initial
			eqend
			rts

;****************************************************************
;* Special Sound #1
;****************************************************************			
ssnd_1		ldaa	#$20
			staa	ssnd_cycles
			staa	ssnd_flag
			ldaa	#$01
			ldx	#$0001
			ldab	#$FF
			bra	play_ssnd

play_ssnd		staa	ssnd_adder
LF8E2			stx	ssnd_period
LF8E4			stab	ssnd_dac
			ldab	ssnd_cycles
			begin
				ldaa	temp2
				lsra
				lsra
				lsra
				eora	temp2
				lsra
				ror	temp1
				ror	temp2
				ldaa	#$00
				ifcs
					ldaa	ssnd_dac
				endif
				staa	pia_dac_out
				ldx	ssnd_period
				begin
					dex
				eqend
				decb
			eqend
			ldab	ssnd_dac
			subb	ssnd_adder
			ifne
				ldx	ssnd_period
				inx
				ldaa	ssnd_flag
				beq	LF8E4
				bra	LF8E2
			endif
			rts
			
;***********************************************
;* Copy Block: Will copy data from pointer at
;*             X to pointer in xtemp3. Block is
;*             B bytes long.
;***********************************************
copy_block		psha
			begin
				ldaa	$00,X
				stx	xtemp2
				ldx	xtemp3
				staa	$00,X
				inx
				stx	xtemp3
				ldx	xtemp2
				inx
				decb
			eqend
			pula
			rts
			
;************************************************************
;* Low Resolution Sound: (Square Wave Data) 
;*
;* Inputs: None, only plays one sound
;*
;* Table Structure: Based on a string of data pairs.
;*
;*	Byte 1: Period
;*    Byte 2: Amplitude (MSB)
;*            Timer (LSB)
;************************************************************
low_res_snd		ldx	#low_res_table
			stx	lr_x_ptr
lr_loop		ldx	lr_x_ptr
			ldaa	$00,X
			ifne
				ldab	$01,X
				andb	#$F0
				stab	lr_dac
				ldab	$01,X
				inx
				inx
				stx	lr_x_ptr
				staa	lr_timer
				andb	#$0F
				begin
					ldaa	lr_dac
					staa	pia_dac_out
					ldaa	lr_timer
					begin
						ldx	#$0005
						begin
							dex
						eqend
						deca
					eqend
					clr	pia_dac_out
					ldaa	lr_timer
					begin
						ldx	#$0005
						begin
							dex
						eqend
						deca
					eqend
					decb
				eqend
				bra	lr_loop
			endif
			rts


;*********************************************************
;* Turns off All Background Sounds
;*********************************************************
kill_background	clr	bg_sec_cnt
			rts
			
;*********************************************************
;* Turns off primary backgroud, increments sec background
;*********************************************************
inc_bg_sec		ldaa	bg_sec_cnt
			anda	#$7F
			cmpa	#$1D
			ifeq
				clra
			endif
			inca
			staa	bg_sec_cnt
			rts
			

play_bg_sec		ldaa	#$0F
			jsr	load_mod_data
			ldaa	bg_sec_cnt
			asla
			asla
			coma
			jsr	LFB42
			begin
				inc	X0018
				jsr	LFB44
			loopend
			
;***************************************************************
;* Variable sum data #8
;***************************************************************
simple_inc		ldaa	#$08
			jsr	load_sum_data
			ldab	counter1
			cmpb	#$1F
			ifeq
				clrb
			endif
			incb
			stab	counter1
			ldaa	#$20
			sba
			clrb
simple_loop		cmpa	#$14
			ifgt
				addb	#$0E
				deca
				bra	simple_loop
			endif
			begin
				addb	#$05
				deca
			eqend
			stab	X0014
			begin
				jsr	play_sum_snd
			loopend
			
;****************************************************
;* Building Sound #1
;****************************************************
bsound_1		ldaa	counter2
			ifeq
				inc	counter2
				ldaa	#$0D
				jsr	load_mod_data
				jmp	play_mod_snd
			endif
			jmp	LFB37
			
;****************************************************
;* Building Sound #2
;****************************************************
bsound_2		ldaa	counter3
			ifeq
				inc	counter3
				ldaa	#$0E
				jsr	load_mod_data
				jmp	play_mod_snd
			endif
			jmp	LFB37
			
;*************************************************************
;* Modulated sound initialization routine: This will read in
;* all tables based on the index value in A and put the data
;* into the appropriate variables for sound production.
;*************************************************************
load_mod_data	tab
			aslb				;Times 7 for table lookup
			aba
			aba
			aba
			ldx	#mod_snd_tbl
			jsr	xplusa
			ldaa	$00,X
			tab
			anda	#$0F
			staa	X0015
			lsrb
			lsrb
			lsrb
			lsrb
			stab	X0014
			ldaa	$01,X
			tab
			lsrb
			lsrb
			lsrb
			lsrb
			stab	X0016
			anda	#$0F
			staa	wave_index
			stx	xtemp1
			ldx	#wavefrm_tbl
wvd_next		dec	wave_index
			ifpl
				ldaa	$00,X
				inca
				jsr	xplusa
				bra	wvd_next
			endif
			stx	X0019				;Store waveform ptr 
			jsr	copy_sweep			;Copy the Waveform data to RAM
			ldx	xtemp1
			ldaa	$02,X
			staa	X001B
			jsr	LFB90
			ldx	xtemp1
			ldaa	$03,X
			staa	X0017
			ldaa	$04,X
			staa	X0018
			ldaa	$05,X
			tab
			ldaa	$06,X				;Get index into freq sweep table
			ldx	#sweep_table
			jsr	xplusa
			tba
			stx	ptr_sweep_start		;Store start ptr to sweep data
			clr	X0024
			jsr	xplusa
			stx	ptr_sweep_end		;Store end ptr to sweep data
			rts
			
;******************************************************************
;* This routine will play the sound previously loaded into the
;* various variables.
;******************************************************************
play_mod_snd	ldaa	X0014
			staa	X0023
			begin
				ldx	ptr_sweep_start
				stx	xtemp2
LFAF6				ldx	xtemp2
				ldaa	$00,X
				adda	X0024
				staa	X0022
				cpx	ptr_sweep_end
				ifne
					ldab	X0015
					inx
					stx	xtemp2
					begin
						ldx	#$0025
						begin
							ldaa	X0022
							begin
								deca
							eqend
							ldaa	$00,X
							staa	pia_dac_out
							inx
							cpx	ptr_sweep_last
						eqend
						decb
						beq	LFAF6
						inx
						dex
						inx
						dex
						inx
						dex
						inx
						dex
						nop
						nop
					loopend
				endif
				ldaa	X0016
				bsr	LFB90
				dec	X0023
			eqend
			ldaa	counter2
			oraa	counter3
			ifeq
LFB37				ldaa	X0017
				ifne
					dec	X0018
					ifne
						adda	X0024
LFB42						staa	X0024
LFB44						ldx	ptr_sweep_start
						clrb
						begin
							ldaa	X0024
							tst	X0017
							ifpl
								adda	$00,X
								bcs	LFB5A
							else
								adda	$00,X
								beq	LFB5A
								ifcc
LFB5A									tstb
									beq	LFB65
									bra	LFB6E
								endif
							endif
							tstb
							ifeq
								stx	ptr_sweep_start
								incb
							endif
LFB65							inx
							cpx	ptr_sweep_end
						eqend
						tstb
						ifeq
							rts
						endif
LFB6E						stx	ptr_sweep_end
						ldaa	X0016
						ifne
							bsr	copy_sweep
							ldaa	X001B
							bsr	LFB90
						endif
						jmp	play_mod_snd
					endif
				endif
			endif
			rts
			
;*************************************************************************
;* This will copy the sound sweep data to RAM 
;*************************************************************************
copy_sweep		ldx	#$0025
			stx	xtemp3
			ldx	X0019
			ldab	$00,X
			inx
			jsr	copy_block		;Copy block from X to xtemp3, B bytes
			ldx	xtemp3
			stx	ptr_sweep_last			;Store away ptr to last byte 
			rts
			

LFB90			tsta
			ifne
				ldx	X0019
				stx	xtemp2
				ldx	#$0025
				staa	X0013
				begin
					stx	xtemp3
					ldx	xtemp2
					ldab	X0013
					stab	X0012
					ldab	$01,X
					lsrb
					lsrb
					lsrb
					lsrb
					inx
					stx	xtemp2
					ldx	xtemp3
					ldaa	$00,X
					begin
						sba
						dec	X0012
					eqend
					staa	$00,X
					inx
					cpx	ptr_sweep_last
				eqend
			endif
			rts

;*************************************************************
;* IRQ Entry: The CPU is interrupted only when the game sends
;*            a sound command to the sound board.
;*************************************************************	
irq_entry		lds	#$007F
			ldaa	pia_sound_command		;Get sound command
			ldab	#$80
			stab	pia_sound_command		;Clear the IRQ
			inc	semi_random			;Increment the semi-random number
			coma
			psha					;save for later
			rola					;see if high bit is set
			pula
			ifcc
				anda #$1F
			else
				oraa #$20
			endif
			;anda	#$7F				;Mask out PB7
			anda	#$3F				;Mask out Sounds/Notes Switch
			psha					;Save for later
			cmpa	#$16
			ifne
				clr	counter2
			endif
			cmpa	#$18
			ifne
				clr	counter3
			endif
			pula
			tab
                  asla
                  aba					;A*3
			ldx	#command_lookup
			bsr	xplusa
			stx	xtemp1
			ldaa	$00,X				;Load command routine index
			asla					;*2
			ldx	#handler_table
			bsr	xplusa	
			ldx	$00,X				;Get the command routine pointer
			stx	xtemp2			;store our command routine
			ldx	xtemp1
			ldaa  $01,X                   ;Load var a
			ldab  $02,X                   ;Load var b
			ldx	xtemp2
			jsr	$00,X				;Jump to command routine
			cli
            	ldaa	bg_sec_cnt			
			beq	$				;Stay here if no backgroud sounds to do
			clra
			staa	counter2
			staa	counter3
			jmp	play_bg_sec
			
;*******************************************************
;* Add Value of A to X with carry
;*******************************************************			
xplusa 		stx	xtemp2
			adda	xtemp2+1
			staa	xtemp2+1
			ldaa	xtemp2
			adca	#$00
			staa	xtemp2
			ldx	xtemp2
			rts
			
;*******************************************************
;* Sound Command 01: Tilt Warning Sound
;*******************************************************			
snd_tilt 		ldx	#$00E0
			begin
				ldaa	#$20
				bsr	xplusa
				begin
					dex
				eqend
				clr	pia_dac_out
				begin
					decb
				eqend
				com	pia_dac_out
				ldx	xtemp2
				cpx	#$1000
			eqend
			rts

;****************************************************
;* NMI Entry: Sound Test
;****************************************************
nmi_entry		begin
				begin
					sei
					lds	#$007F
					ldx	#$FFFF
					clrb
					begin
						adcb	$00,X
						dex
						cpx	#$F800		;Do a running csum from FFFF-F801
					eqend
					cmpb	$00,X			;compare against csum at f8000
					ifne
					      jsr snd_tilt            ;try play the tilt sound
						wai				;if they don't match, stay here forever. :-(
					endif
					clr	pia_sound_command
					ldx	#$2EE0
					begin				;delay 12ms
						dex
					eqend
					jsr	low_res_snd
					jsr	low_res_snd
					jsr	low_res_snd
					ldaa	#$80
					staa	pia_sound_command
					ldaa	#$01
					jsr	load_mod_data
					jsr	play_mod_snd
					ldaa	#$0B
					jsr	load_mod_data
					jsr	play_mod_snd
					jsr	simple_snd1
					ldaa	#$02
					jsr	load_sum_data
					jsr	play_sum_snd
					ldab	speech_test_ptr
					cmpb	#$7E
				eqend
				jsr	speech_test_ptr
			loopend

;**************************************************************
;* Command Routines - these are called directly from the 
;* command table
;**************************************************************
none_cmd          rts

speech_cmd        ldab	speech_entry_ptr
			cmpb	#$7E					;Is it a jump instruction?
			ifeq						;Yes
				jsr	speech_entry_ptr		;Go to it
				cli
				ldab	pia_sound_command			;Clear any commands that came in afterwards
				ldab	sp_pending_com			;Was the speech played succesfully?
				ifeq						;yes
					cmpa	#$14					;was the speech return variable = $14
					ifne
						ldx	#$2EE0			;No, delay 12ms
						begin
							dex
						eqend
					endif
				endif
			endif
			rts
			
speech2_cmd		jmp 	speech2_start
			
mod_cmd           jsr	load_mod_data		;Load up data
			jmp	play_mod_snd		;Play it now!
			
sum_cmd           jsr	load_sum_data
		      jmp	play_sum_snd
			
tilt_cmd          jmp   snd_tilt

simp2_cmd         jmp   simple_snd2

lres_cmd          jmp   low_res_snd

simpinc_cmd       jmp   simple_inc

bgkill_cmd        jmp   kill_background

ssnd1_cmd         jmp   ssnd_1

bg_cmd            jmp   inc_bg_sec

simp1_cmd         jmp   simple_snd1

;**************************************************************
;* Master Command Lookup Table - This table contains two bytes
;* per command, the first byte is the controlling routine that
;* is called and the second byte is the register a data that
;* routine requires. The lookup starts with command 01 since 
;* command 00 does nothing.
;**************************************************************
command_lookup    .db   h_none_cmd,$00,$00            ;00(3f) - EMPTY ALWAYS
			.db   h_tilt_cmd,$00,$00            ;01(3e) - Tilt 
                  .db   h_mod_cmd,$00,$00             ;02(3d) - Electric Melt
                  .db   h_speech_cmd,$01,$00          ;03(3c) - "You  Win! You Jungle Lord"
                  .db   h_speech_cmd,$02,$00          ;04(3b) - Jungle Lord, (Trumpet)"
                  .db   h_mod_cmd,$01,$00             ;05(3a) - Time Fantasy Credit
                  .db   h_mod_cmd,$02,$00             ;06(39) - Double Trouble Miss
                  .db   h_mod_cmd,$03,$00             ;07(38) - Thud
                  .db   h_mod_cmd,$04,$00             ;08(37) - Game Over 
                  .db   h_mod_cmd,$05,$00             ;09(36) - Bonus Count
                  .db   h_speech_cmd,$03,$00          ;0A(35) - "Jungle Lord in Double Trouble" OR "You in Double Trouble"
                  .db   h_mod_cmd,$07,$00             ;0B(34) - TF Loop Forward
                  .db   h_mod_cmd,$08,$00             ;0C(33) - Jungle Lord Credit             
                  .db   h_simp2_cmd,$00,$00           ;0D(32) - TF Complete Rollovers (Uppder DT's down)
                  .db   h_speech_cmd,$05,$1B          ;0E(31) - "Fight Tiger Again" +
                  .db   h_speech_cmd,$06,$00          ;0F(30) - "Stampede, (trumpet)" 
                  .db   h_lres_cmd,$00,$00            ;10(2f) - Pop Bumper Thud   
                  .db   h_speech_cmd,$07,$00          ;11(2e) - "You Jungle Lord"
                  .db   h_simpinc_cmd,$00,$00         ;12(2d) - Funky repeat forever
                  .db   h_bgkill_cmd,$00,$00          ;13(2c) - Kill All Background
                  .db   h_ssnd1_cmd,$00,$00           ;14(2b) - Long Slow Explosion
                  .db   h_bg_cmd,$00,$00              ;15(2a) - Spooky BG
                  .db   h_speech_cmd,$08,$08          ;16(29) - "Me Jungle Lord" +
                  .db   h_simp1_cmd,$00,$00           ;17(28) - Explosion
                  .db   h_speech_cmd,$09,$08          ;18(27) - "You Win! Fight in Jungle Again" +
                  ;temp switcheroo for sound testing
                  .db   h_speech2_cmd,$0f,$00            
                  ;.db   h_speech_cmd,$0A,$1F          ;19(26) - "Fight Jungle Tiger and Win!" OR "Can you be Jungle Lord?" OR "Beat Tiger and be Jungle Lord" OR "Can you fight in Jungle?" +
                  .db   h_sum_cmd,$00,$00          ;1A(25) - Electric Game Over
                  .db   h_sum_cmd,$01,$00          ;1B(24) - Stellar Warp (+sp follow)
                  .db   h_sum_cmd,$02,$00          ;1C(23) - High Score
                  .db   h_sum_cmd,$03,$00          ;1D(22) - Match Sound	
                  .db   h_speech_cmd,$0E,$00            ;1E(21) - 
                  .db   h_speech_cmd,$0E,$00          ;1F(20) - "(trumpet)"
                  ;new jl sounds here
                  .db   h_speech2_cmd,$00,$00         ;Super Long Slow Elephant
                  .db   h_speech2_cmd,$01,$00		;long downward drum beat ;ahhhh (short monotone)
                  .db   h_speech2_cmd,$02,$00         ;oh (short burst)
                  .db   h_speech2_cmd,$03,$00         ;oh (med burst)
                  .db   h_speech2_cmd,$04,$00         ;elephant (jl)
                  .db   h_speech2_cmd,$05,$00         ;Long Slower Elephant
                  .db   h_speech2_cmd,$06,$00         ;Very Long Slow Elephant
                  .db   h_speech2_cmd,$07,$00         ;Super Long Slow Elephant
                  .db   h_speech2_cmd,$08,$00         ;aiiie (high bark)
                  .db   h_speech2_cmd,$09,$00         ;oooh  (high bark)
                  .db   h_speech2_cmd,$0A,$00         ;oooh aahhh (lots of reverb)
                  .db   h_speech2_cmd,$0B,$00         ;tiger scream start
                  .db   h_speech2_cmd,$0C,$00         ;tiger scream end
                  .db   h_speech2_cmd,$0D,$00         ;tiger haaaa
                  .db   h_speech2_cmd,$0E,$00         ;2E(11) - nada?
                  .db   h_speech2_cmd,$0F,$00         ;2F(10) -  
                  .db   h_speech2_cmd,$10,$00         ;30(0f) -    
                  .db   h_speech2_cmd,$11,$00         ;31(0e) - 
                  .db   h_speech2_cmd,$12,$00         ;32(0d) - 
                  .db   h_speech2_cmd,$13,$00         ;33(0c) - 
                  .db   h_speech2_cmd,$14,$00         ;34(0b) - 
                  .db   h_speech2_cmd,$15,$00         ;35(0a) - 
                  .db   h_speech2_cmd,$16,$00         ;36(09) - 
                  .db   h_speech2_cmd,$17,$00         ;37(08) - 
                  .db   h_speech2_cmd,$18,$00         ;38(07) - 
                  .db   h_speech2_cmd,$19,$00         ;39(06) - 
                  .db   h_speech2_cmd,$1A,$00         ;3A(05) - 
                  .db   h_speech2_cmd,$1B,$00         ;3B(04) - 
                  .db   h_speech2_cmd,$1C,$00         ;3C(03) - 
                  .db   h_speech2_cmd,$1D,$00         ;3D(02) - 	
                  .db   h_speech2_cmd,$1E,$00         ;3E(01) - 
                  .db   h_speech2_cmd,$1F,$00         ;3F(00) - 

;**************************************************************
;* Subroutine lookup for all sound commands
;**************************************************************
___hnum = 0
___numh = 13d
___eng = $
___csy = ___eng+(___numh*2)

#define 	reg_handler(xlit)  \ .org ___eng
#defcont   \ .dw xlit
#defcont   \___eng .set ___eng+2
#defcont   \h_+xlit = ___hnum
#defcont   \___hnum .set ___hnum+1
#defcont   \ .org ___csy
#defcont   \___csy .set ___csy+2

handler_table     reg_handler(none_cmd)
                  reg_handler(tilt_cmd)
                  reg_handler(mod_cmd)
                  reg_handler(speech_cmd)
                  reg_handler(simp2_cmd)
                  reg_handler(lres_cmd)
                  reg_handler(simpinc_cmd)
                  reg_handler(bgkill_cmd)
                  reg_handler(ssnd1_cmd)
                  reg_handler(bg_cmd)
                  reg_handler(simp1_cmd)
                  reg_handler(sum_cmd)
                  reg_handler(speech2_cmd)

;**************************************************************
;* Data for creating sum based sounds.
;*
;* byte1: 	Cycle Timer 1 Initial Value
;* byte2: 	Cycle Timer 2 Initial Value
;* byte3:	Cycle Timer 1 Loop Adder
;* byte4:	Cycle Timer 2 Loop Adder
;* byte5:	Cycle Timer 2 Max Value
;* byte6/7:	All Cycle Timer
;* byte8:	Cycle Timer 1 Value
;* byte9: 	DAC Amplitude
;*
;**************************************************************
sum_table		.db 	$40,$01,$00,$10,$E1,$00,$80,$FF,$FF
			.db	$20,$01,$00,$08,$E1,$00,$80,$FF,$FF
			.db	$28,$01,$00,$08,$81,$02,$00,$FF,$FF
			.db	$00,$FF,$08,$FF,$68,$04,$80,$00,$FF
			.db	$28,$81,$00,$FC,$01,$02,$00,$FC,$FF
			.db	$01,$01,$00,$08,$81,$02,$00,$01,$FF
			.db	$01,$08,$00,$01,$20,$01,$00,$01,$FF
			.db	$60,$01,$57,$08,$E1,$02,$00,$FE,$B0
			.db	$FF,$01,$00,$18,$41,$04,$80,$00,$FF
			.db	$FF,$01,$00,$50,$41,$04,$80,$FF,$FF

;**************************************************************
;* Data for creating low res based sounds.
;*
;* byte1: 	
;* byte2: 	
;* byte3:	
;* byte4:	
;* byte5:	
;* byte6:
;* byte7:	
;* byte8:	
;* byte9:
;* bytea: 	
;*
;**************************************************************
low_res_table	.db	$01,$FC,$02,$FC,$03,$F8,$04,$F8,$06,$F8
			.db	$08,$F4,$0C,$F4,$10,$F4,$20,$F2,$40,$F1
			.db	$60,$F1,$80,$F1,$A0,$F1,$C0,$F1,$00,$00

;***************************************************************************
;* Waveform Definition Table: Defines the shape of the wave output by
;*                            the next routine.
;*
;* First Byte is length of data.
;*************************************************************************** 			
wavefrm_tbl		.db	$08,$7F,$D9,$FF,$D9,$7F,$24,$00,$24
			.db	$08,$FF,$FF,$FF,$FF,$00,$00,$00,$00
			.db	$08,$00,$40,$80,$00,$FF,$00,$80,$40
			.db	$10,$7F,$B0,$D9,$F5,$FF,$F5,$D9,$B0,$7F,$4E,$24,$09,$00,$09,$24,$4E
			.db	$10,$7F,$C5,$EC,$E7,$BF,$8D,$6D,$6A,$7F,$94,$92,$71,$40,$17,$12,$39
			.db	$10,$76,$FF,$B8,$D0,$9D,$E6,$6A,$82,$76,$EA,$81,$86,$4E,$9C,$32,$63
			.db	$10,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$00,$00,$00,$00,$00,$00,$00,$00
			.db	$10,$FF,$FF,$FF,$FF,$00,$00,$00,$00,$FF,$FF,$FF,$FF,$00,$00,$00,$00
			.db	$10,$00,$F4,$00,$E8,$00,$DC,$00,$E2,$00,$DC,$00,$E8,$00,$F4,$00,$00
			.db	$48,$8A,$95,$A0,$AB,$B5,$BF,$C8,$D1,$DA,$E1,$E8,$EE,$F3,$F7,$FB,$FD
			.db	    $FE,$FF,$FE,$FD,$FB,$F7,$F3,$EE,$E8,$E1,$DA,$D1,$C8,$BF,$B5,$AB
			.db	    $A0,$95,$8A,$7F,$75,$6A,$5F,$54,$4A,$40,$37,$2E,$25,$1E,$17,$11
			.db	    $0C,$08,$04,$02,$01,$00,$01,$02,$04,$08,$0C,$11,$17,$1E,$25,$2E
			.db	    $37,$40,$4A,$54,$5F,$6A,$75,$7F
			.db	$10,$59,$7B,$98,$AC,$B3,$AC,$98,$7B,$59,$37,$19,$06,$00,$06,$19,$37

;***********************************************************
;* Data Table for Modulated Sounds
;*
;* Table contains 7 bytes per sound entry:
;*	byte1:
;*	byte2:
;*	byte3:
;*	byte4:
;*	byte5:
;*	byte6: Index into Envelope Table
;*	byte7: Envelope Data Length
;***********************************************************
mod_snd_tbl	
			.db   $14,$10,$00,$01,$00,$01,$6A
			.db	$81,$27,$00,$00,$00,$16,$54
			.db 	$12,$09,$1A,$FF,$00,$27,$91
			.db 	$11,$09,$11,$01,$0F,$01,$6A
			.db 	$11,$32,$00,$01,$00,$0D,$1B
			.db	$14,$11,$00,$00,$00,$0E,$0D
			.db	$F4,$13,$00,$00,$00,$14,$6A
			.db	$41,$49,$00,$00,$00,$0F,$7E
			.db	$21,$39,$11,$FF,$00,$0D,$1B
			.db	$42,$46,$00,$00,$00,$0E,$28
			.db	$15,$00,$00,$FD,$00,$01,$8C
			.db	$F1,$18,$00,$00,$00,$0E,$28
			.db	$31,$12,$00,$01,$00,$03,$8D
			.db	$81,$09,$11,$FF,$00,$01,$90
			.db	$31,$12,$00,$FF,$00,$0D,$00
			.db	$12,$0A,$00,$FF,$01,$09,$4B

sweep_table
			.db 	$A0,$98,$90,$88,$80,$78,$70,$68,$60,$58,$50,$44,$40
			.db	$01,$01,$02,$02,$04,$04,$08,$08,$10,$10,$30,$60,$C0,$E0
			.db	$01,$01,$02,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0C
			.db 	$08,$80,$10,$78,$18,$70,$20,$60,$28,$58,$30,$50,$40,$48
			.db 	$04,$05,$06,$07,$08,$0A,$0C,$0E,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$1A,$1B,$1C
			.db	$80,$7C,$78,$74,$70,$74,$78,$7C,$80
			.db 	$01,$01,$02,$02,$04,$04,$08,$08,$10,$20,$28,$30,$38,$40,$48,$50,$60,$70,$80,$A0,$B0,$C0
			.db 	$08,$40,$08,$40,$08,$40,$08,$40,$08,$40,$08,$40,$08,$40,$08,$40,$08,$40,$08,$40
			.db 	$01,$02,$04,$08,$09,$0A,$0B,$0C,$0E,$0F,$10,$12,$14,$16
			.db 	$40,$10,$08,$01,$92
			.db 	$01,$01,$01,$01,$02,$02,$03,$03,$04,$04,$05,$06,$08,$0A,$0C
			.db	$10,$14,$18,$20,$30,$40,$50,$40,$30,$20,$10,$0C,$0A,$08,$07
			.db	$06,$05,$04,$03,$02,$02,$01,$01,$01

	.org $fff3
;************************************************
;* Adding A to X is a common routine and this
;* pointer is provided to the speech ROM's so
;* that the code can be as compact as possible.
;* It appears that designers really pushed hard
;* to get their speech code into 3 ROM's.
;************************************************
to_xplusa
			jmp	xplusa
	
;************************************************
;* dont know what this is.
;************************************************			
unknown
			.dw	$DFDA

.org $fff8			
;************************************************
;* CPU Vectors
;************************************************	
irq_vector	.dw irq_entry
swi_vector	.dw swi_entry
nmi_vector	.dw nmi_entry
res_vector	.dw swi_entry

.end