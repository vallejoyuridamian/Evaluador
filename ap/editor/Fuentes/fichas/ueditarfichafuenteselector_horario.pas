unit uEditarFichaFuenteSelector_horario;

interface

uses
   {$IFDEF WINDOWS}
  Windows,
  {$ELSE}
  LCLType,
  {$ENDIF}
 Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uBaseEditoresFichas, StdCtrls, Grids, ExtCtrls, ComCtrls, uCosa,
  uCosaConNombre, uBaseEditores, uFuentesAleatorias, uFuenteSelector_horario,
  uFichasLPD, uSalasDeJuego, uverdoc, utilidades, uFechas, xMatDefs, types;

type

  { TEditarFichaFuenteSelector_horario }

  TEditarFichaFuenteSelector_horario = class(TBaseEditoresFichas)
    CBBorneA: TComboBox;
    CBBorneB: TComboBox;
    CBBorneC: TComboBox;
    CBBorneD: TComboBox;
    CBFuenteA: TComboBox;
    CBFuenteB: TComboBox;
    CBFuenteC: TComboBox;
    CBFuenteD: TComboBox;
    cbUsarTiposDeDia: TCheckBox;
    eHorarioA_HABIL: TEdit;
    eHorarioA_SEMI_FERIADO: TEdit;
    eHorarioA_FERIADO: TEdit;
    eHorarioB_HABIL: TEdit;
    eHorarioB_SEMI_FERIADO: TEdit;
    eHorarioB_FERIADO: TEdit;
    eHorarioC_HABIL: TEdit;
    eHorarioC_SEMI_FERIADO: TEdit;
    eHorarioC_FERIADO: TEdit;
    eHorarioD_HABIL: TEdit;
    eHorarioD_SEMI_FERIADO: TEdit;
    eHorarioD_FERIADO: TEdit;
    eValorPorDefecto_HABIL: TEdit;
    eValorPorDefecto_SEMI_FERIADO: TEdit;
    eValorPorDefecto_FERIADO: TEdit;
    gb_DiasSemiFeriados: TGroupBox;
    gb_DiasFeriados: TGroupBox;
    GroupBox1: TGroupBox;
    gb_FuentesDeEntrada: TGroupBox;
    gb_DiasHabiles: TGroupBox;
    Label1: TLabel;
    lbl_Fecha: TLabel;
    LFIni: TLabel;
    BGuardar: TButton;
    BCancelar: TButton;
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
    procedure cbUsarTiposDeDiaChange(Sender: TObject);
    procedure EditEnter(Sender: TObject);
    procedure EditExit(Sender: TObject);
    procedure BAyudaClick(Sender: TObject);
    procedure CBPeriodicidadClick(Sender: TObject);
    procedure CBLargoPeriodoChange(Sender: TObject);
    procedure eHorarioD_HABILChange(Sender: TObject);
    procedure sgChequearCambios(Sender: TObject);
    procedure sgGetEditText(Sender: TObject; ACol, ARow: integer;
      var Value: string);
    procedure sgChequearCambiosKeyDown(Sender: TObject; var Key: word;
      Shift: TShiftState);
    procedure CBFuenteAChange(Sender: TObject);
    procedure CBFuenteBChange(Sender: TObject);
    procedure CBFuenteCChange(Sender: TObject);
    procedure CBFuenteDChange(Sender: TObject);

    procedure CambiosForm(Sender: TObject);
    procedure BCancelarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure BGuardarClick(Sender: TObject); override;
  private
  protected
    function validarFormulario: boolean; override;
  public
    constructor Create(AOwner: TComponent; cosaConNombre: TCosaConNombre;
      ficha: TFichaLPD; sala: TSalaDeJuego); override;
  end;

implementation

{$R *.lfm}

constructor TEditarFichaFuenteSelector_horario.Create(AOwner: TComponent;
  cosaConNombre: TCosaConNombre; ficha: TFichaLPD; sala: TSalaDeJuego);
var
  i, j: integer;
  af: TFichaFuenteSelector_horario;
  afh: TFuenteYHorario;

