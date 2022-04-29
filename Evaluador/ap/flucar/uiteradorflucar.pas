(*
Proyecto FSE-18-2009 Mejoras a SimSEE - IIE-FING 2012
*)
unit uiteradorflucar;

interface

uses
  Classes, SysUtils, uiteradoresSimSEE, usalasdejuego, 
{$IFDEF ENZO_DBG}
Dialogs,
{$ENDIF}
  uFlucar, xmatdefs, ugeneradores, uarcos, uDemandas, uComercioInternacional, urawdata, uglobs, cronomet;

type

  { TIteradorFlucar }

  TIteradorFlucar = class(TIteradorDePasoSimSEE)
    Sala: TSalaDeJuego;
    Flucar: TFlucar;
    NgensSimSEE, NdemsSimSEE, NInterSimSEE, NNodosSimSEE, NgensFlucar,
    NdemsFlucar, NArcosSimSEE_, NZonasFlucar: integer;
    Crono:TCrono;
    //kDem_Flucar:TMatOfNInt;           // Equivalencia entre nodos SimSEE y Flucar. Un Nodo SimSEE a varios nodos flucar
    //kPorc_Dem_Flucar:TMatOfNInt;      // Porcentaje de la demanda de cada nodo SimSEE a cada nodo Flucar
    T1,T2,T3,T4,T5,T6: NReal;
    kGen_Flucar: TMatOfNInt;
    // Equivalencia entre Generador SimSEE y Flucar. Un Gen SimSEE a varios Gen flucar
    kDisp_Gen_Flucar: TMatOfNInt;
    // Equivalencia entre la Disponibilidad de cada Generador SimSEE y Flucar

    PotArcSal, PotArcEnt, PotArcSalAUX, PotArcEntAUX: array of TMatOfNReal;
    // Vector real para almacenar las potencias entre los arcos Flucar
    DemZonas: TDAofNReal;   // Vector real para almacenar las demandas de cada zona.

    PotMaxArcosIni, RendArcosIni, PeaArcosIni: array of TDAofNReal;
    PotMaxArcosIniRATE_A: array of TDAofNReal;

    // aux para calculos. Guarda las sobrecargas entre NODOS para cada poste
    HaySobrecarga_pp: TDAOfMatOfNReal;
    Diferencia: TDAofNReal;
    constructor Create(Sala_: TSalaDeJuego);
    function LoadArchivoDeRed_Flucar(archi: string): boolean;
    procedure cargo_Ps_al_flucar(kPoste_: integer);

    // el resultado es TRUE si la diferencia entre las potencias activas
    // es mayor que un umbral establecido.
    // Por ej. el criterio podría ser que las diferencias de potencias y de
    // arcos no supere en ninguno de los casos el 10% (o el 5%)
    procedure preparar_paso_as; override;
    function NecesitoIterar: boolean; override;
    procedure preparar_paso_ps; override;
    procedure Free;

  end;

implementation

function TIteradorFlucar.LoadArchivoDeRed_Flucar(archi: string): boolean;
var
  archivoentrada: string;
begin
  (**** Aquí se levanta el caso ****)
  archivoentrada := archi;
  Flucar := TFlucar.CreateFromArchi(archivoentrada);
  Flucar.cargar_caso;
  NZonasFlucar := Flucar.sala.zonas.Count;
  setlength(DemZonas, NZonasFlucar);
  Flucar.carga_FactorZonaCargas(DemZonas);
  Flucar.DumpProblemaParaDebug('caso_base.xlt');
end;

constructor TIteradorFlucar.Create(sala_: TSalaDeJuego);
var
  kPoste, karco, z1, z2: integer;
  MVA: double;
  a: TArco;
  fil: Text;
  Archisob:string;
