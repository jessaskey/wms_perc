;--------------------------------------------------------------
;Jungle Lord Game ROM Disassembly
;Dumped by Pinbuilder ©2000-2005 Jess M. Askey
;--------------------------------------------------------------
#include  "68logic.asm"	;680X logic definitions
#include "7hard.asm"	;Level 7 Hardware Definitions
#include  "wvm7.asm"	;Level 7 macro defines
#include  "7gen.asm"	;Level 7 general defines

;*************************************************************
;* Set the emulation flag to make our file on the $8000 boundary
;* in order for the eprom emulator to work correctly. The 
;* emulator will cover the block from $8000-$ffff. 
;*************************************************************
emulate .equ 1

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

#IF emulate
	.org	$8000
#ENDIF
	.db $55
	
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
gr_ready_event
gr_ballstart_event	rts\ .db $00	;(Ball Start Event)
gr_addplayer_event	rts\ .db $00	;(Add Player Event)
gr_gameover_event		bra gameover_event;(Game Over Event)
gr_hstdtoggle_event	rts\ .db $00	;(HSTD Toggle Event)

gr_reset_hook_ptr
			.dw hook_reset		;(From $E89F)Reset
gr_main_hook_ptr
			.dw hook_mainloop		;(From $E8B7)Main Loop Begin
gr_coin_hook_ptr
			.dw hook_coin		;(From $F770)Coin Accepted
gr_game_hook_ptr
			.dw hook_gamestart	;(From $F847)New Game Start
gr_player_hook_ptr
			.dw hook_playerinit	;(From $F8D8)Init New Player
gr_outhole_hook_ptr
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

;*****************************************************************************
;* Some Global Equates
;*****************************************************************************

irq_per_minute =	$0EFF

;*****************************************************************************
;*Program starts at $e800 for standard games... we can expand this later..
;*****************************************************************************
	.org $E800

;**************************************
;* Main Entry from Reset
;**************************************
reset			sei	
			lds	#pia_ddr_data-1		;Point stack to start of init data
			ldab	#$0A				;Number of PIA sections to initialize
			ldx	#pia_sound_data		;Start with the lowest PIA
			ldaa	#$04
			staa	pia_control,X		;Select control register
			ldaa	#$7F				
			staa	pia_pir,X
			stx	temp1
			cpx	temp1
			ifeq
				begin
					ldx	temp1			;Get next PIA address base
					begin
						clr	pia_control,X	;Initialize all PIA data direction registers
						pula				;Get DDR data
						staa	pia_pir,X
						pula	
						staa	pia_control,X	;Get Control Data
						cpx	#pia_sound_data	;This is the last PIA to do in Level 7 games
						ifne
							clr	pia_pir,X		;If we are on the sound PIA, then clear the
											;peripheral interface register 
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
					oraa	#$20
					staa	temp1			;Store it
				loopend
			endif
			jmp	diag					;NMI Entry
			
;***************************************************
;* System Checksum #1: Set to make ROM csum from
;*                     $E800-$EFFF equal to $00
;***************************************************		
			
csum1			.db $0B
			
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
			jsr	$00,X					;JSR GameROM
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
checkswitch		ldx	#ram_base
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
			beq	switches
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

			;We come back in here if we are in auto-cycle mode...
						
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
				ldab	#$08
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
			beq	doscoreq				;If zero, time to check for the score queue sound/pts
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
_sndnext		ldab	next_sndcnt				;Here if we are done iterating the sound command.
			beq	doscoreq			;Check the scoring queue
			ldaa	next_sndcmd
			jsr	isnd_mult			;Play Sound Index(A),(B)Times
			clr	next_sndcnt
			bra	check_threads		;Get Outta Here.
			
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
			ldab	#$08
			begin
				ldaa	$03,X
				psha	
				inx	
				decb	
			eqend
			ldaa	$04,X
			psha	
			ldaa	$03,X
			psha	
			ldaa	$06,X
			ldab	$07,X
			ldx	$08,X
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
;*	lda #FF		;This code is executed as the thread.
;***************************************************************************
addthread		stx	temp1
			staa	temp2
			tsx	
			ldx	$00,X				;Return Address from RTS to $EA2F
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
			ldab	#$08
			begin
				pula	
				staa	$0A,X
				dex	
				decb	
			eqend
			ldx	current_thread			;Current VM Routine being run
			begin
				lds	#$13F7			;Restore the stack.
				bra	nextthread			;Go check the Control Routine for another job.
				
killthread			ldx	#vm_base
				begin
					stx	temp2					;Thread that points to killed thread
					ldx	$00,X
					beq	check_threads			;Nothing on VM
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
;*  	XXXZZZZZ	Where: ZZZZZ is solenoid number 00-24
;*                       XXX is timer/command
;*
;*****************************************************************		
solbuf		psha					;Push Solenoid #
			pshb	
			stx	temp1				;Put X into Temp1
			ldx	solenoid_queue_pointer	;Check Solenoid Buffer
			cpx	#sol_queue	
			ifne					;Buffer not full
				sec					;Carry Set if Buffer Full
				cpx	#sol_queue_full		;Buffer Full
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
;* Requires:	A - XXXZZZZZ
;*					
;* Where XXX 	= Solenoid Timer/Command
;*       ZZZZZ	= Solenoid Number
;*
;* Example: A = 20 turns on solenoid #00 for 1 IRQ
;*              F8 turns on solenoid #18 idefinitely
;*              C3 turns on solenoid #03 for 6 IRQ's
;*              03 turns off solenoid #03 indefinitely
;***************************************************
set_solenoid	pshb	
			tab	
			andb	#$E0
			ifne
				cmpb	#$E0
				ifne
					;1-6 goes into counter
					stab	solenoid_counter		;Restore Solenoid Counter to #E0
					bsr	soladdr			;Get Solenoid PIA address and bitpos
					stx	solenoid_address
					stab	solenoid_bitpos
				else
					;Do it now... if at 7
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
soladdr		anda	#$1F				;Mask to under 32 Solenoids
			cmpa	#$0F
			iflo					;Get Regular Solenoid Address (PIA)
				ldx	#pia_sol_low_data		;Solenoid PIA Offset
				cmpa	#$07
				ifgt
					inx	
					inx	
				endif
				bra	hex2bitpos			;Convert Hex (A&07) into bitpos (B) and leave
			endif
