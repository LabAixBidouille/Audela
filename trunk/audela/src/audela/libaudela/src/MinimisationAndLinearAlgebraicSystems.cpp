/**
 * Source file for Levenberg-Marquardt minimisation and linear algebraic systems
 *
 * Author : Yassine Damerdji
 */

#include "MinimisationAndLinearAlgebraicSystems.h"

/**
 * Class constructor
 */
AlgebraicSystemSolver::AlgebraicSystemSolver(const int inputNumberOfFitParameters, const int inputMaximumNumberOfMeasurements) throw (InsufficientMemoryException) :
numberOfFitParameters(inputNumberOfFitParameters),maximumNumberOfMeasurements(inputMaximumNumberOfMeasurements) {

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

	arrayOfParameters           = new double[numberOfFitParameters];
	if(arrayOfParameters       == NULL) {
		sprintf(logMessage,"Error when allocating memory of %d (double) for fitCoefficients\n",numberOfFitParameters);
		throw InsufficientMemoryException(logMessage);
	}
}

/**
 * Class destructor
 */
AlgebraicSystemSolver::~AlgebraicSystemSolver() {

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

	if(projectedObservations != NULL) {
		delete[] projectedObservations;
		projectedObservations = NULL;
	}

	if(intermediateArray != NULL) {
		delete[] intermediateArray;
		intermediateArray = NULL;
	}

	if(arrayOfParameters   != NULL) {
		delete[] arrayOfParameters;
		arrayOfParameters   = NULL;
	}
}

/**
 *  Compute the curvature matrix = transpose(weightedDesignMatrix) * weightedDesignMatrix
 */
void AlgebraicSystemSolver::computeCurvatureMatrix() {

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

			//printf("curvatureMatrix[%d][%d] = %f\n",kParameter1,kParameter2,curvatureMatrix[kParameter1][kParameter2]);
		}
	}
}

/**
 * Decompose the curvature matrix using Cholesky decomposition
 */
void AlgebraicSystemSolver::decomposeCurvatureMatrix(double** theCurvatureMatrix) throw (BadlyConditionnedMatrixException,NonDefinitePositiveMatrixException) {

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

			choleskyMatrix[kParameter][j] = (theCurvatureMatrix[kParameter][j] - theSum) / choleskyMatrix[j][j];
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
void AlgebraicSystemSolver::finishSolvingTheSystem(double* const theFitCoefficients) {

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
			theSum += choleskyMatrix[k][indexOfRow] * theFitCoefficients[k];
			k--;
		}
		theFitCoefficients[indexOfRow] = (intermediateArray[indexOfRow] - theSum) / choleskyMatrix[indexOfRow][indexOfRow];
	}
}

/**
 * Check for badly conditionned curvature matrix
 */
void AlgebraicSystemSolver::isMatrixBadlyConditionned(const double diagonalElement,double& minimumOfDiagonal,double& maximumOfDiagonal)
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
const double* const AlgebraicSystemSolver::getArrayOfParameters() const {
	return arrayOfParameters;
}

/**
 * Class constructor
 */
LinearAlgebraicSystemSolver::LinearAlgebraicSystemSolver(LinearAlgebraicSystemInterface* const inputLinearAlgebraicSystem,
		const int inputNumberOfFitParameters, const int inputMaximumNumberOfMeasurements) throw (InsufficientMemoryException) :
																										AlgebraicSystemSolver(inputNumberOfFitParameters,inputMaximumNumberOfMeasurements), theLinearAlgebraicSystem(inputLinearAlgebraicSystem) {

	weightedObservations      = new double[maximumNumberOfMeasurements];
	if(weightedObservations  == NULL) {
		sprintf(logMessage,"Error when allocating memory of %d (double) for weightedObservations\n",maximumNumberOfMeasurements);
		throw InsufficientMemoryException(logMessage);
	}
}

/**
 * Class destructor
 */
LinearAlgebraicSystemSolver::~LinearAlgebraicSystemSolver() {

	if(weightedObservations != NULL) {
		delete[] weightedObservations;
		weightedObservations = NULL;
	}
}

