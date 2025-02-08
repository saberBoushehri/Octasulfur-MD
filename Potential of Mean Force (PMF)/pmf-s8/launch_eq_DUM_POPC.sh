#!/bin/sh
# script to do clash removal, energy minimization and equilibration per umbrella
# should run in cascade


start_dir=$( pwd )

sed -i "s|PATH|$start_dir|g" "$start_dir/jobscript_eq.sh"

for bilayer in POPC
do
	for resist in  Octasulfur #molecule name  
	do
		for replicate in A B C
		do
	
		outdir=$( echo $start_dir/US_50ns/$bilayer-$resist-$replicate )
		cd $outdir
		pwd

		#UPDATE HERE: molecule name
		if [ $resist = Octasulfur ] ; then molname="Octasulfur" ; fi

		# ---loop over windows---
		NWINDOWS=$( grep "Bins-per-molecule-per-column"  initial-positions.dat | awk ' { print $NF } ' )

		#loop over windows
		N=0	
		while [ $N -lt $NWINDOWS ]
			do
			echo window: $N 
 	    
	    		# 6 --- change mdp file molecule name
	    		sed "s/MOLNAME/$molname/g" $start_dir/grow.mdp > grow.mdp
	    
	    		# 7-9: clash removal (grow), energy-minimization, thermalization, solvent equilibration:
	    		#change window N info in submission script
	    		sed "s/WINDOW/$N/g" 	$start_dir/jobscript_eq.sh  >  $N/jobscript_eq.sh  

#                        sbatch $N/jobscript_eq.sh #--> sbatch */jobscript_eq.sh

	    		rm -f tmp*  \#*\#  */\#*\# 

			N=$[N+1]
			done # loop over windows
	
		rm -f \#*\# 
		cd $start_dir
		done # loop over replicates
	done # loop over resist
done # loop over bilayer
		   
	      
