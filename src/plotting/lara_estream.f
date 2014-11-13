***********************************************************************
      PROGRAM LARA
*************************************************************************
C-- PROGRAM TO read data from Galerkinprogram of J.W. and convert it for IDL.
C--
C-- Input:   stdin  (short version of LARA.EXE for DISSPLA)
C--
C-- Output:
C--          3 files: idl.z, idl.x, idl.y
C--
C------------------------------------------------------------------------
      IMPLICIT REAL*8(A-H,O-W)
      IMPLICIT REAL*8(X,Y,Z)
      PARAMETER (NM=5500,NAM=400,NPM=9,NPSM=4,NPAM=NPM*NPSM)
      PARAMETER (NLMA=100)
      PARAMETER (PI=3.14159265358979D0)
C      CHARACTER*20 INPUTFILE,PARFILE,OUTPUTFILE
      CHARACTER*40 INPUTFILE,OUTPUTFILE
      CHARACTER*30 CTEXT1
      CHARACTER*10 CTEXT2
      CHARACTER*1 CF,CFS,CC,CCP
      CHARACTER*2 CRR,CFE,CFP,CP1,CP2,CPP
      CHARACTER*3 ABCNUM,ABCNUMI,ABCN
C
      DIMENSION DX(NM)
      DIMENSION CP1(NPM),NP2(NPM)
      DIMENSION CP2(NPM,NPSM),CC(NPM,NPSM),XC(NPM,NPSM)
      DIMENSION CFE(NPM,NPSM),XRMU(NPM,NPSM)
      DIMENSION TIME(NPM),ZD(NPM,NPSM),ABCNUMI(NPM,NPSM)
      DIMENSION CPP(NPAM),CFP(NPAM),XCP(NPAM),CCP(NPAM)
      DIMENSION ZDP(NPAM),TIMEP(NPAM)
      DIMENSION XOR(NPAM),YOR(NPAM),XAR(NPAM),YAR(NPAM),ABCN(NPAM)
      DIMENSION XROCM(NPAM),XRICM(NPAM),XRMCM(NPAM),XRM(NPAM)
C
      COMMON/LOG/LCALC,LWRITE,LTR,LVAR,LDY,LT,L7,L8,L9,L10
      COMMON/DIM/NDV,NDW,NDT,NDH,NDG,ND
      COMMON/QNU/NMC,L(NM),M(NM),N(NM),K(NM),CF(NM),CRR(NM)
      COMMON/QNUS/NMSC,LS(NM),MS(NM),NS(NM),CFS(NM)
      COMMON/PAR/RA,TA,PR,PM,ETA,C,OM,FTW,FTG,MF
      COMMON/PARI/RAI,TAI,PRI,PMI,ETAI,CI,OMI,FTWI,FTGI,MFI
ccc   COMMON/NPAR/M0,NE,NTV,NTH,LTV,LTH,KTV,KTH,LD
      COMMON/NPAR/M0,NTV,NTH,LTV,LTH,KTV,KTH,LEV,LRB,LD
      COMMON/NPARI/M0I,NTVI,NTHI,LTVI,LTHI,KTVI,KTHI,LEVI,LRBI,LDI
ccc   COMMON/LNMAX/NLMAC,NL,LC(NLMA),NMAXC(NLMA)
      COMMON/LNMAX/NLMAC,NL,LC(NLMA),NMAXC(NLMA),NMABC
      COMMON/AB/A(NAM),B(NAM),NAMC
ccc   COMMON/NUM/RELE,EPS,ALPH,NITMAX,NJA
      COMMON/NUM/RELE,EPS,ALPH,STOER,NITMAX,NJA
      COMMON/POLE/XP,YP
      COMMON/PLOTC/ZDO,NCPLOT
      COMMON/THETAC/THETA
C
      NCPLOT=0
      ZDO=0.E0
C
C-- INPUT:
      LR=0
      NQ=0
      NR=0
C      OPEN(11,FILE=PARFILE,STATUS='old')
      READ(*,*)
      READ(*,*) INPUTFILE,OUTPUTFILE,NUDS,DC
      READ(*,*)
      READ(*,*) LTIME,LHEAD,LNUM,LWRT,LGR,LCL,LFR
C
C-- LHEAD CONTROLLS THE HEAD:
C   LHEAD = 0 : NHEAD,
C   LHEAD = 1 : NHEAD WRITTEN,
C   LNUM = 0 : NO PLOTNUMBERS
C   LNUM = 1 : PLOTNUMBERS WITH DESCRIPTION,
C   LNUM = 2 : PLOTNUMBERS WITHOUT DESCRIPTION,
C   LNUM = 3 : PLOTNUMBERS GIVEN BY ABCNUMI,
C   LWRT CONTROLLS WETHER THE TIME IS WRITTEN (0/1).
C   LGR DETERMINS THE SIZE OF THE PLOT:
C   LGR = 0 : SMALL
C   LGR = 1 : MEDIUM
C   LGR = 2 : BIG
C   LCL CONTROLLS WETHER ZD IS THE NUMBER OF CONTOURLINES (LCL=1) OR
C   THE DIFFERENCE BETWEEN THE CONTOUR LEVELS (LCL=0).
C   FOR LFR = 1 A FRAME IS DRAWN AROUND EACH SUBPLOT.
C   LTIME CONTROLLS TIMESERIES
C   LTIME = 0 : NORMAL
C   LTIME = -1 : TIMESERIES OF 6 PLOTS WITH TIME GIVEN INDIVIDUALLY, 
C   LTIME = 1 : TIMESERIES OF 6 PLOTS WITH TIME GIVEN BY OM,
C   LTIME = -2 : TIMESERIES OF 8 PLOTS WITH TIME GIVEN INDIVIDUALLY,
C   LTIME = 2 : TIMESERIES OF 8 PLOTS WITH TIME GIVEN BY OM.
C
      IF( LNUM.LT.0 .OR. LNUM.GT.3 ) THEN
	 WRITE(*,*) 'WRONG INPUT OF LNUM: ',LNUM
	 STOP
      ENDIF
      IF( LGR.LT.0 .OR. LGR.GT.2 ) THEN
	 WRITE(*,*) 'WRONG INPUT OF LGR: ',LGR
	 STOP
      ENDIF
      IF( LHEAD.NE.0 .AND. LHEAD.NE.1 ) THEN
	 WRITE(*,*) 'WRONG INPUT OF LHEAD: ',LHEAD
	 STOP
      ENDIF
      IF( LCL.NE.0 .AND. LCL.NE.1 ) THEN
	 WRITE(*,*) 'WRONG INPUT OF LCL: ',LCL
	 STOP
      ENDIF
      IF( LFR.NE.0 .AND. LFR.NE.1 ) THEN
	 WRITE(*,*) 'WRONG INPUT OF LFR: ',LFR
	 STOP
      ENDIF
      IF( LTIME.LT.-2 .OR. LTIME.GT.2 ) THEN
	 WRITE(*,*) 'WRONG INPUT OF LTIME: ',LTIME
	 STOP
      ENDIF
C
      OPEN(14,FILE=OUTPUTFILE,STATUS='unknown')
      write(14,*) 'Inputfile,NUDS ',INPUTFILE,NUDS
C
      RELE=1.D-9
      EPS=1.D-13
C
C-- NP1 IS NUMBER OF PLOTS, XP AND YP ARE LATITUDE AND LONGITUDE OF
C   THE POLE FOR PROJECTION OF A SPHERE ON A CIRCLE ( CP2='PL','PR','PS' ) .
      READ(*,*)
      READ(*,*) NP1,XP,YP

      if(NP1.ne.1.) then
          write(*,*) 'wrong number of plots.'
          stop
      endif
C
      IF( LTIME.GT.0 ) THEN
	 LGR=0
	 NP1=1
      ENDIF
      IF( ( LGR.EQ.0 .AND. NP1.GT.NPM ) .OR. 
     &    ( LGR.EQ.1 .AND. NP1.GT.4 ) .OR.
     &    ( LGR.EQ.2 .AND. NP1.GT.2 ) ) THEN
	 WRITE(*,*) 'TOO BIG NUMBER OF PLOTS NP1: ',NP1
	 STOP
      ENDIF
	   
C
C
      DO 20 I=1,NP1
C----- NP2 IS NUMBER OF SUBPLOTS, CP1 DESTINGUISHES BETWEEN 
C      QUADRANT (CP1='QU'), HALFSPHERE (CP1='HS') AND FULL SPHERE (CP1='SP').
C      TIME IS THE TIME OF THE PLOTTED FIELD FOR TIME DEPENDENCE.
         READ(*,*)
         READ(*,*) CP1(I),TIME(I),NP2(I)
         if(NP2(I).ne.1) then
              write(*,*) 'wrong number of plots.'
              stop
          endif
C
	 IF( NP2(I).GT.NPSM ) THEN
	    WRITE(*,*) 'TOO BIG NUMBER OF SUBPLOTS NP2:',NP2(I)
	    STOP
	 ENDIF
         IF( CP1(I).EQ.'HS' ) THEN
            NR=NR+1
         ELSE
            NQ=NQ+1
         ENDIF
C
C----- CP2 DESTINGUSHES BETWEEN QUADRANTS (CP2='Q1','Q2','Q3','Q4') ,
C      HALF SPHERES ( CP2='HL','HR','HU','HO') ,SPHERE ( CP2='SP' ) 
C      PROJECTION ON A SPHERE ( CP2=' PS','PL','PR' ) .
C      CC DETERMINS WETHER R=XC (CC='R') , PHI=XC (CC='P') OR 
C      THETA=XC (CC='T') IS KEPT CONSTANT ,
C      CFE DETERMINS THE FIELD TO BE PLOTTED:
C      'VS' : STREAMFUNCTIONS OF VELOCITY FIELD IN BUSSE NOTATION,
C      'BS' : STREAMFUNCTIONS OF MAGNETIC FIELD IN BUSSE NOTATION,
C      'JS' : STREAMFUNCTIONS OF ELECTRIC CURRENT IN BUSSE NOTATION,
C      'VR' : RADIAL VELOCITY FIELD,
C      'BR' : RADIAL MAGNETIC FIELD,
C      'TE' : TEMPERATURE FIELD Theta,
C      'ZF' : ZONAL FLOW ( Mean part of phi comp. of velocity),
C      'MF' : MERIDIONAL FLOW ( MEAN STREAM FUNCTION IN PHI=CONST. PLANE ),
C      'MT' : MEAN TOROIDAL MAGNETIC FIELD FOR PHI=CONST,
C      'BT' : TOROIDAL MAGNETIC FIELD FOR PHI=CONST,
C      'MP' : STREAMLINES OF MEAN POLOIDAL MAGNETIC FIELD FOR PHI=CONST,
C      'MJ' : STREAMLINES OF MEAN ELECTRIC CURRENT FOR PHI=CONST,
C      'MC' : CONTOUR LINES OF MEAN PHI COMPONENT OF 
C             ELECTRIC CURRENT FOR PHI=CONST,
C
C      'TT' : Temperature field Theta+Ts,
C      'UP' : Phi component of velocity,
C      'NU' : local Nusselt number for r=ri.
C
C      XRMU IS A MULTIPLIER FOR THE LARGEST RADIUS TO BE PLOTTED: RM=XRMU*RO.
C      ZD IS THE STEP FOR THE CONTOURS FOR LCL=0 OR
C      THE NUMBER OF CONTPUR LINES FOR Z>0 OR Z<0.
         DO 10 J=1,NP2(I)
            READ(*,*)
            READ(*,*) CP2(I,J),CC(I,J),XC(I,J),CFE(I,J),
     &		                        XRMU(I,J),ZD(I,J),ABCNUMI(I,J)
10       CONTINUE
20    CONTINUE
C 
C
C-- END OF PARAMETER INPUT.
C
C
C-- INPUT CHECK:
C
      DO 100 I=1,NP1
      DO 100 J=1,NP2(I)
         IF( CP1(I).NE.'QU' .AND. CP1(I).NE.'HS' .AND.
     &	 		          CP1(I).NE.'SP'  ) THEN
      	    WRITE(*,*) 'WRONG INPUT OF CP1.'
      	    WRITE(*,*) 'CHOOSE BETWEEN QUADRANT : CP1 = QU ,'
      	    WRITE(*,*) '            HALF SPHERE : CP1 = HS ,'
      	    WRITE(*,*) '                 SPHERE : CP1 = SP .'
            WRITE(*,'('' PLOT '',I3,'' , SUBPLOT '',I3)') I,J
            STOP
         ENDIF
         IF( CP2(I,J).NE.'Q1' .AND. CP2(I,J).NE.'Q2' .AND.
     &	     CP2(I,J).NE.'Q3' .AND. CP2(I,J).NE.'Q4' .AND.
     &       CP2(I,J).NE.'HU' .AND. CP2(I,J).NE.'HO' .AND.
     &       CP2(I,J).NE.'HL' .AND. CP2(I,J).NE.'HR' .AND.
     &       CP2(I,J).NE.'PL' .AND. CP2(I,J).NE.'PR' .AND.
     &       CP2(I,J).NE.'SP' .AND. CP2(I,J).NE.'PS' ) THEN
  	  WRITE(*,*) 'WRONG INPUT OF CP2.'
      	  WRITE(*,*) '  CHOOSE BETWEEN QUADRANTS : CP2 = Q1,Q2,Q3,Q4 ,'
      	  WRITE(*,*) '              HALF SPHERES : CP2 = HL,HR,HO,HU ,'
      	  WRITE(*,*) '               FULL SPHERE : CP2 = SP ,'
          WRITE(*,*) '   PROJECTION OF LEFT HALF : CP2 = PL ,'
          WRITE(*,*) '  PROJECTION OF RIGHT HALF : CP2 = PL ,'
          WRITE(*,*) ' PROJECTION OF FULL SPHERE : CP2 = PL .'
          WRITE(*,'('' PLOT '',I3,'' , SUBPLOT '',I3)') I,J
            STOP
         ENDIF
         IF( CC(I,J).NE.'P' .AND. CC(I,J).NE.'T' .AND.
     &       CC(I,J).NE.'R' ) THEN
      	    WRITE(*,*) 'WRONG INPUT OF CONSTANT COORDINATE CC.'
      	    WRITE(*,*) '          CHOOSE BETWEEN PHI : CC = P ,'
      	    WRITE(*,*) '                       THETA : CC = T ,'
      	    WRITE(*,*) '                           R : CC = R ,'
      	    WRITE(*,*) ' RADIAL FIELD FOR CONSTANT R : CC = R .'
            WRITE(*,'('' PLOT '',I3,'' , SUBPLOT '',I3)') I,J
            STOP
         ENDIF
         IF( CC(I,J).EQ.'R' ) XRMU(I,J)=1.E0
C
         IF( CC(I,J).EQ.'P' .AND. XC(I,J).GT.360.E0 ) THEN
            WRITE(*,*) 'PHI SHOULD BE GIVEN IN DEGREES <= 360.'
            WRITE(*,'('' PLOT '',I3,'' , SUBPLOT '',I3)') I,J
            STOP
         ELSEIF( CC(I,J).EQ.'T' .AND. XC(I,J).GT.180.E0 ) THEN
            WRITE(*,*) 'THETA SHOULD BE GIVEN IN DEGREES <= 180.'
            WRITE(*,'('' PLOT '',I3,'' , SUBPLOT '',I3)') I,J
            STOP
         ELSEIF(  CC(I,J).EQ.'R' .AND. 
     &	          ( XC(I,J).LT.0.E0 .OR. XC(I,J).GT.1.E0 )  )THEN
            WRITE(*,*) 'RREL SHOULD BE >=0 , <= 1 .'
            WRITE(*,*) 'RREL IS DEFINED AS: R=RI+RREL*(RO-RI).'
            WRITE(*,'('' PLOT '',I3,'' , SUBPLOT '',I3)') I,J
            STOP
         ENDIF
         IF(  CC(I,J).EQ.'P' ) THEN
      	    IF( XC(I,J).LT.0.E0 ) XC(I,J)=XC(I,J)+360.E0
     	    IF( ( CP2(I,J).EQ.'Q1' .OR. CP2(I,J).EQ.'Q4' .OR. 
     &				        CP2(I,J).EQ.'HR' ) .AND.
     &            XC(I,J).GT.180.E0 .AND. XC(I,J).LT.360.E0 ) THEN
               XC(I,J)=XC(I,J)-180.E0
     	    ELSEIF( ( CP2(I,J).EQ.'Q2' .OR. CP2(I,J).EQ.'Q3' .OR. 
     &				        CP2(I,J).EQ.'HL' ) .AND.
     &            XC(I,J).LT.180.E0 .AND. XC(I,J).GT.0.E0 ) THEN
               XC(I,J)=XC(I,J)+180.E0
            ENDIF
         ENDIF
         IF( CC(I,J).NE.'P' .AND. CFE(I,J).EQ.'MT' ) THEN
            WRITE(*,*) 'FOR  MT PHI HAS TO BE KEPT KONSTANT.'
            CC(I,J)='P'
	 ENDIF
         IF( CC(I,J).NE.'P' .AND. 
     &       ( CFE(I,J).EQ.'MP' .OR. CFE(I,J).EQ.'BT' ) ) THEN
            WRITE(*,*) 'FOR MP AND BT PHI HAS TO BE KEPT KONSTANT.'
            CC(I,J)='P'
	 ENDIF
         IF( CC(I,J).NE.'P' .AND. CFE(I,J).EQ.'MJ' ) THEN
            WRITE(*,*) 'FOR  MJ PHI HAS TO BE KEPT KONSTANT.'
            CC(I,J)='P'
	 ENDIF
         IF( CC(I,J).NE.'P' .AND. CFE(I,J).EQ.'MC' ) THEN
            WRITE(*,*) 'FOR  MC PHI HAS TO BE KEPT KONSTANT.'
            CC(I,J)='P'
	 ENDIF
         IF( CC(I,J).NE.'P' .AND. CFE(I,J).EQ.'ZF' ) THEN
            WRITE(*,*) 'FOR ZONAL FLOW PHI HAS TO BE KEPT KONSTANT.'
            CC(I,J)='P'
         ENDIF
         IF( CC(I,J).NE.'P' .AND. CFE(I,J).EQ.'MF' ) THEN
            WRITE(*,*) 
     &		'FOR MERIDIONAL FLOW PHI HAS TO BE KEPT KONSTANT.'
            CC(I,J)='P'
         ENDIF
         IF( CC(I,J).NE.'R' .AND. CFE(I,J).EQ.'NU' ) THEN
            WRITE(*,*) 
     &		'FOR NUSSELT NUMBER R HAS TO BE KEPT KONSTANT.'
            CC(I,J)='R'
         ENDIF
C
         if( CC(I,J).EQ.'R' .and. CP2(I,J)(:1).NE.'P' ) then
            write(*,*) 'For R=const the subplot must be a projection.'
            stop
         endif
