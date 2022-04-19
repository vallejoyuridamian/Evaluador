unit ueditorsala;

{$mode delphi}

interface

uses
  Classes, SysUtils, syncobjs,
  uConstantesSimSEE,
  usalasdejuego, ucosa,
  usalasdejuegoParaEditor,
  uInicioYFinal;

type
  TRbtEditorSala_cmd = class;

  { TEjecutorDeOrden }
  TEjecutorDeOrden = class
    editor: TRbtEditorSala_cmd; // puntero al editor sobre el que actua
    idOrden: string;
    nParMin: integer; // >= 0
    nParMax: integer; // -1 = cualquier cantidad

    // lista de ayuda para la exploración por comando ls, cd
    LasCosas: TList;


    constructor Create(editor: TRbtEditorSala_cmd; idOrden: string; nParMin,
      nParMax: integer);

    // chequea si el primer parámetro coincide co idOrden y si la cantidad
    // de parámetros es la adecuada y retorna TRUE si este ejecutor es apto
    // para procesar la orden y FALSE en caso contrario.
    function FirmaOk(orden: string; paramLst: TStrings): boolean;
    function ejecutar(paramLst: TStrings): TStrings; virtual;
    function ayuda: TStrings; virtual;
  end;

  { TRbtEditorSala_cmd }
  TRbtEditorSala_cmd = class(TRbtEditorSala)
    nid: integer;
    flg_modificada: boolean;
    EjecutoresDeOrdenes: TList;
    constructor Create(nid: integer);

    // Busca el ejecutor asociado a la orden y le pasa los parametros
    // si no encuentra el ejecutor, retonra en la primera linea "error: comando desconocido".
    // si lo encuentra retorna lo que retorne el ejecutor.
    // El comando desconocido puede ser porque el nombre de la orden sea desconocido
    // o porque la cantidad de parámetros no es correcta.
    function ejecutar( orden: string; paramlst: TStrings): TStrings;
  end;


  { TEjecutor_cargar_sala }
  TEjecutor_cargar_sala = class(TEjecutorDeOrden)
    constructor Create(editor: TRbtEditorSala_cmd);
    function ejecutar(paramLst: TStrings): TStrings; override;
    function ayuda: TStrings; override;
  end;


  { TEjecutor_guardar_sala }

  TEjecutor_guardar_sala = class(TEjecutorDeOrden)
    constructor Create(editor: TRbtEditorSala_cmd);
    function ejecutar(paramLst: TStrings): TStrings; override;
    function ayuda: TStrings; override;
  end;


  { TRobotEditores }

  TRobotEditores = class(TList)
    cs: TCriticalSection;

    constructor Create;
    destructor Destroy; override;

    // Si no existe retorna nil
    function LocateRobotEditor(nid: integer): TRbtEditorSala_cmd;
    function CreateRobotEditor: TRbtEditorSala_cmd;

    // da el siguiente nid e incrementa el contador en forma segura
    function nextnid: integer;
  private
    cnt_nextnid: integer;
  end;


procedure wrln(r: TStrings; s: string);
procedure werror(r: TStrings; s: string);

implementation


procedure wrln(r: TStrings; s: string);
begin
  r.Add(s);
end;

procedure werror(r: TStrings; s: string);
begin
  r.add('ERROR: ' + s);
end;

{ TEjecutor_guardar_sala }

constructor TEjecutor_guardar_sala.Create(editor: TRbtEditorSala_cmd);
begin
  inherited Create(editor, 'guardar_sala', 0, 1);
end;

function TEjecutor_guardar_sala.ejecutar(paramLst: TStrings): TStrings;
begin
  Result:=inherited ejecutar(paramLst);
end;

function TEjecutor_guardar_sala.ayuda: TStrings;
begin
  Result:=inherited ayuda;
end;

{ TRobotEditores }

constructor TRobotEditores.Create;
begin
  inherited Create;
  cs := TCriticalSection.Create;
  cnt_nextnid := 1;
end;

destructor TRobotEditores.Destroy;
var
  k: integer;
  aRbt: TRbtEditorSala_cmd;
begin
  cs.Enter;
  for k := 0 to Count - 1 do
  begin
    aRbt := items[k];
    aRbt.Free;
  end;
  cs.Free;
  inherited Destroy;
end;

function TRobotEditores.LocateRobotEditor(nid: integer): TRbtEditorSala_cmd;
var
  buscando: boolean;
  k: integer;
  aRbt: TRbtEditorSala_cmd;
begin
  buscando := True;
  k := 0;
  while buscando and (k < Count) do
  begin
    aRbt := items[k];
    if aRbt.nid = nid then
      buscando := False
    else
      Inc(k);
  end;
  if not buscando then
    Result := aRbt
  else
    Result := nil;
end;

function TRobotEditores.CreateRobotEditor: TRbtEditorSala_cmd;
var
  aRbt: TRbtEditorSala_cmd;
  anid: integer;
begin
  anid := nextnid;
  aRbt := TRbtEditorSala_cmd.Create(anid);
  cs.Acquire;
  try
    add(aRbt);
  finally
    cs.Release;
  end;
  Result := aRbt;
