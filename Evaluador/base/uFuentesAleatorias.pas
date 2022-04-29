unit uFuentesAleatorias;

interface

uses
  uCosa, uCosaConNombre,
  ucosaparticipedemercado,
  xMatDefs,
  Classes, uFichasLPD,
  uFechas, fddp, SysUtils, Math,
  uconstantesSimSEE, uFuncionesReales,
  uGlobs, uEstados, uAuxiliares, uSimplex;

type
  //Para type-casts de punteros
  TVLArrOfNReal_1 = array[1..10000] of NReal;
  TVLArrOfNReal_0 = array[0.. 9999] of NReal;

  TClaseDeFuenteAleatoria = class of TFuenteAleatoria;

(*+doc TfichaFuncion
Estas fichas contienen la informacion de las funciones asociadas a la
fuente aleatoria
-doc*)

  { TListFuenteAleatoria }

  TListFuenteAleatoria=class(TListaDeCosasConNombre)
    


  end;

  TFichaFuncion = class(TCosa)
  public
    //La funcion a calcular. Es de R->R
    func_rr: TFRenR;
    //El numero del borne de la fuente del que la función toma su entrada
    numeroBorneEntrada: integer;
    //El numero del borne de la fuente en el que la función pone su salidas
    numeroBorneSalida: integer;

    // Número de Poste al que corresponden el o los bornes de salida. (0 si no está asociado a un poste)
    kPoste: integer;

    //Crea una ficha de funcion func asignada al borne numeroBorne
    constructor Create(capa: integer; func: TFRenR; numeroBorneEntrada,
      numeroBorneSalida, kPoste: integer);
    function pfunc: TCosa; virtual;
    procedure Free; override;
  end;

  TFichaFuncion_biborne = class(TFichaFuncion)
  public
    func_r2r: TFR2enR;
    numeroBorneEntrada1, numeroBorneEntrada2: integer;

    constructor Create(capa: integer; func: TFR2enR; numeroBorneEntrada1,
      numeroBorneEntrada2, numeroBorneSalida, kPoste: integer);
    procedure Free; override;
    function pfunc: TCosa; override;
  end;

