/**
 * Code file for profile fitting methods
 *
 * Author : Yassine Damerdji
 */
#include "PsfFitter.h"

/**
 * Class constructor
 */
PsfFitter::PsfFitter(const int inputNumberOfParameterFit,const int inputNumberOfParameterFitPreliminarySolution) :
numberOfParameterFit(inputNumberOfParameterFit), numberOfParameterFitPreliminarySolution(inputNumberOfParameterFitPreliminarySolution) {

	xPixelsMaximumRadius              = NULL;
	yPixelsMaximumRadius              = NULL;
	fluxesMaximumRadius               = NULL;
	fluxErrorsMaximumRadius           = NULL;
	isUsedFlags                       = NULL;
	xPixels                           = NULL;
	yPixels                           = NULL;
	fluxes                            = NULL;
	fluxErrors                        = NULL;
	transformedFluxes                 = NULL;
	transformedFluxErrors             = NULL;
	numberOfPixelsMaximumRadius       = 0;
	numberOfPixelsOneRadius           = 0;
	bestRadius                        = -1;
	theLinearAlgebraicSystemSolver    = NULL;
	theLevenbergMarquardtSystemSolver = NULL;
}

/**
 * Class destructor
 */
PsfFitter::~PsfFitter() {

	if(xPixels != NULL) {
		delete[] xPixels;
		xPixels = NULL;
	}

	if(yPixels != NULL) {
		delete[] yPixels;
		yPixels = NULL;
	}

	if(fluxes != NULL) {
		delete[] fluxes;
		fluxes = NULL;
	}

	if(transformedFluxes != NULL) {
		delete[] transformedFluxes;
		transformedFluxes = NULL;
	}

	if(fluxErrors != NULL) {
		delete[] fluxErrors;
		fluxErrors = NULL;
	}

	if(transformedFluxErrors != NULL) {
		delete[] transformedFluxErrors;
		transformedFluxErrors = NULL;
	}

	if(xPixelsMaximumRadius != NULL) {
		delete[] xPixelsMaximumRadius;
		xPixelsMaximumRadius = NULL;
	}

	if(yPixelsMaximumRadius != NULL) {
		delete[] yPixelsMaximumRadius;
		yPixelsMaximumRadius = NULL;
	}

	if(fluxesMaximumRadius != NULL) {
		delete[] fluxesMaximumRadius;
		fluxesMaximumRadius = NULL;
	}

	if(fluxErrorsMaximumRadius != NULL) {
		delete[] fluxErrorsMaximumRadius;
		fluxErrorsMaximumRadius = NULL;
	}

	if(isUsedFlags != NULL) {
		delete[] isUsedFlags;
		isUsedFlags = NULL;
	}

	if(theLinearAlgebraicSystemSolver != NULL) {
		delete theLinearAlgebraicSystemSolver;
		theLinearAlgebraicSystemSolver = NULL;
	}

	if(theLevenbergMarquardtSystemSolver != NULL) {
		delete theLevenbergMarquardtSystemSolver;
		theLevenbergMarquardtSystemSolver = NULL;
	}

	numberOfPixelsMaximumRadius = 0;
	numberOfPixelsOneRadius     = 0;
}

/**
 * Loop over radii to find the best fit
 */
void PsfFitter::fitProfile(CBuffer* const theBufferImage, const int xCenter, const int yCenter, const int minimumRadius, const int maximumRadius,
		const double saturationLimit, const double readOutNoise) throw (InsufficientMemoryException) {

	numberOfPixelsOneRadius         = 0;
	int bestNumberOfPixelsOneRadius = -1;
	double bestReducedChiSquare     = 1e100;
	bestRadius                      = -1;
	double unReducedChiSquare       = NAN;
	double reducedChiSquare;

	/* Extract the processing zone for the maximum radius */
	extractProcessingZoneMaximumRadius(theBufferImage, xCenter, yCenter, maximumRadius, saturationLimit, readOutNoise);

	theLinearAlgebraicSystemSolver    = new LinearAlgebraicSystemSolver(this,numberOfParameterFitPreliminarySolution,numberOfPixelsMaximumRadius);
	theLevenbergMarquardtSystemSolver = new LevenbergMarquardtSystemSolver(this,numberOfParameterFit,numberOfPixelsMaximumRadius);

	for(int theRadius = minimumRadius; theRadius <= maximumRadius; theRadius++) {

		/* Extract pixels needed for the fit */
		extractProcessingZone(theRadius);

		try {
			/* Fit the profile*/
			unReducedChiSquare     = fitProfilePerRadius();
			reducedChiSquare       = reduceChiSquare(unReducedChiSquare);

		} catch (ErrorException& theException) {
			printf("Exception for radius = %d : %s\n",theRadius,theException.getTheMessage());
			continue;
		}

		if(bestReducedChiSquare         > reducedChiSquare) {
			bestReducedChiSquare        = reducedChiSquare;
			bestRadius                  = theRadius;
			bestNumberOfPixelsOneRadius = numberOfPixelsOneRadius;
			copyParamtersInTheFinalSolution(theLevenbergMarquardtSystemSolver->getArrayOfParameters());
		}
	}

	/* Compute error for the best solution */
	numberOfPixelsOneRadius             = bestNumberOfPixelsOneRadius;
	setTheBestSolution();
	theLevenbergMarquardtSystemSolver->computeErrors();
	setErrorsInThefinalSolution(theLevenbergMarquardtSystemSolver->getArrayOfParameterErrors());
}

/**
 * Extract pixels needed for the fit
 */
