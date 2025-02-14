#!/bin/bash

START=$(date +"%s")

gmx mdrun -deffnm md -cpi md.cpt -append  -dlb yes -ntomp 3 -ntmpi 6 -pme gpu -npme 1 -bonded gpu -nb gpu -maxh 22

END=$(date +"%s")

if [ $(((END-START)/3600)) -lt 2 ]
then
  exit
fi

sbatch job-RE-script.sh
