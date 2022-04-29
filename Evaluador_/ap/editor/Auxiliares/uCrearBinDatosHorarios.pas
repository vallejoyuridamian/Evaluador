unit uCrearBinDatosHorarios;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
{$IFDEF FPC-LCL}
  LResources,
  EditBtn,
{$ENDIF}

{$IFDEF WINDOWS}
Windows,
{$ENDIF}
 Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, StdCtrls, uBaseFormularios, utilidades, uconstantesSimSEE, xMatDefs,
  uimpvnreal, uDatosHorariosDetallados, Math, ComCtrls, uverdoc, uopencalcexportimport,
  uOpcionesSimSEEEdit;

resourcestring
  rs_Hora = 'Hora';
  rs_Demanda = 'Demanda[MW]';
  rs_ArchivoBinario = 'Archivo Binario';
  rs_TodosLosArchivos = 'Todos los archivos';
  rs_MesError = 'Error: ';
  rs_DocAyudaCreadorArchivosBinarios = 'Ayuda del Creador de Archivos Binarios';
  rs_ExCantMaximaHorasAdmisibles = 'La cantidad máxima de horas admisibles es 65535';

type

  { TCrearBinDatosHorarios }

  TCrearBinDatosHorarios = class(TBaseFormularios)
    eFechaIni: TEdit;
    eFechaFin: TEdit;
    SaveDialog1: TSaveDialog;
    BGuardar: TButton;
    BCancelar: TButton;
    LFIni: TLabel;
    LNDatos: TLabel;
    ENDatos: TEdit;
    LFFin: TLabel;
    {$IFNDEF FPC-LCL}
      DTPFIni: TDateTimePicker;
      DTPFFin: TDateTimePicker;
    {$ELSE}
    {$ENDIF}
    BAyuda: TButton;
    BExportar_ods: TButton;
    BImportar_ods: TButton;
    ProgressBar1: TProgressBar;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure EditEnter(Sender: TObject);
    procedure EditExit(Sender: TObject);
    procedure BCancelarClick(Sender: TObject);
    procedure BGuardarClick(Sender: TObject); override;
    procedure sgValidarCambio(Sender: TObject);
    procedure sgGetEditText(Sender: TObject; ACol, ARow: Integer;
      var Value: String);
    procedure sgKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure DTPChange(Sender: TObject);
    procedure BAyudaClick(Sender: TObject);
    procedure BExportar_odsClick(Sender: TObject);
    procedure BImportar_odsClick(Sender: TObject);
  private
    fechaIni: TDateTime;
    fechaFin: TDateTime;
    datos: TDAofNReal;

    procedure recalcCantHoras;
  public
    Constructor Create(Owner: TComponent); reintroduce; overload;
    Constructor Create(Owner: TComponent; fIni, fFin: TDateTime); reintroduce; overload;
    Constructor Create(Owner: TComponent; archi: string); reintroduce; overload;
    function darNombreArch: String;
  end;

implementation
{$R *.lfm}


Constructor TCrearBinDatosHorarios.Create(Owner: TComponent);
begin
  inherited Create(Owner);
  recalcCantHoras;
end;


Constructor TCrearBinDatosHorarios.Create(Owner: TComponent; archi: string );
var
  adhd: TDatosHorariosDetallados;
  cantHoras: integer;
begin
  inherited Create(Owner);
  adhd:= TDatosHorariosDetallados.Create( archi, nil );
  fechaIni:= adhd.fechaPrimerDia;
  fechaFin:= adhd.fechaUltimoDia;
  eFechaIni.text:= DateTimeToStr( fechaIni );
  eFechaFin.text:= DateTimeToStr( fechaFin );
  recalcCantHoras;
  cantHoras:= ceil( fechaFin-FechaIni) * 24;
  setlength( datos, cantHoras );
  adhd.ReadBuff_horario( datos, fechaIni );
  adhd.Free;
end;


Constructor TCrearBinDatosHorarios.Create(Owner: TComponent ; fIni, fFin: TDateTime);
begin
  inherited Create(Owner);
  eFechaIni.text:= DateTimeToStr( fini );
  eFechaFin.text:= DateTimeToStr( ffin );
  fechaIni:= fIni;
  fechaFin:= fFin;
  recalcCantHoras;
end;

procedure TCrearBinDatosHorarios.recalcCantHoras;
var
  cantHoras, nAnt, i: Integer;
  pmin, pmed, pmax: NReal;

