{+doc
+NOMBRE: MatCPX
+CREACION: 1994
+AUTORES: rch
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO: definicion del objeto matriz de complejos.
+PROYECTO: rchlib

+REVISION:
+AUTOR:
+DESCRIPCION:
-doc}
unit MatCPX;

interface
uses
  sysutils,
	xMatDefs,
	Classes,
	AlgebraC;

type
   TVarArrayOfComplex= array of NComplex;

	TVectComplex = class
		v: TVarArrayOfComplex;
			constructor Create_Init(ne: integer);
			constructor Create_Load( var S: TStream );
         constructor Create_OnVarArray( var vc: TVarArrayOfComplex );
			procedure e(var res: NComplex; k:word);
			procedure pon_e(k:word; var x:NComplex);
			procedure acum_e(k:word; var x: NComplex);
			procedure PEV(var res: NComplex; var y :TVectComplex); //res:= self.y
			procedure PorComplex(var  r: NComplex );
			procedure sum(var y:TVectComplex);
			procedure sumComplexPV(var  r: NComplex;var x:TVectComplex);
			function ne2:NReal; {norma euclideana al cuadrado }
			function normEuclid:NReal;
			function normMaxAbs:NReal;
			function normSumAbs:NReal;
			procedure Copy(var a:TVectComplex); // self <- a
			procedure Ceros; virtual;
			function pte( k: integer ): PNComplex;
			function Get_n: integer;
			procedure Set_n( nn: integer );
			property n: integer read Get_n write Set_n;

      // suma los vectores A y B y guarda el resultado
      procedure sumvect(A,B:TVectComplex);

			{Si todos los elementos del vector son menores que (tol)
			el resultado de la función es true}
			function cond_epsilon(tol:NReal):boolean;

			{Si todos los elementos del vector son menores que los
			elementos de (tol)*PV correspondientes el resultado de la
			funcion es true}
			function cond_epsilonR(PX:TVectComplex;tol:NReal):Boolean;

			{Despliega el vector en pantalla}
			procedure mostrarvector;


	end;


type
	TMatComplex = class
		nf, nc: integer;
		fila: array of TVectComplex;
		constructor Create_Init(nfilas,ncolumnas: integer);
		constructor Create_Load( var S: TStream );
		function pte(k,j: integer): PNComplex;
		procedure e(var res: NComplex; k,j: word);
		procedure pon_e(k,j: integer; x: NComplex);
		procedure acum_e(k,j:integer; x: NComplex);
		procedure Mult(a,b:TMatComplex);
		procedure Traza( var res:NComplex );
		procedure Deter( var res:NComplex );
		procedure Escaler(var res: NComplex; var i: TMatComplex);
		procedure CopyColVect(var Y: TVectComplex; J: Integer);
		procedure Inv;
		procedure Ceros; virtual;
		procedure CerosFila( kfil: integer);
		procedure WriteM;
		procedure IntercambieFilas( k1, k2: integer );
		procedure Copy( var a: TMatComplex ); // self <- a
	end;


implementation


procedure TMatComplex.IntercambieFilas( k1, k2: integer );
var
	tmp: TVectComplex;
begin
	tmp:= fila[k1];
	fila[k1]:= fila[k2];
	fila[k2]:= tmp;
end;

procedure TMatComplex.copy( var a: TMatComplex );
var
	k: integer;
begin
	for k:= 0 to high( fila ) do
		fila[k].copy( a.fila[k] );
end;


function TMatComplex.pte( k, j: integer ): PNComplex;
begin
	result:= fila[k].pte(j);
end;

constructor TMatComplex.Create_Init( nfilas, ncolumnas: integer );
var
	k: integer;
begin
	inherited Create;
	nf:= nfilas;
	nc:= ncolumnas;
	setlength( fila, nf+1 );
	for k:= 1 to nf do
		fila[k]:= TVectComplex.Create_Init( ncolumnas );
end;

constructor TMatComplex.Create_Load( var S: TStream );
var
	k: integer;

begin
	inherited Create;
	s.read( nf, sizeOf( nf ));
	s.read( nc, sizeOf( nc ));
	setlength( fila, nf+1 );
	for k:= 1 to nf do
		fila[k]:= TVectComplex.Create_Load( s );
