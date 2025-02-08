#!/bin/bash
#SBATCH -N 1
#SBATCH -p cascade.p
#SBATCH --gres=gpu:1
#SBATCH --mincpus=20
#SBATCH --time=01:00:00
module use /hits/sw/its/doserbd/cascade/modules/all
module load GROMACS/2021-fosscuda-2019b

export start_dir="/hits/fast/mbm/boushesr/OctaSulfur-S8/umbrella-sampling/Glutathione/"

gmx grompp -f $start_dir/step6.0_minimization.mdp -p ../topol.top -c system_overlap.gro  -n ../index.ndx -o em.tpr -r system_overlap.gro  
gmx mdrun -deffnm em  


gmx grompp -f $start_dir/equil.mdp -p ../topol.top -c em.gro  -n ../index.ndx -o equil.tpr -r em.gro -maxwarn 1   
gmx mdrun -deffnm equil -dlb yes -ntomp 3 -ntmpi 6 -pme gpu -npme 1 -bonded gpu -nb gpu


gmx grompp -f $start_dir/pr.mdp -p ../topol.top -c equil.gro  -n ../index.ndx -o pr.tpr -r equil.gro  -maxwarn 1 
gmx mdrun -deffnm pr -dlb yes -ntomp 3 -ntmpi 6 -pme gpu -npme 1 -bonded gpu -nb gpu
