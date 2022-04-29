unit uEditarFichaMercadoSpot_postizado_Fuentes;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
  {$IFDEF WINDOWS}
  Windows,
  {$ENDIF}
  Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uGeneradores, uSalasDeJuego, xMatDefs, uCosaConNombre, StdCtrls,
  uBaseFormularios, utilidades, uconstantesSimSEE, uBaseEditoresFichas, ufichasLPD,
  uFuentesAleatorias, uverdoc;

type

  { TEditarFichaMercadoSpot_postizado_Fuentes }

  TEditarFichaMercadoSpot_postizado_Fuentes = class(TBaseEditoresFichas)
    BAyuda: TButton;
    CBFuenteAleatoria: TComboBox;
    LCentral: TLabel;
    LCoeficiente: TLabel;
    BGuardar: TButton;
    BCancelar: TButton;
    CBBorne: TComboBox;
    procedure BAyudaClick(Sender: TObject);
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
  EditarFichaMercadoSpot_postizado_Fuentes: TEditarFichaMercadoSpot_postizado_Fuentes;



implementation

{$IFNDEF FPC}
  {$R *.dfm}
{$ELSE}
  {$R *.lfm}
{$ENDIF}

procedure TEditarFichaMercadoSpot_postizado_Fuentes.CBFuenteAleatoriaChange(
  Sender: TObject);
begin
  inherited CBFuenteChange(Sender, CBBorne);
end;

Constructor TEditarFichaMercadoSpot_postizado_Fuentes.Create(AOwner: TComponent; cosaConNombre: TCosaConNombre; ficha: TFichaLPD; sala: TSalaDeJuego; fuenteAleatoria : TFuenteAleatoria; borne : String);
begin
  inherited Create(AOwner, cosaConNombre, ficha, sala);
  inherited inicializarCBFuente(CBFuenteAleatoria, CBBorne, false);

  if fuenteAleatoria <> nil then
  begin
    setCBFuente(CBFuenteAleatoria, CBBorne, fuenteAleatoria, borne);
  end;
  //guardado := True;
end;

function TEditarFichaMercadoSpot_postizado_Fuentes.darFuenteAleatoria : TFuenteAleatoria;
begin
  result := fuenteAleatoria;
end;

function TEditarFichaMercadoSpot_postizado_Fuentes.darBorne : String;
begin
  result := borne;
end;

function TEditarFichaMercadoSpot_postizado_Fuentes.validarFormulario : boolean;
begin

  result := inherited validarCBFuente(CBFuenteAleatoria, CBBorne, 0 );

end;

procedure TEditarFichaMercadoSpot_postizado_Fuentes.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarFichaMercadoSpot_postizado_Fuentes.BAyudaClick(Sender: TObject
  );
begin
  uverdoc.verdoc( self, 'ht_fichamspot_postizado_fuentes' );
end;

procedure TEditarFichaMercadoSpot_postizado_Fuentes.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;


procedure TEditarFichaMercadoSpot_postizado_Fuentes.BGuardarClick(Sender: TObject);
begin
  if validarFormulario then
  begin
    fuenteAleatoria := valorCBFuente(CBFuenteAleatoria);
    borne := valorCBString(CBBorne);
    modalResult := mrOk;
  end
end;

procedure TEditarFichaMercadoSpot_postizado_Fuentes.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarFichaMercadoSpot_postizado_Fuentes.EditExit(Sender: TObject);
begin
  inherited EditExit(Sender)
end;

end.