C
         IF( CP1(I).EQ.'QU' ) THEN
            IF( NP2(I).GT.1 ) THEN
               WRITE(*,*) 'ONLY ONE SUBPLOT ALLOWED FOR CP1=QU.'
               WRITE(*,*) 'NP2 ASSUMED TO BE 1.'
               NP2(I)=1
            ENDIF
            IF( CC(I,J).NE.'P' .AND. CC(I,J).NE.'T' ) THEN
               WRITE(*,*) 'FOR CP1=QU ONLY CC=P OR CC=T VALID.'
               WRITE(*,'('' PLOT '',I3,'' , SUBPLOT '',I3)') I,J
               STOP
            ENDIF
            IF( CP2(I,J).NE.'Q1' .AND. CP2(I,J).NE.'Q2' .AND. 
     &	        CP2(I,J).NE.'Q3' .AND. CP2(I,J).NE.'Q4' ) THEN
               WRITE(*,*) 'FOR CP1=QU ONLY CP2=Q1,Q2,Q3,Q4 VALID.'
               WRITE(*,'('' PLOT '',I3,'' , SUBPLOT '',I3)') I,J
               STOP
            ENDIF
         ELSEIF( CP1(I).EQ.'HS' ) THEN
            IF( NP2(I).GT.2 ) THEN
               WRITE(*,*) 'ONLY TWO SUBPLOT MAXIMUM ALLOWED FOR CP1=HS.'
               WRITE(*,*) 'NP2 ASSUMED TO BE 2.'
               NP2(I)=2
            ENDIF
            IF( CC(I,J).NE.'P' .AND. CC(I,J).NE.'T' ) THEN
               WRITE(*,*) 'FOR CP1=HS ONLY CC=P OR CC=T VALID.'
               WRITE(*,'('' PLOT '',I3,'' , SUBPLOT '',I3)') I,J
               STOP
            ENDIF
            IF( CP2(I,J).NE.'Q1' .AND. CP2(I,J).NE.'Q2' .AND. 
     &	        CP2(I,J).NE.'Q3' .AND. CP2(I,J).NE.'Q4' .AND. 
     &	        CP2(I,J).NE.'HO' .AND. CP2(I,J).NE.'HU' ) THEN
               WRITE(*,*) 'FOR CP1=HS ONLY CP2=Q1,Q2,Q3,Q4,HO,HU VALID.'
               WRITE(*,'('' PLOT '',I3,'' , SUBPLOT '',I3)') I,J
               STOP
            ENDIF
            IF( CP2(I,J).EQ.'HO' .AND. CC(I,J).EQ.'P' ) THEN
               CP2(I,J)='Q1'
      	       IF( XC(I,J).GT.180.E0 ) THEN
                  XC(I,J)=XC(I,J)-180.E0
               ENDIF
               NP2(I)=NP2(I)+1
               CP2(I,NP2(I))='Q2'
               CC(I,NP2(I))=CC(I,J)
      	       IF( XC(I,J).LT.180.E0 ) THEN
                  XC(I,NP2(I))=XC(I,NP2(I))+180.E0
               ENDIF
               CFE(I,NP2(I))=CFE(I,J)
               XRMU(I,NP2(I))=XRMU(I,J)
               ZD(I,NP2(I))=ZD(I,J)
            ELSEIF( CP2(I,J).EQ.'HU' .AND. CC(I,J).EQ.'P' ) THEN
               CP2(I,J)='Q4'
      	       IF( XC(I,J).GT.180.E0 ) THEN
                  XC(I,J)=XC(I,J)-180.E0
               ENDIF
               NP2(I)=NP2(I)+1
               CP2(I,NP2(I))='Q3'
               CC(I,NP2(I))=CC(I,J)
      	       IF( XC(I,J).LT.180.E0 ) THEN
                  XC(I,NP2(I))=XC(I,NP2(I))+180.E0
               ENDIF
               CFE(I,NP2(I))=CFE(I,J)
               XRMU(I,NP2(I))=XRMU(I,J)
               ZD(I,NP2(I))=ZD(I,J)
            ENDIF
         ELSEIF( CP1(I).EQ.'SP' ) THEN
            IF( NP2(I).GT.4 ) THEN
             WRITE(*,*) 'ONLY FOUR SUBPLOT MAXIMUM ALLOWED FOR CP1=SP.'
               WRITE(*,*) 'NP2 ASSUMED TO BE 4.'
               NP2(I)=4
            ENDIF 
            IF( CP2(I,J).EQ.'HO' .AND. CC(I,J).EQ.'P' ) THEN
               CP2(I,J)='Q1'
      	       IF( CC(I,J).EQ.'P' .AND. XC(I,J).GT.180.E0 ) THEN
                  XC(I,J)=XC(I,J)-180.E0
               ENDIF
               NP2(I)=NP2(I)+1
               CP2(I,NP2(I))='Q2'
               CC(I,NP2(I))=CC(I,J)
      	       IF( CC(I,J).EQ.'P' .AND. XC(I,J).LT.180.E0 ) THEN
                  XC(I,NP2(I))=XC(I,J)+180.E0
               ENDIF
               CFE(I,NP2(I))=CFE(I,J)
               XRMU(I,NP2(I))=XRMU(I,J)
               ZD(I,NP2(I))=ZD(I,J)
            ELSEIF( CP2(I,J).EQ.'HU' .AND. CC(I,J).EQ.'P' ) THEN
               CP2(I,J)='Q4'
      	       IF( CC(I,J).EQ.'P' .AND. XC(I,J).GT.180.E0 ) THEN
                  XC(I,J)=XC(I,J)-180.E0
               ENDIF
               NP2(I)=NP2(I)+1
               CP2(I,NP2(I))='Q3'
               CC(I,NP2(I))=CC(I,J)
      	       IF( CC(I,J).EQ.'P' .AND. XC(I,J).LT.180.E0 ) THEN
                  XC(I,NP2(I))=XC(I,J)+180.E0
               ENDIF
               CFE(I,NP2(I))=CFE(I,J)
               XRMU(I,NP2(I))=XRMU(I,J)
               ZD(I,NP2(I))=ZD(I,J)
            ENDIF
         ENDIF
100   CONTINUE
C
C
C-- SETTING OF CONSTANTS:
      LTR=1
      NMC=NM
      NMSC=NM
      NAMC=NAM
      NLMAC=NLMA
C
      IF( LTIME.GT.0 ) TIME(1)=0.D0
C
C-- READLA READS THE SET OF COEFFITIENTS TO BE PLOTTED ,
C   IT IS NECESSARY TO CALL IS HERE TO GET PARAMETERS.
      TIMEO=TIME(1)
      write(*,103) 'reading data from ',INPUTFILE,NUDS,TIME(1),'...'
103   FORMAT(A,A,I3,D9.2)
      CALL READLA(INPUTFILE,NUDS,TIME(1),DX)
      write(*,*) '...done'
      RA=RAI
      TA=TAI
      PR=PRI
      PM=PMI
      ETA=ETAI
      C=CI
      OM=OMI
      FTW=FTWI
      FTG=FTGI
      MF=0
      M0=M0I
      NTV=NTVI
      NTH=NTHI
      LTV=LTVI
      LTH=LTHI
      KTV=KTVI
      KTH=KTHI
      LD=LDI
      LEV=LEVI
      LRB=LRBI
C
      IF( LTIME.GT.0 ) THEN
	 NSUBP=NP2(1)
	 IF( LCALC.NE.3 .AND. LCALC.NE.4 ) THEN
	    WRITE(*,*) 
     &        'TIMESERIES WITH LTIME.GT.0 ONLY FOR TIME EXPANSION.'
	    STOP
	 ENDIF 	
         IF( OM.LT.0.D-4 ) THEN
	    WRITE(*,*) 'OM TOO SMALL FOR LTIME.GT.0.'
	    STOP
	 ENDIF
	 IF( LTIME.EQ.1 ) THEN
	    NP1=6
	 ELSEIF( LTIME.EQ.2 ) THEN
	    NP1=8
	 ENDIF
	 TPERIOD=2*PI/OM
	 DT=TPERIOD/NP1
	 LNUM=3
	 TIME(1)=0.D0
	 ABCNUMI(1,1)='(a)'
	 DO 110 J=2,NP2(1)
110      ABCNUMI(1,J)='   '
	 DO 130 I=2,NP1
	    CP1(I)=CP1(1)
	    NP2(I)=NP2(1)
	    IF( CP1(I).EQ.'HS' ) THEN
	       NR=NR+1
	    ELSE
	       NQ=NQ+1
	    ENDIF
	    IF( I.EQ.2 ) THEN
	       TIME(I)=DT
	    ELSEIF( I.EQ.3 ) THEN
	       IF( NP1.EQ.6 ) THEN
	          TIME(I)=5*DT
	       ELSEIF( NP1.EQ.8 ) THEN
	          TIME(I)=2*DT
	       ENDIF
	    ELSEIF( I.EQ.4 ) THEN
	       IF( NP1.EQ.6 ) THEN
	          TIME(I)=2*DT
	       ELSEIF( NP1.EQ.8 ) THEN
	          TIME(I)=7*DT
	       ENDIF
	    ELSEIF( I.EQ.5 ) THEN
	       IF( NP1.EQ.6 ) THEN
	          TIME(I)=4*DT
	       ELSEIF( NP1.EQ.8 ) THEN
	          TIME(I)=3*DT
	       ENDIF
	    ELSEIF( I.EQ.6 ) THEN
	       IF( NP1.EQ.6 ) THEN
	          TIME(I)=3*DT
	       ELSEIF( NP1.EQ.8 ) THEN
	          TIME(I)=6*DT
	       ENDIF
	    ELSEIF( I.EQ.7 ) THEN
	       TIME(I)=5*DT
	    ELSEIF( I.EQ.8 ) THEN
	       TIME(I)=4*DT
	    ENDIF
	    DO 120 J=1,NP2(1)
	       CP2(I,J)=CP2(1,J)
	       CC(I,J)=CC(1,J)
	       XC(I,J)=XC(1,J)
	       CFE(I,J)=CFE(1,J)
	       XRMU(I,J)=XRMU(1,J)
	       ZD(I,J)=-ZD(1,J)
	       IF( J.EQ.1 ) THEN
	          IF( I.EQ.2 ) THEN
	             ABCNUMI(I,J)='(b)'
	          ELSEIF( I.EQ.3 ) THEN
	             IF( NP1.EQ.6 ) THEN
	                ABCNUMI(I,J)='(f)'
	             ELSEIF( NP1.EQ.8 ) THEN
	                ABCNUMI(I,J)='(c)'
	             ENDIF
	          ELSEIF( I.EQ.4 ) THEN
	             IF( NP1.EQ.6 ) THEN
	                ABCNUMI(I,J)='(c)'
	             ELSEIF( NP1.EQ.8 ) THEN
	                ABCNUMI(I,J)='(h)'
	             ENDIF
	          ELSEIF( I.EQ.5 ) THEN
	             IF( NP1.EQ.6 ) THEN
	                ABCNUMI(I,J)='(e)'
	             ELSEIF( NP1.EQ.8 ) THEN
	                ABCNUMI(I,J)='(d)'
	             ENDIF
	          ELSEIF( I.EQ.6 ) THEN
	             IF( NP1.EQ.6 ) THEN
	                ABCNUMI(I,J)='(d)'
	             ELSEIF( NP1.EQ.8 ) THEN
	                ABCNUMI(I,J)='(g)'
	             ENDIF
	          ELSEIF( I.EQ.7 ) THEN
	             ABCNUMI(I,J)='(f)'
	          ELSEIF( I.EQ.8 ) THEN
	             ABCNUMI(I,J)='(e)'
	          ENDIF
	       ELSE
                  ABCNUMI(I,J)='   '
	       ENDIF
120         CONTINUE
130      CONTINUE
      ENDIF
C
C-- CALCULATION OF INNER AND OUTER RADIUS:
      RI=ETA/(1.D0-ETA)
      RO=1.D0+RI
      XRI=DBLE(RI)
      XRO=DBLE(RO)
C
C-- ABG CALCULATES THE ALPHAS AND BETAS IN THE RADIAL FUNCTION
C   OF THE POLOIDAL MAGNETIC FIELD:
      IF( LCALC.EQ.2 .OR. LCALC.EQ.4 .OR. LCALC.EQ.6 ) 
     &			CALL ABG(ND,CF,L,N)
C
C      DO 50 I=1,ND
C50    WRITE(50,'(I3,A2,A3,4I4)') I,CF(I),CRR(I),L(I),M(I),N(I),K(I)
C
C-- WAEHLEN DES ENDGERAETES:
200   CONTINUE
C      WRITE(*,*) 'BITTE AUSGABE W\"AHLEN.'
C      WRITE(*,*) ' ENDE           0,'     
C      WRITE(*,*) ' TEKTRONIX      1,'     
C      WRITE(*,*) ' PLOTTER        2,'     
C      WRITE(*,*) ' LASER (SYS.)   3,'     
C      WRITE(*,*) ' LASER (NWII)   4,'     
C      WRITE(*,*) ' POSTSCRIPT     5.'     
C      READ(*,*) 
C      READ(*,*) NOUT
C
C     CALL SYSBUF
C     IF( NOUT.EQ.0 ) THEN
C     	 GOTO 9999
C     ELSEIF( NOUT.EQ.1 ) THEN
C         CALL TEKALL(4010,480,0,0,0)
C        CALL TEKALL_OLD(4010,480,0,0,0)
C     ELSEIF( NOUT.EQ.2 ) THEN
C     	 CALL HP7550(2)
C     ELSEIF( NOUT.EQ.3 ) THEN
C        CALL HPLJET(300,1)
C     ELSEIF( NOUT.EQ.4 ) THEN
C        CALL HPLJET(300,2)
C     ELSEIF( NOUT.EQ.5 ) THEN
C     	 CALL PSCRPT(2,1)
C     ELSE
C        WRITE(*,*) 'WRONG INPUT OF NOUT.'
C        WRITE(*,*)
C         GOTO 200
C     ENDIF
C
C-- ABINITIALISIERT SCHRIFTEN:
C     CALL AB

C-- FEHLER NACH 13 SCHREIBEN
      OPEN(13,STATUS='SCRATCH')
c     CALL SETDEV(13,13)
C
C-- BILDER IM HOCHFORMAT
c     CALL HWROT('COMIC')
C      CALL HWROT('AUTO')
C      CALL HWSCAL('SCREEN')
C
C-- VERGR/"OSSERN,EINHEITEN
C      CALL BLOWUP(1.1D0)
c     CALL UNITS('CM')
C
C-- DINA4 SEITE IM HOCHFORMAT 
C      YPAGE=29.D0
C      XPAGE=21.D0
C      CALL PAGE(XPAGE,YPAGE)
C
C-- VERDECKEN
c     CALL HIDE
C
C-- SCHRIFT TRIPLEX
c     CALL TRIPLX
C
C-- KEINE BEGRENZUNG
c     CALL NOBRDR
C
C-- DETERMINATION OF PARAMETERS FOR EACH SUBPLOT:
C
C-- XLRAND=LINKER RAND , XRRAND=RECHTER RAND , YURAND=UNTERER RAND ,
C   XINTER,YINTER=ZWISCHENRAUM ZWISCHEN PLOTS , 
C   YHR=HOEHE RECHTECK , XBR=BREITE RECHTECK ( FUER CP1='HS' ) ,
C   YHQ=HOEHE QUADRAT , BXQ=BREITE QUADRAT ( FUER CP1='QU' ODER CP1='SP' ) ,
C   YHPG=HOEHE PLOTGEBIET , XBPG=BREITE PLOTGEBIET ( OHNE KOPF ) .
      XLRAND=3.0D0
      XRRAND=3.0D0
      NROWR=NR
      NROWQ=NQ/2
      IF( MOD(NQ,2).NE.0 ) NROWQ=NROWQ+1
      IF( LTIME.NE.0 ) THEN 
	 NROWR=0
	 NROWQ=3
      ELSE 
         NROWR=NR
         NROWQ=NQ/2
         IF( MOD(NQ,2).NE.0 ) NROWQ=NROWQ+1
      ENDIF
      NROW=NROWR+NROWQ
      IF( LGR.EQ.0 .AND. NROW.GT.3 ) THEN
	 WRITE(*,*) 'TOO MANY ROWS, ONLY 3 ALLOWED FOR LGR=0.',NROW
	 STOP 
      ELSEIF( LGR.EQ.1 .AND. NROW.GT.2 ) THEN
	 WRITE(*,*) 'TOO MANY ROWS, ONLY 2 ALLOWED FOR LGR=1.',NROW
	 STOP 
      ELSEIF( LGR.EQ.2 .AND. NROW.GT.1 ) THEN
	 WRITE(*,*) 'TOO MANY ROWS, ONLY 1 ALLOWED FOR LGR=2.',NROW
	 STOP 
      ENDIF
      IF( NQ.LE.1 ) THEN
         NCOL=1
      ELSE
         NCOL=2
      ENDIF
      IF( LGR.EQ.2 .AND. NCOL.EQ.2 ) THEN
	 WRITE(*,*) 'TOO MANY COLUMNS, ONLY 1 ALLOWED FOR LGR=2.',NCOL
	 STOP 
      ENDIF
      IF( IABS(LTIME).EQ.2 ) NCOL=3
      XTEXT=XLRAND
C
C-- GROESSE DER PLOTS:
      IF( LGR.EQ.0 ) THEN
         YHR=5.5D0
      	 YHQ=5.5D0
	 XLR=2.0D0
         XLQ=1.5D0
	 XINTER=1.D0
	 YINTER=1.D0
      ELSEIF( LGR.EQ.1 ) THEN 
         YHR=6.75D0
         YHQ=6.75D0
	 XLR=0.75D0
         XLQ=0.0D0
	 XINTER=1.5D0
	 YINTER=1.5D0
      ELSEIF( LGR.EQ.2 ) THEN
         YHR=6.75D0
         YHQ=13.0
	 XLR=1.0D0
	 XINTER=0.0D0
	 YINTER=0.0D0
      ENDIF
      XBQ=YHQ
      XBR=2*YHR
C
      IF( LHEAD.EQ.0 ) THEN
	 YHKOPF=0.0D0
      ELSEIF( LHEAD.EQ.1 ) THEN
         YHKOPF=3.D0
      ENDIF
      IF( LNUM.EQ.1 ) THEN
         YHFUSS=5.0D0
      ELSE
         YHFUSS=0.0D0
      ENDIF
      YHPG=NROWR*YHR+NROWQ*YHQ+(NROW-1)*YINTER
      IF( NQ.GT.0 ) THEN
	 XBPG=2*XLQ+NCOL*XBQ+(NCOL-1)*XINTER
      ELSE
	 XBPG=2*XLR+XBR
      ENDIF
      XAREA=XLRAND+XBPG+XRRAND
      YAREA=YHFUSS+YHPG+YHKOPF
c     CALL PAGE(XAREA,YAREA)
C
C-- NZEI ZAEHLT ZEILEN , NSPA SPALTEN UND NP ZAHL DER PLOTS.
C   NQT ZAEHLT DIE ZAHL DER QUADRATE.
      NP=0
      NQT=0
