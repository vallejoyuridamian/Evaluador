Unit WSetFile;
interface
uses Crt,Dos,VideoTxt;
{
const
 Leyenda:array[0..5] of string[25] =
			(	'ษอออออออออออออออออออออออป',
				'บ Ruben Chaer.          บ',
				'บ M.E.E.P/I.I.E         บ',
				'บ Montevideo            บ',
				'บ Uruguay               บ',
				'ศอออออออออออออออออออออออผ' );
}
var
	P: PathStr;
	D: DirStr;
	N: NameStr;
	E: ExtStr;

Procedure SetFile(mascaraIN:string);
procedure Cartel;

implementation

procedure Cartel;
var k:word;
begin
window(1,18,25,24);
CLrScr;
{
for k:=0 to 5 do
	write(Leyenda[k]);}
end;

procedure cartel2;
begin
window(60,23,80,24);
ClrScr;
writeln(' WSetFile:Rch/90 ');
end;


procedure SetFile;
type

  NamePtr = ^ficha;

  ficha = record
				cont:integer;
				name:string[12];
				nextd,nexti:NamePtr;
				Attr:byte;
          end;
  const
	Enter = #13;
	Insert = chr(082);
	Home = chr(071);
	PageUp = chr(073);
	Endx = chr(079);
	PageDown =chr(081);
	up = chr(072);
	down =chr(080);
	left = chr(075);
	righ = chr(077);
	esc = chr(27);

var
 dir,tag,ventana:NamePtr;
 k:integer;
 letra:char;
 temp,mascara:string;
 marca:pointer;
 OldCursorStatus:CursorStatusType;
 d1:DirStr;

function atr(x:byte):string;
begin
 case x of
   $01: atr:='ReadOnly';
   $02: atr:='Hidden';
   $04: atr:='SysFile';
   $08: atr:='VolumeID';
   $10: atr:='Directory';
   $20: atr:='Archive';
   $3f: atr:='AnyFile';
 end;
end;

function EsUn(x,y:byte):boolean;
begin
	if (x and y ) = 0 then EsUn:=False
	else EsUn:=true;
end;


(* Este procedimiento crea un arbol doblemente encadenado con *)
(* los nombres de los archivos en el corriente directorio     *)
(* Al puntero "marca"  lo apunta al inicio del area de memoria*)
(*dinamica ocupada por el arbol                               *)

procedure Directorio(var lf:NamePtr;mascara:string);


var
   pat:SearchRec;
	paux:NamePtr;
	cuenta:integer;
	flag:boolean;
	SearchAttrib, FindAttrib:integer;

begin
if marca <> nil then release(marca);
Mark(marca);
cuenta:=0;
flag:=false;
SearchAttrib:=AnyFile;
lf:=nil;

repeat
FindFirst(mascara,SearchAttrib,pat);
findAttrib:=pat.attr;
while (DosError<>18) do
begin
	if (findAttrib and SearchAttrib <> 0) then
	begin
		if not(EsUn(pat.attr , directory) and not(flag)) then
		begin
			new(paux);
			paux^.nextd:=nil;
			paux^.nexti:=nil;
			paux^.name := pat.Name;
			paux^.attr:=pat.attr;
			paux^.cont:=cuenta;
			cuenta:=cuenta+1;
			if lf = nil then lf := paux
			else
			begin
				paux^.nexti := lf;
				lf^.nextd := paux;
				lf := paux
			end;
		end;
	end;

		FindNext(pat);
		FindAttrib:=pat.attr;
end;
	flag:=not(flag);
	SearchAttrib:=Directory;
	mascara:='*.*';
until not(flag);

end; (* Directorio *)


procedure Despliegue(a:NamePtr);
var
	k:integer;