void PsfFitter::extractProcessingZoneMaximumRadius(CBuffer* const theBufferImage, const int xCenter, const int yCenter, const int theRadius,
		const double saturationLimit, const double readOutNoise) throw (InsufficientMemoryException) {

	const int naxis1 = theBufferImage->GetWidth();
	const int naxis2 = theBufferImage->GetHeight();

	// Starts buy taking the rectangle
	int xPixelStart  = xCenter - theRadius;
	if (xPixelStart  < 0) {
		xPixelStart  = 0;
	}

	int xPixelEnd    = xCenter + theRadius;
	if (xPixelEnd   >= naxis1) {
		xPixelEnd    = naxis1 -1;
	}

	int yPixelStart  = yCenter - theRadius;
	if (yPixelStart  < 0) {
		yPixelStart  = 0;
	}

	int yPixelEnd    = yCenter + theRadius;
	if (yPixelEnd   >= naxis2) {
		yPixelEnd    = naxis2 - 1;
	}

	const int numberOfColumns   = xPixelEnd - xPixelStart + 1;
	const int numberOfRows      = yPixelEnd - yPixelStart + 1;
	numberOfPixelsMaximumRadius = numberOfRows * numberOfColumns;

	// Get the sub image
	TYPE_PIXELS* allPixels      = new TYPE_PIXELS[numberOfPixelsMaximumRadius];
	if(allPixels               == NULL) {
		sprintf(logMessage,"Error when allocating memory of %d (TYPE_PIXELS) for allPixels\n",numberOfPixelsMaximumRadius);
		throw InsufficientMemoryException(logMessage);
	}

	theBufferImage->GetPixels(xPixelStart, yPixelStart, xPixelEnd, yPixelEnd, FORMAT_FLOAT, PLANE_GREY, allPixels);

	// For the maximum radius, we select the rectangle instead of the circle
	xPixelsMaximumRadius        = new int[numberOfPixelsMaximumRadius];
	if(xPixelsMaximumRadius    == NULL) {
		delete[] allPixels;
		sprintf(logMessage,"Error when allocating memory of %d (double) for xPixelsMaximumRadius\n",numberOfPixelsMaximumRadius);
		throw InsufficientMemoryException(logMessage);
	}
	xPixels                     = new int[numberOfPixelsMaximumRadius];
	if(xPixels                 == NULL) {
		delete[] allPixels;
		delete[] xPixelsMaximumRadius;
		sprintf(logMessage,"Error when allocating memory of %d (double) for xPixels\n",numberOfPixelsMaximumRadius);
		throw InsufficientMemoryException(logMessage);
	}

	yPixelsMaximumRadius        = new int[numberOfPixelsMaximumRadius];
	if(yPixelsMaximumRadius    == NULL) {
		delete[] allPixels;
		delete[] xPixelsMaximumRadius;
		delete[] xPixels;
		sprintf(logMessage,"Error when allocating memory of %d (double) for yPixelsMaximumRadius\n",numberOfPixelsMaximumRadius);
		throw InsufficientMemoryException(logMessage);
	}
	yPixels                     = new int[numberOfPixelsMaximumRadius];
	if(yPixels                 == NULL) {
		delete[] allPixels;
		delete[] xPixelsMaximumRadius;
		delete[] xPixels;
		delete[] yPixelsMaximumRadius;
		sprintf(logMessage,"Error when allocating memory of %d (double) for yPixels\n",numberOfPixelsMaximumRadius);
		throw InsufficientMemoryException(logMessage);
	}

	fluxesMaximumRadius         = new double[numberOfPixelsMaximumRadius];
	if(fluxesMaximumRadius     == NULL) {
		delete[] allPixels;
		delete[] xPixelsMaximumRadius;
		delete[] xPixels;
		delete[] yPixelsMaximumRadius;
		delete[] yPixels;
		sprintf(logMessage,"Error when allocating memory of %d (double) for fluxesMaximumRadius\n",numberOfPixelsMaximumRadius);
		throw InsufficientMemoryException(logMessage);
	}
	fluxes                      = new double[numberOfPixelsMaximumRadius];
	if(fluxes                  == NULL) {
		delete[] allPixels;
		delete[] xPixelsMaximumRadius;
		delete[] xPixels;
		delete[] yPixelsMaximumRadius;
		delete[] yPixels;
		delete[] fluxesMaximumRadius;
		sprintf(logMessage,"Error when allocating memory of %d (double) for fluxes\n",numberOfPixelsMaximumRadius);
		throw InsufficientMemoryException(logMessage);
	}
	transformedFluxes           = new double[numberOfPixelsMaximumRadius];
	if(transformedFluxes       == NULL) {
		delete[] allPixels;
		delete[] xPixelsMaximumRadius;
		delete[] xPixels;
		delete[] yPixelsMaximumRadius;
		delete[] yPixels;
		delete[] fluxesMaximumRadius;
		delete[] fluxes;
		sprintf(logMessage,"Error when allocating memory of %d (double) for transformedFluxes\n",numberOfPixelsMaximumRadius);
		throw InsufficientMemoryException(logMessage);
	}

	fluxErrorsMaximumRadius     = new double[numberOfPixelsMaximumRadius];
	if(fluxErrorsMaximumRadius == NULL) {
		delete[] allPixels;
		delete[] xPixelsMaximumRadius;
		delete[] xPixels;
		delete[] yPixelsMaximumRadius;
		delete[] yPixels;
		delete[] fluxesMaximumRadius;
		delete[] fluxes;
		delete[] transformedFluxes;
		sprintf(logMessage,"Error when allocating memory of %d (double) for fluxErrorsMaximumRadius\n",numberOfPixelsMaximumRadius);
		throw InsufficientMemoryException(logMessage);
	}
	fluxErrors                  = new double[numberOfPixelsMaximumRadius];
	if(fluxErrors              == NULL) {
		delete[] allPixels;
		delete[] xPixelsMaximumRadius;
		delete[] xPixels;
		delete[] yPixelsMaximumRadius;
		delete[] yPixels;
		delete[] fluxesMaximumRadius;
		delete[] fluxes;
		delete[] transformedFluxes;
		delete[] fluxErrorsMaximumRadius;
		sprintf(logMessage,"Error when allocating memory of %d (double) for fluxErrors\n",numberOfPixelsMaximumRadius);
		throw InsufficientMemoryException(logMessage);
	}
	transformedFluxErrors       = new double[numberOfPixelsMaximumRadius];
	if(transformedFluxErrors   == NULL) {
		delete[] allPixels;
		delete[] xPixelsMaximumRadius;
		delete[] xPixels;
		delete[] yPixelsMaximumRadius;
		delete[] yPixels;
		delete[] fluxesMaximumRadius;
		delete[] fluxes;
		delete[] transformedFluxes;
		delete[] fluxErrorsMaximumRadius;
		delete[] fluxErrors;
		sprintf(logMessage,"Error when allocating memory of %d (double) for transformedFluxErrors\n",numberOfPixelsMaximumRadius);
		throw InsufficientMemoryException(logMessage);
	}

	isUsedFlags     = new bool[numberOfPixelsMaximumRadius];
	if(isUsedFlags == NULL) {
		delete[] allPixels;
		delete[] xPixelsMaximumRadius;
		delete[] xPixels;
		delete[] yPixelsMaximumRadius;
		delete[] yPixels;
		delete[] fluxesMaximumRadius;
		delete[] fluxes;
		delete[] transformedFluxes;
		delete[] fluxErrorsMaximumRadius;
		delete[] fluxErrors;
		delete[] transformedFluxErrors;
		sprintf(logMessage,"Error when allocating memory of %d (double) for isUsedFlags\n",numberOfPixelsMaximumRadius);
		throw InsufficientMemoryException(logMessage);
	}

	// Fill arrays
	const double squareReadOutNoise = readOutNoise * readOutNoise;
	int componentNumber;
	int counter                     = 0;

	for (int xPixel = xPixelStart; xPixel <= xPixelEnd; xPixel++) {
		for (int yPixel = yPixelStart; yPixel <= yPixelEnd; yPixel++) {

			xPixelsMaximumRadius[counter]        = xPixel - xCenter;
			yPixelsMaximumRadius[counter]        = yPixel - yCenter;
			componentNumber                      = numberOfColumns * (yPixel - yPixelStart) + xPixel - xPixelStart;
			fluxesMaximumRadius[counter]         = (double)(allPixels[componentNumber]);
			if(fluxesMaximumRadius[counter]     >= saturationLimit) {
				fluxErrorsMaximumRadius[counter] = 1e100;
			} else {
				fluxErrorsMaximumRadius[counter] = sqrt(fluxesMaximumRadius[counter] + squareReadOutNoise); // Photon noise + read out noise
			}
			isUsedFlags[counter]                 = false;

			counter++;
		}
	}

	delete[] allPixels;
}

