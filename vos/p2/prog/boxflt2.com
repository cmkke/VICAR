$!****************************************************************************
$!
$! Build proc for MIPL module boxflt2
$! VPACK Version 1.9, Wednesday, December 17, 2014, 13:22:01
$!
$! Execute by entering:		$ @boxflt2
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
$ write sys$output "*** module boxflt2 ***"
$!
$ Create_Source = ""
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
$ if (f$locate("COMP", primary) .eqs. 0) then gosub Set_Exe_Options
$ if (f$locate("ALL", primary) .eqs. 0) then gosub Set_All_Options
$ if (f$locate("STD", primary) .eqs. 0) then gosub Set_Default_Options
$ if (f$locate("SYS", primary) .eqs. 0) then gosub Set_Sys_Options
$ if primary .eqs. " " then gosub Set_Default_Options
$ if primary .eqs. "REPACK" then Create_Repack = "Y"
$ if primary .eqs. "SORC" .or. primary .eqs. "SOURCE" then Create_Source = "Y"
$ if primary .eqs. "PDF" then Create_PDF = "Y"
$ if primary .eqs. "TEST" then Create_Test = "Y"
$ if primary .eqs. "IMAKE" then Create_Imake = "Y"
$ if (f$locate("CLEAN", primary) .eqs. 0) then Do_Make = "Y"
$!
$ if (Create_Source .or. Create_Repack .or. Create_PDF .or. Create_Test .or -
        Create_Imake .or. Do_Make) -
        then goto Parameter_Okay
$ write sys$output "Invalid argument given to boxflt2.com file -- ", primary
$ write sys$output "For a list of valid arguments, please see the header of"
$ write sys$output "of this .com file."
$ exit
$!
$Parameter_Okay:
$ if Create_Repack then gosub Repack_File
$ if Create_Source then gosub Source_File
$ if Create_PDF then gosub PDF_File
$ if Create_Test then gosub Test_File
$ if Create_Imake then gosub Imake_File
$ if Do_Make then gosub Run_Make_File
$ exit
$!
$ Set_Unpack_Options:
$   Create_Repack = "Y"
$   Create_Source = "Y"
$   Create_PDF = "Y"
$   Create_Test = "Y"
$   Create_Imake = "Y"
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
$   Create_PDF = "Y"
$ Return
$!
$ Set_All_Options:
$   Create_Source = "Y"
$   Create_Imake = "Y"
$   Do_Make = "Y"
$   Create_PDF = "Y"
$ Return
$!
$ Set_Sys_Options:
$   Create_Source = "Y"
$   Create_Imake = "Y"
$   Create_PDF = "Y"
$   Do_Make = "Y"
$ Return
$!
$Run_Make_File:
$   if F$SEARCH("boxflt2.imake") .nes. ""
$   then
$      vimake boxflt2
$      purge boxflt2.bld
$   else
$      if F$SEARCH("boxflt2.bld") .eqs. ""
$      then
$         gosub Imake_File
$         vimake boxflt2
$      else
$      endif
$   endif
$   if (primary .eqs. " ")
$   then
$      @boxflt2.bld "STD"
$   else
$      @boxflt2.bld "''primary'" "''secondary'"
$   endif
$ Return
$!#############################################################################
$Repack_File:
$ create boxflt2.repack
$ DECK/DOLLARS="$ VOKAGLEVE"
$ vpack boxflt2.com -mixed -
	-s boxflt2.f boxflt2c.c -
	-i boxflt2.imake -
	-p boxflt2.pdf -
	-t tstboxflt2.pdf tstboxflt2.log
$ Exit
$ VOKAGLEVE
$ Return
$!#############################################################################
$Source_File:
$ create boxflt2.f
$ DECK/DOLLARS="$ VOKAGLEVE"
      INCLUDE 'VICMAIN_FOR'
C**********************************************************************
      subroutine main44
C
C        MODIFIED FOR VAX CONVERSION BY ALAN MAZER 28-JUL-83
C        CONVERTED TO VICAR2 BY J. REIMER 14-AUG-85
C
C        9-88  SP   MODIFIED BECAUSE DIV HAS BEEN RENAMED TO DIVV.
C        4-94  CRI  MSTP S/W CONVERSION (VICAR PORTING)
C
	implicit none
      	external main
      COMMON /C1/ IUNIT,OUNIT,SL,SS,NLO,NSO,FORMAT,fmt,HIGH,NLW,NSW,
     &            ICYCLE,JCYCLE,IDC 

      	integer*4 iunit,ounit,stat,sl,ss,high
	integer*4 nlo,nso,nlw,nsw,icycle,jcycle,icode
	integer*4 ns,nli,nsi,idef,icount
	real*4 idc
	character*8 fmt(4)/'BYTE','HALF','FULL','REAL'/
      	character*8 format
      	logical*4 XVPTST

C        SET DEFAULTS AND INITIALIZE
      nlw=11
      nsw=11
      icycle=0
      jcycle=0
      idc=128.

C
      call ifmessage('BOXFLT2  02-May-2011 (64-bit) RJB ')
C
C          OPEN INPUT DATA SET
      call xveaction('SA',' ')
      call xvunit(iunit,'INP',1,stat,' ')
      call xvopen(iunit,stat,'OPEN_ACT','SA','IO_ACT','SA',' ')
C
C        GET DATA FORMAT AND CHECK
      call xvget(iunit,stat,'FORMAT',format,' ')

	icode = 0
	if (format.eq.'BYTE') icode=1
	if (format.eq.'HALF'.or.format.eq.'WORD') icode=2
	if (format.eq.'FULL') icode=3
	if (format.eq.'REAL') icode=4
	if (icode.eq.0) then
		call xvmessage('??E - Unknown data format for input image',' ')
		call abend  
	endif
	call xvclose(iunit,stat,' ')
	call xvopen(iunit,stat,'OPEN_ACT','SA','IO_ACT','SA',
     &		'I_FORMAT',fmt(icode),'U_FORMAT',fmt(4),' ')		!FMT(INCODE),' ')

C
C        GET SIZE INFORMATION AND CHECK
      call xvsize(sl,ss,nlo,nso,nli,nsi)
      if(sl+nlo-1 .gt. nli) then
         call xvmessage('??E - Number of lines requested exceeds input size',' ')
         call abend
      endif
      if(ss+nso-1 .gt. nsi) then
         call xvmessage('??E - Number of samples requested exceeds input size',' ')
         call abend
      endif
C
C        OPEN OUTPUT DATA SET
      call xvunit(ounit,'OUT',1,stat,' ')
	call xvopen(ounit,stat,'OP','WRITE','U_NL',nlo,'U_NS',nso,
     & 'OPEN_ACT','SA','IO_ACT','SA','O_FORMAT',fmt(icode),
     & 'U_FORMAT',fmt(4),' ')				!,FMT(OUTCODE),' ')

C           PROCESS PARAMETERS
C        'HIGHPASS'
	high = 0
      if(xvptst('HIGHPASS')) high=1
C        'NLW'
      call xvparm('NLW',nlw,icount,idef,1)
      if(nlw/2*2 .eq. nlw) call xvmessage('??W - WARNING-nlw is an even integer',' ')
C        'NSW'
      call xvparm('NSW',nsw,icount,idef,1)
      if(nsw/2*2 .eq. nsw) call xvmessage('??W - WARNING-nsw is an even integer',' ')
C        'CYCLE'
      if (xvptst('CYCLE')) then
         icycle=1
         jcycle=1
      endif
C        'SCYCLE'
      if (xvptst('SCYCLE')) icycle=1
C        'LCYCLE'
      if (xvptst('LCYCLE')) jcycle=1
C        'DCLEVEL'
      call xvparm('DCLEVEL',idc,icount,idef,1)

      ns=nso+nsw
c 4*ns is number of bytes to reserve
c 			  ISUM,TBUF,INBUF,OUTBUF,IDBUF
      CALL STACKA(7,MAIN,5,4*ns,4*ns,4*ns,4*ns,4*ns)	!(7,MAIN,5,4*NS,4*NS,2*NS,2*NS,2*NS)

C        CLOSE DATA SETS
      call xvclose(iunit,stat,' ')
      call xvclose(ounit,stat,' ')
C
      return
      end
C**********************************************************************
      SUBROUTINE MAIN(ISUM,LX,TBUF,MX,INBUF,IX,OUTBUF,JX,IDBUF,KX)

	implicit none
      COMMON /C1/ IUNIT,OUNIT,SL,SS,NLO,NSO,FORMAT,fmt,HIGH,NLW,NSW,
     &            ICYCLE,JCYCLE,IDC 
	
        integer*4 iunit,ounit,stat,ss,sl,nlo,nso,high,nlw,nsw
	integer*4 icycle,jcycle,lx,mx,ix,jx,kx,icode
	integer*4 i,l,m,n,iline,jline
c	integer*4 nlx,nsx		! for xvget now commented out
c      INTEGER*2 INBUF(1),OUTBUF(1),IDBUF(1)
	real*4 isum(lx),tbuf(mx),idc,nlwnsw
	real*4 inbuf(ix),outbuf(jx),idbuf(kx)
	character*8 fmt(4)
      	character*8 format
	
	icode = 0
        if (format.eq.'BYTE') icode=1
        if (format.eq.'HALF'.or.format.eq.'WORD') icode=2
        if (format.eq.'FULL') icode=3
        if (format.eq.'REAL') icode=4

      m=nlw/2+1
      n=nsw/2+1
      l=n-1
c      CALL ZIA(ISUM,NSO+NSW-1)  		!need to replace 
c	zero out the expanded (padded) buffer
	do i=1,nso+nsw-1
	   isum(i)=0.0
	enddo	
c
c	goes thru file, reflects or cycles and writes out
c	to ounit temporarily

      do i=1,nlo
          iline=1-m+i
          if (jcycle .eq. 0) then
              if (iline .lt. 1) iline=2-iline
              if (iline .gt. nlo) iline=nlo+nlo-iline
          else              	      
              if (iline .lt. 1) iline=nlo+iline
              if (iline .gt. nlo) iline=iline-nlo
          endif
