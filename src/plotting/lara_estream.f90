!************************************************************************
!-- PROGRAM TO read data from Galerkinprogram of J.W. and convert it for IDL.
!--
!-- Input:   stdin  (short version of LARA.EXE for DISSPLA)
!--
!-- Output:
!--          3 files: idl.z, idl.x, idl.y
!--
!------------------------------------------------------------------------
PROGRAM LARA
      IMPLICIT REAL*8(A-H,O-W)
      IMPLICIT REAL*8(X,Y,Z)
      PARAMETER (NM = 5500,NAM = 400,nPlotsMAX = 9,NPSM = 4,NPAM = nPlotsMAX*NPSM)
      PARAMETER (NLMA = 100)
      PARAMETER (PI = 3.14159265358979D0)
      CHARACTER*40 INPUTFILE,OUTPUTFILE
      CHARACTER*30 CTEXT1
      CHARACTER*10 CTEXT2
      CHARACTER*1 CF,CFS,constantCoordinate,CCP
      CHARACTER*2 CRR,whatToPlot,CFP,domain,quadrant,CPP
      CHARACTER*3 ABCNUM,ABCNUMI,ABCN
! 
      DIMENSION DX(NM)
      DIMENSION domain(nPlotsMAX),nSubPlots(nPlotsMAX)
      DIMENSION quadrant(nPlotsMAX,NPSM),constantCoordinate(nPlotsMAX,NPSM),XC(nPlotsMAX,NPSM)
      DIMENSION whatToPlot(nPlotsMAX,NPSM),XRMU(nPlotsMAX,NPSM)
      DIMENSION TIME(nPlotsMAX),ZD(nPlotsMAX,NPSM),ABCNUMI(nPlotsMAX,NPSM)
      DIMENSION CPP(NPAM),CFP(NPAM),XCP(NPAM),CCP(NPAM)
      DIMENSION ZDP(NPAM),TIMEP(NPAM)
      DIMENSION XOR(NPAM),YOR(NPAM),XAR(NPAM),YAR(NPAM),ABCN(NPAM)
      DIMENSION XROCM(NPAM),XRICM(NPAM),XRMCM(NPAM),XRM(NPAM)
! 
      COMMON/LOG/LCALC,LWRITE,LTR,LVAR,LDY,LT,L7,L8,L9,L10
      COMMON/DIM/NDV,NDW,NDT,NDH,NDG,ND
      COMMON/QNU/NMC,L(NM),M(NM),N(NM),K(NM),CF(NM),CRR(NM)
      COMMON/QNUS/NMSC,LS(NM),MS(NM),NS(NM),CFS(NM)
      COMMON/PAR/RA,TA,PR,PM,ETA,C,OM,FTW,FTG,MF
      COMMON/PARI/RAI,TAI,PRI,PMI,ETAI,CI,OMI,FTWI,FTGI,MFI
      COMMON/NPAR/M0,NTV,NTH,LTV,LTH,KTV,KTH,LEV,LRB,LD
      COMMON/NPARI/M0I,NTVI,NTHI,LTVI,LTHI,KTVI,KTHI,LEVI,LRBI,LDI
      COMMON/LNMAX/NLMAC,NL,LC(NLMA),NMAXC(NLMA),NMABC
      COMMON/AB/A(NAM),B(NAM),NAMC
      COMMON/NUM/RELE,EPS,ALPH,STOER,NITMAX,NJA
      COMMON/POLE/XP,YP
      COMMON/PLOTC/ZDO,NCPLOT
      COMMON/THETAC/THETA
! 
      NCPLOT = 0
      ZDO = 0.E0
! 
!-- INPUT:
      LR = 0
      NQ = 0
      NR = 0
!      OPEN(11,FILE = PARFILE,STATUS = 'old')
      READ(*,*)
      READ(*,*) INPUTFILE,OUTPUTFILE,NUDS,DC
      READ(*,*)
      READ(*,*) timeSeriesControl,LHEAD,drawPlotNum,drawTime,plotSize,contourDistanceOrNumber,drawFrame
! 
      !-- LHEAD CONTROLLS THE HEAD:
      !   LHEAD = 0 : NHEAD,
      !   LHEAD = 1 : NHEAD WRITTEN,
      !   drawPlotNum = 0 : NO PLOTNUMBERS
      !   drawPlotNum = 1 : PLOTNUMBERS WITH DESCRIPTION,
      !   drawPlotNum = 2 : PLOTNUMBERS WITHOUT DESCRIPTION,
      !   drawPlotNum = 3 : PLOTNUMBERS GIVEN BY ABCNUMI,
      !   drawTime CONTROLLS WETHER THE TIME IS WRITTEN (0/1).
      !   plotSize DETERMINS THE SIZE OF THE PLOT:
      !   plotSize = 0 : SMALL
      !   plotSize = 1 : MEDIUM
      !   plotSize = 2 : BIG
      !   contourDistanceOrNumber CONTROLLS WETHER ZD IS THE NUMBER OF CONTOURLINES (contourDistanceOrNumber = 1) OR
      !   THE DIFFERENCE BETWEEN THE CONTOUR LEVELS (contourDistanceOrNumber = 0).
      !   FOR drawFrame = 1 A FRAME IS DRAWN AROUND EACH SUBPLOT.
      !   timeSeriesControl CONTROLLS TIMESERIES
      !   timeSeriesControl = 0  : NORMAL
      !   timeSeriesControl = -1 : TIMESERIES OF 6 PLOTS WITH TIME GIVEN INDIVIDUALLY, 
      !   timeSeriesControl = 1  : TIMESERIES OF 6 PLOTS WITH TIME GIVEN BY OM,
      !   timeSeriesControl = -2 : TIMESERIES OF 8 PLOTS WITH TIME GIVEN INDIVIDUALLY,
      !   timeSeriesControl = 2  : TIMESERIES OF 8 PLOTS WITH TIME GIVEN BY OM.
      IF( drawPlotNum.LT.0 .OR. drawPlotNum.GT.3 ) THEN
         WRITE(*,*) 'WRONG INPUT OF drawPlotNum: ',drawPlotNum
         STOP
      ENDIF
      IF( plotSize.LT.0 .OR. plotSize.GT.2 ) THEN
         WRITE(*,*) 'WRONG INPUT OF plotSize: ',plotSize
         STOP
      ENDIF
      IF( LHEAD.NE.0 .AND. LHEAD.NE.1 ) THEN
         WRITE(*,*) 'WRONG INPUT OF LHEAD: ',LHEAD
         STOP
      ENDIF
      IF( contourDistanceOrNumber.NE.0 .AND. contourDistanceOrNumber.NE.1 ) THEN
         WRITE(*,*) 'WRONG INPUT OF contourDistanceOrNumber: ',contourDistanceOrNumber
         STOP
      ENDIF
      IF( drawFrame.NE.0 .AND. drawFrame.NE.1 ) THEN
         WRITE(*,*) 'WRONG INPUT OF drawFrame: ',drawFrame
         STOP
      ENDIF
      IF( timeSeriesControl.LT.-2 .OR. timeSeriesControl.GT.2 ) THEN
         WRITE(*,*) 'WRONG INPUT OF timeSeriesControl: ',timeSeriesControl
         STOP
      ENDIF
! 
      OPEN(14,FILE = OUTPUTFILE,STATUS = 'unknown')
      write(14,*) 'Inputfile,NUDS ',INPUTFILE,NUDS
! 
      RELE = 1.D-9
      EPS = 1.D-13
! 
!-- nPlots IS NUMBER OF PLOTS, XP AND YP ARE LATITUDE AND LONGITUDE OF
!   THE POLE FOR PROJECTION OF A SPHERE ON A CIRCLE ( quadrant = 'PL','PR','PS' ) .
      READ(*,*)
      READ(*,*) nPlots,XP,YP

      if(nPlots.ne.1.) then
          write(*,*) 'wrong number of plots.'
          stop
      endif
! 
      IF( timeSeriesControl.GT.0 ) THEN
         plotSize = 0
         nPlots = 1
      ENDIF
      IF( ( plotSize.EQ.0 .AND. nPlots.GT.nPlotsMAX ) .OR. &
          ( plotSize.EQ.1 .AND. nPlots.GT.4 )   .OR. &
          ( plotSize.EQ.2 .AND. nPlots.GT.2 ) ) THEN
         WRITE(*,*) 'TOO BIG NUMBER OF PLOTS nPlots: ',nPlots
         STOP
      ENDIF
        
! 
! 
      DO I = 1,nPlots
         !----- nSubPlots IS NUMBER OF SUBPLOTS, domain DESTINGUISHES BETWEEN 
         !      QUADRANT (domain = 'QU'), HALFSPHERE (domain = 'HS') AND FULL SPHERE (domain = 'SP').
         !      TIME IS THE TIME OF THE PLOTTED FIELD FOR TIME DEPENDENCE.
         READ(*,*)
         READ(*,*) domain(I),TIME(I),nSubPlots(I)
         if(nSubPlots(I).ne.1) then
              write(*,*) 'wrong number of plots.'
              stop
          endif
! 
         IF( nSubPlots(I).GT.NPSM ) THEN
            WRITE(*,*) 'TOO BIG NUMBER OF SUBPLOTS nSubPlots:',nSubPlots(I)
            STOP
         ENDIF
         IF( domain(I).EQ.'HS' ) THEN
            NR = NR+1
         ELSE
            NQ = NQ+1
         ENDIF
! 
         !----- quadrant DESTINGUSHES BETWEEN QUADRANTS (quadrant = 'Q1','Q2','Q3','Q4') ,
         !      HALF SPHERES ( quadrant = 'HL','HR','HU','HO') ,SPHERE ( quadrant = 'SP' ) 
         !      PROJECTION ON A SPHERE ( quadrant = ' PS','PL','PR' ) .
         !      constantCoordinate DETERMINS WETHER R = XC (constantCoordinate = 'R') , PHI = XC (constantCoordinate = 'P') OR 
         !      THETA = XC (constantCoordinate = 'T') IS KEPT CONSTANT ,
         !      whatToPlot DETERMINS THE FIELD TO BE PLOTTED:
         !      'VS' : STREAMFUNCTIONS OF VELOCITY FIELD IN BUSSE NOTATION,
         !      'BS' : STREAMFUNCTIONS OF MAGNETIC FIELD IN BUSSE NOTATION,
         !      'JS' : STREAMFUNCTIONS OF ELECTRIC CURRENT IN BUSSE NOTATION,
         !      'VR' : RADIAL VELOCITY FIELD,
         !      'BR' : RADIAL MAGNETIC FIELD,
         !      'TE' : TEMPERATURE FIELD Theta,
         !      'ZF' : ZONAL FLOW ( Mean part of phi comp. of velocity),
         !      'MF' : MERIDIONAL FLOW ( MEAN STREAM FUNCTION IN PHI = CONST. PLANE ),
         !      'MT' : MEAN TOROIDAL MAGNETIC FIELD FOR PHI = CONST,
         !      'BT' : TOROIDAL MAGNETIC FIELD FOR PHI = CONST,
         !      'MP' : STREAMLINES OF MEAN POLOIDAL MAGNETIC FIELD FOR PHI = CONST,
         !      'MJ' : STREAMLINES OF MEAN ELECTRIC CURRENT FOR PHI = CONST,
         !      'MC' : CONTOUR LINES OF MEAN PHI COMPONENT OF ELECTRIC CURRENT FOR PHI = CONST,
         !      'TT' : Temperature field Theta+Ts,
         !      'UP' : Phi component of velocity,
         !      'NU' : local Nusselt number for r = ri.
         ! 
         !      XRMU IS A MULTIPLIER FOR THE LARGEST RADIUS TO BE PLOTTED: RM = XRMU*RO.
         !      ZD IS THE STEP FOR THE CONTOURS FOR contourDistanceOrNumber = 0 OR
         !      THE NUMBER OF CONTPUR LINES FOR Z>0 OR Z<0.
         DO J = 1,nSubPlots(I)
            READ(*,*)
            READ(*,*) quadrant(I,J),constantCoordinate(I,J),XC(I,J),whatToPlot(I,J), XRMU(I,J),ZD(I,J),ABCNUMI(I,J)
         enddo
      enddo
! 
! 
!-- END OF PARAMETER INPUT.
! 
! 
!-- INPUT CHECK:
! 
   DO I = 1,nPlots
      DO J = 1,nSubPlots(I)
         IF( domain(I).NE.'QU' .AND. domain(I).NE.'HS' .AND.  domain(I).NE.'SP' ) THEN
                  WRITE(*,*) 'WRONG INPUT OF domain.'
                  WRITE(*,*) 'CHOOSE BETWEEN QUADRANT : domain = QU ,'
                  WRITE(*,*) '            HALF SPHERE : domain = HS ,'
                  WRITE(*,*) '                 SPHERE : domain = SP .'
            WRITE(*,'('' PLOT '',I3,'' , SUBPLOT '',I3)') I,J
            STOP
         ENDIF
         IF( quadrant(I,J).NE.'Q1' .AND. quadrant(I,J).NE.'Q2' .AND. &
             quadrant(I,J).NE.'Q3' .AND. quadrant(I,J).NE.'Q4' .AND. &
             quadrant(I,J).NE.'HU' .AND. quadrant(I,J).NE.'HO' .AND. &
             quadrant(I,J).NE.'HL' .AND. quadrant(I,J).NE.'HR' .AND. &
             quadrant(I,J).NE.'PL' .AND. quadrant(I,J).NE.'PR' .AND. &
             quadrant(I,J).NE.'SP' .AND. quadrant(I,J).NE.'PS' ) THEN
            WRITE(*,*) 'WRONG INPUT OF quadrant.'
            WRITE(*,*) '  CHOOSE BETWEEN QUADRANTS : quadrant = Q1,Q2,Q3,Q4 ,'
            WRITE(*,*) '              HALF SPHERES : quadrant = HL,HR,HO,HU ,'
            WRITE(*,*) '               FULL SPHERE : quadrant = SP ,'
            WRITE(*,*) '   PROJECTION OF LEFT HALF : quadrant = PL ,'
            WRITE(*,*) '  PROJECTION OF RIGHT HALF : quadrant = PL ,'
            WRITE(*,*) ' PROJECTION OF FULL SPHERE : quadrant = PL .'
            WRITE(*,'('' PLOT '',I3,'' , SUBPLOT '',I3)') I,J
            STOP
         ENDIF
         IF( constantCoordinate(I,J).NE.'P' .AND. constantCoordinate(I,J).NE.'T' .AND. constantCoordinate(I,J).NE.'R' ) THEN
            WRITE(*,*) 'WRONG INPUT OF CONSTANT COORDINATE constantCoordinate.'
            WRITE(*,*) '          CHOOSE BETWEEN PHI : constantCoordinate = P ,'
            WRITE(*,*) '                       THETA : constantCoordinate = T ,'
            WRITE(*,*) '                           R : constantCoordinate = R ,'
            WRITE(*,*) ' RADIAL FIELD FOR CONSTANT R : constantCoordinate = R .'
            WRITE(*,'('' PLOT '',I3,'' , SUBPLOT '',I3)') I,J
            STOP
         ENDIF
         IF( constantCoordinate(I,J).EQ.'R' ) XRMU(I,J) = 1.E0
! 
         IF( constantCoordinate(I,J).EQ.'P' .AND. XC(I,J).GT.360.E0 ) THEN
            WRITE(*,*) 'PHI SHOULD BE GIVEN IN DEGREES < =  360.'
            WRITE(*,'('' PLOT '',I3,'' , SUBPLOT '',I3)') I,J
            STOP
         ELSEIF( constantCoordinate(I,J).EQ.'T' .AND. XC(I,J).GT.180.E0 ) THEN
            WRITE(*,*) 'THETA SHOULD BE GIVEN IN DEGREES < =  180.'
            WRITE(*,'('' PLOT '',I3,'' , SUBPLOT '',I3)') I,J
            STOP
         ELSEIF(  constantCoordinate(I,J).EQ.'R' .AND. ( XC(I,J).LT.0.E0 .OR. XC(I,J).GT.1.E0 )  )THEN
            WRITE(*,*) 'RREL SHOULD BE > = 0 , < =  1 .'
            WRITE(*,*) 'RREL IS DEFINED AS: R = RI+RREL*(RO-RI).'
            WRITE(*,'('' PLOT '',I3,'' , SUBPLOT '',I3)') I,J
            STOP
         ENDIF
         IF(  constantCoordinate(I,J).EQ.'P' ) THEN
            IF( XC(I,J).LT.0.E0 ) XC(I,J) = XC(I,J)+360.E0
            IF(( quadrant(I,J).EQ.'Q1' .OR. &
                 quadrant(I,J).EQ.'Q4' .OR. &
                 quadrant(I,J).EQ.'HR' ) .AND. &
                 XC(I,J).GT.180.E0 .AND. &
                 XC(I,J).LT.360.E0 ) THEN
               XC(I,J) = XC(I,J) - 180.E0
            ELSEIF(( quadrant(I,J).EQ.'Q2' .OR. & 
                     quadrant(I,J).EQ.'Q3' .OR. &
                     quadrant(I,J).EQ.'HL' ) .AND. &
                     XC(I,J).LT.180.E0 .AND. &
                     XC(I,J).GT.0.E0 ) THEN
               XC(I,J) = XC(I,J) + 180.E0
            ENDIF
         ENDIF
         IF( constantCoordinate(I,J).NE.'P' .AND. whatToPlot(I,J).EQ.'MT' ) THEN
            WRITE(*,*) 'FOR MT PHI HAS TO BE KEPT CONSTANT.'
            constantCoordinate(I,J) = 'P'
         ENDIF
         IF( constantCoordinate(I,J).NE.'P' .AND. ( whatToPlot(I,J).EQ.'MP' .OR. whatToPlot(I,J).EQ.'BT' ) ) THEN
            WRITE(*,*) 'FOR MP AND BT PHI HAS TO BE KEPT CONSTANT.'
            constantCoordinate(I,J) = 'P'
         ENDIF
         IF( constantCoordinate(I,J).NE.'P' .AND. whatToPlot(I,J).EQ.'MJ' ) THEN
            WRITE(*,*) 'FOR  MJ PHI HAS TO BE KEPT CONSTANT.'
            constantCoordinate(I,J) = 'P'
         ENDIF
         IF( constantCoordinate(I,J).NE.'P' .AND. whatToPlot(I,J).EQ.'MC' ) THEN
            WRITE(*,*) 'FOR  MC PHI HAS TO BE KEPT CONSTANT.'
            constantCoordinate(I,J) = 'P'
         ENDIF
         IF( constantCoordinate(I,J).NE.'P' .AND. whatToPlot(I,J).EQ.'ZF' ) THEN
            WRITE(*,*) 'FOR ZONAL FLOW PHI HAS TO BE KEPT CONSTANT.'
            constantCoordinate(I,J) = 'P'
         ENDIF
         IF( constantCoordinate(I,J).NE.'P' .AND. whatToPlot(I,J).EQ.'MF' ) THEN
            WRITE(*,*) 'FOR MERIDIONAL FLOW PHI HAS TO BE KEPT CONSTANT.'
            constantCoordinate(I,J) = 'P'
         ENDIF
         IF( constantCoordinate(I,J).NE.'R' .AND. whatToPlot(I,J).EQ.'NU' ) THEN
            WRITE(*,*) 'FOR NUSSELT NUMBER R HAS TO BE KEPT CONSTANT.'
            constantCoordinate(I,J) = 'R'
         ENDIF
         if( constantCoordinate(I,J).EQ.'R' .and. quadrant(I,J)(:1).NE.'P' ) then
            write(*,*) 'For R = const the subplot must be a projection.'
            stop
         endif
         IF( domain(I).EQ.'QU' ) THEN
            IF( nSubPlots(I).GT.1 ) THEN
               WRITE(*,*) 'ONLY ONE SUBPLOT ALLOWED FOR domain = QU.'
               WRITE(*,*) 'nSubPlots ASSUMED TO BE 1.'
               nSubPlots(I) = 1
            ENDIF
            IF( constantCoordinate(I,J).NE.'P' .AND. constantCoordinate(I,J).NE.'T' ) THEN
               WRITE(*,*) 'FOR domain = QU ONLY constantCoordinate = P OR constantCoordinate = T VALID.'
               WRITE(*,'('' PLOT '',I3,'' , SUBPLOT '',I3)') I,J
               STOP
            ENDIF
            IF( quadrant(I,J).NE.'Q1' .AND. quadrant(I,J).NE.'Q2' .AND. 
     &          quadrant(I,J).NE.'Q3' .AND. quadrant(I,J).NE.'Q4' ) THEN
               WRITE(*,*) 'FOR domain = QU ONLY quadrant = Q1,Q2,Q3,Q4 VALID.'
               WRITE(*,'('' PLOT '',I3,'' , SUBPLOT '',I3)') I,J
               STOP
            ENDIF
         ELSEIF( domain(I).EQ.'HS' ) THEN
            IF( nSubPlots(I).GT.2 ) THEN
               WRITE(*,*) 'ONLY TWO SUBPLOT MAXIMUM ALLOWED FOR domain = HS.'
               WRITE(*,*) 'nSubPlots ASSUMED TO BE 2.'
               nSubPlots(I) = 2
            ENDIF
            IF( constantCoordinate(I,J).NE.'P' .AND. constantCoordinate(I,J).NE.'T' ) THEN
               WRITE(*,*) 'FOR domain = HS ONLY constantCoordinate = P OR constantCoordinate = T VALID.'
               WRITE(*,'('' PLOT '',I3,'' , SUBPLOT '',I3)') I,J
               STOP
            ENDIF
            IF( quadrant(I,J).NE.'Q1' .AND. quadrant(I,J).NE.'Q2' .AND. 
     &          quadrant(I,J).NE.'Q3' .AND. quadrant(I,J).NE.'Q4' .AND.
     &          quadrant(I,J).NE.'HO' .AND. quadrant(I,J).NE.'HU' ) THEN
               WRITE(*,*) 'FOR domain = HS ONLY quadrant = Q1,Q2,Q3,Q4,HO,HU VALID.'
               WRITE(*,'('' PLOT '',I3,'' , SUBPLOT '',I3)') I,J
               STOP
            ENDIF
            IF( quadrant(I,J).EQ.'HO' .AND. constantCoordinate(I,J).EQ.'P' ) THEN
               quadrant(I,J) = 'Q1'
               IF( XC(I,J).GT.180.E0 ) THEN
                  XC(I,J) = XC(I,J)-180.E0
               ENDIF
               nSubPlots(I) = nSubPlots(I)+1
               quadrant(I,nSubPlots(I)) = 'Q2'
               constantCoordinate(I,nSubPlots(I)) = constantCoordinate(I,J)
               IF( XC(I,J).LT.180.E0 ) THEN
                  XC(I,nSubPlots(I)) = XC(I,nSubPlots(I))+180.E0
               ENDIF
               whatToPlot(I,nSubPlots(I)) = whatToPlot(I,J)
               XRMU(I,nSubPlots(I)) = XRMU(I,J)
               ZD(I,nSubPlots(I)) = ZD(I,J)
            ELSEIF( quadrant(I,J).EQ.'HU' .AND. constantCoordinate(I,J).EQ.'P' ) THEN
               quadrant(I,J) = 'Q4'
                     IF( XC(I,J).GT.180.E0 ) THEN
                  XC(I,J) = XC(I,J)-180.E0
               ENDIF
               nSubPlots(I) = nSubPlots(I)+1
               quadrant(I,nSubPlots(I)) = 'Q3'
               constantCoordinate(I,nSubPlots(I)) = constantCoordinate(I,J)
                     IF( XC(I,J).LT.180.E0 ) THEN
                  XC(I,nSubPlots(I)) = XC(I,nSubPlots(I))+180.E0
               ENDIF
               whatToPlot(I,nSubPlots(I)) = whatToPlot(I,J)
               XRMU(I,nSubPlots(I)) = XRMU(I,J)
               ZD(I,nSubPlots(I)) = ZD(I,J)
            ENDIF
         ELSEIF( domain(I).EQ.'SP' ) THEN
            IF( nSubPlots(I).GT.4 ) THEN
             WRITE(*,*) 'ONLY FOUR SUBPLOT MAXIMUM ALLOWED FOR domain = SP.'
               WRITE(*,*) 'nSubPlots ASSUMED TO BE 4.'
               nSubPlots(I) = 4
            ENDIF 
            IF( quadrant(I,J).EQ.'HO' .AND. constantCoordinate(I,J).EQ.'P' ) THEN
               quadrant(I,J) = 'Q1'
                     IF( constantCoordinate(I,J).EQ.'P' .AND. XC(I,J).GT.180.E0 ) THEN
                  XC(I,J) = XC(I,J)-180.E0
               ENDIF
               nSubPlots(I) = nSubPlots(I)+1
               quadrant(I,nSubPlots(I)) = 'Q2'
               constantCoordinate(I,nSubPlots(I)) = constantCoordinate(I,J)
                     IF( constantCoordinate(I,J).EQ.'P' .AND. XC(I,J).LT.180.E0 ) THEN
                  XC(I,nSubPlots(I)) = XC(I,J)+180.E0
               ENDIF
               whatToPlot(I,nSubPlots(I)) = whatToPlot(I,J)
               XRMU(I,nSubPlots(I)) = XRMU(I,J)
               ZD(I,nSubPlots(I)) = ZD(I,J)
            ELSEIF( quadrant(I,J).EQ.'HU' .AND. constantCoordinate(I,J).EQ.'P' ) THEN
               quadrant(I,J) = 'Q4'
                     IF( constantCoordinate(I,J).EQ.'P' .AND. XC(I,J).GT.180.E0 ) THEN
                  XC(I,J) = XC(I,J)-180.E0
               ENDIF
               nSubPlots(I) = nSubPlots(I)+1
               quadrant(I,nSubPlots(I)) = 'Q3'
               constantCoordinate(I,nSubPlots(I)) = constantCoordinate(I,J)
                     IF( constantCoordinate(I,J).EQ.'P' .AND. XC(I,J).LT.180.E0 ) THEN
                  XC(I,nSubPlots(I)) = XC(I,J)+180.E0
               ENDIF
               whatToPlot(I,nSubPlots(I)) = whatToPlot(I,J)
               XRMU(I,nSubPlots(I)) = XRMU(I,J)
               ZD(I,nSubPlots(I)) = ZD(I,J)
            ENDIF
         ENDIF
      enddo
   enddo
