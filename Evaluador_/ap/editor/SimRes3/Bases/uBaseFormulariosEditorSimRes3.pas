unit uBaseFormulariosEditorSimRes3;
{$MODE Delphi}

interface

uses
  LResources,
    {$IFDEF WINDOWS}
  Windows,
  {$ENDIF}
  Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, stdCtrls, grids, Math, extCtrls,
  uBaseFormularios, utilidades, uConstantesSimSEE,
  uLectorSimRes3Defs, xMatDefs, uOpcionesSimSEEEdit,
  uHistoVarsOps, uPrint;

resourcestring
  mesSeleccionarIndiceLista = 'Debe seleccionar un índice de la lista';
  mesSeleccionarVariableLista = 'Debe seleccionar una variable de la lista';
  mesDebeSeleccionarIndiceTabla = 'Debe seleccionar al menos un índice en la tabla';
  rsIndice = 'Índice';
  rsCoeficiente = 'Coeficiente';
  rsVariableCronica = 'Variable crónica';
  rsDesplazamiento = 'Desplazamiento';
  mesSeleccionarVarCronicaTabla =
    'Debe seleccionar al menos una variable crónica en la tabla';
  rs_Alta_de = 'Alta de';
  rs_Edicion_de = 'Edición de';


const
  strNinguna = '<Ninguna>';
  strAgregarNuevaCronVar = '<Agregar Nueva...>';
  strSeleccioneCronVar = '<Seleccione una Variable Crónica>';
  strAgregarNuevoIndice = '<Agregar Nuevo...>';
  strSeleccioneIndice = '<Seleccione un Índice>';

type
  TBaseFormulariosEditorSimRes3 = class(TBaseFormularios)
  protected
    lector: TLectorSimRes3Defs;
  public

    constructor Create(AOwner: TComponent; lector: TLectorSimRes3Defs);
      reintroduce; virtual;

    procedure inicializarCBIndices(cbIndices: TComboBox; permiteNinguno: boolean);
    procedure setCBIndice(cb: TComboBox; valor: TVarIdxs);
    procedure setCBIndiceLinkeado(cb, cbLinkeado: TComboBox;
      valor, valorLinkeado: TVarIdxs);
    function valorCBIndice(cb: TComboBox): TVarIdxs;
    function validarCBIndices(cbIndices: TComboBox): boolean;
    //cambiosForm = true <-> se debe poner guardado = false al cambiar el cb
    procedure cbIndiceChange(Sender: TObject; cambiosForm: boolean);
    procedure cbIndiceLinkeadoChange(Sender: TObject; cbIndicelinkeado: TComboBox);

    procedure inicializarCBCronVars(cbCronVars: TComboBox; permiteNinguno: boolean);
    procedure inicializarCBCronVarsEjex(cbCronVars: TComboBox; permiteNinguno: boolean);
    procedure setCBCronVar(cb: TComboBox; valor: TCronVar);
    procedure setCBCronVarLinkeado(cb, cbLinkeado: TComboBox;
      valor, valorLinkeado: TCronVar);
    function valorCBCronVar(cb: TComboBox): TCronVar;
    function validarCBCronVars(cbCronVars: TComboBox): boolean;
    //cambiaForm = true <-> se debe poner guardado = false al cambiar el cb
    procedure cbCronVarChange(Sender: TObject; cambiaForm: boolean);
    procedure cbCronVarLinkeadoChange(Sender: TObject; cbCronVarlinkeado: TComboBox);
    procedure cbCronVarComplementarioChange(Sender: TObject;
      cbCronVarComplementario: TComboBox; cambiaForm: boolean);
    procedure cbCronVarComplementarioChange3(Sender: TObject;
      cbCronVarComplementario1, cbCronVarComplementario2: TComboBox; cambiaForm: boolean);

    //Retorna la posicion que debe ocupar nombreIndice en cbIndice para mantener
    //el orden original
    function findPosIndiceCB(nombreIndice: String; cbIndice: TComboBox): Integer;

    procedure inicializarSGIndice(sg: TStringGrid; var tiposCols: TDAOfTTipoColumna;
      cbIndice: TComboBox; bAgregar: TButton);
    procedure setSGIndice(sg: TStringGrid; indices: TDAOfTVarIdxs;
      cbIndice: TComboBox; bAgregar: TButton);
    function valorSGIndice(sg: TStringGrid): TDAOfTVarIdxs;
    procedure addSGIndice(sg: TStringGrid; cbIndice: TComboBox; bAgregar: TButton);
    procedure eliminarSGIndice(sg: TStringGrid; fila: integer;
      cbIndice: TComboBox; bAgregar: TButton);

    procedure inicializarSGIndiceCoef(sg: TStringGrid;
      var tiposCols: TDAOfTTipoColumna; eCoef: TEdit;
      cbIndice: TComboBox; bAgregar: TButton);
    procedure setSGIndiceCoef(sg: TStringGrid; indices: TDAOfTVarIdxs;
      coefs: TDAofNReal; cbIndice: TComboBox; eCoef: TEdit; bAgregar: TButton);
    procedure valorSGIndiceCoef(sg: TStringGrid; var indices: TDAOfTVarIdxs;
      var coefs: TDAofNReal);
    procedure addSGIndiceCoef(sg: TStringGrid; cbIndice: TComboBox;
      eCoef: TEdit; minCoef, maxCoef: NReal; bAgregar: TButton);
    procedure eliminarSGIndiceCoef(sg: TStringGrid; fila: integer;
      cbIndice: TComboBox; eCoef: TEdit; bAgregar: TButton);

    //Sirve para SGIndiceCoef también
    function validarSGIndice(sg: TStringGrid; cbIndice: TComboBox): boolean;

    //Retorna la posicion que debe ocupar nombreCronVar en cbCronVar para mantener
    //el orden original
    function findPosCronVarCB(nombreCronVar: String; cbCronVar: TComboBox): Integer;

    procedure inicializarSGCronVar(sg: TStringGrid; var tiposCols: TDAOfTTipoColumna;
      cbCronVar: TComboBox; bAgregar: TButton);
    procedure setSGCronVar(sg: TStringGrid; cronVars: TDAOfCronVar;
      cbCronVar: TComboBox; bAgregar: TButton);
    function valorSGCronVar(sg: TStringGrid): TDAOfCronVar;
    procedure addSGCronVar_(sg: TStringGrid; cbCronVar: TComboBox;
      bAgregar: TButton);
    procedure eliminarSGCronVar(sg: TStringGrid; fila: integer;
      cbCronVar: TComboBox; bAgregar: TButton);

    procedure inicializarSGCronVarCoef(sg: TStringGrid;
      var tiposCols: TDAOfTTipoColumna;
      cbCronVar: TComboBox; eCoef: TEdit;
      bAgregar: TButton);
    procedure setSGCronVarCoef(sg: TStringGrid; cronVars: TDAOfCronVar;
      coefs: TDAofNReal; cbCronVar: TComboBox; eCoef: TEdit; bAgregar: TButton);
    procedure valorSGCronVarCoef(sg: TStringGrid; var cronVars: TDAOfCronVar;
      var coefs: TDAofNReal);

    procedure addSGCronVarCoef(sg: TStringGrid; cbCronVar: TComboBox;
      eCoef: TEdit; minCoef, maxCoef: NReal; bAgregar: TButton);
    procedure eliminarSGCronVarCoef(sg: TStringGrid; fila: integer;
      cbCronVar: TComboBox; eCoef: TEdit; bAgregar: TButton);

    procedure inicializarSGCronVarCoefDesp(sg: TStringGrid;
      var tiposCols: TDAOfTTipoColumna;
      cbCronVar: TComboBox;
      eCoef, eDesp: TEdit; bAgregar: TButton);


    procedure setSGCronVarCoefDesp(sg: TStringGrid; cronVars: TDAOfCronVar;
      coefs: TDAofNReal; desps: TDAofNInt; cbCronVar: TComboBox; eCoef, eDesp: TEdit;
      bAgregar: TButton);
    procedure valorSGCronVarCoefDesp(sg: TStringGrid; var cronVars: TDAOfCronVar;
      var coefs: TDAofNReal; var desps: TDAofNInt);
    procedure addSGCronVarCoefDesp(sg: TStringGrid; cbCronVar: TComboBox;
      eCoef: TEdit; minCoef, maxCoef: NReal; eDesp: TEdit; minDesp, maxDesp: integer;
      bAgregar: TButton);
    procedure eliminarSGCronVarCoefDesp(sg: TStringGrid; fila: integer;
      cbCronVar: TComboBox; eCoef, eDesp: TEdit; bAgregar: TButton);

    //Sirve para SGCronVarCoef y SGCronVarCoefDesp también
    function validarSGCronVar(sg: TStringGrid; cbCronVar: TComboBox): boolean;
    function validarCronVarEjex(cbCronVar: TComboBox; cbEjexCronVar: TRadioButton): boolean;
  end;

