unit uBaseEditores;

{$MODE Delphi}

interface

uses
  SysUtils, Classes,
  Dialogs, StdCtrls, Controls,
  uBaseFormularios,
  uSalasDeJuego,
  uCosa,
  uCosaConNombre,
  uNodos, uArcos,uHidroConEmbalse,
  uNodoCombustible,
  uFuentesAleatorias, uCombustible, Forms, ExtCtrls;

resourcestring
  mesSeleccionarNodoDeLista = 'Debe seleccionar un nodo de la lista';
  mesSeleccionarNodoDeSegLista = 'Debe seleccionar un nodo de la segunda lista';
  mesSeleccionarNodoDePrimLista = 'Debe seleccionar un nodo de la primer lista';
  mesSeleccionarBorneLista = 'Debe seleccionar un borne de la lista';
  mesDebeSeleccionarFuenteDeLista = 'Debe seleccionar una fuente de la lista';
  mesFuenteAleatConPaso1h =
    'TParqueEolico, necesita una fuente aleatoria con paso de sorteo = 1h. ';
  mesUstedLoConectoAFuente = 'Usted lo conectó a la fuente ';
  mesConPasoDeSorteo = ' con paso de sorteo = ';
  mesSeleccionarCombustibleDeLista = 'Debe seleccionar un combustible de la lista';
  mesSeleccionarArcoDeLista = 'Debe seleccionar un arco de la lista';
  mesSeleccionarHidroDeLista = 'Debe seleccionar un Hidro de la lista';

  strNodoNinguno = '<Ninguno>';
  strSeleccionarNodo = '<Seleccione un Nodo>';
  strAgregarNuevoNodo = '<Agregar nuevo...>';

  strFuenteNinguna = '<Ninguna>';
  strSeleccionarFuente = '<Seleccione una Fuente>';
  strAgregarNuevaFuente = '<Agregar nueva...>';
  strSeleccionarBorne = '<Seleccione un Borne>';

  //  strAgregarNuevoCombustible = '<Agregar nuevo...>';
  strCombustibleNinguno = '<Ninguno>';
  strSeleccionarCombustible = '<Seleccione un Combustible>';

  strSeleccionarArco = '<Seleccione un Arco>';
  strArcoNinguno = '<Ninguno>';

  strSeleccionarHidroConEmbalse = '<Seleccione una Central Hidráulica con Embalse>';
  strHidroConEmbalseNinguno = '<Ninguno>';