ssoladdr		suba	#$10
			ldx	#spec_sol_def			;Special Solenoid PIA Location Table
			jsr	gettabledata_b			;X = data at (X + (A*2))
			ldab	#$08
			sec	
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
			ifeq				;Branch if it is already set
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

test_mask_b		ldaa	player_up				;Current Player Up (0-3)
			ldx	#dmask_p1
			jsr	xplusa				;X = X + A
			bitb	$00,X
			rts	

;*********************************************************
;* From the main scoring routine, this will update the
;* extra ball lamp by removing a single extra ball. It 
;* must be done here so that if an extra ball drains 
;* without scoring, the extra ball will not be removed.
;* Therefore all extra ball removals must be done on a
;* scoring event.
;*********************************************************			
update_eb_count	ldab	flag_bonusball			;Are we in infinte ball mode?
			ifeq							;No
				com	flag_bonusball			;
				ldab	num_eb				;Number of Extra Balls Remaining
				ifne				
					dec	num_eb				;EB = EB - 1
					ifeq
						psha	
						ldaa	gr_eb_lamp_1			;Game ROM: Extra Ball Lamp1 Location
						jsr	lamp_off				;Turn off Lamp A (encoded):
						ldaa	gr_eb_lamp_2			;Game ROM: Extra Ball Lamp2 Location
						jsr	lamp_off				;Turn off Lamp A (encoded):
						pula	
					endif
				endif
			endif
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
			stx	x_temp_1			;Store X for later
			jsr	gr_score_event		;Check Game ROM Hook
			bsr	update_eb_count		;Update extra balls
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
			ldx	#score_queue_full	
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
;* Checks the current player score against each replay 
;* level. Award Replay if passed.
;**********************************************************
checkreplay		ldx	#x_temp_2
			bsr	get_hs_digits		;Put Player High Digits into A&B, convert F's to 0's
			stab	x_temp_2
			ldx	pscore_buf			;Current Player Score Buffer Pointer
			bsr	get_hs_digits		;Put Player High Digits into A&B, convert F's to 0's
			ldaa	#$04
			staa	x_temp_2+1			;Check All 4 Replay Levels
			ldx	#adj_replay1		;ADJ: Replay 1 Score
			begin
				jsr	cmosinc_a				;CMOS,X++ -> A
				cba	
				iflo						;Not High Enough, goto next score level
					cmpa	x_temp_2
					ifgt
						stx	thread_priority		;Store our Score Buffer Pointer
						ldaa	#$04
						suba	x_temp_2+1			;See which Replay Level we are at
						asla					;X2
						asla					;X2
						ldx	#aud_replay1times+2	;Base of Replay Score Exceeded Audits
						jsr	xplusa			;X = X + A
						jsr	ptrx_plus_1			;Add 1 to data at X
						ldx	thread_priority
						jsr	award_replay		;Replay Score Level Exceeded: Give award, sound bell.
					endif
				endif
				dec	x_temp_2+1				;Goto Next Score Level
			eqend
			rts
;*********************************************************
;* Load Million and Hundred Thousand Score digits into
;* A and B. Player score buffer pointer is in X. Routine
;* will convert blanks($ff) into 0's
;*********************************************************			
get_hs_digits	ldaa	$00,X
			ldab	$01,X
			bsr	b_plus10		;If B minus then B = B + 0x10
			bsr	split_ab		;Shift A<<4 B>>4
			aba	
			tab	
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
				cpx	#switch_queue_full
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
b_06F			bsr	getswitch				;Clear Carry if Switch Activated
			bcs	to_ldx_rts				;ldx $A0, rts.
			bsr	sw_pack				;$A5(A) = ($A1<<3)+BitPos($A2) Encode Matrix Position
			ldx	#switch_queue
b_071			cpx	switch_queue_pointer
			beq	b_06F
			cmpa	$01,X					;Is this switch in the buffer?
			bne	b_070
			bsr	copy_word				;Copy Word: $96--  Data,$96 -> Data,X
			jsr	sw_proc
			bra	b_06F
b_070			inx	
			inx	
			bra	b_071
			
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
			ldx	#$11A8
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
reset_audits	ldx	#$0066		;Clear RAM from 0100-0165
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
sys_irq			
			;***********************************
			;* Start IRQ with Lamps...
			;***********************************
			ldaa	#$FF
			ldab	irq_counter
			rorb	
			ifcc						;Do Lamps every other IRQ
				inc	lamp_index_word+1
				ldx	#pia_lamp_row_data			;Lamp PIA Offset
				staa	$00,X					;Blank Lamp Rows with an $FF
				ldab	$03,X
				clr	$03,X
				staa	$02,X					;Blank Lamp Columns with $FF
				stab	$03,X
				ldaa	lamp_bit				;Which strobe are we on
				asla						;Shift to next one
				ifeq						;Did it shift off end?			
					staa	lamp_index_word+1			;Yes, Reset lamp strobe count
					staa	irq_counter				;And Reset IRQ counter
					inca						;Make it a 1
				endif
				staa	lamp_bit			;Store new lamp strobe bit position
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
			endif
			;***********************************
			;* Now we will do the displays
			;***********************************
			ldx	lamp_index_word		;Reset X back to $0000
			ldab	irq_counter
			andb	#$07
			ifeq				;Branch on Digits 2-8 or 10-16 (scores)
				ldaa	#$FF
				staa	pia_disp_seg_data			;Display PIA Port B
				ldab	irq_counter
				stab	pia_disp_digit_data		;Display PIA Port A
				bne	b_081
				inc	irqcount16
				ldaa	comma_flags
				staa	comma_data_temp
				ldaa	dmask_p1
				staa	credp1p2_bufferselect
				ldaa	dmask_p3
				staa	mbipp3p4_bufferselect
				ldab	cred_b0
				rol	credp1p2_bufferselect
				ifcs
					ldab	cred_b1
				endif
				ldaa	mbip_b0
				rol	mbipp3p4_bufferselect
				bcc	b_083
				ldaa	mbip_b1
				bra	b_083
			endif
			stab	swap_player_displays
			decb	
			beq	b_084
			subb	#$03
			ifeq
