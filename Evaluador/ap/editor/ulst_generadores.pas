unit ulst_generadores;

{$mode delphi}

interface

uses
  Classes, SysUtils,
  Controls,
  StdCtrls,
  Graphics,
  uCosaConNombre,
  uDataSetGenerico, uvisordetabla,
  uactores,
  ugeneradores,
  usalasdejuego,
  ueditr_parametros_emisiones_gen,
  ufechas, cronomet;

type
  TListadoGeneradores = class(TTabla)
  public
    flg_populate: boolean;
    sala: TSalaDeJuego;
    modificado: ^boolean;
    filtro: string;

    constructor Create(AOwner: TComponent; Name: string; sala: TSalaDeJuego;
      var ModificadoEditor: boolean); reintroduce;
    procedure Editar_onClick(nidRec: string; kFila: integer); override;
    procedure CheckBox_OnClick(Sender: TObject); override;
    procedure Edit_OnChange(Sender: TObject); override;
    procedure Paint; override;
    procedure Populate;
  end;

resourcestring
  rs_EditarParmatros_CalculoEmisiones =
    'Editar parámetros para cálculo de factor de emisiones.';

implementation

constructor TListadoGeneradores.Create(AOwner: TComponent; Name: string;
  sala: TSalaDeJuego; var ModificadoEditor: boolean);
begin
  inherited Create(AOwner, Name, 4, 1, 0);
  self.sala := sala;
  flg_populate := True;
  modificado := @ModificadoEditor;
end;


procedure split_id(var c: char; var kgen, kfil: integer; s: string);
var
  ts: string;
  i: integer;
begin
  c := s[1];
  Delete(s, 1, 1);
  i := pos('k', s);
  ts := copy(s, 1, i - 1);
  kgen := StrToInt(ts);
  ts := copy(s, i + 1, length(s) - i);
  kfil := StrToInt(ts);
end;

procedure TListadoGeneradores.CheckBox_OnClick(Sender: TObject);
var
  kgen, kfil: integer;
  s: string;
  c: char;
  a: TGenerador;
begin
  modificado^ := True;
  split_id(c, kgen, kfil, TComponent(Sender).Name);

  a := sala.gens[kgen] as TGenerador;
  case c of
    'l': a.LowCostMustRun_ := TCheckBox(Sender).Checked;
    'c': a.CleanDevelopmentMechanism := TCheckBox(Sender).Checked;
  end;
end;

procedure TListadoGeneradores.Edit_OnChange(Sender: TObject);
var
  kgen, kfil: integer;
  s, snid: string;
  c: char;
  a: TGenerador;
  i: integer;
begin
  modificado^ := True;
  split_id(c, kgen, kfil, TComponent(Sender).Name);

  s := TEdit(Sender).Text;
  a := sala.gens[kgen] as TGenerador;
  try
    case c of
      'n': a.nacimiento.setDt(s);
      'f': a.TonCO2xMWh := StrToFloat(s);
    end;
    Self.SetBgColorFila(kfil, clLime);
  except
    // nada
    Self.SetBgColorFila(kfil, clRed);
  end;
end;

procedure TListadoGeneradores.Editar_onClick(nidRec: string; kFila: integer);
var
  a: TGenerador;
  f: TfEditParametrosEmisionesGenerador;
  res: integer;
  c: char;
  kGen, kFil: integer;
begin
  split_id(c, kGen, kFil, nidRec);
  a := sala.gens[kFila - 1] as TGenerador;
  f := TfEditParametrosEmisionesGenerador.Create(self);
  f.eTipo.Text := a.ClassName;
  f.eNombre.Text := a.Nombre;
  f.eNacimiento.Text := a.nacimiento.AsStr;
  f.eTonMWh.Text := FloatToStrF(a.TonCO2xMWh, ffFixed, 12, 4);
  f.cb_lcmr.Checked := a.LowCostMustRun_;
  f.cb_cdm.Checked := a.CleanDevelopmentMechanism;

  res := f.ShowModal;
  if res = 1 then
  begin
    modificado^ := True;
    a.nacimiento.setDt(f.eNacimiento.Text);
    a.TonCO2xMWh := StrToFloat(f.eTonMWh.Text);
    a.LowCostMustRun_ := f.cb_lcmr.Checked;
    a.CleanDevelopmentMechanism := f.cb_cdm.Checked;
    flg_populate := True;
    flg_disable_autoscroll := True;
    Invalidate;
  end;
  f.Free;
end;


