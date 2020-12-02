;*****************************************************************************
;* Williams Level 7 Virtual Machine Macro Definitions
;*****************************************************************************
;* Code copyright Williams Electronic Games Inc.
;* Written/Decoded by Jess M. Askey (jess@askey.org)
;* For use with TASMx Assembler
;* Visit http://www.gamearchive.com/pinball/manufacturer/williams/pinbuilder
;* for more information.
;* You may redistribute this file as long as this header remains intact.
;*****************************************************************************
.module wml7
.msfirst

wml1_       .equ  $00
wml2_       .equ  $00
wml3_       .equ  $00
wml4_       .equ  $00
wml5_       .equ  $00
wml6_       .equ  $00

#define     FLAG_WML_IF       $10
#define     FLAG_WML_ELSE     $20
#define	FLAG_WML_BEGIN 	$40
#define     FLAG_WML_EXE      $80

;********************************************************
;* First Define the Thread Structure used in the virtual 
;* machine linked list.
;********************************************************
;* Next:	This is the pointer to the next thread in 
;* 		the linked list. The VM requires this to 
;*		move about the list of threads. This is 
;* 		set by the VM thread handlers and does not
;*          need to be manually fiddled with by the 
;*          game program as it is automatic.
;*
;* Timer:	This is a byte timer (0-255) that holds the 
;*          number of IRQ's counts required before the 
;*          thread is executed. This is set by the 
;*          programmer for delays between executions.	
;*
;* Vars:	When a thread is created, the originating
;*          program may push up to 8 additional bytes
;* 		of data onto the stack which will then be
;*          placed into these 8 byte holders.
;*
;* PC:	This is the address of the program entry 
;*          point that will be executed when the thread
;*       	timer expires.
;*
;* ID:	The thread ID is a number that identifies 
;* 		the thread type. The ID defintions are all
;*		decided by the programmer except for thread
;*		ID #06 which is a general 'end-of-ball' terminated
;*		thread. Because the VM can destroy groups of 
;* 		threads by ID and branch on existence of threads
;*    	with certain ID's, this is a very important
;*		design consideration. See the programming 
;*  		manual for more information.
;*	
;* RegA:	This holds the value that was contained in 
;*		the CPU register A when the Thread was created.
;*
;* RegB:	Similar to above, holds the value of CPU reg B.
;*
;* RegX:	Again, holds the value of the X register upon
;*		thread creation.
;*
;************************************************************

threadobj_next	.equ	$00
threadobj_timer	.equ	$02
threadobj_var1	.equ	$03
threadobj_var2	.equ	$04
threadobj_var3	.equ	$05
threadobj_var4	.equ	$06
threadobj_var5	.equ	$07
threadobj_var6	.equ	$09
threadobj_var7	.equ	$09
threadobj_var8	.equ	$0a
threadobj_pc	.equ	$0b
threadobj_id	.equ	$0d
threadobj_rega	.equ	$0e
threadobj_regb	.equ	$0f
threadobj_regx	.equ	$10

;********************************************************
;* Switch Table Equates
;********************************************************
#define	SWITCHENTRY(a,b)	\.db a \.dw b

sf_wml7	      .equ	$80
sf_code 	      .equ 	$00
sf_tilt	      .equ	$40
sf_notilt         .equ  $00
sf_gameover	      .equ	$20
sf_nogameover     .equ  $00
sf_enabled	      .equ	$10
sf_disabled       .equ  $00
sf_instant	      .equ	$08
sf_delayed        .equ  $00

;********************************************************
;* Define our Level 7 macros.
;********************************************************

#define 	PC100_	\.db $00	
#define 	NOP_		\.db $01	
#define	MRTS_		\.db $02
#define	KILL_		\.db $03	
#define 	CPUX_		\.db $04
#define	SPEC_		\.db $05	
#define	EB_		\.db $06	

;********************************************************
;* Lamp Macro Definition: These take care of turning lamps
;*                        on/off and doing the basic lamp
;*                        effects.
;********************************************************
#define	BITON_(a)		      \.db $10,a
#define	BITON_(a,b)		      \.db $10,((a&$7F)+$80),b
#define	BITON_(a,b,c)	      \.db $10,((a&$7F)+$80),((b&$7F)+$80),c
#define	BITON_(a,b,c,d)	      \.db $10,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),d
#define	BITON_(a,b,c,d,e)	      \.db $10,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),((d&$7F)+$80),e

#define	BITOFF_(a)		      \.db $11,a
#define	BITOFF_(a,b)		\.db $11,((a&$7F)+$80),b
#define	BITOFF_(a,b,c)	      \.db $11,((a&$7F)+$80),((b&$7F)+$80),c
#define	BITOFF_(a,b,c,d)	      \.db $11,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),d
#define	BITOFF_(a,b,c,d,e)	\.db $11,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),((d&$7F)+$80),e

#define	BITINV_(a)		      \.db $12,a
#define	BITINV_(a,b)		\.db $12,((a&$7F)+$80),b
#define	BITINV_(a,b,c)	      \.db $12,((a&$7F)+$80),((b&$7F)+$80),c
#define	BITINV_(a,b,c,d)	      \.db $12,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),d
#define	BITINV_(a,b,c,d,e)	\.db $12,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),((d&$7F)+$80),e

#define	BITFL_(a)		      \.db $13,a
#define	BITFL_(a,b)		      \.db $13,((a&$7F)+$80),b
#define	BITFL_(a,b,c)	      \.db $13,((a&$7F)+$80),((b&$7F)+$80),c
#define	BITFL_(a,b,c,d)	      \.db $13,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),d
#define	BITFL_(a,b,c,d,e)	      \.db $13,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),((d&$7F)+$80),e
 
#define	BITONP_(a)		      \.db $14,a
#define	BITONP_(a,b)		\.db $14,((a&$7F)+$80),b
#define	BITONP_(a,b,c)	      \.db $14,((a&$7F)+$80),((b&$7F)+$80),c
#define	BITONP_(a,b,c,d)	      \.db $14,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),d
#define	BITONP_(a,b,c,d,e)	\.db $14,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),((d&$7F)+$80),e

#define	BITOFFP_(a)		      \.db $15,a
#define	BITOFFP_(a,b)		\.db $15,((a&$7F)+$80),b
#define	BITOFFP_(a,b,c)	      \.db $15,((a&$7F)+$80),((b&$7F)+$80),c
#define	BITOFFP_(a,b,c,d)	      \.db $15,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),d
#define	BITOFFP_(a,b,c,d,e)	\.db $15,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),((d&$7F)+$80),e

#define	BITINVP_(a)		      \.db $16,a
#define	BITINVP_(a,b)		\.db $16,((a&$7F)+$80),b
#define	BITINVP_(a,b,c)	      \.db $16,((a&$7F)+$80),((b&$7F)+$80),c
#define	BITINVP_(a,b,c,d)	      \.db $16,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),d
#define	BITINVP_(a,b,c,d,e)	\.db $16,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),((d&$7F)+$80),e

#define	BITFLP_(a)		      \.db $17,a
#define	BITFLP_(a,b)		\.db $17,((a&$7F)+$80),b
#define	BITFLP_(a,b,c)	      \.db $17,((a&$7F)+$80),((b&$7F)+$80),c
#define	BITFLP_(a,b,c,d)	      \.db $17,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),d
#define	BITFLP_(a,b,c,d,e)	\.db $17,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),((d&$7F)+$80),e

