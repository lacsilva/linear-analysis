module CritRaEff_io
#include "errorcodes.h"
#include "version.h"
   use parameters
   use parser
   implicit none
contains
   !**********************************************************************
   subroutine readConfigFileNew(inputfile)
      implicit none
      CHARACTER(len=*) inputfile
      CHARACTER(len=60) varname
      CHARACTER(len=256) line
      integer:: err
      OPEN(15,FILE=inputfile,STATUS='OLD', iostat=err)
      if(err.ne.0) then
         WRITE(*,*) 'Error opening input file!'
         STOP   NO_INFILE
      endif
      do
         call parse(15, varname, line, err)
         if (err.ne.0) exit
         select case(varname)
            case('Calculation')
               call read_val(line, LCALC)
            case('Symmetry')
               call read_val(line, Symmetry)
            case('Truncation')
               call read_val(line, Truncation)
            case('Pt')
               call read_val(line, Pt)
            case('Le')
               call read_val(line, Le)
            case('m0')
               call read_val(line, m0)
            case('eta')
               call read_val(line, eta)
            case('tau')
               call read_val(line, tau)
            case('AbsParameterError')
               call read_val(line, ABSE)
            case('RelativeGREror')
               call read_val(line, RELE)
            case('MaxIterations')
               call read_val(line, NSMAX)
            case default
               cycle
         end select
      enddo
      close(15)
   end subroutine
   
   !**********************************************************************
   subroutine writeOutputHeader(unitOut)
      use parameters
      IMPLICIT none
      integer, intent(in):: unitOut
      WRITE(unitOut,*)  '### Output of Program glo  Ver.', VERSION,':   ###'
      WRITE(unitOut,*)  '### Lin. Onset of Conv. via Galerkinmethod ###'
      WRITE(unitOut,'(A11,E12.5,A2)') '# P            ', Pt,         '#'
      WRITE(unitOut,'(A11,E12.5,A2)') '# Lewis        ', Le,         '#'
      WRITE(unitOut,'(A11,E12.5,A2)') '# TAU          ', tau,        '#'
      WRITE(unitOut,'(A11,E12.5,A2)') '# ETA          ', ETA,        '#'
      WRITE(unitOut,'(A11,G12.5,A2)') '# m            ', M0,         '#'
      WRITE(unitOut,'(A11,I12,A2)'  ) '# Symmetry     ', Symmetry,   '#'
      WRITE(unitOut,'(A11,E12.5,A2)') '# LowerLimit   ', LowerLimit, '#'
      WRITE(unitOut,'(A11,E12.5,A2)') '# UpperLimit   ', UpperLimit, '#'
      WRITE(unitOut,'(A11,E12.5,A2)') '# StepSize     ', StepSize,   '#'
      WRITE(unitOut,'(A11,I12,A2)')   '# Truncation   ', Truncation, '#'
      WRITE(unitOut,*)  '#  alpha, Ra, m, w                           #'
   end subroutine

end module