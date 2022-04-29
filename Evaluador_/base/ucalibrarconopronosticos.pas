{+doc
+NOMBRE: ucalibrarconopronosticos
+CREACION: 2011-11-22
+AUTORES: rch
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO:procedimiento de calibración de un cono de pronosticos
+PROYECTO:SimSEE

+REVISION:
+AUTOR:
+DESCRIPCION:
-doc}
unit ucalibrarconopronosticos;

{$mode delphi}

interface

uses
{$IFDEF CALIBRAR_PRONOSTICOS_TRAZOSXY}
  Graphics, utrazosxy,
{$ENDIF}
  uauxiliares, Math, Dialogs,
  umodelosintcegh, upronostico, xmatdefs, ufechas,
  autoesca,  ucosaConNombre,
  Classes, SysUtils, matreal, uFuenteSintetizador, usalasdejuego;


(*+doc
Este procedimiento recibe un modelo CEGH y una descripción de los pronosticos asociados
a sus bornes de salida tal como es utilizado porp las FuentesSintetizador.
Si bien los pronosticos pueden especificar la Probabilidad de Excedencia de la GUIA este
procedimiento ignora dicha PE y calcula los vectores "sesgos" y "factor" para lograr
un cono centrado sobre la guía. Se entiende por "Centrado" que la guía tenga probabilidad
de excedencia 50% en el cono.
-doc*)
procedure CalibrarConoCentrado(cegh: TModeloCEGH;
  escenarios: TEscenarioDePronosticos; fechaIniSim: TFecha);

type
(*+doc
Esta clase permite calcular las series de un cono de pronóstico dado un modelo CEGH, un pronótico para una fecha
de inicio. La determinación del cono se hace mediante una simulación de la salida del CEGH de la cantidad de
crónicas especificadas en NCronicas. La simulación se realiza desde FechaIniSim y se finaliza en FechaFinSim
-doc*)
  TSeriesConoPronostico = class
    NPasosT: integer;

    speInf, spe50, speSup: TMatR;
    sVE: TMatR;
    fcegh: TFuenteSintetizadorCEGH; // referencia a la fuente de creación

    pe_inf, pe_sup: NReal;

    constructor CreateFromSim(idHilo: integer; fcegh: TFuenteSintetizadorCEGH;
      fechaIniSim, fechaFinSim: TFecha; NCronicas: integer; pe_inf,
  pe_sup: NReal);
    procedure Free;
    {$IFDEF CALIBRAR_PRONOSTICOS_TRAZOSXY}
    procedure plot(Sender: TComponent);
    {$ENDIF}
  end;




implementation

// extiende con CEROS las guias de pronósticos en espacios gaussianos.
// la hipótesis es que luego de finalizado el cono, la guía es el CERO
// en el espacio gaussiano.
function fguia_extendida(guia_eg: TDAOfNreal; jPaso: integer): NReal;
begin
  if jPaso < length(guia_eg) then
    Result := guia_eg[jPaso]
  else
    Result := 0;
end;

procedure CalibrarConoCentrado(cegh: TModeloCEGH;
  escenarios: TEscenarioDePronosticos; fechaIniSim: TFecha);
var
  NPronosticos,
  NSeries: Integer;

  p: array of TPronostico; // solo para facilidad de escritura.
  i,j: integer; // indice general.

  kSerie,
  kEscenario,
  kPronostico,
  kPaso,
  jPronostico: Integer;
  kretardo: integer;

  ydet, xdet: NReal;
  fecha: TFecha;

  a: NReal;
  jbase: integer;

  ifil, jcol: integer;

  kselector: integer;
  delta_sesgo: NReal;

  // funcion auxiliar para asignar CERO si me voy por fuera de la guia
  function s(kserie, jpaso: integer): NReal;
  begin
    if jpaso <= high(p[kserie].guia_eg) then
      Result := p[kserie].guia_eg[jpaso]
    else
      Result := 0;
  end;

