### FILE="Main.annotation"
# Copyright:	Public domain.
# Filename:	PRELAUNCH_ALIGNMENT_PROGRAM.agc
# Purpose:	Part of the source code for Solarium build 55. This
#		is for the Command Module's (CM) Apollo Guidance
#		Computer (AGC), for Apollo 6.
# Assembler:	yaYUL --block1
# Contact:	Jim Lawton <jim DOT lawton AT gmail DOT com>
# Website:	www.ibiblio.org/apollo/index.html
## Page scans:	www.ibiblio.org/apollo/ScansForConversion/Solarium055/
# Mod history:	2009-10-05 JL	Created.
#		2009-10-30 JL	Fixed filename comment.
#		2016-08-20 RSB	Resolved Jim's uncertainty about TP.
#		2016-08-23 RSB	Typos.

## Page 332

# THE PRELAUNCH ALIGNMENT PROGRAM CONSISTS OF TWO PARTS- VERTICAL ERECTION AND GYROCOMPASSING. IN THE FIRST CASE
# THE Z PIPA INPUTS ARE USED TO CONTROL THE Y GYRO IN SUCH A WAY THAT THESE INPUTS ARE NULLED. A SIMILAR SIT-
# UATION APPLIES TO THE Y PIPA INPUTS AND THE Z GYRO.IN THE GYROCOMPASSING CASE, THE Y PIPA INPUTS ARE USED IN
# EXACTLY THE SAME FASHION AS IN VERTICAL ERECTION. THE Z PIPA INPUTS ARE SPLIT BETWEEN THE Y GYRO TO HOLD THE
# VERTICAL AND THE X GYRO TO POINT THE Z AXIS ALONG SOME DESIRED AZIMUTH. 



# WHILE PRELAUNCH IS ACTIVE IT STAYS IN THE EXECUTIVE AND USES THE SLEEP/WAKE FEATURES. BY THIS MEANS MOST
# ERASABLE USAGE IS CONFINED TO A VAC AREA. THE ASSIGNMENT IS AS FOLLOWS-
 
SINLAM		=	34D		# SIN OF LATITUDE
COSLAM		=	36D		# COSINE OF LATITUDE
SINAZ		=	2		# SIN OF AZIMUTH
COSAZ		=	4		# COSINE OF AZIMUTH
		SETLOC	42000
		
TOP1		TC	INTPRET

		DMOVE	1		# THIS START DISPLAYS ALL INPUTS FOR CHEK
		RTB	EXIT
			AZIMUTH
			1STO2S
		
		TC	GRABDSP
		TC	PREGBSY
		
		XCH	MPAC
		TS	DSPTEM1
		CAF	ZERO
		TS	DSPTEM1 +1
		
		TC	CHECKNV		# DISPLAY AZIMUTH
		OCT	00661		# (N.B. CAN NOT BE MODIFIED    ...ALK)
		
		TC	PRELEXIT -1
		
		TC	INTPRET
		
		TSLT	0
			LATITUDE
			2
		STORE	DSPTEM1 +1
		
		DMOVE	1
		RTB	EXIT
			VAZ
			1STO2S
		
		XCH	MPAC
## Page 333
		TS	DSPTEM1
		
		TC	CHECKNV		# DISPLAY VEHICLE AZIMUTH, LATITUDE
		OCT	00661		# (SEE N.B. ABOVE)
		
		TC	PRELEXIT -1
		
		TC	FREEDSP		# DONE WITH DSKY.
		
		TC	INTPRET
		
TOP3		DMOVE	1		# COMPUTES GIMBAL ANGLES
		RTB	AXT,1
			SCNBMAT +8D
			ZEROVAC
			18D
		STORE	0
		
		COS	0
			VAZ
		STORE	8D
		
		NOLOD	0
		STORE	16D
		
		SIN	0
			VAZ
		STORE	14D
		
		NOLOD	1
		COMP	AST,1
			6
		STORE	10D
		
TOP33		VMOVE*	1
		VXM	VSLT
			SCNBMAT +18D,1
			0
			1
		STORE	XNB +18D,1
		
		TIX,1	0
			TOP33
		
		ITC	0
			MAKEXSM
		
		ITC	0
			CALCGA
## Page 334
		NOLOD	1
		TP
		STORE	PRELXGA
		
		EXIT	0
		
