unit uBaseAltasEditores;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
  {$IFDEF WINDOWS}
  Windows,
  {$ENDIF}
  Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  xMatDefs, StdCtrls, uBaseFormularios, uBaseEditores, Grids, utilidades,
  usalasdejuego,
  usalasdejuegoParaEditor,
  uCosa,
  uActores,
  uNodos,
  uGlobs,
  uFuentesAleatorias, ExtCtrls,
  ImgList, uConstantesSimSEE, ufichasLPD, uFechas;

resourcestring
  mesProfundidadDeEscalonesEnInterv =
    'Las profundidades de los escalones deben estar en el intervalo (0, 1]';
  mesSumaDeProfundidadDeEscalones =
    'La suma de las profundidades de los escalones debe ser 1';
  mesValoresEnTablaNumericos =
    'Los valores introducidos en la tabla deben ser numéricos';
  mesSeleccionarNodoDeLista = 'Debe seleccionar un nodo de la lista';
  mesNoSeEncuentraNodoSel = 'No se encuentra el nodo seleccionado';
  mesNoSeEncuentraFuenteSel = 'No se encuentra la fuente seleccionado';
  mesSeleccionarBorneLista = 'Debe seleccionar un borne de la lista';
  mesDebeSeleccionarFuenteDeLista = 'Debe seleccionar una fuente de la lista';
  mesFuenteAleatConPaso1h =
    'TParqueEolico, necesita una fuente aleatoria con paso de sorteo = 1h. ';
  mesUstedLoConectoAFuente = 'Usted lo conectó a la fuente ';
  mesConPasoDeSorteo = ' con paso de sorteo = ';
  mesAgregarFichaCFechaAnterior =
    'Debe agregar al menos una ficha con fecha ' +
    'anterior a las fechas de inicio de simulación y optimización (fecha <= ';

const
  nombre_RG_ValorFuncional_Ninguno = 'Ninguno';
  nombre_RG_ValorFuncional_Constante = 'Fijo';
  nombre_RG_ValorFuncional_Fuente = 'Tomado de una fuente';
  nombre_RG_ValorFuncional_Otro = 'Otro';

  strNodoNinguno = 'Ninguno';
  strSeleccionarNodo = '<Seleccione un Nodo>';
  strAgregarNuevoNodo = '<Agregar nuevo...>';
  strSeleccionarFuente = '<Seleccione una Fuente>';
  strSeleccionarBorne = '<Seleccione un Borne>';

