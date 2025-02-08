# script to do gwham
# runs in workstation
# compared to salome, the path was modified from ../US/.. to ../US_50ns/..

# replace "Molecule" with name of resist with first letter as capital letter (e.g. Nipam)
# replace "MOL" with 3letter name of resist (e.g. NIP)

start_dir=$( pwd )
D_flat_bottom=0.75 # from this distance lateral XY Flat-bottom potential is turned on
tb=0
te=10000


for bilayer in POPC
do

    
# UPDATE HERE: later necessary for thermostat MEMB and NONMEMB groups
    if [ $bilayer = POPC ] ; then mem_groups=($( echo POPC )) ; Nmemgroups=1 ; fi
#	    if [ $bilayer = POPC-POPE ] ; then mem_groups=($( echo POPC POPE )) ; Nmemgroups=2 ; fi
# etc

    
    for resist in  Octasulfur #Lap  
    do
	outdir=$( echo $start_dir/US_50ns/$bilayer-$resist )
	mkdir $outdir
	cd $outdir
	pwd

		#UPDATE HERE: molecule name
	if [ $resist = Octasulfur ] ; then molname="Octasulfur" ; fi

	# ---loop over windows---
	NWINDOWS=$( grep "Bins-per-molecule-per-column"  initial-positions.dat | awk ' { print $NF } ' )


	# start files with tprs and file with forces and file with coordinates to be considered
		rm -f it.dat ; touch it.dat #tprs
		rm -f if.dat ; touch if.dat #forces
		rm -f coord-sel.dat ; touch coord-sel.dat #coordinate selections
	
	
#loop over windows
	N=0	
		while [ $N -lt $NWINDOWS ]
		do

		   echo window: $N 

	    
# number of resists
Nresists=$( wc   $N/initial-positions.dat   | awk ' { print $1 } ' )

  


# update file lists
 ls $N/us.tpr  >> it.dat
 ls $N/pullf.xvg  >> if.dat

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
	

gmx wham -if if.dat -it it.dat  -is coord-sel.dat -nBootstrap 200 -b $tb -e $te -o profile_0-10.xvg -hist histo_0-10.xvg
		
	
	
	rm -f \#*\# 
	cd $start_dir
    done # loop over resist
done # loop over bilayer
		   
	      
