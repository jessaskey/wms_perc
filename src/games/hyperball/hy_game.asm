;--------------------------------------------------------------
;Hyperball Game ROM Disassembly
;Dumped by Hydasm ©2000-2013 Jess M. Askey
;--------------------------------------------------------------
; Errors/Warnings Generated:
;    Unlabeled immediate address at E6F9: ($13AB)
;    Unlabeled immediate address at E334: ($5501)
;    Unlabeled extended address at E32B: ($13B6)
;    Unlabeled immediate address at E31E: ($13A9)
;    Unlabeled immediate address at E311: ($13AA)
;    Unlabeled extended address at E30E: ($13A9)
;    Unlabeled extended address at E2EC: ($13B6)
;    Unlabeled extended address at E2E0: ($13B6)
;    Unlabeled extended address at E2A5: ($13B7)
;    Unlabeled extended address at E29E: ($13B7)
;    Unlabeled extended address at E28E: ($13B7)
;    Unlabeled extended address at E287: ($13B7)
;    Unlabeled extended address at E275: ($13B7)
;    Unlabeled extended address at E269: ($13B6)
;    Unlabeled extended address at E25C: ($13B7)
;    Unlabeled extended address at E237: ($13B8)
;    Unlabeled extended address at E234: ($13B7)
;    Unlabeled extended address at E22F: ($13B8)
;    Unlabeled extended address at E22A: ($13B6)
;    Unlabeled extended address at E1A3: ($13B7)
;    Unlabeled extended address at E190: ($13B7)
;    Unlabeled immediate address at D95C: ($13AD)
;    Unlabeled immediate address at D8D6: ($13AD)
;    Unlabeled immediate address at D162: ($0303)
;--------------------------------------------------

#include  "../../68logic.asm"	;680X logic definitions      
#include  "hy_wvm.asm"		;Virtual Machine Instruction Definitions       
#include  "hy_sys.exp"	;System defines                         
#include  "hy_hard.asm"	;Macro defines                 


 	.org $d000

;---------------------------------------------------------------------------
;  Default game data and basic system tables start at $e000, these can not  
;  ever be moved
;---------------------------------------------------------------------------

gr_gamenumber		.dw $3509
gr_romrevision		.db $F4
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

gr_lamptable_ptr		.dw lamptable
gr_switchtable_ptr	.dw switchtable
gr_soundtable_ptr		.dw soundtable

gr_lampflashrate		.db $05

gr_specialawardsound	.db $0D	;Special Sound
gr_p1_startsound		.db $03
gr_p2_startsound		.db $03
gr_unknownvar1		.db $1A
gr_hssound			.db $11
gr_gameoversound		.db $1A
gr_creditsound		.db $00

gr_gameover_lamp		.db $5F
gr_tilt_lamp		.db $5F

gr_gameoverthread_ptr	.dw gameover_entry
gr_character_defs_ptr	.dw character_defs
gr_coinlockout		.db $05
gr_highscoresound		.dw highscoresound

gr_switchtypetable
				.db $00,$02
				.db $00,$09
				.db $00,$04
				.db $00,$01
				.db $02,$05
				.db $08,$05
				.db $00,$00

gr_playerstartdata	.db $00,$00,$00,$00,$00
				.db $00,$00,$00,$00,$00
				.db $00,$00,$00,$00,$00
				.db $00,$00,$00,$00,$00
				.db $00,$00,$00,$00,$00
				.db $00,$00,$00,$00,$00

gr_playerresetdata	.db $00,$00,$00,$00,$00
				.db $00,$00,$00,$00,$00
				.db $FF,$03,$00,$00,$00
				.db $00,$00,$00,$00,$00
				.db $00,$00,$00,$00,$00
				.db $00,$00,$00,$00,$00

gr_switch_event		rts\ .db $00	;(Switch Event)
gr_sound_event		rts\ .db $DD	;(Sound Event )
gr_score_event		rts\ .db $00	;(Score Event)
gr_eb_event		rts\ .db $00		;(Extra Ball Event)
gr_special_event		bra special_event	;(Special Event)
gr_macro_event		rts\ .db $00	;(Start Macro Event)
gr_ballstart_event		rts\ .db $00;(Ball Start Event)
gr_addplayer_event		rts\ .db $00;(Add Player Event)
gr_gameover_event		rts\ .db $00	;(Game Over Event)
gr_hstdtoggle_event		rts\ .db $00;(HSTD Toggle Event)

hook_reset_ptr		.dw hook_reset		;Reset
hook_mainloop_ptr		.dw gr_macro_event		;Main Loop Begin
hook_coin_ptr		.dw hook_coin		;Coin Accepted
hook_gamestart_ptr	.dw hook_gamestart	;New Game Start
hook_playerinit_ptr	.dw hook_playerinit	;Init New Player
hook_outhole_ptr		.dw hook_outhole		;Outhole

;------------------------ end system data ---------------------------

gr_irq_entry	jmp	sys_irq_entry

gr_swi_entry	cli	
			ins	
			ins	
			ins	
			ins	
			ins	
			jmp	macro_start

special_event	ldx	#adj_ec_award_level
			jsr	cmosinc_b
			beq	gr_hstdtoggle_event
			ldx	credit_x_temp
			dex	
			dex	
			jsr	cmos_a
			aba	
			daa	
			bsr	gb_01
			ldaa	#$12
			jsr	isnd_once
			ldab	#$01
			jsr	add_b_cur_ecs
			ldx	#wave_p2_b0
			ldaa	player_up
			beq	gb_02
			ldx	#wave_p1_b0
gb_02			ldaa	#$01
			jmp	add_a_to_wave

hook_reset		jsr	restore_hstd
			ldx	#aud_game1
			stx	temp1
			ldx	#msg_ssr_ejs
			ldab	$00,X
			andb	#$0F
			inx	
			jmp	copyblock2

sw_hstd_res		bsr	hook_reset
to_kill		jmp	killthread

hook_gamestart	ldx	#hy_unknown_7
gb_03			clr	$00,X
			inx	
			cpx	#hy_unknown_e
			bne	gb_03
			ldx	#adj_ec_award_level
			ldaa	#$F3
			jsr	solbuf
			jsr	jmp_cmosa
			ldx	#aud_game7
			bsr	gb_01
gb_01			jmp	a_cmosinc

sw_1p_start		clra	
sw_2p_start		inca	
			ldab	flag_gameover
			beq	gb_06
			staa	hy_unknown_5
			tab	
			ldx	#adj_max_credits
			bsr	jmp_cmosa
			beq	gb_07
			ldx	#aud_currentcredits
			bsr	jmp_cmosa
			cba	
			bcs	to_kill
gb_07			ldaa	#$08
			ldx	#credit_button
			jsr	newthreadp
			decb	
			bne	gb_07
			ldx	#$0303
			stx	p1_ecs
			bsr	get_aud_ec_ex
			beq	to_kill
			swi	
			PRI_($48)				;Priority=#48
gs_forever		SLEEP_(5)
			JMPR_(gs_forever)
		
gb_06			cmpa	hy_unknown_5
			bne	to_kill
			ldaa	#$48
			ldab	#$FF
			jsr	check_threadid
			bcs	to_kill2
			jsr	killthreads_ff
			ldab	hy_unknown_5
			ldx	#adj_max_credits
			bsr	jmp_cmosa
			beq	gb_52
			ldaa	current_credits
			cba	
			bcs	to_kill2
gb_52			cmpb	#$02
			bne	gb_53
			bsr	extend_game
			ldab	p2_ecs
			psha	
			aba	
			staa	p2_ecs
			pula	
			ldx	#wave_p1_b0
			bsr	add_a_to_wave
gb_53			bsr	extend_game
			ldab	p1_ecs
			psha	
			aba	
			staa	p1_ecs
			pula	
			ldx	#wave_p2_b0
			bsr	add_a_to_wave
			bra	to_kill2

jmp_cmosa		jmp	cmos_a

extend_game		ldx	#aud_currentcredits
			bsr	jmp_cmosa
			jsr	lesscredit
get_aud_ec_ex	ldx	#adj_energyextended
			bsr	jmp_cmosa
			anda	#$0F
			rts	

add_a_to_wave	ldab	$00,X
			bpl	gb_4D
			andb	#$0F
gb_4D			aba	
			daa	
			cmpa	#$09
			bgt	gb_4E
			oraa	#$F0
gb_4E			staa	$00,X
			rts	

ani_game_lr		ldx	#alpha_b0+6
			stx	game_var_3
			ldx	#msg_game
			jsr	slide_r
to_kill2		jmp	killthread

ani_over_rl		ldx	#alpha_b0+5
			stx	game_var_5
			ldx	#msg_over
			jsr	slide_l
			bra	to_kill2

killthreads_ff	ldab	#$FF
			jmp	kill_threads

hook_outhole	ldaa	#$78
			bsr	killthreads_ff
			ldaa	random_bool
			bne	gb_04
			ldaa	#$29
			jsr	score_main
gb_04			inc	flag_tilt
			ldab	wave_p2_b0
			ldaa	player_up
			beq	gb_05
			ldab	wave_p1_b0
gb_05			cmpb	#$F0
			bne	goto_sme
			ldx	#msg_player
			jsr	load_message
			adda	#$1C
			ldx	temp1
			staa	$02,X
			ldaa	num_players
			beq	show_gameover
			jsr	addthread
			.db $60

show_gameover	ldx	#ani_game_lr
			jsr	newthread_06
			ldx	#ani_over_rl
			jsr	newthread_06
			bsr	goto_sme
			ldaa	#$09
			jsr	isnd_once
			jsr	addthread
			.db $F0

goto_sme		jmp	setup_msg_endptr

slide_r		ldaa	$00,X
			anda	#$0F
			jsr	xplusa
gb_5D			ldab	$00,X
			dex	
gb_0D			bsr	step_r
			bne	gb_5D
			rts	

slide_l		ldaa	$00,X
			anda	#$0F
gb_5F			inx	
			ldab	$00,X
gb_0F			bsr	step_l
			bne	gb_5F
			rts	

			bsr	gb_0C
			bsr	slide_r
			clrb	
			ldaa	#$01
			bra	gb_0D

ani_msg_rlslide	bsr	gb_0E
			bsr	slide_l
			clrb	
gj_2E			ldaa	#$01
			bra	gb_0F

step_r		psha	
			pshb	
			stx	game_var_2
			ldx	#alpha_b0
gb_60			tba	
			ldab	$00,X
			staa	$00,X
			inx	
			cpx	game_var_3
			bne	gb_60
			bra	gb_61

step_l		psha	
			pshb	
			stx	game_var_2
			ldx	#alpha_b0+11
gb_A0			tba	
			ldab	$00,X
			staa	$00,X
			dex	
			cpx	game_var_5
			bne	gb_A0
gb_61			ldx	game_var_2
			pulb	
			ldaa	game_ram_a
			bne	gb_A1
			ldaa	#$09
gb_A1			staa	thread_timer_byte
			pula	
			jsr	delaythread
			deca	
			rts	

gb_0E			stx	game_var_4
			ldx	#wave_p2_b1
			stx	game_var_5
			bra	gb_5E

gb_0C			stx	game_var_4
			ldx	#alpha_b1
			stx	game_var_3
gb_5E			ldx	game_var_4
			rts	

gj_20			bsr	gb_0E
gb_93			bsr	step_l
			bne	gb_93
			rts	

gj_3D			bsr	gb_0C
gb_10			bsr	step_r
			bne	gb_10
			rts	

setup_msg_endptr	psha	
			pshb	
			stx	sys_temp5
			ldx	#alpha_b0
			stx	temp1
			bsr	clr_next_12
			ldx	sys_temp5
			ldab	$00,X
			ldx	temp1
			jsr	split_ab
			stab	game_var_0
			jsr	xplusb
			stx	temp1
			ldx	sys_temp5
pulab_rts		pulb	
			pula	
			rts	

ani_circle		psha	
			pshb	
gb_91			ldaa	#$26
			decb	
			beq	pulab_rts
gb_92			staa	$00,X
			jsr	addthread
			.db $02
			inca	
			cmpa	#$2A
			beq	gb_91
			bra	gb_92

load_message	bsr	setup_msg_endptr
gj_29			ldab	$00,X
			andb	#$0F
			inx	
			jmp	copyblock

ani_msg_letters	bsr	setup_msg_endptr
			ldaa	$00,X
			anda	#$0F
gb_CD			ldab	#$0B
			psha	
			inx	
			stx	game_var_1
			ldaa	$00,X
			staa	alpha_b0+11
			ldx	#alpha_b0+10
gb_CC			jsr	addthread
			.db $04
			ldaa	$01,X
			staa	$00,X
			clra	
			staa	$01,X
			dex	
			decb	
			cmpb	game_var_0
			bne	gb_CC
			ldx	game_var_1
			inc	game_var_0
			pula	
			deca	
			bne	gb_CD
			rts	

gj_0D			jsr	update_commas
gj_08			clrb	
			bra	clr_alpha_set_bx

clr_alpha_set_b1	ldab	#$7F
clr_alpha_set_bx	jsr	stab_all_alphmsk
			ldx	#alpha_b1
clr_next_12		clra	
			ldab	#$0C
			jmp	write_range

