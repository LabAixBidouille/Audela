/**
 * Code file for profile fitting methods
 *
 * Author : Yassine Damerdji
 */
#include "PsfFitter.h"

/**
 * Class constructor
 */
PsfFitter::PsfFitter(const int inputNumberOfParameterFit):numberOfParameterFit(inputNumberOfParameterFit) {

	xPixelsMaximumRadius           = NULL;
	yPixelsMaximumRadius           = NULL;
	fluxesMaximumRadius            = NULL;
	fluxErrorsMaximumRadius        = NULL;
	isUsedFlags                    = NULL;
	xPixels                        = NULL;
	yPixels                        = NULL;
	fluxes                         = NULL;
	fluxErrors                     = NULL;
	transformedFluxes              = NULL;
	transformedFluxErrors          = NULL;
	numberOfPixelsMaximumRadius    = 0;
	numberOfPixelsOneRadius        = 0;
	bestRadius                     = -1;
	theLinearAlgebraicSystemSolver = NULL;
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

	numberOfPixelsMaximumRadius = 0;
	numberOfPixelsOneRadius     = 0;
}

/**
 * Loop over radii to find the best fit
 */
int PsfFitter::fitProfile(CBuffer* const theBufferImage, const int xCenter, const int yCenter, const int minimumRadius, const int maximumRadius,
		const double saturationLimit, const double readOutNoise) {

	numberOfPixelsOneRadius     = 0;
	double bestReducedChiSquare = 1e100;
	bestRadius                  = -1;
	double reducedChiSquare;
	int resultOfFunction;

	/* Extract the processing zone for the maximum radius */
	resultOfFunction = extractProcessingZoneMaximumRadius(theBufferImage, xCenter, yCenter, maximumRadius, saturationLimit, readOutNoise);
	if(resultOfFunction) {
		return 1;
	}

	theLinearAlgebraicSystemSolver = new LinearAlgebraicSystemSolver(this,numberOfParameterFit,numberOfPixelsMaximumRadius);
	if(theLinearAlgebraicSystemSolver->isIsMemoryInsufficient()) {
		return 1;
	}

	for(int theRadius = minimumRadius; theRadius <= maximumRadius; theRadius++) {

		/* Extract pixels needed for the fit */
		extractProcessingZone(theRadius);

		/* Fit the profile*/
		reducedChiSquare         = fitProfilePerRadius();

		if(bestReducedChiSquare  > reducedChiSquare) {
			bestReducedChiSquare = reducedChiSquare;
			bestRadius           = theRadius;
		}
	}

	return 0;
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
 * Extract pixels needed for the fit
 */
int PsfFitter::extractProcessingZoneMaximumRadius(CBuffer* const theBufferImage, const int xCenter, const int yCenter, const int theRadius,
		const double saturationLimit, const double readOutNoise) {

	const int naxis1 = theBufferImage->GetWidth();
	const int naxis2 = theBufferImage->GetHeight();

	// Starts buy taking the rectangle
	int xPixelStart  = xCenter - theRadius;
	if (xPixelStart  < 0) {
		xPixelStart  = 0;
	}

	int xPixelEnd    = xCenter + theRadius;
	if (xPixelEnd   >= naxis1) {;
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
		printf("Error when allocating memory of %d (double) for allPixels\n",numberOfPixelsMaximumRadius);
		return 1;
	}

	theBufferImage->GetPixels(xPixelStart, yPixelStart, xPixelEnd, yPixelEnd, FORMAT_FLOAT, PLANE_GREY, allPixels);

	// For the maximum radius, we select the rectangle instead of the circle
	xPixelsMaximumRadius        = new int[numberOfPixelsMaximumRadius];
	if(xPixelsMaximumRadius    == NULL) {
		delete[] allPixels;
		printf("Error when allocating memory of %d (double) for xPixelsMaximumRadius\n",numberOfPixelsMaximumRadius);
		return 1;
	}
	xPixels                     = new int[numberOfPixelsMaximumRadius];
	if(xPixels                 == NULL) {
		delete[] allPixels;
		delete[] xPixelsMaximumRadius;
		printf("Error when allocating memory of %d (double) for xPixels\n",numberOfPixelsMaximumRadius);
		return 1;
	}

	yPixelsMaximumRadius        = new int[numberOfPixelsMaximumRadius];
	if(yPixelsMaximumRadius    == NULL) {
		delete[] allPixels;
		delete[] xPixelsMaximumRadius;
		delete[] xPixels;
		printf("Error when allocating memory of %d (double) for yPixelsMaximumRadius\n",numberOfPixelsMaximumRadius);
		return 1;
	}
	yPixels                     = new int[numberOfPixelsMaximumRadius];
	if(yPixels                 == NULL) {
		delete[] allPixels;
		delete[] xPixelsMaximumRadius;
		delete[] xPixels;
		delete[] yPixelsMaximumRadius;
		printf("Error when allocating memory of %d (double) for yPixels\n",numberOfPixelsMaximumRadius);
		return 1;
	}

	fluxesMaximumRadius         = new double[numberOfPixelsMaximumRadius];
	if(fluxesMaximumRadius     == NULL) {
		delete[] allPixels;
		delete[] xPixelsMaximumRadius;
		delete[] xPixels;
		delete[] yPixelsMaximumRadius;
		delete[] yPixels;
		printf("Error when allocating memory of %d (double) for fluxesMaximumRadius\n",numberOfPixelsMaximumRadius);
		return 1;
	}
	fluxes                      = new double[numberOfPixelsMaximumRadius];
	if(fluxes                  == NULL) {
		delete[] allPixels;
		delete[] xPixelsMaximumRadius;
		delete[] xPixels;
		delete[] yPixelsMaximumRadius;
		delete[] yPixels;
		delete[] fluxesMaximumRadius;
		printf("Error when allocating memory of %d (double) for fluxes\n",numberOfPixelsMaximumRadius);
		return 1;
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
		printf("Error when allocating memory of %d (double) for transformedFluxes\n",numberOfPixelsMaximumRadius);
		return 1;
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
		printf("Error when allocating memory of %d (double) for fluxErrorsMaximumRadius\n",numberOfPixelsMaximumRadius);
		return 1;
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
		printf("Error when allocating memory of %d (double) for fluxErrors\n",numberOfPixelsMaximumRadius);
		return 1;
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
		printf("Error when allocating memory of %d (double) for transformedFluxErrors\n",numberOfPixelsMaximumRadius);
		return 1;
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
		printf("Error when allocating memory of %d (double) for isUsedFlags\n",numberOfPixelsMaximumRadius);
		return 1;
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
			isUsedFlags[counter]          = false;
			counter++;
		}
	}

	delete[] allPixels;

	return 0;
}

