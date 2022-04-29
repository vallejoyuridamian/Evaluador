(****************************************************
Unidad principal del optimizador-simulador  de SimSEE
****************************************************)
unit uSimSEE;

interface

uses
  LResources,
{$IFDEF WINDOWS}
  Windows,
{$ELSE}
  LMessages,
  LCLType,
{$ENDIF}
  SysUtils, Forms,
  Messages, Classes, Graphics, Controls,
  Dialogs, StdCtrls, Buttons, ExtCtrls, Menus, ComCtrls,
  uglobs,
  uSalasDeJuego,
  uSustituirVariablesPlantilla,
  uCosa, xMatDefs,
  uEstados,
{$IFDEF MONITORES}
  uManejadoresDeMonitores,
  uReferenciaMonitor,
  uEventosOptSim,
{$ENDIF}
  uCosaConNombre, uconstantesSimSEE,
  uverdoc, uversiones,
  uInterpreteDeParametros,
  uauxiliares;

type

  { TfSimSEE }

  TfSimSEE = class(TForm)
    BImprimirUnidadesDisp: TButton;
    btEcualizarCF: TButton;
    btLlenarConUltimoFrame: TButton;
    btOptimizarDeterminista: TButton;
    btCrearControladorDeterministico: TButton;
    bt_SimMH: TButton;
    btCargarCFBase: TButton;
    cbPlantillasSimRes3: TComboBox;
    cbObligarDisponibilidad_1_Opt: TCheckBox;
    cbObligarInicioCronicaIncierto_1_sim: TCheckBox;
    cbPublicarSoloVariablesUsadasEnSimRes3: TCheckBox;
    eNHilosForzados: TEdit;
    eEcualizarCF_nPasos: TEdit;
    GBSim: TGroupBox;
    gb_ResultadosGlobales: TGroupBox;
    lbl_nPasos: TLabel;
    Label6: TLabel;
    lbNHilosForzados: TLabel;
    LTEst: TLabel;
    LTTotal: TLabel;
    ETRestanteEstSim: TEdit;
    ETTotal: TEdit;
    LProgrSim: TLabel;
    LProgrCron: TLabel;
    memoResultados: TMemo;
    PBCron: TProgressBar;
    PBSim: TProgressBar;
    GBOpt: TGroupBox;
    btOptimizar: TButton;
    lbl_progreso_optim: TLabel;
    PBOpt: TProgressBar;
    btSimular: TButton;
    GBArchivos: TGroupBox;
    lbl_ArchiSala: TLabel;
    lbl_ArchiMonitores: TLabel;
    eArchiSala: TEdit;
    eArchiMonitores: TEdit;
    btSala: TButton;
    btMonitores: TButton;
    cbSortearOpt: TCheckBox;
    eNCronicasOpt: TEdit;
    lblNCronicasOpt: TLabel;
    GBAlertas: TGroupBox;
    memoAlertas: TMemo;
    LNCronSim: TLabel;
    ENCronSim: TEdit;
    LTOpt: TLabel;
    ETOpt: TEdit;
    lbl_TiempoRestante: TLabel;
    ETRestanteEstOpt: TEdit;
    cbEstabilizarInicio: TCheckBox;
    gbSimRes3: TGroupBox;
    Button1: TButton;
    eArchiCFAux: TEdit;
    bSeleccionarCFAux: TButton;
    btAyudaCF_aux: TButton;
    openDialogCF: TOpenDialog;
    BOptimizarMultiHilo: TButton;
    BImprimirPotenciasFirmes: TButton;
    cbObligarDisponibilidad_1_Sim: TCheckBox;
    bt_Ayuda: TButton;
    gbControlSimulacion: TGroupBox;
    CBFrenarFinAnio: TCheckBox;
    CBFrenarFinPaso: TCheckBox;
    CBFrenarFinCronica: TCheckBox;
    LTiempoPausa: TLabel;
    BPausarContinuar: TButton;
    BDetenerSim: TButton;
    EditTiempoPausa: TEdit;
    BAyudaTiempo: TButton;
    CBEscribirOptActores: TCheckBox;
    lSemillaAleatoriaOpt: TLabel;
    eSemillaAleatoriaOpt: TEdit;
    lSemillaAleatoriaSim: TLabel;
    eSemillaAleatoriaSim: TEdit;
    btCargarCF: TButton;
    eTasaDeActualizacion: TEdit;
    lTasaDeActualizacionOpt: TLabel;
    pSeparador: TPanel;
    eMaxNITERSOpt: TEdit;
    lMaxNItersOpt: TLabel;
    lMaxNItersSim: TLabel;
    eMaxNItersSim: TEdit;
    OpenDialog1: TOpenDialog;
    cbResincronizarSemilla_SimInicioCronica: TCheckBox;
    rbHtml: TRadioButton;
    rbExcel: TRadioButton;

    procedure BPausarContinuarClick(Sender: TObject);
    procedure btCargarCFBaseClick(Sender: TObject);
    procedure btCrearControladorDeterministicoClick(Sender: TObject);
    procedure btEcualizarCFClick(Sender: TObject);
    procedure btLlenarConUltimoFrameClick(Sender: TObject);
    procedure btOptimizarDeterministaClick(Sender: TObject);
    procedure bt_SimMHClick(Sender: TObject);
    procedure CBEscribirOptActoresChange(Sender: TObject);
    procedure EditEnter(Sender: TObject);
    procedure BDetenerSimClick(Sender: TObject);
    procedure EditTiempoPausaExit(Sender: TObject);
    procedure BAyudaTiempoClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure EditTiempoPausaChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btSalaClick(Sender: TObject);
    procedure btMonitoresClick(Sender: TObject);
    procedure cbSortearOptClick(Sender: TObject);
    procedure btCargarCFClick(Sender: TObject);
    {$IFDEF MONITORES}
    procedure eArchiMonitoresExit(Sender: TObject);
    {$ENDIF}
    procedure Button1Click(Sender: TObject);
    procedure btAyudaCF_auxClick(Sender: TObject);
    procedure bSeleccionarCFAuxClick(Sender: TObject);
    procedure btOptimizarClick(Sender: TObject);
    procedure BOptimizarMultiHiloClick(Sender: TObject);
    procedure btSimularClick(Sender: TObject);
    procedure BImprimirPotenciasFirmesClick(Sender: TObject);
    procedure BImprimirUnidadesDispClick(Sender: TObject);
    procedure bt_AyudaClick(Sender: TObject);
    procedure CBEscribirOptActoresClick(Sender: TObject);
  private
    sala: TSalaDeJuego;