type

  { TBaseEditores }

  TBaseEditores = class( TBaseFormularios )
    e_Capa: TEdit;
    lbo_capa: TLabel;
    base_editores_panel_top: TPanel;

    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);

  protected

    //Manipulación de nodos en ComboBox
    //El valor Tag del cb guarda el indice del objeto anterior seleccionado
    procedure inicializarCBNodos(cb: TComboBox; permiteNinguno: boolean);
    procedure inicializarCBNodosLinkeados(cb, cbLinkeado: TComboBox);

    procedure inicializarCBNodosCombustible(cb: TComboBox; permiteNinguno: boolean);
    procedure inicializarCBNodosCombustibleLinkeados(cb, cbLinkeado: TComboBox);

    procedure setCBNodo(cb: TComboBox; valor: TNodo);
    procedure setCBNodoLinkeado(cb, cbLinkeado: TComboBox; valor, valorLinkeado: TNodo);

    procedure setCBNodoCombustible(cb: TComboBox; valor: TNodoCombustible);
    procedure setCBNodoCombustibleLinkeado(cb, cbLinkeado: TComboBox;
      valor, valorLinkeado: TNodoCombustible);

    function valorCBNodo(cb: TComboBox): TNodo;
    function validarCBNodo(cb: TComboBox): boolean;
    function validarCBNodoLinkeado(cb, cbLinkeado: TComboBox): boolean;

    //cambiosForm = true <-> se debe poner guardado = false al cambiar el cb
    procedure cbNodoChange(Sender: TObject; cambiosForm: boolean);
    procedure cbNodoLinkeadoChange(Sender: TObject; cbLinkeado: TComboBox);
    //Fin de manipulación de nodos

    function valorCBNodoCombustible(cb: TComboBox): TNodoCombustible;
    function validarCBNodoCombustible(cb: TComboBox): boolean;
    function validarCBNodoCombustibleLinkeado(cb, cbLinkeado: TComboBox): boolean;

    //cambiosForm = true <-> se debe poner guardado = false al cambiar el cb
    procedure cbNodoCombustibleChange(Sender: TObject; cambiosForm: boolean);
    procedure cbNodoCombustibleLinkeadoChange(Sender: TObject; cbLinkeado: TComboBox);
    //Fin de manipulación de nodos


    //Manipulación de Fuentes en ComboBox
    //El valor Tag del cb guarda el indice del objeto anterior seleccionado
    procedure inicializarCBFuente(CBFuente, CBBorne: TComboBox; permiteNinguno: boolean);
    procedure inicializarCBFuenteHorarias_MonoBorne(CBFuente, CBBorne: TComboBox);
    procedure inicializarCBFuenteHorarias_BiBorne(CBFuente, CBBorne1,
      CBBorne2: TComboBox);

    procedure setCBFuente(cbFuente, cbBorne: TComboBox;
      fuente: TFuenteAleatoria; nombreBorne: string);
    procedure setCBFuente_biborne(cbFuente, cbBorne1, cbBorne2: TComboBox;
      fuente: TFuenteAleatoria; nombreBorne1, nombreBorne2: string);

    function valorCBFuente(cbFuente: TComboBox): TFuenteAleatoria;

    function validarCBFuente(CBFuente, CBBorne: TComboBox; kItemIndexMin: integer
    // Dependiendo de si la fuente ofrece <Nueva> , <Ninguno> o no este valor será 1,  2, o CERO
      ): boolean;
    function validarCBFuenteEolico(CBFuente, CBBorne: TComboBox): boolean;

    procedure cbFuenteChange(cbFuente: TObject; cbBorne: TComboBox);
    procedure cbBorneChange(cbFuente, cbBorne: TComboBox);

    procedure cbFuenteChange_biborne(cbFuente: TObject; cbBorne1, cbBorne2: TComboBox);

    //Un checkbox que habilita el conjunto y dos combos, uno para la fuente y uno para el borne
    procedure inicializarCBFuenteCondicional(cbCondicion: TCheckBox;
      etiquetaFuente, etiquetaBorne: TLabel; cbFuente, cbBorne: TComboBox;
      condEsCBTickeado: boolean; permiteNinguna: boolean);
    procedure setCBFuenteCondicional(cbCondicion: TCheckBox;
      etiquetaFuente, etiquetaBorne: TLabel; cbFuente, cbBorne: TComboBox;
      condEsCBTickeado: boolean; condicion: boolean; fuente: TFuenteAleatoria;
      borne: string);
    procedure cbFuenteCondicionalClick(cbCondicion: TCheckBox;
      etiquetaFuente, etiquetaBorne: TLabel; cbFuente, cbBorne: TComboBox;
      condEsCBTickeado: boolean);
    function validarCBFuenteCondicional(cbCondicion: TCheckBox;
      cbFuente, cbBorne: TComboBox; condEsCBTickeado: boolean): boolean;
    procedure valoresCBFuenteCondicional(cbCondicion: TCheckBox;
      cbFuente, cbBorne: TComboBox; condEsCBTickeado: boolean;
      var condicion: boolean; var fuente: TFuenteAleatoria; var borne: string);
    //Fin de manipulación de Fuentes


    //Manipulación de combustibles en ComboBox
    //El valor Tag del cb guarda el indice del objeto anterior seleccionado
    procedure inicializarCBCombustible(cb: TComboBox; permiteNinguno: boolean);
    procedure setCBCombustible(cb: TComboBox; valor: TCombustible);
    function valorCBCombustible(cb: TComboBox): TCombustible;
    function validarCBCombustible(cb: TComboBox): boolean;

    //cambiosForm = true <-> se debe poner guardado = false al cambiar el cb
    procedure cbCombustibleChange(Sender: TObject; cambiosForm: boolean);
    //Fin de manipulación de combustible




    //Manipulación de Arcos en ComboBox
    //El valor Tag del cb guarda el indice del objeto anterior seleccionado
    procedure inicializarCBArcos(cb: TComboBox; permiteNinguno: boolean);

    procedure setCBArco(cb: TComboBox; valor: Tarco);

    function valorCBArco(cb: TComboBox): TArco;

    function validarCBArco(cb: TComboBox): boolean;

    procedure cbArcoChange(Sender: TObject; cambiosForm: boolean);
   //Fin de manipulación de arcos


   //Manipulación de HidroConEmbalse en ComboBox
    //El valor Tag del cb guarda el indice del objeto anterior seleccionado
    procedure inicializarCBHidroConEmbalse(cb: TComboBox; permiteNinguno: boolean);
    procedure inicializarEditCV(edit:TEdit);

    procedure setCBHidroConEmbalse(cb: TComboBox; valor:THidroConEmbalse );

    function valorCBHidroConEmbalse(cb: TComboBox): THidroConEmbalse;

    function validarCBHidroConEmbalse(cb: TComboBox): boolean;

    procedure cbHidroConEmbalseChange(Sender: TObject; cambiosForm: boolean);
   //Fin de manipulación de HidroConEmbalse



    function validarFormulario: boolean; override;

  private
    //Estos dos son igual a cbFuenteChange pero no modifica guardado,
    //retorna true si hubieron cambios
    function cbFuenteChangeSinCambiarGuardado(cbFuente: TObject;
      cbBorne: TComboBox): boolean;
    function cbFuenteChangeSinCambiarGuardado_biborne(cbFuente: TObject;
      cbBorne1, cbBorne2: TComboBox): boolean;

    function rd_capa: integer;
    procedure wr_capa(xcapa: integer);

  public

    cosaEditable: TCosa; // puntero al Original de la cosa.

    constructor Create(AOwner: TComponent; cosaEditable: TCosa; xsala: TSalaDeJuego);
      reintroduce; virtual;

    property capa: integer read rd_capa write wr_capa;

  end;


implementation

uses SimSEEEditMain;

  {$R *.lfm}

constructor TBaseEditores.Create(AOwner: TComponent; cosaEditable: TCosa;
  xsala: TSalaDeJuego);
begin
  inherited Create_conSalaYEditor_(AOwner, xsala);
  self.cosaEditable := cosaEditable;
  if cosaEditable = nil then
  begin
    capa := 0;
  end
  else
  begin
    capa := cosaEditable.capa;
  end;
end;


function TBaseEditores.validarFormulario: boolean;
begin
  Result := inherited validarFormulario and validarEditInt(e_Capa);
end;

function TBaseEditores.rd_capa: integer;
begin
  Result := StrToInt(e_Capa.Text);
end;

procedure TBaseEditores.wr_capa(xcapa: integer);
begin
  e_Capa.Text := IntToStr(xcapa);
end;

procedure TBaseEditores.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin

end;

procedure TBaseEditores.FormCreate(Sender: TObject);
begin

end;

//Manipulación de nodos
procedure TBaseEditores.inicializarCBNodos(cb: TComboBox; permiteNinguno: boolean);
var
  i: integer;
