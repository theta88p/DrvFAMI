
	.export		NMI_main
	.import		drv_main
	
	.import		__cc
	.import		__ss
	.import		__mm
	.import		__hh


.segment	"LOWCODE"

.proc	NMI_main

;---------------------------------------
;register push
;---------------------------------------
	pha
	tya
	pha
	txa
	pha

;---------------------------------------
; Call sound driver main routine
;---------------------------------------

	jsr	drv_main

;---------------------------------------
; Count-up
;---------------------------------------
Count:
@cc:
	inc	__cc
	lda	__cc
	cmp	#60
	bne	@exit
	lda	#0
	sta	__cc

@ss:
	ldx	__ss
	cpx	#$59
	beq	@ss_1
	inx
	stx	__ss
	txa
	and	#$0F
	cmp	#$0A
	bne	@exit
	txa
	clc
	adc	#6
	sta	__ss
	bne	@exit
@ss_1:
	lda	#0
	sta	__ss

@mm:
	ldx	__mm
	cpx	#$59
	beq	@mm_1
	inx
	stx	__mm
	txa
	and	#$0F
	cmp	#$0A
	bne	@exit
	txa
	clc
	adc	#6
	sta	__mm
	bne	@exit
@mm_1:
	lda	#0
	sta	__mm

@hh:
	inc	__hh

@exit:

;---------------------------------------
;register pop
;---------------------------------------
	pla
	tax
	pla
	tay
	pla

	rti
.endproc
