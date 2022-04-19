unit uEditarFichaForzamientos;


interface

uses
  {$IFDEF WINDOWS}
  Windows,
  {$ENDIF}
  Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, StdCtrls, uBaseEditoresFichas, uFechas, Grids, utilidades,
  ExtCtrls, Menus, uCosaConNombre, xMatDefs,
  uFichasLPD,
  uForzamientos,
  uActores, uverdoc;

type

  { TEditarFichaForzamientos }

  TEditarFichaForzamientos = class(TBaseEditoresFichas)
    cbActivarForzamiento: TCheckBox;
    ENMaquinas_t2: TEdit;
    ENMaquinas_t3: TEdit;
    ENMaquinas_t4: TEdit;
    LDesde: TLabel;
    BGuardar: TButton;
    BCancelar: TButton;
    CBPeriodicidad: TCheckBox;
    LNMaquinas_t2: TLabel;
    LNMaquinas_t3: TLabel;
    LNMaquinas_t4: TLabel;
    MainMenu1: TMainMenu;
    PPeriodicidad: TPanel;
    LFinPeriodo: TLabel;
    LIniPeriodo: TLabel;
    EFFinPeriodo: TEdit;
    EFIniPeriodo: TEdit;
    sgPeriodicidad: TStringGrid;
    LNMaquinas_t1: TLabel;
    ELargoPeriodo: TEdit;
    CBLargoPeriodo: TComboBox;
    LLargoPeriodo: TLabel;
    ENMaquinas_t1: TEdit;
    EFIni: TEdit;
    BAyuda: TButton;
    procedure BCancelarClick(Sender: TObject);
    procedure BGuardarClick(Sender: TObject); override;
    procedure EditEnter(Sender: TObject);
    procedure EditExit(Sender: TObject);
    procedure sgChequearCambios(Sender: TObject);
    procedure sgGetEditText(Sender: TObject; ACol, ARow: integer; var Value: string);
    procedure sgChequearCambiosKeyDown(Sender: TObject; var Key: word;
      Shift: TShiftState);
    procedure CBPeriodicidadClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure DTPChange(Sender: TObject);
    procedure cambiosForm(Sender: TObject);
    procedure BAyudaClick(Sender: TObject);
  protected
    function validarFormulario: boolean; override;
  public
    cuantasForzamientos: integer;

    constructor Create(AOwner: TComponent; cosaConNombre: TCosaConNombre;
      ficha: TFichaLPD; fechaIni: TFecha); reintroduce; overload;
    constructor Create(AOwner: TComponent; cosaConNombre: TCosaConNombre;
      ficha: TFichaLPD; fechaIni: TFecha; tiposForzamientos: TDAofString);
      reintroduce; overload;

  end;

var
  EditarFichaForzamientos: TEditarFichaForzamientos;

implementation

{$R *.lfm}

uses
  SimSEEEditMain;

constructor TEditarFichaForzamientos.Create(AOwner: TComponent;
  cosaConNombre: TCosaConNombre; ficha: TFichaLPD; fechaIni: TFecha);
begin
  inherited Create(AOwner, cosaConNombre, ficha, sala);
  cuantasForzamientos := 1;

  if cosaConNombre <> nil then
    self.Caption := 'Editar Forzamientos de ' + cosaConNombre.nombre;

  if fechaIni <> nil then
    self.EFIni.Text := FSimSEEEdit.fechaIniToString(fechaIni);

  inherited llenarCamposPeriodicidad(CBLargoPeriodo, ELargoPeriodo,
    EFIniPeriodo, EFFinPeriodo, sgPeriodicidad, CBPeriodicidad, ficha, PPeriodicidad);
  if ficha <> nil then
  begin
    self.EFIni.Text := FSimSEEEdit.fechaIniToString(ficha.fecha);
    ENMaquinas_t1.Text := FloatToStr(TFichaForzamientos(ficha).P[0]);
  end;
end;

constructor TEditarFichaForzamientos.Create(AOwner: TComponent;
  cosaConNombre: TCosaConNombre; ficha: TFichaLPD; fechaIni: TFecha;
  tiposForzamientos: TDAofString);