/**
 * Extract pixels needed for the fit
 */
void PsfFitter::extractProcessingZone(const int theRadius) {

	double distance;
	const double squareRadius = theRadius * theRadius;

	// We do not need to reset arrays, since we processing radii in ascending orders
	for (int pixel = 0; pixel < numberOfPixelsMaximumRadius; pixel++) {

		if(!isUsedFlags[pixel]) {

			distance                                 = xPixelsMaximumRadius[pixel] * xPixelsMaximumRadius[pixel] +
					yPixelsMaximumRadius[pixel] * yPixelsMaximumRadius[pixel];
			if(distance                              < squareRadius) {
				isUsedFlags[pixel]                   = true;
				xPixels[numberOfPixelsOneRadius]     = xPixelsMaximumRadius[pixel];
				yPixels[numberOfPixelsOneRadius]     = yPixelsMaximumRadius[pixel];
				fluxes[numberOfPixelsOneRadius]      = fluxesMaximumRadius[pixel];
				fluxErrors[numberOfPixelsOneRadius]  = fluxErrorsMaximumRadius[pixel];
				numberOfPixelsOneRadius++;
			}
		}
	}
}

/**
 * Fit a PSF for a given pixel radius
 */
double PsfFitter::fitProfilePerRadius() {

	/* Find the initial solution */
	findInitialSolution();

	/* Refine the initial solution */
	const double unNormalisedChiSquare = refineSolution();

	return unNormalisedChiSquare;
}

/**
 * Find the PSF preliminary solution
 */
void PsfFitter::findInitialSolution() {

	const double minimumOfFluxes     = findMinimumOfFluxes();

	// The background flux
	deduceInitialBackgroundFlux(minimumOfFluxes);

	/* Transform fluxes for computing the preliminary solution */
	transformFluxesForPreliminarySolution();

	/* Solve the system to find the preliminary solution */
	theLinearAlgebraicSystemSolver->solveSytem();

	/* Decode the fit coefficients */
	decodeFitCoefficients(theLinearAlgebraicSystemSolver->getArrayOfParameters());
}

/**
 * Find the PSF refined solution
 */
double PsfFitter::refineSolution() {

	// Find the minimum of chiSquare with a Levenberg-Marquardt minimisation
	theLevenbergMarquardtSystemSolver->optimise();

	const double chiSquare = theLevenbergMarquardtSystemSolver->getChiSquare();

	return chiSquare;
}

/**
 * Compute the minimum of fluxes
 */
const double PsfFitter::findMinimumOfFluxes() {

	double minimumOfFluxes = fluxes[0];

	for(int pixel = 1; pixel < numberOfPixelsOneRadius; pixel++) {

		if(minimumOfFluxes  > fluxes[pixel]){
			minimumOfFluxes = fluxes[pixel];
		}
	}

	return minimumOfFluxes;
}

/**
 * Get the number of pixels for a given radius
 */
const int PsfFitter::getNumberOfMeasurements() {
	return numberOfPixelsOneRadius;
}

/**
 * Fill the weighted observations (transformedFluxes / transformedFluxErrors) to find the preliminary solution
 */
void PsfFitter::fillWeightedObservations(double* const weightedObservartions) {

	for(int pixel = 0; pixel < numberOfPixelsOneRadius; pixel++) {

		weightedObservartions[pixel] = transformedFluxes[pixel] / transformedFluxErrors[pixel];
	}
}

/**
 * Class constructor
 */
Gaussian2DPsfFitter::Gaussian2DPsfFitter() : PsfFitter(GAUSSIAN_PROFILE_NUMBER_OF_PARAMETERS,GAUSSIAN_PROFILE_NUMBER_OF_PARAMETERS_PRELIMINARY_SOLUTION) {

	thePsfParameters      = new PsfParameters;
	theFinalPsfParameters = new PsfParameters;
}

/**
 * Class destructor
 */
Gaussian2DPsfFitter::~Gaussian2DPsfFitter() {

	if(thePsfParameters != NULL) {
		delete thePsfParameters;
		thePsfParameters = NULL;
	}

	if(theFinalPsfParameters != NULL) {
		delete theFinalPsfParameters;
		theFinalPsfParameters = NULL;
	}
}

/*
 * Get the PSF parameters
 */
PsfParameters* const Gaussian2DPsfFitter::getThePsfParameters() const {
	return thePsfParameters;
}

/**
 * Deduce the preliminary value of the background flux from the minimum of fluxes
 */
void Gaussian2DPsfFitter::deduceInitialBackgroundFlux(const double minimumOfFluxes) {

	thePsfParameters->setBackGroundFlux(minimumOfFluxes - 1.);
}

/**
 *  Decode the fit coefficients
 */
void Gaussian2DPsfFitter::decodeFitCoefficients(const double* const fitCoefficients) {

	const double coefficientA      = fitCoefficients[0];
	const double coefficientB      = fitCoefficients[1];
	const double coefficientC      = fitCoefficients[2];
	const double coefficientD      = fitCoefficients[3];
	const double coefficientE      = fitCoefficients[4];
	const double coefficientF      = fitCoefficients[5];

	if (coefficientA  == coefficientC) {
		thePsfParameters->setTheta(M_PI / 4);
	} else {
		const double theta          = atan(coefficientB / (coefficientA - coefficientC)) / 2.;
		thePsfParameters->setTheta(theta);
	}

	const double cosTeta            = cos(thePsfParameters->getTheta());
	const double sinTeta            = sin(thePsfParameters->getTheta());
	const double squareCosTeta      = cosTeta * cosTeta;
	const double squareSinTeta      = sinTeta * sinTeta;

	const double coefficientSquareX = coefficientA * squareCosTeta + coefficientB * cosTeta * sinTeta + coefficientC * squareSinTeta;
	const double coefficientSquareY = coefficientA * squareSinTeta - coefficientB * cosTeta * sinTeta + coefficientC * squareCosTeta;
	const double coefficientX       = coefficientD * cosTeta + coefficientE * sinTeta;
	const double coefficientY       = -coefficientD * sinTeta + coefficientE * cosTeta;

	const double x0Tilde            = -coefficientX / coefficientSquareX;
	const double y0Tilde            = -coefficientY / coefficientSquareY;

	const double x0                 = x0Tilde * cosTeta - y0Tilde * sinTeta;
	thePsfParameters->setPhotoCenterX(x0);
	const double y0                 = x0Tilde * sinTeta + y0Tilde * cosTeta;
	thePsfParameters->setPhotoCenterY(y0);

	const double squareSigmaX       = -0.5 / coefficientSquareX;
	if (squareSigmaX                < 0.) {
		// Default value
		thePsfParameters->setSigmaX(1.);
	} else {
		thePsfParameters->setSigmaX(sqrt(squareSigmaX));
	}

	const double squareSigmaY       = -0.5 / coefficientSquareY;
	if (squareSigmaY                < 0.) {
		// Default value
		thePsfParameters->setSigmaY(1.);
	} else {
		thePsfParameters->setSigmaY(sqrt(squareSigmaY));
	}

	double scaleFactor              = coefficientF + x0Tilde * x0Tilde / 2 / squareSigmaX + y0Tilde * y0Tilde / 2 / squareSigmaY;
	scaleFactor                     = exp(scaleFactor);

	thePsfParameters->setScaleFactor(scaleFactor);

	if(DEBUG) {
		printf("GAUSSIAN 2D PSF preliminary solution :\n");
		printf("Background flux  = %.3f\n",thePsfParameters->getBackGroundFlux());
		printf("Scale factor     = %.3f\n",thePsfParameters->getScaleFactor());
		printf("PhotocenterX     = %.3f\n",thePsfParameters->getPhotoCenterX());
		printf("PhotocenterY     = %.3f\n",thePsfParameters->getPhotoCenterY());
		printf("Theta            = %.3f degrees\n",thePsfParameters->getTheta() * 180. / M_PI);
		printf("SigmaX           = %.3f\n",thePsfParameters->getSigmaX());
		printf("SigmaY           = %.3f\n",thePsfParameters->getSigmaY());
	}
}