begin
  inherited Create;
  sala := Sala_;
  LoadArchivoDeRed_Flucar(Sala.globs.iteracion_flucar_Archivo_Flucar);
  (**** Aquí se cargan las variables auxiliares ****)
  NgensSimSEE := sala.gens.Count;
  NInterSimSEE := sala.comercioInternacional.Count;
  NdemsSimSEE := sala.dems.Count;
  NArcosSimSEE_ := sala.arcs.Count;
  NNodosSimSEE := sala.nods.Count;
  (**** Aquí se cargan los vectores y matrices auxiliares ****)
  setlength(PotArcEnt, sala.globs.NPostes);
  setlength(PotArcSal, sala.globs.NPostes);

  setlength(PotArcEntAUX, sala.globs.NPostes);
  setlength(PotArcSalAUX, sala.globs.NPostes);

  setlength(PotMaxArcosIni, sala.globs.NPostes);
  setlength(RendArcosIni, sala.globs.NPostes);
  setlength(PeaArcosIni, sala.globs.NPostes);
  setlength(PotMaxArcosIniRATE_A, sala.globs.NPostes);
  setlength( HaySobrecarga_pp, sala.globs.NPostes );

  for kposte := 0 to sala.globs.NPostes - 1 do
  begin
    setlength(PotArcEnt[kposte], NNodosSimSEE + 1, NNodosSimSEE + 1);
    setlength(PotArcSal[kposte], NNodosSimSEE + 1, NNodosSimSEE + 1);
    setlength(PotArcEntAUX[kposte], NNodosSimSEE + 1, NNodosSimSEE + 1);
    setlength(PotArcSalAUX[kposte], NNodosSimSEE + 1, NNodosSimSEE + 1);
    setlength(HaySobrecarga_pp[kPoste], NArcosSimSEE_, NArcosSimSEE_);
    setlength(PotMaxArcosIni[kposte], NArcosSimSEE_);
    setlength(PotMaxArcosIniRATE_A[kposte], NArcosSimSEE_);
    setlength(RendArcosIni[kposte], NArcosSimSEE_);
    setlength(PeaArcosIni[kposte], NArcosSimSEE_);
    setlength(Diferencia, NArcosSimSEE_);
  end;

  for kposte := 0 to sala.globs.NPostes - 1 do
  begin
    for karco := 0 to NArcosSimSEE_ - 1 do
    begin
      a := self.Sala.arcs.items[karco] as TArco;
      PotMaxArcosIni[kposte][karco] := a.pa.PMax[kposte];
      z1 := a.NodoA.ZonaFlucar;
      z2 := a.NodoB.ZonaFlucar;
      MVA := Flucar.RATE_A(z1, z2);
      PotMaxArcosIniRATE_A[kposte][karco] := MVA;
      //writeln(a.nombre,' ',kposte,' ',karco,#9, PotMaxArcosIniRATE_A[kposte][karco]:5:2);
      RendArcosIni[kposte][karco] := a.pa.rendimiento[kposte];
      PeaArcosIni[kposte][karco] := a.pa.peaje[kposte];
    end;
  end;

  ArchiSob:= sala.nombre+ '_Sobrecargas.txt';
  Assign(fil, ArchiSob);
  rewrite(fil);
  writeln(fil,'LOG DE SOBRETENSIONES Y SOBRECARGAS');
  writeln(fil,' ');
  close(fil);

end;


procedure TIteradorFlucar.cargo_Ps_al_flucar(kPoste_: integer);
var
  k: integer;
  zona: integer;
  nDispoSimSEE: integer;
  PGenSimSEE: NReal;
  PUnidadFlucar: NReal;
  CargaTotal: NReal;
  GenTotal, Peol: NReal;
  PSlack: NReal;
  PerdidasArcos: NReal;
  eolico:boolean;
  nHijos: integer;
  jHijo: integer;
  codigo_Hijo: string;
  barra_Hijo: longint;
  aDemSimSEE: TDemanda;
  aGenSimSEE: TGenerador;
  aComerInterSimSEE: TComercioInternacional;
  aArcoSimSEE: TArco;
  aDemFlucar: TRaw_Load;
  aGenFlucar: TRaw_Generator;