begin
  inherited Create(AOwner, cosaConNombre, ficha, sala);
  inherited  llenarCamposPeriodicidad(CBLargoPeriodo, ELargoPeriodo,
    EFIniPeriodo, EFFinPeriodo, sgPeriodicidad, CBPeriodicidad, ficha, PPeriodicidad);

  CBFuenteA.Items.Add(strFuenteNinguna);
  CBFuenteB.Items.Add(strFuenteNinguna);
  CBFuenteC.Items.Add(strFuenteNinguna);
  CBFuenteD.Items.Add(strFuenteNinguna);

  for i := 0 to sala.listaFuentes_.Count - 1 do
  begin
    CBFuenteA.Items.Add(TFuenteAleatoria(sala.listaFuentes_[i]).nombre);
    CBFuenteB.Items.Add(TFuenteAleatoria(sala.listaFuentes_[i]).nombre);
    CBFuenteC.Items.Add(TFuenteAleatoria(sala.listaFuentes_[i]).nombre);
    CBFuenteD.Items.Add(TFuenteAleatoria(sala.listaFuentes_[i]).nombre);
  end;

  CBFuenteA.ItemIndex := 0;
  CBFuenteB.ItemIndex := 0;
  CBFuenteC.ItemIndex := 0;
  CBFuenteD.ItemIndex := 0;

  cbUsarTiposDeDia.Checked := True;
  gb_DiasSemiFeriados.Enabled := True;
  gb_DiasFeriados.Enabled := True;

  if ficha <> nil then
  begin
    af := ficha as TFichaFuenteSelector_horario;

    EFIni.Text := ficha.fecha.AsStr;
    eValorPorDefecto_HABIL.Text := FloatToStr(af.ValorPorDefecto_HABIL);
    eValorPorDefecto_SEMI_FERIADO.Text := FloatToStr(af.ValorPorDefecto_SEMI_FERIADO);
    eValorPorDefecto_FERIADO.Text := FloatToStr(af.ValorPorDefecto_FERIADO);
    cbUsarTiposDeDia.Checked := af.usarTipoDeDia;
    if not cbUsarTiposDeDia.Checked then
    begin
      gb_DiasSemiFeriados.Enabled := False;
      gb_DiasFeriados.Enabled := False;
    end;
    if af.FuentesYHorarios.Count > 0 then
    begin

      afh := af.FuentesYHorarios.items[0] as TFuenteYHorario;

      inherited setCBFuente(CBFuenteA, CBBorneA,
        afh.fuente, afh.fuente.NombreBorne(afh.idBorne));
      eHorarioA_HABIL.Text := DAOfNIntToStr(afh.horario_HABIL, ';');
      eHorarioA_SEMI_FERIADO.Text := DAOfNIntToStr(afh.horario_SEMI_FERIADO, ';');
      eHorarioA_FERIADO.Text := DAOfNIntToStr(afh.horario_FERIADO, ';');
    end
    else
    begin
      inherited setCBFuente(CBFuenteA, CBBorneA,
        nil, '');
      eHorarioA_HABIL.Text := '';
      eHorarioA_SEMI_FERIADO.Text := '';
      eHorarioA_FERIADO.Text := '';
    end;

    if af.FuentesYHorarios.Count > 1 then
    begin
      afh := af.FuentesYHorarios.items[1] as TFuenteYHorario;
      inherited setCBFuente(CBFuenteB, CBBorneB,
        afh.fuente, afh.fuente.NombreBorne(afh.idBorne));
      eHorarioB_HABIL.Text := DAOfNIntToStr(afh.horario_HABIL, ';');
      eHorarioB_SEMI_FERIADO.Text := DAOfNIntToStr(afh.horario_SEMI_FERIADO, ';');
      eHorarioB_FERIADO.Text := DAOfNIntToStr(afh.horario_FERIADO, ';');
    end
    else
    begin
      inherited setCBFuente(CBFuenteB, CBBorneB,
        nil, '');
      eHorarioB_HABIL.Text := '';
      eHorarioB_SEMI_FERIADO.Text := '';
      eHorarioB_FERIADO.Text := '';
    end;

    if af.FuentesYHorarios.Count > 2 then
    begin
      afh := af.FuentesYHorarios.items[2] as TFuenteYHorario;
      inherited setCBFuente(CBFuenteC, CBBorneC,
        afh.fuente, afh.fuente.NombreBorne(afh.idBorne));
      eHorarioC_HABIL.Text := DAOfNIntToStr(afh.horario_HABIL, ';');
      eHorarioC_SEMI_FERIADO.Text := DAOfNIntToStr(afh.horario_SEMI_FERIADO, ';');
      eHorarioC_FERIADO.Text := DAOfNIntToStr(afh.horario_FERIADO, ';');
    end
    else
    begin
      inherited setCBFuente(CBFuenteC, CBBorneC,
        nil, '');
      eHorarioC_HABIL.Text := '';
      eHorarioC_SEMI_FERIADO.Text := '';
      eHorarioC_FERIADO.Text := '';
    end;

    if af.FuentesYHorarios.Count > 3 then
    begin
      afh := af.FuentesYHorarios.items[3] as TFuenteYHorario;
      inherited setCBFuente(CBFuenteD, CBBorneD,
        afh.fuente, afh.fuente.NombreBorne(afh.idBorne));
      eHorarioD_HABIL.Text := DAOfNIntToStr(afh.horario_HABIL, ';');
      eHorarioD_SEMI_FERIADO.Text := DAOfNIntToStr(afh.horario_SEMI_FERIADO, ';');
      eHorarioD_FERIADO.Text := DAOfNIntToStr(afh.horario_FERIADO, ';');
    end
    else
    begin
      inherited setCBFuente(CBFuenteD, CBBorneD,
        nil, '');
      eHorarioD_HABIL.Text := '';
      eHorarioD_SEMI_FERIADO.Text := '';
      eHorarioD_FERIADO.Text := '';
    end;
  end;
