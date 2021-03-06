$!****************************************************************************
$!
$! Build proc for MIPL module restorw
$! VPACK Version 1.9, Wednesday, March 26, 2003, 15:19:38
$!
$! Execute by entering:		$ @restorw
$!
$! The primary option controls how much is to be built.  It must be in
$! the first parameter.  Only the capitalized letters below are necessary.
$!
$! Primary options are:
$!   ALL         Build a private version, and unpack the PDF and DOC files.
$!   STD         Build a private version, and unpack the PDF file(s).
$!   SYStem      Build the system version with the CLEAN option, and
$!               unpack the PDF and DOC files.
$!   CLEAN       Clean (delete/purge) parts of the code, see secondary options
$!   UNPACK      All files are created.
$!   REPACK      Only the repack file is created.
$!   PDF         Only the PDF file is created.
$!   TEST        Only the test files are created.
$!   IMAKE       Only the IMAKE file (used with the VIMAKE program) is created.
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
$! CLEAN:
$!   OBJ        Delete object and list files, and purge executable (default)
$!   SRC        Delete source and make files
$!
$!****************************************************************************
$!
$ write sys$output "*** module restorw ***"
$!
$ Create_Repack =""
$ Create_PDF = ""
$ Create_Test = ""
$ Create_Imake = ""
$ Do_Make = ""
$!
$! Parse the primary option, which must be in p1.
$ primary = f$edit(p1,"UPCASE,TRIM")
$ if (primary.eqs."") then primary = " "
$ secondary = f$edit(p2,"UPCASE,TRIM")
$!
$ if primary .eqs. "UNPACK" then gosub Set_Unpack_Options
$ if (f$locate("ALL", primary) .eqs. 0) then gosub Set_All_Options
$ if (f$locate("STD", primary) .eqs. 0) then gosub Set_Default_Options
$ if (f$locate("SYS", primary) .eqs. 0) then gosub Set_Sys_Options
$ if primary .eqs. " " then gosub Set_Default_Options
$ if primary .eqs. "REPACK" then Create_Repack = "Y"
$ if primary .eqs. "PDF" then Create_PDF = "Y"
$ if primary .eqs. "TEST" then Create_Test = "Y"
$ if primary .eqs. "IMAKE" then Create_Imake = "Y"
$ if (f$locate("CLEAN", primary) .eqs. 0) then Do_Make = "Y"
$!
$ if (Create_Repack .or. Create_PDF .or. Create_Test .or. Create_Imake .or -
        Do_Make) -
        then goto Parameter_Okay
$ write sys$output "Invalid argument given to restorw.com file -- ", primary
$ write sys$output "For a list of valid arguments, please see the header of"
$ write sys$output "of this .com file."
$ exit
$!
$Parameter_Okay:
$ if Create_Repack then gosub Repack_File
$ if Create_PDF then gosub PDF_File
$ if Create_Test then gosub Test_File
$ if Create_Imake then gosub Imake_File
$ if Do_Make then gosub Run_Make_File
$ exit
$!
$ Set_Unpack_Options:
$   Create_Repack = "Y"
$   Create_PDF = "Y"
$   Create_Test = "Y"
$   Create_Imake = "Y"
$ Return
$!
$ Set_Default_Options:
$   Create_Imake = "Y"
$   Do_Make = "Y"
$   Create_PDF = "Y"
$ Return
$!
$ Set_All_Options:
$   Create_Imake = "Y"
$   Do_Make = "Y"
$   Create_PDF = "Y"
$ Return
$!
$ Set_Sys_Options:
$   Create_Imake = "Y"
$   Create_PDF = "Y"
$   Do_Make = "Y"
$ Return
$!
$Run_Make_File:
$   if F$SEARCH("restorw.imake") .nes. ""
$   then
$      vimake restorw
$      purge restorw.bld
$   else
$      if F$SEARCH("restorw.bld") .eqs. ""
$      then
$         gosub Imake_File
$         vimake restorw
$      else
$      endif
$   endif
$   if (primary .eqs. " ")
$   then
$      @restorw.bld "STD"
$   else
$      @restorw.bld "''primary'" "''secondary'"
$   endif
$ Return
$!#############################################################################
$Repack_File:
$ create restorw.repack
$ DECK/DOLLARS="$ VOKAGLEVE"
$ vpack restorw.com -mixed -
	-i restorw.imake -
	-p restorw.pdf -
	-t tstrestorw.pdf