# ENTER AT TOP2 IF GIMBAL ANGLES, AZIMUTH, LATITUDE ALREADY KEYED IN



TOP2		TC	BANKCALL	# GO AND START CDU ZEROING
		CADR	IMUZERO
		
		TC	NEWMODE
		OCT	01		# INITIALIZATION.
		
		CAF	NINETEEN	# INITIALIZE ERASABLE MEMORY TO ZEROS
ZEROS1		XCH	THETAY
		CAF	ZERO
		INDEX	THETAY
		TS	FILTER
		CCS	THETAY
		TC	ZEROS1
		
		CAF	ELEVEN
ZEROS2		XCH	THETAY
		CAF	ZERO
		INDEX	THETAY
		TS	THETAY
		CCS	THETAY
		TC	ZEROS2
		
		CAF	SIXHNDRD	# INITIALIZE FOR 5 MIN VERTICAL
		TS	GYROCSW
		
		TC	BANKCALL	# INITIALIZATION COMPLETE SO STALL
		CADR	IMUSTALL
		TC	PRELEXIT



		CS	PRELXGA		# LOAD DESIRED CDU ANGLES.
		COM
		TS	THETAD
		CS	PRELYGA
		COM
		TS	THETAD +1
		CS	PRELZGA
		COM
		TS	THETAD +2
## Page 335
		TC	PHASCHNG	# GO INTO COARSE ALIGN PHASE.
		OCT	02103		# 3.17 RESTART.
		
REPL11		TC	BANKCALL
		CADR	IMUCOARS
		
		TC	BANKCALL	# NOTHING TO DO BUT SPEEP
		CADR	IMUSTALL
		TC	PRELEXIT



STARTPL2	TC	PHASCHNG	# START FINE ALIGN - INITIALIZATION PHASE.
		OCT	02203		# 3.18 RESTART.
		
REPL12		TC	BANKCALL
		CADR	IMUFINE
		
		TC	READTIME
		CS	RUPTSTOR
		TS	PREVTIME
		CS	RUPTSTOR +1
		TS	PREVTIME +1
		RELINT
		
		TC	BANKCALL	# SLEEP
		CADR	IMUSTALL
		TC	PRELEXIT



		TC	NEWMODE		# SET MAJOR MODE TO VERTICAL ERECTION
		OCT	5		# (COUNTING)
		
		CAF	ZERO
		TS	INFLANG
		TS	INFLANG +1
		TS	INFLANG +2
		TS	INFLANG +3
		TS	INFLANG +4
		TS	INFLANG +5
		TS	PIPAY		# SET ALL PIPAS TO ZERO
		TS	PIPAZ
		TS	PIPAX
		
		CAF	NINE
		TS	PRELTEMP
		
		CAF	PLPIPADT	# SET UP DELTA TIME FOR IMU COMPENSATION.
		TS	1/PIPADT
## Page 336
		INHINT
		CAF	PRELDT		# SET WAITLIST TO WAKE UP JOB
		TC	WAITLIST
		CADR	PRELALTS
		
		TC	ENDOFJOB
		
## Page 337

#	PRELAUNCH WAITLIST TASK - EXECUTED EVERY .5 SEC. IN LOOP.

PRELALTS	CAF	PIPCAD21
		TC	ISWCALL
		
		CAF	TWENTY0
		TC	NEWPHASE
		OCT	3
		
REDO3.20	CS	TIME1
		TS	TBASE3
		
		CAF	TWO
		TS	PIPAGE
		
		XCH	IN2		# TEST IN2 FOR GRR OR LIFT-OFF
		XCH	IN2
		MASK	BITS56
		CCS	A
		TC	PRELTERM
		
		CAF	BIT2		# CHECK IF LIFT-OFF HAS OCCURRED
		MASK	FLAGWRD1
		CCS	A
		TC	PRELTERM	# IT HAS. TERMINATE PRELAUNCH
		
		CAF	PRELDT		# SELF-SUSTAINING WAITLIST CALL
		TC	WAITLIST
		CADR	PRELALTS
		
NOPLWAIT	CAF	PRIO20
		TC	FINDVAC
		CADR	PRAWAKE
		
		TC	TASKOVER	# RESUME
		
