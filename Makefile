#Makefile at top of application tree
TOP = .
include $(TOP)/configure/CONFIG
DIRS += configure opticsApp tests
opticsApp_DEPEND_DIRS  = configure
tests_DEPEND_DIRS = configure opticsApp
include $(TOP)/configure/RULES_TOP