/**
 * Compute the minimum of fluxes
 */
const double PsfFitter::findMinimumOfFluxes() {

	double minimumOfFLuxes = fluxes[0];

	for(int pixel = 1; pixel < numberOfPixelsOneRadius; pixel++) {

		if(minimumOfFLuxes  > fluxes[pixel]){
			minimumOfFLuxes = fluxes[pixel];
		}
	}

	return minimumOfFLuxes;
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
 * Find the Gaussian 2D PSF preliminary solution
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
	decodeFitCoefficients();
}

/**
 * Class constructor
 */
Gaussian2DPsfFitter::Gaussian2DPsfFitter() : PsfFitter(GAUSSIAN_PROFILE_NUMBER_OF_PARAMETERS) {

	thePsfParameters = new PsfParameters;
}

/**
 * Class destructor
 */
Gaussian2DPsfFitter::~Gaussian2DPsfFitter() {

	delete thePsfParameters;
}

/*
 * Get the PSF parameters
 */
PsfParameters* const Gaussian2DPsfFitter::getThePsfParameters() const {
	return thePsfParameters;
}

/**
 * Fit a PSF for a given pixel radius
 */
double Gaussian2DPsfFitter::fitProfilePerRadius() {

	// Find the initial solution
	findInitialSolution();

	return 0.;
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
void Gaussian2DPsfFitter::decodeFitCoefficients() {

	const double* const fitCoefficients = theLinearAlgebraicSystemSolver->getFitCoefficients();

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
		// Defaul value
		thePsfParameters->setSigmaX(1.);
	} else {
		thePsfParameters->setSigmaX(sqrt(squareSigmaX));
	}

	const double squareSigmaY       = -0.5 / coefficientSquareY;
	if (squareSigmaY                < 0.) {
		// Defaul value
		thePsfParameters->setSigmaY(1.);
	} else {
		thePsfParameters->setSigmaY(sqrt(squareSigmaY));
	}

	double scaleFactor              = coefficientF + x0Tilde * x0Tilde / 2 / squareSigmaX + y0Tilde * y0Tilde / 2 / squareSigmaY;
	scaleFactor                     = exp(scaleFactor);

	thePsfParameters->setScaleFactor(scaleFactor);
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

		/* The xPixel * yPixel term */
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

void Gaussian2DPsfFitter::refineSolution() {
	//TODO
}

double Gaussian2DPsfFitter::computeChiSquare(const double* const arrayOfParameters) {

	//TODO

	return 0.;
}

/**
 * Class constructor
 */
MoffatPsfFitter::MoffatPsfFitter() : PsfFitter(MOFFAT_PROFILE_NUMBER_OF_PARAMETERS) {

	thePsfParameters = new MoffatPsfParameters;
}

/**
 * Class destructor
 */
MoffatPsfFitter::~MoffatPsfFitter() {

	delete thePsfParameters;
}

double MoffatPsfFitter::fitProfilePerRadius() {

	//TODO
	return 0.;
}

void MoffatPsfFitter::refineSolution() {
	//TODO
}

double MoffatPsfFitter::computeChiSquare(const double* const arrayOfParameters) {

	//TODO

	return 0.;
}

/**
 *  Decode the fit coefficients
 */
void MoffatPsfFitter::decodeFitCoefficients() {
//TODO
}

/**
 * Fill the weighted observations (transformedFluxes / transformedFluxErrors) to find the preliminary solution
 */
void MoffatPsfFitter::fillWeightedDesignMatrix(double* const * const weightedDesignMatrix) {
	//TODO
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

//	for(int pixel = 0; pixel < numberOfPixelsOneRadius; pixel++) {
//
//		/* We subtract the background flux */
//		transformedFluxes[pixel]     = fluxes[pixel] - thePsfParameters->backGroundFlux;
//
//		/* The error bars */
//		transformedFluxErrors[pixel] = fluxErrors[pixel] / transformedFluxes[pixel];
//
//		/* We take the logarithm of fluxes */
//		transformedFluxes[pixel]     = log(transformedFluxes[pixel]);
//	}
}

/**
 * Class constructor
 */
MoffatBetaMinus3PsfFitter::MoffatBetaMinus3PsfFitter() : PsfFitter(MOFFAT_BETA_FIXED_PROFILE_NUMBER_OF_PARAMETERS) {

	thePsfParameters = new PsfParameters;
}

/**
 * Class destructor
 */
MoffatBetaMinus3PsfFitter:: ~MoffatBetaMinus3PsfFitter() {

	delete thePsfParameters;
}

double MoffatBetaMinus3PsfFitter::fitProfilePerRadius() {

	//TODO
	return 0.;
}

void MoffatBetaMinus3PsfFitter::refineSolution() {
	//TODO
}

double MoffatBetaMinus3PsfFitter::computeChiSquare(const double* const arrayOfParameters) {

	//TODO

	return 0.;
}

/**
 *  Decode the fit coefficients
 */
void MoffatBetaMinus3PsfFitter::decodeFitCoefficients() {
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

//	for(int pixel = 0; pixel < numberOfPixelsOneRadius; pixel++) {
//
//		/* We subtract the background flux */
//		transformedFluxes[pixel]     = fluxes[pixel] - thePsfParameters->backGroundFlux;
//
//		/* The error bars */
//		transformedFluxErrors[pixel] = fluxErrors[pixel] / transformedFluxes[pixel];
//
//		/* We take the logarithm of fluxes */
//		transformedFluxes[pixel]     = log(transformedFluxes[pixel]);
//	}
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