(*+doc TFuenteAleatoria
Las fuentes cuentan con una lista de funciones asignadas a sus bornes.
Cada funcion tiene asignado un borne simple (borne sin funcion) de la
fuente del cual toma su entrada. Al sortear la fuente primero calcula
el valor de los bornes simples y luego los de las funciones. De esta forma
si se deben realizar n sorteos en un paso de tiempo y por lo tanto
integrar sus resultados, se calculan n valores de la funcion para n sorteos
distintos y lo que se integra es la salida de la funcion.
-doc*)

  { TFuenteAleatoria }

  TFuenteAleatoria = class(TCosaParticipeDeMercado)
  protected

    //La lista con funciones asociadas a esta fuente
    FuncionesRegistradas: TListaDeCosas {of TFichaFuncion};

    // realiza los sorteos en el array aRB. Este procedimiento es llamado
    // por sorteosDelPaso para sortear cada uno de los subsorteos que sea
    // necesario. Cada tipo de fuente debe reescribir este método con
    // su forma particular de sortear.
    procedure SortearEntradaRB(var aRB: NReal); virtual; abstract;

    // pone el valor esperado en la entrada aRB. Es llamado en sorteos del paso
    // cuando el parámetro sortear es pasado en false.
    // cada tipo de fuente debe reescribir este método.
    procedure ValorEsperadoEntradaRB(var aRB: Nreal); virtual; abstract;

    procedure calcular_jsInicioFinal; virtual;

  public

    (**************************************************************************)
    (* A T R I B U T O S   P E R S I S T E N T E S                            *)
    (**************************************************************************)
    //La duracion del paso de sorteo en horas o 0 si se quiere usar la
    //la duracion del paso de tiempo
    durPasoDeSorteoEnHoras: integer;

    // Nombres de los bornes
    NombresDeBornes_Publicados: TStringList;

    // Método de resumen en caso de ser esclavizada en un sub-muestreo.
    // Si es TRUE, se resumen promediando, si es FALSE se resume con
    // un sorteo uniforme entre las muestras lo que reproduce la varianza
    // de la fuente original (sin esclavizar).
    ResumirPromediando: boolean;
    (**************************************************************************)

    // En el esclabizador SubMuestreado por defecto esta opción se pone a TRUE
    // los actores que hacen sus propios resúmenes deben ponerla a FALSE.
    flg_ResumirBorneras: boolean;

    // Apunta al Esclavizador si la fuente está esclavizada.
    Esclavizador: TFuenteAleatoria;

    // vector con los valores ( RB, BC, X, Xs ) de uso privado de la fuente.
    // El orden en la bornera es entradas de ruido blanco (RB), bornes calculados (BC)
    // estado (X) y estado siguiente (Xs). Esta estructura es utilizada por los
    // esclavizadores de la fuentes para sub o sobre muestrearlas.
    Bornera: TDAOfNreal;

    // indica para los BC si pertenecen a un poste.
    // un -1 quiere decir que el borne no está asaociado a un poste
    // un 0 es el poste 1, 1 el 2 y así sucesivamente.
    kPostes_bornes: TDAOfNInt;


    dt_PasoDeSorteo: double; // auxiliar, se calcula al PrepararMemoria

    // Variable auxiliar.
    //Si no hay sorteos no hay que estar sorteando las entradasRB se fijan a
    //su valor esperado por lo que no hay que estarlas asignando cada paso.
    //Solo se deben asignar al cambiar la ficha de parametros dinamicos de la
    //fuente.
    //Al realizar el primer "sorteo" se fija en true y en los pasos siguientes
    //no se asignan valores
    // OJO, esto se hace en entradasRB, pero si la fuente depende de otra fuente
    // no debe asignarse a TRUE pues sino no se verán las variaciones ocasionadas
    // por la otra fuente.
    entradasFijadas: boolean;

    // Suponemos todos los valores arreglados en una BORNERA
    // Primero estan los valores correspondientes a las entradas
    // de ruido blanco (RB). Estas entradas son el resultado de aplicar
    // los sorteos que correspondan para la etapa.
    // Los siguientes bornes son los estados (X) de inicio de etapa para las
    // fuentes que tengan estado y por último, los estados proyectados (Xs)
    // para fin de la etapa para el caso de fuentes con estado.
    // El cálculo de Xs = f( X, RB, BC, k ) es lo que llamamos proyeccion del estado.
    // Luego los valores correspondientes a el resultado
    // de la aplicación de funciones registradas (Bornes Calculados o BC)

    // Estos son índices auxiliares (redundantes) para facilitar el indexado
    // de las borneras. Estos se calculan en preparar_memoria.
    jPrimer_RB_, jUltimo_RB_: integer; // Ruido Blanco
    jPrimer_Wa_, jUltimo_Wa_: integer; // Ruido Blanco para Expansión Ruida
    jPrimer_X, jUltimo_X:   integer;
    jPrimer_Xs, jUltimo_XS: integer;
    jPrimer_BC, jUltimo_BC: integer;

    constructor Create(capa: integer; nombre: string;
      xdurPasoDeSorteoEnHoras: integer; resumirPromediando: boolean);
  reintroduce;

    function Rec: TCosa_RecLnk; override;
    procedure BeforeRead(version, id_hilo: integer); override;
    procedure AfterRead(version, id_hilo: integer); override;

    procedure Free; override;

    //Pide la memoria para la bornera, puede ser redefinido
    procedure PrepararMemoria(Catalogo: TCatalogoReferencias; globs: TGlobs); virtual;

    procedure InicioSim; override;
    procedure InicioOpt; override;


    function cronicaIdInicio: string; virtual; abstract;
    procedure Sim_Cronica_Inicio; virtual;

    //Es llamado para las fuentes sin estado en CF
    //Fija el estado interno de la fuente en un valor determinado (p.ej el
    //valor esperado o un sorteo de una distribución de probabilidad del estado
    //si se conoce)
    procedure fijarEstadoInterno; virtual;

    // Realiza los sorteos,
    // no aplica funciones, ni calcula estados, ni salidas
    // unicamente llena los nSubSorteos vectores de entradasRB
    procedure SorteosDelPaso(xsortear: boolean); virtual;

    // Calcula el tramo de bornesPrivados calculados (BC) a partir de las
    // funciones registradas y del resto de los bornes
    //Solo redefinir en los esclavizadores
    procedure calcular_BC; virtual;

    // Calcula el estado siguiente. Solo calcula Xs, no lo aplica.
    procedure calcular_Xs; virtual;

    // realiza los sorteos, calcula Xs, calcula funciones y evoluciona estados
    procedure sorteosDelPaso_EsclavizadaEnSubmuestreo(xsortear: boolean);


    // Fija el estado "central" del fin del paso sobre el que se
     // realiza el desarrollo de Taylor para tener la linealización
     // de la función de costo futuro. Por defecto, la proyección
     // es suponer que el estado al final es el mismo que al principio
     // pero hay actores que necesitan proyectar otro valor.
     // En particula, si el estado representa una cadena de retardos,
     // la proyección lógica del estado es el SHIFT de la cadena
    procedure ProyectarEstado; virtual;



    function CostoDirectoDelPaso: NReal; virtual;

    // las fuentes con estado tienen que calcular el delta costo
    // por el delta_X resultante del sorteo
    procedure PrepararPaso_ps; virtual;

    // carga el deltacosto en el término indep del simplex
    procedure opt_cargue(s: TSimplex);

    // estas funciones son auxiliares y no permiten dimensionar
    // las borneras y calcular los j de inicio y final de cada tramo.
    function dim_RB: integer; virtual;
    function dim_Wa: integer; virtual;
    function dim_X: integer; virtual;
    function dim_Xs: integer;
    function dim_BC: integer; virtual;

    // esta función devuelve dim_RB+dim_X+dim_Xs es para usar antes de llamar al preparar memoria
    // pues recien ahí se calculan los jsInicioFinal
    function jPrimer_BC_calculado: integer;

    // Calcula el delta costo asignable a evolución involuntaria del estado.
    function calc_DeltaCosto: NReal; virtual;

    //Retorna el indice del array donde ira el valor de ese borne
    //Esta funcion no puede usar los jS pues aun no estan calculados cuando
    //se la llama
    function IdBorne(nombre: string; func: TFRenR): integer; overload; virtual;
    function IdBorne(nombre: string): integer; overload; virtual;

    function NombreBorne( idBorne: integer ): string; virtual;

    // por defecto publica la bornera.
    procedure PubliVars; override;

    function descBornera: string; virtual;
    procedure Dump_Variables(var f: TextFile; charIndentacion: char); virtual;

    //Agrega una funcion a la fuente aleatoria.
    //La fuente sortea primero el borne del que la funcion tomara su entrada y
    //calcula la salida de la funcion
    //retorna el numero de borne en el que hay que pedir la salida de la funcion
    // Si la función debe ser calculada sobre todos pos postes poner kPoste = -1
    function registrarFuncion(funcion: TFRenR; nombreBorne: string;
      kPoste: integer): integer;
    //Quita la función en el borne indicado y lo deja libre para ser usado
    //por el próximo que pida una función
    procedure desregistrarFuncion(numeroBorne: integer);


    //Agrega una funcion a la fuente aleatoria.
    //La fuente sortea primero el borne del que la funcion tomara su entrada y
    //calcula la salida de la funcion
    //retorna el numero de borne en el que hay que pedir la salida de la funcion
    // Si la función debe ser calculada sobre todos pos postes poner kPoste = -1
    function registrarFuncion_biborne(funcion: TFR2enR;
      nombreBorne1, nombreBorne2: string; kPoste: integer): integer;

    //Por defecto retorna false, redifinir en la clase hija si hace referencia
    //a una fuente
    function referenciaFuente(fuente: TFuenteAleatoria): boolean; virtual;

    //Agrega un borne a la bornera
    procedure AddBorne(nombre: string);

    procedure setCalculosAdicionalesEsclavizadorAlCambiarFicha(
      procCalcsAdicionalesEsclavizador: TProcCalculosAdicionalesDeObjeto); virtual;

     // Retorna El Esclavizador si No está activo ResumirPromediando y si
     // la fuente está Esclavizada en un SubMuestreo
     // Retorna NIL en caso contraio
     function ResumirMaxVar(globs: TGlobs): TFuenteAleatoria;
     


  end;

  TProcNotificarCambioFichaEsclava = procedure of object;
  TClaseDeFuenteAleatoriaConFichas = class of TFuenteAleatoriaConFichas;

