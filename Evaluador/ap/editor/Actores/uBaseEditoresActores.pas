unit uBaseEditoresActores;

{$DEFINE ESCONDER_CAPA_EN_ACTORES}

interface

uses
  {$IFDEF WINDOWS}
  Windows,
  {$ENDIF}
  SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, StdCtrls, ExtCtrls,
  xMatDefs,
  utilidades,
  uConstantesSimSEE,
  uBaseEditoresCosasConNombre,
  uBaseFormularios,
  ufichasLPD,
  uEditarUnidades,
  uEditarForzamientos,
  usalasdejuego,
  uCosaConNombre,
  uActores,
  usalasdejuegoParaEditor;

resourcestring
  rsEscalon = 'Escalón';
  rsProfundidadPU = 'Profundidad[p.u.]';
  rsCostoUSDMWh = 'Costo[USD/MWh]';
  mesProfundidadDeEscalonesEnInterv =
    'Las profundidades de los escalones deben estar en el intervalo (0, 1]';
  mesSumaDeProfundidadDeEscalones =
    'La suma de las profundidades de los escalones debe ser 1';
  mesValoresEnTablaNumericos =
    'Los valores introducidos en la tabla deben ser numéricos';

type
  TProcCambioTAmTablaFalla = procedure of object;

  { TBaseEditoresActores }

  TBaseEditoresActores = class(TBaseEditoresCosasConNombre)
    procedure FormResize(Sender: TObject);

  protected
    lpdUnidades: TFichasLPD;
    etiquetasUnidades: TDAofString;

    lpdForzamientos_: TFichasLPD;
    etiquetasForzamientos: TDAofString;

(* estos procedimientos de edición de los escalones y profunidades de falla
es confuso que estén a este nivel tan genéricos.
Debieran estar como utilidades de los editores de Deamandas *)
    procedure BEditorDeUnidadesClick(Sender: TObject);
    procedure BEditorDeForzamientosClick(Sender: TObject);

    procedure EditTamTablaFallaExit(Sender: TObject; sgFalla: TStringGrid;
      procCambioTamTablaFalla: TProcCambioTAmTablaFalla);
    procedure setTablaFalla(sgFalla: TStringGrid; editNEscalones: TEdit;
      profundidad, costo: TDAOfNReal; procCambioTamTablaFalla: TProcCambioTAmTablaFalla);
    function validarTablaFalla(sgFalla: TStringGrid): boolean;
    function getFallaProfundidad(sgFalla: TStringGrid): TDAofNReal;
    function getFallaCosto(sgFalla: TStringGrid): TDAofNReal;


  private
    { Private declarations }

  public
    constructor Create(AOwner: TComponent; sala: TSalaDeJuego;
      tipoCosa: TClass; cosaConNombre: TCosaConNombre);
      overload; override;
    constructor Create(AOwner: TComponent; sala: TSalaDeJuego;
      tipoCosa: TClass; cosaConNombre: TCosaConNombre;
      etiquetasUnidades, etiquetasForzamientos: TDAofString); reintroduce; overload; virtual;
    procedure Free;
  end;

implementation
{$R *.lfm}

constructor TBaseEditoresActores.Create(AOwner: TComponent;
  sala: TSalaDeJuego; tipoCosa: TClass;
  cosaConNombre: TCosaConNombre);
begin
  inherited Create(AOwner, sala, tipoCosa, cosaConNombre);


{$IFDEF ESCONDER_CAPA_EN_ACTORES}
  self.lbo_capa.Visible:=false;
  self.e_Capa.Visible:= false;
{$ENDIF}

  self.etiquetasUnidades := nil;
  self.etiquetasForzamientos:= nil;

  if cosaConNombre <> nil then
  begin
    lpdUnidades:= rbtEditorSala.Clonar_Y_ResolverReferencias(
      TActor(cosaConNombre).lpdUnidades) as TFichasLPD;
    lpdForzamientos_:= rbtEditorSala.Clonar_Y_ResolverReferencias(
      TActor(cosaConNombre).lpdForzamientos) as TFichasLPD;
  end
  else
  begin
    lpdUnidades:= TActor.CreateDefaultLPDUnidades_(1);
    lpdForzamientos_:= TActor.CreateDefaultLPDForzamientos_( 1)
  end;
end;

constructor TBaseEditoresActores.Create(AOwner: TComponent;
  sala: TSalaDeJuego; tipoCosa: TClass;
  cosaConNombre: TCosaConNombre;
  etiquetasUnidades, etiquetasForzamientos: TDAofString);
begin
  inherited Create(AOwner, sala, tipoCosa, cosaConNombre);
  self.etiquetasUnidades := etiquetasUnidades;
  self.etiquetasForzamientos:= etiquetasForzamientos;



  {$IFDEF ESCONDER_CAPA_EN_ACTORES}
    self.lbo_capa.Visible:=false;
    self.e_Capa.Visible:= false;
  {$ENDIF}


  if cosaConNombre <> nil then
  begin
    lpdUnidades:= rbtEditorSala.Clonar_Y_ResolverReferencias(
      TActor(cosaConNombre).lpdUnidades) as TFichasLPD;
    lpdForzamientos_ := rbtEditorSala.Clonar_Y_ResolverReferencias(
      TActor(cosaConNombre).lpdForzamientos) as TFichasLPD;
  end
  else
  begin
    lpdUnidades:= TActor.CreateDefaultLPDUnidades_(Length(etiquetasUnidades));
    lpdForzamientos_ := TActor.CreateDefaultLPDForzamientos_(Length(etiquetasForzamientos));
  end;
