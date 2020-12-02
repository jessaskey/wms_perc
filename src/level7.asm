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
;* This file is set up with tab stops at 6
;*****************************************************************************
;* DB pointed out that this is probably a good idea.
.msfirst	

#include "68logic.asm"		;68XX Logic Definitions
#include "7hard.asm"		;Level 7 Hardware Definitions
#include "wvm7.asm"		;Virtual Machine Instruction Definitions

;Requires game definition file, link to the export file
#include "gamerom.exp"

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
;* Requires:	A - XXXXZZZZ
;*					
;* Where XXXX 	= Solenoid Timer/Command
;*       ZZZZ	= Solenoid Number
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
next_switch		bsr	getswitch				;Clear Carry if Switch Activated
			bcs	to_ldx_rts				;ldx $A0, rts.
			bsr	sw_pack				;$A5(A) = ($A1<<3)+BitPos($A2) Encode Matrix Position
			ldx	#switch_queue
			begin
				cpx	switch_queue_pointer
				beq	next_switch
				cmpa	$01,X					;Is this switch in the buffer?
				ifeq
					bsr	copy_word				;Copy Word: $96--  Data,$96 -> Data,X
					jsr	sw_proc
					bra	next_switch
				endif
				inx	
				inx	
			loopend
			
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
			ldx	#threadpool_base
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
reset_audits	ldx	#aud_reset_end-aud_base		;Clear RAM from 0100-0165
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

;***************************************************************
;* Lamp Range Manipulation Code Start Here
;***************************************************************
;Clears all lamps in specified buffer, sets active buffer to 0		
lampm_clr0		bsr	lampr_start				;A=Current State,B=Bitpos,X=Lamp Byte Postion
			begin
				tba	
				coma	
				anda	$00,X
				bsr	lampm_buf0			;Set Lamp to Buffer 0
				jsr	lamp_left			;Shift Lamp Bit Left, De-increment Lamp Counter, Write it
			csend						;Loop it!
			bra	abx_ret
			
lampm_buf0		staa	$00,X
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

;Invert entire range
lampm_f		bsr	lampr_start				;A=Current State,B=Bitpos,X=Lamp Byte Postion
			begin
				tba	
				eora	$00,X
				staa	$00,X
				jsr	lamp_left				;Shift Lamp Bit Left, De-increment Lamp Counter, Write it
			csend
			bra	abx_ret

;This is unused in the macros. You must call it directly at $F1D5
;The behavior of this command is probably the most complex. It 
;starts at the last lamp in the range. If it is already set, then
;the routine simply exits. If the last lamp is not set, the routine
;goes down through each lamp in the range. If if finds a lamp on,
;then it turns off that lamp, then goes back up to the next lamp
;and turns it on. If no lamps are on in the range, then the first
;lamp in the range is turned on.
;The best example of this routine is for the 10-20-30 lamps on 
;Jungle Lord. It will simply incrment the 10-20-30 lamps sequentially
;and then stop at 30. If none are on, then it will turn on 10.
lampm_g				
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
;***************************************************
;* Goes through range bits from low to high and
;* finds first cleared bit, sets it and exits.	
;***************************************************	
lampm_a		bsr	lampr_start				;A=Current State,B=Bitpos,X=Lamp Byte Postion
			begin
				beq	b_09A
				bsr	lamp_left				;Shift Lamp Bit Left, De-increment Lamp Counter, Write it
				bcs	abx_ret				;Return if we have reached end lamp
			loopend
			
;***************************************************
;* Goes through range bits from low to high and
;* finds first cleared bit, sets it and exits. If 
;* all bits in range are already set, then routine 
;* clears all bits in range.
;***************************************************			
lampm_b		bsr	lampr_start				;A=Current State,B=Bitpos,X=Lamp Byte Postion
			begin
				beq	b_09A
				bsr	lamp_left				;Shift Lamp Bit Left, De-increment Lamp Counter, Write it
			csend
			ldx	temp3
			ldaa	sys_temp1
			ldab	sys_temp2
			bra	lampm_clr0				;Turn OFF All lamps in Range

