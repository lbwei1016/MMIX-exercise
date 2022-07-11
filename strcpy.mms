% copy string from $0 to $1 (both are starting address)
% lines without comments are the parts I didn't understand
in 	IS	$2		Store input data
out 	IS 	$3		Store output data
r	IS	$4		
l	IS 	$5
m	IS	$6
t	IS	$7		Temp. storage
mm	IS	$8
tt	IS	$9		Another temp. storage
flip	GREG	#0102040810204080	Used as a matrix (flip bytes)
ones	GREG	#0101010101010100	For #0 check (end of string)
	
	LOC	#100
StrCpy	AND	in,$0,#7
	SLU	in,in,3
	AND	out,$1,#7
	SLU	out,out,3
	SUB	r,out,in
	LDOU	out,$1,0	"out" now stores meaningless data
	SUB	$1,$1,$0	$1 now stores address diff. from src. to dest.
	NEG	m,0,1		m <- #fff...fff
	SRU	m,m,in		m <- #0..00f..fff
	LDOU	in,$0,0		"in" now stores the first string to be moved
	PUT	rM,m		rM <- m (rM: multiplex mask reg)
	NEG	mm,0,1		mm <- #fff...fff
	BN	r,1F		If r<0, 

	NEG	l,64,r
	SLU	tt,out,r
	MUX	in,in,tt
	BDIF	t,ones,in
	AND	t,t,m
	SRU	mm,mm,r
	PUT	rM,mm
	JMP	4F

1H	NEG	l,0,r		r <- abs(r) - 1
	INCL	r,64		
	SUB	$1,$1,8
	SRU	out,out,l
	MUX	in,in,out
	BDIF	t,ones,in
	AND	t,t,m
	SRU	mm,mm,r
	PUT	rM,mm
	PBZ	t,2F
	JMP 	5F
	
3H	MUX	out,tt,out
	STOU	out,$0,$1	here $1 = $1(original) - $0(original)
2H	SLU	out,in,l
	LDOU	in,$0,8		Load eight bytes at once
	INCL	$0,8		Increase address
	BDIF	t,ones,in	For the following "PBZ" check
4H	SRU	tt,in,r
	PBZ	t,3B		% t==0 only occurs when in==#0, which means the last byte is read. Hence stop reading

	SRU 	mm,t,r
	MUX	out,tt,out
	BNZ	mm,1F

	STOU	out,$0,$1
5H	INCL	$0,8
	SLU	out,in,l
	SLU	mm,t,l
1H	LDOU	in,$0,$1	in <- ($0 + ($1-$0)) = $1
	MOR	mm,mm,flip	rows of matrix(mm) are flipped
	SUBU	mm,mm,1
	PUT	rM,mm
	MUX	in,in,out
	STOU	in,$0,$1
	POP 	0
