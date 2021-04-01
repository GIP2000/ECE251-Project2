# Makefile MINE

.PHONY: clean

all: ./sorter.out

sorter.out: sorter.S
	 arm-linux-gnueabi-gcc $< -o $@ -ggdb3 -static

clean:
	rm -f sorter.out
	rm -f output.txt 

