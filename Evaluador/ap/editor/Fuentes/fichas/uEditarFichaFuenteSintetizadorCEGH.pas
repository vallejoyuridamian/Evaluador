   unit uEditarFichaFuenteSintetizadorCEGH;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
{$IFDEF FPC-LCL}
{$ENDIF}
  SysUtils, Classes, Controls,
  Dialogs, Grids, uBaseEditoresFichas, uFichasLPD,
  uSalasDeJuego,
  StdCtrls, ExtCtrls, uFuenteSintetizador, utilidades,
  umodelosintcegh, uconstantessimsee,
  uFechas, uExcelFile, uExcelExportImport, xMatDefs,
  uverdoc;

resourcestring
  rsBorne = 'Borne';
  rsModificadorValorEsperado = 'Modificador del valor esperado[p.u]';
  rsModificadorDesviacionEstandar = 'Modificador de la desviación estandar[p.u]';

type
  TEditarFichaFuenteSintetizadorCEGH = class(TBaseEditoresFichas)
    BGuardar: TButton;
    BCancelar: TButton;
    sgFicha: TStringGrid;
    LFIni: TLabel;
    EFIni: TEdit;
    CBPeriodicidad: TCheckBox;
    PPeriodicidad: TPanel;
    LFinPeriodo: TLabel;
    LIniPeriodo: TLabel;
    LLargoPeriodo: TLabel;
    EFFinPeriodo: TEdit;
    EFIniPeriodo: TEdit;
    sgPeriodicidad: TStringGrid;
    ELargoPeriodo: TEdit;
    CBLargoPeriodo: TComboBox;
    BAyuda: TButton;
    BObservarValores: TButton;
    cbMultiplicar_VM: TCheckBox;
    CBModificadoresRelativosVE: TCheckBox;
    procedure FormResize(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure CBPeriodicidadClick(Sender: TObject);
    procedure EditEnter(Sender: TObject);
    procedure EditExit(Sender: TObject);
    procedure CBLargoPeriodoChange(Sender: TObject);
    procedure sgChequearCambios(Sender: TObject);
    procedure sgGetEditText(Sender: TObject; ACol, ARow: Integer;
      var Value: string);
    procedure sgChequearCambiosKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure BCancelarClick(Sender: TObject);
    procedure BGuardarClick(Sender: TObject); override;
    procedure BObservarValoresClick(Sender: TObject);
    procedure BAyudaClick(Sender: TObject);
  private
    xls: TExcelFile;
    datosModelo: TModeloSintetizadorCEGH;
  protected
    function validarTablaMultiplicadoresVEsStdDev: Boolean;
    function validarFormulario: Boolean; override;
  public
    Constructor Create(AOwner: TComponent; nombreFuente: String;
      datosModelo: TModeloSintetizadorCEGH; ficha: TFichaLPD;
      sala: TSalaDeJuego); reintroduce;
  end;

implementation

{$IFNDEF FPC-LCL}
  {$R *.dfm}
{$ELSE}
  {$R *.lfm}
{$ENDIF}
procedure TEditarFichaFuenteSintetizadorCEGH.BAyudaClick(Sender: TObject);
begin
  verdoc(self, 'ficha_sintetizadorCEGH', 'Ficha CEGH');
end;

procedure TEditarFichaFuenteSintetizadorCEGH.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarFichaFuenteSintetizadorCEGH.BGuardarClick(Sender: TObject);
var
  periodicidad: TPeriodicidad;
  multiplicadoresVEs, multiplicadoresStdDev: TDAofNReal;
  i: Integer;
begin
  if validarFormulario then
  begin
    if CBPeriodicidad.Checked then
      periodicidad := inherited darPeriodicidad(CBLargoPeriodo, ELargoPeriodo,
        EFIniPeriodo, EFFinPeriodo, sgPeriodicidad)
    else
      periodicidad := NIL;

    SetLength(multiplicadoresVEs, sgFicha.RowCount - 1);
    SetLength(multiplicadoresStdDev, length(multiplicadoresVEs));
    for i := 0 to high(multiplicadoresVEs) do
    begin
      multiplicadoresVEs[i] := StrToFloat(sgFicha.Cells[1, i + 1]);
      multiplicadoresStdDev[i] := StrToFloat(sgFicha.Cells[2, i + 1]);
    end;

    ficha := TFichaFuenteSintetizadorCEGH.Create(TFecha.Create_Str(EFIni.Text),
      periodicidad, CBModificadoresRelativosVE.Checked, cbMultiplicar_VM.Checked,
      multiplicadoresVEs, multiplicadoresStdDev);

    modalResult := mrOk;
  end
end;

procedure TEditarFichaFuenteSintetizadorCEGH.BObservarValoresClick
  (Sender: TObject);
begin
  uExcelExportImport.exportarPromStdDevDatosModeloCEGHAExcel(xls, datosModelo);
end;

procedure TEditarFichaFuenteSintetizadorCEGH.CBLargoPeriodoChange
  (Sender: TObject);
begin
  guardado := false;
end;

procedure TEditarFichaFuenteSintetizadorCEGH.CBPeriodicidadClick
  (Sender: TObject);
begin
  inherited switchPanelPeriodicidad(CBPeriodicidad, PPeriodicidad);
end;

Constructor TEditarFichaFuenteSintetizadorCEGH.Create(AOwner: TComponent;
  nombreFuente: String; datosModelo: TModeloSintetizadorCEGH; ficha: TFichaLPD;
  sala: TSalaDeJuego);
var
  i: Integer;
  fichaCast: TFichaFuenteSintetizadorCEGH;
begin
  inherited Create(AOwner, nombreFuente, TFuenteSintetizadorCEGH, ficha, sala);
  inherited llenarCamposPeriodicidad(CBLargoPeriodo, ELargoPeriodo,
    EFIniPeriodo, EFFinPeriodo, sgPeriodicidad, CBPeriodicidad,
    ficha, PPeriodicidad);

  self.datosModelo := datosModelo;
  xls := NIL;
  sgFicha.RowCount := datosModelo.nBornesSalida + 1;
  sgFicha.Cells[0, 0] := rsBorne;
  sgFicha.Cells[1, 0] := rsModificadorValorEsperado;
  sgFicha.Cells[2, 0] := rsModificadorDesviacionEstandar;
  for i := 0 to datosModelo.NombresDeBornes_Publicados.Count - 1 do
    sgFicha.Cells[0, i + 1] := datosModelo.NombresDeBornes_Publicados[i];

  if ficha <> NIL then
  begin
    fichaCast := TFichaFuenteSintetizadorCEGH(ficha);

    EFIni.Text := ficha.fecha.AsStr;
    for i := 0 to high(fichaCast.modificadoresValEsp) do
    begin
      sgFicha.Cells[1, i + 1] := FloatToStrF(fichaCast.modificadoresValEsp[i],
        ffGeneral, 10, 3);
      sgFicha.Cells[2, i + 1] := FloatToStrF(fichaCast.modificadoresDevEst[i],
        ffGeneral, 10, 3);
    end;

    CBModificadoresRelativosVE.Checked := fichaCast.modificadoresRelativosVE;
    cbMultiplicar_VM.Checked := fichaCast.multiplicar_vm;
  end;

  for i := 0 to sgFicha.ColCount - 1 do
    utilidades.AutoSizeCol(sgFicha, i);
  utilidades.AutoSizeTable(self, sgFicha,
    uconstantessimsee.CP_MAXANCHOTABLAMUYGRANDE,
    uconstantessimsee.CP_MAXALTURATABLAMUYGRANDE, false);
  BObservarValores.Left := sgFicha.Left + sgFicha.Width + plusWidth;
end;

procedure TEditarFichaFuenteSintetizadorCEGH.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
  if CanClose and (xls <> NIL) then
    xls.Free;
end;

procedure TEditarFichaFuenteSintetizadorCEGH.FormResize(Sender: TObject);
begin
  utilidades.centrar2Botones(self, BGuardar, BCancelar);
end;

procedure TEditarFichaFuenteSintetizadorCEGH.sgGetEditText(Sender: TObject;
  ACol, ARow: Integer; var Value: string);
begin
  inherited sgGetEditText(Sender, ACol, ARow, Value);
end;

procedure TEditarFichaFuenteSintetizadorCEGH.sgChequearCambiosKeyDown
  (Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  inherited sgChequearCambiosKeyDown(Sender, Key, Shift);
end;

procedure TEditarFichaFuenteSintetizadorCEGH.sgChequearCambios(Sender: TObject);
begin
  inherited sgChequearCambios(Sender);
end;

function TEditarFichaFuenteSintetizadorCEGH.validarTablaMultiplicadoresVEsStdDev
  : Boolean;
var
  multiplicadoresVEs, multiplicadoresStdDev: TDAofNReal;
  histogramasAlterados: TMatOf_ddp_VectDeMuestras;
begin
  if inherited validarTablaNReals_(sgFicha) then
  begin
    histogramasAlterados := NIL;
    try
      multiplicadoresVEs := columnaTablaNReals(sgFicha, 1);
      multiplicadoresStdDev := columnaTablaNReals(sgFicha, 2);
      histogramasAlterados := createNilTMatOf_ddp_VectDeMuestras
        (datosModelo.nBornesSalida,
        length(datosModelo.funcionesDeformantes[0]));

      calcularNuevosDeformadores(datosModelo.funcionesDeformantes,
        CBModificadoresRelativosVE.Checked, cbMultiplicar_VM.Checked,
        multiplicadoresVEs, multiplicadoresStdDev, histogramasAlterados);
      freeTMatOf_ddp_VectDeMuestras(histogramasAlterados);
      result := true;
    Except
      on E: Exception do
      begin
        if histogramasAlterados <> NIL then
          freeTMatOf_ddp_VectDeMuestras(histogramasAlterados);
        ShowMessage(E.Message);
        result := false;
      end;
    end;
  end
  else
    result := false;
end;

function TEditarFichaFuenteSintetizadorCEGH.validarFormulario: Boolean;
begin
  result := inherited validarEditFecha(EFIni) and inherited validarPeriodicidad
    (CBPeriodicidad, CBLargoPeriodo, ELargoPeriodo, EFIni, EFFinPeriodo,
    sgPeriodicidad) and validarTablaMultiplicadoresVEsStdDev;
end;

procedure TEditarFichaFuenteSintetizadorCEGH.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarFichaFuenteSintetizadorCEGH.EditExit(Sender: TObject);
begin
  inherited EditExit(Sender);
end;

initialization
end.
