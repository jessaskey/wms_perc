;--------------------------------------------------------------
;Spellbinder Game ROM L-0 BETA
;2013 Jess M. Askey - jess@askey.org
;--------------------------------------------------------------
#define SPELLBINDER

#include  "../../68logic.asm"	;680X logic structure definitions   
#include  "../../7gen.asm"	;Level 7 helper macros    
#include  "sb_wvm.asm"		;Virtual Machine Instruction Definitions                           
#include  "sb_hard.asm"		;Hardware Definitions                


;--------------------------------------------------------------------------
; Lamp Definitions for Spellbinder 
;--------------------------------------------------------------------------

lamp_wiz1		.equ	$00
lamp_wiz2		.equ	$01
lamp_wiz3		.equ	$02
lamp_wiz4		.equ	$03
lamp_wiz5		.equ	$04
lamp_2xl		.equ	$05
lamp_3xl		.equ	$06
lamp_5xl		.equ	$07
lamp_troll1		.equ	$08
lamp_09		    .equ	$09
lamp_gargll		.equ	$0a
lamp_warlokl	.equ	$0b
lamp_bkl		.equ	$0c
lamp_ekl		.equ	$0d
lamp_gargtl		.equ	$0e
lamp_demon1		.equ	$0f

lamp_troll2		.equ	$10
lamp_demon2		.equ	$11
lamp_troll3		.equ	$12
lamp_demon3		.equ	$13
lamp_troll4		.equ	$14
lamp_demon4		.equ	$15
lamp_troll5		.equ	$16
lamp_demon5		.equ	$17
lamp_troll6		.equ	$18
lamp_gargtr		.equ	$19
lamp_warlokr	.equ	$1a
lamp_bkr		.equ	$1b
lamp_ekr		.equ	$1c
lamp_gargbr		.equ	$1d
lamp_1e		    .equ	$1e
lamp_demon6		.equ	$1f

lamp_gargtla	.equ	$20
lamp_demon1a	.equ	$21
lamp_troll2a	.equ	$22
lamp_demon2a	.equ	$23
lamp_troll3a	.equ	$24
lamp_demon3a	.equ	$25
lamp_troll4a	.equ	$26
lamp_demon4a	.equ	$27
lamp_troll5a	.equ	$28
lamp_demon5a	.equ	$29
lamp_troll6a	.equ	$2a
lamp_gargtra	.equ	$2b
lamp_gargtlb	.equ	$2c
lamp_demon1b	.equ	$2d
lamp_troll2b	.equ	$2e
lamp_demon2b	.equ	$2f

lamp_troll3b	.equ	$30
lamp_demon3b	.equ	$31
lamp_troll4b	.equ	$32
lamp_demon4b	.equ	$33
lamp_troll5b	.equ	$34
lamp_demon5b	.equ	$35
lamp_troll6b	.equ	$36
lamp_gargtrb	.equ	$37
lamp_500		.equ	$38
lamp_1k		    .equ	$39
lamp_2k		    .equ	$3a
lamp_4k		    .equ	$3b
lamp_8k		    .equ	$3c
lamp_16k		.equ	$3d
lamp_32k		.equ	$3e
lamp_2xu		.equ	$3f

lamp_3xu		.equ	$40
lamp_5xu		.equ	$41
lamp_extrawiz	.equ	$42
lamp_red1		.equ	$43
lamp_red2		.equ	$44
lamp_red3		.equ	$45
lamp_red4		.equ	$46
lamp_red5		.equ	$47
lamp_red6		.equ	$48
lamp_red7		.equ	$49
lamp_red8		.equ	$4a
lamp_red9		.equ	$4b
lamp_axe1		.equ	$4c
lamp_axe2		.equ	$4d
lamp_axe3		.equ	$4e
lamp_axe4		.equ	$4f

lamp_axe5		.equ	$50
lamp_axe6		.equ	$51
lamp_axe7		.equ	$52
lamp_axe8		.equ	$53
lamp_axe9		.equ	$54
lamp_hand1		.equ	$55
lamp_hand2		.equ	$56




;--------------------------------------------------------------------------
; Bitflag Definitions for Spellbinder 
;--------------------------------------------------------------------------

bf_dispspkl	    .equ	$00	;Alpha Display Sparkle Flag, if TRUE, display will sparkle







	.msfirst	
 	.org $d000

;---------------------------------------------------------------------------
;  Default game data and basic system tables start at $d000, these can not  
;  ever be moved
;---------------------------------------------------------------------------

gr_gamenumber		.dw $3513
gr_romrevision		.db $F1
gr_cmoscsum			.db $B2,$A5
gr_backuphstd		.db $12
gr_replay1			.db $00
gr_replay2			.db $00
gr_replay3			.db $00
gr_replay4			.db $00
gr_matchenable		.db $01
gr_specialaward		.db $01
gr_replayaward		.db $00
gr_maxplumbbobtilts	.db $03
gr_numberofballs	.db $04	;number of wizards
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
gr_max_extraballs	.db $00
gr_max_credits		.db $30
;---------------
;Pricing Data  |
;---------------

gr_pricingdata	.db $01	;Left Coin Mult
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

gr_maxthreads		    .db $1C
gr_extendedromtest	    .db $03
gr_lastswitch		    .db (switchtable_end-switchtable)/3
gr_numplayers		    .db $01

gr_lamptable_ptr	    .dw lamptable
gr_switchtable_ptr	    .dw switchtable
gr_soundtable_ptr	    .dw soundtable

gr_lampflashrate	    .db $05

gr_specialawardsound	.db $0D	;Special Sound
gr_p1_startsound	    .db $03
gr_p2_startsound	    .db $03
gr_unknownvar1		    .db $1A
gr_hssound			    .db $11
gr_gameoversound	    .db $1A
gr_creditsound		    .db $00

gr_gameover_lamp	    .db $5F
gr_tilt_lamp		    .db $5F

gr_gameoverthread_ptr	.dw gameover_entry
gr_character_defs_ptr	.dw character_defs
gr_coinlockout		    .db $05
gr_highscore_ptr		.dw high_score

gr_switchtypetable	    .db $00,$02
                        .db $00,$09
                        .db $00,$04
                        .db $00,$01
                        .db $02,$05
                        .db $08,$05
                        .db $00,$00
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



gr_switch_event		bra	empty_event	;(Switch Event)
gr_sound_event		bra	empty_event	;(Sound Event )
gr_score_event		bra	empty_event	;(Score Event)
gr_eb_event			bra	empty_event	;(Extra Ball Event)
gr_special_event	bra	empty_event	;(Special Event)
gr_macro_event		bra	empty_event	;(Start Macro Event)
gr_ballstart_event	bra	empty_event	;(Ball Start Event)
gr_addplayer_event	bra	empty_event	;(Add Player Event)
gr_gameover_event	bra	empty_event	;(Game Over Event)
gr_hstdtoggle_event	bra	empty_event	;(HSTD Toggle Event)

gr_reset_ptr		.dw hook_reset		;Reset
gr_mainloop_ptr		.dw hook_mainloop		;Main Loop Begin
gr_coin_ptr			.dw hook_coin		;Coin Accepted
gr_gamestart_ptr	.dw hook_gamestart	;New Game Start
gr_playerinit_ptr	.dw hook_playerinit	;Init New Player
gr_outhole_ptr		.dw hook_outhole		;Outhole

;------------------------ end system data ---------------------------

empty_event			rts

;******************************************
;* Nothing special to do in Hyperball for
;* the IRQ, just go to system
;******************************************
gr_irq_entry	    jmp	sys_irq_entry

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



;*************************************************
;* Hooks... end with RTS
;*************************************************

;*****************************************************
;* Outhole in Spellbinder is when the players 
;* Wizard is killed
;*****************************************************
hook_outhole	ldaa	#$78
                bsr	killthreads_ff			;kill any game running threads
                inc	flag_tilt				;turn off the shooters 
                bsr	get_pwizards
                ifeq
                    jsr	showplayer
                    SLEEP($60)
                    ldx	#msg_gameover
                    jsr	copy_msg_full
                    ldaa	#$09
                    jsr	isnd_once
                    SLEEP($F0)
                endif