(*+doc TFuenteAleatoriaConFichas
Padre de todas las clases de fuentes aleatorias que admiten parámetros
dinámicos.
Se le agrega la propiedad lpd, para soporte de la lista de parámetros
dinámicos y los métodos:
 - PrepararMemoria
 - RegistrarParametrosDinamicos
 - TipoFichaFuente
-doc*)

  { TFuenteAleatoriaConFichas }

  TFuenteAleatoriaConFichas = class(TFuenteAleatoria)
  public
    procNotificarCambioFichaEsclava: TProcNotificarCambioFichaEsclava;

    constructor Create(capa: integer; nombre: string;
      xdurPasoDeSorteoEnHoras: integer; resumirPromediando: boolean;
      lpd: TFichasLPD);

    function Rec: TCosa_RecLnk; override;
    procedure BeforeRead(version, id_hilo: integer); override;
    procedure AfterRead(version, id_hilo: integer); override;


    procedure Free; override;

    procedure PrepararMemoria( Catalogo: TCatalogoReferencias; globs: TGlobs);
      override;

    class function TipoFichaFuente: TClaseDeFichaLPD; virtual; abstract;
    procedure setCalculosAdicionalesEsclavizadorAlCambiarFicha(
      procCalcsAdicionalesEsclavizador: TProcCalculosAdicionalesDeObjeto); override;
    function InfoAd_: string; override;

    procedure ActivarCapas( const CapasActivas: TDAOfNInt ); override;

  end;


  // clase de ayuda para especificar lisas de fuetes_bornes en los actores.
  // ejemplo de uso en "ugter_basico_PyCVariable

  { TFuenteAleatoria_Borne }

  TFuenteAleatoria_Borne = class(TCosa)
  private
    idBorne: integer;

  public

    fuente: TFuenteAleatoria;
    borne:  string;

    constructor Create(capa: integer; fuente: TFuenteAleatoria; borne: string);
     
    function Rec: TCosa_RecLnk; override;
    procedure BeforeRead(version, id_hilo: integer); override;
    procedure AfterRead(version, id_hilo: integer); override;

    function Create_Clone(Catalogo: TCatalogo; idHilo: integer ): TCosa; override;
    class function DescClase: string; override;
    procedure Free; override;
    function DarIdBorne( const Referente: TCosaConNombre ): integer;

  end;



 // notificamos a la fuente que se cambio su ficha de parámetros dinámicos
 // En principio, el uso es poner entradasFijadas:= false para que se
 // vuelvan a calcular las entradas conlos valores esperados en caso de
 // que no estemos haciendo sorteos.
procedure cambioFichaPDFuenteAleatoria(fuente: TCosa);

 //Para testear llamarlo en la simulación luego de
 //  globs.ActualizadorLPD.ActualizarFichasHasta( globs.FechaInicioDelpaso );
 //y antes de
 //  PrepararPaso_as;
procedure testSim(fuente: TFuenteAleatoria);

procedure AlInicio;
procedure AlFinal;

implementation

procedure cambioFichaPDFuenteAleatoria(fuente: TCosa);
begin
  TFuenteAleatoria(fuente).entradasFijadas := False;
end;

{ TListFuenteAleatoria }










 //-------------------------
 // Métodos de TFichaFuncion
 //=========================

constructor TFichaFuncion.Create(capa: integer; func: TFRenR;
  numeroBorneEntrada, numeroBorneSalida, kPoste: integer);
begin
  inherited Create( capa );
  self.func_rr := func;
  self.numeroBorneEntrada := numeroBorneEntrada;
  self.numeroBorneSalida := numeroBorneSalida;
  self.kPoste  := kPoste;
end;


function TFichaFuncion.pfunc: TCosa;
begin
  Result := self.func_rr;