type
  TClaseAltasEditores = class of TBaseAltasEditores;

  TBaseAltasEditores = class(TBaseEditores)
  published
    procedure sgFallaValidarCambio(Sender: TObject);
    procedure sgFallaKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
  protected
    SaladeJuego: TSaladeJuego;  {La sala de juegos}

    //    constructor Create(AOwner: TComponent);

    procedure inicializarCBNodos(cb: TComboBox; permiteNinguno: boolean);
    procedure setCBNodo(cb: TComboBox; valor: TNodo);
    function valorCBNodo(cb: TComboBox): TNodo;
    function validarCBNodo(cb: TComboBox): boolean;
    //cambiosForm = true <-> se debe poner guardado = false al cambiar el cb
    procedure cbNodoChange(Sender: TObject; cambiosForm: boolean);
    procedure inicializarCBNodosLinkeados(cb, cbLinkeado: TComboBox;
      permiteNinguno: boolean);
    procedure setCBNodoLinkeado(cb, cbLinkeado: TComboBox;
      valor, valorLinkeado: TNodo);
    procedure cbNodoLinkeadoChange(Sender: TObject; cbLinkeado: TComboBox);

    procedure inicializarCBNodo(CBNodo: TComboBox; nodoSeleccionado: TNodo);
    procedure inicializarCBFuente(CBFuente: TComboBox;
      fuenteSeleccionada: TFuenteAleatoria;
      var fuenteFormulario: TFuenteAleatoria;
      CBBorne: TComboBox; nombreBorne: string;
      aceptaNinguna: boolean);

    procedure inicializarCBFuenteEolico(CBFuente: TComboBox;
      fuenteSeleccionada: TFuenteAleatoria;
      var fuenteFormulario: TFuenteAleatoria;
      CBBorne: TComboBox; nombreBorne: string);


    procedure setNodo(nombre: string; box: TComboBox; var nodo: TNodo);

    //Busca la fuente con el nombre especificado en la sala de juegos,
    //si la encuentra selecciona el nombre en el CB de fuentes y apunta fuente
    //a la fuente encotrada. Sino la encuentra despliega un msj de error
    //La segunda versión rellena el CB de bornes con los bornes de la fuente
    //Si se pasa en nombre la constante nombreFuenteNil fuente queda apuntando
    //NIL
    procedure setFuente(nombre: string; boxFuentes, boxBornes: TComboBox;
      var fuente: TFuenteAleatoria); overload;
    function nombreBorne(fuenteSeleccionada: TFuenteAleatoria;
      CBBorne: TComboBox): string;

    function validarNodo(CBNodo: TComboBox): boolean;
    procedure setCBFuente(cbFuente, cbBorne: TComboBox; fuente: TFuenteAleatoria);
    procedure cbFuenteChange(cbFuente: TObject; cbBorne: TComboBox);
    function validarFuente(CBFuente, CBBorne: TComboBox): boolean;
    function validarFuenteEolico(CBFuente, CBBorne: TComboBox): boolean;
    function valorCBFuente(cbFuente: TComboBox): TFuenteAleatoria;
    function validarTablaFalla(tabla: TStringGrid): boolean;

    procedure ocultarFechas(LFIni, LFFin: TLabel; EFIni, EFFin: TEdit);

    procedure initCBFuenteCondicional(cbCondicion: TCheckBox;
      etiquetaFuente, etiquetaBorne: TLabel; cbFuente, cbBorne: TComboBox;
      condEsCBTickeado: boolean; permiteNinguna: boolean;
      condicion: boolean;
      fuente: TFuenteAleatoria; borne: string);
    procedure cbFuenteCondicionalClick(cbCondicion: TCheckBox;
      etiquetaFuente, etiquetaBorne: TLabel; cbFuente, cbBorne: TComboBox;
      condEsCBTickeado: boolean);
    function validarCBFuenteCondicional(cbCondicion: TCheckBox;
      cbFuente, cbBorne: TComboBox; condEsCBTickeado: boolean): boolean;
    procedure valoresCBFuenteCondicional(cbCondicion: TCheckBox;
      cbFuente, cbBorne: TComboBox; condEsCBTickeado: boolean;
      var condicion: boolean;
      var fuente: TFuenteAleatoria; var borne: string);

    function validarListaFichasIniSim(listaFichas: TFichasLPD): boolean;
    //Llena los campos del formulario con el contenido del
    //valor funcional en func
  {    procedure llenarValorFuncional(func: TFuncion;
                                     RGTipoFunc: TRadioGroup;
                                     EValorConstante: TEdit;
                                     CBFuentes: TComboBox;
                                     var fuenteSeleccionada: TFuenteAleatoria;
                                     BTEditar: TButton;
                                     var valorBtEditar : TFuncion);
      //Retorna true <=> RGTipoFunc.itemindex = 0 y EValorConstante.Text puede ser convertido a un numero real
      //               ó RGTipoFunc.itemindex = 1 y fuente <> NIL
      //               ó RGTipoFunc.itemindex = 2 y valorBtEditar <> NIL
      function validarValorFuncional(RGTipoFunc: TRadioGroup;
                                     EValorConstante: TEdit;
                                     fuenteSeleccionada: TFuenteAleatoria;
                                     valorBtEditar: TFuncion) : boolean;
      //Crea un valor funcional a partir de los contenidos de los
      //campos del formulario
      function darValorFuncional(valorOrig : TFuncion;
                                 RGTipoFunc: TRadioGroup;
                                 EValorConstante: TEdit;
                                 fuenteSeleccionada: TFuenteAleatoria;
                                 valorBtEditar: TFuncion) : TFuncion;
      procedure cambioRGValorFuncional(radioGroup: TRadioGroup;
                                       EditValor: TEdit;
                                       CBFuentes: TComboBox;
                                       BTEditar: TButton);}
  private
    { Private declarations }
  public
  end;

implementation

uses Math, SimSEEEditMain;

{$IFNDEF FPC}
  {$R *.dfm}

{$ELSE}
  {$R *.lfm}
{$ENDIF}

procedure TBaseAltasEditores.sgFallaValidarCambio(Sender: TObject);
var
  tabla: TStringGrid;
  sum: NReal;
  iColumna: integer;
begin
  tabla := Sender as TStringGrid;
  if (tabla.cells[1, filaValidarSG] <> loQueHabia) and
    (filaValidarSG >= tabla.FixedRows) and (colValidarSG >= tabla.FixedCols) then
  begin
    try
      if filaValidarSG = 1 then
      begin
        sum := StrToFloat(tabla.cells[colValidarSG, filaValidarSG]);
        if (sum <= 0) or (sum > 1) then
        begin
          tabla.Cells[colValidarSG, filaValidarSG] := loQueHabia;
          ShowMessage(mesProfundidadDeEscalonesEnInterv);
        end
        else
        begin
          sum := 0;
          for iColumna := tabla.FixedCols to tabla.ColCount - 2 do
            sum := sum + StrToFloat(tabla.cells[icolumna, 1]);
          if sum > 1 then
          begin
            tabla.Cells[colValidarSG, filaValidarSG] := loQueHabia;
            ShowMessage(mesSumaDeProfundidadDeEscalones);
          end
          else
          begin
            tabla.Cells[tabla.ColCount - 1, 1] :=
              FloatToStrF(1 - sum, ffGeneral, CF_PRECISION, CF_DECIMALESPU);
            guardado := False;
          end;
        end;
      end
      else
      begin
        StrToFloat(tabla.cells[colValidarSG, filaValidarSG]);
        guardado := False;
      end;
    except
      on EConvertError do
      begin
        tabla.Cells[colValidarSG, filaValidarSG] := loQueHabia;
        ShowMessage(mesValorIntroducidoDebeNum);
      end;
    end;
  end;
