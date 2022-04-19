{+doc
+NOMBRE:tridia
+CREACION:1.1.90
+AUTORES:rch
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO:Servicio de manejo de Sistemas TRI-DIAGONALES.
+PROYECTO:rchlib

+REVISION:
+AUTOR:
+DESCRIPCION:
-doc}

unit tridia;
interface
uses
	xMatDefs;

procedure TridiaSolver(var d,p,q,b; n:integer);
{  INPUT                       LENGTH         OUTPUT
	d = diagonal                 [n]           pivots
	p = Up-diagonal             [n-1]          unchanged
	q = down-diagonal           [n-1]          multipliers
	b = terminos independientes  [n]           system result
	n = length definition                      unchanged    }

procedure TridiaIter(var d,p,q,b,x; n:integer);
{  INPUT                       LENGTH         OUTPUT
	d = diagonal                 [n]
	p = Up-diagonal             [n-1]
	q = down-diagonal           [n-1]
	b = terminos independientes  [n]
	x = aproximate solution      [n]           new apriximation
	n = length definition   }

procedure TridiaResidual(var d,p,q,b,x,r; n:integer);
{  INPUT                       LENGTH         OUTPUT
	d = diagonal                 [n]
	p = Up-diagonal             [n-1]
	q = down-diagonal           [n-1]
	b = terminos independientes  [n]
	x = aproximate solution      [n]
	r = residuos      				[n]				residuos
	n = length definition   }

function norm(var x; n:integer):NReal;
{
	norm = sum( abs(x[i]) ); i: 1..n
}


implementation


type
	LVR = array[1..6000] of NReal;

function norm(var x; n:integer):NReal;
var
	m:NReal;
	k:integer;
begin
	m:=0;
	for k:=1 to n do
		m:=m+abs(LVR(x)[k]);
	norm:=m
end;


procedure TridiaSolver(var d,p,q,b; n:integer);

{  INPUT                     Length           OUTPUT
	d = diagonal                [n]           pivots
	p = Up-diagonal            [n-1]          unchanged
	q = down-diagonal          [n-1]          multipliers
	b = terminos independientes [n]           system result


}


var
	piv,m:NReal;
	k:integer;

begin
	piv:=LVR(d)[1];
	for k:= 1 to n-1 do
	begin
		m:=LVR(q)[k]/piv;
		piv:=LVR(d)[k+1]-m* LVR(p)[k];
		LVR(b)[k+1]:=LVR(b)[k+1]-m*LVR(b)[k];
		LVR(q)[k]:=m;
		LVR(d)[k+1]:=piv
	end;
	LVR(b)[n]:=LVR(b)[n]/LVR(d)[n];
	for k:= n-1 downto 1 do
		LVR(b)[k]:=(LVR(b)[k]-LVR(p)[k]*LVR(b)[k+1])/LVR(d)[k];
end;


procedure TridiaIter(var d,p,q,b,x; n:integer);
{  INPUT                       LENGTH         OUTPUT
	d = diagonal                 [n]
	p = Up-diagonal             [n-1]
	q = down-diagonal           [n-1]
	b = terminos independientes  [n]
	x = aproximate solution      [n]           new apriximation
	n = length definition   }
var
	k:integer;
begin
	LVR(x)[1]:=(LVR(b)[1]-LVR(p)[1]*LVR(x)[2])/LVR(d)[1];
	for k:= 2 to n-1 do
		LVR(x)[k]:=(LVR(b)[k]-LVR(p)[k]*LVR(x)[k+1]
						-LVR(q)[k-1]*LVR(x)[k-1])/LVR(d)[k];
	LVR(x)[n]:=(LVR(b)[n]-LVR(q)[n-1]*LVR(x)[n-1])/LVR(d)[n]
end;


procedure TridiaResidual(var d,p,q,b,x,r; n:integer);
{  INPUT                       LENGTH         OUTPUT
	d = diagonal                 [n]
	p = Up-diagonal             [n-1]
	q = down-diagonal           [n-1]
	b = terminos independientes  [n]
	x = aproximate solution      [n]
	r = residuos      				[n]				residuos
	n = length definition   }

var
	k:integer;
begin
	LVR(r)[1]:=LVR(b)[1]-LVR(p)[1]*LVR(x)[2]-LVR(d)[1]*LVR(x)[1];
	for k:= 2 to n-1 do
		LVR(r)[k]:=LVR(b)[k]-LVR(p)[k]*LVR(x)[k+1]
						-LVR(q)[k-1]*LVR(x)[k-1]-LVR(d)[k]*LVR(x)[k];
	LVR(r)[n]:=LVR(b)[n]-LVR(q)[n-1]*LVR(x)[n-1]-LVR(d)[n]*LVR(x)[n];
end;


end.

