program orient  ("P=xxx:orient1,PM=xxx:,mTTH=m9,mTH=m10,mCHI=m11,mPHI=m12")

/* arguments on the command line  :
 * 
 * ex.  seq &orient, "P=xxx:orient1:,PM=xxx:,mTTH=xxx:m9,mTH=m10,mCHI=m11,mPHI=m12"
 *
 *     P    - non-motor PV names start with this string
 *     PM   - motor PV names start with this string
 *     mTTH - name of PV to which TTH is written
 *     mTH  - name of PV to which TH is written
 *     mCHI - name of PV to which CHI is written
 *     mPHI - name of PV to which PHI is written
 */

/* General Purpose PV's used by sequence */


#define ASSIGN(TYPE, LOCAL_VAR, PV) \
        TYPE LOCAL_VAR;             \
        assign LOCAL_VAR to PV;

#define ASSIGN_MONITOR(TYPE, LOCAL_VAR, PV) \
        ASSIGN(TYPE, LOCAL_VAR, PV)         \
        monitor LOCAL_VAR;

#define ASSIGN_MONITOR_FLAG(TYPE, LOCAL_VAR, PV, LOCAL_FLAG) \
        ASSIGN_MONITOR(TYPE, LOCAL_VAR, PV)              \
        evflag LOCAL_FLAG;                               \
        sync   LOCAL_VAR LOCAL_FLAG;

#define PVPUT(PV,VAL)  {(PV) = (VAL);  pvPut(PV);}

#define PVPUTSTR(MSG,TEXT)  {strcpy((MSG), (TEXT)); pvPut(MSG);}
#define PUTMSG(LINE1)  {strcpy(Msg, (LINE1)); pvPut(Msg); if (orientDebug) printf("orient: %s\n", Msg);}
#define PUTALERT(LINE1)  {strcpy(Msg, (LINE1)); pvPut(Msg); PVPUT(Alert, 1); printf("orient: %s\n", Msg);}

char tmpstr[100];
char *cp;

#define CHECK_MOT_NAME(name) \
		if ((cp = strstr(name, ".DESC"))) { \
			strcpy(cp, ".VAL"); \
			pvPut(name); \
		}

ASSIGN_MONITOR(short, orientDebug, "{P}Debug")

ASSIGN(string, Msg, "{P}Msg")
ASSIGN(short, Alert, "{P}Alert")
ASSIGN_MONITOR(short, opAck, "{P}OperAck")

/* Mode is the constraint according to which HKL gets transleted into TTH, TH, CHI, PHI. */
ASSIGN_MONITOR_FLAG(short, Mode, "{P}Mode", Mode_mon)

/* {P}motPut is the user's "Move" button.  If {P}motPut_Auto==0, user
 * can write whatever values he wants to whatever fields without anything
 * propagating to actual motors, and then set {P}motPut=1 to say "make it so".
 * If {P}motPut_Auto==1, this happens whenever local angle values change.
 */
ASSIGN_MONITOR_FLAG(short, motPut, "{P}motPut", motPut_mon)
ASSIGN_MONITOR(short, motPut_Auto, "{P}motPut_Auto")
ASSIGN(short, load_motPut, "{P}load_motPut")

/* {P}motGet causes motor positions to be read from actual motors to local
 * copies [TTH, TH, CHI, PHI].  If {P}motGet_Auto==1, this will happen whenever
 * the actual motor values change.
 */
ASSIGN_MONITOR_FLAG(short, motGet, "{P}motGet", motGet_mon)
ASSIGN_MONITOR(short, motGet_Auto, "{P}motGet_Auto")

ASSIGN_MONITOR_FLAG(string, motTTH_name, "{P}motTTH_name", motTTH_name_mon)
ASSIGN_MONITOR_FLAG(string, motTH_name, "{P}motTH_name", motTH_name_mon)
ASSIGN_MONITOR_FLAG(string, motCHI_name, "{P}motCHI_name", motCHI_name_mon)
ASSIGN_MONITOR_FLAG(string, motPHI_name, "{P}motPHI_name", motPHI_name_mon)
ASSIGN_MONITOR_FLAG(double, motTTH, "{PM}{mTTH}", motTTH_mon)
ASSIGN_MONITOR_FLAG(double, motTH, "{PM}{mTH}", motTH_mon)
ASSIGN_MONITOR_FLAG(double, motCHI, "{PM}{mCHI}", motCHI_mon)
ASSIGN_MONITOR_FLAG(double, motPHI, "{PM}{mPHI}", motPHI_mon)
ASSIGN_MONITOR_FLAG(double, motTTH_RBV, "", motTTH_RBV_mon)
ASSIGN_MONITOR_FLAG(double, motTH_RBV, "", motTH_RBV_mon)
ASSIGN_MONITOR_FLAG(double, motCHI_RBV, "", motCHI_RBV_mon)
ASSIGN_MONITOR_FLAG(double, motPHI_RBV, "", motPHI_RBV_mon)
double rbv_angles[4];

ASSIGN(int, motTTH_stop, "")
ASSIGN(int, motTH_stop, "")
ASSIGN(int, motCHI_stop, "")
ASSIGN(int, motPHI_stop, "")
ASSIGN_MONITOR(int, stopMotors, "{P}stopMotors")
ASSIGN(int, motTTH_Connected, "{P}motTTH_Connected")
ASSIGN(int, motTH_Connected, "{P}motTH_Connected")
ASSIGN(int, motCHI_Connected, "{P}motCHI_Connected")
ASSIGN(int, motPHI_Connected, "{P}motPHI_Connected")

ASSIGN_MONITOR(short, OMTX_Calc, "{P}OMTX_Calc")

ASSIGN_MONITOR(short, Busy, "{P}Busy")

/* HKL */
ASSIGN_MONITOR(double, H, "{P}H")
ASSIGN_MONITOR_FLAG(double, H_event, "{P}H_event", H_mon)
ASSIGN_MONITOR(short, H_busy, "{P}H_busy")
ASSIGN(double, loadH, "{P}loadH")
ASSIGN(double, H_RBV, "{P}H_RBV")

ASSIGN_MONITOR(double, K, "{P}K")
ASSIGN_MONITOR_FLAG(double, K_event, "{P}K_event", K_mon)
ASSIGN_MONITOR(short, K_busy, "{P}K_busy")
ASSIGN(double, loadK, "{P}loadK")
ASSIGN(double, K_RBV, "{P}K_RBV")

ASSIGN_MONITOR(double, L, "{P}L")
ASSIGN_MONITOR_FLAG(double, L_event, "{P}L_event", L_mon)
ASSIGN_MONITOR(short, L_busy, "{P}L_busy")
ASSIGN(double, loadL, "{P}loadL")
ASSIGN(double, L_RBV, "{P}L_RBV")

double hkl[3];
double rbv_hkl[3];

/* angles */
ASSIGN_MONITOR(double, TTH, "{P}TTH")
ASSIGN_MONITOR_FLAG(double, TTH_event, "{P}TTH_event", TTH_mon)
ASSIGN_MONITOR(short, TTH_busy, "{P}TTH_busy")
ASSIGN(double, loadTTH, "{P}loadTTH")

