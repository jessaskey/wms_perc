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
	.msfirst
#include  "68logic.asm"		;680X logic definitions

;*************************************************************
;* Set the emulation flag to make our file on the $8000 boundary
;* in order for the eprom emulator to work correctly. The 
;* emulator will cover the block from $8000-$ffff. 
;*************************************************************
emulate .equ 0
;*************************************************************

	.org 0000

last_speech_cmd	.block	1
sp_last_random	.block	1	;Stored the value of the last command 0-3 used for 'random' phrase
sp_phrase_tog	.block	1	;Used by command 3 to toggle between phrase_3 and phrase_4
sp_nextwordcmd	.block	1	;If a phrase requires another word, then it is stored here 
bg_type		    .block	1     ;Determines which background sound we will be doing
bg_sec_cnt		.block	1	;Flag to enable background sound
counter1		.block	1
counter2		.block	1
counter3		.block	1
semi_random		.block	1
temp1			.block	1
temp2			.block	1
xtemp1		    .block	2
xtemp2		    .block	2
xtemp3		    .block	2
wave_index
sweep1		    .block	1
sp_pending_com
sweep2		    .block	1
soundbank		.block	1


;***********************************************************
;* Open RAM space begins here for each routine.
;* This space can be used for local sound routines and
;* are not held outside their scope.
;***********************************************************
local_base		.block	1

;*******************************************
;* Speech Variables
.org			local_base
sp_end_ptr		.block	2
sp_phrase_ptr	.block	2
sp_currentbyte	.block	1
sp_currentpitch	.block	1
sp_utindex		.block	1
delaybuf		.block	1

;*******************************************
;* Low Res Sounds
.org			local_base
lr_timer		.block	1
lr_dac		    .block	1
lr_x_ptr		.block	1

;*******************************************
;* Waveform Defined Sounds
;* Modulated Sounds
.org			local_base
mod14			.block	1
mod15			.block	1	
mod16			.block	1
mod17			.block	1
mod18			.block	1
mod19			.block	2
mod1b			.block	1

ptr_sweep_start	.block	2	;001C
ptr_sweep_end	.block	2	;001E
ptr_sweep_last	.block	2	;0020

swp22			.block	1
swp23			.block	1
swp24			.block	1
swpbase		    .block	1

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
sum_dac		    .block	1
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




;*******************************************
;* Hardware Definitions
;*******************************************	
pia_dreg_a           .equ    $0400
pic_creg_a           .equ    $0401
pia_dreg_b           .equ    $0402
pia_creg_b           .equ    $0403

pia_dac_out		    .equ	pia_dreg_a
pia_speech_data	    .equ	pic_creg_a 
pia_sound_command	.equ	pia_dreg_b
pia_speech_clk	    .equ	pia_creg_b

PIA_CONT_OUT        .equ    $20
PIA_CONT_INT        .equ    0
PIA_CONT_OUT_STROBE .equ    0
PIA_CONT_OUT_SETRES .equ    $10
PIA_CONT_OUT_SET    .equ    $08
PIA_CONT_OUT_CLR    .equ    0
PIA_REGSEL_DDR      .equ    0
PIA_REGSEL_OUT      .equ    $04
PIA_CONT_IRQ_HILO   .equ    0
PIA_CONT_IRQ_LOHI   .equ    $02
PIA_CONT_IRQ_ON     .equ    $01
PIA_CONT_IRQ_OFF    .equ    0

PIA_DATA_SET        .equ PIA_CONT_OUT+PIA_CONT_OUT_SETRES+PIA_CONT_OUT_SET+PIA_REGSEL_OUT+PIA_CONT_IRQ_HILO+PIA_CONT_IRQ_OFF    ;3C
PIA_DATA_CLR        .equ PIA_CONT_OUT+PIA_CONT_OUT_SETRES+PIA_CONT_OUT_CLR+PIA_REGSEL_OUT+PIA_CONT_IRQ_HILO+PIA_CONT_IRQ_OFF    ;34.

PIA_CLK_SET         .equ PIA_CONT_OUT+PIA_CONT_OUT_SETRES+PIA_CONT_OUT_SET+PIA_REGSEL_OUT+PIA_CONT_IRQ_LOHI+PIA_CONT_IRQ_ON  ;$3F
PIA_CLK_CLR         .equ PIA_CONT_OUT+PIA_CONT_OUT_SETRES+PIA_CONT_OUT_CLR+PIA_REGSEL_OUT+PIA_CONT_IRQ_LOHI+PIA_CONT_IRQ_ON  ;$37


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
ut_start		
#include  "speech/speechdata.asm"		;Generated Speech Data
ut_end    				

