!************************************************************************
!--
!------------------------------------------------------------------------
PROGRAM simplePlot
   use parameters
   use growthRateMod
   use plms_mod
   use io
   use glo_constants
   implicit none
   integer:: nr=31, nt=180, np=361, error
   CHARACTER(len=60):: INFILE
   character(len=2):: domain, quantity

   type:: eigenElement
      integer:: n
      integer:: l
      integer:: m
      character:: fieldCode
      double precision:: realPart
      double precision:: imagPart
   end type
   type(eigenElement), target, allocatable:: eigenVector(:)
!---------------------------------------------------------
!  arg #1 - filename or usage ?
   call getarg(1,infile)
   if (trim(infile).eq.'' .or. trim(infile).eq.'-h') then
      print*, 'Usage : '
      print*, 'glo_plot <in file> <domain> <quantity>'
      print*, '  <domain> can be one of 2D or 3D.'
      print*, '  <quantity> can be one of:'
      print*, '      UR for the radial flow or'
      print*, '      SL for the equatorial stream lines 1/r dv/dphi.'
      stop
   endif
   
   call getarg(2,domain)
   call getarg(3,quantity)
   if (quantity=='') quantity='UR'
   call init(trim(infile))
   call computeModes(error)
   if (error.ne.0) stop 10

   Write(*,*) 'Plotting...'
   select case (domain)
      case('2D')
         CALL Plot_2D()
      case('3D')
         CALL Plot_3D()
      case default
         stop
   end select
   Write(*,*) 'Done!'

