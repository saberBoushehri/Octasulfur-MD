
1. start to do a quick EM equilibration, we have top, itp and gro files from charmm-gui

	gmx editconf -f ligandrm.pdb -o molecule.gro -d 2.0

	gmx grompp -f em.mdp -c molecule.gro -p topol.top -o em.tpr
	gmx mdrun -v -deffnm em 
		


2. ### For GSH we do not need a dummy atom



3. Add molecules into lipid bilayer
	
	** mkdir US_50ns
	setup_DUM_POPC.sh
	it reads lipid bilayer files and add the molecule to the system
	In two columns and few in each column
	* gmx insert-molecules, build the topol.top file, gmx make_ndx, ...
		

4. launch_eq_DUM_POPC.sh
	
	This scrips copies the "jobscript_eq.sh" into each directores
	PATH in jobscript_eq.sh should be changed.
		
	# energy minimization
	gmx grompp -f $start_dir/step6.0_minimization.mdp
	gmx mdrun -deffnm $N/em
	
	gmx grompp -f $start_dir/equil.mdp -p topol.top
	gmx mdrun -deffnm $N/equil 
	
	gmx grompp -f $start_dir/pr.mdp -p topol.top
	gmx mdrun -deffnm $N/pr


5. Now, it is time to remove the dummy atoms	--> setup_us_DUM_POPC.sh
	
	Correct mol.itp file, remove the dummy parameters
	bash setup_us_DUM_POPC.sh
	run simulations on cascade --> bash launch_us_MOL_POPC.sh   (it runs all jobs, jobscript_us.sh)
	
	
6. WHAM	
          
        run on cascade:  wham_convergence_new.sh
	
	
	
	
	
	
	
	
	
#############	
SELECT ATOMS:		
Tail atioms: name C2 C3 C21 C210 C211 C212 C213 C214 C215 C216 C217 C218 C22 C23 C23 C24 C25 C26 C27 C28 C29 C3 C31 C310 C311 C312 C313 C314 C315 C316 C32 C33 C34 C35 C36 C37 C38 C39 O32 O31 O21 O22	
Head Atoms : name C1 C11 C12 C13 C14 C15 O11 O12 O13 O14 N P
#############	


###

r POPC & a N C12 H12A H12B C13  /* Choline */
r POPC & a P O11 O12 O13 O14    /* Phosphate */
r POPC & a C1 C2 C3 HA HB       /* Glycerol */
r POPC & a C21 C22 C23 C24 ...  /*

###




	
	
	
