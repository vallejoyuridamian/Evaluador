{+doc
+NOMBRE: filed
+CREACION:
+AUTORES:rch
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO: Def.campos ValorReal y ValorEntero
+PROYECTO: grafcrt

+REVISION:
+AUTOR:
+DESCRIPCION:
-doc}

unit field;

interface

 uses
	 GrafCrt,Gr,BSPoint,CMPS,Archivos;

	Type


		ValorReal = object(Campo)
			 n:integer;
			 d:integer;
			 e:boolean;
			 VarPtr:^Real;

			 Procedure Show;virtual;
			 Procedure Hide;virtual;
			 Constructor Load(var f:archivo);
			 Destructor Done;virtual;
			 Procedure Save(var f:archivo);virtual;
			 Procedure Edit;virtual;
			 Constructor Init(zxp,zyp,zcolor,zn,zd:integer;NotCien:boolean);
			 Procedure Run;virtual;
			 procedure marcar;virtual;
			 procedure desmarcar;virtual;
			 Procedure SetVarReal(var x:real);
			 Constructor InitDefault(zpx,zpy:integer);
		 end;

	ValorEntero = object(Campo)
			 n:integer;
			 VarPtr:^Integer;
			 Procedure Show;virtual;
			 Procedure Hide;virtual;
			 Constructor Load(var f:archivo);
			 Destructor Done;virtual;
			 Procedure Save(var f:archivo);virtual;
			 Procedure Edit;virtual;
			 Constructor Init(zxp,zyp,zcolor,zn:integer);
			 Procedure Run;virtual;
			 procedure marcar;virtual;
			 procedure desmarcar;virtual;
			 Procedure SetVarInteger(var x:integer);
			 Constructor InitDefault(zpx,zpy:integer);
		 end;




implementation

const
	rxr:real = 16.1234567;
	exe:integer = 10000;

{Metodos de ValorReal}

Constructor ValorReal.Init(zxp,zyp,zcolor,zn,zd:integer;NotCien:boolean);
begin
	BasePoint.Init(zxp,zyp);
	SetColor(zcolor);
	n:=zn;
	d:=zd;
	e:=NotCien;
	Visible:=False;
	VarPtr:=@rxr;
end;

procedure ValorReal.Show;
var
	EP:Point;
	Xchar,Ychar:integer;
	sx:string;
	cv:word;
begin
	EP:=P;
	if not visible then
	begin
		cv:=VentanaActivaPtr^.ColorTinta;
		VentanaActivaPtr^.tinta(Color);
		Str(varPtr^:n:d,sx);
		Xchar:=EP.x div VentanaActivaPtr^.anch + 1;
		Ychar:=EP.y div VentanaActivaPtr^.alt + 1;
		VentanaActivaPtr^.WriteStrXY(Xchar,Ychar,sx);
		VentanaActivaPtr^.Tinta(cv);
		Visible:=true
	end
end;

procedure ValorReal.marcar;
var
	cc,cp,ct:word;

begin
	Hide;
	cp:=VentanaActivaPtr^.ColorPapel;
	ct:=VentanaActivaPtr^.ColorTinta;
	VentanaActivaPtr^.Papel(Color);
	cc:=color;
	color:=cp;
	Show;
	Color:=cc;
	VentanaActivaPtr^.Papel(cp);
	VentanaActivaPtr^.Tinta(ct);
end;

procedure ValorReal.desmarcar;
var
	cc,cp,ct:word;

begin
	cp:=VentanaActivaPtr^.ColorPapel;
	ct:=VentanaActivaPtr^.ColorTinta;
	VentanaActivaPtr^.Papel(Color);
	cc:=color;
	color:=cp;
	Hide;
	Color:=cc;
	VentanaActivaPtr^.Papel(cp);
	VentanaActivaPtr^.Tinta(ct);
	Show;
end;


procedure ValorReal.Hide;
var
	t:VPType;
	x0,y0:integer;
begin
	if visible then
	begin
      x0:= p.x div VentanaActivaPtr^.anch +1;
		y0:= p.y div VentanaActivaPtr^.alt +1;
		with VentanaActivaPtr^ do
		begin
			ExtentABS(t,x0,y0,x0+n-1,y0); {11/8/91 agrage el -1}
			t.Clear(ColorPapel);
		end;
		visible:=false;
	end
end;



constructor ValorReal.Load(var f:archivo);
begin
	Campo.Load(f);
	f.read(n,2);
	f.read(d,2);
	f.read(e,1);

	varPtr:=@rxr;
end;

destructor ValorReal.Done;
begin
	Campo.Done;
end;

procedure ValorReal.Save(var f:archivo);
begin
	Campo.Save(f);
	f.write(n,2);
	f.write(d,2);
	f.write(e,1);
end;


procedure ValorReal.Edit;
var
	x:string;
	Xa,Ya:integer;

begin
	BasePoint.Edit;
	Show;
	str(rxr:n:d,x);

	Xa:=p.x div VentanaActivaPtr^.anch+1;
	Ya:=p.y div VentanaActivaPtr^.alt +1;

	VentanaActivaPtr^.gotoXY(Xa,Ya);
	VentanaActivaPtr^.Readln(x);

	{Analizo String}

	e:=False;
	n:=length(x);
	if pos('.',x)>0 then
		d:=n - Pos('.',x)
	else d:=0;

	If (Pos('e',x) >0) or (Pos('E',x) >0) then
	begin
		e:=true;
		d:=Pos('e',x) + Pos('E',x) - Pos('.',x) - 1;
	end;
