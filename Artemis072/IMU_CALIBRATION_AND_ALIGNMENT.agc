### FILE="Main.annotation"
# Copyright:	Public domain.
# Filename:	IMU_CALIBRATION_AND_ALIGNMENT.agc
# Purpose:	Part of the source code for Artemis (i.e., Colossus 3),
#		build 072.  This is for the Command Module's (CM) 
#		Apollo Guidance Computer (AGC), we believe for 
#		Apollo 15-17.
# Assembler:	yaYUL
# Contact:	Sergio Navarro <sergionavarrog@gmail.com>
# Website:	www.ibiblio.org/apollo/index.html
## Page scans:	www.ibiblio.org/apollo/ScansForConversion/Artemis072/
# Mod history:	2009-08-19 SN	Adapted from corresponding Comanche 055 file.
# 		2009-09-03 JL	Fixed symbol names.
# 		2009-09-06 JL	Fixed typos.
# 		2010-01-31 JL	Fixed build errors.
# 		2010-02-02 JL	Fixed whitespace.
#		2010-02-20 RSB	Un-##'d this header.

## Page 427

# NAME-	IMU PERFORMANCE TESTS 2
#
# DATE-	MARCH 20,1967
#
# BY- SYSTEM TEST GROUP 864-6900 EXT. 1274
#
# MODNO.- ZERO
#
# FUNCTIONAL DESCRIPTION
#
# POSITIONING ROUTINES FOR THE IMU PERFORMANCE TESTS AS WELL AS SOME OF
# THE TESTS THEMSELVES. FOR A DESCRIPTION OF THESE SUBROUTINES AND THE
# OPERATING PROCEDURES (TYPICALLY) SEE STG MEMO 685. THEORETICAL REF. E-1973

		SETLOC	IMUCAL
		BANK
		
		EBANK=	POSITON
		COUNT*	$$/COMST
GEOIMUTT	TC	BANKCALL		# GYROCOMPASS COMES IN HERE
		CADR	IMUZERO
		TC	IMUSTLLG
IMUBACK		CA	ZERO
		TS	NDXCTR
		TS	TORQNDX
		TS	TORQNDX	+1
NBPOSPL		CA	DEC17
		TS	ZERONDX1
		CA	XNBADR
		TC	ZEROING
		CA	HALF
		TS	XNB
		TC	INTPRET
		DLOAD	SIN
			AZIMUTH
		STORE	YNB +2
		STODL	ZNB +4
			AZIMUTH
		COS
		STORE	YNB +4
		DCOMP
		STORE	ZNB +2
		EXIT
		TC	CHECKMM
		MM	03			# SEE IF IN OPTICAL VERIFICATION
		TCF	+2			# NO
		TCF	SETNBPOS +1		# YES
		TC	INTPRET
		CALL
			CALCGA
## Page 428
		EXIT
		TC	BANKCALL
		CADR	IMUCOARS
		CAF	GLOKFBIT		# IF GLOKFAIL SET, GIMBAL LOCK
		MASK	FLAGWRD3
		EXTEND
		BZF	+2
		INCR	NDXCTR			# +1 IF IN GIMBAL LOCK, OTHERWISE 0
		TC	DOWNFLAG		# RESET GIMBAL LOCK FLAG
		ADRES	GLOKFAIL		# BIT 14 FLAG 3
		TC	IMUSTLLG
		CCS	NDXCTR			# IF ONE GO AND DO A PIPA TEST ONLY
		TC	PIPACHK			# ALIGN AND MEASURE VERTICAL PIPA RATE
		TC	BANKCALL
		CADR	IMUFINE
		TC	IMUSTLLG
		EXTEND
		DCA	PERFDLAY
		TC	LONGCALL
		EBANK=	POSITON
		2CADR	GOESTIMS

		CA	ESTICADR
		TC	JOBSLEEP
GOESTIMS	CA	ESTICADR
		TC	JOBWAKE
		TC	TASKOVER
ESTICADR	CADR	ESTIMS

TORQUE		CA	ZERO
		TS	DSPTEM2
		CA	DRIFTI
		TS	DSPTEM2	+1
		INDEX	POSITON
		TS	SOUTHDR	-1
		TC	SHOW

PIPACHK		CA	EBANK4
		TS	EBANK
		EBANK=	ERASPIP
		TC	ERASPIP
		EBANK=	DRIFTO
VALMIS		CA	DRIFTO
		TS	DSPTEM2 +1
		CA	ZERO
		TS	DSPTEM2
		TC	SHOW

ENDTEST1	TC	DOWNFLAG	# IMU NOT IN USE
## Page 429
		ADRES	IMUSE		# BIT 8 FLAG 0
		CS	ZERO
		TC	NEWMODEA
		TC	BANKCALL
		CADR	MKRELEAS
		TC	ENDEXT
## Page 430
OVERFFIX	DAD	DAD
			DPPOSMAX
			ONEDPP
		RVQ
		