/**
 * Fill the weighted observations (transformedFluxes / transformedFluxErrors) to find the preliminary solution
 */
void Gaussian2DPsfFitter::fillWeightedDesignMatrix(double* const * const weightedDesignMatrix) {

	for(int pixel = 0; pixel < numberOfPixelsOneRadius; pixel++) {

		/* The constant element term */
		weightedDesignMatrix[5][pixel] = 1. / transformedFluxErrors[pixel];

		/* The xPixel term */
		weightedDesignMatrix[3][pixel] = xPixels[pixel] / transformedFluxErrors[pixel];

		/* The yPixel term */
		weightedDesignMatrix[4][pixel] = yPixels[pixel] / transformedFluxErrors[pixel];

		/* The xPixel^2 term */
		weightedDesignMatrix[0][pixel] = xPixels[pixel] * weightedDesignMatrix[3][pixel];

		/* The xPixel * yPixel term */
		weightedDesignMatrix[1][pixel] = yPixels[pixel] * weightedDesignMatrix[3][pixel];

		/* The yPixel * yPixel term */
		weightedDesignMatrix[2][pixel] = yPixels[pixel] * weightedDesignMatrix[4][pixel];
	}
}

/**
 * Transform fluxes for computing the preliminary solution
 */
void Gaussian2DPsfFitter::transformFluxesForPreliminarySolution() {

	for(int pixel = 0; pixel < numberOfPixelsOneRadius; pixel++) {

		/* We subtract the background flux */
		transformedFluxes[pixel]     = fluxes[pixel] - thePsfParameters->getBackGroundFlux();

		/* The error bars */
		transformedFluxErrors[pixel] = fluxErrors[pixel] / transformedFluxes[pixel];

		/* We take the logarithm of fluxes */
		transformedFluxes[pixel]     = log(transformedFluxes[pixel]);
	}
}

/**
 * Fill the array of parameters for the Levenberg-Marquardt minimisation
 */
void Gaussian2DPsfFitter::fillArrayOfParameters(double* const arrayOfParameters) {

	arrayOfParameters[BACKGROUND_FLUX_INDEX] = thePsfParameters->getBackGroundFlux();
	arrayOfParameters[SCALE_FACTOR_INDEX]    = thePsfParameters->getScaleFactor();
	arrayOfParameters[PHOTOCENTER_X_INDEX]   = thePsfParameters->getPhotoCenterX();
	arrayOfParameters[PHOTOCENTER_Y_INDEX]   = thePsfParameters->getPhotoCenterY();
	arrayOfParameters[THETA_INDEX]           = thePsfParameters->getTheta();
	arrayOfParameters[SIGMA_X_INDEX]         = thePsfParameters->getSigmaX();
	arrayOfParameters[SIGMA_Y_INDEX]         = thePsfParameters->getSigmaY();
}

/**
 * Fill the weighted delta observations (observation - fit) / sigma for the Levenberg-Marquardt minimisation
 */
void Gaussian2DPsfFitter::fillWeightedDeltaObservations(double* const theWeightedDeltaObservartions, double* const arrayOfParameters) {

	const double cosTeta         = cos(arrayOfParameters[THETA_INDEX]);
	const double sinTeta         = sin(arrayOfParameters[THETA_INDEX]);
	const double twoSquareSigmaX = 2 * arrayOfParameters[SIGMA_X_INDEX] * arrayOfParameters[SIGMA_X_INDEX];
	const double twoSquareSigmaY = 2 * arrayOfParameters[SIGMA_Y_INDEX] * arrayOfParameters[SIGMA_Y_INDEX];
	double xPixelCentered;
	double yPixelCentered;
	double xPixelCenteredRotated;
	double yPixelCenteredRotated;
	double theEllipse;
	double fittedFlux;

	for (int kMes = 0; kMes < numberOfPixelsOneRadius; kMes++) {

		xPixelCentered        = xPixels[kMes] - arrayOfParameters[PHOTOCENTER_X_INDEX];
		yPixelCentered        = yPixels[kMes] - arrayOfParameters[PHOTOCENTER_Y_INDEX];
		xPixelCenteredRotated = cosTeta * xPixelCentered - sinTeta * yPixelCentered;
		yPixelCenteredRotated = sinTeta * xPixelCentered + cosTeta * yPixelCentered;
		theEllipse            = xPixelCenteredRotated * xPixelCenteredRotated / twoSquareSigmaX + yPixelCenteredRotated * yPixelCenteredRotated / twoSquareSigmaY;

		// The fitted flux can not be positive because we insure at every iteration that BACKGROUND_FLUX > 0. and SCALE_FACTOR > 0.
		fittedFlux            = arrayOfParameters[BACKGROUND_FLUX_INDEX] + arrayOfParameters[SCALE_FACTOR_INDEX] * exp(-theEllipse);

		theWeightedDeltaObservartions[kMes] = (fluxes[kMes] - fittedFlux) / fluxErrors[kMes];
	}
}

/**
 * Fill the weighted design matrix for the Levenberg-Marquardt minimisation
 */
