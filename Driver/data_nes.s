.export BGM0
.export DPCMinfo
.export palette

.segment "MUSDATA"

BGM0:

.segment "PCMDATA"

DPCMinfo:

; パレット
.segment "RODATA"
palette:
	.byte	$0f, $0f, $15, $30
	.byte	$0f, $0c, $1c, $30
	.byte	$0f, $0c, $05, $30
	.byte	$0f, $13, $36, $30

	.byte	$0f, $0c, $15, $25
	.byte	$0f, $0c, $1c, $30
	.byte	$0f, $27, $27, $27
	.byte	$0f, $15, $25, $35

; パターンテーブル
.segment "CHARS"
	.incbin "bg.chr"