begin

  escenarios.prepararse( cegh.durPasoDeSorteoEnHoras );

  NSeries := cegh.nBornesSalida;

  // apuntamos los p a los pronosticos para facilitar referencia.
  NPronosticos:=escenarios.Count*escenarios[0].Count;
  setlength(p, NPronosticos);
  for i := 0 to NPronosticos-1 do
      p[i] := escenarios[i div NSeries][i mod NSeries];

  for i := 0 to high(p) do
  begin
    if p[i].fechaIniSesgo<>nil then
      p[i].fechaIniSesgo.Free;

    p[i].fechaIniSesgo:=TFecha.Create_Dt(fechaIniSim.dt);
    p[i].calcular_rangos(cegh.durPasoDeSorteoEnHoras);
  end;

  // ajustamos dimensiones y limpiamos sesgos y factor
  for i := 0 to high(p) do
  begin
    setlength(p[i].sesgo, p[i].NPCC + p[i].NPLC);
    vclear(p[i].sesgo);
    setlength(p[i].factor, p[i].NPSA + p[i].NPAC);
    vclear(p[i].factor);
  end;



  // llenamos los factores de apertura del cono
  // hasta NPSA dejamos los ceros y a partir de ahí abrimos el cono aumentando
  // linealmente el factor.
  for i := 0 to high(p) do
  begin
    for j := 0 to p[i].NPSA - 1 do
      p[i].factor[j] := 0.0;
    for j := max( 0, p[i].NPSA ) to high(p[i].factor) do
      p[i].factor[j] := (j - p[i].NPSA) / p[i].NPAC;
  end;



  // ahora creamos la imagen de las guías de los pronósticos en el espacio
  // gaussiano.
  for i := 0 to high(p) do
  begin
    setlength(p[i].guia_eg, length(p[i].guia));
    fecha := TFecha.Create_Clone(fechaIniSim);

    kSerie := i mod NSeries;

    // retrocedemos para la cantidad de retardos por la duración del paso de sorteo.
    fecha.addHoras(-cegh.nRetardos*cegh.durPasoDeSorteoEnHoras);

    for kpaso := 0 to high(p[i].guia_eg) do
    begin
      ydet := p[i].guia[kpaso];
      kselector := cegh.kSelectorDeformador(fecha);
      xdet := cegh.xTog(ydet, kSerie + 1, kselector + 1);
      p[i].guia_eg[kpaso] := xdet;
      fecha.addHoras(cegh.durPasoDeSorteoEnHoras);
    end;
    fecha.Free;
  end;

  // ahora, proyectamos la salida del filtro para cada serie conociendo
  // los estados anteriores y la diferencia entre el proyectado y el valor
  // siguiente en los determinismos gaussianos es el sesgo en la fuente.
  for i := 0 to High(p) do
  begin
    if cegh.A_cte = nil then
    // Necesita calcular kselector para seleccionar matriz mcA
    begin
      // neceisto la fecha para calcular el kSelector
      fecha := TFecha.Create_Clone(fechaIniSim);
      // retrocedemos para la cantidad de retardos por la duración del paso de sorteo.
      fecha.addHoras(-cegh.NRetardos * cegh.durPasoDeSorteoEnHoras);
    end;

    jbase := cegh.NRetardos - 1;
    kEscenario:= i div NSeries;
    kPronostico:= i mod NSeries;

    for kpaso := 0 to p[i].NPCC-1 do
    begin
      if cegh.A_cte = nil then
        // Necesita calcular kselector para seleccionar matriz mcA
      begin
        kselector := cegh.kSelectorDeformador(fecha);
        fecha.addHoras(cegh.durPasoDeSorteoEnHoras);
      end;

      ifil := kPronostico + 1;
      a := 0;
      for kretardo := 0 to cegh.NRetardos - 1 do
      begin
        for jPronostico := kEscenario to (kEscenario+1)*NSeries-1 do
        begin
          jcol := kretardo * NSeries + jPronostico + 1;
          xdet := fguia_extendida(p[jPronostico].guia_eg, jbase - kretardo);
          if cegh.A_cte <> nil then
            a := a + cegh.A_cte.e(ifil, jcol) * xdet
          else
            a := a + cegh.mcA[kSelector].e(ifil, jcol) * xdet;
        end;
      end;

      p[i].sesgo[kpaso] := p[i].guia_eg[jbase + 1] - a;
      Inc(jbase);
    end;

    // si está especificado Número de Pasos de Liberación del Cono
    // llevamos los sesgos a CERO en forma lineal.
    if (p[i].NPLC > 0) and (p[i].NPCC > 0) then
    begin
      delta_sesgo := p[i].sesgo[p[i].NPCC - 1] / p[i].NPLC;
      for kpaso := p[i].NPCC to high(p[i].sesgo) do
        p[i].sesgo[kpaso] := p[i].sesgo[kpaso - 1] - delta_sesgo;
    end;

    if cegh.A_cte = nil then
      fecha.Free;

  end;

  //pronosticos.WriteToArchi('pronosticos_calibrador.txt');
