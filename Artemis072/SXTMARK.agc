### FILE="Main.annotation"
# Copyright:	Public domain.
# Filename:	SXTMARK.agc
# Purpose:	Part of the source code for Artemis (i.e., Colossus 3),
#		build 072.  This is for the Command Module's (CM)
#		Apollo Guidance Computer (AGC), we believe for
#		Apollo 15-17.
# Assembler:	yaYUL
# Contact:	Jim Lawton <jim DOT lawton AT gmail DOT com>
# Website:	www.ibiblio.org/apollo/index.html
## Page scans:	www.ibiblio.org/apollo/ScansForConversion/Artemis072/
# Mod history:	2009-08-04 JL	Adapted from corresponding Comanche 055 file.
# 		2010-01-31 JL	Fixed build errors.
#		2010-02-11 JL	Fixed error on p242.
#		2010-02-20 RSB	Un-##'d this header.
#		2010-12-29 JL	Fixed indentation.

## Page 239

# PROGRAM NAME     -     SXTMARK
#
# MOD. 1	8 AUG. 69	BY P.RYE
#
# FUNCTIONAL DESCRIPTION:
#
#	SXTMARK IS CALLED BY P03 AND BY P22, P23, P51, and P52 VIA R53.
#	THE REGISTER MARKINDX IS SET TO 5 IF THE CALLING PROGRAM IS P22, OR TO 1 FOR OTHER USERS.
#	   THIS REGISTER INDICATES THE NUMBER OF MARKS DESIRED.
#	THE REGISTER EXTVBACT IS CHECKED (SUBROUTINE TESTMARK) TO INSURE THAT THE MARK DISPLAY SYSTEM
#	   IS FREE.  IF NOT, BAILOUT (31211) IS DONE.
#	BIT 2 OF THE REGISTER EXTVBACT IS SET BY SXTMARK, RESERVING THE MARKING AND EXTENDED VERB SYSTEM.
#	SXTMARK DISPLAYS A FLASHING VERB 51, CALLING FOR MARKS.  A PROCEED RESPONSE TO THIS DISPLAY
#	   WILL RELEASE THE MARKING SYSTEM (SUBROUTINES MKRELEAS, CLEARMARK) AND RETURN TO THE
#	   CALLING PROGRAM.
#
#	WHEN SUFFICIENT MARKS HAVE BEEN MADE (MARKINDX = 0) A FLASHING V50N25, R1 = 16, IS DISPLAYED.
#	   A PROCEED RESPONSE TO THIS DISPLAY WILL RETURN TO THE CALLING PROGRAM AFTER RELEASING THE
#	   MARKING SYSTEM.
#
#	MARKS ARE PROCESSED BY THE ROUTINE MARKRUPT AS FOLLOWS:
#		IF NO MARKS ARE CALLED FOR, ALARM CODE 114 IS SENT AND THE MARKRUPT ROUTINE EXITS.
#		IF A MARK IS ACCEPTED, MARKFLG IS SET TO ENABLE A REJECT.
#		IF R21(P20) IS RUNNING, DATA IS MOVED FROM STORAGE MRKBUF1 INTO MRKBUF2.  NEW MARK DATA
#			IS STORED INTO MRKBUF1.
#		IF P22 IS RUNNING, MARK DATA IS STORED INTO SVMRKDAT, USING THE REGISTER P22DEX AS AN
#			INDEX AND THE REGISTER 8NN AS A COUNTER.  MARKINDX IS DECREMENTED.
#		IF R57 IS RUNNING, MARK DATA IS STORED INTO MARKDOWN FOR DOWNLINK, THEN PROCESSED AS FOR
#			R21.  MARKRUPT THEN CALLS MARKDISP (IN R57).1DNADR
#		FOR OTHER USERS, MARK DATA IS STORED INTO MRKBUF1 AND MARKINDX IS DECREMENTED.
#
#	MARK REJECTS ARE PROCESSED BY THE ROUTINE MARKRUPT AS FOLLOWS:
#		IF MARKFLG IS CLEAR (I.E., NO MARK WAS TAKEN), ALARM CODE 110 IS SENT AND THE ROUTINE EXITS.
#		OTHERWISE, MARKINDX IS INCREMENTED, THE P22 INDICATORS 8NN AND P22DEX ARE DECREMENTED
#			(IF THE USER IS P22), AND THE V51FL DISPLAY IN SXTMARK IS REESTABLISHED.
#
#	IF THE ERASABLE REGISTER CDUCHKWD IS SET TO A NON-ZERO VALUE, VALIDITY OF THE MARKS IS CHECKED
#	   BY THE MARKRUPT ROUTINE AS FOLLOWS:
#		IF THE CDU'S CHANGE BY MORE THAN 3 BITS OVER THE TIME PERIOD INDICATED BY THE VALUE OF
#			CDUCHKWD, ALARM CODE 121 IS SENT AND THE ROUTINE EXITS.
#
# CALLING SEQUENCE -
#
#	TC	BANKCALL
#	CADR	SXTMARK
#

