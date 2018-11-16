#!/bin/env python
import sys
import yaml
import re 
from collections import defaultdict

import pprint
import StringIO

if len(sys.argv) != 2:
    print "requires input with module relations from tracer log"
    sys.exit(1)

f = file(sys.argv[1])
if not f:
    print "unable to open file %s",sys.argv[1]

moduleRelations = defaultdict(set)
moduleConsumes = defaultdict(set)
processName = None
twospace=re.compile('^  \D*')
fourspace=re.compile('^    \D*')
modules=re.compile('.*modules:$')
consumes=re.compile('.*consumes:$')

for l in f:
    values = l.split("'")
    if twospace.match(l):
        if modules.match(l):
            processName = values[1].replace("'","")
            print "process: %s consumes the product output from modules" % processName
            moduleRelations[processName]=set()
        if consumes.match(l):
            processName = values[1].replace("'","")
            print "process: %s consumes products with labels" % processName
            moduleConsumes[processName]=set()
    if fourspace.match(l):
        if len(values) == 7:
            if not values[-2] == 'reRECO':
                moduleConsumes[processName].add(values[1])
        if len(values) == 3:
            if values[0].endswith('/'):
                moduleRelations[processName].add(values[1])

print moduleRelations
print moduleConsumes    
            
with open('module-consumes.yaml', 'w') as outfile:
   outfile.write(yaml.dump(moduleConsumes, default_flow_style=True))

with open('module-relations.yaml', 'w') as outfile:
   outfile.write(yaml.dump(moduleRelations, default_flow_style=True))

with open('module-timings.yaml', 'r') as infile:
    moduleTimings=yaml.load(infile)

nEvents="100"
storageToGet=""

config = {
 "process" :
 {
   "label" : "TEST",
   "options" :
   {
     "nSimultaneousEvents" : 1,
     "busyWaitScaleFactor" : 2.2e+07
   },
   "source" :
   {
     "@type" : "demo::SimpleSource",
     "iterations" : nEvents
   },
   "filters" :
   [
     { "@label" : "output",
       "@type" : "demo::EventTimesSleepingPassFilter",
       "threadType" : "ThreadSafeBetweenModules",
       "eventTimes": moduleTimings['RECOoutput'],
       "toGet" : storageToGet
     }
   ],
   "producers" :
   [
   ],
   "paths" :
   {
     "o":
      [ "output"]
   }
 }
}