ASSIGN_MONITOR(double, TH, "{P}TH")
ASSIGN_MONITOR_FLAG(double, TH_event, "{P}TH_event", TH_mon)
ASSIGN_MONITOR(short, TH_busy, "{P}TH_busy")
ASSIGN(double, loadTH, "{P}loadTH")

ASSIGN_MONITOR(double, CHI, "{P}CHI")
ASSIGN_MONITOR_FLAG(double, CHI_event, "{P}CHI_event", CHI_mon)
ASSIGN_MONITOR(short, CHI_busy, "{P}CHI_busy")
ASSIGN(double, loadCHI, "{P}loadCHI")

ASSIGN_MONITOR(double, PHI, "{P}PHI")
ASSIGN_MONITOR_FLAG(double, PHI_event, "{P}PHI_event", PHI_mon)
ASSIGN_MONITOR(short, PHI_busy, "{P}PHI_busy")
ASSIGN(double, loadPHI, "{P}loadPHI")

double angles[4];

/* primary and secondary reflections */
/* HKL */
ASSIGN_MONITOR_FLAG(double, H1, "{P}H1", H1_mon)
ASSIGN_MONITOR_FLAG(double, K1, "{P}K1", K1_mon)
ASSIGN_MONITOR_FLAG(double, L1, "{P}L1", L1_mon)
ASSIGN_MONITOR_FLAG(double, TTH1, "{P}TTH1", TTH1_mon)
ASSIGN_MONITOR_FLAG(double, TH1, "{P}TH1", TH1_mon)
ASSIGN_MONITOR_FLAG(double, CHI1, "{P}CHI1", CHI1_mon)
ASSIGN_MONITOR_FLAG(double, PHI1, "{P}PHI1", PHI1_mon)
ASSIGN_MONITOR(short, refGet1, "{P}refGet1")
ASSIGN_MONITOR(short, refPut1, "{P}refPut1")

ASSIGN_MONITOR_FLAG(double, H2, "{P}H2", H2_mon)
ASSIGN_MONITOR_FLAG(double, K2, "{P}K2", K2_mon)
ASSIGN_MONITOR_FLAG(double, L2, "{P}L2", L2_mon)
ASSIGN_MONITOR_FLAG(double, TTH2, "{P}TTH2", TTH2_mon)
ASSIGN_MONITOR_FLAG(double, TH2, "{P}TH2", TH2_mon)
ASSIGN_MONITOR_FLAG(double, CHI2, "{P}CHI2", CHI2_mon)
ASSIGN_MONITOR_FLAG(double, PHI2, "{P}PHI2", PHI2_mon)
ASSIGN_MONITOR(short, refGet2, "{P}refGet2")
ASSIGN_MONITOR(short, refPut2, "{P}refPut2")

/* crystal parameters */
ASSIGN_MONITOR_FLAG(double, a, "{P}a", a_mon)
ASSIGN_MONITOR_FLAG(double, b, "{P}b", b_mon)
ASSIGN_MONITOR_FLAG(double, c, "{P}c", c_mon)
ASSIGN_MONITOR_FLAG(double, alpha, "{P}alpha", alpha_mon)
ASSIGN_MONITOR_FLAG(double, beta, "{P}beta", beta_mon)
ASSIGN_MONITOR_FLAG(double, Gamma, "{P}gamma", Gamma_mon)
ASSIGN_MONITOR_FLAG(double, lambda, "{P}lambda", lambda_mon)

/* A0 matrix elements */
double A0[3][3];
double A0_i[3][3];

ASSIGN_MONITOR_FLAG(double, A0_11, "{P}A0_11", A0_11_mon)
ASSIGN_MONITOR_FLAG(double, A0_12, "{P}A0_12", A0_12_mon)
ASSIGN_MONITOR_FLAG(double, A0_13, "{P}A0_13", A0_13_mon)

ASSIGN_MONITOR_FLAG(double, A0_21, "{P}A0_21", A0_21_mon)
ASSIGN_MONITOR_FLAG(double, A0_22, "{P}A0_22", A0_22_mon)
ASSIGN_MONITOR_FLAG(double, A0_23, "{P}A0_23", A0_23_mon)

ASSIGN_MONITOR_FLAG(double, A0_31, "{P}A0_31", A0_31_mon)
ASSIGN_MONITOR_FLAG(double, A0_32, "{P}A0_32", A0_32_mon)
ASSIGN_MONITOR_FLAG(double, A0_33, "{P}A0_33", A0_33_mon)

/* OMTX matrix elements */
ASSIGN_MONITOR_FLAG(double, OMTX_11, "{P}OMTX_11", OMTX_11_mon)
ASSIGN_MONITOR_FLAG(double, OMTX_12, "{P}OMTX_12", OMTX_12_mon)
ASSIGN_MONITOR_FLAG(double, OMTX_13, "{P}OMTX_13", OMTX_13_mon)

ASSIGN_MONITOR_FLAG(double, OMTX_21, "{P}OMTX_21", OMTX_21_mon)
ASSIGN_MONITOR_FLAG(double, OMTX_22, "{P}OMTX_22", OMTX_22_mon)
ASSIGN_MONITOR_FLAG(double, OMTX_23, "{P}OMTX_23", OMTX_23_mon)

ASSIGN_MONITOR_FLAG(double, OMTX_31, "{P}OMTX_31", OMTX_31_mon)
ASSIGN_MONITOR_FLAG(double, OMTX_32, "{P}OMTX_32", OMTX_32_mon)
ASSIGN_MONITOR_FLAG(double, OMTX_33, "{P}OMTX_33", OMTX_33_mon)

ASSIGN(double, errAngle, "{P}errAngle")
ASSIGN_MONITOR(double, errAngleThresh, "{P}errAngleThresh")

double OMTX[3][3];
double OMTX_i[3][3];

%%#include <string.h>
%%#include <math.h>
%%#include "matrix3.h"
%%#include "orient.h"

double v1_hkl[3];
double v1_angles[4];
double v2_hkl[3];
double v2_angles[4];
int i;

ASSIGN(short, newHKL, "{P}newHKL")
ASSIGN(short, newAngles, "{P}newAngles")
ASSIGN(short, newMotors, "{P}newMotors")
ASSIGN(short, waiting4Mot, "{P}waiting4Mot")
ASSIGN_MONITOR(short, waiting4motTTH, "{P}waiting4motTTH")
ASSIGN_MONITOR(short, waiting4motTH, "{P}waiting4motTH")
ASSIGN_MONITOR(short, waiting4motCHI, "{P}waiting4motCHI")
ASSIGN_MONITOR(short, waiting4motPHI, "{P}waiting4motPHI")
int old_connect_state;

ASSIGN_MONITOR(long, A0_exists, "{P}A0_exists")
ASSIGN_MONITOR(long, OMTX_exists, "{P}OMTX_exists")

ASSIGN_MONITOR(int, weWrote_motTTH, "{P}weWrote_motTTH")
ASSIGN_MONITOR(int, weWrote_motTH , "{P}weWrote_motTH")
ASSIGN_MONITOR(int, weWrote_motCHI, "{P}weWrote_motCHI")
ASSIGN_MONITOR(int, weWrote_motPHI, "{P}weWrote_motPHI")

