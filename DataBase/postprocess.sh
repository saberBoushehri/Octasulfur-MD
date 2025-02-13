#!/bin/bash

for nmol in 1molecule  3molecule  6molecule
do
	for rep in POPC-A-1 POPC-A-2 POPC-B-1 POPC-B-2 POPC-C-1 POPC-C-2
	do
		
		cd /hits/fast/mbm/boushesr/OctaSulfur-S8/membrane-simulations/${nmol}/${rep}
		
	    # echo 7 0 | gmx trjconv -s inMem.tpr -f inMem.gro -o inMem-whole.gro -pbc whole -center -n center.ndx
		# echo 7 0 | gmx trjconv -s inMem.tpr -f inMem.xtc -o inMem-whole.xtc -pbc whole -center -n center.ndx

		echo 3 0 | gmx trjconv -s md.tpr -f md.gro -o md-whole.gro -pbc whole -center  
		echo 3 0 | gmx trjconv -s md.tpr -f md.xtc -o md-whole.xtc -pbc whole -center  

		rm \#*		
		
	done
done

#echo 0 | gmx trjconv -s md.tpr -f md.xtc -o md-whole.xtc -pbc whole -n group-index.ndx
#echo 0 | gmx trjconv -s md.tpr -f md.gro -o md-whole.gro -pbc whole -n group-index.ndx
#echo 0 | gmx trjconv -s md.tpr -f md.xtc -o md-vmd.xtc -pbc whole -n group-index.ndx -skip 50
#echo 0 | gmx trjconv -s md.tpr -f md.gro -o md-vmd.gro -pbc whole -n group-index.ndx

#echo 7  | gmx density -f md.xtc -s md.tpr -d z -n group-index.ndx -o dens-choline.xvg
#echo 8  | gmx density -f md.xtc -s md.tpr -d z -n group-index.ndx -o dens-phosphate.xvg
#echo 9  | gmx density -f md.xtc -s md.tpr -d z -n group-index.ndx -o dens-glycerol.xvg
#echo 10 | gmx density -f md.xtc -s md.tpr -d z -n group-index.ndx -o dens-tails.xvg