implementation

uses
  uEditorSimRes3Main;
  {$R *.lfm}

constructor TBaseFormulariosEditorSimRes3.Create(AOwner: TComponent;
  lector: TLectorSimRes3Defs);
begin
  inherited Create(AOwner);
  self.lector := lector;
  //  utilidades.setTabOrderByLeftAndTop(self);
end;

procedure TBaseFormulariosEditorSimRes3.inicializarCBIndices(cbIndices: TComboBox;
  permiteNinguno: boolean);
var
  i: Integer;
begin
  if permiteNinguno then
    cbIndices.Items.Add(strNinguna);
  cbIndices.Items.Add(strAgregarNuevoIndice);

  for i := 0 to lector.lstIdxs.Count - 1 do
    cbIndices.Items.Add(TVarIdxs(lector.lstIdxs[i]).nombreIndice);

  if cbIndices.Items.Count = 1 then
    cbIndices.ItemIndex := 0
  else
  begin
    cbIndices.ItemIndex := -1;
    cbIndices.Text := strSeleccioneIndice;
  end;
end;

procedure TBaseFormulariosEditorSimRes3.inicializarCBCronVars(cbCronVars: TComboBox;
  permiteNinguno: boolean);
var
  i: Integer;
begin
  if permiteNinguno then
    cbCronVars.Items.Add(strNinguna);

  cbCronVars.Items.Add(strAgregarNuevaCronVar);

  for i := 0 to lector.lstCronVars.Count - 1 do
    cbCronVars.Items.Add(TCronVar(lector.lstCronVars[i]).nombre);


  if cbCronVars.Items.Count = 1 then
     cbCronVars.ItemIndex := 0

  else
  begin
    cbCronVars.ItemIndex := -1;
    cbCronVars.Text := strSeleccioneCronVar;

  end;
end;

procedure TBaseFormulariosEditorSimRes3.inicializarCBCronVarsEjex(cbCronVars: TComboBox;
  permiteNinguno: boolean);
var
  i: Integer;
begin
  if permiteNinguno then
    cbCronVars.Items.Add(strNinguna);

  cbCronVars.Items.Add(strAgregarNuevaCronVar);

  for i := 0 to lector.lstCronVars.Count - 1 do
    cbCronVars.Items.Add(TCronVar(lector.lstCronVars[i]).nombre);


  if cbCronVars.Items.Count = 1 then
     cbCronVars.ItemIndex := 0

  else
  begin
    cbCronVars.ItemIndex := -1;
    cbCronVars.Text := strSeleccioneCronVar;

  end;
end;


function TBaseFormulariosEditorSimRes3.validarCBIndices(cbIndices: TComboBox): boolean;
begin
  if (cbIndices.ItemIndex <> -1) and
    (cbIndices.Items[cbIndices.ItemIndex] <> strAgregarNuevoIndice) then
    Result := True
  else
  begin
    ShowMessage(mesSeleccionarIndiceLista);
    cbIndices.SetFocus;
    Result := False;
  end;