procedure TListadoGeneradores.Populate;
var
  k: integer;
  snid, sk: string;
  a: TGenerador;
  estado: integer;
  flg_filtrado: boolean;
  uc_filtro: string;
  lst_filtro: TList;

  procedure pasaFiltro(vs: string);
  var
    ucvs: string;
  begin
    if flg_filtrado then
    begin
      if uc_filtro = '' then
        flg_filtrado := False
      else
      begin
        ucvs := uppercase(vs);
        if pos(uc_filtro, ucvs) > 0 then
          flg_filtrado := False;
      end;
    end;
  end;

begin
  lst_filtro := TList.Create;

  // primero armo la lista del filtro
  uc_filtro := uppercase(trim(filtro));
  for k := 1 to sala.gens.Count do
  begin
    a := sala.gens[k - 1] as TGenerador;
    flg_Filtrado := True;
    pasaFiltro(a.ClassName);
    pasaFiltro(a.Nombre);
    if not flg_Filtrado then
      lst_filtro.add(a);
  end;

  lst_filtro.Sort(@Sort_Actores_By_DT_DESC);

  flg_populate := False;

  ClearRedim(lst_filtro.Count + 1, 7);
  // fila encabezado
  wrTexto('', 0, 0, 'Tipo');
  wrTexto('', 0, 1, 'Nombre');
  wrTexto('', 0, 2, 'Entrada');
  wrTexto('', 0, 3, 'TCO2/MWh');
  wrTexto('', 0, 4, 'LCMR');
  wrTexto('', 0, 5, 'CDM');

  AlinearCelda(0, 0, CAH_Izquierda, CAV_Centro);
  AlinearCelda(0, 1, CAH_Izquierda, CAV_Centro);
  AlinearCelda(0, 2, CAH_Izquierda, CAV_Centro);
  AlinearCelda(0, 3, CAH_Izquierda, CAV_Centro);
  AlinearCelda(0, 4, CAH_Izquierda, CAV_Centro);
  AlinearCelda(0, 5, CAH_Izquierda, CAV_Centro);


  Self.SetBgColorFila(0, clNavy);
  Self.SetFontColorFila(0, clYellow);

  Self.SetBgColorCelda(0, 0, clNavy);
  Self.SetBgColorCelda(0, 1, clNavy);


  for k := 1 to lst_filtro.Count do
  begin

    a := TGenerador(lst_filtro.items[k - 1]);

    snid := IntToStr(sala.gens.IndexOf(a));

    wrTexto('', k, 0, a.ClassName);
    wrTexto('', k, 1, a.nombre);

    writeln(a.ClassName, '->', a.Nombre);
    sk := 'k' + IntToStr(k);


    //    wrTexto('', k, 2, a.nacimiento.AsStr );
    //    wrTexto('', k, 3, FloatToStrF( a.TonCO2xMWh, ffFixed, 12, 3)  );
    wrEdit('n' + snid + sk, k, 2, a.nacimiento.AsStr, 8, 'Fecha de ingreso al sistema.');
    wrEdit('f' + snid + sk, k, 3, FloatToStrF(a.TonCO2xMWh, ffFixed, 12, 3), 5,
      'TonCO2/MWh');
    wrCheckBox('l' + snid + sk, k, 4,'', a.LowCostMustRun_, 'Low Cost Must Run');
    wrCheckBox('c' + snid + sk, k, 5,'', a.CleanDevelopmentMechanism,
      'Clean Dvelopment Mechanism');

    AlinearCelda(k, 0, CAH_Izquierda, CAV_Centro);
    AlinearCelda(k, 1, CAH_Izquierda, CAV_Centro);
    AlinearCelda(k, 2, CAH_Izquierda, CAV_Centro);
    AlinearCelda(k, 3, CAH_Izquierda, CAV_Centro);
    AlinearCelda(k, 4, CAH_Izquierda, CAV_Centro);
    AlinearCelda(k, 5, CAH_Izquierda, CAV_Centro);


    // ahora la botonera en la última columna
    //    wrBotonera( snid, k, 6,  [ iid_Editar],  [ rs_EditarParmatros_CalculoEmisiones ]);


    if (k mod 2) = 0 then
      SetBgColorFila(k, clFondoFilaPar_Activa)
    else
      SetBgColorFila(k, clFondoFilaImpar_Activa);
  end;


  reposicionar;

  lst_filtro.Free;
end;

procedure TListadoGeneradores.Paint;
begin
  if flg_populate then
    Populate;
  inherited Paint;
end;


end.
