unit uEditarFichaBiomasaEmbalsable;

interface

uses
  {$IFDEF WINDOWS}
   Windows,
   {$ELSE}
   LCLType,
   {$ENDIF}
 Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uBaseEditoresFichas, StdCtrls, ExtCtrls, Grids, uFichasLPD, uCosaConNombre,
  usalasdejuego, uBaseEditoresFichasGeneradores,
  uSalasDeJuegoParaEditor, uBiomasaEmbalsable, uGeneradores,
  uEditarCentralesEncadenadas, utilidades,
  uconstantesSimSEE, uFechas, xMatDefs, uverdoc, uOpcionesSimSEEEdit;

type

  { TEditarFichaBiomasaEmbalsable }

  TEditarFichaBiomasaEmbalsable = class(TBaseEditoresFichasGeneradores)
    ecvea_impuesto: TEdit;
    ePMax: TEdit;
    efd: TEdit;
    eTMR: TEdit;
    lbl_cvea_impuesto: TLabel;
    lblPMax: TLabel;
    LblFD: TLabel;
    lblTMR: TLabel;
    LFIni: TLabel;
    BGuardar: TButton;
    BCancelar: TButton;
    EFIni: TEdit;
    CBPeriodicidad: TCheckBox;
    PPeriodicidad: TPanel;
    LFinPeriodo: TLabel;
    LIniPeriodo: TLabel;
    LLargoPeriodo: TLabel;
    EFFinPeriodo: TEdit;
    EFIniPeriodo: TEdit;
    sgPeriodicidad: TStringGrid;
    ELargoPeriodo: TEdit;
    CBLargoPeriodo: TComboBox;
    BAyuda: TButton;
    sgPrecios: TStringGrid;
    procedure EditEnter(Sender: TObject);
    procedure CBPeriodicidadClick(Sender: TObject);
    procedure CambiosForm(Sender: TObject);
    procedure EditExit(Sender: TObject);
    procedure BCancelarClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure BGuardarClick(Sender: TObject); override;
    procedure BAyudaClick(Sender: TObject);
    procedure sgPreciosEditingDone(Sender: TObject);
  protected
    function validarFormulario: boolean; override;
  private
    Generador: TBiomasaEmbalsable;
  public
    constructor Create(AOwner: TComponent; cosaConNombre: TCosaConNombre;
      ficha: TFichaLPD; sala: TSalaDeJuego); override;
  end;

var
  EditarFichaBiomasaEmbalsable: TEditarFichaBiomasaEmbalsable;

implementation

uses SimSEEEditMain, uBaseAltasEditores;

  {$R *.lfm}

constructor TEditarFichaBiomasaEmbalsable.Create(AOwner: TComponent;
  cosaConNombre: TCosaConNombre; ficha: TFichaLPD; sala: TSalaDeJuego);
var
  fichaAux: TFichaBiomasaEmbalsable;
  i: integer;
begin
  inherited Create(AOwner, cosaConNombre, ficha, sala);
  Generador := cosaConNombre as TBiomasaEmbalsable;
  inherited llenarCamposPeriodicidad(CBLargoPeriodo, ELargoPeriodo,
    EFIniPeriodo, EFFinPeriodo, sgPeriodicidad, CBPeriodicidad, ficha, PPeriodicidad);

  sgPrecios.AutoEdit:= true;

  if (ficha <> nil) then
  begin
    fichaAux := ficha as TFichaBiomasaEmbalsable;
    self.EFIni.Text := FSimSEEEdit.fechaIniToString(fichaAux.fecha);
    self.ePMax.Text := FloatToStr(fichaAux.PMax);

    sgPrecios.Cells[1, 1]:= FloatToStr(fichaAux.PEC);
    sgPrecios.Cells[2, 1]:= FloatToStr(fichaAux.a_PEC);
    sgPrecios.Cells[3, 1]:= FloatToStr(fichaAux.b_PEC);
    sgPrecios.Cells[4, 1]:= FloatToStr(fichaAux.c_PEC);
    sgPrecios.Cells[5, 1]:= FloatToStr(fichaAux.d_PEC);

    sgPrecios.Cells[1, 2]:= FloatToStr(fichaAux.PEE);
    sgPrecios.Cells[2, 2]:= FloatToStr(fichaAux.a_PEE);
    sgPrecios.Cells[3, 2]:= FloatToStr(fichaAux.b_PEE);
    sgPrecios.Cells[4, 2]:= FloatToStr(fichaAux.c_PEE);
    sgPrecios.Cells[5, 2]:= FloatToStr(fichaAux.d_PEE);

    sgPrecios.Cells[1, 3]:=  FloatToStr(fichaAux.PEX);
    sgPrecios.Cells[2, 3]:= FloatToStr(fichaAux.a_PEX);
    sgPrecios.Cells[3, 3]:= FloatToStr(fichaAux.b_PEX);
    sgPrecios.Cells[4, 3]:= FloatToStr(fichaAux.c_PEX);
    sgPrecios.Cells[5, 3]:= FloatToStr(fichaAux.d_PEX);


    self.efd.Text := FloatToStr(fichaAux.fd);
    self.eTMR.Text := FloatToStr(fichaAux.TMR);
    self.ecvea_impuesto.Text:= FloatToStr( fichaAux.cvea_impuesto );
    guardado := True;
  end
  else
  begin
    self.EFIni.Text := '';
    self.ePMax.Text := '';

    sgPrecios.Cells[1, 1]:= FloatToStr( 0 );
    sgPrecios.Cells[2, 1]:= FloatToStr( 0 );
    sgPrecios.Cells[3, 1]:= FloatToStr( 0 );
    sgPrecios.Cells[4, 1]:= FloatToStr( 0 );
    sgPrecios.Cells[5, 1]:= FloatToStr( 0 );

    sgPrecios.Cells[1, 2]:= FloatToStr( 0 );
    sgPrecios.Cells[2, 2]:= FloatToStr( 0 );
    sgPrecios.Cells[3, 2]:= FloatToStr( 0 );
    sgPrecios.Cells[4, 2]:= FloatToStr( 0 );
    sgPrecios.Cells[5, 2]:= FloatToStr( 0 );

    sgPrecios.Cells[1, 3]:= FloatToStr( 0 );
    sgPrecios.Cells[2, 3]:= FloatToStr( 0 );
    sgPrecios.Cells[3, 3]:= FloatToStr( 0 );
    sgPrecios.Cells[4, 3]:= FloatToStr( 0 );
    sgPrecios.Cells[5, 3]:= FloatToStr( 0 );

    self.efd.Text := '';
    self.eTMR.Text := '';
    self.ecvea_impuesto.Text := '';
    guardado := false;
  end;