;************************
;* Lamp/Bit Effects
;************************
#define	BE18_(a)		      \.db $18,a
#define	BE18_(a,b)		      \.db $18,((a&$7F)+$80),b
#define	BE18_(a,b,c)	      \.db $18,((a&$7F)+$80),((b&$7F)+$80),c
#define	BE18_(a,b,c,d)	      \.db $18,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),d
#define	BE18_(a,b,c,d,e)	      \.db $18,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),((d&$7F)+$80),e

#define	BE19_(a)		      \.db $19,a
#define	BE19_(a,b)		      \.db $19,((a&$7F)+$80),b
#define	BE19_(a,b,c)	      \.db $19,((a&$7F)+$80),((b&$7F)+$80),c
#define	BE19_(a,b,c,d)	      \.db $19,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),d
#define	BE19_(a,b,c,d,e)	      \.db $19,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),((d&$7F)+$80),e

#define	BE1A_(a)		      \.db $1A,a
#define	BE1A_(a,b)		      \.db $1A,((a&$7F)+$80),b
#define	BE1A_(a,b,c)	      \.db $1A,((a&$7F)+$80),((b&$7F)+$80),c
#define	BE1A_(a,b,c,d)	      \.db $1A,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),d
#define	BE1A_(a,b,c,d,e)	      \.db $1A,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),((d&$7F)+$80),e

#define	BE1B_(a)		      \.db $1B,a
#define	BE1B_(a,b)		      \.db $1B,((a&$7F)+$80),b
#define	BE1B_(a,b,c)	      \.db $1B,((a&$7F)+$80),((b&$7F)+$80),c
#define	BE1B_(a,b,c,d)	      \.db $1B,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),d
#define	BE1B_(a,b,c,d,e)	      \.db $1B,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),((d&$7F)+$80),e

#define	BE1C_(a)		      \.db $1C,a
#define	BE1C_(a,b)		      \.db $1C,((a&$7F)+$80),b
#define	BE1C_(a,b,c)	      \.db $1C,((a&$7F)+$80),((b&$7F)+$80),c
#define	BE1C_(a,b,c,d)	      \.db $1C,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),d
#define	BE1C_(a,b,c,d,e)	      \.db $1C,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),((d&$7F)+$80),e

#define	BE1D_(a)		      \.db $1D,a
#define	BE1D_(a,b)		      \.db $1D,((a&$7F)+$80),b
#define	BE1D_(a,b,c)	      \.db $1D,((a&$7F)+$80),((b&$7F)+$80),c
#define	BE1D_(a,b,c,d)	      \.db $1D,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),d
#define	BE1D_(a,b,c,d,e)	      \.db $1D,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),((d&$7F)+$80),e

#define	BE1E_(a)		      \.db $1E,a
#define	BE1E_(a,b)		      \.db $1E,((a&$7F)+$80),b
#define	BE1E_(a,b,c)	      \.db $1E,((a&$7F)+$80),((b&$7F)+$80),c
#define	BE1E_(a,b,c,d)	      \.db $1E,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),d
#define	BE1E_(a,b,c,d,e)	      \.db $1E,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),((d&$7F)+$80),e

#define	BE1F_(a)		      \.db $1F,a
#define	BE1F_(a,b)		      \.db $1F,((a&$7F)+$80),b
#define	BE1F_(a,b,c)	      \.db $1F,((a&$7F)+$80),((b&$7F)+$80),c
#define	BE1F_(a,b,c,d)	      \.db $1F,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),d
#define	BE1F_(a,b,c,d,e)	      \.db $1F,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),((d&$7F)+$80),e

#define	BITON2_(a)		      \.db $20,a
#define	BITON2_(a,b)		\.db $20,((a&$7F)+$80),b
#define	BITON2_(a,b,c)	      \.db $20,((a&$7F)+$80),((b&$7F)+$80),c
#define	BITON2_(a,b,c,d)	      \.db $20,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),d
#define	BITON2_(a,b,c,d,e)	\.db $20,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),((d&$7F)+$80),e

#define	BITOFF2_(a)		      \.db $21,a
#define	BITOFF2_(a,b)		\.db $21,((a&$7F)+$80),b
#define	BITOFF2_(a,b,c)	      \.db $21,((a&$7F)+$80),((b&$7F)+$80),c
#define	BITOFF2_(a,b,c,d)	      \.db $21,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),d
#define	BITOFF2_(a,b,c,d,e)	\.db $21,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),((d&$7F)+$80),e

#define	BITINV2_(a)		      \.db $22,a
#define	BITINV2_(a,b)		\.db $22,((a&$7F)+$80),b
#define	BITINV2_(a,b,c)	      \.db $22,((a&$7F)+$80),((b&$7F)+$80),c
#define	BITINV2_(a,b,c,d)	      \.db $22,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),d
#define	BITINV2_(a,b,c,d,e)	\.db $22,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),((d&$7F)+$80),e

#define	BITFL2_(a)		      \.db $23,a
#define	BITFL2_(a,b)		\.db $23,((a&$7F)+$80),b
#define	BITFL2_(a,b,c)	      \.db $23,((a&$7F)+$80),((b&$7F)+$80),c
#define	BITFL2_(a,b,c,d)	      \.db $23,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),d
#define	BITFL2_(a,b,c,d,e)	\.db $23,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),((d&$7F)+$80),e
 
#define	BITONP2_(a)		      \.db $24,a
#define	BITONP2_(a,b)		\.db $24,((a&$7F)+$80),b
#define	BITONP2_(a,b,c)	      \.db $24,((a&$7F)+$80),((b&$7F)+$80),c
#define	BITONP2_(a,b,c,d)	      \.db $24,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),d
#define	BITONP2_(a,b,c,d,e)	\.db $24,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),((d&$7F)+$80),e

#define	BITOFFP2_(a)		\.db $25,a
#define	BITOFFP2_(a,b)		\.db $25,((a&$7F)+$80),b
#define	BITOFFP2_(a,b,c)	      \.db $25,((a&$7F)+$80),((b&$7F)+$80),c
#define	BITOFFP2_(a,b,c,d)	\.db $25,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),d
#define	BITOFFP2_(a,b,c,d,e)	\.db $25,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),((d&$7F)+$80),e

#define	BITINVP2_(a)		\.db $26,a
#define	BITINVP2_(a,b)		\.db $26,((a&$7F)+$80),b
#define	BITINVP2_(a,b,c)	      \.db $26,((a&$7F)+$80),((b&$7F)+$80),c
#define	BITINVP2_(a,b,c,d)	\.db $26,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),d
#define	BITINVP2_(a,b,c,d,e)	\.db $26,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),((d&$7F)+$80),e

#define	BITFLP2_(a)		      \.db $27,a
#define	BITFLP2_(a,b)		\.db $27,((a&$7F)+$80),b
#define	BITFLP2_(a,b,c)	      \.db $27,((a&$7F)+$80),((b&$7F)+$80),c
#define	BITFLP2_(a,b,c,d)	      \.db $27,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),d
#define	BITFLP2_(a,b,c,d,e)	\.db $27,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),((d&$7F)+$80),e

