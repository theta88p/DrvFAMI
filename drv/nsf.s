.include	"drv.inc"

.segment	"HEADER"

	.byte	$4e,$45,$53,$4d,$1a,$01,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00
	.byte	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$41,$1a
	.byte	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
.ifdef MMC5
	.byte	$00,$00,$00,$00,$00,$00,$00,$08,$4e,$20,$00,$00,$00,$00,$00,$00
.else
	.byte	$00,$00,$00,$00,$00,$00,$00,$00,$4e,$20,$00,$00,$00,$00,$00,$00
.endif