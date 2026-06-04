---
layout: default
title: Development History
parent: EPID Feedback
nav_order: 2
---

# fb\_epid Development History
{: .no_toc}

## Table of contents
{: .no_toc .text-delta }

- TOC
{:toc}

This page summarizes key findings from the initial development and
testing of the fb\_epid support in 2004, and the subsequent revision
into its current form.

Testing Progression
-------------------

### Initial testing (June 2004)

The initial testing used a swait record to simulate a crystal
reflection with a Lorentzian peak shape. An EPID record was
configured for closed-loop feedback in either PID or Max/Min mode.

This testing revealed that the bare EPID record needed a wrapping
database to be useful in practice. The following features were
identified as necessary:

- Automatic on/off control based on external conditions
- User-selectable input and output PVs at runtime
- Separate tuning parameters for PID vs Max/Min modes
- Bumpless start (preventing positioner jumps when enabling feedback)
- Output limits loaded from the positioner

### First real feedback test (July 2004)

The first real feedback test was conducted on APS beamline 33ID,
maintaining the Oxford XBPM vertical position by adjusting the DCM
omega2 piezo. Key observations:

- Response locked to a new position 1 mm away in approximately 10
  seconds
- Position noise was observed when the PZT was moved; otherwise
  quieter than standard feedback

### Second test round (October 2004)

The second round of testing confirmed stable operation with active
XBPM-based feedback during sscan step-scans. The database was then
revised to the present `fb_epid` form.

Key Tuning Findings
-------------------

The following practical tuning guidance emerged from the initial
testing:

### PID parameters

- **KP sign** -- KP must be negative when positive KP drives the
  positioner away from the setpoint. This is geometry-dependent.
- **KI value** -- KI=400 gave mild overshoot. KI=1000 caused
  approximately 10 cycles of damped ringing before settling. KD=0
  worked well in the tested configuration.

### Bumpless start

{: .important }
> Before enabling feedback (`FBON`), the I term must be preloaded
> with the current positioner value. The output limits (`DRVL`,
> `DRVH`) must also be loaded from the positioner. Without this, the
> positioner will jump to an arbitrary position when feedback is
> first enabled.

The current fb\_epid database handles this automatically through the
`resume` and `outpv` records (the "bumpless start" feature).

### Update rate

{: .important }
> The input signal must update 3 to 10 times faster than the EPID
> recalculation interval, or instability will occur.
