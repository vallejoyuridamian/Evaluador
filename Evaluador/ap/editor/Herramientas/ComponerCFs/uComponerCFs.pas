unit uComponerCFs;
interface

uses
{$IFDEF WINDOWS}
Windows,
{$ENDIF}
  Messages, SysUtils, Variants, Classes, Graphics, Grids, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, utilidades, uEstados, uFechas,
  uCompositorCFs, uBaseFormularios,
 uverdoc;

resourcestring
  rsArchivoCF = 'ArchivoCF';
  rsFechaDeInicio = 'Fecha de Inicio';
  rsFechaDeFin = 'Fecha de Fin';
  rsValeDesde = 'Vale Desde';

  mesElArchivoDeCostosFuturosSeCreoSatisfactoriamenteEn =
    'El archivo de costos futuros se creo satisfactoriamente en ';

type

  { TComponerCFs }

  TComponerCFs = class(TBaseFormularios)
    gbDatosDelCF: TGroupBox;
    lFechaDeInicio: TLabel;
    eFechaDeInicio: TEdit;
    lHorasDelPaso: TLabel;
    eHorasDelPaso: TEdit;
    eFechaDeFin: TEdit;
    lFechaDeFin: TLabel;
    gbCostosFuturosAComponer: TGroupBox;
    sgCFsAComponer: TStringGrid;
    pBotonera: TPanel;
    bComponerCostosFuturos: TButton;
    SaveDialog1: TSaveDialog;
    OpenDialog1: TOpenDialog;
    pBAgregarCF: TPanel;
    bAgregarCF: TButton;
    bAyuda: TButton;
    procedure bAgregarCFClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure sgCFsAComponerDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure sgCFsAComponerMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure sgCFsAComponerMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure sgCFsAComponerMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure bComponerCostosFuturosClick(Sender: TObject);
    procedure bAyudaClick(Sender: TObject);
    procedure sgCFsAComponerValidarCambio(Sender: TObject);
    procedure sgCFsAComponerGetEditText(Sender: TObject; ACol, ARow: Integer;
      var Value: string);
  private
    tiposCols: TDAOfTTipoColumna;
    compositorCFs: TCompositorCFs;
    formatoFechas: String;

    procedure actualizarVista;

    function validarCambioCelda(listado: TStringGrid;
      fila, columna: Integer): boolean;
    procedure cambiarValorCelda(listado: TStringGrid; fila, columna: Integer);
  end;

implementation
{$R *.lfm}
{ TComponerCFs }

const
  iColumnaValeDesde = 3;

procedure TComponerCFs.actualizarVista;
var
  i: Integer;
  cfAComponer: TCFAComponer;
begin
  eHorasDelPaso.Text := FloatToStr(compositorCFs.horasDelPaso);
  eFechaDeInicio.Text := FormatDateTime(formatoFechas,
    compositorCFs.fechaDeInicio);
  eFechaDeFin.Text := FormatDateTime(formatoFechas, compositorCFs.fechaDeFin);

  sgCFsAComponer.RowCount := compositorCFs.listaCFsAComponer.Count + 1;
  if sgCFsAComponer.RowCount > 1 then
    sgCFsAComponer.FixedRows := 1;

  for i := 0 to compositorCFs.listaCFsAComponer.Count - 1 do
  begin
    cfAComponer := TCFAComponer(compositorCFs.listaCFsAComponer[i]);

    sgCFsAComponer.Cells[0, i + 1] := cfAComponer.archivoCF;
    sgCFsAComponer.Cells[1, i + 1] := FormatDateTime(formatoFechas,
      cfAComponer.fechaDeInicio);
    sgCFsAComponer.Cells[2, i + 1] := FormatDateTime(formatoFechas,
      cfAComponer.fechaDeFin);
    sgCFsAComponer.Cells[3, i + 1] := FormatDateTime(formatoFechas,
      cfAComponer.valeDesde);
  end;

  for i := 0 to sgCFsAComponer.ColCount - 1 do
    AutoSizeTypedCol(sgCFsAComponer, i, tiposCols[i], iconos);
