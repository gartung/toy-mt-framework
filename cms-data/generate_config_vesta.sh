#!/bin/bash
declare -i stepsize
stepsize=100
declare -i nsteps
nsteps=20
declare -i iterations
iterations=100
declare -i nSimulEvt
nSimulEvt=1
declare -i nThreads
nThreads=1
declare -i busyWaitScaleFactor
busyWaitScaleFactor=2080000

echo "#!/bin/bash" > driver.sh
echo "#!/bin/bash" > runjob-driver.sh

for ((x=4;x<=64;x+=4)); do
    echo $x
    nSimulEvt=$x
    nThreads=64
    iterations=$x*$stepsize
    sed -e "s/\$iterations/$iterations/" -e "s/\$nSimulEvt/$nSimulEvt/" -e "s/\$nThreads/$nThreads/" -e "s/\$busyWaitScaleFactor/$busyWaitScaleFactor/"  reco_hipileup_5_2_0_sleeping_perfectIO.config.tt >reco_hipileup_5_2_0_sleeping_perfectIO.${nSimulEvt}s.${nThreads}t.${iterations}i.config
    echo qsub -n 2 --mode=c1 -t 120 -O sleeping_perfectIO.${nSimulEvt}s.${nThreads}t.${iterations}i.log --env LD_LIBRARY_PATH=/soft/compilers/gcc/4.8.4/lib/gcc/powerpc64-bgq-linux/4.8.4/:/soft/compilers/gcc/4.8.4/lib/gcc/:/soft/compilers/gcc/4.8.4/lib/gcc/powerpc64-bgq-linux/4.8.4/../../../../powerpc64-bgq-linux/lib/:\$LD_LIBRARY_PATH ~/altbuild/BuildProducts/bin/TBBDemo ~/toy-mt-framework/cms-data/reco_hipileup_5_2_0_sleeping_perfectIO.${nSimulEvt}s.${nThreads}t.${iterations}i.config >>driver.sh 
    echo runjob -n 2 -p1  --block \$COBALT_PARTNAME --verbose=DEBUG --env LD_LIBRARY_PATH=/soft/compilers/gcc/4.8.4/lib/gcc/powerpc64-bgq-linux/4.8.4/:/soft/compilers/gcc/4.8.4/lib/gcc/:/soft/compilers/gcc/4.8.4/lib/gcc/powerpc64-bgq-linux/4.8.4/../../../../powerpc64-bgq-linux/lib/:\$LD_LIBRARY_PATH --exe ~/altbuild/BuildProducts/bin/TBBDemo --args ~/toy-mt-framework/cms-data/reco_hipileup_5_2_0_sleeping_perfectIO.${nSimulEvt}s.${nThreads}t.${iterations}i.config >>runjob-driver.sh
done
