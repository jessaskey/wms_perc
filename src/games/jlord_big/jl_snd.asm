;************************************************************
;* Jungle Lord Sound/Speech Code
;*                          
;* Jess M. Askey
;* 28-11-2001
;************************************************************
;*
;*	Sound List - There are only 32 sounds available in 
;*                 level 7 games so that the DIP switches
;*                 can properly adjust the commands.
;*
;*  Command	SpeechDisabled			SpeechEnabled
;*  --------------------------------------------------------------------------------------------------			
;*	01	Tilt
;*	02	Electric Melt
;*	03	Cosmic Gunfight Lock		"You  Win! You Jungle Lord"
;*	04	Wah Wah (Increasing Speed)	"Jungle Lord, (Trumpet)"
;*	05	Time Fantasy Credit
;*	06	Double Trouble Miss
;*	07	Thud
;*	08	Game Over (+sp follow)
;*	09	Bonus Count
;*	0A	TF Top Rollover			"Jungle Lord in Double Trouble" OR "You in Double Trouble"
;*	0B	TF Loop Forward
;*	0C	Jungle Lord Credit
;*	0D	TF Complete Rollovers
;*	0E	Mutant				"Fight Tiger Again"
;*	0F	Reverse Slow Explosion		"Stampede, (trumpet)" 
;*	10	Pop Bumper Thud
;*	11	Time Fantasy BG			"You Jungle Lord"
;*	12	Funky repeat forever
;*	13	Kill All Background
;*	14	Long Slow Explosion
;*	15	Spooky BG
;*	16	TF Bonus 				"Me Jungle Lord"
;*	17	Explosion
;*	18						"You Win! Fight in Jungle Again"
;*	19	CG Drain				"Fight Jungle Tiger and Win!" OR "Can you be Jungle Lord?" OR "Beat Tiger and be Jungle Lord" OR "Can you fight in Jungle?"
;*	1A	Electric Game Over
;*	1B	Stellar Warp (+sp follow)
;*	1C	High Score
;*	1D	Match Sound	
;*	1E						"(trumpet)"
;*	1F	(+sp follow)			"(trumpet)"
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
bg_pri_cnt		.block	1
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
;* Chime Sounds
.org			local_base+16
chi_freq		.block	1
chi_loop_cnt	.block	1
chi_common_cnt	.block	1

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
jl_ut_01_start		.db	$AA,$34,$5A,$1E
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
jl_ut_02_start		.db	$AA,$E1,$FF,$07
			.db	$10,$28,$FE,$4F
			.db	$85,$A0,$54,$B5
			.db	$54,$FA,$D3
jl_ut_01_end		.db	$70
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
jl_ut_02_end		.db	$E1
			.db	$D1,$2A
			.db	$AE,$C2,$3B,$95
			.db	$52,$59,$B9,$EA
jl_ut_03_start		.db	$AA,$49,$4B,$A5
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
jl_ut_03_end		.db	$AD
jl_ut_04_start		.db	$AA
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
jl_ut_04_end		.db	$95
jl_ut_05_start		.db	$AA,$BA,$AA,$A6
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
jl_ut_0f_start
jl_ut_16_start		.db	$AA,$FF,$78,$1C
			.db	$0C,$06,$06,$83
			.db	$E1,$FB,$FB,$78
			.db	$1C,$0E,$07,$01
			.db	$40,$F8,$FF,$7D
			.db	$1E,$0E,$C7,$61
			.db	$00,$08,$BF,$FF
			.db	$8F,$C7,$E1,$30
jl_ut_14_start		.db	$AA,$80,$F0,$F7
			.db	$FF,$71,$18,$0C
			.db	$C2,$10,$1C,$BF
			.db	$FF,$9F,$C3,$C1
			.db	$10,$04,$81,$F0
			.db	$F9,$FB,$3A,$1E
			.db	$9F,$70,$10,$10
			.db	$9E,$FF,$FF,$53
jl_ut_14_end		.db	$10,$00,$00,$C1
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
jl_ut_0f_end		.db	$3C,$FF,$DF,$C7
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
jl_ut_16_end		.db	$AA,$57,$CB
			.db	$D1,$52,$A9,$34
			.db	$1A,$15,$8D,$8A
			.db	$82,$42,$A5,$F5
			.db	$FD,$BE,$9E,$AB
			.db	$45,$A1,$30,$2A
			.db	$AA,$AA,$9A,$AE
			.db	$AB,$AB,$55,$91
			.db	$28
