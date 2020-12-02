;--------------------------------------------------------------
;Jungle Lord Game ROM Disassembly
;Dumped by Pinbuilder ©2000-2005 Jess M. Askey
;--------------------------------------------------------------
#include  "68logic.asm"	;680X logic definitions
#include  "level7.exp"	;Level 7 system defines
#include  "wvm7.asm"	;Level 7 macro defines
#include  "7gen.asm"	;Level 7 general defines
;--------------------------------------------------------------
; GAME RAM Locations:
;
; $02 - Last Random Drop Target
; $03 - Not Used?
; $04 - Not Used?
; $05 - Not Used?
; $06 - Not Used?
; $07 - Not Used?
; $08 - Outhole Bonus Delay Value
; $09 - Not Used?
; $0a - Current Timer Value for display
; $0b - Background Sound Flag (00=constant,01=increment)
; $0c - GI Counter
; $0d - Temp holder for Multiball timer animation
; $0e	- Bell Counter
; $0f - Buzzer Counter
;--------------------------------------------------
; Extra RAM Locations Used:
; 
; $00E0: Double Trouble Value ($00,$01,$02,$04,$08,$16)
; $00E1: Comma Flags Temp Holder
;
;
;--------------------------------------------------
; Game Bit Definitions:
; 1.1(00) - Set when game is in multiball fancy display
; 1.2(01) - Set when lock is lit?
; 1.3(02)
; 1.4(03)
; 1.5(04) - Not Used?
; 1.6(05) - Not Used?
; 1.7(06) - Not Used?
; 1.8(07) - Not Used?
; 2.1(08) - Not Used?
; 2.2(09) - Not Used?
; 2.3(0A) - Not Used?
; 2.4(0B) - Not Used?
; 2.5(0C) - Not Used?
; 2.6(0D) - Not Used?
; 2.7(0E) - Not Used?
; 2.8(0F) - Game Play Disable: This is set when a player is being initialized
; 3.1(10)
; 3.2(11) - Tilt Timer: Set for 2.5 seconds after a plumb bob tilt
; 3.3(12) - Double Trouble: Set when player has double trouble lit
; 3.4(13) - Mini Playfied: Set when the Mini-PF is active
; 3.5(14) - Eject Hole Bit: Set for upper eject, clear for lower eject
; 3.6(15) - Outhole: Set when ball enters outhole, cleared when ejected to shooter
; 3.7(16)
; 3.8(17)
; 4.1(18)
; 4.2(19)
; 4.3(1A) - Lower Loop Switch: This bit is set for a number of cycles looking for the upper loop
; 4.4(1B) - Upper Loop Switch: This bit is set for a number of cycles looking for the lower loop
; 4.5(1C)
; 4.6(1D)
; 4.7(1E) - Playfield Entry Flag
; 4.8(1F) - Multiball Flag: Set when two balls are in play?
; 5.1(20) - Replay has been awarded if set
; 5.2(21)
; 5.3(22) - Fancy Bell Active
; 5.4(23)
; 5.5(24)
; 5.6(25)
; 5.7(26)
; 5.8(27) - Set when timer counting down
; 6.1(28)
; 6.2(29)
; 6.3(2A)
; 6.4(2B)
; 6.5(2C)
; 6.6(2D) - Left Magnet Active
; 6.7(2E) - Right Magnet Active
; 6.8(2F)
; 7.1(30)
; 7.2(31)
; 7.3(32)
; 7.4(33)
; 7.5(34)
; 7.6(35)
; 7.7(36)
; 7.8(37)
; 8.1(38)
; 8.2(39)
; 8.3(3A)
; 8.4(3B)
; 8.5(3C)
; 8.6(3D)
; 8.7(3E)
; 8.8(3F)
;
;*************************************
;* Thread ID's
;*************************************
;* $05 - Fancy Bell, DT Switches
;* $09 - Magnet Threads
;* $30 - Upper Drop Target
;* $43 - Attract Mode
;* $60 - Lock Lit
;* $E0 - Backgroud Sound
;*
;*
;*
;*************************************
;* Define Our Solenoids and the
;* time they should be on for each
;* trigger.
;*************************************
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
;******************************************************

	.org $d800

