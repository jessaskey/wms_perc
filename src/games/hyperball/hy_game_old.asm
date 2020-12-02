;*****************************************************************************
;* Hyperball Game Code
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
;* DB pointed out that this is probably a good idea.
.msfirst	

#include "../../68logic.asm"		;68XX Logic Definitions

#include "hy_wvm.asm"		;Virtual Machine Instruction Definitions
#include "hy_hard.asm"		;Level 7 Hardware Definitions

;Requires system definition file, link to the export file
#include "hy_sys.exp"

;*****************************************************************************
;* Some Global Equates
;*****************************************************************************

irq_per_minute =	$0EFF



;*****************************************************************************
;* Some Global Equates
;*****************************************************************************



 	.org $d000
;---------------------------------------------------------------------------
;  Default game data and basic system tables start at $D000, these can not  
;  ever be moved
;---------------------------------------------------------------------------

gr_gamenumber		.dw $2503
gr_romrevision		.db $F4   

gr_defaudit 
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
;gr_extendedromtest	.db $03
gr_lastswitch		.db (switchtable_end-switchtable)/3
gr_numplayers		.db $01
gr_lamptable_ptr		.dw lamptable		;D04F
gr_switchtable_ptr	.dw switchtable
gr_soundtable_ptr		.dw soundtable
gr_lampflashrate		.db $05
     
gr_specialawardsound	.db $0D       		;D056
gr_p1_startsound		.db $03     		;D057  
gr_p2_startsound		.db $03 			;D058      
D059: 1A       
gr_hssound			.db $11       
gr_gameoversound		.db $1A    			;D05B   
gr_creditsound		.db $00			;credit sound D05C  
    
gr_gameover_lamp		.db $5F			;Game Over Lamp Location D05D     
gr_tilt_lamp		.db $5F       		;D05E

gr_gameoverthread_ptr	.dw gameover_init		;Game Over Init Thread D05F
gr_character_defs_ptr	.dw character_defs	;D061     
gr_coinlockout		.db $05			;Coin Lockout Solenoid D063   
gr_highscoresound		.dw highscoresound	;D064
    
    
gr_switchtypetable		

swtype0	.db 	$00,$02
swtype1	.db 	$00,$09
swtype2	.db 	$00,$04
swtype3	.db 	$00,$01
swtype4	.db 	$02,$05
swtype5	.db 	$08,$05
swtype6	.db 	$00,$00

       
gr_playerstartdata    
  
		.db $00,$00,$00,$00  
		.db $00,$00,$00,$00     
		.db $00,$00,$00,$00     
		.db $00,$00,$00,$00      
		.db $00,$00,$00,$00
		.db $00,$00,$00,$00
		.db $00,$00,$00,$00
		.db $00,$00   
      
gr_playerresetdata	;D092

		.db $00,$00,$00,$00  
		.db $00,$00,$00,$00     
		.db $00,$00,$FF,$03     
		.db $00,$00,$00,$00      
		.db $00,$00,$00,$00
		.db $00,$00,$00,$00
		.db $00,$00,$00,$00
		.db $00,$00 

      
gr_switch_event		rts .db 0	;D0B0
gr_sound_event		rts .db 0 	;D0B2
gr_score_event		rts .db 0
gr_eb_event			rts .db 0
gr_special_event		bra	gr_special   
gr_main_hook		rts .db 0	;Main Loop Begin Hook - rts
gr_ready_event		rts .db 0
gr_addplayer_event 	rts .db 0
gr_gameover_event		rts .db 0
gr_hstdtoggle_event	rts .db 0

;********************************************************
;* System Hooks:
;* These are pointers to code blocks that can be run at
;* certain times within the system. This allows the game
;* to expand upon the system quite a bit in it's functionality.
;* All hooks are pointers to code entry points. You cannot
;* run code here like the event entry points above. If you
;* want to return, then you have to point to an 'rts'  
;* opcode somewhere else, like the sacrificial rts above.
;* You should leave these alone at first until you start
;* getting more complex game rules that need to take 
;* advantage of this flexibility.
;********************************************************
;this should be @$DOC4 for Hyperball, if it isn't, something is wrong
gr_reset_hook_ptr			.dw gr_reset_hook 
gr_main_hook_ptr			.dw gr_main_hook
gr_coin_hook_ptr			.dw gr_coin_hook
gr_game_hook_ptr			.dw gr_game_hook 
gr_player_hook_ptr		.dw gr_player_hook
gr_outhole_hook_ptr		.dw gr_outhole_hook 

;*** Game IRQ Entry ***
gr_irq_entry
	jmp   sys_irq_entry


;*** Game SWI Entry ***
gr_swi_entry
			cli   
			ins   
			ins   
			ins   
			ins   
			ins   
			jmp   macro_start		Begin Macro's

gr_special
D0DC: CE 01 99    ldx   #0199
D0DF: BD EE A2    jsr   cmosinc_b		 ( CMOS,X++ -> B)
D0E2: 27 DE       beq   $D0C2
D0E4: DE FA       ldx   credit_x_temp
D0E6: 09          DEX   
D0E7: 09          DEX   
D0E8: BD FD DB    jsr   cmos_a		 ( CMOS, X -> A )
D0EB: 1B          ABA   
D0EC: 19          DAA   
D0ED: 8D 4C       bsr   $D13B
D0EF: 86 12       ldaa   #12
D0F1: BD EC 3B    jsr   isnd_once
D0F4: C6 01       ldab   #01
D0F6: BD D9 CB    jsr   $D9CB
D0F9: CE 00 5E    ldx   cred_b0
D0FC: 96 EB       ldaa   player_up
D0FE: 27 03       beq   $D103
D100: CE 00 5C    ldx   mbip_b0
D103: 86 01       ldaa   #01
D105: 7E D1 CC    jmp   $D1CC

gr_reset_hook
D108: BD EE DC    jsr   $EEDC	 Restore Backup High Score
D10B: CE 01 2E    ldx   #012E
D10E: DF B8       stx   temp1
D110: CE E5 D0    ldx   #E5D0
D113: E6 00       ldab   $00,X
D115: C4 0F       andb  #0F
D117: 08          inx   
D118: 7E EF 23    jmp   copyblock2

D11B: 8D EB       bsr   $gr_reset_hook
D11D: 7E E9 C4    jmp   $E9C4	Remove Current Thread from Control Stack

gr_game_hook
D120: CE 13 A0    ldx   #13A0
D123: 6F 00       CLR   $00,X
D125: 08          inx   
D126: 8C 13 A7    CMPX  #13
D129: 26 F8       bne   $D123
D12B: CE 01 99    ldx   #0199
D12E: 86 F3       ldaa   #F3
D130: BD EA 83    jsr   solbuf
D133: BD D1 B9    jsr   $D1B9
D136: CE 01 46    ldx   #0146
D139: 8D 00       bsr   $D13B
D13B: 7E EE EE    jmp   a_cmosinc

D13E: 4F          clra  
D13F: 4C          inca  
D140: D6 E7       ldab   flag_gameover
D142: 27 2E       beq   $D172
D144: B7 13 9E    staa   $139E
D147: 16          tab   
D148: CE 01 AB    ldx   #01AB
D14B: 8D 6C       bsr   $D1B9
D14D: 27 08       beq   $D157
D14F: CE 01 6E    ldx   #016E
D152: 8D 65       bsr   $D1B9
D154: 11          CBA   
D155: 25 C6       bcs   $D11D
D157: 86 08       ldaa   #08
D159: CE FB A5    ldx   #FBA5
D15C: BD D5 0E    jsr   $D50E
D15F: 5A          decb  
D160: 26 F5       bne   $D157
D162: CE 03 03    ldx   #0303
D165: FF 13 9A    stx   $139A
D168: 8D 5A       bsr   $D1C4
D16A: 27 B1       beq   $D11D
D16C: 3F          SWI   
D16D: 52          --------------------
D16E: 48          ASLA  
D16F: 75          --------------------
D170: 8F          --------------------
D171: FD          --------------------
D172: B1 13 9E    cmpa  $139E
D175: 26 A6       bne   $D11D
D177: 86 48       ldaa   #48
D179: C6 FF       ldab   #FF
D17B: BD EA 60    jsr   check_threadid
D17E: 25 69       bcs   $D1E9
D180: BD D1 FA    jsr   $D1FA
D183: F6 13 9E    ldab   $139E
D186: CE 01 AB    ldx   #01AB
D189: 8D 2E       bsr   $D1B9
D18B: 27 06       beq   $D193
D18D: B6 11 9A    ldaa   current_credits
D190: 11          CBA   
D191: 25 56       bcs   $D1E9
D193: C1 02       CMPB  #02
D195: 26 10       bne   $D1A7
D197: 8D 23       bsr   $D1BC
D199: F6 13 9B    ldab   $139B
D19C: 36          psha  
D19D: 1B          ABA   
D19E: B7 13 9B    staa   $139B
D1A1: 32          pula  
D1A2: CE 00 5C    ldx   mbip_b0
D1A5: 8D 25       bsr   $D1CC
D1A7: 8D 13       bsr   $D1BC
D1A9: F6 13 9A    ldab   $139A
D1AC: 36          psha  
D1AD: 1B          ABA   
D1AE: B7 13 9A    staa   $139A
D1B1: 32          pula  
D1B2: CE 00 5E    ldx   cred_b0
D1B5: 8D 15       bsr   $D1CC
D1B7: 20 30       bra   $D1E9

D1B9: 7E FD DB    jmp   cmos_a

D1BC: CE 01 6E    ldx   #016E
D1BF: 8D F8       bsr   $D1B9
D1C1: BD FB DF    jsr   $FBDF
D1C4: CE 01 95    ldx   #0195
D1C7: 8D F0       bsr   $D1B9
D1C9: 84 0F       anda  #0F
D1CB: 39          rts   

D1CC: E6 00       ldab   $00,X
D1CE: 2A 02       BPL   $D1D2
D1D0: C4 0F       andb  #0F
D1D2: 1B          ABA   
D1D3: 19          DAA   
D1D4: 81 09       cmpa  #09
D1D6: 2E 02       BGT   $D1DA
D1D8: 8A F0       oraa   #F0
D1DA: A7 00       staa   $00,X
D1DC: 39          rts   

D1DD: CE 00 66    ldx   #0066
D1E0: FF 11 8E    stx   $118E
D1E3: CE E5 5F    ldx   #msg_game
D1E6: BD D2 49    jsr   $D249
D1E9: 7E E9 C4    jmp   $E9C4	Remove Current Thread from Control Stack

D1EC: CE 00 65    ldx   #0065
D1EF: FF 11 92    stx   $1192
D1F2: CE E5 65    ldx   #msg_over
D1F5: BD D2 58    jsr   $D258
D1F8: 20 EF       bra   $D1E9

D1FA: C6 FF       ldab   #FF
D1FC: 7E EA 5B    jmp   kill_threads

gr_outhole_hook
D1FF: 86 78       ldaa   #78
D201: 8D F7       bsr   $D1FA
D203: 96 E8       ldaa   random_bool
D205: 26 05       bne   $D20C
D207: 86 29       ldaa   #29
D209: BD EB 3D    jsr   $EB3D
D20C: 7C 00 E6    INC   flag_tilt
D20F: D6 5E       ldab   cred_b0
D211: 96 EB       ldaa   player_up
D213: 27 02       beq   $D217
D215: D6 5C       ldab   mbip_b0
D217: C1 F0       CMPB  #F0
D219: 26 2B       bne   $D246
D21B: CE E5 58    ldx   #msg_player
D21E: BD D3 0B    jsr   $D30B
D221: 8B 1C       ADDA  #1C
D223: DE B8       ldx   temp1
D225: A7 02       staa   $02,X
D227: 96 EA       ldaa   num_players
D229: 27 04       beq   $D22F
D22B: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
D22E: 60 

D22F: CE D1 DD    ldx	#D1DD
D232: BD EA 24    jsr   newthread_06	 Push Control Stack: Data in A,B,X,$A6,$A7,$AA=#06
D235: CE D1 EC    ldx   #D1EC
D238: BD EA 24    jsr   newthread_06	 Push Control Stack: Data in A,B,X,$A6,$A7,$AA=#06
D23B: 8D 09       bsr   $D246
D23D: 86 09       ldaa   #09
D23F: BD EC 3B    jsr   isnd_once
D242: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
D245: F0 

D246: 7E D2 D6	  jmp 	$D2D6   
D249: A6 00       ldaa   $00,X
D24B: 84 0F       anda  #0F
D24D: BD EE 3E    jsr   xplusa	 ( X = X + A)
D250: E6 00       ldab   $00,X
D252: 09          DEX   
D253: 8D 21       bsr   $D276
D255: 26 F9       bne   $D250
D257: 39          rts   

D258: A6 00       ldaa   $00,X
D25A: 84 0F       anda  #0F
D25C: 08          inx   
D25D: E6 00       ldab   $00,X
D25F: 8D 2A       bsr   $D28B
D261: 26 F9       bne   $D25C
D263: 39          rts   

D264: 8D 55       bsr   $D2BB
D266: 8D E1       bsr   $D249
D268: 5F          clrb  
D269: 86 01       ldaa   #01
D26B: 20 E6       bra   $D253

D26D: 8D 41       bsr   $D2B0
D26F: 8D E7       bsr   $D258
D271: 5F          clrb  
D272: 86 01       ldaa   #01
D274: 20 E9       bra   $D25F

D276: 36          psha  
D277: 37          PSHB  
D278: FF 11 8C    stx   $118C
D27B: CE 00 60    ldx   #0060
D27E: 17          TBA   
D27F: E6 00       ldab   $00,X
D281: A7 00       staa   $00,X
D283: 08          inx   
D284: BC 11 8E    CPX   $118E
D287: 26 F5       bne   $D27E
D289: 20 13       bra   $D29E

D28B: 36          psha  
D28C: 37          PSHB  
D28D: FF 11 8C    stx   $118C
D290: CE 00 6B    ldx   #006B
D293: 17          TBA   
D294: E6 00       ldab   $00,X
D296: A7 00       staa   $00,X
D298: 09          DEX   
D299: BC 11 92    CPX   $1192
D29C: 26 F5       bne   $D293
D29E: FE 11 8C    ldx   $118C
D2A1: 33          PULB  
D2A2: 96 0A       ldaa   $000A
D2A4: 26 02       bne   $D2A8
D2A6: 86 09       ldaa   #09
D2A8: 97 D5       staa   thread_timer_byte
D2AA: 32          pula  
D2AB: BD E9 71    jsr   delaythread
D2AE: 4A          deca  
D2AF: 39          rts   

D2B0: FF 11 90    stx   $1190
D2B3: CE 00 5F    ldx   #005F
D2B6: FF 11 92    stx   $1192
D2B9: 20 09       bra   $D2C4

D2BB: FF 11 90    stx   $1190
D2BE: CE 00 6C    ldx   #006C
D2C1: FF 11 8E    stx   $118E
D2C4: FE 11 90    ldx   $1190
D2C7: 39          rts   

D2C8: 8D E6       bsr   $D2B0
D2CA: 8D BF       bsr   $D28B
D2CC: 26 FC       bne   $D2CA
D2CE: 39          rts   

D2CF: 8D EA       bsr   $D2BB
D2D1: 8D A3       bsr   $D276
D2D3: 26 FC       bne   $D2D1
D2D5: 39          rts   

