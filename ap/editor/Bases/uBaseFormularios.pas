unit uBaseFormularios;

interface

uses
{$IFDEF FPC-LCL}
  LResources,
  EditBtn,
{$ENDIF}
{$IFDEF WINDOWS}
  Windows,
{$ELSE}
  LCLType,
{$ENDIF}
  Messages, SysUtils, Variants,
  Controls, Forms,
  Dialogs, xMatDefs, StdCtrls, Grids,
  utilidades,
  uConstantesSimSEE, Math,
  ExtCtrls,
  Classes,
  ucosa,
  usalasdejuego,
  usalasdejuegoParaEditor,
  Graphics;

resourcestring
  exFueraDeRango = 'Fuera de Rango';
  mesErrorAlConvertir = 'Error al convertir.';
  mesSeEsperaUnReal = 'Se espera un número en punto flotante.';
  mesSeEsperaUnEntero = 'Se espera un número entero.';

  mesValorIntroducidoDebeNumYEntre =
    'El valor ingresado debe ser numérico y estar entre ';
  mesY = ' y ';
  mesValorIntroducidoDebeRealYEntre = 'El valor ingresado debe ser real y estar entre ';
  mesFechaIngresadaNoValida = 'La fecha ingresada no es valida';
  mesNombreArchivoNoValido = 'El nombre de archivo ingresado no es válido.';
  mesElArchivo = 'El archivo ';
  mesNoExiste = ' no existe!';
  mesDebeIngresarValorCampo = 'Debe ingresar un valor en el campo ';
  mesValorEnTablaDebeSerFecha = 'El valor ingresado en la tabla debe ser una fecha';
  mesValorEnTablaDebeSerEntero =
    'El valor ingresado en la tabla debe ser un número entero';
  mesValorEnTablaDebeSerReal = 'El valor ingresado en la tabla debe ser un número real';
  mesValoresEnTablaNumericos =
    'Los valores introducidos en la tabla deben ser numéricos';
  mesValorIntroducidoDebeNum = 'El valor introducido debe ser numérico';
  mesSimSEEEdit = 'SimSEEEdit';
  mesValorTablaDebeNumYEntre =
    'Los valores ingresados en la tabla deben ser númericos y estar entre ';
  mesValoresEnTablaOrdenadosCreciente =
    'Los valores ingresados en la tabla deben estar ordenados' + ' de forma creciente';
  mesValoresEnTablaOrdenadosDecreciente =
    'Los valores ingresados en la tabla deben estar ordenados' + ' de forma decreciente';
  mesValoresEnTablaDebenSerNumericos =
    'Los valores ingresados en la tabla deben ser númericos';
  mesNoGuardadoCambiosGuardarAhora =
    'No se han guardado los cambios. ¿Desea guardarlos ahora?';
  mesConfirmarSalida = 'Confirmar Salida';
  RS_TITULO = 'Tïtulo';
  RS_UNIDADES = 'Unidades';
  RS_TITULO_DE_COLUMNA = 'Título de Columna';


const
  teclas = [VK_Return, VK_Tab, VK_Left, VK_Up, VK_Right, VK_Down, VK_Home, VK_End];