## Page 240

# NORMAL EXIT MODE -
#
#	RETURN TO USER VIA BANKJUMP (RETURN ADDRESS IN OPTCADR).
#
#
# ALARM OR ABORT EXIT MODES
#
#	1. ALARM 110 - MARK REJECT WITH NO MARK
#	2. ALARM 113 - NO INBITS
#	3. ALARM 121 - CDU'S NO GOOD AT MARK TIME
#	4. ALARM 114 - MARK MADE BUT NOT DESIRED
#	5. BAILOUT 31211 - MARK DISPLAY SYSTEM BUSY
#
#
# ERASABLE INITIALIZATION REQUIRED -
#
#	NONE
#
#
# OUTPUT -
#
#	FOR P22:
#		MARK DATA IN SVMRKDAT
#		MARKINDX DECREMENTED BY ONE FOR EACH MARK TAKEN
#		NO. OF MARKS IN 8NN
#	FOR R57:
#		MARK DATA IN MARKDOWN AND MRKBUF1
#	FOR OTHER USERS:
#		MARKINDX DECREMENTED TO ZERO IF A MARK WAS TAKEN
#		MARK DATA IN MRKBUF1
#
#
# CONDITIONS AT EXIT -
#
#	MARKINDX = INITIAL VALUE - NO. MARKS TAKEN
#	MARKING SYSTEM IS RELEASED :
#		EXTVBACT = 0
#		BIT 9 OPTMODES = 0
#		OPTIND = -1
#		BIT 2 CHAN12 = 0
#	MARKFLG = 0
#	OPTCADR CONTAINS CADR OF SXTMARK CALLER
#

## Page 241
		SETLOC	SXTMARKE
		BANK

		EBANK=	MRKBUF1
		COUNT*	$$/SXTMK
SXTMARK		TC	TESTMARK
		TC	CHECKMM			# IS THIS P24
		MM	24
		TCF	+2			# NO
		TCF	SXTMRKA			# YES
		TC	CHECKMM
		MM	22
		TCF	SETMRK
SXTMRKA		CAF	ZERO			# INITIALIZE MARK COUNTER
		TS	8NN

		TS	P22DEX
		CAF	FIVE			# 5 MARKS FOR P22, ONE FOR ALL OTHERS
		TCF	SETMRK +1
SETMRK		CAF	ONE
		TS	MARKINDX

		TC	MAKECADR		# STORE RETURN TO USER WHO CALLED
		TS	OPTCADR			#    SXTMARK IN OPTCADR

MKVB51		TC	BANKCALL		# CLEAR DISPLAY FOR MARK VERB
		CADR	KLEENEX
MKVBDSP		CAF	VB51			# DISPLAY MARK VERB 51
 +1		TC	BANKCALL
		CADR	GOMARK4
		TCF	TERMSXT			# VB34-TERMINATE
		TCF	ENTANSWR		# V33-PROCEED-MARKING DONE
		TCF	MKVB5X			# ENTER-RECYCLE TO INITIAL MARK DISPLAY

TERMSXT		TC	CLEARMRK		# CLEAR MARK ACTIVITY.

		TC	MKRLEES

		TC	CHECKMM
		MM	03
		TCF	+2
		TC	TERMP03
		TC	GOTOPOOH

TERMP03		TC	POSTJUMP
		CADR	GCOMP5

ENTANSWR	CAF	PRIO24
		TC	NOVAC
## Page 242
		EBANK=	WHOCARES
		2CADR	ENDEXT

		CAF	PRIO13			# ALLOW LEFTOVER SLEEPING JOB IF ANY
		TC	PRIOCHNG

MKVRET		CA	OPTCADR			# OPTCADR HAS RETURNED CADR OF USER WHO
		TC	BANKJUMP		#    CALLED SXTMARK

MKVB5X		CCS	MARKINDX		# REDISPLAY VB51 IF MORE MARKS WANTED
		TCF	MKVB51
MKVB50		CAF	R1D1			# OCT 16
		TS	DSPTEM1
		CAF	V50N25			# DISPLAY V50N25 IF MARKING DONE.
		TCF	MKVBDSP +1
V50N25		VN	5025
VB51		VN	5100

TESTMARK	CAF	SIX
		MASK	EXTVBACT
		CCS	A
		TCF	MKABORT
		CAF	BIT2
		ADS	EXTVBACT
		TC	Q

MKABORT		TC	BAILOUT
		OCT	31211

MKRELEAS	EQUALS	MKRLEES

