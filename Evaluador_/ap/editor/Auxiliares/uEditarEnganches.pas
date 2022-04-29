unit uEditarEnganches;
interface
uses
  {$IFDEF WINDOWS}
  Windows,
   {$ELSE}
  LCLType,
   {$ENDIF}
  Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs,
  utilidades, Grids, uEstados, StdCtrls, ExtCtrls, uCosa, uConstantesSimSEE,
  uSalasDeJuego, xMatDefs, uOpcionesSimSEEEdit, uBaseEditores, uodt_types,
  uparseadorsupersimple;

resourcestring
  mesValoresEnTablaNumericos =
    'Los valores introducidos en la tabla deben ser numéricos';
  mesValoresEnTablaNumericosDiscretos =
    'Los valores introducidos en la ' +
    'tablas de variables discretas deben ser numéricos y discretos.';

type

  { TEditarEnganches }

  TEditarEnganches = class(TBaseEditores)
    BCancelar: TButton;
    BGuardar: TButton;
    btDefaultMapeoStr: TButton;
    cb_flg_usar_enganche_mapeo: TCheckBox;
    GroupBox1: TGroupBox;
    LVarsCont: TLabel;
    LVarsDisc: TLabel;
    mMapeador: TMemo;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    sgVarsCont: TStringGrid;
    sgVarsDisc: TStringGrid;
    Splitter1: TSplitter;
    procedure BGuardarClick(Sender: TObject);
    procedure btDefaultMapeoStrClick(Sender: TObject);
    procedure BCancelarClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure GroupBox1Click(Sender: TObject);
    function validarFormulario: boolean;  override;
  private
    cf: TAdminEstados;
    vars_continuas_nombres, vars_continuas_unidades: array of string;
    vars_discretas_nombres, vars_discretas_unidades: array of string;
    function buscarValorContinuo(enganchesContinuos: TListaDeCosas;
      nombre, unidades: string; var valor: NReal): boolean;
    function buscarValorDiscreto(enganchesDiscretos: TListaDeCosas;
      nombre, unidades: string; var valor: integer): boolean;
  public
    sala: TSalaDeJuego;
    X_lst, Y_lst: TStringList;

    constructor Create(AOwner: TComponent; nArch: string; sala: TSalaDeJuego);
      reintroduce;
  end;

var
  EditarEnganches: TEditarEnganches;

implementation

  {$R *.lfm}

function TEditarEnganches.validarFormulario: boolean;
var
  i: integer;
  res: boolean;
begin
  res := True;
  try
    for i := 1 to sgVarsCont.RowCount - 1 do
      StrToFloat(sgVarsCont.Cells[3, i]);
  except
    on EConvertError do
    begin
      ShowMessage(mesValoresEnTablaNumericos);
      res := False;
    end;
  end;

  try
    for i := 1 to sgVarsDisc.RowCount - 1 do
      StrToInt(sgVarsDisc.Cells[3, i]);
  except
    on EConvertError do
    begin
      ShowMessage(mesValoresEnTablaNumericosDiscretos);
      res := False;
    end;
  end;

  Result := res;
end;

function TEditarEnganches.buscarValorContinuo(enganchesContinuos: TListaDeCosas;
  nombre, unidades: string; var valor: NReal): boolean;
var
  i: integer;
  encontre: boolean;
  ae: TEngancheCFReal;
begin
  encontre := False;
  for i := 0 to enganchesContinuos.Count - 1 do
  begin
    //    writeln( 'nombre: ('+nombre+'), ec_nombre: ('+TEngancheCFReal(enganchesContinuos[i]).nombreVar+')');
    ae := TEngancheCFReal(enganchesContinuos[i]);
    if (nombre = ae.nombreVar) and (unidades = ae.unidades) then
    begin
      valor := ae.valor;
      encontre := True;
      break;
    end;
  end;
  Result := encontre;
end;

function TEditarEnganches.buscarValorDiscreto(enganchesDiscretos: TListaDeCosas;
  nombre, unidades: string; var valor: integer): boolean;
var
  i: integer;
  encontre: boolean;
  ae: TEngancheCFEntero;
begin
  encontre := False;
  for i := 0 to enganchesDiscretos.Count - 1 do
  begin
    ae := TEngancheCFEntero(enganchesDiscretos[i]);
    if (nombre = ae.nombreVar) and (unidades = ae.unidades) then
    begin
      valor := ae.valor;
      encontre := True;
      break;
    end;
  end;
  Result := encontre;
end;