PRELTERM	CS	RUPTSTOR +1	# N.B. READTIME IS DONE IN PIPASR ABOVE
		TS	TIME1GR
		CS	RUPTSTOR
		TS	TIME2GR
		
		CS	TIME1GR
		TS	TBASE5
		
		CAF	ONE
		TC	NEWPHASE
		OCT	00005
		
		CCS	A
		TC	NOPLWAIT
## Page 338
		TC	+1
		
		CAF	2SEC21		# CALL READACCS IN 2 SECS
		TC	WAITLIST
		CADR	READACCS
		
		TC	NOPLWAIT
		
REPRELAL	CAF	REPIP21
		TC	PRELALTS +1
		
PIPCAD21	CADR	PIPASR
REPIP21		CADR	REPIPASR

## Page 339

REDO3.21	TC	PRLRSTOR
		TC	RE3.21
		
PRAWAKE		TC	PRLSAVE

		CCS	PHASE5		# CHECK IF GRR HAS OCCURED.
		CAF	NINETEEN	# 3.19 RESTART.
		TC	+2
		CAF	TWENTY1		# 3.21 RESTART.
		TC	NEWPHASE
		OCT	3
		
		TC	BANKCALL
		CADR	1/PIPA
		
RE3.21		TC	INTPRET
		
		SMOVE	0		# ZERO TO THEAT-SOUTH
			ZEROPR
		STORE	THETASTH
		
		NOLOD	0
		STORE	THETAE		# ZERO TO THETA EAST
		
		RTB	1
		SIN
			ZEROVAC
			LATITUDE
		STORE	SINLAM
		
		COS	0
			LATITUDE
		STORE	COSLAM
		
		SMOVE	1
		DSU
			90DEGAZ
			AZIMUTH
		
		SIN	0
			0
		STORE	SINAZ
		
		COS	0
		STORE	COSAZ
		
		EXIT	0
		
		CCS	PHASE5		# CHECK IF GRR HAS OCCURRED
		TC	PRELTER1
## Page 340
		TC	+1
		
		TC	CHECKMM		# CHECK IF VERTICAL ERECTION (UNCONDIT.)
		OCT	5
		TC	+2
		TC	NOGYROCM
		
		TC	CHECKMM		# CHECK IF VERTICAL ERECTION (UNCONDIT.)
		OCT	6
		TC	+2
		TC	TJL
		
DOGYROC		TC	CHECKMM		# CHECK IF OPTICAL VERIFICATION
		OCT	3
		TC	DOGYROC1
		
JSTERTHR	TC	INTPRET

		ITC	0
			EARTHRR

DOGYROC1	TC	NEWMODE
		OCT	2
		
DOGYROC2	TC	INTPRET
		
		ITC	0
			GYROCOM
		
EARTHRR		ITC	0
			EARTHRAT
		
ENDOFPR		DMOVE	0
			PIPTIME
		STORE	PREVTIME
		
		EXIT	0
		
		CCS	PRELTEMP
		TC	JUMPY
		
		CCS	LGYRO		# IF BUSY GO AROUND LOOP AGAIN
		TC	JUMPY +1	# WAIT TIL NEXT TIME.  PRELTEM = 0 STILL.
		
PTORQUE		CAF	ZERO		# INITIALIZE TORQUING REGISTERS AND RESET
		XCH	THETAX
		AD	INFLANG +1
		TS	GYROANG +1
		CAF	ZERO
		AD	INFLANG
## Page 341
		TS	GYROANG



		CAF	ZERO
		XCH	THETAY
		AD	INFLANG +3
		TS	GYROANG +3
		CAF	ZERO
		AD	INFLANG +2
		TS	GYROANG +2
		
		CAF	ZERO
		XCH	THETAZ
		AD	INFLANG +5
		TS	GYROANG +5
		CAF	ZERO
		AD	INFLANG +4
		TS	GYROANG +4
		
		CAF	ZERO
		TS	INFLANG
		TS	INFLANG +1
		TS	INFLANG +2
		TS	INFLANG +3
		TS	INFLANG +4
		TS	INFLANG +5
		
		CAF	NINE
		TS	PRELTEMP
		
		TC	PHASCHNG
		OCT	02603
		
		INHINT
		CAF	PRIO27
		TC	NOVAC
		CADR	SPITGYRO
		TC	ENDOFJOB
		
JUMPY		TS	PRELTEMP

		TC	PHASCHNG
		OCT	02603
		
		TC	ENDOFJOB



