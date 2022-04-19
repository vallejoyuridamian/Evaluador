unit ucmdform;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
  {Windows, Messages, }SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, usalasdejuego;

type
  TformConsola = class(TForm)
    memoConsola: TMemo;
    memoInput: TMemo;
    procedure memoInputKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
    salas: array of TSalaDeJuego;
(*
    function AbrirSala( archi: string ): integer;
    function CerrarSala( id: integer ): integer;
    function cd( elemento: string ): integer;
    function ls( mascara: string ): integer;
    *)
  end;

var
  formConsola: TformConsola;

implementation

{$IFNDEF FPC}
  {$R *.dfm}
{$ELSE}
  {$R *.lfm}
{$ENDIF}


procedure TformConsola.FormClose(Sender: TObject; var Action: TCloseAction);
var
  k: integer;
begin
  for k:= 0 to high( salas ) do
   if salas[k] <> nil then
    salas[k].Free;
  setlength( salas, 4 );
end;

procedure TformConsola.FormCreate(Sender: TObject);
var
  k: integer;
begin
  setlength( salas, 4 );
  for k:= 0 to high( salas ) do salas:= nil;
end;




procedure TformConsola.memoInputKeyPress(Sender: TObject; var Key: Char);
var
  s: string;
begin
   if ( ord( key ) = 13 ) then
   begin
     s:= trim(memoInput.text);
     memoConsola.Lines.Add( s );
     memoInput.Text:= '';


     if (s = 'ls' ) then
     begin
//       if sala <> nil then
       begin

       end;
     end;
   end;
end;

end.
