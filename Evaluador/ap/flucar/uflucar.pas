unit uFlucar;

{$mode delphi}

interface

uses
  Classes, SysUtils, xmatdefs, uactoresflucar, flujoraw,
  ucpxresolvecuacs, urawdata, AlgebraC, Math;

type
  TFlucar = class
    sala: TSalaFlucar;
    Slack: TBarra;
  public
    constructor CreateFromArchi(archi: string);
    procedure cargar_caso;
    procedure Cargar_datos_DEM_GEN;
    procedure Cargar_Gen(i: integer; P: NReal);
    procedure Cargar_Dem(i: integer; P: NReal);
    procedure Cargar_Dem_Zonas(demZonas: TDAofNReal);
    procedure DumpProblemaParaDebug(archi: string);
    procedure DumpProblemaParaDebugRaw(archi: string);
    procedure DumpProblemaSobrecargas(archi: string;paso,cronica,poste,iter:integer);
    procedure DumpArcos(archi: string;inicio,fin:integer);
    procedure DumpProblemaParaDebugRawPSSE(archi: string);
    function Correr_caso(maxerr: NReal): boolean;
    function analizar_sobrecarga(Zona1, Zona2: integer; var P12, P21: NReal): boolean;
    function RATE_A(Zona1, Zona2: integer): double;
    function analizar_sobrecargaZonas(var Pent, Psal: TMatOfNReal): boolean;
    function analizar_sobrecargaZonasRATE_A(var Pent, Psal: TMatOfNReal;var HaySobre:TMatOfNReal;var sobre_:NReal): boolean;
    function K_Zona(Zona: integer): integer;
    function Zona_Barra(barra:TRaw_Bus):integer;
    function suma_cargas_zona(Zona: integer): NReal;
    function suma_cargas_total(area: integer): NReal;
    function Buscar_Generador(barra: longint; codigo: string): TRaw_Generator;
    function Buscar_Barra(barra: longint): TRaw_Bus;
    procedure carga_FactorZonaCargas(var cargasporZona: TDAofNReal);
    procedure Limpiar_cargas;
    procedure Flat_Start;
    procedure Flat_V;
    procedure Free;
  end;

implementation


constructor TFlucar.CreateFromArchi(archi: string);
begin
  sala := TSalaFlucar.Create;
  leerraw(sala, archi);
  Slack := sala.Find_Slack as TBarra;

  sala.TapsVariables := False;

end;

procedure TFlucar.DumpProblemaParaDebug(archi: string);
var
  f: textfile;
  i: integer;
  bar: TRaw_Bus;
  car: TRaw_Load;
  gen: TRaw_Generator;