void Gaussian2DPsfFitter::fillWeightedDesignMatrix(double* const * const weightedDesignMatrix, double* const arrayOfParameters) {

	const double cosTeta         = cos(arrayOfParameters[THETA_INDEX]);
	const double sinTeta         = sin(arrayOfParameters[THETA_INDEX]);
	const double squareSigmaX    = arrayOfParameters[SIGMA_X_INDEX] * arrayOfParameters[SIGMA_X_INDEX];
	const double squareSigmaY    = arrayOfParameters[SIGMA_Y_INDEX] * arrayOfParameters[SIGMA_Y_INDEX];
	const double cubeSigmaX      = arrayOfParameters[SIGMA_X_INDEX] * squareSigmaX;
	const double cubeSigmaY      = arrayOfParameters[SIGMA_Y_INDEX] * squareSigmaY;
	const double twoSquareSigmaX = 2. * squareSigmaX;
	const double twoSquareSigmaY = 2. * squareSigmaY;
	double xPixelCentered;
	double yPixelCentered;
	double xPixelCenteredRotated;
	double yPixelCenteredRotated;
	double theEllipse;
	double exponentialEllipse;
	double commonTerm;
	double commenTermScaled;
	double subDerivative;

	for (int kMes = 0; kMes < numberOfPixelsOneRadius; kMes++) {

		xPixelCentered        = xPixels[kMes] - arrayOfParameters[PHOTOCENTER_X_INDEX];
		yPixelCentered        = yPixels[kMes] - arrayOfParameters[PHOTOCENTER_Y_INDEX];
		xPixelCenteredRotated = cosTeta * xPixelCentered - sinTeta * yPixelCentered;
		yPixelCenteredRotated = sinTeta * xPixelCentered + cosTeta * yPixelCentered;
		theEllipse            = xPixelCenteredRotated * xPixelCenteredRotated / twoSquareSigmaX + yPixelCenteredRotated * yPixelCenteredRotated / twoSquareSigmaY;
		exponentialEllipse    = exp(-theEllipse);
		commonTerm            = exponentialEllipse / fluxErrors[kMes];
		commenTermScaled      = arrayOfParameters[SCALE_FACTOR_INDEX] * commonTerm;

		// Derivative with respect to the background flux is always one
		weightedDesignMatrix[BACKGROUND_FLUX_INDEX][kMes] = 1. / fluxErrors[kMes];

		// Derivative with respect to the scale factor
		weightedDesignMatrix[SCALE_FACTOR_INDEX][kMes]    = commonTerm;

		// Derivative with respect to x0
		subDerivative                                     = -2 * xPixelCenteredRotated * cosTeta / twoSquareSigmaX - 2 * yPixelCenteredRotated * sinTeta / twoSquareSigmaY;
		weightedDesignMatrix[PHOTOCENTER_X_INDEX][kMes]   = -commenTermScaled * subDerivative;

		// Derivative with respect to y0
		subDerivative                                     = +2 * xPixelCenteredRotated * sinTeta / twoSquareSigmaX - 2 * yPixelCenteredRotated * cosTeta / twoSquareSigmaY;
		weightedDesignMatrix[PHOTOCENTER_Y_INDEX][kMes]   = -commenTermScaled * subDerivative;

		// Derivative with respect to theta
		subDerivative                                     = 2 * xPixelCenteredRotated * (-xPixelCentered * sinTeta - yPixelCentered * cosTeta) / twoSquareSigmaX + 2 * yPixelCenteredRotated * (xPixelCentered * cosTeta - yPixelCentered * sinTeta) / twoSquareSigmaY;
		weightedDesignMatrix[THETA_INDEX][kMes]           = -commenTermScaled * subDerivative;

		// Derivative with respect to sigmaX
		subDerivative                                     = -xPixelCenteredRotated * xPixelCenteredRotated / cubeSigmaX;
		weightedDesignMatrix[SIGMA_X_INDEX][kMes]         = -commenTermScaled * subDerivative;

		// Derivative with respect to sigmaX
		subDerivative                                     = -yPixelCenteredRotated * yPixelCenteredRotated / cubeSigmaY;
		weightedDesignMatrix[SIGMA_Y_INDEX][kMes]         = -commenTermScaled * subDerivative;
	}
}

/**
 * Check the parameters of a given iteration
 */
void Gaussian2DPsfFitter::checkArrayOfParameters(double* const arrayOfParameters) throw (InvalidDataException) {

	if ((arrayOfParameters[SCALE_FACTOR_INDEX] <= 0.) || (arrayOfParameters[SIGMA_X_INDEX] <= 0.) || (arrayOfParameters[SIGMA_Y_INDEX] <= 0.)) {

		throw InvalidDataException("Bad array of parameters");
	}

	// Saturate back ground flux to 0.
	if (arrayOfParameters[BACKGROUND_FLUX_INDEX] < 0.) {
		arrayOfParameters[BACKGROUND_FLUX_INDEX] = 0.;
	}
}

/**
 * Copy thePsfParameters in theFinalPsfParameters
 */
void Gaussian2DPsfFitter::copyParamtersInTheFinalSolution(const double* const arrayOfParameters) {

	theFinalPsfParameters->setBackGroundFlux(arrayOfParameters[BACKGROUND_FLUX_INDEX]);
	theFinalPsfParameters->setScaleFactor(arrayOfParameters[SCALE_FACTOR_INDEX]);
	theFinalPsfParameters->setPhotoCenterX(arrayOfParameters[PHOTOCENTER_X_INDEX]);
	theFinalPsfParameters->setPhotoCenterY(arrayOfParameters[PHOTOCENTER_Y_INDEX]);
	theFinalPsfParameters->setTheta(arrayOfParameters[THETA_INDEX]);
	theFinalPsfParameters->setSigmaX(arrayOfParameters[SIGMA_X_INDEX]);
	theFinalPsfParameters->setSigmaY(arrayOfParameters[SIGMA_Y_INDEX]);
}

/**
 * Copy arrayOfParameterErrors in theFinalPsfParameters
 */
void Gaussian2DPsfFitter::setErrorsInThefinalSolution(const double* const arrayOfParameterErrors) {

	theFinalPsfParameters->setBackGroundFluxError(arrayOfParameterErrors[BACKGROUND_FLUX_INDEX]);
	theFinalPsfParameters->setScaleFactorError(arrayOfParameterErrors[SCALE_FACTOR_INDEX]);
	theFinalPsfParameters->setPhotoCenterXError(arrayOfParameterErrors[PHOTOCENTER_X_INDEX]);
	theFinalPsfParameters->setPhotoCenterYError(arrayOfParameterErrors[PHOTOCENTER_Y_INDEX]);
	theFinalPsfParameters->setThetaError(arrayOfParameterErrors[THETA_INDEX]);
	theFinalPsfParameters->setSigmaXError(arrayOfParameterErrors[SIGMA_X_INDEX]);
	theFinalPsfParameters->setSigmaYError(arrayOfParameterErrors[SIGMA_Y_INDEX]);
}

/**
 * Divide the unReduced chiSquare by the degree of freedom
 */
double Gaussian2DPsfFitter::reduceChiSquare(const double unReducedChiSquare) {

	const double reducedChiSquare = unReducedChiSquare / (numberOfPixelsOneRadius - GAUSSIAN_PROFILE_NUMBER_OF_PARAMETERS);

	return reducedChiSquare;
}

