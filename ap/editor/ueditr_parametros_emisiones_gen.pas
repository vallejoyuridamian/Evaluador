unit ueditr_parametros_emisiones_gen;

{$mode delphi}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  xMatDefs, ufechas;

type

  { TfEditParametrosEmisionesGenerador }

  TfEditParametrosEmisionesGenerador = class(TForm)
    btGuardar: TButton;
    btCancelar: TButton;
    cb_lcmr: TCheckBox;
    cb_cdm: TCheckBox;
    eNacimiento: TEdit;
    eTonMWh: TEdit;
    eNombre: TEdit;
    eTipo: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    lbl_nombre: TLabel;
    procedure btCancelarClick(Sender: TObject);
    procedure btGuardarClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  fEditParametrosEmisionesGenerador: TfEditParametrosEmisionesGenerador;

implementation

{$R *.lfm}

{ TfEditParametrosEmisionesGenerador }

procedure TfEditParametrosEmisionesGenerador.btGuardarClick(Sender: TObject);
var
  res: integer;
  nr: NReal;
  ok: boolean;
  f: TFecha;

begin
  ok:= true;

  val( eTonMWh.text, res );
  if res <> 0 then
  begin
    showmessage( 'Debe digitar un número válido para el factor de emisiones Ton/MWh' );
    eTonMWh.SetFocus;
    ok:= false;
  end;

  try
    f:= TFecha.Create_Str( eNacimiento.text );
    f.Free;
  except
    showmessage( 'Debe ingresar una fecha válida de incorporación al sistema' );
    eNacimiento.SetFocus;
    ok:= false;
  end;

  if ok then modalresult:= 1;
end;

procedure TfEditParametrosEmisionesGenerador.btCancelarClick(Sender: TObject);
begin
  modalresult:= -1;
end;

end.