type

  { TCampoBaseFormulario }

  TEdit_BaseFormulario = class
    evaluador: TEvaluadorConCatalogo;
    componente: TComponent;
    campoLnk: TCosa_CampoLnk;
    constructor Create(xComponente: TComponent; xCampoLnk: TCosa_CampoLnk;
      xEvaluador: TEvaluadorConCatalogo);
    procedure LoadToFormulario; virtual;
    procedure SaveFromFormulario; virtual;
    function haycambios: boolean; virtual;
    function test: string; virtual;
  end;

  { TComboCosa_BaseFormulario }

  TComboCosa_BaseFormulario = class(TEDit_BaseFormulario)
    opcionesLst: TStrings;
    constructor Create(xComponente: TComboBox; xCampoLnk: TCosa_CampoLnk;
      xEvaluador: TEvaluadorConCatalogo; xListaopciones: TStrings);
    procedure LoadToFormulario; virtual;
    procedure SaveFromFormulario; virtual;
    function haycambios: boolean; virtual;
    function test: string; virtual;
  end;

  TObserverCambioDatos = class
  public
    procedure notificarGuardarDatos; virtual; abstract;
    procedure notificarCancelar; virtual; abstract;
  end;

  TClaseDeFormularios = class of TBaseFormularios;

  //Clase base de los formularios.
  //Tiene métodos para validar Edits de tipo fecha, entero, real, string, nombre archivo y
  //tablas de números reales así como funciones para manipular ComboBoxes cuyos
  //valores sean strings y conjuntos de componentes editFloatCondicional, SGString y SGVectorDeReales

  { TBaseFormularios }

  TBaseFormularios = class(TForm)
    iconos: TImageList;
    iconos2: TImageList;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormResize(Sender: TObject);

  published
    procedure CBEnter(Sender: TObject);

    //Guarda en loQueHabia el valor del texto del edit
    procedure EditEnter(Sender: TObject);

    //si loQueHabia <> TEdit(Sender).Text then guardado:= false
    procedure EditExit(Sender: TObject);
    procedure EditNArchExit(Sender: TObject);
    procedure EditAnioExit(Sender: TObject);
    procedure EditSemanaExit(Sender: TObject);
    procedure EditFechaExit(Sender: TObject);
    procedure EditIntExit(Sender: TObject; min, max: integer);
    procedure EditFloatExit(Sender: TObject; min, max: NReal);
    procedure EditStringExit(Sender: TObject; trimText: boolean);

    procedure DTPChange(Sender: TObject);
    procedure CBChange(Sender: TObject);

    procedure sgGetEditText(Sender: TObject; ACol, ARow: integer;
      var Value: string);
    //Se fijan si hubo cambios y validan el componente
    procedure sgKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure sgValidarCambio(Sender: TObject);

    //Solo se fijan si hubo cambios
    procedure sgChequearCambios(Sender: TObject);
    procedure sgChequearCambiosKeyDown(Sender: TObject; var Key: word;
      Shift: TShiftState);

    procedure sgMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure sgMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer); virtual; abstract;
    procedure sgDrawCell(Sender: TObject; Col, Row: integer; Rect: TRect;
      State: TGridDrawState);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    //Si no se han guardado los cambios pregunta si se desea continuar sin salvar,
    //si estan guardados permite cerrar la ventana
    procedure BCancelarClick(Sender: TObject);
    //Intenta cerrar la ventana. Antes de cerrarse se llama a formCloseQuery
    procedure BGuardarClick(Sender: TObject); virtual; abstract;
    //Guarda el actor nuevo o que se este editando
    procedure cambiosForm(Sender: TObject);

  protected
    colValidarSG, filaValidarSG: integer;

    loQueHabia: string;           {El valor anterior valido en el campo editable}

    modificado: boolean; // indica si ha sido modificado.
    validarSg: boolean;          {Indica si se debe validar una stringgrid}

    maxAnchoTablaChica, maxAnchoTablaMediana, maxAnchoTablaGrande,
    maxAnchoTablaMuyGrande, maxAnchoTablaEnorme: integer;
    maxAlturaTablaChica, maxAlturaTablaMediana, maxAlturaTablaGrande,
    maxAlturaTablaMuyGrande, maxAlturaTablaEnorme: integer;

    procedure calcularTamaniosTablas;

    //Validan que el valor ingresado en el campo de un edit sea del tipo indicado
    //y que esté entre min y max
    function validarEditInt(Sender: TCustomEdit; min: integer; max: integer): boolean;
      overload;

    function validarEditFloat(Sender: TCustomEdit; min, max: NReal): boolean; overload;

    // verifica la conversión pero sin límites
    function validarEditInt(Sender: TCustomEdit): boolean; overload;
    function validarEditFloat(Sender: TCustomEdit): boolean; overload;
    function validarEditDAOfNReal(Sender: TCustomEdit; min, max: NReal;
      sep: char): boolean;
    function validarEditFecha(Sender: TCustomEdit): boolean;
    function validarEditNarch(Sender: TCustomEdit): boolean; virtual;
    function validarEditString(Sender: TCustomEdit; etiqueta: string): boolean;
    function validarMemo(Sender: TMemo; etiqueta: string): boolean;

    //Valida si un TDateEdit es valido
      {$IFDEF FPC-LCL}
    function validarTDateTimeEdit(Sender: TDateEdit): boolean;
      {$ENDIF}

    //Este conjunto está formado por un checkBox, una etiqueta y un edit
    //La idea es que el valor del edit es valido según el checkBox, se puede
    //especificar si checkBox tickeado->edit Valido o si
    //not chechBox tickeado->edit Valido
    procedure cbEditFloatCondicionalClick(cbCondicion: TCheckBox;
      etiqueta: TLabel; edit: TCustomEdit; condEsCBTickeado: boolean);
    function validarEditFloatCondicional(cbCondicion: TCheckBox;
      edit: TCustomEdit; min, max: NReal; condEsCBTickeado: boolean): boolean;
    procedure valoresEditFloatCondicional(cbCondicion: TCheckBox;
      edit: TCustomEdit; condEsCBTickeado: boolean; var condicion: boolean;
      var valor: NReal);

    //verifica que todos los datos del formulario sean validos. Deja loQueHabia
    //vacio para asegurarse de que verifique todos los campos
    function validarFormulario(): boolean; virtual;

    function validarCeldaFecha(tabla: TStringGrid; fila, columna: integer): boolean;
    function validarCeldaNInt(tabla: TStringGrid; fila, columna: integer): boolean;
    function validarCeldaNReal(tabla: TStringGrid; fila, columna: integer): boolean;

    //verifica que todos los valores en tabla puedan ser convertidos a reales
    function validarTablaNReals_(tabla: TStringGrid): boolean; virtual;

    function filaTablaNReals(tabla: TStringGrid; iFila: integer): TDAofNReal;
    function columnaTablaNReals(tabla: TStringGrid; iColumna: integer): TDAofNReal;

    //verifica que el cambio hecho en la tabla sea valido, si no lo es muestra
    //un mensaje y deshace el cambio
    procedure validarCambioTablaNReals(tabla: TStringGrid); virtual;

    //verifica que un cambio en la tabla sea valido
    procedure validarCambioTabla(tabla: TStringGrid); virtual; abstract;

    //mueve todos los controles que esten debajo de desde desplazamiento
    //pixeles hacia abajo. Los controles en desde no se ven afectados.
    //Para mover hacia arriba usar con desplazamiento negativo
    procedure cambiarTopControles(desde, desplazamiento: integer);
    //chequea que los cambios se hayan guardado y si no pregunta al usuario si desea
    //guardar
    //si esta guardado retorna IDNO
    //si no esta guardado y el usuario ingresa si retorna IDYES
    //si no esta guardado y el usuario ingresa no retorna IDNO
    //si no esta guardado y el usuario ingresa cancel retorna IDCANCEL
    function hayQueGuardar(mensaje: string): integer;

    procedure setCBString(cb: TComboBox; valor: string);
    function valorCBString(cb: TComboBox): string;