begin
  cb.Items.Add(strAgregarNuevoNodo);
  if permiteNinguno then
    cb.Items.Add(strNodoNinguno);

  for i := 0 to sala.nods.Count - 1 do
    cb.Items.Add((sala.nods[i] as TNodo).nombre);

  if cb.Items.Count = 2 then
  begin
    cb.ItemIndex := 1;
  end
  else
  begin
    cb.ItemIndex := -1;
    cb.Text := strSeleccionarNodo;
  end;
  cb.Tag := cb.ItemIndex;
end;

procedure TBaseEditores.inicializarCBNodosLinkeados(cb, cbLinkeado: TComboBox);
begin
  inicializarCBNodos(cb, True);
  inicializarCBNodos(cbLinkeado, True);
end;

procedure TBaseEditores.inicializarCBNodosCombustible(cb: TComboBox;
  permiteNinguno: boolean);
var
  i: integer;
  a: TCosaConNombre;

begin
  cb.Items.Add(strAgregarNuevoNodo);
  if permiteNinguno then
    cb.Items.Add(strNodoNinguno);

  for i := 0 to sala.Sums.Count - 1 do
  begin
    a := sala.Sums.items[i] as TCosaConNombre;
    if a is TNodoCombustible then
      cb.Items.Add(a.nombre);
  end;

  if cb.Items.Count = 2 then
  begin
    cb.ItemIndex := 1;
  end
  else
  begin
    cb.ItemIndex := -1;
    cb.Text := strSeleccionarNodo;
  end;
  cb.Tag := cb.ItemIndex;
end;

procedure TBaseEditores.inicializarCBNodosCombustibleLinkeados(
  cb, cbLinkeado: TComboBox);
begin
  inicializarCBNodosCombustible(cb, False);
  inicializarCBNodosCombustible(cbLinkeado, False);
end;


procedure TBaseEditores.setCBNodo(cb: TComboBox; valor: TNodo);
begin
  if valor = nil then
  begin
    cb.ItemIndex := cb.Items.IndexOf(strNodoNinguno);
  end
  else
  begin
    cb.ItemIndex := cb.Items.IndexOf(valor.nombre);
  end;
  cb.Tag := cb.ItemIndex;
end;

procedure TBaseEditores.setCBNodoLinkeado(cb, cbLinkeado: TComboBox;
  valor, valorLinkeado: TNodo);
begin
  cb.ItemIndex := cb.Items.IndexOf(valor.nombre);
  cbLinkeado.Items.Delete(cbLinkeado.Items.IndexOf(valor.nombre));
  cbLinkeado.ItemIndex := cbLinkeado.Items.IndexOf(valorLinkeado.nombre);
  cb.Items.Delete(cb.Items.IndexOf(valorLinkeado.nombre));

  cb.Tag := cb.ItemIndex;
  cbLinkeado.Tag := cbLinkeado.ItemIndex;
end;


procedure TBaseEditores.setCBNodoCombustible(cb: TComboBox; valor: TNodoCombustible);
begin
  if valor = nil then
  begin
    cb.ItemIndex := cb.Items.IndexOf(strNodoNinguno);
  end
  else
  begin
    cb.ItemIndex := cb.Items.IndexOf(valor.nombre);
  end;
  cb.Tag := cb.ItemIndex;
end;

procedure TBaseEditores.setCBNodoCombustibleLinkeado(cb, cbLinkeado: TComboBox;
  valor, valorLinkeado: TNodoCombustible);
begin
  cb.ItemIndex := cb.Items.IndexOf(valor.nombre);
  cbLinkeado.Items.Delete(cbLinkeado.Items.IndexOf(valor.nombre));
  cbLinkeado.ItemIndex := cbLinkeado.Items.IndexOf(valorLinkeado.nombre);
  cb.Items.Delete(cb.Items.IndexOf(valorLinkeado.nombre));

  cb.Tag := cb.ItemIndex;
  cbLinkeado.Tag := cbLinkeado.ItemIndex;
end;



function TBaseEditores.valorCBNodo(cb: TComboBox): TNodo;
begin
  if cb.Items[cb.ItemIndex] = strNodoNinguno then
    Result := nil
  else
    Result := sala.nods.find(cb.Items[cb.ItemIndex]) as TNodo;
end;

function TBaseEditores.validarCBNodo(cb: TComboBox): boolean;
begin
  if cb.ItemIndex > 0 then
    Result := True
  else
  begin
    ShowMessage(mesSeleccionarNodoDeLista);
    cb.SetFocus;
    Result := False;
  end;
end;

function TBaseEditores.validarCBNodoLinkeado(cb, cbLinkeado: TComboBox): boolean;
begin
  if cb.ItemIndex > 0 then
    if cbLinkeado.ItemIndex > 0 then
      Result := True
    else
    begin
      ShowMessage(mesSeleccionarNodoDeSegLista);
      cbLinkeado.SetFocus;
      Result := False;
    end
  else
  begin
    ShowMessage(mesSeleccionarNodoDePrimLista);
    cb.SetFocus;
    Result := False;
  end;
end;

//cambiosForm = true <-> se debe poner guardado = false al cambiar el cb
procedure TBaseEditores.cbNodoChange(Sender: TObject; cambiosForm: boolean);
var
  nodo: TNodo;
begin
  if valorCBString(TComboBox(Sender)) = strAgregarNuevoNodo then
  begin
    nodo := FSimSEEEdit.altaActorClaseBase(TNodo) as TNodo;
    if nodo <> nil then
    begin
      TComboBox(Sender).Items.Add(nodo.nombre);
      TComboBox(Sender).ItemIndex := TComboBox(Sender).Items.Count - 1;
      if cambiosForm then
        guardado := False;
    end
    else
    begin
      TComboBox(Sender).ItemIndex := TComboBox(Sender).Tag;
      //      TComboBox(Sender).Text:= strSeleccionarNodo;
    end;
  end
  else if cambiosForm then
    guardado := False;

  TComboBox(Sender).Tag := TComboBox(Sender).ItemIndex;
end;

