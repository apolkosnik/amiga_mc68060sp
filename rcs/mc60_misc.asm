

**-------------------------------------------------------------------------------
**  /\  |\     Silicon Department         Telefax             06404-64760
**  \_ o| \_ _  Software Entwicklung      Telefon             06404-7996
**    \|| |_)|)   Carsten Schlote         Oberstedter Str 1   35423 Lich
** \__/||_/\_|     Branko Miki�           Elisenstr 10        30451 Hannover
**-------------------------------------------------------------------------------
** ALL RIGHTS ON THIS SOURCES RESERVED TO SILICON DEPARTMENT SOFTWARE
**
** $Id$
**
**
	machine	68060
	near

	include	"mc60_system.i"
	include	"mc60_libbase.i"


	section          mmu_code,code

*----------------------------------------------------------------------------------------------------
*----------------------------------------------------------------------------------------------------
*----------------------------------------------------------------------------------------------------
*----------------------------------------------------------------------------------------------------
*----------------------------------------------------------------------------------------------------
*----------------------------------------------------------------------------------------------------
*----------------------------------------------------------------------------------------------------

	XDEF	_FlushMMU
_FlushMMU:
	MOVEM.L	A5/A6,-(SP)
	LEA	(FlushMMU_Trap,PC),A5
	MOVEA.L	(mc60_SysBase,A6),A6
	JSR	(_LVOSupervisor,A6)
	MOVEM.L	(SP)+,A5/A6
	RTS

FlushMMU_Trap:	CPUSHL	DC,(A0)
	LEA	($0010,A0),A0
	CPUSHL	DC,(A0)
	PFLUSHA		;MC68040
	RTE

*----------------------------------------------------------------------------------------------------

	XDEF	_AllocPatchPage
_AllocPatchPage:
	MOVEM.L	D7/A4-A6,-(SP)
	MOVE.L	D0,D7
	MOVEA.L	A0,A5
	MOVE.L	D7,D0
	ADDI.L	#$00000FFF,D0
	MOVEQ	#1,D1
	MOVEA.L	(4).W,A6
	JSR	(_LVOAllocMem,A6)
	MOVEA.L	D0,A4

	MOVE.L	A4,D0
	BEQ.B	.nomem
	MOVE.L	D7,D0
	ADDI.L	#$00000FFF,D0
	MOVEA.L	A4,A1
	JSR	(_LVOFreeMem,A6)

	MOVE.L	A4,D0
	ADDI.L	#$00000FFF,D0
	ANDI.W	#$F000,D0
	MOVEA.L	D0,A1
	MOVE.L	D7,D0
	JSR	(_LVOAllocAbs,A6)
	MOVEA.L	D0,A4
	ADD.L	D7,($003C,A5)
.nomem:	MOVE.L	A4,D0
	MOVEM.L	(SP)+,D7/A4-A6
	RTS

; -----------------------------------------------------------------------------
	XDEF	_SetupRootPage
_SetupRootPage:
	MOVEM.L	D2/D5-D7/A4-A6,-(SP)
	MOVE.L	D1,D6	;d6=512-1
	MOVE.L	D0,D7	;d7=$200
	MOVEA.L	A0,A5	;a5=mmuframe

	MOVE.L	($0048,A5),D0
	CMP.L	D7,D0
	BCS.B	.alreadydone

	MOVEA.L	($0044,A5),A4
	MOVE.L	A4,D1
	ADD.L	D7,D1
	ADD.L	D6,D1

	MOVE.L	D6,D2
	NOT.L	D2
	AND.L	D2,D1
	MOVE.L	D1,($0044,A5)

	MOVE.L	A4,D0
	SUB.L	D0,D1
	MOVE.L	D1,D5
	SUB.L	D5,($0048,A5)

	MOVE.L	D5,D0
	SUB.L	D7,D0
	ADD.L	D0,($0040,A5)
	BRA.B	.end

.alreadydone:	MOVEA.L	(4).W,A6
	JSR	(_LVOForbid,A6)

	MOVE.L	D7,D0
	ADDI.L	#$00001000,D0
	MOVEQ	#1,D1
	JSR	(_LVOAllocMem,A6)
	MOVEA.L	D0,A4

	MOVE.L	A4,D0
	BEQ.B	.nomem

	MOVE.L	D7,D0
	ADDI.L	#$00001000,D0
	MOVEA.L	A4,A1
	JSR	(_LVOFreeMem,A6)

	MOVE.L	A4,D0
	ADDI.L	#$00000FFF,D0
	ANDI.W	#$F000,D0
	MOVEA.L	D0,A1
	MOVEQ	#$40,D0
	LSL.L	#6,D0
	JSR	(_LVOAllocAbs,A6)
	MOVEA.L	D0,A4

	MOVE.L	A4,D0
	ADD.L	D7,D0
	ADD.L	D6,D0

	MOVE.L	D6,D1
	NOT.L	D1
	AND.L	D1,D0
	MOVE.L	D0,($0044,A5)

	MOVE.L	A4,D1
	SUB.L	D1,D0
	MOVEQ	#$40,D1
	LSL.L	#6,D1
	MOVE.L	D1,D2
	SUB.L	D0,D2
	MOVE.L	D2,($0048,A5)

	ADDI.L	#$00001000,($003C,A5)
	BRA.B	.normend