end;

procedure TBaseFormulariosEditorSimRes3.cbIndiceChange(Sender: TObject;
  cambiosForm: boolean);
var
  indice: TVarIdxs;
begin
  if valorCBString(TComboBox(Sender)) = strAgregarNuevoIndice then
  begin
    indice := editorSimRes3.altaIndice;
    if indice <> NIL then
    begin
      TComboBox(Sender).Items.Add(indice.nombreIndice);
      TComboBox(Sender).ItemIndex := TComboBox(Sender).Items.Count - 1;
      if cambiosForm then
        guardado := False;
    end
    else
    begin
      TComboBox(Sender).ItemIndex := -1;
      TComboBox(Sender).Text := strSeleccioneIndice;
      //no funciona, aparentemente el problema es por estar en el cbCronVarChange
    end;
  end
  else if cambiosForm then
    guardado := False;
end;

procedure TBaseFormulariosEditorSimRes3.cbIndiceLinkeadoChange(Sender: TObject;
  cbIndicelinkeado: TComboBox);
var
  oldStr, strCbCambiado: String;
  i: Integer;
  permiteNinguna: boolean;
begin
  permiteNinguna := cbIndicelinkeado.Items[0] = strNinguna;

  cbIndiceChange(Sender, true);
  strCbCambiado := valorCBString(TComboBox(Sender));
  oldStr := valorCBString(cbIndicelinkeado);

  cbIndicelinkeado.Items.Clear;
  if permiteNinguna then
    cbIndicelinkeado.Items.Add(strNinguna);
  cbIndicelinkeado.Items.Add(strAgregarNuevaCronVar);
  for i := 0 to lector.lstIdxs.Count - 1 do
    if TVarIdxs(lector.lstIdxs[i]).nombreIndice <> strCbCambiado then
      cbIndicelinkeado.Items.Add(TVarIdxs(lector.lstIdxs[i]).nombreIndice);
  cbIndicelinkeado.ItemIndex := cbIndicelinkeado.Items.IndexOf(oldStr);
end;

function TBaseFormulariosEditorSimRes3.validarCBCronVars(cbCronVars: TComboBox): boolean;
begin
  if cbCronVars.ItemIndex <> -1 then
    Result := True
  else
  begin
    ShowMessage(mesSeleccionarVariableLista);
    cbCronVars.SetFocus;
    Result := False;
  end;
end;

procedure TBaseFormulariosEditorSimRes3.cbCronVarChange(Sender: TObject;
  cambiaForm: boolean);
var
  cv: TCronVar;
begin
  if valorCBString(TComboBox(Sender)) = strAgregarNuevaCronVar then
  begin
    cv := editorSimRes3.altaCronVar;
    if cv <> NIL then
    begin
      TComboBox(Sender).Items.Add(cv.nombre);
      TComboBox(Sender).ItemIndex := TComboBox(Sender).Items.Count - 1;
      if cambiaForm then
        guardado := False;
    end
    else
    begin
      TComboBox(Sender).ItemIndex := -1;
      TComboBox(Sender).Text := strSeleccioneCronVar;
      //no funciona, aparentemente el problema es por estar en el cbCronVarChange
    end;
  end
  else if cambiaForm then
    guardado := False;
end;

procedure TBaseFormulariosEditorSimRes3.cbCronVarLinkeadoChange(Sender: TObject;
  cbCronVarlinkeado: TComboBox);
var
  oldStr, strCbCambiado: String;
  i: Integer;
  permiteNinguna: boolean;
begin
  permiteNinguna := cbCronVarlinkeado.Items[0] = strNinguna;

  cbCronVarChange(Sender, true);
  strCbCambiado := valorCBString(TComboBox(Sender));
  oldStr := valorCBString(cbCronVarlinkeado);

  cbCronVarlinkeado.Items.Clear;
  if permiteNinguna then
    cbCronVarlinkeado.Items.Add(strNinguna);
  cbCronVarlinkeado.Items.Add(strAgregarNuevaCronVar);
  for i := 0 to lector.lstCronVars.Count - 1 do
    if TCronVar(lector.lstCronVars[i]).nombre <> strCbCambiado then
      cbCronVarlinkeado.Items.Add(TCronVar(lector.lstCronVars[i]).nombre);
  cbCronVarlinkeado.ItemIndex := cbCronVarlinkeado.Items.IndexOf(oldStr);
end;

procedure TBaseFormulariosEditorSimRes3.cbCronVarComplementarioChange(Sender: TObject;
  cbCronVarComplementario: TComboBox; cambiaForm: boolean);
var
  str: String;
begin
  cbCronVarChange(Sender, cambiaForm);
  str := valorCBString(TComboBox(Sender));
  if cbCronVarComplementario.Items.IndexOf(str) = -1 then
    cbCronVarComplementario.Items.Add(str);
end;

procedure TBaseFormulariosEditorSimRes3.cbCronVarComplementarioChange3(Sender: TObject;
  cbCronVarComplementario1, cbCronVarComplementario2: TComboBox; cambiaForm: boolean);
var
  str: String;
begin
  cbCronVarChange(Sender, cambiaForm);
  str := valorCBString(TComboBox(Sender));
  if cbCronVarComplementario1.Items.IndexOf(str) = -1 then
    cbCronVarComplementario1.Items.Add(str);
  if cbCronVarComplementario2.Items.IndexOf(str) = -1 then
    cbCronVarComplementario2.Items.Add(str);
end;

function TBaseFormulariosEditorSimRes3.validarSGIndice(sg: TStringGrid;
  cbIndice: TComboBox): boolean;
