#!/bin/bash

declare -i stepsize
stepsize=100
declare -i nsteps
nsteps=16
declare -i iterations
iterations=100
declare -i ncore
ncore=4
declare -i nSimulEvt
nSimulEvt=ncore
declare -i nThreads
nThreads=64
declare -i busyWaitScaleFactor
busyWaitScaleFactor=2080000

echo "#!/bin/sh" >runjob-driver.sh

for ((x=1;x<=${nsteps};x+=1)); do
echo $x
echo qsub -n 32 --mode c1  -t 120 --env LD_LIBRARY_PATH=/soft/compilers/gcc/4.8.4/lib/gcc/powerpc64-bgq-linux/4.8.4/:/soft/compilers/gcc/4.8.4/lib/gcc/:/soft/compilers/gcc/4.8.4/lib/gcc/powerpc64-bgq-linux/4.8.4/../../../../powerpc64-bgq-linux/lib/:\$LD_LIBRARY_PATH ~/altbuild/BuildProducts/bin/TBBDemo ~/toy-mt-framework/cms-data/reco_hipileup_5_2_0_busywait_perfectIO.${nSimulEvt}s.${nThreads}t.${iterations}i.config >>driver-$nsteps.sh
echo runjob -n 32 -p1  --block \$COBALT_PARTNAME --verbose=DEBUG --envs LD_LIBRARY_PATH=/soft/compilers/gcc/4.8.4/lib/gcc/powerpc64-bgq-linux/4.8.4/:/soft/compilers/gcc/4.8.4/lib/gcc/:/soft/compilers/gcc/4.8.4/lib/gcc/powerpc64-bgq-linux/4.8.4/../../../../powerpc64-bgq-linux/lib/:\$LD_LIBRARY_PATH --exe ~/altbuild/BuildProducts/bin/TBBDemo --args ~/toy-mt-framework/cms-data/reco_hipileup_5_2_0_busywait_perfectIO.${nSimulEvt}s.${nThreads}t.${iterations}i.config >>runjob-driver-${nsteps}.sh
iterations+=${stepsize}
nSimulEvt+=${ncore}
#nThreads+=${ncore}
done
