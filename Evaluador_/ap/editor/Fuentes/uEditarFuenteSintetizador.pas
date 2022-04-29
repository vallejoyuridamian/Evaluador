unit uEditarFuenteSintetizador;

  {$MODE Delphi}

interface

uses
  {$IFDEF WINDOWS}
  Windows, Buttons,
  {$ELSE}
  LCLType,
  {$ENDIF}
  Messages, SysUtils, Classes,
  Graphics,
  utrazosxy,
  Controls, Forms,
  Dialogs, StdCtrls, Grids,
  uBaseEditoresCosasConNombre,
  uCosaConNombre,
  usalasdejuego, ucosa,
  uFuenteSintetizador,
  umodelosintcegh,
  uEsclavizador,
  uverdoc, uconstantesSimSEE, utilidades, xMatDefs, uAuxiliares,
  uDatosHistoricos, uFechas, uOpcionesSimSEEEdit, uFichasLPD,
  uVisorFichasExpandidas, ComCtrls, ExtCtrls,
  uopencalc,
  uopencalcexportimport,
  MatReal,
  Math,
  uvisordetabla,
  uRobotHttpPost,
  types, Clipbrd, Menus, upronostico,
  ugeturlinfo,
  ucalibrarconopronosticos, uUtilFormulario;

resourcestring
  rsBorne = 'Borne';
  rsValores = 'Valores';
  rsFechaDeInicio = 'Fecha de Inicio';
  rsInformacioNAdicional = 'Información adicional';
  rsPeriodicaQ = 'Periodica?';
  rsNoDisponible = 'No disponible';
  mesSeleccionarArchivoAntesAgregarFichasFuente =
    'Debe seleccionar un archivo de datos antes de agregar fichas a la fuente';
  mesConfirmaEliminarFicha = '¿Confirma que desea eliminar la ficha seleccionada?';
  mesConfirmarEliminacion = 'Confirmar eliminación';
  rsSubMuestreada = 'Sub-muestreada';
  rsSobreMuestreada = 'Sobre-muestreada';
  rsSinEsclavizar = 'Sin Esclavizar';
  exDeterminismoInvalido = 'El formato del determinismo ingresado no es valido';
  msFormatoInvalido = 'Formato invalido';
  mesNumeroValorEsperado = 'El valor esperado debe ser un número entre 1 y 100';
  mesCalibCamposNoNumericos =
    'Los campos del calibrador deben ser valores numericos positivos mayores a 0';
  mesSesgosCamposNoNumericos =
    'Los campos del generador de sesgos deben ser valores numericos positivos.';
  rs_Error_StrToInt = 'Error de conversión a entero.';

  rs_P = 'Probabilidad asignada a la guia.';
  rs_NPCC = 'Número de Pasos de Control de Cono.';
  rs_NPLC = 'Número de Pasos de Liberación del Cono.';
  rs_NPSA = 'Número de Pasos Sin Apertura del cono.';
  rs_NPAC = 'Número de Pasos de Apertura del Cono.';
  rs_ve = 'La guía es en valor esperado.';
  rs_pe = 'Probabilidad de Excedencia de la guía si no es en valor esperado.';