procedure TBaseEditores.cbNodoLinkeadoChange(Sender: TObject; cbLinkeado: TComboBox);
var
  oldStr, strCbCambiado: string;
  i: integer;
begin
  cbNodoChange(Sender, True);
  strCbCambiado := valorCBString(TComboBox(Sender));
  oldStr := valorCBString(cbLinkeado);

  cbLinkeado.Items.Clear;
  cbLinkeado.Items.Add(strNodoNinguno);
  cbLinkeado.Items.Add(strAgregarNuevoNodo);
  for i := 0 to sala.nods.Count - 1 do
    if (sala.nods[i] as TNodo).nombre <> strCbCambiado then
      cbLinkeado.Items.Add((sala.nods[i] as TNodo).nombre);

  if oldStr <> '' then
  begin
    cbLinkeado.ItemIndex := cbLinkeado.Items.IndexOf(oldStr);
    cbLinkeado.Tag := cbLinkeado.ItemIndex;
  end;
end;
//Fin de manipulación de nodos



//****************************


function TBaseEditores.valorCBNodoCombustible(cb: TComboBox): TNodoCombustible;
begin
  if cb.Items[cb.ItemIndex] = strNodoNinguno then
    Result := nil
  else
    Result := sala.sums.find(cb.Items[cb.ItemIndex]) as TNodoCombustible;
end;

function TBaseEditores.validarCBNodoCombustible(cb: TComboBox): boolean;
begin
  if cb.ItemIndex > 0 then
    Result := True
  else
  begin
    ShowMessage(mesSeleccionarNodoDeLista);
    cb.SetFocus;
    Result := False;
  end;
end;

function TBaseEditores.validarCBNodoCombustibleLinkeado(cb, cbLinkeado:
  TComboBox): boolean;
begin
  if cb.ItemIndex > 0 then
    if cbLinkeado.ItemIndex > 0 then
      Result := True
    else
    begin
      ShowMessage(mesSeleccionarNodoDeSegLista);
      cbLinkeado.SetFocus;
      Result := False;
    end
  else
  begin
    ShowMessage(mesSeleccionarNodoDePrimLista);
    cb.SetFocus;
    Result := False;
  end;
end;

procedure TBaseEditores.cbNodoCombustibleChange(Sender: TObject; cambiosForm: boolean);
var
  nodo: TNodoCombustible;
begin
  if valorCBString(TComboBox(Sender)) = strAgregarNuevoNodo then
  begin
    nodo := FSimSEEEdit.altaActorClaseBase(TNodoCombustible) as TNodoCombustible;
    if nodo <> nil then
    begin
      TComboBox(Sender).Items.Add(nodo.nombre);
      TComboBox(Sender).ItemIndex := TComboBox(Sender).Items.Count - 1;
      if cambiosForm then
        guardado := False;
    end
    else
    begin
      TComboBox(Sender).ItemIndex := TComboBox(Sender).Tag;
      //      TComboBox(Sender).Text:= strSeleccionarNodo;
    end;
  end
  else if cambiosForm then
    guardado := False;

  TComboBox(Sender).Tag := TComboBox(Sender).ItemIndex;
end;


procedure TBaseEditores.cbNodoCombustibleLinkeadoChange(Sender: TObject;
  cbLinkeado: TComboBox);

var
  oldStr, strCbCambiado: string;
  i: integer;
begin
  cbNodoCombustibleChange(Sender, True);
  strCbCambiado := valorCBString(TComboBox(Sender));
  oldStr := valorCBString(cbLinkeado);

  cbLinkeado.Items.Clear;
  cbLinkeado.Items.Add(strAgregarNuevoNodo);

  for i := 0 to sala.sums.Count - 1 do
    if sala.sums[i] is TNodoCombustible then
      if (sala.sums[i] as TNodoCombustible).nombre <> strCbCambiado then
        cbLinkeado.Items.Add((sala.sums[i] as TNodoCombustible).nombre);

  if oldStr <> '' then
  begin
    cbLinkeado.ItemIndex := cbLinkeado.Items.IndexOf(oldStr);
    cbLinkeado.Tag := cbLinkeado.ItemIndex;
  end;
end;
//Fin de manipulación de nodos




//**********************************

//Manipulación de Fuentes
procedure TBaseEditores.inicializarCBFuente(CBFuente, CBBorne: TComboBox;
  permiteNinguno: boolean);
var
  i: integer;
begin
  CBFuente.Items.Add(strAgregarNuevaFuente);
  if permiteNinguno then
    CBFuente.Items.Add(strFuenteNinguna);

  for i := 0 to sala.listaFuentes_.Count - 1 do
    CBFuente.Items.Add(TFuenteAleatoria(sala.listaFuentes_[i]).nombre);

  if CBFuente.Items.Count = 2 then
  begin
    CBFuente.ItemIndex := 1;
    cbFuenteChangeSinCambiarGuardado(CBFuente, CBBorne);
  end
  else
  begin
    CBFuente.ItemIndex := -1;
    CBFuente.Text := strSeleccionarFuente;
  end;

  CBFuente.Tag := CBFuente.ItemIndex;
  CBBorne.Tag := CBBorne.ItemIndex;
end;

procedure TBaseEditores.inicializarCBFuenteHorarias_MonoBorne(
  CBFuente, CBBorne: TComboBox);
var
  i: integer;