! 
! 
!-- SETTING OF CONSTANTS:
      LTR = 1
      NMC = NM
      NMSC = NM
      NAMC = NAM
      NLMAC = NLMA
! 
      IF( timeSeriesControl.GT.0 ) TIME(1) = 0.D0
! 
!-- READLA READS THE SET OF COEFFITIENTS TO BE PLOTTED ,
!   IT IS NECESSARY TO CALL IS HERE TO GET PARAMETERS.
      TIMEO = TIME(1)
      write(*,'(A,A,I3,D9.2)') 'reading data from ',INPUTFILE,NUDS,TIME(1),'...'
      CALL READLA(INPUTFILE,NUDS,TIME(1),DX)
      write(*,*) '...done'
      RA = RAI
      TA = TAI
      PR = PRI
      PM = PMI
      ETA = ETAI
      C = CI
      OM = OMI
      FTW = FTWI
      FTG = FTGI
      MF = 0
      M0 = M0I
      NTV = NTVI
      NTH = NTHI
      LTV = LTVI
      LTH = LTHI
      KTV = KTVI
      KTH = KTHI
      LD = LDI
      LEV = LEVI
      LRB = LRBI
! 
      IF( timeSeriesControl.GT.0 ) THEN
         NSUBP = nSubPlots(1)
         IF( LCALC.NE.3 .AND. LCALC.NE.4 ) THEN
            WRITE(*,*) 'TIMESERIES WITH timeSeriesControl.GT.0 ONLY FOR TIME EXPANSION.'
            STOP
         ENDIF
         IF( OM.LT.0.D-4 ) THEN
            WRITE(*,*) 'OM TOO SMALL FOR timeSeriesControl.GT.0.'
            STOP
         ENDIF
         IF( timeSeriesControl.EQ.1 ) THEN
            nPlots = 6
         ELSEIF( timeSeriesControl.EQ.2 ) THEN
            nPlots = 8
         ENDIF
         TPERIOD = 2*PI/OM
         DT = TPERIOD/nPlots
         drawPlotNum = 3
         TIME(1) = 0.D0
         ABCNUMI(1,1) = '(a)'
         DO J = 2,nSubPlots(1)
            ABCNUMI(1,J) = '   '
         enddo
         DO 130 I = 2,nPlots
            domain(I) = domain(1)
            nSubPlots(I) = nSubPlots(1)
            IF( domain(I).EQ.'HS' ) THEN
               NR = NR+1
            ELSE
               NQ = NQ+1
            ENDIF
            IF( I.EQ.2 ) THEN
               TIME(I) = DT
            ELSEIF( I.EQ.3 ) THEN
               IF( nPlots.EQ.6 ) THEN
                  TIME(I) = 5*DT
               ELSEIF( nPlots.EQ.8 ) THEN
                  TIME(I) = 2*DT
               ENDIF
            ELSEIF( I.EQ.4 ) THEN
               IF( nPlots.EQ.6 ) THEN
                  TIME(I) = 2*DT
               ELSEIF( nPlots.EQ.8 ) THEN
                  TIME(I) = 7*DT
               ENDIF
            ELSEIF( I.EQ.5 ) THEN
               IF( nPlots.EQ.6 ) THEN
                  TIME(I) = 4*DT
               ELSEIF( nPlots.EQ.8 ) THEN
                  TIME(I) = 3*DT
               ENDIF
            ELSEIF( I.EQ.6 ) THEN
               IF( nPlots.EQ.6 ) THEN
                  TIME(I) = 3*DT
               ELSEIF( nPlots.EQ.8 ) THEN
                  TIME(I) = 6*DT
               ENDIF
            ELSEIF( I.EQ.7 ) THEN
               TIME(I) = 5*DT
            ELSEIF( I.EQ.8 ) THEN
               TIME(I) = 4*DT
            ENDIF
            DO 120 J = 1,nSubPlots(1)
               quadrant(I,J) = quadrant(1,J)
               constantCoordinate(I,J) = constantCoordinate(1,J)
               XC(I,J) = XC(1,J)
               whatToPlot(I,J) = whatToPlot(1,J)
               XRMU(I,J) = XRMU(1,J)
               ZD(I,J) = -ZD(1,J)
               IF( J.EQ.1 ) THEN
                  IF( I.EQ.2 ) THEN
                     ABCNUMI(I,J) = '(b)'
                  ELSEIF( I.EQ.3 ) THEN
                     IF( nPlots.EQ.6 ) THEN
                        ABCNUMI(I,J) = '(f)'
                     ELSEIF( nPlots.EQ.8 ) THEN
                        ABCNUMI(I,J) = '(c)'
                     ENDIF
                  ELSEIF( I.EQ.4 ) THEN
                     IF( nPlots.EQ.6 ) THEN
                        ABCNUMI(I,J) = '(c)'
                     ELSEIF( nPlots.EQ.8 ) THEN
                        ABCNUMI(I,J) = '(h)'
                     ENDIF
                  ELSEIF( I.EQ.5 ) THEN
                     IF( nPlots.EQ.6 ) THEN
                        ABCNUMI(I,J) = '(e)'
                     ELSEIF( nPlots.EQ.8 ) THEN
                        ABCNUMI(I,J) = '(d)'
                     ENDIF
                  ELSEIF( I.EQ.6 ) THEN
                     IF( nPlots.EQ.6 ) THEN
                        ABCNUMI(I,J) = '(d)'
                     ELSEIF( nPlots.EQ.8 ) THEN
                        ABCNUMI(I,J) = '(g)'
                     ENDIF
                  ELSEIF( I.EQ.7 ) THEN
                     ABCNUMI(I,J) = '(f)'
                  ELSEIF( I.EQ.8 ) THEN
                     ABCNUMI(I,J) = '(e)'
                  ENDIF
               ELSE
                  ABCNUMI(I,J) = '   '
               ENDIF
120         CONTINUE
130      CONTINUE
      ENDIF
! 
!-- CALCULATION OF INNER AND OUTER RADIUS:
      RI = ETA/(1.D0-ETA)
      RO = 1.D0+RI
      XRI = DBLE(RI)
      XRO = DBLE(RO)
! 
!-- ABG CALCULATES THE ALPHAS AND BETAS IN THE RADIAL FUNCTION
!   OF THE POLOIDAL MAGNETIC FIELD:
      IF( LCALC.EQ.2 .OR. LCALC.EQ.4 .OR. LCALC.EQ.6 ) 
     &                        CALL ABG(ND,CF,L,N)
! 
!      DO 50 I = 1,ND
!50    WRITE(50,'(I3,A2,A3,4I4)') I,CF(I),CRR(I),L(I),M(I),N(I),K(I)
! 
!-- WAEHLEN DES ENDGERAETES:
200   CONTINUE
!      WRITE(*,*) 'BITTE AUSGABE W\"AHLEN.'
!      WRITE(*,*) ' ENDE           0,'     
!      WRITE(*,*) ' TEKTRONIX      1,'     
!      WRITE(*,*) ' PLOTTER        2,'     
!      WRITE(*,*) ' LASER (SYS.)   3,'     
!      WRITE(*,*) ' LASER (NWII)   4,'     
!      WRITE(*,*) ' POSTSCRIPT     5.'     
!      READ(*,*) 
!      READ(*,*) NOUT
! 
!     CALL SYSBUF
!     IF( NOUT.EQ.0 ) THEN
!              GOTO 9999
!     ELSEIF( NOUT.EQ.1 ) THEN
!         CALL TEKALL(4010,480,0,0,0)
!        CALL TEKALL_OLD(4010,480,0,0,0)
!     ELSEIF( NOUT.EQ.2 ) THEN
!              CALL HP7550(2)
!     ELSEIF( NOUT.EQ.3 ) THEN
!        CALL HPLJET(300,1)
!     ELSEIF( NOUT.EQ.4 ) THEN
!        CALL HPLJET(300,2)
!     ELSEIF( NOUT.EQ.5 ) THEN
!              CALL PSCRPT(2,1)
!     ELSE
!        WRITE(*,*) 'WRONG INPUT OF NOUT.'
!        WRITE(*,*)
!         GOTO 200
!     ENDIF
! 
!-- ABINITIALISIERT SCHRIFTEN:
!     CALL AB

!-- FEHLER NACH 13 SCHREIBEN
      OPEN(13,STATUS = 'SCRATCH')
!     CALL SETDEV(13,13)
! 
!-- BILDER IM HOCHFORMAT
!     CALL HWROT('COMIC')
!      CALL HWROT('AUTO')
!      CALL HWSCAL('SCREEN')
! 
!-- VERGR/"OSSERN,EINHEITEN
!      CALL BLOWUP(1.1D0)
!     CALL UNITS('CM')
! 
!-- DINA4 SEITE IM HOCHFORMAT 
!      YPAGE = 29.D0
!      XPAGE = 21.D0
!      CALL PAGE(XPAGE,YPAGE)
! 
!-- VERDECKEN
!     CALL HIDE
! 
!-- SCHRIFT TRIPLEX
!     CALL TRIPLX
! 
!-- KEINE BEGRENZUNG
!     CALL NOBRDR
! 
!-- DETERMINATION OF PARAMETERS FOR EACH SUBPLOT:
! 
!-- XLRAND = LINKER RAND , XRRAND = RECHTER RAND , YURAND = UNTERER RAND ,
!   XINTER,YINTER = ZWISCHENRAUM ZWISCHEN PLOTS , 
!   YHR = HOEHE RECHTECK , XBR = BREITE RECHTECK ( FUER domain = 'HS' ) ,
!   YHQ = HOEHE QUADRAT , BXQ = BREITE QUADRAT ( FUER domain = 'QU' ODER domain = 'SP' ) ,
!   YHPG = HOEHE PLOTGEBIET , XBPG = BREITE PLOTGEBIET ( OHNE KOPF ) .
      XLRAND = 3.0D0
      XRRAND = 3.0D0
      NROWR = NR
      NROWQ = NQ/2
      IF( MOD(NQ,2).NE.0 ) NROWQ = NROWQ+1
      IF( timeSeriesControl.NE.0 ) THEN 
         NROWR = 0
         NROWQ = 3
      ELSE 
         NROWR = NR
         NROWQ = NQ/2
         IF( MOD(NQ,2).NE.0 ) NROWQ = NROWQ+1
      ENDIF
      NROW = NROWR+NROWQ
      IF( plotSize.EQ.0 .AND. NROW.GT.3 ) THEN
         WRITE(*,*) 'TOO MANY ROWS, ONLY 3 ALLOWED FOR plotSize = 0.',NROW
         STOP
      ELSEIF( plotSize.EQ.1 .AND. NROW.GT.2 ) THEN
         WRITE(*,*) 'TOO MANY ROWS, ONLY 2 ALLOWED FOR plotSize = 1.',NROW
         STOP
      ELSEIF( plotSize.EQ.2 .AND. NROW.GT.1 ) THEN
         WRITE(*,*) 'TOO MANY ROWS, ONLY 1 ALLOWED FOR plotSize = 2.',NROW
         STOP
      ENDIF
      IF( NQ.LE.1 ) THEN
         NCOL = 1
      ELSE
         NCOL = 2
      ENDIF
      IF( plotSize.EQ.2 .AND. NCOL.EQ.2 ) THEN
         WRITE(*,*) 'TOO MANY COLUMNS, ONLY 1 ALLOWED FOR plotSize = 2.',NCOL
         STOP
      ENDIF
      IF( IABS(timeSeriesControl).EQ.2 ) NCOL = 3
      XTEXT = XLRAND
! 
!-- GROESSE DER PLOTS:
      IF( plotSize.EQ.0 ) THEN
         YHR = 5.5D0
               YHQ = 5.5D0
         XLR = 2.0D0
         XLQ = 1.5D0
         XINTER = 1.D0
         YINTER = 1.D0
      ELSEIF( plotSize.EQ.1 ) THEN 
         YHR = 6.75D0
         YHQ = 6.75D0
         XLR = 0.75D0
         XLQ = 0.0D0
         XINTER = 1.5D0
         YINTER = 1.5D0
      ELSEIF( plotSize.EQ.2 ) THEN
         YHR = 6.75D0
         YHQ = 13.0
         XLR = 1.0D0
         XINTER = 0.0D0
         YINTER = 0.0D0
      ENDIF
      XBQ = YHQ
      XBR = 2*YHR
! 
      IF( LHEAD.EQ.0 ) THEN
         YHKOPF = 0.0D0
      ELSEIF( LHEAD.EQ.1 ) THEN
         YHKOPF = 3.D0
      ENDIF
      IF( drawPlotNum.EQ.1 ) THEN
         YHFUSS = 5.0D0
      ELSE
         YHFUSS = 0.0D0
      ENDIF
      YHPG = NROWR*YHR+NROWQ*YHQ+(NROW-1)*YINTER
      IF( NQ.GT.0 ) THEN
         XBPG = 2*XLQ+NCOL*XBQ+(NCOL-1)*XINTER
      ELSE
         XBPG = 2*XLR+XBR
      ENDIF
      XAREA = XLRAND+XBPG+XRRAND
      YAREA = YHFUSS+YHPG+YHKOPF
!     CALL PAGE(XAREA,YAREA)
! 
!-- NZEI ZAEHLT ZEILEN , NSPA SPALTEN UND NP ZAHL DER PLOTS.
!   NQT ZAEHLT DIE ZAHL DER QUADRATE.
      NP = 0
      NQT = 0
