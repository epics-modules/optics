program pf4Dual

/*
 * 2006-05-03,PRJ: converted to use of seqPVmacros.h
 * added glass, April 18, 2006, JZT
 * and fixed a bug (used bitsA where I should have used bitsB)
 * 2006-09-08, DMK: Removed usage of seqPVmacros.h. It simply did
 *                  work with the vxWorks cross-compiler.
 */
#define DEBUGGING 1
#include "seqPVmacros.h"

/*
 Usage:
    seq &pf4Dual
    (or to over-ride the defaults)
    seq &pf4Dual, "P=,MONO=,A0=,A1=,A2=,A3=,B0=,B1=,B2=,B4="

  P    = prefix for filter parameters
  MONO = monochromator energy (keV)
  A0   = PV for bank A bit 0
  A1   = PV for bank A bit 1
  A2   = PV for bank A bit 2
  A3   = PV for bank A bit 3
  B0   = PV for bank B bit 0
  B1   = PV for bank B bit 1
  B2   = PV for bank B bit 2
  B3   = PV for bank B bit 3
 */

/*   ------------------------   assignments   ------------------------ */
#define debug_flag pf4DualDebug

/* connect up with PV for result */

/* debugging flag for developers */
PV(short,pf4DualDebug,"{P}debug",EvFlag);

/* monochromator energy, keV */
PV(double,Emono,"{MONO}",EvFlag);

/* relays for each bank (A or B) */
PV(short,relay0A,"{A0}",EvFlag);
PV(short,relay1A,"{A1}",EvFlag);
PV(short,relay2A,"{A2}",EvFlag);
PV(short,relay3A,"{A3}",EvFlag);

PV(short,relay0B,"{B0}",EvFlag);
PV(short,relay1B,"{B1}",EvFlag);
PV(short,relay2B,"{B2}",EvFlag);
PV(short,relay3B,"{B3}",EvFlag);

/* button to recalculate everything */
PV(short,calc,"{P}calc",EvFlag);

/* status of each bank (PF4 module)
 * 0 == off
 * 1 == enabled
 * 2 == recalc transmission
 * 3 == recalc all
 */
PV(short,bankA,"{P}bankA",Monitor);
PV(short,bankB,"{P}bankB",Monitor);

     /* energy of mono (keV) */
PV (double,E_using,  "{P}E_using",  EvFlag);

     /* flag use Emono, not E_using */
PV (short,useMono,   "{P}useMono",  EvFlag);

     /* bit pattern (status) for each bank */
PV (short,statusA,   "{P}statusA",  NoMon);
PV (short,statusB,   "{P}statusB",  NoMon);

     /* user selection for each bank */
PV (long,bitFlagA,   "{P}bitFlagA", NoMon);
PV (long,bitFlagB,   "{P}bitFlagB", NoMon);

     /* transmission of entire unit (composite of all filters) */
PV (double,trans,   "{P}trans",   NoMon);
PV (double,invTrans,"{P}invTrans",NoMon);

     /* combined thickness (and units) of selected filters, by material, mm */
PV (double,filterAl_mm,   "{P}filterAl",       NoMon);
PV (string,filterAl_u,    "{P}filterAl.EGU",   NoMon);
PV (double,filterTi_mm,   "{P}filterTi",       NoMon);
PV (string,filterTi_u,    "{P}filterTi.EGU",   NoMon);
PV (double,filterGlass_mm,"{P}filterGlass",    NoMon);
PV (string,filterGlass_u, "{P}filterGlass.EGU",NoMon);

     /* filter bank thicknesses in each bank */
PV (double,f1A,"{P}f1A",EvFlag);
PV (double,f2A,"{P}f2A",EvFlag);
PV (double,f3A,"{P}f3A",EvFlag);
PV (double,f4A,"{P}f4A",EvFlag);
PV (double,f1B,"{P}f1B",EvFlag);
PV (double,f2B,"{P}f2B",EvFlag);
PV (double,f3B,"{P}f3B",EvFlag);
PV (double,f4B,"{P}f4B",EvFlag);

     /*
      * material index number for each filter blade
      *  0 == Al
      *  1 == Ti
      *  2 == borosilicate glass
      */
PV (short, Z1A,"{P}Z1A", EvFlag);
PV (short, Z2A,"{P}Z2A", EvFlag);
PV (short, Z3A,"{P}Z3A", EvFlag);
PV (short, Z4A,"{P}Z4A", EvFlag);
PV (short, Z1B,"{P}Z1B", EvFlag);
PV (short, Z2B,"{P}Z2B", EvFlag);
PV (short, Z3B,"{P}Z3B", EvFlag);
PV (short, Z4B,"{P}Z4B", EvFlag);

     /* filter combinations select [0-15], banks A&B */
PV (short, filterPosA, "{P}fPosA", EvFlag);
PV (short, filterPosB, "{P}fPosB", EvFlag);

     /* names of combinations, thick & absorption, bank A */
