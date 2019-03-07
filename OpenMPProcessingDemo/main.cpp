#include <iostream>
#include <cassert>
#include <cmath>
#include <boost/property_tree/json_parser.hpp>
#include <sstream>
#include "omp.h"

#include "EventProcessor.h"

#include "SimpleSource.h"
#include "FactoryManager.h"
#include "Producer.h"
#include "Filter.h"

#include "busy_wait_scale_factor.h"
#include <sys/time.h>

#if !defined(__APPLE__)
#include <sys/resource.h>
#endif

#include <errno.h>


int main (int argc, char * const argv[]) {
  
  assert(argc==2);
  boost::property_tree::ptree pConfig; 
  try {
    read_json(argv[1],pConfig);
  } catch(const std::exception& iE) {
    std::cout <<iE.what()<<std::endl;
    exit(1);
  }


  const unsigned int nThreads = pConfig.get<unsigned int>("process.options.nThreads",omp_get_max_threads());
  assert(nThreads == omp_get_thread_limit());

  //if nTopThreads != nThreads then some threads are reserved for nested parallelism
  omp_set_nested(0);
  const unsigned int nTopThreads = pConfig.get<unsigned int>("process.options.nTopThreads",nThreads);
  omp_set_num_threads(nTopThreads);
  if(nThreads != nTopThreads) {
    omp_set_max_active_levels(2);
    omp_set_nested(1);
#ifdef __clang__
    omp_set_dynamic(1);
#else
    omp_set_dynamic(0);
#endif
   }



  //const size_t iterations= 3000;
  const size_t iterations = pConfig.get<size_t>("process.source.iterations");
  //const size_t iterations= 2;
  demo::EventProcessor ep;
  ep.setSource(new demo::SimpleSource( iterations) );
  
  
  busy_wait_scale_factor = pConfig.get<double>("process.options.busyWaitScaleFactor",2.2e+07);
  
  boost::property_tree::ptree& filters=pConfig.get_child("process.filters");
  for(const boost::property_tree::ptree::value_type& f : filters) {
    auto pF = demo::FactoryManager<demo::Filter>::create(f.second.get<std::string>("@type"),f.second);
    std::cout << f.second.get<std::string>("@type")<<" "<<f.second.get<std::string>("@label")<<" "<<std::hex<<pF.get()<<std::dec<<std::endl;
    if(pF.get() != 0) {
      ep.addFilter(pF.release());
    } else {
      assert(0=="Failed creating filter");
      exit(1);
    }
  }

  boost::property_tree::ptree& producers=pConfig.get_child("process.producers");
  for(const boost::property_tree::ptree::value_type& p : producers) {
    auto pP = demo::FactoryManager<demo::Producer>::create(p.second.get<std::string>("@type"),p.second);
    std::cout << p.second.get<std::string>("@type")<<" "<<p.second.get<std::string>("@label")<<" "<<std::hex<<pP.get()<<std::dec<<std::endl;
    if(pP.get() != 0) {
      ep.addProducer(pP.release());
    } else {
      assert(0=="Failed creating filter");
      exit(1);
    }
  }

  
  boost::property_tree::ptree& paths=pConfig.get_child("process.paths");
  for(const boost::property_tree::ptree::value_type& p : paths) {
    std::string n = p.first;
    std::vector<std::string> modules;
    for(const boost::property_tree::ptree::value_type& m: p.second) {
      //std::cout <<m.first<<" - "<<m.second.data()<<std::endl;
      modules.push_back(m.second.data());
    }
    ep.addPath(n,modules);
  }

  {
    struct timeval startCPUTime;
    
    rusage theUsage;
    if(0 != getrusage(RUSAGE_SELF, &theUsage)) {
      std::cerr<<errno;
      return 1;
    }
    startCPUTime.tv_sec =theUsage.ru_stime.tv_sec+theUsage.ru_utime.tv_sec;
    startCPUTime.tv_usec =theUsage.ru_stime.tv_usec+theUsage.ru_utime.tv_usec;

    struct timeval startRealTime;
    gettimeofday(&startRealTime, 0);
    
    //ep.processAll(2);
    unsigned int nEvents = pConfig.get<unsigned int>("process.options.nSimultaneousEvents");
    ep.processAll(nEvents);
    
    struct timeval tp;
    gettimeofday(&tp, 0);

    if(0 != getrusage(RUSAGE_SELF, &theUsage)) {
      std::cerr<<errno;
      return 1;
    }
    
    
    double const microsecToSec = 1E-6;
    
    double cpuTime = theUsage.ru_stime.tv_sec + theUsage.ru_utime.tv_sec - startCPUTime.tv_sec +
    microsecToSec * (theUsage.ru_stime.tv_usec + theUsage.ru_utime.tv_usec - startCPUTime.tv_usec);
   
    double realTime = tp.tv_sec - startRealTime.tv_sec + microsecToSec * (tp.tv_usec - startRealTime.tv_usec);
    std::cout <<"OMP:# threads:"<<nThreads<<" # top threads:"<<nTopThreads<<" # simultaneous events:"<<nEvents<<" total # events:"<<iterations<<" cpu time:" << cpuTime<<" real time:"<<realTime<<" events/sec:"<<iterations/realTime<<std::endl;
  }

  return 0;
}
