#!/bin/bash

#EM
gmx grompp -f em.mdp -c POPC-*.gro -p topol.top -o em.tpr -maxwarn 1
gmx mdrun -v -deffnm em

#NVT
gmx grompp -f nvt.mdp -c em.gro -p topol.top -o nvt.tpr -n index.ndx  -maxwarn 1
gmx mdrun -v -deffnm nvt -dlb yes -ntomp 3 -ntmpi 6 -pme gpu -npme 1 -bonded gpu -nb gpu

#NPT
gmx grompp -f npt.mdp -c nvt.gro -r nvt.gro -p topol.top -n index.ndx -o npt.tpr -maxwarn 1   
gmx mdrun -v -deffnm npt -dlb yes -ntomp 3 -ntmpi 6 -pme gpu -npme 1 -bonded gpu -nb gpu

#MD
gmx grompp -f md.mdp  -c npt.gro -r npt.gro  -n index.ndx -p topol.top -o md.tpr  -maxwarn 1 
gmx mdrun -v -deffnm md -dlb yes -ntomp 3 -ntmpi 6 -pme gpu -npme 1 -bonded gpu -nb gpu -maxh 10