end;

function TBaseAltasEditores.validarTablaFalla(tabla: TStringGrid): boolean;
var
  iColumna: integer;
  sum, profundidad: NReal;
  errorProfundidad: boolean;
begin
  try
    begin
      for iColumna := tabla.FixedCols to tabla.ColCount - 1 do
        StrToFloat(tabla.cells[iColumna, 2]);
      sum := 0;
      errorProfundidad := False;
      for iColumna := tabla.FixedCols to tabla.ColCount - 1 do
      begin
        profundidad := StrToFloat(tabla.cells[iColumna, 1]);
        if (profundidad <= 0) or (profundidad > 1) then
        begin
          errorProfundidad := True;
          break;
        end;
        sum := sum + profundidad;
      end;
      if errorProfundidad then
      begin
        ShowMessage(mesProfundidadDeEscalonesEnInterv);
        Result := False;
      end
      else if (sum < 1 + AsumaCero) and (sum > 1 - AsumaCero) then
        Result := True
      else
      begin
        ShowMessage(mesSumaDeProfundidadDeEscalones);
        Result := False;
      end;
    end
  except
    on EConvertError do
    begin
      ShowMessage(mesValoresEnTablaNumericos);
      Result := False;
    end
  end;
end;

procedure TBaseAltasEditores.sgFallaKeyDown(Sender: TObject; var Key: word;
  Shift: TShiftState);
var
  senderAsGrid: TStringGrid;
begin
  senderAsGrid := Sender as TStringGrid;
  validarSg := senderAsGrid.Cells[senderAsGrid.col, senderAsGrid.row] <> loQueHabia;
  if (Key in teclas) then
    sgFallaValidarCambio(Sender);
end;

procedure TBaseAltasEditores.inicializarCBNodos(cb: TComboBox; permiteNinguno: boolean);
var
  i: integer;
begin
  if permiteNinguno then
    cb.Items.Add(strNodoNinguno);
  //  cb.Items.Add(strAgregarNuevoNodo);

  for i := 0 to SaladeJuego.Nods.Count - 1 do
    cb.Items.Add((SaladeJuego.Nods[i] as TNodo).nombre);

  if cb.Items.Count = 1 then
    cb.ItemIndex := 0
  else
  begin
    cb.ItemIndex := -1;
    cb.Text := strSeleccionarNodo;
  end;
end;

procedure TBaseAltasEditores.setCBNodo(cb: TComboBox; valor: TNodo);
begin
  cb.ItemIndex := cb.Items.IndexOf(valor.nombre);
end;

function TBaseAltasEditores.valorCBNodo(cb: TComboBox): TNodo;
begin
  Result := TNodo(SaladeJuego.Nods.find(cb.Items[cb.ItemIndex]));
end;

function TBaseAltasEditores.validarCBNodo(cb: TComboBox): boolean;
begin
  if cb.ItemIndex <> -1 then
    Result := True
  else
  begin
    ShowMessage(mesSeleccionarNodoDeLista);
    cb.SetFocus;
    Result := False;
  end;
end;

procedure TBaseAltasEditores.cbNodoChange(Sender: TObject; cambiosForm: boolean);
//var
//  nodo: TNodo;
begin
{  if valorCBString(TComboBox(Sender)) = strAgregarNuevoNodo then
  begin
    nodo:= FSimSEEEdit.editar2(TNodo, NIL, false);
    if nodo <> NIL then
    begin
      TComboBox(Sender).Items.Add(nodo.nombre);
      TComboBox(Sender).ItemIndex:= TComboBox(Sender).Items.Count - 1;
      if cambiosForm then
        guardado:= false;
    end
    else
    begin
      TComboBox(Sender).ItemIndex:= -1;
      TComboBox(Sender).Text:= strSeleccionarNodo;
    end;
  end
  else} if cambiosForm then
    guardado := False;
end;

procedure TBaseAltasEditores.inicializarCBNodosLinkeados(cb, cbLinkeado: TComboBox;
  permiteNinguno: boolean);
