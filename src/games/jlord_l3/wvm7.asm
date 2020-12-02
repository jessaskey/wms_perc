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
;* Version 	Date		Notes
;* 0.90	04/29/2006	Converted Lamp Range Macros into meaningful mnemonics
;*
;*****************************************************************************

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
;* Now define some standard RAM locations etc...
;********************************************************
rega	.equ	$00
regb	.equ	$01

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
;* Test for our current execution mode, CODE or WML7
;* If we think the programmer has their code wrong, 
;* then throw an error.
;********************************************************
;_MODECPU_         .equ  $00
;_MODEWML_         .equ  $80
;_CURRENTMODE_     .equ  _MODECPU_
;
;#define     _SETMODECPU_      \_CURRENTMODE_     .set  _MODECPU_
;#define     _SETMODEWML_      \_CURRENTMODE_     .set  _MODEWML_
;
;#define     _CHECKWML_        \#if _CURRENTMODE_ != _MODEWML_
;#defcont                      \     .error "WML7: Execution mode does not expect WML codes now, are you sure your code is structured properly?"
;#defcont                      \#endif
;
;#define     _CHECKCPU_        \#if _CURRENTMODE_ != _MODECPU_
;#defcont                      \     .error "WML7: Execution mode does not expect CPU codes now, are you sure your code is structured properly?"
;#defcont                      \#endif
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
#define	BITX_(x,a)		      \.db x,a
#define	BITX_(x,a,b)		\.db x,((a&$7F)+$80),b
#define	BITX_(x,a,b,c)	      \.db x,((a&$7F)+$80),((b&$7F)+$80),c
#define	BITX_(x,a,b,c,d)	      \.db x,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),d
#define	BITX_(x,a,b,c,d,e)	\.db x,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),((d&$7F)+$80),e
#define	BITX_(x,a,b,c,d,e,f)    \.db x,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),((d&$7F)+$80),((e&$7F)+$80),f
#define	BITX_(x,a,b,c,d,e,f,g)  \.db x,((a&$7F)+$80),((b&$7F)+$80),((c&$7F)+$80),((d&$7F)+$80),((e&$7F)+$80),((f&$7F)+$80),g

;*****************************************************************
;* Macros 1X_
;*****************************************************************
#define	BITON_(a)		      \BITX_($10,a)
#define	BITON_(a,b)		      \BITX_($10,a,b)
#define	BITON_(a,b,c)	      \BITX_($10,a,b,c)
#define	BITON_(a,b,c,d)	      \BITX_($10,a,b,c,d)
#define	BITON_(a,b,c,d,e)	      \BITX_($10,a,b,c,d,e)
#define	BITON_(a,b,c,d,e,f)     \BITX_($10,a,b,c,d,e,f)
#define	BITON_(a,b,c,d,e,f,g)   \BITX_($10,a,b,c,d,e,f,g)

#define	BITOFF_(a)		      \BITX_($11,a)            
#define	BITOFF_(a,b)		\BITX_($11,a,b)          
#define	BITOFF_(a,b,c)	      \BITX_($11,a,b,c)        
#define	BITOFF_(a,b,c,d)	      \BITX_($11,a,b,c,d)      
#define	BITOFF_(a,b,c,d,e)	\BITX_($11,a,b,c,d,e)    
#define	BITOFF_(a,b,c,d,e,f)    \BITX_($11,a,b,c,d,e,f)  
#define	BITOFF_(a,b,c,d,e,f,g)  \BITX_($11,a,b,c,d,e,f,g)
                                    
#define	BITINV_(a)		      \BITX_($12,a)            
#define	BITINV_(a,b)		\BITX_($12,a,b)          
#define	BITINV_(a,b,c)	      \BITX_($12,a,b,c)        
#define	BITINV_(a,b,c,d)	      \BITX_($12,a,b,c,d)      
#define	BITINV_(a,b,c,d,e)	\BITX_($12,a,b,c,d,e)    
#define	BITINV_(a,b,c,d,e,f)    \BITX_($12,a,b,c,d,e,f)  
#define	BITINV_(a,b,c,d,e,f,g)  \BITX_($12,a,b,c,d,e,f,g)

#define	BITFL_(a)		      \BITX_($13,a)            
#define	BITFL_(a,b)			\BITX_($13,a,b)          
#define	BITFL_(a,b,c)	      \BITX_($13,a,b,c)        
#define	BITFL_(a,b,c,d)	      \BITX_($13,a,b,c,d)      
#define	BITFL_(a,b,c,d,e)		\BITX_($13,a,b,c,d,e)    
#define	BITFL_(a,b,c,d,e,f)    	\BITX_($13,a,b,c,d,e,f)  
#define	BITFL_(a,b,c,d,e,f,g)  	\BITX_($13,a,b,c,d,e,f,g)
 
