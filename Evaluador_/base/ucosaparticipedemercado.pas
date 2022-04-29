unit ucosaparticipedemercado;
{$mode delphi}

interface

uses
  xMatDefs, Classes, SysUtils, uConstantesSimSEE,
  ucosa, ucosaconnombre,
  uEstados,
  umadresuniformes, uFechas, uVarDefs, uglobs, uFichasLPD,
  uparseadorsupersimple;

type

  { TCosaParticipeDeMercado }
  TCosaParticipeDeMercado = class(TCosaConNombre)
  public
    //lista de variables que serán impresas  en simPrintResultados
    variablesParaSimRes: TListaVarDefs;

    globs: TGlobs;
    SorteadorUniforme: TMadreUniformeEtiquetada;

    // Lista de parámetros dinámicos específicos del tipo de ParticipanteDeMercado.
    // Cada Clase define la FICHA de acuerdo su tipo
    lpd: TFichasLPD;

    procedure AddToCapasLst(capas: TList; padre: TCosa ); override;

    constructor Create(capa: integer; const nombre: string); override;

    procedure AfterRead(version, id_hilo: integer); override;

    procedure PrepararMemoria(Catalogo: TCatalogoReferencias; globs: TGlobs); virtual;
    procedure RegistrarParametrosDinamicos(CatalogoReferencias: TCatalogoReferencias);
      virtual;


    // NUMERO DE VARIABLES DE ESTADO CONTINUAS DISCRETAS, auxiliares CONTINUAS, auxiliares DISCRETAS
    // Almacena el valor de ixr (indice dónde comienzan las variables de estado
    // del actor en el vector de variables de estado continuas e incrementa
    // el valor de ixr en la cantidad de variables de estado continuas que necesita
    // el actor.
    // En ixd almacena donde comienza la discreta.
    // ------ Variables auxiliares ----
    // Son para almacenar un valor asociado a que el Actor se encuentre en un determinado estado.
    // esto se hace así para facilitar la optimización. Por ejemplo, si para el cálculo de la pérdida de
    // salto se quiere utilizar el caudal erogado en la etapa antes calculada, hay que guardar el caudal erogado
    // en una variable auxiliar para luego usar el de la etapa anterior, que corresponde a la misma estrella
    // en el espacio de estados. En la simulación se tomará simplemente el caudal erogado en el paso anterior
    // pues se supone que hay cierta continuidad en la trayectoria del estado.
    // En iauxNReal almacenamos el índice de las auxiliaers continuas el actor debe incrementar este valor en
    // el número de variables que requiere almacenar.
    // En iauxInt almacena el índice de las auxileares enteras. El actor debe incrementar este valor en el número
    // de variables enteras que requiere que se almacenen.
    procedure optx_nvxs(var ixr, ixd, iauxNReal, iauxInt: integer); virtual;

    // Registra las variables en el administrador de variables de estado
    procedure optx_RegistrarVariablesDeEstado(adminEstados: TAdminEstados); virtual;


    // Estre procedimiento es llamado al inicio de cada paso durante el proceso de
    // optimización dinámica para que cada actor se posicione de acuerdo con la Estrellita
    // que representa el estado global del sistema al inicio del paso que se optimizará.
    // Este procedimento es el primero a llamar como preparación de un paso para que
    // cualquier cálculo que realicen los actores lo hagan conociendo su estado de inicio.

    //(Fuentes) si la fuente tiene estado (X) , lo pone acorde con la estrellita del
    //administrador de estados y calcula el (Xs) correspondiente

    procedure PosicionarseEnEstrellita; virtual;

    // Este procedimiento es llamado al inicio de cada paso durante el proceso de simulación
    // para que cada actor actualice su estado en el estado global del sistema.
    // Esto se hace al inicio del paso, antes de realizar los sorteos para que todo lo que calculen los
    // actores como preparación del paso lo puedan hacer con conocimiento del estado global
    // al inicio del paso.
    // (Fuentes) Según el parámetro la fuente debe usar su proyección Xs al final del paso
    //(proyección central) o usar X directametne.
    procedure ActualizarEstadoGlobal(flg_Xs: boolean); virtual;


    //Hace efectivo el cambio de estado haciendo EstadoK_actual:= EstadoK_aux
    procedure EvolucionarEstado; virtual;


    procedure PublicarVariableS(const xnombre, xunidades: string;
      var xvar: string; paraSimResPorDefecto: boolean); reintroduce;
    procedure PublicarVariableNR(const xnombre, xunidades: string;
      precision, decimales: integer; var xvar: NReal; paraSimResPorDefecto: boolean);
      reintroduce;
    procedure PublicarVariableNI(const xnombre, xunidades: string;
      var xvar: integer; paraSimResPorDefecto: boolean); reintroduce;
    procedure PublicarVariableB(const xnombre, xunidades: string;
      var xvar: boolean; paraSimResPorDefecto: boolean); reintroduce;
    procedure PublicarVariableFecha(const xnombre: string; var xvar: TFecha;
      paraSimResPorDefecto: boolean); reintroduce;

    procedure PublicarVariableVR(const xnombre, xunidades: string;
      precision, decimales: integer; var xvar: TDAOfNReal;
      usarNomenclaturaConPostes: boolean; paraSimResPorDefecto: boolean); reintroduce;

    procedure PublicarVariableVI(const xnombre, xunidades: string;
      var xvar: TDAOfNInt; usarNomenclaturaConPostes: boolean;
      paraSimResPorDefecto: boolean); reintroduce;
    procedure PublicarVariableVB(const xnombre, xunidades: string;
      var xvar: TDAOfBoolean; usarNomenclaturaConPostes: boolean;
      paraSimResPorDefecto: boolean); reintroduce;

    procedure PublicarVariablePS(const xnombre, xunidades: string;
      var pd; var xvar: string; paraSimResPorDefecto: boolean); reintroduce;

    procedure PublicarVariablePNR(const xnombre, xunidades: string;
      precision, decimales: integer; var pd; var xvar: NReal;
      paraSimResPorDefecto: boolean); reintroduce; overload;
    procedure PublicarVariablePNI(const xnombre, xunidades: string;
      var pd; var xvar: integer; paraSimResPorDefecto: boolean); reintroduce; overload;
    procedure PublicarVariablePB(const xnombre, xunidades: string;
      var pd; var xvar: boolean; paraSimResPorDefecto: boolean); reintroduce; overload;

    //Publican las variables igual que arriba pero permiten especificar que son parte de un
    //arreglo y su indice en el arreglo
    procedure PublicarVariablePNR(const xnombre, xunidades: string;
      precision, decimales: integer; var pd; var xvar: NReal;
      posteVar: integer; paraSimResPorDefecto: boolean); reintroduce; overload;
    procedure PublicarVariablePNI(const xnombre, xunidades: string;
      var pd; var xvar: integer; posteVar: integer; paraSimResPorDefecto: boolean);
      reintroduce; overload;
    procedure PublicarVariablePB(const xnombre, xunidades: string;
      var pd; var xvar: boolean; posteVar: integer; paraSimResPorDefecto: boolean);
      reintroduce; overload;

    procedure PublicarVariablePFecha(const xnombre: string; var pd;
      var xvar: TFecha; paraSimResPorDefecto: boolean); reintroduce;

    procedure PublicarVariablePVNR(const xnombre, xunidades: string;
      precision, decimales: integer; var pd; var xvar: TDAofNReal;
      usarNomenclaturaConPostes: boolean; paraSimResPorDefecto: boolean); reintroduce;
    procedure PublicarVariablePVNI(const xnombre, xunidades: string;
      var pd; var xvar: TDAofNInt; usarNomenclaturaConPostes: boolean;
      paraSimResPorDefecto: boolean); reintroduce;
    procedure PublicarVariablePVB(const xnombre, xunidades: string;
      var pd; var xvar: TDAOfBoolean; usarNomenclaturaConPostes: boolean;
      paraSimResPorDefecto: boolean); reintroduce;

    procedure PubliVars; override;

