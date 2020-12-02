;*****************************************************************************
;* Williams Level 7 General Macros
;*****************************************************************************
;* Code copyright Williams Electronic Games Inc.
;* Written/Decoded by Jess M. Askey (jess@askey.org)
;* For use with TASMx Assembler
;* Visit http://www.gamearchive.com/pinball/manufacturer/williams/pinbuilder
;* for more information.
;* You may redistribute this file as long as this header remains intact.
;*****************************************************************************

;*****************************************************************************
;* This is where you should put general timesaving macros above and beyond
;* the base logic and WML7 macros...
;*
;* An example is repetitive code such as...
;*
;* ldx	#gj_2B
;* jsr	newthread_06
;*
;* Is both long and it is easy to forget to reference the label properly, it
;* can be replaced with..
;*
;* NEWTHREAD(gj_2B) 
;* 
;* By using the macro defined below...
;*****************************************************************************

#define	NEWTHREAD(x)	\ ldx #x	\ jsr newthread_06
#define     NEWTHREAD_JMP(x)	\ ldx #x	\ jmp newthread_06


;*****************************************************************************
;* When in native code, it is common to to sleep the current thread a number of
;* cycles, this is similar to the SLEEP_ macro, but when in code it looks like this
;*
;* jsr	addthread
;* .db $01				;with the data lingering behind
;*
;* It is much easier to read a macro like this...
;*
;* SLEEP(1);
;*
;*****************************************************************************

#define	SLEEP(x)	\ jsr addthread	\ .db x


;*****************************************************************************
; Lamp Groups
;*****************************************************************************
lmpgrpidx___ = 0

#define	LAMPGROUP(group,start,end)	\group = lmpgrpidx___
#defcont						\ .db start,end
#defcont						\lmpgrpidx___ .set lmpgrpidx___+1
