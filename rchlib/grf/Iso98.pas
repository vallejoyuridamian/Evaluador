{+doc
+NOMBRE:iso98
+CREACION:25.01.98
+AUTORES:rch
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO:Calculo de curvas iso-nivel
+PROYECTO:rchlib

+REVISION:
+AUTOR:
+DESCRIPCION:
	Es una modernizaci¢n del a ISO90.PAS para hacer un mejor uso
de la memoria.
-doc}

{RCh9/90----------------------------------------------------------
	La unidad iso90, fue pensada para generar las curvas iso-nivel
de un sierto campo escalar NReal, que llamaremos f(x,y) para la explicaci¢n.
	El procedimiento de construcci¢n de una curva de nivel, comienza
con la notificaci¢n a iso90 de la fuci¢n que representa al campo escalar
y de la manera en que quremos que la acseda. Para llevar a cabo dicha
notificaci¢n usamos:

procedure AnotarFunciones( ff:fkj; fx,fy:fk; nk,nj:integer; NNivel:NReal);

Los pr metros son:

	ff: Es una funci¢n externa, que le permite calcular a iso90
el valor del campo f correspondiente a f(fx[k],fy[j]).

	fx,fy: Son las funciones de "deformaci¢n", nos permiten lograr un
mapeo no uniforme de la ret¡cula de enteros sobre la que iso90 calcula,
sobre una regi¢n del plano (x,y).

	nk,nj: Definen la ret¡cula de c lculo. iso90 calcula el valor de f en
una matriz de nk * nj elementos siendo el elemento k,j el valor de f
correspondiente a,  x = fx[k],  e, y = fy[j]. Luego calculara la curva
de nivel sobre dicha matriz, extrapolando los puntos (x,y)
correspondientes a la intersecci¢n de la curva con el reticulado.

	NNivel: Es el nivel de la curva que queremos calcular. La curva
que se calcular  ser  la correspondiente a f(x,y) = NNivel


	Una vez inicializado iso90 con el procedimiento AnotarFunciones,
el procedimiento para obtener los puntos de la curva iso-nivel, es
pedir los puntos uno a uno por intermedio de la funci¢n:

	function GetPunto(var Prx:puntoReal):boolean;

	El punto calculado se devuelve en Prx, y si el resultado de GetPunto
------------------------------------------------------------------}
unit iso98;                {14/9/90/ RCh/ 9:30}
interface
uses
	horrores, xMatDefs;

type

	fkj = function(k,j:integer):NReal;
	fk = function(k:integer):NReal;

	puntoReal = record
		x,y:NReal;
		end;

	IsoScannerStateType = (fin, SemiActivo, Activo, Reversa);
var

	Estado : IsoScannerStateType;


function GetPunto(var Prx:puntoReal):boolean;

procedure AnotarFunciones( ff:fkj; fx,fy:fk; nk,nj:integer; NNivel:NReal);
procedure DoneISO98;

implementation

const
	maxmk = 3000;
	maxmj = 3000;


type
	puntoInt = record
		k,j:integer;
		end;


Type

	TLAB= array[1..3000] of byte;
	PLAB= ^TLAB;

	TMB= array[1..3000] of PLAB;
	PMB= ^TMB;

var
	Inicializada: boolean;
	CuentaPtr: PMB;
	nivel:NReal;
	OldExitProc: pointer;


	p1,p2:puntoInt;
	p1Inicial,p2Inicial:puntoInt;
	Pinicial,PR:puntoReal;

var
	f:fkj;
	x,y:fk;
	mk,mj:integer;


function Cuenta( k, j: integer ): integer;
begin
	Cuenta:= CuentaPtr^[k]^[j];
end;

{$IFDEF MemLog}
procedure MemLog( texto: string );
var
	f: text;
begin
	if Inicializada then Texto:= '[I]'+texto;
	assign( f, 'iso98.log');
	{$I-}
	append(f);
	{$I+}
	if ioresult <>0 then rewrite(f);
	writeln(f, texto+'( ',mk,' , ',mj, ') : MemAvail: ', MemAvail,' : MaxAvail: ', MaxAvail);
	close(f);
end;
{$ENDIF}

procedure DoneISO98;
var
	k: integer;
begin
{$IFDEF MemLog}
	MemLog( '>DoneISO98');
{$ENDIF}
	if Inicializada then
	begin
		Inicializada:= false;
		for k:= 1 to mk do
		begin
			FreeMem( CuentaPtr^[k], mj );
		end;
		FreeMem( CuentaPtr, sizeOf(Pointer)*mk );
	end;
{$IFDEF MemLog}
	MemLog( '<DoneISO98');
{$ENDIF}
end;

function Int2Str( k: integer): string;
var
	ts: string;
