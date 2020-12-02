;--------------------------------------------------------------
;Barracora Game ROM Disassembly
;Dumped by Pinbuilder ©2000-2001 Jess M. Askey
;--------------------------------------------------------------

#include  "level7.exp"	;Level 7 system defines
#include  "wvm7.asm"	;Level 7 macro defines
#include  "68logic.asm"	;680X logic definitions
#include  "7gen.asm"	;Level 7 general defines

	.org $d800

gj_02			jsr	macro_start
			BITON_($53)				;Turn ON: Bit#13
gb_46			SLEEP_(4)
			.db $5A,$58,$FC			;BEQ_BIT#18 to gb_46
			BE29_($81,$0D)			;Effect: Range #81 Range #0D
			BE2A_($0D)				;Effect: Range #0D
			BE28_($4D)				;Effect: Range #4D
gb_47			SLEEP_(6)
			BE2A_($41)				;Effect: Range #41
			EXE_($04)				;CPU Execute Next 4 Bytes
			ldaa	$27
			anda	#$10
			.db $5A,$FC,$E0,$00,$F3		;BEQ_RAM$00==#0 to gb_47
			BE2E_($0D)				;Effect: Range #0D
gb_48			SLEEP_(6)
			BE2D_($41)				;Effect: Range #41
			EXE_($04)				;CPU Execute Next 4 Bytes
			ldaa	$26
			anda	#$20
			.db $5B,$FC,$E0,$00,$F3		;BNE_RAM$00==#0 to gb_48
			BE2E_($0D)				;Effect: Range #0D
gb_49			SLEEP_(6)
			BE2E_($41)				;Effect: Range #41
			EXE_($04)				;CPU Execute Next 4 Bytes
			ldaa	$27
			anda	#$20
			.db $5B,$FC,$E0,$00,$F3		;BNE_RAM$00==#0 to gb_49
			BE2E_($0D)				;Effect: Range #0D
gb_4A			SLEEP_(6)
			BE2C_($41)				;Effect: Range #41
			EXE_($04)				;CPU Execute Next 4 Bytes
			ldaa	$26
			anda	#$40
			.db $5B,$FC,$E0,$00,$F3		;BNE_RAM$00==#0 to gb_4A
			BE2E_($0D)				;Effect: Range #0D
gb_4B			SLEEP_(6)
			BE2E_($41)				;Effect: Range #41
			EXE_($04)				;CPU Execute Next 4 Bytes
			ldaa	$27
			anda	#$20
			.db $5A,$FC,$E0,$00,$F3		;BEQ_RAM$00==#0 to gb_4B
			BE2E_($0D)				;Effect: Range #0D
gb_4C			SLEEP_(6)
			BE2D_($41)				;Effect: Range #41
			EXE_($04)				;CPU Execute Next 4 Bytes
			ldaa	$26
			anda	#$20
			.db $5A,$FC,$E0,$00,$F3		;BEQ_RAM$00==#0 to gb_4C
			BE2E_($0D)				;Effect: Range #0D
			JMPR_(gb_47)			
gj_2E			jsr	macro_start
			PRI_($32)				;Priority=#32
			BE28_($45)				;Effect: Range #45
			BE2A_($05)				;Effect: Range #05
			SETRAM_($00,$10)			;RAM$00=$10
gb_91			SLEEP_(4)
			BE2E_($05)				;Effect: Range #05
			ADDRAM_($00,$FF)			;RAM$00+=$FF
			.db $5B,$FC,$E0,$00,$F6		;BNE_RAM$00==#0 to gb_91
			SETRAM_($00,$10)			;RAM$00=$10
gb_92			SLEEP_(3)
			BE2D_($05)				;Effect: Range #05
			ADDRAM_($00,$FF)			;RAM$00+=$FF
			.db $5B,$FC,$E0,$00,$F6		;BNE_RAM$00==#0 to gb_92
			BE29_($C5,$05)			;Effect: Range #C5 Range #05
			KILL_					;Remove This Thread

gj_28			jsr	macro_start
			PRI_($32)				;Priority=#32
			BE28_($46)				;Effect: Range #46
			SETRAM_($00,$10)			;RAM$00=$10
			BE2A_($06)				;Effect: Range #06
gb_84			SLEEP_(4)
			BE2E_($06)				;Effect: Range #06
			ADDRAM_($00,$FF)			;RAM$00+=$FF
			.db $5B,$FC,$E0,$00,$F6		;BNE_RAM$00==#0 to gb_84
			SETRAM_($00,$10)			;RAM$00=$10
gb_85			SLEEP_(3)
			BE2D_($06)				;Effect: Range #06
			ADDRAM_($00,$FF)			;RAM$00+=$FF
			.db $5B,$FC,$E0,$00,$F6		;BNE_RAM$00==#0 to gb_85
			BE29_($C6,$06)			;Effect: Range #C6 Range #06
			KILL_					;Remove This Thread

