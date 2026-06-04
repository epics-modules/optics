---
layout: default
title: Optics
nav_order: 1
---

# synApps Optics Module
{: .no_toc}

## Table of contents
{: .no_toc .text-delta }

- TOC
{:toc}

The optics module contains support for devices used to modify the
x-ray beam from a synchrotron source and apply it in experimentally
useful ways, including a variety of monochromators, slits, filters,
mirrors, diffractometers, and optical tables.

The optics module is part of
[synApps](https://www.aps.anl.gov/BCDA/synApps).

Supported Devices
-----------------

### Monochromators

- Non-dispersive double-crystal with symmetric offset (Kohzu/PSL geometry 1)
- Non-dispersive double-crystal with asymmetric offset (Kohzu/PSL geometry 2)
- Non-dispersive double-crystal with Bragg and gap control
- Dispersive double-crystal -- nested geometry
- Dispersive double-crystal -- symmetric geometry
- Spherical grating
- Multilayer

### Slits

- 2-blade slits (with optional soft motor front end)
- 4-blade graphic slits
- XIA HSC slits
- APSU variable mask aperture

### Filters

- Motor-driven filters with interlocks
- XIA PF4 dual filter (two 4-filter units)
- XIA PF4 multiple filter (two or four 4-filter units as a single device)

### Mirrors

- 2-post mirror
- ASRP mirror table (coupled pitch/vertical motion)

### Optical Tables

- 6-DOF optical table control with four geometry types (SRI, PNC,
  GEOCARS, NEWPORT), documented in the [Table Record](tableRecord.html)
  reference

### Other Devices

- Orientation matrix for 4-circle diffractometer control
- Io (ion chamber photon flux) calculation
- Software PID feedback via the epid record ([EPID Feedback](fb_epid/index.html))
- Flexure stage combined coarse/fine motion ([Flexure Combined Motion](flexCombinedMotion.html))
- CoarseFineMotor database

Dependencies
------------

The optics module requires the following EPICS modules:

| Module | Purpose |
| - | - |
| EPICS Base | Core IOC infrastructure |
| SNCSEQ | State Notation Language sequencer (monochromator, filter, and slit control programs) |
| CALC | transform and swait records (coordinate transforms, slit math) |
| BUSY | busy record |
| ASYN | asyn communication driver |
