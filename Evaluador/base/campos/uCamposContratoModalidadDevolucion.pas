unit uCamposContratoModalidadDevolucion;

interface

uses
  uCampo, ucontratomodalidaddevolucion, uFechas, Math, urscampos;

procedure crearCamposTContratoModalidadDevolucion;
procedure liberarCamposTContratoModalidadDevolucion;

var
  camposContratoModalidadDevolucion, camposFichaContratoModalidadDevolucion: TDAOfTCampo;

implementation

procedure crearCamposTContratoModalidadDevolucion;
var
  actor: TContratoModalidadDevolucion;
  ficha: TFichaContratoModalidadDevolucion;

  a: TDAOfTCampo;
  i: Integer;
begin
  actor := TContratoModalidadDevolucion.Create('aux', TFecha.Create_Dt(0),
    TFecha.Create_Dt(0), NIL, NIL, NIL, 0, 2);

  SetLength(camposContratoModalidadDevolucion, 3);
  a := camposContratoModalidadDevolucion;
  i := 0;

  addCampo(rsNombre, rsNombre, rsVacio, actor, actor.nombre, a, i);
  addCampo(rsCreditoInicialDeEnergia, rsCredIniEnerg, rsUMWh, actor, actor.E_Credito_ini, a,
    i);
  addCampo(rsNumeroDeDiscretizaciones, rsNDisc, rsVacio, actor, actor.NDisc, 2, MaxInt, a, i);
  listaCamposDeClases.Add(TParClaseCampos.Create(TContratoModalidadDevolucion,
      camposContratoModalidadDevolucion));
  actor.Free;

  ficha := TFichaContratoModalidadDevolucion.Create(TFecha.Create_Dt(0), NIL,
    TFecha.Create_Dt(0), TFecha.Create_Dt(0), TFecha.Create_Dt(0), TFecha.Create_Dt(0), 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0);

  SetLength(camposFichaContratoModalidadDevolucion, 15);
  a := camposFichaContratoModalidadDevolucion;
  i := 0;

  addCampo(rsFechaDeInicioDeImportacion, rsIniImport, rsVacio, ficha, ficha.dtImpoIni, a, i);
  addCampo(rsFechaDeFinDeImportacion, rsFinImport, rsVacio, ficha, ficha.dtImpoFin, a, i);
  addCampo(rsFechaDeInicioDeDevolucion, rsIniDevol, rsVacio, ficha, ficha.dtDevoIni, a, i);
  addCampo(rsFechaDeFinDeDevolucion, rsFinDevol, rsVacio, ficha, ficha.dtDevoFin, a, i);
  addCampo(rsEnergiaMaximaDeImportacion, rsEMaxImp, rsUMWh, ficha, ficha.EMaxImp, 0,
    MaxDouble, a, i);
  addCampo(rsPotenciaMaximaDeImportacion, rsPMaxImp, rsUMW, ficha, ficha.PMaxImp, 0,
    MaxDouble, a, i);
  addCampo(rsCostoVariableDeImportacion, rsCVImp, rsUUSDPorMWh, ficha, ficha.cvImp, 0,
    MaxDouble, a, i);
  addCampo(rsRendimientoDeImportacion, rsRendImp, rsUPU, ficha, ficha.renImp, 0, 1, a, i);
  addCampo(rsFactorDeDisponibilidadDeImportacion, rsFDispImp, rsUPU, ficha, ficha.fdImp, 0, 1,
    a, i);
  addCampo(rsPotenciaMaximaDeExportacion, rsPMaxExp, rsUMW, ficha, ficha.PMaxExp, 0,
    MaxDouble, a, i);
  addCampo(rsCostoVariableDeExportacion, rsCVExp, rsUUSDPorMWh, ficha, ficha.cvExp, 0,
    MaxDouble, a, i);
  addCampo(rsRendimientoDeExportacion, rsRendExp, rsUPU, ficha, ficha.renExp, 0, 1, a, i);
  addCampo(rsCostoVariableDeDevolucion, rsCVDev, rsUUSDPorMWh, ficha, ficha.cvDevolucion, 0,
    MaxDouble, a, i);
  addCampo(rsFactorDeDisponibilidadDeExportacion, rsFDispExp, rsUPU, ficha, ficha.fdExp, 0, 1,
    a, i);
  addCampo(rsFactorDeIncremento, rsFInc, rsUPU, ficha, ficha.fi, 0, MaxDouble, a, i);

  listaCamposDeClases.Add(TParClaseCampos.Create(TFichaContratoModalidadDevolucion,
      camposFichaContratoModalidadDevolucion));
  ficha.Free;
end;

procedure liberarCamposTContratoModalidadDevolucion;
begin
  listaCamposDeClases.quitarClase(TContratoModalidadDevolucion, True);
  listaCamposDeClases.quitarClase(TFichaContratoModalidadDevolucion, True);
end;

initialization

crearCamposTContratoModalidadDevolucion;

finalization

liberarCamposTContratoModalidadDevolucion;

end.
