	.export		exit

	.import		_main
	.import		NMI_main
	.import		IRQ_main

	.import		ppudrv_init
	.import		Bank_Change_Prg
	
	; Linker generated symbols
	.import		__STACK_START__,	__STACK_SIZE__

	.include	"drv.inc"


; ------------------------------------------------------------------------
; Place the startup code in a special segment.

.segment	"STARTUP"

.byte	"DRFM  "

start:

	sei
	cld

	DISP_OFF


;===============================
;	メモリ初期化
;===============================
Clear_Memory:

	lda	#0
	ldx	#<(__STACK_START__ + __STACK_SIZE__ - 1)
	txs
	tax
@L0:
	sta	$0000,x
;	sta	$0100,x
;	sta	$0200,x
;	sta	$0300,x
;	sta	$0400,x
;	sta	$0500,x
;	sta	$0600,x
;	sta	$0700,x

	inx
	bne	@L0

;===============================
;	サウンド初期化
;===============================
;Sound_Init:

	lda	#$40
	sta	$4017

;===============================
;	画面初期化
;===============================
;Disp_Init:

	; Call initialize PPU
	jsr	_ppu_init

;===============================
;	メインルーチン呼出し
;===============================
; Push arguments and call main()

	jsr	_main

; Call module destructors. This is also the _exit entry.

exit:

; Reset the NES

	jmp	start

; ------------------------------------------------------------------------
; Init PPU
; ------------------------------------------------------------------------
.proc	_ppu_init

	;---------------
	; PPU Control
	lda	#%10101000		;V-Blank NMI: enable
	sta	$2000

	lda	#%00011110
	sta	$2001

	;---------------
	; Wait for vblank
@wait:	lda	$2002
	bpl	@wait

	;---------------
	; reset scrolling
	lda	#0
	sta	$2005
	sta	$2005

	;---------------
	; Make all sprites invisible
	lda	#$00
	ldy	#$f0
	sta	$2003
	ldx	#$40
@loop:	sty	$2007
	sta	$2007
	sta	$2007
	sty	$2007
	dex
	bne	@loop

	rts

.endproc

; ------------------------------------------------------------------------
; hardware vectors
; ------------------------------------------------------------------------

.segment "VECTORS"

	.word	NMI_main	; $fffa vblank nmi
	.word	start		; $fffc reset
	.word	IRQ_main	; $fffe irq / brk
