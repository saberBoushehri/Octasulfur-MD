#!/bin/bash

for nmol in 1molecule  3molecule  6molecule
do
	for rep in 1 2 3 4 5 6 
	do
		
		cd /hits/fast/mbm/boushesr/OctaSulfur-S8/membrane-simulations/${nmol}/${rep}
		
		echo 3 0 | gmx trjconv -s md.tpr -f md.gro -o md-whole.gro -pbc whole -center  
		echo 3 0 | gmx trjconv -s md.tpr -f md.xtc -o md-whole.xtc -pbc whole -center  

		rm \#*		
		
	done
done

#echo 0 | gmx trjconv -s md.tpr -f md.xtc -o md-whole.xtc -pbc whole -n group-index.ndx
#echo 0 | gmx trjconv -s md.tpr -f md.gro -o md-whole.gro -pbc whole -n group-index.ndx

#echo 0 | gmx trjconv -s md.tpr -f md.xtc -o md-vmd.xtc -pbc whole -n group-index.ndx -skip 50
#echo 0 | gmx trjconv -s md.tpr -f md.gro -o md-vmd.gro -pbc whole -n group-index.ndx

