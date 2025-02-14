#!/bin/bash

#MD
gmx grompp -f md.mdp  -c npt.gro -r npt.gro  -n index.ndx -p topol.top -o md.tpr  -maxwarn 1 
gmx mdrun -v -deffnm md -dlb yes -ntomp 3 -ntmpi 6 -pme gpu -npme 1 -bonded gpu -nb gpu
