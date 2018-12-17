project(TOY_MT_FRAMEWORK)

cmake_minimum_required(VERSION 3.0)
include(GNUInstallDirs)
set(BASE_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/BuildProducts")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${BASE_OUTPUT_DIRECTORY}/${CMAKE_INSTALL_BINDIR}")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${BASE_OUTPUT_DIRECTORY}/${CMAKE_INSTALL_LIBDIR}")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${BASE_OUTPUT_DIRECTORY}/${CMAKE_INSTALL_LIBDIR}")

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_CURRENT_SOURCE_DIR}/cmake/Modules")
find_package(OpenMP)
find_package(TBB)
include_directories(${TBB_INCLUDE_DIRS})
set(Boost_NO_BOOST_CMAKE ON)
find_package(Boost)
include_directories(${Boost_INCLUDE_DIR})

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++17")

if(EXTBUSYWAIT)
  include(ExternalProject)
  ExternalProject_add(ExtBusyWait
    DEPENDS
    DOWNLOAD_COMMAND
    UPDATE_COMMAND
    CMAKE_ARGS "-DCMAKE_INSTALL_PREFIX=BusyWaitCalibration/install;-DCMAKE_BUILD_TYPE=Release;-DCMAKE_CXX_COMPILER=g++;-DCMAKE_C_COMPILER=gcc"
    SOURCE_DIR ${CMAKE_CURRENT_LIST_DIR}/BusyWaitCalibration
    BINARY_DIR BusyWaitCalibration/build
  )
  add_library(BusyWait SHARED IMPORTED)
  ExternalProject_Get_Property(EXTBUSYWAIT INSTALL_DIR)
  set_property(TARGET ExtBusyWait PROPERTY IMPORTED_LOCATION ${INSTALL_DIR}${CMAKE_INSTALL_LIBDIR}/libBusyWait.so)
  add_dependencies(BusyWait ExtBusyWait)
else()
  add_subdirectory(BusyWaitCalibration)
endif()
add_subdirectory(CommonTestModules)
# nothing ever sets DISPATCH_FOUND (!)
if(DISPATCH_FOUND)
    add_subdirectory(DispatchProcessingDemo)
endif()
add_subdirectory(SingleThreadedProcessingDemo)
if(TBB_FOUND)
    add_subdirectory(TBBProcessingDemo)
endif()
if (OPENMP_FOUND)
    add_subdirectory(OpenMPProcessingDemo)
endif()