begin
	str(k, ts);
	Int2Str:= ts;
end;

procedure InitISO98( nk, nj: integer );
var
	k: integer;
begin
{$IFDEF MemLog}
	MemLog( '>InitISO98');
{$ENDIF}
	if Inicializada then DoneISO98;
	mk:=nk;mj:=nj;

	GetMem( CuentaPtr, sizeOf(Pointer)*nk );
	for k:= 1 to nk do
	begin
			GetMem( CuentaPtr^[k], nj );
	end;
	Inicializada:= true;
{$IFDEF MemLog}
	MemLog( '<InitISO98');
{$ENDIF}

end;

procedure AnotarFunciones( ff:fkj; fx,fy:fk; nk,nj:integer; NNivel:NReal);
begin
	if nk> maxmk then error(' iso98: maxmk superado');
	if nj> maxmj then error(' iso98: maxmj superado');
	InitISO98(nk, nj);
	Estado:=fin;
	f:=ff;x:=fx;y:=fy;
	nivel:=Nnivel;
end;

function CuentaPI(p:puntoInt):integer;
begin
	CuentaPI:=cuenta(p.k,p.j);
end;

function fPI(p:puntoInt):NReal;
begin
	fPI:=f(p.k,p.j);
end;


procedure BorreCuenta;
var
	k,j:integer;
begin
	for k:=1 to mk do
		for j:=1 to mj do
			cuentaPtr^[k]^[j]:=0;
end;

function pos(k,j:integer):boolean;
begin
	pos:=f(k,j)>nivel;
end;

procedure InitCuenta;
var
	k,j:integer;
	PosTrack:boolean;
begin
	BorreCuenta;
	for k:=1 to mk do
	begin
		PosTrack:=pos(k,1);
		for j:= 1 to mj-1 do
			if pos(k,j+1)<> PosTrack then
			begin
				inc(CuentaPtr^[k]^[j]);
				inc(CuentaPtr^[k]^[j+1]);
				PosTrack:=not PosTrack;
			end;
	end;
	for j:=1 to mj do
	begin
		PosTrack:=Pos(1,j);
		for k:=1 to mk-1 do
			if pos(k+1,j)<> PosTrack then
			begin
				inc(CuentaPtr^[k]^[j]);
				inc(CuentaPtr^[k+1]^[j]);
				PosTrack:= not PosTrack;
			end;
	end;
end;

function BuscaPrincipioCurva(var p:puntoInt):boolean;
label
	fin;
var
	k,j:integer;
begin
	for k:=1 to mk do
		for j:=1 to mj do
			if cuentaPtr^[k]^[j]>0 then
			begin
				p.k:=k;
				p.j:=j;
				BuscaPrincipioCurva:=true;
				goto fin
			end;
	BuscaPrincipioCurva:=false;
fin:
end;


function Corte(p1,p2:puntoInt; var prp:PuntoReal):boolean;
var
	f1,f2:NReal;
	landa:NReal;
	df: NReal;
begin
	f1:=fpi(p1);
	f2:=fpi(p2);
	df:= (f2-f1);
	if abs(df) > AsumaCero then   // agregado marzo2002 chequear decisión
	begin
		landa:=(nivel-f1)/(f2-f1);
		if (0<=landa)and(landa<=1) then
		begin
			Corte:=true;
			prp.x:=x(p1.k)+landa*(x(p2.k)-x(p1.k));
			prp.y:=y(p1.j)+landa*(y(p2.j)-y(p1.j));
			dec(CuentaPtr^[p1.k]^[p1.j]);
			dec(CuentaPtr^[p2.k]^[p2.j]);
		end
		else
			Corte:=false;
	end
	else
		Corte:= false;
end;

function AdyacenteCuentaPos(var P:puntoInt):boolean;
label
	FinTRUE,Fin;
var
	temp:boolean;

function rlt(k,j:integer):boolean;
begin
	rlt:=temp xor pos(k,j);
end;

begin
	temp:=pos(p.k,p.j);
	if (p.k>1)and(cuentaPtr^[p.k-1]^[p.j]>0)and rlt(p.k-1,p.j) then
	begin
		dec(p.k);
		goto finTRUE;
	end;
	if (p.k<mk)and(CuentaPtr^[p.k+1]^[p.j]>0)and rlt(p.k+1,p.j) then
	begin
		inc(p.k);
		goto finTRUE;
	end;
	if (p.j>1)and(CuentaPtr^[p.k]^[p.j-1]>0)and rlt(p.k,p.j-1) then
	begin
		dec(p.j);
		goto finTRUE;
	end;
	if (p.j<mj)and(CuentaPtr^[p.k]^[p.j+1]>0)and rlt(p.k,p.j+1) then
	begin
		inc(p.j);
		goto finTRUE;
	end;
	AdyacenteCuentaPos:=false; goto fin;
