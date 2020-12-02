
;*************************************************************************************************
;* Sound ROM Start
;*
;* Jungle Lord uses a 2716(2kx8) ROM, it is possible to expand this up to 4K if needed.
;*************************************************************************************************

.org $f800

;***************************************
;* checsum must be here for system test
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
			staa	X000A
			stab	$02,X
			clra
			staa	X0007
			staa	X0008
			staa	X0004
			staa	X0005
			staa	X0006
			cli				;Ready for commands
			bra	$			;Stay Here forever!!!!!!!!!!!!!!!
			

LF82E
			tab
			asla
			asla
			asla
			aba
			ldx	#$0014
			stx	X0010
			ldx	#mono_table
			jsr	xplusa
			ldab	#$09
			jmp	LF917


LF843
			ldaa	X001C
			staa	dac_out
LF848
			ldaa	X0014
			staa	X001D
			ldaa	X0015
			staa	X001E
			begin
				ldx	X0019
LF852
				ldaa	X001D
				com	dac_out
LF857
				dex
				ifne
					deca
					bne	LF857
					com	dac_out
					ldaa	X001E
				LF862
					dex
					ifne
						deca
						bne	LF862
						bra	LF852
					endif
				endif
				ldaa	dac_out
				ifpl
					coma
				endif
				adda	#$00
				staa	dac_out
				ldaa	X001D
				adda	X0016
				staa	X001D
				ldaa	X001E
				adda	X0017
				staa	X001E
				cmpa	X0018
			eqend
			ldaa	X001B
			ifne
				adda	X0014
				staa	X0014
				bne	LF848
			endif
			rts
			

LF890
			ldaa	#$01
			staa	X001B
			ldab	#$03
			bra	LF8A2

			.db	$86,$FF,$97,$1B
			.db	$86,$60,$C6,$FF
			.db	$20,$00

LF8A2
			staa	X001A
			ldaa	#$FF
			staa	dac_out
			stab	X0016
			begin
				ldab	X0016
				begin
					ldaa	X000B
					lsra
					lsra
					lsra
					eora	X000B
					lsra
					ror	X000A
					ror	X000B
					ifcs
						com	dac_out
					endif
					ldaa	X001A
					begin
						deca
					eqend
					decb
				eqend
				ldaa	X001A
				adda	X001B
				staa	X001A
			eqend
			rts
			
LF8D1
			ldaa	#$20
			staa	X0016
			staa	X0019
			ldaa	#$01
			ldx	#$0001
			ldab	#$FF
			bra	LF8E0

LF8E0
			staa	X0014
LF8E2
			stx	X0017
LF8E4
			stab	X0015
			ldab	X0016
			begin
				ldaa	X000B
				lsra
				lsra
				lsra
				eora	X000B
				lsra
				ror	X000A
				ror	X000B
				ldaa	#$00
				ifcs
					ldaa	X0015
				endif
				staa	dac_out
				ldx	X0017
				begin
					dex
				eqend
				decb
			eqend
			ldab	X0015
			subb	X0014
			ifne
				ldx	X0017
				inx
				ldaa	X0019
				beq	LF8E4
				bra	LF8E2
			endif
			rts
			

LF917
			psha
			begin
				ldaa	$00,X
				stx	xtemp1
				ldx	X0010
				staa	$00,X
				inx
				stx	X0010
				ldx	xtemp1
				inx
				decb
			eqend
			pula
			rts
			

;*******************************************************
;* Chime Handler:
;*******************************************************
snd_chime
			anda	#$1F
			beq	$			;should never get $00, if so, halt here
			anda	#$0F			;only 15 possible chime sounds
			ldx	#$0014
			stx	X0010
			ldx	#chime_table_1
			jsr	xplusa
			ldaa	$00,X
			staa	X0024
			ldx	#$FCE7
			ldab	#$10
			jsr	LF917
			ldx	#chime_table_2
			ldab	$00,X
			begin
				stab	X0026
				stx	X0010
				begin
					ldx	#$0014
					ldab	#$08
					stab	X0025
					begin
						ldaa	$00,X
						ldab	X0024
						tst	X0026
						ifeq
							suba	$08,X
							staa	$00,X
							subb	#$03
						endif
						inx
						staa	dac_out
						begin
							decb
						eqend
						dec	X0025
					eqend
					dec	X0026
				miend
				ldx	X0010
				inx
				ldab	$00,X
			eqend
			bra	$

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
low_res_snd
			ldx	#low_res_table
			stx	X0016