contains

   !**********************************************************************
   !> Initialises things.
   SUBROUTINE init(inputfile)
      implicit none
      CHARACTER(len=*), intent(in):: inputfile

      ! ----Default values:
      call setDefaults()
      ! ----INPUT:
      call readConfigFileNew(inputfile)

      ! ---- doesn't work for M=0 !!!!!!
      IF(M0.LT.1) THEN
        write(*,*) 'The code does not work for M0<1. ', M0, ' --> 1'
        M0 = 1
      ENDIF
      if(4*m0.gt.Np) then
         Np = 4*m0+1
         Nt = 2*m0
         Write(*,*) "Warning: This file is going to be huge!"
      endif
      Nr = max(Nr,floor(Nt*acos(eta)/dpi)+1)

      call setVariableParam(VariablePar)
      if (VariablePar=='Ra'.or.VariablePar=='aa') then
         Write(*,*) Ra, alpha, Pt, Le, tau, eta, m0, Symmetry, Truncation
         call GrowthRateInitAlpha(Ra, alpha, Pt, Le, tau, eta, m0, Symmetry, Truncation)
      else
         call GrowthRateInit(Rt, Rc, Pt, Le, tau, eta, m0, Symmetry, Truncation)
      endif
   END subroutine

   !------------------------------------------------------------------------
   function pointValueOfSelectedQuantity(eigenVector, r, PHI, itheta) result(z)
      implicit none
      type(eigenElement), intent(in):: eigenVector(:)
      double precision, intent(in):: r, phi
      integer, intent(in):: itheta
      double precision:: z
      select case(quantity)
         case('ur','UR')
            z = flow_r(eigenVector, r, PHI, itheta)
         case('sl','SL')
            z = stream_function(eigenVector, r, PHI, itheta)
         case default
            z = flow_r(eigenVector, r, PHI, itheta)
      end select
   end function
   
   !------------------------------------------------------------------------
   !     calculates the field Z and makes one subplot.
   SUBROUTINE Plot_2D()
      implicit none
      double precision:: THETA, r, phi
      double precision:: ri,z
      integer:: i, k
      !-- CALCULATION OF INNER AND OUTER RADIUS:
      RI = ETA/(1.D0-ETA)

      write(*,*) 'computing the fields...'
      ! Plot the equator
      theta  = 90.0d0
      
      ! Find the highest l or m that we need to compute
      ! Reuse k for that so we don't have to create a new variable
      k=0
      DO i=1, size(eigenVector,1)
         if (eigenVector(i)%m.gt.k) k = eigenVector(i)%m
         if (eigenVector(i)%l.gt.k) k = eigenVector(i)%l
      enddo

      !-- BESTIMMUNG DER PLM(THETA) , ABSPEICHERUNG:
      
      CALL STOREPLM( (/THETA/), 1, k )

      open(20,file ='glo-render_2D.general',STATUS =  'UNKNOWN')
      Write(20,*) 'grid = ',np+1,'x',nr+1
      Write(20,*) 'format = ascii'
      Write(20,*) 'interleaving = field'
      Write(20,*) 'majority = column'
      Write(20,*) 'field = locations, field0'
      Write(20,*) 'structure = 2-vector, scalar'
      Write(20,*) 'type = float, float'
      Write(20,*) ''
      Write(20,*) 'end'
      do i=0, nr
         r = ri + dble(i)/dble(nr)
         do k=0, np
            phi = k*(360.0/np)
            z = pointValueOfSelectedQuantity(eigenVector, r, PHI, 1)
            Write(20,*) r*cos(phi*dpi/180.0), &
                        r*sin(phi*dpi/180.0), &
                        z
         enddo
      enddo
      close(20)
   end subroutine Plot_2D
   
   !------------------------------------------------------------------------
   !     calculates the field Z and makes one subplot.
   SUBROUTINE Plot_3D()
      implicit none
      double precision:: THETA(Nt), r, phi, dtheta
      double precision:: ri, z
      integer:: i, j, k
      !-- CALCULATION OF INNER AND OUTER RADIUS:
      RI = ETA/(1.D0-ETA)

      write(*,*) 'computing the fields...'
      ! Avoid the poles
      dtheta  = 180.d0/(nt+1)
      DO I = 1, Nt
         THETA(I) = (I-0.5d0)*dtheta
      enddo
      
      ! Find the highest l or m that we need to compute
      ! Reuse k for that so we don't have to create a new variable
      k=0
      DO i=1, size(eigenVector)
         if (eigenVector(i)%m.gt.k) k = eigenVector(i)%m
         if (eigenVector(i)%l.gt.k) k = eigenVector(i)%l
      enddo

      !-- BESTIMMUNG DER PLM(THETA) , ABSPEICHERUNG:
      
      CALL STOREPLM( THETA, Nt, k )

      open(20,file ='glo-render_3D.general',STATUS =  'UNKNOWN')
      Write(20,*) 'grid = ',nt,'x',np+1,'x',nr+1
      Write(20,*) 'format = ascii'
      Write(20,*) 'interleaving = field'
      Write(20,*) 'majority = column'
      Write(20,*) 'field = locations, field0'
      Write(20,*) 'structure = 3-vector, scalar'
      Write(20,*) 'type = float, float'
      Write(20,*) ''
      Write(20,*) 'end'
      do i=0, nr
         r = ri + dble(i)/dble(nr)
         do k=0, np
            phi = k*(360.0/np)
            do j=1, nt
               z = pointValueOfSelectedQuantity(eigenVector, r, PHI, j)
               Write(20,*) r*sin((theta(j))*dpi/180.0)*cos(phi*dpi/180.0), &
                           r*sin((theta(j))*dpi/180.0)*sin(phi*dpi/180.0), &
                           r*cos((theta(j))*dpi/180.0), &
                           z
            enddo
         enddo
      enddo
      close(20)
   end subroutine Plot_3D

   !------------------------------------------------------------------------
   !> Radial flow: U_r = L_2/r v
   double precision function flow_r(eigenVector,R,PHI,iTHETA)
      IMPLICIT none
      type(eigenElement)::eigenVector(:)
      double precision, intent(in):: R, phi
      double precision:: ri, epsm, pphi
      double precision:: RFT, RFTR, RFTI
      integer, intent(in):: iTheta
      integer:: i
      integer:: l, m, n

      PPHI = PHI*dpi/180.D0
      !-- CALCULATION OF INNER AND OUTER RADIUS:
      RI = ETA/(1.D0-ETA)

      flow_r = 0.0d0
      do i=1, size(eigenVector)
         if (eigenVector(i)%fieldCode.ne.'V') cycle
         ! Prefactor for Legendre Associated Polynomials
         if( eigenVector(i)%M.eq.0 ) then
            EPSM = 1.D0
         else
            EPSM = 2.D0
         endif

         l = eigenVector(i)%l
         m = eigenVector(i)%m
         n = eigenVector(i)%n
         RFT = EPSM*l*(l+1)*PLMS(L,M,iTheta)*DSIN( N*dpi*(R-RI) ) / R

         RFTR =  RFT * eigenVector(I)%realPart * DCOS( M*PPHI )
         RFTI = -RFT * eigenVector(I)%ImagPart * DSIN( M*PPHI )

         flow_r = flow_r + RFTR+RFTI
      enddo
   end function

   !------------------------------------------------------------------------
   !> The stream function on the equatorial plane S=r*dv/dphi
   double precision function stream_function(eigenVector,R,PHI,iTHETA)
      IMPLICIT none
      type(eigenElement)::eigenVector(:)
      double precision, intent(in):: R, phi
      double precision:: ri, epsm, pphi
      double precision:: FTT, FTTR, FTTI
      integer, intent(in):: iTheta
      integer:: i
      integer:: l, m, n

      PPHI = PHI*dpi/180.D0
      !-- CALCULATION OF INNER AND OUTER RADIUS:
      RI = ETA/(1.D0-ETA)

      stream_function=0.D0
      do i=1, size(eigenVector)
         if (eigenVector(i)%fieldCode.ne.'V') cycle
         ! Prefactor for Legendre Associated Polynomials
         if( eigenVector(i)%M.EQ.0 ) then
            EPSM = 1.D0
         else
            EPSM = 2.D0
         endif

         l = eigenVector(i)%l
         m = eigenVector(i)%m
         n = eigenVector(i)%n
         FTT = EPSM*M*PLMS(L,M,iTHETA)*R*DSIN( N*dpi*(R-RI) )

         FTTR = -FTT * eigenVector(I)%realPart * DSIN( M*PPHI )
         FTTI = -FTT * eigenVector(I)%imagPart * DCOS( M*PPHI )

         stream_function = stream_function - FTTR - FTTI
      enddo
   end function

   !------------------------------------------------------------------------
   !>
   SUBROUTINE computeModes(error)
      IMPLICIT none
      integer, intent(out):: error
      integer:: nElements
      complex(8), allocatable:: ZEVEC(:), zew(:), ZEVAL(:,:)
      integer:: i, ni, li, lti, lpi, ld, ii
      integer:: LMAX, NIMAX, LMIN, eqdim


      call setLminAndLD(Symmetry, m0, LMIN, LD) 
      call setEigenProblemSize(LMIN,LD,truncation,M0)
      nElements = getEigenProblemSize()
      allocate( ZEVEC(NElements), zew(NElements), ZEVAL(NElements,NElements))
      allocate (eigenVector(nElements))
      call findCriticalPar(error)
      if (error.ne.0) return
      ! Recoompute critical state modes and eigenvectors
      call computeGrowthRateModes(sort=.TRUE., zew=zew, zeval=zeval)
      ! Most unstable mode will be the first
      zevec(:) = zeval(:,1)

      eqdim=nElements/4

      LMAX=2*Truncation+M0-1
      ! poloidal flow:
      I=1
      do LI=LMIN,LMAX,LD
         LPI = LI
         NIMAX=INT( DBLE(2*Truncation+1-LI+M0)/2 )
         do NI=1,NIMAX
            eigenVector(i)%fieldCode = 'V'
            eigenVector(i)%l         = LPI
            eigenVector(i)%m         = M0
            eigenVector(i)%n         = NI
            eigenVector(i)%RealPart  = DREAL(ZEVEC(I+0*eqdim))
            eigenVector(i)%ImagPart  = DIMAG(ZEVEC(I+0*eqdim))
            I=I+1
         enddo
      enddo

      i=1
      ii=eqdim+1
      DO LI=LMIN,LMAX,LD
         IF( Symmetry.EQ.2 ) THEN
         LTI=LI+1
         ELSEIF( Symmetry.EQ.1 ) THEN
         LTI=LI-1
         ELSEIF( Symmetry.EQ.0 ) THEN
         LTI=LI
         ENDIF
         NIMAX=INT( DBLE(2*Truncation+1-LI+M0)/2 )
         DO NI=1,NIMAX
            eigenVector(ii)%fieldCode = 'W'
            eigenVector(ii)%l         = LTI
            eigenVector(ii)%m         = M0
            eigenVector(ii)%n         = NI
            eigenVector(ii)%RealPart  = DREAL(ZEVEC(I+1*eqdim))
            eigenVector(ii)%ImagPart  = DIMAG(ZEVEC(I+1*eqdim))
            I=I+1
            Ii=Ii+1
         enddo
      enddo

      ! temperature
      i=1
      ii=2*eqdim+1
      DO LI=LMIN,LMAX,LD
         NIMAX=INT( DBLE(2*Truncation+1-LI+M0)/2 )
         DO NI=1,NIMAX
            eigenVector(ii)%fieldCode = 'T'
            eigenVector(ii)%l         = LI
            eigenVector(ii)%m         = M0
            eigenVector(ii)%n         = NI
            eigenVector(ii)%RealPart  = DREAL(ZEVEC(I+2*eqdim))
            eigenVector(ii)%ImagPart  = DIMAG(ZEVEC(I+2*eqdim))
            I=I+1
            Ii=Ii+1
         enddo
      enddo

      ! composition
      i=1
      ii=3*eqdim+1
      DO LI=LMIN,LMAX,LD
         NIMAX=INT( DBLE(2*Truncation+1-LI+M0)/2 )
         DO NI=1,NIMAX
            eigenVector(ii)%fieldCode = 'G'
            eigenVector(ii)%l         = LI
            eigenVector(ii)%m         = M0
            eigenVector(ii)%n         = NI
            eigenVector(ii)%RealPart  = DREAL(ZEVEC(I+3*eqdim))
            eigenVector(ii)%ImagPart  = DIMAG(ZEVEC(I+3*eqdim))
            I=I+1
            Ii=iI+1
         enddo
      enddo
      
   END SUBROUTINE computeModes

   !**********************************************************************
   !> For the specified parameter, finds the global critical value
   !! for all other parameters fixed. At the end, m0 is teh critical m
   !! and the critical value of VariablePar is updated in the growth rate 
   !! module.
   subroutine findCriticalPar(error)
      implicit none
      integer, intent(out):: error
      double precision:: ParMin, ParMax
      double precision:: CriticalPar, origParVal
      integer:: i

      call saveParameterValue(origParVal)
      ! Increase the interval, in case we did not find anything.
      do i=0, 10
         error = 0
         ParMin = origParVal - 2.0d0**(i-2)*dabs(origParVal)
         ParMax = origParVal + 2.0d0**(i-2)*dabs(origParVal)
         Print*, origParVal, ParMin, ParMax
         if (ParMin.gt.0.0d0) ParMin = 0.0d0
         if (ParMax.lt.0.0d0) ParMax = 0.0d0
         if (i.gt.9) then
            Write(*,*) i,': Damn! 9 iterations and I could find nothing?'
            ParMin = -1.0d20
            ParMax = 1.0d20
         endif

         call minimizer(MaxGrowthRate, ParMin, ParMax, RELE ,ABSE, NSMAX, CriticalPar, error)
         if (error.eq.0) exit
      enddo
      call setParameterValue(CriticalPar) 
      Write(*,*) 'Critical ',trim(VariablePar)//'_c = ', CriticalPar
   end subroutine

end PROGRAM simplePlot
! vim: tabstop=3:softtabstop=3:shiftwidth=3:expandtab
