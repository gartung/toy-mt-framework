#Change this to point to your boost installation
BOOST_INCLUDES := -I/cvmfs/cms.cern.ch/slc6_amd64_gcc530/external/boost/1.57.0-ikhhed/include
#BOOST_INCLUDES := -I/uscms_data/d2/cdj/build/multicore/dispatch/install/include
#BOOST_INCLUDES := -I/uscms_data/d2/cdj/build/multicore/openmp/install/include
CPPFLAGS=$(BOOST_INCLUDES) -IOpenMPFrameworkCore/ -I../BusyWaitCalibration/ -DPARALLEL_MODULES
CXXFLAGS=-O3 -g -std=c++14 -fopenmp -fPIC
LDFLAGS= -std=c++14
LINKER=g++ -std=c++14 -fopenmp

all: libOpenMPFrameworkCore.so libOpenMPTestModules.so OpenMPDemo

OpenMPDemo: libOpenMPFrameworkCore.so libOpenMPTestModules.so main.o
	$(LINKER) $+ $(LDFLAGS) -o $@

fc_objects := $(patsubst %.cpp,%.o,$(wildcard OpenMPFrameworkCore/*.cpp))
tm_objects := $(patsubst %.cpp,%.o,$(wildcard OpenMPTestModules/*.cpp))

libOpenMPFrameworkCore.so: $(fc_objects)
	$(LINKER) $+ -shared -o $@

libOpenMPTestModules.so: $(tm_objects) ../BusyWaitCalibration/busyWait.o ../BusyWaitCalibration/busy_wait_scale_factor.o libOpenMPFrameworkCore.so
	$(LINKER) $+ -shared -o $@

clean:
	rm -f *.o */*.o *.so
	rm -f OpenMPDemo
	rm -f $(fc_objects)
	rm -f $(tm_objects)