IMUSTLLG	EXTEND
		QXCH	QPLACE
		TC	BANKCALL
		CADR	IMUSTALL
		TC	SOMERR2
		TC	QPLACE
ZEROING		TS	L
		TCF	+2
ZEROING1	TS	ZERONDX1
		CAF	ZERO
		INDEX	L
		TS	0
		INCR	L
		CCS	ZERONDX1
		TCF	ZEROING1
		TC	Q

## Page 431
		SETLOC	IMUCAL3
		BANK
		COUNT*	$$/COMST
ERTHRVSE	DLOAD	PDDL
			SCHZEROS	# PD24 = (SIN		-COS	0)(OMEG/MS)
			LATITUDE
		COS	DCOMP
		PDDL	SIN
			LATITUDE
		VDEF	VXSC
			OMEG/MS
		STORE	ERVECTOR
		RTB
			LOADTIME
		STOVL	TMARK
			SCHZEROS
		STORE	ERCOMP1
		RVQ
		SETLOC	IMUCAL
		BANK
		COUNT*	$$/COMST
EARTHR		ITA	RTB		# CALCULATES AND COMPENSATES EARTH RATE
			S2
			LOADTIME
 +3		STORE	TEMPTIME
		DSU	BPL
			TMARK
			ERTHR
		CALL
			OVERFFIX
ERTHR		SL	VXSC
			9D
			ERVECTOR
		MXV	VAD
			XSM
			ERCOMP1
		STODL	ERCOMP1
			TEMPTIME
		STORE	TMARK
		AXT,1	RTB
		ECADR	ERCOMP1
			PULSEIMU
		GOTO
			S2	
EARTHR*		EXTEND
		QXCH	QPLACES
		TC	INTPRET
		CALL
			EARTHR
PROUT		EXIT
## Page 432
		TC	IMUSTLLG
		TC	QPLACES
SHOW		EXTEND
		QXCH	QPLACE
SHOW1		CA	POSITON
		TS	DSPTEM2 +2
		CA	VB06N98
		TC	BANKCALL
		CADR	GOFLASH
		TC	ENDTEST1	# V34
		TC	QPLACE		# V33
		TCF	SHOW1


3990DEC		=	OMEG/MS
VB06N98		VN	0698
DEC17		=	ND1
OGCPL		ECADR	OGC
1SECX		=	1SEC
DEC57		=	VD1
XNBADR		GENADR	XNB
XSMADR		GENADR	XSM
OMEG/MS		2DEC	.24339048


P11OUT		TC	BANKCALL
		CADR	MATRXJOB	# RETURN TO P11

		SETLOC	FFTAG1
		BANK	

		COUNT*	$$/COMST
FINETIME	INHINT			# RETURNS WITH INTERRUPT INHIBITED
 +1		EXTEND
		READ	LOSCALAR
		TS	L
		EXTEND
		RXOR	LOSCALAR
		EXTEND
		BZF	+4
		EXTEND
		READ	LOSCALAR
		TS	L
 +4		CS	POSMAX
		AD	L
		EXTEND
		BZF	FINETIME +1
		EXTEND
		READ	HISCALAR
## Page 433
		TC Q