$ Exit
$ VOKAGLEVE
$ Return
$!#############################################################################
$Imake_File:
$ create restorw.imake
#define  PROCEDURE restorw
#define R2LIB 
$ Return
$!#############################################################################
$PDF_File:
$ create restorw.pdf
procedure help=*
PARM INP STRING COUNT=2:3
PARM OUT STRING
PARM SIZE INTEGER COUNT=4 DEFAULT=(1,1,0,0)
PARM SL INTEGER COUNT=1 DEFAULT=1
PARM SS INTEGER COUNT=1 DEFAULT=1
PARM NL INTEGER COUNT=1 DEFAULT=0
PARM NS INTEGER COUNT=1 DEFAULT=0
PARM SN REAL DEFAULT=20.
PARM IFFT STRING DEFAULT="IFFT"
PARM OFFT STRING DEFAULT="OFFT"
PARM MODE KEYWORD VALID=(PSF,OTF) DEFAULT=OTF
PARM PSF STRING DEFAULT="PSF"
PARM OTF STRING DEFAULT="OTF"
PARM SCRATCH STRING DEFAULT="SCRATCH"
PARM AREA INTEGER COUNT=(0,4) DEFAULT=--
PARM SHIFT KEYWORD VALID=(SHIFT,NOSHIFT) DEFAULT=SHIFT

BODY

LOCAL PINP STRING			! PRIMARY INPUT
LET PINP=INP(1)

LOCAL FMT (STRING,8) INITIAL=""
LOCAL NLI INTEGER INITIAL=0
LOCAL NSI INTEGER INITIAL=0

form INP=@PINP FORMAT=@FMT NL=@NLI NS=@NSI

IF (MODE="OTF")
  let OTF=INP(2)
  goto OTF
END-IF

!ELSE (PSF):

  IF ($COUNT(AREA)<>4) 
    let $SFI=-1
    write "AREA PARAMETER REQUIRED FOR PSF MODE"
    return
  END-IF

  LOCAL PSIZE INTEGER COUNT=4 INITIAL=(0,0,0,0)
  LOCAL PSFINP STRING			! SOURCE FOR PSF

  let PSFINP=INP(2)

! NOW FOLLOW THE 'XVSIZE' ALGORITHM TO FIND THE OUTPUT SIZE FOR PSF:
  IF (SIZE(3)<>0)		! INDICATES 'SIZE' WAS SPECIFIED
    let PSIZE=SIZE
  ELSE
    let PSIZE(1)=SL
    let PSIZE(2)=SS
    let PSIZE(3)=NL
    let PSIZE(4)=NS
    IF (NL=0 OR NS=0)
      IF (NL=0)
        let PSIZE(3)=NLI-PSIZE(1)+1	! IN CASE SL SPECIFIED & NL DEFAULTED
      END-IF
      IF (NS=0)
        let PSIZE(4)=NSI-PSIZE(2)+1	! SAME FOR SS/NS
      END-IF
    END-IF
  END-IF

  psf &PSFINP &PSF &PSIZE AREA=&AREA SHIFT=&SHIFT

  fft22 &PSF &OTF SCRATCH=&SCRATCH

OTF>
  fft22 &PINP &IFFT SIZE=&SIZE SL=&SL SS=&SS NL=&NL NS=&NS SCRATCH=&SCRATCH

  LOCAL OTFD STRING INITIAL=""
  IF ($COUNT(INP)=2) GOTO NO_OTFD

    let OTFD=INP(3)
    wiener (&IFFT,&OTF,&OTFD) &OFFT SN=&SN 
    goto FINAL

  NO_OTFD>

    wiener (&IFFT,&OTF) &OFFT SN=&SN 

FINAL>
  fft22 &OFFT &OUT 'INVERSE  FORMAT=&FMT SCRATCH=&SCRATCH

END-PROC
.TITLE
VICAR1 Procedure "restorw"  --  Image restoration using Wiener filter.
.HELP
 This procedure restores an image using the Wiener noise additive model.

 It performs the following operations:
  1. (Optional) Extract a PSF from the second input image and fourier
    transform it to obtain an OTF.
  2. Fourier transform the primary input.
  3. Perform Wiener filtering.
  4. Inverse fourier transform the result of step 3 to obtain the output
    image.

 The fourier transform steps are done using the procedure FFT22.

