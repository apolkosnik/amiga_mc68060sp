
**-------------------------------------------------------------------------------
**  /\  |\     Silicon Department         Telefax             06404-64760
**  \_ o| \_ _  Software Entwicklung      Telefon             06404-7996
**    \|| |_)|)   Carsten Schlote         Oberstedter Str 1   35423 Lich
** \__/||_/\_|     Branko Miki�           Elisenstr 10        30451 Hannover
**-------------------------------------------------------------------------------
** ALL RIGHTS ON THIS SOURCES RESERVED TO SILICON DEPARTMENT SOFTWARE
**
** $Id: mc60_debug.i 1.4 1997/04/14 23:06:35 schlote Exp schlote $
**
**
** Assemble, then link lib:amiga.lib,lib:debug.lib
***-------------------------------------------------------------------------------
** Set MYDEBUG to != 0 for Debug output. Output if \1 <= MYDEBUG

	NOLIST
	INCLUDE	"exec/types.i"
	INCLUDE	"hardware/custom.i"
	LIST

MYDEBUG	SET	0
DEBUG_DETAIL 	set 	10


**-------------------------------------------------------------------------------
*
* Sample program calling DBUG macro
*
*	DBUG	x,template,...

**-------------------------------------------------------------------------------
* note - current 2.0 debug.lib has this entry

	XREF	KPrintF




**-------------------------------------------------------------------------------
* DBUG macro for format string and two variables
*	 preserves all registers
*        outputs to serial port   link with amiga.lib,debug.lib
* Usage: pass name of format string,value,value
*        values may be register name, variablename(PC), or #value
*
**-------------------------------------------------------------------------------
* The debugging macro DBUG
* Only generates code if MYDEBUG is > 0
*


DBUG	MACRO	* passed name of format string, with args on stack
	NOLIST

	IFGT	MYDEBUG
DBUG_LEVEL	SET         DEBUG_DETAIL-\1

	IFGE	DBUG_LEVEL
DBUG_STKCNT	SET	0		* Remember to pop stack

	movem.l 	d0-d1/a0-a1,-(sp)

	IFNC	'\9',''
	move.l	\9,-(sp)
DBUG_STKCNT	SET	DBUG_STKCNT+4
	ENDC

	IFNC	'\8',''
	move.l	\8,-(sp)
DBUG_STKCNT	SET	DBUG_STKCNT+4
	ENDC

	IFNC	'\7',''
	move.l	\7,-(sp)
DBUG_STKCNT	SET	DBUG_STKCNT+4
	ENDC

	IFNC	'\6',''
	move.l	\6,-(sp)
DBUG_STKCNT	SET	DBUG_STKCNT+4
	ENDC

	IFNC	'\5',''
	move.l	\5,-(sp)
DBUG_STKCNT	SET	DBUG_STKCNT+4
	ENDC

	IFNC	'\4',''
	move.l	\4,-(sp)
DBUG_STKCNT	SET	DBUG_STKCNT+4
	ENDC

	IFNC	'\3',''
	move.l	\3,-(sp)
DBUG_STKCNT	SET	DBUG_STKCNT+4
	ENDC

	lea.l	.PSS\@(pc),A0
	lea.l	(SP),A1

	XREF	KPrintF
	jsr	KPrintF
	lea.l	(DBUG_STKCNT,sp),sp
	movem.l 	(sp)+,d0-d1/a0-a1
	bra.w	.PSE\@
.PSS\@:
	dc.b	\2
	dc.b	0
                        even
.PSE\@:
	ENDC
	ENDC
	LIST
	ENDM


**-------------------------------------------------------------

