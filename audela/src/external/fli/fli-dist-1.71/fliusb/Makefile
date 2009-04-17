obj-m		:= fliusb.o

KDIR		?= /lib/modules/$(shell uname -r)/build
PWD		:= $(shell pwd)

CFLAGS		+= -O2 -Wall

#CFLAGS		+= -DDEBUG	# enable debug messages
#CFLAGS		+= -DASYNCWRITE	# enable asynchronous writes
CFLAGS		+= -DSGREAD	# enable scatter-gather reads

all: module cleanup

module:
	$(MAKE) -C $(KDIR) SUBDIRS=$(PWD) modules

cleanup:
	rm -f *.o .*.cmd *.mod.c; rm -rf .tmp_versions

clean: cleanup
	rm -f *.ko test