PV (string, a0, "{P}fPosA.ZRST", NoMon);
PV (string, a1, "{P}fPosA.ONST", NoMon);
PV (string, a2, "{P}fPosA.TWST", NoMon);
PV (string, a3, "{P}fPosA.THST", NoMon);
PV (string, a4, "{P}fPosA.FRST", NoMon);
PV (string, a5, "{P}fPosA.FVST", NoMon);
PV (string, a6, "{P}fPosA.SXST", NoMon);
PV (string, a7, "{P}fPosA.SVST", NoMon);
PV (string, a8, "{P}fPosA.EIST", NoMon);
PV (string, a9, "{P}fPosA.NIST", NoMon);
PV (string, a10, "{P}fPosA.TEST", NoMon);
PV (string, a11, "{P}fPosA.ELST", NoMon);
PV (string, a12, "{P}fPosA.TVST", NoMon);
PV (string, a13, "{P}fPosA.TTST", NoMon);
PV (string, a14, "{P}fPosA.FTST", NoMon);
PV (string, a15, "{P}fPosA.FFST", NoMon);

     /* names of combinations, thick & absorption, bank B */
PV (string, b0, "{P}fPosB.ZRST", NoMon);
PV (string, b1, "{P}fPosB.ONST", NoMon);
PV (string, b2, "{P}fPosB.TWST", NoMon);
PV (string, b3, "{P}fPosB.THST", NoMon);
PV (string, b4, "{P}fPosB.FRST", NoMon);
PV (string, b5, "{P}fPosB.FVST", NoMon);
PV (string, b6, "{P}fPosB.SXST", NoMon);
PV (string, b7, "{P}fPosB.SVST", NoMon);
PV (string, b8, "{P}fPosB.EIST", NoMon);
PV (string, b9, "{P}fPosB.NIST", NoMon);
PV (string, b10, "{P}fPosB.TEST", NoMon);
PV (string, b11, "{P}fPosB.ELST", NoMon);
PV (string, b12, "{P}fPosB.TVST", NoMon);
PV (string, b13, "{P}fPosB.TTST", NoMon);
PV (string, b14, "{P}fPosB.FTST", NoMon);
PV (string, b15, "{P}fPosB.FFST", NoMon);

char	new_msg[256];  
double	updateRate;	/* delay time between updates */
char	*SNLtaskName;
/* short	onOff; */
short	onOff0;
short	onOff1;
short	onOff2;
short	onOff3;

double	transmitA[16];	/* transmission of all of the filter combinations, bank A */
double	transmitB[16];	/* transmission of all of the filter combinations, bank B */
short	bitsA[16];	/* bit patterns for each of the thicknesses, bank A */
short	bitsB[16];	/* bit patterns for each of the thicknesses, bank B */
long	j;

%% #include <stdlib.h>
%% #include <string.h>
%% #include <math.h>
%% static double AlAbsorpLength(double keV);
%% static double TiAbsorb(double keV);
%% static double GlassAbsorb(double keV);
%% static void RecalcFilters(double keV);
%% static void sortDecreasing(double *arr, short *bits, int n);
%% static double thickZ(int Z);
%% static long numInArray(long N, short arr[], short value);

/* 
 * state set:  general
 */
ss general {
	state init {		/* general init for things not specific to bank A or B */
		when () {
			SNLtaskName = macValueGet("name");
			pvGet(pf4DualDebug,SYNC);
			DEBUG_PRINT(1, "init general start in general");
			pvGet(Emono,SYNC);
			PVPUTSTR(filterAl_u,    "mm")
			PVPUTSTR(filterTi_u,    "mm")
			PVPUTSTR(filterGlass_u, "mm")
			PVPUT(calc,0);
			PVPUT(E_using,Emono);
			pvGet(useMono,SYNC);
			pvGet(bankA,SYNC);
			pvGet(bankB,SYNC);
			efClear(pf4DualDebug_mon);
			efClear(Emono_mon);
			efClear(calc_mon);
			efClear(E_using_mon);
			efClear(useMono_mon);
			DEBUG_PRINT(1, "init general complete in general");
		} state recalcBoth
	}


	state idle {					
		/* main program loop */
		when (efTestAndClear(pf4DualDebug_mon)) {
			sprintf(new_msg, "changed debug flag to %d", pf4DualDebug);
			DEBUG_PRINT(1, new_msg);
		} state idle

		when (efTestAndClear(E_using_mon)) {
			PVPUT(useMono,0)
			efClear(useMono_mon);
			sprintf(new_msg, "monochromator energy (pretend) changed %g", E_using);
			DEBUG_PRINT(1, new_msg);
		} state recalcBoth

		when (efTestAndClear(useMono_mon)) {
			sprintf(new_msg, "start/stop using monochromator energy changed to %d", useMono);
			DEBUG_PRINT(1, new_msg);
		} state idle

		when (efTestAndClear(calc_mon)) {
			DEBUG_PRINT(1, "recalculate all");
			if (bankA) {
				filterPosA = numInArray(16,bitsA,relay0A+2*relay1A+4*relay2A+8*relay3A);
				pvPut(filterPosA,SYNC);
				sprintf(new_msg, " based on relays, changed filterPosA to %d", filterPosA);
				DEBUG_PRINT(7, new_msg);
			}
			else
                            PVPUT(filterPosA,0)
			if (bankB) {
				filterPosB = numInArray(16,bitsB,relay0B+2*relay1B+4*relay2B+8*relay3B);
				pvPut(filterPosB,SYNC);
				sprintf(new_msg, " based on relays, changed filterPosB to %d", filterPosB);
				DEBUG_PRINT(7, new_msg);
			}
			else
                            PVPUT(filterPosB,0)
			efClear(filterPosA_mon);
			efClear(filterPosB_mon);
		} state recalcBoth

		when (useMono && efTestAndClear(Emono_mon)) {
			DEBUG_PRINT(1, "monochromator (actual) changed");
			PVPUT(E_using,Emono);
			efClear(E_using_mon);
			epicsThreadSleep(1.5);	/* wait 1.5 sec after energy changes */
		} state recalcBoth

                when( delay(.1) ) {} state idle
	}

	state recalcBoth {
		when ( delay(.1) ) {
			DEBUG_PRINT(3, "mark both banks for recalculation");
%%			bankA = (bankA) ? 3 : 0;			/* mark banks as needing updates */
%%			bankB = (bankB) ? 3 : 0;
			pvPut(bankA,SYNC);
			pvPut(bankB,SYNC);
		} state idle


	}
}