finTRUE:
	AdyacenteCuentaPos:=true;
fin:
end;

{---------------------------------------------------------
	Dado el segmento orientado P1P2, esta funci¢n devuelve
P3 = rot(P2-P1, 90 grados antihorario) + P2
	Si el resulatado es true, el punto P3 corresponde a un
elemento de la matriz, si SDI = false, el punto P3 se sale
de la matriz
-------------------------------------------------------}


function SDI(var P1,P2,P3:puntoInt):boolean;
begin
	P3.k:=P2.k-(P2.j-P1.j);
	P3.j:=P2.j+(P2.k-P1.k);
	if (P3.k<1)or(p3.k>mk)or(p3.j<1)or(p3.j>mj)
	then
		SDI:=false
	else
		SDI:=true;
end;


{--------------------------------------------------------------
Entradas:
Por P1P2, indicamos cual es el segmento de entrada a un cuadro.
Salidadas:
	P1P2, Segmento de salida del cuadro.
	SegInterior, Si es TRUE, el segmento no es borde de la matriz.
	SegmentoSalida, es TRUE si encontr¢ un segmento de salida.

Cuando SegmentoSalida = TRUE, P1P2 es el segmento de salida,
Si SegmentoSalida = FALSE, Con SegInterior sabemos porque no
se encontro un segmento de salida
--------------------------------------------------------------}


function SegmentoSalida(var p1,p2: PuntoInt; var SegInterior:boolean):boolean;
var
	cont:integer;
	p3:puntoInt;

function SegSal:boolean;
begin
	inc(cont);
	SegInterior:=SDI(p1,p2,p3);
	if not SegInterior then SegSal := false
	else
		begin
			if (cuentaPI(p3)>0)and(cuentaPI(p2)>0)and
				((fpi(p3)-nivel)*(fpi(p2)-nivel)<=0) then
			begin
				p1:=p3;
				SegSal:=true
			end
			else
				if cont<3 then
				begin
					p1:=p2;p2:=p3;
					SegSal:=SegSal;
				end
				else SegSal:=false
		end;
end;

begin
	cont:=0;
	SegmentoSalida:=SegSal;
end;




function BuscaSegmentoInicial(var p1,p2:puntoInt):boolean;
begin
	if BuscaPrincipioCurva(p1) then
	begin
		p2:=p1;
		BuscaSegmentoInicial:=AdyacenteCuentaPos(p2);
	end
	else
		BuscaSegmentoInicial:=false;
end;



function IniciarPoligonal:boolean;
var
	res:boolean;
begin
	res:=BuscaSegmentoInicial(p1,p2);
	if res then
	begin
		res:=Corte(p1,p2,pr);
		Pinicial:=PR;
		p1Inicial:=p1;
		p2Inicial:=p2;
		Estado:=activo;
	end
	else
	begin
		res:=false;
		Estado:=fin;
	end;
	IniciarPoligonal:=res;
end;


function IniciarTodo:boolean;
var res:boolean;
begin
	InitCuenta;
	IniciarTodo:=IniciarPoligonal;
end;

function BusquedaActiva:boolean;
var
	res1,SegInter:boolean;
begin
	res1:=SegmentoSalida(p1,p2,SegInter);
	if res1 then BusquedaActiva:=Corte(p1,p2,PR)
	else
		if SegInter then
		begin
			PR:=Pinicial;
			BusquedaActiva:=true;
			Estado:=Semiactivo;
		end
		else
		begin
			if estado= Reversa then
				begin
					BusquedaActiva:=false;
					Estado:=SemiActivo;
				end
			else
			begin
				p1:=p2Inicial;
				p2:=p1Inicial;
				BusquedaActiva:=Corte(p1,p2,pr);
				inc(cuentaPtr^[p1.k]^[p1.j]);
				inc(cuentaPtr^[p2.k]^[p2.j]);
				Estado := Reversa
			end
		end;
end;


function GetPunto(var prx:puntoReal):boolean;
var
	res0:boolean;

begin
	case Estado of
		fin: res0:=IniciarTodo;
		SemiActivo: res0:=IniciarPoligonal;
		Activo: res0:=BusquedaActiva;
		Reversa:
		begin
			res0:=BusquedaActiva;
			if res0 then Estado:=Activo;
		end;
	end;
	PRX:=Pr;
	GetPunto:=res0;
end;

procedure AlFinal; far;
begin
	ExitProc:= OldExitProc;
	if Inicializada then DoneISO98;
end;

procedure AlInicio;
begin
	OldExitProc:= ExitProc;
	ExitProc:= @AlFinal;
	Inicializada:= false;
end;


begin
	AlInicio;

end.