end;

procedure TFichaFuncion.Free;
begin
  if self.func_rr <> nil then
    FreeAndNil(func_rr);
  inherited Free;
end;

//**************************************

constructor TFichaFuncion_biborne.Create(capa: integer; func: TFR2enR;
  numeroBorneEntrada1, numeroBorneEntrada2, numeroBorneSalida, kPoste: integer);
begin
  TCosa.Create( capa );
  self.func_r2r := func;
  self.func_rr  := nil;
  self.numeroBorneEntrada1 := numeroBorneEntrada1;
  self.numeroBorneEntrada2 := numeroBorneEntrada2;
  self.numeroBorneSalida := numeroBorneSalida;
  self.kPoste   := kPoste;
end;

function TFichaFuncion_biborne.pfunc: TCosa;
begin
  Result := self.func_r2r;
end;


procedure TFichaFuncion_biborne.Free;
begin
  self.func_r2r.Free;
  inherited Free;
end;




 //----------------------------
 // Métodos de TFuenteAleatoria
 //============================

constructor TFuenteAleatoria.Create(capa: integer; nombre: string; xdurPasoDeSorteoEnHoras: integer;
  resumirPromediando: boolean);
begin
  inherited Create(capa, nombre);
  self.durPasoDeSorteoEnHoras := xdurPasoDeSorteoEnHoras;
  SetLength(bornera, 0);
  setlength(kpostes_bornes, 0);
  NombresDeBornes_Publicados := TStringList.Create;
  FuncionesRegistradas    := TListaDeCosas.Create(capa, 'FuncionesRegistradas');
  self.ResumirPromediando := ResumirPromediando;
  self.Esclavizador:= nil;
  self.flg_ResumirBorneras:= false;
end;

function TFuenteAleatoria.Rec: TCosa_RecLnk;
begin
  Result:=inherited Rec;
  Result.addCampoDef('durPasoDeSorteoEnHoras', durPasoDeSorteoEnHoras);
  Result.addCampoDef('NombresDeBornes_Publicados', NombresDeBornes_Publicados, 1 );
  Result.addCampoDef('ResumirPromediando', ResumirPromediando, 42, 0, 'T')
end;

procedure TFuenteAleatoria.BeforeRead(version, id_hilo: integer);
begin
  inherited BeforeRead(version, id_hilo);
  Esclavizador:= nil;
  self.flg_ResumirBorneras:= false;
  FuncionesRegistradas := TListaDeCosas.Create(capa, 'FuncionesRegistradas');
  SetLength(bornera, 0);
  SetLength(kpostes_bornes, 0);
end;

procedure TFuenteAleatoria.AfterRead(version, id_hilo: integer);
begin
  inherited AfterRead(version, id_hilo);
end;


procedure TFuenteAleatoria.Free;
begin
  SetLength(bornera, 0);
  SetLength(kpostes_bornes, 0);
  NombresDeBornes_Publicados.Free;
  FuncionesRegistradas.Free;
  inherited Free;
end;

procedure TFuenteAleatoria.calcular_Xs;
begin
  //Nada
end;

procedure TFuenteAleatoria.ProyectarEstado;
begin
  //Nada
end;


procedure TFuenteAleatoria.AddBorne(nombre: string);
begin
  NombresDeBornes_Publicados.Add(nombre);
end;


procedure TFuenteAleatoria.setCalculosAdicionalesEsclavizadorAlCambiarFicha(
  procCalcsAdicionalesEsclavizador: TProcCalculosAdicionalesDeObjeto);
begin
  //Nada, no hay fichas, no hay cambio de fichas
end;


// Retorna Self si No está ativo ResumirPromediando y si la el paso de sorteo
// de la fuente es menor que el de la sala. (o sea si será esclavizada en un sub-muestreo).
// Retorna NIL en caso contraio
function TFuenteAleatoria.ResumirMaxVar( globs: TGlobs ): TFuenteAleatoria;
begin
  if  not ResumirPromediando and (( globs.HorasDelPaso - self.durPasoDeSorteoEnHoras ) > 1 ) then
      result:= Esclavizador
  else
      result:= nil;
end;


function TFuenteAleatoria.dim_RB: integer;
begin
  Result := NombresDeBornes_Publicados.Count;
end;

function TFuenteAleatoria.dim_Wa: integer;
begin
  result:= 0;
end;

function TFuenteAleatoria.dim_BC: integer;
begin
  Result := FuncionesRegistradas.Count;
end;

function TFuenteAleatoria.dim_X: integer;
begin
  Result := 0;
end;

function TFuenteAleatoria.dim_Xs: integer;
begin
  Result := dim_X;
end;

// esta función devuelve dim_RB+dim_Wa+dim_X+dim_Xs es para usar antes de llamar al preparar memoria
// pues recien ahí se calculan los jsInicioFinal
function TFuenteAleatoria.jPrimer_BC_calculado: integer;
begin
  Result := dim_RB + dim_Wa + dim_X + dim_Xs;
end;

procedure TFuenteAleatoria.calcular_jsInicioFinal;
begin
  jPrimer_RB_ := 0;
  jUltimo_RB_ := dim_RB - 1;
  jPrimer_Wa_ := jUltimo_RB_ + 1;
  jUltimo_Wa_ := jPrimer_Wa_ + dim_Wa -1;
  jPrimer_X  := jUltimo_Wa_ + 1;
  jUltimo_X  := jPrimer_X + dim_X - 1;
  jPrimer_Xs := jUltimo_X + 1;
  jUltimo_Xs := jPrimer_Xs + dim_X - 1;
  jPrimer_BC := jUltimo_Xs + 1;
  jUltimo_BC := jPrimer_BC + dim_BC - 1;