(*********OJO esto es una mala solución, depende de los Strings de los RadioButtonGroups que
cualquiera  puede cambiar al traducir los formularios a otro idioma pro ejemplo.
NO ES ROBUZTO y tiene que cambiarse en todos lados por cosas como
RGValoresAComparar.ItemIndex:= Ord( printCronVarCast.tipoValorAComparar);

y directametne al definir los tipos ENUMERADOS que definen las opciopnes se obliga a que el
0 CERO sea la primera, el 1 la segunda y así sucesivamente.
      procedure setRGString(rg: TRadioGroup; valor: String);
      function valorRGString(rg: TRadioGroup): String;
      *****************)

    //Este conjunto esta compuesto por un TStringGrid, un edit, una etiqueta y
    //un boton. El usuario escribe un string en el edit, luego hace click en el
    //boton y esta se agrega a la tabla. Encabezados sigue el mismo formato que
    //los listados, por lo que se puede agregar botones a la tabla para clonar,
    //eliminar, mover valores, etc
    procedure inicializarSGString(sg: TStringGrid; encabezados: array of string;
      var tiposCols: TDAOfTTipoColumna; eString: TCustomEdit;
      etiqueta: TLabel; bAgregar: TButton);

    procedure setSGString(sg: TStringGrid; strings: TDAofString);
    function valorSGString(sg: TStringGrid): TDAofString;
    procedure addSGString(sg: TStringGrid; eString: TCustomEdit;
      etiqueta: string; deshabilitarScrollHorizontal: boolean);
    procedure eStringKeyDown(sg: TStringGrid; eString: TCustomEdit;
      etiqueta: string; deshabilitarScrollHorizontal: boolean;
      var Key: word; Shift: TShiftState);
    procedure eliminarSGString(sg: TStringGrid; fila: integer;
      eString: TCustomEdit; deshabilitarScrollHorizontal: boolean);

    //Este conjunto esta compuesto por un TStringGrid, un edit, una etiqueta y
    //un boton. El usuario escribe un real en el edit, luego hace click en el
    //boton y este se agrega a la tabla
    procedure setSGVectorDeReales(sg: TStringGrid; eTamanio: TCustomEdit;
      reales: TDAofNReal);
    function valorSGVectorDeReales(sg: TStringGrid): TDAofNReal;
    procedure cambioTamanioSGVectorDeReales(sg: TStringGrid;
      eTamanio: TCustomEdit; minTamanio, maxTamanio: integer;
      deshabilitarScrollHorizontal: boolean);
    procedure eTamSGVectorDeRealesChange(sg: TStringGrid; eTamanio: TCustomEdit;
      minTamanio, maxTamanio: integer; deshabilitarScrollHorizontal: boolean);
    function validarSGVectorDeReales(sg: TStringGrid): boolean;
    function validarSGVectorDeRealesMinMax(sg: TStringGrid; min, max: NReal): boolean;
    function validarSGVectorDeRealesOrdenado(sg: TStringGrid;
      creciente: boolean): boolean;

  public

    rbtEditorSala: TRbtEditorSala;
    sala: TSalaDeJuego;
    campos_lst: TList;

    constructor Create_conSalaYEditor_(AOwner: TComponent;
      xsala: TSalaDeJuego); virtual;

    procedure setParent(newParent: TWinControl);

    function getGuardado: boolean;
    procedure setGuardado(x: boolean);
    property guardado: boolean read getGuardado write setGuardado;

    procedure AddLnk_Edit(xComponente: TComponent; xCampoLnk: TCosa_CampoLnk);

    // Carga los valores visibles de los componentes a partir de la lista de campos
    procedure LoadData;

    // Guarda los valores del Formulario en la lista de campos.
    procedure SaveData;
  end;

  { TObserverCambioDatosEnHijoDeBaseFormulario }
  //Esta clase sirve para hacer un observer de los cambios de un formulario
  //creado por este (por ejemplo un editor de un actor en el editor principal)
  //de modo que si se hacen cambios en el hijo el padre ponga su guardado a false
  TObserverCambioDatosEnHijoDeBaseFormularios = class(TObserverCambioDatos)
  public
    baseFormulario: TBaseFormularios;
    constructor Create(baseFormulario: TBaseFormularios);
    procedure notificarGuardarDatos; override;
    procedure notificarCancelar; override;
  end;

implementation

  {$R *.lfm}

{ TComboCosa_BaseFormulario }

constructor TComboCosa_BaseFormulario.Create(xComponente: TComboBox;
  xCampoLnk: TCosa_CampoLnk; xEvaluador: TEvaluadorConCatalogo;
  xListaopciones: TStrings);
begin
  inherited Create(xComponente, xCampoLnk, xEvaluador);
  opcionesLst := xListaOpciones;

end;

procedure TComboCosa_BaseFormulario.LoadToFormulario;
begin

end;

procedure TComboCosa_BaseFormulario.SaveFromFormulario;
begin

end;

function TComboCosa_BaseFormulario.haycambios: boolean;
begin

end;

function TComboCosa_BaseFormulario.test: string;
begin

end;


{ TEdit_BaseFormulario }

constructor TEdit_BaseFormulario.Create(xComponente: TComponent;
  xCampoLnk: TCosa_CampoLnk; xEvaluador: TEvaluadorConCatalogo);
begin
  inherited Create;
  componente := xComponente;
  campoLnk := xCampoLnk;
  evaluador := xEvaluador;
end;

procedure TEdit_BaseFormulario.LoadToFormulario;
var
  a: TEdit;
begin
  a := componente as TEdit;
  a.Text := campoLnk.GetStrVal;
end;

procedure TEdit_BaseFormulario.SaveFromFormulario;
var
  a: TEdit;

begin
  a := componente as TEdit;
  campoLnk.SetStrVal(a.Text, Evaluador);
end;

function TEdit_BaseFormulario.haycambios: boolean;
var
  a: TEdit;
  s: string;
begin
  a := componente as TEdit;
  s := campoLnk.GetStrVal;
  Result := s <> a.Text;
end;

function TEdit_BaseFormulario.test: string;
var
  res: boolean;
begin
  if campoLnk.Parent_RecLnk <> nil then
    res := campoLnk.Evaluar(campoLnk.Parent_RecLnk.aCosa, Evaluador, False)
  else
    res := campoLnk.Evaluar(nil, evaluador, False);

  if res then
    Result := ''
  else
    Result := 'error';
end;



{ TObserverCambioDatosEnHijoDeBaseFormulario }

constructor TObserverCambioDatosEnHijoDeBaseFormularios.Create(
  baseFormulario: TBaseFormularios);
begin
  inherited Create;
  Self.baseFormulario := baseFormulario;
end;

procedure TObserverCambioDatosEnHijoDeBaseFormularios.notificarGuardarDatos;
begin
  baseFormulario.guardado := False;
end;

procedure TObserverCambioDatosEnHijoDeBaseFormularios.notificarCancelar;
begin
  //Nada
end;

constructor TBaseFormularios.Create_conSalaYEditor_(AOwner: TComponent;
  xsala: TSalaDeJuego);
begin
  inherited Create(AOwner);

  campos_lst := TList.Create;

  self.sala := xsala;
  if xsala <> nil then
    rbtEditorSala := TRbtEditorSala(sala.rbtEditor)
  else
    rbtEditorSala := nil;

  calcularTamaniosTablas;
  if Aowner is TForm then
  begin
    self.Top := max(TForm(Aowner).Top, 0) + plusTop;
    self.Left := max(TForm(Aowner).Left, 0) + plusLeft;
  end
  else
  begin
    Self.Top := plusTop;
    self.Left := plusLeft;
  end;

  guardado := True;
  loQueHabia := #0;
  validarSg := False;
  utilidades.setTabOrderByTopAndLeft(self);

end;



function TBaseFormularios.getGuardado: boolean;
begin
  Result := not Modificado;
end;

procedure TBaseFormularios.setGuardado(x: boolean);
begin
  Modificado := not x;