begin
  CBFuente.Items.Add(strAgregarNuevaFuente);
  if sala.globs.HorasDelPaso = 1 then
  begin
    for i := 0 to sala.listaFuentes_.Count - 1 do
      CBFuente.Items.Add(TFuenteAleatoria(sala.listaFuentes_[i]).nombre);
  end
  else
  begin
    for i := 0 to sala.listaFuentes_.Count - 1 do
      if TFuenteAleatoria(sala.listaFuentes_[i]).durPasoDeSorteoEnHoras = 1 then
        CBFuente.Items.Add(TFuenteAleatoria(sala.listaFuentes_[i]).nombre);
  end;

  if CBFuente.Items.Count = 2 then
  begin
    CBFuente.ItemIndex := 1;
    cbFuenteChangeSinCambiarGuardado(CBFuente, CBBorne);
  end
  else
  begin
    CBFuente.ItemIndex := -1;
    CBFuente.Text := strSeleccionarFuente;
  end;

  CBFuente.Tag := CBFuente.ItemIndex;
  CBBorne.Tag := CBBorne.ItemIndex;
end;



procedure TBaseEditores.inicializarCBFuenteHorarias_BiBorne(
  CBFuente, CBBorne1, CBBorne2: TComboBox);
var
  i: integer;
begin
  CBFuente.Items.Add(strAgregarNuevaFuente);
  if sala.globs.HorasDelPaso = 1 then
  begin
    for i := 0 to sala.listaFuentes_.Count - 1 do
      CBFuente.Items.Add(TFuenteAleatoria(sala.listaFuentes_[i]).nombre);
  end
  else
  begin
    for i := 0 to sala.listaFuentes_.Count - 1 do
      if TFuenteAleatoria(sala.listaFuentes_[i]).durPasoDeSorteoEnHoras = 1 then
        CBFuente.Items.Add(TFuenteAleatoria(sala.listaFuentes_[i]).nombre);
  end;

  if CBFuente.Items.Count = 2 then
  begin
    CBFuente.ItemIndex := 1;
    cbFuenteChangeSinCambiarGuardado_biborne(CBFuente, CBBorne1, CBBorne2);
  end
  else
  begin
    CBFuente.ItemIndex := -1;
    CBFuente.Text := strSeleccionarFuente;
  end;

  CBFuente.Tag := CBFuente.ItemIndex;
  CBBorne1.Tag := CBBorne1.ItemIndex;
  CBBorne2.Tag := CBBorne2.ItemIndex;
end;


procedure TBaseEditores.setCBFuente(cbFuente, cbBorne: TComboBox;
  fuente: TFuenteAleatoria; nombreBorne: string);
begin
  if fuente = nil then
    cbFuente.ItemIndex := cbFuente.Items.IndexOf(strFuenteNinguna)
  else
    cbFuente.ItemIndex := cbFuente.Items.IndexOf(fuente.nombre);

  cbFuenteChangeSinCambiarGuardado(cbFuente, cbBorne);
  setCBString(cbBorne, nombreBorne);
  CBFuente.Tag := CBFuente.ItemIndex;
  CBBorne.Tag := CBBorne.ItemIndex;
end;

procedure TBaseEditores.setCBFuente_biborne(cbFuente, cbBorne1, cbBorne2: TComboBox;
  fuente: TFuenteAleatoria; nombreBorne1, nombreBorne2: string);
begin
  if fuente = nil then
    cbFuente.ItemIndex := cbFuente.Items.IndexOf(strFuenteNinguna)
  else
    cbFuente.ItemIndex := cbFuente.Items.IndexOf(fuente.nombre);

  cbFuenteChangeSinCambiarGuardado_biborne(cbFuente, cbBorne1, cbBorne2);

  setCBString(cbBorne1, nombreBorne1);
  setCBString(cbBorne2, nombreBorne2);
  CBFuente.Tag := CBFuente.ItemIndex;
  CBBorne1.Tag := CBBorne1.ItemIndex;
  CBBorne2.Tag := CBBorne2.ItemIndex;
end;


function TBaseEditores.valorCBFuente(cbFuente: TComboBox): TFuenteAleatoria;
begin
  if cbFuente.ItemIndex < 0 then
    cbFuente.ItemIndex := 0;
  if cbFuente.Items[cbFuente.ItemIndex] = strFuenteNinguna then
    Result := nil
  else
    Result := TFuenteAleatoria(sala.listaFuentes_.find(
      cbFuente.Items[cbFuente.ItemIndex]));
end;

function TBaseEditores.validarCBFuente(CBFuente, CBBorne: TComboBox;
  kItemIndexMin: integer): boolean;
begin
  if (CBFuente.ItemIndex >= kItemIndexMin) then
  begin
    if CBFuente.Items[CBFuente.ItemIndex] <> strFuenteNinguna then
    begin
      if CBBorne.ItemIndex <> -1 then
        Result := True
      else
      begin
        ShowMessage(mesSeleccionarBorneLista);
        CBBorne.SetFocus;
        Result := False;
      end;
    end
    else
      Result := True;
  end
  else
  begin
    ShowMessage(mesDebeSeleccionarFuenteDeLista);
    CBFuente.SetFocus;
    Result := False;
  end;
end;

function TBaseEditores.validarCBFuenteEolico(CBFuente, CBBorne: TComboBox): boolean;
var
  fuente: TFuenteAleatoria;
begin
  if validarCBFuente(CBFuente, CBBorne, 0) then
  begin
    fuente := valorCBFuente(CBFuente);
    if fuente.durPasoDeSorteoEnHoras <> 1 then
    begin
      if (fuente.durPasoDeSorteoEnHoras = 0) and
        (sala.globs.HorasDelPaso = 1) then
      begin
        uCosa.procMsgAdvertenciaLectura(
          'Conectó un parque eólico a una fuente con paso de sorteo = 0. Si cambia la duración del paso de tiempo de la sala el generador se volverá invalido.');
        Result := True;
      end
      else
      begin
        ShowMessage(mesFuenteAleatConPaso1h + mesUstedLoConectoAFuente +
          fuente.nombre + mesConPasoDeSorteo + IntToStr(fuente.durPasoDeSorteoEnHoras));
        Result := False;
      end;
    end
    else
      Result := True;
  end
  else
    Result := False;
end;