begin
  if SaladeJuego.Nods.Count = 1 then
    raise Exception.Create('Debe agregar al menos dos nodos a la sala');

  inicializarCBNodos(cb, permiteNinguno);
  inicializarCBNodos(cbLinkeado, permiteNinguno);
end;

procedure TBaseAltasEditores.setCBNodoLinkeado(cb, cbLinkeado: TComboBox;
  valor, valorLinkeado: TNodo);
begin
  cb.ItemIndex := cb.Items.IndexOf(valor.nombre);
  cbLinkeado.Items.Delete(cbLinkeado.Items.IndexOf(valor.nombre));
  cbLinkeado.ItemIndex := cbLinkeado.Items.IndexOf(valorLinkeado.nombre);
  cb.Items.Delete(cb.Items.IndexOf(valorLinkeado.nombre));
end;

procedure TBaseAltasEditores.cbNodoLinkeadoChange(Sender: TObject;
  cbLinkeado: TComboBox);
var
  oldStr, strCbCambiado: string;
  i: integer;
  permiteNinguna: boolean;
begin
  permiteNinguna := cbLinkeado.Items[0] = strNodoNinguno;

  cbNodoChange(Sender, True);
  strCbCambiado := valorCBString(TComboBox(Sender));
  oldStr := valorCBString(cbLinkeado);

  cbLinkeado.Items.Clear;
  if permiteNinguna then
    cbLinkeado.Items.Add(strNodoNinguno);
  //  cbLinkeado.Items.Add(strAgregarNuevoNodo);
  for i := 0 to SaladeJuego.Nods.Count - 1 do
    if (SaladeJuego.Nods[i] as TNodo).nombre <> strCbCambiado then
      cbLinkeado.Items.Add((SaladeJuego.Nods[i] as TNodo).nombre);
  cbLinkeado.ItemIndex := cbLinkeado.Items.IndexOf(oldStr);
end;

procedure TBaseAltasEditores.inicializarCBNodo(CBNodo: TComboBox;
  nodoSeleccionado: TNodo);
var
  i: integer;
begin
  for i := 0 to SaladeJuego.Nods.Count - 1 do
    CBNodo.Items.Add((SaladeJuego.Nods[i] as TNodo).nombre);
  if nodoSeleccionado <> nil then
    CBNodo.ItemIndex := CBNodo.Items.IndexOf(nodoSeleccionado.Nombre);
end;

procedure TBaseAltasEditores.inicializarCBFuente(CBFuente: TComboBox;
  fuenteSeleccionada: TFuenteAleatoria; var fuenteFormulario: TFuenteAleatoria;
  CBBorne: TComboBox; nombreBorne: string; aceptaNinguna: boolean);
var
  i: integer;
begin
  fuenteFormulario := fuenteSeleccionada;
  if aceptaNinguna then
    CBFuente.Items.Add(nombreFuenteNil);
  for i := 0 to SaladeJuego.listaFuentes_.Count - 1 do
    CBFuente.Items.Add(TFuenteAleatoria(SaladeJuego.listaFuentes_[i]).nombre);
  if fuenteSeleccionada <> nil then
  begin
    CBFuente.ItemIndex := CBFuente.Items.IndexOf(fuenteSeleccionada.nombre);
    CBBorne.Items := fuenteSeleccionada.NombresDeBornes_Publicados;
    CBBorne.ItemIndex := CBBorne.Items.IndexOf(nombreBorne);
  end
  else
  begin
    if aceptaNinguna then
      CBFuente.ItemIndex := 0
    else
      CBFuente.ItemIndex := -1;
    CBBorne.Enabled := False;
  end;
end;

procedure TBaseAltasEditores.inicializarCBFuenteEolico(CBFuente: TComboBox;
  fuenteSeleccionada: TFuenteAleatoria;
  var fuenteFormulario:
  TFuenteAleatoria; CBBorne: TComboBox;
  nombreBorne: string);
var
  i: integer;
begin
  fuenteFormulario := fuenteSeleccionada;
  if SaladeJuego.globs.HorasDelPaso = 1 then
  begin
    for i := 0 to SaladeJuego.listaFuentes_.Count - 1 do
      CBFuente.Items.Add(TFuenteAleatoria(SaladeJuego.listaFuentes_[i]).nombre);
  end
  else
  begin
    for i := 0 to SaladeJuego.listaFuentes_.Count - 1 do
      if TFuenteAleatoria(SaladeJuego.listaFuentes_[i]).durPasoDeSorteoEnHoras = 1 then
        CBFuente.Items.Add(TFuenteAleatoria(SaladeJuego.listaFuentes_[i]).nombre);
  end;

  if fuenteSeleccionada <> nil then
  begin
    CBFuente.ItemIndex := CBFuente.Items.IndexOf(fuenteSeleccionada.nombre);
    CBBorne.Items := fuenteSeleccionada.NombresDeBornes_Publicados;
    CBBorne.ItemIndex := CBBorne.Items.IndexOf(nombreBorne);
  end
  else
  begin
    CBFuente.ItemIndex := -1;
    CBBorne.Enabled := False;
  end;
