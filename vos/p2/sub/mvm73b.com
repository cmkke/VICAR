$!****************************************************************************
$!
$! Build proc for MIPL module mvm73b
$! VPACK Version 1.5, Friday, October 30, 1992, 08:30:01
$!
$! Execute by entering:		$ @mvm73b
$!
$! The primary option controls how much is to be built.  It must be in
$! the first parameter.  Only the capitalized letters below are necessary.
$!
$! Primary options are:
$!   COMPile     Compile the program modules
$!   ALL         Build a private version, and unpack the PDF and DOC files.
$!   STD         Build a private version, and unpack the PDF file(s).
$!   SYStem      Build the system version with the CLEAN option, and
$!               unpack the PDF and DOC files.
$!   CLEAN       Clean (delete/purge) parts of the code, see secondary options
$!   UNPACK      All files are created.
$!   REPACK      Only the repack file is created.
$!   SOURCE      Only the source files are created.
$!   SORC        Only the source files are created.
$!               (This parameter is left in for backward compatibility).
$!   TEST        Only the test files are created.
$!   IMAKE       Only the IMAKE file (used with the VIMAKE program) is created.
$!   OTHER       Only the "other" files are created.
$!
$!   The default is to use the STD parameter if none is provided.
$!
$!****************************************************************************
$!
$! The secondary options modify how the primary option is performed.
$! Note that secondary options apply to particular primary options,
$! listed below.  If more than one secondary is desired, separate them by
$! commas so the entire list is in a single parameter.
$!
$! Secondary options are:
$! COMPile,ALL:
$!   DEBug      Compile for debug               (/debug/noopt)
$!   PROfile    Compile for PCA                 (/debug)
$!   LISt       Generate a list file            (/list)
$!   LISTALL    Generate a full list            (/show=all)   (implies LIST)
$! CLEAN:
$!   OBJ        Delete object and list files, and purge executable (default)
$!   SRC        Delete source and make files
$!
$!****************************************************************************
$!
$ write sys$output "*** module mvm73b ***"
$!
$ Create_Source = ""
$ Create_Repack =""
$ Create_Test = ""
$ Create_Imake = ""
$ Create_Other = ""
$ Do_Make = ""
$!
$! Parse the primary option, which must be in p1.
$ primary = f$edit(p1,"UPCASE,TRIM")
$ if (primary.eqs."") then primary = " "
$ secondary = f$edit(p2,"UPCASE,TRIM")
$!
$ if primary .eqs. "UNPACK" then gosub Set_Unpack_Options
$ if (f$locate("COMP", primary) .eqs. 0) then gosub Set_Exe_Options
$ if (f$locate("ALL", primary) .eqs. 0) then gosub Set_All_Options
$ if (f$locate("STD", primary) .eqs. 0) then gosub Set_Default_Options
$ if (f$locate("SYS", primary) .eqs. 0) then gosub Set_Sys_Options
$ if primary .eqs. " " then gosub Set_Default_Options
$ if primary .eqs. "REPACK" then Create_Repack = "Y"
$ if primary .eqs. "SORC" .or. primary .eqs. "SOURCE" then Create_Source = "Y"
$ if primary .eqs. "TEST" then Create_Test = "Y"
$ if primary .eqs. "IMAKE" then Create_Imake = "Y"
$ if primary .eqs. "OTHER" then Create_Other = "Y"
$ if (f$locate("CLEAN", primary) .eqs. 0) then Do_Make = "Y"
$!
$ if Create_Repack then gosub Repack_File
$ if Create_Source then gosub Source_File
$ if Create_Test then gosub Test_File
$ if Create_Imake then gosub Imake_File
$ if Create_Other then gosub Other_File
$ if Do_Make then gosub Run_Make_File
$ exit
$!
$ Set_Unpack_Options:
$   Create_Repack = "Y"
$   Create_Source = "Y"
$   Create_Test = "Y"
$   Create_Imake = "Y"
$   Create_Other = "Y"
$ Return
$!
$ Set_EXE_Options:
$   Create_Source = "Y"
$   Create_Imake = "Y"
$   Do_Make = "Y"
$ Return
$!
$ Set_Default_Options:
$   Create_Source = "Y"
$   Create_Imake = "Y"
$   Do_Make = "Y"
$ Return
$!
$ Set_All_Options:
$   Create_Source = "Y"
$   Create_Imake = "Y"
$   Do_Make = "Y"
$ Return
$!
$ Set_Sys_Options:
$   Create_Source = "Y"
$   Create_Imake = "Y"
$   Do_Make = "Y"
$ Return
$!
$Run_Make_File:
$   if F$SEARCH("mvm73b.imake") .nes. ""
$   then
$      vimake mvm73b
$      purge mvm73b.bld
$   else
$      if F$SEARCH("mvm73b.bld") .eqs. ""
$      then
$         gosub Imake_File
$         vimake mvm73b
$      else
$      endif
$   endif
$   if (primary .eqs. " ")
$   then
$      @mvm73b.bld "STD"
$   else
$      @mvm73b.bld "''primary'" "''secondary'"
$   endif
$ Return
$!#############################################################################
$Repack_File:
$ create mvm73b.repack
$ DECK/DOLLARS="$ VOKAGLEVE"
$ vpack mvm73b.com -
	-s mvm73b.f -
	-i mvm73b.imake -
	-t tmvm73b.f tmvm73b.imake tmvm73b.pdf tstmvm73b.pdf -
	-o mvm73b.hlp
