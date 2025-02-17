# Umbrella Sampling Procedure for PMF Calculation

This guide outlines the steps to perform an umbrella sampling simulation to calculate the Potential of Mean Force (PMF):

## 1. Energy Minimization (EM) Equilibration
We start with topology (`top`), force field (`itp`), and structure (`gro`) files from CHARMM-GUI.

```bash
gmx editconf -f molecule.pdb -o molecule.gro -d 2.0
gmx grompp -f em.mdp -c molecule.gro -p topol.top -o em.tpr
gmx mdrun -v -deffnm em
```

## 2. Adding a Dummy Atom at the Center of the Ring

We add a dummy atom at the center of the ring to prevent the tail from entering it. This ensures that the ring is not restricted by the tail of a POPC molecule.
**To add dummy atom:**

```bash
COM : gmx traj -f em.gro -s em.tpr -oxt com_atom.pdb -com
gmx editconf -f em.gro -o em.pdb
cat em.pdb com_atom.pdb > mol_dum.pdb
```

Edit mol_dum.pdb by removing unnecessary lines, changing atom names, and tidying up the structure.
Additionally, update .itp files to include the new atom names.

**No Dummy Atom Needed for GSH** (This step is skipped if working with GSH).

## 3. Adding Molecules into the Lipid Bilayer
Create a working directory:

```bash
mkdir US_50ns or US_100ns 
```

Run the script to insert molecules into the lipid bilayer:
```bash
setup_DUM_POPC.sh
```
This script:
- Reads lipid bilayer files
- Adds the molecule to the system in a structured manner
- Uses `gmx insert-molecules`, `gmx make_ndx`, and builds `topol.top`

## 4. Equilibration
Run the script to set up equilibration:
```bash
launch_eq_DUM_POPC.sh
```
This script:
- Copies `jobscript_eq.sh` into each directory
- Ensures the correct path is set in `jobscript_eq.sh`

Run the equilibration steps:
```bash
gmx grompp -f $start_dir/step6.0_minimization.mdp
gmx mdrun -deffnm $N/em

gmx grompp -f $start_dir/equil.mdp -p topol.top
gmx mdrun -deffnm $N/equil

gmx grompp -f $start_dir/pr.mdp -p topol.top
gmx mdrun -deffnm $N/pr
```

## 5. Removing Dummy Atoms and Running Umbrella Sampling Simulations
Run the script to remove dummy parameters:
```bash
setup_us_DUM_POPC.sh
```
After removing the dummy atoms, run umbrella sampling simulations:
```bash
bash launch_us_MOL_POPC.sh   
```

## 6. WHAM Analysis
To analyze the results and calculate PMF:
```bash
wham_convergence_new.sh   
```

---

## **Atom Selection**

### Tail Atoms:
```
name C2 C3 C21 C210 C211 C212 C213 C214 C215 C216 C217 C218 C22 C23 C24 C25 C26 C27 C28 C29 C3 C31 C310 C311 C312 C313 C314 C315 C316 C32 C33 C34 C35 C36 C37 C38 C39 O32 O31 O21 O22
```

### Head Atoms:
```
name C1 C11 C12 C13 C14 C15 O11 O12 O13 O14 N P
```

### Residue Selection for POPC:
```
r POPC & a N C12 H12A H12B C13  # Choline
t POPC & a P O11 O12 O13 O14    # Phosphate
r POPC & a C1 C2 C3 HA HB       # Glycerol
r POPC & a C21 C22 C23 C24 ...  # Lipid tails
```


