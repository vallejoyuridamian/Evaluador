unit flujoraw;
interface

uses
  Classes, SysUtils,
  xMatDefs,
  urawdata,
  usistema, uactoresflucar,
  AlgebraC, ucpxresolvecuacs, MatCPX, Dialogs, uauxiliares;


procedure leerraw( sala: TSalaFlucar; archi: string);
procedure Preparar_sistema( sala: TSalaFlucar );
procedure Cargar_problema( sala: TSalaFlucar );
procedure Cargar_solo_problema( sala: TSalaFlucar );
procedure Cargar_datos_luego_de_resuelto(Convergio:boolean;sala: TSalaFlucar );
procedure cargar_taps( sala: TSalaFlucar );

function conectividad(var MatAdmitancias: TMatrizDeAdmitancias; var lugar: integer): boolean;

implementation
uses
  ufunciones_flucar;


procedure leerraw( sala: TSalaFlucar; archi: string);

var

  k, I: integer;
  f:    textfile;
  modulo: double;
  caso: TRaw_CaseIdentification;
  carga: TRaw_Load;
  generador: TRaw_Generator;
  linea: TRaw_Branch;
  linea_Imp_cero: TRaw_Branch_Impedancia_cero;
  trafoAdjust: TRaw_TransformerAdjust;
  area: TRaw_AreaInterchange;
  termDC2vias: TRaw_TwoTerminal_DCLine;
  Fixedshunt: TRaw_FixedShunt;
  shunt: TRaw_SwitcheShunt;
  ICTable: TRaw_TransformerImpedanceCorrectionTables;
  MultiDC: TRaw_MultiTerminal_DCLine;
  Multilinea: TRaw_MultiSectionLineGrouping;
  zona: TRaw_Zone;
  trasarea: TRaw_InterAreaTransfer;
  dueno: TRaw_Owner;
  fact: TRaw_Facts;
  r: string;
  carpeta: string;

