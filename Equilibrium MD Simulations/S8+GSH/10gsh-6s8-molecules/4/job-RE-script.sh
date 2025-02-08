#!/bin/bash
#SBATCH -N 1
#SBATCH -p cascade.p
#SBATCH --gres=gpu:1
#SBATCH --mincpus=20
#SBATCH --time=24:00:00
#SBATCH --job-name="6s-10gsh"

module use /hits/sw/its/doserbd/cascade/modules/all
module load GROMACS/2021-fosscuda-2019b

#rerun MD

START=$(date +"%s")

gmx mdrun -deffnm md1 -cpi md1.cpt -append  -dlb yes -ntomp 3 -ntmpi 6 -pme gpu -npme 1 -bonded gpu -nb gpu -maxh 22

END=$(date +"%s")

if [ $(((END-START)/3600)) -lt 2 ]
then
  exit
fi

sbatch job-RE-script.sh