begin
  crono.borre;
  crono.cuente;
  CargaTotal := 0;
  GenTotal := 0;
  Peol := 0;
  PerdidasArcos := 0;
  // Cargar las potencias Activas DE LAS CARGAS al CASO
  for k := 0 to length(DemZonas) - 1 do
    DemZonas[k] := 0;

  for k := 0 to sala.dems.Count - 1 do
  begin
    aDemSimSEE := self.Sala.dems.items[k] as TDemanda;
    Zona := Flucar.k_Zona(aDemSimSEE.Nodo.ZonaFlucar);
    DemZonas[Zona] := DemZonas[Zona] + aDemSimSEE.P[kPoste_];
    //Writeln('Zona: ',aDemSimSEE.Nodo.ZonaFlucar,' dem ',DemZonas[Zona]:3:2 );      //

    CargaTotal := CargaTotal + DemZonas[Zona];
  end;
  Flucar.Cargar_Dem_Zonas(DemZonas);

  // Cargar las potencias Activas DE LOS GENERADORES al CASO
  for k := 0 to sala.gens.Count - 1 do
  begin
    aGenSimSEE := self.Sala.gens.items[k] as TGenerador;
    PGenSimSEE := aGenSimSEE.P[kPoste_];
    nDispoSimSEE := aGenSimSEE.paUnidades.nUnidades_Operativas[0];
    nHijos := length(aGenSimSEE.codigos_flucar);

    GenTotal := GenTotal + aGenSimSEE.P[kPoste_];
    eolico:= (aGenSimSEE.ClassName = 'TParqueEolico') or (aGenSimSEE.ClassName = 'TParqueEolico_vxy');
    if not eolico then
    begin
      if nDispoSimSEE > 0 then
        PUnidadFlucar := PGenSimSEE / nDispoSimSEE
      else
        PUnidadFlucar := 0;

      for jHijo := 0 to high(aGenSimSEE.codigos_flucar) do
      begin
        barra_Hijo := aGenSimSEE.barras_flucar[jHijo];
        codigo_Hijo := aGenSimSEE.codigos_flucar[jHijo];
        aGenFlucar := Flucar.sala.Find_Generador(barra_Hijo, codigo_Hijo) as
          TRaw_Generator;
        if aGenFlucar = nil then
          raise Exception.Create('Error. El Actor: ' + aGenSimSEE.nombre +
            ' tiene el código Flucar: ' + IntToStr(barra_Hijo) +
            ' ' + codigo_Hijo +
            ', pero no se encuentra entre los generadores de la sala Flucar ');

        // para ser prolijos habría que distribuir la potencia SimSEE considerando los límites de  los generadores Flucar.
        // AHORA simplemente dividimos la potencia SimSEE entre la cantidada de Generadores

        if jHijo < nDispoSimSEE then
        begin
          aGenFlucar.STAT := 1;
          aGenFlucar.PG := PUnidadFlucar;
          aGenFlucar.QG := 0;
        end
        else
        begin
          aGenFlucar.STAT := 0;
          aGenFlucar.PG := 0.0;
          aGenFlucar.QG := 0.0;
        end;

      end;
    end
    else
    begin
      //for jHijo := 0 to high(aGenSimSEE.codigos_flucar) do
      jHijo:=0;
          begin
            barra_Hijo := aGenSimSEE.barras_flucar[jHijo];
            codigo_Hijo := aGenSimSEE.codigos_flucar[jHijo];
            aDemFlucar := Flucar.sala.Find_Demanda(barra_Hijo, codigo_Hijo) as TRaw_Load;
            if aDemFlucar = nil then
              raise Exception.Create('Error. El Actor: ' + aDemFlucar.nombre +
              ' tiene el código Flucar: ' + IntToStr(barra_Hijo) +
              ' ' + codigo_Hijo +
              ', pero no se encuentra entre las demandas de la sala Flucar ');
            aDemFlucar.STATUS := 1;
            aDemFlucar.PL := -PGenSimSEE;
            aDemFlucar.QL := 0;
            Peol := Peol + PGenSimSEE;
          end;
    end;

  end;

  for k := 0 to sala.comercioInternacional.Count - 1 do
  begin

    aComerInterSimSEE := self.Sala.comercioInternacional.items[k] as
      TComercioInternacional;
    for jHijo := 0 to high(aComerInterSimSEE.codigos_flucar) do
    begin
      barra_Hijo := aComerInterSimSEE.barras_flucar[jHijo];
      codigo_Hijo := aComerInterSimSEE.codigos_flucar[jHijo];
      aDemFlucar := Flucar.sala.Find_Demanda(barra_Hijo, codigo_Hijo) as TRaw_Load;
      if aDemFlucar <> nil then
      begin
        aDemFlucar.PL := -aComerInterSimSEE.P[kPoste_];
        GenTotal := GenTotal + aComerInterSimSEE.P[kPoste_];
      end
      else
        raise Exception.Create('OJO; El actor comercio Internacional: ' +
          aComerInterSimSEE.nombre + ' ' + IntToStr(barra_Hijo) +
          ' ' + codigo_Hijo + ' no se encuentra en el archivo *.RAW');
      ;
      //writeln(aComerInterSimSEE.nombre, #9,aComerInterSimSEE.P[kPoste_]:5:2);
    end;
  end;

  for k := 0 to sala.arcs.Count - 1 do
  begin
    aArcoSimSEE := self.Sala.arcs.items[k] as TArco;
    PerdidasArcos := PerdidasArcos + aArcoSimSEE.P_NodoA[kPoste_] +
      aArcoSimSEE.P_NodoB[kPoste_];
  end;

  writeln('SimSEE: GenTotal ', GenTotal: 5: 2, ' CargaTotal ',
    CargaTotal: 5: 2, ' Peol: ', Peol: 5: 2,
    ' Dif: ', GenTotal + CargaTotal: 5: 2, '  Perdida Arcos ', PerdidasArcos: 5: 2);

  CargaTotal := 0;
  GenTotal := 0;

  for k := 0 to Flucar.sala.Generadores.Count - 1 do
  begin
    aGenFlucar := Flucar.sala.Generadores.Items[k];
    if aGenFlucar.STAT = 1 then
      GenTotal := GenTotal + aGenFlucar.PG;
  end;
  for k := 0 to Flucar.sala.Cargas.Count - 1 do
  begin
    aDemFlucar := Flucar.sala.Cargas.Items[k];
    if aDemFlucar.STATUS = 1 then
      CargaTotal := CargaTotal - aDemFlucar.PL;
  end;

  writeln('FLUCAR: GenTotal ', GenTotal: 5: 2, ' CargaTotal ',
    CargaTotal: 5: 2, ' Dif: ',
    GenTotal + CargaTotal: 5: 2);




  PSlack := Flucar.Slack.PL;
  Flucar.Slack.PL := 0; //PSlack-(GenTotal+CargaTotal);
  Flucar.Slack.QL := 0;
  crono.pare;
  T1:=crono.cuenta;
  //Flucar.DumpProblemaParaDebug('caso_base'+inttostr(kposte_)+'.xlt');

