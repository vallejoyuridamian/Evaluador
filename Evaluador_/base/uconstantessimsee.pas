unit uConstantesSimSEE;

{$MODE Delphi}
interface

uses
{$IFDEF LINUX}
  winLinuxUtils,
{$ENDIF}
{$IFDEF WINDOWS}
  {$IFNDEF APLICACION_CONSOLA}
  Forms, Messages,
  {$ENDIF}
{$ELSE}
{$IFNDEF APLICACION_CONSOLA}
  Forms, LMessages, Messages,
  Graphics,
  {$ELSE}
  {$IFDEF WINDOWS}
  uWinMsgs,
  {$ENDIF}
  {$ENDIF}
  BaseUnix,
{$ENDIF}
  SysUtils;

const
{$IFNDEF APLICACION_CONSOLA}
  WM_CLOSETRAZOSXY = WM_USER + 1; //Mensaje para cerrar una ventana TrazosXY
{$ENDIF}
  CF_PRECISION = 10;
  CF_DECIMALES = 10;
  CF_DECIMALESPU = 12; //para valores por unidad
  //Nombre de la fuente NIL para los formularios de edicion
  nombreFuenteNil = '<Ninguna>';


var
  // Intento quitar tmp_rundir de aquí, para que cada Hilo pueda tener su propio
  // directorio.
  //  tmp_rundir: string; // si se fija a un valor <> '' se usa como rundir.

  base_ScreenWidth, base_ScreenHeight: integer;
  CP_maxAnchoTablaChica, CP_maxAnchoTablaMediana, CP_maxAnchoTablaGrande,
  CP_maxAnchoTablaMuyGrande, CP_maxAnchoTablaEnorme: integer;
  CP_maxAlturaTablaChica, CP_maxAlturaTablaMediana, CP_maxAlturaTablaGrande,
  CP_maxAlturaTablaMuyGrande, CP_maxAlturaTablaEnorme: integer;



var
  tmp_rundir: string;


function getDir_SimSEE: string;
function getDir_Dbg: string;
function getDir_Bin: string;
function getDir_Run: string;
function getDir_Docs: string;
function getDir_Lib: string;
function getDir_DatosComunes: string;
function getDir_Corridas: string;
function getDir_Tmp: string;

function getDir_SimSEE_ws: string;
function get_SRV_MIME_FILES: string;


// Retorna el nombre del archivo quitando la path y la extensión.
function nombreArchSinExtension(const nomArch: string): string;

//Retorna la unidad actual seguida de :. P.ej: 'C:'
function getCurrentDrive: string;
{$IFDEF LINUX}
//Intenta transformar los paths a paths de linux. Si no se encuentra el archivo
//indicado por path se cambia path por
//HOME + LowerCase(ExtractFilePath(path)) + ExtractFileName(path),
//con HOME el valor de la variable de entorno HOME. Si la variable HOME no esta
//definida se asume HOME = /home/topo
procedure toLinuxDir(var path: string);
{$ENDIF}



procedure subirDirectorio(var path: string);

function quitarRaiz_(path: string): string;

// retorna el archivo sin la extensión
function quitarExtension(archi: string): string;

//Revisa que existan los directorios necesarios para el SimSEE y en caso de no
//existir los crea.
procedure crearDirectorios;


// en Linux es /tmp/simsee_USUARIO siendo
// USUARIO en nombre del usuario que esta ejecutando.
// en Windows es \SimSEE\tmp_rundir
function getDefault_tmp_base: string;


// Crea directorio temporal para el idEjecutor en la carpeta tmp_base
// Retorna el camino completo a la carpeta tmp_base+ DirectorySeparator + idEjecutor
function CrearDirectorioTemporal(tmp_base, idEjecutor: string;
  idSubCarpetaSalida: string = ''): string;


// Borra el contenido de una carpeta.
// por seguridad se exige que la carpeta tenga es string "simsee".
procedure LimpiarCarpeta(const DirName, mascara: string);

//Borra el contenideo de la carpeta, sin exigir nada sobre el nombre
//de la carpeta
function LimpiarResultadosSim(var carpeta: string; archiComodin: string): integer;

// cambia una letra por otra en un string;
procedure remplazar_letra(var pajar: string; aguja, reemplazo: char);

