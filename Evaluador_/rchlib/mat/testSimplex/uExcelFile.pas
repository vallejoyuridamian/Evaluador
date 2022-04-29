unit uExcelFile;

interface

type
	TExcelFile= class
		v: variant; // el workbook
		constructor Create( nombreHoja1: string; visible: boolean );
//		constructor CreateLoad( nombre: string; visible: boolean );
		procedure Guardar( nombre: string );
		procedure Abrir (nombArchivo: string );
		procedure agregoHoja( nombreHoja: string );
		function Hoja( iHoja: integer ): Variant; overload;
		function Hoja( nombreHoja: string ): Variant; overload;
		procedure EscribirCelda(nombreHoja:string; fila:integer; columna:integer; contenido:variant);
		procedure EscribirCeldaTexto(nombreHoja:string; fila:integer; columna:integer; contenido:string);
		function ContenidoCelda(nombreHoja:string; var fila:integer; columna:integer; incrementa:boolean): variant;
		procedure Free;
		procedure VisibleOn;
		procedure VisibleOff;
	end;





implementation
uses
	ComObj, XLConst; //, Variants;

(*
procedure EscribirCelda(fila:integer; columna:integer; contenido:variant);
begin
//	v.Workbooks[1].ActiveWorkSheets[1].Name:
//	.cells[fila, columna]:= contenido;
end;
	*)
constructor TExcelFile.Create( nombreHoja1: string; visible: boolean );
var
h: variant;
begin

	inherited Create;
	v:= CreateOleObject('Excel.Application');
	v.visible := visible;
	if nombreHoja1 <> '' then
	begin
		v.Workbooks.Add(xlWBatWorkSheet);
		v.Workbooks[1].WorkSheets[1].Name:= nombreHoja1;
	end;
end;

function TExcelFile.Hoja( nombreHoja: string ): Variant;
begin
	result:=v.Workbooks[1].WorkSheets[nombreHoja];
end;

function TExcelFile.Hoja( iHoja: integer ): Variant;
begin
	result:=v.Workbooks[1].WorkSheets[ihoja];
end;


procedure TExcelFile.EscribirCelda(nombreHoja:string; fila:integer; columna:integer; contenido:variant);
var
	h:variant;
begin
	h:= self.Hoja(nombreHoja);
	h.cells[fila, columna]:= contenido;
end;

procedure TExcelFile.EscribirCeldaTexto(nombreHoja:string; fila:integer; columna:integer; contenido:string);
var
	h:variant;
begin
	h:= self.Hoja(nombreHoja);
	h.cells[fila, columna]:= contenido;
end;



function TExcelFile.ContenidoCelda(nombreHoja:string; var fila:integer; columna:integer; incrementa:boolean):variant;
var
	h:variant;
begin
//	h:= v.Workbooks[1].WorkSheets[1];
	h:= self.Hoja(nombreHoja);
	result:= h.cells[fila, columna];
	if incrementa then
		inc(fila);
end;


procedure TExcelFile.Guardar( nombre: string );
begin
	v.Workbooks[1].SaveAs(	nombre, xlNormal, '', '', false, false );
{
	FileName:="C:\Mis documentos\Hoja1.xls",
	FileFormat:= xlNormal,
	Password:="",
	WriteResPassword:="",
	ReadOnlyRecommended:=False,
	CreateBackup:=False );}


end;





procedure TExcelFile.Abrir( nombArchivo: string );
begin
	v.Workbooks.Open (nombArchivo);
end;



procedure TExcelFile.agregoHoja( nombreHoja: string );
begin
	v.Workbooks[1].Sheets.Add(,,1,xlWorksheet);
	v.Workbooks[1].WorkSheets[1].name:= nombreHoja;
end;

procedure TExcelFile.Free;
begin
	if not VarIsEmpty(v) then
	begin
//    v.DisplayAlerts := False;
    v.Quit;
  end;
	inherited Free;
end;

procedure TExcelFile.VisibleOn;
begin
	v.Visible:= true;
end;

procedure TExcelFile.VisibleOff;
begin
	v.Visible:= false;
end;


end.