/**
 * Solve the algebraic system
 */
void LinearAlgebraicSystemSolver::solveSytem() throw (BadlyConditionnedMatrixException,NonDefinitePositiveMatrixException) {

	/* Retrieve the number of measurements */
	numberOfMeasurements = theLinearAlgebraicSystem->getNumberOfMeasurements();

	/* Fill the design matrix */
	theLinearAlgebraicSystem->fillWeightedDesignMatrix(weightedDesignMatrix);

	/* Fill the weighted observations */
	theLinearAlgebraicSystem->fillWeightedObservations(weightedObservations);

	/* Compute the curvature matrix = transpose(weightedDesignMatrix) * weightedDesignMatrix */
	computeCurvatureMatrix();

	/* Decompose the curvature matrix by the Cholesky decomposition */
	decomposeCurvatureMatrix(curvatureMatrix);

	/* Compute projectObservations = transpose(weightedDesignMatrix) * weightedObservations */
	computeProjectedObservations();

	/* Solve the system */
	finishSolvingTheSystem(arrayOfParameters);
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
 * Class constructor
 */
LevenbergMarquardtSystemSolver::LevenbergMarquardtSystemSolver(NonLinearAlgebraicSystemInterface* const inputNonLinearAlgebraicSystem,
		const int inputNumberOfFitParameters, const int inputMaximumNumberOfMeasurements) throw (InsufficientMemoryException) :
																										AlgebraicSystemSolver(inputNumberOfFitParameters,inputMaximumNumberOfMeasurements), theNonLinearAlgebraicSystem(inputNonLinearAlgebraicSystem) {

	hessianMatrix          = new double*[numberOfFitParameters];
	if(hessianMatrix      == NULL) {
		sprintf(logMessage,"Error when allocating memory of %d (double*) for hessianMatrix\n",numberOfFitParameters);
		throw InsufficientMemoryException(logMessage);
	}

	for(int kParameter = 0; kParameter < numberOfFitParameters; kParameter++) {

		hessianMatrix[kParameter]          = new double[numberOfFitParameters];
		if(hessianMatrix[kParameter]      == NULL) {
			sprintf(logMessage,"Error when allocating memory of %d (double) for hessianMatrix[%d]\n",numberOfFitParameters,kParameter);
			throw InsufficientMemoryException(logMessage);
		}
	}

	weightedDeltaObservations      = new double[maximumNumberOfMeasurements];
	if(weightedDeltaObservations  == NULL) {
		sprintf(logMessage,"Error when allocating memory of %d (double) for weightedDeltaObservations\n",maximumNumberOfMeasurements);
		throw InsufficientMemoryException(logMessage);
	}

	temporaryWeightedDeltaObservations      = new double[maximumNumberOfMeasurements];
	if(temporaryWeightedDeltaObservations  == NULL) {
		sprintf(logMessage,"Error when allocating memory of %d (double) for temporaryWeightedDeltaObservations\n",maximumNumberOfMeasurements);
		throw InsufficientMemoryException(logMessage);
	}

	temporaryArrayOfParameters      = new double[numberOfFitParameters];
	if(temporaryArrayOfParameters  == NULL) {
		sprintf(logMessage,"Error when allocating memory of %d (double) for temporaryFitCoefficients\n",numberOfFitParameters);
		throw InsufficientMemoryException(logMessage);
	}

	marquardtLambda    = NAN;
	recomputeMatrix    = false;
	convergenceCounter = -1;
	chiSquare          = NAN;
}

/**
 * Class destructor
 */
LevenbergMarquardtSystemSolver::~LevenbergMarquardtSystemSolver() {

	if(weightedDeltaObservations != NULL) {
		delete[] weightedDeltaObservations;
		weightedDeltaObservations = NULL;
	}

	if(temporaryWeightedDeltaObservations != NULL) {
		delete[] temporaryWeightedDeltaObservations;
		temporaryWeightedDeltaObservations = NULL;
	}

	if(temporaryArrayOfParameters != NULL) {
		delete[] temporaryArrayOfParameters;
		temporaryArrayOfParameters = NULL;
	}

	for(int kParameter = 0; kParameter < numberOfFitParameters; kParameter++) {

		if(hessianMatrix[kParameter]      != NULL) {
			delete[] hessianMatrix[kParameter];
			hessianMatrix[kParameter] = NULL;
		}
	}

	if(hessianMatrix != NULL) {
		delete[] hessianMatrix;
		hessianMatrix = NULL;
	}
}

/**
 * Perform the Levenberg-Marquardt minimisation
 */
bool LevenbergMarquardtSystemSolver::optimise() {

	/* Fill arrayOfNumberOfMeasurements */
	numberOfMeasurements = theNonLinearAlgebraicSystem->getNumberOfMeasurements();

	/* Fill the array of parameters */
	theNonLinearAlgebraicSystem->fillArrayOfParameters(arrayOfParameters);

	/* Compute the weighted delta observations */
	theNonLinearAlgebraicSystem->fillWeightedDeltaObservations(weightedDeltaObservations,arrayOfParameters);

	/* Compute the chiSquare */
	chiSquare = computeChiSqure(weightedDeltaObservations);

	int iterationCounter = 0;
	convergenceCounter   = 0;
	marquardtLambda      = 0.001;
	recomputeMatrix      = true;
	double newChiSquare;
	double deltaChisquare;

	while ((iterationCounter < MAXIMUM_NUMBER_OF_ITERATIONS) && (convergenceCounter < NUMBER_OF_NEEDED_CONVERGENCE)) {

		// Compute the matrix of derivative and fill the projected velocities
		prepareAlgebraicSystem();

		// Copy initialCurvatureMatrix in modifiedCurvatureMatrix and add the constant to diagonal
		copyCurvatureMatrix();

		// Decompose hessianMatrix by a Cholesky decomposition
		try {
			decomposeCurvatureMatrix(hessianMatrix);

			// Find the delta parameters
			computeDeltaParameters();

			// Check the new parameters
			theNonLinearAlgebraicSystem->checkArrayOfParameters(temporaryArrayOfParameters);

			/* Compute the weighted delta observations */
			theNonLinearAlgebraicSystem->fillWeightedDeltaObservations(temporaryWeightedDeltaObservations,temporaryArrayOfParameters);

			/* Compute the chiSquare */
			newChiSquare   = computeChiSqure(temporaryWeightedDeltaObservations);

			deltaChisquare  = newChiSquare - chiSquare;
			if ((fabs(deltaChisquare) < DELTA_CHI_SQUARE_LIMIT) || (fabs(deltaChisquare) < chiSquare * CHI_SQUARE_TOLERENCE)) {
				convergenceCounter++;
			}

			if (deltaChisquare    < 0.) {

				// Accept the new solution
				chiSquare         = newChiSquare;
				marquardtLambda  /= MARQUARDT_SCALE;
				recomputeMatrix   = true;
				swapSolutionParameters();

			} else {

				badStep();
			}


		} catch (BadlyConditionnedMatrixException& theException) {

			badStep();

		} catch (NonDefinitePositiveMatrixException& theException) {

			badStep();

		} catch (InvalidDataException& theException) {

			badStep();
		}

		iterationCounter++;
	}

	return iterationCounter != MAXIMUM_NUMBER_OF_ITERATIONS;
}

/**
 * In the case of new computation of the matrix of derivatives,
 * we recompute weightedDeltaVelocities and the curvatureMatrix
 */
void LevenbergMarquardtSystemSolver::prepareAlgebraicSystem() {

	if(recomputeMatrix) {

		/* Ask the model to fill the matrix of derivatives */
		theNonLinearAlgebraicSystem->fillWeightedDesignMatrix(weightedDesignMatrix,arrayOfParameters);

		/* Fill the curvature matrix */
		computeCurvatureMatrix();

		/* Fill projectedVelocities */
		computeProjectedObservations();
	}
}

/**
 * Swap the solution parameters
 */
void LevenbergMarquardtSystemSolver::swapSolutionParameters() {

	double* temporaryAdress    = arrayOfParameters;
	arrayOfParameters          = temporaryArrayOfParameters;
	temporaryArrayOfParameters = temporaryAdress;

	temporaryAdress                    = weightedDeltaObservations;
	weightedDeltaObservations          = temporaryWeightedDeltaObservations;
	temporaryWeightedDeltaObservations = temporaryAdress;
}

/**
 * Copy initialCurvatureMatrix in modifiedCurvatureMatrix and add the constant to diagonal
 */
void LevenbergMarquardtSystemSolver::copyCurvatureMatrix() {

	const double onePlusLambda  = 1 + marquardtLambda;

	for(int kParameter1 = 0; kParameter1 < numberOfFitParameters; kParameter1++) {

		hessianMatrix[kParameter1][kParameter1] = onePlusLambda * curvatureMatrix[kParameter1][kParameter1];

		for(int kParameter2 = kParameter1; kParameter2 < numberOfFitParameters; kParameter2++) {

			hessianMatrix[kParameter1][kParameter2] = curvatureMatrix[kParameter1][kParameter2];
			hessianMatrix[kParameter2][kParameter1] = curvatureMatrix[kParameter1][kParameter2];
		}
	}
}

/**
 * Compute projectObservations = transpose(weightedDesignMatrix) * weightedObservations
 */
void LevenbergMarquardtSystemSolver::computeProjectedObservations() {

	double theSum;

	for(int kParameter = 0; kParameter < numberOfFitParameters; kParameter++) {

		theSum       = 0.;
		for(int kMes = 0; kMes < numberOfMeasurements; kMes++) {
			theSum  += weightedDesignMatrix[kParameter][kMes] * weightedDeltaObservations[kMes];
		}

		projectedObservations[kParameter] = theSum;
	}
}

/**
 * Compute the chiSquare of a given iteration
 */
double LevenbergMarquardtSystemSolver::computeChiSqure(double* const theWeightedDeltaObservations) {

	double theChiSquare = 0.;

	for (int kMes = 0; kMes < numberOfMeasurements; kMes++) {
		theChiSquare   += theWeightedDeltaObservations[kMes] * theWeightedDeltaObservations[kMes];
	}

	return theChiSquare;
}

/**
 * Change variables when for a bad step
 */
void LevenbergMarquardtSystemSolver::badStep() {

	marquardtLambda *= MARQUARDT_SCALE;
	recomputeMatrix  = false;
}

/**
 * Find the delta parameters
 */
void LevenbergMarquardtSystemSolver::computeDeltaParameters() {

	double theSum;
	int k;

	// Fill intermediateSolution
	for (int indexOfRow = 0; indexOfRow < numberOfFitParameters; indexOfRow++) {

		theSum     = 0.;
		k          = 1;
		while (k   < indexOfRow) {
			theSum += choleskyMatrix[indexOfRow][k] * intermediateArray[k];
			k      = k + 1;
		}

		intermediateArray[indexOfRow] = (projectedObservations[indexOfRow] - theSum) / choleskyMatrix[indexOfRow][indexOfRow];
	}

	// Compute the fit coeffcients
	for (int indexOfRow = numberOfFitParameters; indexOfRow >= 0; indexOfRow--) {

		theSum     = 0.;
		k          = numberOfFitParameters - 1;
		while (k   > indexOfRow) {
			theSum    += choleskyMatrix[k][indexOfRow] * temporaryArrayOfParameters[k];
			k--;
		}
		temporaryArrayOfParameters[indexOfRow] = (intermediateArray[indexOfRow] - theSum) / choleskyMatrix[indexOfRow][indexOfRow];
	}

	// We find the delta fit paramters, so we add the fitCoefficients to have the complete parameters
	for (int indexOfRow = 0; indexOfRow < numberOfFitParameters; indexOfRow++) {
		temporaryArrayOfParameters[indexOfRow] += arrayOfParameters[indexOfRow];
	}
}

/**
 * Get the chiSquare of the fit
 */
const double LevenbergMarquardtSystemSolver::getChiSquare() const {
	return chiSquare;
}
