.PHONY: build install clean

DIR = gsl-1.4

build:
	( cd $(DIR) ; ./configure --prefix=`pwd`/../.. )
	make -C $(DIR)

install:
	make -C $(DIR) install

clean:
	make -C $(DIR) clean

