;--------------------------------------------------------------
;Hyperball Game ROM L-4
;Dumped by Hydasm ©2000-2013 Jess M. Askey
;--------------------------------------------------------------
#define HYPERBALL

#include  "../../68logic.asm"	;680X logic structure definitions   
#include  "../../7gen.asm"	;Level 7 helper macros    
#include  "hy_wvm.asm"		;Virtual Machine Instruction Definitions                           
#include  "hy_hard.asm"		;Hardware Definitions                


	.msfirst	
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
gr_highscore_ptr		.dw high_score

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
gr_eb_event			rts\ .db $00	;(Extra Ball Event)
gr_special_event		bra special_event	;(Special Event)
gr_macro_event		rts\ .db $00	;(Start Macro Event)
gr_ballstart_event	rts\ .db $00	;(Ball Start Event)
gr_addplayer_event	rts\ .db $00	;(Add Player Event)
gr_gameover_event		rts\ .db $00	;(Game Over Event)
gr_hstdtoggle_event	rts\ .db $00	;(HSTD Toggle Event)

gr_reset_ptr		.dw hook_reset		;Reset
gr_mainloop_ptr		.dw gr_macro_event	;Main Loop Begin
gr_coin_ptr			.dw hook_coin		;Coin Accepted
gr_gamestart_ptr		.dw hook_gamestart	;New Game Start
gr_playerinit_ptr		.dw hook_playerinit	;Init New Player
gr_outhole_ptr		.dw hook_outhole		;Outhole

;------------------------ end system data ---------------------------

;******************************************
;* Nothing special to do in Hyperball for
;* the IRQ, just go to system
;******************************************
gr_irq_entry	jmp	sys_irq_entry

;******************************************
;* SWI - This is a cheap way to start 
;* macros in order to save some ROM space
;******************************************
gr_swi_entry	cli	
			ins	
			ins	
			ins	
			ins	
			ins	
			jmp	macro_start

;******************************************
;* This is called when a player score 
;* reaches the Energy Center Award Level 
;* in the adjustments.
;******************************************
special_event	ldx	#adj_ec_award_level
			jsr	cmosinc_b
			beq	gr_hstdtoggle_event
			ldx	credit_x_temp
			dex	
			dex	
			jsr	cmos_a
			aba	
			daa	
			bsr	to_cmosa
			ldaa	#$12
			jsr	isnd_once
			ldab	#$01
			jsr	add_b_cur_ecs
			ldx	#p2_ec_b0
			ldaa	player_up
			ifne
				ldx	#p1_ec_b0
			endif
			ldaa	#$01
			jmp	add_a_to_ecd

;*************************************************
;* Reset Hook from system - by default, the HSTD
;* is reset on power-on. 
;*************************************************
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
			begin
				clr	$00,X
				inx	
				cpx	#hy_unknown_8
			eqend
			ldx	#adj_ec_award_level
			ldaa	#$F3
			jsr	solbuf			;turn on ball feed motor and ball shooter
			jsr	jmp_cmosa
			ldx	#aud_game7
			bsr	to_cmosa
to_cmosa		jmp	a_cmosinc

;****************************************************
;* Game Start - sets appropriate startup, A will have
;* 01 for 1 player game, and 02 for 2 player game.
;****************************************************
sw_1p_start		clra	
sw_2p_start		inca	
			ldab	flag_gameover		;Is game over? 1 = gameover
			ifne						;this is an extended game
				staa	spell_award			;this is a double use of the memory location, really has nothing to do with spell award		
				tab	
				ldx	#adj_max_credits		;free play?
				bsr	jmp_cmosa
				ifne					;no, check for actual credits
					ldx	#aud_currentcredits
					bsr	jmp_cmosa
					cba	
					bcs	to_kill		;not enough, kill
				endif
				begin
					ldaa	#$08
					ldx	#credit_button
					jsr	newthreadp
					decb	
				eqend
				ldx	#$0303
				stx	p1_ecs
				bsr	get_aud_ec_ex
				beq	to_kill
				swi	
				PRI_($48)				;Priority=#48
gs_forever			SLEEP_(5)
				JMPR_(gs_forever)			;just stay here, something will have to kill it?
			endif
			;here for a fresh game start
			cmpa	spell_award
			bne	to_kill			;kill if SPELL already active, which means that there is already a game playing
			ldaa	#$48
			ldab	#$FF
			jsr	check_threadid
			bcs	to_kill2			
			jsr	killthreads_ff		;If there was an extended game playing already, now just kill the marker thread
			ldab	spell_award
			ldx	#adj_max_credits
			bsr	jmp_cmosa			;check for free play
			ifne
				ldaa	current_credits
				cba	
				bcs	to_kill2			;exit on not enough
			endif
			cmpb	#$02
			ifeq					;2P game is already going, extend it
				bsr	extend_game
				ldab	p2_ecs
				psha	
				aba	
				staa	p2_ecs
				pula	
				ldx	#p1_ec_b0
				bsr	add_a_to_ecd		;update EC numbers for P1
			endif
			bsr	extend_game			;here for 1P game already in progress
			ldab	p1_ecs
			psha	
			aba	
			staa	p1_ecs
			pula	
			ldx	#p2_ec_b0
			bsr	add_a_to_ecd
			bra	to_kill2

jmp_cmosa		jmp	cmos_a

;Remove a credit and get the extended EC value
extend_game		ldx	#aud_currentcredits
			bsr	jmp_cmosa
			jsr	lesscredit
get_aud_ec_ex	ldx	#adj_energyextended
			bsr	jmp_cmosa
			anda	#$0F
			rts	

;Adds A to the number of EC's currently in X
add_a_to_ecd	ldab	$00,X
			ifmi
				andb	#$0F
			endif
			aba	
			daa	
			cmpa	#$09
			ifle
				oraa	#$F0
			endif
			staa	$00,X
			rts	

;*****************************************************
;* Animations for GAME OVER text, each slide in from
;* the Left and Right edges respectively.
;*****************************************************
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
			
;*****************************************************
;* Outhole in Hyperball is when the players Energy
;* Centers are gone;
;*****************************************************
hook_outhole	ldaa	#$78
			bsr	killthreads_ff			;kill any game running threads
			ldaa	random_bool
			ifeq						;Randomly give 50 points... why exactly? We may never know.
				ldaa	#$29
				jsr	score_main			;50 points
			endif
			inc	flag_tilt				;turn off the shooters 
			ldab	p2_ec_b0
			ldaa	player_up
			ifne
				ldab	p1_ec_b0
			endif
			cmpb	#$F0
			bne	goto_sme
			ldx	#msg_player
			jsr	copy_msg_full
			adda	#$1C
			ldx	temp1
			staa	$02,X
			ldaa	num_players
			ifne
				SLEEP($60)
			endif
			ldx	#ani_game_lr
			jsr	newthread_06
			ldx	#ani_over_rl
			jsr	newthread_06
			bsr	goto_sme
			ldaa	#$09
			jsr	isnd_once
			SLEEP($F0)
goto_sme		jmp	setup_msg_endptr

slide_r		ldaa	$00,X
			anda	#$0F
			jsr	xplusa
			begin
				ldab	$00,X
				dex	
gb_0D				bsr	step_r
			eqend
			rts	

slide_l		ldaa	$00,X
			anda	#$0F
			begin
				inx	
				ldab	$00,X
gb_0F				bsr	step_l
			eqend
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
			begin
				tba	
				ldab	$00,X
				staa	$00,X
				inx	
				cpx	game_var_3
			eqend
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
			ifeq
				ldaa	#$09
			endif
			staa	thread_timer_byte
			pula	
			jsr	delaythread
			deca	
			rts	

gb_0E			stx	game_var_4
			ldx	#p2_ec_b1
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

ani_spinner		psha	
			pshb	
			begin
				ldaa	#$26
				decb	
				beq	pulab_rts
spin_rpt				staa	$00,X
				SLEEP($02)
				inca	
				cmpa	#$2A
			neend
			bra	spin_rpt
;**************************************************
;* Message Copy - Either copies the full message 
;* into the the alpha buffer or copies a partial
;* message into the buffer for more complex 
;* rendering
;**************************************************
copy_msg_full	bsr	setup_msg_endptr
copy_msg_part	ldab	$00,X
			andb	#$0F
			inx	
			jmp	copyblock

ani_msg_letters	bsr	setup_msg_endptr
			ldaa	$00,X
			anda	#$0F
			begin
				ldab	#$0B
				psha	
				inx	
				stx	game_var_1
				ldaa	$00,X
				staa	alpha_b0+11
				ldx	#alpha_b0+10
				begin
					SLEEP($04)
					ldaa	$01,X
					staa	$00,X
					clra	
					staa	$01,X
					dex	
					decb	
					cmpb	game_var_0
				eqend
				ldx	game_var_1
				inc	game_var_0
				pula	
				deca	
			eqend
			rts	

gj_0D			jsr	update_commas
clr_alpha_set_b0			clrb	
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
			SOL_(GI_PF_ON4)			; Sol#6:gi_relay_pf
tilt_kill		KILL_					;Remove This Thread

tilt_sleeper	swi	
			PRI_($C0)				;Priority=#C0
			SLEEP_(24)
			KILL_					;Remove This Thread

game_tilt		SOL_(GI_PF_ON)			; Sol#6:gi_relay_pf
			PRI_($A0)				;Priority=#A0
			REMTHREADS_($08,$00)		;Remove Multiple Threads Based on Priority
			JSRR_(gj_06)			
			CPUX_					;Resume CPU Execution
			ldx	#msg_tilt
			bsr	copy_msg_full
			bsr	clr_alpha_set_b1
			ldaa	#$31
			begin
				jsr	invert_alphamsk
				SLEEP($06)
				deca	
			eqend
			ldx	#0000
			stx	cur_spell_pos
			swi	
			JSRDR_(setup_msg_endptr)
			JSRDR_(stab_all_alphmsk)
			RAMCPY_($6,$0)			;Copy RAM;RAM,6 = RAM,0