;******************************************************
;* FancyBell - This is the ring pattern that jungle 
;*             Lord plays on replays. It is the standard
;*             
;*             Shave-and-a-hair-cut
;*
;*             pattern...
;******************************************************
fancybell		jsr	macro_start
			PRI_($05)				;Priority=#05
			IFNER_($FC,$FF,$D8,$F2,$F0,$00)	;BEQR_(#F0 & ADJ#8)==#0 
				SOL_(bell_on_short)	      ;Turn ON Sol#15:bell
			ENDIF_
			BITON_($E0,$62)			;Turn ON: Bit#20, Bit#22
			JSRR_(gi_bell_long)		
			JSRR_(gi_bell_long)		
			JSRR_(gi_bell_short)		
			JSRR_(gi_bell_long)		
			JSRR_(gi_bell_long)		
			SLEEP_(24)
			JSRR_(buzz_on_inc)			
			SLEEP_(12)
			JSRR_(buzz_off_dec)			
			SLEEP_(8)
			JSRR_(buzz_on_inc)			
			SLEEP_(12)
			JSRR_(buzz_off_dec)			
			BITOFF_($62)			;Turn OFF: Bit#22
			SSND_($11)				;Sound #11
			KILL_					;Remove This Thread

gi_bell_long	JSRR_(gi_off_inc)			
			JSRR_(bell_on_inc)		
			SLEEP_(12)
gi_bell_com		JSRR_(bell_off_dec)		
			JSRR_(gi_on_dec)			
			SLEEP_(6)
			MRTS_					;Macro RTS, Save MRA,MRB

gi_bell_short	JSRR_(gi_off_inc)			
			JSRR_(bell_on_inc)		
			SLEEP_(6)
			JMPR_(gi_bell_com)

;******************************************************
;* System Coin Accepted Hook - This will ring the bell
;*                             if bit29 is 0
;******************************************************					
hook_coin		jsr	macro_start		
			IFEQR_($69)                   ;BNER_BIT#29
			      SOL_(bell_on_short)		;Turn ON Sol#15:bell
			      SLEEP_(20)
			ENDIF_			
                  CPUX_					;Resume CPU Execution
			rts	

;********************************************************
;* Outlane Switches:
;********************************************************			
sw_leftdrain
sw_rightdrain	PTSDIG_(5,1000)			;5000 Points/Digit Sound
			SETRAM_(regb,$02)			;RAM$01=$02
			JSRR_(add_bonus_dly)			
			IFEQR_($E0)			      ;BNER_RAM$00
      			BITOFFP_(rega)			;Turn OFF Lamp/Bit @RAM:00
      			EXE_
      			      ldx	#aud_game3			;Increment Drain Shield Counter
      			      jsr	ptrx_plus_1
      			EXEEND_
      			SSND_($13)				;Sound #13
      			BE29_($08)				;Effect: Range #08
      			JSRDR_(timer_inc)		
      			ADDRAM_(rega,$40)			;RAM$00+=$40
      			BITONP2_(rega)			;Turn ON Lamp/Bit @RAM:00
      			ADDRAM_(rega,$F8)			;RAM$00+=$F8
      			BITOFFP_(rega)			;Turn OFF Lamp/Bit @RAM:00
      			BITOFF2_($1A)			;Turn OFF: Lamp#1A(keepshooting)
      			BITFL_($1A)				;Flash: Lamp#1A(keepshooting)
      			BITON_($66)				;Turn ON: Bit#26
      			SOL_(flippers_on)             ;Turn ON Sol#25:flippers?
      			JSRR_(gi_off_inc)			
      			EXE_				      
      			      inc	flag_tilt
      			EXEEND_
			ENDIF_
			KILL_					;Remove This Thread

;***********************************************************
;* Attract Mode Lamps 1:
;***********************************************************
attract_1		jsr	macro_start
			PRI_($43)				;Priority=#43
			REMTHREADS_($FA,$42)		;Remove Multiple Threads Based on Priority
			BEGIN_
				SETRAM_(regb,$0B)			;RAM$01=$0B
				BE28_($02)				;Effect: Range #02
				BEGIN_
					BEGIN_
						BE28_($42)				;Effect: Range #02
						BITOFF2_($4F)			;Turn OFF: Lamp#0F(D)
						BE2E_($02)				;Effect: Range #02
						SLEEP_(3)
					EQEND_($F5,$82)			;BNER_RangeOFF#82
					BEGIN_
						BE2A_($02)				;Effect: Range #02
						SLEEP_(3)
					EQEND_($F6,$82)			;BNER_RangeON#82 to gb_7E
					ADDRAM_(regb,-1)			;RAM$01-=1
				EQEND_($FC,$E1,$00)		;BNER_RAM$01==#0 
			NEEND_($FB,$40,$F1)		;BEQR_(GAME || BIT#00)
			BE29_($42)				;Effect: Range #02
			KILL_					;Remove This Thread

;************************************************************************
;* Left Drop Target Timer Thread:
;************************************************************************
left_timer		jsr	macro_start
			EXE_				
			      jsr	get_lord			;Get Number of L-O-R-D lamps to go
			      asla	
			      adda	#$0D
			      ldab	#$08
			EXEEND_
			BEGIN_
				ADDRAM_(rega,-1)			;RAM$00-=1
lt_outer_loop		BITON_($1C)		            ;Turn ON: Lamp#1C(dt_left)
				SSND_($09)				;Sound #09
				SLEEPI_(rega)				;Delay RAM$00
				BITOFF_($1C)			;Turn OFF: Lamp#1C(dt_left)
				BEGIN_
					SLEEPI_(rega)			;Delay RAM$00
				NEEND_($FE,$F2,$F0,$10)  	;BEQR_(LAMP#10(1_target) P $F0,$10)
			EQEND_($FC,$E0,$03)		;BNER_RAM$00==#3
			ADDRAM_(regb,-1)			;RAM$01-=1
			BNER_($FC,$E1,$00,lt_outer_loop)	;BNER_RAM$01==#0 to lt_outer_loop
			BITON_($5D)				;Turn ON: Bit#1D
			SOL_(dtleft_on)               ;Turn ON Sol#4:dt_left
			SLEEP_(48)
			BITOFF_($DC,$DD,$1C)		;Turn OFF: Bit#1C, Bit#1D, Lamp#1C(dt_left)
			KILL_					;Remove This Thread

;************************************************************************
;* Right Drop Target Timer Thread:
;************************************************************************
right_timer		jsr	macro_start
			PRI_($70)				;Priority=#70
			EXE_				
			      jsr	get_lord
			      asla	
			      adda	#$0D
			      ldab	#$08
			EXEEND_
			BEGIN_
				ADDRAM_(rega,-1)			;RAM$00-=1
rt_outer_loop		BITON_($18)				;Turn ON: Lamp#18(dt_right)
				SSND_($09)				;Sound #09
				SLEEPI_(rega)			;Delay RAM$00
				BITOFF_($18)			;Turn OFF: Lamp#18(dt_right)
				BEGIN_
					SLEEPI_(rega)			;Delay RAM$00
				NEEND_($FE,$F2,$F0,$10)		;BEQR_(LAMP#10(1_target) P $F0,$10)
			EQEND_($FC,$E0,$03)		;BNER_RAM$00==#3
			ADDRAM_(regb,-1)			;RAM$01-=1
			BNER_($FC,$E1,$00,rt_outer_loop)	;BNER_RAM$01==#0 to rt_outer_loop
			BITON_($59)				;Turn ON: Bit#19
			SOL_(dtright_on)              ;Turn ON Sol#5:dt_right
			SLEEP_(48)
			BITOFF_($D8,$D9,$18)		;Turn OFF: Bit#18, Bit#19, Lamp#18(dt_right)
			KILL_					;Remove This Thread

;**********************************************************
;* Plunger Thread
;**********************************************************
sw_ballshooter	IFEQR_($F8,$E0)    	      ;BNER_SW#E0
			      REMTHREADS_($F8,$C0)		;Remove Multiple Threads Based on Priority
			      KILL_					;Remove This Thread
                  ENDIF_
			RSND_($09,$1E)			;Sound #09(x30)
			IFEQR_($FB,$50,$5E)	      ;BNER_(BIT#1E || BIT#10)
			      PRI_($C0)				;Priority=#C0
			      SLEEP_(255)
			      SLEEP_(129)
			      BEQR_($5E,gb_56)			;BEQR_BIT#1E to gb_56
			ENDIF_
kill_1		KILL_					;Remove This Thread

;**************************************************************
;* Playfield Entry Switch - Always scores 10 points
;**************************************************************
pf_entry_cpu	jsr	macro_start
sw_pf_entry		PTSDIG_(1,10)			;10 Points/Digit Sound
			BNER_($FB,$50,$5E,kill_1)	;BNER_(BIT#1E || BIT#10) to kill_1
gb_56			BITOFF_($DE,$50)			;Turn OFF: Bit#1E, Bit#10
			REMTHREADS_($F8,$C0)		;Remove Multiple Threads Based on Priority
			BNEA_($57,gb_24)        	;BNEA_BIT#17 to gb_24
			BITOFF_($57)			;Turn OFF: Bit#17
			KILL_					;Remove This Thread

;***************************************************************
;* Outhole Thread
;***************************************************************
sw_outhole		SOL_(outhole_on)              ;Turn ON Sol#1:outhole
			BITON_($55)				;Turn ON: Bit#15
			IFEQR_($FB,$50,$5E)	      ;BNER_(BIT#1E || BIT#10)
			      EXE_	
			      	NEWTHREAD(gj_2B)			
			      EXEEND_
			ENDIF_
			SLEEP_(192)
			SWCLR_($29)				;Clear Sw#: $29(outhole)
			KILL_					;Remove This Thread

;***************************************************************
;*
;***************************************************************
gj_2B			jsr	macro_start
			JMPR_(gb_56)	
			
;***************************************************************
;* Multiball counter: This routine is responsible for incrementing
;* the count in the player 1 score display at the start of the
;* multiball animation process. It resets game_ram_d and increments
;* it until it matches the value of game_ram_a
;***************************************************************					
mb_countup		clra	
			staa	game_ram_d
			begin
				tab	
				jsr	split_ab
				oraa	#$0F
				orab	#$F0
				staa	$49
				stab	score_p1_b1
				ldaa	#$0C
				jsr	isnd_once
				jsr	addthread
				.db $05
				ldaa	game_ram_d
				adda	#$01
				daa	
				bcs	countup_end
				staa	game_ram_d
				cmpa	game_ram_a
			hiend
countup_end		rts	

;******************************************************
;* This will show the current timer value in the digit
;* specified in X.
;******************************************************
show_timer		ldab	game_ram_a			;Get timer value
time_disp		ldaa	spare_ram+3			;If spare_ram+3 != zero then numbers span digit bytes
			ifne
				tba	
				jsr	split_ab
				oraa	#$0F
				orab	#$F0
				staa	$01,X				;Split them up
			endif
			stab	$00,X				;Store them...
			cpx	#score_p2_b1-1		;Are we at the right side of player 2?
			ifeq
				ldaa	spare_ram+3
				ifne
					ldaa	game_ram_a
					staa	score_p2_b1
				endif
			endif
			rts	

;*******************************************************
;* This thread follows behind and erases the previous
;* displayed value.
;*******************************************************
erase_timer		ldab	#$FF
			bra	time_disp

;*******************************************************
;* Fix edges
;*******************************************************			
fix_edges		ldaa	spare_ram+4		;Moving Right or Left?
			ifne				;Left
				ldaa	spare_ram+3		;Spanning digit
				ifeq
					dex	
					cpx	#score_p4_b1-1
					bne	fix_end
					sec	
					rts				;We are done	
				endif
				cpx	#score_p4_b1
				ifeq				;Put half in MBIP 
					ldaa	game_ram_a
					lsra	
					lsra	
					lsra	
					lsra	
					oraa	#$F0
					staa	mbip_b1
				endif
fix_end			com	spare_ram+3
				clc	
				rts
			endif	
			;Here if was moving right
			ldaa	spare_ram+3
			beq	fix_end
			inx	
			bra	fix_end

;*******************************************************
;* Adjusts X value for display animation
;*******************************************************			
adj_anix		cpx	#score_p3_b1-1		;Are we at the end of Player 2
			ifeq					;yes
				ldx	#score_p4_b1-1		;then, adjust to the end of Player 3
chng_dir			com	spare_ram+4			;Chage direction
				sec	
				rts	
			endif			
			cpx	#score_p3_b1		;Are we at the start of Player 3
			ifeq					;yes
				ldx	#score_p4_b1		;then, adjust to the start of Player 4
				bra	chng_dir
			endif
			cpx	#score_p2_b1-1		;Are we at the end of Player 1
			ifeq					;Yes
				ldaa	spare_ram+3			
				beq	ret_clr
				inx	
				sec	
				rts
			endif	
			cpx	#mbip_b0-1			;Are we at the end of Player 4
			ifeq					;Yes...
				com	spare_ram+4			;change direction
			endif
ret_clr		clc	
			rts
			
;***********************************************************
;* This routine takes care of the fancy display during the
;* start of multiball.
;***********************************************************			
mb_fancy		BITON_($40)				;Turn ON: Bit#00
			PRI_($B5)				;Priority=#B5
			BEGIN_
				SLEEP_(11)
			NEEND_($FE,$F2,$F2,$40)		;BEQR_(BIT#00 P $F2,$40)
			REMTHREADS_($F8,$D0)		;Remove Multiple Threads Based on Priority
			JSRDR_(cpdisp_show)		
			JSRR_(gi_off_inc)			
			BE29_($08)				;Effect: Range #08
			JSRDR_(timer_inc)		
			CPUX_					;Resume CPU Execution
			NEWTHREAD(attract_1)
			NEWTHREAD(attract_2)
			clr	comma_flags
			ldx	#score_p1_b1
			ldab	#$10
			ldaa	#$FF
			staa	mbip_b1
			staa	cred_b1
			jsr	write_range			;Blank all displays in Buffer 1
			ldaa	#$FF
			jsr	store_display_mask
			jsr	mb_countup			;Increment counter in Player 1 score display
			jsr	macro_start
			JSRR_(bell_on_inc)		;Turn on the damn bell!		
			CPUX_					;Resume CPU Execution
			ldx	#score_p1_b1
			clra	
			staa	spare_ram+4			;Store direction: 00=right ff=left
			coma	
			staa	spare_ram+3			;Store Digit Span info: 00=normal ff=split
			begin
				begin
					jsr	show_timer			;Show the digit
					jsr	addthread			;Wait a bit
					.db $08
					jsr	erase_timer			;Erase trailing digits
					jsr	adj_anix			;Adjust X value
				ccend
				jsr	fix_edges			;Fix transistions
			csend
			;Now we are done with the walking animation
			ldaa	game_ram_a
			staa	mbip_b1			;Put timer back in MBIP
			jsr	macro_start
			;This next section will flash the time in the MBIP display 4 times...
			SETRAM_(regb,$04)			;RAM$01=$04
			BEGIN_
				SLEEP_(16)
				EXE_
				      ldaa	#$FF
				      staa	mbip_b1
				EXEEND_
				SLEEP_(16)
				EXE_
				      ldaa	game_ram_a
				      staa	mbip_b1
				EXEEND_
				ADDRAM_(regb,-1)			;RAM$01-=1
			EQEND_($FC,$E1,$00)		;BNER_RAM$01==#0
			EXE_
			      ;Put back all the scores
			      ldx	#vm_reg_a
			      stx	dmask_p1
			      stx	dmask_p3
			      ldaa	spare_ram+1
			      staa	comma_flags
			EXEEND_
			JSRD_(update_commas)		
			JSRR_(bell_off_dec)		;Turn off that damn bell!!!	
			SSND_($12)				;Sound #12
			BITOFF_($40)			;Turn OFF: Bit#00
			JSRDR_(timer_dec)		
			REMTHREADS_($F8,$42)		;Remove Multiple Threads Based on Priority
;************************************************************
;* NOTE: This falls through from above!
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

;********************************************************
;* Attract Mode Lamps 2
;*
;* This is a ping-pong effect on the left and right
;* magna save lamps. One lamp is one and it bounces 
;* from end to end in the group.
;********************************************************
attract_2		NEWTHREAD(attract_2a)
			jsr	macro_start
			PRI_($43)				;Priority=#43
			BITON2_($66)			;Turn ON: Lamp#26(lmag1)
			BITON2_($47)			;Turn ON: Lamp#07(rmag1)
			BITON2_($60)			;Turn ON: Lamp#20(dt1)
			BEGIN_
				BEGIN_
					ADDRAM_(rega,$01)			;RAM$00+=$01
at2_loop			      BEQR_($FC,$FF,$E0,$01,$00,at2_1)	;BEQR_(LAMP#01(bip) & RAM$00)==#0 to at2_1
				NEEND_($F7,$26)    		;BEQR_BIT#26
				BE2D_($06,$05)			;Effect: Range #06 Range #05
				JMPR_(at2_2)			
at2_1			NEEND_($F7,$2A)			;BEQR_BIT#2A 
			BE2E_($06,$05)			;Effect: Range #06 Range #05
at2_2			BE2D_($0B)				;Effect: Range #0B
			SLEEP_(4)
			JMPR_(at2_loop)			
			
;********************************************************
;* Attract Mode Lamps 2a
;*
;* This effect is the center lamps of the PF that include
;* the double-score lamp, the multiplier lamps and the 
;* bonus lamps from 1-30.  It is a sweep effect that 
;* starts with the bottom (double-score) lamp and the 
;* multiplier lamps turning on, then the bonus lamps 
;* starting at 1 turning on and sequentially turning on
;* up through 9. Once all lamps are on, the effect repeats
;* but with the lamps turning off.
;********************************************************			
attract_2a		jsr	macro_start
			PRI_($43)				;Priority=#43
			BEGIN_
				BITINV2_($59)			;Toggle: Lamp#19(double_score)
				BITINV2_($7C)			;Toggle: Lamp#3C(2x)
				BITINV2_($7F)			;Toggle: Lamp#3F(5x)
				SLEEP_(3)
				BITINV2_($7D)			;Toggle: Lamp#3D(3x)
				BITINV2_($7E)			;Toggle: Lamp#3E(4x)
				SETRAM_(rega,$6F)			;RAM$00=$6F
				BEGIN_
					SLEEP_(3)
					ADDRAM_(rega,$01)			;RAM$00+=$01
					BITINVP2_(rega)			;Toggle Lamp/Bit @RAM:00
				EQEND_($FC,$E0,$78)		;BNER_RAM$00==$78
				BITINV2_($7A)			;Toggle: Lamp#3A(bonus_20)
				BITINV2_($7B)			;Toggle: Lamp#3B(bonus_30)
				SLEEP_(3)
				BITINV2_($79)			;Toggle: Lamp#39(bonus_10)
				SLEEP_(3)
			LOOP_

;***************************************************************
;* Left Return Lane Code:
;***************************************************************						
sw_4_rollover	EXE_
			      NEWTHREAD(sw_12345_com)		;Spawn the new thread for 12345 logic
			EXEEND_
			JSRDR_(spawn_loop)		;Turn on the appropriate loop lamp		
			JSRR_(inc_bonus)			;1 bonus advance		
			IFNER_($41)			      ;BEQR_BIT#01
      			BITFL_($2B)				;Flash: Lamp#2B(extra_kick)
      			PRI_($20)				;Priority=#20
      			JSRD_(get_lord_num)			
      			SLEEPI_(rega)			;Delay RAM$00
      			SLEEP_(160)
      			BITOFF_($2B)			;Turn OFF: Lamp#2B(extra_kick)
      	      ENDIF_
			KILL_					;Remove This Thread

spawn_loop		NEWTHREAD_JMP(activate_loop)
			
activate_loop	jsr	macro_start
			REMTHREADS_($F8,$50)		;Remove Multiple Threads Based on Priority
			PRI_($50)				;Priority=#50
			IFEQR_($F6,$01)			;BNER_RangeON#01
				IFNER_($FC,$D6,$01)	      ;BEQR_ADJ#6==#1
	      			BITFL_($1D)				;Flash: Lamp#1D(loop_dshield)
	      			SLEEP_(160)
	      			BITOFF_($1D)			;Turn OFF: Lamp#1D(loop_dshield)
	      	      ENDIF_
	      		KILL_	
	      	ENDIF_				;Remove This Thread
			;fall through
;***************************************************************
;* Will light the loop to award a bonus multiplier for a time
;* period determined by the number of multipliers already lit.
;***************************************************************
light_x		BITFL_($1E)				;Flash: Lamp#1E(loop_x)
			BITOFF2_($1E)			;Turn OFF: Lamp#1E(loop_x)
			SLEEP_(96)
			EXE_
			      ldab	$17
			      andb	#$F0
			      jsr	bits_to_int
			EXEEND_
			EXE_
			      nega	
			      asla	
			      asla	
			      asla	
			      asla	
			      asla	
			      asla	
			      deca	
			EXEEND_
			SLEEPI_(rega)			;Delay RAM$00
			IFNER_($3E)		            ;BEQR_BIT#FFFFFFFE 
			      SLEEP_(64)
			ENDIF_
      		BITOFF2_($5E)			;Turn OFF: Lamp#1E(loop_x)
			BITON2_($1E)			;Turn ON: Lamp#1E(loop_x)
			SLEEP_(64)
			BITOFF_($1E)			;Turn OFF: Lamp#1E(loop_x)
			BITOFF2_($1E)			;Turn OFF: Lamp#1E(loop_x)
			KILL_					;Remove This Thread

;**********************************************************************
;* Left Magnet Button
;**********************************************************************
sw_left_magnet	IFNER_($FB,$FB,$F5,$06,$6D,$4F)	;BEQR_(BIT#0F || (BIT#2D || RangeOFF#06))
				PRI_($09)				;Priority=#09
				SETRAM_(regb,$2B)			;RAM$01=$2B
				JSRR_(gj_15)			
				BITON_($6D)				;Turn ON: Bit#2D - this will protect us from reentering here again
				SOL_(leftmag_on)		      ;Turn ON Sol#21:left_magnet
				BEGIN_
					SETRAM_(regb,$2B)			;RAM$01=$2B
					JSRR_(gj_15)			
					BE1C_($06)				;Effect: Range #06
					SETRAM_(rega,$20)			;RAM$00=$20
					BEGIN_
						JSRR_(mag_tick)			;Does lamp effect and a 'tick', minimum 
											;magnet on time is 20 ticks.		
						BNER_($F8,$31,lmag_off)		;BNER_SW#31 to lmag_off
					EQEND_($FC,$E0,$00)		;BNER_RAM$00==#0 
					ADDRAM_(regb,$C0)			;RAM$01+=$C0
					BITOFFP2_(regb)			;Turn OFF Lamp/Bit @RAM:01
				EQEND_($F5,$06)			;BNER_RangeOFF#06
				;Here if we are out of magna-saves
				ADDRAM_(regb,$40)			;RAM$01+=$40
lmag_off			SOL_(leftmag_off)             ;Turn OFF Sol#21:left_magnet
				ADDRAM_(regb,$C0)			;RAM$01+=$C0
				BITOFFP2_(regb)			;Turn OFF Lamp/Bit @RAM:01
				BITOFF_($6D)			;Turn OFF: Bit#2D
			ENDIF_
kill_2		KILL_					;Remove This Thread


gj_15			BEGIN_
				ADDRAM_(regb,-1)			;RAM$01-=1
			EQEND_($E1)				;BNER_RAM$01
			BITONP2_(regb)			;Turn ON Lamp/Bit @RAM:01
			ADDRAM_(regb,$40)			;RAM$01+=$40
			MRTS_					;Macro RTS, Save MRA,MRB

;**********************************************************************
;* Routine to do the lamp effect for the magna-save. It will also
;* decrement RAM $00 which is the minimum magnet on time counter and 
;* create the magna-save sound.
;**********************************************************************
mag_tick		SLEEP_(2)
			BITINVP2_(regb)			;Toggle Lamp/Bit @RAM:01
			IFEQR_($FA,$F9,$C0,$E1,$F3,$FB,$FC,$E1,$6A,$FC,$E1,$4B)
				;BNER_((!(RAM$01==#75 || RAM$01==#106)) && (RAM$01 + BIT#80)) 
				ADDRAM_(regb,$C0)			;RAM$01+=$C0
				BITOFFP2_(regb)			;Turn OFF Lamp/Bit @RAM:01
				ADDRAM_(regb,$01)			;RAM$01+=$01
				BITONP2_(regb)			;Turn ON Lamp/Bit @RAM:01
				ADDRAM_(regb,$40)			;RAM$01+=$40
			ENDIF_
			ADDRAM_(rega,-1)			;RAM$00-=1
			SSND_($1A)				;Sound #1A
			MRTS_					;Macro RTS, Save MRA,MRB
;**********************************************************************
;* Right Magnet Button
;**********************************************************************
sw_right_magnet	IFNER_($FB,$FB,$F5,$05,$6E,$4F)	;BEQR_(BIT#0F || (BIT#2E || RangeOFF#05)) to kill_2
				;BEQR_($FB,$FB,$F5,$05,$6E,$4F,kill_2)	
				PRI_($09)				;Priority=#09
				BITON_($6E)				;Bit#2E=1 - this will protect us from reentering here again
				SOL_(rightmag_on)            	;Turn ON Sol#6:right_magnet
				BEGIN_
					SETRAM_(regb,$0C)			;RAM$01=$0C
					JSRR_(gj_15)			
					BE1C_($05)				;Effect: Range #05
					SETRAM_(rega,$20)			;RAM$00=$20
					BEGIN_
						JSRR_(mag_tick)		;Does lamp effect and a 'tick', minimum 
												;magnet on time is $20 ticks.		
						BNER_($F8,$30,rmag_off)	;BNER_SW#30 to rmag_off
		      		EQEND_($FC,$E0,$00)		;BNER_RAM$00==#0 
		      		ADDRAM_(regb,$C0)			;RAM$01+=$C0
		      		BITOFFP2_(regb)			;Turn OFF Lamp/Bit @RAM:01
	      		EQEND_($F5,$05)			;BNER_RangeOFF#05
	      		;Here if we are out of magna-saves
	      		ADDRAM_(regb,$40)			;RAM$01+=$40
rmag_off			SOL_(rightmag_off)            ;Turn OFF Sol#6:right_magnet
				ADDRAM_(regb,$C0)			;RAM$01+=$C0
				BITOFFP2_(regb)			;Turn OFF Lamp/Bit @RAM:01
				BITOFF_($6E)			;Bit#2E=0 Set the magnet status bit
			ENDIF_
			KILL_					;Remove This Thread

;**********************************************************************
;* Player Initialization: Called from System at start of each ball. 
;*                        This will flash the high score between balls.
;**********************************************************************
hook_playerinit	ldaa	comma_flags
			staa	spare_ram+1
			clr	spare_ram+5
			jsr	macro_start
			PRI_($05)				;Priority=#05
			BITON_($4F)				;Turn ON: Bit#0F
			CPUX_					;Resume CPU Execution
			ldx	#adj_backuphstd
			jsr	cmosinc_a
			ifne
				ldx	pscore_buf
				ldaa	$00,X
				inca	
				ifne
					jsr	show_hstd
					ldaa	#$7F
					jsr	store_display_mask
					ldaa	#$FF
					staa	comma_flags
					ldaa	#$1D
					jsr	isnd_once
					ldaa	#$05
					jsr	lamp_flash
					jsr	addthread
					.db $80
		
					jsr	lamp_off
					ldaa	spare_ram+1
					staa	comma_flags
					clra	
					jsr	store_display_mask
				endif
			endif
			jsr	macro_start
			IFNER_($61)			      ;BEQR_BIT#21
      			SLEEP_(96)
      			BITON_($61)				;Turn ON: Bit#21
      		ENDIF_
			BE29_($47)				;Effect: Range #07
			JSRR_(add_drainshield)			
			IFEQR_($FC,$FF,$0F,$D7,$01)	;BNER_(ADJ#7 & LAMP#0F(D))==#1
				BE19_($06,$05)			;Effect: Range #06 Range #05
			ENDIF_
			IFNER_($FC,$D9,$01)	      ;BEQR_ADJ#9==#1
      			EXE_
      			      NEWTHREAD(bg_snd)			;Start the BG Sound
      			EXEEND_
      		ENDIF_
			IFEQR_($52)			;BNER_BIT#12
      			EXE_
      			      NEWTHREAD(udt_init)		;Set up the Upper drop Targets
      			EXEEND_
      	      ELSE_			
			      JSR_(udt_setup)
			ENDIF_				
			SOL_(dtleft_on,dtright_on,gi_off,buzzer_off,bell_off)	
                                                ;Sol#4:dt_left ON  
								;Sol#5:dt_right ON  
								;Sol#3:GI OFF  
								;Sol#6:buzzer OFF  
								;Sol#15:bell OFF
			SETRAM_($0C,$00)			;RAM$0C=$00	Reset GI counter
			SETRAM_($0E,$00)			;RAM$0E=$00	Reset Bell counter
			SETRAM_($0F,$00)			;RAM$0F=$00 Reset Buzzer counter
			IFEQR_($41)			      ;BNER_BIT#01 
			      JSRD_(lock_thread)
			ENDIF_			
			JSRR_(do_trough)			
			BITOFF_($55)			;Turn OFF: Bit#15
			REMTHREADS_($F8,$D0)		;Remove Multiple Threads Based on Priority
			JSRDR_(cpdisp_show)		
			BITOFF_($4F)			;Turn OFF: Bit#0F
			SWCLR_($A5,$A6,$98,$1C)		;Clear Sw#: $25(upper_eject) $26(lower_eject) $18(dt_rb) $1C(dt_ll)
			CPUX_					;Resume CPU Execution
			rts	
			
timer_inc		psha	
			ldaa	spare_ram+5
			inca	
			staa	spare_ram+5
			ldaa	#$C8
			jsr	lampm_8
			pula	
			rts
				
timer_dec		psha	
			ldaa	spare_ram+5
			ifne
				deca	
				staa	spare_ram+5
				bne	timer_dec_end
			endif
			ldaa	#$C8
			jsr	lampm_off
timer_dec_end	pula	
			rts	

;**********************************************************
;* Bell Routines
;**********************************************************			
bell_on_inc		IFEQR_($FC,$FF,$D8,$F2,$F0,$00)	;BNER_(#F0 & ADJ#8)==#0 
				ADDRAM_($0E,$01)			;RAM$0E+=$01
				SOL_(bell_on)			;Turn ON Sol#15:bell
			ENDIF_
mrts_1		MRTS_					;Macro RTS, Save MRA,MRB

bell_off_dec	IFNER_($FC,$EE,$00)	      ;BEQR_RAM$0E==#0
			      ADDRAM_($0E,-1)			;RAM$0E-=1
			      BNER_($FC,$EE,$00,mrts_1)	;BNER_RAM$0E==#0 to mrts_1
			ENDIF_
			SOL_(bell_off)    		;Turn OFF Sol#15:bell
			MRTS_					;Macro RTS, Save MRA,MRB

;**********************************************************
;* Buzzer Routines
;**********************************************************
buzz_on_inc		BNER_($FC,$FF,$D8,$0F,$00,mrts_1) ;BNER_(LAMP#0F(D) & ADJ#8)==#0 to mrts_1
			ADDRAM_($0F,$01)			;RAM$0F+=$01
			SOL_(buzzer_on)              	;Turn ON Sol#6:buzzer
			MRTS_					;Macro RTS, Save MRA,MRB

buzz_off_dec	IFNER_($FC,$EF,$00)	      ;BEQR_RAM$0F==#0
			      ADDRAM_($0F,-1)			;RAM$0F-=1
			      BNER_($FC,$EF,$00,mrts_1)	;BNER_RAM$0F==#0 to mrts_1
			ENDIF_
			SOL_(buzzer_off)            	;Turn OFF Sol#6:buzzer
			MRTS_					;Macro RTS, Save MRA,MRB




trough_kill		JSRR_(do_trough)			
			KILL_					;Remove This Thread

;**********************************************************
;* Background Sound Thread
;**********************************************************
bg_snd		jsr	macro_start
			PRI_($E0)				;Priority=#E0
			BEGIN_
				SSND_($1B)				;Sound #1B
				SETRAM_($0B,$00)			;RAM$0B=$00
				BEGIN_
					SLEEP_(255)
					SLEEP_(192)
				NEEND_($FC,$EB,$00)		;BEQR_RAM$0B==#0
				JSRD_(send_sound)			
			LOOP_

;**************************************************************
;* Add Bonus: This routine will add onto the running bonus, the
;* 		  amount passed in B (RAM $01)
;**************************************************************						
add_bonus_dly	BEGIN_
				JSRR_(inc_bonus)			
				ADDRAM_(regb,-1)			;RAM$01-=1
			EQEND_($FC,$E1,$00) 		;BNER_RAM$01==#0 
			MRTS_					;Macro RTS, Save MRA,MRB

inc_bonus		IFNER_($FB,$FA,$3B,$F6,$00,$4F) ;BEQR_(BIT#0F || (RangeON#00 && BIT#FFFFFFFB))
				BE1B_($00)				;Effect: Range #00
				IFEQR_($F5,$00)	            ;BNER_RangeOFF#00
	      			EXE_
	      			      psha	
	      			      ldaa	#$03
	      			      jsr	$F1D5
	      			      pula
	      			EXEEND_	
	      	      ENDIF_
	      	ENDIF_
			MRTS_					;Macro RTS, Save MRA,MRB

;**************************************************************
;* Outhole Routine Called from System
;**************************************************************
hook_outhole	jsr	cpdisp_show
			ldab	flag_bonusball
			jsr	macro_start
			REMTHREADS_($F8,$D0)		;Remove Multiple Threads Based on Priority
			JSRD_(send_sound)			
			IFNER_($FC,$E1,$00)	      ;BEQR_RAM$01==#0
      			IFEQR_($19)			      ;BNER_LAMP#19(double_score) 
      			      BITFL_($19)				;Flash: Lamp#19(double_score)
      			ENDIF_
      			SETRAM_($08,$10)			;RAM$08=$10
      			BE28_($4D)				;Effect: Range #0D (Bounus 1-30)
mult_loop		      SETRAM_(regb,$01)			;RAM$01=$01
      			IFEQR_($3E)			      ;BNER_BIT#FFFFFFFE 
      			      SETRAM_(regb,$02)			;RAM$01=$02
      			      IFEQR_($3F)			      ;BNER_BIT#FFFFFFFF 
      			            SETRAM_(regb,$05)			;RAM$01=$05
      			      ENDIF_
      			ENDIF_
      			BEGIN_
		 			SETRAM_(rega,$0D)			;RAM$00=$0D
	      			JSRD_(lampm_x)
	      			;Do our bonus countdown here...			
bonus_loop		      		IFNER_($FB,$F0,$F5,$8D)	      ;BEQR_(RangeOFF#8D || TILT)
	            			PTSND_($1E,1,1000)		;Sound#1E/1000 Points
	            			IFNER_($F5,$80)		      ;BEQR_RangeOFF#80
	            			      BE2C_($00)				;Effect: Range #00
	            			ELSE_			
	                                    BE28_($00)				;Effect: Range #00
	            			      SETRAM_(rega,$83)			;RAM$00=$83
	            			      JSRD_(lampm_z)
	            			ENDIF_			
				            IFNER_($FC,$E8,$02)	      ;BEQR_RAM$08==#2
	            			      ADDRAM_($08,-1)			;RAM$08-=1
	            			ENDIF_
				            SLEEPI_($8)				;Delay RAM$08
	            			JMPR_(bonus_loop)
	      			ENDIF_	
				      ADDRAM_(regb,-1)			;RAM$01-=1
      			EQEND_($FC,$E1,$00)		;BNER_RAM$01==#0
      			IFNER_($F5,$01)		      ;BEQR_RangeOFF#01
      			      BE1C_($01)				;Effect: Range #01
      			      JMPR_(mult_loop)
      			ENDIF_	
      	      ENDIF_	
			BEGIN_
				SSND_($1C)				;Sound #1C
				JSRDR_(cpdisp_show)		
				REMTHREADS_($F8,$D0)		;Remove Multiple Threads Based on Priority
				SLEEP_(2)
			NEEND_($FB,$51,$62)		;BEQR_(BIT#22 || BIT#11)
			CPUX_					;Resume CPU Execution
			rts	

;**********************************************************
;* Lock Thread Enable: Creates a thread with ID = $60 that
;*                     flashes the lock lamp.
;**********************************************************			
lock_thread		NEWTHREAD_JMP(lock_enable)
			
lock_enable		jsr	macro_start
			PRI_($60)				;Priority=#60
lock_loop		BITINV_($2C)			;Toggle: Lamp#2C(lock)
			SLEEP_(3)
			JMPR_(lock_loop)

;**********************************************************
;* Upper drop target init thread
;**********************************************************						
udt_init		jsr	macro_start
			PRI_($30)				;Priority=#30
			BITON_($42)				;Turn ON: Bit#02
			SOL_(dtrelease_on)		;Turn ON Sol#14:dt_release
			BEGIN_
				SLEEP_(32)
				EXE_
				      ldaa	flag_timer_bip
				EXEEND_
			NEEND_($FC,$E0,$00)		;BEQR_RAM$00==#0 
			JMP_(udt_reset)				

;**********************************************************
;* Main Reset Hook
;**********************************************************
hook_reset		ldaa	#$1C
			jmp	isnd_once			;Kill Background Sounds
			begin
				jmp	killthread
disp_animation		ldaa	bitflags			;See if bit#01 is set
				rora					;If so, we had score, stop the flashing
			ccend
			ldaa	#$D0
			ldab	#$F8
			jsr	kill_threads
			ldx	#score_p1_b1
			ldaa	player_up
			asla	
			asla	
			jsr	xplusa
			ldaa	#$FF
			staa	$00,X
			staa	$01,X
			staa	$02,X
			staa	$03,X
			jsr	cpdisp_show
			clrb	
			clra	
			jsr	addthread
			.db $58
			begin
				begin
					eora	#$80
					eorb	#$01
					begin
						asra	
						psha	
						anda	#$7F
						bsr	plyrmask_x
						pshb	
						ldab	$00,X
						andb	#$80
						aba	
						staa	$00,X
						jsr	disp_mask
						coma	
						anda	comma_flags
						staa	comma_flags
						bsr	to_update_commas
						pulb	
						jsr	addthread
						.db $03
						pula	
						psha	
						anda	#$01
						cba	
						pula	
					eqend
					tstb	
				eqend
				jsr	addthread
				.db $20
			loopend

;***********************************************************
;* Will show buffer 0 of current player
;***********************************************************			
cpdisp_show		bsr	plyrmask_x
			ldaa	$00,X
			anda	#$80
			staa	$00,X
to_update_commas	jmp	update_commas

;***********************************************************
;* Loads X with pointer to current players display mask
;***********************************************************
plyrmask_x		psha	
			ldaa	player_up
			ldx	#dmask_p1
			jsr	xplusa
			pula	
			rts
			
;*********************************************************
; Main System Game Over Entry:
;*********************************************************	
gameover_entry	jsr	macro_start
			IFEQR_($69)			      ;BNER_BIT#29
      			SOL_(gi_off)  		      ;Turn OFF Sol#3:gi
      			SETRAM_($0C,$00)			;RAM$0C=$00
      			JSRD_(send_sound)			
      			SSND_($1C)				;Stop Background Sound
      			IFNER_($60)			      ;BEQR_BIT#20
      			      SSND_($0F)				;Sound #0F
      			ELSE_			
			            SSND_($10)				;Sound #10
      			      BITOFF_($60)			;Turn OFF: Bit#20
      			ENDIF_
			      SLEEP_(192)
      			BITOFF_($69)			;Turn OFF: Bit#29
                  ENDIF_
			;Here are the attract mode threads
			BE29_($08)				;Effect: Range #08
			BE28_($48)				;Effect: Range #08
			CPUX_					;Resume CPU Execution
			NEWTHREAD(attract_1)
			NEWTHREAD(attract_2)
			NEWTHREAD(attract_3)
			NEWTHREAD(attract_4)
			;fall through to start attract_5
			
			jsr	macro_start
attract_5	      BEGIN_
				BITINV2_($57)			;Toggle: Lamp#17(mini_pf)
				BITINV2_($5F)			;Toggle: Lamp#1F(mini_pf)
				BITINV2_($65)			;Toggle: Lamp#25(mini_pf)
				BITINV2_($6E)			;Toggle: Lamp#2E(mini_pf)
				BITINV2_($6F)			;Toggle: Lamp#2F(mini_pf)
				BITINV2_($5B)			;Toggle: Lamp#1B(special)
				BITINV2_($50)			;Toggle: Lamp#10(1_target)
				BITINV2_($6D)			;Toggle: Lamp#2D(double_trouble)
				BITINV2_($6C)			;Toggle: Lamp#2C(lock)
				SLEEP_(3)
			LOOP_	

;**********************************************************
;* Attract Mode Lamps 3
;*
;* This effect sets up two large groups of lamps and toggles
;* between the two groups being on with a 15 cycle pause.
;**********************************************************					
attract_3		jsr	macro_start
			BITON2_($54)			;Turn ON: Lamp#14(5_rollover)
			BITON2_($56)			;Turn ON: Lamp#16(drainshield_r)
			BITON2_($6B)			;Turn ON: Lamp#2B(extra_kick)
			BITON2_($52)			;Turn ON: Lamp#12(3_target)
			BITON2_($58)			;Turn ON: Lamp#18(dt_right)
			BEGIN_
				BITINV2_($54)			;Toggle: Lamp#14(5_rollover)
				BITINV2_($56)			;Toggle: Lamp#16(drainshield_r)
				BITINV2_($6B)			;Toggle: Lamp#2B(extra_kick)
				BITINV2_($52)			;Toggle: Lamp#12(3_target)
				BITINV2_($58)			;Toggle: Lamp#18(dt_right)
				BITINV2_($55)			;Toggle: Lamp#15(drainshield_l)
				BITINV2_($53)			;Toggle: Lamp#13(4_rollover)
				BITINV2_($5C)			;Toggle: Lamp#1C(dt_left)
				BITINV2_($51)			;Toggle: Lamp#11(2_target)
				BITINV2_($5E)			;Toggle: Lamp#1E(loop_x)
				BITINV2_($5D)			;Toggle: Lamp#1D(loop_dshield)
				BITINV2_($5A)			;Toggle: Lamp#1A(keepshooting)
				SLEEP_(15)
			LOOP_	

;***************************************************************
;* Attract Mode Speech/GI Timer
;***************************************************************					
attract_4		jsr	macro_start
			BEGIN_
				SETRAM_(rega,$3C)			;RAM$00=$3C: 60 times
				BEGIN_
					SLEEP_(255)				;255 is about 4 seconds
					ADDRAM_(rega,-1)			;RAM$00-=1
				EQEND_($FC,$E0,$00)		;BNER_RAM$00==#0
				SETRAM_(rega,$10)			;RAM$00=$10
				;Here when timer runs out, flash our GI
				BEGIN_
					JSRR_(gi_off_inc)			
					SLEEP_(4)
					JSRR_(gi_on_dec)			
					SLEEP_(4)
					ADDRAM_(rega,-1)			;RAM$00-=1
				EQEND_($FC,$E0,$00)		;BNER_RAM$00==#0
				JSRR_(gi_off_inc)			
				IFNER_($FC,$FF,$D7,$F2,$F0,$10) ;BEQR_(#F0 & ADJ#7)==#16
					SSND_($0E)				;Sound #0E
					JSRD_(send_sound)	
				ENDIF_		
				JSRR_(gi_on_dec)			
				SSND_($1C)				;Sound #1C
			LOOP_
					
add_dt_audit	stx	sys_temp3
			ldx	#aud_game4			;Total 20,000 Double Trouble Scores
			cmpa	#$02
			ifne
      			ldx	#aud_game5			;Total 40,000 Double Trouble Scores
      			cmpa	#$04
      			ifne
            			ldx	#aud_game6			;Total 80,000 Double Trouble Scores
            			cmpa	#$08
            			ifne
            			      ldx	#aud_game7			;Total 160,000 Double Trouble Scores
            			      cmpa	#$16
            			bne	aud_noadd               ;didn't find an audit for this, bad, exit
            			endif
            		endif
            	endif
			jsr	ptrx_plus_1
aud_noadd		ldx	sys_temp3
			rts	

;****************************************************
; Check status of ball trough switches, if they are
; both down, then eject a ball.
;****************************************************			
do_trough		EXE_
			      clr	flag_timer_bip
			      ldaa	$62
			      anda	#$03
			EXEEND_
			IFEQR_($FC,$E0,$03)	      ;BNER_RAM$00==#3 
			      SOL_(trough_on)   		;Turn ON Sol#2:trough
			      BITOFF_($55)			;Turn OFF: Bit#15
			ENDIF_
      		SLEEP_(96)
			SWCLR_($09)				;Clear Sw#: $09(left_trough)
			MRTS_					;Macro RTS, Save MRA,MRB

;*****************************************************
;* Sound Lookup Table:
;*****************************************************
soundtable		.db $23, $06,	$3A;(05)	;(00) Credit Sound
			.db $A0, $04,	$2F;(10)	;(01) Pop Bumper Thud
			.db $28, $06,	$3A;(05)	;(02) Credit Sound
			.db $A0, $04,	$38;(07)	;(03) Thud
			.db $22, $40,	$32;(0D)	;(04) UDT Bank Down
			.db $28, $02,	$2D;(12)	;(05) Mini-PF
			.db $24, $22,	$3D;(02)	;(06) 
			.db $24, $50,	$39;(06)	;(07) Double Trouble Target Timeout
			.db $C9, $10,	$3E;(01)	;(08) Tilt
			.db $23, $20,	$34;(0D)	;(09) 
			.dw c_sound1\	.db $FF	;(0A) 
			.db $27, $20,	$33;(0C)	;(0B) Gatlin Sound
			.db $28, $2C,	$23;(1C)	;(0C) 
			.db $27, $40,	$2B;(14)	;(0D) Special
			.db $CC, $F0,	$26;(19)	;(0E) Add Player - Random Speech
			.db $CE, $D0,	$29;(16)	;(0F) "Me Jungle Lord"
			.db $CE, $FF,	$27;(18)	;(10) "You Win! Fight in Jungle Again"
			.db $CE, $88,	$2E;(11)	;(11) "You Jungle Lord"
			.db $4E, $FF,	$30;(0F)	;(12) "Stampede, (trumpet)"
			.db $CE, $FF,	$31;(0E)	;(13) "Fight Tiger Again"
			.db $CE, $D8,	$35;(0A)	;(14) "Jungle Lord in Double Trouble" OR "You in Double Trouble"
			.db $CE, $C8,	$3C;(03)	;(15) High Score - "You  Win! You Jungle Lord"
			.db $8C, $80,	$24;(1D)	;(16) Match - "Me Jungle Lord"
			.db $CE, $A8,	$3B;(02)	;(17) Drop Target Timer
			.db $05, $50,	$21;(1E)	;(18) Trumpet
			.db $05, $60,	$20;(1F)	;(19) Trumpet
			.db $24, $02,	$36;(09)	;(1A) 
			.db $BE, $40,	$2A;(15)	;(1B) 
			.db $9F, $40,	$2C;(13)	;(1C) Game Over
			.db $A9, $60,	$22;(1D)	;(1D) 
			.db $04, $04,	$36;(09)	;(1E) 
			.db $28, $40,	$28;(17)	;(1F) 

c_sound1		.db $26,$82,$2D,$80,$3A,$3F	;(19)(12)(02)


switchtable		.db %11010011	\.dw sw_plumbtilt		;(1) plumbtilt
			.db %10010001	\.dw sw_balltilt		;(2) balltilt
			.db %01110001	\.dw credit_button	;(3) credit_button
			.db %11110010	\.dw sw_coin_r		;(4) coin_r
			.db %11110010	\.dw sw_coin_c		;(5) coin_c
			.db %11110010	\.dw sw_coin_l		;(6) coin_l
			.db %01110001	\.dw reset			;(7) slam
			.db %11110001	\.dw sw_hstd_res		;(8) hstd_res
			.db %11010100	\.dw sw_right_trough	;(9) right_trough
			.db %11010100	\.dw sw_left_trough	;(10) left_trough
			.db %11010100	\.dw sw_notused		;(11) notused
			.db %10010001	\.dw sw_leftsling		;(12) leftsling
			.db %10010011	\.dw sw_L_rollover	;(13) L_rollover
			.db %10010011	\.dw sw_O_rollover	;(14) O_rollover
			.db %10010011	\.dw sw_R_rollover	;(15) R_rollover
			.db %10010011	\.dw sw_D_rollover	;(16) D_rollover
			.db %10010010	\.dw sw_1_target		;(17) 1_target
			.db %10010010	\.dw sw_2_target		;(18) 2_target
			.db %10010010	\.dw sw_3_target		;(19) 3_target
			.db %10010011	\.dw sw_4_rollover	;(20) 4_rollover
			.db %10010011	\.dw sw_5_rollover	;(21) 5_rollover
			.db %10010011	\.dw sw_leftdrain		;(22) leftdrain
			.db %10010011	\.dw sw_rightdrain	;(23) rightdrain
			.db %10010011	\.dw sw_looplow		;(24) looplow
			.db %10010101	\.dw sw_dt_rb		;(25) dt_rb
			.db %10010101	\.dw sw_dt_rc		;(26) dt_rc
			.db %10010101	\.dw sw_dt_rt		;(27) dt_rt
			.db %10010001	\.dw sw_rightsling	;(28) rightsling
			.db %10010101	\.dw sw_dt_ll		;(29) dt_ll
			.db %10010101	\.dw sw_dt_lc		;(30) dt_lc
			.db %10010101	\.dw sw_dt_lu		;(31) dt_lu
			.db %10010011	\.dw sw_loophigh		;(32) loophigh
			.db %10010101	\.dw sw_dt_u1		;(33) dt_u1
			.db %10010101	\.dw sw_dt_u2		;(34) dt_u2
			.db %10010101	\.dw sw_dt_u3		;(35) dt_u3
			.db %10010101	\.dw sw_dt_u4		;(36) dt_u4
			.db %10010101	\.dw sw_dt_u5		;(37) dt_u5
			.db %11110100	\.dw sw_upper_eject	;(38) upper_eject
			.db %11110100	\.dw sw_lower_eject	;(39) lower_eject
			.db %10010001	\.dw sw_upper_sling	;(40) upper_sling
			.db %11010011	\.dw sw_pf_tilt		;(41) pf_tilt
			.db %11110110	\.dw sw_outhole		;(42) outhole
			.db %10011111	\.dw sw_ballshooter	;(43) ballshooter
			.db %10010011	\.dw sw_pf_entry		;(44) pf_entry
			.db %10010001	\.dw sw_ten_1		;(45) ten_1
			.db %10010001	\.dw sw_ten_2		;(46) ten_2
			.db %10010001	\.dw sw_ten_3		;(47) ten_3
			.db %10010001	\.dw sw_notused		;(48) notused
			.db %10010001	\.dw sw_right_magnet	;(49) right_magnet
			.db %10010001	\.dw sw_left_magnet	;(50) left_magnet
switchtable_end

			.db $28

 	.org $e000

;---------------------------------------------------------------------------
;  Default game data and basic system tables start at $e000, these can not  
;  ever be moved
;---------------------------------------------------------------------------

gr_gamenumber		.dw $2503
gr_romrevision		.db $F2
gr_cmoscsum			.db $B2,$A5
gr_backuphstd		.db $20
gr_replay1			.db $07
gr_replay2			.db $15
gr_replay3			.db $00
gr_replay4			.db $00
gr_matchenable		.db $00
gr_specialaward		.db $00
gr_replayaward		.db $00
gr_maxplumbbobtilts	.db $03
gr_numberofballs		.db $03
gr_gameadjust1		.db $35
gr_gameadjust2		.db $01
gr_gameadjust3		.db $05
gr_gameadjust4		.db $00
gr_gameadjust5		.db $00
gr_gameadjust6		.db $00
gr_gameadjust7		.db $00
gr_gameadjust8		.db $00
gr_gameadjust9		.db $00
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
gr_extendedromtest	.db $7F
gr_lastswitch		.db (switchtable_end-switchtable)/3
gr_numplayers		.db $03

gr_lamptable_ptr		.dw lamptable
gr_switchtable_ptr	.dw switchtable
gr_soundtable_ptr		.dw soundtable

gr_lampflashrate		.db $05

gr_specialawardsound	.db $0D	;Special Sound
gr_p1_startsound		.db $0E
gr_p2_startsound		.db $0E
gr_p3_startsound		.db $0E
gr_p4_startsound		.db $0E
gr_matchsound		.db $16
gr_highscoresound		.db $15
gr_gameoversound		.db $1C
gr_creditsound		.db $00

gr_eb_lamp_1		.db $7E
gr_eb_lamp_2		.db $00
gr_lastlamp			.db $7E
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
				.db $00,$24

gr_playerstartdata	.db $02,$00,$00,$00,$00
				.db $00,$01,$00,$08,$80
				.db $00,$00,$00,$00,$00
				.db $00,$00,$00,$00,$00

gr_playerresetdata	.db $81,$FF,$00,$00,$C0
				.db $07,$00,$00,$FA,$7F
				.db $04,$00,$00,$00,$00
				.db $00,$00,$40,$00,$00

gr_switch_event		rts\ .db $00	;(Switch Event)
gr_sound_event		rts\ .db $00	;(Sound Event )
gr_score_event		bra score_event	;(Score Event)
gr_eb_event			bra eb_event	;(Extra Ball Event)
gr_special_event		bra special_event	;(Special Event)
gr_macro_event		rts\ .db $00	;(Start Macro Event)
gr_ballstart_event	rts\ .db $00	;(Ball Start Event)
gr_addplayer_event	rts\ .db $00	;(Add Player Event)
gr_gameover_event		bra gameover_event;(Game Over Event)
gr_hstdtoggle_event	rts\ .db $00	;(HSTD Toggle Event)

			.dw hook_reset		;(From $E89F)Reset
			.dw hook_mainloop		;(From $E8B7)Main Loop Begin
			.dw hook_coin		;(From $F770)Coin Accepted
			.dw hook_gamestart	;(From $F847)New Game Start
			.dw hook_playerinit	;(From $F8D8)Init New Player
			.dw hook_outhole		;(From $F9BA)Outhole

;------------------------ end system data ---------------------------

gr_irq_entry	
gr_swi_entry	jmp	sys_irq

lamptable         .db $30, $38      ;(00) bonus_1 -- bonus_9
      		.db $3C ,$3F	;(01) 2x -- 10x
			.db $0C ,$0F	;(02) L -- D
			.db $39 ,$3B	;(03) bonus_10 -- bonus_30
			.db $10 ,$14	;(04) 1_target -- 5_rollover
			.db $07 ,$0B	;(05) rmag1 -- rmag5
			.db $26 ,$2A	;(06) lmag1 -- lmag5
			.db $00 ,$3F	;(07) all lamps
			.db $07 ,$3F	;(08) all lamps except backbox
			.db $48 ,$4C	;(09) bits 18 - 1c
			.db $43 ,$47	;(0A) bits 13 - 17
			.db $20 ,$24	;(0B) dt1 -- dt5
			.db $15 ,$16	;(0C) drainshield_l -- drainshield_r
			.db $30 ,$3B	;(0D) bonus_1 -- bonus_30
			.db $4D ,$4E	;(0E) bits 1d -1e

;**************************************************************
;* Ring the bell fancy when special or extra ball
;**************************************************************
eb_event
special_event	NEWTHREAD_JMP(fancybell)
			
gameover_event	ldaa	#$FF
			staa	mbip_b0
			ldaa	#$69
			jmp	lamp_on
	
;********************************************************
;* Jungle Lord Scoring Event: This takes care of adding
;* up all scores, this needs to be here because of the 
;* double scoring. 
;********************************************************		
score_event		pshb	
			ldab	#$D4
			stab	game_ram_b			;Set Background Sound toggle
			stab	thread_priority
			ldx	#disp_animation
			jsr	newthread_sp
			ldab	$1C
			ifmi	
				andb	#$3F
				stab	$1C			;clear bit#26
				psha	
				jsr	timer_dec
				ldaa	#$1A
				jsr	lamp_off		;turn off 'keepshooting' on playfield
				pula	
			endif
			ldab	$13
			orab	$33
			bitb	#$02
			ifne
				psha	
				anda	#$F8
				asla	
				pulb	
				andb	#$07
				aba	
			endif
			pulb	
			ins	
			ins	
			jsr	update_eb_count
			jsr	score_update
			jsr	update_commas
			ldx	#x_temp_2
			bsr	add_ab
			stab	x_temp_2
			ldx	pscore_buf
			bsr	add_ab
			jsr	$ECB7			;Because we have overridden the scoring event, we need to check
			jmp	$EC18			;if player has exceeded any of the replay scores.
			
add_ab		ldaa	$00,X
			ldab	$01,X
			bsr	dec_test
			jsr	split_ab
			aba	
			tab	
dec_test		cmpb	#$A0
			ifcc
				addb	#$10
			endif
hook_gamestart
hook_mainloop	rts

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
      			SWCLR_($25,$26)			;Clear Sw#: $25(upper_eject) $26(lower_eject)
      			IFEQR_($5F)			      ;BNER_BIT#1F 
      			      JSRR_(mb_end_disp)
      			ENDIF_			
      			BITOFF_($E6,$67)			;Turn OFF: Bit#26, Bit#27
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

;**********************************************************
;* HSTD Reset Switch: Just do it.
;**********************************************************
sw_hstd_res		JSRD_(restore_hstd)		
			KILL_					;Remove This Thread

;**********************************************************
;* 1-2-3-4-5 Switches: This is the routine that takes care
;*                     of handling all the switch closures
;*                     for this feature. If all are on,
;*                     then Double Bonus lights.
;**********************************************************
sw_12345_com	jsr	macro_start
			;Fall through to target logic
sw_1_target
sw_2_target
sw_3_target		BITONP_(rega)			;Turn ON Lamp/Bit @RAM:00
			PTSDIG_(1,1000)			;1000 Points/Digit Sound
			IFEQR_($F6,$04)		      ;BNER_RangeON#04
      			PRI_($05)				;Priority=#05
      			IFEQR_($19)			      ;BNER_LAMP#19(double_score) 
      			      ;If already lit, then give points
      			      POINTS_(5,10000)			;50,000 Points
      			ENDIF_
      			BITON_($19)				;Turn ON: Lamp#19(double_score)
      			SSND_($1D)				;Sound #1D
      			BE19_($04)				;Effect: Range #04
      			BE29_($08)				;Effect: Range #08
      			JSRD_(timer_inc)			
      			SETRAM_(rega,$1E)			;RAM$00=$1E
      			BEGIN_
	 				BE2F_($04)				;Effect: Range #04
	      			SLEEP_(3)
	      			ADDRAM_(rega,-1)			;RAM$00-=1
      			EQEND_($FC,$E0,$00)	;BNER_RAM$00==#0 
      			JSRD_(timer_dec)	
      	      ENDIF_		
			KILL_					;Remove This Thread

;**************************************************************
;* 10 Point switches: If one of the outlanes are on, then
;*                    switch it to the other.
;**************************************************************
sw_leftsling
sw_rightsling
sw_ten_1
sw_ten_2
sw_ten_3
sw_upper_sling	PTSDIG_(1,10)				;10 Points/Digit Sound
			IFNER_($FB,$F6,$0C,$F5,$0C)	;BEQR_(RangeOFF#0C || RangeON#0C) 
			      BE1F_($0C)				;Effect: Range #0C
			      BE1F_($0E)				;Effect: Range #0E
			ENDIF_
sw_notused		KILL_					;Remove This Thread

;**************************************************************
;* Loop Switches:
;**************************************************************
sw_looplow		REMTHREADS_($F8,$90)		;Remove Multiple Threads Based on Priority
			PRI_($90)				;Priority=#90
			PTSDIG_(1,1000)			;1000 Points/Digit Sound
			IFNER_($5B)				;BEQR_BIT#1B
				BITON_($5A)				;Turn ON: Bit#1A
				SLEEP_(32)				;1/2 second
noloop			BITOFF_($5A)			;Turn OFF: Bit#1A
				KILL_					;Remove This Thread
			ENDIF_
loop_forward	REMTHREADS_($F8,$50)		;Remove Multiple Threads Based on Priority
			IFEQR_($F4,$1E)    	      ;BNER_LampOn/Flash#1E
      			BITOFF_($9E,$5B)			;Turn OFF: Lamp#1E(loop_x), Bit#1B
      			BITOFF2_($1E)			;Turn OFF: Lamp#1E(loop_x)
      			PRI_($05)				;Priority=#05
      			BE1A_($01)				;Effect: Range #01
      			SETRAM_(rega,$40)			;RAM$00=$40
      			BEGIN_
				      ADDRAM_(rega,-1)			;RAM$00-=1
      			EQEND_($E0)				;BNER_RAM$00 to gb_46
      			JSRR_(gatlin_sound)			
      			KILL_					;Remove This Thread
                  ENDIF_
      		IFEQR_($F4,$1D)		      ;BNER_LampOn/Flash#1D
      			BITOFF_($1D)			;Turn OFF: Lamp#1D(loop_dshield)
      			JSRR_(loop_effect)			
			ELSE_			
      			PTSDIG_(15,1000)			;15000 Points/Digit Sound
      			JMPR_(bit1b_off)						
sw_loophigh		      REMTHREADS_($F8,$90)		;Remove Multiple Threads Based on Priority
      			PRI_($90)				;Priority=#90
      			PTSDIG_(1,1000)			;1000 Points/Digit Sound
      			BEQR_($5A,loop_backwards)	;BEQR_BIT#1A to loop_backwards
      			BITON_($5B)				;Turn ON: Bit#1B
      			SLEEP_(32)				;1/2 second
      	      ENDIF_
bit1b_off		BITOFF_($5B)			;Turn OFF: Bit#1B
			KILL_					;Remove This Thread

loop_backwards	JSRR_(loop_effect)			
			JMPR_(noloop)
						
loop_effect		BE1A_($0E)				;Effect: Range #0E
			IFNER_($56)			      ;BEQR_BIT#16
			      ;add a drain shield now
add_drainshield		IFNER_($FC,$D6,$01)	      ;BEQR_ADJ#6==#1
            			EXE_
            			      ldaa	$19
            			      anda	#$60
            			      oraa	$12
            			      staa	$12
            			EXEEND_
            			BITOFF_($56)			;Turn OFF: Bit#16
            		ENDIF_
      		ENDIF_
			MRTS_					;Macro RTS, Save MRA,MRB

;**************************************************************
;* Left Drop Target Bank
;**************************************************************
sw_dt_lc
sw_dt_ll
sw_dt_lu		BEQR_($4F,dt_kill)		;BEQR_BIT#0F to dt_kill
			BE1A_($06)				;Effect: Range #06
			PTSDIG_(1,1000)			;1000 Points/Digit Sound
			JSRR_(do_lord)			
			EXE_
			      andb	#$70
			EXEEND_
			BNER_($FC,$E1,$70,dt_kill)	;BNER_RAM$01==#112 to dt_kill
			BITOFF_($1C)			;Turn OFF: Lamp#1C(dt_left)
			SOL_(dtleft_on)   		;Turn ON Sol#4:dt_left
			REMTHREADS_($F8,$80)		;Remove Multiple Threads Based on Priority
			JMPR_(dt_common)
			
;**************************************************************
;* Right Drop Target Bank
;**************************************************************						
sw_dt_rb
sw_dt_rc
sw_dt_rt		BEQR_($4F,dt_kill)		;BEQR_BIT#0F to dt_kill
			BE1A_($05)				;Effect: Range #05
			PTSDIG_(1,1000)			;1000 Points/Digit Sound
			JSRR_(do_lord)			
			EXE_
			      andb	#$07
			EXEEND_
			BNER_($FC,$E1,$07,dt_kill)	;BNER_RAM$01==#7 to dt_kill
			BITOFF_($18)			;Turn OFF: Lamp#18(dt_right)
			SOL_(dtright_on)           	;Turn ON Sol#5:dt_right
			REMTHREADS_($F8,$70)		;Remove Multiple Threads Based on Priority
dt_common		PRI_($05)				;Priority=#05
			EXE_
			      pshb	
			      psha	
			      ldab	#$05
			EXEEND_
			JSR_(add_bonus_dly)				
			EXE_
			      pula	
			      psha
			EXEEND_	
			IFEQR_($E0)			      ;BNER_RAM$00
			      JSRR_(gj_0E)			
			      JMPR_(gj_0F)
			ENDIF_		
			RSND_($1A,$0A)			;Sound #1A(x10)
gj_0F			EXE_
			      pula	
			      pulb
			EXEEND_	
			BITOFFP_(rega)			;Turn OFF Lamp/Bit @RAM:00
			ADDRAM_(rega,$01)			;RAM$00+=$01
			IFNER_($E0)				;BEQR_RAM$00
				BITONP_(rega)			;Turn ON Lamp/Bit @RAM:00
				ADDRAM_(rega,$BF)			;RAM$00+=$BF
				SETRAM_(regb,$18)			;RAM$01=$18
				BEGIN_
					BITINVP_(rega)			;Toggle Lamp/Bit @RAM:00
					SLEEP_(2)
					ADDRAM_(regb,-1)			;RAM$01-=1
				EQEND_($FC,$E1,$00)		;BNER_RAM$01==#0
				ADDRAM_(rega,$41)			;RAM$00+=$41
				BITOFFP_($00)			;Turn OFF Lamp/Bit @RAM:00
			ENDIF_
dt_kill		KILL_					;Remove This Thread

do_lord		EXE_
			      psha	
			      anda	#$FC
			      adda	#$41
			EXEEND_
			BEGIN_
				SLEEP_(2)
			NEEND_($E0)				;BEQR_RAM$00
			EXE_
			      pulb	
			      deca
			EXEEND_	
			BNER_($F8,$E1,dt_kill)		;BNER_SW#E1 to dt_kill
			EXE_
			      psha	
			      jsr	get_lord
			      tab	
			      pula	
			EXEEND_
			IFNER_($E0)		      ;BEQR_RAM$00
      			IFNER_($FB,$FB,$FA,$5F,$FC,$D2,$00,$41,$FA,$FC,$E1,$01,$FC,$D5,$01)
      				;BEQR_((ADJ#5==#1 && RAM$01==#1) || (BIT#01 || (ADJ#2==#0 && BIT#1F)))
            			BITONP_(rega)			;Turn ON Lamp/Bit @RAM:00
            			IFNER_($FC,$E0,$58)	      ;BEQR_RAM$00==#88 
                  			EXE_
                  			      ldab	#$80
                  			      stab	thread_priority
                  			      ldx	#left_timer
                  			      jsr	newthread_sp
                  			EXEEND_
                              ELSE_ 						
                          		EXE_
                  			      ldab	#$70
                  			      stab	thread_priority
                  			      ldx	#right_timer
                  			      jsr	newthread_sp
                  			EXEEND_
                  		ENDIF_
                  	ENDIF_
      		ENDIF_
      		EXE_
			      ldab	$64
			EXEEND_
			MRTS_					;Macro RTS, Save MRA,MRB

;************************************************************
;* #5 Rollover switch: Will turn on multiplier lamp or drain
;*                     shield on loop.
;************************************************************
sw_5_rollover	JSRD_(spawn_loop)			
			JSR_(inc_bonus)		      ;1 bonus advance			
			JMPR_(sw_1_target)		

;************************************************************
;* Lower Eject Hole
;************************************************************			
sw_lower_eject	IFEQR_($FB,$F0,$F1)	;BNER_(GAME || TILT)
			      SETRAM_(rega,$46)			;RAM$00=$46	
      		ELSE_	
	      		BEQA_($FB,$FB,$FE,$F2,$F0,$10,$FA,$5E,$F3,$57,$4F,sw_notused)
                        ;BEQR_(BIT#0F || (((!BIT#17) && BIT#1E) || (LAMP#10(1_target) P $F0,$10))) to sw_notused
      			BITON_($54)				;Turn ON: Bit#14
      			BEQA_($41,mb_start)		;BEQR_BIT#01 to mb_start
      			IFEQR_($F4,$2B)		      ;BNER_LampOn/Flash#2B
      			      BITOFF_($2B)			;Turn OFF: Lamp#2B(extra_kick)
      			      REMTHREADS_($F8,$14)		;Remove Multiple Threads Based on Priority
      			      BITON_($53)				;Turn ON: Bit#13
      			ENDIF_
eject_common	      PRI_($15)				;Priority=#15
      			PTSDIG_(1,1000)			;1000 Points/Digit Sound
      			IFNER_($F8,$08)		      ;BEQR_SW#08
            			BITON2_($17)			;Turn ON: Lamp#17(mini_pf)
            			BITON2_($1F)			;Turn ON: Lamp#1F(mini_pf)
            			BITON2_($25)			;Turn ON: Lamp#25(mini_pf)
            			BITON2_($2E)			;Turn ON: Lamp#2E(mini_pf)
            			BITON2_($2F)			;Turn ON: Lamp#2F(mini_pf)
            			BITON2_($2B)			;Turn ON: Lamp#2B(extra_kick)
            			BITOFF2_($6B)			;Turn OFF: Lamp#2B(extra_kick)
            			BITON_($64)				;Turn ON: Bit#24
            		ELSE_			
      	      		JSR_(gi_off_inc)			
            			BE29_($08)				;Effect: Range #08
            			JSRD_(timer_inc)			
            			BE29_($42)				;Effect: Range #02
            	      ENDIF_
gj_22     			EXE_
      			      NEWTHREAD(minipf_thread)
      			EXEEND_
      			SLEEP_(64)
      			SOL_(minikick_on)         	;Turn ON Sol#20:mini_kicker
      			SLEEP_(255)                   ;wait 4 seconds
      			SOL_(minikick_on_hard)        ;Turn ON Sol#20:mini_kicker
      			SLEEP_(192)
gb_89 			BITOFF_($53)			;Turn OFF: Bit#13
      			REMTHREADS_($F8,$10)		;Remove Multiple Threads Based on Priority
gb_41 			JSRR_(minipf_done)			
gb_24 			PRI_($17)				;Priority=#17
      			SLEEP_(32)
      			SSND_($0D)				;Sound #0D
      			IFEQR_($FA,$5F,$F8,$08)	      ;BNER_(SW#08 && BIT#1F)
            			BITOFF_($57)			;Turn OFF: Bit#17
            			JMPR_(mb_restart)
            	      ENDIF_	
       			SETRAM_(rega,lowereject_on)    
      			IFNER_($54)			      ;BEQR_BIT#14 
gb_1C 			      SETRAM_(rega,uppereject_on)
                        ENDIF_
                  ENDIF_	
			JSRD_(solbuf)			
			BITOFF_($54)			;Turn OFF: Bit#14
			SLEEP_(32)
			SWCLR_($A5),($26)			;Clear Sw#: $25(upper_eject) $26(lower_eject)
gb_0B			KILL_					;Remove This Thread


minipf_done		IFEQR_($64)			      ;BNER_BIT#24
      			BITOFF2_($2B)			;Turn OFF: Lamp#2B(extra_kick)
      			BITOFF2_($17)			;Turn OFF: Lamp#17(mini_pf)
      			BITOFF2_($1F)			;Turn OFF: Lamp#1F(mini_pf)
      			BITOFF2_($25)			;Turn OFF: Lamp#25(mini_pf)
      			BITOFF2_($2E)			;Turn OFF: Lamp#2E(mini_pf)
      			BITOFF2_($2F)			;Turn OFF: Lamp#2F(mini_pf)
      		ELSE_				
			      JSRD_(timer_dec)			
			      JSR_(gi_on_dec)
		      ENDIF_			
      		BITOFF_($64)			;Turn OFF: Bit#24
			MRTS_					;Macro RTS, Save MRA,MRB

minipf_thread	jsr	macro_start
			PRI_($15)				;Priority=#15
minipf_loop		BITINV2_($57)			;Toggle: Lamp#17(mini_pf)
			BITINV2_($5F)			;Toggle: Lamp#1F(mini_pf)
			BITINV2_($65)			;Toggle: Lamp#25(mini_pf)
			BITINV2_($6E)			;Toggle: Lamp#2E(mini_pf)
			BITINV2_($6F)			;Toggle: Lamp#2F(mini_pf)
			SSND_($05)				;Sound #05
			SLEEP_(2)
			BEQR_($F0,gb_89)			;BEQR_TILT to gb_89
			BNER_($53,minipf_loop)		;BNER_BIT#13 to minipf_loop
			BITINV2_($6B)			;Toggle: Lamp#2B(extra_kick)
			JMPR_(minipf_loop)	
					
sw_L_rollover
sw_O_rollover
sw_R_rollover
sw_D_rollover	BNER_($FE,$F2,$F2,$10,gb_0B)	;BNER_(LAMP#10(1_target) P $F2,$10) to gb_0B
			BEGIN_
				SLEEP_(1)
			EQEND_($F7,$17)			;BNER_BIT#17
			POINTS_(5,1000)			;5000 Points
			REMTHREADS_($F8,$10)		;Remove Multiple Threads Based on Priority
			PRI_($17)				;Priority=#17
			EXE_
			      tab	
			      negb	
			      addb	#$10
			EXEEND_
			JSR_(add_bonus_dly)				
			IFNER_($E0)		      	;BEQR_RAM$00 
      			BITONP_(rega)			;Turn ON Lamp/Bit @RAM:00
      			JSRR_(gatlin_sound)			
      			IFEQR_($F6,$02)		      ;BNER_RangeON#02 
            			IFNER_($1B)			      ;BEQR_LAMP#1B(special)
                  			JSRR_(minipf_done)			
                  			BNER_($F0,mb_start)		;BNER_TILT to mb_start
                  			BITON_($41)				;Turn ON: Bit#01
                  			SWCLR_($A5),($26)			;Clear Sw#: $25(upper_eject) $26(lower_eject)
                  			KILL_					;Remove This Thread
                  	      ENDIF_
            			SPEC_					;Award Special
            			BE19_($02)				;Effect: Range #02
            		ENDIF_
gb_0E 			BNEA_($53,gb_41)		      ;BNEA_BIT#13 to gb_41
      			BITOFF_($53)			;Turn OFF: Bit#13
      			SLEEP_(32)
      			JMPR_(gj_22)
      		ENDIF_
                  ;mini playfield buzzer						
      		SSND_($02)				;Credit Sound
			JSR_(buzz_on_inc)				
			SLEEP_(12)
			JSR_(buzz_off_dec)				
			SLEEP_(20)
			JSR_(buzz_on_inc)				
			SLEEP_(12)
			JSR_(buzz_off_dec)				
			JMPR_(gb_0E)	

;*************************************************************************
;* Gatlin Gun Sound Effect
;*************************************************************************					
gatlin_sound	BITONP2_(rega)			;Turn ON Lamp/Bit @RAM:00
			ADDRAM_(rega,$40)			;RAM$00+=$40
			SETRAM_(regb,$0C)			;RAM$01=$0C
			BEGIN_
				IFNER_($FD,$E0,$64)	      ;BEQR_RAM$00>=#100 
	      			SSND_($02)				;Sound #02
	      		ELSE_			
					SSND_($0B)				;Sound #0B
				ENDIF_
				BITINVP2_(rega)			;Toggle Lamp/Bit @RAM:00
				SLEEP_(4)
				ADDRAM_(regb,-1)			;RAM$01-=1
			EQEND_($FC,$E1,$00)	      ;BNER_RAM$01==#0
			ADDRAM_(rega,$C0)			;RAM$00+=$C0
			BITOFFP2_(rega)			;Turn OFF Lamp/Bit @RAM:00
			MRTS_					;Macro RTS, Save MRA,MRB

sw_upper_eject	BEQA_($FB,$F0,$F1,gb_1C)	;BEQR_(GAME || TILT) to gb_1C
			BEQA_($FB,$FB,$FE,$F2,$F0,$10,$FA,$F3,$57,$5E,$4F,gb_0B)
			;BEQR_(BIT#0F || ((BIT#1E && (!BIT#17)) || (LAMP#10(1_target) P $F0,$10))) to gb_0B
			BNEA_($41,eject_common)		      ;BNEA_BIT#01 to eject_common

;*******************************************************
;* Begin Multiball
;*******************************************************			
mb_start		BITOFF_($41)			;Turn OFF: Bit#01
			BE19_($02,$0C)			;Effect: Range #02 Range #0C
			BITON_($DF,$9B,$D6,$5E)		;Turn ON: Bit#1F, Lamp#1B(special), Bit#16, Bit#1E
			EXE_
			      ldx	#aud_game1			;Times Multiball has been achieved
			      jsr	ptrx_plus_1
			EXEEND_
			EXE_
			      ldx	#adj_gameadjust1		;Get Multiball Timer
			      jsr	cmosinc_b
			      cmpb	#$15
			      ifcs
				      ldab	#$15
			      endif
			EXEEND_
			RAMCPY_($0A,regb)
			BITOFF_($01)			;Turn OFF: Lamp#01(bip)
			BITFL_($06)				;Flash: Lamp#06(multiball_timer)
			IFEQR_($F8,$08)		      ;BNER_SW#08
      			POINTS_(1,10)     	;10 Points
      			JSR_(mb_fancy)			;Do the fancy fancy animation	
      		ENDIF_
			SOL_(dtleft_on,dtright_on)	;Turn ON Sol#4:dt_left Sol#5:dt_right		
			EXE_
			      ldaa	dmask_p3
			      oraa	#$80
			      staa	dmask_p3
			      ldaa	dmask_p4
			      oraa	#$80
			      staa	dmask_p4
			EXEEND_
;***********************************************************
;* NOTE: Falls through from above!
;*
;***********************************************************
mb_restart		PRI_($B1)				;Priority=#B1
			BITON_($5E)				;Turn ON: Bit#1E
			BITOFF_($2C)			;Turn OFF: Lamp#2C(lock)
			REMTHREADS_($F8,$60)		;Remove Multiple Threads Based on Priority
			REMTHREADS_($F8,$B0)		;Remove Multiple Threads Based on Priority
			BEQR_($F8,$08,mb_pause)		;BEQR_SW#08 to mb_pause
			EXE_
			      NEWTHREAD(pf_entry_cpu)
			EXEEND_
			JMPR_(mb_nopause)
;******************************************************
;* Ball Drained, pause multiball timer for a bit...
;******************************************************						
mb_pause		JSRR_(gj_1D)			
			SOL_(trough_on)   		;Turn ON Sol#2:trough
			EXE_
			      ldaa	game_ram_a
			      staa	mbip_b1
			EXEEND_
			SLEEP_(80)
			SWCLR_($08,$09)			;Clear Sw#: $08(right_trough) $09(left_trough)
			SETRAM_(regb,$16)			;RAM$01=$16
mbp_loop		BEGIN_
				EXE_
				      ldaa	#$FF
				      staa	mbip_b1
				EXEEND_
				SLEEPI_(regb)			;Delay RAM$01
				EXE_
				      ldaa	game_ram_a
				      staa	mbip_b1
				EXEEND_
				SSND_($00)				;Sound #00
				SLEEPI_(regb)			;Delay RAM$01
				EXE_
				      decb	
				      ldaa	flag_timer_bip
				EXEEND_
			EQEND_($FB,$FD,$E0,$00,$FC,$E1,$00) ;BNER_(RAM$01==#0 || RAM$00>=#0)
mb_nopause		BEGIN_
				SETRAM_(regb,$05)			;RAM$01=$05
				SSND_($18)				;Sound #18
mb_loop			PRI_($B1)				;Priority=#B1
				ADDRAM_(regb,-1)			;RAM$01-=1
			NEEND_($FC,$E1,$00)		;BEQR_RAM$01==#0 
			SSND_($00)				;Sound #00
			IFEQR_($FC,$E1,$02)		;BNER_RAM$01==#2
				SSND_($19)				;Sound #19
			ENDIF_
	            RAMCPY_(rega,$0A)
			IFNER_($FE,$F2,$F0,$10)	      ;BEQR_(LAMP#10(1_target) P $F0,$10) 
      			EXE_
      			      adda	#$99
      			      daa	
      			      staa	game_ram_a			;De-increment Mutiball Timer
      			EXEEND_
      		ENDIF_
			EXE_
			      staa	mbip_b1
			EXEEND_
			;are we out of time yet?
			IFNER_($FC,$EA,$00)	      ;BEQR_RAM$0A==#0
			      ;no, keep going
      			SLEEP_(32)
      			EXE_
      			      ldaa	#$FF
      			      staa	mbip_b1
      			EXEEND_
      			SLEEP_(32)
      			JMPR_(mb_loop)
			ENDIF_	
			;here if multiball timer has reached 0	
			IFEQR_($5E)			      ;BNER_BIT#1E
			      BITON_($50)				;Turn ON: Bit#10
			ENDIF_
			JSRR_(mb_end_disp)			
			JSRR_(reset_dt)			
			IFEQR_($F8,$08)		      ;BNER_SW#08
			      JSRR_(add_drainshield)
			ENDIF_			
			PRI_($08)				;Priority=#08
			JSR_(buzz_on_inc)				
			SLEEP_(128)
			JSR_(buzz_off_dec)				
			KILL_					;Remove This Thread

;*****************************************************************
;* This subroutine takes care of setting the multiball mode lamps
;* back to normal and putting the player score masks back as well.
;*****************************************************************
mb_end_disp		BITOFF_($DF,$DE,$9B,$86,$2C)	;Turn OFF: Bit#1F, Bit#1E, Lamp#1B(special), Lamp#06(multiball_timer), Lamp#2C(lock)
			BITON_($01)				;Turn ON: Lamp#01(bip)
			REMTHREADS_($F8,$60)		;Remove Multiple Threads Based on Priority
			BE19_($02)				;Effect: Range #02
			EXE_
			      ldaa	dmask_p3
			      anda	#$7F
			      staa	dmask_p3
			      ldaa	dmask_p4
			      anda	#$7F
			      staa	dmask_p4
			EXEEND_
			MRTS_					;Macro RTS, Save MRA,MRB

sw_right_trough	IFEQR_($FA,$5E,$F3,$57)	      ;BNER_((!BIT#17) && BIT#1E)
      			SOL_(trough_on)              	;Turn ON Sol#2:trough
      			SLEEP_(96)
      			SWCLR_($08)				;Clear Sw#: $08(right_trough)
      			KILL_					;Remove This Thread
                  ENDIF_
			IFEQR_($5F)			      ;BNER_BIT#1F 
			      REMTHREADS_($F8,$60)		;Remove Multiple Threads Based on Priority
			      JMPD_(lock_enable)			
                  ENDIF_
			JSRR_(add_drainshield)			
			KILL_					;Remove This Thread

sw_left_trough	IFEQR_($FA,$F3,$40,$FA,$F8,$08,$F3,$4F)
                        ;BNER_(((!BIT#0F) && SW#08) && (!BIT#00))
      			IFEQR_($5F)			      ;BNER_BIT#1F 
      			      BITON_($57)				;Turn ON: Bit#17
      			      JMPR_(mb_restart)
      			ENDIF_			
      			IFEQR_($66)				;BNER_BIT#26
	      			JSRR_(reset_dt)			
	      			SOL_(flippers_off)            ;Turn OFF Sol#24:flippers
	      			EXE_
	      			      clr	flag_tilt
	      			EXEEND_
	      			BITON_($67)				;Turn ON: Bit#27
	      			JSR_(gi_on_dec)			
gb_5D	 				JSRR_(gj_1D)			
	      			JMP_(trough_kill)
	      		ENDIF_				
	 		      IFEQR_($F0)			      ;BNER_TILT
            			EXE_
            			      dec	flag_bonusball
            			EXEEND_
            	      ENDIF_
      			BNER_($55,gb_5D)			;BNER_BIT#15 to gb_5D
      			BITON_($4F)				;Turn ON: Bit#0F
      			JMPD_(outhole_main)		
      
gj_1D 			JSRD_(cpdisp_show)			
      			REMTHREADS_($F8,$D0)		;Remove Multiple Threads Based on Priority
      			BITOFF_($55)			;Turn OFF: Bit#15
      			EXE_
      			      ldaa	flag_timer_bip
      			      ifne
      				      NEWTHREAD(player_ready)
      				      clr	flag_timer_bip
      			      endif
      			EXEEND_
      			MRTS_					;Macro RTS, Save MRA,MRB
      
reset_dt 			REMTHREADS_($F8,$70)		;Remove Multiple Threads Based on Priority
      			REMTHREADS_($F8,$80)		;Remove Multiple Threads Based on Priority
      			SOL_(dtleft_on,dtright_on)			
      			                              ;Turn ON Sol#3:dt_l Sol#4:dt_r
      			BITOFF_($D8,$DC,$D9,$5D)	;Turn OFF: Bit#18, Bit#1C, Bit#19, Bit#1D
      			MRTS_					;Macro RTS, Save MRA,MRB
                  ENDIF_
			SWCLR_($09)				;Clear Sw#: $09(left_trough)
			KILL_					;Remove This Thread

;**********************************************************************
;* Get LORD Status
;**********************************************************************
get_lord_num	bsr	get_lord
			asla	
			asla	
			asla	
			asla	
			asla	
			asla	
			deca	
			rts
				
get_lord		ldab	$11
			andb	#$F0
			bsr	bits_to_int
			nega	
			adda	#$04
			rts	

;********************************************************
;* Will count the number of bits set in B and return the
;* number in A.
;********************************************************			
bits_to_int		pshb	
			clra	
bits_loop		tstb	
			ifne
				begin
					aslb	
				csend
				inca	
				bra	bits_loop
			endif
			pulb	
			rts	
			
;*********************************************************
;* Double Trouble Drop Target Data
;*********************************************************			
target_data		.db $0E
			.db $16
			.db $2A
			.db $16
			.db $0E
target_data_end

double_trouble	PRI_($05)				;Priority=#05
			BE19_($09,$0B)			;Effect: Range #09 Range #0B
			BE1E_($0A)				;Effect: Range #0A
			IFEQR_($43)		            ;BNER_BIT#03 
      			EXE_
      			      clr	spare_ram			;Reset DT value
      			      NEWTHREAD(set_dt_target)
      			EXEEND_
      			SSND_($14)				;Sound #14
      			BITON_($52)				;Turn ON: Bit#12
      			EXE_
      			      ldx	#aud_game2			;Times Double Trouble Achieved
      			      jsr	ptrx_plus_1
      			EXEEND_
      			MRTS_					;Macro RTS, Save MRA,MRB
;**************************************************
;* This routine will reset the upper drop target 
;* bank and then reset the correct targets for the
;* current player.
;**************************************************
udt_setup		      PRI_($05)				;Priority=#05
      			BITON_($42)				;Turn ON: Bit#02
      			SOL_(dtrelease_on)            ;Turn ON Sol#13:dt_release
      			SLEEP_(64)
      		ENDIF_
			;Here when Double Trouble Starts...
udt_start		CPUX_					;Resume CPU Execution
			ldaa	#dt1_on                 ;Base solenoid is DT1
			ldx	#target_data
			begin
				psha	
				ldaa	bitflags
				lsra	
				ldab	$00,X
				begin
					lsrb	
					asla	
				miend
				pula	
				lsrb	
				ifcs
					suba	#$28
					jsr	lamp_on
					adda	#$28
					stx	sys_temp5
					jsr	bit_lamp_buf_0
					ifeq
						jsr	solbuf
					endif
					ldx	sys_temp5
				else
					jsr	lamp_on
				endif
				inca	                        ;Increment our solenoid number
				inx	
				cpx	#target_data_end
			eqend
			jsr	macro_start
			SLEEP_(48)
			SWCLR_($A0,$A1,$A2,$A3,$A4,$25) ;Clear Sw#: $20(dt_u1) $21(dt_u2) $22(dt_u3) $23(dt_u4) $24(dt_u5) $25(upper_eject)
			BITOFF_($42)			;Turn OFF: Bit#02
			MRTS_					;Macro RTS, Save MRA,MRB

;**********************************************************
;* Select Random Target: Will return $20-24 in game_ram_2
;*                       New target cannot be the same as
;*                       last target.
;**********************************************************
rand_dt		begin
                        begin
                              jsr	get_random
      			      anda	#$07
      			      cmpa	#$05
      			csend
      			adda	#$20
      			cmpa	game_ram_2
			neend
			staa	game_ram_2
			rts	

;**********************************************************
;* Will select a random target and reset it appropriately.
;* The thread will run until the Double Trouble timer expires
;* and will then drop the target and re-select another.
;**********************************************************			
set_dt_target	jsr	rand_dt			;Select a random target, will return $20-$24
			adda	#$28
			jsr	solbuf
			jsr	macro_start
			BE19_($0B)				;Effect: Range #0B
			PRI_($30)				;Priority=#30
			BITONP_($02)			;Turn ON Lamp/Bit @RAM:02
			SLEEP_(32)
			BITOFF_($42)			;Turn OFF: Bit#02
			EXE_
			      jsr	hex2bitpos
			      comb	
			      andb	$65
			      stab	$65
			      ldaa	spare_ram			;Get DT Value, if 0, then no timer
			EXEEND_
			IFEQR_($FC,$E0,$00) ;BNER_RAM$00==#0
			      KILL_					;Remove This Thread
                  ENDIF_
                  ;fall through
;*****************************************************************************
;* Main Double Trouble Routines
;*****************************************************************************
dbltrbl_timer	EXE_
			      ldab	adj_gameadjust3+1
			      andb	#$0F
			EXEEND_
			ADDRAM_(regb,$12)			;RAM$01+=$12 - Get timer from adjustments and add 12
			SETRAM_(rega,$08)			;RAM$00=$08	 -
			BEGIN_
				ADDRAM_(regb,-1)			;RAM$01-=1
dt_fast_loop		SLEEPI_($1)				;Delay RAM$01
				IFEQR_($FB,$FB,$FB,$5E,$66,$FE,$F2,$F0,$10,$40)
	      			;BNER_(BIT#00 || ((LAMP#10(1_target) P $F0,$10) || (BIT#26 || BIT#1E)))
	      			BITONP_($02)			;Turn ON Lamp/Bit @RAM:02
	      			BITOFFP2_($02)			;Turn OFF Lamp/Bit @RAM:02
	      			JMPR_(dt_fast_loop)
	      		ENDIF_			
	      		IFNER_($E2)		      ;BEQR_RAM$02
				      SSND_($06)				;Sound #06
				ENDIF_
	      		BITINVP_($02)			;Toggle Lamp/Bit @RAM:02
			EQEND_($FC,$E1,$02)		;BNER_RAM$01==#2 - Shorten timer and loop
			ADDRAM_(rega,-1)			;RAM$00-=1
			BNER_($FC,$E0,$00,dt_fast_loop)	;BNER_RAM$00==#0 to dt_fast_loop
			SSND_($07)				;Sound #07 (Double Trouble Target Timeout)
			PRI_($30)				;Priority=#30
			BITOFF_($2D)			;Turn OFF: Lamp#2D(double_trouble)
			BITON_($42)				;Turn ON: Bit#02
			SOL_(dtrelease_on)            ;Turn ON Sol#14:dt_release
			BE19_($0B)				;Effect: Range #0B
			SLEEP_(64)
			EXE_
			      ldx	#adj_gameadjust4		;Load delay until reset
			      jsr	cmosinc_a
			EXEEND_
			SLEEPI_(rega)				;Delay RAM$00
udt_reset		EXE_
			      clr	spare_ram			;Reset DT value
			EXEEND_
			JMPD_(set_dt_target)			

start_dbltrbl	BNEA_($FC,$E2,$E0,udt_exit)	;BNER_RAM$02==#224 to udt_exit
			REMTHREADS_($F8,$30)		;Remove Multiple Threads Based on Priority
			BITON_($2D)				;Turn ON: Lamp#2D(double_trouble)
			CPUX_					;Resume CPU Execution
			NEWTHREAD(award_dt_score)
			jmp	set_dt_target
			.db $03

award_dt_score	jsr	macro_start
			IFEQR_($FE,$F2,$F2,$40)	      ;BNER_(BIT#00 P $F2,$40)
			      REMTHREADS_($FA,$40)		;Remove Multiple Threads Based on Priority
			      EXE_
			            jsr	gj_4A
			      EXEEND_
			ENDIF_
			PRI_($45)				;Priority=#45
			CPUX_					;Resume CPU Execution
			ldaa	spare_ram
			ifeq
				inca	
			else
				cmpa	#$16
				ifne
					asla	
					cmpa	#$10
					ifcc
						ldaa	#$16
					endif
				endif
			endif
			jsr	add_dt_audit
			staa	spare_ram
			asla	
			asla	
			asla	
			anda	#$7F
			adda	#$04
			staa	spare_ram+2
			ldaa	bitflags
			rora	
			ifcc
				bsr	gb_9E
				ldaa	#$08
				begin
					bsr	gb_9F
					jsr	addthread
					.db $06
		
					cmpa	#$01
					ifeq
						jsr	addthread
						.db $60
					endif
					jsr	gj_54
					jsr	addthread
					.db $06
		
					deca	
				eqend
				bsr	gb_A2
			endif
			bsr	gj_4A
			jmp	killthread
			
gj_4A			ldaa	spare_ram+2
			jsr	score_main
			cmpa	#$34
			ifeq
      			ldaa	#$0D
      			jmp	score_main
gb_9E 			ldx	#dmask_p4
      			ldab	#$03
      			begin
            			cmpb	player_up
            			ifne
            			      ldaa	$00,X
            			      oraa	#$7F
            			      staa	$00,X
            			endif
            			dex	
            			decb	
      			miend
			rts
	
gb_A2			ldx	#dmask_p4
			ldab	#$03
			begin
      			cmpb	player_up
      			ifne
      			      ldaa	$00,X
      			      anda	#$80
      			      staa	$00,X
      			endif
      			dex	
      			decb	
			miend
			ldaa	spare_ram+1
			staa	comma_flags
			jmp	update_commas
			
gb_9F			psha	
			cmpa	#$06
			ifcc
			      ldaa	#$1F
			else
			      ldaa	#$0C
                  endif
			jsr	isnd_once
			jsr	disp_mask
			tab	
			coma	
			anda	#$33
			andb	comma_flags
			aba	
			staa	comma_flags
			jsr	update_commas
			ldx	#score_p1_b1
			clra	
			begin
      			cmpa	player_up
      			ifne
            			clr	$02,X
            			clr	$03,X
            			ldab	spare_ram
            			bitb	#$F0
            			ifeq
            			      orab	#$F0
            			endif
            			stab	$01,X
            			ldab	#$FF
            			stab	$00,X
            		endif
      			ldab	#$04
      			jsr	xplusb
      			inca	
      			cmpa	#$04
			eqend
			pula	
			rts	
			
gj_54			psha	
			jsr	disp_mask
			anda	comma_flags
			staa	comma_flags
			ldaa	#$FF
			ldab	#$10
			ldx	#score_p1_b1
			jsr	write_range
			pula	
			rts	

;********************************************************
;* Upper Drop Target Switches:
;********************************************************			
sw_dt_u1
sw_dt_u2
sw_dt_u3
sw_dt_u4
sw_dt_u5		IFNER_($42)		      ;BEQR_BIT#02
      			BEQA_($52,start_dbltrbl)  	;BEQR_BIT#12 to start_dbltrbl
      			ADDRAM_(rega,$28)			;RAM$00+=$28
      			IFNER_($E0)		;BEQR_RAM$00
            			BITONP_(rega)			;Turn ON Lamp/Bit @RAM:00
            			JSR_(inc_bonus)			;1 bonus advance			
            			PTSDIG_(1,10000)			;10,000 Points/Digit Sound
            			IFEQR_($F6,$09)		      ;BNER_RangeON#09
            			      JSRR_(double_trouble)
            			ENDIF_
            	      ENDIF_
      	      ENDIF_			
udt_exit		KILL_					;Remove This Thread

gj_0E			SETRAM_(rega,$10)			;RAM$00=$10
			BEGIN_
				ADDRAM_(rega,-1)			;RAM$00-=1
			NEEND_($FA,$E0,$F3,$FC,$E0,$0C) ;BEQR_((!RAM$00==#12) && RAM$00) 
			BITONP_(rega)			;Turn ON Lamp/Bit @RAM:00
			IFEQR_($F6,$02)		      ;BNER_RangeON#02
      			BEQR_($1B,award_spec)		;BEQR_LAMP#1B(special) to award_spec
      			SSND_($17)				;Sound #17
      			BITON_($41)				;Turn ON: Bit#01
      			BITOFF_($D8,$5C)			;Turn OFF: Bit#18, Bit#1C
      			JSRD_(lock_thread)			
      			EXE_
      			      NEWTHREAD(attract_1)
      			EXEEND_
      			MRTS_					;Macro RTS, Save MRA,MRB
                  ENDIF_
gb_4C			EXE_
			      NEWTHREAD(gj_3B)
			EXEEND_
			MRTS_					;Macro RTS, Save MRA,MRB

gj_3B			jsr	macro_start
			JSRR_(gatlin_sound)			
			KILL_					;Remove This Thread

award_spec		SPEC_					;Award Special
			BE19_($02)				;Effect: Range #02
			MRTS_					;Macro RTS, Save MRA,MRB

gr_csum2		.db $49

	
	.end