{$IFDEF DECLARAR_VARIABLES_SIMRES_DEF}
    //agrega nombresVars[0]_P1, nombresVars[1]_P1, ... nombresVars[n]_P1, ...nombresVars[0]_Pk, ... nombresVars[n]_Pk
    //a las variables por defecto para SimRes.
    //De esta forma se escriben todas las variables del poste 1, luego las del poste 2 y sucesivamente
    procedure declararVarsPSimResPorDefectoIntercalandoPostes(
      const nombresVars: array of string; nPostes: integer);
{$ENDIF}


    // borra las variables no seleccionadas por una plantilla SimRes3
    procedure Depurar_VaraiblesParaSimRes; virtual;

    procedure sim_PrintResultados_Encab(var fsal: textfile; kencab: integer); virtual;
    procedure sim_PrintResultados(var fsal: textfile); virtual;

    procedure sim_FinCronicaPrintEstadoFinal(var fsal: textfile); virtual;
    destructor Destroy; override;
    procedure Free; override;

    procedure InicioSim; virtual;
    procedure InicioOpt; virtual;

{$IFDEF BOSTA}
    procedure AfterInstantiation; override;
{$ENDIF}

  end;


implementation

{ TCosaParticipeDeMercado }

procedure TCosaParticipeDeMercado.AddToCapasLst(capas: TList; padre: TCosa);
var
  k: integer;
