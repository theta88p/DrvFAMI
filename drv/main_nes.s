.export		_main
.export		_init
.export		_play

.importzp	sync
.import		drv_init
.import		drv_sndreq
.import		drv_main
.import		set_dpcm
.import		DPCMinfo
.import		BGM0
.import		dsp_init
.import		dsp_main

.include	"drv.inc"


; ------------------------------------------------------------------------
; play
; ------------------------------------------------------------------------

.rodata

;Address of D-PCM information
dpcm_info:	.addr	DPCMinfo

;Address of BGM Sequence
bgm_00:		.addr	BGM0

; ------------------------------------------------------------------------
; main
; ------------------------------------------------------------------------
.code

.proc	_main
		jsr _init

	Loop:
		lda sync
		beq Loop
		
		jsr dsp_main
		
		jmp	Loop
.endproc

.proc _init
	pha
	jsr dsp_init
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