.nomem:	CLR.L	($0044,A5)
	CLR.L	($0048,A5)
.normend:	JSR	(_LVOPermit,A6)
.end:	MOVE.L	A4,D0
	MOVEM.L	(SP)+,D2/D5-D7/A4-A6
	RTS

; -----------------------------------------------------------------------------
	XDEF	_SetMMUPageMode
_SetMMUPageMode:
	SUBA.W	#$001C,SP	;a0=mmuframe,d0=wo,d1=len,(sp)=mode

	MOVEM.L	D2/D3/D5-D7/A3-A5,-(SP)
	MOVE.L	($0040,SP),D5
	MOVE.L	D1,D6
	MOVE.L	D0,D7
	MOVEA.L	A0,A5

	CLR.W	($0038,SP)
	MOVEQ	#-1,D0
	CMP.L	($004C,A5),D0
	BNE.B	.case1
	MOVE.L	D7,D0
	ANDI.W	#$F000,D0
	MOVE.L	D0,($004C,A5)
	MOVE.L	D5,D1
	MOVE.L	D1,($0050,A5)
	BRA.B	.case2

.case1:	MOVE.L	D7,D0
	ANDI.W	#$F000,D0
	CMP.L	($004C,A5),D0
	BNE.B	.case2
	MOVE.L	($0050,A5),D0
	CMP.L	D5,D0
	BNE.B	.case2
	MOVE.L	A5,D0
	BRA.W	.end

.case2:	MOVE.L	D7,D0
	ANDI.W	#$F000,D0
	MOVE.L	D0,($004C,A5)
	MOVE.L	D5,($0050,A5)
	BSET	#0,D5
	MOVE.L	A5,D0
	BEQ.W	.loop3out
	MOVE.L	D7,D0
	LSR.L	#8,D0
	LSR.L	#4,D0
	MOVE.L	D7,D1
	ADD.L	D6,D1
	SUBQ.L	#1,D1
	LSR.L	#8,D1
	LSR.L	#4,D1
	MOVE.L	D0,($0034,SP)
	MOVE.L	D1,($0030,SP)
	CMP.L	D1,D0
	BLS.B	.loop3
	MOVE.W	#1,($0038,SP)

.loop3:	MOVE.L	($0034,SP),D0
	CMP.L	($0030,SP),D0
	BHI.W	.loop3out
	CLR.W	($0038,SP)
	MOVE.L	D0,D1
	LSR.L	#8,D1
	LSR.L	#5,D1
	MOVE.L	D0,D2
	LSR.L	#6,D2
	MOVEQ	#$7F,D3
	AND.L	D3,D2
	MOVEQ	#$3F,D3
	AND.L	D3,D0
	MOVEA.L	(12,A5),A0
	LEA	(A0,D1.L*4),A1
	MOVE.L	D0,($0024,SP)
	MOVE.L	D1,($002C,SP)
	MOVE.L	D2,($0028,SP)
	MOVE.L	(A1),D0
	CMP.L	($0024,A5),D0
	BNE.B	.isnot

	MOVEA.L	A5,A0
	MOVEQ	#$40,D0
	LSL.L	#3,D0
	MOVE.L	#$000001FF,D1
	BSR.W	_SetupRootPage
	MOVEA.L	D0,A4

	MOVE.L	A4,D0
	BEQ.B	.isnot

	MOVE.L	($002C,SP),D0
	MOVEA.L	(12,A5),A0
	LEA	(A0,D0.L*4),A1
	MOVE.L	A4,D0
	ORI.W	#3,D0
	MOVE.L	D0,(A1)
	CLR.L	($0020,SP)

.loop:	MOVE.L	($0020,SP),D0
	MOVEQ	#$40,D1
	ADD.L	D1,D1
	CMP.L	D1,D0
	BCC.B	.loopout
	MOVE.L	($0028,A5),(A4,D0.L*4)
	ADDQ.L	#1,($0020,SP)
	BRA.B	.loop