$ Exit
$ VOKAGLEVE
$ Return
$!#############################################################################
$Source_File:
$ create mvm73b.f
$ DECK/DOLLARS="$ VOKAGLEVE"
      SUBROUTINE MVM73B(RESTAB)
c
C     6 MAY 80   ...JAM...    INITIAL RELEASE
C     1 OCT 90   ...CCA...    EBCDIC TO ASCII 
c    30 OCT 92   ...WPL...    Ported for UNIX Conversion
c
      REAL*4 RESTAB(840)
C    B CAMERA
C     MERCURY FLIGHT CALIBRATION
C     GENERATED 4-24-74 FOR B CAMERA
      REAL RGEOB(840)
c
      BYTE       BNAH(8)
      INTEGER    INAH
      BYTE       BNAV(8)
      INTEGER    INAV
      BYTE       BTIE(8)
c
c      REAL MYY(8)/
c     *Z2048414E,Z20202020,Z0000000F,Z2056414E,Z20202020,Z0000000C,
c     *Z50454954,Z544E494F/ 
c
      REAL MY2(72)/
     * 41.296, 15.007, 22.374, 21.713, 40.348, 70.580, 18.111, 66.681,
     * 40.348, 70.580, 18.111, 66.681, 40.819,205.346, 13.658,181.918,
     * 40.819,205.346, 13.658,181.918, 40.689,339.855, 12.566,300.149,
     * 40.689,339.855, 12.566,300.149, 40.819,474.796, 13.135,419.257,
     * 40.819,474.796, 13.135,419.257, 40.779,610.040, 14.129,538.057,
     * 40.779,610.040, 14.129,538.057, 41.158,744.852, 16.004,655.557,
     * 41.158,744.852, 16.004,655.557, 41.071,879.470, 18.629,770.057,
     * 41.071,879.470, 18.629,770.057, 42.596,935.203, 22.289,814.394,
     * 84.573, 13.808, 59.408, 18.605, 84.573, 13.808, 59.408, 18.605/
      REAL MY3(80)/
     * 83.914,137.495, 53.798,122.887, 83.914,137.495, 53.798,122.887,
     * 84.053,272.286, 52.254,240.246, 84.053,272.286, 52.254,240.246,
     * 84.288,407.463, 52.566,359.464, 84.288,407.463, 52.566,359.464,
     * 84.093,542.840, 53.441,478.933, 84.093,542.840, 53.441,478.933,
     * 84.556,677.917, 54.704,597.400, 84.556,677.917, 54.704,597.400,
     * 84.889,813.063, 56.477,714.251, 84.889,813.063, 56.477,714.251,
     * 85.622,935.759, 60.327,816.783, 85.622,935.759, 60.327,816.783,
     *130.580, 13.518,100.449, 17.485,130.577, 70.054, 97.865, 64.483,
     *130.577, 70.054, 97.865, 64.483,130.891,205.129, 95.566,180.996,
     *130.891,205.129, 95.566,180.996,130.619,339.858, 95.379,299.871/
      REAL MY4(80)/
     *130.619,339.858, 95.379,299.871,130.331,475.165, 96.004,419.183,
     *130.331,475.165, 96.004,419.183,130.513,610.187, 97.425,538.078,
     *130.513,610.187, 97.425,538.078,130.902,745.193, 98.749,656.414,
     *130.902,745.193, 98.749,656.414,131.743,880.426,100.707,772.063,
     *131.743,880.426,100.707,772.063,131.736,935.686,102.369,818.160,
     *197.040, 13.116,160.005, 15.313,197.040, 13.116,160.005, 15.313,
     *196.832,137.410,157.265,121.274,196.832,137.410,157.265,121.274,
     *196.922,272.377,157.194,239.888,196.922,272.377,157.194,239.888,
     *197.020,407.419,158.191,359.035,197.020,407.419,158.191,359.035,
     *196.882,542.794,159.182,478.409,196.882,542.794,159.182,478.409/
      REAL MY5(80)/
     *196.771,677.938,160.191,597.308,196.771,677.938,160.191,597.308,
     *196.874,812.686,161.348,715.336,196.874,812.686,161.348,715.336,
     *197.475,936.562,162.930,820.487,197.475,936.562,162.930,820.487,
     *266.079, 13.031,223.567, 14.128,265.997, 69.974,222.312, 62.387,
     *265.997, 69.974,222.312, 62.387,266.354,205.066,222.249,179.937,
     *266.354,205.066,222.249,179.937,265.873,339.904,222.316,298.933,
     *265.873,339.904,222.316,298.933,265.988,475.095,223.634,418.408,
     *265.988,475.095,223.634,418.408,265.979,610.710,224.713,537.584,
     *265.979,610.710,224.713,537.584,265.898,745.289,226.027,656.329,
     *265.898,745.289,226.027,656.329,266.190,880.364,226.691,773.621/
      REAL MY6(80)/
     *266.190,880.364,226.691,773.621,266.038,936.257,226.993,820.801,
     *332.045, 13.886,284.626, 13.951,332.045, 13.886,284.626, 13.951,
     *331.982,137.557,283.690,120.121,331.982,137.557,283.690,120.121,
     *332.042,272.345,284.451,238.884,332.042,272.345,284.451,238.884,
     *331.856,407.582,285.379,358.246,331.856,407.582,285.379,358.246,
     *331.968,542.764,286.690,477.548,331.968,542.764,286.690,477.548,
     *331.899,677.947,287.885,596.798,331.899,677.947,287.885,596.798,
     *331.874,813.144,288.501,715.521,331.874,813.144,288.501,715.521,
     *332.099,936.110,289.053,821.121,332.099,936.110,289.053,821.121,
     *399.955, 13.991,348.189, 13.767,399.563, 69.917,347.470, 61.288/
      REAL MY7(80)/
     *399.563, 69.917,347.470, 61.288,399.414,205.095,347.691,179.058,
     *399.414,205.095,347.691,179.058,399.613,340.061,348.778,298.188,
     *399.613,340.061,348.778,298.188,400.000,475.000,350.441,417.183,
     *400.000,475.000,350.441,417.183,399.819,610.275,351.754,536.308,
     *399.819,610.275,351.754,536.308,399.688,745.373,352.562,655.438,
     *399.688,745.373,352.562,655.438,399.375,880.541,352.379,773.558,
     *399.375,880.541,352.379,773.558,399.630,936.661,352.616,821.437,
     *467.235, 13.814,411.251, 13.584,467.235, 13.814,411.251, 13.584,
     *467.164,137.590,411.475,119.483,467.164,137.590,411.475,119.483,
     *467.058,272.707,412.333,238.236,467.058,272.707,412.333,238.236/
      REAL MY8(80)/
     *467.544,407.243,413.941,356.871,467.544,407.243,413.941,356.871,
     *467.116,542.849,414.661,476.503,467.116,542.849,414.661,476.503,
     *466.749,678.042,415.576,595.976,466.749,678.042,415.576,595.976,
     *467.143,812.623,416.588,714.344,467.143,812.623,416.588,714.344,
     *467.328,936.122,416.178,820.752,467.328,936.122,416.178,820.752,
     *532.903, 13.911,472.811, 14.405,533.062, 70.161,473.402, 61.726,
     *533.062, 70.161,473.402, 61.726,533.181,205.124,474.379,178.424,
     *533.181,205.124,474.379,178.424,533.332,340.040,475.495,297.175,
     *533.332,340.040,475.495,297.175,533.223,475.122,476.561,416.321,
     *533.223,475.122,476.561,416.321,533.032,610.431,477.627,535.792/
      REAL MY9(80)/
     *533.032,610.431,477.627,535.792,532.728,745.520,478.254,654.996,
     *532.728,745.520,478.254,654.996,532.808,880.474,478.129,772.558,
     *532.808,880.474,478.129,772.558,532.710,936.103,477.238,820.074,
     *601.814, 13.679,537.375, 15.219,601.814, 13.679,537.375, 15.219,
     *602.014,137.911,538.765,119.831,602.014,137.911,538.765,119.831,
     *601.834,272.710,539.679,237.734,601.834,272.710,539.679,237.734,
     *602.252,407.619,541.219,356.388,602.252,407.619,541.219,356.388,
     *601.778,542.993,541.830,475.899,601.778,542.993,541.830,475.899,
     *602.255,677.973,543.350,594.997,602.255,677.973,543.350,594.997,
     *602.251,813.289,543.149,713.732,602.251,813.289,543.149,713.732/
      REAL MY10(80)/
     *601.810,936.367,541.298,819.389,601.810,936.367,541.298,819.389,
     *667.938, 12.634,598.436, 16.542,667.700, 70.337,599.429, 63.536,
     *667.700, 70.337,599.429, 63.536,668.109,205.392,601.609,178.694,
     *668.109,205.392,601.609,178.694,668.031,340.172,602.684,296.852,
     *668.031,340.172,602.684,296.852,668.082,475.355,603.788,415.825,
     *668.082,475.355,603.788,415.825,668.044,610.279,604.875,534.927,
     *668.044,610.279,604.875,534.927,667.791,745.277,604.888,653.997,
     *667.791,745.277,604.888,653.997,667.597,880.271,603.191,770.871,
     *667.597,880.271,603.191,770.871,667.745,936.088,601.357,817.715,
     *713.858, 13.453,640.478, 18.670,713.858, 13.453,640.478, 18.670/
      REAL MY11(80)/
     *714.429,138.027,643.713,121.116,714.429,138.027,643.713,121.116,
     *714.500,272.683,645.648,237.656,714.500,272.683,645.648,237.656,
     *714.361,407.856,646.754,356.308,714.361,407.856,646.754,356.308,
     *714.373,542.958,647.616,475.407,714.373,542.958,647.616,475.407,
     *714.065,678.014,647.721,594.788,714.065,678.014,647.721,594.788,
     *713.865,812.609,646.654,712.352,713.865,812.609,646.654,712.352,
     *713.322,935.299,642.397,816.095,713.322,935.299,642.397,816.095,
     *756.710, 15.321,679.018, 22.809,757.076, 70.947,681.004, 66.808,
     *757.076, 70.947,681.004, 66.808,757.697,205.491,684.691,179.496,
     *757.697,205.491,684.691,179.496,757.834,340.165,686.504,296.966/
      REAL MY12(40)/
     *757.834,340.165,686.504,296.996,758.018,475.403,687.795,415.774,
     *758.018,475.403,687.795,415.774,757.771,610.352,688.331,534.905,
     *757.771,610.352,688.331,534.905,757.527,745.136,687.453,653.274,
     *757.527,745.136,687.453,653.274,757.176,879.777,683.714,768.728,
     *757.176,879.777,683.714,768.728,756.253,934.830,679.933,813.986/
