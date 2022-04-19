unit uEditarFichaGTer_solartermico_Fuentes;

interface

uses
  {$IFDEF WINDOWS}
   Windows,
   {$ELSE}
   LCLType,
   {$ENDIF}
 Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uGeneradores, uSalasDeJuego, xMatDefs, uCosaConNombre, StdCtrls,
  uBaseFormularios, utilidades, uconstantesSimSEE, uBaseEditoresFichas, ufichasLPD,
  uFuentesAleatorias;

type
  TEditarFichaGTer_solartermico_Fuentes = class(TBaseEditoresFichas)
    CBFuenteAleatoria: TComboBox;
    LCentral: TLabel;
    LCoeficiente: TLabel;
    BGuardar: TButton;
    BCancelar: TButton;
    CBBorne: TComboBox;
    procedure BCancelarClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure BGuardarClick(Sender: TObject); override;
    procedure EditEnter(Sender: TObject);
    procedure EditExit(Sender: TObject);
    procedure CBFuenteAleatoriaChange(Sender: TObject);
  protected
    function validarFormulario : boolean; override;
  private
    fuenteAleatoria : TFuenteAleatoria;
    borne : String;
  public
    Constructor Create(AOwner: TComponent; cosaConNombre: TCosaConNombre; ficha: TFichaLPD; sala: TSalaDeJuego; fuenteAleatoria : TFuenteAleatoria; borne : String); reintroduce;
    function darFuenteAleatoria : TFuenteAleatoria;
    function darBorne : String;
  end;

var
  EditarFichaGTer_solartermico_Fuentes: TEditarFichaGTer_solartermico_Fuentes;

implementation

  {$R *.lfm}

procedure TEditarFichaGTer_solartermico_Fuentes.CBFuenteAleatoriaChange(
  Sender: TObject);
begin
  inherited CBFuenteChange(Sender, CBBorne);
end;

Constructor TEditarFichaGTer_solartermico_Fuentes.Create(AOwner: TComponent; cosaConNombre: TCosaConNombre; ficha: TFichaLPD; sala: TSalaDeJuego; fuenteAleatoria : TFuenteAleatoria; borne : String);
begin
  inherited Create(AOwner, cosaConNombre, ficha, sala);
  inherited inicializarCBFuente(CBFuenteAleatoria, CBBorne, false);

  if fuenteAleatoria <> nil then
  begin
    setCBFuente(CBFuenteAleatoria, CBBorne, fuenteAleatoria, borne);
  end;
  //guardado := True;
end;

function TEditarFichaGTer_solartermico_Fuentes.darFuenteAleatoria : TFuenteAleatoria;
begin
  result := fuenteAleatoria;
end;

function TEditarFichaGTer_solartermico_Fuentes.darBorne : String;
begin
  result := borne;
end;

function TEditarFichaGTer_solartermico_Fuentes.validarFormulario : boolean;
begin

  result := inherited validarCBFuente(CBFuenteAleatoria, CBBorne, 0 );

end;

procedure TEditarFichaGTer_solartermico_Fuentes.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarFichaGTer_solartermico_Fuentes.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;


procedure TEditarFichaGTer_solartermico_Fuentes.BGuardarClick(Sender: TObject);
begin
  if validarFormulario then
  begin
    fuenteAleatoria := valorCBFuente(CBFuenteAleatoria);
    borne := valorCBString(CBBorne);
    modalResult := mrOk;
  end
end;

procedure TEditarFichaGTer_solartermico_Fuentes.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarFichaGTer_solartermico_Fuentes.EditExit(Sender: TObject);
begin
  inherited EditExit(Sender)
end;

end.