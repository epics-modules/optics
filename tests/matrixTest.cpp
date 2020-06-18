#include <cmath>
#include <vector>
#include <numeric>
#include <cstddef>

#include <epicsMath.h>
#include <epicsUnitTest.h>
#include <testMain.h>

extern "C"
{
	#include "matrix3.h"
}

void testDot(double x1, double y1, double z1, double x2, double y2, double z2)
{
	std::vector<double> vec1;
	std::vector<double> vec2;
	
	vec1.push_back(x1);
	vec1.push_back(y1);
	vec1.push_back(z1);
	
	vec2.push_back(x2);
	vec2.push_back(y2);
	vec2.push_back(z2);
	
	double expected = std::inner_product(vec1.begin(), vec1.end(), vec2.begin(), 0); 
	double result = dot(&vec1[0], &vec2[0]);
	
	bool pass;
	
	if (finite(expected) and finite(result))
	{
		pass = fabs(expected - result) < 1e-8;
	}
	else if (isnan(expected))
	{
		pass = (bool) isnan(result);
	}
	else
	{
		pass = (result == expected);
	}
	
	if(!testOk(pass, "<%f, %f, %f> . <%f, %f, %f>", x1, y1, z1, x2, y2, z2))
	{
		testDiag("Expected: %f, Got: %f", expected, result);
	}	
}

void testCross(double v1[3], double v2[3], double expected[3])
{
	double result[3];
	
	cross(v1, v2, result);
	
	bool pass = true;

	int i;
	
	for (i = 0; i < 3; i += 1)
	{
		if (finite(expected[i]) and finite(result[i]))
		{
			if (fabs(expected[i] - result[i]) > 1e-8)
			{
				pass = false;
				break;
			}
		}
		else if (isnan(expected[i]) and not isnan(result[i]))
		{
			pass = false;
			break;
		}
		else if (result[i] != expected[i])
		{
			pass = false;
			break;
		}
	}
	
	if (!testOk(pass, "<%f, %f, %f> x <%f, %f, %f>", v1[0], v1[1], v1[2], v2[0], v2[1], v2[2]))
	{
		testDiag("Expected index %d: %f, Got: %f", i, expected[i], result[i]);
	}
}

void testDotCross(double v1[3], double v2[3], double v3[3])
{
	double crossed[3];
	
	cross(v2, v3, crossed);
	
	double expected = dot(v1, crossed);
	double result = dotcross(v1, v2, v3);

	bool pass;
	
	if (finite(expected) and finite(result))
	{
		pass = fabs(expected - result) < 1e-8;
	}
	else if (isnan(expected))
	{
		pass = (bool) isnan(result);
	}
	else
	{
		pass = (result == expected);
	}
	
	if(!testOk(pass, "<%f, %f, %f> . (<%f, %f, %f> x <%f, %f, %f>)", v1[0], v1[1], v1[2], v2[0], v2[1], v2[2], v3[0], v3[1], v3[2]))
	{
		testDiag("Expected: %f, Got: %f", expected, result);
	}	
}

void testMultArrayArray(double m1[3][3], double m2[3][3], double expected[3][3])
{
	double result[3][3];
	
	multArrayArray(m1, m2, result);
	
	int i, j;
	
	bool pass = true;
	
	for (i = 0; i < 3; i += 1)
	{
		for (j = 0; j < 3; j += 1)
		{
			if (finite(expected[i][j]) and finite(result[i][j]))
			{
				if (fabs(expected[i][j] - result[i][j]) > 1e-8)
				{
					pass = false;
					break;
				}
			}
			else if (isnan(expected[i][j]) and not isnan(result[i][j]))
			{
				pass = false;
				break;
			}
			else if (result[i][j] != expected[i][j])
			{
				pass = false;
				break;
			}
		}
		
		if (pass == false)    { break; }
	}
		
	if(!testOk(pass, "\n|%f, %f, %f|   |%f, %f, %f|\n|%f, %f, %f| X |%f, %f, %f|\n|%f, %f, %f|   |%f, %f, %f|\n", 
	                  m1[0][0], m1[0][1], m1[0][2], m2[0][0], m2[0][1], m2[0][2],
	                  m1[1][0], m1[1][1], m1[1][2], m2[1][0], m2[1][1], m2[1][2],
	                  m1[2][0], m1[2][1], m1[2][2], m2[2][0], m2[2][1], m2[2][2]))
	{
		testDiag("Expected [%d][%d]: %f, Got: %f", i, j, expected[i][j], result[i][j]);
	}	
}

