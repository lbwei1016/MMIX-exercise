t 	GREG 	0		% temp. storage
Dat 	GREG 	Data_Segment
Y 	GREG	1950		% starting year
cnt	GREG 	0		% count how many years have been calculated 

	LOC	#100
Main	SET	cnt,0
2H	JMP	MkTab		% NO subroutine here, for I cannot fix some error
3H	INCL	Y,1
	INCL	cnt,1
	DIV	t,cnt,5		
	GET	t,rR
	PBP	t,2B		% If a multiple of five, print '\n'
	GETA	$255,NewLine
	TRAP	0,Fputs,StdOut
	CMP	t,cnt,50
	PBN	t,2B
	TRAP	0,Halt,0
NewLine	BYTE	#a,0,0,0

MkTab	SET 	$1,Y
	PUSHJ	$0,Easter	% Calculate Easter Day
				% N (Day) is stored in $0, "April or 
				% not" (G=1, April) is stored in $1
	SET	$3,$0		% print Day
	PUSHJ	$2,Int2Chr
	LDA	$255,Dat
	TRAP	0,Fputs,StdOut
	
	PBZ	$1,1F		% print month
	GETA	$255,April
	JMP	@+4*2
1H	GETA	$255,March
	TRAP	0,Fputs,StdOut
	
	SET	$3,Y		% print year
	PUSHJ	$2,Int2Chr
	LDA	$255,Dat
	TRAP	0,Fputs,StdOut
	GETA	$255,Deli
	TRAP	0,Fputs,StdOut
	JMP	3B
%	TRAP	0,Halt,0

March	BYTE	"March ",0,0	% two 0s are used to pad address
				% to a multiple of 4 (tetra) 
April	BYTE	"April ",0,0
Deli	BYTE	#9,"|",#9,0

G IS $0 ;N IS $1 ;C IS $2 ;X IS $3 
Z IS $4 ;D IS $5 ;E IS $6 ;YY IS $7
Easter 	SET	YY,$0		% This formula is due to TAOCP fasc1 p.54
	DIV 	t,YY,19
	GET	t,rR
	INCL	t,1
	SET	G,t
	DIV	C,YY,100
	INCL	C,1
	MUL	t,C,3
	DIV	X,t,4
	SUB	X,X,12
	MUL	t,C,8
	ADD	t,t,5
	DIV	Z,t,25	
	SUB	Z,Z,5
	MUL	t,YY,5
	DIV	D,t,4
	ADD	t,X,10
	SUB	D,D,t
	MUL	t,G,11
	ADD	t,t,20
	ADD	t,t,Z
	SUB	t,t,X
	DIV	t,t,30
	GET	E,rR
	SUB	t,E,24
	PBN	t,1F
	SUB	t,E,25
	PBP	t,1F
	BN	t,2F
	SUB	t,G,11
	BNP	t,1F
2H	INCL	E,1
1H	NEG	t,E
	ADD	N,t,44
	SUB 	t,N,21
	BNN	t,Skip
	INCL	N,30
Skip	ADD	t,D,N
	DIV	t,t,7
	GET	t,rR
	NEG	t,t
	ADD	t,t,7
	ADD	t,t,N
	SET	N,t
	SUB 	t,N,31
	BN	t,1F
	SET	G,1		% April
	SUB	N,N,31
	JMP	2F
1H	SET	G,0		% March
2H	POP	2,0

off IS $1 ;NN IS $2 ;rem IS $3 ;chr IS $5
Int2Chr	SET	NN,$0		% fetch parameter (integer to be 
				% converted)
	SET	t,NN		% make a copy
	SET	off,1		
1H	DIV	t,t,10		% calculate how many digits the integer has
	INCL	off,1
	PBP	t,1B

	SET	t,0
	STB	t,Dat,off	% terminating chr
	SUB	off,off,1
	SET	t,#20		% ASCII code #20 is ' ' (for formatting)
	STB	t,Dat,off
	SUB	off,off,1
	SET	t,NN
2H	DIV	t,t,10		% key part: convert "int" to ASCII code
	GET	rem,rR
	ADD	rem,rem,#30	% ASCII code #30 is '0'
	STB	rem,Dat,off
	SUB	off,off,1
	PBP	t,2B
	POP	0,0	
