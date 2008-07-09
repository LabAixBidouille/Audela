# SExtractor V2.0
#
# general makefile
#
# E.BERTIN 28/08/1998
#
SEXMACHINE = linuxpc
include ../src/Macrodefs.$(SEXMACHINE)
DEST  = ../../../../../bin
LIBS  = -L. -lwcs_c -lm
SRC   = ../src
ALL   = analyse.o assoc.o astrom.o back.o bpro.o catout.o check.o clean.o \
	extract.o field.o filter.o fitscat.o fitsconv.o fitshead.o fitskey.o \
	fitsmisc.o fitsread.o fitstab.o fitsutil.o fitswrite.o flag.o graph.o \
	growth.o image.o interpolate.o main.o makeit.o manobjlist.o misc.o \
	neurro.o pc.o photom.o plist.o poly.o prefs.o psf.o readimage.o \
	refine.o retina.o scan.o som.o weight.o libwcs_c.a
STDH  = $(SRC)/define.h $(SRC)/globals.h $(SRC)/types.h
STDO  = 

sex: $(ALL)
	$(CC) $(ALL) -o sex $(LIBS) $(COPTS)
	-$(CP) sex $(DEST)/sex

clean:
	$(RM) $(ALL) sex
	$(MAKE) -f Makefile.wcs SEXMACHINE=$(SEXMACHINE) clean

analyse.o: $(STDH) $(STDO) $(SRC)/analyse.c $(SRC)/assoc.h $(SRC)/back.h $(SRC)/check.h $(SRC)/growth.h $(SRC)/image.h \
		$(SRC)/photom.h $(SRC)/plist.h $(SRC)/growth.h $(SRC)/psf.h
	$(CC) $(COPTS) -c $(SRC)/analyse.c

assoc.o: $(STDH) $(STDO) $(SRC)/assoc.c $(SRC)/assoc.h
	$(CC) $(COPTS) -c $(SRC)/assoc.c

astrom.o: $(STDH) $(STDO) $(SRC)/astrom.c $(SRC)/astrom.h
	$(CC) $(COPTS) -c $(SRC)/astrom.c

back.o: $(STDH) $(STDO) $(SRC)/back.c $(SRC)/back.h $(SRC)/field.h
	$(CC) $(COPTS) -c $(SRC)/back.c

bpro.o: $(STDH) $(STDO) $(SRC)/bpro.c $(SRC)/bpro.h $(SRC)/fitscat.h
	$(CC) $(COPTS) -c $(SRC)/bpro.c

catout.o: $(STDH) $(STDO) $(SRC)/catout.c $(SRC)/param.h $(SRC)/sexhead.h $(SRC)/sexhead1.h $(SRC)/sexheadsc.h
	$(CC) $(COPTS) -c $(SRC)/catout.c

check.o: $(STDH) $(STDO) $(SRC)/check.c $(SRC)/check.h
	$(CC) $(COPTS) -c $(SRC)/check.c

clean.o: $(STDH) $(STDO) $(SRC)/clean.c $(SRC)/clean.h $(SRC)/check.h
	$(CC) $(COPTS) -c $(SRC)/clean.c

extract.o: $(STDH) $(STDO) $(SRC)/extract.c $(SRC)/extract.h $(SRC)/plist.h
	$(CC) $(COPTS) -c $(SRC)/extract.c

field.o: $(STDH) $(STDO) $(SRC)/field.c $(SRC)/field.h $(SRC)/interpolate.h
	$(CC) $(COPTS) -c $(SRC)/field.c

filter.o: $(STDH) $(STDO) $(SRC)/filter.c $(SRC)/bpro.h $(SRC)/filter.h $(SRC)/image.h
	$(CC) $(COPTS) -c $(SRC)/filter.c

fitscat.o: $(STDH) $(STDO) $(SRC)/fitscat.c $(SRC)/fitscat_defs.h $(SRC)/fitscat.h
	$(CC) $(COPTS) -c $(SRC)/fitscat.c

fitsconv.o: $(STDH) $(STDO) $(SRC)/fitsconv.c $(SRC)/fitscat_defs.h $(SRC)/fitscat.h
	$(CC) $(COPTS) -c $(SRC)/fitsconv.c

fitshead.o: $(STDH) $(STDO) $(SRC)/fitshead.c $(SRC)/fitscat_defs.h $(SRC)/fitscat.h
	$(CC) $(COPTS) -c $(SRC)/fitshead.c

fitskey.o: $(STDH) $(STDO) $(SRC)/fitskey.c $(SRC)/fitscat_defs.h $(SRC)/fitscat.h
	$(CC) $(COPTS) -c $(SRC)/fitskey.c

fitsmisc.o: $(STDH) $(STDO) $(SRC)/fitsmisc.c $(SRC)/fitscat_defs.h $(SRC)/fitscat.h
	$(CC) $(COPTS) -c $(SRC)/fitsmisc.c

fitsread.o: $(STDH) $(STDO) $(SRC)/fitsread.c $(SRC)/fitscat_defs.h $(SRC)/fitscat.h
	$(CC) $(COPTS) -c $(SRC)/fitsread.c

