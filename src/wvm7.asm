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
#define	switchentry(a,b)	.db a /.dw b

sf_wml7	.equ	$80
sf_code 	.equ 	$00
sf_tilt	.equ	$40
sf_gameover	.equ	$20
sf_enabled	.equ	$10
sf_instant	.equ	$08

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
#define	BITON_(a)		\.db $10,a
#define	BITON_(a,b)		\.db $10,(a+$80),b
#define	BITON_(a,b,c)	\.db $10,(a+$80),(b+$80),c
#define	BITON_(a,b,c,d)	\.db $10,(a+$80),(b+$80),(c+$80),d

#define	BITOFF_(a)		\.db $11,a
#define	BITOFF_(a,b)	\.db $11,(a+$80),b
#define	BITOFF_(a,b,c)	\.db $11,(a+$80),(b+$80),c
#define	BITOFF_(a,b,c,d)	\.db $11,(a+$80),(b+$80),(c+$80),d

#define	BITINV_(a)		\.db $12,a
#define	BITINV_(a,b)	\.db $12,(a+$80),b
#define	BITINV_(a,b,c)	\.db $12,(a+$80),(b+$80),c
#define	BITINV_(a,b,c,d)	\.db $12,(a+$80),(b+$80),(c+$80),d

#define	BITFL_(a)		\.db $13,a
#define	BITFL_(a,b)		\.db $13,(a+$80),b
#define	BITFL_(a,b,c)	\.db $13,(a+$80),(b+$80),c
#define	BITFL_(a,b,c,d)	\.db $13,(a+$80),(b+$80),(c+$80),d
 
#define	BITONP_(a)		\.db $14,a
#define	BITONP_(a,b)	\.db $14,(a+$80),b
#define	BITONP_(a,b,c)	\.db $14,(a+$80),(b+$80),c
#define	BITONP_(a,b,c,d)	\.db $14,(a+$80),(b+$80),(c+$80),d 

#define	BITOFFP_(a)		\.db $15,a
#define	BITOFFP_(a,b)	\.db $15,(a+$80),b
#define	BITOFFP_(a,b,c)	\.db $15,(a+$80),(b+$80),c
#define	BITOFFP_(a,b,c,d)	\.db $15,(a+$80),(b+$80),(c+$80),d 

#define	BITINVP_(a)		\.db $16,a
#define	BITINVP_(a,b)	\.db $16,(a+$80),b
#define	BITINVP_(a,b,c)	\.db $16,(a+$80),(b+$80),c
#define	BITINVP_(a,b,c,d)	\.db $16,(a+$80),(b+$80),(c+$80),d 
 
#define	BITFLP_(a)		\.db $17,a
#define	BITFLP_(a,b)	\.db $17,(a+$80),b
#define	BITFLP_(a,b,c)	\.db $17,(a+$80),(b+$80),c
#define	BITFLP_(a,b,c,d)	\.db $17,(a+$80),(b+$80),(c+$80),d  

;************************
;* Lamp/Bit Effects
;************************
#define	BE18_(a)		\.db $18,a
#define	BE18_(a,b)		\.db $18,(a+$80),b
#define	BE18_(a,b,c)	\.db $18,(a+$80),(b+$80),c
#define	BE18_(a,b,c,d)	\.db $18,(a+$80),(b+$80),(c+$80),d  

#define	BE19_(a)		\.db $19,a
#define	BE19_(a,b)		\.db $19,(a+$80),b
#define	BE19_(a,b,c)	\.db $19,(a+$80),(b+$80),c
#define	BE19_(a,b,c,d)	\.db $19,(a+$80),(b+$80),(c+$80),d 

#define	BE1A_(a)		\.db $1A,a
#define	BE1A_(a,b)		\.db $1A,(a+$80),b
#define	BE1A_(a,b,c)	\.db $1A,(a+$80),(b+$80),c
#define	BE1A_(a,b,c,d)	\.db $1A,(a+$80),(b+$80),(c+$80),d 

#define	BE1B_(a)		\.db $1B,a
#define	BE1B_(a,b)		\.db $1B,(a+$80),b
#define	BE1B_(a,b,c)	\.db $1B,(a+$80),(b+$80),c
#define	BE1B_(a,b,c,d)	\.db $1B,(a+$80),(b+$80),(c+$80),d 

#define	BE1C_(a)		\.db $1C,a
#define	BE1C_(a,b)		\.db $1C,(a+$80),b
#define	BE1C_(a,b,c)	\.db $1C,(a+$80),(b+$80),c
#define	BE1C_(a,b,c,d)	\.db $1C,(a+$80),(b+$80),(c+$80),d 