# PROGRAM NAME-  OPTIMUM PRELAUNCH ALIGNMENT CALIBRATION
# DATE- NOVEMBER 2  1966
# BY- GEORGE SCHMIDT IL 7-146 EXT. 126
# MOD NO 3
#
# FUNCTIONAL DESCRIPTION
#
# THIS SECTION CONSISTS OF PRELAUNCH ALIGNMENT AND GYRO DRIFT TESTS
# INTEGRATED TOGETHER TO SAVE WORDS. COMPASS IS COMPLETELY RESTART
# PROOFED EXCEPT FOR THE FIRST 30 SECONDS OR SO. PERFORMANCE TESTS OF
# THE IRIGS IS RESTART PROOFED ENOUGH TO GIVE 75 PERCENT CONFIDENCE THAT
# IF A RESTART OCCURS THE DATA WILL STILL BE GOOD. GOOD PRACTICE TO RECYCL
# WHEN A RESTART OCCURS UNLESS IT HAPPENS NEAR THE END OF A TEST - THEN WAIT
# FOR THE DATA TO FLASH.
#
# A RESTART IN GYROCOMPASS DURING GYRO TORQUING CAUSES PULSES TO BE LOST
# THE PRELAUNCH ALIGNMENT TECHNIQUE IS BASICALLY THE SAME AS IN BLOCK 1
# EXCEPT THAT IT HAS BEEN SIMPLIFIED IN THE SENSE THAT SMALL ANGLE APPROX.
# HAVE BEEN USED. THE DRIFT TESTS USE A UNIQUE IMPLEMENTATION OF THE 
# OPTIMUM STATISTICAL FILTER. FOR A DESCRIPTION SEE E-1973. BOTH OF THESE
# ROUTINES USE STANDARD SYSTEM TEST LEADIN PROCEDURES. THE INITIALIZATION
# PROCEDURE FOR THE DRIFT TESTS IS IN THE JDC'S. THE INITIALIZATION METHOD
# FOR GYROCOMPASS IS AN ERAS LOAD THEN A MISSION PHASE CALL.
# THE COMPASS ALIGNS TO Z DOWN, X DOWNRANGE, HAS THE CAPABILITY (to)
# CHANGE AZIMUTH WHILE RUNNING, IS COMPENSATED FOR
# COMPONENT ERRORS, IS CAPABLE OF OPTICAL VERIFICATION (CSM ONLY).
#
# COMPASS ERASABLE LOAD REQUIRED
#
# 1- LAUNCHAZ -DP AZIMUTH IN REV FROM NORTH OF XSM DESIRED	(NOM=.2)
# 2- LATITUDE -DP-OF LAUNCH PAD
# 3- AZIMUTH-DP-OF ZNB OF VEHICLE
# 4- IMU COMPENSATION PARAMETERS
# 5- AZ AND ELEVATION OF TARGETS 1,2		****OPTIONAL****
#
# TO PERFORM AS PART OF COMPASS
#
# 1-OPTICAL VERIFICATION- V 65 E
# 2-AXIMUTH CHANGE- V 78 E
#
# SUBROUTINES CALLED
#
# DURING OPTICAL VERIFICATION (CSM ONLY) ESSENTIALLY ALL OF INFLIGHT ALIGN
# IS CALLED IN ONE WAY OR ANOTHER. SEE THE LISTING.
#
# NORMAL EXIT
#
# DRIFT TESTS- LENGTHOT GOES TO ZERO-RETURN TO IMU PERF TEST2 CONTROL
# GYROCOMPASS-MANY,SEE THE LISTING
## Page 434
#
# ALARMS
#
# 1600     OVERFLOW IN DRIFT TEST
# 1601     BAD IMU TORQUE ABORT
# 1602     BAD OPTICS DURING VERIFICATION-RETURN TO COMPASS	CSM ONLY
#
# OUTPUT
#
# DRIFT TESTS- FLASHING DISPLAYS OF RESULTS-CONTROLLED IN IMU PERF TESTS 2
# COMPASS-PROGRAM MODE LIGHTS TELL YOU WHAT PHASE OF PROGRAM YOU ARE IN
#    01    INITIALIZING THE PLATFORM POSITION AND ERASABLE
#    02    GYROCOMPASSING
#    03    DOING OPTICAL VERIFICATION (CSM)
#
#
# DEBRIS
#
# ALL CENTRALS,ALL OF EBANK XSM

## Page 435
# MOST OF THE ROUTINES COMMON TO ALIGNMENT AND CALIBRATION APPEAR
# ON THE NEXT FEW PAGES.

		EBANK=	XSM
		SETLOC	IMUCAL
		BANK
		
		COUNT*	$$/P02
ESTIMS		TC	2PHSCHNG	# COMES HERE FROM IMU2
		OCT	00075
		OCT	00004		# TURN OFF GROUP 4 IF ON
5P7SPT1		=	5.7SPOT
RSTGTS1		INHINT			# COMES HERE PHASE1 RESTART
		CA	TIME1
		TS	GTSWTLT1
		CAF	ZERO		# ZERO THE PIPAS
		TS	PIPAX
		TS	PIPAY
		TS	PIPAZ
		RELINT
		CA	77DECML		# ZERO ALL NECESSARY LOCATIONS
		TS	ZERONDX1
		CA	ALXXXZ
		TC	ZEROING
		TC	INTPRET
		SLOAD
			SCHZEROS
		STOVL	GCOMPSW -1
			INTVAL +2	# LOAD SOME INITIAL DRIFT GAINS
		STOVL	ALX1S
			SCHZEROS
		STORE	GCOMP
		STORE	DELVX		# GCOMPZER SUBROUTINE NO LONGER NEEDED
		EXIT
		
		CCS	GEOCOMP1	# NON ZERO IF COMPASS.
		TC	+2
		TC	SLEEPIE	+1
		TC	INTPRET
		CALL
			ERTHRVSE
		EXIT
		CA	LENGTHOT	# TIMES FIVE IS THE NUM OF SEC ERECTING
		TS	ERECTIME

		TC	NEWMODEX
		MM	02
		TC	BANKCALL	# SET UP PIPA FAIL TO CAUSE ISS ALARM
		CADR	PIPUSE		# COMPASS NEVER TURNS THIS OFF
## Page 436
		TC	ANNNNNN		# END OF FIRST TIME THROUGH
## Page 437

# COMES HERE AT THE END OF EVERY ITERATION THROUGH DRIFT TEST OR COMPASS

# SET UP WAITLIST SECTION
SLEEPIE		TS	LENGTHOT	# TEST NOT OVER-DECREMENT LENGTHOT
 +1		TC	PHASCHNG	# CHANGE PHASE
		OCT	00135