D2D6: 36          psha  
D2D7: 37          PSHB  
D2D8: DF C2       stx   sys_temp5
D2DA: CE 00 60    ldx   #0060
D2DD: DF B8       stx   temp1
D2DF: 8D 73       bsr   $D354
D2E1: DE C2       ldx   sys_temp5
D2E3: E6 00       ldab   $00,X
D2E5: DE B8       ldx   temp1
D2E7: BD EC 32    jsr   split_ab
D2EA: F7 11 88    stab   $1188
D2ED: BD EE 8C    jsr   xplusb
D2F0: DF B8       stx   temp1
D2F2: DE C2       ldx   sys_temp5
D2F4: 33          PULB  
D2F5: 32          pula  
D2F6: 39          rts   

D2F7: 36          psha  
D2F8: 37          PSHB  
D2F9: 86 26       ldaa   #26
D2FB: 5A          decb  
D2FC: 27 F6       beq   $D2F4
D2FE: A7 00       staa   $00,X
D300: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
D303: 02   

D304: 4C          inca  
D305: 81 2A       cmpa  #2A
D307: 27 F0       beq   $D2F9
D309: 20 F3       bra   $D2FE

D30B: 8D C9       bsr   $D2D6
D30D: E6 00       ldab   $00,X
D30F: C4 0F       andb  #0F
D311: 08          inx   
D312: 7E EE FB    jmp   $EEFB

D315: 8D BF       bsr   $D2D6
D317: A6 00       ldaa   $00,X
D319: 84 0F       anda  #0F
D31B: C6 0B       ldab   #0B
D31D: 36          psha  
D31E: 08          inx   
D31F: FF 11 8A    stx   $118A
D322: A6 00       ldaa   $00,X
D324: 97 6B       staa   $006B
D326: CE 00 6A    ldx   #006A
D329: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
D32C: 04 

D32D: A6 01       ldaa   $01,X
D32F: A7 00       staa   $00,X
D331: 4F          clra  
D332: A7 01       staa   $01,X
D334: 09          DEX   
D335: 5A          decb  
D336: F1 11 88    CMPB  $1188
D339: 26 EE       bne   $D329
D33B: FE 11 8A    ldx   $118A
D33E: 7C 11 88    INC   $1188
D341: 32          pula  
D342: 4A          deca  
D343: 26 D6       bne   $D31B
D345: 39          rts   

D346: BD EA F8    jsr   $EAF8
D349: 5F          clrb  
D34A: 20 02       bra   $D34E

D34C: C6 7F       ldab   #7F
D34E: BD D8 58    jsr   $D858
D351: CE 00 6C    ldx   #006C
D354: 4F          clra  
D355: C6 0C       ldab   #0C
D357: 7E F8 A9    jmp   write_range

D35A: 5A          decb  
D35B: FE F2 FF    ldx   $F2FF
D35E: C0 10       subb  #10
D360: 48          ASLA  
D361: CE D3 71    ldx   #D371
D364: BD EA 24    jsr   newthread_06	 Push Control Stack: Data in A,B,X,$A6,$A7,$AA=#06
D367: F5 57 FB    BITB  $57FB
D36A: FD          --------------------
D36B: 5A          decb  
D36C: F0 09 31    subb  $0931
D36F: 46          RORA  
D370: 03          --------------------
D371: 3F          SWI   
D372: 52          --------------------
D373: C0 53       subb  #53
D375: 18          --------------------
D376: 03          --------------------
D377: 31          INS   
D378: F6 52 A0    ldab   $52A0
D37B: 55          --------------------
D37C: 08          inx   
D37D: 00          --------------------
D37E: 93          --------------------
D37F: 8A 04       oraa   #04
D381: CE E5 F4    ldx   #E5F4
D384: 8D 85       bsr   $D30B
D386: 8D C4       bsr   $D34C
D388: 86 31       ldaa   #31
D38A: BD D8 53    jsr   $D853
D38D: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
D390: 06      

D391: 4A          deca  
D392: 26 F6       bne   $D38A
D394: CE 00 00    ldx   #0000
D397: FF 11 98    stx   $1198
D39A: 3F          SWI   
D39B: AF 39       STS   $39,X
D39D: A4 B9       anda  $B9,X
D39F: 51          --------------------
D3A0: 60 34       NEG   $34,X
D3A2: 06          TAP   
D3A3: 01          NOP   
D3A4: 02          --------------------
D3A5: 07          TPA   
D3A6: 52          --------------------
D3A7: 00          --------------------
D3A8: A5 DD       BITA  $DD,X
D3AA: 57          ASRB  
D3AB: EA F8       ORB   $F8,X
D3AD: 5C          incb  
D3AE: FA 43 

gr_player_hook
D3B0: 7C    	ORB   $437C
D3B1: 00          --------------------
D3B2: E6 CE       ldab   $CE,X
D3B4: E5 58       BITB  $58,X
D3B6: BD D3 0B    jsr   $D30B
D3B9: DE CF       ldx   current_thread
D3BB: E7 0D       stab   $0D,X
D3BD: 96 EB       ldaa   player_up
D3BF: 8B 1C       ADDA  #1C
D3C1: DE B8       ldx   temp1
D3C3: A7 02       staa   $02,X
D3C5: BD D3 4C    jsr   $D34C
D3C8: BD DF 11    jsr   $DF11
D3CB: CE E3 34    ldx   #E334
D3CE: BD D5 0D    jsr   $D50D
D3D1: 8D 20       bsr   $D3F3
D3D3: 7F 13 9D    CLR   $139D
D3D6: 3F          SWI   
D3D7: 5B          --------------------
D3D8: FC          --------------------
D3D9: E6 00       ldab   $00,X
D3DB: 06          TAP   
D3DC: C2 00       SBCB  #00
D3DE: C6 05       ldab   #05
D3E0: 18          --------------------
D3E1: 0A          CLV   
D3E2: 19          DAA   
D3E3: 4F          clra  
D3E4: 29 40       BVS   $D426
D3E6: B0 0B 5A    SUBA  $0B5A
D3E9: FC          --------------------
D3EA: E1 00       CMPB  $00,X
D3EC: 12          --------------------
D3ED: A5 FF       BITA  $FF,X
D3EF: B1 FF 8F    cmpa  $FF8F
D3F2: F5 D6 EB    BITB  $D6EB
D3F5: 17          TBA   
D3F6: CE 13 9A    ldx   #139A
D3F9: BD EE 8C    jsr   xplusb
D3FC: E6 00       ldab   $00,X
D3FE: 39          rts   

D3FF: B0 43 31    SUBA  $4331
D402: 06          TAP   
D403: 17          TBA   
D404: 00          --------------------
D405: C1 10       CMPB  #10
D407: E7 7A       stab   $7A,X
D409: B1 FF 5B    cmpa  $FF5B
D40C: FC          --------------------
D40D: E1 00       CMPB  $00,X
D40F: F7 14 00    stab   $1400
D412: D9 30       ADCB  $0030
D414: AE C0       LDS   $C0,X
D416: 31          INS   
D417: F9 53 40    ADCB  $5340
D41A: 55          --------------------
D41B: FF 48 04    stx   $4804
D41E: 4F          clra  
D41F: 97 E6       staa   flag_tilt
D421: 97 0A       staa   $000A
D423: CE 01 97    ldx   #0197
D426: BD EE A2    jsr   cmosinc_b		 ( CMOS,X++ -> B)
D429: 86 11       ldaa   #11
D42B: C4 0F       andb  #0F
D42D: 27 0A       beq   $D439
D42F: 4A          deca  
D430: 5A          decb  
D431: 26 FC       bne   $D42F
D433: 81 04       cmpa  #04
D435: 2E 02       BGT   $D439
D437: 86 04       ldaa   #04
D439: 97 0C       staa   $000C
D43B: 96 05       ldaa   $0005
D43D: D6 03       ldab   $0003
D43F: 26 32       bne   $D473
D441: 8B 01       ADDA  #01
D443: 19          DAA   
D444: 97 05       staa   $0005
D446: 36          psha  
D447: C6 0F       ldab   #0F
D449: D7 07       stab   $0007
D44B: C6 04       ldab   #04
D44D: CE 01 9F    ldx   #019F
D450: BD EE 92    jsr   cmosinc_a		 ( CMOS,X++ -> A)
D453: 84 0F       anda  #0F
D455: 27 0A       beq   $D461
D457: 7A 00 07    DEC   $0007
D45A: D1 07       CMPB  $0007
D45C: 27 03       beq   $D461
D45E: 4A          deca  
D45F: 26 F6       bne   $D457
D461: D6 05       ldab   $0005
D463: BD F8 9D    jsr   $F89D
D466: 96 07       ldaa   $0007
D468: 81 04       cmpa  #04
D46A: 27 04       beq   $D470
D46C: 4A          deca  
D46D: 5A          decb  
D46E: 26 F8       bne   $D468
D470: 97 07       staa   $0007
D472: 32          pula  
D473: 5F          clrb  
D474: 36          psha  
D475: 96 0C       ldaa   $000C
D477: 4A          deca  
D478: 81 03       cmpa  #03
D47A: 2D 02       BLT   $D47E
D47C: 97 0C       staa   $000C
D47E: 32          pula  
D47F: 8B 99       ADDA  #99
D481: 19          DAA   
D482: 27 07       beq   $D48B
D484: 5C          incb  
D485: C1 05       CMPB  #05
D487: 27 EA       beq   $D473
D489: 20 F4       bra   $D47F

D48B: 96 05       ldaa   $0005
D48D: C1 04       CMPB  #04
D48F: 27 70       beq   $D501
D491: 7D 00 03    TST   $0003
D494: 26 0E       bne   $D4A4
D496: CE E4 A2    ldx   #E4A2
D499: BD D3 F9    jsr   $D3F9
D49C: 81 09       cmpa  #09
D49E: 2D 02       BLT   $D4A2
D4A0: C6 20       ldab   #20
D4A2: D7 03       stab   $0003
D4A4: 96 04       ldaa   $0004
D4A6: 26 04       bne   $D4AC
D4A8: 86 14       ldaa   #14
D4AA: 97 04       staa   $0004
D4AC: CE 01 9B    ldx   #019B
D4AF: BD EE A2    jsr   cmosinc_b		 ( CMOS,X++ -> B)
D4B2: C1 20       CMPB  #20
D4B4: 2F 02       BLE   $D4B8
D4B6: C6 20       ldab   #20
D4B8: BD F8 9D    jsr   $F89D
D4BB: 17          TBA   
D4BC: D6 05       ldab   $0005
D4BE: BD F8 9D    jsr   $F89D
D4C1: C1 01       CMPB  #01
D4C3: 27 01       beq   $D4C6
D4C5: 58          ASLB  
D4C6: 10          SBA   
D4C7: 25 04       bcs   $D4CD
D4C9: 81 06       cmpa  #06
D4CB: 2C 02       BGE   $D4CF
D4CD: 86 06       ldaa   #06
D4CF: 97 09       staa   $0009
D4D1: CE D5 13    ldx   #D513
D4D4: 8D 29       bsr   $D4FF
D4D6: CE DD 87    ldx   #DD87
D4D9: 8D 24       bsr   $D4FF
D4DB: BD FB 94    jsr   $FB94
D4DE: C6 06       ldab   #06
D4E0: 81 25       cmpa  #25
D4E2: 22 0C       BHI   $D4F0
D4E4: C6 04       ldab   #04
D4E6: CE DA AE    ldx   #DAAE
D4E9: 8D 14       bsr   $D4FF
D4EB: CE DA 86    ldx   #DA86
D4EE: 8D 0F       bsr   $D4FF
D4F0: D7 08       stab   $0008
D4F2: CE D8 85    ldx   #D885
D4F5: 8D 08       bsr   $D4FF
D4F7: CE D5 AA    ldx   #D5AA
D4FA: 8D 03       bsr   $D4FF
D4FC: CE DB E5    ldx   #DBE5
D4FF: 20 0C       bra   $D50D

D501: 86 2E       ldaa   #2E
D503: BD F1 FD    jsr   $F1FD
D506: 86 10       ldaa   #10
D508: 97 0F       staa   $000F
D50A: CE DF F0    ldx   #DFF0
D50D: 4F          clra  
D50E: 97 C8       staa   thread_priority
D510: 7E E9 D8    jmp   newthread_sp	Push Control Stack: Data in A,B,X,$AA,$A6,$A7

D513: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
D516: 03   

D517: 96 08       ldaa   $0008
D519: 27 F8       beq   $D513
D51B: CE D9 F1    ldx   #D9F1
D51E: 8D ED       bsr   $D50D
D520: CE 01 9D    ldx   #019D
D523: BD EE 92    jsr   cmosinc_a		 ( CMOS,X++ -> A)
D526: 84 0F       anda  #0F
D528: D6 05       ldab   $0005
D52A: C1 09       CMPB  #09
D52C: 2F 02       BLE   $D530
D52E: C6 09       ldab   #09
D530: 10          SBA   
D531: 24 01       bcc   $D534
D533: 4F          clra  
D534: 8B 0B       ADDA  #0B
D536: D6 09       ldab   $0009
D538: C1 0C       CMPB  #0C
D53A: 2F 01       BLE   $D53D
D53C: 54          LSRB  
D53D: D7 D5       stab   thread_timer_byte
D53F: BD E9 71    jsr   delaythread
D542: 4A          deca  
D543: 26 F1       bne   $D536
D545: 20 D0       bra   $D517

D547: 52          --------------------
D548: B0 5B FB    SUBA  $5BFB
D54B: D0 30       subb  $0030
D54D: FE F2 F0    ldx   $F2F0
D550: F2 F0 09    SBCB  $F009
D553: 5A          decb  
D554: FE F2 F0    ldx   $F2F0
D557: B0 0A 71    SUBA  $0A71
D55A: 8F          --------------------
D55B: ED          --------------------
D55C: 52          --------------------
D55D: F0 E4 57    subb  $E457
D560: FE CC 7B    ldx   $CC7B
D563: 03          --------------------
D564: 3F          SWI   
D565: 74 5A FE    LSR   $5AFE
D568: F2 F0 A0    SBCB  $F0A0
D56B: F9 52 A1    ADCB  $52A1
D56E: AD D6       jsr   $D6,X
D570: AD 64       jsr   $64,X
D572: 48          ASLA  
D573: CE E5 6B    ldx   #E56B
D576: BD D3 0B    jsr   $D30B
D579: C0 14       subb  #14
D57B: A2 D6       SBCA  $D6,X
D57D: F1 31 F6    CMPB  $31F6
D580: 78 31 06    ASL   $3106
D583: 78 B0 FF    ASL   $B0FF
D586: 5B          --------------------
D587: FC          --------------------
D588: E0 00       subb  $00,X
D58A: F0 F8 C1    subb  $F8C1
D58D: 00          --------------------
D58E: A2 C8       SBCA  $C8,X
D590: 03          --------------------
D591: 71          --------------------
D592: 5B          --------------------
D593: F6 4E 02    ldab   $4E02
D596: 19          DAA   
D597: 4E          --------------------
D598: A0 5B       SUBA  $5B,X
D59A: 5A          decb  
D59B: FD          --------------------
D59C: E0 0D       subb  $0D,X
D59E: F2 51 10    SBCB  $5110
D5A1: B1 3A 5A    cmpa  $3A5A
D5A4: D0 E1       subb  $00E1
D5A6: EA DC       ORB   $DC,X
D5A8: 01          NOP   
D5A9: 02          --------------------
D5AA: 8D 49       bsr   $D5F5
D5AC: 26 01       bne   $D5AF
D5AE: 4C          inca  
D5AF: 3F          SWI   
D5B0: 52          --------------------
D5B1: 00          --------------------
D5B2: 53          COMB  
D5B3: 70 B0 FF    NEG   $B0FF
D5B6: 5B          --------------------
D5B7: FC          --------------------
D5B8: E0 00       subb  $00,X
D5BA: F7 7A 5A    stab   $7A5A
D5BD: FE F2 F0    ldx   $F2F0
D5C0: A0 F9       SUBA  $F9,X
D5C2: 52          --------------------
D5C3: A6 9F       ldaa   $9F,X
D5C5: CB 45       ADDB  #45
D5C7: B7 11 9B    staa   $119B
D5CA: 5B          --------------------
D5CB: FD          --------------------
D5CC: E0 0B       subb  $0B,X
D5CE: 2B 5A       BMI   $D62A
D5D0: FC          --------------------
D5D1: E0 0D       subb  $0D,X
D5D3: 0A          CLV   
D5D4: 5A          decb  
D5D5: F4 3C EC    andb  $3CEC
D5D8: 13          --------------------
D5D9: BA BB 3C    oraa   $BB3C
D5DC: 80 24       SUBA  #24
D5DE: 5A          decb  
D5DF: F4 45 E2    andb  $45E2
D5E2: 13          --------------------
D5E3: C3          --------------------
D5E4: C4 45       andb  #45
D5E6: 80 1A       SUBA  #1A
D5E8: 7E FB 94    jmp   $FB94

