#!/bin/sh

start_dir=$( pwd )
for bilayer in POPC
do

    for resist in Octasulfur
    do

        for replicate in A B C
        do

            dir=$( echo $start_dir/US_50ns/$bilayer-$resist-$replicate )
            pwd
            # ---loop over windows---
            NWINDOWS=$( grep "Bins-per-molecule-per-column"  $dir/initial-positions.dat | awk ' { print $NF } ' )
            N=0
            while [ $N -lt $NWINDOWS ]
            do

		sleep 0.2
                outdir=$( echo $dir/$N )
                cd $outdir
                pwd
                cp $start_dir/jobscript_us.sh .
                sed -i "s/^#SBATCH --job-name=.*/#SBATCH --job-name=\"$replicate$N\"/" jobscript_us.sh
                sbatch jobscript_us.sh
                #rm -f tmp*  \#*\#  */\#*\#
                N=$[N+1]

            done # loop over windows
            # rm -f \#*\#
            cd $start_dir

        done # loop over replicates
    done # loop over resist
done # loop over bilayer