end;

function TEditarFichaFuenteSelector_horario.validarFormulario: boolean;
begin
  Result := inherited validarFormulario and validarEditFecha(EFIni) and
    inherited validarPeriodicidad(CBPeriodicidad, CBLargoPeriodo,
    ELargoPeriodo, EFIniPeriodo, EFFinPeriodo, sgPeriodicidad) and
    inherited validarCBFuente(CBFuenteA, CBBorneA, 0) and
    inherited validarCBFuente(CBFuenteB, CBBorneB, 0) and
    inherited validarCBFuente(CBFuenteC, CBBorneC, 0) and
    inherited validarCBFuente(CBFuenteD, CBBorneD, 0);
end;

procedure TEditarFichaFuenteSelector_horario.BAyudaClick(Sender: TObject);
begin
  verdoc(self, TFuenteSelector_horario);
end;

procedure TEditarFichaFuenteSelector_horario.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarFichaFuenteSelector_horario.BGuardarClick(Sender: TObject);
var
  periodicidad: TPeriodicidad;
  fuentesYHorarios: TListaDeCosas;
  afh: TFuenteYHorario;
  nombreFuente: string;
  nombreBorne: string;
  idBorne: integer;
  fuente: TFuenteAleatoria;
  usarTiposDeDia: boolean;
  horario_HABIL, horario_SEMI_FERIADO, horario_FERIADO: TDAofNInt;
  valorPorDefecto_HABIL, valorPorDefecto_SEMI_FERIADO, valorPorDefecto_FERIADO: NReal;

begin
  if validarFormulario then
  begin
    if CBPeriodicidad.Checked then
      periodicidad := inherited darPeriodicidad(CBLargoPeriodo,
        ELargoPeriodo, EFIniPeriodo, EFFinPeriodo, sgPeriodicidad)
    else
      periodicidad := nil;

    usarTiposDeDia := cbUsarTiposDeDia.Checked;
    valorPorDefecto_HABIL := StrToFloat(eValorPorDefecto_HABIL.Text);
    valorPorDefecto_SEMI_FERIADO := StrToFloat(eValorPorDefecto_SEMI_FERIADO.Text);
    valorPorDefecto_FERIADO := StrToFloat(eValorPorDefecto_FERIADO.Text);

    fuentesYHorarios := TListaDeCosasConNombre.Create(capa, 'FuentesYHorarios');

    fuente := valorCBFuente(CBFuenteA);
    if fuente <> nil then
    begin
      nombreBorne := valorCBString(CBBorneA);
      idBorne := fuente.IdBorne(nombreBorne);
      horario_HABIL := StrToDAOfNInt(eHorarioA_HABIL.Text, ';');
      horario_SEMI_FERIADO := StrToDAOfNInt(eHorarioA_SEMI_FERIADO.Text, ';');
      horario_FERIADO := StrToDAOfNInt(eHorarioA_FERIADO.Text, ';');
      afh := TFuenteYHorario.Create(fuente, idBorne, horario_HABIL,
        horario_SEMI_FERIADO, horario_FERIADO);
      fuentesYHorarios.add(afh);
    end;

    fuente := valorCBFuente(CBFuenteB);
    if fuente <> nil then
    begin
      nombreBorne := valorCBString(CBBorneB);
      idBorne := fuente.IdBorne(nombreBorne);
      horario_HABIL := StrToDAOfNInt(eHorarioB_HABIL.Text, ';');
      horario_SEMI_FERIADO := StrToDAOfNInt(eHorarioB_SEMI_FERIADO.Text, ';');
      horario_FERIADO := StrToDAOfNInt(eHorarioB_FERIADO.Text, ';');
      afh := TFuenteYHorario.Create(fuente, idBorne, horario_HABIL,
        horario_SEMI_FERIADO, horario_FERIADO);
      fuentesYHorarios.add(afh);
    end;

    fuente := valorCBFuente(CBFuenteC);
    if fuente <> nil then
    begin
      nombreBorne := valorCBString(CBBorneC);
      idBorne := fuente.IdBorne(nombreBorne);
      horario_HABIL := StrToDAOfNInt(eHorarioC_HABIL.Text, ';');
      horario_SEMI_FERIADO := StrToDAOfNInt(eHorarioC_SEMI_FERIADO.Text, ';');
      horario_FERIADO := StrToDAOfNInt(eHorarioC_FERIADO.Text, ';');
      afh := TFuenteYHorario.Create(fuente, idBorne, horario_HABIL,
        horario_SEMI_FERIADO, horario_FERIADO);
      fuentesYHorarios.add(afh);
    end;

    fuente := valorCBFuente(CBFuenteD);
    if fuente <> nil then
    begin
      nombreBorne := valorCBString(CBBorneD);
      idBorne := fuente.IdBorne(nombreBorne);
      horario_HABIL := StrToDAOfNInt(eHorarioD_HABIL.Text, ';');
      horario_SEMI_FERIADO := StrToDAOfNInt(eHorarioD_SEMI_FERIADO.Text, ';');
      horario_FERIADO := StrToDAOfNInt(eHorarioD_FERIADO.Text, ';');
      afh := TFuenteYHorario.Create(fuente, idBorne, horario_HABIL,
        horario_SEMI_FERIADO, horario_FERIADO);
      fuentesYHorarios.add(afh);
    end;

    ficha := TFichaFuenteSelector_horario.Create( capa,
      TFecha.Create_Str(EFIni.Text), periodicidad, usarTiposDeDia,
      fuentesYHorarios, valorPorDefecto_HABIL, valorPorDefecto_SEMI_FERIADO,
      valorPorDefecto_FERIADO);
    modalResult := mrOk;
  end;
