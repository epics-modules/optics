---
layout: default
title: Release Notes
nav_order: 2
---

# Release Notes
{: .no_toc}

## Table of contents
{: .no_toc .text-delta }

- TOC
{:toc}

Release 2-14 (Jun. 5 2023)
---------------------------

- **APSU variable mask aperture slits** -- Added slit support for the
  APSU variable mask aperture.
- **Flexure combined motion** -- Added support for APS combined motion
  flexure stages.
- **filterDrive.st cleanup** -- Fixed unused variables.
- **Documentation** -- Updated documentation to GitHub Pages.

Release 2-13-5 (Oct. 5 2020)
-----------------------------

- **iocsh file installation** -- Iocsh files now installed to top
  level folder from `opticsApp/iocsh`.

Release 2-13-4 (Apr. 20 2020)
------------------------------

- **Display file conversion** -- Autoconverted ADL screens to EDL
  and BOB formats.

Release 2-13-3 (Jun. 14 2019)
------------------------------

- **Request file installation** -- Req files now installed to top
  level `db` folder.

Release 2-13-2 (Apr. 3 2019)
-----------------------------

- **EPICS v7 compatibility** -- Updated record structure for EPICS v7.
- **kohzuCtl speed improvements** -- Speeds now optional and input
  values are checked against limits before being set.
- **XIA PFCU slit iocsh** -- New iocsh script for setting up XIA PFCU
  slits.

Release 2-13-1 (Jun. 5 2018)
-----------------------------

- **Display file organization** -- Autoconverted UI and CSS files are
  now in subfolders.

Release 2-13 (Dec. 5 2017)
---------------------------

- **hrCtl.st limit calculation** -- Modified so that limits for energy
  and wavelength are calculated from limits of both phi1 and phi2
  motors -- whichever limit is more restrictive rules.
- **kohzuCtl speed control** -- Modified `kohzuCtl.st` and
  `kohzuCtl_soft.st` so user can disable speed control.
- **kohzuCtl limit handling** -- Modified `kohzuCtl.st` and
  `kohzuCtl_soft.st` so entering a value for energy, lambda, or theta
  that will violate a limit does not put the mono into manual mode.

Release 2-12
------------

- **iocsh files** -- Added iocsh files for all support that requires
  more than just a database.
- **orient.iocsh** -- Found that macros can be set for template files;
  added default substitutions file to demonstrate usage.
- **Build configuration** -- `CONFIG_APP` renamed to `CONFIG_SITE`;
  revamped configure from base-3.15.4 `makeBaseApp` example.
- **kohzuSeq speed control PV** -- Enable/disable speed control via
  `$(P)KohzuSpeedCtrl`.
- **Soft motor improvements** -- Modified `2slit_soft.vdb` and
  `table_soft.vdb` to allow more effective control by spec,
  especially in the setting (recalibration) of soft motor values.
  (`kohzuSeq_soft.vdb` does not have these changes.)

{: .important }
> These soft motor changes require a version of the motor record with
> the `IGSET` (ignore set) field.

- **kohzuCtl\_soft.st macro rename** -- Previously used macro
  variables `kohzuCtl_pmac*`. Now uses `kohzuCtl_soft_pmac*`.

Release 2-11
------------

- Added support for slits, optical table, and Kohzu monochromator
  with soft motor record front ends: `2slit_soft`, `table*soft`,
  `kohzuCtl_soft`.
- Added support for Multilayer Laue stage: MLLH, MLLV.
- Modified `tableRecord.c` to write to all motors every time.
  `table_soft.vdb` depends on this; `table.db` does not care.

Release 2-10
------------

- tableRecord: Added the menu field `AUNIT`, which allows user or
  developer to specify the units in which table angles AX, AY, and AZ
  are understood and displayed. The overall table orientation angle,
  `YANG`, must be in degrees.
- When finding angle limits, explore +/- 80 degrees (previously +/- 5).
  If an angle that violates a motor limit cannot be found, set angle
  limit to +/- 89 degrees.

Release 2-9-3
-------------

