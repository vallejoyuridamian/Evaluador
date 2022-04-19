unit uAltaEdicionTVarIdxs;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
{$IFDEF FPC-LCL}
  LResources,
{$ENDIF}

{$IFDEF FPC}
  FileUtil,
{$ENDIF}
  {$IFDEF WINDOWS}
  Windows,
 {$ENDIF}

  Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, uBaseFormularios, uSalasDeJuego, uLectorSimRes3Defs,
  uHistoVarsOps, uActores,
  uConstantesSimSEE, uAuxiliares, uBaseAltaEdicionIndices, uVerDoc,
  uBaseAltaEdicionCronVars, uFuentesAleatorias;

resourcestring
  mesSeleccionoVariableCFaux = 'Seleccionó la variable CFaux.';
  mesVariableCFauxPuedeImprimirse =
    'Esta variable puede imprimirse o no, según como ejecute la simulación.';
  mesCFauxAntesDeSimRes3 =
    'Antes de ejecutar SimRes3 asegurese que el achivo de corrida seleccionado' +
    ' haya sido ejecutado con costo futuro auxiliar.';

type
  TAltaEdicionTVarIdxs = class(TBaseAltaEdicionIndices)
    lNombre: TLabel;
    eNombre: TEdit;
    lActor: TLabel;
    cbActor: TComboBox;
    cbVariable: TComboBox;
    lVariable: TLabel;
    bGuardar: TButton;
    bCancelar: TButton;
    BAyuda: TButton;
    LNumSimRes: TLabel;
    cbNumSimRes: TComboBox;
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure cbActorChange(Sender: TObject);
    procedure bCancelarClick(Sender: TObject);
    procedure cbVariableChange(Sender: TObject);
    procedure BGuardarClick(Sender: TObject); override;
    procedure BAyudaClick(Sender: TObject);
    procedure cambiosForm(Sender: TObject);
    procedure EditEnter(Sender: TObject);
    procedure EditNombreExit(Sender: TObject);
  private
    nombreEditado: boolean;
    actoresPorColumna, variablesPorColumna, actoresSinRepetir: TStringList;

    procedure inicializarActoresYVariablesPorColumna;
    //Genera un nombre para el índice a partir de la variable y el actor
    function nombreSugerido: string;
    //Si result es true variable sin poste vuelve con el nombre de la variable
    //sin el _P"nroPoste"
    function esVariablePorPoste(variable: string; var variableSinPoste: string): boolean;
  protected
    function validarFormulario: boolean; override;
  public
    constructor Create(AOwner: TComponent; sala: TSalaDeJuego;
      lector: TLectorSimRes3Defs; indice: TVarIdxs); override;
  end;

implementation

{$R *.lfm}

procedure TAltaEdicionTVarIdxs.BAyudaClick(Sender: TObject);
begin
  verdoc(self, TVarIdxs);
end;

procedure TAltaEdicionTVarIdxs.bCancelarClick(Sender: TObject);
begin
  inherited bCancelarClick(Sender);
end;

procedure TAltaEdicionTVarIdxs.BGuardarClick(Sender: TObject);
begin
  if validarFormulario then
  begin
    if indice = nil then
      indice := TVarIdxs.Create(eNombre.Text, cbActor.Items[cbActor.ItemIndex],
        cbVariable.Items[cbVariable.ItemIndex], cbNumSimRes.Items[cbNumSimRes.ItemIndex])
    else
    begin
      indice.nombreIndice := eNombre.Text;
      indice.nombreActor := cbActor.Items[cbActor.ItemIndex];
      indice.nombreVar := cbVariable.Items[cbVariable.ItemIndex];
      indice.numSimRes := cbNumSimRes.Items[cbNumSimRes.ItemIndex];
    end;
    ModalResult := mrOk;
  end;
end;

procedure TAltaEdicionTVarIdxs.cambiosForm(Sender: TObject);
begin
  inherited cambiosForm(Sender);
end;

procedure TAltaEdicionTVarIdxs.cbActorChange(Sender: TObject);
var
  nomActor: string;
  i: integer;
  variableSinPoste: string;
  nuevaPosOldSelectedVar: integer;
  oldSelectedVar: string;
  iActor: integer;
