unit uEditarCentralCoeficiente;


interface

uses
  {$IFDEF WINDOWS}
   Windows,
   {$ELSE}
   LCLType,
   {$ENDIF}
Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uGeneradores, uSalasDeJuego, xMatDefs, uCosaConNombre, StdCtrls,
  uBaseFormularios, utilidades, uconstantesSimSEE, uBaseAltasEditores;

resourcestring
  mesSeleccionarCentralDeLista = 'Debe seleccionar una central de la lista';
  mesNoSeEncuentraActor = 'No se encuentra el actor';

type

  { TEditarCentralCoeficiente }

  TEditarCentralCoeficiente = class(TBaseFormularios)
    cbCentrales: TComboBox;
    LCentral: TLabel;
    LCoeficiente: TLabel;
    ECoef: TEdit;
    BGuardar: TButton;
    BCancelar: TButton;
    procedure BCancelarClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure BGuardarClick(Sender: TObject); override;
    procedure EditEnter(Sender: TObject);
    procedure EditExit(Sender: TObject);
    procedure cambiosForm(Sender: TObject);
  protected
    function validarFormulario: boolean; override;
  private
    central: TGeneradorHidraulico;
    disponibles: TListaDeCosasConNombre;
    coeficiente: NReal;
  public
    constructor Create(AOwner: TForm; central: TGeneradorHidraulico;
      coeficiente: NReal; xsala: TSalaDeJuego; centralesDisponibles: TListaDeCosasConNombre); reintroduce;
    function darCentral: TGeneradorHidraulico;
    function darCoeficiente: NReal;
  end;

var
  EditarCentralCoeficiente: TEditarCentralCoeficiente;

implementation

  {$R *.lfm}

constructor TEditarCentralCoeficiente.Create(AOwner: TForm;
  central: TGeneradorHidraulico; coeficiente: NReal; xsala: TSalaDeJuego;
  centralesDisponibles: TListaDeCosasConNombre);
var
  i: integer;
begin
  inherited Create_conSalaYEditor_(AOwner, xsala );
  self.Top := AOwner.Top + utilidades.plusTop;
  self.Left := AOwner.Left + utilidades.plusLeft;
  disponibles := centralesDisponibles;

  for i := 0 to centralesDisponibles.Count - 1 do
    self.cbCentrales.Items.Add(TCosaConNombre(centralesDisponibles[i]).ClaseNombre);

  if central <> nil then
  begin
    self.cbCentrales.ItemIndex := Self.cbCentrales.Items.IndexOf(central.ClaseNombre);
    self.ECoef.Text := FloatToStrF(coeficiente, ffGeneral, CF_PRECISION, CF_DECIMALESPU);
  end;
  guardado := True;
end;

function TEditarCentralCoeficiente.darCentral: TGeneradorHidraulico;
begin
  Result := central;
end;

function TEditarCentralCoeficiente.darCoeficiente: NReal;
begin
  Result := coeficiente;
end;

function TEditarCentralCoeficiente.validarFormulario: boolean;
begin
  if cbCentrales.ItemIndex <> -1 then
    Result := inherited validarEditFloat(ECoef, 0, xMatDefs.MaxNReal)
  else
  begin
    ShowMessage(mesSeleccionarCentralDeLista);
    Result := False;
  end;
end;

procedure TEditarCentralCoeficiente.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarCentralCoeficiente.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;


procedure TEditarCentralCoeficiente.BGuardarClick(Sender: TObject);
var
  clase, nombre: string;
  ipos: integer;
  cadena: string;
begin
  if validarFormulario then
  begin
    cadena := cbCentrales.Items[cbCentrales.ItemIndex];
    clase := uCosaConNombre.ParseClase(cadena);
    nombre := uCosaConNombre.ParseNombre(cadena);
    coeficiente := StrToFloat(ECoef.Text);
    if disponibles.find(clase, nombre, ipos) then
      central := TGeneradorHidraulico(disponibles[ipos])
    else
      raise Exception.Create(mesNoSeEncuentraActor + ' ' + cadena + '.');
    modalResult := mrOk;
  end;
end;

procedure TEditarCentralCoeficiente.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarCentralCoeficiente.EditExit(Sender: TObject);
begin
  inherited EditExit(Sender);
end;

procedure TEditarCentralCoeficiente.cambiosForm(Sender: TObject);
begin
  inherited cambiosForm(Sender);
end;

end.
