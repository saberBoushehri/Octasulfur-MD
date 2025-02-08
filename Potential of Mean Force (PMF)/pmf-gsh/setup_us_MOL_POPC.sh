#!/bin/sh

start_dir=$( pwd )
D_flat_bottom=1.0 #


for bilayer in POPC
do

    

    if [ $bilayer = POPC ] ; then mem_groups=($( echo POPC )) ; Nmemgroups=1 ; fi
    
    for resist in  GSH #Lap  
    do
	for replicate in A B C
	do 

	outdir=$( echo $start_dir/US_50ns/$bilayer-$resist-$replicate )
	#mkdir $outdir
	cd $outdir
	pwd

	#UPDATE HERE: molecule name
	if [ $resist = GSH ] ; then molname="GSH" ; fi
	#etc

	# ---loop over windows---
	NWINDOWS=$( grep "Bins-per-molecule-per-column"  initial-positions.dat | awk ' { print $NF } ' )

#loop over windows
	N=0	
	while [ $N -lt $NWINDOWS ]
		do

		   echo window: $N 

    
	    # 10. --- 50 ns umbrella ---

	        
	    # find most centered membrane atom in box
	    gro=$( ls $N/pr.gro )
	    rm -f tmp-center ; touch tmp-center

	    	# box size
	    Box=($( tail -n 1 $gro ))


	    for group in ${mem_groups[*]}
	    do
		grep $group $gro >> tmp-center 
	    done

	    pbcatom=$(
	    awk '
BEGIN{dmin=1e7 ; atidmin=-1}
{
atomid=substr($0,16,5)

Lx='${Box[0]}'/2
Ly='${Box[1]}'/2
Lz='${Box[2]}'/2

X=substr($0,21,8)-Lx
Y=substr($0,29,8)-Ly
Z=substr($0,37,8)-Lz


D=sqrt( X*X +Y*Y + Z*Z )
if(D<dmin) {dmin=D ; atidmin=atomid}

}
END { print atidmin}
' tmp-center
	    )


	    
# number of resists
Nresists=$( wc   $N/initial-positions.dat   | awk ' { print $1 } ' )


# com of membrane in z axis
    echo MEMB  | gmx traj -f $gro -s $gro -n index.ndx -com -ox -noy -nox   >& out || { cat out; exit 1 ;}
COM_mem_Z=$( tail -n 1 coord.xvg  | awk ' { print $2 } ' )



	    
# pull section

	    #header
	    cat>$N/pull<<EOF
	    ; COM PULLING          
pull                     = yes
pull-nstxout             = 50
pull-nstfout             = 50
; Number of pull groups 
pull-ngroups             = $[Nresists+1] ; Nresist + membrane
; Number of pull coordinates
pull-ncoords             = $[Nresists*3] ; Nresist-ones: resist-mem z-distance  2xNresist-ones: flat bottom X-axis  2xNresit: flat bottom potential  Y-axis
pull-xout-average	 = no
pull-fout-average	 = no
pull-group1-name         = MEMB
pull-group1-pbcatom      = $pbcatom
pull-pbc-ref-prev-step-com = yes
;pull-cylinder-r          = 1.5
EOF

	    # remaining groups
{
	    echo "; group definitions"
	    g=1
	    while  [ $g -le $Nresists ] ; do
		echo pull-group$[g+1]-name         = $molname\_$molname\_$g 
		g=$[g+1]
	    done
}	    >>  $N/pull
	    


#  coordinate definitions
awk '
BEGIN{
Nmol=0 ; D_Flat_Bottom='${D_flat_bottom}'   }

#read reference positions
{
ref[Nmol,0]=$1 ; x
ref[Nmol,1]=$2 ; y
ref[Nmol,2]=sqrt( ($3-'$COM_mem_Z')^2 ) # z (this one with respect to com of membrane and always positive)


Nmol++
}




END {



# print everything
print  "; memb-resist definitions"
for(m=0;m<Nmol;m++){
printf(";resist :%d\n",m+1)
printf("pull-coord%d-type         = umbrella\n",m+1)
printf("pull-coord%d-geometry     = distance\n",m+1)
#printf("pull-coord%d-geometry     = cylinder\n",m+1)
#printf("pull-coord%d-vec     = 0 0 1 \n",m+1)
printf("pull-coord%d-groups       = 1 %d ; 1=mem other=resist\n",m+1,m+2)
printf("pull-coord%d-dim          = N N Y\n",m+1)
printf("pull-coord%d-start        = no\n",m+1)
printf("pull-coord%d-init         = %f\n",m+1, ref[m,2] )
printf("pull-coord%d-rate         = 0\n",m+1)
printf("pull-coord%s-k            = 1000\n",m+1)
printf("\n")

}




for(m=0;m<Nmol;m++){
print "; y-axis (upper limit)"
printf("pull-coord%d-type         = flat-bottom\n", m+1+Nmol )
printf("pull-coord%d-init         = %f ; \n", m+1+Nmol, D_Flat_Bottom )
printf("pull-coord%d-geometry     = direction\n", m+1+Nmol )
printf("pull-coord%d-groups       = 0 %d ; 1=membrane  other=resist\n", m+1+Nmol, m+2 )
printf("pull-coord%d-dim          = N Y N\n", m+1+Nmol )
printf("pull-coord%d-vec          = 0 1 0\n", m+1+Nmol )
printf("pull-coord%d-start        = yes\n", m+1+Nmol )
printf("pull-coord%d-rate         = 0\n", m+1+Nmol )
printf("pull-coord%d-k            = 2000\n", m+1+Nmol )
}

for(m=0;m<Nmol;m++){
print "; y-axis (lower limit)"
printf("pull-coord%d-type         = flat-bottom-high\n", m+1+2*Nmol )
printf("pull-coord%d-init         = %f ; \n", m+1+2*Nmol , -D_Flat_Bottom )
printf("pull-coord%d-geometry     = direction\n", m+1+2*Nmol )
printf("pull-coord%d-groups       = 0 %d ; 1=membrane  other=resist\n", m+1+2*Nmol , m+2)
printf("pull-coord%d-dim          = N Y N\n", m+1+2*Nmol )
printf("pull-coord%d-vec          = 0 1 0\n", m+1+2*Nmol )
printf("pull-coord%d-start        = yes\n", m+1+2*Nmol )
printf("pull-coord%d-rate         = 0\n", m+1+2*Nmol )
printf("pull-coord%d-k            = 2000\n", m+1+2*Nmol )
}



}

' $N/initial-positions.dat  >> $N/pull

# paste the pull info into the mdp file
cat $start_dir/us.mdp $N/pull > $N/us.mdp

gmx grompp -f $N/us.mdp -p topol.top -c $gro  -n index.ndx -o $N/us.tpr   -maxwarn 1  >& $N/out   || { cat $N/out; exit 1 ;}

    
	    
	    rm -f tmp*  \#*\#  */\#*\# 

	    N=$[N+1]
	done # loop over windows
		
	rm -f \#*\# 
	cd $start_dir

	done # loop over replicates
    done # loop over resist
done # loop over bilayer
		   
	     
