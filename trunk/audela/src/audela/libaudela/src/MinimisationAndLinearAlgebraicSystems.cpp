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
		const int inputNumberOfFitParameters, const int inputMaximumNumberOfMeasurements) throw (InsufficientMemoryException) :
		theLinearAlgebraicSystem(inputLinearAlgebraicSystem), numberOfFitParameters(inputNumberOfFitParameters),
		maximumNumberOfMeasurements(inputMaximumNumberOfMeasurements) {

	numberOfMeasurements = -1;

	weightedDesignMatrix     = new double*[numberOfFitParameters];
	if(weightedDesignMatrix == NULL) {
		sprintf(logMessage,"Error when allocating memory of %d (double*) for weightedDesignMatrix\n",numberOfFitParameters);
		throw InsufficientMemoryException(logMessage);
	}

	curvatureMatrix          = new double*[numberOfFitParameters];
	if(curvatureMatrix      == NULL) {
		sprintf(logMessage,"Error when allocating memory of %d (double*) for curvatureMatrix\n",numberOfFitParameters);
		throw InsufficientMemoryException(logMessage);
	}

	choleskyMatrix           = new double*[numberOfFitParameters];
	if(choleskyMatrix       == NULL) {
		sprintf(logMessage,"Error when allocating memory of %d (double*) for choleskyMatrix\n",numberOfFitParameters);
		throw InsufficientMemoryException(logMessage);
	}

	for(int kParameter = 0; kParameter < numberOfFitParameters; kParameter++) {

		weightedDesignMatrix[kParameter]     = new double[maximumNumberOfMeasurements];
		if(weightedDesignMatrix[kParameter] == NULL) {
			sprintf(logMessage,"Error when allocating memory of %d (double) for choleskyMatrix[%d]\n",maximumNumberOfMeasurements,kParameter);
			throw InsufficientMemoryException(logMessage);
		}

		curvatureMatrix[kParameter]          = new double[numberOfFitParameters];
		if(curvatureMatrix[kParameter]      == NULL) {
			sprintf(logMessage,"Error when allocating memory of %d (double) for curvatureMatrix[%d]\n",numberOfFitParameters,kParameter);
			throw InsufficientMemoryException(logMessage);
		}

		choleskyMatrix[kParameter]           = new double[numberOfFitParameters];
		if(choleskyMatrix[kParameter]       == NULL) {
			sprintf(logMessage,"Error when allocating memory of %d (double) for choleskyMatrix[%d]\n",numberOfFitParameters,kParameter);
			throw InsufficientMemoryException(logMessage);
		}
	}

	weightedObservations      = new double[maximumNumberOfMeasurements];
	if(weightedObservations  == NULL) {
		sprintf(logMessage,"Error when allocating memory of %d (double) for weightedObservations\n",maximumNumberOfMeasurements);
		throw InsufficientMemoryException(logMessage);
	}

	projectedObservations     = new double[numberOfFitParameters];
	if(projectedObservations == NULL) {
		sprintf(logMessage,"Error when allocating memory of %d (double) for projectedObservations\n",numberOfFitParameters);
		throw InsufficientMemoryException(logMessage);
	}

	intermediateArray         = new double[numberOfFitParameters];
	if(intermediateArray     == NULL) {
		sprintf(logMessage,"Error when allocating memory of %d (double) for intermediateArray\n",numberOfFitParameters);
		throw InsufficientMemoryException(logMessage);
	}

	fitCoefficients           = new double[numberOfFitParameters];
	if(fitCoefficients       == NULL) {
		sprintf(logMessage,"Error when allocating memory of %d (double) for fitCoefficients\n",numberOfFitParameters);
		throw InsufficientMemoryException(logMessage);
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
void LinearAlgebraicSystemSolver::solveSytem() throw (BadlyConditionnedMatrixException,NonDefinitePositiveMatrixException) {

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
void LinearAlgebraicSystemSolver::decomposeCurvatureMatrix() throw (BadlyConditionnedMatrixException,NonDefinitePositiveMatrixException) {

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

		} else {
			sprintf(logMessage,"The curvature matrix is not definite positive\n");
			throw NonDefinitePositiveMatrixException(logMessage);
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
void LinearAlgebraicSystemSolver::isMatrixBadlyConditionned(const double diagonalElement,double& minimumOfDiagonal,double& maximumOfDiagonal)
throw (BadlyConditionnedMatrixException) {

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
		sprintf(logMessage,"The ratio of diagonal elements = %f : the curvature matrix is badly conditionned\n",ratioOfExtrema);
		throw BadlyConditionnedMatrixException(logMessage);
	}
}

/**
 * Get the fit coefficients
 */
const double* const LinearAlgebraicSystemSolver::getFitCoefficients() const {
	return fitCoefficients;
}