jl_ut_15_start		.db	$AA,$DF,$D7
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
jl_ut_15_end		.db	$8A,$A6,$F5,$BA
			.db	$D5,$2A,$8A,$2A
			.db	$15,$3D,$BE,$4E
			.db	$14,$D6,$F6,$BD
			.db	$52,$00,$41,$55
			.db	$AF,$57,$55,$A8
			.db	$94,$BE,$6F,$2B
			.db	$51,$A8,$D8,$DA
jl_ut_05_end
jl_ut_06_start		.db	$AA,$3C,$8E,$03
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
jl_ut_08_start		.db	$AA,$7F,$01
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
jl_ut_06_end		.db	$FF,$5F,$95,$00
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
jl_ut_08_end		.db	$EE
jl_ut_07_start		.db	$AA,$F1
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
jl_ut_07_end		.db	$DF,$00
jl_ut_09_start		.db	$AA,$BE
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
jl_ut_09_end		.db	$05
jl_ut_0a_start		.db	$AA
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
jl_ut_0a_end		.db	$FF
jl_ut_0b_start		.db	$AA,$FC
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
jl_ut_0d_start		.db	$AA,$55,$AF,$55
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
jl_ut_0d_end		.db	$14,$C0,$75,$BD
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
jl_ut_0b_end		.db	$AF
jl_ut_0c_start	
jl_ut_17_start		.db	$AA
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
jl_ut_17_end
jl_ut_12_start		.db	$AA,$DE,$E3,$68
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
jl_ut_12_end		.db	$AA,$A0,$A2,$AC
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
jl_ut_0c_end		.db	$48
jl_ut_0e_start		.db	$AA,$AA,$AA
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
jl_ut_0e_end		.db	$AA

jl_ut_11_start
jl_ut_13_start
jl_ut_18_start		.db	$AA
			.db	$95,$48
jl_ut_18_end		.db	$D5,$DF
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
jl_ut_13_end		.db	$08,$0C,$FF
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
jl_ut_10_start		.db	$AA,$C5,$1C
jl_ut_11_end		.db	$AA
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
jl_ut_10_end	.db	$18

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
speech_data_tbl	.dw	jl_ut_01_start,jl_ut_01_end	;81 - "Jungle"
			.dw 	jl_ut_02_start,jl_ut_02_end	;82 - "Lord"
			.dw	jl_ut_03_start,jl_ut_03_end	;83 - "Fight"
			.dw	jl_ut_04_start,jl_ut_04_end	;84 - "Tiger"
			.dw	jl_ut_05_start,jl_ut_05_end	;85 - "Stampede!"
			.dw	jl_ut_06_start,jl_ut_06_end	;86 - "Double"
			.dw	jl_ut_07_start,jl_ut_07_end	;87 - "Trou-"
			.dw	jl_ut_08_start,jl_ut_08_end	;88 - "-ble"
			.dw	jl_ut_09_start,jl_ut_09_end	;89 - "You"
			.dw	jl_ut_0a_start,jl_ut_0a_end	;8A - "Win"
			.dw	jl_ut_0b_start,jl_ut_0b_end	;8B - "Again"
			.dw	jl_ut_0c_start,jl_ut_0c_end	;8C - "Can"
			.dw	jl_ut_0d_start,jl_ut_0d_end	;8D - "in"
			.dw	jl_ut_0e_start,jl_ut_0e_end	;8E - "M-"
			.dw	jl_ut_0f_start,jl_ut_0f_end	;8F - "-e"
			.dw	jl_ut_10_start,jl_ut_10_end	;90 - (trumpet)
			.dw	jl_ut_11_start,jl_ut_11_end	;91 - "Beat"
			.dw	jl_ut_12_start,jl_ut_12_end	;92 - "an" 
			.dw	jl_ut_13_start,jl_ut_13_end	;93 - "be-"
			.dw	jl_ut_14_start,jl_ut_14_end	;94 - "e"
			.dw	jl_ut_15_start,jl_ut_15_end	;95 - "-d"
			.dw	jl_ut_16_start,jl_ut_16_end	;96 - "-m"
			.dw	jl_ut_17_start,jl_ut_17_end	;97 - "Ca"
			.dw	jl_ut_01_start,jl_ut_10_end	;98 - All Speech
			.dw	jl_ut_18_start,jl_ut_18_end	;99 - "Be"

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