#define	BITONP_(a)		      \BITX_($14,a)            
#define	BITONP_(a,b)		\BITX_($14,a,b)          
#define	BITONP_(a,b,c)	      \BITX_($14,a,b,c)        
#define	BITONP_(a,b,c,d)	      \BITX_($14,a,b,c,d)      
#define	BITONP_(a,b,c,d,e)	\BITX_($14,a,b,c,d,e)    
#define	BITONP_(a,b,c,d,e,f)    \BITX_($14,a,b,c,d,e,f)  
#define	BITONP_(a,b,c,d,e,f,g)  \BITX_($14,a,b,c,d,e,f,g)

#define	BITOFFP_(a)		      \BITX_($15,a)            
#define	BITOFFP_(a,b)		\BITX_($15,a,b)          
#define	BITOFFP_(a,b,c)	      \BITX_($15,a,b,c)        
#define	BITOFFP_(a,b,c,d)	      \BITX_($15,a,b,c,d)      
#define	BITOFFP_(a,b,c,d,e)	\BITX_($15,a,b,c,d,e)    
#define	BITOFFP_(a,b,c,d,e,f)   \BITX_($15,a,b,c,d,e,f)  
#define	BITOFFP_(a,b,c,d,e,f,g) \BITX_($15,a,b,c,d,e,f,g)

#define	BITINVP_(a)		      \BITX_($16,a)            
#define	BITINVP_(a,b)		\BITX_($16,a,b)          
#define	BITINVP_(a,b,c)	      \BITX_($16,a,b,c)        
#define	BITINVP_(a,b,c,d)	      \BITX_($16,a,b,c,d)      
#define	BITINVP_(a,b,c,d,e)	\BITX_($16,a,b,c,d,e)    
#define	BITINVP_(a,b,c,d,e,f)   \BITX_($16,a,b,c,d,e,f)  
#define	BITINVP_(a,b,c,d,e,f,g) \BITX_($16,a,b,c,d,e,f,g)

#define	BITFLP_(a)		      \BITX_($17,a)            
#define	BITFLP_(a,b)		\BITX_($17,a,b)          
#define	BITFLP_(a,b,c)	      \BITX_($17,a,b,c)        
#define	BITFLP_(a,b,c,d)	      \BITX_($17,a,b,c,d)      
#define	BITFLP_(a,b,c,d,e)	\BITX_($17,a,b,c,d,e)    
#define	BITFLP_(a,b,c,d,e,f)   	\BITX_($17,a,b,c,d,e,f)  
#define	BITFLP_(a,b,c,d,e,f,g) 	\BITX_($17,a,b,c,d,e,f,g)

;************************
;* Lamp/Bit Effects
;************************
#define	RSET0_(a)		      \BITX_($18,a)            
#define	RSET0_(a,b)			\BITX_($18,a,b)          
#define	RSET0_(a,b,c)	      \BITX_($18,a,b,c)        
#define	RSET0_(a,b,c,d)	      \BITX_($18,a,b,c,d)      
#define	RSET0_(a,b,c,d,e)		\BITX_($18,a,b,c,d,e)    
#define	RSET0_(a,b,c,d,e,f)   	\BITX_($18,a,b,c,d,e,f)  
#define	RSET0_(a,b,c,d,e,f,g) 	\BITX_($18,a,b,c,d,e,f,g)

#define	RCLR0_(a)		      \BITX_($19,a)            
#define	RCLR0_(a,b)			\BITX_($19,a,b)          
#define	RCLR0_(a,b,c)	      \BITX_($19,a,b,c)        
#define	RCLR0_(a,b,c,d)	      \BITX_($19,a,b,c,d)      
#define	RCLR0_(a,b,c,d,e)		\BITX_($19,a,b,c,d,e)    
#define	RCLR0_(a,b,c,d,e,f)   	\BITX_($19,a,b,c,d,e,f)  
#define	RCLR0_(a,b,c,d,e,f,g) 	\BITX_($19,a,b,c,d,e,f,g)

#define	RSET1R0_(a)		      \BITX_($1A,a)            
#define	RSET1R0_(a,b)		\BITX_($1A,a,b)          
#define	RSET1R0_(a,b,c)	      \BITX_($1A,a,b,c)        
#define	RSET1R0_(a,b,c,d)	      \BITX_($1A,a,b,c,d)      
#define	RSET1R0_(a,b,c,d,e)	\BITX_($1A,a,b,c,d,e)    
#define	RSET1R0_(a,b,c,d,e,f)   \BITX_($1A,a,b,c,d,e,f)  
#define	RSET1R0_(a,b,c,d,e,f,g) \BITX_($1A,a,b,c,d,e,f,g)

