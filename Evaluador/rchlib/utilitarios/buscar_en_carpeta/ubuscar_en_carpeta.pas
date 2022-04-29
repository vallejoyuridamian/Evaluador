unit ubuscar_en_carpeta;

{$H+}

interface

uses
  Classes,
  dos,
  SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TFormBuscarEnCarpeta }
  TFormBuscarEnCarpeta = class(TForm)
    btBuscar: TButton;
    btCarpeta: TButton;
    eCarpeta: TEdit;
    eBuscar: TEdit;
    eMascara: TEdit;
    Label1: TLabel;
    mListaArchivos: TMemo;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    procedure btBuscarClick(Sender: TObject);
    procedure btCarpetaClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    xmascara, xcarpeta, xstrbuscar: string;
    procedure scanArchivos( const carpeta: string);
    procedure scanCarpetas( const carpeta: string);
    function scanArchivo( const archi: string ): integer;
  end;

var
  FormBuscarEnCarpeta: TFormBuscarEnCarpeta;

implementation

{$R *.lfm}

function TFormBuscarEnCarpeta.scanArchivo( const archi: string ): integer;
var
  r: string;
  f: textfile;
  ocurrencias: integer;
begin
  ocurrencias:= 0;
  assignfile( f, archi );
  filemode:= 0;
  reset( f );
  while not eof( f ) do
  begin
    readln( f, r );
    if pos( xstrbuscar, r ) > 0 then
    begin
      writeln( r );
      inc( ocurrencias );
    end;
  end;
  result:= ocurrencias;
end;

procedure TFormBuscarEnCarpeta.scanArchivos( const carpeta: string);
var
  Dir: TSearchRec;
  archi: string;
  res: integer;
begin
  res:= FindFirst(carpeta + '\'+xMascara, archive, Dir);
  while ( res = 0) do
  begin
    if ((Dir.attr and archive) <> 0) then
    begin
      archi := carpeta + '\' + Dir.Name;
      if scanArchivo( archi ) > 0 then
         mListaArchivos.lines.add( archi );
    end;
    res:= FindNext(Dir);
  end;
  FindClose(Dir);
end;

procedure TFormBuscarEnCarpeta.scanCarpetas( const carpeta: string);
var
  Dir: TSearchRec;
  res: integer;
begin
  res:= FindFirst(carpeta + '\*', faDirectory, Dir);
  while ( res = 0) do
  begin
     if ((Dir.attr and directory) <> 0) and (Dir.Name[1] <> '.') and
      (Dir.Name <> 'backup') then
    begin
      scanCarpetas( carpeta + '\' + Dir.Name );
    end;
    res:= FindNext(Dir);
  end;
  FindClose(Dir);
  scanArchivos( carpeta );
end;

{ TFormBuscarEnCarpeta }

procedure TFormBuscarEnCarpeta.btBuscarClick(Sender: TObject);
begin
  xmascara:= eMascara.Text;
  xcarpeta:= eCarpeta.Text;
  xstrbuscar:= eBuscar.Text;
  mListaArchivos.Lines.Clear;
  scanCarpetas( xcarpeta );
end;

procedure TFormBuscarEnCarpeta.btCarpetaClick(Sender: TObject);
begin
  if SelectDirectoryDialog1.Execute then
  begin
    eCarpeta.Text:= SelectDirectoryDialog1.FileName;
  end;
end;



end.