;**********************************************************
;* Speech Test Entry: This routine will play all speech
;*                    and then return.
;**********************************************************

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

speech_data_tbl2	
                reg_speech(ut_you, ut_you_beg, ut_you_end)
                reg_speech(ut_are, ut_are_beg, ut_are_end)
                reg_speech(ut_the, ut_the_beg, ut_the_end)
                reg_speech(ut_spellbinder, ut_spellbinder_beg, ut_spellbinder_end)
                reg_speech(ut_welcome, ut_welcome_beg, ut_welcome_end)
                reg_speech(ut_died, ut_died_beg, ut_died_end)
                reg_speech(ut_horribly, ut_horribly_beg, ut_horribly_end)
                reg_speech(ut_gracefully, ut_gracefully_beg, ut_gracefully_end)
                reg_speech(ut_enemy, ut_enemy_beg, ut_enemy_end)
                reg_speech(ut_frenzy, ut_frenzy_beg, ut_frenzy_end)
                reg_speech(ut_defeated, ut_defeated_beg, ut_defeated_end)
                reg_speech(ut_dragon, ut_dragon_beg, ut_dragon_end)
                reg_speech(ut_slayed, ut_slayed_beg, ut_slayed_end)
                reg_speech(ut_bonus, ut_bonus_beg, ut_bonus_end)
                reg_speech(ut_wizard, ut_wizard_beg, ut_wizard_end)
                reg_speech(ut_spellof, ut_spellof_beg, ut_spellof_end)
                reg_speech(ut_protection, ut_protection_beg, ut_protection_end)
                reg_speech(ut_power, ut_power_beg, ut_power_end)

  
___phnum = 0

#define 	reg_phrase(phrasedef)  \ .dw phrasedef
#defcont   \s_+phrasedef = ___phnum
#defcont   \___phnum .set ___phnum+1

speech_phrases		
                reg_phrase(youaresb)
                reg_phrase(wspellbinder)
                reg_phrase(diedhorribly)
                reg_phrase(diedgraceful)
                reg_phrase(youdied)
                reg_phrase(enemydefeat)
                reg_phrase(enemyfrenzy)
                reg_phrase(defdragon)
                reg_phrase(slaydragon)
                reg_phrase(bonuswiz)
                reg_phrase(spellprotect)
                reg_phrase(spellpower)
  
;*******************************************************************		
;* Phrase Structure     
;*		            
;* First Byte non-negative = Speech Item, 2nd Byte is pitch delay > $00 (smaller values, shorter delay, higher pitch)
;* First Byte negative     = Silence, 2nd byte is LSB of 2's complement value * 5us
;* First Byte Zero	   = End of Phrase
;*******************************************************************
#define	phrase_end		.dw 	$00

#define	addut(a)		.db	(a|$40)
#define	addut(a,b)		.db	a,b


;You are the spellbinder
;Welcome spellbinder
youaresb
        addut(ut_you,$30)
        addut(ut_are,$30)
        addut(ut_the,$30)
        addut(ut_spellbinder,$30)
        l7delay($20)
        phrase_end

wspellbinder
        addut(ut_welcome,$3F)
        l7delay($20)
        addut(ut_spellbinder,$3F)
        phrase_end
        
diedhorribly
        addut(ut_you,$3F)
        l7delay($20)
        addut(ut_died,$3F)
        l7delay($20)
        addut(ut_horribly,$3F)
        phrase_end
        
diedgraceful
        addut(ut_you,$3F)
        l7delay($20)
        addut(ut_died,$3F)
        l7delay($20)
        addut(ut_gracefully,$3F)
        phrase_end
        
youdied
        addut(ut_you,$3F)
        l7delay($20)
        addut(ut_died,$3F)
        phrase_end
        
enemydefeat
        addut(ut_enemy,$3F)
        l7delay($20)
        addut(ut_defeated,$3F)
        phrase_end
        
enemyfrenzy
        addut(ut_enemy,$3F)
        l7delay($20)
        addut(ut_frenzy,$3F)
        phrase_end
        
defdragon
        addut(ut_you,$3F)
        l7delay($20)
        addut(ut_defeated,$3F)
        l7delay($20)
        addut(ut_the,$3F)
        l7delay($20)
        addut(ut_dragon,$3F)
        phrase_end
        
slaydragon
        addut(ut_you,$3F)
        l7delay($20)
        addut(ut_slayed,$3F)
        l7delay($20)
        addut(ut_the,$3F)
        l7delay($20)
        addut(ut_dragon,$3F)
        phrase_end
        