;************************
;* Lamp/Bit Effects
;************************
#define	BE28_(a)		      \.db $28,a
#define	BE28_(a,b)		      \.db $28,((a&$7F)+$80),b
#define	BE28_(a,b,c)	      \.db $28,((a&$7F)+$80),((b&$7F)+$80),c
#define	BE28_(a,b,c,d)	      \.db $28,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),d
#define	BE28_(a,b,c,d,e)	      \.db $28,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),((d&$7F)+$80),e

#define	BE29_(a)		      \.db $29,a
#define	BE29_(a,b)		      \.db $29,((a&$7F)+$80),b
#define	BE29_(a,b,c)	      \.db $29,((a&$7F)+$80),((b&$7F)+$80),c
#define	BE29_(a,b,c,d)	      \.db $29,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),d
#define	BE29_(a,b,c,d,e)	      \.db $29,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),((d&$7F)+$80),e

#define	BE2A_(a)		      \.db $2A,a
#define	BE2A_(a,b)		      \.db $2A,((a&$7F)+$80),b
#define	BE2A_(a,b,c)	      \.db $2A,((a&$7F)+$80),((b&$7F)+$80),c
#define	BE2A_(a,b,c,d)	      \.db $2A,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),d
#define	BE2A_(a,b,c,d,e)	      \.db $2A,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),((d&$7F)+$80),e

#define	BE2B_(a)		      \.db $2B,a
#define	BE2B_(a,b)		      \.db $2B,((a&$7F)+$80),b
#define	BE2B_(a,b,c)	      \.db $2B,((a&$7F)+$80),((b&$7F)+$80),c
#define	BE2B_(a,b,c,d)	      \.db $2B,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),d
#define	BE2B_(a,b,c,d,e)	      \.db $2B,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),((d&$7F)+$80),e

#define	BE2C_(a)		      \.db $2C,a
#define	BE2C_(a,b)		      \.db $2C,((a&$7F)+$80),b
#define	BE2C_(a,b,c)	      \.db $2C,((a&$7F)+$80),((b&$7F)+$80),c
#define	BE2C_(a,b,c,d)	      \.db $2C,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),d
#define	BE2C_(a,b,c,d,e)	      \.db $2C,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),((d&$7F)+$80),e

#define	BE2D_(a)		      \.db $2D,a
#define	BE2D_(a,b)		      \.db $2D,((a&$7F)+$80),b
#define	BE2D_(a,b,c)	      \.db $2D,((a&$7F)+$80),((b&$7F)+$80),c
#define	BE2D_(a,b,c,d)	      \.db $2D,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),d
#define	BE2D_(a,b,c,d,e)	      \.db $2D,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),((d&$7F)+$80),e

#define	BE2E_(a)		      \.db $2E,a
#define	BE2E_(a,b)		      \.db $2E,((a&$7F)+$80),b
#define	BE2E_(a,b,c)	      \.db $2E,((a&$7F)+$80),((b&$7F)+$80),c
#define	BE2E_(a,b,c,d)	      \.db $2E,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),d
#define	BE2E_(a,b,c,d,e)	      \.db $2E,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),((d&$7F)+$80),e

#define	BE2F_(a)		      \.db $2F,a
#define	BE2F_(a,b)		      \.db $2F,((a&$7F)+$80),b
#define	BE2F_(a,b,c)	      \.db $2F,((a&$7F)+$80),((b&$7F)+$80),c
#define	BE2F_(a,b,c,d)	      \.db $2F,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),d
#define	BE2F_(a,b,c,d,e)	      \.db $2F,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),((d&$7F)+$80),e

;********************************************************
;* Solenoid Macro Definition: Up to 15 Solenoids are Supported
;* 
;* The macro takes a coded value of the solenoid number 
;* and the number of IRQ's to leave the solenoid on.
;* You can define the solenoid number plus the time by using
;* the equates following this macro definition...
;* 
;* Example #1:  Turn on Solenoid #1 for 4 IRQ cycles
;*
;*          sol_1_on    .equ  $00+SOLENOID_ON_4_CYCLES
;*          sol_1_off   .equ  $00+SOLENOID_OFF
;* 
;* Then use the SOL_ macro...
;*
;*    Turn it on:       SOL_(sol_1_on)
;*    Turn it off:      SOL_(sol_1_off)
;*
;* Example #2:  Turn on Solenoid #15 indefinitely, and Solenoid #6 for 2 IRQ cycles
;*
;*          sol_15_on   .equ  $0E+SOLENOID_ON_LATCH
;*          sol_15_off  .equ  $0E+SOLENOID_OFF
;*
;*          sol_2_on    .equ  $01+SOLENOID_ON_2_CYCLES
;*          sol_2_off   .equ  $01+SOLENOID_OFF
;* 
;* Then use the SOL_ macro...
;*
;*    Turn them on:       SOL_(sol_15_on,sol_2_on)
;*    Turn them off:      SOL_(sol_15_off,sol_2_off)
;********************************************************
#define	SOL_(a)		                  \.db $31,a
#define	SOL_(a,b)		                  \.db $32,a,b
#define 	SOL_(a,b,c)		                  \.db $33,a,b,c
#define	SOL_(a,b,c,d)	                  \.db $34,a,b,c,d
#define	SOL_(a,b,c,d,e)	                  \.db $35,a,b,c,d,e
#define	SOL_(a,b,c,d,e,f)	                  \.db $36,a,b,c,d,e,f
#define	SOL_(a,b,c,d,e,f,g)	            \.db $37,a,b,c,d,e,f,g
#define	SOL_(a,b,c,d,e,f,g,h)	            \.db $38,a,b,c,d,e,f,g,h
#define	SOL_(a,b,c,d,e,f,g,h,i)	            \.db $39,a,b,c,d,e,f,g,h,i
#define	SOL_(a,b,c,d,e,f,g,h,i,j)	      \.db $3A,a,b,c,d,e,f,g,h,i,j
#define	SOL_(a,b,c,d,e,f,g,h,i,j,k)	      \.db $3B,a,b,c,d,e,f,g,h,i,j,k
#define	SOL_(a,b,c,d,e,f,g,h,i,j,k,l)	      \.db $3C,a,b,c,d,e,f,g,h,i,j,k,l
#define	SOL_(a,b,c,d,e,f,g,h,i,j,k,l,m)	\.db $3D,a,b,c,d,e,f,g,h,i,j,k,l,m
#define	SOL_(a,b,c,d,e,f,g,h,i,j,k,l,m,n)	\.db $3E,a,b,c,d,e,f,g,h,i,j,k,l,m,n
#define	SOL_(a,b,c,d,e,f,g,h,i,j,k,l,m,n,o)	\.db $3F,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o

;********************************************************
;* some additional solenoid defines for timing
;* Use these in the top of your game definition to specify 
;* static lables for each solenoid
;********************************************************
SOLENOID_ON_1_CYCLES       .equ  $20
SOLENOID_ON_2_CYCLES       .equ  $40
SOLENOID_ON_3_CYCLES       .equ  $60
SOLENOID_ON_4_CYCLES       .equ  $80
SOLENOID_ON_6_CYCLES       .equ  $A0
SOLENOID_ON_7_CYCLES       .equ  $C0
SOLENOID_ON_LATCH          .equ  $E0
SOLENOID_OFF               .equ  $00

;********************************************************
;* Macros 40-43: Static Length, easy
;********************************************************
#define	PTSND_(a,b)	      \.db $40,a,b
#define	PTCHIME_(a)	      \.db $41,a
#define	POINTS_(a)		\.db $42,a
#define	PTSDIG_(a)		\.db $43,a

