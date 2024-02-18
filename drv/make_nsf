#==============================================================================
#	NES Sound Driver Libraly
#		Make file
#				A.Waranabe (S.W.)
#==============================================================================

TOOL_PASS =	
INC_PASS = 
LIB_PASS =

########################################
#;	LOG files
########################################

LOG_FILE    =	comlog.txt		#各コマンドの標準出力先です。
ERRLOG_FILE =	errlog.txt		#各コマンドのエラー出力先です。
BLDLOG_FILE =	buildlog.txt		#make.exeの出力先です。



########################################
#;	Define of build tools & option
########################################

#---------------
#;  MML Compiler (for Music & SE data)
MC      = $(TOOL_PASS)nsc
MCFLAGS = -a -e

#---------------
#;  C Compiler
CC      = $(TOOL_PASS)cl65
CFLAGS  = -t none --listing $*.lst --list-bytes 255 -g -c -o

#---------------
#;  Assembler
AS      = $(TOOL_PASS)ca65
ASFLAGS = -t none --listing $*.lst --list-bytes 255 -g

#---------------
#;  Archiver
AR      = $(TOOL_PASS)ar65
ARFLAGS = a

#---------------
#;  Linker
LINKER  = $(TOOL_PASS)ld65
LDFLAGS = -C $(CFG_FILE) -L$(LIB_PASS) -v -m $(MAP_FILE) -vm --dbgfile $(DBG_FILE) -o

#---------------
#;  File delete
RM      = rm -f

#---------------
#;  File copy
CP      = copy



#===============================
#; 依存関係（ヘッダーファイル等を、依存関係に追加するために、定義）

%.o : %.s $(INC_FILES)			#;".inc"ファイルが更新された場合は、.sは、全部アセンブルする。
	@echo [Assemble] : $< >>$(ERRLOG_FILE)
	$(AS) $(ASFLAGS) $< 1>>$(LOG_FILE) 2>>$(ERRLOG_FILE)


%.o : %.c $(H_FILES)			#;".h"ファイルが更新された場合は、.cは、全部コンパイルする。
	@echo [Compile] : $< >>$(ERRLOG_FILE)
	$(CC)  $(CFLAGS) $*.o $< 1>>$(LOG_FILE) 2>>$(ERRLOG_FILE)


%.s : %.mml $(DMC_FILES)		#;".dmc"ファイルが更新された場合は、.mmlは、全部コンパイルする。
	@echo ======================================================== >>$(LOG_FILE)
	@echo [Compile] : $< >>$(LOG_FILE)
	@echo ======================================================== >>$(LOG_FILE)
	@echo [Compile] : $< >>$(ERRLOG_FILE)
	$(MC) $(MCFLAGS) $< 1>>$(LOG_FILE) 2>>$(ERRLOG_FILE)

%.s : %.bmp
	


########################################
#;	Siurce files
########################################
#;
#;	ソース追加時は、ファイル名を追加してください。
#;	それだけで、プロジェクトに追加されます。
#;

#---------------
#; プロジェクト名
MAIN_PROJ  =	test.nes

#---------------
#; リンカーの設定
CFG_FILE   =	nsf.cfg
MAP_FILE   =	test.map
DBG_FILE   =	test.dbg

#---------------
#; ソースファイル
MAIN_FILES =	nsf.o			\
		crt0.o			\
		nmi_main.o		\
		irq_main.o		\
		main_nsf.o			\
		drv.o			\
		data_nsf.o			\

CHR_FILRS  =

MML_FILES  =


#---------------------------------------
#;	Header files
#---------------------------------------
#;
#;	ビルドに依存するヘッダーファイルは、ここに書いてください。
#;

#---------------
#; アセンブリ言語用ヘッダー
INC_FILES =	drv.inc		\

#---------------
#; Ｃ言語用ヘッダー
H_FILES  =	

#---------------
#; ⊿ＰＣＭファイル
DMC_FILES =	




#---------------------------------------
#;	Library files
#---------------------------------------
#;
#;	ビルドに依存するライブラリファイルは、ここに書いてください。
#;

LIB_FILES =	



########################################
#;	Build process
########################################

.PHONY: all clean

#---------------
#; Default Target（ここに、ビルドするプロジェクトの一覧を記述する。）
all: $(MAIN_PROJ)


#---------------
#; build of main program
$(MAIN_PROJ) : $(MAIN_FILES) $(CHR_FILES) $(MML_FILES) $(LIB_FILES)
	@echo [Link] : $@ >>$(ERRLOG_FILE)
	$(LINKER) $(LDFLAGS) $@ $^ 1>>$(LOG_FILE) 2>>$(ERRLOG_FILE)


#---------------
#; Crean up
clean:
#	@$(RM) *.nes		#NESファイルは、消さないでおく。
	@$(RM) *.bak
	@$(RM) *.map
	@$(RM) *.lst
	@$(RM) *.o

	@$(RM) $(LOG_FILE)
	@$(RM) $(ERRLOG_FILE)
	@$(RM) $(BLDLOG_FILE)
