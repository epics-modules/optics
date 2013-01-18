program filterDrive("NAME=filterDrive, P=TEST:, R=filter:, NUM_FILTERS=8")

/*============================================================================
**  filterDrive.st
**  ==============
**
**  SNL program to drive a set of beamline filters.
**
**  The code works for a variable number of filter blades, each of which may
**  be enabled/disabled and locked/freed individually. Disabling a filter
**  blade removes it completely from the transmission calculation, while
**  locking a blade keeps it in its current position (in our out) and does
**  not allow it to change when a different transmission is required, but
**  always includes this blade in the calculation of the total transmission.
**
**  The $(P)$(R):TransmissionSetpoint, (P)$(R):TransmissionStepUp and 
**  (P)$(R):TransmissionStepDown records are monitored and, every time one of
**  them changes, the filters are moved in and out accordingly.
**
**  The following macro substitutions are required:
**    NAME:        The name of the filterDrive program.
**                 e.g.: NAME="Sector 33-ID-D filters"
**    P:           The IOC prefix for the filterDriver records.
**                 e.g.: P="ioc33idd:"
**    R:           The common record name for the filterDriver records.
**                 e.g.: R="filter:"
**    NUM_FILTERS: The number of filter blades used in the calculations.
**                 e.g.: NUM_FILTERS = 8
**
**  The filter blade records must be named with the following naming
**  scheme, and numbered (N) consecutively starting from 1:
**    $(P)$(R)Fi$(N)
**
**  The filter transmission calculations are based on the filter material
**  and thickness, using the Chanter Tables to interpolate the material's
**  absorption coefficient for the requested energy:
**    C.T. Chantler, Journal of Physical and Chemical Reference Data 24,
**    71 (1995).
**
**  Note: This code is based both on the filter code from the X04SA beamline
**        at the Swiss Light Source, originally written by D. Maden, and the
**        pf4 filter code from synApps with major contributions from
**        J. Tischler, T. Mooney, and P. Jemian.
**
**  Created: 2013-01-16 by C.M. Schlepuetz @ APS
** 
**  $Revision: $
**  $Date: $
**  $Author: $
**  $URL: $
**==========================================================================*/

/* Ensure we are translated reentrantly */
option +r;

%%#include <string.h>
%%#include <math.h>
%%#include <stdlib.h> /* malloc */
%%#include "chantler.h"

/* Maximum number of filters supported.  Note MAX_PERMS = 1<<MAX_ENABLED */
#define MAX_FILTERS 32
#define MAX_ENABLED 16
#define MAX_PERMS 65536


/*----------------------------------------------------------------------------
**  Declare variables and assign them to channels
*/

/* The global busy record */
int STATUS_BUSY;
assign STATUS_BUSY to "{P}{R}Status";
monitor STATUS_BUSY;

/* The update flag */
int STATUS_UPDATE;
assign STATUS_UPDATE to "{P}{R}Update";
monitor STATUS_UPDATE;

/* Debug Level:
** If non-zero, it causes debug printout:
**     Bit 0 (0x1) --> general debug info.
**     Bit 1 (0x2) --> global transmission calculation and sorting.
**     Bit 2 (0x4) --> filter blade transmission calculation.
**     Bit 3 (0x8) --> filter blade interpolation steps.
*/
int DEBUG;
assign DEBUG to "{P}{R}Debug";
monitor DEBUG;

/* The transmission readback value */
double TRANSMISSION;
assign TRANSMISSION to "{P}{R}Transmission";

/* The FilterMask readback value */
int FILTER_MASK;
assign FILTER_MASK to "{P}{R}FilterMask";

/* The transmission setpoint*/
evflag  EvFlgTRANSM_SETPT;
double  TRANSM_SETPT;                        
assign  TRANSM_SETPT to "{P}{R}TransmissionSetpoint";
monitor TRANSM_SETPT;
sync    TRANSM_SETPT EvFlgTRANSM_SETPT;

/* Transmission step up */
int     TRANSM_UP;                          
assign  TRANSM_UP to "{P}{R}TransmissionStepUp";
monitor TRANSM_UP;

/*Transmission  step down */
int     TRANSM_DN;                          
assign  TRANSM_DN to "{P}{R}TransmissionStepDown";
monitor TRANSM_DN;

evflag  needRecalc;
evflag  newEnergy;

/* The beam energy */
double ENERGY;
assign ENERGY to "{P}{R}Energy";
monitor ENERGY;
sync ENERGY newEnergy;