end;

var
  //Es un arreglo de boneras, donde cada bornera es una matriz
  //Las filas de esta matriz son los pasos y las columnas las cronicas
  preview_datos: array of TMatR;
  preview_fuente: TFuenteSintetizadorCEGH;
  preview_kCronica, preview_jPaso, preview_nseries, preview_DimEstadoReducido: integer;
  preview_despBornera: integer; // desplazamiento en la bornera para acceder a la salida

  // del filtro en el mundo real. = nSeries + (nSeries*NRetardos)
  preview_NCronicas, preview_NPasos: integer;
  {$IFDEF CALIBRAR_PRONOSTICOS_TRAZOSXY}
  trx: array of TfrmDllForm;

  {$ENDIF}

procedure preview_inicioCronica;
begin
  preview_jPaso := 1;
  Inc(preview_kCronica);
end;

procedure preview_finpaso;
var
  jBornera, j: integer;
begin
  for jBornera := 0 to preview_nseries - 1 do
  begin
    preview_datos[jBornera].pon_e(preview_jPaso, preview_kCronica,
      preview_fuente.bornera[preview_despBornera + jBornera]);
  end;
  for j := 0 to preview_DimEstadoReducido - 1 do
  begin
    with preview_fuente do
      ReducirEstado(XRed, jPrimer_X_x, datosModelo_Opt, datosModelo_Opt.MRed, Bornera);

    preview_datos[preview_nseries + j].pon_e(preview_jPaso, preview_kCronica,
      preview_fuente.XRed[j]);
  end;
  Inc(preview_jPaso);
end;



constructor TSeriesConoPronostico.CreateFromSim(
  idHilo: integer;
  fcegh: TFuenteSintetizadorCEGH;
  fechaIniSim, fechaFinSim: TFecha; NCronicas: integer; pe_inf, pe_sup: NReal);

var
  sala: TSalaDeJuego;
  durpos: TDAOfNReal;
  jPaso, kSerie: integer;
  jpeInf, jpe50, jpeSup: integer;
  vdatos: TVectR;

  kCronica: integer;
  sal: textfile;
  old_dir: string;

  CatalogoRefs: TCatalogoReferencias;