#define	RSET1RC0_(a)		\BITX_($1B,a)            
#define	RSET1RC0_(a,b)		\BITX_($1B,a,b)          
#define	RSET1RC0_(a,b,c)	      \BITX_($1B,a,b,c)        
#define	RSET1RC0_(a,b,c,d)	\BITX_($1B,a,b,c,d)      
#define	RSET1RC0_(a,b,c,d,e)	\BITX_($1B,a,b,c,d,e)    
#define	RSET1RC0_(a,b,c,d,e,f)  \BITX_($1B,a,b,c,d,e,f)  
#define	RSET1RC0_(a,b,c,d,e,f,g) \BITX_($1B,a,b,c,d,e,f,g)

#define	RCLR1L0_(a)		      \BITX_($1C,a)            
#define	RCLR1L0_(a,b)		\BITX_($1C,a,b)          
#define	RCLR1L0_(a,b,c)	      \BITX_($1C,a,b,c)        
#define	RCLR1L0_(a,b,c,d)	      \BITX_($1C,a,b,c,d)      
#define	RCLR1L0_(a,b,c,d,e)	\BITX_($1C,a,b,c,d,e)    
#define	RCLR1L0_(a,b,c,d,e,f)   \BITX_($1C,a,b,c,d,e,f)  
#define	RCLR1L0_(a,b,c,d,e,f,g) \BITX_($1C,a,b,c,d,e,f,g)

#define	RROL0_(a)		      \BITX_($1D,a)            
#define	RROL0_(a,b)			\BITX_($1D,a,b)          
#define	RROL0_(a,b,c)	      \BITX_($1D,a,b,c)        
#define	RROL0_(a,b,c,d)	      \BITX_($1D,a,b,c,d)      
#define	RROL0_(a,b,c,d,e)		\BITX_($1D,a,b,c,d,e)    
#define	RROL0_(a,b,c,d,e,f)   	\BITX_($1D,a,b,c,d,e,f)  
#define	RROL0_(a,b,c,d,e,f,g) 	\BITX_($1D,a,b,c,d,e,f,g)

#define	RROR0_(a)		      \BITX_($1E,a)            
#define	RROR0_(a,b)			\BITX_($1E,a,b)          
#define	RROR0_(a,b,c)	      \BITX_($1E,a,b,c)        
#define	RROR0_(a,b,c,d)	      \BITX_($1E,a,b,c,d)      
#define	RROR0_(a,b,c,d,e)		\BITX_($1E,a,b,c,d,e)    
#define	RROR0_(a,b,c,d,e,f)   	\BITX_($1E,a,b,c,d,e,f)  
#define	RROR0_(a,b,c,d,e,f,g) 	\BITX_($1E,a,b,c,d,e,f,g)

#define	RINV0_(a)		      \BITX_($1F,a)            
#define	RINV0_(a,b)			\BITX_($1F,a,b)          
#define	RINV0_(a,b,c)	      \BITX_($1F,a,b,c)        
#define	RINV0_(a,b,c,d)	      \BITX_($1F,a,b,c,d)      
#define	RINV0_(a,b,c,d,e)		\BITX_($1F,a,b,c,d,e)    
#define	RINV0_(a,b,c,d,e,f)   	\BITX_($1F,a,b,c,d,e,f)  
#define	RINV0_(a,b,c,d,e,f,g) 	\BITX_($1F,a,b,c,d,e,f,g)

;*****************************************************************
;* Macros 2X_
;*****************************************************************

#define	BITON2_(a)		      	\BITX_($20,a)
#define	BITON2_(a,b)			\BITX_($20,a,b)
#define	BITON2_(a,b,c)	      	\BITX_($20,a,b,c)
#define	BITON2_(a,b,c,d)	      	\BITX_($20,a,b,c,d)
#define	BITON2_(a,b,c,d,e)		\BITX_($20,a,b,c,d,e)
#define	BITON2_(a,b,c,d,e,f)    	\BITX_($20,a,b,c,d,e,f)
#define	BITON2_(a,b,c,d,e,f,g)  	\BITX_($20,a,b,c,d,e,f,g)