MKRLEES		INHINT
		CA	NEGONE
		TS	OPTIND			# KILL COARS OPTICS

		CAF	ZERO
		TS	MARKINDX

		CS	MARKBIT
		MASK	FLAGWRD1
		TS	FLAGWRD1

		RELINT

		TC	Q

## Page 243

MARKRUPT	TS	BANKRUPT		# STORE CDUS AND OPTICS NOW
		CA	CDUT
		TS	MKCDUT
		CA	CDUS
		TS	MKCDUS
		CA	CDUY
		TS	MKCDUY
		CA	CDUZ
		TS	MKCDUZ
		CA	CDUX
		TS	MKCDUX
		EXTEND
		DCA	TIME2			# GET TIME
		DXCH	MKT2T1
		EXTEND
		DCA	MKT2T1
		DXCH	SAMPTIME		# RUPT TIME FOR NOUN 65.

		XCH	Q
		TS	QRUPT

		CAF	BIT6			# SEE IF MARK OR MKREJECT
		EXTEND
		RAND	NAVKEYIN
		CCS	A
		TC	MARKIT			# ITS A MARK

		CAF	BIT7			# NOT A MARK, SEE IF MKREJECT
		EXTEND
		RAND	NAVKEYIN
		CCS	A
		TC	MKREJECT		# ITS A MARK REJECT

KEYCALL		CAF	OCT37			# NOT MARK OR MKREJECT, SEE IF KEYCODE
		EXTEND
		RAND	NAVKEYIN
		EXTEND
		BZF	+3			# IF NO INBITS
		TC	POSTJUMP
		CADR	KEYCOM			# IT'S A KEY CODE, NOT A MARK.

 +3		TC	ALARM			# ALARM IF NO INBITS
		OCT	113
		TC	RESUME

## Page 244

# PROGRAM NAME - MARKIT					DATE: 19 SEPT 1967
#
# CALLING SEQUENCE
#	FROM MARKRUPT IF CHAN 16 BIT 6 = 1
#
# EXIT
#	RESUME
#
# INPUT
#	CDUCHKWD. ALSO ALL INITIALIZATION FOR MARKCONT
#
# OUTPUT
#	MK22T1,MKCDUX,MKCDUY,MKCDUZ,MKCDUS,MKCDUT
#
# ALARM EXIT
#	NONE

MARKIT		CCS	CDUCHKWD
		TCF	+3			# DELAY OF CDUCHKWD CS IF PNZ
		TCF	+2
		CAF	ZERO
		AD	ONE			# 10 MS IF NO CHECK
		TC	WAITLIST
		EBANK=	MRKBUF1
		2CADR	MARKDIF

		TCF	RESUME

MARKDIF		CAF	P24BIT			# IS THIS P24
		MASK	FLAGWRD9
		CCS	A
		TCF	MARKCONT		# YES ACCEPT MARK
		CA	CDUCHKWD		# IF DELAY CHECK IS ZERO OR NEG, ACP MARK
		EXTEND
		BZMF	MARKCONT
		CS	BIT1
		TS	MKNDX			# SET INDEX -1
		CA	MKCDUX
		TC	DIFCHK			# SEE IF VEHICLE RATE TOO MUCH AT MARK
		CA	MKCDUY
		TC	DIFCHK
		CA	MKCDUZ
		TC	DIFCHK

MARKCONT	CAF	R21BIT			# R21 MARKING
		MASK	FLAGWRD2
		CCS	A
		TCF	PUTMARK			# YES

		CAF	V59FLBIT
## Page 245
		MASK 	FLAGWRD5		# V59FLAG
		CCS	A
		TCF	DOWNMRK

		CCS	MARKINDX		# MARKS CALLED FOR
		TCF	MARK2			# YES

114ALM		TC	ALARM
		OCT	114			# MARKS NOT CALLED FOR
		TC	TASKOVER

MARK2		TS	MARKINDX		# DECREMENT NO. MARKS WANTED

		TC	UPFLAG
		ADRES	MARKFLG			# SET FLAG TO ENABLE REJECT

		TC	CHECKMM			# IS THIS P24
		MM	24
		TCF	MRKCHK22		# NO
		INCR	MARKINDX		# RESTORE THIS REGISTER
		TC	UPFLAG
		ADRES	P22MKFLG		# DOWNLINK CONTAINS P24 MARKS
		TC	UPFLAG
		ADRES	P24MKFLG		# NEW P24MARK TAKEN
		TCF	VACSTOR -1
MRKCHK22	TC	CHECKMM
		MM	22
		TCF	PUTMARK
 -1		INCR	8NN			# NO, MARKS TAKEN.
VACSTOR		EXTEND
		DCA	MKT2T1
		INDEX	P22DEX
		DXCH	SVMRKDAT
		EXTEND
		DCA	MKCDUY
		INDEX	P22DEX
		DXCH	SVMRKDAT +2
		EXTEND
		DCA	MKCDUZ
		INDEX	P22DEX
		DXCH	SVMRKDAT +4
		CA	MKCDUX
		INDEX	P22DEX
		TS	SVMRKDAT +6

		TC	CHECKMM			# IS THIS P24
		MM	24
		TCF	INDINC			# NO
		CS	OCT34			# YES DEC 28
		AD	P22DEX