SPITGYRO	CAF	LGYROANG
## Page 342
		TC	BANKCALL
		CADR	GYRODPNT
		
		TC	BANKCALL
		CADR	IMUSTALL
		TC	ENDOFJOB
		TC	ENDOFJOB
		
## Page 343

#	VERTICAL ERECTION PROCEDURES.

NOGYROCM	CCS	GYROCSW		# COUNT DOWN FOR 5 MIN OF VERTICAL ERECT.
		TC	MORE		#  IF MORE TO COME.
		TC	NEWMODE		# IF NOT, GO INTO GYROCOMP. (MM 02)
		OCT	2
		
		TC	+2
		
MORE		TS	GYROCSW

TJL		TC	INTPRET

		ITC	0
			EARTHRAT
		
		DSU	1
		DMP	DAD
			DELVY
			FILDELY
			VERECTC3
			FILDELY
		STORE	FILDELY
		
		AXC,1	1
		AXC,2	ITC
			2
			0
			VERECT
		
		DSU	1
		DMP	DAD
			DELVZ
			FILDELZ
			VERECTC3
			FILDELZ
		STORE	FILDELZ
		
		AXC,1	2
		NOLOD	COMP
		ITC
			0
			VERECT
		
		ITC	0
			ENDOFPR

## Page 344

#	CALCULATION OF EARTH RATE

EARTHRAT	DSU	1
		TSLT	DMPR
			PIPTIME
			PREVTIME
			11D
			GOMEGA
		
		DMP	1		#  SIN(LAMBDE).DT.LENGTH OMEGA + THETA X
		TSLT	DAD
			0
			SINLAM
			1
			THETAX
		STORE	THETAX
		
		DMP	1		# -COS(LAMBDA).DT.LENGTH OMEGA + THETA STH
		TSLT	BDSU
			-
			COSLAM
			1
			THETASTH
		STORE	THETASTH
		
		DMP	1		#  COS(AZIMUTH). SOUTH COMPONENT
		TSLT
			THETASTH	# 			TO P.D. LIST
			COSAZ
			1
		
		DMP	2		#  Y COMPONENT = SIN(AZIMUTH).EAST COMP
		TSLT	DAD		# 		   + COS(AZIMUTH). SOUTH
		DAD
			THETAE		# 				    COMP
			SINAZ
			1
			THETAY
		STORE	THETAY
		
		DMP	1		#  SIN(AZIMUTH). SOUTH COMPONENT
		TSLT
			SINAZ		# 			TO P.D. LIST
			THETASTH
			
			1
		DMP	2		# Z COMPONENT = COS(AZIMUTH.EAST COMP)
		TSLT	DSU
		DAD
			COSAZ		# 	       -SIN(AZIMUTH).SOUTH COMP
## Page 345
			THETAE
			1
			-
			THETAZ
		STORE	THETAZ
		
		ITCQ	0
		
## Page 346

#	COMPUTATION OF GYROCOMPASS COMMAND

GYROCOM		ITA	1
		DMP	TSLT
			S2
			DELVZ
			COSAZ
			1
			
		DMP	1		# DELTA-V(EAST)= COS(AZ).DELTA-V(Z)
		TSLT	DAD
			DELVY
			SINAZ
			1
		STORE	DELE
		
		AXC,1	2
		AXC,2	NOLOD
		COMP	ITC
			6
			2
			VERECT

		DMP	1		# SIN(AZ).DELTA-V(Z)
		TSLT
			DELVZ
			SINAZ
			1

		DMP	1		# DELTA-V(SOUTH= COS(AZ.DELTA-V(Y)
		TSLT	DSU
			DELVY
			COSAZ
			1
		STORE	DELS
		
		DMP	0
			DELS		#  C1. DELTA-V(SOUTH) TO P.D. LIST
			GYRCMC1
		
		DMP	1		# FILTER = C1. DELTA-V(SOUTH)
		DAD			#         +C2. FILTER
			FILTER
			GYRCMC2
		STORE	FILTER
		
		NOLOD	2
		DMP	TSLT
		DAD
			GYRCMC3
## Page 347
			7
			THETAX
		STORE	THETAX
		
		DMP	1		# EAST-TORQUING ANGLE = C4.FILTER
		TSLT
			DELS
			GYRCMC4
			3
		STORE	THETAE
		
		ITCI	0
			S2

## page 348

