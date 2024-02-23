MAKE_NSF = 1

TOOL_PASS =	
INC_PASS = 
LIB_PASS =

########################################
#;	LOG files
########################################

LOG_FILE    =	comlog.txt
ERRLOG_FILE =	errlog.txt
BLDLOG_FILE =	buildlog.txt



########################################
#;	Define of build tools & option
########################################

#---------------
#;  MML Compiler (for Music & SE data)
MC      = $(TOOL_PASS)
MCFLAGS =

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

%.s : %.mml $(DMC_FILES)		#;".dmc"ファイルが更新された場合は、.mmlは、全部コンパイルする。
	@echo ======================================================== >>$(LOG_FILE)
	@echo [Compile] : $< >>$(LOG_FILE)
	@echo ======================================================== >>$(LOG_FILE)
	@echo [Compile] : $< >>$(ERRLOG_FILE)
	$(MC) $(MCFLAGS) $< 1>>$(LOG_FILE) 2>>$(ERRLOG_FILE)



########################################
#;	Source files
########################################

#---------------
#; プロジェクト名
MAIN_PROJ  =	test.nes


ifdef MAKE_NSF

#---------------
#; リンカーの設定
CFG_FILE   =	nsf.cfg
MAP_FILE   =	test.map
DBG_FILE   =	test.dbg

#---------------
#; ソースファイル
MAIN_FILES =	nsf.o	\
		crt0_nsf.o		\
		main_nsf.o		\
		drv.o			\
		data_nsf.o		\

else

#---------------
#; リンカーの設定
CFG_FILE   =	nesa.cfg
MAP_FILE   =	test.map
DBG_FILE   =	test.dbg

#---------------
#; ソースファイル
MAIN_FILES =	ines.o	\
		crt0_nes.o		\
		nmi_main_nes.o	\
		irq_main.o		\
		main_nes.o		\
		drv.o			\
		data_nes.o		\
		
endif

CHR_FILRS  =

MML_FILES  =


#---------------------------------------
#;	Header files
#---------------------------------------

#---------------
#; アセンブリ言語用ヘッダー
INC_FILES =	drv.inc		\
			data.bin	\

#---------------
#; ⊿ＰＣＭファイル
DMC_FILES =	


#---------------------------------------
#;	Library files
#---------------------------------------

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
