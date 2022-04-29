unit uBaseEditoresFichas;
  {$MODE Delphi}

interface

uses
  //  Windows,
  SysUtils, Classes, Controls, Forms, Dialogs,
  uCosaConNombre, ufichasLPD, utilidades, StdCtrls, ExtCtrls, Grids,
  usalasdejuego, uBaseFormularios,
  uOpcionesSimSEEEdit, xMatDefs, uBaseEditores;

resourcestring
  rsCiclosActiva = 'Ciclos Activa';
  rsCiclosInactiva = 'Ciclos Inactiva';
  rsDesplazamiento = 'Desplazamiento';
  mesValorIntroducidoDebeNumYMayor0 =
    'El valor ingresado debe ser numérico y mayor Que 0';

type

  { TBaseEditoresFichas }

  TBaseEditoresFichas = class(TBaseEditores)
  published
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure sgPeriodicidadValidarCambio(tabla: TStringGrid);
    procedure sgPeriodicidadKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
  protected


    function darPeriodicidad(CBLargo: TComboBox; ELPer, EFIni, EFFin: Tedit;
      integers: TStringGrid): TPeriodicidad;
    procedure llenarCamposPeriodicidad(CBLargo: TComboBox;
      ELPer, EFIni, EFFin: Tedit; integers: TStringGrid; cb: TCheckBox;
      ficha: TFichaLPD; panel: TPanel);
    procedure switchPanelPeriodicidad(cb: TCheckBox; panel: TPanel);
    function validarTablaPeriodicidad(sg: TStringGrid): boolean;
    function validarPeriodicidad(CBperiodicidad: Tcheckbox;
      CBLargo: TComboBox; ELPer, EFIni, EFFin: Tedit; integers: TStringGrid): boolean;
  private

  public

    ficha: TFichaLPD;

    constructor Create(AOwner: TComponent; nombreCosa: string;
      claseCosa: TClaseDeCosaConNombre; ficha: TFichaLPD; sala: TSalaDeJuego);
      reintroduce; overload; virtual;
    constructor Create(AOwner: TComponent; cosaConNombre: TCosaConNombre;
      ficha: TFichaLPD; sala: TSalaDeJuego); reintroduce; overload; virtual;
    function darFicha(): TFichaLPD;
    procedure Free;
  end;

  TClaseEditoresFichas = class of TBaseEditoresFichas;

implementation

uses SimSEEEditMain;
  {$R *.lfm}

constructor TBaseEditoresFichas.Create(AOwner: TComponent; nombreCosa: string;
  claseCosa: TClaseDeCosaConNombre; ficha: TFichaLPD; sala: TSalaDeJuego);
begin
  inherited Create(AOwner, ficha, sala);
  self.Top := TForm(Owner).Top + plusTop;
  self.Left := TForm(Owner).Left + plusLeft;
  if ficha = nil then
  begin
    self.Caption := 'Agregar ficha de "' + nombreCosa + '" ' + claseCosa.DescClase;
  end
  else
  begin
    self.Caption := 'Editar ficha de "' + nombreCosa + '" ' + claseCosa.DescClase;
  end;
  guardado := True;
end;

constructor TBaseEditoresFichas.Create(AOwner: TComponent;
  cosaConNombre: TCosaConNombre; ficha: TFichaLPD; sala: TSalaDeJuego);
begin
  inherited Create(AOwner, ficha, sala);
  self.Top := TForm(Owner).Top + plusTop;
  self.Left := TForm(Owner).Left + plusLeft;
  if cosaConNombre <> nil then
  begin
    if ficha = nil then
    begin
      self.Caption := 'Agregar ficha de "' + cosaConNombre.nombre +
        '" ' + cosaConNombre.DescClase;
    end
    else
    begin
      self.Caption := 'Editar ficha de  "' + cosaConNombre.nombre +
        '" ' + cosaConNombre.DescClase;
    end;
  end;
  //TODO pasar claseCosa
  guardado := True;
end;

function TBaseEditoresFichas.darFicha: TFichaLPD;
begin
  Result := ficha;
end;

function TBaseEditoresFichas.darPeriodicidad(CBLargo: TComboBox;
  ELPer, EFIni, EFFin: Tedit; integers: TStringGrid): TPeriodicidad;
var
  cant: NReal;
  tipo: TTipoPeriodicidad;
begin
  cant := StrToInt(ELPer.Text);
  case CBLargo.ItemIndex of
    0: // if CBLargo.Items[CBLargo.ItemIndex] = 'Años' then
    begin
      tipo := TP_Anual;
      cant := aniosTohoras(cant);
    end;
    1: // else if CBLargo.Items[CBLargo.ItemIndex] = 'Meses' then
    begin
      tipo := TP_Mensual;
      cant := mesesToHoras(cant);
    end;
    2://  else if CBLargo.Items[CBLargo.ItemIndex] = 'Semanas' then
    begin
      tipo := TP_Semanal;
      cant := semanasToHoras(cant);
    end;
    else
    begin
      tipo := TP_Diaria;
      cant := diasToHoras(cant);
    end;
  end;

  Result := TPeriodicidad.Create(FSimSEEEdit.StringToFecha(EFIni.Text),
    FSimSEEEdit.StringToFecha(EFFin.Text), cant, StrToInt(integers.Cells[1, 0]),
    StrToInt(integers.Cells[1, 1]), StrToFloat(integers.Cells[1, 2]), tipo);
end;

procedure TBaseEditoresFichas.llenarCamposPeriodicidad(CBLargo: TComboBox;
  ELPer, EFIni, EFFin: Tedit; integers: TStringGrid; cb: TCheckBox;
  ficha: TFichaLPD; panel: TPanel);