end;

procedure TBaseFormularios.AddLnk_Edit(xComponente: TComponent;
  xCampoLnk: TCosa_CampoLnk);
var
  aCampo: TEdit_BaseFormulario;
begin
  if sala <> nil then
    aCampo := TEdit_BaseFormulario.Create(xComponente, xCampoLnk, sala.evaluador)
  else
    aCampo := TEdit_BaseFormulario.Create(xComponente, xCampoLnk, nil);

  campos_lst.add(aCampo);
end;

procedure TBaseFormularios.LoadData;
var
  aC: TEdit_BaseFormulario;
  k: integer;
begin
  for k := 0 to campos_lst.Count - 1 do
  begin
    aC := campos_lst[k];
    aC.LoadToFormulario;
  end;
end;

procedure TBaseFormularios.SaveData;
var
  aC: TEdit_BaseFormulario;
  k: integer;
begin
  for k := 0 to campos_lst.Count - 1 do
  begin
    aC := campos_lst[k];
    aC.SaveFromFormulario;
  end;
end;

procedure TBaseFormularios.setParent(newParent: TWinControl);
begin
  self.parent := newParent;
  calcularTamaniosTablas;
end;

function TBaseFormularios.validarEditInt(Sender: TCustomEdit; min: integer;
  max: integer): boolean;
var
  valor: integer;
begin
  if (Sender.Text <> loQueHabia) then
  begin
    try
      begin
        valor := StrToInt(Sender.Text);
        if (valor < min) or (valor > max) then
          raise EConvertError.Create(exFueraDeRango);
        guardado := False;
        Result := True;
      end
    except
      on EConvertError do
      begin
        ShowMessage(mesValorIntroducidoDebeNumYEntre + IntToStr(min) +
          mesY + IntToStr(max));
        Sender.Text := loQueHabia;
        Sender.SetFocus;
        Result := False;
      end
    end;
  end
  else
    Result := True;
end;



function TBaseFormularios.validarEditFloat(Sender: TCustomEdit;
  min, max: NReal): boolean;
var
  valor: NReal;
begin
  if Sender.Text <> loQueHabia then
  begin
    try
      begin
        valor := StrToFloat(Sender.Text);
        if (valor < min) or (valor > max) then
          raise EConvertError.Create(exFueraDeRango);
        guardado := False;
        Result := True;
      end
    except
      on EConvertError do
      begin
        ShowMessage(mesValorIntroducidoDebeRealYEntre + FloatToStr(min) +
          mesY + FloatToStr(max));
        Sender.Text := loQueHabia;
        Sender.SetFocus;
        Result := False;
      end
    end;
  end
  else
    Result := True;
end;



function TBaseFormularios.validarEditInt(Sender: TCustomEdit): boolean;
var
  valor: integer;
begin
  try
    begin
      valor := StrToInt(Sender.Text);
      if Sender.Text <> loQueHabia then
        guardado := False;
      Result := True;
    end
  except
    ShowMessage(mesErrorAlConvertir + ', (' + Sender.Text + '). ' + mesSeEsperaUnEntero);
    Sender.SetFocus;
    Result := False;
  end;
end;

function TBaseFormularios.validarEditFloat(Sender: TCustomEdit): boolean;
var
  valor: NReal;
begin
  try
    begin
      valor := StrToFloat(Sender.Text);
      if Sender.Text <> loQueHabia then
        guardado := False;
      Result := True;
    end
  except
    ShowMessage(mesErrorAlConvertir + ', (' + Sender.Text + '). ' + mesSeEsperaUnReal);
    Sender.SetFocus;
    Result := False;
  end;
end;



function TBaseFormularios.validarEditDAOfNReal(Sender: TCustomEdit;
  min, max: NReal; sep: char): boolean;
var
  k: integer;
  v: TDAOfNReal;
  fueraDeRango: integer;
begin
  if Sender.Text <> loQueHabia then
  begin
    try
      begin
        v := StrToDAOfNReal_(Sender.Text, sep);
        fueraDeRango := 0;
        for k := 0 to high(v) do
          if (v[k] < min) or (v[k] > max) then
            Inc(fueraDeRango);

        setlength(v, 0);
        if fueraDeRango > 0 then
          raise EConvertError.Create(exFueraDeRango);
        guardado := False;
        Result := True;
      end
    except
      on EConvertError do
      begin
        ShowMessage(mesValorIntroducidoDebeRealYEntre + FloatToStr(min) +
          mesY + FloatToStr(max));
        Sender.Text := loQueHabia;
        Sender.SetFocus;
        Result := False;
      end
    end;
  end
  else
    Result := True;
end;


function TBaseFormularios.validarEditFecha(Sender: TCustomEdit): boolean;
begin
  if (Sender.Text <> loQueHabia) and (Sender.Text <> 'Auto') and
    (Sender.Text <> '0') then
  begin
    try
      begin
        StrToDateTime(Sender.Text);
        guardado := False;
        Result := True;
      end
    except
      on EConvertError do
      begin
        ShowMessage(mesFechaIngresadaNoValida);
        Sender.Text := loQueHabia;
        Sender.SetFocus;
        Result := False;
      end
    end;
  end
  else
    Result := True;
end;

{$IFDEF FPC-LCL}
function TBaseFormularios.validarTDateTimeEdit(Sender: TDateEdit): boolean;
begin
  if (Sender.Text <> loQueHabia) and (Sender.Text <> '0') then
  begin
    try
      begin
        StrToDateTime(Sender.Text);
        guardado := False;
        Result := True;
      end
    except
      on EConvertError do
      begin
        ShowMessage(mesFechaIngresadaNoValida);
        Sender.Text := loQueHabia;
        Sender.SetFocus;
        Result := False;
      end
    end;
  end
  else
    Result := True;
end;

{$ENDIF}

function TBaseFormularios.validarEditNarch(Sender: TCustomEdit): boolean;
begin
  if (Sender.Text = '') then
  begin
    ShowMessage(mesNombreArchivoNoValido);
    Sender.Text := loQueHabia;
    Result := False;
  end
  else if not FileExists(Sender.Text) { *Converted from FileExists*  } then
  begin
    ShowMessage(mesElArchivo + Sender.Text + mesNoExiste);
    Sender.Text := loQueHabia;
    Result := False;
  end
  else
  begin
    Result := True;
    if (Sender.Text <> loQueHabia) then
      guardado := False;
  end;