goto_sme		rts

get_pwizards	
                ldaa	player_up
                ifne
                    ldab	p2_wizards
                else
                    ldab	p1_wizards
                endif
                rts
			
killthreads_ff	ldab	#$FF
                jmp	kill_threads

showplayer		ldx	#msg_player
                jsr	copy_msg_full
                ;ldx	current_thread
                ;stab	$0D,X
                ldaa	player_up
                adda	#$1C
                ldx	temp1
                staa	$02,X
                ;jsr	copy_msg_full
                jsr	clr_alpha_set_b1
                jmp	ani_starslide

; Player Init:
hook_playerinit	inc	flag_tilt			;turn off the shooters 
                jsr	showplayer
                swi
                SOL_(GI_RELAY_PF_OFF)		;Sol#6:gi_relay_pf
                SND_($07)				;Sound #07
                EXE_
                    jsr	get_pwizards
                    incb
                    stab	game_ram_2
                EXEEND_
                ;A contains the current number of wizards for the user...
                RCLR0_(grp_wizard)
                BEGIN_
                    RSET1R0_(grp_wizard)
                    SLEEP_(2)
                    ADDRAM_($02,$ff)			;RAM$00+=$01
                EQEND_($FC,$E2,$00)
                SLEEP_(10)
                SOL_(BALL_LIFT_ON)		; Sol#9:ball_lift
                SLEEP_(64)
                REMTHREADS_($FF,$48)		;Remove Multiple Threads Based on Priority
                CPUX_
                jsr	clr_alpha_set_b1
                clra	
                staa	flag_tilt			;turn ON the shooters 
                ldx	#start_play
to_addthr_noa	bra	addthread_clra
                ;rts

hook_reset		ldx	#aud_game1
                stx	temp1
                ldx	#msg_defhs
                ldab	$00,X
                andb	#$0F
                inx	
                jmp	copyblock2

sw_hstd_res		jsr	restore_hstd
to_kill		    jmp	killthread


hook_mainloop	rts
hook_gamestart	rts