;********************************************************
;* Macros 44-4F: Define temporary execution of CPU code.
;*               The length of bytes to execute is in 
;*               the lower nibble and must be between
;*               4-f. Therefore, number of bytes to 
;*               execute must be between 2 and 13.
:*
;* There are two macros defined here, the first is the
;* new style macro where it will automatically calculate
;* the number of opcode bytes that are executed. This 
;* style requires and end tag for the macro called EXEEND_
;* that marks where execution returns to WML7.
;*
;* The old style macro does not require an end tag but
;* does require you to calcuate the number of bytes that
;* will be executed as native 680X code. This is obviously
;* more tedious but I left it here for some reason. 
;********************************************************
#define     EXE_              \.push *,FLAG_WML_EXE
#defcont                      \.db $44

#define     EXEEND_           \wml4_ .set *
#defcont                      \.pop wml1_,wml2_
#defcont                      \#if wml1_ == FLAG_WML_EXE
#defcont                            \wml3_ .set wml4_-wml2_
#defcont                            \#if (wml3_>14)|(wml3_<3)
#defcont                            \     .error "Macro EXE_: Number of executed bytes must be between 2 and 15"
#defcont                            \#else
#defcont                            \     .org wml2_
#defcont                            \     .db $44+wml3_-3
#defcont                            \#endif
#defcont                            \.org wml4_
#defcont                      \#else
#defcont                            \.error "EXE_END did not have a starting EXE_ code"
#defcont                      \#endif

   
#define	EXE_(a)		\#if (a>13)|(a<2)
#defcont				\    .error "Macro EXE_: Number of bytes to execute must be between 2-15"
#defcont				\#else
#defcont				\    .db ($44+a-2)
#defcont				\#endif

;********************************************************
;* Macros 50-57:
;********************************************************
#define	RAMADD_(a,b)	\#if (a<16)&(a>=0)&(b<16)&(b>=0)
#defcont				\	.db $50,((a*16)+b) 
#defcont				\#else
#defcont				\	.error "Macro RAMADD_: Parameters out of range"
#defcont				\#endif

#define	RAMCPY_(a,b)	\#if (a<16)&(a>=0)&(b<16)&(b>=0)
#defcont				\	.db $51,((a*16)+b) 
#defcont				\#else
#defcont				\	.error "Macro RAMCPY_: Parameters out of range"
#defcont				\#endif

#define	PRI_(a)		\.db $52,a

#define	SLEEP_(a)		\#if (a<16)
#defcont				\	.db ($70+a)
#defcont				\#else
#defcont				\	.db $53,a
#defcont				\#endif

#define	REMTHREAD_(a,b)	\.db $54,a,b

#define  	REMTHREADS_(a,b)	\.db $55,a,b

#define 	JSR_(a)		\.db $56 \.dw a
#define	JSRD_(a)		\.db $57 \.dw a

;**********************************************************
;* Branch Macros: 58-5B
;**********************************************************
#define     IFLOC_(type,vars)    \ .push  *, vars, type        

#define     IFEQR_(z)                                 IFLOC_(FLAG_WML_IF,1)  \ BNER_(z,*+3)     
#define     IFEQR_(z,y)                               IFLOC_(FLAG_WML_IF,2)  \ BNER_(z,y,*+3)   
#define     IFEQR_(z,y,x)                             IFLOC_(FLAG_WML_IF,3)  \ BNER_(z,y,x,*+3) 
#define     IFEQR_(z,y,x,w)                           IFLOC_(FLAG_WML_IF,4)  \ BNER_(z,y,x,w,*+3)   
#define     IFEQR_(z,y,x,w,v)                         IFLOC_(FLAG_WML_IF,5)  \ BNER_(z,y,x,w,v,*+3) 
#define     IFEQR_(z,y,x,w,v,u)                       IFLOC_(FLAG_WML_IF,6)  \ BNER_(z,y,x,w,v,u,*+3) 
#define     IFEQR_(z,y,x,w,v,u,t)                     IFLOC_(FLAG_WML_IF,7)  \ BNER_(z,y,x,w,v,u,t,*+3) 
#define     IFEQR_(z,y,x,w,v,u,t,s)                   IFLOC_(FLAG_WML_IF,8)  \ BNER_(z,y,x,w,v,u,t,s,*+3) 
#define     IFEQR_(z,y,x,w,v,u,t,s,r)                 IFLOC_(FLAG_WML_IF,9)  \ BNER_(z,y,x,w,v,u,t,s,r,*+3)
#define     IFEQR_(z,y,x,w,v,u,t,s,r,q)               IFLOC_(FLAG_WML_IF,10) \ BNER_(z,y,x,w,v,u,t,s,r,q,*+3)
#define     IFEQR_(z,y,x,w,v,u,t,s,r,q,p)             IFLOC_(FLAG_WML_IF,11) \ BNER_(z,y,x,w,v,u,t,s,r,q,p,*+3)
#define     IFEQR_(z,y,x,w,v,u,t,s,r,q,p,o)           IFLOC_(FLAG_WML_IF,12) \ BNER_(z,y,x,w,v,u,t,s,r,q,p,o,*+3)
#define     IFEQR_(z,y,x,w,v,u,t,s,r,q,p,o,n)         IFLOC_(FLAG_WML_IF,13) \ BNER_(z,y,x,w,v,u,t,s,r,q,p,o,n,*+3)
#define     IFEQR_(z,y,x,w,v,u,t,s,r,q,p,o,n,m)       IFLOC_(FLAG_WML_IF,14) \ BNER_(z,y,x,w,v,u,t,s,r,q,p,o,n,m,*+3)
#define     IFEQR_(z,y,x,w,v,u,t,s,r,q,p,o,n,m,l)     IFLOC_(FLAG_WML_IF,15) \ BNER_(z,y,x,w,v,u,t,s,r,q,p,o,n,m,l,*+3)

#define     IFNER_(z)                                 IFLOC_(FLAG_WML_IF,1)  \ BEQR_(z,*+3)     
#define     IFNER_(z,y)                               IFLOC_(FLAG_WML_IF,2)  \ BEQR_(z,y,*+3)   
#define     IFNER_(z,y,x)                             IFLOC_(FLAG_WML_IF,3)  \ BEQR_(z,y,x,*+3) 
#define     IFNER_(z,y,x,w)                           IFLOC_(FLAG_WML_IF,4)  \ BEQR_(z,y,x,w,*+3) 
#define     IFNER_(z,y,x,w,v)                         IFLOC_(FLAG_WML_IF,5)  \ BEQR_(z,y,x,w,v,*+3) 
#define     IFNER_(z,y,x,w,v,u)                       IFLOC_(FLAG_WML_IF,6)  \ BEQR_(z,y,x,w,v,u,*+3) 
#define     IFNER_(z,y,x,w,v,u,t)                     IFLOC_(FLAG_WML_IF,7)  \ BEQR_(z,y,x,w,v,u,t,*+3) 
#define     IFNER_(z,y,x,w,v,u,t,s)                   IFLOC_(FLAG_WML_IF,8)  \ BEQR_(z,y,x,w,v,u,t,s,*+3) 
#define     IFNER_(z,y,x,w,v,u,t,s,r)                 IFLOC_(FLAG_WML_IF,9)  \ BEQR_(z,y,x,w,v,u,t,s,r,*+3)
#define     IFNER_(z,y,x,w,v,u,t,s,r,q)               IFLOC_(FLAG_WML_IF,10) \ BEQR_(z,y,x,w,v,u,t,s,r,q,*+3)
#define     IFNER_(z,y,x,w,v,u,t,s,r,q,p)             IFLOC_(FLAG_WML_IF,11) \ BEQR_(z,y,x,w,v,u,t,s,r,q,p,*+3)
#define     IFNER_(z,y,x,w,v,u,t,s,r,q,p,o)           IFLOC_(FLAG_WML_IF,12) \ BEQR_(z,y,x,w,v,u,t,s,r,q,p,o,*+3)
#define     IFNER_(z,y,x,w,v,u,t,s,r,q,p,o,n)         IFLOC_(FLAG_WML_IF,13) \ BEQR_(z,y,x,w,v,u,t,s,r,q,p,o,n,*+3)
#define     IFNER_(z,y,x,w,v,u,t,s,r,q,p,o,n,m)       IFLOC_(FLAG_WML_IF,14) \ BEQR_(z,y,x,w,v,u,t,s,r,q,p,o,n,m,*+3)
#define     IFNER_(z,y,x,w,v,u,t,s,r,q,p,o,n,m,l)     IFLOC_(FLAG_WML_IF,15) \ BEQR_(z,y,x,w,v,u,t,s,r,q,p,o,n,m,l,*+3)

