unit LectFile;
interface
type
	FOC = file of char;



function RNI(var f:FOC):integer;
function RNR(var f:FOC):real;
function RNS(var f:FOC):string;

function RII(var f:FOC):integer;
function RIS(var f:FOC):string;

procedure SkipStr(var f:FOC; x:string);

implementation

procedure Error(x:string);
begin
	writeln('*&(*&)(*&(*');
	writeln('--->  ',x);
	halt(1)
end;

{---------------------------------------------------
	Esta funci¢n actua sobre el archivo pasado como par metro, buscando en
el el caracter ':'.
	Si lo encuentra retorna 0, y la posici¢n de lectura
del archivo est  posicionado en el caracter siguiente al ':'.
	Si por el contrario llega al fin de archivo sin encortrar ':', retornar 
un -1 como indicaci¢n de dicho error.
-----------------------------------------}

function SearchNextTwoPoint(var f:FOC):integer;
var
	c:char;
begin
	c:='m';
	while (not EOF(f) )and( c<>':' ) do read(f,c);
	if EOF(f) then SearchNextTwoPoint:=-1
	else SearchNExtTwoPoint:=0
end;

{-------------------------------------------------------
	NOMBRE: ReadUntilCOMA
	FUNCION: Lee  arch los caracteres desde la posici¢n actual hasta
		enctontrar una (,)o (;) (COMA) . Si se encuentra el caracter (") (comillas)
		antes que la coma, se leer  hasta encontran las comillas de cierre
		hantes de buscar la coma.
	ENTRADA:
		(arch)  Archivo de entrada, debe estar inicializado.
	SALIDA:
		(resStr) String en que se retornan los caracteres le¡dos.
		(Result) (0 lectura exitosa ),(-1 EOF antes que una COMA )
---------------------}

function ReadUntilCOMA(var arch:FOC; var resStr:string):integer;
var
	c:char;
	Comillas,OK:boolean;
begin
	Comillas:=false;
	read(arch,c);
	resStr:='';
	OK:=true;
	while OK and( Comillas or ((c <> ',')and(c<>';'))) do
	begin
		resStr:=resStr+c;
		if c='"' then Comillas:=not Comillas;
		if EOF(arch) then OK:=false
		else
			read(arch,c);
	end;
	if not OK then ReadUntilCOMA:=-1
	else ReadUntilCOMA:=0
end;


function RNS(var f:FOC):string;
var
	tmp:string;
begin
	if SearchNextTwoPoint(f) <>0 then Error(' buscando '':'' ');
	if ReadUntilComa(f,tmp) <> 0 then Error(' buscando '','' ');
	RNS:=tmp
end;

function RNI(var f:FOC):integer;
var
	tmp:string;
	res:integer;
	m:integer;
begin
	tmp:=RNS(f);
	val(tmp,m,res);
	if res<> 0 then Error(' convirtiendo a entero ');
	RNI:=m;
end;

function RNR(var f:FOC):real;
var
	tmp:string;
	res:integer;
	m:real;
begin
	tmp:=RNS(f);
	val(tmp,m,res);
	if res<> 0 then Error(' convirtiendo a real ');
	RNR:=m;
end;

function RIS(var f:FOC):string;
var
	tmp:string;
begin
	if ReadUntilComa(f,tmp) <> 0 then Error(' buscando '','' ');
	RIS:=tmp
end;


function RII(var f:FOC):integer;
var
	tmp:string;
	res:integer;
	m:integer;

begin
	tmp:=RIS(f);
	val(tmp,m,res);
	if res<> 0 then Error(' convirtiendo a entero ');
	RII:=m;
end;

procedure SkipStr(var f:FOC; x:string);
var
	c:char;
	k:integer;
	OK:boolean;
begin
	k:=1;
	OK:=true;
	while OK and (k<=length(x)) do
	begin
		if EOF(f) then OK:= false
		else
		begin
			read(f,c);
			if c=x[k] then inc(k)
			else k:=1;
		end;
	end;
	if not OK then Error('Saltenado : '+x);
end;

end.