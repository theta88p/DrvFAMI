
.export		NMI_main

.importzp	sync
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

	lda #0
	sta sync
	
	;スプライト転送
	lda #$07
	sta $4014
	jsr drv_main
	
	
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
	cpx	#59
	beq	@ss_1
	inx
	stx	__ss
	jmp @exit
@ss_1:
	lda	#0
	sta	__ss

@mm:
	ldx	__mm
	cpx	#59
	beq	@mm_1
	inx
	stx	__mm
	jmp	@exit
@mm_1:
	lda	#0
	sta	__mm

@hh:
	inc	__hh

@exit:

	lda #1
	sta sync

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