; Coin Routine, jumps to Credits display if game is not being played
hook_coin		swi
                SND_($06)				;Sound #06
                BEQR_($FB,$FB,$F0,$D0,$30,$F3,$F1,$F3) ;BEQ_((!GAME) || (BIT2#30 || TILT)) to gj_1F
                REMTHREADS_($FF,$10)		;Remove Multiple Threads Based on Priority
                CPUX_					;Resume CPU Execution
                ldaa	#$10
                ldx	#show_cred
                jmp	newthreadp
			
addthread_clra	clra	
newthreadp		staa	thread_priority
                jmp	newthread_sp
;****************************************************
;* Game Start - sets appropriate startup, A will have
;* 01 for 1 player game, and 02 for 2 player game.
;****************************************************
sw_1p_start		clra	
sw_2p_start		inca		
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
                bra	to_kill

jmp_cmosa		jmp	cmos_a


;*****************************************************
;* Slide Routines
;*****************************************************

ani_msg_starslide	
                jsr	copy_msg_full
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
                    ldaa	#$2B			; Right Arrow Character
                    staa	$00,X
                    SLEEP($02)
                    ldaa	#$2B
                    staa	$00,X
                    SLEEP($02)
                    decb	
                eqend
                pulb	
                pula	
                rts	


			
slide_r		    ldaa	$00,X
                anda	#$0F
                jsr	xplusa
                begin
                    ldab	$00,X
                    dex	
gb_0D				bsr	step_r
                eqend
                rts	

slide_l		    ldaa	$00,X
                anda	#$0F
                begin
                    inx	
                    ldab	$00,X
gb_0F				bsr	step_l
                eqend
                rts	

ani_msg_rlslide	bsr	gb_0E
                bsr	slide_l
                clrb	
gj_2E			ldaa	#$01
                bra	gb_0F

step_r		    psha	
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


;**********************************************
;* Shift Routines
;**********************************************
step_l		    psha	
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
                ldx	#alpha_b0-1
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

setup_msg_endptr	
                psha	
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
                ldaa	$00,X					;get first letter
                anda	#$0F
                begin
                    ldab	#$0C
                    psha	
                    inx	
                    stx	game_var_1
                    ldaa	$00,X
                    staa	alpha_b0+12
                    ldx	#alpha_b0+11
                    begin
                        SLEEP($01)
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
clr_alpha_set_b0	
                clrb	
                bra	clr_alpha_set_bx
clr_alpha_set_b1	
                ldab	#$7F
clr_alpha_set_bx	
                jsr	stab_all_alphmsk
                ldx	#alpha_b1
clr_next_12		clra	
                ldab	#$0C
                jmp	write_range

invert_alphamsk	ldab	dmask_p3
                comb	
                andb	#$7F
stab_all_alphmsk	
                stab	dmask_p3
                stab	dmask_p4
                rts
		
ani_spinner		psha	
                pshb	
                begin
                    ldaa	#$26
                    decb	
                    beq	pulab_rts
spin_rpt			staa	$00,X
                    SLEEP($02)
                    inca	
                    cmpa	#$2A
                neend
                bra	spin_rpt
		
						







sw_notused_1	jmp	killthread
high_score		rts		


sw_troll_1			
sw_gargoyle_bl	
sw_warlok_l		
sw_blknite_l		
sw_evilking_l	
sw_gargoyle_tl	
sw_demon_1		
sw_troll_2		
sw_demon_2		
sw_troll_3		
sw_demon_3		
sw_troll_4		
sw_demon_4		
sw_troll_5		
sw_demon_5		
sw_troll_6		
sw_demon_6		
sw_gargoyle_tr	
sw_warlok_r		
sw_blknight_r	
sw_evilking_r	
sw_gargoyle_br	KILL_


sw_spell		KILL_

sw_l_shooter		
sw_r_shooter	KILL_

	

gameover_entry	swi
                SOL_(BB_LEFT_FLASH_OFF,BB_RIGHT_FLASH_OFF,PF_TOP_FLASH_OFF,PF_BOT_FLASH_OFF,PF_CENTER_FLASH_OFF,GI_RELAY_PF_OFF,GI_RELAY_BB_OFF,BALL_LIFT_OFF)	
                SND_($18)				;Sound #18
go_loop		    RCLR0_(grp_alllamps)		;All lamps off buffer 0
                RCLR1_(grp_alllamps)		;All lamps off buffer 1
                PRI_($10)				;Priority=#10
                CPUX_
                jsr	start_attract
                clr	flag_tilt
                ldaa	#$01
                staa	game_ram_c
                begin
                    ldx	#msg_williams
                    jsr	ani_msg_letters
                    SLEEP($90)
                    ldx	#msg_electronics
                    jsr	ani_msg_letters
                    SLEEP($90)
                    ldx	#msg_presents
                    jsr	ani_msg_letters
                    SLEEP($90)
                    ldx	#msg_spellbinder
                    jsr	copy_msg_full
                    swi
                        BITON4_(bf_dispspkl)
                    CPUX_
                    ldaa	#$10
                    staa	sparkle_rate
                    SLEEP($40)
                    ldaa	#$30
                    staa	sparkle_rate
                    SLEEP($30)
                    ldaa	#$70
                    staa	sparkle_rate
                    SLEEP($30)
                    ldaa	#$f0
                    staa	sparkle_rate
                    SLEEP($20)
                    ldaa	#$f8
                    staa	sparkle_rate
                    SLEEP($30)
                    swi
                        BITOFF4_(bf_dispspkl)
                    CPUX_
                    SLEEP($30)
                    ldx	#msg_gameover
                    jsr	ani_msg_letters
                    SLEEP($C0)

                    ldx	#msg_destroy
                    jsr	copy_msg_full
                    SLEEP($80)
                    ldx	#msg_enemies
                    jsr	copy_msg_full
                    SLEEP($80)
                    ldx	#msg_battlethe
                    jsr	copy_msg_full
                    SLEEP($80)
                    ldx	#msg_dragon
                    jsr	copy_msg_full
                    SLEEP($80)
                    jsr	disp_hy_score
show_cred			swi
					BITOFF4_(bf_dispspkl)
					CPUX_
                    jsr	setup_msg_endptr
                    jsr	clr_alpha_set_b0
                    SLEEP($80)
                    ldx	#msg_credit
                    jsr	copy_msg_full
                    ldaa	current_credits
                    jsr	disp_num_a
                    dec	game_ram_c
                    beq 	go_attract
                    SLEEP($E0)
                loopend
                ;we are here for the timeout on the fancy attract
go_attract		swi
                REMTHREADS_($FF,$43)		;Remove Multiple Threads Based on Priority
                SOL_(GI_RELAY_PF_ON,GI_RELAY_BB_ON)	
                SND_($0E)				;Sound #19
                SLEEP_(4)
                EXE_
                    jsr gover_lamps
                EXEEND_
                SETRAM_(rega,0)
                BEGIN_
                    SOL_(PF_CENTER_FLASH_ON4)
                    SLEEP_(8)
                    ADDRAM_(rega,1)
                EQEND_($FC,$E0,5)
                SOL_(GI_RELAY_PF_OFF,GI_RELAY_BB_OFF)
                JMPR_(go_loop)
			
	
;disp_wave_num	ldaa	current_wave
disp_num_a		tab	
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

start_attract   NEWTHREAD(attract_dragon)
                NEWTHREAD(attract_bonus)
                NEWTHREAD(attract_sides)
                NEWTHREAD(attract_arrows)
                NEWTHREAD(attract_mult)
                NEWTHREAD(attract_axe)
                NEWTHREAD(attract_red)
                NEWTHREAD_JMP(attract_wiz)
	
;********************************************************
;* Dragon Attract
;********************************************************
attract_dragon	swi
                PRI_($43)				;Priority=#43
                BITON_(lamp_gargtl)			;Turn ON: lamp_500
                BEGIN_
                    BEGIN_
                        ADDRAM_(rega,$01)			;RAM$00+=$01
atd_loop			    BEQR_($FC,$FF,$E0,$01,$00,atd_1)	;BEQR_(LAMP#01(bip) & RAM$00)==#0 to at2_1
                    NEEND_(lamp_gargtl)    		;BEQR_BIT#26
                    RROL0_(grp_dragons)			
                    JMPR_(atd_2)			
atd_1			NEEND_(lamp_gargtr)		;BEQR_BIT#2A 
                RROR0_(grp_dragons)		;Effect: Range #06 Range #05
atd_2	        SLEEP_(4)
                JMPR_(atd_loop)
					
;********************************************************
;* Bonus Lamps Attract
;********************************************************
attract_bonus	swi
                PRI_($43)				;Priority=#43
                BITON_(lamp_500)			;Turn ON: lamp_500
                BITON_(lamp_extrawiz)
                BITON_(lamp_hand1)
                BITON_(lamp_hand2)
                BEGIN_
                    BEGIN_
                        ADDRAM_(rega,$01)			;RAM$00+=$01
atb_loop			    BEQR_($FC,$FF,$E0,$01,$00,atb_1)	;BEQR_(LAMP#01(bip) & RAM$00)==#0 to at2_1
                    NEEND_(lamp_500)    		;BEQR_BIT#26
                    RROL0_(grp_bonmult)		;Effect: Range #06 Range #05
                    JMPR_(atb_2)			
atb_1			NEEND_(lamp_5xu)			;BEQR_BIT#2A 
                RROR0_(grp_bonmult)		;Effect: Range #06 Range #05
atb_2			SLEEP_(4)
                BITINV_(lamp_extrawiz)
                RINV0_(grp_shield)
                JMPR_(atb_loop)
	
;********************************************************
;* Multiplier Lamps Attract
;********************************************************
attract_mult	swi
                PRI_($43)				;Priority=#43
                RCLR0_(grp_lowermult)
                BEGIN_
                    RSET1RC0_(grp_lowermult)
                    SLEEP_(16)
                LOOP_
			
;********************************************************
;* Axe Lamps Attract
;********************************************************
attract_axe		swi
                PRI_($43)				;Priority=#43
                RCLR0_(grp_axe)
                BEGIN_
                    RSET1RC0_(grp_axe)		
                    SLEEP_(8)
                LOOP_

			
;********************************************************
;* Red Lamps Attract
;********************************************************
attract_red		swi
                PRI_($43)				;Priority=#43
                BEGIN_
                    RCLR0_(grp_reds)
                    SLEEP_(8)
                    BITON_(lamp_red5)
                    SLEEP_(8)
                    BITON_(lamp_red4)
                    BITON_(lamp_red6)
                    SLEEP_(8)
                    BITON_(lamp_red3)
                    BITON_(lamp_red7)
                    SLEEP_(8)
                    BITON_(lamp_red2)
                    BITON_(lamp_red8)
                    SLEEP_(8)
                    BITON_(lamp_red1)
                    BITON_(lamp_red9)
                    SLEEP_(16)
                LOOP_
					
;**********************************************************
;* Wizard Lamp Attract
;**********************************************************	
attract_wiz		swi
                PRI_($43)				;Priority=#43
                BEGIN_
                    RCLR0_(grp_wizard)
                    BITON_(lamp_wiz1)			;Toggle: lamp_wiz1
                    SLEEP_(4)
                    SETRAM_(rega,$00)
                    BEGIN_
                        RROR0_(grp_wizard)				;Rotate Right Lamp Group
                        SLEEP_(4)
                        ADDRAM_(rega,$01)			;RAM$00+=$01
                    EQEND_($FC,$E0,24)
                    RCLR0_(grp_wizard)
                    SLEEP_(4)
                    SETRAM_(rega,$00)
                    BEGIN_
                        RINV0_(grp_wizard)
                        SLEEP_(4)
                        ADDRAM_(rega,$01)			;RAM$00+=$01
                    EQEND_($FC,$E0,10)
                LOOP_
			
;**********************************************************
;* Aarow Lamp Attract
;**********************************************************	
attract_arrows	swi
                PRI_($43)				;Priority=#43
                BEGIN_
                    RCLR0_(grp_seriesa)
                    SLEEP_(16)
                    SETRAM_(rega,$00)
                    BEGIN_
                        RINV0_(grp_seriesa)
                        SLEEP_(2)
                        ADDRAM_(rega,$01)			;RAM$00+=$01
                    EQEND_($FC,$E0,$10)
                LOOP_			
	
;**********************************************************
;* Side Enemy Attract
;**********************************************************	
attract_sides	swi
                PRI_($43)				;Priority=#43
                BITON_(lamp_troll1)			;Toggle: lamp_troll1
                BITON_(lamp_warlokr)			;Toggle: lamp_warlokr	
                BEGIN_
                    RROR0_(grp_leftside)		;Rotate Right Lamp Group Left Side
                    RROR0_(grp_rightside)		;Rotate Right Lamp Group Right Side
                    SLEEP_(6)
                LOOP_
					
gover_lamps		ldab	#$03
                begin
                    ldx  	#lampsweep-1
                    ldaa	#$05
                    jsr  	lampstr_on
                    SLEEP(2)
                        ldx  	#lampsweep-1
                        ldaa	#$05
                        jsr  	lampstr_off
                        SLEEP(2)
                        decb
                eqend
                rts
			
disp_hy_score	ldx	#msg_top_wizard
                jsr	ani_msg_letters
                ldaa	#$7F
                jsr	clr_dis_masks12
                jsr	show_hstd
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
                SLEEP($60)
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

sw_plumbtilt	BEQR_($FE,$F2,$FF,$C0,$10)	;BEQ_(BIT#80 P #FF) to tilt_kill
                EXE_($06)				;CPU Execute Next 6 Bytes
                ldx	#tilt_sleeper
                jsr	newthread_06
                SND_($15)				;Sound #15
                JSRD_(tilt_warning)		
                BEQR_($F0,$09)			;BEQ_TILT to game_tilt
                SOL_(GI_RELAY_PF_ON)		; Sol#6:gi_relay_pf
tilt_kill		KILL_					;Remove This Thread

tilt_sleeper	swi	
                PRI_($C0)				;Priority=#C0
                SLEEP_(24)
                KILL_					;Remove This Thread

game_tilt		SOL_(GI_RELAY_PF_ON)		; Sol#6:gi_relay_pf
                PRI_($A0)				;Priority=#A0
                REMTHREADS_($08,$00)		;Remove Multiple Threads Based on Priority
                JSRR_(clear_ui)			
                CPUX_					;Resume CPU Execution
                ldx	#msg_tilt
                jsr	copy_msg_full
                jsr	clr_alpha_set_b1
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
end_player		SOL_(GI_RELAY_PF_OFF,PF_CENTER_FLASH_OFF,BB_LEFT_FLASH_OFF,BB_RIGHT_FLASH_OFF)		
                PRI_($00)				;Priority=#00
                JSRDR_(save_playerdata)		
                JSRD_(update_commas)		
                JMPD_(outhole_main)
			
start_play		;do stuff here for gameplay
                swi
                RSET0_(grp_reds)		;Turn on all reds
                SLEEP_(90)
                BEGIN_
                    RCLR1L0_(grp_reds)
                    SLEEP_(30)
                EQEND_($F5,grp_reds)		
                ;when the player is out of reds, end the round
                JMPR_(end_player)

save_playerdata rts


clear_ui		JSRD_(clr_dis_masks)				
                EXE_			
                    inc	flag_tilt			;turn OFF the shooters 
                    ldab	player_up
                    jsr	saveplayertobuffer
                    ldab	player_up
                EXEEND_
                JSRD_(resetplayerdata)		
                MRTS_					;Macro RTS, Save MRA,MRB

lampstr_on		pshb
                begin
                    begin
                        inx  
                        ldab	$00,X
                        cmpb 	#$ff
                        beq	lampstr_rts
                        tba  
                        anda #$7F
                        stx  temp3
                        jsr  lamp_onx
                        tstb 
                    miend
                    SLEEP(2) 
                loopend
			
lampstr_rts		pulb
                rts

lampstr_off		pshb
                begin
                    begin
                        inx  
                        ldab	$00,X
                        cmpb 	#$ff
                        beq	lampstr_rts
                        tba  
                        anda #$7F
                        stx  temp3
                        jsr  lamp_offx
                        tstb 
                    miend
                    SLEEP(2)   
                loopend
		
lampsweep		.db lamp_2xl+$80
                .db lamp_3xl+$80
                .db lamp_5xl+$80
                .db lamp_troll1,lamp_demon6+$80
                .db lamp_red1,lamp_red2,lamp_red3,lamp_red4,lamp_red5,lamp_red6,lamp_red7,lamp_red8,lamp_red9,lamp_gargll,lamp_gargbr+$80
                .db lamp_hand1,lamp_axe1,lamp_axe2,lamp_axe3,lamp_axe4,lamp_axe5,lamp_axe6,lamp_axe7,lamp_axe8,lamp_axe9,lamp_hand2+$80
                .db lamp_warlokl,lamp_ekr+$80
                .db lamp_bkl,lamp_bkr,lamp_wiz1,lamp_wiz2,lamp_wiz3,lamp_wiz4,lamp_wiz5+$80
                .db lamp_ekl,lamp_warlokr+$80
                .db lamp_extrawiz,lamp_500,lamp_1k,lamp_2k,lamp_4k,lamp_8k,lamp_16k,lamp_32k,lamp_2xu,lamp_3xu,lamp_5xu+$80
                .db lamp_gargtla,lamp_demon1a,lamp_troll2a,lamp_demon2a,lamp_troll3a,lamp_demon3a,lamp_troll4a,lamp_demon4a,lamp_troll5a,lamp_demon5a,lamp_troll6a,lamp_gargtra+$80
                .db lamp_gargtl,lamp_demon1,lamp_troll2,lamp_demon2,lamp_troll3,lamp_demon3,lamp_troll4,lamp_demon4,lamp_troll5,lamp_demon5,lamp_troll6,lamp_gargtr+$80
                .db $ff

switchtable		.db sf_wml7+sf_enabled+swtype3 				        \.dw sw_plumbtilt   ;(1) plumbtilt
                .db sf_code+sf_tilt+sf_gameover+sf_enabled+swtype1	\.dw sw_2p_start	;(2) 2p_start
                .db sf_code+sf_tilt+sf_gameover+sf_enabled+swtype1	\.dw sw_1p_start	;(3) 1p_start
                .db sf_wml7+sf_tilt+sf_gameover+sf_enabled+swtype2	\.dw coin_accepted	;(4) coin_r
                .db sf_wml7+sf_tilt+sf_gameover+sf_enabled+swtype2	\.dw coin_accepted	;(5) coin_c
                .db sf_wml7+sf_tilt+sf_gameover+sf_enabled+swtype2	\.dw coin_accepted	;(6) coin_l
                .db sf_code+sf_tilt+sf_gameover+sf_enabled+swtype1	\.dw reset			;(7) slam
                .db sf_code+sf_tilt+sf_gameover+sf_enabled+swtype1	\.dw sw_hstd_res	;(8) hstd_res
                .db sf_wml7+sf_enabled+swtype1				        \.dw sw_troll_1		;(9) Troll #1
                .db sf_code+sf_disabled+swtype1				        \.dw sw_notused_1	;(10)
                .db sf_wml7+sf_enabled+swtype1				        \.dw sw_gargoyle_bl	;(11) Lower Left Gargoyle
                .db sf_wml7+sf_enabled+swtype1				        \.dw sw_warlok_l	;(12) Left Warlok
                .db sf_wml7+sf_enabled+swtype1				        \.dw sw_blknite_l	;(13) Left Black Knight
                .db sf_wml7+sf_enabled+swtype1				        \.dw sw_evilking_l	;(14) Left Evil King
                .db sf_wml7+sf_enabled+swtype1				        \.dw sw_gargoyle_tl	;(15) Top Left Gargoyle
                .db sf_wml7+sf_enabled+swtype7				        \.dw sw_demon_1		;(16) Demon #1
                .db sf_wml7+sf_enabled+swtype7				        \.dw sw_troll_2		;(17) Troll #2
                .db sf_wml7+sf_enabled+swtype7				        \.dw sw_demon_2		;(18) Demon #2
                .db sf_wml7+sf_enabled+swtype7				        \.dw sw_troll_3		;(19) Troll #3
                .db sf_wml7+sf_enabled+swtype7				        \.dw sw_demon_3		;(20) Demon #3
                .db sf_wml7+sf_enabled+swtype7				        \.dw sw_troll_4		;(21) Troll #4
                .db sf_wml7+sf_enabled+swtype7				        \.dw sw_demon_4		;(22) Demon #4
                .db sf_wml7+sf_enabled+swtype7				        \.dw sw_troll_5		;(23) Troll #5
                .db sf_wml7+sf_enabled+swtype7				        \.dw sw_demon_5		;(24) Demon #5
                .db sf_wml7+sf_enabled+swtype7				        \.dw sw_troll_6		;(25) Troll #6
                .db sf_wml7+sf_enabled+swtype7				        \.dw sw_demon_6		;(26) Demon #6
                .db sf_wml7+sf_enabled+swtype1				        \.dw sw_gargoyle_tr	;(27) Top Right Gargoyle
                .db sf_wml7+sf_enabled+swtype1				        \.dw sw_warlok_r	;(28) Right Warlok
                .db sf_wml7+sf_enabled+swtype1				        \.dw sw_blknight_r	;(29) Right Black Knight
                .db sf_wml7+sf_enabled+swtype1				        \.dw sw_evilking_r	;(30) Right Evil King
                .db sf_wml7+sf_enabled+swtype1				        \.dw sw_gargoyle_br	;(31) Bottom Right Gargoyle
                .db sf_wml7+sf_gameover+sf_enabled+swtype3	        \.dw sw_spell		;(32) Cast Spell
                .db sf_wml7+sf_enabled+swtype4				        \.dw sw_l_shooter	;(33) l_shooter
                .db sf_wml7+sf_enabled+swtype4				        \.dw sw_r_shooter	;(34) r_shooter
switchtable_end




lamptable		LAMPGROUP(grp_alllamps,lamp_wiz1,lamp_hand2)		;(00) all lamps
                LAMPGROUP(grp_wizard,lamp_wiz1,lamp_wiz5)			;(01) wizard lights
                LAMPGROUP(grp_lowermult,lamp_2xl,lamp_5xl)		    ;(02) lower multipliers
                LAMPGROUP(grp_leftside,lamp_troll1,lamp_ekl)		;(03) left side
                LAMPGROUP(grp_trip1,lamp_gargtl,lamp_troll2)		;(04) trip 1
                LAMPGROUP(grp_trip2,lamp_demon2,lamp_demon3)		;(05) trip 2
                LAMPGROUP(grp_trip3,lamp_troll4,lamp_troll5)		;(06) trip 3
                LAMPGROUP(grp_trip4,lamp_demon5,lamp_gargtr)		;(07) trip 4
                LAMPGROUP(grp_dragons,lamp_gargtl,lamp_gargtr)		;(08) Whole top series of lamsp
                LAMPGROUP(grp_rightside,lamp_warlokr,lamp_demon6)	;(09) right side
                LAMPGROUP(grp_allloop,lamp_troll1,lamp_demon6) 		;(0A) whole loop
                LAMPGROUP(grp_seriesa,lamp_gargtla,lamp_gargtra)	;(0B) A series
                LAMPGROUP(grp_seriesb,lamp_gargtlb,lamp_gargtra)	;(0C) B series
                LAMPGROUP(grp_bonus,lamp_500,lamp_32k)			    ;(0D) bonus
                LAMPGROUP(grp_uppermult,lamp_2xu,lamp_5xu)		    ;(0E) upper multipliers
                LAMPGROUP(grp_bonmult,lamp_500,lamp_5xu)			;(0F) bonus + multipliers
                LAMPGROUP(grp_reds,lamp_red1,lamp_red9)			    ;(10) red power lamps
                LAMPGROUP(grp_axe,lamp_axe1,lamp_axe9)			    ;(11) axe lamps
                LAMPGROUP(grp_shield,lamp_hand1,lamp_hand2)		    ;(12) hands
                LAMPGROUP(grp_axehands,lamp_axe1,lamp_hand2)		;(13) axe + hands


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

;*************************************************************
; Character Sprites
;
; J H F E  D C B A   X X N P  R M G K
;
;   ---a---
;  |\  |  /|
;  f h j k b
;  |  \|/  |
;   -g- -m-
;  |  /|\  |
;  e r p n c
;  |/  |  \|
;   ---d---
;
;*************************************************************

character_defs	.dw $0000   ;SPACE (00)
			.dw $3706	;A (01)
			.dw $8F14	;B (02)
			.dw $3900	;C (03)
			.dw $4F10	;D (04)
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
			.dw $3103	;P (10)
			.dw $3F20	;Q (11)
			.dw $3123	;R (12)
			.dw $4D04	;S (13)
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
			.dw $400A	;-> (2B)
			.dw $C03F	;* (2C)
			.dw $0025	;<- (2D)
			.dw $0800	;_ (2E)

msg_williams	.db $28,$17,$09,$0C,$0C,$09,$01,$0D,$13

msg_electronics	.db $0B,$05,$0C,$05,$03,$14,$12,$0F,$0E,$09,$03,$13

msg_presents	.db $28,$10,$12,$05,$13,$05,$0E,$14,$13

msg_spellbinder	.db $0C,$13,$10,$05,$0C,$0C,$02,$09,$0E,$04,$05,$12,$00

msg_credit		.db $17,$03,$12,$05,$04,$09,$14,$13

msg_gameover	.db $0C,$00,$07,$01,$0D,$05,$00,$00,$0F,$16,$05,$12,$00

msg_player		.db $26,$10,$0C,$01,$19,$05,$12

msg_boom		.db $04,$02,$0F,$0F,$0D

msg_destroy		.db $27,$04,$05,$13,$14,$12,$0F,$19

msg_enemies		.db $27,$05,$0E,$05,$0D,$09,$05,$13

msg_battlethe	.db $1A,$02,$01,$14,$14,$0C,$05,$00,$14,$08,$05

msg_dragon		.db $36,$04,$12,$01,$07,$0F,$0E

msg_top_wizard	.db $1A,$14,$0F,$10,$00,$17,$09,$1A,$01,$12,$04

msg_defhs		.db $2C,$00,$00,$2C,$0D,$08,$01,$16,$0F,$03,$2C,$00,$00

msg_tilt		.db $28,$2C,$00,$14,$09,$0C,$14,$00,$2C


;*****************************************************************************
;* Williams Spellbinder System Code
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
	;.org $E730



;**************************************
;* Main Entry from Reset
;**************************************
reset		sei	
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
	
csum1	    .db $C0 	 


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
clear_all		jsr	factory_zeroaudits		;Restore Factory Settings and Zero Audit Totals
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
			;deca
			;staa	p2_ec_b0
			;staa	p1_ec_b0
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
main		ldx	#vm_base
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
checkswitch	ldx	#0000
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
time		ldab	flag_timer_bip			;Ball Timer Flag
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
switches	ldx	#switch_queue
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
sw_break		inx	
				inx	
				bra	next_sw
			endif
;Entry here if we are in auto-cycle mode...						
vm_irqcheck	ldx	vm_base				;Check the start of the vm loop
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
flashlamp	ldaa	lamp_flash_count		;Timer for Flashing Lamps
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
solq		ldaa	solenoid_counter			;Solenoid Counter
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
snd_queue	ldaa	sys_soundflags			;Sound Flag??
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
_sndnext		ldab	next_sndcnt			;Here if we are done iterating the sound command.
				ifne			;Check the scoring queue
					ldaa	next_sndcmd
					jsr	isnd_mult			;Play Sound Index(A),(B)Times
					clr	next_sndcnt
					bra	check_threads		;Get Outta Here.
				endif
			endif
doscoreq	clr	sys_soundflags		;Reset the Sound Flag??
			ldx	#$1127			;See if there is something in this stack
			ldaa	#$08
			begin
				inx	
				deca	
				bmi	check_threads		;Nuttin' Honey, Skip this Sound Crap!
				ldab	$00,X
			neend					;Nuttin' Honey, Check next Entry!
			dec	$00,X				;Re-Adjust the Sound Command So Sound #00 will still work!
			oraa #$08
			jsr	dsnd_pts			;Add Points(A),Play Digit Sound

check_threads	
            ldx	#vm_base
			begin
nextthread		ldx	$00,X				;Check to see if we have a routine to do?
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
delaythread	staa	temp2				;Routine returns here when done
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
addthread	stx	temp1
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
dump_thread	stx	temp3				;Now X points the the replacement address
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
newthread_sp
            stx	temp1
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

newthread_06	
            psha	
			ldaa	#$06
			staa	thread_priority
			pula	
			bra	newthread_sp			;Push VM: Data in A,B,X,threadpriority,$A6,$A7

;***************************************************************************
;* This will remove the current thread from the VM. 
;*
;* Requires: temp2 holds the thread that points to the thread to be killed	
;***************************************************************************		
killthread_sp	
            psha	
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
kill_thread	bsr	check_threadid		;Test Thread ID Mask
			ifcc					;Return with Carry Set
				bsr	killthread_sp		;Remove Entry (X)($B1) From VM
				clc	
			endif
			rts

;*************************************************
;* Kill All threads with the given ID
;*
;* Requires:   A - EOR Mask Definition	
;*             B - AND Mask Definition		
;* 
;* If result is not zero, then thread is killed
;*************************************************
kill_threads
            begin
				bsr	kill_thread		;Kill first One
			csend				;Repeat if Carry Clear
			rts

;*************************************************
;* Checks the VM thread list for threads that 
;* qualify agains the bitmasks defined in A and B.
;* If a thread qualifies, then this routine will
;* return with carry cleared.
;*************************************************		
check_threadid	
            pshb	
			stab	temp1
			ldx	#vm_base		;Load Start Address
			stx	temp2			;Store it
			ldx	vm_base		;Load End Address
pri_next	sec	
			ifne				;Branch if we have reached the end of the VM (Next = 0000)
				tab	
				eorb	threadobj_id,X		;EOR with Type Code in Current Routine
				comb	
				andb	temp1
				cmpb	temp1
				ifne				;Branch if Bits Dont work
pri_skipme			stx	temp2
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
_sb01				staa	$00,X				;Insert Solenoid Into Buffer
					inx	
					stx	solenoid_queue_pointer	;Update Pointer
_sb02				clc					;Carry Cleared on Buffer Add
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
set_solenoid	
            pshb	
			tab	
			andb	#$F0
			ifne
				cmpb	#$F0
				ifne
					;1-15 goes into counter
set_sol_counter		stab	solenoid_counter		;Restore Solenoid Counter to #E0
					bsr	soladdr			;Get Solenoid PIA address and bitpos
					stx	solenoid_address
					stab	solenoid_bitpos
				else
					;Do it now... if at 0
					bsr	soladdr			;Get Solenoid PIA address and bitpos
				endif
				bcs	set_ss_on			;Carry Set: Special Solenoid, these work in reverse
				;Here to turn solenoid ON
set_ss_off		sei	
				orab	$00,X
set_s_pia		stab	$00,X			;Write Solenoid Data to PIA
				cli	
				pulb	
				rts					;Outta here!
			endif
			bsr	soladdr				;Get Solenoid PIA address and bitpos
			bcs	set_ss_off				;Special Solenoids work in reverse
			;Here to turn solenoid OFF			
set_ss_on	comb	
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
hex2bitpos	psha	
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

update_commas	
            ldab	#$40				;Million digit
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
set_comma_bit		ldaa	player_up				;Current Player Up (0-3)
					jsr	xplusa				;X = X + A
					ldaa	$00,X
					oraa	comma_flags
					staa	comma_flags
				endif
			endif
			rts	
			

test_mask_b	ldaa	player_up				;Current Player Up (0-1)
			ldx	#dmask_p1
			jsr	xplusa				;X = X + A
			bitb	$00,X
			rts	


;**********************************************************
;* Point based sounds (chime type).
;**********************************************************			
isnd_pts	psha	
			tba	
			bra	snd_pts
dsnd_pts	psha	
			anda	#$07
snd_pts		jsr	isnd_once			;Play Sound Index(A) Once
			pula
			;Fall Through to points 

score_main	psha	
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
score_update	
            ldx	pscore_buf			;Start of Current Player Score Buffer
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
_su01		bne	    _su04
			incb	
			stab	temp3				;Store (data&07)+1
_su02		ldab	sys_temp3
			lsrb	
			lsrb	
			lsrb	
			bsr	score2hex			;Convert MSD Blanks to 0's on (X+03)
			begin
				adda	temp3				;(data&07)+1
				bsr	hex2dec			;Decimal Adjust A, sys_temp2 incremented if A flipped
				decb					
			eqend
_su03		ldab	sys_temp2
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
_su04			decb	
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
_su05			ldab	sys_temp4
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

score2hex	ldaa	$03,X
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
add_points	psha	
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
checkreplay	ldx	#x_temp_2
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
get_hs_digits	
            ldaa	$00,X
			anda	#$0F
			ldab	$01,X
			bsr	b_plus10		;If B minus then B = B + 0x10
			bsr	split_ab		;Shift A<<4 B>>4
			aba	
			tab
b_plus10	cmpb	#$A0
			ifcc
				addb	#$10
			endif
			rts	
			
;*********************************************************
;* Shifts A and B to convert million and hundred thousand
;* score digits into a single byte.
;*********************************************************
split_ab	asla	
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
isnd_once	pshb	
			ldab	#$01
			bsr	sound_sub
			pulb	
			rts

;*********************************************************
;* This is the main sound subroutine. It will play index
;* sound contained in A, B times.
;*********************************************************				
sound_sub	stx	thread_priority
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
b_050		tsta	
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
			
isnd_test	psha	
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
isnd_mult	stx	thread_priority
b_051		psha	
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
isnd_mult_x	jsr	xplusa				;X = X + A
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
snd_exit_pull	
            pulb	
			pula	
snd_exit	ldx	thread_priority
			rts	

;*****************************************************************
;* Send the command to the sound board, stores the command sent
;* in 'lastsound' for reference.
;*****************************************************************			
send_snd_save	
            staa	lastsound
send_snd	jsr	    gr_sound_event			
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
sw_down		    jsr	sw_tbl_lookup		;Loads X with pointer to switch table entry
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
sw_proc		    ldx	sys_temp1
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
xplusa		    psha	
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
xplusb		    psha	
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
clr_ram		    begin
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
                ldab  irq_counter
                dec   randomseed
                rorb  			;lamp strobe is changed every other irq_counter
                ifcc
                    inc   lamp_index_wordx
                    ldaa  cur_lampstrobe
                    asla  
                    ifeq				;if strobes have cycled, then reset everything
                        staa   lamp_index_wordx
                        staa   irq_counter
                        staa   alpha_digit_cur+1
                        inca  			;reset strobe to $01 and start again
                    endif
                    staa   cur_lampstrobe
                endif
                ldx   lamp_index_word
                ldab   irq_counter
                andb  #$07
                ifeq				;every 8th, blank the displays
                    ldaa  #$FF
                    staa  pia_disp_seg_data
                    clr	pia_alphanum_segl_data
                    clr   pia_alphanum_segh_data
                    ldab  irq_counter
                    stab  pia_disp_digit_data
                    beq   b_082
                    jmp   skip_lots
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

                asl	sparkle_rate
                ifcs
                    ldaa	sparkle_rate
                    oraa	#$01
                    staa	sparkle_rate
                endif				
                
                ldaa  comma_flags
                staa  comma_data_temp
                ldaa  dmask_p1
                staa  credp1p2_bufferselect
                ldaa  dmask_p3
                staa  alpha_bufferselect
                ;ldab  p2_ec_b0
                ;rol   credp1p2_bufferselect
                ;ifcs
                ;	ldab   p2_ec_b1
                ;endif
                ;ldaa  p1_ec_b0
                ;rol   alpha_bufferselect
                ;bcc   b_083
                ;ldaa  p1_ec_b1
                bra   b_083

			;***********************************
			;* Sound command clear
			;***********************************
snd_wr0		    ldab  pia_comma_data
                andb  #$3F
snd_wr		    stab  pia_comma_data

			;************************************
			;* Display Routines
			;************************************
			;reset displays
                clr   pia_alphanum_segl_data
                clr   pia_alphanum_segh_data
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
                    jsr	sparkleb
                    stab   pia_alphanum_segl_data	;write character data
                    ldab   $01,X
                    bita  #$80
                    ifne
                        orab   #$40
                    endif
                    bita  #$40
                    ifne   
                        orab   #$80
                    endif
                    jsr	sparkleb
                    stab   pia_alphanum_segh_data	;write comma/dot data
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
                    bra	disp_save					;save it now to PIA
skip_lots			ldaa	dmask_p2
                    staa	credp1p2_bufferselect
                    ldaa	dmask_p4
                    staa	alpha_bufferselect
                    ;ldab	p2_ec_b0
                    rol	credp1p2_bufferselect
                    ;ifcs
                    ;	ldab	p2_ec_b1
                    ;endif
                    ;ldaa	p1_ec_b0
                    rol	alpha_bufferselect
                    ;ifcs
                    ;	ldaa	p1_ec_b1
                    ;endif
                endif
                asla						;Show AB
                asla	
                asla	
                asla	
                andb	#$0F					;Fall through to end
disp_save		aba	
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
                    ldaa	cur_lampstrobe			;Which strobe are we on
                    staa	$02,X					;Put the strobe out there
                    cmpa	$02,X					;Did it take?
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
                ;* Done with Lamps
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
                asl	    pia_switch_strobe_data		;Shift to Next Column Drive
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
                asl	    pia_switch_strobe_data		;Shift to Next Column Drive
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
irq_sol		    ldaa	solenoid_counter			;Solenoid Counter
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

sparkleb		pshb
                ldab 	 bitflags
                asrb
                pulb
                ifcs
                    ;sparkle is on. modify b
                    andb	sparkle_rate
                endif
                rts

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
lamp_on		    stx	temp3
lamp_onx		ldx	#lampbuffer0			;Set up correct index to lampbuffer
lamp_or		    pshb	
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
lamp_offx		ldx	#lampbuffer0
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
				
bsel_on		    stx	temp3
                ldx	#lampbufferselect
                bra	lamp_or

bsel_off		stx	temp3
                ldx	#lampbufferselect
                bra	lamp_and

bsel_invert	    stx	temp3
                ldx	#lampbufferselect
                bra	lamp_eor

lamp_on_1		stx	temp3
lamp_on_1x		ldx	#lampbuffer1
                bra	lamp_or

lamp_off_1		stx	temp3
lamp_off_1x		ldx	#lampbuffer1
                bra	lamp_and

lamp_invert_1	stx	temp3
                ldx	#lampbuffer1
                bra	lamp_eor
			
bit_on		    stx	temp3
                ldx	#bitflags
                bra	lamp_or

bit_off		    stx	temp3
                ldx	#bitflags
                bra	lamp_and

bit_invert		stx	temp3
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
lampm_f		    bsr	lampr_start				;A=Current State,B=Bitpos,X=Lamp Byte Postion
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
lampm_a		    bsr	lampr_start				;A=Current State,B=Bitpos,X=Lamp Byte Postion
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
lampm_b		    bsr	lampr_start				;A=Current State,B=Bitpos,X=Lamp Byte Postion
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
abx_ret		    ldaa	sys_temp1
                ldab	sys_temp2
                ldx	temp3
                rts	 

;************************************************************
;* Lamp Group Routines: This take care of manipulating
;*                      a collection of sequential lamps
;*                      to create various lighting effects.
;************************************************************
;* Loads the Lamp Group data
;*
;* sys_temp3 = start lamp
;* sys_temp4 = end lamp
;* A = XX-YYYYY: XX = Buffer Selection, YYYYY = Lamp Group
;* B = Bitpos
;* X = Selected Buffer Address
;*
;************************************			
lampr_start		jsr	lampr_setup				;Set up Lamp: $A2=start $A3=last B=Bitpos X=Buffer
                ldaa	sys_temp3				;Starting lamp in range
lr_ret		    jsr	unpack_byte				;(X = X + A>>3), B = (bitpos(A&07))
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
                ldx	$00,X					;Get the start lamp
                stx	sys_temp3				;Save Lamp Range
                ldx	#lampbuffers			;Lamp Buffer Locations, shifts bits 6+7 around into 1+2
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
ls_ret		    ldaa	temp1				;load up the original lamp counter until end lamp
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
lampm_c		    bsr	lampr_end				;A=Current State,B=Bitpos,X=Lamp Byte Postion
lm_test		    ifeq
                    bsr	lamp_right				;Shift Lamp Bit Right, De-increment Lamp Counter, Write it
                    bcc	lm_test
                    bra	abx_ret
                endif
                comb	
                andb	$00,X
                stab	$00,X
                bra	abx_ret

;Rotate Up			
lampm_e		    bsr	lampr_start				;A=Current State,B=Bitpos,X=Lamp Byte Postion
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
lampm_d		    bsr	lampr_end				;A = Last Lamp Level, B = Last Lamp BitPos
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

lampm_z		    jsr	lampr_end				;A = Last Lamp Level, B = Last Lamp BitPos
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

lfill_a		    jsr	lampr_start				;A=Current State,B=Bitpos,X=Lamp Byte Postion
b_0AB			ifne
                    jsr	lamp_left				;Shift Lamp Bit Left, De-increment Lamp Counter, Write it
                    bcc	b_0AB
                    bra	to_abx_ret
                endif
lmp_clc		    clc	
                bra	to_abx_ret

lfill_b		    jsr	lampr_start				;A=Current State,B=Bitpos,X=Lamp Byte Postion
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
bit_flags	    ldx	#bitflags
                bra	bit_main
bit_lamp_buf_0	ldx	#lampbuffer0
bit_main		jsr	unpack_byte				;(X = X + A>>3), B = (bitpos(A&07))
                bitb	$00,X
                rts	

lampm_x		    anda	#$3F
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
                .dw bsel_on
                .dw bsel_off
                .dw bsel_invert

vm_lookup_dx_l
                .dw lamp_on_1
                .dw lamp_off_1
                .dw lamp_invert_1

vm_lookup_dx_h
                .dw bit_on
                .dw bit_off
                .dw bit_invert

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
                .dw branch_tilt		    ;Tilt Flag				
                .dw branch_gameover     ;Game Over Flag			
                .dw macro_getnextbyte	;NextByte = Straight Data		
                .dw branch_invert		;Invert Result			
                .dw branch_lamp_on	    ;Check if Lamp is On or Flashing
                .dw branch_lamprangeoff	;Lamp Range All Off			
                .dw branch_lamprangeon	;Lamp Range All On			
                .dw branch_lampbuf1	    ;RAM Matrix $0028			
                .dw branch_switch		;Check Encoded Switch		
                .dw branch_add		    ;A = A + B				
                .dw branch_and		    ;Logical AND 				
                .dw branch_or		    ;Logical OR 				
                .dw branch_equal		;A = B ??				
                .dw branch_ge		    ;A >= B ??				
                .dw branch_threadpri	;Check for Priority Thread??	
                .dw branch_bitwise	    ;A && B	

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
			
macro_pcminus100	
                ldx	vm_pc
                dex	
                stx	vm_pc
                bra	macro_go

macro_code_start	
                ldx	vm_pc
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
			
vm_control_dx	ldx   #vm_lookup_dx_l
                tab   
                andb  #$0F
                subb  #$08
                bcs   macro_x17
                ldx   #vm_lookup_dx_h
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
dly_sto		    staa	thread_timer_byte
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
pc_sto2		    stx	vm_pc
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
ret_sto		    ldaa	vm_pc+1
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
pc_sto		    stx	vm_pc					;Store X into VMPC
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
ram_sto		    bsr	macro_a_ram				;A->RAM(B&0f)
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

macro_clearswitch	
                bsr	load_sw_no				;Get switch number from the data
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
                ldx	#adj_gamebase			;Pointer to Bottom of Game Adjustments
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
                beq	branch_bitflag
                ldx	#branch_lookup
                jsr	gettabledata_w			;X = data at (X + LSD(A)*2)
                ldaa	temp1
                jmp	$00,X

branch_invert	bsr	test_a
                eora	#$01
to_rts3		    rts	

branch_lamp_on	jsr	bit_lamp_buf_0			;Bit Test B with Lamp Data (A)
                bne	ret_true				;return true
                jsr	bit_lamp_flash			;Check Encoded #(A) with $0030
test_z		    bne	ret_true				;return true
                bra	ret_false				;return false
			
branch_lamprangeoff	
                jsr	lfill_b
test_c		    bcs	ret_true				;return true
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


branch_bitflag	ldaa  temp1					;Check Encoded #(A) with bitflags
                jsr   bit_flags
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

branch_threadpri	
                jsr	check_threadid
                bcc	ret_true				;lda  #$81, rts
                bra	ret_false				;lda  #$80, rts
			
branch_bitwise	stab	temp1
                anda	temp1
to_rts4		    rts	

set_logic		psha	
                tba	
                bsr	test_a
                staa	temp1
                pula	
test_a		    tsta	
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
eb_rts		    pula	
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
creditq		    ldx	#aud_currentcredits		;CMOS: Current Credits
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
                ;Starts with macro
                JSRR_(do_coin)	;MJSR $F7A7
                jmp	killthread
			
do_coin		    PRI_($0E) 		;Set this loops priority to #0E
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
dec2hex		    psha	
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
write_range		begin
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
                ;deca
                ;staa	p1_ec_b0
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
                ldx	#adj_wizardspergame
                jsr	cmosinc_a			
                tstb
                ifne
                    staa	p2_wizards
                else
                    staa	p1_wizards
                endif
ap_shft		    aslb
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
                ldx	#bitflags				;Clear all bitflags
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
init_player_game	
                psha	
                pshb	
                bsr	setplayerbuffer			;Set up the Pointer to the Players Buffer
                bsr	copyplayerdata			;Copy Default Player Data into Player Buffer (X)
                ldx	temp1
                ldab	#$06
                bsr	clear_range				;Clear Temp vars temp1,temp2,temp3
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
                ldx   #p1_wizards
                ldab   player_up
                ifne
                    ldx   #p2_wizards
                endif
                ldaa   $00,X
                ;ifmi
                ;	anda  #0F
                ;endif
                deca
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
                jsr	solbuf				;Turn on Solenoid $09 (Ball Lift)
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
dump_score_queue	
                ldx	#score_queue
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
                swi			;Start Executing Macros
                SLEEP_(1)        				;Delay 1
                BEQR_($FE,$01,$01,$FA)	 		;Branch if Priority #01 to $F9B0
                REMTHREADS_($0A,$00)			;Reset Threads Based on Priority #0A	
                CPUX_ 					;Resume CPU Execution
                ldx  	gr_outhole_ptr			;Game ROM: Pointer
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
                    ldaa   p2_wizards
                    ;cmpa  #$00
                    bne   badj_rts
badj_p2		        bsr   chk_p1
                    bne   badj_loop
                    cmpa  p2_wizards
                    bne   badj_loop
                else
                    bsr   chk_p1
                    ifne
                        rts 
chk_p1			        ldaa   p1_wizards
                        ;cmpa  #$F0
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
                        rts  				;all done, return
                    endif
                endif
                ;fall through on game over
gameover		jsr   gr_gameover_event
                ldx   #lampflashflag
                ldab  #$0C
                jsr   clear_range
                bra   check_hstd

endgame		    ldaa  gr_gameoversound
                jsr   isnd_once
                ;fall through to init

powerup_init	ldaa	gr_gameover_lamp			;Game ROM: Game Over Lamp Location
                swi	
                SOL_($09)				;Turn Off Solenoid: Shooter/BallLift Disabled
                BITFLP_($00) 			;Flash Lamp: Lamp Locatation at RAM $00
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
hstd_nextp			    dec	sys_temp1				;Goto Next Player
                    eqend						;Loop for all 4 Players
                    ldaa	sys_temp2
                    ifne
                        ldx	gr_highscore_ptr			;Game ROM Data: High Score Hook
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
to_rts1		    rts	
			
;**************************************************
;* This routine will fill the value of A into all
;* high score digit data.
;**************************************************
fill_hstd_digits	
                ldx	#aud_currenthstd			;CMOS: Current HSTD
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
to_rts2		    rts

;********************************************************
;* Credit Button Press: Called twice for 2-player game
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
                    ldab	num_players				;Current # of Players
                    cmpb	gr_numplayers			;Max # of Players (Game ROM data)
                    ifcs						;Already max players, outta here.
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
do_tilt		    ldaa	gr_tilt_lamp			;Game ROM: Tilt Lamp Location
                staa	flag_tilt				;Tilt Flag
                swi
                ;BITONP_($00) 		;Turn on Tilt Lamp - but we don't have a tilt lamp in SB
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
testlists		.db $00		    ;Function 00:    Game Identification
                .dw fn_gameid	;$FD,$23
                .db $01		    ;Function 01-11: System Audits
                .dw fn_sysaud	;$FD,$30
                .db $0C		    ;Function 12:    Current HSTD
                .dw fn_hstd		;$FD,$A9
                .db $0D		    ;Function 13-17: Backup HSTD and Replays
                .dw fn_replay	;$FD,$B1
                .db $12		    ;Function 18:    Max Credits
                .dw fn_credit	;$FE,$26
                .db $13		    ;Function 19:    Pricing Control
                .dw fn_pricec	;$FD,$EF
                .db $14		    ;Function 20-25: Pricing Settings
                .dw fn_prices	;$FE,$09
                .db $1A		    ;Function 26-41: System and Game Adjustments
                .dw fn_adj		;$FE,$33
                .db $2A		    ;Function 42-49: Game Audits
                .dw fn_gameaud	;$FD,$2E
                .db $32		    ;Function 50:    Command Mode
                .dw fn_command	;$FE,$3E
                .db $33

;************************************************
;* Main Self-Test Routine
;************************************************
test_number     =	$000e			;RAM Location to store where we are...
test_lamptimer  =	$000f			;Timer for Lamp test loop

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
                stab	score_p2_b0				;Show the test number in display
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
do_aumd		    psha	
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
st_init		    clrb	
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
do_audadj		clr	score_p1_b0
                ldaa	#$04					;Show test 04 by default
                staa	score_p2_b0
                SLEEP($10)
                begin
                    jsr	clear_displays			;Blank all Player Displays (buffer 0)
                    bsr	b_129					;#08 -> $0F
                    ldab	score_p1_b0
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
                adda	score_p1_b0				;Change it
                daa	
                cmpa	#$51					;Are we now on audit 51??
                beq	st_reset				;Yes, Blank displays, reboot game
                cmpa	#$99					;Going down, are we minus now??
                ifeq
                    ldaa	#$50					;Yes, wrap around to 50
                endif
                staa	score_p1_b0				;Store new value
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
                staa	score_p1_b0
                staa	score_p2_b0
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

fn_hstd		    jsr	show_hstd				;Puts HSTD in All Player Displays(Buffer 1)
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

cmos_a		    jsr	cmosinc_a				;CMOS,X++ -> A
fn_ret		    dex	
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

fn_adj		    ldx	#adj_matchenable			;RAM Pointer Base
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
                    staa	score_p1_b0				;Match/Ball in Play Display = 00
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
                        inc	score_p1_b0				;Increment Match/Ball in Play Display
                        asla	
                        inca	
                    plend
                    ldab	flags_selftest
                miend					;Start Over
                rts

;****************************************************
;* Main Lamp Routine - Flashes all lamps 
;****************************************************			
st_lamp		    ldab	#$AA
                stab	score_p1_b0				;Match/Ball in Play Display Buffer 0
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
                    clr  	score_p2_b0
                    bsr  	st_sound
                    inc  	score_p2_b0
                    bsr  	st_lamp
                    inc  	score_p2_b0
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
                    stab 	score_p1_b0	 
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
                        inc	score_p1_b0
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
                    staa  score_p1_b0
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
st_dosw			    ldaa	$00,X
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
                    staa  score_p1_b0
                    clra  
                    jsr   isnd_once
                    pula  
                    SLEEP($40)
st_swe			    deca  
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
rambad		    ldab	#$20
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
	.org $fff8
	
irq_entry		.dw gr_irq_entry	;Goes to Game ROM
swi_entry		.dw gr_swi_entry	;Goes to Game ROM 
nmi_entry		.dw diag
res_entry		.dw reset

	.end