b_084				rol	comma_data_temp			;Commas...
				rorb	
				rol	comma_data_temp
				rorb	
				orab	pia_comma_data			;Store Commas
			else
				ldab	pia_comma_data			;Get Comma Data
				andb	#$3F
			endif						;Blank them out.
			stab	pia_comma_data			;Store the data.
			ldaa	#$FF
			staa	pia_disp_seg_data			;Blank the Display Digits
			ldaa	irq_counter
			staa	pia_disp_digit_data		;Send Display Strobe
			ldaa	score_p1_b0,X			;Buffer 0
			rol	credp1p2_bufferselect
			ifcs
				ldaa	score_p1_b1,X			;Buffer 1
			endif
			ldab	score_p3_b0,X			;Buffer 0
			rol	mbipp3p4_bufferselect
			ifcs
				ldab	score_p3_b1,X			;Buffer 1
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
			;* Done with Displays
			;* Increment the IRQ counter
			;***********************************
			ldaa	irq_counter				;We need to increment this every time.
			inca	
			staa	irq_counter
			;***********************************
			;* Now do switches, The switch logic
			;* has a total of 5 data buffers.
			;* These are used for debouncing the
			;* switch through software.
			;***********************************
			rora	
			ifcc						;Every other IRQ, do all switches
				ldaa	#$01
				staa	pia_switch_strobe_data		;Store Switch Column Drives
				ldx	#ram_base
				begin
					ldaa	switch_debounced,X
					eora	pia_switch_return_data		;Switch Row Return Data
					tab	
					anda	switch_masked,X
					oraa	switch_pending,X
					staa	switch_pending,X
					stab	switch_masked,X
					comb	
					andb	switch_pending,X
					orab	switch_aux,X
					stab	switch_aux,X
					inx	
					asl	pia_switch_strobe_data		;Shift to Next Column Drive
				csend
			endif
			;***********************************
			;* Now do solenoids
			;***********************************
			ldaa	solenoid_counter			;Solenoid Counter
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

;*************************************************************************
;* Special Solenoid Locations	- Defines the addresses for each PIA	
;*************************************************************************	
spec_sol_def	.dw pia_lamp_col_ctrl		;Solenoid $10
			.dw pia_lamp_row_ctrl		;Solenoid $11
			.dw pia_switch_strobe_ctrl	;Solenoid $12
			.dw pia_switch_return_ctrl	;Solenoid $13
			.dw pia_sol_low_ctrl		;Solenoid $14
			.dw pia_disp_seg_ctrl		;Solenoid $15
			.dw pia_comma_ctrl		;Solenoid $16-ST7
			.dw pia_sound_ctrl		;Solenoid $17-ST8
			.dw pia_sol_high_ctrl		;Solenoid $18-Flipper/Solenoid Enable

;*************************************************************************
;* Lamp Buffer Locations		
;*************************************************************************	
lampbuffers		.dw lampbuffer0
			.dw lampflashflag
			.dw lampbuffer1	
			.dw lampbufferselect
			
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
			andb	lampbufferselect,X		;We are now on buffer 0
			stab	lampbufferselect,X
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

;**********************************************************
;* Lamp Range Manipulation Code Start Here
;**********************************************************			
lampm_off		bsr	lampr_start				;A = Start Lamp Level, B = Start Lamp BitPos
			begin
				tba	
				coma	
				anda	$00,X
				bsr	lampm_noflash			;Turn off Flashing State for this lamp
				jsr	lamp_left				;Shift Lamp Bit Left, De-increment Lamp Counter, Write it
			csend						;Loop it!
			bra	abx_ret
			
lampm_noflash	staa	$00,X
			stx	temp2
			ldaa	temp2+1
			cmpa	#$18					;If we are not using Buffer $0010 then skip this
			ifcs
				tba	
				coma	
				anda	lampbufferselect,X
				staa	lampbufferselect,X
			endif
			rts	


lampm_f		bsr	lampr_start				;A = Start Lamp Level, B = Start Lamp BitPos
			begin
				tba	
				eora	$00,X
				staa	$00,X
				jsr	lamp_left				;Shift Lamp Bit Left, De-increment Lamp Counter, Write it
			csend
			bra	abx_ret

;unused?			
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
			
lampm_a		bsr	lampr_start				;A = Start Lamp Level, B = Start Lamp BitPos
			begin
				beq	b_09A
				bsr	lamp_left				;Shift Lamp Bit Left, De-increment Lamp Counter, Write it
				bcs	abx_ret
			loopend
			
lampm_b		bsr	lampr_start				;A = Start Lamp Level, B = Start Lamp BitPos
			begin
				beq	b_09A
				bsr	lamp_left				;Shift Lamp Bit Left, De-increment Lamp Counter, Write it
			csend
			ldx	temp3
			ldaa	sys_temp1
			ldab	sys_temp2
			bra	lampm_off				;Turn OFF All lamps in Range
			