end;



procedure TFuenteAleatoria.PrepararMemoria(Catalogo: TCatalogoReferencias;
  globs: TGlobs);

var
  i:     integer;
  ficha: TFichaFuncion;

begin
  inherited PrepararMemoria(Catalogo,  globs );

  calcular_jsInicioFinal;
  setlength(bornera, dim_RB + dim_Wa + dim_X + dim_Xs + dim_BC);
  setlength(kpostes_bornes, length(bornera));

  for i := 0 to high(kpostes_bornes) do
    kpostes_bornes[i] := -1;
  // por defecto si no registramos ninguna función el borne es de todos los postes
  // aquí se supone que ya registraron las funciones los actores por lo cual
  // estamos en condiciones de llenar el vector kpostes.
  for i := 0 to FuncionesRegistradas.Count - 1 do
  begin
    if TFichaFuncion(FuncionesRegistradas[i]) <> nil then
    begin
      ficha := TFichaFuncion(FuncionesRegistradas[i]);
      self.kPostes_bornes[ficha.numeroBorneSalida] := ficha.kPoste;
    end;
  end;

  dt_PasoDeSorteo:= durPasoDeSorteoEnHoras / 24.0;
end;


procedure TFuenteAleatoria.InicioSim;
begin
  vclear(bornera);
end;

procedure TFuenteAleatoria.InicioOpt;
begin
  vclear(bornera);
end;


procedure TFuenteAleatoria.Sim_Cronica_Inicio;
begin
  entradasFijadas := False;
end;



function TFuenteAleatoria.CostoDirectoDelPaso: NReal;
begin
  //Nada
  raise Exception.Create(
    'TFuenteAleatoria.CostoDirectoDelPaso: debería redefinir el método en ' +
    self.ClassName);
  //Para sacar el warning en FPC
  Result := 0;
end;

 // las fuentes con estado tienen que calcular el delta costo
 // por el delta_X resultante del sorteo
procedure TFuenteAleatoria.PrepararPaso_ps;
begin
  //Nada
end;

function TFuenteAleatoria.calc_DeltaCosto: NReal;
begin
  Result := 0;
end;

// carga el deltacosto en el término indep del simplex
procedure TFuenteAleatoria.opt_cargue(s: TSimplex);
begin
  s.acum_e(s.nf, s.nc, -calc_DeltaCosto);
end;

function TFuenteAleatoria.IdBorne(nombre: string): integer;
var
  res: integer;
begin
  res:= NombresDeBornes_Publicados.IndexOf(nombre);
  if res < 0 then
  begin
    writeln( 'OJO ... borne sin resolver .... ' );
    writeln( 'TFuenteAleatoria.idBorne, NombreBorne: '+nombre+', res: '+IntToStr( res )+' , FUENTE: '+self.nombre );
//    raise Exception.Create( 'ERROR, borne sin resolver. ' );
    writeln( 'PRESIONE ENTER PARA CONTINUAR.' );
    readln;
  end;
  Result := res;
end;

function TFuenteAleatoria.NombreBorne( idBorne: integer ): string;
begin
  result:= NombresDeBornes_Publicados[idBorne];
end;

function TFuenteAleatoria.IdBorne(nombre: string; func: TFRenR): integer;
var
  ficha:    TFichaFuncion;
  res, numeroBorne: integer;
  buscando: boolean;
begin
  if func = nil then
    raise Exception.Create('TFuenteAleatoria.idBorne con func= nil ');

  res      := 0;
  numeroBorne := NombresDeBornes_Publicados.IndexOf(nombre);
  buscando := True;
  while (res < FuncionesRegistradas.Count) and buscando do
  begin
    if (FuncionesRegistradas[res] <> nil) then
    begin
      ficha := TFichaFuncion(FuncionesRegistradas[res]);
      if (ficha.pfunc = func) and (ficha.numeroBorneEntrada = numeroBorne) then
        buscando := False;
    end
    else
      raise Exception.Create('OJO VIGILAME!!!!');

    Inc(res);
  end;
  if not buscando then
    Result := res - 1 + jPrimer_BC
  else
    Result := -1;
end;

function TFuenteAleatoria.descBornera: string;
begin
  Result := 'RB  : 0..' + IntToStr(dim_RB - 1) + #10 +
    'Wa   :' + IntToStr(jPrimer_Wa_) + '..' + IntToStr(jUltimo_Wa_ ) + #10 +
    'X   :' + IntToStr(jPrimer_X) + '..' + IntToStr(jUltimo_X ) + #10 +
    'Xs  :' + IntToStr(jPrimer_Xs) + '..' + IntToStr(jUltimo_Xs ) + #10 +
    'BC  :' + IntToStr(jPrimer_BC) + '..' +  IntToStr(jUltimo_BC);
end;

procedure TFuenteAleatoria.Dump_Variables(var f: TextFile; charIndentacion: char
  );
var
  i: integer;
begin
  writeln(f, self.claseNombre);
  for i := 0 to NombresDeBornes_Publicados.Count - 1 do
    writeln(f, charIndentacion, 'Nombre: ', NombresDeBornes_Publicados[i]);
  writeln(f);

  writeln(f, charIndentacion + StringReplace(descBornera, '#10', #10 +
    charIndentacion, [rfReplaceAll]));
  for i := 0 to high(bornera) do
    writeln(f, charIndentacion, 'bornera[' + IntToStr(i) + ']= ',
      FloatToStrF(bornera[i], ffFixed, 10, 3));
  writeln(f);
