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
#define GAUSSIAN_PROFILE_NUMBER_OF_PARAMETERS_PRELIMINARY_SOLUTION 6
#define MOFFAT_PROFILE_NUMBER_OF_PARAMETERS 8
#define MOFFAT_PROFILE_NUMBER_OF_PARAMETERS_PRELIMINARY_SOLUTION 5
#define MOFFAT_BETA_FIXED_PROFILE_NUMBER_OF_PARAMETERS 7
#define MOFFAT_BETA_FIXED_PROFILE_NUMBER_OF_PARAMETERS_PRELIMINARY_SOLUTION 25

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
	void copy(PsfParameters* const anotherPsfParameters);
};

/**
 * Container class for Moffat PSF parameters
 */
class MoffatPsfParameters : public PsfParameters {

private:
	typedef PsfParameters super;
	double beta;
	double betaError;

public:
	MoffatPsfParameters();
	virtual ~MoffatPsfParameters();
	double getBeta() const;
	void setBeta(const double beta);
	double getBetaError() const;
	void setBetaError(const double betaError);
	void copy(MoffatPsfParameters* const anotherPsfParameters);
};

/**
 * Parent class for fitting different kind of profiles
 */
class PsfFitter : public LinearAlgebraicSystemInterface,NonLinearAlgebraicSystemInterface {

private:
	char logMessage[1024];
	int numberOfParameterFit;
	int numberOfParameterFitPreliminarySolution;
	LinearAlgebraicSystemSolver* theLinearAlgebraicSystemSolver;
	LevenbergMarquardtSystemSolver* theLevenbergMarquardtSystemSolver;

protected:
	static const double TWO_PI;
	static const int BACKGROUND_FLUX_INDEX;
	static const int SCALE_FACTOR_INDEX;
	static const int PHOTOCENTER_X_INDEX;
	static const int PHOTOCENTER_Y_INDEX;
	static const int THETA_INDEX;
	static const int SIGMA_X_INDEX;
	static const int SIGMA_Y_INDEX;
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

	virtual void transformFluxesForPreliminarySolution() = 0;
	void extractProcessingZoneMaximumRadius(CBuffer* const theBufferImage, const int xCenter, const int yCenter, const int theRadius,
			const double saturationLimit, const double readOutNoise) throw (InsufficientMemoryException);
	void extractProcessingZone(const int theRadius);
	double fitProfilePerRadius();
	void findInitialSolution();
	double refineSolution();
	virtual void deduceInitialBackgroundFlux(const double minimumOfFluxes) = 0;
	virtual void decodeFitCoefficients(const double* const fitCoefficients) = 0;
	virtual void copyParamtersInTheFinalSolution(const double* const arrayOfParameters) = 0;
	virtual double reduceChiSquare(const double unReducedChiSquare) = 0;
	virtual void setTheBestSolution() = 0;
	virtual void setErrorsInThefinalSolution(const double* const arrayOfParameterErrors) = 0;
	virtual void updatePhotocenter(const int xCenter, const int yCenter) = 0;
	const double findMinimumOfFluxes();
	void correctTheta(double& theta);

public:
	PsfFitter(const int inputNumberOfParameterFit,const int inputNumberOfParameterFitPreliminarySolution);
	virtual ~PsfFitter();
	int fitProfile(CBuffer* const theBufferImage, const int xCenter, const int yCenter, const int minimumRadius, const int maximumRadius,
			const double saturationLimit, const double readOutNoise) throw (InsufficientMemoryException);
	const int getNumberOfMeasurements();
	void fillWeightedObservations(double* const weightedObservartions);
};

/**
 * Class for fitting a 2D gaussian profile
 */
