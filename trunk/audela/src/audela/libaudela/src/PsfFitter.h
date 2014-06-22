/**
 * Header file for profile fitting methods
 *
 * Author : Yassine Damerdji
 */

#ifndef __PSFFITTERH__
#define __PSFFITTERH__

#include "MinimisationAndLinearAlgebraicSystems.h"
#include "cbuffer.h"

#define GAUSSIAN_PROFILE_NUMBER_OF_PARAMETERS 7
#define MOFFAT_PROFILE_NUMBER_OF_PARAMETERS 8
#define MOFFAT_BETA_FIXED_PROFILE_NUMBER_OF_PARAMETERS 7

/**
 * Parent class for PSF parameters (container class)
 */
class PsfParameters {

protected:
	double backGroundFlux;
	double backGroundFluxError;
	double scaleFactor;
	double scaleFactorError;
	double photoCenterX;
	double photoCenterXError;
	double photoCenterY;
	double photoCenterYError;
	double theta;
	double thetaError;
	double sigmaX;
	double sigmaXError;
	double sigmaY;
	double sigmaYError;

public:
	PsfParameters();
	virtual ~PsfParameters();
	double getBackGroundFlux() const;
	void setBackGroundFlux(const double backGroundFlux);
	double getScaleFactor() const;
	void setScaleFactor(const double scaleFactor);
	double getScaleFactorError() const;
	void setScaleFactorError(const double scaleFactorError);
	double getBackGroundFluxError() const;
	void setBackGroundFluxError(const double backGroundFluxError);
	double getPhotoCenterX() const;
	void setPhotoCenterX(const double photoCenterX);
	double getPhotoCenterXError() const;
	void setPhotoCenterXError(const double photoCenterXError);
	double getPhotoCenterY() const;
	void setPhotoCenterY(const double photoCenterY);
	double getPhotoCenterYError() const;
	void setPhotoCenterYError(const double photoCenterYError);
	double getSigmaX() const;
	void setSigmaX(const double sigmaX);
	double getSigmaXError() const;
	void setSigmaXError(const double sigmaXError);
	double getSigmaY() const;
	void setSigmaY(const double sigmaY);
	double getSigmaYError() const;
	void setSigmaYError(const double sigmaYError);
	double getTheta() const;
	void setTheta(const double theta);
	double getThetaError() const;
	void setThetaError(const double thetaError);
};

/**
 * Container class for Moffat PSF parameters
 */
class MoffatPsfParameters : public PsfParameters {

private:
	double beta;
	double betaError;

public:
	MoffatPsfParameters();
	virtual ~MoffatPsfParameters();
	double getBeta() const;
	void setBeta(const double beta);
	double getBetaError() const;
	void setBetaError(const double betaError);
};

/**
 * Parent class for fitting different kind of profiles
 */
class PsfFitter : public MinimisationInterface, LinearAlgebraicSystemInterface {

protected:
	static const int BACKGROUND_FLUX_INDEX = 0;
	static const int SCALE_FACTOR_INDEX    = 1;
	static const int PHOTOCENTER_X_INDEX   = 2;
	static const int PHOTOCENTER_Y_INDEX   = 3;
	static const int THETA_INDEX           = 4;
	static const int SIGMA_X_INDEX         = 5;
	static const int SIGMA_Y_INDEX         = 6;
	int numberOfParameterFit;
	int bestRadius;
	int     numberOfPixelsMaximumRadius;
	int     numberOfPixelsOneRadius;
	int*    xPixelsMaximumRadius;
	int*    yPixelsMaximumRadius;
	double* fluxesMaximumRadius;
	double* fluxErrorsMaximumRadius;
	bool*   isUsedFlags;
	int*    xPixels;
	int*    yPixels;
	double* fluxes;
	double* fluxErrors;
	double* transformedFluxes;
	double* transformedFluxErrors;
	LinearAlgebraicSystemSolver* theLinearAlgebraicSystemSolver;

	virtual double fitProfilePerRadius() = 0;
	virtual void transformFluxesForPreliminarySolution() = 0;
	int extractProcessingZoneMaximumRadius(CBuffer* const theBufferImage, const int xCenter, const int yCenter, const int theRadius,
			const double saturationLimit, const double readOutNoise);
	void extractProcessingZone(const int theRadius);
	void findInitialSolution();
	virtual void deduceInitialBackgroundFlux(const double minimumOfFluxes) = 0;
	virtual void refineSolution() = 0;
	virtual void decodeFitCoefficients() = 0;
	const double findMinimumOfFluxes();

public:
	PsfFitter(const int inputNumberOfParameterFit);
	virtual ~PsfFitter();
	int fitProfile(CBuffer* const theBufferImage, const int xCenter, const int yCenter, const int minimumRadius, const int maximumRadius,
			const double saturationLimit, const double readOutNoise);
	const int getNumberOfMeasurements();
	void fillWeightedObservations(double* const weightedObservartions);
};

/**
 * Class for fitting a 2D gaussian profile
 */
class Gaussian2DPsfFitter : public PsfFitter {

private:
	PsfParameters* thePsfParameters;

protected:
	double fitProfilePerRadius();
	void transformFluxesForPreliminarySolution();
	void deduceInitialBackgroundFlux(const double minimumOfFluxes);
	void decodeFitCoefficients();
	void refineSolution();

public:
	Gaussian2DPsfFitter();
	virtual ~Gaussian2DPsfFitter();
	PsfParameters* const getThePsfParameters() const;
	void fillWeightedDesignMatrix(double* const * const weightedDesignMatrix);
	double computeChiSquare(const double* const arrayOfParameters);
};

/**
 * Class for fitting a Moffat non radial profile
 */
class MoffatPsfFitter : public PsfFitter {

private:
	MoffatPsfParameters* thePsfParameters;

protected:
	double fitProfilePerRadius();
	void transformFluxesForPreliminarySolution();
	void deduceInitialBackgroundFlux(const double minimumOfFluxes);
	void decodeFitCoefficients();
	void refineSolution();

public:
	MoffatPsfFitter();
	virtual ~MoffatPsfFitter();
	void fillWeightedDesignMatrix(double* const * const weightedDesignMatrix);
	double computeChiSquare(const double* const arrayOfParameters);
};

/**
 * Class for fitting a Moffat non radial profile with beta = -3
 */
class MoffatBetaMinus3PsfFitter : public PsfFitter {

private:
	PsfParameters* thePsfParameters;

protected:
	double fitProfilePerRadius();
	void transformFluxesForPreliminarySolution();
	void deduceInitialBackgroundFlux(const double minimumOfFluxes);
	void decodeFitCoefficients();
	void refineSolution();

public:
	MoffatBetaMinus3PsfFitter();
	virtual ~MoffatBetaMinus3PsfFitter();
	void fillWeightedDesignMatrix(double* const * const weightedDesignMatrix);
	double computeChiSquare(const double* const arrayOfParameters);
};

#endif // __PSFFITTERH__
