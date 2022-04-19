unit uEditarFichaUnidades;
{$MODE Delphi}

interface

uses
  {$IFDEF WINDOWS}
//  Windows,
  {$ENDIF}
  Math,
  //Messages,
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  //ComCtrls,
  StdCtrls, uBaseEditoresFichas, uFechas, Grids, utilidades,
  ExtCtrls, Menus, uCosaConNombre, xMatDefs, uFichasLPD, uActores, uunidades, uverdoc;

type

  { TEditarFichaUnidades }

  TEditarFichaUnidades = class(TBaseEditoresFichas)
    cb_AltaConIncertidumbre1: TCheckBox;
    cb_AltaConIncertidumbre2: TCheckBox;
    cb_AltaConIncertidumbre3: TCheckBox;
    cb_AltaConIncertidumbre0: TCheckBox;
    cb_InicioCronicaConIncertidumbre1: TCheckBox;
    cb_InicioCronicaConIncertidumbre2: TCheckBox;
    cb_InicioCronicaConIncertidumbre3: TCheckBox;
    cb_InicioCronicaConIncertidumbre0: TCheckBox;
    ENMaquinas_I1: TEdit;
    ENMaquinas_I2: TEdit;
    ENMaquinas_I3: TEdit;
    ENMaquinas_EMP0: TEdit;
    ENMaquinas_EMP1: TEdit;
    ENMaquinas_EMP2: TEdit;
    ENMaquinas_EMP3: TEdit;
    LDesde: TLabel;
    BGuardar: TButton;
    BCancelar: TButton;
    CBPeriodicidad: TCheckBox;
    LNMaquinas_t2: TLabel;
    LNMaquinas_t3: TLabel;
    LNMaquinas_t4: TLabel;
    LNMaquinas_t5: TLabel;
    LNMaquinas_t6: TLabel;
    LNMaquinas_t7: TLabel;
    LNMaquinas_t8: TLabel;
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
    ENMaquinas_I0: TEdit;
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
    nTiposDeUnidades: integer;

    constructor Create(AOwner: TComponent; cosaConNombre: TCosaConNombre;
      ficha: TFichaLPD; fechaIni: TFecha); reintroduce; overload;
    constructor Create(AOwner: TComponent; cosaConNombre: TCosaConNombre;
      ficha: TFichaLPD; fechaIni: TFecha; tiposUnidades: TDAofString);
      reintroduce; overload;

  end;

var
  EditarFichaUnidades: TEditarFichaUnidades;

implementation
{$R *.lfm}
uses
  SimSEEEditMain;

constructor TEditarFichaUnidades.Create(AOwner: TComponent;
  cosaConNombre: TCosaConNombre; ficha: TFichaLPD; fechaIni: TFecha);
begin
  inherited Create(AOwner, cosaConNombre, ficha, sala);
  nTiposDeUnidades := 1;

  if cosaConNombre <> nil then
    self.Caption := 'Editar unidades de ' + cosaConNombre.nombre;

  if fechaIni <> nil then
    self.EFIni.Text := FSimSEEEdit.fechaIniToString(fechaIni);

  inherited llenarCamposPeriodicidad(CBLargoPeriodo, ELargoPeriodo,
    EFIniPeriodo, EFFinPeriodo, sgPeriodicidad, CBPeriodicidad, ficha, PPeriodicidad);

  if ficha <> nil then
  begin
    self.EFIni.Text := FSimSEEEdit.fechaIniToString(ficha.fecha);

    nTiposDeUnidades := length( TFichaUnidades(ficha).nUnidades_Instaladas ) ;

    ENMaquinas_I0.Text := IntToStr(TFichaUnidades(ficha).nUnidades_Instaladas[0]);
    ENMaquinas_EMP0.Text := IntToStr(TFichaUnidades(ficha).nUnidades_EnMantenimiento[0]);
    cb_AltaConIncertidumbre0.Checked:= TFichaUnidades(ficha).AltaConIncertidumbre[0];
    cb_InicioCronicaConIncertidumbre0.Checked:= TFichaUnidades(ficha).InicioCronicaConIncertidumbre[0];

    if nTiposDeUnidades > 1 then
    begin
      ENMaquinas_I1.Text := IntToStr(TFichaUnidades(ficha).nUnidades_Instaladas[1]);
      ENMaquinas_EMP1.Text := IntToStr(TFichaUnidades(ficha).nUnidades_EnMantenimiento[1]);
      cb_AltaConIncertidumbre1.Checked:= TFichaUnidades(ficha).AltaConIncertidumbre[1];
      cb_InicioCronicaConIncertidumbre1.Checked:= TFichaUnidades(ficha).InicioCronicaConIncertidumbre[1];
    end;
    if nTiposDeUnidades > 2 then
    begin
      ENMaquinas_I2.Text := IntToStr(TFichaUnidades(ficha).nUnidades_Instaladas[2]);
      ENMaquinas_EMP2.Text := IntToStr(TFichaUnidades(ficha).nUnidades_EnMantenimiento[2]);
      cb_AltaConIncertidumbre2.Checked:= TFichaUnidades(ficha).AltaConIncertidumbre[2];
      cb_InicioCronicaConIncertidumbre2.Checked:= TFichaUnidades(ficha).InicioCronicaConIncertidumbre[2];
    end;
    if nTiposDeUnidades > 3 then
    begin
      ENMaquinas_I3.Text := IntToStr(TFichaUnidades(ficha).nUnidades_Instaladas[3]);
      ENMaquinas_EMP3.Text := IntToStr(TFichaUnidades(ficha).nUnidades_EnMantenimiento[3]);
      cb_AltaConIncertidumbre3.Checked:= TFichaUnidades(ficha).AltaConIncertidumbre[3];
      cb_InicioCronicaConIncertidumbre3.Checked:= TFichaUnidades(ficha).InicioCronicaConIncertidumbre[3];
    end;
  end;
