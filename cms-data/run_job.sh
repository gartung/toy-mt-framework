qsub -n 32 --mode c1  -t 120 --env LD_LIBRARY_PATH=/soft/compilers/gcc/4.8.4/lib/gcc/powerpc64-bgq-linux/4.8.4/:/soft/compilers/gcc/4.8.4/lib/gcc/:/soft/compilers/gcc/4.8.4/lib/gcc/powerpc64-bgq-linux/4.8.4/../../../../powerpc64-bgq-linux/lib/:$LD_LIBRARY_PATH ~/altbuild/BuildProducts/bin/TBBDemo ~/toy-mt-framework/cms-data/reco_hipileup_5_2_0_busywait_perfectIO.config