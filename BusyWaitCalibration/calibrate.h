#include <iostream>
#if defined(__APPLE__)
#include <time.h>
#else
#include <sys/time.h>
#include <sys/resource.h>
#endif
#include "busyWait.h"
#include <errno.h>

static double calibrate(unsigned long long iLoop)
{
  struct timeval startCPUTime;

  rusage theUsage;
  if(0 != getrusage(RUSAGE_SELF, &theUsage)) {
    std::cerr<<errno;
    return 1;
  }
  startCPUTime.tv_sec =theUsage.ru_stime.tv_sec+theUsage.ru_utime.tv_sec;
  startCPUTime.tv_usec =theUsage.ru_stime.tv_usec+theUsage.ru_utime.tv_usec;

  std::cout << demo::busyWait(iLoop)<<std::endl;

  if(0 != getrusage(RUSAGE_SELF, &theUsage)) {
    std::cerr<<errno;
    return 1;
  }


  double const microsecToSec = 1E-6;

  double time = theUsage.ru_stime.tv_sec + theUsage.ru_utime.tv_sec - startCPUTime.tv_sec +
  microsecToSec * (theUsage.ru_stime.tv_usec + theUsage.ru_utime.tv_usec - startCPUTime.tv_usec);

  std::cout <<iLoop<<" " << time<<" "<<iLoop/time<<std::endl;

  return time;
}

