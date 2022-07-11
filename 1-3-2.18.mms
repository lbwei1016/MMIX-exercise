% Find saddle point in a 9X8 matrix.
Row	GREG	0
Col	GREG	0
B 	IS	#ffff0000ffff0000	% Some temp storge for marking
ii	IS	$0			% Row index
jj	IS	$1			% Column index
mn	IS 	$2
mx	IS 	$3	% Flag indicating now is calculating "max"
aij	IS 	$4
sameCnt IS	$5	% Number of simultaneous minimums
Pos	GREG	Data_Segment
t	GREG	0		% Temp storage
tt	GREG	0		% Temp storage 2
	
	SET 	Row,9
	SET	Col,8
	SET	mx,0

NewRow	SET 	sameCnt,0
	SET	ii,Row<<3
	SET 	jj,Col
	SUB	Row,Row,1
	BN	Row,NewCol

	LDO	mn,A,ii+jj
	JMP	DecrJ
Loop	LDO	aij,A,ii+jj	% Retrieve value and compare
	BNZ	mx,@+4*3
	CMP	t,aij,mn
	PBP	t,DecrJ		% Go to the next value if aij > mn  
	NEG	aij,0,aij	% Max is negated 
	PBP	t,DecrI
	BZ	t,StSame	% Store if same as current min
StSame	INCL	sameCnt,1	% Store the same 
	BNZ	mx,@+4*3
	STO	jj,Pos,sameCnt<<3
	JMP	DecrJ
	STO	ii,Pos,sameCnt<<3
	JMP	DecrI
ChanMn	SET	sameCnt,0	% Update minimum
	SET	mn,aij
	JMP	StSame
DecrJ	SUB	jj,jj,1		% Decrease j; j <- j-1
	PBP 	jj,Loop		% If j>0, go to compare
Mark	LDO	t,Pos,sameCnt<<3	% Where to mark
	LDO	tt,B,ii+t		% Mark increase by one
	STO	tt+1,B,ii+t
	SUB	sameCnt,sameCnt,1
	BNP	sameCnt,NewRow	
	JMP	Mark	

DecrI	SUB	ii,ii,1<<3
	PBP	ii,Loop
MarkCol	LDO	t,Pos,sameCnt<<3
	LDO	tt,B,t+jj
	STO	tt+1,B,t+jj
	SUB	sameCnt, sameCnt,1
	BNP	sameCnt,NewCol
	JMP	MarkCol

NewCol	CSN	Row,Row,9
	SET 	sameCnt,0
	SET	ii,Row<<3
	SET	jj,Col
	SUB	Col,Col,1
	BN	Col,End
	
	LDO	mn,A,ii+jj
	NEG	mn,0,mn		% mn <- (-mn)
	SET	mx,1
	JMP	DecrI

End	SET 	Row,9
	SET 	Col,8
	SET	t,(ii<<3)+jj + 1

	SUB	t,t,1
	CSN	t,t-9,0		% Boundry reached
	BZ	t,@+4*3
	LDO	tt,B,t
	PBNP	tt-1,@-4*2	% If marked twice -> saddle point
	SET	ii,t
	CSP	ii,t,t+A
	POP 	1,0		% Return 8*ii + jj