paux:NamePtr;
begin
ClrScr;
paux:=a;
for k:=1 to 48 do
	 if paux<>nil then
		begin
		if paux=tag then
			begin
				textbackground(7);
				textcolor(0);
            if EsUn(paux^.attr,directory) then
					write(paux^.name+'\':13)
				else
					write(paux^.name:12,' ');
				textcolor(7);
				textbackground(0);
			end
		else
			if EsUn(paux^.attr,directory) then
				write(paux^.name+'\':13)
			else
				write(paux^.name:12,' ');
		paux:=paux^.nexti
		end
end; (* Despliegue *)


function raiz(s:DirStr):boolean;
begin
if (ord(s[0])=3)and(s[2]=':')and(s[3]='\') then raiz := true
else raiz:=false
end;

function ultimo(s:string):char;
begin
ultimo:=s[ord(s[0])];
end;

procedure unoderecha;
begin
if tag^.nexti <> nil then
       begin
        ClrScr;
		  tag:=tag^.nexti;
		  if tag^.cont-ventana^.cont<=-44 then ventana:=ventana^.nexti;
		 end;
end;



procedure unoizquierda;
begin
if tag^.nextd<>nil then
         begin
          ClrScr;
			 tag:=tag^.nextd;
			 if ventana^.nextd=tag then ventana:=tag;
			end;
end;



begin
marca:=nil;
OldCursorStatus:=GetCursorStatus;
SetCursorStatus(OffCursor);
ClrScr;
getdir(0,d1);

if mascaraIN='' then
	begin
	Write('Mascara [',d1,' *.pas] ');
	ReadLn(P);
	end
else
	p:=mascaraIN;

FSplit(P, D, N, E);
if d = '' then d:=d1;
if N = '' then N:='*';
if E = '' then E:='.pas';
P := D + ' '+N + E;

if (d<>'')and(d[ord(d[0])]='\') then d[0]:=chr(ord(d[0])-1);
if d <> d1 then chdir(d);
mascara:=n+e;
p:='';
repeat
	Directorio(dir,mascara);
	textbackground(5);
	clrscr;
	window(1,1,54,16);
	gotoxy(1,1);
	textcolor(7);
	textbackground(0);
	CLrScr;
    (* น บ ป  ศ ษ ส ห ฬ อ ฮ ผ *)
	write('ษออออออออออออออออออออออออออออออออออออออออออออออออออออป');
	write('บ                                                    บ');
	write('บ                                                    บ');
	write('บ                                                    บ');
	write('บ                                                    บ');
	write('บ                                                    บ');
	write('บ                                                    บ');
	write('บ                                                    บ');
	write('บ                                                    บ');
	write('บ                                                    บ');
	write('บ                                                    บ');
	write('บ                                                    บ');
	write('บ                                                    บ');
	write('บ                                                    บ');
	write('ศออออออออออออออออออออออออออออออออออออออออออออออออออออผ');

	Cartel2;


	Window(2,2,53,14);




	letra:='l';
	tag:=dir;
	ventana:=dir;
	Despliegue(ventana);
	window(12,0,0,0);
	while (letra<> Enter)and(letra<>Esc) do
		begin
		letra:=ReadKey;
		case letra of
			left:	begin
					unoizquierda;
					despliegue(ventana)
					end;

			up: 	begin
					for k:=1 to 4 do unoizquierda;
					despliegue(ventana)
					end;

			righ: 	begin
						unoderecha;
						despliegue(ventana);
						end;

			down:	begin
					for k:= 1 to 4 do unoderecha;
					despliegue(ventana);
					end;

			PageUp:	begin
						for k:=1 to 43 do unoizquierda;
						despliegue(ventana);
						end;

			PageDown : 	begin
							for k:= 1 to 43 do unoderecha;
							despliegue(ventana);
							end;

			Endx: 	begin
						while tag^.nexti<>nil do unoderecha;
						despliegue(ventana);
						end;

			Home:		begin
						while tag^.nextd<>nil do unoizquierda;
						despliegue(ventana);
						end;
			end; (* Case *)

		end; (* while *)


	if letra<>Esc then

		if EsUn(tag^.attr,directory) then
			begin
				temp:=tag^.name;
				chdir(temp);
				getdir(0,d);
			end
		else
		begin
			p:=d+'\'+tag^.name;
			FSplit(p,d,n,e);
		end


until (p<>'') or (letra = Esc);


if d <> d1 then chdir(d1);

if marca<>nil then release(marca);
Window(1,1,80,25);
ClrScr;
SetCursorStatus(OldCursorStatus);
end;

begin
writeln('Unit: WSetFile/RCh90');
end.