! 
!-- DIE DATEN FUER DIE EINZELNEN PLOTS WERDEN FESTGELEGT UND LINEAR
!   ABGESPEICHERT: URSPRUNG IN CM = (XORIG,YORIG) ,
!   PLOTGEBIET IN CM = (XAR,YAR) , RADIEN IN CM = (XRICM,XROCM,XRMCM).
      DO 2000 I = 1,nPlots
         IF( I.EQ.1 ) THEN
            NSPA = 1
            NZEI = 1
            IF( domain(I).EQ.'HS' ) THEN
               YHPLOT = YHR
               XBPLOT = XBR
               XLPLOT = XLR
            ELSE
               YHPLOT = YHQ
               XBPLOT = XBQ
               XLPLOT = XLQ
            ENDIF
         ELSEIF( domain(I).EQ.'HS' .OR. domain(I-1).EQ.'HS' ) THEN
            NSPA = 1
            NZEI = NZEI+1
            YHPLOT = YHR
            XBPLOT = XBR
            XLPLOT = XLR
         ELSE
            IF( NSPA.EQ.NCOL ) THEN
               NSPA = 1
               NZEI = NZEI+1
            ELSE
               NSPA = NSPA+1
               IF( IABS(timeSeriesControl).EQ.2 .AND. I.EQ.5 ) NSPA = NSPA+1
            ENDIF
            YHPLOT = YHQ
            XBPLOT = XBQ
            XLPLOT = XLQ
         ENDIF
         XORIG = XLRAND+XLPLOT+(NSPA-1)*(XBPLOT+XINTER)
         YORIG = YHFUSS+YHPG-NZEI*YHPLOT-(NZEI-1)*YINTER

              IF( domain(I).EQ.'QU' .OR. domain(I).EQ.'SP' .AND. NCOL.GT.1 ) THEN
            NQT = NQT+1
            IF( NSPA.EQ.1 .AND. NQT.EQ.NQ ) XLQ = XLQ+(XBQ+XINTER)/2
         ENDIF
         DO 1000 J = 1,nSubPlots(I)
                  NP = NP+1
                  CPP(NP) = quadrant(I,J)
            CFP(NP) = whatToPlot(I,J)
            CCP(NP) = constantCoordinate(I,J)
            ABCN(NP) = ABCNUMI(I,J)
            IF( constantCoordinate(I,J).EQ.'R' ) THEN
                     XCP(NP) = XRI+XC(I,J)
            ELSE
                     XCP(NP) = XC(I,J)
            ENDIF
                  ZDP(NP) = ZD(I,J)
            TIMEP(NP) = TIME(I)
            IF( domain(I).EQ.'HS' ) THEN
                     IF( quadrant(I,J).EQ.'HO' .OR. quadrant(I,J).EQ.'HU' ) THEN
                        XOR(NP) = XORIG
                  XAR(NP) = XBR
                        YOR(NP) = YORIG
                  YAR(NP) = YHR
                  XRMCM(NP) = XBR/2
                     ELSEIF( quadrant(I,J).EQ.'Q1' ) THEN
                        XOR(NP) = XORIG+XBR/2
                  XAR(NP) = XBR/2
                        YOR(NP) = YORIG
                  YAR(NP) = YHR
                  XRMCM(NP) = XBR/2
                     ELSEIF( quadrant(I,J).EQ.'Q2' ) THEN
                        XOR(NP) = XORIG
                  XAR(NP) = XBR/2
                        YOR(NP) = YORIG
                  YAR(NP) = YHR
                  XRMCM(NP) = XBR/2
                     ELSEIF( quadrant(I,J).EQ.'Q3' ) THEN
                        XOR(NP) = XORIG
                  XAR(NP) = XBR/2
                        YOR(NP) = YORIG
                  YAR(NP) = YHR
                  XRMCM(NP) = XBR/2
                     ELSEIF( quadrant(I,J).EQ.'Q4' ) THEN
                        XOR(NP) = XORIG+XBR/2
                  XAR(NP) = XBR/2
                        YOR(NP) = YORIG
                  YAR(NP) = YHR
                  XRMCM(NP) = XBR/2
               ENDIF
            ELSEIF( domain(I).EQ.'QU' ) THEN
                     XOR(NP) = XORIG
               XAR(NP) = XBQ
                     YOR(NP) = YORIG
               YAR(NP) = YHQ
               XRMCM(NP) = XBQ
            ELSEIF( domain(I).EQ.'SP' ) THEN
                     IF( quadrant(I,J).EQ.'Q1' ) THEN
                        XOR(NP) = XORIG+XBQ/2
                  XAR(NP) = XBQ/2
                        YOR(NP) = YORIG+YHQ/2
                  YAR(NP) = YHQ/2
                  XRMCM(NP) = XBQ/2
                     ELSEIF( quadrant(I,J).EQ.'Q2' ) THEN
                        XOR(NP) = XORIG
                  XAR(NP) = XBQ/2
                        YOR(NP) = YORIG+YHQ/2
                  YAR(NP) = YHQ/2
                  XRMCM(NP) = XBQ/2
                     ELSEIF( quadrant(I,J).EQ.'Q3' ) THEN
                        XOR(NP) = XORIG
                  XAR(NP) = XBQ/2
                        YOR(NP) = YORIG
                  YAR(NP) = YHQ/2
                  XRMCM(NP) = XBQ/2
                     ELSEIF( quadrant(I,J).EQ.'Q4' ) THEN
                        XOR(NP) = XORIG+XBQ/2
                  XAR(NP) = XBQ/2
                        YORIG = YORIG
                        YOR(NP) = YORIG
                  YAR(NP) = YHQ/2
                  XRMCM(NP) = XBQ/2
               ELSEIF( quadrant(I,J).EQ.'HU' ) THEN
                        XOR(NP) = XORIG
                  XAR(NP) = XBQ
                        YOR(NP) = YORIG
                  YAR(NP) = YHQ/2              
                  XRMCM(NP) = XBQ/2
               ELSEIF( quadrant(I,J).EQ.'HO' ) THEN
                        XOR(NP) = XORIG
                  XAR(NP) = XBQ
                        YOR(NP) = YORIG+YHQ/2
                  YAR(NP) = YHQ/2      
                  XRMCM(NP) = XBQ/2
               ELSEIF( quadrant(I,J).EQ.'HL' ) THEN
                        XOR(NP) = XORIG
                  XAR(NP) = XBQ/2
                        YOR(NP) = YORIG
                  YAR(NP) = YHQ
                  XRMCM(NP) = XBQ/2
               ELSEIF( quadrant(I,J).EQ.'HR' ) THEN
                        XOR(NP) = XORIG+XBQ/2
                  XAR(NP) = XBQ/2
                        YOR(NP) = YORIG
                  YAR(NP) = YHQ              
                  XRMCM(NP) = XBQ/2
               ELSEIF( quadrant(I,J).EQ.'SP' .OR. quadrant(I,J).EQ.'PS' .OR.
     &                       quadrant(I,J).EQ.'PL' ) THEN
                  XOR(NP) = XORIG
                  XAR(NP) = XBQ
                        YOR(NP) = YORIG
                  YAR(NP) = YHQ              
                  XRMCM(NP) = XBQ/2
               ELSEIF( quadrant(I,J).EQ.'PR' ) THEN
                  XOR(NP) = XORIG
                  XAR(NP) = XBQ
                        YOR(NP) = YORIG
                  YAR(NP) = YHQ              
                  XRMCM(NP) = XBQ/2
               ENDIF        
            ENDIF
            XRM(NP) = XRMU(I,J)*XRO
            XROCM(NP) = XRMCM(NP)*XRO/XRM(NP)
            XRICM(NP) = XRMCM(NP)*XRI/XRM(NP)
1000     CONTINUE
2000  CONTINUE
! 
!      DO 2100 I = 1,NP
!2100  WRITE(60,'(X,A3,A2,A2,4E14.4)') CPP(I),CFP(I),CCP(I),XOR(I),
!     &                                      YOR(I),XAR(I),YAR(I)
! 
! 
!-- SCHREIBEN DES KOPFES:
!     IF( LHEAD.EQ.1 ) THEN
!        YTEXT = YHFUSS+YHPG+YHKOPF-1.E0
!        CALL PHYSOR(0.0E0,0.0E0)
!        CALL AREA2D(XAREA,YAREA)
!        CALL HEIGHT(0.3)
!        CALL MESSAG('Ta  = ',100.,XTEXT,YTEXT)
!        CALL REALNO(REAL(TA),-3,'ABUT','ABUT')
!        CALL MESSAG(' ,  Ra  = ',100.,'ABUT','ABUT')
!        CALL REALNO(REAL(RA),3,'ABUT','ABUT')
!        CALL MESSAG(' ,  Pr  = ',100.,'ABUT','ABUT')
!        CALL REALNO(REAL(PR),3,'ABUT','ABUT')
!        CALL MESSAG(' ,  Pm  = ',100.,'ABUT','ABUT')
!        CALL REALNO(REAL(PM),3,'ABUT','ABUT')
! 
!        YTEXT = YTEXT-0.7E0
!        CALL MESSAG('M0 = ',5,XTEXT,YTEXT)
!        CALL INTNO(M0,'ABUT','ABUT')
!        CALL MESSAG(' ,  Ntv = ',10,'ABUT','ABUT')
!        CALL INTNO(NTV,'ABUT','ABUT')
!        CALL MESSAG(' ,  Nth = ',10,'ABUT','ABUT')
!        CALL INTNO(NTH,'ABUT','ABUT')
!        CALL MESSAG(' ,  {M7}c{M0}  = ',100.,'ABUT','ABUT')
!        CALL REALNO(REAL(ETA),2,'ABUT','ABUT')
!        CALL MESSAG(' ,  c  = ',100.,'ABUT','ABUT')
!        CALL REALNO(REAL(C),3,'ABUT','ABUT')
!        IF( OM.NE.0.D0 ) THEN
!           PERIOD = 2*PI/OM
!           CALL MESSAG(' ,  T  = ',100.,'ABUT','ABUT')
!           CALL REALNO(REAL(PERIOD),3,'ABUT','ABUT')
!        ENDIF
! 
!        YTEXT = YTEXT-0.9E0
!        CALL MESSAG('DATAFILE = ',11,XTEXT+9.E0,YTEXT)
!        CALL MESSAG(INPUTFILE,100,'ABUT','ABUT')
! 
!        CALL ENDGR(0)
!     ENDIF
! 
         YTEXT = YHFUSS-1.0E0
! 
!-- PLO FUEHRT DIE EINZELNEN SUBPLOTS AUS:
! 
      DO 3000 I = 1,NP
! 
      write(14,*) 'Plot Nr. ',I,':'
! 
!-- READLA READS THE SET OF COEFFITIENTS TO BE PLOTTED .
!   IF THIS IT IS A TIMEINTEGRATION AND THE TIMES DIFFER 
!   READLA HAS TO BE CALLED FOR EVERY TIME.
!      DO 3100 J = 1,ND
!3100  WRITE(51,'(I3,A2,A3,4I3,D16.6)') 
!     &            J,CF(J),CRR(J),L(J),M(J),N(J),K(J),DX(J)
! 
         IF( TIMEP(I).NE.TIMEO .AND. LT.EQ.1 ) THEN
            CALL READLA(INPUTFILE,NUDS,TIMEP(I),DX)
         ENDIF
! 
         CALL PLO(I,NSUBP,DC,DX,contourDistanceOrNumber,plotSize,drawFrame,
     &                  ZDP(I),TIMEP(I),CPP(I),CFP(I),CCP(I),XCP(I),
     &                   XOR(I),YOR(I),XAR(I),YAR(I),
     &                  XRI,XRO,XRM(I),XRICM(I),XROCM(I),XRMCM(I),XP,YP)

! 
!-- BESCHRIFTUNG SUBPLOT: BUCHSTABE IM PLOT AN POSITION (XNUM,YNUM) ,
!   BESCHRIFTUNG UNTER BUCHSTABE UNTEN AUF SEITE.
          IF( drawPlotNum.GT.0 ) THEN
!            CALL HEIGHT(0.3)
             IF( CPP(I).EQ.'Q1' ) THEN
                      XNUM = XOR(I)+XAR(I)-0.9E0
                      YNUM = YOR(I)+YAR(I)-0.5E0
                XTIME = XNUM-2.E0
                YTIME = YNUM+0.8E0
             ELSEIF( CPP(I).EQ.'Q2' ) THEN
                      XNUM = XOR(I)+0.25E0
                      YNUM = YOR(I)+YAR(I)-0.5E0
                XTIME = XNUM
                YTIME = YNUM+0.8E0
             ELSEIF( CPP(I).EQ.'Q3' ) THEN
                      XNUM = XOR(I)+0.25E0
                      YNUM = YOR(I)+0.2E0
                XTIME = XNUM
                YTIME = YNUM-1.0E0
             ELSEIF( CPP(I).EQ.'Q4' ) THEN
                      XNUM = XOR(I)+XAR(I)-0.9E0
                      YNUM = YOR(I)+0.3E0
                XTIME = XNUM-2.E0
                YTIME = YNUM-1.0E0
             ELSEIF( CPP(I).EQ.'HO' ) THEN
                      XNUM = XOR(I)+0.25E0
                      YNUM = YOR(I)+YAR(I)-0.5E0
                XTIME = XNUM
                YTIME = YNUM+0.8E0
             ELSEIF( CPP(I).EQ.'HU' ) THEN
                      XNUM = XOR(I)+0.25E0
                      YNUM = YOR(I)+0.2E0
                XTIME = XNUM
                YTIME = YNUM-1.0E0
             ELSEIF( CPP(I).EQ.'HL' .OR. CPP(I).EQ.'PL' ) THEN
                      XNUM = XOR(I)+0.25E0
                      YNUM = YOR(I)+YAR(I)-0.5E0
                XTIME = XNUM
                YTIME = YNUM+0.8E0
             ELSEIF( CPP(I).EQ.'HR' .OR. CPP(I).EQ.'PR' ) THEN
                      XNUM = XOR(I)+XAR(I)-0.9E0
                      YNUM = YOR(I)+YAR(I)-0.5E0
                XTIME = XNUM-2.E0
                YTIME = YNUM+0.8E0
             ELSEIF( CPP(I).EQ.'SP' .OR. CPP(I).EQ.'PS' ) THEN
                      XNUM = XOR(I)+0.25E0
                      YNUM = YOR(I)+YAR(I)-0.5E0
                XTIME = XNUM
                YTIME = YNUM+0.8E0
             ENDIF
!            CALL PHYSOR(0.0E0,0.0E0)
!            CALL AREA2D(XAREA,YAREA)
!            IF( drawTime.EQ.1 .AND.
!     &                ( TIMEP(I).NE.TIMEO .OR. I.EQ.1 ) ) THEN
!               CALL MESSAG('t =  ',100.,XTIME,YTIME)
!               CALL REALNO(REAL(TIMEP(I)),5,'ABUT','ABUT')
!            ENDIF
!            IF( drawPlotNum.LT.3 ) THEN
!               IF( I.EQ.1 ) THEN
!                  ABCNUM = '(a)'
!               ELSEIF( I.EQ.2 ) THEN
!                  ABCNUM = '(b)'
!               ELSEIF( I.EQ.3 ) THEN
!                  ABCNUM = '(c)'
!               ELSEIF( I.EQ.4 ) THEN
!                  ABCNUM = '(d)'
!               ELSEIF( I.EQ.5 ) THEN
!                  ABCNUM = '(e)'
!               ELSEIF( I.EQ.6 ) THEN
!                  ABCNUM = '(f)'
!               ELSEIF( I.EQ.7 ) THEN
!                  ABCNUM = '(g)'
!               ELSEIF( I.EQ.8 ) THEN
!                  ABCNUM = '(h)'
!               ELSEIF( I.EQ.9 ) THEN
!                  ABCNUM = '(i)'
!               ELSEIF( I.EQ.10 ) THEN
!                  ABCNUM = '(j)'
!               ELSEIF( I.EQ.11 ) THEN
!                  ABCNUM = '(k)'
!               ELSEIF( I.EQ.12 ) THEN
!                  ABCNUM = '(l)'
!               ELSEIF( I.EQ.13 ) THEN
!                  ABCNUM = '(m)'
!               ELSEIF( I.EQ.14 ) THEN
!                  ABCNUM = '(n)'
!               ELSEIF( I.EQ.15 ) THEN
!                  ABCNUM = '(o)'
!               ELSEIF( I.EQ.16 ) THEN
!                  ABCNUM = '(p)'
!               ELSEIF( I.EQ.17 ) THEN
!                  ABCNUM = '(q)'
!               ELSEIF( I.EQ.18 ) THEN
!                  ABCNUM = '(r)'
!               ELSEIF( I.EQ.19 ) THEN
!                  ABCNUM = '(s)'
!               ELSEIF( I.EQ.20 ) THEN
!                  ABCNUM = '(t)'
!               ELSE
!                  ABCNUM = '(x)'
!               ENDIF
!            ELSEIF( drawPlotNum.EQ.3 ) THEN
!               ABCNUM = ABCN(I)
!            ENDIF
!            CALL MESSAG(ABCNUM,3.,XNUM,YNUM)
             IF( drawPlotNum.EQ.1 ) THEN
!ccc            YTEXT = YHFUSS-1.0E0
!               CALL MESSAG(ABCNUM,3.,XTEXT,YTEXT)
                IF( CFP(I).EQ.'BR' ) THEN
                   CTEXT1 = '  Contours of radial magnetic field for '
                ELSEIF( CFP(I).EQ.'BR' ) THEN
                   CTEXT1 = '  Contours of toriodal magnetic field for '
                ELSEIF( CFP(I).EQ.'BS' ) THEN
                   CTEXT1 = '  Magnetic field lines in the plane '
                ELSEIF( CFP(I).EQ.'VR' ) THEN
                   CTEXT1 = '  Contours of radial velocity field for '
                ELSEIF( CFP(I).EQ.'VS' ) THEN
                   CTEXT1 = '  Streamlines in the plane  '
                ELSEIF( CFP(I).EQ.'VS' ) THEN
            CTEXT1 = '  Streamlines of electric current in the plane  '
                ELSEIF( CFP(I).EQ.'TE' ) THEN
                   CTEXT1 = '  Temperature field '
                ELSEIF( CFP(I).EQ.'ZF' ) THEN
                   CTEXT1 = '  Mean zonal flow '
                ELSEIF( CFP(I).EQ.'MF' ) THEN
                   CTEXT1 = '  Mean meridional flow '
                ELSEIF( CFP(I).EQ.'MT' ) THEN
                   CTEXT1 = '  Mean toroidal magnetic field '
                ELSEIF( CFP(I).EQ.'MP' ) THEN
                CTEXT1 = '  Fieldlines of mean poloidal magnetic field '
                ELSEIF( CFP(I).EQ.'MJ' ) THEN
                   CTEXT1 = '  Fieldlines of mean electric current'
                ELSEIF( CFP(I).EQ.'MC' ) THEN
            CTEXT1 = '  Contourlines of mean phi comp. of elec. curr.'
                ELSEIF( CFP(I).EQ.'TT' ) THEN
            CTEXT1 = '  Temperature field including basic state for '
                ELSEIF( CFP(I).EQ.'UP' ) THEN
                   CTEXT1 = '  Contours of U{M7}v{M0} for '
                ELSEIF( CFP(I).EQ.'NU' ) THEN
                   CTEXT1 = '  Contours of local nusselt number for '
                   XCP(I) = REAL(ETA/(1.D0-ETA))
                ENDIF
!               CALL MESSAG(CTEXT1,100.,'ABUT','ABUT')
                IF( CCP(I).EQ.'P') THEN
!                  CALL MESSAG(' {M7}v{M0}  = ',100.,'ABUT','ABUT')
                   CTEXT2 = 'phi  = '
                ELSEIF( CCP(I).EQ.'T') THEN
!                  CALL MESSAG(' {M7}Q{M0}  = ',100.,'ABUT','ABUT')
                   CTEXT2 = 'theta  = '
                ELSEIF( CCP(I).EQ.'R' ) THEN
!                  CALL MESSAG(' r  = ',100.,'ABUT','ABUT')
                   CTEXT2 = 'r  = '
                ENDIF
!               CALL REALNO(REAL(XCP(I)),2,'ABUT','ABUT')
!               IF( drawTime.EQ.1 ) THEN
!                CALL MESSAG(' , relative time  = ',100.,'ABUT','ABUT')
!                  CALL REALNO(REAL(TIMEP(I)),4,'ABUT','ABUT')
!               ENDIF
                write(14,*) CTEXT1,CTEXT2,XCP(I)
                write(*,*) CTEXT1,CTEXT2,XCP(I)
             ENDIF
!            CALL ENDGR(0)
             YTEXT = YTEXT-0.5E0
          ENDIF
          TIMEO = TIMEP(I)
3000  CONTINUE
!C
!     CALL DONEPL
! 
      CLOSE(11)
      CLOSE(14)
      CLOSE(13)
! 
!      GOTO 200
9999  CONTINUE
! 
      END
! 
!----------------------------------------------------------------------
!-- END OF LARA
!----------------------------------------------------------------------
! 
! 
!**********************************************************************
      SUBROUTINE PLO(NPLOT,NSUBP,DC,DX,contourDistanceOrNumber,plotSize,drawFrame,ZD,TIME,CP,CF,constantCoordinate,XC,
     &        XOR,YOR,XAR,YAR,XRI,XRO,XRM,XRICM,XROCM,XRMCM,XP,YP)
!
!     calculates the field Z and makes one subplot.
!
!**********************************************************************
! 
!----------------------------------------------------------------------
      IMPLICIT REAL*8(A-H,O-W)
      IMPLICIT REAL*8(X,Y,Z)
      CHARACTER*1 constantCoordinate,CCC
      CHARACTER*2 CP,CF,CPC
      character*20 filez,filex,filey
      PARAMETER(NMX = 65,NMY = 128)
!     PARAMETER(NMX = 101,NMY = 51)
      PARAMETER (PI = 3.14159265358979D0)
! 
      DIMENSION DX(*),THETA(NMY),XIDL(NMX,NMY),YIDL(NMX,NMY)
      DIMENSION Z(NMX,NMY),XML(2),YML(2),ZDS(4)
! 
      COMMON/PLOTC/ZDO,NCPLOT
      COMMON/PARI/RA,TA,PR,PM,ETA,C,OM,FTW,FTG,MF
!CCCC COMMON/TRANSC/CPC,CCC,XCC,XARC,YARC,XMIN,XMAX,YMIN,YMAX
      COMMON/CNULL/ZNULL
      integer on_a_sphere
      COMMON/THETAC/THETA
! 
!-- COUNTER
      NCPLOT = NCPLOT+1
      WRITE(14,'(2X,''TIME =  '',2D16.6)') TIME
! 
!-- UEBERGABE AN COMMONBLOCK FUER TRANS:
      CCC = constantCoordinate
      CPC = CP
      XCC = XC
! 
!-- INITIALISIERUNG VON DISSPLA UND ZEICHNEN EINES RAHMENS (FRAME):
!     CALL PHYSOR(XOR,YOR)
!     CALL AREA2D(XAR,YAR)
!     IF( drawFrame.EQ.1 ) THEN
!        CALL THKFRM(0.02E0)
!        CALL FRAME
!     ENDIF
      DXY = XRO/100
! 
!-- FESTLEGEN DER X BZW Y ACHSE UND ZEICHNEN DES INNEREN UND
!   AEUSSEREN KERNS MIT ARC:
      IF( CP.EQ.'Q1' ) THEN