D5EB: 8D FB       bsr   $D5E8
D5ED: 84 03       anda  #03
D5EF: 39          rts   

D5F0: 8D F6       bsr   $D5E8
D5F2: 84 07       anda  #07
D5F4: 39          rts   

D5F5: 8D F1       bsr   $D5E8
D5F7: 84 0F       anda  #0F
D5F9: 39          rts   

D5FA: A0 C3       SUBA  $C3,X
D5FC: 5A          decb  
D5FD: F4 E0 C4    andb  $E0C4
D600: 17          TBA   
D601: 00          --------------------
D602: CA 04       ORB   #04
D604: 04          --------------------
D605: CE E5 AC    ldx   #msg_hit
D608: BD D2 6D    jsr   $D26D
D60B: F6 11 9B    ldab   $119B
D60E: CE E4 94    ldx   #E494
D611: BD EE 8C    jsr   xplusb
D614: E6 00       ldab   $00,X
D616: BD D2 72    jsr   $D272
D619: C6 26       ldab   #26
D61B: BD D2 72    jsr   $D272
D61E: CE 13 A7    ldx   #13A7
D621: 8D C8       bsr   $D5EB
D623: 27 01       beq   $D626
D625: 4A          deca  
D626: B7 13 9F    staa   $139F
D629: 26 07       bne   $D632
D62B: 96 04       ldaa   $0004
D62D: BD DF D2    jsr   $DFD2
D630: 20 1C       bra   $D64E

D632: 6F 01       CLR   $01,X
D634: C6 1C       ldab   #1C
D636: E7 02       stab   $02,X
D638: C6 26       ldab   #26
D63A: E7 03       stab   $03,X
D63C: 81 02       cmpa  #02
D63E: 27 06       beq   $D646
D640: 86 5A       ldaa   #5A
D642: C6 42       ldab   #42
D644: 20 04       bra   $D64A

D646: 86 45       ldaa   #45
D648: C6 55       ldab   #55
D64A: A7 04       staa   $04,X
D64C: E7 05       stab   $05,X
D64E: 86 05       ldaa   #05
D650: A7 00       staa   $00,X
D652: BD D2 6D    jsr   $D26D
D655: 97 0A       staa   $000A
D657: DE CF       ldx   current_thread
D659: 86 A4       ldaa   #A4
D65B: A7 0D       staa   $0D,X
D65D: 86 02       ldaa   #02
D65F: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
D662: C0 

D663: 4A  	  deca
D664: 26 F9       bne   $D65F
D666: B6 11 9B    ldaa   $119B
D669: 3F          SWI   
D66A: 52          --------------------
D66B: A1 5A       cmpa  $5A,X
D66D: FD          --------------------
D66E: E0 0B       subb  $0B,X
D670: 06          TAP   
D671: A0 4C       SUBA  score_p1_b0,X
D673: 15          --------------------
D674: 00          --------------------
D675: 80 0B       SUBA  #0B
D677: 5A          decb  
D678: FC          --------------------
D679: E0 0D       subb  $0D,X
D67B: 04          --------------------
D67C: 19          DAA   
D67D: 10          SBA   
D67E: 80 02       SUBA  #02
D680: 19          DAA   
D681: 11          CBA   
D682: CA 04       ORB   #04
D684: 04          --------------------
D685: 86 0C       ldaa   #0C
D687: 5F          clrb  
D688: BD D2 CF    jsr   $D2CF
D68B: 97 0A       staa   $000A
D68D: 7E D5 AA    jmp   $D5AA

D690: 3F          SWI   
D691: 74 5A FE    LSR   $5AFE
D694: F2 FF 68    SBCB  $FF68
D697: F9 52 68    ADCB  $5268
D69A: EE 33       ldx   $33,X
D69C: F1 F2 F7    CMPB  $F2F7
D69F: 74 33 01    LSR   $3301
D6A2: 02          --------------------
D6A3: 07          TPA   
D6A4: 03          --------------------
D6A5: 36          psha  
D6A6: CE D6 90    ldx   #D690
D6A9: BD D5 0D    jsr   $D50D
D6AC: 96 06       ldaa   $0006
D6AE: 8B 99       ADDA  #99
D6B0: 19          DAA   
D6B1: 97 06       staa   $0006
D6B3: 81 01       cmpa  #01
D6B5: 26 06       bne   $D6BD
D6B7: CE D5 64    ldx   #D564
D6BA: BD D5 0D    jsr   $D50D
D6BD: 32          pula  
D6BE: 39          rts   

D6BF: CE E4 71    ldx   #E471
D6C2: BD EE 3E    jsr   xplusa	 ( X = X + A)
D6C5: A6 00       ldaa   $00,X
D6C7: 39          rts   

D6C8: 36          psha  
D6C9: 37          PSHB  
D6CA: 4A          deca  
D6CB: BD F3 6F    jsr   $F36F
D6CE: 27 04       beq   $D6D4
D6D0: 86 01       ldaa   #01
D6D2: 20 09       bra   $D6DD

D6D4: 4C          inca  
D6D5: 4C          inca  
D6D6: BD F3 6F    jsr   $F36F
D6D9: 27 05       beq   $D6E0
D6DB: 86 02       ldaa   #02
D6DD: B7 13 9D    staa   $139D
D6E0: 33          PULB  
D6E1: 32          pula  
D6E2: 39          rts   

D6E3: 36          psha  
D6E4: 37          PSHB  
D6E5: 16          tab   
D6E6: 8B 41       ADDA  #41
D6E8: 8D DE       bsr   $D6C8
D6EA: BD F2 04    jsr   $F204
D6ED: C0 08       subb  #08
D6EF: CE E4 B4    ldx   #E4B4
D6F2: BD D3 F9    jsr   $D3F9
D6F5: F7 13 9C    stab   $139C
D6F8: FE 11 96    ldx   $1196
D6FB: 27 E3       beq   $D6E0
D6FD: E1 00       CMPB  $00,X
D6FF: 26 DF       bne   $D6E0
D701: 08          inx   
D702: FF 11 96    stx   $1196
D705: 74 11 98    LSR   $1198
D708: 20 D6       bra   $D6E0

D70A: D8 30       EORB  $0030
D70C: 19          DAA   
D70D: CF          --------------------
D70E: 4D          TSTA  
D70F: 29 C0       BVS   $D6D1
D711: 00          --------------------
D712: CA 00       ORB   #00
D714: 57          ASRB  
D715: F9 22 AC    ADCB  $22AC
D718: 2D 4C       BLT   $D766
D71A: 7C 00 E6    INC   flag_tilt
D71D: D6 EB       ldab   player_up
D71F: BD FA 63    jsr   $FA63
D722: D6 EB       ldab   player_up
D724: 57          ASRB  
D725: F9 EA 02    ADCB  $EA02
D728: AF B9       STS   $B9,X
D72A: 44          LSRA  
D72B: 80 12       SUBA  #12
D72D: 5B          --------------------
D72E: D0 E0       subb  $00E0
D730: 42          --------------------
D731: DD          --------------------
D732: 00          --------------------
D733: 4C          inca  
D734: C6 21       ldab   #21
D736: D7 C8       stab   thread_priority
D738: CE DD 76    ldx   #DD76
D73B: BD E9 D8    jsr   newthread_sp	Push Control Stack: Data in A,B,X,$AA,$A6,$A7
D73E: 42          --------------------
D73F: 0B          SEV   
D740: E8 B3       EORB  $B3,X
D742: FF 5A FB    stx   $5AFB
D745: FB F3 FC    ADDB  $F3FC
D748: E3          --------------------
D749: 00          --------------------
D74A: D0 2E       subb  $002E
D74C: D0 2F       subb  $002F
D74E: 24 55       bcc   $D7A5
D750: 08          inx   
D751: 00          --------------------
D752: E5 A2       BITB  $A2,X
D754: 32          pula  
D755: 9F B3       STS   irqcount16
D757: 57          ASRB  
D758: DF 64       stx   $0064
D75A: A0 18       SUBA  lampbuffer0x
D75C: A4 2A       anda  $2A,X
D75E: 55          --------------------
D75F: 08          inx   
D760: 00          --------------------
D761: 47          ASRA  
D762: D6 EB       ldab   player_up
D764: BD F9 EA    jsr   $F9EA
D767: 4A          deca  
D768: 97 F4       staa   flag_timer_bip
D76A: CE F9 75    ldx   #F975
D76D: BD D5 0E    jsr   $D50E
D770: 57          ASRB  
D771: D3          --------------------
D772: CB 03       ADDB  #03
D774: CE E5 74    ldx   #msg_wave
D777: BD D3 0B    jsr   $D30B
D77A: BD E6 D2    jsr   $E6D2
D77D: 8D 06       bsr   $D785
D77F: CE E5 79    ldx   #msg_completed
D782: BD D3 0B    jsr   $D30B
D785: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
D788: 45    

D789: 39          rts   

D78A: AF 57       STS   $57,X
D78C: 5B          --------------------
D78D: F4 43 2E    andb  $432E
D790: 19          DAA   
D791: 11          CBA   
D792: 80 19       SUBA  #19
D794: AF 4D       STS   $4D,X
D796: 5B          --------------------
D797: F4 3A 24    andb  $3A24
D79A: 19          DAA   
D79B: 10          SBA   
D79C: 80 0F       SUBA  #0F
D79E: C6 3D       ldab   #3D
D7A0: 20 02       bra   $D7A4

D7A2: C6 3E       ldab   #3E
D7A4: 3F          SWI   
D7A5: AF 3C       STS   lampbuffer1x
D7A7: 5B          --------------------
D7A8: F4 E1 13    andb  $E113
D7AB: 15          --------------------
D7AC: 01          NOP   
D7AD: 96 87       ldaa   $0087
D7AF: 5A          decb  
D7B0: FE F2 F4    ldx   $F2F4
D7B3: A4 27       anda  $27,X
D7B5: 5A          decb  
D7B6: D0 2E       subb  $002E
D7B8: 05          --------------------
D7B9: E0 42       subb  $42,X
D7BB: 2B 8F       BMI   $D74C
D7BD: 83          --------------------
D7BE: 03          --------------------
D7BF: C6 46       ldab   #46
D7C1: 20 E1       bra   $D7A4

D7C3: C6 47       ldab   #47
D7C5: 20 DD       bra   $D7A4

D7C7: 16          tab   
D7C8: C0 08       subb  #08
D7CA: CE E4 73    ldx   #E473
D7CD: BD D3 F9    jsr   $D3F9
D7D0: 20 D2       bra   $D7A4

D7D2: 3F          SWI   
D7D3: 5A          decb  
D7D4: FE F2 F6    ldx   $F2F6
D7D7: A4 18       anda  lampbuffer0x
D7D9: 72          --------------------
D7DA: 8F          --------------------
D7DB: F7 45 B6    stab   $45B6
D7DE: 13          --------------------
D7DF: 9C 5A       CPX   $005A
D7E1: FE F2 F6    ldx   $F2F6
D7E4: A4 03       anda  $03,X
D7E6: 76 8F F7    ROR   $8FF7
D7E9: 44          LSRA  
D7EA: D6 64       ldab   $0064
D7EC: 5B          --------------------
D7ED: FC          --------------------
D7EE: E0 E1       subb  $E1,X
D7F0: C4 55       andb  #55
D7F2: F1 A0 52    CMPB  $A052
D7F5: A1 AD       cmpa  $AD,X
D7F7: F3          --------------------
D7F8: 04          --------------------
D7F9: 9B 04       ADDA  $0004
D7FB: 19          DAA   
D7FC: 97 04       staa   $0004
D7FE: C6 01       ldab   #01
D800: B6 13 9F    ldaa   $139F
D803: 27 0D       beq   $D812
D805: 46          RORA  
D806: 24 05       bcc   $D80D
D808: BD D9 CB    jsr   $D9CB
D80B: 20 0A       bra   $D817

D80D: BD D9 DA    jsr   $D9DA
D810: 20 05       bra   $D817

D812: CE 00 66    ldx   #0066
D815: 8D 1D       bsr   $D834
D817: BD D3 46    jsr   $D346
D81A: C6 10       ldab   #10
D81C: 86 01       ldaa   #01
D81E: BD EC 3B    jsr   isnd_once
D821: 96 7B       ldaa   dmask_p4
D823: 43          COMA  
D824: 84 3F       anda  #3F
D826: 97 7B       staa   dmask_p4
D828: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
D82B: 05 

D82C: 5A          decb  
D82D: 26 F2       bne   $D821
D82F: D7 7B       stab   dmask_p4
D831: 7E D6 66    jmp   $D666

D834: E6 01       ldab   $01,X
D836: C4 3F       andb  #3F
D838: C0 1B       subb  #1B
D83A: 27 08       beq   $D844
D83C: 86 0B       ldaa   #0B
D83E: BD EB 3D    jsr   $EB3D
D841: 5A          decb  
D842: 26 FA       bne   $D83E
D844: E6 00       ldab   $00,X
D846: 27 0A       beq   $D852
D848: C0 1B       subb  #1B
D84A: 86 0C       ldaa   #0C
D84C: BD EB 3D    jsr   $EB3D
D84F: 5A          decb  
D850: 26 FA       bne   $D84C
D852: 39          rts   

D853: D6 7A       ldab   dmask_p3
D855: 53          COMB  
D856: C4 7F       andb  #7F
D858: D7 7A       stab   dmask_p3
D85A: D7 7B       stab   dmask_p4
D85C: 39          rts   

D85D: 36          psha  
D85E: BD D5 EB    jsr   $D5EB
D861: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
D864: 01 

D865: 27 14       beq   $D87B
D867: 81 03       cmpa  #03
D869: 27 F3       beq   $D85E
D86B: 81 02       cmpa  #02
D86D: 26 0C       bne   $D87B
D86F: 86 0A       ldaa   #0A
D871: BD F3 45    jsr   $F345
D874: 25 04       bcs   $D87A
D876: 86 02       ldaa   #02
D878: 20 01       bra   $D87B

D87A: 4F          clra  
D87B: B7 13 9E    staa   $139E
D87E: 32          pula  
D87F: 39          rts   

D880: DE CF       ldx   current_thread
D882: 6F 0D       CLR   $0D,X
D884: 39          rts   