int startup = 1;
%%char *orient_pmac_PM;
%%char *orient_pmac_mTTH;
%%char *orient_pmac_mTH;
%%char *orient_pmac_mCHI;
%%char *orient_pmac_mPHI;



ss orient {

	state init_wait {
		when (delay(1)) {
			if (A0_exists == 2) PVPUT(A0_exists, 0);
			if (OMTX_exists == 2) PVPUT(OMTX_exists, 0);
		} state init
	}

	state init {
		when (startup) {
			/* Construct motor PV names from macro arguments */
			%%orient_pmac_PM = seq_macValueGet(ssId, "PM");
			%%orient_pmac_mTTH = seq_macValueGet(ssId, "mTTH");
			%%orient_pmac_mTH = seq_macValueGet(ssId, "mTH");
			%%orient_pmac_mCHI = seq_macValueGet(ssId, "mCHI");
			%%orient_pmac_mPHI = seq_macValueGet(ssId, "mPHI");
			if (orient_pmac_PM == 0) {
				PUTALERT("motor prefix (PM) not specified");
			} else {
				%%strcpy(motTTH_name, orient_pmac_PM);
				%%strcpy(motTH_name, orient_pmac_PM);
				%%strcpy(motCHI_name, orient_pmac_PM);
				%%strcpy(motPHI_name, orient_pmac_PM);
				if (orient_pmac_mTTH == 0) {
					PUTALERT("orient: TTH motor name (mTTH) not specified");
				} else {
					%%strcat(motTTH_name, orient_pmac_mTTH);
					pvPut(motTTH_name);
					/* Construct name of motor-stop PV and assign. */
					%%strcpy(tmpstr, motTTH_name);
					%%if ((cp = strrchr(tmpstr, (int)'.'))) *cp = '\0';
					%%strcat(tmpstr, ".STOP");
					pvAssign(motTTH_stop, tmpstr);
					/* Construct name of motor-rbv PV and assign. */
					%%strcpy(tmpstr, motTTH_name);
					%%if ((cp = strrchr(tmpstr, (int)'.'))) *cp = '\0';
					%%strcat(tmpstr, ".RBV");
					pvAssign(motTTH_RBV, tmpstr);
				}
				if (orient_pmac_mTH == 0) {
					PUTALERT("orient: TH motor name (mTH) not specified");
				} else {
					%%strcat(motTH_name, orient_pmac_mTH);
					pvPut(motTH_name);
					%%strcpy(tmpstr, motTH_name);
					%%if ((cp = strrchr(tmpstr, (int)'.'))) *cp = '\0';
					%%strcat(tmpstr, ".STOP");
					pvAssign(motTH_stop, tmpstr);
					/* Construct name of motor-rbv PV and assign. */
					%%strcpy(tmpstr, motTH_name);
					%%if ((cp = strrchr(tmpstr, (int)'.'))) *cp = '\0';
					%%strcat(tmpstr, ".RBV");
					pvAssign(motTH_RBV, tmpstr);
				}
				if (orient_pmac_mCHI == 0) {
					PUTALERT("orient: CHI motor name (mCHI) not specified");
				} else {
					%%strcat(motCHI_name, orient_pmac_mCHI);
					pvPut(motCHI_name);
					%%strcpy(tmpstr, motCHI_name);
					%%if ((cp = strrchr(tmpstr, (int)'.'))) *cp = '\0';
					%%strcat(tmpstr, ".STOP");
					pvAssign(motCHI_stop, tmpstr);
					/* Construct name of motor-rbv PV and assign. */
					%%strcpy(tmpstr, motCHI_name);
					%%if ((cp = strrchr(tmpstr, (int)'.'))) *cp = '\0';
					%%strcat(tmpstr, ".RBV");
					pvAssign(motCHI_RBV, tmpstr);
				}
				if (orient_pmac_mPHI == 0) {
					PUTALERT("orient: PHI motor name (mPHI) not specified");
				} else {
					%%strcat(motPHI_name, orient_pmac_mPHI);
					pvPut(motPHI_name);
					%%strcpy(tmpstr, motPHI_name);
					%%if ((cp = strrchr(tmpstr, (int)'.'))) *cp = '\0';
					%%strcat(tmpstr, ".STOP");
					pvAssign(motPHI_stop, tmpstr);
					/* Construct name of motor-rbv PV and assign. */
					%%strcpy(tmpstr, motPHI_name);
					%%if ((cp = strrchr(tmpstr, (int)'.'))) *cp = '\0';
					%%strcat(tmpstr, ".RBV");
					pvAssign(motPHI_RBV, tmpstr);
				}
			}
			startup = 0;
		} state init

		when (A0_exists == 0) {
			/*
			 * Attempt to calculate A0 matrix (depends on crystal structure and x-ray wavelength).
			 * If successful, A0_exists -> 1; else A0_exists -> 2, which should result in a retry.
			 */
			if ((a!=0) && (b!=0) && (c!=0) && (alpha!=0) && (beta!=0) && (Gamma!=0) && (lambda!=0)) {
				if (orientDebug) PUTMSG("calling calc_A0");
				%%i = calc_A0(a, b, c, alpha, beta, Gamma, lambda, A0, A0_i);
				/* Copy from array to individual matrix-element PV's, and show them to user */
				%%A0_11 = A0[0][0]; A0_12 = A0[0][1]; A0_13 = A0[0][2];
				%%A0_21 = A0[1][0]; A0_22 = A0[1][1]; A0_23 = A0[1][2];
				%%A0_31 = A0[2][0]; A0_32 = A0[2][1]; A0_33 = A0[2][2];
				pvPut(A0_11); pvPut(A0_12); pvPut(A0_13);
				pvPut(A0_21); pvPut(A0_22); pvPut(A0_23);
				pvPut(A0_31); pvPut(A0_32); pvPut(A0_33);
				PVPUT(A0_exists, (i==0 ? 1 : 2));
				if (A0_exists == 1) PUTMSG("Successful A0 calc");
			} else {
				PVPUT(A0_exists, 2);
			}
		} state init

		when (A0_exists == 2) {
			/* A0 calculation failed.  Wait and retry. */
		} state init_wait

		when (A0_exists == 1 && (OMTX_exists == 0)) {
			/*
			 * Attempt to calculate orientation matrix OMTX -- this defines the orientation of the crystal,
			 * which is determined by user-entered locations (TTH, TH, CHI, PHI) of primary and secondary
			 * diffraction spots, and user-entered identification of the reciprocal-lattice vectors (HKL's)
			 * that correspond with those spots.  Check that calculations of A0 and OMTX actually do
			 * reproduce secondary reflection at its user-entered location.
			 * Don't bother to attempt calculation if primary- or secondary-reflection vectors are zero,
			 * because this cannot possibly work. 
			 */
			if ((H1!=0 || K1!=0 || L1!=0) && (H2!=0 || K2!=0 || L2!=0)) {
				if (orientDebug) PUTMSG("calling calc_OMTX");
				%%v1_hkl[_H_] = H1; v1_hkl[_K_] = K1; v1_hkl[_L_] = L1;
				%%v1_angles[_TTH_] = TTH1; v1_angles[_TH_] = TH1;
				%%v1_angles[_CHI_] = CHI1; v1_angles[_PHI_] = PHI1;
				%%v2_hkl[_H_] = H2; v2_hkl[_K_] = K2; v2_hkl[_L_] = L2;
				%%v2_angles[_TTH_] = TTH2; v2_angles[_TH_] = TH2;
				%%v2_angles[_CHI_] = CHI2; v2_angles[_PHI_] = PHI2;
				%%i = calc_OMTX(v1_hkl, v1_angles, v2_hkl, v2_angles, A0, A0_i, OMTX, OMTX_i);
				%%OMTX_11 = OMTX[0][0]; OMTX_12 = OMTX[0][1]; OMTX_13 = OMTX[0][2];
				%%OMTX_21 = OMTX[1][0]; OMTX_22 = OMTX[1][1]; OMTX_23 = OMTX[1][2];
				%%OMTX_31 = OMTX[2][0]; OMTX_32 = OMTX[2][1]; OMTX_33 = OMTX[2][2];
				pvPut(OMTX_11); pvPut(OMTX_12); pvPut(OMTX_13);
				pvPut(OMTX_21); pvPut(OMTX_22); pvPut(OMTX_23);
				pvPut(OMTX_31); pvPut(OMTX_32); pvPut(OMTX_33);
				if (OMTX_Calc)  PVPUT(OMTX_Calc, 0);
				PVPUT(errAngle, checkOMTX(v2_hkl, v2_angles, A0, A0_i, OMTX, OMTX_i));
			} else {
				i = -1;
			}
			/*
			 * If calculation returned an error, or secondary reflection was not accurately reproduced, 
			 * declare failure (OMTX_Exists -> 2), which should result in a retry, and set motor-drive
			 * switch to manual, so we don't automatically drive into a ditch.
			 */ 
			if ((i==0) && (fabs(errAngle) < errAngleThresh)) {
				/* good calculation */
				PVPUT(OMTX_exists, 1);
				if (OMTX_exists == 1) PUTMSG("Successful OMTX calc");
			} else {
				PVPUT(OMTX_exists, 2);
				PVPUT(motPut_Auto, 0);
				PUTALERT("Bad OMTX calc; motPut_Auto set to Manual");
			}
		} state init

		when (OMTX_exists == 2) {
			/* OMTX calculation failed.  Wait and retry. */
		} state init_wait

		when (A0_exists == 1 && (OMTX_exists == 1)) {
			/* Success.  We graduate from the sandbox to the real world. */
		} state enter_monitor_all

	}

	state ref_show {
		/*
		 * Implement part of the user interface: user pushed a button to get or put a
		 * primary or secondary reflection from or to active HKL/Angle PV's.  Hold the
		 * value for a little while so MEDM display can show user what the button did.
		 * (It would be nicer if we could show user what the button is going to do before
		 * s/he commits to doing it, but I can't figure out how to do this with MEDM.)
		 */
		when (delay(.5)) {
			PVPUT(refGet1, 0); PVPUT(refGet2, 0);
			PVPUT(refPut1, 0); PVPUT(refPut2, 0);
		} state monitor_all
	}

	state enter_monitor_all {
		when (delay(10)) {
			/* clear all event flags */
			efClear(a_mon); efClear(b_mon); efClear(c_mon); efClear(alpha_mon);
			efClear(beta_mon); efClear(Gamma_mon); efClear(lambda_mon);
			efClear(A0_11_mon); efClear(A0_12_mon); efClear(A0_13_mon);
			efClear(A0_21_mon); efClear(A0_22_mon); efClear(A0_23_mon);
			efClear(A0_31_mon); efClear(A0_32_mon); efClear(A0_33_mon);
			efClear(OMTX_11_mon); efClear(OMTX_12_mon); efClear(OMTX_13_mon);
			efClear(OMTX_21_mon); efClear(OMTX_22_mon); efClear(OMTX_23_mon);
			efClear(OMTX_31_mon); efClear(OMTX_32_mon); efClear(OMTX_33_mon);
			efClear(H_mon); efClear(K_mon); efClear(L_mon);
			efClear(TTH_mon); efClear(TH_mon); efClear(CHI_mon); efClear(PHI_mon);
			/* efClear(motTTH_mon); efClear(motTH_mon); efClear(motCHI_mon); efClear(motPHI_mon); */
			efClear(Mode_mon);
			PUTMSG("Initialization complete; going live");
		} state monitor_all
	}

	state monitor_all_delay {
		/* Wait a little bit before going (back?) to live action. */
		when (delay(1)) {
		} state monitor_all
	}

	state monitor_all { 

#if 0
		when(efTest(motTTH_name_mon)) {
			CHECK_MOT_NAME(motTTH_name)
			pvAssign(motTTH, "");
			pvAssign(motTTH, motTTH_name);
			efClear(motTTH_name_mon);
		} state monitor_all

		when(efTest(motTH_name_mon)) {
			CHECK_MOT_NAME(motTH_name)
			pvAssign(motTH, "");
			pvAssign(motTH, motTH_name);
			efClear(motTH_name_mon);
		} state monitor_all

		when(efTest(motCHI_name_mon)) {
			CHECK_MOT_NAME(motCHI_name)
			pvAssign(motCHI, "");
			pvAssign(motCHI, motCHI_name);
			efClear(motCHI_name_mon);
		} state monitor_all

		when(efTest(motPHI_name_mon)) {
			CHECK_MOT_NAME(motPHI_name)
			pvAssign(motPHI, "");
			pvAssign(motPHI, motPHI_name);
			efClear(motPHI_name_mon);
		} state monitor_all
#endif

		/*
		 * Check connections to motor PV's.  These are allowed to be in a different IOC from
		 * the rest of our stuff.
		 */
		when ((pvAssigned(motTTH) && !pvConnected(motTTH)) ||
				(pvAssigned(motTH) && !pvConnected(motTH)) ||
				(pvAssigned(motCHI) && !pvConnected(motCHI)) ||
				(pvAssigned(motPHI) && !pvConnected(motPHI))) {
			PUTMSG("Waiting for motor connection(s)");
		} state monitor_all_delay

		when ((pvAssigned(motTTH_stop) && !pvConnected(motTTH_stop)) ||
				(pvAssigned(motTH_stop) && !pvConnected(motTH_stop)) ||
				(pvAssigned(motCHI_stop) && !pvConnected(motCHI_stop)) ||
				(pvAssigned(motPHI_stop) && !pvConnected(motPHI_stop))) {
			PUTMSG("Waiting for motor-stop connection(s)");
		} state monitor_all_delay

		when (A0_exists == 0) {
			/* User must have caused a recalculation of A0, and the recalc failed.  Try again. */
			if (orientDebug) PUTMSG("Recalculating A0");
			%%i = calc_A0(a, b, c, alpha, beta, Gamma, lambda, A0, A0_i);
			%%A0_11 = A0[0][0]; A0_12 = A0[0][1]; A0_13 = A0[0][2];
			%%A0_21 = A0[1][0]; A0_22 = A0[1][1]; A0_23 = A0[1][2];
			%%A0_31 = A0[2][0]; A0_32 = A0[2][1]; A0_33 = A0[2][2];
			pvPut(A0_11); pvPut(A0_12); pvPut(A0_13);
			pvPut(A0_21); pvPut(A0_22); pvPut(A0_23);
			pvPut(A0_31); pvPut(A0_32); pvPut(A0_33);
			PVPUT(A0_exists, (i==0 ? 1 : 2));
		} state monitor_all

		when (A0_exists == 1 && (OMTX_exists == 0 || OMTX_Calc)) {
			/* A0 is ok, but either OMTX is broken or user wants it to be recalculated */
			if (orientDebug) PUTMSG("Recalculating OMTX");
			%%v1_hkl[_H_] = H1; v1_hkl[_K_] = K1; v1_hkl[_L_] = L1;
			%%v1_angles[_TTH_] = TTH1; v1_angles[_TH_] = TH1;
			%%v1_angles[_CHI_] = CHI1; v1_angles[_PHI_] = PHI1;
			%%v2_hkl[_H_] = H2; v2_hkl[_K_] = K2; v2_hkl[_L_] = L2;
			%%v2_angles[_TTH_] = TTH2; v2_angles[_TH_] = TH2;
			%%v2_angles[_CHI_] = CHI2; v2_angles[_PHI_] = PHI2;
			%%i = calc_OMTX(v1_hkl, v1_angles, v2_hkl, v2_angles, A0, A0_i, OMTX, OMTX_i);
			%%OMTX_11 = OMTX[0][0]; OMTX_12 = OMTX[0][1]; OMTX_13 = OMTX[0][2];
			%%OMTX_21 = OMTX[1][0]; OMTX_22 = OMTX[1][1]; OMTX_23 = OMTX[1][2];
			%%OMTX_31 = OMTX[2][0]; OMTX_32 = OMTX[2][1]; OMTX_33 = OMTX[2][2];
			pvPut(OMTX_11); pvPut(OMTX_12); pvPut(OMTX_13);
			pvPut(OMTX_21); pvPut(OMTX_22); pvPut(OMTX_23);
			pvPut(OMTX_31); pvPut(OMTX_32); pvPut(OMTX_33);
			if (OMTX_Calc)  {OMTX_Calc = 0; pvPut(OMTX_Calc);}
			errAngle = checkOMTX(v2_hkl, v2_angles, A0, A0_i, OMTX, OMTX_i);
			pvPut(errAngle);
			if ((i==0) && (fabs(errAngle) < errAngleThresh)) {
				/* good calculation */
				PVPUT(OMTX_exists, 1);
			} else {
				PVPUT(OMTX_exists, 2);
				PVPUT(motPut_Auto, 0);
				PUTALERT("Bad OMTX calc; motPut_Auto set to Manual");
			}
		} state newOMTX

		/* Detect any change that will require us to recalculate A0 */
		when (efTest(a_mon)||efTest(b_mon)||efTest(c_mon)||efTest(alpha_mon)||
				efTest(beta_mon)||efTest(Gamma_mon)||efTest(lambda_mon)) {
			efClear(a_mon); efClear(b_mon); efClear(c_mon); efClear(alpha_mon);
			efClear(beta_mon); efClear(Gamma_mon); efClear(lambda_mon);
			if (orientDebug) PUTMSG("new XTAL parameters");
			%%i = calc_A0(a, b, c, alpha, beta, Gamma, lambda, A0, A0_i);
			%%A0_11 = A0[0][0]; A0_12 = A0[0][1]; A0_13 = A0[0][2];
			%%A0_21 = A0[1][0]; A0_22 = A0[1][1]; A0_23 = A0[1][2];
			%%A0_31 = A0[2][0]; A0_32 = A0[2][1]; A0_33 = A0[2][2];
			pvPut(A0_11); pvPut(A0_12); pvPut(A0_13);
			pvPut(A0_21); pvPut(A0_22); pvPut(A0_23);
			pvPut(A0_31); pvPut(A0_32); pvPut(A0_33);
			PVPUT(A0_exists, (i==0 ? 1 : 2));
			if (A0_exists == 1) {
				PUTMSG("Successful A0 calc");
			} else {
				PUTALERT("A0 calc failed");
			}
		} state newHKL

		/* Detect and handle direct user input of A0 */
		when (efTest(A0_11_mon) || efTest(A0_12_mon) || efTest(A0_13_mon) ||
				efTest(A0_21_mon) || efTest(A0_22_mon) || efTest(A0_23_mon) ||
				efTest(A0_31_mon) || efTest(A0_32_mon) || efTest(A0_33_mon)) {
			efClear(A0_11_mon); efClear(A0_12_mon); efClear(A0_13_mon);
			efClear(A0_21_mon); efClear(A0_22_mon); efClear(A0_23_mon);
			efClear(A0_31_mon); efClear(A0_32_mon); efClear(A0_33_mon);
			if (orientDebug) PUTMSG("new A0 element(s)");
			/* Copy to internal array and calculate matrix inverse */
			%%A0[0][0] = A0_11; A0[0][1] = A0_12; A0[0][2] = A0_13;
			%%A0[1][0] = A0_21; A0[1][1] = A0_22; A0[1][2] = A0_23;
			%%A0[2][0] = A0_31; A0[2][1] = A0_32; A0[2][2] = A0_33;
			i = invertArray(A0, A0_i);
			if (i == -1) {
				PUTMSG("Could not invert A0 array");
				A0_exists = 2;
			}
		} state newA0

		/* Detect and handle direct user input of OMTX */
		when (efTest(OMTX_11_mon) || efTest(OMTX_12_mon) || efTest(OMTX_13_mon) ||
				efTest(OMTX_21_mon) || efTest(OMTX_22_mon) || efTest(OMTX_23_mon) ||
				efTest(OMTX_31_mon) || efTest(OMTX_32_mon) || efTest(OMTX_33_mon)) {
			efClear(OMTX_11_mon); efClear(OMTX_12_mon); efClear(OMTX_13_mon);
			efClear(OMTX_21_mon); efClear(OMTX_22_mon); efClear(OMTX_23_mon);
			efClear(OMTX_31_mon); efClear(OMTX_32_mon); efClear(OMTX_33_mon);
			if (orientDebug) PUTMSG("new OMTX element(s)");
			/* Copy to internal array; invert and check OMTX */
			%%OMTX[0][0] = OMTX_11; OMTX[0][1] = OMTX_12; OMTX[0][2] = OMTX_13;
			%%OMTX[1][0] = OMTX_21; OMTX[1][1] = OMTX_22; OMTX[1][2] = OMTX_23;
			%%OMTX[2][0] = OMTX_31; OMTX[2][1] = OMTX_32; OMTX[2][2] = OMTX_33;
			i = invertArray(OMTX, OMTX_i);
			if (i == -1) {
				PUTMSG("Could not invert OMTX array");
				OMTX_exists = 2;
			} else if (A0_exists != 1) {
				PUTMSG("Can't check or use OMTX array (No A0)");
				OMTX_exists = 2;
			} else {
				errAngle = checkOMTX(v2_hkl, v2_angles, A0, A0_i, OMTX, OMTX_i);
				pvPut(errAngle);
				if (fabs(errAngle) < errAngleThresh) {
					/* good calculation */
					PVPUT(OMTX_exists, 1);
					if (orientDebug) PUTMSG("User's OMTX passes test");
				} else {
					PVPUT(OMTX_exists, 2);
					if (orientDebug) PUTMSG("User's OMTX fails test");
				}
			}
		} state newOMTX

		/* Detect user entry of H, K, or L */
		when (efTest(H_mon)) {
			if (orientDebug) {printf("\norient: client wrote H\n");}
			if (!Busy) PVPUT(Busy, 1);
			efClear(H_mon);
		} state newHKL

		when (efTest(K_mon)) {
			if (orientDebug) {printf("\norient: client wrote K\n");}
			if (!Busy) PVPUT(Busy, 1);
			efClear(K_mon);
		} state newHKL

		when (efTest(L_mon)) {
			if (orientDebug) {printf("\norient: client wrote L\n");}
			if (!Busy) PVPUT(Busy, 1);
			efClear(L_mon);
		} state newHKL


		/* Detect user entry of diffractometer angles (note these are not motors). */
		when (efTest(TTH_mon)) {
			if (orientDebug) {printf("\norient: client wrote TTH\n");}
			if (!Busy) PVPUT(Busy, 1);
			efClear(TTH_mon);
		} state newAngles

		when (efTest(TH_mon)) {
			if (orientDebug) {printf("\norient: client wrote TH\n");}
			if (!Busy) PVPUT(Busy, 1);
			efClear(TH_mon);
		} state newAngles

		when (efTest(CHI_mon)) {
			if (orientDebug) {printf("\norient: client wrote CHI\n");}
			if (!Busy) PVPUT(Busy, 1);
			efClear(CHI_mon);
		} state newAngles
		
		when (efTest(PHI_mon)) {
			if (orientDebug) {printf("\norient: client wrote PHI\n");}
			if (!Busy) PVPUT(Busy, 1);
			efClear(PHI_mon);
		} state newAngles

		/*
		 * Detect motor events.  There are two possible event types: a new motor value, and
		 * the completion message resulting from a pvPut(<motor>, ASYNC) call that we made.
		 * We try to distinguish these event types, using three pieces of information:
		 * A) weWrote_motXXX        - a flag we set when we write to the motor
		 * B) waiting4motXXX        - a flag we set when we write to the motor
		 * C) pvPutComplete(motXXX) - returns true after pvPut(<motor>, ASYNC), and continues
		 *                            to return true until the EPICS calls SNL back to say the
		 *                            motor (and any processing it may have triggered) is done.
		 *
		 * If the event is a new value, there are three possibilities:
		 * 1) We caused the event directly by writing to the motor, which resulted in
		 *    an immediate posting of the new value.  In this case, we simply clear the flag
		 *    (weWrote_motXXX) that we set at the time we wrote to the motor.
		 * 2) We caused the event indirectly by causing the motor to move, which resulted
		 *    in a delayed posting of the motor value when the motor stopped.  In this case
		 *    we expect the event will coincide with the done event, and will be masked by it.
		 * 3) We had nothing to do with it.  Some outside agent wrote to the motor.
		 *    In this case we start the process of reconciling HKL and angles with the new
		 *    motor position.
		 * Note that if the motor motion is short enough, we expect (1) and (2) to coincide with
		 * each other, and with the done event, which we expect to mask them both.
		 *
		 * If the event indicates completion, we clear both flags and start the process of
		 * reconciling HKL and angles with the new motor position (in case the motors did not
		 * get where we told them to go).
		 */
		when (efTest(motTTH_mon) && waiting4motTTH && pvPutComplete(motTTH)) {
			if (orientDebug) {printf("orient: motTTH done moving\n");}
			efClear(motTTH_mon); PVPUT(waiting4motTTH, 0);
			/*
			 * If motor completes immediately, the monitor and done events will
			 * set the (shared) event flag twice.  There's no way we can tell if
			 * this happened, except to assume the done event must come after the
			 * monitor event.
			 */ 
			if (weWrote_motTTH) PVPUT(weWrote_motTTH, 0);
		} state checkNewMotorValues
		when (efTest(motTTH_mon) && weWrote_motTTH) {
			if (orientDebug) {printf("orient: We wrote motTTH\n");}
			efClear(motTTH_mon); PVPUT(weWrote_motTTH, 0);
		} state monitor_all 
		when (efTest(motTTH_mon) && !weWrote_motTTH) {
			if (orientDebug) {printf("orient: client wrote motTTH\n");}
			efClear(motTTH_mon);
		} state checkNewMotorValues

		when (efTest(motTH_mon) && waiting4motTH && pvPutComplete(motTH)) {
			if (orientDebug) {printf("orient: motTH done moving\n");}
			efClear(motTH_mon); PVPUT(waiting4motTH, 0);
			if (weWrote_motTH) PVPUT(weWrote_motTH, 0);
		} state checkNewMotorValues
		when (efTest(motTH_mon) && weWrote_motTH) {
			if (orientDebug) {printf("orient: We wrote motTH\n");}
			efClear(motTH_mon); PVPUT(weWrote_motTH, 0);
		} state monitor_all 
		when (efTest(motTH_mon) && !weWrote_motTH) {
			if (orientDebug) {printf("orient: client wrote motTH\n");}
			efClear(motTH_mon);
		} state checkNewMotorValues

		when (efTest(motCHI_mon) && waiting4motCHI && pvPutComplete(motCHI)) {
			if (orientDebug) {printf("orient: motCHI done moving\n");}
			efClear(motCHI_mon); PVPUT(waiting4motCHI, 0);
			if (weWrote_motCHI) PVPUT(weWrote_motCHI, 0);
		} state checkNewMotorValues
		when (efTest(motCHI_mon) && weWrote_motCHI) {
			if (orientDebug) {printf("orient: We wrote motCHI\n");}
			efClear(motCHI_mon); PVPUT(weWrote_motCHI, 0);
		} state monitor_all 
		when (efTest(motCHI_mon) && !weWrote_motCHI) {
			if (orientDebug) {printf("orient: client wrote motCHI\n");}
			efClear(motCHI_mon);
		} state checkNewMotorValues

		when (efTest(motPHI_mon) && waiting4motPHI && pvPutComplete(motPHI)) {
			if (orientDebug) {printf("orient: motPHI done moving\n");}
			efClear(motPHI_mon); PVPUT(waiting4motPHI, 0);
			if (weWrote_motPHI) PVPUT(weWrote_motPHI, 0);
		} state checkNewMotorValues
		when (efTest(motPHI_mon) && weWrote_motPHI) {
			if (orientDebug) {printf("orient: We wrote motPHI\n");}
			efClear(motPHI_mon); PVPUT(weWrote_motPHI, 0);
		} state monitor_all 
		when (efTest(motPHI_mon) && !weWrote_motPHI) {
			if (orientDebug) {printf("orient: client wrote motPHI\n");}
			efClear(motPHI_mon);
		} state checkNewMotorValues
		
		when (Busy && waiting4Mot && (waiting4motTTH==0) && (waiting4motTH==0) &&
				(waiting4motCHI==0) && (waiting4motPHI==0)) {
			PVPUT(waiting4Mot, 0);
			PVPUT(Busy, 0);
			if (H_busy) PVPUT(H_busy, 0);
			if (K_busy) PVPUT(K_busy, 0);
			if (L_busy) PVPUT(L_busy, 0);
			if (TTH_busy) PVPUT(TTH_busy, 0);
			if (TH_busy) PVPUT(TH_busy, 0);
			if (CHI_busy) PVPUT(CHI_busy, 0);
			if (PHI_busy) PVPUT(PHI_busy, 0);
			if (orientDebug) {printf("motors done\n");}
		} state monitor_all

		when (efTest(Mode_mon)) {
			efClear(Mode_mon);
			if (orientDebug) {
				PUTMSG("new HKL-to-Angles Mode");
				printf("...Mode=%d\n", Mode);
			}
		} state newHKL

		when (motPut) {
			if (orientDebug) {printf("orient: motPut==%d\n", motPut);}
			PVPUT(weWrote_motTTH, 1); motTTH = TTH; PVPUT(waiting4motTTH, 1); pvPut(motTTH, ASYNC);
			PVPUT(weWrote_motTH,  1); motTH  = TH;  PVPUT(waiting4motTH,  1); pvPut(motTH, ASYNC);
			PVPUT(weWrote_motCHI, 1); motCHI = CHI; PVPUT(waiting4motCHI, 1); pvPut(motCHI, ASYNC);
			PVPUT(weWrote_motPHI, 1); motPHI = PHI; PVPUT(waiting4motPHI, 1); pvPut(motPHI, ASYNC);
			motPut = 0; PVPUT(load_motPut, motPut);
			PVPUT(waiting4Mot, 1);
		} state monitor_all

		when (motGet) {
		} state checkNewMotorValues

		when (refGet1) {
			PVPUT(H1, H); PVPUT(K1, K); PVPUT(L1, L);
			PVPUT(TTH1, TTH); PVPUT(TH1, TH); PVPUT(CHI1, CHI); PVPUT(PHI1, PHI);
		} state ref_show

		when (refGet2) {
			PVPUT(H2, H); PVPUT(K2, K); PVPUT(L2, L);
			PVPUT(TTH2, TTH); PVPUT(TH2, TH); PVPUT(CHI2, CHI); PVPUT(PHI2, PHI);
		} state ref_show

		when (refPut1) {
			PVPUT(H, H1); PVPUT(K, K1); PVPUT(L, L1);
			PVPUT(TTH, TTH1); PVPUT(TH, TH1); PVPUT(CHI, CHI1); PVPUT(PHI, PHI1);
		} state ref_show

		when (refPut2) {
			PVPUT(H, H2); PVPUT(K, K2); PVPUT(L, L2);
			PVPUT(TTH, TTH2); PVPUT(TH, TH2); PVPUT(CHI, CHI2); PVPUT(PHI, PHI2);
		} state ref_show

		when (opAck) {
			PUTMSG("");
			PVPUT(opAck, 0);
			PVPUT(Alert, 0);
		} state monitor_all
	}

	state newA0 {
		when (A0_exists != 1) {
		} state monitor_all
		when (A0_exists == 1) {
		} state newHKL
	}

	state newOMTX {
		when (OMTX_exists == 1) {
		} state newHKL
		when (OMTX_exists != 1) {
			PVPUT(motPut_Auto, 0);
			PUTALERT("Bad OMTX calc; motPut_Auto set to Manual");
		} state monitor_all
	}

	state newHKL {
		when ((A0_exists == 0) || (OMTX_exists == 0)) {
			if (A0_exists == 0) {
				PUTALERT("A0 has not been calculated");
			} else {
				PUTALERT("OMTX has not been calculated");
			}
		} state monitor_all
		when (delay(.02)) {
			if (efTest(H_mon)) {efClear(H_mon); if (orientDebug) printf("orient:newHKL: client also wrote H\n");}
			if (efTest(K_mon)) {efClear(K_mon); if (orientDebug) printf("orient:newHKL: client also wrote K\n");}
			if (efTest(L_mon)) {efClear(L_mon); if (orientDebug) printf("orient:newHKL: client also wrote L\n");}
			/* calc angles */
			%%hkl[_H_] = H; hkl[_K_] = K; hkl[_L_] = L;
			%%angles[_TTH_] = TTH; angles[_TH_] = TH;
			%%angles[_CHI_] = CHI; angles[_PHI_] = PHI;
			%%i = HKL_to_angles(hkl, A0, OMTX, angles, (int)Mode);
			if (i == 0 && ((H != 0) || (K != 0) || (L != 0))) {
				%%TTH = angles[_TTH_]; TH = angles[_TH_]; CHI = angles[_CHI_]; PHI = angles[_PHI_];
				PVPUT(newAngles, 1);
				if (motPut_Auto) PVPUT(newMotors, 1);
			} else if (i) {
				PUTALERT("Bad HKL2angles calc.");
			}
		} state putAll
	}

	state newAngles {
		when ((A0_exists == 0) || (OMTX_exists == 0)) {
			if (A0_exists == 0) {
				PUTALERT("A0 has not been calculated");
			} else {
				PUTALERT("OMTX has not been calculated");
			}
		} state monitor_all
		when (delay(.02)) {
			if (efTest(TTH_mon)) {efClear(TTH_mon); if (orientDebug) printf("orient:newAngles: client also wrote TTH\n");}
			if (efTest(TH_mon)) {efClear(TH_mon); if (orientDebug) printf("orient:newAngles: client also wrote TH\n");}
			if (efTest(CHI_mon)) {efClear(CHI_mon); if (orientDebug) printf("orient:newAngles: client also wrote CHI\n");}
			if (efTest(PHI_mon)) {efClear(PHI_mon); if (orientDebug) printf("orient:newAngles: client also wrote PHI\n");}
			/* calc HKL */
			%%angles[_TTH_] = TTH; angles[_TH_] = TH;
			%%angles[_CHI_] = CHI; angles[_PHI_] = PHI;
			%%angles_to_HKL(angles, OMTX_i, A0_i, hkl);
			%%H = hkl[_H_]; K = hkl[_K_]; L = hkl[_L_];
			PVPUT(newHKL, 1);
			if (motPut_Auto) {
				PVPUT(newMotors, 1);
			}
		} state putAll
	}

	state checkNewMotorValues {
		when (motTTH==0 && motTH==0 && motCHI==0 && motPHI==0) {
			/* ignore all-zeroes posting */
			if (motGet) PVPUT(motGet, 0);
		} state monitor_all
		when () {
			if (orientDebug) {printf("orient:checkNewMotorValues: values OK\n");}
		} state newMotors
	}

	state newMotors {
		when () {
			if (orientDebug) {printf("orient:newMotors: motGet=%d\n", motGet);}
			if (motGet || motGet_Auto) {
				/* get angles */
				if (orientDebug) {printf("orient:newMotors: getting values\n");}
				TTH = motTTH; TH = motTH; CHI = motCHI; PHI = motPHI;
				PVPUT(newAngles, 1);
				/* calc HKL */
				%%angles[_TTH_] = TTH; angles[_TH_] = TH;
				%%angles[_CHI_] = CHI; angles[_PHI_] = PHI;
				%%angles_to_HKL(angles, OMTX_i, A0_i, hkl);
				%%H = hkl[_H_]; K = hkl[_K_]; L = hkl[_L_];
				PVPUT(newHKL, 1);
				if (motGet) PVPUT(motGet, 0);
			}
		} state putAll
	}

	state putAll {
		when () {
			if (newHKL) {
				if (orientDebug) {printf("orient:putAll: writing HKL\n");}
				PVPUT(loadH, H);
				PVPUT(loadK, K);
				PVPUT(loadL, L);
				PVPUT(newHKL, 0);
			}
			if (newAngles) {
				if (orientDebug) {printf("orient:putAll: writing Angles\n");}
				PVPUT(loadTTH, TTH);
				PVPUT(loadTH,  TH);
				PVPUT(loadCHI, CHI);
				PVPUT(loadPHI, PHI);
				PVPUT(newAngles, 0);
			}
			if (newMotors) {
				if (orientDebug) {printf("orient:putAll: writing Motors\n");}
				if (motTTH_Connected && motTH_Connected && motCHI_Connected && motPHI_Connected) {
					if (orientDebug) {
						printf("putAll:newMotors: TTH=%8.4f, motTTH=%8.4f, H=%8.4f\n", TTH, motTTH, H);
						printf("putAll:newMotors:  TH=%8.4f,  motTH=%8.4f, K=%8.4f\n", TH, motTH, K);
						printf("putAll:newMotors: CHI=%8.4f, motCHI=%8.4f, L=%8.4f\n", CHI, motCHI, L);
						printf("putAll:newMotors: PHI=%8.4f, motPHI=%8.4f\n", PHI, motPHI);
					}
					if (motTTH != TTH) {
						PVPUT(weWrote_motTTH, 1); PVPUT(waiting4motTTH, 1);
						motTTH = TTH; pvPut(motTTH, ASYNC);
					}
					if (motTH != TH) {
						PVPUT(weWrote_motTH,  1); PVPUT(waiting4motTH,  1);
						motTH = TH; pvPut(motTH, ASYNC);
					}
					if (motCHI != CHI) {
						PVPUT(weWrote_motCHI , 1); PVPUT(waiting4motCHI, 1);
						motCHI = CHI; pvPut(motCHI, ASYNC);
					}
					if (motPHI != PHI) {
						PVPUT(weWrote_motPHI, 1); PVPUT(waiting4motPHI, 1);
						motPHI = PHI; pvPut(motPHI, ASYNC);
					}
					if (waiting4motTTH || waiting4motTH || waiting4motCHI || waiting4motPHI) {
						PVPUT(waiting4Mot, 1);
						if (!Busy) PVPUT(Busy, 1);
					}
					PVPUT(newMotors, 0);
				} else {
					PUTALERT("Motors not connected");
					PVPUT(newMotors, 0);
				}
				
			} else if (!waiting4Mot) {
				if (Busy) PVPUT(Busy, 0);
				if (H_busy) PVPUT(H_busy, 0);
				if (K_busy) PVPUT(K_busy, 0);
				if (L_busy) PVPUT(L_busy, 0);
				if (TTH_busy) PVPUT(TTH_busy, 0);
				if (TH_busy) PVPUT(TH_busy, 0);
				if (CHI_busy) PVPUT(CHI_busy, 0);
				if (PHI_busy) PVPUT(PHI_busy, 0);
				if (orientDebug) {printf("orient:putAll: all complete (no motors)\n");}
			}
		} state monitor_all
	}
}

