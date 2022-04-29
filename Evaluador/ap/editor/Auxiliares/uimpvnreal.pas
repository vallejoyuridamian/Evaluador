unit uimpvnreal;

{$MODE Delphi}

interface

uses
  {$IFDEF WINDOWS}
  Windows,
  {$ENDIF}
 Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls,
  xmatdefs, uauxiliares;

resourcestring
  mesCantidadDatosImportados = 'La cantidad de datos importados debe ser';
  mesSeContaron = 'se contaron:';
  mesReviseYVuelvaAProbar = 'Revise y vuelva a intentar.';


type
	TFormImportarVectorNReales = class(TForm)
		Memo1: TMemo;
		Importar: TButton;
    eSeparadorDecimal: TEdit;
    Label1: TLabel;
		procedure ImportarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
	private
		{ Private declarations }
		a: TDAOfNreal;
	public
		{ Public declarations }
	end;

function importarDatos: TDAOfNReal;
function importarDatosTamanioN(n: Integer): TDAOfNReal;

implementation

{$R *.lfm}

procedure TFormImportarVectorNReales.FormCreate(Sender: TObject);
begin
  eSeparadorDecimal.Text:= sysutils.DecimalSeparator;
end;

procedure TFormImportarVectorNReales.ImportarClick(Sender: TObject);
(*
var
  sepDec: Char;
{$IFDEF WINDOWS}
  MyDecimal: PChar;
{$ENDIF}
*)
begin
	a:= uauxiliares.TextToDArrOfNReal( memo1.text, eSeparadorDecimal.text[1] );
(*
{$IFDEF WINDOWS}
  MyDecimal:=StrAlloc(10);
  GetLocaleInfo(LOCALE_SYSTEM_DEFAULT, LOCALE_SDECIMAL, MyDecimal, 10);
  if StrLen(MyDecimal) = 1 then
    sepDec:= MyDecimal[0]
  else
    raise Exception.Create('El separador decimal es ' + MyDecimal + ' debe cambiarlo por uno de un único caracter.');
{$ELSE}
  sepDec:= '.';
{$ENDIF}

	a:= uauxiliares.TextToDArrOfNReal( memo1.text, sepDec );
	modalresult:= mrOk;
*)
	modalresult:= mrOk;
end;

function importarDatos: TDAOfNreal;
var
	Form2: TFormImportarVectorNReales;
	res: integer;
begin
	Form2:= TFormImportarVectorNReales.Create( nil );
	res:= Form2.ShowModal;
	if res= mrOk then
		result:= copy( Form2.a)
	else
		result:= nil;
	Form2.Free;
end;

function importarDatosTamanioN(n: Integer): TDAOfNReal;
var
  vect: TDAofNReal;
begin
  vect:= importarDatos;
  if (vect <> NIL) and (length(vect) <> 0) then
  begin
    if length(vect) = n then
      result:= vect
    else
    begin
      ShowMessage(mesCantidadDatosImportados +' '+ IntToStr(n)+' '+mesSeContaron+' '+IntToStr( length(vect) )+'. '+mesReviseYVuelvaAProbar);
      result:= NIL;
    end;
  end
  else
    result:= NIL;
end;


end.