c
c      EQUIVALENCE (RGEOB(1),MYY(1))
c
      EQUIVALENCE  (RGEOB(1), BNAH(1))
      Equivalence  (RGEOB(3), INAH)
      Equivalence  (RGEOB(4), BNAV(1))
      EQuivalence  (RGEOB(6), INAV)
      Equivalence  (RGEOB(7), BTIE(1))

      Equivalence (RGEOB(9),MY2(1)),(RGEOB(81),MY3(1)),
     & (RGEOB(161),MY4(1)),(RGEOB(241),MY5(1)),(RGEOB(321),MY6(1)),
     & (RGEOB(401),MY7(1)),(RGEOB(481),MY8(1)),(RGEOB(561),MY9(1)),
     & (RGEOB(641),MY10(1)),(RGEOB(721),MY11(1)),(RGEOB(801),MY12(1))
c
c
c      CALL MVL(RGEOB,RESTAB,3360)
c
      Call MVCL('NAH     ',BNAH, 8)
      INAH = 15
      Call MVCL('NAV     ',BNAV, 8)
      INAV = 12
      Call MVCL('TIEPOINT',BTIE, 8)
c
      Do  20  IJ = 1, 840
        RESTAB(IJ) = RGEOB(IJ)
20    Continue

      Return
      End