!        CALL THKCRV(0.01E0)
!        CALL GRAF(0.E0,DXY,XRM,0.E0,DXY,XRM)
         XML(1) = XRI
         YML(1) = 0.E0
         XML(2) = XRO
         YML(2) = 0.E0
!        CALL CURVE(XML,YML,2,0)
         XML(1) = 0.E0
         YML(1) = XRI
         XML(2) = 0.E0
         YML(2) = XRO
!        CALL CURVE(XML,YML,2,0)
!        CALL RESET('THKCRV')
         XMIN = XRI
         XMAX = XRM
         IF( constantCoordinate.EQ.'T' ) THEN
                  YMIN = 90.E0
            YMAX = 180.E0
         ELSEIF( constantCoordinate.EQ.'P' ) THEN
                  YMIN = 0.E0
            YMAX = 90.E0
         ENDIF
!        CALL ARC(0.E0,0.E0,XRICM,0.E0,90.E0,'NONE',0.01E0)
!        CALL ARC(0.E0,0.E0,XROCM,0.E0,90.E0,'NONE',0.01E0)
!        CALL THKCRV(0.01E0)
      ELSEIF( CP.EQ.'Q2' ) THEN
         XMIN = XRI
               XMAX = XRM
         IF( constantCoordinate.EQ.'T' ) THEN
                  YMIN = 180.E0
            YMAX = 270.E0
         ELSEIF( constantCoordinate.EQ.'P' ) THEN
                  YMIN = 0.E0
            YMAX = 90.E0
         ENDIF
!        CALL ARC(XRMCM,0.E0,XRICM,90.E0,180.E0,'NONE',0.01E0)
!        CALL ARC(XRMCM,0.E0,XROCM,90.E0,180.E0,'NONE',0.01E0)
!        CALL THKCRV(0.01E0)
!        CALL GRAF(-XRM,DXY,0.E0,0.E0,DXY,XRM)
         XML(1) = -XRO
         YML(1) = 0.E0
         XML(2) = -XRI
         YML(2) = 0.E0
!        CALL CURVE(XML,YML,2,0)
         XML(1) = 0.E0
         YML(1) = XRI
         XML(2) = 0.E0
         YML(2) = XRO
!        CALL CURVE(XML,YML,2,0)
!        CALL RESET('THKCRV')
      ELSEIF( CP.EQ.'Q3' ) THEN
         XMIN = XRI
               XMAX = XRM
         IF( constantCoordinate.EQ.'T' ) THEN
                  YMIN = 270.E0
            YMAX = 360.E0
         ELSEIF( constantCoordinate.EQ.'P' ) THEN
                  YMIN = 90.E0
            YMAX = 180.E0
         ENDIF
!        CALL ARC(XRMCM,XRMCM,XRICM,180.E0,270.E0,'NONE',0.01E0)
!        CALL ARC(XRMCM,XRMCM,XROCM,180.E0,270.E0,'NONE',0.01E0)
!        CALL THKCRV(0.01E0)
!        CALL GRAF(-XRM,DXY,0.E0,-XRM,DXY,0.E0)
         XML(1) = -XRO
         YML(1) = 0.E0
         XML(2) = -XRI
         YML(2) = 0.E0
!        CALL CURVE(XML,YML,2,0)
         XML(1) = 0.E0
         YML(1) = -XRI
         XML(2) = 0.E0
         YML(2) = -XRO
!        CALL CURVE(XML,YML,2,0)
!        CALL RESET('THKCRV')
      ELSEIF( CP.EQ.'Q4' ) THEN
         XMIN = XRI
               XMAX = XRM
         IF( constantCoordinate.EQ.'T' ) THEN
                  YMIN = 0.E0
            YMAX = 90.E0
         ELSEIF( constantCoordinate.EQ.'P' ) THEN
                  YMIN = 90.E0
            YMAX = 180.E0
         ENDIF
!        CALL ARC(0.E0,XRMCM,XRICM,270.E0,360.E0,'NONE',0.01E0)
!        CALL ARC(0.E0,XRMCM,XROCM,270.E0,360.E0,'NONE',0.01E0)
!        CALL THKCRV(0.01E0)
!        CALL GRAF(0.E0,DXY,XRM,-XRM,DXY,0.E0)
         XML(1) = XRI
         YML(1) = 0.E0
         XML(2) = XRO
         YML(2) = 0.E0
!        CALL CURVE(XML,YML,2,0)
         XML(1) = 0.E0
         YML(1) = -XRI
         XML(2) = 0.E0
         YML(2) = -XRO
!        CALL CURVE(XML,YML,2,0)
!        CALL RESET('THKCRV')
      ELSEIF( CP.EQ.'HO' ) THEN
         XMIN = XRI
               XMAX = XRM
         IF( constantCoordinate.EQ.'T' ) THEN
                  YMIN = 90.E0-XP
            YMAX = 270.E0-XP
         ELSEIF( constantCoordinate.EQ.'P' ) THEN
                  YMIN = 0.E0
            YMAX = 90.E0
         ENDIF
!        CALL ARC(XRMCM,0.E0,XRICM,0.E0,180.E0,'NONE',0.01E0)
!        CALL ARC(XRMCM,0.E0,XROCM,0.E0,180.E0,'NONE',0.01E0)
!        CALL THKCRV(0.01E0)
!        CALL GRAF(-XRM,DXY,XRM,0.E0,DXY,XRM)
         XML(1) = -XRO
         YML(1) = 0.E0
         XML(2) = -XRI
         YML(2) = 0.E0
!        CALL CURVE(XML,YML,2,0)
         XML(1) = XRI
         YML(1) = 0.E0
         XML(2) = XRO
         YML(2) = 0.E0
!        CALL CURVE(XML,YML,2,0)
!        CALL RESET('THKCRV')
      ELSEIF( CP.EQ.'HU' ) THEN
         XMIN = XRI
               XMAX = XRM
         IF( constantCoordinate.EQ.'T' ) THEN
                  YMIN = 270.E0-XP
            YMAX = 450.E0-XP
         ELSEIF( constantCoordinate.EQ.'P' ) THEN
                  YMIN = 90.E0
            YMAX = 180.E0
         ENDIF
!        CALL ARC(XRMCM,XRMCM,XRICM,180.E0,360.E0,'NONE',0.01E0)
!        CALL ARC(XRMCM,XRMCM,XROCM,180.E0,360.E0,'NONE',0.01E0)
!        CALL THKCRV(0.01E0)
!        CALL GRAF(-XRM,DXY,XRM,-XRM,DXY,0.E0)
         XML(1) = -XRO
         YML(1) = 0.E0
         XML(2) = -XRI
         YML(2) = 0.E0
!        CALL CURVE(XML,YML,2,0)
         XML(1) = XRI
         YML(1) = 0.E0
         XML(2) = XRO
         YML(2) = 0.E0
!        CALL CURVE(XML,YML,2,0)
!        CALL RESET('THKCRV')
      ELSEIF( CP.EQ.'HL' ) THEN
         XMIN = XRI
               XMAX = XRM
         IF( constantCoordinate.EQ.'T' ) THEN
                  YMIN = 180.E0
            YMAX = 360.E0
         ELSEIF( constantCoordinate.EQ.'P' ) THEN
                  YMIN = 0.E0
            YMAX = 180.E0
         ENDIF
!        CALL ARC(XRMCM,XRMCM,XRICM,90.E0,270.E0,'NONE',0.01E0)
!        CALL ARC(XRMCM,XRMCM,XROCM,90.E0,270.E0,'NONE',0.01E0)
!        CALL THKCRV(0.01E0)
!        CALL GRAF(-XRM,DXY,0.E0,-XRM,DXY,XRM)
         XML(1) = 0.D0
         YML(1) = -XRO
         XML(2) = 0.D0
         YML(2) = -XRI
!        CALL CURVE(XML,YML,2,0)
         XML(1) = 0.E0
         YML(1) = XRI
         XML(2) = 0.E0
         YML(2) = XRO
!        CALL CURVE(XML,YML,2,0)
!        CALL RESET('THKCRV')
      ELSEIF( CP.EQ.'HR' ) THEN
         XMIN = XRI
               XMAX = XRM
         IF( constantCoordinate.EQ.'T' ) THEN
                  YMIN = 0.E0
            YMAX = 180.E0
         ELSEIF( constantCoordinate.EQ.'P' ) THEN
                  YMIN = 0.E0
            YMAX = 180.E0
         ENDIF
!        CALL ARC(0.E0,XRMCM,XRICM,-90.E0,90.E0,'NONE',0.01E0)
!        CALL ARC(0.E0,XRMCM,XROCM,-90.E0,90.E0,'NONE',0.01E0)
!        CALL THKCRV(0.01E0)
!        CALL GRAF(0.E0,DXY,XRM,-XRM,DXY,XRM)
         XML(1) = 0.E0
         YML(1) = -XRO
         XML(2) = 0.E0
         YML(2) = -XRI
!        CALL CURVE(XML,YML,2,0)
         XML(1) = 0.E0
         YML(1) = XRI
         XML(2) = 0.E0
         YML(2) = XRO
!        CALL CURVE(XML,YML,2,0)
!        CALL RESET('THKCRV')
      ELSEIF( CP.EQ.'SP' ) THEN
         XMIN = XRI
               XMAX = XRM
         IF( constantCoordinate.EQ.'T' ) THEN
                  YMIN = 0.E0
            YMAX = 360.E0
         ELSEIF( constantCoordinate.EQ.'P' ) THEN
                  YMIN = 0.E0
            YMAX = 180.E0
         ENDIF
!        CALL ARC(XRMCM,XRMCM,XRICM,0.E0,360.E0,'NONE',0.01E0)
!        CALL ARC(XRMCM,XRMCM,XROCM,0.E0,360.E0,'NONE',0.01E0)
      ELSEIF( CP.EQ.'PS' ) THEN
         XMIN = -180.E0-XP
               XMAX = 180.E0-XP
         YMIN = 180.E0-YP
         YMAX = 0.E0-YP
      ELSEIF( CP.EQ.'PL' ) THEN
         XMIN = -180.E0-XP
               XMAX = 180.E0-XP
         YMIN = 180.E0-YP
         YMAX = 0.E0-YP
!        CALL THKCRV(0.01E0)
!        CALL GRAF(0.E0,DXY,1.E0,0.E0,DXY,1.E0)
         XML(1) = 0.5E0
         YML(1) = 0.E0
         XML(2) = 0.5E0
         YML(2) = 1.E0
!        CALL CURVE(XML,YML,2,0)
!        CALL RESET('THKCRV')
!----- SOLL NUR EINE HAELFTE DER KUGELPROJEKTION GEZEICHNET WERDEN,
!      SO WIRD DIE ANDERE DURCH BLANKING ( CALL BLREC ) GESCHUETZT.
!        CALL BLREC(0.0E0+XRMCM,0.0E0,XRMCM,2*XRMCM,0)
      ELSEIF( CP.EQ.'PR' ) THEN
         XMIN = -180.E0-XP
               XMAX = 180.E0-XP
         YMIN = 180.E0-YP
         YMAX = 0.E0-YP
!        CALL THKCRV(0.01E0)
!        CALL GRAF(0.E0,DXY,1.E0,0.E0,DXY,1.E0)
         XML(1) = 0.5E0
         YML(1) = 0.E0
         XML(2) = 0.5E0
         YML(2) = 1.E0
!        CALL CURVE(XML,YML,2,0)
!        CALL RESET('THKCRV')
!        CALL BLREC(0.0E0,0.0E0,XRMCM,2*XRMCM,0)
      ENDIF
!     CALL ENDGR(0)
! 
!-- IST DER MAXIMALE RADIUS XRM GROESSER ALS DER AEUSSERE RADIUS RO
!   UND EXISTIERT ABER NUR FUER R< = RO EIN FELD , SO MUESSEN DAS
!   PLOTGEBIET UND DER URSPRUNG ENTSPRECHEND ANGEPASST WERDEN.
!   TEILWEISE WIRD ZUDEM DIE X-ACHSE AUF R< = RO EINGESCHRAENKT.
      IF( ( ( CF.NE.'BS' .AND. CF.NE.'MP' ) .OR. 
     &      ( CF.EQ.'BS' .AND. constantCoordinate.EQ.'R' ) ) .AND.
     &                                               XROCM.NE.XRMCM ) THEN
         IF( CP(:1).EQ.'Q' ) THEN
            XAR = XROCM
            YAR = XROCM
            XMAX = XRO
            IF( CP.EQ.'Q2' ) THEN
               XOR = XOR+XRMCM-XROCM
            ELSEIF( CP.EQ.'Q3' ) THEN
               XOR = XOR+XRMCM-XROCM
               YOR = YOR+XRMCM-XROCM
            ELSEIF( CP.EQ.'Q4' ) THEN
               YOR = YOR+XRMCM-XROCM
            ENDIF
         ELSEIF( CP.EQ.'HL' ) THEN
                  XAR = XROCM
            YAR = 2*XROCM
            XMAX = XRO
            XOR = XOR+XRMCM-XROCM
            YOR = YOR+XRMCM-XROCM
         ELSEIF( CP.EQ.'HR' ) THEN
                  XAR = XROCM
            YAR = 2*XROCM
            XMAX = XRO
            YOR = YOR+XRMCM-XROCM
         ELSEIF( CP.EQ.'HO' ) THEN
                  XAR = 2*XROCM
            YAR = XROCM
            XMAX = XRO
            XOR = XOR+XRMCM-XROCM
         ELSEIF( CP.EQ.'HU' ) THEN
                  XAR = 2*XROCM
            YAR = XROCM
            XMAX = XRO
            XOR = XOR+XRMCM-XROCM
            YOR = YOR+XRMCM-XROCM   
         ELSEIF( CP.EQ.'SP' .OR. CP(:1).EQ.'P' ) THEN
                  XAR = 2*XROCM
            YAR = 2*XROCM
            IF( CP.EQ.'SP' ) XMAX = XRO
            XOR = XOR+XRMCM-XROCM
            YOR = YOR+XRMCM-XROCM        
         ENDIF
      ENDIF    
      XARC = XAR
      YARC = YAR

      write(*,*) 'computing the fields...'
! 
! 
!-- BERECHNEN DER Z-WERTE FUER EIN RASTER MIT JE NXM PUNKTEN IN
!   X-RICHTUNG UND NYM PUNKTEN IN Y-RICHTUNG:
!   THETA WIRD EIN INTEGER NTHETA ZUGEORDNET UNTER DEM PLM(THETA)
!   ABGESPEICHERT WIRD, NMTHETA IST DIE ANZAHL DER BENOETIGTEN THETA.
! 
      IF( constantCoordinate.EQ.'T' ) THEN
         NMTHETA = 1
         THETA(NMTHETA) = DBLE(XC)
      ELSEIF( constantCoordinate.EQ.'P' ) THEN
         PHI = DBLE(XC)
      ELSEIF( constantCoordinate.EQ.'R' ) THEN
         R = DBLE(XC)      
      ENDIF
      XD = (XMAX-XMIN)/(NMX-1)
      YD = (YMAX-YMIN)/(NMY-1)
      IF( constantCoordinate.NE.'T' ) THEN
         NMTHETA = NMY
         DO 100 I = 1,NMTHETA
 100        THETA(I) = DBLE(YMIN+(I-1)*YD)
      ENDIF
! 
!-- BESTIMMUNG DER PLM(THETA) , ABSPEICHERUNG:
      CALL STOREPLM(THETA,NMTHETA)
! 
      ZMIN = 1.E10
      ZMAX = -1.E10
      DO 2000 I = 1,NMX
               X = XMIN+(I-1)*XD
         DO 1000 J = 1,NMY
            Y = YMIN+(J-1)*YD
            IF( constantCoordinate.EQ.'T' ) THEN
               R = DBLE(X)
               PHI = DBLE(Y)
               NTHETA = 1
            ELSEIF( constantCoordinate.EQ.'P' ) THEN
               R = DBLE(X)
               NTHETA = J
            ELSEIF( constantCoordinate.EQ.'R' ) THEN
               PHI = DBLE(X)
               NTHETA = J
            ENDIF
!cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
! IDL
!cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
            if( cc.eq.'T' ) then
               XIDL(I,J) = R*COS(pi*PHI/180.d0)
               YIDL(I,J) = R*SIN(pi*PHI/180.d0)
                on_a_sphere = 0 
            elseif( cc.eq.'P' ) then
               XIDL(I,J) = R*COS(pi*(THETA(J)-90.d0)/180.d0)
               YIDL(I,J) = R*SIN(pi*(THETA(J)-90.d0)/180.d0)
                on_a_sphere = 0  
            elseif( cc.eq.'R' ) then 
!               print*, PHI, THETA(NTHETA)
               on_a_sphere = 1
            else
                on_a_sphere = 0  
               write(*,*) 'wrong constant variable: ',cc
               stop
            endif
            
            
! 
!-------- R,PHI UND THETA SIND DIE KUGELKOORDINATEN:
            IF( CF.EQ.'VS' .OR. CF.EQ.'BS' .OR. CF.EQ.'JS' ) THEN
               IF(  constantCoordinate.EQ.'T' ) THEN
                  Z(I,J) = REAL(FT(DX,CF,R,PHI,NTHETA,TIME,DC))
               ELSEIF( constantCoordinate.EQ.'P' ) THEN
                  Z(I,J) = REAL(FP(DX,CF,R,PHI,NTHETA,TIME,DC))
               ELSEIF( constantCoordinate.EQ.'R' ) THEN
                  Z(I,J) = REAL(FR(DX,CF,R,PHI,NTHETA,TIME,DC))
               ENDIF
            ELSEIF( CF.EQ.'VR' .OR. CF.EQ.'BR' ) THEN
               Z(I,J) = REAL(RF(DX,CF,R,PHI,NTHETA,TIME,DC))
            ELSEIF( CF.EQ.'TE' ) THEN
               Z(I,J) = REAL(TEMP(DX,CF,R,PHI,NTHETA,TIME,DC))
            ELSEIF( CF.EQ.'ZF' ) THEN
               Z(I,J) = REAL(FZONAL(DX,R,NTHETA,TIME))
            ELSEIF( CF.EQ.'MF' ) THEN
               Z(I,J) = REAL(DMERI(DX,R,NTHETA,TIME))
            ELSEIF( CF.EQ.'MT' ) THEN
               Z(I,J) = REAL(DMTOR(DX,R,NTHETA,TIME))
            ELSEIF( CF.EQ.'MP' .OR. CF.EQ.'MJ' ) THEN
               Z(I,J) = REAL(DMPJ(DX,CF,R,NTHETA,TIME))
            ELSEIF( CF.EQ.'BT' ) THEN
               Z(I,J) = REAL(DBT(DX,R,PHI,NTHETA,TIME,DC))
            ELSEIF( CF.EQ.'MC' ) THEN
               Z(I,J) = REAL(DMC(DX,R,NTHETA,TIME))
            ELSEIF( CF.EQ.'TT' ) THEN
               Z(I,J) = REAL(TT(DX,CF,R,PHI,NTHETA,TIME,DC))
            ELSEIF( CF.EQ.'UP' ) THEN
               Z(I,J) = REAL(UP(DX,CF,R,PHI,NTHETA,TIME,DC))
            ELSEIF( CF.EQ.'NU' ) THEN
               Z(I,J) = REAL(FNU(DX,CF,R,PHI,NTHETA,TIME,DC))
            ELSE
               WRITE(*,*) 'WRONG INPUT OF CF.'
               STOP
            ENDIF
                  IF( Z(I,J).GT.ZMAX ) ZMAX = Z(I,J)
                  IF( Z(I,J).LT.ZMIN ) ZMIN = Z(I,J)
1000     CONTINUE
2000  CONTINUE
! 

      ZAMAX = MAX(ABS(ZMIN),ABS(ZMAX))
      ZNULL = 1.E-11*ZAMAX
      ZNULLM = 1.E-11
      ZANULL = 1.E-13
      ZSCALE = 1.E0
! 
      IF( ZD.GT.0.E0 ) THEN
         IF( ZAMAX.LT.ZANULL ) THEN
            WRITE(14,*) 'ZMAX AND ZMIN CLOSE TO ZERO: ',ZMAX,ZMIN
            WRITE(14,*) 'NO PLOT POSSIBLE.'
            GOTO 9000
         ELSEIF( ZNULL.LE.ZNULLM ) THEN
            ZSCALE = 1.E0/ZNULLM
            WRITE(14,*) 'SCALED BY ',ZSCALE
            ZMIN = ZSCALE*ZMIN
            ZMAX = ZSCALE*ZMAX
            ZNULL = ZSCALE*ZNULL
            DO 2100 IX = 1,NMX
            DO 2100 IY = 1,NMY