end;


procedure TFuenteAleatoria.PubliVars;
begin
  inherited PubliVars;
  // No eliminar aunque parezca redundante por compatibilidad con
  // plantillas viejas de SimRes3
  PublicarVariableVR('Borne', '-', 15, 15, Bornera, False, True);
end;


 //Agrega una funcion a la fuente aleatoria y retorna el numero de borne
 //en el que hay que pedir su valor
function TFuenteAleatoria.registrarFuncion(funcion: TFRenR;
  nombreBorne: string; kPoste: integer): integer;
var
  i, iFicha, iBorneSimple, iBorneCalculado: integer;
  fichaFunc: TFichaFuncion;
  encontreLaFicha: boolean;
begin
  i      := 0;
  iBorneSimple := idBorne(nombreBorne);
  iFicha := -1;
  encontreLaFicha := False;

  //Me fijo, que no haya llegado al final, que no haya un hueco
  //y que la función no este ya en la lista
  while (i < FuncionesRegistradas.Count) do
  begin
    if (FuncionesRegistradas[i] = nil) then
    begin
      if iFicha = -1 then
        iFicha := i;
    end
    else
    begin
      fichaFunc := TFichaFuncion(FuncionesRegistradas[i]);
      if (fichaFunc.pfunc = funcion) and (fichaFunc.numeroBorneEntrada =
        iBorneSimple) then
      begin
        iFicha := i;
        encontreLaFicha := True;
        break;
      end;
    end;
    Inc(i);
  end;

  if not encontreLaFicha then
  begin
    if iFicha = -1 then
    begin
      iBorneCalculado := jPrimer_BC_calculado + FuncionesRegistradas.Count;
      fichaFunc := TFichaFuncion.Create(capa, funcion, iBorneSimple, iBorneCalculado, kPoste);
      //Si no hay huecos la inserto al final y devuelvo su indice
      FuncionesRegistradas.Add(fichaFunc);
    end
    else
      //Si hay huecos la inserto en el hueco y devuelvo su indice
    begin
      iBorneCalculado := jPrimer_BC_calculado + iFicha;
      fichaFunc := TFichaFuncion.Create(capa, funcion, iBorneSimple, iBorneCalculado, kPoste);
      FuncionesRegistradas.Insert(iFicha, fichaFunc);
      iBorneCalculado := iFicha;
    end;
  end
  else
    iBorneCalculado := jPrimer_BC_calculado + iFicha;
  Result := iBorneCalculado;
end;


function TFuenteAleatoria.registrarFuncion_biborne(funcion: TFR2enR;
  nombreBorne1, nombreBorne2: string; kPoste: integer): integer;
var
  i, iFicha, iBorneSimple1, iBorneSimple2, iBorneCalculado: integer;
  fichaFunc: TFichaFuncion_biborne;
  encontreLaFicha: boolean;
begin
  i      := 0;
  iBorneSimple1 := idBorne(nombreBorne1);
  iBorneSimple2 := idBorne(nombreBorne2);
  iFicha := -1;
  encontreLaFicha := False;

  //Me fijo, que no haya llegado al final, que no haya un hueco
  //y que la función no este ya en la lista
  while (i < FuncionesRegistradas.Count) do
  begin
    if (FuncionesRegistradas[i] = nil) then
    begin
      if iFicha = -1 then
        iFicha := i;
    end
    else
    begin
      if TFichaFuncion(FuncionesRegistradas[i]) is TFichaFuncion_biborne then
      begin
        fichaFunc := TFichaFuncion_biborne(FuncionesRegistradas[i]);
        if (fichaFunc.pfunc = funcion) and
          (fichaFunc.numeroBorneEntrada1 = iBorneSimple1) and
          (fichaFunc.numeroBorneEntrada2 = iBorneSimple2) then
        begin
          iFicha := i;
          encontreLaFicha := True;
          break;
        end;
      end;
    end;
    Inc(i);
  end;

  if not encontreLaFicha then
  begin
    if iFicha = -1 then
    begin
      iBorneCalculado := jPrimer_BC_calculado + FuncionesRegistradas.Count;
      fichaFunc := TFichaFuncion_biborne.Create(capa, funcion, iBorneSimple1,
        iBorneSimple2, iBorneCalculado, kPoste);
      //Si no hay huecos la inserto al final y devuelvo su indice
      FuncionesRegistradas.Add(fichaFunc);
    end
    else
      //Si hay huecos la inserto en el hueco y devuelvo su indice
    begin
      iBorneCalculado := jPrimer_BC_calculado + iFicha;
      fichaFunc := TFichaFuncion_biborne.Create(capa, funcion, iBorneSimple1,
        iBorneSimple2, iBorneCalculado, kPoste);
      FuncionesRegistradas.Insert(iFicha, fichaFunc);
      iBorneCalculado := iFicha;
    end;
  end
  else
    iBorneCalculado := jPrimer_BC_calculado + iFicha;
  Result := iBorneCalculado;
end;


 //Quita la función en el borne indicado y lo deja libre para ser usado
 //por el próximo que pida una función
procedure TFuenteAleatoria.desregistrarFuncion(numeroBorne: integer);
begin
  TFichaFuncion(FuncionesRegistradas[numeroBorne]).Free;
  FuncionesRegistradas[numeroBorne] := nil;
