/* matrix3.h - general 3x3-matrix/3-vector functions */
epicsShareFunc void printVector(double v[3], char *name);
epicsShareFunc void print4Vector(double v[4], char *name);
epicsShareFunc void printArray(double a[3][3], char *name);
epicsShareFunc double dot(double a[3], double b[3]);
epicsShareFunc void cross(double a[3], double b[3], double r[3]);
epicsShareFunc double dotcross(double a[3], double b[3], double c[3]);
epicsShareFunc void multArrayArray(double a[3][3], double b[3][3], double r[3][3]);
epicsShareFunc void multArrayVector(double a[3][3], double v[3], double r[3]);
epicsShareFunc double determinant(double a[3][3]);
epicsShareFunc int invertArray(double a[3][3], double r[3][3]);

#define SMALL 1.e-11
