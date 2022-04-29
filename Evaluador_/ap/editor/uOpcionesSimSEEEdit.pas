unit uOpcionesSimSEEEdit;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
{$IFDEF WINDOWS}
  Windows,
{$ENDIF}
{$IFDEF FPC}
  FileUtil,
{$ENDIF}
  uCosa, uCosaConNombre, uconstantesSimSEE,
  SysUtils, Dialogs, xmatdefs, utilidades;
resourcestring
  mesErrorLeyendoArchivoPref =
    'Ocurrio un error leyendo el archivo de preferencias del editor.';
  mesUsaronValoresXDefecto = 'Se usaran los valores por defecto';

const
  configFile_ = 'config.ini';

type

  { TSimSEEEditOptions }

  TSimSEEEditOptions = class(TCosa)
  public

    (**************************************************************************)
    (*              A T R I B U T O S   P E R S I S T E N T E S               *)
    (**************************************************************************)

    fechasAutomaticas: boolean;
    fLibPath: string;
    deshabilitarScrollHorizontalEnListados: boolean;
    guardarBackupDeArchivos: boolean;
    maxNBackups: integer;

    (**************************************************************************)

    constructor Create(capa: integer; fechasAutomaticas: boolean;
      deshabilitarScrollHorizontalEnListados: boolean; libPath: string;
      guardarBackupDeArchivos: boolean; maxNBackups: integer);


    function Rec: TCosa_RecLnk; override;
    procedure BeforeRead(version, id_hilo: integer); override;
    procedure AfterRead(version, id_hilo: integer); override;

    //Van public por el warning. No usar, usar getInstance
// OJO REVISAR ESTO de GetInstance
    class function getInstance: TSimSEEEditOptions;

    procedure setLibPath(newLibPath: string);
    procedure guardar;
    procedure Free; override;
    property libPath: string read fLibPath write setLibPath;

  end;

implementation
var
  opciones: TSimSEEEditOptions;

constructor TSimSEEEditOptions.Create(capa: integer; fechasAutomaticas: boolean;
  deshabilitarScrollHorizontalEnListados: boolean; libPath: string;
  guardarBackupDeArchivos: boolean; maxNBackups: integer);
begin
  (*
  if opciones <> nil then
    raise Exception.Create(
      'TSimSEEEditOptions.Create: Error se esta creando una segunda instancia de TSimSEEEditOptions');
    *)
  inherited Create(capa);
  self.fechasAutomaticas := fechasAutomaticas;
  self.deshabilitarScrollHorizontalEnListados := deshabilitarScrollHorizontalEnListados;
  self.libPath := libPath;
  setLibPath(libPath);
  opciones := self;
  self.guardarBackupDeArchivos := guardarBackupDeArchivos;
  Self.maxNBackups := maxNBackups;
end;

function TSimSEEEditOptions.Rec: TCosa_RecLnk;
begin
  Result:=inherited Rec;
  Result.addCampoDef('fechasAutomaticas', fechasAutomaticas, 0, 14 );
  Result.addCampoDef('libPath', fLibPath, 0, 14 );
  Result.addCampoDef('fechasAutomaticas', fechasAutomaticas, 14, 15 );
  Result.addCampoDef('deshabilitarScrollHorizontalEnListados', deshabilitarScrollHorizontalEnListados, 14, 15 );
  Result.addCampoDef('libPath', fLibPath, 14, 15 );
  Result.addCampoDef('fechasAutomaticas', fechasAutomaticas, 15 );
  Result.addCampoDef('deshabilitarScrollHorizontalEnListados', deshabilitarScrollHorizontalEnListados, 15 );
  Result.addCampoDef('libPath', fLibPath, 15 );
  Result.addCampoDef('guardarBackupDeArchivos', guardarBackupDeArchivos, 15 );
  Result.addCampoDef('maxNBackups', maxNBackups, 15 );
end;

procedure TSimSEEEditOptions.BeforeRead(version, id_hilo: integer);
begin
  inherited BeforeRead(version, id_hilo);
  if opciones <> nil then
    raise Exception.Create(
      'TSimSEEEditOptions.Create_ReadFromText: Error se esta creando una segunda instancia de TSimSEEEditOptions');
end;

procedure TSimSEEEditOptions.AfterRead(version, id_hilo: integer);
begin
  inherited AfterRead(version, id_hilo);
  if Version < 14 then
  begin
    setLibPath(libPath);
    deshabilitarScrollHorizontalEnListados := True;
    guardarBackupDeArchivos := True;
    maxNBackups := 10;
  end
  else if Version < 15 then
  begin
    setLibPath(libPath);
    guardarBackupDeArchivos := True;
    maxNBackups := 10;
  end
  else
  begin
    setLibPath(libPath);
  end;
end;

class function TSimSEEEditOptions.getInstance: TSimSEEEditOptions;
var
  archi_cfg: string;
  f: TArchiTexto;
  Catalogo: TCatalogoReferencias;
begin
  if opciones = nil then
  begin
    archi_cfg := getDir_Bin + configFile_;
    if FileExists(archi_cfg) then
    begin
      try
        f := nil;
        Catalogo := TCatalogoReferencias.Create;
        f := TArchiTexto.CreateForRead(0, Catalogo, archi_cfg, True);
        f.rd('opciones', TCosa(opciones));
        f.Free;
        Catalogo.Free;
      except
        ShowMessage(mesErrorLeyendoArchivoPref + mesUsaronValoresXDefecto);
        if f <> nil then
          f.Free;
        DeleteFile(archi_cfg);
        opciones := TSimSEEEditOptions.Create(0, True, True,
          uconstantesSimSEE.getDir_Lib, True, 10);
      end;
    end
    else
    begin
      opciones := TSimSEEEditOptions.Create(0, True, False,
        uconstantesSimSEE.getDir_Lib, True, 10);
    end;
  end;
  Result := opciones;
end;



procedure TSimSEEEditOptions.setLibPath(newLibPath: string);
begin
  //Si no es una url de red le pongo la letra de unidad
  if (pos('\\', newLibPath) <> 1) and (pos(':\', newLibPath) = 0) then
    fLibPath := ExtractFileDrive(getDir_Bin) + newLibPath
  else
    fLibPath := newLibPath;
  if (Length(fLibPath) = 0) or (fLibPath[Length(fLibPath)] <> DirectorySeparator) then
    fLibPath := fLibPath + DirectorySeparator;

  if not DirectoryExists(fLibPath) then
    if not ForceDirectories(fLibPath) then
      raise Exception.Create(
        'TSimSEEEditOptions.setLibPath: No se puede acceder al directorio ' +
        newLibPath);
end;

procedure TSimSEEEditOptions.guardar;
var
  f: TArchiTexto;
begin
  f := nil;
  try
    ucosa.procMsgValorPorDefecto := nil;
    f := TArchiTexto.CreateForWrite(getDir_Bin + configFile_, False, 0);
    f.wr('opciones', self );
  finally
    if f <> nil then
      f.Free;
  end;
end;

procedure TSimSEEEditOptions.Free;
begin
//  opciones := nil;
  self.Free;
end;

end.
