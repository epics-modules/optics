# flexCombinedMotion

This support was designed for APS flexure stages, but it should work for other coarse/fine motor applications.

## APS Flexure Hardware

An APS flexure stage includes the following hardware:

* A New Focus picomotor controller
* A New Focus open-loop picomotor (providing coarse motion and a large travel range)
* A PI piezo controller
* A PI piezo (providing fine motion and a small travel range)
* A Lion Precision cap sensor driver
* A Lion Precision cap sensor (providing absolute positioning)
* A measComp USB-2408-2AO or LabJack T8 (analog inputs to read the cap sensor)

## Motivation

The existing [CoarseFineMotor.db](../opticsApp/Db/CoarseFineMotor.db) could not be used because it was not guaranteed that the open-loop picomotor would get within the piezo's range of the desired position.  [flexCombinedMotion.st](../opticsApp/src/flexCombinedMotion.st) was adapted from a hybrid motion program already in use at an APS beamline.

## Modes of operation

* Fast: combined motion using the specified piezo range as the deadband
* Precise: combined motion using the specified deadband as the deadband
* Coarse: motion using only the coarse motor
* Fine: motion using only the fine motor

## Example configuration

### Motors

* PREFIX: optics:
* Picomotor: $(PREFIX):nf:c0:m1
* Piezo: $(PREFIX):pi:c0:m1
* Piezo range: 15um
* Analog input reading cap sensor voltage: $(PREFIX):LJT8:1:Ai0
* Cap sensor conversion factor (um/V): 32.59
* Desired cap sensor name: cap1
* Desired cap sensor description: "Cap Sensor Position"
* Desired combo motor name: m1

### IOC config

The [flexCombinedMotion.iocsh](../opticsApp/iocsh/flexCombinedMotion.iocsh) file describes the required and option macros it accepts.  This example includes only the required macros:

```
iocshLoad("$(OPTICS)/iocsh/flexCombinedMotion.iocsh","P=$(PREFIX),C=cap1,V=$(PREFIX)LJT8:1:Ai1,UMV=32.59,M=m1,DESC='Cap Sensor Position',LLM=0.0,HOME=7.5,HLM=15.0,FM=pi:c0:m1,CM=nf:c0:m1")
```

Notes: The LLM/HLM values can be used to restrict the usable range of the piezo.  The HOME can be near LLM or HLM to allow more fine steps in one direction before a coarse move is needed.

### MEDM/caQtDM screen macros

#### flexCombinedMotionTop.{adl,ui}

```
"P=optics:,M=m1,CM=nf:c0:m1,FM=pi:c0:m1,C=cap1"
```

#### flexCombinedMotion.{adl,ui}

```
"P=optics:,M=m1"
```

#### flexCapSensor.{adl,ui}

```
"P=optics:,C=cap1"
```