5P13SPT1	=	5.13SPOT
		CCS	TORQNDX		# ARE WE DOING VERTDRIFT
		TC	EARTHR*		# TRUE TORQUE SOUTH GYRO
WTLISTNT	TC	CHKCOMED	# SEE IF COMPASS OVER
		TC	SETGWLST
		TC	ENDOFJOB

SETGWLST	EXTEND
		QXCH	MPAC		# CALLED EVERY WAITLIST OR AZIMUTH CHANGE
		INHINT
		CS	TIME1
		AD	GTSWTLT1
		EXTEND
		BZMF	+2
		AD	NEGMAX		# 10 MS ERROR OK
		AD	1SECXT1		# 1 SEC FOR CALIBRATION, .5 SEC IN COMPASS
		EXTEND
		BZMF	RIGHTGTS
WTGTSMPL	TC	TWIDDLE
		ADRES	ALLOOP
		TC	MPAC
RIGHTGTS	CAF	FOUR		# SET UP NEXT WAITLIST-ALLOW SOME TIME
		TC	WTGTSMPL	# END OF WAITLIST SECTION
		
# STORE AND LOAD DATA SECTIONS FOR RESTART PROOFING

25DECML		EQUALS	OCT31
STOREDTA	CAF	25DECML
 +1		TS	MPAC
		INDEX	MPAC
		CAE	THETAX1
		INDEX	MPAC
		TS	RESTARPT
		CCS	MPAC
		TCF	STOREDTA +1
		TC	Q

LOADSTDT	CAF	25DECML
 +1		TS	MPAC
		INDEX	MPAC
		CA	RESTARPT
		INDEX	MPAC
## Page 438
		TS	THETAX1
		CCS	MPAC
		TCF	LOADSTDT +1
		TC	Q
		
# COMES HERE EVERY ITERATION BY A WAITLIST CALL SET IN SLEEPIE
		
ALLOOP		CA	TIME1
		TS	GTSWTLT1	# STORE TIME TO SET UP NEXT WAITLIST.
ALLOOP3		CA	ALTIM
		TS	GEOSAVE1
		TC	PHASCHNG
		OCT	00115
5P11SPT1	=	5.11SPOT
ALLOOP1		CAE	GEOSAVE1
		TS	ALTIM
		CCS	A
		CA	A		# SHOULD NEVER HIT THIS LOCATION
		TS	ALTIMS
		CS	A
		TS	ALTIM
		CAF	ZERO
		XCH	PIPAX
		TS	DELVX
		CAF	ZERO
		XCH	PIPAY
		TS	DELVY
		CAF	ZERO
		XCH	PIPAZ
		TS	DELVZ
		CAF	19DECML		# 23 OCT
		TC	NEWPHASE
		OCT	00005
5P23SPT1	=	5.23SPOT
SPECSTS		CAF	PRIO22
		TC	FINDVAC
		EBANK=	GEOSAVE1
		2CADR	ALFLT		# START THE JOB

		TC	TASKOVER
		
## Page 439
# THIS IS PART OF THE JOB DONE EVERY ITERATION

ALFLT		TC	STOREDTA	# STORE DATA IN CASE OF RESTART IN JOB
		TC	PHASCHNG	# THIS IS THE JOB DONE EVERY ITERATION
		OCT	00215
5P21SPT1	=	5.21SPOT
		TCF	+2
ALFLT1		TC	LOADSTDT	# COMES HERE ON RESTART

		CCS	GEOCOMP1
		TC	+2
		TC	NORMLOP
		TC	CHKCOMED	# SEE IF PRELAUNCH OVER
		TC	BANKCALL	# COMPENSATION IF IN COMPASS
		CADR	1/PIPA

NORMLOP		TC	INTPRET
		DLOAD
			INTVAL
		STOVL	S1
			DELVX
		VXM	VSL1
			XSM
		DLOAD	DCOMP
			MPAC +3
		STODL	DPIPAY
			MPAC +5
		STORE	DPIPAZ

		SETPD	AXT,1
			0
			8D
		SLOAD	DCOMP
			GEOCOMP1
		BMN	
			ALWAYSG		# DO A QUICK COMPASS

## Page 440
# NOW WE HAVE JUST THE CALIBRATION PARTS OF THE PROGRAM-NEXT PAGES

		COUNT*	$$/COMST
ALCGKK		SLOAD	BMN
			ALTIMS
			ALFLT3		# NO NEW GAINS NEEDED
ALKCG		AXT,2	LXA,1		# LOADS SLOPES AND TIME CONSTANTS AT RQST
			12D
			ALX1S
ALKCG2		DLOAD*	INCR,1
			ALFDK +144D,1
		DEC	-2
		STORE	ALDK +10D,2
		TIX,2	SXA,1
			ALKCG2
			ALX1S
	