end;

function TBaseFormularios.validarEditString(Sender: TCustomEdit;
  etiqueta: string): boolean;
begin
  if Sender.Text = '' then
  begin
    ShowMessage(mesDebeIngresarValorCampo + etiqueta);
    Sender.SetFocus;
    Result := False;
  end
  else
    Result := True;
end;

function TBaseFormularios.validarMemo(Sender: TMemo; etiqueta: string): boolean;
begin
  if Sender.Lines.Text = '' then
  begin
    ShowMessage(mesDebeIngresarValorCampo + etiqueta);
    Sender.SetFocus;
    Result := False;
  end
  else
    Result := True;
end;

procedure TBaseFormularios.cbEditFloatCondicionalClick(cbCondicion: TCheckBox;
  etiqueta: TLabel; edit: TCustomEdit; condEsCBTickeado: boolean);
begin
  if cbCondicion.Enabled then
  begin
    if condEsCBTickeado then
    begin
      if etiqueta <> nil then
        etiqueta.Enabled := cbCondicion.Checked;
      edit.Enabled := cbCondicion.Checked;
    end
    else
    begin
      if etiqueta <> nil then
        etiqueta.Enabled := not cbCondicion.Checked;
      edit.Enabled := not cbCondicion.Checked;
    end;
    guardado := False;
  end
  else
  begin
    etiqueta.Enabled := False;
    edit.Enabled := False;
  end;
end;

function TBaseFormularios.validarEditFloatCondicional(cbCondicion: TCheckBox;
  edit: TCustomEdit; min, max: NReal; condEsCBTickeado: boolean): boolean;
begin
  if condEsCBTickeado then
  begin
    if cbCondicion.Checked then
      Result := validarEditFloat(edit, min, max)
    else
      Result := True;
  end
  else if cbCondicion.Checked then
    Result := True
  else
    Result := validarEditFloat(edit, min, max);
end;

procedure TBaseFormularios.valoresEditFloatCondicional(cbCondicion: TCheckBox;
  edit: TCustomEdit; condEsCBTickeado: boolean; var condicion: boolean;
  var valor: NReal);
begin
  condicion := cbCondicion.Checked;
  if condEsCBTickeado then
  begin
    if cbCondicion.Checked and cbCondicion.Enabled then
      valor := StrToFloat(edit.Text)
    else
      try
        valor := StrToFloat(edit.Text)
      except
        valor := 0
      end;
  end
  else if cbCondicion.Checked or not cbCondicion.Enabled then
    try
      valor := StrToFloat(edit.Text)
    except
      valor := 0
    end
  else
    valor := StrToFloat(edit.Text);
end;

function TBaseFormularios.validarFormulario: boolean;
begin
  loQueHabia := #0;
  Result := True;
end;

function TBaseFormularios.validarCeldaFecha(tabla: TStringGrid;
  fila, columna: integer): boolean;
var
  valCelda: string;
  fecha: TDateTime;
begin
  valCelda := tabla.Cells[columna, fila];
  if (valCelda <> loQueHabia) and (valCelda <> 'Auto') and (valCelda <> '0') then
  begin
    Result := TryStrToDateTime(valCelda, fecha);
  end
  else
    Result := True;
end;

function TBaseFormularios.validarCeldaNInt(tabla: TStringGrid;
  fila, columna: integer): boolean;
var
  i: integer;
begin
  Result := TryStrToInt(tabla.Cells[columna, fila], i);
end;

function TBaseFormularios.validarCeldaNReal(tabla: TStringGrid;
  fila, columna: integer): boolean;
begin
  try
    StrToFloat(tabla.Cells[columna, fila]);
    Result := True;
  except
    //    ShowMessage(mesValorEnTablaDebeSerReal);
    Result := False;
  end;
end;

function TBaseFormularios.validarTablaNReals_(tabla: TStringGrid): boolean;
var
  iFila, iColumna: integer;
begin
  iFila := -1;
  iColumna := -1;

  try
    begin
      iFila := tabla.FixedRows;
      while iFila < tabla.RowCount do
      begin
        iColumna := tabla.FixedCols;
        while iColumna < tabla.ColCount do
        begin
          StrToFloat(tabla.Cells[iColumna, iFila]);
          iColumna := iColumna + 1;
        end;
        iFila := iFila + 1;
      end;
      {    for iFila:= tabla.FixedRows to tabla.RowCount -1 do
        for iColumna:= tabla.FixedCols to tabla.ColCount - 1 do
        StrToFloat(tabla.cells[iColumna, iFila]);}
      Result := True;
    end
  except
    on EConvertError do
    begin
      if (iFila >= tabla.FixedRows) and (iFila < tabla.RowCount) then
        tabla.Row := iFila;
      if (iColumna >= tabla.FixedCols) and (iColumna < tabla.ColCount) then
        tabla.Col := iColumna;
      tabla.SetFocus;
      ShowMessage(mesValoresEnTablaNumericos);
      Result := False;
    end
  end;
end;

function TBaseFormularios.filaTablaNReals(tabla: TStringGrid;
  iFila: integer): TDAofNReal;
var
  res: TDAofNReal;
  i: integer;
begin
  SetLength(res, tabla.ColCount - tabla.FixedCols);
  for i := tabla.FixedCols to tabla.ColCount - 1 do
    res[i - tabla.FixedCols] := StrToFloat(tabla.Cells[i, iFila]);
  Result := res;
end;

function TBaseFormularios.columnaTablaNReals(tabla: TStringGrid;
  iColumna: integer): TDAofNReal;
var
  res: TDAofNReal;
  i: integer;
begin
  SetLength(res, tabla.RowCount - tabla.FixedRows);
  for i := tabla.FixedRows to tabla.RowCount - 1 do
    res[i - tabla.FixedRows] := StrToFloat(tabla.Cells[iColumna, i]);
  Result := res;
end;

procedure TBaseFormularios.validarCambioTablaNReals(tabla: TStringGrid);
begin
  if (tabla.Cells[colValidarSG, filaValidarSG] <> loQueHabia) and
    (filaValidarSG >= tabla.FixedRows) and (colValidarSG >= tabla.FixedCols) then
  begin
    try
      StrToFloat(tabla.Cells[colValidarSG, filaValidarSG]);
      guardado := False;
    except
      on EConvertError do
      begin
        tabla.Cells[colValidarSG, filaValidarSG] := loQueHabia;
        ShowMessage(mesValorIntroducidoDebeNum);
      end;
    end;
  end;
  validarSg := True;