end;

procedure TBaseAltasEditores.setNodo(nombre: string; box: TComboBox; var nodo: TNodo);
var
  pos: integer;
begin
  if SaladeJuego.Nods.find(nombre, pos) then
  begin
    Nodo := SaladeJuego.Nods[pos] as TNodo;
    box.ItemIndex := box.Items.IndexOf(nombre);
    guardado := False;
  end
  else
    ShowMessage(mesNoSeEncuentraNodoSel);
end;

procedure TBaseAltasEditores.setFuente(nombre: string;
  boxFuentes, boxBornes: TComboBox; var fuente: TFuenteAleatoria);
var
  pos: integer;
begin
  if nombre <> nombreFuenteNil then
  begin
    if SaladeJuego.listaFuentes_.find(nombre, pos) then
    begin
      fuente := TFuenteAleatoria(SaladeJuego.listaFuentes_[pos]);
      boxFuentes.ItemIndex := boxFuentes.Items.IndexOf(nombre);
      guardado := False;
      boxBornes.Items := fuente.NombresDeBornes_Publicados;
      if boxBornes.Items.Count = 1 then
        boxBornes.ItemIndex := 0;
      boxBornes.Enabled := True;
    end
    else
      ShowMessage(mesNoSeEncuentraFuenteSel);
  end
  else
  begin
    fuente := nil;
    boxBornes.Items.Clear;
    boxBornes.Enabled := False;
  end;
end;

function TBaseAltasEditores.nombreBorne(fuenteSeleccionada: TFuenteAleatoria;
  CBBorne: TComboBox): string;
begin
  if fuenteSeleccionada <> nil then
    Result := CBBorne.Items[CBBorne.ItemIndex]
  else
    Result := '';
end;

function TBaseAltasEditores.validarNodo(CBNodo: TComboBox): boolean;
var
  ipos: integer;
begin
  if CBNodo.ItemIndex <> -1 then
  begin
    if SaladeJuego.Nods.find(CBNodo.Items[CBNodo.ItemIndex], ipos) then
      Result := True
    else
    begin
      ShowMessage(mesNoSeEncuentraNodoSel);
      Result := False;
    end;
  end
  else
  begin
    ShowMessage(mesSeleccionarNodoDeLista);
    Result := False;
  end;
end;

procedure TBaseAltasEditores.setCBFuente(cbFuente, cbBorne: TComboBox;
  fuente: TFuenteAleatoria);
begin
  if fuente <> nil then
  begin
    cbFuente.ItemIndex := cbFuente.Items.IndexOf(fuente.nombre);
    guardado := False;
    cbBorne.Items := fuente.NombresDeBornes_Publicados;
    if cbBorne.Items.Count = 1 then
      cbBorne.ItemIndex := 0;
  end
  else
  begin
    cbFuente.ItemIndex := cbFuente.Items.IndexOf(nombreFuenteNil);
    cbBorne.ItemIndex := -1;
  end;
end;

procedure TBaseAltasEditores.cbFuenteChange(cbFuente: TObject; cbBorne: TComboBox);
var
  fuente: TFuenteAleatoria;
begin
  fuente := valorCBFuente(TComboBox(cbFuente));
  cbBorne.Items := fuente.NombresDeBornes_Publicados;
  if cbBorne.Items.Count = 1 then
    cbBorne.ItemIndex := 0;
end;

function TBaseAltasEditores.validarFuente(CBFuente, CBBorne: TComboBox): boolean;
begin
  if CBFuente.ItemIndex <> -1 then
  begin
    if CBFuente.Items[CBFuente.ItemIndex] <> nombreFuenteNil then
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

function TBaseAltasEditores.validarFuenteEolico(CBFuente, CBBorne: TComboBox): boolean;
var
  fuente: TFuenteAleatoria;
begin
  if validarFuente(CBFuente, CBBorne) then
  begin
    fuente := valorCBFuente(CBFuente);
    if fuente.durPasoDeSorteoEnHoras <> 1 then
    begin
      if (fuente.durPasoDeSorteoEnHoras = 0) and
        (SaladeJuego.globs.HorasDelPaso = 1) then
      begin
        uCosa.procMsgAdvertenciaLectura(
          'Conectó un parque eólico a una fuente con paso de sorteo = 0. Si cambia la duración del paso de tiempo de la sala el generador se volverá invalido.');
        Result := True;
      end
      else
      begin
        ShowMessage(mesFuenteAleatConPaso1h + mesUstedLoConectoAFuente +
          fuente.nombre + mesConPasoDeSorteo +
          IntToStr(fuente.durPasoDeSorteoEnHoras));
        Result := False;
      end;
    end
    else
      Result := True;
  end
  else
    Result := False;