begin
  inherited Create(AOwner, cosaConNombre, ficha, sala);
  cuantasForzamientos := Length(tiposForzamientos);

  if cosaConNombre <> nil then
    self.Caption := 'Editar Forzamientos de ' + cosaConNombre.nombre;

  if fechaIni <> nil then
    self.EFIni.Text := FSimSEEEdit.fechaIniToString(fechaIni);

  inherited llenarCamposPeriodicidad(CBLargoPeriodo, ELargoPeriodo,
    EFIniPeriodo, EFFinPeriodo, sgPeriodicidad, CBPeriodicidad, ficha, PPeriodicidad);

  self.cbActivarForzamiento.Checked := False;


  if ficha <> nil then
  begin
    self.EFIni.Text := FSimSEEEdit.fechaIniToString(ficha.fecha);

    self.cbActivarForzamiento.Checked := TFichaForzamientos(ficha).activar_forzamiento;
    ENMaquinas_t1.Text := FloatToStr(TFichaForzamientos(ficha).P[0]);

    if cuantasForzamientos > 1 then
    begin
      ENMaquinas_t2.Text := FloatToStr(TFichaForzamientos(ficha).P[1]);
    end;

    if cuantasForzamientos > 2 then
    begin
      ENMaquinas_t3.Text := FloatToStr(TFichaForzamientos(ficha).P[2]);
    end;

    if cuantasForzamientos > 3 then
    begin
      ENMaquinas_t4.Text := FloatToStr(TFichaForzamientos(ficha).P[3]);
    end;
  end;

  //Tengo que mostrar tantos casilleros como nombres me pasan
  if cuantasForzamientos > 4 then
    raise Exception.Create(
      'No se pueden crear tipos de Forzamientos con mas de 4 tipos diferentes');

  if cuantasForzamientos > 0 then
  begin
    LNMaquinas_t1.Caption := tiposForzamientos[0];
  end;

  if cuantasForzamientos > 1 then
  begin
    LNMaquinas_t2.Caption := tiposForzamientos[1];
    LNMaquinas_t2.Visible := True;
    ENMaquinas_t2.Visible := True;
  end;

  if cuantasForzamientos > 2 then
  begin
    LNMaquinas_t3.Caption := tiposForzamientos[2];
    LNMaquinas_t3.Visible := True;
    ENMaquinas_t3.Visible := True;
  end;

  if cuantasForzamientos > 3 then
  begin
    LNMaquinas_t4.Caption := tiposForzamientos[3];
    LNMaquinas_t4.Visible := True;
    ENMaquinas_t4.Visible := True;
  end;
end;

function TEditarFichaForzamientos.validarFormulario: boolean;
begin
  Result := inherited validarEditFecha(EFIni) and
    inherited validarEditFloat(ENMaquinas_t1, -1e-20, 1e20) and
    inherited validarEditFloat(ENMaquinas_t2, -1e-20, 1e20) and
    inherited validarEditFloat(ENMaquinas_t3, -1e-20, 1e20) and
    inherited validarEditFloat(ENMaquinas_t4, -1e-20, 1e20) and
    inherited validarPeriodicidad(CBPeriodicidad, CBLargoPeriodo,
    ELargoPeriodo, EFIniPeriodo, EFFinPeriodo, sgPeriodicidad);
end;

procedure TEditarFichaForzamientos.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarFichaForzamientos.BGuardarClick(Sender: TObject);
var
  periodicidad: TPeriodicidad;
  cantMaquinas: string;
begin
  if validarFormulario then
  begin
    if CBPeriodicidad.Checked then
      periodicidad := inherited darPeriodicidad(CBLargoPeriodo,
        ELargoPeriodo, EFIniPeriodo, EFFinPeriodo, sgPeriodicidad)
    else
      periodicidad := nil;

    //Tengo que recorrer todos los edit validos
    cantMaquinas := ENMaquinas_t1.Text;
    if cuantasForzamientos > 1 then
    begin
      cantMaquinas := cantMaquinas + ';' + ENMaquinas_t2.Text;
    end;

    if cuantasForzamientos > 2 then
    begin
      cantMaquinas := cantMaquinas + ';' + ENMaquinas_t3.Text;
    end;

    if cuantasForzamientos > 3 then
    begin
      cantMaquinas := cantMaquinas + ';' + ENMaquinas_t4.Text;
    end;


    ficha := TFichaForzamientos.Create(capa, FSimSEEEdit.StringToFecha(EFIni.Text),
      periodicidad, cbActivarForzamiento.Checked, StrToDAOfNReal_(cantMaquinas, ';'));

    ModalResult := mrOk;
  end;
end;

procedure TEditarFichaForzamientos.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarFichaForzamientos.EditExit(Sender: TObject);
begin
  inherited EditExit(Sender);
end;

procedure TEditarFichaForzamientos.sgChequearCambios(Sender: TObject);
begin
  inherited sgChequearCambios(TStringGrid(Sender));
end;

procedure TEditarFichaForzamientos.sgGetEditText(Sender: TObject;
  ACol, ARow: integer; var Value: string);
begin
  inherited sgGetEditText(Sender, ACol, ARow, Value);
end;

procedure TEditarFichaForzamientos.sgChequearCambiosKeyDown(Sender: TObject;
  var Key: word; Shift: TShiftState);
begin
  inherited sgChequearCambiosKeyDown(Sender, Key, Shift);
end;

procedure TEditarFichaForzamientos.CBPeriodicidadClick(Sender: TObject);
begin
  inherited switchPanelPeriodicidad(CBPeriodicidad, PPeriodicidad);
end;

procedure TEditarFichaForzamientos.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;


procedure TEditarFichaForzamientos.DTPChange(Sender: TObject);
begin
  inherited DTPChange(Sender);
end;

procedure TEditarFichaForzamientos.cambiosForm(Sender: TObject);
begin
  inherited cambiosForm(Sender);
end;

procedure TEditarFichaForzamientos.BAyudaClick(Sender: TObject);
begin
  verdoc(self, TFichaForzamientos);
end;

end.