LF986
			ldx	X0016
			ldaa	$00,X
			ifne
				ldab	$01,X
				andb	#$F0
				stab	X0015
				ldab	$01,X
				inx
				inx
				stx	X0016
				staa	X0014
				andb	#$0F
				begin
					ldaa	X0015
					staa	dac_out
					ldaa	X0014
					begin
						ldx	#$0005
						begin
							dex
						eqend
						deca
					eqend
					clr	dac_out
					ldaa	X0014
					begin
						ldx	#$0005
						begin
							dex
						eqend
						deca
					eqend
					decb
				eqend
				bra	LF986
			endif
			rts
			
LF9C0
			ldaa	X0005
			oraa	#$80
			staa	X0005
			ldab	X0004
			andb	#$7F
			cmpb	#$24
			ifeq
				clrb
			endif
			incb
			stab	X0004
			rts
			

LF9D3
			ldaa	#$07
			jsr	LF82E
			ldab	X0004
			cmpb	#$20
			ifge
				ldab	#$20
			endif
			ldx	#$0038
			ldaa	#$20
			sba
			tab
LF9E7
			cmpb	#$0F
			ifge
				ldaa	#$10
				jsr	xplusa
				decb
				bra	LF9E7
			endif
			begin
				ldaa	#$08
				jsr	xplusa
				decb
			eqend
			stx	X0019
			ldaa	X000A
			asla
			adda	X000A
			adda	#$0B
			staa	X000A
			staa	X0014
			begin
				jsr	LF843
			loopend
			

LFA0D
			clr	X0004
			clr	X0005
			rts
			

LFA14
			ldaa	X0004
			oraa	#$80
			staa	X0004
			ldaa	X0005
			anda	#$7F
			cmpa	#$1D
			ifeq
				clra
			endif
			inca
			staa	X0005
			rts
			

LFA27
			ldaa	#$0F
			jsr	LFA88
			ldaa	X0005
			asla
			asla
			coma
			jsr	LFB42
			begin
				inc	X0018
				jsr	LFB44
			loopend
			

LFA3C
			ldaa	#$08
			jsr	LF82E
			ldab	X0006
			cmpb	#$1F
			ifeq
				clrb
			endif
			incb
			stab	X0006
			ldaa	#$20
			sba
			clrb
LFA4F
			cmpa	#$14
			ifge
				addb	#$0E
				deca
				bra	LFA4F
			endif
			begin
				addb	#$05
				deca
			eqend
			stab	X0014
			begin
				jsr	LF843
			loopend
			

LFA64
			ldaa	X0007
			ifeq
				inc	X0007
				ldaa	#$0D
				jsr	LFA88
				jmp	LFAEE
			endif
			jmp	LFB37
			

LFA76
			ldaa	X0008
			ifeq
				inc	X0008
				ldaa	#$0E
				jsr	LFA88
				jmp	LFAEE
			endif
			jmp	LFB37
			

LFA88
			tab
			aslb
			aba
			aba
			aba
			ldx	#$FE68
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
			staa	X0012
			stx	X000C
			ldx	#$FD8D
LFAB2
			dec	X0012
			ifpl
				ldaa	$00,X
				inca
				jsr	xplusa
				bra	LFAB2
			endif
			stx	X0019
			jsr	LFB7E
			ldx	X000C
			ldaa	$02,X
			staa	X001B
			jsr	LFB90
			ldx	X000C
			ldaa	$03,X
			staa	X0017
			ldaa	$04,X
			staa	X0018
			ldaa	$05,X
			tab
			ldaa	$06,X
			ldx	#envelope_table
			jsr	xplusa
			tba
			stx	X001C
			clr	X0024
			jsr	xplusa
			stx	X001E
			rts
			

LFAEE
			ldaa	X0014
			staa	X0023
			begin
				ldx	X001C
				stx	xtemp1