end;


procedure TMatComplex.e( var res: NComplex; k,j: word);
begin
	 fila[k].e(res, j);
end;

procedure TMatComplex.pon_e(k,j: integer; x:NComplex);
begin
	fila[k].pon_e(j, x );
end;

procedure TMatComplex.acum_e(k,j: integer; x:NComplex);
begin
	fila[k].acum_e(j, x );
end;


constructor TVectComplex.Create_Init(ne: integer);
begin
	inherited Create;
	setlength( v, ne+1 );
end;

constructor TVectComplex.Create_Load( var S: TStream );
var
	i, n: integer;
begin
	inherited Create;
	s.read(n, sizeOf(n));
	setlength( v, n+1 );
  for i:= 1 to n do
	  s.read( v[i], SizeOf(NComplex));
end;


constructor TVectComplex.Create_OnVarArray( var vc: TVarArrayOfComplex );
begin
   inherited Create;
   v:= vc;
end;

function TVectComplex.pte( k: integer ): PNComplex;
begin
	result:= @v[k];
end;

procedure TVectComplex.e(var res: NComplex; k:word);
begin
	res:=v[k];
end;

procedure TVectComplex.pon_e(k:word; var x:NComplex);
begin
	v[k]:= x;
end;

procedure TVectComplex.acum_e(k:word; var x:NComplex);
begin
	v[k]:= sc(v[k], x)^;
end;


function TVectComplex.Get_n: integer;
begin
	result:= length( v )-1;
end;

procedure TVectComplex.Set_n( nn: integer );
begin
	setlength( v, nn +1 );
end;


procedure TMatComplex.Ceros;
var
	k: integer;
begin
	for k:= 1 to nf do
		fila[k].Ceros;
end;
	 {
procedure TMatComplex.MinMax(
			var kMin, jMin:word;
			var kMax, jMax:word;
			var Min,  Max: NComplex);
var
	k, j: integer;
	m: NReal;
begin
	Min:=Complex(pte(1,1)^);
	Max:=Min;
	kmin:=1; jmin:=1; kmax:=1; jmax:=1;
	for k:= 1 to nf do
	begin
		for j:= 1 to nc do
		begin
			m:=Complex(pte(k,j)^);
			if mod2(m)<Min then
			begin
				kmin:=k;
				jmin:=j;
				min:=m;
			end
			else
			if m>Max then
			begin
				kmax:=k;
				jmax:=j;
				max:=m;
			end;
		end;
	end;
end;
	  }

procedure TMatComplex.CerosFila( kfil: integer);
begin
	fila[kfil].Ceros;
end;



procedure TVectComplex.Ceros;
var
	k:integer;
begin
	for k:= 0 to high(v) do
		v[k]:= Complex_Nulo;
end;

{

procedure TVectComplex.MinMax( var kMin, kMax: word; var Min, Max:NComplex);
var
	k:integer;
	p:pointer;
begin
	p:=pv;
	Min:= Complex(p^); kMin:=1;
	Max:= Complex(p^); kMax:=1;
	for k:= 1 to n do
	begin
		if Complex(p^)<min then
		begin
			Min := Complex(p^);
			kMin:=k
		end
		else
			if Complex(p^) > max then
			begin
				Max := Complex(p^);
				kMax:= k
			end;
		inc(p)
	end
end;
 }