c          call xvread(iunit,inbuf(n),stat,'LINE',sl+iline-1,
	    call xvread(iunit,inbuf(n),stat,'LINE',sl+iline-1,
     &                'SAMP',ss,'NSAMPS',nso,' ')  
 
          if (i.le.nlw) then
              if (n.gt.1) then
                  if (icycle .eq. 0) then
                      call rflct(n,nso,inbuf)
                  else 
                      call cycle(n,nso,inbuf)
                  endif
              endif
c	isum is output - it is the expanded buffer
              call addv(7,nso+nsw-1,inbuf,isum,1,1)
          endif
          call xvwrit(ounit,inbuf(n),stat,' ')
      enddo

      call zaire(tbuf,isum,nso,nsw)
	nlwnsw = nlw*nsw
      call divv(7,nso,nlwnsw,tbuf,0,1)				!formerly 7 was 4 call divv(4,nso,nlw*nsw,tbuf,0,1)
      call mve(7,nso,tbuf,outbuf,1,1)				!formerly 7 was -6
c	now we have finished updating output (same size as oiginal but with 
C        RE-OPEN OUTPUT TO REREAD
      call xvclose(ounit,stat,' ')
      call xvopen(ounit,stat,'OP','UPDATE','I_FORMAT',fmt(icode),'U_FORMAT',fmt(4),' ')
c	call xvget(iunit,stat,'NL',nlx,'NS',nsx,' ')
      iline=(nlw+1)/2

c
      do i=2,nlo
c          Call xvread(ounit,idbuf(n),stat,'LINE',i-1,' ')
	  call xvread(ounit,idbuf(n),stat,'LINE',i-1,' ')
          call xvwrit(ounit,outbuf,stat,'LINE',i-1,' ')

          if (n.gt.1) then
              if (icycle .eq. 0) then 
                  call rflct(n,nso,idbuf)
              else 
                  call cycle(n,nso,idbuf)
              endif
          endif
          call rsubv(7,nso+nsw-1,idbuf,isum,1,1)		!formerly 7 was 6

          jline=iline+1
          if (jcycle .eq. 0.and.jline.gt.nlo) jline=nlo+nlo-jline
          if (jcycle.ne.0 .and. jline .gt. nlo) jline=jline-nlo
c          call xvread(iunit,inbuf(n),stat,'LINE',sl+jline-1,
	   call xvread(iunit,inbuf(n),stat,'LINE',sl+jline-1,
     &                'SAMP',SS,'NSAMPS',nso,' ')        
          if (n.gt.1) then
              if (icycle .eq. 0) then 
                  call rflct(n,nso,inbuf)
              else 
                  call cycle(n,nso,inbuf)
              endif
          endif
          call addv(7,nso+nsw-1,inbuf,isum,1,1)		!formerly 7 was 6
          call zaire(tbuf,isum,nso,nsw)	
          call divv(7,nso,nlwnsw,tbuf,0,1)		!formerly 7 was 4	call divv(4,nso,nlw*nsw,tbuf,0,1)
          call mve(7,nso,tbuf,outbuf,1,1)		!formerly 7 ws -6
          iline=iline+1
      enddo

      call xvwrit(ounit,outbuf,stat,'LINE',i-1,' ')

      if (high .ne. 1) return

C        DO HIGHPASS OPERATION
      do i=1,nlo
          call xvread(iunit,inbuf,stat,'LINE',sl+i-1,
     &                'SAMP',SS,'NSAMPS',nso,' ')
          call xvread(ounit,outbuf,stat,'LINE',i,' ')
          call rsubv(7,nso,outbuf,inbuf,1,1)		!formerly 7 was 2
          call addv(7,nso,idc,inbuf,0,1)		!formerly 7 was -6
          if (format.eq.'BYTE') call cutoff(inbuf,nso)
          call xvwrit(ounit,inbuf,stat,'LINE',I,' ')
      enddo

      call xvmessage('HIGH PASS FILTER PERFORMED.',' ')

      return
      end
C**********************************************************************
      SUBROUTINE RFLCT(N,NSO,INBUF)
	implicit none
	real*4 inbuf(1)
	integer*4 l,n,nso
c      INTEGER*2 INBUF(1)

      l=n-1
      call mve(7,l,inbuf(n+1),inbuf(n-1),1,-1)		!formerly 7 was 2
      call mve(7,l,inbuf(nso+l-1),inbuf(nso+n),-1,1)	!formerly 7 was 2

      return
      end
C**********************************************************************
      SUBROUTINE CYCLE(N,NSO,INBUF)
        implicit none
        real*4 inbuf(1)
        integer*4 l,n,nso

c      INTEGER*2 INBUF(1)

      l=n-1
      call mve(7,l,inbuf(nso+1),inbuf(1),1,1)		!formerly 7 was 2
      call mve(7,l,inbuf(n),inbuf(n+nso),1,1)		!formerly 7 was 2

      return
      end
C**********************************************************************
      SUBROUTINE CUTOFF(INBUF,NSO)
        implicit none
        real*4 inbuf(1)
        integer*4 i,nso
c      INTEGER*2 INBUF(1)

      do i=1,nso
          if (inbuf(i).gt.255) inbuf(i)=255
          if (inbuf(i).lt.0) inbuf(i)=0
      enddo

      return
      end
$ VOKAGLEVE
$!-----------------------------------------------------------------------------
$ create boxflt2c.c
$ DECK/DOLLARS="$ VOKAGLEVE"
/*  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	VICAR SUBROUTINE                                            SUBV

	General routine for subtracting arrays.  Array B is replaced with the
	product of subtracting A from B.  A and B can be of different data 
        types as indicated

	DCODE......Data types
	           =1,   A is byte         B is byte
	           =2,   A is halfword     B is halfword
	           =3,   A is byte         B is halfword
               =4,   A is fullword     B is fullword
	           =5,   A is byte         B is fullword
               =6,   A is halfword     B is fullword
	           =7,   A is real(single) B is real
	           =8,   A is double       B is double
               =9,   A is real         B is double
                  negative values -1 to -9 reverse of above
*/    
/*                     ADAPTED FROM ASU VERSION  */
/* April 19, 2011 - rjb - added prototypes and zvproto.h      */
/* Jun 20, 2011 - rjb - cast varibles to avoid warnings with gcc 4.4.4 */
#include "xvmaininc.h"
#include "ftnbridge.h"
#include "zvproto.h"        //resolves zvmessage and zabend

/* prototypes */
void FTN_NAME (rsubv)(int *dcode,int *n,void *avec,void *bvec,int *inca,int *incb);
void rzsubv(int dcode,int n,void *avec,void *bvec,int inca,int incb);
void FTN_NAME (zaire)(float out[],float in[],int *nsaddr,int *nswaddr);

/************************************************************************/
/* Fortran-Callable Version                                             */
/************************************************************************/


void FTN_NAME (rsubv)(dcode, n, avec, bvec, inca, incb)
     int *dcode, *n, *inca, *incb;
     void *avec, *bvec;
{
   rzsubv( *dcode, *n, avec, bvec, *inca, *incb);
}

/************************************************************************/
/* C-Callable Version                                                   */
/************************************************************************/

void rzsubv(dcode, n, avec, bvec, inca, incb)
   int dcode, n, inca, incb;
   void *avec, *bvec;
{
  int i;
  
  /* vectors */
  unsigned char *bytein,   *byteout;
  short         *halfin,   *halfout;
  long          *fullin,   *fullout;
  float         *realin,   *realout;
  double        *doublein, *doubleout;
  
  
  switch (dcode) {
  case -1:
  case 1:
    bytein = (unsigned char *) avec;
    byteout = (unsigned char *) bvec;
    for (i=0; i < n; i++, bytein+=inca, byteout+=incb) {
      *byteout = (unsigned char)(*byteout - *bytein);
    }
    break;
  case -2:
  case 2:
    halfin = (short *) avec;
    halfout = (short *) bvec;
    for (i = 0; i <n; i++, halfin+=inca, halfout+=incb) {
      *halfout = (short)(*halfout - *halfin);
    }
    break;
  case -3:
    halfin = (short *) avec;
    byteout = (unsigned char *) bvec;
    for (i = 0; i<n ;i++,halfin+=inca, byteout+=incb) {
      *byteout = (unsigned char)(*byteout - *halfin);
    }
    break;
  case 3:
    bytein = (unsigned char *) avec;
    halfout = (short *) bvec;
    for (i = 0; i< n; i++, bytein+=inca,halfout+=incb){
      *halfout = (short)(*halfout - *bytein);
    }
    break;
  case -4:
  case  4:
    fullin = (long *) avec;
    fullout = (long *) bvec;
    for (i = 0; i<n ;i++,fullin+=inca,fullout+=incb){
      *fullout = *fullout - *fullin;
    }
    break;
  case -5:
    fullin = (long *) avec;
    byteout = (unsigned char *) bvec;
    for (i = 0; i< n; i++,fullin+=inca,byteout+=incb){
      *byteout = (unsigned char)(*byteout - *fullin);
    }
    break;
  case 5:
    bytein = (unsigned char *) avec;
    fullout = (long *) bvec;
    for (i = 0; i< n; i++, bytein+=inca,fullout+=incb){
      *fullout = *fullout - *bytein;
    }
    break;
  case -6:
    fullin = (long *) avec;
    halfout = (short *) bvec;
    for (i = 0;i< n; i++, fullin+=inca,halfout+=incb){
        *halfout = (short)(*halfout - *fullin);
    }
    break;
  case 6:
    halfin = (short *) avec;
    fullout = (long *) bvec;
    for (i = 0; i< n; i++, halfin+=inca,fullout+=incb){
      *fullout = *fullout - *halfin;
    }
    break;
  case -7:
  case  7:
    realin = (float *) avec;
    realout = (float *) bvec;
    for (i = 0;i< n; i++, realin+=inca,realout+=incb){
      *realout = *realout - *realin;
    }
    break;
  case -8:
  case  8:
    doublein = (double *) avec;
    doubleout = (double *) bvec;
    for (i = 0; i< n; i++, doublein+=inca,doubleout+=incb){
      *doubleout = *doubleout - *doublein;
    }
    break;
  case -9:
    doublein = (double *) avec;
    realout = (float *) bvec;
    for (i = 0; i< n; i++, doublein+=inca,realout+=incb){
      *realout = (float)(*realout - *doublein);
    }
    break;
  case 9:
    realin = (float *) avec;
    doubleout = (double *) bvec;
    for (i = 0; i< n; i++,realin+=inca,doubleout+=incb){
      *doubleout = *doubleout - *realin;
    }
    break;
  default:    
    zvmessage("*** SUBV - Illegal DCODE","");
    zabend();
    break;
  }
}


/************************************************************************/
/* Fortran-Callable ZAIRE                                             */
/************************************************************************/

/* Apr-19-2011 - R. J. Bambery - changed from int to float      */
void FTN_NAME (zaire)(out,in,nsaddr,nswaddr)
      float out[],in[];
      int *nsaddr,*nswaddr;

{
      int ns,nsw,outptr,inptr;
      int tmp,i;
      float total;
      ns = *nsaddr;
      nsw = *nswaddr;
      inptr = 0;
      outptr = 0; 
      tmp = inptr;
/*                                         */
      total = 0.0;
      for (i=1;i<=nsw;i++) {
        total += in[inptr++];
      }
/*                                         */
      ns--;
      out[outptr++] = total;
/*                                         */
      for (i=1;i<=ns;i++) {
          total = total - in[tmp++] + in[inptr++];
          out[outptr++] = total;
      }
}
$ VOKAGLEVE
$ Return
$!#############################################################################
$Imake_File:
$ create boxflt2.imake
/***********************************************************************

                     IMAKE FILE FOR PROGRAM boxflt2

   To Create the build file give the command:

		$ vimake boxflt2			(VMS)
   or
		% vimake boxflt2			(Unix)


************************************************************************/


#define PROGRAM	boxflt2
#define R2LIB

#define MODULE_LIST boxflt2.f boxflt2c.c

#define MAIN_LANG_FORTRAN
#define USES_FORTRAN
#define USES_C
#define LIB_RTL
#define LIB_TAE
#define LIB_P2SUB
/************************* End of Imake file ***************************/
$ Return
$!#############################################################################
$PDF_File:
$ create boxflt2.pdf
process help=*
PARM INP TYPE=STRING
PARM OUT TYPE=STRING
PARM SIZE TYPE=INTEGER COUNT=4 DEFAULT=(1,1,0,0)
PARM SL TYPE=INTEGER DEFAULT=1
PARM SS TYPE=INTEGER DEFAULT=1
PARM NL TYPE=INTEGER DEFAULT=0
PARM NS TYPE=INTEGER DEFAULT=0
PARM NSW TYPE=INTEGER DEFAULT=11
PARM NLW TYPE=INTEGER DEFAULT=11
PARM FILTER TYPE=KEYWORD VALID=(HIGHPASS,LOWPASS) DEFAULT=LOWPASS
PARM DCLEVEL TYPE=real DEFAULT=128.
PARM EDGE TYPE=KEYWORD VALID=(CYCLE,LCYCLE,SCYCLE,REFLECT) DEFAULT=REFLECT
END-PROC
.TITLE
BOXFLT2 - Box Filter Convolution Program
.HELP
PURPOSE:
boxflt2 applies a low-pass filter to an input image by taking the local
mean of all pixels contained within a prescribed window centered at
each pixel of the input image.  This mean then replaces the input value.
A highpass option is available which replaces each input value with the
difference between the input and the local mean, plus a constant DC-level
offset.

EXECUTION:

Examples
	boxflt2  INP  OUT  NLW=21  NSW=451

	This example performs a lowpass filter of size 451 samples by 21
	lines on the input. Reflection is performed at image boundaries.

	boxflt2  INP  OUT  NLW=101  NSW=1  'HIGHPASS  DCLEVEL=90  'CYCLE

	This examples performs a highpass filter of size 101 lines by 1
	sample with an output DCLEVEL of 90, performing cycling at the
	image boundaries.  (The omitted keywords are FILTER and EDGE,
	respectively.)

.page	
Modes of handling boundaries:
		a = pixel (1,1)		b = pixel (1,NS)
		c = pixel (NL,1)	d = pixel (NL,NS)
	+-------+-------+-------+	+-------+-------+-------+
	| d   c | c   d | d   c |	| a   b | a   b | a   b |
	|       |       |       |	|       |       |       |
	| b   a | a   b | b   a |	| c   d | c   d | c   d |
	|-------|-------|-------|	|-------|-------|-------|
	| b   a | a   b | b   a |	| a   b | a   b | a   b |
	|       |       |       |	|       |       |       |
	| d   c | c   d | d   c |	| c   d | c   d | c   d |
	|-------|-------|-------|	|-------|-------|-------|
	| d   c | c   d | d   c |	| a   b | a   b | a   b |
	|       |       |       |	|       |       |       |
	| b   a | a   b | b   a |	| c   d | c   d | c   d |
	+-------+-------+-------+	+-------+-------+-------+
		RELECTION			 CYCLING
.page
OPERATION:
boxflt2 performs a lowpass filter operation by taking the local mean of
all pixels contained within a prescribed window of NLW by NSW dimensions
centered at each pixel of the input image.  This mean then replaces the 
input value.  If the HIGHPASS option is specified, then the difference
between the input and the local mean plus a constant DC-level offset
replaces the input value. 

boxflt2 provides the user with the choice of using "reflection" or "cycling"
(wrap-around) at image boundaries.  In the default case, image reflection
is used, and may be depicted as above in the EXECUTION section.  If cycling
is desired, where the left boundary of the image is equivalent to the 
right boundary, and the upper boundary is equivalent to the lower boundary,
the reflection is performed as shown above in the CYCLING diagram.

.page
COMPARISONS to other filter programs

The FILTER program gives slightly different results with 1,1,1... etc
weights. FILTER has code that passed data out to a Floating Point
Systems Array Processor, AP-120B that did the convolution filter.
The array processor was supported on the IBM 270 and the DEC Vax.
In 1994 that code was emulated to work in a SUN unix environment.
FILTER does not provide boundary options

In 2010, Ray Bambery wrote a new convolution filtering program
GFILTER, from scratch. It gives the same results as BOXFLT2
with 1,1,1... filter weights. GFILTER provides zero boundaries,
reflection boundaries or wraparound boundaries.


.page
HISTORY

WRITTEN BY:  W. D. Benton, 1 June 1976
COGNIZANT PROGRAMMER:  R. J. Bambery
REVISION:  New
           Made Portable for UNIX   Richardson(CRI)  05-May-94 

    19-Apr-2011 - R. J. Bambery - Changed internals to operate 
                in REAL format. Now supports BYTE, HALF, FULL and
                REAL images
    02 May 2011 - R. J. Bambery - removed warning messages from gcc44 compiler

.LEVEL1
.VARIABLE INP
STRING - Input dataset
.VARIABLE OUT
STRING - Output dataset
.VARIABLE SIZE
INTEGER - Standard VICAR1 size field
.VARIABLE SL
INTEGER - Starting line
.VARIABLE SS
INTEGER - Starting sample
.VARIABLE NS
INTEGER - Number of lines
.VARIABLE NL
INTEGER - Number of samples
.VARIABLE NSW
INTEGER - Filter width in pixels
.VARIABLE NLW
INTEGER - Filter length in pixels
.VARIABLE FILTER
KEYWORD - Selects type of filtering (LOWPASS, HIGHPASS)
.VARIABLE DCLEVEL
INTEGER - Highpass constant
.VARIABLE EDGE
KEYWORD - Selects method of handling edges (REFLECT, CYCLE, LCYCLE, SCYCLE)
.LEVEL2
.VARIABLE NSW
NSW is the width in pixels of the box filter.  It must be less than
twice the image width in pixels and defaults to 11.
.VARIABLE NLW
NLS is the length in lines of the box filter.  It must be less than
twice the image length in pixels and defaults to 11.
.VARIABLE FILTER
FILTER=HIGHPASS specifies that the output is to be the highpass, rather than
the lowpass, version of the input, i.e., OUT = IN - LOW + DCLEVEL.
The default is lowpass filtering.
.VARIABLE DCLEVEL
Specifies (for highpass filter) the constant to be added to the 
difference (IN-LOW) in the highpass output image.  Default is 128.
.VARIABLE EDGE
Specifies image handling at image boundaries.  Setting EDGE=CYCLE or 'CYCLE
causes the program to treat the image as if it wrapped around at boundaries
in both directions.  'LCYCLE and 'SCYCLE cause wrap-around in the line and
sample direction only, respectively.  The default is for the program to 
reflect the image at the boundaries.
.END
$ Return
$!#############################################################################
$Test_File:
$ create tstboxflt2.pdf
procedure
refgbl $echo
refgbl $autousage
! Aug 28, 2013 - RJB
! TEST SCRIPT FOR BOXFLT2
! tests BYTE, HALF, FULL, REAL images
!
! Vicar Programs:
!       gen list
!
! External Programs
!   <none>
! 
! parameters:
!   <none>
!
! Requires NO external test data: 
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

body
let _onfail="stop"
let $autousage="none"
let $echo="yes"
!  TEST WITH BYTE IMAGES
!
gen boxfa 20 20 linc=10 sinc=4 ival=0
list boxfa
boxflt2 boxfa boxfb
list boxfb
boxflt2 boxfa boxfc nlw=1 nsw=1
list boxfc
boxflt2 boxfa boxfd 'highpass dclevel=100 'cycle
list boxfd
boxflt2 boxfa boxfe 'lcycle
list boxfe
boxflt2 boxfa boxff 'scycle
list boxff
boxflt2 boxfa boxfg 'reflect 'highpass
list boxfg
!  TEST WITH HALFWORD IMAGES
!
gen boxfh 20 20 linc=10 sinc=4 ival=-100 'half
list boxfh
boxflt2 boxfh boxfhb
list boxfhb
boxflt2 boxfh boxfhc nlw=1 nsw=1
list boxfhc
boxflt2 boxfh boxfhd 'highpass dclevel=100 'cycle
list boxfhd
boxflt2 boxfh boxfhe 'lcycle
list boxfhe
boxflt2 boxfh boxfhf 'scycle
list boxfhf
boxflt2 boxfh boxfhg 'reflect 'highpass
list boxfhg
!  TEST WITH FULLWORD IMAGES
!
gen boxff 20 20 linc=10 sinc=4 ival=-100 'full
list boxff
boxflt2 boxff boxffb
list boxffb
boxflt2 boxff boxffc nlw=1 nsw=1
list boxffc
boxflt2 boxff boxffd 'highpass dclevel=100 'cycle
list boxffd
boxflt2 boxff boxffe 'lcycle
list boxffe
boxflt2 boxff boxfff 'scycle
list boxfff
boxflt2 boxff boxffg 'reflect 'highpass
list boxffg
!  TEST WITH REAL IMAGES
!
gen boxfr 20 20 linc=10 sinc=4 ival=-100. 'real
list boxfr
boxflt2 boxfr boxfrb
list boxfrb
boxflt2 boxfr boxfrc nlw=1 nsw=1
list boxfrc
boxflt2 boxfr boxfrd 'highpass dclevel=100. 'cycle
list boxfrd
boxflt2 boxfr boxfre 'lcycle
list boxfre
boxflt2 boxfr boxfrf 'scycle
list boxfrf
boxflt2 boxfr boxfrg 'reflect 'highpass
list boxfrg
!

let $echo="no"
! 
end-proc
$!-----------------------------------------------------------------------------
$ create tstboxflt2.log
                Version 5C/16C

      ***********************************************************
      *                                                         *
      * VICAR Supervisor version 5C, TAE V5.2                   *
      *   Debugger is now supported on all platforms            *
      *   USAGE command now implemented under Unix              *
      *                                                         *
      * VRDI and VIDS now support X-windows and Unix            *
      * New X-windows display program: xvd (for all but VAX/VMS)*
      *                                                         *
      * VICAR Run-Time Library version 16C                      *
      *   '+' form of temp filename now avail. on all platforms *
      *   ANSI C now fully supported                            *
      *                                                         *
      * See B.Deen(RGD059) with problems                        *
      *                                                         *
      ***********************************************************

  --- Type NUT for the New User Tutorial ---

  --- Type MENU for a menu of available applications ---

gen boxfa 20 20 linc=10 sinc=4 ival=0
Beginning VICAR task gen
GEN Version 6
GEN task completed
list boxfa
Beginning VICAR task list

   BYTE     samples are interpreted as   BYTE   data
 Task:GEN       User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
     Samp     1       3       5       7       9      11      13      15      17      19
   Line
      1       0   4   8  12  16  20  24  28  32  36  40  44  48  52  56  60  64  68  72  76
      2      10  14  18  22  26  30  34  38  42  46  50  54  58  62  66  70  74  78  82  86
      3      20  24  28  32  36  40  44  48  52  56  60  64  68  72  76  80  84  88  92  96
      4      30  34  38  42  46  50  54  58  62  66  70  74  78  82  86  90  94  98 102 106
      5      40  44  48  52  56  60  64  68  72  76  80  84  88  92  96 100 104 108 112 116
      6      50  54  58  62  66  70  74  78  82  86  90  94  98 102 106 110 114 118 122 126
      7      60  64  68  72  76  80  84  88  92  96 100 104 108 112 116 120 124 128 132 136
      8      70  74  78  82  86  90  94  98 102 106 110 114 118 122 126 130 134 138 142 146
      9      80  84  88  92  96 100 104 108 112 116 120 124 128 132 136 140 144 148 152 156
     10      90  94  98 102 106 110 114 118 122 126 130 134 138 142 146 150 154 158 162 166
     11     100 104 108 112 116 120 124 128 132 136 140 144 148 152 156 160 164 168 172 176
     12     110 114 118 122 126 130 134 138 142 146 150 154 158 162 166 170 174 178 182 186
     13     120 124 128 132 136 140 144 148 152 156 160 164 168 172 176 180 184 188 192 196
     14     130 134 138 142 146 150 154 158 162 166 170 174 178 182 186 190 194 198 202 206
     15     140 144 148 152 156 160 164 168 172 176 180 184 188 192 196 200 204 208 212 216
     16     150 154 158 162 166 170 174 178 182 186 190 194 198 202 206 210 214 218 222 226
     17     160 164 168 172 176 180 184 188 192 196 200 204 208 212 216 220 224 228 232 236
     18     170 174 178 182 186 190 194 198 202 206 210 214 218 222 226 230 234 238 242 246
     19     180 184 188 192 196 200 204 208 212 216 220 224 228 232 236 240 244 248 252   0
     20     190 194 198 202 206 210 214 218 222 226 230 234 238 242 246 250 254   2   6  10
boxflt2 boxfa boxfb
Beginning VICAR task boxflt2
BOXFLT2  02-May-2011 (64-bit) RJB
list boxfb
Beginning VICAR task list

   BYTE     samples are interpreted as   BYTE   data
 Task:GEN       User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
 Task:BOXFLT2   User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
     Samp     1       3       5       7       9      11      13      15      17      19
   Line
      1      38  38  39  41  44  47  51  55  59  63  67  71  75  79  83  86  89  90  92  92
      2      39  39  40  42  44  48  52  56  60  64  68  72  76  80  84  87  90  91  92  93
      3      41  42  43  45  47  50  54  58  62  66  70  74  78  82  86  90  92  94  95  96
      4      46  46  47  49  52  55  59  63  67  71  75  79  83  87  91  94  97  99 100 100
      5      52  53  54  56  58  61  65  69  73  77  81  85  89  93  97 101 103 105 106 106
      6      60  61  62  64  66  70  74  78  82  86  90  94  98 102 106 109 111 113 114 115
      7      70  71  72  74  76  80  84  88  92  96 100 104 108 112 116 119 121 123 124 125
      8      80  81  82  84  86  90  94  98 102 106 110 114 118 122 126 129 131 133 134 135
      9      90  91  92  94  96 100 104 108 112 116 120 124 128 132 136 139 141 143 144 145
     10     100 101 102 104 106 110 114 118 122 126 130 134 138 142 146 149 151 153 154 155
     11     110 111 112 114 116 120 124 128 132 136 140 144 148 152 156 159 161 163 164 165
     12     120 121 122 124 126 130 134 138 142 146 150 154 158 162 166 169 171 173 174 175
     13     130 131 132 134 136 140 144 148 152 156 160 164 168 172 176 179 181 183 184 185
     14     140 141 142 144 146 150 154 158 162 166 170 174 178 182 183 187 189 191 192 192
     15     150 151 152 154 156 160 164 168 172 176 180 184 185 187 187 188 189 190 192 192
     16     159 159 160 162 164 168 172 176 180 184 188 192 194 195 193 194 195 197 198 198
     17     165 165 166 168 171 174 178 182 186 190 194 198 200 202 199 201 201 203 204 204
     18     170 170 171 173 175 179 183 187 191 195 199 203 204 206 204 205 206 207 209 209
     19     172 173 174 176 178 181 185 189 193 197 201 205 207 209 207 208 208 210 211 212
     20     173 174 175 176 179 182 186 190 194 198 202 206 208 210 208 209 209 211 212 213
boxflt2 boxfa boxfc nlw=1 nsw=1
Beginning VICAR task boxflt2
BOXFLT2  02-May-2011 (64-bit) RJB
list boxfc
Beginning VICAR task list

   BYTE     samples are interpreted as   BYTE   data
 Task:GEN       User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
 Task:BOXFLT2   User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
     Samp     1       3       5       7       9      11      13      15      17      19
   Line
      1       0   4   8  12  16  20  24  28  32  36  40  44  48  52  56  60  64  68  72  76
      2      10  14  18  22  26  30  34  38  42  46  50  54  58  62  66  70  74  78  82  86
      3      20  24  28  32  36  40  44  48  52  56  60  64  68  72  76  80  84  88  92  96
      4      30  34  38  42  46  50  54  58  62  66  70  74  78  82  86  90  94  98 102 106
      5      40  44  48  52  56  60  64  68  72  76  80  84  88  92  96 100 104 108 112 116
      6      50  54  58  62  66  70  74  78  82  86  90  94  98 102 106 110 114 118 122 126
      7      60  64  68  72  76  80  84  88  92  96 100 104 108 112 116 120 124 128 132 136
      8      70  74  78  82  86  90  94  98 102 106 110 114 118 122 126 130 134 138 142 146
      9      80  84  88  92  96 100 104 108 112 116 120 124 128 132 136 140 144 148 152 156
     10      90  94  98 102 106 110 114 118 122 126 130 134 138 142 146 150 154 158 162 166
     11     100 104 108 112 116 120 124 128 132 136 140 144 148 152 156 160 164 168 172 176
     12     110 114 118 122 126 130 134 138 142 146 150 154 158 162 166 170 174 178 182 186
     13     120 124 128 132 136 140 144 148 152 156 160 164 168 172 176 180 184 188 192 196
     14     130 134 138 142 146 150 154 158 162 166 170 174 178 182 186 190 194 198 202 206
     15     140 144 148 152 156 160 164 168 172 176 180 184 188 192 196 200 204 208 212 216
     16     150 154 158 162 166 170 174 178 182 186 190 194 198 202 206 210 214 218 222 226
     17     160 164 168 172 176 180 184 188 192 196 200 204 208 212 216 220 224 228 232 236
     18     170 174 178 182 186 190 194 198 202 206 210 214 218 222 226 230 234 238 242 246
     19     180 184 188 192 196 200 204 208 212 216 220 224 228 232 236 240 244 248 252   0
     20     190 194 198 202 206 210 214 218 222 226 230 234 238 242 246 250 254   2   6  10
boxflt2 boxfa boxfd 'highpass dclevel=100 'cycle
Beginning VICAR task boxflt2
BOXFLT2  02-May-2011 (64-bit) RJB
HIGH PASS FILTER PERFORMED.
list boxfd
Beginning VICAR task list

   BYTE     samples are interpreted as   BYTE   data
 Task:GEN       User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
 Task:BOXFLT2   User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
     Samp     1       3       5       7       9      11      13      15      17      19
   Line
      1       0   0   0   1   7  10  10  10  10  10  10  10  12  14  18  25  33  40  47  54
      2       0   7  14  20  25  28  28  28  28  28  28  28  30  32  36  44  51  58  65  73
      3      18  25  33  38  43  46  46  46  46  46  46  46  48  50  54  62  69  76  84  91
      4      36  44  51  56  61  64  64  64  64  64  64  64  66  68  73  80  87  94 102 109
      5      52  60  67  72  77  82  82  82  82  82  82  82  84  87  89  96 103 110 118 125
      6      64  71  79  86  93 100 100 100 100 100 100 100 100 100 100 108 115 122 130 137
      7      64  71  79  86  93 100 100 100 100 100 100 100 100 100 100 108 115 122 130 137
      8      64  71  79  86  93 100 100 100 100 100 100 100 100 100 100 108 115 122 130 137
      9      64  71  79  86  93 100 100 100 100 100 100 100 100 100 100 108 115 122 130 137
     10      64  71  79  86  93 100 100 100 100 100 100 100 100 100 100 108 115 122 130 137
     11      64  71  79  86  93 100 100 100 100 100 100 100 100 100 100 108 115 122 130 137
     12      64  71  79  86  93 100 100 100 100 100 100 100 100 100 100 108 115 122 130 137
     13      64  71  79  86  93 100 100 100 100 100 100 100 100 100 100 108 115 122 130 137
     14      66  74  81  88  95 100 100 100 100 100 100 100 100 100 103 110 117 124 132 139
     15      73  80  87  92  97 100 100 100 100 100 100 100 103 105 109 116 124 131 138 145
     16      91  98 105 110 116 119 119 119 119 119 119 119 121 123 127 134 142 149 156 164
     17     109 116 124 129 134 137 137 137 137 137 137 137 139 141 145 153 160 167 174 182
     18     127 134 142 147 152 155 155 155 155 155 155 155 157 159 164 171 178 185 193 200
     19     145 153 160 165 170 173 173 173 173 173 173 173 175 177 182 189 196 204 211   0
     20     164 171 178 183 188 191 191 191 191 191 191 191 194 196 200 207 214   0   0   0
boxflt2 boxfa boxfe 'lcycle
Beginning VICAR task boxflt2
BOXFLT2  02-May-2011 (64-bit) RJB
list boxfe
Beginning VICAR task list

   BYTE     samples are interpreted as   BYTE   data
 Task:GEN       User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
 Task:BOXFLT2   User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
     Samp     1       3       5       7       9      11      13      15      17      19
   Line
      1     101 102 103 105 107 110 114 118 122 126 130 134 136 138 138 139 140 141 142 143
      2      93  94  95  96  99 102 106 110 114 118 122 126 128 130 130 131 131 133 134 135
      3      85  85  86  88  91  94  98 102 106 110 114 118 120 122 122 123 123 125 126 126
      4      77  77  78  80  83  86  90  94  98 102 106 110 112 114 113 115 115 117 118 118
      5      69  69  70  72  74  78  82  86  90  94  98 102 104 105 107 108 109 111 112 112
      6      60  61  62  64  66  70  74  78  82  86  90  94  98 102 106 109 111 113 114 115
      7      70  71  72  74  76  80  84  88  92  96 100 104 108 112 116 119 121 123 124 125
      8      80  81  82  84  86  90  94  98 102 106 110 114 118 122 126 129 131 133 134 135
      9      90  91  92  94  96 100 104 108 112 116 120 124 128 132 136 139 141 143 144 145
     10     100 101 102 104 106 110 114 118 122 126 130 134 138 142 146 149 151 153 154 155
     11     110 111 112 114 116 120 124 128 132 136 140 144 148 152 156 159 161 163 164 165
     12     120 121 122 124 126 130 134 138 142 146 150 154 158 162 166 169 171 173 174 175
     13     130 131 132 134 136 140 144 148 152 156 160 164 168 172 176 179 181 183 184 185
     14     140 141 142 144 146 150 154 158 162 166 170 174 178 182 183 187 189 191 192 192
     15     150 151 152 154 156 160 164 168 172 176 180 184 185 187 187 188 189 190 192 192
     16     142 143 144 146 148 151 155 159 163 167 171 175 177 179 179 180 180 182 183 184
     17     134 134 136 137 140 143 147 151 155 159 163 167 169 171 171 172 172 174 175 176
     18     126 126 127 129 132 135 139 143 147 151 155 159 161 163 162 164 164 166 167 167
     19     118 118 119 121 124 127 131 135 139 143 147 151 153 155 154 155 156 158 159 159
     20     110 110 111 113 115 119 123 127 131 135 139 143 144 146 146 147 148 150 151 151
boxflt2 boxfa boxff 'scycle
Beginning VICAR task boxflt2
BOXFLT2  02-May-2011 (64-bit) RJB
list boxff
Beginning VICAR task list

   BYTE     samples are interpreted as   BYTE   data
 Task:GEN       User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
 Task:BOXFLT2   User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
     Samp     1       3       5       7       9      11      13      15      17      19
   Line
      1      63  60  57  53  50  47  51  55  59  63  67  71  75  79  83  80  76  73  70  66
      2      64  61  58  54  51  48  52  56  60  64  68  72  76  80  84  80  77  74  71  67
      3      67  64  60  57  54  50  54  58  62  66  70  74  78  82  86  83  80  77  73  70
      4      71  68  65  62  58  55  59  63  67  71  75  79  83  87  91  88  84  81  78  75
      5      78  74  71  68  65  61  65  69  73  77  81  85  89  93  97  94  91  88  84  81
      6      86  83  79  76  73  70  74  78  82  86  90  94  98 102 106 102  99  96  92  89
      7      96  93  89  86  83  80  84  88  92  96 100 104 108 112 116 112 109 106 102  99
      8     106 103  99  96  93  90  94  98 102 106 110 114 118 122 126 122 119 116 112 109
      9     116 113 109 106 103 100 104 108 112 116 120 124 128 132 136 132 129 126 122 119
     10     126 123 119 116 113 110 114 118 122 126 130 134 138 142 146 142 139 136 132 129
     11     136 133 129 126 123 120 124 128 132 136 140 144 148 152 156 152 149 146 142 139
     12     146 143 139 136 133 130 134 138 142 146 150 154 158 162 166 162 159 156 152 149
     13     156 153 149 146 143 140 144 148 152 156 160 164 168 172 176 172 169 166 162 159
     14     164 160 157 154 151 150 154 158 162 166 170 174 178 182 183 180 177 174 170 167
     15     167 164 161 160 159 160 164 168 172 176 180 184 185 187 187 184 180 177 174 171
     16     173 170 167 166 165 168 172 176 180 184 188 192 194 195 193 190 187 183 180 177
     17     180 177 173 172 171 174 178 182 186 190 194 198 200 202 199 196 193 190 186 183
     18     184 181 178 177 176 179 183 187 191 195 199 203 204 206 204 201 197 194 191 188
     19     187 184 181 179 178 181 185 189 193 197 201 205 207 209 207 203 200 197 194 190
     20     188 185 181 180 179 182 186 190 194 198 202 206 208 210 208 204 201 198 195 191
boxflt2 boxfa boxfg 'reflect 'highpass
Beginning VICAR task boxflt2
BOXFLT2  02-May-2011 (64-bit) RJB
HIGH PASS FILTER PERFORMED.
list boxfg
Beginning VICAR task list

   BYTE     samples are interpreted as   BYTE   data
 Task:GEN       User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
 Task:BOXFLT2   User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
     Samp     1       3       5       7       9      11      13      15      17      19
   Line
      1      90  94  97  99 100 101 101 101 101 101 101 101 101 101 101 102 103 106 108 112
      2      99 103 106 108 110 110 110 110 110 110 110 110 110 110 110 111 112 115 118 121
      3     107 110 113 115 117 118 118 118 118 118 118 118 118 118 118 118 120 122 125 128
      4     112 116 119 121 122 123 123 123 123 123 123 123 123 123 123 124 125 127 130 134
      5     116 119 122 124 126 127 127 127 127 127 127 127 127 127 127 127 129 131 134 138
      6     118 121 124 126 128 128 128 128 128 128 128 128 128 128 128 129 131 133 136 139
      7     118 121 124 126 128 128 128 128 128 128 128 128 128 128 128 129 131 133 136 139
      8     118 121 124 126 128 128 128 128 128 128 128 128 128 128 128 129 131 133 136 139
      9     118 121 124 126 128 128 128 128 128 128 128 128 128 128 128 129 131 133 136 139
     10     118 121 124 126 128 128 128 128 128 128 128 128 128 128 128 129 131 133 136 139
     11     118 121 124 126 128 128 128 128 128 128 128 128 128 128 128 129 131 133 136 139
     12     118 121 124 126 128 128 128 128 128 128 128 128 128 128 128 129 131 133 136 139
     13     118 121 124 126 128 128 128 128 128 128 128 128 128 128 128 129 131 133 136 139
     14     118 121 124 126 128 128 128 128 128 128 128 128 128 128 131 131 133 135 138 142
     15     118 121 124 126 128 128 128 128 128 128 128 128 131 133 137 140 143 146 148 152
     16     119 123 126 128 130 130 130 130 130 130 130 130 132 135 141 144 147 149 152 156
     17     123 127 130 132 133 134 134 134 134 134 134 134 136 138 145 147 151 153 156 160
     18     128 132 135 137 139 139 139 139 139 139 139 139 142 144 150 153 156 159 161 165
     19     136 139 142 144 146 147 147 147 147 147 147 147 149 151 157 160 164 166 169   0
     20     145 148 151 154 155 156 156 156 156 156 156 156 158 160 166 169 173   0   0   0
gen boxfh 20 20 linc=10 sinc=4 ival=-100 'half
Beginning VICAR task gen
GEN Version 6
GEN task completed
list boxfh
Beginning VICAR task list

   HALF     samples are interpreted as HALFWORD data
 Task:GEN       User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
     Samp       1     2     3     4     5     6     7     8     9    10    11    12    13    14    15
   Line
      1      -100   -96   -92   -88   -84   -80   -76   -72   -68   -64   -60   -56   -52   -48   -44
      2       -90   -86   -82   -78   -74   -70   -66   -62   -58   -54   -50   -46   -42   -38   -34
      3       -80   -76   -72   -68   -64   -60   -56   -52   -48   -44   -40   -36   -32   -28   -24
      4       -70   -66   -62   -58   -54   -50   -46   -42   -38   -34   -30   -26   -22   -18   -14
      5       -60   -56   -52   -48   -44   -40   -36   -32   -28   -24   -20   -16   -12    -8    -4
      6       -50   -46   -42   -38   -34   -30   -26   -22   -18   -14   -10    -6    -2     2     6
      7       -40   -36   -32   -28   -24   -20   -16   -12    -8    -4     0     4     8    12    16
      8       -30   -26   -22   -18   -14   -10    -6    -2     2     6    10    14    18    22    26
      9       -20   -16   -12    -8    -4     0     4     8    12    16    20    24    28    32    36
     10       -10    -6    -2     2     6    10    14    18    22    26    30    34    38    42    46
     11         0     4     8    12    16    20    24    28    32    36    40    44    48    52    56
     12        10    14    18    22    26    30    34    38    42    46    50    54    58    62    66
     13        20    24    28    32    36    40    44    48    52    56    60    64    68    72    76
     14        30    34    38    42    46    50    54    58    62    66    70    74    78    82    86
     15        40    44    48    52    56    60    64    68    72    76    80    84    88    92    96
     16        50    54    58    62    66    70    74    78    82    86    90    94    98   102   106
     17        60    64    68    72    76    80    84    88    92    96   100   104   108   112   116
     18        70    74    78    82    86    90    94    98   102   106   110   114   118   122   126
     19        80    84    88    92    96   100   104   108   112   116   120   124   128   132   136
     20        90    94    98   102   106   110   114   118   122   126   130   134   138   142   146

   HALF     samples are interpreted as HALFWORD data
 Task:GEN       User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
     Samp      16    17    18    19    20
   Line
      1       -40   -36   -32   -28   -24
      2       -30   -26   -22   -18   -14
      3       -20   -16   -12    -8    -4
      4       -10    -6    -2     2     6
      5         0     4     8    12    16
      6        10    14    18    22    26
      7        20    24    28    32    36
      8        30    34    38    42    46
      9        40    44    48    52    56
     10        50    54    58    62    66
     11        60    64    68    72    76
     12        70    74    78    82    86
     13        80    84    88    92    96
     14        90    94    98   102   106
     15       100   104   108   112   116
     16       110   114   118   122   126
     17       120   124   128   132   136
     18       130   134   138   142   146
     19       140   144   148   152   156
     20       150   154   158   162   166
boxflt2 boxfh boxfhb
Beginning VICAR task boxflt2
BOXFLT2  02-May-2011 (64-bit) RJB
list boxfhb
Beginning VICAR task list

   HALF     samples are interpreted as HALFWORD data
 Task:GEN       User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
 Task:BOXFLT2   User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
     Samp       1     2     3     4     5     6     7     8     9    10    11    12    13    14    15
   Line
      1       -61   -61   -60   -58   -56   -52   -48   -44   -40   -36   -32   -28   -24   -20   -16
      2       -60   -60   -59   -57   -55   -51   -47   -43   -39   -35   -31   -27   -23   -19   -15
      3       -58   -57   -56   -54   -52   -49   -45   -41   -37   -33   -29   -25   -21   -17   -13
      4       -53   -53   -52   -50   -47   -44   -40   -36   -32   -28   -24   -20   -16   -12    -8
      5       -47   -46   -45   -44   -41   -38   -34   -30   -26   -22   -18   -14   -10    -6    -2
      6       -39   -38   -37   -35   -33   -30   -26   -22   -18   -14   -10    -6    -2     2     6
      7       -29   -28   -27   -25   -23   -20   -16   -12    -8    -4     0     4     8    12    16
      8       -19   -18   -17   -15   -13   -10    -6    -2     2     6    10    14    18    22    26
      9        -9    -8    -7    -5    -3     0     4     8    12    16    20    24    28    32    36
     10         0     1     2     4     6    10    14    18    22    26    30    34    38    42    46
     11        10    11    12    14    16    20    24    28    32    36    40    44    48    52    56
     12        20    21    22    24    26    30    34    38    42    46    50    54    58    62    66
     13        30    31    32    34    36    40    44    48    52    56    60    64    68    72    76
     14        40    41    42    44    46    50    54    58    62    66    70    74    78    82    86
     15        50    51    52    54    56    60    64    68    72    76    80    84    88    92    96
     16        59    59    60    62    64    68    72    76    80    84    88    92    96   100   104
     17        65    65    66    68    71    74    78    82    86    90    94    98   102   106   110
     18        70    70    71    73    75    79    83    87    91    95    99   103   107   111   115
     19        72    73    74    76    78    81    85    89    93    97   101   105   109   113   117
     20        73    74    75    76    79    82    86    90    94    98   102   106   110   114   118

   HALF     samples are interpreted as HALFWORD data
 Task:GEN       User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
 Task:BOXFLT2   User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
     Samp      16    17    18    19    20
   Line
      1       -13   -10    -9    -8    -7
      2       -12   -10    -8    -7    -6
      3        -9    -7    -5    -4    -4
      4        -5    -2     0     0     0
      5         1     3     5     6     6
      6         9    11    13    14    15
      7        19    21    23    24    25
      8        29    31    33    34    35
      9        39    41    43    44    45
     10        49    51    53    54    55
     11        59    61    63    64    65
     12        69    71    73    74    75
     13        79    81    83    84    85
     14        89    91    93    94    95
     15        99   101   103   104   105
     16       107   110   111   112   113
     17       113   116   118   119   119
     18       118   120   122   123   124
     19       121   123   125   126   126
     20       122   124   126   127   127
boxflt2 boxfh boxfhc nlw=1 nsw=1
Beginning VICAR task boxflt2
BOXFLT2  02-May-2011 (64-bit) RJB
list boxfhc
Beginning VICAR task list

   HALF     samples are interpreted as HALFWORD data
 Task:GEN       User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
 Task:BOXFLT2   User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
     Samp       1     2     3     4     5     6     7     8     9    10    11    12    13    14    15
   Line
      1      -100   -96   -92   -88   -84   -80   -76   -72   -68   -64   -60   -56   -52   -48   -44
      2       -90   -86   -82   -78   -74   -70   -66   -62   -58   -54   -50   -46   -42   -38   -34
      3       -80   -76   -72   -68   -64   -60   -56   -52   -48   -44   -40   -36   -32   -28   -24
      4       -70   -66   -62   -58   -54   -50   -46   -42   -38   -34   -30   -26   -22   -18   -14
      5       -60   -56   -52   -48   -44   -40   -36   -32   -28   -24   -20   -16   -12    -8    -4
      6       -50   -46   -42   -38   -34   -30   -26   -22   -18   -14   -10    -6    -2     2     6
      7       -40   -36   -32   -28   -24   -20   -16   -12    -8    -4     0     4     8    12    16
      8       -30   -26   -22   -18   -14   -10    -6    -2     2     6    10    14    18    22    26
      9       -20   -16   -12    -8    -4     0     4     8    12    16    20    24    28    32    36
     10       -10    -6    -2     2     6    10    14    18    22    26    30    34    38    42    46
     11         0     4     8    12    16    20    24    28    32    36    40    44    48    52    56
     12        10    14    18    22    26    30    34    38    42    46    50    54    58    62    66
     13        20    24    28    32    36    40    44    48    52    56    60    64    68    72    76
     14        30    34    38    42    46    50    54    58    62    66    70    74    78    82    86
     15        40    44    48    52    56    60    64    68    72    76    80    84    88    92    96
     16        50    54    58    62    66    70    74    78    82    86    90    94    98   102   106
     17        60    64    68    72    76    80    84    88    92    96   100   104   108   112   116
     18        70    74    78    82    86    90    94    98   102   106   110   114   118   122   126
     19        80    84    88    92    96   100   104   108   112   116   120   124   128   132   136
     20        90    94    98   102   106   110   114   118   122   126   130   134   138   142   146

   HALF     samples are interpreted as HALFWORD data
 Task:GEN       User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
 Task:BOXFLT2   User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
     Samp      16    17    18    19    20
   Line
      1       -40   -36   -32   -28   -24
      2       -30   -26   -22   -18   -14
      3       -20   -16   -12    -8    -4
      4       -10    -6    -2     2     6
      5         0     4     8    12    16
      6        10    14    18    22    26
      7        20    24    28    32    36
      8        30    34    38    42    46
      9        40    44    48    52    56
     10        50    54    58    62    66
     11        60    64    68    72    76
     12        70    74    78    82    86
     13        80    84    88    92    96
     14        90    94    98   102   106
     15       100   104   108   112   116
     16       110   114   118   122   126
     17       120   124   128   132   136
     18       130   134   138   142   146
     19       140   144   148   152   156
     20       150   154   158   162   166
boxflt2 boxfh boxfhd 'highpass dclevel=100 'cycle
Beginning VICAR task boxflt2
BOXFLT2  02-May-2011 (64-bit) RJB
HIGH PASS FILTER PERFORMED.
list boxfhd
Beginning VICAR task list

   HALF     samples are interpreted as HALFWORD data
 Task:GEN       User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
 Task:BOXFLT2   User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
     Samp       1     2     3     4     5     6     7     8     9    10    11    12    13    14    15
   Line
      1       -27   -20   -12    -5     2    10    10    10    10    10    10    10    10    10    10
      2        -9    -1     6    13    20    28    28    28    28    28    28    28    28    28    28
      3        10    17    24    31    38    45    45    46    46    46    46    46    46    46    46
      4        28    34    41    49    56    63    63    63    63    64    64    64    64    64    64
      5        45    52    60    67    74    81    81    81    81    81    81    82    82    82    82
      6        63    70    78    85    92   100   100   100   100   100   100   100   100   100   100
      7        63    70    78    85    92   100   100   100   100   100   100   100   100   100   100
      8        64    71    78    85    92   100   100   100   100   100   100   100   100   100   100
      9        64    71    79    86    93   100   100   100   100   100   100   100   100   100   100
     10        64    71    79    86    93   100   100   100   100   100   100   100   100   100   100
     11        64    71    79    86    93   100   100   100   100   100   100   100   100   100   100
     12        64    71    79    86    93   100   100   100   100   100   100   100   100   100   100
     13        64    71    79    86    93   100   100   100   100   100   100   100   100   100   100
     14        64    71    79    86    93   100   100   100   100   100   100   100   100   100   100
     15        64    71    79    86    93   100   100   100   100   100   100   100   100   100   100
     16        82    90    97   104   111   119   119   119   119   119   119   119   119   119   119
     17       100   108   115   122   130   137   137   137   137   137   137   137   137   137   137
     18       119   126   133   140   148   155   155   155   155   155   155   155   155   155   155
     19       137   144   151   159   166   173   173   173   173   173   173   173   173   173   173
     20       155   162   170   177   184   191   191   191   191   191   191   191   191   191   191

   HALF     samples are interpreted as HALFWORD data
 Task:GEN       User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
 Task:BOXFLT2   User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
     Samp      16    17    18    19    20
   Line
      1        17    24    31    39    46
      2        35    42    50    57    64
      3        53    60    68    75    82
      4        71    79    86    93   100
      5        90    97   104   111   118
      6       108   114   121   129   136
      7       108   115   122   130   136
      8       108   115   122   130   137
      9       108   115   122   130   137
     10       108   115   122   130   137
     11       108   115   122   130   137
     12       108   115   122   130   137
     13       108   115   122   130   137
     14       108   115   122   130   137
     15       108   115   122   130   137
     16       126   133   140   148   155
     17       144   151   159   166   173
     18       162   170   177   184   191
     19       180   188   195   202   210
     20       199   206   213   220   228
boxflt2 boxfh boxfhe 'lcycle
Beginning VICAR task boxflt2
BOXFLT2  02-May-2011 (64-bit) RJB
list boxfhe
Beginning VICAR task list

   HALF     samples are interpreted as HALFWORD data
 Task:GEN       User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
 Task:BOXFLT2   User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
     Samp       1     2     3     4     5     6     7     8     9    10    11    12    13    14    15
   Line
      1         1     2     3     5     7    10    14    18    22    26    30    34    38    42    46
      2        -6    -6    -4    -3     0     2     6    10    14    18    22    26    30    34    38
      3       -14   -14   -13   -11    -8    -5    -1     2     6    10    14    18    22    26    30
      4       -22   -22   -21   -19   -16   -13    -9    -5    -1     2     6    10    14    18    22
      5       -30   -30   -29   -27   -25   -21   -17   -13    -9    -5    -1     2     6    10    14
      6       -39   -38   -37   -35   -33   -30   -26   -22   -18   -14   -10    -6    -2     2     6
      7       -29   -28   -27   -25   -23   -20   -16   -12    -8    -4     0     4     8    12    16
      8       -19   -18   -17   -15   -13   -10    -6    -2     2     6    10    14    18    22    26
      9        -9    -8    -7    -5    -3     0     4     8    12    16    20    24    28    32    36
     10         0     1     2     4     6    10    14    18    22    26    30    34    38    42    46
     11        10    11    12    14    16    20    24    28    32    36    40    44    48    52    56
     12        20    21    22    24    26    30    34    38    42    46    50    54    58    62    66
     13        30    31    32    34    36    40    44    48    52    56    60    64    68    72    76
     14        40    41    42    44    46    50    54    58    62    66    70    74    78    82    86
     15        50    51    52    54    56    60    64    68    72    76    80    84    88    92    96
     16        42    43    44    46    48    51    55    59    63    67    71    75    79    83    87
     17        34    34    36    37    40    43    47    51    55    59    63    67    71    75    79
     18        26    26    27    29    32    35    39    43    47    51    55    59    63    67    71
     19        18    18    19    21    24    27    31    35    39    43    47    51    55    59    63
     20        10    10    11    13    15    19    23    27    31    35    39    43    47    51    55

   HALF     samples are interpreted as HALFWORD data
 Task:GEN       User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
 Task:BOXFLT2   User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
     Samp      16    17    18    19    20
   Line
      1        50    52    54    55    56
      2        42    44    46    47    47
      3        33    36    38    39    39
      4        25    28    30    31    31
      5        17    20    21    22    23
      6         9    11    13    14    15
      7        19    21    23    24    25
      8        29    31    33    34    35
      9        39    41    43    44    45
     10        49    51    53    54    55
     11        59    61    63    64    65
     12        69    71    73    74    75
     13        79    81    83    84    85
     14        89    91    93    94    95
     15        99   101   103   104   105
     16        91    93    95    96    96
     17        82    85    87    88    88
     18        74    77    79    80    80
     19        66    69    70    72    72
     20        58    60    62    63    64
boxflt2 boxfh boxfhf 'scycle
Beginning VICAR task boxflt2
BOXFLT2  02-May-2011 (64-bit) RJB
list boxfhf
Beginning VICAR task list

   HALF     samples are interpreted as HALFWORD data
 Task:GEN       User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
 Task:BOXFLT2   User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
     Samp       1     2     3     4     5     6     7     8     9    10    11    12    13    14    15
   Line
      1       -36   -39   -42   -46   -49   -52   -48   -44   -40   -36   -32   -28   -24   -20   -16
      2       -35   -38   -42   -45   -48   -51   -47   -43   -39   -35   -31   -27   -23   -19   -15
      3       -32   -36   -39   -42   -45   -49   -45   -41   -37   -33   -29   -25   -21   -17   -13
      4       -28   -31   -34   -38   -41   -44   -40   -36   -32   -28   -24   -20   -16   -12    -8
      5       -21   -25   -28   -31   -34   -38   -34   -30   -26   -22   -18   -14   -10    -6    -2
      6       -13   -16   -20   -23   -26   -30   -26   -22   -18   -14   -10    -6    -2     2     6
      7        -3    -6   -10   -13   -16   -20   -16   -12    -8    -4     0     4     8    12    16
      8         6     3     0    -3    -6   -10    -6    -2     2     6    10    14    18    22    26
      9        16    13     9     6     3     0     4     8    12    16    20    24    28    32    36
     10        26    23    19    16    13    10    14    18    22    26    30    34    38    42    46
     11        36    33    29    26    23    20    24    28    32    36    40    44    48    52    56
     12        46    43    39    36    33    30    34    38    42    46    50    54    58    62    66
     13        56    53    49    46    43    40    44    48    52    56    60    64    68    72    76
     14        66    63    59    56    53    50    54    58    62    66    70    74    78    82    86
     15        76    73    69    66    63    60    64    68    72    76    80    84    88    92    96
     16        84    81    78    74    71    68    72    76    80    84    88    92    96   100   104
     17        90    87    84    81    77    74    78    82    86    90    94    98   102   106   110
     18        95    92    88    85    82    79    83    87    91    95    99   103   107   111   115
     19        98    94    91    88    85    81    85    89    93    97   101   105   109   113   117
     20        99    95    92    89    86    82    86    90    94    98   102   106   110   114   118

   HALF     samples are interpreted as HALFWORD data
 Task:GEN       User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
 Task:BOXFLT2   User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
     Samp      16    17    18    19    20
   Line
      1       -20   -23   -26   -29   -33
      2       -19   -22   -25   -28   -32
      3       -16   -19   -22   -26   -29
      4       -11   -15   -18   -21   -24
      5        -5    -8   -12   -15   -18
      6         2     0    -3    -7   -10
      7        12     9     6     2     0
      8        22    19    16    12     9
      9        32    29    26    22    19
     10        42    39    36    32    29
     11        52    49    46    42    39
     12        62    59    56    52    49
     13        72    69    66    62    59
     14        82    79    76    72    69
     15        92    89    86    82    79
     16       100    97    94    91    87
     17       107   104   100    97    94
     18       111   108   105   102    98
     19       114   111   108   104   101
     20       115   112   108   105   102
boxflt2 boxfh boxfhg 'reflect 'highpass
Beginning VICAR task boxflt2
BOXFLT2  02-May-2011 (64-bit) RJB
HIGH PASS FILTER PERFORMED.
list boxfhg
Beginning VICAR task list

   HALF     samples are interpreted as HALFWORD data
 Task:GEN       User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
 Task:BOXFLT2   User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
     Samp       1     2     3     4     5     6     7     8     9    10    11    12    13    14    15
   Line
      1        89    93    96    98   100   100   100   100   100   100   100   100   100   100   100
      2        98   102   105   107   109   109   109   109   109   109   109   109   109   109   109
      3       106   109   112   114   116   117   117   117   117   117   117   117   117   117   117
      4       111   115   118   120   121   122   122   122   122   122   122   122   122   122   122
      5       115   118   121   124   125   126   126   126   126   126   126   126   126   126   126
      6       117   120   123   125   127   128   128   128   128   128   128   128   128   128   128
      7       117   120   123   125   127   128   128   128   128   128   128   128   128   128   128
      8       117   120   123   125   127   128   128   128   128   128   128   128   128   128   128
      9       117   120   123   125   127   128   128   128   128   128   128   128   128   128   128
     10       118   121   124   126   128   128   128   128   128   128   128   128   128   128   128
     11       118   121   124   126   128   128   128   128   128   128   128   128   128   128   128
     12       118   121   124   126   128   128   128   128   128   128   128   128   128   128   128
     13       118   121   124   126   128   128   128   128   128   128   128   128   128   128   128
     14       118   121   124   126   128   128   128   128   128   128   128   128   128   128   128
     15       118   121   124   126   128   128   128   128   128   128   128   128   128   128   128
     16       119   123   126   128   130   130   130   130   130   130   130   130   130   130   130
     17       123   127   130   132   133   134   134   134   134   134   134   134   134   134   134
     18       128   132   135   137   139   139   139   139   139   139   139   139   139   139   139
     19       136   139   142   144   146   147   147   147   147   147   147   147   147   147   147
     20       145   148   151   154   155   156   156   156   156   156   156   156   156   156   156

   HALF     samples are interpreted as HALFWORD data
 Task:GEN       User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
 Task:BOXFLT2   User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
     Samp      16    17    18    19    20
   Line
      1       101   102   105   108   111
      2       110   112   114   117   120
      3       117   119   121   124   128
      4       123   124   126   130   134
      5       127   129   131   134   138
      6       129   131   133   136   139
      7       129   131   133   136   139
      8       129   131   133   136   139
      9       129   131   133   136   139
     10       129   131   133   136   139
     11       129   131   133   136   139
     12       129   131   133   136   139
     13       129   131   133   136   139
     14       129   131   133   136   139
     15       129   131   133   136   139
     16       131   132   135   138   141
     17       135   136   138   141   145
     18       140   142   144   147   150
     19       147   149   151   154   158
     20       156   158   160   163   167
gen boxff 20 20 linc=10 sinc=4 ival=-100 'full
Beginning VICAR task gen
GEN Version 6
GEN task completed
list boxff
Beginning VICAR task list

   FULL     samples are interpreted as FULLWORD data
 Task:GEN       User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
     Samp            1          2          3          4          5          6          7          8          9         10
   Line
      1           -100        -96        -92        -88        -84        -80        -76        -72        -68        -64
      2            -90        -86        -82        -78        -74        -70        -66        -62        -58        -54
      3            -80        -76        -72        -68        -64        -60        -56        -52        -48        -44
      4            -70        -66        -62        -58        -54        -50        -46        -42        -38        -34
      5            -60        -56        -52        -48        -44        -40        -36        -32        -28        -24
      6            -50        -46        -42        -38        -34        -30        -26        -22        -18        -14
      7            -40        -36        -32        -28        -24        -20        -16        -12         -8         -4
      8            -30        -26        -22        -18        -14        -10         -6         -2          2          6
      9            -20        -16        -12         -8         -4          0          4          8         12         16
     10            -10         -6         -2          2          6         10         14         18         22         26
     11              0          4          8         12         16         20         24         28         32         36
     12             10         14         18         22         26         30         34         38         42         46
     13             20         24         28         32         36         40         44         48         52         56
     14             30         34         38         42         46         50         54         58         62         66
     15             40         44         48         52         56         60         64         68         72         76
     16             50         54         58         62         66         70         74         78         82         86
     17             60         64         68         72         76         80         84         88         92         96
     18             70         74         78         82         86         90         94         98        102        106
     19             80         84         88         92         96        100        104        108        112        116
     20             90         94         98        102        106        110        114        118        122        126

   FULL     samples are interpreted as FULLWORD data
 Task:GEN       User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
     Samp           11         12         13         14         15         16         17         18         19         20
   Line
      1            -60        -56        -52        -48        -44        -40        -36        -32        -28        -24
      2            -50        -46        -42        -38        -34        -30        -26        -22        -18        -14
      3            -40        -36        -32        -28        -24        -20        -16        -12         -8         -4
      4            -30        -26        -22        -18        -14        -10         -6         -2          2          6
      5            -20        -16        -12         -8         -4          0          4          8         12         16
      6            -10         -6         -2          2          6         10         14         18         22         26
      7              0          4          8         12         16         20         24         28         32         36
      8             10         14         18         22         26         30         34         38         42         46
      9             20         24         28         32         36         40         44         48         52         56
     10             30         34         38         42         46         50         54         58         62         66
     11             40         44         48         52         56         60         64         68         72         76
     12             50         54         58         62         66         70         74         78         82         86
     13             60         64         68         72         76         80         84         88         92         96
     14             70         74         78         82         86         90         94         98        102        106
     15             80         84         88         92         96        100        104        108        112        116
     16             90         94         98        102        106        110        114        118        122        126
     17            100        104        108        112        116        120        124        128        132        136
     18            110        114        118        122        126        130        134        138        142        146
     19            120        124        128        132        136        140        144        148        152        156
     20            130        134        138        142        146        150        154        158        162        166
boxflt2 boxff boxffb
Beginning VICAR task boxflt2
BOXFLT2  02-May-2011 (64-bit) RJB
list boxffb
Beginning VICAR task list

   FULL     samples are interpreted as FULLWORD data
 Task:GEN       User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
 Task:BOXFLT2   User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
     Samp            1          2          3          4          5          6          7          8          9         10
   Line
      1            -61        -61        -60        -58        -56        -52        -48        -44        -40        -36
      2            -60        -60        -59        -57        -55        -51        -47        -43        -39        -35
      3            -58        -57        -56        -54        -52        -49        -45        -41        -37        -33
      4            -53        -53        -52        -50        -47        -44        -40        -36        -32        -28
      5            -47        -46        -45        -44        -41        -38        -34        -30        -26        -22
      6            -39        -38        -37        -35        -33        -30        -26        -22        -18        -14
      7            -29        -28        -27        -25        -23        -20        -16        -12         -8         -4
      8            -19        -18        -17        -15        -13        -10         -6         -2          2          6
      9             -9         -8         -7         -5         -3          0          4          8         12         16
     10              0          1          2          4          6         10         14         18         22         26
     11             10         11         12         14         16         20         24         28         32         36
     12             20         21         22         24         26         30         34         38         42         46
     13             30         31         32         34         36         40         44         48         52         56
     14             40         41         42         44         46         50         54         58         62         66
     15             50         51         52         54         56         60         64         68         72         76
     16             59         59         60         62         64         68         72         76         80         84
     17             65         65         66         68         71         74         78         82         86         90
     18             70         70         71         73         75         79         83         87         91         95
     19             72         73         74         76         78         81         85         89         93         97
     20             73         74         75         76         79         82         86         90         94         98

   FULL     samples are interpreted as FULLWORD data
 Task:GEN       User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
 Task:BOXFLT2   User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
     Samp           11         12         13         14         15         16         17         18         19         20
   Line
      1            -32        -28        -24        -20        -16        -13        -10         -9         -8         -7
      2            -31        -27        -23        -19        -15        -12        -10         -8         -7         -6
      3            -29        -25        -21        -17        -13         -9         -7         -5         -4         -4
      4            -24        -20        -16        -12         -8         -5         -2          0          0          0
      5            -18        -14        -10         -6         -2          1          3          5          6          6
      6            -10         -6         -2          2          6          9         11         13         14         15
      7              0          4          8         12         16         19         21         23         24         25
      8             10         14         18         22         26         29         31         33         34         35
      9             20         24         28         32         36         39         41         43         44         45
     10             30         34         38         42         46         49         51         53         54         55
     11             40         44         48         52         56         59         61         63         64         65
     12             50         54         58         62         66         69         71         73         74         75
     13             60         64         68         72         76         79         81         83         84         85
     14             70         74         78         82         86         89         91         93         94         95
     15             80         84         88         92         96         99        101        103        104        105
     16             88         92         96        100        104        107        110        111        112        113
     17             94         98        102        106        110        113        116        118        119        119
     18             99        103        107        111        115        118        120        122        123        124
     19            101        105        109        113        117        121        123        125        126        126
     20            102        106        110        114        118        122        124        126        127        127
boxflt2 boxff boxffc nlw=1 nsw=1
Beginning VICAR task boxflt2
BOXFLT2  02-May-2011 (64-bit) RJB
list boxffc
Beginning VICAR task list

   FULL     samples are interpreted as FULLWORD data
 Task:GEN       User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
 Task:BOXFLT2   User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
     Samp            1          2          3          4          5          6          7          8          9         10
   Line
      1           -100        -96        -92        -88        -84        -80        -76        -72        -68        -64
      2            -90        -86        -82        -78        -74        -70        -66        -62        -58        -54
      3            -80        -76        -72        -68        -64        -60        -56        -52        -48        -44
      4            -70        -66        -62        -58        -54        -50        -46        -42        -38        -34
      5            -60        -56        -52        -48        -44        -40        -36        -32        -28        -24
      6            -50        -46        -42        -38        -34        -30        -26        -22        -18        -14
      7            -40        -36        -32        -28        -24        -20        -16        -12         -8         -4
      8            -30        -26        -22        -18        -14        -10         -6         -2          2          6
      9            -20        -16        -12         -8         -4          0          4          8         12         16
     10            -10         -6         -2          2          6         10         14         18         22         26
     11              0          4          8         12         16         20         24         28         32         36
     12             10         14         18         22         26         30         34         38         42         46
     13             20         24         28         32         36         40         44         48         52         56
     14             30         34         38         42         46         50         54         58         62         66
     15             40         44         48         52         56         60         64         68         72         76
     16             50         54         58         62         66         70         74         78         82         86
     17             60         64         68         72         76         80         84         88         92         96
     18             70         74         78         82         86         90         94         98        102        106
     19             80         84         88         92         96        100        104        108        112        116
     20             90         94         98        102        106        110        114        118        122        126

   FULL     samples are interpreted as FULLWORD data
 Task:GEN       User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
 Task:BOXFLT2   User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
     Samp           11         12         13         14         15         16         17         18         19         20
   Line
      1            -60        -56        -52        -48        -44        -40        -36        -32        -28        -24
      2            -50        -46        -42        -38        -34        -30        -26        -22        -18        -14
      3            -40        -36        -32        -28        -24        -20        -16        -12         -8         -4
      4            -30        -26        -22        -18        -14        -10         -6         -2          2          6
      5            -20        -16        -12         -8         -4          0          4          8         12         16
      6            -10         -6         -2          2          6         10         14         18         22         26
      7              0          4          8         12         16         20         24         28         32         36
      8             10         14         18         22         26         30         34         38         42         46
      9             20         24         28         32         36         40         44         48         52         56
     10             30         34         38         42         46         50         54         58         62         66
     11             40         44         48         52         56         60         64         68         72         76
     12             50         54         58         62         66         70         74         78         82         86
     13             60         64         68         72         76         80         84         88         92         96
     14             70         74         78         82         86         90         94         98        102        106
     15             80         84         88         92         96        100        104        108        112        116
     16             90         94         98        102        106        110        114        118        122        126
     17            100        104        108        112        116        120        124        128        132        136
     18            110        114        118        122        126        130        134        138        142        146
     19            120        124        128        132        136        140        144        148        152        156
     20            130        134        138        142        146        150        154        158        162        166
boxflt2 boxff boxffd 'highpass dclevel=100 'cycle
Beginning VICAR task boxflt2
BOXFLT2  02-May-2011 (64-bit) RJB
HIGH PASS FILTER PERFORMED.
list boxffd
Beginning VICAR task list

   FULL     samples are interpreted as FULLWORD data
 Task:GEN       User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
 Task:BOXFLT2   User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
     Samp            1          2          3          4          5          6          7          8          9         10
   Line
      1            -27        -20        -12         -5          2         10         10         10         10         10
      2             -9         -1          6         13         20         28         28         28         28         28
      3             10         17         24         31         38         45         45         46         46         46
      4             28         34         41         49         56         63         63         63         63         64
      5             45         52         60         67         74         81         81         81         81         81
      6             63         70         78         85         92        100        100        100        100        100
      7             63         70         78         85         92        100        100        100        100        100
      8             64         71         78         85         92        100        100        100        100        100
      9             64         71         79         86         93        100        100        100        100        100
     10             64         71         79         86         93        100        100        100        100        100
     11             64         71         79         86         93        100        100        100        100        100
     12             64         71         79         86         93        100        100        100        100        100
     13             64         71         79         86         93        100        100        100        100        100
     14             64         71         79         86         93        100        100        100        100        100
     15             64         71         79         86         93        100        100        100        100        100
     16             82         90         97        104        111        119        119        119        119        119
     17            100        108        115        122        130        137        137        137        137        137
     18            119        126        133        140        148        155        155        155        155        155
     19            137        144        151        159        166        173        173        173        173        173
     20            155        162        170        177        184        191        191        191        191        191

   FULL     samples are interpreted as FULLWORD data
 Task:GEN       User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
 Task:BOXFLT2   User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
     Samp           11         12         13         14         15         16         17         18         19         20
   Line
      1             10         10         10         10         10         17         24         31         39         46
      2             28         28         28         28         28         35         42         50         57         64
      3             46         46         46         46         46         53         60         68         75         82
      4             64         64         64         64         64         71         79         86         93        100
      5             81         82         82         82         82         90         97        104        111        118
      6            100        100        100        100        100        108        114        121        129        136
      7            100        100        100        100        100        108        115        122        130        136
      8            100        100        100        100        100        108        115        122        130        137
      9            100        100        100        100        100        108        115        122        130        137
     10            100        100        100        100        100        108        115        122        130        137
     11            100        100        100        100        100        108        115        122        130        137
     12            100        100        100        100        100        108        115        122        130        137
     13            100        100        100        100        100        108        115        122        130        137
     14            100        100        100        100        100        108        115        122        130        137
     15            100        100        100        100        100        108        115        122        130        137
     16            119        119        119        119        119        126        133        140        148        155
     17            137        137        137        137        137        144        151        159        166        173
     18            155        155        155        155        155        162        170        177        184        191
     19            173        173        173        173        173        180        188        195        202        210
     20            191        191        191        191        191        199        206        213        220        228
boxflt2 boxff boxffe 'lcycle
Beginning VICAR task boxflt2
BOXFLT2  02-May-2011 (64-bit) RJB
list boxffe
Beginning VICAR task list

   FULL     samples are interpreted as FULLWORD data
 Task:GEN       User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
 Task:BOXFLT2   User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
     Samp            1          2          3          4          5          6          7          8          9         10
   Line
      1              1          2          3          5          7         10         14         18         22         26
      2             -6         -6         -4         -3          0          2          6         10         14         18
      3            -14        -14        -13        -11         -8         -5         -1          2          6         10
      4            -22        -22        -21        -19        -16        -13         -9         -5         -1          2
      5            -30        -30        -29        -27        -25        -21        -17        -13         -9         -5
      6            -39        -38        -37        -35        -33        -30        -26        -22        -18        -14
      7            -29        -28        -27        -25        -23        -20        -16        -12         -8         -4
      8            -19        -18        -17        -15        -13        -10         -6         -2          2          6
      9             -9         -8         -7         -5         -3          0          4          8         12         16
     10              0          1          2          4          6         10         14         18         22         26
     11             10         11         12         14         16         20         24         28         32         36
     12             20         21         22         24         26         30         34         38         42         46
     13             30         31         32         34         36         40         44         48         52         56
     14             40         41         42         44         46         50         54         58         62         66
     15             50         51         52         54         56         60         64         68         72         76
     16             42         43         44         46         48         51         55         59         63         67
     17             34         34         36         37         40         43         47         51         55         59
     18             26         26         27         29         32         35         39         43         47         51
     19             18         18         19         21         24         27         31         35         39         43
     20             10         10         11         13         15         19         23         27         31         35

   FULL     samples are interpreted as FULLWORD data
 Task:GEN       User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
 Task:BOXFLT2   User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
     Samp           11         12         13         14         15         16         17         18         19         20
   Line
      1             30         34         38         42         46         50         52         54         55         56
      2             22         26         30         34         38         42         44         46         47         47
      3             14         18         22         26         30         33         36         38         39         39
      4              6         10         14         18         22         25         28         30         31         31
      5             -1          2          6         10         14         17         20         21         22         23
      6            -10         -6         -2          2          6          9         11         13         14         15
      7              0          4          8         12         16         19         21         23         24         25
      8             10         14         18         22         26         29         31         33         34         35
      9             20         24         28         32         36         39         41         43         44         45
     10             30         34         38         42         46         49         51         53         54         55
     11             40         44         48         52         56         59         61         63         64         65
     12             50         54         58         62         66         69         71         73         74         75
     13             60         64         68         72         76         79         81         83         84         85
     14             70         74         78         82         86         89         91         93         94         95
     15             80         84         88         92         96         99        101        103        104        105
     16             71         75         79         83         87         91         93         95         96         96
     17             63         67         71         75         79         82         85         87         88         88
     18             55         59         63         67         71         74         77         79         80         80
     19             47         51         55         59         63         66         69         70         72         72
     20             39         43         47         51         55         58         60         62         63         64
boxflt2 boxff boxfff 'scycle
Beginning VICAR task boxflt2
BOXFLT2  02-May-2011 (64-bit) RJB
list boxfff
Beginning VICAR task list

   FULL     samples are interpreted as FULLWORD data
 Task:GEN       User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
 Task:BOXFLT2   User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
     Samp            1          2          3          4          5          6          7          8          9         10
   Line
      1            -36        -39        -42        -46        -49        -52        -48        -44        -40        -36
      2            -35        -38        -42        -45        -48        -51        -47        -43        -39        -35
      3            -32        -36        -39        -42        -45        -49        -45        -41        -37        -33
      4            -28        -31        -34        -38        -41        -44        -40        -36        -32        -28
      5            -21        -25        -28        -31        -34        -38        -34        -30        -26        -22
      6            -13        -16        -20        -23        -26        -30        -26        -22        -18        -14
      7             -3         -6        -10        -13        -16        -20        -16        -12         -8         -4
      8              6          3          0         -3         -6        -10         -6         -2          2          6
      9             16         13          9          6          3          0          4          8         12         16
     10             26         23         19         16         13         10         14         18         22         26
     11             36         33         29         26         23         20         24         28         32         36
     12             46         43         39         36         33         30         34         38         42         46
     13             56         53         49         46         43         40         44         48         52         56
     14             66         63         59         56         53         50         54         58         62         66
     15             76         73         69         66         63         60         64         68         72         76
     16             84         81         78         74         71         68         72         76         80         84
     17             90         87         84         81         77         74         78         82         86         90
     18             95         92         88         85         82         79         83         87         91         95
     19             98         94         91         88         85         81         85         89         93         97
     20             99         95         92         89         86         82         86         90         94         98

   FULL     samples are interpreted as FULLWORD data
 Task:GEN       User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
 Task:BOXFLT2   User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
     Samp           11         12         13         14         15         16         17         18         19         20
   Line
      1            -32        -28        -24        -20        -16        -20        -23        -26        -29        -33
      2            -31        -27        -23        -19        -15        -19        -22        -25        -28        -32
      3            -29        -25        -21        -17        -13        -16        -19        -22        -26        -29
      4            -24        -20        -16        -12         -8        -11        -15        -18        -21        -24
      5            -18        -14        -10         -6         -2         -5         -8        -12        -15        -18
      6            -10         -6         -2          2          6          2          0         -3         -7        -10
      7              0          4          8         12         16         12          9          6          2          0
      8             10         14         18         22         26         22         19         16         12          9
      9             20         24         28         32         36         32         29         26         22         19
     10             30         34         38         42         46         42         39         36         32         29
     11             40         44         48         52         56         52         49         46         42         39
     12             50         54         58         62         66         62         59         56         52         49
     13             60         64         68         72         76         72         69         66         62         59
     14             70         74         78         82         86         82         79         76         72         69
     15             80         84         88         92         96         92         89         86         82         79
     16             88         92         96        100        104        100         97         94         91         87
     17             94         98        102        106        110        107        104        100         97         94
     18             99        103        107        111        115        111        108        105        102         98
     19            101        105        109        113        117        114        111        108        104        101
     20            102        106        110        114        118        115        112        108        105        102
boxflt2 boxff boxffg 'reflect 'highpass
Beginning VICAR task boxflt2
BOXFLT2  02-May-2011 (64-bit) RJB
HIGH PASS FILTER PERFORMED.
list boxffg
Beginning VICAR task list

   FULL     samples are interpreted as FULLWORD data
 Task:GEN       User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
 Task:BOXFLT2   User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
     Samp            1          2          3          4          5          6          7          8          9         10
   Line
      1             89         93         96         98        100        100        100        100        100        100
      2             98        102        105        107        109        109        109        109        109        109
      3            106        109        112        114        116        117        117        117        117        117
      4            111        115        118        120        121        122        122        122        122        122
      5            115        118        121        124        125        126        126        126        126        126
      6            117        120        123        125        127        128        128        128        128        128
      7            117        120        123        125        127        128        128        128        128        128
      8            117        120        123        125        127        128        128        128        128        128
      9            117        120        123        125        127        128        128        128        128        128
     10            118        121        124        126        128        128        128        128        128        128
     11            118        121        124        126        128        128        128        128        128        128
     12            118        121        124        126        128        128        128        128        128        128
     13            118        121        124        126        128        128        128        128        128        128
     14            118        121        124        126        128        128        128        128        128        128
     15            118        121        124        126        128        128        128        128        128        128
     16            119        123        126        128        130        130        130        130        130        130
     17            123        127        130        132        133        134        134        134        134        134
     18            128        132        135        137        139        139        139        139        139        139
     19            136        139        142        144        146        147        147        147        147        147
     20            145        148        151        154        155        156        156        156        156        156

   FULL     samples are interpreted as FULLWORD data
 Task:GEN       User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
 Task:BOXFLT2   User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
     Samp           11         12         13         14         15         16         17         18         19         20
   Line
      1            100        100        100        100        100        101        102        105        108        111
      2            109        109        109        109        109        110        112        114        117        120
      3            117        117        117        117        117        117        119        121        124        128
      4            122        122        122        122        122        123        124        126        130        134
      5            126        126        126        126        126        127        129        131        134        138
      6            128        128        128        128        128        129        131        133        136        139
      7            128        128        128        128        128        129        131        133        136        139
      8            128        128        128        128        128        129        131        133        136        139
      9            128        128        128        128        128        129        131        133        136        139
     10            128        128        128        128        128        129        131        133        136        139
     11            128        128        128        128        128        129        131        133        136        139
     12            128        128        128        128        128        129        131        133        136        139
     13            128        128        128        128        128        129        131        133        136        139
     14            128        128        128        128        128        129        131        133        136        139
     15            128        128        128        128        128        129        131        133        136        139
     16            130        130        130        130        130        131        132        135        138        141
     17            134        134        134        134        134        135        136        138        141        145
     18            139        139        139        139        139        140        142        144        147        150
     19            147        147        147        147        147        147        149        151        154        158
     20            156        156        156        156        156        156        158        160        163        167
gen boxfr 20 20 linc=10 sinc=4 ival=-100. 'real
Beginning VICAR task gen
GEN Version 6
GEN task completed
list boxfr
Beginning VICAR task list

   REAL     samples are interpreted as  REAL*4  data
 Task:GEN       User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
     Samp             1           2           3           4           5           6           7           8           9          10
   Line
      1      -1.000E+02  -9.600E+01  -9.200E+01  -8.800E+01  -8.400E+01  -8.000E+01  -7.600E+01  -7.200E+01  -6.800E+01  -6.400E+01
      2      -9.000E+01  -8.600E+01  -8.200E+01  -7.800E+01  -7.400E+01  -7.000E+01  -6.600E+01  -6.200E+01  -5.800E+01  -5.400E+01
      3      -8.000E+01  -7.600E+01  -7.200E+01  -6.800E+01  -6.400E+01  -6.000E+01  -5.600E+01  -5.200E+01  -4.800E+01  -4.400E+01
      4      -7.000E+01  -6.600E+01  -6.200E+01  -5.800E+01  -5.400E+01  -5.000E+01  -4.600E+01  -4.200E+01  -3.800E+01  -3.400E+01
      5      -6.000E+01  -5.600E+01  -5.200E+01  -4.800E+01  -4.400E+01  -4.000E+01  -3.600E+01  -3.200E+01  -2.800E+01  -2.400E+01
      6      -5.000E+01  -4.600E+01  -4.200E+01  -3.800E+01  -3.400E+01  -3.000E+01  -2.600E+01  -2.200E+01  -1.800E+01  -1.400E+01
      7      -4.000E+01  -3.600E+01  -3.200E+01  -2.800E+01  -2.400E+01  -2.000E+01  -1.600E+01  -1.200E+01  -8.000E+00  -4.000E+00
      8      -3.000E+01  -2.600E+01  -2.200E+01  -1.800E+01  -1.400E+01  -1.000E+01  -6.000E+00  -2.000E+00   2.000E+00   6.000E+00
      9      -2.000E+01  -1.600E+01  -1.200E+01  -8.000E+00  -4.000E+00   0.000E+00   4.000E+00   8.000E+00   1.200E+01   1.600E+01
     10      -1.000E+01  -6.000E+00  -2.000E+00   2.000E+00   6.000E+00   1.000E+01   1.400E+01   1.800E+01   2.200E+01   2.600E+01
     11       0.000E+00   4.000E+00   8.000E+00   1.200E+01   1.600E+01   2.000E+01   2.400E+01   2.800E+01   3.200E+01   3.600E+01
     12       1.000E+01   1.400E+01   1.800E+01   2.200E+01   2.600E+01   3.000E+01   3.400E+01   3.800E+01   4.200E+01   4.600E+01
     13       2.000E+01   2.400E+01   2.800E+01   3.200E+01   3.600E+01   4.000E+01   4.400E+01   4.800E+01   5.200E+01   5.600E+01
     14       3.000E+01   3.400E+01   3.800E+01   4.200E+01   4.600E+01   5.000E+01   5.400E+01   5.800E+01   6.200E+01   6.600E+01
     15       4.000E+01   4.400E+01   4.800E+01   5.200E+01   5.600E+01   6.000E+01   6.400E+01   6.800E+01   7.200E+01   7.600E+01
     16       5.000E+01   5.400E+01   5.800E+01   6.200E+01   6.600E+01   7.000E+01   7.400E+01   7.800E+01   8.200E+01   8.600E+01
     17       6.000E+01   6.400E+01   6.800E+01   7.200E+01   7.600E+01   8.000E+01   8.400E+01   8.800E+01   9.200E+01   9.600E+01
     18       7.000E+01   7.400E+01   7.800E+01   8.200E+01   8.600E+01   9.000E+01   9.400E+01   9.800E+01   1.020E+02   1.060E+02
     19       8.000E+01   8.400E+01   8.800E+01   9.200E+01   9.600E+01   1.000E+02   1.040E+02   1.080E+02   1.120E+02   1.160E+02
     20       9.000E+01   9.400E+01   9.800E+01   1.020E+02   1.060E+02   1.100E+02   1.140E+02   1.180E+02   1.220E+02   1.260E+02

   REAL     samples are interpreted as  REAL*4  data
 Task:GEN       User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
     Samp            11          12          13          14          15          16          17          18          19          20
   Line
      1      -6.000E+01  -5.600E+01  -5.200E+01  -4.800E+01  -4.400E+01  -4.000E+01  -3.600E+01  -3.200E+01  -2.800E+01  -2.400E+01
      2      -5.000E+01  -4.600E+01  -4.200E+01  -3.800E+01  -3.400E+01  -3.000E+01  -2.600E+01  -2.200E+01  -1.800E+01  -1.400E+01
      3      -4.000E+01  -3.600E+01  -3.200E+01  -2.800E+01  -2.400E+01  -2.000E+01  -1.600E+01  -1.200E+01  -8.000E+00  -4.000E+00
      4      -3.000E+01  -2.600E+01  -2.200E+01  -1.800E+01  -1.400E+01  -1.000E+01  -6.000E+00  -2.000E+00   2.000E+00   6.000E+00
      5      -2.000E+01  -1.600E+01  -1.200E+01  -8.000E+00  -4.000E+00   0.000E+00   4.000E+00   8.000E+00   1.200E+01   1.600E+01
      6      -1.000E+01  -6.000E+00  -2.000E+00   2.000E+00   6.000E+00   1.000E+01   1.400E+01   1.800E+01   2.200E+01   2.600E+01
      7       0.000E+00   4.000E+00   8.000E+00   1.200E+01   1.600E+01   2.000E+01   2.400E+01   2.800E+01   3.200E+01   3.600E+01
      8       1.000E+01   1.400E+01   1.800E+01   2.200E+01   2.600E+01   3.000E+01   3.400E+01   3.800E+01   4.200E+01   4.600E+01
      9       2.000E+01   2.400E+01   2.800E+01   3.200E+01   3.600E+01   4.000E+01   4.400E+01   4.800E+01   5.200E+01   5.600E+01
     10       3.000E+01   3.400E+01   3.800E+01   4.200E+01   4.600E+01   5.000E+01   5.400E+01   5.800E+01   6.200E+01   6.600E+01
     11       4.000E+01   4.400E+01   4.800E+01   5.200E+01   5.600E+01   6.000E+01   6.400E+01   6.800E+01   7.200E+01   7.600E+01
     12       5.000E+01   5.400E+01   5.800E+01   6.200E+01   6.600E+01   7.000E+01   7.400E+01   7.800E+01   8.200E+01   8.600E+01
     13       6.000E+01   6.400E+01   6.800E+01   7.200E+01   7.600E+01   8.000E+01   8.400E+01   8.800E+01   9.200E+01   9.600E+01
     14       7.000E+01   7.400E+01   7.800E+01   8.200E+01   8.600E+01   9.000E+01   9.400E+01   9.800E+01   1.020E+02   1.060E+02
     15       8.000E+01   8.400E+01   8.800E+01   9.200E+01   9.600E+01   1.000E+02   1.040E+02   1.080E+02   1.120E+02   1.160E+02
     16       9.000E+01   9.400E+01   9.800E+01   1.020E+02   1.060E+02   1.100E+02   1.140E+02   1.180E+02   1.220E+02   1.260E+02
     17       1.000E+02   1.040E+02   1.080E+02   1.120E+02   1.160E+02   1.200E+02   1.240E+02   1.280E+02   1.320E+02   1.360E+02
     18       1.100E+02   1.140E+02   1.180E+02   1.220E+02   1.260E+02   1.300E+02   1.340E+02   1.380E+02   1.420E+02   1.460E+02
     19       1.200E+02   1.240E+02   1.280E+02   1.320E+02   1.360E+02   1.400E+02   1.440E+02   1.480E+02   1.520E+02   1.560E+02
     20       1.300E+02   1.340E+02   1.380E+02   1.420E+02   1.460E+02   1.500E+02   1.540E+02   1.580E+02   1.620E+02   1.660E+02
boxflt2 boxfr boxfrb
Beginning VICAR task boxflt2
BOXFLT2  02-May-2011 (64-bit) RJB
list boxfrb
Beginning VICAR task list

   REAL     samples are interpreted as  REAL*4  data
 Task:GEN       User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
 Task:BOXFLT2   User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
     Samp             1           2           3           4           5           6           7           8           9          10
   Line
      1      -6.182E+01  -6.145E+01  -6.036E+01  -5.855E+01  -5.600E+01  -5.273E+01  -4.873E+01  -4.473E+01  -4.073E+01  -3.673E+01
      2      -6.091E+01  -6.055E+01  -5.945E+01  -5.764E+01  -5.509E+01  -5.182E+01  -4.782E+01  -4.382E+01  -3.982E+01  -3.582E+01
      3      -5.818E+01  -5.782E+01  -5.673E+01  -5.491E+01  -5.236E+01  -4.909E+01  -4.509E+01  -4.109E+01  -3.709E+01  -3.309E+01
      4      -5.364E+01  -5.327E+01  -5.218E+01  -5.036E+01  -4.782E+01  -4.455E+01  -4.055E+01  -3.655E+01  -3.255E+01  -2.855E+01
      5      -4.727E+01  -4.691E+01  -4.582E+01  -4.400E+01  -4.145E+01  -3.818E+01  -3.418E+01  -3.018E+01  -2.618E+01  -2.218E+01
      6      -3.909E+01  -3.873E+01  -3.764E+01  -3.582E+01  -3.327E+01  -3.000E+01  -2.600E+01  -2.200E+01  -1.800E+01  -1.400E+01
      7      -2.909E+01  -2.873E+01  -2.764E+01  -2.582E+01  -2.327E+01  -2.000E+01  -1.600E+01  -1.200E+01  -8.000E+00  -4.000E+00
      8      -1.909E+01  -1.873E+01  -1.764E+01  -1.582E+01  -1.327E+01  -1.000E+01  -6.000E+00  -2.000E+00   2.000E+00   6.000E+00
      9      -9.091E+00  -8.727E+00  -7.636E+00  -5.818E+00  -3.273E+00   0.000E+00   4.000E+00   8.000E+00   1.200E+01   1.600E+01
     10       9.091E-01   1.273E+00   2.364E+00   4.182E+00   6.727E+00   1.000E+01   1.400E+01   1.800E+01   2.200E+01   2.600E+01
     11       1.091E+01   1.127E+01   1.236E+01   1.418E+01   1.673E+01   2.000E+01   2.400E+01   2.800E+01   3.200E+01   3.600E+01
     12       2.091E+01   2.127E+01   2.236E+01   2.418E+01   2.673E+01   3.000E+01   3.400E+01   3.800E+01   4.200E+01   4.600E+01
     13       3.091E+01   3.127E+01   3.236E+01   3.418E+01   3.673E+01   4.000E+01   4.400E+01   4.800E+01   5.200E+01   5.600E+01
     14       4.091E+01   4.127E+01   4.236E+01   4.418E+01   4.673E+01   5.000E+01   5.400E+01   5.800E+01   6.200E+01   6.600E+01
     15       5.091E+01   5.127E+01   5.236E+01   5.418E+01   5.673E+01   6.000E+01   6.400E+01   6.800E+01   7.200E+01   7.600E+01
     16       5.909E+01   5.945E+01   6.055E+01   6.236E+01   6.491E+01   6.818E+01   7.218E+01   7.618E+01   8.018E+01   8.418E+01
     17       6.545E+01   6.582E+01   6.691E+01   6.873E+01   7.127E+01   7.455E+01   7.855E+01   8.255E+01   8.655E+01   9.055E+01
     18       7.000E+01   7.036E+01   7.145E+01   7.327E+01   7.582E+01   7.909E+01   8.309E+01   8.709E+01   9.109E+01   9.509E+01
     19       7.273E+01   7.309E+01   7.418E+01   7.600E+01   7.855E+01   8.182E+01   8.582E+01   8.982E+01   9.382E+01   9.782E+01
     20       7.364E+01   7.400E+01   7.509E+01   7.691E+01   7.945E+01   8.273E+01   8.673E+01   9.073E+01   9.473E+01   9.873E+01

   REAL     samples are interpreted as  REAL*4  data
 Task:GEN       User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
 Task:BOXFLT2   User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
     Samp            11          12          13          14          15          16          17          18          19          20
   Line
      1      -3.273E+01  -2.873E+01  -2.473E+01  -2.073E+01  -1.673E+01  -1.345E+01  -1.091E+01  -9.091E+00  -8.000E+00  -7.636E+00
      2      -3.182E+01  -2.782E+01  -2.382E+01  -1.982E+01  -1.582E+01  -1.255E+01  -1.000E+01  -8.182E+00  -7.091E+00  -6.727E+00
      3      -2.909E+01  -2.509E+01  -2.109E+01  -1.709E+01  -1.309E+01  -9.818E+00  -7.273E+00  -5.455E+00  -4.364E+00  -4.000E+00
      4      -2.455E+01  -2.055E+01  -1.655E+01  -1.255E+01  -8.545E+00  -5.273E+00  -2.727E+00  -9.091E-01   1.818E-01   5.455E-01
      5      -1.818E+01  -1.418E+01  -1.018E+01  -6.182E+00  -2.182E+00   1.091E+00   3.636E+00   5.455E+00   6.545E+00   6.909E+00
      6      -1.000E+01  -6.000E+00  -2.000E+00   2.000E+00   6.000E+00   9.273E+00   1.182E+01   1.364E+01   1.473E+01   1.509E+01
      7       0.000E+00   4.000E+00   8.000E+00   1.200E+01   1.600E+01   1.927E+01   2.182E+01   2.364E+01   2.473E+01   2.509E+01
      8       1.000E+01   1.400E+01   1.800E+01   2.200E+01   2.600E+01   2.927E+01   3.182E+01   3.364E+01   3.473E+01   3.509E+01
      9       2.000E+01   2.400E+01   2.800E+01   3.200E+01   3.600E+01   3.927E+01   4.182E+01   4.364E+01   4.473E+01   4.509E+01
     10       3.000E+01   3.400E+01   3.800E+01   4.200E+01   4.600E+01   4.927E+01   5.182E+01   5.364E+01   5.473E+01   5.509E+01
     11       4.000E+01   4.400E+01   4.800E+01   5.200E+01   5.600E+01   5.927E+01   6.182E+01   6.364E+01   6.473E+01   6.509E+01
     12       5.000E+01   5.400E+01   5.800E+01   6.200E+01   6.600E+01   6.927E+01   7.182E+01   7.364E+01   7.473E+01   7.509E+01
     13       6.000E+01   6.400E+01   6.800E+01   7.200E+01   7.600E+01   7.927E+01   8.182E+01   8.364E+01   8.473E+01   8.509E+01
     14       7.000E+01   7.400E+01   7.800E+01   8.200E+01   8.600E+01   8.927E+01   9.182E+01   9.364E+01   9.473E+01   9.509E+01
     15       8.000E+01   8.400E+01   8.800E+01   9.200E+01   9.600E+01   9.927E+01   1.018E+02   1.036E+02   1.047E+02   1.051E+02
     16       8.818E+01   9.218E+01   9.618E+01   1.002E+02   1.042E+02   1.075E+02   1.100E+02   1.118E+02   1.129E+02   1.133E+02
     17       9.455E+01   9.855E+01   1.025E+02   1.065E+02   1.105E+02   1.138E+02   1.164E+02   1.182E+02   1.193E+02   1.196E+02
     18       9.909E+01   1.031E+02   1.071E+02   1.111E+02   1.151E+02   1.184E+02   1.209E+02   1.227E+02   1.238E+02   1.242E+02
     19       1.018E+02   1.058E+02   1.098E+02   1.138E+02   1.178E+02   1.211E+02   1.236E+02   1.255E+02   1.265E+02   1.269E+02
     20       1.027E+02   1.067E+02   1.107E+02   1.147E+02   1.187E+02   1.220E+02   1.245E+02   1.264E+02   1.275E+02   1.278E+02
boxflt2 boxfr boxfrc nlw=1 nsw=1
Beginning VICAR task boxflt2
BOXFLT2  02-May-2011 (64-bit) RJB
list boxfrc
Beginning VICAR task list

   REAL     samples are interpreted as  REAL*4  data
 Task:GEN       User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
 Task:BOXFLT2   User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
     Samp             1           2           3           4           5           6           7           8           9          10
   Line
      1      -1.000E+02  -9.600E+01  -9.200E+01  -8.800E+01  -8.400E+01  -8.000E+01  -7.600E+01  -7.200E+01  -6.800E+01  -6.400E+01
      2      -9.000E+01  -8.600E+01  -8.200E+01  -7.800E+01  -7.400E+01  -7.000E+01  -6.600E+01  -6.200E+01  -5.800E+01  -5.400E+01
      3      -8.000E+01  -7.600E+01  -7.200E+01  -6.800E+01  -6.400E+01  -6.000E+01  -5.600E+01  -5.200E+01  -4.800E+01  -4.400E+01
      4      -7.000E+01  -6.600E+01  -6.200E+01  -5.800E+01  -5.400E+01  -5.000E+01  -4.600E+01  -4.200E+01  -3.800E+01  -3.400E+01
      5      -6.000E+01  -5.600E+01  -5.200E+01  -4.800E+01  -4.400E+01  -4.000E+01  -3.600E+01  -3.200E+01  -2.800E+01  -2.400E+01
      6      -5.000E+01  -4.600E+01  -4.200E+01  -3.800E+01  -3.400E+01  -3.000E+01  -2.600E+01  -2.200E+01  -1.800E+01  -1.400E+01
      7      -4.000E+01  -3.600E+01  -3.200E+01  -2.800E+01  -2.400E+01  -2.000E+01  -1.600E+01  -1.200E+01  -8.000E+00  -4.000E+00
      8      -3.000E+01  -2.600E+01  -2.200E+01  -1.800E+01  -1.400E+01  -1.000E+01  -6.000E+00  -2.000E+00   2.000E+00   6.000E+00
      9      -2.000E+01  -1.600E+01  -1.200E+01  -8.000E+00  -4.000E+00   0.000E+00   4.000E+00   8.000E+00   1.200E+01   1.600E+01
     10      -1.000E+01  -6.000E+00  -2.000E+00   2.000E+00   6.000E+00   1.000E+01   1.400E+01   1.800E+01   2.200E+01   2.600E+01
     11       0.000E+00   4.000E+00   8.000E+00   1.200E+01   1.600E+01   2.000E+01   2.400E+01   2.800E+01   3.200E+01   3.600E+01
     12       1.000E+01   1.400E+01   1.800E+01   2.200E+01   2.600E+01   3.000E+01   3.400E+01   3.800E+01   4.200E+01   4.600E+01
     13       2.000E+01   2.400E+01   2.800E+01   3.200E+01   3.600E+01   4.000E+01   4.400E+01   4.800E+01   5.200E+01   5.600E+01
     14       3.000E+01   3.400E+01   3.800E+01   4.200E+01   4.600E+01   5.000E+01   5.400E+01   5.800E+01   6.200E+01   6.600E+01
     15       4.000E+01   4.400E+01   4.800E+01   5.200E+01   5.600E+01   6.000E+01   6.400E+01   6.800E+01   7.200E+01   7.600E+01
     16       5.000E+01   5.400E+01   5.800E+01   6.200E+01   6.600E+01   7.000E+01   7.400E+01   7.800E+01   8.200E+01   8.600E+01
     17       6.000E+01   6.400E+01   6.800E+01   7.200E+01   7.600E+01   8.000E+01   8.400E+01   8.800E+01   9.200E+01   9.600E+01
     18       7.000E+01   7.400E+01   7.800E+01   8.200E+01   8.600E+01   9.000E+01   9.400E+01   9.800E+01   1.020E+02   1.060E+02
     19       8.000E+01   8.400E+01   8.800E+01   9.200E+01   9.600E+01   1.000E+02   1.040E+02   1.080E+02   1.120E+02   1.160E+02
     20       9.000E+01   9.400E+01   9.800E+01   1.020E+02   1.060E+02   1.100E+02   1.140E+02   1.180E+02   1.220E+02   1.260E+02

   REAL     samples are interpreted as  REAL*4  data
 Task:GEN       User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
 Task:BOXFLT2   User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
     Samp            11          12          13          14          15          16          17          18          19          20
   Line
      1      -6.000E+01  -5.600E+01  -5.200E+01  -4.800E+01  -4.400E+01  -4.000E+01  -3.600E+01  -3.200E+01  -2.800E+01  -2.400E+01
      2      -5.000E+01  -4.600E+01  -4.200E+01  -3.800E+01  -3.400E+01  -3.000E+01  -2.600E+01  -2.200E+01  -1.800E+01  -1.400E+01
      3      -4.000E+01  -3.600E+01  -3.200E+01  -2.800E+01  -2.400E+01  -2.000E+01  -1.600E+01  -1.200E+01  -8.000E+00  -4.000E+00
      4      -3.000E+01  -2.600E+01  -2.200E+01  -1.800E+01  -1.400E+01  -1.000E+01  -6.000E+00  -2.000E+00   2.000E+00   6.000E+00
      5      -2.000E+01  -1.600E+01  -1.200E+01  -8.000E+00  -4.000E+00   0.000E+00   4.000E+00   8.000E+00   1.200E+01   1.600E+01
      6      -1.000E+01  -6.000E+00  -2.000E+00   2.000E+00   6.000E+00   1.000E+01   1.400E+01   1.800E+01   2.200E+01   2.600E+01
      7       0.000E+00   4.000E+00   8.000E+00   1.200E+01   1.600E+01   2.000E+01   2.400E+01   2.800E+01   3.200E+01   3.600E+01
      8       1.000E+01   1.400E+01   1.800E+01   2.200E+01   2.600E+01   3.000E+01   3.400E+01   3.800E+01   4.200E+01   4.600E+01
      9       2.000E+01   2.400E+01   2.800E+01   3.200E+01   3.600E+01   4.000E+01   4.400E+01   4.800E+01   5.200E+01   5.600E+01
     10       3.000E+01   3.400E+01   3.800E+01   4.200E+01   4.600E+01   5.000E+01   5.400E+01   5.800E+01   6.200E+01   6.600E+01
     11       4.000E+01   4.400E+01   4.800E+01   5.200E+01   5.600E+01   6.000E+01   6.400E+01   6.800E+01   7.200E+01   7.600E+01
     12       5.000E+01   5.400E+01   5.800E+01   6.200E+01   6.600E+01   7.000E+01   7.400E+01   7.800E+01   8.200E+01   8.600E+01
     13       6.000E+01   6.400E+01   6.800E+01   7.200E+01   7.600E+01   8.000E+01   8.400E+01   8.800E+01   9.200E+01   9.600E+01
     14       7.000E+01   7.400E+01   7.800E+01   8.200E+01   8.600E+01   9.000E+01   9.400E+01   9.800E+01   1.020E+02   1.060E+02
     15       8.000E+01   8.400E+01   8.800E+01   9.200E+01   9.600E+01   1.000E+02   1.040E+02   1.080E+02   1.120E+02   1.160E+02
     16       9.000E+01   9.400E+01   9.800E+01   1.020E+02   1.060E+02   1.100E+02   1.140E+02   1.180E+02   1.220E+02   1.260E+02
     17       1.000E+02   1.040E+02   1.080E+02   1.120E+02   1.160E+02   1.200E+02   1.240E+02   1.280E+02   1.320E+02   1.360E+02
     18       1.100E+02   1.140E+02   1.180E+02   1.220E+02   1.260E+02   1.300E+02   1.340E+02   1.380E+02   1.420E+02   1.460E+02
     19       1.200E+02   1.240E+02   1.280E+02   1.320E+02   1.360E+02   1.400E+02   1.440E+02   1.480E+02   1.520E+02   1.560E+02
     20       1.300E+02   1.340E+02   1.380E+02   1.420E+02   1.460E+02   1.500E+02   1.540E+02   1.580E+02   1.620E+02   1.660E+02
boxflt2 boxfr boxfrd 'highpass dclevel=100. 'cycle
Beginning VICAR task boxflt2
BOXFLT2  02-May-2011 (64-bit) RJB
HIGH PASS FILTER PERFORMED.
list boxfrd
Beginning VICAR task list

   REAL     samples are interpreted as  REAL*4  data
 Task:GEN       User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
 Task:BOXFLT2   User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
     Samp             1           2           3           4           5           6           7           8           9          10
   Line
      1      -2.727E+01  -2.000E+01  -1.273E+01  -5.455E+00   1.818E+00   9.091E+00   9.091E+00   9.091E+00   9.091E+00   9.091E+00
      2      -9.091E+00  -1.818E+00   5.455E+00   1.273E+01   2.000E+01   2.727E+01   2.727E+01   2.727E+01   2.727E+01   2.727E+01
      3       9.091E+00   1.636E+01   2.364E+01   3.091E+01   3.818E+01   4.545E+01   4.545E+01   4.545E+01   4.545E+01   4.545E+01
      4       2.727E+01   3.455E+01   4.182E+01   4.909E+01   5.636E+01   6.364E+01   6.364E+01   6.364E+01   6.364E+01   6.364E+01
      5       4.545E+01   5.273E+01   6.000E+01   6.727E+01   7.455E+01   8.182E+01   8.182E+01   8.182E+01   8.182E+01   8.182E+01
      6       6.364E+01   7.091E+01   7.818E+01   8.545E+01   9.273E+01   1.000E+02   1.000E+02   1.000E+02   1.000E+02   1.000E+02
      7       6.364E+01   7.091E+01   7.818E+01   8.545E+01   9.273E+01   1.000E+02   1.000E+02   1.000E+02   1.000E+02   1.000E+02
      8       6.364E+01   7.091E+01   7.818E+01   8.545E+01   9.273E+01   1.000E+02   1.000E+02   1.000E+02   1.000E+02   1.000E+02
      9       6.364E+01   7.091E+01   7.818E+01   8.545E+01   9.273E+01   1.000E+02   1.000E+02   1.000E+02   1.000E+02   1.000E+02
     10       6.364E+01   7.091E+01   7.818E+01   8.545E+01   9.273E+01   1.000E+02   1.000E+02   1.000E+02   1.000E+02   1.000E+02
     11       6.364E+01   7.091E+01   7.818E+01   8.545E+01   9.273E+01   1.000E+02   1.000E+02   1.000E+02   1.000E+02   1.000E+02
     12       6.364E+01   7.091E+01   7.818E+01   8.545E+01   9.273E+01   1.000E+02   1.000E+02   1.000E+02   1.000E+02   1.000E+02
     13       6.364E+01   7.091E+01   7.818E+01   8.545E+01   9.273E+01   1.000E+02   1.000E+02   1.000E+02   1.000E+02   1.000E+02
     14       6.364E+01   7.091E+01   7.818E+01   8.545E+01   9.273E+01   1.000E+02   1.000E+02   1.000E+02   1.000E+02   1.000E+02
     15       6.364E+01   7.091E+01   7.818E+01   8.545E+01   9.273E+01   1.000E+02   1.000E+02   1.000E+02   1.000E+02   1.000E+02
     16       8.182E+01   8.909E+01   9.636E+01   1.036E+02   1.109E+02   1.182E+02   1.182E+02   1.182E+02   1.182E+02   1.182E+02
     17       1.000E+02   1.073E+02   1.145E+02   1.218E+02   1.291E+02   1.364E+02   1.364E+02   1.364E+02   1.364E+02   1.364E+02
     18       1.182E+02   1.255E+02   1.327E+02   1.400E+02   1.473E+02   1.545E+02   1.545E+02   1.545E+02   1.545E+02   1.545E+02
     19       1.364E+02   1.436E+02   1.509E+02   1.582E+02   1.655E+02   1.727E+02   1.727E+02   1.727E+02   1.727E+02   1.727E+02
     20       1.545E+02   1.618E+02   1.691E+02   1.764E+02   1.836E+02   1.909E+02   1.909E+02   1.909E+02   1.909E+02   1.909E+02

   REAL     samples are interpreted as  REAL*4  data
 Task:GEN       User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
 Task:BOXFLT2   User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
     Samp            11          12          13          14          15          16          17          18          19          20
   Line
      1       9.091E+00   9.091E+00   9.091E+00   9.091E+00   9.091E+00   1.636E+01   2.364E+01   3.091E+01   3.818E+01   4.545E+01
      2       2.727E+01   2.727E+01   2.727E+01   2.727E+01   2.727E+01   3.455E+01   4.182E+01   4.909E+01   5.636E+01   6.364E+01
      3       4.545E+01   4.545E+01   4.545E+01   4.545E+01   4.545E+01   5.273E+01   6.000E+01   6.727E+01   7.455E+01   8.182E+01
      4       6.364E+01   6.364E+01   6.364E+01   6.364E+01   6.364E+01   7.091E+01   7.818E+01   8.545E+01   9.273E+01   1.000E+02
      5       8.182E+01   8.182E+01   8.182E+01   8.182E+01   8.182E+01   8.909E+01   9.636E+01   1.036E+02   1.109E+02   1.182E+02
      6       1.000E+02   1.000E+02   1.000E+02   1.000E+02   1.000E+02   1.073E+02   1.145E+02   1.218E+02   1.291E+02   1.364E+02
      7       1.000E+02   1.000E+02   1.000E+02   1.000E+02   1.000E+02   1.073E+02   1.145E+02   1.218E+02   1.291E+02   1.364E+02
      8       1.000E+02   1.000E+02   1.000E+02   1.000E+02   1.000E+02   1.073E+02   1.145E+02   1.218E+02   1.291E+02   1.364E+02
      9       1.000E+02   1.000E+02   1.000E+02   1.000E+02   1.000E+02   1.073E+02   1.145E+02   1.218E+02   1.291E+02   1.364E+02
     10       1.000E+02   1.000E+02   1.000E+02   1.000E+02   1.000E+02   1.073E+02   1.145E+02   1.218E+02   1.291E+02   1.364E+02
     11       1.000E+02   1.000E+02   1.000E+02   1.000E+02   1.000E+02   1.073E+02   1.145E+02   1.218E+02   1.291E+02   1.364E+02
     12       1.000E+02   1.000E+02   1.000E+02   1.000E+02   1.000E+02   1.073E+02   1.145E+02   1.218E+02   1.291E+02   1.364E+02
     13       1.000E+02   1.000E+02   1.000E+02   1.000E+02   1.000E+02   1.073E+02   1.145E+02   1.218E+02   1.291E+02   1.364E+02
     14       1.000E+02   1.000E+02   1.000E+02   1.000E+02   1.000E+02   1.073E+02   1.145E+02   1.218E+02   1.291E+02   1.364E+02
     15       1.000E+02   1.000E+02   1.000E+02   1.000E+02   1.000E+02   1.073E+02   1.145E+02   1.218E+02   1.291E+02   1.364E+02
     16       1.182E+02   1.182E+02   1.182E+02   1.182E+02   1.182E+02   1.255E+02   1.327E+02   1.400E+02   1.473E+02   1.545E+02
     17       1.364E+02   1.364E+02   1.364E+02   1.364E+02   1.364E+02   1.436E+02   1.509E+02   1.582E+02   1.655E+02   1.727E+02
     18       1.545E+02   1.545E+02   1.545E+02   1.545E+02   1.545E+02   1.618E+02   1.691E+02   1.764E+02   1.836E+02   1.909E+02
     19       1.727E+02   1.727E+02   1.727E+02   1.727E+02   1.727E+02   1.800E+02   1.873E+02   1.945E+02   2.018E+02   2.091E+02
     20       1.909E+02   1.909E+02   1.909E+02   1.909E+02   1.909E+02   1.982E+02   2.055E+02   2.127E+02   2.200E+02   2.273E+02
boxflt2 boxfr boxfre 'lcycle
Beginning VICAR task boxflt2
BOXFLT2  02-May-2011 (64-bit) RJB
list boxfre
Beginning VICAR task list

   REAL     samples are interpreted as  REAL*4  data
 Task:GEN       User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
 Task:BOXFLT2   User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
     Samp             1           2           3           4           5           6           7           8           9          10
   Line
      1       1.818E+00   2.182E+00   3.273E+00   5.091E+00   7.636E+00   1.091E+01   1.491E+01   1.891E+01   2.291E+01   2.691E+01
      2      -6.364E+00  -6.000E+00  -4.909E+00  -3.091E+00  -5.455E-01   2.727E+00   6.727E+00   1.073E+01   1.473E+01   1.873E+01
      3      -1.455E+01  -1.418E+01  -1.309E+01  -1.127E+01  -8.727E+00  -5.455E+00  -1.455E+00   2.545E+00   6.545E+00   1.055E+01
      4      -2.273E+01  -2.236E+01  -2.127E+01  -1.945E+01  -1.691E+01  -1.364E+01  -9.636E+00  -5.636E+00  -1.636E+00   2.364E+00
      5      -3.091E+01  -3.055E+01  -2.945E+01  -2.764E+01  -2.509E+01  -2.182E+01  -1.782E+01  -1.382E+01  -9.818E+00  -5.818E+00
      6      -3.909E+01  -3.873E+01  -3.764E+01  -3.582E+01  -3.327E+01  -3.000E+01  -2.600E+01  -2.200E+01  -1.800E+01  -1.400E+01
      7      -2.909E+01  -2.873E+01  -2.764E+01  -2.582E+01  -2.327E+01  -2.000E+01  -1.600E+01  -1.200E+01  -8.000E+00  -4.000E+00
      8      -1.909E+01  -1.873E+01  -1.764E+01  -1.582E+01  -1.327E+01  -1.000E+01  -6.000E+00  -2.000E+00   2.000E+00   6.000E+00
      9      -9.091E+00  -8.727E+00  -7.636E+00  -5.818E+00  -3.273E+00   0.000E+00   4.000E+00   8.000E+00   1.200E+01   1.600E+01
     10       9.091E-01   1.273E+00   2.364E+00   4.182E+00   6.727E+00   1.000E+01   1.400E+01   1.800E+01   2.200E+01   2.600E+01
     11       1.091E+01   1.127E+01   1.236E+01   1.418E+01   1.673E+01   2.000E+01   2.400E+01   2.800E+01   3.200E+01   3.600E+01
     12       2.091E+01   2.127E+01   2.236E+01   2.418E+01   2.673E+01   3.000E+01   3.400E+01   3.800E+01   4.200E+01   4.600E+01
     13       3.091E+01   3.127E+01   3.236E+01   3.418E+01   3.673E+01   4.000E+01   4.400E+01   4.800E+01   5.200E+01   5.600E+01
     14       4.091E+01   4.127E+01   4.236E+01   4.418E+01   4.673E+01   5.000E+01   5.400E+01   5.800E+01   6.200E+01   6.600E+01
     15       5.091E+01   5.127E+01   5.236E+01   5.418E+01   5.673E+01   6.000E+01   6.400E+01   6.800E+01   7.200E+01   7.600E+01
     16       4.273E+01   4.309E+01   4.418E+01   4.600E+01   4.855E+01   5.182E+01   5.582E+01   5.982E+01   6.382E+01   6.782E+01
     17       3.455E+01   3.491E+01   3.600E+01   3.782E+01   4.036E+01   4.364E+01   4.764E+01   5.164E+01   5.564E+01   5.964E+01
     18       2.636E+01   2.673E+01   2.782E+01   2.964E+01   3.218E+01   3.545E+01   3.945E+01   4.345E+01   4.745E+01   5.145E+01
     19       1.818E+01   1.855E+01   1.964E+01   2.145E+01   2.400E+01   2.727E+01   3.127E+01   3.527E+01   3.927E+01   4.327E+01
     20       1.000E+01   1.036E+01   1.145E+01   1.327E+01   1.582E+01   1.909E+01   2.309E+01   2.709E+01   3.109E+01   3.509E+01

   REAL     samples are interpreted as  REAL*4  data
 Task:GEN       User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
 Task:BOXFLT2   User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
     Samp            11          12          13          14          15          16          17          18          19          20
   Line
      1       3.091E+01   3.491E+01   3.891E+01   4.291E+01   4.691E+01   5.018E+01   5.273E+01   5.455E+01   5.564E+01   5.600E+01
      2       2.273E+01   2.673E+01   3.073E+01   3.473E+01   3.873E+01   4.200E+01   4.455E+01   4.636E+01   4.745E+01   4.782E+01
      3       1.455E+01   1.855E+01   2.255E+01   2.655E+01   3.055E+01   3.382E+01   3.636E+01   3.818E+01   3.927E+01   3.964E+01
      4       6.364E+00   1.036E+01   1.436E+01   1.836E+01   2.236E+01   2.564E+01   2.818E+01   3.000E+01   3.109E+01   3.145E+01
      5      -1.818E+00   2.182E+00   6.182E+00   1.018E+01   1.418E+01   1.745E+01   2.000E+01   2.182E+01   2.291E+01   2.327E+01
      6      -1.000E+01  -6.000E+00  -2.000E+00   2.000E+00   6.000E+00   9.273E+00   1.182E+01   1.364E+01   1.473E+01   1.509E+01
      7       0.000E+00   4.000E+00   8.000E+00   1.200E+01   1.600E+01   1.927E+01   2.182E+01   2.364E+01   2.473E+01   2.509E+01
      8       1.000E+01   1.400E+01   1.800E+01   2.200E+01   2.600E+01   2.927E+01   3.182E+01   3.364E+01   3.473E+01   3.509E+01
      9       2.000E+01   2.400E+01   2.800E+01   3.200E+01   3.600E+01   3.927E+01   4.182E+01   4.364E+01   4.473E+01   4.509E+01
     10       3.000E+01   3.400E+01   3.800E+01   4.200E+01   4.600E+01   4.927E+01   5.182E+01   5.364E+01   5.473E+01   5.509E+01
     11       4.000E+01   4.400E+01   4.800E+01   5.200E+01   5.600E+01   5.927E+01   6.182E+01   6.364E+01   6.473E+01   6.509E+01
     12       5.000E+01   5.400E+01   5.800E+01   6.200E+01   6.600E+01   6.927E+01   7.182E+01   7.364E+01   7.473E+01   7.509E+01
     13       6.000E+01   6.400E+01   6.800E+01   7.200E+01   7.600E+01   7.927E+01   8.182E+01   8.364E+01   8.473E+01   8.509E+01
     14       7.000E+01   7.400E+01   7.800E+01   8.200E+01   8.600E+01   8.927E+01   9.182E+01   9.364E+01   9.473E+01   9.509E+01
     15       8.000E+01   8.400E+01   8.800E+01   9.200E+01   9.600E+01   9.927E+01   1.018E+02   1.036E+02   1.047E+02   1.051E+02
     16       7.182E+01   7.582E+01   7.982E+01   8.382E+01   8.782E+01   9.109E+01   9.364E+01   9.545E+01   9.655E+01   9.691E+01
     17       6.364E+01   6.764E+01   7.164E+01   7.564E+01   7.964E+01   8.291E+01   8.545E+01   8.727E+01   8.836E+01   8.873E+01
     18       5.545E+01   5.945E+01   6.345E+01   6.745E+01   7.145E+01   7.473E+01   7.727E+01   7.909E+01   8.018E+01   8.055E+01
     19       4.727E+01   5.127E+01   5.527E+01   5.927E+01   6.327E+01   6.655E+01   6.909E+01   7.091E+01   7.200E+01   7.236E+01
     20       3.909E+01   4.309E+01   4.709E+01   5.109E+01   5.509E+01   5.836E+01   6.091E+01   6.273E+01   6.382E+01   6.418E+01
boxflt2 boxfr boxfrf 'scycle
Beginning VICAR task boxflt2
BOXFLT2  02-May-2011 (64-bit) RJB
list boxfrf
Beginning VICAR task list

   REAL     samples are interpreted as  REAL*4  data
 Task:GEN       User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
 Task:BOXFLT2   User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
     Samp             1           2           3           4           5           6           7           8           9          10
   Line
      1      -3.636E+01  -3.964E+01  -4.291E+01  -4.618E+01  -4.945E+01  -5.273E+01  -4.873E+01  -4.473E+01  -4.073E+01  -3.673E+01
      2      -3.545E+01  -3.873E+01  -4.200E+01  -4.527E+01  -4.855E+01  -5.182E+01  -4.782E+01  -4.382E+01  -3.982E+01  -3.582E+01
      3      -3.273E+01  -3.600E+01  -3.927E+01  -4.255E+01  -4.582E+01  -4.909E+01  -4.509E+01  -4.109E+01  -3.709E+01  -3.309E+01
      4      -2.818E+01  -3.145E+01  -3.473E+01  -3.800E+01  -4.127E+01  -4.455E+01  -4.055E+01  -3.655E+01  -3.255E+01  -2.855E+01
      5      -2.182E+01  -2.509E+01  -2.836E+01  -3.164E+01  -3.491E+01  -3.818E+01  -3.418E+01  -3.018E+01  -2.618E+01  -2.218E+01
      6      -1.364E+01  -1.691E+01  -2.018E+01  -2.345E+01  -2.673E+01  -3.000E+01  -2.600E+01  -2.200E+01  -1.800E+01  -1.400E+01
      7      -3.636E+00  -6.909E+00  -1.018E+01  -1.345E+01  -1.673E+01  -2.000E+01  -1.600E+01  -1.200E+01  -8.000E+00  -4.000E+00
      8       6.364E+00   3.091E+00  -1.818E-01  -3.455E+00  -6.727E+00  -1.000E+01  -6.000E+00  -2.000E+00   2.000E+00   6.000E+00
      9       1.636E+01   1.309E+01   9.818E+00   6.545E+00   3.273E+00   0.000E+00   4.000E+00   8.000E+00   1.200E+01   1.600E+01
     10       2.636E+01   2.309E+01   1.982E+01   1.655E+01   1.327E+01   1.000E+01   1.400E+01   1.800E+01   2.200E+01   2.600E+01
     11       3.636E+01   3.309E+01   2.982E+01   2.655E+01   2.327E+01   2.000E+01   2.400E+01   2.800E+01   3.200E+01   3.600E+01
     12       4.636E+01   4.309E+01   3.982E+01   3.655E+01   3.327E+01   3.000E+01   3.400E+01   3.800E+01   4.200E+01   4.600E+01
     13       5.636E+01   5.309E+01   4.982E+01   4.655E+01   4.327E+01   4.000E+01   4.400E+01   4.800E+01   5.200E+01   5.600E+01
     14       6.636E+01   6.309E+01   5.982E+01   5.655E+01   5.327E+01   5.000E+01   5.400E+01   5.800E+01   6.200E+01   6.600E+01
     15       7.636E+01   7.309E+01   6.982E+01   6.655E+01   6.327E+01   6.000E+01   6.400E+01   6.800E+01   7.200E+01   7.600E+01
     16       8.455E+01   8.127E+01   7.800E+01   7.473E+01   7.145E+01   6.818E+01   7.218E+01   7.618E+01   8.018E+01   8.418E+01
     17       9.091E+01   8.764E+01   8.436E+01   8.109E+01   7.782E+01   7.455E+01   7.855E+01   8.255E+01   8.655E+01   9.055E+01
     18       9.545E+01   9.218E+01   8.891E+01   8.564E+01   8.236E+01   7.909E+01   8.309E+01   8.709E+01   9.109E+01   9.509E+01
     19       9.818E+01   9.491E+01   9.164E+01   8.836E+01   8.509E+01   8.182E+01   8.582E+01   8.982E+01   9.382E+01   9.782E+01
     20       9.909E+01   9.582E+01   9.255E+01   8.927E+01   8.600E+01   8.273E+01   8.673E+01   9.073E+01   9.473E+01   9.873E+01

   REAL     samples are interpreted as  REAL*4  data
 Task:GEN       User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
 Task:BOXFLT2   User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
     Samp            11          12          13          14          15          16          17          18          19          20
   Line
      1      -3.273E+01  -2.873E+01  -2.473E+01  -2.073E+01  -1.673E+01  -2.000E+01  -2.327E+01  -2.655E+01  -2.982E+01  -3.309E+01
      2      -3.182E+01  -2.782E+01  -2.382E+01  -1.982E+01  -1.582E+01  -1.909E+01  -2.236E+01  -2.564E+01  -2.891E+01  -3.218E+01
      3      -2.909E+01  -2.509E+01  -2.109E+01  -1.709E+01  -1.309E+01  -1.636E+01  -1.964E+01  -2.291E+01  -2.618E+01  -2.945E+01
      4      -2.455E+01  -2.055E+01  -1.655E+01  -1.255E+01  -8.545E+00  -1.182E+01  -1.509E+01  -1.836E+01  -2.164E+01  -2.491E+01
      5      -1.818E+01  -1.418E+01  -1.018E+01  -6.182E+00  -2.182E+00  -5.455E+00  -8.727E+00  -1.200E+01  -1.527E+01  -1.855E+01
      6      -1.000E+01  -6.000E+00  -2.000E+00   2.000E+00   6.000E+00   2.727E+00  -5.455E-01  -3.818E+00  -7.091E+00  -1.036E+01
      7       0.000E+00   4.000E+00   8.000E+00   1.200E+01   1.600E+01   1.273E+01   9.455E+00   6.182E+00   2.909E+00  -3.636E-01
      8       1.000E+01   1.400E+01   1.800E+01   2.200E+01   2.600E+01   2.273E+01   1.945E+01   1.618E+01   1.291E+01   9.636E+00
      9       2.000E+01   2.400E+01   2.800E+01   3.200E+01   3.600E+01   3.273E+01   2.945E+01   2.618E+01   2.291E+01   1.964E+01
     10       3.000E+01   3.400E+01   3.800E+01   4.200E+01   4.600E+01   4.273E+01   3.945E+01   3.618E+01   3.291E+01   2.964E+01
     11       4.000E+01   4.400E+01   4.800E+01   5.200E+01   5.600E+01   5.273E+01   4.945E+01   4.618E+01   4.291E+01   3.964E+01
     12       5.000E+01   5.400E+01   5.800E+01   6.200E+01   6.600E+01   6.273E+01   5.945E+01   5.618E+01   5.291E+01   4.964E+01
     13       6.000E+01   6.400E+01   6.800E+01   7.200E+01   7.600E+01   7.273E+01   6.945E+01   6.618E+01   6.291E+01   5.964E+01
     14       7.000E+01   7.400E+01   7.800E+01   8.200E+01   8.600E+01   8.273E+01   7.945E+01   7.618E+01   7.291E+01   6.964E+01
     15       8.000E+01   8.400E+01   8.800E+01   9.200E+01   9.600E+01   9.273E+01   8.945E+01   8.618E+01   8.291E+01   7.964E+01
     16       8.818E+01   9.218E+01   9.618E+01   1.002E+02   1.042E+02   1.009E+02   9.764E+01   9.436E+01   9.109E+01   8.782E+01
     17       9.455E+01   9.855E+01   1.025E+02   1.065E+02   1.105E+02   1.073E+02   1.040E+02   1.007E+02   9.745E+01   9.418E+01
     18       9.909E+01   1.031E+02   1.071E+02   1.111E+02   1.151E+02   1.118E+02   1.085E+02   1.053E+02   1.020E+02   9.873E+01
     19       1.018E+02   1.058E+02   1.098E+02   1.138E+02   1.178E+02   1.145E+02   1.113E+02   1.080E+02   1.047E+02   1.015E+02
     20       1.027E+02   1.067E+02   1.107E+02   1.147E+02   1.187E+02   1.155E+02   1.122E+02   1.089E+02   1.056E+02   1.024E+02
boxflt2 boxfr boxfrg 'reflect 'highpass
Beginning VICAR task boxflt2
BOXFLT2  02-May-2011 (64-bit) RJB
HIGH PASS FILTER PERFORMED.
list boxfrg
Beginning VICAR task list

   REAL     samples are interpreted as  REAL*4  data
 Task:GEN       User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
 Task:BOXFLT2   User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
     Samp             1           2           3           4           5           6           7           8           9          10
   Line
      1       8.982E+01   9.345E+01   9.636E+01   9.855E+01   1.000E+02   1.007E+02   1.007E+02   1.007E+02   1.007E+02   1.007E+02
      2       9.891E+01   1.025E+02   1.055E+02   1.076E+02   1.091E+02   1.098E+02   1.098E+02   1.098E+02   1.098E+02   1.098E+02
      3       1.062E+02   1.098E+02   1.127E+02   1.149E+02   1.164E+02   1.171E+02   1.171E+02   1.171E+02   1.171E+02   1.171E+02
      4       1.116E+02   1.153E+02   1.182E+02   1.204E+02   1.218E+02   1.225E+02   1.225E+02   1.225E+02   1.225E+02   1.225E+02
      5       1.153E+02   1.189E+02   1.218E+02   1.240E+02   1.255E+02   1.262E+02   1.262E+02   1.262E+02   1.262E+02   1.262E+02
      6       1.171E+02   1.207E+02   1.236E+02   1.258E+02   1.273E+02   1.280E+02   1.280E+02   1.280E+02   1.280E+02   1.280E+02
      7       1.171E+02   1.207E+02   1.236E+02   1.258E+02   1.273E+02   1.280E+02   1.280E+02   1.280E+02   1.280E+02   1.280E+02
      8       1.171E+02   1.207E+02   1.236E+02   1.258E+02   1.273E+02   1.280E+02   1.280E+02   1.280E+02   1.280E+02   1.280E+02
      9       1.171E+02   1.207E+02   1.236E+02   1.258E+02   1.273E+02   1.280E+02   1.280E+02   1.280E+02   1.280E+02   1.280E+02
     10       1.171E+02   1.207E+02   1.236E+02   1.258E+02   1.273E+02   1.280E+02   1.280E+02   1.280E+02   1.280E+02   1.280E+02
     11       1.171E+02   1.207E+02   1.236E+02   1.258E+02   1.273E+02   1.280E+02   1.280E+02   1.280E+02   1.280E+02   1.280E+02
     12       1.171E+02   1.207E+02   1.236E+02   1.258E+02   1.273E+02   1.280E+02   1.280E+02   1.280E+02   1.280E+02   1.280E+02
     13       1.171E+02   1.207E+02   1.236E+02   1.258E+02   1.273E+02   1.280E+02   1.280E+02   1.280E+02   1.280E+02   1.280E+02
     14       1.171E+02   1.207E+02   1.236E+02   1.258E+02   1.273E+02   1.280E+02   1.280E+02   1.280E+02   1.280E+02   1.280E+02
     15       1.171E+02   1.207E+02   1.236E+02   1.258E+02   1.273E+02   1.280E+02   1.280E+02   1.280E+02   1.280E+02   1.280E+02
     16       1.189E+02   1.225E+02   1.255E+02   1.276E+02   1.291E+02   1.298E+02   1.298E+02   1.298E+02   1.298E+02   1.298E+02
     17       1.225E+02   1.262E+02   1.291E+02   1.313E+02   1.327E+02   1.335E+02   1.335E+02   1.335E+02   1.335E+02   1.335E+02
     18       1.280E+02   1.316E+02   1.345E+02   1.367E+02   1.382E+02   1.389E+02   1.389E+02   1.389E+02   1.389E+02   1.389E+02
     19       1.353E+02   1.389E+02   1.418E+02   1.440E+02   1.455E+02   1.462E+02   1.462E+02   1.462E+02   1.462E+02   1.462E+02
     20       1.444E+02   1.480E+02   1.509E+02   1.531E+02   1.545E+02   1.553E+02   1.553E+02   1.553E+02   1.553E+02   1.553E+02

   REAL     samples are interpreted as  REAL*4  data
 Task:GEN       User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
 Task:BOXFLT2   User:wlb       Date_Time:Wed Dec 17 13:21:45 2014
     Samp            11          12          13          14          15          16          17          18          19          20
   Line
      1       1.007E+02   1.007E+02   1.007E+02   1.007E+02   1.007E+02   1.015E+02   1.029E+02   1.051E+02   1.080E+02   1.116E+02
      2       1.098E+02   1.098E+02   1.098E+02   1.098E+02   1.098E+02   1.105E+02   1.120E+02   1.142E+02   1.171E+02   1.207E+02
      3       1.171E+02   1.171E+02   1.171E+02   1.171E+02   1.171E+02   1.178E+02   1.193E+02   1.215E+02   1.244E+02   1.280E+02
      4       1.225E+02   1.225E+02   1.225E+02   1.225E+02   1.225E+02   1.233E+02   1.247E+02   1.269E+02   1.298E+02   1.335E+02
      5       1.262E+02   1.262E+02   1.262E+02   1.262E+02   1.262E+02   1.269E+02   1.284E+02   1.305E+02   1.335E+02   1.371E+02
      6       1.280E+02   1.280E+02   1.280E+02   1.280E+02   1.280E+02   1.287E+02   1.302E+02   1.324E+02   1.353E+02   1.389E+02
      7       1.280E+02   1.280E+02   1.280E+02   1.280E+02   1.280E+02   1.287E+02   1.302E+02   1.324E+02   1.353E+02   1.389E+02
      8       1.280E+02   1.280E+02   1.280E+02   1.280E+02   1.280E+02   1.287E+02   1.302E+02   1.324E+02   1.353E+02   1.389E+02
      9       1.280E+02   1.280E+02   1.280E+02   1.280E+02   1.280E+02   1.287E+02   1.302E+02   1.324E+02   1.353E+02   1.389E+02
     10       1.280E+02   1.280E+02   1.280E+02   1.280E+02   1.280E+02   1.287E+02   1.302E+02   1.324E+02   1.353E+02   1.389E+02
     11       1.280E+02   1.280E+02   1.280E+02   1.280E+02   1.280E+02   1.287E+02   1.302E+02   1.324E+02   1.353E+02   1.389E+02
     12       1.280E+02   1.280E+02   1.280E+02   1.280E+02   1.280E+02   1.287E+02   1.302E+02   1.324E+02   1.353E+02   1.389E+02
     13       1.280E+02   1.280E+02   1.280E+02   1.280E+02   1.280E+02   1.287E+02   1.302E+02   1.324E+02   1.353E+02   1.389E+02
     14       1.280E+02   1.280E+02   1.280E+02   1.280E+02   1.280E+02   1.287E+02   1.302E+02   1.324E+02   1.353E+02   1.389E+02
     15       1.280E+02   1.280E+02   1.280E+02   1.280E+02   1.280E+02   1.287E+02   1.302E+02   1.324E+02   1.353E+02   1.389E+02
     16       1.298E+02   1.298E+02   1.298E+02   1.298E+02   1.298E+02   1.305E+02   1.320E+02   1.342E+02   1.371E+02   1.407E+02
     17       1.335E+02   1.335E+02   1.335E+02   1.335E+02   1.335E+02   1.342E+02   1.356E+02   1.378E+02   1.407E+02   1.444E+02
     18       1.389E+02   1.389E+02   1.389E+02   1.389E+02   1.389E+02   1.396E+02   1.411E+02   1.433E+02   1.462E+02   1.498E+02
     19       1.462E+02   1.462E+02   1.462E+02   1.462E+02   1.462E+02   1.469E+02   1.484E+02   1.505E+02   1.535E+02   1.571E+02
     20       1.553E+02   1.553E+02   1.553E+02   1.553E+02   1.553E+02   1.560E+02   1.575E+02   1.596E+02   1.625E+02   1.662E+02
let $echo="no"
$ Return
$!#############################################################################