bonuswiz
        addut(ut_bonus,$3F)
        l7delay($20)
        addut(ut_wizard,$3F)
        phrase_end
        
spellprotect
        addut(ut_spellof,$3F)
        l7delay($20)
        addut(ut_protection,$3F)
        phrase_end
        
spellpower
        addut(ut_spellof,$3F)
        l7delay($20)
        addut(ut_power,$3F)
        phrase_end
        
;You died horribly
;You died gracefully
;You died 
;Enemy Defeated
;Enemy Frenzy
;You defeated the Dragon
;You slayed the Dragon
;Bonus Wizard
;Spell of Protection
;Spell of Power					
									
;*************************************************************************
;* SPEECH ROUTINES START HERE!!
;*************************************************************************

		
;*************************************************************************
;* Random Speech Routine
;*************************************************************************
speechrnd_start
		ldx	#$B000			;Point to some random data
		pshb
		psha
		ldaa	semi_random			;Get a semi-random number
		begin
			inx
			jsr	to_xplusa
			ldab	$00,X
			andb	#$03				;Range from 0-3
			cmpb	sp_last_random		;Is it the same as last time, if so, try again
		neend
		stab	sp_last_random		;save new index for next time
		pula					;Get base value
		aba					;Add index to base
		pulb
		jmp speech2_start
	
		
speechtog_start
		com	sp_phrase_tog		;Which phrase did it play last
		ifpl					;Play phrase_3
			inca					;Do phrase_4 instead
		endif
		jmp	speech2_start

;**************************************************************************
;* This is the main speech entry point from the sound command controller
;* 
;* Phrase number is in A
;**************************************************************************
speech2_start   ldx	#speech_phrases               ;Load up the phrase index pointer 
                pshb
                asla
                jsr	xplusa
                ldx	$00,x                         ;Point to the start of the phrase data string
phrase_loop     stx	sp_phrase_ptr                 ;Save pointer for last half of loop
phrase_next     ldx	sp_phrase_ptr
                ldaa	$00,x                         ;Get command byte
                ifne	
            		bpl	utter_load
phrase_wait         ldab	$01,x
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
                pulb
                ifne
                    tba
                    jmp	false_cmd      			
                endif
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
		stx	    xtemp2			;Save our current X value
		ldx	    xtemp1
		ldx	    $02,x				;Get speech end address
		stx	    sp_end_ptr
		ldx	    xtemp2
        ldaa	$01,x
        ifeq
            ldaa	#$0d
        else
            anda	#$40
            ifne
              ;default pitch flag is set, use $0d
              ldaa	#$0d
            else
              ldaa	$01,x
              inx
            endif
		endif
		staa	sp_currentpitch		;save the speech pitch
		inx
		stx	sp_phrase_ptr
		jsr	sp_fill_ramexec		;based on our pitch, set up the delay buffer
		ldx	xtemp1
		ldx	$00,x
		stx	xtemp1			;save the current speech data pointer at $00
		jsr	utter_start			;play the utterance loaded
		bra	phrase_next
		


;***********************************************
;* This routine is called always at the end of
;* the speech delay routine
;***********************************************
sp_delay_ret
		ldaa	#PIA_CLK_CLR            ;$37
		staa	pia_speech_clk               
		bitb	sp_currentbyte			;apply the current bit mask, if result is 0, the bit is 0, etc
		ifeq
			ldaa	#PIA_DATA_CLR                 ;$34
			staa	pia_speech_data               ;Send a 0
			ldaa	#PIA_CLK_SET                  ;$3F
			staa	pia_speech_clk
        else
            ldaa	#PIA_DATA_SET					;$3C send a 1
            staa	pia_speech_data
            ldaa	#PIA_CLK_SET                    ;$3F
            staa	pia_speech_clk			;send final bits properly
			; aslb
			; bcs	sp_getnextbyte			;Get next data byte, this one is done being shifted
			; bpl	sp_delayplus			;not done, are we at the last bit, if not, add some more time
			; cpx	sp_end_ptr
			; bne	sp_delay				;if not at end of speech bytes, then fall through and this will
									; ;end after sending a 1
			; rts						;THIS IS THE WAY OUT. Only here if all speech data was sent
		endif
		; ldaa	#$3C					;send a 1
		; staa	pia_speech_data
		; ldaa	#$3F
		; staa	pia_speech_clk			;send final bits properly
		aslb
		bcs	sp_getnextbyte				;get next data byte, we are done with this one
		bpl sp_delayplus				;not done, are we at the last bit? If not, add some more time
		cpx	sp_end_ptr				;Are we at the end of the speech data bytes yet?
		bne	sp_delay				;branch if not
		rts						;THIS IS THE WAY OUT. Only here if all speech data was sent
        
