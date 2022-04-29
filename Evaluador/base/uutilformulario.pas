unit uUtilFormulario;

{$mode delphi}

interface

uses
  Classes, SysUtils, uvisordetabla, StdCtrls, Dialogs, xMatDefs;

resourcestring
  rs_ErrorDeFormato_SeEsperabaUnEntero = 'Error de formato. Se esperaba un entero.';
  rs_ErrorDeFormato_SeEsperabaUnReal = 'Error de formato. Se esperaba un real.';

procedure dump_int(tbl: TTabla; var resVal: Integer; nameId: string; iFil, jCol: integer; var hayCambios, hayErrores: boolean  );
procedure dump_float(tbl: TTabla; var resVal: NReal; nameId: string; iFil, jCol: integer; var hayCambios, hayErrores: boolean );
procedure dump_boolean(tbl: TTabla; var resVal: boolean; nameId: string; iFil, jCol: integer; var hayCambios, hayErrores: boolean );

implementation

procedure dump_int(tbl: TTabla; var resVal: INteger; nameId: string; iFil, jCol: integer; var hayCambios, hayErrores: boolean  );
var
  IVal: integer;
  ed:  TEdit;
begin
  if hayErrores then exit;
  ed  := tbl.FindObj(iFil, jCol, nameId);
  try
    IVal:=StrToInt( ed.text );
    if IVal <> resVal then
    begin
      resVal:= IVal;
      hayCambios:= true;
    end;
  except
    showMessage( rs_ErrorDeFormato_SeEsperabaUnEntero );
    hayErrores:= true;
  end;
end;

procedure dump_float(tbl: TTabla; var resVal: NReal; nameId: string; iFil, jCol: integer; var hayCambios, hayErrores: boolean );
var
  RVal: NReal;
  ed:  TEdit;
begin
  if hayErrores then exit;
  ed  := tbl.FindObj(iFil, jCol, nameId);
  try
    RVal:=StrToFloat( ed.text );
    if RVal <> resVal then
    begin
      resVal:= RVal;
      hayCambios:= true;
    end;
  except
    showMessage( rs_ErrorDeFormato_SeEsperabaUnReal );
    hayErrores:= true;
  end;
end;

procedure dump_boolean(tbl: TTabla; var resVal: boolean; nameId: string; iFil, jCol: integer; var hayCambios, hayErrores: boolean );
var
  BVal: boolean;
  cb:  TCheckBox;
begin
    if hayErrores then exit;
    cb  := tbl.FindObj(iFil, jCol, nameId);
    BVal:= cb.checked;
    if BVal <> resVal then
    begin
      resVal:= BVal;
      hayCambios:= true;
    end;
end;

end.