D885: 8D F9       bsr   $D880
D887: CE 00 00    ldx   #0000
D88A: FF 11 96    stx   $1196
D88D: 8D 7D       bsr   $D90C
D88F: A6 00       ldaa   $00,X
D891: B7 13 9E    staa   $139E
D894: EE 01       ldx   $01,X
D896: FF 11 98    stx   $1198
D899: 26 31       bne   $D8CC
D89B: 3F          SWI   
D89C: 53          COMB  
D89D: 40          NEGA  
D89E: 5A          decb  
D89F: FE F2 F0    ldx   $F2F0
D8A2: A0 F8       SUBA  $F8,X
D8A4: 52          --------------------
D8A5: A0 04       SUBA  $04,X
D8A7: CE E5 83    ldx   #msg_spell
D8AA: BD D3 0B    jsr   $D30B
D8AD: BD D3 4C    jsr   $D34C
D8B0: 86 10       ldaa   #10
D8B2: 8D 9F       bsr   $D853
D8B4: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
D8B7: 08 

D8B8: 4A          deca  
D8B9: 26 F7       bne   $D8B2
D8BB: BD D5 F0    jsr   $D5F0
D8BE: 26 01       bne   $D8C1
D8C0: 4C          inca  
D8C1: 8D 9A       bsr   $D85D
D8C3: 4A          deca  
D8C4: B7 11 99    staa   $1199
D8C7: 86 20       ldaa   #20
D8C9: B7 11 98    staa   $1198
D8CC: BD D9 71    jsr   $D971
D8CF: 24 FB       bcc   $D8CC
D8D1: BD D3 4C    jsr   $D34C
D8D4: 8D 51       bsr   $D927
D8D6: CE 13 AD    ldx   #13AD
D8D9: DF B8       stx   temp1
D8DB: B6 11 98    ldaa   $1198
D8DE: 27 71       beq   $D951
D8E0: 85 20       BITA  #20
D8E2: 26 06       bne   $D8EA
D8E4: 48          ASLA  
D8E5: 27 6A       beq   $D951
D8E7: 08          inx   
D8E8: 20 F6       bra   $D8E0

D8EA: FF 11 96    stx   $1196
D8ED: BD D3 54    jsr   $D354
D8F0: 8D 53       bsr   $D945
D8F2: 8D 8C       bsr   $D880
D8F4: 86 7F       ldaa   #7F
D8F6: 97 7A       staa   dmask_p3
D8F8: 84 7F       anda  #7F
D8FA: 97 7B       staa   dmask_p4
D8FC: 8D 73       bsr   $D971
D8FE: 24 17       bcc   $D917
D900: 8D 7A       bsr   $D97C
D902: 27 4D       beq   $D951
D904: 43          COMA  
D905: 9A 7B       oraa   dmask_p4
D907: B8 11 98    EORA  $1198
D90A: 20 EC       bra   $D8F8

D90C: CE 13 A0    ldx   #13A0
D90F: D6 EB       ldab   player_up
D911: 27 03       beq   $D916
D913: 08          inx   
D914: 08          inx   
D915: 08          inx   
D916: 39          rts   

D917: 5F          clrb  
D918: BD D8 58    jsr   $D858
D91B: 8D 5F       bsr   $D97C
D91D: 27 32       beq   $D951
D91F: 8D 50       bsr   $D971
D921: 24 F8       bcc   $D91B
D923: 8D 02       bsr   $D927
D925: 20 CD       bra   $D8F4

D927: BD D2 D6    jsr   $D2D6
D92A: CE 00 6C    ldx   #006C
D92D: DF B8       stx   temp1
D92F: CE E5 BC    ldx   #E5BC
D932: B6 13 9E    ldaa   $139E
D935: 27 09       beq   $D940
D937: CE E5 B6    ldx   #E5B6
D93A: 46          RORA  
D93B: 25 03       bcs   $D940
D93D: CE E5 B0    ldx   #E5B0
D940: 8D 0C       bsr   $D94E
D942: 7C 00 B9    INC   temp1+1
D945: CE E4 A6    ldx   #E4A6
D948: B6 11 99    ldaa   $1199
D94B: BD F5 28    jsr   gettabledata_b
D94E: 7E D3 0D    jmp   $D30D

D951: CE 00 00    ldx   #0000
D954: FF 11 96    stx   $1196
D957: FF 11 98    stx   $1198
D95A: 8D 2B       bsr   $D987
D95C: CE 13 AD    ldx   #13AD
D95F: BD D3 54    jsr   $D354
D962: C6 03       ldab   #03
D964: B6 13 9E    ldaa   $139E
D967: 27 34       beq   $D99D
D969: 81 02       cmpa  #02
D96B: 27 2C       beq   $D999
D96D: 8D 5C       bsr   $D9CB
D96F: 20 31       bra   $D9A2

D971: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
D974: 05     

D975: 86 A0       ldaa   #A0
D977: C6 F0       ldab   #F0
D979: 7E EA 60    jmp   check_threadid

D97C: FE 11 96    ldx   $1196
D97F: A6 00       ldaa   $00,X
D981: 27 03       beq   $D986
D983: B6 11 98    ldaa   $1198
D986: 39          rts   

D987: 8D 83       bsr   $D90C
D989: B6 13 9E    ldaa   $139E
D98C: A7 00       staa   $00,X
D98E: B6 11 98    ldaa   $1198
D991: A7 01       staa   $01,X
D993: B6 11 99    ldaa   $1199
D996: A7 02       staa   $02,X
D998: 39          rts   

D999: 8D 3F       bsr   $D9DA
D99B: 20 05       bra   $D9A2

D99D: 86 4C       ldaa   #4C
D99F: BD EB 3D    jsr   $EB3D
D9A2: 86 06       ldaa   #06
D9A4: BD EC 3B    jsr   isnd_once
D9A7: 8D C8       bsr   $D971
D9A9: 24 1A       bcc   $D9C5
D9AB: DE CF       ldx   current_thread
D9AD: 86 A1       ldaa   #A1
D9AF: A7 0D       staa   $0D,X
D9B1: 86 7F       ldaa   #7F
D9B3: 97 7B       staa   dmask_p4
D9B5: 86 10       ldaa   #10
D9B7: D6 7A       ldab   dmask_p3
D9B9: 53          COMB  
D9BA: C4 7F       andb  #7F
D9BC: D7 7A       stab   dmask_p3
D9BE: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
D9C1: 05   

D9C2: 4A          deca  
D9C3: 26 F2       bne   $D9B7
D9C5: BD D3 46    jsr   $D346
D9C8: 7E D8 85    jmp   $D885

D9CB: 37          PSHB  
D9CC: BD D3 F3    jsr   $D3F3
D9CF: 17          TBA   
D9D0: 33          PULB  
D9D1: 1B          ABA   
D9D2: A7 00       staa   $00,X
D9D4: 96 EB       ldaa   player_up
D9D6: 8B 0B       ADDA  #0B
D9D8: 20 0E       bra   $D9E8

D9DA: 96 06       ldaa   $0006
D9DC: 1B          ABA   
D9DD: 81 05       cmpa  #05
D9DF: 2F 02       BLE   $D9E3
D9E1: 86 05       ldaa   #05
D9E3: 97 06       staa   $0006
D9E5: 86 0A       ldaa   #0A
D9E7: 58          ASLB  
D9E8: 8D 04       bsr   $D9EE
D9EA: 5A          decb  
D9EB: 26 FB       bne   $D9E8
D9ED: 39          rts   

D9EE: 7E F2 64    jmp   $F264

D9F1: 3F          SWI   
D9F2: AB F4       ADDA  $F4,X
D9F4: 44          LSRA  
D9F5: 84 02       anda  #02
D9F7: 5B          --------------------
D9F8: D0 2F       subb  $002F
D9FA: 01          NOP   
D9FB: 03          --------------------
D9FC: 52          --------------------
D9FD: 50          NEGB  
D9FE: 5A          decb  
D9FF: FC          --------------------
DA00: E8 00       EORB  $00,X
DA02: F8 B8 FF    EORB  $B8FF
DA05: 5A          decb  
DA06: FC          --------------------
DA07: E0 02       subb  $02,X
DA09: 2C C1       BGE   $D9CC
DA0B: 36          psha  
DA0C: 5A          decb  
DA0D: F4 E1 09    andb  $E109
DA10: 14          --------------------
DA11: 01          NOP   
DA12: 69 69       rol   $69,X
DA14: 5B          --------------------
DA15: E1 DB       CMPB  $DB,X
DA17: 15          --------------------
DA18: 01          NOP   
DA19: 5A          decb  
DA1A: FC          --------------------
DA1B: E1 3E       CMPB  $3E,X
DA1D: 69 5B       rol   $5B,X
DA1F: FC          --------------------
DA20: E1 3C       CMPB  lampbuffer1x
DA22: 02          --------------------
DA23: 19          DAA   
DA24: 10          SBA   
DA25: B1 01 5B    cmpa  $015B
DA28: FC          --------------------
DA29: E1 3A       CMPB  $3A,X
DA2B: E0 B1       subb  $B1,X
DA2D: 02          --------------------
DA2E: 5A          decb  
DA2F: F4 E1 F3    andb  $E1F3
DA32: 18          --------------------
DA33: 10          SBA   
DA34: 8F          --------------------
DA35: DA C1       ORB   sys_temp4
DA37: 3F          SWI   
DA38: 5A          decb  
DA39: F4 E1 09    andb  $E109
DA3C: 14          --------------------
DA3D: 01          NOP   
DA3E: 69 69       rol   $69,X
DA40: 5B          --------------------
DA41: E1 AF       CMPB  $AF,X
DA43: 15          --------------------
DA44: 01          NOP   
DA45: 5A          decb  
DA46: FC          --------------------
DA47: E1 47       CMPB  $47,X
DA49: 65          --------------------
DA4A: 5B          --------------------
DA4B: FC          --------------------
DA4C: E1 45       CMPB  $45,X
DA4E: 02          --------------------
DA4F: 19          DAA   
DA50: 11          CBA   
DA51: B1 01 5B    cmpa  $015B
DA54: FC          --------------------
DA55: E1 43       CMPB  $43,X
DA57: E0 B1       subb  $B1,X
DA59: 02          --------------------
DA5A: 5A          decb  
DA5B: F4 E1 F3    andb  $E1F3
DA5E: 18          --------------------
DA5F: 11          CBA   
DA60: 8F          --------------------
DA61: DA 37       ORB   $0037
DA63: 16          tab   
DA64: BD DD 17    jsr   $DD17
DA67: 3F          SWI   
DA68: 5A          decb  
DA69: FB D0 E0    ADDB  $D0E0
DA6C: F3          --------------------
DA6D: F5 E0 13    BITB  $E013
DA70: DC          --------------------
DA71: 00          --------------------
DA72: 14          --------------------
DA73: 01          NOP   
DA74: 69 69       rol   $69,X
DA76: 5A          decb  
DA77: D0 E0       subb  $00E0
DA79: 04          --------------------
DA7A: C0 00       subb  #00
DA7C: 80 05       SUBA  #05
DA7E: DD          --------------------
DA7F: 00          --------------------
DA80: 57          ASRB  
DA81: F2 1D 04    SBCB  $1D04
DA84: 33          PULB  
DA85: 39          rts   

DA86: 3F          SWI   
DA87: 90 D0       SUBA  $00D0
DA89: 5A          decb  
DA8A: D0 2F       subb  $002F
DA8C: 5F          clrb  
DA8D: C0 00       subb  #00
DA8F: B0 01 5A    SUBA  $015A
DA92: FA D0 E0    ORB   $D0E0
DA95: F3          --------------------
DA96: FC          --------------------
DA97: E0 E1       subb  $E1,X
DA99: F5 5A FE    BITB  $5AFE
DA9C: F2 F0 30    SBCB  $F030
DA9F: 4C          inca  
DAA0: AF C0       STS   $C0,X
DAA2: 5A          decb  
DAA3: FC          --------------------
DAA4: E0 00       subb  $00,X
DAA6: 45          --------------------
DAA7: 5A          decb  
DAA8: FC          --------------------
DAA9: E0 E1       subb  $E1,X
DAAB: 28 8F       BVC   $DA3C
DAAD: E1 3F       CMPB  $3F,X
DAAF: 90 A8       SUBA  lamp_bit
DAB1: 5A          decb  
DAB2: D0 2F       subb  $002F
DAB4: 37          PSHB  
DAB5: C0 0A       subb  #0A
DAB7: B0 FF 5A    SUBA  $FF5A
DABA: FA D0 E0    ORB   $D0E0
DABD: F3          --------------------
DABE: FC          --------------------
DABF: E0 E1       subb  $E1,X
DAC1: F5 5A FE    BITB  $5AFE
DAC4: F2 F0 30    SBCB  $F030
DAC7: 24 AF       bcc   $DA78
DAC9: 98 5A       EORA  $005A
DACB: FC          --------------------
DACC: E0 00       subb  $00,X
DACE: 1D          --------------------
DACF: 5B          --------------------
DAD0: FC          --------------------
DAD1: E0 E1       subb  $E1,X
DAD3: E3          --------------------
DAD4: 5A          decb  
DAD5: FA F5 E0    ORB   $F5E0
DAD8: F3          --------------------
DAD9: D0 E0       subb  $00E0
DADB: 03          --------------------
DADC: 71          --------------------
DADD: 8F          --------------------
DADE: F5 DC 00    BITB  $DC00
DAE1: AF 0B       STS   $0B,X
DAE3: 5A          decb  
DAE4: F6 E0 08    ldab   $E008
DAE7: 69 5A       rol   $5A,X
DAE9: D0 E0       subb  $00E0
DAEB: F5 93 48    BITB  $9348
DAEE: 03          --------------------
DAEF: 57          ASRB  
DAF0: F2 E1 57    SBCB  $E157
DAF3: F2 F2 5A    SBCB  $F25A
DAF6: F5 E0 07    BITB  $E007
DAF9: 74 5B D0    LSR   $5BD0
DAFC: E0 EE       subb  $EE,X
DAFE: 8F          --------------------
DAFF: EF DD       stx   $DD,X
DB01: 00          --------------------
DB02: 52          --------------------
DB03: 00          --------------------
DB04: 93          --------------------
DB05: 30          TSX   
DB06: AB 9D       ADDA  switch_b4,X
DB08: 1C          --------------------
DB09: 8A 0A       oraa   #0A
DB0B: B2 04 5B    SBCA  $045B
DB0E: FC          --------------------
DB0F: E6 00       ldab   $00,X
DB11: DC          --------------------
DB12: 55          --------------------
DB13: 08          inx   
DB14: 00          --------------------
DB15: 31          INS   
DB16: F6 9B F1    ldab   $9BF1
DB19: C0 05       subb  #05
DB1B: C1 05       CMPB  #05
DB1D: 14          --------------------
DB1E: 01          NOP   
DB1F: 5A          decb  
DB20: FC          --------------------
DB21: E1 35       CMPB  $35,X
DB23: 04          --------------------
DB24: B1 06 8F    cmpa  $068F
DB27: F5 5B 05    BITB  $5B05
DB2A: 0D          SEC   
DB2B: B0 FF 5A    SUBA  $FF5A
DB2E: FC          --------------------
DB2F: E0 00       subb  $00,X
DB31: 22 EE       BHI   $DB21
DB33: 34          DES   
DB34: 40          NEGA  
DB35: 41          --------------------
DB36: 42          --------------------
DB37: 47          ASRA  
DB38: 1D          --------------------
DB39: 81 82       cmpa  #82
DB3B: 83          --------------------
DB3C: 84 85       anda  #85
DB3E: 86 87       ldaa   #87
DB40: 88 09       EORA  #09
DB42: 77 5B 00    ASR   $5B00
DB45: E2 10       SBCB  $10,X
DB47: BE BD C6    LDS   $BDC6
DB4A: 47          ASRA  
DB4B: 48          ASLA  
DB4C: CE DD B0    ldx   #DDB0
DB4F: BD EA 24    jsr   newthread_06	 Push Control Stack: Data in A,B,X,$A6,$A7,$AA=#06
DB52: 8F          --------------------
DB53: D4 C6       andb  sys_temp_w3
DB55: 00          --------------------
DB56: 5F          clrb  
DB57: D3          --------------------
DB58: A1 71       cmpa  $71,X
DB5A: 5A          decb  
DB5B: FE F2 F1    ldx   $F2F1
DB5E: 21          --------------------
DB5F: F9 52 20    ADCB  $5220
DB62: 5B          --------------------
DB63: F6 4D 02    ldab   $4D02
DB66: 19          DAA   
DB67: 4D          TSTA  
DB68: A0 13       SUBA  $13,X
DB6A: B1 30 5A    cmpa  $305A
DB6D: FB FB D0    ADDB  $FBD0
DB70: E1 D0       CMPB  $D0,X
DB72: E0 D0       subb  $D0,X
DB74: F9 E1 23    ADCB  $E123
DB77: E1 DC       CMPB  $DC,X
DB79: 01          NOP   
DB7A: 51          --------------------
DB7B: 10          SBA   
DB7C: 02          --------------------
DB7D: BD D5 F5    jsr   $D5F5
DB80: 81 08       cmpa  #08
DB82: 2F 01       BLE   $DB85
DB84: 44          LSRA  
DB85: 4C          inca  
DB86: 16          tab   
DB87: 39          rts   

