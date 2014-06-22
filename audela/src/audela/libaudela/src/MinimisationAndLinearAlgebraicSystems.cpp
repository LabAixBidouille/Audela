/**
 * Source file for Levenberg-Marquardt minimisation and linear algebraic systems
 *
 * Author : Yassine Damerdji
 */

#include "MinimisationAndLinearAlgebraicSystems.h"

/**
 * Class constructor
 */
LinearAlgebraicSystemSolver::LinearAlgebraicSystemSolver(LinearAlgebraicSystemInterface* const inputLinearAlgebraicSystem,
		const int inputNumberOfFitParameters, const int inputMaximumNumberOfMeasurements) :
		theLinearAlgebraicSystem(inputLinearAlgebraicSystem), numberOfFitParameters(inputNumberOfFitParameters), maximumNumberOfMeasurements(inputMaximumNumberOfMeasurements) {

	numberOfMeasurements = -1;
	isMemoryInsufficient = false;
	computationDiverges  = false;

	weightedDesignMatrix     = new double*[numberOfFitParameters];
	if(weightedDesignMatrix == NULL) {
		isMemoryInsufficient = true;
		return;
	}

	curvatureMatrix          = new double*[numberOfFitParameters];
	if(curvatureMatrix      == NULL) {
		isMemoryInsufficient = true;
		return;
	}

	choleskyMatrix           = new double*[numberOfFitParameters];
	if(choleskyMatrix       == NULL) {
		isMemoryInsufficient = true;
		return;
	}

	for(int kParameter = 0; kParameter < numberOfFitParameters; kParameter++) {

		weightedDesignMatrix[kParameter]     = new double[maximumNumberOfMeasurements];
		if(weightedDesignMatrix[kParameter] == NULL) {
			isMemoryInsufficient             = true;
			return;
		}

		curvatureMatrix[kParameter]          = new double[numberOfFitParameters];
		if(curvatureMatrix[kParameter]      == NULL) {
			isMemoryInsufficient             = true;
			return;
		}

		choleskyMatrix[kParameter]           = new double[numberOfFitParameters];
		if(choleskyMatrix[kParameter]       == NULL) {
			isMemoryInsufficient             = true;
			return;
		}
	}

	weightedObservations      = new double[maximumNumberOfMeasurements];
	if(weightedObservations  == NULL) {
		isMemoryInsufficient  = true;
		return;
	}

	projectedObservations     = new double[numberOfFitParameters];
	if(projectedObservations == NULL) {
		isMemoryInsufficient  = true;
		return;
	}

	intermediateArray         = new double[numberOfFitParameters];
	if(intermediateArray     == NULL) {
		isMemoryInsufficient  = true;
		return;
	}

	fitCoefficients           = new double[numberOfFitParameters];
	if(fitCoefficients       == NULL) {
		isMemoryInsufficient  = true;
		return;
	}
}

/**
 * Class destructor
 */
LinearAlgebraicSystemSolver::~LinearAlgebraicSystemSolver() {

	for(int kParameter = 0; kParameter < numberOfFitParameters; kParameter++) {

		if(weightedDesignMatrix[kParameter] != NULL) {
			delete[] weightedDesignMatrix[kParameter];
			weightedDesignMatrix[kParameter] = NULL;
		}

		if(curvatureMatrix[kParameter]      != NULL) {
			delete[] curvatureMatrix[kParameter];
			curvatureMatrix[kParameter] = NULL;
		}

		choleskyMatrix[kParameter]           = new double[numberOfFitParameters];
		if(choleskyMatrix[kParameter]      != NULL) {
			delete[] choleskyMatrix[kParameter];
			choleskyMatrix[kParameter] = NULL;
		}
	}

	if(weightedDesignMatrix != NULL) {
		delete[] weightedDesignMatrix;
		weightedDesignMatrix = NULL;
	}

	if(curvatureMatrix != NULL) {
		delete[] curvatureMatrix;
		curvatureMatrix = NULL;
	}

	if(choleskyMatrix != NULL) {
		delete[] choleskyMatrix;
		choleskyMatrix = NULL;
	}

	if(weightedObservations != NULL) {
		delete[] weightedObservations;
		weightedObservations = NULL;
	}

	if(projectedObservations != NULL) {
		delete[] projectedObservations;
		projectedObservations = NULL;
	}

	if(intermediateArray != NULL) {
		delete[] intermediateArray;
		intermediateArray = NULL;
	}

	if(fitCoefficients   != NULL) {
		delete[] fitCoefficients;
		fitCoefficients   = NULL;
	}
}

/**
 * SOlve the algebraic system
 */
void LinearAlgebraicSystemSolver::solveSytem() {

	/* Retrieve the number of measurements */
	theLinearAlgebraicSystem->getNumberOfMeasurements();

	/* Fill the design matrix */
	theLinearAlgebraicSystem->fillWeightedDesignMatrix(weightedDesignMatrix);

	/* Fill the weighted observations */
	theLinearAlgebraicSystem->fillWeightedObservations(weightedObservations);

	/* Compute the curvature matrix = transpose(weightedDesignMatrix) * weightedDesignMatrix */
	computeCurvatureMatrix();

	/* Decompose the curvature matrix by the Cholesky decomposition */
	decomposeCurvatureMatrix();
	if(computationDiverges) {
		return;
	}

	/* Compute projectObservations = transpose(weightedDesignMatrix) * weightedObservations */
	computeProjectedObservations();

	/* Solve the system */
	finishSolvingTheSystem();
}

