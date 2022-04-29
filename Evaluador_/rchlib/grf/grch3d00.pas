{+doc
+NOMBRE: grch3d00
+CREACION:6.9.90
+AUTORES:rch
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO: encabezamiento estandar
+PROYECTO: Graficador en 3 dimensiones.

+REVISION:
+AUTOR:
+DESCRIPCION:
-doc}

{  8:45 a 13:05   6/9/90     RCh  }
{ 	14:57 a ...    6/9/90     }

unit grch3d00;

interface
	uses graph, traxp;

type


	Punto = object
		x,y,z:real;
		procedure SetPunto(x0,y0,z0:real);
		procedure Resta(var xp:punto);
		procedure Suma(var xp:Punto);
		function Escalar(var xp:Punto):real;
		procedure Vectorial(var a:Punto);
		procedure PorReal(r:real);
		procedure versor;
	end;

	CuboVision = object
		P1,P2:Punto;
			{ Se consireda un Poliedro rectangular de lados paralelos }
			{ a los ejes de cooordenadas, cuyo vertice mas pr¢ximo al }
			{ al origen es P1 y el m s lejano es P2 }

		function RecorteLinea(var LP1,LP2:Punto):boolean;
			{Devuelve True si parte del segmento LP1-LP2 pertenece al cubo}
			{En LP1,LP2 devuelve el segmento que pertenece al cubo        }
			{Si el resultado es false, es segmento es exterior al cubo  }

		procedure definaX(x0,x1:real);
		procedure definaY(y0,y1:real);
		procedure definaZ(z0,z1:real);
	end;

	trazo3d = object(CuboVision)
		gridx,gridy,gridz:integer;
		ColorFondo,ColorGrid,ColorTrazo,ColorAux,ColorEjes:integer;
		Diru:Punto;
		Dira,Dirb:Punto;
		canal:integer;
		constructor Init;
		procedure asigneCanal(kanal:integer);
		procedure trazo(px,py,pz:real);
		procedure trz(p:punto);
		procedure definadireccion(dirx,diry,dirz:real);
		procedure encuadre;
		procedure GridXY;
		procedure GridYZ;
		procedure GridZX;
	end;

implementation


const
	vi:punto = (x:1;y:0;z:0);
	vj:punto = (x:0;y:1;z:0);
	vk:punto = (x:0;y:0;z:1);




{------------------------------------------
m‚todos de "Punto" :
--------------------------------------------}


procedure Punto.SetPunto;
begin
	x:=x0;
	y:=y0;
	z:=z0
end;

procedure Punto.Suma(var xp:Punto);
begin
	x:= x + xp.x;
	y:= y + xp.y;
	z:= z + xp.z;
end;

procedure Punto.Resta(var xp:Punto);
begin
	x:=x-xp.x;
	y:=y-xp.y;
	z:=z-xp.z
end;

function Punto.Escalar(var xp:Punto):real;
var
	temp:real;
begin
	temp:=x*xp.x;
	temp:=temp+y*xp.y;
	temp:=temp+z*xp.z;
	Escalar:=temp
end;

procedure Punto.Vectorial(var a:Punto);
var
	temp:punto;
begin
	temp.x:=-z*a.y+y*a.z;
	temp.y:=z*a.x-x*a.z;
	temp.z:=-y*a.x+x*a.y;
	self:=temp;
end;




procedure Punto.PorReal(r:real);
begin
	x:=x*r;
	y:=y*r;
	z:=z*r;
end;

procedure Punto.versor;
var
	temp:real;
begin
	temp:=self.escalar(self);
	self.PorReal(1/sqrt(temp));
end;




{---------------------------------------
M‚todos de CuboVision:
----------------------------------}

function CuboVision.RecorteLinea(var LP1,LP2:Punto):boolean;
var
	res:boolean;


function Semiplano(var Pbase,dir:Punto;signo:integer):boolean;
var
	temp:punto;
	a1,a2,landa:real;

begin
	temp:=Pbase;
	temp.resta(Lp1);
	a1:=-temp.Escalar(dir);
	temp:=Pbase;
	temp.resta(Lp2);
	a2:=-temp.Escalar(dir);
	if (a1>0)and(a2>0) then Semiplano :=true
	else
		if (a1<0)and(a2<0) then Semiplano:=false
		else
			begin
				Semiplano:=true;
				if a1<>a2 then
					begin
					landa:=(Pbase.Escalar(dir)-a1)/(a2-a1);
					temp:=lp2;
					temp.resta(lp1);
					temp.PorReal(landa);
					temp.suma(lp1);
					if a1<0 then lp1:=temp
					else lp2:=temp;
					end
			end
end;


begin
	RecorteLinea:=false;
	if SemiPlano(P1,vi,+1) then
		if Semiplano(P1,vj,+1) then
			if Semiplano(P1,vk,+1) then
				if Semiplano(P2,vi,-1) then
					if Semiplano(P2,vj,-1) then
						if Semiplano(P2,vk,-1) then
							RecorteLinea:=true;
end;



procedure CuboVision.definaX;
begin
	p1.x:=x0;
	p2.x:=x1;
end;
procedure CuboVision.definaY;
begin
	p1.y:=y0;
	p2.y:=y1;
end;
procedure CuboVIsion.definaZ;
begin
	p1.z:=z0;
	p2.z:=z1
end;

{------------------------------------
metodos de trazo3D
------------------------------------}
constructor trazo3d.Init;
begin
	ColorEjes:=Negro;
	ColorGrid:=marron;
	ColorAux:=GrisClaro;
	ColorTrazo:=Amarillo;
	ColorFondo:=Celeste;
	gridx:=5;
	gridy:=5;
	gridz:=5;
	DirU.Setpunto(0,0,0);
	p1.setpunto(0,0,0);
	p2.setpunto(0,0,0);
	Canal:=-1;
