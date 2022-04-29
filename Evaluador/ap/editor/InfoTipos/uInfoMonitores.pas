unit uInfoMonitores;

interface

uses
	Classes, SysUtils, uBaseAltasMonitores, uAltaMonitorConsola, uAltaMonitorGrafico,
	uReferenciaMonitor, uAltaMonArchivo, uAltaMonHistograma;

type
	TClaseEditorMonitor = class of TBaseAltasMonitores;

	TInfoMonitor = class
		private
			tipoMonitor : TClaseReferenciaMonitor;
			descClase : String;
			editor : TClaseEditorMonitor;
		public
			Constructor Create(xtipoMonitor : TClaseReferenciaMonitor; xdescClase : String; xeditor : TClaseEditorMonitor);
	end;

	TListaInfoMonitores = class (TList)
		function getTipoEditor(tipo : TClass) : TClaseEditorMonitor; overload;
		function getTipoEditor(descClase : String) : TClaseEditorMonitor; overload;
		function descsClaseMonitores : TStrings;
		function TipoReferenciaMonitor(descClase : String) : TClaseReferenciaMonitor;
	end;

var
	InfoMonitores : TListaInfoMonitores;

procedure AlInicio;
procedure AlFinal;

implementation

//------------------------
// Métodos de TInfoMonitor
//========================

Constructor TInfoMonitor.Create(xtipoMonitor : TClaseReferenciaMonitor; xdescClase : String; xeditor : TClaseEditorMonitor);
begin
	inherited Create;
	tipoMonitor := xtipoMonitor;
	descClase := xdescClase;
	editor := xeditor;
end;

//-------------------------------
// Métodos de TListaInfoMonitores
//===============================

function TListaInfoMonitores.getTipoEditor(tipo : TClass) : TClaseEditorMonitor;
var
	i : Integer;
	encontre : boolean;
	resultado : TClaseEditorMonitor;
begin
	encontre := false;
	resultado := NIL;
	for i := 0 to Count -1 do
		if TInfoMonitor(items[i]).tipoMonitor = tipo then
			begin
			resultado := TInfoMonitor(items[i]).editor;
			encontre := true;
			break;
			end;
	if not encontre then
		raise Exception.Create('Editor no registrado para la clase ' + tipo.ClassName)
	else
		Result := resultado;
end;

function TListaInfoMonitores.getTipoEditor(descClase : String) : TClaseEditorMonitor;
var
	i : Integer;
	encontre : boolean;
	resultado : TClaseEditorMonitor;
begin
	encontre := false;
	resultado := NIL;
	for i := 0 to Count -1 do
		if TInfoMonitor(items[i]).descClase = descClase then
			begin
			resultado := TInfoMonitor(items[i]).editor;
			encontre := true;
			break;
			end;
	if not encontre then
		raise Exception.Create('Editor no registrado para la clase ' + descClase)
	else
		result := resultado;
end;

function TListaInfoMonitores.descsClaseMonitores : TStrings;
var
	i : Integer;
	lista : TStrings;
begin
	lista := TStringList.Create;
	for i := 0 to Count -1 do
		lista.Add(TInfoMonitor(items[i]).descClase);
	result := lista;
end;

function TListaInfoMonitores.TipoReferenciaMonitor(descClase : String) : TClaseReferenciaMonitor;
var
	i, pos : Integer;
begin
	pos := -1;
	for i := 0 to Count - 1 do
		if TInfoMonitor(items[i]).descClase = descClase then
			begin
			pos := i;
			break;
			end;
	if pos <> -1 then
		result := TInfoMonitor(items[i]).tipoMonitor
	else
		raise Exception.Create('Referencia de monitor no registrada: ' + descClase);
end;

procedure AlInicio;
begin
	InfoMonitores := TListaInfoMonitores.Create;
end;

procedure AlFinal;
var
	i : Integer;
begin
	for i := 0 to InfoMonitores.Count -1 do
		TInfoMonitor(InfoMonitores[i]).Free;
	InfoMonitores.Free;
end;

end.
