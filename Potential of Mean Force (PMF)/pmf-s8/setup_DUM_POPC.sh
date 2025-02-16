#!/bin/sh

start_dir=$( pwd )

Ncolumn=2 # number of resist columns to insert
DZwin=0.025 # spacing between umbrellas
DZsol=1.5 # spacing between resists in a column (size of resist will be added to this spacing)
Buffer=1.2 # windows will span the box size minus this distance

for bilayer in POPC
do
    if [ $bilayer = POPC ] ; then mem_groups=($( echo POPC )) ; Nmemgroups=1 ; fi
    

    for resist in  Octasulfur #Lap  
    do
	for replicate in A B C 
	do
	
	outdir=$( echo $start_dir/US_50ns/$bilayer-$resist-$replicate )
	mkdir $outdir
	cd $outdir
	pwd
    
	#UPDATE HERE: molecule name
	if [ $resist = Octasulfur ] ; then molname="Octasulfur" ; fi
	
	
	#bilayer gro
	bilayer_gro=$( echo $start_dir/groFiles/$bilayer\_162-$replicate.gro )
	# bilayer in pdb format

	gmx editconf -f $bilayer_gro -o bilayer.pdb >& out || { cat out; exit 1 ;}
	
	
	#resist gro
	resist_gro=$( echo  $start_dir/groFiles/mol_dum.pdb )

	# combined topology dir (for the moment for POPC and MOLECULE)
	topdir=$( echo $start_dir/Topology  )

	# resist max size
	gmx editconf -f $resist_gro -d 0 -bt cubic -center 0 0 0  >& out || { cat out; exit 1 ;}

	
	Lresist=$( tail -n 1 out.gro | awk ' { print $1 } ' )

	# box size
	Box=($( tail -n 1 $bilayer_gro ))
	

	# calculation of dimensions and initial positions of resists
	echo $Ncolumn $DZwin $DZsol $Lresist ${Box[*]} $Buffer | awk '
{

Ncolumn=$1
DZwin=$2
DZsol=$3
Lresist=$4
Lx=$5
Ly=$6
lz=$7
Buffer=$8
Lz=lz-Buffer


# Ntotal of windows
NWINDOWS=int(Lz/DZwin)


# spacing between molecules (in DZwin units)
DZSOL=DZsol+Lresist
BIN_SOL=int( DZSOL/DZwin) 



# make this number a multiple of the number of columns
if( BIN_SOL%Ncolumn!=0) { BIN_SOL+= BIN_SOL%Ncolumn}


BIN_SOL_per_col=BIN_SOL/Ncolumn


# number of molecules to insert per column
NSOL=int(NWINDOWS/BIN_SOL)


# x,y  position  In the middle of the box 

Lx_col=Lx/Ncolumn
Ly_col=Ly/Ncolumn




# print parameters
print "#Ncolumns: "Ncolumn
print "#DZwin: "DZwin
print "#DZSOL(including-resist-size): "DZSOL 
print "#Z box size:" Lz
print "#NSOL: "NSOL
print "#NWINDOWS: "NWINDOWS
print "#Bins-per-molecule: "BIN_SOL
print "#Bins-per-molecule-per-column: "BIN_SOL_per_col
print "#lateral spacing X: " Lx_col
print "#lateral spacing Y: " Ly_col

print "#window column molecule x y z"
# initial positions of resists per window
for(w=0;w<BIN_SOL_per_col;w++){
for(c=0;c<Ncolumn;c++){
for(m=0;m<NSOL;m++){

#z position
z=  ( m*BIN_SOL +  c*BIN_SOL_per_col + w )*DZwin + Buffer/2

# x and y position
x=Lx_col
y=(c+0.5)*Ly_col




print w, c, m, x, y, z


}
}
}
}
' > initial-positions.dat	

# ---loop over windows---
	NWINDOWS=$( grep "Bins-per-molecule-per-column"  initial-positions.dat | awk ' { print $NF } ' )
	
#loop over windows
	N=0	
	while [ $N -lt $NWINDOWS ]
	do
	    mkdir $N
	    echo window $N
	    