#define     ENDIF_ \wml1_ .set *
#defcont		 \ .pop wml3_, wml5_, wml4_
#defcont		 \#if (wml3_ & FLAG_WML_BEGIN)==0
#defcont			\#if (wml3_ & FLAG_WML_ELSE)==0
#defcont  			      \wml2_ .set wml1_-wml4_-wml5_-2
#defcont			      \#if wml2_+127 < 0
#defcont				      \ .error "Branch Range < -127"
#defcont			      \#else
#defcont				      \#if wml2_-128 > 0
#defcont					      \ .error "Branch Range > 128"
#defcont				      \#else
#defcont    				      \ .org wml4_+wml5_+1
#defcont					      \ .byte wml2_
#defcont				      \#endif
#defcont			      \#endif
#defcont                \#else
#defcont                      \ .org  wml4_-2	
#defcont				\ JMP_(wml1_)
#defcont                      \ .error "123: Not Tested"
#defcont                \#endif
#defcont			\ .org	wml1_
#defcont		 \#else
#defcont			\.error "Wrong Endtype for IFXXR_ block"
#defcont		 \#endif

#define	ELSE_	\wml1_ .set $
#defcont		\ .pop wml3_, wml5_, wml4_
#defcont		\#if (wml3_ & FLAG_WML_BEGIN)==0
#defcont			\#if (wml3_ & FLAG_WML_ELSE)==0
#defcont				\ .org wml4_+wml5_+1
#defcont				\wml2_ .set wml1_-wml4_
#defcont					\#if wml2_+127 < 0
#defcont						\ .org wml1_
#defcont						\.push wml1_+3, wml5_, FLAG_WML_ELSE
#defcont						\ JMP_($)
#defcont                                  \ .error "(124)ELSE_: Not Tested with long JMP"
#defcont					\#else
#defcont						\#if wml2_-128>0
#defcont							\ .org wml1_
#defcont							\.push wml1_+3, wml5_, FLAG_WML_ELSE
#defcont							\ JMP_($)
#defcont                                  \ .error "(125)ELSE_: Not Tested with long JMP"
#defcont						\#else
#defcont							\.push wml1_-wml5_, wml5_, FLAG_WML_IF
#defcont							\ .byte wml2_-wml5_
#defcont							\ .org wml1_
#defcont							\ JMPR_($+1)
#defcont							\ .org wml1_+2
#defcont						\#endif
#defcont					\#endif
#defcont			\#else
#defcont				\.error "Duplicate ELSE Statement"
#defcont			\#endif
#defcont		\#else
#defcont			\ .error "Misplaced Else"
#defcont		\#endif

#define     BEQR_(p1__,ba__)     \#if $+3-ba__ < 128
#defcont                                 \.db $5A,p1__,ba__-$-3
#defcont				\#else
#defcont					\#if ba__-$+3 < 127
#defcont                                 \.db $5A,p1__,$+3-ba__
#defcont					\#else
#defcont    					 \ .error "WML7: Branch Macro Out Of Range."
#defcont					\#endif
#defcont				\#endif

#define     BEQR_(p1__,p2__,ba__)     \#if $+4-ba__ < 128
#defcont                                 \.db $5A,p1__,p2__,ba__-$-4
#defcont				\#else
#defcont					\#if ba__-$+4 < 127
#defcont                                 \.db $5A,p1__,p2__,$+4-ba__
#defcont					\#else
#defcont    					 \ .error "WML7: Branch Macro Out Of Range."
#defcont					\#endif
#defcont				\#endif

#define     BEQR_(p1__,p2__,p3__,ba__)     \#if $+5-ba__ < 128
#defcont                                 \.db $5A,p1__,p2__,p3__,ba__-$-5
#defcont				\#else
#defcont					\#if ba__-$+5 < 127
#defcont                                 \.db $5A,p1__,p2__,p3__,$+5-ba__
#defcont					\#else
#defcont    					 \ .error "WML7: Branch Macro Out Of Range."
#defcont					\#endif
#defcont				\#endif

#define     BEQR_(p1__,p2__,p3__,p4__,ba__)     \#if $+6-ba__ < 128
#defcont                                 \.db $5A,p1__,p2__,p3__,p4__,ba__-$-6
#defcont				\#else
#defcont					\#if ba__-$+6 < 127
#defcont                                 \.db $5A,p1__,p2__,p3__,p4__,$+6-ba__
#defcont					\#else
#defcont    					 \ .error "WML7: Branch Macro Out Of Range."
#defcont					\#endif
#defcont				\#endif

#define     BEQR_(p1__,p2__,p3__,p4__,p5__,ba__)     \#if $+7-ba__ < 128
#defcont                                 \.db $5A,p1__,p2__,p3__,p4__,p5__,ba__-$-7
#defcont				\#else
#defcont					\#if ba__-$+7 < 127
#defcont                                 \.db $5A,p1__,p2__,p3__,p4__,p5__,$+7-ba__
#defcont					\#else
#defcont    					 \ .error "WML7: Branch Macro Out Of Range."
#defcont					\#endif
#defcont				\#endif

#define     BEQR_(p1__,p2__,p3__,p4__,p5__,p6__,ba__)     \#if $+8-ba__ < 128
#defcont                                 \.db $5A,p1__,p2__,p3__,p4__,p5__,p6__,ba__-$-8
#defcont				\#else
#defcont					\#if ba__-$+8 < 127
#defcont                                 \.db $5A,p1__,p2__,p3__,p4__,p5__,p6__,$+8-ba__
#defcont					\#else
#defcont    					 \ .error "WML7: Branch Macro Out Of Range."
#defcont					\#endif
#defcont				\#endif

#define     BEQR_(p1__,p2__,p3__,p4__,p5__,p6__,p7__,ba__)     \#if $+9-ba__ < 128
#defcont                                 \.db $5A,p1__,p2__,p3__,p4__,p5__,p6__,p7__,ba__-$-9
#defcont				\#else
#defcont					\#if ba__-$+9 < 127
#defcont                                 \.db $5A,p1__,p2__,p3__,p4__,p5__,p6__,p7__,$+9-ba__
#defcont					\#else
#defcont    					 \ .error "WML7: Branch Macro Out Of Range."
#defcont					\#endif
#defcont				\#endif

