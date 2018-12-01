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

moduleRelations = defaultdict(list)
moduleConsumes = defaultdict(list)
moduleTimings = defaultdict(list)
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
#            print "process '%s' modules:" % processName
            moduleRelations[processName]=list()
        if consumes.match(l):
            processName = values[1].replace("'","")
#            print "process '%s' consumes:" % processName
            moduleConsumes[processName]=list()
    if fourspace.match(l):
        if len(values) == 7:
            if not values[-2] == 'reRECO':
                moduleConsumes[processName].append(values[1])
#                print "\t%s" % values
        if len(values) == 3:
            if values[0].endswith('/'):
                moduleRelations[processName].append(values[1])
#                print "\t%s" % values

            
with open('module-storage2get.yaml', 'w') as outfile:
   outfile.write(yaml.dump(moduleConsumes, default_flow_style=True))

with open('module-relations.yaml', 'w') as outfile:
   outfile.write(yaml.dump(moduleRelations, default_flow_style=True))

with open('module-timings.yaml', 'r') as infile:
    moduleTimings=yaml.load(infile)

#with open('module-storage2get.yaml', 'r') as infile:
#    moduleConsumes=yaml.load(infile)
#
#with open('module-relations.yaml', 'r') as infile:
#    moduleRelations=yaml.load(infile)
#

storageToGet=set()
for mod,consumes in moduleConsumes.items():
    for c in consumes:
        storageToGet.add(c)

nEvents="100"
recotimes=moduleTimings['RECOoutput']

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
       "eventTimes": recotimes[50:150],
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

#add producers
producers = config["process"]["producers"]
for mod,dependents in moduleRelations.items():
    time = moduleTimings.get(mod,[0.])
    if len(time) == 200:
        toGet = list()
        for d in dependents:
            toGet.append({"label":d, "product":""})
        c = { "@label" : mod,
          "@type" : "demo::EventTimesBusyWaitProducer",
          "threadType" : "ThreadSafeBetweenInstances",
          "eventTimes":time[50:150],
          "toGet" :toGet
        }
        producers.append(c)



with open('config.yaml', 'w') as outfile:
   outfile.write(yaml.dump(config, default_flow_style=True))

import pprint
import StringIO
output = StringIO.StringIO()
#pp = pprint.PrettyPrinter(indent=3)
pprint.pprint(config,stream=output)

#have to convert single quotes to double quotes
configString = output.getvalue()
configString = configString.replace("'",'"')

print configString