end;

Procedure ValorReal.Run;
var
	Xa,Ya:integer;
	s:string;
	code:integer;
	TipoCursor:CursorType;

begin
	Str(VarPtr^:n:d,s);
	Xa:=p.x div VentanaActivaPtr^.anch+1;
	Ya:=p.y div VentanaActivaPtr^.alt +1;

	repeat
	with VentanaActivaPtr^ do
		 begin
			 TipoCursor:=CurTipo;
			 InsMode:=true;
			 CurTipo:=Chico;
			 gotoXY(Xa,Ya);
			 Readln(s);
			 CurTipo:=TipoCursor;
		 end;

	Val(s,VarPtr^,code);

	until code = 0;
end;

Procedure ValorReal.SetVarReal(var x:real);
begin
	VarPtr:=@x;
end;

Constructor ValorReal.InitDefault(zpx,zpy:integer);
begin
	n:=6;
	d:=3;
	BasePoint.Init(zpx,zpy);
	varPtr:=@rxr;
end;

Constructor ValorEntero.Init(zxp,zyp,zcolor,zn:integer);
begin
	BasePoint.Init(zxp,zyp);
	SetColor(zcolor);
	n:=zn;
	Visible:=False;
	VarPtr:=@exe;
end;

procedure ValorEntero.Show;
var
	EP:Point;
	Xchar,Ychar:integer;
	sx:string;
	cv:word;
begin
	EP:=P;
	if not visible then
	begin
		cv:=VentanaActivaPtr^.ColorTinta;
		VentanaActivaPtr^.tinta(Color);
		Str(varPtr^:n,sx);
		Xchar:=EP.x div VentanaActivaPtr^.anch + 1;
		Ychar:=EP.y div VentanaActivaPtr^.alt + 1;
		VentanaActivaPtr^.WriteStrXY(Xchar,Ychar,sx);
		VentanaActivaPtr^.Tinta(cv);
		Visible:=true
	end
end;

procedure ValorEntero.marcar;
var
	cc,cp,ct:word;

begin
	Hide;
	cp:=VentanaActivaPtr^.ColorPapel;
	ct:=VentanaActivaPtr^.ColorTinta;
	VentanaActivaPtr^.Papel(Color);
	cc:=color;
	color:=cp;
	Show;
	Color:=cc;
	VentanaActivaPtr^.Papel(cp);
	VentanaActivaPtr^.Tinta(ct);
end;

procedure ValorEntero.desmarcar;
var
	cc,cp,ct:word;

begin
	cp:=VentanaActivaPtr^.ColorPapel;
	ct:=VentanaActivaPtr^.ColorTinta;
	VentanaActivaPtr^.Papel(Color);
	cc:=color;
	color:=cp;
	Hide;
	Color:=cc;
	VentanaActivaPtr^.Papel(cp);
	VentanaActivaPtr^.Tinta(ct);
	Show;
end;


procedure ValorEntero.Hide;
var
	t:VPType;
	x0,y0:integer;
begin
	if visible then
	begin
		x0:= p.x div VentanaActivaPtr^.anch +1;
		y0:= p.y div VentanaActivaPtr^.alt +1;
		VentanaActivaPtr^.ExtentABS(t,x0,y0,x0+n-1,y0); {11/8/91 agreg‚ el -1}
		t.Clear(VentanaActivaPtr^.ColorPapel);
		visible:=false;
	end
end;



constructor ValorEntero.Load(var f:archivo);
begin
	Campo.Load(f);
	f.read(n,2);

	varPtr:=@exe;
end;

destructor ValorEntero.Done;
begin
	Campo.Done;
end;

procedure ValorEntero.Save(var f:archivo);
begin
	Campo.Save(f);
	f.write(n,2);
end;


procedure ValorEntero.Edit;
var
	x:string;
	Xa,Ya:integer;

begin
	BasePoint.Edit;
	Show;
	str(exe:n,x);
	Xa:=p.x div VentanaActivaPtr^.anch+1;
	Ya:=p.y div VentanaActivaPtr^.alt +1;
	with VentanaActivaPtr^ do
	begin
		gotoXY(Xa,Ya);
		Readln(x);
	end;
	n:=length(x);
end;


Procedure ValorEntero.Run;
var
	Xa,Ya:integer;
	s:string;
	code:integer;
	OldCurType:CursorType;
begin
	Str(VarPtr^:n,s);
	Xa:=p.x div VentanaActivaPtr^.anch+1;
	Ya:=p.y div VentanaActivaPtr^.alt +1;
	repeat
		with VentanaActivaPtr^ do
		begin
			OldCurType:=CurTipo;
			CurTipo:=Chico;
			InsMode:=True;
			gotoXY(Xa,Ya);
			Readln(s);
			CurTipo:=OldCurType;
		end;
		Val(s,VarPtr^,code);
	until code = 0;
end;

Procedure ValorEntero.SetVarInteger(var x:integer);
begin
	VarPtr:=@x;
end;

Constructor ValorEntero.InitDefault(zpx,zpy:integer);
begin
	n:=6;
	BasePoint.Init(zpx,zpy);
	varPtr:=@exe;
end;

end.