#define     BEQR_(p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,ba__)     \#if $+10-ba__ < 128
#defcont                                 \.db $5A,p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,ba__-$-10
#defcont				\#else
#defcont					\#if ba__-$+10 < 127
#defcont                                 \.db $5A,p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,$+10-ba__
#defcont					\#else
#defcont    					 \ .error "WML7: Branch Macro Out Of Range."
#defcont					\#endif
#defcont				\#endif

#define     BEQR_(p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,p9__,ba__)     \#if $+11-ba__ < 128
#defcont                                 \.db $5A,p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,p9__,ba__-$-11
#defcont				\#else
#defcont					\#if ba__-$+11 < 127
#defcont                                 \.db $5A,p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,p9__,$+11-ba__
#defcont					\#else
#defcont    					 \ .error "WML7: Branch Macro Out Of Range."
#defcont					\#endif
#defcont				\#endif

#define     BEQR_(p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,p9__,p10__,ba__)     \#if $+12-ba__ < 128
#defcont                                 \.db $5A,p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,p9__,p10__,ba__-$-12
#defcont				\#else
#defcont					\#if ba__-$+12 < 127
#defcont                                 \.db $5A,p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,p9__,p10__,$+12-ba__
#defcont					\#else
#defcont    					 \ .error "WML7: Branch Macro Out Of Range."
#defcont					\#endif
#defcont				\#endif

#define     BEQR_(p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,p9__,p10__,p11__,ba__)     \#if $+13-ba__ < 128
#defcont                                 \.db $5A,p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,p9__,p10__,p11__,ba__-$-13
#defcont				\#else
#defcont					\#if ba__-$+13 < 127
#defcont                                 \.db $5A,p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,p9__,p10__,p11__,$+13-ba__
#defcont					\#else
#defcont    					 \ .error "WML7: Branch Macro Out Of Range."
#defcont					\#endif
#defcont				\#endif

#define     BEQR_(p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,p9__,p10__,p11__,p12__,ba__)     \#if $+14-ba__ < 128
#defcont                                 \.db $5A,p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,p9__,p10__,p11__,p12__,ba__-$-14
#defcont				\#else
#defcont					\#if ba__-$+14 < 127
#defcont                                 \.db $5A,p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,p9__,p10__,p11__,p12__,$+14-ba__
#defcont					\#else
#defcont    					 \ .error "WML7: Branch Macro Out Of Range."
#defcont					\#endif
#defcont				\#endif

#define     BEQR_(p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,p9__,p10__,p11__,p12__,p13__,ba__)     \#if $+15-ba__ < 128
#defcont                                 \.db $5A,p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,p9__,p10__,p11__,p12__,p13__,ba__-$-15
#defcont				\#else
#defcont					\#if ba__-$+15 < 127
#defcont                                 \.db $5A,p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,p9__,p10__,p11__,p12__,p13__,$+15-ba__
#defcont					\#else
#defcont    					 \ .error "WML7: Branch Macro Out Of Range."
#defcont					\#endif
#defcont				\#endif

#define     BEQR_(p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,p9__,p10__,p11__,p12__,p13__,p14__,ba__)     \#if $+16-ba__ < 128
#defcont                                 \.db $5A,p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,p9__,p10__,p11__,p12__,p13__,p14__,ba__-$-16
#defcont				\#else
#defcont					\#if ba__-$+16 < 127
#defcont                                 \.db $5A,p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,p9__,p10__,p11__,p12__,p13__,p14__,$+16-ba__
#defcont					\#else
#defcont    					 \ .error "WML7: Branch Macro Out Of Range."
#defcont					\#endif
#defcont				\#endif

#define     BEQR_(p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,p9__,p10__,p11__,p12__,p13__,p14__,p15__,ba__)     \#if $+17-ba__ < 128
#defcont                                 \.db $5A,p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,p9__,p10__,p11__,p12__,p13__,p14__,p15__,ba__-$-17
#defcont				\#else
#defcont					\#if ba__-$+17 < 127
#defcont                                 \.db $5A,p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,p9__,p10__,p11__,p12__,p13__,p14__,p15__,$+17-ba__
#defcont					\#else
#defcont    					 \ .error "WML7: Branch Macro Out Of Range."
#defcont					\#endif
#defcont				\#endif

#define     BEQR_(p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,p9__,p10__,p11__,p12__,p13__,p14__,p15__,p16__,ba__)     \#if $+18-ba__ < 128
#defcont                                 \.db $5A,p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,p9__,p10__,p11__,p12__,p13__,p14__,p15__,p16__,ba__-$-18
#defcont				\#else
#defcont					\#if ba__-$+18 < 127
#defcont                                 \.db $5A,p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,p9__,p10__,p11__,p12__,p13__,p14__,p15__,p16__,$+18-ba__
#defcont					\#else
#defcont    					 \ .error "WML7: Branch Macro Out Of Range."
#defcont					\#endif
#defcont				\#endif

#define     BEQR_(p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,p9__,p10__,p11__,p12__,p13__,p14__,p15__,p16__,p17__,ba__)     \#if $+19-ba__ < 128
#defcont                                 \.db $5A,p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,p9__,p10__,p11__,p12__,p13__,p14__,p15__,p16__,p17__,ba__-$-19
#defcont				\#else
#defcont					\#if ba__-$+19 < 127
#defcont                                 \.db $5A,p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,p9__,p10__,p11__,p12__,p13__,p14__,p15__,p16__,p17__,$+19-ba__
#defcont					\#else
#defcont    					 \ .error "WML7: Branch Macro Out Of Range."
#defcont					\#endif
#defcont				\#endif

#define     BEQA_(p1__,ba__)     \.db $58,p1__ \.dw ba__
#define     BEQA_(p1__,p2__,ba__)     \.db $58,p1__,p2__ \.dw ba__
#define     BEQA_(p1__,p2__,p3__,ba__)     \.db $58,p1__,p2__,p3__ \.dw ba__
#define     BEQA_(p1__,p2__,p3__,p4__,ba__)     \.db $58,p1__,p2__,p3__,p4__ \.dw ba__
#define     BEQA_(p1__,p2__,p3__,p4__,p5__,ba__)     \.db $58,p1__,p2__,p3__,p4__,p5__ \.dw ba__
#define     BEQA_(p1__,p2__,p3__,p4__,p5__,p6__,ba__)     \.db $58,p1__,p2__,p3__,p4__,p5__,p6__ \.dw ba__
#define     BEQA_(p1__,p2__,p3__,p4__,p5__,p6__,p7__,ba__)     \.db $58,p1__,p2__,p3__,p4__,p5__,p6__,p7__ \.dw ba__
#define     BEQA_(p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,ba__)     \.db $58,p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__ \.dw ba__
#define     BEQA_(p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,p9__,ba__)     \.db $58,p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,p9__ \.dw ba__
#define     BEQA_(p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,p9__,p10__,ba__)     \.db $58,p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,p9__,p10__ \.dw ba__
#define     BEQA_(p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,p9__,p10__,p11__,ba__)     \.db $58,p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,p9__,p10__,p11__ \.dw ba__
#define     BEQA_(p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,p9__,p10__,p11__,p12__,ba__)     \.db $58,p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,p9__,p10__,p11__,p12__ \.dw ba__

