!***********************************************************************
!
!***********************************************************************
#include "errorcodes.h"
#include "version.h"
program CriticalRaEff
   use parameters
   use GrowthRateRaEffMod
   use CritRaEff_io
   implicit none
   type GlobalCrit
      double precision:: alpha
      double precision:: Ra
      double precision:: w
      integer:: m
   end type
   double precision, parameter:: DPI=3.141592653589793D0
   integer, parameter:: NN = 3600
   character*60:: infile,outfile
   integer, parameter:: unitOut=16
   double precision:: alphas(NN)
   type(GlobalCrit):: crit(NN)

!---------------------------------------------------------
!  arg #1 - filename or usage ?
   call getarg(1,infile)
   if (infile.eq.' ') then
      print*, 'Usage : '
      print*, 'CriticalRaEff <in file> <out file>'
      stop
   endif
   if (infile.eq.'-h') then
      print*, 'Usage : '
      print*, 'CriticalRaEff <in file> <out file>'
      stop
   endif

   call getarg(2,outfile)
   print*,  trim(infile),' - ',trim(outfile)

   call init(trim(infile),trim(outfile))
   Print*, 'Out of init()'

   call createAlphas(alphas)
   select case(LCALC)
      case(0)
         ! Single m
         call computeCriticalCurveSingleM(alphas,crit)
         call writeCriticalCurve(crit)
      case(1)
         ! Global
         call computeCriticalCurve(alphas,crit)
         call writeCriticalCurve(crit)
   end select

   close(unitOut)