begin

  i := cbVariable.ItemIndex;
  if i >= 0 then
    oldSelectedVar := cbVariable.Items[i]
  else
    oldSelectedVar := '';

  iActor := cbActor.ItemIndex;
  if (iActor >= 0) then
  begin
    nomActor := cbActor.Items[iActor];
    i := 0;
    while (actoresPorColumna[i] <> nomActor) and (i < actoresPorColumna.Count) do
      i := i + 1;

    cbVariable.Items.Clear;
    while (i < actoresPorColumna.Count) and (actoresPorColumna[i] = nomActor) do
    begin
      if esVariablePorPoste(variablesPorColumna[i], variableSinPoste) and
        (cbVariable.Items.IndexOf(variableSinPoste) = -1) then
        cbVariable.Items.Add(variableSinPoste);
      cbVariable.Items.Add(variablesPorColumna[i]);
      i := i + 1;
    end;

    nuevaPosOldSelectedVar := cbVariable.Items.IndexOf(oldSelectedVar);
    if nuevaPosOldSelectedVar <> -1 then
      cbVariable.ItemIndex := nuevaPosOldSelectedVar
    else
      cbVariable.ItemIndex := 0;

    if Sender <> nil then //Sender == NIL = Inicialización
    begin
      cbVariableChange(nil);
      guardado := False;
    end;
  end
  else
    nomActor := '';

end;

procedure TAltaEdicionTVarIdxs.cbVariableChange(Sender: TObject);
begin
  if cbVariable.ItemIndex >= 0 then
  begin
    guardado := False;
    if cbVariable.Items[cbVariable.ItemIndex] = 'CFaux' then
      ShowMessage(mesSeleccionoVariableCFaux + #13#10 +
        mesVariableCFauxPuedeImprimirse + #13#10 +
        mesCFauxAntesDeSimRes3);

    if not nombreEditado then
    begin
      eNombre.Text := nombreSugerido;
    end;
  end;
end;

constructor TAltaEdicionTVarIdxs.Create(AOwner: TComponent; sala: TSalaDeJuego;
  lector: TLectorSimRes3Defs; indice: TVarIdxs);
var
  i, iActorIndice: integer;
begin
  inherited Create(AOwner, sala, lector, indice);

  inicializarActoresYVariablesPorColumna;
  for i := 0 to actoresSinRepetir.Count - 1 do
    cbActor.Items.Add(actoresSinRepetir[i]);

  cbVariable.Items.Add('-');
  cbVariable.ItemIndex := 0;

  cbNumSimRes.Items.Add('1');
  cbNumSimRes.Items.Add('*');
  cbNumSimRes.ItemIndex := 0;

  if indice <> nil then
  begin
    eNombre.Text := indice.nombreIndice;
    iActorIndice := cbActor.Items.IndexOf(indice.nombreActor);
    if iActorIndice <> -1 then
    begin
      cbActor.ItemIndex := iActorIndice;
      cbActorChange(nil);

      cbVariable.ItemIndex := cbVariable.Items.IndexOf(indice.nombreVar);
    end;
    cbNumSimRes.ItemIndex := cbNumSimRes.Items.IndexOf(indice.numSimRes);
  end;
  nombreEditado := eNombre.Text <> nombreSugerido;
end;

procedure TAltaEdicionTVarIdxs.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TAltaEdicionTVarIdxs.EditNombreExit(Sender: TObject);
begin
  inherited EditStringExit(Sender, True);
  nombreEditado := TEdit(Sender).Text <> nombreSugerido;
end;

procedure TAltaEdicionTVarIdxs.inicializarActoresYVariablesPorColumna;
var
  i: integer;
  aux: TextFile;
  archi, encabActores, encabVariables, actor, lastActor: string;
  var_str: string;