sp_delayplus					;We are here for all but final bit position in speech data byte
		nop					;this is here to make these bytes take just as long as the routine
		nop					;that gets the next speech data byte.
		bra	sp_delay
		
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

;***********************************************************
;* Required Speech Pointers
;***********************************************************
#IF *>$effa 
	.error "Speech ROM Overflow."
#ENDIF 

	.org $effa

speech_test_ptr		jmp speech_test

;*************************************************************************************************
;* Sound ROM Start
;*
;* Jungle Lord uses a 2716(2kx8) ROM, it is possible to expand this up to 4K if needed.
;*************************************************************************************************
.org $f000

;***************************************
;* checksum must be here for system test
;***************************************	
csum	.db	$9B

;*********************************************************
;* A Little Note
;*********************************************************	

	.text "---SPELLBINDER SOUND---MHAVOC WAS HERE---"

;********************************************
; Main Speech Loop
;********************************************
sploop      begin
                  begin
                        begin
                  		ldaa	#PIA_CLK_CLR            ;$37
                  		staa	pia_speech_clk
                  		bitb	sp_currentbyte
                  		bne	sploopbr_1
                  		ldaa	#PIA_DATA_CLR           ;$34
                  		staa	pia_speech_data
                  		ldaa	#PIA_CLK_SET            ;$3F
                  		staa	pia_speech_clk
                  		aslb
                  		ifcs
                  			jmp sp_getnextbyte			;Are we done with this byte?
                  		endif
                  		bpl	sploopbr_2
                  		cpx	sp_end_ptr
            		loopend
            		rts
sploopbr_1
            		ldaa	#PIA_DATA_SET           ;$3C
            		staa	pia_speech_data
            		ldaa	#PIA_CLK_SET            ;$3F
            		staa	pia_speech_clk
            		aslb
            		ifcs
            			jmp sp_getnextbyte			;Are we done with this byte?
            		endif
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
		ldab	#$91                    ;CMPA
		stab	$00,x
		clr	    $01,x                   ;#$00
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
	
	
speech_test
play_all_speech
		ldaa	#$0d
		staa	sp_currentpitch
		jsr	sp_fill_ramexec		;based on our pitch, set up the delay buffer
		ldx	#ut_start
		stx	xtemp1
		ldx	#ut_end
		stx	sp_end_ptr
		jmp	utter_start
		

.org $f800
	
;*********************************************************
;* Main Entry
;*********************************************************		
swi_entry
reset_entry
			sei
			lds	    #$007F
			ldx	    #$0400		        ;Set up the PIA
			clr	    $01,X			    ;Clear Control Register A
			clr	    $03,X			    ;Clear Control Register B
			ldaa	#$FF
			staa	$00,X			    ;Set DDRA to Outputs
			ldab	#$80
			stab	$02,X			    ;Set DDRB to Inputs except for PB7	
			ldaa	#$37
			staa	$03,X
			ldaa	#$3C
			staa	$01,X			    ;Set up CA2 and CB2 as outputs
			staa	temp1
			stab	$02,X
			clra
			staa	counter2
			staa	counter3	
			staa	bg_sec_cnt      ;Reset background sounds
			staa	counter1
			staa	bg_type
			cli				        ;Ready for commands
			bra	$			        ;Stay Here forever!!!!!!!!!!!!!!!
			
;********************************************************************
;* Copy Sum based sound data to RAM
;********************************************************************
load_sum_data	tab
                asla
                asla
                asla
                aba				        ;Times 9
                ldx	    #local_base
                stx	    xtemp3
                ldx	    #sum_table
                jsr	    xplusa
                ldab	#$09
                jmp	    copy_block		;Copy block from X to xtemp3, B bytes

;*******************************************************************
;* Play Sum Based Sound
;*******************************************************************
;*                                                  Sample
;* sum_t1_init 	Cycle Timer 1 Initial Value		$40
;* sum_t2_init 	Cycle Timer 2 Initial Value		$01
;* sum_t1_adder	Cycle Timer 1 Loop Adder		$00
;* sum_t2_adder	Cycle Timer 2 Loop Adder		$10
;* sum_t2_max	Cycle Timer 2 Max Value			$E1
;* sum_all_max	All Cycle Timer				$0080
;* sum_t1_ext	Cycle Timer 1 Value			$FF
;* sum_dac	 	DAC Amplitude				$FF
;*
;* Rules to Play Comlete Sounds:
;*		sum_t2_max % sum_t2_adder = sum_t2_init
;*		sum_t1_init + sum_t1_ext = sum_t1_init must eventually equal 0
;**************************************************************
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
;* Increments sec background, starts if not playing
;*********************************************************
inc_bg_sec		staa	bg_type
			ldaa	bg_sec_cnt
			anda	#$7F
			;make the background sound go higher than before
			cmpa	#$19
			ifeq
				clra
			endif
			inca
			staa	bg_sec_cnt
			rts
			