end;

function TRobotEditores.nextnid: integer;
begin
  cs.Enter;
  try
    Result := cnt_nextnid;
    Inc(cnt_nextnid);
  finally
    cs.Leave;
  end;
end;


{ TEjecutor_Abrir }

constructor TEjecutor_cargar_sala.Create(editor: TRbtEditorSala_cmd);
begin
  inherited Create(editor, 'cargar_sala', 1, 1);
end;



function TEjecutor_cargar_sala.ejecutar(paramLst: TStrings): TStrings;
var
  res: TStrings;
  f: TArchiTexto;
  archi: string;
  cnt_errores: integer;

begin
  Res := inherited ejecutar(paramLst);

  cnt_errores:= 0;
  archi := paramLst[0];
  try
    chdir(extractFilePath(archi));
    f := TArchiTexto.CreateForRead(0, editor.CatalogoReferencias, archi, False);
    try
      f.rd('sala', TCosa(editor.sala));
    finally
      f.Free;
    end;

    if editor.sala = nil then
    begin
      inc( cnt_errores );
      werror(res, 'No fue posible cargar la sala del archivo: ' + archi);
    end;

    editor.sala.setDirCorrida(archi);
    if editor.resolverReferenciasContraSala(False) > 0 then
    begin
      inc( cnt_errores );
      werror(res, 'No se pudo resolver todas las asociaciones entre los actores' +
        ' de la sala, por lo que no se cargará. Puede ver la lista de ' +
        'referencias que no pudieron resolverse en el siguiente ' +
        'archivo: ' + getDir_Run + 'errRefs.txt');
    end;

    editor.Sala.Prepararse_( editor.CatalogoReferencias);
    editor.sala.publicarTodasLasVariables;
    if cnt_errores = 0 then
       wrln(res, 'OK, sala abierta exitosamente.' )
    else
       wrln(res, 'ATENCIÓN, sala abierta con inconvenientes.' );
  finally
  end;
  result:= res;
end;




function TEjecutor_cargar_sala.ayuda: TStrings;
begin
  Result := inherited ayuda;
end;

{ TRbtEditorSala }

constructor TRbtEditorSala_cmd.Create(nid: integer);
begin
  inherited Create(nil);
  self.nid := nid;
  EjecutoresDeOrdenes := TList.Create;
  EjecutoresDeOrdenes.Add( TEjecutor_cargar_sala.Create(self) );
end;

function TRbtEditorSala_cmd.ejecutar(orden: string; paramlst: TStrings
  ): TStrings;
var
  buscando: boolean;
  k: integer;
  aEjecutor: TEjecutorDeOrden;
  res: TStringList;

begin
  // buscamos el ejecutor
  buscando:= true;
  k:= 0;
  while buscando and ( k < EjecutoresDeOrdenes.Count ) do
  begin
    aEjecutor:= EjecutoresDeOrdenes.items[k];
    if aEjecutor.FirmaOk( orden, paramLst ) then
      buscando:= false
    else
      inc( k );
  end;

  if buscando then
  begin
    res:= TStringList.Create;
    res.add( 'error: comando desconocido.' );
    res.add( '<br>posibles comandos: ' );
    for k:= 0 to EjecutoresDeOrdenes.count-1 do
    begin
      res.AddStrings( TEjecutorDeOrden( EjecutoresDeOrdenes.items[k] ).ayuda );
    end;
    result:= res;
  end
  else
  begin
    result:= aEjecutor.ejecutar( paramLst );
  end;
end;

{ TEjecutorDeOrden }

constructor TEjecutorDeOrden.Create(editor: TRbtEditorSala_cmd; idOrden: string;
  nParMin, nParMax: integer);
begin
  inherited Create;
  self.editor := editor;
  self.idOrden := idOrden;
  self.nParMin:= nParMin;
  self.nParMax:= nParMax;
end;

function TEjecutorDeOrden.FirmaOk(orden: string; paramLst: TStrings): boolean;
begin
  Result := (idOrden = orden) and (nParMin <= paramLst.Count) and
    ((nParMax < 0) or (paramLst.Count <= nParMax));
end;

function TEjecutorDeOrden.ejecutar(paramLst: TStrings): TStrings;
var
  res: TStringList;
begin
  res := TStringList.Create;
end;

function TEjecutorDeOrden.ayuda: TStrings;
var
  res: TStringList;
  s, auxs: string;
  k: integer;
begin
  res := TStringList.Create;
  s := 'Sintaxis: ' + idOrden;
  if nParMax = nParMin then
  begin
    if nParMax = 1 then
      s := s + ' p1'
    else if nParMax > 0 then
    begin
      for k := 1 to nParMax do
        s := s + ' p' + IntToStr(k);
    end;
  end
  else
  begin
    for k := 1 to nParMin do
      s := s + ' p' + IntToStr(k);
    if nParMax < 0 then
      s := s + '[... [p' + IntToStr(nParMin + 1) + '] ... pN]'
    else
    begin
      auxs := '';
      for k := nParMin + 1 to nParMax do
        auxs := '[' + auxs + ' p' + IntToStr(k) + ']';
      s := s + auxs;
    end;
  end;
  res.add(s);
  Result := res;