lampm_8		bsr	lampr_start				;A = Start Lamp Level, B = Start Lamp BitPos
			begin
				tba	
				oraa	$00,X
				bsr	lampm_noflash			;Turn off Flashing State for this lamp
				bsr	lamp_left				;Shift Lamp Bit Left, De-increment Lamp Counter, Write it
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
lampr_start		jsr	lampr_setup				;Set up Lamp: $A2=start $A3=last B=Number Of lamps X=Buffer
			ldaa	sys_temp3				;Starting lamp in range
lr_ret		jsr	unpack_byte				;(X = X + A>>3), B = (bitpos(A&07))
			tba	
			anda	$00,X
			rts	
			
lampr_end		bsr	lampr_setup				;Set up Lamp: $A2=start $A3=last B=Number Of lamps X=Buffer
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
			
lamp_left		aslb	
			ifcs
				rolb	
				inx	
			endif
ls_ret		ldaa	temp1
			suba	#$01
			staa	temp1
			tba	
			anda	$00,X
			rts	
			
lamp_right		lsrb	
			bcc	ls_ret
			rorb	
			dex	
			bra	ls_ret
			
			
lampm_c		bsr	lampr_end				;A = Last Lamp Level, B = Last Lamp BitPos
lm_test		ifeq
				bsr	lamp_right				;Shift Lamp Bit Right, De-increment Lamp Counter, Write it
				bcc	lm_test
				bra	abx_ret
			endif
			comb	
			andb	$00,X
			stab	$00,X
			bra	abx_ret
			
lampm_e		bsr	lampr_start				;A = Start Lamp Level, B = Start Lamp BitPos
			stx	temp2
			stab	temp1+1
			begin
				staa	sys_temp5
				bsr	lamp_left				;Shift Lamp Bit Left, De-increment Lamp Counter, Write it
				bcs	b_0A2
				bsr	b_0A3
			loopend
			
b_0A2			ldx	temp2
			ldab	temp1+1
			bsr	b_0A3
			bra	b_0A5
			
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
			tba	
			coma	
			anda	$00,X
			tst	sys_temp5
			ifne
				aba
			endif
			staa	$00,X
			pula	
			rts	
			
lampm_z		jsr	lampr_end				;A = Last Lamp Level, B = Last Lamp BitPos
			ifeq
				begin
					bsr	lamp_right				;Shift Lamp Bit Right, De-increment Lamp Counter, Write it
					bcs	b_0A5
				neend
			endif
			tba	
			eora	$00,X
			staa	$00,X
			jsr	lamp_right				;Shift Lamp Bit Right, De-increment Lamp Counter, Write it
			bcs	b_0A5
			orab	$00,X
			stab	$00,X
b_0A5			jmp	abx_ret

			jsr	lampr_start				;A = Start Lamp Level, B = Start Lamp BitPos
b_0AB			ifne
				jsr	lamp_left				;Shift Lamp Bit Left, De-increment Lamp Counter, Write it
				bcc	b_0AB
				bra	b_0A5
			endif
b_0AA			clc	
			bra	b_0A5
			jsr	lampr_start				;A = Start Lamp Level, B = Start Lamp BitPos
b_0AC			bne	b_0AA
			jsr	lamp_left				;Shift Lamp Bit Left, De-increment Lamp Counter, Write it
			bcc	b_0AC
			bra	b_0A5

		
bit_switch		ldx	#switch_debounced
			bra	bit_main
bit_lamp_flash	ldx	#lampflashflag
			bra	bit_main
bit_lamp_buf_1	ldx	#lampbuffer1
			bra	bit_main
bit_lamp_buf_0	ldx	#lampbuffer0
bit_main		jsr	unpack_byte				;(X = X + A>>3), B = (bitpos(A&07))
			bitb	$00,X
			rts	
			
			
lampm_x		anda	#$3F
			jsr	lampr_start				;A = Start Lamp Level, B = Start Lamp BitPos
			begin
				staa	thread_priority			;This is probably just a temp location?
				tba	
				coma	
				anda	bitflags,X
				oraa	thread_priority			;Recall temp
				staa	bitflags,X
				jsr	lamp_left				;Shift Lamp Bit Left, De-increment Lamp Counter, Write it
			csend
			bra	b_0A5
			
;***************************************************
;* System Checksum #2: Set to make ROM csum from
;*                     $F000-F7FF equal to $00
;***************************************************
	
csum2			.db $EF
			
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
			.dw vm_control_9x		;JSR Relative
			.dw vm_control_ax		;JSR to Code Relative
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
			
vm_lookup_1x_a	.dw lampm_8
			.dw lampm_off
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
			
vm_lookup_2x	.dw lamp_on_b
			.dw lamp_off_b
			.dw lamp_invert_b
			
vm_lookup_4x	.dw add_points
			.dw score_main
			.dw dsnd_pts
			
vm_lookup_5x	.dw macro_ramadd
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

;***************************************************************
;* Pointers to routines for complex branch tests
;***************************************************************			
branch_lookup	.dw branch_tilt		;Tilt Flag				
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
macro_start		staa	ram_base
			stab	ram_base+1
macro_rts		pula	
			staa	vm_pc
			pula	
			staa	vm_pc+1
macro_go		jsr	gr_macro_event
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
			staa	ram_base
breg_sto		stab	ram_base+1
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
			
macro_extraball	jsr	extraball				;Award Extra Ball
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
				jsr	macro_b_ram				;$00,LSD(A)->A
				jsr	$00,X
				tstb	
			plend
to_macro_go1	jmp	macro_go