.loopout:	PEA	($60).W
	MOVE.L	A4,D0
	MOVEA.L	A5,A0
	MOVEQ	#$40,D1
	LSL.L	#3,D1
	BSR.W	_SetMMUPageMode

	MOVEA.L	D0,A5
	ADDQ.W	#4,SP
.isnot:	MOVE.L	($002C,SP),D0
	MOVEA.L	(12,A5),A0
	LEA	(A0,D0.L*4),A1
	MOVE.L	(A1),D0
	MOVE.L	($0024,A5),D1
	CMP.L	D0,D1
	BEQ.W	.loopcont
	ANDI.W	#$FE00,D0
	MOVEA.L	D0,A4
	MOVE.L	($0028,SP),D0
	MOVE.L	(A4,D0.L*4),D0
	CMP.L	($0028,A5),D0
	BNE.B	.noframe

	MOVEA.L	A5,A0
	MOVEQ	#$40,D0
	LSL.L	#2,D0
	MOVE.L	#$000001FF,D1
	BSR.W	_SetupRootPage
	MOVEA.L	D0,A3

	MOVE.L	A3,D0
	BEQ.B	.noframe
	MOVE.L	A3,D0
	ORI.W	#3,D0
	MOVE.L	($0028,SP),D1
	MOVE.L	D0,(A4,D1.L*4)
	CLR.L	($0020,SP)
.loop2:	MOVE.L	($0020,SP),D0
	MOVEQ	#$40,D1
	CMP.L	D1,D0
	BCC.B	.loopout2
	MOVE.L	($002C,A5),(A3,D0.L*4)
	ADDQ.L	#1,($0020,SP)
	BRA.B	.loop2

.loopout2:	PEA	($60).W
	MOVE.L	A3,D0
	MOVEA.L	A5,A0
	MOVEQ	#$40,D1
	LSL.L	#2,D1
	BSR.W	_SetMMUPageMode
	MOVEA.L	D0,A5
	ADDQ.W	#4,SP

.noframe:	MOVE.L	($0028,SP),D0
	MOVE.L	(A4,D0.L*4),D0
	MOVE.L	($0028,A5),D1
	CMP.L	D0,D1
	BEQ.B	.loopcont
	ANDI.W	#$FE00,D0
	MOVEA.L	D0,A3
	MOVE.L	($0024,SP),D0
	MOVE.L	(A3,D0.L*4),D0
	CMP.L	($002C,A5),D0
	BNE.B	.skipit

	MOVE.L	($0034,SP),D0
	MOVE.L	D0,D1
	ASL.L	#8,D1
	ASL.L	#4,D1
	MOVE.L	($0024,SP),D2
	MOVE.L	D1,(A3,D2.L*4)

.skipit:	MOVEQ	#$60,D0
	MOVE.L	($0024,SP),D1
	AND.L	(A3,D1.L*4),D0
	MOVEQ	#$20,D1
	CMP.L	D1,D0
	BHI.B	.ishigher
	MOVE.L	($0024,SP),D0
	MOVE.L	(A3,D0.L*4),D0
	OR.L	D5,D0
	MOVE.L	($0024,SP),D1
	MOVE.L	D0,(A3,D1.L*4)
.ishigher:	TST.L	D7
	BNE.B	.setit
	MOVE.L	A3,($0020,A5)
.setit:	MOVE.W	#1,($0038,SP)
.loopcont:	ADDQ.L	#1,($0034,SP)
	BRA.W	.loop3

.loop3out:	TST.W	($0038,SP)
	BNE.B	.allout
	SUBA.L	A5,A5

.allout:	MOVE.L	A5,D0
.end:	MOVEM.L	(SP)+,D2/D3/D5-D7/A3-A5
	ADDA.W	#$001C,SP
	RTS

; -----------------------------------------------------------------------------
	XDEF	_AllocMMUPages
_AllocMMUPages:
	MOVEM.L	D5-D7/A4-A6,-(SP)
	MOVE.L	D1,D6
	MOVE.L	D0,D7
	MOVEA.L	A0,A5

	MOVE.L	A5,D0
	BEQ.B	.addedpages

	MOVE.L	D7,D0
	ANDI.W	#$F000,D0
	LSR.L	#8,D0
	LSR.L	#4,D0
	MOVE.L	D0,D7

	MOVE.L	D6,D0
	ADDI.L	#$00000FFE,D0
	ANDI.W	#$F000,D0
	LSR.L	#8,D0
	LSR.L	#4,D0
	MOVE.L	D0,D6

	MOVE.L	D6,D0
	SUB.L	D7,D0
	MOVE.L	D0,D5

	ADDQ.L	#1,D5

	MOVE.L	D5,D0
	ADD.L	D0,D0

	MOVEQ	#16,D1

	ADD.L	D1,D0
	MOVE.L	#(MEMF_PUBLIC|MEMF_CLEAR),D1
	MOVEA.L	(4).W,A6
	JSR	(_LVOAllocVec,A6)
	MOVEA.L	D0,A4

	MOVE.L	A4,D0
	BEQ.B	.nomem
	MOVE.L	D7,(8,A4)
	MOVE.L	D6,(12,A4)
	LEA	($0030,A5),A0
	MOVEA.L	A4,A1
	JSR	(_LVOAddTail,A6)
	BRA.B	.addedpages