begin
  if sg.RowCount > 1 then
    Result := True
  else
  begin
    ShowMessage(mesDebeSeleccionarIndiceTabla);
    cbIndice.SetFocus;
    Result := False;
  end;
end;

procedure TBaseFormulariosEditorSimRes3.setCBCronVar(cb: TComboBox; valor: TCronVar);
begin
  if valor <> NIL then
    cb.ItemIndex := cb.Items.IndexOf(valor.nombre)
  else
    cb.ItemIndex := cb.Items.IndexOf(strNinguna);
  if cb.TabOrder = 0 then
    loQueHabia := cb.Items[cb.ItemIndex];
end;

procedure TBaseFormulariosEditorSimRes3.setCBCronVarLinkeado(cb, cbLinkeado: TComboBox;
  valor, valorLinkeado: TCronVar);
begin
  cb.ItemIndex := cb.Items.IndexOf(valor.nombre);
  cbLinkeado.Items.Delete(cbLinkeado.Items.IndexOf(valor.nombre));
  if valorLinkeado <> NIL then
  begin
    cbLinkeado.ItemIndex := cbLinkeado.Items.IndexOf(valorLinkeado.nombre);
    cb.Items.Delete(cb.Items.IndexOf(valorLinkeado.nombre));
  end
  else
  begin
    cbLinkeado.ItemIndex := cbLinkeado.Items.IndexOf(strNinguna);
  end;
end;

function TBaseFormulariosEditorSimRes3.valorCBCronVar(cb: TComboBox): TCronVar;
begin
  if cb.Items[cb.ItemIndex] <> strNinguna then
    Result := lector.getCronVarByName(cb.Items[cb.ItemIndex])
  else
    Result := nil;
end;

procedure TBaseFormulariosEditorSimRes3.setCBIndice(cb: TComboBox; valor: TVarIdxs);
begin
  cb.ItemIndex := cb.Items.IndexOf(valor.nombreIndice);
end;

procedure TBaseFormulariosEditorSimRes3.setCBIndiceLinkeado(cb, cbLinkeado: TComboBox;
  valor, valorLinkeado: TVarIdxs);
begin
  cb.ItemIndex := cb.Items.IndexOf(valor.nombreIndice);
  cbLinkeado.Items.Delete(cbLinkeado.Items.IndexOf(valor.nombreIndice));
  cbLinkeado.ItemIndex := cbLinkeado.Items.IndexOf(valorLinkeado.nombreIndice);
  cb.Items.Delete(cb.Items.IndexOf(valorLinkeado.nombreIndice));
end;

function TBaseFormulariosEditorSimRes3.valorCBIndice(cb: TComboBox): TVarIdxs;
begin
  Result := lector.getIndiceByName(cb.Items[cb.ItemIndex]);
end;

function TBaseFormulariosEditorSimRes3.findPosIndiceCB(nombreIndice: string;
  cbIndice: TComboBox): integer;
var
  iLstIdxs, iCB, res: Integer;
begin
  res := -1;
  iLstIdxs := 0;
  iCB := cbIndice.Items.IndexOf(strAgregarNuevoIndice) + 1;
  while res = -1 do
  begin
    while (iLstIdxs < lector.lstIdxs.Count) and (iCB < cbIndice.Items.Count) and
      (TVarIdxs(lector.lstIdxs[iLstIdxs]).nombreIndice = cbIndice.Items[iCB]) do
    begin
      iLstIdxs := iLstIdxs + 1;
      iCb := iCB + 1;
    end;
    if iCB <> cbIndice.Items.Count then
    begin
      while (iLstIdxs < lector.lstIdxs.Count) and
        (TVarIdxs(lector.lstIdxs[iLstIdxs]).nombreIndice <> cbIndice.Items[iCB]) and
        (res = -1) do
      begin
        if TVarIdxs(lector.lstIdxs[iLstIdxs]).nombreIndice = nombreIndice then
          res := iCB
        else
          iLstIdxs := iLstIdxs + 1;
      end;
    end
    else
      res := iCB;
  end;
  Result := res;
end;

procedure TBaseFormulariosEditorSimRes3.inicializarSGIndice(sg: TStringGrid;
  var tiposCols: TDAOfTTipoColumna; cbIndice: TComboBox; bAgregar: TButton);
begin
  sg.Options := sg.Options + [goRowSelect];
  inicializarCBIndices(cbIndice, false);
  initListado(sg, [rsIndice, encabezadoBTEliminar], tiposCols, true);
end;

procedure TBaseFormulariosEditorSimRes3.setSGIndice(sg: TStringGrid;
  indices: TDAOfTVarIdxs; cbIndice: TComboBox; bAgregar: TButton);
var
  i: Integer;
begin
  sg.RowCount := Length(indices) + 1;
  if sg.RowCount > 1 then
    sg.FixedRows := 1;
  for i := 0 to high(indices) do
  begin
    sg.Cells[0, i + 1] := indices[i].nombreIndice;
    cbIndice.Items.Delete(cbIndice.Items.IndexOf(indices[i].nombreIndice));
  end;
  bAgregar.Enabled := cbIndice.Items.Count > 0;
  cbIndice.Enabled := bAgregar.Enabled;
end;

function TBaseFormulariosEditorSimRes3.valorSGIndice(sg: TStringGrid): TDAOfTVarIdxs;
var
  i: Integer;
  indices: TDAOfTVarIdxs;
begin
  SetLength(indices, sg.RowCount - 1);
  for i := 0 to High(indices) do
    indices[i] := lector.getIndiceByName(sg.Cells[0, i + 1]);
  Result := indices;
end;

procedure TBaseFormulariosEditorSimRes3.inicializarSGIndiceCoef(sg: TStringGrid;
  var tiposCols: TDAOfTTipoColumna;
  eCoef: TEdit;
  cbIndice: TComboBox; bAgregar: TButton);
