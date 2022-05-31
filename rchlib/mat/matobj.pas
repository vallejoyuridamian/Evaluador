
{-----------------------------------------------------  RCH/90  --
 Ing. Ruben Chaer                                      M.E.E.P.
 Dpto. Maquinas Electricas y Electronica de Potencia
 Av. J. Herrera y Reissig No 565
------------------------------------------------------------------}

{+doc
+NOMBRE: MatObj
+CREACION: 1.4.1990
+AUTORES: rch
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO: Definición de objetos abstractos TVect y TMat
+PROYECTO: rchlib

+REVISION: 9.02.93. Se implemento lo necesario para salvarlos
usando TStream.

+AUTOR:
+DESCRIPCION:

-doc}


unit MatObj;
interface
uses
	Objects, Horrores;

type


PVect = ^TVect;
TVect=object(TObject)
	n,tam:word;
	pv:pointer;
	constructor Init(ne,te:word);
	constructor Ventana( ne, xtam: word; var x );
	constructor Load(var arch:TStream);
	procedure Store(var arch:TStream); virtual;
	procedure Print; virtual;
	function pte(k:word):pointer; 
	procedure inc(var p:pointer); 
	procedure dec(var p:pointer); 
	procedure igual(var x:TVect); 
	destructor Done; virtual;
	function IndiceEnRango( k: word ): boolean;
	function IndiceDe( p: pointer ): word;
	procedure SHLnk( nk: integer );
	procedure SHRnk( nk: integer );
	procedure SHLX(var X);
	procedure SHRX(var X);
	procedure Intercambiar( var X: TVect );
end;


const
  RVect: TStreamRec = (	 ObjType: 4003;
	 VmtLink: Ofs(TypeOf(TVect)^);
	 Load:    @TVect.Load;
	 Store:   @TVect.Store
	);

type
PMat = ^TMat;
TMat=object(TVect)
	nf,nc:word;
	constructor Init(filas,columnas,BytesPorElemento:word);
	constructor Load(var s: TStream);
	procedure Store(var s: TStream); virtual;

	function pte(k,j:word):pointer;
	procedure incol(var p:pointer);
	procedure decol(var p:pointer);
	procedure IntercambieFilas(k,j:word);
	procedure igual(var x:TMat);
	destructor Done; virtual;
	function IndiceEnRangoColumnas( j: word ): boolean; virtual;
	function pFila( fila: integer ): pointer; virtual;
	procedure Trasponer;
end;

const
  RMat: TStreamRec = (	 ObjType: 4004;
	 VmtLink: Ofs(TypeOf(TMat)^);
	 Load:    @TMat.Load;
	 Store:   @TMat.Store
	);

procedure RegisterMatObj;
implementation


procedure RegisterMatObj;
begin
	RegisterType(RVect);
	RegisterType(RMat);
end;

constructor TVect.Init(ne,te:word);
begin
 n:=ne; tam:=te;
 if MaxAvail >  n*tam then GetMem(pv,n*tam)
 else error('No hay suficiente memoria');
end;

procedure TVect.Intercambiar( var X: TVect );
var
	t: pointer;
begin
	t:= pv;
	pv:= X.pv;
	X.pv:= t;
end;

constructor TVect.Ventana( ne, xtam: word; var x );
begin
	tam:= xtam;
	n:= ne;
	pv:= @x;
end;

constructor TVect.Load(var arch:TStream);
begin
	arch.Read(n,SizeOf(word));
	arch.Read(tam,SizeOf(word));
	if MaxAvail > n*tam then 	GetMem(pv, n*tam)
	else error(' No hay suficiente memoria ');
	arch.Read(pv^,n*tam);
end;


procedure TVect.Store(var arch: TStream);
begin
	arch.write(n,SizeOf(word));
	arch.write(tam,SizeOf(word));
	arch.write(pv^,n*tam);
end;



procedure TVect.Print;
begin
	writeln('TVect /n= ',n,'  /tam= ',tam);
end;

procedure TVect.igual;
begin
	move(x.pv^,pv^,n*tam);
end;


procedure TVect.SHLnk( nk: integer );
var
	p: pointer;