# VERTICAL ERECTION SUBROUTINE
#
# VERECT - VERTICAL ERECTION      ENTERED IN INT. MODE WITH
#		    SUBROUTINE            C(X1)= 2 FOR C(MPAC)= DEL-V Y
#		                               = 0     C(MPAC)=-DEL-V Z
#		                               = 6 FOR C(MPAC)=-DEL-V E
#				   FOR THESE THREE CASES OUTPUT WILL BE
#						THETA-Z
#						THETA-Y
#						THETA-S RESPECTIVELY.
#				   LOOP CONSTANTS ARE DETERMINED BY
#					  C(X2)= 0 NO GYROCOMPASSING
#					         2    GYROCOMPASSING



VERECT		NOLOD	0
		
		STORE	0
		
		NOLOD	1
		DAD*
			INT,1		# COMPUTE INTEGRAL OF DEL-V = INT
		STORE	INT,1
		
		DMOVE	1
		DMP*	TSLT
			0
			VERECTC1,2
			5
		
		DMP*	1
		DAD*	DAD
			INT,1		# THETA = THETA + C1 DEL-V  + C2 INT
			VERECTC2,2
			THETAY,1
		STORE	THETAY,1
		
		ITCQ	0
		
## Page 349

#	PRELAUNCH MANUAL REQUEST PROCESSOR.

STARTPL		CAF	PRIO20		# ENTER EXECUTIVE REQUEST ON START-UP.
		TC	FINDVAC
		CADR	STARTPL2
		TC	SWRETURN
		
PLSTCHK		CS	EIGHT		# PRELAUNCH COMES HERE WHENEVER A PHASE
		AD	MPAC		# REFERENCE IS MADE TO SEE IF A MANUAL
		CCS	A		# REQUEST HAS BEEN ENTERED THROUGH MASTER
		TC	Q		# CONTROL. ALL SUCH PHASES ARE LESS THAN 8
PLPRIO		OCT	24000
		TC	+1
		
		INDEX	MPAC		# SEE WHICH MANUAL MODE REQUESTED.
		TC	+0
		TC	TOP1		# 1 - INITIALIZATION 1.
		TC	TOP2		# 2 - INITIALIZATION 2.
		TC	OPTCHK		# 3 - DO OPTICAL CHECK
		
PLFINCHK	CCS	WASKSET		# SEE IF IN FINE ALIGN.
		TC	3CHECK
		TC	PRELEXIT	# SYSTEM IN BAD SHAPE.
		TC	DOPLCHNG	# DO THE CHANGE ANYWAY.
		TC	PRELEXIT	# SYSTEM IN BAD SHAPE.
		
3CHECK		AD	-CCSFINE
		CCS	A
		TC	TOP1
-CCSFINE	OCT	-47		# WASKSET IS 50 FOR FINE ALIGN.
		TC	TOP1
		
DOPLCHNG	INDEX	MPAC
		TC	-2
		TC	DOPL14
		
DOPL15		TC	NEWMODE		# SET MAJOR MODE TO GYROCOMPASSING
		OCT	2
		
		TC	DOGYROC
		
DOPL14		TC	NEWMODE		# SET MAJOR MODE TO UNCONDITIONAL VERT-
		OCT	6		# ICAL ERECTION
		
		TC	TJL

## Page 350

#	PRELAUNCH GO-SEQUENCE PROCESSOR.
#
#	  HAS BEEN DELETED.  SEE GENERAL RESTARTS.   ...DJL

FINECODE	OCT	50		# FINE ALIGN AND COMPUTER CONTROL.

#	PRELAUNCH TERMINATION.

		TC	FREEDSP
PRELEXIT	TC	BANKCALL
		CADR	IMUFINIS
		
ENDJ3OUT	CS	ONE
		TC	NEWPHASE
		OCT	3
		
		TC	ENDOFJOB
		
## Page 351

# PRELAUNCH BANK STORED CONSTANTS

VERECTC1	2DEC	20. B-5		# VERTICAL LOOP CONSTANTS
		2DEC	2 B-5
VERECTC2	2DEC	.4
		2DEC	.004
VERECTC3	2DEC	.1
GYRCMC1		2DEC	0.1
GYRCMC2		2DEC	0.9
GYRCMC3		2DEC	-68 B-7
GYRCMC4		2DEC	4 B-3
LABLAT		2DEC	.117678252	# LATITUDE OF IL-7
90DEGAZ		2DEC	.25		# 90 DEG. FROM NORTH = EAST
PRELDT		DEC	.5 E2		# HALF SECOND PRELAUNCH CYCLE