vm_control_2x	tab						;A= macro
			andb	#$0F
			subb	#$08
			bcc	macro_x8f				;Branch for Macros 28-2F
			ldx	#vm_lookup_2x
			bra	macro_x17
			
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
			eqend					;Add B bytes to Buffer at #1130
			ldaa	#$7E
			staa	$00,X
			ldaa	#$F3
			staa	$01,X
			ldaa	#$CD					;Tack a JMP $F3CD at the end of the routine
			staa	$02,X
			ldaa	ram_base
			ldab	ram_base+1
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
			ldaa	ram_base
			ldab	ram_base+1
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
			ldaa	ram_base
			ldab	ram_base+1
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

;*******************************************************
;* This is the main special award routine that decides 
;* what type of award is to be given and jumps to the 
;* appropriate place.
;*******************************************************			
award_special	psha	
			ldaa	adj_specialaward+1		;ADJ: LSD Special Award-00=Credit 01=EB 02=Points
			anda	#$0F
			beq	credit_special			;Special award is credits
			rora	
			bcs	do_eb					;Extra Ball
			ldaa	gr_specialawardsound		;*Here if Points* Data byte from Game ROM
			jsr	dsnd_pts				;Add Points(A),Play Digit Sound
			pula	
			rts	
			
credit_special	stx	credit_x_temp			;Save X for later
			ldx	#aud_specialcredits		;AUD: Special Credits
			bra	give_credit
;*******************************************************
;* Main entry for replays... score or matching
;*******************************************************			
award_replay	psha	
			ldaa	adj_replayaward+1			;ADJ: LSD Replay Award-00=Credit 01=Extra Ball
			rora	
			bcs	do_eb					;Extra Ball
			stx	credit_x_temp			;Save X for later
			ldx	#aud_replaycredits		;AUD: Replay Score Credits
give_credit		jsr	ptrx_plus_1				;Add 1 to data at X
			jsr	gr_special_event			;Game ROM Hook
			ldaa	#$01
			bra	addcredit2
			
extraball		psha	
do_eb			stx	eb_x_temp				;Save X for later
			ldx	#adj_max_extraballs		;ADJ: Max Extra Balls
			jsr	cmosinc_a				;CMOS,X++ -> A
			cmpa	num_eb				;Number of Extra Balls Remaining
			ifgt
				jsr	gr_eb_event
				ldaa	gr_eb_lamp_1			;*** Game ROM data ***
				jsr	lamp_on				;Turn on Lamp A (encoded):
				ldaa	gr_eb_lamp_2			;*** Game ROM data ***
				jsr	lamp_on				;Turn on Lamp A (encoded):
				inc	num_eb
				ldx	#aud_extraballs			;AUD: Total Extra Balls
				jsr	ptrx_plus_1				;Add 1 to data at X
			endif
			ldx	eb_x_temp				;Restore X
			pula	
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
				cmpb	cred_b0				;Actual Credits
				ifeq						;Check against shown credits
					ldab	#$0E
					stab	thread_priority
					ldx	#creditq				;Thread: Add on Queued Credits
					jsr	newthread_sp			;Push VM: Data in A,B,X,threadpriority,$A6,$A7
					ifcs						;If Carry is set, thread was not added
						staa	cred_b0				;Actual Credits
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
			ldaa	#$EF					;Lockout Coils On
			ifcc
				ldaa	#$0F					;Lockout Coils Off
			endif
			jsr	solbuf				;Turn Off Lockout Coils
			ldaa	gr_lastlamp				;Game ROM: Last Lamp Used
			jsr	lamp_off				;Turn off Lamp A (encoded):
			jsr	cmosinc_b				;CMOS,X++ -> B
			ifne
				jsr	lamp_on				;Turn on Lamp A (encoded):
			endif
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
;* credits showing on the display do not match
;* the number of credits in the CMOS RAM. It 
;* Takes care of bringing them equal in a timely
;* fashion and calling the game ROM hook each
;* time a credit is added to the display. With
;* this, the game ROM can control the credit 
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
					jsr	$00,X					;JSR to Game ROM Credit Hook
					bra	creditq				;Loop it.
				endif
				jsr	$00,X					;JSR to Game ROM/bell?
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
			
;*********************************************************************************
;* Main Coin Switch Routine - Called from each coin switch in the Switch Table.
;*                            This takes care of all bonus coins, multipliers,etc.
;*********************************************************************************
coin_accepted	
			;Starts with Macros
			.db $90,$03 	;MJSR $F7A7
			.db $7E,$EA,$67  	;Push $EA67 into Control Loop with delay of #0E
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
;* System Checksum #3: Set to make ROM csum from
;*                     $F800-$FFFF equal to $00
;********************************************************
csum3			.db $42

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
			jsr	$00,X					;JSR to Game ROM Hook
			jsr	dump_score_queue			;Clean the score queue
			bsr	clear_displays			;Blank all Player Displays (buffer 0)
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
add_player		jsr	gr_addplayer_event		;(RTS)
			inc	num_players				;Add One Player
			ldab	num_players
			bsr	init_player_game			;Put the Default(game start) data into Current Players Game Data Buffer
			ldx	#gr_p1_startsound			;Game ROM Table: Player Start Sounds
			jsr	xplusb				;X = X + B)
			ldaa	$00,X
			jsr	isnd_once				;Play Player Start Sound From Game ROM Table
			aslb	
			aslb	
			ldx	#score_p1_b0
			jsr	xplusb				;X = X + B)
			clr	$03,X				;Put in "00" onto new player display
			rts	

;****************************************************	
;* Sets up all gameplay variables for a new game.
;****************************************************		
initialize_game	clra	
			staa	flag_timer_bip			;Ball in Play Flag
			staa	num_eb				;Number of Extra Balls Remaining
			staa	player_up				;Current Player Up (0-3)
			staa	flag_gameover			;Game Play On
			staa	comma_flags
			ldab	#$08
			jsr	kill_threads
			deca	
			staa	num_players				;Subtract one Credit
			ldaa	#$F1
			staa	mbip_b0				;Set Display to Ball 1
			ldab	#$0C
			ldx	#$001C				;Clear RAM $001C-0027
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
			
