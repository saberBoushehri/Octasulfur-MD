#script to add entries of a new molecule into a ffnonbonded and ffbonded itp files
file1=$1 # file 1 with solvent ff definitions (e.g. charmm36.itp for POPC bilayer)
file2=$2 # file 2 with molecule definitions  (e.g. charmm36.itp for NIP molecule)
molfile=$3 # molecule.itp file (e.g. mol.itp )
mol_prefix=$4 # all atom-types  in molecule will have this prefix to distinguish it from other atom definitions
outputdir=$5 # output directory:  charmm36 and mol itps will be copied in this directory


# 0) --- sync input and output topdirs
mkdir $outputdir
cp $file1 $outputdir/charmm36.itp
cp $molfile $outputdir/mol.itp



#1)--- list the atomtypes of the molecule
awk '
BEGIN{attype_section=0 }
($2=="atomtypes"){attype_section=1 }
($2=="bondtypes"){attype_section=0 }
(attype_section==1 && $1!=";" && $1!="[" && NF>0)  { attype=$1 ; print attype }



 ' $file2  > $outputdir/new-attypes


#2---- add prefix to atom types
Natoms=$( wc $outputdir/new-attypes | awk ' { print $1 } ' )

cp $file2 tmp-ffdef-itp


N=1
while [  $N -le $Natoms ]
do

    attype=$( head -n $N $outputdir/new-attypes | tail -n 1 )


    # charmm36 file
    sed "s/$attype/$mol_prefix$attype/g" tmp-ffdef-itp > tmp2-ffdef-itp
    mv     tmp2-ffdef-itp     tmp-ffdef-itp


    # mol.itp file
sed "s/$attype/$mol_prefix$attype/g" $outputdir/mol.itp > tmp2-mol-itp
    mv     tmp2-mol-itp     $outputdir/mol.itp 
    
    
N=$[N+1]
done


#3) --- addd the  non-bonded and bonded entries
awk '
BEGIN{
attype_section=0 
bonded_section=0
pairs_section=0

#print headers
OUTDIR="'$outputdir'"



print "; New molecule definitions inserted by add_mol_ff.sh: " >> OUTDIR"/charmm36.itp"
print "; New molecule definitions inserted by add_mol_ff.sh: " >> OUTDIR"/charmm36.itp"


}
($2=="atomtypes"){attype_section=1 }
($2=="bondtypes"){attype_section=0 ;  bonded_section=1 }

($2=="pairtypes"){pairs_section=1 ;  bonded_section=0 }
($2=="angletypes"){pairs_section=0 ;  bonded_section=1 } # from angles on it will be on ffbonded file


#(attype_section==1 && $1!=";" && $1!="[" && NF>0)  { print $0 >> OUTDIR"/charmm36.itp" }
(attype_section==1 )  { print $0 >> OUTDIR"/charmm36.itp" }
(bonded_section==1 )  { print $0 >> OUTDIR"/charmm36.itp" }
(pairs_section==1 )  { print $0 >> OUTDIR"/charmm36.itp" }

'  tmp-ffdef-itp
rm -f tmp-ffdef-itp

echo files created
ls $outputdir/charmm36.itp
ls $outputdir/mol.itp