ALFLT3		AXT,1			# MEASUREMENT INCORPORATION ROUTINES
			8D		# AND GAIN UPDATES
DELMLP		DLOAD*	DMP
			DPIPAY +8D,1
			PIPASC
		SLR	BDSU*
			9D
			INTY +8D,1
		STORE	INTY +8D,1
		PDDL	DMP*
			VELSC
			VLAUN +8D,1
		SL2R
		DSU	STADR
		STORE	DELM +8D,1
		STORE	DELM +10D,1
		TIX,1	AXT,2
			DELMLP
			4
ALILP		DLOAD*	DMPR*
			ALK +4,2
			ALDK +4,2
		STORE	ALK +4,2
		TIX,2	AXT,2
			ALILP
			8D
ALKLP		LXC,1	SXA,1
			CMPX1
			CMPX1
		DLOAD*	DMPR*
			ALK +1,1
			DELM +8D,2
		DAD*
## Page 441
			INTY +8D,2
		STORE	INTY +8D,2
		DLOAD*	DAD*
			ALK +12D,2
			ALDK +12D,2
		STORE	ALK +12D,2
		DMPR*	DAD*
			DELM +8D,2
			INTY +16D,2
		STORE	INTY +16D,2
		DLOAD*	DMP*
			ALSK +1,1
			DELM +8D,2
		SL1R	DAD*
			VLAUN +8D,2
		STORE	VLAUN +8D,2
		TIX,2	AXT,1
			ALKLP
			8D
	
LOOSE		DLOAD*	PDDL*		# EXTRAPOLATE SWAY VARIABLES
			ACCWD +8D,1
			VLAUN +8D,1
		PDDL*	VDEF
			POSNV +8D,1
		MXV	VSL1
			TRANSM1
		DLOAD
			MPAC
		STORE	POSNV +8D,1
		DLOAD
			MPAC +3
		STORE	VLAUN +8D,1
		DLOAD
			MPAC +5
		STORE	ACCWD +8D,1
		TIX,1
			LOOSE
	
		AXT,2	AXT,1		# EVALUATE SINES AND COSINES
			6
			2
BOOP		DLOAD*	DMPR
			ANGX +2,1
			GEORGEJ
		SR2R
		PUSH	SIN
		SL3R	XAD,1
## Page 442
			X1
		STORE	16D,2
		DLOAD
		COS
		STORE	22D,2		# COSINES
		TIX,2
			BOOP	
PERFERAS	EXIT
		TC	E7SETTER
		EBANK=	LAT(SPL)
		TC	LAT(SPL)	# GO TO ERASABLE ONLY TO RETURN

# 	CAUTION
#
# THE ERASABLE PROGRAM THAT DOES THE CALCULATIONS MUST BE LOADED
# BEFORE ANY ATTEMPT IS MADE TO RUN THE IMU PERFORMANCE TEST

		EBANK=	LENGTHOT
ONCEMORE	CCS	LENGTHOT
		TC	SLEEPIE		# TEST NOT OVER SET UP NEXT WAITLIST

		CCS	TORQNDX
		TCF	+2
		TC	SETUPER1
		CA	CDUX
		TS	LOSVEC +1	# FOR TROUBLESHOOTING POSNS 2$4 VD
SETUPER1	TC	INTPRET		# DRIFT TEST OVER
		DLOAD	PDDL		# ANGLES FROM DRIFT TEST ONLY
			ANGZ
			ANGY
		PDDL	VDEF
			ANGX
		VCOMP	VXSC
			GEORGEJ
		MXV	VSR1
			XSM
		STORE	OGC
		EXIT

TORQINCH	TC	PHASCHNG
		OCT	00005		
		CA	OGCPL
		TC	BANKCALL
		CADR	IMUPULSE
		TC	IMUSTLLG
		CCS	TORQNDX		# + IF IN VERTICAL DRIFT TEST
		TC	VALMIS		# VERT DRIFT TEST OVER
		TC	INTPRET
		CALL			# SET UP ERATE FOR PIP TEST OR COMPASS
			ERTHRVSE
## Page 443
		EXIT
		TC	TORQUE		# GO TO IMU2 FOR A PIPA TEST AND DISPLAY


SOMEERRR	TC	ALARM
		OCT	1600
		TC	+3
SOMERR2		TC	ALARM
		OCT	1601		
		TC	PHASCHNG
		OCT	00005
		TC	ENDTEST1


# THE FAMOUS MAGIC NUMBERS OF SCHMIDT ARE NOW PART OF AN ERASABLE LOAD		

		
SCHZEROS	2DEC	.00000000
		2DEC	.00000000
		OCT	00000
ONEDPP		OCT	00000
 +1		OCT	00001		# ABOVE ORDER IS IMPORTANT
		
INTVAL		OCT	4
		OCT	2
		DEC	144
		DEC	-1