begin
  inherited AddToCapasLst(capas, Padre);
  if lpd <> nil then
    for k:= 0 to lpd.Count - 1 do
       TCosa( lpd[k] ).AddToCapasLst( capas, Self );
end;

constructor TCosaParticipeDeMercado.Create(capa: integer; const nombre: string);
begin
  inherited Create(capa, nombre);
  sorteadorUniforme := nil;
  variablesParaSimRes := TListaVarDefs.Create;
end;


procedure TCosaParticipeDeMercado.AfterRead(version, id_hilo: integer);
begin
  inherited AfterRead( version, id_hilo );
  sorteadorUniforme := nil;
  variablesParaSimRes := TListaVarDefs.Create;
end;

procedure TCosaParticipeDeMercado.PrepararMemoria(Catalogo: TCatalogoReferencias;
  globs: TGlobs);
begin
  self.globs := globs;
  if SorteadorUniforme = nil then
    SorteadorUniforme := globs.madresUniformes.Get_NuevaMadreUniforme(get_hash_nombre);
end;

procedure TCosaParticipeDeMercado.RegistrarParametrosDinamicos(
  CatalogoReferencias: TCatalogoReferencias);
begin
  // no hago nada
end;


procedure TCosaParticipeDeMercado.Free;
begin
  if sorteadorUniforme <> nil then
  begin
    sorteadorUniforme.Free;
    sorteadorUniforme := nil;
  end;
  inherited Free;
end;

procedure TCosaParticipeDeMercado.PublicarVariableS(const xnombre, xunidades: string;
  var xvar: string; paraSimResPorDefecto: boolean);
var
  varDef: TVarDef;
begin
  inherited PublicarVariableS(xnombre, xunidades, xvar);
  if paraSimResPorDefecto then
  begin
    if buscarVariable(xnombre, varDef) then
    begin
      vardef.Prepararse;
      variablesParaSimRes.Add(varDef);
    end
    else
      raise Exception.Create(
        'TCosaParticipeDeMercado.PublicarVariableS: no se encuentra la variable ' +
        xnombre);
  end;
end;

procedure TCosaParticipeDeMercado.PublicarVariableNR(const xnombre, xunidades: string;
  precision, decimales: integer; var xvar: NReal; paraSimResPorDefecto: boolean);