end_player		SOL_(GI_PF_OFF,ENERGY_FL_OFF,P1_FL_OFF,P2_FL_OFF)		
			PRI_($00)				;Priority=#00
			JSRDR_(save_spell)		
			JSRD_(update_commas)		
			JMPD_(outhole_main)
		
hook_playerinit	inc	flag_tilt			;turn off the shooters 
			ldx	#msg_player
			jsr	copy_msg_full
			ldx	current_thread
			stab	$0D,X
			ldaa	player_up
			adda	#$1C
			ldx	temp1
			staa	$02,X
			jsr	clr_alpha_set_b1
			jsr	ani_starslide
plyer_load		ldx	#ec_animate
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
			SOL_(GI_PF_OFF)			; Sol#6:gi_relay_pf
			BITFLP_($00)			;Flash Lamp/Bit @RAM:00
			SETRAM_($01,$10)			;RAM$01=$10
gb_12			SND_($07)				;Sound #07
			SLEEP_(10)
			ADDRAM_($01,$FF)			;RAM$01+=$FF
			.db $5B,$FC,$E1,$00,$F7		;BNE_RAM$01==#0 to gb_12
			BITONP_($00)			;Turn ON Lamp/Bit @RAM:00
			BITOFF4_($30)			;Turn OFF: Lamp#30(lamp_p1)
			JSRDR_(setup_msg_endptr)
			SOL_(BALL_LIFT_ON)		; Sol#9:ball_lift
			SLEEP_(64)
			REMTHREADS_($FF,$48)		;Remove Multiple Threads Based on Priority
			CPUX_					;Resume CPU Execution
			clra	
			staa	flag_tilt			;turn ON the shooters 
			staa	game_ram_a
			ldx	#adj_reflex_diff
			jsr	cmosinc_b
			ldaa	#$11
			andb	#$0F
			ifne
				begin
					deca	
					decb	
				eqend
				cmpa	#$04
				ifle	
					ldaa	#$04
				endif
			endif
			staa	game_ram_c			;saves the default reflex wave difficulty min=4 max=11
			ldaa	current_wave		;get the current wave
			ldab	cur_bolt_cnt			;are we done?
			ifeq
				adda	#$01				;yes, advance wave
				daa	
				staa	current_wave
				psha	
				ldab	#$0F
				stab	baiter_speed
				ldab	#$04
				ldx	#adj_baiter_speed
				jsr	cmosinc_a
				anda	#$0F
				ifne
gb_66					dec	baiter_speed
					cmpb	baiter_speed
					ifne
						deca	
						bne	gb_66
					endif
				endif
				ldab	current_wave
				jsr	dec2hex
				ldaa	baiter_speed
gb_68				cmpa	#$04
				beq	gb_67
				deca	
				decb	
				bne	gb_68
gb_67				staa	baiter_speed
				pula	
			endif
			begin
				clrb	
				psha	
				ldaa	game_ram_c
				deca	
				cmpa	#$03
				ifgte
					staa	game_ram_c
				endif
				pula	
gb_6B				adda	#$99
				daa	
				beq	gb_6A
				incb	
				cmpb	#$05
			neend
			bra	gb_6B

gb_6A			ldaa	current_wave
			cmpb	#$04
			ifne
				tst	cur_bolt_cnt			;is bolt count at zero? 
				ifeq
					ldx	#wave_bolt_cnt		;load the bolt count for this level
					jsr	xplusb_ldb
					cmpa	#$09
					ifgte
						ldab	#$20				;after level 9, waves always have 32 bolts
					endif
					stab	cur_bolt_cnt
				endif
				ldaa	game_ram_4
				ifeq
					ldaa	#$14
					staa	game_ram_4
				endif
				ldx	#adj_bolt_speed
				jsr	cmosinc_b
				cmpb	#$20
				ifgt
					ldab	#$20
				endif
				jsr	dec2hex
				tba	
				ldab	current_wave
				jsr	dec2hex
				cmpb	#$01
				ifne
					aslb	
				endif
				sba	
				bcs	gb_A7
				cmpa	#$06
				iflt
gb_A7					ldaa	#$06
				endif
				staa	game_ram_9
				ldx	#bolt_launcher
				bsr	to_addthr_noa
				ldx	#gb_3A
				bsr	to_addthr_noa
				jsr	get_random
				ldab	#$06
				cmpa	#$25
				iflo
					ldab	#$04
					ldx	#gj_3B
					bsr	to_addthr_noa
					ldx	#gj_3C
					bsr	to_addthr_noa
				endif
				stab	game_ram_8
				ldx	#load_spell
				bsr	to_addthr_noa
				ldx	#start_rndawd
				bsr	to_addthr_noa
				ldx	#start_baiter
to_addthr_noa		bra	addthread_clra
			endif
			
start_reflex	ldaa	#$2E
			jsr	lamp_on_f
			ldaa	#$10
			staa	reflx_cur_pts
			ldx	#reflex_thread
addthread_clra	clra	
newthreadp		staa	thread_priority
			jmp	newthread_sp

bolt_launcher	SLEEP($03)
			begin
				ldaa	game_ram_8
				beq	bolt_launcher
				ldx	#gj_0C
				bsr	addthread_clra
				ldx	#adj_bolt_feed
				jsr	cmosinc_a
				anda	#$0F
				ldab	current_wave
				cmpb	#$09
				ifgt
					ldab	#$09
				endif
				sba	
				ifcs
					clra	
				endif
				adda	#$0B
				begin
					ldab	game_ram_9
					cmpb	#$0C
					ifgt
						lsrb
					endif	
					stab	thread_timer_byte
					jsr	delaythread
					deca	
				eqend
			loopend

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
			jsr	copy_msg_full
			SETRAM_($00,$14)			;RAM$00=$14
gb_19			JSRDR_(invert_alphamsk)	
			SND_($11)				;Sound #11
			SOL_(GI_PF_ON)				
			SLEEP_(8)
			SOL_(GI_PF_OFF)				; Sol#6:gi_relay_pf
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
			ldx	#hy_unknown_8
			bsr	random_x03
			ifne
				deca
			endif	
			staa	hy_unknown_6
			ifeq
				ldaa	game_ram_4
				jsr	show_thousands
			else
				clr	$01,X
				ldab	#$1C
				stab	$02,X
				ldab	#$26
				stab	$03,X
				cmpa	#$02
				ifne
					ldaa	#$5A
					ldab	#$42
				else
					ldaa	#$45
					ldab	#$55
				endif
				staa	$04,X
				stab	$05,X
			endif
			ldaa	#$05
			staa	$00,X
			jsr	ani_msg_rlslide
			staa	game_ram_a
			ldx	current_thread
			ldaa	#$A4
			staa	$0D,X
			ldaa	#$02
			begin
				SLEEP($C0)
				deca	
			eqend
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
			SOL_(ENERGY_FL_ON,P1_FL_ON,P2_FL_ON)			
			SLEEP_(4)
			SOL_(ENERGY_FL_OFF,P1_FL_OFF,P2_FL_OFF)			
			KILL_					;Remove This Thread

gj_35			psha	
			ldx	#gj_10
			jsr	addthread_clra
			ldaa	game_ram_6
			adda	#$99
			daa	
			staa	game_ram_6
			cmpa	#$01
			ifeq
				ldx	#gj_11
				jsr	addthread_clra
			endif
			pula	
			rts	

get_rnd_lampnum	ldx	#gj_12
			jsr	xplusa
			ldaa	$00,X
			rts	

check_neighbors	psha	
			pshb	
			deca	
			jsr	bit_lamp_buf_f
			ifne
				ldaa	#$01
			else
				inca	
				inca	
				jsr	bit_lamp_buf_f
				beq	sw_rts
				ldaa	#$02
			endif
			staa	hy_unknown_4
sw_rts		pulb	
			pula	
			rts	

sw_checks		psha	
			pshb	
			tab	
			adda	#$41
			bsr	check_neighbors
			jsr	lamp_off_f
			subb	#$08
			ldx	#sw_to_lamp_map		;get the lamp number associated with this switch
			jsr	xplusb_ldb			;put it into B
			stab	last_sw_lamp
			ldx	cur_spell_ltr		;Is the user 'spelling'?
			beq	sw_rts			;no, return
			cmpb	$00,X				;Is this the correct letter for 'spell'?
			bne	sw_rts			;no, return
			inx	
			stx	cur_spell_ltr		;move to next letter
			lsr	cur_spell_pos
			bra	sw_rts

gj_06			BITON4_($30)			;Turn ON: Lamp#30(lamp_p1)
			RCLR0_($CF,$4D)			;Effect: Range #CF Range #4D
			RCLR1_($C0,$00)			;Effect: Range #C0 Range #00
			SETRAM_($0A,$00)			;RAM$0A=$00
			JSRD_(clr_dis_masks)		
			JSRDR_(gj_0D)		
			EXE_($0A)				;CPU Execute Next 10 Bytes
			inc	flag_tilt			;turn OFF the shooters 
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
sw_P			JSRDR_(sw_checks)		
			EXE_
				suba	#$12
			EXEEND_
			.db $5B,$D0,$E0,$42		;BNE_BIT2#E0 to s_kill
			BITOFF4a_($00)			;Turn OFF: Lamp#00(lamp_h1)
			EXE_
				ldab	#$21
				stab	thread_priority
				ldx	#gj_27
				jsr	newthread_sp
			EXEEND_
			POINTS_(1,1000)			;1000 Points
			SND_($08)				;Sound #08
			;Fall through to sw_common
			