SOUPLY		2DEC	.93505870	# INITIAL GAINS FOR PIP OUTPUTS
		2DEC	.26266423	# INITIAL GAINS/4 FOR ERECTION ANGLES


77DECML		DEC	77
ALXXXZ		GENADR	ALX1S -1

# GYROCOMPASS PORTIONS FINISH THIS LOG SECTION

		COUNT*	$$/P01

# INITIALIZATION SECTION

GTSCPSS		CA	FLAGWRD1	# CALLED BY V37
		MASK	NOP01BIT
		EXTEND
		BZF	GTSCPSSA
		TC	POODOO
		OCT	21521		# NO DO ALARM FOR P01 - P11 ALREADY DONE
## Page 444
GTSCPSSA	CAF	PRIO20		# INITIAL PRIORITY ONLY 13
		TC	PRIOCHNG	# CHANGE TO 20

		CAF	ONE
		TS	GEOCOMP1	# THIS IS THE LEAD IN FOR COMPASS.
		CA	1/PIPAGT
		TS	1/PIPADT
NXXTBNN		CA	BIT8
		TS	LENGTHOT
		CAF	1/2SECX		# COMPASS IS A .5 SEC LOOP
		TS	1SECXT1
		CAF	ONE
		TS	PREMTRX1
		TS	PERFDLAY +1
		CAF	ZERO
		TS	PERFDLAY
		EXTEND
		DCA	LUNCHAZ1
		DXCH	NEWAZ1
		EXTEND
		DCA	LUNCHAZ1
		DXCH	OLDAZMTH
SETUPGC		CA	DEC17
		TS	ZERONDX1
		CA	XSMADR
		TC	ZEROING
		TC	POSN17C
		TC	GEOIMUTT	# GO TO IMU2 FOR FURTHER INITIALIZATION


POSN17C		EXTEND			# COMPASS POSITION Z DOWN,X DOWNRANGE
		QXCH	QPLACE		# FROM NORTH IN REVOLUTIONS + CLOCKWISE
		CS	HALF		# ALL THIS TO INITIALIZE MATRIX
		TS	ZSM
		TC	INTPRET
		DLOAD	PUSH
			NEWAZ1
		SIN
		STORE	XSM +4
		STODL	YSM +2
		COS
		STORE	YSM +4
		DCOMP
		STORE	XSM +2
		EXIT
		TC	QPLACE

# JOB DONE EVERY ITERATION THROUGH COMPASS PROGRAM. SET BY TASK ALLOOP

## Page 445
		COUNT*	$$/P02
ALWAYSG		DLOAD*	DSU*		# COMPASS AND ERECT
			DPIPAY +8D,1
			FILDELV1 +8D,1
		DMPR	DAD*
			GEOCONS1
			FILDELV1 +8D,1
		STORE	FILDELV1 +8D,1
		DAD*
			INTVEC1 +8D,1
		STORE	INTVEC1 +8D,1
		DMPR	DAD*
			GEOCONS2
			FILDELV1 +8D,1
		DMPR	PUSH
			GEOCONS5
		TIX,1	SLOAD
			ALWAYSG
			ERECTIM1
		BZE	DLOAD
			COMPGS
			THETAN1 +2
		DSU	STADR
		STODL	THETAN1 +2	# ERECTION ONLY.
		BDSU
			THETAN1 +4
		STORE	THETAN1 +4
		GOTO
			ADDINDRF
COMPGS		DLOAD	DAD		# COMPASS
			THETAN1
			FILDELV1
		STODL	THETAN1
			FILDELV1
		DMPR	BDSU
			GEOCONS3
			THETAN1 +4
		STODL	THETAN1 +4
			FILDELV1 +4
		DMPR	BDSU
			GEOCONS3
			THETAN1 +2
		PDDL	DMPR
			INTVEC1 +4
			GEOCONS4
		BDSU	STADR
		STORE	THETAN1 +2
ADDINDRF	EXIT

## Page 446

ENDGTSAL	CCS	LENGTHOT	# IS 5 SEC OVER-THE TIME TO TORQ PLATFORM
		TC	SLEEPIE		# NO-SET UP NEXT WAITLIST CALL FOR .5 SEC
		TC	CHKCOMED
		CCS	LGYRO		# YES BUT ARE GYROS BUSY
		TCF	SLEEPIE +1	# BUSY-GET THEM .5 SECONDS FROM NOW

LASTGTS		TC	INTPRET
		VLOAD
			ERCOMP1
		STODL	THETAX1
			TMARK
		STORE	ALK
		EXIT			# PREVIOUS SECTION WAS FOR RESTARTS

RESTAIER	TC	PHASCHNG
		OCT	00275
5P27SPT1	=	5.27SPOT
		TC	INTPRET		# ADD COMPASS COMMANDS INTO ERATE
		VLOAD	MXV
			THETAN1
			XSM
		VSL1	VAD
			THETAX1
		STODL	ERCOMP1
			ALK
		STORE	TMARK
		EXIT
		TC	EARTHR*		# TORQUE IT ALL IN
		CAE	ERECTIM1
		TS	GEOSAVE1
		TC	PHASCHNG
		OCT	00155