end;


procedure TIteradorFlucar.preparar_paso_as;
var
  k, j, kposte,max_iter: integer;
  a: TArco;
  ConsideroRATE_A: boolean;
  pmaxaux: NReal;
begin

  if sala.globs.EstadoDeLaSala = CES_OPTIMIZANDO then
     max_iter:=sala.globs.NMAX_ITERACIONESDELPASO_OPT
     else
     max_iter:=sala.globs.NMAX_ITERACIONESDELPASO_SIM;
  if not (sala.globs.cntIteracionesDelPaso >= max_iter) then
          begin


            ConsideroRATE_A := True;
            for kPoste := 0 to sala.globs.NPostes - 1 do
            begin

              //if kposte=0 then flucar.DumpProblemaParaDebugRaw('prueba.txt');
              for k := 0 to NArcosSimSEE_ - 1 do
              begin
                a := self.Sala.arcs.items[k] as TArco;
                if (sala.globs.cntIteracionesDelPaso <= 1) then
                begin
                  a.pa.rendimiento[kPoste] := RendArcosIni[kposte][k];
                  if not ConsideroRATE_A then
                    a.pa.PMax[kPoste] := PotMaxArcosIni[kposte][k]
                  else
                    a.pa.PMax[kPoste] := PotMaxArcosIniRATE_A[kposte][k];

                  a.pa.peaje[kPoste] := PeaArcosIni[kposte][k];
                end;
              end;
            end;
         end;
            //??? revisar si no se puede llevar al preparar memoria



end;


function TIteradorFlucar.NecesitoIterar: boolean;
var
  kPoste, max_iter: integer;
  resOK, res: boolean;
  Tolerancia, PotEntrada, PotSalida, PotEntradaAUX, rendFlucar: NReal;
  k, j, Nodo1, Nodo2, NArcos: integer;
  a: TArco;
  b: TGenerador;
  c: TDemanda;
  d: TComercioInternacional;
  fil, fil1: Text;
  sobrecarga, sobrecarga1: boolean;
  sobrec: NReal;
  ArchiSal, ArchiSal1, ArchiSob: string;

