#includes
-include $(ROOT_DIR)/build/make/platforms/superplatforms/unix.mak

###Universal tools
MKDIR = test -e $(dir $@) || mkdir -p $(dir $@)
DELETE = rm -f

ifeq ($(MULTITHREADED),1)
ifneq ($(HPOLDMODE),1)
#actually, as of TRW405, even in regular mode
#we don't support multithreading on HPUX, as you can't
#reliably mix threaded libraries with unthreaded code,
#and cache.exe will be unthreaded
#TOOL += -mt 
endif
endif

PLATCFLAGS = -Ae +DD64
PLATCXXFLAGS = -AA +DD64 -D_INCLUDE_LONGLONG -D_INCLUDE__STDC_A1_SOURCE
PLATLDFLAGS = +DD64

###Stage 1: Source->Objects
CPP_COMPILER = aCC
C_COMPILER = cc
HEADERINCLUDEFLAG = -I
OBJECTOUTPUTFLAG = -o
OBJECTSUFFIX = .o
ifdef HPOLDMODE
OBJECTFLAGS += -Ae -c -O2 -DUNIX -DHPUX11 -D_HPUX_SOURCE $(if $(CREATELIBRARY), +z)  -DITANIUM
else
OBJECTFLAGS += $(PLATCXXFLAGS) -c -O2 -DMY_BIG_ENDIAN=1 -D_ISC_BIGENDIAN=1 -DHP  -DBIT64PLAT -DSIZEOF_LONG=8 -DITANIUM -DUNIX $(if $(CREATELIBRARY), +Z)
endif



###Stage 2a: Objects->Library
ifdef HPOLDMODE
LIBRARIAN = ld
else
LIBRARIAN = aCC
endif
LIBRARYDIRFLAG = -L
LIBRARYSEARCHFLAG = -l
ifdef HPOLDMODE
LIBRARYFLAGS += -b
ifeq ($(MULTITHREADED),1)
LIBRARYFLAGS += -lpthread
endif
LIBRARYSUFFIX = .so
else
LIBRARYFLAGS += $(PLATLDFLAGS) -DBIT64PLAT -DSIZEOF_LONG=8 -DITANIUM -lstd_v2 -lCsup -lunwind -b
LIBRARYSUFFIX ?= .sl
endif
ifdef CACHE_LOADED
LIBRARYSUFFIX = .so
endif
LIBRARYOUTPUTFLAG = -o



###Stage 2b: Objects->Executable
LINKER = aCC
EXECUTABLEDIRFLAG = -L
EXECUTABLESEARCHFLAG = -l
ifdef HPOLDMODE
EXECUTABLEFLAGS += -Ae
ifeq ($(MULTITHREADED),1)
EXECUTABLEFLAGS += -lpthread
endif
else
EXECUTABLEFLAGS += +DD64 -AA -DBIT64PLAT -DSIZEOF_LONG=8 -DITANIUM -lstd_v2 -lCsup -lunwind
endif
RUNTIMELOADPATHVAR = LD_LIBRARY_PATH
EXECUTABLEOUTPUTFLAG = -o
EXECUTABLESUFFIX = 


ifeq ($(HIDE_SYMBOLS),1)
LIBRARYFLAGS += -Wl,-B,symbolic
EXECUTABLEFLAGS += -Wl,-B,symbolic
endif



#Thirdparty definitions
PLAT_OPENSSL_CONFIGURE_OPTIONS = hpux64-ia64-cc
PLAT_CMQL_CONFIGURE_OPTIONS = --enable-64bit
PLAT_ANTLR_CONFIGURE_OPTIONS = --enable-64bit
PLAT_OPENLDAP_AC_CFLAGS = -O +DD64
RUN_CONFIGURE_ICU_PARAMS = HP-UX/ACC --enable-threads=no
PLAT_XERCES_CONFIGURE_OPTIONS = CC=cc CXX=aCC CXXFLAGS="+DD64 +Z +p -AA" LDFLAGS="+DD64 -lstd_v2 -lCsup" CFLAGS="+DD64 +Z +p -Ae"
RUN_CONFIGURE_XERCES_PARAMS = -p hp-11 -c cc -x aCC -minmem -ticu -r none -b64 -z -AA -z +DD64 -z +Z -z +p -l +DD64 -l -lstd_v2 -l -lCsup -z -D_INCLUDE__STDC_A1_SOURCE
RUN_CONFIGURE_XALAN_PARAMS = -p hp-11 -c cc -x aCC -minmem -ticu -b64  -z -AA -z +DD64 -z +Z -z +p -l +DD64 -l -lstd_v2 -l -lCsup -z +d -r none
SHARED_LIB_VAR = LD_LIBRARY_PATH

BUILD_THIRDPARTY = 1
PLATSOEXT=sl
CONFIG_PLAT_CFLAGS=+DD64
CONFIG_PLAT_LDFLAGS=+DD64 
PLAT_ALIGNMENT=+u1
PLAT_MQ_LIBRARIES = mqic
PLAT_MQ_LIBRARY_FLAGS = -Wl,+b,/opt/mqm/lib64
PLAT_MOD_CSP22_INC = hp11
PLAT_MOD_CSP22_OBJECTFLAGS = -Ae -DNET_SSL -D_HPUX_SOURCE -DMCC_HTTPD -DSPAPI20 -UHPUX
PLAT_MOD_CSP22_LIBRARYFLAGS = 
PLAT_ZLIB_OBJECTFLAGS += -c +DD64 -Ae $(if $(CREATELIBRARY), +Z)
PLAT_ZLIB_VERSION = 1.2.3
PLAT_LIBSSH2_OBJECTFLAGS += +DD64
PLAT_BJAM_OPTIONS = toolset=acc

#Debugging flags
ifeq ($(MODE),debug)
OBJECTFLAGS += -g0 -DDEBUG
LIBRARYFLAGS += -g0 -DDEBUG
EXECUTABLEFLAGS += -g0 -DDEBUG
RUN_CONFIGURE_ICU_PARAMS += --enable-debug
RUN_CONFIGURE_XERCES_PARAMS += -d
RUN_CONFIGURE_XALAN_PARAMS += -d
CONFIG_PLAT_CFLAGS+=-g0 -DDEBUG
CONFIG_PLAT_LDFLAGS+=-g0 -DDEBUG
endif