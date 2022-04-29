unit uCompositorCFs;

interface

uses
  SysUtils, Classes, uEstados, uFechas, Math, xMatDefs;

resourcestring
  mesElCFSeleccionadoTieneUnaDuracionDelPasoDeTiempoDistintaALosDemas =
    'El CF seleccionado tiene una duracion del paso de tiempo distinta a los demas de la lista';
  mesDebeAgregarAlgunCFParaComponer = 'Debe agregar algún CF para componer';
  mesFInicioArchiSalidaEntreLaFIniPrimerCFAComponer =
    'La fecha de inicio del archivo de salida debe estar entre la fecha de inicio';
  mesY = 'y';
  mesFFinPrimerCFAComponer = 'la fecha de fin del primer CF a componer';
  mesElCF = 'El CF ';
  mesTieneSuFechaDeValidezFueraDeSuHorizonteDeTiempo =
    ' tiene su fecha de validez fuera de su horizonte de tiempo';
  mesTerminaAntesQueEmpieceElCF = ' termina antes que empiece el CF ';
  mesTieneVariablesDistintasQueElCF = ' tiene variables distintas que el CF ';

type
  TCFAComponer = class
  public
    archivoCF: String;
    fechaDeInicio, fechaDeFin, valeDesde: TDateTime;

    Constructor Create(const archivoCF: String;
      fechaDeInicio, fechaDeFin, valeDesde: TDateTime);
  end;

  TListaCFsAComponer = class(TList)
  public
    function agregarCFAComponer(cfAComponer: TCFAComponer): Integer;

    function iCFAComponer(const archivoCF: String): Integer;
    function buscarCFAComponer(const archivoCF: String): TCFAComponer;

    procedure ordenarPorValeDesde;

    procedure FreeConElementos;
  end;

  TCompositorCFs = class
  private
  public
    formatoFechas: String;
    fechaDeInicio, fechaDeFin: TDateTime;
    horasDelPaso: NReal;
    listaCFsAComponer: TListaCFsAComponer;

    Constructor Create(const formatoFechas: String);

    function agregarCF(const archiCF: String): String;
    function valeDesdeValido(iCF: Integer; nuevoValeDesde: TDateTime): Boolean;
    procedure cambiarValeDesdeCF(iCF: Integer; nuevoValeDesde: TDateTime);

    function eliminarCF(iCF: Integer): String;

    {
     Sean:
     FIniSal: fecha de inicio del archivo de salida
     FFinSal: fecha de fin del archivo de salida
     nCFs: listaCFsAComponer.Count

     Verifica que:
     ==>Haya al menos un CF a componer
     -nCFs > 0

     ==>La fecha de inicio del archivo de salida este comprendida entre las
     ==>fechas de inicio y fin del primer CF a componer
     -listaCFsAComponer[0].fechaDeInicio <= FIniSal < listaCFsAComponer[0].FechaDeFin

     ==>La fecha de fin del archivo de salida este comprendida entre las
     ==>fechas de inicio y fin del último CF a componer
     -listaCFsAComponer[nCFs-1].FechaDeInicio <= FFinSal < listaCFsAComponer[nCFs-1].FechaDeFin

     ==>La fecha a partir de la cual vale un CF está comprendida entre sus
     ==>fechas de inicio y fin
     -Para todo CF perteneciente a listaCFsAComponer
     - CF.FechaDeInicio <= CF.valeDesde < CF.FechaDeFin

     ==>No quedan huecos en el CF de salida
     -Para todo CF perteneciente a listaCFsAComponer menos el último
     - sea CF' el CF siguiente en listaCFsAComponer
     - CF'.FechaDeInicio <= CF.FechaDeInicio < CF'.FechaDeFin

     Esta restricción se podría quitar pero en principio lo hacemos así por
     sencillez
     ==>Todos los CFs a componer deben tener las mismas variables

     Si cualquiera de estas condiciones no se cumple retorna false y errores
     (si no es NIL) se carga con la descripción de los errores encontrados.
     Si se cumplen todas retorna true
     }
    function validarEntradas(var errores: TStringList): Boolean;
    procedure componerCFs(const archiCFSalida: String);

    procedure Free;
  end;

implementation

{ TCFAComponer }

constructor TCFAComponer.Create(const archivoCF: String;
  fechaDeInicio, fechaDeFin, valeDesde: TDateTime);