ss connections {
	state check {
		/* Report connection state of motor PV's */
		when (delay(1)) {
			old_connect_state = motTTH_Connected;
			motTTH_Connected = pvAssigned(motTTH) ? pvConnected(motTTH) : 0;
			if (old_connect_state != motTTH_Connected) pvPut(motTTH_Connected);

			old_connect_state = motTH_Connected;
			motTH_Connected = pvAssigned(motTH) ? pvConnected(motTH) : 0;
			if (old_connect_state != motTH_Connected) pvPut(motTH_Connected);

			old_connect_state = motCHI_Connected;
			motCHI_Connected = pvAssigned(motCHI) ? pvConnected(motCHI) : 0;
			if (old_connect_state != motCHI_Connected) pvPut(motCHI_Connected);

			old_connect_state = motPHI_Connected;
			motPHI_Connected = pvAssigned(motPHI) ? pvConnected(motPHI) : 0;
			if (old_connect_state != motPHI_Connected) pvPut(motPHI_Connected);
		} state check
	}
}

ss readback {
	state rbv_monitor_throttle {
		when (delay(.1)) {
		} state rbv_monitor
	}

	state rbv_monitor_wait {
		when ((A0_exists == 1) && (OMTX_exists == 1)) {
		} state rbv_monitor

		when (delay(5)) {
		} state rbv_monitor
	}

	state rbv_monitor {
		when ((A0_exists != 1) || (OMTX_exists != 1)) {
			PVPUT(motTTH_RBV, 0);
			PVPUT(motTH_RBV, 0);
			PVPUT(motCHI_RBV, 0);
			PVPUT(motPHI_RBV, 0);
		} state rbv_monitor_wait

		when (efTest(motTTH_RBV_mon) || efTest(motTH_RBV_mon) || efTest(motCHI_RBV_mon) || efTest(motPHI_RBV_mon)) {
			efClear(motTTH_RBV_mon); efClear(motTH_RBV_mon); efClear(motCHI_RBV_mon); efClear(motPHI_RBV_mon);
			/* calc HKL */
			%%rbv_angles[_TTH_] = motTTH_RBV; rbv_angles[_TH_] = motTH_RBV;
			%%rbv_angles[_CHI_] = motCHI_RBV; rbv_angles[_PHI_] = motPHI_RBV;
			%%angles_to_HKL(rbv_angles, OMTX_i, A0_i, rbv_hkl);
			%%H_RBV = rbv_hkl[_H_]; K_RBV = rbv_hkl[_K_]; L_RBV = rbv_hkl[_L_];
			pvPut(H_RBV); pvPut(K_RBV); pvPut(L_RBV);
		} state rbv_monitor_throttle
	}
}

ss stop {
	state stop_all {
		when (stopMotors) {
			PUTMSG("stopping motors");
			if (pvAssigned(motTTH_stop) && pvConnected(motTTH_stop)) PVPUT(motTTH_stop, 1);
			if (pvAssigned(motTH_stop) && pvConnected(motTH_stop)) PVPUT(motTH_stop, 1);
			if (pvAssigned(motCHI_stop) && pvConnected(motCHI_stop)) PVPUT(motCHI_stop, 1);
			if (pvAssigned(motPHI_stop) && pvConnected(motPHI_stop)) PVPUT(motPHI_stop, 1);
			PVPUT(stopMotors, 0);
		} state stop_all
	}
}
