//   Read the documentation to learn more about C++ code generator
//   versioning.
//	This is version 2.0 release dated Jan 2008
//	Astrophysics Science Division,
//	NASA/ Goddard Space Flight Center
//	HEASARC
//	http://heasarc.gsfc.nasa.gov
//	e-mail: ccfits@legacy.gsfc.nasa.gov
//
//	Original author: Ben Dorman

#ifndef FITSBASE_H
#define FITSBASE_H 1

// map
#include <map>
// fitsio
#include "fitsio.h"
// string
#include <string>
// CCfitsHeader
#include "CCfits.h"

namespace CCfits {
  class PHDU;
  class ExtHDU;

} // namespace CCfits
using std::string;


namespace CCfits {



  class FITSBase 
  {

    public:
        FITSBase (const String& fileName, RWmode rwmode);
        ~FITSBase();

        void destroyPrimary ();
        void destroyExtensions ();
        int currentCompressionTileDim () const;
        void currentCompressionTileDim (int value);
        RWmode mode ();
        std::string& currentExtensionName ();
        std::string& name ();
        PHDU*& pHDU ();
        ExtMap& extension ();
        fitsfile*& fptr ();

      // Additional Public Declarations

    protected:
      // Additional Protected Declarations

    private:
        FITSBase(const FITSBase &right);
        FITSBase & operator=(const FITSBase &right);

      // Additional Private Declarations

    private: //## implementation
      // Data Members for Class Attributes
        int m_currentCompressionTileDim;

      // Data Members for Associations
        RWmode m_mode;
        std::string m_currentExtensionName;
        std::string m_name;
        PHDU* m_pHDU;
        ExtMap m_extension;
        fitsfile* m_fptr;

      // Additional Implementation Declarations

  };

  // Class CCfits::FITSBase 

  inline int FITSBase::currentCompressionTileDim () const
  {
    return m_currentCompressionTileDim;
  }

  inline void FITSBase::currentCompressionTileDim (int value)
  {
    m_currentCompressionTileDim = value;
  }

  inline RWmode FITSBase::mode ()
  {
    return m_mode;
  }

  inline std::string& FITSBase::currentExtensionName ()
  {
    return m_currentExtensionName;
  }

  inline std::string& FITSBase::name ()
  {
    return m_name;
  }

  inline PHDU*& FITSBase::pHDU ()
  {
    return m_pHDU;
  }

  inline ExtMap& FITSBase::extension ()
  {
    return m_extension;
  }

  inline fitsfile*& FITSBase::fptr ()
  {
    return m_fptr;
  }

} // namespace CCfits


#endif
