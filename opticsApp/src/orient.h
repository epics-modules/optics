/* orient.h */

/* orientation-matrix functions */
void calc_rotZ(double a, double r[3][3]);
void calc_rotY(double a, double r[3][3]);
int angles_to_HKL(double angles[4], double omtx_inv[3][3], double a0_inv[3][3], double hkl[3]);
int HKL_to_angles(double hkl[3], double a0[3][3], double omtx[3][3], double angles[4], int constraint);
int calc_A0(double a, double b, double c,
              double alpha, double beta, double gamma,
			  double lambda, double r[3][3], double r_i[3][3]);
int calc_OMTX(double v1_hkl[3], double v1_mot[4], double v2_hkl[3], double v2_mot[4],
                double a0[3][3], double a0_i[3][3], double o[3][3], double o_i[3][3]);
double checkOMTX(double v2_hkl[3], double v2_mot_arg[4], double a0[3][3],
	double a0_inv[3][3], double o[3][3], double o_inv[3][3]);			
/* indices for angle vectors */
#define _TTH_ 0
#define  _TH_ 1
#define _CHI_ 2
#define _PHI_ 3

/* indices for HKL vectors */
#define _H_ 0
#define _K_ 1
#define _L_ 2

/* Constraints for HKL_to_motors */
#define OMEGA_ZERO		0	/* Set TH == TTH/2 */
#define MIN_CHI_PHIm90	1	/* Minimize the quantities CHI and (PHI-PI/2) */
#define PHI_CONST		2	/* Use PHI as delivered to function */
