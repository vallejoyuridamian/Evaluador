unit uManejadorListadoEditores;

interface

uses
  StdCtrls, ExtCtrls, ComCtrls, Controls, Classes, uInfoTabs,
  uCosaConNombre, uBaseFormularios, uBaseEditoresCosasConNombre, usalasdejuego, SysUtils,
  xMatDefs, Windows, Forms, uConstantesSimSEE, Graphics,
  Buttons;

resourcestring
  exFormularioEdicionParaClase =
    'Formulario de edición no registrado para la clase ';

type
  TFuncAlta = function(const nombreTab: string): TCosaConNombre of object;
  TFuncClonar = function(cosaConNombreOrig: TCosaConNombre): TCosaConNombre of object;
  TFuncEliminar = function(cosaConNombre: TCosaConNombre): boolean of object;

  { TManejadorListadoEditores }

  TManejadorListadoEditores = class(TObserverCambioDatos)
  private
    oldListadoOnClick, oldTCClasificacionOnChange, oldBAgregarOnClick,
    oldBEliminarOnClick, oldBClonarOnClick: TNotifyEvent;
    oldTCClasificacionOnChanging: TTabChangingEvent;
    oldIListado: Integer;

    procedure llenarListado;
    procedure tcClasificacionOnChanging(Sender: TObject; var AllowChange: boolean);
    procedure listadoOnClick(Sender: TObject);
    procedure tcClasificacionOnChange(Sender: TObject);

    procedure bAgregarClick(Sender: TObject);
    procedure bEliminarClick(Sender: TObject);
    procedure bClonarClick(Sender: TObject);

    procedure setBotonesEnabled;
  public
    listado: TListBox;
    gbEditor: TGroupBox;
    sbEditor: TScrollBox;
    tcClasificacion: TTabControl;
    bAgregar, bEliminar, bClonar: TBitBtn;

    funcAlta: TFuncAlta;
    funcClonar: TFuncClonar;
    funcEliminar: TFuncEliminar;

    listaObjetos: TListaDeCosasConNombre;
    sala: TSalaDeJuego;

    liberarEditorActivo: Boolean;
    editorActivo: TBaseEditoresCosasConNombre;

    pageControlPrincipal: TPageControl;
    paginaEditores: TTabSheet;

    listaObservadoresCambioDatos: TList;

    constructor Create(listado: TListBox; gbEditor: TGroupBox;
      sbEditor: TScrollBox; tcClasificacion: TTabControl;
      bAgregar, bEliminar, bClonar: TBitBtn; listaObjetos: TListaDeCosasConNombre;
      sala: TSalaDeJuego; funcAlta: TFuncAlta; funcClonar: TFuncClonar;
      funcEliminar: TFuncEliminar; pageControlPrincipal: TPageControl;
      paginaEditores: TTabSheet);

    procedure Free;
    procedure notificarGuardarDatos; override;
    procedure notificarCancelar; override;
  end;

implementation

uses
  SimSEEEditMain;

{ TManejadorListadoEditores }

procedure TManejadorListadoEditores.bAgregarClick(Sender: TObject);
var
  cosaConNombre: TCosaConNombre;
begin
  cosaConNombre := funcAlta(tcClasificacion.Tabs[tcClasificacion.TabIndex]);
  if cosaConNombre <> NIL then
  begin
    notificarGuardarDatos;
    listado.ItemIndex := listado.Items.IndexOf(cosaConNombre.nombre);
    listadoOnClick(Sender);
  end;
end;

procedure TManejadorListadoEditores.bClonarClick(Sender: TObject);
var
  cosaAClonar, clon: TCosaConNombre;
begin
  if listado.ItemIndex >= 0 then
  begin
    cosaAClonar := listaObjetos.find(listado.Items[listado.ItemIndex]);
    clon := funcClonar(cosaAClonar);
    if clon <> NIL then
    begin
      llenarListado;
      listado.ItemIndex := listado.Items.IndexOf(clon.nombre);
      listadoOnClick(Sender);
    end;
  end;
end;

procedure TManejadorListadoEditores.bEliminarClick(Sender: TObject);
var
  cosaAEliminar: TCosaConNombre;
  oldItemIndex: Integer;
begin
  oldItemIndex := listado.ItemIndex;
  if oldItemIndex >= 0 then
  begin
    cosaAEliminar := listaObjetos.find(listado.Items[listado.ItemIndex]);
    if funcEliminar(cosaAEliminar) then
    begin
      llenarListado;
      if listado.Items.Count > oldItemIndex then
        listado.ItemIndex := listado.Items.Count
      else
        listado.ItemIndex := -1;
      listadoOnClick(Sender);
      setBotonesEnabled;
    end;
  end;
