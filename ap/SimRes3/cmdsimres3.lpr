program cmdsimres3;

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes,
  uConstantesSimSEE,
  usimres3, ucoloresbasicos;


var
  ArchiDefs: string;
  idSubCarpetaSalida: string;
  idEjecutor: string;
  tmp_base: string;

{$R *.res}

procedure WriteHelp;
begin
    writeln( 'SINTAXIS: ' );
    writeln( '   cmdsimres3 archi_defs [idSubCarpetaSalida [ejecutor [tmp_base]]] ' );
    writeln;
    writeln( ' archi_defs : es el archivo con las definiciones resultado de sustituir en una plantilla.sr3' );
    writeln( ' idSubCarpetaSalida : Crea una subcarpeta para los resultados con este nombre.' );
    writeln( ' ejecutor : un número entero usado para identificar el ejecutor.' );
    writeln( ' tmp_base : es la carpeta raíz de los resultados. Es opcional y si no se especifica se utiliza la por defecto. ' );
end;

function leopar( kPar: integer ): string;
var
  s: string;
begin
  s:= ParamStr( kPar );
  if (length( s ) >= 2) and ( s[1] = '"') and ( s[ length( s )] = '"' ) then
   begin
      delete( s, 1, 1 );
      delete( s, length( s ), 1 );
   end;
  result:= s;
end;

begin
  if Paramcount > 0 then
   begin
      ArchiDefs:= LeoPar( 1 ); //archivo con definiciones simres3

      if paramCount >= 2 then
        idSubCarpetaSalida:= LeoPar( 2 )
      else
        idSubCarpetaSalida:= '';

      if paramCount >= 3 then
        idEjecutor:= LeoPar( 3 ) //identificador del robot del ejecutador
      else
        idEjecutor:= '';

      if idEjecutor = '_ninguno_' then
         idEjecutor:= '';

      if paramCount >= 4 then
        tmp_base:= LeoPar( 4 ) //directorio base
      else
        tmp_base:= getDefault_tmp_base;

      tmp_rundir:= CrearDirectorioTemporal( tmp_base, idEjecutor, idSubCarpetaSalida );
      chdir( tmp_rundir );
      usimres3.run( ArchiDefs, 'salida_sr3', false );
   end
  else
   WriteHelp;
end.