end;

function TFuenteAleatoria.referenciaFuente(fuente: TFuenteAleatoria): boolean;
begin
  result:= false;
end;

procedure TFuenteAleatoria.fijarEstadoInterno;
begin
  //Nada, redefinir donde corresponda
end;

procedure TFuenteAleatoria.SorteosDelPaso(xsortear: boolean);
begin
  if xsortear then
  begin
    SortearEntradaRB(bornera[0]);
  end
  else if not entradasFijadas then
  begin
    ValorEsperadoEntradaRB(bornera[0]);
// OJO    entradasFijadas_ := True;
  end;
end;

procedure TFuenteAleatoria.calcular_BC;
var
  i:      integer;
  ficha1b: TFichaFuncion;
  ficha2b: TFichaFuncion_biborne;
  kPoste: integer;
begin
  kPoste := globs.kPosteHorasDelPaso[globs.kSubPaso_];
  for i := 0 to FuncionesRegistradas.Count - 1 do
  begin
    if TFichaFuncion(FuncionesRegistradas[i]) <> nil then
    begin
      if TFichaFuncion(FuncionesRegistradas[i]) is TFichaFuncion_biborne then
      begin
        ficha2b := TFichaFuncion_biborne(FuncionesRegistradas[i]);
        if (kPostes_bornes[ficha2b.numeroBorneSalida] = -1) or
          (kPoste = kPostes_bornes[ficha2b.numeroBorneSalida]) then
        begin
          Bornera[ficha2b.numeroBorneSalida] :=
            ficha2b.func_r2r.fval(bornera[ficha2b.numeroBorneEntrada1]
            , bornera[ficha2b.numeroBorneEntrada2]);
        end
        else
        begin
          Bornera[ficha2b.numeroBorneSalida] := 0;
          //  esto parece que está mal. QUé sentido tiene asignar un borne de entrada?.
          //          Bornera[ficha2b.numeroBorneEntrada2]:= 0;
        end;
      end
      else
      begin
        ficha1b := TFichaFuncion(FuncionesRegistradas[i]);
        if (kPostes_bornes[ficha1b.numeroBorneSalida] = -1) or
          (kPoste = kPostes_bornes[ficha1b.numeroBorneSalida]) then
          Bornera[ficha1b.numeroBorneSalida] :=
            ficha1b.func_rr.fval(bornera[ficha1b.numeroBorneEntrada])
        else
          Bornera[ficha1b.numeroBorneSalida] := 0;
      end;
    end;
  end;
end;


procedure TFuenteAleatoria.sorteosDelPaso_EsclavizadaEnSubmuestreo(xsortear: boolean);
begin
  if xsortear then
  begin
    SortearEntradaRB(bornera[0]);
    calcular_XS;
    EvolucionarEstado;
    calcular_BC;
  end
  else if not entradasFijadas then
  begin
    ValorEsperadoEntradaRB(bornera[0]);
    calcular_XS;
    EvolucionarEstado;
    calcular_BC;
// ojo esto debía estar mal    entradasFijadas := True;
  end;
end;


 //-------------------------------------
 // Métodos de TFuenteAleatoriaConFichas
 //=====================================

constructor TFuenteAleatoriaConFichas.Create(capa: integer; nombre: string;
  xdurPasoDeSorteoEnHoras: integer; resumirPromediando: boolean; lpd: TFichasLPD);
begin
  inherited Create(capa, nombre, xdurPasoDeSorteoEnHoras, resumirPromediando);
  self.lpd := lpd;
  if lpd <> nil then
    self.lpd.Propietario := self;
end;

function TFuenteAleatoriaConFichas.Rec: TCosa_RecLnk;
begin
  Result:=inherited Rec;
  Result.addCampoDef('lpd', TCosa(lpd), 19 );
end;

procedure TFuenteAleatoriaConFichas.BeforeRead(version, id_hilo: integer);
begin
  inherited BeforeRead(version, id_hilo);
  if Version < 19 then
  begin
    raise Exception.Create('Lo siento pero la versión de archivo es MUY ANTIGUA y no es posible leerla' );
  end;
end;

procedure TFuenteAleatoriaConFichas.AfterRead(version, id_hilo: integer);
begin
  inherited AfterRead(version, id_hilo);
end;


procedure TFuenteAleatoriaConFichas.Free;
begin
  if lpd <> nil then
  begin
    lpd.Free;
  end;
  inherited Free;
end;

procedure TFuenteAleatoriaConFichas.PrepararMemoria(Catalogo: TCatalogoReferencias; globs: TGlobs);
begin
  inherited prepararMemoria( Catalogo, globs);
  lpd.expandirFichas(Catalogo, globs);
end;

procedure TFuenteAleatoriaConFichas.setCalculosAdicionalesEsclavizadorAlCambiarFicha(
  procCalcsAdicionalesEsclavizador: TProcCalculosAdicionalesDeObjeto);
begin
  lpd.calculosAdicionalesEsclavizador := procCalcsAdicionalesEsclavizador;
end;

function TFuenteAleatoriaConFichas.InfoAd_: string;
var
  res: string;
begin
  res := inherited InfoAd_;
  if res <> '' then
    res := res + ' ';

  if lpd.Count = 1 then
    res := res + TFichaLpd(lpd[0]).infoAd_
  else if lpd.Count > 1 then
  begin
    res := res + TFichaLpd(lpd[0]).fechaMasInfoAd + ListSeparator +
      ' ' + TFichaLpd(lpd[1]).fechaMasInfoAd;
    if lpd.Count > 2 then
      res := res + ' ...';
  end;

  Result := res;
