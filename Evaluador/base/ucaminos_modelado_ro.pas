unit ucaminos_modelado_ro;

{$mode delphi}
interface

uses
  Classes, SysUtils,ufechas;


var
  CarpetaRaizInfo: string;
  CarpetaCEGH: string;

function CarpetaResultados_modelado_RO( nidCentral: integer ): string;
function archi_parque_mt( nidCentral: integer ): string;
function archi_calibrador( nidCentral: integer ): string;
function archi_parque_mc( nidCentral: integer ): string;
function archi_series(nidCentral: integer; term_str: string = '_series10min.sas' ): string; overload;
function archi_series(path: String; nidCentral: integer; term_str: string = '_series10min.sas' ): string; overload;


implementation


function CarpetaResultados_modelado_RO( nidCentral: integer ): string;
begin
 result:= CarpetaRaizInfo+ DirectorySeparator +'c'+IntToStr( nidCentral );
 if not DirectoryExists( Result ) then
     mkdir( Result );
end;

function archi_parque_mt( nidCentral: integer ): string;
begin
  result:= CarpetaResultados_modelado_RO( nidCentral)+DirectorySeparator +'c'+IntToStr( nidCentral )+'_parque_mt.pmt';
end;
function archi_parque_mc( nidCentral: integer ): string;
begin
  result:= CarpetaResultados_modelado_RO( nidCentral)+DirectorySeparator +'c'+IntToStr( nidCentral )+'.pmc';
end;

function archi_calibrador( nidCentral: integer ): string;
begin
  result:= CarpetaResultados_modelado_RO( nidCentral)+DirectorySeparator +'c'+IntToStr( nidCentral )+'_calibrador.clp';
end;

function archi_series(path: String; nidCentral: integer; term_str: string = '_series10min.sas'): string;
begin
  result:= path+DirectorySeparator+'c'+IntToStr(nidCentral)+ term_str;
end;

function archi_series( nidCentral: integer; term_str: string = '_series10min.sas' ): string;
begin
  result:= archi_series( CarpetaResultados_modelado_RO( nidCentral), nidCentral, term_str  );
end;


procedure mkdirine( carpeta: string );
begin
 WriteLn(carpeta);
  if not DirectoryExists( Carpeta ) then
     mkdir( carpeta );
end;

initialization

{$IFDEF LINUX}
mkdirine( getUserDir+ 'modelado_ro' );
CarpetaRaizInfo:= getUserDir+ 'modelado_ro/calibrador_ro';
mkdirine( CarpetaRaizInfo );
CarpetaCEGH:= CarpetaRaizInfo+'/CEGH';
mkdirine( CarpetaCEGH );
{$ELSE}

{$IFDEF VERSION_SIMPLE}
CarpetaRaizInfo:= 'C:\simsee\modelado_ro';
mkdirine( CarpetaRaizInfo );
{$ELSE}
if DirectoryExists( 'Y:' ) then
begin
  CarpetaRaizInfo:= 'Y:\modelado_ro';
  mkdirine( CarpetaRaizInfo );
  CarpetaCEGH:= 'Y:\modelado_ro\CEGH';
  mkdirine( CarpetaCEGH );
end
else
begin
  if DirectoryExists( 'C:' ) then
     begin
  mkdirine( 'C:\basura' );
  CarpetaRaizInfo:= 'C:\basura\modelado_ro';
  mkdirine( CarpetaRaizInfo );
  CarpetaCEGH:= 'C:\basura\modelado_ro\CEGH';
  mkdirine( CarpetaCEGH );
    end;
end;
{$ENDIF}

if not DirectoryExists(CarpetaRaizInfo) then
begin
  {$IFDEF VERSION_SIMPLE}
  mkdirine('C:\simsee\modelado_ro');
  {$ELSE}
  mkdirine('c:\basura');
  CarpetaRaizInfo:= 'c:\basura\modelado_ro';
  mkdirine( CarpetaRaizInfo );
  CarpetaCEGH:= 'c:\basura\modelado_ro\CEGH';
  mkdirine( CarpetaCEGH );
  {$ENDIF}
end;
{$ENDIF}



end.