DB88: BD D2 D6    jsr   $D2D6
DB8B: CE 00 60    ldx   #0060
DB8E: DF B8       stx   temp1
DB90: CE E5 C8    ldx   #E5C8
DB93: BD D3 0D    jsr   $D30D
DB96: CE E5 8D    ldx   #msg_bonus
DB99: BD D3 0D    jsr   $D30D
DB9C: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
DB9F: 25 

DBA0: BD D2 D6    jsr	$D2D6
DBA3: D6 06       ldab   $0006
DBA5: CE 00 61    ldx   #0061
DBA8: BD EC 32    jsr   split_ab
DBAB: 5D          TSTB  
DBAC: 27 04       beq   $DBB2
DBAE: CB 1B       ADDB  #1B
DBB0: E7 00       stab   $00,X
DBB2: D6 06       ldab   $0006
DBB4: C4 0F       andb  #0F
DBB6: CB 1B       ADDB  #1B
DBB8: E7 01       stab   $01,X
DBBA: 86 18       ldaa   #18
DBBC: A7 03       staa   $03,X
DBBE: 96 05       ldaa   $0005
DBC0: 81 09       cmpa  #09
DBC2: 23 02       BLS   $DBC6
DBC4: 86 09       ldaa   #09
DBC6: 16          tab   
DBC7: CB 9B       ADDB  #9B
DBC9: E7 05       stab   $05,X
DBCB: C6 1B       ldab   #1B
DBCD: E7 06       stab   $06,X
DBCF: E7 07       stab   $07,X
DBD1: E7 08       stab   $08,X
DBD3: 48          ASLA  
DBD4: 48          ASLA  
DBD5: 48          ASLA  
DBD6: 8A 03       oraa   #03
DBD8: D6 06       ldab   $0006
DBDA: BD EB 3D    jsr   $EB3D
DBDD: 5A          decb  
DBDE: 26 FA       bne   $DBDA
DBE0: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
DBE3: 25 

DBE4: 39          rts

DBE5: D6 05       ldab   $0005
DBE7: BD F8 9D    jsr   $F89D
DBEA: 86 7F       ldaa   #7F
DBEC: 80 04       SUBA  #04
DBEE: 81 09       cmpa  #09
DBF0: 2D 05       BLT   $DBF7
DBF2: 5A          decb  
DBF3: 26 F7       bne   $DBEC
DBF5: 20 02       bra   $DBF9

DBF7: 86 08       ldaa   #08
DBF9: 3F          SWI   
DBFA: CE 00 67    ldx   #0067
DBFD: BE 01 5A    LDS   $015A
DC00: D0 2F       subb  $002F
DC02: F9 45 D6    ADCB  $45D6
DC05: E8 4A       EORB  $4A,X
DC07: 5A          decb  
DC08: FC          --------------------
DC09: E0 00       subb  $00,X
DC0B: 09          DEX   
DC0C: 5B          --------------------
DC0D: FA FC E1    ORB   $FCE1
DC10: 00          --------------------
DC11: FD          --------------------
DC12: EE 30       ldx   $30,X
DC14: E7 71       stab   $71,X
DC16: 45          --------------------
DC17: 7F 13 96    CLR   $1396
DC1A: AF 61       STS   $61,X
DC1C: 5A          decb  
DC1D: FB F3 F5    ADDB  $F3F5
DC20: E0 D0       subb  $D0,X
DC22: E0 F1       subb  $F1,X
DC24: B0 53 A0    SUBA  $53A0
DC27: EF 52       stx   $52,X
DC29: 30          TSX   
DC2A: CE 06 DC    ldx   #06DC
DC2D: 00          --------------------
DC2E: 14          --------------------
DC2F: 01          NOP   
DC30: D5 01       BITB  vm_reg_b
DC32: 26 01       bne   $DC35
DC34: E2 67       SBCB  $67,X
DC36: 5B          --------------------
DC37: D0 E0       subb  $00E0
DC39: 20 BE       bra   $DBF9

DC3B: FF 5B FC    stx   $5BFC
DC3E: EE 00       ldx   $00,X
DC40: F1 24 01    CMPB  LAMP_PIA3_CRTL_A
DC43: A0 3F       SUBA  $3F,X
DC45: 25 01       bcs   $DC48
DC47: 15          --------------------
DC48: 01          NOP   
DC49: 5B          --------------------
DC4A: D0 E0       subb  $00E0
DC4C: 0D          SEC   
DC4D: DD          --------------------
DC4E: 00          --------------------
DC4F: A0 D2       SUBA  $D2,X
DC51: 5B          --------------------
DC52: FC          --------------------
DC53: E1 00       CMPB  $00,X
DC55: D4 52       andb  $0052
DC57: 00          --------------------
DC58: 8E B8 15    LDS   #B8
DC5B: 01          NOP   
DC5C: 25 01       bcs   $DC5F
DC5E: 52          --------------------
DC5F: 00          --------------------
DC60: 42          --------------------
DC61: 0C          CLC   
DC62: 5A          decb  
DC63: FC          --------------------
DC64: E7 04       stab   $04,X
DC66: 02          --------------------
DC67: B7 FF A9    staa   $FFA9
DC6A: 85 44       BITA  #44
DC6C: 9B 03       ADDA  $0003
DC6E: FB 5A FD    ADDB  $5AFD
DC71: E5 09       BITB  $09,X
DC73: 02          --------------------
DC74: 53          COMB  
DC75: 20 7F       bra   $DCF6

DC77: 5A          decb  
DC78: D0 2F       subb  $002F
DC7A: F4 B0 FF    andb  $B0FF
DC7D: 5B          --------------------
DC7E: FC          --------------------
DC7F: E0 00       subb  $00,X
DC81: ED          --------------------
DC82: 8F          --------------------
DC83: 91 36       cmpa  $0036
DC85: 37          PSHB  
DC86: BD D5 EB    jsr   $D5EB
DC89: 97 0E       staa   $000E
DC8B: 33          PULB  
DC8C: 32          pula  
DC8D: 27 2D       beq   $DCBC
DC8F: 36          psha  
DC90: B6 13 96    ldaa   $1396
DC93: 81 03       cmpa  #03
DC95: 32          pula  
DC96: 2E 24       BGT   $DCBC
DC98: 36          psha  
DC99: 86 30       ldaa   #30
DC9B: 97 C8       staa   thread_priority
DC9D: 32          pula  
DC9E: CE DC BD    ldx   #DCBD
DCA1: BD E9 D8    jsr   newthread_sp	Push Control Stack: Data in A,B,X,$AA,$A6,$A7
DCA4: 3F          SWI   
DCA5: FD          --------------------
DCA6: 7A 5A FE    DEC   $5AFE
DCA9: F2 FF 30    SBCB  $FF30
DCAC: F9 04 8D    ADCB  $048D
DCAF: 5F          clrb  
DCB0: 27 0A       beq   $DCBC
DCB2: 7D 13 9D    TST   $139D
DCB5: 26 05       bne   $DCBC
DCB7: 7A 00 0E    DEC   $000E
DCBA: 26 DC       bne   $DC98
DCBC: 39          rts   

DCBD: 97 0D       staa   $000D
DCBF: 80 53       SUBA  #53
DCC1: BD F3 7D    jsr   $F37D
DCC4: 8A C0       oraa   #C0
DCC6: BD F2 7E    jsr   $F27E
DCC9: 84 8F       anda  #8F
DCCB: 36          psha  
DCCC: 17          TBA   
DCCD: F6 13 96    ldab   $1396
DCD0: BD F1 DA    jsr   $F1DA
DCD3: 32          pula  
DCD4: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
DCD7: 08  

DCD8: 36          psha  
DCD9: 37          PSHB  
DCDA: 96 0D       ldaa   $000D
DCDC: BD F3 6F    jsr   $F36F
DCDF: 33          PULB  
DCE0: 32          pula  
DCE1: 27 21       beq   $DD04
DCE3: BD F2 F2    jsr   $F2F2
DCE6: 5C          incb  
DCE7: C1 05       CMPB  #05
DCE9: 23 E9       BLS   $DCD4
DCEB: 8D 05       bsr   $DCF2
DCED: 3F          SWI   
DCEE: 52          --------------------
DCEF: 00          --------------------
DCF0: 8E 14 36    LDS   #14
DCF3: 37          PSHB  
DCF4: 86 2F       ldaa   #2F
DCF6: BD F3 6F    jsr   $F36F
DCF9: 33          PULB  
DCFA: 32          pula  
DCFB: 26 BF       bne   $DCBC
DCFD: 8D 02       bsr   $DD01
DCFF: 8A C0       oraa   #C0
DD01: 7E F2 1D    jmp   $F21D

DD04: 36          psha  
DD05: 86 0B       ldaa   #0B
DD07: BD EB 3D    jsr   $EB3D
DD0A: 32          pula  
DD0B: 8D E5       bsr   $DCF2
DD0D: 20 75       bra   $DD84

DD0F: 36          psha  
DD10: 37          PSHB  
DD11: BD F3 6F    jsr   $F36F
DD14: 33          PULB  
DD15: 32          pula  
DD16: 39          rts   

DD17: 36          psha  
DD18: 4F          clra  
DD19: 5A          decb  
DD1A: 27 04       beq   $DD20
DD1C: 8B 06       ADDA  #06
DD1E: 20 F9       bra   $DD19

DD20: 16          tab   
DD21: 32          pula  
DD22: 39          rts   

DD23: 36          psha  
DD24: B6 13 96    ldaa   $1396
DD27: 4C          inca  
DD28: B7 13 96    staa   $1396
DD2B: 81 06       cmpa  #06
DD2D: 32          pula  
DD2E: 26 02       bne   $DD32
DD30: 5F          clrb  
DD31: 39          rts   

DD32: 74 13 9D    LSR   $139D
DD35: 25 11       bcs   $DD48
DD37: 74 13 9D    LSR   $139D
DD3A: 25 15       bcs   $DD51
DD3C: 36          psha  
DD3D: BD FB 94    jsr   $FB94
DD40: 46          RORA  
DD41: 85 08       BITA  #08
DD43: 32          pula  
DD44: 25 18       bcs   $DD5E
DD46: 27 09       beq   $DD51
DD48: 4A          deca  
DD49: 81 53       cmpa  #53
DD4B: 27 0D       beq   $DD5A
DD4D: C0 05       subb  #05
DD4F: 20 0E       bra   $DD5F

DD51: 4C          inca  
DD52: 81 5D       cmpa  #5D
DD54: 27 07       beq   $DD5D
DD56: CB 07       ADDB  #07
DD58: 20 05       bra   $DD5F

DD5A: 4C          inca  
DD5B: 20 01       bra   $DD5E

DD5D: 4A          deca  
DD5E: 5C          incb  
DD5F: 36          psha  
DD60: 37          PSHB  
DD61: 80 53       SUBA  #53
DD63: BD F3 54    jsr   $F354
DD66: 24 05       bcc   $DD6D
DD68: BD F3 6F    jsr   $F36F
DD6B: 27 A7       beq   $DD14
DD6D: 33          PULB  
DD6E: 32          pula  
DD6F: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
DD72: 01     

DD73: 5A          decb  
DD74: 20 BC       bra   $DD32

DD76: BD F2 E1    jsr   $F2E1
DD79: BD F3 54    jsr   $F354
DD7C: 25 06       bcs   $DD84
DD7E: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
DD81: 04  

DD82: 20 F2       bra   $DD76

DD84: 7E E9 C4    jmp   $E9C4	Remove Current Thread from Control Stack

DD87: C6 0F       ldab   #0F
DD89: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
DD8C: 40    

DD8D: 5A          decb  
DD8E: 26 F9       bne   $DD89
DD90: 96 09       ldaa   $0009
DD92: 4A          deca  
DD93: 97 09       staa   $0009
DD95: 81 09       cmpa  #09
DD97: 2E EE       BGT   $DD87
DD99: 20 E9       bra   $DD84

DD9B: 5A          decb  
DD9C: FB F3 F1    ADDB  $F3F1
DD9F: D0 30       subb  $0030
DDA1: 1E          --------------------
DDA2: 52          --------------------
DDA3: 10          SBA   
DDA4: 55          --------------------
DDA5: FF 10 57    stx   $1057
DDA8: D2 D6       SBCB  soundcount
DDAA: 57          ASRB  
DDAB: D3          --------------------
DDAC: 49          ROLA  
DDAD: 5C          incb  
DDAE: DE EE       ldx   $00EE
DDB0: 3F          SWI   
DDB1: C0 09       subb  #09
DDB3: 1D          --------------------
DDB4: 96 15       ldaa   $0015
DDB6: EF 75       stx   $75,X
DDB8: B0 FF 5B    SUBA  $FF5B
DDBB: FC          --------------------
DDBC: E0 00       subb  $00,X
DDBE: F4 03 5A    andb  $035A
DDC1: FB D0 2F    ADDB  $D02F
DDC4: D0 30       subb  $0030
DDC6: F8 4A BD    EORB  $4ABD
DDC9: D3          --------------------
DDCA: F3          --------------------
DDCB: 27 03       beq   $DDD0
DDCD: 5A          decb  
DDCE: E7 00       stab   $00,X
DDD0: B0 0B 5A    SUBA  $0B5A
DDD3: F5 E0 E9    BITB  $E0E9
DDD6: 5A          decb  
DDD7: FD          --------------------
DDD8: E1 02       CMPB  $02,X
DDDA: 03          --------------------
DDDB: 57          ASRB  
DDDC: F2 E1 D8    SBCB  $E1D8
DDDF: 2F 42       BLE   $DE23
DDE1: 09          DEX   
DDE2: 52          --------------------
DDE3: A1 29       cmpa  $29,X
DDE5: 52          --------------------
DDE6: 19          DAA   
DDE7: CF          --------------------
DDE8: D3          --------------------
DDE9: 12          --------------------
DDEA: C1 00       CMPB  #00
DDEC: 5B          --------------------
DDED: FE F2 FF    ldx   $F2FF
DDF0: 50          NEGB  
DDF1: 0B          SEV   
DDF2: B8 01 B1    EORA  $01B1
DDF5: 01          NOP   
DDF6: 42          --------------------
DDF7: 2B 54       BMI   $DE4D
DDF9: FF 50 8F    stx   $508F
DDFC: EF 5B       stx   $5B,X
DDFE: FE F2 FF    ldx   $F2FF
DE01: 20 0B       bra   $DE0E

