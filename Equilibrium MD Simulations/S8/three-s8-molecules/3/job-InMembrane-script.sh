#!/bin/bash

#MD in membrane
gmx grompp -f in-mem.mdp -c md-whole.gro -r md-whole.gro  -n index.ndx -p topol.top -o inMem.tpr -maxwarn 1 
gmx mdrun -v -deffnm inMem -dlb yes -ntomp 3 -ntmpi 6 -pme gpu -npme 1 -bonded gpu -nb gpu