end;

constructor TEditarFichaUnidades.Create(AOwner: TComponent;
  cosaConNombre: TCosaConNombre; ficha: TFichaLPD; fechaIni: TFecha;
  tiposUnidades: TDAofString);
begin
  inherited Create(AOwner, cosaConNombre, ficha, sala);
  nTiposDeUnidades := max( 1, Length(tiposUnidades) );

  if cosaConNombre <> nil then
    self.Caption := 'Editar unidades de ' + cosaConNombre.nombre;

  if fechaIni <> nil then
    self.EFIni.Text := FSimSEEEdit.fechaIniToString(fechaIni);

  inherited llenarCamposPeriodicidad(CBLargoPeriodo, ELargoPeriodo,
    EFIniPeriodo, EFFinPeriodo, sgPeriodicidad, CBPeriodicidad, ficha, PPeriodicidad);

  if ficha <> nil then
  begin
    self.EFIni.Text := FSimSEEEdit.fechaIniToString(ficha.fecha);
    ENMaquinas_I0.Text := IntToStr(TFichaUnidades(ficha).nUnidades_Instaladas[0]);
    ENMaquinas_EMP0.Text := IntToStr(TFichaUnidades(ficha).nUnidades_EnMantenimiento[0]);
    cb_AltaConIncertidumbre0.Checked:= TFichaUnidades(ficha).AltaConIncertidumbre[0];
    cb_InicioCronicaConIncertidumbre0.Checked:= TFichaUnidades(ficha).InicioCronicaConIncertidumbre[0];
    if nTiposDeUnidades > 1 then
    begin
      ENMaquinas_I1.Text := IntToStr(TFichaUnidades(ficha).nUnidades_Instaladas[1]);
      ENMaquinas_EMP1.Text := IntToStr(TFichaUnidades(ficha).nUnidades_EnMantenimiento[1]);
      cb_AltaConIncertidumbre1.Checked:= TFichaUnidades(ficha).AltaConIncertidumbre[1];
      cb_InicioCronicaConIncertidumbre1.Checked:= TFichaUnidades(ficha).InicioCronicaConIncertidumbre[1];
    end;

    if nTiposDeUnidades > 2 then
    begin
      ENMaquinas_I2.Text := IntToStr(TFichaUnidades(ficha).nUnidades_Instaladas[2]);
      ENMaquinas_EMP2.Text := IntToStr(TFichaUnidades(ficha).nUnidades_EnMantenimiento[2]);
      cb_AltaConIncertidumbre2.Checked:= TFichaUnidades(ficha).AltaConIncertidumbre[2];
      cb_InicioCronicaConIncertidumbre2.Checked:= TFichaUnidades(ficha).InicioCronicaConIncertidumbre[2];
    end;

    if nTiposDeUnidades > 3 then
    begin
      ENMaquinas_I3.Text := IntToStr(TFichaUnidades(ficha).nUnidades_Instaladas[3]);
      ENMaquinas_EMP3.Text := IntToStr(TFichaUnidades(ficha).nUnidades_EnMantenimiento[3]);
      cb_AltaConIncertidumbre3.Checked:= TFichaUnidades(ficha).AltaConIncertidumbre[3];
      cb_InicioCronicaConIncertidumbre3.Checked:= TFichaUnidades(ficha).InicioCronicaConIncertidumbre[3];
    end;
  end;

  //Tengo que mostrar tantos casilleros como nombres me pasan
  if nTiposDeUnidades > 4 then
    raise Exception.Create(
      'No se pueden crear tipos de unidades con mas de 4 tipos diferentes');

  if Length(tiposUnidades) > 0 then
  begin
    LNMaquinas_t1.Caption := tiposUnidades[0];
  end;

  if nTiposDeUnidades > 1 then
  begin
    LNMaquinas_t2.Caption := tiposUnidades[1];
    LNMaquinas_t2.Visible := True;
    ENMaquinas_I1.Visible := True;
    cb_AltaConIncertidumbre1.Visible:= True;
    cb_InicioCronicaConIncertidumbre1.Visible:= True;
  end;

  if nTiposDeUnidades > 2 then
  begin
    LNMaquinas_t3.Caption := tiposUnidades[2];
    LNMaquinas_t3.Visible := True;
    ENMaquinas_I2.Visible := True;
    cb_AltaConIncertidumbre2.Visible:= True;
    cb_InicioCronicaConIncertidumbre2.Visible:= True;
  end;

  if nTiposDeUnidades > 3 then
  begin
    LNMaquinas_t4.Caption := tiposUnidades[3];
    LNMaquinas_t4.Visible := True;
    ENMaquinas_I3.Visible := True;
    cb_AltaConIncertidumbre3.Visible:= True;
    cb_InicioCronicaConIncertidumbre3.Visible:= True;
  end;