void testMultArrayVector(double m1[3][3], double v2[3], double expected[3])
{
	double result[3];
	
	multArrayVector(m1, v2, result);
	
	int i;
	
	bool pass = true;
	
	for (i = 0; i < 3; i += 1)
	{
		if (finite(expected[i]) and finite(result[i]))
		{
			if (fabs(expected[i] - result[i]) > 1e-8)
			{
				pass = false;
				break;
			}
		}
		else if (isnan(expected[i]) and not isnan(result[i]))
		{
			pass = false;
			break;
		}
		else if (result[i] != expected[i])
		{
			pass = false;
			break;
		}
	}
	
	if (!testOk(pass, "\n|%f, %f, %f|\n|%f, %f, %f| x <%f, %f, %f>\n|%f, %f, %f|\n",
	                   m1[0][0], m1[0][1], m1[0][2], 
	                   m1[1][0], m1[1][1], m1[1][2], v2[0], v2[1], v2[2],
	                   m1[2][0], m1[2][1], m1[2][2]))
	{
		testDiag("Expected index %d: %f, Got: %f", i, expected[i], result[i]);
	}
}

void testDeterminant(double arr[3][3], double expected)
{
	double result = determinant(arr);
	
	bool pass;
	
	if (finite(expected) and finite(result))
	{
		pass = fabs(expected - result) < 1e-8;
	}
	else if (isnan(expected))
	{
		pass = (bool) isnan(result);
	}
	else
	{
		pass = (result == expected);
	}
	
	if(!testOk(pass, "Determinant of \n|%f, %f, %f|\n|%f, %f, %f|\n|%f, %f, %f|\n", 
		              arr[0][0], arr[0][1], arr[0][2], 
		              arr[1][0], arr[1][1], arr[1][2],
		              arr[2][0], arr[2][1], arr[2][2]))
	{
		testDiag("Expected: %f, Got: %f", expected, result);
	}	
}

void testInvertArray(double arr[3][3], double expected[3][3])
{
	double result[3][3];
	
	int i, j;
	
	int status = invertArray(arr, result);
	
	if (status != 0)
	{
		if (! testOk(expected == NULL, "\n|%f, %f, %f| ^-1\n|%f, %f, %f|\n|%f, %f, %f|\n", 
		                                arr[0][0], arr[0][1], arr[0][2], 
		                                arr[1][0], arr[1][1], arr[1][2],
		                                arr[2][0], arr[2][1], arr[2][2]))
		{
			testDiag("Expected determinant too small error.");
		}
		
		return;
	}
	
	bool pass = true;
		
	for (i = 0; i < 3; i += 1)
	{
		for (j = 0; j < 3; j += 1)
		{
			if (finite(expected[i][j]) and finite(result[i][j]))
			{
				if (fabs(expected[i][j] - result[i][j]) > 1e-8)
				{
					pass = false;
					break;
				}
			}
			else if (isnan(expected[i][j]) and not isnan(result[i][j]))
			{
				pass = false;
				break;
			}
			else if (result[i][j] != expected[i][j])
			{
				pass = false;
				break;
			}
		}
		
		if (pass == false)    { break; }
	}

	if (!testOk(pass, "\n|%f, %f, %f| ^-1\n|%f, %f, %f|\n|%f, %f, %f|\n", 
	                   arr[0][0], arr[0][1], arr[0][2], 
	                   arr[1][0], arr[1][1], arr[1][2],
	                   arr[2][0], arr[2][1], arr[2][2]))
	{
		testDiag("Expected [%d][%d]: %f, Got: %f", i, j, expected[i][j], result[i][j]);
	}
}