gj_13			jsr	macro_start
			.db $5A,$FB,$58,$57,$69		;BEQ_(BIT#17 || BIT#18) to gb_6C
			PRI_($32)				;Priority=#32
			BITON_($57)				;Turn ON: Bit#17
			SLEEP_(15)
			BE28_($43)				;Effect: Range #43
			BE29_($03)				;Effect: Range #03
			SETRAM_($00,$06)			;RAM$00=$06
			BITON2_($6D)			;Turn ON: Lamp#2D(super_2x)
gb_6D			SLEEP_(5)
			BE2E_($03)				;Effect: Range #03
			.db $5B,$F7,$30,$F9		;BNE_BIT#30 to gb_6D
gb_6E			SLEEP_(5)
			BE2D_($03)				;Effect: Range #03
			.db $5B,$F7,$2D,$F9		;BNE_BIT#2D to gb_6E
			ADDRAM_($00,$FF)			;RAM$00+=$FF
			.db $5B,$FC,$E0,$00,$EB		;BNE_RAM$00==#0 to gb_6D
			SETRAM_($00,$2D)			;RAM$00=$2D
gb_6F			BITOFFP2_($00)			;Turn OFF Lamp/Bit @RAM:00
			SLEEP_(8)
			ADDRAM_($00,$01)			;RAM$00+=$01
			.db $5B,$FD,$E0,$30,$F6		;BNE_RAM$00>=#48 to gb_6F
			BITOFF_($57)			;Turn OFF: Bit#17
			KILL_					;Remove This Thread

gj_15			jsr	macro_start
			.db $5A,$FB,$58,$56,$30		;BEQ_(BIT#16 || BIT#18) to gb_6C
			PRI_($32)				;Priority=#32
			BITON_($56)				;Turn ON: Bit#16
			SLEEP_(7)
			BE28_($42)				;Effect: Range #42
			BE29_($02)				;Effect: Range #02
			SETRAM_($00,$06)			;RAM$00=$06
			BITON2_($71)			;Turn ON: Lamp#31(2x_mult)
gb_73			SLEEP_(5)
			BE2E_($02)				;Effect: Range #02
			.db $5B,$F7,$34,$F9		;BNE_BIT#34 to gb_73
gb_74			SLEEP_(5)
			BE2D_($02)				;Effect: Range #02
			.db $5B,$F7,$31,$F9		;BNE_BIT#31 to gb_74
			ADDRAM_($00,$FF)			;RAM$00+=$FF
			.db $5B,$FC,$E0,$00,$EB		;BNE_RAM$00==#0 to gb_73
			SETRAM_($00,$31)			;RAM$00=$31
gb_75			BITOFFP2_($00)			;Turn OFF Lamp/Bit @RAM:00
			SLEEP_(8)
			ADDRAM_($00,$01)			;RAM$00+=$01
			.db $5B,$FD,$E0,$34,$F6		;BNE_RAM$00>=#52 to gb_75
			BITOFF_($56)			;Turn OFF: Bit#16
gb_6C			KILL_					;Remove This Thread


lamptable	.db $2D ,$3F	;(00) super_2x -- bonus_20
			.db $35 ,$3D	;(01) bonus_1 -- bonus_9
			.db $31 ,$34	;(02) 2x_mult -- 5x_mult
			.db $2D ,$30	;(03) super_2x -- super_5x
			.db $08 ,$0F	;(04) lamp_b -- lamp_a3
			.db $1A ,$1C	;(05) lower_eject_30 -- lower_eject_90
			.db $20 ,$22	;(06) urbull_20k -- urbull_eb
			.db $16 ,$17	;(07) left_special -- right_special
			.db $10 ,$15	;(08) lamp_1 -- lamp_6
			.db $10 ,$12	;(09) lamp_1 -- lamp_3
			.db $13 ,$15	;(0A) lamp_4 -- lamp_6
			.db $23 ,$27	;(0B) lbull_5k -- lbull_25k
			.db $28 ,$2C	;(0C) rbull_2x -- rbull_10x
			.db $3E ,$3F	;(0D) bonus_10 -- bonus_20
			.db $1D ,$1F	;(0E) lower_eject_lock -- upper_eject_cb
			.db $48 ,$4A	;(0F) lamp_b -- lamp_rr
			.db $4B ,$4F	;(10) lamp_a2 -- lamp_a3
			.db $06 ,$3F	;(11) barr_dt_bank -- bonus_20
			.db $23 ,$2C	;(12) lbull_5k -- rbull_10x
			.db $1D ,$1E	;(13) lower_eject_lock -- upper_eject_lock
			.db $06 ,$07	;(14) barr_dt_bank -- acora_dt_bank


soundtable		.db $21, $10,	$3D		;(00) 
			.db $AE, $60,	$3E		;(01) 
			.db $A4, $50,	$3C		;(02) 
			.db $22, $10,	$3B		;(03) 
			.db $A9, $D0,	$3A		;(04) 
			.db $28, $70,	$39		;(05) 
			.db $22, $20,	$38		;(06) 
			.db $22, $10,	$37		;(07) 
			.db $A2, $40,	$36		;(08) 
			.db $22, $30,	$35		;(09) 
			.db $23, $10,	$34		;(0A) 
			.db $23, $50,	$33		;(0B) 
			.db $21, $10,	$32		;(0C) 
			.db $23, $20,	$31		;(0D) 
			.db $A2, $30,	$30		;(0E) 
			.db $22, $90,	$2F		;(0F) 
			.db $A1, $01,	$2E		;(10) 
			.db $22, $30,	$2D		;(11) 
			.db $CE, $05,	$2C		;(12) 
			.db $21, $10,	$2B		;(13) 
			.db $23, $40,	$2A		;(14) 
			.db $23, $20,	$29		;(15) 
			.db $21, $10,	$28		;(16) 
			.db $22, $30,	$27		;(17) 
			.db $21, $10,	$26		;(18) 
			.db $2A, $50,	$25		;(19) 
			.db $AA, $80,	$24		;(1A) 
			.db $AA, $50,	$23		;(1B) 
			.db $AF, $50,	$22		;(1C) 
			.db $AF, $50,	$21		;(1D) 
			.db $AF, $50,	$20		;(1E) 


switchtable		.db %10010011	\.dw sw_plumbtilt		;(1) plumbtilt
			.db %10010001	\.dw sw_balltilt		;(2) balltilt
			.db %11110001	\.dw sw_credit_button	;(3) credit_button
			.db %11110010	\.dw coin_accepted	;(4) coin_right
			.db %11110010	\.dw coin_accepted	;(5) coin_center
			.db %11110010	\.dw coin_accepted	;(6) coin_left
			.db %01110001	\.dw reset			;(7) slam
			.db %11110001	\.dw sw_hstd_res		;(8) hstd_res
			.db %10010011	\.dw sw_barracora_lane	;(9) barracora_lane
			.db %11111110	\.dw sw_upper_eject	;(10) upper_eject
			.db %11111110	\.dw sw_lower_eject	;(11) lower_eject
			.db %11110110	\.dw sw_outhole		;(12) outhole
			.db %11010100	\.dw sw_left_trough	;(13) left_trough
			.db %11010100	\.dw sw_center_trough	;(14) center_trough
			.db %11010100	\.dw sw_right_trough	;(15) right_trough
			.db %10011110	\.dw sw_ball_shooter	;(16) ball_shooter
			.db %10010011	\.dw sw_1_4_lane		;(17) 1_4_lane
			.db %10010011	\.dw sw_2_5_lane		;(18) 2_5_lane
			.db %10010011	\.dw sw_3_6_lane		;(19) 3_6_lane
			.db %10010001	\.dw sw_left_jet		;(20) left_jet
			.db %10010001	\.dw sw_right_jet		;(21) right_jet
			.db %10010001	\.dw sw_bottom_jet	;(22) bottom_jet
			.db %10010011	\.dw sw_left_outlane	;(23) left_outlane
			.db %10010011	\.dw sw_right_outlane	;(24) right_outlane
			.db %10010111	\.dw sw_spinner		;(25) spinner
			.db %10010011	\.dw sw_right_turnaround;(26) right_turnaround
			.db %10010010	\.dw sw_left_bull		;(27) left_bull
			.db %10010010	\.dw sw_right_bull	;(28) right_bull
			.db %10010001	\.dw sw_lsling_10		;(29) lsling_10
			.db %10010001	\.dw sw_rsling_10		;(30) rsling_10
			.db %10010011	\.dw sw_left_return	;(31) left_return
			.db %10010011	\.dw sw_right_return	;(32) right_return
			.db %10010010	\.dw sw_upper_right_bull;(33) upper_right_bull
			.db %10010001	\.dw sw_left_flipper	;(34) left_flipper
			.db %10010001	\.dw sw_right_flipper	;(35) right_flipper
			.db %10010001	\.dw sw_pf_tilt		;(36) pf_tilt
			.db %10010001	\.dw sw_upper_10		;(37) upper_10
			.db %10010001	\.dw sw_lower_10		;(38) lower_10
			.db %10010001	\.dw sw_5bank_10		;(39) 5bank_10
			.db %10010001	\.dw sw_lleft_10		;(40) lleft_10
			.db %10010101	\.dw sw_dt_b		;(41) dt_b
			.db %10010101	\.dw sw_dt_a1		;(42) dt_a1
			.db %10010101	\.dw sw_dt_rr		;(43) dt_rr
			.db %10010101	\.dw sw_dt_a2		;(44) dt_a2
			.db %10010101	\.dw sw_dt_c		;(45) dt_c
			.db %10010101	\.dw sw_dt_o		;(46) dt_o
			.db %10010101	\.dw sw_dt_r		;(47) dt_r
			.db %10010101	\.dw sw_dt_a3		;(48) dt_a3
switchtable_end

gj_20			bsr	gb_58
			clrb	
			ldaa	#$A0
gb_5C			cmpb	player_up
			beq	gb_59
			staa	thread_priority
			ldx	#gj_2F
			jsr	newthread_sp
gb_59			cmpb	#$03
			beq	gb_5A
			incb	
			bsr	gb_5B
			bra	gb_5C
gb_5A			rts	
gb_58			jsr	disp_mask
			anda	comma_flags
			staa	comma_flags
			rts	
gb_5B			jsr	addthread
			.db $10

			rts	
gj_2F			tba	
			ldx	#dmask_p1
			jsr	xplusb
			ldab	#$7F
			stab	$00,X
			jsr	gj_33
			ldaa	#$FF
			staa	$00,X
			staa	$01,X
			staa	$02,X
			staa	$03,X
			ldab	spare_ram+4
			stab	$00,X
			stab	$03,X
			bsr	gb_5B
			ldab	$00,X
			jsr	gj_34
			stab	$01,X
			andb	$03,X
			stab	$03,X
			bsr	gb_5B
			ldab	spare_ram+4
			stab	$02,X
			andb	$01,X
			stab	$01,X
			bsr	gb_5B
			ldab	$01,X
			stab	$02,X
			bsr	gb_5B
			ldab	#$FF
			stab	$00,X
			ldab	$03,X
			orab	#$0F
			stab	$03,X
			bsr	gb_5B
			ldab	spare_ram+4
			stab	$01,X
			orab	$03,X
			stab	$03,X
			bsr	gb_5B
			ldab	$02,X
			orab	#$0F
			stab	$02,X
			orab	$01,X
			stab	$01,X
			bsr	gb_7C
gb_7D			bsr	gb_7C
			stab	$02,X
			stab	$01,X
			bsr	gb_7C
			bsr	gj_34
			stab	$01,X
			stab	$03,X
			ldab	#$FF
			stab	$02,X
			bsr	gb_7C
			stab	$00,X
			stab	$03,X
			ldab	#$FF
			stab	$01,X
			bsr	gb_7C
			bsr	gj_34
			stab	$03,X
			stab	$01,X
			ldab	#$FF
			stab	$00,X
			bsr	gb_7C
			stab	$01,X
			stab	$02,X
			ldab	#$FF
			stab	$03,X
			bsr	gb_7C
			bsr	gj_34
			stab	$02,X
			ldab	#$FF
			stab	$01,X
			bra	gb_7D
gj_33			asla	
			asla	
			ldx	#score_p1_b1
			jmp	xplusa
gj_34			aslb	
			aslb	
			aslb	
			aslb	
			orab	#$0F
			rts	
gb_7C			stx	spare_ram+5
			ldab	$02,X
			andb	#$F0
			cmpb	#$F0
			beq	gb_93
			jsr	get_random
			anda	#$03
			adda	#$05
			ldx	spare_ram+5
gb_93			staa	thread_timer_byte
			jsr	delaythread
			ldab	spare_ram+4
			rts	
gj_11			BITON_($61)				;Turn ON: Bit#21
			SLEEP_(128)
			CPUX_					;Resume CPU Execution
			ldaa	comma_flags
			staa	spare_ram+1
			clr	flag_gameover
			clra	
			ldab	num_players
gb_67			bsr	gb_66
			decb	
			bne	gb_67
			staa	player_up
			ldab	#$82
			stab	thread_priority
			ldx	#gj_31
			jsr	newthread_sp
			ldab	adj_gameadjust4
			andb	#$0F
			jsr	macro_start
			SETRAM_($0A,$00)			;RAM$0A=$00
gb_8E			ADDRAM_($0A,$01)			;RAM$0A+=$01
			.db $5B,$FC,$E1,$00,$08		;BNE_RAM$01==#0 to gb_8D
			SOL_($EE)				;Turn ON Sol#14:bell
			SLEEP_(40)
			SOL_($0E)				;Turn OFF Sol#14:bell
			SLEEP_(32)
gb_8D			.db $5B,$FD,$EA,$E0,$EC		;BNE_RAM$0A>=#224 to gb_8E
			CPUX_					;Resume CPU Execution
			ldaa	#$82
			staa	thread_priority
			ldx	#gj_3D
			jsr	newthread_sp
			jmp	init_player_up
gb_66			pshb	
			psha	
			ldx	#lampflashflag+5
			asla	
			asla	
			jsr	xplusa
			stx	temp1
			aslb	
			aslb	
			ldx	#lampflashflag+5
			jsr	xplusb
gb_87			jsr	score2hex
			tab	
			inx	
			stx	temp2
			ldx	temp1
			jsr	score2hex
			cba	
			bne	gb_86
			inx	
			stx	temp1
			ldx	temp2
			bra	gb_87
gb_86			pula	
			pulb	
			bcc	gb_9C
			tba	
gb_9C			rts	
gj_3D			ldab	#$20
			ldx	#adj_gameadjust3
			jsr	cmosinc_a
			staa	game_ram_c
			clr	game_ram_b
gj_42			ldaa	game_ram_c
			staa	mbip_b0
			decb	
			jsr	macro_start
			PRI_($82)				;Priority=#82
			.db $5A,$FB,$FC,$E1,$00,$FD,$EB,$00,$0B;BEQ_(RAM$0B>=#0 || RAM$01==#0) to gb_A5
			SSND_($15)				;Sound #15
			SLEEPI_($1)				;Delay RAM$01
			EXE_($04)				;CPU Execute Next 4 Bytes
			ldaa	#$FF
			staa	mbip_b0
			SLEEPI_($1)				;Delay RAM$01
			JMPD_(gj_42)			

gb_A5			EXE_($0D)				;CPU Execute Next 13 Bytes
			jsr	update_eb_count
			ldaa	#$82
			staa	thread_priority
			ldx	#gj_45
			jsr	newthread_sp
gj_44			EXE_($09)				;CPU Execute Next 9 Bytes
			ldaa	game_ram_c
			adda	#$99
			daa	
			staa	mbip_b0
			staa	game_ram_c
			.db $5A,$FC,$E0,$00,$0D		;BEQ_RAM$00==#0 to gb_04
			SSND_($0D)				;Sound #0D
			SLEEP_(32)
			SSND_($15)				;Sound #15
			EXE_($04)				;CPU Execute Next 4 Bytes
			ldaa	#$FF
			staa	mbip_b0
			SLEEP_(32)
			JMPR_(gj_44)			
gb_04			PRI_($86)				;Priority=#86
			SOL_($F8)				;Turn ON Sol#8:dt_left_release
			REMTHREADS_($F8,$80)		;Remove Multiple Threads Based on Priority
			BITON_($60)				;Turn ON: Bit#20
			EXE_($03)				;CPU Execute Next 3 Bytes
			inc	flag_gameover
gb_2C			SLEEP_(15)
			JSRD_(gj_07)			
			.db $5B,$FD,$E0,$02,$F7		;BNE_RAM$00>=#2 to gb_2C
			EXE_($0A)				;CPU Execute Next 10 Bytes
			ldaa	#$01
			staa	thread_priority
			ldx	#outhole_main
			jsr	newthread_sp
			SETRAM_($0C,$28)			;RAM$0C=$28
gb_2D			SLEEP_(15)
			ADDRAM_($0C,$FF)			;RAM$0C+=$FF
			.db $5A,$FE,$01,$01,$F8		;BEQ_(LAMP#01(bip) P LAMP#01(bip)) to gb_2D
			BITOFF_($E0,$61)			;Turn OFF: Bit#20, Bit#21
			EXE_($0D)				;CPU Execute Next 13 Bytes
			clra	
			staa	flag_timer_bip
			jsr	store_display_mask
			ldaa	spare_ram+1
			staa	comma_flags
			jsr	update_commas
			SWCLR_($89),($0A)			;Clear Sw#: $09(upper_eject) $0A(lower_eject)
			SLEEP_(64)
			.db $58,$F4,$19,$DB,$2E		;BEQ_LampOn/Flash#19 to gj_11
			JMPD_($FA21)			

gj_1B			jsr	gb_02
			ldaa	#$7F
			ldx	#dmask_p1
			staa	$00,X
			staa	$01,X
			staa	$02,X
			staa	$03,X
			ldaa	player_up
			jsr	xplusa
			clr	$00,X
			jsr	disp_mask
			anda	comma_flags
			staa	comma_flags
			rts	
gj_31			bsr	gj_1B
gb_8B			ldab	#$40
gb_8C			ldx	#score_p1_b1
			clra	
gb_8A			psha	
			cmpa	player_up
			beq	gb_88
			ldaa	game_ram_a
			bsr	gb_89
gb_88			inx	
			inx	
			inx	
			inx	
			pula	
			inca	
			cmpa	#$04
			bne	gb_8A
			jsr	addthread
			.db $04

			lsrb	
			bcs	gb_8B
			bra	gb_8C
gb_89			stx	temp1
			pshb	
			staa	temp3
			ldaa	#$04
			staa	temp2
gb_9F			ldaa	#$FF
			aslb	
			bcc	gb_9D
			ldaa	temp3
			asla	
			asla	
			asla	
			asla	
			oraa	#$0F
gb_9D			aslb	
			bcc	gb_9E
			anda	#$F0
			adda	temp3
gb_9E			staa	$00,X
			inx	
			dec	temp2
			bne	gb_9F
			pulb	
			ldx	temp1
			rts	
gj_45			jsr	macro_start
gb_A7			JSRR_(gj_1F)			
			SLEEP_(80)
			.db $5B,$60,$F9			;BNE_BIT#20 to gb_A7
gj_41			KILL_					;Remove This Thread

			.db $56,$59,$57,$47,$60,$61,$62,$DE,$D2,$55,$D1,$54,$DF,$D0,$53,$48
			.db $49,$4A,$4B,$4C,$CD,$5D,$CE,$5C,$CF,$5B,$5A,$58,$46

gj_40			ldx	#gj_41
			stx	spare_ram+2
gb_A4			ldx	spare_ram+2
			inx	
			cpx	#gj_40
			beq	gb_A3
			ldab	$00,X
			stx	spare_ram+2
			tba	
			anda	#$7F
			jsr	lamp_on_b
			tstb	
			bmi	gb_A4
			jsr	addthread
			.db $03

			bra	gb_A4
gb_A3			ldx	#gj_41
			stx	spare_ram+2
gb_A6			ldx	spare_ram+2
			inx	
			cpx	#gj_40
			beq	gj_40
			ldab	$00,X
			stx	spare_ram+2
			tba	
			anda	#$7F
			jsr	lamp_off_b
			tstb	
			bmi	gb_A6
			jsr	addthread
			.db $03

			bra	gb_A6
gj_27			jsr	macro_start
			JSRR_(gj_37)			
			SLEEP_(192)
			JMPR_(gb_81)			
gj_37			PRI_($32)				;Priority=#32
gb_94			SLEEP_(5)
			.db $5A,$FB,$FB,$FE,$F2,$FF,$32,$55,$54,$F5;BEQ_(BIT#14 || (BIT#15 || (BIT#FFFFFFF2 P #FF))) to gb_94
			REMTHREADS_($FF,$60)		;Remove Multiple Threads Based on Priority
			BITON_($58)				;Turn ON: Bit#18
			.db $5B,$52,$07			;BNE_BIT#12 to gb_95
			EXE_($06)				;CPU Execute Next 6 Bytes
			ldx	#gj_3F
			jsr	newthread_06
gb_95			EXE_($0A)				;CPU Execute Next 10 Bytes
			ldaa	#$32
			staa	thread_priority
			ldx	#gj_40
			jsr	newthread_sp
			.db $5A,$F1,$01			;BEQ_GAME to gb_96
			SSND_($04)				;Sound #04
gb_96			BE28_($51)				;Effect: Range #51
			BE29_($11)				;Effect: Range #11
			MRTS_					;Macro RTS, Save MRA,MRB

gj_3F			jsr	macro_start
			PRI_($30)				;Priority=#30
gj_43			SSND_($1E)				;Sound #1E
			SLEEP_(5)
			JMPR_(gj_43)			
gj_24			jsr	macro_start
			JSRR_(gj_37)			
			SETRAM_($02,$03)			;RAM$02=$03
gb_80			BITON2_($7E)			;Turn ON: Lamp#3E(bonus_10)
			BITON2_($7F)			;Turn ON: Lamp#3F(bonus_20)
			SLEEP_(6)
			BE28_($01)				;Effect: Range #01
			SLEEP_(6)
			BE28_($02)				;Effect: Range #02
			SLEEP_(6)
			BE28_($03)				;Effect: Range #03
			SLEEP_(6)
			SETRAM_($00,$63)			;RAM$00=$63
			SETRAM_($01,$68)			;RAM$01=$68
gb_7E			BITONP2_($00)			;Turn ON Lamp/Bit @RAM:00
			BITONP2_($01)			;Turn ON Lamp/Bit @RAM:01
			SLEEP_(6)
			EXE_($02)				;CPU Execute Next 2 Bytes
			inca	
			incb	
			.db $5B,$FD,$E0,$67,$F3		;BNE_RAM$00>=#103 to gb_7E
			BITOFF2_($7E)			;Turn OFF: Lamp#3E(bonus_10)
			BITOFF2_($7F)			;Turn OFF: Lamp#3F(bonus_20)
			SLEEP_(6)
			BE29_($01)				;Effect: Range #01
			SLEEP_(6)
			BE29_($02)				;Effect: Range #02
			SLEEP_(6)
			BE29_($03)				;Effect: Range #03
			SLEEP_(6)
			SETRAM_($00,$63)			;RAM$00=$63
			SETRAM_($01,$68)			;RAM$01=$68
gb_7F			BITOFFP2_($00)			;Turn OFF Lamp/Bit @RAM:00
			BITOFFP2_($01)			;Turn OFF Lamp/Bit @RAM:01
			SLEEP_(6)
			EXE_($02)				;CPU Execute Next 2 Bytes
			inca	
			incb	
			.db $5B,$FD,$E0,$67,$F3		;BNE_RAM$00>=#103 to gb_7F
			SLEEP_(6)
			ADDRAM_($02,$FF)			;RAM$02+=$FF
			.db $5B,$FC,$E2,$00,$BA		;BNE_RAM$02==#0 to gb_80
			.db $5B,$52,$16			;BNE_BIT#12 to gb_81
			BITOFF_($52)			;Turn OFF: Bit#12
			JSRDR_(gj_38)		
			SETRAM_($00,$20)			;RAM$00=$20
gb_82			BE2E_($8B,$02)			;Effect: Range #8B Range #02
			BE2D_($8C,$83,$01)		;Effect: Range #8C Range #83 Range #01
			SSND_($1E)				;Sound #1E
			SLEEP_(4)
			ADDRAM_($00,$FF)			;RAM$00+=$FF
			.db $5B,$FC,$E0,$00,$F0		;BNE_RAM$00==#0 to gb_82
gb_81			REMTHREADS_($F0,$30)		;Remove Multiple Threads Based on Priority
			JSR_(gj_39)				
			BITOFF_($C6,$D6,$D7,$58)	;Turn OFF: Bit#06, Bit#16, Bit#17, Bit#18
			BE29_($D1,$11)			;Effect: Range #D1 Range #11
			BITON2_($1E)			;Turn ON: Lamp#1E(upper_eject_lock)
gj_3C			KILL_					;Remove This Thread

			.db $63,$65,$67,$68,$6A,$6C,$6D,$6F,$71,$73,$77,$7A,$7D

gj_38			ldx	#gj_3C
			stx	sys_temp1
gb_98			ldx	sys_temp1
			inx	
			cpx	#gj_38
			beq	gb_97
			ldaa	$00,X
			stx	sys_temp1
			jsr	lamp_on_b
			bra	gb_98
gb_97			rts	
gj_01			jsr	macro_start
			PRI_($70)				;Priority=#70
			BITON_($59)				;Turn ON: Bit#19
			REMTHREADS_($F8,$70)		;Remove Multiple Threads Based on Priority
			JSRDR_(gj_2A)		
			EXE_($02)				;CPU Execute Next 2 Bytes
			clra	
			clrb	
			SLEEP_(88)
gj_3A			.db $5A,$40,$1D			;BEQ_BIT#00 to gb_45
			CPUX_					;Resume CPU Execution
gb_65			eora	#$80
			eorb	#$01
gb_64			asra	
			psha	
			anda	#$7F
			bsr	gb_63
			staa	$00,X
			pshb	
			jsr	disp_mask
			coma	
			anda	comma_flags
			staa	comma_flags
			jsr	update_commas
			pulb	
			jsr	addthread
			.db $03

			pula	
			psha	
			anda	#$01
			cba	
			pula	
			bne	gb_64
			tstb	
			bne	gb_65
			jsr	macro_start
			SLEEP_(24)
			JMPR_(gj_3A)			
gb_63			psha	
			ldaa	player_up
			ldx	#dmask_p1
			jsr	xplusa
			pula	
			rts	
gj_2A			bsr	gb_63
			clr	$00,X
			jmp	update_commas
gj_32			jsr	macro_start
			PRI_($00)				;Priority=#00
gj_3E			SSND_($10)				;Sound #10
			BITOFF_($59)			;Turn OFF: Bit#19
gb_A0			SLEEP_(192)
			.db $5B,$59,$FB			;BNE_BIT#19 to gb_A0
			JMPR_(gj_3E)			
gameover_entry	ldx	#gj_02
			jsr	newthread_06
			ldx	#gj_03
			jsr	newthread_06
			ldx	#gj_04
			jsr	newthread_06
			ldx	#gj_05
			jsr	newthread_06
			ldx	#gj_06
			jsr	newthread_06
			jsr	macro_start
			BE29_($D1,$11)			;Effect: Range #D1 Range #11
			SSND_($12)				;Sound #12
			BE19_($11)				;Effect: Range #11
			BE18_($93,$84,$92,$00)		;Effect: Range #93 Range #84 Range #92 Range #00
			BITON_($86,$96,$BE,$1F)		;Turn ON: Lamp#06(barr_dt_bank), Lamp#16(left_special), Lamp#3E(bonus_10), Lamp#1F(upper_eject_cb)
			BITFL_($98,$19)			;Flash: Lamp#18(lamp_spinner), Lamp#19(shootagain_pf)
gj_17			BE1E_($87,$8D,$14)		;Effect: Range #87 Range #8D Range #14
			BE1B_($85,$06)			;Effect: Range #85 Range #06
			SLEEP_(8)
			JMPR_(gj_17)			
gj_03			jsr	macro_start
gj_2B			BE19_($08)				;Effect: Range #08
			SETRAM_($00,$15)			;RAM$00=$15
gb_4D			BE1A_($08)				;Effect: Range #08
			SLEEP_(10)
			.db $5B,$F6,$08,$F9		;BNE_RangeON#08 to gb_4D
			BE19_($08)				;Effect: Range #08
			BE1A_($89,$0A)			;Effect: Range #89 Range #0A
gb_4E			BE1E_($09)				;Effect: Range #09
			SLEEP_(2)
			BE1D_($0A)				;Effect: Range #0A
			SLEEP_(4)
			ADDRAM_($00,$FF)			;RAM$00+=$FF
			.db $5B,$FC,$E0,$00,$F3		;BNE_RAM$00==#0 to gb_4E
			JMPR_(gj_2B)			
gj_04			ldx	#gj_12
			jsr	newthread_06
			ldx	#gj_13
			jsr	newthread_06
			jsr	addthread
			.db $FF

			ldx	#gj_14
			jsr	newthread_06
			ldx	#gj_15
			jsr	newthread_06
			jsr	addthread
			.db $FF

			bra	gj_04
gj_05			ldx	#gj_16
			jsr	newthread_06
			jsr	addthread
			.db $FF

			bra	gj_05
			.db $0B

			.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
			.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
			.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
			.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
			.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
			.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
			.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
			.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
			.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
			.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
			.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
			.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
			.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
			.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
			.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
			.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
			.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
			.db $00,$00,$00

 	.org $e000

;---------------------------------------------------------------------------
;  Default game data and basic system tables start at $e000, these can not  
;  ever be moved
;---------------------------------------------------------------------------

gr_gamenumber		.dw $2510
gr_romrevision		.db $F1
gr_cmoscsum			.db $B2,$A5
gr_backuphstd		.db $25
gr_replay1			.db $12
gr_replay2			.db $25
gr_replay3			.db $00
gr_replay4			.db $00
gr_matchenable		.db $00
gr_specialaward		.db $00
gr_replayaward		.db $00
gr_maxplumbbobtilts	.db $03
gr_numberofballs		.db $03
gr_gameadjust1		.db $01
gr_gameadjust2		.db $00
gr_gameadjust3		.db $30
gr_gameadjust4		.db $00
gr_gameadjust5		.db $00
gr_gameadjust6		.db $00
gr_gameadjust7		.db $00
gr_gameadjust8		.db $00
gr_gameadjust9		.db $01
gr_hstdcredits		.db $03
gr_max_extraballs		.db $04
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

gr_maxthreads		.db $1D
gr_extendedromtest	.db $00
gr_lastswitch		.db (switchtable_end-switchtable)/3
gr_numplayers		.db $03

gr_lamptable_ptr		.dw lamptable
gr_switchtable_ptr	.dw switchtable
gr_soundtable_ptr		.dw soundtable

gr_lampflashrate		.db $05

gr_specialawardsound	.db $0D	;Special Sound
gr_p1_startsound		.db $1A
gr_p2_startsound		.db $1B
gr_p3_startsound		.db $1B
gr_p4_startsound		.db $1B
gr_matchsound		.db $1C
gr_highscoresound		.db $1E
gr_gameoversound		.db $1D
gr_creditsound		.db $00

gr_eb_lamp_1		.db $19
gr_eb_lamp_2		.db $00
gr_lastlamp			.db $7F
gr_hs_lamp			.db $05
gr_match_lamp		.db $04
gr_bip_lamp			.db $01
gr_gameover_lamp		.db $03
gr_tilt_lamp		.db $02

gr_gameoverthread_ptr	.dw gameover_entry

gr_switchtypetable
				.db $00,$02
				.db $00,$09
				.db $00,$04
				.db $1A,$14
				.db $02,$05
				.db $08,$05
				.db $00,$01

gr_playerstartdata	.db $02,$00,$00,$00,$00
				.db $00,$20,$00,$00,$00
				.db $00,$00,$00,$00,$00
				.db $00,$00,$00,$00,$00

gr_playerresetdata	.db $C3,$00,$FF,$FE,$FF
				.db $FF,$01,$00,$80,$FF
				.db $03,$04,$00,$00,$00
				.db $00,$00,$00,$00,$00

gr_switch_event		rts\ .db $00	;(Switch Event)
gr_sound_event		rts\ .db $00	;(Sound Event )
gr_score_event		bra score_event	;(Score Event)
gr_eb_event		rts\ .db $00		;(Extra Ball Event)
gr_special_event		rts\ .db $00	;(Special Event)
gr_macro_event		rts\ .db $00	;(Start Macro Event)
gr_ballstart_event		bra ballstart_event;(Ball Start Event)
gr_addplayer_event		rts\ .db $00;(Add Player Event)
gr_gameover_event		bra gameover_event;(Game Over Event)
gr_hstdtoggle_event		rts\ .db $00;(HSTD Toggle Event)

			.dw hook_reset		;(From $E89F)Reset
			.dw hook_mainloop		;(From $E8B7)Main Loop Begin
			.dw hook_coin		;(From $F770)Coin Accepted
			.dw hook_gamestart	;(From $F847)New Game Start
			.dw hook_playerinit	;(From $F8D8)Init New Player
			.dw hook_outhole		;(From $F9BA)Outhole

;------------------------ end system data ---------------------------

gr_irq_entry	jmp	sys_irq
ballstart_event
gr_swi_entry	ldaa	flag_tilt
			beq	hook_mainloop
			jsr	killthread
gameover_event	ldaa	num_players
			jsr	macro_start
			.db $5A,$FB,$FC,$D3,$00,$FC,$E0,$00,$0D;BEQ_(RAM$00==#0 || ADJ#3==#0) to gb_25
			JMP_(gj_11)				

sw_hstd_res		JSRD_(restore_hstd)		
			KILL_					;Remove This Thread

hook_coin		jsr	macro_start
			SOL_($6E)				;Turn ON Sol#14:bell
			SLEEP_(15)
gb_25			CPUX_					;Resume CPU Execution
hook_mainloop
hook_reset		rts	
hook_gamestart	jsr	macro_start
			SWCLR_($89),($0A)			;Clear Sw#: $09(upper_eject) $0A(lower_eject)
			BITON_($41)				;Turn ON: Bit#01
gj_18			JSRD_(gj_0C)			
			.db $5B,$F8,$0F,$02		;BNE_SW#0F to gb_26
			ADDRAM_($00,$01)			;RAM$00+=$01
gb_26			.db $5A,$FC,$E0,$03,$E8		;BEQ_RAM$00==#3 to gb_25
			SLEEP_(15)
			JMPR_(gj_18)			
sw_credit_button	PRI_($08)				;Priority=#08
			JSRDR_(gj_07)		
			.db $58,$FB,$FB,$41,$FA,$F3,$FC,$E0,$03,$F1,$61,$E1,$91;BEQ_(BIT#21 || ((GAME && (!RAM$00==#3)) || BIT#01)) to gb_05
			JMPD_(credit_button)		

score_event		ldx	#gj_01
			jsr	newthread_06
			inc	game_ram_b
			ins	
			ins	
			jsr	update_eb_count
			jsr	score_update
			jsr	update_commas
			ldx	#x_temp_2
			bsr	gb_01
			stab	x_temp_2
			ldx	pscore_buf
			bsr	gb_01
			jsr	$ECB7
			jmp	$EC18
gb_01			ldaa	$00,X
			ldab	$01,X
			bsr	gb_23
			jsr	split_ab
			aba	
			tab	
gb_23			cmpb	#$A0
			bcs	gb_24
			addb	#$10
gb_24			rts	
sw_plumbtilt	EXE_($06)				;CPU Execute Next 6 Bytes
			ldx	#gj_1A
			jsr	newthread_06
			SSND_($01)				;Sound #01
			JSRD_(tilt_warning)		
			.db $5A,$F0,$13			;BEQ_TILT to gb_03
			KILL_					;Remove This Thread

gj_1A			jsr	macro_start
			REMTHREADS_($F8,$A0)		;Remove Multiple Threads Based on Priority
			PRI_($A6)				;Priority=#A6
			BITON_($5F)				;Turn ON: Bit#1F
			SLEEP_(160)
			BITOFF_($5F)			;Turn OFF: Bit#1F
			KILL_					;Remove This Thread

sw_balltilt
sw_pf_tilt		JSRD_(do_tilt)			
gb_03			PRI_($A8)				;Priority=#A8
			BE29_($11)				;Effect: Range #11
			BE28_($51)				;Effect: Range #51
			SWCLR_($89),($0A)			;Clear Sw#: $09(upper_eject) $0A(lower_eject)
			SOL_($0E)				;Turn OFF Sol#14:bell
			.db $58,$61,$DB,$FF		;BEQ_BIT#21 to gb_04
			CPUX_					;Resume CPU Execution
			jsr	gj_1B
gb_30			clra	
			bsr	gb_2E
			bsr	gb_2F
			jsr	addthread
			.db $03

			bsr	gb_02
			bsr	gb_2F
			jsr	addthread
			.db $03

			bra	gb_30
gb_05			KILL_					;Remove This Thread

gb_2F			ldaa	player_up
			ldx	#dmask_p1
			jsr	xplusa
			clr	$00,X
			ldaa	#$19
			jmp	isnd_once
hook_outhole	clra	
			ldx	#dmask_p1
			staa	$00,X
			staa	$01,X
			staa	$02,X
			staa	$03,X
			ldaa	flag_bonusball
			jsr	macro_start
			SSND_($12)				;Sound #12
			.db $5A,$FB,$FC,$E0,$00,$F0,$02	;BEQ_(TILT || RAM$00==#0) to gb_2B
			JSRR_(gj_0A)			
gb_2B			BE29_($51)				;Effect: Range #51
			REMTHREADS_($F0,$70)		;Remove Multiple Threads Based on Priority
			REMTHREADS_($F0,$60)		;Remove Multiple Threads Based on Priority
			.db $5A,$60,$CA			;BEQ_BIT#20 to gb_05
			JMPR_(gb_25)			
gb_02			ldaa	#$FF
gb_2E			ldx	#score_p1_b1
			ldab	#$10
			jmp	write_range
hook_playerinit	ldaa	comma_flags
			staa	spare_ram
			bsr	gb_02
			jsr	macro_start
			REMTHREADS_($F0,$60)		;Remove Multiple Threads Based on Priority
			BITOFF_($41)			;Turn OFF: Bit#01
			BE29_($D1,$11)			;Effect: Range #D1 Range #11
			.db $5B,$61,$06			;BNE_BIT#21 to gb_27
			BE19_($91,$90,$0F)		;Effect: Range #91 Range #90 Range #0F
			BITON_($35)				;Turn ON: Lamp#35(bonus_1)
gb_27			.db $5B,$F6,$0F,$02		;BNE_RangeON#0F to gb_28
			BE19_($0F)				;Effect: Range #0F
gb_28			.db $5B,$F6,$10,$02		;BNE_RangeON#10 to gb_29
			BE19_($10)				;Effect: Range #10
gb_29			BITON_($45)				;Turn ON: Bit#05
			SOL_($48,$69)			;Turn ON Sol#8:dt_left_release Sol#8:dt_left_release
			SLEEP_(32)
			SETRAM_($01,$08)			;RAM$01=$08
			SETRAM_($02,$48)			;RAM$02=$48
			SETRAM_($00,$40)			;RAM$00=$40
gb_4F			.db $5A,$E2,$06			;BEQ_RAM$02 to gb_2A
			JSRD_(solbuf)			
			SLEEP_(7)
			JMPR_(gj_19)			
gb_2A			BITONP_($01)			;Turn ON Lamp/Bit @RAM:01
gj_19			EXE_($02)				;CPU Execute Next 2 Bytes
			inca	
			incb	
			ADDRAM_($02,$01)			;RAM$02+=$01
			.db $5B,$FC,$E2,$50,$EB		;BNE_RAM$02==#80 to gb_4F
			BITOFF_($45)			;Turn OFF: Bit#05
			.db $5B,$FC,$D5,$00,$03		;BNE_ADJ#5==#0 to gb_50
			BITON_($A3,$28)			;Turn ON: Lamp#23(lbull_5k), Lamp#28(rbull_2x)
gb_50			.db $5A,$FB,$61,$FD,$D2,$00,$07	;BEQ_(ADJ#2>=#0 || BIT#21) to gb_51
			EXE_($06)				;CPU Execute Next 6 Bytes
			ldx	#gj_32
			jsr	newthread_06
gb_51			SOL_($10)				;Turn ON Sol#0:dt_b_reset
			JSRDR_(gj_0C)		
			.db $5B,$FC,$E0,$03,$02		;BNE_RAM$00==#3 to gb_52
			JSRR_(gj_1F)			
gb_52			JSRR_(gj_1E)			
			EXE_($06)				;CPU Execute Next 6 Bytes
			ldx	#gj_06
			jsr	newthread_06
			KILL_					;Remove This Thread

gj_1F			JSRDR_(gj_0C)		
			.db $5A,$FB,$FB,$42,$F8,$0F,$FC,$E0,$00,$16;BEQ_(RAM$00==#0 || (SW#0F || BIT#02)) to gb_55
			SOL_($10)				;Turn ON Sol#0:dt_b_reset
			BITON_($42)				;Turn ON: Bit#02
			RAMCPY_($1,$0)			;Copy RAM;RAM,1 = RAM,0
gb_56			SOL_($4B)				;Turn ON Sol#11:ball_thrower
			SLEEP_(96)
			JSRDR_(gj_0C)		
			.db $5B,$FB,$FD,$E1,$E0,$F8,$0F,$F2	;BNE_(SW#0F || RAM$01>=#224) to gb_56
			BITOFF_($42)			;Turn OFF: Bit#02
gb_55			MRTS_					;Macro RTS, Save MRA,MRB

gj_06			jsr	macro_start
			PRI_($00)				;Priority=#00
			BITON2_($1D)			;Turn ON: Lamp#1D(lower_eject_lock)
gj_2C			SLEEP_(5)
			BE2E_($4E)				;Effect: Range #4E
			JMPR_(gj_2C)			
gj_07			pshb	
			clra	
			ldab	$62
			andb	#$FE
gb_32			bpl	gb_31
			inca	
gb_31			aslb	
			bne	gb_32
			pulb	
			rts	
gj_0C			pshb	
			clra	
			ldab	$62
			andb	#$70
			bra	gb_32
sw_barracora_lane	SETRAM_($00,$0C)			;RAM$00=$0C
			JSRR_(gj_08)			
			SSND_($08)				;Sound #08
			.db $5A,$F5,$04,$15		;BEQ_RangeOFF#04 to gb_06
			SETRAM_($00,$08)			;RAM$00=$08
gb_08			.db $5B,$E0,$02			;BNE_RAM$00 to gb_07
			JSRDR_(gj_09)		
gb_07			ADDRAM_($00,$01)			;RAM$00+=$01
			.db $5B,$FC,$E0,$10,$F4		;BNE_RAM$00==#16 to gb_08
			EXE_($06)				;CPU Execute Next 6 Bytes
			ldx	#gj_16
			jsr	newthread_06
gb_06			KILL_					;Remove This Thread

gj_16			jsr	macro_start
			PRI_($32)				;Priority=#32
			.db $5A,$58,$F7			;BEQ_BIT#18 to gb_06
			BE29_($04)				;Effect: Range #04
			BE28_($44)				;Effect: Range #44
			SETRAM_($00,$18)			;RAM$00=$18
			BITON2_($48)			;Turn ON: Lamp#08(lamp_b)
			BITON2_($49)			;Turn ON: Lamp#09(lamp_a1)
			BITON2_($4C)			;Turn ON: Lamp#0C(lamp_c)
			BITON2_($4D)			;Turn ON: Lamp#0D(lamp_o)
gb_77			BE2D_($04)				;Effect: Range #04
			.db $5A,$F1,$01			;BEQ_GAME to gb_76
			SSND_($09)				;Sound #09
gb_76			SLEEP_(4)
			ADDRAM_($00,$FF)			;RAM$00+=$FF
			.db $5B,$FC,$E0,$00,$F2		;BNE_RAM$00==#0 to gb_77
			BE29_($04)				;Effect: Range #04
			SETRAM_($00,$08)			;RAM$00=$08
gb_78			BITOFFP2_($00)			;Turn OFF Lamp/Bit @RAM:00
			SLEEP_(8)
			ADDRAM_($00,$01)			;RAM$00+=$01
			.db $5B,$FD,$E0,$0F,$F6		;BNE_RAM$00>=#15 to gb_78
			KILL_					;Remove This Thread

sw_left_flipper	BE1D_($0A)				;Effect: Range #0A
			KILL_					;Remove This Thread

sw_right_flipper	BE1E_($09)				;Effect: Range #09
			KILL_					;Remove This Thread

sw_1_4_lane
sw_2_5_lane
sw_3_6_lane		POINTS_(1,1000)			;1000 Points
			SSND_($03)				;Sound #03
			JSRDR_(gj_09)		
			.db $5A,$E0,$40			;BEQ_RAM$00 to gb_14
			BITONP_($00)			;Turn ON Lamp/Bit @RAM:00
			.db $5B,$F6,$09,$39		;BNE_RangeON#09 to gb_15
			BE19_($09)				;Effect: Range #09
			BE1A_($05)				;Effect: Range #05
			EXE_($07)				;CPU Execute Next 7 Bytes
			psha	
			ldaa	#$32
			staa	thread_priority
			ldaa	#$C5
			EXE_($07)				;CPU Execute Next 7 Bytes
			ldx	#gj_23
			jsr	newthread_sp
			pula	
			BITON_($50)				;Turn ON: Bit#10
			.db $5A,$58,$16			;BEQ_BIT#18 to gb_16
			BE28_($49)				;Effect: Range #49
			BE29_($09)				;Effect: Range #09
			BE2A_($09)				;Effect: Range #09
			SETRAM_($00,$10)			;RAM$00=$10
			SSND_($02)				;Sound #02
gb_17			SLEEP_(4)
			BE2D_($09)				;Effect: Range #09
			ADDRAM_($00,$FF)			;RAM$00+=$FF
			.db $5B,$FC,$E0,$00,$F6		;BNE_RAM$00==#0 to gb_17
			BE29_($C9,$09)			;Effect: Range #C9 Range #09
gb_16			.db $5B,$FA,$50,$51,$05		;BNE_(BIT#11 && BIT#10) to gb_15
			BITON_($1F)				;Turn ON: Lamp#1F(upper_eject_cb)
			BITOFF_($D0,$51)			;Turn OFF: Bit#10, Bit#11
gb_15			KILL_					;Remove This Thread

gb_14			ADDRAM_($00,$03)			;RAM$00+=$03
			.db $5A,$E0,$FA			;BEQ_RAM$00 to gb_15
			BITONP_($00)			;Turn ON Lamp/Bit @RAM:00
			.db $5B,$F6,$0A,$F4		;BNE_RangeON#0A to gb_15
			BE1A_($06)				;Effect: Range #06
			EXE_($07)				;CPU Execute Next 7 Bytes
			psha	
			ldaa	#$32
			staa	thread_priority
			ldaa	#$C6
			EXE_($07)				;CPU Execute Next 7 Bytes
			ldx	#gj_23
			jsr	newthread_sp
			pula	
			BITON_($51)				;Turn ON: Bit#11
			BE19_($0A)				;Effect: Range #0A
			.db $5A,$58,$D1			;BEQ_BIT#18 to gb_16
			BE28_($4A)				;Effect: Range #4A
			BE29_($0A)				;Effect: Range #0A
			BE2A_($0A)				;Effect: Range #0A
			SETRAM_($00,$10)			;RAM$00=$10
			SSND_($02)				;Sound #02
gb_3F			SLEEP_(4)
			BE2E_($0A)				;Effect: Range #0A
			ADDRAM_($00,$FF)			;RAM$00+=$FF
			.db $5B,$FC,$E0,$00,$F6		;BNE_RAM$00==#0 to gb_3F
			BE29_($CA,$0A)			;Effect: Range #CA Range #0A
			JMPR_(gb_16)			
gj_23			ldab	#$10
gb_5D			jsr	lampm_f
			jsr	addthread
			.db $04

			decb	
			bne	gb_5D
			jsr	lampm_off
			jmp	killthread
sw_upper_eject	.db $5A,$FB,$F0,$F1,$1D		;BEQ_(GAME || TILT) to gb_09
			SETRAM_($00,$5E)			;RAM$00=$5E
			.db $5B,$F8,$09,$2F		;BNE_SW#09 to gb_0A
			.db $5A,$43,$20			;BEQ_BIT#03 to gb_0B
			POINTS_(1,10000)			;10000 Points
			.db $5B,$1F,$09			;BNE_LAMP#1F(upper_eject_cb) to gb_0C
			JSRR_(gj_0A)			
			BE19_($81,$0D)			;Effect: Range #81 Range #0D
			BITON_($35)				;Turn ON: Lamp#35(bonus_1)
			BITOFF_($1F)			;Turn OFF: Lamp#1F(upper_eject_cb)
gb_0C			SETRAM_($00,$5E)			;RAM$00=$5E
			.db $5A,$1E,$0E			;BEQ_LAMP#1E(upper_eject_lock) to gb_0D
			SSND_($14)				;Sound #14
gb_09			BITON_($43)				;Turn ON: Bit#03
			SOL_($4C)				;Turn ON Sol#12:upper_eject
			SLEEP_(64)
gj_35			.db $5A,$F8,$09,$F6		;BEQ_SW#09 to gb_09
			BITOFF_($43)			;Turn OFF: Bit#03
gb_0B			KILL_					;Remove This Thread

gb_0D			BITONP2_($00)			;Turn ON Lamp/Bit @RAM:00
			SSND_($05)				;Sound #05
			REMTHREADS_($FF,$20)		;Remove Multiple Threads Based on Priority
			JSRR_(gj_1E)			
			JSRR_(gj_1F)			
			KILL_					;Remove This Thread

gb_0A			BITOFFP2_($00)			;Turn OFF Lamp/Bit @RAM:00
			KILL_					;Remove This Thread

gj_21			jsr	macro_start
			JMPR_(gj_35)			
sw_lower_eject	.db $5A,$FB,$F0,$F1,$4E		;BEQ_(GAME || TILT) to gb_0E
			SETRAM_($00,$5D)			;RAM$00=$5D
			.db $5B,$F8,$0A,$ED		;BNE_SW#0A to gb_0A
			.db $5A,$44,$51			;BEQ_BIT#04 to gb_0F
			.db $5B,$F5,$05,$04		;BNE_RangeOFF#05 to gb_10
			SETRAM_($00,$0C)			;RAM$00=$0C
			JMPR_(gj_0B)			
gb_10			SETRAM_($00,$04)			;RAM$00=$04
gb_3B			BE1C_($05)				;Effect: Range #05
			ADDRAM_($00,$18)			;RAM$00+=$18
			.db $5B,$F5,$05,$F8		;BNE_RangeOFF#05 to gb_3B
			EXE_($06)				;CPU Execute Next 6 Bytes
			ldx	#gj_2E
			jsr	newthread_06
gj_0B			JSRR_(gj_08)			
			.db $5B,$1D,$26			;BNE_LAMP#1D(lower_eject_lock) to gb_3C
			BITON_($40)				;Turn ON: Bit#00
			REMTHREADS_($FF,$20)		;Remove Multiple Threads Based on Priority
			JSRDR_(gj_0C)		
			EXE_($0A)				;CPU Execute Next 10 Bytes
			ldab	#$F3
			cmpa	#$01
			beq	gb_57
			ldab	#$F2
gb_57			stab	spare_ram+4
			JSRD_(gj_20)			
			EXE_($0A)				;CPU Execute Next 10 Bytes
			ldaa	#$32
			staa	thread_priority
			ldx	#gj_24
			jsr	newthread_sp
			SLEEP_(128)
			SETRAM_($00,$5D)			;RAM$00=$5D
			JMPR_(gb_0D)			
gb_3C			SSND_($14)				;Sound #14
gb_0E			BITON_($44)				;Turn ON: Bit#04
			SOL_($4D)				;Turn ON Sol#13:lower_eject
			SLEEP_(64)
gj_36			.db $5A,$F8,$0A,$F6		;BEQ_SW#0A to gb_0E
			BITOFF_($44)			;Turn OFF: Bit#04
gb_0F			KILL_					;Remove This Thread

gj_22			jsr	macro_start
			JMPR_(gj_36)			
sw_center_trough
sw_left_trough
sw_right_trough	.db $5A,$FB,$FB,$FB,$42,$41,$F8,$0F,$61,$F0;BEQ_(BIT#21 || (SW#0F || (BIT#01 || BIT#02))) to gb_0F
			JSRD_(gj_0C)			
			.db $5B,$FC,$E0,$03,$08		;BNE_RAM$00==#3 to gb_11
			REMTHREADS_($F0,$A0)		;Remove Multiple Threads Based on Priority
			JSRDR_(gj_0D)		
			JMPD_(outhole_main)		

gb_11			EXE_($03)				;CPU Execute Next 3 Bytes
			dec	spare_ram+4
			.db $5B,$FD,$E0,$01,$0C		;BNE_RAM$00>=#1 to gb_3D
			BITOFF_($40)			;Turn OFF: Bit#00
			REMTHREADS_($F0,$A0)		;Remove Multiple Threads Based on Priority
			JSRDR_(gb_02)		
			JSRD_($F8A3)			
			JSRDR_(gj_0D)		
gb_3D			JSRDR_(gj_07)		
			.db $5A,$FB,$F3,$FC,$E0,$03,$F8,$0F,$08;BEQ_(SW#0F || (!RAM$00==#3)) to gb_3E
			BE29_($13)				;Effect: Range #13
			BE19_($13)				;Effect: Range #13
			JSRR_(gj_1E)			
			JSRDR_(gj_0E)		
gb_3E			KILL_					;Remove This Thread

gj_0D			ldaa	spare_ram
			staa	comma_flags
			jmp	update_commas
sw_outhole		SOL_($4A)				;Turn ON Sol#10:ball_release
			SLEEP_(96)
			SWCLR_($0B)				;Clear Sw#: $0B(outhole)
			KILL_					;Remove This Thread

gj_1E			REMTHREADS_($FF,$70)		;Remove Multiple Threads Based on Priority
			SETRAM_($00,$70)			;RAM$00=$70
			EXE_($0B)				;CPU Execute Next 11 Bytes
			staa	thread_priority
			clr	flag_timer_bip
			ldx	#$F8DD
			jsr	newthread_sp
			MRTS_					;Macro RTS, Save MRA,MRB

sw_bottom_jet	POINTS_(1,1000)			;1000 Points
			SSND_($15)				;Sound #15
			KILL_					;Remove This Thread

sw_left_jet
sw_right_jet	POINTS_(1,100)			;100 Points
			SSND_($15)				;Sound #15
			KILL_					;Remove This Thread

sw_5bank_10
sw_lleft_10
sw_lower_10
sw_lsling_10
sw_rsling_10
sw_upper_10		POINTS_(1,10)			;10 Points
			SSND_($00)				;Sound #00
			KILL_					;Remove This Thread

sw_left_return
sw_right_return	JSRDR_(gj_09)		
			POINTS_(1,1000)			;1000 Points
			SSND_($0B)				;Sound #0B
			KILL_					;Remove This Thread

sw_left_outlane
sw_right_outlane	POINTS_(5,1000)			;5000 Points
			SSND_($0F)				;Sound #0F
			JSRDR_(gj_09)		
			.db $5B,$E0,$10			;BNE_RAM$00 to gb_18
			BE19_($07)				;Effect: Range #07
			SPEC_					;Award Special
			BITON_($52)				;Turn ON: Bit#12
			SETRAM_($00,$32)			;RAM$00=$32
			EXE_($08)				;CPU Execute Next 8 Bytes
			staa	thread_priority
			ldx	#gj_24
			jsr	newthread_sp
gb_18			KILL_					;Remove This Thread

sw_ball_shooter	.db $5A,$F8,$0F,$13		;BEQ_SW#0F to gb_12
			SSND_($14)				;Sound #14
			PRI_($20)				;Priority=#20
			SLEEP_(240)
			SLEEP_(64)
			SOL_($F0)				;Turn ON Sol#0:dt_b_reset
			.db $5B,$40,$06			;BNE_BIT#00 to gb_13
			BE19_($13)				;Effect: Range #13
			BE29_($13)				;Effect: Range #13
			JSRDR_(gj_0E)		
gb_13			KILL_					;Remove This Thread

gb_12			REMTHREADS_($F8,$20)		;Remove Multiple Threads Based on Priority
			SOL_($10)				;Turn ON Sol#0:dt_b_reset
			KILL_					;Remove This Thread

gj_0E			ldx	#gj_21
			jsr	newthread_06
			ldx	#gj_22
			jmp	newthread_06
sw_left_bull	BE1A_($0B)				;Effect: Range #0B
gj_10			POINTS_(1,100)			;100 Points
			SSND_($06)				;Sound #06
			.db $5A,$FA,$27,$2C,$02		;BEQ_(LAMP#2C(rbull_10x) && LAMP#27(lbull_25k)) to gb_1B
			BITOFF_($47)			;Turn OFF: Bit#07
gb_1B			KILL_					;Remove This Thread

sw_right_bull	BE1A_($0C)				;Effect: Range #0C
			JMPR_(gj_10)			
sw_upper_right_bull	SETRAM_($00,$0C)		;RAM$00=$0C
			SSND_($19)				;Sound #19
			.db $5A,$F5,$06,$2A		;BEQ_RangeOFF#06 to gb_1C
			SETRAM_($00,$24)			;RAM$00=$24
			.db $5B,$22,$0F			;BNE_LAMP#22(urbull_eb) to gb_1D
			EB_					;Award Extra Ball
			EXE_($06)				;CPU Execute Next 6 Bytes
			ldx	#gj_27
			jsr	newthread_06
			.db $5A,$19,$02			;BEQ_LAMP#19(shootagain_pf) to gb_1E
			POINTS_(1,100000)			;100000 Points
gb_1E			BE19_($06)				;Effect: Range #06
gb_1D			.db $5A,$21,$02			;BEQ_LAMP#21(urbull_40k) to gb_1F
			SETRAM_($00,$14)			;RAM$00=$14
gb_1F			.db $5A,$FA,$FD,$D1,$00,$F3,$19,$02	;BEQ_((!LAMP#19(shootagain_pf)) && ADJ#1>=#0) to gb_20
			BE19_($06)				;Effect: Range #06
gb_20			EXE_($06)				;CPU Execute Next 6 Bytes
			ldx	#gj_28
			jsr	newthread_06
gb_1C			JSRR_(gj_08)			
			KILL_					;Remove This Thread

gj_08			.db $5B,$FB,$61,$40,$13		;BNE_(BIT#00 || BIT#21) to gb_33
			CPUX_					;Resume CPU Execution
			pshb	
			psha	
			anda	#$F8
			tab	
			jsr	gj_0C
			tsta	
			pula	
			bne	gb_53
			aslb	
gb_53			aba	
			pulb	
			jsr	macro_start
gb_33			JSRD_(score_main)			
			MRTS_					;Macro RTS, Save MRA,MRB

sw_spinner		PRI_($11)				;Priority=#11
			REMTHREADS_($F8,$10)		;Remove Multiple Threads Based on Priority
			.db $5B,$F4,$18,$0A		;BNE_LampOn/Flash#18 to gb_19
			POINTS_(1,1000)			;1000 Points
			SSND_($06)				;Sound #06
			BITON_($18)				;Turn ON: Lamp#18(lamp_spinner)
			SLEEP_(64)
			BITOFF_($18)			;Turn OFF: Lamp#18(lamp_spinner)
			KILL_					;Remove This Thread

gb_19			POINTS_(1,100)			;100 Points
			SSND_($07)				;Sound #07
			KILL_					;Remove This Thread

gj_09			ldx	#gj_1C
			psha	
			ldaa	#$01
			staa	thread_priority
			pula	
			jmp	newthread_sp
gj_1C			jsr	macro_start
gb_79			SLEEP_(4)
			.db $5A,$FB,$FB,$55,$54,$58,$F8	;BEQ_(BIT#18 || (BIT#14 || BIT#15)) to gb_79
			BITON_($55)				;Turn ON: Bit#15
			.db $5A,$3D,$19			;BEQ_BIT#FFFFFFFD to gb_7A
			BE29_($C1,$01)			;Effect: Range #C1 Range #01
			BE2A_($41)				;Effect: Range #41
gb_7B			SLEEP_(4)
			BE2E_($41)				;Effect: Range #41
			EXE_($04)				;CPU Execute Next 4 Bytes
			ldaa	$27
			anda	#$20
			.db $5A,$FC,$E0,$00,$F3		;BEQ_RAM$00==#0 to gb_7B
			BE29_($41)				;Effect: Range #41
			BE1A_($01)				;Effect: Range #01
gb_90			BITOFF_($55)			;Turn OFF: Bit#15
			KILL_					;Remove This Thread

gb_7A			.db $5B,$3F,$09			;BNE_BIT#FFFFFFFF to gb_8F
			POINTS_(1,1000)			;1000 Points
			.db $5A,$53,$F5			;BEQ_BIT#13 to gb_90
			JSRR_(gj_3B)			
			JMPR_(gb_90)			
gb_8F			SLEEP_(5)
			BE1C_($01)				;Effect: Range #01
			.db $5B,$F5,$01,$F9		;BNE_RangeOFF#01 to gb_8F
			.db $5B,$3E,$04			;BNE_BIT#FFFFFFFE to gb_A1
			BE1E_($0D)				;Effect: Range #0D
			JMPR_(gb_90)			
gb_A1			BITON_($3E)				;Turn ON: Lamp#3E(bonus_10)
			JMPR_(gb_90)			
gj_0A			SLEEP_(10)
			.db $5A,$FB,$55,$58,$FA		;BEQ_(BIT#18 || BIT#15) to gj_0A
			SSND_($12)				;Sound #12
			BITON_($54)				;Turn ON: Bit#14
			REMTHREADS_($FF,$60)		;Remove Multiple Threads Based on Priority
			SETRAM_($00,$00)			;RAM$00=$00
			JSRD_($F302)			
			BE28_($40)				;Effect: Range #40
			SETRAM_($00,$08)			;RAM$00=$08
			.db $5A,$F5,$02,$0A		;BEQ_RangeOFF#02 to gb_34
gb_35			ADDRAM_($00,$08)			;RAM$00+=$08
			BE2C_($02)				;Effect: Range #02
			SSND_($15)				;Sound #15
			SLEEP_(15)
			.db $5B,$F5,$82,$F6		;BNE_RangeOFF#82 to gb_35
gb_34			.db $5A,$F5,$03,$0C		;BEQ_RangeOFF#03 to gb_36
			RAMCPY_($1,$0)			;Copy RAM;RAM,1 = RAM,0
gb_37			RAMADD_($0,$1)			;RAM,0 += RAM,1
			BE2C_($03)				;Effect: Range #03
			SSND_($15)				;Sound #15
			SLEEP_(15)
			.db $5B,$F5,$83,$F6		;BNE_RangeOFF#83 to gb_37
gb_36			EXE_($02)				;CPU Execute Next 2 Bytes
			oraa	#$03
			SETRAM_($01,$0A)			;RAM$01=$0A
gj_1D			.db $5A,$F0,$27			;BEQ_TILT to gb_38
			.db $5A,$F5,$81,$11		;BEQ_RangeOFF#81 to gb_39
			BE2C_($01)				;Effect: Range #01
gj_2D			JSRD_(score_main)			
			SSND_($11)				;Sound #11
			SSND_($11)				;Sound #11
			.db $5A,$FC,$E1,$02,$02		;BEQ_RAM$01==#2 to gb_3A
			ADDRAM_($01,$FF)			;RAM$01+=$FF
gb_3A			SLEEPI_($1)				;Delay RAM$01
			JMPR_(gj_1D)			
gb_39			.db $5A,$F5,$8D,$0E		;BEQ_RangeOFF#8D to gb_38
			BE28_($01)				;Effect: Range #01
			.db $5B,$F7,$3E,$04		;BNE_BIT#3E to gb_54
			BITOFF2_($7E)			;Turn OFF: Lamp#3E(bonus_10)
			JMPR_(gj_2D)			
gb_54			BE2D_($0D)				;Effect: Range #0D
			JMPR_(gj_2D)			
gb_38			BE29_($40)				;Effect: Range #40
			BITOFF_($D4,$53)			;Turn OFF: Bit#14, Bit#13
			SSND_($12)				;Sound #12
			MRTS_					;Macro RTS, Save MRA,MRB

gj_39			.db $5B,$53,$0D			;BNE_BIT#13 to gb_99
gj_3B			EXE_($0C)				;CPU Execute Next 12 Bytes
			psha	
			ldaa	#$60
			staa	thread_priority
			pula	
			ldx	#gj_02
			jsr	newthread_sp
gb_99			MRTS_					;Macro RTS, Save MRA,MRB

sw_dt_a1
sw_dt_a2
sw_dt_a3
sw_dt_b
sw_dt_c
sw_dt_o
sw_dt_r
sw_dt_rr		.db $5A,$45,$1B			;BEQ_BIT#05 to gb_21
			SSND_($17)				;Sound #17
			POINTS_(1,1000)			;1000 Points
			ADDRAM_($00,$20)			;RAM$00+=$20
			RAMCPY_($1,$0)			;Copy RAM;RAM,1 = RAM,0
			ADDRAM_($01,$FF)			;RAM$01+=$FF
			.db $5A,$FB,$FB,$FC,$E0,$48,$FC,$E0,$4B,$E1,$08;BEQ_(RAM$01 || (RAM$00==#75 || RAM$00==#72)) to gb_22
			SSND_($0E)				;Sound #0E
			EXE_($05)				;CPU Execute Next 5 Bytes
			suba	#$08
			jsr	solbuf
gb_21			KILL_					;Remove This Thread

gb_22			EXE_($03)				;CPU Execute Next 3 Bytes
			suba	#$40
			incb	
			BITONP_($80,$01)			;Turn ON Lamp/Bit @RAM:80,80
			.db $5A,$FD,$E0,$0A,$15		;BEQ_RAM$00>=#10 to gb_43
			.db $5B,$F6,$0F,$EF		;BNE_RangeON#0F to gb_21
			BITON_($06)				;Turn ON: Lamp#06(barr_dt_bank)
			.db $5A,$FB,$61,$40,$02		;BEQ_(BIT#00 || BIT#21) to gb_44
			BITON_($1D)				;Turn ON: Lamp#1D(lower_eject_lock)
gb_44			SOL_($42,$41,$40)			;Turn ON Sol#2:dt_rr_reset Sol#2:dt_rr_reset Sol#2:dt_rr_reset
			BE19_($0F)				;Effect: Range #0F
			JMPR_(gj_29)			
gb_43			.db $5B,$F6,$10,$DA		;BNE_RangeON#10 to gb_21
			BITON_($07)				;Turn ON: Lamp#07(acora_dt_bank)
			.db $5A,$FB,$61,$40,$02		;BEQ_(BIT#00 || BIT#21) to gb_5F
			BITON_($1E)				;Turn ON: Lamp#1E(upper_eject_lock)
gb_5F			SOL_($47,$46,$45,$44,$43)	;Turn ON Sol#7:dt_a3_reset Sol#7:dt_a3_reset Sol#7:dt_a3_reset Sol#7:dt_a3_reset Sol#7:dt_a3_reset
			BE19_($10)				;Effect: Range #10
gj_29			BE1A_($02)				;Effect: Range #02
			EXE_($06)				;CPU Execute Next 6 Bytes
			ldx	#gj_15
			jsr	newthread_06
			.db $5B,$FA,$06,$07,$17		;BNE_(LAMP#07(acora_dt_bank) && LAMP#06(barr_dt_bank)) to gb_60
			BE1A_($03)				;Effect: Range #03
			.db $5B,$FA,$F6,$03,$F3,$5A,$04	;BNE_((!BIT#1A) && RangeON#03) to gb_61
			BITON_($5A)				;Turn ON: Bit#1A
			BE18_($07)				;Effect: Range #07
gb_61			BITOFF_($86,$07)			;Turn OFF: Lamp#06(barr_dt_bank), Lamp#07(acora_dt_bank)
			EXE_($06)				;CPU Execute Next 6 Bytes
			ldx	#gj_13
			jsr	newthread_06
gb_60			BITFL_($18)				;Flash: Lamp#18(lamp_spinner)
			REMTHREADS_($FF,$10)		;Remove Multiple Threads Based on Priority
			PRI_($10)				;Priority=#10
			SETRAM_($00,$0A)			;RAM$00=$0A
gb_62			SLEEP_(57)
			ADDRAM_($00,$FF)			;RAM$00+=$FF
			.db $5B,$FC,$E0,$00,$F7		;BNE_RAM$00==#0 to gb_62
			BITOFF_($18)			;Turn OFF: Lamp#18(lamp_spinner)
			KILL_					;Remove This Thread

sw_right_turnaround	.db $5B,$F5,$0B,$04	;BNE_RangeOFF#0B to gb_1A
			SETRAM_($00,$13)			;RAM$00=$13
			JMPR_(gj_0F)			
gb_1A			SETRAM_($00,$03)			;RAM$00=$03
			SETRAM_($01,$23)			;RAM$01=$23
gj_25			.db $5A,$FB,$F3,$E1,$FD,$E1,$27,$06	;BEQ_(RAM$01>=#39 || (!RAM$01)) to gj_0F
			ADDRAM_($00,$28)			;RAM$00+=$28
			ADDRAM_($01,$01)			;RAM$01+=$01
			JMPR_(gj_25)			
gj_0F			EXE_($02)				;CPU Execute Next 2 Bytes
			psha	
			clrb	
			.db $5A,$F5,$0C,$14		;BEQ_RangeOFF#0C to gb_40
			SETRAM_($00,$2C)			;RAM$00=$2C
			SETRAM_($01,$09)			;RAM$01=$09
			.db $5A,$E0,$0D			;BEQ_RAM$00 to gb_40
			SETRAM_($01,$05)			;RAM$01=$05
gb_41			EXE_($02)				;CPU Execute Next 2 Bytes
			deca	
			decb	
			.db $5A,$FA,$F3,$E0,$FD,$E0,$28,$F5	;BEQ_(RAM$00>=#40 && (!RAM$00)) to gb_41
gb_40			EXE_($02)				;CPU Execute Next 2 Bytes
			pula	
			nop	
gj_26			JSRD_(score_main)			
			.db $5A,$FC,$E1,$00,$04		;BEQ_RAM$01==#0 to gb_42
			ADDRAM_($01,$FF)			;RAM$01+=$FF
			JMPR_(gj_26)			
gb_42			SLEEP_(5)
			.db $5A,$FB,$46,$58,$FA		;BEQ_(BIT#18 || BIT#06) to gb_42
			SSND_($09)				;Sound #09
			SETRAM_($00,$12)			;RAM$00=$12
			JSRD_($F302)			
			EXE_($02)				;CPU Execute Next 2 Bytes
			clra	
			clrb	
gj_30			.db $5A,$F5,$8B,$06		;BEQ_RangeOFF#8B to gb_5E
			BE2C_($0B)				;Effect: Range #0B
			ADDRAM_($00,$01)			;RAM$00+=$01
			JMPR_(gj_30)			
gb_5E			.db $5A,$F5,$8C,$06		;BEQ_RangeOFF#8C to gb_83
			BE2C_($0C)				;Effect: Range #0C
			ADDRAM_($01,$01)			;RAM$01+=$01
			JMPR_(gb_5E)			
gb_83			.db $5A,$F5,$12,$1E		;BEQ_RangeOFF#12 to gb_9A
			.db $5A,$FA,$FC,$E0,$E1,$F3,$47,$0D	;BEQ_((!BIT#07) && RAM$00==#225) to gb_9B
			BE19_($12)				;Effect: Range #12
			EXE_($06)				;CPU Execute Next 6 Bytes
			ldx	#gj_14
			jsr	newthread_06
			BITOFF_($47)			;Turn OFF: Bit#07
			JMPR_(gb_9A)			
gb_9B			BITON_($47)				;Turn ON: Bit#07
			EXE_($06)				;CPU Execute Next 6 Bytes
			ldx	#gj_12
			jsr	newthread_06
gb_9A			.db $5B,$FC,$D5,$00,$03		;BNE_ADJ#5==#0 to gb_A2
			BITON_($A3,$28)			;Turn ON: Lamp#23(lbull_5k), Lamp#28(rbull_2x)
gb_A2			KILL_					;Remove This Thread

gj_12			jsr	macro_start
			PRI_($32)				;Priority=#32
			.db $5A,$F5,$12,$33		;BEQ_RangeOFF#12 to gb_68
			BITON_($46)				;Turn ON: Bit#06
			BITON2_($64)			;Turn ON: Lamp#24(lbull_10k)
			BITON2_($66)			;Turn ON: Lamp#26(lbull_20k)
			BITON2_($69)			;Turn ON: Lamp#29(rbull_3x)
			BITON2_($6B)			;Turn ON: Lamp#2B(rbull_5x)
			SETRAM_($00,$23)			;RAM$00=$23
			BE28_($52)				;Effect: Range #52
gb_6A			.db $5A,$F1,$01			;BEQ_GAME to gb_69
			SSND_($0A)				;Sound #0A
gb_69			SLEEP_(4)
			BE2E_($0B)				;Effect: Range #0B
			BE2D_($0C)				;Effect: Range #0C
			ADDRAM_($00,$FF)			;RAM$00+=$FF
			.db $5B,$FC,$E0,$00,$F0		;BNE_RAM$00==#0 to gb_6A
			SETRAM_($00,$23)			;RAM$00=$23
			SETRAM_($01,$28)			;RAM$01=$28
			BE29_($12)				;Effect: Range #12
gb_6B			SLEEP_(7)
			BITOFFP2_($00)			;Turn OFF Lamp/Bit @RAM:00
			BITOFFP2_($01)			;Turn OFF Lamp/Bit @RAM:01
			EXE_($02)				;CPU Execute Next 2 Bytes
			inca	
			incb	
			.db $5B,$FD,$E0,$27,$F3		;BNE_RAM$00>=#39 to gb_6B
			BITOFF_($46)			;Turn OFF: Bit#06
gb_68			KILL_					;Remove This Thread

gj_14			jsr	macro_start
			PRI_($32)				;Priority=#32
			BITON_($46)				;Turn ON: Bit#06
			BE28_($52)				;Effect: Range #52
			BE29_($12)				;Effect: Range #12
			BITON2_($63)			;Turn ON: Lamp#23(lbull_5k)
			BITON2_($64)			;Turn ON: Lamp#24(lbull_10k)
			BITON2_($68)			;Turn ON: Lamp#28(rbull_2x)
			BITON2_($69)			;Turn ON: Lamp#29(rbull_3x)
			SETRAM_($00,$06)			;RAM$00=$06
gb_71			.db $5A,$F1,$01			;BEQ_GAME to gb_70
			SSND_($06)				;Sound #06
gb_70			SLEEP_(4)
			BE2E_($12)				;Effect: Range #12
			.db $5B,$F7,$2C,$F5		;BNE_BIT#2C to gb_71
gb_72			SLEEP_(4)
			BE2D_($12)				;Effect: Range #12
			.db $5B,$F7,$28,$F9		;BNE_BIT#28 to gb_72
			ADDRAM_($00,$FF)			;RAM$00+=$FF
			.db $5B,$FC,$E0,$00,$E7		;BNE_RAM$00==#0 to gb_71
			SLEEP_(4)
			BE2C_($8B,$0C)			;Effect: Range #8B Range #0C
			SLEEP_(4)
			BE2C_($8B,$0C)			;Effect: Range #8B Range #0C
			BE29_($52)				;Effect: Range #52
			BITOFF_($46)			;Turn OFF: Bit#06
			KILL_					;Remove This Thread

			.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
			.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
			.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
			.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
			.db $00,$00,$00,$00,$00,$00,$00,$00,$00


	.end

;**************************************
;* Label Definitions                   
;**************************************
; D800 gj_02
; D805 gb_46
; D810 gb_47
; D81F gb_48
; D82E gb_49
; D83D gb_4A
; D84C gb_4B
; D85B gb_4C
; D86C gj_2E
; D877 gb_91
; D883 gb_92
; D891 gj_28
; D89C gb_84
; D8A8 gb_85
; D8B6 gj_13
; D8CB gb_6D
; D8D2 gb_6E
; D8E2 gb_6F
; D8EF gj_15
; D904 gb_73
; D90B gb_74
; D91B gb_75
; D927 gb_6C
; DA3F gj_20
; DA44 gb_5C
; DA50 gb_59
; DA59 gb_5A
; DA5A gb_58
; DA62 gb_5B
; DA67 gj_2F
; DAC6 gb_7D
; DB04 gj_33
; DB0C gj_34
; DB13 gb_7C
; DB26 gb_93
; DB2E gj_11
; DB3D gb_67
; DB58 gb_8E
; DB67 gb_8D
; DB7A gb_66
; DB8E gb_87
; DBA4 gb_86
; DBA9 gb_9C
; DBAA gj_3D
; DBB7 gj_42
; DBD5 gb_A5
; DBE3 gj_44
; DBFF gb_04
; DC0C gb_2C
; DC22 gb_2D
; DC48 gj_1B
; DC67 gj_31
; DC69 gb_8B
; DC6B gb_8C
; DC6F gb_8A
; DC78 gb_88
; DC8B gb_89
; DC94 gb_9F
; DCA1 gb_9D
; DCA8 gb_9E
; DCB4 gj_45
; DCB7 gb_A7
; DCBE gj_41
; DCDC gj_40
; DCE1 gb_A4
; DCFC gb_A3
; DD01 gb_A6
; DD1C gj_27
; DD25 gj_37
; DD27 gb_94
; DD41 gb_95
; DD50 gb_96
; DD55 gj_3F
; DD5A gj_43
; DD5E gj_24
; DD65 gb_80
; DD77 gb_7E
; DD96 gb_7F
; DDB4 gb_82
; DDC4 gb_81
; DDD4 gj_3C
; DDE2 gj_38
; DDE7 gb_98
; DDF8 gb_97
; DDF9 gj_01
; DE0A gj_3A
; DE0E gb_65
; DE12 gb_64
; DE2A gb_45
; DE3D gb_63
; DE48 gj_2A
; DE4F gj_32
; DE54 gj_3E
; DE57 gb_A0
; DE5E gameover_entry
; DE92 gj_17
; DE9C gj_03
; DE9F gj_2B
; DEA3 gb_4D
; DEAF gb_4E
; DEBE gj_04
; DEE0 gj_05
; E0C9 gameover_event
; E0DA sw_hstd_res
; E0DE hook_coin
; E0E4 gb_25
; E0E5 hook_mainloop
; E0E5 hook_reset
; E0E6 hook_gamestart
; E0EE gj_18
; E0F7 gb_26
; E0FF sw_credit_button
; E113 score_event
; E138 gb_01
; E143 gb_23
; E149 gb_24
; E14A sw_plumbtilt
; E159 gj_1A
; E168 sw_balltilt
; E168 sw_pf_tilt
; E16B gb_03
; E17E gb_30
; E191 gb_05
; E192 gb_2F
; E1A1 hook_outhole
; E1BC gb_2B
; E1C9 gb_02
; E1CB gb_2E
; E1D3 hook_playerinit
; E1ED gb_27
; E1F3 gb_28
; E1F9 gb_29
; E206 gb_4F
; E20F gb_2A
; E211 gj_19
; E225 gb_50
; E233 gb_51
; E23E gb_52
; E248 gj_1F
; E25A gb_56
; E26A gb_55
; E26B gj_06
; E272 gj_2C
; E277 gj_07
; E27D gb_32
; E280 gb_31
; E285 gj_0C
; E28D sw_barracora_lane
; E298 gb_08
; E29D gb_07
; E2AB gb_06
; E2AC gj_16
; E2C2 gb_77
; E2C8 gb_76
; E2D4 gb_78
; E2DF sw_left_flipper
; E2E2 sw_right_flipper
; E2E5 sw_1_4_lane
; E2E5 sw_2_5_lane
; E2E5 sw_3_6_lane
; E315 gb_17
; E322 gb_16
; E32C gb_15
; E32D gb_14
; E35A gb_3F
; E369 gj_23
; E36B gb_5D
; E37B sw_upper_eject
; E397 gb_0C
; E39D gb_09
; E3A3 gj_35
; E3A9 gb_0B
; E3AA gb_0D
; E3B5 gb_0A
; E3B8 gj_21
; E3BD sw_lower_eject
; E3D3 gb_10
; E3D5 gb_3B
; E3E4 gj_0B
; E3F9 gb_57
; E40F gb_3C
; E410 gb_0E
; E416 gj_36
; E41C gb_0F
; E41D gj_22
; E422 sw_center_trough
; E422 sw_left_trough
; E422 sw_right_trough
; E43C gb_11
; E451 gb_3D
; E464 gb_3E
; E465 gj_0D
; E46C sw_outhole
; E473 gj_1E
; E485 sw_bottom_jet
; E489 sw_left_jet
; E489 sw_right_jet
; E48D sw_5bank_10
; E48D sw_lleft_10
; E48D sw_lower_10
; E48D sw_lsling_10
; E48D sw_rsling_10
; E48D sw_upper_10
; E491 sw_left_return
; E491 sw_right_return
; E497 sw_left_outlane
; E497 sw_right_outlane
; E4AF gb_18
; E4B0 sw_ball_shooter
; E4C6 gb_13
; E4C7 gb_12
; E4CD gj_0E
; E4D9 sw_left_bull
; E4DB gj_10
; E4E5 gb_1B
; E4E6 sw_right_bull
; E4EA sw_upper_right_bull
; E503 gb_1E
; E505 gb_1D
; E50A gb_1F
; E514 gb_20
; E51B gb_1C
; E51E gj_08
; E531 gb_53
; E536 gb_33
; E53A sw_spinner
; E54D gb_19
; E551 gj_09
; E55D gj_1C
; E560 gb_79
; E572 gb_7B
; E583 gb_90
; E586 gb_7A
; E592 gb_8F
; E5A0 gb_A1
; E5A4 gj_0A
; E5BD gb_35
; E5C7 gb_34
; E5CD gb_37
; E5D7 gb_36
; E5DC gj_1D
; E5E5 gj_2D
; E5F1 gb_3A
; E5F4 gb_39
; E602 gb_54
; E606 gb_38
; E60D gj_39
; E610 gj_3B
; E61D gb_99
; E61E sw_dt_a1
; E61E sw_dt_a2
; E61E sw_dt_a3
; E61E sw_dt_b
; E61E sw_dt_c
; E61E sw_dt_o
; E61E sw_dt_r
; E61E sw_dt_rr
; E63C gb_21
; E63D gb_22
; E656 gb_44
; E65E gb_43
; E66B gb_5F
; E673 gj_29
; E68E gb_61
; E698 gb_60
; E6A1 gb_62
; E6AD sw_right_turnaround
; E6B5 gb_1A
; E6B9 gj_25
; E6C7 gj_0F
; E6D7 gb_41
; E6E2 gb_40
; E6E5 gj_26
; E6F1 gb_42
; E700 gj_30
; E70A gb_5E
; E714 gb_83
; E72D gb_9B
; E736 gb_9A
; E73E gb_A2
; E73F gj_12
; E756 gb_6A
; E75A gb_69
; E76C gb_6B
; E77B gb_68
; E77C gj_14
; E791 gb_71
; E795 gb_70
; E79C gb_72