$ VOKAGLEVE
$ Return
$!#############################################################################
$Imake_File:
$ create mvm73b.imake
/* Imake file for VICAR subroutine MVM73B  */

#define SUBROUTINE  mvm73b

#define MODULE_LIST  mvm73b.f  

#define P2_SUBLIB

#define USES_FORTRAN
$ Return
$!#############################################################################
$Test_File:
$ create tmvm73b.f
      INCLUDE 'VICMAIN_FOR'
c
      Subroutine MAIN44
c
C  PROGRAM TMVM73B
C
C  THIS IS A TESTPROGRAM FOR SUBROUTINE MVM73B.
C  MVM73B PROVIDES THE CALLING PROGRAM A BUFFER CONTAINING
C  NOMINAL MVM DISTORTION CORRECTION DATA IN GEOMA
C  FORMAT.  MVM73B RETURNS DATA FOR THE "B" CAMERA.
c
      REAL*4  BUF(840)
c
      CALL MVM73B(BUF)
c
c      CALL QPRINT(' FIRST EIGHT ELEMENTS IN BUF, STARTING WITH NAH',47)
c      CALL PRNT(0,32,BUF)
c
      Call Prnt(99, 8, BUF(1), ' FIRST 2 BUF = .')
      Call Prnt( 4, 1, BUF(3), ' Value of NAH = .')
      Call Prnt(99, 8, BUF(4), ' NEXT  2 BUF = .')
      Call Prnt( 4, 1, BUF(6), ' Value of NAV = .')
      Call Prnt(99, 8, BUF(7), ' NEXT  2 BUF = .')
