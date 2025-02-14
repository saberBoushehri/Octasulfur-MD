#!/bin/bash


#rerun MD
gmx mdrun -deffnm md -cpi md.cpt -append  -dlb yes -ntomp 3 -ntmpi 6 -pme gpu -npme 1 -bonded gpu -nb gpu