# 2. --- create the initial positions of the molecules ----
# extract molecule positions for this windows
	    grep -v \# initial-positions.dat | awk ' $1=='$N' { print $4,$5,$6} ' > $N/initial-positions.dat

	    gmx insert-molecules -ci out.gro -ip $N/initial-positions.dat -o $N/resists.pdb -box ${Box[*]}  >& out || { cat out; exit 1 ;}	    
	    
# 3. --- merge resist and bilayer positions (with overlap)
	    {
		grep CRYST bilayer.pdb # box size
		grep ATOM $N/resists.pdb # resist atoms
		grep ATOM bilayer.pdb # lipids,water,ions
	    } > $N/system_overlap.pdb  
	    
	    
	    gmx editconf -f $N/system_overlap.pdb  -o $N/system_overlap.gro >& out || { cat out; exit 4 ;}
	    
 
	    if [ $N = 0 ]
	    then

	    # merge topologies (for the moment POPC and MOLECULE only)
	  
	    $start_dir/add_mol_ff.sh $topdir/forcefield.itp  $topdir/charmm36_Octasulfur.itp  $topdir/Octasulfur.itp  $molname"_" toppar
	    
	    
	    # copy lipid, water, ions itps
	    cp $topdir/$bilayer.itp toppar/
	    cp $topdir/TIP3.itp toppar/
	    cp $topdir/SOD.itp toppar/
	    cp $topdir/CLA.itp toppar/
	    
	    
	    
	    # update MOLECULE		       
	    Nresists=$( wc   $N/initial-positions.dat   | awk ' { print $1 } ' )
	    # lipids, water, and ions  will not be counted and kept as in topol.top (as it may be a mixture)

	    awk '
BEGIN{modify=0}
{

if($0=="[ system ]") { 
printf ("#include \"toppar/%s.itp\"\n", "mol" )
print $0 ; 
}
else {

if($0=="; Compound	#mols") { 
print $0 ; 
printf ("%s %d\n", "'$molname'" ,  '$Nresists' )
}
else {
print $0
}
}
}

'  $topdir/topol.top | sed 's/forcefield.itp/charmm36.itp/g'  > topol.top


	    
# 4. generate position restraint file for resist
	echo 0| 	    gmx genrestr -f out.gro -o toppar/posres-$molname.itp >& out || { cat out; exit 1 ;}
	    
# include posres indication in resist itp
cat>> toppar/mol.itp <<EOF
; Include Position restraint file
#ifdef POSRES
#include "posres-$molname.itp"
#endif
EOF

	    fi # top only for N=0


	    if [ $N = 0 ]
	    then
	    
	    rm -f index.ndx 

{
	g=0
	while [ $g -lt $Nmemgroups ]
        do
	
	  group=${mem_groups[g]}
	  if [ $g -lt $[Nmemgroups-1] ] ; then     echo \"$group\" \|
	  else # last group without the \|
	  echo \"$group\"
	  fi
	  
        g=$[g+1]
	done 	     | tr "\n" " " ;

echo " "
	echo q 
} | gmx make_ndx -f $N/system_overlap.gro  -o   >& out || { cat out; exit 1 ;}

    ngroups=$( grep -c "\[" index.ndx )

    {
    echo name $[ngroups-1] MEMB
    echo \! $[ngroups-1]
    echo name $[ngroups] NON-MEMB
    echo q 
    } | gmx make_ndx -n index.ndx  -f $N/system_overlap.gro  -o   >& out || { cat out; exit 1 ;}


    
    	    # index group with umbrellas

molgroup=$(	    grep "\[" index.ndx | awk ' $2=="'$molname'" {print NR-1 }' )
	    
	    {
	    echo splitres $molgroup
	    echo q
	    } |	    gmx make_ndx -f $N/system_overlap.gro -n index.ndx -o index.ndx  >& out || { cat out; exit 1 ;}

fi # index file 	    
	    
	    
	rm -f tmp*  \#*\#  */\#*\# 
	N=$[N+1]
	done



	rm -f \#*\# 
	cd $start_dir
	done # loop over replicates
    done # loop over resist
done # loop over bilayer
		   
    
