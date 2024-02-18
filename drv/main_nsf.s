
	.export		_main
	.export		_init
	.export		_play
	
	.import		drv_init
	.import		drv_sndreq
	.import		drv_main
	.import		set_dpcm
	.import		_DPCMinfo
	.import		_BGM0
	
	.include	"drv.inc"


; ------------------------------------------------------------------------
; play
; ------------------------------------------------------------------------

.rodata

;Address of D-PCM information
dpcm_info:	.addr	_DPCMinfo

;Address of BGM Sequence
bgm_00:		.addr	_BGM0

; ------------------------------------------------------------------------
; main
; ------------------------------------------------------------------------
.code

.proc	_main

	jsr _init

;Wait_Next_Flame:
;	jmp	Wait_Next_Flame
	rts

.endproc

.proc _init
	pha
	jsr drv_init
	
	lda	dpcm_info
	ldx	dpcm_info + 1
	jsr	set_dpcm
	pla
	tay
	lda	bgm_00
	ldx	bgm_00 + 1
	jsr	drv_sndreq
.endproc

.proc	_play
	jmp	drv_main
.endproc