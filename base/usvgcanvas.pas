unit usvgcanvas;
//mirar ADME/POSTOPERATIVO/utestsvg

{$mode delphi}

interface

uses
  Classes, types, SysUtils, DOM, XMLWrite;

type

  TColor = cardinal;
  TSVGPenStyle = (psSolid, psDash, psDot, psDashDot, psDashDotDot,
    psinsideFrame, psPattern, psClear);
  TSVGBrushStyle = (bsSolid, bsClear, bsHorizontal, bsVertical, bsFDiagonal,
    bsBDiagonal, bsCross, bsDiagCross, bsImage, bsPattern);

  TFPJPEGCompressionQuality = 1..100;   // 100 = best quality, 25 = pretty awful


const
  CFont_Alto = 1.8;//2; // ajustar
  CFont_Ancho = 0.6;//0.8; // ajustar

  // The following colors match the predefined Delphi Colors

const
  // standard colors
  clBlack = TColor($000000);
  clMaroon = TColor($000080);
  clGreen = TColor($008000);
  clOlive = TColor($008080);
  clNavy = TColor($800000);
  clPurple = TColor($800080);
  clTeal = TColor($808000);
  clGray = TColor($808080);
  clSilver = TColor($C0C0C0);
  clRed = TColor($0000FF);
  clLime = TColor($00FF00);
  clYellow = TColor($00FFFF);
  clBlue = TColor($FF0000);
  clFuchsia = TColor($FF00FF);
  clAqua = TColor($FFFF00);
  clLtGray = TColor($C0C0C0); // clSilver alias
  clDkGray = TColor($808080); // clGray alias
  clWhite = TColor($FFFFFF);
  StandardColorsCount = 16;

  // extended colors
  clMoneyGreen = TColor($C0DCC0);
  clSkyBlue = TColor($F0CAA6);
  clCream = TColor($F0FBFF);
  clMedGray = TColor($A4A0A0);

  ExtendedColorCount = 4;

   // special colors
  clNone = TColor($1FFFFFFF);
  clDefault = TColor($20000000);


type

  { TSVGPen }

  TSVGPen = class
    color: TColor;
    Width: integer;
    style: TSVGPenStyle;
    constructor Create;
  end;

  { TSVGBrush }

  TSVGBrush = class
    color: TColor;
    style: TSVGBrushStyle;
    constructor Create;
  end;

  { TSVGFont }

  TSVGFont = class
    size: integer;
    orientation: integer;
    color: Tcolor;
    constructor Create;
  end;

  { TSVGCanvas }

  TSVGCanvas = class
  private
    clipRect_cnt: integer;

    xdoc: TXMLDocument;
    NodoSVG: TDOMElement;
  public
    Width, Height: integer;
    pen: TSVGPen;
    brush: TSVGBrush;
    Font: TSVGFont;
    penPos: TPoint;
    clipping: boolean;

    constructor Create(Width, Height: integer);
    procedure ClipRect(x1, y1, x2, y2: integer);
    destructor Destroy; override;
    procedure wr(s: string);
    procedure Line(x1, y1, x2, y2: integer);
    procedure Polyline(const Points: array of TPoint;
      StartIndex: integer = 0; NumPts: integer = -1);
    procedure Ellipse(x1, y1, x2, y2: integer);
    procedure Rectangle(x1, y1, x2, y2: integer);
    function FillRect(x1, y1, x2, y2: integer): integer;
    procedure Polygon(r: array of TPoint);
    procedure MoveTo(x, y: integer);
    procedure LineTo(x, y: integer);
    function TextExtent(const Text: string): TSize;
    function TextHeight({%H-}s: string): integer;
    function TextWidth(s: string): integer;
    procedure TextOut(x, y: integer; texto: string);

    procedure WriteToArchi(archi: string);

    //function GetClipRect: TRect;
    //function GetClipRect: int64;
    //procedure SetClipRect( id: int64 );
    //property ClipRect: TRect read GetClipRect write SetClipRect;
    //property ClipRect: int64 read GetClipRect write SetClipRect;

  end;

function RGBToColor(R, G, B: byte): TColor;
function ColorToRGB(color: TColor): integer;

function ColorToString(Color: TColor): ansistring;
function StringToColor(const S: shortstring): TColor;

implementation


function ColorToString(Color: TColor): ansistring;
begin
  Result := '$' + HexStr(Color, 8);
end;

function apodoToHexa(const s: shortstring): shortstring;
var
  ts: shortstring;

