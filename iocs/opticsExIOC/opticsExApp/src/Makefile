TOP=../..
include $(TOP)/configure/CONFIG

PROD_NAME = opticsExApp
PROD_IOC = $(PROD_NAME)

DBD += $(PROD_NAME).dbd

$(PROD_NAME)_DBD += base.dbd

# Modules with cfg-deps support -- auto-discovered
$(PROD_NAME)_DBD += $(OPTICS_IOC_DBDS)
$(PROD_NAME)_DBD += $(CALC_IOC_DBDS)
$(PROD_NAME)_DBD += $(BUSY_IOC_DBDS)

# Modules without cfg-deps support -- direct listing
ifdef ASYN
$(PROD_NAME)_DBD += asyn.dbd
$(PROD_NAME)_DBD += drvAsynSerialPort.dbd
$(PROD_NAME)_DBD += drvAsynIPPort.dbd
endif

$(PROD_NAME)_SRCS += $(PROD_NAME)_registerRecordDeviceDriver.cpp
$(PROD_NAME)_SRCS_DEFAULT += $(PROD_NAME)Main.cpp
$(PROD_NAME)_SRCS_vxWorks += -nil-

# Modules with cfg-deps support
$(PROD_NAME)_LIBS += $(OPTICS_IOC_LIBS)
$(PROD_NAME)_LIBS += $(CALC_IOC_LIBS)
$(PROD_NAME)_LIBS += $(BUSY_IOC_LIBS)

# Modules without cfg-deps support
ifdef SNCSEQ
$(PROD_NAME)_LIBS += seq pv
endif

ifdef ASYN
$(PROD_NAME)_LIBS += asyn
endif

$(PROD_NAME)_LIBS += $(EPICS_BASE_IOC_LIBS)

include $(TOP)/configure/RULES