{$IFDEF MONITORES}
    manejadorMonitores: TManejadoresDeMonitores;
    cambioArchiMonitores: boolean;
{$ENDIF}
    loQueHabia: string;
    cambioArchiSala: boolean;
    pausa, simulacionEnCurso: boolean;
    tiempoPausa: integer;
    tiempoIniSim, tiempoTotalDeSimulacion, tiempoIniCronica, tStop: NReal;
    tiempoIniOpt, tiempoTotalDeOptimizacion: NReal;

    //Chequea que se haya recibido al menos un parametro que sea un nombre de
    //archivo existente y .ese. Si hay mas de uno, chequea que el 2do sea un nombre
    //de archivo valido y .mon
    function chequearParamsLineaDeComandos: boolean;

    function validarEditInt(Sender: TEdit; min: integer; max: integer): boolean;

    procedure pausarSim;
    procedure reanudarSim;
  public
    procedure resetCtrl;
{$IFDEF MONITORES}
    //Atiende los mensajes de cerrar una ventana TrazosXY
    procedure WM_CLOSETRAZOSXY(var Message: TMessage); message WM_CLOSETRAZOSXY;
    procedure CargarMonitores(archiMonitores: string);
{$ENDIF}

    // Conecta los procedimientos de NOTIFICACION de la sala con
    // las funciones locales definidas en esta unidad para el propósito
    // de dar seguimiento al avance de la Optimización y de la Simulación.
    procedure EnlazarProcedimientos_OptSim(sala: TSalaDeJuego);

    // carga la sala leyendo el nombre de archivo del formulario
    // además maneja la habilitación de botones y etiquetas.
    procedure CargarSala_(nombre_escenario_activo: string);

    // carga la sala con el nombre pasado por parámetro
    procedure CargarSala(archiSala, nombre_escenario_activo: string);


    // Funciones auxiliares para Activar/Desactivar los controles.
    procedure desactivarControlesOpt;
    procedure activarControlesOpt;
    procedure desactivarControlesSim;
    procedure activarControlesSim;

    procedure call_runOptimizar(multihilo: boolean; llenarConFrameFinal: boolean);
    procedure call_runSimular(multihilo: boolean);

  end;


// Procedimientos para monitoreo de la optimización.
procedure Opt_Inicio;
procedure Opt_InicioCalculosDeEtapa;
procedure Opt_InicioCronicaSorteos;
procedure Opt_PrepararPaso_ps;
procedure Opt_FinCronicaSorteos;
procedure Opt_FinCalculosDeEtapa;
procedure Opt_Fin;

// Procedimientos para monitoreo de la simulación.
procedure Sim_Inicio;
procedure Sim_InicioCronica;
procedure Sim_IniPaso;
procedure Sim_FinPaso;
procedure Sim_FinCronica;
procedure Sim_Fin;

var
  fSimSEE: TfSimSEE;

implementation

{$R *.lfm}

procedure TfSimSEE.resetCtrl;
begin
  CBFrenarFinCronica.Checked := False;
  CBFrenarFinPaso.Checked := False;
  CBFrenarFinAnio.Checked := False;
  reanudarSim;
end;

{$IFDEF MONITORES}
procedure TfSimSEE.WM_CLOSETRAZOSXY(var Message: TMessage);
var
  ref: TReferenciaMonitor;
begin
  ref := TReferenciaMonitor(manejadorMonitores.referenciasMonitores[Message.wParam - 1]);
  manejadorMonitores.quitarMonitor(ref);
end;

{$ENDIF}

function TfSimSEE.chequearParamsLineaDeComandos: boolean;
var
  param: string;
  k, n: integer;
begin
  n := paramCount;
  writeln('ParamCount: ', n);
  for k := 1 to n do
    writeln('ParamStr(' + IntToStr(k) + '): ' + ParamStr(k) + ';');

  if ParamCount >= 1 then
  begin
    param := ParamStr(1);
    if not FileExists(param) then
      raise Exception.Create('El archivo: [' + param + '] no existe.(par1)');

    if (ExtractFileExt(param) = '.ese') then
    begin
      if ParamCount >= 2 then
      begin
        param := ParamStr(2);
        if not FileExists(param) then
          raise Exception.Create('El archivo: [' + param + '] no existe.(par2)');

        if (ExtractFileExt(param) = '.mon') then
        begin
          Result := True;
        end
        else
        begin
          raise Exception.Create(
            'El Archivo De Monitores Indicado No Es Valido (par2): [' + param + ']');
          Result := False;
        end;
      end
      else
        Result := True;
    end
    else
    begin
      raise Exception.Create('El Archivo De Sala Indicado No Es Valido (par1): [' +
        param + ']');
      Result := False;
    end;
  end
  else
  begin
    raise Exception.Create('No Se Indico Ningun Archivo');
    Result := False;
  end;
end;


{$IFDEF MONITORES}
procedure TfSimSEE.eArchiMonitoresExit(Sender: TObject);
begin
  if (eArchiMonitores.Text = '') and (manejadorMonitores <> nil) then
  begin
    manejadorMonitores.Free;
    manejadorMonitores := TManejadoresDeMonitores.Create(0, self.sala);
  end;