contains

   !**********************************************************************
   !> Initialises things.
   subroutine init(inputfile,outputfile)
      implicit none
      CHARACTER(len=*) inputfile,outputfile

      ! ----Default values:
      call setDefaults()
      ! ----INPUT:
      call readConfigFileNew(inputfile)

      ! ---- doesn't work for M=0 !!!!!!
      IF(M0.LT.1) THEN
        write(*,*) 'The code does not work for M0<1. ', M0, ' --> 1'
        M0 = 1
      ENDIF

      call GrowthRateInit(Ra, alpha, Pt, Le, tau, eta, m0, Symmetry, Truncation)
      call setVariableParam('Ra ')

      ! ----OUTPUT:
      OPEN(unitOut,FILE=outputfile,STATUS='UNKNOWN')
      call writeOutputHeader(unitOut)
   end subroutine

   !**********************************************************************
   subroutine createAlphas(alphas)
      implicit none
      double precision, intent(out):: alphas(:)
      double precision:: dalpha
      integer:: n, i
      n=size(alphas,1)
      dalpha=2.0d0*dpi/n
      alphas(1)=-dpi

      do i=2, n
         alphas(i) = alphas(i-1) + dalpha
      enddo
   end subroutine

   !**********************************************************************
   !> Computes the lowest critical effective Rayleigh number as a function of alpha
   !! for all other parameters fixed.
   subroutine computeCriticalCurveM(alpha, crit)
      implicit none
      double precision, intent(in):: alpha(:)
      double precision, intent(out):: crit(:,:)
      double precision:: CriticalRa, CriticalRaAlpha0
      double precision:: RaMin, RaMax, gr1,gr2
      double complex:: frequency
      integer:: i, N, HalfN
      integer:: info

      N     = size(alphas,1)
      HalfN = N/2
      Write(*,*) N, HalfN
      info  = 0
      crit(:,1) = huge(1.0d0)
      crit(:,2) = 0.0d0

      RaMin = 0
      RaMax = 10*Ra
      call GrowthRateUpdatePar(alpha=0.0d0)
      ! At this point a critical Ra is certain to exist so,
      ! increase the interval, until we find it.
      do
         gr1 = MaxGrowthRate(RaMin)
         gr2 = MaxGrowthRate(RaMax)
         if (gr1*gr2.gt.0.0d0) then
            RaMin = RaMax
            RaMax = 2*RaMax
         else
            exit
         endif
      enddo
      ! Now that we found an interval find the critical value for Ra.
      call minimizer(MaxGrowthRate, RaMin, RaMax, RELE ,ABSE, NSMAX, CriticalRa, info)
      ! Cache this value for future use.
      CriticalRaAlpha0 = CriticalRa
      ! Compute the positive half of the alphas
      do i=HalfN, N
         call GrowthRateUpdatePar(Ra=CriticalRa, alpha=alpha(i))
         RaMin = 0.05d0*CriticalRa
         RaMax = 100.d0*CriticalRa
         call minimizer(MaxGrowthRate, RaMin, RaMax, RELE ,ABSE, NSMAX, CriticalRa, info)
         if (info.NE.0) exit
         Write(*,*) '  alpha = ', alpha(i), CriticalRa
         crit(i,1) = CriticalRa
         crit(i,2) = dble(MaxGrowthRateCmplx(CriticalRa))
      enddo
      info = 0
      CriticalRa = CriticalRaAlpha0
      ! and the negative half
      do i=HalfN-1, 1, -1
         call GrowthRateUpdatePar(Ra=CriticalRa, alpha=alpha(i))
         RaMin = 0.05d0*CriticalRa
         RaMax = 100.d0*CriticalRa
         call minimizer(MaxGrowthRate, RaMin, RaMax, RELE ,ABSE, NSMAX, CriticalRa, info)
         if (info.NE.0) exit
         Write(*,*) '  alpha = ', alpha(i), CriticalRa
         crit(i,1) = CriticalRa
         crit(i,2) = dble(MaxGrowthRateCmplx(CriticalRa))
      enddo
   end subroutine

   !**********************************************************************
   !>
   subroutine computeCriticalCurve(alpha, crit)
      implicit none
      double precision, intent(in):: alpha(:)
      type(GlobalCrit), intent(out):: crit(:)
      double precision, allocatable:: crit_new(:,:)
      integer:: m, N, i
      integer:: info

      N = size(alpha,1)
      allocate(crit_new(N,2))
      info = 0
      crit_new(:,1) = huge(1.0d0)
      crit_new(:,2) = 0.0d0
      do i=1, N
         crit(i)%alpha = alpha(i)
         crit(i)%m  = Huge(1)
         crit(i)%w  = Huge(1.0d0)
         crit(i)%Ra = Huge(1.0d0)
      enddo

      do m=1, m0
         call GrowthRateUpdatePar(m=m)
         Write(*,*) 'Computing critical value for m =', m
         call computeCriticalCurveM(alpha, crit_new)
         call writeCriticalCurveSingleM(alpha, crit_new, m)
         do i=1,N
            if(crit_new(i,1).lt.crit(i)%Ra) then
               crit(i)%Ra = crit_new(i,1)
               crit(i)%w  = crit_new(i,2)
               crit(i)%m  = m
            endif
         enddo
      enddo
      deallocate(crit_new)
   end subroutine

   !**********************************************************************
   !>
   subroutine computeCriticalCurveSingleM(alpha, crit)
      implicit none
      double precision, intent(in):: alpha(:)
      type(GlobalCrit), intent(out):: crit(:)
      double precision, allocatable:: crit_new(:,:)
      integer:: N, i
      integer:: info

      N     = size(alpha,1)
      allocate(crit_new(N,2))
      info  = 0
      crit_new(:,1) = huge(1.0d0)
      crit_new(:,2) = 0.0d0
      call GrowthRateUpdatePar(m=m0)
      Write(*,*) 'Computing critical value for m =', m0
      call computeCriticalCurveM(alpha, crit_new)
      do i=1,N
         crit(i)%alpha = alpha(i)
         crit(i)%Ra = crit_new(i,1)
         crit(i)%w  = crit_new(i,2)
         crit(i)%m  = m0
      enddo
      deallocate(crit_new)
   end subroutine

   !**********************************************************************
   !>
   subroutine writeCriticalCurve(crit)
      implicit none
      type(GlobalCrit), intent(in):: crit(:)
      integer:: N, i
      N = size(crit,1)
      do i=1, N
         Write(unitOut,*) crit(i)%alpha, crit(i)%Ra, crit(i)%m, crit(i)%w  
      enddo
   end subroutine

   !**********************************************************************
   !>
   subroutine writeCriticalCurveSingleM(alpha, crit, m)
      implicit none
      double precision, intent(in):: alpha(:)
      double precision, intent(in):: crit(:,:)
      integer, intent(in):: m
      character(len=3):: num
      integer:: N, i
      integer, parameter:: unitm=999
      N = size(crit,1)
      Write(num,'(I3.3)') m
      open(unit=unitm,file=trim(outfile)//'.'//trim(num), status='UNKNOWN')
      do i=1, N
         Write(unitm,*) alpha(i), crit(i,1), crit(i,2)
      enddo
      close(unitm)
   end subroutine
end program
! vim: tabstop=3:softtabstop=3:shiftwidth=3:expandtab
