/*

  sysexp.h

  This file is part of the Ethernaude Driver.

  Copyright (C)2000-2005, Michel MEUNIER <michel.meunier10@tiscali.fr>
  All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions
  are met:

        Redistributions of source code must retain the above copyright
        notice, this list of conditions and the following disclaimer.

        Redistributions in binary form must reproduce the above
        copyright notice, this list of conditions and the following
        disclaimer in the documentation and/or other materials
        provided with the distribution.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
  ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
  FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
  REGENTS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
  BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
  LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
  ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
  POSSIBILITY OF SUCH DAMAGE.

*/

#ifndef __SYSEXPH__
#define __SYSEXPH__

/* --- definition de l'operating systeme (OS) employe pour compiler    ---*/

#define OS_UNK
/*
#define OS_UNI
#undef OS_UNK
#define OS_LIN
*/

#if defined(_Windows)
   /* Borland */
#define OS_WIN
#undef OS_UNK
#define OS_WIN_BORL_DLL
#elif defined(_MSC_VER)
   /* Visual C++ */
#define OS_WIN
#undef OS_UNK
#define OS_WIN_VCPP_DLL
#elif defined(__linux__)
   /* gcc Linux */
#define OS_UNI
#undef OS_UNK
#define OS_LIN
#elif defined(__MACH__) && defined(__APPLE__)
   /* gcc Mac */
#define OS_UNI
#undef OS_UNK
#define OS_LIN
#define OS_MAC
#elif defined(__WIN32__)
   /* Autres Windows */
#define OS_WIN
#undef OS_UNK
#endif


#endif
