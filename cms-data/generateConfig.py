#!/bin/env python
import sys
import yaml
import re 
from collections import defaultdict
import json

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
module2space=re.compile("^\s\s(\S*)/'(\S*)'\n")
module4space=re.compile("^\s\s\s\s(\S*)/'(\S*)'\n")
fourspace=re.compile("^\s\s\s\s(\S*)\s'(\S*)'\s'(|\S*)'\s'(|\S*)'")
modules=re.compile("^\s\s(\S*)/'(\S*)' consumes products from these modules:$")
consumes=re.compile("^\s\s(\S*)/'(\S*)' consumes:$")
tickspace=re.compile("' '")

for l in f:
    if module4space.match(l):
        print 'labels: ',re.match(module4space,l).groups()
        labels=re.match(module4space,l).groups()
        if len(labels) > 1:
            if not labels[1] == '':
                moduleRelations[processName].append(labels[1])
    if module2space.match(l):
        values=re.match(module2space,l).groups()
        print values, 'has no consumes:'
        processName = values[1]
        moduleRelations[processName]=list()
        moduleConsumes[processName]=list()
    if modules.match(l):
        values = re.match(modules,l).groups()
        print values,'consumes products from these modules: '
        processName = values[1]
        moduleRelations[processName]=list()
    if consumes.match(l):
        values = re.match(consumes,l).groups()
        print values, 'consumes: '
        processName = values[1]
        moduleConsumes[processName]=list()
    if fourspace.match(l):
        fields=re.match(fourspace,l).groups()
        print 'fields: ', fields
        if not fields[-1] == "RECO":
            if not fields[1] == '@EmptyLabel@':
                print 'fields2: ',fields
                moduleConsumes[processName].append(fields[1])

            
with open('module-storage2get.json', 'w') as outfile:
   outfile.write(json.dumps(moduleConsumes, indent=4))

with open('module-relations.json', 'w') as outfile:
   outfile.write(json.dumps(moduleRelations, indent=4))

with open('module-timings.json', 'r') as infile:
    moduleTimings=json.load(infile)

modconsumes=list()
for mod,consumes in moduleConsumes.items():
    modconsumes.append({"label":mod, "product":""})
#storageToGet=list(consumes for mod,consumes in enumerate(modconsumes) if consumes not in modconsumes[:mod])
storageToGet=modconsumes

nEvents="100"
eventTimes = moduleTimings['RECOoutput']

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
       "@type" : "demo::EventTimesBusyWaitPassFilter",
       "threadType" : "ThreadSafeBetweenModules",
       "eventTimes": eventTimes[50:150],
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
    eventTimes = moduleTimings.get(mod,[0.]*200)
    toGet = list()
    for d in dependents:
        toGet.append({"label":d, "product":""})
    c = { "@label" : mod,
      "@type" : "demo::EventTimesBusyWaitProducer",
      "threadType" : "ThreadSafeBetweenInstances",
      "eventTimes":eventTimes[50:150],
      "toGet" :toGet
    }
    producers.append(c)


with open('config.json','w') as outfile:
    outfile.write(json.dumps(config,indent=3))