WAKEPRAD	CADR	PRAWAKE		# WAKING ADDRESS FOR PRELAUNCH

ZEROPR		OCT	0		# OUR OWN PERSONAL COPY OF ZERO

LOMEGA		2DEC	.12169524	# EARTH RATE IN IRIG PULSES PER .01 SEC.
GOMEGA		2DEC	0.97356192	# EARTH RATE IN IRIG PULSES/CS
PLPIPADT	DEC	50 B+6
-.25SC21	DEC	-25
NEG.5SEC	DEC	-50

2SEC21		DEC	200
DP2.5SEC	2DEC	250
BITS56		DEC	48
SIDEDAYS	2DEC*	.011605763 E-5 B23*	# FRACTION OF T2-T1 IN SIDEREAL DAY
LOCALUP		2DEC	.738876298 B-1
		2DEC	.0			# VECTOR AT TIME C(T2,T1) = 0
		2DEC	.673841098 B-1
## Page 352
LGYROANG	ADRES	GYROANG
IX		DEC	9

## Page 353

# PRELAUNCH TERMINATION PHASE(AFTER G.R. SIGNAL)



PRELTER1	TC	INTPRET

		DAD	0
			PREVTIME
			DP2.5SEC
		STORE	PREVTIME
		
		ITC	0
			EARTHRAT	# CHANGED BY MR. FIXIT.
		
		EXIT	0
		
		CAF	ZERO
		TS	GYROANG
		TS	GYROANG +2
		TS	GYROANG +4
		
		XCH	THETAX
		TS	GYROANG +1
		XCH	THETAY
		TS	GYROANG +3
		XCH	THETAZ
		TS	GYROANG +5
		
		INHINT
		CAF	PRIO31		#  CHANGED BY MR. FIXIT.
		TC	NOVAC
		CADR	SPITGYRO
		RELINT
		
		TC	NEWMODE
		OCT	04		# INERTIAL REFERENCE.
		
		TC	INTPRET
		
		DAD	0		# FORM TIME SINCE LAUNCH VECTOR IN
			DTEPOCH		# INERTIAL Z-X PLANE
			TIME2GR
		STORE	DTEAROT
		
		ITC	0		# BRANCH TO FORCE WT TO LESS THAN 1 REV
			EARROT2
		
		SIN	0		# FORM INERTIAL Z-X PLANE LOCAL VERTICAL
			LATITUDE
## Page 354
		DMOVE	0
			ZERODP
		
		COS	1
		VDEF
			LATITUDE
		STORE	VAC
		
		TEST	0		# TEST IF BIT IS ON. IF NOT SET IT ON
			NBSMBIT
			NBITON

ROTXY		AXT,1	1		# ROTATE PROJECTION OF LOCAL VERTICAL ON
		AXT,2	ITC		# INERTIAL X-Y PLANE ABOUT Z-AXIS
			2
			4
			ACCUROT
			
		NOLOD	0
		STORE	REFSMMAT	# PRESENT LOCAL VERTICAL VECTOR IS X-AXIS
		
		DMOVE	0
			ZERODP
		
		DMOVE	0
			VAC
		
		COMP	1		# FORM UNIT EAST VECTOR AT GRR
		VDEF	UNIT
			VAC +2
		
		NOLOD	1		# FORM UNIT SOUTH VECTOR
		VXV	UNIT
			REFSMMAT
		
		DSU	0		# FORM AZIMUTH SOUTH OF EAST AT GRR
			AZIMUTH
			90DEGAZ
		STORE	30D
		
		NOLOD	1
		SIN	VXSC
		STORE	REFSMMAT +12D	# (TEMPORARY STORAGE)
		
		COS	2		# FORM SM Z-AXIS
		VXSC	VAD
		UNIT
			30D
			-
			REFSMMAT +12D
