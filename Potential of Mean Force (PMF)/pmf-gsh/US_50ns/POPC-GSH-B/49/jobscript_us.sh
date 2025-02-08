#!/bin/bash
#SBATCH -N 1
#SBATCH -p cascade.p
#SBATCH --gres=gpu:1
#SBATCH --mincpus=20
#SBATCH --time=24:00:00
#SBATCH --job-name="B49"

module use /hits/sw/its/doserbd/cascade/modules/all
module load GROMACS/2021-fosscuda-2019b

gmx grompp -f us.mdp -p ../topol.top -c pr.gro -n ../index.ndx -o us.tpr -maxwarn 1
gmx mdrun -s us.tpr -maxh 24 -dlb yes -ntomp 3 -ntmpi 6 -pme gpu -npme 1 -bonded gpu -nb gpu -cpo us.cpt -cpi us.cpt 
