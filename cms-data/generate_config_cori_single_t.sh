#!/bin/bash

declare -i stepsize
stepsize=64
declare -i nsteps
nsteps=32
declare -i iterations
iterations=100
declare -i ncore
ncore=64
declare -i nSimulEvt
nSimulEvt=1
declare -i nThreads
nThreads=1
#nThreads=64
busyWaitScaleFactor=25000000


nSimulEvtP=`printf "%02d" $nSimulEvt`
nThreadsP=`printf "%02d" $nThreads`

sed -e "s/\$iterations/$iterations/" -e "s/\$nSimulEvt/$nSimulEvt/" -e "s/\$nThreads/$nThreads/" -e "s/\$busyWaitScaleFactor/$busyWaitScaleFactor/"  reco_hipileup_5_2_0_sleeping_perfectIO.config.tt >reco_hipileup_5_2_0_sleeping_perfectIO.${nSimulEvtP}s.${nThreadsP}t.${iterations}i.config

echo "#" >srun-driver-sleeping.sh
for ((x=4;x<=48;x+=4)); do
echo ${x}
echo "sbatch -N1 srun-driver-sleeping-${x}.sh">>srun-driver-sleeping.sh
echo "#!/bin/bash -l ">srun-driver-sleeping-${x}.sh
echo "#SBATCH -p regular ">>srun-driver-sleeping-${x}.sh
echo "#SBATCH --nodes=1  ">>srun-driver-sleeping-${x}.sh
echo "#SBATCH --cpus-per-task=1 ">>srun-driver-sleeping-${x}.sh
echo "#SBATCH --exclusive ">>srun-driver-sleeping-${x}.sh
echo "#SBATCH --ntasks-per-node=$x ">>srun-driver-sleeping-${x}.sh
echo "#SBATCH -t 01:00:00  ">>srun-driver-sleeping-${x}.sh
echo "#SBATCH -J reco_hipileup_sleeping_perfectIO_Nsingle">>srun-driver-sleeping-${x}.sh
echo "#SBATCH -L SCRATCH ">>srun-driver-sleeping-${x}.sh
echo "module swap PrgEnv-intel PrgEnv-gnu">>srun-driver-sleeping-${x}.sh
echo "srun -n${x} /global/homes/g/gartung/build/BuildProducts/bin/TBBDemo /global/homes/g/gartung/toy-mt-framework/cms-data/reco_hipileup_5_2_0_sleeping_perfectIO.${nSimulEvtP}s.${nThreadsP}t.${iterations}i.config" >>srun-driver-sleeping-${x}.sh
done