end;

constructor TManejadorListadoEditores.Create(listado: TListBox;
  gbEditor: TGroupBox; sbEditor: TScrollBox; tcClasificacion: TTabControl;
  bAgregar, bEliminar, bClonar: TBitBtn; listaObjetos: TListaDeCosasConNombre;
  sala: TSalaDeJuego; funcAlta: TFuncAlta; funcClonar: TFuncClonar;
  funcEliminar: TFuncEliminar; pageControlPrincipal: TPageControl;
  paginaEditores: TTabSheet);
var
  i: Integer;
  nombresTabs: TDAOfString;
begin
  inherited Create;
  self.listado := listado;
  self.gbEditor := gbEditor;
  self.sbEditor := sbEditor;
  self.tcClasificacion := tcClasificacion;
  self.bAgregar := bAgregar;
  self.bEliminar := bEliminar;
  self.bClonar := bClonar;
  self.pageControlPrincipal := pageControlPrincipal;
  Self.paginaEditores := paginaEditores;

  self.funcAlta := funcAlta;
  self.funcClonar := funcClonar;
  self.funcEliminar := funcEliminar;
  self.editorActivo := NIL;
  self.liberarEditorActivo := False;

  self.listaObjetos := listaObjetos;
  self.sala := sala;
  self.listaObservadoresCambioDatos := TList.Create;

  // Sobreescribir eventos de los componentes
  oldListadoOnClick := listado.OnClick;
  listado.OnClick := listadoOnClick;
  oldTCClasificacionOnChange := tcClasificacion.OnChange;
  tcClasificacion.OnChange := tcClasificacionOnChange;
  oldTCClasificacionOnChanging := tcClasificacion.OnChanging;
  tcClasificacion.OnChanging := tcClasificacionOnChanging;
  oldBAgregarOnClick := bAgregar.OnClick;
  bAgregar.OnClick := bAgregarClick;
  oldBEliminarOnClick := bEliminar.OnClick;
  bEliminar.OnClick := bEliminarClick;
  oldBClonarOnClick := bClonar.OnClick;
  bClonar.OnClick := bClonarClick;

  gbEditor.Caption := '';
  nombresTabs := infoTabs.getNombresTabs;
  tcClasificacion.Tabs.Clear;
  for i := 0 to high(nombresTabs) do
    tcClasificacion.Tabs.Add(nombresTabs[i]);
  tcClasificacion.TabIndex := 0;
  tcClasificacionOnChange(NIL);
  setBotonesEnabled;
end;

procedure TManejadorListadoEditores.Free;
var
   oldPage: TTabSheet;
begin
  if editorActivo <> NIL then
  begin
    LockWindowUpdate(FSimSEEEdit.Handle);
    oldPage := pageControlPrincipal.ActivePage;
    pageControlPrincipal.ActivePage := paginaEditores;
    if not liberarEditorActivo then
    begin
    editorActivo.Close;
    editorActivo.Parent := NIL;
    end;
    editorActivo.Free;
    pageControlPrincipal.ActivePage := oldPage;
    LockWindowUpdate(0);
  end;
  listaObservadoresCambioDatos.Free;

  //Restaurar eventos de los controles
  listado.OnClick := oldListadoOnClick;
  tcClasificacion.OnChange := oldTCClasificacionOnChange;
  tcClasificacion.OnChanging := oldTCClasificacionOnChanging;
  bAgregar.OnClick := oldBAgregarOnClick;
  bEliminar.OnClick := oldBEliminarOnClick;
  bClonar.OnClick := oldBClonarOnClick;

  inherited Free;
end;

procedure TManejadorListadoEditores.listadoOnClick(Sender: TObject);
var
  infoClase: TInfoCosaConNombre;
  cosaAEditar: TCosaConNombre;
  claseCosaAEditar: TClass;
  cambiarEditor: boolean;