end;




procedure TEditarFichaFuenteSelector_horario.CambiosForm(Sender: TObject);
begin
  inherited cambiosForm(Sender);
end;

procedure TEditarFichaFuenteSelector_horario.CBFuenteAChange(Sender: TObject);
begin
  inherited cbFuenteChange(CBFuenteA, CBBorneA);
end;

procedure TEditarFichaFuenteSelector_horario.CBFuenteBChange(Sender: TObject);
begin
  inherited cbFuenteChange(CBFuenteB, CBBorneB);
end;


procedure TEditarFichaFuenteSelector_horario.CBFuenteCChange(Sender: TObject);
begin
  inherited cbFuenteChange(CBFuenteC, CBBorneC);
end;

procedure TEditarFichaFuenteSelector_horario.CBFuenteDChange(Sender: TObject);
begin
  inherited cbFuenteChange(CBFuenteD, CBBorneD);
end;

procedure TEditarFichaFuenteSelector_horario.CBLargoPeriodoChange(Sender: TObject);
begin
  guardado := False;
end;

procedure TEditarFichaFuenteSelector_horario.eHorarioD_HABILChange(Sender: TObject);
begin

end;


procedure TEditarFichaFuenteSelector_horario.CBPeriodicidadClick(Sender: TObject);
begin
  inherited switchPanelPeriodicidad(CBPeriodicidad, PPeriodicidad);
end;

procedure TEditarFichaFuenteSelector_horario.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarFichaFuenteSelector_horario.cbUsarTiposDeDiaChange(Sender: TObject);
begin
  guardado := False;
  if cbUsarTiposDeDia.Checked then
  begin
    gb_DiasFeriados.Enabled := True;
    gb_DiasSemiFeriados.Enabled := True;
  end
  else
  begin
    gb_DiasFeriados.Enabled := False;
    gb_DiasSemiFeriados.Enabled := False;
  end;
end;

procedure TEditarFichaFuenteSelector_horario.EditExit(Sender: TObject);
begin
  inherited EditExit(Sender);
end;

procedure TEditarFichaFuenteSelector_horario.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

procedure TEditarFichaFuenteSelector_horario.FormCreate(Sender: TObject);
begin
  utilidades.AgregarFormatoFecha(LFIni);
end;

procedure TEditarFichaFuenteSelector_horario.sgGetEditText(Sender: TObject;
  ACol, ARow: integer; var Value: string);
begin
  inherited sgGetEditText(Sender, ACol, ARow, Value);
end;

procedure TEditarFichaFuenteSelector_horario.sgChequearCambiosKeyDown(Sender: TObject;
  var Key: word; Shift: TShiftState);
begin
  inherited sgChequearCambiosKeyDown(Sender, Key, Shift);
end;

procedure TEditarFichaFuenteSelector_horario.sgChequearCambios(Sender: TObject);
begin
  inherited sgChequearCambios(sgPeriodicidad);
end;

end.