end;

function TBaseAltasEditores.valorCBFuente(cbFuente: TComboBox): TFuenteAleatoria;
var
  nombreFuente: string;
begin
  nombreFuente := valorCBString(cbFuente);
  Result := TFuenteAleatoria(SaladeJuego.listaFuentes_.find(nombreFuente));
end;

procedure TBaseAltasEditores.ocultarFechas(LFIni, LFFin: TLabel; EFIni, EFFin: TEdit);
begin
  LFIni.Visible := False;
  LFFin.Visible := False;
  EFIni.Text := 'Auto';
  EFFin.Text := 'Auto';
  EFIni.Visible := False;
  EFFin.Visible := False;
  cambiarTopControles(EFFin.Top, -(EFIni.Height + EFFin.Height + 3));
end;

procedure TBaseAltasEditores.initCBFuenteCondicional(cbCondicion: TCheckBox;
  etiquetaFuente, etiquetaBorne: TLabel; cbFuente, cbBorne: TComboBox;
  condEsCBTickeado: boolean; permiteNinguna: boolean;
  condicion: boolean;
  fuente: TFuenteAleatoria; borne: string);
var
  cumpleCondicion: boolean;
  i: integer;
begin
  cumpleCondicion := (condEsCBTickeado and condicion) or
    (not condEsCBTickeado and not condicion);

  if permiteNinguna then
    cbFuente.Items.Add(nombreFuenteNil);
  for i := 0 to SaladeJuego.listaFuentes_.Count - 1 do
    cbFuente.Items.Add(TFuenteAleatoria(SaladeJuego.listaFuentes_[i]).nombre);

  cbCondicion.Checked := condicion;
  if cumpleCondicion then
  begin
    if fuente <> nil then
    begin
      setCBFuente(cbFuente, cbBorne, fuente);
      setCBString(cbBorne, borne);
    end
    else
    begin
      cbFuente.ItemIndex := -1;
      cbBorne.ItemIndex := -1;
      cbFuente.Text := strSeleccionarFuente;
      cbBorne.Text := strSeleccionarBorne;
    end;
  end
  else
  begin
    cbFuente.ItemIndex := -1;
    cbBorne.ItemIndex := -1;
    cbFuente.Text := '';
    cbBorne.Text := '';
    etiquetaFuente.Enabled := False;
    cbFuente.Enabled := False;
    etiquetaBorne.Enabled := False;
    cbBorne.Enabled := False;
  end;
end;