begin
	if nk < n then
	begin { mov }
		p:= pte(nk+1);
		move(p^, pv^, (n-nk)*tam );
	end;
	p:= pte(n-nk);
	fillchar(p^, nk*tam, #0);
end;


procedure TVect.SHLX(var X);
var
	p: pointer;
begin
	p:= pte(2);
	move(p^, pv^, (n-1)*tam );
	p:= pte(n-1);
	move(X, p^, tam);
end;


procedure TVect.SHRnk( nk: integer );
var
	p: pointer;
begin
	if nk < n then
	begin { mov }
		p:= pte(nk+1);
		move(pv^,p^, (n-nk)*tam );
	end;
	fillchar(pv^, nk*tam, #0);
end;


procedure TVect.SHRX(var X);
var
	p: pointer;
begin
	p:= pte(2);
	move(pv^,p^, (n-1)*tam );
	move(X, pv^, tam);
end;




function TVect.pte(k:word):pointer;
var
temp:^word;
temp2:pointer;
begin
 Temp2:=pv;
 Temp:=@temp2;
 Temp^:=Temp^+(k-1)*tam;
 pte:=Temp2
end;

function TVect.IndiceDe( p: pointer ): word;
var
	DistByte:word;
begin        
	DistByte:= Ofs(p^)- Ofs(pv^);
	IndiceDe:=  (DistByte div tam ) +1;
end;
	



procedure TVect.inc(var p:pointer);
var
temp:^word;
begin
 Temp:=@p;
 Temp^:=Temp^+tam;
end;

procedure TVect.dec(var p:pointer);
var
temp:^word;
begin
 Temp:=@p;
 Temp^:=Temp^-tam;
end;


destructor TVect.Done;
begin
	FreeMem(pv,n*tam);
end;

function TVect.IndiceEnRango( k: word ): boolean;
begin
	if (k<1) or (k>n) then IndiceENRango:= false
	else IndiceEnRango:= true;
end;


constructor TMat.Init;
var
temp:pointer;
k:word;
begin
 nf:=filas;nc:=columnas;
 TVect.Init(nf,sizeOf(TVect));
 temp:=pv;
 for k:=1 to nf do
	begin
	 TVect(temp^).Init(nc,bytesPorElemento);
	 inc(temp);
	end;
end;

procedure TMat.Trasponer;
var
	tmp: TMat;
	k, j: integer;
begin
	tmp.Init( nc, nf , TVect(TVect.pte(1)^).tam);
	for k:= 1 to nf do
		for j:= 1 to nc do
			system.move( pte(k,j)^, tmp.pte(j,k)^, TVect(TVect.pte(1)^).tam );
	done;
	Self:= tmp;
end;




constructor TMat.Load( var s: TStream);
var
	temp:pointer;
	k:word;
begin
	s.Read(nf, SizeOf(nf));
	s.Read(nc, SizeOf(nc));
	TVect.Init(nf,sizeOf(TVect));
	temp:=pv;
	for k:=1 to nf do
	begin
		TVect(temp^).Load(s);
		inc(temp);
	end;
end;

procedure TMat.Store( var s: TStream);
var
	temp:pointer;
	k:word;
begin
	s.Write(nf, SizeOf(nf));
	s.Write(nc, SizeOf(nc));
	temp:=pv;
	for k:=1 to nf do
	begin
		TVect(temp^).Store(s);
		inc(temp);
	end;
end;



procedure TMat.igual;
var
px,p:pointer;
k:word;
begin
 p:=pv;px:=x.pv;
 for k:=1 to nf do
	begin
	 TVect(p^).igual(TVect(px^));
	 inc(p);x.inc(px);
	end;
end;


function TMat.pte(k,j:word):pointer;

begin
 pte:=TVect(TVect.pte(k)^).pte(j)
end;


procedure TMat.incol(var p:pointer);
begin
 TVect(pv^).inc(p);
end;

procedure TMat.decol(var p:pointer);
begin
 TVect(pv^).dec(p)
end;

procedure TMat.IntercambieFilas(k,j:word);
var
temp:pointer;
begin
temp:=TVect(TVect.pte(k)^).pv;
TVect(TVect.pte(k)^).pv:=TVect(TVect.pte(j)^).pv;
TVect(TVect.pte(j)^).pv:=temp;
end;

destructor TMat.Done;
var
temp:pointer;
k:word;
begin
 temp:=pv;
 for k:=1 to nf do
	begin
	 TVect(temp^).done;
	 inc(temp);
	end;
 TVect.Done;
end;

function TMat.IndiceEnRangoColumnas( j: word ): boolean;
begin
	if (j<1) or (j>nc) then IndiceEnRangoColumnas:=false
	else IndiceEnRangoColumnas:= true;
end;

function TMat.pFila( fila: integer ): pointer;
begin
	pFila:=TVect.pte(fila);
end;

begin
end.