end;


procedure trazo3d.asigneCanal(kanal:integer);
var
	k:integer;
	ap:array[1..8] of punto;
	ppmin,ppmax:punto;
	temp:real;


begin
	canal:=kanal;
	If (p1.escalar(p1)=0)and(p2.escalar(p2)=0) then
		 writeln('Error trazo3D no inicializado');
	{cara inferior }
	borreCanal(Canal,ColorFondo);
	ap[1]:=p1;
	ap[2]:=ap[1];ap[2].x:=p2.x;
	ap[3]:=ap[2];ap[3].y:=p2.y;
	ap[4]:=ap[3];ap[4].x:=p1.x;
	{cara superior }
	for k:=5 to 8 do
		begin
			ap[k]:=ap[k-4];
			ap[k].z:=p2.z
		end;
	dira:=diru;
	dira.vectorial(vk);
	dira.versor;
	dirb:=dira;
	dirb.vectorial(diru);
	ppMin.x:=ap[1].escalar(dira);
	ppmax.x:=ppmin.x;
	ppmin.y:=ap[1].escalar(dirb);
	ppmax.y:=ppmin.y;
	for k:=2 to 8 do
		begin
			temp:=ap[k].escalar(dira);
			if temp<ppmin.x then ppmin.x:=temp
			else if temp>ppmax.x then ppmax.x:=temp;
			temp:=ap[k].escalar(dirb);
			if temp<ppmin.y then ppmin.y:=temp
			else if temp>ppmax.y then ppmax.y:=temp;
		end;


	traxp.definax(kanal,ppmin.x,(ppmax.x-ppmin.x)/traxp.gridx);
	traxp.definay(kanal,ppmin.y,(ppmax.y-ppmin.y)/traxp.gridy);
end;






procedure trazo3d.trazo(px,py,pz:real);
var
	temp:punto;
begin
	temp.x:=px;
	temp.y:=py;
	temp.z:=pz;
	DefinaColor(canal,ColorTrazo);
	trz(temp);
	desligue(canal);
	DefinaColor(canal,ColorAux);
	temp.z:=p1.z;
	trz(temp);
	temp.z:=pz;
	trz(temp)
end;

procedure trazo3d.trz(p:punto);
begin
	traxp.trazoXY(canal,p.escalar(dira),p.escalar(dirb));
end;

procedure trazo3d.encuadre;
var
	pt:punto;
begin
	Desligue(canal);
	DefinaColor(canal,ColorEjes);
	pt:=p1;

	trz(pt);
	pt.y:=p2.y;
	trz(pt);
	pt.x:=p2.x;
	trz(pt);
	pt.y:=p1.y;
	trz(pt);
	pt.x:=p1.x;
	trz(pt);
	pt.z:=p2.z;
	trz(pt);

	Desligue(0);
	DefinaCOlor(0,white);
end;


procedure trazo3d.definadireccion;

begin
	diru.x:=dirx;
	diru.y:=diry;
	diru.z:=dirz;
	diru.versor;
end;

procedure trazo3D.GridXY;
var
	k:integer;
	d:real;
	ptemp:punto;

begin
desligue(canal);
definaColor(canal,ColorGrid);
d:=(p2.x-p1.x)/gridx;
ptemp:=p1;
for k:= 1 to gridx do
	begin
	ptemp.x:=p1.x+k*d;
	desligue(canal);
	ptemp.y:=p1.y;
	trz(ptemp);
	ptemp.y:=p2.y;
	trz(ptemp);
	end;
d:=(p2.y-p1.y)/gridy;
ptemp:=p1;
for k:=1 to gridy do
	begin
	ptemp.y:=p1.y+k*d;
	desligue(canal);
	ptemp.x:=p1.x;
	trz(ptemp);
	ptemp.x:=p2.x;
	trz(ptemp);
	end;
end;


procedure trazo3d.GridYZ;
var
	k:integer;
	d:real;
	ptemp:punto;

begin
desligue(canal);
definaColor(canal,ColorGrid);
d:=(p2.y-p1.y)/gridy;
ptemp:=p1;
for k:= 1 to gridy do
	begin
	desligue(canal);
	ptemp.y:=p1.y+k*d;
	ptemp.z:=p1.z;
	trz(ptemp);
	ptemp.z:=p2.z;
	trz(ptemp);
	end;
d:=(p2.z-p1.z)/gridz;
for k:=1 to gridz do
	begin
	ptemp:=p1;
	ptemp.z:=p1.z+k*d;
	desligue(canal);
	ptemp.y:=p1.y;
	trz(ptemp);
	ptemp.y:=p2.y;
	trz(ptemp);
	end;
end;

procedure trazo3d.GridZX;
var
	k:integer;
	d:real;
	ptemp:punto;

begin
desligue(canal);
definaColor(canal,COlorGrid);
d:=(p2.z-p1.z)/gridz;
ptemp:=p1;
for k:= 1 to gridz do
	begin
	ptemp.z:=p1.z+k*d;
	desligue(canal);
	ptemp.x:=p1.x;
	trz(ptemp);
	ptemp.x:=p2.x;
	trz(ptemp);
	end;

d:=(p2.x-p1.x)/gridx;
ptemp:=p1;
for k:=1 to gridx do
	begin
	ptemp.x:=p1.x+k*d;
	desligue(canal);
	ptemp.z:=p1.z;
	trz(ptemp);
	ptemp.z:=p2.z;
	trz(ptemp);
	end;
end;


end.