2100        Z(IX,IY) = ZSCALE*Z(IX,IY)
         ENDIF
      ELSEIF( ZD.LT.0.E0 ) THEN 
         IF( NCPLOT.GT.NSUBP ) THEN
            NZD = MOD(NCPLOT,NSUBP)
            IF( NZD.EQ.0 ) NZD = NSUBP
            ZD = ZSCALE*ZDS(NZD)
            contourDistanceOrNumber = 0
         ELSE
            ZD = ZSCALE*ABS(ZD)
         ENDIF
      ENDIF
      IF( contourDistanceOrNumber.EQ.1 ) THEN
         NCL = AINT(ZD+0.1E0)
         IF( ZMIN.GT.-ZNULL .OR. ZMAX.LT.ZNULL ) THEN
            ZD = ((ZMAX-ZMIN)-ZNULL)/(NCL-1)
         ELSE
            ZD = (MAX(ABS(ZMIN),ABS(ZMAX))-ZNULL)/(NCL-1)
         ENDIF
         ZD = ZD-ZD/100
      ELSEIF( contourDistanceOrNumber.EQ.0 ) THEN
         IF( ZD.GT.ABS(ZMAX) .AND. ZD.GT.ABS(ZMIN) ) THEN
            WRITE(*,*) 'TOO LARGE ZD , ZMIN,ZMAX ARE ONLY: ',ZMIN,ZMAX
            STOP
         ENDIF
         IF( ZMIN.GT.-ZNULL .OR. ZMAX.LT.ZNULL ) THEN
            NCL = AINT( ABS(ZMAX-ZMIN)/ZD+0.1E0 )+1
         ELSE
            NCL = AINT(MAX(ABS(ZMAX),ABS(ZMIN))/ZD+0.1E0)+1
         ENDIF
      ENDIF
      IF( NCPLOT.LE.NSUBP ) ZDS(NCPLOT) = ZD/ZSCALE
      IF( ZMIN.GT.-ZNULL .OR. ZMAX.LT.ZNULL ) THEN
         ZMINP = ZMIN
         ZMAXP = ZMAX
      ELSE
         ZMINP = ZD*AINT( ZMIN/ZD )-ZNULL
         ZMAXP = ZD*AINT( ZMAX/ZD )+ZNULL
      ENDIF
      IF( ABS(ZMINP).LT.ZNULL ) ZMINP = ZNULL
      IF( ABS(ZMAXP).LT.ZNULL ) ZMAXP = ZNULL
      WRITE(14,*) 'DIFFERENCE BETWEEN CONTOURLINES ZD =  ',ZD
      WRITE(14,*) 'NUMBER OF CONTOURLINES NCL =  ',NCL
      WRITE(14,*) 'ZMAX,ZMIN =  ',ZMAX,ZMIN
      WRITE(14,*) 'ZMAXP,ZMINP =  ',ZMAXP,ZMINP
! 
      TENSN = 0.D0