{ res:= Self.*.cc(y) // ojo, lo que está escrito es res:= Self.*.y (no cc)}
procedure TVectComplex.PEV(var res: NComplex; var y :TVectComplex);
var
 k:integer;
 temp:NComplex;
begin
	temp:=complex_nulo;
	for k:=0 to length( v ) do
		temp:=sc(temp, pc(v[k], y.v[k])^)^;
	res:=temp
end;  (* PEV *)




function  TVectComplex.cond_epsilon(tol:NReal):Boolean;

var
	k:word;
	cond:boolean;

begin
	cond:=true;
	for k:=1 to n do
		if mod1( v[k]) >= tol then cond:=false;
	result:=cond;
end;


function  TVectComplex.cond_epsilonR(PX:TVectComplex;tol:NReal):Boolean;

var
	j: integer;
	cond:boolean;
	res1,res2: NComplex;


begin
	j:=0;
	cond:=true;
	if n<>PX.n then
		raise Exception.Create('los vectores deben ser de la misma dimension');
	while (j<n)and(cond=true) do
	begin
		j:=j+1;
		e(res1,j);
		PX.e(res2,j);
		if (mod1(res1)) >= (tol*mod1(res2)) then cond:=false;
	end;
	cond_epsilonR:=cond;
end;


procedure TVectComplex.mostrarvector;

var
	numel:word;
	k:integer;
	x: NComplex;

begin
	numel:=n;
	for k:=1 to numel do
	begin
		e(x,k);
		write(k);
		write(' ');
		wtxtcln(output,x,CA_Radianes);
	end;
end;



procedure TVectComplex.Copy(var a:TVectComplex);
var
	k: integer;
begin
	for k:= 1 to n do
		v[k]:=a.v[k];
end;


procedure TVectComplex.sum(var y:TVectComplex);
var
	k:integer;
begin
	for k:=0 to high( v) do
		v[k]:= sc( v[k], y.v[k] )^;
end;

procedure TVectComplex.sumvect(A,B:TVectComplex);
var
	k:integer;
begin
	for k:=0 to high( v) do
		v[k]:= sc( A.v[k], B.v[k] )^;
end;



procedure TVectComplex.sumComplexPV(var r:NComplex;var x:TVectComplex);
var
	k:integer;
begin
	for k:=0 to high( v ) do
		v[k]:= sc(v[k], pc(r,x.v[k])^)^;
end;


procedure TVectComplex.PorComplex( var r:NComplex);
var
	k:integer;
begin
	for k:=0 to high(v) do
		v[k]:=pc(v[k],r)^;
end;

function TVectComplex.ne2: NReal; {norma euclideana al cuadrado }
var
	k:integer;
	acum: NReal;
begin
	acum:=0;
	for k:= 0 to high( v ) do
		acum:=acum+mod2(v[k]);
	ne2:=acum;
end;

function TVectComplex.normEuclid:NReal;
begin
	normEuclid:=sqrt(ne2)
end;

function TVectComplex.normMaxAbs:NReal;
var
	k:integer;
	maxA:NReal;
begin
	maxA:=0;
	for k:= 0 to high(v) do
		if mod2(v[k])> maxA then
			maxA:= mod2(v[k]);
	normMaxAbs:= sqrt(maxA);
end;

function TVectComplex.normSumAbs:NReal;
var
	k:integer;
	acum:NReal;
begin
	acum:=0;
	for k:= 0 to high(v) do
		acum:=acum+sqrt(mod2(v[k]));
	normSumAbs:=acum;
end;

procedure TMatComplex.WriteM;
var
	k,j: integer;
	c: NComplex;
begin
	for k:= 1 to nf do
	begin
		write('f: ',k:4,') ');
		for j:= 1 to nc do
		begin
			e(c, k, j );
			wc(c);
			write(',');
		end;
		writeln;
	end;
end;


procedure TMatComplex.Escaler(var res: NComplex; var i:TMatComplex);
{$ifdef testdeter }
procedure muestre;
begin
	writeM;
	i.writeM;
	readln;writeln('===============');
end;
{$endif}

var
  k,p,j:integer;
  ptfp,ptfe: TVarArrayOfComplex;
  ptfpi,ptfei: TVarArrayOfComplex;

 det,mc1, mcoef:NComplex;

 m: NReal;
 n: integer;

begin
	n:= nf;
	p:=1; det:=numc(1,0)^;
	{esca1}
	while p<n do
	begin
		{$ifdef testdeter }
		muestre;
		{$endif}

// buscamos el mejor pivote en la columna p
// en las filas de p a n
		m:=mod2(fila[p].v[p]);
    j:=p;
		for k:=p+1 to n do
		begin
			if mod2(fila[k].v[p])>m then
			begin
				m:=mod2(fila[k].v[p]);
        j:=k
			end;
		end;
		if p<>j then
		begin
			IntercambieFilas(p,j);
			i.IntercambieFilas(p,j);
			det:=prc(-1, det)^;
		end;

		if m=0 then
		begin
			det:= complex_Nulo;
			p:=nf
		end
		else{eliminacion}
		begin
      ptfp:= fila[p].v;
      ptfpi:=i.fila[p].v;

			mc1:= ptfp[p];
			det:=pc(det,mc1)^;

			for k:=p+1 to nf do
			begin
        ptfe:= fila[k].v;
        ptfei:=i.fila[k].v;

				mcoef:=dc(ptfe[p],mc1)^;
				for j:=p+1 to nc do
					ptfe[j]:=rc(ptfe[j],pc(mcoef, ptfp[j])^)^;
				for j:=1 to i.nc do
					ptfei[j]:=rc(ptfei[j],pc(mcoef, ptfpi[j])^)^;
			end
		end;
		p:=p+1;
	end;(* while *)

	det:= pc(det, fila[n].v[n])^;

	if mod2(det) >AsumaCero then
	begin{esca2}
		for k:=1 to nf do
		begin
			{$ifdef testdeter }
			muestre;
			{$endif}
      ptfe:= fila[k].v;
      ptfei:=i.fila[k].v;

			mc1:= invc( ptfe[k])^;
			for j:=k+1 to nc do
				ptfe[j]:=pc(ptfe[j],mc1)^;
			for j:=1 to i.nc do
  			ptfei[j]:=pc(ptfei[j],mc1)^;
		end;

		for p:=nf downto 2 do
    begin
      ptfp:= fila[p].v;
      ptfpi:=i.fila[p].v;

      for k:=p-1 downto 1 do
      begin
        ptfe:= fila[k].v;
        ptfei:=i.fila[k].v;

        mc1:=Ncomplex(pte(k,p)^);
        for j:=1 to i.nc do
          ptfe[j]:=rc(ptfe[j],pc(ptfp[j],mc1)^)^;
      end;
    end;
	end;
	res:=det;
	{$ifdef testdeter }
	muestre;
	{$endif}
end {deter};


procedure TMatComplex.CopyColVect(var Y: TVectComplex; J: Integer);
var
	k:integer;
begin
	y:= TVectComplex.Create_init( nf );
	for k:= 1 to nc do
		y.v[k]:= fila[k].v[j];
end;  (* CopyColVect *)



procedure TMatComplex.Traza(var res:NComplex);
var
	 k:integer;
	temp:NComplex;
begin
	temp:=fila[1].v[1];
	for k:=2 to nf do
		temp := sc(temp, fila[k].v[k])^;
	res:=temp
end; (* Traza *)



procedure TMatComplex.Mult(a,b:TMatComplex);
var
	 k,j:integer;
	 v:TVectComplex;
	 mtemp:TMatComplex;

	 c: NComplex;

begin
	v:= TVectComplex.Create_Init(b.nf);
// copiamos la matriz A por si la modificamos
	mtemp:= Create_init(a.nf,a.nc);
	mtemp.copy(a);
	for j:=1 to A.nc do
	begin
		b.CopyColVect(v,j);
		for k:=1 to nf do
		begin
			v.PEV(c, mtemp.fila[k]);
			fila[k].v[j]:= c;
		end;
 end;
	mtemp.Free;
	v.Free;
end;

procedure TMatComplex.deter(var res:NComplex);
var
	temp1,temp2:TMatComplex;
	tmp: NComplex;
begin
	temp1:= TMatComplex.Create_init(nf,nc);
	temp1.copy(Self);
	temp2:= TMatComplex.Create_init(0,0);
	temp1.escaler(tmp, temp2);
	temp2.Free;
	temp1.Free;
	res:= tmp;
end;

procedure TMatComplex.inv;
var
	temp:TMatComplex;
	k,j:integer;
	aux: NComplex;
begin
	temp:= TMatComplex.Create_init(nf,nc);
	for k:=1 to nf do
		for j:=1 to nc do
			if k=j then
				pon_e(k,j, complex_UNO )
			else
				pon_e(k,j, complex_NULO );
	Self.escaler(aux, temp);
	Self.copy(temp);
	temp.Free;
end;

begin
(*
writeln('Unidad MatReal INSTALADA / RCH-90');
*)
end.