5P15SPT1	=	5.15SPOT
RESTEST1	TC	INTPRET
		VLOAD
			SCHZEROS
		STORE	THETAN1
		EXIT
		CCS	PREMTRXC
		TC	NOCHORLD
		TC	PHASCHNG
		OCT	00255
5P25SPT1	=	5.25SPOT
RESTEST3	TC	INTPRET
		DLOAD
			LAUNCHAZ
		DSU	BZE
			OLDAZMTH
			NOAZCHGE
		STORE	0D
## Page 447
		SLOAD	DAD
			ONEDPP +1
			PREMTRXC	# DOES NOT CHANGE LAUNCHAZ
		STODL	PREMTRXC
			LAUNCHAZ
		STODL	NEWAZMTH
			0D
ADERCOMP	STORE	ERCOMP +4
		EXIT
		TC	POSN17C
		TC	PHASCHNG
		OCT	00335
5P33SPT1	=	5.33SPOT
RESCHNG		EXTEND
		DCA	NEWAZMTH
		DXCH	OLDAZMTH
		CA	BIT7		# SPEND 320 SEC ERECTING
		TS	LENGTHOT
		TC	PHASCHNG
		OCT	00075
5P7SPT2		=	5.7SPOT
SPITGYRO	CA	ERCOMPPL
		TC	BANKCALL
		CADR	IMUPULSE
		TC	BANKCALL
		CADR	IMUSTALL
		TC	SOMERR2
		TC	ESTIMS		# RE-INITIALIZE


NOAZCHGE	EXIT
		CA	ONE
		TS	PREMTRXC
NOCHORLD	CCS	GEOSAVE1
		TS	ERECTIM1	# COUNTS DOWN FOR ERECTION.

ANNNNNN		CAF	NINE
		TS	LENGTHOT
		TC	SLEEPIE +1


CHKCOMED	INHINT
		CS 	MODREG		# CHECK FOR MM 07 FIRST
		AD 	SEVEN
		EXTEND
		BZF 	GOBKCALB	# IF MM 07 RETURN TO PERF TEST
		CS	ZERO
		EXTEND
		RXOR	CHAN30		# READ AND INVERT BITS IN CHANNEL 30
		MASK	BIT5		# LIFTOFF BIT
## Page 448
		CCS	A
		TCF	PRELTERM	# LIFTOFF HAS OCCURRED

		CA	GRRBKBIT	# CHECK FOR BACKUP LIFTOFF
		MASK	FLAGWRD5	# BIT5 FLAGWRD5
		CCS	A
		TCF	PRELTERM	# BACKUP RECEIVED

		RELINT
GOBKCALB	TC	Q

PRELTERM	CA	PRIO22		# PRELAUNCH DONE - SET UP P11
		TC	PRIOCHNG	# INCREASE PRIORITY HIGHER THAN SERVICER
		INHINT
		TC	POSTJUMP
		CADR	P11


ERCOMPPL	ECADR	ERCOMP

GEOCONS5	EQUALS	HIDPHALF
1/PIPAGT	OCT	06200
17DECML		=	ND1		# OCT 21
19DECML		=	VD1		# OCT 23
1/2SECX		=	.5SEC

## Page 449
# OPTICAL VERIFICATION ROUTINES FOR GYROCOMPASS

		COUNT*	$$/P03
GCOMPVER	TC	PHASCHNG	# OPTICAL VERIFICATION ROUTINE
		OCT	00154
4P15SPT1	=	4.15SPOT
		TC	NEWMODEX	# ENTERED BY VERB 65 ENTER
		MM	03
SETNBPOS	TC	NBPOSPL
 +1		TC	BANKCALL
		CADR	MKRELEAS
OPTDATA		CAF	BIT1		# CALLS FOR AZIMUTH AND ELEVATION OF TARGE
		ZL			# T 1, THEN TARGET 2
 +2		LXCH	RUN
		TS	DSPTEM1 +2	# ELEVATION MEASURED FROM HORIZONTAL
		EXTEND
		INDEX	RUN
		DCA	TAZEL1
		DXCH	DSPTEM1
OPTDATA8	CAF	V05N30E
		TC	BANKCALL
		CADR	GODSPRET
		CAF	V06N41
		TC	BANKCALL
		CADR	GOFLASH
		TC	GCOMP5
		TC	+2
		TCF	OPTDATA8

		DXCH	DSPTEM1		# TAZEL1  TARGET 1 AZIMUTH
		INDEX	RUN
		DXCH	TAZEL1		# TAZEL1 +2 TARGET 2 AZIMUTH
		CCS	RUN
		TCF	CONTIN33
		CAF	TWO
		TS	L
		TCF	OPTDATA +2	# MPAC    1ST PASS=0  2ND PASS=2

