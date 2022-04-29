{+doc
+NOMBRE: ucronometros
+CREACION: 26/11/2006
+AUTORES: Ruben Chaer
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO: def. Clase (TCrono). Sive de cronometro para medir tiempos.
+PROYECTO:rchlib
+REVISION:
+AUTOR: Ruben Chaer
+DESCRIPCION:
Es una reedición de la unidad cronomet (1990) ayornando el objeto TCrono a
que sea una Class y usando DateTime para manejo de fechas.
-doc}

unit ucronometros;

interface (******************************)
uses
	xMatDefs, SysUtils;

type
	TCrono = Object
		tac,tarr:NReal;
		procedure borre;
		procedure pare;
		procedure cuente;
		function cuenta:NReal;
	end;

implementation

procedure TCrono.borre;
begin
	tac:=0;
	tarr:=0;
end;

procedure TCrono.cuente;
{var
	hrs,min,sec,decs:word;}
begin
	TArr:= now;
end;

procedure TCrono.pare;
var
{	hrs,min,sec,decs:word; }
	temp:NReal;
begin
	Temp:= now;
	tarr:=temp-tarr;
	tac:=tac+tarr;
end;

function TCrono.cuenta:NReal;
begin
	cuenta:=tac*24*60*60;
end;

end.