function TBaseEditores.cbFuenteChangeSinCambiarGuardado(cbFuente: TObject;
  cbBorne: TComboBox): boolean;
var
  fuente: TFuenteAleatoria;
  canceloAlta, res: boolean;
begin
  canceloAlta := False;
  if valorCBString(TComboBox(cbFuente)) = strAgregarNuevaFuente then
  begin
    fuente := FSimSEEEdit.altaFuente as TFuenteAleatoria;
    if fuente <> nil then
    begin
      TComboBox(cbFuente).Items.Add(fuente.nombre);
      TComboBox(cbFuente).ItemIndex := TComboBox(cbFuente).Items.Count - 1;
      canceloAlta := False;
    end
    else
    begin
      canceloAlta := True;
      TComboBox(cbFuente).ItemIndex := TComboBox(cbFuente).Tag;
      fuente := valorCBFuente(TComboBox(cbFuente));
    end;
  end
  else
    fuente := valorCBFuente(TComboBox(cbFuente));

  if fuente <> nil then
  begin
    cbBorne.Items := fuente.NombresDeBornes_Publicados;
    if canceloAlta then
      cbBorne.ItemIndex := cbBorne.Tag
    else if cbBorne.Items.Count = 1 then
      cbBorne.ItemIndex := 0;
    cbBorne.Enabled := True;
    res := True;
  end
  else
  begin
    cbBorne.Items.Clear;
    cbBorne.Enabled := False;
    res := False;
  end;

  TComboBox(cbFuente).Tag := TComboBox(cbFuente).ItemIndex;
  CBBorne.Tag := CBBorne.ItemIndex;

  Result := res;
end;


function TBaseEditores.cbFuenteChangeSinCambiarGuardado_biborne(cbFuente: TObject;
  cbBorne1, cbBorne2: TComboBox): boolean;
var
  fuente: TFuenteAleatoria;
  canceloAlta, res: boolean;
begin
  canceloAlta := False;
  if valorCBString(TComboBox(cbFuente)) = strAgregarNuevaFuente then
  begin
    fuente := FSimSEEEdit.altaFuente as TFuenteAleatoria;
    if fuente <> nil then
    begin
      TComboBox(cbFuente).Items.Add(fuente.nombre);
      TComboBox(cbFuente).ItemIndex := TComboBox(cbFuente).Items.Count - 1;
      canceloAlta := False;
    end
    else
    begin
      canceloAlta := True;
      TComboBox(cbFuente).ItemIndex := TComboBox(cbFuente).Tag;
      fuente := valorCBFuente(TComboBox(cbFuente));
    end;
  end
  else
    fuente := valorCBFuente(TComboBox(cbFuente));

  if fuente <> nil then
  begin
    cbBorne1.Items := fuente.NombresDeBornes_Publicados;
    cbBorne2.Items := fuente.NombresDeBornes_Publicados;
    if canceloAlta then
    begin
      cbBorne1.ItemIndex := cbBorne1.Tag;
      cbBorne2.ItemIndex := cbBorne2.Tag;
    end
    else
    begin
      if cbBorne1.Items.Count = 1 then
        cbBorne1.ItemIndex := 0;
      if cbBorne2.Items.Count = 1 then
        cbBorne2.ItemIndex := 0;
    end;
    cbBorne1.Enabled := True;
    cbBorne2.Enabled := True;
    res := True;
  end
  else
  begin
    cbBorne1.Items.Clear;
    cbBorne2.Items.Clear;
    cbBorne1.Enabled := False;
    cbBorne2.Enabled := False;
    res := False;
  end;

  TComboBox(cbFuente).Tag := TComboBox(cbFuente).ItemIndex;
  CBBorne1.Tag := CBBorne1.ItemIndex;
  CBBorne2.Tag := CBBorne2.ItemIndex;

  Result := res;
end;


procedure TBaseEditores.cbFuenteChange(cbFuente: TObject; cbBorne: TComboBox);
begin
  if cbFuenteChangeSinCambiarGuardado(cbFuente, cbBorne) then
    guardado := False;
end;

procedure TBaseEditores.cbBorneChange(cbFuente, cbBorne: TComboBox);
begin
  guardado := False;
  cbBorne.Tag := cbBorne.ItemIndex;
end;

procedure TBaseEditores.cbFuenteChange_biborne(cbFuente: TObject;
  cbBorne1, cbBorne2: TComboBox);
begin
  if cbFuenteChangeSinCambiarGuardado_biborne(cbFuente, cbBorne1, cbBorne2) then
    guardado := False;
end;

procedure TBaseEditores.inicializarCBFuenteCondicional(cbCondicion: TCheckBox;
  etiquetaFuente, etiquetaBorne: TLabel; cbFuente, cbBorne: TComboBox;
  condEsCBTickeado: boolean; permiteNinguna: boolean);
begin
  //Por defecto arranca sin cumplir la condición
  cbCondicion.Checked := not condEsCBTickeado;
  inicializarCBFuente(cbFuente, cbBorne, permiteNinguna);
  etiquetaFuente.Enabled := False;
  cbFuente.Enabled := False;
  etiquetaBorne.Enabled := False;
  cbBorne.Enabled := False;
end;

procedure TBaseEditores.setCBFuenteCondicional(cbCondicion: TCheckBox;
  etiquetaFuente, etiquetaBorne: TLabel; cbFuente, cbBorne: TComboBox;
  condEsCBTickeado: boolean; condicion: boolean; fuente: TFuenteAleatoria;
  borne: string);
var
  cumpleCondicion: boolean;