begin

  SysUtils.decimalseparator := '.';
  k := pos('.', archi);
  NOmbreArch := copy(archi, 1, k - 1);
  extensionent := '.raw';
  //extensionsal:='.sal';
  NombreArchent := NombreArch + extensionent;
  //NombreArchsal:=NombreArch+extensionsal;

  Assign(f, NombreArchent);
        {$I-}
  Reset(f);
        {$I+}
  if ioresult <> 0 then
  begin
    // si falló, intento buscar el archivo en la ruta local.
    r:= extractFileName( NombreArchEnt );
    Assign(f, r);
          {$I-}
    Reset(f);
          {$I+}
    if ioresult <> 0 then
       raise Exception.Create(' Error abriendo archivo ' + NombreArchent);
  end;
  // 1 Se lee el descriptor del caso

  caso := TRaw_CaseIdentification.LoadFromtext(sala, f);
  sala.actores.Add( caso );

  writeln;
  writeln(caso.ic);
  writeln(caso.sbase);
  writeln(caso.ds1);
  writeln(caso.ds2);
  writeln;

  // 2 Se leen las barras
  leer_barras_raw(sala, f);
  //readln();
  // 3 Se leen las cargas


  //Cargas:=Tlist.create;
  carga := TRaw_Load.loadfromtext(sala, f);
  while carga.I <> 0 do
  begin
    //writeln(CARGA.I, ' ' + #9, carga.PL: 1: 2, ' ' + #9, carga.QL: 1: 2);
    sala.Cargas.add( carga );
    sala.actores.add( carga );
    carga := TRaw_Load.loadfromtext(sala, f);
  end;
  writeln;   writeln('ESTO es el fin de las CARGAS  ',sala.cargas.Count);
  carga.Free;

  // 4 si es la version 32 leo los Fixed Shunts

  if RAW_VER >= 32 then
  begin
    Fixedshunt := TRaw_FixedShunt.loadfromtext(sala, f);
    while Fixedshunt.I <> 0 do
    begin
      //writeln(Fixedshunt.I);
      sala.ShuntsFijos.add( Fixedshunt );
      sala.actores.add( FixedShunt );
      Fixedshunt := TRaw_FixedShunt.loadfromtext(sala, f);
    end;
    writeln;   writeln('ESTO es el fin de las FIXED SHUNTS ', sala.shuntsfijos.Count);
    Fixedshunt.Free;
  end;



  // 5 Se leen los generadores

  //generadores:=TList.create;
  generador := TRaw_Generator.loadfromtext(sala, f);
  while generador.I <> 0 do
  begin
    //writeln(generador.I);
    sala.Generadores.add(generador);
    sala.actores.add( generador );
    generador := TRaw_Generator.loadfromtext(sala, f);
  end;
  //writeln;   writeln('ESTO es el fin de las GENERADORES ',generadores.Count);
  generador.Free;

  // 6 Se leen las lineas

  //lineas:=TList.create;
  linea := TRaw_Branch.loadfromtext(sala, f);
  while linea.I <> 0 do
  begin
   if linea.ST = 1 then
   begin
        //writeln(linea.I, ' ' + #9, linea.J);
        modulo := mod1(numc(linea.RR, linea.X)^);
      if modulo > 1.01E-4 then
      begin
      linea.resolver_referencias;
      linea.IMP_Zero:=FALSE;
      sala.lineas.add(linea);
      sala.actores.add( linea );
      end
      else
        begin
        linea.resolver_referencias;
        //linea.Barra_J.IMP_CERO:=True;
        linea.IMP_Zero:=True;
          if not (linea.Barra_I.IMP_CERO) and linea.Barra_J.IMP_CERO then
             begin
               linea.Barra_I.PrincipalLinImpCero:= true;
               linea.Barra_J.BarraExtImpCero:=linea.Barra_I.I;
               linea.Barra_J.IMP_CERO:=True;
               //linea.Barra_J:=linea.Barra_I;
             end;
          if linea.Barra_I.IMP_CERO and not (linea.Barra_J.IMP_CERO) then
             begin
               linea.Barra_J.PrincipalLinImpCero:= true;
               linea.Barra_I.BarraExtImpCero:=linea.Barra_J.I;
               linea.Barra_I.IMP_CERO:=True;
               //linea.Barra_I:=linea.Barra_J;
             end;
           if not(linea.Barra_I.IMP_CERO) and not(linea.Barra_J.IMP_CERO) then
             begin
               if linea.Barra_I.PrincipalLinImpCero then
                 begin
                      linea.Barra_J.BarraExtImpCero:=linea.Barra_I.I;
                      linea.Barra_J.IMP_CERO:=True;
                      //linea.Barra_J:=linea.Barra_I;
                 end
                 else
                 if linea.Barra_J.PrincipalLinImpCero then
                  begin
                       linea.Barra_I.BarraExtImpCero:=linea.Barra_J.I;
                       linea.Barra_I.IMP_CERO:=True;
                       //linea.Barra_I:=linea.Barra_J;
                  end
                else
                    begin
                      linea.Barra_I.PrincipalLinImpCero:= true;
                      linea.Barra_J.BarraExtImpCero:=linea.Barra_I.I;
                      linea.Barra_J.IMP_CERO:=True;
                      //linea.Barra_J:=linea.Barra_I;
                    end;

             end;
           if linea.Barra_I.IMP_CERO and linea.Barra_J.IMP_CERO then
             begin
               linea.Barra_I.PrincipalLinImpCero:= true;
               linea.Barra_J.BarraExtImpCero:=linea.Barra_I.BarraExtImpCero;
               linea.Barra_J.IMP_CERO:=True;
               //linea.Barra_J:=linea.Barra_I;
             end;
           linea.resolver_referencias;
           sala.LineasImpCero.add(linea);
           sala.actores.add( linea );
        end;
    end;
    linea := TRaw_Branch.loadfromtext(sala, f);
  end;
  //writeln;   writeln('ESTO es el fin de las LINEAS ', lineas.Count);
  linea.Free;
  //  readln();
  // 7 Se leen los transformadores

  sala.trafosAdjust := TList.Create;
  trafoAdjust  := TRaw_TransformerAdjust.loadfromtext(sala, f);
  while trafoAdjust.I <> 0 do
  begin
    if trafoAdjust.STAT = 1 then
    begin
      //writeln(trafoAdjust.I, ' ' + #9, trafoAdjust.J);
      trafoAdjust.resolver_referencias;
      sala.trafosAdjust.add(trafoAdjust);
      sala.actores.add( trafoAdjust );
    end;
    trafoAdjust := TRaw_TransformerAdjust.loadfromtext(sala, f);

  end;
  writeln;
  writeln('ESTO es el fin de las TRAFOS ');
  trafoAdjust.Free;
  //writeln(trafosAdjust.Count);
  // readln();
  // 8 Se leen los areas

  sala.areas := TList.Create;
  area  := TRaw_AreaInterchange.loadfromtext(sala, f);
  while area.I <> 0 do
  begin
    //writeln(area.I, ' ' + #9, area.ARNAME);
    sala.areas.add(area);
    sala.actores.Add( area );
    area := TRaw_AreaInterchange.loadfromtext(sala, f);
  end;
  writeln;
  writeln('ESTO es el fin de las AREAS');
  area.Free;


  // 9 Se leen las terminales DC de 2 vias

  sala.TerminalesDC := TList.Create;
  termDC2vias  := TRaw_TwoTerminal_DCLine.loadfromtext(sala, f);
  while termDC2vias.I <> 0 do
  begin
    sala.TerminalesDC.add(termDC2vias);
    sala.actores.add( termDC2vias );
    termDC2vias := TRaw_TwoTerminal_DCLine.loadfromtext(sala, f);
  end;
  writeln;
  writeln('ESTO es el fin de los terminales DC de 2 vias');
  termDC2vias.Free;

  // 10 Se leen lo0s VSC En la 26 se leen los switched shunts

  if RAW_VER <= 32 then
  begin
    shunt := TRaw_SwitcheShunt.loadfromtext(sala, f);
    while shunt.I <> 0 do
    begin
      //writeln(shunt.I);
      sala.Shunts.add(shunt);
      sala.actores.add( shunt );
      shunt := TRaw_SwitcheShunt.loadfromtext(sala, f);
    end;
    writeln;
    writeln('ESTO es el fin de las SHUNTS');
    shunt.Free;
  end
  else
  begin
    // se leen los VSC hay que implementarlos4
    readln(f, r);
    try
      I := nextint(r);
    finally
    end;
  end;


  // Se leen las tablas de correccion de las impedancias de los TRAFOS

  sala.ICTRATables := TList.Create;
  ICTable     := TRaw_TransformerImpedanceCorrectionTables.loadfromtext(sala, f);
  while ICTable.I <> 0 do
  begin
    sala.ICTRATables.add(ICTable);
    sala.actores.add( ICTable );
    ICTable := TRaw_TransformerImpedanceCorrectionTables.loadfromtext(sala, f);
  end;
  writeln;
  writeln('ESTO es el fin de las tablas de correccion de las impedancias de los TRAFOS');
  ICTable.Free;


  // Se leen las terminales DC de multiples vias

  sala.TerminalesDCMult := TList.Create;
  MultiDC := TRaw_MultiTerminal_DCLine.loadfromtext(sala, f);
  while MultiDC.I <> 0 do
  begin
    sala.TerminalesDCMult.add(MultiDC);
    sala.actores.Add( MultiDC );
    MultiDC := TRaw_MultiTerminal_DCLine.loadfromtext(sala, f);
  end;
  writeln;
  writeln('ESTO es el fin de las terminales DC de multiples vias');
  MultiDC.Free;

  // Se leen las lineas agrupadas por seccion

  sala.LineasSeccion := TList.Create;
  Multilinea    := TRaw_MultiSectionLineGrouping.loadfromtext(sala, f);
  while Multilinea.I <> 0 do
  begin
    sala.LineasSeccion.add( multiLinea);
    sala.actores.Add( multiLinea );
    Multilinea := TRaw_MultiSectionLineGrouping.loadfromtext(sala, f);
  end;
  writeln;
  writeln('ESTO es el fin de las lineas agrupadas por seccion');
  Multilinea.Free;

  // Se leen las zonas

  sala.zonas := TList.Create;
  zona  := TRaw_Zone.loadfromtext(sala, f);
  while zona.I <> 0 do
  begin
    //writeln(zona.I);
    sala.zonas.add(zona);
    sala.actores.Add( zona );
    zona := TRaw_Zone.loadfromtext(sala, f);
  end;
  writeln;
  writeln('ESTO es el fin de las ZONAS');
  zona.Free;


  // Se leen los datos de transferencia entre areas

  sala.trasfareas := TList.Create;
  trasarea   := TRaw_InterAreaTransfer.loadfromtext(sala, f);
  while trasarea.ARFROM <> 0 do
  begin
    sala.trasfareas.add(trasArea);
    sala.actores.Add( trasArea);
    trasarea := TRaw_InterAreaTransfer.loadfromtext(sala, f);
  end;
  writeln;
  writeln('ESTO es el fin de las transferencia entre AREAS');
  trasarea.Free;

  // Se leen los owners

  sala.owners := TList.Create;
  dueno  := TRaw_Owner.loadfromtext(sala, f);
  while dueno.I <> 0 do
  begin
    //writeln(dueno.I);
    sala.owners.add(dueno);
    sala.actores.Add( dueno );
    dueno := TRaw_Owner.loadfromtext(sala, f);
  end;
  writeln;
  writeln('ESTO es el fin de los OWNERS');
  dueno.Free;

  // Se leen los datos de control de los FACTS

  sala.facts := TList.Create;
  fact  := TRaw_Facts.loadfromtext(sala, f);
  while fact.N <> 0 do
  begin
    sala.facts.add(fact);
    sala.actores.Add( fact );
    fact := TRaw_Facts.loadfromtext(sala, f);
  end;
  writeln;
  writeln('ESTO es el fin de los FACTS');
  fact.Free;

  if RAW_VER = 32 then
  begin
    shunt := TRaw_SwitcheShunt.loadfromtext(sala, f);
    while shunt.I <> 0 do
    begin
      //writeln(shunt.I);
      sala.Shunts.add(shunt);
      sala.actores.Add( shunt );
      shunt := TRaw_SwitcheShunt.loadfromtext(sala, f);
    end;
    writeln;
    writeln('ESTO es el fin de las SHUNTS ', sala.shunts.Count);
    shunt.Free;
  end;

  //writeln;   writeln('ESTO EL FIN DE LECTURA DE FLUJOS RAW');
  Close(f);
  //readln;
  //sala.resolver_referencias;