end;

procedure TBaseEditoresActores.FormResize(Sender: TObject);
begin
  // nada, pero no borrar porque hay descendientes que
  // tienen linkeado este método
end;

procedure TBaseEditoresActores.BEditorDeUnidadesClick(Sender: TObject);
var
  form: TEditarUnidades;
begin
  form := TEditarUnidades.Create(self, sala, TActor(cosaConNombre),
    lpdUnidades, etiquetasUnidades);
  form.ShowModal;
  if form.ModalResult = mrOk then
  begin
    self.lpdUnidades.Free;
    self.lpdUnidades := form.darLista_;
    guardado := False;
  end;
  form.Free;
end;

procedure TBaseEditoresActores.BEditorDeForzamientosClick(Sender: TObject);
var
  form: TEditarForzamientos;
begin
  form := TEditarForzamientos.Create(self, sala, TActor(cosaConNombre),
    lpdForzamientos_, etiquetasForzamientos);
  form.ShowModal;
  if form.ModalResult = mrOk then
  begin
    self.lpdForzamientos_.Free;
    self.lpdForzamientos_ := form.darLista;
    guardado := False;
  end;
  form.Free;
end;


procedure TBaseEditoresActores.EditTamTablaFallaExit(Sender: TObject;
  sgFalla: TStringGrid; procCambioTamTablaFalla: TProcCambioTAmTablaFalla);
var
  nAnt, i: integer;
begin
  if validarEditInt(TEdit(Sender), 1, MAXINT) then
  begin
    nAnt := sgFalla.ColCount;
    sgFalla.ColCount := StrToInt(TEdit(Sender).Text) + 1;
    for i := nAnt to sgFalla.ColCount - 1 do
    begin
      sgFalla.Cells[i, 0] := IntToStr(i);
      sgFalla.Cells[i, 1] := '0';
      sgFalla.Cells[i, 2] := '0';
    end;
    if Assigned(procCambioTamTablaFalla) then
      procCambioTamTablaFalla;
  end;
end;

procedure TBaseEditoresActores.setTablaFalla(sgFalla: TStringGrid;
  editNEscalones: TEdit; profundidad, costo: TDAOfNReal;
  procCambioTamTablaFalla: TProcCambioTAmTablaFalla);
var
  i: integer;
begin
  editNEscalones.Text := IntToStr(Length(profundidad));
  sgFalla.ColCount := Length(profundidad) + 1;

  sgFalla.Cells[0, 0] := rsEscalon;
  sgFalla.Cells[0, 1] := rsProfundidadPU;
  sgFalla.Cells[0, 2] := rsCostoUSDMWh;

  for i := 0 to high(profundidad) do
  begin
    sgFalla.Cells[i + 1, 1] := FloatToStrF(profundidad[i], ffGeneral,
      CF_PRECISION, CF_DECIMALESPU);
    sgFalla.Cells[i + 1, 2] := FloatToStrF(costo[i], ffGeneral, CF_PRECISION,
      CF_DECIMALES);
  end;

  utilidades.AutoSizeCol(sgFalla, 0);
  if Assigned(procCambioTamTablaFalla) then
    procCambioTamTablaFalla;
end;

function TBaseEditoresActores.validarTablaFalla(sgFalla: TStringGrid): boolean;
var
  iColumna: integer;
  sum, profundidad: NReal;
  errorProfundidad: boolean;
begin
  try
    begin
      for iColumna := sgFalla.FixedCols to sgFalla.ColCount - 1 do
        StrToFloat(sgFalla.cells[iColumna, 2]);
      sum := 0;
      errorProfundidad := False;
      for iColumna := sgFalla.FixedCols to sgFalla.ColCount - 1 do
      begin
        profundidad := StrToFloat(sgFalla.cells[iColumna, 1]);
        if (profundidad <= 0) or (profundidad > 1) then
        begin
          errorProfundidad := True;
          break;
        end;
        sum := sum + profundidad;
      end;
      if errorProfundidad then
      begin
        ShowMessage(mesProfundidadDeEscalonesEnInterv);
        Result := False;
      end
      else if (sum < 1 + AsumaCero) and (sum > 1 - AsumaCero) then
        Result := True
      else
      begin
        ShowMessage(mesSumaDeProfundidadDeEscalones);
        Result := False;
      end;
    end
  except
    on EConvertError do
    begin
      ShowMessage(mesValoresEnTablaNumericos);
      Result := False;
    end
  end;
end;

function TBaseEditoresActores.getFallaProfundidad(sgFalla: TStringGrid): TDAofNReal;
var
  res: TDAofNReal;
  i: integer;
begin
  SetLength(res, sgFalla.ColCount - 1);
  for i := 1 to sgFalla.ColCount - 1 do
    res[i - 1] := StrToFloat(sgFalla.Cells[i, 1]);
  Result := res;
end;

function TBaseEditoresActores.getFallaCosto(sgFalla: TStringGrid): TDAofNReal;
var
  res: TDAofNReal;
  i: integer;
begin
  SetLength(res, sgFalla.ColCount - 1);
  for i := 1 to sgFalla.ColCount - 1 do
    res[i - 1] := StrToFloat(sgFalla.Cells[i, 2]);
  Result := res;
end;

procedure TBaseEditoresActores.Free;
begin
  if ModalResult <> mrOk then
  begin
    lpdUnidades.Free;
    lpdForzamientos_.Free;
  end;
  inherited Free;
end;

end.
