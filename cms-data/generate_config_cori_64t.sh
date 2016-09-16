#!/bin/bash

declare -i stepsize
stepsize=64
declare -i nsteps
nsteps=32
declare -i iterations
iterations=200
declare -i ncore
ncore=2
declare -i nSimulEvt
nSimulEvt=2
declare -i nThreads
nThreads=64
declare -i busyWaitScaleFactor
busyWaitScaleFactor=25000000

echo "#" > srun-driver-64t.sh

for ((x=2;x<=64;x+=2)); do
echo $x
nSimulEvt=$x
nSimulEvtP=`printf "%02d" $nSimulEvt`
nThreadsP=`printf "%02d" $nThreads`
echo "#!/bin/bash -l     "  >srun-driver-${nSimulEvtP}s.${nThreadsP}t.${iterations}i.sh  
echo "                   " >>srun-driver-${nSimulEvtP}s.${nThreadsP}t.${iterations}i.sh
echo "#SBATCH -p regular " >>srun-driver-${nSimulEvtP}s.${nThreadsP}t.${iterations}i.sh   
echo "#SBATCH -N 1       " >>srun-driver-${nSimulEvtP}s.${nThreadsP}t.${iterations}i.sh   
echo "#SBATCH -n 1       " >>srun-driver-${nSimulEvtP}s.${nThreadsP}t.${iterations}i.sh   
echo "#SBATCH -c 64      " >>srun-driver-${nSimulEvtP}s.${nThreadsP}t.${iterations}i.sh   
echo "#SBATCH -t 02:00:00" >>srun-driver-${nSimulEvtP}s.${nThreadsP}t.${iterations}i.sh  
echo "#SBATCH -J my_job  " >>srun-driver-${nSimulEvtP}s.${nThreadsP}t.${iterations}i.sh   
echo "#SBATCH -L SCRATCH " >>srun-driver-${nSimulEvtP}s.${nThreadsP}t.${iterations}i.sh
echo "export OMP_NUM_THREADS=64">>srun-driver-${nSimulEvtP}s.${nThreadsP}t.${iterations}i.sh

sed -e "s/\$iterations/$iterations/" -e "s/\$nSimulEvt/$nSimulEvt/" -e "s/\$nThreads/$nThreads/" -e "s/\$busyWaitScaleFactor/$busyWaitScaleFactor/"  reco_hipileup_5_2_0_busywait_perfectIO.config.tt >reco_hipileup_5_2_0_busywait_perfectIO.${nSimulEvtP}s.${nThreadsP}t.${iterations}i.config
echo /global/homes/g/gartung/build/BuildProducts/bin/TBBDemo /global/homes/g/gartung/toy-mt-framework/cms-data/reco_hipileup_5_2_0_busywait_perfectIO.${nSimulEvtP}s.${nThreadsP}t.${iterations}i.config >>srun-driver-${nSimulEvtP}s.${nThreadsP}t.${iterations}i.sh

echo sbatch srun-driver-${nSimulEvtP}s.${nThreadsP}t.${iterations}i.sh >> srun-driver-64t.sh
done
