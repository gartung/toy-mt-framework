CXX=g++
CPPFLAGS=-I.
CXXFLAGS=-O3 -g -std=c++14 -fPIC
LDFLAGS= -std=c++14
LINKER=g++

all: BusyWaitCalibrate

BusyWaitCalibrate: main.o busy_wait_scale_factor.o busyWait.o
	$(LINKER) $+ -o $@

clean:
	rm -f *.o
	rm -f BusyWaitCalibrate