/* 
 * state set:  bankA
 */
ss bankA {
	state init {
		when () {
			DEBUG_PRINT(1, "init bank A start");
/*			PVPUT(f1A,0.1626);					/* = 0.0064 inch */
/*			PVPUT(f2A,0.3226);					/* = 0.0127 inch */
/*			PVPUT(f3A,0.6325);					/* = 0.0249 inch */
/*			PVPUT(f4A,1.27);					/* = 0.0500 inch */
			pvGet(relay0A,SYNC);
			pvGet(relay1A,SYNC);
			pvGet(relay2A,SYNC);
			pvGet(relay3A,SYNC);
			pvGet(f1A,SYNC);
			pvGet(f2A,SYNC);
			pvGet(f3A,SYNC);
			pvGet(f4A,SYNC);
			pvGet(Z1A,SYNC);
			pvGet(Z2A,SYNC);
			pvGet(Z3A,SYNC);
			pvGet(Z4A,SYNC);
			pvGet(filterPosA,SYNC);
			efClear(relay0A_mon);
			efClear(relay1A_mon);
			efClear(relay2A_mon);
			efClear(relay3A_mon);
			efClear(f1A_mon);
			efClear(f2A_mon);
			efClear(f3A_mon);
			efClear(f4A_mon);
			efClear(Z1A_mon);
			efClear(Z2A_mon);
			efClear(Z3A_mon);
			efClear(Z4A_mon);
			efClear(filterPosA_mon);

			efSet(relay0A_mon);					/* forces filters to be read in idle state */
			DEBUG_PRINT(1, "init complete in ss bankA");
%%			bankA = (bankA) ? 3 : 0;			/* mark bankA as needing updates */
			pvPut(bankA,SYNC);
		} state idle
	}

	state idle {								/* main program loop */
		when (bankA==0) {						/* do nothing for disabled bank */
			DEBUG_PRINT(1, "bank A is off, wait for it to turn on");
		}	state bankOff

		when (efTestAndClear(f1A_mon) || efTestAndClear(f2A_mon) || efTestAndClear(f3A_mon) || efTestAndClear(f4A_mon)) {
			/* changed the defined thickness of a filter in bank A */
			sprintf(new_msg, "filters changed, f1A=%g, f2A=%g, f3A=%g, f4A=%g", f1A,f2A,f3A,f4A);
			DEBUG_PRINT(1, new_msg);
%%			bankA = (bankA) ? 3 : 0;			/* mark bankA as needing updates */
			pvPut(bankA,SYNC);
		} state idle

		when (efTestAndClear(Z1A_mon) || efTestAndClear(Z2A_mon) || efTestAndClear(Z3A_mon) || efTestAndClear(Z4A_mon)) {
			/* changed the defined element of a filter in bank A */
			sprintf(new_msg, "filters changed, Z1A=%d, Z2A=%d, Z3A=%d, Z4A=%d", Z1A,Z2A,Z3A,Z4A);
			DEBUG_PRINT(1, new_msg);
%%			bankA = (bankA) ? 3 : 0;			/* mark bankA as needing updates */
			pvPut(bankA,SYNC);
		} state idle

		when (efTestAndClear(relay0A_mon) || efTestAndClear(relay1A_mon) || efTestAndClear(relay2A_mon) || efTestAndClear(relay3A_mon)) {
			sprintf(new_msg, "relays of bank A changed to (%d, %d, %d, %d)", relay0A,relay1A,relay2A,relay3A);
			DEBUG_PRINT(1, new_msg);
			filterPosA = numInArray(16,bitsA,relay0A+2*relay1A+4*relay2A+8*relay3A);
			pvPut(filterPosA,SYNC);
			j = 1;
			j = (j << filterPosA);				/* integer with a single bit set (only bits 0-15) */
			PVPUT(bitFlagA,j);					/* indicate selected button */
			PVPUT(statusA,bitsA[filterPosA])	/* show correct status of filters */
			efClear(filterPosA_mon);
%%			bankA = (bankA) ? 2 : 0;			/* update only enabled banks */
%%			bankB = (bankB) ? 2 : 0;
			pvPut(bankA,SYNC);
			pvPut(bankB,SYNC);
		} state idle

		when (efTestAndClear(filterPosA_mon)) {/* change the filter positions in bank A */
			pvGet(filterPosA,SYNC);
			sprintf(new_msg, "pushed filter button in bank A, change filter to %d, bits=%d", filterPosA,bitsA[filterPosA]);
			DEBUG_PRINT(1, new_msg);
%%			onOff0 = 1 & bitsA[filterPosA];
%%			onOff1 = (2 & bitsA[filterPosA])/2;
%%			onOff2 = (4 & bitsA[filterPosA])/4;
%%			onOff3 = (8 & bitsA[filterPosA])/8;
			/* the test of onOffN, makes new filters go in before old ones come out */
			if (onOff0) PVPUT(relay0A,onOff0)	/* first set the ON bits */
			if (onOff1) PVPUT(relay1A,onOff1)
			if (onOff2) PVPUT(relay2A,onOff2)
			if (onOff3) PVPUT(relay3A,onOff3)
			epicsThreadSleep(0.5);			/* wait 1/2 sec for filters to go in */
			if (!onOff0) PVPUT(relay0A,onOff0)	/* next set the OFF bits */
			if (!onOff1) PVPUT(relay1A,onOff1)
			if (!onOff2) PVPUT(relay2A,onOff2)
			if (!onOff3) PVPUT(relay3A,onOff3)
			sprintf(new_msg, "          changed relays of bank A (%d, %d, %d, %d)", relay0A,relay1A,relay2A,relay3A);
			DEBUG_PRINT(2, new_msg);
			sprintf(new_msg, "          the onOff values used are %d, %d, %d, %d)", onOff0,onOff1,onOff2,onOff3);
			DEBUG_PRINT(2, new_msg);
		} state idle

                when( delay(.1) ) {} state idle
	}

	state bankOff {
		when (bankA) {
			DEBUG_PRINT(1, "switching bankA on in state bankOff");
			pvGet(bankA,SYNC);
		} state idle

                when( delay(.1) ) {} state bankOff
	}
}