begin
  sg.Options := sg.Options + [goRowSelect];
  inicializarCBIndices(cbIndice, false);
  initListado(sg, [rsIndice, rsCoeficiente, encabezadoBTEliminar], tiposCols, true);
end;

procedure TBaseFormulariosEditorSimRes3.setSGIndiceCoef(sg: TStringGrid;
  indices: TDAOfTVarIdxs; coefs: TDAofNReal; cbIndice: TComboBox;
  eCoef: TEdit; bAgregar: TButton);
var
  i: Integer;
begin
  sg.RowCount := Length(indices) + 1;
  if sg.RowCount > 1 then
    sg.FixedRows := 1;
  for i := 0 to high(indices) do
  begin
    sg.Cells[0, i + 1] := indices[i].nombreIndice;
    sg.Cells[1, i + 1] := FloatToStrF(coefs[i], ffGeneral, 16, 10);
    cbIndice.Items.Delete(cbIndice.Items.IndexOf(indices[i].nombreIndice));
  end;
  bAgregar.Enabled := cbIndice.Items.Count > 0;
  cbIndice.Enabled := bAgregar.Enabled;
  eCoef.Enabled := bAgregar.Enabled;
end;

procedure TBaseFormulariosEditorSimRes3.valorSGIndiceCoef(sg: TStringGrid;
  var indices: TDAOfTVarIdxs; var coefs: TDAofNReal);
var
  i: Integer;
begin
  SetLength(indices, sg.RowCount - 1);
  SetLength(coefs, sg.RowCount - 1);
  for i := 0 to High(indices) do
  begin
    indices[i] := lector.getIndiceByName(sg.Cells[0, i + 1]);
    coefs[i] := StrToFloat(sg.Cells[1, i + 1]);
  end;
end;

procedure TBaseFormulariosEditorSimRes3.addSGIndice(sg: TStringGrid;
  cbIndice: TComboBox; bAgregar: TButton);
var
  oldItemIndex: Integer;
begin
  if validarCBIndices(cbIndice) then
  begin
    sg.RowCount := sg.RowCount + 1;
    if sg.RowCount > 1 then
      sg.FixedRows := 1;
    sg.Cells[0, sg.RowCount - 1] := cbIndice.Items[cbIndice.ItemIndex];

    oldItemIndex := cbIndice.ItemIndex;
    cbIndice.Items.Delete(cbIndice.ItemIndex);
    if cbIndice.Items.Count > 0 then
    begin
      cbIndice.ItemIndex := min(oldItemIndex, cbIndice.Items.Count - 1);
      cbIndice.Text := cbIndice.Items[cbIndice.ItemIndex];
    end
    else
    begin
      cbIndice.ItemIndex := -1;
      cbIndice.Text := '';
    end;

    utilidades.AutoSizeCol(sg, 0);
    sg.Row := sg.RowCount - 1;

    guardado := False;
    bAgregar.Enabled := cbIndice.Items.Count > 0;
    cbIndice.Enabled := bAgregar.Enabled;
  end;
end;

procedure TBaseFormulariosEditorSimRes3.addSGIndiceCoef(sg: TStringGrid;
  cbIndice: TComboBox; eCoef: TEdit; minCoef, maxCoef: NReal; bAgregar: TButton);
var
  i: Integer;
  oldItemIndex: Integer;
begin
  if validarCBIndices(cbIndice) and validarEditFloat(eCoef, minCoef, maxCoef) then
  begin
    sg.RowCount := sg.RowCount + 1;
    if sg.RowCount > 1 then
      sg.FixedRows := 1;
    sg.Cells[0, sg.RowCount - 1] := cbIndice.Items[cbIndice.ItemIndex];
    sg.Cells[1, sg.RowCount - 1] := eCoef.Text;

    oldItemIndex := cbIndice.ItemIndex;
    cbIndice.Items.Delete(cbIndice.ItemIndex);
    if cbIndice.Items.Count > 0 then
    begin
      cbIndice.ItemIndex := min(oldItemIndex, cbIndice.Items.Count - 1);
      cbIndice.Text := cbIndice.Items[cbIndice.ItemIndex];
    end
    else
    begin
      cbIndice.ItemIndex := -1;
      cbIndice.Text := '';
      eCoef.Text := '';
    end;

    for i := 0 to 1 do
      utilidades.AutoSizeCol(sg, i);
    sg.Row := sg.RowCount - 1;

    guardado := False;
    bAgregar.Enabled := cbIndice.Items.Count > 0;
    cbIndice.Enabled := bAgregar.Enabled;
    eCoef.Enabled := bAgregar.Enabled;
  end;
end;

procedure TBaseFormulariosEditorSimRes3.eliminarSGIndice(sg: TStringGrid;
  fila: integer; cbIndice: TComboBox; bAgregar: TButton);
var
  i: Integer;
  posIndiceCB: Integer;
begin
  posIndiceCB := findPosIndiceCB(sg.Cells[0, fila], cbIndice);
  cbIndice.Items.Insert(posIndiceCB, sg.Cells[0, fila]);
  if cbIndice.ItemIndex = -1 then
    cbIndice.ItemIndex := posIndiceCB;
  for i := fila to sg.RowCount - 2 do
    sg.Cells[0, i] := sg.Cells[0, i + 1];

  sg.RowCount := sg.RowCount - 1;

  utilidades.AutoSizeCol(sg, 0);
  guardado := False;
  bAgregar.Enabled := cbIndice.Items.Count > 0;
  cbIndice.Enabled := bAgregar.Enabled;
end;

procedure TBaseFormulariosEditorSimRes3.eliminarSGIndiceCoef(sg: TStringGrid;
  fila: integer; cbIndice: TComboBox; eCoef: TEdit; bAgregar: TButton);
var
  i: Integer;
  posIndiceCB: Integer;