store_display_mask	
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
setplayerbuffer	ldaa	#$1A		;Length of Player Buffer
			ldx	#$1126	;Player 1 base
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
			ldab	#$14
			jmp	copyblock				;Copy Block: X -> temp1 B=Length

;***********************************************************
;			
init_player_up	bsr	init_player_sys			;Initialize System for New Player Up
			ldab	player_up				;Current Player Up (0-3)
			bsr	resetplayerdata			;Reset Player Game Data:
			ldx	gr_player_hook_ptr		;Game ROM hook Location
			jsr	$00,X					;JSR to Game ROM
			;This following loop makes the current players
			;score flash until any score is made.
			begin
player_ready		jsr	addthread				;End This Routine, Replace with next routine, next byte is timer.
				.db 	$05
				bsr	disp_mask				;Get Active Player Display Toggle Data
				coma	
				anda	comma_flags
				staa	comma_flags
				bsr	disp_clear				;Blank Current Player Score Display (Buffer 1)
				ldx	current_thread			;Current VM Routine being run
				ldaa	#$07
				staa	threadobj_id,X			;Set thread ID
				ldx	#dmask_p1				;Start of Display Toggles
				jsr	xplusb				;X = X + B
				ldaa	$00,X
				oraa	#$7F
				staa	$00,X
				jsr	addthread				;End This Routine, Replace with next routine, next byte is timer.
				.db	$05
				jsr	gr_ready_event			;Game ROM Hook
				ldaa	$00,X
				anda	#$80
				staa	$00,X
				jsr	update_commas			;Update Master Display Toggle From Current Player
				ldx	current_thread			;Current VM Routine being run
				ldaa	#$04
				staa	threadobj_id,X
				ldaa	flag_timer_bip			;Ball in Play Flag
			neend					
			jmp	killthread				;Remove Current Thread from VM
			
disp_mask		ldab	player_up				;Current Player Up (0-3)
			ldx	#comma_million			;Comma Tables
			jsr	xplusb				;X = X + B)
			ldaa	$00,X					;comma_million: 40 04 80 08
			oraa	$04,X					;comma_thousand: 10 01 20 02
			rts	
			
disp_clear		ldx	pscore_buf				;Start of Current Player Score Buffer
			ldaa	#$FF
			staa	lampbuffer0,X
			staa	$11,X
			staa	$12,X
			staa	$13,X
			rts	

;********************************************************
;* Initializes new player. Clears tilt counter, reset 
;* bonus ball enable, enables flippers, Loads Plater 
;* score buffer pointer.
;********************************************************			
init_player_sys	ldaa	switch_debounced
			anda	#$FC
			staa	switch_debounced				;Blank the Tilt Lines?
			clra	
			staa	flag_tilt				;Clear Tilt Flag
			staa	num_tilt				;Clear Plumb Bob Tilts
			staa	flag_bonusball			;Enable Bonus Ball
			ldaa	#$18
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
			jsr	setplayerbuffer			;X=#1126+((B+1)*#1A))
			stx	temp2					;$9C Points to Base of Player Game Data Buffer
			ldx	#gr_playerstartdata		;X points to base of default player data
			begin
				ldaa	$14,X					;Get Game Data Reset Data
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
				cpx	#lampbuffer0+$0C
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
			ldab	#$0C
			bsr	to_copyblock			;Save current lamp settings
			ldx	#lampflashflag
			ldab	#$08
			bsr	to_copyblock			;Save Flashing lamps too!
			ldx	#$0002
			ldab	#$06
to_copyblock	jmp	copyblock				;Finally, save player game data.

;*********************************************************************
;* Ball Update: This will increment to next player if there is one   
;*              or will increment to next ball. If we are on the last
;*              ball then it jumps to the gameover handler.
;*********************************************************************
balladjust		ldaa	flag_bonusball			;Check the Bonus Ball Flag (00=free balls)
			ifne
				ldx	#aud_totalballs			;AUD: Total Balls Played
				jsr	ptrx_plus_1				;Add 1 to data at X
				ldaa	num_eb				;Number of Extra Balls Remaining
				ifeq
					ldaa	player_up				;Current Player Up (0-3)
					cmpa	num_players				;Number of Players Playing
					inca	
					ifcc
						ldaa	adj_numberofballs+1		;ADJ: LSD Balls per game
						eora	mbip_b0
						anda	#$0F
						beq	gameover				;End of Game
						inc	mbip_b0				;Increment Ball #
						clra	
					endif
					staa	player_up				;Current Player Up (0-3)
				endif
			endif
			rts	

show_hstd		ldx	#score_p1_b1				;Score Buffer 1 Base Index
			stx	temp1
			ldaa	#$04
			begin
				ldab	#$04
				ldx	#aud_currenthstd				;CMOS: Current HSTD
				jsr	block_copy					;Copy Block from X -> temp1, Length = B
				deca
			eqend
			rts

;*********************************************************************
;* Game Over Handler: This will do the basic events run at gameover.
;*                    CheckHSTD and Match.
;*********************************************************************				
gameover		jsr	gr_gameover_event
			ldx	#lampflashflag
			ldab	#$08
			jsr	clear_range				;Clear RAM $30-37 (Lamp Inverts)
			bsr	check_hstd				;Check HSTD
			jsr	do_match				;Match Routine
			ldaa	gr_gameoversound			;Game ROM: Game Over Sound
			jsr	isnd_once				;Play Sound Index(A) Once
