#!/bin/bash

gmx grompp -f us.mdp -p ../topol.top -c pr.gro -n ../index.ndx -o us.tpr -maxwarn 1
gmx mdrun -s us.tpr -maxh 24 -dlb yes -ntomp 3 -ntmpi 6 -pme gpu -npme 1 -bonded gpu -nb gpu -cpo us.cpt -cpi us.cpt 