begin
  cumpleCondicion := (condEsCBTickeado and condicion) or
    (not condEsCBTickeado and not condicion);

  cbCondicion.Checked := condicion;
  setCBFuente(cbFuente, cbBorne, fuente, borne);
  if cumpleCondicion then
  begin
    etiquetaFuente.Enabled := True;
    cbFuente.Enabled := True;
    etiquetaBorne.Enabled := True;
    cbBorne.Enabled := True;
  end
  else
  begin
    etiquetaFuente.Enabled := False;
    cbFuente.Enabled := False;
    etiquetaBorne.Enabled := False;
    cbBorne.Enabled := False;
  end;
end;

procedure TBaseEditores.cbFuenteCondicionalClick(cbCondicion: TCheckBox;
  etiquetaFuente, etiquetaBorne: TLabel; cbFuente, cbBorne: TComboBox;
  condEsCBTickeado: boolean);
var
  cumpleCondicion: boolean;
begin
  cumpleCondicion := (condEsCBTickeado and cbCondicion.Checked) or
    (not condEsCBTickeado and not cbCondicion.Checked);
  if cumpleCondicion then
  begin
    if etiquetaFuente <> nil then
      etiquetaFuente.Enabled := True;
    if etiquetaBorne <> nil then
      etiquetaBorne.Enabled := True;
    cbFuente.Enabled := True;
    cbBorne.Enabled := True;

    if cbFuente.Text = '' then
      cbFuente.Text := strSeleccionarFuente;
    if cbBorne.Text = '' then
      cbBorne.Text := strSeleccionarBorne;
  end
  else
  begin
    if etiquetaFuente <> nil then
      etiquetaFuente.Enabled := False;
    if etiquetaBorne <> nil then
      etiquetaBorne.Enabled := False;
    cbFuente.Enabled := False;
    cbBorne.Enabled := False;
  end;

  guardado := False;
end;

function TBaseEditores.validarCBFuenteCondicional(cbCondicion: TCheckBox;
  cbFuente, cbBorne: TComboBox; condEsCBTickeado: boolean): boolean;
var
  cumpleCondicion: boolean;
begin
  cumpleCondicion := (condEsCBTickeado and cbCondicion.Checked) or
    (not condEsCBTickeado and not cbCondicion.Checked);

  if cumpleCondicion then
    Result := validarCBFuente(cbFuente, cbBorne, 0)
  else
    Result := True;
end;

procedure TBaseEditores.valoresCBFuenteCondicional(cbCondicion: TCheckBox;
  cbFuente, cbBorne: TComboBox; condEsCBTickeado: boolean; var condicion: boolean;
  var fuente: TFuenteAleatoria; var borne: string);
var
  cumpleCondicion: boolean;
begin
  cumpleCondicion := (condEsCBTickeado and cbCondicion.Checked) or
    (not condEsCBTickeado and not cbCondicion.Checked);

  condicion := cbCondicion.Checked;
  if cumpleCondicion then
  begin
    fuente := valorCBFuente(cbFuente);
    borne := valorCBString(cbBorne);
  end
  else
  begin
    fuente := nil;
    borne := '';
  end;
end;
//Fin de manipulación de Fuentes


//Manipulación de combustibles en ComboBox
//El valor Tag del cb guarda el indice del objeto anterior seleccionado
procedure TBaseEditores.inicializarCBCombustible(cb: TComboBox; permiteNinguno: boolean);
var
  i: integer;
begin
  //  cb.Items.Add(strAgregarNuevoCombustible);
  if permiteNinguno then
    cb.Items.Add(strCombustibleNinguno);

  for i := 0 to sala.listaCombustibles.Count - 1 do
    cb.Items.Add(TCombustible(sala.listaCombustibles[i]).nombre);

  if cb.Items.Count = 2 then
  begin
    cb.ItemIndex := 1;
  end
  else
  begin
    cb.ItemIndex := -1;
    cb.Text := strSeleccionarCombustible;
  end;
  cb.Tag := cb.ItemIndex;
end;

procedure TBaseEditores.setCBCombustible(cb: TComboBox; valor: TCombustible);
begin
  if valor = nil then
  begin
    cb.ItemIndex := cb.Items.IndexOf(strCombustibleNinguno);
  end
  else
  begin
    cb.ItemIndex := cb.Items.IndexOf(valor.nombre);
  end;
  cb.Tag := cb.ItemIndex;
end;


function TBaseEditores.valorCBCombustible(cb: TComboBox): TCombustible;
begin
  if cb.Items[cb.ItemIndex] = strCombustibleNinguno then
    Result := nil
  else
    Result := TCombustible(sala.listaCombustibles.find(cb.Items[cb.ItemIndex]));
end;

function TBaseEditores.validarCBCombustible(cb: TComboBox): boolean;
begin
  if (cb.ItemIndex >= 0) and (cb.Items[cb.ItemIndex] <> strCombustibleNinguno) then
    Result := True
  else
  begin
    ShowMessage(mesSeleccionarCombustibleDeLista);
    cb.SetFocus;
    Result := False;
  end;
end;


//cambiosForm = true <-> se debe poner guardado = false al cambiar el cb
procedure TBaseEditores.cbCombustibleChange(Sender: TObject; cambiosForm: boolean);
//var
//combustible: TCombustible;
begin
  //  if valorCBString(TComboBox(Sender)) = strAgregarNuevoCombustible then
  //  begin
  //combustible := FSimSEEEdit.altaActorClaseBase(TCombustible) as TCombustible;
  //if combustible <> NIL then
  //begin
  //  TComboBox(Sender).Items.Add(combustible.nombre);
  //  TComboBox(Sender).ItemIndex := TComboBox(Sender).Items.Count - 1;
  //  if cambiosForm then
  //    guardado:= false;
  //end
  //else
  //    begin
  //      TComboBox(Sender).ItemIndex:= TComboBox(Sender).Tag;
  //    end;
  //  end
  //  else
  if cambiosForm then
    guardado := False;

  TComboBox(Sender).Tag := TComboBox(Sender).ItemIndex;
end;

//Fin de manipulación de combustible


