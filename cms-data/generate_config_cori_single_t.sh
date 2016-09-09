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
declare -i busyWaitScaleFactor
busyWaitScaleFactor=423729000


nSimulEvtP=`printf "%02d" $nSimulEvt`
nThreadsP=`printf "%02d" $nThreads`

sed -e "s/\$iterations/$iterations/" -e "s/\$nSimulEvt/$nSimulEvt/" -e "s/\$nThreads/$nThreads/" -e "s/\$busyWaitScaleFactor/$busyWaitScaleFactor/"  reco_hipileup_5_2_0_busywait_perfectIO.config.tt >reco_hipileup_5_2_0_busywait_perfectIO.${nSimulEvtP}s.${nThreadsP}t.${iterations}i.config

for ((x=2;x<=64;x+=2)); do
   echo "#!/bin/bash -l     "  >srun-driver-${x}.sh  
   echo "                   " >>srun-driver-${x}.sh
   echo "#SBATCH -p regular " >>srun-driver-${x}.sh   
   echo "#SBATCH -N 1      "  >>srun-driver-${x}.sh   
   echo "#SBATCH -t 02:00:00" >>srun-driver-${x}.sh  
   echo "#SBATCH -J my_job  " >>srun-driver-${x}.sh   
   echo "#SBATCH -L SCRATCH " >>srun-driver-${x}.sh
   echo "srun $PWD/driver-$x.sh" >>srun-driver-${x}.sh
  echo "#!/bin/bash" >driver-$x.sh
  for ((y=1;y<=${x};y+=1));do
    echo /global/homes/g/gartung/build/BuildProducts/bin/TBBDemo /global/homes/g/gartung/toy-mt-framework/cms-data/reco_hipileup_5_2_0_busywait_perfectIO.${nSimulEvtP}s.${nThreadsP}t.${iterations}i.config \>$x-$y.log 2\>\&1\& >>driver-$x.sh
    echo ids[$y]=\$\! >>driver-$x.sh
    done
  cat >> driver-$x.sh << EOF
    tim=0
    live=1
    while [ \$live -eq 1 ]; do
       let tim=\$tim+100
       live=0
       sleep 100
       for ((x=1;x<$y;x+=1)); do
          if ps -p \${ids[\$x]}> /dev/null 2>&1
          then
             if [ \$tim -gt 720000 ] ; then
                kill \${ids[\$x]}
                echo "APPLICATION RAN OUT OF TIME"
             else
                live=1
             fi
          fi
       done
    done
EOF
chmod +x driver-$x.sh

done