procedure TEditarEnganches.BCancelarClick(Sender: TObject);
begin
  setlength(vars_continuas_nombres, 0);
  setlength(vars_continuas_unidades, 0);
  setlength(vars_discretas_nombres, 0);
  setlength(vars_discretas_unidades, 0);
  ModalResult := mrCancel;
end;


procedure TEditarEnganches.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  X_lst.Free;
  Y_lst.Free;
  inherited FormClose(Sender, CloseAction);
end;

procedure TEditarEnganches.GroupBox1Click(Sender: TObject);
begin

end;

procedure TEditarEnganches.BGuardarClick(Sender: TObject);
var
  i: integer;
  val_s: string;
begin
  if validarFormulario then
  begin
    if sala.enganchesContinuos <> nil then
      sala.enganchesContinuos.Free;
    sala.enganchesContinuos := TListaDeCosas.Create(capa, 'EnganchesContinuos');
    if sala.enganchesDiscretos <> nil then
      sala.enganchesDiscretos.Free;
    sala.enganchesDiscretos := TListaDeCosas.Create(capa, 'EnganchesDiscretos');

    for i := 0 to high(vars_continuas_nombres) do
    begin
      val_s := sgVarsCont.Cells[3, i + 1];
      sala.enganchesContinuos.add(TEngancheCFReal.Create(capa,
        vars_continuas_nombres[i], vars_continuas_unidades[i],
        StrToFloat(val_s)));
    end;
    for i := 0 to high(vars_discretas_nombres) do
    begin
      val_s := sgVarsDisc.Cells[3, i + 1];
      sala.enganchesDiscretos.add(TEngancheCFEntero.Create(capa,
        vars_discretas_nombres[i], vars_discretas_unidades[i],
        StrToInt(val_s)));
    end;

    sala.enganche_mapeo := mMapeador.Lines.DelimitedText;
    sala.flg_usar_enganche_mapeo := cb_flg_usar_enganche_mapeo.Checked;

    ModalResult := mrOk;
  end;
end;

procedure TEditarEnganches.btDefaultMapeoStrClick(Sender: TObject);
var
  k, kVar: integer;
  s: string;

begin
  mMapeador.Lines.Clear;
  mMapeador.Lines.Add('// Variables X ');
  for k := 0 to X_lst.Count - 1 do
  begin
    mMapeador.Lines.add('// $X_' + X_lst[k]);
  end;
  mMapeador.Lines.Add('// --------------');

  mMapeador.Lines.Add('// Variables Y ');
  for k := 0 to Y_lst.Count - 1 do
  begin
    mMapeador.Lines.add('// $Y_' + Y_lst[k]);
  end;
  mMapeador.Lines.Add('// --------------');


  for k := 0 to Y_lst.Count - 1 do
  begin
    kVar := X_lst.IndexOf(Y_Lst[k]);
    if kVar >= 0 then
    begin
      s := '$Y_' + Y_lst[k] + ' := $X_' + Y_lst[k] + ';';
    end
    else
    begin
      s := '$Y_' + Y_lst[k] + ' := ???;';
    end;
    mMapeador.Lines.add(s);
  end;

end;

constructor TEditarEnganches.Create(AOwner: TComponent; nArch: string;
  sala: TSalaDeJuego);
var
  i: integer;
  valReal: NReal;
  valEntero: integer;
  var_nombre, var_unidades: string;

