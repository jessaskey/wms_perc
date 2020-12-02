;***********************************************
;* 680X Style Logical Instruction Macros       *
;* For use with TASMx Assembler                *
;* Written by Jess M. Askey 2001 jess@askey.org*
;***********************************************
.module logic
.msfirst

var1_		.equ	$00
var2_		.equ	$00
var3_		.equ	$00
var4_		.equ	$00

#define     FLAG_IF    	0
#define     FLAG_ELSE 	1
#define	FLAG_BEGIN 	2

;*******************************************************************
;* Locate: Pushes two Words                                        *
;*                                                                 *
;*            Word 1 - address of branch location                  *
;*            Word 2 - Type of Operation                           *
;*                     0 - Standard ENDIF                          *
;*                     1 - ELSE or Logical ELSE                    *
;*                     2 - Loop                                    *
;*******************************************************************
#define	logic_loc(type)	     \ .push  *, type

;*******************************************************************
;* Ifxx: These are the standard 'if' statements, they will always  *
;*       be of type 0.                                             *
;*******************************************************************
#define	logic_ifxx(x)	     logic_loc(FLAG_IF) \ x  * 

;*******************************************************************
;* Begin: The start marker for logical loops, must terminate with  *
;*        an 'xxend' statement.                                    *
;******************************************************************* 
#define     begin		      logic_loc(FLAG_BEGIN)

;*******************************************************************
;* Logic End: This is the end macro for the 'begin' statement. It  *
;*            pulls the pc location of the beginning of the loop   *
;*            and verifies that the 'type' is correct.             *
;*******************************************************************
#define logic_loopend(x,y)	\ .pop var1_, var2_
#defcont				\#if (var1_ & FLAG_BEGIN)
#defcont					\#if ((var2_-*-2+127) <= 0)
#defcont						\ y	*+5
#defcont						\ jmp	var2_
#defcont					\#else
#defcont						\ x	var2_
#defcont					\#endif
#defcont				\#else
#defcont					\ .error "Inappropriate End for BEGIN Loop."
#defcont				\#endif

;*******************************************************************
;* Logic Find: Used for ENDIF statement. Will find the pc for the  *
;*             previous IF (or ELSE) and update the branch or jump *
;*             at that address to point to the current address.    *
;*******************************************************************
#define logic_end \var1_ .set *
#defcont		\ .pop var3_, var4_
#defcont		\#if (var3_ & FLAG_BEGIN)==0 
#defcont			\#if (var3_ & FLAG_ELSE)==0	
#defcont  				\var2_ .set var1_-var4_-2
#defcont				\#if var2_+127 < 0
#defcont					\ .error "Branch Range < -127"
#defcont				\#else
#defcont					\#if var2_-128 > 0
#defcont						\ .error "Branch Range > 128"
#defcont					\#else
#defcont    					\ .org var4_+1
#defcont						\ .byte var2_
#defcont					\#endif
#defcont				\#endif
#defcont			\#else	
#defcont    			\ .org  var4_-2	
#defcont				\ .word var1_
#defcont			\#endif
#defcont			\ .org	var1_
#defcont		\#else
#defcont			\.error "Wrong Endtype for IF block"
#defcont		\#endif

;*******************************************************************
;* Logic Else: Can act as a standard else or a complex else        *
;*             (ie. with additional logic as defined below). The   *
;*             ELSE block will resove how to terminate the current *
;*             code and then set the owning IF statement's data    *
;*             byte.                                               *
;*******************************************************************
#define	logic_else(x,y)	\var1_ .set $
#defcont		\ .pop var3_, var4_
#defcont		\#if (var3_ & FLAG_BEGIN)==0
#defcont			\#if (var3_ & FLAG_ELSE)==0
#defcont				\ .org var4_+1
#defcont	      		\#if x==0
#defcont					\var2_ .set var1_-var4_-2+2
#defcont					\#if var2_+127 < 0
#defcont						\ .org var1_
#defcont						\.push $+3, 1
#defcont						\ jmp $
#defcont					\#else
#defcont						\#if var2_-128>0
#defcont							\ .org var1_
#defcont							\.push $+3, 1
#defcont							\ jmp $
#defcont						\#else
#defcont							\.push var1_, 0
#defcont							\ .byte var2_
#defcont							\ .org var1_
#defcont							\ BRA $
#defcont							\ .org var1_+2
#defcont						\#endif
#defcont					\#endif
#defcont				\#else
#defcont					\ .byte var1_-var4_-2+2
#defcont					\ .org var1_
#defcont					\.push $, 0
#defcont					\ y $		
#defcont				\#endif
#defcont			\#else
#defcont				\.error "Duplicate ELSE Statement"
#defcont			\#endif
#defcont		\#else
#defcont			\ .error "Misplaced Else"
#defcont		\#endif


;*******************************************************************
;* Defines how to use the various logic macros defined above.      *
;*******************************************************************
#define	ifeq	logic_ifxx(BNE)		
#define	ifne	logic_ifxx(BEQ)
#define	ifpl	logic_ifxx(BMI)
#define	ifhi	logic_ifxx(BLO)
#define	ifmi	logic_ifxx(BPL)
#define	iflo	logic_ifxx(BHI)
#define	ifcs	logic_ifxx(BCC)
#define	ifcc	logic_ifxx(BCS)
#define 	ifvc	logic_ifxx(BVS)
#define 	ifvs	logic_ifxx(BVC)
#define	ifge	logic_ifxx(BLO)
#define	ifgt	logic_ifxx(BLS)

#define	else  	logic_else(0,0)
#define	else_eq	logic_else(1,BEQ)
#define	else_ne	logic_else(1,BNE)
#define	else_pl	logic_else(1,BPL)
#define	else_mi	logic_else(1,BMI)
#define	else_cc	logic_else(1,BCC)
#define	else_cs	logic_else(1,BCS)

#define 	endif		logic_end

#define	eqend	logic_loopend(BNE,BEQ)		
#define	neend	logic_loopend(BEQ,BNE)		
#define	plend	logic_loopend(BMI,BPL)
#define	miend	logic_loopend(BPL,BMI)
#define	csend	logic_loopend(BCC,BCS)
#define	ccend	logic_loopend(BCS,BCC)
#define	vcend	logic_loopend(BVS,BVC)
#define	vsend	logic_loopend(BVC,BVS)
#define     hiend logic_loopend(BLS,BHI)
#define     lsend logic_loopend(BHI,BLS)

#define	loopend	logic_loopend(BRA,BRA)

#define	lsb(x)	x&$FF

#define	msb(x)	(x>>8)&$FF