var
  varDef: TVarDef;
begin
  inherited PublicarVariableNR(xnombre, xunidades, precision, decimales, xvar);
  if paraSimResPorDefecto then
  begin
    if buscarVariable(xnombre, varDef) then
    begin
      vardef.Prepararse;
      variablesParaSimRes.Add(varDef);
    end
    else
      raise Exception.Create(
        'TCosaParticipeDeMercado.PublicarVariableNR: no se encuentra la variable ' +
        xnombre);
  end;
end;

procedure TCosaParticipeDeMercado.PublicarVariableNI(const xnombre, xunidades: string;
  var xvar: integer; paraSimResPorDefecto: boolean);
var
  varDef: TVarDef;
begin
  inherited PublicarVariableNI(xnombre, xunidades, xvar);
  if paraSimResPorDefecto then
  begin
    if buscarVariable(xnombre, varDef) then
    begin
      vardef.Prepararse;
      variablesParaSimRes.Add(varDef);
    end
    else
      raise Exception.Create(
        'TCosaParticipeDeMercado.PublicarVariableNI: no se encuentra la variable ' +
        xnombre);
  end;
end;

procedure TCosaParticipeDeMercado.PublicarVariableB(const xnombre, xunidades: string;
  var xvar: boolean; paraSimResPorDefecto: boolean);
var
  varDef: TVarDef;
begin
  inherited PublicarVariableB(xnombre, xunidades, xvar);
  if paraSimResPorDefecto then
  begin
    if buscarVariable(xnombre, varDef) then
    begin
      vardef.Prepararse;
      variablesParaSimRes.Add(varDef);
    end
    else
      raise Exception.Create(
        'TCosaParticipeDeMercado.PublicarVariableB: no se encuentra la variable ' +
        xnombre);
  end;
end;

procedure TCosaParticipeDeMercado.PublicarVariableFecha(const xnombre: string;
  var xvar: TFecha; paraSimResPorDefecto: boolean);
var
  varDef: TVarDef;
begin
  inherited PublicarVariableFecha(xnombre, xvar);
  if paraSimResPorDefecto then
  begin
    if buscarVariable(xnombre, varDef) then
    begin
      vardef.Prepararse;
      variablesParaSimRes.Add(varDef);
    end
    else
      raise Exception.Create(
        'TCosaParticipeDeMercado.PublicarVariableFecha: no se encuentra la variable ' +
        xnombre);
  end;
end;

procedure TCosaParticipeDeMercado.PublicarVariableVR(const xnombre, xunidades: string;
  precision, decimales: integer; var xvar: TDAOfNReal;
  usarNomenclaturaConPostes: boolean; paraSimResPorDefecto: boolean);
var
  varDef: TVarDef;
begin
  inherited PublicarVariableVR(xnombre, xunidades, precision, decimales,
    xvar, usarNomenclaturaConPostes);
  if paraSimResPorDefecto and buscarVariable(xnombre, varDef) then
  begin
    vardef.Prepararse;
    variablesParaSimRes.Add(varDef);
  end;
end;

procedure TCosaParticipeDeMercado.PublicarVariableVI(const xnombre, xunidades: string;
  var xvar: TDAOfNInt; usarNomenclaturaConPostes: boolean;
  paraSimResPorDefecto: boolean);
var
  varDef: TVarDef;
begin
  inherited PublicarVariableVI(xnombre, xunidades, xvar, usarNomenclaturaConPostes);
  if paraSimResPorDefecto and buscarVariable(xnombre, varDef) then
  begin
    vardef.Prepararse;
    variablesParaSimRes.Add(varDef);
  end;
end;

procedure TCosaParticipeDeMercado.PublicarVariableVB(const xnombre, xunidades: string;
  var xvar: TDAOfBoolean; usarNomenclaturaConPostes: boolean;
  paraSimResPorDefecto: boolean);
var
  varDef: TVarDef;