.nomem:	SUBA.L	A5,A5
.addedpages:	MOVE.L	A5,D0
	MOVEM.L	(SP)+,D5-D7/A4-A6
	RTS

; --------------------------------------------------------------------------
	XDEF	__SetRomAddress
__SetRomAddress:
	MOVEM.L	D6/D7/A3-A6,-(SP)
	MOVE.L	A0,D7
	MOVEA.L	A6,A5

	CLR.L	-(SP)
	MOVEA.L	($0034,A5),A0
	MOVE.L	#$00F80000,D0
	MOVEQ	#8,D1
	SWAP	D1
	BSR.W	_SetMMUPageMode
	MOVEA.L	D0,A3

	ADDQ.W	#4,SP
	MOVE.L	A3,D0
	BEQ.B	.stdrom

	CMPI.L	#$00F80000,D7
	BEQ.B	.stdrom

	MOVEQ	#$7C,D6
	LSL.L	#5,D6
	MOVEA.L	(4).W,A6
	JSR	(_LVODisable,A6)

.loop:	CMPI.L	#$00000FFF,D6
	BHI.B	.loopend
	MOVE.L	D6,D0
	LSR.L	#8,D0
	LSR.L	#5,D0
	MOVEA.L	(12,A3),A0
	LEA	(A0,D0.L*4),A1
	MOVE.L	(A1),D0
	ANDI.W	#$FE00,D0
	MOVEA.L	D0,A4
	MOVE.L	D6,D0
	LSR.L	#6,D0
	MOVEQ	#$7F,D1
	AND.L	D1,D0
	MOVE.L	(A4,D0.L*4),D1
	ANDI.W	#$FE00,D1
	MOVEA.L	D1,A4
	MOVE.L	D6,D0
	MOVEQ	#$3F,D1
	AND.L	D1,D0
	MOVE.L	D7,D1
	ORI.W	#1,D1
	MOVE.L	D1,(A4,D0.L*4)
	ADDQ.L	#1,D6
	ADDI.L	#$00001000,D7
	BRA.B	.loop

.loopend:	MOVEA.L	(4).W,A6
	JSR	(_LVOEnable,A6)

.stdrom:	MOVE.L	A3,D0
	MOVEM.L	(SP)+,D6/D7/A3-A6
	RTS

; --------------------------------------------------------------------------
	XDEF	@Map_PatchArea
@Map_PatchArea:
	MOVEM.L	D6/D7/A3-A5,-(SP)
	MOVEA.L	A1,A4
	MOVEA.L	A0,A5
	MOVEA.L	A4,A0
	MOVE.L	#$00008000,D0
	BSR.W	_AllocPatchPage

	MOVE.L	D0,D6
	TST.L	D6
	BEQ.B	.endloop
	MOVE.L	D6,($006E,A5)

	CLR.L	-(SP)
	MOVEA.L	A4,A0
	MOVE.L	#$FFFF8000,D0
	MOVE.L	#$00008000,D1
	BSR.W	_SetMMUPageMode
	MOVEA.L	D0,A4

	ADDQ.W	#4,SP
	MOVE.L	A4,D0
	BEQ.B	.endloop

	MOVE.L	#$000FFFF8,D7

.loop:	CMPI.L	#$00100000,D7
	BEQ.B	.endloop
	MOVE.L	D7,D0
	LSR.L	#8,D0
	LSR.L	#5,D0
	MOVEA.L	(12,A4),A0
	LEA	(A0,D0.L*4),A1
	MOVE.L	(A1),D0
	ANDI.W	#$FE00,D0
	MOVEA.L	D0,A3
	MOVE.L	D7,D0
	LSR.L	#6,D0
	MOVEQ	#$7F,D1
	AND.L	D1,D0
	MOVE.L	(A3,D0.L*4),D1
	ANDI.W	#$FE00,D1
	MOVEA.L	D1,A3
	MOVE.L	D7,D0
	MOVEQ	#$3F,D1
	AND.L	D1,D0
	MOVE.L	D6,D1
	ORI.W	#$0020,D1
	ORI.W	#1,D1
	MOVE.L	D1,(A3,D0.L*4)
	ADDQ.L	#1,D7
	ADDI.L	#$00001000,D6
	BRA.B	.loop

