unit udirectoryscanner;

{$mode delphi}{$H+}

interface

uses
  Classes, SysUtils;


type
  { TIgnoreItem }
  TIgnoreItem = class
    nombre: string;
    ipos: integer; // -1 es al inicio; 0 en cualquier parte ; 1 al final
    flg_case_sensitive: boolean;
    constructor Create( xnombre: string; xipos: integer; xflg_case_sensitive: boolean );
    function match( nombre_item: string ): boolean;
  end;

  { TDirectoryScanner }
  TDirectoryScanner = class
   public
     constructor Create;
     procedure scan( const carpeta_raiz: string ); virtual; abstract;
     procedure Free; virtual;

   protected
    carpetas_ignore_lst, archivos_ignore_lst: TList;
     procedure procesar_archivo( const carpeta, nombre_archivo: string ); virtual; abstract;

     // retorna el camino completo al archivo = carpeta + DirectorySeparator+ nombre_archivo
     function archi( const carpeta, nombre_archivo: string ): string;
     procedure procesar_carpeta(const carpeta, mascara: string); virtual;
     procedure procesar_archivos_de_carpeta( const carpeta, mascara: string ); virtual;
     procedure add_ignore_carpeta(
       partenombre: string;
       ipos: integer = -1; // -1 al inicio, 0 cualquier parte , 1 al final );
       flg_case_sensitive: boolean = false );
     procedure add_ignore_archivo(
       partenombre: string;
       ipos: integer = -1; // -1 al inicio, 0 cualquier parte , 1 al final );
       flg_case_sensitive: boolean = false );

     // retorna TRUE si el nombre_item no está en la lista
    function not_in_ignore_lst( nombre_item: string; ignore_lst: TList ): boolean;
  end;


implementation




{ TIgnoreItem }
constructor TIgnoreItem.Create(xnombre: string; xipos: integer;
  xflg_case_sensitive: boolean);
begin
  inherited Create;
  if flg_case_sensitive then
    nombre:=  xnombre
  else
    nombre:= LowerCase( xnombre );
  ipos:= xipos;
  flg_case_sensitive:= xflg_case_sensitive;
end;

function TIgnoreItem.match(nombre_item: string): boolean;
var
  i: integer;
  s: string;
  res: boolean;
begin
  if flg_case_sensitive then
    s:= nombre_item
  else
    s:= LowerCase( nombre_item );
  i:= pos( nombre, s );
  if i = 0 then
   res:= false
  else
    case ipos of
    -1: res:= i = 1;
     1: res:= i = ( length( s ) - length( nombre_item ) +1 );
     else // ipos = 0
      res:= true;
    end;
  result:= res;
end;


{ TFileScanner }

constructor TDirectoryScanner.Create;
begin
  inherited Create;
  carpetas_ignore_lst:= TList.Create;
  archivos_ignore_lst:= TList.Create;
end;

procedure TDirectoryScanner.Free;
var
  k: integer;
  aii: TIgnoreItem;
begin
  for k:= 0 to carpetas_ignore_lst.Count-1 do
  begin
    aii:= carpetas_ignore_lst[k];
    aii.Free;
  end;
  carpetas_ignore_lst.Free;

  for k:= 0 to archivos_ignore_lst.Count-1 do
  begin
    aii:= archivos_ignore_lst[k];
    aii.Free;
  end;
  archivos_ignore_lst.Free;

  inherited Free;
end;

procedure TDirectoryScanner.add_ignore_carpeta(partenombre: string; ipos: integer;
  flg_case_sensitive: boolean);
var
  aRec: TIgnoreItem;
begin
  aRec:= TIgnoreItem.Create( partenombre, ipos, flg_case_sensitive );
  carpetas_ignore_lst.add( aRec );
end;

procedure TDirectoryScanner.add_ignore_archivo(partenombre: string; ipos: integer;
  flg_case_sensitive: boolean);
var
  aRec: TIgnoreItem;
begin
  aRec:= TIgnoreItem.Create( partenombre, ipos, flg_case_sensitive );
  archivos_ignore_lst.add( aRec );
end;

function TDirectoryScanner.not_in_ignore_lst(nombre_item: string;
  ignore_lst: TList): boolean;
var
  aii: TIgnoreItem;
  k, n: integer;
  res: boolean;
begin
  res:= true;
  k:= 0;
  for k:= 0 to ignore_lst.count-1 do
  begin
    aii:= ignore_lst[k];
    if aii.match( nombre_item ) then
    begin
      res:= false;
      break;
    end;
  end;
  result:= res;
end;

function TDirectoryScanner.archi(const carpeta, nombre_archivo: string): string;
begin
  result:= carpeta + DirectorySeparator + nombre_archivo;
end;

procedure TDirectoryScanner.procesar_archivos_de_carpeta(const carpeta,
  mascara: string);
var
  infoRec: TSearchRec;
  cerr: integer;
begin
  cerr:= FindFirst(carpeta +  DirectorySeparator + mascara, faArchive, infoRec );
  while ( cerr = 0) do
  begin
    if (( infoRec.attr and faArchive) <> 0) then
    begin
      procesar_archivo(carpeta, infoRec.Name);
    end;
    cerr:= FindNext( infoRec );
  end;
  FindClose( infoRec );
end;

procedure TDirectoryScanner.procesar_carpeta(const carpeta,
  mascara: string);
var
  infoRec: TSearchRec;
  cerr: integer;
begin
  cerr:= FindFirst(carpeta + DirectorySeparator + '*', faDirectory, infoRec);
  while ( cerr = 0) do
  begin
    if ((infoRec.attr and faDirectory) <> 0) and ( infoRec.Name[1] <> '.') and
      ( infoRec.Name <> 'backup')
      and not_in_ignore_lst( inforec.Name, carpetas_ignore_lst ) then
    begin
      //      writeln('Directorio ---> ', carpeta +'\'+ Dir.Name);
      Procesar_Carpeta(carpeta + DirectorySeparator + infoRec.Name, mascara);
    end;
    cerr:= FindNext( infoRec );
  end;
  FindClose( infoRec );
  Procesar_Archivos_de_Carpeta(carpeta, mascara );
end;

end.