DE03: 42          --------------------
DE04: 0B          SEV   
DE05: B1 01 B8    cmpa  $01B8
DE08: 01          NOP   
DE09: 54          LSRB  
DE0A: FF 20 8F    stx   $208F
DE0D: EF 5B       stx   $5B,X
DE0F: FE F2 F4    ldx   $F2F4
DE12: A4 07       anda  $07,X
DE14: 48          ASLA  
DE15: CE D7 D2    ldx   #D7D2
DE18: BD D5 0D    jsr   $D50D
DE1B: 28 54       BVC   $DE71
DE1D: 90 19       SUBA  $0019
DE1F: 4A          deca  
DE20: 96 03       ldaa   $0003
DE22: 10          SBA   
DE23: 2E 01       BGT   $DE26
DE25: 4F          clra  
DE26: 97 03       staa   $0003
DE28: A0 16       SUBA  $16,X
DE2A: EB A0       ADDB  $A0,X
DE2C: 4D          TSTA  
DE2D: 19          DAA   
DE2E: 12          --------------------
DE2F: 29 54       BVS   $DE85
DE31: D9 2F       ADCB  $002F
DE33: 89 0E       ADCA  #0E
DE35: 03          --------------------
DE36: B8 01 5B    EORA  $015B
DE39: FD          --------------------
DE3A: E8 06       EORB  $06,X
DE3C: 02          --------------------
DE3D: C8 06       EORB  #06
DE3F: 02          --------------------
DE40: CE E6 32    ldx   #E632
DE43: 08          inx   
DE44: 8C E6 82    CMPX  #E6
DE47: 27 17       beq   $DE60
DE49: E6 00       ldab   $00,X
DE4B: 17          TBA   
DE4C: 84 7F       anda  #7F
DE4E: BD F1 E8    jsr   $F1E8
DE51: 5D          TSTB  
DE52: 2B EF       BMI   $DE43
DE54: 86 0F       ldaa   #0F
DE56: BD EC 3B    jsr   isnd_once
DE59: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
DE5C: 02     

DE5D: 20 E4       bra   $DE43

DE5F: 39          rts   

DE60: CE E6 32    ldx   #E632
DE63: 08          inx   
DE64: 8C E6 82    CMPX  #E6
DE67: 27 F6       beq   $DE5F
DE69: E6 00       ldab   $00,X
DE6B: 17          TBA   
DE6C: 84 7F       anda  #7F
DE6E: BD F1 EF    jsr   $F1EF
DE71: 5D          TSTB  
DE72: 2B EF       BMI   $DE63
DE74: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
DE77: 02  

DE78: 20 E9       bra   $DE63

DE7A: CE E6 32    ldx   #E632
DE7D: FF 13 98    stx   $1398
DE80: 08          inx   
DE81: 8C E6 82    CMPX  #E6
DE84: 27 D9       beq   $DE5F
DE86: E6 00       ldab   $00,X
DE88: 17          TBA   
DE89: 84 7F       anda  #7F
DE8B: BD F1 E8    jsr   $F1E8
DE8E: 5D          TSTB  
DE8F: 2B EF       BMI   $DE80
DE91: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
DE94: 03  

DE95: FE 13 98    ldx   $1398
DE98: 08          inx   
DE99: E6 00       ldab   $00,X
DE9B: 17          TBA   
DE9C: 84 7F       anda  #7F
DE9E: BD F1 EF    jsr   $F1EF
DEA1: 5D          TSTB  
DEA2: 2B F4       BMI   $DE98
DEA4: 20 D7       bra   $DE7D

DEA6: 00          --------------------

gameover_init
DEA7: 3F          SWI   
DEA8: 36          psha  
DEA9: 01          NOP   
DEAA: 02          --------------------
DEAB: 03          --------------------
DEAC: 06          TAP   
DEAD: 07          TPA   
DEAE: 09          DEX   
DEAF: F8 19 14    EORB  $1914
DEB2: 29 D4       BVS   $DE88
DEB4: 14          --------------------
DEB5: 52          --------------------
DEB6: 10          SBA   
DEB7: 04          --------------------
DEB8: CE DF 6F    ldx   #DF6F
DEBB: BD D5 0D    jsr   $D50D
DEBE: 7F 00 E6    CLR   flag_tilt
DEC1: 7F 00 22    CLR   $0022
DEC4: CE E5 29    ldx   #msg_williams
DEC7: 8D 45       bsr   show_message
DEC9: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
DECC: 90 

DECD: CE E5 32    ldx   #msg_electronics
DED0: 8D 3C       bsr   show_message
DED2: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
DED5: 90 

DED6: CE E5 3E    ldx   #msg_presents
DED9: 8D 33       bsr   show_message
DEDB: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
DEDE: 70 

DEDF: CE E5 47    ldx   #msg_hyperball
DEE2: 5F          clrb  
DEE3: BD D3 15    jsr   $D315
DEE6: C6 25       ldab   #25
DEE8: CE 00 6B    ldx   #006B
DEEB: BD D2 F7    jsr   $D2F7
DEEE: 7C 00 22    INC   $0022
DEF1: BD E2 E7    jsr   $E2E7
DEF4: BD D2 D6    jsr   $D2D6
DEF7: BD D3 49    jsr   $D349
DEFA: 97 22       staa   $0022
DEFC: CE E5 51    ldx   #msg_credit
DEFF: BD D3 0B    jsr   $D30B
DF02: B6 11 9A    ldaa   current_credits
DF05: BD E6 D4    jsr   $E6D4
DF08: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
DF0B: E0 

DF0C: 20 B6       bra	$

show_message
DF0E: BD D3 0B    jsr	$D30B
DF11: BD D3 4C    jsr   $D34C
DF14: 86 04       ldaa   #04
DF16: CE 00 6C    ldx   #006C
DF19: 8D 1D       bsr   $DF38
DF1B: BD EA E5    jsr   hex2bitpos	Convert Hex(A&07) into Bitpos(B)
DF1E: 53          COMB  
DF1F: D4 7A       andb  dmask_p3
DF21: D7 7A       stab   dmask_p3
DF23: 08          inx   
DF24: 4A          deca  
DF25: 2A F2       BPL   $DF19
DF27: 86 06       ldaa   #06
DF29: 8D 0D       bsr   $DF38
DF2B: BD EA E5    jsr   hex2bitpos	Convert Hex(A&07) into Bitpos(B)
DF2E: 53          COMB  
DF2F: D4 7B       andb  dmask_p4
DF31: D7 7B       stab   dmask_p4
DF33: 08          inx   
DF34: 4A          deca  
DF35: 2A F2       BPL   $DF29
DF37: 39          rts   

DF38: 36          psha  
DF39: 37          PSHB  
DF3A: C6 01       ldab   #01
DF3C: 86 18       ldaa   #18
DF3E: A7 00       staa   $00,X
DF40: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
DF43: 02 

DF44: 86 2B       ldaa   #2B
DF46: A7 00       staa   $00,X
DF48: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
DF4B: 02   

DF4C: 5A          decb  
DF4D: 26 ED       bne   $DF3C
DF4F: 20 07       bra   $DF58

DF51: 36          psha  
DF52: 37          PSHB  
DF53: 8D 06       bsr   $DF5B
DF55: BD F1 BE    jsr   $F1BE
DF58: 33          PULB  
DF59: 32          pula  
DF5A: 39          rts   

DF5B: CE E4 7D    ldx   #E47D
DF5E: BD EE 8C    jsr   xplusb
DF61: A6 00       ldaa   $00,X
DF63: 39          rts   

DF64: CE DF 74    ldx   #DF74
DF67: 8D 03       bsr   $DF6C
DF69: CE E3 5E    ldx   #E35E
DF6C: 7E D5 0D    jmp   $D50D

DF6F: CE E3 34    ldx   #E334
DF72: 8D F8       bsr   $DF6C
DF74: CE DF B0    ldx   #DFB0
DF77: 8D F3       bsr   $DF6C
DF79: CE E6 81    ldx   #E681
DF7C: 08          inx   
DF7D: 8C E6 D2    CMPX  #E6
DF80: 27 14       beq   $DF96
DF82: A6 00       ldaa   $00,X
DF84: 16          tab   
DF85: 84 7F       anda  #7F
DF87: BD F1 91    jsr   $F191
DF8A: BD F1 D3    jsr   $F1D3
DF8D: 5D          TSTB  
DF8E: 2B EC       BMI   $DF7C
DF90: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
DF93: 05   

DF94: 20 E6       bra   $DF7C

DF96: CE E6 81    ldx   #E681
DF99: 08          inx   
DF9A: 8C E6 D2    CMPX  #E6
DF9D: 27 DA       beq   $DF79
DF9F: A6 00       ldaa   $00,X
DFA1: 16          tab   
DFA2: 84 7F       anda  #7F
DFA4: BD F1 B0    jsr   $F1B0
DFA7: 5D          TSTB  
DFA8: 2B EF       BMI   $DF99
DFAA: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
DFAD: 05 

DFAE: 20 E9       bra   $DF99

DFB0: 86 D4       ldaa   #D4
DFB2: BD F2 3D    jsr   $F23D
DFB5: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
DFB8: 04      

DFB9: 20 F5       bra   $DFB0

DFBB: 86 08       ldaa   #08
DFBD: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
DFC0: 40   

DFC1: 4A          deca  
DFC2: 26 F9       bne   $DFBD
DFC4: 86 09       ldaa   #09
DFC6: BD EA 83    jsr   solbuf
DFC9: 7E E9 C4    jmp   $E9C4	Remove Current Thread from Control Stack

DFCC: 5F          clrb  
DFCD: 86 0C       ldaa   #0C
DFCF: 7E D2 C8    jmp   $D2C8

DFD2: 16          tab   
DFD3: 84 0F       anda  #0F
DFD5: 8B 1B       ADDA  #1B
DFD7: 8A 80       oraa   #80
DFD9: A7 02       staa   $02,X
DFDB: BD EC 32    jsr   split_ab
DFDE: 4F          clra  
DFDF: 5D          TSTB  
DFE0: 27 03       beq   $DFE5
DFE2: CB 1B       ADDB  #1B
DFE4: 17          TBA   
DFE5: A7 01       staa   $01,X
DFE7: 86 1B       ldaa   #1B
DFE9: A7 03       staa   $03,X
DFEB: A7 04       staa   $04,X
DFED: A7 05       staa   $05,X
DFEF: 39          rts   

DFF0: CE E5 A5    ldx   #msg_reflex
DFF3: 86 04       ldaa   #04
DFF5: 97 0A       staa   $000A
DFF7: BD D2 6D    jsr   $D26D
DFFA: CE E5 74    ldx   #msg_wave
DFFD: BD D2 6D    jsr   $D26D
E000: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
E003: 40  

E004: 8D C6       bsr   $DFCC
E006: 97 0E       staa   $000E
E008: 97 0A       staa   $000A
E00A: BD D2 D6    jsr   $D2D6
E00D: 7C 00 0E    INC   $000E
E010: 86 14       ldaa   #14
E012: 91 0E       cmpa  $000E
E014: 26 53       bne   $E069
E016: BD D2 D6    jsr   $D2D6
E019: 86 10       ldaa   #10
E01B: BD EC 3B    jsr   isnd_once
E01E: 86 01       ldaa   #01
E020: 97 22       staa   $0022
E022: CE E5 FD    ldx   #E5FD
E025: BD D2 6D    jsr   $D26D
E028: 8D A2       bsr   $DFCC
E02A: CE 00 60    ldx   #0060
E02D: 96 05       ldaa   $0005
E02F: 81 06       cmpa  #06
E031: 2E 0B       BGT   $E03E
E033: 86 2C       ldaa   #2C
E035: BD EB 3D    jsr   $EB3D
E038: 86 50       ldaa   #50
E03A: 8D 96       bsr   $DFD2
E03C: 20 11       bra   $E04F

E03E: 86 0D       ldaa   #0D
E040: BD EB 3D    jsr   $EB3D
E043: 86 1C       ldaa   #1C
E045: A7 00       staa   $00,X
E047: 86 9B       ldaa   #9B
E049: A7 02       staa   $02,X
E04B: 86 1B       ldaa   #1B
E04D: 8D 96       bsr   $DFE5
E04F: CE 00 67    ldx   #0067
E052: DF B8       stx   temp1
E054: CE E5 8D    ldx   #msg_bonus
E057: BD D3 0D    jsr   $D30D
E05A: 3F          SWI   
E05B: 55          --------------------
E05C: 08          inx   
E05D: 00          --------------------
E05E: 56          RORB  
E05F: D7 0A       stab   $000A
E061: AF 01       STS   $01,X
E063: ED          --------------------
E064: 53          COMB  
E065: 50          NEGB  
E066: 5F          clrb  
E067: D7 5E       stab   cred_b0
E069: 3F          SWI   
E06A: 52          --------------------
E06B: 00          --------------------
E06C: 71          --------------------
E06D: 57          ASRB  
E06E: FB 94 44    ADDB  $9444
E071: 84 1F       anda  #1F
E073: 5A          decb  
E074: FB FD E0    ADDB  $FDE0
E077: 16          tab   
E078: D0 2F       subb  $002F
E07A: F1 5B F6    CMPB  $5BF6
E07D: 57          ASRB  
E07E: 02          --------------------
E07F: 19          DAA   
E080: 57          ASRB  
E081: 51          --------------------
E082: 10          SBA   
E083: B1 31 5B    cmpa  $315B
E086: D0 E1       subb  $00E1
E088: 04          --------------------
E089: B0 01 8F    SUBA  $018F
E08C: E3          --------------------
E08D: DC          --------------------
E08E: 01          NOP   
E08F: 51          --------------------
E090: 10          SBA   
E091: B0 49 DC    SUBA  $49DC
E094: 00          --------------------
E095: 5A          decb  
E096: FB FC E1    ADDB  $FCE1
E099: 16          tab   
E09A: FC          --------------------
E09B: E1 08       CMPB  $08,X
E09D: 04          --------------------
E09E: AE B1       LDS   $B1,X
E0A0: 80 0F       SUBA  #0F
E0A2: 5A          decb  
E0A3: FD          --------------------
E0A4: E1 08       CMPB  $08,X
E0A6: 06          TAP   
E0A7: 13          --------------------
E0A8: BA BB 3C    oraa   $BB3C
E0AB: 80 04       SUBA  #04
E0AD: 13          --------------------
E0AE: C3          --------------------
E0AF: C4 45       andb  #45
E0B1: 04          --------------------
E0B2: 36          psha  
E0B3: 37          PSHB  
E0B4: CE 00 62    ldx   #0062
E0B7: 96 0F       ldaa   $000F
E0B9: BD DF D2    jsr   $DFD2
E0BC: 33          PULB  
E0BD: 32          pula  
E0BE: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
E0C1: 30    

