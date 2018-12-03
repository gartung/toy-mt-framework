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
tickspace=re.compile("' '")

for l in f:
    if twospace.match(l):
        fields=tickspace.split(l)
        if modules.match(l):
            values = fields[0].split("'")
            processName = values[-2]
            moduleRelations[processName]=list()
        if consumes.match(l):
            values = fields[0].split("'")
            processName = values[-2]
            moduleConsumes[processName]=list()
    if fourspace.match(l):
        fields=tickspace.split(l)
        if len(fields) == 3:
            if not fields[-1] == "RECO'\n":
                labels=fields[0].split("'")
                if not labels[-1] == '@EmptyLabel@':
                    moduleConsumes[processName].append(labels[-1])
        if len(fields) == 1:
            labels=fields[0].split("'")
            if len(labels) > 1:
                if not labels[-2] == '':
                    moduleRelations[processName].append(labels[-2])

            
#with open('module-storage2get.yaml', 'w') as outfile:
#   outfile.write(yaml.dump(moduleConsumes, default_flow_style=True))

#with open('module-relations.yaml', 'w') as outfile:
#   outfile.write(yaml.dump(moduleRelations, default_flow_style=True))

with open('module-timings.yaml', 'r') as infile:
    moduleTimings=yaml.load(infile)

#with open('module-storage2get.yaml', 'r') as infile:
#    moduleConsumes=yaml.load(infile)
#
#with open('module-relations.yaml', 'r') as infile:
#    moduleRelations=yaml.load(infile)
#

storageToGet=list()
for mod,consumes in moduleConsumes.items():
    storageToGet.append({"label":mod, "product":consumes})
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
       "@type" : "demo::EventTimesBusyWaitPassFilter",
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


