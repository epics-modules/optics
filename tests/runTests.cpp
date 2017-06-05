#include <epicsUnitTest.h>

int matrixTest(void);

void runOpticsTests(void)
{
	testHarness();
	
	runTest(matrixTest);
}