#define	BITOFF2_(a)		      	\BITX_($21,a)            
#define	BITOFF2_(a,b)			\BITX_($21,a,b)          
#define	BITOFF2_(a,b,c)	      	\BITX_($21,a,b,c)        
#define	BITOFF2_(a,b,c,d)	      	\BITX_($21,a,b,c,d)      
#define	BITOFF2_(a,b,c,d,e)		\BITX_($21,a,b,c,d,e)    
#define	BITOFF2_(a,b,c,d,e,f)   	\BITX_($21,a,b,c,d,e,f)  
#define	BITOFF2_(a,b,c,d,e,f,g) 	\BITX_($21,a,b,c,d,e,f,g)
                                    
#define	BITINV2_(a)		      	\BITX_($22,a)            
#define	BITINV2_(a,b)			\BITX_($22,a,b)          
#define	BITINV2_(a,b,c)	      	\BITX_($22,a,b,c)        
#define	BITINV2_(a,b,c,d)	      	\BITX_($22,a,b,c,d)      
#define	BITINV2_(a,b,c,d,e)		\BITX_($22,a,b,c,d,e)    
#define	BITINV2_(a,b,c,d,e,f)   	\BITX_($22,a,b,c,d,e,f)  
#define	BITINV2_(a,b,c,d,e,f,g) 	\BITX_($22,a,b,c,d,e,f,g)

#define	BITFL2_(a)		      	\BITX_($23,a)            
#define	BITFL2_(a,b)			\BITX_($23,a,b)          
#define	BITFL2_(a,b,c)	      	\BITX_($23,a,b,c)        
#define	BITFL2_(a,b,c,d)	      	\BITX_($23,a,b,c,d)      
#define	BITFL2_(a,b,c,d,e)		\BITX_($23,a,b,c,d,e)    
#define	BITFL2_(a,b,c,d,e,f)    	\BITX_($23,a,b,c,d,e,f)  
#define	BITFL2_(a,b,c,d,e,f,g)  	\BITX_($23,a,b,c,d,e,f,g)
 
#define	BITONP2_(a)		      	\BITX_($24,a)            
#define	BITONP2_(a,b)			\BITX_($24,a,b)          
#define	BITONP2_(a,b,c)	      	\BITX_($24,a,b,c)        
#define	BITONP2_(a,b,c,d)	      	\BITX_($24,a,b,c,d)      
#define	BITONP2_(a,b,c,d,e)		\BITX_($24,a,b,c,d,e)    
#define	BITONP2_(a,b,c,d,e,f)   	\BITX_($24,a,b,c,d,e,f)  
#define	BITONP2_(a,b,c,d,e,f,g) 	\BITX_($24,a,b,c,d,e,f,g)

#define	BITOFFP2_(a)			\BITX_($25,a)            
#define	BITOFFP2_(a,b)			\BITX_($25,a,b)          
#define	BITOFFP2_(a,b,c)	      	\BITX_($25,a,b,c)        
#define	BITOFFP2_(a,b,c,d)		\BITX_($25,a,b,c,d)      
#define	BITOFFP2_(a,b,c,d,e)		\BITX_($25,a,b,c,d,e)    
#define	BITOFFP2_(a,b,c,d,e,f)  	\BITX_($25,a,b,c,d,e,f)  
#define	BITOFFP2_(a,b,c,d,e,f,g)	\BITX_($25,a,b,c,d,e,f,g)

#define	BITINVP2_(a)			\BITX_($26,a)            
#define	BITINVP2_(a,b)			\BITX_($26,a,b)          
#define	BITINVP2_(a,b,c)	      	\BITX_($26,a,b,c)        
#define	BITINVP2_(a,b,c,d)		\BITX_($26,a,b,c,d)      
#define	BITINVP2_(a,b,c,d,e)		\BITX_($26,a,b,c,d,e)    
#define	BITINVP2_(a,b,c,d,e,f)   	\BITX_($26,a,b,c,d,e,f)  
#define	BITINVP2_(a,b,c,d,e,f,g) 	\BITX_($26,a,b,c,d,e,f,g)

#define	BITFLP2_(a)		      	\BITX_($27,a)            
#define	BITFLP2_(a,b)			\BITX_($27,a,b)          
#define	BITFLP2_(a,b,c)	      	\BITX_($27,a,b,c)        
#define	BITFLP2_(a,b,c,d)	      	\BITX_($27,a,b,c,d)      
#define	BITFLP2_(a,b,c,d,e)		\BITX_($27,a,b,c,d,e)    
#define	BITFLP2_(a,b,c,d,e,f)   	\BITX_($27,a,b,c,d,e,f)  
#define	BITFLP2_(a,b,c,d,e,f,g) 	\BITX_($27,a,b,c,d,e,f,g)