end;

procedure TBaseFormularios.cambiarTopControles(desde, desplazamiento: integer);
var
  i: integer;
begin
  for i := 0 to ControlCount - 1 do
  begin
    if Controls[i].Top > desde then
      Controls[i].Top := Controls[i].Top + desplazamiento;
  end;
end;

function TBaseFormularios.hayQueGuardar(mensaje: string): integer;
var
  mbResult: integer;
  mensajeAsPChar: PChar;
begin
  if not guardado then
  begin
    GetMem(mensajeAsPChar, length(mensaje) + 1);
    StrPCopy(mensajeAsPChar, mensaje);
    mbResult := Application.MessageBox(mensajeAsPChar, PChar(mesSimSEEEdit),
      MB_YESNOCANCEL or MB_ICONEXCLAMATION);
    FreeMem(mensajeAsPChar, length(mensaje) + 1);
  end
  else
    mbResult := idNo;
  Result := mbResult;
end;

procedure TBaseFormularios.setCBString(cb: TComboBox; valor: string);
begin
  cb.ItemIndex := cb.Items.IndexOf(valor);
end;

function TBaseFormularios.valorCBString(cb: TComboBox): string;
begin
  if cb.Enabled and (cb.ItemIndex <> -1) then
    Result := cb.Items[cb.ItemIndex]
  else
    Result := '';
end;


procedure TBaseFormularios.inicializarSGString(sg: TStringGrid;
  encabezados: array of string; var tiposCols: TDAOfTTipoColumna;
  eString: TCustomEdit; etiqueta: TLabel; bAgregar: TButton);
begin
  sg.Options := sg.Options + [goRowSelect];
  initListado(sg, encabezados, tiposCols, True);
end;


procedure TBaseFormularios.setSGString(sg: TStringGrid; strings: TDAofString);
var
  i: integer;
begin
  sg.RowCount := length(strings) + 1;
  if sg.RowCount > 1 then
    sg.FixedRows := 1;
  for i := 0 to high(strings) do
    sg.Cells[0, i + 1] := strings[i];
end;

function TBaseFormularios.valorSGString(sg: TStringGrid): TDAofString;
var
  i: integer;
  res: TDAofString;
begin
  SetLength(res, sg.RowCount - 1);
  for i := 0 to High(res) do
    res[i] := sg.Cells[0, i + 1];
  Result := res;
end;

procedure TBaseFormularios.addSGString(sg: TStringGrid; eString: TCustomEdit;
  etiqueta: string; deshabilitarScrollHorizontal: boolean);
begin
  if validarEditString(eString, etiqueta) then
  begin
    sg.RowCount := sg.RowCount + 1;
    if sg.RowCount > 1 then
      sg.FixedRows := 1;
    sg.Cells[0, sg.RowCount - 1] := eString.Text;

    utilidades.AutoSizeCol(sg, 0);
    sg.Row := sg.RowCount - 1;
    guardado := False;
  end;
end;

procedure TBaseFormularios.eStringKeyDown(sg: TStringGrid; eString: TCustomEdit;
  etiqueta: string; deshabilitarScrollHorizontal: boolean; var Key: word;
  Shift: TShiftState);
begin
  if Key in [VK_Return] then
    addSGString(sg, eString, etiqueta, deshabilitarScrollHorizontal);
end;

procedure TBaseFormularios.eliminarSGString(sg: TStringGrid; fila: integer;
  eString: TCustomEdit; deshabilitarScrollHorizontal: boolean);
var
  i: integer;
begin
  for i := fila to sg.RowCount - 2 do
    sg.Cells[0, i] := sg.Cells[0, i + 1];
  sg.RowCount := sg.RowCount - 1;

  utilidades.AutoSizeCol(sg, 0);
  guardado := False;
end;

procedure TBaseFormularios.setSGVectorDeReales(sg: TStringGrid;
  eTamanio: TCustomEdit; reales: TDAofNReal);
var
  i: integer;
begin
  if eTamanio <> nil then
    eTamanio.Text := IntToStr(length(reales));
  if length(reales) + sg.FixedCols = 0 then
    sg.Visible := False
  else
    sg.ColCount := length(reales) + sg.FixedCols;

  for i := 0 to high(reales) do
    sg.Cells[i + sg.FixedCols, sg.FixedRows] :=
      FloatToStrF(reales[i], ffGeneral, 16, 10);
  //utilidades.AutoSizeColsToMaxCol(sg);
end;

function TBaseFormularios.valorSGVectorDeReales(sg: TStringGrid): TDAofNReal;
var
  res: TDAofNReal;
  i: integer;
begin
  if sg.Visible = False then
    res := nil
  else
  begin
    SetLength(res, sg.ColCount - sg.FixedCols);
    for i := 0 to high(res) do
      res[i] := StrToFloat(sg.Cells[i + sg.FixedCols, sg.FixedRows]);
  end;

  Result := res;
end;

procedure TBaseFormularios.cambioTamanioSGVectorDeReales(sg: TStringGrid;
  eTamanio: TCustomEdit; minTamanio, maxTamanio: integer;
  deshabilitarScrollHorizontal: boolean);
var
  i: integer;
begin
  if validarEditInt(eTamanio, minTamanio, maxTamanio) then
  begin
    if StrToInt(eTamanio.Text) + sg.FixedCols = 0 then
      sg.Visible := False
    else
    begin
      sg.Visible := True;
      sg.ColCount := StrToInt(eTamanio.Text) + sg.FixedCols;
      //utilidades.AutoSizeColsToMaxCol(sg);
      for i := 0 to sg.ColCount - 1 do
        sg.ColWidths[i] := sg.DefaultColWidth;
    end;
  end;
end;

procedure TBaseFormularios.eTamSGVectorDeRealesChange(sg: TStringGrid;
  eTamanio: TCustomEdit; minTamanio, maxTamanio: integer;
  deshabilitarScrollHorizontal: boolean);
var
  loQueHabiaAsInt, newTamanio: integer;