C
C-- DIE DATEN FUER DIE EINZELNEN PLOTS WERDEN FESTGELEGT UND LINEAR
C   ABGESPEICHERT: URSPRUNG IN CM = (XORIG,YORIG) ,
C   PLOTGEBIET IN CM = (XAR,YAR) , RADIEN IN CM = (XRICM,XROCM,XRMCM).
      DO 2000 I=1,NP1
	 IF( I.EQ.1 ) THEN
	    NSPA=1
	    NZEI=1
	    IF( CP1(I).EQ.'HS' ) THEN 
               YHPLOT=YHR
               XBPLOT=XBR
               XLPLOT=XLR
	    ELSE
               YHPLOT=YHQ
               XBPLOT=XBQ
               XLPLOT=XLQ
	    ENDIF
	 ELSEIF( CP1(I).EQ.'HS' .OR. CP1(I-1).EQ.'HS' ) THEN
	    NSPA=1
	    NZEI=NZEI+1
	    YHPLOT=YHR
	    XBPLOT=XBR
	    XLPLOT=XLR
	 ELSE
	    IF( NSPA.EQ.NCOL ) THEN
	       NSPA=1
	       NZEI=NZEI+1
	    ELSE
	       NSPA=NSPA+1 
	       IF( IABS(LTIME).EQ.2 .AND. I.EQ.5 ) NSPA=NSPA+1
            ENDIF
	    YHPLOT=YHQ
	    XBPLOT=XBQ
	    XLPLOT=XLQ
         ENDIF
	 XORIG=XLRAND+XLPLOT+(NSPA-1)*(XBPLOT+XINTER)
	 YORIG=YHFUSS+YHPG-NZEI*YHPLOT-(NZEI-1)*YINTER

     	 IF( CP1(I).EQ.'QU' .OR. CP1(I).EQ.'SP' .AND. NCOL.GT.1 ) THEN
	    NQT=NQT+1
	    IF( NSPA.EQ.1 .AND. NQT.EQ.NQ ) XLQ=XLQ+(XBQ+XINTER)/2
         ENDIF
         DO 1000 J=1,NP2(I)
      	    NP=NP+1
      	    CPP(NP)=CP2(I,J)
            CFP(NP)=CFE(I,J)
            CCP(NP)=CC(I,J)
            ABCN(NP)=ABCNUMI(I,J)
            IF( CC(I,J).EQ.'R' ) THEN
      	       XCP(NP)=XRI+XC(I,J)
            ELSE
      	       XCP(NP)=XC(I,J)
            ENDIF
      	    ZDP(NP)=ZD(I,J)
            TIMEP(NP)=TIME(I)
            IF( CP1(I).EQ.'HS' ) THEN
      	       IF( CP2(I,J).EQ.'HO' .OR. CP2(I,J).EQ.'HU' ) THEN
      	          XOR(NP)=XORIG
                  XAR(NP)=XBR
      		  YOR(NP)=YORIG
                  YAR(NP)=YHR
                  XRMCM(NP)=XBR/2
      	       ELSEIF( CP2(I,J).EQ.'Q1' ) THEN
      	          XOR(NP)=XORIG+XBR/2
                  XAR(NP)=XBR/2
      		  YOR(NP)=YORIG
                  YAR(NP)=YHR
                  XRMCM(NP)=XBR/2
      	       ELSEIF( CP2(I,J).EQ.'Q2' ) THEN
      	          XOR(NP)=XORIG
                  XAR(NP)=XBR/2
      		  YOR(NP)=YORIG
                  YAR(NP)=YHR
                  XRMCM(NP)=XBR/2
      	       ELSEIF( CP2(I,J).EQ.'Q3' ) THEN
      	          XOR(NP)=XORIG
                  XAR(NP)=XBR/2
      		  YOR(NP)=YORIG
                  YAR(NP)=YHR
                  XRMCM(NP)=XBR/2
      	       ELSEIF( CP2(I,J).EQ.'Q4' ) THEN
      	          XOR(NP)=XORIG+XBR/2
                  XAR(NP)=XBR/2
      		  YOR(NP)=YORIG
                  YAR(NP)=YHR
                  XRMCM(NP)=XBR/2
               ENDIF
            ELSEIF( CP1(I).EQ.'QU' ) THEN
      	       XOR(NP)=XORIG
               XAR(NP)=XBQ
      	       YOR(NP)=YORIG
               YAR(NP)=YHQ
               XRMCM(NP)=XBQ
            ELSEIF( CP1(I).EQ.'SP' ) THEN
      	       IF( CP2(I,J).EQ.'Q1' ) THEN
      	          XOR(NP)=XORIG+XBQ/2
                  XAR(NP)=XBQ/2
      	          YOR(NP)=YORIG+YHQ/2
                  YAR(NP)=YHQ/2
                  XRMCM(NP)=XBQ/2
      	       ELSEIF( CP2(I,J).EQ.'Q2' ) THEN
      	          XOR(NP)=XORIG
                  XAR(NP)=XBQ/2
      	          YOR(NP)=YORIG+YHQ/2
                  YAR(NP)=YHQ/2
                  XRMCM(NP)=XBQ/2
      	       ELSEIF( CP2(I,J).EQ.'Q3' ) THEN
      	          XOR(NP)=XORIG
                  XAR(NP)=XBQ/2
      	          YOR(NP)=YORIG
                  YAR(NP)=YHQ/2
                  XRMCM(NP)=XBQ/2
      	       ELSEIF( CP2(I,J).EQ.'Q4' ) THEN
      	          XOR(NP)=XORIG+XBQ/2
                  XAR(NP)=XBQ/2
      	          YORIG=YORIG
      	          YOR(NP)=YORIG
                  YAR(NP)=YHQ/2
                  XRMCM(NP)=XBQ/2
               ELSEIF( CP2(I,J).EQ.'HU' ) THEN
      	          XOR(NP)=XORIG
                  XAR(NP)=XBQ
      	          YOR(NP)=YORIG
                  YAR(NP)=YHQ/2      	
                  XRMCM(NP)=XBQ/2
               ELSEIF( CP2(I,J).EQ.'HO' ) THEN
      	          XOR(NP)=XORIG
                  XAR(NP)=XBQ
      	          YOR(NP)=YORIG+YHQ/2
                  YAR(NP)=YHQ/2      
                  XRMCM(NP)=XBQ/2
               ELSEIF( CP2(I,J).EQ.'HL' ) THEN
      	          XOR(NP)=XORIG
                  XAR(NP)=XBQ/2
      	          YOR(NP)=YORIG
                  YAR(NP)=YHQ
                  XRMCM(NP)=XBQ/2
               ELSEIF( CP2(I,J).EQ.'HR' ) THEN
      	          XOR(NP)=XORIG+XBQ/2
                  XAR(NP)=XBQ/2
      	          YOR(NP)=YORIG
                  YAR(NP)=YHQ      		
                  XRMCM(NP)=XBQ/2
               ELSEIF( CP2(I,J).EQ.'SP' .OR. CP2(I,J).EQ.'PS' .OR.
     &		       CP2(I,J).EQ.'PL' ) THEN
	          XOR(NP)=XORIG
                  XAR(NP)=XBQ
      	          YOR(NP)=YORIG
                  YAR(NP)=YHQ      		
                  XRMCM(NP)=XBQ/2
               ELSEIF( CP2(I,J).EQ.'PR' ) THEN
	          XOR(NP)=XORIG
                  XAR(NP)=XBQ
      	          YOR(NP)=YORIG
                  YAR(NP)=YHQ      		
                  XRMCM(NP)=XBQ/2
               ENDIF	  
            ENDIF
            XRM(NP)=XRMU(I,J)*XRO
            XROCM(NP)=XRMCM(NP)*XRO/XRM(NP)
            XRICM(NP)=XRMCM(NP)*XRI/XRM(NP)
1000     CONTINUE
2000  CONTINUE
C
c      DO 2100 I=1,NP
c2100  WRITE(60,'(X,A3,A2,A2,4E14.4)') CPP(I),CFP(I),CCP(I),XOR(I),
c     &				      YOR(I),XAR(I),YAR(I)
C 
C
C-- SCHREIBEN DES KOPFES:
c     IF( LHEAD.EQ.1 ) THEN
c        YTEXT=YHFUSS+YHPG+YHKOPF-1.E0
c        CALL PHYSOR(0.0E0,0.0E0)
c        CALL AREA2D(XAREA,YAREA)
c        CALL HEIGHT(0.3)
c        CALL MESSAG('Ta =',100.,XTEXT,YTEXT)
c        CALL REALNO(REAL(TA),-3,'ABUT','ABUT')
c        CALL MESSAG(' ,  Ra =',100.,'ABUT','ABUT')
c        CALL REALNO(REAL(RA),3,'ABUT','ABUT')
c        CALL MESSAG(' ,  Pr =',100.,'ABUT','ABUT')
c        CALL REALNO(REAL(PR),3,'ABUT','ABUT')
c        CALL MESSAG(' ,  Pm =',100.,'ABUT','ABUT')
c        CALL REALNO(REAL(PM),3,'ABUT','ABUT')
c
c        YTEXT=YTEXT-0.7E0
c        CALL MESSAG('M0 = ',5,XTEXT,YTEXT)
c        CALL INTNO(M0,'ABUT','ABUT')
c        CALL MESSAG(' ,  Ntv = ',10,'ABUT','ABUT')
c        CALL INTNO(NTV,'ABUT','ABUT')
c        CALL MESSAG(' ,  Nth = ',10,'ABUT','ABUT')
c        CALL INTNO(NTH,'ABUT','ABUT')
c        CALL MESSAG(' ,  {M7}c{M0} =',100.,'ABUT','ABUT')
c        CALL REALNO(REAL(ETA),2,'ABUT','ABUT')
c        CALL MESSAG(' ,  c =',100.,'ABUT','ABUT')
c        CALL REALNO(REAL(C),3,'ABUT','ABUT')
c        IF( OM.NE.0.D0 ) THEN
c           PERIOD=2*PI/OM
c           CALL MESSAG(' ,  T =',100.,'ABUT','ABUT')
c           CALL REALNO(REAL(PERIOD),3,'ABUT','ABUT')
c        ENDIF
c
c        YTEXT=YTEXT-0.9E0
c        CALL MESSAG('DATAFILE = ',11,XTEXT+9.E0,YTEXT)
c        CALL MESSAG(INPUTFILE,100,'ABUT','ABUT')
c
c        CALL ENDGR(0)
c     ENDIF
C
         YTEXT=YHFUSS-1.0E0
C
C-- PLO FUEHRT DIE EINZELNEN SUBPLOTS AUS:
C
      DO 3000 I=1,NP
C
      write(14,*) 'Plot Nr. ',I,':'
C
C-- READLA READS THE SET OF COEFFITIENTS TO BE PLOTTED .
C   IF THIS IT IS A TIMEINTEGRATION AND THE TIMES DIFFER 
C   READLA HAS TO BE CALLED FOR EVERY TIME.
C      DO 3100 J=1,ND
C3100  WRITE(51,'(I3,A2,A3,4I3,D16.6)') 
C     &            J,CF(J),CRR(J),L(J),M(J),N(J),K(J),DX(J)
C
         IF( TIMEP(I).NE.TIMEO .AND. LT.EQ.1 ) THEN
            CALL READLA(INPUTFILE,NUDS,TIMEP(I),DX)
         ENDIF
C
         CALL PLO(I,NSUBP,DC,DX,LCL,LGR,LFR,
     &		  ZDP(I),TIMEP(I),CPP(I),CFP(I),CCP(I),XCP(I),
     & 		  XOR(I),YOR(I),XAR(I),YAR(I),
     &		  XRI,XRO,XRM(I),XRICM(I),XROCM(I),XRMCM(I),XP,YP)

C
C-- BESCHRIFTUNG SUBPLOT: BUCHSTABE IM PLOT AN POSITION (XNUM,YNUM) ,
C   BESCHRIFTUNG UNTER BUCHSTABE UNTEN AUF SEITE.
 	 IF( LNUM.GT.0 ) THEN
c	    CALL HEIGHT(0.3)
             IF( CPP(I).EQ.'Q1' ) THEN
       	       XNUM=XOR(I)+XAR(I)-0.9E0
       	       YNUM=YOR(I)+YAR(I)-0.5E0
 	       XTIME=XNUM-2.E0
 	       YTIME=YNUM+0.8E0        
             ELSEIF( CPP(I).EQ.'Q2' ) THEN
       	       XNUM=XOR(I)+0.25E0
       	       YNUM=YOR(I)+YAR(I)-0.5E0
 	       XTIME=XNUM
 	       YTIME=YNUM+0.8E0        
             ELSEIF( CPP(I).EQ.'Q3' ) THEN
       	       XNUM=XOR(I)+0.25E0
       	       YNUM=YOR(I)+0.2E0
 	       XTIME=XNUM
 	       YTIME=YNUM-1.0E0        
             ELSEIF( CPP(I).EQ.'Q4' ) THEN
       	       XNUM=XOR(I)+XAR(I)-0.9E0
       	       YNUM=YOR(I)+0.3E0
 	       XTIME=XNUM-2.E0
 	       YTIME=YNUM-1.0E0        
             ELSEIF( CPP(I).EQ.'HO' ) THEN
       	       XNUM=XOR(I)+0.25E0
       	       YNUM=YOR(I)+YAR(I)-0.5E0
 	       XTIME=XNUM
 	       YTIME=YNUM+0.8E0        
             ELSEIF( CPP(I).EQ.'HU' ) THEN
       	       XNUM=XOR(I)+0.25E0
       	       YNUM=YOR(I)+0.2E0
                XTIME=XNUM
 	       YTIME=YNUM-1.0E0        
             ELSEIF( CPP(I).EQ.'HL' .OR. CPP(I).EQ.'PL' ) THEN
       	       XNUM=XOR(I)+0.25E0
       	       YNUM=YOR(I)+YAR(I)-0.5E0
 	       XTIME=XNUM
 	       YTIME=YNUM+0.8E0        
             ELSEIF( CPP(I).EQ.'HR' .OR. CPP(I).EQ.'PR' ) THEN
       	       XNUM=XOR(I)+XAR(I)-0.9E0
       	       YNUM=YOR(I)+YAR(I)-0.5E0
 	       XTIME=XNUM-2.E0
 	       YTIME=YNUM+0.8E0        
             ELSEIF( CPP(I).EQ.'SP' .OR. CPP(I).EQ.'PS' ) THEN
       	       XNUM=XOR(I)+0.25E0
       	       YNUM=YOR(I)+YAR(I)-0.5E0
 	       XTIME=XNUM
 	       YTIME=YNUM+0.8E0                 
             ENDIF
c            CALL PHYSOR(0.0E0,0.0E0)
c            CALL AREA2D(XAREA,YAREA)
c	    IF( LWRT.EQ.1 .AND. 
c     &		( TIMEP(I).NE.TIMEO .OR. I.EQ.1 ) ) THEN
c               CALL MESSAG('t= ',100.,XTIME,YTIME)
c               CALL REALNO(REAL(TIMEP(I)),5,'ABUT','ABUT')
c	    ENDIF
c            IF( LNUM.LT.3 ) THEN
c               IF( I.EQ.1 ) THEN
c                  ABCNUM='(a)'
c               ELSEIF( I.EQ.2 ) THEN
c                  ABCNUM='(b)'
c               ELSEIF( I.EQ.3 ) THEN
c                  ABCNUM='(c)'
c               ELSEIF( I.EQ.4 ) THEN
c                  ABCNUM='(d)'
c               ELSEIF( I.EQ.5 ) THEN
c                  ABCNUM='(e)'
c               ELSEIF( I.EQ.6 ) THEN
c                  ABCNUM='(f)'
c               ELSEIF( I.EQ.7 ) THEN
c                  ABCNUM='(g)'
c               ELSEIF( I.EQ.8 ) THEN
c                  ABCNUM='(h)'
c               ELSEIF( I.EQ.9 ) THEN
c                  ABCNUM='(i)'
c               ELSEIF( I.EQ.10 ) THEN
c                  ABCNUM='(j)'
c               ELSEIF( I.EQ.11 ) THEN
c                  ABCNUM='(k)'
c               ELSEIF( I.EQ.12 ) THEN
c                  ABCNUM='(l)'
c               ELSEIF( I.EQ.13 ) THEN
c                  ABCNUM='(m)'
c               ELSEIF( I.EQ.14 ) THEN
c                  ABCNUM='(n)'
c               ELSEIF( I.EQ.15 ) THEN
c                  ABCNUM='(o)'
c               ELSEIF( I.EQ.16 ) THEN
c                  ABCNUM='(p)'
c               ELSEIF( I.EQ.17 ) THEN
c                  ABCNUM='(q)'
c               ELSEIF( I.EQ.18 ) THEN
c                  ABCNUM='(r)'
c               ELSEIF( I.EQ.19 ) THEN
c                  ABCNUM='(s)'
c               ELSEIF( I.EQ.20 ) THEN
c                  ABCNUM='(t)'
c               ELSE
c                  ABCNUM='(x)'
c               ENDIF
c            ELSEIF( LNUM.EQ.3 ) THEN
c               ABCNUM=ABCN(I)
c            ENDIF
c            CALL MESSAG(ABCNUM,3.,XNUM,YNUM)
 	    IF( LNUM.EQ.1 ) THEN
cccc            YTEXT=YHFUSS-1.0E0
c	       CALL MESSAG(ABCNUM,3.,XTEXT,YTEXT)
                IF( CFP(I).EQ.'BR' ) THEN
                   CTEXT1='  Contours of radial magnetic field for '
                ELSEIF( CFP(I).EQ.'BR' ) THEN
                   CTEXT1='  Contours of toriodal magnetic field for '
                ELSEIF( CFP(I).EQ.'BS' ) THEN
                   CTEXT1='  Magnetic field lines in the plane '
                ELSEIF( CFP(I).EQ.'VR' ) THEN
                   CTEXT1='  Contours of radial velocity field for '
                ELSEIF( CFP(I).EQ.'VS' ) THEN
                   CTEXT1='  Streamlines in the plane  '
                ELSEIF( CFP(I).EQ.'VS' ) THEN
            CTEXT1='  Streamlines of electric current in the plane  '
                ELSEIF( CFP(I).EQ.'TE' ) THEN
                   CTEXT1='  Temperature field '
                ELSEIF( CFP(I).EQ.'ZF' ) THEN
                   CTEXT1='  Mean zonal flow '
                ELSEIF( CFP(I).EQ.'MF' ) THEN
                   CTEXT1='  Mean meridional flow '
                ELSEIF( CFP(I).EQ.'MT' ) THEN
                   CTEXT1='  Mean toroidal magnetic field '
                ELSEIF( CFP(I).EQ.'MP' ) THEN
                CTEXT1='  Fieldlines of mean poloidal magnetic field '
                ELSEIF( CFP(I).EQ.'MJ' ) THEN
                   CTEXT1='  Fieldlines of mean electric current'
                ELSEIF( CFP(I).EQ.'MC' ) THEN
            CTEXT1='  Contourlines of mean phi comp. of elec. curr.'
                ELSEIF( CFP(I).EQ.'TT' ) THEN
            CTEXT1='  Temperature field including basic state for '
                ELSEIF( CFP(I).EQ.'UP' ) THEN
                   CTEXT1='  Contours of U{M7}v{M0} for '
                ELSEIF( CFP(I).EQ.'NU' ) THEN
                   CTEXT1='  Contours of local nusselt number for '
                   XCP(I)=REAL(ETA/(1.D0-ETA))
                ENDIF
c               CALL MESSAG(CTEXT1,100.,'ABUT','ABUT')
                IF( CCP(I).EQ.'P') THEN
c                  CALL MESSAG(' {M7}v{M0} =',100.,'ABUT','ABUT')
                   CTEXT2='phi ='
                ELSEIF( CCP(I).EQ.'T') THEN
c                  CALL MESSAG(' {M7}Q{M0} =',100.,'ABUT','ABUT')
                   CTEXT2='theta ='
                ELSEIF( CCP(I).EQ.'R' ) THEN
c                  CALL MESSAG(' r =',100.,'ABUT','ABUT')
                   CTEXT2='r ='
                ENDIF
c               CALL REALNO(REAL(XCP(I)),2,'ABUT','ABUT')
c               IF( LWRT.EQ.1 ) THEN
c                CALL MESSAG(' , relative time =',100.,'ABUT','ABUT')
c                  CALL REALNO(REAL(TIMEP(I)),4,'ABUT','ABUT')
c               ENDIF
                write(14,*) CTEXT1,CTEXT2,XCP(I)
                write(*,*) CTEXT1,CTEXT2,XCP(I)
 	    ENDIF
c            CALL ENDGR(0)
             YTEXT=YTEXT-0.5E0
 	 ENDIF
          TIMEO=TIMEP(I)
3000  CONTINUE
cC
c     CALL DONEPL
C
      CLOSE(11)
      CLOSE(14)
      CLOSE(13)
C
C      GOTO 200
9999  CONTINUE
C
      END
C
C----------------------------------------------------------------------
C-- END OF LARA
C----------------------------------------------------------------------
C
C
***********************************************************************
      SUBROUTINE PLO(NPLOT,NSUBP,DC,DX,LCL,LGR,LFR,ZD,TIME,CP,CF,CC,XC,
     &        XOR,YOR,XAR,YAR,XRI,XRO,XRM,XRICM,XROCM,XRMCM,XP,YP)
*
*     calculates the field Z and makes one subplot.
*
***********************************************************************
C
C----------------------------------------------------------------------
      IMPLICIT REAL*8(A-H,O-W)
      IMPLICIT REAL*8(X,Y,Z)
      CHARACTER*1 CC,CCC
      CHARACTER*2 CP,CF,CPC
      character*20 filez,filex,filey
      PARAMETER(NMX=65,NMY=128)
C     PARAMETER(NMX=101,NMY=51)
      PARAMETER (PI=3.14159265358979D0)
C
      DIMENSION DX(*),THETA(NMY),XIDL(NMX,NMY),YIDL(NMX,NMY)
      DIMENSION Z(NMX,NMY),XML(2),YML(2),ZDS(4)
C
      COMMON/PLOTC/ZDO,NCPLOT
      COMMON/PARI/RA,TA,PR,PM,ETA,C,OM,FTW,FTG,MF
CCCCC COMMON/TRANSC/CPC,CCC,XCC,XARC,YARC,XMIN,XMAX,YMIN,YMAX
      COMMON/CNULL/ZNULL
      integer on_a_sphere
      COMMON/THETAC/THETA
C
C-- COUNTER
      NCPLOT=NCPLOT+1
      WRITE(14,'(2X,''TIME= '',2D16.6)') TIME
C
C-- UEBERGABE AN COMMONBLOCK FUER TRANS:
      CCC=CC
      CPC=CP
      XCC=XC
C
C-- INITIALISIERUNG VON DISSPLA UND ZEICHNEN EINES RAHMENS (FRAME):
c     CALL PHYSOR(XOR,YOR)
c     CALL AREA2D(XAR,YAR)
c     IF( LFR.EQ.1 ) THEN
c        CALL THKFRM(0.02E0)
c        CALL FRAME
c     ENDIF
      DXY=XRO/100
C
C-- FESTLEGEN DER X BZW Y ACHSE UND ZEICHNEN DES INNEREN UND
C   AEUSSEREN KERNS MIT ARC:
      IF( CP.EQ.'Q1' ) THEN
c        CALL THKCRV(0.01E0)
c        CALL GRAF(0.E0,DXY,XRM,0.E0,DXY,XRM)
         XML(1)=XRI
         YML(1)=0.E0
         XML(2)=XRO
         YML(2)=0.E0
c        CALL CURVE(XML,YML,2,0)
         XML(1)=0.E0
         YML(1)=XRI
         XML(2)=0.E0
         YML(2)=XRO
c        CALL CURVE(XML,YML,2,0)
c        CALL RESET('THKCRV')
         XMIN=XRI
         XMAX=XRM
         IF( CC.EQ.'T' ) THEN
      	    YMIN=90.E0
            YMAX=180.E0
         ELSEIF( CC.EQ.'P' ) THEN
      	    YMIN=0.E0
            YMAX=90.E0
         ENDIF
