TOP=..

include $(TOP)/configure/CONFIG

SRC_DIRS += $(TOP)/opticsApp/src

TESTPROD_HOST += matrixTest
matrixTest_SRCS += matrixTest.cpp
testHarness_SRCS += matrixTest.cpp
TESTS += matrixTest

testHarness_SRCS += runTests.cpp

PROD_vxWorks = opticsTestHarness
opticsTestHarness_SRCS += $(testHarness_SRCS)
TESTSPEC_vxWorks = opticsTestHarness.munch; runTests

PROD_LIBS += optics
PROD_LIBS += $(EPICS_BASE_IOC_LIBS)

#TESTSCRIPTS_HOST += $(TESTS:%=%.t)

include $(TOP)/configure/RULES