begin
  ts := LowerCase(s);
  if pos('cl', ts) <> 1 then
    Result := s
  else if ts = 'clblack' then
    Result := '$000000'
  else if ts = 'clmaroon' then
    Result := '$000080'
  else if ts = 'clgreen' then
    Result := '$008000'
  else if ts = 'clolive' then
    Result := '$008080'
  else if ts = 'clnavy' then
    Result := '$800000'
  else if ts = 'clpurple' then
    Result := '$800080'
  else if ts = 'clteal' then
    Result := '$808000'
  else if ts = 'clgray' then
    Result := '$808080'
  else if ts = 'clsilver' then
    Result := '$C0C0C0'
  else if ts = 'clred' then
    Result := '$0000FF'
  else if ts = 'cllime' then
    Result := '$00FF00'
  else if ts = 'clyellow' then
    Result := '$00FFFF'
  else if ts = 'clblue' then
    Result := '$FF0000'
  else if ts = 'clfuchsia' then
    Result := '$FF00FF'
  else if ts = 'claqua' then
    Result := '$FFFF00'
  else if (ts = 'clltgray') or (ts = 'clsilver') then
    Result := '$C0C0C0'
  else if (ts = 'cldkgray') or (ts = 'clgray') then
    Result := '$808080'
  else if ts = 'clwhite' then
    Result := '$FFFFFF'
  else if ts = 'clmoneygreen' then
    Result := '$C0DCC0'
  else if ts = 'clskyblue' then
    Result := '$F0CAA6'
  else if ts = 'clcream' then
    Result := '$F0FBFF'
  else if ts = 'clmedgray' then
    Result := '$A4A0A0'
  else if ts = 'clnone' then
    Result := '$1FFFFFFF'
  else if ts = 'cldefault' then
    Result := '$20000000'
  else
    Result := s;
end;

function StringToColor(const S: shortstring): TColor;
var
  ts: shortstring;
begin
  ts := apodoToHexa(s);
  Result := TColor(StrToInt(ts));
end;



{ TSVGPen }

constructor TSVGPen.Create;
begin
  inherited Create;
  color := clBlack;
  style := psSolid;
  Width := 1;

end;

{ TSVGBrush }

constructor TSVGBrush.Create;
begin
  inherited Create;
  color := clBlack;
  style := bsSolid;
end;

{ TSVGFont }

constructor TSVGFont.Create;
begin
  inherited Create;
  size := 12;
  orientation := 0;
  color := clBlack;
end;



//function TSVGCanvas.GetClipRect: TRect;
//begin
// result:= rClipRect;
//end;

//procedure TSVGCanvas.SetClipRect(id: int64);
//begin
// clipRect_cnt:=id;

// //rchSetClipRect
// //rClipRect:= r;
// //inc( clipRect_cnt );
//end;


//procedure TSVGCanvas.SetClipRect(AValue: TRect);
//  var
//    NodoRect: TDOMElement;
//    NodoClip: TDOMElement;
//    ancho: Int64;
//    alto: Int64;
//  begin

//    NodoClip := xdoc.CreateElement('clipPath');
//    Result := clipRect_cnt + 1 ;
//    TDOMElement(NodoClip).SetAttribute('id', 'Clip' + IntToStr(Result));       // crear los atributos del nodo padre

//    NodoRect := xdoc.CreateElement('rect');

//    ancho:= round(abs(x2-x1));
//    alto := round(abs(y2-y1));

//    TDOMElement(NodoRect).SetAttribute('x', IntToStr(x1));       // crear los atributos del nodo padre
//    TDOMElement(NodoRect).SetAttribute('y', IntToStr(y1));       // crear los atributos del nodo padre
//    TDOMElement(NodoRect).SetAttribute('width', IntToStr(ancho));       // crear los atributos del nodo padre
//    TDOMElement(NodoRect).SetAttribute('height', IntToStr(alto));       // crear los atributos del nodo padre

//    estilo := '; fill: #' + IntToHex(clWhite, 6) + ' ;';
//    TDOMElement(NodoRect).SetAttribute('style', estilo);       // crear los atributos del nodo padre

//    NodoClip.AppendChild(NodoRect);
//    NodoSVG.Appendchild(NodoClip);                          // guardar nodo padre

//end;


