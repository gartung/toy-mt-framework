#!/bin/bash

declare -i stepsize
stepsize=64
declare -i nsteps
nsteps=256
declare -i iterations
iterations=100
declare -i ncore
ncore=8
declare -i nSimulEvt
nSimulEvt=1
declare -i nThreads
nThreads=1
declare -i busyWaitScaleFactor
busyWaitScaleFactor=9700000

sed -e "s/\$iterations/$iterations/" -e "s/\$nSimulEvt/$nSimulEvt/" -e "s/\$nThreads/$nThreads/" -e "s/\$busyWaitScaleFactor/$busyWaitScaleFactor/"  reco_hipileup_5_2_0_busywait_perfectIO.config.tt >reco_hipileup_5_2_0_busywait_perfectIO.${nSimulEvt}s.${nThreads}t.${iterations}i.config

echo "#" >driver-busywait-single.sh
for ((x=32;x<=256;x+=32)); do
    echo $x
    echo "qsub -q knl -l nodes=1:knl,walltime=12:00:00 -A CMS-MT-Tests ~/toy-mt-framework/cms-data/driver-busywait-${x}.sh" >>driver-busywait-single.sh
    
    echo "#!/bin/bash" >driver-busywait-${x}.sh
    echo "source /opt/intel/parallel_studio_xe_2016.3.067/psxevars.sh intel64">>driver-busywait-${x}.sh
    echo "numactl -m 1" >> driver-busywait-${x}.sh
    echo "export export KMP_PLACE_THREADS=1s,64c,4t" >> driver-busywait-${x}.sh

for ((y=1;y<=$x;y+=1));do
    echo "~/build/BuildProducts/bin/TBBDemo ~/toy-mt-framework/cms-data/reco_hipileup_5_2_0_busywait_perfectIO.${nSimulEvt}s.${nThreads}t.${iterations}i.config > job-${x}-${y}.log.txt 2>&1&">>driver-busywait-$x.sh
    done
echo "wait">>driver-busywait-$x.sh
done