/* Diagnostic message */
string  MSGE;
assign  MSGE to "{P}{R}Message";

/* Wait time for filters to be inserted/removed */
double FILTER_WAIT_TIME;
assign FILTER_WAIT_TIME to "{P}{R}WaitTime";

/* Define array of transmissions */
double  TRANSM[MAX_FILTERS];
assign  TRANSM to {"","","","","","","","","","","","","","","","",
                   "","","","","","","","","","","","","","","",""};

/* Define array of thicknesses */
double  THICK[MAX_FILTERS];
assign  THICK to {"","","","","","","","","","","","","","","","",
                  "","","","","","","","","","","","","","","",""};
monitor THICK;
sync THICK needRecalc;

/* Define array of filter materials */
string  MATER[MAX_FILTERS];
assign  MATER to {"","","","","","","","","","","","","","","","",
                  "","","","","","","","","","","","","","","",""};
monitor MATER;
sync MATER needRecalc;

/* Define array for LOCK status of filters */
int     LOCK[MAX_FILTERS];
assign  LOCK to {"","","","","","","","","","","","","","","","",
                 "","","","","","","","","","","","","","","",""};
monitor LOCK;
sync LOCK needRecalc;

/* Define array of filters activators */
int     SET[MAX_FILTERS];
assign  SET to {"","","","","","","","","","","","","","","","",
                "","","","","","","","","","","","","","","",""};
monitor SET;

/* Define array for the enable/disable status of the filters */
int     ENBL[MAX_FILTERS];
assign  ENBL to {"","","","","","","","","","","","","","","","",
                 "","","","","","","","","","","","","","","",""};
monitor ENBL;
sync ENBL needRecalc;

/* Define array of PV links to the actual output channels */
string  OUTLINK[MAX_FILTERS];
assign  OUTLINK to {"","","","","","","","","","","","","","","","",
                "","","","","","","","","","","","","","","",""};
/* Define array for the actual output channels */
int     OUT[MAX_FILTERS];
assign  OUT to {"","","","","","","","","","","","","","","","",
                "","","","","","","","","","","","","","","",""};

char     *name;
char     *prefix;
char     *record;
int      firstTime;
int      changeFlag;
int      updateFlag;
int      nFltrs;
int      nEnabled;
int      nPerms;
int      ind;
int      indNow;
int      i;
int      j;
int      k;
int      myAction;
double   transNow;
int      fltrsInNow;
char     str[64];
double   transMis[MAX_PERMS];
int      fltrsIn[MAX_PERMS];
string   buff0;
string   buff1;
  