## Page 246
		EXTEND				# ARE THERE ANY MORE LOC LEFT IN MARK
		BZF	+2			# DOWNLINK BUFFER
		TCF	INDINC			# YES
		CA	ZERO			# REINITIALIZE INDEX FOR
		TS	P22DEX			# BEGINNING OF BUFFER
		TCF	MARKDONE
INDINC		CAF	SEVEN
		ADS	P22DEX
MARKDONE	CCS	MARKINDX		# ANY MORE MARKS TO BE TAKEN
		TCF	TASKOVER
		CAF	PRIO22
		TC	FINDVAC
		EBANK=	MRKBUF1
		2CADR	MKVB5X

		TCF	TASKOVER

DOWNMRK		CAF	SIX			# FOR CALIBRATION MARK
		TC	GENTRAN
		ADRES	MKT2T1
		ADRES	MARKDOWN

		CAF	PRIO5
		TC	NOVAC
		EBANK=	MRKBUF1
		2CADR	MARKDISP

PUTMARK		CAF	SIX
		TC	GENTRAN
		ADRES	MKT2T1
		ADRES	MRKBUF1

		CAF	R21BIT			# DONT CALL VB50 DISPLAY FOR R21
		MASK	FLAGWRD2
		CCS	A
		TCF	TASKOVER

		TCF	MARKDONE

DIFCHK		INCR	MKNDX			# INCREMENT INDEX

		EXTEND
		INDEX	MKNDX
		MSU	CDUX			# GET MARK(ICDU) - CURRENT(ICDU)
		CCS	A
		TCF	+4
		TC	Q
		TCF	+2
		TC	Q
## Page 247
		AD	NEG2			# SEE IF DIFFERENCE GREATER THAN 3 BITS
		EXTEND
		BZMF	-3			# NOT GREATER

		TC	ALARM			# COUPLED WITH PROGRAM ALARM
		OCT	00121

		TCF	TASKOVER		# DO NOT ACCEPT

MKREJECT	CAF	R21BIT
		MASK	FLAGWRD2		# R21 MARK (SPECIAL MARKING FOR R21)
		EXTEND
		BZF	MRKREJCT		# NOT SET THEREFORE REGULAR REJECT
		CA	MRKBUF1			# IS THERE A MARK IN THE BUFFER?
		EXTEND
		BZF	+3			# YES - REJECT MARK IN BUFFER

		EXTEND
		BZMF	REJCTR22		# NO,SET FLAG TO REJECT MARK PRoCESSED-R22

		CA	NEGONE			# -1 (FOR R22)
		TS	MRKBUF1			# -0 IN TIME IS FLAG TO R22 SIGNIFYING A
		TC	RESUME

REJCTR22	CAF	R22CABIT		# IS R22 PROCESSING A MARK?
		MASK	FLAGWRD9
		EXTEND
		BZF	RESUME			# NO IGNORE MARK REJECT

		TC	UPFLAG
		ADRES	REJCTFLG		# YES - SET FLAG FOR R22
		TC	RESUME

MRKREJCT	CAF	MARKBIT
		MASK	FLAGWRD1
		CCS	A
		TC	REJECT3

		TC	ALARM			# DONT ACCEPT TWO REJECTS TOGETHER
		OCT	110
		TC	RESUME

REJECT3		TC	DOWNFLAG
		ADRES	MARKFLG

		TC	CHECKMM			# IS THIS P24
		MM	24
		TCF	REJECT4			# NO
		TC	DOWNFLAG		# YES
		ADRES	P24MKFLG
## Page 248
		CCS	P22DEX			# IS MARK TO BE REJ, THE LAST MARK IN BUF
		TCF	+3			# NO
		CA	OCT34			# YES
		TCF	+3
		CS	SEVEN
		AD	P22DEX
REJECT5		TS	RUPTREG1
		EXTEND
		INDEX	RUPTREG1
		DCS	SVMRKDAT
		INDEX	RUPTREG1
		DXCH	SVMRKDAT
		TCF	REJEXIT
REJECT4		INCR	MARKINDX		# CALL FOR ANOTHER MARK
		TC	CHECKMM
		MM	22
		TCF	REJEXIT

		CS	ONE			# FOR P22
		ADS	8NN
		CS	SEVEN
		ADS	P22DEX			# DECREMENT P22 INDEX

		TCF	REJECT5

REJEXIT		CAF	PRIO22
		TC	FINDVAC
		EBANK=	MRKBUF1
		2CADR	MKVBDSP

		TCF	RESUME