procedure TBaseAltasEditores.cbFuenteCondicionalClick(cbCondicion: TCheckBox;
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

function TBaseAltasEditores.validarCBFuenteCondicional(cbCondicion: TCheckBox;
  cbFuente, cbBorne: TComboBox; condEsCBTickeado: boolean): boolean;
var
  cumpleCondicion: boolean;
begin
  cumpleCondicion := (condEsCBTickeado and cbCondicion.Checked) or
    (not condEsCBTickeado and not cbCondicion.Checked);

  if cumpleCondicion then
    Result := validarFuente(cbFuente, cbBorne)
  else
    Result := True;
end;

procedure TBaseAltasEditores.valoresCBFuenteCondicional(cbCondicion: TCheckBox;
  cbFuente, cbBorne: TComboBox; condEsCBTickeado: boolean;
  var condicion: boolean;
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

function TBaseAltasEditores.validarListaFichasIniSim(listaFichas: TFichasLPD): boolean;
var
  minFechaIni: TFecha;
begin
  minFechaIni := minFecha(SaladeJuego.globs.fechaIniSim, SaladeJuego.globs.fechaIniOpt);
  if (listaFichas.Count > 0) and
    (listaFichas[0].fecha.menorOIgualQue(minFechaIni)) then
    Result := True
  else
  begin
    ShowMessage(mesAgregarFichaCFechaAnterior + minFechaIni.AsISOStr + ').');
    Result := False;
  end;
end;

{procedure TBaseAltasEditores.llenarValorFuncional(
                                   func: TFuncion;
                                   RGTipoFunc: TRadioGroup;
                                   EValorConstante: TEdit;
                                   CBFuentes: TComboBox;
                                   var fuenteSeleccionada: TFuenteAleatoria;
                                   BTEditar: TButton;
                                   var valorBtEditar : TFuncion);

var
  i: Integer;
begin
  CBFuentes.Clear;
  for i := 0 to SaladeJuego.listaFuentes.Count - 1 do
    CBFuentes.Items.Add(TFuenteAleatoria(SaladeJuego.listaFuentes[i]).nombre);
  if func = NIL then
  begin
    fuenteSeleccionada:= NIL;
    RGTipoFunc.ItemIndex:= RGTipoFunc.Items.IndexOf(nombre_RG_ValorFuncional_Ninguno);
    if EValorConstante <> NIL then EValorConstante.Enabled:= false;
    if CBFuentes <> NIL then CBFuentes.Enabled:= false;
    if BTEditar <> NIL then BTEditar.Enabled:= false;
    valorBtEditar:= NIL;
  end
  else if func.ClassType = TFuncion_Constante then
  begin
    fuenteSeleccionada:= NIL;
    RGTipoFunc.ItemIndex:= RGTipoFunc.Items.IndexOf(nombre_RG_ValorFuncional_Constante);
    EValorConstante.Text:= FloatToStrF(func.valor, ffGeneral, CF_PRECISION, CF_DECIMALES);
    if CBFuentes <> NIL then CBFuentes.Enabled:= false;
    if BTEditar <> NIL then BTEditar.Enabled:= false;
    valorBtEditar:= NIL;
  end
  else if func.ClassType = TFuncion_Fuente then
  begin
    fuenteSeleccionada:= TFuncion_Fuente(func).fuente;
    RGTipoFunc.ItemIndex:= RGTipoFunc.Items.IndexOf(nombre_RG_ValorFuncional_Fuente);
    CBFuentes.ItemIndex:= CBFuentes.Items.IndexOf(TFuncion_Fuente(func).fuente.nombre);
    if EValorConstante <> NIL then EValorConstante.Enabled:= false;
    if BTEditar <> NIL then BTEditar.Enabled:= false;
    valorBtEditar:= NIL;
  end
  else
  begin
    fuenteSeleccionada:= TFuncion_Fuente(func).fuente;
    RGTipoFunc.ItemIndex:= RGTipoFunc.Items.IndexOf(nombre_RG_ValorFuncional_Otro);
    if EValorConstante <> NIL then EValorConstante.Enabled:= false;
    if CBFuentes <> NIL then CBFuentes.Enabled:= false;
    valorBtEditar:= func;
  end;
end;

function TBaseAltasEditores.validarValorFuncional(RGTipoFunc: TRadioGroup;
                                                  EValorConstante: TEdit;
                                                  fuenteSeleccionada: TFuenteAleatoria;
                                                  valorBtEditar: TFuncion) : boolean;
var
  res: boolean;
begin
  if RGTipoFunc.ItemIndex = RGTipoFunc.Items.IndexOf(nombre_RG_ValorFuncional_Ninguno) then
    res:= true
  else if RGTipoFunc.ItemIndex = RGTipoFunc.Items.IndexOf(nombre_RG_ValorFuncional_Constante) then
  begin
    res:= validarEditFloat(EValorConstante, -MaxNReal, MaxNReal);
  end
  else if RGTipoFunc.ItemIndex = RGTipoFunc.Items.IndexOf(nombre_RG_ValorFuncional_Fuente) then
  begin
    if fuenteSeleccionada <> NIL then
      res:= true
    else
    begin
      Showmessage(mesDebeSeleccionarFuenteDeLista);
      res:= false;
    end;
  end
  else if RGTipoFunc.ItemIndex = RGTipoFunc.Items.IndexOf(nombre_RG_ValorFuncional_Otro) then
    if valorBtEditar <> NIL then
      res:= true
    else
    begin
      Showmessage('Debe ingresar un valor funcional');
      res:= false;
    end
  else
    raise Exception.Create('Valor funcional desconocido, RGItemIndex= ' + IntToStr(RGTipoFunc.ItemIndex));
  result:= res;
end;

function TBaseAltasEditores.darValorFuncional(valorOrig : TFuncion;
                                              RGTipoFunc: TRadioGroup;
                                              EValorConstante: TEdit;
                                              fuenteSeleccionada: TFuenteAleatoria;
                                              valorBtEditar: TFuncion) : TFuncion;
var
  cv: TFuncion;
begin
  if (valorOrig = NIL) or (valorOrig.publica) then
  begin
    if RGTipoFunc.ItemIndex = RGTipoFunc.Items.IndexOf(nombre_RG_ValorFuncional_Ninguno) then
    begin //Selecciono Ninguno
      cv:= nil;
    end
    else if RGTipoFunc.ItemIndex = RGTipoFunc.Items.IndexOf(nombre_RG_ValorFuncional_Constante) then
    begin //Selecciono Fijo
      cv:= TFuncion_Constante.Create(SaladeJuego.Funcs.getNextId(TFuncion_Constante), StrToFloat(EValorConstante.Text));
      SaladeJuego.Funcs.Add(cv);
    end
    else if RGTipoFunc.ItemIndex = RGTipoFunc.Items.IndexOf(nombre_RG_ValorFuncional_Fuente) then
    begin //Selecciono Tomado de una fuente
      cv:= TFuncion_Fuente.Create(SaladeJuego.Funcs.getNextId(TFuncion_Fuente), fuenteSeleccionada);
      SaladeJuego.Funcs.Add(cv);
    end //Selecciono Otro
    else if RGTipoFunc.ItemIndex = RGTipoFunc.Items.IndexOf(nombre_RG_ValorFuncional_Otro) then
      cv:= valorBtEditar
    else
    begin
      raise Exception.Create('Valor funcional desconocido, RGItemIndex= ' + IntToStr(RGTipoFunc.ItemIndex));
    end;
  end
  else //valorOrig <> NIL and not valorOrig.publica
  begin
    if (RGTipoFunc.ItemIndex = RGTipoFunc.Items.IndexOf(nombre_RG_ValorFuncional_Ninguno)) then
    begin //Selecciono Ninguno
      SaladeJuego.Funcs.Remove(valorOrig);
      valorOrig.Free;
      cv:= NIL;
    end
    else if (RGTipoFunc.ItemIndex = RGTipoFunc.Items.IndexOf(nombre_RG_ValorFuncional_Constante)) then
    begin //Selecciono Fijo
      if (valorOrig.ClassType = TFuncion_Constante) then
      begin
        valorOrig.valor:= StrToFloat(EValorConstante.Text);
        cv:= valorOrig;
      end
      else
      begin
        SaladeJuego.Funcs.Remove(valorOrig);
        valorOrig.Free;
        cv:= TFuncion_Constante.Create(SaladeJuego.Funcs.getNextId(TFuncion_Constante), StrToFloat(EValorConstante.Text));
      end;
    end
    else if (RGTipoFunc.ItemIndex = RGTipoFunc.Items.IndexOf(nombre_RG_ValorFuncional_Fuente)) then
    begin //Selecciono Tomado de una fuente
      if (valorOrig.ClassType = TFuncion_Fuente) then
      begin
        TFuncion_Fuente(valorOrig).fuente:= fuenteSeleccionada;
        cv:= valorOrig;
      end
      else
      begin
        SaladeJuego.Funcs.Remove(valorOrig);
        valorOrig.Free;
        cv:= TFuncion_Fuente.Create(SaladeJuego.Funcs.getNextId(TFuncion_Fuente), fuenteSeleccionada);
      end
    end
    else if RGTipoFunc.ItemIndex = RGTipoFunc.Items.IndexOf(nombre_RG_ValorFuncional_Otro) then
    begin //Selecciono Otro
      SaladeJuego.Funcs.Remove(valorOrig);
      valorOrig.Free;
      cv:= valorBtEditar;
    end
    else
    begin
      raise Exception.Create('Valor funcional desconocido, RGItemIndex= ' + IntToStr(RGTipoFunc.ItemIndex));
    end;
  end;
  result:= cv;
end;

procedure TBaseAltasEditores.cambioRGValorFuncional(
            radioGroup: TRadioGroup; EditValor: TEdit;
            CBFuentes: TComboBox; BTEditar: TButton);
begin
  if radioGroup.ItemIndex = radioGroup.Items.IndexOf(nombre_RG_ValorFuncional_Ninguno) then
  begin
    if EditValor <> NIL then EditValor.Enabled:= false;
    if CBFuentes <> NIL then CBFuentes.Enabled:= false;
    if BTEditar <> NIL then BTEditar.Enabled:= false;
  end
  else if radioGroup.ItemIndex = radioGroup.Items.IndexOf(nombre_RG_ValorFuncional_Constante) then
  begin
    EditValor.Enabled:= true;
    if CBFuentes <> NIL then CBFuentes.Enabled:= false;
    if BTEditar <> NIL then BTEditar.Enabled:= false;
  end
  else if radioGroup.ItemIndex = radioGroup.Items.IndexOf(nombre_RG_ValorFuncional_Fuente) then
  begin
    if EditValor <> NIL then EditValor.Enabled:= false;
    CBFuentes.Enabled:= true;
    if BTEditar <> NIL then BTEditar.Enabled:= false;
    CBFuentes.Enabled:= true;
  end
  else if radioGroup.ItemIndex = radioGroup.Items.IndexOf(nombre_RG_ValorFuncional_Otro) then
  begin
    Showmessage('Por implementar');
    if EditValor <> NIL then EditValor.Enabled:= false;
    if CBFuentes <> NIL then CBFuentes.Enabled:= false;
    if BTEditar <> NIL then BTEditar.Enabled:= false;
//    CBFuentes.Enabled:= false;
//    BTEditar.Enabled:= true;
  end
  else
    raise Exception.Create('Valor funcional desconocido, RGItemIndex= ' + IntToStr(radioGroup.ItemIndex));
end;}

end.