;Sets all lamp bits specified buffer, sets active buffer to 0 if action is on buffer 0			
lampm_set0		bsr	lampr_start				;A=Current State,B=Bitpos,X=Lamp Byte Postion
			begin
				tba	
				oraa	$00,X
				bsr	lampm_buf0			;Set Lamp to Buffer 0
				bsr	lamp_left			;Shift Lamp Bit Left, De-increment Lamp Counter, Write it
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
;* Loads the Lamp range data
;*
;* sys_temp2 = start lamp
;* sys_temp3 = end lamp
;* A = Byte data anded with curent bit
;* B = Bitpos
;* X = Lamp Byte Postion
;*
;************************************			
lampr_start		jsr	lampr_setup				;Set up Lamp: $A2=start $A3=last B=Bitpos X=Buffer
			ldaa	sys_temp3				;Starting lamp in range
lr_ret		jsr	unpack_byte				;(X = X + A>>3), B = (bitpos(A&07))
			tba	
			anda	$00,X
			rts	
			
lampr_end		bsr	lampr_setup				;Set up Lamp: $A2=start $A3=last B=Bitpos X=Buffer
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

;*************************************************************
;* Moves current lamp bit up one bit. If shifted off end of 
;* current lamp buffer byte, then byte is incremented and bit
;* is reset to $01.
;*************************************************************			
lamp_left		aslb					;shift it
			ifcs					;did it go off end
				rolb					;yes, rolb to #$01
				inx					;increment the byte position
			endif
ls_ret		ldaa	temp1				;load up the original lamp counter until end lamp
			suba	#$01				;take one off
			staa	temp1				;store it again
			tba					;get the bit back again
			anda	$00,X				;AND accum A with current buffer location
			rts	

;*************************************************************
;* Moves current lamp bit down one bit. If shifted off start of 
;* current lamp buffer byte, then byte is deincremented and bit
;* is reset to #$80
;*************************************************************			
lamp_right		lsrb	
			bcc	ls_ret
			rorb	
			dex	
			bra	ls_ret
			
;***************************************************
;* Goes through range bits from high to low, routine
;* finds first bit in range that is set and clears
;* it and then exits.
;***************************************************			
lampm_c		bsr	lampr_end				;A=Current State,B=Bitpos,X=Lamp Byte Postion
lm_test		ifeq
				bsr	lamp_right				;Shift Lamp Bit Right, De-increment Lamp Counter, Write it
				bcc	lm_test
				bra	abx_ret
			endif
			comb	
			andb	$00,X
			stab	$00,X
			bra	abx_ret

;Rotate Up			
lampm_e		bsr	lampr_start				;A=Current State,B=Bitpos,X=Lamp Byte Postion
			stx	temp2
			stab	temp1+1
			begin
				staa	sys_temp5
				bsr	lamp_left				;Shift Lamp Bit Left, De-increment Lamp Counter, Write it
				bcs	b_0A2					;Branch if we are at the end of the range
				bsr	b_0A3
			loopend
			
b_0A2			ldx	temp2					;Get the last Byte location
			ldab	temp1+1				;Get the last Bitpos
			bsr	b_0A3
			bra	to_abx_ret
;Rotate Down			
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
			tba					;B has the bitpos
			coma	
			anda	$00,X				;Mask it off
			tst	sys_temp5			;sys_temp5 has the first bit in range's value or 0s
			ifne					;if it was on
				aba					;make it on again
			endif
			staa	$00,X				;store it
			pula	
			rts	
			
lampm_z		jsr	lampr_end				;A = Last Lamp Level, B = Last Lamp BitPos
			ifeq
				begin
					bsr	lamp_right				;Shift Lamp Bit Right, De-increment Lamp Counter, Write it
					bcs	to_abx_ret
				neend
			endif
			tba	
			eora	$00,X
			staa	$00,X
			jsr	lamp_right				;Shift Lamp Bit Right, De-increment Lamp Counter, Write it
			bcs	to_abx_ret
			orab	$00,X
			stab	$00,X