sw_common		ADDRAM_($03,$FF)			;RAM$03+=$FF
chk_wave_compl	.db $5A,$FB,$FB,$F3,$FC,$E3,$00,$D0,$2E,$D0,$2F,$24;BEQ_(BIT2#2F || (BIT2#2E || (!RAM$03==#0))) to s_kill
			REMTHREADS_($08,$00)		;Remove Multiple Threads Based on Priority
			SND_($05)				;Sound #05
			JSRDR_(save_spell)		
			JSRR_(gj_06)			
			JSRD_(waveend_ux)			
			JSRDR_(show_wave_compl)	
			JSRDR_(show_eunit_bonus)
			;fall through to wave setup procedures
			
setup_next_wave	REMTHREADS_($08,$00)		;Remove Multiple Threads Based on Priority
			EXE_				
				ldab	player_up
				jsr	resetplayerdata
			EXEEND_
			EXE_
				staa	flag_timer_bip
				ldx	#player_ready
				jsr	newthreadp
			EXEEND_
			JSRD_(plyer_load)			
s_kill		KILL_					;Remove This Thread

show_wave_compl	ldx	#msg_wave
			jsr	copy_msg_full
			jsr	disp_wave_num
			bsr	sleep45
			ldx	#msg_completed
			jsr	copy_msg_full
sleep45		SLEEP($45)
			rts	

sw_T			JSRDR_(sw_checks)		
			.db $5B,$F4,$43,$2E		;BNE_LampOn/Flash#43 to gb_08
			RCLR0_($11)				;Effect: Range #11
			JMPR_(gj_04)
			
sw_E			JSRDR_(sw_checks)		
			.db $5B,$F4,$3A,$24		;BNE_LampOn/Flash#3A to gb_08
			RCLR0_($10)				;Effect: Range #10
			JMPR_(gj_04)
			
sw_F			ldab	#$3D
			bra	ssw_handler

sw_G			ldab	#$3E
ssw_handler		swi	
			JSRDR_(sw_checks)		
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

gj_48			swi	
gj_14			.db $5A,$FE,$F2,$F6,$A4,$18	;BEQ_(BIT#64 P #F6) to gb_25
			SLEEP_(2)
			JMPR_(gj_14)
			
gb_24			EXE_($03)				;CPU Execute Next 3 Bytes
			ldaa	last_sw_lamp
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
			ifne
				rora	
				ifcs
					jsr	add_b_cur_ecs
					bra	gb_B1
				endif
				jsr	add_b_cur_zb
			else
				ldx	#alpha_b0+6
				bsr	gb_D3
			endif
gb_B1			jsr	gj_0D
			ldab	#$10
			ldaa	#$01
			jsr	isnd_once
			begin
				ldaa	dmask_p4
				coma	
				anda	#$3F
				staa	dmask_p4
				SLEEP($05)
				decb	
			eqend
			stab	dmask_p4
			jmp	sumthin

gb_D3			ldab	$01,X
			andb	#$3F
			subb	#$1B
			ifne
				ldaa	#$0B
				begin
					jsr	score_main			;1,000 points
					decb	
				eqend
			endif
			ldab	$00,X
			ifne
				subb	#$1B
				ldaa	#$0C
				begin
					jsr	score_main			;10,000 points
					decb	
				eqend
			endif
			rts	

invert_alphamsk	ldab	dmask_p3
			comb	
			andb	#$7F
stab_all_alphmsk	stab	dmask_p3
			stab	dmask_p4
			rts	

gb_79			psha	
gb_27			jsr	random_x03
			SLEEP(1)
			ifne
				cmpa	#$03
				beq	gb_27
				cmpa	#$02
				ifeq
					ldaa	#$0A
					jsr	lfill_a
					ifcc
						ldaa	#$02
					else
						clra	
					endif
				endif
			endif
			staa	spell_award
			pula	
			rts	

gb_29			ldx	current_thread
			clr	$0D,X
			rts	

load_spell		bsr	gb_29
			ldx	#vm_reg_a
			stx	cur_spell_ltr
			bsr	gb_2A
			ldaa	$00,X
			staa	spell_award
			ldx	$01,X
			stx	cur_spell_pos
			ifeq
				swi	
gb_2C				SLEEP_(64)
				.db $5A,$FE,$F2,$F0,$A0,$F8	;BEQ_(BIT#60 P #F0) to gb_2C
				PRI_($A0)				;Priority=#A0
				CPUX_					;Resume CPU Execution
				ldx	#msg_spell
				jsr	copy_msg_full
				jsr	clr_alpha_set_b1
				ldaa	#$10
				begin
					bsr	invert_alphamsk
					SLEEP($08)
					deca	
				eqend
				jsr	random_x07
				ifeq
					inca	
				endif
				bsr	gb_79
				deca	
				staa	cur_spell_word
				ldaa	#$20
				staa	cur_spell_pos
			endif
			begin
				jsr	gj_31
			csend
			jsr	clr_alpha_set_b1
			bsr	start_spell
			ldx	#dynamic_disp_buf
			stx	temp1
			ldaa	cur_spell_pos
			beq	award_spell
			begin
				bita	#$20
				bne	gb_75
				asla	
				beq	award_spell
				inx	
			loopend

gb_75			stx	cur_spell_ltr
			jsr	clr_next_12
			bsr	gb_B7
			bsr	gb_29
gb_D8			ldaa	#$7F
			staa	dmask_p3
			begin
				anda	#$7F
				staa	dmask_p4
				bsr	gj_31
				bcc	gb_B8
				bsr	gb_B9
				beq	award_spell
				coma	
				oraa	dmask_p4
				eora	cur_spell_pos
			loopend

gb_2A			ldx	#hy_unknown_7
			ldab	player_up
			ifne
				inx	
				inx	
				inx	
			endif
			rts	

gb_B8			clrb	
			jsr	stab_all_alphmsk
			begin
				bsr	gb_B9
				beq	award_spell
				bsr	gj_31
			csend
			bsr	start_spell
			bra	gb_D8

;**************************************************
;* Starts SPELL sequence, assigns random word, sets
;* vars
;**************************************************
start_spell		jsr	setup_msg_endptr
			ldx	#alpha_b1
			stx	temp1
			ldx	#msg_zeros
			ldaa	spell_award				;get current spell award: ;00=points, 01=ZB , 10=EU  
			ifne
				ldx	#msg_3zb
				rora	
				ifcc
					ldx	#msg_3eu
				endif
			endif
			bsr	gb_B3
			inc	temp1+1
gb_B7			ldx	#random_words
			ldaa	cur_spell_word
			jsr	gettabledata_b
gb_B3			jmp	copy_msg_part

award_spell		ldx	#0000
			stx	cur_spell_ltr
			stx	cur_spell_pos
			bsr	save_spell
			ldx	#dynamic_disp_buf
			jsr	clr_next_12
			ldab	#$03
			ldaa	spell_award
			beq	spell_awd_pts					;Branch if SPELL not active
			cmpa	#$02
			beq	spell_awd_zb					;Branch for Energy Units award
			bsr	add_b_cur_ecs
			bra	spell_awd_com

gj_31			SLEEP($05)
			ldaa	#$A0
			ldab	#$F0
			jmp	check_threadid

gb_B9			ldx	cur_spell_ltr
			ldaa	$00,X
			ifne
				ldaa	cur_spell_pos
			endif
			rts	

save_spell		bsr	gb_2A
			ldaa	spell_award				;Store current award
			staa	$00,X
			ldaa	cur_spell_pos
			staa	$01,X
			ldaa	cur_spell_word
			staa	$02,X
			rts	

spell_awd_zb	bsr	add_b_cur_zb
			bra	spell_awd_com
spell_awd_pts	ldaa	#$4C
			jsr	score_main				;90,000 points
spell_awd_com	ldaa	#$06
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
			SLEEP($05)
			deca	
			bne	gb_D6
gb_D5			jsr	gj_0D
			jmp	load_spell

add_b_cur_ecs	pshb	
			jsr	get_current_ecs
			tba	
			pulb	
			aba	
			staa	$00,X
			ldaa	player_up
			adda	#$0B
			bra	gb_4C
			
add_b_cur_zb	ldaa	game_ram_6
			aba	
			cmpa	#$05
			ifgt
				ldaa	#$05
			endif
			staa	game_ram_6
			ldaa	#$0A
			aslb	
gb_4C			begin
				bsr	to_lampm_a
				decb	
			eqend
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
gj_3E			BITONP_($01)			;Turn ON Lamp/Bit @RAM:01
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
			JMPR_(gj_3E)
			
gj_40			pshb	
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


gb_7E			JSRR_(gj_3F)			
			.db $5A,$D0,$2F,$5F		;BEQ_BIT2#2F to gb_BF
			SETRAM_($00,$00)			;RAM$00=$00
gb_C0			ADDRAM_($00,$01)			;RAM$00+=$01
			.db $5A,$FA,$D0,$E0,$F3,$FC,$E0,$E1,$F5;BEQ_((!RAM$00==#225) && BIT2#E0) to gb_C0
			.db $5A,$FE,$F2,$F0,$30,$4C	;BEQ_(BIT#FFFFFFF0 P #F0) to gb_BF
			JSRDR_(gj_40)		
			.db $5A,$FC,$E0,$00,$45		;BEQ_RAM$00==#0 to gb_BF
			.db $5A,$FC,$E0,$E1,$28		;BEQ_RAM$00==#225 to gb_C1
			JMPR_(gb_C0)
			
gj_3B			.db $3F


gb_BC			JSRR_(gj_3F)			
			.db $5A,$D0,$2F,$37		;BEQ_BIT2#2F to gb_BF
			SETRAM_($00,$0A)			;RAM$00=$0A
gb_DA			ADDRAM_($00,$FF)			;RAM$00+=$FF
			.db $5A,$FA,$D0,$E0,$F3,$FC,$E0,$E1,$F5;BEQ_((!RAM$00==#225) && BIT2#E0) to gb_DA
			.db $5A,$FE,$F2,$F0,$30,$24	;BEQ_(BIT#FFFFFFF0 P #F0) to gb_BF
			JSRDR_(gj_40)		
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
			SOL_(GI_PF_ON)				
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
			SOL_(HYPER_FL_ON4,ENERGY_FL_ON4,P1_FL_ON4,P2_FL_ON4)		; Sol#0:hyper_flash Sol#1:energy_flash Sol#2:p1_flash Sol#7:p2_flash
gb_CA			RROL0_($81,$82,$83,$84,$85,$86,$87,$88,$09);Effect: Range #81 Range #82 Range #83 Range #84 Range #85 Range #86 Range #87 Range #88 Range #09
			SLEEP_(7)
			.db $5B,$00,$E2			;BNE_LAMP#00(lamp_h1) to gb_89
			BITON_($BE,$BD,$C6,$47)		;Turn ON: Lamp#3E(lamp_g), Lamp#3D(lamp_f), Bit#06, Bit#07
			EXE_($06)				;CPU Execute Next 6 Bytes
			ldx	#gj_45
			jsr	newthread_06
			JMPR_(gb_89)
			
gb_CB			SETRAM_($06,$00)			;RAM$06=$00
			JMP_(end_player)				


gj_3F			SLEEP_(1)
			.db $5A,$FE,$F2,$F1,$21,$F9	;BEQ_(LAMP#21(lamp_m4) P #F1) to gj_3F
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
			ifgt
				lsra
			endif	
			inca	
			tab	
			rts	

show_eunit_bonus	jsr	setup_msg_endptr
			ldx	#alpha_b0
			stx	temp1
			ldx	#msg_enuit
			jsr	copy_msg_part
			ldx	#msg_bonus
			jsr	copy_msg_part
			SLEEP($25)
			jsr	setup_msg_endptr
			ldab	game_ram_6
			ldx	#alpha_b0+1
			jsr	split_ab
			tstb	
			ifne
				addb	#$1B
				stab	$00,X
			endif
			ldab	game_ram_6
			andb	#$0F
			addb	#$1B
			stab	$01,X
			ldaa	#$18
			staa	$03,X
			ldaa	current_wave
			cmpa	#$09
			ifge
				ldaa	#$09
			endif
			tab	
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
			begin
				jsr	score_main			;x 1,000 points
				decb	
			eqend
			SLEEP($25)
			rts	

start_baiter	ldab	current_wave
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
			adda	cur_bolt_cnt
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
			staa	reflx_cur_hits
			pulb	
			pula	
			ifne
				psha	
				ldaa	hy_unknown_1
				cmpa	#$03
				pula	
				ifle
					begin
						psha	
						ldaa	#$30
						staa	thread_priority
						pula	
						ldx	#gj_33
						jsr	newthread_sp
						swi	
						SND_($1D)				;Sound #1D
gb_38						SLEEP_(10)
						.db $5A,$FE,$F2,$FF,$30,$F9	;BEQ_(BIT#FFFFFFF0 P #FF) to gb_38
						CPUX_					;Resume CPU Execution
						bsr	gb_8A
						beq	gb_87
						tst	hy_unknown_4
						bne	gb_87
						dec	reflx_cur_hits
					eqend
				endif
			endif
gb_87			rts	

gj_33			staa	reflx_tmr_btr
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
			begin
				SLEEP($08)
				psha	
				pshb	
				ldaa	reflx_tmr_btr
				jsr	bit_lamp_buf_f
				pulb	
				pula	
				beq	gb_C2
				jsr	lampm_e
				incb	
				cmpb	#$05
			geend
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
			jsr	score_main			;1,000 points
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
			begin
				decb	
				beq	gb_82
				adda	#$06
			loopend
gb_82			tab	
			pula	
			rts	

gj_18			psha	
			ldaa	hy_unknown_1
			inca	
			staa	hy_unknown_1
			cmpa	#$06
			pula	
			ifeq
				clrb	
				rts	
			endif
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
			ifne
				addb	#$07
				bra	gb_C9
gb_C8				inca	
			else
				deca
			endif	
gb_C7			incb	
gb_C9			psha	
			pshb	
			suba	#$53
			jsr	lfill_b
			ifcs
				jsr	bit_lamp_buf_f
				beq	gb_E1
			endif
			pulb	
			pula	
			SLEEP($01)
			decb	
			bra	gb_88
			begin
gj_27				jsr	lampm_c
				jsr	lfill_b
				bcs	gb_3B
				SLEEP($04)
			loopend
gb_3B			jmp	killthread

gb_3A			begin
				ldab	#$0F
				begin
					SLEEP($40)
					decb	
				eqend
				ldaa	game_ram_9
				deca	
				staa	game_ram_9
				cmpa	#$09
			leend
			bra	gb_3B

sw_z_bomb		.db $5A,$FB,$F3,$F1,$D0,$30,$1E	;BEQ_(BIT2#30 || (!GAME)) to gb_09
			PRI_($10)				;Priority=#10
			REMTHREADS_($FF,$10)		;Remove Multiple Threads Based on Priority
			JSRD_(setup_msg_endptr)		
			JSRD_(clr_alpha_set_b0)			
			JMPD_(gj_09)
			
gj_45			swi	
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
			ifne
				decb	
				stab	$00,X
			endif
			ADDRAM_($00,$0B)			;RAM$00+=$0B
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
			ldx	#gj_48
			jsr	addthread_clra
gb_D1			RSET1_($54)				;Effect: Range #54
			JSRR_(gj_42)			
			EXE_($08)				;CPU Execute Next 8 Bytes
			ldaa	cur_bolt_cnt
			sba	
			ifle
				clra	
			endif
			staa	cur_bolt_cnt
			JSRDR_(zbomb_ani)		
			SND_($0B)				;Sound #0B
			JSRDR_(zbomb_ani3)	
			RCLR0_($12)				;Effect: Range #12
			RCLR1_($54)				;Effect: Range #54
			BITOFF4_($2F)			;Turn OFF: Lamp#2F(lamp_o6)
			JMPR_(chk_wave_compl)
		
			.db $03


gj_13			ADDRAM_($08,$01)			;RAM$08+=$01
gj_42			.db $5B,$FD,$E8,$06,$02		;BNE_RAM$08>=#6 to gb_70
			SETRAM_($08,$06)			;RAM$08=$06
gb_70			MRTS_					;Macro RTS, Save MRA,MRB

zbomb_ani		ldx	#lmp_ani_inout-1
			begin
				begin
					inx	
					cpx	#lmp_ani_outin
					beq	zbomb_ani2
					ldab	$00,X
					tba	
					anda	#$7F
					jsr	lamp_on_1
					tstb	
				plend
				ldaa	#$0F
				jsr	isnd_once
				SLEEP($02)
			loopend

lmpanirts		rts	

zbomb_ani2		ldx	#lmp_ani_inout-1
			begin
				begin
					inx	
					cpx	#lmp_ani_outin
					beq	lmpanirts
					ldab	$00,X
					tba	
					anda	#$7F
					jsr	lamp_off_1
					tstb	
				plend
				SLEEP($02)
			loopend

zbomb_ani3		ldx	#lmp_ani_inout-1
			begin
				stx	hy_unknown_2
				begin
					inx	
					cpx	#lmp_ani_outin
					beq	lmpanirts
					ldab	$00,X
					tba	
					anda	#$7F
					jsr	lamp_on_1
					tstb	
				plend
				SLEEP($03)
				ldx	hy_unknown_2
				begin
					inx	
					ldab	$00,X
					tba	
					anda	#$7F
					jsr	lamp_off_1
					tstb	
				plend
			loopend

			.db $00


gameover_entry	swi	
			SOL_(ENERGY_FL_OFF,P1_FL_OFF,GI_BB_OFF,GI_PF_OFF,P2_FL_OFF,BALL_LIFT_OFF)	
			 SND_($18)				;Sound #18
			RCLR0_($14)				;Effect: Range #14
			RCLR1_($D4,$14)			;Effect: Range #D4 Range #14
			PRI_($10)				;Priority=#10
			CPUX_					;Resume CPU Execution
			ldx	#game_over_thrds
			jsr	addthread_clra
			;this is the main display loop for the game over sequence
			clr	flag_tilt
			clr	bitflags+6
			begin
				ldx	#msg_williams
				bsr	ani_msg_starslide
				SLEEP($90)
				ldx	#msg_electronics
				bsr	ani_msg_starslide
				SLEEP($90)
				ldx	#msg_presents
				bsr	ani_msg_starslide
				SLEEP($70)
				ldx	#msg_hyperball
				clrb	
				jsr	ani_msg_letters
				ldab	#$25
				ldx	#alpha_b0+11
				jsr	ani_spinner
gj_09				inc	bitflags+6
				jsr	disp_hy_score
gj_39				jsr	setup_msg_endptr
				jsr	clr_alpha_set_b0
				staa	bitflags+6
				ldx	#msg_credit
				jsr	copy_msg_full
				ldaa	current_credits
				jsr	gj_2C
				SLEEP($E0)
			loopend

ani_msg_starslide	jsr	copy_msg_full
ani_starslide	jsr	clr_alpha_set_b1
			ldaa	#$04
			ldx	#alpha_b1
			begin
				bsr	gb_4F
				jsr	hex2bitpos
				comb	
				andb	dmask_p3
				stab	dmask_p3
				inx	
				deca	
			miend
			ldaa	#$06
			begin
				bsr	gb_4F
				jsr	hex2bitpos
				comb	
				andb	dmask_p4
				stab	dmask_p4
				inx	
				deca	
			miend
			rts	
			
gb_4F			psha	
			pshb	
			ldab	#$01
			begin
				ldaa	#$18
				staa	$00,X
				SLEEP($02)
				ldaa	#$2B
				staa	$00,X
				SLEEP($02)
				decb	
			eqend
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

;* Takes care of showing the between wave lamp effect and turns off solenoids
waveend_ux		ldx	#wvend_lamp_ani
			bsr	to_addthread
			ldx	#sols_off
to_addthread	jmp	addthread_clra

;******************************************************
;* Launch game over threads, this starts up the threads
;* for displaying the playfield lamps, the z-bomb lamp
;* and the player displays
;******************************************************
game_over_thrds	ldx	#ec_animate
			bsr	to_addthread
wvend_lamp_ani	ldx	#ec_gover_lamps
			bsr	to_addthread
			;this is the main playfield lamp display sequence, it repeats indefinitely
			begin
				ldx	#lmp_ani_outin-1
gb_3F				inx	
				cpx	#disp_wave_num
				ifne
					ldaa	$00,X
					tab	
					anda	#$7F
					jsr	lamp_on
					jsr	lamp_on_b
					tstb	
					bmi	gb_3F
					SLEEP($05)
					bra	gb_3F
				endif
				ldx	#lmp_ani_outin-1
gb_8E				inx	
				cpx	#disp_wave_num
			neend
			ldaa	$00,X
			tab	
			anda	#$7F
			jsr	lamp_off
			tstb	
			bmi	gb_8E
			SLEEP($05)
			bra	gb_8E
			
;toggles all EC lamps, forever	
ec_gover_lamps	begin
				ldaa	#$D4
				jsr	lampm_f
				SLEEP($04)
			loopend
			
			
			ldaa	#$08
			begin
				SLEEP($40)
				deca	
			eqend
			ldaa	#$09
			jsr	solbuf
			jmp	killthread

;********************************************
;* Method to take the current alpha display
;* and shift the content out left until the 
;* display is empty
;********************************************
shift_out_left   	clrb	
			ldaa	#$0C				;all 12 digits
			jmp	gj_20				;always returns zero

;********************************************
;* Show A thousands on the alpha display
;* like: AA,000
;********************************************
show_thousands	tab	
			anda	#$0F
			adda	#$1B
			oraa	#$80
			staa	$02,X
			jsr	split_ab
			clra	
			tstb	
			ifne
				addb	#$1B
				tba	
			endif
show_10thous	staa	$01,X
			ldaa	#$1B
			staa	$03,X
			staa	$04,X
			staa	$05,X
			rts	

;**************************************************
;* All Reflex is done in this big thread
;**************************************************
reflex_thread	ldx	#msg_reflex
			ldaa	#$04
			staa	game_ram_a
			jsr	ani_msg_rlslide
			ldx	#msg_wave
			jsr	ani_msg_rlslide
			SLEEP($40)
			bsr	shift_out_left			;returns zero always
			staa	reflx_cur_hits				;cleared
			staa	game_ram_a				;cleared
reflex_loop		jsr	setup_msg_endptr
			inc	reflx_cur_hits
			ldaa	#$14					;max number of reflex attempts in wave: 20d
			cmpa	reflx_cur_hits
			ifeq
				jsr	setup_msg_endptr			;Reflex wave is over by getting all of them done.
				ldaa	#$10
				jsr	isnd_once				;make sound
				ldaa	#$01
				staa	bitflags+6
				ldx	#msg_great_reflex
				jsr	ani_msg_rlslide			;Tell the player they are doing well!
				bsr	shift_out_left
				ldx	#alpha_b0				;set X to first position on display
				ldaa	current_wave			;which wave are we on?
				cmpa	#$06
				ifle						;5th wave reflex
					ldaa	#$2C					;50,000 points
					jsr	score_main
					ldaa	#$50
					bsr	show_thousands
				else						;10th+ wave reflex
					ldaa	#$0D
					jsr	score_main				;100,000 points
					ldaa	#$1C
					staa	$00,X					;store the 1
					ldaa	#$9B
					staa	$02,X					;zero with a comma
					ldaa	#$1B
					bsr	show_10thous			;show zero 10 thousands + 100,000
				endif
				ldx	#alpha_b0+7
				stx	temp1
				ldx	#msg_bonus
				jsr	copy_msg_part
to_next_wave		swi	
				REMTHREADS_($08,$00)		;Remove Multiple Threads Based on Priority
				JSR_(gj_06)				
				JSRDR_(waveend_ux)		
				SND_($0D)				;Sound #0D
				SLEEP_(80)
				JMP_(setup_next_wave)		
			endif
			swi	
			PRI_($00)				;Priority=#00
gb_41			SLEEP_(1)
			JSRD_(get_random)			
gj_1D			EXE_
				anda	#$1F
			EXEEND_
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
			ldaa	reflx_cur_pts
			jsr	show_thousands
			pulb	
			pula	
			SLEEP($30)
			psha	
			ldaa	game_ram_c
			staa	reflx_tmr_btr
			begin
				ldaa	reflx_tmr_btr
				cmpa	#$04
				ifgte
					dec	reflx_tmr_btr
				endif
				staa	thread_timer_byte
				ldaa	#$01
				jsr	isnd_once
				jsr	delaythread
				pula	
				jsr	gb_8A
				beq	gb_E3
				ldx	#alpha_b0+3
				psha	
				jsr	gj_46
			eqend
			ldaa	reflx_cur_hits
			cmpa	#$05
			ifgt
				pula	
				ldaa	#$1E
				staa	flag_tilt			;turn OFF the shooters 
				jsr	isnd_once
				jsr	setup_msg_endptr
				ldaa	#$01
				staa	bitflags+6
				ldx	#msg_youmissed
				jsr	ani_msg_rlslide
				jsr	shift_out_left
				jmp	to_next_wave
			endif
			pula	
			bsr	gb_F8
			bra	to_reflex_loop
			
gb_E3			bsr	gb_F8
			ldx	#alpha_b0+3
			jsr	gb_D3
			jsr	gj_0D
			ldaa	#$06
			begin
				jsr	invert_alphamsk
				psha	
				ldaa	#$0E
				jsr	isnd_once
				pula	
				SLEEP($05)
				deca	
			eqend
			ldaa	reflx_cur_pts
			adda	#$01
			daa	
			staa	reflx_cur_pts
to_reflex_loop	jmp	reflex_loop

gj_46			ldaa	$01,X
			cmpa	#$9B
			ifne
				deca	
				staa	$01,X
			else
				ldaa	$00,X
				ifne
					deca	
					cmpa	#$1B
					ifeq
						clra	
					endif
					staa	$00,X
					ldaa	#$A4
					staa	$01,X
				endif
			endif
			rts	

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

high_score	ldab	#$0A
			clr	flag_tilt
			ldaa	sys_temp2
			staa	dynamic_disp_buf+10
			staa	flag_gameover
			begin
				ldaa	gr_hssound
				jsr	isnd_once
				ldx	#msg_player
				pshb	
				jsr	copy_msg_full
				pulb	
				ldaa	dynamic_disp_buf+10
				nega	
				adda	#$1E
				ldx	temp1
				staa	$01,X
				SLEEP($08)
				jsr	setup_msg_endptr
				SLEEP($08)
				decb	
			eqend
			ldx	#msg_great_score
			jsr	copy_msg_full
			ldx	temp1
			ldab	#$10
			jsr	ani_spinner
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
			stx	hy_unknown_8
gb_48			begin
				ldaa	#$2E
				staa	$00,X
				begin
					jsr	gj_22
					ldaa	$00,X
					cmpa	#$2D
					bne	gb_46
					clr	$00,X
					dex	
					ldaa	$00,X
				eqend
			loopend

gb_46			cmpa	#$2E
			ifeq
				ldaa	#$00
				staa	$00,X
			endif
			inx	
			cpx	#alpha_b0+3
			bne	gb_48
			begin
				ldx	#aud_game1
				stx	temp1
				ldab	#$0C
				ldx	#alpha_b0
				jsr	copyblock2
				stab	bitflags+6
				jmp	set_hstd
	
gj_22				ldaa	$00,X
				staa	dynamic_disp_buf+9
				ldaa	#$60
				staa	dynamic_disp_buf+11
gb_E8				ldaa	#$06
				staa	dynamic_disp_buf+10
				dec	dynamic_disp_buf+11
				bne	gb_94
				ins	
				ins	
				clr	$00,X
			loopend

gb_94			SLEEP($02)
			ldaa	$80
			ifmi
				jsr	gj_41
				begin
					SLEEP($02)
					ldaa	$80
				plend
				rts	
			endif
			ldaa	$81
			anda	#$03
			ifeq
				dec	dynamic_disp_buf+10
				bne	gb_94
				ldaa	$00,X
				ifne
					clr	$00,X
					bra	gb_E8
				endif
				ldaa	dynamic_disp_buf+9
				staa	$00,X
				bra	gb_E8
			endif
			jsr	gj_41
			ldab	#$20
			stab	dynamic_disp_buf+10
			rora	
			ifcc
				begin
					bsr	gb_FE
gb_FF					SLEEP($01)
					ldaa	$81
					bita	#$02
					beq	gj_22
					dec	dynamic_disp_buf+10
					bne	gb_FF
					ldaa	#$05
					staa	dynamic_disp_buf+10
				loopend
			endif
			begin
				bsr	gb_104
				begin
					SLEEP($01)
					ldaa	$81
					rora	
					bcc	gj_22
					dec	dynamic_disp_buf+10
				eqend
				ldaa	#$05
				staa	dynamic_disp_buf+10
			loopend

gb_FE			ldaa	$00,X
			inca	
			cmpa	#$2E
			ifeq
gb_109			ldaa	#$2E
			endif
			cmpa	#$2F
			ifeq
				ldaa	#$01
			endif
			cmpa	#$1B
			ifeq
				cpx	#alpha_b0
				beq	gb_109
gb_10D			ldaa	#$2D
			endif
			begin
				staa	$00,X
				rts	
gb_104			ldaa	$00,X
				deca	
				ifeq
					ldaa	#$2E
				endif
				cmpa	#$2C
				ifeq
gb_10C				ldaa	#$1A
				endif
				cmpa	#$2D
			eqend
			cpx	#alpha_b0
			beq	gb_10C
			bra	gb_10D

gj_41			psha	
			ldaa	dynamic_disp_buf+9
			staa	$00,X
			pula	
			rts	

disp_hy_score	jsr	show_hstd
			ldab	comma_flags
			stab	dynamic_disp_buf+9
			coma	
			tst	score_p1_b1
			ifeq
				staa	score_p1_b1
				staa	score_p2_b1
				ldaa	#$33
			endif
			staa	comma_flags
			ldaa	#$7F
			jsr	clr_dis_masks12
			ldx	#msg_hy_score
			jsr	copy_msg_full
			SLEEP($30)
			ldaa	#$0C
			staa	hy_unknown_9
			ldx	#hy_unknown_a
			stx	temp1
			ldx	#aud_game1
			ldab	#$0C
			jsr	block_copy
			ldx	#hy_unknown_9
			jsr	gb_0E
			jsr	slide_l
			SLEEP($A0)
			ldab	dynamic_disp_buf+9
			stab	comma_flags
			clra	
			jmp	clr_dis_masks12

;**************************************************
;* This routine makes the Energy Center lights
;* sparkle by using two overlapping patterns
;**************************************************
ec_animate		ldx	#$5501
			stx	lampbufferselectx+2
			ldaa	#$80
			ldab	player_up
			ifne
				lsra	
			endif
			staa	lampbufferselectx+1
			ldx	#ec_rotator
			jsr	addthread_clra
			swi	
			.db $5B,$F1,$05			;BNE_GAME to gb_4A
			RSET0_($0A)				;Effect: Range #0A
			RCLR1L0_($8A,$0A)			;Effect: Range #8A Range #0A
gb_4A			RCLR1_($0A)				;Effect: Range #0A
gj_24			SLEEP_(5)
			RINV1_($4A)				;Effect: Range #4A
			JMPR_(gj_24)
			
;* This routine rotates the EC lamps in the animation sequence			
ec_rotator		swi	
gj_25			SLEEPI_($2)				;Delay RAM$02
			RROR0_($0A)				;Effect: Range #0A
			JMPR_(gj_25)


;* Turns off all solenoids			
sols_off		begin
				ldaa	#$40
				jsr	solbuf
				SLEEP($0A)
			loopend


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
			.db %01110001	\.dw reset			;(7) slam
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


LAMP_A	.equ	$36
LAMP_B	.equ	$37
LAMP_C	.equ	$38
LAMP_D	.equ	$39
LAMP_F	.equ	$3D
LAMP_G	.equ	$3E
LAMP_H	.equ	$00
LAMP_I	.equ	$06
LAMP_J	.equ	$0C
LAMP_K	.equ	$12
LAMP_L	.equ	$18
LAMP_M	.equ	$1E
LAMP_N	.equ	$24
LAMP_O	.equ	$2A
LAMP_P	.equ	$30
LAMP_R	.equ	$47
LAMP_S	.equ	$46
LAMP_T	.equ	$43
LAMP_U	.equ	$42
LAMP_V	.equ	$41
LAMP_W	.equ	$40
LAMP_Y	.equ	$3F


gj_12			.db $3D,$3E

gj_02			.db LAMP_A,LAMP_B,LAMP_C,LAMP_D,LAMP_Y,LAMP_W,LAMP_V,LAMP_U,LAMP_S,LAMP_R

gj_1B			.db LAMP_A,LAMP_B,LAMP_C,LAMP_D,LAMP_Y,LAMP_W,LAMP_V,LAMP_U,$00,LAMP_F,LAMP_G,$00
			.db LAMP_I,LAMP_J,LAMP_K,LAMP_L,LAMP_M,LAMP_N,LAMP_O,LAMP_P,LAMP_R,LAMP_S,$00

gj_2D			.db $06,$07,$01,$02,$03,$04,$19,$17,$16,$15,$13,$12,$05,$14

wave_bolt_cnt	.db $0C,$0F,$13,$15


random_words	.dw msg_energy
			.dw msg_bonus
			.dw msg_hyper
			.dw msg_cannon
			.dw msg_laser
			.dw msg_alien
			.dw msg_ray

;switch to lamp map table, switches are contiguous in index to this table, the data is the lamp offset to the 
;top lamp in the series (if any)
sw_to_lamp_map			.db $01,$02,$03,$04,$19,$17,$16,$15,$05,$06,$07,$08,$09,$0A,$0B,$0C
			.db $0D,$0E,$0F,$10,$12,$13,$14

;*************************************************************
; Character Sprites
;
; J H F E  D C B A   X X N P  R M G K
;
;   ---a---
;  |\  |  /|
;  f h j k b
;  |  \|/  |
;   --- -m-
;  |  /|\  |
;  e r p n c
;  |/  |  \|
;   ---d---
;
;*************************************************************

character_defs	.dw $0000	;SPACE (00)
			.dw $3706	;A (01)
			.dw $8F14	;B (02)
			.dw $3900	;C (03)
			.dw $8F10	;D (04)
			.dw $3902	;E (05)
			.dw $3102	;F (06)
			.dw $3D04	;G (07)
			.dw $3606	;H (08)
			.dw $8910	;I (09)
			.dw $1E00	;J (0A)
			.dw $3023	;K (0B)
			.dw $3800	;L (0C)
			.dw $7601	;M (0D)
			.dw $7620	;N (0E)
			.dw $3F00	;O (0F)
			.dw $3306	;P (10)
			.dw $3F20	;Q (11)
			.dw $3326	;R (12)
			.dw $2D06	;S (13)
			.dw $8110	;T (14)
			.dw $3E00	;U (15)
			.dw $3009	;V (16)
			.dw $3628	;W (17)
			.dw $4029	;X (18)
			.dw $2216	;Y (19)
			.dw $0909	;Z (1A)
			.dw $3F09	;0 (1B)
			.dw $8010	;1 (1C)
			.dw $0B0C	;2 (1D)
			.dw $0D05	;3 (1E)
			.dw $2606	;4 (1F)
			.dw $2922	;5 (20)
			.dw $3D06	;6 (21)
			.dw $0700	;7 (22)
			.dw $3F06	;8 (23)
			.dw $2F06	;9 (24)
			.dw $8200	;quot (25)
			.dw $0006	;- (26)
			.dw $4020	;\ (27)
			.dw $8010	;| (28)
			.dw $0009	;/ (29)
			.dw $BB04	;@ (2A)
			.dw $8016	;+ (2B)
			.dw $C03F	;  (2C)
			.dw $0025	;<- (2D)
			.dw $0800	;_ (2E)

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


disp_wave_num	ldaa	current_wave
gj_2C			tab	
			anda	#$0F
			adda	#$1B
			ldx	temp1
			staa	$02,X
			jsr	split_ab
			tstb	
			ifne
				addb	#$1B
			endif
			stab	$01,X
			rts	

gj_21			ldx	#hy_unknown_8
			stx	temp1
			bsr	disp_wave_num
			ldaa	#$08
			staa	$00,X
			ldaa	#$13
			staa	$08,X
			clr	$03,X
			ldx	#hy_unknown_b
			stx	temp1
			ldx	#msg_wave
			jsr	copy_msg_part
			jsr	gb_0E
			clrb	
			ldaa	#$04
			jsr	gj_20
			ldx	#hy_unknown_8
			jmp	slide_l


;*****************************************************************************
;* Williams Hyperball System Code
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



;*****************************************************************************
;* Some Global Equates
;*****************************************************************************

irq_per_minute =	$0EFF

;*****************************************************************************
;*Program starts at $e800 for standard games... we can expand this later..
;*****************************************************************************
	.org $E730



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
			staa	current_credits
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
			deca
			staa	p2_ec_b0
			staa	p1_ec_b0
			cli
			ldx	gr_reset_ptr
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
			ldx	gr_mainloop_ptr
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
			ldaa	$07,X
			psha
			ldaa	$08,X
			psha
			ldaa	$09,X
			psha
			ldaa	$0A,X
			psha
			ldaa	$0C,X
			psha
			ldaa	$0B,X
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
			pula
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
				jmp	nextthread			;Go check the Control Routine for another job.
				
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
;* Kill All threads with the given Definition
;*
;* Requires:   A - EOR Mask Definition	
;*             B - AND Mask Definition	
;* 
;* If result is not zero, then thread is killed
;* If B = 0, then all threads are killed
;* 
;* Example:
;* 
;* Given two threads with priority $10 and $30
;*
;*     Thread 1:   0001 0000
;*     Thread 2:   0011 0000
;*
;*  kill_threads with the following would result
;*
;*   A: 0011 0000 ($30)
;*   B: 0011 0000 ($30)
;*   This would kill Thread 2
;*
;*   A: 0001 0000 ($10)
;*   B: 0011 0000 ($30)
;*   This would kill Thread 1
;*
;*   A: 0010 0000 ($20)
;*   B: 0011 0000 ($30)
;*   This would kill Thread 1
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
;*  	XXXZZZZZ	Where: ZZZZZ is solenoid number 00-10d
;*                       XXX is timer/command
;*
;* NOTE: Hyperball only allows 8 solenoids + Shooter + BallLift
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

			;*************************************************
;* Get Physical Address and Bitposition of 
;* solenoid number.
;*
;* Requires:	A - Solenoid Number
;* Output:		B - PIA bit position
;*			X - PIA address
;*************************************************	
soladdr		anda	#$0F				;Mask to under 16 Solenoids
			ldx	#pia_sol_high_data
			cmpa	#$07				;Normal solenoids or ball shooter/ball lift
			ifgt					;Get Regular Solenoid Address (PIA)
				inx
				ldab	#$08
				cba
				ifeq
					;this is the ball shooter coil
					ldx   #pia_sol_low_ctrl
					sec 
				endif
				rts	
			endif
			

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
				cmpa	x_temp_2
				ifge
					stx	thread_priority
					nop
					nop
					nop
					nop
					nop
					nop
					ldx	#(aud_replay1times + 2)
					nop
					jsr	ptrx_plus_1			;add 1 to address in X
					ldx	thread_priority
					jsr	award_replay
				endif
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
			anda	#$0F
			ldab	$01,X
			bsr	b_plus10		;If B minus then B = B + 0x10
			bsr	split_ab		;Shift A<<4 B>>4
			aba	
			tab
b_plus10		cmpb	#$A0
			ifcc
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
			ifge						;Out of Range!
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
							ldx	#macro_next		;Will put this routine into VM.
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
reset_audits	ldx	#aud_reset_end-cmos_base		;Clear RAM from 0100-0165
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
			ldx	#gr_cmoscsum			;Begining of Default Audit Data
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
					staa   alpha_digit_cur+1
					inca  
				endif
				staa   lamp_bit
			endif
			ldx   lamp_index_word
			ldab   irq_counter
			andb  #$07
			ifeq
				ldaa  #$FF
				staa  pia_disp_seg_data
				clr	pia_alphanum_digit_data
				clr   pia_alphanum_seg_data
				ldab  irq_counter
				stab  pia_disp_digit_data
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
			orab  pia_comma_data
			bra   snd_wr
b_082			inc   irqcount16
			ldaa  comma_flags
			staa  comma_data_temp
			ldaa  dmask_p1
			staa  credp1p2_bufferselect
			ldaa  dmask_p3
			staa  alpha_bufferselect
			ldab  p2_ec_b0
			rol   credp1p2_bufferselect
			ifcs
				ldab   p2_ec_b1
			endif
			ldaa  p1_ec_b0
			rol   alpha_bufferselect
			bcc   b_083
			ldaa  p1_ec_b1
			bra   b_083

			;***********************************
			;* Sound command clear
			;***********************************
snd_wr0		ldab  pia_comma_data
			andb  #$3F
snd_wr		stab  pia_comma_data

			;reset displays
			clr   pia_alphanum_digit_data
			clr   pia_alphanum_seg_data
			ldaa   #$FF
			staa   pia_disp_seg_data
			ldaa   irq_counter
			staa   pia_disp_digit_data
			
			
			ldaa   score_p1_b0,X
			rol   credp1p2_bufferselect
			ifcs
				ldaa   score_p1_b1,X
			endif
			ldab   #03
			cmpb  irq_counter
			ifgt
				rol   alpha_bufferselect
			else
				ldx	alpha_digit_cur
				inc   alpha_digit_cur+1 	;increment LSB
				ldab  alpha_b0,X
				rol   alpha_bufferselect
				ifcs
					ldab   alpha_b1,X
				endif
				ldx   gr_character_defs_ptr	;This is the index table for all characters
				psha  
				tba   
				andb  #$3F				;max 3F characters in lookup table
				aslb  
				stx   character_ptr
				addb  character_ptr+1
				stab  character_ptr+1
				ifcs
					inc   character_ptr
				endif
				ldx   character_ptr
				ldab   $00,X
				stab   pia_alphanum_digit_data	;write character data
				ldab   $01,X
				bita  #$80
				ifne
					orab   #$40
				endif
				bita  #$40
				ifne   
					orab   #$80
				endif
				stab   pia_alphanum_seg_data	;write comma/dot data
				pula  	
			endif
			ldab   #$FF
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
				staa	alpha_bufferselect
				ldab	p2_ec_b0
				rol	credp1p2_bufferselect
				ifcs
					ldab	p2_ec_b1
				endif
				ldaa	p1_ec_b0
				rol	alpha_bufferselect
				ifcs
					ldaa	p1_ec_b1
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
				staa	pia_sol_low_data
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
					andb  lampbuffer0x,X
					anda  lampbuffer1x,X
					aba   
					coma  
					ldab   lamp_index_wordx
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
			endif
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

lampbuffers		.dw lampbuffer0		;Lower Buffer for 1X Commands, $40 Flag Clear
			.dw bitflags		;Upper Buffer for 1X Commands, $40 Flag Set
			.dw lampbuffer1		;Lower Buffer for 2X Commands, $40 Flag Clear
			.dw lampbufferselect	;Upper Buffer for 2X Commands, $40 Flag Set

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
				
lamp_on_b		stx	temp3
			ldx	#lampbufferselect
			bra	lamp_or

lamp_off_b		stx	temp3
			ldx	#lampbufferselect
			bra	lamp_and

lamp_invert_b	stx	temp3
			ldx	#lampbufferselect
			bra	lamp_eor

lamp_on_1		stx	temp3
			ldx	#lampbuffer1
			bra	lamp_or

lamp_off_1		stx	temp3
			ldx	#lampbuffer1
			bra	lamp_and

lamp_invert_1	stx	temp3
			ldx	#lampbuffer1
			bra	lamp_eor
			
lamp_on_f		stx	temp3
			ldx	#bitflags
			bra	lamp_or

lamp_off_f		stx	temp3
			ldx	#bitflags
			bra	lamp_and

lamp_invert_f	stx	temp3
			ldx	#bitflags
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

lfill_a		jsr	lampr_start				;A=Current State,B=Bitpos,X=Lamp Byte Postion
b_0AB			ifne
				jsr	lamp_left				;Shift Lamp Bit Left, De-increment Lamp Counter, Write it
				bcc	b_0AB
				bra	to_abx_ret
			endif
lmp_clc		clc	
			bra	to_abx_ret

lfill_b		jsr	lampr_start				;A=Current State,B=Bitpos,X=Lamp Byte Postion
			begin
				bne	lmp_clc
				jsr	lamp_left				;Shift Lamp Bit Left, De-increment Lamp Counter, Write it
			csend
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
			.dw vm_control_dx		;Extended Lamp Functions
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
			.dw lamp_on_b
			.dw lamp_off_b
			.dw lamp_invert_b

vm_lookup_2x_b
			.dw lamp_on_1
			.dw lamp_off_1
			.dw lamp_invert_1

vm_lookup_2x_c
			.dw lamp_on_f
			.dw lamp_off_f
			.dw lamp_invert_f

vm_lookup_4x
			.dw add_points
			.dw score_main  
			.dw dsnd_pts 

vm_lookup_5x    
			.dw macro_ramadd
			.dw macro_ramcopy
			.dw macro_set_pri
			.dw macro_delay_imm_b
			.dw macro_rem_th_s
			.dw macro_rem_th_m
			.dw macro_jsr_noreturn
			.dw macro_jsr_return
			.dw macro_branch
			.dw macro_branch
			.dw macro_branch
			.dw macro_branch
			.dw macro_jmp_cpu
			.dw macro_setswitch
			.dw macro_clearswitch
			.dw macro_jmp_abs

branch_lookup
			.dw branch_tilt		;Tilt Flag				
			.dw branch_gameover     ;Game Over Flag			
			.dw macro_getnextbyte	;NextByte = Straight Data		
			.dw branch_invert		;Invert Result			
			.dw branch_lamp_on	;Check if Lamp is On or Flashing
			.dw branch_lamprangeoff	;Lamp Range All Off			
			.dw branch_lamprangeon	;Lamp Range All On			
			.dw branch_lampbuf1	;RAM Matrix $0028			
			.dw branch_switch		;Check Encoded Switch		
			.dw branch_add		;A = A + B				
			.dw branch_and		;Logical AND 				
			.dw branch_or		;Logical OR 				
			.dw branch_equal		;A = B ??				
			.dw branch_ge		;A >= B ??				
			.dw branch_threadpri	;Check for Priority Thread??	
			.dw branch_bitwise	;A && B	

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
			staa	vm_pc
			pula	
			staa	vm_pc+1
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

macro_next		stx	vm_pc
abreg_sto		staa	vm_reg_a
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

macro_special	jsr	award_replay			;Award Special
			bra	macro_go

macro_extraball	jsr	award_extraball			;Award Extra Ball
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
vm_control_dx	ldx   #vm_lookup_2x_b
			tab   
			andb  #$0F
			subb  #$08
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
			eqend						;Add B bytes to exe Buffer 
			ldaa	#$7E
			staa	$00,X
			ldaa	#((abreg_sto>>8)&$FF)
			staa	$01,X
			ldaa	#((abreg_sto)&$FF)		;Tack a jmp macro_next at the end of the routine
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
			jmp	macro_next

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
			
vm_control_nu	anda	#$0F
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
			beq	cbra2
			bcs	to_rts3				;(rts) if data is below #D0
			cmpa	#$F0
			bcc	complexbranch			;Branch if #F0 or above (Complex)
			cmpa	#$E0
			ifcc						;Branch if less than #E0
				jmp	macro_b_ram				;RAM Data (A&0f)->A (Data is E_)
			endif
			ldx	#adj_gamebase		;Pointer to Bottom of Game Adjustments
			anda	#$0F					;A = Index for Game Adjustment Lookup
			asla	
			jsr	xplusa				;X = X + A
			jmp	cmosinc_a				;CMOS,X++ -> A

complexbranch	cmpa	#$F3
			ifcc							;data is below #F3 (not complex)
cbra2				psha						;Push Current Branch Inst.
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
			cmpa	#$D0
			beq	branch_lampflag
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
			jsr	lfill_b
test_c		bcs	ret_true				;return true
			bra	ret_false				;return false
			
branch_lamprangeon	
			jsr	lfill_a
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


branch_lampflag	ldaa  temp1					;Check Encoded #(A) with bitflags
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

award_extraball	psha	
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
			oraa	#$F0
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
			cmpb	current_credits
			ifne
				ldaa	current_credits
				adda	#$01
				daa	
				staa	current_credits
				ldx	gr_coin_ptr			;Game ROM:
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
			bsr	dec2hex
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
do_game_init	ldx	gr_gamestart_ptr			;Game Start Hook
			jsr	$00,X					;jsr to Game ROM Hook
			jsr	dump_score_queue			;Clean the score queue
			bsr	clear_displays			;Blank all Player Displays (buffer 0)
			deca
			staa	p1_ec_b0
			bsr	initialize_game			;Remove one Credit, init some game variables
			bsr	add_player				;Add one Player
			jmp	init_player_up


;****************************************************
;* Add Player: Increments player count and loads    
;*             default game data for that player.  
;*             Plays start sound and inits display.
;*
;* Requires:   No Variables
;****************************************************	
add_player		jsr   gr_addplayer_event
			inc   num_players
			ldab  num_players
			bsr   init_player_game
		
			ldx	#gr_p1_startsound			;Game ROM Table: Player Start Sounds
			jsr	xplusb				;X = X + B)
			ldaa	$00,X
			jsr	isnd_once				;Play Player Start Sound From Game ROM Table
			ldx	#adj_gamebase
			jsr	cmosinc_a			
			oraa	#$F0
			tstb
			ifne
				staa	p1_ec_b0
			else
				staa	p2_ec_b0
			endif
ap_shft		aslb
			aslb
			ldx	#score_p1_b0
			jsr	xplusb
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
			ldab	#$12
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
			
clr_dis_masks	clra
			staa	dmask_p4				;These are the Display Buffer Toggles
			staa	dmask_p3
clr_dis_masks12	staa	dmask_p2
			staa	dmask_p1
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
setplayerbuffer	ldaa	#gamedata_size			;Length of Player Buffer
			ldx	#p1_gamedata-gamedata_size	;Player 1 base
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
			ldx   #p2_ec_b0
			ldab   player_up
			ifne
				ldx   #p1_ec_b0
			endif
			ldaa   $00,X
			ifmi
				anda  #0F
			endif
			adda  #$99
			daa   
			cmpa  #$10
			iflt
				oraa   #$F0
			endif
			staa	$00,X
			bsr   resetplayerdata
			ldx   gr_playerinit_ptr
			jsr   $00,X
			begin
player_ready		SLEEP($05)		
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
				ldx   #dmask_p1
				jsr   xplusb
				ldaa  $00,X
				oraa	#$7F
				staa  $00,X
				SLEEP($05)
				jsr   gr_ballstart_event			;Game ROM Hook
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
			staa	random_bool				;Clear Random
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

			ldx  	gr_outhole_ptr		;Game ROM: Pointer
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
			jsr   ptrx_plus_1	 		;Add 1 to data in X
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
				ldaa   p1_ec_b0
				cmpa  #$F0
				bne   badj_rts
badj_p2		      bsr   chk_p1
				bne   badj_loop
				cmpa  p1_ec_b0
				bne   badj_loop
			else
				bsr   chk_p1
				ifne
					rts 
chk_p1			      ldaa   p2_ec_b0
					cmpa  #$F0
					rts   
show_hstd				ldx   #score_p1_b1
					stx   temp1
					ldaa   #02
					begin
						ldab   #04
						ldx   #aud_currenthstd
						jsr   block_copy
						deca  
					eqend
					rts  				;all done, return.
				endif
			endif
			;fall through on game over
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
			
			SOL_($09)				;Turn Off Solenoid: Shooter/BallLift Disabled
			.db $17,$00 			;Flash Lamp: Lamp Locatation at RAM $00
			CPUX_ 				;Resume CPU execution
set_gameover	inc	flag_gameover			;Set Game Over
			ldx	gr_gameoverthread_ptr		;Game ROM: Init Pointer
			jsr	newthread_06			;Push VM: Data in A,B,X,$A6,$A7,$AA=#06
			jsr	clr_dis_masks		
			jmp	killthread				;Remove Current Thread from VM


get_aud_baseawd
			ldx   #aud_game7
			ldaa   player_up
			ifne   
				ldx   #aud_game7+2
			endif
			rts   

check_hstd		ldx	#adj_backuphstd			;CMOS: Backup HSTD
			jsr	cmosinc_a				;CMOS,X++ -> A
			ifne						;No award if backup HSTD is 0,000,000
				clr	sys_temp2
				ldab	#$02
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
					ldx	gr_highscore_ptr			;Game ROM Data: High Score Sound
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
				SLEEP($02)
				ldaa  sys_soundflags			
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
			rola	
			adda	irq_counter					;Throw in some switch matrix stuff
			staa	randomseed
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
				ldx	#adj_gamebase
				jsr	cmosinc_b				;CMOS,X++ -> B
				ldx	sys_temp_w2
				decb
				orab	#$F0
				cmpb	p2_ec_b0
				ifle
					ldab	num_players				;Current # of Players
					cmpb	gr_numplayers			;Max # of Players (Game ROM data)
					ifcs						;Already 4 players, outta here.
						bsr	lesscredit				;Subtract a credit
						jsr	add_player				;Add a player.
					endif
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
			stab	p2_ec_b0				;Show the test number in display
			jsr	newthread_06			;Start a new thread with our test routine
			SLEEP($10)	
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
			SLEEP($02)
			ldab	pia_disp_digit_ctrl
			rts

;*********************************************************
;* This routine will check the state of the Up/Down toggle
;* switch. First do a dummy read to clear previous results
;*********************************************************
check_aumd		ldab	pia_disp_seg_data			;Dummy read to clear previous results
			SLEEP($02)
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
do_audadj		clr	p1_ec_b0
			ldaa	#$04					;Show test 04 by default
			staa	p2_ec_b0
			SLEEP($10)
			begin
				jsr	clear_displays			;Blank all Player Displays (buffer 0)
				bsr	b_129					;#08 -> $0F
				ldab	p1_ec_b0
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
			adda	p1_ec_b0				;Change it
			daa	
			cmpa	#$51					;Are we now on audit 51??
			beq	st_reset				;Yes, Blank displays, reboot game
			cmpa	#$99					;Going down, are we minus now??
			ifeq
				ldaa	#$50					;Yes, wrap around to 50
			endif
			staa	p1_ec_b0				;Store new value
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
			staa	p1_ec_b0
			staa	p2_ec_b0
			SLEEP($50)
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
			bsr	cmos_a				;CMOS, X -> A )
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
						SLEEP($18)
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
				staa	p1_ec_b0				;Match/Ball in Play Display = 00
				ldaa	#$FE					;Initial Sound Command $1E
				begin
					begin
						ldab	#$FF
						stab	pia_sound_data			;Sound Blanking
						SLEEP($00)	
						staa	pia_sound_data			;Commands.. $1E,$1D,$1B,$17,$0F
						jsr	addthread				;Delay $40 IRQ's
						.db	$40
						jsr	do_aumd				;Either repeat same sound or move on to next
					miend
					inc	p1_ec_b0				;Increment Match/Ball in Play Display
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
			stab	p1_ec_b0				;Match/Ball in Play Display Buffer 0
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
				clr  	p2_ec_b0
				bsr  	st_sound
				inc  	p2_ec_b0
				bsr  	st_lamp
				inc  	p2_ec_b0
				bsr  	st_solenoid
				ldx  	#aud_autocycles		;Audit: Auto-Cycles
				jsr  	ptrx_plus_1 		;Add 1 to data at X
			loopend

;****************************************************
;* Main Solenoid Routine - Steps through each solenoid 
;****************************************************			
st_solenoid		ldaa	#$F9
			jsr	solbuf
			begin
				ldab  #$01
				stab 	p1_ec_b0	 
				ldaa 	#$20
				begin
					begin
						bita	#$08
						ifne
							bsr   solenoid_wait
						else
							jsr  	solbuf			;Turn On Outhole Solenoid
							SLEEP($20)
							
						endif
						SLEEP($20)
						jsr  	do_aumd			;AUMD: + if Manual-Down
					miend
					inca
					inc	p1_ec_b0
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

;****************************************************
;* Main Switch Routine - Scans for closed switches
;****************************************************			
st_switch		begin
				ldaa	#$FF
				staa  p1_ec_b0
				SLEEP($00)
				ldaa 	gr_lastswitch		;Game ROM: Last Switch Used
				deca 
st_swnext			psha
				ldx  	gr_switchtable_ptr
				ldab	#$03
				begin
					deca					;Switchtable entries are 3 bytes each
					bmi	st_dosw		
					jsr	xplusb
				loopend
st_dosw			ldaa	$00,X
				anda	#$10
				staa	vm_reg_a
				pula
				ldx	#switch_masked
				jsr  	unpack_byte    		;Unpack Switch
				tst	vm_reg_a
				ifeq
					bitb 	$00,X
					bne	st_swe
				else
					bitb 	$00,X
					beq   st_swe
				endif
				psha  
				inca  
				ldab  #01
				jsr   divide_ab
				staa   p1_ec_b0
				clra  
				jsr   isnd_once
				pula  
				SLEEP($40)
st_swe			deca  
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
				coma					;Test with #$FF
			eqend
			ldaa	#$03
			staa	temp2
			ldab	#$20					;Begin ROM Test
			ldx	#$FFFF
			begin
				stx	temp1
				addb	#$10
				dec	temp2
				bmi	diag_ramtest
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
			cpx	#$0200
			rts	

;*******************************************
;* CPU Startup/Interrupt Vectors go here.
;*******************************************
	
irq_entry		.dw gr_irq_entry	;Goes to Game ROM
swi_entry		.dw gr_swi_entry	;Goes to Game ROM 
nmi_entry		.dw diag
res_entry		.dw reset

	.end