powerup_init	ldaa	gr_gameover_lamp			;Game ROM: Game Over Lamp Location
			ldab	gr_bip_lamp				;Game ROM: Ball in Play Lamp Location
			jsr	macro_start				;Start Macro Execution
			
			SOL_($F8)				;Turn Off Solenoid: Flippers Disabled
			.db $17,$00 			;Flash Lamp: Lamp Locatation at RAM $00
			.db $15,$01 			;Turn off Lamp: Lamp Location is at RAM $01
			CPUX_ 				;Resume CPU execution

set_gameover	inc	flag_gameover			;Set Game Over
			ldx	gr_gameoverthread_ptr		;Game ROM: Init Pointer
			jsr	newthread_06			;Push VM: Data in A,B,X,$A6,$A7,$AA=#06
			ldx	#adj_backuphstd			;CMOS: Backup HSTD
			jsr	cmosinc_a				;CMOS,X++ -> A
			bne	show_all_scores			;If there is a HSTD, Show it now.
			jmp	killthread				;Remove Current Thread from VM
			
show_all_scores	begin
				clra
				jsr	store_display_mask		;A -> Display Buffer Toggle )
				ldaa	gr_hs_lamp				;Game ROM: High Score Lamp Location
				jsr	lamp_off				;Turn off Lamp A (encoded):
				jsr	addthread				;Delay Thread
				.db	$90
				bsr  	show_hstd   			;Puts HSTD in All Player Displays(Buffer 1) 
				ldab  comma_flags
				coma 
				tst  	score_p1_b1
				ifeq
					staa  score_p1_b1
					staa  score_p2_b1
					staa  score_p3_b1
					staa  score_p4_b1
					ldaa  #$33
				endif
				staa 	comma_flags
				ldaa 	#$7F
				jsr  	store_display_mask				
				ldaa 	gr_hs_lamp				;Game ROM: High Score Lamp Location
				jsr  	lamp_flash				;Flash Lamp A(encoded)
				jsr  	addthread   			;Delay Thread
				.db 	$70
				jsr	gr_hstdtoggle_event		;Check the hook
				stab  comma_flags
			loopend

;************************************************************************
;* High Score Check Routine: Will iterate through each player to see if
;*                           they beat the high score.
;************************************************************************
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
					ldaa	gr_highscoresound			;Game ROM Data: High Score Sound
					jsr	isnd_once				;Play Sound Index(A) Once
					bsr	send_sound					;time delay
set_hstd				ldx	#adj_hstdcredits			;Adjustment: HSTD Award
					jsr	cmosinc_a				;CMOS,X++ -> A
					ldx	#aud_hstdcredits			;Audit: HSTD Credits Awarded
					jsr	ptrx_plus_a				;Add A to data at X:
					jsr	addcredits				;Add Credits if Possible
					ldaa	aud_currenthstd			;HSTD High Digit
					anda	#$0F
					ifne					;Branch if Score is under 10 million
						ldaa	#$99
						bsr	fill_hstd_digits			;Set HSTD to 9,999,999
						clr	aud_currenthstd			;Clear 10 Million Digit
					endif
				endif
			endif
			rts	

update_hstd		ldx	#aud_currenthstd			;Current HSTD
			inc	sys_temp2
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

;*************************************************************
;* Match Routine: Will generate a random number and put in in
;*                the match display. Then it will compare each
;*                player score too see if we have a match.    
;*                If so, it will increment temp1 for each. 
;*************************************************************
do_match		ldaa	adj_matchenable+1			;Adjustment: LSD Match 00=on 01=off
			rora	
			bcs	to_rts1				;If match is off, get out of here.
			begin
				bsr	get_random				;Get Random Number??
				asla	
				asla	
				asla	
				asla	
				cmpa	#$A0
			csend						;If A>= 0xA0 then try again.
			staa	mbip_b0				;Store Match # in Match/BallinPlay
			clr	temp1
			ldab	#$04
			stab	temp1+1
			ldx	#score_p1_b0			;Player Score Buffers, do each one
			begin
				cmpa	$03,X
				ifeq
					inc	temp1					;Yes, a Match!
				endif
				jsr	xplusb				;X = X + B)
				dec	temp1+1
			eqend						;Do it 4 Times.
			ldab	temp1					;Number of Matches
			ifne						;None, Get outta here.
				ldaa	gr_matchsound			;Game ROM Data: Match Sound
				jsr	isnd_once				;Play Sound Index(A) Once
				bsr	send_sound
				tba	
				ldx	#aud_matchcredits			;Audit: Match Credits
				jsr	ptrx_plus_a				;Add Matches to Audit
				jsr	addcredits				;Add Credits if Possible
			endif
			ldaa	gr_match_lamp			;Game ROM: Match Lamp Location
			jmp	lamp_on				;Turn on Lamp A (encoded):

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
				ldab	mbip_b0				;Ball #
				cmpb	#$F1					;First Ball?
				bne	start_new_game			;Start New Game
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
				ldaa	cred_b0				;Current Credits
				adda	#$99					;Subtract 1
				daa	
				staa	cred_b0				;Store Credits
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
			SOL_($F8)			;.db $31,$F8 		;Disable Flippers
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
			bsr	st_init				;Set up self test
			bsr	check_aumd				;AUMD: + if Manual-Down
			bmi	do_audadj				;Auto-Up, go do audits and adjustments instead
			clra	
st_diagnostics	clr	test_number				;Start at 0
			ldx	#testdata				;Macro Pointer
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
			ldaa	#$18
			jsr	solbuf				;Turn Off Solenoid 24 (Flipper Enable)
			inc	flags_selftest			;Set Test Flag
			ldx	#ram_base
			ldab	#$89
to_clear_range	jmp	clear_range				;Clear RAM from $0000-0089