c        CALL ARC(0.E0,0.E0,XRICM,0.E0,90.E0,'NONE',0.01E0)
c        CALL ARC(0.E0,0.E0,XROCM,0.E0,90.E0,'NONE',0.01E0)
c        CALL THKCRV(0.01E0)
      ELSEIF( CP.EQ.'Q2' ) THEN
         XMIN=XRI
      	 XMAX=XRM
         IF( CC.EQ.'T' ) THEN
      	    YMIN=180.E0
            YMAX=270.E0
         ELSEIF( CC.EQ.'P' ) THEN
      	    YMIN=0.E0
            YMAX=90.E0
         ENDIF
c        CALL ARC(XRMCM,0.E0,XRICM,90.E0,180.E0,'NONE',0.01E0)
c        CALL ARC(XRMCM,0.E0,XROCM,90.E0,180.E0,'NONE',0.01E0)
c        CALL THKCRV(0.01E0)
c        CALL GRAF(-XRM,DXY,0.E0,0.E0,DXY,XRM)
         XML(1)=-XRO
         YML(1)=0.E0
         XML(2)=-XRI
         YML(2)=0.E0
c        CALL CURVE(XML,YML,2,0)
         XML(1)=0.E0
         YML(1)=XRI
         XML(2)=0.E0
         YML(2)=XRO
c        CALL CURVE(XML,YML,2,0)
c        CALL RESET('THKCRV')
      ELSEIF( CP.EQ.'Q3' ) THEN
         XMIN=XRI
      	 XMAX=XRM
         IF( CC.EQ.'T' ) THEN
      	    YMIN=270.E0
            YMAX=360.E0
         ELSEIF( CC.EQ.'P' ) THEN
      	    YMIN=90.E0
            YMAX=180.E0
         ENDIF
c        CALL ARC(XRMCM,XRMCM,XRICM,180.E0,270.E0,'NONE',0.01E0)
c        CALL ARC(XRMCM,XRMCM,XROCM,180.E0,270.E0,'NONE',0.01E0)
c        CALL THKCRV(0.01E0)
c        CALL GRAF(-XRM,DXY,0.E0,-XRM,DXY,0.E0)
         XML(1)=-XRO
         YML(1)=0.E0
         XML(2)=-XRI
         YML(2)=0.E0
c        CALL CURVE(XML,YML,2,0)
         XML(1)=0.E0
         YML(1)=-XRI
         XML(2)=0.E0
         YML(2)=-XRO
c        CALL CURVE(XML,YML,2,0)
c        CALL RESET('THKCRV')
      ELSEIF( CP.EQ.'Q4' ) THEN
         XMIN=XRI
      	 XMAX=XRM
         IF( CC.EQ.'T' ) THEN
      	    YMIN=0.E0
            YMAX=90.E0
         ELSEIF( CC.EQ.'P' ) THEN
      	    YMIN=90.E0
            YMAX=180.E0
         ENDIF
c        CALL ARC(0.E0,XRMCM,XRICM,270.E0,360.E0,'NONE',0.01E0)
c        CALL ARC(0.E0,XRMCM,XROCM,270.E0,360.E0,'NONE',0.01E0)
c        CALL THKCRV(0.01E0)
c        CALL GRAF(0.E0,DXY,XRM,-XRM,DXY,0.E0)
         XML(1)=XRI
         YML(1)=0.E0
         XML(2)=XRO
         YML(2)=0.E0
c        CALL CURVE(XML,YML,2,0)
         XML(1)=0.E0
         YML(1)=-XRI
         XML(2)=0.E0
         YML(2)=-XRO
c        CALL CURVE(XML,YML,2,0)
c        CALL RESET('THKCRV')
      ELSEIF( CP.EQ.'HO' ) THEN
         XMIN=XRI
      	 XMAX=XRM
         IF( CC.EQ.'T' ) THEN
      	    YMIN=90.E0-XP
            YMAX=270.E0-XP
         ELSEIF( CC.EQ.'P' ) THEN
      	    YMIN=0.E0
            YMAX=90.E0
         ENDIF
c        CALL ARC(XRMCM,0.E0,XRICM,0.E0,180.E0,'NONE',0.01E0)
c        CALL ARC(XRMCM,0.E0,XROCM,0.E0,180.E0,'NONE',0.01E0)
c        CALL THKCRV(0.01E0)
c        CALL GRAF(-XRM,DXY,XRM,0.E0,DXY,XRM)
         XML(1)=-XRO
         YML(1)=0.E0
         XML(2)=-XRI
         YML(2)=0.E0
c        CALL CURVE(XML,YML,2,0)
         XML(1)=XRI
         YML(1)=0.E0
         XML(2)=XRO
         YML(2)=0.E0
c        CALL CURVE(XML,YML,2,0)
c        CALL RESET('THKCRV')
      ELSEIF( CP.EQ.'HU' ) THEN
         XMIN=XRI
      	 XMAX=XRM
         IF( CC.EQ.'T' ) THEN
      	    YMIN=270.E0-XP
            YMAX=450.E0-XP
         ELSEIF( CC.EQ.'P' ) THEN
      	    YMIN=90.E0
            YMAX=180.E0
         ENDIF
c        CALL ARC(XRMCM,XRMCM,XRICM,180.E0,360.E0,'NONE',0.01E0)
c        CALL ARC(XRMCM,XRMCM,XROCM,180.E0,360.E0,'NONE',0.01E0)
c        CALL THKCRV(0.01E0)
c        CALL GRAF(-XRM,DXY,XRM,-XRM,DXY,0.E0)
         XML(1)=-XRO
         YML(1)=0.E0
         XML(2)=-XRI
         YML(2)=0.E0
c        CALL CURVE(XML,YML,2,0)
         XML(1)=XRI
         YML(1)=0.E0
         XML(2)=XRO
         YML(2)=0.E0
c        CALL CURVE(XML,YML,2,0)
c        CALL RESET('THKCRV')
      ELSEIF( CP.EQ.'HL' ) THEN
         XMIN=XRI
      	 XMAX=XRM
         IF( CC.EQ.'T' ) THEN
      	    YMIN=180.E0
            YMAX=360.E0
         ELSEIF( CC.EQ.'P' ) THEN
      	    YMIN=0.E0
            YMAX=180.E0
         ENDIF
c        CALL ARC(XRMCM,XRMCM,XRICM,90.E0,270.E0,'NONE',0.01E0)
c        CALL ARC(XRMCM,XRMCM,XROCM,90.E0,270.E0,'NONE',0.01E0)
c        CALL THKCRV(0.01E0)
c        CALL GRAF(-XRM,DXY,0.E0,-XRM,DXY,XRM)
         XML(1)=0.D0
         YML(1)=-XRO
         XML(2)=0.D0
         YML(2)=-XRI
c        CALL CURVE(XML,YML,2,0)
         XML(1)=0.E0
         YML(1)=XRI
         XML(2)=0.E0
         YML(2)=XRO
c        CALL CURVE(XML,YML,2,0)
c        CALL RESET('THKCRV')
      ELSEIF( CP.EQ.'HR' ) THEN
         XMIN=XRI
      	 XMAX=XRM
         IF( CC.EQ.'T' ) THEN
      	    YMIN=0.E0
            YMAX=180.E0
         ELSEIF( CC.EQ.'P' ) THEN
      	    YMIN=0.E0
            YMAX=180.E0
         ENDIF
c        CALL ARC(0.E0,XRMCM,XRICM,-90.E0,90.E0,'NONE',0.01E0)
c        CALL ARC(0.E0,XRMCM,XROCM,-90.E0,90.E0,'NONE',0.01E0)
c        CALL THKCRV(0.01E0)
c        CALL GRAF(0.E0,DXY,XRM,-XRM,DXY,XRM)
         XML(1)=0.E0
         YML(1)=-XRO
         XML(2)=0.E0
         YML(2)=-XRI
c        CALL CURVE(XML,YML,2,0)
         XML(1)=0.E0
         YML(1)=XRI
         XML(2)=0.E0
         YML(2)=XRO
c        CALL CURVE(XML,YML,2,0)
c        CALL RESET('THKCRV')
      ELSEIF( CP.EQ.'SP' ) THEN
         XMIN=XRI
      	 XMAX=XRM
         IF( CC.EQ.'T' ) THEN
      	    YMIN=0.E0
            YMAX=360.E0
         ELSEIF( CC.EQ.'P' ) THEN
      	    YMIN=0.E0
            YMAX=180.E0
         ENDIF
c        CALL ARC(XRMCM,XRMCM,XRICM,0.E0,360.E0,'NONE',0.01E0)
c        CALL ARC(XRMCM,XRMCM,XROCM,0.E0,360.E0,'NONE',0.01E0)
      ELSEIF( CP.EQ.'PS' ) THEN
         XMIN=-180.E0-XP
      	 XMAX=180.E0-XP
         YMIN=180.E0-YP
         YMAX=0.E0-YP
      ELSEIF( CP.EQ.'PL' ) THEN
         XMIN=-180.E0-XP
      	 XMAX=180.E0-XP
         YMIN=180.E0-YP
         YMAX=0.E0-YP
c        CALL THKCRV(0.01E0)
c        CALL GRAF(0.E0,DXY,1.E0,0.E0,DXY,1.E0)
         XML(1)=0.5E0
         YML(1)=0.E0
         XML(2)=0.5E0
         YML(2)=1.E0
c        CALL CURVE(XML,YML,2,0)
c        CALL RESET('THKCRV')
C----- SOLL NUR EINE HAELFTE DER KUGELPROJEKTION GEZEICHNET WERDEN,
C      SO WIRD DIE ANDERE DURCH BLANKING ( CALL BLREC ) GESCHUETZT.
c        CALL BLREC(0.0E0+XRMCM,0.0E0,XRMCM,2*XRMCM,0)
      ELSEIF( CP.EQ.'PR' ) THEN
         XMIN=-180.E0-XP
      	 XMAX=180.E0-XP
         YMIN=180.E0-YP
         YMAX=0.E0-YP
c        CALL THKCRV(0.01E0)
c        CALL GRAF(0.E0,DXY,1.E0,0.E0,DXY,1.E0)
         XML(1)=0.5E0
         YML(1)=0.E0
         XML(2)=0.5E0
         YML(2)=1.E0
c        CALL CURVE(XML,YML,2,0)
c        CALL RESET('THKCRV')
c        CALL BLREC(0.0E0,0.0E0,XRMCM,2*XRMCM,0)
      ENDIF
c     CALL ENDGR(0)
C
C-- IST DER MAXIMALE RADIUS XRM GROESSER ALS DER AEUSSERE RADIUS RO
C   UND EXISTIERT ABER NUR FUER R<=RO EIN FELD , SO MUESSEN DAS
C   PLOTGEBIET UND DER URSPRUNG ENTSPRECHEND ANGEPASST WERDEN.
C   TEILWEISE WIRD ZUDEM DIE X-ACHSE AUF R<=RO EINGESCHRAENKT.
      IF( ( ( CF.NE.'BS' .AND. CF.NE.'MP' ) .OR. 
     &      ( CF.EQ.'BS' .AND. CC.EQ.'R' ) ) .AND.
     &	   				    XROCM.NE.XRMCM ) THEN
         IF( CP(:1).EQ.'Q' ) THEN
            XAR=XROCM
            YAR=XROCM
            XMAX=XRO
            IF( CP.EQ.'Q2' ) THEN
               XOR=XOR+XRMCM-XROCM
            ELSEIF( CP.EQ.'Q3' ) THEN
               XOR=XOR+XRMCM-XROCM
               YOR=YOR+XRMCM-XROCM
            ELSEIF( CP.EQ.'Q4' ) THEN
               YOR=YOR+XRMCM-XROCM
            ENDIF
         ELSEIF( CP.EQ.'HL' ) THEN
      	    XAR=XROCM
            YAR=2*XROCM
            XMAX=XRO
            XOR=XOR+XRMCM-XROCM
            YOR=YOR+XRMCM-XROCM
         ELSEIF( CP.EQ.'HR' ) THEN
      	    XAR=XROCM
            YAR=2*XROCM
            XMAX=XRO
            YOR=YOR+XRMCM-XROCM
         ELSEIF( CP.EQ.'HO' ) THEN
      	    XAR=2*XROCM
            YAR=XROCM
            XMAX=XRO
            XOR=XOR+XRMCM-XROCM
         ELSEIF( CP.EQ.'HU' ) THEN
      	    XAR=2*XROCM
            YAR=XROCM
            XMAX=XRO
            XOR=XOR+XRMCM-XROCM
            YOR=YOR+XRMCM-XROCM   
         ELSEIF( CP.EQ.'SP' .OR. CP(:1).EQ.'P' ) THEN
      	    XAR=2*XROCM
            YAR=2*XROCM
            IF( CP.EQ.'SP' ) XMAX=XRO
            XOR=XOR+XRMCM-XROCM
            YOR=YOR+XRMCM-XROCM        
         ENDIF
      ENDIF    
      XARC=XAR
      YARC=YAR

      write(*,*) 'computing the fields...'
C
C
C-- BERECHNEN DER Z-WERTE FUER EIN RASTER MIT JE NXM PUNKTEN IN
C   X-RICHTUNG UND NYM PUNKTEN IN Y-RICHTUNG:
C   THETA WIRD EIN INTEGER NTHETA ZUGEORDNET UNTER DEM PLM(THETA)
C   ABGESPEICHERT WIRD, NMTHETA IST DIE ANZAHL DER BENOETIGTEN THETA.
C
      IF( CC.EQ.'T' ) THEN
         NMTHETA=1
         THETA(NMTHETA)=DBLE(XC)
      ELSEIF( CC.EQ.'P' ) THEN
         PHI=DBLE(XC)
      ELSEIF( CC.EQ.'R' ) THEN
         R=DBLE(XC)      
      ENDIF
      XD=(XMAX-XMIN)/(NMX-1)
      YD=(YMAX-YMIN)/(NMY-1)
      IF( CC.NE.'T' ) THEN
         NMTHETA=NMY
         DO 100 I=1,NMTHETA
 100        THETA(I)=DBLE(YMIN+(I-1)*YD)
      ENDIF
C
C-- BESTIMMUNG DER PLM(THETA) , ABSPEICHERUNG:
      CALL STOREPLM(THETA,NMTHETA)
C
      ZMIN=1.E10
      ZMAX=-1.E10
      DO 2000 I=1,NMX
      	 X=XMIN+(I-1)*XD
         DO 1000 J=1,NMY
            Y=YMIN+(J-1)*YD
            IF( CC.EQ.'T' ) THEN
               R=DBLE(X)
               PHI=DBLE(Y)
               NTHETA=1
            ELSEIF( CC.EQ.'P' ) THEN
               R=DBLE(X)
               NTHETA=J
            ELSEIF( CC.EQ.'R' ) THEN
               PHI=DBLE(X)
               NTHETA=J
            ENDIF
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c IDL
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
            if( cc.eq.'T' ) then
               XIDL(I,J)=R*COS(pi*PHI/180.d0)
               YIDL(I,J)=R*SIN(pi*PHI/180.d0)
                on_a_sphere=0 
            elseif( cc.eq.'P' ) then
               XIDL(I,J)=R*COS(pi*(THETA(J)-90.d0)/180.d0)
               YIDL(I,J)=R*SIN(pi*(THETA(J)-90.d0)/180.d0)
                on_a_sphere=0  
            elseif( cc.eq.'R' ) then 
c               print*, PHI, THETA(NTHETA)
               on_a_sphere=1
            else
                on_a_sphere=0  
               write(*,*) 'wrong constant variable: ',cc
               stop
            endif
            
            
C
C-------- R,PHI UND THETA SIND DIE KUGELKOORDINATEN:
	    IF( CF.EQ.'VS' .OR. CF.EQ.'BS' .OR. CF.EQ.'JS' ) THEN
               IF(  CC.EQ.'T' ) THEN
                  Z(I,J)=REAL(FT(DX,CF,R,PHI,NTHETA,TIME,DC))
               ELSEIF( CC.EQ.'P' ) THEN
                  Z(I,J)=REAL(FP(DX,CF,R,PHI,NTHETA,TIME,DC))
               ELSEIF( CC.EQ.'R' ) THEN
                  Z(I,J)=REAL(FR(DX,CF,R,PHI,NTHETA,TIME,DC))
	       ENDIF
            ELSEIF( CF.EQ.'VR' .OR. CF.EQ.'BR' ) THEN
               Z(I,J)=REAL(RF(DX,CF,R,PHI,NTHETA,TIME,DC))
            ELSEIF( CF.EQ.'TE' ) THEN
               Z(I,J)=REAL(TEMP(DX,CF,R,PHI,NTHETA,TIME,DC))
            ELSEIF( CF.EQ.'ZF' ) THEN
               Z(I,J)=REAL(FZONAL(DX,R,NTHETA,TIME))
            ELSEIF( CF.EQ.'MF' ) THEN
               Z(I,J)=REAL(DMERI(DX,R,NTHETA,TIME))
            ELSEIF( CF.EQ.'MT' ) THEN
               Z(I,J)=REAL(DMTOR(DX,R,NTHETA,TIME))
            ELSEIF( CF.EQ.'MP' .OR. CF.EQ.'MJ' ) THEN
               Z(I,J)=REAL(DMPJ(DX,CF,R,NTHETA,TIME))
            ELSEIF( CF.EQ.'BT' ) THEN
               Z(I,J)=REAL(DBT(DX,R,PHI,NTHETA,TIME,DC))
            ELSEIF( CF.EQ.'MC' ) THEN
               Z(I,J)=REAL(DMC(DX,R,NTHETA,TIME))
            ELSEIF( CF.EQ.'TT' ) THEN
               Z(I,J)=REAL(TT(DX,CF,R,PHI,NTHETA,TIME,DC))
            ELSEIF( CF.EQ.'UP' ) THEN
               Z(I,J)=REAL(UP(DX,CF,R,PHI,NTHETA,TIME,DC))
            ELSEIF( CF.EQ.'NU' ) THEN
               Z(I,J)=REAL(FNU(DX,CF,R,PHI,NTHETA,TIME,DC))
	    ELSE
	       WRITE(*,*) 'WRONG INPUT OF CF.'
	       STOP
            ENDIF
      	    IF( Z(I,J).GT.ZMAX ) ZMAX=Z(I,J)
      	    IF( Z(I,J).LT.ZMIN ) ZMIN=Z(I,J)
1000     CONTINUE
2000  CONTINUE
C

      ZAMAX=MAX(ABS(ZMIN),ABS(ZMAX))
      ZNULL=1.E-11*ZAMAX
      ZNULLM=1.E-11
      ZANULL=1.E-13
      ZSCALE=1.E0
C
      IF( ZD.GT.0.E0 ) THEN
         IF( ZAMAX.LT.ZANULL ) THEN
            WRITE(14,*) 'ZMAX AND ZMIN CLOSE TO ZERO: ',ZMAX,ZMIN
            WRITE(14,*) 'NO PLOT POSSIBLE.'
            GOTO 9000
         ELSEIF( ZNULL.LE.ZNULLM ) THEN
	    ZSCALE=1.E0/ZNULLM
	    WRITE(14,*) 'SCALED BY ',ZSCALE
	    ZMIN=ZSCALE*ZMIN
	    ZMAX=ZSCALE*ZMAX
	    ZNULL=ZSCALE*ZNULL
	    DO 2100 IX=1,NMX
	    DO 2100 IY=1,NMY
2100        Z(IX,IY)=ZSCALE*Z(IX,IY)
         ENDIF
      ELSEIF( ZD.LT.0.E0 ) THEN 
	 IF( NCPLOT.GT.NSUBP ) THEN
	    NZD=MOD(NCPLOT,NSUBP)
	    IF( NZD.EQ.0 ) NZD=NSUBP
	    ZD=ZSCALE*ZDS(NZD)
	    LCL=0
	 ELSE
	    ZD=ZSCALE*ABS(ZD)
	 ENDIF
      ENDIF
      IF( LCL.EQ.1 ) THEN
         NCL=AINT(ZD+0.1E0)
         IF( ZMIN.GT.-ZNULL .OR. ZMAX.LT.ZNULL ) THEN
            ZD=((ZMAX-ZMIN)-ZNULL)/(NCL-1)
         ELSE
            ZD=(MAX(ABS(ZMIN),ABS(ZMAX))-ZNULL)/(NCL-1)
         ENDIF
         ZD=ZD-ZD/100
      ELSEIF( LCL.EQ.0 ) THEN
         IF( ZD.GT.ABS(ZMAX) .AND. ZD.GT.ABS(ZMIN) ) THEN
            WRITE(*,*) 'TOO LARGE ZD , ZMIN,ZMAX ARE ONLY: ',ZMIN,ZMAX
            STOP
         ENDIF
         IF( ZMIN.GT.-ZNULL .OR. ZMAX.LT.ZNULL ) THEN
            NCL=AINT( ABS(ZMAX-ZMIN)/ZD+0.1E0 )+1
         ELSE
            NCL=AINT(MAX(ABS(ZMAX),ABS(ZMIN))/ZD+0.1E0)+1
         ENDIF
      ENDIF
      IF( NCPLOT.LE.NSUBP ) ZDS(NCPLOT)=ZD/ZSCALE
      IF( ZMIN.GT.-ZNULL .OR. ZMAX.LT.ZNULL ) THEN
         ZMINP=ZMIN
         ZMAXP=ZMAX
      ELSE
         ZMINP=ZD*AINT( ZMIN/ZD )-ZNULL
         ZMAXP=ZD*AINT( ZMAX/ZD )+ZNULL
      ENDIF
      IF( ABS(ZMINP).LT.ZNULL ) ZMINP=ZNULL
      IF( ABS(ZMAXP).LT.ZNULL ) ZMAXP=ZNULL
      WRITE(14,*) 'DIFFERENCE BETWEEN CONTOURLINES ZD= ',ZD
      WRITE(14,*) 'NUMBER OF CONTOURLINES NCL= ',NCL
      WRITE(14,*) 'ZMAX,ZMIN= ',ZMAX,ZMIN
      WRITE(14,*) 'ZMAXP,ZMINP= ',ZMAXP,ZMINP