;*********************************************************
;* Background Sound Loop
;*********************************************************
play_bg		ldaa	bg_type
			ifeq
				jmp	play_bg_norm
			endif
			jmp 	play_bg_drum


play_bg_norm	ldaa	#$0F
			jsr	load_mod_data
			ldaa	bg_sec_cnt
			asla
			asla
			coma
			jsr	LFB42
			begin
				inc	mod18
				jsr	LFB44
			loopend

play_bg_drum	begin
				jsr 	drum_beat
			loopend
	
drum_beat		ldaa	#$10
			jsr	load_mod_data		;Load up data
			jmp	play_mod_snd		;Play it now!
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
			staa	mod15
			lsrb
			lsrb
			lsrb
			lsrb
			stab	mod14
			ldaa	$01,X
			tab
			lsrb
			lsrb
			lsrb
			lsrb
			stab	mod16
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
			stx	mod19				;Store waveform ptr 
			jsr	copy_sweep			;Copy the Waveform data to RAM
			ldx	xtemp1
			ldaa	$02,X
			staa	mod1b
			jsr	LFB90
			ldx	xtemp1
			ldaa	$03,X
			staa	mod17
			ldaa	$04,X
			staa	mod18
			ldaa	$05,X
			tab
			ldaa	$06,X				;Get index into freq sweep table
			ldx	#sweep_table
			jsr	xplusa
			tba
			stx	ptr_sweep_start		;Store start ptr to sweep data
			clr	swp24
			jsr	xplusa
			stx	ptr_sweep_end		;Store end ptr to sweep data
			rts
			
;******************************************************************
;* This routine will play the sound previously loaded into the
;* various variables.
;******************************************************************
play_mod_snd	ldaa	mod14
			staa	swp23
			begin
				ldx	ptr_sweep_start
				stx	xtemp2
LFAF6				ldx	xtemp2
				ldaa	$00,X
				adda	swp24
				staa	swp22
				cpx	ptr_sweep_end
				ifne
					ldab	mod15
					inx
					stx	xtemp2
					begin
						ldx	#swpbase
						begin
							ldaa	swp22
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
				ldaa	mod16
				bsr	LFB90
				dec	swp23
			eqend
			ldaa	counter2
			oraa	counter3
			ifeq
LFB37				ldaa	mod17
				ifne
					dec	mod18
					ifne
						adda	swp24
LFB42						staa	swp24
LFB44						ldx	ptr_sweep_start
						clrb
						begin
							ldaa	swp24
							tst	mod17
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
						ldaa	mod16
						ifne
							bsr	copy_sweep
							ldaa	mod1b
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
copy_sweep		ldx	#swpbase
			stx	xtemp3
			ldx	mod19
			ldab	$00,X
			inx
			jsr	copy_block		;Copy block from X to xtemp3, B bytes
			ldx	xtemp3
			stx	ptr_sweep_last			;Store away ptr to last byte 
			rts
			

LFB90			tsta
			ifne
				ldx	mod19
				stx	xtemp2
				ldx	#swpbase
				staa	sweep2
				begin
					stx	xtemp3
					ldx	xtemp2
					ldab	sweep2
					stab	sweep1
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
						dec	sweep1
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
irq_entry		lds	    #$007F
                ldaa	pia_sound_command		;Get sound command
                ldab	#$80
                stab	pia_sound_command		;Clear the IRQ
                inc	    semi_random			        ;Increment the semi-random number
                coma
                anda	#$1F
                ;this flag determines if we need to go high
                ;for the next command
                ldab	soundbank
                ifne
                    oraa 	#$20
                    clr	    soundbank
                endif
                cmpa	#$1f
                ifeq
                    inc	    soundbank
                endif