/* 
 * state set:  bankB
 */
ss bankB {
	state init {
		when () {
			DEBUG_PRINT(1, "init bank B start");
/*			PVPUT(f1A,0.25); */
/*			PVPUT(f2A,0.5);  */
/*			PVPUT(f3A,1.0);  */
/*			PVPUT(f4A,2.0);  */
			pvGet(relay0B,SYNC);
			pvGet(relay1B,SYNC);
			pvGet(relay2B,SYNC);
			pvGet(relay3B,SYNC);
			pvGet(f1B,SYNC);
			pvGet(f2B,SYNC);
			pvGet(f3B,SYNC);
			pvGet(f4B,SYNC);
			pvGet(Z1B,SYNC);
			pvGet(Z2B,SYNC);
			pvGet(Z3B,SYNC);
			pvGet(Z4B,SYNC);
			efClear(relay0B_mon);
			efClear(relay1B_mon);
			efClear(relay2B_mon);
			efClear(relay3B_mon);
			efClear(f1B_mon);
			efClear(f2B_mon);
			efClear(f3B_mon);
			efClear(f4B_mon);
			efClear(Z1B_mon);
			efClear(Z2B_mon);
			efClear(Z3B_mon);
			efClear(Z4B_mon);
			efClear(filterPosB_mon);

			efSet(relay0B_mon);					/* forces filters to be read in idle state */
			DEBUG_PRINT(1, "init complete in ss bankB");
%%			bankB = (bankB) ? 3 : 0;			/* mark bankB as needing updates */
			pvPut(bankB,SYNC);
		} state bankOff
	}

	state idle {								/* main program loop */
		when (bankB==0) {						/* do nothing for disabled bank */
                        DEBUG_PRINT(1, "bank B is off, wait for it to turn on");
		} state bankOff

		when (efTestAndClear(f1B_mon) || efTestAndClear(f2B_mon) || efTestAndClear(f3B_mon) || efTestAndClear(f4B_mon)) {
			/* changed the defined thickness of a filter in bank B */
			sprintf(new_msg, "filters changed, f1B=%g, f2B=%g, f3B=%g, f4B=%g", f1B,f2B,f3B,f4B);
			DEBUG_PRINT(1, new_msg);
%%			bankB = (bankB) ? 3 : 0;			/* mark bankB as needing updates */
			pvPut(bankB,SYNC);
		} state idle

		when (efTestAndClear(Z1B_mon) || efTestAndClear(Z2B_mon) || efTestAndClear(Z3B_mon) || efTestAndClear(Z4B_mon)) {
			/* changed the defined element of a filter in bank B */
			sprintf(new_msg, "filters changed, Z1B=%d, Z2B=%d, Z3B=%d, Z4B=%d", Z1B,Z2B,Z3B,Z4B);
			DEBUG_PRINT(1, new_msg);
%%			bankB = (bankB) ? 3 : 0;			/* mark bankB as needing updates */
			pvPut(bankB,SYNC);
		} state idle

		when (efTestAndClear(relay0B_mon) || efTestAndClear(relay1B_mon) || efTestAndClear(relay2B_mon) || efTestAndClear(relay3B_mon)) {
			sprintf(new_msg, "relays of bank B changed to (%d, %d, %d, %d)", relay0B,relay1B,relay2B,relay3B);
			DEBUG_PRINT(1, new_msg);
			filterPosB = numInArray(16,bitsB,relay0B+2*relay1B+4*relay2B+8*relay3B);
			pvPut(filterPosB,SYNC);
			j = 1;
			j = (j << filterPosB);				/* integer with a single bit set (only bits 0-15) */
			PVPUT(bitFlagB,j);					/* indicate selected button */
			PVPUT(statusB,bitsB[filterPosB])	/* show correct status of filters */
			efClear(filterPosB_mon);
%%			bankA = (bankA) ? 2 : 0;			/* update only enabled banks */
%%			bankB = (bankB) ? 2 : 0;
			pvPut(bankA,SYNC);
			pvPut(bankB,SYNC);
		} state idle

		when (efTestAndClear(filterPosB_mon)) {			/* change the filter positions in bank B */
			sprintf(new_msg, "pushed filter button in bank B, change filter to %d, bits=%d", filterPosB,bitsB[filterPosB]);
			DEBUG_PRINT(1, new_msg);
%%			onOff0 = 1 & bitsB[filterPosB];
%%			onOff1 = (2 & bitsB[filterPosB])/2;
%%			onOff2 = (4 & bitsB[filterPosB])/4;
%%			onOff3 = (8 & bitsB[filterPosB])/8;
			/* the test of onOffN, makes new filters go in before old ones come out */
			if (onOff0) PVPUT(relay0B,onOff0)	/* first set the ON bits */
			if (onOff1) PVPUT(relay1B,onOff1)
			if (onOff2) PVPUT(relay2B,onOff2)
			if (onOff3) PVPUT(relay3B,onOff3)
			epicsThreadSleep(0.5);			/* wait 1/2 sec for filters to go in */
			if (!onOff0) PVPUT(relay0B,onOff0)	/* next set the OFF bits */
			if (!onOff1) PVPUT(relay1B,onOff1)
			if (!onOff2) PVPUT(relay2B,onOff2)
			if (!onOff3) PVPUT(relay3B,onOff3)
			sprintf(new_msg, "          changed relays of bank B (%d, %d, %d, %d)", relay0B,relay1B,relay2B,relay3B);
			DEBUG_PRINT(2, new_msg);
			sprintf(new_msg, "          the onOff values used are %d, %d, %d, %d)", onOff0,onOff1,onOff2,onOff3);
			DEBUG_PRINT(2, new_msg);
		} state idle

                when( delay(.1) ) {} state idle
	}

	state bankOff {
		when (bankB) {
			DEBUG_PRINT(1, "switching bankB on in state bankOff");
			pvGet(bankB,SYNC);
		} state idle

                when( delay(.1) ) {} state bankOff
	}
}