//Cambia el nombre del archivo a la carpeta de nomArchivo\backups\nomArchivo.bak
//No crea una copia, por lo que debe llamarse cuando se va a salvar un nuevo archivo
//sobre nomArchivo
procedure backupearArchivoAntesDeSalvar(nomArchivo: string; maxNBackups: integer);

procedure calcularTamaniosTablas(altoDisponible, anchoDisponible: integer;
  ajustarATamaniosCeldasPorDefecto: boolean);

implementation


(* Retorna el directorio padre terminado con barraDir
Ej1: path = 'c:\simsee\bin\' retorna path = 'c:\simsee\'
Ej2: path = 'c:\simsee\bin' retorna path = 'c:\simsee\'
Ej3: path = 'c:\sim' retorna path = 'c:\'
Ej4: path = 'c:\' retorna path = '\'
Ej4: path = 'adsfadsf\' retorna path = '\'
*)
procedure subirDirectorio(var path: string);
var
  i, N: integer;
  buscando: boolean;
begin
  N := length(path);
  if N < 1 then
  begin
    path := DirectorySeparator; // cubre el caso path=''  y path='x'
    exit;
  end;

  buscando := True;
  i := N - 1; // me salteo el último caracter pues si es una barra quiero ignorarla

  while buscando and (i > 0) do
    if path[i] = DirectorySeparator then
      buscando := False
    else
      Dec(i);
  if buscando then
    path := DirectorySeparator
  else
    Delete(path, i + 1, N - i);
end;


function quitarRaiz_(path: string): string;
var
  i: integer;
  s: string;
begin
  i := pos(':', path);
  if i <> 0 then
    s := copy(path, i + 1, MAXINT)
  else
    s := path;
  Result := trim(s);
end;



procedure remplazar_letra(var pajar: string; aguja, reemplazo: char);
var
  k, n: integer;
begin
  n := length(pajar);
  for k := 1 to n do
    if pajar[k] = aguja then
      pajar[k] := reemplazo;
end;


procedure LimpiarCarpeta(const DirName, mascara: string);
var
  Error: integer;
  FileSearch: TSearchRec;
  camino: string;
begin
  if pos('simsee', DirName) = 0 then
    exit; // no permitimos borrar nada que no tenga simsee en el camino

  if DirName[Length(DirName)] = DirectorySeparator then
    camino := DirName
  else
    camino := DirName + DirectorySeparator;

  Error := FindFirst(camino + mascara, faAnyFile, FileSearch);
  try
    while (Error = 0) do
    begin
      if (FileSearch.Name <> '.') and (FileSearch.Name <> '..') then
        SysUtils.DeleteFile(camino + FileSearch.Name);
      Error := FindNext(FileSearch);
    end;
  finally
    SysUtils.FindClose(FileSearch);
  end;
end;

function LimpiarResultadosSim(var carpeta: string; archiComodin: string): integer;
var
  res: integer;
  Info: TSearchRec;

begin
  carpeta := ExtractFilePath(archiComodin);
  res := 0;
  if FindFirst(archiComodin, faArchive, Info) = 0 then
  begin
    repeat
      SysUtils.DeleteFile(carpeta + info.Name);
      Writeln(info.Name);
      Inc(res);
    until FindNext(info) <> 0;
  end;
  FindClose(Info);
  Result := res;
end;

procedure calcularTamaniosTablas(altoDisponible, anchoDisponible: integer;
  ajustarATamaniosCeldasPorDefecto: boolean);
const
  defaultColWidths = 64;
  defaultLineWidth = 1;
  nLineasBordes = 4;
  nPxLineasBordes = nLineasBordes * defaultLineWidth;
  auxWidth = defaultColWidths + defaultLineWidth;