end;

procedure TComponerCFs.bAgregarCFClick(Sender: TObject);
var
  nuevoArchiCF, msjError: String;
begin
  if OpenDialog1.Execute then
  begin
    nuevoArchiCF := OpenDialog1.FileName;
    msjError := compositorCFs.agregarCF(nuevoArchiCF);

    if msjError = '' then
      actualizarVista
    else
      MessageDlg(msjError, mtError, [mbOK], 0);
  end;
end;

procedure TComponerCFs.FormCreate(Sender: TObject);
begin
  utilidades.initListado(sgCFsAComponer, [rsArchivoCF, rsFechaDeInicio,
    rsFechaDeFin, encabezadoTextoEditable + rsValeDesde, encabezadoBTEliminar],
    tiposCols, False);

  formatoFechas := ShortDateFormat + ' hh' + TimeSeparator + 'nn';
  compositorCFs := TCompositorCFs.Create(formatoFechas);

  actualizarVista;
end;

procedure TComponerCFs.bAyudaClick(Sender: TObject);
begin
  uverdoc.verdoc(self, TComponerCFs);
end;

procedure TComponerCFs.bComponerCostosFuturosClick(Sender: TObject);
begin
  if SaveDialog1.Execute then
  begin
    compositorCFs.componerCFs(SaveDialog1.FileName);
    MessageDlg(mesElArchivoDeCostosFuturosSeCreoSatisfactoriamenteEn + '"' +
        SaveDialog1.FileName + '"', mtInformation, [mbOK], 0);
  end;
end;

function TComponerCFs.validarCambioCelda(listado: TStringGrid;
  fila, columna: Integer): boolean;
var
  fecha: TDateTime;
begin
  case columna of
    iColumnaValeDesde:
      Result := TryStrToDateTime(listado.Cells[columna, fila], fecha)
        and compositorCFs.valeDesdeValido(fila - 1, fecha);
  else
    Result := True;
  end;
end;

procedure TComponerCFs.cambiarValorCelda(listado: TStringGrid;
  fila, columna: Integer);
var
  fecha: TDateTime;
begin
  case columna of
    iColumnaValeDesde:
      begin
        fecha := StrToDateTime(listado.Cells[columna, fila]);
        compositorCFs.cambiarValeDesdeCF(fila - 1, fecha);
        actualizarVista;
      end;
  end;
end;


procedure TComponerCFs.sgCFsAComponerDrawCell(Sender: TObject;
  ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
begin
  utilidades.ListadoDrawCell(Sender, ACol, ARow, Rect, State, tiposCols[ACol],
    NIL, iconos, validarCambioCelda);
end;

procedure TComponerCFs.sgCFsAComponerGetEditText(Sender: TObject;
  ACol, ARow: Integer; var Value: string);
begin
  utilidades.listadoGetEditText(Sender, ACol, ARow);
end;


procedure TComponerCFs.sgCFsAComponerMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  utilidades.ListadoMouseDown(Sender, Button, Shift, X, Y);
end;

procedure TComponerCFs.sgCFsAComponerMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  utilidades.ListadoMouseMove(Sender, Shift, X, Y, tiposCols, []);
end;

procedure TComponerCFs.sgCFsAComponerMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  res: TTipoColumna;
begin
  res := utilidades.ListadoMouseUp(Sender, Button, Shift, X, Y, tiposCols);
  case res of
    TC_btEliminar:
      begin
        compositorCFs.eliminarCF(utilidades.filaListado - 1);
        actualizarVista;
      end;
  end;
end;

procedure TComponerCFs.sgCFsAComponerValidarCambio(Sender: TObject);
begin
  utilidades.listadoValidarCambio(Sender, tiposCols, validarCambioCelda,
    cambiarValorCelda);
end;

end.