var
  cant: integer;
begin
  panel.Enabled := False;

  integers.Cells[0, 0] := rsCiclosActiva;
  integers.Cells[0, 1] := rsCiclosInactiva;
  integers.Cells[0, 2] := rsDesplazamiento;
  utilidades.AutoSizeCol(integers, 0);

  integers.Options := integers.Options + [goEditing];
  CBLargo.ItemIndex := 0;
  if (ficha <> nil) and (ficha.periodicidad <> nil) then
  begin
    cb.Checked := True;
    case ficha.periodicidad.tipoPeriodicidad_ of
      TP_Anual:
      begin
        CBLargo.ItemIndex := 0;
        cant := round(horasToAnios(ficha.periodicidad.durPeriodoEnHoras));
      end;
      TP_Mensual:
      begin
        CBLargo.ItemIndex := 1;
        cant := round(horasToMeses(ficha.periodicidad.durPeriodoEnHoras));
      end;
      TP_Semanal:
      begin
        CBLargo.ItemIndex := 2;
        cant := round(horasToSemanas(ficha.periodicidad.durPeriodoEnHoras));
      end;
      TP_Diaria:
      begin
        CBLargo.ItemIndex := 3;
        cant := round(horasToDias(ficha.periodicidad.durPeriodoEnHoras));
      end;
      else
        cant := -1;
    end;

    ELPer.Text := IntToStr(cant);

    integers.Cells[1, 0] := IntToStr(ficha.periodicidad.ciclosOn);
    integers.Cells[1, 1] := IntToStr(ficha.periodicidad.ciclosOff);
    integers.Cells[1, 2] := FloatToStr(ficha.periodicidad.ciclosOffset);

    EFIni.Text := ficha.periodicidad.iniHorizonte.AsStr;
    EFFin.Text := ficha.periodicidad.finHorizonte.AsStr;
  end;
  panel.Width := self.Canvas.TextWidth('Inicio de la Ventana:') +
    EFIni.Width + integers.Width + utilidades.plusWidth;
end;

procedure TBaseEditoresFichas.switchPanelPeriodicidad(cb: TCheckBox; panel: TPanel);
(*
var
  i: integer;
*)
begin
  if cb.Checked then
  begin
    panel.Enabled := True;
(*
    for i := 0 to ControlCount -1 do
      begin
      if Controls[i].Top > panel.Top then
        Controls[i].Top := Controls[i].Top + panel.Height
      end
*)
  end
  else
  begin
    panel.Enabled := False;
(*
    for i := 0 to ControlCount -1 do
      if Controls[i].Top > panel.Top then
        Controls[i].Top := Controls[i].Top - panel.Height
*)
  end;
end;

function TBaseEditoresFichas.validarTablaPeriodicidad(sg: TStringGrid): boolean;
var
  i, pos, val: integer;
begin
  pos := -1;
  try
    for i := 0 to sg.RowCount - 2 do
    begin
      pos := i;
      val := StrToInt(sg.Cells[1, i]);
      if (val < 0) then
        raise EConvertError.Create('menor que 0');
    end;
    pos := sg.rowcount - 1;
    StrToFloat(sg.Cells[1, sg.rowcount - 1]);
    Result := True;
  except
    on EConvertError do
    begin
      if pos = -1 then
        raise Exception.Create(
          'TBaseEditoresFichas.validarTablaPeriodicidad, ERROR; pos=-1');
      if pos < 2 then
        ShowMessage(mesValorIntroducidoDebeNumYMayor0)
      else
        ShowMessage(mesValorIntroducidoDebeNum);
      sg.row := pos;
      Result := False;
    end
  end; // try
end;

function TBaseEditoresFichas.validarPeriodicidad(CBperiodicidad: Tcheckbox;
  CBLargo: TComboBox; ELPer, EFIni, EFFin: Tedit; integers: TStringGrid): boolean;
begin
  if CBperiodicidad.Checked then
    Result := (CBLargo.ItemIndex <> -1) and validarEditInt(ELPer, 1, MAXINT) and
      validarEditFecha(EFIni) and validarEditFecha(EFFin) and
      validarTablaPeriodicidad(integers)
  else
    Result := True;
end;

procedure TBaseEditoresFichas.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  inherited;
end;

procedure TBaseEditoresFichas.FormCreate(Sender: TObject);
begin
  inherited;
end;

procedure TBaseEditoresFichas.sgPeriodicidadValidarCambio(tabla: TStringGrid);
begin
  if (validarSg) and (tabla.cells[1, filaValidarSG] <> loQueHabia) then
  begin
    try
      begin
        StrToFloat(tabla.cells[1, filaValidarSG]);
        guardado := False;
      end
    except
      on EConvertError do
      begin
        tabla.Cells[1, filaValidarSG] := loQueHabia;
        ShowMessage(mesValorIntroducidoDebeNum);
      end;
    end;
  end;
  //   validarSg := true;
end;

procedure TBaseEditoresFichas.sgPeriodicidadKeyDown(Sender: TObject;
  var Key: word; Shift: TShiftState);
begin
  validarSg := (Sender as TStringGrid).Cells[TStringGrid(Sender).col,
    TStringGrid(Sender).row] <> loQueHabia;
  if (Key in teclas) then
    sgPeriodicidadValidarCambio(TStringGrid(Sender));
end;

procedure TBaseEditoresFichas.Free;
begin
  if (Self.ModalResult <> mrOk) and (ficha <> nil) then
    ficha.Free;
  inherited Free;
end;

initialization
end.