begin
  inherited Create;
  self.archivoCF := archivoCF;
  self.fechaDeInicio := fechaDeInicio;
  self.fechaDeFin := fechaDeFin;
  self.valeDesde := valeDesde;
end;

{ TListaCFsAComponer }

function TListaCFsAComponer.agregarCFAComponer(cfAComponer: TCFAComponer)
  : Integer;
var
  iPos: Integer;
begin
  iPos := 0;
  while (iPos < Count) and (cfAComponer.valeDesde > TCFAComponer(items[iPos])
      .valeDesde) do
    iPos := iPos + 1;

  Insert(iPos, cfAComponer);
  Result := iPos;
end;

function TListaCFsAComponer.iCFAComponer(const archivoCF: String): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to Count - 1 do
    if TCFAComponer(items[i]).archivoCF = archivoCF then
    begin
      Result := i;
      break;
    end;
end;

function TListaCFsAComponer.buscarCFAComponer(const archivoCF: String)
  : TCFAComponer;
var
  i: Integer;
begin
  Result := NIL;
  for i := 0 to Count - 1 do
    if TCFAComponer(items[i]).archivoCF = archivoCF then
    begin
      Result := TCFAComponer(items[i]);
      break;
    end;
end;

function compareCFsAComponerPorValeDesde(item1, item2: Pointer): Integer;
begin
  if TCFAComponer(item1).valeDesde < TCFAComponer(item2).valeDesde then
    Result := -1
  else if TCFAComponer(item1).valeDesde > TCFAComponer(item2).valeDesde then
    Result := 1
  else
    Result := 0;
end;

procedure TListaCFsAComponer.ordenarPorValeDesde;
begin
  Sort(compareCFsAComponerPorValeDesde);
end;

procedure TListaCFsAComponer.FreeConElementos;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    TCFAComponer(items[i]).Free;
  inherited Free;
end;

{ TCompositorCFs }

constructor TCompositorCFs.Create(const formatoFechas: String);
begin
  inherited Create;

  self.formatoFechas := formatoFechas;
  listaCFsAComponer := TListaCFsAComponer.Create;
  fechaDeInicio := MaxDateTime;
  fechaDeFin := MinDateTime;
  horasDelPaso := -1;
end;

function TCompositorCFs.agregarCF(const archiCF: String): String;
var
  nuevoCF: TAdminEstados;
begin
  nuevoCF := TAdminEstados.CreateLoadFromArchi(archiCF);

  if horasDelPaso = -1 then
    horasDelPaso := nuevoCF.horasDelPaso;

  if nuevoCF.fechaIni.dt < fechaDeInicio then
    fechaDeInicio := nuevoCF.fechaIni.dt;
  if nuevoCF.fechaFin.dt > fechaDeFin then
    fechaDeFin := nuevoCF.fechaFin.dt;

  if nuevoCF.horasDelPaso = horasDelPaso then
    listaCFsAComponer.agregarCFAComponer(TCFAComponer.Create(archiCF,
        nuevoCF.fechaIni.dt, nuevoCF.fechaFin.dt, nuevoCF.fechaIni.dt))
  else
    Result :=
      mesElCFSeleccionadoTieneUnaDuracionDelPasoDeTiempoDistintaALosDemas;

  nuevoCF.Free;
end;

function TCompositorCFs.valeDesdeValido(iCF: Integer;
  nuevoValeDesde: TDateTime): Boolean;
begin
  Result := fechaEntre(nuevoValeDesde,
    TCFAComponer(listaCFsAComponer[iCF]).fechaDeInicio,
    TCFAComponer(listaCFsAComponer[iCF]).fechaDeFin);
end;

procedure TCompositorCFs.cambiarValeDesdeCF(iCF: Integer;
  nuevoValeDesde: TDateTime);
begin
  if fechaEntre(nuevoValeDesde,
    TCFAComponer(listaCFsAComponer[iCF]).fechaDeInicio,
    TCFAComponer(listaCFsAComponer[iCF]).fechaDeFin) then
  begin
    TCFAComponer(listaCFsAComponer[iCF]).valeDesde := nuevoValeDesde;
    listaCFsAComponer.ordenarPorValeDesde;
  end;
end;

function TCompositorCFs.eliminarCF(iCF: Integer): String;
begin
  TCFAComponer(listaCFsAComponer[iCF]).Free;
  listaCFsAComponer.Delete(iCF);