/*============================================================================
** C-code (enclosed in "%{" ... "}%")
**==========================================================================*/
%{

/*----------------------------------------------------------------------------
**  A Merge Sort (ref: http://en.wikipedia.org/wiki/Merge_sort)
**--------------------------------------------------------------------------*/
static void Merge(double v[], 
                  int    w[],
                  int    start,
                  int    mid,
                  int    end)
{
  int     i, j, k;
  double *tmpd = malloc(sizeof(double) * (end - start));
  int    *tmpi = malloc(sizeof(int)    * (end - start));

  i = start;
  j = mid;
  k = 0;
  while((i < mid) && (j < end)) {
    if(v[i] <= v[j]) {
      tmpd[k]   = v[i];
      tmpi[k++] = w[i++];
    } else {
      tmpd[k]   = v[j];
      tmpi[k++] = w[j++];
    }
  }
  while(i < mid) {
    tmpd[k]   = v[i];
    tmpi[k++] = w[i++];
  }
  while(j < end) {
    tmpd[k]   = v[j];
    tmpi[k++] = w[j++];
  }
  for(i = 0; i < (end-start); i++) {
    v[start+i] = tmpd[i];
    w[start+i] = tmpi[i];
  }
  free(tmpd); 
  free(tmpi); 
}

/*--------------------------------------------------------------------------*/
static void Sort(double arr0[],
                 int    arr1[],
                 int    begin,
                 int    end) {

  int mid;

  if(begin == end) return; 
  if(begin == end - 1) return;
  mid = (begin + end) / 2;
  Sort(arr0, arr1, begin, mid);
  Sort(arr0, arr1, mid, end);
  Merge(arr0, arr1, begin, mid, end);
}

/*----------------------------------------------------------------------------
**  cvtToBin - convert an integer to a binary representation.
**             The converted string has least sig bit on left
**             (to match the order of filters in beam).
**--------------------------------------------------------------------------*/
static char *cvtToBin(char *buff,   /* Buffer for result */
                      int   val,    /* Value to convert */
                      int   nBits)  /* Number of bits to convert */
{  
  int     i, nxtBit, nxtChar;
  
  nxtChar = 0;
  for (i = 0; i < nBits; i++) {
    nxtBit = 1 << (nBits - i - 1);
    if ((i != 0) && ((i & 0x0003) == 0)) buff[nxtChar++] = '.';

    if (val & nxtBit) {
      buff[nxtChar++] = '1';
      val &= ~nxtBit;
    }else {
      buff[nxtChar++] = '0';
    }
  }
  buff[nxtChar] = '\0';
  if (val != 0) {
    for (i = 0; i < nxtChar; i++) buff[i] = '*';
  }

  return buff;
}

/*--------------------------------------------------------------------------*/
static double calcTrans(double keV,
                        double thickness,
                        char *species,
                        int debug)
{
  int i, j;
  double mu, frac, absLen, transm;

  for(i=0; i<NUM_SPECIES; i++) {
    if (strcmp(filtermat[i].name, species) == 0) break; 
  }
  if(i >= NUM_SPECIES) {
    if(debug) printf("Filter material '%s' not found\n", species);
    return(0.);
  }
  if(debug & 4) printf("  species = '%s', index = %d\n", species, i);
  if(debug & 4) printf("  density = %.4e gm/cm3, thickness = %.4e um\n", matdensity[i], thickness);
  if(debug & 4) printf("  energy = %.4e\n", keV);

  for(j=0; j<filtermat[i].numEntries; j++) {
    if (keV < filtermat[i].keV[j]) break; 
  }
  if((j < 1) | (j >= filtermat[i].numEntries)) {
    if(debug) printf("Energy '%f' not found in filter data\n", keV);
    return(0.);
  }

  /* linear interpolation of mu */
  /* mu is in cm^2/g, density is g/cm^3, want absorption length in microns,
  ** then calculate transmission */
  frac = (keV - filtermat[i].keV[j-1]) / (filtermat[i].keV[j] - filtermat[i].keV[j-1]);
  mu = filtermat[i].mu[j-1] + frac * (filtermat[i].mu[j] - filtermat[i].mu[j-1]);
  absLen = 1.0/(matdensity[i]*mu);
  absLen *= 1.e4; /* cm to microns */
  transm = exp(-(thickness/absLen));

  if(debug & 8){
    printf("  E1 = %.4e keV, mu1 = %.4e\n", filtermat[i].keV[j-1], filtermat[i].mu[j-1]);
    printf("  E2 = %.4e keV, mu2 = %.4e\n", filtermat[i].keV[j], filtermat[i].mu[j]);
    printf("  frac = %.4f, mu = %.4e\n", frac, mu);
  }

  if(debug & 4){
    printf("  attenuation length ='%.4e' um, transmission=%.4e\n", absLen, transm);
  }

  return(transm);
}

}%