end;

procedure TFuenteAleatoriaConFichas.ActivarCapas( const CapasActivas: TDAOfNInt );
begin
  if lpd <> nil then
   lpd.ActivarCapas( CapasActivas );
end;

procedure testSim(fuente: TFuenteAleatoria);
const
  N_REPETICIONES = 10000;
var
  i, j:   integer;
  fdbg:   TextFile;
  indice: string;
begin
  AssignFile(fdbg, '\simsee\debug\' + fuente.nombre + '.xlt');
  Rewrite(fdbg);

  Write(fdbg, 'Evento');
  for i := fuente.jPrimer_RB_ to fuente.jUltimo_RB_ do
  begin
    indice := IntToStr(i - fuente.jPrimer_RB_);
    Write(fdbg, #9'RB[' + indice + ']');
  end;

  for i := fuente.jPrimer_Wa_ to fuente.jUltimo_Wa_ do
  begin
    indice := IntToStr(i - fuente.jPrimer_Wa_);
    Write(fdbg, #9'Wa[' + indice + ']');
  end;


  for i := fuente.jPrimer_X to fuente.jUltimo_X do
  begin
    indice := IntToStr(i - fuente.jPrimer_X);
    Write(fdbg, #9'X[' + indice + ']');
  end;

  for i := fuente.jPrimer_Xs to fuente.jUltimo_XS do
  begin
    indice := IntToStr(i - fuente.jPrimer_Xs);
    Write(fdbg, #9'Xs[' + indice + ']');
  end;

  for i := fuente.jPrimer_BC to fuente.jUltimo_BC do
  begin
    indice := IntToStr(i - fuente.jPrimer_BC);
    Write(fdbg, #9'BC[' + indice + ']');
  end;
  Writeln(fdbg);

  fuente.Sim_Cronica_Inicio;
  Write(fdbg, 'Sim_Cronica_Inicio');
  for j := 0 to high(fuente.Bornera) do
    Write(fdbg, #9, fuente.Bornera[j]);
  Writeln(fdbg);

  for i := 1 to N_REPETICIONES - 1 do
  begin
    fuente.SorteosDelPaso(True);
{    Write(fdbg, 'SorteosDelPaso');
    for j:= 0 to high(fuente.Bornera) do
      Write(fdbg, #9, fuente.Bornera[j]);
    Writeln(fdbg); }

    fuente.calcular_BC;
{    Write(fdbg, 'calcular_BC');
    for j:= 0 to high(fuente.Bornera) do
      Write(fdbg, #9, fuente.Bornera[j]);
    Writeln(fdbg);}

    fuente.PrepararPaso_ps;
    Write(fdbg, 'PrepararPaso_ps');
    for j := 0 to high(fuente.Bornera) do
      Write(fdbg, #9, fuente.Bornera[j]);
    Writeln(fdbg);

    fuente.EvolucionarEstado;
{    Write(fdbg, 'EvolucionarEstadoActual');
    for j:= 0 to high(fuente.Bornera) do
      Write(fdbg, #9, fuente.Bornera[j]);
    Writeln(fdbg);}
  end;

  CloseFile(fdbg);
end;


(********************************************************
   Métodos de TFuenteAleatoria_Borne.
=========================================================*)
constructor TFuenteAleatoria_Borne.Create( capa: integer; fuente: TFuenteAleatoria; borne: string);
begin
  inherited Create( capa );
  self.fuente  := fuente;
  self.borne   := borne;
  self.idBorne := fuente.IdBorne(borne);
end;

function TFuenteAleatoria_Borne.Rec: TCosa_RecLnk;
begin
  Result:=inherited Rec;
  Result.addCampoDef_ref('fuentes', TCosa(fuente), self );
  Result.addCampoDef('borne', borne );
end;

procedure TFuenteAleatoria_Borne.BeforeRead(version, id_hilo: integer);
begin
  inherited BeforeRead(version, id_hilo);
end;

procedure TFuenteAleatoria_Borne.AfterRead(version, id_hilo: integer);
begin
  inherited AfterRead(version, id_hilo);
  self.idBorne := -1;
end;


function TFuenteAleatoria_Borne.Create_Clone(Catalogo: TCatalogo;
  idHilo: integer): TCosa;
begin
  Result := inherited Create_Clone( Catalogo, idHilo );
end;

class function TFuenteAleatoria_Borne.DescClase: string;
begin
  Result := inherited DescClase;
end;

procedure TFuenteAleatoria_Borne.Free;
begin
  inherited Free;
end;

function TFuenteAleatoria_Borne.DarIdBorne(const Referente: TCosaConNombre ): integer;
begin
  if idBorne = -1 then
  begin
    idBorne := fuente.IdBorne(borne);
    if idBOrne = -1 then
    raise Exception.Create( 'Error en referencia a fuente: "'+fuente.Nombre+'", por "'+Referente.Nombre+'" el BORNE: "'+borne+'" NO Existe!' );
  end;

  Result := idBorne;
end;


procedure AlInicio;
begin
  ucosa.registrarClaseDeCosa(TListFuenteAleatoria.ClassName, TListFuenteAleatoria);

  ucosa.registrarClaseDeCosa(TFuenteAleatoria_Borne.ClassName, TFuenteAleatoria_Borne);
end;

procedure AlFinal;
begin

end;

end.