.endloop:	MOVE.L	A4,D0
	MOVEM.L	(SP)+,D6/D7/A3-A5
	RTS

; -----------------------------------------------------------------------------
	XDEF	_SetupMMUFrame
_SetupMMUFrame:
	MOVEM.L	D6/D7/A5/A6,-(SP)

	MOVEQ	#0,D6	;rc

	MOVEQ	#$54,D0	;alloc MMUFrame
	MOVE.L	#(MEMF_PUBLIC|MEMF_CLEAR),D1
	MOVEA.L	(4).W,A6
	JSR	(_LVOAllocVec,A6)
	MOVEA.L	D0,A5

	MOVE.L	A5,D0
	BEQ.W	.nomem

	LEA	($0030,A5),A0
	MOVE.L	A0,($0038,A5)	;newlist LIST MMUSegMents
	CLR.L	($0034,A5)
	LEA	($0034,A5),A0
	MOVE.L	A0,($0030,A5)

	CLR.L	($003C,A5)
	CLR.L	($0040,A5)
	CLR.L	($0044,A5)
	CLR.L	($0048,A5)
	MOVEQ	#-1,D0
	MOVE.L	D0,($004C,A5)
	CLR.L	($0050,A5)

	MOVEA.L	A5,A0	;a0=mmuframe
	MOVEQ	#$40,D0	;40 << 3 = $200
	LSL.L	#3,D0
	MOVE.L	#$000001FF,D1	;d1=512-1
	BSR.W	_SetupRootPage
	MOVE.L	D0,(12,A5)

	MOVEA.L	A5,A0
	MOVEQ	#$40,D0	;d0=$200
	LSL.L	#3,D0
	MOVE.L	#$000001FF,D1
	BSR.W	_SetupRootPage
	MOVE.L	D0,($0010,A5)

	MOVEA.L	A5,A0
	MOVEQ	#$40,D0	;d0=$100
	LSL.L	#2,D0
	MOVE.L	#$000001FF,D1
	BSR.W	_SetupRootPage
	MOVE.L	D0,($0014,A5)

	MOVEA.L	A5,A0
	MOVEQ	#$40,D0	;d0=40<<6=$1000
	LSL.L	#6,D0
	MOVE.L	#$00000FFF,D1
	BSR.W	_SetupRootPage
	MOVE.L	D0,($001C,A5)

	TST.L	(12,A5)
	BEQ.W	.nomem
	TST.L	($0010,A5)
	BEQ.W	.nomem
	TST.L	($0014,A5)
	BEQ.W	.nomem
	TST.L	D0
	BEQ.W	.nomem

	ORI.W	#$0040,D0
	ORI.W	#1,D0
	MOVE.L	D0,($0018,A5)

	LEA	($0018,A5),A0
	MOVE.L	A0,D0
	ORI.W	#2,D0
	MOVE.L	D0,($002C,A5)

	MOVE.L	($0014,A5),D0
	ORI.W	#3,D0
	MOVE.L	D0,($0028,A5)

	MOVE.L	($0010,A5),D0
	ORI.W	#3,D0
	MOVE.L	D0,($0024,A5)

	MOVEQ	#0,D7
.loop0:	MOVEQ	#64,D0
	CMP.L	D0,D7
	BCC.B	.endloop
	MOVEA.L	($0014,A5),A0
	LEA	(A0,D7.L*4),A1
	MOVE.L	($002C,A5),(A1)
	ADDQ.L	#1,D7
	BRA.B	.loop0

.endloop:	MOVEQ	#0,D7
.loop:	MOVEQ	#64,D0
	ADD.L	D0,D0
	CMP.L	D0,D7
	BCC.B	.loopstart2
	MOVEA.L	($0010,A5),A0
	LEA	(A0,D7.L*4),A1
	MOVE.L	($0028,A5),(A1)
	ADDQ.L	#1,D7
	BRA.B	.loop

.loopstart2:	MOVEQ	#0,D7
.loop2:	MOVEQ	#64,D0
	ADD.L	D0,D0
	CMP.L	D0,D7
	BCC.B	.endloop2
	MOVEA.L	(12,A5),A0
	LEA	(A0,D7.L*4),A1
	MOVE.L	($0024,A5),(A1)
	ADDQ.L	#1,D7
	BRA.B	.loop2