;************************
;* Lamp/Bit Effects
;************************
#define	RSET1_(a)		      \BITX_($28,a)            
#define	RSET1_(a,b)			\BITX_($28,a,b)          
#define	RSET1_(a,b,c)	      \BITX_($28,a,b,c)        
#define	RSET1_(a,b,c,d)	      \BITX_($28,a,b,c,d)      
#define	RSET1_(a,b,c,d,e)		\BITX_($28,a,b,c,d,e)    
#define	RSET1_(a,b,c,d,e,f)   	\BITX_($28,a,b,c,d,e,f)  
#define	RSET1_(a,b,c,d,e,f,g) 	\BITX_($28,a,b,c,d,e,f,g)

#define	RCLR1_(a)		      \BITX_($29,a)            
#define	RCLR1_(a,b)			\BITX_($29,a,b)          
#define	RCLR1_(a,b,c)	      \BITX_($29,a,b,c)        
#define	RCLR1_(a,b,c,d)	      \BITX_($29,a,b,c,d)      
#define	RCLR1_(a,b,c,d,e)		\BITX_($29,a,b,c,d,e)    
#define	RCLR1_(a,b,c,d,e,f)   	\BITX_($29,a,b,c,d,e,f)  
#define	RCLR1_(a,b,c,d,e,f,g) 	\BITX_($29,a,b,c,d,e,f,g)

#define	RSET1R1_(a)		      \BITX_($2A,a)            
#define	RSET1R1_(a,b)		\BITX_($2A,a,b)          
#define	RSET1R1_(a,b,c)	      \BITX_($2A,a,b,c)        
#define	RSET1R1_(a,b,c,d)	      \BITX_($2A,a,b,c,d)      
#define	RSET1R1_(a,b,c,d,e)	\BITX_($2A,a,b,c,d,e)    
#define	RSET1R1_(a,b,c,d,e,f)   \BITX_($2A,a,b,c,d,e,f)  
#define	RSET1R1_(a,b,c,d,e,f,g) \BITX_($2A,a,b,c,d,e,f,g)

#define	RSET1RC1_(a)		\BITX_($2B,a)            
#define	RSET1RC1_(a,b)		\BITX_($2B,a,b)          
#define	RSET1RC1_(a,b,c)	      \BITX_($2B,a,b,c)        
#define	RSET1RC1_(a,b,c,d)	\BITX_($2B,a,b,c,d)      
#define	RSET1RC1_(a,b,c,d,e)	\BITX_($2B,a,b,c,d,e)    
#define	RSET1RC1_(a,b,c,d,e,f)  \BITX_($2B,a,b,c,d,e,f)  
#define	RSET1RC1_(a,b,c,d,e,f,g) \BITX_($2B,a,b,c,d,e,f,g)

#define	RCLR1L1_(a)		      \BITX_($2C,a)            
#define	RCLR1L1_(a,b)		\BITX_($2C,a,b)          
#define	RCLR1L1_(a,b,c)	      \BITX_($2C,a,b,c)        
#define	RCLR1L1_(a,b,c,d)	      \BITX_($2C,a,b,c,d)      
#define	RCLR1L1_(a,b,c,d,e)	\BITX_($2C,a,b,c,d,e)    
#define	RCLR1L1_(a,b,c,d,e,f)   \BITX_($2C,a,b,c,d,e,f)  
#define	RCLR1L1_(a,b,c,d,e,f,g) \BITX_($2C,a,b,c,d,e,f,g)

#define	RROL1_(a)		      \BITX_($2D,a)            
#define	RROL1_(a,b)			\BITX_($2D,a,b)          
#define	RROL1_(a,b,c)	      \BITX_($2D,a,b,c)        
#define	RROL1_(a,b,c,d)	      \BITX_($2D,a,b,c,d)      
#define	RROL1_(a,b,c,d,e)		\BITX_($2D,a,b,c,d,e)    
#define	RROL1_(a,b,c,d,e,f)   	\BITX_($2D,a,b,c,d,e,f)  
#define	RROL1_(a,b,c,d,e,f,g) 	\BITX_($2D,a,b,c,d,e,f,g)

#define	RROR1_(a)		      \BITX_($2E,a)            
#define	RROR1_(a,b)			\BITX_($2E,a,b)          
#define	RROR1_(a,b,c)	      \BITX_($2E,a,b,c)        
#define	RROR1_(a,b,c,d)	      \BITX_($2E,a,b,c,d)      
#define	RROR1_(a,b,c,d,e)		\BITX_($2E,a,b,c,d,e)    
#define	RROR1_(a,b,c,d,e,f)   	\BITX_($2E,a,b,c,d,e,f)  
#define	RROR1_(a,b,c,d,e,f,g) 	\BITX_($2E,a,b,c,d,e,f,g)

