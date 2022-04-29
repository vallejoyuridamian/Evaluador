unit uEditorEscenario;

{$mode delphi}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls,
  xmatdefs,
  uverdoc, uescenarios;

type

  { TEditorEscenario }

  TEditorEscenario = class(TForm)
    btAyudaGlobales: TButton;
    bt_Guardar: TButton;
    bt_Cancelar: TButton;
    cbRunOpt: TCheckBox;
    cbRunSim: TCheckBox;
    cbRunSimRes3: TCheckBox;
    eCapasActivas: TEdit;
    eNombre: TEdit;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    eDescripcion: TMemo;
    procedure btAyudaGlobalesClick(Sender: TObject);
    procedure bt_CancelarClick(Sender: TObject);
    procedure bt_GuardarClick(Sender: TObject);
  private
    { private declarations }
    listado: TListaEscenarios;
    prec_orig: TEscenario_rec;
    cnt_cambios: integer;

  public
    { public declarations }
    procedure set_data( prec: TEscenario_rec; listado: TListaEscenarios );
    procedure get_data( prec: TEscenario_rec );
    function validar_formulario: boolean;
  end;

var
  EditorEscenario: TEditorEscenario;

resourcestring
  rs_CapasActivas_invalidas = 'Capas activas no válidas. Deben ser números enteros separados por ";".';

implementation

{$R *.lfm}

{ TEditorEscenario }

procedure TEditorEscenario.btAyudaGlobalesClick(Sender: TObject);
begin
  verdoc(self, 'editor-escenario', 'Escenario');
end;

procedure TEditorEscenario.bt_CancelarClick(Sender: TObject);
begin
  ModalResult:= -1;
end;

procedure TEditorEscenario.bt_GuardarClick(Sender: TObject);
begin
  if validar_formulario then
   ModalResult:= 1;
end;

procedure TEditorEscenario.set_data( prec: TEscenario_rec; listado: TListaEscenarios );
begin
  self.listado:= listado;
  self.prec_orig:= prec;

  if prec <> nil then
  begin
    eNombre.text:= prec.nombre;
    eCapasActivas.text:= DAOfNIntToStr( prec.capasActivas, ';' );
    eDescripcion.Text:= prec.descripcion;
    cbRunOpt.Checked:= prec.run_opt;
    cbRunSim.Checked:= prec.run_sim;
    cbRunSimRes3.Checked:= prec.run_sr3;
  end
  else
  begin
    eNombre.text:= '??';
    eCapasActivas.text:= '0';
    eDescripcion.Text:= '??';
    cbRunOpt.Checked:= true;
    cbRunSim.Checked:= true;
    cbRunSimRes3.Checked:= true;
  end;
end;

procedure TEditorEscenario.get_data( prec: TEscenario_rec );
begin
  prec.nombre:= eNombre.text;
  prec.capasActivas:= StrToDAOfNInt( eCapasActivas.Text, ';' );
  prec.descripcion:= eDescripcion.Text;
  prec.run_opt:= cbRunOpt.Checked;
  prec.run_sim:= cbRunSim.Checked;
  prec.run_sr3:= cbRunSimRes3.Checked;
end;

function TEditorEscenario.validar_formulario: boolean;
var
  s: string;
  vi: TDAOfNInt;
  res: boolean;
begin
  cnt_cambios:= 0;

  if prec_orig.nombre <> eNombre.text then
    inc( cnt_cambios );
  if prec_orig.descripcion <> eDescripcion.text then
    inc( cnt_cambios );
  if prec_orig.run_opt <> cbRunOpt.Checked then
    inc( cnt_cambios );
  if prec_orig.run_sim <> cbRunSim.Checked then
    inc( cnt_cambios );
  if prec_orig.run_sr3 <> cbRunSimRes3.Checked then
    inc( cnt_cambios );

  s:= DAOfNIntToStr( prec_orig.capasActivas,';' );
  if s <> eCapasActivas.text then
   inc( cnt_cambios );

  try
   vi:= StrToDAOfNInt( eCapasActivas.text, ';' );
   if length( vi ) = 0 then raise Exception.Create('error de conversión');
   setlength( vi, 0 );
   res:= true;
  except
    showmessage( rs_CapasActivas_invalidas );
    eCapasActivas.SetFocus;
    res:= false;
  end;
  result:= res;
end;

end.