- `tableRecord.c`: User-limit was broken, which in some cases prevented
  effective use of "Set/Use" and "Zero" features. As part of the fix,
  relative user limits (e.g., `UHAXR`) have been added to supplement
  the previously supported absolute limits (e.g., `UHAX`).
- `tableRecord.c`: Newport geometry sometimes gave unphysical angle
  readbacks when M0Y and M2Y had exactly the same value.
- `table_settings.req`: Was not including tweak values.
- Spherical grating monochromator database: Changed `SGM$(N)` to
  `$(SGM)`, so user can give it any name, and to agree with
  `SGM_settings.req`.

Release 2-9-2
-------------

- `hrSeq.db`: Crystal species was not implemented correctly (seq record
  needed `TypeMO.RVAL`, instead of `TypeMO.VAL`).
- `hrCtl.st`: phi1MotRdbk was not converted to degrees before being
  used to init Phi1. Theta2 init was not honoring Geom switch. Fixed
  "when" statements that included expressions like
  `efTestAndClear() && delay(.1)`, which can fail because the delay
  has not expired. Use `pvPut(, ASYNC)` instead of motor `.DMOV` fields
  to check for completion.
- `hrCtl.st`: When motors are moved by a third party, drive "Moving",
  and set to Manual mode when motors stop. `sprintf` overwrote end of
  string.
- `orient_st.st`: User messages were overflowing string fields.
- MLLH, MLLV: New databases and display files for Multilayer Laue Lens
  instrument. The databases are also examples of using multiple soft
  motors to control multiple hard motors through transforms.

Release 2-9-1
-------------

- `filterDrive.st`: Added `OUTGET` for separate readback of outputs;
  only move enabled filters. Removed trailing backslash characters from
  several lines (caused compiler failure on Windows).
- `filterBladeNoSensor.db`: Added `OutGet` and `OutSet` records and
  `OUT_STRING` and `IN_STRING` macro parameters so the database does
  not assume blade in=1 and blade out=0.
- `filter.substitutions`: Added `OUT_STRING` and `IN_STRING` macro
  parameters.

Release 2-9
-----------

- **fb\_epid** -- Support and documentation updated to help with
  deployment. Added simulation of a temperature controller as default
  configuration.
- Split `chantler.h` into `chantler.h` and `chantler.c`, so more than
  one program can use it.
- Added `iocBoot` example code.
- Added Christian Schlepuetz' support for the XIA PF4 filter, which
  draws from support developed by David Maden, Jon Tischler, Pete
  Jemian, and Tim Mooney.
- Fixed initialization problems in SGM database, and converted to VDCT.
- Added CSS-BOY and caQtDM display files.

Release 2-8-1
-------------

- `hrSeq.db`, `hrCtl.st` now permits min/max theta to be specified via
  PVs.
- Dropped `__VAR_ARGS__` from `sncqxbpm.st`, because different
  compilers handle this differently.

Release 2-8
-----------

- `2slit.db`, `2slit.adl`, `4slitGraphic.adl`: Added `CoordSys`
  record, and `RELTOCENTER` macro which controls its value. If
  `CoordSys==0`, the database is backward compatible with previous
  versions. Otherwise, both motors increase as the slit opens. Also
  added autosave-request file `2slit_settings.req`.
- PF4 filter: Extensive modifications to support additional filter
  materials, and to avoid having to specify I/O and energy PVs to both
  the SNL program and to the MEDM-display files. Changed the way I/O
  PVs are specified (`$(BP)$(Bn)` instead of `$(Bn)`) to avoid vxWorks
  line-length limitations. Added transmission factor for each bank
  separately. For new filter materials, show user raw absorption data
  (mu) as a function of energy. Display digital I/O bits for
  coexistence with external software.
- Changes for 64-bit architecture.
- `tableRecord.c`: Compare user limits to (`>SMALL`), rather than to
  (`==0`).
- `xiahsc.st`: Added the `validateResponse` patch to resolve the
  problem of temporary, incorrect, position readbacks. Modifications
  to build with seq 2.1.0.
