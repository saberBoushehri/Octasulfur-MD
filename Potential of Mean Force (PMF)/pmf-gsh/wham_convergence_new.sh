#!/bin/bash 

# gwham with backward block average 
# runs on cluster 

#SBATCH -N 1 
#SBATCH -p cascade.p 
#SBATCH --mincpus=4
#SBATCH --time=24:00:00

module use /hits/sw/its/doserbd/cascade/modules/all
module load GROMACS/2021-fosscuda-2019b

# 1 Create output directory (US_50ns/WHAM) 
# 2 Get input for gmx wham from all replicates (it.dat, if.dat, coord-sel.dat)
# 3 Run gmx wham with bootstrapping on the aggregated information (with backward block averaging) 

# PARAMETERS 
# ----------
# replace "Nipam" with name of resist as it is specified in the directories in which the simulation was conducted

start_dir=$( pwd )
D_flat_bottom=0.75 # from this distance lateral XY Flat-bottom potential is turned on
increment=5000 #ps
end=100000 #ps                                                  #*********************

bilayer=$( echo POPC )
resist=$( echo GSH )
replicates=( A B C )
min=0
max=4.50


# CREATE OUTPUT Directory
outdir=$( echo $start_dir/US_50ns/WHAM )
# mkdir $outdir                                                  #*********************
cd $outdir
pwd

rm it.dat 
rm if.dat 
rm coord-sel.dat 

for replicate in "${replicates[@]}"
do 

	datadir=$( echo $start_dir/US_50ns/$bilayer-$resist-$replicate )
	

	# ---loop over windows---
	NWINDOWS=$( grep "Bins-per-molecule-per-column"  $datadir/initial-positions.dat | awk ' { print $NF } ' )

	ZMAX=`awk 'BEGIN {a = 0}{if ($1>0+a) a=$1} END{print a}' $datadir/initial-positions.dat`


	#loop over windows and create required files for gmx wham 
	# if.dat List of us.tpr run files
	# it.dat List of pullf.xvg log files 
	# coord-sel.dat  File that provides the pull coordinates that will be used by gmx wham
	N=0	
	while [ $N -lt $NWINDOWS ]
	do

		echo window: $N 
			
		# number of resists in this window 
		Nresists=$( wc   $datadir/$N/initial-positions.dat   | awk ' { print $1 } ' )

		# update file lists
		ls $datadir/$N/us.tpr  >> it.dat
		ls $datadir/$N/pullf.xvg  >> if.dat

		# Only consider (1) the first n pull coordinates where n is the number of resists 
		# while omitting (0) the other 2n (n+1 .. 3n) helper coordinates that keep the 
		# resists in their respective column
		echo " " | awk ' { 
		for (n=0;n<'$Nresists'*3 ; n++) { 
		if (n<'$Nresists') {consider=1} 
		else { consider=0 } 
		printf("%d ",consider ) 
		}
		printf("\n")  
		}
		' >> coord-sel.dat

		rm -f tmp*  \#*\#  */\#*\# 

		N=$[N+1]
	done # loop over windows

done 	


# Convergence analysis/Backward block average (run gmx wham for different time windows)
# 0 ns - 50 ns; 5 ns - 50 ns; ... ; 45 ns - 50 ns 

s=0                                                #*********************
while [ $(( end-s )) -ge 0 ] 
do

	begin=$(( end - s ))
	echo $begin 
	echo $s
	echo $end

	gmx wham -if if.dat -it it.dat  -is coord-sel.dat -nBootstrap 200 -b $begin -e $end -o profile_$begin.xvg -hist hist_$begin.xvg -bsprof bsProfs_$begin.xvg -bsres bsResults_$begin.xvg -temp 298 -bins 200 -min $min -max $max -zprof0 200

	s=$(($s+$increment))
done
	
rm -f \#*\# 
cd $start_dir