;**********************************************************
;* Speech Command Index Table - These map sound commands 
;* to speech commands. If the first byte is a zero, then
;* the command if somehow got here will play a sound command
;* and skip speech. If the first byte is non-zero, then 
;* the speech handler will play the phrase number in that 
;* byte.
;**********************************************************			
speech_lookup	.db	$00,$01	;01
			.db	$00,$02	;02
			.db	$01,$00	;03
			.db	$02,$00	;04
			.db	$00,$05	;05
			.db	$00,$06	;06
			.db	$00,$07	;07
			.db	$00,$08	;08
			.db	$00,$09	;09
			.db	$03,$00	;0a
			.db	$00,$0B	;0b
			.db	$00,$0C	;0c
			.db	$00,$0D	;0d
			.db	$05,$1B	;0e
			.db	$06,$00	;0f
			.db	$00,$10	;10
			.db	$07,$00	;11
			.db	$00,$12	;12
			.db	$00,$13	;13
			.db	$00,$14	;14
			.db	$00,$15	;15
			.db	$08,$08	;16
			.db	$00,$17	;17
			.db	$09,$08	;18
			.db	$0A,$1F	;19
			.db	$00,$1A	;1a
			.db	$00,$1B	;1b
			.db	$00,$1C	;1c
			.db	$00,$1D	;1d
			.db	$0E,$00	;1e
			.db	$0E,$00	;1f
			
;*********************************************************
;* A Little Note
;*********************************************************	

	.text "COPYRIGHT-WILLIAMS ELECTRONICS-2/9/81-JK-"		

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
;**********************************************************
speech_handler	ldx	#speech_lookup-2
			staa	last_speech_cmd
			staa	sp_pending_com		;Store this for later
			anda	#$1F
			ifne					;Is this command greater than zero and less than $20?
				asla					;times 2 for master table lookup
				jsr	to_xplusa			;Add the offset
				ldab	$01,X
				stab	sp_nextwordcmd		;Store the next word needed command here for now
				ldaa	$00,X
			endif
			ifne
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
				ldaa	sp_nextwordcmd			;Yes, get the next word command if needed
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

;***********************************************************
;* Required Speech Pointers
;***********************************************************
#IF emulate
	.org $effa
#ELSE
	.org $dffa
#ENDIF
	

speech_test_ptr		jmp speech_test
speech_handler_ptr	jmp speech_handler

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
			staa	bg_pri_cnt		;Reset background sounds
			staa	bg_sec_cnt
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
			
;*******************************************************
;* Chime Handler:
;*******************************************************
snd_chime		anda	#$1F
			beq	$			;should never get $00, if so, halt here
			anda	#$0F			;only 15 possible chime sounds
			ldx	#local_base	;This is where we will temporarily copy the chima data
			stx	xtemp3
			ldx	#chi_freq_tab
			jsr	xplusa
			ldaa	$00,X
			staa	chi_freq
			ldx	#chime_dac_data	;Copy the chime dac data into the RAM buffer
			ldab	#$10			;for processing.
			jsr	copy_block		;Copy block from X to xtemp3, B bytes
			ldx	#chime_common
			ldab	$00,X
			begin
				stab	chi_common_cnt
				stx	xtemp3
				begin
					ldx	#local_base
					ldab	#$08
					stab	chi_loop_cnt
					begin
						ldaa	$00,X
						ldab	chi_freq
						tst	chi_common_cnt
						ifeq
							suba	$08,X
							staa	$00,X
							subb	#$03		;This took some extra time, subtract it
						endif
						inx
						staa	pia_dac_out
						begin
							decb
						eqend
						dec	chi_loop_cnt
					eqend
					dec	chi_common_cnt
				miend
				ldx	xtemp3
				inx
				ldab	$00,X
			eqend
			bra	$			;Stay Here until next command

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

;********************************************************************
;* Stops Secondary Background, increments primary background
;********************************************************************			
inc_bg_pri		ldaa	bg_sec_cnt
			oraa	#$80
			staa	bg_sec_cnt
			ldab	bg_pri_cnt
			andb	#$7F
			cmpb	#$24
			ifeq
				clrb
			endif
			incb
			stab	bg_pri_cnt
			rts
			

play_bg_pri		ldaa	#$07
			jsr	load_sum_data
			ldab	bg_pri_cnt
			cmpb	#$20
			ifgt
				ldab	#$20
			endif
			ldx	#$0038
			ldaa	#$20
			sba
			tab