begin

  res := False;
  sobrec := 0;
  ArchiSob:= sala.nombre+ '_Sobrecargas.txt';
  if sala.globs.EstadoDeLaSala = CES_OPTIMIZANDO then
     max_iter:=sala.globs.NMAX_ITERACIONESDELPASO_OPT
     else
     max_iter:=sala.globs.NMAX_ITERACIONESDELPASO_SIM;
  if not (sala.globs.cntIteracionesDelPaso >= max_iter)  then
     begin

        for kPoste := 0 to sala.globs.NPostes - 1 do
        begin
          writeln();
          writeln('Paso ', sala.globs.kPaso_Sim, ' Cronica: ', sala.globs.kCronica,
            ' Poste: ', kPoste + 1, ' Iter: ', sala.globs.cntIteracionesDelPaso-1);

          Tolerancia := 0.05;

          // ponemos todas las Cargas en CERO en Flucar
          Flucar.Limpiar_cargas;

          // Cargo las potencias activas, generadores y cargas
          cargo_Ps_al_flucar(kPoste);

          // Crear sistema de ecuaciones para resolución del problema.
          Flucar.cargar_caso;
          crono.borre;
          crono.cuente;
          // Resolver Sistema de Ecuaciones Flucar
          resOk := Flucar.Correr_caso(Tolerancia);


          if not resOK then
          begin
            flucar.DumpProblemaParaDebug('flucar_debug.xlt');
            //raise Exception.Create('No logro resolver FLUCAR');

            Flucar.cargar_caso; //?? podría sobrar REVISAR
            Flucar.Flat_Start;

            resOk := Flucar.Correr_caso(Tolerancia);
            if not resOK then
            begin
              flucar.DumpProblemaParaDebug('flucar_debug.xlt');
{$IFDEF ENZO_DBG}
        ShowMessage('No logro resolver FLUCAR en Paso '+ inttostr(sala.globs.kPaso_)+ ' Cronica: ' +inttostr(sala.globs.kCronica)+
            ' Poste: '+ inttostr(kPoste + 1)+ ' Iter: '+ inttostr(sala.globs.cntIteracionesDelPaso-1))
{$ELSE}
              raise Exception.Create('No logro resolver FLUCAR');
{$ENDIF}
            end;
          end;

          crono.pare;
          T2:=crono.cuenta;
          writeln('barra Slack ', Flucar.Slack.PL: 5: 2, ' ', Flucar.Slack.QL: 5: 2);



          crono.borre;
          crono.cuente;
          sobrecarga := Flucar.analizar_sobrecargaZonas(PotArcEnt[kPoste], PotArcSal[kPoste]);
          sobrecarga1 := Flucar.analizar_sobrecargaZonasRATE_A(PotArcEntAUX[kPoste],
            PotArcSalAUX[kPoste], HaySobrecarga_pp[kPoste], sobrec); //?? revisar

          sobrec := 0;
          for k := 0 to NArcosSimSEE_ - 1 do
            for j := 0 to NArcosSimSEE_ - 1 do
            begin
              if HaySobrecarga_pp[kPoste][k][j] > sobrec then
                sobrec := HaySobrecarga_pp[kPoste][k][j];
            end;