/**
 * Copy theFinalPsfParameters in thePsfParameters
 */
void Gaussian2DPsfFitter::setTheBestSolution() {
	thePsfParameters->copy(theFinalPsfParameters);
}

/**
 * Class constructor
 */
MoffatPsfFitter::MoffatPsfFitter() : PsfFitter(MOFFAT_PROFILE_NUMBER_OF_PARAMETERS,1) {

	thePsfParameters      = new MoffatPsfParameters;
	theFinalPsfParameters = new MoffatPsfParameters;
}

/**
 * Class destructor
 */
MoffatPsfFitter::~MoffatPsfFitter() {

	if(thePsfParameters != NULL) {
		delete thePsfParameters;
		thePsfParameters = NULL;
	}
}

/*
 * Get the PSF parameters
 */
MoffatPsfParameters* const MoffatPsfFitter::getThePsfParameters() const{
	return thePsfParameters;
}

/**
 *  Decode the fit coefficients
 */
void MoffatPsfFitter::decodeFitCoefficients(const double* const fitCoefficients) {

	// Theta = 0
	thePsfParameters->setTheta(0.);
	// Beta = -1
	thePsfParameters->setBeta(-1.);

	const double c1   = fitCoefficients[0];
	const double c2   = fitCoefficients[1];
	const double c3   = fitCoefficients[2];
	const double c4   = fitCoefficients[3];
	const double c5   = fitCoefficients[4];

	double squareSigmaX;
	if(c2             > 0.) {
		squareSigmaX         = 1 / sqrt(c2);
		const double sigmaX  = sqrt(squareSigmaX);
		thePsfParameters->setSigmaX(sigmaX);
	} else {
		// Set a default value
		squareSigmaX         = 1.;
		thePsfParameters->setSigmaX(1.);
	}

	double squareSigmaY;
	if(c4             > 0.) {
		squareSigmaY        = 1 / sqrt(c4);
		const double sigmaY = sqrt(squareSigmaY);
		thePsfParameters->setSigmaY(sigmaY);
	} else {
		// Set a default value
		squareSigmaY        = 1.;
		thePsfParameters->setSigmaY(1.);
	}

	const double x0   = -c3 * squareSigmaX / 2;
	const double y0   = -c5 * squareSigmaY / 2;

	thePsfParameters->setPhotoCenterX(x0);
	thePsfParameters->setPhotoCenterY(y0);

	const double scaleFactor = (1 + x0 * x0 / squareSigmaX + y0 * y0 / squareSigmaY) / c1;
	thePsfParameters->setScaleFactor(scaleFactor);
}

/**
 * Fill the weighted observations (transformedFluxes / transformedFluxErrors) to find the preliminary solution
 */
void MoffatPsfFitter::fillWeightedDesignMatrix(double* const * const weightedDesignMatrix) {

	for(int pixel = 0; pixel < numberOfPixelsOneRadius; pixel++) {

		/* The constant element term */
		weightedDesignMatrix[0][pixel] = 1. / transformedFluxErrors[pixel];

		/* The xPixel term */
		weightedDesignMatrix[2][pixel] = xPixels[pixel] / transformedFluxErrors[pixel];

		/* The xPixel^2 term */
		weightedDesignMatrix[1][pixel] = xPixels[pixel] * weightedDesignMatrix[2][pixel];

		/* The yPixel term */
		weightedDesignMatrix[4][pixel] = yPixels[pixel] / transformedFluxErrors[pixel];

		/* The yPixel * yPixel term */
		weightedDesignMatrix[3][pixel] = yPixels[pixel] * weightedDesignMatrix[4][pixel];
	}
}

/**
 * Deduce the preliminary value of the background flux from the minimum of fluxes
 */
void MoffatPsfFitter::deduceInitialBackgroundFlux(const double minimumOfFluxes) {

	thePsfParameters->setBackGroundFlux(minimumOfFluxes - 1.);
}

/**
 * Transform fluxes for computing the preliminary solution
 */
void MoffatPsfFitter::transformFluxesForPreliminarySolution() {

	for(int pixel = 0; pixel < numberOfPixelsOneRadius; pixel++) {

		/* We subtract the background flux */
		transformedFluxes[pixel]     = fluxes[pixel] - thePsfParameters->getBackGroundFlux();

		/* The error bars */
		transformedFluxErrors[pixel] = fluxErrors[pixel] / transformedFluxes[pixel] / transformedFluxes[pixel];

		/* We take the inverse of fluxes */
		transformedFluxes[pixel]     = 1. / transformedFluxes[pixel];
	}
}

/**
 * Fill the array of parameters for the Levenberg-Marquardt minimisation
 */
void MoffatPsfFitter::fillArrayOfParameters(double* const arrayOfParameters) {

	arrayOfParameters[BACKGROUND_FLUX_INDEX] = thePsfParameters->getBackGroundFlux();
	arrayOfParameters[SCALE_FACTOR_INDEX]    = thePsfParameters->getScaleFactor();
	arrayOfParameters[PHOTOCENTER_X_INDEX]   = thePsfParameters->getPhotoCenterX();
	arrayOfParameters[PHOTOCENTER_Y_INDEX]   = thePsfParameters->getPhotoCenterY();
	arrayOfParameters[THETA_INDEX]           = thePsfParameters->getTheta();
	arrayOfParameters[SIGMA_X_INDEX]         = thePsfParameters->getSigmaX();
	arrayOfParameters[SIGMA_Y_INDEX]         = thePsfParameters->getSigmaY();
	arrayOfParameters[BETA_INDEX]            = thePsfParameters->getBeta();
}

/**
 * Fill the weighted delta observations (observation - fit) / sigma for the Levenberg-Marquardt minimisation
 */
void MoffatPsfFitter::fillWeightedDeltaObservations(double* const theWeightedDeltaObservartions, double* const arrayOfParameters) {
	//TODO
}

/**
 * Fill the weighted design matrix for the Levenberg-Marquardt minimisation
 */
void MoffatPsfFitter::fillWeightedDesignMatrix(double* const * const weightedDesignMatrix, double* const arrayOfParameters) {
	//TODO
}

/**
 * Check the parameters of a given iteration
 */
void MoffatPsfFitter::checkArrayOfParameters(double* const arrayOfParameters) throw (InvalidDataException) {
	//TODO
}

/**
 * Copy thePsfParameters in theFinalPsfParameters
 */
