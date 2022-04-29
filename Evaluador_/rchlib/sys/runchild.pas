{+doc
+NOMBRE:runchild
+CREACION:1.1.90
+AUTORES:rch
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO: Servicio de corrida de subprocesos DOS. (para DOS).
+PROYECTO:rchlib

+REVISION:
+AUTOR:
+DESCRIPCION:
-doc}

unit runchild;
interface
uses
	dos;

procedure rc( Command:string);

implementation

procedure rc( Command:string);
begin
	writeln('Running:.......................... ');
	writeln(Command);
	if Command <> '' then
	  Command := '/C ' + Command;
	SwapVectors;
	Exec(GetEnv('COMSPEC'),Command);
	SwapVectors;
	if DosError <> 0 then
	  WriteLn('Could not execute COMMAND.COM');
end;
end.