/**
 * Compute projectObservations = transpose(weightedDesignMatrix) * weightedObservations
 */
void LinearAlgebraicSystemSolver::computeProjectedObservations() {

	double theSum;

	for(int kParameter = 0; kParameter < numberOfFitParameters; kParameter++) {

		theSum       = 0.;
		for(int kMes = 0; kMes < numberOfMeasurements; kMes++) {
			theSum  += weightedDesignMatrix[kParameter][kMes] * weightedObservations[kMes];
		}

		projectedObservations[kParameter] = theSum;
	}
}

/**
 *  Compute the curvature matrix = transpose(weightedDesignMatrix) * weightedDesignMatrix
 */
void LinearAlgebraicSystemSolver::computeCurvatureMatrix() {

	double theSum;

	for(int kParameter1 = 0; kParameter1 < numberOfFitParameters; kParameter1++) {
		for(int kParameter2 = kParameter1; kParameter2 < numberOfFitParameters; kParameter2++) {

			theSum      = 0.;
			for(int kMes = 0; kMes < numberOfMeasurements; kMes++) {
				theSum += weightedDesignMatrix[kParameter1][kMes] * weightedDesignMatrix[kParameter2][kMes];
			}

			curvatureMatrix[kParameter1][kParameter2] = theSum;
			/* And its symmetric */
			curvatureMatrix[kParameter2][kParameter1] = theSum;
		}
	}
}

/**
 * Decompose the curvature matrix using Cholesky decomposition
 */
void LinearAlgebraicSystemSolver::decomposeCurvatureMatrix() {

	int j,k;
	double theSum,theSquare;
	double minimumOfDiagonal = 1e100;
	double maximumOfDiagonal = -1e100;

	for(int kParameter = 0; kParameter < numberOfFitParameters; kParameter++) {

		j = 0;
		while (j < kParameter) {

			theSum      = 0.;
			k           = 0;
			while (k    < j) {
				theSum += choleskyMatrix[kParameter][k] * choleskyMatrix[j][k];
				k++;
			}

			choleskyMatrix[kParameter][j] = (curvatureMatrix[kParameter][j] - theSum) / choleskyMatrix[j][j];
			j++;
		}

		theSum      = 0.;
		k           = 0;
		while (k    < kParameter) {
			theSum += choleskyMatrix[kParameter][k] * choleskyMatrix[kParameter][k];
			k++;
		}

		theSquare         = curvatureMatrix[kParameter][kParameter] - theSum;

		if(theSquare      > 0.) {

			choleskyMatrix[kParameter][kParameter] = sqrt(theSquare);
			isMatrixBadlyConditionned(choleskyMatrix[kParameter][kParameter],minimumOfDiagonal,maximumOfDiagonal);
			if(computationDiverges) {
				return;
			}

		} else {
			computationDiverges    = true;
			return;
		}
	}
}

/**
 * Finish solving the system
 */
void LinearAlgebraicSystemSolver::finishSolvingTheSystem() {

	int k;
	double theSum;

	// Fill intermediateSolution
	for (int indexOfRow = 0; indexOfRow < numberOfFitParameters; indexOfRow++) {

		theSum      = 0.;
		k           = 0;
		while (k    < indexOfRow) {
			theSum += choleskyMatrix[indexOfRow][k] * intermediateArray[k];
			k++;
		}

		intermediateArray[indexOfRow] = (projectedObservations[indexOfRow] - theSum) / choleskyMatrix[indexOfRow][indexOfRow];
	}

	const int lastIndex = numberOfFitParameters - 1;

	for (int indexOfRow = lastIndex; indexOfRow >= 0; indexOfRow--) {
		theSum      = 0.;
		k           = lastIndex;
		while (k    > indexOfRow) {
			theSum += choleskyMatrix[k][indexOfRow] * fitCoefficients[k];
			k--;
		}
		fitCoefficients[indexOfRow] = (intermediateArray[indexOfRow] - theSum) / choleskyMatrix[indexOfRow][indexOfRow];
	}
}

/**
 * Check for badly conditionned curvature matrix
 */
void LinearAlgebraicSystemSolver::isMatrixBadlyConditionned(const double diagonalElement,double& minimumOfDiagonal,double& maximumOfDiagonal) {

	if(minimumOfDiagonal  > diagonalElement) {
		minimumOfDiagonal = diagonalElement;
	}
	if(maximumOfDiagonal  < diagonalElement) {
		maximumOfDiagonal = diagonalElement;
	}

	/* This is only an estimate of the condition number */
	const double ratioOfExtrema = minimumOfDiagonal / maximumOfDiagonal;

	if(ratioOfExtrema < RATIO_DIAGONAL_EXTRAMUM_LIMIT) {
		/* The matrix is badly scaled : we consider it as singular */
		computationDiverges = true;
	}
}

/**
 * Get the flag for insufficient memory
 */
bool LinearAlgebraicSystemSolver::isIsMemoryInsufficient() const {
	return isMemoryInsufficient;
}

/**
 * Get the flag for divergent computations
 */
bool LinearAlgebraicSystemSolver::getComputationDiverges() const {

	return computationDiverges;
}

/**
 * Get the fit coefficients
 */
const double* const LinearAlgebraicSystemSolver::getFitCoefficients() const {
	return fitCoefficients;
}