to_abx_ret		jmp	abx_ret

			jsr	lampr_start				;A=Current State,B=Bitpos,X=Lamp Byte Postion
b_0AB			ifne
				jsr	lamp_left				;Shift Lamp Bit Left, De-increment Lamp Counter, Write it
				bcc	b_0AB
				bra	to_abx_ret
			endif
b_0AA			clc	
			bra	to_abx_ret
b_0AB			jsr	lampr_start				;A=Current State,B=Bitpos,X=Lamp Byte Postion
b_0AC			bne	b_0AA
			jsr	lamp_left				;Shift Lamp Bit Left, De-increment Lamp Counter, Write it
			bcc	b_0AC
			bra	to_abx_ret

		
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
			jsr	lampr_start				;A=Current State,B=Bitpos,X=Lamp Byte Postion
			begin
				staa	thread_priority			;This is probably just a temp location?
				tba	
				coma	
				anda	bitflags,X
				oraa	thread_priority			;Recall temp
				staa	bitflags,X
				jsr	lamp_left				;Shift Lamp Bit Left, De-increment Lamp Counter, Write it
			csend
			bra	to_abx_ret
			
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
			
vm_lookup_1x_a	.dw lampm_set0
			.dw lampm_clr0
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
			jsr	b_0AB
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
			;fall through
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

;*******************************************
;* Exports for the Game ROM
;*******************************************

