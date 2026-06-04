---
layout: default
title: EPID Feedback
nav_order: 6
has_children: true
---

# EPICS fb\_epid Feedback Controls
{: .no_toc}

## Table of contents
{: .no_toc .text-delta }

- TOC
{:toc}

Overview
========

The fb\_epid support provides a database centered around the EPICS
[epid](https://epics.anl.gov/bcda/synApps/std/epidRecord.html)
record. The versatility of the fb\_epid support lies in the various
calculations that can be reconfigured by the user while the IOC is
operating. These calculations allow the user to configure the input
and output of the PID loop, as well as to apply complex conditions on
when the PID loop should be allowed to drive the output or be
switched off.

The fb\_epid support is part of the synApps
[optics](https://github.com/epics-modules/optics) module.

Theory of Operation
-------------------

1. A signal is provided as an EPICS process variable (macro parameter
   `IN`). The signal source can be in the same IOC with the feedback
   software or in another EPICS IOC available on the network. The
   variable should be a floating point. (In principle, it *could* be
   an integer but the feedback may not be so smooth.)
2. The input calculation (swait record) provides some flexibility for
   conditioning the input signal to the feedback.
3. An epid record provides real-time feedback and recalculates the
   output variable.
4. The output from the epid record is buffered by the `obuf`
   calculation which watches the Feedback ON (`FBON`) switch and
   retains the previous output value if the feedback software is
   switched off.
5. The output calculation allows some flexibility for conditioning the
   output signal to the positioner (`OUT`). The conditioned epid
   result is pushed to the positioner.
6. A positioner responds to the result from the epid record and thus
   further modifies the input signal.
7. The feedback can be switched on manually or automatically, subject
   to the logic of some other calculation (`CALC`). For example, a
   shutter closed signal could suspend feedback. In this case, the
   output is not driven.
8. When the feedback is switched on, the positioner should not jerk to
   a different position. The feedback software must be prepared to
   start moving the positioner from its present location.

Installation
============

Install one instance of this database for each feedback channel. If
two different methods for feedback are desired for a given axis,
create two instances of this database. See below for details of these
configurations.

{: .note }
> Clever adjustments to the enable calculations can allow for
> automated switching. For example, at APS beam line 33ID for
> feedback of the DCM crystal 2 PZT, one instance would use the
> XBPM *y* position signal while another instance would use the D3
> graphite foil intensity as input signals. Both would be configured
> to drive the DCM second crystal PZT. Choice of the *active*
> fb\_epid instance was obtained by adding values to the enable
> calculation, watching the `FBON` field of the other feedback.

Follow these steps to install the fb\_epid support:

1. Modify the `st.cmd` file
2. Add `fb_epid.substitutions` file
3. Modify `auto_settings.req` file
4. Add configuration to GUI to access the new support

Modify the IOC's st.cmd File
-----------------------------

To install this software, make changes in the IOC's `st.cmd` file,
adding this line anywhere between the calls to `dbLoadDatabase` and
`iocInit`:

```
### PID_based feedback
dbLoadTemplate("fb_epid.substitutions")
```

Add fb\_epid.substitutions File
-------------------------------

Create the `fb_epid.substitutions` file in the same directory as
`st.cmd` with content such as:

```
file "$(OPTICS)/opticsApp/Db/fb_epid.db"
  {
    {
        P=xxx:epid1,
        IN=xxx:epid1:sim.VAL,
        OUT=xxx:epid1:sim.D,
        MODE=PID,
        CALC=A,
        PERMIT1="xxx:epid1:on.VAL",
        PERMIT2="",
        PERMIT3="",
        PERMIT4=""
    }
  }
```

### Macro substitutions in fb\_epid.db

| Macro | Description |
| - | - |
| `$(P)` | Prefix for this instance of this database. Note that `$(P):in.INAN` holds PV name of input PV (by default) |
| `$(IN)` | PV name: input signal |
| `$(OUT)` | PV name: output positioner |
| `$(MODE)` | Either `PID` or `Max/Min` |
| `$(CALC)` | Calculation string: `1` = feedback on, `0` = feedback off. A trivial value might be `A` which only watches the value of `$(P):on`. |
| `$(PERMIT1)` | PV name: boolean value to permit operations; value becomes `$(P):enable.B` |
| `$(PERMIT2)` | PV name: boolean value to permit operations; value becomes `$(P):enable.C` |
| `$(PERMIT3)` | PV name: boolean value to permit operations; value becomes `$(P):enable.D` |
| `$(PERMIT4)` | PV name: boolean value to permit operations; value becomes `$(P):enable.E` |

Modify auto\_settings.req File
------------------------------

To ensure that changed values will be restored after reboot, add
lines such as this to the `auto_settings.req` file (usually found in
the same directory with the `st.cmd` file):

```
### PID_based feedback
file fb_epid.req P=$(P)epid1
```

Add Configuration to GUI
-------------------------

Add commands to the GUI displays to call each configured instance of
the fb\_epid support. Such as this *related display* widget in MEDM:

```
"related display" {
        object {
                x=10
                y=10
                width=70
                height=20
        }
        display[0] {
                label="fb_epid"
                name="fb_epid.adl"
                args="P=prj:epid1"
        }
        display[1] {
                label="simulator"
                name="fb_epid_sim.adl"
                args="P=prj:epid1,C=sim"
        }
        clr=0
        bclr=17
        label="-prj:epid1"
}
```

Or start MEDM using a command line such as:

```
medm -x -macro "P=prj:epid1" fb_epid.adl &
```

### Macro substitutions in fb\_epid.adl

| Macro | Description |
| - | - |
| `$(P)` | Prefix for this instance of support |

Use
===

Once the software has been installed (IOC configured with database
and autosave/restore configured to retain settings across restarts of
the IOC), some careful setup needs to happen before the software is
ready to be used.

First, it is necessary to identify the EPICS PVs for the control
variable (such as a positioner or the power to a heating element) and
the signal variable (the PV that is sampled for the PID loop). These
may have been configured in the IOC but it is possible to change them
while the IOC is running. They can be changed without need to
recompile or restart the EPICS IOC.

{: .warning }
> To avoid any unexpected consequences, be sure the fb\_epid software
> is switched off before changing any PVs or changing between modes
> of operation. In the MEDM screen, in the EPID output section, press
> the button marked **off**.

{: .important }
> The input signal must be updated faster than the recalculation
> interval for the fb\_epid software or instability will occur. A
> factor of 3 to 10 input updates per output update is reasonable.
> The output will be updated each time the epid is processed.

MEDM Screens
-------------

The features of the fb\_epid software are accessed from the main
control screen in MEDM: `fb_epid.adl`. Controls for the
[Simulator](simulator.html) are provided from a `fb_epid_sim.adl`
screen.

### fb\_epid main control screen

The MEDM screen provides access to all the controls of the epid
record. To add some flexibility for configuration at run time by beam
line users, an EPICS interface database has been created. The user can
change the input variable(s) through a calculation
([swait](https://epics.anl.gov/bcda/synApps/calc/swaitRecord.html)
record).

![main MEDM control screen](fb_epid_adl.png)

Control of the output variable will be permitted between the software
limits shown at the bottom of the control screen. From the output
calc, it is possible to change the PV which will be directed by this
database.

The enable calculation can be used to provide automated on/off
features with details specific to the particular installation.

### fb\_epid basic control screen

There are many controls on the main screen. For routine operations,
it may be more desirable to display just the basic controls (and less
of the tuning infrastructure).

![basic MEDM control screen](fb_epid_basic_adl.png)

### fb\_epid configuration screen

The configuration screen provides top-level access to the main
components that must be addressed for basic configuration.

{: .note }
> Advanced situations must use the calculation screens to access the
> complete interfaces of the swait records.

![fb_epid configuration screen](fb_epid_config_adl.png)

{: .warning }
> The buttons marked *output buffer calc* and *resume calc* in the
> lower right corner are for internal use only. **Do not change
> anything on these screens.**

### fb\_epid chart screen

The chart screen provides a view to the recent progress. There are
two strip charts (value vs. time). The upper chart shows the set
point (`.VAL`) and current value (`.CVAL`). The lower chart shows the
following error (`.ERR`).

{: .note }
> The limits on the two charts need to be set before this screen is
> of any real use. Right-click and select "PV limits" from the pop-up
> menu. Do not forget to apply any changes.

![fb_epid chart screen](fb_epid_chart_adl.png)

### fb\_epid simulator control screen

The main control screen for the [Simulator](simulator.html) is shown:

![main MEDM control screen for simulator](fb_epid_sim_adl.png)

Setup of the Calculations
--------------------------

As stated above, the versatility of the fb\_epid support lies in the
various calculations that can be reconfigured by the user while the
IOC is operating.

### Setting the enable calculation

The operation of fb\_epid is permitted when the result of the enable
calculation is 1.0. The first, obvious, choice is that a `bo` record
is provided to the user to switch the fb\_epid software on and off.
But the software should also disable itself when the input signal
goes out of range or due to some other operating parameters.

Other factors can be built into the enable calculation. For example,
on undulator beam lines, it is not useful to run the feedback if the
undulator is not operating (gap is closed or magnets are energized).
In such a case, monitor the PV for the undulator gap (APS undulator
A) and enable only if the gap is below some reasonable number such as
50 mm.

One should also factor the fb\_epid input signal into the enable
calculation by checking that it is within a valid operating range.

### Setting the input calculation

It is possible to perform limited math on the input signal to be
used. For example, when the goal is to maximize the conductance
through a crystal pair, such as a monochromator, the best signal
would be a ratio between detectors immediately before and after the
pair of crystals. The control variable would be the rotation angle of
either of the two crystals (usually a fine rotation of the second
crystal). The input calculation would then monitor the PVs for both
detectors and calculate the ratio of the two: `A/B`. In this example,
it would also be useful to include the PV of this calculation in the
enable calculation and ensure that the ratio is acceptable.

### Setting the limits on the output

To prevent the epid record from driving the control variable out of
bounds, there are limits for low and high (using the epid record's
`.DRVL` and `.DRVH` fields). The epid record software will not allow
the positioner to drive outside of these limits.

Tuning of the epid Record
--------------------------

In the epid record documentation, there is a special discussion on
feedback tuning in PID mode. Refer to the documentation for more
information on the EPICS epid record.

The epid record can run in either Max/Min or PID mode. Max/Min is
used to maximize a positive input signal or minimize a negative input
signal such as from a beam line detector. PID mode is used to keep
the input signal at a constant value such as holding a sample's
temperature constant.

### Max/Min mode

Max/Min mode is useful for monochromator feedback or other situations
where a positive signal is to be maximized (or a negative signal is
to be minimized).

{: .note }
> In Max/Min mode, the Set Point is ignored.

### PID mode

PID mode is useful for holding the input signal to the *Set Point* by
adjusting the control variable. The epid record documentation
provides a good description of how to set the PID constants.

Example Using the Simulator
----------------------------

An example demonstrating the simulator is provided in the
[simulator documentation](simulator.html).

Example DCM Feedback from X-ray Beam Position Monitor
------------------------------------------------------

Consider the case of an X-ray beam line with a double crystal
monochromator (DCM) and an X-ray Beam Position Monitor (XBPM) after
the DCM. The XBPM provides a signal that can be used to maintain the
throughput of the DCM if the DCM allows an adjustment of either first
or second crystal Bragg rotation independent of the other crystal.

For synchrotron beam lines, the vertical position from the XBPM
provides the input signal to the epid loop. The DCM often has a
piezoelectric transducer (PZT) that is used to control the fine
rotation of the second crystal. The second crystal rotation is
controlled by a low voltage (such as -2 to +9 VDC) sent to the PZT's
amplifier.

This example shows the startup configuration used to maintain the
XBPM vertical beam position by controlling the DCM second crystal PZT
voltage.

| Macro | Configured value | Meaning |
| - | - | - |
| `P` | `iad:fbe:xbpm:y` | PV of this fb\_epid instance |
| `IN` | `iad:xbpm:pos:y` | Y position from the XBPM |
| `OUT` | `iad:540:c0:out0` | Control voltage of the PZT |
| `MODE` | `PID` | Hold position steady using PID |
| `CALC` | `A&&B&&C` | Only when EPID is ON and both permits |
| `PERMIT1` | `iad:beamAvailable.VAL` | Require X-ray beam to be ready |
| `PERMIT2` | `iad:xbpm:current:ok.VAL` | Require XBPM signal to be valid |
| `PERMIT3` | | Unused |
| `PERMIT4` | | Unused |

Example Monochromator Feedback from Beam Intensity Monitor
----------------------------------------------------------

Consider another beam line with a DCM and then a monitor of the beam
intensity (reported as a floating-point or large integer number). A
list of suitable such monitors might include ionization chambers,
graphite foils, or fluorescent materials with photodiodes.

| Macro | Configured value | Meaning |
| - | - | - |
| `P` | `iad:fbe:D3:y` | PV of this fb\_epid instance |
| `IN` | `iad:540:c0:in10` | Signal from the beam intensity monitor |
| `OUT` | `iad:540:c0:out0` | Control voltage of the PZT |
| `MODE` | `Max/Min` | Maximize beam intensity |
| `CALC` | `A&&B` | Only when EPID is ON and one permit |
| `PERMIT1` | `iad:beamAvailable.VAL` | Require X-ray beam to be ready |
| `PERMIT2` | | Unused |
| `PERMIT3` | | Unused |
| `PERMIT4` | | Unused |

Infrastructure
==============

The fb\_epid support consists of several components:

| File | Description |
| - | - |
| `opticsApp/Db/fb_epid.db` | EPICS database |
| `opticsApp/Db/fb_epid.req` | Request file for autosave/restore |
| `opticsApp/Db/epid.req` | Request file for autosave/restore |
| `iocBoot/iocAny/fb_epid.substitutions` | Creates specific instances |
| `opticsApp/op/adl/fb_epid.adl` | Main MEDM screen |
| `opticsApp/op/adl/fb_epid_basic.adl` | Basic MEDM screen |
| `opticsApp/op/adl/fb_epid_chart.adl` | Charts VAL and CVAL, also ERR |
| `opticsApp/op/adl/fb_epid_config.adl` | Simplified configuration screen |
| `opticsApp/op/adl/fb_epid_sim.adl` | Simulator controls |

Structure of the EPICS Database
--------------------------------

The EPICS database was constructed in 2004. The records of the
database are defined in this table:

| Record type | Name | Description |
| - | - | - |
| epid | `$(P)` | Epid record instance |
| swait | `$(P):in` | Input signal collector |
| swait | `$(P):obuf` | Enforces `$(P).FBON` to disconnect epid record from output so `$(OUT)` is not changed |
| swait | `$(P):out` | Output signal collector |
| sseq | `$(P):outpv` | Part of bumpless start feature |
| swait | `$(P):resume` | Part of bumpless start feature |
| bo | `$(P):on` | User switch to turn epid ON or OFF |
| swait | `$(P):enable` | Automatic ON/OFF feature |
| swait | `$(P):sim` | Simulated temperature reading and heater |

A figure was produced to show how these records are connected. The
simulator record (`$(P):sim`) is not shown in this figure.

![structure of fb_epid database](fb_epid.png)

The full database source code is available in
[opticsApp/Db/fb_epid.db](https://github.com/epics-modules/optics/blob/master/opticsApp/Db/fb_epid.db).

Simulator
---------

To help learn how to use the fb\_epid support, a swait record was
added to simulate the temperature reading of an object that is
exposed to some cooling power. A heater with adjustable power may be
applied, either as adjustable power or as a switched power.

Documentation of the simulator is provided on a
[related page](simulator.html).