sw_plumbtilt	.db $5A,$FE,$F2,$FF,$C0,$10	;BEQ_(BIT#80 P #FF) to tilt_kill
			EXE_($06)				;CPU Execute Next 6 Bytes
			ldx	#tilt_sleeper
			jsr	newthread_06
			SND_($15)				;Sound #15
			JSRD_(tilt_warning)		
			.db $5A,$F0,$09			;BEQ_TILT to game_tilt
			SOL_($46)				; Sol#6:gi_relay_pf
tilt_kill		KILL_					;Remove This Thread

tilt_sleeper	swi	
			PRI_($C0)				;Priority=#C0
			SLEEP_(24)
			KILL_					;Remove This Thread

game_tilt		SOL_($F6)				; Sol#6:gi_relay_pf
			PRI_($A0)				;Priority=#A0
			REMTHREADS_($08,$00)		;Remove Multiple Threads Based on Priority
			JSRR_(gj_06)			
			CPUX_					;Resume CPU Execution
			ldx	#msg_tilt
			bsr	load_message
			bsr	clr_alpha_set_b1
			ldaa	#$31
gb_99			jsr	invert_alphamsk
			jsr	addthread
			.db $06
			deca	
			bne	gb_99
			ldx	#vm_reg_a
			stx	game_var_unknown
			swi	
			JSRDR_(setup_msg_endptr)
			JSRDR_(stab_all_alphmsk)
			RAMCPY_($6,$0)			;Copy RAM;RAM,6 = RAM,0
gj_45			SOL_($06,$01,$02,$07)		; Sol#6:gi_relay_pf Sol#1:energy_flash Sol#2:p1_flash Sol#7:p2_flash
			PRI_($00)				;Priority=#00
			JSRDR_(gj_05)		
			JSRD_(update_commas)		
			JMPD_(outhole_main)
		
hook_playerinit	inc	flag_tilt
			ldx	#msg_player
			jsr	load_message
			ldx	current_thread
			stab	$0D,X
			ldaa	player_up
			adda	#$1C
			ldx	temp1
			staa	$02,X
			jsr	clr_alpha_set_b1
			jsr	ani_starslide
plyer_load		ldx	#gj_01
			jsr	addthread_clra
			bsr	get_current_ecs
			clr	hy_unknown_4
			swi	
			.db $5B,$FC,$E6,$00,$06		;BNE_RAM$06==#0 to gb_11
			SETRAM_($02,$00)			;RAM$02=$00
			SETRAM_($06,$05)			;RAM$06=$05
			RSET0_($0A)				;Effect: Range #0A
gb_11			RCLR0_($4F)				;Effect: Range #4F
			RCLR1_($40)				;Effect: Range #40
			ADDRAM_($00,$0B)			;RAM$00+=$0B
gj_0B			.db $5A,$FC,$E1,$00,$12		;BEQ_RAM$01==#0 to begin_play
			JSRDR_(to_lampm_a)	
			ADDRAM_($01,$FF)			;RAM$01+=$FF
			JMPR_(gj_0B)
			
get_current_ecs	ldab	player_up
			tba	
			ldx	#p1_ecs
xplusb_ldb		jsr	xplusb
			ldab	$00,X
			rts	

begin_play		ADDRAM_($00,$43)			;RAM$00+=$43
			SOL_($06)				; Sol#6:gi_relay_pf
			BITFLP_($00)			;Flash Lamp/Bit @RAM:00
			SETRAM_($01,$10)			;RAM$01=$10
gb_12			SND_($07)				;Sound #07
			SLEEP_(10)
			ADDRAM_($01,$FF)			;RAM$01+=$FF
			.db $5B,$FC,$E1,$00,$F7		;BNE_RAM$01==#0 to gb_12
			BITONP_($00)			;Turn ON Lamp/Bit @RAM:00
			BITOFF4_($30)			;Turn OFF: Lamp#30(lamp_p1)
			JSRDR_(setup_msg_endptr)
			SOL_($F9)				; Sol#9:ball_lift
			SLEEP_(64)
			REMTHREADS_($FF,$48)		;Remove Multiple Threads Based on Priority
			CPUX_					;Resume CPU Execution
			clra	
			staa	flag_tilt
			staa	game_ram_a
			ldx	#adj_reflex_diff
			jsr	cmosinc_b
			ldaa	#$11
			andb	#$0F
			beq	gb_62
gb_63			deca	
			decb	
			bne	gb_63
			cmpa	#$04
			bgt	gb_62
			ldaa	#$04
gb_62			staa	game_ram_c
			ldaa	game_ram_5
			ldab	game_ram_3
			bne	gb_64
			adda	#$01
			daa	
			staa	game_ram_5
			psha	
			ldab	#$0F
			stab	game_ram_7
			ldab	#$04
			ldx	#adj_baiter_speed
			jsr	cmosinc_a
			anda	#$0F
			beq	gb_65
gb_66			dec	game_ram_7
			cmpb	game_ram_7
			beq	gb_65
			deca	
			bne	gb_66
gb_65			ldab	game_ram_5
			jsr	dec2hex
			ldaa	game_ram_7
gb_68			cmpa	#$04
			beq	gb_67
			deca	
			decb	
			bne	gb_68
gb_67			staa	game_ram_7
			pula	
gb_64			clrb	
			psha	
			ldaa	game_ram_c
			deca	
			cmpa	#$03
			blt	gb_69
			staa	game_ram_c
gb_69			pula	
gb_6B			adda	#$99
			daa	
			beq	gb_6A
			incb	
			cmpb	#$05
			beq	gb_64
			bra	gb_6B

gb_6A			ldaa	game_ram_5
			cmpb	#$04
			beq	start_reflex
			tst	game_ram_3
			bne	gb_A2
			ldx	#gj_3A
			jsr	xplusb_ldb
			cmpa	#$09
			blt	gb_A3
			ldab	#$20
gb_A3			stab	game_ram_3
gb_A2			ldaa	game_ram_4
			bne	gb_A4
			ldaa	#$14
			staa	game_ram_4
gb_A4			ldx	#adj_bolt_speed
			jsr	cmosinc_b
			cmpb	#$20
			ble	gb_A5
			ldab	#$20
gb_A5			jsr	dec2hex
			tba	
			ldab	game_ram_5
			jsr	dec2hex
			cmpb	#$01
			beq	gb_A6
			aslb	
gb_A6			sba	
			bcs	gb_A7
			cmpa	#$06
			bge	gb_A8
gb_A7			ldaa	#$06
gb_A8			staa	game_ram_9
			ldx	#bolt_launcher
			bsr	to_addthr_noa
			ldx	#gb_3A
			bsr	to_addthr_noa
			jsr	get_random
			ldab	#$06
			cmpa	#$25
			bhi	gb_A9
			ldab	#$04
			ldx	#gj_3B
			bsr	to_addthr_noa
			ldx	#gj_3C
			bsr	to_addthr_noa
gb_A9			stab	game_ram_8
			ldx	#start_spell
			bsr	to_addthr_noa
			ldx	#start_rndawd
			bsr	to_addthr_noa
			ldx	#start_baiter
to_addthr_noa	bra	addthread_clra

start_reflex	ldaa	#$2E
			jsr	lamp_on_f
			ldaa	#$10
			staa	game_ram_f
			ldx	#reflex_thread
addthread_clra	clra	
newthreadp		staa	thread_priority
			jmp	newthread_sp

bolt_launcher	jsr	addthread
			.db $03

gb_17			ldaa	game_ram_8
			beq	bolt_launcher
			ldx	#gj_0C
			bsr	addthread_clra
			ldx	#adj_bolt_feed
			jsr	cmosinc_a
			anda	#$0F
			ldab	game_ram_5
			cmpb	#$09
			ble	gb_13
			ldab	#$09
gb_13			sba	
			bcc	gb_14
			clra	
gb_14			adda	#$0B
gb_16			ldab	game_ram_9
			cmpb	#$0C
			ble	gb_15
			lsrb	
gb_15			stab	thread_timer_byte
			jsr	delaythread
			deca	
			bne	gb_16
			bra	gb_17

sw_l_shooter
sw_r_shooter	PRI_($B0)				;Priority=#B0
gj_0A			.db $5B,$FB,$D0,$30,$FE,$F2,$F0,$F2,$F0,$09;BNE_((#F0 P #F0) || BIT2#30) to gb_0A
			.db $5A,$FE,$F2,$F0,$B0,$0A	;BEQ_(BIT#70 P #F0) to gb_0B
			SLEEP_(1)
			JMPR_(gj_0A)
			
gb_0A			PRI_($F0)				;Priority=#F0
			SND_($04)				;Sound #04
			JSRD_(solenoid_wait)		
			SLEEP_(11)
gb_0B			KILL_					;Remove This Thread

gj_11			swi	
gb_18			SLEEP_(4)
			.db $5A,$FE,$F2,$F0,$A0,$F9	;BEQ_(BIT#60 P #F0) to gb_18
			PRI_($A1)				;Priority=#A1
			JSRDR_(gj_0D)		
			JSRDR_(setup_msg_endptr)
			EXE_($06)				;CPU Execute Next 6 Bytes
			ldx	#msg_critical
			jsr	load_message
			SETRAM_($00,$14)			;RAM$00=$14
gb_19			JSRDR_(invert_alphamsk)	
			SND_($11)				;Sound #11
			SOL_($F6)				; Sol#6:gi_relay_pf
			SLEEP_(8)
			SOL_($06)				; Sol#6:gi_relay_pf
			SLEEP_(8)
			ADDRAM_($00,$FF)			;RAM$00+=$FF
			.db $5B,$FC,$E0,$00,$F0		;BNE_RAM$00==#0 to gb_19
			SND_($18)				;Sound #18
			SETRAM_($01,$00)			;RAM$01=$00
			JSRDR_(stab_all_alphmsk)
			KILL_					;Remove This Thread

gb_1B			SLEEP_(1)
			.db $5B,$F6,$4E,$02		;BNE_RangeON#4E to gb_1A
			RCLR0_($4E)				;Effect: Range #4E
gb_1A			JSRDR_(random_x0f)	
			.db $5A,$FD,$E0,$0D,$F2		;BEQ_RAM$00>=#13 to gb_1B
			RAMCPY_($1,$0)			;Copy RAM;RAM,1 = RAM,0
			ADDRAM_($01,$3A)			;RAM$01+=$3A
			.db $5A,$D0,$E1,$EA		;BEQ_BIT2#E1 to gb_1B
			BITON4a_($01)			;Turn ON: Lamp#01(lamp_h2)
			MRTS_					;Macro RTS, Save MRA,MRB

start_rndawd	bsr	random_x0f
			bne	gb_D2
			inca	
gb_D2			swi	
			PRI_($00)				;Priority=#00
gb_1C			SLEEP_(112)
			ADDRAM_($00,$FF)			;RAM$00+=$FF
			.db $5B,$FC,$E0,$00,$F7		;BNE_RAM$00==#0 to gb_1C
gb_1D			SLEEP_(10)
			.db $5A,$FE,$F2,$F0,$A0,$F9	;BEQ_(BIT#60 P #F0) to gb_1D
			PRI_($A6)				;Priority=#A6
gb_20			JSRR_(gb_1B)			
			EXE_($03)				;CPU Execute Next 3 Bytes
			staa	current_credits+1
			.db $5B,$FD,$E0,$0B,$2B		;BNE_RAM$00>=#11 to gb_1E
			.db $5A,$FC,$E0,$0D,$0A		;BEQ_RAM$00==#13 to gb_1F
			.db $5A,$F4,$3C,$EC		;BEQ_LampOn/Flash#3C to gb_20
			BITFL_($BA,$BB,$3C)		;Flash: Lamp#3A(lamp_e3), Lamp#3B(lamp_e2), Lamp#3C(lamp_e1)
			JMPR_(gj_0E)
			
gb_1F			.db $5A,$F4,$45,$E2		;BEQ_LampOn/Flash#45 to gb_20
			BITFL_($C3,$C4,$45)		;Flash: Bit#03, Bit#04, Bit#05
			JMPR_(gj_0E)
			
jmp_getrandom	jmp	get_random

random_x03		bsr	jmp_getrandom
			anda	#$03
			rts	

random_x07		bsr	jmp_getrandom
			anda	#$07
			rts	

random_x0f		bsr	jmp_getrandom
			anda	#$0F
			rts	

gb_1E			JSRDR_(get_rnd_lampnum)	
			.db $5A,$F4,$E0,$C4		;BEQ_LampOn/Flash#E0 to gb_20
			BITFLP_($00)			;Flash Lamp/Bit @RAM:00
gj_0E			SETRAM_($0A,$04)			;RAM$0A=$04
			CPUX_					;Resume CPU Execution
			ldx	#msg_hit
			jsr	ani_msg_rlslide
			ldab	current_credits+1
			ldx	#gj_2D
			jsr	xplusb
			ldab	$00,X
			jsr	gj_2E
			ldab	#$26
			jsr	gj_2E
			ldx	#hy_unknown_e
			bsr	random_x03
			beq	gb_6C
			deca	
gb_6C			staa	hy_unknown_6
			bne	gb_6D
			ldaa	game_ram_4
			jsr	gj_2F
			bra	gb_6E

gb_6D			clr	$01,X
			ldab	#$1C
			stab	$02,X
			ldab	#$26
			stab	$03,X
			cmpa	#$02
			beq	gb_AA
			ldaa	#$5A
			ldab	#$42
			bra	gb_AB

gb_AA			ldaa	#$45
			ldab	#$55
gb_AB			staa	$04,X
			stab	$05,X
gb_6E			ldaa	#$05
			staa	$00,X
			jsr	ani_msg_rlslide
			staa	game_ram_a
			ldx	current_thread
			ldaa	#$A4
			staa	$0D,X
			ldaa	#$02
gb_AD			jsr	addthread
			.db $C0
			deca	
			bne	gb_AD
sumthin		ldaa	current_credits+1
			swi	
			PRI_($A1)				;Priority=#A1
			.db $5A,$FD,$E0,$0B,$06		;BEQ_RAM$00>=#11 to gb_21
			JSRDR_(get_rnd_lampnum)	
			BITOFFP_($00)			;Turn OFF Lamp/Bit @RAM:00
			JMPR_(gj_0F)
			
gb_21			.db $5A,$FC,$E0,$0D,$04		;BEQ_RAM$00==#13 to gb_6F
			RCLR0_($10)				;Effect: Range #10
			JMPR_(gj_0F)
			
gb_6F			RCLR0_($11)				;Effect: Range #11
gj_0F			SETRAM_($0A,$04)			;RAM$0A=$04
			CPUX_					;Resume CPU Execution
			ldaa	#$0C
			clrb	
			jsr	gj_3D
			staa	game_ram_a
			jmp	start_rndawd

gj_10			swi	
gb_22			SLEEP_(4)
			.db $5A,$FE,$F2,$FF,$68,$F9	;BEQ_(BIT#28 P #FF) to gb_22
			PRI_($68)				;Priority=#68
			SND_($0E)				;Sound #0E
			SOL_($F1,$F2,$F7)			; Sol#1:energy_flash Sol#2:p1_flash Sol#7:p2_flash
			SLEEP_(4)
			SOL_($01,$02,$07)			; Sol#1:energy_flash Sol#2:p1_flash Sol#7:p2_flash
			KILL_					;Remove This Thread

gj_35			psha	
			ldx	#gj_10
			jsr	addthread_clra
			ldaa	game_ram_6
			adda	#$99
			daa	
			staa	game_ram_6
			cmpa	#$01
			bne	gb_23
			ldx	#gj_11
			jsr	addthread_clra
gb_23			pula	
			rts	

get_rnd_lampnum	ldx	#gj_12
			jsr	xplusa
			ldaa	$00,X
			rts	

gb_54			psha	
			pshb	
			deca	
			jsr	bit_lamp_buf_f
			beq	gb_9A
			ldaa	#$01
			bra	gb_9B

gb_9A			inca	
			inca	
			jsr	bit_lamp_buf_f
			beq	gb_55
			ldaa	#$02
gb_9B			staa	hy_unknown_4
gb_55			pulb	
			pula	
			rts	

gj_03			psha	
			pshb	
			tab	
			adda	#$41
			bsr	gb_54
			jsr	lamp_off_f
			subb	#$08
			ldx	#gj_26
			jsr	xplusb_ldb
			stab	hy_unknown_3
			ldx	game_var_7
			beq	gb_55
			cmpb	$00,X
			bne	gb_55
			inx	
			stx	game_var_7
			lsr	game_var_unknown
			bra	gb_55

gj_06			BITON4_($30)			;Turn ON: Lamp#30(lamp_p1)
			RCLR0_($CF,$4D)			;Effect: Range #CF Range #4D
			RCLR1_($C0,$00)			;Effect: Range #C0 Range #00
			SETRAM_($0A,$00)			;RAM$0A=$00
			JSRD_(clr_dis_masks)		
			JSRDR_(gj_0D)		
			EXE_($0A)				;CPU Execute Next 10 Bytes
			inc	flag_tilt
			ldab	player_up
			jsr	saveplayertobuffer
			ldab	player_up
			JSRD_(resetplayerdata)		
			MRTS_					;Macro RTS, Save MRA,MRB

sw_H
sw_I
sw_J
sw_K
sw_L
sw_M
sw_N
sw_O
sw_P			JSRDR_(gj_03)		
			EXE_($02)				;CPU Execute Next 2 Bytes
			suba	#$12
			.db $5B,$D0,$E0,$42		;BNE_BIT2#E0 to s_kill
			BITOFF4a_($00)			;Turn OFF: Lamp#00(lamp_h1)
			EXE_($0A)				;CPU Execute Next 10 Bytes
			ldab	#$21
			stab	thread_priority
			ldx	#gj_27
			jsr	newthread_sp
			POINTS_(1,1000)			;1000 Points
			SND_($08)				;Sound #08
sw_common		ADDRAM_($03,$FF)			;RAM$03+=$FF
chk_wave_compl	.db $5A,$FB,$FB,$F3,$FC,$E3,$00,$D0,$2E,$D0,$2F,$24;BEQ_(BIT2#2F || (BIT2#2E || (!RAM$03==#0))) to s_kill
			REMTHREADS_($08,$00)		;Remove Multiple Threads Based on Priority
			SND_($05)				;Sound #05
			JSRDR_(gj_05)		
			JSRR_(gj_06)			
			JSRD_(gj_07)			
			JSRDR_(show_wave_compl)	
			JSRDR_(show_eunit_bonus)
setup_next_wave	REMTHREADS_($08,$00)		;Remove Multiple Threads Based on Priority
			EXE_($05)				;CPU Execute Next 5 Bytes
			ldab	player_up
			jsr	resetplayerdata
			EXE_($08)				;CPU Execute Next 8 Bytes
			staa	flag_timer_bip
			ldx	#player_ready
			jsr	newthreadp
			JSRD_(plyer_load)			
s_kill		KILL_					;Remove This Thread

show_wave_compl	ldx	#msg_wave
			jsr	load_message
			jsr	disp_wave_num
			bsr	sleep45
			ldx	#msg_completed
			jsr	load_message
sleep45		jsr	addthread
			.db $45
			rts	

sw_T			JSRDR_(gj_03)		
			.db $5B,$F4,$43,$2E		;BNE_LampOn/Flash#43 to gb_08
			RCLR0_($11)				;Effect: Range #11
			JMPR_(gj_04)
			
sw_E			JSRDR_(gj_03)		
			.db $5B,$F4,$3A,$24		;BNE_LampOn/Flash#3A to gb_08
			RCLR0_($10)				;Effect: Range #10
			JMPR_(gj_04)
			
sw_F			ldab	#$3D
			bra	ssw_handler

sw_G			ldab	#$3E
ssw_handler		swi	
			JSRDR_(gj_03)		
			.db $5B,$F4,$E1,$13		;BNE_LampOn/Flash#E1 to gb_08
			BITOFFP_($01)			;Turn OFF Lamp/Bit @RAM:01
gj_04			JSRR_(gj_13)			
			.db $5A,$FE,$F2,$F4,$A4,$27	;BEQ_(BIT#64 P #F4) to gb_24
gb_AE			.db $5A,$D0,$2E,$05		;BEQ_BIT2#2E to gb_08
			SND_($00)				;Sound #00
			POINTS_(5,1000)			;5000 Points
			JMPR_(sw_common)
		
gb_08			KILL_					;Remove This Thread

sw_S			ldab	#$46
			bra	ssw_handler

sw_R			ldab	#$47
			bra	ssw_handler

sw_A
sw_B
sw_C
sw_D
sw_U
sw_V
sw_W
sw_Y			tab	
			subb	#$08
			ldx	#gj_02
			jsr	xplusb_ldb
			bra	ssw_handler

gj_49			swi	
gj_14			.db $5A,$FE,$F2,$F6,$A4,$18	;BEQ_(BIT#64 P #F6) to gb_25
			SLEEP_(2)
			JMPR_(gj_14)
			
gb_24			EXE_($03)				;CPU Execute Next 3 Bytes
			ldaa	hy_unknown_3
gj_30			.db $5A,$FE,$F2,$F6,$A4,$03	;BEQ_(BIT#64 P #F6) to gb_71
			SLEEP_(6)
			JMPR_(gj_30)
			
gb_71			EXE_($02)				;CPU Execute Next 2 Bytes
			ldab	$64
			.db $5B,$FC,$E0,$E1,$C4		;BNE_RAM$00==#225 to gb_AE
gb_25			REMTHREADS_($F1,$A0)		;Remove Multiple Threads Based on Priority
			PRI_($A1)				;Priority=#A1
			JSRDR_(random_x03)	
			CPUX_					;Resume CPU Execution
			adda	game_ram_4
			daa	
			staa	game_ram_4
			ldab	#$01
			ldaa	hy_unknown_6
			beq	gb_AF
			rora	
			bcc	gb_B0
			jsr	add_b_cur_ecs
			bra	gb_B1

gb_B0			jsr	gj_44
			bra	gb_B1

gb_AF			ldx	#alpha_b0+6
			bsr	gb_D3
gb_B1			jsr	gj_0D
			ldab	#$10
			ldaa	#$01
			jsr	isnd_once
gb_D4			ldaa	dmask_p4
			coma	
			anda	#$3F
			staa	dmask_p4
			jsr	addthread
			.db $05
			decb	
			bne	gb_D4
			stab	dmask_p4
			jmp	sumthin

gb_D3			ldab	$01,X
			andb	#$3F
			subb	#$1B
			beq	gb_F1
			ldaa	#$0B
gb_F2			jsr	score_main
			decb	
			bne	gb_F2
gb_F1			ldab	$00,X
			beq	gb_F3
			subb	#$1B
			ldaa	#$0C
gb_F4			jsr	score_main
			decb	
			bne	gb_F4
gb_F3			rts	

invert_alphamsk	ldab	dmask_p3
			comb	
			andb	#$7F
stab_all_alphmsk	stab	dmask_p3
			stab	dmask_p4
			rts	

gb_79			psha	
gb_27			jsr	random_x03
			jsr	addthread
			.db $01
			beq	gb_26
			cmpa	#$03
			beq	gb_27
			cmpa	#$02
			bne	gb_26
			ldaa	#$0A
			jsr	lfill_a
			bcs	gb_28
			ldaa	#$02
			bra	gb_26

gb_28			clra	
gb_26			staa	hy_unknown_5
			pula	
			rts	

gb_29			ldx	current_thread
			clr	$0D,X
			rts	

start_spell		bsr	gb_29
			ldx	#vm_reg_a
			stx	game_var_7
			bsr	gb_2A
			ldaa	$00,X
			staa	hy_unknown_5
			ldx	$01,X
			stx	game_var_unknown
			bne	gb_2B
			swi	
gb_2C			SLEEP_(64)
			.db $5A,$FE,$F2,$F0,$A0,$F8	;BEQ_(BIT#60 P #F0) to gb_2C
			PRI_($A0)				;Priority=#A0
			CPUX_					;Resume CPU Execution
			ldx	#msg_spell
			jsr	load_message
			jsr	clr_alpha_set_b1
			ldaa	#$10
gb_77			bsr	invert_alphamsk
			jsr	addthread
			.db $08
			deca	
			bne	gb_77
			jsr	random_x07
			bne	gb_78
			inca	
gb_78			bsr	gb_79
			deca	
			staa	game_var_unknown+1
			ldaa	#$20
			staa	game_var_unknown
gb_2B			jsr	gj_31
			bcc	gb_2B
			jsr	clr_alpha_set_b1
			bsr	gb_73
			ldx	#$13AD
			stx	temp1
			ldaa	game_var_unknown
			beq	gb_74
gb_76			bita	#$20
			bne	gb_75
			asla	
			beq	gb_74
			inx	
			bra	gb_76

gb_75			stx	game_var_7
			jsr	clr_next_12
			bsr	gb_B7
			bsr	gb_29
gb_D8			ldaa	#$7F
			staa	dmask_p3
gb_BA			anda	#$7F
			staa	dmask_p4
			bsr	gj_31
			bcc	gb_B8
			bsr	gb_B9
			beq	gb_74
			coma	
			oraa	dmask_p4
			eora	game_var_unknown
			bra	gb_BA

gb_2A			ldx	#hy_unknown_7
			ldab	player_up
			beq	gb_72
			inx	
			inx	
			inx	
gb_72			rts	

gb_B8			clrb	
			jsr	stab_all_alphmsk
gb_D7			bsr	gb_B9
			beq	gb_74
			bsr	gj_31
			bcc	gb_D7
			bsr	gb_73
			bra	gb_D8

gb_73			jsr	setup_msg_endptr
			ldx	#alpha_b1
			stx	temp1
			ldx	#msg_zeros
			ldaa	hy_unknown_5
			beq	gb_B2
			ldx	#msg_3zb
			rora	
			bcs	gb_B2
			ldx	#msg_3eu
gb_B2			bsr	gb_B3
			inc	temp1+1
gb_B7			ldx	#gj_3E
			ldaa	game_var_unknown+1
			jsr	gettabledata_b
gb_B3			jmp	gj_29

gb_74			ldx	#vm_reg_a
			stx	game_var_7
			stx	game_var_unknown
			bsr	gj_05
			ldx	#$13AD
			jsr	clr_next_12
			ldab	#$03
			ldaa	hy_unknown_5
			beq	gb_B4
			cmpa	#$02
			beq	gb_B5
			bsr	add_b_cur_ecs
			bra	gb_B6

gj_31			jsr	addthread
			.db $05
			ldaa	#$A0
			ldab	#$F0
			jmp	check_threadid

gb_B9			ldx	game_var_7
			ldaa	$00,X
			beq	gb_D9
			ldaa	game_var_unknown
gb_D9			rts	

gj_05			bsr	gb_2A
			ldaa	hy_unknown_5
			staa	$00,X
			ldaa	game_var_unknown
			staa	$01,X
			ldaa	game_var_unknown+1
			staa	$02,X
			rts	

gb_B5			bsr	gj_44
			bra	gb_B6

gb_B4			ldaa	#$4C
			jsr	score_main
gb_B6			ldaa	#$06
			jsr	isnd_once
			bsr	gj_31
			bcc	gb_D5
			ldx	current_thread
			ldaa	#$A1
			staa	$0D,X
			ldaa	#$7F
			staa	dmask_p4
			ldaa	#$10
gb_D6			ldab	dmask_p3
			comb	
			andb	#$7F
			stab	dmask_p3
			jsr	addthread
			.db $05
			deca	
			bne	gb_D6
gb_D5			jsr	gj_0D
			jmp	start_spell

add_b_cur_ecs	pshb	
			jsr	get_current_ecs
			tba	
			pulb	
			aba	
			staa	$00,X
			ldaa	player_up
			adda	#$0B
			bra	gb_4C

gj_44			ldaa	game_ram_6
			aba	
			cmpa	#$05
			ble	gb_F5
			ldaa	#$05
gb_F5			staa	game_ram_6
			ldaa	#$0A
			aslb	
gb_4C			bsr	to_lampm_a
			decb	
			bne	gb_4C
			rts	

to_lampm_a		jmp	lampm_a

gj_0C			swi	
gb_7D			adda	$F4,X
			lsra	
			anda	#$02
			.db $5B,$D0,$2F,$01		;BNE_BIT2#2F to gb_2D
gb_7A			KILL_					;Remove This Thread

gb_2D			PRI_($50)				;Priority=#50
			.db $5A,$FC,$E8,$00,$F8		;BEQ_RAM$08==#0 to gb_7A
			ADDRAM_($08,$FF)			;RAM$08+=$FF
			.db $5A,$FC,$E0,$02,$2C		;BEQ_RAM$00==#2 to gb_7B
			SETRAM_($01,$36)			;RAM$01=$36
gb_80			.db $5A,$F4,$E1,$09		;BEQ_LampOn/Flash#E1 to gb_7C
gj_32			BITONP_($01)			;Turn ON Lamp/Bit @RAM:01
			SLEEPI_($9)				;Delay RAM$09
			SLEEPI_($9)				;Delay RAM$09
			.db $5B,$E1,$DB			;BNE_RAM$01 to gb_7D
			BITOFFP_($01)			;Turn OFF Lamp/Bit @RAM:01
gb_7C			.db $5A,$FC,$E1,$3E,$69		;BEQ_RAM$01==#62 to gb_7E
			.db $5B,$FC,$E1,$3C,$02		;BNE_RAM$01==#60 to gb_7F
			RCLR0_($10)				;Effect: Range #10
gb_7F			ADDRAM_($01,$01)			;RAM$01+=$01
			.db $5B,$FC,$E1,$3A,$E0		;BNE_RAM$01==#58 to gb_80
			ADDRAM_($01,$02)			;RAM$01+=$02
			.db $5A,$F4,$E1,$F3		;BEQ_LampOn/Flash#E1 to gb_7F
			RSET0_($10)				;Effect: Range #10
			JMPR_(gj_32)
			
gb_7B			SETRAM_($01,$3F)			;RAM$01=$3F
gb_BE			.db $5A,$F4,$E1,$09		;BEQ_LampOn/Flash#E1 to gb_BB
gj_3F			BITONP_($01)			;Turn ON Lamp/Bit @RAM:01
			SLEEPI_($9)				;Delay RAM$09
			SLEEPI_($9)				;Delay RAM$09
			.db $5B,$E1,$AF			;BNE_RAM$01 to gb_7D
			BITOFFP_($01)			;Turn OFF Lamp/Bit @RAM:01
gb_BB			.db $5A,$FC,$E1,$47,$65		;BEQ_RAM$01==#71 to gb_BC
			.db $5B,$FC,$E1,$45,$02		;BNE_RAM$01==#69 to gb_BD
			RCLR0_($11)				;Effect: Range #11
gb_BD			ADDRAM_($01,$01)			;RAM$01+=$01
			.db $5B,$FC,$E1,$43,$E0		;BNE_RAM$01==#67 to gb_BE
			ADDRAM_($01,$02)			;RAM$01+=$02
			.db $5A,$F4,$E1,$F3		;BEQ_LampOn/Flash#E1 to gb_BD
			RSET0_($11)				;Effect: Range #11
			JMPR_(gj_3F)
			
gj_41			pshb	
			tab	
			jsr	gj_16
			swi	
			.db $5A,$FB,$D0,$E0,$F3,$F5,$E0,$13	;BEQ_((!RangeOFF#E0) || BIT2#E0) to gb_2E
			BITON4a_($00)			;Turn ON: Lamp#00(lamp_h1)
			BITONP_($01)			;Turn ON Lamp/Bit @RAM:01
			SLEEPI_($9)				;Delay RAM$09
			SLEEPI_($9)				;Delay RAM$09
			.db $5A,$D0,$E0,$04		;BEQ_BIT2#E0 to gb_2F
			SETRAM_($00,$00)			;RAM$00=$00
			JMPR_(gb_2E)
			
gb_2F			BITOFF4a_($00)			;Turn OFF: Lamp#00(lamp_h1)
			JSRD_(lampm_clr0)			
gb_2E			CPUX_					;Resume CPU Execution
			pulb	
			rts	

gj_3C			.db $3F


gb_7E			JSRR_(gj_40)			
			.db $5A,$D0,$2F,$5F		;BEQ_BIT2#2F to gb_BF
			SETRAM_($00,$00)			;RAM$00=$00
gb_C0			ADDRAM_($00,$01)			;RAM$00+=$01
			.db $5A,$FA,$D0,$E0,$F3,$FC,$E0,$E1,$F5;BEQ_((!RAM$00==#225) && BIT2#E0) to gb_C0
			.db $5A,$FE,$F2,$F0,$30,$4C	;BEQ_(BIT#FFFFFFF0 P #F0) to gb_BF
			JSRDR_(gj_41)		
			.db $5A,$FC,$E0,$00,$45		;BEQ_RAM$00==#0 to gb_BF
			.db $5A,$FC,$E0,$E1,$28		;BEQ_RAM$00==#225 to gb_C1
			JMPR_(gb_C0)
			
gj_3B			.db $3F


gb_BC			JSRR_(gj_40)			
			.db $5A,$D0,$2F,$37		;BEQ_BIT2#2F to gb_BF
			SETRAM_($00,$0A)			;RAM$00=$0A
gb_DA			ADDRAM_($00,$FF)			;RAM$00+=$FF
			.db $5A,$FA,$D0,$E0,$F3,$FC,$E0,$E1,$F5;BEQ_((!RAM$00==#225) && BIT2#E0) to gb_DA
			.db $5A,$FE,$F2,$F0,$30,$24	;BEQ_(BIT#FFFFFFF0 P #F0) to gb_BF
			JSRDR_(gj_41)		
			.db $5A,$FC,$E0,$00,$1D		;BEQ_RAM$00==#0 to gb_BF
			.db $5B,$FC,$E0,$E1,$E3		;BNE_RAM$00==#225 to gb_DA
gb_C1			.db $5A,$FA,$F5,$E0,$F3,$D0,$E0,$03	;BEQ_((!BIT2#E0) && RangeOFF#E0) to gb_DB
			SLEEP_(1)
			JMPR_(gb_C1)
			
gb_DB			BITON4a_($00)			;Turn ON: Lamp#00(lamp_h1)
gb_F7			JSRDR_(to_lampm_a)	
			.db $5A,$F6,$E0,$08		;BEQ_RangeON#E0 to gb_F6
			SLEEPI_($9)				;Delay RAM$09
			.db $5A,$D0,$E0,$F5		;BEQ_BIT2#E0 to gb_F7
gb_BF			JSRR_(gj_13)			
gb_8C			KILL_					;Remove This Thread

gb_F6			JSRD_(lampm_c)			
			JSRD_(lampm_e)			
			.db $5A,$F5,$E0,$07		;BEQ_RangeOFF#E0 to gb_102
			SLEEP_(4)
			.db $5B,$D0,$E0,$EE		;BNE_BIT2#E0 to gb_BF
			JMPR_(gb_F6)
			
gb_102		BITOFF4a_($00)			;Turn OFF: Lamp#00(lamp_h1)
			PRI_($00)				;Priority=#00
			JSRR_(gj_13)			
gj_1A			JSRDR_(gj_35)		
			RCLR1L0_($8A,$0A)			;Effect: Range #8A Range #0A
			ADDRAM_($02,$04)			;RAM$02+=$04
			.db $5B,$FC,$E6,$00,$DC		;BNE_RAM$06==#0 to gb_8C
gj_19			REMTHREADS_($08,$00)		;Remove Multiple Threads Based on Priority
			SOL_($F6)				; Sol#6:gi_relay_pf
			JSRR_(gj_06)			
			SETRAM_($00,$05)			;RAM$00=$05
			SETRAM_($01,$05)			;RAM$01=$05
gj_34			BITONP_($01)			;Turn ON Lamp/Bit @RAM:01
			.db $5A,$FC,$E1,$35,$04		;BEQ_RAM$01==#53 to gb_89
			ADDRAM_($01,$06)			;RAM$01+=$06
			JMPR_(gj_34)
			
gb_89			.db $5B,$05,$0D			;BNE_LAMP#05(lamp_h6) to gb_CA
			ADDRAM_($00,$FF)			;RAM$00+=$FF
			.db $5A,$FC,$E0,$00,$22		;BEQ_RAM$00==#0 to gb_CB
			SND_($0E)				;Sound #0E
			SOL_($40,$41,$42,$47)		; Sol#0:hyper_flash Sol#1:energy_flash Sol#2:p1_flash Sol#7:p2_flash
gb_CA			RROL0_($81,$82,$83,$84,$85,$86,$87,$88,$09);Effect: Range #81 Range #82 Range #83 Range #84 Range #85 Range #86 Range #87 Range #88 Range #09
			SLEEP_(7)
			.db $5B,$00,$E2			;BNE_LAMP#00(lamp_h1) to gb_89
			BITON_($BE,$BD,$C6,$47)		;Turn ON: Lamp#3E(lamp_g), Lamp#3D(lamp_f), Bit#06, Bit#07
			EXE_($06)				;CPU Execute Next 6 Bytes
			ldx	#gj_46
			jsr	newthread_06
			JMPR_(gb_89)
			
gb_CB			SETRAM_($06,$00)			;RAM$06=$00
			JMP_(gj_45)				


gj_40			SLEEP_(1)
			.db $5A,$FE,$F2,$F1,$21,$F9	;BEQ_(LAMP#21(lamp_m4) P #F1) to gj_40
			PRI_($20)				;Priority=#20
			.db $5B,$F6,$4D,$02		;BNE_RangeON#4D to gb_DC
			RCLR0_($4D)				;Effect: Range #4D
gb_DC			JSRDR_(gj_15)		
			ADDRAM_($01,$30)			;RAM$01+=$30
			.db $5A,$FB,$FB,$D0,$E1,$D0,$E0,$D0,$F9,$E1;BEQ_(BIT2#F9 || (BIT2#E0 || BIT2#E1)) to gb_DD
			BITFL2_($E1,$DC,$01)		;Flash: Lamp#21(lamp_m4), Lamp#1C(lamp_l5), Lamp#01(lamp_h2)
			RAMCPY_($1,$0)			;Copy RAM;RAM,1 = RAM,0
			MRTS_					;Macro RTS, Save MRA,MRB

gj_15			jsr	random_x0f
			cmpa	#$08
			ble	gb_81
			lsra	
gb_81			inca	
			tab	
			rts	

show_eunit_bonus	jsr	setup_msg_endptr
			ldx	#alpha_b0
			stx	temp1
			ldx	#msg_enuit
			jsr	gj_29
			ldx	#msg_bonus
			jsr	gj_29
			jsr	addthread
			.db $25
			jsr	setup_msg_endptr
			ldab	game_ram_6
			ldx	#alpha_b0+1
			jsr	split_ab
			tstb	
			beq	gb_56
			addb	#$1B
			stab	$00,X
gb_56			ldab	game_ram_6
			andb	#$0F
			addb	#$1B
			stab	$01,X
			ldaa	#$18
			staa	$03,X
			ldaa	game_ram_5
			cmpa	#$09
			bls	gb_57
			ldaa	#$09
gb_57			tab	
			addb	#$9B
			stab	$05,X
			ldab	#$1B
			stab	$06,X
			stab	$07,X
			stab	$08,X
			asla	
			asla	
			asla	
			oraa	#$03
			ldab	game_ram_6
gb_58			jsr	score_main
			decb	
			bne	gb_58
			jsr	addthread
			.db $25
			rts	

start_baiter	ldab	game_ram_5
			jsr	dec2hex
			ldaa	#$7F
gb_31			suba	#$04
			cmpa	#$09
			blt	gb_30
			decb	
			bne	gb_31
			bra	gb_32

gb_30			ldaa	#$08
gb_32			swi	
			SETRAM_($0E,$00)			;RAM$0E=$00
gb_33			SLEEPI_($7)				;Delay RAM$07
			ADDRAM_($0E,$01)			;RAM$0E+=$01
			.db $5A,$D0,$2F,$F9		;BEQ_BIT2#2F to gb_33
			EXE_($03)				;CPU Execute Next 3 Bytes
			ldab	random_bool
			deca	
			.db $5A,$FC,$E0,$00,$09		;BEQ_RAM$00==#0 to gb_34
			.db $5B,$FA,$FC,$E1,$00,$FD,$EE,$30,$E7;BNE_(RAM$0E>=#48 && RAM$01==#0) to gb_33
gb_34			SLEEP_(1)
			EXE_($03)				;CPU Execute Next 3 Bytes
			clr	hy_unknown_1
			JSRDR_(gj_15)		
			.db $5A,$FB,$F3,$F5,$E0,$D0,$E0,$F1	;BEQ_(BIT2#E0 || (!RangeOFF#E0)) to gb_34
			ADDRAM_($00,$53)			;RAM$00+=$53
			JSRDR_(gj_16)		
			PRI_($30)				;Priority=#30
gb_37			SETRAM_($0E,$06)			;RAM$0E=$06
			BITON4a_($00)			;Turn ON: Lamp#00(lamp_h1)
			BITONP_($01)			;Turn ON Lamp/Bit @RAM:01
			BITOFF3a_($01)			;Turn OFF: Lamp#01(lamp_h2)
gb_36			BITINVP2_($01)			;Toggle Lamp/Bit @RAM:01
			SND_($02)				;Sound #02
			SLEEPI_($7)				;Delay RAM$07
			.db $5B,$D0,$E0,$20		;BNE_BIT2#E0 to gb_35
			ADDRAM_($0E,$FF)			;RAM$0E+=$FF
			.db $5B,$FC,$EE,$00,$F1		;BNE_RAM$0E==#0 to gb_36
			BITONP2_($01)			;Turn ON Lamp/Bit @RAM:01
			JSRDR_(gj_17)		
			BITOFFP2_($01)			;Turn OFF Lamp/Bit @RAM:01
			BITOFFP_($01)			;Turn OFF Lamp/Bit @RAM:01
			.db $5B,$D0,$E0,$0D		;BNE_BIT2#E0 to gb_35
			BITOFF4a_($00)			;Turn OFF: Lamp#00(lamp_h1)
			JSRDR_(gj_18)		
			.db $5B,$FC,$E1,$00,$D4		;BNE_RAM$01==#0 to gb_37
			PRI_($00)				;Priority=#00
			JMPR_(gj_19)
			
gb_35			BITOFFP_($01)			;Turn OFF Lamp/Bit @RAM:01
			BITOFFP2_($01)			;Turn OFF Lamp/Bit @RAM:01
			PRI_($00)				;Priority=#00
			POINTS_(1,10000)			;10000 Points
			.db $5A,$FC,$E7,$04,$02		;BEQ_RAM$07==#4 to gb_84
			ADDRAM_($07,$FF)			;RAM$07+=$FF
gb_84			JSRDR_(random_x07)	
			EXE_($02)				;CPU Execute Next 2 Bytes
			adda	game_ram_3
			SND_($1B)				;Sound #1B
gb_86			.db $5A,$FD,$E5,$09,$02		;BEQ_RAM$05>=#9 to gb_85
			SLEEP_(32)
gb_85			SLEEP_(15)
			.db $5A,$D0,$2F,$F4		;BEQ_BIT2#2F to gb_86
			ADDRAM_($00,$FF)			;RAM$00+=$FF
			.db $5B,$FC,$E0,$00,$ED		;BNE_RAM$00==#0 to gb_86
			JMPR_(gb_34)
			
gj_17			psha	
			pshb	
			jsr	random_x03
			staa	game_ram_e
			pulb	
			pula	
			beq	gb_87
			psha	
			ldaa	hy_unknown_1
			cmpa	#$03
			pula	
			bgt	gb_87
gb_8B			psha	
			ldaa	#$30
			staa	thread_priority
			pula	
			ldx	#gj_33
			jsr	newthread_sp
			swi	
			SND_($1D)				;Sound #1D
gb_38			SLEEP_(10)
			.db $5A,$FE,$F2,$FF,$30,$F9	;BEQ_(BIT#FFFFFFF0 P #FF) to gb_38
			CPUX_					;Resume CPU Execution
			bsr	gb_8A
			beq	gb_87
			tst	hy_unknown_4
			bne	gb_87
			dec	game_ram_e
			bne	gb_8B
gb_87			rts	

gj_33			staa	game_ram_d
			suba	#$53
			jsr	lampm_x
			oraa	#$C0
			jsr	lampm_set0
			anda	#$8F
			psha	
			tba	
			ldab	hy_unknown_1
			jsr	lamp_off_b
			pula	
gb_C3			jsr	addthread
			.db $08
			psha	
			pshb	
			ldaa	game_ram_d
			jsr	bit_lamp_buf_f
			pulb	
			pula	
			beq	gb_C2
			jsr	lampm_e
			incb	
			cmpb	#$05
			bls	gb_C3
			bsr	gb_C4
			swi	
			PRI_($00)				;Priority=#00
			JMPR_(gj_1A)
			
gb_C4			psha	
			pshb	
			ldaa	#$2F
			jsr	bit_lamp_buf_f
			pulb	
			pula	
			bne	gb_87
			bsr	gb_DE
			oraa	#$C0
gb_DE			jmp	lampm_clr0

gb_C2			psha	
			ldaa	#$0B
			jsr	score_main
			pula	
			bsr	gb_C4
			bra	gb_3B

gb_8A			psha	
			pshb	
			jsr	bit_lamp_buf_f
gb_E1			pulb	
			pula	
			rts	

gj_16			psha	
			clra	
gb_83			decb	
			beq	gb_82
			adda	#$06
			bra	gb_83

gb_82			tab	
			pula	
			rts	

gj_18			psha	
			ldaa	hy_unknown_1
			inca	
			staa	hy_unknown_1
			cmpa	#$06
			pula	
			bne	gb_88
			clrb	
			rts	

gb_88			lsr	hy_unknown_4
			bcs	gb_C5
			lsr	hy_unknown_4
			bcs	gb_C6
			psha	
			jsr	get_random
			rora	
			bita	#$08
			pula	
			bcs	gb_C7
			beq	gb_C6
gb_C5			deca	
			cmpa	#$53
			beq	gb_C8
			subb	#$05
			bra	gb_C9

gb_C6			inca	
			cmpa	#$5D
			beq	gb_DF
			addb	#$07
			bra	gb_C9

gb_C8			inca	
			bra	gb_C7

gb_DF			deca	
gb_C7			incb	
gb_C9			psha	
			pshb	
			suba	#$53
			jsr	lfill_b
			bcc	gb_E0
			jsr	bit_lamp_buf_f
			beq	gb_E1
gb_E0			pulb	
			pula	
			jsr	addthread
			.db $01
			decb	
			bra	gb_88

gj_27			jsr	lampm_c
			jsr	lfill_b
			bcs	gb_3B
			jsr	addthread
			.db $04
			bra	gj_27

gb_3B			jmp	killthread

gb_3A			ldab	#$0F
gb_39			jsr	addthread
			.db $40
			decb	
			bne	gb_39
			ldaa	game_ram_9
			deca	
			staa	game_ram_9
			cmpa	#$09
			bgt	gb_3A
			bra	gb_3B

sw_z_bomb		.db $5A,$FB,$F3,$F1,$D0,$30,$1E	;BEQ_(BIT2#30 || (!GAME)) to gb_09
			PRI_($10)				;Priority=#10
			REMTHREADS_($FF,$10)		;Remove Multiple Threads Based on Priority
			JSRD_(setup_msg_endptr)		
			JSRD_(gj_08)			
			JMPD_(gj_09)
			
gj_46			swi	
			SETRAM_($00,$09)			;RAM$00=$09
gb_3C			RROL0_($96,$15)			;Effect: Range #96 Range #15
			SND_($0F)				;Sound #0F
			SLEEP_(5)
			ADDRAM_($00,$FF)			;RAM$00+=$FF
			.db $5B,$FC,$E0,$00,$F4		;BNE_RAM$00==#0 to gb_3C
gb_59			KILL_					;Remove This Thread

gb_09			.db $5A,$FB,$D0,$2F,$D0,$30,$F8	;BEQ_(BIT2#30 || BIT2#2F) to gb_59
			EXE_($08)				;CPU Execute Next 8 Bytes
			jsr	get_current_ecs
			beq	gb_9D
			decb	
			stab	$00,X
gb_9D			ADDRAM_($00,$0B)			;RAM$00+=$0B
			.db $5A,$F5,$E0,$E9		;BEQ_RangeOFF#E0 to gb_59
			.db $5A,$FD,$E1,$02,$03		;BEQ_RAM$01>=#2 to gb_5A
			JSRD_(lampm_c)			
gb_5A			BITON4_($2F)			;Turn ON: Lamp#2F(lamp_o6)
			POINTS_(1,10)			;10 Points
			PRI_($A1)				;Priority=#A1
			RCLR1_($52)				;Effect: Range #52
			RCLR0_($CF,$D3,$12)		;Effect: Range #CF Range #D3 Range #12
			SETRAM_($01,$00)			;RAM$01=$00
gj_2A			.db $5B,$FE,$F2,$FF,$50,$0B	;BNE_(BIT#10 P #FF) to gb_5B
			ADDRAM_($08,$01)			;RAM$08+=$01
			ADDRAM_($01,$01)			;RAM$01+=$01
			POINTS_(5,1000)			;5000 Points
			REMTHREAD_($FF,$50)		;Remove Single Thread Based on Priority
			JMPR_(gj_2A)
			
gb_5B			.db $5B,$FE,$F2,$FF,$20,$0B	;BNE_(LAMP#20(lamp_m3) P #FF) to gb_9E
			POINTS_(1,1000)			;1000 Points
			ADDRAM_($01,$01)			;RAM$01+=$01
			ADDRAM_($08,$01)			;RAM$08+=$01
			REMTHREAD_($FF,$20)		;Remove Single Thread Based on Priority
			JMPR_(gb_5B)
			
gb_9E			.db $5B,$FE,$F2,$F4,$A4,$07	;BNE_(BIT#64 P #F4) to gb_D1
			EXE_($06)				;CPU Execute Next 6 Bytes
			ldx	#gj_49
			jsr	addthread_clra
gb_D1			RSET1_($54)				;Effect: Range #54
			JSRR_(gj_43)			
			EXE_($08)				;CPU Execute Next 8 Bytes
			ldaa	game_ram_3
			sba	
			bgt	gb_E9
			clra	
gb_E9			staa	game_ram_3
			JSRDR_(zbomb_ani)		
			SND_($0B)				;Sound #0B
			JSRDR_(zbomb_ani3)	
			RCLR0_($12)				;Effect: Range #12
			RCLR1_($54)				;Effect: Range #54
			BITOFF4_($2F)			;Turn OFF: Lamp#2F(lamp_o6)
			JMPR_(chk_wave_compl)
		
			.db $03


gj_13			ADDRAM_($08,$01)			;RAM$08+=$01
gj_43			.db $5B,$FD,$E8,$06,$02		;BNE_RAM$08>=#6 to gb_70
			SETRAM_($08,$06)			;RAM$08=$06
gb_70			MRTS_					;Macro RTS, Save MRA,MRB

zbomb_ani		ldx	#lmp_ani_inout-1
gb_EA			inx	
			cpx	#lmp_ani_outin
			beq	zbomb_ani2
			ldab	$00,X
			tba	
			anda	#$7F
			jsr	lamp_on_1
			tstb	
			bmi	gb_EA
			ldaa	#$0F
			jsr	isnd_once
			jsr	addthread
			.db $02
			bra	gb_EA

lmpanirts		rts	

zbomb_ani2		ldx	#lmp_ani_inout-1
gb_101		inx	
			cpx	#lmp_ani_outin
			beq	lmpanirts
			ldab	$00,X
			tba	
			anda	#$7F
			jsr	lamp_off_1
			tstb	
			bmi	gb_101
			jsr	addthread
			.db $02
			bra	gb_101

zbomb_ani3		ldx	#lmp_ani_inout-1
gb_ED			stx	hy_unknown_2
gb_EB			inx	
			cpx	#lmp_ani_outin
			beq	lmpanirts
			ldab	$00,X
			tba	
			anda	#$7F
			jsr	lamp_on_1
			tstb	
			bmi	gb_EB
			jsr	addthread
			.db $03
			ldx	hy_unknown_2
gb_EC			inx	
			ldab	$00,X
			tba	
			anda	#$7F
			jsr	lamp_off_1
			tstb	
			bmi	gb_EC
			bra	gb_ED

			.db $00


gameover_entry	swi	
			SOL_($01,$02,$03,$06,$07,$09)	; Sol#1:energy_flash Sol#2:p1_flash Sol#3:gi_relay_bb Sol#6:gi_relay_pf Sol#7:p2_flash Sol#9:ball_lift
			SND_($18)				;Sound #18
			RCLR0_($14)				;Effect: Range #14
			RCLR1_($D4,$14)			;Effect: Range #D4 Range #14
			PRI_($10)				;Priority=#10
			CPUX_					;Resume CPU Execution
			ldx	#gj_36
			jsr	addthread_clra
			clr	flag_tilt
			clr	bitflags+6
gb_5C			ldx	#msg_williams
			bsr	ani_msg_starslide
			jsr	addthread
			.db $90
			ldx	#msg_electronics
			bsr	ani_msg_starslide
			jsr	addthread
			.db $90
			ldx	#msg_presents
			bsr	ani_msg_starslide
			jsr	addthread
			.db $70
			ldx	#msg_hyperball
			clrb	
			jsr	ani_msg_letters
			ldab	#$25
			ldx	#alpha_b0+11
			jsr	ani_circle
gj_09			inc	bitflags+6
			jsr	gj_2B
gj_39			jsr	setup_msg_endptr
			jsr	gj_08
			staa	bitflags+6
			ldx	#msg_credit
			jsr	load_message
			ldaa	current_credits
			jsr	gj_2C
			jsr	addthread
			.db $E0
			bra	gb_5C

ani_msg_starslide	jsr	load_message
ani_starslide	jsr	clr_alpha_set_b1
			ldaa	#$04
			ldx	#alpha_b1
gb_50			bsr	gb_4F
			jsr	hex2bitpos
			comb	
			andb	dmask_p3
			stab	dmask_p3
			inx	
			deca	
			bpl	gb_50
			ldaa	#$06
gb_51			bsr	gb_4F
			jsr	hex2bitpos
			comb	
			andb	dmask_p4
			stab	dmask_p4
			inx	
			deca	
			bpl	gb_51
			rts	

gb_4F			psha	
			pshb	
			ldab	#$01
gb_97			ldaa	#$18
			staa	$00,X
			jsr	addthread
			.db $02
			ldaa	#$2B
			staa	$00,X
			jsr	addthread
			.db $02
			decb	
			bne	gb_97
			bra	gb_98

gj_37			psha	
			pshb	
			bsr	gj_1E
			jsr	lamp_flash
gb_98			pulb	
			pula	
			rts	

gj_1E			ldx	#gj_1B
			jsr	xplusb
			ldaa	$00,X
			rts	

gj_07			ldx	#gj_28
			bsr	gb_3D
			ldx	#gb_4B
gb_3D			jmp	addthread_clra

gj_36			ldx	#gj_01
			bsr	gb_3D
gj_28			ldx	#gj_1C
			bsr	gb_3D
gb_8D			ldx	#lmp_ani_outin-1
gb_3F			inx	
			cpx	#disp_wave_num
			beq	gb_3E
			ldaa	$00,X
			tab	
			anda	#$7F
			jsr	lamp_on
			jsr	lamp_on_b
			tstb	
			bmi	gb_3F
			jsr	addthread
			.db $05
			bra	gb_3F

gb_3E			ldx	#lmp_ani_outin-1
gb_8E			inx	
			cpx	#disp_wave_num
			beq	gb_8D
			ldaa	$00,X
			tab	
			anda	#$7F
			jsr	lamp_off
			tstb	
			bmi	gb_8E
			jsr	addthread
			.db $05
			bra	gb_8E

gj_1C			ldaa	#$D4
			jsr	lampm_f
			jsr	addthread
			.db $04
			bra	gj_1C

			ldaa	#$08
gb_40			jsr	addthread
			.db $40
			deca	
			bne	gb_40
			ldaa	#$09
			jsr	solbuf
			jmp	killthread

gj_48			clrb	
			ldaa	#$0C
			jmp	gj_20

gj_2F			tab	
			anda	#$0F
			adda	#$1B
			oraa	#$80
			staa	$02,X
			jsr	split_ab
			clra	
			tstb	
			beq	gb_AC
			addb	#$1B
			tba	
gb_AC			staa	$01,X
			ldaa	#$1B
			staa	$03,X
			staa	$04,X
			staa	$05,X
			rts	

reflex_thread	ldx	#msg_reflex
			ldaa	#$04
			staa	game_ram_a
			jsr	ani_msg_rlslide
			ldx	#msg_wave
			jsr	ani_msg_rlslide
			jsr	addthread
			.db $40
			bsr	gj_48
			staa	game_ram_e
			staa	game_ram_a
reflex_lp		jsr	setup_msg_endptr
			inc	game_ram_e
			ldaa	#$14
			cmpa	game_ram_e
			bne	gb_EE
			jsr	setup_msg_endptr
			ldaa	#$10
			jsr	isnd_once
			ldaa	#$01
			staa	bitflags+6
			ldx	#msg_great_reflex
			jsr	ani_msg_rlslide
			bsr	gj_48
			ldx	#alpha_b0
			ldaa	game_ram_5
			cmpa	#$06
			bgt	gb_EF
			ldaa	#$2C
			jsr	score_main
			ldaa	#$50
			bsr	gj_2F
			bra	gb_F0

gb_EF			ldaa	#$0D
			jsr	score_main
			ldaa	#$1C
			staa	$00,X
			ldaa	#$9B
			staa	$02,X
			ldaa	#$1B
			bsr	gb_AC
gb_F0			ldx	#alpha_b0+7
			stx	temp1
			ldx	#msg_bonus
			jsr	gj_29
to_next_wave	swi	
			REMTHREADS_($08,$00)		;Remove Multiple Threads Based on Priority
			JSR_(gj_06)				
			JSRDR_(gj_07)		
			SND_($0D)				;Sound #0D
			SLEEP_(80)
			JMP_(setup_next_wave)		


gb_EE			swi	
			PRI_($00)				;Priority=#00
gb_41			SLEEP_(1)
			JSRD_(get_random)			
gj_1D			EXE_($02)				;CPU Execute Next 2 Bytes
			anda	#$1F
			.db $5A,$FB,$FD,$E0,$16,$D0,$2F,$F1	;BEQ_(BIT2#2F || RAM$00>=#22) to gb_41
			.db $5B,$F6,$57,$02		;BNE_RangeON#57 to gb_42
			RCLR0_($57)				;Effect: Range #57
gb_42			RAMCPY_($1,$0)			;Copy RAM;RAM,1 = RAM,0
			ADDRAM_($01,$31)			;RAM$01+=$31
			.db $5B,$D0,$E1,$04		;BNE_BIT2#E1 to gb_43
			ADDRAM_($00,$01)			;RAM$00+=$01
			JMPR_(gj_1D)
			
gb_43			BITON4a_($01)			;Turn ON: Lamp#01(lamp_h2)
			RAMCPY_($1,$0)			;Copy RAM;RAM,1 = RAM,0
			ADDRAM_($00,$49)			;RAM$00+=$49
			BITON4a_($00)			;Turn ON: Lamp#00(lamp_h1)
			.db $5A,$FB,$FC,$E1,$16,$FC,$E1,$08,$04;BEQ_(RAM$01==#8 || RAM$01==#22) to gb_8F
			JSRDR_(gj_37)		
			JMPR_(gj_38)
			
gb_8F			.db $5A,$FD,$E1,$08,$06		;BEQ_RAM$01>=#8 to gb_CE
			BITFL_($BA,$BB,$3C)		;Flash: Lamp#3A(lamp_e3), Lamp#3B(lamp_e2), Lamp#3C(lamp_e1)
			JMPR_(gj_38)
			
gb_CE			BITFL_($C3,$C4,$45)		;Flash: Bit#03, Bit#04, Bit#05
gj_38			CPUX_					;Resume CPU Execution
			psha	
			pshb	
			ldx	#alpha_b0+2
			ldaa	game_ram_f
			jsr	gj_2F
			pulb	
			pula	
			jsr	addthread
			.db $30
			psha	
			ldaa	game_ram_c
			staa	game_ram_d
gb_E4			ldaa	game_ram_d
			cmpa	#$04
			blt	gb_E2
			dec	game_ram_d
gb_E2			staa	thread_timer_byte
			ldaa	#$01
			jsr	isnd_once
			jsr	delaythread
			pula	
			jsr	gb_8A
			beq	gb_E3
			ldx	#alpha_b0+3
			psha	
			jsr	gj_47
			bne	gb_E4
			ldaa	game_ram_e
			cmpa	#$05
			ble	gb_E5
			pula	
			ldaa	#$1E
			staa	flag_tilt
			jsr	isnd_once
			jsr	setup_msg_endptr
			ldaa	#$01
			staa	bitflags+6
			ldx	#msg_youmissed
			jsr	ani_msg_rlslide
			jsr	gj_48
			jmp	to_next_wave

gb_E5			pula	
			bsr	gb_F8
			bra	gb_FC

gb_E3			bsr	gb_F8
			ldx	#alpha_b0+3
			jsr	gb_D3
			jsr	gj_0D
			ldaa	#$06
gb_F9			jsr	invert_alphamsk
			psha	
			ldaa	#$0E
			jsr	isnd_once
			pula	
			jsr	addthread
			.db $05
			deca	
			bne	gb_F9
			ldaa	game_ram_f
			adda	#$01
			daa	
			staa	game_ram_f
gb_FC			jmp	reflex_lp

gj_47			ldaa	$01,X
			cmpa	#$9B
			beq	gb_FA
			deca	
			staa	$01,X
			bra	gb_FB

gb_FA			ldaa	$00,X
			beq	gb_FB
			deca	
			cmpa	#$1B
			bne	gb_103
			clra	
gb_103		staa	$00,X
			ldaa	#$A4
			staa	$01,X
gb_FB			rts	

gb_F8			swi	
			BITOFF4a_($00)			;Turn OFF: Lamp#00(lamp_h1)
			.db $5A,$FB,$FC,$E1,$16,$FC,$E1,$08,$06;BEQ_(RAM$01==#8 || RAM$01==#22) to gb_44
			JSRDR_(gj_1E)		
			BITOFFP_($00)			;Turn OFF Lamp/Bit @RAM:00
			JMPR_(gj_1F)
			
gb_44			.db $5A,$FD,$E1,$08,$04		;BEQ_RAM$01>=#8 to gb_90
			RCLR0_($10)				;Effect: Range #10
			JMPR_(gj_1F)
			
gb_90			RCLR0_($11)				;Effect: Range #11
gj_1F			CPUX_					;Resume CPU Execution
			rts	

hook_coin		swi	
			SND_($06)				;Sound #06
			.db $5A,$FB,$FB,$F0,$D0,$30,$F3,$F1,$F3;BEQ_((!GAME) || (BIT2#30 || TILT)) to gj_1F
			REMTHREADS_($FF,$10)		;Remove Multiple Threads Based on Priority
			CPUX_					;Resume CPU Execution
			ldaa	#$10
			ldx	#gj_39
			jmp	newthreadp

highscoresound	ldab	#$0A
			clr	flag_tilt
			ldaa	sys_temp2
			staa	$13B7
			staa	flag_gameover
gb_45			ldaa	gr_hssound
			jsr	isnd_once
			ldx	#msg_player
			pshb	
			jsr	load_message
			pulb	
			ldaa	$13B7
			nega	
			adda	#$1E
			ldx	temp1
			staa	$01,X
			jsr	addthread
			.db $08
			jsr	setup_msg_endptr
			jsr	addthread
			.db $08
			decb	
			bne	gb_45
			ldx	#msg_great_score
			jsr	load_message
			ldx	temp1
			ldab	#$10
			jsr	ani_circle
			ldaa	#$18
			jsr	isnd_once
			ldaa	#$05
			ldab	#$40
			stab	$00,X
			jsr	gj_20
			ldx	#msg_enter_your
			jsr	ani_msg_rlslide
			ldx	#msg_initials
			jsr	ani_msg_rlslide
			ldaa	#$05
			ldab	#$40
			jsr	gj_20
			jsr	gj_21
			ldx	#alpha_b0
			stx	hy_unknown_e
gb_48			ldaa	#$2E
			staa	$00,X
gb_47			jsr	gj_22
			ldaa	$00,X
			cmpa	#$2D
			bne	gb_46
			clr	$00,X
			dex	
			ldaa	$00,X
			bne	gb_47
			bra	gb_48

gb_46			cmpa	#$2E
			bne	gb_96
			ldaa	#$00
			staa	$00,X
gb_96			inx	
			cpx	#alpha_b0+3
			bne	gb_48
gb_95			ldx	#aud_game1
			stx	temp1
			ldab	#$0C
			ldx	#alpha_b0
			jsr	copyblock2
			stab	bitflags+6
			jmp	set_hstd

gj_22			ldaa	$00,X
			staa	$13B6
			ldaa	#$60
			staa	$13B8
gb_E8			ldaa	#$06
			staa	$13B7
			dec	$13B8
			bne	gb_94
			ins	
			ins	
			clr	$00,X
			bra	gb_95

gb_94			jsr	addthread
			.db $02
			ldaa	$80
			bpl	gb_CF
			jsr	gj_42
gb_D0			jsr	addthread
			.db $02
			ldaa	$80
			bmi	gb_D0
			rts	

gb_CF			ldaa	$81
			anda	#$03
			bne	gb_E6
			dec	$13B7
			bne	gb_94
			ldaa	$00,X
			beq	gb_E7
			clr	$00,X
			bra	gb_E8

gb_E7			ldaa	$13B6
			staa	$00,X
			bra	gb_E8

gb_E6			jsr	gj_42
			ldab	#$20
			stab	$13B7
			rora	
			bcs	gb_FD
gb_100		bsr	gb_FE
gb_FF			jsr	addthread
			.db $01
			ldaa	$81
			bita	#$02
			beq	gj_22
			dec	$13B7
			bne	gb_FF
			ldaa	#$05
			staa	$13B7
			bra	gb_100

gb_FD			bsr	gb_104
gb_105		jsr	addthread
			.db $01
			ldaa	$81
			rora	
			bcc	gj_22
			dec	$13B7
			bne	gb_105
			ldaa	#$05
			staa	$13B7
			bra	gb_FD

gb_FE			ldaa	$00,X
			inca	
			cmpa	#$2E
			bne	gb_106
gb_109		ldaa	#$2E
gb_106		cmpa	#$2F
			bne	gb_107
			ldaa	#$01
gb_107		cmpa	#$1B
			bne	gb_108
			cpx	#alpha_b0
			beq	gb_109
gb_10D		ldaa	#$2D
gb_108		staa	$00,X
			rts	

gb_104		ldaa	$00,X
			deca	
			bne	gb_10A
			ldaa	#$2E
gb_10A		cmpa	#$2C
			bne	gb_10B
gb_10C		ldaa	#$1A
gb_10B		cmpa	#$2D
			bne	gb_108
			cpx	#alpha_b0
			beq	gb_10C
			bra	gb_10D

gj_42			psha	
			ldaa	$13B6
			staa	$00,X
			pula	
			rts	

gj_2B			jsr	show_hstd
			ldab	comma_flags
			stab	$13B6
			coma	
			tst	score_p1_b1
			bne	gb_9F
			staa	score_p1_b1
			staa	score_p2_b1
			ldaa	#$33
gb_9F			staa	comma_flags
			ldaa	#$7F
			jsr	clr_dis_masks12
			ldx	#msg_hy_score
			jsr	load_message
			jsr	addthread
			.db $30
			ldaa	#$0C
			staa	$13A9
			ldx	#$13AA
			stx	temp1
			ldx	#aud_game1
			ldab	#$0C
			jsr	block_copy
			ldx	#$13A9
			jsr	gb_0E
			jsr	slide_l
			jsr	addthread
			.db $A0
			ldab	$13B6
			stab	comma_flags
			clra	
			jmp	clr_dis_masks12

gj_01			ldx	#$5501
			stx	lampbufferselectx+2
			ldaa	#$80
			ldab	player_up
			beq	gb_49
			lsra	
gb_49			staa	lampbufferselectx+1
			ldx	#gj_23
			jsr	addthread_clra
			swi	
			.db $5B,$F1,$05			;BNE_GAME to gb_4A
			RSET0_($0A)				;Effect: Range #0A
			RCLR1L0_($8A,$0A)			;Effect: Range #8A Range #0A
gb_4A			RCLR1_($0A)				;Effect: Range #0A
gj_24			SLEEP_(5)
			RINV1_($4A)				;Effect: Range #4A
			JMPR_(gj_24)
			
gj_23			swi	
gj_25			SLEEPI_($2)				;Delay RAM$02
			RROR0_($0A)				;Effect: Range #0A
			JMPR_(gj_25)
			
gb_4B			ldaa	#$40
			jsr	solbuf
			jsr	addthread
			.db $0A
			bra	gb_4B


lamptable		.db $00 ,$5F	;(00) lamp_h1 -- lamp_uu6
			.db $00 ,$05	;(01) lamp_h1 -- lamp_h6
			.db $06 ,$0B	;(02) lamp_i1 -- lamp_i6
			.db $0C ,$11	;(03) lamp_j1 -- lamp_j6
			.db $12 ,$17	;(04) lamp_k1 -- lamp_k6
			.db $18 ,$1D	;(05) lamp_l1 -- lamp_l6
			.db $1E ,$23	;(06) lamp_m1 -- lamp_m6
			.db $24 ,$29	;(07) lamp_n1 -- lamp_n6
			.db $2A ,$2F	;(08) lamp_o1 -- lamp_o6
			.db $30 ,$35	;(09) lamp_p1 -- lamp_p6
			.db $50 ,$59	;(0A) lamp_ec1 -- lamp_ec10
			.db $48 ,$4A	;(0B) lamp_p1b1 -- lamp_p1b3
			.db $4B ,$4D	;(0C) lamp_p2b1 -- lamp_p2b3
			.db $31 ,$39	;(0D) lamp_p2 -- lamp_d
			.db $3A ,$47	;(0E) lamp_e3 -- lamp_r
			.db $49 ,$5F	;(0F) lamp_p1b2 -- lamp_uu6
			.db $3A ,$3C	;(10) lamp_e3 -- lamp_e1
			.db $43 ,$45	;(11) lamp_t1 -- lamp_t3
			.db $00 ,$47	;(12) lamp_h1 -- lamp_r
			.db $01 ,$09	;(13) lamp_h2 -- lamp_i4
			.db $00 ,$4F	;(14) lamp_h1 -- lamp_p2
			.db $36 ,$3E	;(15) lamp_a -- lamp_g
			.db $3F ,$47	;(16) lamp_y -- lamp_r
			.db $31 ,$47	;(17) lamp_p2 -- lamp_r


soundtable		.db $22, $30,	$3C		;(00) 
			.db $23, $10,	$3B		;(01) 
			.db $22, $20,	$3A		;(02) 
			.dw c_sound1\	.db $FF	;(03) 
			.dw c_sound2\	.db $FF	;(04) 
			.dw c_sound3\	.db $FF	;(05) 
			.db $22, $30,	$36		;(06) 
			.db $22, $20,	$35		;(07) 
			.db $22, $20,	$34		;(08) 
			.dw c_sound4\	.db $FF	;(09) 
			.db $22, $20,	$30		;(0A) 
			.db $22, $20,	$2F		;(0B) 
			.db $22, $20,	$2E		;(0C) 
			.db $22, $20,	$2D		;(0D) 
			.db $22, $20,	$2C		;(0E) 
			.db $22, $20,	$2B		;(0F) 
			.db $83, $50,	$2A		;(10) 
			.db $22, $20,	$29		;(11) 
			.db $83, $40,	$32		;(12) 
			.db $22, $20,	$28		;(13) 
			.db $22, $20,	$27		;(14) 
			.db $23, $20,	$3D		;(15) 
			.db $22, $20,	$26		;(16) 
			.db $22, $20,	$25		;(17) 
			.db $24, $20,	$3E		;(18) 
			.db $22, $20,	$24		;(19) 
			.db $22, $20,	$23		;(1A) 
			.db $22, $20,	$22		;(1B) 
			.db $22, $20,	$31		;(1C) 
			.db $22, $20,	$21		;(1D) 
			.db $23, $30,	$20		;(1E) 

c_sound2		.db $21,$92,$38,$3E,$3F

c_sound1		.db $26,$F5,$2E,$C0,$2D,$3F

c_sound4		.db $26,$FF,$37,$2D,$3F

c_sound3		.db $26,$FF,$24,$2D,$3F


switchtable		.db %10010011	\.dw sw_plumbtilt		;(1) plumbtilt
			.db %01110001	\.dw sw_2p_start		;(2) 2p_start
			.db %01110001	\.dw sw_1p_start		;(3) 1p_start
			.db %11110010	\.dw coin_accepted	;(4) coin_r
			.db %11110010	\.dw coin_accepted	;(5) coin_c
			.db %11110010	\.dw coin_accepted	;(6) coin_l
			.db %01110001	\.dw sw_slam		;(7) slam
			.db %01110001	\.dw sw_hstd_res		;(8) hstd_res
			.db %00010001	\.dw sw_A			;(9) A
			.db %00010001	\.dw sw_B			;(10) B
			.db %00010001	\.dw sw_C			;(11) C
			.db %00010001	\.dw sw_D			;(12) D
			.db %00010001	\.dw sw_Y			;(13) Y
			.db %00010001	\.dw sw_W			;(14) W
			.db %00010001	\.dw sw_V			;(15) V
			.db %00010001	\.dw sw_U			;(16) U
			.db %10010001	\.dw sw_E			;(17) E
			.db %00010001	\.dw sw_F			;(18) F
			.db %00010001	\.dw sw_G			;(19) G
			.db %10001111	\.dw sw_H			;(20) H
			.db %10001111	\.dw sw_I			;(21) I
			.db %10001111	\.dw sw_J			;(22) J
			.db %10001111	\.dw sw_K			;(23) K
			.db %10001111	\.dw sw_L			;(24) L
			.db %10001111	\.dw sw_M			;(25) M
			.db %10001111	\.dw sw_N			;(26) N
			.db %10001111	\.dw sw_O			;(27) O
			.db %10001111	\.dw sw_P			;(28) P
			.db %00010001	\.dw sw_R			;(29) R
			.db %00010001	\.dw sw_S			;(30) S
			.db %10010001	\.dw sw_T			;(31) T
			.db %10110011	\.dw sw_z_bomb		;(32) z_bomb
			.db %10010100	\.dw sw_l_shooter		;(33) l_shooter
			.db %10010100	\.dw sw_r_shooter		;(34) r_shooter
switchtable_end

gj_12			.db $3D,$3E

gj_02			.db $36,$37,$38,$39,$3F,$40,$41,$42,$46,$47

gj_1B			.db $36,$37,$38,$39,$3F,$40,$41,$42,$00,$3D,$3E,$00,$06,$0C,$12,$18
			.db $1E,$24,$2A,$30,$47,$46,$00

gj_2D			.db $06,$07,$01,$02,$03,$04,$19,$17,$16,$15,$13,$12,$05,$14

gj_3A			.db $0C,$0F,$13,$15

gj_3E			.db $E5,$93,$E5,$8D,$E5,$C2,$E5,$DD,$E5,$EA,$E5,$E4,$E5,$F0

gj_26			.db $01,$02,$03,$04,$19,$17,$16,$15,$05,$06,$07,$08,$09,$0A,$0B,$0C
			.db $0D,$0E,$0F,$10,$12,$13,$14

character_defs	.db $00,$00,$37,$06,$8F,$14,$39,$00,$8F,$10,$39,$02,$31,$02,$3D,$04
			.db $36,$06,$89,$10,$1E,$00,$30,$23,$38,$00,$76,$01,$76,$20,$3F,$00
			.db $33,$06,$3F,$20,$33,$26,$2D,$06,$81,$10,$3E,$00,$30,$09,$36,$28
			.db $40,$29,$22,$16,$09,$09,$3F,$09,$80,$10,$0B,$0C,$0D,$05,$26,$06
			.db $29,$22,$3D,$06,$07,$00,$3F,$06,$2F,$06,$82,$00,$00,$06,$40,$20
			.db $80,$10,$00,$09,$BB,$04,$80,$16,$C0,$3F,$00,$25,$08,$00

msg_williams	.db $28,$17,$09,$0C,$0C,$09,$01,$0D,$13

msg_electronics	.db $0B,$05,$0C,$05,$03,$14,$12,$0F,$0E,$09,$03,$13

msg_presents	.db $28,$10,$12,$05,$13,$05,$0E,$14,$13

msg_hyperball	.db $19,$08,$19,$10,$05,$12,$02,$01,$0C,$0C

msg_credit		.db $16,$03,$12,$05,$04,$09,$14

msg_player		.db $26,$10,$0C,$01,$19,$05,$12

msg_game		.db $05,$00,$07,$01,$0D,$05

msg_over		.db $05,$0F,$16,$05,$12,$00

msg_critical	.db $28,$03,$12,$09,$14,$09,$03,$01,$0C

msg_wave		.db $24,$17,$01,$16,$05

msg_completed	.db $19,$03,$0F,$0D,$10,$0C,$05,$14,$05,$04

msg_spell		.db $19,$2C,$00,$13,$10,$05,$0C,$0C,$00,$2C

msg_bonus		.db $05,$02,$0F,$0E,$15,$13

msg_energy		.db $06,$05,$0E,$05,$12,$07,$19

msg_youmissed	.db $0A,$19,$0F,$15,$00,$0D,$09,$13,$13,$05,$04

msg_reflex		.db $06,$12,$05,$06,$0C,$05,$18

msg_hit		.db $03,$08,$09,$14

msg_3eu		.db $15,$1E,$26,$45,$55,$00

msg_3zb		.db $15,$1E,$26,$5A,$42,$00

msg_zeros		.db $05,$24,$9B,$1B,$1B,$1B

msg_hyper		.db $05,$08,$19,$10,$05,$12

msg_enuit		.db $07,$05,$26,$15,$0E,$09,$14,$00

msg_ssr_ejs		.db $0C,$2C,$00,$13,$13,$12,$00,$00,$05,$0A,$13,$00,$2C

msg_cannon		.db $06,$03,$01,$0E,$0E,$0F,$0E

msg_alien		.db $05,$01,$0C,$09,$05,$0E

msg_laser		.db $05,$0C,$01,$13,$05,$12

msg_ray		.db $03,$12,$01,$19

msg_tilt		.db $28,$2C,$00,$14,$09,$0C,$14,$00,$2C

msg_great_reflex	.db $0C,$07,$12,$05,$01,$14,$00,$12,$05,$06,$0C,$05,$18

msg_enter_your	.db $0A,$05,$0E,$14,$05,$12,$00,$19,$0F,$15,$12

msg_initials	.db $08,$09,$0E,$09,$14,$09,$01,$0C,$13

msg_great_score	.db $0B,$07,$12,$05,$01,$14,$00,$13,$03,$0F,$12,$05

msg_hy_score	.db $28,$08,$19,$00,$13,$03,$0F,$12

lmp_ani_inout-1	.db $05

lmp_ani_inout	.db $1B,$95,$21,$A7,$A2,$9C,$96,$8F,$1A,$A0,$AD,$A8,$90,$89,$14,$A6
			.db $B3,$AE,$8A,$83,$0E,$AC,$A9,$A3,$9D,$97,$91,$84,$B4,$08,$B2,$B5
			.db $AF,$8B,$85,$02,$CE,$CF,$C8,$CB,$93,$99,$1F,$CD,$CC,$C9,$CA,$81
			.db $87,$8D,$A5,$AB,$31,$C7,$C3,$C2,$BA,$B9,$3E,$C6,$C4,$C1,$B8,$BB
			.db $BD,$92,$98,$1E,$A4,$AA,$B0,$C5,$BF,$B6,$B7,$BC,$80,$86

lmp_ani_outin-1	.db $0C

lmp_ani_outin	.db $B6,$3F,$B7,$40,$B8,$C1,$CA,$4D,$C9,$CC,$85,$8B,$91,$97,$9D,$A3
			.db $A9,$AF,$35,$C8,$CB,$84,$8A,$90,$96,$9C,$A2,$A8,$AE,$34,$C2,$CF
			.db $B9,$4E,$83,$89,$8F,$95,$9B,$A1,$A7,$AD,$33,$BA,$C3,$82,$88,$8E
			.db $94,$9A,$A0,$A6,$AC,$32,$BB,$44,$C6,$C7,$BC,$81,$87,$8D,$93,$99
			.db $9F,$A5,$AB,$31,$BD,$C5,$3E,$80,$86,$8C,$92,$98,$9E,$A4,$AA,$30


disp_wave_num	ldaa	game_ram_5
gj_2C			tab	
			anda	#$0F
			adda	#$1B
			ldx	temp1
			staa	$02,X
			jsr	split_ab
			tstb	
			beq	gb_9C
			addb	#$1B
gb_9C			stab	$01,X
			rts	

gj_21			ldx	#hy_unknown_e
			stx	temp1
			bsr	disp_wave_num
			ldaa	#$08
			staa	$00,X
			ldaa	#$13
			staa	$08,X
			clr	$03,X
			ldx	#$13AB
			stx	temp1
			ldx	#msg_wave
			jsr	gj_29
			jsr	gb_0E
			clrb	
			ldaa	#$04
			jsr	gj_20
			ldx	#hy_unknown_e
			jmp	slide_l

dt_E713		.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
			.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

sw_slam		.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
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


	.end

;**************************************
;* Label Definitions                   
;**************************************
; d000	gr_gamenumber
; d002	gr_romrevision
; d003	gr_cmoscsum
; d005	gr_backuphstd
; d006	gr_replay1
; d007	gr_replay2
; d008	gr_replay3
; d009	gr_replay4
; d00a	gr_matchenable
; d00b	gr_specialaward
; d00c	gr_replayaward
; d00d	gr_maxplumbbobtilts
; d00e	gr_numberofballs
; d00f	gr_gameadjust1
; d010	gr_gameadjust2
; d011	gr_gameadjust3
; d012	gr_gameadjust4
; d013	gr_gameadjust5
; d014	gr_gameadjust6
; d015	gr_gameadjust7
; d016	gr_gameadjust8
; d017	gr_gameadjust9
; d018	gr_hstdcredits
; d019	gr_max_extraballs
; d01a	gr_max_credits
; d01b	gr_pricingdata
; d04b	gr_maxthreads
; d04c	gr_extendedromtest
; d04d	gr_lastswitch
; d04e	gr_numplayers
; d04f	gr_lamptable_ptr
; d051	gr_switchtable_ptr
; d053	gr_soundtable_ptr
; d055	gr_lampflashrate
; d056	gr_specialawardsound
; d057	gr_p1_startsound
; d058	gr_p2_startsound
; d05a	gr_hssound
; d05b	gr_gameoversound
; d05c	gr_creditsound
; d05d	gr_gameover_lamp
; d05f	gr_gameoverthread_ptr
; d05f	gr_tilt_lamp
; d066	gr_switchtypetable
; d074	gr_playerstartdata
; d092	gr_playerresetdata
; d0b0	gr_switch_event
; d0b2	gr_sound_event
; d0b4	gr_score_event
; d0b6	gr_eb_event
; d0b8	gr_special_event
; D0BA hook_mainloop
; d0ba	gr_macro_event
; d0bc	gr_ballstart_event
; d0be	gr_addplayer_event
; d0c0	gr_gameover_event
; d0c2	gr_hstdtoggle_event
; d0c4	gr_reset_hook_ptr
; d0c6	gr_main_hook_ptr
; d0c8	gr_coin_hook_ptr
; d0ca	gr_game_hook_ptr
; d0cc	gr_player_hook_ptr
; d0ce	gr_outhole_hook_ptr
; d0d0	gr_irq_entry
; d0d3	gr_swi_entry
; D0DC special_event
; D103 gb_02
; D108 hook_reset
; D11B sw_hstd_res
; D11D to_kill
; D120 hook_gamestart
; D123 gb_03
; D13B gb_01
; D13E sw_1p_start
; D13F sw_2p_start
; D157 gb_07
; D16F gs_forever
; D172 gb_06
; D193 gb_52
; D1A7 gb_53
; D1B9 jmp_cmosa
; D1BC extend_game
; D1C4 get_aud_ec_ex
; D1CC add_a_to_wave
; D1D2 gb_4D
; D1DA gb_4E
; D1DD ani_game_lr
; D1E9 to_kill2
; D1EC ani_over_rl
; D1FA killthreads_ff
; D1FF hook_outhole
; D20C gb_04
; D217 gb_05
; D22F show_gameover
; D246 goto_sme
; D249 slide_r
; D250 gb_5D
; D253 gb_0D
; D258 slide_l
; D25C gb_5F
; D25F gb_0F
; D26D ani_msg_rlslide
; D272 gj_2E
; D276 step_r
; D27E gb_60
; D28B step_l
; D293 gb_A0
; D29E gb_61
; D2A8 gb_A1
; D2B0 gb_0E
; D2BB gb_0C
; D2C4 gb_5E
; D2C8 gj_20
; D2CA gb_93
; D2CF gj_3D
; D2D1 gb_10
; D2D6 setup_msg_endptr
; D2F4 pulab_rts
; D2F7 ani_circle
; D2F9 gb_91
; D2FE gb_92
; D30B load_message
; D30D gj_29
; D315 ani_msg_letters
; D31B gb_CD
; D329 gb_CC
; D346 gj_0D
; D349 gj_08
; D34C clr_alpha_set_b1
; D34E clr_alpha_set_bx
; D354 clr_next_12
; D35A sw_plumbtilt
; D370 tilt_kill
; D371 tilt_sleeper
; D377 game_tilt
; D38A gb_99
; D3A1 gj_45
; D3B0 hook_playerinit
; D3CB plyer_load
; D3E2 gb_11
; D3E8 gj_0B
; D3F3 get_current_ecs
; D3F9 xplusb_ldb
; D3FF begin_play
; D407 gb_12
; D42F gb_63
; D439 gb_62
; D457 gb_66
; D461 gb_65
; D468 gb_68
; D470 gb_67
; D473 gb_64
; D47E gb_69
; D47F gb_6B
; D48B gb_6A
; D4A2 gb_A3
; D4A4 gb_A2
; D4AC gb_A4
; D4B8 gb_A5
; D4C6 gb_A6
; D4CD gb_A7
; D4CF gb_A8
; D4F0 gb_A9
; D4FF to_addthr_noa
; D501 start_reflex
; D50D addthread_clra
; D50E newthreadp
; D513 bolt_launcher
; D517 gb_17
; D530 gb_13
; D534 gb_14
; D536 gb_16
; D53D gb_15
; D547 sw_l_shooter
; D547 sw_r_shooter
; D549 gj_0A
; D55C gb_0A
; D563 gb_0B
; D564 gj_11
; D565 gb_18
; D57B gb_19
; D591 gb_1B
; D598 gb_1A
; D5AA start_rndawd
; D5AF gb_D2
; D5B2 gb_1C
; D5BB gb_1D
; D5C4 gb_20
; D5DE gb_1F
; D5E8 jmp_getrandom
; D5EB random_x03
; D5F0 random_x07
; D5F5 random_x0f
; D5FA gb_1E
; D602 gj_0E
; D626 gb_6C
; D632 gb_6D
; D646 gb_AA
; D64A gb_AB
; D64E gb_6E
; D65F gb_AD
; D666 sumthin
; D677 gb_21
; D680 gb_6F
; D682 gj_0F
; D690 gj_10
; D691 gb_22
; D6A5 gj_35
; D6BD gb_23
; D6BF get_rnd_lampnum
; D6C8 gb_54
; D6D4 gb_9A
; D6DD gb_9B
; D6E0 gb_55
; D6E3 gj_03
; D70A gj_06
; D728 sw_H
; D728 sw_I
; D728 sw_J
; D728 sw_K
; D728 sw_L
; D728 sw_M
; D728 sw_N
; D728 sw_O
; D728 sw_P
; D741 sw_common
; D743 chk_wave_compl
; D75E setup_next_wave
; D773 s_kill
; D774 show_wave_compl
; D785 sleep45
; D78A sw_T
; D794 sw_E
; D79E sw_F
; D7A2 sw_G
; D7A4 ssw_handler
; D7AD gj_04
; D7B5 gb_AE
; D7BE gb_08
; D7BF sw_S
; D7C3 sw_R
; D7C7 sw_A
; D7C7 sw_B
; D7C7 sw_C
; D7C7 sw_D
; D7C7 sw_U
; D7C7 sw_V
; D7C7 sw_W
; D7C7 sw_Y
; D7D2 gj_49
; D7D3 gj_14
; D7DC gb_24
; D7E0 gj_30
; D7E9 gb_71
; D7F1 gb_25
; D80D gb_B0
; D812 gb_AF
; D817 gb_B1
; D821 gb_D4
; D834 gb_D3
; D83E gb_F2
; D844 gb_F1
; D84C gb_F4
; D852 gb_F3
; D853 invert_alphamsk
; D858 stab_all_alphmsk
; D85D gb_79
; D85E gb_27
; D87A gb_28
; D87B gb_26
; D880 gb_29
; D885 start_spell
; D89C gb_2C
; D8B2 gb_77
; D8C1 gb_78
; D8CC gb_2B
; D8E0 gb_76
; D8EA gb_75
; D8F4 gb_D8
; D8F8 gb_BA
; D90C gb_2A
; D916 gb_72
; D917 gb_B8
; D91B gb_D7
; D927 gb_73
; D940 gb_B2
; D945 gb_B7
; D94E gb_B3
; D951 gb_74
; D971 gj_31
; D97C gb_B9
; D986 gb_D9
; D987 gj_05
; D999 gb_B5
; D99D gb_B4
; D9A2 gb_B6
; D9B7 gb_D6
; D9C5 gb_D5
; D9CB add_b_cur_ecs
; D9DA gj_44
; D9E3 gb_F5
; D9E8 gb_4C
; D9EE to_lampm_a
; D9F1 gj_0C
; D9F2 gb_7D
; D9FB gb_7A
; D9FC gb_2D
; DA0C gb_80
; DA10 gj_32
; DA19 gb_7C
; DA25 gb_7F
; DA36 gb_7B
; DA38 gb_BE
; DA3C gj_3F
; DA45 gb_BB
; DA51 gb_BD
; DA62 gj_41
; DA7E gb_2F
; DA83 gb_2E
; DA86 gj_3C
; DA87 gb_7E
; DA8F gb_C0
; DAAE gj_3B
; DAAF gb_BC
; DAB7 gb_DA
; DAD4 gb_C1
; DADF gb_DB
; DAE1 gb_F7
; DAEC gb_BF
; DAEE gb_8C
; DAEF gb_F6
; DB00 gb_102
; DB06 gj_1A
; DB12 gj_19
; DB1D gj_34
; DB28 gb_89
; DB38 gb_CA
; DB54 gb_CB
; DB57 gb_DD
; DB59 gj_40
; DB68 gb_DC
; DB7D gj_15
; DB85 gb_81
; DB88 show_eunit_bonus
; DBB2 gb_56
; DBC6 gb_57
; DBDA gb_58
; DBE5 start_baiter
; DBEC gb_31
; DBF7 gb_30
; DBF9 gb_32
; DBFC gb_33
; DC15 gb_34
; DC2A gb_37
; DC32 gb_36
; DC5A gb_35
; DC69 gb_84
; DC6F gb_86
; DC76 gb_85
; DC84 gj_17
; DC98 gb_8B
; DCA6 gb_38
; DCBC gb_87
; DCBD gj_33
; DCD4 gb_C3
; DCF2 gb_C4
; DD01 gb_DE
; DD04 gb_C2
; DD0F gb_8A
; DD14 gb_E1
; DD17 gj_16
; DD19 gb_83
; DD20 gb_82
; DD23 gj_18
; DD32 gb_88
; DD48 gb_C5
; DD51 gb_C6
; DD5A gb_C8
; DD5D gb_DF
; DD5E gb_C7
; DD5F gb_C9
; DD6D gb_E0
; DD76 gj_27
; DD84 gb_3B
; DD87 gb_3A
; DD89 gb_39
; DD9B sw_z_bomb
; DDB0 gj_46
; DDB3 gb_3C
; DDBF gb_59
; DDC0 gb_09
; DDD0 gb_9D
; DDDE gb_5A
; DDEC gj_2A
; DDFD gb_5B
; DE0E gb_9E
; DE1B gb_D1
; DE26 gb_E9
; DE36 gj_13
; DE38 gj_43
; DE3F gb_70
; DE40 zbomb_ani
; DE43 gb_EA
; DE5F lmpanirts
; DE60 zbomb_ani2
; DE63 gb_101
; DE7A zbomb_ani3
; DE7D gb_ED
; DE80 gb_EB
; DE98 gb_EC
; DEA7 gameover_entry
; DEC4 gb_5C
; DEEE gj_09
; DEF4 gj_39
; DF0E ani_msg_starslide
; DF11 ani_starslide
; DF19 gb_50
; DF29 gb_51
; DF38 gb_4F
; DF3C gb_97
; DF51 gj_37
; DF58 gb_98
; DF5B gj_1E
; DF64 gj_07
; DF6C gb_3D
; DF6F gj_36
; DF74 gj_28
; DF79 gb_8D
; DF7C gb_3F
; DF96 gb_3E
; DF99 gb_8E
; DFB0 gj_1C
; DFBD gb_40
; DFCC gj_48
; DFD2 gj_2F
; DFE5 gb_AC
; DFF0 reflex_thread
; E00A reflex_lp
; E03E gb_EF
; E04F gb_F0
; E05A to_next_wave
; E069 gb_EE
; E06C gb_41
; E070 gj_1D
; E081 gb_42
; E08D gb_43
; E0A2 gb_8F
; E0AD gb_CE
; E0B1 gj_38
; E0C7 gb_E4
; E0D0 gb_E2
; E10A gb_E5
; E10F gb_E3
; E11C gb_F9
; E134 gb_FC
; E137 gj_47
; E142 gb_FA
; E14C gb_103
; E152 gb_FB
; E153 gb_F8
; E165 gb_44
; E16E gb_90
; E170 gj_1F
; E172 hook_coin
; E189 highscoresound
; E195 gb_45
; E1F2 gb_48
; E1F6 gb_47
; E208 gb_46
; E210 gb_96
; E216 gb_95
; E228 gj_22
; E232 gb_E8
; E242 gb_94
; E24D gb_D0
; E256 gb_CF
; E269 gb_E7
; E270 gb_E6
; E27B gb_100
; E27D gb_FF
; E293 gb_FD
; E295 gb_105
; E2AA gb_FE
; E2B1 gb_109
; E2B3 gb_106
; E2B9 gb_107
; E2C2 gb_10D
; E2C4 gb_108
; E2C7 gb_104
; E2CE gb_10A
; E2D2 gb_10C
; E2D4 gb_10B
; E2DF gj_42
; E2E7 gj_2B
; E2FB gb_9F
; E334 gj_01
; E340 gb_49
; E351 gb_4A
; E353 gj_24
; E358 gj_23
; E359 gj_25
; E35E gb_4B
; E471 gj_12
; E473 gj_02
; E47D gj_1B
; E494 gj_2D
; E4A2 gj_3A
; E4A6 gj_3E
; E4B4 gj_26
; E4CB character_defs
; E529 msg_williams
; E532 msg_electronics
; E53E msg_presents
; E547 msg_hyperball
; E551 msg_credit
; E558 msg_player
; E55F msg_game
; E565 msg_over
; E56B msg_critical
; E574 msg_wave
; E579 msg_completed
; E583 msg_spell
; E58D msg_bonus
; E593 msg_energy
; E59A msg_youmissed
; E5A5 msg_reflex
; E5AC msg_hit
; E5B0 msg_3eu
; E5B6 msg_3zb
; E5BC msg_zeros
; E5C2 msg_hyper
; E5C8 msg_enuit
; E5D0 msg_ssr_ejs
; E5DD msg_cannon
; E5E4 msg_alien
; E5EA msg_laser
; E5F0 msg_ray
; E5F4 msg_tilt
; E5FD msg_great_reflex
; E60A msg_enter_your
; E615 msg_initials
; E61E msg_great_score
; E62A msg_hy_score
; E632 lmp_ani_inout-1
; E633 lmp_ani_inout
; E681 lmp_ani_outin-1
; E682 lmp_ani_outin
; E6D2 disp_wave_num
; E6D4 gj_2C
; E6E5 gb_9C
; E6E8 gj_21
; E730 sw_slam
