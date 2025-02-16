#!/bin/sh

export start_dir="/umbrella-sampling/pmf-gsh"

for i in {0..52}
do
	cd US_100ns/POPC-Octasulfur-A/${i}

	gmx grompp -f ../grow.mdp -p ../topol.top -c system_overlap.gro -n ../index.ndx -o grow.tpr -r system_overlap.gro -maxwarn 1 
	gmx mdrun -deffnm grow -dlb yes -ntomp 3 -ntmpi 6 -pme gpu -npme 1 -bonded gpu -nb gpu

	gmx grompp -f $start_dir/step6.0_minimization.mdp -p ../topol.top -c grow.gro  -n ../index.ndx -o em.tpr -r grow.gro  
	gmx mdrun -deffnm em  

	gmx grompp -f $start_dir/equil.mdp -p ../topol.top -c em.gro  -n ../index.ndx -o equil.tpr -r em.gro -maxwarn 1   
	gmx mdrun -deffnm equil -dlb yes -ntomp 3 -ntmpi 6 -pme gpu -npme 1 -bonded gpu -nb gpu
	
	gmx grompp -f $start_dir/pr.mdp -p ../topol.top -c equil.gro  -n ../index.ndx -o pr.tpr -r equil.gro  -maxwarn 1 
	gmx mdrun -deffnm pr -dlb yes -ntomp 3 -ntmpi 6 -pme gpu -npme 1 -bonded gpu -nb gpu

done # loop over bilayer
		   
	      