begin
  posIndiceCB := findPosIndiceCB(sg.Cells[0, fila], cbIndice);
  cbIndice.Items.Insert(posIndiceCB, sg.Cells[0, fila]);
  if cbIndice.ItemIndex = -1 then
  begin
    cbIndice.ItemIndex := posIndiceCB;
    eCoef.Text := sg.Cells[1, fila];
  end;
  for i := fila to sg.RowCount - 2 do
  begin
    sg.Cells[0, i] := sg.Cells[0, i + 1];
    sg.Cells[1, i] := sg.Cells[1, i + 1];
  end;

  sg.RowCount := sg.RowCount - 1;

  utilidades.AutoSizeCol(sg, 0);
  guardado := False;
  bAgregar.Enabled := cbIndice.Items.Count > 0;
  cbIndice.Enabled := bAgregar.Enabled;
  eCoef.Enabled := bAgregar.Enabled;
end;

procedure TBaseFormulariosEditorSimRes3.inicializarSGCronVar(sg: TStringGrid;
  var tiposCols: TDAOfTTipoColumna;
  cbCronVar: TComboBox;
  bAgregar: TButton);
begin
  sg.Options := sg.Options + [goRowSelect];
  inicializarCBCronVars(cbCronVar, false);
  initListado(sg, [rsVariableCronica, encabezadoBTEliminar], tiposCols, true);
end;

procedure TBaseFormulariosEditorSimRes3.setSGCronVar(sg: TStringGrid;
  cronVars: TDAOfCronVar; cbCronVar: TComboBox; bAgregar: TButton);
var
  i: Integer;
begin
  sg.RowCount := Length(cronVars) + 1;
  if sg.RowCount > 1 then
    sg.FixedRows := 1;
  for i := 0 to high(cronVars) do
  begin
    sg.Cells[0, i + 1] := cronVars[i].nombre;
    cbCronVar.Items.Delete(cbCronVar.Items.IndexOf(cronVars[i].nombre));
  end;
  bAgregar.Enabled := cbCronVar.Items.Count > 0;
  cbCronVar.Enabled := bAgregar.Enabled;
end;

function TBaseFormulariosEditorSimRes3.findPosCronVarCB(nombreCronVar: string;
  cbCronVar: TComboBox): integer;
var
  iLstCronVars, iCB, res: Integer;
begin
  res := -1;
  iLstCronVars := 0;
  iCB := cbCronVar.Items.IndexOf(strAgregarNuevaCronVar) + 1;
  while res = -1 do
  begin
    while (iLstCronVars < lector.lstCronVars.Count) and
      (iCB < cbCronVar.Items.Count) and
      (TCronVar(lector.lstCronVars[iLstCronVars]).nombre = cbCronVar.Items[iCB]) do
    begin
      iLstCronVars := iLstCronVars + 1;
      iCb := iCB + 1;
    end;
    if iCB <> cbCronVar.Items.Count then
    begin
      while (iLstCronVars < lector.lstCronVars.Count) and
        (TCronVar(lector.lstCronVars[iLstCronVars]).nombre <>
          cbCronVar.Items[iCB]) and (res = -1) do
      begin
        if TCronVar(lector.lstCronVars[iLstCronVars]).nombre = nombreCronVar then
          res := iCB
        else
          iLstCronVars := iLstCronVars + 1;
      end;
    end
    else
      res := iCB;
  end;
  Result := res;
end;

function TBaseFormulariosEditorSimRes3.valorSGCronVar(sg: TStringGrid): TDAOfCronVar;
var
  i: Integer;
  cronVars: TDAOfCronVar;
begin
  SetLength(cronVars, sg.RowCount - 1);
  for i := 0 to High(cronVars) do
    cronVars[i] := lector.getCronVarByName(sg.Cells[0, i + 1]);
  Result := cronVars;
end;

procedure TBaseFormulariosEditorSimRes3.addSGCronVar_(sg: TStringGrid;
  cbCronVar: TComboBox; bAgregar: TButton);
var
  oldItemIndex: Integer;
begin
  if validarCBCronVars(cbCronVar) then
  begin
    sg.RowCount := sg.RowCount + 1;
    if sg.RowCount > 1 then
      sg.FixedRows := 1;
    sg.Cells[0, sg.RowCount - 1] := cbCronVar.Items[cbCronVar.ItemIndex];

    oldItemIndex := cbCronVar.ItemIndex;
    cbCronVar.Items.Delete(cbCronVar.ItemIndex);
    if cbCronVar.Items.Count > 0 then
    begin
      cbCronVar.ItemIndex := min(oldItemIndex, cbCronVar.Items.Count - 1);
      cbCronVar.Text := cbCronVar.Items[cbCronVar.ItemIndex];
    end
    else
    begin
      cbCronVar.ItemIndex := -1;
      cbCronVar.Text := '';
    end;

    utilidades.AutoSizeCol(sg, 0);
    guardado := False;
    bAgregar.Enabled := cbCronVar.Items.Count > 0;
    cbCronVar.Enabled := bAgregar.Enabled;
  end;
end;

procedure TBaseFormulariosEditorSimRes3.eliminarSGCronVar(sg: TStringGrid;
  fila: integer; cbCronVar: TComboBox; bAgregar: TButton);
var
  i: Integer;
  posCronVarCB: Integer;
begin
  posCronVarCB := findPosCronVarCB(sg.Cells[0, fila], cbCronVar);
  cbCronVar.Items.Insert(posCronVarCB, sg.Cells[0, fila]);
  if cbCronVar.ItemIndex = -1 then
    cbCronVar.ItemIndex := posCronVarCB;

  for i := fila to sg.RowCount - 2 do
    sg.Cells[0, i] := sg.Cells[0, i + 1];

  sg.RowCount := sg.RowCount - 1;

  utilidades.AutoSizeCol(sg, 0);

  guardado := False;
  bAgregar.Enabled := cbCronVar.Items.Count > 0;
  cbCronVar.Enabled := bAgregar.Enabled;
end;

