unit formModificarReferencia;


interface

uses
  {$IFDEF WINDOWS}
  // Windows,
  {$ELSE}
  LCLType,
  {$ENDIF}
 //Messages,
  SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TformErrorReferencia = class(TForm)
    LReferente: TLabel;
    EReferente: TEdit;
    gbReferido: TGroupBox;
    LClaseReferido: TLabel;
    LNombreReferido: TLabel;
    cbClaseReferido: TComboBox;
    cbNombreReferido: TComboBox;
    BAceptar: TButton;
    gbReferidoErroneo: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    EClaseReferidoErroneo: TEdit;
    ENombreReferidoErroneo: TEdit;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  formErrorReferencia: TformErrorReferencia;

implementation

  {$R *.lfm}

end.