.page
EXECUTION:

  restorw   (IN, PSFPIC or OTF, [OTFD])   OUT    PARAMS

  where:	IN	is the input image to be restored,
		PSFPIC  is the image containing the PSF (if MODE=PSF),
		OTF	is the optical transfer function (if MODE=OTF),
		OTFD	(optional) is the desired output OTF,
		OUT	is the restored output image,
		PARAMS  are the parameters, which are described in Tutor
			mode.
.page
METHOD

The optional first step is only performed if MODE=PSF is specified.  (Default
is MODE=OTF).  In this step, a point spread function is extracted from the
second input image, using the AREA parameter, and is fourier transformed to 
obtain the optical transfer function (OTF).  If MODE=OTF, the OTF is the
second input file.

The image restoration is performed using program "wiener". This program applies
the Wiener noise additive restoration model on a point by point basis:

        FT2(i,j) = FT1(i,j) * W(i,j)

                        OTF"(i,j)
	W(i,j) = -----------------------
                 |OTF(i,j)|**2 + 1/SN**2

where FT1 and FT2 are the fourier transforms before and after restoration
respectively, W is the Wiener filter, OTF is the optical transfer function,
OTF" is the complex conjugate of OTF, and SN is the signal-to-noise ratio.

(NOTE:  a previous version of this proc, and of program WIENER, had a PASS
parameter that provided for iterative refinement of the output FFT, which
converged towards the reciprocal filter.  However, the same result can be
achieved by specifying a large value for parameter SN, so this was removed.)

The optional third input is the fourier transform of the desired point
spread function of the output, OTFD.  If this is specified, then the
restored transform produced by the above processing is multiplied by
this:

  FT2(final,i,j) = FT2(i,j) * OTFD(i,j)

Normally one desires a delta function PSF, and OTFD is not specified.

.page
HISTORY

  may1985 ...lwk...  original version
  18sep90 ...lwk... replaced APFLAG/FT2/FFT22 by proc FFT2 (which
                     uses FFT2AP instead of FT2)
  26sep90 ...lwk... renamed param IDSF to SCRATCH and added it to FFT2 call
  08may95 ...ams... (CRI) MSTP S/W CONVERSION (made portable for UNIX)
  20mar03 ...lwk... removed parameter PASS (JJL did the same in WIENER)

 Current Cognizant Programmer:  L.W.Kamp

.LEVEL1
.vari INP 
1. Primary input image.
2. PSF image or OTF.
3. (Optional) desired OTF.
.vari OUT
restored output image.
.vari SIZE 
(SL,SS,NL,NS)
.vari SL 
Starting line.
.vari SS 
Starting sample.
.vari NL
Number of lines.
.vari NS
Number of samples.
.vari SN 
Signal-to noise ratio.
.vari IFFT
File to contain fourier
transform of input.
.vari OFFT
File to contain fourier
transform of output.
.vari MODE
PSF or OTF.
.vari PSF
File to contain point 
spread function.
(Only if MODE=PSF)
.vari OTF
File to contain fourier
transform of PSF.
(Only if MODE=PSF)
.vari SCRATCH
Scratch file for proc FFT22.
.vari AREA 
Area of PSF image containing
the PSF.
(Required if MODE=PSF)
.vari SHIFT 
Allow PSF to shift?
(Only if MODE=PSF)
.LEVEL2
.vari INP
The input files to RESTORW are:

1. The image to be restored.

2. Either:
 2a. (if MODE=PSF) the image containing the point spread function (PSF),
    which will be extracted using the AREA and SHIFT parameters by
    invoking program PSF,
   or:
 2b. (if MODE=OTF, default) the optical transfer function (OTF) of the
    degraded image, i.e., the fourier transform of the PSF.  

3. Optionally, the fourier transform of the desired output point
  spread function.  Normally one desires a delta function for this,
  and this input is not specified.
.VARIABLE OUT
The output file is the restored image.
.vari SIZE 
The standard Vicar2 size parameter: (SL,SS,NL,NS), or:
 (starting line, starting sample, number of lines, number of samples).