type

 { TEditarFuenteSintetizador }

  TEditarFuenteSintetizador = class(TBaseEditoresCosasConNombre)
    BAyuda: TButton;
    BAyudaDurPasoSorteo: TButton;
    BAyudaDurPasoTiempo: TButton;
    BBuscar: TButton;
    BBuscarDatosHistoricos: TButton;
    BCancelar: TButton;
    BGuardar: TButton;
    BtBuscarModeloAuxiliar: TButton;
    btGetPronosticos: TButton;
    btGraficarPronosticos: TButton;
    cbEscenarioSelecctionado: TComboBox;
    cbResumirPromediando: TCheckBox;
    cbSimularUsandoDatosHistoricos: TCheckBox;
    cbUsarModeloAuxiliarParaOpt: TCheckBox;
    cbSincronizarConHistoricos: TCheckBox;
    cbSincronizarConSemillaAleatoria: TCheckBox;
    EArchiDatosHistoricos: TEdit;
    eArchiModeloAuxiliar: TEdit;
    eNPasosPlot: TEdit;
    eProbabilidad: TEdit;
    eDurPasoSorteo: TEdit;
    eDurPasoTiempo: TEdit;
    ENArch: TEdit;
    ENombre: TEdit;
    eTipoDeEsclavizacion: TEdit;
    eurl_get: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    lDatosHistoricos: TLabel;
    LDurPasoSorteo: TLabel;
    LDurPasoTiempo: TLabel;
    LNArch: TLabel;
    LNombre: TLabel;
    lTipoEsclavizacion: TLabel;
    odEditarFuenteSintetizador: TOpenDialog;
    Panel1: TPanel;
    Panel2: TPanel;
    rbGraficarEscenarioActual: TRadioButton;
    rbGraficarComplexivo: TRadioButton;
    ScrollBox1: TScrollBox;
    Splitter3: TSplitter;

    procedure BCancelarClick(Sender: TObject);
    procedure BGuardarClick(Sender: TObject); override;
    procedure BBuscarClick(Sender: TObject);
    procedure BAyudaClick(Sender: TObject);
    procedure btGraficarPronosticosClick(Sender: TObject);
    procedure btGetPronosticosClick(Sender: TObject);
    procedure cambiosForm(Sender: TObject);
    procedure cbEscenarioSelecctionadoChange(Sender: TObject);
    procedure eProbabilidadChange(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure ENArchExit(Sender: TObject);
    procedure BBuscarDatosHistoricosClick(Sender: TObject);
    procedure cbSimularUsandoDatosHistoricosClick(Sender: TObject);
    procedure BtBuscarModeloAuxiliarClick(Sender: TObject);
    procedure CopiadoYPegadoDeterminismos(Sender: TObject; var Key: word;
      Shift: TShiftState);
    procedure BAyudaTipoEsclavizadorClick(Sender: TObject);
  private

    escenarioDePronosticos: TEscenarioDePronosticos;
    ultimoEscenarioSeleccionado: Integer;

    cegh: TModeloCEGH;
    tblPronosticos: TTabla;

    // llena al tabla a partir de los datos
    procedure cambiar_guia(kSerie: integer; nueva_guia: TDAOfNReal);
    procedure populate_Pronosticos;

    // copia los valores de la tabla en los datos
    // retorna si hayErrores o si hayCambios.
    procedure dump_Pronosticos(var hayCambios, hayErrores: boolean);


    function onCambioENarchValido:Boolean;
    procedure setComponentesTipoEsclavizador;

  protected
    function validarModeloEHistorico: boolean;
    function validarFormulario: boolean; override;
  public

    constructor Create(AOwner: TComponent; sala: TSalaDeJuego;
      tipoCosa: TClass; cosaConNombre: TCosaConNombre); override;


  end;

var
  trx: array of TfrmDLLForm;


implementation

  {$R *.lfm}

constructor TEditarFuenteSintetizador.Create(AOwner: TComponent;
  sala: TSalaDeJuego; tipoCosa: TClass; cosaConNombre: TCosaConNombre);
var
  fuente: TFuenteSintetizadorCEGH;
  kNombreBornes_Publicados, i: Integer;
  Catalogo: TCatalogoReferencias;

begin
  inherited Create(AOwner, sala, tipoCosa, cosaConNombre);
  self.eDurPasoTiempo.Text := FloatToStr(sala.globs.HorasDelPaso);

  cbEscenarioSelecctionado.Items.Add('<Nuevo escenario>');

  tblPronosticos := TTabla.Create(scrollBox1, 'tblPronosticos', 4, 0, 0);

  if cosaConNombre <> nil then
  begin
    fuente := cosaConNombre as TFuenteSintetizadorCEGH;

    ENombre.Text := fuente.nombre;
    ENArch.Text := fuente.nombreArchivoModelo.archi;
    odEditarFuenteSintetizador.InitialDir :=
      getCurrentDrive + ExtractFilePath(fuente.nombreArchivoModelo.archi);

    cegh := TModeloCEGH.CreateFromArchi(fuente.nombreArchivoModelo.archi);
    cbSimularUsandoDatosHistoricos.Checked := fuente.simularConDatosHistoricos;
    cbSimularUsandoDatosHistoricosClick(self);
    cbSincronizarConHistoricos.Checked := fuente.SincronizarConHistoricos;
    cbSincronizarConSemillaAleatoria.Checked := fuente.SincronizarConSemillaAleatoria;

    EArchiDatosHistoricos.Text := fuente.nombreArchivoDatosHistoricos.archi;
    eDurPasoSorteo.Text := IntToStr(cegh.durPasoDeSorteoEnHoras);

    eArchiModeloAuxiliar.Text := fuente.nombreArchivoModeloAuxiliar.archi;
    cbUsarModeloAuxiliarParaOpt.Checked := fuente.usarModeloAuxiliar;
    cbResumirPromediando.Checked := fuente.ResumirPromediando;
    setComponentesTipoEsclavizador;


    Catalogo:= TCatalogoReferencias.Create;
    Self.escenarioDePronosticos := fuente.escenarioDePronosticos.Create_Clone( catalogo, 0 ) as TEscenarioDePronosticos;
    Catalogo.Free;

    for i:= 1 to escenarioDePronosticos.Count do
      cbEscenarioSelecctionado.Items.Add('Escenario '+IntToStr(i));

    cbEscenarioSelecctionado.ItemIndex:=1;
    ultimoEscenarioSeleccionado:=0;

    eProbabilidad.Text:=IntToStr(Self.escenarioDePronosticos.items[0].P);

    eurl_get.Text:= fuente.url_get;

    populate_Pronosticos;

  end
  else
  begin
    odEditarFuenteSintetizador.InitialDir := getDir_DatosComunes;
    self.escenarioDePronosticos := TEscenarioDePronosticos.Create(capa, '');
    cegh := nil;
    eDurPasoSorteo.Text := rsNoDisponible;
    EArchiDatosHistoricos.Enabled := False;
    BBuscarDatosHistoricos.Enabled := False;
    eArchiModeloAuxiliar.Text := '';
    cbUsarModeloAuxiliarParaOpt.Checked := False;
    cbResumirPromediando.Checked := True;
    eurl_get.Text:= '';
  end;

end;


procedure TEditarFuenteSintetizador.dump_Pronosticos(var hayCambios,
  hayErrores: boolean);
var
  i: integer;
  aPronostico: TPronostico;
  cb: TCheckBox;
  nuevos_valores: TDAofNReal;
  ed: TEdit;
  res: boolean;
  maxNPCC: integer;

  Serie: String;
  Pronosticos: TPronosticos;
  PAcum: NReal;

begin

  if hayErrores then
    exit;

  Pronosticos:= escenarioDePronosticos.items[ultimoEscenarioSeleccionado] as TPronosticos;
  for i := 1 to Pronosticos.Count do
  begin
    aPronostico := Pronosticos[i - 1] as TPronostico; //Arrancan en 0
    ed := tblPronosticos.FindObj(i, 1, 'ed_' + IntToStr(i));
    if Assigned(ed) then
    begin

      try
        nuevos_valores := StrToDAOfNReal_(ed.Text, ';');
        if not viguales(nuevos_valores, aPronostico.guia) then
        begin
          setlength(aPronostico.guia, 0);
          aPronostico.guia := nuevos_valores;
          hayCambios := True;
        end;
      except
        on E: Exception do
        begin
          ShowMessage(msFormatoInvalido);
          ed.SetFocus;
          hayErrores := True;
        end;
      end;
      dump_int(tblPronosticos, aPronostico.NPCC, 'npcc_' + IntToStr(i),
        i, 2, hayCambios, hayErrores);

      maxNPCC := length(aPronostico.guia) - cegh.CalcOrdenDelFiltro;
      if aPronostico.NPCC > MaxNPCC then
      begin
        ed := tblPronosticos.FindObj(i, 2, 'npcc_' + IntToStr(i));
        ed.Text := IntToStr(maxNPCC);
        aPronostico.NPCC := maxNPCC;
        hayCambios := True;
        hayErrores := True;
        ShowMessage('Atención, el valor NPCC+NRetardos para la serie: ' +
          IntToStr(i) + ' es superior al largo de la guía del cono. Dicho valor NPCC fue reducido al largo de la guía-NRetardos. Revise el cambio por favor.');
      end;

      dump_int(tblPronosticos, aPronostico.NPSA, 'npsa_' + IntToStr(i),
        i, 4, hayCambios, hayErrores);
      if aPronostico.NPSA > MaxNPCC then
      begin
        ed := tblPronosticos.FindObj(i, 4, 'npsa_' + IntToStr(i));
        ed.Text := IntToStr(maxNPCC);
        aPronostico.NPSA := maxNPCC;
        hayCambios := True;
        hayErrores := True;
        ShowMessage('Atención, el valor NPSA del canal ' + IntToStr(
          i) + ' debe ser inferior a la cantidad de valores de la guia descontando los necesarios para inicializar el filtro.'
          + ' Dicho valor NPSA fue reducido al largo de la guía-NRetardos. Revise el cambio por favor.'
          );
      end;

      dump_int(tblPronosticos, aPronostico.NPLC, 'nplc_' + IntToStr(i),
        i, 3, hayCambios, hayErrores);
      dump_int(tblPronosticos, aPronostico.NPAC, 'npac_' + IntToStr(i),
        i, 5, hayCambios, hayErrores);
      dump_float(tblPronosticos, aPronostico.guia_pe, 'npe_' + IntToStr(i),
        i, 6, hayCambios, hayErrores);

    end;
  end;

  if hayCambios then
    guardado := False;
end;






procedure TEditarFuenteSintetizador.populate_Pronosticos;
var
  i: integer;
  Pronosticos: TPronosticos;
  aPronostico: TPronostico;

begin

  Pronosticos:= escenarioDePronosticos.items[cbEscenarioSelecctionado.ItemIndex-1] as TPronosticos;

  //  tblPronosticos.Parent:= ScrollBox1;
  //  Borne, valores, ve, prb, NPCC, NPLC, NPSA, NPAC

  tblPronosticos.ClearRedim(1 + Pronosticos.Count, 8); //filas, columnas

  //Creo la fila de titulos
  tblPronosticos.wrTexto('', 0, 0, 'Borne');
  tblPronosticos.wrTexto('', 0, 1, 'Valores iniciales y guía del pronóstico.');
  tblPronosticos.wrTexto('', 0, 2, 'NPCC');
  tblPronosticos.wrTexto('', 0, 3, 'NPLC');
  tblPronosticos.wrTexto('', 0, 4, 'NPSA');
  tblPronosticos.wrTexto('', 0, 5, 'NPAC');
  tblPronosticos.wrTexto('', 0, 6, 'pe[p.u.]');
  tblPronosticos.wrTexto('', 0, 7, 'NRet.');

  tblPronosticos.SetBgColorFila(0, clGray);
  tblPronosticos.SetFontColorFila(0, clWhite);
  //Completo la tabla con los pronosticos para la serie

  for i:= 1 to Pronosticos.Count do
  begin

    aPronostico:=Pronosticos.items[i-1];

    tblPronosticos.wrTexto('', i, 0, cegh.NombresDeBornes_Publicados[i - 1]);

    tblPronosticos.wrEdit('ed_' + IntToStr(i), i, 1, DAOfNRealToStr_(
      aPronostico.guia, 8, 3, ';'), 28, '');

    tblPronosticos.wrEdit('npcc_' + IntToStr(i), i, 2,
      IntToStr(aPronostico.NPCC), 2, rs_NPCC);
    tblPronosticos.wrEdit('nplc_' + IntToStr(i), i, 3,
      IntToStr(aPronostico.NPLC), 2, rs_NPLC);
    tblPronosticos.wrEdit('npsa_' + IntToStr(i), i, 4,
      IntToStr(aPronostico.NPSA), 2, rs_NPSA);
    tblPronosticos.wrEdit('npac_' + IntToStr(i), i, 5,
      IntToStr(aPronostico.NPAC), 2, rs_NPAC);
    tblPronosticos.wrEdit('npe_' + IntToStr(i), i, 6,
      FloatToStr(aPronostico.guia_pe), 3, rs_pe);
    tblPronosticos.wrTexto('', i, 7, IntToStr(cegh.CalcOrdenDelFiltro));

  end;

  eProbabilidad.Text:=IntToStr(Pronosticos.P);

  tblPronosticos.reposicionar;
  tblPronosticos.Visible := True;

end;


procedure TEditarFuenteSintetizador.cambiar_guia(
   kSerie: integer; nueva_guia: TDAOfNReal );
var
  i: integer;
  Pronosticos: TPronosticos;
  aPronostico: TPronostico;

begin
  Pronosticos:= escenarioDePronosticos.items[cbEscenarioSelecctionado.ItemIndex-1] as TPronosticos;
  aPronostico:=Pronosticos.items[ kSerie ];
  setlength( aPronostico.guia, 0 );
  aPronostico.guia:= copy( nueva_guia );
end;


function TEditarFuenteSintetizador.onCambioENarchValido: Boolean;
var
  i, j, pos: integer;
  newDatos: TModeloCEGH;
  newEscenario: TEscenarioDePronosticos;
  nEscenatios: Integer;
  salaAux: TSalaDeJuego;
  fr: TFichaReferencia;
  referentes: String;
  Catalogo: TCatalogoReferencias;
begin

  Result:=True;
  newDatos := TModeloCEGH.CreateFromArchi(ENArch.Text);

  if cegh <> nil then
  begin

    Catalogo:= TCatalogoReferencias.Create;
    // Para cargar la variable referencias en uCosaConNombre.
    salaAux:= TSalaDeJuego(sala.Create_Clone( Catalogo, 0 ));
    referentes:='';
    for i:=0 to Catalogo.referencias.Count-1 do
    begin
      fr:=TFichaReferencia( Catalogo.referencias[i]);
      if (fr.referido_nombre=cosaConNombre.nombre) then
        begin
          if fr.referente is TCosaConNombre then
            referentes:=referentes +TCosaConNombre(fr.referente).DescClase+ ' - ' + TCosaConNombre(fr.referente).nombre+#13#10
          else
            referentes:=referentes +TCosaConNombre(fr.referente).DescClase+ ' - ' + 'SIN NOMBRE'+#13#10;
        end;
    end;

    // Libero y limpio las lista de referencias.
    salaAux.Free;
    Catalogo.LimpiarReferencias;

    if (referentes<>'') and (MessageDlg('Atención',
       'Se deberá verificar la asignación de bornes para:'+#13#10#13#10+
       referentes+#13#10#13#10+'¿Desea continuar?', mtWarning, [mbYes, mbNo], 0) = mrNo) then
    begin
      Result:=False;
      Exit;
    end;

    newEscenario:=TEscenarioDePronosticos.Create(capa);
    nEscenatios:=escenarioDePronosticos.Count;

    cbEscenarioSelecctionado.Items.Clear;
    cbEscenarioSelecctionado.Items.Add('<Nuevo escenario>');

    if nEscenatios = 0 then
      escenarioDePronosticos.Add(TPronosticos.Create_Default(newDatos), 100)
    else
    begin
      // Si hay pronosticos en común los conservamos.
      for i:=0 to nEscenatios-1 do
      begin
        newEscenario.Add(TPronosticos.Create_Default(newDatos), escenarioDePronosticos[i].P);

        cbEscenarioSelecctionado.Items.Add('Escenario '+IntToStr(i+1));

        for j:=0 to cegh.NombresDeBornes_Publicados.Count-1 do
        begin
          pos := newDatos.NombresDeBornes_Publicados.IndexOf(
            cegh.NombresDeBornes_Publicados[j]);

          if pos <> -1 then
          begin
            newEscenario[i][pos].Free;
            newEscenario[i][pos]:=escenarioDePronosticos[i][pos].Create_Clone( Catalogo, 0 ) as TPronostico;
          end;
        end;
      end;
    end;

    cegh.Free;
    cbEscenarioSelecctionado.ItemIndex :=1;
    ultimoEscenarioSeleccionado:=0;

    Catalogo.Free;

  end
  else
  begin

    newEscenario:=TEscenarioDePronosticos.Create(capa);
    newEscenario.Add(TPronosticos.Create_Default(newDatos), 100);

    cbEscenarioSelecctionado.Items.Add('Escenario '+IntToStr(cbEscenarioSelecctionado.Items.Count));
    cbEscenarioSelecctionado.ItemIndex := cbEscenarioSelecctionado.Items.Count-1;
  end;

  cegh := newDatos;
  if escenarioDePronosticos <> nil then
    escenarioDePronosticos.Free;

  self.escenarioDePronosticos := newEscenario;

  setComponentesTipoEsclavizador;
  populate_Pronosticos;

  eDurPasoSorteo.Text := IntToStr(cegh.durPasoDeSorteoEnHoras);
  eArchiModeloAuxiliar.Text := '';
  EArchiDatosHistoricos.Text := '';
  cbUsarModeloAuxiliarParaOpt.Checked := False;
  cbResumirPromediando.Checked := True;
  cbSimularUsandoDatosHistoricos.Checked:=False;
  eurl_get.Text:= '';

end;

function TEditarFuenteSintetizador.validarModeloEHistorico: boolean;
var
  i: integer;
  mismosBornes: boolean;
  datosHistoricos: TDatosHistoricos;
begin
  try
    datosHistoricos := TDatosHistoricos.CreateFromArchi(EArchiDatosHistoricos.Text);
    if cegh.durPasoDeSorteoEnHoras <> Trunc(datosHistoricos.dt_EntrePuntos *
      dtToHora + 0.02) then
      raise Exception.Create(
        'Especificó un archivo de datos historicos con distinta duración de paso de sorteo que la del archivo del modelo.');

    mismosBornes := datosHistoricos.NombresDeBornes_Publicados.Count =
      cegh.NombresDeBornes_Publicados.Count;
    i := 0;
    while (i < datosHistoricos.NombresDeBornes_Publicados.Count) and mismosBornes do
    begin
      mismosBornes := cegh.NombresDeBornes_Publicados[i] =
        datosHistoricos.NombresDeBornes_Publicados[i];
      i := i + 1;
    end;
    if not mismosBornes then
      raise Exception.Create(
        'Los bornes en el archivo del modelo difieren de los bornes en el archivo de datos historicos.');
    Result := True;
    datosHistoricos.Free;
  except
    on e: Exception do
    begin
      ShowMessage(e.Message);
      Result := False;
    end;
  end;
end;

function TEditarFuenteSintetizador.validarFormulario: boolean;
var
  hayCambios, hayErrores: boolean;
begin
  try
    hayCambios := False;
    hayErrores := False;
    dump_pronosticos(hayCambios, hayErrores);
    Result := not hayErrores and inherited validarNombre(ENombre) and
      inherited validarEditNarch(ENArch) and
      (not cbSimularUsandoDatosHistoricos.Checked or
      (validarEditNarch(EArchiDatosHistoricos) and validarModeloEHistorico));
  except
    Result := False;
  end;
end;




procedure TEditarFuenteSintetizador.ENArchExit(Sender: TObject);
begin
  if validarEditNarch(ENArch) then
    onCambioENarchValido;
end;



procedure TEditarFuenteSintetizador.cambiosForm(Sender: TObject);
begin
  inherited CambiosForm(Sender);
end;

procedure TEditarFuenteSintetizador.cbEscenarioSelecctionadoChange(Sender: TObject);
var
  hayCambios,
  hayErrores: Boolean;
  index: Integer;
begin

  if ultimoEscenarioSeleccionado=cbEscenarioSelecctionado.ItemIndex-1 then
    Exit;

  hayErrores:= false;
  hayCambios:= false;
  dump_Pronosticos( hayCambios, hayErrores);

  // Agregar nuevo escanarios.
  if cbEscenarioSelecctionado.ItemIndex = 0 then
  begin





    ////******  A BORRAR   ***********
    //
    //MessageDlg('Información', 'FUNCIÓN AÚN NO DISPONIBLE.', mtInformation, [mbOK], 0);
    //cbEscenarioSelecctionado.ItemIndex:=1;
    //Exit;
    //
    ////******************************


    index:=escenarioDePronosticos.Add(TPronosticos.Create_Default(cegh), 0);
    cbEscenarioSelecctionado.Items.Add('Escenario '+IntToStr(cbEscenarioSelecctionado.Items.Count));
    cbEscenarioSelecctionado.ItemIndex := cbEscenarioSelecctionado.Items.Count-1;

  end;

  if hayErrores then
    tblPronosticos.SetFocus
  else
    populate_Pronosticos;

  ultimoEscenarioSeleccionado:=cbEscenarioSelecctionado.ItemIndex-1;
end;

procedure TEditarFuenteSintetizador.eProbabilidadChange(Sender: TObject);
var
  p: Integer;
begin

  if eProbabilidad.Text='' then
  begin
    eProbabilidad.Text:='0';
    Exit;
  end;

  p:= StrToInt(eProbabilidad.Text);

  if (p<0) or (p>100) then
  begin
    MessageDlg('Atención', 'Rango válido de valores: 0 <= p <= 100', mtWarning, [mbOK], 0);
    eProbabilidad.Undo;
  end;
end;



procedure TEditarFuenteSintetizador.cbSimularUsandoDatosHistoricosClick(Sender: TObject);
begin
  EArchiDatosHistoricos.Enabled := cbSimularUsandoDatosHistoricos.Checked;
  BBuscarDatosHistoricos.Enabled := cbSimularUsandoDatosHistoricos.Checked;
end;

procedure TEditarFuenteSintetizador.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
var
  numeroDeSerie: integer;
begin
  inherited FormCloseQuery(Sender, CanClose);
  if CanClose then
  begin
    if cegh <> nil then
      cegh.Free;
    if (ModalResult <> mrOk) then
    begin
      //if pronosticos <> nil then
      //begin
      //  Pronosticos.Free;
      //  Pronosticos := nil;
      //end;

      for numeroDeSerie := 0 to high(trx) do
        if trx[numeroDeSerie] <> nil then
          trx[numeroDeSerie].Close;
      SetLength(trx, 0);
    end;
  end;
end;

procedure TEditarFuenteSintetizador.setComponentesTipoEsclavizador;
begin
  if cegh.durPasoDeSorteoEnHoras < sala.globs.HorasDelPaso then
  begin
    eTipoDeEsclavizacion.Text := rsSubMuestreada;
    cbResumirPromediando.Enabled := True;
  end
  else if cegh.durPasoDeSorteoEnHoras = sala.globs.HorasDelPaso then
  begin
    eTipoDeEsclavizacion.Text := rsSinEsclavizar;
    cbResumirPromediando.Enabled := False;
  end
  else
  begin
    eTipoDeEsclavizacion.Text := rsSobreMuestreada;
    cbResumirPromediando.Enabled := False;
  end;
end;


procedure TEditarFuenteSintetizador.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;


procedure TEditarFuenteSintetizador.BGuardarClick(Sender: TObject);
var
  fuente: TFuenteSintetizadorCEGH;
begin
  if validarFormulario then
  begin
    if cosaConNombre = nil then
    begin
      cosaConNombre := TFuenteSintetizadorCEGH.Create(
        capa, ENombre.Text, ENArch.Text, EArchiDatosHistoricos.Text,
        cbSimularUsandoDatosHistoricos.Checked, cbSincronizarConHistoricos.Checked,
        cbSincronizarConSemillaAleatoria.Checked, eArchiModeloAuxiliar.Text,
        cbUsarModeloAuxiliarParaOpt.Checked, self.escenarioDePronosticos,
        cbResumirPromediando.Checked, eurl_get.Text);
    end
    else
    begin
      fuente := TFuenteSintetizadorCEGH(cosaConNombre);
      fuente.nombre := ENombre.Text;
      fuente.nombreArchivoModelo.archi := ENArch.Text;
      fuente.nombreArchivoDatosHistoricos.archi := EArchiDatosHistoricos.Text;
      fuente.simularConDatosHistoricos := cbSimularUsandoDatosHistoricos.Checked;
      fuente.sincronizarConHistoricos := cbSincronizarConHistoricos.Checked;
      fuente.SincronizarConSemillaAleatoria := cbSincronizarConSemillaAleatoria.Checked;

      fuente.nombreArchivoModeloAuxiliar.archi := eArchiModeloAuxiliar.Text;
      fuente.usarModeloAuxiliar := cbUsarModeloAuxiliarParaOpt.Checked;
      fuente.ResumirPromediando := cbResumirPromediando.Checked;
      fuente.escenarioDePronosticos.Free;
      fuente.escenarioDePronosticos := self.escenarioDePronosticos;
      fuente.url_get:= eurl_get.Text;
      fuente.InitModeloFromFile;


    end;

    ModalResult := mrOk;
  end;
end;


procedure TEditarFuenteSintetizador.BtBuscarModeloAuxiliarClick(Sender: TObject);
begin
  if odEditarFuenteSintetizador.Execute then
  begin
    odEditarFuenteSintetizador.FileName :=
      odEditarFuenteSintetizador.FileName;
    eArchiModeloAuxiliar.Text := odEditarFuenteSintetizador.FileName;
    validarEditNarch(ENArch);
  end;
end;

procedure TEditarFuenteSintetizador.BBuscarClick(Sender: TObject);
var
  oldArchi: TCaption;
begin
  oldArchi:=ENArch.Text;
  if odEditarFuenteSintetizador.Execute then
  begin
    ENArch.Text := odEditarFuenteSintetizador.FileName;
    if validarEditNarch(ENArch) and not onCambioENArchValido then
      ENArch.Text := oldArchi;
  end;
end;

procedure TEditarFuenteSintetizador.BBuscarDatosHistoricosClick(Sender: TObject);
begin
  if odEditarFuenteSintetizador.Execute then
  begin
    odEditarFuenteSintetizador.FileName :=
      odEditarFuenteSintetizador.FileName;
    EArchiDatosHistoricos.Text := odEditarFuenteSintetizador.FileName;
  end;
end;


procedure TEditarFuenteSintetizador.BAyudaClick(Sender: TObject);
begin
  verdoc(self, TFuenteSintetizadorCEGH);
end;

procedure TEditarFuenteSintetizador.btGraficarPronosticosClick(Sender: TObject);
var
  fcegh: TFuenteSintetizadorCEGH;
  escenario_aux: TEscenarioDePronosticos;

  SeriesCono: TSeriesConoPronostico;
  fechaIniSim, fechaFinSim: TFecha;
  hayCambios, hayErrores: boolean;
  NPasosT: integer;
  Catalogo: TCatalogoReferencias;

begin

  hayErrores := False;
  hayCambios:= False;
  dump_pronosticos(hayCambios, hayErrores);
  if hayCambios then
    self.guardado := False;
  if hayErrores then
    exit;

  if (eNPasosPlot.Text <> '') and (StrToInt(eNPasosPlot.Text)>0) then
    NPasosT := StrToInt(eNPasosPlot.Text)
  else
  begin
    MessageDlg('Info', 'El número de pasos a graficar debe ser mayor a 0.',
      mtInformation, [mbClose],0);
    Exit;
  end;

  Catalogo:= TCatalogoReferencias.Create;
  escenario_aux := escenarioDePronosticos.Create_Clone( Catalogo, 0 ) as TEscenarioDePronosticos;

  fcegh := TFuenteSintetizadorCEGH.Create(capa, ENombre.Text,
    ENArch.Text, EArchiDatosHistoricos.Text, cbSimularUsandoDatosHistoricos.Checked,
    cbSincronizarConHistoricos.Checked, cbSincronizarConSemillaAleatoria.Checked,
    eArchiModeloAuxiliar.Text, cbUsarModeloAuxiliarParaOpt.Checked,
    escenario_aux, cbResumirPromediando.Checked, eurl_get.text );

  fechaIniSim := TFecha.Create_Clone(sala.globs.fechaIniSim);

  fechaFinSim := TFecha.Create_Clone(sala.globs.fechaIniSim);
  fechaFinSim.addHoras(NPasosT * fcegh.durPasoDeSorteoEnHoras);

  SeriesCono := TSeriesConoPronostico.CreateFromSim( 0,
    fcegh, fechaIniSim, fechaFinSim, 100, 0.05, 0.95);

  {$IFDEF CALIBRAR_PRONOSTICOS_TRAZOSXY}
    SeriesCono.plot(self);
  {$EndIf}
  SeriesCono.Free;
  fcegh.Free;
  Catalogo.Free;

end;








procedure TEditarFuenteSintetizador.btGetPronosticosClick(Sender: TObject);
 var
    fcegh: TFuenteSintetizadorCEGH;
    pronosticos_aux: TPronosticos;
    SeriesCono: TSeriesConoPronostico;
    fechaIniSim, fechaFinSim: TFecha;
    hayCambios, hayErrores: boolean;
    NPasosT: integer;
    bProno: TPronostico;

    Catalogo: TCatalogoReferencias;
    esc_pronosticos_aux: TEscenarioDePronosticos;
    fuente: TFuenteSintetizadorCEGH;
    NSeries: integer;
    kSerie: integer;
    aRecCono: TRecConoPronosticos;
    kIni: integer;
    aSerie: TDAOfNReal;
    dtIniSim: TDateTime;
    dtPrimeraMuestra: TDateTime;
    dtEntreMuestras: TDateTime;
    nDatos: integer;
    kDato: integer;

    s: string;
    nueva_guia: TDAOfNReal;

begin

    if cegh = nil then
    begin
      showmessage( 'Necesita guardar y volver abrir este formulario para que esté bien definida la fuente' );
      exit;
    end;
    hayErrores := False;
    hayCambios := False;
    dump_pronosticos(hayCambios, hayErrores);
    if hayCambios then
      self.guardado := False;
    if hayErrores then
      exit;



//  strUrl := 'http://pronos.adme.com.uy/getcono.php?dtIniSim=' + FloatToStr( dtIni);

    bProno:= escenarioDePronosticos.items[0].items[0];

    dtIniSim:= sala.globs.fechaIniSim.dt - (cegh.CalcOrdenDelFiltro-1)* cegh.durPasoDeSorteoEnHoras/24.0 ;
    aRecCono:= TRecConoPronosticos.Create( self.eurl_get.text+'?dtIniSim='+ FloatToStr(sala.globs.fechaIniSim.dt) );
    nDatos:= length( aRecCono.series[0] ) ;
    kIni:=  round( ( dtIniSim - aRecCono.dtPrimeraMuestra )*24 / aRecCono.HorasEntreMuestras ) ;

    // la primer serie del cono es un timestamp ... la salteo
    for kSerie:= 1 to high( aRecCono.series ) do
    begin
      aSerie:= aRecCono.series[kSerie];
      setlength( nueva_guia, length( aSerie ) - kIni );
      for kDato:= kIni  to high( aSerie ) do
         nueva_guia[kDato-kIni]:= aSerie[kDato];
      cambiar_guia(kSerie-1, nueva_guia );
      setlength( nueva_guia, 0 );
    end;


    (**

     Catalogo:= TCatalogoReferencias.Create;
     esc_pronosticos_aux := escenarioDePronosticos.Create_Clone( Catalogo, 0 ) as TEscenarioDePronosticos;// pronosticos.Create_Clone as TPronosticos;

    fcegh := TFuenteSintetizadorCEGH.Create(capa, ENombre.Text,
      ENArch.Text, EArchiDatosHistoricos.Text, cbSimularUsandoDatosHistoricos.Checked,
      cbSincronizarConHistoricos.Checked, cbSincronizarConSemillaAleatoria.Checked,
      eArchiModeloAuxiliar.Text, cbUsarModeloAuxiliarParaOpt.Checked,
      esc_pronosticos_aux, cbResumirPromediando.Checked, eurl_get.text );
    //fcegh:= escenarioDePronosticos.items[0].xcegh;

    fcegh.PrepararMemoria( Catalogo, sala.globs );
    if fcegh.GetPronosticos( sala.globs.fechaIniSim ) then
    begin
       escenarioDePronosticos.Free;
       escenarioDePronosticos:= fcegh.escenarioDePronosticos.Create_Clone( Catalogo, 0 ) as TEscenarioDePronosticos;
       bProno:= escenarioDePronosticos.items[0].items[0];
       guardado:= false;
    end
    else
      showmessage( 'Imposible obtener los pronósticos.' );
    fcegh.Free;

     Catalogo.Free;

    **)

    populate_Pronosticos;
end;



procedure TEditarFuenteSintetizador.CopiadoYPegadoDeterminismos(Sender: TObject;
  var Key: word; Shift: TShiftState);
var
  stringAParsear: string;
begin
  if (((ssCtrl in Shift) and (Key = Ord('V'))) or
    ((ssShift in Shift) and (Key = VK_INSERT))) then
  begin
    if Clipboard.HasFormat(CF_TEXT) then
      ClipBoard.Clear;
    stringAParsear := Clipboard.AsText;
    stringAParsear := StringReplace(stringAParsear, #9, ';', [rfReplaceAll]);
    //Saco los tabs
    stringAParsear := StringReplace(stringAParsear, #13#10, '', [rfReplaceAll]);
    //La porqueria esta viene con un enter al final
    TEdit(Sender).Text := stringAParsear;
    Key := 0;
  end;

  if (((ssCtrl in Shift) and (Key = Ord('C'))) or
    ((ssCtrl in Shift) and (Key = VK_INSERT))) then
  begin
    if Clipboard.HasFormat(CF_TEXT) then
      ClipBoard.Clear;
    stringAParsear := TEdit(Sender).Text;
    stringAParsear := StringReplace(stringAParsear, ';', #9, [rfReplaceAll]);
    //Pongo los tabs
    Clipboard.AsText := stringAParsear;
    Key := 0;
  end;
end;

procedure TEditarFuenteSintetizador.BAyudaTipoEsclavizadorClick(Sender: TObject);
begin
  verdoc(self, TEsclavizador);
end;

initialization
  trx := nil;
end.