## Page 355
		STORE	REFSMMAT +12D
		
		NOLOD	1		# FORM SM Y-AXIS BY CROSS PRODUCT
		VXV	UNIT
			REFSMMAT
		STORE	REFSMMAT +6
		
		VXV	1		# INITIALISE VN, GRAVITY GIVEN RN, UNITW
		VXSC
			UNITW
			RN		# SCALED AT 2(+25) METERS
			WIE
		STORE	VN		# SCALED AT 2(+7)M/CS
		
		VMOVE	1
		ITC
			RN
			CALCGRAV
		
		EXIT	0
		
		CAF	PRIO31		# GUESS WHAT WE'RE DOING
		TS	1/PIPADT	# GIVE UP  WOULD YOU BELEIVE 2 SECONDS
		
		TC	ENDJ3OUT	# TERMINATE PRELAUNCH. (PHASE = INACTIVE.)



NBITON		SWITCH	1
		ITC
			NBSMBIT
			ROTXY

WIE		2DEC*	7.29211505 E-7 B+19*	# RAD/CS SCALED AT 2(-19)

## Page 356

PRLSAVE		XCH	Q		# SAVE CURRENT VARIABLES FOR RESTARTS
		TS	MPAC +1
		
		CAF	THIRTEEN
AGAIN1		TS	MPAC
		INDEX	MPAC
		CS	FILTER
		INDEX	MPAC
		TS	PTEMP
		CCS	MPAC
		TC	AGAIN1
		
		CAF	ELEVEN
AGAIN2		TS	MPAC
		INDEX	MPAC
		CS	THETAY
		INDEX	MPAC
		TS	PTEMP +14D
		CCS	MPAC
		TC	AGAIN2
		
		CS	PRELTEMP
		TS	PTEMP +26D
		CS	GYROCSW
		TS	PTEMP +27D
		
		TC	MPAC +1
		
PRLRSTOR	XCH	Q		# RESTORE OLD VALUES OF VARIABLES
		TS	MPAC +1
		
		CAF	THIRTEEN
AGAIN3		TS	MPAC
		INDEX	MPAC
		CS	PTEMP
		INDEX	MPAC
		TS	FILTER
		CCS	MPAC
		TC	AGAIN3

		CAF	ELEVEN
AGAIN4		TS	MPAC
		INDEX	MPAC
		CS	PTEMP +14D
		INDEX	MPAC
		TS	THETAY
		CCS	MPAC
		TC	AGAIN4
		
		CS	PTEMP +26D
## Page 357
		TS	PRELTEMP
		CS	PTEMP +27D
		TS	GYROCSW
		
		TC	MPAC +1
		
## Page 358

# PRELAUNCH CHECK PROCEDURE (USES THE Z-NORTH SYSTEM OF AXES)



OPTCHK		INHINT
		CAF	PRIO14
		TC	FINDVAC		# CALL WITH PRIORITY OF TWENTY
		CADR	CHKOPT
		
		CAF	BIT3
		TS	MPAC
		TC	PLFINCHK
		TC	DOGYROC2
		
CHKOPT		TC	GRABDSP
		TC	PREGBSY
		
		TC	NEWMODE
		OCT	03
		
		CAF	ZERO
		TS	STARS
		AD	ONE
		TS	DSPTEM1 +2
		CAF	V06N30P
		TC	NVSUB
		TC	PRENVBSY
		INDEX	STARS
		XCH	TAZ
		TS	DSPTEM1
		INDEX	STARS
		XCH	TEL
		TS	DSPTEM1 +1
		
		TC	CHECKNV
		OCT	00661
		TC	CHEXIT
		XCH	DSPTEM1
		INDEX	STARS
		TS	TAZ
		XCH	DSPTEM1 +1
		INDEX	STARS
		TS	TEL
		
		CCS	STARS
		TC	+3
		CAF	ONE
		TC	CHKOPT +5
		TS	DSPTEM1 +2
## Page 359
		CAF	TWO
		TS	DSPTEM1 +1
		CAF	ONE
		TS	DSPTEM1		# SET UP STAR NUMBER DISPLAY
		
		CAF	V06N30P
		TC	NVSUB
		TC	PRENVBSY
		CAF	TWO
		TC	BANKCALL
		CADR	SXTMARK
		TC	BANKCALL
		CADR	OPTSTALL
		TC	CHEXIT
		TC	INTPRET
		
		ITC	0
			PROCTARG
		
		ITC	0
			MAKEXSM		# COMPUTE DESIRED SM ORIENTATION IN REC
		
		MXV	1
		VSLT
			TARGET1
			XSM
			1
		STORE	STARAD
		MXV	1
		VSLT
			TARGET1 +6
			XSM
			1
		STORE	STARAD +6
		
		LXC,1	2
		AXT,2	XSU,2
		SXA,2	ITC
			MARKSTAT
			2
			X1
			S1
			SXTNB

		ITC	0
			NBSM
		
		VMOVE	0
			STARM
		STORE	VECTEM