false_cmd		anda	#$3F				;Mask out Sounds/Notes Switch
                psha					;Save for later

                cmpa	#$16
                ifne
                    clr	    counter2
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
                ldaa	$00,X			;Load command routine index
                asla					;*2
                ldx	#handler_table
                bsr	xplusa	
                ldx	$00,X				;Get the command routine pointer
                stx	xtemp2			;store our command routine
                ldx	xtemp1
                ldaa  $01,X                   ;Load var a
                ldab  $02,X                   ;Load var b
                ldx	xtemp2
                cli
                jsr	$00,X				;Jump to command routine
                ldaa	bg_sec_cnt			
                beq	$				;Stay here if no backgroud sounds to do
                clra
                staa	counter2
                staa	counter3
                jmp	play_bg
			
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
snd_tilt 	ldx	#$00E0
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
nmi_entry	begin

                sei
                lds	#$007F
                ldx	#$FFFF
                clrb
                begin
                    adcb	$00,X
                    dex
                    cpx	#csum		;Do a running csum from FFFF-F801
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
                
                
                ldaa #$00
                begin
                    inca
                    psha
                    tab
                    asla
                    aba					;A*3
                    ldx	#command_lookup
                    bsr	xplusa
                    stx	xtemp1
                    ldaa	$00,X			;Load command routine index
                    asla					;*2
                    ldx	#handler_table
                    bsr	xplusa	
                    ldx	$00,X				;Get the command routine pointer
                    stx	xtemp2			;store our command routine
                    ldx	xtemp1
                    ldaa  $01,X                   ;Load var a
                    ldab  $02,X                   ;Load var b
                    ldx	xtemp2
                    cli
                    jsr	$00,X				;Jump to command routine
                    pula
                    cmpa #___snum
            
					; jsr	    low_res_snd
					; jsr	    low_res_snd
					; jsr	    low_res_snd
					; ldaa	#$80
					; staa	pia_sound_command
					; ldaa	#$01
					; jsr	    load_mod_data
					; jsr	    play_mod_snd
					; ldaa	#$0B
					; jsr	    load_mod_data
					; jsr	    play_mod_snd
					; jsr	    simple_snd1
					; ldaa	#$02
					; jsr	    load_sum_data
					; jsr	    play_sum_snd
					; ldab	speech_test_ptr
					; cmpb	#$7E
				eqend
				jsr	speech_test_ptr
			loopend

;**************************************************************
;* Command Routines - these are called directly from the 
;* command table
;**************************************************************
none_cmd          rts

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

speechrnd_cmd	  jmp	speechrnd_start

speechtog_cmd	  jmp	speechtog_start

;**************************************************************
;* Master Command Lookup Table - This table contains two bytes
;* per command, the first byte is the controlling routine that
;* is called and the second byte is the register a data that
;* routine requires. The lookup starts with command 01 since 
;* command 00 does nothing.
;**************************************************************
;sndcmd_tilt    .equ  $01
;sndcmd_gameover .equ 

___snum = 0;

#define SNDCMD(cmdlbl,handler,p1,p2)    \cmdlbl = ___snum^$3f
#defcont                                \___snum .set ___snum+1
#defcont                                \ .db handler
#defcont                                \ .db p1 
#defcont                                \ .db p2 
#defcont                                \ .export cmdlbl