V05N30E		VN	0530

		TC	INTPRET		# UNDYNAMIC ASSEMBLER
TAR/EREF	AXT,1	AXT,2		# TARGET VECTOR
			2		# SIN(EL)  -COS(AZ)COS(EL)   SIN(AZ)COS(EL)
			12D
		SSP	SETPD
			S2
			6
			0
TAR1		SLOAD*	SR2		# X1=2 X2=12 S2=6 X1=0 X2=6 S2=6
## Page 450
			TAZEL1 +3,1	
		STORE	0		# PD00    ELEVATION    PD00
		SIN
		STORE	18D,2		# PD06 ***    SIN(EL)   ***PD12
		DLOAD
			0
		COS	PUSH		# PD00     COS(EL)   PD00
		SLOAD*	RTB
			TAZEL1 +2,1
			CDULOGIC
		STORE	2		# PD02        AZIMUTH   PD02
		SIN	DMP
			0
		SL1
		STORE	22D,2		# PD10  *** SIN(AZ)COS(EL)  ***PD16
		DLOAD	COS
			2
		DMP	SL1
		DCOMP	AXT,1
			0
		STORE	20D,2		# PD08 ***   -COS(AZ)COS(EL)  ***PD14
		TIX,2	RVQ
			TAR1


		SETLOC	IMUCAL
		BANK
		COUNT*	$$/P03
CONTIN33	CA	ONE
		TS	STARCODE
		CA	ZERO
		TC	TARGDRVE
		TC	INTPRET
		CALL
			TAR/EREF
NEXTBNKS	VLOAD	MXV
			6D
			XSM
		VSL1	
		STOVL	STARAD
			12D
		MXV	VSL1
			XSM
		STCALL	STARAD +6
			LITTLSUB
		STORE	LOSVEC
		EXIT
NEXBNKSS	CAF	TWO
		TS	STARCODE
		CAF	SIX
## Page 451
		TC	TARGDRVE
		TC	INTPRET
		CALL
			LITTLSUB
		STOVL	12D
			LOSVEC
		STCALL	06D
			AXISGEN
		CALL
			CALCGTA
		EXIT
GCOMP4		CAF	V06N93
		TC	BANKCALL
		CADR	GOFLASH
		TC	GCOMP5
		TCF	+2
		TCF	GCOMP4
		TC	INTPRET
		VLOAD	VAD
			OGC
			ERCOMP1
		STORE	ERCOMP1
		EXIT
GCOMP5		TC	NEWMODEX
		MM	02
		TC	PHASCHNG
		OCT	00004
		TC	ENDOFJOB
		SETLOC	IMUCAL
		BANK


		COUNT*	$$/P03
TARGDRVE	EXTEND
		QXCH	QPLAC
		TS	TARG1/2
		TC	INTPRET
		CALL
			TAR/EREF
		LXC,1	VLOAD*
			TARG1/2
			6D,1
		STCALL	STAR
			SXTANG
		EXIT
		CA	SAC
		TS	DESOPTS
		CA	PAC
		TS	DESOPTT
RETARG		CAF	ZERO
## Page 452
		TS	OPTIND
		TC	BANKCALL
		CADR	SXTMARK
		CCS	MARKINDX
		TC	RETARG		# NO MARK TAKEN	- DO AGAIN

		TC	BANKCALL
		CADR	MKRELEAS

		TC	QPLAC


		SETLOC	IMUCAL
		BANK
		COUNT*	$$/P03
PIPASC		2DEC	.76376833
VELSC		2DEC	-.52223476
ALSK		2DEC	.17329931
		2DEC	-.00835370
GEORGEJ		2DEC	.63661977
GEOCONS1	2DEC	.1
GEOCONS2	2DEC	.005
GEOCONS3	2DEC	.062
GEOCONS4	2DEC	.0003

		COUNT*	$$/P02
LITTLSUB	STQ	AXC,1
			QMAJ
			MRKBUF1
		GOTO
			SXTSM2


		SETLOC	EXTVERBS
		BANK

		COUNT*	$$/EXTVB
AZMTHCG1	TC	INTPRET
		DLOAD	RTB
			NEWAZMTH
			1STO2S
		EXIT
## Page 453
		XCH	MPAC
		TS	DSPTEM1
		TC	BANKCALL
		CADR	CLEANDSP
		CAF	VN0629
		TC	BANKCALL
		CADR	GOFLASH
		TCF	+11
		TCF	+2
		TCF	-5
		TC	INTPRET
		SLOAD	RTB
			DSPTEM1
			CDULOGIC
		STORE	LAUNCHAZ
		EXIT
 +11		CAF	ZERO
		TS	PREMTRXC
		TC	PHASCHNG
		OCT	00004
		TC	POSTJUMP
		CADR	PINBRNCH

VN0629		VN	0629

## Page 454
# *** END OF DIOGENES.064 ***