E0C2: 36          psha  
E0C3: 96 0C       ldaa   $000C
E0C5: 97 0D       staa   $000D
E0C7: 96 0D       ldaa   $000D
E0C9: 81 04       cmpa  #04
E0CB: 2D 03       BLT   $E0D0
E0CD: 7A 00 0D    DEC   $000D
E0D0: 97 D5       staa   thread_timer_byte
E0D2: 86 01       ldaa   #01
E0D4: BD EC 3B    jsr   isnd_once
E0D7: BD E9 71    jsr   delaythread
E0DA: 32          pula  
E0DB: BD DD 0F    jsr   $DD0F
E0DE: 27 2F       beq   $E10F
E0E0: CE 00 63    ldx   #0063
E0E3: 36          psha  
E0E4: BD E1 37    jsr   $E137
E0E7: 26 DE       bne   $E0C7
E0E9: 96 0E       ldaa   $000E
E0EB: 81 05       cmpa  #05
E0ED: 2F 1B       BLE   $E10A
E0EF: 32          pula  
E0F0: 86 1E       ldaa   #1E
E0F2: 97 E6       staa   flag_tilt
E0F4: BD EC 3B    jsr   isnd_once
E0F7: BD D2 D6    jsr   $D2D6
E0FA: 86 01       ldaa   #01
E0FC: 97 22       staa   $0022
E0FE: CE E5 9A    ldx   #msg_youmissed
E101: BD D2 6D    jsr   $D26D
E104: BD DF CC    jsr   $DFCC
E107: 7E E0 5A    jmp   $E05A

E10A: 32          pula  
E10B: 8D 46       bsr   $E153
E10D: 20 25       bra   $E134

E10F: 8D 42       bsr   $E153
E111: CE 00 63    ldx   #0063
E114: BD D8 34    jsr   $D834
E117: BD D3 46    jsr   $D346
E11A: 86 06       ldaa   #06
E11C: BD D8 53    jsr   $D853
E11F: 36          psha  
E120: 86 0E       ldaa   #0E
E122: BD EC 3B    jsr   isnd_once
E125: 32          pula  
E126: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
E129: 05  

E12A: 4A          deca  
E12B: 26 EF       bne   $E11C
E12D: 96 0F       ldaa   $000F
E12F: 8B 01       ADDA  #01
E131: 19          DAA   
E132: 97 0F       staa   $000F
E134: 7E E0 0A    jmp   $E00A

E137: A6 01       ldaa   $01,X
E139: 81 9B       cmpa  #9B
E13B: 27 05       beq   $E142
E13D: 4A          deca  
E13E: A7 01       staa   $01,X
E140: 20 10       bra   $E152

E142: A6 00       ldaa   $00,X
E144: 27 0C       beq   $E152
E146: 4A          deca  
E147: 81 1B       cmpa  #1B
E149: 26 01       bne   $E14C
E14B: 4F          clra  
E14C: A7 00       staa   $00,X
E14E: 86 A4       ldaa   #A4
E150: A7 01       staa   $01,X
E152: 39          rts   

E153: 3F          SWI   
E154: DD          --------------------
E155: 00          --------------------
E156: 5A          decb  
E157: FB FC E1    ADDB  $FCE1
E15A: 16          tab   
E15B: FC          --------------------
E15C: E1 08       CMPB  $08,X
E15E: 06          TAP   
E15F: AD FA       jsr   $FA,X
E161: 15          --------------------
E162: 00          --------------------
E163: 80 0B       SUBA  #0B
E165: 5A          decb  
E166: FD          --------------------
E167: E1 08       CMPB  $08,X
E169: 04          --------------------
E16A: 19          DAA   
E16B: 10          SBA   
E16C: 80 02       SUBA  #02
E16E: 19          DAA   
E16F: 11          CBA   
E170: 04          --------------------
E171: 39          rts   

gr_coin_hook
E172: 3F          SWI   
E173: E6 5A       ldab   $5A,X
E175: FB FB F0    ADDB  $FBF0
E178: D0 30       subb  $0030
E17A: F3          --------------------
E17B: F1 F3 55    CMPB  $F355
E17E: FF 10 04    stx   $1004
E181: 86 10       ldaa   #10
E183: CE DE F4    ldx   #DEF4
E186: 7E D5 0E    jmp   $D50E

highscoresound
E189: C6 0A       ldab   #0A
E18B: 7F 00 E6    CLR   flag_tilt
E18E: 96 BF       ldaa   sys_temp2
E190: B7 13 B7    staa   $13B7
E193: 97 E7       staa   flag_gameover
E195: B6 D0 5A    ldaa   $D05A
E198: BD EC 3B    jsr   isnd_once
E19B: CE E5 58    ldx   #msg_player
E19E: 37          PSHB  
E19F: BD D3 0B    jsr   $D30B
E1A2: 33          PULB  
E1A3: B6 13 B7    ldaa   $13B7
E1A6: 40          NEGA  
E1A7: 8B 1E       ADDA  #1E
E1A9: DE B8       ldx   temp1
E1AB: A7 01       staa   $01,X
E1AD: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
E1B0: 08     

E1B1: BD D2 D6    jsr   $D2D6
E1B4: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
E1B7: 08   

E1B8: 5A          decb  
E1B9: 26 DA       bne   $E195
E1BB: CE E6 1E    ldx   #E61E
E1BE: BD D3 0B    jsr   $D30B
E1C1: DE B8       ldx   temp1
E1C3: C6 10       ldab   #10
E1C5: BD D2 F7    jsr   $D2F7
E1C8: 86 18       ldaa   #18
E1CA: BD EC 3B    jsr   isnd_once
E1CD: 86 05       ldaa   #05
E1CF: C6 40       ldab   #40
E1D1: E7 00       stab   $00,X
E1D3: BD D2 C8    jsr   $D2C8
E1D6: CE E6 0A    ldx   #E60A
E1D9: BD D2 6D    jsr   $D26D
E1DC: CE E6 15    ldx   #E615
E1DF: BD D2 6D    jsr   $D26D
E1E2: 86 05       ldaa   #05
E1E4: C6 40       ldab   #40
E1E6: BD D2 C8    jsr   $D2C8
E1E9: BD E6 E8    jsr   $E6E8
E1EC: CE 00 60    ldx   #0060
E1EF: FF 13 A7    stx   $13A7
E1F2: 86 2E       ldaa   #2E
E1F4: A7 00       staa   $00,X
E1F6: BD E2 28    jsr   $E228
E1F9: A6 00       ldaa   $00,X
E1FB: 81 2D       cmpa  #2D
E1FD: 26 09       bne   $E208
E1FF: 6F 00       CLR   $00,X
E201: 09          DEX   
E202: A6 00       ldaa   $00,X
E204: 26 F0       bne   $E1F6
E206: 20 EA       bra   $E1F2

E208: 81 2E       cmpa  #2E
E20A: 26 04       bne   $E210
E20C: 86 00       ldaa   #00
E20E: A7 00       staa   $00,X
E210: 08          inx   
E211: 8C 00 63    CMPX  #00
E214: 26 DC       bne   $E1F2
E216: CE 01 2E    ldx   #012E
E219: DF B8       stx   temp1
E21B: C6 0C       ldab   #0C
E21D: CE 00 60    ldx   #0060
E220: BD EF 23    jsr   copyblock2
E223: D7 22       stab   $0022
E225: 7E FB 3E    jmp   $FB3E

E228: A6 00       ldaa   $00,X
E22A: B7 13 B6    staa   $13B6
E22D: 86 60       ldaa   #60
E22F: B7 13 B8    staa   $13B8
E232: 86 06       ldaa   #06
E234: B7 13 B7    staa   $13B7
E237: 7A 13 B8    DEC   $13B8
E23A: 26 06       bne   $E242
E23C: 31          INS   
E23D: 31          INS   
E23E: 6F 00       CLR   $00,X
E240: 20 D4       bra   $E216

E242: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
E245: 02  

E246: 96 80       ldaa   $0080
E248: 2A 0C       BPL   $E256
E24A: BD E2 DF    jsr   $E2DF
E24D: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
E250: 02   

E251: 96 80       ldaa   $0080
E253: 2B F8       BMI   $E24D
E255: 39          rts   

E256: 96 81       ldaa   $0081
E258: 84 03       anda  #03
E25A: 26 14       bne   $E270
E25C: 7A 13 B7    DEC   $13B7
E25F: 26 E1       bne   $E242
E261: A6 00       ldaa   $00,X
E263: 27 04       beq   $E269
E265: 6F 00       CLR   $00,X
E267: 20 C9       bra   $E232

E269: B6 13 B6    ldaa   $13B6
E26C: A7 00       staa   $00,X
E26E: 20 C2       bra   $E232

E270: BD E2 DF    jsr   $E2DF
E273: C6 20       ldab   #20
E275: F7 13 B7    stab   $13B7
E278: 46          RORA  
E279: 25 18       bcs   $E293
E27B: 8D 2D       bsr   $E2AA
E27D: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
E280: 01  

E281: 96 81       ldaa   $0081
E283: 85 02       BITA  #02
E285: 27 A1       beq   $E228
E287: 7A 13 B7    DEC   $13B7
E28A: 26 F1       bne   $E27D
E28C: 86 05       ldaa   #05
E28E: B7 13 B7    staa   $13B7
E291: 20 E8       bra   $E27B

E293: 8D 32       bsr   $E2C7
E295: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
E298: 01     

E299: 96 81       ldaa   $0081
E29B: 46          RORA  
E29C: 24 8A       bcc   $E228
E29E: 7A 13 B7    DEC   $13B7
E2A1: 26 F2       bne   $E295
E2A3: 86 05       ldaa   #05
E2A5: B7 13 B7    staa   $13B7
E2A8: 20 E9       bra   $E293

E2AA: A6 00       ldaa   $00,X
E2AC: 4C          inca  
E2AD: 81 2E       cmpa  #2E
E2AF: 26 02       bne   $E2B3
E2B1: 86 2E       ldaa   #2E
E2B3: 81 2F       cmpa  #2F
E2B5: 26 02       bne   $E2B9
E2B7: 86 01       ldaa   #01
E2B9: 81 1B       cmpa  #1B
E2BB: 26 07       bne   $E2C4
E2BD: 8C 00 60    CMPX  #00
E2C0: 27 EF       beq   $E2B1
E2C2: 86 2D       ldaa   #2D
E2C4: A7 00       staa   $00,X
E2C6: 39          rts   

E2C7: A6 00       ldaa   $00,X
E2C9: 4A          deca  
E2CA: 26 02       bne   $E2CE
E2CC: 86 2E       ldaa   #2E
E2CE: 81 2C       cmpa  #2C
E2D0: 26 02       bne   $E2D4
E2D2: 86 1A       ldaa   #1A
E2D4: 81 2D       cmpa  #2D
E2D6: 26 EC       bne   $E2C4
E2D8: 8C 00 60    CMPX  #00
E2DB: 27 F5       beq   $E2D2
E2DD: 20 E3       bra   $E2C2

E2DF: 36          psha  
E2E0: B6 13 B6    ldaa   $13B6
E2E3: A7 00       staa   $00,X
E2E5: 32          pula  
E2E6: 39          rts   

E2E7: BD FA B1    jsr   $FAB1
E2EA: D6 7C       ldab   comma_flags
E2EC: F7 13 B6    stab   $13B6
E2EF: 43          COMA  
E2F0: 7D 00 54    TST   $0054
E2F3: 26 06       bne   $E2FB
E2F5: 97 54       staa   $0054
E2F7: 97 58       staa   $0058
E2F9: 86 33       ldaa   #33
E2FB: 97 7C       staa   comma_flags
E2FD: 86 7F       ldaa   #7F
E2FF: BD F9 27    jsr   $F927
E302: CE E6 2A    ldx   #E62A
E305: BD D3 0B    jsr   $D30B
E308: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
E30B: 30   

E30C: 86 0C       ldaa   #0C
E30E: B7 13 A9    staa   $13A9
E311: CE 13 AA    ldx   #13AA
E314: DF B8       stx   temp1
E316: CE 01 2E    ldx   #012E
E319: C6 0C       ldab   #0C
E31B: BD FF CD    jsr   $FFCD
E31E: CE 13 A9    ldx   #13A9
E321: BD D2 B0    jsr   $D2B0
E324: BD D2 58    jsr   $D258
E327: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
E32A: A0 

E32B: F6 13 B6	  ldab   $13B6	  
E32E: D7 7C       stab   comma_flags
E330: 4F          clra  
E331: 7E F9 27    jmp   $F927

E334: CE 55 01    ldx   #5501
E337: DF 32       stx   $0032
E339: 86 80       ldaa   #80
E33B: D6 EB       ldab   player_up
E33D: 27 01       beq   $E340
E33F: 44          LSRA  
E340: 97 31       staa   $0031
E342: CE E3 58    ldx   #E358
E345: BD D5 0D    jsr   $D50D
E348: 3F          SWI   
E349: 5B          --------------------
E34A: F1 05 18    CMPB  $0518
E34D: 0A          CLV   
E34E: 1C          --------------------
E34F: 8A 0A       oraa   #0A
E351: 29 0A       BVS   $E35D
E353: 75          --------------------
E354: 2F 4A       BLE   $E3A0
E356: 8F          --------------------
E357: FB 3F 62    ADDB  $3F62
E35A: 1E          --------------------
E35B: 0A          CLV   
E35C: 8F          --------------------
E35D: FB 86 40    ADDB  $8640
E360: BD EA 83    jsr   solbuf
E363: BD E9 7C    jsr   $E97C	Push Following Routine onto Control Stack with Timer
E366: 0A    

E367: 20 F5       bra   $E35E


lamptable
	.db $00, $5F
	.db $00, $05 	;H-Top, H-Bottom
	.db $06, $0B	;I-Top, I-Bottom
	.db $0C, $11	;J-Top, J-Bottom
	.db $12, $17	;K-Top, K-Bottom
	.db $18, $1D	;L-Top, L-Bottom
	.db $1E, $23	;M-Top, M-Bottom
	.db $24, $29	;N-Top, N-Bottom
	.db $2A, $2F	;O-Top, O-Bottom
	.db $30, $35	;P-Top, P-Bottom
	.db $50, $59	;Energy Center Lamps
	.db $48, $4A	;Player 1 Z-Bombs
	.db $4B, $4D	;Player 2 Z-Bombs
	.db $31, $39
	.db $3A, $47
	.db $49, $5F
	.db $3A, $3C	;E-Top, E-Bottom
	.db $43, $45	;T-Top, T-Bottom
	.db $00, $47
	.db $01, $09
	.db $00, $4F	;All Lamps minus Energy Center Lamps
	.db $36, $3E	;A-G
	.db $3F, $47	;Y-R
	.db $31, $47 	;A-G,Y-R

 
soundtable

	.db $22, $30,	$3C;(03)	;(00) 
	.db $23, $10,	$3B;(04)	;(01) 
	.db $22, $20,	$3A;(05)	;(03) 
	.dw csound2\	.db $FF	;(04) 
	.dw csound1\	.db $FF	;(05) 
	.dw csound4\ 	.db $FF	;(06) 
	.db $22, $30,	$36;(09)	;(07)  
	.db $22, $20,	$35;(0A)	;(08)   
	.db $22, $20,   	$34;(0B)	;(09)
	.dw csound3\	.db $FF	;(10)
	.db $22, $20,	$30;(0F)	;(11)
	.db $22, $20,	$2F;(11)	;(12)
	.db $22, $20,	$2E;(12)	;(13)
	.db $22, $20,	$2D;(13)	;(14)
	.db $22, $20, 	$2C;(14)	;(15)
	.db $22, $20,	$2B;(15)	;(16)
	.db $83, $50,	$2A;(16)	;(17)
	.db $22, $20,	$29;(17)	;(18)
	.db $83, $40,	$32;(  )	;(19)
	.db $22, $20,	$28;(  )	;(20)
	.db $22, $20,	$27;(  )	;(21)
	.db $23, $20,	$3D;(  )	;(22)
	.db $22, $20,	$26;(  )	;(23)
	.db $22, $20,	$25;(  )	;(24)
	.db $24, $20, 	$3E;(  )	;(25)
	.db $22, $20,	$24;(  )	;(26)
	.db $22, $20,	$23;(  )	;(27)
	.db $22, $20,	$22;(  )	;(28)
	.db $22, $20,	$31;(  )	;(29)
	.db $22, $20, 	$21;(  )	;(30)
	.db $23, $30,	$20;(  )	;(31)
	
