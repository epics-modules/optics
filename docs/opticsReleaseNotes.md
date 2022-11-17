---
layout: default
title: Release Notes
nav_order: 3
---


optics Release Notes
====================

Release 2-13-5 (Oct, 5 2020)
----------------------------

- Iocsh files now installed to top level folder from opticsApp/iocsh

Release 2-13-4 (Apr. 20 2020)
-----------------------------

- Autoconverted adl screens to edl and bob

Release 2-13-3 (Jun. 14 2019)
-----------------------------

- Req files now installed to top level db folder.

Release 2-13-2 (Apr. 3 2019)
----------------------------

- Updated record structure for EPICS v7
- kohzuCtl speeds now optional and input values are checked against limits before being set
- New iocsh script for setting up XIA pfcu slits

Release 2-13-1 (Jun 5. 2018)
----------------------------

- Autoconverted ui and css files are now in subfolders

Release 2-13 (Dec 5, 2017)
--------------------------

- Modified hrCtl.st so that limits for energy and wavelength are calculated from limits of both phy1 and phi2 motors - whichever limit is more restrictive rules.
- Modified kohzuCtl.st and kohzuCtl\_soft.st so user can disable speed control.
- Modified kohzuCtl.st and kohzuCtl\_soft.st so entering a value for energy, lambda, or theta that will violate a limit doesn't put the mono into manual mode.

Release 2-12
------------

- Added iocsh files for all support that require more than just a database.
- /orient.iocsh: Found out you can set macros for template files, will make matching PV's easier. Added default substitutions file to demonstrate to users of orient.iocsh a functions sub file.
- CONFIG\_APP -&gt; CONFIG\_SITE, revamped configure from base-3.15.4 makeBaseApp example.
- kohzuSeq: Enable/disable speed control via PV $(P)KohzuSpeedCtrl
- Modified 2slit\_soft.vdb and table\_soft.vdb to allow more effective control by spec - especially in the setting (that is, recalibration) of soft motor values. (kohzuSeq\_soft.vdb does not have these changes.) NOTE that these changes require a version of the motor record with the IGSET (ignore set) field. Currently (5/12/2017), no released version of the motor module has this, but it's in the trunk as of 1/12/2017.)
- Previously, kohzuCtl\_soft.st used macro variables kohzuCtl\_pmac\*. Now it uses kohzuCtl\_soft\_pmac\*.

Release 2-11
------------

- Added support for slits, optical table, and Kohzu monochromator with soft motor record front ends: 2slit\_soft, table\*soft, kohzuCtl\_soft.
- Added support for MultiLayer Laue stage: MLLH, MLLV.
- Modified tableRecord.c to write to all motors every time. table\_soft.vdb depends on this; table.db doesn't care.

Release 2-10
------------

- tableRecord: Added the menu field AUNIT, which allows user or developer to specify the units in which table angles AX, AY, and AZ are understood and displayed. The Overall table orientation angle, YANG, must be in degrees.
- When finding angle limits, explore +/- 80 degrees (previously, it was +/- 5). If can't find an angle that violates a motor limit, set angle limit to +/- 89 degrees.

Release 2-9-3
-------------

- tableRecord.c: User-limit was broken, which in some cases prevented effective use of "Set/Use" and "Zero" features. As part of the fix, relative user limits (e.g., UHAXR) have been added to supplement the previously supported absolute limits (e.g., UHAX).
- tableRecord.c: Newport geometry sometimes gave unphysical angle readbacks when M0Y and M2Y had exactly the same value. Thanks to Mark Rivers for isolating the condition in which this occurred.
- table\_settings.req: wasn't including tweak values.
- Spherical grating monochromator database: changed SGM$(N) to $(SGM), so user can give it any name, and to agree with SGM\_settings.req.

Release 2-9-2
-------------

- hrSeq.db: Crystal species wasn't implemented right (seq record needed TypeMO.RVAL, instead of TyoeMO.VAL)
- hrCtl.st: phi1MotRdbk wasn't converted to degrees before being used to init Phi1. Theta2 init wasn't honoring Geom switch. Fixed "when" statements that included expressions like "efTestAndClear() &amp;&amp; delay(.1)", which can fail because delay hasn't expired, and then fail because flag was cleared. Use pvPut(, ASYNC) instead of motor.DMOV fields to check for completion.
- hrCtl.st: When motors moved by third party, drive "Moving", and set to Manual mode when motors stop. sprintf overwrote end of string.
- orient\_st.st: User messages were overflowing string fields.
- MLLH, MLLV: New databases and display files for Multilayer Laue Lens instrument. The databases are also examples of using multiple soft motors to control multiple hard motors through transforms.

Release 2-9-1
-------------

- filterDrive.st: Added OUTGET for separate readback of outputs; only move enabled filters. Removed trailing backslash characters from several lines, caused compiler failure on Windows.
- filterBladeNoSensor.db: Added OutGet and OutSet records and OUT\_STRING and IN\_STRING macro parameters so the database does not assume blade in=1 and blade out=0.
- filter.substitutions: Added OUT\_STRING and IN\_STRING macro parameters

Release 2-9
-----------

- __fb\_epid__ updated (2012-02-29): 
    - Support and [documentation](fb_epid/index.html) updated to help with deployment.
    - Added simulation of a temperature controller as default configuration.
    - TODO: Consider replacing swait records with calcout from EPICS base.
- Split chantler.h into chantler.h and chantler.c, so more than one program can use it.
- Added iocBoot examples code
- Added Christian Schlepuetz' support for the XIA PF4 filter, which draws from support developed by David Maden, Jon Tischler, Pete Jemian, and Tim Mooney.
- Fixed initialization problems in SGM database, and converted to VDCT.
- Added CSS-BOY and caQtDM display files