- Modified `RELEASE`; deleted `RELEASE.arch`.
- Added `.opi` display files for CSS-BOY.
- `sncqxbpm.st`: Modifications to build with seq 2.1.0.

Release 2-7
-----------

- `SGM.db` had some empty links that were specified as "0", which
  produced link errors.
- `table_setup_PNC.adl` showed origin in wrong position (at M1,
  instead of M0).
- Added database and MEDM displays for a multilayer monochromator.
- `2slit.db`, `2postMirror.db`: Added `DMOV` PV, implemented using
  local gate PV.
- Added `fb_epid.db` and `fb_epid.adl`: user-reconfigurable software
  feedback using the epid record, and related documentation.
- Added `sncqxbpm.st`, `qxbpm.db`, `qxbpm.req`, `qxbpm*.adl`:
  Support for the Oxford 4-channel X-ray Beam Position Monitor.
- `xia-slit.db`: Modified for updated slit support.
- `seqPVmacros.h`: Format changes.
- `tableRecord.c`: Commented out unused variables.

Release 2-6-1
-------------

- Added support for a multilayer monochromator.
- `XIA_shutter.db`: User command was sometimes overwritten by a poll
  and dropped.

Release 2-6
-----------

- New support for XIA PF4 filter/shutter: rewritten to use asyn
  records instead of stringin/out records with stringParm device
  support. Also, `waitTime` calc was in milliseconds, but the serial
  record was replaced by an asyn record, whose timeout is specified in
  seconds. Database converted to VDCT.
- Oxford 4-channel x-ray beam position monitor.
- New support for an ASRP optical table.
- `2slit.db`: Deleted gate-related PVs.
- `table.db`: Fixed problems that were causing motor records to be put
  into alarm: `tweakVal` records had `UDF==1`; calcout record had empty
  `CALC` expression.

Release 2-5-3
-------------

- Fixed problems in `table.db` that caused the table to put motors
  into alarm.

Release 2-5-2
-------------

- Added MEDM display files for XIA PF4 filter, and fixed it to compile
  for vxWorks.
- `xia_slit.st` was not honoring limits written to the hardware.
- `2slit.db` converted to VDCT.

Release 2-5-1
-------------

- Added CoarseFineMotor database and MEDM display files.
- Fixed minor problems with xia\_slit MEDM display.
- Added support for XIA PF4 dual filters.
- Added support for Io (ionization-chamber) calculation.

Release 2-5
-----------

- Added diffractometer support (orientation matrix).
- Added some documentation for slits, mirrors, filters, spherical
  grating monochromator, high-energy-resolution monochromator.
- Ported xia slit to EPICS 3.14, and improved its behavior when driven
  by `ca_put_callback()`.

Release 2-4
-----------

- Added table of fixed points (points about which an optical table
  rotates) to table database, request file, and MEDM displays.
- The save\_restore include file, `table_settings.req`, now requires
  the additional macro argument `Q`. This is the same macro argument
  required by `table.db`.

Release 2-3
-----------

This is the first release of the synApps optics module. Version
numbering for this module begins with 2.3 because this module was
split from version 2.2 of the std module, and the CVS histories of
module contents were retained.

This version is intended to build with EPICS base 3.14.5, mpf 2.4.2,
and std 2.3. Differences from software as previously released in
std 2.2:

- Converted to EPICS 3.14.
- Docs updated and moved to `optics/documentation`.
- `SGM.db`: Removed forward links pointing nowhere (gdct artifacts).
- `kohzuSeq.db`: Added debug PV `$(P)KohzuCtlDebug`. Fixed
  long-standing bug: if the theta motor was moved by a very small
  amount (by external client not working through kohzuCtl) this
  software would sometimes ignore the notification it received from
  EPICS.
- `hrSeq.db`: Added debug PV `$(P)HR$(N)CtlDebug`. Fixed
  long-standing bug: if a theta motor was moved by a very small
  amount (by external client not working through hrCtl) this software
  would sometimes ignore the notification it received from EPICS.
