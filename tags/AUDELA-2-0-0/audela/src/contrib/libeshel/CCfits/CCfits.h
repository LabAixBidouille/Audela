//   Read the documentation to learn more about C++ code generator
//   versioning.
//	This is version 2.2 release dated Sep 2009
//	Astrophysics Science Division,
//	NASA/ Goddard Space Flight Center
//	HEASARC
//	http://heasarc.gsfc.nasa.gov
//	e-mail: ccfits@legacy.gsfc.nasa.gov
//
//	Original author: Ben Dorman

#ifndef CCFITS_H
#define CCFITS_H 1

// fitsio
#include "fitsio.h"
// string
#include <string>

namespace CCfits {
  class ExtHDU;

} // namespace CCfits
#include <map>
#include <sys/types.h>
#include "longnam.h"
#include "float.h"


namespace CCfits {
  static const int BITPIX = -32;
  static const int  NAXIS =   2;
  static const int  MAXDIM = 99;
  extern const unsigned long USBASE;
  extern const unsigned long  ULBASE;

  extern  char BSCALE[7];
  extern  char BZERO[6];



  typedef enum {Read=READONLY,Write=READWRITE} RWmode;



  typedef enum {Tnull, Tbit = TBIT, Tbyte = TBYTE, Tlogical = TLOGICAL, Tstring = TSTRING, Tushort = TUSHORT, Tshort = TSHORT,Tuint = TUINT,Tint = TINT, Tulong = TULONG,Tlong = TLONG, Tlonglong = TLONGLONG, Tfloat = TFLOAT, Tdouble = TDOUBLE, Tcomplex = TCOMPLEX, Tdblcomplex=TDBLCOMPLEX, VTbit= -TBIT, VTbyte=-TBYTE,VTlogical=-Tlogical, VTushort=-TUSHORT,VTshort=-TSHORT,VTuint=-TUINT, VTint=-TINT,VTulong=-TULONG,VTlong=-TLONG,VTlonglong=-TLONGLONG,VTfloat=-TFLOAT,VTdouble=-TDOUBLE,VTcomplex=-TCOMPLEX,VTdblcomplex=-TDBLCOMPLEX} ValueType;



  typedef enum {AnyHdu=-1, ImageHdu, AsciiTbl, BinaryTbl} HduType;



  typedef enum {Inotype = 0, Ibyte=BYTE_IMG, 
  Ishort = SHORT_IMG,
  Ilong = LONG_IMG, 
  Ifloat = FLOAT_IMG, 
  Idouble = DOUBLE_IMG, 
  Iushort = USHORT_IMG, 
  Iulong = ULONG_IMG} ImageType;



  typedef std::string String;



  typedef std::multimap<String,CCfits::ExtHDU*> ExtMap;



  typedef ExtMap::const_iterator ExtMapConstIt;



  typedef ExtMap::iterator ExtMapIt;

} // namespace CCfits


#endif