constructor TSVGCanvas.Create(Width, Height: integer);
begin
  inherited Create;
  xdoc := TXMLDocument.Create;

  //creo el documento
  NodoSVG := xdoc.CreateElement('svg');               //crear el nodo SVG
  TDOMElement(NodoSVG).SetAttribute('xmlns', 'http://www.w3.org/2000/svg');
  // crear los atributos del nodo padre
  TDOMElement(NodoSVG).SetAttribute('width', IntToStr(Width));
  // crear los atributos del nodo padre
  TDOMElement(NodoSVG).SetAttribute('height', IntToStr(Height));
  // crear los atributos del nodo padre
  xdoc.Appendchild(NodoSVG);                          // guardar nodo raíz

  clipRect_cnt := 0;

  //rchCreate
  //inherited Create;
  //self.width:= width;
  //self.height:= height;
  pen := TSVGPen.Create;
  brush := TSVGBrush.Create;
  Font := TSVGFont.Create;
  //clipRect_cnt:= 0;
end;

procedure TSVGCanvas.ClipRect(x1, y1, x2, y2: integer);
var
  NodoRect: TDOMElement;
  NodoClip: TDOMElement;
  ancho: int64;
  alto: int64;
  id: integer;
  estilo: string;
begin
  clipping := True;
  NodoClip := xdoc.CreateElement('clipPath');
  clipRect_cnt := clipRect_cnt + 1;
  id := clipRect_cnt;
  TDOMElement(NodoClip).SetAttribute('id', 'Clip' + IntToStr(id));
  // crear los atributos del nodo padre

  NodoRect := xdoc.CreateElement('rect');

  ancho := round(abs(x2 - x1));
  alto := round(abs(y2 - y1));

  TDOMElement(NodoRect).SetAttribute('x', IntToStr(x1));
  // crear los atributos del nodo padre
  TDOMElement(NodoRect).SetAttribute('y', IntToStr(y1));
  // crear los atributos del nodo padre
  TDOMElement(NodoRect).SetAttribute('width', IntToStr(ancho));
  // crear los atributos del nodo padre
  TDOMElement(NodoRect).SetAttribute('height', IntToStr(alto));
  // crear los atributos del nodo padre

  estilo := '; fill: #' + IntToHex(clWhite, 6) + ' ;';
  TDOMElement(NodoRect).SetAttribute('style', estilo);
  // crear los atributos del nodo padre

  NodoClip.AppendChild(NodoRect);
  NodoSVG.Appendchild(NodoClip);                          // guardar nodo padre

end;

destructor TSVGCanvas.Destroy;
begin
  pen.Free;
  brush.Free;
  Font.Free;
  NodoSVG.Free;
  xdoc.Free;
  inherited Destroy;
end;

procedure TSVGCanvas.wr(s: string);
begin
    { TODO : Implementar salida.
 }
end;


procedure TSVGCanvas.Line(x1, y1, x2, y2: integer);
var
  NodoLine: TDOMElement;
  estilo: string;
begin
  NodoLine := xdoc.CreateElement('line');

  TDOMElement(NodoLine).SetAttribute('x1', IntToStr(x1));
  // crear los atributos del nodo padre
  TDOMElement(NodoLine).SetAttribute('y1', IntToStr(y1));
  // crear los atributos del nodo padre
  TDOMElement(NodoLine).SetAttribute('x2', IntToStr(x2));
  // crear los atributos del nodo padre
  TDOMElement(NodoLine).SetAttribute('y2', IntToStr(y2));
  // crear los atributos del nodo padre
  estilo := '; fill: #' + IntToStr(ColorToRGB(pen.color)) +
    ' ; stroke: #' + IntToHex(ColorToRGB(pen.color), 6) +
    ' ; stroke-width: ' + IntToStr(pen.Width) + ' ;';

  case pen.style of
  psDash: estilo := estilo + '; stroke-dasharray: 3;1';
  psDot: estilo:= estilo +'; stroke-dasharray: 1;2';
  end;

  if clipping then
    estilo := estilo + '; clip-path: url(#Clip' + IntToStr(clipRect_cnt) + ') ;';
  TDOMElement(NodoLine).SetAttribute('style', estilo);
  // crear los atributos del nodo padre
  NodoSVG.Appendchild(NodoLine);                          // guardar nodo padre

  //rchLine
  // http://www.w3schools.com/svg/svg_line.asp
  //wr( '<line x1="0" y1="0" x2="200" y2="200" style="stroke:rgb(255,0,0);stroke-width:2" />' );
end;

procedure TSVGCanvas.Polyline(const Points: array of TPoint;
  StartIndex: integer; NumPts: integer);
var
  NodoLine: TDOMElement;
  s: string;
  k: integer;
  estilo: string;