command_lookup   SNDCMD(sndcmd_blank,h_none_cmd,$00,$00)    ;00(3f) - EMPTY ALWAYS
                 SNDCMD(sndcmd_tilt, h_tilt_cmd,$00,$00)    ;01(3e) - Tilt       
                 SNDCMD(sndcmd_melt,h_mod_cmd,$00,$00)             ;02(3d) - Electric Melt
                 SNDCMD(sndcmd_youaresb,h_speech2_cmd,s_youaresb,$00)         ;03(3c) - "You are the spellbinder"
                 SNDCMD(sndcmd_trump,h_speech2_cmd,s_youaresb,$00)         ;04(3b) - Jungle Lord, (Trumpet)"
                 SNDCMD(sndcmd_tfcred,h_mod_cmd,$03,$00)             ;05(3a) - Time Fantasy Credit
                 SNDCMD(sndcmd_dtmiss,h_mod_cmd,$04,$00)             ;06(39) - Double Trouble Miss
                 SNDCMD(sndcmd_thud,h_mod_cmd,$05,$00)             ;07(38) - Thud
                 SNDCMD(sndcmd_gameover,h_mod_cmd,$06,$00)             ;08(37) - Game Over 
                 SNDCMD(sndcmd_boncnt,h_mod_cmd,$07,$00)             ;09(36) - Bonus Count
                 SNDCMD(sndcmd_dtrando,h_speechtog_cmd,$0A,$00)       ;0A(35) - "Jungle Lord in Double Trouble" OR "You in Double Trouble"
                 SNDCMD(sndcmd_tfloopf,h_mod_cmd,$09,$00)             ;0B(34) - TF Loop Forward
                 SNDCMD(sndcmd_jlcred,h_mod_cmd,$0A,$00)             ;0C(33) - Jungle Lord Credit             
                 SNDCMD(sndcmd_tfcomp,h_mod_cmd,$0B,$00)             ;0D(32) - TF Complete Rollovers (Uppder DT's down)
                 SNDCMD(sndcmd_fightt,h_speech2_cmd,s_youaresb,$1B)         ;0E(31) - "Fight Tiger Again" +1B
                 SNDCMD(sndcmd_stampede,h_speech2_cmd,s_youaresb,$00)         ;0F(30) - "Stampede, (trumpet)" 
                 SNDCMD(sndcmd_pbthud,h_lres_cmd,$00,$00)            ;10(2f) - Pop Bumper Thud   
                 SNDCMD(sndcmd_youjl,h_speech2_cmd,s_youaresb,$00)         ;11(2e) - "You Jungle Lord"
                 SNDCMD(sndcmd_funkyrep,h_simpinc_cmd,$00,$00)         ;12(2d) - Funky repeat forever
                 SNDCMD(sndcmd_bgkill, h_bgkill_cmd,$00,$00)          ;13(2c) - Kill All Background
                 SNDCMD(sndcmd_lngexp,h_ssnd1_cmd,$00,$00)           ;14(2b) - Long Slow Explosion
                 SNDCMD(sndcmd_spookybg,h_bg_cmd,$00,$00)              ;15(2a) - Spooky BG
                 SNDCMD(sndcmd_mejl,h_speech2_cmd,s_youaresb,$08)         ;16(29) - "Me Jungle Lord" +08
                 SNDCMD(sndcmd_explode,h_simp1_cmd,$00,$00)           ;17(28) - Explosion
                 SNDCMD(sndcmd_youwinf,h_speech2_cmd,s_youaresb,$08)         ;18(27) - "You Win! Fight in Jungle Again" +08           
                 SNDCMD(sndcmd_fightjt,h_speechrnd_cmd,$11,$3E)       ;19(26) - "Fight Jungle Tiger and Win!" OR "Can you be Jungle Lord?" OR "Beat Tiger and be Jungle Lord" OR "Can you fight in Jungle?" +1F
                 SNDCMD(sndcmd_elecgo,h_sum_cmd,$01,$00)          	  ;1A(25) - Electric Game Over
                 SNDCMD(sndcmd_stwarp,h_sum_cmd,$02,$00)          	  ;1B(24) - Stellar Warp 
                 SNDCMD(sndcmd_highscore,h_sum_cmd,$03,$00)          	  ;1C(23) - High Score
                 SNDCMD(sndcmd_match,h_sum_cmd,$04,$00)          	  ;1D(22) - Match Sound	
                 SNDCMD(sndcmd_trump2,h_speech2_cmd,s_youaresb,$00)         ;1E(21) - "(trumpet)"
                 SNDCMD(sndcmd_na,h_none_cmd,$00,$00)		      ;1F(20) - Placeholder for 2-Sound Bank
                  ;.db   h_speech2_cmd,$15,$00        ;1F(20) - "(trumpet)"
                  ;Extended Sounds start here...
                 SNDCMD(sndcmd_tigern,h_speech2_cmd,s_youaresb,$00)         ;00(1f) - tiger_norm
                 SNDCMD(sndcmd_tigers,h_speech2_cmd,s_youaresb,$00)		  ;01(1e) - tiger_slow
                 SNDCMD(sndcmd_tigerss,h_speech2_cmd,s_youaresb,$00)         ;02(1d) - tiger_slowest
                 SNDCMD(sndcmd_tigerd,h_speech2_cmd,s_youaresb,$00)         ;03(1c) - tiger_double
                 SNDCMD(sndcmd_tigerb,h_speech2_cmd,s_youaresb,$00)         ;04(1b) - tiger_bark
                 SNDCMD(sndcmd_tigerg1,h_speech2_cmd,s_youaresb,$00)         ;05(1a) - tiger_growl
                 SNDCMD(sndcmd_tigerg2,h_speech2_cmd,s_youaresb,$00)         ;06(19) - tiger_growl
                 SNDCMD(sndcmd_tigerg3,h_speech2_cmd,s_youaresb,$00)         ;07(18) - tiger_growl
                 SNDCMD(sndcmd_chirp,h_speech2_cmd,$16,$00)         ;08(17) - simple_chirp
                 SNDCMD(sndcmd_shriek1, h_speech2_cmd,s_youaresb,$00)         ;09(16) - shriek1
                 SNDCMD(sndcmd_shriek2,h_speech2_cmd,s_youaresb,$00)         ;0A(15) - shriek2
                 SNDCMD(sndcmd_shriek3, h_speech2_cmd,s_youaresb,$00)         ;0B(14) - shriek3
                 SNDCMD(sndcmd_shriek4,h_speech2_cmd,s_youaresb,$00)         ;0C(13) - shriek4
                 SNDCMD(sndcmd_shriek5,h_speech2_cmd,s_youaresb,$00)         ;0D(12) - shriek5
                 SNDCMD(sndcmd_monkeyt,h_speech2_cmd,s_youaresb,$00)         ;0E(11) - monkeytune
                 SNDCMD(sndcmd_monkeyo1,h_speech2_cmd,s_youaresb,$00)         ;0F(10) - monkey_oohooh
                 SNDCMD(sndcmd_monkeyo2,h_speech2_cmd,s_youaresb,$00)         ;10(0f) - monkey_oohooh2
                 SNDCMD(sndcmd_monkey03,h_speech2_cmd,s_youaresb,$00)         ;11(0e) - monkey_oohooh3
                 SNDCMD(sndcmd_monkey04,h_speech2_cmd,s_youaresb,$00)         ;12(0d) - monkey_oohooh4
                 SNDCMD(sndcmd_monkey05,h_speech2_cmd,s_youaresb,$00)         ;13(0c) - monkey_oohooh5   
                 SNDCMD(sndcmd_monkeyo6,h_speech2_cmd,s_youaresb,$00)         ;14(0b) - monkey_oohooh6
                 SNDCMD(sndcmd_laugh,h_speech2_cmd,s_youaresb,$00)         ;15(0a) - laughter
                 SNDCMD(sndcmd_trumps,h_speech2_cmd,s_youaresb,$00)         ;16(09) - Trumpet Slower 
                 SNDCMD(sndcmd_fightjl,h_speech2_cmd,s_youaresb,$00)         ;17(08) - Fight Jungle Lord
                 SNDCMD(sndcmd_fighta,h_speech2_cmd,s_youaresb,$00)         ;18(07) - Fight Again!
                 SNDCMD(sndcmd_none,h_none_cmd,$00,$00)         	  ;19(06) -
                 SNDCMD(sndcmd_mejl2,h_speech2_cmd,s_youaresb,$00)         ;1A(05) - "Me Jungle Lord" +08
                 SNDCMD(sndcmd_drumbg,h_bg_cmd,$01,$00)              ;1B(04) - Drum BG
                 SNDCMD(sndcmd_other1,h_sum_cmd,$04,$00)             ;1C(03) - 
                 SNDCMD(sndcmd_other2,h_sum_cmd,$05,$00)             ;1D(02) -
                 SNDCMD(sndcmd_startw,h_sum_cmd,$06,$00)             ;1E(01) - Start Warp
                 SNDCMD(sndcmd_altbon,h_sum_cmd,$09,$00)         	  ;1F(00) - Alt Bonus Count


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
                  reg_handler(simp2_cmd)
                  reg_handler(lres_cmd)
                  reg_handler(simpinc_cmd)
                  reg_handler(bgkill_cmd)
                  reg_handler(ssnd1_cmd)
                  reg_handler(bg_cmd)
                  reg_handler(simp1_cmd)
                  reg_handler(sum_cmd)
                  reg_handler(speech2_cmd)
                  reg_handler(speechrnd_cmd)
                  reg_handler(speechtog_cmd)

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
			.db		$FE,$FF,$FE,$FD,$FB,$F7,$F3,$EE,$E8,$E1,$DA,$D1,$C8,$BF,$B5,$AB
			.db		$A0,$95,$8A,$7F,$75,$6A,$5F,$54,$4A,$40,$37,$2E,$25,$1E,$17,$11
			.db		$0C,$08,$04,$02,$01,$00,$01,$02,$04,$08,$0C,$11,$17,$1E,$25,$2E
			.db		$37,$40,$4A,$54,$5F,$6A,$75,$7F
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
			.db	$32,$13,$09,$00,$00,$14,$50
			
			;electric pulse	.db	$32,$19,$09,$00,$00,$14,$50
			;freaky ship	.db	$32,$19,$01,$FF,$00,$14,$50
			;growing pulse	.db	$32,$19,$09,$00,$00,$14,$00
			;centaurish		.db	$32,$19,$09,$00,$00,$28,$20
			;centaurish pulse	.db	$32,$19,$09,$00,$00,$28,$27
			;fast beat		.db	$32,$10,$09,$00,$00,$14,$50
			;jungle beat	.db	$32,$13,$09,$00,$00,$14,$50

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
	

.org $fff8			
;************************************************
;* CPU Vectors
;************************************************	
irq_vector	.dw irq_entry
swi_vector	.dw swi_entry
nmi_vector	.dw nmi_entry
res_vector	.dw reset_entry




.end