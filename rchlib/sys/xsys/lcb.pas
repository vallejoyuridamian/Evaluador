{+doc
+NOMBRE:
+CREACION:
+AUTORES:
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO: Separador del campo comentarios del encabezado estandar
+PROYECTO: SOLAR.

+REVISION:
+AUTOR:
+DESCRIPCION:
-doc}

unit lcb;
interface

function GetProposito(var f:text):string;

implementation


function GetProposito(var f:text):string;
var
	r,q:string;
	buscando:boolean;
begin
	reset(f);
	buscando:= true;
	while not eof(f) and buscando do
	begin
		readln(f,r);
		if pos('+PROPOSITO:',r) = 1 then buscando:= false;
	end;
	GetProposito:='';
	if buscando then exit;
	delete(r,1,11);
	buscando:=true;
	while not eof(f) and buscando do
	begin
		{r:=r+'/';}
		readln(f,q);
		if pos('+PROYECTO:',q) = 1 then buscando := false
		else
		if Length(r)+Length(q) > 255 then
		begin
			r:= r+copy(q,1,255-Length(r));
			buscando:= false
		end
		else r:=r+q;
	end;
	if buscando then exit;
	while pos(#9,r)>0 do
		r[pos(#9,r)]:=' ';
	GetProposito:= r;
end;


end.