begin
  LockWindowUpdate(FSimSEEEdit.Handle);

  //Si ya había un editor anterior lo libero, fijando su Owner a NIL para que
  //este no lo libere también.
  if (editorActivo <> nil) and (Sender <> NIL) then
  begin
    if liberarEditorActivo or editorActivo.CloseQuery then
    begin
    editorActivo.Parent := NIL;
    editorActivo.Free;
      editorActivo := NIL;
      gbEditor.Caption := '';
      cambiarEditor := listado.ItemIndex >= 0;
      liberarEditorActivo := False;
    end
    else
    begin
      cambiarEditor := False;
      listado.ItemIndex := oldIListado;
  end;
  end
  else
    cambiarEditor := listado.ItemIndex >= 0;

  if cambiarEditor then
  begin
  cosaAEditar := listaObjetos.find(listado.Items[listado.ItemIndex]);
  claseCosaAEditar := cosaAEditar.ClassType;
  infoClase := infoTabs.getInfoActor(claseCosaAEditar);
  if infoClase <> nil then
  begin
      uConstantesSimSEE.calcularTamaniosTablas(sbEditor.ClientHeight,
        sbEditor.ClientWidth, True);
      editorActivo := infoClase.ClaseEditor.Create(nil, sala,
        claseCosaAEditar, cosaAEditar);
      editorActivo.Parent := sbEditor;
      editorActivo.BorderStyle := bsNone;

      //editorActivo.HorzScrollBar.Range := editorActivo.ClientWidth;
      //editorActivo.VertScrollBar.Range := editorActivo.ClientHeight;
    editorActivo.AutoSize := False;
    editorActivo.Align := alClient;
    editorActivo.Color := clWindow;
      gbEditor.Caption := 'Editando ' + cosaAEditar.DescClase +
        ' "' + cosaAEditar.nombre + '"';
{$IFDEF FPC}
    editorActivo.BorderSpacing.Top := 10;
    editorActivo.BorderSpacing.left := 10;
{$ENDIF}
    editorActivo.listaObservadoresCambioDatos_.Add(self);
    editorActivo.Show;
  end
  else
      raise Exception.Create(exFormularioEdicionParaClase + '"' +
        cosaAEditar.ClaseNombre + '"');
  end;
  oldIListado := listado.ItemIndex;

  setBotonesEnabled;
  LockWindowUpdate(0);
  if Assigned(oldListadoOnClick) then
    oldListadoOnClick(Sender);
end;

procedure TManejadorListadoEditores.llenarListado;
var
  infoTabSeleccionada: TInfoTab;
  objetoI: TCosaConNombre;
  i: Integer;
begin
  infoTabSeleccionada := infoTabs.getInfoTab(
    tcClasificacion.Tabs[tcClasificacion.TabIndex]);

  listado.Items.Clear;
  for i := 0 to listaObjetos.Count - 1 do
  begin
    objetoI := TCosaConNombre(listaObjetos[i]);
    if infoTabSeleccionada.perteneceClase(objetoI.ClassType) then
      listado.Items.Add(objetoI.nombre);
  end;
end;

procedure TManejadorListadoEditores.notificarGuardarDatos;
var
  oldItemIndex, i: integer;
begin
  oldItemIndex := listado.ItemIndex;
  llenarListado;
  if listado.Items.Count > oldItemIndex then
    listado.ItemIndex := oldItemIndex;

  for i := 0 to listaObservadoresCambioDatos.Count - 1 do
    TObserverCambioDatos(listaObservadoresCambioDatos[i]).notificarGuardarDatos;
end;

procedure TManejadorListadoEditores.notificarCancelar;
var
  i: Integer;
begin
  editorActivo.Parent := NIL;
  //No lo puedo liberar acá porque estoy en su click del botón cancelar
  //Lo marco para liberar la próxima vez que se use
//  editorActivo.Free;
//  editorActivo := nil;
  liberarEditorActivo := True;
  gbEditor.Caption := '';

  for i := 0 to listaObservadoresCambioDatos.Count - 1 do
    TObserverCambioDatos(listaObservadoresCambioDatos[i]).notificarCancelar;
end;

procedure TManejadorListadoEditores.setBotonesEnabled;
begin
  bEliminar.Enabled := listado.Items.Count > 0;
  bClonar.Enabled := bEliminar.Enabled;
end;

procedure TManejadorListadoEditores.tcClasificacionOnChange(Sender: TObject);
{var
 i: Integer;}
begin
  oldIListado := -1;
  llenarListado;

  if listado.Items.Count > 0 then
  begin
    listado.ItemIndex := 0;
    listadoOnClick(Sender);
  end;

  setBotonesEnabled;
  if Assigned(oldTCClasificacionOnChange) then
    oldTCClasificacionOnChange(Sender);
end;

procedure TManejadorListadoEditores.tcClasificacionOnChanging(Sender: TObject;
  var AllowChange: boolean);
begin
  if editorActivo <> NIL then
  begin
    if liberarEditorActivo or editorActivo.CloseQuery then
    begin
      editorActivo.Parent := NIL;
      editorActivo.Free;
      editorActivo := NIL;
      gbEditor.Caption := '';
      AllowChange := True;
      liberarEditorActivo := False;
    end
    else
      AllowChange := False;
  end;
end;

end.