begin
  CP_MAXANCHOTABLACHICA := round(anchoDisponible * 0.15);
  CP_MAXANCHOTABLAMEDIANA := round(anchoDisponible * 0.4);
  CP_maxAnchoTablaGrande := round(anchoDisponible * 0.6);
  CP_maxAnchoTablaMuyGrande := round(anchoDisponible * 0.75);
  CP_maxAnchoTablaEnorme := round(anchoDisponible * 0.95);

  CP_maxAlturaTablaChica := round(altoDisponible * 0.15);
  CP_maxAlturaTablaMediana := round(altoDisponible * 0.4);
  CP_maxAlturaTablaGrande := round(altoDisponible * 0.55);
  CP_maxAlturaTablaMuyGrande := round(altoDisponible * 0.75);
  CP_maxAlturaTablaEnorme := round(altoDisponible * 0.95);

  if ajustarATamaniosCeldasPorDefecto then
  begin
    //El alto de las filas de una tabla es 24 por defecto, por cada fila hay un
    //pixel mas de la linea separadora y uno mas al final por una linea extra
    //buscamos el primer multiplo de 25 + 1 para cada tamanio
    CP_MAXANCHOTABLACHICA := ((CP_MAXANCHOTABLACHICA div auxWidth) + 1) *
      auxWidth + nPxLineasBordes;
    CP_MAXANCHOTABLAMEDIANA :=
      ((CP_MAXANCHOTABLAMEDIANA div auxWidth) + 1) * auxWidth + nPxLineasBordes;
    CP_maxAnchoTablaGrande := ((CP_maxAnchoTablaGrande div auxWidth) + 1) *
      auxWidth + nPxLineasBordes;
    CP_maxAnchoTablaMuyGrande :=
      ((CP_maxAnchoTablaMuyGrande div auxWidth) + 1) * auxWidth + nPxLineasBordes;
    CP_maxAnchoTablaEnorme := ((CP_maxAnchoTablaEnorme div auxWidth) + 1) *
      auxWidth + nPxLineasBordes;

    CP_maxAlturaTablaChica := ((CP_maxAlturaTablaChica div auxWidth) + 1) *
      auxWidth + nPxLineasBordes;
    CP_maxAlturaTablaMediana :=
      ((CP_maxAlturaTablaMediana div auxWidth) + 1) * auxWidth + nPxLineasBordes;
    CP_maxAlturaTablaGrande :=
      ((CP_maxAlturaTablaGrande div auxWidth) + 1) * auxWidth + nPxLineasBordes;
    CP_maxAlturaTablaMuyGrande :=
      ((CP_maxAlturaTablaMuyGrande div auxWidth) + 1) * auxWidth + nPxLineasBordes;
    CP_maxAlturaTablaEnorme :=
      ((CP_maxAlturaTablaEnorme div auxWidth) + 1) * auxWidth + nPxLineasBordes;
  end;
end;

function getDefault_tmp_base: string;
begin
{$IFDEF LINUX}
  Result := '/tmp/simsee_' + GetEnvironmentVariable('USER');
  //   home:= GetEnvironmentVariable( 'HOME' );
{$ELSE}
  Result := '\simsee\tmp_rundir';
{$ENDIF}
end;

function CrearDirectorioTemporal(tmp_base, idEjecutor: string;
  idSubCarpetaSalida: string): string;
var
  tmp_rundir: string;
begin
  if length( tmp_base ) > 0 then
    if tmp_base[length( tmp_base ) ] = DirectorySeparator then
      delete( tmp_base, length( tmp_base ), 1 );
  if not DirectoryExists(tmp_base) then
    CreateDir(tmp_base);

  if idEjecutor <> '' then
  begin
    tmp_rundir := tmp_base + DirectorySeparator + idEjecutor;
    if not DirectoryExists(tmp_rundir) then
      CreateDir(tmp_rundir);
  end
  else
    tmp_rundir := tmp_base;

  if idSubCarpetaSalida <> '' then
  begin
    tmp_rundir := tmp_rundir + DirectorySeparator + idSubCarpetaSalida;
    if not DirectoryExists(tmp_rundir) then
      CreateDir(tmp_rundir);
  end;
  Result := tmp_rundir;

end;


procedure crearDirectorios;
begin
  if not DirectoryExists(getDir_Dbg) then
    CreateDir(getDir_Dbg);
  if not DirectoryExists(getDir_Run) then
    CreateDir(getDir_Run);
{$IFNDEF AYUDAENWEB}
  if not DirectoryExists(getDir_Docs) then
    CreateDir(getDir_Docs);
{$ENDIF}
  if not DirectoryExists(getDir_Lib) then
    CreateDir(getDir_Lib);
  if not DirectoryExists(getDir_Dbg) then
    CreateDir(getDir_Dbg);
  if not DirectoryExists(getDir_DatosComunes) then
    CreateDir(getDir_DatosComunes);
  if not DirectoryExists(getDir_Corridas) then
    CreateDir(getDir_Corridas);
  if not DirectoryExists(getDir_Tmp) then
    CreateDir(getDir_Tmp);