.export vm_reg_a,vm_reg_b,game_ram_2,game_ram_3,game_ram_4,game_ram_5,game_ram_6,game_ram_7,game_ram_8
.export game_ram_9,game_ram_a,game_ram_b,game_ram_c,game_ram_d,lampbuffer0,bitflags,lampbufferselect,lampbuffer1,lampflashflag
.export score_p1_b0,score_p3_b0,score_p4_b0,score_p1_b1,score_p2_b1,score_p3_b1,score_p4_b1,mbip_b0,mbip_b1,cred_b0,cred_b1
.export dmask_p1,dmask_p2,dmask_p3,dmask_p4,comma_flags,switch_debounced,switch_masked,switch_pending,switch_aux,switch_b4,irq_counter
.export lamp_index_word,lamp_bit,comma_data_temp,credp1p2_bufferselect,mbipp3p4_bufferselect,swap_player_displays,solenoid_address
.export solenoid_bitpos,solenoid_counter,irqcount16,switch_queue_pointer,solenoid_queue_pointer
.export temp1,temp2,temp3,sys_temp1,sys_temp2,sys_temp3,sys_temp4,sys_temp5,sw_encoded,sys_temp_w2,sys_temp_w3,thread_priority
.export unused_ram1,irqcount,vm_base,vm_nextslot,current_thread,vm_tail_thread,lamp_flash_rate,lamp_flash_count,thread_timer_byte
.export soundcount,lastsound,cur_sndflags,soundptr,soundirqcount,soundindex_com,sys_soundflags,soundindex,csound_timer,next_sndflags
.export next_sndcnt,next_sndcmd,flag_tilt,flag_gameover,flag_bonusball,flags_selftest,num_players,player_up
.export pscore_buf,num_eb,vm_pc,num_tilt,minutetimer,flag_timer_bip,randomseed,x_temp_1,eb_x_temp,credit_x_temp,x_temp_2,spare_ram
.export cmos_base,cmos_csum,aud_leftcoins
.export aud_centercoins,aud_rightcoins,aud_paidcredits,aud_specialcredits,aud_replaycredits,aud_matchcredits,aud_totalcredits
.export aud_extraballs,aud_avgballtime,aud_totalballs,aud_game1,aud_game2,aud_game3,aud_game4,aud_game5,aud_game6,aud_game7
.export aud_autocycles,aud_hstdcredits,aud_replay1times,aud_replay2times,aud_replay3times,aud_replay4times,cmos_bonusunits
.export cmos_coinunits,aud_currenthstd,aud_currentcredits,aud_command,adj_cmoscsum,adj_backuphstd,adj_replay1,adj_replay2
.export adj_replay3,adj_replay4,adj_matchenable,adj_specialaward,adj_replayaward,adj_maxplumbbobtilts,adj_numberofballs
.export adj_gameadjust1,adj_gameadjust2,adj_gameadjust3,adj_gameadjust4
.export adj_gameadjust5,adj_gameadjust6,adj_gameadjust7,adj_gameadjust8,adj_gameadjust9,adj_hstdcredits,adj_max_extraballs
.export adj_max_credits,adj_pricecontrol,cmos_leftcoinmult,cmos_centercoinmult,cmos_rightcoinmult,cmos_coinsforcredit
.export cmos_bonuscoins,cmos_minimumcoins,cmos_byteloc,switch_queue,sol_queue,score_queue,exe_buffer,p1_gamedata,p2_gamedata
.export p3_gamedata,p4_gamedata,pia_sound_data,pia_sound_ctrl,pia_comma_data,pia_comma_ctrl,pia_sol_low_data,pia_sol_low_ctrl
.export pia_sol_high_data,pia_sol_high_ctrl,pia_lamp_row_data,pia_lamp_row_ctrl,pia_lamp_col_data,pia_lamp_col_ctrl,pia_disp_digit_data
.export pia_disp_digit_ctrl,pia_disp_seg_data,pia_disp_seg_ctrl,pia_switch_return_data,pia_switch_return_ctrl
.export pia_switch_strobe_data,pia_switch_strobe_ctrl,pia_alphanum_digit_data,pia_alphanum_digit_ctrl,pia_alphanum_seg_data
.export pia_alphanum_seg_ctrl,reset,csum1,init_done,clear_all,main,checkswitch,time,switches,next_sw,sw_break,vm_irqcheck
.export flashlamp,solq,snd_queue,check_threads,nextthread,delaythread,addthread,dump_thread,killthread
.export newthread_sp,newthread_06,killthread_sp,kill_thread,kill_threads,check_threadid,pri_next,pri_skipme
.export solbuf,set_solenoid,set_ss_off,set_s_pia,set_ss_on,soladdr,ssoladdr,hex2bitpos,comma_million,comma_thousand
.export update_commas,set_comma_bit,test_mask_b,update_eb_count,isnd_pts,dsnd_pts,snd_pts,score_main,score_update
.export hex2dec,score2hex,sh_exit,add_points,checkreplay,get_hs_digits,b_plus10,split_ab,isnd_once,sound_sub,isnd_test
.export isnd_mult,snd_exit_pull,snd_exit,send_snd_save,send_snd,do_complex_snd,store_csndflg,check_sw_mask,sw_ignore
.export sw_active,sw_down,sw_dtime,sw_trig_yes,sw_proc,check_sw_close,to_ldx_rts,getswitch,sw_pack,pack_done
.export check_sw_open,sw_get_time,sw_tbl_lookup,xplusa,copy_word,setup_vm_stack,stack_done,xplusb,cmosinc_a,cmosinc_b,b_cmosinc
.export reset_audits,clr_ram_100,clr_ram,factory_zeroaudits,restore_hstd,a_cmosinc,copyblock,loadpricing,copyblock2,sys_irq
.export pia_ddr_data,spec_sol_def,lampbuffers,lamp_on,lamp_or,lamp_commit,lamp_done,lamp_off,lamp_and,lamp_flash,lamp_invert
.export lamp_eor,lamp_on_b,lamp_off_b,lamp_invert_b,lamp_on_1,lamp_off_1,lamp_invert_1,unpack_byte,lampm_clr0,lampm_buf0
.export lampm_f,lampm_a,lampm_b,lampm_set0,abx_ret,lampr_start,lr_ret,lampr_end
.export lampr_setup,lamp_left,ls_ret,lamp_right,lampm_c,lm_test,lampm_e,lampm_d,bit_switch,bit_lamp_flash,bit_lamp_buf_1,bit_lamp_buf_0
.export lampm_z,lampm_x,bit_main,csum2,master_vm_lookup,vm_lookup_0x,vm_lookup_1x_a,vm_lookup_1x_b,vm_lookup_2x,vm_lookup_4x,vm_lookup_5x
.export branch_lookup,macro_start,macro_rts,macro_go,switch_entry,breg_sto,vm_control_0x,macro_pcminus100,macro_code_start
.export macro_special,macro_extraball,vm_control_1x, macro_x8f,macro_17,macro_x17,to_macro_go1,vm_control_2x,vm_control_3x
.export vm_control_4x,macro_exec,gettabledata_w,gettabledata_b,macro_getnextbyte,getx_rts,vm_control_5x,macro_ramadd,ram_sto2
.export to_macro_go2,macro_ramcopy,macro_set_pri,macro_delay_imm_b,dly_sto,macro_getnextword,macro_get2bytes,macro_rem_th_s
.export macro_rem_th_m,macro_jsr_noreturn,pc_sto2,macro_a_ram,to_getx_rts,macro_b_ram,macro_jsr_return,ret_sto,vm_control_6x
.export vm_control_7x,vm_control_8x,pc_sto,to_macro_go4,macro_jmp_cpu,vm_control_9x,vm_control_ax,macro_jmp_abs,vm_control_bx
.export ram_sto,vm_control_cx,vm_control_dx,vm_control_ex,vm_control_fx,macro_pcadd,macro_setswitch,load_sw_no,macro_clearswitch
.export to_macro_go3,to_macro_getnextbyte,macro_branch,branchdata,complexbranch,branch_invert,to_rts3,branch_lamp_on,test_z
.export branch_lamprangeoff,test_c,branch_lamprangeon,branch_tilt,ret_false,branch_gameover,ret_true,branch_lampbuf1
.export branch_switch,branch_and,branch_add,branch_or,branch_equal,branch_ge,branch_threadpri,branch_bitwise,to_rts4,set_logic
.export award_special,credit_special,award_replay,give_credit,extraball,do_eb,addcredits,addcredit2,coinlockout,checkmaxcredits
.export pull_ba_rts,creditq,ptrx_plus_1,ptrx_plus_a,ptrx_plus,coin_accepted,cmos_a_plus_b_cmos,divide_ab,clr_bonus_coins,csum3
.export dec2hex,write_range,do_game_init,add_player,initialize_game,clear_range,to_pula_rts,clear_displays,store_display_mask
.export init_player_game,setplayerbuffer,copyplayerdata,init_player_up,disp_mask,disp_clear,init_player_sys,resetplayerdata
.export dump_score_queue,outhole_main,saveplayertobuffer,to_copyblock,balladjust,show_hstd,gameover,powerup_init,set_gameover
.export show_all_scores,check_hstd,hstd_nextp,set_hstd,update_hstd,hstd_adddig,wordplusbyte,to_rts1,fill_hstd_digits,send_sound
.export do_match,get_random,to_rts2,credit_button,has_credit,start_new_game,lesscredit,tilt_warning,do_tilt,testdata,testlists
.export selftest_entry,st_diagnostics,do_aumd,check_adv,check_aumd,st_init,to_clear_range,st_nexttest,to_audadj,do_audadj
.export show_func,adjust_func,st_reset,fn_gameid,fn_gameaud,fn_sysaud,fn_hstd,fn_replay,cmos_add_d,fn_pricec,fn_prices
.export cmos_a,fn_ret,fn_credit,fn_cdtbtn,fn_adj,fn_command,st_display,st_sound,st_lamp,st_autocycle,st_solenoid,st_switch
.export st_swnext,rambad,diag,diag_showerror,tightloop,diag_ramtest,cmos_error,block_copy,cmos_restore,adjust_a,irq_entry
.export swi_entry,nmi_entry,res_entry,player_ready,isnd_mult_x