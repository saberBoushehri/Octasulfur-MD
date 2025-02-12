#!/bin/sh

start_dir=$( pwd )

Nmol=6 # number of molecules to insert
output_file="initial-positions.dat"


generate_random_float() {
    local min=$1
    local max=$2
    echo "$(bc -l <<< "scale=1; $min + ($RANDOM/32767) * ($max - $min)")"
}

gmx editconf -f GSH.gro -o gsh_box.gro -d 0 -bt cubic -center 0 0 0


for replicate in A B C
do 
     
    for rep in 1 2  
    do
    
    bilayer_gro=$( echo S8-POPC-$replicate-${rep}.gro )
    echo $bilayer_gro
    Box=($( tail -n 1 $bilayer_gro ))
    gmx editconf -f S8-POPC-$replicate-${rep}.gro -o S8-POPC-$replicate-${rep}.pdb
    

    > "$output_file"
    
	for nomol in $(seq 1 $Nmol)
	do
	    x=$(generate_random_float 0.5 6.5)
	    y=$(generate_random_float 0.5 6.4)
	    z=$(generate_random_float 8 9.5)
            echo "$x $y $z" >> "$output_file"
        done       
        
        gmx insert-molecules -ci  gsh_box.gro -ip initial-positions.dat -o $replicate-$rep.pdb -box ${Box[*]}
        
        {
	    grep CRYST S8-POPC-$replicate-${rep}.pdb # box size
	    grep ATOM  $replicate-$rep.pdb # resist atoms
	    grep ATOM  S8-POPC-$replicate-${rep}.pdb # lipids,water,ions
	} > POPC-overlap-$replicate-$rep.pdb  
	
	
	gmx editconf -f POPC-overlap-$replicate-$rep.pdb -o POPC-$replicate-$rep.gro



	# Copy paste files
	mkdir POPC-$replicate-$rep
	mv POPC-$replicate-$rep.gro ./POPC-$replicate-$rep
	scp topol.top ./POPC-$replicate-$rep
	scp em.mdp ./POPC-$replicate-$rep
	scp -r toppar ./POPC-$replicate-$rep
	
	# EM
	gmx grompp -f ./POPC-$replicate-$rep/em.mdp -p ./POPC-$replicate-$rep/topol.top -c ./POPC-$replicate-$rep/POPC-$replicate-$rep.gro -o ./POPC-$replicate-$rep/em.tpr
	gmx mdrun -v -deffnm ./POPC-$replicate-$rep/em
	
	sleep 2
	clear
	clear


        rm \#*
    done    
done 