## Page 360
		LXC,1	2
		INCR,1	AXT,2
		XSU,2	SXA,2
			MARKSTAT
			-7
			2
			X1
			S1
		
		ITC	0
			SXTNB
		
		ITC	0
			NBSM
		
		VMOVE	0
			STARM
		STORE	12D
		
		VMOVE	0
			VECTEM
		STORE	6		# TO AVOID ERASABLE BIND
		
		ITC	0		# FIND DESIRED SM IN PRESENT SM
			AXISGEN
		
		ITC	0		# CALCULATE REQUIRED PULSE TORQUE IN GYROD
			CALCGTA
		
		VSRT	0
			OGC
			8D
		STORE	OGC		# CHANGE UNITS FROM 2PI TO GYRO PULSES
		
		EXIT	0



		TC	BANKCALL
		CADR	MKRELEAS
		TC	CHECKNV
		OCT	00667
		TC	CHEXIT
		TC	INTPRET
		
		VMOVE	0
			OGC		# GETS SUMMED INTO PRELAUNCH
		STORE	INFLANG
		
		EXIT	0
## Page 361

CHEXIT		TC	FREEDSP
		TC	NEWMODE
		OCT	02
		TC	ENDOFJOB
		
## Page 362

# SUBROUTINE TO COMPUTE DESIRED SM AXES IN REC

MAKEXSM		EXIT	0
		CAF	XVII
		TS	BUF
		CAF	ZERO		# ZERO ALL OF XSM
		INDEX	BUF
		TS	XSM
		CCS	BUF
		TC	MAKEXSM +2
		CAF	HALF
		TS	XSM		# HALF UNIT MATRIX IS COMPUTED
		
		TC	INTPRET
		
		COS	0
			AZIMUTH
		STORE	XSM +8D
		
		NOLOD	0
		STORE	XSM +16D
		
		SIN	0
			AZIMUTH
		STORE	XSM +14D
		
		COMP	0
			XSM +14D
		STORE	XSM +10D
		
		ITCQ	0
		
## Page 363

# ROUTINE TO CONVERT TARGET AZIMUTH AND ELEVATIONS TO VECTORS



PROCTARG	AXT,1	1
		AXT,2	AST,2
			1
			12D
			6
		
PROC1		SMOVE*	1
		TSRT
			TEL +1,1
			2
		STORE	0
		
		SIN	0
			0
		STORE	TARGET1 +12D,2
		COS	0
			0		# PUSH DOWN THE COSINE OF ELEVATION
		
		SMOVE*	1
		RTB
			TAZ +1,1
			CDULOGIC
		STORE	2		# THEN Y=0.5SIN(AZ)COS(EL)
		
		SIN	1
		DMP	TSLT
			2
			0
			1
		STORE	TARGET1 +14D,2
		
		COS	1
		DMP	TSLT
			2
			-
			1
		STORE	TARGET1 +16D,2
		AXT,1	1
		TIX,2	ITCQ
			0
			PROC1

## Page 364

# ROUTINE TO ROTATE COORDINATE SYSTEM BY EARTHRATE TIMES TIME		ON



V06N30P		OCTAL	00630
XVII		DEC	17

## Page 365

# ROUTINE TO DISPLAY STORED DATA FOR CHECKING AND MODIFICATION,VERB NOUN
# IS STORED AT L +1,RETURN IS TO L +2 FOR TERMINATE,L +3 FOR GOOD DATA OR PROCEDE



CHECKNV		XCH	Q
		TS	CHKNVTEM
		INDEX	CHKNVTEM
		XCH	A
		
		TC	NVSUB
		TC	CHECKNV1
		TC	BANKCALL
		CADR	FLASHON
		
		TC	ENDIDLE
		TC	+3
		TC	+4
		TC	CHECKNV +2
		
		INDEX	CHKNVTEM
		TC	Q
		INDEX	CHKNVTEM
		TC	Z
		
CHECKNV1	CAF	CHECKNV2
		TC	NVSUBUSY
CHECKNV2	CADR	CHECKNV +2