end;


function chequear_EMPMenorInst( eInst, eEMP: TEdit ): boolean;
begin
  if not ( eInst.Visible and eEMP.Visible ) then
  begin
    result:= true;
    exit;
  end;

  if  ( StrToInt( eEMP.text )  <= StrToInt( eInst.text ) ) then
      result:= true
  else
  begin
    eEMP.SetFocus;
    ShowMessage( 'ERROR!: La cantidad de unidades en mantenimiento programado no puede superar a la cantidad de unidades instalada.' );
    result:= false;
  end;
end;

function TEditarFichaUnidades.validarFormulario: boolean;
var
  res: boolean;
begin
  Res := inherited validarEditFecha(EFIni) and
    inherited validarEditInt(ENMaquinas_I0, 0, MAXINT) and
    inherited validarEditInt(ENMaquinas_I1, 0, MAXINT) and
    inherited validarEditInt(ENMaquinas_I2, 0, MAXINT) and
    inherited validarEditInt(ENMaquinas_I3, 0, MAXINT) and
    inherited validarEditInt(ENMaquinas_EMP0, 0, MAXINT) and
    inherited validarEditInt(ENMaquinas_EMP1, 0, MAXINT) and
    inherited validarEditInt(ENMaquinas_EMP2, 0, MAXINT) and
    inherited validarEditInt(ENMaquinas_EMP3, 0, MAXINT) and
    inherited validarPeriodicidad(CBPeriodicidad, CBLargoPeriodo,
    ELargoPeriodo, EFIniPeriodo, EFFinPeriodo, sgPeriodicidad);

  if res then
  begin
    res:= res and chequear_EMPMenorInst( ENMaquinas_I0, ENMaquinas_EMP0 );
    res:= res and chequear_EMPMenorInst( ENMaquinas_I1, ENMaquinas_EMP1 );
    res:= res and chequear_EMPMenorInst( ENMaquinas_I2, ENMaquinas_EMP2 );
    res:= res and chequear_EMPMenorInst( ENMaquinas_I3, ENMaquinas_EMP3 );
  end;
  result:= res;

end;

procedure TEditarFichaUnidades.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarFichaUnidades.BGuardarClick(Sender: TObject);
var
  periodicidad: TPeriodicidad;
  cantMaquinas_Instaladas: string;
  cantMaquinas_EnMantenimiento: string;
  AltaConIncertidumbre, InicioCronicaConIncertidumbre: TDAOfBoolean;
