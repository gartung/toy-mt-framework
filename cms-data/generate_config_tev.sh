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

echo "#!/bin/sh" >driver-busywait.sh

scale=1.25

for ((x=16;x<=256;x+=16)); do
    nSimulEvt=${x}
    nThreads=`echo "($scale * $nSimulEvt)/1" | bc `
    iterations=` echo "($nSimulEvt * $stepsize )/1" | bc `
    nThreadsP=`printf "%03d\n" $nThreads`
    echo $nThreadsP
    nSimulEvtP=`printf "%03d\n" $nSimulEvt`
    echo $nSimulEvtP
    iterationsP=`printf "%05d\n" $iterations`
    echo "qsub -q knl -l nodes=1:knl,walltime=12:00:00 -A CMS-MT-Tests ~/toy-mt-framework/cms-data/driver-busywait-${nSimulEvtP}s-${nThreadsP}t-${iterationsP}i.sh" >>driver-busywait.sh
    echo "#!/bin/bash" >driver-busywait-${nSimulEvtP}s-${nThreadsP}t-${iterationsP}i.sh
    echo "source /opt/intel/parallel_studio_xe_2016.3.067/psxevars.sh intel64" >>driver-busywait-${nSimulEvtP}s-${nThreadsP}t-${iterationsP}i.sh
#    echo "numactl -m 1" >> driver-busywait-${nSimulEvtP}s-${nThreadsP}t-${iterations}i.sh
#    echo "export export KMP_PLACE_THREADS=1s,64c,4t" >> driver-busywait-${nSimulEvtP}s-${nThreadsP}t-${iterations}i.sh
    echo "~/build/BuildProducts/bin/TBBDemo ~/toy-mt-framework/cms-data/reco_hipileup_5_2_0_busywait_perfectIO.${nSimulEvtP}s.${nThreadsP}t.${iterationsP}i.config > busywait-${iterationsP}i-${nSimulEvtP}s-${nThreadsP}t.log.txt 2>&1  ">>driver-busywait-${nSimulEvtP}s-${nThreadsP}t-${iterationsP}i.sh

    sed -e "s/\$iterations/$iterations/" -e "s/\$nSimulEvt/$nSimulEvt/" -e "s/\$nThreads/$nThreads/" -e "s/\$busyWaitScaleFactor/$busyWaitScaleFactor/"  reco_hipileup_5_2_0_busywait_perfectIO.config.tt >reco_hipileup_5_2_0_busywait_perfectIO.${nSimulEvtP}s.${nThreadsP}t.${iterationsP}i.config

done