end;

function TCompositorCFs.validarEntradas(var errores: TStringList): Boolean;
var
  i: Integer;
  error: Boolean;
  cf, cf2: TCFAComponer;
  cfBin, cfBin2: TAdminEstados;
begin
  error := False;
  {
   ==>Haya al menos un CF a componer
   -nCFs > 0
   }
  if listaCFsAComponer.Count > 0 then
  begin
    listaCFsAComponer.ordenarPorValeDesde;

    {
     ==>La fecha de inicio del archivo de salida este comprendida entre las
     ==>fechas de inicio y fin del primer cf a componer
     - listaCFsAComponer[0].fechaDeInicio <= FIniSal < listaCFsAComponer[0].fechaDeFin
     }
    cf := TCFAComponer(listaCFsAComponer[0]);
    if not fechaEntre(fechaDeInicio, cf.fechaDeInicio, cf.fechaDeFin) then
    begin
      if errores <> NIL then
        errores.Add(mesFInicioArchiSalidaEntreLaFIniPrimerCFAComponer + '(' +
            FormatDateTime(formatoFechas, cf.fechaDeInicio)
            + ') ' + mesY + ' ' + mesFFinPrimerCFAComponer + '(' +
            FormatDateTime(formatoFechas, cf.fechaDeFin) + ')');
      error := True;
    end;

    {
     ==>La fecha de fin del archivo de salida este comprendida entre las
     ==>fechas de inicio y fin del último cf a componer
     - listaCFsAComponer[nCFs - 1].fechaDeInicio <= FFinSal < listaCFsAComponer[nCFs - 1].fechaDeFin
     }
    cf := TCFAComponer(listaCFsAComponer[listaCFsAComponer.Count - 1]);
    if not fechaEntre(fechaDeFin, cf.fechaDeInicio, cf.fechaDeFin) then
    begin
      if errores <> NIL then
        errores.Add(mesFInicioArchiSalidaEntreLaFIniPrimerCFAComponer + '(' +
            FormatDateTime(formatoFechas, cf.fechaDeInicio)
            + ') ' + mesY + ' ' + mesFFinPrimerCFAComponer + '(' +
            FormatDateTime(formatoFechas, cf.fechaDeFin) + ')');
      error := True;
    end;

    {
     ==>La fecha a partir de La cual vale un cf está comprendida entre sus
     ==>fechas de inicio y fin
     - Para todo CF perteneciente a listaCFsAComponer
     - CF.fechaDeInicio <= CF.valeDesde < CF.fechaDeFin
     }
    for i := 0 to listaCFsAComponer.Count - 1 do
    begin
      cf := TCFAComponer(listaCFsAComponer[i]);
      if not fechaEntre(cf.valeDesde, cf.fechaDeInicio, cf.fechaDeFin) then
      begin
        if errores <> NIL then
          errores.Add(mesElCF + '"' + cf.archivoCF + '"' +
              mesTieneSuFechaDeValidezFueraDeSuHorizonteDeTiempo + '([' +
              FormatDateTime(formatoFechas, cf.fechaDeInicio)
              + ', ' + FormatDateTime(formatoFechas, cf.fechaDeFin) + '))');
        error := True;
      end;
    end;

    {
     ==> No quedan huecos en el cf de salida
     - Para todo CF perteneciente a listaCFsAComponer menos el último
     - sea CF' el CF siguiente en listaCFsAComponer
     - CF'.FechaDeInicio <= CF.FechaDeInicio < CF'.fechaDeFin
     }
    for i := 0 to listaCFsAComponer.Count - 2 do
    begin
      cf := TCFAComponer(listaCFsAComponer[i]);
      cf2 := TCFAComponer(listaCFsAComponer[i + 1]);
      if not fechaEntre(cf.fechaDeInicio, cf2.fechaDeInicio, cf2.fechaDeFin)
        then
      begin
        if errores <> NIL then
          errores.Add(mesElCF + '"' + cf.archivoCF + '"' + '([' + FormatDateTime
              (formatoFechas, cf.fechaDeInicio) + ', ' + FormatDateTime
              (formatoFechas, cf.fechaDeFin) + '))');
        error := True;
      end;
    end;

    {
     Esta restricción se podría quitar pero en principio lo hacemos así por
     sencillez
     ==>Todos los CFs a componer deben tener las mismas variables
     }

    cf := TCFAComponer(listaCFsAComponer[0]);
    cfBin := TAdminEstados.CreateLoadFromArchi(cf.archivoCF);
    for i := 1 to listaCFsAComponer.Count - 1 do
    begin
      cf2 := TCFAComponer(listaCFsAComponer[i]);
      cfBin2 := TAdminEstados.CreateLoadFromArchi(cf2.archivoCF);
      if not cfBin.variablesIgualesA(cfBin2) then
      begin
        if errores <> NIL then
          errores.Add(mesElCF + '"' + cf2.archivoCF + '" ' +
              mesTieneVariablesDistintasQueElCF + '"' + cf.archivoCF + '"');
        error := True;
      end;
      cfBin2.Free;
    end;
    cfBin.Free;
  end
  else
  begin
    if errores <> NIL then
      errores.Add(mesDebeAgregarAlgunCFParaComponer);
    error := True;
  end;
  Result := not error;