#define	RINV1_(a)		      \BITX_($2F,a)            
#define	RINV1_(a,b)			\BITX_($2F,a,b)          
#define	RINV1_(a,b,c)	      \BITX_($2F,a,b,c)        
#define	RINV1_(a,b,c,d)	      \BITX_($2F,a,b,c,d)      
#define	RINV1_(a,b,c,d,e)		\BITX_($2F,a,b,c,d,e)    
#define	RINV1_(a,b,c,d,e,f)   	\BITX_($2F,a,b,c,d,e,f)  
#define	RINV1_(a,b,c,d,e,f,g) 	\BITX_($2F,a,b,c,d,e,f,g)

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
#IFDEF HYPERBALL

SOLENOID_ON_1_CYCLES       .equ  $10
SOLENOID_ON_2_CYCLES       .equ  $20
SOLENOID_ON_3_CYCLES       .equ  $30
SOLENOID_ON_4_CYCLES       .equ  $40
SOLENOID_ON_5_CYCLES       .equ  $50
SOLENOID_ON_6_CYCLES       .equ  $60
SOLENOID_ON_LATCH          .equ  $F0
SOLENOID_OFF               .equ  $00

#ELSE

SOLENOID_ON_1_CYCLES       .equ  $20
SOLENOID_ON_2_CYCLES       .equ  $40
SOLENOID_ON_3_CYCLES       .equ  $60
SOLENOID_ON_4_CYCLES       .equ  $80
SOLENOID_ON_5_CYCLES       .equ  $A0
SOLENOID_ON_6_CYCLES       .equ  $C0
SOLENOID_ON_LATCH          .equ  $E0
SOLENOID_OFF               .equ  $00

#ENDIF

;********************************************************
;* Macros 40-43: Static Length, easy
;********************************************************
#define	PTSND_(snd,count,unit)	\.db $40,snd      \ ADDPOINTS_(count,unit)

#define	PTCHIME_(count,unit)	\.db $41    \ ADDPOINTS_(count,unit)

#define	POINTS_(count,unit)	\.db $42    \ ADDPOINTS_(count,unit)

#define	PTSDIG_(count,unit)	\.db $43    \ ADDPOINTS_(count,unit)

#define     ADDPOINTS_(count,unit)  \#if ((unit < 10) & (count <= 32))
#defcont				      \	.error "Point unit must be multples of 10 and count must be less than 33"
#defcont				      \#else
#defcont					      \#if (unit == 10)
#defcont					      \	.db (((count)<<3)&$F8)+1
#defcont					      \#else 
#defcont					      	\#if (unit == 100)
#defcont						      \	.db (((count)<<3)&$F8)+2
#defcont						      \#else 
#defcont							      \#if (unit == 1000)
#defcont							      \	.db (((count)<<3)&$F8)+3
#defcont							      \#else 
#defcont								      \#if (unit == 10000)
#defcont								      \	.db (((count)<<3)&$F8)+4
#defcont								      \#else 
#defcont									      \#if (unit == 100000)
#defcont									      \	.db (((count)<<3)&$F8)+5
#defcont									      \#else 
#defcont									      \	.error "Macros only support points under 1,000,000 points"
#defcont									      \#endif
#defcont								      \#endif
#defcont							      \#endif
#defcont						      \#endif
#defcont					      \#endif
#defcont				      \#endif



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
#defcont                            \.error "EXEEND_ did not have a starting EXE_ code"
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

;*******************************************************************
;* Branch Macros: 58-5B
;*******************************************************************
#define     IFLOC_(type,vars)    \ .push  *, vars, type        

;*******************************************************************
;* Begin: The start marker for logical loops, must terminate with  *
;*        an 'XXEND_' statement.                                    *
;******************************************************************* 
#define     BEGIN_	      IFLOC_(FLAG_WML_BEGIN,0)

;*******************************************************************
;* Logic End: This is the end macro for the 'begin' statement. It  *
;*            pulls the pc location of the beginning of the loop   *
;*            and verifies that the 'type' is correct.             *
;*******************************************************************
#define 	LOGIC_LOOPEND_(vars)	\ .pop wml1_, wml2_, wml3_
#defcont						\wml2_ .set vars
#defcont						\wml4_ .set *
#defcont						\#if (wml1_ & FLAG_WML_BEGIN)
#defcont							\#if ((wml4_-wml3_) <= 127)
#defcont								\ .org wml4_-1
#defcont								\ .db wml3_-wml4_
#defcont								\ .org wml4_
#defcont							\#else
#defcont								\ .error "Loop Branch out of Range."
#defcont							\#endif
#defcont						\#else
#defcont							\ .error "Inappropriate End for BEGIN Loop."
#defcont						\#endif

