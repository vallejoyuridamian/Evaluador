unit uimpmatnreal;


interface

uses
  {$IFDEF WINDOWS}
   Windows,
   {$ELSE}
   LCLType,
   {$ENDIF}
 Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, xMatDefs, StdCtrls, uAuxiliares;

resourcestring
  exSeparadorDecimalEs = 'El separador decimal es ';
  exCambiarloPorUnicoCaracter = ' debe cambiarlo por uno de un único caracter.';
  mesMatrizImportadaTamanio = 'La matriz importada debe ser de tamaño ';

type
  TFormImportarMatrizNReal = class(TForm)
    Memo1: TMemo;
    Importar: TButton;
    procedure ImportarClick(Sender: TObject);
  private
    { Private declarations }
  public
    mat: TMatOfNReal;
  end;

function importarMatriz: TMatOfNReal;
function importarMatrizMxN(m, n: Integer): TMatOfNReal;

implementation
{$R *.lfm}

procedure TFormImportarMatrizNReal.ImportarClick(Sender: TObject);
var
  sepDec: Char;
{$IFDEF WINDOWS}
  MyDecimal: PChar;
{$ENDIF}
begin
{$IFDEF WINDOWS}
  MyDecimal:=StrAlloc(10);
  GetLocaleInfo(LOCALE_SYSTEM_DEFAULT, LOCALE_SDECIMAL, MyDecimal, 10);
  if StrLen(MyDecimal) = 1 then
    sepDec:= MyDecimal[0]
  else
    raise Exception.Create(exSeparadorDecimalEs + MyDecimal + exCambiarloPorUnicoCaracter);
{$ELSE}
  sepDec:= '.';
{$ENDIF}

	mat:= uauxiliares.TextToTMatOfNReal( memo1.lines, sepDec );
	modalresult:= mrOk;
end;

function importarMatriz: TMatOfNReal;
var
	Form2: TFormImportarMatrizNReal;
	res: integer;
begin
	Form2:= TFormImportarMatrizNReal.Create( nil );
	res:= Form2.ShowModal;
	if res= mrOk then
		result:= Form2.mat
	else
		result:= nil;
	Form2.Free;
end;

function importarMatrizMxN(m, n: Integer): TMatOfNReal;
var
  mat: TMatOfNReal;
begin
  mat:= importarMatriz;
  if (mat <> NIL) and (length(mat) <> 0) then
  begin
    if (Length(mat) = m) and (length(mat[0]) = n) then
      result:= mat
    else
    begin
      ShowMessage(mesMatrizImportadaTamanio + IntToStr(m) + 'x' + IntToStr(n));
      result:= NIL;
    end;
  end
  else
    result:= NIL;
end;

end.