LFAF6
				ldx	xtemp1
				ldaa	$00,X
				adda	X0024
				staa	X0022
				cpx	X001E
				ifeq
					ldab	X0015
					inx
					stx	xtemp1
					begin
						ldx	#$0025
						begin
							ldaa	X0022
							begin
								deca
							eqend
							ldaa	$00,X
							staa	dac_out
							inx
							cpx	X0020
						endif
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
			ldaa	X0007
			oraa	X0008
			ifne
				ldaa	X0017
				ifne
					dec	X0018
					ifne
						adda	X0024
LFB42						staa	X0024
LFB44						ldx	X001C
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
LFB5A								tstb
								beq	LFB65
								bra	LFB6E
							endif
							tstb
							ifeq
								stx	X001C
								incb
							endif
LFB65							inx
							cpx	X001E
						eqend
						tstb
						ifeq
							rts
						endif
LFB6E						stx	X001E
						ldaa	X0016
						ifne
							bsr	LFB7E
							ldaa	X001B
							bsr	LFB90
						endif
						jmp	LFAEE
					endif
				endif
			endif
			rts
			

LFB7E
			ldx	#$0025
			stx	X0010
			ldx	X0019
			ldab	$00,X
			inx
			jsr	LF917
			ldx	X0010
			stx	X0020
			rts
			

LFB90
			tsta
			ifne
				ldx	X0019
				stx	xtemp1
				ldx	#$0025
				staa	X0013
				begin
					stx	X0010
					ldx	xtemp1
					ldab	X0013
					stab	X0012
					ldab	$01,X
					lsrb
					lsrb
					lsrb
					lsrb
					inx
					stx	xtemp1
					ldx	X0010
					ldaa	$00,X
					begin
						sba
						dec	X0012
					eqend
					staa	$00,X
					inx
					cpx	X0020
				eqend
			endif
			rts

;*************************************************************
;* IRQ Entry: The CPU is interrupted only when the game sends
;*            a sound command to the sound board.
;*************************************************************	

irq_entry
			lds	#$007F
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
				clr	X0007
			endif
			cmpa	#$18
			ifne
				clr	X0008
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
					ldab	sp_played_flag			;Was the speech played succesfully?
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
				beq	LFC64
				cmpa	#$0D
				iflo
					deca
					jsr	LFA88
					jsr	LFAEE
				else
					cmpa	#$17
					iflo
						suba	#$0E
						asla
						ldx	#$FCD3
						bsr	xplusa
						ldx	$00,X
						jsr	$00,X				;INFO: index jump
					else
						suba	#$18
						jsr	LF82E
						jsr	LF843
					endif
				endif
			endif
chk_background	ldaa	X0004				;Here if we had a sound command of $00
			oraa	X0005
			beq	$				;Stay here if no backgroud sounds to do
			clra
			staa	X0007
			staa	X0008
			ldaa	X0004
			ifne
				ifpl
					jmp	LF9D3
				endif
			endif
			jmp	LFA27
			
;*******************************************************
;* Add Value of A to X with carry
;*******************************************************			
xplusa 		stx	xtemp1
			adda	xtemp1+1
			staa	xtemp1+1
			ldaa	xtemp1
			adca	#$00
			staa	xtemp1
			ldx	xtemp1
			rts
			
			
LFC64 		ldx	#$00E0
			begin
				ldaa	#$20
				bsr	xplusa
				begin
					dex
				eqend
				clr	dac_out
				begin
					decb
				eqend
				com	dac_out
				ldx	xtemp1
				cpx	#$1000
			eqend
			bra chk_background


;****************************************************
;* NMI Entry: Sound Test
;****************************************************
nmi_entry
			begin
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
					jsr	LFA88
					jsr	LFAEE
					ldaa	#$0B
					jsr	LFA88
					jsr	LFAEE
					jsr	LF890
					ldaa	#$02
					jsr	LF82E
					jsr	LF843
					ldab	speech_test_ptr
					cmpb	#$7E
				eqend
				jsr	speech_test_ptr
			loopend
			
tab_fcd3	
			.dw	LF898
			.dw   low_res_snd
			.dw	LF9C0
			.dw	LFA3C
			.dw	LFA0D
			.dw 	LF8D1
			.dw	LFA14
			.dw 	LFA64
			.dw	LF890
			.dw	LFA76
			
tab_fce7	
			.db	$DA,$FF,$DA,$80
			.db	$26,$01,$26,$80
			.db	$07,$0A,$07,$00
			.db	$F9,$F6,$F9,$00