end;

end.

constructor TRbtEditorSala.Create_Nueva;
begin
end;
procedure TRbtEditorSala.Guardar;
begin
end;
function TRbtEditorSala.ejecutar(comandos: TStrings): TStrings;
begin
end;





procedure TFSimSEEEdit.mConsolaKeyPress(Sender: TObject; var Key: char);
var
  aRecLnk: TCosa_RecLnk;
  aCampoLnk: TCosa_CampoLnk;
  campo, orden, s: string;
  LaCosa: TCosa;
  aCosaH: TCosa;
  k, rescod: integer;
begin
  if key = #13 then
  begin
    s := trim(mComandos.Lines[mComandos.Lines.Count - 1]);
    if LasCosas.Count = 0 then
      LasCosas.add(sala);
    LaCosa := LasCosas[LasCosas.Count - 1];

    aRecLnk := LaCosa.rec_lnk;
    if aRecLnk = nil then
    begin
      wrln('LaCosa.rec_lnk = NIL !!!!! PROBLEMA');
    end;

    orden := NextPal(s);

    if (orden = 'ls') and (s = '') then
    begin
      wrln('Explorando una instancia de:' + LaCosa.ClassName);
      if aRecLnk <> nil then
      begin
        for k := 0 to aRecLnk.Count - 1 do
        begin
          aCampoLnk := aRecLnk[k];
(**** OJO CON ESTO
          aCampoLnk.Devaluar;
          ***)
          wrln(IntToStr(k) + ': ' + aCampoLnk.CampoDef.nombreCampo +
            ' (' + aCampoLnk.CampoDef.ClassName + '), = ' + aCampoLnk.StrVal);
        end;
      end
      else
      begin
        // chequeamos si es una Lista de Cosas.
        if LaCosa is TListaDeCosas then
          for k := 0 to TListaDeCosas(LaCosa).Count - 1 do
          begin
            aCosaH := TCosa(TListaDeCosas(LaCosa)[k]);
            if aCosaH is TCosaConNombre then
              wrln(IntToStr(k) + ' : ' + (aCosaH as TCosaConNombre).nombre +
                ' (' + aCosaH.ClassName + ')')
            else
              wrln(IntToStr(k) + ' : s/n (' + aCosaH.ClassName + ')');
          end;

      end;
    end
    else if (orden = 'ls') and (s = 'clases_registradas') then
    begin
      mConsola.Lines.add('');
      mConsola.Lines.AddStrings(ListarRegistroDeClases);
    end
    else if (orden = 'cd') and (s <> '') then
    begin
      if s = '..' then
      begin
        // Subir al Padre
        if LasCosas.Count = 1 then
          wrln('Ya está en la raíz')
        else
        begin
          LasCosas.Delete(LasCosas.Count - 1);
          LaCosa := LasCosas[LasCosas.Count - 1];
          wrln('La Cosa: ' + LaCosa.InfoAd_20);
        end;
      end
      else if length(s) > 0 then
      begin
        val(s, k, rescod);
        if LaCosa is TListaDeCosas then
        begin
          if rescod = 0 then
            if (0 <= k) and (k < TListaDeCosas(LaCosa).Count) then
              aCosaH := TListaDeCosas(LaCosa)[k]
            else
              aCosaH := nil
          else
          if LaCosa is TListaDeCosasConNombre then
            aCosaH := TListaDeCosasConNombre(LaCosa).find(s)
          else
            wrln('no puede buscar por nombre en una lista de cosas sin nombre');

          if aCosaH <> nil then
          begin
            LasCosas.add(TCosa(aCosaH));
          end
          else
            wrln('No fue posible ubicar la Cosa: ' + s);
        end
        else
        begin
          if rescod = 0 then
          begin
            if (0 <= k) and (k < aRecLnk.Count) then
              aCampoLnk := aRecLnk[k]
            else
              aCampoLnk := nil;
          end
          else
            aCampoLnk := LaCosa.GetFieldByName(s);
          if (aCampoLnk <> nil) then
            if (aCampoLnk.CampoDef.ClassName = 'TCosa_CampoDef_Cosa') then
              if aCampoLnk.pval <> nil then
              begin
                LasCosas.add(TCosa(aCampoLnk.pval^));
                LaCosa := LasCosas[LasCosas.Count - 1];
                wrln('La Cosa: ' + LaCosa.InfoAd_20);
              end
              else
                wrln('COSA = NIL no es posible seleccionarla.')
            else
              wrln('El campo: ' + s + ' no es una Cosa')
          else
            wrln('No logré identificar el campo: ' + s);

        end;
      end;
    end
    else if (orden = 'set') then
    begin
      campo := nextpal(s);
      LaCosa.SetValStr(campo, s, self.sala.evaluador);
    end;
  end;
end;