begin
  if not TryStrToInt(loQueHabia, loQueHabiaAsInt) then
    loQueHabiaAsInt := 0;
  try
    newTamanio := StrToInt(eTamanio.Text);
    if newTamanio > loQueHabiaAsInt then
    begin
      cambioTamanioSGVectorDeReales(sg, eTamanio, minTamanio, maxTamanio,
        deshabilitarScrollHorizontal);
      loQueHabia := eTamanio.Text;
    end;
  except
    cambioTamanioSGVectorDeReales(sg, eTamanio, minTamanio, maxTamanio,
      deshabilitarScrollHorizontal);
  end;
end;

function TBaseFormularios.validarSGVectorDeReales(sg: TStringGrid): boolean;
var
  res: boolean;
  i: integer;
begin
  res := True;
  if sg.Visible then
  begin
    try
      for i := sg.FixedCols to sg.ColCount - 1 do
        StrToFloat(sg.Cells[i, sg.FixedRows]);
    except
      on EConvertError do
        res := False;
    end;
  end;
  Result := res;
end;

function TBaseFormularios.validarSGVectorDeRealesMinMax(sg: TStringGrid;
  min, max: NReal): boolean;
var
  res: boolean;
  i: integer;
  val: NReal;
begin
  res := True;
  if sg.Visible then
  begin
    try
      for i := sg.FixedCols to sg.ColCount - 1 do
      begin
        val := StrToFloat(sg.Cells[i, sg.FixedRows]);
        if (val < min) or (val > max) then
        begin
          ShowMessage(mesValorTablaDebeNumYEntre + FloatToStrF(min,
            ffFixed, 10, 2) + mesY + FloatToStrF(max, ffFixed, 10, 2));
          res := False;
          break;
        end;
      end;
    except
      on EConvertError do
      begin
        ShowMessage(mesValorTablaDebeNumYEntre + FloatToStrF(min,
          ffFixed, 10, 2) + mesY + FloatToStrF(max, ffFixed, 10, 2));
        res := False;
      end;
    end;
  end;
  Result := res;
end;

function TBaseFormularios.validarSGVectorDeRealesOrdenado(sg: TStringGrid;
  creciente: boolean): boolean;
var
  res: boolean;
  i: integer;
  val, lastVal: NReal;
begin
  res := True;

  if sg.Visible then
  begin
    if creciente then
      lastVal := -MaxNReal
    else
      lastVal := MaxNReal;

    try
      for i := sg.FixedCols to sg.ColCount - 1 do
      begin
        val := StrToFloat(sg.Cells[i, sg.FixedRows]);
        if creciente and (val < lastVal) then
        begin
          ShowMessage(mesValoresEnTablaOrdenadosCreciente);
          res := False;
          break;
        end
        else if not creciente and (val > lastVal) then
        begin
          ShowMessage(mesValoresEnTablaOrdenadosDecreciente);
          res := False;
          break;
        end;
        lastVal := val;
      end;
    except
      on EConvertError do
      begin
        ShowMessage(mesValoresEnTablaDebenSerNumericos);
        res := False;
      end;
    end;
  end;
  Result := res;
end;

procedure TBaseFormularios.FormResize(Sender: TObject);
begin
  // Solo para que no falle en los formularios que lo linkean
end;

procedure TBaseFormularios.FormClose(Sender: TObject; var CloseAction: TCloseAction);
var
  k: integer;
  aCampo: TEdit_BaseFormulario;
begin
  if campos_lst <> nil then
  begin
    for k := 0 to campos_lst.Count - 1 do
    begin
      aCampo := campos_lst[k];
      aCampo.Free;
    end;
    campos_lst.Free;
  end;
end;

procedure TBaseFormularios.CBEnter(Sender: TObject);
begin
  loQueHabia := TComboBox(Sender).Text;
end;

procedure TBaseFormularios.EditEnter(Sender: TObject);
begin
  loQueHabia := TCustomEdit(Sender).Text;
end;

procedure TBaseFormularios.EditExit(Sender: TObject);
begin
  if loQueHabia <> TCustomEdit(Sender).Text then
    guardado := False;
end;

procedure TBaseFormularios.EditNArchExit(Sender: TObject);
begin
  validarEditNarch(TCustomEdit(Sender));
end;

procedure TBaseFormularios.EditAnioExit(Sender: TObject);
begin
  validarEditInt(TCustomEdit(Sender), 1899, MAXINT);
end;

procedure TBaseFormularios.EditSemanaExit(Sender: TObject);
begin
  validarEditInt(TCustomEdit(Sender), 1, 52);
end;

procedure TBaseFormularios.EditFechaExit(Sender: TObject);
begin
  validarEditFecha(TCustomEdit(Sender));
end;

procedure TBaseFormularios.EditIntExit(Sender: TObject; min, max: integer);
begin
  validarEditInt(Sender as TCustomEdit, min, max);
end;

procedure TBaseFormularios.EditFloatExit(Sender: TObject; min, max: NReal);
begin
  validarEditFloat(Sender as TCustomEdit, min, max);
end;

procedure TBaseFormularios.EditStringExit(Sender: TObject; trimText: boolean);
begin
  if TCustomEdit(Sender).Text <> loQueHabia then
  begin
    if trimText then
      TCustomEdit(Sender).Text := Trim(TCustomEdit(Sender).Text);
    guardado := False;
  end;
end;


procedure TBaseFormularios.DTPChange(Sender: TObject);
begin
  guardado := False;
end;

procedure TBaseFormularios.CBChange(Sender: TObject);
begin
  guardado := False;
end;

procedure TBaseFormularios.BCancelarClick(Sender: TObject);
begin
  self.Close;
end;

procedure TBaseFormularios.cambiosForm(Sender: TObject);
begin
  guardado := False;
end;

procedure TBaseFormularios.sgValidarCambio(Sender: TObject);
begin
  validarCambioTabla(TStringGrid(Sender));
end;

procedure TBaseFormularios.sgGetEditText(Sender: TObject; ACol, ARow: integer;
  var Value: string);
begin
  //  validarSg:= (loQueHabia <> TStringGrid(Sender).Cells[ACol, ARow]);
  loQueHabia := TStringGrid(Sender).Cells[ACol, ARow];
  filaValidarSG := ARow;
  colValidarSG := ACol;
end;

procedure TBaseFormularios.sgKeyDown(Sender: TObject; var Key: word;
  Shift: TShiftState);
var
  senderAsGrid: TStringGrid;
begin
  senderAsGrid := Sender as TStringGrid;
  validarSg := senderAsGrid.Cells[senderAsGrid.Col, senderAsGrid.Row] <> loQueHabia;
  if (Key in teclas) then
    validarCambioTabla(TStringGrid(Sender));