.endloop2:	MOVE.L	#$00008008,(8,A5)
	MOVE.L	(12,A5),D0
	MOVE.L	D0,(A5)
	MOVE.L	(12,A5),D0
	MOVE.L	D0,(4,A5)
	MOVEQ	#1,D6
	MOVE.L	(12,A5),D0

	PEA	($60).W
	MOVEA.L	A5,A0
	MOVEQ	#$40,D1
	LSL.L	#3,D1
	BSR.W	_SetMMUPageMode

	MOVEA.L	D0,A5
	MOVE.L	($0010,A5),D0
	PEA	($60).W
	MOVEA.L	A5,A0
	MOVEQ	#$40,D1
	LSL.L	#3,D1
	BSR.W	_SetMMUPageMode

	MOVEA.L	D0,A5
	MOVE.L	($0014,A5),D0
	PEA	($60).W
	MOVEA.L	A5,A0
	MOVEQ	#$40,D1
	LSL.L	#2,D1
	BSR.W	_SetMMUPageMode

	MOVEA.L	D0,A5
	MOVE.L	($001C,A5),D0
	PEA	($60).W
	MOVEA.L	A5,A0
	MOVEQ	#$40,D1
	LSL.L	#6,D1
	BSR.W	_SetMMUPageMode

	MOVEA.L	D0,A5
	LEA	($0010,SP),SP
.nomem:	TST.W	D6
	BNE.B	.nofail
	SUBA.L	A5,A5
.nofail:	MOVE.L	A5,D0
	MOVEM.L	(SP)+,D6/D7/A5/A6
	RTS

; --------------------------------------------------------------------------
	XDEF	__SetIllegalPageValue
__SetIllegalPageValue:
	MOVEM.L	D5-D7/A2/A5/A6,-(SP)
	MOVE.L	D0,D7
	MOVEA.L	A6,A5

	MOVEA.L	($0034,A5),A0
	MOVEA.L	($001C,A0),A1
	MOVE.L	(A1),D5
	MOVEQ	#0,D6

.loop:	CMPI.L	#$00000400,D6
	BGE.B	.loopend

	MOVEA.L	($0034,A5),A0
	MOVEA.L	($001C,A0),A1
	LEA	(A1,D6.L*4),A2
	MOVE.L	D7,(A2)
	ADDQ.L	#1,D6
	BRA.B	.loop

.loopend:	MOVE.L	D5,D0
	MOVEM.L	(SP)+,D5-D7/A2/A5/A6
	RTS

; --------------------------------------------------------------------------

	XDEF	__GetIllegalPage
__GetIllegalPage:
	MOVEM.L	A5/A6,-(SP)
	MOVEA.L	A6,A5
	MOVEA.L	($0034,A5),A0
	MOVEA.L	($001C,A0),A1
	MOVE.L	A1,D0
	MOVEM.L	(SP)+,A5/A6
	RTS

; --------------------------------------------------------------------------

	XDEF	__SetIllegalPageMode
__SetIllegalPageMode:
	MOVEM.L	D6/D7/A5/A6,-(SP)
	MOVE.L	D0,D7
	MOVEA.L	A6,A5

	MOVEA.L	($0034,A5),A0
	MOVE.L	($0018,A0),D6
	TST.W	D7
	BEQ.B	.false

	MOVE.L	D6,D0
	ANDI.W	#$FFFC,D0
	MOVE.L	D0,($0018,A0)
	BRA.B	.doit

.false:	MOVE.L	D6,D0
	ANDI.W	#$FFFC,D0
	ORI.W	#1,D0
	MOVE.L	D0,($0018,A0)

.doit:	MOVEA.L	($0034,A5),A0
	LEA	($0018,A0),A1
	MOVEA.L	A1,A0
	MOVEA.L	A5,A6
	JSR	(-$0042,A6)
	MOVE.L	D6,D0
	MOVEM.L	(SP)+,D6/D7/A5/A6
	RTS

; --------------------------------------------------------------------------

	XDEF	__SetZeroPageMode
__SetZeroPageMode:
	MOVEM.L	D6/D7/A5/A6,-(SP)
	MOVE.L	D0,D7
	MOVEA.L	A6,A5

	MOVEA.L	($0034,A5),A0
	MOVEA.L	($0020,A0),A1
	MOVE.L	(A1),D6
	MOVE.L	D7,D0
	TST.L	D0
	BEQ.B	.case0
	SUBQ.L	#1,D0
	BEQ.B	.case1
	SUBQ.L	#1,D0
	BEQ.B	.case3
	BRA.B	.default

.case0:	MOVEA.L	($0034,A5),A0
	MOVEA.L	($0020,A0),A1
	MOVEQ	#$41,D0
	MOVE.L	D0,(A1)
	BRA.B	.default

.case1:	MOVEA.L	($0034,A5),A0
	MOVEA.L	($0020,A0),A1
	MOVE.L	($0018,A0),D0
	ANDI.W	#$FFFC,D0
	ORI.W	#$0040,D0
	MOVE.L	D0,(A1)
	BRA.B	.default

