#Change this to point to your boost installation
BOOST_INCLUDES := -I/home/gartung/products/boost/v1_57_0a/Linux64bit+2.6-2.12-e9-prof/include

CPPUNIT_INCLUDES := -I/home/gartung/products/cppunit/v1_12_1c/Linux64bit+2.6-2.12-e9-prof/include
CPPUNIT_LIB_PATH := -L/home/gartung/products/cppunit/v1_12_1c/Linux64bit+2.6-2.12-e9-prof/lib
CPPUNIT_LIB := $(CPPUNIT_LIB_PATH) -lcppunit

#change the following to to point to where you installed tbb

TBB_INCLUDES := -I/home/gartung/products/tbb/v4_4_3/Linux64bit+2.6-2.12-e9-prof/include
TBB_LIB_PATH := -L/home/gartung/products/tbb/v4_4_3/Linux64bit+2.6-2.12-e9-prof/lib

CXXOTHERFLAGS := -D__USE_XOPEN2K8

TBB_LIB := $(TBB_LIB_PATH) -ltbb

CXX=g++
CPPFLAGS=$(TBB_INCLUDES) $(BOOST_INCLUDES) $(CPPUNIT_INCLUDES) -ITBBFrameworkCore/ -I../BusyWaitCalibration/
CXXFLAGS=-g -std=c++14 -fPIC -pthread $(CXXOTHERFLAGS)
LDFLAGS= -std=c++14 -pthread
LINKER=g++

all: libTBBFrameworkCore.so libTBBTestModules.so TBBDemo

TBBDemo: libTBBFrameworkCore.so libTBBTestModules.so main.o
	$(LINKER) $+ $(LDFLAGS) $(TBB_LIB) -o $@

fc_objects := $(patsubst %.cpp,%.o,$(wildcard TBBFrameworkCore/*.cpp))
tm_objects := $(patsubst %.cpp,%.o,$(wildcard TBBTestModules/*.cpp))
unittest_objects := $(patsubst %.cpp,%.o,$(wildcard TBBUnitTests/*.cpp))

libTBBFrameworkCore.so: $(fc_objects)
	$(LINKER) $+ $(TBB_LIB) -shared -o $@

libTBBTestModules.so: $(tm_objects) ../BusyWaitCalibration/busyWait.o ../BusyWaitCalibration/busy_wait_scale_factor.o libTBBFrameworkCore.so
	$(LINKER) $+ -shared -o $@

TBBRunUnitTests: $(unittest_objects) libTBBFrameworkCore.so
	$(LINKER) $+ $(LDFLAGS) $(TBB_LIB) $(CPPUNIT_LIB) -o $@

clean:
	rm -f *.o */*.o *.so
	rm -f TBBDemo
	rm -f $(fc_objects)
	rm -f $(tm_objects)