end;

function conectividad(var MatAdmitancias: TMatrizDeAdmitancias; var lugar: integer): boolean;
var
  i, n, k:   integer;
  resultado: NComplex;
  arbol:     array of boolean;
begin
  n := MatAdmitancias.numeroDeEcuaciones;
  setlength(arbol, n + 1);
  Result := True;
  lugar  := 1;
  resultado:=complex_NULO;
  for i := 1 to n do
    arbol[i] := False;

  for i := 1 to n do
    for k := 1 to n do
    begin
      if i <> k then
      begin
        if MatAdmitancias.ValCoef(resultado, i, k) and
         not EsCero( resultado )  then
        begin
          arbol[k] := True;
        end;
      end;
    end;
  for i := 1 to n do
  begin
    writeln(arbol[i]);
    if not arbol[i] then
    begin
      Result := False;
      lugar  := i;
    end;
  end;

end;



procedure dump_barras_to_txt(sala: TSalaFlucar; archi: string );
var
  f: textfile;
  i: integer;
  ab: TRaw_Bus;
begin
  assignfile( f, archi );
  rewrite( f );
  writeln( f, 'NBarras: ',#9, sala.Barras.Count );
  writeln( f, 'Name', #9, 'AREA', #9,  'I', #9,  'IDE' , #9, 'IMP Cero' );
  for i := 0 to sala.Barras.Count - 1 do
  begin
    ab:= sala.Barras[i];
    writeln( f, ab.Name, #9, ab.AREA, #9,  ab.I, #9,  ab.IDE, #9,ab.IMP_CERO );
  end;
  closefile( f );
end;



procedure dump_cargas_to_txt( sala: TSalaFlucar; archi: string );
var
  f: textfile;
  i: integer;
  a: TRaw_Load;
begin
  assignfile( f, archi );
  rewrite( f );
  writeln( f, 'NCargas: ',#9, sala.Cargas.Count );
  writeln( f, 'ID', #9, 'AREA', #9,  'I', #9,  'PL', #9,  'QL' );
  for i := 0 to sala.Cargas.Count - 1 do
  begin
    a:= sala.Cargas[i];
    writeln( f, a.ID, #9, a.AREA, #9,  a.I, #9,  a.PL, #9,  a.QL );
  end;
  closefile( f );
end;

procedure dump_MY_to_txt( sala: TSalaFlucar; archi: string );
var
  f: textfile;
  i,j: integer;
  a: NComplex;
  ab1,ab2: TRaw_Bus;
begin
  assignfile( f, archi );
  rewrite( f );
  //writeln( f, 'NCargas: ',#9, sala.Cargas.Count );
  //writeln( f, 'ID', #9, 'AREA', #9,  'I' );
  for i := 1 to sala.Barras.Count  do
  begin
        for j := 1 to sala.Barras.Count  do
        begin
          ab1:= sala.Barras[i-1];
          ab2:= sala.Barras[j-1];
          a:= sala.MY.e( i, j );
          writeln( f, a.r, #9 , a.i, #9); //ab1.I, #9,ab2.I, #9
        end;
        //writeln(f,' ');
  end;
  closefile( f );
end;


procedure Preparar_sistema( sala: TSalaFlucar );
var
  i, j, k, lug, numbarras, contador, id, INI,FIN : integer;
  rr: boolean;
  barratemp: TRaw_Bus;
  Z12,Zii,Zjj:NComplex;
  modulo:NReal;

begin


  //dump_barras_to_txt( sala, 'lst_barras1.xlt' );

  for i := 0 to sala.Barras.Count - 1 do
  begin
    TRaw_Bus( sala.Barras[i]).cargue;
  end;


  if RAW_VER >= 32 then
  begin
    for i := 0 to sala.ShuntsFijos.Count - 1 do
    begin
      TRaw_FixedShunt(sala.ShuntsFijos[i]).cargue;
    end;
  end;

  for i := 0 to sala.lineas.Count - 1 do
  begin
    TRaw_Branch(sala.lineas[i]).cargue;
  end;



  if RAW_VER >= 32 then
  begin
    for i := 0 to sala.trafosAdjust.Count - 1 do
    begin
      TRaw_TransformerAdjust(sala.trafosAdjust[i]).cargue;
    end;
  end;

  //writeln('TRAFOS  ',sala.trafosAdjust.Count);

  for i := 0 to sala.shunts.Count - 1 do
  begin
    //writeln(i, ' ', sala.shunts.Count - 1);
    TRaw_SwitcheShunt(sala.shunts[i]).cargue;
  end;



  //dump_cargas_to_txt(sala,  'lst_cargas.xlt' );

  for i := 0 to sala.Cargas.Count - 1 do
  begin
    TRaw_Load(sala.Cargas[i]).cargue;
  end;


  for i := 0 to sala.generadores.Count - 1 do
  begin
    TRaw_Generator(sala.generadores[i]).cargue;
  end;
  //dump_MY_to_txt(sala,  'sistema2.xlt' );

  //writeln('ESTO ES EL FIN DE LA PREPARACION DEL SISTEMA');

end;

procedure cargar_taps( sala: TSalaFlucar );
var
  i,j,k: integer;
  ata: TRaw_TransformerAdjust;
begin
  j:=0;
    for i := 0 to sala.trafosAdjust.Count - 1 do
    begin
      ata:= sala.trafosAdjust[i];
      //ata.resolver_referencias;
        case ata.STAT of
        1: // en servicio
        begin
          if (ata.COD1)=1 then
          begin
            if (ata.K = 0) then
            begin

              if ata.Barra_I.conectada and ata.Barra_J.conectada then
              begin
                if (ata.CNTRL=1) then
                begin
                  if TRaw_Bus(sala.Barras[ata.Barra_I.jcol-1]).IDE=2 then
                     begin
                     end
                  else
                  begin
                     sala.nodos_reguladores.Add(ata.I);
                     sala.nodos_regulados.Add(ata.J);
                     TRaw_Bus(sala.Barras[ata.Barra_I.jcol-1]).IDE:=2;
                     //TRaw_Bus(sala.Barras[ata.Barra_J.jcol-1]).IDE:=2;
                     //writeln('regulador en barra  ', ata.I);
                     j:=j+1;
                  end;
                end;

              end
              else
                raise Exception.Create( 'flujoraw.cargar_taps .. alguna barra desconectada: '+IntToStr( ata.I )+', '+IntToStr( ata.j ) );

            end
            else
              raise Exception.Create('CargarTaps() ..Trafo de 3 bobinados ... el regulador de tab puede estar en los 3 bobinados; TrafoAdjust: '+ata.Name );
            //barratempo:=I_to_barra(ata.J);
            //barratempo.IDE:=2;
          end;
        end;
        0: ; // Out of service (no hago nada)
        2:  raise Exception.Create('CargarTaps Only winding 2 out of service SIN IMPLEMENTAR; TrafoAdjust:' + ata.Name );
        3:  raise Exception.Create('CargarTaps Only winding 3 out of service SIN IMPLEMENTAR; TrafoAdjust:' + ata.Name );
        4:  raise Exception.Create('CargarTaps Only winding 1 out of service SIN IMPLEMENTAR; TrafoAdjust:' + ata.Name );
        else
          raise Exception.Create( 'CargarTaps() ... ata.STAT: '+IntToStr( ata.STAT )+'; TrafoAdjust:' + ata.Name );
        end;
    end;
  writeln('ESTO ES EL FIN DE CARGAR LOS REGULADORES   reg: ', sala.trafosadjust.Count);
  writeln('Numero de reguladores ' , j);
  system.readln;
end;

procedure Cargar_problema( sala: TSalaFlucar );
var

  iEcuacion, Nudos, kkvar: integer;
  resOk: boolean;
  err,k:   NReal;
  cntiters, i,h: integer;
  S_12, S_21, S_CON, I_I: NComplex;
  libres, nolibres, g: integer;
begin

  ufunciones_flucar.salaActiva:= sala;

  Nudos := sala.nNodos;
  libres := 0;
  nolibres := 0;
  g := 0;


  for iEcuacion := 1 to Nudos do
    begin
      sala.problemaCPX.InscribirEcuacion(fi, iEcuacion);
      //writeln( 'fi'+IntToStr( inodo )+': '+FloatToStrF( res.r, ffFixed, 8,2 )+'+j'+FloatToStrF( res.i, ffFixed, 8,2 ),' abs ', mod1(res):8:0 );
    end;


  for iEcuacion := 1 to Nudos do
  begin
    case TRaw_Bus(sala.Barras[(iEcuacion - 1)]).IDE of
      1:
      begin  // barra PQ o de carga

        sala.ProblemaCPX.DefinirVariable(iEcuacion, CPX_POLAR,
          0.5, 1.5, TRaw_Bus(sala.Barras[(iEcuacion - 1)]).VM, False,
         -1.6, +1.6, TRaw_Bus(sala.Barras[(iEcuacion - 1)]).VA / 180.0 * pi, False);

        sala.ProblemaCPX.DefinirVariable(iEcuacion + Nudos, CPX_RECTANGULAR,
          TRaw_Bus(sala.Barras[(iEcuacion - 1)]).PL / 100, True,
          TRaw_Bus(sala.Barras[(iEcuacion - 1)]).QL / 100, True);

        libres   := libres + 2;
        nolibres := nolibres + 2;
        //writeln('nodo tipo 1 I ', TRaw_Bus(sala.Barras[(iEcuacion - 1)]).I, ' ', g);
        //writeln('nodo tipo 1 NAME ', TRaw_Bus(sala.Barras[(iEcuacion - 1)]).NAME, ' ', g);
        //writeln('nodo tipo 1 v ', TRaw_Bus(sala.Barras[(iEcuacion - 1)]).VM);
        //writeln('nodo tipo 1 arg ', TRaw_Bus(sala.Barras[(iEcuacion - 1)]).VA);
        //writeln('nodo tipo 1 PL', TRaw_Bus(sala.Barras[(iEcuacion - 1)]).PL);
        //writeln('nodo tipo 1 QL', TRaw_Bus(sala.Barras[(iEcuacion - 1)]).QL);

      end;

      2:
      begin // barra PV o de generacion o voltaje controlado

        sala.ProblemaCPX.DefinirVariable(iEcuacion, CPX_POLAR,
          0.5, 1.5, TRaw_Bus(sala.Barras[(iEcuacion - 1)]).VM, True,
          -1.6, +1.6, TRaw_Bus(sala.Barras[(iEcuacion - 1)]).VA / 180.0 * pi, False);
        libres   := libres + 1;
        nolibres := nolibres + 1;



        if (sala.nodos_reguladores.Find(TRaw_Bus(sala.Barras[(iEcuacion - 1)]).I) > -1) then
        begin
          sala.ProblemaCPX.DefinirVariable(iEcuacion + Nudos, CPX_RECTANGULAR,
            TRaw_Bus(sala.Barras[(iEcuacion - 1)]).PL / 100, True,
            //dejar fijos P, Q y variar tm (abajo)
            TRaw_Bus(sala.Barras[(iEcuacion - 1)]).QL / 100, True);
          nolibres := nolibres + 2;

          if sala.TapsVariables then
          sala.ProblemaCPX.DefinirVariable(iEcuacion + Nudos + Nudos, CPX_POLAR,
            0.5, 1.5, 1.00, False,
            //agregar variable tm
            0, 1, 0, True);
          libres   := libres + 1;
          nolibres := nolibres + 1;

        end
        else
        begin
          sala.ProblemaCPX.DefinirVariable(iEcuacion + Nudos, CPX_RECTANGULAR,
            1, 1, TRaw_Bus(sala.Barras[(iEcuacion - 1)]).PL / 100, True,
            //dejar fijo P y variar Q
            TRaw_Bus(sala.Barras[(iEcuacion - 1)]).QMIN / 100,
            TRaw_Bus(sala.Barras[(iEcuacion - 1)]).QMAX / 100,
            TRaw_Bus(sala.Barras[(iEcuacion - 1)]).QL / 100, False);
          //writeln('la generacion de la maquina es ',TRaw_Bus(sala.Barras[(iEcuacion - 1)]).PL: 6: 6 , ' MW');
          //writeln('la max reactiva de la maquina es ',TRaw_Bus(sala.Barras[(iEcuacion - 1)]).QMAX: 6: 6 , ' MVA');
          //writeln('la min reactiva de la maquina es ',TRaw_Bus(sala.Barras[(iEcuacion - 1)]).QMIN: 6: 6 , ' MVA');
         libres   := libres + 1;
          nolibres := nolibres + 1;
        end;
        g := g + 1;
        writeln('nodo tipo 2 I ', TRaw_Bus(sala.Barras[(iEcuacion - 1)]).I, ' ', g);
        //writeln('nodo tipo 2 NAME ', TRaw_Bus(sala.Barras[(iEcuacion - 1)]).NAME, ' ', g);
        //writeln('nodo tipo 2 v ', TRaw_Bus(sala.Barras[(iEcuacion - 1)]).VM);
        //writeln('nodo tipo 2 arg ', TRaw_Bus(sala.Barras[(iEcuacion - 1)]).VA);
        writeln('nodo tipo 2 PL ', TRaw_Bus(sala.Barras[(iEcuacion - 1)]).PL, ' ', g);
        writeln('nodo tipo 2 QL ', TRaw_Bus(sala.Barras[(iEcuacion - 1)]).QL, ' ', g);
        writeln('nodo tipo 2 QMIN ', TRaw_Bus(sala.Barras[(iEcuacion - 1)]).QMIN, ' ', g);
        writeln('nodo tipo 2 QMAX ', TRaw_Bus(sala.Barras[(iEcuacion - 1)]).QMAX, ' ', g);


      end;

      3:
      begin  // barra Slack (Flotante)

        sala.ProblemaCPX.DefinirVariable(iEcuacion, CPX_POLAR,
          TRaw_Bus(sala.Barras[(iEcuacion - 1)]).VM, True,
          TRaw_Bus(sala.Barras[(iEcuacion - 1)]).VA / 180.0 * pi, True);

        sala.ProblemaCPX.DefinirVariable(iEcuacion + Nudos, CPX_RECTANGULAR,
          -9999, 9999, -75, False, -9999, 9999, -30, False);

        libres   := libres + 2;
        nolibres := nolibres + 2;
        //writeln('nodo tipo 3 I ', TRaw_Bus(sala.Barras[(iEcuacion - 1)]).I, ' ', g);
        //writeln('nodo tipo 3 NAME ', TRaw_Bus(sala.Barras[(iEcuacion - 1)]).NAME, ' ', g);
        //writeln('nodo tipo 3 v ', TRaw_Bus(sala.Barras[(iEcuacion - 1)]).VM);
        //writeln('nodo tipo 3 arg ', TRaw_Bus(sala.Barras[(iEcuacion - 1)]).VA);
        //writeln('nodo tipo 3 PL', TRaw_Bus(sala.Barras[(iEcuacion - 1)]).PL);
        //writeln('nodo tipo 3 QL', TRaw_Bus(sala.Barras[(iEcuacion - 1)]).QL);


      end;

    end;

    ////si el nodo es regulador, agregar tm variable, de lo contrario agregar un tm fijo
    if (sala.nodos_reguladores.Find(TRaw_Bus(sala.Barras[(iEcuacion - 1)]).I) > -1) then
    begin
    end
    else
    begin
      if sala.TapsVariables then
          sala.ProblemaCPX.DefinirVariable(iEcuacion + Nudos + Nudos, CPX_POLAR,
            1,1,1, True,
            0,0, 0, true);
          nolibres := nolibres + 2;
    end;
    //writeln('libres ', libres, '   no libres  ', nolibres);

  end;


  for iEcuacion := 1 to Nudos do
    for kkvar := 1 to Nudos do
    begin
      sala.ProblemaCPX.InscribirDerivada(dfidro_V, iEcuacion, kkvar, 1);
      sala.ProblemaCPX.InscribirDerivada(dfidalfa_V, iEcuacion, kkvar, 2);
      sala.ProblemaCPX.InscribirDerivada(dfidP, iEcuacion, kkvar + Nudos, 1);
      sala.ProblemaCPX.InscribirDerivada(dfidQ, iEcuacion, kkvar + Nudos, 2);
      if sala.TapsVariables then
      begin
                sala.ProblemaCPX.InscribirDerivada(dfidtm, iEcuacion, kkvar + 2 * Nudos, 1);
                sala.ProblemaCPX.InscribirDerivada(dfidargtm, iEcuacion, kkvar + 2 * Nudos, 2);

      end;

    end;


  writeln('variables libres  ', libres);
  writeln('variables NO libres  ', nolibres);
  //sala.MY.writetoTXT('sistema.xlt');

 // dump_MY_to_txt(sala,  'sistema2.xlt' );
  //readln;


  resOk := sala.ProblemaCPX.BuscarSolucion_NewtonRapson(1e-3, 1000, err, cntiters);
  //readln;
  if not resOK then
  begin
    writeln('No CONVERGIO ' + sala.ProblemaCPX.errMsg);
    writeln('.... PRESINE ENTER PARA CONTINUAR....' );
    system.readln;
    for iEcuacion := 1 to Nudos do
    begin
      Writeln('nudo ', iecuacion, '   ');
      writeln('|V|= ', mod1(sala.ProblemaCPX.zvalores.v[iEcuacion]): 6: 6);
      writeln('arg(V)= ', fase(sala.ProblemaCPX.zvalores.v[iEcuacion]) * 180.0 / pi: 6: 6);
      //writeln(p.zvalores.v[iEcuacion].r: 6:6);
      //writeln(p.zvalores.v[iEcuacion].i: 6:6);

      TRaw_Bus(sala.Barras[(iEcuacion - 1)]).VM := mod1(sala.ProblemaCPX.zvalores.v[iEcuacion]);
      TRaw_Bus(sala.Barras[(iEcuacion - 1)]).VA := fase(sala.ProblemaCPX.zvalores.v[iEcuacion]);
      writeln('P= ', sala.ProblemaCPX.zvalores.v[iEcuacion + Nudos].r * 100: 6: 6);
      writeln('Q= ', sala.ProblemaCPX.zvalores.v[iEcuacion + Nudos].i * 100: 6: 6);
      writeln('tm= ', 1/sala.ProblemaCPX.zvalores.v[iEcuacion + 2 * Nudos].r: 6: 6);
      writeln('Im(tm)= ', sala.ProblemaCPX.zvalores.v[iEcuacion + 2 * Nudos].i: 6: 6);
    end;
    writeln('Nro de iteraciones  ', cntiters);
  end
  else
  begin
    writeln(' FELICITACIONES CONVERGIO ' + sala.ProblemaCPX.errMsg);
    //readln;
    for iEcuacion := 1 to Nudos do
    begin
      TRaw_Bus(sala.Barras[(iEcuacion - 1)]).VM := mod1(sala.ProblemaCPX.zvalores.v[iEcuacion]);//*TRaw_Bus(sala.Barras[(iEcuacion - 1)]).BASKV;
      TRaw_Bus(sala.Barras[(iEcuacion - 1)]).VA := fase(sala.ProblemaCPX.zvalores.v[iEcuacion])* 180.0 / pi;

      Writeln('nudo ', iecuacion, '  N: ',TRaw_Bus(sala.Barras[(iEcuacion - 1)]).I, ' ',TRaw_Bus(sala.Barras[(iEcuacion - 1)]).NAME, ' ',
      '|V|= ', mod1(sala.ProblemaCPX.zvalores.v[iEcuacion]): 3: 3,' < ', fase(sala.ProblemaCPX.zvalores.v[iEcuacion]) * 180.0 / pi: 6: 6, ' ',
      'P= ', sala.ProblemaCPX.zvalores.v[iEcuacion + Nudos].r * 100: 3: 3,' Q= ', sala.ProblemaCPX.zvalores.v[iEcuacion + Nudos].i * 100: 3: 3);


      if not (sala.nodos_reguladores.IntCount = 0) then
      begin
        writeln('tm= ', 1/sala.ProblemaCPX.zvalores.v[iEcuacion + 2 * Nudos].r: 4: 4,' < ', sala.ProblemaCPX.zvalores.v[iEcuacion + 2 * Nudos].i: 4: 4);

      end;



    end;
    //readln;
    writeln('Nro de iteraciones  ', cntiters);
    writeln('');
    for i := 0 to sala.lineas.Count - 1 do
    begin
      if (sala.nodos_reguladores.Find(TRaw_Branch(sala.lineas[i]).I) > -1) then
      begin
        h:=TRaw_Branch(sala.lineas[i]).Barra_I.jcol;
        TRaw_Branch(sala.lineas[i]).RATIO := 1/(sala.ProblemaCPX.zvalores.v[h + 2 * Nudos].r);// TRaw_Branch(sala.lineas[i]).RATIO/(sala.ProblemaCPX.zvalores.v[h + 2 * Nudos].r);    //   1/sala.ProblemaCPX.zvalores.v[h + 2 * Nudos].r;
      end;


      TRaw_Branch(sala.lineas[i]).Calculo_potencias(S_12, S_21, S_CON, I_I);
      writeln(' linea ', TRaw_Branch(sala.lineas[i]).I, ' ', TRaw_Branch(sala.lineas[i]).J, '  ', ' P12 = ', S_12.r * 100: 6: 2,
              ' Q12 = ', S_12.i * 100: 6: 2,' P21=', S_21.r * 100: 6: 2 , ' Q21=', S_21.i * 100: 6: 2, ' PCON = ', S_CON.r * 100: 6: 2,
              ' QCON = ', S_CON.i * 100: 6: 2, ' ratio ', TRaw_Branch(sala.lineas[i]).RATIO: 6: 3 );


    end;

  end;
  //sala.MY.muestrasistema;
end;

procedure Cargar_solo_problema( sala: TSalaFlucar );
var

  iEcuacion, Nudos, kkvar: integer;
  resOk: boolean;
  err,k:   NReal;
  cntiters, i,h: integer;
  S_12, S_21, S_CON, I_I: NComplex;
  libres, nolibres: integer;
begin


  ufunciones_flucar.salaActiva:= sala;

  Nudos := sala.nNodos;
  libres := 0;
  nolibres := 0;

  for iEcuacion := 1 to Nudos do
  begin
    sala.problemaCPX.InscribirEcuacion(fi, iEcuacion);
  end;


  for iEcuacion := 1 to Nudos do
  begin
    case TRaw_Bus(sala.Barras[(iEcuacion - 1)]).IDE of
      1:
      begin  // barra PQ o de carga

        sala.ProblemaCPX.DefinirVariable(iEcuacion, CPX_POLAR,
          0.5, 1.5, TRaw_Bus(sala.Barras[(iEcuacion - 1)]).VM, False,
         -1.6, +1.6, TRaw_Bus(sala.Barras[(iEcuacion - 1)]).VA / 180.0 * pi, False);

        sala.ProblemaCPX.DefinirVariable(iEcuacion + Nudos, CPX_RECTANGULAR,
          TRaw_Bus(sala.Barras[(iEcuacion - 1)]).PL / 100, True,
          TRaw_Bus(sala.Barras[(iEcuacion - 1)]).QL / 100, True);

        libres   := libres + 2;
        nolibres := nolibres + 2;
      end;

      2:
      begin // barra PV o de generacion o voltaje controlado

        sala.ProblemaCPX.DefinirVariable(iEcuacion, CPX_POLAR,
          0.5, 1.5, TRaw_Bus(sala.Barras[(iEcuacion - 1)]).VM, True,
          -1.6, +1.6, TRaw_Bus(sala.Barras[(iEcuacion - 1)]).VA / 180.0 * pi, False);
        libres   := libres + 1;
        nolibres := nolibres + 1;



        if (sala.nodos_reguladores.Find(TRaw_Bus(sala.Barras[(iEcuacion - 1)]).I) > -1) then
        begin
          sala.ProblemaCPX.DefinirVariable(iEcuacion + Nudos, CPX_RECTANGULAR,
            TRaw_Bus(sala.Barras[(iEcuacion - 1)]).PL / 100, True,
            //dejar fijos P, Q y variar tm (abajo)
            TRaw_Bus(sala.Barras[(iEcuacion - 1)]).QL / 100, True);
          nolibres := nolibres + 2;


          sala.ProblemaCPX.DefinirVariable(iEcuacion + Nudos + Nudos, CPX_POLAR,
            0.5, 1.5, 1.00, False,
            //agregar variable tm
            0, 1, 0, True);
          libres   := libres + 1;
          nolibres := nolibres + 1;

        end
        else
        begin
          sala.ProblemaCPX.DefinirVariable(iEcuacion + Nudos, CPX_RECTANGULAR,
            1, 1, TRaw_Bus(sala.Barras[(iEcuacion - 1)]).PL / 100, True,
            //dejar fijo P y variar Q
            TRaw_Bus(sala.Barras[(iEcuacion - 1)]).QMIN / 100,
            TRaw_Bus(sala.Barras[(iEcuacion - 1)]).QMAX / 100,
            TRaw_Bus(sala.Barras[(iEcuacion - 1)]).QL / 100, False);
         libres   := libres + 1;
         nolibres := nolibres + 1;
        end;


      end;

      3:
      begin  // barra Slack (Flotante)

        sala.ProblemaCPX.DefinirVariable(iEcuacion, CPX_POLAR,
          TRaw_Bus(sala.Barras[(iEcuacion - 1)]).VM, True,
          TRaw_Bus(sala.Barras[(iEcuacion - 1)]).VA / 180.0 * pi, True);

        sala.ProblemaCPX.DefinirVariable(iEcuacion + Nudos, CPX_RECTANGULAR,
          -9999, 9999, TRaw_Bus(sala.Barras[(iEcuacion - 1)]).PL, False,
          -9999, 9999, TRaw_Bus(sala.Barras[(iEcuacion - 1)]).QL, False);

        libres   := libres + 2;
        nolibres := nolibres + 2;
      end;

    end;

    ////si el nodo es regulador, agregar tm variable, de lo contrario agregar un tm fijo
    if (sala.nodos_reguladores.Find(TRaw_Bus(sala.Barras[(iEcuacion - 1)]).I) > -1) then
    begin
    end
    else
    begin
      if sala.TapsVariables then
         sala.ProblemaCPX.DefinirVariable(iEcuacion + Nudos + Nudos, CPX_POLAR,
         1,1,1, True,
         0,0, 0, true);
      nolibres := nolibres + 2;

    end;


  end;

//writeln('libres ', libres, '   no libres  ', nolibres);
  for iEcuacion := 1 to Nudos do
    for kkvar := 1 to Nudos do
    begin
      sala.ProblemaCPX.InscribirDerivada(dfidro_V, iEcuacion, kkvar, 1);
      sala.ProblemaCPX.InscribirDerivada(dfidalfa_V, iEcuacion, kkvar, 2);
      sala.ProblemaCPX.InscribirDerivada(dfidP, iEcuacion, kkvar + Nudos, 1);
      sala.ProblemaCPX.InscribirDerivada(dfidQ, iEcuacion, kkvar + Nudos, 2);
      if sala.TapsVariables then
         begin
           sala.ProblemaCPX.InscribirDerivada(dfidtm, iEcuacion, kkvar + 2 * Nudos, 1);
           sala.ProblemaCPX.InscribirDerivada(dfidargtm, iEcuacion, kkvar + 2 * Nudos, 2);
         end;
    end;
end;


procedure Cargar_datos_luego_de_resuelto(Convergio:boolean;sala: TSalaFlucar );
var

  iEcuacion, Nudos, kkvar: integer;
  err,k:   NReal;
  cntiters, i,h: integer;
  S_12, S_21, S_CON, I_I: NComplex;

  begin
  Nudos := sala.nNodos;
    if not Convergio then
    begin
      writeln('No CONVERGIO ' + sala.ProblemaCPX.errMsg);
      writeln('.... PRESINE ENTER PARA CONTINUAR....' );
      system.readln;
      for iEcuacion := 1 to Nudos do
      begin
        TRaw_Bus(sala.Barras[(iEcuacion - 1)]).VM := mod1(sala.ProblemaCPX.zvalores.v[iEcuacion]);
        TRaw_Bus(sala.Barras[(iEcuacion - 1)]).VA := fase(sala.ProblemaCPX.zvalores.v[iEcuacion]);
      end;
      writeln('Nro de iteraciones  ', cntiters);
    end
    else
    begin
      //writeln(' FELICITACIONES CONVERGIO ' + sala.ProblemaCPX.errMsg);
      //readln;
      for iEcuacion := 1 to Nudos do
      begin
        TRaw_Bus(sala.Barras[(iEcuacion - 1)]).VM := mod1(sala.ProblemaCPX.zvalores.v[iEcuacion]);//*TRaw_Bus(sala.Barras[(iEcuacion - 1)]).BASKV;
        TRaw_Bus(sala.Barras[(iEcuacion - 1)]).VA := fase(sala.ProblemaCPX.zvalores.v[iEcuacion])* 180.0 / pi;

        //Writeln('nudo ', iecuacion, '  N: ',TRaw_Bus(sala.Barras[(iEcuacion - 1)]).I, ' ',TRaw_Bus(sala.Barras[(iEcuacion - 1)]).NAME, ' ',
        //'|V|= ', mod1(sala.ProblemaCPX.zvalores.v[iEcuacion]): 3: 3,' < ', fase(sala.ProblemaCPX.zvalores.v[iEcuacion]) * 180.0 / pi: 6: 6, ' ',
        //'P= ', sala.ProblemaCPX.zvalores.v[iEcuacion + Nudos].r * 100: 3: 3,' Q= ', sala.ProblemaCPX.zvalores.v[iEcuacion + Nudos].i * 100: 3: 3);

        if not (sala.nodos_reguladores.IntCount = 0) then
        begin
          writeln('tm= ', 1/sala.ProblemaCPX.zvalores.v[iEcuacion + 2 * Nudos].r: 4: 4,' < ', sala.ProblemaCPX.zvalores.v[iEcuacion + 2 * Nudos].i: 4: 4);

        end;



      end;
      //readln;
      //writeln('Nro de iteraciones  ', cntiters);
      //writeln('');
      for i := 0 to sala.lineas.Count - 1 do
      begin
        if (sala.nodos_reguladores.Find(TRaw_Branch(sala.lineas[i]).I) > -1) then
        begin
          h:=TRaw_Branch(sala.lineas[i]).Barra_I.jcol;
          TRaw_Branch(sala.lineas[i]).RATIO := 1/(sala.ProblemaCPX.zvalores.v[h + 2 * Nudos].r);// TRaw_Branch(sala.lineas[i]).RATIO/(sala.ProblemaCPX.zvalores.v[h + 2 * Nudos].r);    //   1/sala.ProblemaCPX.zvalores.v[h + 2 * Nudos].r;
        end;
        TRaw_Branch(sala.lineas[i]).Calculo_potencias(S_12, S_21, S_CON, I_I);
      end;

    end;

  end;

end.

