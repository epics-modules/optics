TOP=../..

include $(TOP)/configure/CONFIG
#----------------------------------------
#  ADD MACRO DEFINITIONS AFTER THIS LINE
#=============================

#PROD_HOST += caExample
#caExample_SRCS	+= caExample.c
#caExample_LIBS	+= ca
#caExample_LIBS	+= Com
#ca_DIR           = $(EPICS_BASE_LIB)
#Com_DIR          = $(EPICS_BASE_LIB)


#=============================
# xxxRecord.h will be created from xxxRecord.dbd

DBDINC += tableRecord

# <name>.dbd will be created from <name>Include.dbd
DBD += optics.dbd
DBD += opticsSupport.dbd

#=============================

LIBRARY_IOC += optics


optics_SRCS += tableRecord.c

# <name>_registerRecordDeviceDriver.cpp will be created from <name>.dbd
optics_SRCS += optics_registerRecordDeviceDriver.cpp
#optics_SRCS_DEFAULT += opticsMain.cpp #maybe only for win32
#optics_SRCS_vxWorks += -nil- #?

#The following adds support from base/src/vxWorks
#optics_OBJS_vxWorks += $(EPICS_BASE_BIN)/vxComLibrary

### The following builds SNL programs as components of optics
# NOTE: for suffix .st, code is run through cpp; for .stt, it's not
optics_SRCS += kohzuCtl.st
optics_SRCS += hrCtl.st

# Pete Jemian's support for X-ray Instrumentation Associates
# HSC-1 slit controller (SNL program)
optics_SRCS   += xiahsc.st
# customized version that works with sscan record
optics_SRCS   += xia_slit.st

optics_LIBS += seq pv
seq_DIR    = $(SNCSEQ_LIB)
pv_DIR     = $(SNCSEQ_LIB)

#optics_LIBS += mpf gpib
optics_LIBS += $(EPICS_BASE_IOC_LIBS)


include $(TOP)/configure/RULES
#----------------------------------------
#  ADD RULES AFTER THIS LINE