MAIN(matrixTest)
{
	testPlan(56);
	
	double zeroes_vector[3] = {0., 0., 0.};
	double ones_vector[3]   = {1., 1., 1.};
	double vector1[3]       = {1., 2., 3.};
	double vector2[3]       = {10.,71.,45.};
	double vector3[3]       = {5.,10.,15.};
	
	double vector_result1_1[3] = {14.,32.,50.};
	double vector_result2_1[3] = {25.,17.,10.};
	double vector_result1_2[3] = {287.,665.,1043.};
	double vector_result2_2[3] = {790.,194.,391.};
	
	double crossed1_2[3] = {-123., -15., 51.};
	double crossed2_3[3] = {615., 75., -255.};
	double crossed3_2[3] = {-615.,-75.,255.};
	
	double vector_sum1[3] = {6.,15.,24.};
	double vector_sum2[3] = {11.,8.,6.};
	
	double matrix1[3][3] = 
	{
		{1.0, 2.0, 3.0},
		{4.0, 5.0, 6.0},
		{7.0, 8.0, 9.0}
	};
	
	double matrix2[3][3] = 
	{
		{-1.0, 10.0, 2.0},
		{4.0, -1.0, 5.0},
		{1.0, 6.0, -1.0}
	};
	
	double matrix_result1[3][3] = 
	{
		{-29./169., 22./169., 52./169.},
		{9./169., -1./169., 13./169.},
		{25./169., 16./169., -39./169.}
	};
	
	double matrix_result2[3][3] =
	{
		{10.0, 26.0, 9.0},
		{22.0, 71.0, 27.0},
		{34.0, 116.0, 45.0}
	};
	
	double identity_matrix[3][3] = 
	{
		{1.0, 0.0, 0.0},
		{0.0, 1.0, 0.0},
		{0.0, 0.0, 1.0}
	};
	
	double zeroes_matrix[3][3] =
	{
		{0.0, 0.0, 0.0},
		{0.0, 0.0, 0.0},
		{0.0, 0.0, 0.0}
	};
	
	testDot(-1,-1,-1, 1,1,1);
	testDot( 0,-1,-1, 1,2,3);
	testDot(-1, 0,-1, 1,2,3);
	testDot(-1,-1, 0, 1,2,3);
	testDot( 0, 0,-1, 1,2,3);
	testDot( 0,-1, 0, 1,2,3);
	testDot(-1, 0, 0, 1,2,3);
	
	testDot( 0, 0, 0, 0,0,0);
	
	testDot( 1, 0, 0, 1,2,3);
	testDot( 0, 1, 0, 1,2,3);
	testDot( 0, 0, 1, 1,2,3);
	testDot( 1, 1, 0, 1,2,3);
	testDot( 1, 0, 1, 1,2,3);
	testDot( 0, 1, 1, 1,2,3);
	testDot( 1, 1, 1, 1,2,3);
	
	testDot( 1, 1, 1, 1,1,1);
	
	testCross(zeroes_vector, zeroes_vector, zeroes_vector);
	testCross(ones_vector, ones_vector, zeroes_vector);
	testCross(vector1, vector2, crossed1_2);
	testCross(vector1, vector3, zeroes_vector);
	testCross(vector2, vector3, crossed2_3);
	testCross(vector3, vector2, crossed3_2);
	
	testDotCross(zeroes_vector, zeroes_vector, zeroes_vector);
	testDotCross(ones_vector, ones_vector, ones_vector);
	
	testDotCross(vector1, vector2, zeroes_vector);
	testDotCross(vector1, vector2, ones_vector);
	testDotCross(vector1, vector2, vector3);
	
	testDotCross(vector1, vector3, zeroes_vector);
	testDotCross(vector1, vector3, ones_vector);
	testDotCross(vector1, vector3, vector1);
	
	testDotCross(vector2, vector1, zeroes_vector);
	testDotCross(vector2, vector1, ones_vector);
	testDotCross(vector2, vector1, vector3);
	
	testDotCross(vector3, vector2, zeroes_vector);
	testDotCross(vector3, vector2, ones_vector);
	testDotCross(vector3, vector2, vector1);
	
	testDotCross(vector3, vector1, zeroes_vector);
	testDotCross(vector3, vector1, ones_vector);
	testDotCross(vector3, vector1, vector2);
	
	double inverted[3][3];
	invertArray(matrix2, inverted);
	
	testDeterminant(matrix1, 0);
	testDeterminant(matrix2, 169);
	testDeterminant(identity_matrix, 1);
	
	testInvertArray(matrix1, NULL);
	testInvertArray(identity_matrix, identity_matrix);
	testInvertArray(matrix2, matrix_result1);
	
	testMultArrayArray(matrix1, zeroes_matrix, zeroes_matrix);
	testMultArrayArray(matrix1, identity_matrix, matrix1);
	testMultArrayArray(matrix1, matrix2, matrix_result2);
	testMultArrayArray(matrix2, inverted, identity_matrix);
	
	testMultArrayVector(matrix1, zeroes_vector, zeroes_vector);
	testMultArrayVector(matrix1, ones_vector, vector_sum1);
	testMultArrayVector(matrix2, ones_vector, vector_sum2);
	testMultArrayVector(matrix1, vector1, vector_result1_1);
	testMultArrayVector(matrix1, vector2, vector_result1_2);
	testMultArrayVector(matrix2, vector1, vector_result2_1);
	testMultArrayVector(matrix2, vector2, vector_result2_2);
	
	return testDone();
}