.case3:	MOVEA.L	($0034,A5),A0
	MOVEA.L	($0020,A0),A1
	MOVE.L	($0018,A0),D0
	ANDI.W	#$FFFC,D0
	ORI.W	#1,D0
	ORI.W	#$0040,D0
	MOVE.L	D0,(A1)

.default:	MOVEA.L	($0034,A5),A0
	MOVEA.L	($0020,A0),A1
	MOVEA.L	A1,A0
	MOVEA.L	A5,A6
	JSR	(-$0042,A6)
	MOVE.L	D6,D0
	MOVEM.L	(SP)+,D6/D7/A5/A6
	RTS

; --------------------------------------------------------------------------

	XDEF	__SetPageProtectMode
__SetPageProtectMode:
	SUBA.W	#$0018,SP
	MOVEM.L	D2-D7/A2/A4-A6,-(SP)
	MOVE.L	D1,D5
	MOVE.L	D0,D6
	MOVE.L	A1,D7
	MOVEA.L	A6,A5

	MOVE.L	D7,D0
	LSR.L	#8,D0
	LSR.L	#4,D0

	MOVE.L	D7,D1
	ADD.L	D6,D1
	SUBQ.L	#1,D1
	LSR.L	#8,D1
	LSR.L	#4,D1

	MOVE.L	D0,($003C,SP)
	MOVE.L	D1,($0038,SP)

.loop:	MOVE.L	($003C,SP),D0
	CMP.L	($0038,SP),D0
	BHI.B	.loopout
	MOVE.L	D0,D1
	LSR.L	#8,D1
	LSR.L	#5,D1
	MOVE.L	D0,D2
	LSR.L	#6,D2
	MOVEQ	#$7F,D3
	AND.L	D3,D2
	MOVEQ	#$3F,D3
	AND.L	D0,D3
	MOVEA.L	($0034,A5),A0
	MOVEA.L	(12,A0),A1
	LEA	(A1,D1.L*4),A2
	MOVE.L	(A2),D4
	ANDI.W	#$FE00,D4
	MOVEA.L	D4,A4
	MOVE.L	(A4,D2.L*4),D4
	ANDI.W	#$FE00,D4
	MOVEA.L	D4,A4
	MOVE.L	(A4,D3.L*4),($0034,SP)
	MOVE.L	D1,($0030,SP)
	MOVE.L	D2,($002C,SP)
	MOVE.L	D3,($0028,SP)
	TST.W	D5
	BEQ.B	.skip
	MOVE.L	(A4,D3.L*4),D1
	ORI.W	#4,D1
	MOVE.L	D1,(A4,D3.L*4)
	BRA.B	.loopcont

.skip:	MOVEQ	#$3F,D1
	AND.L	D0,D1
	MOVE.L	(A4,D1.L*4),D2
	ANDI.W	#$FFFB,D2
	MOVE.L	D2,(A4,D1.L*4)
.loopcont:	ADDQ.L	#1,($003C,SP)
	BRA.B	.loop

.loopout:	MOVE.L	($0034,SP),D0
	MOVEM.L	(SP)+,D2-D7/A2/A4-A6
	ADDA.W	#$0018,SP
	RTS

; --------------------------------------------------------------------------

	XDEF	__BuildMMUTables
__BuildMMUTables:
	SUBQ.W	#4,SP
	MOVEM.L	D7/A2-A6,-(SP)

	MOVEA.L	A6,A5
	MOVEA.L	(4).W,A6
	JSR	(_LVOForbid,A6)

	BSR.W	_SetupMMUFrame
	MOVEA.L	D0,A3

	PEA	($40).W
	MOVEA.L	A3,A0
	MOVE.L	#$00BC0000,D0
	MOVEQ	#4,D1
	SWAP	D1
	BSR.W	_SetMMUPageMode

	MOVEA.L	D0,A3
	PEA	($40).W
	MOVEA.L	A3,A0
	MOVE.L	#$00D80000,D0
	MOVEQ	#8,D1
	SWAP	D1
	BSR.W	_SetMMUPageMode

	MOVEA.L	D0,A3
	CLR.L	(SP)
	MOVEA.L	A3,A0
	MOVE.L	#$00F00000,D0
	MOVEQ	#$10,D1
	SWAP	D1
	BSR.W	_SetMMUPageMode

	MOVEA.L	D0,A3
	ADDQ.W	#8,SP
	MOVEA.L	($0038,A5),A1
	JSR	(_LVOOpenResource,A6)
	TST.L	D0
	BEQ.B	.noresource

	PEA	($40).W
	MOVEA.L	A3,A0
	MOVEQ	#$60,D0
	SWAP	D0
	MOVE.L	#$00440002,D1
	BSR.W	_SetMMUPageMode

	MOVEA.L	D0,A3
	ADDQ.W	#4,SP