end;

{$ENDIF}

function TfSimSEE.validarEditInt(Sender: TEdit; min: integer; max: integer): boolean;
var
  valor: integer;
begin
  try
    begin
      if Sender.Text = '' then
      begin
        Sender.Text := '0';
        Result := True;
      end
      else
      begin
        valor := StrToInt(Sender.Text);
        if (valor < min) or (valor > max) then
          raise EConvertError.Create('Fuera de Rango');
        Result := True;
      end;
    end
  except
    on EConvertError do
    begin
      ShowMessage('El valor ingresado debe ser numérico y estar entre ' +
        IntToStr(min) + ' y ' + IntToStr(max));
      Sender.Text := loQueHabia;
      Sender.SetFocus;
      Result := False;
    end
  end;
end;

procedure TfSimSEE.pausarSim;
begin
  pausa := True;
  tiempoPausa := StrToInt(EditTiempoPausa.Text);
  BPausarContinuar.Caption := 'Continuar';
  tStop := Now();
end;

procedure TfSimSEE.reanudarSim;
var
  tiempoDetenido: NReal;
begin
  pausa := False;
  BPausarContinuar.Caption := 'Pausar';
  tiempoDetenido := Now() - tStop;
  tiempoIniCronica := tiempoIniCronica + tiempoDetenido;
  tiempoIniSim := tiempoIniSim + tiempoDetenido;
end;

procedure Alerta(const s: string);
begin
  fSimSEE.memoAlertas.Lines.Append(s);
end;

procedure TfSimSEE.EnlazarProcedimientos_OptSim(sala: TSalaDeJuego);
begin
  sala.globs.procNot_opt_InicioOptimizacion := Opt_Inicio;
  sala.globs.procNot_opt_InicioCalculosDeEtapa := Opt_InicioCalculosDeEtapa;
  sala.globs.procNot_opt_InicioCronicaSorteos := Opt_InicioCronicaSorteos;
  sala.globs.procNot_opt_PrepararPaso_ps := Opt_PrepararPaso_ps;
  sala.globs.procNot_opt_FinCronicaSorteos := Opt_FinCronicaSorteos;
  sala.globs.procNot_opt_FinCalculosDeEtapa := Opt_FinCalculosDeEtapa;
  sala.globs.procNot_opt_FinOptimizacion := Opt_Fin;

  sala.globs.procNot_InicioSimulacion := Sim_Inicio;
  sala.globs.procNot_InicioCronica := Sim_InicioCronica;
  sala.globs.procNot_InicioPaso := Sim_IniPaso;
  sala.globs.procNot_FinPaso := Sim_FinPaso;
  sala.globs.procNot_FinCronica := Sim_FinCronica;
  sala.globs.procNot_FinSimulacion := Sim_Fin;

  sala.globs.setProcAlerta(Alerta);
end;