end;

function TEditarFichaBiomasaEmbalsable.validarFormulario(): boolean;
begin
  inherited validarFormulario;
  Result := inherited validarEditFecha(EFIni) and
    inherited validarPeriodicidad(CBPeriodicidad, CBLargoPeriodo,
    ELargoPeriodo, EFIniPeriodo, EFFinPeriodo,
    sgPeriodicidad) and validarEditFloat(
    ePMax) and validarTablaNReals_(sgPrecios) and validarEditFloat(
    efd) and validarEditFloat(eTMR) and validarEditFloat(ecvea_impuesto);
end;

procedure TEditarFichaBiomasaEmbalsable.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarFichaBiomasaEmbalsable.CBPeriodicidadClick(Sender: TObject);
begin
  inherited switchPanelPeriodicidad(CBPeriodicidad, PPeriodicidad);
end;

procedure TEditarFichaBiomasaEmbalsable.CambiosForm(Sender: TObject);
begin
  guardado := False;
end;

procedure TEditarFichaBiomasaEmbalsable.EditExit(Sender: TObject);
begin

end;



procedure TEditarFichaBiomasaEmbalsable.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarFichaBiomasaEmbalsable.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

procedure TEditarFichaBiomasaEmbalsable.FormCreate(Sender: TObject);
begin
  utilidades.AgregarFormatoFecha(LFIni);
end;


procedure TEditarFichaBiomasaEmbalsable.BGuardarClick(Sender: TObject);
var
  periodo: TPeriodicidad;
begin
  sgPreciosEditingDone( Sender );

  if validarFormulario then
  begin
    if not CBPeriodicidad.Checked then
      periodo := nil
    else
      periodo := inherited darPeriodicidad(CBLargoPeriodo, ELargoPeriodo,
        EFIniPeriodo, EFFinPeriodo, sgPeriodicidad);


    ficha := TFichaBiomasaEmbalsable.Create(
      capa, FSimSEEEdit.StringToFecha(EFIni.Text), periodo,
      StrToFloat(efd.Text), StrToFloat(eTMR.Text),
      StrToFloat(ePMax.Text),

      StrToFloat( sgPrecios.Cells[ 1, 1]), // PEC
      StrToFloat( sgPrecios.Cells[ 1, 2]), // PEE
      StrToFloat( sgPrecios.Cells[ 1, 3]), // PEX

      StrToFloat( ecvea_impuesto.Text ),

      StrToFloat( sgPrecios.Cells[ 2, 1]), // a_PEC
      StrToFloat( sgPrecios.Cells[ 3, 1]), // b_PEC
      StrToFloat( sgPrecios.Cells[ 4, 1]), // c_PEC
      StrToFloat( sgPrecios.Cells[ 5, 1]), // d_PEC

      StrToFloat( sgPrecios.Cells[ 2, 2]), // a_PEE
      StrToFloat( sgPrecios.Cells[ 3, 2]), // b_PEE
      StrToFloat( sgPrecios.Cells[ 4, 2]), // c_PEE
      StrToFloat( sgPrecios.Cells[ 5, 2]), // d_PEE

      StrToFloat( sgPrecios.Cells[ 2, 3]), // a_PEX
      StrToFloat( sgPrecios.Cells[ 3, 3]), // b_PEX
      StrToFloat( sgPrecios.Cells[ 4, 3]), // c_PEX
      StrToFloat( sgPrecios.Cells[ 5, 3])  // d_PEX

      );


    ModalResult := mrOk;
  end;
end;


procedure TEditarFichaBiomasaEmbalsable.BAyudaClick(Sender: TObject);
begin
  verdoc(self, TBiomasaEmbalsable);
end;

procedure TEditarFichaBiomasaEmbalsable.sgPreciosEditingDone(Sender: TObject);
var
  kFila, jCol: integer;
  residuo: NReal;
  flg_OK: boolean;
begin
try
  flg_OK:= true;
  for kFila:= 1 to 3 do
  begin
    residuo:= 1;
    for jCol:= 2 to 5 do
    begin
      residuo:= residuo - StrToFloat( sgPrecios.Cells[ jCol, kFila ] );
    end;
    sgPrecios.Cells[ 6, kFila ]:= FloatToStr( residuo );
    if ( residuo > (1+AsumaCero) ) or ( residuo < -AsumaCero) then
      flg_OK:= false;
  end;

  if not flg_OK then
    sgPrecios.Color:= clRed
  else
    sgPrecios.Color:= clWhite;

except
  sgPrecios.Color:= clRed
end;

end;

initialization
end.