void MoffatPsfFitter::copyParamtersInTheFinalSolution(const double* const arrayOfParameters) {

	theFinalPsfParameters->setBackGroundFlux(arrayOfParameters[BACKGROUND_FLUX_INDEX]);
	theFinalPsfParameters->setScaleFactor(arrayOfParameters[SCALE_FACTOR_INDEX]);
	theFinalPsfParameters->setPhotoCenterX(arrayOfParameters[PHOTOCENTER_X_INDEX]);
	theFinalPsfParameters->setPhotoCenterY(arrayOfParameters[PHOTOCENTER_Y_INDEX]);
	theFinalPsfParameters->setTheta(arrayOfParameters[THETA_INDEX]);
	theFinalPsfParameters->setSigmaX(arrayOfParameters[SIGMA_X_INDEX]);
	theFinalPsfParameters->setSigmaY(arrayOfParameters[SIGMA_Y_INDEX]);
	theFinalPsfParameters->setBeta(arrayOfParameters[BETA_INDEX]);
}

/**
 * Copy arrayOfParameterErrors in theFinalPsfParameters
 */
void MoffatPsfFitter::setErrorsInThefinalSolution(const double* const arrayOfParameterErrors) {

	theFinalPsfParameters->setBackGroundFluxError(arrayOfParameterErrors[BACKGROUND_FLUX_INDEX]);
	theFinalPsfParameters->setScaleFactorError(arrayOfParameterErrors[SCALE_FACTOR_INDEX]);
	theFinalPsfParameters->setPhotoCenterXError(arrayOfParameterErrors[PHOTOCENTER_X_INDEX]);
	theFinalPsfParameters->setPhotoCenterYError(arrayOfParameterErrors[PHOTOCENTER_Y_INDEX]);
	theFinalPsfParameters->setThetaError(arrayOfParameterErrors[THETA_INDEX]);
	theFinalPsfParameters->setSigmaXError(arrayOfParameterErrors[SIGMA_X_INDEX]);
	theFinalPsfParameters->setSigmaYError(arrayOfParameterErrors[SIGMA_Y_INDEX]);
	theFinalPsfParameters->setBetaError(arrayOfParameterErrors[BETA_INDEX]);
}

/**
 * Divide the unReduced chiSquare by the degree of freedom
 */
double MoffatPsfFitter::reduceChiSquare(const double unReducedChiSquare) {

	const double reducedChiSquare = unReducedChiSquare / (numberOfPixelsOneRadius - MOFFAT_PROFILE_NUMBER_OF_PARAMETERS);

	return reducedChiSquare;
}

/**
 * Copy theFinalPsfParameters in thePsfParameters
 */
void MoffatPsfFitter::setTheBestSolution() {
	thePsfParameters->copy(theFinalPsfParameters);
}

/**
 * Class constructor
 */
MoffatBetaMinus3PsfFitter::MoffatBetaMinus3PsfFitter() : PsfFitter(MOFFAT_BETA_FIXED_PROFILE_NUMBER_OF_PARAMETERS,1) { //TODO

	thePsfParameters      = new PsfParameters;
	theFinalPsfParameters = new PsfParameters;
}

/**
 * Class destructor
 */
MoffatBetaMinus3PsfFitter:: ~MoffatBetaMinus3PsfFitter() {

	if(thePsfParameters != NULL) {
		delete thePsfParameters;
		thePsfParameters = NULL;
	}
}

/*
 * Get the PSF parameters
 */
PsfParameters* const MoffatBetaMinus3PsfFitter::getThePsfParameters() const{
	return thePsfParameters;
}

/**
 *  Decode the fit coefficients
 */
void MoffatBetaMinus3PsfFitter::decodeFitCoefficients(const double* const fitCoefficients) {
	//TODO
}

/**
 * Deduce the preliminary value of the background flux from the minimum of fluxes
 */
void MoffatBetaMinus3PsfFitter::deduceInitialBackgroundFlux(const double minimumOfFluxes) {

	thePsfParameters->setBackGroundFlux(minimumOfFluxes - 1.);
}

/**
 * Fill the weighted observations (transformedFluxes / transformedFluxErrors) to find the preliminary solution
 */
void MoffatBetaMinus3PsfFitter::fillWeightedDesignMatrix(double* const * const weightedDesignMatrix) {
	//TODO
}

/**
 * Transform fluxes for computing the preliminary solution
 */
void MoffatBetaMinus3PsfFitter::transformFluxesForPreliminarySolution() {

	for(int pixel = 0; pixel < numberOfPixelsOneRadius; pixel++) {

		/* We subtract the background flux */
		transformedFluxes[pixel]     = fluxes[pixel] - thePsfParameters->getBackGroundFlux();

		/* The error bars */
		transformedFluxErrors[pixel] = fluxErrors[pixel] / transformedFluxes[pixel] / transformedFluxes[pixel];

		/* We take the inverse of fluxes */
		transformedFluxes[pixel]     = 1. / transformedFluxes[pixel];
	}
}

/**
 * Fill the array of parameters for the Levenberg-Marquardt minimisation
 */
void MoffatBetaMinus3PsfFitter::fillArrayOfParameters(double* const arrayOfParameters) {

	arrayOfParameters[BACKGROUND_FLUX_INDEX] = thePsfParameters->getBackGroundFlux();
	arrayOfParameters[SCALE_FACTOR_INDEX]    = thePsfParameters->getScaleFactor();
	arrayOfParameters[PHOTOCENTER_X_INDEX]   = thePsfParameters->getPhotoCenterX();
	arrayOfParameters[PHOTOCENTER_Y_INDEX]   = thePsfParameters->getPhotoCenterY();
	arrayOfParameters[THETA_INDEX]           = thePsfParameters->getTheta();
	arrayOfParameters[SIGMA_X_INDEX]         = thePsfParameters->getSigmaX();
	arrayOfParameters[SIGMA_Y_INDEX]         = thePsfParameters->getSigmaY();
}

/**
 * Fill the weighted delta observations (observation - fit) / sigma for the Levenberg-Marquardt minimisation
 */
void MoffatBetaMinus3PsfFitter::fillWeightedDeltaObservations(double* const theWeightedDeltaObservartions, double* const arrayOfParameters) {
	//TODO
}

/**
 * Fill the weighted design matrix for the Levenberg-Marquardt minimisation
 */
void MoffatBetaMinus3PsfFitter::fillWeightedDesignMatrix(double* const * const weightedDesignMatrix, double* const arrayOfParameters) {
	//TODO
}

/**
 * Check the parameters of a given iteration
 */
void MoffatBetaMinus3PsfFitter::checkArrayOfParameters(double* const arrayOfParameters) throw (InvalidDataException) {
	//TODO
}

/**
 * Copy arrayOfParameters in theFinalPsfParameters
 */
void MoffatBetaMinus3PsfFitter::copyParamtersInTheFinalSolution(const double* const arrayOfParameters) {

	theFinalPsfParameters->setBackGroundFlux(arrayOfParameters[BACKGROUND_FLUX_INDEX]);
	theFinalPsfParameters->setScaleFactor(arrayOfParameters[SCALE_FACTOR_INDEX]);
	theFinalPsfParameters->setPhotoCenterX(arrayOfParameters[PHOTOCENTER_X_INDEX]);
	theFinalPsfParameters->setPhotoCenterY(arrayOfParameters[PHOTOCENTER_Y_INDEX]);
	theFinalPsfParameters->setTheta(arrayOfParameters[THETA_INDEX]);
	theFinalPsfParameters->setSigmaX(arrayOfParameters[SIGMA_X_INDEX]);
	theFinalPsfParameters->setSigmaY(arrayOfParameters[SIGMA_Y_INDEX]);
}