#define	BE1D_(a)		\.db $1D,a
#define	BE1D_(a,b)		\.db $1D,(a+$80),b
#define	BE1D_(a,b,c)	\.db $1D,(a+$80),(b+$80),c
#define	BE1D_(a,b,c,d)	\.db $1D,(a+$80),(b+$80),(c+$80),d 

#define	BE1E_(a)		\.db $1E,a
#define	BE1E_(a,b)		\.db $1E,(a+$80),b
#define	BE1E_(a,b,c)	\.db $1E,(a+$80),(b+$80),c
#define	BE1E_(a,b,c,d)	\.db $1E,(a+$80),(b+$80),(c+$80),d 

#define	BE1F_(a)		\.db $1F,a
#define	BE1F_(a,b)		\.db $1F,(a+$80),b
#define	BE1F_(a,b,c)	\.db $1F,(a+$80),(b+$80),c
#define	BE1F_(a,b,c,d)	\.db $1F,(a+$80),(b+$80),(c+$80),d 

#define	BITON2_(a)		\.db $20,a
#define	BITON2_(a,b)	\.db $20,(a+$80),b
#define	BITON2_(a,b,c)	\.db $20,(a+$80),(b+$80),c
#define	BITON2_(a,b,c,d)	\.db $20,(a+$80),(b+$80),(c+$80),d

#define	BITOFF2_(a)		\.db $21,a
#define	BITOFF2_(a,b)	\.db $21,(a+$80),b
#define	BITOFF2_(a,b,c)	\.db $21,(a+$80),(b+$80),c
#define	BITOFF2_(a,b,c,d)	\.db $21,(a+$80),(b+$80),(c+$80),d

#define	BITINV2_(a)		\.db $22,a
#define	BITINV2_(a,b)	\.db $22,(a+$80),b
#define	BITINV2_(a,b,c)	\.db $22,(a+$80),(b+$80),c
#define	BITINV2_(a,b,c,d)	\.db $22,(a+$80),(b+$80),(c+$80),d

#define	BITFL2_(a)		\.db $23,a
#define	BITFL2_(a,b)	\.db $23,(a+$80),b
#define	BITFL2_(a,b,c)	\.db $23,(a+$80),(b+$80),c
#define	BITFL2_(a,b,c,d)	\.db $23,(a+$80),(b+$80),(c+$80),d
 
#define	BITONP2_(a)		\.db $24,a
#define	BITONP2_(a,b)	\.db $24,(a+$80),b
#define	BITONP2_(a,b,c)	\.db $24,(a+$80),(b+$80),c
#define	BITONP2_(a,b,c,d)	\.db $24,(a+$80),(b+$80),(c+$80),d 

#define	BITOFFP2_(a)	\.db $25,a
#define	BITOFFP2_(a,b)	\.db $25,(a+$80),b
#define	BITOFFP2_(a,b,c)	\.db $25,(a+$80),(b+$80),c
#define	BITOFFP2_(a,b,c,d) \.db $25,(a+$80),(b+$80),(c+$80),d 

#define	BITINVP2_(a)	\.db $26,a
#define	BITINVP2_(a,b)	\.db $26,(a+$80),b
#define	BITINVP2_(a,b,c)	\.db $26,(a+$80),(b+$80),c
#define	BITINVP2_(a,b,c,d) \.db $26,(a+$80),(b+$80),(c+$80),d 
 
#define	BITFLP2_(a)		\.db $27,a
#define	BITFLP2_(a,b)	\.db $27,(a+$80),b
#define	BITFLP2_(a,b,c)	\.db $27,(a+$80),(b+$80),c
#define	BITFLP2_(a,b,c,d)	\.db $27,(a+$80),(b+$80),(c+$80),d 

#define	BE28_(a)		\.db $28,a
#define	BE28_(a,b)		\.db $28,(a+$80),b
#define	BE28_(a,b,c)	\.db $28,(a+$80),(b+$80),c
#define	BE28_(a,b,c,d)	\.db $28,(a+$80),(b+$80),(c+$80),d  

#define	BE29_(a)		\.db $29,a
#define	BE29_(a,b)		\.db $29,(a+$80),b
#define	BE29_(a,b,c)	\.db $29,(a+$80),(b+$80),c
#define	BE29_(a,b,c,d)	\.db $29,(a+$80),(b+$80),(c+$80),d 

#define	BE2A_(a)		\.db $2A,a
#define	BE2A_(a,b)		\.db $2A,(a+$80),b
#define	BE2A_(a,b,c)	\.db $2A,(a+$80),(b+$80),c
#define	BE2A_(a,b,c,d)	\.db $2A,(a+$80),(b+$80),(c+$80),d 

#define	BE2B_(a)		\.db $2B,a
#define	BE2B_(a,b)		\.db $2B,(a+$80),b
#define	BE2B_(a,b,c)	\.db $2B,(a+$80),(b+$80),c
#define	BE2B_(a,b,c,d)	\.db $2B,(a+$80),(b+$80),(c+$80),d 