fitstab.o: $(STDH) $(STDO) $(SRC)/fitstab.c $(SRC)/fitscat_defs.h $(SRC)/fitscat.h
	$(CC) $(COPTS) -c $(SRC)/fitstab.c

fitsutil.o: $(STDH) $(STDO) $(SRC)/fitsutil.c $(SRC)/fitscat_defs.h $(SRC)/fitscat.h
	$(CC) $(COPTS) -c $(SRC)/fitsutil.c

fitswrite.o: $(STDH) $(STDO) $(SRC)/fitswrite.c $(SRC)/fitscat_defs.h $(SRC)/fitscat.h
	$(CC) $(COPTS) -c $(SRC)/fitswrite.c

flag.o: $(STDH) $(STDO) $(SRC)/flag.c $(SRC)/flag.h $(SRC)/plist.h
	$(CC) $(COPTS) -c $(SRC)/flag.c

graph.o: $(STDH) $(STDO) $(SRC)/graph.c
	$(CC) $(COPTS) -c $(SRC)/graph.c

growth.o: $(STDH) $(STDO) $(SRC)/growth.c $(SRC)/growth.h
	$(CC) $(COPTS) -c $(SRC)/growth.c

image.o: $(STDH) $(STDO) $(SRC)/image.c
	$(CC) $(COPTS) -c $(SRC)/image.c

interpolate.o: $(STDH) $(STDO) $(SRC)/interpolate.c $(SRC)/interpolate.h
	$(CC) $(COPTS) -c $(SRC)/interpolate.c

main.o: $(STDH) $(STDO) $(SRC)/main.c
	$(CC) $(COPTS) -c $(SRC)/main.c

makeit.o: $(STDH) $(STDO) $(SRC)/makeit.c $(SRC)/check.h $(SRC)/growth.h $(SRC)/interpolate.h $(SRC)/psf.h \
	$(SRC)/weight.h
	$(CC) $(COPTS) -c $(SRC)/makeit.c

manobjlist.o: $(STDH) $(STDO) $(SRC)/manobjlist.c $(SRC)/plist.h
	$(CC) $(COPTS) -c $(SRC)/manobjlist.c

misc.o: $(STDH) $(STDO) $(SRC)/misc.c
	$(CC) $(COPTS) -c $(SRC)/misc.c

neurro.o: $(STDH) $(STDO) $(SRC)/neurro.c $(SRC)/neurro.h
	$(CC) $(COPTS) -c $(SRC)/neurro.c         

pc.o: $(STDH) $(STDO) $(SRC)/pc.c $(SRC)/image.h $(SRC)/psf.h
	$(CC) $(COPTS) -c $(SRC)/pc.c

photom.o: $(STDH) $(STDO) $(SRC)/photom.c $(SRC)/photom.h
	$(CC) $(COPTS) -c $(SRC)/photom.c

plist.o: $(STDH) $(STDO) $(SRC)/plist.c $(SRC)/plist.h
	$(CC) $(COPTS) -c $(SRC)/plist.c

poly.o: $(STDH) $(STDO) $(SRC)/poly.c $(SRC)/poly.h
	$(CC) $(COPTS) -c $(SRC)/poly.c

prefs.o: $(STDH) $(STDO) $(SRC)/prefs.c $(SRC)/prefs.h
	$(CC) $(COPTS) -c $(SRC)/prefs.c

psf.o: $(STDH) $(STDO) $(SRC)/psf.c $(SRC)/image.h $(SRC)/psf.h
	$(CC) $(COPTS) -c $(SRC)/psf.c

readimage.o: $(STDH) $(STDO) $(SRC)/readimage.c $(SRC)/check.h $(SRC)/interpolate.h $(SRC)/weight.h
	$(CC) $(COPTS) -c $(SRC)/readimage.c

refine.o: $(STDH) $(STDO) $(SRC)/refine.c $(SRC)/extract.h $(SRC)/plist.h
	$(CC) $(COPTS) -c $(SRC)/refine.c

retina.o: $(STDH) $(STDO) $(SRC)/retina.c $(SRC)/image.h $(SRC)/retina.h $(SRC)/fitscat.h
	$(CC) $(COPTS) -c $(SRC)/retina.c

scan.o: $(STDH) $(STDO) $(SRC)/scan.c $(SRC)/check.h $(SRC)/clean.h $(SRC)/extract.h $(SRC)/plist.h
	$(CC) $(COPTS) -c $(SRC)/scan.c

som.o: $(STDH) $(STDO) $(SRC)/som.c $(SRC)/som.h
	$(CC) $(COPTS) -c $(SRC)/som.c

weight.o: $(STDH) $(STDO) $(SRC)/weight.c $(SRC)/weight.h $(SRC)/field.h
	$(CC) $(COPTS) -c $(SRC)/weight.c

libwcs_c.a:
	$(MAKE) -f Makefile.wcs SEXMACHINE=$(SEXMACHINE)