.noresource:	MOVEA.L	($003C,A5),A1
	JSR	(_LVOFindResident,A6)
	TST.L	D0
	BEQ.B	.noresident

	PEA	($40).W
	MOVEA.L	A3,A0
	MOVE.L	#$00E00000,D0
	MOVEQ	#8,D1
	SWAP	D1
	BSR.W	_SetMMUPageMode
	MOVEA.L	D0,A3
	ADDQ.W	#4,SP

.noresident:	MOVEA.W	#4,A0
	MOVEA.L	(A0),A1
	MOVE.L	(10,A1),D0
	CLR.W	D0
	SWAP	D0
	MOVEQ	#$20,D1
	CMP.L	D1,D0
	BNE.B	.wrongresver

	CLR.L	-(SP)
	MOVEA.L	A3,A0
	MOVEQ	#$20,D0
	SWAP	D0
	MOVEQ	#8,D1
	SWAP	D1
	BSR.W	_SetMMUPageMode
	MOVEA.L	D0,A3
	ADDQ.W	#4,SP

.wrongresver:	PEA	($40).W
	MOVEA.L	A3,A0
	MOVEQ	#0,D0
	MOVEQ	#$40,D1
	LSL.L	#6,D1
	BSR.W	_SetMMUPageMode

	MOVEA.L	D0,A3
	ADDQ.W	#4,SP
	JSR	(_LVOForbid,A6)

	MOVEA.W	#4,A0
	MOVEA.L	(A0),A1
	MOVEA.L	(MemList,A1),A2
.setup_mem_loop:	TST.L	(LN_SUCC,A2)
	BEQ.B	.endofmemlist
	MOVEA.L	(MH_LOWER,A2),A1
	MOVEA.L	(4).W,A6
	JSR	(_LVOTypeOfMem,A6)
	BTST	#MEMF_PUBLIC,D0
	BEQ.B	.ispubmem
	MOVEQ	#$40,D7
	BRA.B	.isnotpubmem

.ispubmem:	MOVEQ	#$20,D7
.isnotpubmem:	MOVE.L	(MH_LOWER,A2),D0
	MOVE.L	(MH_UPPER,A2),D1
	SUB.L	D0,D1
	MOVE.L	D7,-(SP)
	MOVEA.L	A3,A0
	BSR.W	_SetMMUPageMode

	MOVEA.L	D0,A3
	ADDQ.W	#4,SP
	MOVEQ	#$20,D0
	CMP.L	D0,D7
	BNE.B	.waspublic
	MOVE.L	(MH_LOWER,A2),D0
	MOVE.L	(MH_UPPER,A2),D1
	MOVEA.L	A3,A0
	BSR.W	_AllocMMUPages

	MOVEA.L	D0,A3
.waspublic:	MOVEA.L	A2,A0
	MOVEA.L	(LN_SUCC,A0),A2
	BRA.B	.setup_mem_loop

.endofmemlist:	MOVEA.L	(4).W,A6
	JSR	(_LVOPermit,A6)

	MOVEA.L	($0040,A5),A1
	MOVEQ	#0,D0
	JSR	(_LVOOpenLibrary,A6)
	MOVEA.L	D0,A4

	MOVE.L	A4,D0
	BEQ.B	.nolib

	CLR.L	($0018,SP)
.reinit:	MOVEA.L	($0018,SP),A0
	MOVEQ	#-1,D0
	MOVE.L	D0,D1
	MOVEA.L	A4,A6
	JSR	(-$0048,A6)
	MOVE.L	D0,($0018,SP)
	BEQ.B	.initfailed

	MOVEA.L	D0,A0
	BTST	#5,($0010,A0)
	BNE.B	.reinit

	MOVE.L	($0020,A0),D1
	PEA	($40).W
	MOVE.L	D1,D0
	MOVE.L	($0024,A0),D1
	MOVEA.L	A3,A0
	BSR.W	_SetMMUPageMode
	MOVEA.L	D0,A3
	ADDQ.W	#4,SP
	BRA.B	.reinit

.initfailed:	MOVEA.L	A4,A1
	MOVEA.L	(4).W,A6
	JSR	(_LVOCloseLibrary,A6)

.nolib:	MOVEA.L	A5,A0
	MOVEA.L	A3,A1
	BSR.W	@Map_PatchArea

	MOVEA.L	(4).W,A6
	JSR	(_LVOPermit,A6)
	MOVE.L	A3,D0
	MOVEM.L	(SP)+,D7/A2-A6
	ADDQ.W	#4,SP
	RTS

	end
