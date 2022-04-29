{+doc
+NOMBRE:horrores
+CREACION:1.1.90
+AUTORES:rch
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO:Servicio de unificacion del tratamiento de errores.
+PROYECTO:rchlib

+REVISION:
+AUTOR:
+DESCRIPCION:
-doc}

unit Horrores;
interface

procedure Error(x:string);

implementation

procedure Error(x:string);
begin
	writeln('Horror! $#@$#%^&*&^%');
	writeln;
	writeln(x);
	Halt(1)
end;

end.
