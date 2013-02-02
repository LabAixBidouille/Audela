.PHONY: build install clean

DIR = gsl-1.8

build:
	( cd $(DIR) ; ./configure --prefix=`pwd`/../.. )
	make -C $(DIR)

install:
	make -C $(DIR) install

clean:
	make -C $(DIR) clean