begin
  inherited PublicarVariableVB(xnombre, xunidades, xvar, usarNomenclaturaConPostes);
  if paraSimResPorDefecto and buscarVariable(xnombre, varDef) then
  begin
    vardef.Prepararse;
    variablesParaSimRes.Add(varDef);
  end;
end;

procedure TCosaParticipeDeMercado.PublicarVariablePS(const xnombre, xunidades: string;
  var pd; var xvar: string; paraSimResPorDefecto: boolean);
var
  varDef: TVarDef;
begin
  inherited PublicarVariableS(xnombre, xunidades, xvar);
  if paraSimResPorDefecto and buscarVariable(xnombre, varDef) then
  begin
    vardef.Prepararse;
    variablesParaSimRes.Add(varDef);
  end;
end;

procedure TCosaParticipeDeMercado.PublicarVariablePNR(const xnombre, xunidades: string;
  precision, decimales: integer; var pd; var xvar: NReal; paraSimResPorDefecto: boolean);
var
  varDef: TVarDef;
begin
  inherited PublicarVariablePNR(xnombre, xunidades, precision, decimales, pd, xvar);
  if paraSimResPorDefecto and buscarVariable(xnombre, varDef) then
  begin
    vardef.Prepararse;
    variablesParaSimRes.Add(varDef);
  end;
end;

procedure TCosaParticipeDeMercado.PublicarVariablePNI(const xnombre, xunidades: string;
  var pd; var xvar: integer; paraSimResPorDefecto: boolean);
var
  varDef: TVarDef;
begin
  inherited PublicarVariablePNI(xnombre, xunidades, pd, xvar);
  if paraSimResPorDefecto and buscarVariable(xnombre, varDef) then
  begin
    vardef.Prepararse;
    variablesParaSimRes.Add(varDef);
  end;
end;

procedure TCosaParticipeDeMercado.PublicarVariablePB(const xnombre, xunidades: string;
  var pd; var xvar: boolean; paraSimResPorDefecto: boolean);
var
  varDef: TVarDef;
begin
  inherited PublicarVariablePB(xnombre, xunidades, pd, xvar);
  if paraSimResPorDefecto and buscarVariable(xnombre, varDef) then
  begin
    vardef.Prepararse;
    variablesParaSimRes.Add(varDef);
  end;
end;

procedure TCosaParticipeDeMercado.PublicarVariablePNR(const xnombre, xunidades: string;
  precision, decimales: integer; var pd; var xvar: NReal; posteVar: integer;
  paraSimResPorDefecto: boolean);
var
  varDef: TVarDef;
begin
  inherited PublicarVariablePNR(xnombre, xunidades, precision, decimales,
    pd, xvar, posteVar);
  if paraSimResPorDefecto and buscarVariable(xnombre, varDef) then
  begin
    vardef.Prepararse;
    variablesParaSimRes.Add(varDef);
  end;
end;

procedure TCosaParticipeDeMercado.PublicarVariablePNI(const xnombre, xunidades: string;
  var pd; var xvar: integer; posteVar: integer; paraSimResPorDefecto: boolean);
var
  varDef: TVarDef;
begin
  inherited PublicarVariablePNI(xnombre, xunidades, pd, xvar, posteVar);
  if paraSimResPorDefecto and buscarVariable(xnombre, varDef) then
  begin
    vardef.Prepararse;
    variablesParaSimRes.Add(varDef);
  end;
end;

procedure TCosaParticipeDeMercado.PublicarVariablePB(const xnombre, xunidades: string;
  var pd; var xvar: boolean; posteVar: integer; paraSimResPorDefecto: boolean);
var
  varDef: TVarDef;
begin
  inherited PublicarVariablePB(xnombre, xunidades, pd, xvar, posteVar);
  if paraSimResPorDefecto and buscarVariable(xnombre, varDef) then
  begin
    vardef.Prepararse;
    variablesParaSimRes.Add(varDef);
  end;