#define     BNER_(p1__,ba__)     \#if $+3-ba__ < 128
#defcont                                 \.db $5B,p1__,ba__-$-3
#defcont				\#else
#defcont					\#if ba__-$+3 < 127
#defcont                                 \.db $5B,p1__,$+3-ba__
#defcont					\#else
#defcont    					 \ .error "WML7: Branch Macro Out Of Range."
#defcont					\#endif
#defcont				\#endif

#define     BNER_(p1__,p2__,ba__)     \#if $+4-ba__ < 128
#defcont                                 \.db $5B,p1__,p2__,ba__-$-4
#defcont				\#else
#defcont					\#if ba__-$+4 < 127
#defcont                                 \.db $5B,p1__,p2__,$+4-ba__
#defcont					\#else
#defcont    					 \ .error "WML7: Branch Macro Out Of Range."
#defcont					\#endif
#defcont				\#endif

#define     BNER_(p1__,p2__,p3__,ba__)     \#if $+5-ba__ < 128
#defcont                                 \.db $5B,p1__,p2__,p3__,ba__-$-5
#defcont				\#else
#defcont					\#if ba__-$+5 < 127
#defcont                                 \.db $5B,p1__,p2__,p3__,$+5-ba__
#defcont					\#else
#defcont    					 \ .error "WML7: Branch Macro Out Of Range."
#defcont					\#endif
#defcont				\#endif

#define     BNER_(p1__,p2__,p3__,p4__,ba__)     \#if $+6-ba__ < 128
#defcont                                 \.db $5B,p1__,p2__,p3__,p4__,ba__-$-6
#defcont				\#else
#defcont					\#if ba__-$+6 < 127
#defcont                                 \.db $5B,p1__,p2__,p3__,p4__,$+6-ba__
#defcont					\#else
#defcont    					 \ .error "WML7: Branch Macro Out Of Range."
#defcont					\#endif
#defcont				\#endif

#define     BNER_(p1__,p2__,p3__,p4__,p5__,ba__)     \#if $+7-ba__ < 128
#defcont                                 \.db $5B,p1__,p2__,p3__,p4__,p5__,ba__-$-7
#defcont				\#else
#defcont					\#if ba__-$+7 < 127
#defcont                                 \.db $5B,p1__,p2__,p3__,p4__,p5__,$+7-ba__
#defcont					\#else
#defcont    					 \ .error "WML7: Branch Macro Out Of Range."
#defcont					\#endif
#defcont				\#endif

#define     BNER_(p1__,p2__,p3__,p4__,p5__,p6__,ba__)     \#if $+8-ba__ < 128
#defcont                                 \.db $5B,p1__,p2__,p3__,p4__,p5__,p6__,ba__-$-8
#defcont				\#else
#defcont					\#if ba__-$+8 < 127
#defcont                                 \.db $5B,p1__,p2__,p3__,p4__,p5__,p6__,$+8-ba__
#defcont					\#else
#defcont    					 \ .error "WML7: Branch Macro Out Of Range."
#defcont					\#endif
#defcont				\#endif

#define     BNER_(p1__,p2__,p3__,p4__,p5__,p6__,p7__,ba__)     \#if $+9-ba__ < 128
#defcont                                 \.db $5B,p1__,p2__,p3__,p4__,p5__,p6__,p7__,ba__-$-9
#defcont				\#else
#defcont					\#if ba__-$+9 < 127
#defcont                                 \.db $5B,p1__,p2__,p3__,p4__,p5__,p6__,p7__,$+9-ba__
#defcont					\#else
#defcont    					 \ .error "WML7: Branch Macro Out Of Range."
#defcont					\#endif
#defcont				\#endif

#define     BNER_(p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,ba__)     \#if $+10-ba__ < 128
#defcont                                 \.db $5B,p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,ba__-$-10
#defcont				\#else
#defcont					\#if ba__-$+10 < 127
#defcont                                 \.db $5B,p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,$+10-ba__
#defcont					\#else
#defcont    					 \ .error "WML7: Branch Macro Out Of Range."
#defcont					\#endif
#defcont				\#endif

#define     BNER_(p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,p9__,ba__)     \#if $+11-ba__ < 128
#defcont                                 \.db $5B,p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,p9__,ba__-$-11
#defcont				\#else
#defcont					\#if ba__-$+11 < 127
#defcont                                 \.db $5B,p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,p9__,$+11-ba__
#defcont					\#else
#defcont    					 \ .error "WML7: Branch Macro Out Of Range."
#defcont					\#endif
#defcont				\#endif

#define     BNER_(p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,p9__,p10__,ba__)     \#if $+12-ba__ < 128
#defcont                                 \.db $5B,p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,p9__,p10__,ba__-$-12
#defcont				\#else
#defcont					\#if ba__-$+12 < 127
#defcont                                 \.db $5B,p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,p9__,p10__,$+12-ba__
#defcont					\#else
#defcont    					 \ .error "WML7: Branch Macro Out Of Range."
#defcont					\#endif
#defcont				\#endif

#define     BNER_(p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,p9__,p10__,p11__,ba__)     \#if $+13-ba__ < 128
#defcont                                 \.db $5B,p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,p9__,p10__,p11__,ba__-$-13
#defcont				\#else
#defcont					\#if ba__-$+13 < 127
#defcont                                 \.db $5B,p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,p9__,p10__,p11__,$+13-ba__
#defcont					\#else
#defcont    					 \ .error "WML7: Branch Macro Out Of Range."
#defcont					\#endif
#defcont				\#endif

#define     BNER_(p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,p9__,p10__,p11__,p12__,ba__)     \#if $+14-ba__ < 128
#defcont                                 \.db $5B,p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,p9__,p10__,p11__,p12__,ba__-$-14
#defcont				\#else
#defcont					\#if ba__-$+14 < 127
#defcont                                 \.db $5B,p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,p9__,p10__,p11__,p12__,$+14-ba__
#defcont					\#else
#defcont    					 \ .error "WML7: Branch Macro Out Of Range."
#defcont					\#endif
#defcont				\#endif

#define     BNER_(p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,p9__,p10__,p11__,p12__,p13__,ba__)     \#if $+15-ba__ < 128
#defcont                                 \.db $5B,p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,p9__,p10__,p11__,p12__,p13__,ba__-$-15
#defcont				\#else
#defcont					\#if ba__-$+15 < 127
#defcont                                 \.db $5B,p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,p9__,p10__,p11__,p12__,p13__,$+15-ba__
#defcont					\#else
#defcont    					 \ .error "WML7: Branch Macro Out Of Range."
#defcont					\#endif
#defcont				\#endif

#define     BNER_(p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,p9__,p10__,p11__,p12__,p13__,p14__,ba__)     \#if $+16-ba__ < 128
#defcont                                 \.db $5B,p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,p9__,p10__,p11__,p12__,p13__,p14__,ba__-$-16
#defcont				\#else
#defcont					\#if ba__-$+16 < 127
#defcont                                 \.db $5B,p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,p9__,p10__,p11__,p12__,p13__,p14__,$+16-ba__
#defcont					\#else
#defcont    					 \ .error "WML7: Branch Macro Out Of Range."
#defcont					\#endif
#defcont				\#endif

