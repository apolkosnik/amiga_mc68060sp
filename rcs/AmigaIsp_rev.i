;** $Revision Header *** Header built automatically - do not edit! ***********
;**
;** � Copyright Silicon Department
;**
;** File             : AmigaIsp_rev.i
;** Created on       : Dienstag, 08-Apr-97
;** Created by       : Carsten Schlote
;** Current revision : V 40.04
;**
;** Purpose
;** -------
;**   - Empty log message -
;**
;** Date        Author                 Comment
;** =========   ====================   ====================
;** 08-Apr-97    Carsten Schlote        - Empty log message -
;** 08-Apr-97    Carsten Schlote        --- Initial release ---
;**
;** $Revision Header ********************************************************
VERSION  EQU	40
REVISION EQU	4
DATE     MACRO
		dc.b	'08.04.97'
    ENDM
VERS     MACRO
		dc.b	'AmigaIsp 40.04'
    ENDM
VSTRING  MACRO
		dc.b	'AmigaIsp 40.04 (08.04.97)',13,10,0
    ENDM
VERSTAG  MACRO
		dc.b	0,'$VER: AmigaIsp 40.04 (08.04.97)',0
    ENDM
AUTHOR   MACRO
		dc.b	'Carsten Schlote'
    ENDM
PROJECT  MACRO
		dc.b	'AmigaIsp'
    ENDM