begin
  inherited Create(AOwner, nil, sala);

  self.sala := sala;
  cf := TAdminEstados.CreateLoadFromArchi(nArch);

  sala.Preparar_CrearCF_y_regsitrar_variables_de_estado(False);
  if sala.globs.CF <> nil then
    X_lst := sala.globs.CF.VariablesDeEstado_lst
  else
    X_lst := TStringList.Create;

  Y_lst := cf.VariablesDeEstado_lst;

  mMapeador.Lines.DelimitedText := sala.enganche_mapeo;

  cb_flg_usar_enganche_mapeo.Checked := sala.flg_usar_enganche_mapeo;
  setlength(vars_continuas_nombres, cf.nVarsContinuas);
  setlength(vars_continuas_unidades, cf.nVarsContinuas);

  if cf.nVarsContinuas > 0 then
  begin
    sgVarsCont.RowCount := cf.nVarsContinuas + 1;
    sgVarsCont.Cells[0, 0] := 'Variable';
    sgVarsCont.Cells[1, 0] := 'Limites (Inf, Sup)';
    sgVarsCont.Cells[2, 0] := 'Valor Medio';
    sgVarsCont.Cells[3, 0] := 'Valor';
    for i := 0 to cf.nVarsContinuas - 1 do
    begin
      var_nombre := cf.xr_def[i].nombre;
      var_unidades := cf.xr_def[i].unidades;
      vars_continuas_nombres[i] := var_nombre;
      vars_continuas_unidades[i] := var_unidades;

      sgVarsCont.Cells[0, i + 1] := var_nombre + ' [' + var_unidades + ']';
      sgVarsCont.Cells[1, i + 1] :=
        '(' + FloatToStr(cf.xr_def[i].x[0]) + ', ' +
        FloatToStr(cf.xr_def[i].x[high(cf.xr_def[i].x)]) + ')';
      sgVarsCont.Cells[2, i + 1] := FloatToStr(cf.xr_def[i].xmed);

      if (sala.enganchesContinuos <> nil) and buscarValorContinuo(
        sala.enganchesContinuos, var_nombre, var_unidades, valReal) then
        sgVarsCont.Cells[3, i + 1] := FloatToStr(valReal)
      else
        sgVarsCont.Cells[3, i + 1] := FloatToStr(cf.xr_def[i].xmed);
    end;
  end
  else
  begin
    sgVarsCont.RowCount := 0;
    LVarsCont.Visible := False;
    sgVarsCont.Visible := False;

    for i := 0 to ControlCount - 1 do
      if Controls[i].Top >= (sgVarsCont.Top + sgVarsCont.Height) then
        Controls[i].Top := Controls[i].Top - ((sgVarsCont.Top - LVarsCont.Top) +
          sgVarsCont.Height);
  end;

  setlength(vars_discretas_nombres, cf.nVarsDiscretas);
  setlength(vars_discretas_unidades, cf.nVarsDiscretas);
  if cf.nVarsDiscretas > 0 then
  begin
    sgVarsDisc.RowCount := cf.nVarsDiscretas + 1;
    sgVarsDisc.Cells[0, 0] := 'Variable';
    sgVarsDisc.Cells[1, 0] := 'Limites (Inf, Sup)';
    sgVarsDisc.Cells[2, 0] := 'Valor Mínimo';
    sgVarsDisc.Cells[3, 0] := 'Valor';
    for i := 0 to cf.nVarsDiscretas - 1 do
    begin
      var_nombre := cf.xd_def[i].nombre;
      var_unidades := cf.xd_def[i].unidades;
      vars_discretas_nombres[i] := var_nombre;
      vars_discretas_unidades[i] := var_unidades;

      sgVarsDisc.Cells[0, i + 1] := var_nombre + ' [' + var_unidades + ']';
      sgVarsDisc.Cells[1, i + 1] :=
        '(' + IntToStr(cf.xd_def[i].x[0]) + ', ' +
        IntToStr(cf.xd_def[i].x[high(cf.xd_def[i].x)]) + ')';
      sgVarsDisc.Cells[2, i + 1] := IntToStr(cf.xd_def[i].x[0]);

      if (sala.enganchesDiscretos <> nil) and buscarValorDiscreto(
        sala.enganchesDiscretos, var_nombre, var_unidades, valEntero) then
        sgVarsDisc.Cells[3, i + 1] := FloatToStr(valEntero)
      else
        sgVarsDisc.Cells[3, i + 1] := FloatToStr(cf.xd_def[i].x[0]);
    end;
  end
  else
  begin
    sgVarsDisc.RowCount := 0;
    LVarsDisc.Visible := False;
    sgVarsDisc.Visible := False;

    for i := 0 to ControlCount - 1 do
      if Controls[i].Top >= (sgVarsDisc.Top + sgVarsDisc.Height) then
        Controls[i].Top := Controls[i].Top - ((sgVarsDisc.Top - LVarsDisc.Top) +
          sgVarsDisc.Height);
  end;

  cf.Free;
  cf := nil;

  for i := 0 to sgVarsCont.ColCount - 2 do
    utilidades.AutoSizeCol(sgVarsCont, i);
  if (sgVarsDisc.ColCount > 0) then
    //si no hay valores se rompe por index -1 fix 16/5/2011
    sgVarsCont.ColWidths[sgVarsCont.ColCount - 1] := 150;

  for i := 0 to sgVarsDisc.ColCount - 2 do
    utilidades.AutoSizeCol(sgVarsDisc, i);
  if (sgVarsDisc.ColCount > 0) then
    //si no hay valores se rompe por index -1 fix 16/5/2011
    sgVarsDisc.ColWidths[sgVarsDisc.ColCount - 1] := 150;


  self.ClientWidth := sgVarsCont.Width;
  self.ClientHeight := LVarsCont.Height + sgVarsCont.Height +
    LVarsDisc.Height + sgVarsDisc.Height + BGuardar.Height;

end;


end.
