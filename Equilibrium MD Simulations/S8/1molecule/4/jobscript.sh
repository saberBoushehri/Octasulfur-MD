#!/bin/bash
#SBATCH -N 1
#SBATCH -p cascade.p
#SBATCH --gres=gpu:1
#SBATCH --mincpus=20
#SBATCH --time=24:00:00
#SBATCH --job-name="1B2"

module use /hits/sw/its/doserbd/cascade/modules/all
module load GROMACS/2021-fosscuda-2019b

#MD
gmx grompp -f md.mdp  -c npt.gro -r npt.gro  -n index.ndx -p topol.top -o md.tpr  -maxwarn 1 
gmx mdrun -v -deffnm md -dlb yes -ntomp 3 -ntmpi 6 -pme gpu -npme 1 -bonded gpu -nb gpu
