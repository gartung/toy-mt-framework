#!/bin/bash

declare -i stepsize
stepsize=64
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
busyWaitScaleFactor=25000000
declare -i nProcs
#nProcs=64/nThreads
nProcs=1

echo "#">srun-driver-nt.sh
for ((x=4;x<=48;x+=4)); do
echo $x
nSimulEvt=$x
nSimulEvtP=`printf "%02d" $nSimulEvt`
nThreads=$x
nThreadsP=`printf "%02d" $nThreads`
#nProcs=64/$x
nProcsP=`printf "%02d" $nProcs`
echo "#!/bin/bash -l     "  >srun-driver-${nProcsP}p.${nSimulEvtP}s.${nThreadsP}t.${iterations}i.sh  
echo "#SBATCH -p regular " >>srun-driver-${nProcsP}p.${nSimulEvtP}s.${nThreadsP}t.${iterations}i.sh   
echo "#SBATCH --nodes=1  " >>srun-driver-${nProcsP}p.${nSimulEvtP}s.${nThreadsP}t.${iterations}i.sh   
echo "#SBATCH --cpus-per-task=$x " >>srun-driver-${nProcsP}p.${nSimulEvtP}s.${nThreadsP}t.${iterations}i.sh
echo "#SBATCH --exclusive " >>srun-driver-${nProcsP}p.${nSimulEvtP}s.${nThreadsP}t.${iterations}i.sh
echo "#SBATCH --ntasks-per-node=$nProcs " >>srun-driver-${nProcsP}p.${nSimulEvtP}s.${nThreadsP}t.${iterations}i.sh
echo "#SBATCH -t 01:00:00" >>srun-driver-${nProcsP}p.${nSimulEvtP}s.${nThreadsP}t.${iterations}i.sh  
echo "#SBATCH -J my_job  " >>srun-driver-${nProcsP}p.${nSimulEvtP}s.${nThreadsP}t.${iterations}i.sh   
echo "#SBATCH -L SCRATCH " >>srun-driver-${nProcsP}p.${nSimulEvtP}s.${nThreadsP}t.${iterations}i.sh
echo "module swap PrgEnv-intel PrgEnv-gnu" >>srun-driver-${nProcsP}p.${nSimulEvtP}s.${nThreadsP}t.${iterations}i.sh

sed -e "s/\$iterations/$iterations/" -e "s/\$nSimulEvt/$nSimulEvt/" -e "s/\$nThreads/$nThreads/" -e "s/\$busyWaitScaleFactor/$busyWaitScaleFactor/"  reco_hipileup_5_2_0_sleeping_perfectIO.config.tt >reco_hipileup_5_2_0_sleeping_perfectIO.${nSimulEvtP}s.${nThreadsP}t.${iterations}i.config

echo srun -n1 -c$x /global/homes/g/gartung/build/BuildProducts/bin/TBBDemo /global/homes/g/gartung/toy-mt-framework/cms-data/reco_hipileup_5_2_0_sleeping_perfectIO.${nSimulEvtP}s.${nThreadsP}t.${iterations}i.config \& >>srun-driver-${nProcsP}p.${nSimulEvtP}s.${nThreadsP}t.${iterations}i.sh
echo "wait" >>srun-driver-${nProcsP}p.${nSimulEvtP}s.${nThreadsP}t.${iterations}i.sh 
echo sbatch srun-driver-${nProcsP}p.${nSimulEvtP}s.${nThreadsP}t.${iterations}i.sh >>srun-driver-nt.sh   
done