This parameter defines the area in the input image which will be used
for processing.
.vari SL 
Starting line.
See SIZE.
.vari SS 
Starting sample.
See SIZE.
.vari NL
Number of lines.
See SIZE.
.vari NS
Number of samples.
See SIZE.
.vari SN
This parameter specifies the signal-to-noise ratio to be used in the
restoration.  See HELP RESTORW for its use in the algorithm.
.vari IFFT
This parameter allows the user to specify a file to contain the
fourier transform of the primary input.  Default is a file in the
local directory.

Possible reasons to specify this include problems in the default
directory, a desire to save this file for further processing, or
spreading of the I/O to different disks to avoid head contention.
.vari OFFT
This parameter allows the user to specify a file to contain the
fourier transform of the output image.  Default is a file in the
local directory.

Possible reasons to specify this include problems in the default
directory, a desire to save this file for further processing, or
spreading of the I/O to different disks to avoid head contention.
.vari MODE
This keyword parameter allows the user to specify whether the procedure
should compute the optical transfer function (OTF) from a point spread
function (PSF) contained in the second input image, or whether the
OTF will be supplied directly by the user.

MODE = PSF: second input is an image containing the PSF.  In this case
           the parameter AREA must be specified.

MODE = OTF: second input is the optical transfer function.  In this case,
           the parameters AREA, SHIFT, OTF, and PSF are ignored.

.vari PSF
This parameter allows the user to specify a file to contain the
point spread function, if MODE=PSF has been specified.  Default is
a file in the local directory.

Possible reasons to specify this include problems in the default
directory, a desire to save this file for further processing, or
spreading of the I/O to different disks to avoid head contention.
.vari OTF
This parameter allows the user to specify a file to contain the
fourier transform of the PSF (if MODE=PSF has been specified.)
Default is a file in the local directory.

Possible reasons to specify this include problems in the default
directory, a desire to save this file for further processing, or
spreading of the I/O to different disks to avoid head contention.
.vari SCRATCH
This parameter allows the user to specify a file to contain the
scratch file needed by procedure FFT22.
Default is a file in the local directory.

Possible reasons to specify this include problems in the default
directory, a desire to save this file for further processing, or
spreading of the I/O to different disks to avoid head contention.
.vari AREA 
This parameter specifies the area of second input image containing
the PSF, if MODE=PSF has been specified. (Otherwise it is ignored.)

It follows the same convention as the SIZE parameter, i.e.:
 (starting line, starting sample, number of lines, number of samples).

The SHIFT keyword specifies whether the final PSF may lie outside this
area, after the centroid has been determined.
.vari SHIFT 
This parameter specifies whether the PSF extracted from the second input
(if MODE=PSF has been specified) will be allowed to lie partially ooutside
the area specified by the AREA parameter, after its centroid has been
determined.  If NOSHIFT is specified, then the size of the PSF will be
reduced if necessary to keep it inside the specified area.
.END
$ Return
$!#############################################################################
$Test_File:
$ create tstrestorw.pdf
procedure
refgbl $echo
refgbl $autousage
PARM DIR TYPE=STRING DEFAULT="/project/test_work/testdata/mipl/vgr/"
LOCAL NEPIMG TYPE=STRING
LOCAL STRIMG TYPE=STRING
LOCAL RSTWIMG TYPE=STRING
body
let $autousage="none"
let _onfail="continue"
let $echo="yes"
let NEPIMG= "&DIR"//"neptune.img"
let STRIMG= "&DIR"//"star.img"
let RSTWIMG= "&DIR"//"restw.img"
!
! RESTORE IMAGE IN NEPTUNE.IMG, USING STAR AS PSF:
restorw (&NEPIMG,&STRIMG) +
 RESTW AREA=(10,10,30,30) MODE=PSF
!
! LIST PART OF PSF IMAGE (FOR PSF TEST):
list PSF (1,1,20,20)
!
! COMPARE RESULT WITH STANDARD RESULT:
DIFPIC (RESTW,&RSTWIMG) X
!
! NOTE THAT THERE IS A DIFFERENCE OF ABOUT 0.25 % BETWEEN THE LATTER
! TWO IMAGES, BECAUSE THE IMAGE IN TESTDATA WAS CREATED BEFORE A CHANGE
! MADE TO WIENER BY JJL, ADDING A NORMALIZATION FACTOR OF 1+(1/SN^2).
end-proc
$ Return
$!#############################################################################