end;

procedure TCompositorCFs.componerCFs(const archiCFSalida: String);
var
  dtDelPaso: NReal;
  cfAComponer: TCFAComponer;
  cf, CFSalida: TAdminEstados;
  costoFuturo: TMatOfNReal;
  nPuntosT, iPasoSalida, iPasoCF: Integer;
  iterFecha: TDateTime;

  iCFAComponer, oldICFAComponer: Integer;
begin
  dtDelPaso := horasDelPaso * horaToDt;
  nPuntosT := ceil(horasHasta(fechaDeInicio, fechaDeFin) / (horasDelPaso));
  //El costoFuturo[0] no se usa, se empieza desde la posición 1
  SetLength(costoFuturo, nPuntosT + 2);

  iCFAComponer := 0;
  cfAComponer := TCFAComponer(listaCFsAComponer[iCFAComponer]);
  cf := TAdminEstados.CreateLoadFromArchi(cfAComponer.archivoCF);

  //Para inicializar con algo
  SetLength(costoFuturo[0], cf.constelacion.nEstrellas);
  vclear(costoFuturo[0]);
  for iPasoSalida := 0 to nPuntosT do
  begin
    iterFecha := fechaDeInicio + iPasoSalida * dtDelPaso;

    oldICFAComponer := iCFAComponer;
    while (iCFAComponer < listaCFsAComponer.Count - 1) and
      (iterFecha >= TCFAComponer(listaCFsAComponer[iCFAComponer + 1])
        .valeDesde) do
      iCFAComponer := iCFAComponer + 1;

    if oldICFAComponer <> iCFAComponer then
    begin
      cfAComponer := TCFAComponer(listaCFsAComponer[iCFAComponer]);
      cf.Free;
      cf := TAdminEstados.CreateLoadFromArchi(cfAComponer.archivoCF);
    end;

    iPasoCF := round((iterFecha - cf.fechaIni.dt) * dtToHora / horasDelPaso)
      + 1;

    costoFuturo[iPasoSalida + 1] := copy(cf.constelacion.fCosto[iPasoCF]);
  end;
  //cf queda con el último cf cargado y todos tienen las mismas variables
  CFSalida := TAdminEstados.Create(cf.nVarsContinuas, cf.nVarsDiscretas,
    nPuntosT);
  CFSalida.copiarVariablesDe(cf);
  CFSalida.CrearElEspacioTiempo(TFecha.Create_Dt(fechaDeInicio),
    TFecha.Create_Dt(fechaDeFin), horasDelPaso, costoFuturo, false );
  CFSalida.StoreInArchi(archiCFSalida);

  cf.Free;
{$DEFINE DEBUG}
{$IFDEF DEBUG}
  for iCFAComponer := 0 to listaCFsAComponer.Count - 1 do
  begin
    cfAComponer := TCFAComponer(listaCFsAComponer[iCFAComponer]);
    cf := TAdminEstados.CreateLoadFromArchi(cfAComponer.archivoCF);
    cf.dumpToTextFile('cfAComponer_' + IntToStr(iCFAComponer) + '.xls');
    cf.Free;
  end;
  CFSalida.dumpToTextFile('cf_debug.xls');
{$ENDIF}
{$UNDEF DEBUG}
  CFSalida.Free;
end;

procedure TCompositorCFs.Free;
begin
  listaCFsAComponer.FreeConElementos;
  inherited Free;
end;

end.