;**************************************************
;* Next Test: Will advance diagnostics to next
;*            test in sequence, if done, then fall
;*            through to audits/adjustments
;**************************************************
st_nexttest		ldab	#$28
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
					jsr	check_adv			;Advance: - if Triggered
				miend
b_133				bsr	b_129					;#08 -> $0F
show_func			jsr	check_adv				;Advance: - if Triggered
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
			cmpb	#$20
			ifne						;If on Audit 08, Keep Going
				rts						;Else... get outta here!
			endif
			ldx	#aud_hstdcredits			;Audit: HSTD Credits Awarded
			jsr	cmosinc_a				;CMOS,X++ -> A
			staa	score_p2_b0+2
			jsr	cmosinc_a				;CMOS,X++ -> A
			staa	score_p2_b0+3
			ldx	#aud_specialcredits		;Audit: Special Credits
			ldab	#$03
			stab	temp1
			begin
				jsr	cmosinc_b				;CMOS,X++ -> B
				jsr	cmosinc_a				;CMOS,X++ -> A
				adda	score_p2_b0+3
				daa						;\
				staa	score_p2_b0+3			;|
				tba						;|--  Add up HSTD,Special,Replay,Match Credits
				adca	score_p2_b0+2			;|
				daa						;/
				staa	score_p2_b0+2			;Store Result (Player 2 Display)
				dec	temp1
			eqend
			ldx	#score_p4_b0+2
			ldab	#$07
			jsr	clear_range				;Clear RAM from X to X+B
			ldx	score_p2_b0+2
			stx	score_p1_b1				;RAM $48 = Total Free Credits (Player 1 Display)
			ldaa	#$99
			staa	score_p2_b1+1			;RAM $4D = #99 (Player 2 Display)
			tab	
			suba	score_p1_b0+3
			subb	score_p1_b0+2
			adda	#$01
			daa	
			staa	score_p2_b1+3
			tba	
			adca	#$00
			daa	
			staa	score_p2_b1+2
			begin
				ldab	score_p4_b0+3
				ldx	#score_p4_b0+2
				clc
				begin	
					ldaa	$04,X
					adca	$09,X
					daa	
					staa	$04,X
					dex	
					cpx	#score_p3_b0+1
				eqend
				cmpb	score_p4_b0+3
			eqend
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
st_display		clra
			begin	
				begin
					ldx	#score_p1_b0
					ldab	#$24
					jsr	write_range				;RAM $38-$5B = A: Clear all Displays
					jsr	addthread				;End This Routine, Replace with next routine, next byte is timer.
					.db	$18
					jsr	do_aumd				;Check Auto/Manual, return + if Manual
				miend
				com	comma_flags				;Toggle commas on each count
				adda	#$11					;Add one to each digit
				daa	
			csend
			ldab	flags_selftest
			bpl	st_display				;Clear All Displays
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
					ldab	#$08
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
				bsr  	st_display    		;Clear All Displays
				clr  	cred_b0
				bsr  	st_sound
				inc  	cred_b0
				bsr  	st_lamp
				inc  	cred_b0
				bsr  	st_solenoid
				ldx  	#aud_autocycles		;Audit: Auto-Cycles
				jsr  	ptrx_plus_1 		;Add 1 to data at X
			loopend

;****************************************************
;* Main Solenoid Routine - Steps through each solenoid 
;****************************************************			
st_solenoid		begin
				ldab  #$01
				stab 	mbip_b0	 
				ldaa 	#$20	
				begin
					begin
						jsr  	solbuf			;Turn On Outhole Solenoid
						jsr  	addthread    		;End This Routine, Replace with next routine, next byte is timer.
						.db	$40
						jsr  	do_aumd			;AUMD: + if Manual-Down
					miend
					tab  
					ldaa  mbip_b0
					adda 	#$01
					daa  
					staa  mbip_b0
					tba  
					inca 
					cmpa  #$39
				ccend
				ldab  flags_selftest			;Auto-Cycle??
			miend
			rts  

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
st_swnext			ldx  	#switch_masked
				jsr  	unpack_byte    		;Unpack Switch
				bitb 	$00,X
				ifne
					psha 
					inca 
					ldab  #$01
					jsr  	divide_ab
					staa 	mbip_b0
					clra 
					ldab  #$01
					jsr  	isnd_mult			;Play Sound Command A, B Times:
					pula 
					jsr  	addthread    		;End This Routine, Replace with next routine, next byte is timer.
					.db	$40
				endif
				deca 
			plend					;Start Back at the top switch
			bra  st_swnext			;Do Next Switch

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
;*      3 - IC17 ROM Lower Half (Location $F000-$F7FF)
;*      4 - IC17 ROM Upper Half (Location $F800-$FFFF)
;*      5 - IC20 ROM Fault (Location $E800-$EFFF)
;*      6 - IC14 GAME ROM Fault (Location $E000-$E7FF)
;*      7 - IC15 GAME ROM Fault (Location $D800-$DFFF)
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
				cmpb	#$70
				bhi	diag_ramtest
				ifeq
					ldaa	gr_extendedromtest		;Check to see if we need to test additional ROM
					bmi	diag_ramtest
				endif
				ldaa	temp1					
				suba	#$08
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
					inx	
					cpx	#cmos_base+$100
				eqend
				ldx	#cmos_base
				ldaa	temp3
				begin
					tab	
					eorb	$00,X
					andb	#$0F
					bne	cmos_error
					bsr	adjust_a
					inx	
					cpx	#cmos_base+$100
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
			rts	

;*******************************************
;* CPU Startup/Interrupt Vectors go here.
;*******************************************
	
irq_entry		.dw gr_irq_entry	;Goes to Game ROM
swi_entry		.dw gr_swi_entry	;Goes to Game ROM 
nmi_entry		.dw diag
res_entry		.dw reset

	.end


	.end
