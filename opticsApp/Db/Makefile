# Makefile.Host
TOP = ../..
include $(TOP)/configure/CONFIG
#----------------------------------------
#  ADD MACRO DEFINITIONS AFTER THIS LINE

#----------------------------------------------------
#  Optimization of db files using dbst (DEFAULT: NO)
#DB_OPT = YES

#----------------------------------------------------
# Create and install (or just install) dbd files
# <name>.dbd will be created from <name>Include.dbd
#DBD += example.dbd

#----------------------------------------------------
# Create and install (or just install)
# databases, templates, substitutions like this
#DB += sample.db

DB += 2postMirror.db
DB += 2slit.db
DB += ASRPmirrorTable.db
DB += ASRPmirrorTable_softmotor.db
DB += bragg.db
DB += CoarseFineMotor.db
DB += fb_epid.db
DB += filterBladeNoSensor.db
DB += filterDrive.db
DB += filterLock.db
DB += filterMotor.db
DB += hrSeq.db
DB += Io.db
DB += kohzuSeq.db
DB += kohzuSeq_soft.db
DB += ml_monoSeq.db
DB += orient.db
DB += orientFan8.db
DB += orient_xtals.db
DB += pf4bank.db
DB += pf4common.db
DB += qxbpm.db
DB += SGM.db
DB += table.db
DB += xiahsc.db
DB += XIA_shutter.db
DB += XIA_shutterTry.db
DB += xia_slit.db

REQ += 2slit_settings.req
REQ += 2slit_soft_settings.req
REQ += ASRPmirrorTable_settings.req
REQ += CoarseFineMotor_settings.req
REQ += fb_epid.req
REQ += filterBladeNoSensor.req
REQ += filterDrive.req
REQ += hrSeq_settings.req
REQ += Io_settings.req
REQ += kohzuSeq_settings.req
REQ += MLLH_soft_settings.req
REQ += MLLV_soft_settings.req
REQ += ml_monoSeq_settings.req
REQ += orient_settings.req
REQ += orient_xtals_1_settings.req
REQ += orient_xtals_settings.req
REQ += pf4bank.req
REQ += pf4bank_settings.req
REQ += pf4common.req
REQ += pf4common_settings.req
REQ += qxbpm.req
REQ += SGM_settings.req
REQ += table_settings.req
REQ += table_soft_settings.req
REQ += xia_slit_settings.req


#----------------------------------------------------
# Declare template files which do not show up in DB
#USES_TEMPLATE += dbExample2.template

include $(TOP)/configure/RULES
#----------------------------------------
#  ADD RULES AFTER THIS LINE