chime_table_1		
			.db	$3A,$3E,$50,$46
			.db	$33,$2C,$27,$20
			.db	$25,$1C,$1A,$17
			.db	$14,$11,$10,$33

chime_table_2	
			.db	$08,$03,$02,$01
			.db	$02,$03,$04,$05
			.db	$06,$0A,$1E,$32
			.db	$70,$00

mono_table	
			.db 	$40,$01,$00,$10,$E1,$00,$80,$FF,$FF
			.db	$20,$01,$00,$08,$E1,$00,$80,$FF,$FF
			.db	$28,$01,$00,$08,$81,$02,$00,$FF,$FF
			.db	$00,$FF,$08,$FF,$68,$04,$80,$00,$FF
			.db	$28,$81,$00,$FC,$01,$02,$00,$FC,$FF
			.db	$01,$01,$00,$08,$81,$02,$00,$01,$FF
			.db	$01,$08,$00,$01,$20,$01,$00,$01,$FF
			.db	$60,$01,$57,$08,$E1,$02,$00,$FE,$B0
			.db	$FF,$01,$00,$18,$41,$04,$80,$00,$FF
			.db	$FF,$01,$00,$50,$41,$04,$80,$FF,$FF

low_res_table	
			.db	$01,$FC,$02,$FC,$03,$F8,$04,$F8,$06,$F8
			.db	$08,$F4,$0C,$F4,$10,$F4,$20,$F2,$40,$F1
			.db	$60,$F1,$80,$F1,$A0,$F1,$C0,$F1,$00,$00
			
table_fd8d
			.db	$08,$7F
			.db	$D9,$FF,$D9,$7F
			.db	$24,$00,$24,$08
			.db	$FF,$FF,$FF,$FF
			.db	$00,$00,$00,$00
			.db	$08,$00,$40,$80
			.db	$00,$FF,$00,$80
			.db	$40,$10,$7F,$B0
			.db	$D9,$F5,$FF,$F5
			.db	$D9,$B0,$7F,$4E
			.db	$24,$09,$00,$09
			.db	$24,$4E,$10,$7F
			.db	$C5,$EC,$E7,$BF
			.db	$8D,$6D,$6A,$7F
			.db	$94,$92,$71,$40
			.db	$17,$12,$39,$10
			.db	$76,$FF,$B8,$D0
			.db	$9D,$E6,$6A,$82
			.db	$76,$EA,$81,$86
			.db	$4E,$9C,$32,$63
			.db	$10,$FF,$FF,$FF
			.db	$FF,$FF,$FF,$FF
			.db	$FF,$00,$00,$00
			.db	$00,$00,$00,$00
			.db	$00,$10,$FF,$FF
			.db	$FF,$FF,$00,$00
			.db	$00,$00,$FF,$FF
			.db	$FF,$FF,$00,$00
			.db	$00,$00,$10,$00
			.db	$F4,$00,$E8,$00
			.db	$DC,$00,$E2,$00
			.db	$DC,$00,$E8,$00
			.db	$F4,$00,$00,$48
			.db	$8A,$95,$A0,$AB
			.db	$B5,$BF,$C8,$D1
			.db	$DA,$E1,$E8,$EE
			.db	$F3,$F7,$FB,$FD
			.db	$FE,$FF,$FE,$FD
			.db	$FB,$F7,$F3,$EE
			.db	$E8,$E1,$DA,$D1
			.db	$C8,$BF,$B5,$AB
			.db	$A0,$95,$8A,$7F
			.db	$75,$6A,$5F,$54
			.db	$4A,$40,$37,$2E
			.db	$25,$1E,$17,$11
			.db	$0C,$08,$04,$02
			.db	$01,$00,$01,$02
			.db	$04,$08,$0C,$11
			.db	$17,$1E,$25,$2E
			.db	$37,$40,$4A,$54
			.db	$5F,$6A,$75,$7F
			.db	$10,$59,$7B,$98
			.db	$AC,$B3,$AC,$98
			.db	$7B,$59,$37,$19
			.db	$06,$00,$06,$19
			.db	$37

table_fe68	
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
			
envelope_table
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


	.org fff3
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
			
;************************************************
;* CPU Vectors
;************************************************	
irq_vector	.dw irq_entry
swi_vector	.dw swi_entry
nmi_vector	.dw nmi_entry
res_vector	.dw swi_entry