begin
  archi := getDir_Tmp + 'auxTformAltaEdicionTVarIdxs.txt';
  AssignFile(aux, archi);
  Rewrite(aux);
  //Nombres de los Actores
  for i := 0 to sala.nods.Count - 1 do
    (sala.nods[i] as TActor).sim_PrintResultados_Encab(aux, 0);
  for i := 0 to sala.dems.Count - 1 do
    (sala.dems[i] as TActor).sim_PrintResultados_Encab(aux, 0);
  for i := 0 to sala.gens.Count - 1 do
    (sala.gens[i] as TActor).sim_PrintResultados_Encab(aux, 0);
  for i := 0 to sala.arcs.Count - 1 do
    (sala.arcs[i] as TActor).sim_PrintResultados_Encab(aux, 0);
  for i := 0 to sala.comercioInternacional.Count - 1 do
    (sala.comercioInternacional[i] as TActor).sim_PrintResultados_Encab(aux, 0);
  for i := 0 to sala.UsosGestionables.Count - 1 do
    (sala.UsosGestionables[i] as TActor).sim_PrintResultados_Encab(aux, 0);
  for i := 0 to sala.sums.Count - 1 do
    (sala.sums[i] as TActor).sim_PrintResultados_Encab(aux, 0);
  for i := 0 to sala.listaFuentes_.Count - 1 do
    TFuenteAleatoria(sala.listaFuentes_[i]).sim_PrintResultados_Encab(aux, 0);
  writeln(aux, #9, '-', #9, '-', #9, '-', #9, '-');

  //Variables
  for i := 0 to sala.nods.Count - 1 do
    (sala.nods[i] as TActor).sim_PrintResultados_Encab(aux, 2);
  for i := 0 to sala.dems.Count - 1 do
    (sala.dems[i] as TActor).sim_PrintResultados_Encab(aux, 2);
  for i := 0 to sala.gens.Count - 1 do
    (sala.gens[i] as TActor).sim_PrintResultados_Encab(aux, 2);
  for i := 0 to sala.arcs.Count - 1 do
    (sala.arcs[i] as TActor).sim_PrintResultados_Encab(aux, 2);
  for i := 0 to sala.comercioInternacional.Count - 1 do
    (sala.comercioInternacional[i] as TActor).sim_PrintResultados_Encab(aux, 2);

  for i := 0 to sala.UsosGestionables.Count - 1 do
    (sala.UsosGestionables[i] as TActor).sim_PrintResultados_Encab(aux, 2);

  for i := 0 to sala.sums.Count - 1 do
    (sala.sums[i] as TActor).sim_PrintResultados_Encab(aux, 2);

  for i := 0 to sala.listaFuentes_.Count - 1 do
    TFuenteAleatoria(sala.listaFuentes_[i]).sim_PrintResultados_Encab(aux, 2);
  writeln(aux, #9, 'CF_AlInicioDelPaso', #9, 'CFaux', #9, 'CPDirecto',  #9, 'UPDirecta', #9, 'CPSimplex');
  CloseFile(aux);

  AssignFile(aux, archi);
  Reset(aux);
  Readln(aux, encabActores);
  Readln(aux, encabVariables);
  CloseFile(aux);
  DeleteFile(archi);

  lastActor := '';
  actoresPorColumna := TStringList.Create;
  actoresSinRepetir := TStringList.Create;

  variablesPorColumna := TStringList.Create;
  variablesPorColumna.Capacity := actoresPorColumna.Count;

  while encabActores <> '' do
  begin
    actor := NextStr(encabActores);
    actoresPorColumna.Add(actor);
    if lastActor <> actor then
    begin
      lastActor := actor;
      if actoresSinRepetir.IndexOf(actor) = -1 then
        actoresSinRepetir.Add(actor);
    end;
  end;
  while encabVariables <> '' do
  begin
    var_str:= NextStr(encabVariables);
    variablesPorColumna.Add( var_str );
  end;
end;

function TAltaEdicionTVarIdxs.nombreSugerido: string;
begin
  if (cbActor.ItemIndex >= 0) and (cbVariable.ItemIndex >= 0) then
  begin
    if cbActor.Items[cbActor.ItemIndex] <> '-' then
      Result := 'Idx_' + cbVariable.Items[cbVariable.ItemIndex] + '_' +
        cbActor.Items[cbActor.ItemIndex]
    else
      Result := 'Idx_' + cbVariable.Items[cbVariable.ItemIndex];
  end
  else
    Result := '';
end;

function TAltaEdicionTVarIdxs.esVariablePorPoste(variable: string;
  var variableSinPoste: string): boolean;
var
  i: integer;
  buscando: boolean;
  kposte, rescod: integer;
  pal: string;

begin
  variableSinPoste := '';
  i := Length(variable)-1;
  buscando := True;
  while (i > 2) and buscando do
  begin
    if (variable[i - 1] = '_') and (variable[i] = 'P') then
      buscando := False
    else
      dec( i );
  end;

  if buscando then
    result:= false
  else
  begin
    pal:= Copy(variable, i + 1, length(variable) - i);
    variableSinPoste := Copy(variable, 1, i - 2);
    val( pal, kposte, rescod );
    result := rescod = 0;
  end;
end;

function TAltaEdicionTVarIdxs.validarFormulario: boolean;
begin
  Result := validarNombreIndice(eNombre) and (cbActor.ItemIndex <> -1) and
    (cbVariable.ItemIndex <> -1) and (cbNumSimRes.ItemIndex <> -1);
end;

procedure TAltaEdicionTVarIdxs.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

initialization
end.