end;


function quitarExtension(archi: string): string;
var
  ext: string;
  res: string;
begin
  ext := ExtractFileExt(Archi);
  res := copy(archi, 1, length(Archi) - length(ext));
  Result := res;
end;

procedure backupearArchivoAntesDeSalvar(nomArchivo: string; maxNBackups: integer);
var
  path, nombreSinExt, ext, nomArchivoBackup, base: string;
  i, iArchivoMinFecha: integer;
  fechaArchivo, minFechaArchivo: TDateTime;
{$IFDEF FPC}
  fechaArchivoSistema: longint;
{$ENDIF}
begin
  path := ExtractFilePath(nomArchivo);
  nombreSinExt := nombreArchSinExtension(nomArchivo);
  ext := ExtractFileExt(nomArchivo);
  base := path + 'backups' + DirectorySeparator;
  if not DirectoryExists(base) then
  begin
    MkDir(base);
    nomArchivoBackup := base + nombreSinExt + '_bk1' + ext;
  end
  else
  begin
    iArchivoMinFecha := -1;
    minFechaArchivo := EncodeDate(9999, 1, 1);
    base := base + nombreSinExt + '_bk';
    //Busco si hay un backup numerado entre 1 y maxNBackups sin crear
    i := 0;
    while (i < maxNBackups) and FileExists(nomArchivoBackup) do
      //esto antes era un repeat 25/4/11
    begin
      i := i + 1;
      nomArchivoBackup := base + IntToStr(i) + ext;
      {$IFNDEF FPC}
      FileAge(nomArchivoBackup, fechaArchivo);
      {$ELSE}
      fechaArchivoSistema := FileAge(nomArchivoBackup); { *Converted from FileAge*  }
      fechaArchivo := FileDateTodateTime(fechaArchivoSistema);
      {$ENDIF}
      if fechaArchivo < minFechaArchivo then
      begin
        minFechaArchivo := fechaArchivo;
        iArchivoMinFecha := i;
      end;
    end;

    //Si ya estan todos creados remplazo el mas viejo
    if (i = maxNBackups) and FileExists(nomArchivoBackup)
    { *Converted from FileExists*  } then
      nomArchivoBackup := base + IntToStr(iArchivoMinFecha) + ext;
  end;
  RenameFile(nomArchivo, nomArchivoBackup); { *Converted from RenameFile*  }
  FileSetDate(nomArchivoBackup, DateTimeToFileDate(now));
  { *Converted from FileSetDate*  }
end;

function getDir_SimSEE: string;
var
  res: string;
begin
  res := getDir_Bin;
  subirDirectorio(res);
  Result := res;
end;

function getDir_Bin: string;
begin
  Result := ExtractFileDir(ParamStr(0)) + DirectorySeparator;
end;

function nombreArchSinExtension(const nomArch: string): string;
var
  posUltimoPunto, posUltimaBarraDir: integer;
begin
  posUltimoPunto := Length(nomArch) - 1;
  while (posUltimoPunto > 0) and (nomArch[posUltimoPunto] <> '.') do
    posUltimoPunto := posUltimoPunto - 1;


  if posUltimoPunto > 0 then
    posUltimaBarraDir := posUltimoPunto - 1
  else
    posUltimaBarraDir := Length(nomArch) - 1;

  while (posUltimaBarraDir > 0) and (nomArch[posUltimaBarraDir] <> DirectorySeparator) do
    posUltimaBarraDir := posUltimaBarraDir - 1;

  if posUltimoPunto > 0 then
    Result := copy(nomArch, posUltimaBarraDir + 1, posUltimoPunto -
      (posUltimaBarraDir + 1))
  else
    Result := Copy(nomArch, posUltimaBarraDir + 1, length(nomArch) - posUltimaBarraDir);
end;

function getCurrentDrive: string;
var
  s1: string;
begin
  s1 := '';
  GetDir(0, s1);
  Result := Copy(s1, 0, 2);
