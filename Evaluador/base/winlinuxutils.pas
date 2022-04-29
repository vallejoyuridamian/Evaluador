unit winLinuxUtils;

interface

uses
{$IFDEF WINDOWS}
  Windows,
{$ELSE}
  ctypes,
{$ENDIF}
  Sysutils,
  Classes;


//Retorna todos los archivos en path cuya extension se encuentre en extensiones
//y sus subdirectorios
//Las extensiones deben darse sin ., un archivo .exe se buscara con exe
//Si se quiere cualquier extension poner '*' en extensiones
procedure getDirectoryContents(path: String; extensiones: array of String; var res: TStringList; recursivo: boolean); overload;

// OJO!. Elimina todos los archivos en la carpeta "path" que pasen por el filtro de extensiones..
procedure deleteFiles(path: String; extensiones: array of String;  recursivo: boolean);

function GetSystemCoreCount: integer;

//Si esta en windows cambia las '/' por '\'
//Si esta en linux cambia las '\' por '/'
procedure toOSBarraDirs(var s: String);

implementation


procedure getDirectoryContents(path: String; extensiones: array of String; var res: TStringList; recursivo: boolean);
var
  sr: TSearchRec;
  FileAttrs: Integer;
  directorios: TStringList;
  pathExtension: String;
  i: Integer;
begin
{  FileAttrs:= 0;
  FileAttrs := FileAttrs + faReadOnly;
  FileAttrs := FileAttrs + faHidden;
  FileAttrs := FileAttrs + faSysFile;
  FileAttrs := FileAttrs + faVolumeID;
  FileAttrs := FileAttrs + faDirectory;
  FileAttrs := FileAttrs + faArchive;
  FileAttrs := FileAttrs + faAnyFile;}

  if path[Length(path)] <> DirectorySeparator then
    path:= path + DirectorySeparator;

  FileAttrs := 0;
  for i:= 0 to high(extensiones) do
  begin
    pathExtension:= path + '*.' + extensiones[i];
    if SysUtils.FindFirst(pathExtension, FileAttrs, sr) = 0 then
    begin
      repeat
        if (sr.Attr and FileAttrs) = FileAttrs then
          res.Add(path + sr.Name);
      until FindNext(sr) <> 0;
      FindClose(sr);
    end;
  end;

  if recursivo then
  begin
  directorios:= TStringList.Create;
  FileAttrs:= faDirectory;
  pathExtension:= path + '*.*';
  if SysUtils.FindFirst(pathExtension, FileAttrs, sr) = 0 then
  begin
    repeat
      if ((sr.Attr and FileAttrs) = FileAttrs) and
         (sr.Name <> '.') and   //Solo busco en directorios hacia abajo
         (sr.Name <> '..') then
        directorios.Add(sr.Name);
    until FindNext(sr) <> 0;
    FindClose(sr);
  end;

  for i:= 0 to directorios.Count - 1 do
      getDirectoryContents(path + directorios[i] + DirectorySeparator, extensiones, res, recursivo);
  directorios.Free;
end;
end;

procedure deleteFiles(path: String; extensiones: array of String; recursivo: boolean);
var
  archis: TStringList;
  i: Integer;
begin
  getDirectoryContents(path, extensiones, archis, recursivo);
  for i:= 0 to archis.Count - 1 do
    DeleteFile(archis[i]);
  archis.Free;
end;

{$IFDEF Linux}
const _SC_NPROCESSORS_ONLN = 83;
function sysconf(i: cint): clong; cdecl; external name 'sysconf';
function get_nprocs:longint; cdecl; external 'c' name 'get_nprocs';
{$ENDIF}
//Parte de la función encontrada en
//http://www.nabble.com/number-of-cpu-cores-td20747886.html
//La funcion original era GetSystemThreadCount
function GetSystemCoreCount: integer;
// returns a good default for the number of threads on this system


{$IFDEF WINDOWS}
//returns total number of processors available to system including logical hyperthreaded processors
var
  i: Integer;
  {$IFDEF WIN32}
  ProcessAffinityMask, SystemAffinityMask: DWORD;
  {$ENDIF}
  {$IFDEF WIN64}
  ProcessAffinityMask, SystemAffinityMask: QWORD;
  {$ENDIF}

  Mask: DWORD;
  SystemInfo: SYSTEM_INFO;
  res: integer;
begin
     result:= GetCPUCount;
(*
  if GetProcessAffinityMask(GetCurrentProcess, ProcessAffinityMask, SystemAffinityMask) then
  begin
    res := 0;
    Mask:= 1;
    for i := 0 to 31 do
    begin
      if (ProcessAffinityMask and Mask) <> 0 then
        inc( res );
      Mask:= Mask shl 1;
    end;
  end
  else
  begin
    //can't get the affinity mask so we just report the total number of processors
    GetSystemInfo(SystemInfo);
    res:= SystemInfo.dwNumberOfProcessors;
  end;
  result:= res;
  *)
end;
{$ELSE}
begin
   result:= get_nprocs;
end;
{$ENDIF}


procedure toOSBarraDirs(var s: String);
begin
{$IFDEF LINUX}
s:= StringReplace(s, '\', DirectorySeparator, [rfReplaceAll]);
{$ELSE}
s:= StringReplace(s, '/', DirectorySeparator, [rfReplaceAll]);
{$ENDIF}
end;

end.






