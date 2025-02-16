#!/bin/sh

# script to do clash removal, energy minimization and equilibration per umbrella
start_dir=$( pwd )

sed -i "s|PATH|$start_dir|g" "$start_dir/jobscript_eq.sh"

for bilayer in POPC
do
	for resist in  GSH # name of the molecule   
	do
		for replicate in A B C
		do
	
		outdir=$( echo $start_dir/US_50ns/$bilayer-$resist-$replicate )
		cd $outdir
		pwd

		#UPDATE HERE: molecule name
		if [ $resist = GSH ] ; then molname="GSH" ; fi

		# ---loop over windows---
		NWINDOWS=$( grep "Bins-per-molecule-per-column"  initial-positions.dat | awk ' { print $NF } ' )

		#loop over windows
		N=0	
		while [ $N -lt $NWINDOWS ]
			do
			echo window: $N 
 	   
	    
	    		#change window N info in submission script
	    		sed "s/WINDOW/$N/g" 	$start_dir/jobscript_eq.sh  >  $N/jobscript_eq.sh  

                        sbatch $N/jobscript_eq.sh 

	    		rm -f tmp*  \#*\#  */\#*\# 

			N=$[N+1]
			done # loop over windows
	
		rm -f \#*\# 
		cd $start_dir
		done # loop over replicates
	done # loop over resist
done # loop over bilayer
		   
	      