procedure TfSimSEE.CargarSala(archiSala, nombre_escenario_activo: string);
begin
  ETRestanteEstSim.Text := '';
  ETRestanteEstOpt.Text := '';
  ETOpt.Text := '';
  ETTotal.Text := '';

  if Sala <> nil then
  begin
    Sala.Free;
    sala := nil;
  end;

  try
    sala := TSalaDeJuego.cargarSala(0, archiSala, nombre_escenario_activo, True);
  except
    on E: Exception do
    begin
      ShowMessage('CargarSala, Error:' + #13 + E.Message);
      raise;
    end;
  end;

  if fileExists(sala.archiCF_bin) then
    btCargarCF.Enabled := True
  else
    btCargarCF.Enabled := False;
end;


{$IFDEF MONITORES}
procedure TfSimSEE.CargarMonitores(archiMonitores: string);
begin
  if manejadorMonitores <> nil then
  begin
    manejadorMonitores.Free;
    manejadorMonitores := nil;
  end;

  try
    manejadorMonitores := TManejadoresDeMonitores.CargarManejadorDeMonitores(
      archiMonitores, True, self.sala);
  except
    on E: Exception do
    begin
      ShowMessage('Se Encontro El Siguiente Error:' + #13 + E.Message);
      //  PostQuitMessage(0);
    end;
  end;
end;

{$ENDIF}

procedure Sim_Inicio;
begin
  fSimSEE.PBCron.Step := 1;
  fSimSEE.PBCron.Min := 0;
  fSimSEE.PBCron.Max := fSimSEE.Sala.globs.calcNPasosSim;
  fSimSEE.PBSim.Min := 0;
  fSimSEE.PBSim.Max := fSimSEE.Sala.globs.NCronicasSim;
  fSimSEE.PBSim.Position := 0;

  fSimSEE.PBSim.Step := 1;
  fSimSEE.ETTotal.Text := '0';
  fSimSEE.simulacionEnCurso := True;
  fSimSEE.tiempoIniSim := now();
{$IFDEF MONITORES}
  try
    fSimSEE.manejadorMonitores.resolverReferenciasMonitores(
      TResolverMonitoresSimulacion);
  except
    on E: EMonitorException do
      ShowMessage('Se Encontraron Los Siguientes Errores:' + #13 +
        e.Message + #13 +
        'La Simulación Continuara Sin Monitorear Los Actores/Variables Sin Resolver.');
  end;
  fSimSEE.manejadorMonitores.notificarEvento(E_Sim_Inicio);
{$ENDIF}
end;

procedure Sim_InicioCronica;
begin
  fSimSEE.PBCron.Position := 0;
  fSimSEE.tiempoIniCronica := now();
{$IFDEF MONITORES}
  fSimSEE.manejadorMonitores.notificarEvento(E_Sim_InicioCronica);
{$ENDIF}
end;

procedure Sim_IniPaso;
begin
{$IFDEF MONITORES}
  uManejadoresDeMonitores.notifyIniPaso;
{$ENDIF}
end;

procedure Sim_FinPaso;
var
  i, tpausa: integer;
begin
  if fSimSEE.CBFrenarFinPaso.Checked or fSimSEE.pausa then
  begin
    if not fSimSEE.pausa then
      fSimSEE.pausarSim;
    while (fSimSEE.pausa) and (not fSimSEE.Sala.globs.abortarSim) do
    begin
      application.ProcessMessages;
      tpausa := fSimSEE.tiempoPausa;
      if tpausa <> 0 then
      begin
        if tpausa > 100 then
        begin
          for i := 0 to tpausa div 100 do
          begin
            Sleep(100);
            Application.ProcessMessages;
          end;
        end
        else
          Sleep(tpausa);
        fSimSEE.BPausarContinuarClick(fSimSEE.BPausarContinuar);
      end
      else
        sleep(200);
    end;
  end;
  fSimSEE.PBCron.stepit;
{$IFDEF MONITORES}
  fSimSEE.manejadorMonitores.notificarEvento(E_Sim_FinPaso);
{$ENDIF}
  application.ProcessMessages;
end;

procedure Sim_FinCronica;
var
  i, tpausa: integer;
  segsPorCronica: double;
begin
  fSimSEE.tiempoTotalDeSimulacion := (now() - fSimSEE.tiempoIniSim) * 24 * 3600;
  segsPorCronica := fSimSEE.tiempoTotalDeSimulacion / fSimSEE.sala.globs.kCronica;
  fSimSEE.ETRestanteEstSim.Text :=
    FloatToStrF(segsPorCronica * (fSimSEE.sala.globs.NCronicasSim -
    fSimSEE.sala.globs.kCronica), ffFixed, 8, 3);
  fSimSEE.ETTotal.Text := FloatToStrF(fSimSEE.tiempoTotalDeSimulacion, ffFixed, 8, 3);

  if fSimSEE.CBFrenarFinCronica.Checked or fSimSEE.pausa then
  begin
    if not fSimSEE.pausa then
      fSimSEE.pausarSim;
    while (fSimSEE.pausa) and (not fSimSEE.Sala.globs.abortarSim) do
    begin
      application.ProcessMessages;
      tpausa := fSimSEE.tiempoPausa;
      if tpausa <> 0 then
      begin
        if tpausa > 100 then
        begin
          for i := 0 to tpausa div 100 do
          begin
            Sleep(100);
            Application.ProcessMessages;
          end;
        end
        else
          Sleep(tpausa);
        fSimSEE.BPausarContinuarClick(fSimSEE.BPausarContinuar);
      end
      else
        sleep(200);
    end;
  end;

  fSimSEE.tiempoIniCronica := now();

  fSimSEE.PBSim.stepit;
{$IFDEF MONITORES}
  fSimSEE.manejadorMonitores.notificarEvento(E_Sim_FinCronica);
{$ENDIF}
  Application.ProcessMessages;

end;

procedure Sim_Fin;
begin
{$IFDEF MONITORES}
  fSimSEE.manejadorMonitores.notificarEvento(E_Sim_Fin);
{$ENDIF}
  fSimSEE.resetCtrl;
  fSimSEE.ETRestanteEstSim.Text := '0';
  fSimSEE.simulacionEnCurso := False;
end;

procedure Opt_Inicio;
begin
  fSimSEE.PBOpt.Min := 1;
  fSimSEE.PBOpt.Max := fSimSEE.Sala.globs.calcNPasosOpt + 1;
  fSimSEE.PBOpt.Position := 1;
  fSimSEE.PBOpt.Step := 1;
  fSimSEE.PBCron.Position := 0;
  fSimSEE.PBSim.Position := 0;
  fSimSEE.simulacionEnCurso := True;
{$IFDEF MONITORES}
  try
    fSimSEE.manejadorMonitores.resolverReferenciasMonitores(
      TResolverMonitoresOptimizacion);
  except
    on E: EMonitorException do
      ShowMessage('Se Encontraron Los Siguientes Errores:' + #13 +
        e.Message + #13 +
        'La Simulación Continuara Sin Monitorear Los Actores/Variables Sin Resolver.');
  end;
  fSimSEE.manejadorMonitores.notificarEvento(E_Opt_Inicio);
{$ENDIF}
end;

procedure Opt_InicioCalculosDeEtapa;
begin
{$IFDEF MONITORES}
  fSimSEE.manejadorMonitores.notificarEvento(E_Opt_InicioCalculosEtapa);
{$ENDIF}
end;

procedure Opt_InicioCronicaSorteos;
begin
{$IFDEF MONITORES}
  fSimSEE.manejadorMonitores.notificarEvento(E_Opt_InicioCronicaSorteos);
{$ENDIF}
end;

procedure Opt_PrepararPaso_ps;
begin
{$IFDEF MONITORES}
  fSimSEE.manejadorMonitores.notificarEvento(E_Opt_PrepararPaso_ps);
{$ENDIF}
end;

procedure Opt_FinCronicaSorteos;
begin
{$IFDEF MONITORES}
  fSimSEE.manejadorMonitores.notificarEvento(E_Opt_FinCronicaSorteos);
{$ENDIF}
end;


procedure Opt_FinCalculosDeEtapa;
var
  segsPorEtapa: NReal;
begin
{$IFDEF MONITORES}
  fSimSEE.manejadorMonitores.notificarEvento(E_Opt_FinCalculosEtapa);
{$ENDIF}
  fSimSEE.PBOpt.stepit;
  fSimSEE.tiempoTotalDeOptimizacion := (now() - fSimSEE.tiempoIniOpt) * 24 * 3600;
  fSimSEE.ETOpt.Text := FloatToStrF(fSimSEE.tiempoTotalDeOptimizacion, ffFixed, 8, 2);
  segsPorEtapa := fSimSEE.tiempoTotalDeOptimizacion /
    (fSimSEE.sala.globs.NPasos - fSimSEE.sala.globs.kPaso_Opt + 1);
  fSimSEE.ETRestanteEstOpt.Text :=
    FloatToStrF(segsPorEtapa * fSimSEE.sala.globs.kPaso_Opt, ffFixed, 8, 2);
  Application.ProcessMessages;
end;

procedure Opt_Fin;
begin
{$IFDEF MONITORES}
  fSimSEE.manejadorMonitores.notificarEvento(E_Opt_Fin);
{$ENDIF}
  fSimSEE.simulacionEnCurso := False;
end;

procedure TfSimSEE.BPausarContinuarClick(Sender: TObject);
begin
  if pausa then
    reanudarSim
  else
    pausarSim;
end;

procedure TfSimSEE.btCargarCFBaseClick(Sender: TObject);
begin
  GBSim.Visible := False;
  desactivarControlesOpt;

  if sala.globs.CF <> nil then
    sala.globs.CF.Free;

(***
rch@201411091951

Esto es para que Vates funcione colgado de un CF de una sala
que se usó para valorizar los recursos.

También puede servir para testear en el caso del proyecto de la
regasificadora el Optimizar con paso Mensual o Quincenal y luego
simular con paso Semanal.

ojo , ahora para probar copiar a mano el CF de la corrida BASE
en la carpeta de la Sala que se cuelga de la base y llamar al CF
CFBase_.bin para que funcione el cargar.

Después vamos a poner en la Sala un indicador de que está COLGADA y que
por tanto no corresponde OPTIMIZAR y tendrá un LINK a la sala BASE y se
colgará de su CF.bin
 ****)

  Sala.globs.CF := TAdminEstados_SobreMuestreado.CreateLoadFromArchi(
    sala.dirResultadosCorrida + 'CFBase_' + sala.EscenarioActivo.nombre +
    '.bin', sala.globs.fechaIniSim.dt, sala.globs.fechaFinSim.dt,
    sala.globs.HorasDelPaso);

  activarControlesOpt;

  GBSim.Visible := True;
end;

procedure TfSimSEE.btCrearControladorDeterministicoClick(Sender: TObject);
begin
{
// La idea aquí, es crear un controlador determinístico para que
sirva de base para un Optimización-Determinístca que mejore
la solución.
// Hay que guardar el FRAME final de la úlitma etapa de CF(X) y
también el valor esperado de dCF/dX durante el conjunto de crónicas
a simular.
}

end;

procedure TfSimSEE.btEcualizarCFClick(Sender: TObject);
var
  nPasos: integer;
  oldCursor: TCursor;
begin
  oldCursor := Cursor;
  Cursor := crHourGlass;
  btEcualizarCF.Enabled := False;
  nPasos := StrToInt(eEcualizarCF_nPasos.Text);
  sala.globs.CF.Ecualizar(nPasos);
  Cursor := oldCursor;
end;

procedure TfSimSEE.btLlenarConUltimoFrameClick(Sender: TObject);
begin
  call_runOptimizar(False, True);
end;

procedure TfSimSEE.btOptimizarDeterministaClick(Sender: TObject);
begin
  sala.globs.Deterministico := True;
  sala.OptimizarDeterministica;
  GBSim.Visible := True;
end;

procedure TfSimSEE.bt_SimMHClick(Sender: TObject);
begin
  call_runSimular(True);
end;

procedure TfSimSEE.CBEscribirOptActoresChange(Sender: TObject);
begin
  //if Self.CBEscribirOptActores.Checked then
  //  self.BOptimizarMultiHilo.Enabled := False
  //else
  //  self.BOptimizarMultiHilo.Enabled := True;
end;

procedure TfSimSEE.EditEnter(Sender: TObject);
begin
  loQueHabia := TEdit(Sender).Text;
end;

procedure TfSimSEE.BDetenerSimClick(Sender: TObject);
begin
  reanudarSim;
  Sala.globs.abortarSim := True;
  //  ETRestanteEst.Text := '0';
end;

procedure TfSimSEE.btOptimizarClick(Sender: TObject);
begin
  call_runOptimizar(False, False);
end;

procedure TfSimSEE.BOptimizarMultiHiloClick(Sender: TObject);
begin
  call_runOptimizar(True, False);
end;

procedure TfSimSEE.call_runOptimizar(multihilo: boolean; llenarConFrameFinal: boolean);
begin
{$IFDEF MONITORES}
  if manejadorMonitores = nil then
    manejadorMonitores := TManejadoresDeMonitores.Create(0, sala);
  btMonitores.Enabled := False;
{$ENDIF}
  GBSim.Visible := False;
  desactivarControlesOpt;
  sala.globs.SortearOpt := cbSortearOpt.Checked;
  sala.estabilizarInicio := cbEstabilizarInicio.Checked;
  sala.escribirOptActores := CBEscribirOptActores.Checked;
  sala.globs.TasaDeActualizacion := StrToFloat(eTasaDeActualizacion.Text);
  sala.globs.NCronicasOpt := StrToInt(eNCronicasOpt.Text);
  sala.globs.NMAX_ITERACIONESDELPASO_OPT := StrToInt(self.eMaxNITERSOpt.Text);

  sala.globs.ObligarDisponibilidad_1_Sim := cbObligarDisponibilidad_1_Sim.Checked;
  sala.globs.ObligarInicioCronicaIncierto_1_Sim :=
    cbObligarInicioCronicaIncierto_1_sim.Checked;
  sala.globs.ObligarDisponibilidad_1_Opt := cbObligarDisponibilidad_1_Opt.Checked;
  sala.globs.ObligarDisponibilidad_1_ := sala.globs.ObligarDisponibilidad_1_Opt;

  sala.globs.publicarSoloVariablesUsadasEnSimRes3 :=
    cbPublicarSoloVariablesUsadasEnSimRes3.Checked;

  EnlazarProcedimientos_OptSim(sala);
  sala.globs.semilla_inicial_opt := StrToInt(eSemillaAleatoriaOpt.Text);

  tiempoIniOpt := now();

  if multihilo then
    runOptimizar(sala, StrToInt(eNHilosForzados.Text), -1, llenarConFrameFinal)
  else
    runOptimizar(sala, 0, -1, llenarConFrameFinal);


  if sala.globs.EstadoDeLaSala <> CES_OPTIMIZACION_ABORTADA then
  begin
    self.ETOpt.Text := FloatToStrF((now() - tiempoIniOpt) * 24 * 3600, ffFixed, 8, 3);

    if sala.globs.CF <> nil then
      sala.globs.CF.StoreInArchi(sala.ArchiCF_bin);

    activarControlesOpt;
    if GBOpt.Visible then
      GBSim.Visible := True;
  end;
  btSala.Enabled := True;
{$IFDEF MONITORES}
  btMonitores.Enabled := True;
{$ENDIF}
end;

procedure TFSimSEE.call_runSimular(multihilo: boolean);
begin
  gbSimRes3.Visible := False;
{$IFDEF MONITORES}
  if self.eArchiMonitores.Text <> '' then
    CargarMonitores(self.eArchiMonitores.Text);
  if manejadorMonitores = nil then
    manejadorMonitores := TManejadoresDeMonitores.Create(0, sala);
{$ENDIF}
  desactivarControlesSim;

  EnlazarProcedimientos_OptSim(sala);

  sala.globs.abortarSim := False;
  sala.globs.NCronicasSim := StrToInt(ENCronSim.Text);

  sala.globs.semilla_inicial_sim := StrToInt(eSemillaAleatoriaSim.Text);
  sala.globs.ObligarDisponibilidad_1_Sim := cbObligarDisponibilidad_1_Sim.Checked;
  sala.globs.ObligarInicioCronicaIncierto_1_Sim :=
    cbObligarInicioCronicaIncierto_1_sim.Checked;
  sala.globs.ObligarDisponibilidad_1_Opt := cbObligarDisponibilidad_1_Opt.Checked;
  sala.globs.ObligarDisponibilidad_1_ := sala.globs.ObligarDisponibilidad_1_Sim;
  sala.globs.NMAX_ITERACIONESDELPASO_SIM := StrToInt(self.eMaxNItersSim.Text);
  sala.RandSeed_SincronizarAlInicioDeCadaCronica :=
    self.cbResincronizarSemilla_SimInicioCronica.Checked;

  sala.archivoCFAux.archi := eArchiCFAux.Text;

  application.ProcessMessages;

  sala.Clear_ResultadosSim;

  if multihilo then
    runSimular(sala, -1)
  else
    runSimular(sala, 0);



  memoResultados.Lines.Add( 'CF_VE[MUSD]: '+ FloatToStrF( sala.VE_CF, ffFixed, 12, 2 ) );
  memoResultados.Lines.Add( 'CF_VaR(5%)[MUSD]: '+ FloatToStrF( sala.VaR05_CF, ffFixed, 12, 2 ));
  memoResultados.Lines.Add( 'CF_CVaR(5%)[MUSD]: '+ FloatToStrF( sala.CVaR05_CF, ffFixed, 12, 2 ));

  activarControlesSim;

  if sala.globs.EstadoDeLaSala = CES_SIMULACION_TERMINADA then
  begin
    //  cbPlantillasSimRes3.Items.AddStrings( sala.listaPlantillasSimRes3.lista_activas );
    cbPlantillasSimRes3.Items := sala.listaPlantillasSimRes3.lista_activas;
    if cbPlantillasSimRes3.Items.Count > 0 then
    begin
      cbPlantillasSimRes3.ItemIndex := 0;
    end;
    gbSimRes3.Visible := True;
  end
  else
    ShowMessage('Simlación ABORTADA');
end;


procedure TfSimSEE.desactivarControlesOpt;
begin
  BImprimirPotenciasFirmes.Enabled := False;
  BImprimirUnidadesDisp.Enabled := False;
  btSala.Enabled := False;
  btMonitores.Enabled := False;
  btOptimizar.Enabled := False;
  eArchiSala.ReadOnly := True;
  eArchiMonitores.ReadOnly := True;
  BOptimizarMultiHilo.Enabled := False;
  cbSortearOpt.Enabled := False;
  cbEstabilizarInicio.Enabled := False;
  CBEscribirOptActores.Enabled := False;
  btCargarCF.Enabled := False;
{  lTasaDeActualizacionOpt.Enabled:= false;
  lblNCronicasOpt.Enabled:= false;
  lSemillaAleatoriaOpt.Enabled:= False;
  eTasaDeActualizacion.Enabled:= false;
  eNCronicasOpt.Enabled:= false;
  eSemillaAleatoriaOpt.Enabled:= false;}
  eTasaDeActualizacion.ReadOnly := True;
  eNCronicasOpt.ReadOnly := True;
  eSemillaAleatoriaOpt.ReadOnly := True;
end;

procedure TfSimSEE.activarControlesOpt;
begin
  BImprimirPotenciasFirmes.Enabled := True;
  BImprimirUnidadesDisp.Enabled := True;
  btSala.Enabled := True;
  btMonitores.Enabled := True;
  eArchiSala.ReadOnly := False;
  eArchiMonitores.ReadOnly := False;
  btOptimizar.Enabled := True;
  BOptimizarMultiHilo.Enabled := True;
  cbSortearOpt.Enabled := True;
  cbEstabilizarInicio.Enabled := True;
  CBEscribirOptActores.Enabled := True;
  btCargarCF.Enabled := True;
{  lTasaDeActualizacionOpt.Enabled:= true;
  lblNCronicasOpt.Enabled:= true;
  lSemillaAleatoriaOpt.Enabled:= true;
  eTasaDeActualizacion.Enabled:= true;
  eNCronicasOpt.Enabled:= true;
  eSemillaAleatoriaOpt.Enabled:= true;}
  eTasaDeActualizacion.ReadOnly := False;
  eNCronicasOpt.ReadOnly := False;
  eSemillaAleatoriaOpt.ReadOnly := False;
end;

procedure TfSimSEE.desactivarControlesSim;
begin
  desactivarControlesOpt;
  btSimular.Enabled := False;
  cbObligarDisponibilidad_1_Sim.Enabled := False;
  cbObligarInicioCronicaIncierto_1_sim.Enabled := False;
  cbPublicarSoloVariablesUsadasEnSimRes3.Enabled := False;
  LNCronSim.Enabled := False;
  ENCronSim.Enabled := False;
  lSemillaAleatoriaSim.Enabled := False;
  eSemillaAleatoriaSim.Enabled := False;
  bSeleccionarCFAux.Enabled := False;
end;

procedure TfSimSEE.activarControlesSim;
begin
  activarControlesOpt;
  cbObligarDisponibilidad_1_Sim.Enabled := True;
  cbObligarInicioCronicaIncierto_1_sim.Enabled := True;
  cbPublicarSoloVariablesUsadasEnSimRes3.Enabled := True;
  btSimular.Enabled := True;
  LNCronSim.Enabled := True;
  ENCronSim.Enabled := True;
  lSemillaAleatoriaSim.Enabled := True;
  eSemillaAleatoriaSim.Enabled := True;
  bSeleccionarCFAux.Enabled := True;
end;

procedure TfSimSEE.EditTiempoPausaExit(Sender: TObject);
begin
  validarEditInt(TEdit(Sender), 0, MAXINT);
end;

procedure TfSimSEE.BAyudaTiempoClick(Sender: TObject);
begin
  verdoc(self, 'simulador-mspausa', '');
end;

procedure TfSimSEE.FormCloseQuery(Sender: TObject; var CanClose: boolean);
var
  res: boolean;
begin
  CanClose := True;
  if sala <> nil then
  begin
    if sala.globs.EstadoDeLaSala in [CES_OPTIMIZANDO, CES_SIMULANDO] then
    begin
      pausarSim;
      case sala.globs.EstadoDeLaSala of
        CES_OPTIMIZANDO:
          res := (Application.MessageBox(
            'La Optimización No Ha Terminado. ¿Desea Salir De Todas Formas?',
            'Confirmar Salida', MB_YESNO or MB_ICONEXCLAMATION) = idYes);
        CES_SIMULANDO:
          res := (Application.MessageBox(
            'La Simulación No Ha Terminado. ¿Desea Salir De Todas Formas?',
            'Confirmar Salida', MB_YESNO or MB_ICONEXCLAMATION) = idYes);
        else
          res := False;
      end;
      if res then
      begin
        Sala.globs.abortarSim := True;
        CanClose := False;
        GBArchivos.Visible := False;
        GBOpt.Visible := False;
        GBSim.Visible := False;
      end
      else
      begin
        CanClose := False;
        reanudarSim;
      end;
    end;
  end
  else
    CanClose := True;
  if CanClose then
  begin
    if Sala <> nil then
    begin
      Sala.Free;
      Sala := nil;
    end;
    {$IFDEF MONITORES}
    if manejadorMonitores <> nil then
    begin
      ManejadorMonitores.Free;
      ManejadorMonitores := nil;
    end;
    {$ENDIF}
  end;
end;

procedure TfSimSEE.btSimularClick(Sender: TObject);
begin
  call_runSimular(False);
end;

procedure TfSimSEE.Button1Click(Sender: TObject);
var
  sustitutor: TSustituirVariablesPlantilla;
begin
  sustitutor := TSustituirVariablesPlantilla.Create(0);
  try
    sustitutor.ejecutarSimRes3(
      cbPlantillasSimRes3.Text, sala,
      sala.EscenarioActivo.nombre,
      StrToInt(eSemillaAleatoriaSim.Text), rbHtml.Checked);
  except
    on e: Exception do
      ShowMessage(e.Message);
  end;
  sustitutor.Free;
end;

procedure TfSimSEE.bSeleccionarCFAuxClick(Sender: TObject);
begin
  if openDialogCF.Execute then
    eArchiCFAux.Text := openDialogCF.FileName;
end;

procedure TfSimSEE.btAyudaCF_auxClick(Sender: TObject);
begin
  verdoc(self, 'simulador-cfauxiliar', '');
end;

procedure TfSimSEE.bt_AyudaClick(Sender: TObject);
begin
  verdoc(self, 'simulador-pantallaprincipal', '');
end;

procedure TfSimSEE.BImprimirPotenciasFirmesClick(Sender: TObject);
begin
  sala.ImprimirPotenciasFirmes;
end;

procedure TfSimSEE.BImprimirUnidadesDispClick(Sender: TObject);
begin
  sala.ImprimirUnidadesInstaladas;
end;



procedure TfSimSEE.EditTiempoPausaChange(Sender: TObject);
begin
  if TEdit(Sender).Text = '' then
    TEdit(Sender).Text := '0';
end;

procedure TfSimSEE.FormCreate(Sender: TObject);
var
  interpreteDeParametros: TInterpreteParametros;
  nombre_escenario: string;

begin
  ChDir(ExtractFilePath(ParamStr(0)));
  crearDirectorios;
  self.top := 20;
  self.left := 50;

  self.Caption := AnsiToUtf8('SimSEE (v' + uversiones.vSimSEESimulador_ + ')');


  memoAlertas.Lines.add(self.Caption);
  memoAlertas.Lines.add(CONDITIONAL_DEFINES);

  sala := nil;
{$IFDEF MONITORES}
  manejadorMonitores := nil;
{$ENDIF}
{$IFNDEF ESTABILIZAR_FRAMEINICIAL}
  cbEstabilizarInicio.Visible := False;
{$ENDIF}

  cambioArchiSala := True;
  GBOpt.Visible := False;
  GBSim.Visible := False;

  interpreteDeParametros := TInterpreteParametros.Create(False);

  eArchiSala.Text := interpreteDeParametros.valStr('sala');
  if eArchiSala.Text = '' then
    OpenDialog1.InitialDir := getDir_Corridas;

  eArchiMonitores.Text := interpreteDeParametros.valStr('monitores');


  nombre_escenario := interpreteDeParametros.valStr('escenario');
  if nombre_escenario = '' then
    nombre_escenario := '__principal__';

  interpreteDeParametros.Free;

  if eArchiSala.Text <> '' then
    CargarSala_(nombre_escenario);

{$IFDEF MONITORES}
  eArchiMonitores.Enabled := True;
  self.btMonitores.Enabled := True;
  if eArchiMonitores.Text <> '' then
    CargarMonitores(eArchiMonitores.Text);
{$ELSE}
  eArchiMonitores.Enabled := False;
  self.btMonitores.Enabled := False;
{$ENDIF}
end;

procedure TfSimSEE.cargarSala_(nombre_escenario_activo: string);
var
  carpetaSala: string;
begin
  cambioArchiSala := True;
  GBOpt.Visible := False;

  try
    carpetaSala := extractFilePath(eArchiSala.Text);
    chdir(carpetaSala);
    CargarSala(eArchiSala.Text, nombre_escenario_activo);
  except
    begin
      MessageDlg('Error cargando la Sala', mtError, [mbOK], 0);
      exit;
    end;
  end;

  memoAlertas.Clear;
  cbSortearOpt.Checked := sala.globs.SortearOpt;
  cbEstabilizarInicio.Checked := sala.estabilizarInicio;
  CBEscribirOptActores.Checked := sala.escribirOptActores;
  eNCronicasOpt.Text := IntToStr(sala.globs.NCronicasOpt);
  eMaxNITERSOpt.Text := IntToStr(sala.globs.NMAX_ITERACIONESDELPASO_OPT);
  ENCronSim.Text := IntToStr(sala.globs.NCronicasSim);
  eTasaDeActualizacion.Text :=
    FloatToStrF(sala.globs.TasaDeActualizacion, ffGeneral, 6, 3);
  cbObligarDisponibilidad_1_Sim.Checked := sala.globs.ObligarDisponibilidad_1_Sim;
  cbObligarInicioCronicaIncierto_1_sim.Checked :=
    sala.globs.ObligarInicioCronicaIncierto_1_Sim;
  cbObligarDisponibilidad_1_Opt.Checked := sala.globs.ObligarDisponibilidad_1_Opt;

  eSemillaAleatoriaOpt.Text := IntToStr(sala.globs.semilla_inicial_opt);

  cbPublicarSoloVariablesUsadasEnSimRes3.Checked :=
    sala.globs.publicarSoloVariablesUsadasEnSimRes3;

  eMaxNItersSim.Text := IntToStr(sala.globs.NMAX_ITERACIONESDELPASO_SIM);

  eSemillaAleatoriaSim.Text := IntToStr(sala.globs.semilla_inicial_sim);
  cbSortearOptClick(Self);


  GBOpt.Visible := True;
  GBSim.Visible := False;

  eArchiCFAux.Text := sala.archivoCFAux.archi;

end;

procedure TfSimSEE.CBEscribirOptActoresClick(Sender: TObject);
begin
  if CBEscribirOptActores.Checked then
    Self.BOptimizarMultiHilo.Enabled := False
  else
    Self.BOptimizarMultiHilo.Enabled := True;
end;

procedure TfSimSEE.btSalaClick(Sender: TObject);
begin
  OpenDialog1.FilterIndex := 1;
  if OpenDialog1.Execute then
  begin
    eArchiSala.Text := OpenDialog1.FileName;

    CargarSala_('__principal__');

    eArchiCFAux.Text := sala.archivoCFaux.archi;
    PBSim.Position := 0;
    PBOpt.Position := 0;
    self.Caption := 'SimSEE ' + eArchiSala.Text;
{$IFDEF MONITORES}
    if manejadorMonitores <> nil then
      manejadorMonitores.sala := sala;
{$ENDIF}
  end;
end;

procedure TfSimSEE.btMonitoresClick(Sender: TObject);
begin
{$IFDEF MONITORES}
  OpenDialog1.FilterIndex := 2;
  if OpenDialog1.Execute then
  begin
    eArchiMonitores.Text := OpenDialog1.FileName;
    cambioArchiMonitores := True;
    cargarMonitores(eArchiMonitores.Text);
  end;
{$ELSE}
  ShowMessage('Esta versión del simulador no ha sido compilada con monitores.' +
    'Para habilitarlos recompile los codigos fuente con el conditional' +
    'define MONITORES');
{$ENDIF}
end;

procedure TfSimSEE.cbSortearOptClick(Sender: TObject);
begin
  if cbSortearOpt.Checked then
  begin
    eNCronicasOpt.Enabled := True;
    lblNCronicasOpt.Enabled := True;
  end
  else
  begin
    eNCronicasOpt.Enabled := False;
    lblNCronicasOpt.Enabled := False;
  end;
end;


procedure TfSimSEE.btCargarCFClick(Sender: TObject);
begin
  GBSim.Visible := False;
  desactivarControlesOpt;
  if sala.CargarCFFrom_bin(True) then
  begin
    activarControlesOpt;
    GBSim.Visible := True;
  end;
end;


initialization
{$I uSimSEE.lrs}
end.