class Gaussian2DPsfFitter : public PsfFitter {

private:
	PsfParameters* thePsfParameters;
	PsfParameters* theFinalPsfParameters;

protected:
	void transformFluxesForPreliminarySolution();
	void deduceInitialBackgroundFlux(const double minimumOfFluxes);
	void decodeFitCoefficients(const double* const fitCoefficients);
	void copyParamtersInTheFinalSolution(const double* const arrayOfParameters);
	double reduceChiSquare(const double unReducedChiSquare);
	void setTheBestSolution();
	void setErrorsInThefinalSolution(const double* const arrayOfParameterErrors);
	void updatePhotocenter(const int xCenter, const int yCenter);

public:
	Gaussian2DPsfFitter();
	virtual ~Gaussian2DPsfFitter();
	PsfParameters* const getThePsfParameters() const;
	void fillWeightedDesignMatrix(double* const * const weightedDesignMatrix);
	void fillArrayOfParameters(double* const arrayOfParameters);
	void fillWeightedDeltaObservations(double* const theWeightedDeltaObservartions, double* const arrayOfParameters);
	void fillWeightedDesignMatrix(double* const * const weightedDesignMatrix, double* const arrayOfParameters);
	void checkArrayOfParameters(double* const arrayOfParameters) throw (InvalidDataException);
};

/**
 * Class for fitting a Moffat non radial profile
 */
class MoffatPsfFitter : public PsfFitter {

private:
	static const int BETA_INDEX;
	MoffatPsfParameters* thePsfParameters;
	MoffatPsfParameters* theFinalPsfParameters;

protected:
	void transformFluxesForPreliminarySolution();
	void deduceInitialBackgroundFlux(const double minimumOfFluxes);
	void decodeFitCoefficients(const double* const fitCoefficients);
	void copyParamtersInTheFinalSolution(const double* const arrayOfParameters);
	double reduceChiSquare(const double unReducedChiSquare);
	void setTheBestSolution();
	void setErrorsInThefinalSolution(const double* const arrayOfParameterErrors);
	void updatePhotocenter(const int xCenter, const int yCenter);

public:
	MoffatPsfFitter();
	virtual ~MoffatPsfFitter();
	MoffatPsfParameters* const getThePsfParameters() const;
	void fillWeightedDesignMatrix(double* const * const weightedDesignMatrix);
	void fillArrayOfParameters(double* const arrayOfParameters);
	void fillWeightedDeltaObservations(double* const theWeightedDeltaObservartions, double* const arrayOfParameters);
	void fillWeightedDesignMatrix(double* const * const weightedDesignMatrix, double* const arrayOfParameters);
	void checkArrayOfParameters(double* const arrayOfParameters) throw (InvalidDataException);
};

/**
 * Class for fitting a Moffat non radial profile with beta = -3
 */
class MoffatBetaMinus3PsfFitter : public PsfFitter {

private:
	PsfParameters* thePsfParameters;
	PsfParameters* theFinalPsfParameters;

protected:
	void transformFluxesForPreliminarySolution();
	void deduceInitialBackgroundFlux(const double minimumOfFluxes);
	void decodeFitCoefficients(const double* const fitCoefficients);
	void copyParamtersInTheFinalSolution(const double* const arrayOfParameters);
	double reduceChiSquare(const double unReducedChiSquare);
	void setTheBestSolution();
	void setErrorsInThefinalSolution(const double* const arrayOfParameterErrors);
	void updatePhotocenter(const int xCenter, const int yCenter);

public:
	MoffatBetaMinus3PsfFitter();
	virtual ~MoffatBetaMinus3PsfFitter();
	PsfParameters* const getThePsfParameters() const;
	void fillWeightedDesignMatrix(double* const * const weightedDesignMatrix);
	void fillArrayOfParameters(double* const arrayOfParameters);
	void fillWeightedDeltaObservations(double* const theWeightedDeltaObservartions, double* const arrayOfParameters);
	void fillWeightedDesignMatrix(double* const * const weightedDesignMatrix, double* const arrayOfParameters);
	void checkArrayOfParameters(double* const arrayOfParameters) throw (InvalidDataException);
};

const double findMaximum(const double* const arrayOfDoubles, const int lengthOfArray);

#endif // __PSFFITTERH__