end;

procedure TCosaParticipeDeMercado.PublicarVariablePFecha(const xnombre: string;
  var pd; var xvar: TFecha; paraSimResPorDefecto: boolean);
var
  varDef: TVarDef;
begin
  inherited PublicarVariablePFecha(xnombre, pd, xvar);
  if paraSimResPorDefecto and buscarVariable(xnombre, varDef) then
  begin
    vardef.Prepararse;
    variablesParaSimRes.Add(varDef);
  end;
end;

procedure TCosaParticipeDeMercado.PublicarVariablePVNR(const xnombre, xunidades: string;
  precision, decimales: integer; var pd; var xvar: TDAofNReal;
  usarNomenclaturaConPostes: boolean; paraSimResPorDefecto: boolean);
var
  varDef: TVarDef;
begin
  inherited PublicarVariablePVNR(xnombre, xunidades, precision,
    decimales, pd, xvar, usarNomenclaturaConPostes);
  if paraSimResPorDefecto and buscarVariable(xnombre, varDef) then
  begin
    vardef.Prepararse;
    variablesParaSimRes.Add(varDef);
  end;
end;

procedure TCosaParticipeDeMercado.PublicarVariablePVNI(const xnombre, xunidades: string;
  var pd; var xvar: TDAofNInt; usarNomenclaturaConPostes: boolean;
  paraSimResPorDefecto: boolean);
var
  varDef: TVarDef;
begin
  inherited PublicarVariablePVNI(xnombre, xunidades, pd, xvar,
    usarNomenclaturaConPostes);
  if paraSimResPorDefecto and buscarVariable(xnombre, varDef) then
  begin
    vardef.Prepararse;
    variablesParaSimRes.Add(varDef);
  end;
end;

procedure TCosaParticipeDeMercado.PublicarVariablePVB(const xnombre, xunidades: string;
  var pd; var xvar: TDAOfBoolean; usarNomenclaturaConPostes: boolean;
  paraSimResPorDefecto: boolean);
var
  varDef: TVarDef;
begin
  inherited PublicarVariablePVB(xnombre, xunidades, pd, xvar, usarNomenclaturaConPostes);
  if paraSimResPorDefecto and buscarVariable(xnombre, varDef) then
  begin
    vardef.Prepararse;
    variablesParaSimRes.Add(varDef);
  end;
end;


procedure TCosaParticipeDeMercado.optx_nvxs(var ixr, ixd, iauxNReal, iauxInt: integer);
begin
  // nada;
end;

procedure TCosaParticipeDeMercado.optx_RegistrarVariablesDeEstado(
  adminEstados: TAdminEstados);
begin
  //nada;
end;

procedure TCosaParticipeDeMercado.PosicionarseEnEstrellita;
begin
  //Nada
end;

procedure TCosaParticipeDeMercado.ActualizarEstadoGlobal(flg_Xs: boolean);
begin
  //Nada
end;


//Hace efectivo el cambio de estado haciendo EstadoK_actual:= EstadoK_aux
procedure TCosaParticipeDeMercado.EvolucionarEstado;
begin
  // Nada
end;

procedure TCosaParticipeDeMercado.PubliVars;
begin
  inherited PubliVars;
  //Se borraron los objetos referenciados en la lista de variables para SimRes
  //tengo que borrar las referencias
  variablesParaSimRes.Clear;
end;

{$IFDEF DECLARAR_VARIABLES_SIMRES_DEF}
procedure TCosaParticipeDeMercado.declararVarsPSimResPorDefectoIntercalandoPostes(
  const nombresVars: array of string; nPostes: integer);
var
  iPoste: integer;
  iVariable: integer;
  varDef: TVarDef;
  strPoste, strIndice: string;