//Manipulación de Arcos
procedure TBaseEditores.inicializarCBArcos(cb: TComboBox; permiteNinguno: boolean);
var
  i: integer;
begin
  //cb.Items.Add(strAgregarNuevoNodo);
  if permiteNinguno then
    cb.Items.Add(strArcoNinguno);

  for i := 0 to sala.arcs.Count - 1 do
    cb.Items.Add((sala.arcs[i] as TArco).nombre);

  if cb.Items.Count = 2 then
  begin
    cb.ItemIndex := 1;
  end
  else
  begin
    cb.ItemIndex := -1;
    cb.Text := strSeleccionarArco;
  end;
  cb.Tag := cb.ItemIndex;
end;


procedure TBaseEditores.setCBArco(cb: TComboBox; valor: TArco);
begin
  if valor = nil then
  begin
    cb.ItemIndex := cb.Items.IndexOf(strArcoNinguno);
  end
  else
  begin
    cb.ItemIndex := cb.Items.IndexOf(valor.nombre);
  end;
  cb.Tag := cb.ItemIndex;
end;

function TBaseEditores.valorCBArco(cb: TComboBox): TArco;
begin
  if cb.Items[cb.ItemIndex] = strArcoNinguno then
    Result := nil
  else
    Result := sala.arcs.find(cb.Items[cb.ItemIndex]) as TArco;
end;


function TBaseEditores.validarCBArco(cb: TComboBox): boolean;
begin
  if cb.ItemIndex > 0 then
    Result := True
  else
  begin
    ShowMessage(mesSeleccionarArcoDeLista);
    cb.SetFocus;
    Result := False;
  end;
end;

//cambiosForm = true <-> se debe poner guardado = false al cambiar el cb
procedure TBaseEditores.cbArcoChange(Sender: TObject; cambiosForm: boolean);
var
  arco: TArco;
begin
  {*if valorCBString(TComboBox(Sender)) = strAgregarNuevoArco then
  begin
    nodo := FSimSEEEdit.altaActorClaseBase(TNodo) as TNodo;
    if nodo <> nil then
    begin
      TComboBox(Sender).Items.Add(nodo.nombre);
      TComboBox(Sender).ItemIndex := TComboBox(Sender).Items.Count - 1;
      if cambiosForm then
        guardado := False;
    end
    else
    begin
      TComboBox(Sender).ItemIndex := TComboBox(Sender).Tag;
      //      TComboBox(Sender).Text:= strSeleccionarNodo;
    end;
  end
  else*}

  if cambiosForm then
    guardado := False;

  //TComboBox(Sender).Tag := TComboBox(Sender).ItemIndex;
end;

//Fin de manipulación de Arcos



//Manipulación de HidroConEmbalse
procedure TBaseEditores.inicializarCBHidroConEmbalse(cb: TComboBox; permiteNinguno: boolean);
var
  i: integer;
begin
  //cb.Items.Add(strAgregarNuevoNodo);
  if permiteNinguno then
    cb.Items.Add(strHidroConEmbalseNinguno);

  for i := 0 to sala.gens.Count - 1 do
  begin
    if (sala.gens[i] is THidroConEmbalse) then
       cb.Items.Add((sala.gens[i] as TCosaConNombre).nombre);
  end;

  if cb.Items.Count = 1 then
  begin
    cb.ItemIndex := 0;
  end
  else
  begin
    cb.ItemIndex := -1;
    cb.Text := strSeleccionarHidroConEmbalse;
  end;
  cb.Tag := cb.ItemIndex;
end;


procedure TBaseEditores.inicializarEditCV(edit:TEdit);
begin
  edit.Text:='0';
end;

procedure TBaseEditores.setCBHidroConEmbalse(cb: TComboBox; valor: THidroConEmbalse);
begin
  if valor = nil then
  begin
    cb.ItemIndex := cb.Items.IndexOf(strHidroConEmbalseNinguno);
  end
  else
  begin
    cb.ItemIndex := cb.Items.IndexOf(valor.nombreBorne);
  end;
  cb.Tag := cb.ItemIndex;
end;

function TBaseEditores.valorCBHidroConEmbalse(cb: TComboBox): THidroConEmbalse;
begin
  if cb.Items[cb.ItemIndex] = strHidroConEmbalseNinguno then
    Result := nil
  else
    Result := sala.gens.find(cb.Items[cb.ItemIndex]) as THidroConEmbalse;
end;


function TBaseEditores.validarCBHidroConEmbalse(cb: TComboBox): boolean;
begin
  if cb.ItemIndex > 0 then
    Result := True
  else
  begin
    ShowMessage(mesSeleccionarHidroDeLista);
    cb.SetFocus;
    Result := False;
  end;
end;

//cambiosForm = true <-> se debe poner guardado = false al cambiar el cb
procedure TBaseEditores.cbHidroConEmbalseChange(Sender: TObject; cambiosForm: boolean);
var
  HidroConEmbalse: THidroConEmbalse;
begin
  {*if valorCBString(TComboBox(Sender)) = strAgregarNuevoArco then
  begin
    nodo := FSimSEEEdit.altaActorClaseBase(TNodo) as TNodo;
    if nodo <> nil then
    begin
      TComboBox(Sender).Items.Add(nodo.nombre);
      TComboBox(Sender).ItemIndex := TComboBox(Sender).Items.Count - 1;
      if cambiosForm then
        guardado := False;
    end
    else
    begin
      TComboBox(Sender).ItemIndex := TComboBox(Sender).Tag;
      //      TComboBox(Sender).Text:= strSeleccionarNodo;
    end;
  end
  else*}

  if cambiosForm then
    guardado := False;

  //TComboBox(Sender).Tag := TComboBox(Sender).ItemIndex;
end;

//Fin de manipulación de HidroConEmbalse


end.