/**
 * Copy arrayOfParameterErrors in theFinalPsfParameters
 */
void MoffatBetaMinus3PsfFitter::setErrorsInThefinalSolution(const double* const arrayOfParameterErrors) {

	theFinalPsfParameters->setBackGroundFluxError(arrayOfParameterErrors[BACKGROUND_FLUX_INDEX]);
	theFinalPsfParameters->setScaleFactorError(arrayOfParameterErrors[SCALE_FACTOR_INDEX]);
	theFinalPsfParameters->setPhotoCenterXError(arrayOfParameterErrors[PHOTOCENTER_X_INDEX]);
	theFinalPsfParameters->setPhotoCenterYError(arrayOfParameterErrors[PHOTOCENTER_Y_INDEX]);
	theFinalPsfParameters->setThetaError(arrayOfParameterErrors[THETA_INDEX]);
	theFinalPsfParameters->setSigmaXError(arrayOfParameterErrors[SIGMA_X_INDEX]);
	theFinalPsfParameters->setSigmaYError(arrayOfParameterErrors[SIGMA_Y_INDEX]);
}

/**
 * Divide the unReduced chiSquare by the degree of freedom
 */
double MoffatBetaMinus3PsfFitter::reduceChiSquare(const double unReducedChiSquare) {

	const double reducedChiSquare = unReducedChiSquare / (numberOfPixelsOneRadius - MOFFAT_BETA_FIXED_PROFILE_NUMBER_OF_PARAMETERS);

	return reducedChiSquare;
}

/**
 * Copy theFinalPsfParameters in thePsfParameters
 */
void MoffatBetaMinus3PsfFitter::setTheBestSolution() {
	thePsfParameters->copy(theFinalPsfParameters);
}

/**
 * Class constructor
 */
PsfParameters::PsfParameters() {

	backGroundFlux      = NAN;
	backGroundFluxError = NAN;
	scaleFactor         = NAN;
	scaleFactorError    = NAN;
	photoCenterX        = NAN;
	photoCenterXError   = NAN;
	photoCenterY        = NAN;
	photoCenterYError   = NAN;
	sigmaX              = NAN;
	sigmaXError         = NAN;
	sigmaY              = NAN;
	sigmaYError         = NAN;
	theta               = NAN;
	thetaError          = NAN;
}

/**
 * Class destructor
 */
PsfParameters::~PsfParameters() {}

/**
 * Copy anotherPsfParameters in this
 */
void PsfParameters::copy(PsfParameters* const anotherPsfParameters) {

	backGroundFlux      = anotherPsfParameters->backGroundFlux;
	scaleFactor         = anotherPsfParameters->scaleFactor;
	photoCenterX        = anotherPsfParameters->photoCenterX;
	photoCenterY        = anotherPsfParameters->photoCenterY;
	sigmaX              = anotherPsfParameters->sigmaX;
	sigmaY              = anotherPsfParameters->sigmaY;
	theta               = anotherPsfParameters->theta;
}


double PsfParameters::getBackGroundFlux() const {
	return backGroundFlux;
}

void PsfParameters::setBackGroundFlux(const double inputBackGroundFlux) {
	backGroundFlux = inputBackGroundFlux;
}

double PsfParameters::getScaleFactor() const {
	return scaleFactor;

}

void PsfParameters::setScaleFactor(const double inputScaleFactor) {
	scaleFactor = inputScaleFactor;
}

double PsfParameters::getScaleFactorError() const {
	return scaleFactorError;

}

void PsfParameters::setScaleFactorError(const double inputScaleFactorError) {
	scaleFactorError = inputScaleFactorError;
}

double PsfParameters::getBackGroundFluxError() const {
	return backGroundFluxError;
}

void PsfParameters::setBackGroundFluxError(const double inputBackGroundFluxError) {
	backGroundFluxError = inputBackGroundFluxError;
}

double PsfParameters::getPhotoCenterX() const {
	return photoCenterX;
}

void PsfParameters::setPhotoCenterX(const double inputPhotoCenterX) {
	photoCenterX = inputPhotoCenterX;
}

double PsfParameters::getPhotoCenterXError() const {
	return photoCenterXError;
}

void PsfParameters::setPhotoCenterXError(const double inputPhotoCenterXError) {
	photoCenterXError = inputPhotoCenterXError;
}

double PsfParameters::getPhotoCenterY() const {
	return photoCenterY;
}

void PsfParameters::setPhotoCenterY(const double inputPhotoCenterY) {
	photoCenterY = inputPhotoCenterY;
}

double PsfParameters::getPhotoCenterYError() const {
	return photoCenterYError;
}

void PsfParameters::setPhotoCenterYError(const double inputPhotoCenterYError) {
	photoCenterYError = inputPhotoCenterYError;
}

double PsfParameters::getSigmaX() const {
	return sigmaX;
}

void PsfParameters::setSigmaX(const double inputSigmaX) {
	sigmaX = inputSigmaX;
}

double PsfParameters::getSigmaXError() const {
	return sigmaXError;
}

void PsfParameters::setSigmaXError(const double inputSigmaXError) {
	sigmaXError = inputSigmaXError;
}

double PsfParameters::getSigmaY() const {
	return sigmaY;
}

void PsfParameters::setSigmaY(const double inputSigmaY) {
	sigmaY = inputSigmaY;
}

double PsfParameters::getSigmaYError() const {
	return sigmaYError;
}

void PsfParameters::setSigmaYError(const double inputSigmaYError) {
	sigmaYError = inputSigmaYError;
}

double PsfParameters::getTheta() const {
	return theta;
}

void PsfParameters::setTheta(const double inputTheta) {
	theta = inputTheta;
}

double PsfParameters::getThetaError() const {
	return thetaError;
}

void PsfParameters::setThetaError(const double inputThetaError) {
	thetaError = inputThetaError;
}

/**
 * Class constructor
 */
MoffatPsfParameters::MoffatPsfParameters() {

	beta      = NAN;
	betaError = NAN;
}

/**
 * Copy anotherPsfParameters in this
 */
void MoffatPsfParameters::copy(MoffatPsfParameters* const anotherPsfParameters) {

	super::copy(anotherPsfParameters);

	beta = anotherPsfParameters->beta;
}

/**
 * Class destructor
 */
MoffatPsfParameters::~MoffatPsfParameters() {}


double MoffatPsfParameters::getBeta() const {
	return beta;
}

void MoffatPsfParameters::setBeta(const double inputBeta) {
	beta = inputBeta;
}

double MoffatPsfParameters::getBetaError() const {
	return betaError;
}

void MoffatPsfParameters::setBetaError(const double inputBetaError) {
	betaError = inputBetaError;
}
