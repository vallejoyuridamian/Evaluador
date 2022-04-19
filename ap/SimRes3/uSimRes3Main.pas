unit uSimRes3Main;

interface

uses
  {$IFDEF WINDOWS}
  Windows,
  {$ENDIF}
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ComCtrls, ExtCtrls,
  uconstantesSimSEE,
  uversiones;

type

  { TForm1 }

  TForm1 = class(TForm)
    BBuscar: TButton;
    BEjecutar: TButton;
    EArchiDefs: TEdit;
    LArchiDefs: TLabel;
    LProgresoPrint: TLabel;
    OpenDialog1: TOpenDialog;
    PBPrint: TProgressBar;
    Timer1: TTimer;
    procedure BBuscarClick(Sender: TObject);
    procedure BEjecutarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    procedure initProgressBar(nPasos: integer; const estado: string);
    procedure stepProgressBar;
  public
    ArchiSalida: string;
    MostrarLibroExcel: boolean;
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

uses usimres3;

{ TForm1 }

procedure TForm1.BBuscarClick(Sender: TObject);
begin
  if OpenDialog1.Execute then
    EArchiDefs.Text := OpenDialog1.FileName;

end;

procedure TForm1.BEjecutarClick(Sender: TObject);
var
  cursorAnterior: TCursor;
  dt: TDateTime;
begin
(*
  chdir( 'c:\tmp\simsee\11' );
  EArchiDefs.Text:= 'c:\tmp\simsee\11\x.txt';
  *)
  if EArchiDefs.Text <> '' then
  begin

    BEjecutar.Enabled := False;
    BBuscar.Enabled := False;
    cursorAnterior := Screen.Cursor;
    screen.Cursor := crHourGlass;
    usimres3.procInitNotificar := self.initProgressBar;
    usimres3.procNotificar := self.stepProgressBar;
    if (ARchiSalida = '') then
    begin
      ArchiSalida := quitarExtension(EArchiDefs.Text) + '.xls';
    end;
    try
      dt := now();
      usimres3.run(EArchiDefs.Text, ArchiSalida, MostrarLibroExcel);
      writelN('Tiempo de ejecución SimRes3: ' +
        IntToStr(trunc((now - dt) * 24 * 3600 + 0.5)) + ' [s]');
    finally
      screen.Cursor := cursorAnterior;
      BBuscar.Enabled := True;
      BEjecutar.Enabled := True;
    end;
  end
  else
    ShowMessage('Primero debe seleccionar un archivo!');
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  self.Caption := AnsiToUtf8('SimRes3 - v' + uversiones.vSimRes3_);
  OpenDialog1.InitialDir := uconstantesSimSEE.getDir_Run;
  OpenDialog1.Filter := 'Archivos de Texto (*.txt)|*.txt|Todos los Archivos (*.*)|*.*';
  ArchiSalida := '';
  MostrarLibroExcel := True;
  if ParamCount > 0 then
  begin
    timer1.Enabled := True;
  end;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
  autocerrar: boolean;

begin
  timer1.Enabled := False;
  self.EArchiDefs.Text := ParamStr(1);

  if ParamCount > 1 then
  begin
    if ParamStr(2) = 'autocerrar' then
    begin
      autocerrar := True;
      MostrarLibroExcel := False;
    end
    else
      autocerrar := False;
    if ParamCount > 2 then
      ArchiSalida := ParamStr(3);
  end
  else
    autocerrar := False;

  BEjecutarClick(self);

  {$IFDEF WINDOWS}
  if autocerrar then
    postmessage(handle, WM_CLOSE, 0, 0);
  {$ENDIF}
end;

procedure TForm1.initProgressBar(nPasos: integer; const estado: string);
begin
  self.PBPrint.Position := 0;
  self.PBPrint.Max := nPasos;
  self.Caption := AnsiToUtf8('SimRes3 - v' + uversiones.vSimRes3_ + ' - ' + estado);
end;

procedure TForm1.stepProgressBar;
begin
  self.PBPrint.StepIt;
  Application.ProcessMessages;
end;

end.
