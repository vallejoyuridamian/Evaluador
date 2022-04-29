{+doc
+NOMBRE: FechHora
+CREACION:
+AUTORES: rch
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO:  Definir funcion que debuelva la fecha y la hora en string
+PROYECTO:

+REVISION:
+AUTOR:
+DESCRIPCION:
-doc}

unit FechHora;
interface
uses
{$IFNDEF WINDOWS}
	{$I xDOS};
{$ELSE}
  SysUtils;
{$ENDIF}


function FechaYHora: string;
function Fecha: string;
function Hora: string;




implementation

{$IFNDEF WINDOWS}
const
  days : array [0..6] of String[9] =
	 (	'Domingo',
		'Lunes',
		'Martes',
		'Miercoles',
		'Jueves',
		'Viernes',
		'Sabado');


function Fecha:string;
var
  y, m, d, dow : Word;
  t1, t2: string;
begin
	GetDate(y,m,d,dow);
	str(y, t1);
	str(m, t2);
	t1:=t1+'/'+t2;
	str(d, t2);
	t1:= t1+'/'+t2;
	Fecha:= days[dow]+','+t1;
end;


function Hora: string;
var
  h, m, s, hund : Word;
function LeadingZero(w : Word) : String;
var
  s : String;
begin
  Str(w:0,s);
  if Length(s) = 1 then
    s := '0' + s;
  LeadingZero := s;
end;
begin
  GetTime(h,m,s,hund);
  hora:= LeadingZero(h)+':'+LeadingZero(m)+
			':'+LeadingZero(s)+'.'+LeadingZero(hund);
end;

function FechaYHora: string;
begin
	FechaYHora:= Fecha+'  '+Hora;
end;
{$ELSE}

function Fecha:string;
begin
   Fecha:= DateToStr( Date );
end;


function Hora: string;
begin
     Hora:= TimeToStr( Time );
end;

function FechaYHora: string;
begin
	FechaYHora:= DateTimeToStr( Now );
end;
{$ENDIF}
end.