bgs_loop		cmpb	#$0F
			ifgt
				ldaa	#$10
				jsr	xplusa
				decb
				bra	bgs_loop
			endif
			begin
				ldaa	#$08
				jsr	xplusa
				decb
			eqend
			stx	X0019
			ldaa	temp1
			asla
			adda	temp1
			adda	#$0B
			staa	temp1
			staa	X0014
			begin
				jsr	play_sum_snd
			loopend
			
;*********************************************************
;* Turns off All Background Sounds
;*********************************************************
kill_background	clr	bg_pri_cnt
			clr	bg_sec_cnt
			rts
			
;*********************************************************
;* Turns off primary backgroud, increments sec background
;*********************************************************
inc_bg_sec		ldaa	bg_pri_cnt
			oraa	#$80
			staa	bg_pri_cnt
			ldaa	bg_sec_cnt
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
			stab	sum_t1_init
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
			anda	#$7F				;Mask out PB7
			psha					;Save for later
			anda	#$5F				;Mask out Sounds/Notes Switch
			cmpa	#$16
			ifne
				clr	counter2
			endif
			cmpa	#$18
			ifne
				clr	counter3
			endif
			pula
			bita	#$20				;If bit#20 is set then we have a speech command
			ifne
				ldab	speech_handler_ptr
				cmpb	#$7E					;Is it a jump instruction?
				ifeq						;Yes
					jsr	speech_handler_ptr		;Go to it
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
			endif
			cli
			bita	#$40				;If bit#40 is set then we have chimes
			ifne
				anda	#$1F
				cmpa	#$01				;let command $01 slip past...
				ifne
					jmp	snd_chime
				endif
			endif
			anda	#$1F				;Less than $1f sound effects
			ifne
				deca
				beq	snd_tilt			;Here for sound command $01: Tilt
				cmpa	#$0D
				iflo					;Here for commands $02-$0C
					deca
					jsr	load_mod_data		;Load up data
					jsr	play_mod_snd		;Play it now!
				else
					cmpa	#$17
					iflo
						suba	#$0E
						asla
						ldx	#comtable_0f_17
						bsr	xplusa
						ldx	$00,X
						jsr	$00,X				;INFO: index jump
					else				
						suba	#$18				;Here for commands 18 and higher
						jsr	load_sum_data
						jsr	play_sum_snd
					endif
				endif
			endif
chk_background	ldaa	bg_pri_cnt			;Here if we had a sound command of $00
			oraa	bg_sec_cnt
			beq	$				;Stay here if no backgroud sounds to do
			clra
			staa	counter2
			staa	counter3
			ldaa	bg_pri_cnt
			ifne
				ifpl
					jmp	play_bg_pri
				endif
			endif
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
			bra chk_background

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
;* Subroutine lookup for sound commands $0e-$17
;**************************************************************			
comtable_0f_17	.dw	simple_snd2		;0F -
			.dw   low_res_snd		;10 -
			.dw	inc_bg_pri		;11 - Start pri bg?
			.dw	simple_inc		;12 - 
			.dw	kill_background	;13 - 
			.dw 	ssnd_1		;14 - 
			.dw	inc_bg_sec		;15 - start sec bg?
			.dw 	bsound_1		;16 - Inc 0007 bg
			.dw	simple_snd1		;17 -
			.dw	bsound_2		;XX - Inc 0008 bg

;**************************************************************
;* This is the raw data that is dumped to the DAC for chime 
;* sounds. The first set is the actual data while the second
;* set is an amplitude modifier.
;**************************************************************			
chime_dac_data	
			.db	$DA,$FF,$DA,$80,$26,$01,$26,$80		
			.db	$07,$0A,$07,$00,$F9,$F6,$F9,$00

;**************************************************************
;* This is the lookup table for the frequencies used for each
;* chime command. The data is the delay between data output 
;* to the DAC. Higher values are lower frequencies.
;**************************************************************
chi_freq_tab		
			.db	$3A,$3E,$50,$46,$33,$2C,$27,$20,$25,$1C,$1A,$17,$14,$11,$10,$33

;**************************************************************
;* This is a data table that is used for all chime sounds
;**************************************************************
chime_common	
			.db	$08,$03,$02,$01,$02,$03,$04,$05,$06,$0A,$1E,$32,$70,$00

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