;*******************************************************************
;* Basic Loop
;*******************************************************************
#define	LOOP_		\ .pop wml1_, wml2_, wml3_ \ JMPR_(wml3_)

;*******************************************************************
;* Conditional Looping
;*******************************************************************
#define	EQEND_(z)						BNER_(z,*+3) \ LOGIC_LOOPEND_(1)		
#define	EQEND_(z,y)						BNER_(z,y,*+3) \ LOGIC_LOOPEND_(2)
#define	EQEND_(z,y,x)					BNER_(z,y,x,*+3) \ LOGIC_LOOPEND_(3)
#define	EQEND_(z,y,x,w)					BNER_(z,y,x,w,*+3) \ LOGIC_LOOPEND_(4)
#define	EQEND_(z,y,x,w,v)					BNER_(z,y,x,w,v,*+3) \ LOGIC_LOOPEND_(5)
#define     EQEND_(z,y,x,w,v,u)				BNER_(z,y,x,w,v,u,*+3) \ LOGIC_LOOPEND_(6)
#define     EQEND_(z,y,x,w,v,u,t)			     	BNER_(z,y,x,w,v,u,t,*+3) \ LOGIC_LOOPEND_(7)
#define     EQEND_(z,y,x,w,v,u,t,s)     			BNER_(z,y,x,w,v,u,t,s,*+3) \ LOGIC_LOOPEND_(8)
#define     EQEND_(z,y,x,w,v,u,t,s,r)     		BNER_(z,y,x,w,v,u,t,s,r,*+3) \ LOGIC_LOOPEND_(9)
#define     EQEND_(z,y,x,w,v,u,t,s,r,q)     		BNER_(z,y,x,w,v,u,t,s,r,q,*+3) \ LOGIC_LOOPEND_(10)
#define     EQEND_(z,y,x,w,v,u,t,s,r,q,p)     		BNER_(z,y,x,w,v,u,t,s,r,q,p,*+3) \ LOGIC_LOOPEND_(11)
#define     EQEND_(z,y,x,w,v,u,t,s,r,q,p,o)    		BNER_(z,y,x,w,v,u,t,s,r,q,p,o,*+3) \ LOGIC_LOOPEND_(12)
#define     EQEND_(z,y,x,w,v,u,t,s,r,q,p,o,n)     	BNER_(z,y,x,w,v,u,t,s,r,q,p,o,n,*+3) \ LOGIC_LOOPEND_(13)
#define     EQEND_(z,y,x,w,v,u,t,s,r,q,p,o,n,m)     	BNER_(z,y,x,w,v,u,t,s,r,q,p,o,n,m,*+3) \ LOGIC_LOOPEND_(14)
#define     EQEND_(z,y,x,w,v,u,t,s,r,q,p,o,n,m,l)     BNER_(z,y,x,w,v,u,t,s,r,q,p,o,n,m,l,*+3) \ LOGIC_LOOPEND_(15)

