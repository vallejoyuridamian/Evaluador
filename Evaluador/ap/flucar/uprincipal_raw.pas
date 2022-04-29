unit uprincipal_raw;
interface
uses
  Classes,
  SysUtils,
  xMatDefs,
  AlgebraC,
  cronomet,
  MatCPX,
  uactoresflucar,
  ucpxresolvecuacs,
  //salida,
  //checklim,
  flujoraw;
  //IntList,

  // umatrizadmitancias;
var
  Cronometro: TCrono;
  NombreArch, NombreArchent, NombreArchsal, extensionent, extensionsal: string;
  f:      Text;
  NIT:    longint;
  convergencia: boolean;
  Xv, Xn: TVectComplex;
  epsx, epsf: NReal;

procedure Principal_Raw(archi: string;tapsvar:boolean);
procedure correr_raw_con_modificaciones(archi_raw, archi_modif: string);

implementation


procedure correr_raw_con_modificaciones(archi_raw, archi_modif: string);
var
  f:      textfile;
  k:      integer;
  a1, a2: integer;
  sala:   TSalaFlucar;

begin
  k := pos('.', archi_raw);
  NOmbreArch := copy(archi_raw, 1, k - 1);
  extensionent := '.raw';
  extensionsal := '.res';
  NombreArchent := NombreArch + extensionent;
  NombreArchsal := NombreArch + extensionsal;


  sala := TSalaFlucar.Create;

  leerraw(sala, NombreArchent);

  writeln;
  writeln('LA INFORMACION ESTA SIENDO PROCESADA.....');
  writeln;

  (***** aquí va la preparación de la sala ***)
  sala.cargue;
  cargar_taps(sala);


  (** ????? ANTENCION ???? hace lo mismo en cualquier ad los dos casos del IF !!!!*)
  if (sala.nodos_reguladores.IntCount = 0) then  //si no hay taps
    sala.ProblemaCPX := TProblemaCPX.Create(sala.nNodos, sala.nNodos * 3)
  else
    sala.ProblemaCPX := TproblemaCPX.Create(sala.nNodos, sala.nNodos * 3);

  Cronometro.Borre;
  Cronometro.Cuente;
  Preparar_sistema(sala);
  Cargar_problema(sala);



  {Escritura de resultados}
  Assign(f, NombreArchsal);
  Rewrite(f);
  writeln(f, '              P  R  O  Y  E  C  T  O    F  L  U  C  A  R');
  writeln(f);
  writeln(f);
  writeln(f);
  writeln(f, 'DATOS: ', NombreArchent);
  writeln(f);
  writeln(f, 'RESULTADOS: ', NombreArchsal);
  writeln(f);
  writeln(f);
  writeln(f, ' RESULTADOS: ');
  writeln(f);

  //writeBarras(f,Barras);
  //writeFlujosDePotencia(f);
  writeln(f);
  writeln(f, 'VERIFICACION DE LIMITES:');
  writeln(f);
  Cronometro.Pare;
  writeln(f, 'NITs: ', NIT, ' converge: ', convergencia, ' Tiempo: ',
    Cronometro.Cuenta: 8: 4, 's');
  Close(f);
  //{$ENDIF}


  sala.Free;
  writeln('FIN DEL FLUJO DE CARGAS');

end;

procedure Principal_Raw(archi: string;tapsvar:boolean);
var
  k:    integer;
  sala: TSalaFlucar;

begin
  k := pos('.', archi);
  NOmbreArch := copy(archi, 1, k - 1);
  extensionent := '.raw';
  extensionsal := '.res';
  NombreArchent := NombreArch + extensionent;
  NombreArchsal := NombreArch + extensionsal;

  sala := TSalaFlucar.Create;

  leerraw(sala, NombreArchent);

  writeln;
  writeln('LA INFORMACION ESTA SIENDO PROCESADA.....');
  writeln;

  sala.cargue;
  sala.TapsVariables:=tapsvar;
  if sala.TapsVariables then
     cargar_taps(sala);

  if not sala.TapsVariables then  //si no hay taps
     sala.ProblemaCPX := TproblemaCPX.Create(sala.nNodos, sala.nNodos * 2)
  else
      sala.ProblemaCPX := TproblemaCPX.Create(sala.nNodos, sala.nNodos * 3);

  Cronometro.Borre;
  Cronometro.Cuente;
  Preparar_sistema(sala);

  Cargar_problema(sala);
  {Escritura de resultados}
  //Assign(f, NombreArchsal);
  //Rewrite(f);
  //writeln(f, '              P  R  O  Y  E  C  T  O    F  L  U  C  A  R');
  //writeln(f);
  //writeln(f);
  //writeln(f);
  //writeln(f, 'DATOS: ', NombreArchent);
  //writeln(f);
  //writeln(f, 'RESULTADOS: ', NombreArchsal);
  //writeln(f);
  //writeln(f);
  //writeln(f, ' RESULTADOS: ');
  //writeln(f);
  ////reordenarbarras(BarrasOrdenadas,Barras);
  ////writeBarras(f,Barras);
  ////writeFlujosDePotencia(f);
  //writeln(f);
  //writeln(f, 'VERIFICACION DE LIMITES:');
  //writeln(f);
  Cronometro.Pare;
  writeln('NITs: ', NIT, ' converge: ', convergencia, ' Tiempo: ',
    Cronometro.Cuenta: 8: 4, 's');

  //writeln(f, 'NITs: ', NIT, ' converge: ', convergencia, ' Tiempo: ',
  //  Cronometro.Cuenta: 8: 4, 's');
  //Close(f);
  //{$ENDIF}

  sala.Free;
  writeln('FIN DEL FLUJO DE CARGAS');
end;

end.

