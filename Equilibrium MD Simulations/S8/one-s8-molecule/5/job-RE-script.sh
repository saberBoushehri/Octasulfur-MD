#!/bin/bash
#SBATCH -N 1
#SBATCH -p cascade.p
#SBATCH --gres=gpu:1
#SBATCH --mincpus=20
#SBATCH --time=24:00:00
#SBATCH --job-name="1C1"

module use /hits/sw/its/doserbd/cascade/modules/all
module load GROMACS/2021-fosscuda-2019b

#rerun MD
gmx mdrun -deffnm md -cpi md.cpt -append  -dlb yes -ntomp 3 -ntmpi 6 -pme gpu -npme 1 -bonded gpu -nb gpu