#define	NEEND_(z)						BEQR_(z,*+3) \ LOGIC_LOOPEND_(1)		
#define	NEEND_(z,y)						BEQR_(z,y,*+3) \ LOGIC_LOOPEND_(2)
#define	NEEND_(z,y,x)					BEQR_(z,y,x,*+3) \ LOGIC_LOOPEND_(3)
#define	NEEND_(z,y,x,w)					BEQR_(z,y,x,w,*+3) \ LOGIC_LOOPEND_(4)
#define	NEEND_(z,y,x,w,v)					BEQR_(z,y,x,w,v,*+3) \ LOGIC_LOOPEND_(5)
#define     NEEND_(z,y,x,w,v,u)				BEQR_(z,y,x,w,v,u,*+3) \ LOGIC_LOOPEND_(6)
#define     NEEND_(z,y,x,w,v,u,t)			     	BEQR_(z,y,x,w,v,u,t,*+3) \ LOGIC_LOOPEND_(7)
#define     NEEND_(z,y,x,w,v,u,t,s)     			BEQR_(z,y,x,w,v,u,t,s,*+3) \ LOGIC_LOOPEND_(8)
#define     NEEND_(z,y,x,w,v,u,t,s,r)     		BEQR_(z,y,x,w,v,u,t,s,r,*+3) \ LOGIC_LOOPEND_(9)
#define     NEEND_(z,y,x,w,v,u,t,s,r,q)     		BEQR_(z,y,x,w,v,u,t,s,r,q,*+3) \ LOGIC_LOOPEND_(10)
#define     NEEND_(z,y,x,w,v,u,t,s,r,q,p)     		BEQR_(z,y,x,w,v,u,t,s,r,q,p,*+3) \ LOGIC_LOOPEND_(11)
#define     NEEND_(z,y,x,w,v,u,t,s,r,q,p,o)    		BEQR_(z,y,x,w,v,u,t,s,r,q,p,o,*+3) \ LOGIC_LOOPEND_(12)
#define     NEEND_(z,y,x,w,v,u,t,s,r,q,p,o,n)     	BEQR_(z,y,x,w,v,u,t,s,r,q,p,o,n,*+3) \ LOGIC_LOOPEND_(13)
#define     NEEND_(z,y,x,w,v,u,t,s,r,q,p,o,n,m)     	BEQR_(z,y,x,w,v,u,t,s,r,q,p,o,n,m,*+3) \ LOGIC_LOOPEND_(14)
#define     NEEND_(z,y,x,w,v,u,t,s,r,q,p,o,n,m,l)     BEQR_(z,y,x,w,v,u,t,s,r,q,p,o,n,m,l,*+3) \ LOGIC_LOOPEND_(15)
;*******************************************************************
;* IFxxx: These are the standard 'if' statements, they will always  
;*        be of type FLAG_WML_IF                                           
;*******************************************************************
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
#define 	JMPR_(a)		\#if a-$ > $7ff
#defcont				\	.error "Macro JMPR_: Relative branch exceedes limit. Use JMP_ instead."
#defcont				\#else
#defcont				\	#if $-a > $7ff
#defcont				\		.error "Macro JMPR_: Relative branch exceedes limit. Use JMP_ instead."
#defcont				\	#endif
#defcont				\#endif
#defcont				\	.db ($80+(((a-($+2))>>8)&$0f)) \.db ((a-($+1))&$ff)

;**********************************************************
;* Macro 9X:
;**********************************************************
#define 	JSRR_(a)		\#if a-$ > $7ff
#defcont				\	.error "Macro JSRR_: Relative branch exceedes limit. Use JSR_ instead."
#defcont				\#else
#defcont				\	#if $-a > $7ff
#defcont				\		.error "Macro JSRR_: Relative branch exceedes limit. Use JSR_ instead."
#defcont				\	#endif
#defcont				\#endif
#defcont				\	.db ($90+(((a-($+2))>>8)&$0f)) \.db ((a-($+1))&$ff)
;**********************************************************
;* Macro AX:
;**********************************************************
#define 	JSRDR_(a)		\#if a-$ > $7ff
#defcont				\	.error "Macro JSRDR_: Relative branch exceedes limit. Use JSRD_ instead."
#defcont				\#else
#defcont				\	#if $-a > $7ff
#defcont				\		.error "Macro JSRDR_: Relative branch exceedes limit. Use JSRD_ instead."
#defcont				\	#endif
#defcont				\#endif
#defcont				\	.db ($a0+(((a-($+2))>>8)&$0f)) \.db ((a-($+1))&$ff)


;**********************************************************
;* Macro BX: Add NextByte to RAM LSD(command) 
;**********************************************************
#define 	ADDRAM_(ramloc,data)	\#if ramloc > $0f
#defcont					\	.error "Macro ADDRAM_: RAM Location must be between $00-$0F"
#defcont					\#endif
#defcont					\	.db ($b0+(ramloc&$0f)),data

;**********************************************************
;* Macro CX: Set NextByte to RAM LSD(command) 
;**********************************************************
#define 	SETRAM_(ramloc,data)	\#if ramloc > $0f
#defcont					\	.error "Macro SETRAM_: RAM Location must be between $00-$0F"
#defcont					\#endif
#defcont					\	.db ($c0+ramloc),data

;**********************************************************
;* Macro DX: Play Index Sound (NextByte)Times  
;**********************************************************
#define	RSND_(snd,times)		.db $d0+(snd&0F),times

;**********************************************************
;* Macro EX,FX: Play Index Sound 
;**********************************************************
#define	SSND_(a)		\#if (a<$20)
#defcont				\	.db $e0+a
#defcont				\#else
#defcont				\	.db $e0
#defcont				\	.error "Macro SSND_: Parameters must be less than $20"
#defcont				\#endif
