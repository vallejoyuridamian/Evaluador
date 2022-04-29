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
uses
{$IFDEF ERROR_CONDIALOGO}
  dialogs,
{$ENDIF}
  SysUtils;
procedure Error(x:string);

implementation

procedure Error(x:string);
begin
{$IFDEF ERROR_CONDIALOGO}
   ShowMessage( 'ERROR:::'+x);
	Halt(1)
{$ELSE}
  raise Exception.Create('ERROR: '+x );
{$ENDIF}
end;

end.