procedure TBaseFormulariosEditorSimRes3.inicializarSGCronVarCoef(sg: TStringGrid;
  var tiposCols: TDAOfTTipoColumna;
  cbCronVar: TComboBox;
  eCoef: TEdit; bAgregar: TButton);
begin
  //  sg.Options:= sg.Options + [goRowSelect];
  inicializarCBCronVars(cbCronVar, false);
  initListado(sg, [rsVariableCronica, rsCoeficiente, encabezadoBTEliminar],
    tiposCols, True);
end;

procedure TBaseFormulariosEditorSimRes3.setSGCronVarCoef(sg: TStringGrid;
  cronVars: TDAOfCronVar; coefs: TDAofNReal; cbCronVar: TComboBox;
  eCoef: TEdit; bAgregar: TButton);
var
  i: Integer;
begin
  sg.RowCount := Length(cronVars) + 1;
  if sg.RowCount > 1 then
    sg.FixedRows := 1;
  for i := 0 to high(cronVars) do
  begin
    sg.Cells[0, i + 1] := cronVars[i].nombre;
    sg.Cells[1, i + 1] := FloatToStrF(coefs[i], ffGeneral, 16, 10);
    cbCronVar.Items.Delete(cbCronVar.Items.IndexOf(cronVars[i].nombre));
  end;
  bAgregar.Enabled := cbCronVar.Items.Count > 0;
  cbCronVar.Enabled := bAgregar.Enabled;
  eCoef.Enabled := bAgregar.Enabled;
end;

procedure TBaseFormulariosEditorSimRes3.valorSGCronVarCoef(sg: TStringGrid;
  var cronVars: TDAOfCronVar; var coefs: TDAofNReal);
var
  i: Integer;
begin
  SetLength(cronVars, sg.RowCount - 1);
  SetLength(coefs, sg.RowCount - 1);
  for i := 0 to High(cronVars) do
  begin
    cronVars[i] := lector.getCronVarByName(sg.Cells[0, i + 1]);
    coefs[i] := StrToFloat(sg.Cells[1, i + 1]);
  end;
end;

procedure TBaseFormulariosEditorSimRes3.addSGCronVarCoef(sg: TStringGrid;
  cbCronVar: TComboBox; eCoef: TEdit; minCoef, maxCoef: NReal; bAgregar: TButton);
var
  i: Integer;
  oldItemIndex: Integer;
begin
  if validarCBCronVars(cbCronVar) and validarEditFloat(eCoef, minCoef, maxCoef) then
  begin
    sg.RowCount := sg.RowCount + 1;
    if sg.RowCount > 1 then
      sg.FixedRows := 1;
    sg.Cells[0, sg.RowCount - 1] := cbCronVar.Items[cbCronVar.ItemIndex];
    sg.Cells[1, sg.RowCount - 1] := eCoef.Text;

    oldItemIndex := cbCronVar.ItemIndex;
    cbCronVar.Items.Delete(cbCronVar.ItemIndex);
    if cbCronVar.Items.Count > 0 then
    begin
      cbCronVar.ItemIndex := min(oldItemIndex, cbCronVar.Items.Count - 1);
      cbCronVar.Text := cbCronVar.Items[cbCronVar.ItemIndex];
    end
    else
    begin
      cbCronVar.ItemIndex := -1;
      cbCronVar.Text := '';
      eCoef.Text := '';
    end;

    for i := 0 to 1 do
      utilidades.AutoSizeCol(sg, i);
    sg.Row := sg.RowCount - 1;

    guardado := False;
    bAgregar.Enabled := cbCronVar.Items.Count > 0;
    cbCronVar.Enabled := bAgregar.Enabled;
    eCoef.Enabled := bAgregar.Enabled;
  end;
end;

procedure TBaseFormulariosEditorSimRes3.eliminarSGCronVarCoef(sg: TStringGrid;
  fila: integer; cbCronVar: TComboBox; eCoef: TEdit; bAgregar: TButton);
var
  i: Integer;
  posCronVarCB: Integer;
begin
  posCronVarCB := findPosCronVarCB(sg.Cells[0, fila], cbCronVar);
  cbCronVar.Items.Insert(posCronVarCB, sg.Cells[0, fila]);
  if cbCronVar.ItemIndex = -1 then
  begin
    cbCronVar.ItemIndex := posCronVarCB;
    eCoef.Text := sg.Cells[1, fila];
  end;
  for i := fila to sg.RowCount - 2 do
  begin
    sg.Cells[0, i] := sg.Cells[0, i + 1];
    sg.Cells[1, i] := sg.Cells[1, i + 1];
  end;

  sg.RowCount := sg.RowCount - 1;

  for i := 0 to 1 do
    utilidades.AutoSizeCol(sg, i);
  guardado := False;
  bAgregar.Enabled := cbCronVar.Items.Count > 0;
  cbCronVar.Enabled := bAgregar.Enabled;
  eCoef.Enabled := bAgregar.Enabled;
end;

procedure TBaseFormulariosEditorSimRes3.inicializarSGCronVarCoefDesp(sg: TStringGrid;
  var tiposCols: TDAOfTTipoColumna;
  cbCronVar:
  TComboBox;
  eCoef, eDesp: TEdit; bAgregar: TButton);
begin
  sg.Options := sg.Options + [goRowSelect];
  inicializarCBCronVars(cbCronVar, false);
  initListado(sg, [rsVariableCronica, rsCoeficiente, rsDesplazamiento,
    encabezadoBTEliminar], tiposCols, True);
end;

procedure TBaseFormulariosEditorSimRes3.setSGCronVarCoefDesp(sg: TStringGrid;
  cronVars: TDAOfCronVar; coefs: TDAofNReal; desps: TDAofNInt;
  cbCronVar: TComboBox; eCoef, eDesp: TEdit; bAgregar: TButton);
var
  i: Integer;