begin
  FechaIni:= StrToDateTime( trim( eFechaIni.text ));
  FechaFin:= StrToDateTime( trim( eFechaFin.text ));
  cantHoras:= ceil( fechaFin-FechaIni) * 24;
  if length( datos ) <> cantHoras then
    setlength( datos, cantHoras );
  ENDatos.Text:= IntToStr(cantHoras);

  if length( datos ) > 0 then
  begin
    pmin:= datos[0];
    pmax:= datos[0];
    pmed:= datos[0];
    for i:= 1 to high( datos ) do
    begin
      if datos[i] < pmin then pmin:= datos[i]
      else if datos[i] > pmax then pmax:= datos[i];
      pmed:= pmed + datos[i];
    end;
    pmed:= pmed / length( datos );
  end
  else
  begin
    pmin:= 0.0;
    pmax:= 0.0;
    pmed:= 0.0;
  end;


  guardado:= false;
end;

function TCrearBinDatosHorarios.darNombreArch: String;
begin
  result:= SaveDialog1.FileName;
end;

procedure TCrearBinDatosHorarios.DTPChange(Sender: TObject);
begin
end;


procedure TCrearBinDatosHorarios.FormCreate(Sender: TObject);
var
  i: Integer;
begin
  if Owner is TControl then
  begin
    self.Top:= TControl(Owner).Top + utilidades.plusTop;
    self.Left:= TControl(Owner).Left + utilidades.plusLeft;
  end;
  guardado:= true;

  SaveDialog1.InitialDir:= getDir_DatosComunes;
  SaveDialog1.Filter:= rs_ArchivoBinario+' (*.bin)|*.bin|'+ rs_TodosLosArchivos +' (*.*)|*.*';
  SaveDialog1.DefaultExt:= 'bin';
end;


procedure TCrearBinDatosHorarios.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

procedure TCrearBinDatosHorarios.BAyudaClick(Sender: TObject);
begin
// Atención no poner como resourcestring los tópicos de las ayudas.
// son los campos llaves de la base de datos de ayuda.
  verdoc(self, 'SimSEEEdit-CrearBinDatosHorarios', rs_DocAyudaCreadorArchivosBinarios);
end;

procedure TCrearBinDatosHorarios.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TCrearBinDatosHorarios.EditExit(Sender: TObject);
begin
  if TEdit(Sender).Text <> loQueHabia then
    guardado:= false;
end;

procedure TCrearBinDatosHorarios.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TCrearBinDatosHorarios.BExportar_odsClick(Sender: TObject);
begin
  recalcCantHoras;
  exportarDatosHorariosAODS( datos, fechaIni, BImportar_ods, ProgressBar1 );
end;


procedure TCrearBinDatosHorarios.BImportar_odsClick(Sender: TObject);
var
  dt1, dt2: NReal;
  ddt: NReal;
  s: string;

begin
  importarDatosHorariosDesdeODS( datos, fechaIni, BImportar_ods, ProgressBar1, true, true);
  fechaFin:= fechaIni + ceil( length( datos ) / 24 );

  s:= DateTimeToStr( fechaIni );
  eFechaIni.text:= s;
  s:= DateTimeToStr( fechaFin );
  eFechaFin.text:= s;

  recalcCantHoras;
end;

procedure TCrearBinDatosHorarios.BGuardarClick(Sender: TObject);
var
  i: Integer;
begin
  if validarFormulario and SaveDialog1.Execute then
  begin
    try
      TDatosHorariosDetallados.WriteToBin(SaveDialog1.FileName, FechaIni, FechaFin, datos);
      setlength( datos, 0 );
      modalResult:= mrOk;
    Except
      on E: Exception do
      begin
        ShowMessage(rs_MesError +' '+ E.Message);
        ModalResult:= mrAbort;
      end;
    end;
  end;
end;

procedure TCrearBinDatosHorarios.sgValidarCambio(Sender: TObject);
begin
  inherited validarCambioTablaNReals(TStringGrid(Sender));
end;

procedure TCrearBinDatosHorarios.sgGetEditText(Sender: TObject; ACol,
  ARow: Integer; var Value: String);
begin
  inherited sgGetEditText(Sender, ACol, ARow, Value);
end;

procedure TCrearBinDatosHorarios.sgKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  inherited sgKeyDown(Sender, Key, Shift);
end;

initialization
end.