/*============================================================================
** The State Notation Language code
**==========================================================================*/

  ss filterDrive {
/*==============*/

/*-------------*/
    state start {
      when() {
        /* Show that we are starting up. */
        firstTime = 1;
        changeFlag = 1;
        
        /* Wait a bit to let things settle down */
        epicsThreadSleep(1.0);

        /* Assign the macro substitution values */
        name = macValueGet("NAME");
        prefix = macValueGet("P");
        record = macValueGet("R");
        sscanf(macValueGet("NUM_FILTERS"), "%d", &nFltrs);
        
        /* dynamically assign the PV channels to database variables */
        for(i = 0; i < nFltrs; i++) {
          sprintf(str, "%s%sFi%d:Thickness", prefix, record, i+1);
          pvAssign(THICK[i], str);
          sprintf(str, "%s%sFi%d:Material", prefix, record, i+1);
          pvAssign(MATER[i], str);
          sprintf(str, "%s%sFi%d:Transmission", prefix, record, i+1);
          pvAssign(TRANSM[i], str);
          sprintf(str, "%s%sFi%d:Lock", prefix, record, i+1);
          pvAssign(LOCK[i], str);
          sprintf(str, "%s%sFi%d:Set", prefix, record, i+1);
          pvAssign(SET[i], str);
          sprintf(str, "%s%sFi%d:Enable", prefix, record, i+1);
          pvAssign(ENBL[i], str);
          sprintf(str, "%s%sFi%d:Set.OUT", prefix, record, i+1);
          pvAssign(OUTLINK[i], str);
        }

        epicsThreadSleep(1.0); /* wait for OUTLINK[i] to connect */
        /* get the OUT PV names, and dynamically assign the OUT PVs */
        for(i = 0; i < nFltrs; i++) {
          pvGet(OUTLINK[i]);
          strcpy(str, OUTLINK[i]);
           /* strip trailing' NPP NMS' from link string */
          for (j=0; j<39; j++) {
            if (str[j]==' ') {
              str[j] = '\0';
              break;
            }
          }
          pvAssign(OUT[i], str);
        }

        printf("%s: SNL program started for %s%s\n", name, prefix, record);
        printf("%s:   # of filters = %d\n", name, nFltrs);

        /* Wait a bit again to let things settle down */
        epicsThreadSleep(1.0);

      } state init
    }


/*------------*/
    state init {
      /* Ensure everything is connected */
      when(pvConnectCount() == pvAssignCount()) {

        /* If not first time through, there must have been a channel
        ** disconnection. So wait a bit to (hopefully) let things settle
        ** down.
        */
        if(!firstTime){
          epicsThreadSleep(2.0);
        }

        sprintf(MSGE, "Initialising ..."); pvPut(MSGE); strcpy(MSGE, "");
        efClear(EvFlgTRANSM_SETPT);
        TRANSM_UP = 0; pvPut(TRANSM_UP);
        TRANSM_DN = 0; pvPut(TRANSM_DN);
        efSet(needRecalc);
      } state waiting
    }


/*----------------------*/
    state update_filters {
      entry {
        if (DEBUG & 0x1) printf("state: update_filters\n");
      }

      when(){
        /* Make sure the physical binary PVs of the actuators
        ** are in sync with the SET bo PVs */
        for(i = 0; i < nFltrs; i++) {
          pvGet(OUT[i]);
          pvGet(SET[i]);
          if (SET[i] != OUT[i]) {
            /* We mustn't write to SET[i] unless OUT[i] is different, because writing processes, which
             * sets STATUS_UPDATE, which brings us back here, causing an infinite loop.
             */
            SET[i] = OUT[i];
            pvPut(SET[i]);
            sprintf(MSGE, "Filter state set by external agent.");
            pvPut(MSGE); strcpy(MSGE, "");
          }
        }

        /* Update the readback values */
        transNow = 1.0;
        fltrsInNow = 0;
        nEnabled = 0;
        for(i = 0; i < nFltrs; i++) {
          /* calculate the individual filter blade transmissions */
          if(DEBUG & 0x4) printf("%s: Calculating transmission for blade %d.\n", name, i);
          TRANSM[i] = calcTrans(ENERGY, THICK[i], MATER[i], DEBUG);
          pvPut(TRANSM[i]);

          /* update combined transmission, enable count, ... */
          if(SET[i] && ENBL[i]){            
            fltrsInNow |= (1 << i);
            transNow *= TRANSM[i];
          }
          if((LOCK[i] == 0) && ENBL[i]) {
            nEnabled += 1;
          }
        }

        TRANSMISSION = transNow; pvPut(TRANSMISSION);
        FILTER_MASK = fltrsInNow; pvPut(FILTER_MASK);

        /* Clear the busy record */
        if(changeFlag){
          if(DEBUG & 0x1) printf("%s: clearing busy record.\n", name);
          changeFlag = 0;

          STATUS_BUSY = 0;
          pvPut(STATUS_BUSY);
        }

        /* Clear the update flag */
        if(updateFlag){
          if(DEBUG & 0x1) printf("%s: clearing update flag.\n", name);
          updateFlag = 0;

          STATUS_UPDATE = 0;
          pvPut(STATUS_UPDATE);
        }

      } state waiting
    }


/*---------------*/
    state waiting {

      /* Connection was lost */
      when(pvConnectCount() != pvAssignCount()) {
        printf ("%s: channel connection lost.\n", name);
      } state init
      
      /* First run after startup */
      when(firstTime){
        firstTime = 0;
      } state update_filters

      when(efTestAndClear(newEnergy)) {
        TRANSMISSION = 1.0;
        for(i = 0; i < nFltrs; i++) {
          /* calculate the individual filter blade transmissions */
          TRANSM[i] = calcTrans(ENERGY, THICK[i], MATER[i], DEBUG);
          pvPut(TRANSM[i]);

          /* update combined transmission, enable count, ... */
          if(SET[i] && ENBL[i]){            
            TRANSMISSION *= TRANSM[i];
          }
        }
        pvPut(TRANSMISSION);
      } state waiting

      /* Setpoint changed */
      when(efTestAndClear(EvFlgTRANSM_SETPT)) {
        if(DEBUG & 0x1) printf("%s: setpoint changed.\n", name);
        myAction = 0;
      } state action

      /* Transmission step up */
      when(TRANSM_UP) {
        TRANSM_UP = 0;
        pvPut(TRANSM_UP);
        if(DEBUG & 0x1) printf("%s: step up.\n", name);
        myAction = 1;
      } state action

      /* Transmission step down */
      when(TRANSM_DN) {
        TRANSM_DN = 0;
        pvPut(TRANSM_DN);
        if(DEBUG & 0x1) printf("%s: step down.\n", name);
        myAction = 2;
      } state action

      when(STATUS_UPDATE){
        if(DEBUG & 0x1){
          printf("%s: Configuration change detected: Updating values.\n", name);
        }
        updateFlag = 1;
      } state update_filters

      when(STATUS_BUSY){
        changeFlag = 1;
      } state update_filters
    }


/*--------------*/
    state action {

      /* Can only deal with up to MAX_ENABLED unlocked filters */
      when(nEnabled > MAX_ENABLED){
        if(DEBUG & 0x1){
          printf("%s: ERROR: Too many filters unlocked (%d/%d).\n", name, nEnabled, MAX_ENABLED);
        }
        sprintf(MSGE, "ERROR: Too many unlocked (%d/%d)", nEnabled, MAX_ENABLED);
        pvPut(MSGE); strcpy(MSGE, "");
      } state update_filters

      when() {

        /* signal that we are changing something */
        changeFlag = 1;

        if(DEBUG & 0x1){
          sprintf(MSGE, "Action = %d", myAction); pvPut(MSGE);
          printf("Action = %d\n", myAction);
          epicsThreadSleep(1.0);
        }
        strcpy(MSGE, "");      

        /* Calculate array of all possible transmissions
        ** and the corresponding pattern of filters.
        */
        nPerms = 1 << nEnabled;
        for(i = 0; i < nPerms; i++){
          transMis[i] = 1.0;
          fltrsIn[i]  = 0;
          k           = 0;
          for(j = 0; j < nFltrs; j++){
            if(ENBL[j]){
              if(LOCK[j] == 1){
                if(SET[j]){
                  /* take transmission into account for Locked and inserted filters */
                  transMis[i] *= TRANSM[j];
                  fltrsIn[i] |= (1 << j);
                }
              } else {
                if(i & (1 << k)){
                  transMis[i] *= TRANSM[j];
                  fltrsIn[i] |= (1 << j);
                }
                k++;
              }
            }
          }
        }
        if(DEBUG & 0x2){
          printf("%s: <#-enabled> = %d, <#-permutations> = %d, transmission = %e\n", 
              name, nEnabled, nPerms, transNow);
          for(i = 0; ((i < nPerms) && (i < 100)); i++){
            printf("  %s: %s    %e\n",
                cvtToBin(buff0, i, nEnabled),
                cvtToBin(buff1, fltrsIn[i], nFltrs),
                transMis[i]);
          }
        }
        
        /* Sort the permutations into ascending order */
        if(nPerms > 0) {
          if(DEBUG & 0x1) {
            strcpy(MSGE, "Starting sort ..."); pvPut(MSGE); strcpy(MSGE, "");
            printf("Starting sort ...\n");
            epicsThreadSleep(1.0);
          }
          Sort(transMis, fltrsIn, 0, nPerms);
          if(DEBUG & 0x1) {
            sprintf(MSGE, "Finished sort"); pvPut(MSGE); strcpy(MSGE, "");
            printf("Finished sort ...\n");
            epicsThreadSleep(1.0);
          }
        }
        if(DEBUG & 0x2) {
          printf("%s: Sorted transmissions:\n", name);
          for(i = 0; ((i < nPerms) && (i < 100)); i++) {
            printf("      %s    %e\n",
                cvtToBin(buff1, fltrsIn[i], nFltrs), transMis[i]);
          }
        }

        /* Now we are ready to do the work! */
        if(myAction == 0) {

          /* find the current filter combination index */
          indNow = -1;
          if(transNow >= 0.99999) {
            indNow = nPerms - 1;
          } else {
            indNow = 0;                             
            for(k = 1; k < nPerms; k++) {
              if(transMis[k] <= transNow) indNow = k;
            }
          }
          
          /* Set the transmission to the next lower or equal transmission as
          ** requested in the setpoint
          */
          ind = -1;
          if(DEBUG & 0x1){
            printf("%s: Required transmission = %e\n", name, TRANSM_SETPT);
          }
          if(TRANSM_SETPT >= 0.99999) {
            ind = nPerms - 1;
          } else {
            ind = 0;                             
            for(k = 1; k < nPerms; k++) {
              if(transMis[k] <= TRANSM_SETPT) ind = k;
            }
          }
          if(DEBUG & 0x1) {
            printf("%s: Selected filters are: %s   Transmission = %e\n",
              name, cvtToBin(buff1, fltrsIn[ind], nFltrs), transMis[ind]);
          }
          if(ind == indNow){
            if(DEBUG & 0x1) printf("NO CHANGE! Current settings are best.\n");
            strcpy(MSGE, "NO CHANGE! Transm. unavailable.");
            pvPut(MSGE); strcpy(MSGE, "");
          } else {
            strcpy(MSGE, ""); pvPut(MSGE);
          }
		  
        } else if(myAction == 1){
          /* Set the transmission to the next available step up */
          k = -1;
          ind = -1;
          for(i = 0; i < nPerms; i++) {
            if(fltrsIn[i] == fltrsInNow) k = i;
          }
          if(k < 0) {
            printf("%s: Cannot find current filter pattern!\n", name);
          } else {
            if(transMis[k] >= transMis[nPerms-1]) {
              strcpy(MSGE, "NO CHANGE! Step unavailable.");
              pvPut(MSGE); strcpy(MSGE, "");
              if(DEBUG & 0x1) printf("%s: No more steps up available!\n", name);
            } else {
              strcpy(MSGE, ""); pvPut(MSGE);
              for(ind = k; ind < (nPerms - 1); ind++) {
                if(transMis[ind] > transNow) break;
              }
              if(DEBUG & 0x1){
                printf("%s: Next filter pattern is %s,  Transmission = %e\n",
                name, cvtToBin(buff1, fltrsIn[ind], nFltrs), transMis[ind]);
              }
            }
          }
        } else if(myAction == 2) {
          /* Set the transmission to the next available step up */
          k = -1;
          ind = -1;
          for(i = 0; i < nPerms; i++) {
            if(fltrsIn[i] == fltrsInNow) k = i;
          }
          if(k < 0) {
            printf("%s: Cannot find current filter pattern!\n", name);
          } else {
            if(transMis[k] <= transMis[0]) {
              strcpy(MSGE, "NO CHANGE! Step unavailable.");
              pvPut(MSGE); strcpy(MSGE, "");
              if(DEBUG & 0x1) printf("%s: No more steps down available!\n", name);
            } else {
              pvPut(MSGE);
              for(ind = k; ind >= 0; ind--) {
                if(transMis[ind] < transNow) break;
              }
              if(DEBUG & 0x1){
                printf("%s: Next filter pattern is %s,  Transmission = %e\n",
                name, cvtToBin (buff1, fltrsIn[ind], nFltrs), transMis[ind]);
              }
            }
          }
        }
        TRANSM_UP = 0; pvPut(TRANSM_UP);
        TRANSM_DN = 0; pvPut(TRANSM_DN);
      } state change_filters
    }

/*----------------------*/
    state change_filters {
      when() {
        if(ind >=0){

          /* Signal that filters need updating */
          updateFlag = 1;

          /* Start by putting in filters */
          for(j = 0; j < nFltrs; j++) {        
            if(fltrsIn[ind] & (1 << j)) {
              SET[j] = 1; pvPut(SET[j]);
            }
          }

          /* Give them time to get in */
          pvGet(FILTER_WAIT_TIME);
          epicsThreadSleep(FILTER_WAIT_TIME);
        
          /* Then take out the others */
          for(j = 0; j < nFltrs; j++) {           
            if((fltrsIn[ind] & (1 << j)) == 0) {
              SET[j] = 0; pvPut(SET[j]);
            }
          }

          /* Give them time to get out */
          pvGet(FILTER_WAIT_TIME);
          epicsThreadSleep(FILTER_WAIT_TIME);

        }
      } state waiting
    }
  }


/*============================================= End of filterDrive.st ====*/
