module io
#include "losub-inc.h"
   use parameters
   implicit none
contains

   subroutine readConfigFile(inputfile)
      IMPLICIT none
      CHARACTER(len=*) inputfile
      OPEN(15,FILE=inputfile,STATUS='OLD',ERR=10)
      GOTO 11
10    WRITE(*,*) 'LOSUB.F: Error while reading inputfile!'
      STOP   NO_INFILE
11    CONTINUE
      READ(15,'(A)',END=15) 
      READ(15,*,END=15) NE,LCALC
      READ(15,'(A)',END=15) 
      READ(15,*,END=15) Rt,Tau,Pt,ETA,Le,Rc
      READ(15,'(A)',END=15) 
      READ(15,*,END=15) NT,M0
      READ(15,'(A)',END=15) 
      READ(15,*,END=15) DRt,ABSE,RELE,NSMAX
      READ(15,'(A)',END=15) 
      READ(15,*,END=15) StepSize, UpperLimit
      CLOSE(15)
      GOTO 16
15    WRITE(*,*) 'Error in inputfile ',inputfile
      STOP ERR_IN_INFILE
16    CONTINUE
   end subroutine

!**********************************************************************
   subroutine writeOutputHeader(outputfile)
      use parameters
      IMPLICIT none
      CHARACTER(len=*) outputfile
      IF(LCALC.GT.0 .AND. LCALC.LT.4 .or. LCALC.eq.5.or.LCALC.eq.6) THEN
         WRITE(16,*)  '### Output of Program lo.f Ver.2.1:        ###'
         WRITE(16,*)  '### Lin. Onset of Conv. via Galerkinmethod ###'
         WRITE(16,'(A11,E12.5,A2)') '# P     ', Pt,     '#'
         WRITE(16,'(A11,E12.5,A2)') '# Lewis ', Le,     '#'
         WRITE(16,'(A11,E12.5,A2)') '# TAU   ', TAU,    '#'
         WRITE(16,'(A11,E12.5,A2)') '# R     ', Rt,     '#'
         WRITE(16,'(A11,E12.5,A2)') '# RC    ', Rc,     '#'
         WRITE(16,'(A11,E12.5,A2)') '# ETA   ', ETA,    '#'
         WRITE(16,'(A11,G12.5,A2)') '# m     ', M0,     '#'
         WRITE(16,'(A11,A12,A2)')   '# cvar  ','TAU',   '#'
         WRITE(16,'(A11,I12,A2)')   '# NE    ', NE,     '#'
         WRITE(16,'(A11,E12.5,A2)') '# LowerLimit   ', LowerLimit,    '#'
         WRITE(16,'(A11,E12.5,A2)') '# UpperLimit   ', UpperLimit,    '#'
         WRITE(16,'(A11,E12.5,A2)') '# StepSize',StepSize,  '#'
         WRITE(16,'(A11,I12,A2)')   '# NT    ', NT,     '#'
         WRITE(16,*)  '# see definition of LCALC for output. LCALC:', LCALC,'   #'
         WRITE(16,*)  '#                                      #'
      ENDIF
   end subroutine

! *************************************************************************
!     opens file <filename> and puts the filepointer at EOF
      subroutine open_file_at_end(NHANDLE,filename)
         implicit none
      INTEGER:: NHANDLE
      CHARACTER(len=*):: filename

      OPEN(NHANDLE,FILE=trim(filename),STATUS='OLD', POSITION='APPEND',ERR=990)
      GOTO 999
990   WRITE(*,*) 'Error reading ',filename
      STOP ERR_WRT_OUTFILE
999   CONTINUE
      END subroutine

! *************************************************************************
      subroutine writeConfigFile(outputfile)
         implicit none
         CHARACTER(len=*), intent(in):: outputfile

         OPEN(99,FILE=outputfile,STATUS='UNKNOWN')
         WRITE(99,*) ' NE (0/1/2) | LCALC (1/2/3/4) |'
         WRITE(99,'(A,2I12)') ' ',NE, LCALC
         WRITE(99,*) '|  RAYLEIGH  |  TAU     |  PRANTEL  |  ETA  | Lewis |   Rconc   |'
         WRITE(99,'(1P,E17.6,5(A,E17.6))') Rt,' ',TAU,' ',Pt,' ',ETA,' ',Le,' ',Rc
         WRITE(99,*) '|   NTRUNC (>=1) | MODE |'
         WRITE(99,'(A,2I12)') ' ',NT, M0
         WRITE(99,*) '|   DRA   | ABSERR  |  RELERR  | NMAX |'
         WRITE(99,'(1PG12.6,A,1PG11.5,A,1PG11.5,A,I4)') DRt,' ',ABSE,' ',RELE,' ',NSMAX
         WRITE(99,*) '|  StepSize  | UpperLimit'
         WRITE(99,'(1P,2G11.4)') StepSize, UpperLimit
         CLOSE(99)
      end subroutine writeConfigFile
end module io