begin
  assignfile(f, archi);
  rewrite(f);

  writeln(f, 'Numero Barras: ', sala.Barras.Count);
  for i := 0 to sala.Barras.Count - 1 do
  begin
    bar := sala.Barras[i];
    writeln(f, bar.I, #9, bar.Name, #9, bar.ZONE, #9, bar.IDE, #9, bar.IMP_CERO);
  end;
  writeln(f,'');

  writeln(f, 'Numero cargas: ', sala.Cargas.Count);
  for i := 0 to sala.Cargas.Count - 1 do
  begin
    car := sala.Cargas[i];
    writeln(f, car.I, #9, car.ID, #9, car.ZONE, #9, car.PL: 3: 2,
      #9, car.QL: 3: 2, #9, car.STATUS, #9, car.SCALE, #9, car.factorZona: 3: 2);
  end;
  writeln(f,'');

  writeln(f, 'Numero Generadores: ', sala.Generadores.Count);
  for i := 0 to sala.Generadores.Count - 1 do
  begin
    gen := sala.Generadores[i];
    writeln(f, gen.I, #9, gen.ID, #9, gen.nombre, #9, gen.PG: 3: 2,
      #9, gen.QG: 3: 2, #9, gen.STAT);
  end;

  closefile(f);
end;

procedure TFlucar.DumpProblemaParaDebugRaw(archi: string);
var
  f: textfile;
  i: integer;
  bar: TRaw_Bus;
  car: TRaw_Load;
  gen: TRaw_Generator;
  lin: TRaw_Branch;
  tra: TRaw_TransformerAdjust;
  S12,S21,SCON,II: NComplex;
  Base: Nreal;
begin
  Base:=100;
  assignfile(f, archi);
  rewrite(f);

  writeln(f, 'Numero Barras: ', sala.Barras.Count);
  for i := 0 to sala.Barras.Count - 1 do
  begin
    bar := sala.Barras[i];
    writeln(f, bar.I, #9, bar.Name, #9, bar.ZONE, #9, bar.IDE, #9, bar.VM:5:5, #9, bar.VA:5:5);
  end;
  writeln(f,' ' );

  writeln(f, 'Numero cargas: ', sala.Cargas.Count);
  for i := 0 to sala.Cargas.Count - 1 do
  begin
    car := sala.Cargas[i];
    writeln(f, car.I, #9, car.ID, #9, car.ZONE, #9, car.PL: 3: 2,
      #9, car.QL: 3: 2, #9, car.STATUS, #9, car.SCALE, #9, car.factorZona: 3: 2);
  end;
  writeln(f,' ');

  writeln(f, 'Numero Generadores: ', sala.Generadores.Count);

  for i := 0 to sala.Generadores.Count - 1 do
  begin
    gen := sala.Generadores[i];
    writeln(f, gen.I, #9, gen.ID, #9, gen.nombre, #9, gen.PG: 3: 2,
      #9, gen.QG: 3: 2, #9, gen.STAT);
  end;
  writeln(f,' ');
  writeln(f,'FLUJO POR LAS LINEAS - FLUJO DE CARGAS ');
  for i := 0 to sala.Lineas.Count - 1 do
  begin
    lin := sala.Lineas[i];
    lin.Calculo_potencias(S12,S21,SCON,II);
    writeln(f, Buscar_Barra(lin.I).Name, #9, Buscar_Barra(lin.J).Name, #9, #9,lin.CKT, #9,
               S12.r*Base: 3: 2, #9, S21.r*Base: 3: 2, #9,lin.RATEA:3:0);
  end;
  writeln(f,' ');
  writeln(f,'FLUJO POR LOS TRANSFORMADORES - FLUJO DE CARGAS ');
  for i := 0 to sala.trafosadjust.Count - 1 do
  begin
    tra := sala.trafosAdjust[i];
    tra.Calculo_potencias(S12,S21,SCON,II);
    writeln(f, Buscar_Barra(tra.I).Name, #9, Buscar_Barra(tra.J).Name, #9,
               S12.r*Base: 3: 2, #9, S21.r*Base: 3: 2, #9,tra.RATA1:3:0);
  end;
  closefile(f);
end;


procedure TFlucar.DumpProblemaSobrecargas(archi: string;paso,cronica,poste,iter:integer);
var
  f: textfile;
  i: integer;
  bar: TRaw_Bus;
  lin: TRaw_Branch;
  tra: TRaw_TransformerAdjust;
  S12,S21,SCON,II: NComplex;
  Base: Nreal;
  Vmin500, Vmax500, Vmin150, Vmax150:NReal;
  CASO:string;
begin
  Base:=100;
  Vmin500:= 0.95;
  Vmax500:= 1.05;
  Vmin150:= 0.93;
  Vmax150:= 1.07;
  assignfile(f, archi);
  append(f);

  CASO:='Caso Paso: ' + IntToStr(paso) + ' Cronica: ' + IntToStr(cronica) + ' Poste: ' +
       IntToStr(poste) + ' Iter ' + IntToStr(iter);
  writeln(f,CASO);
  writeln(f,#9,'LOG DE TENSIONES FUERA DE RANGO EN BARRAS');
  for i := 0 to sala.Barras.Count - 1 do
  begin
    bar := sala.Barras[i];
    if bar.BASKV = 500.0000 then
       begin
          if bar.VM<Vmin500 then
               writeln(f,#9,#9,'INFERIOR A MIN  ',#9,bar.I, #9, bar.Name, #9, bar.VM*bar.BASKV:5:5, #9, bar.VA:5:5 )
          else
            if bar.VM>Vmax500 then
               writeln(f,#9,#9,'SUPERIOR A MIN  ',#9,bar.I, #9, bar.Name, #9, bar.VM*bar.BASKV:5:5, #9, bar.VA:5:5 );
       end;
    if bar.BASKV = 150.0000 then
       begin
          if bar.VM<Vmin150 then
               writeln(f,#9,#9,'INFERIOR A MAX  ',#9,bar.I, #9, bar.Name, #9, bar.VM*bar.BASKV:5:5, #9, bar.VA:5:5 )
          else
            if bar.VM>Vmax150 then
               writeln(f,#9,#9,'SUPERIOR A MAX  ',#9,bar.I, #9, bar.Name, #9, bar.VM*bar.BASKV:5:5, #9, bar.VA:5:5 );
       end;
  end;


  writeln(f,#9,'SOBRECARGA POR LAS LINEAS');
  for i := 0 to sala.Lineas.Count - 1 do
  begin
    lin := sala.Lineas[i];
    lin.Calculo_potencias(S12,S21,SCON,II);
    if ((mod1(S12)>lin.RATEA) or (mod1(S21)>lin.RATEA)) and (lin.RATEA<>0) then
       writeln(f, #9,#9,'SOBRECARGA EN LINEA  ',#9,Buscar_Barra(lin.I).Name, #9, Buscar_Barra(lin.J).Name, #9, #9,lin.CKT, #9,
               S12.r*Base: 3: 2, #9, S21.r*Base: 3: 2, #9,lin.RATEA:3:0);
  end;

  writeln(f,#9,'SOBRECARGA POR LOS TRANSFORMADORES');
  for i := 0 to sala.trafosadjust.Count - 1 do
  begin
    tra := sala.trafosAdjust[i];
    tra.Calculo_potencias(S12,S21,SCON,II);
    if ((mod1(S12)>tra.RATA1) or (mod1(S21)>tra.RATA1)) and (tra.RATA1<>0) then
       writeln(f, #9,#9,'SOBRECARGA EN TRAFO  ',#9, Buscar_Barra(tra.I).Name, #9, Buscar_Barra(tra.J).Name, #9,
               S12.r*Base: 3: 2, #9, S21.r*Base: 3: 2, #9,tra.RATA1:3:0);
  end;
  writeln(f,' ');
  closefile(f);
end;


procedure TFlucar.DumpArcos(archi: string;inicio,fin:integer);
var
  f: textfile;
  i,j,k: integer;
  lin: TRaw_Branch;
  tra: TRaw_TransformerAdjust;
  S12,S21,SCON,II: NComplex;
  Base: Nreal;

begin
  Base:=100;
  assignfile(f, archi);
  append(f);


  for k := 0 to sala.Lineas.Count - 1 do
  begin
    lin := sala.Lineas[k];
    i := K_Zona(TRaw_Bus(lin.Barra_I).ZONE);
    j := K_Zona(TRaw_Bus(lin.Barra_J).ZONE);

    if ((i=inicio) and (j=fin)) or ((j=inicio) and (i=fin)) then
       begin
          lin.Calculo_potencias(S12,S21,SCON,II);
          writeln(f, #9,#9,'LINEA  ',#9,Buscar_Barra(lin.I).Name, #9, Buscar_Barra(lin.J).Name, #9, lin.CKT, #9,
                  S12.r*Base: 3: 2, #9, S21.r*Base: 3: 2, #9,lin.RATEA:3:0);
       end;
  end;

  for k := 0 to sala.trafosadjust.Count - 1 do
  begin
    tra := sala.trafosAdjust[k];
    i := K_Zona(TRaw_Bus(tra.Barra_I).ZONE);
    j := K_Zona(TRaw_Bus(tra.Barra_J).ZONE);

    if ((i=inicio) and (j=fin)) or ((j=inicio) and (i=fin)) then
       begin
          tra.Calculo_potencias(S12,S21,SCON,II);
          writeln(f, #9,#9,'TRAFO  ',#9,Buscar_Barra(tra.I).Name, #9, Buscar_Barra(tra.J).Name, #9,
                  S12.r*Base: 3: 2, #9, S21.r*Base: 3: 2, #9,tra.RATA1:3:0);
       end;
  end;
  writeln(f,' ');
  closefile(f);
end;

procedure TFlucar.DumpProblemaParaDebugRawPSSE(archi: string);
var
  f: textfile;
  i,iEcuacion: integer;
  bar: TRaw_Bus;
  car: TRaw_Load;
  gen: TRaw_Generator;
  lin: TRaw_Branch;
  S12,S21,SCON,II: NComplex;
  Base: Nreal;
begin
  Base:=100;
  assignfile(f, archi);
  rewrite(f);

  for iEcuacion := 1 to sala.Barras.Count do
  begin
    bar := TRaw_Bus(sala.Barras[(iEcuacion - 1)]);
    writeln(f, bar.I, #9, bar.Name, #9, bar.ZONE, #9, bar.IDE, #9, bar.VM:5:5, #9, bar.VA:5:5);
  end;
  closefile(f);
end;

procedure TFlucar.cargar_caso;
begin
  sala.cargue;
  if sala.problemaCPX <> nil then
     sala.problemaCPX.Free;

  if sala.TapsVariables then
  begin
    cargar_taps(sala);
    sala.ProblemaCPX := TproblemaCPX.Create(sala.nNodos, sala.nNodos * 3);
  end
  else
  begin
    sala.ProblemaCPX := TproblemaCPX.Create(sala.nNodos, sala.nNodos * 2);
  end;
  Preparar_sistema(sala);
  Cargar_solo_problema(sala);
end;

procedure TFlucar.Cargar_datos_DEM_GEN;
var
  i: integer;
begin
  //Borro todo lo que tienen las barras
  for i := 0 to sala.Barras.Count - 1 do
  begin
    TRaw_Bus(sala.Barras[i]).borrar_dem_gen;
  end;

  // Cargo los Shunts Fijos
  if RAW_VER >= 32 then
  begin
    for i := 0 to sala.ShuntsFijos.Count - 1 do
    begin
      TRaw_FixedShunt(sala.ShuntsFijos[i]).cargue;
    end;
  end;

  //Cargo los Shunts variables
  for i := 0 to sala.shunts.Count - 1 do
  begin
    TRaw_SwitcheShunt(sala.shunts[i]).cargue;
  end;

  // Cargo las cargas o loads
  for i := 0 to sala.Cargas.Count - 1 do
  begin
    TRaw_Load(sala.Cargas[i]).cargue;
  end;

  //Cargo los generadores
  for i := 0 to sala.generadores.Count - 1 do
  begin
    TRaw_Generator(sala.generadores[i]).cargue;
  end;
end;

procedure TFlucar.Cargar_Gen(i: integer; P: NReal);
begin
  TRaw_Generator(sala.generadores[i]).PG := P;
end;

procedure TFlucar.Cargar_Dem(i: integer; P: NReal);
var
  factor: NReal;
begin
  factor := TRaw_Load(sala.Cargas[i]).factorZona;
  TRaw_Load(sala.Cargas[i]).PL := P * factor;
  TRaw_Load(sala.Cargas[i]).QL := P * factor * TRaw_Load(sala.Cargas[i]).QSobreP;
end;

procedure TFlucar.Cargar_Dem_Zonas(demZonas: TDAofNReal);
var
  factor, P: NReal;
  i, Zona, kZona: integer;
  carga: TRaw_Load;
  barra: TRaw_Bus;
  jcol_barra: integer;

begin
  for i := 0 to sala.Cargas.Count - 1 do
  begin
    carga := sala.cargas[i];
    zona := carga.ZONE;
    kZona := K_Zona(zona);
    if kzona < 0 then
    begin
      raise Exception.Create('No encontré la zona para la carga: ' +
        carga.nombre + ' i: ' + IntToStr(i) + ', Zona: ' + IntToStr(Zona));
    end;
    P := -demZonas[kZona];
    factor := carga.factorZona;
    if (carga.SCALE = 1) and (carga.STATUS = 1) then
    begin
      carga.PL := carga.PL + P * factor;
      carga.QL := carga.QL + P * factor * carga.QSobreP;
    end;

  end;
end;

procedure TFlucar.Limpiar_cargas;
var
  i: integer;
  carga: TRaw_Load;
begin
  for i := 0 to sala.Cargas.Count - 1 do
  begin
    carga := sala.cargas[i];
    carga.PL := 0;
    carga.QL := 0;
  end;
end;

procedure TFlucar.Flat_Start;
var
  i: integer;
  carga: TRaw_Load;
begin
  for i := 0 to sala.Barras.Count - 1 do
  begin
    sala.ProblemaCPX.zvaloresiniciales.v[i]:=numc(1,0)^;
  end;
end;


procedure TFlucar.Flat_V;
var
  i: integer;
  carga: TRaw_Load;
begin
  for i := 0 to sala.Barras.Count - 1 do
  begin
    sala.ProblemaCPX.zvalores.v[i]:=numc_rofi(mod1(sala.ProblemaCPX.zvaloresiniciales.v[i]),
    fase(sala.ProblemaCPX.zvaloresiniciales.v[i]) * 180.0 / pi)^;
  end;
end;


function TFlucar.Correr_caso(maxerr: NReal): boolean;
var
  err: NReal;
  I_I, S_CON, S_21, S_12: NComplex;
  cntiters, iEcuacion, Nudos, i, h: integer;
begin
  Nudos := sala.nNodos;
  Result := sala.ProblemaCPX.BuscarSolucion_NewtonRapson(maxerr, 20, err, cntiters);

  for iEcuacion := 1 to Nudos do
  begin
    TRaw_Bus(sala.Barras[(iEcuacion - 1)]).VM :=
      mod1(sala.ProblemaCPX.zvalores.v[iEcuacion]);
    //*TRaw_Bus(sala.Barras[(iEcuacion - 1)]).BASKV;
    TRaw_Bus(sala.Barras[(iEcuacion - 1)]).VA :=
      fase(sala.ProblemaCPX.zvalores.v[iEcuacion]) * 180.0 / pi;
  end;
  Cargar_datos_luego_de_resuelto(Result,sala);
end;


function TFlucar.analizar_sobrecarga(Zona1, Zona2: integer;
  var P12, P21: NReal): boolean;
var
  i: integer;
  linea: TRaw_Branch;
  Base:NReal;
  S_12, S_21, S_CON, I_I: NComplex;
begin
  Result := False;
  Base:=100;
  P12 := 0;
  P21 := 0;
  for i := 0 to sala.Lineas.Count - 1 do

  begin
    linea := sala.Lineas[i];
    if (TRaw_Bus(linea.Barra_I.jcol - 1).ZONE = Zona1) and
      (TRaw_Bus(linea.Barra_J.jcol - 1).ZONE = Zona2) then
    begin
      linea.Calculo_potencias(S_12, S_21, S_CON, I_I);
      P12 := P12 + (S_12.r*Base);
      P21 := P21 + (S_21.r*Base);
      if (abs(S_12.r * Base) > linea.RATEA) or (abs(S_21.r * Base) > linea.RATEA) then
        Result := True;
    end;
  end;

end;

function TFlucar.RATE_A(Zona1, Zona2: integer): double;
var
  i,k: integer;
  linea: TRaw_Branch;
  barra1, barra2: TRaw_Bus;
  trafo:TRaw_TransformerAdjust;
  RATE_A:double;
begin
  RATE_A := 0;

  for i := 0 to sala.Lineas.Count - 1 do
  begin
    linea := sala.Lineas[i];
    barra1:= Buscar_Barra(linea.Barra_I.I);
    barra2:= Buscar_Barra(linea.Barra_J.I);
    if ((barra1.ZONE = Zona1) and (barra2.ZONE = Zona2)) OR ((barra1.ZONE = Zona2) and (barra2.ZONE = Zona1)) then
    begin
      RATE_A:=RATE_A + linea.RATEA;
    end;
  end;

  for k := 0 to sala.trafosadjust.Count - 1 do
  begin
    trafo := sala.trafosadjust[k];
    barra1:= Buscar_Barra(trafo.Barra_I.I);
    barra2:= Buscar_Barra(trafo.Barra_J.I);

    if ((barra1.ZONE = Zona1) and (barra2.ZONE = Zona2)) OR ((barra1.ZONE = Zona2) and (barra2.ZONE = Zona1)) then
    begin
      RATE_A:=RATE_A + trafo.RATA1;
    end;
  end;

 Result := RATE_A;
end;
function TFlucar.analizar_sobrecargaZonas(var Pent, Psal: TMatOfNReal): boolean;
var
  i, j, k, m, NNodos: integer;
  linea: TRaw_Branch;
  trafo:TRaw_TransformerAdjust;
  S_12, S_21, S_CON, I_I: NComplex;
  Base: NReal;
begin
  Result := False;
  Base:= 100;
  NNodos := Length(Pent);
  for i := 0 to NNodos - 1 do
  begin
    vclear(Pent[i]);
    vclear(Psal[i]);
  end;

  for k := 0 to sala.Lineas.Count - 1 do
  begin
    linea := sala.Lineas[k];
    i := K_Zona(TRaw_Bus(linea.Barra_I).ZONE);
    j := K_Zona(TRaw_Bus(linea.Barra_J).ZONE);
    if not (i=j) then
    begin
      linea.Calculo_potencias(S_12, S_21, S_CON, I_I);
      PEnt[i][j] := PEnt[i][j] + S_12.r * Base;
      PSal[i][j] := PSal[i][j] - S_21.r * Base;


    end;
    end;

    for k := 0 to sala.trafosadjust.Count - 1 do
    begin
      trafo := sala.trafosadjust[k];

      i := K_Zona(TRaw_Bus(trafo.Barra_I).ZONE);
      j := K_Zona(TRaw_Bus(trafo.Barra_J).ZONE);
      if not (i=j) then
        begin
          trafo.Calculo_potencias(S_12, S_21, S_CON, I_I);
          PEnt[i][j] := PEnt[i][j] + S_12.r * Base;
          PSal[i][j] := PSal[i][j] - S_21.r * Base;

        end;
      end;

    //if (abs(S_12.r*Base) > linea.RATEA) or (abs(S_21.r*Base) > linea.RATEA) then
    //  Result := True;

end;

function TFlucar.analizar_sobrecargaZonasRATE_A(var Pent, Psal: TMatOfNReal;var HaySobre:TMatOfNReal;var sobre_:NReal): boolean;
var
  i, j, k, m, NNodos: integer;
  linea: TRaw_Branch;
  trafo:TRaw_TransformerAdjust;
  S_12, S_21, S_CON, I_I: NComplex;
  factorEnt, factorSal,cantidadLineas:TMatOfNReal;
  Base,landa,sobre1, sobre2: NReal;
begin
  Result := False;
  Base:= 100;
  landa:=1.0;

  NNodos := Length(Pent);
  setlength(factorEnt, NNodos+1, NNodos+1);
  setlength(factorSal, NNodos+1, NNodos+1);
  setlength(cantidadLineas, NNodos+1, NNodos+1);

  for i := 0 to NNodos - 1 do
  begin
    vclear(Pent[i]);
    vclear(Psal[i]);
    vclear(factorEnt[i]);
    vclear(factorSal[i]);
    vclear(cantidadLineas[i]);

    for j:=0 to NNodos - 1 do
    begin
      factorEnt[i][j]:=1;
      factorSal[i][j]:=1;
      HaySobre[i][j]:=0;
      cantidadLineas[i][j]:=0;
    end;
  end;

  for k := 0 to sala.Lineas.Count - 1 do
  begin
    linea := sala.Lineas[k];
    i := K_Zona(TRaw_Bus(linea.Barra_I).ZONE);
    j := K_Zona(TRaw_Bus(linea.Barra_J).ZONE);
    cantidadLineas[i][j]:=cantidadLineas[i][j]+1;
    cantidadLineas[j][i]:=cantidadLineas[j][i]+1;
  end;
  for k := 0 to sala.trafosadjust.Count - 1 do
  begin
    trafo := sala.trafosadjust[k];
    i := K_Zona(TRaw_Bus(trafo.Barra_I).ZONE);
    j := K_Zona(TRaw_Bus(trafo.Barra_J).ZONE);
    cantidadLineas[i][j]:=cantidadLineas[i][j]+1;
    cantidadLineas[j][i]:=cantidadLineas[j][i]+1;
  end;


  for k := 0 to sala.Lineas.Count - 1 do
  begin
    linea := sala.Lineas[k];
    i := K_Zona(TRaw_Bus(linea.Barra_I).ZONE);
    j := K_Zona(TRaw_Bus(linea.Barra_J).ZONE);
    if not (i=j) then
      begin
        linea.Calculo_potencias(S_12, S_21, S_CON, I_I);

        if S_12.r>0 then
          begin
            sobre1:= abs(S_12.r*Base)- linea.RATEA;
            if sobre1>0 then
              begin
                 if cantidadLineas[i][j]>1 then
                   factorEnt[i][j]:=factorEnt[i][j]*linea.RATEA/(abs(S_12.r)*Base);
                 HaySobre[i][j]:=HaySobre[i][j]+sobre1;
              end;
            PEnt[i][j] := PEnt[i][j] + linea.RATEA;
            PEnt[j][i] := PEnt[j][i] + 0;
          end
        else
          begin
            sobre2:= abs(S_21.r*Base)- linea.RATEA;
            if sobre2>0 then
              begin
                 if cantidadLineas[j][i]>1 then
                   factorEnt[j][i]:=factorEnt[j][i]*linea.RATEA/(abs(S_21.r)*Base);
                 HaySobre[j][j]:=HaySobre[j][i]+sobre2;
              end;
            PEnt[j][i] := PEnt[j][i] + linea.RATEA;
            PEnt[i][j] := PEnt[i][j] + 0;
          end;
      end;
  end;

    sobre_:= max( sobre1, sobre2 );

    for k := 0 to sala.trafosadjust.Count - 1 do
    begin
      trafo := sala.trafosadjust[k];
      i := K_Zona(TRaw_Bus(trafo.Barra_I).ZONE);
      j := K_Zona(TRaw_Bus(trafo.Barra_J).ZONE);
      if not (i=j) then
        begin
          trafo.Calculo_potencias(S_12, S_21, S_CON, I_I);
          if S_12.r>0 then
          begin
            sobre1:= abs(S_12.r*Base)- trafo.RATA1;
            if sobre1>0 then
              begin
                 if cantidadLineas[i][j]>1 then
                   factorEnt[i][j]:=factorEnt[i][j]*trafo.RATA1/(abs(S_12.r)*Base);
                 HaySobre[i][j]:=HaySobre[i][j]+sobre1;
              end;
            PEnt[i][j] := PEnt[i][j] + trafo.RATA1;
            PEnt[j][i] := PEnt[j][i] + 0;
          end
          else
          begin
            sobre2:= abs(S_21.r*Base)- trafo.RATA1;
            if sobre2>0 then
              begin
                 if cantidadLineas[j][i]>1 then
                   factorEnt[j][i]:=factorEnt[j][i]*trafo.RATA1/(abs(S_21.r)*Base);
                 HaySobre[j][j]:=HaySobre[j][i]+sobre2;
              end;
            PEnt[j][i] := PEnt[j][i] + trafo.RATA1;
            PEnt[i][j] := PEnt[i][j] + 0;
          end;
        end;
    end;


    if sobre1>sobre_ then sobre_:=sobre1;
    if sobre2>sobre_ then sobre_:=sobre2;

      for i:=0 to NNodos-1 do
          for j:=0 to NNodos-1 do
          begin
           if cantidadLineas[i][j]>1 then
             begin
               PEnt[i][j] := PEnt[i][j]*factorEnt[i][j];
             end
          end;


    liberarMatriz(factorEnt);
    liberarMatriz(factorSal);
    liberarMatriz(cantidadLineas);
    Result := True;

end;

function TFlucar.K_Zona(Zona: integer): integer;
var
  res, i: integer;
  Z: TRaw_Zone;
begin
  res := -1;
  for i := 0 to sala.zonas.Count - 1 do
  begin
    Z := sala.zonas[i];
    if Z.I = Zona then
    begin
      res := i;
      break;
    end;
  end;
    if res < 0 then
    begin
      raise Exception.Create('No encontré la zona: ' + IntToStr(Zona));
    end;
  Result := res;
end;


function TFlucar.Zona_Barra(barra:TRaw_Bus):integer;
begin
  result:=barra.ZONE;
end;

function TFlucar.suma_cargas_zona(Zona: integer): NReal;
var
  i, k: integer;
  res: Nreal;
  carga: TRaw_Load;
begin
  res := 0;

  for i := 0 to sala.Cargas.Count - 1 do
  begin
    carga := sala.cargas[i];
    k := carga.ZONE;
    if (k = Zona) then
      if carga.PL > 0 then
        res := res + carga.PL;
  end;
  Result := res;
end;

procedure TFlucar.carga_FactorZonaCargas(var cargasporZona: TDAofNReal);
var
  Nzonas, Zona, i, k: integer;
  carga: TRaw_Load;
begin
  Nzonas := length(cargasporZona);

  for i := 0 to sala.Cargas.Count - 1 do
  begin
    carga := sala.cargas[i];
    k := carga.ZONE;

    Zona := K_Zona(k);
    if (carga.SCALE = 1) and (carga.STATUS = 1) then
      cargasporZona[Zona] := cargasporZona[Zona] + carga.PL;
  end;

  for i := 0 to sala.Cargas.Count - 1 do
  begin
    carga := sala.cargas[i];
    k := carga.ZONE;
    Zona := K_Zona(k);

    if (carga.SCALE = 1) and (carga.STATUS = 1) then
      carga.factorZona := carga.PL / cargasporZona[Zona];
    if (carga.PL < 0) then
      carga.factorZona := 0;

  end;

end;


function TFlucar.suma_cargas_total(area: integer): NReal;
var
  i, k: integer;
  res: Nreal;
  carga: TRaw_Load;
begin
  res := 0;
  for i := 0 to sala.Cargas.Count - 1 do
  begin
    carga := sala.cargas[i];
    k := carga.AREA;
    if (k = area) then
      if carga.PL > 0 then
        res := res + carga.PL;
  end;
  Result := res;
end;

function TFlucar.Buscar_Generador(barra: longint; codigo: string): TRaw_Generator;
var
  a: TRaw_Generator;
  buscando: boolean;
  k, Ngenes: integer;
begin
  buscando := True;
  k := 0;
  Ngenes := sala.Generadores.Count;
  while (buscando and (k < Ngenes)) do
  begin
    a := sala.generadores[k];

    if (a.I = barra) and (a.ID = codigo) then
      buscando := False
    else
      Inc(k);
  end;
  if buscando then
    Result := nil
  else
    Result := a;
end;

function TFlucar.Buscar_Barra(barra: longint): TRaw_Bus;
var
  a: TRaw_Bus;
  buscando: boolean;
  k, Nbarras: integer;
begin
  buscando := True;
  k := 0;
  Nbarras := sala.Barras.Count;
  while (buscando and (k < Nbarras)) do
  begin
    a := sala.barras[k];

    if (a.I = barra)  then
      buscando := False
    else
      Inc(k);
  end;
  if buscando then
    Result := nil
  else
    Result := a;
end;

procedure TFlucar.Free;
begin
  sala.Free;
end;

end.
