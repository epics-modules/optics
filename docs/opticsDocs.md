---
layout: default
title: User Guide
nav_order: 3
has_children: true
---

# User Guide
{: .no_toc}

This section provides detailed documentation for each type of
optical device supported by the optics module. Each device category
is documented on its own page:

- [Monochromators](monochromators.html) -- Kohzu/PSL, Bragg-Gap,
  high-resolution dispersive, spherical grating, and multilayer
  monochromators
- [Slits](slits.html) -- 2-blade, 4-blade, and XIA HSC slit support
- [Filters](filters.html) -- Motor-driven filters and XIA PF4
  filter support (dual and multiple)
- [Mirrors](mirrors.html) -- 2-post mirror and ASRP mirror table
- [Other Devices](other.html) -- Orientation matrix, Io calculation,
  optical table, and PID feedback cross-references

{: .note }
> Many of the databases in this module provide two variants: one
> using EPICS analog output records for virtual motors, and one
> using soft motor records. The soft motor versions are more
> convenient for spec users and other clients that expect motor
> record interfaces. Look for files with `*soft*` in the name
> in the `src`, `Db`, and `op` directories.
