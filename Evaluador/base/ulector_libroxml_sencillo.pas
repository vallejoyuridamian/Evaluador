unit ulector_libroxml_sencillo;
(***

 lector sencillo de Libros Excel en formato xml

***)
{$mode delphi}

interface

uses
  Classes, SysUtils, XMLRead, DOM;


type
  TXML_Hoja = class
    nombre: string;
    filas: Tlist;
    constructor Create( nodo: TDOMNode; xNombre: string  );
    procedure Free;

    // retorna cantidad de filas de la hoja
    function nFilas: integer;

    // retorna la cantidad de columnas de la fila más larga
    function nColumnas: integer;

    // retorna el contenido de la celca kFila, jCol con
    // kFila = [1..nFilas] y jCol = [1..nColumnas]
    function GetVal( kFila, jCol: integer ): string;
     (*
    // retorna el número de fila que tiene el texto en la columna iCol
    // comenzando a buscar desde la fila iFilDesde
    function FindFilaByCol( iCol: integer; texto: String; iFildesde: integer = 1 ): integer;
    *)
  end;

  TXML_Fila = class( TStringList )
    constructor Create( nodo: TDOMNode );
    procedure Free;
  end;

  TXML_Libro = class
    Hojas: TList;
    constructor Create ( archi: string );
    procedure Free;

    // retorna la cantidad de Hojas del Libro
    function nHojas: integer;

    // retorna la Hoja Nro iHoja con iHoja = [1..nHojas]
    function GetHojaByi(iHoja: integer): TXML_Hoja;

    // retonra la Hoja dado el nombre. Si no encuentra retorna NIL.
    function GetHojaByName( NombreHoja: string ): TXML_Hoja;
  end;



implementation

constructor TXML_Libro.Create ( archi: string );
var
  doc: TXMLDocument;
  k: integer;
  Nodo: TDOMNode;
  hoja: TXML_Hoja;
begin
  inherited Create;
  doc:= TXMLDocument.Create;
  ReadXMLFile( doc, archi );
  hojas:= TList.Create;
  for k:= 0 to doc.DocumentElement.ChildNodes.Count-1 do
  begin
    Nodo:= doc.DocumentElement.ChildNodes.Item[k];
    if Nodo.NodeName = 'Worksheet' then
    begin
      hoja:= TXML_Hoja.Create( Nodo.ChildNodes.Item[0], Nodo.Attributes.GetNamedItem('ss:Name').NodeValue );
      hojas.add( hoja );
    end;
  end;
  doc.Free;
end;


// retorna la cantidad de Hojas del Libro
function TXML_Libro.nHojas: integer;
begin
  result:= hojas.count;
end;

// retorna la Hoja Nro iHoja con iHoja = [1..nHojas]
function TXML_Libro.GetHojaByi( iHoja: integer ): TXML_Hoja;
begin
  result:= hojas[iHoja-1];
end;

// retonra la Hoja dado el nombre. Si no encuentra retorna NIL.
function TXML_Libro.GetHojaByName( NombreHoja: string ): TXML_Hoja;
var
  i: integer;
  buscando: boolean;
  aHoja: TXML_Hoja;
begin
  i:= 0;
  buscando:= true;
  while buscando and ( i < hojas.Count ) do
  begin
    aHoja:= hojas[i];
    if aHoja.Nombre = NombreHoja then
       buscando:= false
    else
       inc( i );
  end;
  if buscando then
   result:= nil
  else
   result:= aHoja;
end;

procedure TXML_Libro.Free;
var
  k: integer;
begin
  for k:= 0 to hojas.count -1 do
   TXML_Hoja( Hojas.items[k] ).Free;
  hojas.free;
  inherited Free;
end;


constructor TXML_Hoja.Create( nodo: TDOMNode; xNombre: string  );
var
  k: integer;
  fila: TXML_Fila;
  aNodo: TDOMNode;
begin
  inherited Create;
  filas:= TList.Create;
  nombre:= xNombre;
  for k:= 0 to Nodo.ChildNodes.Count-1 do
  begin
    aNodo:= Nodo.ChildNodes.Item[k];
    if aNodo.NodeName = 'Row' then
    begin
      Fila:= TXML_Fila.Create( aNodo );
      Filas.add( Fila );
    end;
  end;
end;

function TXML_Hoja.nFilas: integer;
begin
  result:= filas.Count;
end;

function TXML_Hoja.nColumnas: integer;
var
  k: integer;
  maxN, n: integer;
begin
  maxN:= 0;
  for k:= 0 to filas.count - 1 do
  begin
    n:= TXML_Fila( filas[k] ).Count;
    if n > maxN then
      maxN:= n;
  end;
  result:= maxN;
end;

function TXML_Hoja.GetVal( kFila, jCol: integer ): string;
var
  aFila: TXML_Fila;
begin
  aFila:= filas[kFila-1];
  if jCol > aFila.Count then
    result:= ''
  else
    result:= aFila[ jCol - 1 ];

end;

 (*
function TXML_Hoja.FindFilaByCol( iCol: integer; texto: String; iFiladesde: integer = 1 ): integer;
var
  buscando: integer;
  iFila: integer;
begin
  iFila:= iFilaDesde - 1;
  buscando:= true;
  while buscando and (iFila < filas.count ) do
    if GetVal( ifila-1, jcol-1 ) = texto then
       buscando:= false
    else
      inc( iFila );

  if buscando then
   result:= -1
  else
    result:= iFila;
end;
   *)
procedure TXML_Hoja.Free;
var
  k: integer;
begin
  for k:= 0 to filas.Count -1 do
    TXML_Fila( filas.Items[k] ).Free;
  filas.Free;
  inherited Free;
end;

constructor TXML_Fila.Create( nodo: TDOMNode );
var
  k: integer;
  fila: TXML_Fila;
  aNodo: TDOMNode;
begin
  inherited Create;
  for k:= 0 to Nodo.ChildNodes.Count-1 do
  begin
    aNodo:= nodo.ChildNodes.Item[k]; // Cell
    aNodo:= aNodo.FirstChild; // Data
    aNodo:= aNodo.FirstChild; // #text
    if aNodo <> nil then
     add( aNodo.NodeValue )
    else
     add( '' );
  end;
end;

procedure TXML_Fila.Free;
begin
  inherited Free;
end;

end.