! 
!     IF( constantCoordinate.EQ.'T' .OR. constantCoordinate.EQ.'P' ) THEN
! 
!-- NEUE FESTLEGUNG VON URSPRUNG UND PLOTGEBIET:
!        CALL PHYSOR(XOR,YOR)
!        CALL AREA2D(XAR,YAR)
! 
!-- ATRANS INFORMIERT DISSPLA, DASS EINE KOORDINATENTRANSFORMATION,
!   GEGEBEN DURCH DIE SUBROUTINE TRANS, VORNENOMMEN WERDEN SOLL,
!   HIER VON DEN LINEAREN X,Y-ACHSEN ZU POLAREN KOORDINATEN (RADIUS,WINKEL).
!        CALL ATRANS
! 
!-- GRAF INITIALISIERT X UND Y ACHSE:
!        CALL GRAF(XMIN,XD,XMAX,YMIN,YD,YMAX)
! 
!     ELSEIF( constantCoordinate.EQ.'R' ) THEN
! 
!-- AUFRUFEN DEN PROJEKTION VON KUGEL AUF KREIS:
!        CALL PROJCT('ORTH')
! 
!-- FESTLEGUNG DES POLS:
!        CALL MAPOLE(XP,YP)
! 
!-- NEUE FESTLEGUNG VON URSPRUNG UND PLOTGEBIET (MUSS NACH PROJCT UND
!   MAPOLE ERFOLGEN:
!        CALL PHYSOR(XOR,YOR)
!        CALL AREA2D(XAR,YAR)
! 
!-- ZEICHNEN DER GROSSKREISE:
!        CALL MAPMDE('GREAT')
! 
!-- INITIALISIERUNG DER ACHSEN:
!        CALL MAPGR(XP-180.E0,30.E0,XP+180.E0,YP-90.E0,30.E0,YP+90.E0)
! 
!-- FESTLEGUNG DES GITTERS , HIER NUR GROSSKREISE:
!        CALL THKCRV(0.002E0)
!        CALL THKFRM(0.005E0)
!        CALL GRID(0,3)
!        CALL RESET('THKCRV')
! 
!     ENDIF
! 
!-- ZEICHNEN DER KONTOURLINIEN:
! 
!     IF( ZMINP.LE.-ZD ) THEN
! 
!        WRITE(14,*) 'ZLEVEL < 0.'
! 
!-- FESTLEGUNG DES WERTEBEREICHS:
!        IF( ZMAXP.LT.ZNULL ) THEN
!           CALL ZRANGE(ZMAXP,ZMINP)
!        ELSE
!           CALL ZRANGE(ZMINP,-ZD)
!        ENDIF
! 
!-- PRODUKTION DER CONTOURLINIEN:
!        CALL CONMAK(Z,NMX,NMY,ZD)
! 
!-- FESTLEGUNG WIE DIESE ZU ZEICHNEN SIND IN DER SUBROUTINE MYCNLN:
!        CALL CONLIN(0,'MYCNLN','NOLABELS',3,1)
! 
!-- SPLINE INTERPOLATION:
!        CALL RASPLN(TENSN)
! 
!-- ZEICHNEN DER LINIEN:
!        CALL CONTUR(1,'NOLABELS','DRAW')
! 
!     ENDIF
! 
!-- DITO FUER Z>0 : 
!     IF( ZMAXP.GE.ZNULL ) THEN
! 
!        WRITE(14,*) 'ZLEVEL > 0.'
! 
!        IF( ZMINP.GT.-ZNULL ) THEN
!           CALL ZRANGE(ZMINP,ZMAXP)
!        ELSE
!           ZMAXAP = MIN(ZMAX,ZMAXP+ZNULL)
!           CALL ZRANGE(ZNULL,ZMAXAP)
!        ENDIF
!        CALL CONMAK(Z,NMX,NMY,ZD)
!        CALL CONLIN(0,'MYCNLN','NOLABELS',3,1)
!        CALL RASPLN(TENSN)
!        CALL CONTUR(1,'NOLABELS','DRAW')
!     ENDIF         
! 
9000  CONTINUE
!     CALL RESET('ATRANS')
!     CALL RESET('MAPMDE')
!     CALL RESET('MAPOLE')
!     CALL RESET('PROJCT')
!     CALL RESET('BLNKS')
!     CALL RESET('DOT')
!     CALL RESET('DASH')
!     CALL RESET('THKCRV')
!     CALL LINEAR
! 
!     WRITE(14,*)
! 
!     CALL ENDGR(0)
! 
!cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
! IDL
!cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      write(*,*) 'writing files idl.z, idl.x, idl.y ...'
      filez = 'idl.z'
      filex = 'idl.x'
      filey = 'idl.y'
!     write(filez(6:7),'(1I1)') NPLOT
!     write(filex(6:7),'(1I1)') NPLOT
!     write(filey(6:7),'(1I1)') NPLOT
      open(21,file = filez,STATUS =  'UNKNOWN')
      open(22,file = filex,STATUS =  'UNKNOWN')
      open(23,file = filey,STATUS =  'UNKNOWN')

      if (on_a_sphere.eq.1) then 
 
      DO 2001 I = 1,NMX  
         X = XMIN+(I-1)*XD
!  phi = x  
         write(22,*)   DBLE(X) + 180.

 2001 CONTINUE  

      DO 1001 J = 1,NMY  
!         Y = YMIN+(J-1)*YD  
!  theta = THETA(J) 
         write(23,*)  THETA(J)-90.  
 1001    CONTINUE  
         do i = 1,nmx 
            do j = 1,nmy 
               write(21,*) z(i,j) 
            enddo 
         enddo 
      ELSE
         do i = 1,nmx
            do j = 1,nmy
               write(21,*) z(i,j)
               write(22,*) xidl(i,j)
               write(23,*) yidl(i,j)
            enddo
         enddo
      ENDIF
      
9999  CONTINUE
      RETURN
      END
! 
!---------------------------------------------------------------------
! 
! 
!************************************************************************
      FUNCTION FT(X,whatToPlot,R,PHI,NTHETA,TIME,DC)
!************************************************************************
!   Stromfunktion fuer theta = konstant:
!      F_theta = r dphi v             (Busse: r/sin(th) d/dphi v )
!   Fuer den elektrischen Strom: 
!              F_theta = r dphi g
! 
!     optimized for K = 0.
! 
!------------------------------------------------------------------------
      IMPLICIT REAL*8(A-H,O-Z)
      PARAMETER (NM = 5500,NAM = 400)
      PARAMETER (PI = 3.14159265358979D0)
      CHARACTER*1 CF
      CHARACTER*2 CRR,whatToPlot
! 
      DIMENSION X(*)
! 
      COMMON/DIM/NDV,NDW,NDT,NDH,NDG,ND
      COMMON/QNU/NMC,L(NM),M(NM),N(NM),K(NM),CF(NM),CRR(NM)
      COMMON/PARI/RA,TA,PR,PM,ETA,C,OM,FTW,FTG,MF
!cc   COMMON/NPARI/M0,NE,NTV,NTH,LTV,LTH,KTV,KTH,LD
      COMMON/NPARI/M0,NTV,NTH,LTV,LTH,KTV,KTH,LEV,LRB,LD
      COMMON/AB/A(NAM),B(NAM),NAMC
! 
      IF( NAM.NE.NAMC ) THEN
         WRITE(*,*) 'WRONG DIMENSION NAM IN FT.'
         STOP
      ENDIF
      IF( NM.NE.NMC ) THEN
         WRITE(*,*) 'WRONG DIMENSION NM IN FT.'
         STOP
      ENDIF

      PPHI = PHI*PI/180.D0
      RI = ETA/(1.D0-ETA)
      RO = RI+1.D0
      FT = 0.D0
      IF( whatToPlot.EQ.'VS' ) THEN
         NDOMIN = 1
         NDOMAX = NDV
      ELSEIF( whatToPlot.EQ.'BS' ) THEN
         NDOMIN = NDV+NDW+NDT+1
         NDOMAX = NDV+NDW+NDT+NDH
      ELSEIF( whatToPlot.EQ.'JS' ) THEN
         NDOMIN = NDV+NDW+NDT+NDH+1
         NDOMAX = NDV+NDW+NDT+NDH+NDG
      ELSE
         WRITE(*,*) 
     &    'WRONG whatToPlot IN FT, SHOULD BE VS OR BS OR JS BUT IS: ',whatToPlot
         STOP
      ENDIF
      DO 1000 I = NDOMIN,NDOMAX
         IF( .NOT.( ( CF(I).EQ.'V' .AND. whatToPlot.EQ.'VS' ) .OR.
     &              ( CF(I).EQ.'H' .AND. whatToPlot.EQ.'BS' ) .OR.       
     &              ( CF(I).EQ.'G' .AND. whatToPlot.EQ.'JS' )  )  ) THEN
            WRITE(*,*) 
     &      'WRONG CF IN FT, SHOULD BE V OR H OR G BUT IS: ',CF(I)
            STOP
         ENDIF
         IF( M(I).EQ.0 ) THEN
            EPSM = 1.D0
         ELSE
            EPSM = 2.D0
         ENDIF
         IF( K(I).EQ.0 ) THEN
            EPSK = 1.D0
         ELSE
            EPSK = 2.D0
         ENDIF
         FTT = EPSM*EPSK*M(I)*PLMS(L(I),M(I),NTHETA)*R
         IF( CF(I).EQ.'V' .OR. CF(I).EQ.'G' ) THEN
            FTT = FTT*DSIN( N(I)*PI*(R-RI) )
         ELSEIF( CF(I).EQ.'H' ) THEN
            NR = NAB(L(I),N(I))
            IF( R.LE.RO ) THEN
               IF( A(NR).EQ.0.D0 .OR. B(NR).EQ.0.D0 ) THEN
                  WRITE(*,*) 'ALPHA AND BETA NOT CALCULATED.'
                  STOP  
               ENDIF
               FTT = -FTT*DCOS( A(NR)*R-B(NR) )
            ELSE
               IF( A(NR).EQ.0.D0 .OR. B(NR).EQ.0.D0 ) THEN
                  WRITE(*,*) 'ALPHA AND BETA NOT CALCULATED.'
                  STOP  
               ENDIF
               FTT = -FTT * (RO/R)**(L(I)+1) * DCOS( A(NR)*RO-B(NR) )
            ENDIF
         ENDIF
! 
        if(K(I).EQ.0) then
         IF( CRR(I).EQ.'RR' ) THEN
            FTT = -FTT * X(I) * DSIN( M(I)*(PPHI-DC*TIME) )
         ELSEIF( CRR(I).EQ.'IR' ) THEN
            FTT = -FTT * X(I) * DCOS( M(I)*(PPHI-DC*TIME) )
         ELSE
            FTT = 0.D0
         ENDIF
        else
         IF( CRR(I).EQ.'RR' ) THEN
            FTT = -FTT * X(I) * DSIN( M(I)*(PPHI-DC*TIME) ) * 
     *                                                DCOS(K(I)*OM*TIME)
         ELSEIF( CRR(I).EQ.'IR' ) THEN
            FTT = -FTT * X(I) * DCOS( M(I)*(PPHI-DC*TIME) ) * 
     *                                                DCOS(K(I)*OM*TIME)
         ELSEIF( CRR(I).EQ.'RI' ) THEN
            FTT = FTT * X(I) * DSIN( M(I)*(PPHI-DC*TIME) ) * 
     *                                                DSIN(K(I)*OM*TIME)
         ELSEIF( CRR(I).EQ.'II' ) THEN
            FTT = FTT * X(I) * DCOS( M(I)*(PPHI-DC*TIME) ) * 
     *                                                DSIN(K(I)*OM*TIME)
         ENDIF
        endif
         FT = FT-FTT
1000  CONTINUE
! 
      RETURN
      END
! 
!---------------------------------------------------------------------
! 
! 
!************************************************************************
      FUNCTION FP(X,whatToPlot,R,PHI,NTHETA,TIME,DC)
!************************************************************************
! Stromfunktion fuer phi = konstant: 
!              F_phi = r sin(theta) dtheta v  (like Busse)
! Fuer den elektrischen Strom: 
!              F_phi = r sin(theta) dtheta g
! 
!     optimized for K = 0.
! 
!------------------------------------------------------------------------
      IMPLICIT REAL*8(A-H,O-Z)
      PARAMETER (NM = 5500,NAM = 400)
      PARAMETER (PI = 3.14159265358979D0)
      CHARACTER*1 CF
      CHARACTER*2 CRR,whatToPlot
! 
      DIMENSION X(*)
! 
      COMMON/DIM/NDV,NDW,NDT,NDH,NDG,ND
      COMMON/QNU/NMC,L(NM),M(NM),N(NM),K(NM),CF(NM),CRR(NM)
      COMMON/PARI/RA,TA,PR,PM,ETA,C,OM,FTW,FTG,MF
!cc   COMMON/NPARI/M0,NE,NTV,NTH,LTV,LTH,KTV,KTH,LD
      COMMON/NPARI/M0,NTV,NTH,LTV,LTH,KTV,KTH,LEV,LRB,LD
      COMMON/AB/A(NAM),B(NAM),NAMC
! 
      IF( NM.NE.NMC ) THEN
         WRITE(*,*) 'WRONG DIMENSION NM IN FP.'
         STOP
      ENDIF
      IF( NAM.NE.NAMC ) THEN
         WRITE(*,*) 'WRONG DIMENSION NAM IN FP.'
         STOP
      ENDIF
! 
      PPHI = PHI*PI/180.D0
      RI = ETA/(1.D0-ETA)
      RO = RI+1.D0
      FP = 0.D0
      IF( whatToPlot.EQ.'VS' ) THEN
         NDOMIN = 1
         NDOMAX = NDV

      ELSEIF( whatToPlot.EQ.'BS' ) THEN
         NDOMIN = NDV+NDW+NDT+1
         NDOMAX = NDV+NDW+NDT+NDH
      ELSEIF( whatToPlot.EQ.'JS' ) THEN
         NDOMIN = NDV+NDW+NDT+NDH+1
         NDOMAX = NDV+NDW+NDT+NDH+NDG
      ELSE
         WRITE(*,*) 
     &   'WRONG whatToPlot IN FP, SHOULD BE VS OR BS OR JS BUT IS: ',whatToPlot
         STOP
      ENDIF
      DO 1000 I = NDOMIN,NDOMAX
         IF( .NOT.( ( CF(I).EQ.'V' .AND. whatToPlot.EQ.'VS' ) .OR.
     &              ( CF(I).EQ.'H' .AND. whatToPlot.EQ.'BS' ) .OR.      
     &              ( CF(I).EQ.'G' .AND. whatToPlot.EQ.'JS' )  )  ) THEN
            WRITE(*,*) 
     &       'WRONG CF IN FP, SHOULD BE V OR H OR G BUT IS: ',CF(I)
            STOP
         ENDIF
         IF( M(I).EQ.0 ) THEN
            EPSM = 1.D0
         ELSE
            EPSM = 2.D0
         ENDIF
         IF( K(I).EQ.0 ) THEN
            EPSK = 1.D0
         ELSE
            EPSK = 2.D0
         ENDIF
         FPT = EPSM*EPSK*R * (
     &            DBLE(L(I))*DSQRT( DBLE( (L(I)-M(I)+1)*(L(I)+M(I)+1) ) /
     /    DBLE( (2*L(I)+1)*(2*L(I)+3) ) ) * PLMS(L(I)+1,M(I),NTHETA) -
     -            DBLE(L(I)+1)*DSQRT( DBLE( (L(I)-M(I))*(L(I)+M(I)) ) /
     /    DBLE( (2*L(I)+1)*(2*L(I)-1) ) ) * PLMS(L(I)-1,M(I),NTHETA)  )
         IF( CF(I).EQ.'V' .OR. CF(I).EQ.'G' ) THEN
            FPT = FPT*DSIN( N(I)*PI*(R-RI) )
         ELSEIF( CF(I).EQ.'H' ) THEN
            NR = NAB(L(I),N(I))
            IF( R.LE.RO ) THEN
               IF( A(NR).EQ.0.D0 .OR. B(NR).EQ.0.D0 ) THEN
                  WRITE(*,*) 'ALPHA AND BETA NOT CALCULATED.'
                  STOP  
               ENDIF
               FPT = FPT*DCOS( A(NR)*R-B(NR) )
            ELSE
               IF( A(NR).EQ.0.D0 .OR. B(NR).EQ.0.D0 ) THEN
                  WRITE(*,*) 'ALPHA AND BETA NOT CALCULATED.'
                  STOP  
               ENDIF
               FPT = FPT * (RO/R)**(L(I)+1) * DCOS( A(NR)*RO-B(NR) )
            ENDIF
         ENDIF
! 
        if(K(I).EQ.0) then
         IF( CRR(I).EQ.'RR' ) THEN
            FPT = FPT * X(I) * DCOS( M(I)*(PPHI-DC*TIME) )
         ELSEIF( CRR(I).EQ.'IR' ) THEN
            FPT = -FPT * X(I) * DSIN( M(I)*(PPHI-DC*TIME) )
         ELSE
            FPT = 0.D0
         ENDIF
        else
         IF( CRR(I).EQ.'RR' ) THEN
            FPT = FPT * X(I) * DCOS( M(I)*(PPHI-DC*TIME) ) * 
     *                                                DCOS(K(I)*OM*TIME)
         ELSEIF( CRR(I).EQ.'IR' ) THEN
            FPT = -FPT * X(I) * DSIN( M(I)*(PPHI-DC*TIME) ) * 
     *                                                DCOS(K(I)*OM*TIME)
         ELSEIF( CRR(I).EQ.'RI' ) THEN
            FPT = -FPT * X(I) * DCOS( M(I)*(PPHI-DC*TIME) ) * 
     *                                                DSIN(K(I)*OM*TIME)
         ELSEIF( CRR(I).EQ.'II' ) THEN
            FPT = FPT * X(I) * DSIN( M(I)*(PPHI-DC*TIME) ) * 
     *                                                DSIN(K(I)*OM*TIME)
         ENDIF
        endif
         FP = FP+FPT
1000  CONTINUE
! 
      RETURN
      END
! 
!---------------------------------------------------------------------      
! 
! 
!************************************************************************
      FUNCTION FR(X,whatToPlot,R,PHI,NTHETA,TIME,DC)
!************************************************************************
!   Stromfunktion fuer r = konstant:
!                     F_r = w      (like Busse, Hirsching: rw )
!   Stromfunktion fuer r = konstant des elektrischen Stroms: 
!                     F_r = - laplace h
! 
!     optimized for K = 0.
! 
!------------------------------------------------------------------------
      IMPLICIT REAL*8(A-H,O-Z)
      PARAMETER (NM = 5500,NAM = 400)
      PARAMETER (PI = 3.14159265358979D0)
      CHARACTER*1 CF
      CHARACTER*2 CRR,whatToPlot
! 
      DIMENSION X(*)
! 
      COMMON/DIM/NDV,NDW,NDT,NDH,NDG,ND
      COMMON/QNU/NMC,L(NM),M(NM),N(NM),K(NM),CF(NM),CRR(NM)
      COMMON/PARI/RA,TA,PR,PM,ETA,C,OM,FTW,FTG,MF
!cc   COMMON/NPARI/M0,NE,NTV,NTH,LTV,LTH,KTV,KTH,LD
      COMMON/NPARI/M0,NTV,NTH,LTV,LTH,KTV,KTH,LEV,LRB,LD
      COMMON/AB/A(NAM),B(NAM),NAMC
! 
      IF( NM.NE.NMC ) THEN
         WRITE(*,*) 'WRONG DIMENSION NM IN FR.'
         STOP
      ENDIF
! 
      PPHI = PHI*PI/180.D0
      RI = ETA/(1.D0-ETA)
      FR = 0.D0
      IF( whatToPlot.EQ.'VS' ) THEN
         NDOMIN = NDV+1
         NDOMAX = NDV+NDW
      ELSEIF( whatToPlot.EQ.'JS' ) THEN
         NDOMIN = NDV+NDW+NDT+1
         NDOMAX = NDV+NDW+NDT+NDH
      ELSEIF( whatToPlot.EQ.'BS' ) THEN
         NDOMIN = NDV+NDW+NDT+NDH+1
         NDOMAX = NDV+NDW+NDT+NDH+NDG
      ELSE
         WRITE(*,*) 
     &   'WRONG whatToPlot IN FR, SHOULD BE VS OR BS OR JS BUT IS: ',whatToPlot
         STOP
      ENDIF
      DO 1000 I = NDOMIN,NDOMAX
         IF(  .NOT.( ( whatToPlot.EQ.'VS' .AND. CF(I).EQ.'W' ) .OR.
     &               ( whatToPlot.EQ.'BS' .AND. CF(I).EQ.'G' ) .OR.       
     &               ( whatToPlot.EQ.'JS' .AND. CF(I).EQ.'H' )  )  ) THEN
            WRITE(*,*) 
     &       'WRONG CF IN FR, SHOULD BE W OR G OR H BUT IS: ',CF(I)
            STOP
         ENDIF
         IF( M(I).EQ.0 ) THEN
            EPSM = 1.D0
         ELSE
            EPSM = 2.D0
         ENDIF
         IF( K(I).EQ.0 ) THEN
            EPSK = 1.D0
         ELSE
            EPSK = 2.D0
         ENDIF
         FRT = EPSM*EPSK*PLMS(L(I),M(I),NTHETA)
         IF( CF(I).EQ.'W' ) THEN
            FRT = FRT*R*DCOS( (N(I)-1)*PI*(R-RI) )
         ELSEIF( CF(I).EQ.'G' ) THEN
            FRT = FRT*DSIN( N(I)*PI*(R-RI) )
         ELSEIF( CF(I).EQ.'H' ) THEN
            NR = NAB(L(I),N(I))
            IF( A(NR).EQ.0.D0 .OR. B(NR).EQ.0.D0 ) THEN
               WRITE(*,*) 'ALPHA AND BETA NOT CALCULATED.'
               STOP  
            ENDIF
            FRT = FRT*(
     &           ( A(NR)*A(NR)+DBLE(L(I)*(L(I)+1))/(R*R) ) *
     *                                DCOS( A(NR)*R-B(NR) ) +
     +                    2*A(NR)/R * DSIN( A(NR)*R-B(NR) )  )
         ENDIF
        if(K(I).EQ.0) then
         IF( CRR(I).EQ.'RR' ) THEN
            FRT = FRT * X(I) * DCOS( M(I)*(PPHI-DC*TIME) )
         ELSEIF( CRR(I).EQ.'IR' ) THEN
            FRT = -FRT * X(I) * DSIN( M(I)*(PPHI-DC*TIME) )
         ELSE
            FRT = 0.D0
         ENDIF
        else
         IF( CRR(I).EQ.'RR' ) THEN
            FRT = FRT * X(I) * DCOS( M(I)*(PPHI-DC*TIME) ) * 
     *                                                DCOS(K(I)*OM*TIME)
         ELSEIF( CRR(I).EQ.'IR' ) THEN
            FRT = -FRT * X(I) * DSIN( M(I)*(PPHI-DC*TIME) ) * 
     *                                                DCOS(K(I)*OM*TIME)
         ELSEIF( CRR(I).EQ.'RI' ) THEN
            FRT = -FRT * X(I) * DCOS( M(I)*(PPHI-DC*TIME) ) * 
     *                                                DSIN(K(I)*OM*TIME)
         ELSEIF( CRR(I).EQ.'II' ) THEN
            FRT = FRT * X(I) * DSIN( M(I)*(PPHI-DC*TIME) ) * 
     *                                                DSIN(K(I)*OM*TIME)
         ENDIF
        endif
         FR = FR+FRT
1000  CONTINUE
! 
      RETURN
      END
! 
!---------------------------------------------------------------------
! 
! 
!************************************************************************
      FUNCTION RF(X,whatToPlot,R,PHI,NTHETA,TIME,DC)
!************************************************************************
! Radiales Geschw.feld: U_r = L_2/r v
! 
!     optimized for K = 0.
! 
!------------------------------------------------------------------------
      IMPLICIT REAL*8(A-H,O-Z)
      PARAMETER (NM = 5500,NAM = 400)
      PARAMETER (PI = 3.14159265358979D0)
      CHARACTER*1 CF
      CHARACTER*2 CRR,whatToPlot
! 
      DIMENSION X(*)
! 
      COMMON/DIM/NDV,NDW,NDT,NDH,NDG,ND
      COMMON/QNU/NMC,L(NM),M(NM),N(NM),K(NM),CF(NM),CRR(NM)
      COMMON/PARI/RA,TA,PR,PM,ETA,C,OM,FTW,FTG,MF
!cc   COMMON/NPARI/M0,NE,NTV,NTH,LTV,LTH,KTV,KTH,LD
      COMMON/NPARI/M0,NTV,NTH,LTV,LTH,KTV,KTH,LEV,LRB,LD
      COMMON/AB/A(NAM),B(NAM),NAMC
! 
      IF( NM.NE.NMC ) THEN
         WRITE(*,*) 'WRONG DIMENSION NM IN RF.'
         STOP
      ENDIF
      IF( NAM.NE.NAMC ) THEN
         WRITE(*,*) 'WRONG DIMENSION NAM IN RF.'
         STOP
      ENDIF
! 
      PPHI = PHI*PI/180.D0
      RI = ETA/(1.D0-ETA)
      RF = 0.D0
      IF( whatToPlot.EQ.'VR' ) THEN
         NDOMIN = 1
         NDOMAX = NDV
      ELSEIF( whatToPlot.EQ.'BR' ) THEN
         NDOMIN = NDV+NDW+NDT+1
         NDOMAX = NDV+NDW+NDT+NDH
      ELSE
         WRITE(*,*) 'WRONG whatToPlot IN RF, SHOULD BE V OR H BUT IS: ',whatToPlot
         STOP
      ENDIF
      DO 1000 I = NDOMIN,NDOMAX
         IF( .NOT.( ( CF(I).EQ.'V' .AND. whatToPlot.EQ.'VR' ) .OR.
     &              ( CF(I).EQ.'H' .AND. whatToPlot.EQ.'BR' )  ) ) THEN
            WRITE(*,*) 'WRONG CF IN RF, SHOULD BE V OR H BUT IS: ',
     &                                                  CF(I)
            STOP
         ENDIF
         IF( M(I).EQ.0 ) THEN
            EPSM = 1.D0
         ELSE
            EPSM = 2.D0
         ENDIF
         IF( K(I).EQ.0 ) THEN
            EPSK = 1.D0
         ELSE
            EPSK = 2.D0
         ENDIF
         RFT = EPSM*EPSK*L(I)*(L(I)+1) * PLMS(L(I),M(I),NTHETA) / R 
         IF( CF(I).EQ.'V' ) THEN
            RFT = RFT*DSIN( N(I)*PI*(R-RI) )
         ELSEIF( CF(I).EQ.'H' ) THEN
            NR = NAB(L(I),N(I))
            IF( A(NR).EQ.0.D0 .OR. B(NR).EQ.0.D0 ) THEN
               WRITE(*,*) 'ALPHA AND BETA NOT CALCULATED.'
               STOP  
            ENDIF
            RFT = RFT*DCOS( A(NR)*R-B(NR) )
         ENDIF
! 
        if(K(I).EQ.0) then
         IF( CRR(I).EQ.'RR' ) THEN
            RFT = RFT * X(I) * DCOS( M(I)*(PPHI-DC*TIME) )
         ELSEIF( CRR(I).EQ.'IR' ) THEN
            RFT = -RFT * X(I) * DSIN( M(I)*(PPHI-DC*TIME) )
         ELSE
            RFT = 0.D0
         ENDIF
        else
         IF( CRR(I).EQ.'RR' ) THEN
            RFT = RFT * X(I) * DCOS( M(I)*(PPHI-DC*TIME) ) * 
     *                                                DCOS(K(I)*OM*TIME)
         ELSEIF( CRR(I).EQ.'IR' ) THEN
            RFT = -RFT * X(I) * DSIN( M(I)*(PPHI-DC*TIME) ) * 
     *                                                DCOS(K(I)*OM*TIME)
         ELSEIF( CRR(I).EQ.'RI' ) THEN
            RFT = -RFT * X(I) * DCOS( M(I)*(PPHI-DC*TIME) ) * 
     *                                                DSIN(K(I)*OM*TIME)
         ELSEIF( CRR(I).EQ.'II' ) THEN
            RFT = RFT * X(I) * DSIN( M(I)*(PPHI-DC*TIME) ) * 
     *                                                DSIN(K(I)*OM*TIME)
         ENDIF
        endif
         RF = RF+RFT
1000  CONTINUE
! 
      RETURN
      END
! 
!---------------------------------------------------------------------      
! 
! 
!************************************************************************
      FUNCTION TEMP(X,whatToPlot,R,PHI,NTHETA,TIME,DC)
!************************************************************************
!   Temperaturfeld Theta ( =  Abweichung vom Grundzust.)
!   optimized for K = 0.
!------------------------------------------------------------------------
      IMPLICIT REAL*8(A-H,O-Z)
      PARAMETER (NM = 5500)
      PARAMETER (PI = 3.14159265358979D0)
      CHARACTER*1 CF
      CHARACTER*2 CRR,whatToPlot
! 
      DIMENSION X(*)
! 
      COMMON/DIM/NDV,NDW,NDT,NDH,NDG,ND
      COMMON/QNU/NMC,L(NM),M(NM),N(NM),K(NM),CF(NM),CRR(NM)
      COMMON/PARI/RA,TA,PR,PM,ETA,C,OM,FTW,FTG,MF
      COMMON/NPARI/M0,NTV,NTH,LTV,LTH,KTV,KTH,LEV,LRB,LD
      IF( NM.NE.NMC ) THEN
         WRITE(*,*) 'WRONG DIMENSION NM IN TEMP.'
         STOP
      ENDIF
! 
      TEMP = 0.D0
      PPHI = PHI*PI/180.D0
      RI = ETA/(1.D0-ETA)
      IF( whatToPlot.EQ.'TE' ) THEN
         NDOMIN = 1+NDV+NDW
         NDOMAX = NDV+NDW+NDT
      ELSE
         WRITE(*,*) 'WRONG whatToPlot IN TEMP, SHOULD BE TE BUT IS: ',whatToPlot
         STOP
      ENDIF
! 
      DO 1000 I = NDOMIN,NDOMAX
         IF( CF(I).NE.'T' ) THEN
            WRITE(*,*) 'WRONG CF IN TEMP, SHOULD BE T BUT IS: ',
     &                                                  CF(I)
            STOP
         ENDIF
         IF( M(I).EQ.0 ) THEN
            EPSM = 1.D0
         ELSE
            EPSM = 2.D0
         ENDIF
         IF( K(I).EQ.0 ) THEN
            EPSK = 1.D0
         ELSE
            EPSK = 2.D0
         ENDIF
         TEM = EPSM*EPSK*PLMS(L(I),M(I),NTHETA)*DSIN( N(I)*PI*(R-RI) )
! 
        if(K(I).EQ.0) then
         IF( CRR(I).EQ.'RR' ) THEN
            TEM = TEM * X(I) * DCOS( M(I)*(PPHI-DC*TIME) ) 
         ELSEIF( CRR(I).EQ.'IR' ) THEN
            TEM = -TEM * X(I) * DSIN( M(I)*(PPHI-DC*TIME) ) 
         ELSE
            TEM = 0.D0
         ENDIF
        else
         IF( CRR(I).EQ.'RR' ) THEN
            TEM = TEM * X(I) * DCOS( M(I)*(PPHI-DC*TIME) ) *
     *                                          DCOS(K(I)*OM*TIME)
         ELSEIF( CRR(I).EQ.'IR' ) THEN
            TEM = -TEM * X(I) * DSIN( M(I)*(PPHI-DC*TIME) ) *
     *                                          DCOS(K(I)*OM*TIME)
         ELSEIF( CRR(I).EQ.'RI' ) THEN
            TEM = -TEM * X(I) * DCOS( M(I)*(PPHI-DC*TIME) ) *
     *                                          DSIN(K(I)*OM*TIME)
         ELSEIF( CRR(I).EQ.'II' ) THEN
            TEM = TEM * X(I) * DSIN( M(I)*(PPHI-DC*TIME) ) *
     *                                          DSIN(K(I)*OM*TIME)
         ENDIF
        endif
         TEMP = TEMP+TEM
1000  CONTINUE
! 
      RETURN
      END
! 
!---------------------------------------------------------------------
! 
! 
!************************************************************************
      FUNCTION TT(X,whatToPlot,R,PHI,NTHETA,TIME,DC)
!     temperature field Theta + Ts
!     optimized for K = 0.
!************************************************************************
! 
!------------------------------------------------------------------------
      IMPLICIT REAL*8(A-H,O-Z)
      PARAMETER (NM = 5500)
      PARAMETER (PI = 3.14159265358979D0)
      CHARACTER*1 CF
      CHARACTER*2 CRR,whatToPlot
! 
      DIMENSION X(*)
! 
      COMMON/DIM/NDV,NDW,NDT,NDH,NDG,ND
      COMMON/QNU/NMC,L(NM),M(NM),N(NM),K(NM),CF(NM),CRR(NM)
      COMMON/PARI/RA,TA,PR,PM,ETA,C,OM,FTW,FTG,MF
      COMMON/NPARI/M0,NTV,NTH,LTV,LTH,KTV,KTH,LEV,LRB,LD
! 
      IF( NM.NE.NMC ) THEN
         WRITE(*,*) 'WRONG DIMENSION NM IN TT.'
         STOP
      ENDIF
! 
      PPHI = PHI*PI/180.D0
      RI = ETA/(1.D0-ETA)
      T = 0.D0
      IF( whatToPlot.EQ.'TT' ) THEN
         NDOMIN = NDV+NDW+1
         NDOMAX = NDV+NDW+NDT
      ELSE
         WRITE(*,*) 'WRONG whatToPlot IN TT, SHOULD TT BUT IS: ',whatToPlot
         STOP
      ENDIF
      DO 1000 I = NDOMIN,NDOMAX
         IF( CF(I).NE.'T' ) THEN
            WRITE(*,*) 'WRONG CF IN T, SHOULD BE T BUT IS: ',
     &                                                  CF(I)
            STOP
         ENDIF
         IF( M(I).EQ.0 ) THEN
            EPSM = 1.D0
         ELSE
            EPSM = 2.D0
         ENDIF
         IF( K(I).EQ.0 ) THEN
            EPSK = 1.D0
         ELSE
            EPSK = 2.D0
         ENDIF
         TT = EPSM*EPSK*PLMS(L(I),M(I),NTHETA)
         TT = TT*DSIN( N(I)*PI*(R-RI) )
! 
         IF(K(I).EQ.0) THEN
          IF( CRR(I).EQ.'RR' ) THEN
            TT = TT * X(I) * DCOS( M(I)*(PPHI-DC*TIME) )
          ELSEIF( CRR(I).EQ.'IR' ) THEN
            TT = -TT * X(I) * DSIN( M(I)*(PPHI-DC*TIME) )
          ELSEIF( CRR(I).EQ.'RI' ) THEN
            TT = 0.0D0
          ELSEIF( CRR(I).EQ.'II' ) THEN
            TT = 0.0D0
          ENDIF
         ELSE
          IF( CRR(I).EQ.'RR' ) THEN
            TT = TT * X(I) * DCOS( M(I)*(PPHI-DC*TIME) )  *
     *                                          DCOS(K(I)*OM*TIME)
          ELSEIF( CRR(I).EQ.'IR' ) THEN
            TT = -TT * X(I) * DSIN( M(I)*(PPHI-DC*TIME) ) *
     *                                          DCOS(K(I)*OM*TIME)
          ELSEIF( CRR(I).EQ.'RI' ) THEN
            TT = -TT * X(I) * DCOS( M(I)*(PPHI-DC*TIME) ) *
     *                                          DSIN(K(I)*OM*TIME)
          ELSEIF( CRR(I).EQ.'II' ) THEN
            TT = TT * X(I) * DSIN( M(I)*(PPHI-DC*TIME) ) *
     *                                          DSIN(K(I)*OM*TIME)
          ENDIF
         ENDIF
         T = T+TT
1000  CONTINUE
! 
!        add basic temperature field Ts:
         T = T - R * R / ( 2.D0 * PR )
         TT = T
! 
      RETURN
      END
! 
!---------------------------------------------------------------------
! 
!************************************************************************
      FUNCTION FNU(X,whatToPlot,R,PHI,NTHETA,TIME,DC)
!************************************************************************
!   local Nusselt number NU(r = ri)
!   optimized for K = 0.
!------------------------------------------------------------------------
      IMPLICIT REAL*8(A-H,O-Z)
      PARAMETER (NM = 5500)
      PARAMETER (PI = 3.14159265358979D0)
      CHARACTER*1 CF
      CHARACTER*2 CRR,whatToPlot
! 
      DIMENSION X(*)
! 
      COMMON/DIM/NDV,NDW,NDT,NDH,NDG,ND
      COMMON/QNU/NMC,L(NM),M(NM),N(NM),K(NM),CF(NM),CRR(NM)
      COMMON/PARI/RA,TA,PR,PM,ETA,C,OM,FTW,FTG,MF
      COMMON/NPARI/M0,NTV,NTH,LTV,LTH,KTV,KTH,LEV,LRB,LD
      IF( NM.NE.NMC ) THEN
         WRITE(*,*) 'WRONG DIMENSION NM IN FNU.'
         STOP
      ENDIF
! 
      FNU = 0.D0
      PPHI = PHI*PI/180.D0
      RI = ETA/(1.D0-ETA)
      IF( whatToPlot.EQ.'NU' ) THEN
         NDOMIN = 1+NDV+NDW
         NDOMAX = NDV+NDW+NDT
      ELSE
         WRITE(*,*) 'WRONG whatToPlot IN FNU, SHOULD BE NU BUT IS: ',whatToPlot
         STOP
      ENDIF
! 
      DO 1000 I = NDOMIN,NDOMAX
         IF( CF(I).NE.'T' ) THEN
            WRITE(*,*) 'WRONG CF IN TEMP, SHOULD BE T BUT IS: ',
     &                                                  CF(I)
            STOP
         ENDIF
         IF( M(I).EQ.0 ) THEN
            EPSM = 1.D0
         ELSE
            EPSM = 2.D0
         ENDIF
         IF( K(I).EQ.0 ) THEN
            EPSK = 1.D0
         ELSE
            EPSK = 2.D0
         ENDIF
         FNUT = EPSM*EPSK*PLMS(L(I),M(I),NTHETA)*DBLE(N(I))*PI
! 
        if(K(I).EQ.0) then
         IF( CRR(I).EQ.'RR' ) THEN
            FNUT = FNUT * X(I) * DCOS( M(I)*(PPHI-DC*TIME) ) 
         ELSEIF( CRR(I).EQ.'IR' ) THEN
            FNUT = -FNUT * X(I) * DSIN( M(I)*(PPHI-DC*TIME) ) 
         ELSE
            FNUT = 0.D0
         ENDIF
        else
         IF( CRR(I).EQ.'RR' ) THEN
            FNUT = FNUT * X(I) * DCOS( M(I)*(PPHI-DC*TIME) ) *
     *                                          DCOS(K(I)*OM*TIME)
         ELSEIF( CRR(I).EQ.'IR' ) THEN
            FNUT = -FNUT * X(I) * DSIN( M(I)*(PPHI-DC*TIME) ) *
     *                                          DCOS(K(I)*OM*TIME)
         ELSEIF( CRR(I).EQ.'RI' ) THEN
            FNUT = -FNUT * X(I) * DCOS( M(I)*(PPHI-DC*TIME) ) *
     *                                          DSIN(K(I)*OM*TIME)
         ELSEIF( CRR(I).EQ.'II' ) THEN
            FNUT = FNUT * X(I) * DSIN( M(I)*(PPHI-DC*TIME) ) *
     *                                          DSIN(K(I)*OM*TIME)
         ENDIF
        endif
         FNU = FNU+FNUT
1000  CONTINUE
! 
      FNU = 1.D0 - PR/RI*FNU
! 
      RETURN
      END
! 
!---------------------------------------------------------------------
! 
! 
!************************************************************************
      FUNCTION FZONAL(X,R,NTHETA,TIME)
!************************************************************************
!   Zonaler Fluss = gemittelte phi-Komponente der Geschwindigkeit:
!          < u_phi > = - dtheta w   (m = 0) 
! 
!     optimized for K = 0.
! 
!------------------------------------------------------------------------
      IMPLICIT REAL*8(A-H,O-Z)
      PARAMETER (NM = 5500)
      PARAMETER (PI = 3.14159265358979D0)
      CHARACTER*1 CF
      CHARACTER*2 CRR
! 
      DIMENSION X(*)
! 
      COMMON/DIM/NDV,NDW,NDT,NDH,NDG,ND
      COMMON/QNU/NMC,L(NM),M(NM),N(NM),K(NM),CF(NM),CRR(NM)
      COMMON/PARI/RA,TA,PR,PM,ETA,C,OM,FTW,FTG,MF
      COMMON/NPARI/M0,NTV,NTH,LTV,LTH,KTV,KTH,LEV,LRB,LD
! 
      IF( NM.NE.NMC ) THEN
         WRITE(*,*) 'WRONG DIMENSION NM IN FZONAL.'
         STOP
      ENDIF
! 
      FZONAL = 0.D0
      RI = ETA/(1.D0-ETA)
      NDOMIN = 1+NDV
      NDOMAX = NDV+NDW
! 
      DO 1000 I = NDOMIN,NDOMAX
         IF( CF(I).NE.'W' ) THEN
            WRITE(*,*) 'WRONG CF IN FZONAL, SHOULD BE W BUT IS: ',
     &                                                  CF(I)
            STOP
         ENDIF
! 
         IF( M(I).NE.0 ) GOTO 1000
! 
         IF( K(I).EQ.0 ) THEN
            EPSK = 1.D0
         ELSE
            EPSK = 2.D0
         ENDIF
         ZON = EPSK*DSQRT(DBLE(L(I)*(L(I)+1))) * PLMS(L(I),1,NTHETA) *
     &                  R * DCOS( (N(I)-1)*PI*(R-RI) )
! 
        if(K(I).EQ.0) then
         IF( CRR(I).EQ.'RR' ) THEN
            ZON = ZON * X(I)
         ELSE
            ZON = 0.D0
         ENDIF
        else
         IF( CRR(I).EQ.'RR' ) THEN
            ZON = ZON * X(I) * DCOS(K(I)*OM*TIME)
         ELSEIF( CRR(I).EQ.'RI' ) THEN
            ZON = -ZON * X(I) * DSIN(K(I)*OM*TIME)
         ELSE
            ZON = 0.D0
         ENDIF
        endif
         FZONAL = FZONAL+ZON
1000  CONTINUE
! 
      RETURN
      END
! 
!---------------------------------------------------------------------
! 
! 
!************************************************************************
      FUNCTION UP(X,whatToPlot,R,PHI,NTHETA,TIME,DC)
!     Uphi = 1/(r*sinphi) d^2/drdph rv - d/dth w
!
!     optimized for K = 0.
!
!************************************************************************
! 
!------------------------------------------------------------------------
      IMPLICIT REAL*8(A-H,O-Z)
      PARAMETER(NMX = 65,NMY = 128)
!     PARAMETER(NMX = 101,NMY = 51)
      PARAMETER (NM = 5500)
      PARAMETER (PI = 3.14159265358979D0)
      CHARACTER*1 CF
      CHARACTER*2 CRR,whatToPlot
! 
      DIMENSION X(*)
      DIMENSION THETA(NMY)
! 
      COMMON/DIM/NDV,NDW,NDT,NDH,NDG,ND
      COMMON/QNU/NMC,L(NM),M(NM),N(NM),K(NM),CF(NM),CRR(NM)
      COMMON/PARI/RA,TA,PR,PM,ETA,C,OM,FTW,FTG,MF
      COMMON/NPARI/M0,NTV,NTH,LTV,LTH,KTV,KTH,LEV,LRB,LD
! 
      COMMON/THETAC/THETA
! 
      IF( NM.NE.NMC ) THEN
         WRITE(*,*) 'WRONG DIMENSION NM IN UP.'
         STOP
      ENDIF
! 
      THETAR = PI*THETA(NTHETA)/180.D0
      SINTH = DSIN(THETAR)
! 
      PPHI = PHI*PI/180.D0
      RI = ETA/(1.D0-ETA)
      UP = 0.D0

      IF( whatToPlot.NE.'UP' ) THEN
        WRITE(*,*) 'WRONG whatToPlot IN UP, SHOULD BE UP BUT IS: ',whatToPlot
        STOP
      ENDIF

      NDOMIN = NDV+1
      NDOMAX = NDV+NDW
!------- toroidal part: --------------------------
      DO 1000 I = NDOMIN,NDOMAX
         IF( M(I).EQ.0 ) THEN
            EPSM = 1.D0
         ELSE
            EPSM = 2.D0
         ENDIF
         IF( K(I).EQ.0 ) THEN
            EPSK = 1.D0
         ELSE
            EPSK = 2.D0
         ENDIF

         IF(SINTH.EQ.0.D0) THEN
          UPT = 0.D0
         ELSE
          DL = DBLE(L(I))
          DM = DBLE(M(I))
          DLPM = DL+DM
          DLMM = DL-DM
!-------               -d/dth w       ----------------
         UPT = EPSM*EPSK/SINTH *
     *    ( (DL+1.D0)*PLMS(L(I)-1,M(I),NTHETA) *
     *      DSQRT(DLPM*DLMM/((2.D0*DL-1)*(2D0*DL+1D0))) -
     -      DL*PLMS(L(I)+1,M(I),NTHETA) *
     *      DSQRT((DLMM+1.D0)*(DLPM+1.D0)/((2D0*DL+3D0)*(2D0*DL+1D0))) )
         ENDIF

         IF( CF(I).EQ.'W' ) THEN
            UPT = UPT*R*DCOS( (N(I)-1)*PI*(R-RI) )
         ELSEIF( CF(I).EQ.'G' ) THEN
            UPT = UPT*DSIN( N(I)*PI*(R-RI) )
         ENDIF
         IF(K(I).EQ.0) THEN
           IF( CRR(I).EQ.'RR' ) THEN
            UPT = UPT * X(I) * DCOS( M(I)*(PPHI-DC*TIME) )
           ELSEIF( CRR(I).EQ.'IR' ) THEN
            UPT = -UPT * X(I) * DSIN( M(I)*(PPHI-DC*TIME) )
           ELSEIF( CRR(I).EQ.'RI' ) THEN
            UPT = 0.0D0
           ELSEIF( CRR(I).EQ.'II' ) THEN
            UPT = 0.0D0
           ENDIF
         ELSE
           IF( CRR(I).EQ.'RR' ) THEN
            UPT = UPT * X(I) * DCOS( M(I)*(PPHI-DC*TIME) ) *
     *                                          DCOS(K(I)*OM*TIME)
           ELSEIF( CRR(I).EQ.'IR' ) THEN
            UPT = -UPT * X(I) * DSIN( M(I)*(PPHI-DC*TIME) ) *
     *                                          DCOS(K(I)*OM*TIME)
           ELSEIF( CRR(I).EQ.'RI' ) THEN
            UPT = -UPT * X(I) * DCOS( M(I)*(PPHI-DC*TIME) ) *
     *                                          DSIN(K(I)*OM*TIME)
           ELSEIF( CRR(I).EQ.'II' ) THEN
            UPT = UPT * X(I) * DSIN( M(I)*(PPHI-DC*TIME) ) *
     *                                          DSIN(K(I)*OM*TIME)
           ENDIF
         ENDIF

         UP = UP+UPT
1000  CONTINUE


!------- poloidal part: --------------------------
         NDOMIN = 1
         NDOMAX = NDV
      DO 2000 I = NDOMIN,NDOMAX
         IF( M(I).EQ.0 ) THEN
            EPSM = 1.D0
!           poloidal part is 0 for M = 0:
            GOTO 2000
         ELSE
            EPSM = 2.D0
         ENDIF
         IF( K(I).EQ.0 ) THEN
            EPSK = 1.D0
         ELSE
            EPSK = 2.D0
         ENDIF

!------- 1/(rsinth) d^2/drdphi (rv) -------------
         IF( SINTH.EQ.0.D0 .OR. M(I).EQ.0 ) THEN
          UPT = 0.D0
         ELSE
          UPT = EPSM*EPSK * M(I) * PLMS(L(I),M(I),NTHETA)  / (R*SINTH)

          UPT = UPT*(R*N(I)*PI*DCOS(N(I)*PI*(R-RI))+DSIN(N(I)*PI*(R-RI)))

         IF(K(I).EQ.0) THEN
           IF( CRR(I).EQ.'RR' ) THEN
            UPT = -UPT * X(I) * DSIN( M(I)*(PPHI-DC*TIME) )
           ELSEIF( CRR(I).EQ.'IR' ) THEN
             UPT = -UPT * X(I) * DCOS( M(I)*(PPHI-DC*TIME) )
           ELSE
             UPT = 0.D0
           ENDIF
         ELSE
           IF( CRR(I).EQ.'RR' ) THEN
            UPT = -UPT * X(I) * DSIN( M(I)*(PPHI-DC*TIME) ) *
     *                                          DCOS(K(I)*OM*TIME)
           ELSEIF( CRR(I).EQ.'IR' ) THEN
             UPT = -UPT * X(I) * DCOS( M(I)*(PPHI-DC*TIME) ) *
     *                                          DCOS(K(I)*OM*TIME)
           ELSEIF( CRR(I).EQ.'RI' ) THEN
             UPT = UPT * X(I) * DSIN( M(I)*(PPHI-DC*TIME) ) *
     *                                          DSIN(K(I)*OM*TIME)
           ELSEIF( CRR(I).EQ.'II' ) THEN
             UPT = UPT * X(I) * DCOS( M(I)*(PPHI-DC*TIME) ) *
     *                                          DSIN(K(I)*OM*TIME)
           ENDIF
         ENDIF
         ENDIF

         UP = UP+UPT
2000  CONTINUE
! 
      RETURN
      END
! 
!---------------------------------------------------------------------
! 
!************************************************************************
      FUNCTION DMERI(X,R,NTHETA,TIME)
!************************************************************************
!   Meridionale Zirkulation = phi-gemittelt Stromlinien fuer phi = kostant:
!        < F_phi > = < r sin(theta) dtheta v>  
! 
!     optimized for K = 0.
! 
!----------------------------------------------------------------------- 
! 
      IMPLICIT REAL*8(A-H,O-Z)
      PARAMETER (NM = 5500)
      PARAMETER (PI = 3.14159265358979D0)
      CHARACTER*1 CF
      CHARACTER*2 CRR
! 
      DIMENSION X(*)
! 
      COMMON/DIM/NDV,NDW,NDT,NDH,NDG,ND
      COMMON/QNU/NMC,L(NM),M(NM),N(NM),K(NM),CF(NM),CRR(NM)
      COMMON/PARI/RA,TA,PR,PM,ETA,C,OM,FTW,FTG,MF
      COMMON/NPARI/M0,NTV,NTH,LTV,LTH,KTV,KTH,LEV,LRB,LD
! 
      IF( NM.NE.NMC ) THEN
         WRITE(*,*) 'WRONG DIMENSION NM IN DMERI.'
         STOP
      ENDIF
      RI = ETA/(1.D0-ETA)
      DMERI = 0.D0
      NDOMIN = 1
      NDOMAX = NDV
! 
      DO 1000 I = NDOMIN,NDOMAX
         IF( CF(I).NE.'V' ) THEN
            WRITE(*,*) 'WRONG CF IN FP, SHOULD BE V BUT IS: ',
     &                                                  CF(I)
            STOP
         ENDIF
! 
         IF( M(I).NE.0 ) GOTO 1000
! 
         IF( K(I).EQ.0 ) THEN
            EPSK = 1.D0
         ELSE
            EPSK = 2.D0
         ENDIF

         DMER = EPSK*R * DBLE(L(I)*(L(I)+1)) * (
     &      1.D0/DSQRT( DBLE( (2*L(I)+1)*(2*L(I)+3) ) ) * 
     *                                        PLMS(L(I)+1,0,NTHETA) -
     -      1.D0/DSQRT( DBLE( (2*L(I)+1)*(2*L(I)-1) ) ) * 
     *                                        PLMS(L(I)-1,0,NTHETA)  )
         DMER = DMER*DSIN( N(I)*PI*(R-RI) )
! 
        if(K(I).EQ.0) then
         IF( CRR(I).EQ.'RR' ) THEN
            DMER = DMER * X(I)
         ELSE
            DMER = 0.D0
         ENDIF
        else
         IF( CRR(I).EQ.'RR' ) THEN
            DMER = DMER * X(I) * DCOS(K(I)*OM*TIME)
         ELSEIF( CRR(I).EQ.'RI' ) THEN
            DMER = -DMER * X(I) * DSIN(K(I)*OM*TIME)
         ELSE
            DMER = 0.D0
         ENDIF
        endif
! 
         DMERI = DMERI+DMER
1000  CONTINUE
! 
      RETURN
      END
! 
!---------------------------------------------------------------------
! 
! 
!************************************************************************
      FUNCTION DMTOR(X,R,NTHETA,TIME)
!************************************************************************
!   phi-gemittelte phi-Komponente der Toroidalfeldes:
!           < B_phi > = - dtheta g (m = 0)
! 
!     optimized for K = 0.
! 
!------------------------------------------------------------------------
      IMPLICIT REAL*8(A-H,O-Z)
      PARAMETER (NM = 5500)
      PARAMETER (PI = 3.14159265358979D0)
      CHARACTER*1 CF
      CHARACTER*2 CRR
! 
      DIMENSION X(*)
! 
      COMMON/DIM/NDV,NDW,NDT,NDH,NDG,ND
      COMMON/QNU/NMC,L(NM),M(NM),N(NM),K(NM),CF(NM),CRR(NM)
      COMMON/PARI/RA,TA,PR,PM,ETA,C,OM,FTW,FTG,MF
      COMMON/NPARI/M0,NTV,NTH,LTV,LTH,KTV,KTH,LEV,LRB,LD
! 
      IF( NM.NE.NMC ) THEN
         WRITE(*,*) 'WRONG DIMENSION NM IN DMTOR.'
         STOP
      ENDIF
! 
      RI = ETA/(1.D0-ETA)
      DMTOR = 0.D0
      NDOMIN = NDV+NDW+NDT+NDH+1
      NDOMAX = NDV+NDW+NDT+NDH+NDG
      DO 1000 I = NDOMIN,NDOMAX
         IF( CF(I).NE.'G' ) THEN
            WRITE(*,*) 'WRONG CF IN DMTOR, SHOULD BE G BUT IS: ',
     &                                                  CF(I)
            STOP
         ENDIF
         IF( M(I).NE.0 ) GOTO 1000
         IF( K(I).EQ.0 ) THEN
            EPSK = 1.D0
         ELSE
            EPSK = 2.D0
         ENDIF
         DMT = EPSK*DSQRT(DBLE(L(I)*(L(I)+1))) * PLMS(L(I),1,NTHETA) * 
     *                                DSIN( N(I)*PI*(R-RI) )
        if(K(I).EQ.0) then
         IF( CRR(I).EQ.'RR' ) THEN
            DMT = DMT * X(I)
         ELSE
            DMT = 0.D0
         ENDIF
        else
         IF( CRR(I).EQ.'RR' ) THEN
            DMT = DMT * X(I) * DCOS(K(I)*OM*TIME)
         ELSEIF( CRR(I).EQ.'RI' ) THEN
            DMT = -DMT * X(I) * DSIN(K(I)*OM*TIME)
         ELSE
            DMT = 0.D0
         ENDIF
        endif
         DMTOR = DMTOR-DMT
1000  CONTINUE
! 
      RETURN
      END
! 
!---------------------------------------------------------------------
! 
! 
!************************************************************************
      FUNCTION DMPJ(X,whatToPlot,R,NTHETA,TIME)
!************************************************************************
!  phi-gemittelte Stomlinien des Poloidalfeldes fuer phi = konstant:
!            < F_phi > = r sin(theta) dtheta h (m = 0)
!  oder des elektrischen Stromes: 
!            < F_phi > = r sin(theta) dtheta g (m = 0)
! 
!     optimized for K = 0.
! 
!------------------------------------------------------------------------
      IMPLICIT REAL*8(A-H,O-Z)
      PARAMETER (NM = 5500,NAM = 400)
      PARAMETER (PI = 3.14159265358979D0)
      CHARACTER*1 CF
      CHARACTER*2 CRR,whatToPlot
! 
      DIMENSION X(*)
! 
      COMMON/DIM/NDV,NDW,NDT,NDH,NDG,ND
      COMMON/QNU/NMC,L(NM),M(NM),N(NM),K(NM),CF(NM),CRR(NM)
      COMMON/PARI/RA,TA,PR,PM,ETA,C,OM,FTW,FTG,MF
      COMMON/NPARI/M0,NTV,NTH,LTV,LTH,KTV,KTH,LEV,LRB,LD
      COMMON/AB/A(NAM),B(NAM),NAMC
! 
      IF( NM.NE.NMC ) THEN
         WRITE(*,*) 'WRONG DIMENSION NM IN DMPJ.'
         STOP
      ENDIF
      IF( NAM.NE.NAMC ) THEN
         WRITE(*,*) 'WRONG DIMENSION NAM IN DMPJ.'
         STOP
      ENDIF
! 
      RI = ETA/(1.D0-ETA)
      RO = RI+1.D0
      DMPJ = 0.D0
      IF( whatToPlot.EQ.'MP' ) THEN
         NDOMIN = NDV+NDW+NDT+1
         NDOMAX = NDV+NDW+NDT+NDH
      ELSEIF( whatToPlot.EQ.'MJ' ) THEN
         NDOMIN = NDV+NDW+NDT+NDH+1
         NDOMAX = NDV+NDW+NDT+NDH+NDG
      ELSE
         WRITE(*,*) 'WRONG whatToPlot IN DMPJ, SHOULD BE MP OR MJ BUT IS: ',whatToPlot
         STOP
      ENDIF
      DO 1000 I = NDOMIN,NDOMAX
         IF( .NOT.( ( CF(I).EQ.'H' .AND. whatToPlot.EQ.'MP' ) .OR.
     &              ( CF(I).EQ.'G' .AND. whatToPlot.EQ.'MJ' )  ) ) THEN
            WRITE(*,*) 'WRONG CF IN DMPJ, SHOULD BE H OR G BUT IS: ', CF(I)
            STOP
         ENDIF
         IF( M(I).NE.0 ) GOTO 1000
         IF( K(I).EQ.0 ) THEN
            EPSK = 1.D0
         ELSE
            EPSK = 2.D0
         ENDIF
         DMP = EPSK*R * DBLE(L(I)*(L(I)+1)) * (
     &        PLMS(L(I)+1,M(I),NTHETA) / DSQRT( DBLE( (2*L(I)+1)*(2*L(I)+3) ) )  -
     -        PLMS(L(I)-1,M(I),NTHETA) / DSQRT( DBLE( (2*L(I)+1)*(2*L(I)-1) ) )   )
         IF( CF(I).EQ.'H' ) THEN
            NR = NAB(L(I),N(I))
            IF( R.LE.RO ) THEN
               IF( A(NR).EQ.0.D0 .OR. B(NR).EQ.0.D0 ) THEN
                  WRITE(*,*) 'ALPHA AND BETA NOT CALCULATED.'
                  STOP  
               ENDIF
               DMP = DMP*DCOS( A(NR)*R-B(NR) )
            ELSE
               IF( A(NR).EQ.0.D0 .OR. B(NR).EQ.0.D0 ) THEN
                  WRITE(*,*) 'ALPHA AND BETA NOT CALCULATED.'
                  STOP  
               ENDIF
               DMP = DMP * (RO/R)**(L(I)+1) * DCOS( A(NR)*RO-B(NR) )
            ENDIF
         ELSEIF( CF(I).EQ.'G' ) THEN
            DMP = DMP*DSIN( N(I)*PI*(R-RI) )
         ENDIF
        if(K(I).EQ.0) then
         IF( CRR(I).EQ.'RR' ) THEN
            DMP = DMP * X(I)
         ELSE        
            DMP = 0.D0
         ENDIF
        else
         IF( CRR(I).EQ.'RR' ) THEN
            DMP = DMP * X(I) * DCOS(K(I)*OM*TIME)
         ELSEIF( CRR(I).EQ.'RI' ) THEN
            DMP = -DMP * X(I) * DSIN(K(I)*OM*TIME)
         ELSE        
            DMP = 0.D0
         ENDIF
        endif
         DMPJ = DMPJ+DMP
1000  CONTINUE
! 
      RETURN
   END

   !---------------------------------------------------------------------
   ! Ueber Phi gemittelte Phi-Komponente des elektrischen Stromes: 
   !            dtheta laplace h  (m = 0).
   ! 
   !     optimized for K = 0.
   FUNCTION DMC(X,R,NTHETA,TIME)
      IMPLICIT REAL*8(A-H,O-Z)
      PARAMETER (NM = 5500,NAM = 400)
      CHARACTER*1 CF
      CHARACTER*2 CRR
! 
      DIMENSION X(*)
! 
      COMMON/DIM/NDV,NDW,NDT,NDH,NDG,ND
      COMMON/QNU/NMC,L(NM),M(NM),N(NM),K(NM),CF(NM),CRR(NM)
      COMMON/PARI/RA,TA,PR,PM,ETA,C,OM,FTW,FTG,MF
      COMMON/NPARI/M0,NTV,NTH,LTV,LTH,KTV,KTH,LEV,LRB,LD
      COMMON/AB/A(NAM),B(NAM),NAMC
! 
      IF( NM.NE.NMC ) THEN
         WRITE(*,*) 'WRONG DIMENSION NM IN DMC.'
         STOP
      ENDIF
      IF( NAM.NE.NAMC ) THEN
         WRITE(*,*) 'WRONG DIMENSION NAM IN DMC.'
         STOP
      ENDIF
      RI = ETA/(1.D0-ETA)
      DMC = 0.D0
      NDOMIN = NDV + NDW + NDT + 1
      NDOMAX = NDV + NDW + NDT + NDH
      DO 1000 I = NDOMIN,NDOMAX
         IF( CF(I).NE.'H' ) THEN
            WRITE(*,*) 'WRONG CF IN DMC, SHOULD BE H BUT IS: ', CF(I)
            STOP
         ENDIF
         IF( M(I).NE.0 ) GOTO 1000
         IF( K(I).EQ.0 ) THEN
            EPSK = 1.D0
         ELSE
            EPSK = 2.D0
         ENDIF
         DM = EPSK*DSQRT(DBLE(L(I)*(L(I)+1))) * PLMS(L(I),1,NTHETA)
         NR = NAB(L(I),N(I))
         IF( A(NR).EQ.0.D0 .OR. B(NR).EQ.0.D0 ) THEN
            WRITE(*,*) 'ALPHA AND BETA NOT CALCULATED.'
            STOP
         ENDIF
         DM = -DM*( ( A(NR)*A(NR)+DBLE(L(I)*(L(I)+1))/(R*R) )*DCOS(A(NR)*R-B(NR) ) + &
                    2*A(NR)/R * DSIN( A(NR)*R-B(NR) )  )
! 
        if(K(I).EQ.0) then
           IF( CRR(I).EQ.'RR' ) THEN
              DM = DM * X(I)
           ELSE
              DM = 0.D0
           ENDIF
        else
           IF( CRR(I).EQ.'RR' ) THEN
              DM = DM * X(I) * DCOS(K(I)*OM*TIME)
           ELSEIF( CRR(I).EQ.'RI' ) THEN
              DM = -DM * X(I) * DSIN(K(I)*OM*TIME)
           ELSE
              DM = 0.D0
           ENDIF
        endif
         DMC = DMC-DM
1000  CONTINUE
   END function

   !---------------------------------------------------------------------
   !  THIS PROGRAM FINDS THE A'S AND B'S OF THE POLODIAL MAGNETIC
   !  FIELD TO FULLFILL THE BOUNDARY CONDITIONS:
   !  A(I)*TAN(A(I)*RO-B(I))-(L+1)/RO = 0  AND
   !  A(I)*TAN(A(I)*RI-B(I))+L/RI = 0 WITH A PRCISSION OF 1D-13.
   !  THE A'S AND B'S ARE STORED LINEARLY IN THE ARRAYS, NAB(L,N)
   !  DETERMINS THE POSITION IN THE ARRAY.
   !  NEEDS FUNCTIONS AMIN,NAB .
   SUBROUTINE ABG(ND,CF,LA,NA)
      IMPLICIT REAL*8(A-H,O-Y)
      CHARACTER*1 CF
      PARAMETER(NAM = 400)
      PARAMETER(NLMA = 100)
      PARAMETER(DPI = 3.141592653589793D0)
! 
      DIMENSION CF(*),LA(*),NA(*)
! 
      COMMON/LOG/LCALC,LWRITE,LTR,LVAR,LDY,L6,L7,L8,L9,L10
      COMMON/PAR/RA,TA,PR,PM,ETA,C,OM,FTW,FTG,MF
      COMMON/NPAR/M0,NTV,NTH,LTV,LTH,KTV,KTH,LEV,LRB,LD
      COMMON/NUM/RELE,EPS,ALPH,STOER,NITMAX,NJA
! 
      COMMON/AB/A(NAM),B(NAM),NAMC
      COMMON/ABMIN/RIAB,ROAB,RELEAB,LAB
      COMMON/LNMAX/NLMAC,NL,LC(100),NMAXC(100),NMABC
! 
      IF( NAM.NE.NAMC ) THEN
         WRITE(*,*) 'WRONG DIMENSION NAM IN ABG.'
         STOP
      ENDIF
      IF( NLMA.NE.NLMAC ) THEN
         WRITE(*,*) 'WRONG DIMENSION NLMA IN ABG.'
         STOP
      ENDIF
! 
      CALL CALCNMAX(ND,CF,LA,NA)
! 
      RI = ETA/(1.D0-ETA)
      RO = RI+1.D0
      RIAB = RI
      ROAB = RO
      DAX = 1.D-3
! 
      IF( DAX.LT.RELE*1.D3 ) THEN
         RELEAB = RELE*1.D-4
      ELSE
         RELEAB = RELE
      ENDIF
      RELEAB = DMAX1(RELEAB,EPS)
! 
      IA = 1
      DO 1000 NI = 1,NL
         L = IABS(LC(NI))
         NMAX = NMAXC(NI)
! 
         IF( NMAX.LE.0 ) THEN
            GOTO 1000
         ELSEIF( NMAX.GT.NAM ) THEN
            WRITE(*,*) 'TOO SMALL NAM IN DABG.'
            STOP
         ENDIF
         N = 1
         LAB = L
         IF( RI.EQ.0 ) THEN
            DO I = 0,2000
               IF( I.EQ.0 ) THEN
                  AXMIN = DAX
               ELSE
                  AXMIN = (I-0.5D0)*DPI+DAX
               ENDIF
               AXMAX = (I+0.5D0)*DPI-DAX
               IF( IA.GT.NAM ) THEN
                  WRITE(*,*) 'TOO SMALL DIMENSION NAM IN ABG.'
                  STOP
               ENDIF
               AGUESS = AXMAX
               LBT = 0
90             A(IA) = AMINB(AGUESS)
               IF( LBT.EQ.0 .AND. ( A(IA).LT.AXMIN .OR. A(IA).GT.AXMAX ) ) THEN
                  LBT = 1
                  AGUESS = AXMIN
                  GOTO 90
               ELSEIF( LBT.EQ.1 .AND. ( A(IA).LT.AXMIN .OR. A(IA).GT.AXMAX ) ) THEN
                  WRITE(*,*) 'WRONG ALPHA!!!!'
                  WRITE(*,'(X,'' IA,L,ALPHAMIN,ALPHA,ALPHAMAX: '',2I4,3D16.6)') IA,L,AXMIN,A(IA),AXMAX
                  STOP
               ENDIF
               B(IA) = 0.0D0
               IA = IA+1
               N = N+1
               IF(N.GT.NMAX) GOTO 1000
            enddo
         ELSE
            CD = DSQRT(L*(L+1)/RI/RO)
            AXMIN = DAX
            AXMAX = 0.5D0*DPI-DAX
            IF(AXMAX.GT.CD) THEN
               IF( IA.GT.NAM ) THEN
                  WRITE(*,*) 'TOO SMALL DIMENSION NAM IN ABG.'
                  STOP
               ENDIF
               AGUESS = AXMAX
               LBT = 0
190            A(IA) = AMIN(AGUESS)
               IF( LBT.EQ.0 .AND. ( A(IA).LT.AXMIN .OR. A(IA).GT.AXMAX ) ) THEN
                  LBT = 1
                  AGUESS = AXMIN
                  GOTO 190
               ELSEIF( LBT.EQ.1 .AND.  ( A(IA).LT.AXMIN .OR. A(IA).GT.AXMAX ) ) THEN
                  WRITE(*,*) 'WRONG ALPHA!!!!'
                  WRITE(*,'(X,'' IA,L,ALPHAMIN,ALPHA,ALPHAMAX: '',2I4,3D16.6)') IA,L,AXMIN,A(IA),AXMAX
                  STOP
               ENDIF
               B(IA) = A(IA)*RI+DATAN(L/A(IA)/RI)
               IA = IA+1
               N = N+1
               IF(N.GT.NMAX) GOTO 1000
            ENDIF
            DO 200 I = 1,2000
               DAX = 1D-3
               AXMIN = (I-0.5D0)*DPI+DAX
               AXMAX = (I+0.5D0)*DPI-DAX
               IF(AXMIN.LT.CD .AND. AXMAX.GT.CD ) THEN
                  IF( IA.GT.NAM ) THEN
                     WRITE(*,*) 'TOO SMALL DIMENSION NAM IN ABG.'
                     STOP
                  ENDIF
                  AGUESS = AXMIN
                  LBT = 0
290               A(IA) = AMIN(AGUESS)
                  IF( LBT.EQ.0 .AND. ( A(IA).LT.AXMIN .OR. A(IA).GT.AXMAX ) ) THEN
                     LBT = 1
                     AGUESS = AXMAX
                     GOTO 290
                  ELSEIF( LBT.EQ.1 .AND. ( A(IA).LT.AXMIN .OR. A(IA).GT.AXMAX ) ) THEN
                     WRITE(*,*) 'WRONG ALPHA!!!!'
                     WRITE(*,'(X,'' IA,L,ALPHAMIN,ALPHA,ALPHAMAX: '',2I4,3D16.6)') IA,L,AXMIN,A(IA),AXMAX
                     STOP
                  ENDIF
                  B(IA) = A(IA)*RI+DATAN(L/A(IA)/RI)
                  IA = IA+1
                  N = N+1
                  IF(N.GT.NMAX) GOTO 1000
               ENDIF
150            CONTINUE
               IF( IA.GT.NAM ) THEN
                  WRITE(*,*) 'TOO SMALL DIMENSION NAM IN ABG.'
                  STOP
               ENDIF
               AGUESS = AXMAX
               LBT = 0
390            A(IA) = AMIN(AGUESS)
               IF( LBT.EQ.0 .AND. ( A(IA).LT.AXMIN .OR. A(IA).GT.AXMAX ) ) THEN
                  LBT = 1
                  AGUESS = AXMIN
                  GOTO 390
               ELSEIF( LBT.EQ.1 .AND. ( A(IA).LT.AXMIN .OR. A(IA).GT.AXMAX ) ) THEN
                  WRITE(*,*) 'WRONG ALPHA!!!!'
                  WRITE(*,'(X,'' IA,L,ALPHAMIN,ALPHA,ALPHAMAX: '',2I4,3D16.6)') IA,L,AXMIN,A(IA),AXMAX
                  STOP
               ENDIF
               B(IA) = A(IA)*RI+DATAN(L/A(IA)/RI)
               IA = IA+1
               N = N+1
               IF(N.GT.NMAX) GOTO 1000
200         CONTINUE
         ENDIF
1000  CONTINUE
      DO I = 1,IA-1
         IF( I.GT.1 .AND. ( A(I).GT.A(I-1)-RELE .AND. A(I).LT.A(I-1)+RELE ) ) THEN
            WRITE(*,*) 'TWO ALPHAS EQUAL: ',A(I-1),A(I)
            STOP
         ENDIF
         DO J = 1,100
            B(I) = B(I)-DPI
            IF(B(I).LT.0.D0) THEN
               B(I) = B(I)+DPI
               exit
            ENDIF
         enddo
      enddo
! 
      IA = IA-1
      WRITE(*,*) IA,' ALPHA AND BETA CALCULATED.'
      NMABC = IA
      DO I = 1,IA
         WRITE(*,'(2X,I4,2D14.6)') I,A(I),B(I)
      enddo
   END

   !------------------------------------------------------------------------
   !  FINDS THE MINIMUM FOR THE FUNCTION IN LINE 5 WITH A NEWTON METHOD.
   FUNCTION AMIN(AX)
      IMPLICIT REAL*8(A-H,O-Y)
! 
      COMMON/ABMIN/RI,RO,RELE,L
! 
      ICOUNT = 0
! 
5     FA = DTAN(AX)-(L*RO+(L+1)*RI)*AX/(RI*RO*AX**2-L*(L+1))
      FAA = 1D0/DCOS(AX)**2-( (L*RO+(L+1)*RI)*(RI*RO*AX**2-L*(L+1)) -
     -      AX*(L*RO+(L+1)*RI)*2*RI*RO*AX )/(RI*RO*AX**2-L*(L+1))**2
      IF(FAA.EQ.0) THEN
         AX = AX+RELE
         GOTO 5
      ENDIF
      DA = FA/FAA
      AOX = AX
      AX = AX-DA
      IF(DABS(1-DABS(AOX/AX)).LT.RELE) THEN
         AMIN = AX
         RETURN
      ENDIF
      ICOUNT = ICOUNT+1
      IF(ICOUNT.GT.100) THEN
         WRITE(*,*) 'NO ZERO FOUND IN DABG/AMIN.'
         STOP
      ENDIF
      GOTO 5
! 
   END function

   !------------------------------------------------------------------------
   !   FINDS THE MINIMUM FOR THE FUNCTION IN LINE 5 WITH A NEWTON METHOD.
   FUNCTION AMINB(AX)
      IMPLICIT REAL*8(A-H,O-Y)
! 
      COMMON/ABMIN/RI,RO,RELE,L
! 
5     FA = DTAN(AX*RO)-(L+1)/AX/RO
      FAA = RO/DCOS(AX*RO)**2+(L+1)/AX**2/RO
      IF(FAA.EQ.0) THEN
         AX = AX+RELE
         GOTO 5
      ENDIF
      DA = FA/FAA
      AOX = AX
      AX = AX-DA
      IF(DABS(1-DABS(AOX/AX)).LT.RELE) THEN
         AMINB = AX
         RETURN
      ENDIF
      GOTO 5
   END function

   !------------------------------------------------------------------------
   !  DETERMINS THE POSITION OF AN A ORE B IN THE ARRAY A(I),B(I)
   !  DEPENDING ON L AND N.
   FUNCTION NAB(L,N)
      IMPLICIT REAL*8(A-H,O-Y)
      PARAMETER(NLMA = 100)
! 
      COMMON/LOG/LCALC,LWRITE,LTR,LVAR,LDY,L6,L7,L8,L9,L10
      COMMON/PAR/RA,TA,PR,PM,ETA,C,OM,FTW,FTG,MF
      COMMON/NPAR/M0,NTV,NTH,LTV,LTH,KTV,KTH,LEV,LRB,LD
      COMMON/LNMAX/NLMAC,NL,LC(NLMA),NMAXC(NLMA),NMABC
! 
      IF( NLMA.NE.NLMAC ) THEN
         WRITE(*,*) 'WRONG DIMENSION NLMA IN NAB.'
         STOP
      ENDIF
! 
      LMIN = LC(1)
      LMAX = LC(NL)
      IF( L.GT.LMAX .OR. L.LT.LMIN ) THEN
         WRITE(*,*) 'WRONG L IN NAB',L,LMIN,LMAX
         STOP
      ENDIF
      NAB = 0
      DO NI = 1,NL
         LL = LC(NI)
         NMAX = NMAXC(NI)
         IF( LL.LT.L ) THEN
            IF( NMAX.GT.0 ) NAB = NAB+NMAX
         ELSEIF( LL.EQ.L ) THEN
            IF( NMAX.LT.N ) THEN
               WRITE(*,*) 'WRONG N IN NAB',N,NMAX
               STOP
            ELSE
               NAB = NAB+N
               RETURN
            ENDIF
         ENDIF
      enddo
! 
      IF( N.GT.NMABC ) THEN
         WRITE(*,*) 'N LARGER THE CALCULATED NUMBER OF A,B IN NAB: ',N,NMABC
         STOP
      ENDIF
   END

   !------------------------------------------------------------------
   !-- CALCULATES THE MAXIMUM N FOR EACH L.
   !   THIS IS USED FOR CALCULATING THE RADIAL FUNCTION OF H.
   SUBROUTINE CALCNMAX(NK,CF,L,N)
      IMPLICIT REAL*8(A-H,O-Z)
      CHARACTER*1 CF
      DIMENSION CF(*),L(*),N(*)
      PARAMETER(NLMA = 100)
! 
      COMMON/LNMAX/NLMAC,NL,LC(NLMA),NMAX(NLMA),NMABC
! 
      NLMAC = NLMA
! 
!-- BESTIMMMUNG VON NMAX FUER JEDES L , NOTWENDIG IN ABG:
      LOLD = 10000
      NL = 0
      DO I = 1,NK
         IF( CF(I).EQ.'H' ) THEN
            IF( L(I).NE.LOLD ) THEN
               NL = NL+1
               IF( NL.GT.NLMA ) THEN
                  WRITE(*,*) 'TOO SMALL DIMENSION NLMA IN CALCNMAX.'
                  STOP
               ENDIF
               LC(NL) = L(I)
               NMAX(NL) = N(I)
               LOLD = L(I)
            ELSEIF( L(I).EQ.LOLD .AND. N(I).GT.NMAX(NL) ) THEN
               NMAX(NL) = N(I)
            ENDIF
         ENDIF
      enddo
   END

   !------------------------------------------------------------------------
   ! Phi -Komponente des Toroidalfeldes: - dtheta g
   FUNCTION DBT(X,R,PHI,NTHETA,TIME,DC)
      IMPLICIT REAL*8(A-H,O-Z)
      PARAMETER (NM = 5500)
      PARAMETER (PI = 3.141592654D0)
      CHARACTER*1 CF
      CHARACTER*2 CRR
  
      DIMENSION X(*)
  
      COMMON/DIM/NDV,NDW,NDT,NDH,NDG,ND
      COMMON/QNU/NMC,L(NM),M(NM),N(NM),K(NM),CF(NM),CRR(NM)
      COMMON/PARI/RA,TA,PR,PM,ETA,C,OM,FTW,FTG,MF
      COMMON/NPARI/M0,NTV,NTH,LTV,LTH,KTV,KTH,LEV,LRB,LD
  
      IF( NM.NE.NMC ) THEN
         WRITE(*,*) 'WRONG DIMENSION NM IN DMPJ.'
         STOP
      ENDIF
  
      PPHI = PHI*PI/180.D0
      RI = ETA/(1.D0-ETA)
      DBT = 0.D0
      NDOMIN = NDV+NDW+NDT+NDH+1
      NDOMAX = NDV+NDW+NDT+NDH+NDG
      DO I = NDOMIN,NDOMAX
         IF( CF(I).NE.'G' ) THEN
            WRITE(*,*) 'WRONG CF IN DBT, SHOULD BE G BUT IS: ', CF(I)
            STOP
         ENDIF
         IF( M(I).EQ.0 ) THEN
            EPSM = 1.D0
         ELSE
            EPSM = 2.D0
         ENDIF
         IF( K(I).EQ.0 ) THEN
            EPSK = 1.D0
         ELSE
            EPSK = 2.D0
         ENDIF
         DB = -0.5D0*EPSM*EPSK* ( &
              DSQRT(DBLE((L(I)-M(I)+1)*(L(I)+M(I)))) * PLMS(L(I),M(I)-1,NTHETA) -&
              DSQRT(DBLE((L(I)+M(I)+1)*(L(I)-M(I)))) * PLMS(L(I),M(I)+1,NTHETA) )
         DB = DB*DSIN( N(I)*PI*(R-RI) )
         IF( CRR(I).EQ.'RR' ) THEN
            DB = DB * X(I) * DCOS( M(I)*(PPHI-DC*TIME) ) * DCOS(K(I)*OM*TIME)
         ELSEIF( CRR(I).EQ.'IR' ) THEN
            DB = -DB * X(I) * DSIN( M(I)*(PPHI-DC*TIME) ) * DCOS(K(I)*OM*TIME)
         ELSEIF( CRR(I).EQ.'RI' ) THEN
            DB = -DB * X(I) * DCOS( M(I)*(PPHI-DC*TIME) ) * DSIN(K(I)*OM*TIME)
         ELSEIF( CRR(I).EQ.'II' ) THEN
            DB = DB * X(I) * DSIN( M(I)*(PPHI-DC*TIME) ) * DSIN(K(I)*OM*TIME)
         ENDIF
         DBT = DBT+DB
      enddo
   END
!---------------------------------------------------------------------
! vim: tabstop=3:softtabstop=3:shiftwidth=3:expandtab
