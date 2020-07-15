#!/usr/bin/env nextflow

leap = "leap.in"
mglib = "mg.off"
pdbin = "wt1mg.pdb"
min = 'min.in'

process amberleap {

    container='andreagia/ambertools20conda'
    input:
    file 'mg.off' from file(mglib)
    file 'leap.in' from file(leap) 
    file 'wt1mg.pdb' from file(pdbin)
    
    output:
    file 'wt1mg.parm7' into parms
    file 'wt1mg.crd' into coords
 
    """
    tleap -f leap.in
    """
}

process ambermin {

    container='andreagia/ambertools20conda'
    input:
    file 'wt1mg.parm7' from parms
    file 'wt1mg.crd' from coords
    file 'min.in' from file(min)

    output:
    file 'wt1mg_min.rst' into restmin

    """
    sander -O -i min.in -p wt1mg.parm7 -c wt1mg.crd -r wt1mg_min.rst -o wt1mg_min_water.out -ref wt1mg.crd
    """

}

process viewpdb {

    container='andreagia/ambertools20conda'
    input:
    file 'wt1mg_min.rst' from restmin
    file 'wt1mg.parm7' from parms
    output:
    file 'wt1mg_solvated_min.pdb' into result

    """
    ambpdb -p wt1mg.parm7 -c  wt1mg_min.rst > wt1mg_solvated_min.pdb
    """

}

result.println()