#define     BNER_(p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,p9__,p10__,p11__,p12__,p13__,p14__,p15__,ba__)     \#if $+17-ba__ < 128
#defcont                                 \.db $5B,p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,p9__,p10__,p11__,p12__,p13__,p14__,p15__,ba__-$-17
#defcont				\#else
#defcont					\#if ba__-$+17 < 127
#defcont                                 \.db $5B,p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,p9__,p10__,p11__,p12__,p13__,p14__,p15__,$+17-ba__
#defcont					\#else
#defcont    					 \ .error "WML7: Branch Macro Out Of Range."
#defcont					\#endif
#defcont				\#endif

#define     BNER_(p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,p9__,p10__,p11__,p12__,p13__,p14__,p15__,p16__,ba__)     \#if $+18-ba__ < 128
#defcont                                 \.db $5B,p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,p9__,p10__,p11__,p12__,p13__,p14__,p15__,p16__,ba__-$-18
#defcont				\#else
#defcont					\#if ba__-$+18 < 127
#defcont                                 \.db $5B,p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,p9__,p10__,p11__,p12__,p13__,p14__,p15__,p16__,$+18-ba__
#defcont					\#else
#defcont    					 \ .error "WML7: Branch Macro Out Of Range."
#defcont					\#endif
#defcont				\#endif

#define     BEQR_(p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,p9__,p10__,p11__,p12__,p13__,p14__,p15__,p16__,p17__,ba__)     \#if $+19-ba__ < 128
#defcont                                 \.db $5B,p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,p9__,p10__,p11__,p12__,p13__,p14__,p15__,p16__,p17__,ba__-$-19
#defcont				\#else
#defcont					\#if ba__-$+19 < 127
#defcont                                 \.db $5B,p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,p9__,p10__,p11__,p12__,p13__,p14__,p15__,p16__,p17__,$+19-ba__
#defcont					\#else
#defcont    					 \ .error "WML7: Branch Macro Out Of Range."
#defcont					\#endif
#defcont				\#endif

#define     BNEA_(p1__,ba__)     \.db $59,p1__ \.dw ba__
#define     BNEA_(p1__,p2__,ba__)     \.db $59,p1__,p2__ \.dw ba__
#define     BNEA_(p1__,p2__,p3__,ba__)     \.db $59,p1__,p2__,p3__ \.dw ba__
#define     BNEA_(p1__,p2__,p3__,p4__,ba__)     \.db $59,p1__,p2__,p3__,p4__ \.dw ba__
#define     BNEA_(p1__,p2__,p3__,p4__,p5__,ba__)     \.db $59,p1__,p2__,p3__,p4__,p5__ \.dw ba__
#define     BNEA_(p1__,p2__,p3__,p4__,p5__,p6__,ba__)     \.db $59,p1__,p2__,p3__,p4__,p5__,p6__ \.dw ba__
#define     BNEA_(p1__,p2__,p3__,p4__,p5__,p6__,p7__,ba__)     \.db $59,p1__,p2__,p3__,p4__,p5__,p6__,p7__ \.dw ba__
#define     BNEA_(p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,ba__)     \.db $59,p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__ \.dw ba__
#define     BNEA_(p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,p9__,ba__)     \.db $59,p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,p9__ \.dw ba__
#define     BNEA_(p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,p9__,p10__,ba__)     \.db $59,p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,p9__,p10__ \.dw ba__
#define     BNEA_(p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,p9__,p10__,p11__,ba__)     \.db $59,p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,p9__,p10__,p11__ \.dw ba__
#define     BNEA_(p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,p9__,p10__,p11__,p12__,ba__)     \.db $59,p1__,p2__,p3__,p4__,p5__,p6__,p7__,p8__,p9__,p10__,p11__,p12__ \.dw ba__
;**********************************************************
;* Macros 5C-5F
;**********************************************************
#define	JMPD_(a)		.db $5c \.dw a

#define	SWSET_(a)		      .db $5d,a
#define	SWSET_(a,b)		      .db $5d,((a&$7F)+$80),b
#define	SWSET_(a,b,c)	      .db $5d,((a&$7F)+$80),((b&$7F)+$80),c
#define	SWSET_(a,b,c,d)	      .db $5d,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),d
#define	SWSET_(a,b,c,d,e)	      .db $5d,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),((d&$7F)+$80),e
#define	SWSET_(a,b,c,d,e,f)	.db $5d,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),((d&$7F)+$80),((e&$7F)+$80),f
#define	SWSET_(a,b,c,d,e,f,g)	.db $5d,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),((d&$7F)+$80),((e&$7F)+$80),((f&$7F)+$80),g
#define	SWSET_(a,b,c,d,e,f,g,h)	.db $5d,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),((d&$7F)+$80),((e&$7F)+$80),((f&$7F)+$80),((g&$7F)+$80),h

#define	SWCLR_(a)		      .db $5e,a
#define	SWCLR_(a,b)		      .db $5e,((a&$7F)+$80),b
#define	SWCLR_(a,b,c)	      .db $5e,((a&$7F)+$80),((b&$7F)+$80),c
#define	SWCLR_(a,b,c,d)	      .db $5e,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),d
#define	SWCLR_(a,b,c,d,e)	      .db $5e,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),((d&$7F)+$80),e
#define	SWCLR_(a,b,c,d,e,f)	.db $5e,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),((d&$7F)+$80),((e&$7F)+$80),f
#define	SWCLR_(a,b,c,d,e,f,g)	.db $5e,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),((d&$7F)+$80),((e&$7F)+$80),((f&$7F)+$80),g
#define	SWCLR_(a,b,c,d,e,f,g,h)	.db $5e,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),((d&$7F)+$80),((e&$7F)+$80),((f&$7F)+$80),((g&$7F)+$80),h

#define	JMP_(a)		.db $5f \.dw a

;**********************************************************
;* Macro 6X:
;**********************************************************
#define	SLEEPI_(a)		.db ($60+(a&$0f))

;**********************************************************
;* Macro 7X: 
;**********************************************************
;See SLEEP macro previous...

;**********************************************************
;* Macro 8X:
;**********************************************************
#define 	JMPR_(a)		.db ($80+(((a-($+1))>>8)&$0f)) \.db ((a-($+1))&$ff)

;**********************************************************
;* Macro 9X:
;**********************************************************
#define 	JSRR_(a)		.db ($90+(((a-($+1))>>8)&$0f)) \.db ((a-($+1))&$ff)

;**********************************************************
;* Macro AX:
;**********************************************************
#define 	JSRDR_(a)		.db ($a0+(((a-($+1))>>8)&$0f)) \.db ((a-($+1))&$ff)

;**********************************************************
;* Macro BX: Add NextByte to RAM LSD(command) 
;**********************************************************
#define 	ADDRAM_(ramloc,data)	.db ($b0+(ramloc&$0f)),data

;**********************************************************
;* Macro CX: Set NextByte to RAM LSD(command) 
;**********************************************************
#define 	SETRAM_(ramloc,data)	.db ($c0+ramloc),data

;**********************************************************
;* Macro DX: Play Index Sound (NextByte)Times  
;**********************************************************
#define	RSND_(snd,times)		.db $d0+(snd&0F),times

;**********************************************************
;* Macro EX,FX: Play Index Sound (NextByte)Times  
;**********************************************************
#define	SSND_(a)		\#if (a<$20)
#defcont				\	.db $e0+a
#defcont				\#else
#defcont				\	.error "Macro SSND_: Parameters must be less than $20"
#defcont				\#endif