begin
  inherited Create;

  old_dir := getcurrentdir;

  fcegh.WriteToArchi('fcegh_calibrador.txt');

  self.fcegh := fcegh;

  self.pe_inf := pe_inf;
  self.pe_sup := pe_sup;


  setlength(durpos, 1);
  durpos[0] := fcegh.datosModelo_Sim.durPasoDeSorteoEnHoras;

  // creamos un clon para que cuando haga el FREE de la Sala no se me pierda
  // la fuente.
  CatalogoRefs:= TCatalogoReferencias.Create;
  preview_fuente := fcegh.Create_Clone( CatalogoRefs, idHilo )  as TFuenteSintetizadorCEGH;
  CatalogoRefs.Free;

  sala := TSalaDeJuego.Create(fcegh.capa, 'Calibrador',

  // rango de simulación
  fechaIniSim, fechaFinSim, TFecha.Create_Dt(0),
  // rango de optimización (pongo lo mismo que sim - no importa )
  fechaIniSim, fechaFinSim, durpos);

  sala.setDirCorrida('_calibrador_.ese');

  //Inicializamos todas las variables
  preview_NPasos := sala.globs.calcNPasosSim;
  preview_kCronica := 0;

  preview_nseries := fcegh.datosModelo_Sim.nBornesSalida;
  preview_DimEstadoReducido := fcegh.datosModelo_Sim.MRed.nf;

  preview_despBornera := fcegh.dim_RB + fcegh.dim_Wa + fcegh.datosModelo_Sim.nRetardos *
    preview_nseries;

  NPasosT := preview_NPasos;
  preview_NCronicas := NCronicas;

  speInf := TMatR.Create_Init(preview_NSeries + preview_DimEstadoReducido,
    preview_NPasos);
  spe50 := TMatR.Create_Init(preview_NSeries + preview_DimEstadoReducido,
    preview_NPasos);
  speSup := TMatR.Create_Init(preview_NSeries + preview_DimEstadoReducido,
    preview_NPasos);
  sVE := TMatR.Create_Init(preview_NSeries + preview_DimEstadoReducido,
    preview_NPasos);

  sala.globs.procNot_InicioCronica := preview_inicioCronica;
  sala.globs.procNot_FinPaso := preview_finpaso;


  //Inicializo array para el tamaño de series
  setlength(preview_datos, preview_nseries + preview_DimEstadoReducido);
  //Inicializo matriz como num de pasos x num de cronicas
  for kSerie := 0 to high(preview_datos) do
  begin
    preview_datos[kSerie] := TMatR.Create_Init(preview_NPasos, preview_NCronicas);
  end;

  //Agregamos fuente a la sala
  sala.listaFuentes_.Add(preview_fuente);


  (**** OJO hago como que optmicé para que exista globs.CF ****)
  sala.inicializarOptimizacion_subproc01;
  sala.inicializarOptimizacion_subproc02(nil, nil);
  sala.globs.abortarSim := False;
  sala.globs.NCronicasSim := NCronicas;
  sala.globs.semilla_inicial_sim := 31;
  // !!!!!!!!!!!!! SIMULAR !!!!!!!!!!!!!!!!!!
  setSeparadoresGlobales; // para que escriba en global
  sala.Simular(0, True);
  setSeparadoresLocales;
  // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

  jpeInf := min(trunc(pe_inf * NCronicas) + 1, NCronicas);
  jpe50 := min(trunc(0.5 * NCronicas) + 1, NCronicas);
  jpeSup := min(trunc(pe_sup * NCronicas) + 1, NCronicas);


  assignfile(sal, 'ucalibrador.xlt');
  rewrite(sal);
  writeln(sal, 'NSeries: ', preview_NSeries);
  writeln(sal, 'NPasos: ', preview_NPasos);
  writeln(sal, 'DimEstadoReducido: ', preview_DimEstadoReducido);

  for kSerie := 1 to length(preview_datos) do
  begin
    writeln(sal, 'Serie: ', kSerie);
    for jPaso := 1 to preview_NPasos do
    begin
      Write(sal, jPaso);
      //datos[kSerie][jPaso][jCronica]
      vdatos := preview_datos[kSerie - 1].Fila(jPaso);
      for kCronica := 1 to vdatos.n do
        Write(sal, #9, vdatos.e(kCronica));
      writeln(sal);
    end;
    writeln(sal);
  end;

  writeln(sal, '**********CONO RESUMEN*********');
  writeln(sal, 'jpeInf: ', jpeInf, ', jpe50: ', jpe50, ', jpeSup: ', jpeSup);

  //Tenemos que ordenar los vectores de la matriz para poder imprimir el cono
  for jPaso := 1 to preview_NPasos do
  begin
    Write(sal, jPaso);
    for kSerie := 1 to length(preview_datos) do
    begin
      //datos[kSerie][jPaso][jCronica]
      vdatos := preview_datos[kSerie - 1].Fila(jPaso);
      vdatos.Sort(True);

      sVE.pon_e(kSerie, jPaso, vdatos.promedio);
      speInf.pon_e(kSerie, jPaso, vdatos.e(jpeInf));
      spe50.pon_e(kSerie, jPaso, vdatos.e(jpe50));
      speSup.pon_e(kSerie, jPaso, vdatos.e(jpeSup));

      Write(sal, #9, sVE.e(kSerie, jPaso));
      Write(sal, #9, speInf.e(kSerie, jPaso));
      Write(sal, #9, spe50.e(kSerie, jPaso));
      Write(sal, #9, speInf.e(kSerie, jPaso));
    end;
    writeln(sal);
  end;

  closefile(sal);

  sala.Free;
  preview_fuente := nil; // ya la liberó la sala.
  for kSerie := 0 to high(preview_datos) do
    preview_datos[kSerie].Free;
  setlength(preview_datos, 0);

  setcurrentdir(old_dir);
end;

procedure TSeriesConoPronostico.Free;
begin
  speInf.Free;
  spe50.Free;
  speSup.Free;
  sVE.Free;
end;



{$IFDEF CALIBRAR_PRONOSTICOS_TRAZOSXY}
procedure TSeriesConoPronostico.plot(Sender: TComponent);
var
  kSerie, jPaso: integer;
  colores: array of TColor;
  nombreBorne: string;

  minVal, maxVal, dVal: NReal;

  NDivY: integer;
  guia: TDAOfNReal;
  jPasoGuia, jPasoGuia_Ultimo: integer;

  iserie_VE, iserie_Guia, iserie_pe05, iserie_pe50, iserie_pe95: integer;

begin
  if NPasosT <= 0 then
  begin
    ShowMessage('No hay cono de pronósticos especificado.');
    exit;
  end;

  (*
  if length(trx) <> 0 then
    for kSerie := 0 to high(trx) do
      if trx[kSerie] <> nil then
        trx[kSerie].Close;
    *)

  SetLength(trx, preview_nseries + preview_DimEstadoReducido);
  //Tamaño del vector de graficos
  //Creo un array con los colores para todas las posibles series
  setlength(colores, 12);
  colores[0] := clBlue;
  colores[1] := clOlive;
  colores[2] := clTeal;
  colores[3] := clGreen;
  colores[4] := clNavy;
  colores[5] := clPurple;
  colores[6] := clBlack;
  colores[7] := clGray;
  colores[8] := clLime;
  colores[9] := clFuchsia;
  colores[10] := clMaroon;
  colores[11] := clRed;

  //Comienza loop de imprimir
  for kSerie := 0 to preview_nseries + preview_DimEstadoReducido - 1 do
  begin

    if kSerie < preview_nseries then
      nombreBorne := fcegh.NombresDeBornes_Publicados[kSerie]
    else
      nombreBorne := fcegh.datosModelo_Sim.nombreVarE[kSerie - preview_nseries];


    minVal := speInf.fila(kSerie + 1).minval;
    maxVal := speSup.fila(kSerie + 1).maxval;

    NDivY := 8;
    Escala125N(minVal, maxVal, dVal, NDivY, 1);

    (*
    if trx[kSerie] <> nil then
      trx[kSerie].Close;
     *)

    trx[kSerie] := TfrmDllForm.Create(Sender);

    iserie_VE := 1;
    trx[kSerie].CrearDiagramaXY(
      nombreBorne, // Nombres
      NPasosT,      // MaxNPuntos
      False,       // ciruclar
      'paso',         // nombre_sx
      'VE',  // nombre_sy1: pchar;
      colores[0],  //  color_sy1: TColor;
      1, NPasosT,   //  x1, x2,
      minVal, maxVal, //y1, y2
      10, NDivY        // NDivX, NDivY
      );

//    trx[kSerie].nilOnClose := @trx[kSerie];

    trx[kSerie].Show;

    //Creo las series
    if kSerie < preview_nseries then
      iserie_Guia := trx[kSerie].CrearSerieXY('Guía', NPasosT, False,
        colores[1], TM_Cuadrado, colores[1], colores[1], 3);

    iserie_pe05 := trx[kSerie].CrearSerieXY('pe_' +
      FloatToStr(trunc(self.pe_inf * 100 + 0.5)) + '%', NPasosT,
      False, colores[2], TM_Triangulo, colores[2], colores[2], 3);
    iserie_pe50 := trx[kSerie].CrearSerieXY('pe_50%', NPasosT, False,
      colores[3], TM_Circulo, colores[3], colores[3], 3);
    iserie_pe95 := trx[kSerie].CrearSerieXY('pe_' +
      FloatToStr(trunc(self.pe_sup * 100 + 0.5)) + '%', NPasosT,
      False, colores[4], TM_Cruz45, colores[4], colores[4], 3);

    trx[kSerie].dbj_gridx;
    trx[kSerie].dbj_gridy;
    trx[kSerie].dbj_borde;
    trx[kSerie].titulo(nombreBorne);
    trx[kSerie].etiquetas_x(0, NPasosT);
    trx[kSerie].etiquetas_y(MinVal, maxVal);
    trx[kSerie].xlabel('PasoT');
    //    trx[kSerie].ylabel('M^3/s');


    if kSerie < preview_nseries then
    begin
      guia := fcegh.escenarioDePronosticos[0][kSerie].guia;
      jPasoGuia := fcegh.datosModelo_Sim.nRetardos - 1;
      jPasoGuia_Ultimo := jPasoGuia + fcegh.escenarioDePronosticos[0][kSerie].NPCC;
    end;

    //Aca se imprimen los valores de cada serie
    for jPaso := 1 to NPasosT do
    begin
      trx[kSerie].tr1.PlotNuevo_x(jPaso);
      trx[kSerie].tr1.PlotNuevo_y(iserie_VE, sve.fila(kserie + 1).e(jPaso));
      if kSerie < preview_nseries then
      begin
        if jPasoGuia <= jPasoGuia_Ultimo then
          trx[kSerie].tr1.PlotNuevo_y(iserie_Guia, guia[jPasoGuia]);
        Inc(jPasoGuia);
      end;
      trx[kSerie].tr1.PlotNuevo_y(iserie_pe05, speInf.fila(kserie + 1).e(jPaso));
      trx[kSerie].tr1.PlotNuevo_y(iserie_pe50, spe50.fila(kserie + 1).e(jPaso));
      trx[kSerie].tr1.PlotNuevo_y(iserie_pe95, speSup.fila(kserie + 1).e(jPaso));
    end;

  end;//End del loop que imprime cada serie

  SetLength(colores, 0);
end;

{$ENDIF}


procedure AlFinal;
var
  k: integer;
begin
  {$IFDEF CALIBRAR_PRONOSTICOS_TRAZOSXY}
  (*
  if length( trx ) > 0 then
    for k:= 0 to high( trx ) do
      if trx[k] <> nil then
        trx[k].Close;
        *)
  setlength(trx, 0);
  {$ENDIF}
end;

initialization
  preview_datos := nil;
  preview_fuente := nil;
  {$IFDEF CALIBRAR_PRONOSTICOS_TRAZOSXY}
  setlength(trx, 0);
  {$ENDIF}
finalization
  AlFinal;
end.