csound1	
	.db $21,$92,$38;$3E,$3F
csound2
	.db $26,$F5,$2E,$C0,$2D,$3F
csound3
	.db $26,$FF,$37,$2D,$3F
csound4
	.db $26,$FF,$24,$2D,$3F  


switchtable
	.db $93	\.dw $D35A			;(1) Plumb Bob Tilt
	.db $71	\.dw $D13F			;(2) Player 2 Start
	.db $71	\.dw $D13E			;(3) Player 1 Start
	.db $F2	\.dw coin_accepted	;(4) Right Coin
	.db $F2	\.dw coin_accepted	;(5) Center Coin
	.db $F2	\.dw coin_accepted	;(6) Left Coin
	.db $71	\.dw $D730			;(7) Slam
	.db $71	\.dw $D11B			;(8) High Score Reset
	
	.db $11	\.dw $D7C7			;(9) A
	.db $11	\.dw $D7C7			;(10) B
	.db $11	\.dw $D7C7			;(11) B
	.db $11	\.dw $D7C7			;(12) B
	.db $11	\.dw $D7C7			;(13) Y
	.db $11	\.dw $D7C7			;(14) W
	.db $11	\.dw $D7C7			;(15) V
	.db $11	\.dw $D7C7			;(16) U

	.db $91	\.dw $D794			;(17) E
	.db $11	\.dw $D79E			;(18) F
	.db $11	\.dw $D7A2			;(19) G
	.db $8F	\.dw $D728			;(20) H
	.db $8F	\.dw $D728			;(21) I
	.db $8F	\.dw $D728			;(22) J
	.db $8F	\.dw $D728			;(23) K
	.db $8F	\.dw $D728			;(24) L
	
	.db $8F	\.dw $D728			;(25) M
	.db $8F	\.dw $D728			;(26) N
	.db $8F	\.dw $D728			;(27) O
	.db $8F	\.dw $D728			;(28) P
	.db $11	\.dw $D7C3			;(29) R
	.db $11	\.dw $D7BF			;(30) S
	.db $91	\.dw $D78A			;(31) T
	.db $B3	\.dw $DD9B			;(32) Z-Bomb

	.db $94	\.dw $D547			;(33) Left Shooter
	.db $94	\.dw $D547			;(34) Right Shooter

switchtable_end



E471: 3D          WAI   

E472: 3E          --------------------
E473: 36          psha  
E474: 37          PSHB  
E475: 38          --------------------
E476: 39          rts   

E477: 3F          SWI   
E478: 40          NEGA  
E479: 41          --------------------
E47A: 42          --------------------
E47B: 46          RORA  
E47C: 47          ASRA  
E47D: 36          psha  
E47E: 37          PSHB  
E47F: 38          --------------------
E480: 39          rts   

E481: 3F          SWI   
E482: 40          NEGA  
E483: 41          --------------------
E484: 42          --------------------
E485: 00          --------------------
E486: 3D          WAI   

E487: 3E          --------------------
E488: 00          --------------------
E489: 06          TAP   
E48A: 0C          CLC   
E48B: 12          --------------------
E48C: 18          --------------------
E48D: 1E          --------------------
E48E: 24 2A       bcc   $E4BA
E490: 30          TSX   
E491: 47          ASRA  
E492: 46          RORA  
E493: 00          --------------------
E494: 06          TAP   
E495: 07          TPA   
E496: 01          NOP   
E497: 02          --------------------
E498: 03          --------------------
E499: 04          --------------------
E49A: 19          DAA   
E49B: 17          TBA   
E49C: 16          tab   
E49D: 15          --------------------
E49E: 13          --------------------
E49F: 12          --------------------
E4A0: 05          --------------------
E4A1: 14          --------------------
E4A2: 0C          CLC   
E4A3: 0F          SEI   
E4A4: 13          --------------------
E4A5: 15          --------------------
E4A6: E5 93       BITB  $93,X
E4A8: E5 8D       BITB  switch_pending,X
E4AA: E5 C2       BITB  $C2,X
E4AC: E5 DD       BITB  $DD,X
E4AE: E5 EA       BITB  $EA,X
E4B0: E5 E4       BITB  $E4,X
E4B2: E5 F0       BITB  $F0,X
E4B4: 01          NOP   
E4B5: 02          --------------------
E4B6: 03          --------------------
E4B7: 04          --------------------
E4B8: 19          DAA   
E4B9: 17          TBA   
E4BA: 16          tab   
E4BB: 15          --------------------
E4BC: 05          --------------------
E4BD: 06          TAP   
E4BE: 07          TPA   
E4BF: 08          inx   
E4C0: 09          DEX   
E4C1: 0A          CLV   
E4C2: 0B          SEV   
E4C3: 0C          CLC   
E4C4: 0D          SEC   
E4C5: 0E          CLI   
E4C6: 0F          SEI   
E4C7: 10          SBA   
E4C8: 12          --------------------
E4C9: 13          --------------------
E4CA: 14          --------------------

character_defs
E4CB: .dw $0000   ;Space
E4CD: .dw $3706   ;A
E4CF: .dw $8F14   ;B 
E4D1: .dw $3900   ;C 
E4D3: .dw $8F10   ;D 
E4D5: .dw $3902   ;E 
E4D7: .dw $3102   ;F 
E4D9: .dw $3D04   ;G 
E4DB: .dw $3606   ;H 
E4DD: .dw $8910   ;I 
E4DF: .dw $1E00   ;J 
E4E1: .dw $3023 	;K
E4E3: .dw $3800   ;L 
E4E5: .dw $7601 	;M
E4E7: .dw $7620 	;N
E4E9: .dw $3F00   ;O 
E4EB: .dw $3306   ;P 
E4ED: .dw $3F20	;Q
E4EF: .dw $3326	;R
E4F1: .dw $2D06   ;S 
E4F3: .dw $8110   ;T 
E4F5: .dw $3E00   ;U 
E4F7: .dw $3009   ;V   
E4F9: .dw $3628   ;W
E4FB:	.dw $4029	;X
E4FD:	.dw $2216   ;Y   
E4FF: .dw $0909   ;Z   
E501: .dw $3F09   ;0 
E503: .dw $8010   ;1
E505: .dw $0B0C   ;2     
E507: .dw $0D05   ;3     
E509: .dw $2606   ;4    
E50B: .dw $2922   ;5    
E50D: .dw $3D06   ;6       
E50F: .dw $0700   ;7       
E511: .dw $3F06   ;8       
E513: .dw $2F06   ;9    
E515: .dw $8200   ;quot    
E517: .dw $0006   ;-
E519: .dw $4020	;\
E51B:	.dw $8010   ;|
E51D: .dw $0009   ;/       
E51F: .dw $BB04	;@
E521:	.dw $8016   ;+      
E523: .dw $C03F   ;
E525: .dw $0025	;<-
E527:	.dw $0800   ;_

J H F E  D C B A   X X N P  R M G K
       
;-----------------------------------------------------------------
; Character Definitions for Alpha Display
;
; First Byte - String Setup Info
;	MSB - ?
;	LSB - Lenght of String
; Second Byte and beyond - Character Data
;     Flag at 0x40 is for dot segment
;
;-----------------------------------------------------------------       
; WILLIAMS
msg_williams	.db $28,$17,$09,$0C,$0C,$09,$01,$0D,$13 
; ELECTRONICS
msg_electronics 	.db $0B,$05,$0C,$05,$03,$14,$12,$0F,$0E,$09,$03,$13          
; PRESENTS
msg_presents 	.db $28,$10,$12,$05,$13,$05,$0E,$14,$13
; HYPERBALL
msg_hyperball 	.db $19,$08,$19,$10,$05,$12,$02,$01,$0C,$0C
; CREDIT
msg_credit		.db $16,$03,$12,$05,$04,$09,$14   
; PLAYER      
msg_player 		.db $26,$10,$0C,$01,$19,$05,$12    
; GAME
msg_game		.db $05,$00,$07,$01,$0D,$05  
; OVER 
msg_over		.db $05,$0F,$16,$05,$12,$00
; CRITICAL
msg_critical	.db $28,$03,$12,$09,$14,$09,$03,$01,$0C 
; WAVE        
msg_wave		.db $24,$17,$01,$16,$05
; COMPLETED
msg_completed: 	.db $19,$03,$0F,$0D,$10,$0C,$05,$14,$05,$04
; * SPELL *
msg_spell		.db $19,$2C,$00,$13,$10,$05,$0C,$0C,$00,$2C
; BONUS
msg_bonus		.db $05,$02,$0F,$0E,$15,$13 
; ENERGY
msg_energy		.db $06,$05,$0E,$05,$12,$07,$19    
; YOU MISSED
msg_youmissed	.db $0A,$19,$0F,$15,$00,$0D,$09,$13,$13,$05,$04  
; REFLEX   
msg_reflex		.db $06,$12,$05,$06,$0C,$05,$18   
; HIT
msg_hit		.db $03,$08,$09,$14
; 3-E.U.
E5B0: .db $15,$1E,$26,$45,$55,$00 
; 3-Z.B.        
E5B6: .db $15,$1E,$26,$5A,$42,$00  
; 0,000       
E5BC: .db $05,$24,$9B,$1B,$1B,$1B   
; HYPER      
E5C2: .db $05,$08,$19,$10,$05,$12 
; E-UNIT 
E5C8: .db $07,$05,$26,$15,$0E,$09,$14,$00   
; *_SSR__EJS_*     
E5D0: .db $0C,$2C,$00,$13,$13,$12,$00,$00,$05,$0A,$13,$00,$2C 
; CANNON
E5DD: .db $06,$03,$01,$0E,$0E,$0F,$0E    
; ALIEN
E5E4: .db $05,$01,$0C,$09,$05,$0E 
; LASER    
E5EA: .db $05,$0C,$01,$13,$05,$12 
; RAY    
E5F0: .db $03,$12,$01,$19
; *_TILT_*
E5F4: .db $28,$2C,$00,$14,$09,$0C,$14,$00,$2C
; GREAT REFLEX
E5FD: .db $0C,$07,$12,$05,$01,$14,$00,$12,$05,$06,$0C,$05,$18   
; ENTER YOUR
E60A: .db $0A,$05,$0E,$14,$05,$12,$00,$19,$0F,$15,$12
; INITIALS  
E615: .db $08,$09,$0E,$09,$14,$09,$01,$0C,$13 
; GREAT SCORE
E61E: .db $0B,$07,$12,$05,$01,$14,$00,$13,$03,$0F,$12,$05  
; HY SCORE
E62A: .db $28,$08,$19,$00,$13,$03,$0F,$12,$05    

E633: 1B          ABA   
E634: 95 21       BITA  $0021
E636: A7 A2       staa   $A2,X
E638: 9C 96       CPX   $0096
E63A: 8F          --------------------
E63B: 1A          --------------------
E63C: A0 AD       SUBA  $AD,X
E63E: A8 90       EORA  $90,X
E640: 89 14       ADCA  #14
E642: A6 B3       ldaa   $B3,X
E644: AE 8A       LDS   $8A,X
E646: 83          --------------------
E647: 0E          CLI   
E648: AC A9       CPX   $A9,X
E64A: A3          --------------------
E64B: 9D          --------------------
E64C: 97 91       staa   $0091
E64E: 84 B4       anda  #B4
E650: 08          inx   
E651: B2 B5 AF    SBCA  $B5AF
E654: 8B 85       ADDA  #85
E656: 02          --------------------
E657: CE CF C8    ldx   #CFC8
E65A: CB 93       ADDB  #93
E65C: 99 1F       ADCA  $001F
E65E: CD          --------------------
E65F: CC          --------------------
E660: C9 CA       ADCB  #CA
E662: 81 87       cmpa  #87
E664: 8D A5       bsr   $E60B
E666: AB 31       ADDA  $31,X
E668: C7          --------------------
E669: C3          --------------------
E66A: C2 BA       SBCB  #BA
E66C: B9 3E C6    ADCA  $3EC6
E66F: C4 C1       andb  #C1
E671: B8 BB BD    EORA  $BBBD
E674: 92 98       SBCA  $0098
E676: 1E          --------------------
E677: A4 AA       anda  $AA,X
E679: B0 C5 BF    SUBA  $C5BF
E67C: B6 B7 BC    ldaa   $B7BC
E67F: 80 86       SUBA  #86
E681: 0C          CLC   
E682: B6 3F B7    ldaa   $3FB7
E685: 40          NEGA  
E686: B8 C1 CA    EORA  $C1CA
E689: 4D          TSTA  
E68A: C9 CC       ADCB  #CC
E68C: 85 8B       BITA  #8B
E68E: 91 97       cmpa  $0097
E690: 9D          --------------------
E691: A3          --------------------
E692: A9 AF       ADCA  $AF,X
E694: 35          TXS   
E695: C8 CB       EORB  #CB
E697: 84 8A       anda  #8A
E699: 90 96       SUBA  $0096
E69B: 9C A2       CPX   $00A2
E69D: A8 AE       EORA  $AE,X
E69F: 34          DES   
E6A0: C2 CF       SBCB  #CF
E6A2: B9 4E 83    ADCA  $4E83
E6A5: 89 8F       ADCA  #8F
E6A7: 95 9B       BITA  $009B
E6A9: A1 A7       cmpa  $A7,X
E6AB: AD 33       jsr   $33,X
E6AD: BA C3 82    oraa   $C382
E6B0: 88 8E       EORA  #8E
E6B2: 94 9A       anda  $009A
E6B4: A0 A6       SUBA  $A6,X
E6B6: AC 32       CPX   $32,X
E6B8: BB 44 C6    ADDA  $44C6
E6BB: C7          --------------------
E6BC: BC 81 87    CPX   $8187
E6BF: 8D 93       bsr   $E654
E6C1: 99 9F       ADCA  $009F
E6C3: A5 AB       BITA  $AB,X
E6C5: 31          INS   
E6C6: BD C5 3E    jsr   $C53E
E6C9: 80 86       SUBA  #86
E6CB: 8C 92 98    CMPX  #92
E6CE: 9E A4       LDS   $00A4
E6D0: AA 30       oraa   $30,X
E6D2: 96 05       ldaa   $0005
E6D4: 16          tab   
E6D5: 84 0F       anda  #0F
E6D7: 8B 1B       ADDA  #1B
E6D9: DE B8       ldx   temp1
E6DB: A7 02       staa   $02,X
E6DD: BD EC 32    jsr   split_ab
E6E0: 5D          TSTB  
E6E1: 27 02       beq   $E6E5
E6E3: CB 1B       ADDB  #1B
E6E5: E7 01       stab   $01,X
E6E7: 39          rts   

E6E8: CE 13 A7    ldx   #13A7
E6EB: DF B8       stx   temp1
E6ED: 8D E3       bsr   $E6D2
E6EF: 86 08       ldaa   #08
E6F1: A7 00       staa   $00,X
E6F3: 86 13       ldaa   #13
E6F5: A7 08       staa   $08,X
E6F7: 6F 03       CLR   $03,X
E6F9: CE 13 AB    ldx   #13AB
E6FC: DF B8       stx   temp1
E6FE: CE E5 74    ldx   #msg_wave
E701: BD D3 0D    jsr   $D30D
E704: BD D2 B0    jsr   $D2B0
E707: 5F          clrb  
E708: 86 04       ldaa   #04
E70A: BD D2 C8    jsr   $D2C8
E70D: CE 13 A7    ldx   #13A7
E710: 7E D2 58    jmp   $D258