begin
  NodoLine := xdoc.CreateElement('polyline');
  s := '';

  if NumPts = -1 then
    NumPts := High(Points);

  for k := StartIndex to NumPts do
  begin
    s := s + ' ' + IntToStr(Points[k].x) + ',' + IntToStr(Points[k].y);
  end;

  TDOMElement(NodoLine).SetAttribute('points', s);
  // crear los atributos del nodo padre
  estilo := '; fill: none' + ' ; stroke: #' + IntToHex(ColorToRGB(pen.color), 6) +
    ' ; stroke-width: ' + IntToStr(pen.Width) + ' ;';

  case pen.style of
  psDash: estilo := estilo + '; stroke-dasharray: 3;1';
  psDot: estilo:= estilo +'; stroke-dasharray: 1;2';
  end;

  if clipping then
    estilo := estilo + '; clip-path: url(#Clip' + IntToStr(clipRect_cnt) + ') ;';
  TDOMElement(NodoLine).SetAttribute('style', estilo);
  // crear los atributos del nodo padre
  NodoSVG.Appendchild(NodoLine);                          // guardar nodo padre

end;

procedure TSVGCanvas.Ellipse(x1, y1, x2, y2: integer);
var
  NodoElip: TDOMElement;
  ycentro, xcentro, xradio, yradio: int64;
  estilo: string;
begin
  NodoElip := xdoc.CreateElement('ellipse');

  xcentro := round((x1 + x2) / 2);
  ycentro := round((y1 + y2) / 2);
  xradio := round(abs(x2 - x1) / 2);
  yradio := round(abs(x2 - x1) / 2);

  TDOMElement(NodoElip).SetAttribute('cx', IntToStr(xcentro));
  // crear los atributos del nodo padre
  TDOMElement(NodoElip).SetAttribute('cy', IntToStr(ycentro));
  // crear los atributos del nodo padre
  TDOMElement(NodoElip).SetAttribute('rx', IntToStr(xradio));
  // crear los atributos del nodo padre
  TDOMElement(NodoElip).SetAttribute('ry', IntToStr(yradio));
  // crear los atributos del nodo padre
  estilo := '; fill: #' + IntToHex(ColorToRGB(brush.color), 6) +
    ' ; stroke: #' + IntToHex(ColorToRGB(pen.color), 6) + ' ; stroke-width: ' +
    IntToStr(pen.Width) + ' ;';
  if clipping then
    estilo := estilo + '; clip-path: url(#Clip' + IntToStr(clipRect_cnt) + ') ;';
  TDOMElement(NodoElip).SetAttribute('style', estilo);
  // crear los atributos del nodo padre

  NodoSVG.Appendchild(NodoElip);                          // guardar nodo padre
end;

procedure TSVGCanvas.Rectangle(x1, y1, x2, y2: integer);
begin
  FillRect(x1, y1, x2, y2);
end;

function TSVGCanvas.FillRect(x1, y1, x2, y2: integer): integer;
var
  NodoRect: TDOMElement;
  alto: int64;
  ancho: int64;
  estilo: string;

begin
  NodoRect := xdoc.CreateElement('rect');

  ancho := round(abs(x2 - x1));
  alto := round(abs(y2 - y1));

  TDOMElement(NodoRect).SetAttribute('x', IntToStr(x1));
  // crear los atributos del nodo padre
  TDOMElement(NodoRect).SetAttribute('y', IntToStr(y1{y1-alto}));
  // crear los atributos del nodo padre
  TDOMElement(NodoRect).SetAttribute('width', IntToStr(ancho));
  // crear los atributos del nodo padre
  TDOMElement(NodoRect).SetAttribute('height', IntToStr(alto));
  // crear los atributos del nodo padre

  estilo := '; fill: #' + IntToHex(ColorToRGB(brush.color), 6) +
    ' ; stroke: #' + IntToHex(ColorToRGB(pen.color), 6) + ' ; stroke-width: ' +
    IntToStr(pen.Width) + ' ;';
  if clipping then
    estilo := estilo + '; clip-path: url(#Clip' + IntToStr(clipRect_cnt) + ') ;';
  TDOMElement(NodoRect).SetAttribute('style', estilo);
  // crear los atributos del nodo padre

  NodoSVG.Appendchild(NodoRect);                          // guardar nodo padre

end;


procedure TSVGCanvas.Polygon(r: array of TPoint);
var
  NodoPoly: TDOMElement;
  k: integer;
  puntos: string;
  estilo: string;