Release 2-8-1
-------------

- hrSeq.db, hrCtl.st now permits min/max theta to be specified via PVs
- Dropped \_\_VAR\_ARGS\_\_ from sncqxbpm.st, because different compilers do this differently.

Release 2-8
-----------

- 2slit.db, 2slit.adl, 4slitGraphic.adl: Add CoordSys record, and "RELTOCENTER" macro which controls its value. If CoordSys==0, the database is backward compatible with previous versions, and both motors move in the lab frame (both increase in the same direction). Otherwise, both motors increase as the slit opens.  
     Also added autosave-request file 2slit\_settings.req.
- pf4 filter: 
    - Extensive modifications to support additional filter materials, and to avoid having to specify I/O and energy PVs to both the SNL program and to the MEDM-display files. Also, change the way I/O PVs are specified ('$(BP)$(Bn)' instead of '$(Bn)') to avoid vxWorks line-length limitations.
    - Added transmission factor for each bank separately
    - For new filter materials, show user raw absorption data (mu) as a function of energy
    - Display digital I/O bits, so we can coexist with external software that independently manages I/O bits.
- Changes for 64-bit arch
- tableRecord.c: Compare user limits to (&gt;SMALL), rather than to (==0)
- xiahsc.st: Added the validateResponse patch to xiahsc.st that I wrote for unicat to resolve the problem of temporary, incorrect, position readbacks.   
    Modifications to build with seq 2.1.0: snc wasn't parsing sprintf call correctly, so I put it behind '%%'.
- Modified RELEASE; deleted RELEASE.arch
- Added .opi display files for CSS-BOY
- sncqxbpm.st: Modifications to build with seq 2.1.0: delete variable assignment and comma separator within macro.

Release 2-7
-----------

- SGM.db had some empty links that were specified as "0", which produced link errors.
- table\_setup\_PNC.adl showed origin in wrong position (at M1, instead of M0).
- Added database and MEDM displays for a multilayer monochromator.
- 2slit.db, 2postMirror.db - Added DMOV PV, implemented using local gate PV.
- Added fb\_epid.db and fb\_epid.adl: user-reconfigurable software feedback using the epid record, and related documentation fb\_epid/\*.
- Added sncqxbpm.st, qxbpm.db, qxbpm.req, qxbpm\*.adl - Support for the Oxford 4-channel X-ray Beam Position Monitor, and related documentation qxbpm.html.
- xia-slit.db - Modified for update slit support
- seqPVmacros.h - format changes
- tableRecord.c - commented out unused variables

Release 2-6-1
-------------

- Added support for a multilayer monochromator
- XIA\_shutter.db - user command was sometimes overwritten by a poll and dropped

Release 2-6
-----------

- New support for XIA PF4 filter/shutter: rewritten to use asyn records instead of stringin/out records with stringParm device support. Also waitTime calc (for serial record) was in milliseconds, but the serial record was replaced by an asyn record, whose timeout is specified in seconds. Database converted to vdct.
- Oxford 4-channel x-ray beam position monitor
- New support for an ASRP optical table
- optics/opticsApp/Db/2slit.db: deleted gate-related PV's
- optics/opticsApp/Db/table.db: Fixed problems that were causing motor records to be put into alarm: tweakVal records had UDF==1; calcout record had empty CALC expression.

Release 2-5-3
-------------

- Fixed problems in table.db that caused the table to put motors into alarm.

Release 2-5-2
-------------

- Added MEDM display files for XIA PF4 filter, and fixed it to compile for vxWorks
- xia\_slit.st was not honoring limits written to the hardware.
- 2slit.db converted to vdct

Release 2-5-1
-------------

- Added CoarseFineMotor database and MEDM display files
- fixed minor problems with xia\_slit MEDM display.
- Added support for XIA PF4 dual filters.
- Added support for Io (ionization-chamber) calculation.

Release 2-5
-----------

- Added diffractometer support (orientation matrix)
- Added some documentation for slits, mirrors, filters, spherical grating monochromator, high-energy-resolution monochromator.
- Ported xia slit to EPICS 3.14, and improved its behavior when driven by ca\_put\_callback().

Release 2-4
-----------

- Added table of fixed points (points about which an optical table rotates) to table database, request file, and medm displays
- The save\_restore include file, table\_settings.req, now requires the additional macro argument 'Q'. This is the same macro argument required by table.db.

Release 2-3
-----------

This is the first release of the synApps optics module. Version numbering for this module begins with 2.3 because this module was split from version 2.2 of the std module, and I wanted to retain the CVS histories of module contents.

This version is intended to build with EPICS base 3.14.5, mpf 2.4.2, and std 2.3. Differences from software as previously released in std 2.2:

- Converted to EPICS 3.14
- Docs updated and moved to optics/documentation
- SGM.db - removed forward links pointing nowhere (gdct artifacts).
- kohzuSeq.db - added debug PV $(P)KohzuCtlDebug. Fixed long-standing bug: if the theta motor was moved by a very small amount (by external client not working through kohzuCtl) this software would sometimes ignore the notification it received from EPICS.
- hrSeq.db - added debug PV $(P)HR$(N)CtlDebug. Fixed long-standing bug: if a theta motor was moved by a very small amount (by external client not working through hrCtl) this software would sometimes ignore the notification it received from EPICS.

Suggestions and Comments to:   
[Tim Mooney ](mailto:mooney@aps.anl.gov): (mooney@aps.anl.gov)