/* 
 * state set:  updates
 */
ss updates {
	state init {
		when () {
			updateRate = 10.0;					/* forced update time in seconds */
			DEBUG_PRINT(1, "init complete in ss updates");
		} state doUpdates
	}

	state doUpdates {
		when(bankB==3) {						/* flag for update of bank B filters */
			pvGet(E_using,SYNC);
			efClear(E_using_mon);
			RecalcFilters(E_using);

/*			PVPUT(statusB,bitsB[filterPosB])	/* show correct status of filters */
/*			j = 1;
/*			j = (j << filterPosB);				/* integer with a single bit set (only bits 0-15) */
/*			PVPUT(bitFlagB,j);					/* indicate selected button */
			sprintf(b0, "%.2e", transmitB[0]);   pvPut(b0,SYNC);	/* set button names to transmission factors */
			sprintf(b1, "%.2e", transmitB[1]);   pvPut(b1,SYNC);
			sprintf(b2, "%.2e", transmitB[2]);   pvPut(b2,SYNC);
			sprintf(b3, "%.2e", transmitB[3]);   pvPut(b3,SYNC);
			sprintf(b4, "%.2e", transmitB[4]);   pvPut(b4,SYNC);
			sprintf(b5, "%.2e", transmitB[5]);   pvPut(b5,SYNC);
			sprintf(b6, "%.2e", transmitB[6]);   pvPut(b6,SYNC);
			sprintf(b7, "%.2e", transmitB[7]);   pvPut(b7,SYNC);
			sprintf(b8, "%.2e", transmitB[8]);   pvPut(b8,SYNC);
			sprintf(b9, "%.2e", transmitB[9]);   pvPut(b9,SYNC);
			sprintf(b10,"%.2e", transmitB[10]);  pvPut(b10,SYNC);
			sprintf(b11,"%.2e", transmitB[11]);  pvPut(b11,SYNC);
			sprintf(b12,"%.2e", transmitB[12]);  pvPut(b12,SYNC);
			sprintf(b13,"%.2e", transmitB[13]);  pvPut(b13,SYNC);
			sprintf(b14,"%.2e", transmitB[14]);  pvPut(b14,SYNC);
			sprintf(b15,"%.2e", transmitB[15]);  pvPut(b15,SYNC);

			PVPUT(bankB,2)						/* next update transmission */
			sprintf(new_msg, "   in doUpdates, bankB==3, transmitB[1] = %g, b1='%s'", transmitB[1],b1);
			DEBUG_PRINT(2, new_msg);
			sprintf(new_msg, "        bitsB = (%d, %d, %d, %d, %d, %d, %d, %d)",bitsB[0],bitsB[1],bitsB[2],bitsB[3],bitsB[4],bitsB[5],bitsB[6],bitsB[7]);
			DEBUG_PRINT(5, new_msg);
			sprintf(new_msg, "        bitsB = (%d, %d, %d, %d, %d, %d, %d, %d)",bitsB[8],bitsB[9],bitsB[10],bitsB[11],bitsB[12],bitsB[13],bitsB[14],bitsB[15]);
			DEBUG_PRINT(5, new_msg);
			DEBUG_PRINT(5, new_msg);
		} state doUpdates

		when(bankA==3) {						/* flag for update of bank A filters */
			pvGet(E_using,SYNC);
			efClear(E_using_mon);
			RecalcFilters(E_using);

/*			PVPUT(statusA,bitsA[filterPosA])	/* show correct status of filters */
/*			j = 1;
/*			j = (j << filterPosA);				/* integer with a single bit set (only bits 0-15) */
/*			PVPUT(bitFlagA,j);					/* indicate selected button */
			sprintf(a0, "%.2e", transmitA[0]);   pvPut(a0,SYNC);	/* set button names to transmission factors */
			sprintf(a1, "%.2e", transmitA[1]);   pvPut(a1,SYNC);
			sprintf(a2, "%.2e", transmitA[2]);   pvPut(a2,SYNC);
			sprintf(a3, "%.2e", transmitA[3]);   pvPut(a3,SYNC);
			sprintf(a4, "%.2e", transmitA[4]);   pvPut(a4,SYNC);
			sprintf(a5, "%.2e", transmitA[5]);   pvPut(a5,SYNC);
			sprintf(a6, "%.2e", transmitA[6]);   pvPut(a6,SYNC);
			sprintf(a7, "%.2e", transmitA[7]);   pvPut(a7,SYNC);
			sprintf(a8, "%.2e", transmitA[8]);   pvPut(a8,SYNC);
			sprintf(a9, "%.2e", transmitA[9]);   pvPut(a9,SYNC);
			sprintf(a10,"%.2e", transmitA[10]);  pvPut(a10,SYNC);
			sprintf(a11,"%.2e", transmitA[11]);  pvPut(a11,SYNC);
			sprintf(a12,"%.2e", transmitA[12]);  pvPut(a12,SYNC);
			sprintf(a13,"%.2e", transmitA[13]);  pvPut(a13,SYNC);
			sprintf(a14,"%.2e", transmitA[14]);  pvPut(a14,SYNC);
			sprintf(a15,"%.2e", transmitA[15]);  pvPut(a15,SYNC);
			PVPUT(bankA,2)						/* next update transmission */
			DEBUG_PRINT(2, "in doUpdates, bankA==3, ...");
			sprintf(new_msg, "   in doUpdates, bankA==3, transmitA[1] = %g,  a1='%s'", transmitA[1],a1);
			DEBUG_PRINT(2, new_msg);
			sprintf(new_msg, "   in doUpdates, bankA==3, transmitA[1] = %g,  a1='%s'", transmitA[1],a1);
			DEBUG_PRINT(2, new_msg);
			sprintf(new_msg, "        bitsA = (%2d, %2d, %2d, %2d, %2d, %2d, %2d, %2d,",bitsA[0],bitsA[1],bitsA[2],bitsA[3],bitsA[4],bitsA[5],bitsA[6],bitsA[7]);
			DEBUG_PRINT(5, new_msg);
			sprintf(new_msg, "                 %2d, %2d, %2d, %2d, %2d, %2d, %2d, %2d)",bitsA[8],bitsA[9],bitsA[10],bitsA[11],bitsA[12],bitsA[13],bitsA[14],bitsA[15]);
			DEBUG_PRINT(5, new_msg);
		} state doUpdates

		when((bankA==2) || (bankB==2)) {		/* flag for update of transmission */
%%			filterAl_mm = thickZ(0);
			pvPut(filterAl_mm,SYNC);					/* show selected Al filter thickness (mm) */
%%			filterTi_mm = thickZ(1);
			pvPut(filterTi_mm,SYNC);					/* show selected Ti filter thickness (mm) */
%%			filterGlass_mm = thickZ(2);
			pvPut(filterGlass_mm,SYNC);				/* show selected Glass filter thickness (mm) */

			trans = transmitA[filterPosA]*transmitB[filterPosB];
			pvPut(trans,SYNC);						/* show total selected filter transmission */
			if (trans>0.) PVPUT(invTrans,1/trans)	/* show 1/transmission too */

			PVPUT(statusA,bitsA[filterPosA])	/* show correct status of filters */
			j = 1;
			j = (j << filterPosA);				/* integer with a single bit set (only bits 0-15) */
			PVPUT(bitFlagA,j);					/* indicate selected button */
			PVPUT(statusB,bitsB[filterPosB])
			j = 1;
			j = (j << filterPosB);				/* integer with a single bit set (only bits 0-15) */
			PVPUT(bitFlagB,j);					/* indicate selected button */

%%			bankA = (bankA) ? 1 : 0;			/* all banks updated */
%%			bankB = (bankB) ? 1 : 0;
			pvPut(bankA,SYNC);
			pvPut(bankB,SYNC);
			sprintf(new_msg, "in updateTransmission, trans = %g", trans);
			DEBUG_PRINT(2, new_msg);
			sprintf(new_msg, "         filterPosA=%d, transmitA=%g", filterPosA, transmitA[filterPosA]);
			DEBUG_PRINT(4, new_msg);
			sprintf(new_msg, "         filterPosB=%d, transmitB=%g", filterPosB, transmitB[filterPosB]);
			DEBUG_PRINT(4, new_msg);
		} state doUpdates

		when (delay(updateRate)) {				/* after a wait, check chi just to be sure */
			DEBUG_PRINT(5, "periodic update");
%%			bankA = (bankA) ? 3 : 0;		/* mark banks as needing updates */
%%			bankB = (bankB) ? 3 : 0;
			pvPut(bankA,SYNC);
			pvPut(bankB,SYNC);
		} state doUpdates

                when( delay(.1) ) {} state doUpdates
	}
}





