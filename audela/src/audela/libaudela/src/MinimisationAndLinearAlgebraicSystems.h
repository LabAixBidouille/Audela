/**
 * Header file for Levenberg-Marquardt minimisation and linear algebraic systems
 *
 * Author : Yassine Damerdji
 */

#ifndef __MINIMISATIONANDLINEARALGEBRAICSYSTEMS__
#define __MINIMISATIONANDLINEARALGEBRAICSYSTEMS__

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include "AllExceptions.h"

#define RATIO_DIAGONAL_EXTRAMUM_LIMIT 1e-15

#ifndef M_PI
# define M_PI 3.14159265358979323846
#endif

/**
 * Interface for minimisation (Levenberg-Marquardt)
 */
class MinimisationInterface {

public:
	MinimisationInterface() {};
	virtual ~MinimisationInterface() {};
	virtual double computeChiSquare(const double* const arrayOfParameters) = 0;

};

/**
 *Interface for linear algebraic systems
 */
class LinearAlgebraicSystemInterface {

public:
	LinearAlgebraicSystemInterface() {};
	virtual ~LinearAlgebraicSystemInterface() {};
	virtual void fillWeightedDesignMatrix(double* const * const weightedDesignMatrix) = 0;
	virtual void fillWeightedObservations(double* const weightedObservartions) = 0;
	virtual const int getNumberOfMeasurements() = 0;
};

/**
 * Class to solve linear algebraic systems by Cholesky decomposition
 */
class LinearAlgebraicSystemSolver {

private:
	char logMessage[1024];
	LinearAlgebraicSystemInterface* theLinearAlgebraicSystem;
	int numberOfFitParameters;
	int maximumNumberOfMeasurements;
	int numberOfMeasurements;
	double** weightedDesignMatrix;
	double** curvatureMatrix;
	double* weightedObservations;
	double* projectedObservations;
	double** choleskyMatrix;
	double* intermediateArray;
	double* fitCoefficients;
	void computeCurvatureMatrix();
	void computeProjectedObservations();
	void decomposeCurvatureMatrix() throw (BadlyConditionnedMatrixException,NonDefinitePositiveMatrixException);
	void isMatrixBadlyConditionned(const double diagonalElement,double& minimumOfDiagonal,double& maximumOfDiagonal) throw (BadlyConditionnedMatrixException);
	void finishSolvingTheSystem();

public:
	LinearAlgebraicSystemSolver(LinearAlgebraicSystemInterface* const inputLinearAlgebraicSystem,
			const int inputNumberOfFitParameters, const int inputMaximumNumberOfMeasurements) throw (InsufficientMemoryException);
	virtual ~LinearAlgebraicSystemSolver();
	void solveSytem() throw (BadlyConditionnedMatrixException,NonDefinitePositiveMatrixException);
	bool getComputationDiverges() const;
	const double* const getFitCoefficients() const;
};

#endif // __MINIMISATIONANDLINEARALGEBRAICSYSTEMS__