begin
  if validarFormulario then
  begin
    if CBPeriodicidad.Checked then
      periodicidad := inherited darPeriodicidad(CBLargoPeriodo,
        ELargoPeriodo, EFIniPeriodo, EFFinPeriodo, sgPeriodicidad)
    else
      periodicidad := nil;

    setlength( AltaConIncertidumbre, nTiposDeUnidades );
    setlength( InicioCronicaConIncertidumbre, nTiposDeUnidades );

    //Tengo que recorrer todos los edit validos
    cantMaquinas_Instaladas := ENMaquinas_I0.Text;
    cantMaquinas_EnMantenimiento := ENMaquinas_EMP0.Text;
    AltaConIncertidumbre[0]:= cb_AltaConIncertidumbre0.Checked;
    InicioCronicaConIncertidumbre[0]:= cb_InicioCronicaConIncertidumbre0.Checked;

    if nTiposDeUnidades > 1 then
    begin
      cantMaquinas_Instaladas := cantMaquinas_Instaladas + ';' + ENMaquinas_I1.Text;
      cantMaquinas_EnMantenimiento := cantMaquinas_EnMantenimiento + ';' + ENMaquinas_EMP1.Text;
      AltaConIncertidumbre[1]:= cb_AltaConIncertidumbre1.Checked;
      InicioCronicaConIncertidumbre[1]:= cb_InicioCronicaConIncertidumbre1.Checked;
    end;

    if nTiposDeUnidades > 2 then
    begin
      cantMaquinas_Instaladas := cantMaquinas_Instaladas + ';' + ENMaquinas_I2.Text;
      cantMaquinas_EnMantenimiento := cantMaquinas_EnMantenimiento + ';' + ENMaquinas_EMP2.Text;
      AltaConIncertidumbre[2]:= cb_AltaConIncertidumbre2.Checked;
      InicioCronicaConIncertidumbre[2]:= cb_InicioCronicaConIncertidumbre2.Checked;
    end;

    if nTiposDeUnidades > 3 then
    begin
      cantMaquinas_Instaladas := cantMaquinas_Instaladas + ';' + ENMaquinas_I3.Text;
      cantMaquinas_EnMantenimiento := cantMaquinas_EnMantenimiento + ';' + ENMaquinas_EMP3.Text;
      AltaConIncertidumbre[3]:= cb_AltaConIncertidumbre3.Checked;
      InicioCronicaConIncertidumbre[3]:= cb_InicioCronicaConIncertidumbre3.Checked;
    end;


    ficha := TFichaUnidades.Create(capa, FSimSEEEdit.StringToFecha(EFIni.Text),
      periodicidad,
      StrToDAOfNInt(cantMaquinas_Instaladas, ';'),
      StrToDAOfNInt(cantMaquinas_EnMantenimiento, ';'),
      AltaConIncertidumbre, InicioCronicaConIncertidumbre );

    ModalResult := mrOk;
  end;
end;

procedure TEditarFichaUnidades.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarFichaUnidades.EditExit(Sender: TObject);
begin
  inherited EditExit(Sender);
end;

procedure TEditarFichaUnidades.sgChequearCambios(Sender: TObject);
begin
  inherited sgChequearCambios(TStringGrid(Sender));
end;

procedure TEditarFichaUnidades.sgGetEditText(Sender: TObject;
  ACol, ARow: integer; var Value: string);
begin
  inherited sgGetEditText(Sender, ACol, ARow, Value);
end;

procedure TEditarFichaUnidades.sgChequearCambiosKeyDown(Sender: TObject;
  var Key: word; Shift: TShiftState);
begin
  inherited sgChequearCambiosKeyDown(Sender, Key, Shift);
end;

procedure TEditarFichaUnidades.CBPeriodicidadClick(Sender: TObject);
begin
  inherited switchPanelPeriodicidad(CBPeriodicidad, PPeriodicidad);
end;

procedure TEditarFichaUnidades.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;


procedure TEditarFichaUnidades.DTPChange(Sender: TObject);
begin
  inherited DTPChange(Sender);
end;

procedure TEditarFichaUnidades.cambiosForm(Sender: TObject);
begin
  inherited cambiosForm(Sender);
end;

procedure TEditarFichaUnidades.BAyudaClick(Sender: TObject);
begin
  verdoc(self, TFichaUnidades);
end;

end.