end;

procedure TBaseFormularios.sgMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  TStringGrid(Sender).MouseToCell(X, Y, colValidarSG, filaValidarSG);
end;

procedure TBaseFormularios.sgChequearCambios(Sender: TObject);
begin
  if TStringGrid(Sender).Cells[colValidarSG, filaValidarSG] <> loQueHabia then
    guardado := False;
end;

procedure TBaseFormularios.sgChequearCambiosKeyDown(Sender: TObject;
  var Key: word; Shift: TShiftState);
begin
  if Key in teclas then
    sgChequearCambios(Sender);
end;

procedure TBaseFormularios.sgDrawCell(Sender: TObject; Col, Row: integer;
  Rect: TRect; State: TGridDrawState);
var
  Texto: string;
  Indice: integer;
  Posicion: integer;
begin
  if Pos(#13, TStringGrid(Sender).Cells[Col, Row]) <> 0 then
  begin
    Texto := TStringGrid(Sender).Cells[Col, Row] + #13;
    TStringGrid(Sender).Canvas.FillRect(Rect);
    Indice := 0;
    repeat
      Posicion := Pos(#13, Texto);
      with TStringGrid(Sender).Canvas do
        TextOut(Rect.Left + 2, Rect.Top +
          (Indice * TextHeight(Copy(Texto, 1, Posicion - 1))) + 2,
          Copy(Texto, 1, Posicion - 1));
      Inc(Indice);
      Delete(Texto, 1, Posicion);
    until Posicion = 0;
    TStringGrid(Sender).RowHeights[Row] :=
      (Indice - 1) * TStringGrid(Sender).Canvas.TextHeight(
      TStringGrid(Sender).Cells[Col, Row]) + utilidades.plusHeight + 1;
  end;
end;

procedure TBaseFormularios.FormCloseQuery(Sender: TObject; var CanClose: boolean);
var
  mbResult: integer;
  i: integer;
begin
  //Pongo el foco en un botón para que salga del control actual
  (* ESTO DA ERROR.
    1) Abrí una sala
    2) Activá le TAB "Simular"
    3) Archivo->Abrir y abrí otra sala
    y da un error por intentar hacer foco sobre algo invisible.
   *)
  if self.Visible then
    for i := 0 to ControlCount - 1 do
      if Controls[i] is TButton and Controls[i].Enabled and Controls[i].Visible then
      begin
        TButton(Controls[i]).SetFocus;
        break;
      end;

  if ModalResult <> mrOk then
  begin
    if (not guardado) then
    begin
      mbResult := Application.MessageBox(PChar(mesNoGuardadoCambiosGuardarAhora),
        PChar(mesConfirmarSalida), MB_YESNOCANCEL or MB_ICONEXCLAMATION);

      if mbResult = idYes then
      begin
        BGuardarClick(Sender);
        CanClose := (ModalResult = mrOk) or guardado;
      end
      else if mbResult = idNo then
      begin
        CanClose := True;
        ModalResult := mrAbort;
      end
      else
        CanClose := False;
    end
    else
    begin
      ModalResult := mrAbort;
      CanClose := True;
    end;
  end;
end;


procedure TBaseFormularios.calcularTamaniosTablas;
const
  //defaultRowHeights = 24;
  defaultColWidths = 64;
  defaultLineWidth = 1;
  nLineasBordes = 4;
  nPxLineasBordes = nLineasBordes * defaultLineWidth;

  //  auxHeight = defaultRowHeights + defaultLineWidth;
  auxWidth = defaultColWidths + defaultLineWidth;
{$IFDEF FPC-LCL}
var
  R: TRect;
{$ENDIF}
  anchoDisponible, altoDisponible: integer;
begin
  if self.Parent = nil then
  begin
    maxAnchoTablaChica := CP_maxAlturaTablaChica;
    maxAnchoTablaMediana := CP_maxAnchoTablaMediana;
    maxAnchoTablaGrande := CP_maxAnchoTablaGrande;
    maxAnchoTablaMuyGrande := CP_maxAnchoTablaMuyGrande;
    maxAnchoTablaEnorme := CP_maxAnchoTablaEnorme;

    maxAlturaTablaChica := CP_maxAlturaTablaChica;
    maxAlturaTablaMediana := CP_maxAlturaTablaMediana;
    maxAlturaTablaGrande := CP_maxAlturaTablaGrande;
    maxAlturaTablaMuyGrande := CP_maxAlturaTablaMuyGrande;
    maxAlturaTablaEnorme := CP_maxAlturaTablaEnorme;
  end
  else
  begin
    //El alto de las filas de una tabla es 24 por defecto, por cada fila hay un
    //pixel mas de la linea separadora y uno mas al final por una linea extra
    //buscamos el primer multiplo de 25 + 1 para cada tamanio
    maxAnchoTablaChica := ((round(anchoDisponible * 0.15) div auxWidth) + 1) *
      auxWidth + nPxLineasBordes;
    maxAnchoTablaMediana := ((round(anchoDisponible * 0.4) div auxWidth) + 1) *
      auxWidth + nPxLineasBordes;
    maxAnchoTablaGrande := ((round(anchoDisponible * 0.6) div auxWidth) + 1) *
      auxWidth + nPxLineasBordes;
    maxAnchoTablaMuyGrande := ((round(anchoDisponible * 0.75) div auxWidth) + 1) *
      auxWidth + nPxLineasBordes;
    maxAnchoTablaEnorme := ((round(anchoDisponible * 0.95) div auxWidth) + 1) *
      auxWidth + nPxLineasBordes;

    maxAlturaTablaChica := ((round(altoDisponible * 0.15) div auxWidth) + 1) *
      auxWidth + nPxLineasBordes;
    maxAlturaTablaMediana := ((round(altoDisponible * 0.4) div auxWidth) + 1) *
      auxWidth + nPxLineasBordes;
    maxAlturaTablaGrande := ((round(altoDisponible * 0.55) div auxWidth) + 1) *
      auxWidth + nPxLineasBordes;
    maxAlturaTablaMuyGrande :=
      ((round(altoDisponible * 0.75) div auxWidth) + 1) * auxWidth + nPxLineasBordes;
    maxAlturaTablaEnorme := ((round(altoDisponible * 0.95) div auxWidth) + 1) *
      auxWidth + nPxLineasBordes;
  end;
end;

initialization

end.
