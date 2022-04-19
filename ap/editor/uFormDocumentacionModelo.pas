unit uFormDocumentacionModelo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, OleServer, Word2000, StdCtrls, OleCtnrs, uCosaConNombre;

type
  TFormDocumentacionModelo = class(TForm)
    docContainer: TOleContainer;
    BGuardar: TButton;
    BCancelar: TButton;
    procedure BGuardarClick(Sender: TObject);
    procedure BCancelarClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure docContainerResize(Sender: TObject);
  private
    nombreArch : String;
    function nombreArchivo(claseDelModelo : TClass) : String;
  public
    Constructor Create(AOwner: TForm ; claseDelModelo : TClaseDeCosaConNombre); reintroduce;
  end;

var
  FormDocumentacionModelo: TFormDocumentacionModelo;

implementation

uses Math, SimSEEUEditMain;

{$R *.dfm}
Constructor TFormDocumentacionModelo.Create(AOwner: TForm ; claseDelModelo : TClaseDeCosaConNombre);
begin
  inherited Create(AOwner);
  nombreArch:= nombreArchivo(claseDelModelo);
  if FileExists(nombreArch) then
    docContainer.LoadFromFile(nombreArch);
  docContainer.Modified:= false;
end;

function TFormDocumentacionModelo.nombreArchivo(claseDelModelo : TClass) : String;
begin
  result:= FSimSEEUEdit.helpPath + claseDelModelo.ClassName + '.shp';
end;

procedure TFormDocumentacionModelo.BGuardarClick(Sender: TObject);
begin
  docContainer.SaveToFile(nombreArch);
  docContainer.Modified:= false;
  self.Close;
end;

procedure TFormDocumentacionModelo.BCancelarClick(Sender: TObject);
begin
  self.Close;
end;

procedure TFormDocumentacionModelo.FormResize(Sender: TObject);
begin
  BGuardar.Left:= self.ClientWidth div 4 - BGuardar.Width div 2;
  BCancelar.Left:= (self.ClientWidth * 3) div 4 - BCancelar.Width div 2;
end;

procedure TFormDocumentacionModelo.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if ActiveControl is TOleContainer then
    TOleContainer(ActiveControl).UpdateObject;
  if docContainer.Modified and
     (Application.MessageBox('Los cambios no se han guardado. ¿Desea hacerlo ahora?', 'SimSEEUEdit',
							 MB_YESNO or MB_ICONEXCLAMATION) = IDYES) then
    docContainer.SaveToFile(nombreArch);
  CanClose:= true;
end;

procedure TFormDocumentacionModelo.docContainerResize(Sender: TObject);
begin
  BGuardar.Top:= docContainer.Top + docContainer.Height + 5;
  BCancelar.Top:= docContainer.Top + docContainer.Height + 5;
end;

end.
