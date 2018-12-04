#!/bin/bash

declare -i stepsize
stepsize=100
declare -i nsteps
nsteps=256
declare -i iterations
iterations=100
declare -i ncore
ncore=8
declare -i nSimulEvt
nSimulEvt=0
declare -i nThreads
nThreads=0
declare -i busyWaitScaleFactor
busyWaitScaleFactor=9700000

echo "#!/bin/sh" >driver-sleeping.sh



for ((x=256;x<=4096;x+=256)); do
    nSimulEvt=${x}
    iterations=${x}*${stepsize}
    iterationsP=`printf "%05d\n" $iterations`
    nSimulEvtP=`printf "%03d\n" $nSimulEvt`
    echo $nSimulEvtP
    scale=1.5
    nThreads=`echo "($scale * $nSimulEvt)/1" | bc`
    nThreadsP=`printf "%03d\n" $nThreads`
    echo $nThreadsP
    echo "qsub -q knl -l nodes=1:knl,walltime=12:00:00 -A CMS-MT-Tests ~/toy-mt-framework/cms-data/driver-sleeping-${nSimulEvtP}s-${nThreadsP}t.sh" >>driver-sleeping.sh

    echo "#!/bin/bash" >driver-sleeping-${nSimulEvtP}s-${nThreadsP}t.sh
    echo "source /opt/intel/parallel_studio_xe_2016.3.067/psxevars.sh intel64" >>driver-sleeping-${nSimulEvtP}s-${nThreadsP}t.sh
    echo "~/build/BuildProducts/bin/TBBDemo ~/toy-mt-framework/cms-data/reco_hipileup_5_2_0_sleeping_perfectIO.${nSimulEvtP}s.${nThreadsP}t.${iterationsP}i.config > sleeping-${iterationsP}i-${nSimulEvtP}s-${nThreadsP}t.log.txt 2>&1  ">>driver-sleeping-${nSimulEvtP}s-${nThreadsP}t.sh
    sed -e "s/\$iterations/$iterations/" -e "s/\$nSimulEvt/$nSimulEvt/" -e "s/\$nThreads/$nThreads/" -e "s/\$busyWaitScaleFactor/$busyWaitScaleFactor/"  reco_hipileup_5_2_0_sleeping_perfectIO.config.tt >reco_hipileup_5_2_0_sleeping_perfectIO.${nSimulEvtP}s.${nThreadsP}t.${iterationsP}i.config

done