C
      TENSN=0.D0
C
c     IF( CC.EQ.'T' .OR. CC.EQ.'P' ) THEN
c
C-- NEUE FESTLEGUNG VON URSPRUNG UND PLOTGEBIET:
c        CALL PHYSOR(XOR,YOR)
c        CALL AREA2D(XAR,YAR)
C
C-- ATRANS INFORMIERT DISSPLA, DASS EINE KOORDINATENTRANSFORMATION,
C   GEGEBEN DURCH DIE SUBROUTINE TRANS, VORNENOMMEN WERDEN SOLL,
C   HIER VON DEN LINEAREN X,Y-ACHSEN ZU POLAREN KOORDINATEN (RADIUS,WINKEL).
c        CALL ATRANS
C
C-- GRAF INITIALISIERT X UND Y ACHSE:
c        CALL GRAF(XMIN,XD,XMAX,YMIN,YD,YMAX)
C
c     ELSEIF( CC.EQ.'R' ) THEN
C
C-- AUFRUFEN DEN PROJEKTION VON KUGEL AUF KREIS:
c        CALL PROJCT('ORTH')
C
C-- FESTLEGUNG DES POLS:
c        CALL MAPOLE(XP,YP)
C
C-- NEUE FESTLEGUNG VON URSPRUNG UND PLOTGEBIET (MUSS NACH PROJCT UND
C   MAPOLE ERFOLGEN:
c        CALL PHYSOR(XOR,YOR)
c        CALL AREA2D(XAR,YAR)
C
C-- ZEICHNEN DER GROSSKREISE:
c        CALL MAPMDE('GREAT')
C
C-- INITIALISIERUNG DER ACHSEN:
c        CALL MAPGR(XP-180.E0,30.E0,XP+180.E0,YP-90.E0,30.E0,YP+90.E0)
C
C-- FESTLEGUNG DES GITTERS , HIER NUR GROSSKREISE:
c        CALL THKCRV(0.002E0)
c        CALL THKFRM(0.005E0)
c        CALL GRID(0,3)
c        CALL RESET('THKCRV')
C
c     ENDIF
C
C-- ZEICHNEN DER KONTOURLINIEN:
C
c     IF( ZMINP.LE.-ZD ) THEN
C
c        WRITE(14,*) 'ZLEVEL < 0.'
C
C-- FESTLEGUNG DES WERTEBEREICHS:
c        IF( ZMAXP.LT.ZNULL ) THEN
c           CALL ZRANGE(ZMAXP,ZMINP)
c        ELSE
c           CALL ZRANGE(ZMINP,-ZD)
c        ENDIF
C
C-- PRODUKTION DER CONTOURLINIEN:
c        CALL CONMAK(Z,NMX,NMY,ZD)
C
C-- FESTLEGUNG WIE DIESE ZU ZEICHNEN SIND IN DER SUBROUTINE MYCNLN:
c        CALL CONLIN(0,'MYCNLN','NOLABELS',3,1)
C
C-- SPLINE INTERPOLATION:
c        CALL RASPLN(TENSN)
C
C-- ZEICHNEN DER LINIEN:
c        CALL CONTUR(1,'NOLABELS','DRAW')
C
c     ENDIF
C
C-- DITO FUER Z>0 : 
c     IF( ZMAXP.GE.ZNULL ) THEN
C
c        WRITE(14,*) 'ZLEVEL > 0.'
C
c        IF( ZMINP.GT.-ZNULL ) THEN
c           CALL ZRANGE(ZMINP,ZMAXP)
c        ELSE
c           ZMAXAP=MIN(ZMAX,ZMAXP+ZNULL)
c           CALL ZRANGE(ZNULL,ZMAXAP)
c        ENDIF
c        CALL CONMAK(Z,NMX,NMY,ZD)
c        CALL CONLIN(0,'MYCNLN','NOLABELS',3,1)
c        CALL RASPLN(TENSN)
c        CALL CONTUR(1,'NOLABELS','DRAW')
c     ENDIF         
C
9000  CONTINUE
c     CALL RESET('ATRANS')
c     CALL RESET('MAPMDE')
c     CALL RESET('MAPOLE')
c     CALL RESET('PROJCT')
c     CALL RESET('BLNKS')
c     CALL RESET('DOT')
c     CALL RESET('DASH')
c     CALL RESET('THKCRV')
c     CALL LINEAR
C
c     WRITE(14,*)
C
c     CALL ENDGR(0)
C
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c IDL
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      write(*,*) 'writing files idl.z, idl.x, idl.y ...'
      filez='idl.z'
      filex='idl.x'
      filey='idl.y'
c     write(filez(6:7),'(1I1)') NPLOT
c     write(filex(6:7),'(1I1)') NPLOT
c     write(filey(6:7),'(1I1)') NPLOT
      open(21,file=filez,STATUS= 'UNKNOWN')
      open(22,file=filex,STATUS= 'UNKNOWN')
      open(23,file=filey,STATUS= 'UNKNOWN')

      if (on_a_sphere.eq.1) then 
 
      DO 2001 I=1,NMX  
         X=XMIN+(I-1)*XD
c  phi = x  
         write(22,*)   DBLE(X) + 180.

 2001 CONTINUE  

      DO 1001 J=1,NMY  
c         Y=YMIN+(J-1)*YD  
c  theta = THETA(J) 
         write(23,*)  THETA(J)-90.  
 1001    CONTINUE  
         do i=1,nmx 
            do j=1,nmy 
               write(21,*) z(i,j) 
            enddo 
         enddo 
      ELSE
         do i=1,nmx
            do j=1,nmy
               write(21,*) z(i,j)
               write(22,*) xidl(i,j)
               write(23,*) yidl(i,j)
            enddo
         enddo
      ENDIF
      
9999  CONTINUE
      RETURN
      END
C
C---------------------------------------------------------------------
C
C
*************************************************************************
      FUNCTION FT(X,CFE,R,PHI,NTHETA,TIME,DC)
*************************************************************************
C   Stromfunktion fuer theta=konstant:
C      F_theta = r dphi v             (Busse: r/sin(th) d/dphi v )
C   Fuer den elektrischen Strom: 
C              F_theta = r dphi g
C
C     optimized for K=0.
C
C------------------------------------------------------------------------
      IMPLICIT REAL*8(A-H,O-Z)
      PARAMETER (NM=5500,NAM=400)
      PARAMETER (PI=3.14159265358979D0)
      CHARACTER*1 CF
      CHARACTER*2 CRR,CFE
C
      DIMENSION X(*)
C
      COMMON/DIM/NDV,NDW,NDT,NDH,NDG,ND
      COMMON/QNU/NMC,L(NM),M(NM),N(NM),K(NM),CF(NM),CRR(NM)
      COMMON/PARI/RA,TA,PR,PM,ETA,C,OM,FTW,FTG,MF
ccc   COMMON/NPARI/M0,NE,NTV,NTH,LTV,LTH,KTV,KTH,LD
      COMMON/NPARI/M0,NTV,NTH,LTV,LTH,KTV,KTH,LEV,LRB,LD
      COMMON/AB/A(NAM),B(NAM),NAMC
C
      IF( NAM.NE.NAMC ) THEN
         WRITE(*,*) 'WRONG DIMENSION NAM IN FT.'
         STOP
      ENDIF
      IF( NM.NE.NMC ) THEN
         WRITE(*,*) 'WRONG DIMENSION NM IN FT.'
         STOP
      ENDIF

      PPHI=PHI*PI/180.D0
      RI=ETA/(1.D0-ETA)
      RO=RI+1.D0
      FT=0.D0
      IF( CFE.EQ.'VS' ) THEN
         NDOMIN=1
         NDOMAX=NDV
      ELSEIF( CFE.EQ.'BS' ) THEN
         NDOMIN=NDV+NDW+NDT+1
         NDOMAX=NDV+NDW+NDT+NDH
      ELSEIF( CFE.EQ.'JS' ) THEN
         NDOMIN=NDV+NDW+NDT+NDH+1
         NDOMAX=NDV+NDW+NDT+NDH+NDG
      ELSE
         WRITE(*,*) 
     &    'WRONG CFE IN FT, SHOULD BE VS OR BS OR JS BUT IS: ',CFE
         STOP
      ENDIF
      DO 1000 I=NDOMIN,NDOMAX
         IF( .NOT.( ( CF(I).EQ.'V' .AND. CFE.EQ.'VS' ) .OR.
     &              ( CF(I).EQ.'H' .AND. CFE.EQ.'BS' ) .OR.       
     &              ( CF(I).EQ.'G' .AND. CFE.EQ.'JS' )  )  ) THEN
            WRITE(*,*) 
     &      'WRONG CF IN FT, SHOULD BE V OR H OR G BUT IS: ',CF(I)
            STOP
         ENDIF
         IF( M(I).EQ.0 ) THEN
            EPSM=1.D0
         ELSE
            EPSM=2.D0
         ENDIF
         IF( K(I).EQ.0 ) THEN
            EPSK=1.D0
         ELSE
            EPSK=2.D0
         ENDIF
         FTT=EPSM*EPSK*M(I)*PLMS(L(I),M(I),NTHETA)*R
         IF( CF(I).EQ.'V' .OR. CF(I).EQ.'G' ) THEN
            FTT=FTT*DSIN( N(I)*PI*(R-RI) )
         ELSEIF( CF(I).EQ.'H' ) THEN
            NR=NAB(L(I),N(I))
            IF( R.LE.RO ) THEN
               IF( A(NR).EQ.0.D0 .OR. B(NR).EQ.0.D0 ) THEN
                  WRITE(*,*) 'ALPHA AND BETA NOT CALCULATED.'
                  STOP  
               ENDIF
               FTT=-FTT*DCOS( A(NR)*R-B(NR) )
            ELSE
               IF( A(NR).EQ.0.D0 .OR. B(NR).EQ.0.D0 ) THEN
                  WRITE(*,*) 'ALPHA AND BETA NOT CALCULATED.'
                  STOP  
               ENDIF
               FTT=-FTT * (RO/R)**(L(I)+1) * DCOS( A(NR)*RO-B(NR) )
            ENDIF
         ENDIF
C
        if(K(I).EQ.0) then
         IF( CRR(I).EQ.'RR' ) THEN
            FTT=-FTT * X(I) * DSIN( M(I)*(PPHI-DC*TIME) )
         ELSEIF( CRR(I).EQ.'IR' ) THEN
            FTT=-FTT * X(I) * DCOS( M(I)*(PPHI-DC*TIME) )
         ELSE
            FTT=0.D0
         ENDIF
        else
         IF( CRR(I).EQ.'RR' ) THEN
            FTT=-FTT * X(I) * DSIN( M(I)*(PPHI-DC*TIME) ) * 
     *						DCOS(K(I)*OM*TIME)
         ELSEIF( CRR(I).EQ.'IR' ) THEN
            FTT=-FTT * X(I) * DCOS( M(I)*(PPHI-DC*TIME) ) * 
     *					        DCOS(K(I)*OM*TIME)
         ELSEIF( CRR(I).EQ.'RI' ) THEN
            FTT=FTT * X(I) * DSIN( M(I)*(PPHI-DC*TIME) ) * 
     *						DSIN(K(I)*OM*TIME)
         ELSEIF( CRR(I).EQ.'II' ) THEN
            FTT=FTT * X(I) * DCOS( M(I)*(PPHI-DC*TIME) ) * 
     *						DSIN(K(I)*OM*TIME)
         ENDIF
        endif
         FT=FT-FTT
1000  CONTINUE
C
      RETURN
      END
C
C---------------------------------------------------------------------
C
C
*************************************************************************
      FUNCTION FP(X,CFE,R,PHI,NTHETA,TIME,DC)
*************************************************************************
C Stromfunktion fuer phi=konstant: 
C              F_phi = r sin(theta) dtheta v  (like Busse)
C Fuer den elektrischen Strom: 
C              F_phi = r sin(theta) dtheta g
C
C     optimized for K=0.
C
C------------------------------------------------------------------------
      IMPLICIT REAL*8(A-H,O-Z)
      PARAMETER (NM=5500,NAM=400)
      PARAMETER (PI=3.14159265358979D0)
      CHARACTER*1 CF
      CHARACTER*2 CRR,CFE
C
      DIMENSION X(*)
C
      COMMON/DIM/NDV,NDW,NDT,NDH,NDG,ND
      COMMON/QNU/NMC,L(NM),M(NM),N(NM),K(NM),CF(NM),CRR(NM)
      COMMON/PARI/RA,TA,PR,PM,ETA,C,OM,FTW,FTG,MF
ccc   COMMON/NPARI/M0,NE,NTV,NTH,LTV,LTH,KTV,KTH,LD
      COMMON/NPARI/M0,NTV,NTH,LTV,LTH,KTV,KTH,LEV,LRB,LD
      COMMON/AB/A(NAM),B(NAM),NAMC
C
      IF( NM.NE.NMC ) THEN
         WRITE(*,*) 'WRONG DIMENSION NM IN FP.'
         STOP
      ENDIF
      IF( NAM.NE.NAMC ) THEN
         WRITE(*,*) 'WRONG DIMENSION NAM IN FP.'
         STOP
      ENDIF
C
      PPHI=PHI*PI/180.D0
      RI=ETA/(1.D0-ETA)
      RO=RI+1.D0
      FP=0.D0
      IF( CFE.EQ.'VS' ) THEN
         NDOMIN=1
         NDOMAX=NDV

      ELSEIF( CFE.EQ.'BS' ) THEN
         NDOMIN=NDV+NDW+NDT+1
         NDOMAX=NDV+NDW+NDT+NDH
      ELSEIF( CFE.EQ.'JS' ) THEN
         NDOMIN=NDV+NDW+NDT+NDH+1
         NDOMAX=NDV+NDW+NDT+NDH+NDG
      ELSE
         WRITE(*,*) 
     &   'WRONG CFE IN FP, SHOULD BE VS OR BS OR JS BUT IS: ',CFE
         STOP
      ENDIF
      DO 1000 I=NDOMIN,NDOMAX
         IF( .NOT.( ( CF(I).EQ.'V' .AND. CFE.EQ.'VS' ) .OR.
     &              ( CF(I).EQ.'H' .AND. CFE.EQ.'BS' ) .OR.      
     &              ( CF(I).EQ.'G' .AND. CFE.EQ.'JS' )  )  ) THEN
            WRITE(*,*) 
     &       'WRONG CF IN FP, SHOULD BE V OR H OR G BUT IS: ',CF(I)
            STOP
         ENDIF
         IF( M(I).EQ.0 ) THEN
            EPSM=1.D0
         ELSE
            EPSM=2.D0
         ENDIF
         IF( K(I).EQ.0 ) THEN
            EPSK=1.D0
         ELSE
            EPSK=2.D0
         ENDIF
         FPT=EPSM*EPSK*R * (
     &	    DBLE(L(I))*DSQRT( DBLE( (L(I)-M(I)+1)*(L(I)+M(I)+1) ) /
     /    DBLE( (2*L(I)+1)*(2*L(I)+3) ) ) * PLMS(L(I)+1,M(I),NTHETA) -
     -	    DBLE(L(I)+1)*DSQRT( DBLE( (L(I)-M(I))*(L(I)+M(I)) ) /
     /    DBLE( (2*L(I)+1)*(2*L(I)-1) ) ) * PLMS(L(I)-1,M(I),NTHETA)  )
         IF( CF(I).EQ.'V' .OR. CF(I).EQ.'G' ) THEN
            FPT=FPT*DSIN( N(I)*PI*(R-RI) )
         ELSEIF( CF(I).EQ.'H' ) THEN
            NR=NAB(L(I),N(I))
	    IF( R.LE.RO ) THEN
               IF( A(NR).EQ.0.D0 .OR. B(NR).EQ.0.D0 ) THEN
                  WRITE(*,*) 'ALPHA AND BETA NOT CALCULATED.'
                  STOP  
               ENDIF
               FPT=FPT*DCOS( A(NR)*R-B(NR) )
	    ELSE
               IF( A(NR).EQ.0.D0 .OR. B(NR).EQ.0.D0 ) THEN
                  WRITE(*,*) 'ALPHA AND BETA NOT CALCULATED.'
                  STOP  
               ENDIF
               FPT=FPT * (RO/R)**(L(I)+1) * DCOS( A(NR)*RO-B(NR) )
	    ENDIF
         ENDIF
C
        if(K(I).EQ.0) then
         IF( CRR(I).EQ.'RR' ) THEN
            FPT=FPT * X(I) * DCOS( M(I)*(PPHI-DC*TIME) )
         ELSEIF( CRR(I).EQ.'IR' ) THEN
            FPT=-FPT * X(I) * DSIN( M(I)*(PPHI-DC*TIME) )
         ELSE
            FPT=0.D0
         ENDIF
        else
         IF( CRR(I).EQ.'RR' ) THEN
            FPT=FPT * X(I) * DCOS( M(I)*(PPHI-DC*TIME) ) * 
     *						DCOS(K(I)*OM*TIME)
         ELSEIF( CRR(I).EQ.'IR' ) THEN
            FPT=-FPT * X(I) * DSIN( M(I)*(PPHI-DC*TIME) ) * 
     *						DCOS(K(I)*OM*TIME)
         ELSEIF( CRR(I).EQ.'RI' ) THEN
            FPT=-FPT * X(I) * DCOS( M(I)*(PPHI-DC*TIME) ) * 
     *						DSIN(K(I)*OM*TIME)
         ELSEIF( CRR(I).EQ.'II' ) THEN
            FPT=FPT * X(I) * DSIN( M(I)*(PPHI-DC*TIME) ) * 
     *						DSIN(K(I)*OM*TIME)
         ENDIF
        endif
         FP=FP+FPT
1000  CONTINUE
C
      RETURN
      END
C
C---------------------------------------------------------------------      
C
C
*************************************************************************
      FUNCTION FR(X,CFE,R,PHI,NTHETA,TIME,DC)
*************************************************************************
C   Stromfunktion fuer r=konstant:
C                     F_r = w      (like Busse, Hirsching: rw )
C   Stromfunktion fuer r=konstant des elektrischen Stroms: 
C                     F_r = - laplace h
C
C     optimized for K=0.
C
C------------------------------------------------------------------------
      IMPLICIT REAL*8(A-H,O-Z)
      PARAMETER (NM=5500,NAM=400)
      PARAMETER (PI=3.14159265358979D0)
      CHARACTER*1 CF
      CHARACTER*2 CRR,CFE
C
      DIMENSION X(*)
C
      COMMON/DIM/NDV,NDW,NDT,NDH,NDG,ND
      COMMON/QNU/NMC,L(NM),M(NM),N(NM),K(NM),CF(NM),CRR(NM)
      COMMON/PARI/RA,TA,PR,PM,ETA,C,OM,FTW,FTG,MF
ccc   COMMON/NPARI/M0,NE,NTV,NTH,LTV,LTH,KTV,KTH,LD
      COMMON/NPARI/M0,NTV,NTH,LTV,LTH,KTV,KTH,LEV,LRB,LD
      COMMON/AB/A(NAM),B(NAM),NAMC
C
      IF( NM.NE.NMC ) THEN
         WRITE(*,*) 'WRONG DIMENSION NM IN FR.'
         STOP
      ENDIF
C
      PPHI=PHI*PI/180.D0
      RI=ETA/(1.D0-ETA)
      FR=0.D0
      IF( CFE.EQ.'VS' ) THEN
         NDOMIN=NDV+1
         NDOMAX=NDV+NDW
      ELSEIF( CFE.EQ.'JS' ) THEN
         NDOMIN=NDV+NDW+NDT+1
         NDOMAX=NDV+NDW+NDT+NDH
      ELSEIF( CFE.EQ.'BS' ) THEN
         NDOMIN=NDV+NDW+NDT+NDH+1
         NDOMAX=NDV+NDW+NDT+NDH+NDG
      ELSE
         WRITE(*,*) 
     &   'WRONG CFE IN FR, SHOULD BE VS OR BS OR JS BUT IS: ',CFE
         STOP
      ENDIF
      DO 1000 I=NDOMIN,NDOMAX
         IF(  .NOT.( ( CFE.EQ.'VS' .AND. CF(I).EQ.'W' ) .OR.
     &               ( CFE.EQ.'BS' .AND. CF(I).EQ.'G' ) .OR.       
     &               ( CFE.EQ.'JS' .AND. CF(I).EQ.'H' )  )  ) THEN
            WRITE(*,*) 
     &       'WRONG CF IN FR, SHOULD BE W OR G OR H BUT IS: ',CF(I)
            STOP
         ENDIF
         IF( M(I).EQ.0 ) THEN
            EPSM=1.D0
         ELSE
            EPSM=2.D0
         ENDIF
         IF( K(I).EQ.0 ) THEN
            EPSK=1.D0
         ELSE
            EPSK=2.D0
         ENDIF
         FRT=EPSM*EPSK*PLMS(L(I),M(I),NTHETA)
         IF( CF(I).EQ.'W' ) THEN
            FRT=FRT*R*DCOS( (N(I)-1)*PI*(R-RI) )
         ELSEIF( CF(I).EQ.'G' ) THEN
            FRT=FRT*DSIN( N(I)*PI*(R-RI) )
         ELSEIF( CF(I).EQ.'H' ) THEN
            NR=NAB(L(I),N(I))
            IF( A(NR).EQ.0.D0 .OR. B(NR).EQ.0.D0 ) THEN
               WRITE(*,*) 'ALPHA AND BETA NOT CALCULATED.'
               STOP  
            ENDIF
	    FRT=FRT*(
     &           ( A(NR)*A(NR)+DBLE(L(I)*(L(I)+1))/(R*R) ) *
     *                                DCOS( A(NR)*R-B(NR) ) +
     +                    2*A(NR)/R * DSIN( A(NR)*R-B(NR) )  )
         ENDIF
        if(K(I).EQ.0) then
         IF( CRR(I).EQ.'RR' ) THEN
            FRT=FRT * X(I) * DCOS( M(I)*(PPHI-DC*TIME) )
         ELSEIF( CRR(I).EQ.'IR' ) THEN
            FRT=-FRT * X(I) * DSIN( M(I)*(PPHI-DC*TIME) )
         ELSE
            FRT=0.D0
         ENDIF
        else
         IF( CRR(I).EQ.'RR' ) THEN
            FRT=FRT * X(I) * DCOS( M(I)*(PPHI-DC*TIME) ) * 
     *						DCOS(K(I)*OM*TIME)
         ELSEIF( CRR(I).EQ.'IR' ) THEN
            FRT=-FRT * X(I) * DSIN( M(I)*(PPHI-DC*TIME) ) * 
     *						DCOS(K(I)*OM*TIME)
         ELSEIF( CRR(I).EQ.'RI' ) THEN
            FRT=-FRT * X(I) * DCOS( M(I)*(PPHI-DC*TIME) ) * 
     *						DSIN(K(I)*OM*TIME)
         ELSEIF( CRR(I).EQ.'II' ) THEN
            FRT=FRT * X(I) * DSIN( M(I)*(PPHI-DC*TIME) ) * 
     *						DSIN(K(I)*OM*TIME)
         ENDIF
        endif
         FR=FR+FRT
1000  CONTINUE
C
      RETURN
      END
C
C---------------------------------------------------------------------
C
C
*************************************************************************
      FUNCTION RF(X,CFE,R,PHI,NTHETA,TIME,DC)
*************************************************************************
C Radiales Geschw.feld: U_r = L_2/r v
C
C     optimized for K=0.
C
C------------------------------------------------------------------------
      IMPLICIT REAL*8(A-H,O-Z)
      PARAMETER (NM=5500,NAM=400)
      PARAMETER (PI=3.14159265358979D0)
      CHARACTER*1 CF
      CHARACTER*2 CRR,CFE
C
      DIMENSION X(*)
C
      COMMON/DIM/NDV,NDW,NDT,NDH,NDG,ND
      COMMON/QNU/NMC,L(NM),M(NM),N(NM),K(NM),CF(NM),CRR(NM)
      COMMON/PARI/RA,TA,PR,PM,ETA,C,OM,FTW,FTG,MF
ccc   COMMON/NPARI/M0,NE,NTV,NTH,LTV,LTH,KTV,KTH,LD
      COMMON/NPARI/M0,NTV,NTH,LTV,LTH,KTV,KTH,LEV,LRB,LD
      COMMON/AB/A(NAM),B(NAM),NAMC
C
      IF( NM.NE.NMC ) THEN
         WRITE(*,*) 'WRONG DIMENSION NM IN RF.'
         STOP
      ENDIF
      IF( NAM.NE.NAMC ) THEN
         WRITE(*,*) 'WRONG DIMENSION NAM IN RF.'
         STOP
      ENDIF
C
      PPHI=PHI*PI/180.D0
      RI=ETA/(1.D0-ETA)
      RF=0.D0
      IF( CFE.EQ.'VR' ) THEN
         NDOMIN=1
         NDOMAX=NDV
      ELSEIF( CFE.EQ.'BR' ) THEN
         NDOMIN=NDV+NDW+NDT+1
         NDOMAX=NDV+NDW+NDT+NDH
      ELSE
         WRITE(*,*) 'WRONG CFE IN RF, SHOULD BE V OR H BUT IS: ',CFE
         STOP
      ENDIF
      DO 1000 I=NDOMIN,NDOMAX
         IF( .NOT.( ( CF(I).EQ.'V' .AND. CFE.EQ.'VR' ) .OR.
     &              ( CF(I).EQ.'H' .AND. CFE.EQ.'BR' )  ) ) THEN
            WRITE(*,*) 'WRONG CF IN RF, SHOULD BE V OR H BUT IS: ',
     &                                                  CF(I)
            STOP
         ENDIF
         IF( M(I).EQ.0 ) THEN
            EPSM=1.D0
         ELSE
            EPSM=2.D0
         ENDIF
         IF( K(I).EQ.0 ) THEN
            EPSK=1.D0
         ELSE
            EPSK=2.D0
         ENDIF
         RFT=EPSM*EPSK*L(I)*(L(I)+1) * PLMS(L(I),M(I),NTHETA) / R 
         IF( CF(I).EQ.'V' ) THEN
            RFT=RFT*DSIN( N(I)*PI*(R-RI) )
         ELSEIF( CF(I).EQ.'H' ) THEN
            NR=NAB(L(I),N(I))
            IF( A(NR).EQ.0.D0 .OR. B(NR).EQ.0.D0 ) THEN
               WRITE(*,*) 'ALPHA AND BETA NOT CALCULATED.'
               STOP  
            ENDIF
            RFT=RFT*DCOS( A(NR)*R-B(NR) )
         ENDIF
C
        if(K(I).EQ.0) then
         IF( CRR(I).EQ.'RR' ) THEN
            RFT=RFT * X(I) * DCOS( M(I)*(PPHI-DC*TIME) )
         ELSEIF( CRR(I).EQ.'IR' ) THEN
            RFT=-RFT * X(I) * DSIN( M(I)*(PPHI-DC*TIME) )
         ELSE
            RFT=0.D0
         ENDIF
        else
         IF( CRR(I).EQ.'RR' ) THEN
            RFT=RFT * X(I) * DCOS( M(I)*(PPHI-DC*TIME) ) * 
     *						DCOS(K(I)*OM*TIME)
         ELSEIF( CRR(I).EQ.'IR' ) THEN
            RFT=-RFT * X(I) * DSIN( M(I)*(PPHI-DC*TIME) ) * 
     *						DCOS(K(I)*OM*TIME)
         ELSEIF( CRR(I).EQ.'RI' ) THEN
            RFT=-RFT * X(I) * DCOS( M(I)*(PPHI-DC*TIME) ) * 
     *						DSIN(K(I)*OM*TIME)
         ELSEIF( CRR(I).EQ.'II' ) THEN
            RFT=RFT * X(I) * DSIN( M(I)*(PPHI-DC*TIME) ) * 
     *						DSIN(K(I)*OM*TIME)
         ENDIF
        endif
         RF=RF+RFT
1000  CONTINUE
C
      RETURN
      END
C
C---------------------------------------------------------------------      
C
C
*************************************************************************
      FUNCTION TEMP(X,CFE,R,PHI,NTHETA,TIME,DC)
*************************************************************************
C   Temperaturfeld Theta (= Abweichung vom Grundzust.)
C   optimized for K=0.
C------------------------------------------------------------------------
      IMPLICIT REAL*8(A-H,O-Z)
      PARAMETER (NM=5500)
      PARAMETER (PI=3.14159265358979D0)
      CHARACTER*1 CF
      CHARACTER*2 CRR,CFE
C
      DIMENSION X(*)
C
      COMMON/DIM/NDV,NDW,NDT,NDH,NDG,ND
      COMMON/QNU/NMC,L(NM),M(NM),N(NM),K(NM),CF(NM),CRR(NM)
      COMMON/PARI/RA,TA,PR,PM,ETA,C,OM,FTW,FTG,MF
      COMMON/NPARI/M0,NTV,NTH,LTV,LTH,KTV,KTH,LEV,LRB,LD
      IF( NM.NE.NMC ) THEN
         WRITE(*,*) 'WRONG DIMENSION NM IN TEMP.'
         STOP
      ENDIF
C
      TEMP=0.D0
      PPHI=PHI*PI/180.D0
      RI=ETA/(1.D0-ETA)
      IF( CFE.EQ.'TE' ) THEN
         NDOMIN=1+NDV+NDW
         NDOMAX=NDV+NDW+NDT
      ELSE
         WRITE(*,*) 'WRONG CFE IN TEMP, SHOULD BE TE BUT IS: ',CFE
         STOP
      ENDIF
C
      DO 1000 I=NDOMIN,NDOMAX
         IF( CF(I).NE.'T' ) THEN
            WRITE(*,*) 'WRONG CF IN TEMP, SHOULD BE T BUT IS: ',
     &                                                  CF(I)
            STOP
         ENDIF
         IF( M(I).EQ.0 ) THEN
            EPSM=1.D0
         ELSE
            EPSM=2.D0
         ENDIF
         IF( K(I).EQ.0 ) THEN
            EPSK=1.D0
         ELSE
            EPSK=2.D0
         ENDIF
         TEM=EPSM*EPSK*PLMS(L(I),M(I),NTHETA)*DSIN( N(I)*PI*(R-RI) )
C
        if(K(I).EQ.0) then
         IF( CRR(I).EQ.'RR' ) THEN
            TEM=TEM * X(I) * DCOS( M(I)*(PPHI-DC*TIME) ) 
         ELSEIF( CRR(I).EQ.'IR' ) THEN
            TEM=-TEM * X(I) * DSIN( M(I)*(PPHI-DC*TIME) ) 
         ELSE
            TEM=0.D0
         ENDIF
        else
         IF( CRR(I).EQ.'RR' ) THEN
            TEM=TEM * X(I) * DCOS( M(I)*(PPHI-DC*TIME) ) *
     *                                          DCOS(K(I)*OM*TIME)
         ELSEIF( CRR(I).EQ.'IR' ) THEN
            TEM=-TEM * X(I) * DSIN( M(I)*(PPHI-DC*TIME) ) *
     *                                          DCOS(K(I)*OM*TIME)
         ELSEIF( CRR(I).EQ.'RI' ) THEN
            TEM=-TEM * X(I) * DCOS( M(I)*(PPHI-DC*TIME) ) *
     *                                          DSIN(K(I)*OM*TIME)
         ELSEIF( CRR(I).EQ.'II' ) THEN
            TEM=TEM * X(I) * DSIN( M(I)*(PPHI-DC*TIME) ) *
     *                                          DSIN(K(I)*OM*TIME)
         ENDIF
        endif
         TEMP=TEMP+TEM
1000  CONTINUE
C
      RETURN
      END
C
C---------------------------------------------------------------------
C
C
*************************************************************************
      FUNCTION TT(X,CFE,R,PHI,NTHETA,TIME,DC)
*     temperature field Theta + Ts
*     optimized for K=0.
*************************************************************************
C
C------------------------------------------------------------------------
      IMPLICIT REAL*8(A-H,O-Z)
      PARAMETER (NM=5500)
      PARAMETER (PI=3.14159265358979D0)
      CHARACTER*1 CF
      CHARACTER*2 CRR,CFE
C
      DIMENSION X(*)
C
      COMMON/DIM/NDV,NDW,NDT,NDH,NDG,ND
      COMMON/QNU/NMC,L(NM),M(NM),N(NM),K(NM),CF(NM),CRR(NM)
      COMMON/PARI/RA,TA,PR,PM,ETA,C,OM,FTW,FTG,MF
      COMMON/NPARI/M0,NTV,NTH,LTV,LTH,KTV,KTH,LEV,LRB,LD
C
      IF( NM.NE.NMC ) THEN
         WRITE(*,*) 'WRONG DIMENSION NM IN TT.'
         STOP
      ENDIF
C
      PPHI=PHI*PI/180.D0
      RI=ETA/(1.D0-ETA)
      T=0.D0
      IF( CFE.EQ.'TT' ) THEN
         NDOMIN=NDV+NDW+1
         NDOMAX=NDV+NDW+NDT
      ELSE
         WRITE(*,*) 'WRONG CFE IN TT, SHOULD TT BUT IS: ',CFE
         STOP
      ENDIF
      DO 1000 I=NDOMIN,NDOMAX
         IF( CF(I).NE.'T' ) THEN
            WRITE(*,*) 'WRONG CF IN T, SHOULD BE T BUT IS: ',
     &                                                  CF(I)
            STOP
         ENDIF
         IF( M(I).EQ.0 ) THEN
            EPSM=1.D0
         ELSE
            EPSM=2.D0
         ENDIF
         IF( K(I).EQ.0 ) THEN
            EPSK=1.D0
         ELSE
            EPSK=2.D0
         ENDIF
         TT=EPSM*EPSK*PLMS(L(I),M(I),NTHETA)
         TT=TT*DSIN( N(I)*PI*(R-RI) )
C
         IF(K(I).EQ.0) THEN
          IF( CRR(I).EQ.'RR' ) THEN
            TT=TT * X(I) * DCOS( M(I)*(PPHI-DC*TIME) )
          ELSEIF( CRR(I).EQ.'IR' ) THEN
            TT=-TT * X(I) * DSIN( M(I)*(PPHI-DC*TIME) )
          ELSEIF( CRR(I).EQ.'RI' ) THEN
            TT=0.0D0
          ELSEIF( CRR(I).EQ.'II' ) THEN
            TT=0.0D0
          ENDIF
         ELSE
          IF( CRR(I).EQ.'RR' ) THEN
            TT=TT * X(I) * DCOS( M(I)*(PPHI-DC*TIME) )  *
     *                                          DCOS(K(I)*OM*TIME)
          ELSEIF( CRR(I).EQ.'IR' ) THEN
            TT=-TT * X(I) * DSIN( M(I)*(PPHI-DC*TIME) ) *
     *                                          DCOS(K(I)*OM*TIME)
          ELSEIF( CRR(I).EQ.'RI' ) THEN
            TT=-TT * X(I) * DCOS( M(I)*(PPHI-DC*TIME) ) *
     *                                          DSIN(K(I)*OM*TIME)
          ELSEIF( CRR(I).EQ.'II' ) THEN
            TT=TT * X(I) * DSIN( M(I)*(PPHI-DC*TIME) ) *
     *                                          DSIN(K(I)*OM*TIME)
          ENDIF
         ENDIF
         T=T+TT
1000  CONTINUE
C
C        add basic temperature field Ts:
         T=T - R * R / ( 2.D0 * PR )
         TT=T
C
      RETURN
      END
C
C---------------------------------------------------------------------
C
*************************************************************************
      FUNCTION FNU(X,CFE,R,PHI,NTHETA,TIME,DC)
*************************************************************************
C   local Nusselt number NU(r=ri)
C   optimized for K=0.
C------------------------------------------------------------------------
      IMPLICIT REAL*8(A-H,O-Z)
      PARAMETER (NM=5500)
      PARAMETER (PI=3.14159265358979D0)
      CHARACTER*1 CF
      CHARACTER*2 CRR,CFE
C
      DIMENSION X(*)
C
      COMMON/DIM/NDV,NDW,NDT,NDH,NDG,ND
      COMMON/QNU/NMC,L(NM),M(NM),N(NM),K(NM),CF(NM),CRR(NM)
      COMMON/PARI/RA,TA,PR,PM,ETA,C,OM,FTW,FTG,MF
      COMMON/NPARI/M0,NTV,NTH,LTV,LTH,KTV,KTH,LEV,LRB,LD
      IF( NM.NE.NMC ) THEN
         WRITE(*,*) 'WRONG DIMENSION NM IN FNU.'
         STOP
      ENDIF
C
      FNU=0.D0
      PPHI=PHI*PI/180.D0
      RI=ETA/(1.D0-ETA)
      IF( CFE.EQ.'NU' ) THEN
         NDOMIN=1+NDV+NDW
         NDOMAX=NDV+NDW+NDT
      ELSE
         WRITE(*,*) 'WRONG CFE IN FNU, SHOULD BE NU BUT IS: ',CFE
         STOP
      ENDIF
C
      DO 1000 I=NDOMIN,NDOMAX
         IF( CF(I).NE.'T' ) THEN
            WRITE(*,*) 'WRONG CF IN TEMP, SHOULD BE T BUT IS: ',
     &                                                  CF(I)
            STOP
         ENDIF
         IF( M(I).EQ.0 ) THEN
            EPSM=1.D0
         ELSE
            EPSM=2.D0
         ENDIF
         IF( K(I).EQ.0 ) THEN
            EPSK=1.D0
         ELSE
            EPSK=2.D0
         ENDIF
         FNUT=EPSM*EPSK*PLMS(L(I),M(I),NTHETA)*DBLE(N(I))*PI
C
        if(K(I).EQ.0) then
         IF( CRR(I).EQ.'RR' ) THEN
            FNUT=FNUT * X(I) * DCOS( M(I)*(PPHI-DC*TIME) ) 
         ELSEIF( CRR(I).EQ.'IR' ) THEN
            FNUT=-FNUT * X(I) * DSIN( M(I)*(PPHI-DC*TIME) ) 
         ELSE
            FNUT=0.D0
         ENDIF
        else
         IF( CRR(I).EQ.'RR' ) THEN
            FNUT=FNUT * X(I) * DCOS( M(I)*(PPHI-DC*TIME) ) *
     *                                          DCOS(K(I)*OM*TIME)
         ELSEIF( CRR(I).EQ.'IR' ) THEN
            FNUT=-FNUT * X(I) * DSIN( M(I)*(PPHI-DC*TIME) ) *
     *                                          DCOS(K(I)*OM*TIME)
         ELSEIF( CRR(I).EQ.'RI' ) THEN
            FNUT=-FNUT * X(I) * DCOS( M(I)*(PPHI-DC*TIME) ) *
     *                                          DSIN(K(I)*OM*TIME)
         ELSEIF( CRR(I).EQ.'II' ) THEN
            FNUT=FNUT * X(I) * DSIN( M(I)*(PPHI-DC*TIME) ) *
     *                                          DSIN(K(I)*OM*TIME)
         ENDIF
        endif
         FNU=FNU+FNUT
1000  CONTINUE
C
      FNU=1.D0 - PR/RI*FNU
C
      RETURN
      END
C
C---------------------------------------------------------------------
C
C
*************************************************************************
      FUNCTION FZONAL(X,R,NTHETA,TIME)
*************************************************************************
C   Zonaler Fluss = gemittelte phi-Komponente der Geschwindigkeit:
C          < u_phi > = - dtheta w   (m=0) 
C
C     optimized for K=0.
C
C------------------------------------------------------------------------
      IMPLICIT REAL*8(A-H,O-Z)
      PARAMETER (NM=5500)
      PARAMETER (PI=3.14159265358979D0)
      CHARACTER*1 CF
      CHARACTER*2 CRR
C
      DIMENSION X(*)
C
      COMMON/DIM/NDV,NDW,NDT,NDH,NDG,ND
      COMMON/QNU/NMC,L(NM),M(NM),N(NM),K(NM),CF(NM),CRR(NM)
      COMMON/PARI/RA,TA,PR,PM,ETA,C,OM,FTW,FTG,MF
      COMMON/NPARI/M0,NTV,NTH,LTV,LTH,KTV,KTH,LEV,LRB,LD
C
      IF( NM.NE.NMC ) THEN
         WRITE(*,*) 'WRONG DIMENSION NM IN FZONAL.'
         STOP
      ENDIF
C
      FZONAL=0.D0
      RI=ETA/(1.D0-ETA)
      NDOMIN=1+NDV
      NDOMAX=NDV+NDW
C
      DO 1000 I=NDOMIN,NDOMAX
         IF( CF(I).NE.'W' ) THEN
            WRITE(*,*) 'WRONG CF IN FZONAL, SHOULD BE W BUT IS: ',
     &                                                  CF(I)
            STOP
         ENDIF
C
         IF( M(I).NE.0 ) GOTO 1000
C
         IF( K(I).EQ.0 ) THEN
            EPSK=1.D0
         ELSE
            EPSK=2.D0
         ENDIF
         ZON=EPSK*DSQRT(DBLE(L(I)*(L(I)+1))) * PLMS(L(I),1,NTHETA) *
     &                  R * DCOS( (N(I)-1)*PI*(R-RI) )
C
        if(K(I).EQ.0) then
         IF( CRR(I).EQ.'RR' ) THEN
            ZON=ZON * X(I)
	 ELSE
	    ZON=0.D0
         ENDIF
        else
         IF( CRR(I).EQ.'RR' ) THEN
            ZON=ZON * X(I) * DCOS(K(I)*OM*TIME)
         ELSEIF( CRR(I).EQ.'RI' ) THEN
            ZON=-ZON * X(I) * DSIN(K(I)*OM*TIME)
	 ELSE
	    ZON=0.D0
         ENDIF
        endif
         FZONAL=FZONAL+ZON
1000  CONTINUE
C
      RETURN
      END
C
C---------------------------------------------------------------------
C
C
*************************************************************************
      FUNCTION UP(X,CFE,R,PHI,NTHETA,TIME,DC)
*     Uphi = 1/(r*sinphi) d^2/drdph rv - d/dth w
*
*     optimized for K=0.
*
*************************************************************************
C
C------------------------------------------------------------------------
      IMPLICIT REAL*8(A-H,O-Z)
      PARAMETER(NMX=65,NMY=128)
C     PARAMETER(NMX=101,NMY=51)
      PARAMETER (NM=5500)
      PARAMETER (PI=3.14159265358979D0)
      CHARACTER*1 CF
      CHARACTER*2 CRR,CFE
C
      DIMENSION X(*)
      DIMENSION THETA(NMY)
C
      COMMON/DIM/NDV,NDW,NDT,NDH,NDG,ND
      COMMON/QNU/NMC,L(NM),M(NM),N(NM),K(NM),CF(NM),CRR(NM)
      COMMON/PARI/RA,TA,PR,PM,ETA,C,OM,FTW,FTG,MF
      COMMON/NPARI/M0,NTV,NTH,LTV,LTH,KTV,KTH,LEV,LRB,LD
C
      COMMON/THETAC/THETA
C
      IF( NM.NE.NMC ) THEN
         WRITE(*,*) 'WRONG DIMENSION NM IN UP.'
         STOP
      ENDIF
C
      THETAR=PI*THETA(NTHETA)/180.D0
      SINTH=DSIN(THETAR)
C
      PPHI=PHI*PI/180.D0
      RI=ETA/(1.D0-ETA)
      UP=0.D0

      IF( CFE.NE.'UP' ) THEN
        WRITE(*,*) 'WRONG CFE IN UP, SHOULD BE UP BUT IS: ',CFE
        STOP
      ENDIF

      NDOMIN=NDV+1
      NDOMAX=NDV+NDW
C------- toroidal part: --------------------------
      DO 1000 I=NDOMIN,NDOMAX
         IF( M(I).EQ.0 ) THEN
            EPSM=1.D0
         ELSE
            EPSM=2.D0
         ENDIF
         IF( K(I).EQ.0 ) THEN
            EPSK=1.D0
         ELSE
            EPSK=2.D0
         ENDIF

         IF(SINTH.EQ.0.D0) THEN
          UPT=0.D0
         ELSE
          DL=DBLE(L(I))
          DM=DBLE(M(I))
          DLPM=DL+DM
          DLMM=DL-DM
C-------               -d/dth w       ----------------
         UPT=EPSM*EPSK/SINTH *
     *    ( (DL+1.D0)*PLMS(L(I)-1,M(I),NTHETA) *
     *      DSQRT(DLPM*DLMM/((2.D0*DL-1)*(2D0*DL+1D0))) -
     -      DL*PLMS(L(I)+1,M(I),NTHETA) *
     *      DSQRT((DLMM+1.D0)*(DLPM+1.D0)/((2D0*DL+3D0)*(2D0*DL+1D0))) )
         ENDIF

         IF( CF(I).EQ.'W' ) THEN
            UPT=UPT*R*DCOS( (N(I)-1)*PI*(R-RI) )
         ELSEIF( CF(I).EQ.'G' ) THEN
            UPT=UPT*DSIN( N(I)*PI*(R-RI) )
         ENDIF
         IF(K(I).EQ.0) THEN
           IF( CRR(I).EQ.'RR' ) THEN
            UPT=UPT * X(I) * DCOS( M(I)*(PPHI-DC*TIME) )
           ELSEIF( CRR(I).EQ.'IR' ) THEN
            UPT=-UPT * X(I) * DSIN( M(I)*(PPHI-DC*TIME) )
           ELSEIF( CRR(I).EQ.'RI' ) THEN
            UPT=0.0D0
           ELSEIF( CRR(I).EQ.'II' ) THEN
            UPT=0.0D0
           ENDIF
         ELSE
           IF( CRR(I).EQ.'RR' ) THEN
            UPT=UPT * X(I) * DCOS( M(I)*(PPHI-DC*TIME) ) *
     *                                          DCOS(K(I)*OM*TIME)
           ELSEIF( CRR(I).EQ.'IR' ) THEN
            UPT=-UPT * X(I) * DSIN( M(I)*(PPHI-DC*TIME) ) *
     *                                          DCOS(K(I)*OM*TIME)
           ELSEIF( CRR(I).EQ.'RI' ) THEN
            UPT=-UPT * X(I) * DCOS( M(I)*(PPHI-DC*TIME) ) *
     *                                          DSIN(K(I)*OM*TIME)
           ELSEIF( CRR(I).EQ.'II' ) THEN
            UPT=UPT * X(I) * DSIN( M(I)*(PPHI-DC*TIME) ) *
     *                                          DSIN(K(I)*OM*TIME)
           ENDIF
         ENDIF

         UP=UP+UPT
1000  CONTINUE


C------- poloidal part: --------------------------
         NDOMIN=1
         NDOMAX=NDV
      DO 2000 I=NDOMIN,NDOMAX
         IF( M(I).EQ.0 ) THEN
            EPSM=1.D0
C           poloidal part is 0 for M=0:
            GOTO 2000
         ELSE
            EPSM=2.D0
         ENDIF
         IF( K(I).EQ.0 ) THEN
            EPSK=1.D0
         ELSE
            EPSK=2.D0
         ENDIF

C------- 1/(rsinth) d^2/drdphi (rv) -------------
         IF( SINTH.EQ.0.D0 .OR. M(I).EQ.0 ) THEN
          UPT=0.D0
         ELSE
          UPT=EPSM*EPSK * M(I) * PLMS(L(I),M(I),NTHETA)  / (R*SINTH)

          UPT=UPT*(R*N(I)*PI*DCOS(N(I)*PI*(R-RI))+DSIN(N(I)*PI*(R-RI)))

         IF(K(I).EQ.0) THEN
           IF( CRR(I).EQ.'RR' ) THEN
            UPT=-UPT * X(I) * DSIN( M(I)*(PPHI-DC*TIME) )
           ELSEIF( CRR(I).EQ.'IR' ) THEN
             UPT=-UPT * X(I) * DCOS( M(I)*(PPHI-DC*TIME) )
           ELSE
             UPT=0.D0
           ENDIF
         ELSE
           IF( CRR(I).EQ.'RR' ) THEN
            UPT=-UPT * X(I) * DSIN( M(I)*(PPHI-DC*TIME) ) *
     *                                          DCOS(K(I)*OM*TIME)
           ELSEIF( CRR(I).EQ.'IR' ) THEN
             UPT=-UPT * X(I) * DCOS( M(I)*(PPHI-DC*TIME) ) *
     *                                          DCOS(K(I)*OM*TIME)
           ELSEIF( CRR(I).EQ.'RI' ) THEN
             UPT=UPT * X(I) * DSIN( M(I)*(PPHI-DC*TIME) ) *
     *                                          DSIN(K(I)*OM*TIME)
           ELSEIF( CRR(I).EQ.'II' ) THEN
             UPT=UPT * X(I) * DCOS( M(I)*(PPHI-DC*TIME) ) *
     *                                          DSIN(K(I)*OM*TIME)
           ENDIF
         ENDIF
         ENDIF

         UP=UP+UPT
2000  CONTINUE
C
      RETURN
      END
C
C---------------------------------------------------------------------
C
*************************************************************************
      FUNCTION DMERI(X,R,NTHETA,TIME)
*************************************************************************
C   Meridionale Zirkulation = phi-gemittelt Stromlinien fuer phi=kostant:
C        < F_phi > = < r sin(theta) dtheta v>  
C
C     optimized for K=0.
C
C----------------------------------------------------------------------- 
C
      IMPLICIT REAL*8(A-H,O-Z)
      PARAMETER (NM=5500)
      PARAMETER (PI=3.14159265358979D0)
      CHARACTER*1 CF
      CHARACTER*2 CRR
C
      DIMENSION X(*)
C
      COMMON/DIM/NDV,NDW,NDT,NDH,NDG,ND
      COMMON/QNU/NMC,L(NM),M(NM),N(NM),K(NM),CF(NM),CRR(NM)
      COMMON/PARI/RA,TA,PR,PM,ETA,C,OM,FTW,FTG,MF
      COMMON/NPARI/M0,NTV,NTH,LTV,LTH,KTV,KTH,LEV,LRB,LD
C
      IF( NM.NE.NMC ) THEN
         WRITE(*,*) 'WRONG DIMENSION NM IN DMERI.'
         STOP
      ENDIF
      RI=ETA/(1.D0-ETA)
      DMERI=0.D0
      NDOMIN=1
      NDOMAX=NDV
C
      DO 1000 I=NDOMIN,NDOMAX
         IF( CF(I).NE.'V' ) THEN
            WRITE(*,*) 'WRONG CF IN FP, SHOULD BE V BUT IS: ',
     &                                                  CF(I)
            STOP
         ENDIF
C
	 IF( M(I).NE.0 ) GOTO 1000
C
         IF( K(I).EQ.0 ) THEN
            EPSK=1.D0
         ELSE
            EPSK=2.D0
         ENDIF

         DMER=EPSK*R * DBLE(L(I)*(L(I)+1)) * (
     &      1.D0/DSQRT( DBLE( (2*L(I)+1)*(2*L(I)+3) ) ) * 
     *					PLMS(L(I)+1,0,NTHETA) -
     -      1.D0/DSQRT( DBLE( (2*L(I)+1)*(2*L(I)-1) ) ) * 
     *					PLMS(L(I)-1,0,NTHETA)  )
         DMER=DMER*DSIN( N(I)*PI*(R-RI) )
C
        if(K(I).EQ.0) then
         IF( CRR(I).EQ.'RR' ) THEN
            DMER=DMER * X(I)
         ELSE
	    DMER=0.D0
         ENDIF
        else
         IF( CRR(I).EQ.'RR' ) THEN
            DMER=DMER * X(I) * DCOS(K(I)*OM*TIME)
         ELSEIF( CRR(I).EQ.'RI' ) THEN
            DMER=-DMER * X(I) * DSIN(K(I)*OM*TIME)
         ELSE
	    DMER=0.D0
         ENDIF
        endif
C
	 DMERI=DMERI+DMER
1000  CONTINUE
C
      RETURN
      END
C
C---------------------------------------------------------------------
C
C
*************************************************************************
      FUNCTION DMTOR(X,R,NTHETA,TIME)
*************************************************************************
C   phi-gemittelte phi-Komponente der Toroidalfeldes:
C           < B_phi > = - dtheta g (m=0)
C
C     optimized for K=0.
C
C------------------------------------------------------------------------
      IMPLICIT REAL*8(A-H,O-Z)
      PARAMETER (NM=5500)
      PARAMETER (PI=3.14159265358979D0)
      CHARACTER*1 CF
      CHARACTER*2 CRR
C
      DIMENSION X(*)
C
      COMMON/DIM/NDV,NDW,NDT,NDH,NDG,ND
      COMMON/QNU/NMC,L(NM),M(NM),N(NM),K(NM),CF(NM),CRR(NM)
      COMMON/PARI/RA,TA,PR,PM,ETA,C,OM,FTW,FTG,MF
      COMMON/NPARI/M0,NTV,NTH,LTV,LTH,KTV,KTH,LEV,LRB,LD
C
      IF( NM.NE.NMC ) THEN
         WRITE(*,*) 'WRONG DIMENSION NM IN DMTOR.'
         STOP
      ENDIF
C
      RI=ETA/(1.D0-ETA)
      DMTOR=0.D0
      NDOMIN=NDV+NDW+NDT+NDH+1
      NDOMAX=NDV+NDW+NDT+NDH+NDG
      DO 1000 I=NDOMIN,NDOMAX
         IF( CF(I).NE.'G' ) THEN
            WRITE(*,*) 'WRONG CF IN DMTOR, SHOULD BE G BUT IS: ',
     &                                                  CF(I)
            STOP
         ENDIF
         IF( M(I).NE.0 ) GOTO 1000
         IF( K(I).EQ.0 ) THEN
            EPSK=1.D0
         ELSE
            EPSK=2.D0
         ENDIF
         DMT=EPSK*DSQRT(DBLE(L(I)*(L(I)+1))) * PLMS(L(I),1,NTHETA) * 
     *                                DSIN( N(I)*PI*(R-RI) )
        if(K(I).EQ.0) then
         IF( CRR(I).EQ.'RR' ) THEN
            DMT=DMT * X(I)
	 ELSE
	    DMT=0.D0
         ENDIF
        else
         IF( CRR(I).EQ.'RR' ) THEN
            DMT=DMT * X(I) * DCOS(K(I)*OM*TIME)
         ELSEIF( CRR(I).EQ.'RI' ) THEN
            DMT=-DMT * X(I) * DSIN(K(I)*OM*TIME)
	 ELSE
	    DMT=0.D0
         ENDIF
        endif
         DMTOR=DMTOR-DMT
1000  CONTINUE
C
      RETURN
      END
C
C---------------------------------------------------------------------
C
C
*************************************************************************
      FUNCTION DMPJ(X,CFE,R,NTHETA,TIME)
*************************************************************************
C  phi-gemittelte Stomlinien des Poloidalfeldes fuer phi=konstant:
C            < F_phi > = r sin(theta) dtheta h (m=0)
C  oder des elektrischen Stromes: 
C            < F_phi > = r sin(theta) dtheta g (m=0)
C
C     optimized for K=0.
C
C------------------------------------------------------------------------
      IMPLICIT REAL*8(A-H,O-Z)
      PARAMETER (NM=5500,NAM=400)
      PARAMETER (PI=3.14159265358979D0)
      CHARACTER*1 CF
      CHARACTER*2 CRR,CFE
C
      DIMENSION X(*)
C
      COMMON/DIM/NDV,NDW,NDT,NDH,NDG,ND
      COMMON/QNU/NMC,L(NM),M(NM),N(NM),K(NM),CF(NM),CRR(NM)
      COMMON/PARI/RA,TA,PR,PM,ETA,C,OM,FTW,FTG,MF
      COMMON/NPARI/M0,NTV,NTH,LTV,LTH,KTV,KTH,LEV,LRB,LD
      COMMON/AB/A(NAM),B(NAM),NAMC
C
      IF( NM.NE.NMC ) THEN
         WRITE(*,*) 'WRONG DIMENSION NM IN DMPJ.'
         STOP
      ENDIF
      IF( NAM.NE.NAMC ) THEN
         WRITE(*,*) 'WRONG DIMENSION NAM IN DMPJ.'
         STOP
      ENDIF
C
      RI=ETA/(1.D0-ETA)
      RO=RI+1.D0
      DMPJ=0.D0
      IF( CFE.EQ.'MP' ) THEN
         NDOMIN=NDV+NDW+NDT+1
         NDOMAX=NDV+NDW+NDT+NDH
      ELSEIF( CFE.EQ.'MJ' ) THEN
         NDOMIN=NDV+NDW+NDT+NDH+1
         NDOMAX=NDV+NDW+NDT+NDH+NDG
      ELSE
         WRITE(*,*) 
     &    'WRONG CFE IN DMPJ, SHOULD BE MP OR MJ BUT IS: ',CFE
         STOP
      ENDIF
      DO 1000 I=NDOMIN,NDOMAX
         IF( .NOT.( ( CF(I).EQ.'H' .AND. CFE.EQ.'MP' ) .OR.
     &              ( CF(I).EQ.'G' .AND. CFE.EQ.'MJ' )  ) ) THEN
            WRITE(*,*) 'WRONG CF IN DMPJ, SHOULD BE H OR G BUT IS: ',
     &                                                  CF(I)
            STOP
         ENDIF
         IF( M(I).NE.0 ) GOTO 1000
         IF( K(I).EQ.0 ) THEN
            EPSK=1.D0
         ELSE
            EPSK=2.D0
         ENDIF
         DMP=EPSK*R * DBLE(L(I)*(L(I)+1)) * (
     &        PLMS(L(I)+1,M(I),NTHETA) /
     /                      DSQRT( DBLE( (2*L(I)+1)*(2*L(I)+3) ) )  -
     -        PLMS(L(I)-1,M(I),NTHETA) /
     /                      DSQRT( DBLE( (2*L(I)+1)*(2*L(I)-1) ) )   )
	 IF( CF(I).EQ.'H' ) THEN
            NR=NAB(L(I),N(I))
            IF( R.LE.RO ) THEN
               IF( A(NR).EQ.0.D0 .OR. B(NR).EQ.0.D0 ) THEN
                  WRITE(*,*) 'ALPHA AND BETA NOT CALCULATED.'
                  STOP  
               ENDIF
               DMP=DMP*DCOS( A(NR)*R-B(NR) )
            ELSE
               IF( A(NR).EQ.0.D0 .OR. B(NR).EQ.0.D0 ) THEN
                  WRITE(*,*) 'ALPHA AND BETA NOT CALCULATED.'
                  STOP  
               ENDIF
               DMP=DMP * (RO/R)**(L(I)+1) * DCOS( A(NR)*RO-B(NR) )
            ENDIF
	 ELSEIF( CF(I).EQ.'G' ) THEN
            DMP=DMP*DSIN( N(I)*PI*(R-RI) )
	 ENDIF
        if(K(I).EQ.0) then
         IF( CRR(I).EQ.'RR' ) THEN
            DMP=DMP * X(I)
         ELSE	
	    DMP=0.D0
         ENDIF
        else
         IF( CRR(I).EQ.'RR' ) THEN
            DMP=DMP * X(I) * DCOS(K(I)*OM*TIME)
         ELSEIF( CRR(I).EQ.'RI' ) THEN
            DMP=-DMP * X(I) * DSIN(K(I)*OM*TIME)
         ELSE	
	    DMP=0.D0
         ENDIF
        endif
         DMPJ=DMPJ+DMP
1000  CONTINUE
C
      RETURN
      END
C
C---------------------------------------------------------------------
C
C
*************************************************************************
      FUNCTION DMC(X,R,NTHETA,TIME)
*************************************************************************
C Ueber Phi gemittelte Phi-Komponente des elektrischen Stromes: 
C            dtheta laplace h  (m=0).
C
C     optimized for K=0.
C
C------------------------------------------------------------------------
      IMPLICIT REAL*8(A-H,O-Z)
      PARAMETER (NM=5500,NAM=400)
      CHARACTER*1 CF
      CHARACTER*2 CRR
C
      DIMENSION X(*)
C
      COMMON/DIM/NDV,NDW,NDT,NDH,NDG,ND
      COMMON/QNU/NMC,L(NM),M(NM),N(NM),K(NM),CF(NM),CRR(NM)
      COMMON/PARI/RA,TA,PR,PM,ETA,C,OM,FTW,FTG,MF
      COMMON/NPARI/M0,NTV,NTH,LTV,LTH,KTV,KTH,LEV,LRB,LD
      COMMON/AB/A(NAM),B(NAM),NAMC
C
      IF( NM.NE.NMC ) THEN
         WRITE(*,*) 'WRONG DIMENSION NM IN DMC.'
         STOP
      ENDIF
      IF( NAM.NE.NAMC ) THEN
         WRITE(*,*) 'WRONG DIMENSION NAM IN DMC.'
         STOP
      ENDIF
      RI=ETA/(1.D0-ETA)
      DMC=0.D0
      NDOMIN=NDV+NDW+NDT+1
      NDOMAX=NDV+NDW+NDT+NDH
      DO 1000 I=NDOMIN,NDOMAX
         IF( CF(I).NE.'H' ) THEN
            WRITE(*,*) 'WRONG CF IN DMC, SHOULD BE H BUT IS: ',
     &                                                  CF(I)
            STOP
         ENDIF
         IF( M(I).NE.0 ) GOTO 1000
         IF( K(I).EQ.0 ) THEN
            EPSK=1.D0
         ELSE
            EPSK=2.D0
         ENDIF
         DM=EPSK*DSQRT(DBLE(L(I)*(L(I)+1))) * PLMS(L(I),1,NTHETA)
         NR=NAB(L(I),N(I))
         IF( A(NR).EQ.0.D0 .OR. B(NR).EQ.0.D0 ) THEN
            WRITE(*,*) 'ALPHA AND BETA NOT CALCULATED.'
            STOP  
         ENDIF
         DM=-DM*(
     &           ( A(NR)*A(NR)+DBLE(L(I)*(L(I)+1))/(R*R) ) *
     *                                DCOS( A(NR)*R-B(NR) ) +
     +                    2*A(NR)/R * DSIN( A(NR)*R-B(NR) )  )
C
        if(K(I).EQ.0) then
         IF( CRR(I).EQ.'RR' ) THEN
            DM=DM * X(I)
	 ELSE
	    DM=0.D0
         ENDIF
        else
         IF( CRR(I).EQ.'RR' ) THEN
            DM=DM * X(I) * DCOS(K(I)*OM*TIME)
         ELSEIF( CRR(I).EQ.'RI' ) THEN
            DM=-DM * X(I) * DSIN(K(I)*OM*TIME)
	 ELSE
	    DM=0.D0
         ENDIF
        endif
	 DMC=DMC-DM
1000  CONTINUE
C
      RETURN
      END
C
C---------------------------------------------------------------------
C
C
***************************************************************************
      SUBROUTINE ABG(ND,CF,LA,NA)
***************************************************************************
C     THIS PROGRAM FINDS THE A'S AND B'S OF THE POLODIAL MAGNETIC
C     FIELD TO FULLFILL THE BOUNDARY CONDITIONS:
C     A(I)*TAN(A(I)*RO-B(I))-(L+1)/RO = 0  AND
C     A(I)*TAN(A(I)*RI-B(I))+L/RI = 0 WITH A PRCISSION OF 1D-13.
C     THE A'S AND B'S ARE STORED LINEARLY IN THE ARRAYS, NAB(L,N)
C     DETERMINS THE POSITION IN THE ARRAY.
C     NEEDS FUNCTIONS AMIN,NAB .
C-------------------------------------------------------------------------
      IMPLICIT REAL*8(A-H,O-Y)
      CHARACTER*1 CF
      PARAMETER(NAM=400)
      PARAMETER(NLMA=100)
      PARAMETER(DPI=3.141592653589793D0)
C
      DIMENSION CF(*),LA(*),NA(*)
C
      COMMON/LOG/LCALC,LWRITE,LTR,LVAR,LDY,L6,L7,L8,L9,L10
      COMMON/PAR/RA,TA,PR,PM,ETA,C,OM,FTW,FTG,MF
      COMMON/NPAR/M0,NTV,NTH,LTV,LTH,KTV,KTH,LEV,LRB,LD
      COMMON/NUM/RELE,EPS,ALPH,STOER,NITMAX,NJA
C
      COMMON/AB/A(NAM),B(NAM),NAMC
      COMMON/ABMIN/RIAB,ROAB,RELEAB,LAB
      COMMON/LNMAX/NLMAC,NL,LC(100),NMAXC(100),NMABC
C
      IF( NAM.NE.NAMC ) THEN
         WRITE(*,*) 'WRONG DIMENSION NAM IN ABG.'
         STOP
      ENDIF
      IF( NLMA.NE.NLMAC ) THEN
         WRITE(*,*) 'WRONG DIMENSION NLMA IN ABG.'
         STOP
      ENDIF
C
      CALL CALCNMAX(ND,CF,LA,NA)
C
C
      RI=ETA/(1.D0-ETA)
      RO=RI+1.D0
      RIAB=RI
      ROAB=RO
      DAX=1.D-3
C
      IF( DAX.LT.RELE*1.D3 ) THEN
         RELEAB=RELE*1.D-4
      ELSE
         RELEAB=RELE
      ENDIF
      RELEAB=DMAX1(RELEAB,EPS)
C
      IA=1
      DO 1000 NI=1,NL
         L=IABS(LC(NI))
         NMAX=NMAXC(NI)
C
         IF( NMAX.LE.0 ) THEN
            GOTO 1000
         ELSEIF( NMAX.GT.NAM ) THEN
            WRITE(*,*) 'TOO SMALL NAM IN DABG.'
            STOP
         ENDIF
         N=1
         LAB=L
         IF( RI.EQ.0 ) THEN
            DO 100 I=0,2000
               IF( I.EQ.0 ) THEN
                  AXMIN=DAX
               ELSE
                  AXMIN=(I-0.5D0)*DPI+DAX
               ENDIF
               AXMAX=(I+0.5D0)*DPI-DAX
               IF( IA.GT.NAM ) THEN
                  WRITE(*,*) 'TOO SMALL DIMENSION NAM IN ABG.'
                  STOP
               ENDIF
               AGUESS=AXMAX
               LBT=0
90             A(IA)=AMINB(AGUESS)
               IF( LBT.EQ.0 .AND.
     &              ( A(IA).LT.AXMIN .OR. A(IA).GT.AXMAX ) ) THEN
                  LBT=1
                  AGUESS=AXMIN
                  GOTO 90
               ELSEIF( LBT.EQ.1 .AND.
     &              ( A(IA).LT.AXMIN .OR. A(IA).GT.AXMAX ) ) THEN
                  WRITE(*,*) 'WRONG ALPHA!!!!'
                  WRITE(*,'(X,'' IA,L,ALPHAMIN,ALPHA,ALPHAMAX: '',
     &                  2I4,3D16.6)') IA,L,AXMIN,A(IA),AXMAX
                  STOP
               ENDIF
               B(IA)=0.0D0
               IA=IA+1
               N=N+1
               IF(N.GT.NMAX) GOTO 1000
100         CONTINUE
         ELSE
            CD=DSQRT(L*(L+1)/RI/RO)
            AXMIN=DAX
            AXMAX=0.5D0*DPI-DAX
            IF(AXMAX.GT.CD) THEN
               IF( IA.GT.NAM ) THEN
                  WRITE(*,*) 'TOO SMALL DIMENSION NAM IN ABG.'
                  STOP
               ENDIF
               AGUESS=AXMAX
               LBT=0
190            A(IA)=AMIN(AGUESS)
               IF( LBT.EQ.0 .AND.
     &              ( A(IA).LT.AXMIN .OR. A(IA).GT.AXMAX ) ) THEN
                  LBT=1
                  AGUESS=AXMIN
                  GOTO 190
               ELSEIF( LBT.EQ.1 .AND.
     &              ( A(IA).LT.AXMIN .OR. A(IA).GT.AXMAX ) ) THEN
                  WRITE(*,*) 'WRONG ALPHA!!!!'
                  WRITE(*,'(X,'' IA,L,ALPHAMIN,ALPHA,ALPHAMAX: '',
     &                  2I4,3D16.6)') IA,L,AXMIN,A(IA),AXMAX
                  STOP
               ENDIF
               B(IA)=A(IA)*RI+DATAN(L/A(IA)/RI)
               IA=IA+1
               N=N+1
               IF(N.GT.NMAX) GOTO 1000
            ENDIF
            DO 200 I=1,2000
               DAX=1D-3
               AXMIN=(I-0.5D0)*DPI+DAX
               AXMAX=(I+0.5D0)*DPI-DAX
               IF(AXMIN.LT.CD .AND. AXMAX.GT.CD ) THEN
                  IF( IA.GT.NAM ) THEN
                     WRITE(*,*) 'TOO SMALL DIMENSION NAM IN ABG.'
                     STOP
                  ENDIF
                  AGUESS=AXMIN
                  LBT=0
290               A(IA)=AMIN(AGUESS)
                  IF( LBT.EQ.0 .AND.
     &                 ( A(IA).LT.AXMIN .OR. A(IA).GT.AXMAX ) ) THEN
                     LBT=1
                     AGUESS=AXMAX
                     GOTO 290
                  ELSEIF( LBT.EQ.1 .AND.
     &              ( A(IA).LT.AXMIN .OR. A(IA).GT.AXMAX ) ) THEN
                     WRITE(*,*) 'WRONG ALPHA!!!!'
                     WRITE(*,'(X,'' IA,L,ALPHAMIN,ALPHA,ALPHAMAX: '',
     &                     2I4,3D16.6)') IA,L,AXMIN,A(IA),AXMAX
                     STOP
                  ENDIF
                  B(IA)=A(IA)*RI+DATAN(L/A(IA)/RI)
                  IA=IA+1
                  N=N+1
                  IF(N.GT.NMAX) GOTO 1000
               ENDIF
150            CONTINUE
               IF( IA.GT.NAM ) THEN
                  WRITE(*,*) 'TOO SMALL DIMENSION NAM IN ABG.'
                  STOP
               ENDIF
               AGUESS=AXMAX
               LBT=0
390            A(IA)=AMIN(AGUESS)
               IF( LBT.EQ.0 .AND.
     &              ( A(IA).LT.AXMIN .OR. A(IA).GT.AXMAX ) ) THEN
                  LBT=1
                  AGUESS=AXMIN
                  GOTO 390
               ELSEIF( LBT.EQ.1 .AND.
     &              ( A(IA).LT.AXMIN .OR. A(IA).GT.AXMAX ) ) THEN
                  WRITE(*,*) 'WRONG ALPHA!!!!'
                  WRITE(*,'(X,'' IA,L,ALPHAMIN,ALPHA,ALPHAMAX: '',
     &                  2I4,3D16.6)') IA,L,AXMIN,A(IA),AXMAX
                  STOP
               ENDIF
               B(IA)=A(IA)*RI+DATAN(L/A(IA)/RI)
               IA=IA+1
               N=N+1
               IF(N.GT.NMAX) GOTO 1000
200         CONTINUE
         ENDIF
1000  CONTINUE
      DO 2000 I=1,IA-1
         IF( I.GT.1 .AND. ( A(I).GT.A(I-1)-RELE .AND.
     &       A(I).LT.A(I-1)+RELE ) ) THEN
            WRITE(*,*) 'TWO ALPHAS EQUAL: ',A(I-1),A(I)
            STOP
         ENDIF
         DO 300 J=1,100
            B(I)=B(I)-DPI
            IF(B(I).LT.0.D0) THEN
               B(I)=B(I)+DPI
               GOTO 400
            ENDIF
300      CONTINUE
400      CONTINUE
2000  CONTINUE
C
      IA=IA-1
      WRITE(*,*) IA,' ALPHA AND BETA CALCULATED.'
      NMABC=IA
      DO 3000 I=1,IA
3000  WRITE(*,'(2X,I4,2D14.6)') I,A(I),B(I)
C
      RETURN
      END
C
C------------------------------------------------------------------------
C
C
***************************************************************************
      FUNCTION AMIN(AX)
***************************************************************************
C     FINDS THE MINIMUM FOR THE FUNCTION IN LINE 5 WITH A NEWTON METHOD.
C--------------------------------------------------------------------------
      IMPLICIT REAL*8(A-H,O-Y)
C
      COMMON/ABMIN/RI,RO,RELE,L
C
      ICOUNT=0
C
5     FA=DTAN(AX)-(L*RO+(L+1)*RI)*AX/(RI*RO*AX**2-L*(L+1))
      FAA=1D0/DCOS(AX)**2-( (L*RO+(L+1)*RI)*(RI*RO*AX**2-L*(L+1)) -
     -      AX*(L*RO+(L+1)*RI)*2*RI*RO*AX )/(RI*RO*AX**2-L*(L+1))**2
      IF(FAA.EQ.0) THEN
         AX=AX+RELE
         GOTO 5
      ENDIF
      DA=FA/FAA
      AOX=AX
      AX=AX-DA
      IF(DABS(1-DABS(AOX/AX)).LT.RELE) THEN
         AMIN=AX
         RETURN
      ENDIF
      ICOUNT=ICOUNT+1
      IF(ICOUNT.GT.100) THEN
         WRITE(*,*) 'NO ZERO FOUND IN DABG/AMIN.'
         STOP
      ENDIF
      GOTO 5
C
      END
C------------------------------------------------------------------------
C
C
***************************************************************************
      FUNCTION AMINB(AX)
***************************************************************************
C     FINDS THE MINIMUM FOR THE FUNCTION IN LINE 5 WITH A NEWTON METHOD.
C--------------------------------------------------------------------------
      IMPLICIT REAL*8(A-H,O-Y)
C
      COMMON/ABMIN/RI,RO,RELE,L
C
5     FA=DTAN(AX*RO)-(L+1)/AX/RO
      FAA=RO/DCOS(AX*RO)**2+(L+1)/AX**2/RO
      IF(FAA.EQ.0) THEN
         AX=AX+RELE
         GOTO 5
      ENDIF
      DA=FA/FAA
      AOX=AX
      AX=AX-DA
      IF(DABS(1-DABS(AOX/AX)).LT.RELE) THEN
         AMINB=AX
         RETURN
      ENDIF
      GOTO 5
C
      END
C------------------------------------------------------------------------
C
C
************************************************************************
      FUNCTION NAB(L,N)
************************************************************************
C     DETERMINS THE POSITION OF AN A ORE B IN THE ARRAY A(I),B(I)
C     DEPENDING ON L AND N.
C-----------------------------------------------------------------------
C
      IMPLICIT REAL*8(A-H,O-Y)
      PARAMETER(NLMA=100)
C
      COMMON/LOG/LCALC,LWRITE,LTR,LVAR,LDY,L6,L7,L8,L9,L10
      COMMON/PAR/RA,TA,PR,PM,ETA,C,OM,FTW,FTG,MF
      COMMON/NPAR/M0,NTV,NTH,LTV,LTH,KTV,KTH,LEV,LRB,LD
C
ccc   COMMON/LNMAX/NLMAC,NL,LC(100),NMAXC(100),NMABC
      COMMON/LNMAX/NLMAC,NL,LC(NLMA),NMAXC(NLMA),NMABC
C
      IF( NLMA.NE.NLMAC ) THEN
         WRITE(*,*) 'WRONG DIMENSION NLMA IN NAB.'
         STOP
      ENDIF
C
      LMIN=LC(1)
      LMAX=LC(NL)
      IF( L.GT.LMAX .OR. L.LT.LMIN ) THEN
         WRITE(*,*) 'WRONG L IN NAB',L,LMIN,LMAX
         STOP
      ENDIF
      NAB=0
      DO 1000 NI=1,NL
         LL=LC(NI)
         NMAX=NMAXC(NI)
         IF( LL.LT.L ) THEN
            IF( NMAX.GT.0 ) NAB=NAB+NMAX
         ELSEIF( LL.EQ.L ) THEN
            IF( NMAX.LT.N ) THEN
               WRITE(*,*) 'WRONG N IN NAB',N,NMAX
               STOP
            ELSE
               NAB=NAB+N
               RETURN
            ENDIF
         ENDIF
1000  CONTINUE
C
      IF( N.GT.NMABC ) THEN
         WRITE(*,*)
     &   'N LARGER THE CALCULATED NUMBER OF A,B IN NAB: ',N,NMABC
         STOP
      ENDIF
C
      END
C
*******************************************************************
C
C
*******************************************************************
      SUBROUTINE CALCNMAX(NK,CF,L,N)
*******************************************************************
C-- CALCULATES THE MAXIMUM N FOR EACH L.
C   THIS IS USED FOR CALCULATING THE RADIAL FUNCTION OF H.
C------------------------------------------------------------------
      IMPLICIT REAL*8(A-H,O-Z)
      CHARACTER*1 CF
      DIMENSION CF(*),L(*),N(*)
      PARAMETER(NLMA=100)
C
      COMMON/LNMAX/NLMAC,NL,LC(NLMA),NMAX(NLMA),NMABC
C
      NLMAC=NLMA
C
C-- BESTIMMMUNG VON NMAX FUER JEDES L , NOTWENDIG IN ABG:
      LOLD=10000
      NL=0
      DO 1000 I=1,NK
         IF( CF(I).EQ.'H' ) THEN
            IF( L(I).NE.LOLD ) THEN
               NL=NL+1
               IF( NL.GT.NLMA ) THEN
                  WRITE(*,*) 'TOO SMALL DIMENSION NLMA IN CALCNMAX.'
                  STOP
               ENDIF
               LC(NL)=L(I)
               NMAX(NL)=N(I)
               LOLD=L(I)
            ELSEIF( L(I).EQ.LOLD .AND. N(I).GT.NMAX(NL) ) THEN
               NMAX(NL)=N(I)
            ENDIF
         ENDIF
1000  CONTINUE
C
      RETURN
      END
C
C-----------------------------------------------------------------------
C 
C
C
C
*************************************************************************
      FUNCTION DBT(X,R,PHI,NTHETA,TIME,DC)
*************************************************************************
C Phi -Komponente des Toroidalfeldes: - dtheta g
C------------------------------------------------------------------------
      IMPLICIT REAL*8(A-H,O-Z)
      PARAMETER (NM=5500)
      PARAMETER (PI=3.141592654D0)
      CHARACTER*1 CF
      CHARACTER*2 CRR
C
      DIMENSION X(*)
C
      COMMON/DIM/NDV,NDW,NDT,NDH,NDG,ND
      COMMON/QNU/NMC,L(NM),M(NM),N(NM),K(NM),CF(NM),CRR(NM)
      COMMON/PARI/RA,TA,PR,PM,ETA,C,OM,FTW,FTG,MF
      COMMON/NPARI/M0,NTV,NTH,LTV,LTH,KTV,KTH,LEV,LRB,LD
C
      IF( NM.NE.NMC ) THEN
         WRITE(*,*) 'WRONG DIMENSION NM IN DMPJ.'
         STOP
      ENDIF
C
      PPHI=PHI*PI/180.D0
      RI=ETA/(1.D0-ETA)
      DBT=0.D0
      NDOMIN=NDV+NDW+NDT+NDH+1
      NDOMAX=NDV+NDW+NDT+NDH+NDG
      DO 1000 I=NDOMIN,NDOMAX
         IF( CF(I).NE.'G' ) THEN
            WRITE(*,*) 'WRONG CF IN DBT, SHOULD BE G BUT IS: ',
     &                                                  CF(I)
            STOP
         ENDIF
         IF( M(I).EQ.0 ) THEN
            EPSM=1.D0
         ELSE
            EPSM=2.D0
         ENDIF
         IF( K(I).EQ.0 ) THEN
            EPSK=1.D0
         ELSE
            EPSK=2.D0
         ENDIF
         DB=-0.5D0*EPSM*EPSK* (
     &        DSQRT(DBLE((L(I)-M(I)+1)*(L(I)+M(I)))) * 
     *                               PLMS(L(I),M(I)-1,NTHETA) -
     -        DSQRT(DBLE((L(I)+M(I)+1)*(L(I)-M(I)))) * 
     *                               PLMS(L(I),M(I)+1,NTHETA) )
	 DB=DB*DSIN( N(I)*PI*(R-RI) )
         IF( CRR(I).EQ.'RR' ) THEN
            DB=DB * X(I) * DCOS( M(I)*(PPHI-DC*TIME) ) *
     *                                          DCOS(K(I)*OM*TIME)
         ELSEIF( CRR(I).EQ.'IR' ) THEN
            DB=-DB * X(I) * DSIN( M(I)*(PPHI-DC*TIME) ) *
     *                                          DCOS(K(I)*OM*TIME)
         ELSEIF( CRR(I).EQ.'RI' ) THEN
            DB=-DB * X(I) * DCOS( M(I)*(PPHI-DC*TIME) ) *
     *                                          DSIN(K(I)*OM*TIME)
         ELSEIF( CRR(I).EQ.'II' ) THEN
            DB=DB * X(I) * DSIN( M(I)*(PPHI-DC*TIME) ) *
     *                                          DSIN(K(I)*OM*TIME)
         ENDIF
         DBT=DBT+DB
1000  CONTINUE
C
      RETURN
      END
C
C---------------------------------------------------------------------
