unit uprincipal;


interface

uses
  Classes,
  SysUtils,
  xMatDefs,
  AlgebraC,
  cronomet,
  MatCPX,
  EntDat,
  servic1,
  usistema,
  NR1,
  MatAdm,
  salida,
  checklim;

var
  Cronometro: TCrono;
  NombreArch, NombreArchent, NombreArchsal, extensionent, extensionsal: string;
  f:      Text;
  NIT:    longint;
  convergencia: boolean;
  Xv, Xn: TVectComplex;
  epsx, epsf: NReal;

procedure Principal(archi: string);


implementation

{+doc
+NOMBRE:  FLU 4.0
+CREACION:  9/97
+MODIFICACION:
+AUTORES:  MARIO VIGNOLO
+REGISTRO:
+TIPO:  Programa Pascal
+PROPOSITO:  Resoluci¢n del problema de flujo de carga utilizando el
        m‚todo de Newton-Raphson.
        Incorporaci¢n de l¡mites (Qmin,Qmax) para las barras de
        generaci¢n y voltaje controlado y de (Vmin,Vmax) para las
        barras de carga.
        Incoporaci¢n de transformadores sin taps.
        Incorporaci¢n de Imax para l¡neas y transformadores.
        Incorporaci¢n de barras con reguladores de tensi¢n
        (transformadores con taps).

+PROYECTO:  FLUCAR

+REVISION:
+AUTOR:
+DESCRIPCION:
-doc}

{
  El programa resuleve el Flujo de Carga mediante el m‚todo de Newton-
Raphson en coordenadas polares de un sistema en el que se pueden tener
barras de carga (se fija P y Q), barras de generacion y voltaje controlado
(se fija V y P), barras donde se controle la tension mediante un regulador
(se fija P, Q y V) y una barra flotante (con V y delta fijos).
A partir de la matriz de impedancias de la red y de los datos iniciales
de las barras se genera la matriz de Newton-Raphson Jo(inicial). Las
variables que no son datos se inicializan de acuerdo a los valores iniciales
ingresados en el archivo de datos de entrada. Luego se resuelve el sistema Jo
y a partir de los resultados se calcula el nuevo sistema J1.
El proceso se repite hallando los sucesivos Jk hasta verificar la condicion
de parada. Esta consiste en que DFX<=toleranciaF y DX<=toleranciaX y que
(DVreg<=tolerancia o que se alcancen los limites de los taps en los
reguladores) o que el numero de iteraciones supere la cantidad de MAXNIT.
  Este programa lee los datos de un archivo de texto que debe
organizarse de la siguiente manera: VER ARCHIVO ZEJER3.DAT.  El archivo que
debe pasarse como par metro no debe tener la extensi¢n .DAT.  Los resultados
del flujo apareceran un archivo del mismo nombre pero con la extensi¢n .RES.
}



procedure Help;
begin
  writeln;
  writeln('===========================================>PROYECTO FLUCAR 97');
  writeln(' FLUCAR VER 4.0');
  writeln('__________________________________________');
  writeln(' Sintaxis: ');
  writeln('              FLU40 NomArch ');
  writeln;
  writeln(' NombArch : Nombre del archivo con las definiciones del sistema sin extensi¢n');
  writeln('');
  writeln('Los resultados se almacenan en el archivo del mismo nombre con extensi¢n .RES');
  readln;
  halt(1);
end;

procedure Principal(archi: string);
var
  k: integer;

begin
  k := pos('.', archi);
  NOmbreArch := copy(archi, 1, k - 1);
  extensionent := '.dat';
  extensionsal := '.res';
  NombreArchent := NombreArch + extensionent;
  NombreArchsal := NombreArch + extensionsal;

  BarraFlotante := nil;
  Barras      := TList.Create;
  BarrasdeCarga := TList.Create;
  BarrasdeGenyVcont := TList.Create;
  Barrasconregulador := TList.Create;
  BarrasOrdenadas := TList.Create;
  Impedancias := TList.Create;
  Cuadripolos := TList.Create;
  Trafos      := TList.Create;
  Reguladores := TList.Create;
  LeerDatos(NombreArchent);
  writeln;
  writeln('LA INFORMACION ESTA SIENDO PROCESADA.....');
  writeln;
  mAdmitancias := TSistema.Create_crearsistema(NBarras);
  FormarSistema;
  {$IFDEF DEB_NR}
  Admitancias.muestrasistema;
  {$ENDIF}
  Xv := TVectComplex.Create_Init(NBarras + NBarrasdeCarga + NBarrasconregulador - 1);
  calcularXv(Xv, BarrasOrdenadas, Reguladores, NBarras, NBarrasdeCarga, NBarrasconregulador);
  NIT  := 0;
  epsx := TOLERANCIA / 10;
  epsf := TOLERANCIA;
  Cronometro.Borre;
  Cronometro.Cuente;
  newtonraphson(Xv, NIT, convergencia, epsx, epsf, 0.5, MAXNITs);
  Cronometro.Pare;
  actualizarbarras(BarrasOrdenadas, mAdmitancias, Xv, Nbarras, Nbarrasdecarga,
    NBarrasconregulador);
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
  reordenarbarras(BarrasOrdenadas, Barras);
  writeBarras(f, Barras);
  writeFlujosDePotencia(f);
  writeln(f);
  writeln(f, 'VERIFICACION DE LIMITES:');
  writeln(f);
  checkbarrs(f);
  checkimpds(f);
  checkcuadri(f);
  checktrafos(f);
  checkreg(f);
  writeln(f, 'NITs: ', NIT, ' converge: ', convergencia, ' Tiempo: ',
    Cronometro.Cuenta: 8: 4, 's');
  Close(f);
  {$IFDEF DEB_FLU}
  Write(memavail, 'bytes libres');
  readln;
  {$ENDIF}

  liberar(Barras);

  //  BarraFlotante.Free; // me parece que no va
  BarrasdeCarga.Free;
  BarrasdeGenyVcont.Free;
  Barrasconregulador.Free;
  BarrasOrdenadas.Free;

  liberar(Impedancias);
  liberar(Cuadripolos);
  liberar(Trafos);
  liberar(Reguladores);
  mAdmitancias.Free_destruirsistema;
  {$IFDEF DEB_FLU}
  Write(memavail, 'bytes libres');

  readln;
  {$ENDIF}

end;


end.