end;

{$IFDEF LINUX}
//Si el archivo path existe lo deja sin modificar, sino le quita la raiz y lo
//cambia por '/home/topo/' + toOSBarraDirs(path)
procedure toLinuxDir(var path: string);
var
  ruta, arch: string;
  homeDir: PChar;
begin
  if path <> '' then
  begin
    toOSBarraDirs(path);
    if not FileExists(path) then
    begin
      ruta := LowerCase(ExtractFilePath(path));
      arch := ExtractFileName(path);
      homeDir := fpGetEnv('HOME');
      if homeDir = nil then
        homeDir := '/home/topo';
      if path[1] = DirectorySeparator then
        path := homeDir + ruta + arch
      else
        path := homeDir + DirectorySeparator + ruta + arch;
    end;
  end;
end;

{$ENDIF}

function getDir_Dbg: string;
var
  res: string;
begin
  if tmp_rundir = '' then
  begin
    res := getDir_Bin;
    subirDirectorio(res);
    res := res + 'debug' + DirectorySeparator;
  end
  else
  if tmp_rundir[length(tmp_rundir)] = DirectorySeparator then
    res := tmp_rundir
  else
    res := tmp_rundir + DirectorySeparator;
  Result := res;
end;

function getDir_Run: string;
var
  res: string;
begin
  if tmp_rundir = '' then
  begin
    res := getDir_Bin;
    subirDirectorio(res);
    res := res + 'rundir' + DirectorySeparator;
  end
  else
  if tmp_rundir[length(tmp_rundir)] = DirectorySeparator then
    res := tmp_rundir
  else
    res := tmp_rundir + DirectorySeparator;
  Result := res;
end;

function getDir_Tmp: string;
var
  res: string;
begin
  if tmp_rundir = '' then
  begin
    res := getDir_Bin;
    subirDirectorio(res);
    res := res + 'tmp' + DirectorySeparator;
  end
  else
  if tmp_rundir[length(tmp_rundir)] = DirectorySeparator then
    res := tmp_rundir
  else
    res := tmp_rundir + DirectorySeparator;

  Result := res;
end;

function getDir_SimSEE_ws: string;
begin
  Result := getDir_SimSEE + DirectorySeparator + 'ws';
end;

function get_SRV_MIME_FILES: string;
begin
{$IFDEF unix}
  Result := '/etc/mime.types';
{$ELSE}
  Result := getDir_SimSEE_ws + DirectorySeparator + 'mime.types';
{$ENDIF}
end;

function getDir_Docs: string;
{$IFNDEF AYUDAENWEB}
var
  res: string;
{$ENDIF}
begin
{$IFNDEF AYUDAENWEB}
  res := getDir_Bin;
  subirDirectorio(res);
  Result := res + 'docs-word' + DirectorySeparator;
{$ELSE}
  Result := 'http://iie.fing.edu.uy/simsee/simsee/ayuda/';
{$ENDIF}
end;

function getDir_Lib: string;
var
  res: string;
begin
  res := getDir_Bin;
  subirDirectorio(res);
  Result := res + 'librerias' + DirectorySeparator;
end;

function getDir_DatosComunes: string;
var
  res: string;
begin
  res := getDir_Bin;
  subirDirectorio(res);
  Result := res + 'datos_comunes' + DirectorySeparator;
end;

function getDir_Corridas: string;
var
  res: string;
begin
  res := getDir_Bin;
  subirDirectorio(res);
  Result := res + 'corridas' + DirectorySeparator;
end;


{$IFNDEF APLICACION_CONSOLA}
procedure initConstantesTamanio;
begin
  if screen <> nil then
  begin
    base_ScreenWidth := Screen.WorkAreaWidth;
    base_ScreenHeight := Screen.WorkAreaHeight;
  end
  else
  begin
    base_ScreenWidth := 800;
    base_ScreenHeight := 600;
  end;
  calcularTamaniosTablas(base_ScreenHeight, base_ScreenWidth, True);
end;

{$ENDIF}

initialization
  begin

    //  tmp_rundir:= '';

{$IFNDEF APLICACION_CONSOLA}
    initConstantesTamanio;
{$ENDIF}

  end;

finalization

end.