begin
  for iPoste := 1 to nPostes do
  begin
    strPoste := '_P' + IntToStr(iPoste);
    strIndice := '[' + IntToStr(iPoste) + ']';
    for iVariable := 0 to high(nombresVars) do
    begin
      //Si no encuentra la variable con "_Pi" la busca con "[i]"
      if buscarVariable(nombresVars[iVariable] + strPoste, varDef) or
        buscarVariable(nombresVars[iVariable] + strIndice, varDef) then
      begin
        varDef.Prepararse;
        variablesParaSimRes.Add(varDef);
      end
      else
        raise Exception.Create(
          'TCosaParticipeDeMercado.declararVarsPSimResPorDefectoIntercalandoPostes: no se encuentra la variable '
          + nombresVars[iVariable] + strPoste);
    end;
  end;
end;

{$ENDIF}

procedure TCosaParticipeDeMercado.Depurar_VaraiblesParaSimRes;
var
  ivarParaSimRes: integer;
begin
  iVarParaSimRes := 0;
  while iVarParaSimRes < variablesParaSimRes.Count do
    if TVarDef(variablesParaSimRes[iVarParaSimRes]).flg_smartdump_write then
    begin
writeln(self.nombre, ': ', TVarDef(variablesParaSimRes[iVarParaSimRes]).nombreVar, ' PUBLICADA ' );
      Inc(ivarParaSimRes);
    end
    else
    begin
writeln(self.nombre, ': ', TVarDef(variablesParaSimRes[iVarParaSimRes]).nombreVar, ' DELETE ' );
      variablesParaSimRes.Delete(iVarParaSimRes);
    end;

end;

procedure TCosaParticipeDeMercado.sim_PrintResultados_Encab(var fsal: textfile;
  kencab: integer);
var
  iVarParaSimRes: integer;
begin
  case kencab of
    0:
      for iVarParaSimRes := 0 to variablesParaSimRes.Count - 1 do
        Write(fsal, #9, TVarDef(variablesParaSimRes[iVarParaSimRes]).getNombreCosa);
    1:
      for iVarParaSimRes := 0 to variablesParaSimRes.Count - 1 do
        Write(fsal, #9, TVarDef(variablesParaSimRes[iVarParaSimRes]).getUnidades);
    2:
      for iVarParaSimRes := 0 to variablesParaSimRes.Count - 1 do
        Write(fsal, #9, TVarDef(variablesParaSimRes[iVarParaSimRes]).getNombreVar);
    3:
      for iVarParaSimRes := 0 to variablesParaSimRes.Count - 1 do
        Write(fsal, #9, TVarDef(variablesParaSimRes[iVarParaSimRes]).getPostesVars);
  end;
end;

procedure TCosaParticipeDeMercado.sim_PrintResultados(var fsal: textfile);
var
  iVarParaSimRes: integer;
begin
  for iVarParaSimRes := 0 to variablesParaSimRes.Count - 1 do
    Write(fsal, #9, TVarDef(variablesParaSimRes[iVarParaSimRes]).asS);
end;


procedure TCosaParticipeDeMercado.sim_FinCronicaPrintEstadoFinal(var fsal: textfile);
begin
  // cada participante debe imprimir un renglon por variable que exporte
  // el formato preferido es
  // NombreActor.Variable = Valor
end;


procedure TCosaParticipeDeMercado.InicioSim;
begin
  // Si corresponde cada participante que escriba lo que quiera
end;

procedure TCosaParticipeDeMercado.InicioOpt;
begin
  // Si corresponde cada participante que escriba lo que quiera
end;


destructor TCosaParticipeDeMercado.Destroy;
begin
  variablesParaSimRes.FreeSinElementos;
  inherited Destroy;
end;


{$IFDEF BOSTA}
procedure TCosaParticipeDeMercado.AfterInstantiation;
begin
  inherited AfterInstantiation;
  sorteadorUniforme := nil;
  variablesParaSimRes := TListaVarDefs.Create;

  if Assigned(lpd) then
    lpd.Propietario := self;
end;
{$ENDIF}

end.