c
      CALL QPRINT(' GEOMA PARAMETERS:',18)
      CALL PRNT(7,80,BUF(81),'.')
      CALL QPRINT(' ',1)
      CALL PRNT(7,80,BUF(161),'.')
      CALL QPRINT(' ',1)
      CALL PRNT(7,80,BUF(241),'.')
      CALL QPRINT(' ',1)
      CALL PRNT(7,80,BUF(321),'.')
      CALL QPRINT(' ',1)
      CALL PRNT(7,80,BUF(401),'.')
      CALL QPRINT(' ',1)
      CALL PRNT(7,80,BUF(481),'.')
      CALL QPRINT(' ',1)
      CALL PRNT(7,80,BUF(561),'.')
      CALL QPRINT(' ',1)
      CALL PRNT(7,80,BUF(641),'.')
      CALL QPRINT(' ',1)
      CALL PRNT(7,80,BUF(721),'.')
      CALL QPRINT(' ',1)
      CALL PRNT(7,40,BUF(801),'.')
c
      Return
      End
$!-----------------------------------------------------------------------------
$ create tmvm73b.imake
/* IMAKE file for Test of VICAR subroutine  MVM73B  */

#define PROGRAM  tmvm73b

#define MODULE_LIST tmvm73b.f 

#define MAIN_LANG_FORTRAN
#define TEST

#define USES_FORTRAN

#define   LIB_RTL         
#define   LIB_TAE           
/*  #define   LIB_LOCAL   */  /*  Disable during delivery   */
#define   LIB_P2SUB         
$!-----------------------------------------------------------------------------
$ create tmvm73b.pdf
Process 
End-Proc
$!-----------------------------------------------------------------------------
$ create tstmvm73b.pdf
Procedure
Refgbl $echo
Body
Let _onfail="continue"
Let $echo="NO"
Write " THIS IS A TEST OF SUBROUTINE MVM73B."
Write "  MVM73B PROVIDES THE CALLING PROGRAM A BUFFER CONTAINING"
Write "  NOMINAL MVM DISTORTION CORRECTION DATA IN GEOMA FORMAT."
Write "  MVM73B RETURNS DATA FOR THE "B" CAMERA.  THE DATA IS RETURNED"
Write "  IN AN 840 ELEMENT ARRAY.  THE VALUES ARE INITIALIZED IN THE"
Write "  SUBROUTINE."
TMVM73B
End-Proc
$ Return
$!#############################################################################
$Other_File:
$ create mvm73b.hlp
1 MVM73B

2  PURPOSE

     To provide the calling program a buffer containing nominal MVM
     distortion correction data in the GEOMA format.

2  CALLING SEQUENCE

     CALL MVM73B(BUF)

2  ARGUMENTS

     BUF    is an 840 word array of GEOMA parameters returned.

     MVM73A should be called to set data for the "A" camera, and
     MVM73B for the "B" camera.

2  OPERATION

     The data in the array is similar to the format as the parameter
     dataset which can be input to GEOMA.  The difference between the
     two formats is in the first word.  This subroutine begins with
     NAH and the first word in the GEOMA dataset is the number of words
     (840) following the first word.

2  HISTORY

     Original Programmer:  Unknown
     Current Cognizant Programmer:  C. AVIS
     Source Language:  Fortran
     Latest Revision: 2, 1 OCT 1990

     Ported for UNIX Conversion:   W.P. Lee,  Oct. 30, 1992   
$ Return
$!#############################################################################