// Escribo los archivos de salida-----------------------------------------------------------------------------------------------------

                ArchiSal := 'Caso Paso_' + IntToStr(sala.globs.kPaso_Sim) +
                  ' Cronica_' + IntToStr(sala.globs.kCronica) + ' Poste_' +
                  IntToStr(kPoste + 1) + ' Iter ' +
                  IntToStr(sala.globs.cntIteracionesDelPaso-1) + '.txt';
                ArchiSal1 := 'Caso Paso_' + IntToStr(sala.globs.kPaso_Sim) +
                  ' Cronica_' + IntToStr(sala.globs.kCronica) + ' Poste_' +
                  IntToStr(kPoste + 1) + ' Iter ' +
                  IntToStr(sala.globs.cntIteracionesDelPaso-1) + '.raw';

                if sala.GenerarRaws then
                begin
                  Flucar.DumpProblemaParaDebugRaw(ArchiSal);
                  //Flucar.DumpProblemaParaDebugRawPSSE(ArchiSal1);  Agregar los datos para que sea un archivo de flujo de cargas
                  Assign(fil, ArchiSal);
                  append(fil);
                  writeln(fil, ' ');
                  writeln(fil, 'ARCOS SIMSEE ');
                  for k := 0 to NArcosSimSEE_ - 1 do
                  begin
                    a := self.Sala.arcs.items[k] as TArco;
                    Diferencia[k] := -a.P_NodoA[kposte] - a.pa.PMax[kPoste];
                    if -a.P_NodoA[kposte] > 0 then
                      writeln(fil, a.nombre, #9, -a.P_NodoA[kposte]: 5: 2,
                        #9, -a.P_NodoB[kposte]: 5: 2, #9,
                        ' Pmax: ', #9, a.pa.PMax[kPoste]: 1: 2, #9, ' rend: ',
                        #9, a.pa.rendimiento[kposte]: 5: 3, #9,
                        ' Pmaxdisponible: ', #9, a.PMaxDisponible_[kPoste]: 1: 2, #9,'Perd:',#9,
                        a.P_NodoA[kposte]*(1-a.pa.rendimiento[kposte]):5:2,
                        #9, ' Diferencia: ', #9, Diferencia[k]: 5: 3)
                    else
                      writeln(fil, a.nombre, #9, -a.P_NodoA[kposte]: 5: 2,
                        #9, -a.P_NodoB[kposte]: 5: 2, #9,
                        ' Pmax: ', #9, a.pa.PMax[kPoste]: 1: 2, #9, ' rend: ',
                        #9, a.pa.rendimiento[kposte]: 5: 3, #9,
                        ' Pmaxdisponible: ', #9, a.PMaxDisponible_[kPoste]: 1: 2, #9,'Perd:',#9,
                        a.P_NodoA[kposte]*(1-a.pa.rendimiento[kposte]):5:2);
                    a.SorteosDelPaso(True);

                  end;
                  writeln(fil, 'SOBRECARGA ', sobrec: 5: 2);
                  writeln(fil, ' ');
                  writeln(fil, 'GENERADORES SIMSEE ');

                  for k := 0 to NgensSimSEE - 1 do
                  begin
                    b := self.Sala.gens.items[k] as TGenerador;
                    writeln(fil, b.nombre, #9, b.P[kposte]: 5: 2);

                  end;
                  writeln(fil, ' ');
                  writeln(fil, 'CARGAS SIMSEE ');

                  for k := 0 to self.Sala.dems.Count - 1 do
                  begin
                    c := self.Sala.dems.items[k] as TDemanda;
                    Write(fil, c.nombre, #9, c.P[kposte]: 5: 2, #9);
                    for j := 0 to high(c.fallas) do
                      Write(fil, #9, 'Falla ' + IntToStr(j + 1), #9, c.fallas[j][kposte]: 5: 2);
                    writeln(fil);
                  end;
                  writeln(fil, ' ');
                  writeln(fil, 'COMERCIO INTERNACIONAL SIMSEE ');

                  for k := 0 to self.Sala.comercioInternacional.Count - 1 do
                  begin
                    d := self.Sala.comercioInternacional.items[k] as TComercioInternacional;
                    writeln(fil, d.nombre, #9, d.P[kposte]: 5: 2);

                  end;
                  writeln(fil, '');
                  writeln(fil, 'Tiempo de carga de Pot.', #9, T1: 5: 7);
                  writeln(fil, 'Tiempo de resol de flujo', #9, T2: 5: 7);
                  writeln(fil, 'Tiempo de analisis de sobrec', #9, T3: 5: 7);
                  writeln(fil, 'Tiempo de modificacion de param', #9, T4: 5: 7);

                  Closefile(fil);
                end;


                if sala.globs.cntIteracionesDelPaso=sala.globs.NMAX_ITERACIONESDELPASO_SIM-1 then
                    Flucar.DumpProblemaSobrecargas(ArchiSob,sala.globs.kPaso_Sim,
                       sala.globs.kCronica,kposte,sala.globs.cntIteracionesDelPaso);




                if sala.globs.cntIteracionesDelPaso=sala.globs.NMAX_ITERACIONESDELPASO_SIM-1 then
                begin
                  Assign(fil1, ArchiSal);
                  rewrite(fil1);
                  writeln(fil1,'LOG CONTROL DE ARCOS');
                  closefile(fil1);
                 for k := 0 to NArcosSimSEE_ - 1 do
                     begin
                      a := self.Sala.arcs.items[k] as TArco;

                      Nodo1 := Flucar.K_Zona(a.NodoA.ZonaFlucar);
                      Nodo2 := Flucar.K_Zona(a.NodoB.ZonaFlucar);
                      Assign(fil1, ArchiSal);
                      append(fil1);
                      writeln(fil1,a.nombre, '  ', a.P_NodoA[kposte]: 5: 2,
                        ' _ ', a.P_NodoB[kposte]: 5: 2,
                        ' Pmax: ', a.pa.PMax[kPoste]: 1: 1, ' rend: ',
                        a.pa.rendimiento[kposte]: 5: 3, #9,'Perd:',#9,
                        a.P_NodoA[kposte]*(1-a.pa.rendimiento[kposte]):5:2);
                      closefile(fil1);
                      Flucar.DumpArcos(ArchiSal,Nodo1,Nodo2);
                    end;
                end;

// fin de escribir archivos de salida-------------------------------------------------------------------
                //end;


          // resuelvo si necesito seguir iterando
          res := res or (sobrec > 2);
          writeln(sala.globs.cntIteracionesDelPaso, ' SOBREC ', sobrec: 5: 2);
          T3:=crono.cuenta;
        end;
     end;
  Result := res;
end;

procedure TIteradorFlucar.preparar_paso_ps;
var
  modifico_peajes, modifico_rendim, modifico_pmax: boolean;
  kPoste, max_iter: integer;
  k: integer;
  j: integer;
  a: TArco;
  b: TGenerador;
  c: TDemanda;
  d: TComercioInternacional;

  Nodo1, Nodo2: integer;
  PotEntrada: NReal;
  PotEntradaAUX: NReal;
  PotSalida: NReal;
  rendFlucar: NReal;
  dPFlucar: NReal;
  dif: NReal;
  //Diferencia: TDAofNReal;
  potaux: NReal;
  nu: NReal;
  sobrec: NReal;
  ConsideroRATE_A: boolean;
//  dPFlucar, dif, potaux, sobrec, nu: NReal;
  landa: NReal;
  fil: Text;
  //ArchiSal, ArchiSal1: string;

begin
  if sala.globs.EstadoDeLaSala = CES_OPTIMIZANDO then
     max_iter:=sala.globs.NMAX_ITERACIONESDELPASO_OPT
     else
     max_iter:=sala.globs.NMAX_ITERACIONESDELPASO_SIM;
  if not (sala.globs.cntIteracionesDelPaso >= max_iter) and not (sala.globs.cntIteracionesDelPaso =1) then
     begin
        ConsideroRATE_A := True;
        landa := 1;
        //setlength(Diferencia, NArcosSimSEE_);

        sobrec := 0;
        for kPoste := 0 to sala.globs.NPostes - 1 do
        begin
        for k := 0 to NArcosSimSEE_ - 1 do
          for j := 0 to NArcosSimSEE_ - 1 do
          begin
            if HaySobrecarga_pp[kPoste][k][j] > sobrec then
              sobrec := HaySobrecarga_pp[kPoste][k][j];
          end;
         end;


        for kPoste := 0 to sala.globs.NPostes - 1 do
        begin
          modifico_peajes := Sala.globs.iteracion_flucar_modificar_peaje;
          modifico_rendim := Sala.globs.iteracion_flucar_modificar_rendimiento;
          modifico_pmax := Sala.globs.iteracion_flucar_modificar_capacidad;
          crono.borre;
          crono.cuente;

          writeln();
          for k := 0 to NArcosSimSEE_ - 1 do
          begin
            a := self.Sala.arcs.items[k] as TArco;

            Nodo1 := Flucar.K_Zona(a.NodoA.ZonaFlucar);
            Nodo2 := Flucar.K_Zona(a.NodoB.ZonaFlucar);

            PotEntrada := -PotArcEnt[kPoste][Nodo1][Nodo2] + PotArcSal[kPoste][Nodo2][Nodo1];
            PotEntradaAUX := -PotArcEntAUX[kPoste][Nodo1][Nodo2];
            //+PotArcSalAUX[kPoste][Nodo2][Nodo1];
            PotSalida := PotArcSal[kPoste][Nodo1][Nodo2] - PotArcEnt[kPoste][Nodo2][Nodo1];

            begin

              //if PotEntrada <= 0 then
              begin
                if PotEntrada > 0.000001 then
                  rendFlucar := PotEntrada / -PotSalida;
                if PotEntrada < -0.000001 then
                  rendFlucar := -PotSalida / PotEntrada;

                if (PotEntrada < 0) and (PotSalida < 0) then
                  rendFlucar := PotEntrada / -PotSalida;

                if abs(PotEntrada) < 0.1 then
                  rendFlucar := 1;



                dPFlucar := -a.P_Entrante[kposte] - PotEntrada;
                if PotEntrada <> 0 then
                  dif := dPFlucar / PotEntrada
                else
                  dif := 0;

                //writeln(a.nombre, ' SimSEE: ', a.P_NodoA[kposte]: 5: 2,
                //  ' _ ', a.P_NodoB[kposte]: 5: 2,
                //  ' Pmax: ', a.pa.PMax[kPoste]: 1: 1, ' rend: ',
                //  a.pa.rendimiento[kposte]: 5: 3,
                //  '   Flucar: ', PotEntrada: 5: 2, ' _ ', PotSalida: 5: 2,
                //  ' Rend: ', rendFlucar: 5: 4,
                //  ' DP ', dPFlucar: 5: 2, ' DP/Pent ', dif: 5: 2);


                // bueno ahora la primer idea sería imponer rendimientos
                if modifico_rendim then
                begin
                  //  Corrijo el Rendimiento segun la diferencia sea la diferencia entre el flujo y el SimSEE
                  if abs(rendFlucar) > 1.0 then
                    rendFlucar := 1.0;
                  a.pa.rendimiento[kPoste] := rendFlucar;
                end;

                if -a.P_NodoA[kposte] > 0.0 then
                  Diferencia[k] := -a.P_NodoA[kposte] - a.pa.PMax[kPoste]
                else
                  Diferencia[k] := 0.0;

                if PotEntrada <= 0.0 then
                begin
                  potaux := -PotEntrada;
                  if -PotEntrada > -PotEntradaAUX then
                    potaux := -PotEntradaAUX;
                end
                else
                begin
                  potaux := PotEntrada;
                  if PotEntrada > -PotEntradaAUX then
                    potaux := -PotEntradaAUX;
                end;
                nu := 0.0;

                if sobrec > 2.0 then
                begin
                  if ( HaySobrecarga_pp[kPoste][Nodo1][Nodo2] = 0.0 ) then
                  begin
                    if sala.globs.cntIteracionesDelPaso <= 2.0 then
                      potaux := -PotEntradaAUX
                    else
                    if abs(PotEntrada) > abs(PotEntradaAUX) then
                      potaux := abs(PotEntradaAUX)
                    else
                      potaux := abs(abs(PotEntrada));
                    //-sala.globs.cntIteracionesDelPaso)
                  end
                  else
                  begin
                    if HaySobrecarga_pp[kPoste][Nodo1][Nodo2] < 2.0 then
                      nu := HaySobrecarga_pp[kPoste][Nodo1][Nodo2] / 100.0;
                    if abs(PotEntradaAUX) <> 0 then
                      potaux :=
                        abs(PotEntrada) * (1.0 - abs(HaySobrecarga_pp[kPoste][Nodo1][Nodo2] + 2.0) /
                        abs(PotEntradaAUX) - nu);
                  end;



                  if (not ConsideroRATE_A) or (sala.globs.cntIteracionesDelPaso >= 1) then
                    if modifico_pmax then
                      a.pa.PMax[kPoste] := potaux
                    else
                    if modifico_pmax then
                      a.pa.PMax[kPoste] := -PotEntradaAUX;

                end;
                // Y tratar de corregir diferencias de potencia con introducción de peajes.
                if modifico_peajes and (abs(dPFlucar / PotEntrada) > 0.2) and
                  (abs(dPFlucar) > 50) then
                  a.pa.peaje[kPoste] := landa * (dPFlucar / PotEntrada);

              end;

            end;

          end;
          T4:=crono.cuenta;
          // Escribo los archivos de salida---????

        end;
        //setlength(Diferencia, 0);
   end;
end;

procedure TIteradorFlucar.Free;
var
  k: integer;
begin
  inherited Free;
  sala.Free;
  flucar.Free;

  vclear(DemZonas);
  vclear(Diferencia);
  for k := 0 to sala.globs.NPostes - 1 do
  begin
    liberarMatriz(PotArcEnt[k]);
    liberarMatriz(PotArcSal[k]);
    liberarMatriz(PotArcEntAUX[k]);
    liberarMatriz(PotArcSalAUX[k]);
    liberarMatriz(HaySobrecarga_pp[k]);
    liberarMatriz(PotMaxArcosIni);
    liberarMatriz(RendArcosIni);
    liberarMatriz(PeaArcosIni);
    liberarMatriz(PotMaxArcosIniRATE_A);
  end;

end;




end.
