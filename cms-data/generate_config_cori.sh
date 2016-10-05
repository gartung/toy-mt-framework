#!/bin/bash

declare -i stepsize
stepsize=300
declare -i nsteps
nsteps=32
declare -i iterations
iterations=100
declare -i ncore
ncore=2
declare -i nSimulEvt
nSimulEvt=4
declare -i nThreads
nThreads=4
declare -i busyWaitScaleFactor
busyWaitScaleFactor=5000000
declare -i nProcs
#nProcs=64/nThreads
nProcs=1

echo "#">srun-driver-busywait-nt.sh
for ((x=4;x<=48;x+=4)); do
echo $x
nSimulEvt=$x
nSimulEvtP=`printf "%02d" $nSimulEvt`
scale=1.00
nThreads=`echo "($scale * $nSimulEvt)/1" | bc`
nThreadsP=`printf "%02d" $nThreads`
#nProcs=64/$x
nProcsP=`printf "%02d" $nProcs`
iterations=$x*$stepsize
echo "#!/bin/bash -l     "  >srun-driver-busywait-${nProcsP}p.${nSimulEvtP}s.${nThreadsP}t.${iterations}i.sh  
echo "#SBATCH -p debug " >>srun-driver-busywait-${nProcsP}p.${nSimulEvtP}s.${nThreadsP}t.${iterations}i.sh   
echo "#SBATCH --nodes=1  " >>srun-driver-busywait-${nProcsP}p.${nSimulEvtP}s.${nThreadsP}t.${iterations}i.sh   
echo "#SBATCH --cpus-per-task=48 " >>srun-driver-busywait-${nProcsP}p.${nSimulEvtP}s.${nThreadsP}t.${iterations}i.sh
echo "#SBATCH --exclusive " >>srun-driver-busywait-${nProcsP}p.${nSimulEvtP}s.${nThreadsP}t.${iterations}i.sh
echo "#SBATCH --ntasks-per-node=$nProcs " >>srun-driver-busywait-${nProcsP}p.${nSimulEvtP}s.${nThreadsP}t.${iterations}i.sh
echo "#SBATCH -t 00:30:00" >>srun-driver-busywait-${nProcsP}p.${nSimulEvtP}s.${nThreadsP}t.${iterations}i.sh  
echo "#SBATCH -J reco_highpileup_busywait_perfectIO  " >>srun-driver-busywait-${nProcsP}p.${nSimulEvtP}s.${nThreadsP}t.${iterations}i.sh   
echo "#SBATCH -L SCRATCH " >>srun-driver-busywait-${nProcsP}p.${nSimulEvtP}s.${nThreadsP}t.${iterations}i.sh
echo "module swap PrgEnv-intel PrgEnv-gnu" >>srun-driver-busywait-${nProcsP}p.${nSimulEvtP}s.${nThreadsP}t.${iterations}i.sh

sed -e "s/\$iterations/$iterations/" -e "s/\$nSimulEvt/$nSimulEvt/" -e "s/\$nThreads/$nThreads/" -e "s/\$busyWaitScaleFactor/$busyWaitScaleFactor/"  reco_hipileup_5_2_0_busywait_perfectIO.config.tt >reco_hipileup_5_2_0_busywait_perfectIO.${nSimulEvtP}s.${nThreadsP}t.${iterations}i.config

echo srun /global/homes/g/gartung/build/BuildProducts/bin/TBBDemo /global/homes/g/gartung/toy-mt-framework/cms-data/reco_hipileup_5_2_0_busywait_perfectIO.${nSimulEvtP}s.${nThreadsP}t.${iterations}i.config >>srun-driver-busywait-${nProcsP}p.${nSimulEvtP}s.${nThreadsP}t.${iterations}i.sh
echo sbatch srun-driver-busywait-${nProcsP}p.${nSimulEvtP}s.${nThreadsP}t.${iterations}i.sh >>srun-driver-busywait-nt.sh   
done