#define	BE2C_(a)		\.db $2C,a
#define	BE2C_(a,b)		\.db $2C,(a+$80),b
#define	BE2C_(a,b,c)	\.db $2C,(a+$80),(b+$80),c
#define	BE2C_(a,b,c,d)	\.db $2C,(a+$80),(b+$80),(c+$80),d 

#define	BE2D_(a)		\.db $2D,a
#define	BE2D_(a,b)		\.db $2D,(a+$80),b
#define	BE2D_(a,b,c)	\.db $2D,(a+$80),(b+$80),c
#define	BE2D_(a,b,c,d)	\.db $2D,(a+$80),(b+$80),(c+$80),d 

#define	BE2E_(a)		\.db $2E,a
#define	BE2E_(a,b)		\.db $2E,(a+$80),b
#define	BE2E_(a,b,c)	\.db $2E,(a+$80),(b+$80),c
#define	BE2E_(a,b,c,d)	\.db $2E,(a+$80),(b+$80),(c+$80),d 

#define	BE2F_(a)		\.db $2F,a
#define	BE2F_(a,b)		\.db $2F,(a+$80),b
#define	BE2F_(a,b,c)	\.db $2F,(a+$80),(b+$80),c
#define	BE2F_(a,b,c,d)	\.db $2F,(a+$80),(b+$80),(c+$80),d 

;********************************************************
;* Solenoid Macro Definition: We will pre-define this for
;*                            up to six solenoids even
;*                            tho up to 16 are actually
;*                            allowed.
;********************************************************
#define	SOL_(a)		\.db $31,a
#define	SOL_(a,b)		\.db $32,a,b
#define 	SOL_(a,b,c)		\.db $33,a,b,c
#define	SOL_(a,b,c,d)	\.db $34,a,b,c,d
#define	SOL_(a,b,c,d,e)	\.db $35,a,b,c,d,e
#define	SOL_(a,b,c,d,e,f)	\.db $36,a,b,c,d,e,f

;********************************************************
;* Macros 40-43: Static Length, easy
;********************************************************
#define	PTSSND_(a,b)	\.db $40,a,b
#define	PTSCHIME_(a)	\.db $41,a
#define	POINTS_(a)		\.db $44,a
#define	PTSDIG_(a)		\.db $43,a

;********************************************************
;* Macros 44-4F: Define temporary execution of CPU code.
;*               The length of bytes to execute is in 
;*               the lower nibble and must be between
;*               4-f. Therefore, number is bytes to 
;*               execute must be between 2 and 13.
;********************************************************
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


;**********************************************************
;* Macros 5C-5F
;**********************************************************
#define	JMPD_(a)		.db $5c \.dw a

#define	SWSET_(a)		.db $5d,a
#define	SWSET_(a,b)		.db $5d,a,b
#define	SWSET_(a,b,c)	.db $5d,a,b,c
#define	SWSET_(a,b,c,d)	.db $5d,a,b,c,d

#define	SWCLR_(a)		.db $5e,a
#define	SWCLR_(a,b)		.db $5e,a,b
#define	SWCLR_(a,b,c)	.db $5e,a,b,c
#define	SWCLR_(a,b,c,d)	.db $5e,a,b,c,d

#define	JMP_(a)		.db $5f \.dw a

;**********************************************************
;* Macro 6X:
;**********************************************************
#define	SLEEPI_(a)		.db ($60+a)

;**********************************************************
;* Macro 7X: 
;**********************************************************
;See SLEEP macro previous...

;**********************************************************
;* Macro 8X:
;**********************************************************
#define 	JMPR_(a)		.db ($80+((a-$)>>8)) \.dw ((a-$)&$ff)

;**********************************************************
;* Macro 9X:
;**********************************************************
#define 	JSRR_(a)		.db ($90+((a-$)>>8)) \.dw ((a-$)&$ff)

;**********************************************************
;* Macro AX:
;**********************************************************
#define 	JSRDR_(a)		.db ($a0+((a-$)>>8)) \.dw ((a-$)&$ff)

;**********************************************************
;* Macro BX: Add NextByte to RAM LSD(command) 
;**********************************************************
#define 	ADDRAM_(ramloc,data)	.db ($b0+ramloc),data

;**********************************************************
;* Macro CX: Set NextByte to RAM LSD(command) 
;**********************************************************
#define 	SETRAM_(ramloc,data)	.db ($c0+ramloc),data

;**********************************************************
;* Macro DX: Play Index Sound (NextByte)Times  
;**********************************************************
#define	RSND_(snd,times)		.db $d0+snd,times

;**********************************************************
;* Macro EX,FX: Play Index Sound (NextByte)Times  
;**********************************************************
#define	SND_(a)			.db $e0+a