begin
  sg.RowCount := Length(cronVars) + 1;
  if sg.RowCount > 1 then
    sg.FixedRows := 1;
  for i := 0 to high(cronVars) do
  begin
    sg.Cells[0, i + 1] := cronVars[i].nombre;
    sg.Cells[1, i + 1] := FloatToStrF(coefs[i], ffGeneral, 16, 10);
    sg.Cells[2, i + 1] := IntToStr(desps[i]);
    cbCronVar.Items.Delete(cbCronVar.Items.IndexOf(cronVars[i].nombre));
  end;
  bAgregar.Enabled := cbCronVar.Items.Count > 0;
  cbCronVar.Enabled := bAgregar.Enabled;
  eCoef.Enabled := bAgregar.Enabled;
  eDesp.Enabled := bAgregar.Enabled;
end;

procedure TBaseFormulariosEditorSimRes3.valorSGCronVarCoefDesp(sg: TStringGrid;
  var cronVars: TDAOfCronVar; var coefs: TDAofNReal; var desps: TDAofNInt);
var
  i: Integer;
begin
  SetLength(cronVars, sg.RowCount - 1);
  SetLength(coefs, sg.RowCount - 1);
  SetLength(desps, sg.RowCount - 1);
  for i := 0 to High(cronVars) do
  begin
    cronVars[i] := lector.getCronVarByName(sg.Cells[0, i + 1]);
    coefs[i] := StrToFloat(sg.Cells[1, i + 1]);
    desps[i] := StrToInt(sg.Cells[2, i + 1]);
  end;
end;

procedure TBaseFormulariosEditorSimRes3.addSGCronVarCoefDesp(sg: TStringGrid;
  cbCronVar: TComboBox; eCoef: TEdit; minCoef, maxCoef: NReal; eDesp: TEdit;
  minDesp, maxDesp: integer; bAgregar: TButton);
var
  i: Integer;
  oldItemIndex: Integer;
begin
  if validarCBCronVars(cbCronVar) and validarEditFloat(eCoef, minCoef, maxCoef) and
    validarEditInt(eDesp, minDesp, maxDesp) then
  begin
    sg.RowCount := sg.RowCount + 1;
    if sg.RowCount > 1 then
      sg.FixedRows := 1;
    sg.Cells[0, sg.RowCount - 1] := cbCronVar.Items[cbCronVar.ItemIndex];
    sg.Cells[1, sg.RowCount - 1] := eCoef.Text;
    sg.Cells[2, sg.RowCount - 1] := eDesp.Text;

    oldItemIndex := cbCronVar.ItemIndex;
    cbCronVar.Items.Delete(cbCronVar.ItemIndex);
    if cbCronVar.Items.Count > 0 then
    begin
      cbCronVar.ItemIndex := min(oldItemIndex, cbCronVar.Items.Count - 1);
      cbCronVar.Text := cbCronVar.Items[cbCronVar.ItemIndex];
    end
    else
    begin
      cbCronVar.ItemIndex := -1;
      cbCronVar.Text := '';
      eCoef.Text := '';
      eDesp.Text := '';
    end;

    for i := 0 to 2 do
      utilidades.AutoSizeCol(sg, i);
    sg.Row := sg.RowCount - 1;

    guardado := False;
    bAgregar.Enabled := cbCronVar.Items.Count > 0;
    cbCronVar.Enabled := bAgregar.Enabled;
    eCoef.Enabled := bAgregar.Enabled;
    eDesp.Enabled := bAgregar.Enabled;
  end;
end;

procedure TBaseFormulariosEditorSimRes3.eliminarSGCronVarCoefDesp(sg: TStringGrid;
  fila: integer; cbCronVar: TComboBox; eCoef, eDesp: TEdit; bAgregar: TButton);
var
  i: Integer;
  posCronVarCB: Integer;
begin
  posCronVarCB := findPosCronVarCB(sg.Cells[0, fila], cbCronVar);
  cbCronVar.Items.Insert(posCronVarCB, sg.Cells[0, fila]);
  if cbCronVar.ItemIndex = -1 then
  begin
    cbCronVar.ItemIndex := posCronVarCB;
    eCoef.Text := sg.Cells[1, fila];
    eDesp.Text := sg.Cells[2, fila];
  end;
  for i := fila to sg.RowCount - 2 do
  begin
    sg.Cells[0, i] := sg.Cells[0, i + 1];
    sg.Cells[1, i] := sg.Cells[1, i + 1];
    sg.Cells[2, i] := sg.Cells[2, i + 1];
  end;

  sg.RowCount := sg.RowCount - 1;

  for i := 0 to 2 do
    utilidades.AutoSizeCol(sg, i);

  guardado := False;
  bAgregar.Enabled := cbCronVar.Items.Count > 0;
  cbCronVar.Enabled := bAgregar.Enabled;
  eCoef.Enabled := bAgregar.Enabled;
  eDesp.Enabled := bAgregar.Enabled;
end;

function TBaseFormulariosEditorSimRes3.validarSGCronVar(sg: TStringGrid;
  cbCronVar: TComboBox): boolean;
begin
  if sg.RowCount > 1 then
    Result := True
  else
  begin
    ShowMessage(mesSeleccionarVarCronicaTabla);
    cbCronVar.SetFocus;
    Result := False;
  end;
end;

function TBaseFormulariosEditorSimRes3.validarCronVarEjex(cbCronVar: TComboBox; cbEjexCronVar: TRadioButton): boolean;
var
  i: Integer;
begin
  Result:=false;
  if cbEjexCronVar.Checked then
  begin
       for i := 0 to lector.lstCronVars.Count - 1 do
           if TCronVar(lector.lstCronVars[i]).nombre = valorCBString(cbCronVar) then
               Result:=true;
  if Result=false then
  begin
    ShowMessage(mesSeleccionarVarCronicaTabla);
    cbCronVar.SetFocus;
    Result := False;
  end;
  end
  else
  Result:=true

end;

initialization
end.