%{

double AlAbsorpLength(					/* calculate absorption length of Al (microns) */
double keV)						/* energy in keV */
{
	double	Wcoef0[]={1.90195,-0.00120447,4.3745e-7,8.68635e-11,3.40793e-15,-1.05816e-19,5.83389e-25};
	double	Wcoef1[]={-1625.33,0.328256,-2.68391e-5,1.26554e-9,-2.41557e-14,2.12864e-19,-7.28743e-25};
	double	kink = 26797.5;
	double	*pointer;
	double	sum,power;
	double	eV;
	int		i;

	eV = keV * 1000;		/* convert to eV */
	if (eV>60000.) eV = 60000.;
	pointer = (eV<kink) ? Wcoef0 : Wcoef1;
	sum = 0.;
	power=1.;
	for (i=0;i<7;i++) {
		sum += pointer[i] * power;
		power *= eV;
	}
	return sum;
}


double TiAbsorb(				/* absorption length of Ti in microns, (= 1/mu) */
double keV)					/* energy in keV */
{
	double eV;				/* energy in eV */
	double mu;				/* mu in 1/micron */
						/* for Ti, Kedge = 4966.4,   Ledge = 563.7 */
	eV = keV * 1000.;			/* convert keV to eV */
	if (eV<1e3) mu = 0;			/* this routine only good above 1000 eV */
	else if (eV<4966.4) {			/* above L-edge, and below K-edge */
		double c0=0.00092284;
		double c1=2.5891e+08;
		double powA=-2.6651;
		mu = c0+c1*pow(eV,powA);
	}
	else {					/* above the K-edge */
		/* coefs={5.63768167444831e-05  24061652313.4169  -2.91380053083527  -0.268162843203489  3.74221014277593e-05  -1.05663835782997  -0.000570785180739491} */
		double offset = 5.63768167444831e-5;
		double amp = 24061652313.4169;
		double powB = -2.91380053083527;
		double intercept = -0.268162843203489;
		double slope = 3.74221014277593e-5;

		double ampExp = -1.05663835782997;
		double invTau = -0.000570785180739491;
		double extra = (eV < 6456) ? (intercept+slope*eV) : (ampExp*exp(invTau*eV));
		mu = (offset + amp*pow(eV,powB) + extra);
	}
	return (1./mu);
}


/* calculation for glass, see the Igor experiment "glass absorption.pxp" for the coefficients.
 *
 *	SiO2	0.722	wt fraction
 *	Na2O	0.143
 *	CaO	0.064
 *	MgO	0.043
 *	Al2O3	0.012
 *	K2O	0.012
 *	SO2	0.003
 *	Fe2O3	0.0003
 */
double GlassAbsorb(				/* absorption length of Glass in microns, (= 1/mu) */
double keV)					/* energy in keV */
{
	double absLength;			/* absorption length (micron) */
	double c0,c1,c2;
	double c3,c4,c5,c6,c7;			/* more coefficients for the last energy range */
	double keV2, keVn;			/* square of energy, and powers of energy */
	keV2 = keV*keV;

	if (keV<2) absLength = 0;		/* this routine only good above 2 keV */
	else if (keV<2.472) {			/* below Sulphur K edge */
		c0 = 0.5059463974;
		c1 = -0.1259565387;
		c2 = 0.01763933889;
		absLength = c0 + c1*keV + c2*keV2;
	}
	else if (keV<3.6084) {			/* above Sulphur K and below Potassium K */
		c0 = 0.4570603245;
		c1 = -0.08869920063;
		c2 = 0.01032934773;
		absLength = c0 + c1*keV + c2*keV2;
	}
	else if (keV<4.0385) {			/* above Potassium K and below Calcium K */
		c0 =  0.3708574258;
		c1 =  -0.04453063888;
		c2 =  3.979930821e-3;
		absLength = c0 + c1*keV + c2*keV2;
	}
	else if (keV<7.112) {			/* above Calcium K and below Iron K */
		c0 = 0.2830642538;
		c1 = -0.0223186563;
		c2 = 1.412011413e-3;
		absLength = c0 + c1*keV + c2*keV2;
	}
	else {					/* above Iron K */
		c0 = 0.2715022686;
		c1 = -0.02428526798;
		c2 = 2.984228845e-3;
		c3 = -2.003675391e-4;
		c4 = 7.983398893e-6;
		c5 = -1.869726202e-7;
		c6 = 2.378962632e-9;
		c7 = -1.270082060e-11;
		absLength = c0 + c1*keV;
		keVn = keV2;	absLength += c2*keVn;
		keVn *= keV;	absLength += c3*keVn;
		keVn *= keV;	absLength += c4*keVn;
		keVn *= keV;	absLength += c5*keVn;
		keVn *= keV;	absLength += c6*keVn;
		keVn *= keV;	absLength += c7*keVn;
	}
	absLength *= keV*keV*keV;	/* finally scale by energy^3 */
	return (absLength);
}


void RecalcFilters(						/* recalculate all of the filters and attenuations */
double keV)								/* energy in keV */
{
	double	absLenAl,absLenTi,absLenGlass;	/* absorption length for this energy (micron) */
	double	xAl, xTi, xGlass;				/* thickneses of Al, Ti, and Glass (mm) */
	int		i;

	if (debug_flag >= 10) {
		printf("\n");
	}
	absLenAl = AlAbsorpLength(keV);
	absLenTi = TiAbsorb(keV);
	absLenGlass = GlassAbsorb(keV);
	for (i=0;i<16;i++) {
		if (bankA) {
			xAl     = (Z1A==0 && 1&i) ? f1A	: 0;	/* for bank A */
			xAl    += (Z2A==0 && 2&i) ? f2A	: 0;
			xAl    += (Z3A==0 && 4&i) ? f3A	: 0;
			xAl    += (Z4A==0 && 8&i) ? f4A	: 0;
			xTi    =  (Z1A==1 && 1&i) ? f1A	: 0;
			xTi    += (Z2A==1 && 2&i) ? f2A	: 0;
			xTi    += (Z3A==1 && 4&i) ? f3A	: 0;
			xTi    += (Z4A==1 && 8&i) ? f4A	: 0;
			xGlass  = (Z1A==2 && 1&i) ? f1A	: 0;
			xGlass += (Z2A==2 && 2&i) ? f2A	: 0;
			xGlass += (Z3A==2 && 4&i) ? f3A	: 0;
			xGlass += (Z4A==2 && 8&i) ? f4A	: 0;
			if (debug_flag >= 10) {
				printf("       in RecalcFilters, bank A, %3d, Aluminum = %g,   Titanium = %g,   Glass = %g\n",i,xAl,xTi,xGlass);
			}
			transmitA[i] =  exp(-xAl*1000./absLenAl);
			transmitA[i] *= exp(-xTi*1000./absLenTi);
			transmitA[i] *= exp(-xGlass*1000./absLenGlass);
		}
		else transmitA[i] =  1.;
		bitsA[i] = i;

		if (bankB) {
			xAl     = (Z1B==0) ? ((1&i)*f1B)	: 0;	/* for bank B */
			xAl    += (Z2B==0) ? ((2&i)/2*f2B)	: 0;
			xAl    += (Z3B==0) ? ((4&i)/4*f3B)	: 0;
			xAl    += (Z4B==0) ? ((8&i)/8*f4B)	: 0;
			xTi     = (Z1B==1) ? ((1&i)*f1B)	: 0;
			xTi    += (Z2B==1) ? ((2&i)/2*f2B)	: 0;
			xTi    += (Z3B==1) ? ((4&i)/4*f3B)	: 0;
			xTi    += (Z4B==1) ? ((8&i)/8*f4B)	: 0;
			xGlass  = (Z1B==2) ? ((1&i)*f1B)	: 0;
			xGlass += (Z2B==2) ? ((2&i)/2*f2B)	: 0;
			xGlass += (Z3B==2) ? ((4&i)/4*f3B)	: 0;
			xGlass += (Z4B==2) ? ((8&i)/8*f4B)	: 0;
			if (debug_flag >= 10) {
				printf("       in RecalcFilters, bank B, %3d, Aluminum = %g,   Titanium = %g,   Glass = %g\n",i,xAl,xTi,xGlass);
			}
			transmitB[i] =  exp(-xAl*1000./absLenAl);
			transmitB[i] *= exp(-xTi*1000./absLenTi);
			transmitB[i] *= exp(-xGlass*1000./absLenGlass);
		}
		else transmitB[i] = 1.;
		bitsB[i] = i;
	}
	if (bankA) sortDecreasing(transmitA,bitsA,16);	/* sort by transmission, transmission and bits */
	if (bankB) sortDecreasing(transmitB,bitsB,16);	/* and again for bank B */
}



void sortDecreasing(
double	*arr,
short	*bits,
int	n)						/* number of elements */
{
	int	ii, jj;
	double	a;
	short	b;

	if (debug_flag >= 9) {
		printf("       before sorting, bits={%d",bits[0]);
		for (ii=1; ii<n; ii++) {
			printf(", %d", bits[ii]);
		}
		printf("\n");
		if (debug_flag >= 10) {
			printf("                   transmit={%g",arr[0]);
			for (ii=1; ii<n/3; ii++) {
				printf(", %g", arr[ii]);
			}
			printf("\n");
		}
	}


	for (jj=1;jj<n;jj++) {
		a = arr[jj];
		b = bits[jj];
		ii = jj-1;
		while(ii>=0 && arr[ii]<a) {
			arr[ii+1] = arr[ii];
			bits[ii+1] = bits[ii];
			ii--;
		}
		arr[ii+1] = a;
		bits[ii+1] = b;
	}

	if (debug_flag >= 8) {
		printf("        after sorting, bits={%d",bits[0]);
		for (ii=1; ii<n; ii++) {
			printf(", %d", bits[ii]);
		}
		printf("\n");
		if (debug_flag >= 10) {
			printf("                   transmit={%g",arr[0]);
			for (ii=1; ii<n/3; ii++) {
				printf(", %g", arr[ii]);
			}
			printf("\n");
		}
	}
}


double thickZ(		/* add up current thickness of all filters with material number Z */
int	Z)		/* material number */
{
	double sum;
	sum = 0;

	if (bankA) {
		sum += (relay0A && (Z1A==Z)) ? f1A : 0;
		sum += (relay1A && (Z2A==Z)) ? f2A : 0;
		sum += (relay2A && (Z3A==Z)) ? f3A : 0;
		sum += (relay3A && (Z4A==Z)) ? f4A : 0;
	}

	if (bankB) {
		sum += (relay0B && (Z1B==Z)) ? f1B : 0;
		sum += (relay1B && (Z2B==Z)) ? f2B : 0;
		sum += (relay2B && (Z3B==Z)) ? f3B : 0;
		sum += (relay3B && (Z4B==Z)) ? f4B : 0;
	}
	return sum;
}


long numInArray(	/* find the arrays element contianing value, return index, arr[i]==value */
long	N,		/* number of elements in array */
short	arr[],		/* array of length N */
short	value)		/* value to search for */
{
	int		i;
	for (i=0;i<N;i++) if (value==arr[i]) return i;
	return 0;			/* if none found, at least return legal index */
}


}%
