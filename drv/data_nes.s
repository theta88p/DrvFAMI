.export BGM0
.export DPCMinfo
.export palette

.segment "MUSDATA"

BGM0:
	.byte	"SEQ"
	;.incbin "test.bin"

.segment "PCMDATA"

DPCMinfo:
	.byte	"DPCM"
	;.incbin "C:\Programs\mck\Mumml\prog\dmc\909kick3_v60.dmc"
	;.incbin	"C:\Programs\mck\Mumml\prog\dmc\tight909kick_v60.dmc"
	;.incbin "C:\Programs\mck\Mumml\prog\dmc\cowbell.dmc"

; パレット
.segment "RODATA"
palette:
	.byte	$0F, $0C, $1C, $30
	.byte	$0F, $05, $00, $30
	.byte	$0F, $0C, $05, $30
	.byte	$0F, $13, $36, $30

	.byte	$0F, $0C, $15, $25
	.byte	$0F, $0C, $1C, $30
	.byte	$0F, $27, $27, $27
	.byte	$0F, $15, $25, $35

; パターンテーブル
.segment "CHARS"
	.incbin "bg.chr"
