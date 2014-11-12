#!/bin/csh
#
setenv tau 
setenv in plot.in 
setenv out m3e04p01t12000Rconc1000Le
rm $in 

set calc=true
set plot=false

if ( $calc == "true" ) then

#========================================================== 
#   input for lo
#* ------- Physical Parameters: ------
#* RA=RAYLEIGH NUMBER,  TAU=Coriolis NUMBER, PR=PRANTEL NUMBER,
#* ETA=RATIO OF RADII,  NT= TRUNCATION,  MODE=WAVE NUMBER,
#* pL = Lewis number,  Rconc=Rayleigh number due to concentration
#* 
#* NE= SYMMETRY PARAMETER, NE=0 : UNDEFINED SYMMETRY,
#* NE=2 : EQUATORIAL SYMMETRY, NE=1 : EQUATORIAL ANTISYMMETRY.
#* DRIFT C IS DEFINED as (phi-c*t).
#*
#* LCALC=-1: Most basic case: find the most unstable growth rate at all parameters fixed
#* LCALC=0 : Critical Rayleigh number at fixed other parameters
#* LCALC=1 : All eigenvalues at fixed parameters including the Rayleigh number
#* LCALC=2 : Onset determined for constant wavenumber M 
#*           (by searching root of grothrate in R, using pegasus.f).
#* LCALC=3 : Onset determined by varying Rayleigh number R and wavenumber M.
#* LCALC=4 : Eigenvector determined for one set of parameters at onset.
#*           (Solution can be then plotted)
#* LCALC=5 : Increment along M
#* LCALC=6 : Vary Le and calculate critical R at fixed P, tau, eta, M
#*
#* LO.F calculates R (crit. Rayleighn.) and Omega (and M) in the
#* range TAU=TTA to TAU=TTF.
#========================================================== 
#
cat > $in << EOT
  NE (0/1/2) | LCALC (-1/0/1/2/3/4/5/6) |
            2               4
 |  RAYLEIGH  |  TAU     |  PRANTEL  |  ETA  |  Lewis |   Rconc   |
      80972.3279    12000     0.1       0.4    1000.     1000.
 |   NTRUNC (>=1) | MODE |
            6          3
 |   DRA   | ABSERR  |  RELERR  | NMAX |
  3000.00     1.00000E-05 0.0000E+00  10000
 |   incr_STEP | incr_END
       1.0        5000                                             
EOT
#  
# Command
make lo
./lo $in $out
rm $in

endif 
if ( $plot == "true" ) then

#  PLOTTING   ####################################################################
#==========================================================
#     input for lara
#==========================================================
#! LHEAD=0: NHEAD, LHEAD=1: NHEAD WRITTEN,
#! LNUM: 0 no plotnumbers,  1 numbers with description,
#!       2 numbers without descr., 3 numbers by ABCNUMI
#! CFE determins the field to be plotted:
#! 'VS':STREAMFUNCTION OF VELOCITY        'BS':STREAMFUNCTION OF MAG. FIELD,
#! 'JS':STREAMFUNCTION OF EL. CURRENT,
#! 'VR':RADIAL VELOCITY U_R               'BR':RADIAL MAGNETIC FIELD,
#! 'TE':TEMPERATURE FIELD THETA,          'ZF':ZONAL FLOW ( MEAN VPHI ),
#! 'MF':MEAN MERID. FLOW (M=0,PHI=CONST), 'MT':MEAN TOR. MAG. FIELD, PHI=CONST,
#! 'BT':TOROIDAL MAG. FIELD FOR PHI=CONST,
#! 'MP':STREAMLINES OF MEAN POL. MAG. FIELD FOR PHI=CONST,
#! 'MJ':STREAMLINES OF MEAN ELECTRIC CURRENT FOR PHI=CONST,
#! 'MC':CONTOUR LINES OF MEAN PHI COMPONENT OF ELECTRIC CURRENT FOR PHI=CONST,
#! 'TT':Temperature field including basic state
#! 'UP':Contours of Uphi
#! 'NU':local nusselt number

cat > larai <<EOT
|  INPUTFILE  |  OUTPUTFILE  | DATASETNR  | PLOTDRIFT |
  '$out'   'larao.DAT'              1       0.0D0
|LTIM(-2..2)|LHEAD(01)|LNUM0123|LWRT|LGR(012)|LCL(01)|LFR|
       0        1         1       0    0       1       0
| NUMBER OF PLOTS | LATITUDE OF POLE | LONGITUDE OF POLE |
         1               20.E0              20.E0
| PLOT |  TIME  | NUMBER OF SUBPLOTS |
  'SP'    0.0E0             1
    | SUBPL | PLANE(RPT) | CONST | FIELD |(MAX RAD)/RO|ZD/STEP|PlotNR|
      'SP'       'T'        90      'VS'     1.E0          9    '000'
| NOUT 0=Ende, 1=TEK, 2=Plotter, 3=SYS_LASER, 4=NWII_LAS, 5=POSTSCR. |
1
EOT

# Command
../../PLOTTINGcode/lara < larai
rm larai
#
#========================================================
#  run IDL
#========================================================
cat > idl.batch <<EOF
.run ../../PLOTTINGcode/idl_lara.pro
exit
EOF


/maths/idl81/bin/idl idl.batch

endif