begin
  NodoPoly := xdoc.CreateElement('polygon');

  puntos := '';
  for k := 0 to high(r) do
  begin
    puntos := puntos + ' ' + IntToStr(r[k].x) + ',' + IntToStr(r[k].y);
  end;

  TDOMElement(NodoPoly).SetAttribute('points', puntos);
  // crear los atributos del nodo padre
  estilo := '; fill: #' + IntToHex(ColorToRGB(brush.color), 6) +
    ' ; stroke: #' + IntToHex(ColorToRGB(pen.color), 6) + ' ; stroke-width: ' +
    IntToStr(pen.Width) + ' ;';
  if clipping then
    estilo := estilo + '; clip-path: url(#Clip' + IntToStr(clipRect_cnt) + ') ;';
  TDOMElement(NodoPoly).SetAttribute('style', estilo);
  // crear los atributos del nodo padre

  NodoSVG.Appendchild(NodoPoly);                          // guardar nodo padre

  //rchPolygon
  // http://www.w3schools.com/svg/svg_polygon.asp
  //wr( '<polygon points="200,10 250,190 160,210" style="fill:lime;stroke:purple;stroke-width:1" />' );
end;


procedure TSVGCanvas.MoveTo(x, y: integer);
begin
  penPos.x := x;
  penPos.y := y;
end;

procedure TSVGCanvas.LineTo(x, y: integer);
begin
  line(penPos.x, penPos.y, x, y);
  MoveTo(x, y);
end;

function TSVGCanvas.TextExtent(const Text: string): TSize;
begin
  Result.cx := TextHeight(Text);
  Result.cy := TextWidth(Text);
end;

function TSVGCanvas.TextHeight(s: string): integer;
begin
  Result := round(font.size * CFont_Alto);
end;

function TSVGCanvas.TextWidth(s: string): integer;
begin
  Result := round(font.size * CFont_Ancho * length(s));
end;


procedure TSVGCanvas.TextOut(x, y: integer; texto: string);
var
  NodoText: TDOMElement;
  //NodoCont: TDOMText;
  NodoG: TDOMElement;
  estilo: string;
  stext: string;
begin
  NodoText := xdoc.CreateElement('text');

  TDOMElement(NodoText).SetAttribute('x', IntToStr(x));
  // crear los atributos del nodo padre
  TDOMElement(NodoText).SetAttribute('y', IntToStr(y));
  // crear los atributos del nodo padre
  TDOMElement(NodoText).SetAttribute('transform', 'rotate( -' + IntToStr(
    round(font.orientation / 10)) + ' ' + IntToStr(x) + ',' + IntToStr(y) + ')');
  // crear los atributos del nodo padre
  estilo := '; fill: #' + IntToHex(ColorToRGB(font.color), 6) + ' ;';
  TDOMElement(NodoText).SetAttribute('style', estilo);
  // crear los atributos del nodo padre

  stext := Utf8ToAnsi(texto);// UTF8ToSys(texto);
  NodoText.TextContent := stext;

  if clipping then
  begin
    NodoG := xdoc.CreateElement('g');
    TDOMElement(NodoG).SetAttribute('style', '; clip-path: url(#Clip' +
      IntToStr(clipRect_cnt) + ') ;');
    NodoG.Appendchild(NodoText);
    NodoSVG.Appendchild(NodoG);
    exit;
  end
  else
    NodoSVG.Appendchild(NodoText);                          // guardar nodo padre
  //NodoSVG.ChildNodes.Item[0].AppendChild(NodoText);       // insertar el nodo hijo en el correspondiente nodo padre

  //rchTextOut
  // http://www.w3schools.com/svg/svg_text.asp
  //wr( '<text x="0" y="15" fill="red" transform="rotate(30 20,40)">I love SVG</text>' );
end;

procedure TSVGCanvas.WriteToArchi(archi: string);
begin
  writeXMLFile(self.xdoc, archi); // escribir el XML
end;

//function TSVGCanvas.GetClipRect: int64;
//begin
//     result:=clipRect_cnt;
//end;

function RGBToColor(R, G, B: byte): TColor;
begin
  Result := (B shl 16) or (G shl 8) or R;
end;

function ColorToRGB(color: TColor): integer;
var
  red, green, blue: integer;
begin
  red := (color and $000000ff) shl 16;//*65536;
  green := (color and $0000ff00);
  blue := (color and $00ff0000) shr 16;//div 65536;
  Result := red + green + blue;
end;

end.
