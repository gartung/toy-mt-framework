#!/bin/bash

declare -i stepsize
stepsize=64
declare -i nsteps
nsteps=32
declare -i iterations
iterations=300
declare -i ncore
ncore=64
declare -i nSimulEvt
nSimulEvt=1
declare -i nThreads
nThreads=1
#nThreads=64
busyWaitScaleFactor=5000000


nSimulEvtP=`printf "%02d" $nSimulEvt`
nThreadsP=`printf "%02d" $nThreads`

sed -e "s/\$iterations/$iterations/" -e "s/\$nSimulEvt/$nSimulEvt/" -e "s/\$nThreads/$nThreads/" -e "s/\$busyWaitScaleFactor/$busyWaitScaleFactor/"  reco_hipileup_5_2_0_busywait_perfectIO.config.tt >reco_hipileup_5_2_0_busywait_perfectIO.${nSimulEvtP}s.${nThreadsP}t.${iterations}i.config

echo "#" >srun-driver-busywait.sh
for ((x=4;x<=48;x+=4)); do
echo ${x}
echo "sbatch -N1 srun-driver-busywait-${x}.sh">>srun-driver-busywait.sh
echo "#!/bin/bash -l ">srun-driver-busywait-${x}.sh
echo "#SBATCH -p debug ">>srun-driver-busywait-${x}.sh
echo "#SBATCH --nodes=1  ">>srun-driver-busywait-${x}.sh
echo "#SBATCH --cpus-per-task=48 ">>srun-driver-busywait-${x}.sh
echo "#SBATCH --exclusive ">>srun-driver-busywait-${x}.sh
echo "#SBATCH --ntasks-per-node=1 ">>srun-driver-busywait-${x}.sh
echo "#SBATCH -t 00:30:00  ">>srun-driver-busywait-${x}.sh
echo "#SBATCH -J reco_hipileup_busywait_perfectIO_Nsingle">>srun-driver-busywait-${x}.sh
echo "#SBATCH -L SCRATCH ">>srun-driver-busywait-${x}.sh
echo "module swap PrgEnv-intel PrgEnv-gnu">>srun-driver-busywait-${x}.sh
for ((y=1;y<=$x;y+=1));do
echo "/global/homes/g/gartung/build/BuildProducts/bin/TBBDemo /global/homes/g/gartung/toy-mt-framework/cms-data/reco_hipileup_5_2_0_busywait_perfectIO.${nSimulEvtP}s.${nThreadsP}t.${iterations}i.config & " >>srun-driver-busywait-${x}.sh
done
echo wait >>srun-driver-busywait-${x}.sh
done
