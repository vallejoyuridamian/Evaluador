unit utrazosxy;

{$IFDEF FPC}
{$MODE Delphi}
{$ENDIF}
interface

uses
{$IFDEF FPC-LCL}
  LCLIntf, Menus, LResources, LCLType,
{$ELSE}
  Windows, jpeg, Menus,
  Messages,
{$ENDIF}
  SysUtils, Classes, Graphics,
  Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, ComCtrls, clipbrd;

const
  Paleta1: array[1..12] of TColor = (
    clBlack, clMaroon, clGreen, clOlive, clNavy,
    clPurple, clTeal, clGray, clRed, clLime, clBlue, clFuchsia);


type
  PPuntoXY = ^TPuntoXY;

  TPuntoXY = record
    x, y: double;
  end;

  TTrazoXY = class; // se define más adelante


  (*+doc TTipoMarquita especifica el tipo de marca que dibuja una Marquita
  -doc*)
  TTipoMarquita = (TM_Circulo, TM_Cuadrado, TM_Triangulo, TM_Rombo,
    TM_Cruz, TM_Cruz45, TM_Asterisco);

  (*+doc TMarquita, especifica un marcador aplicable a las series. Si los colores son pasados nil
  no se cambia el TPen del Canvas.
  -doc*)
  TMarquita = class
    tipo: TTipoMarquita;
    fg_color, bg_color: TColor;
    radio: integer;
    constructor Create(xTipo: TTipoMarquita; xfg_color, xbg_color: TColor;
      xradio: integer);
    procedure plot(c: TCanvas; xp, yp: integer);
    procedure Free;
  end;



(*+doc TOGxy, Objeto Gráfico xy
El el padre de los objetos desplegables en un canvas XY
-doc*)
  TOGxy = class
    cxy: TTrazoXY; // canvasXY
    nombre: string;
    Visible: boolean;

    marquita: TMarquita; // Destaque de los puntos. Aplicable a algunos

    constructor Create(canvasXY: TTrazoXY; nombre: string);
    procedure Replot; virtual;
    procedure Free; virtual;
  end;

(*+doc TSerie
 representa una serie de numeros. Tiene asociado un nombre, un color
 y se grafica contra la serie X del cxy asociado
 -doc*)
  TSerie = class(TOGxy)
    kPrimero, kSiguiente: integer;
    Color: TColor;
    xup, yup: integer;
    PenUP: boolean;
    y: array of double;
    circular: boolean;
    constructor Create(canvasXY: TTrazoXY; nombre: string;
      maxNPuntos: integer; MemoriaCircular: boolean; color: TColor);
    procedure Free; override;
    procedure nuevovalor(v: double); overload; virtual;
    procedure desligue;
    procedure limpiar; virtual;
    procedure Replot; override;
  end;

  TDAOfSerie = array of TSerie;

(*+doc TPoligonalxy
 -doc*)
  TPoligonalxy = class(TOGxy)
    Color: TColor;
    puntos: TList;
    cerrada: boolean;
    constructor Create(canvasXY: TTrazoXY; nombre: string; cerrada: boolean;
      color: TColor);
    procedure Free; override;
    procedure nuevoPunto(x, y: double);
    procedure nuevoPuntoAlInicio(x, y: double);
    procedure limpiar; virtual;
    procedure Replot; override;
  end;

 (*+doc TLabel
 -doc*)
  TLabelxy = class(TOGxy)
    texto: string;
    Color: TColor;
    size: integer;
    x, y: double;
    constructor Create(canvasXY: TTrazoXY; nombre: string; x, y: double;
      texto: string; FColor: TColor; FSize: integer);
    procedure Replot; override;
  end;

  // representa un conjunto de series en un rectángulo de un Canvas.
  TTrazoXY = class

    Nombre: string;

    x1, x2, y1, y2: double;

    sy: TDAOfSerie; // la cero es el eje x
    sx: TSerie;

    OGxyLst: TList;

    circular: boolean;

    c: TCanvas;

    px0, py0: integer;
    px1, py1: integer; // px1= px0+(w-1) ; py1= py0 +(h-1)
    w, h: integer; // ancho y alto del rectángulo graficable.

    cmx, cmy: double;

    xp: integer; // Posición actual del trazo en el eje x.
    // Es ingresada por PlotNuevo_x
    // Los siguientes PlotNuevo_y se grafican en cada serie
    // asociados al valor xp en las x.

    constructor Create(nombre: string; maxNPuntos: integer;
      MemoriaCircular: boolean; nombre_sx, nombre_sy1: string;
      color_sy1: TColor; x1, x2, y1, y2: double); overload;

    constructor Create(nombre: string; maxNPuntos: integer;
      MemoriaCircular: boolean; nombre_sx, nombre_sy1: string;
      color_sy1: TColor; x1, x2, y1, y2: double; nSeriesY: integer); overload;

    procedure PlotNuevo_x(x: double);
    procedure PlotNuevo_y(ks: integer; y: double);
    procedure RePlot;


    procedure SetCanvas(c: TCanvas; px0, py0, w, h: integer);

    function x2p(x: double): integer;
    function y2p(y: double): integer;

    function p2x(px: integer): double;
    function p2y(py: integer): double;

    procedure DrawClipLine(xp, yp, xpt, ypt: integer);

    procedure limpiarCanales;
    procedure desligueCanales;

    procedure Free;
  end;



  // es la ventana donde desplegar cosas.
  // tienen un objeto del tipo trazoxy.

  PfrmDllForm = ^TfrmDllForm;

  { TfrmDllForm }

  TfrmDllForm = class(TForm)
    Copiar1: TMenuItem;
    GuardarJPG1: TMenuItem;
    Panel1: TPanel;
    pb: TPaintBox;
    Splitter1: TSplitter;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    StatusBar1: TStatusBar;
    SaveDialog1: TSaveDialog;
    exportarXLS: TMenuItem;
    SaveDialog2: TSaveDialog;
    PopupMenu1: TPopupMenu;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure pbPaint(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure Copiar1Click(Sender: TObject);
    procedure pbMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure GuardarJPG1Click(Sender: TObject);
    procedure exportarXLSClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
  private
    { Private declarations }
    ColorBorde, ColorGrilla, ColorLinea0: TColor;
    NDivX, NDivY: integer;
    borde_on, GridX_on, GridY_on: boolean;
    xlabel_str, ylabel_str, zlabel_str, titulo_str: string;
    ColorFondoExterior: TColor;
    ColorTextoExterior: TColor;
    ColorFondoInterior: TColor;
    etiquetar_x: boolean;
    x1, x2: double;
    etiquetar_y: boolean;
    y1, y2: double;
    etiquetar_z: boolean;
    z1, z2: double;
    escribirNombresSeries: boolean;
    margen_sup, margen_inf, margen_der, margen_izq: integer;
    //    AltoM, AnchoM: integer;
    Titulo_FontSize, Labels_FontSize, Etiquetas_FontSize,
    NombresSeries_FontSize: integer;

  public
    { Public declarations }
    tr1: TTrazoXY;
    {$IFDEF FTRX_NILONCLOSE}
    nilOnClose: PfrmDllForm;
    {$ENDIF}
    hWndForClose: HWnd;
    MsgForClose: uint;
    wParamForClose: wParam;
    lParamForClose: lParam;
    forzarClose: boolean;

    procedure xlabel(str: string);
    procedure ylabel(str: string);
    procedure zlabel(str: string);
    procedure titulo(str: string);
    procedure Etiquetas_x(x1, x2: double);
    procedure Etiquetas_y(y1, y2: double);
    procedure Etiquetas_z(z1, z2: double);


    procedure dbj_xlabel;
    procedure dbj_ylabel;
    procedure dbj_zlabel;
    procedure dbj_titulo;
    procedure dbj_etiquetasx;
    procedure dbj_etiquetasy;
    procedure dbj_etiquetasz;

    procedure dbj_gridX;
    procedure dbj_gridY;
    procedure dbj_borde;
    //    procedure dbj_linea0;


    // crea el diagrama le fija y agrega dos series, una
    // que será la serie X y otra que es la serie 1 como la
    // primer serie Y.
    procedure CrearDiagramaXY(nombre: string; MaxNPuntos: integer;
      Circular: boolean; nombre_sx, nombre_sy1: string; color_sy1: TColor;
      x1, x2, y1, y2: double; NDivX, NDivY: integer); overload;

    procedure CrearDiagramaXY(nombre: string; MaxNPuntos: integer;
      Circular: boolean; nombre_sx, nombre_sy1: string; color_sy1: TColor;
      x1, x2, y1, y2: double; NDivX, NDivY: integer; nSeriesY: integer); overload;

    // agrega una nueva serie y retorna el id.
    function CrearSerieXY(nombre: string; maxNPuntos: integer;
      MemoriaCircular: boolean; color: TColor): integer; overload;

    function CrearSerieXY(nombre: string; maxNPuntos: integer;
      MemoriaCircular: boolean; color: TColor; tipoMarquita: TTipoMarquita;
      fg_color, bg_color: TColor; radio: integer): integer; overload;


    procedure SaveJPG(fn: string; b: TBitmap);
    procedure RegisterWinForClose(xhWndForClose: HWnd; xMsgForCLose: uint;
      xwParamForClose: wParam; xlParamForClose: lParam);
    procedure CloseForzado;
  end;

procedure Alert(s: string);

implementation

{$IFNDEF FPC-LCL}
{$R *.lfm}

{$ELSE}
  {$R *.lfm}
{$ENDIF}

procedure Alert(s: string);
begin
  ShowMessage(s);
end;




constructor TPoligonalxy.Create(canvasXY: TTrazoXY; nombre: string;
  cerrada: boolean; color: TColor);
begin
  inherited Create(canvasXY, nombre);
  self.Color := color;
  Self.cerrada := cerrada;
  puntos := TList.Create;
end;

procedure TPoligonalxy.Free;
begin
  Limpiar;
  puntos.Free;
  inherited Free;
end;

procedure TPoligonalxy.nuevoPunto(x, y: double);
var
  pPunto: PPuntoXY;
begin
  GetMem(pPunto, SizeOf(TPuntoXY));
  pPunto^.x := x;
  pPunto^.y := y;
  puntos.Add(pPunto);
end;

procedure TPoligonalxy.nuevoPuntoAlInicio(x, y: double);
var
  pPunto: PPuntoXY;
begin
  GetMem(pPunto, SizeOf(TPuntoXY));
  pPunto^.x := x;
  pPunto^.y := y;
  puntos.Insert(0, pPunto);
end;

procedure TPoligonalxy.limpiar;
var
  k: integer;
begin
  for k := 0 to Puntos.Count - 1 do
    FreeMem(puntos.items[k], SizeOf(TPuntoXY));
  puntos.Clear;
end;

procedure TPoligonalxy.replot;
var
  k: integer;
  xp, yp: integer;
  xup, yup: integer;
  pp: PPuntoXY;
begin
  if not Visible then
    exit;
  if puntos.Count = 0 then
    exit;

  pp := puntos[0];
  xup := cxy.x2p(pp^.x);
  yup := cxy.y2p(pp^.y);
{  xp:= xup;
  yp:= yup;}

  cxy.c.Pen.Color := color;

  for k := 1 to puntos.Count - 1 do
  begin
    pp := puntos[k];
    xp := cxy.x2p(pp^.x);
    yp := cxy.y2p(pp^.y);
    cxy.DrawClipLine(xup, yup, xp, yp);
    xup := xp;
    yup := yp;
  end;

  if cerrada then
  begin
    pp := puntos[0];
    xp := cxy.x2p(pp^.x);
    yp := cxy.y2p(pp^.y);
    cxy.DrawClipLine(xup, yup, xp, yp);
    //    xup:= xp;  yup:= yp;
  end;
end;


constructor TLabelxy.Create(canvasXY: TTrazoXY; nombre: string;
  x, y: double; texto: string; FColor: TColor; FSize: integer);
begin
  inherited Create(canvasXY, nombre);
  self.x := x;
  self.y := y;
  self.texto := texto;
  self.Color := fcolor;
  self.size := fsize;
end;

procedure TLabelxy.replot;
var
  xp, yp: integer;
begin
  cxy.c.Font.Size := Size;
  cxy.c.Font.Color := color;
  xp := cxy.x2p(x);
  yp := cxy.y2p(y);
  cxy.c.TextOut(xp, yp, texto);
end;




constructor TOGxy.Create(canvasXY: TTrazoXY; nombre: string);
begin
  inherited Create;
  Visible := True;
  Self.cxy := canvasxy;
  Self.nombre := nombre;
  cxy.OGxyLst.Add(self);
  marquita := nil;
end;

procedure TOGxy.RePlot;
begin
end;

procedure TOGxy.Free;
var
  i: integer;
begin
  i := cxy.OGxyLst.IndexOf(self);
  if i >= 0 then
    cxy.OGxyLst.Delete(i);
  if marquita <> nil then
    FreeAndNil(marquita);

  inherited Free;
end;


(*
procedure TfrmDllForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin

   if (not ForzarClose) and (hWndForClose <> 0) then
   begin
//   showmessage( 'WParam: '+IntToStr( wParamForClose )+' LParam: '+intToStr( LParamForClose ) );
      if PostMessage(
         hWndForClose,
         MsgForCLose,
         wParamForClose,
         lParamForClose ) then
         begin
            Action:= caMinimize;
            exit;
         end;
      // si falló el envio del mensaje dejo que siga y la cierre.
   end;


   Action := caFree;

  if nilOnClose<> nil then
   begin
          nilOnClose^:= nil;
      nilOnClose:= nil;
   end;
  // liberar los trazos creados
  tr1.Free;
end;
*)

procedure TfrmDllForm.RegisterWinForClose(xhWndForClose: HWnd;
  xMsgForCLose: uint; xwParamForClose: wParam; xlParamForClose: lParam);
begin
  hWndForClose := xhWndForClose;
  MsgForCLose := xMsgForCLose;
  wParamForClose := xwParamForClose;
  lParamForClose := xlParamForClose;
end;

procedure TfrmDllForm.CloseForzado;
begin
  ForzarClose := True;
  Self.Close;
end;


(**** OBSOLETO

function CreateAngledFont(Font: HFont; Angle: longint;
  Quality: byte = PROOF_QUALITY): HFont;
var
{$IFDEF VER200}
  //Delphi 2009
  FontInfo: TLogFontW;    // Font information structure
{$ELSE}
{$IFDEF VER210}
  //Delphi 2010
  FontInfo: TLogFontW;    // Font information structure
{$ELSE}
{$IFDEF VER220}
  //Delphi XE
  FontInfo: TLogFontW;    // Font information structure
{$ELSE}
  FontInfo: TLogFontA;
{$ENDIF}
{$ENDIF}
{$ENDIF}
begin
  // Get the information of the font passed as parameter
  if GetObject(Font, SizeOf(FontInfo), @FontInfo) = 0 then
  begin
    Result := 0;
    exit;
  end;
  // Set the angle
  FontInfo.lfEscapement := Angle;
  FontInfo.lfOrientation := Angle;
  // Set the quality
  FontInfo.lfQuality := Quality;
  // Create a new font with the modified information
  // The new font must be released calling DeleteObject
  Result := CreateFontIndirect(FontInfo);
end;


procedure TextOutA(Canvas: TCanvas; X, Y, Angle: integer; Text: string);
var
  OriginalFont, AngledFont: HFont;
begin
  // Create an angled font from the current font
  AngledFont := CreateAngledFont(Canvas.Font.Handle, Angle);
  if AngledFont <> 0 then
  begin
    // Set it temporarily as the current font
    OriginalFont := SelectObject(Canvas.Handle, AngledFont);
    if OriginalFont <> 0 then
    begin
      // Write the text
      Canvas.TextOut(X, Y, Text);
      // Restore the original font
      if SelectObject(Canvas.Handle, OriginalFont) = 0 then
      begin
        Canvas.Font.Handle := AngledFont;
        // raise Exception.Create('Couldn''t restore font');
        exit;
      end;
    end;
    // Release the angled font
    DeleteObject(AngledFont);
  end;
end;
***)

procedure TextOutA(Canvas: TCanvas; X, Y, Angle: integer; Text: string);
var
  org_angle: integer;
begin
  org_angle := Canvas.Font.orientation;
  Canvas.Font.orientation := Angle;
  Canvas.TextOut(X, Y, Text);
  Canvas.Font.orientation := org_angle;
end;


constructor TSerie.Create(canvasXY: TTrazoXY; nombre: string;
  maxNPuntos: integer; MemoriaCircular: boolean; color: TColor);
begin
  inherited Create(canvasxy, nombre);
  circular := MemoriaCircular;
  Visible := True;
(*** rch@080708 comento esto para ver si cuando es circular funciona el resize
  if circular then
    setlength( y, maxNPuntos )
  else

*****)
  setlength(y, maxNPuntos + 1);
  Self.Color := Color;
  limpiar;
end;

procedure TSerie.Free;
begin
  setlength(y, 0);
  inherited Free;
end;

procedure TSerie.limpiar;
begin
  desligue;
  kPrimero := 0;
  kSiguiente := 0;
  xup := 0;
  yup := 0;
end;

procedure TSerie.desligue;
begin
  PenUP := True;
end;


procedure TSerie.NuevoValor(v: double);
begin
  y[kSiguiente] := v;
  kSiguiente := (kSiguiente + 1) mod length(y);
  if kSiguiente = kPrimero then
    if circular then
      kPrimero := (kPrimero + 1) mod length(y)
    else
      raise Exception.Create('TSerie : ' + Nombre + ' Sobreescritura de la memoria');
end;

procedure TSerie.Replot;
var
  k: integer;
  xp, yp: integer;
  xup, yup: integer;
  kHasta: integer;

begin
  if not Visible then
    exit;
  if kPrimero = kSiguiente then
    exit;
  kHasta := kSiguiente - 1;
  if kHasta < 0 then
    kHasta := high(y);

  xup := cxy.x2p(cxy.sx.y[cxy.sx.kPrimero]);
  yup := cxy.y2p(y[kPrimero]);
{  xp:= xup;
  yp:= yup;}

  cxy.c.Pen.Color := color;
  if kHasta > kPrimero then
  begin
    for k := kPrimero to kSiguiente - 1 do
    begin
      xp := cxy.x2p(cxy.sx.y[k]);
      yp := cxy.y2p(y[k]);
      cxy.DrawClipLine(xup, yup, xp, yp);
      xup := xp;
      yup := yp;
      if marquita <> nil then
        marquita.plot(cxy.c, xp, yp);
    end;
  end
  else
  begin
    for k := kPrimero to high(y) do
    begin
      xp := cxy.x2p(cxy.sx.y[k]);
      yp := cxy.y2p(y[k]);
      cxy.DrawClipLine(xup, yup, xp, yp);
      xup := xp;
      yup := yp;
      if marquita <> nil then
        marquita.plot(cxy.c, xp, yp);
    end;
    for k := 0 to kHasta do
    begin
      xp := cxy.x2p(cxy.sx.y[k]);
      yp := cxy.y2p(y[k]);
      cxy.DrawClipLine(xup, yup, xp, yp);
      xup := xp;
      yup := yp;
      if marquita <> nil then
        marquita.plot(cxy.c, xp, yp);
    end;
  end;
{  xup:= xp;
  yup:= yp;}
end;

constructor TTrazoXY.Create(nombre: string; maxNPuntos: integer;
  MemoriaCircular: boolean; nombre_sx, nombre_sy1: string; color_sy1: TColor;
  x1, x2, y1, y2: double);
begin
  Create(nombre, maxNPuntos, MemoriaCircular, nombre_sx, nombre_sy1,
    color_sy1, x1, x2, y1, y2, 10);
end;

constructor TTrazoXY.Create(nombre: string; maxNPuntos: integer;
  MemoriaCircular: boolean; nombre_sx, nombre_sy1: string; color_sy1: TColor;
  x1, x2, y1, y2: double; nSeriesY: integer);
var
  k: integer;
begin
  Self.Nombre := nombre;
  Self.x1 := x1;
  Self.x2 := x2;
  Self.y1 := y1;
  Self.y2 := y2;
  circular := MemoriaCircular;
  c := nil;
  cmx := 0;
  cmy := 0;
  OGxyLst := TList.Create;

  setlength(sy, nSeriesY + 1); // iniciamos lugar para nSeriesY y el x
  sy[0] := TSerie.Create(Self, nombre_sx, MaxNPuntos, MemoriaCircular, clblack);
  sy[1] := TSerie.Create(Self, nombre_sy1, MaxNPuntos, MemoriaCircular, color_sy1);
  for k := 2 to high(sy) do
    sy[k] := nil; // serie libre

  sx := sy[0];
  sx.Visible := False; // hacemos que la serie x no sea ploteable
end;

procedure TTrazoXY.limpiarCanales;
var
  k: integer;
begin
  for k := 0 to high(sy) do
    if sy[k] <> nil then
      sy[k].limpiar;
end;

procedure TTrazoXY.desligueCanales;
var
  k: integer;
begin
  for k := 0 to high(sy) do
    if sy[k] <> nil then
      sy[k].desligue;
end;

procedure TTrazoXY.Free;
var
  k: integer;
begin
  for k := 0 to high(sy) do
    if sy[k] <> nil then
      sy[k].Free;

  setlength(sy, 0);

  while OGxyLst.Count > 0 do
    TOgxy(Ogxylst.Items[0]).Free; // el mismo free saca el elemento de la lista.
  OGxylst.Free;
  inherited Free;
end;

function TTrazoXY.x2p(x: double): integer;
begin
  Result := trunc((x - x1) * cmx + 0.5 + px0);
end;

function TTrazoXY.y2p(y: double): integer;
begin
  Result := trunc(h - (y - y1) * cmy + 0.5 + py0);
end;


function TTrazoXY.p2x(px: integer): double;
begin
  Result := (px - px0) / cmx + x1;
end;

function TTrazoXY.p2y(py: integer): double;
begin
  Result := y1 + (h + py0 - py) / cmy;
end;


procedure TTrazoXY.PlotNuevo_x(x: double);
begin
  sy[0].nuevovalor(x);
  if assigned(c) then
  begin
    xp := x2p(x);
  end;
end;

function CohenSutherland(var x0, y0, x1, y1: integer;
  const xp1, yp1, xp2, yp2: integer): boolean;
var
  codP0, codP1: word;
  dp: integer;

  function PointCodify(x, y: integer): word;
  var
    cod: word;
  begin
    cod := 0;
    if x <= xp1 then
      cod := 1
    else if x >= xp2 then
      cod := 4;

    if y <= yp1 then
      cod := cod or 2
    else if y >= yp2 then
      cod := cod or 8;

    result := cod;
  end;

  procedure shortXY(var ax, ay: integer; bx, by: integer; codA: word);

    procedure shortY(x: integer);
    begin
      dp := (ax - bx);
      if dp > 0 then
        ay := by + trunc(((x - bx) * (ay - by)) / dp + 0.5)
      else
        ay := by; //????
      ax := x;
    end;

    procedure shortX(y: integer);
    begin
      dp := (ay - by);
      if dp > 0 then
        ax := bx + trunc(((y - by) * (ax - bx)) / (ay - by) + 0.5)
      else
        ax := bx; //??
      ay := y;
    end;

  begin
(***

  if (codA and 1)<>0 then
      shortY( xp1)
  else if (codA and 4)<>0 then
      shortY(xp2)
  else if (codA and 2)<>0 then
      shortX(yp1)
  else if (codA and 8)<>0 then
      shortX(yp2);

*************)
    if (codA and 1) <> 0 then
      shortY(xp1)
    else if (codA and 4) <> 0 then
      shortY(xp2);

    if (codA and 2) <> 0 then
      shortX(yp1)
    else if (codA and 8) <> 0 then
      shortX(yp2);
  end;

  function res: boolean;
  begin  {res}
    codP0 := pointCodify(x0, y0);
    codP1 := pointCodify(x1, y1);
    if (codP0 and codP1) = 0 then
      res := True
    else
    if (codP0 and codP1) <> 0 then
      res := False
    else
    begin
      if codP0 > 0 then
        shortXY(x0, y0, x1, y1, codP0)
      else
        shortXY(x1, y1, x0, y0, codP1);
      Result := res; // en esta recursión recodica y acota si es necesario el otro punto
    end;
  end; {res}

begin {ClipLine}
  Result := res;
end; {ClipLine}

procedure TTrazoXY.DrawClipLine(xp, yp, xpt, ypt: integer);
var
  Visible: boolean;
begin
  Visible := CohenSutherland(xp, yp, xpt, ypt, px0, py0, px1, py1);
  // decía px1-1 y py1-1
  if not Visible then
    exit;
  c.MoveTo(xp, yp);
  c.LineTo(xpt, ypt);
end;

procedure TTrazoXY.PlotNuevo_y(ks: integer; y: double);
var
  yp: integer;
  s: TSerie;
begin
  s := sy[ks];
  s.NuevoValor(y);
  if assigned(c) then
  begin
    yp := y2p(y);
    if s.PenUP then
    begin
      c.MoveTo(xp, yp);
      s.PenUp := False;
    end
    else
    begin
      c.Pen.Color := s.color;
      DrawClipLine(s.xup, s.yup, xp, yp);
    end;
    s.xup := xp;
    s.yup := yp;
    if s.marquita <> nil then
      s.marquita.plot(c, xp, yp);
  end;
end;

procedure TTrazoXY.RePlot;
var
  //  s: TSerie;
  ks: integer;
begin
  if not assigned(c) then
    exit;
(*
  for ks:=1 to high( sy ) do
  begin
    s:= sy[ks];
    if s <> nil then
      s.Replot;
  end;
  *)
  for ks := 0 to OGxyLst.Count - 1 do
    TOGxy(OGxyLst.items[ks]).Replot;

end;

procedure TTrazoXY.SetCanvas(c: TCanvas; px0, py0, w, h: integer);
begin
  Self.c := c;
  Self.px0 := px0;
  Self.py0 := py0;
  px1 := px0 + w - 1;
  py1 := py0 + (h - 1);
  Self.w := w;
  Self.h := h;

  if x2 <> x1 then
    cmx := w / (x2 - x1)
  else
    cmx := 0;
  if y2 <> y1 then
    cmy := h / (y2 - y1)
  else
    cmy := 0;
end;



procedure TfrmDllForm.dbj_borde;
begin
  borde_on := True;
  pb.Canvas.Pen.Color := ColorBorde;
  pb.Canvas.MoveTo(margen_izq, margen_sup);
  pb.Canvas.LineTo(pb.Width - margen_der - 1, margen_sup);
  pb.Canvas.LineTo(pb.Width - margen_der - 1, pb.Height - margen_inf - 1);
  pb.Canvas.LineTo(margen_izq, pb.Height - margen_inf - 1);
  pb.Canvas.LineTo(margen_izq, margen_sup);
end;

procedure TfrmDllForm.dbj_GridX;
var
  k: integer;
  dx: double;
  xp: integer;
begin
  GridX_on := True;
  dx := (pb.Width - margen_izq - margen_der) / NDivX;
  pb.Canvas.Pen.Color := ColorGrilla;
  for k := 1 to NDivX - 1 do
  begin
    xp := trunc(dx * k + 0.5 + margen_izq);
    pb.Canvas.MoveTo(xp, margen_sup);
    pb.Canvas.LineTo(xp, pb.Height - margen_inf);
  end;
end;


procedure TfrmDllForm.dbj_GridY;
var
  k: integer;
  dy: double;
  yp: integer;
begin
  GridY_on := True;
  dy := (pb.Height - margen_sup - margen_inf) / NDivY;
  pb.Canvas.Pen.Color := ColorGrilla;
  for k := 1 to NDivY - 1 do
  begin
    yp := trunc(dy * k + 0.5 + margen_sup);
    pb.Canvas.MoveTo(margen_izq, yp);
    pb.Canvas.LineTo(pb.Width - margen_der, yp);
  end;
end;

procedure TfrmDllForm.Button1Click(Sender: TObject);
begin
  pb.Canvas.MoveTo(0, 0);
  pb.Canvas.LineTo(pb.Width - 1, pb.Height - 1);
end;

procedure TfrmDllForm.Button2Click(Sender: TObject);
var
  k: integer;
begin
  dbj_GridX;
  dbj_GridY;
  //   tr1.SetCanvas( pb.Canvas, pb.Width, pb.Height );
  for k := 0 to 100 do
  begin
    tr1.PlotNuevo_x(k);
    tr1.PlotNuevo_y(1, 8 * sin(2 * pi * k / 100));
  end;
  dbj_borde;
end;

procedure TfrmDllForm.FormCreate(Sender: TObject);
var
  aux: integer;
begin
  NombresSeries_FontSize := 8;
  EscribirNombresSeries := True;
  Labels_FontSize := 10;
  Etiquetas_FontSize := 8;
  Titulo_FontSize := 14;
  ColorBorde := clDkGray;
  ColorGrilla := clLtGray;
  ColorLinea0 := clNavy;
  NDivX := 10;
  NDivY := 8;
  borde_on := False;
  GridX_on := False;
  GridY_on := False;
  xlabel_str := '';
  ylabel_str := '';
  zlabel_str := '';
  titulo_str := '';
  ColorFondoExterior := clWhite;
  ColorTextoExterior := clNavy;
  ColorFondoInterior := clWhite;
  Color := ColorFondoInterior;
  margen_sup := pb.Canvas.TextHeight('M') * 2;
  margen_izq := pb.Canvas.TextWidth('M') * 6;

  if escribirNombresSeries then
  begin
    aux := pb.Canvas.Font.Size;
    pb.Canvas.Font.Size := NombresSeries_FontSize;
    margen_sup := margen_sup + pb.Canvas.TextHeight('M') * 2;
    pb.Canvas.Font.Size := aux;
  end;

  margen_der := margen_izq;
  margen_inf := margen_der;

  tr1 := nil;
end;

procedure TfrmDLLForm.CrearDiagramaXY(nombre: string; MaxNPuntos: integer;
  Circular: boolean; nombre_sx, nombre_sy1: string; color_sy1: TColor;
  x1, x2, y1, y2: double; NDivX, NDivY: integer);
begin
  CrearDiagramaXY(nombre, MaxNPuntos, Circular, nombre_sx, nombre_sy1, color_sy1,
    x1, x2, y1, y2, NDivX, NDivY, 10);
end;

procedure TfrmDLLForm.CrearDiagramaXY(nombre: string; MaxNPuntos: integer;
  Circular: boolean; nombre_sx, nombre_sy1: string; color_sy1: TColor;
  x1, x2, y1, y2: double; NDivX, NDivY: integer; nSeriesY: integer);
begin
  {$IFDEF FTRX_NILONCLOSE}
  nilOnClose := nil;
  {$ENDIF}

  hWndForClose := 0;
  forzarClose := False;

  if tr1 <> nil then
    tr1.Free;
  Self.NDivX := NDivX;
  Self.NDivY := NDivY;

  tr1 := TTrazoXY.Create(Nombre, MaxNPuntos, Circular, nombre_sx,
    nombre_sy1, color_sy1, x1, x2, y1, y2, nSeriesY);
  tr1.SetCanvas(
    pb.canvas,
    margen_der, margen_sup,
    pb.Width - margen_izq - margen_der, pb.Height - margen_inf - margen_sup);
end;

function TfrmDLLForm.CrearSerieXY(nombre: string; maxNPuntos: integer;
  MemoriaCircular: boolean; color: TColor): integer;
var
  oldSeries: TDAOfSerie;
  buscando: boolean;
  k, n, i: integer;
begin
  n := length(tr1.sy);
  buscando := True;
  k := 2;
  while buscando do
    if tr1.sy[k] = nil then
      buscando := False
    else
      Inc(k);
  if k > n then
  begin
    oldSeries := tr1.sy;
    SetLength(tr1.sy, length(tr1.sy) + 1);
    for i := 0 to high(oldSeries) do
      tr1.sy[i] := oldSeries[i];
  end;
  tr1.sy[k] := TSerie.Create(tr1, nombre, maxNPuntos, MemoriaCircular, color);
  Result := k;
end;

function TfrmDLLForm.CrearSerieXY(nombre: string; maxNPuntos: integer;
  MemoriaCircular: boolean; color: TColor; tipoMarquita: TTipoMarquita;
  fg_color, bg_color: TColor; radio: integer): integer;
var
  kserie: integer;
begin
  kserie := CrearSerieXY(nombre, maxNPuntos, MemoriaCircular, color);
  tr1.sy[kserie].marquita := TMarquita.Create(tipoMarquita, fg_color, bg_color, radio);
  Result := kserie;
end;


procedure TfrmDllForm.pbPaint(Sender: TObject);
{var
  f: TExtFile;   }
begin
  //  assignfile( f, 'c:\basura\log.txt' );
  {$I-}
  //  append( f );
  {$I+}
  //  if ioresult <> 0 then
  //    rewrite(f);
  //  writeln(f,'-pbPaint-');  }


  if (xlabel_str <> '') or etiquetar_x then
  begin
    dbj_xlabel;
    dbj_EtiquetasX;
  end;
  if (ylabel_str <> '') or etiquetar_y then
  begin
    dbj_ylabel;
    dbj_EtiquetasY;
  end;
  if (zlabel_str <> '') or etiquetar_z then
  begin
    dbj_zlabel;
    dbj_EtiquetasZ;
  end;
  if Titulo_str <> '' then
    dbj_TItulo;

  if GridX_on then
    dbj_GridX;
  if GridY_on then
    dbj_GridY;

  //  writeln(f,'-RePlot-');
  //  closefile( f );

  tr1.RePlot;

  if borde_on then
    dbj_borde;
end;


procedure TfrmDllForm.xlabel(str: string);
begin
  xlabel_str := str;
  dbj_xlabel;
end;

procedure TfrmDllForm.ylabel(str: string);
begin
  ylabel_str := str;
  dbj_ylabel;
end;

procedure TfrmDllForm.zlabel(str: string);
begin
  zlabel_str := str;
  dbj_zlabel;
end;

procedure TfrmDllForm.titulo(str: string);
begin
  titulo_str := str;
  dbj_titulo;
end;


procedure TfrmDllForm.Button3Click(Sender: TObject);
begin
  titulo('Este es el título jyquin');
  xlabel(' ... xlabel ...cc');
  ylabel(' ... ylabel ...cc');
  zlabel(' ... zlabel ...cc');

  self.Etiquetas_x(-100, 200);
  self.Etiquetas_y(-100, 200);
  self.Etiquetas_z(-100, 200);
end;

procedure TfrmDllForm.FormResize(Sender: TObject);
begin
  if tr1 <> nil then
    Self.tr1.SetCanvas(
      pb.canvas,
      margen_der, margen_sup,
      pb.Width - margen_izq - margen_der, pb.Height - margen_inf - margen_sup);
end;

procedure TfrmDllForm.dbj_Titulo;
var
  xp, yp, i, titleHeight: integer;
  pto: TPoint;
  aux: string;
begin
  pb.Canvas.Brush.Color := ColorFondoExterior;
  pb.Canvas.FillRect(rect(0, 0, pb.Width - 1, margen_sup - 1));
  if Titulo_str <> '' then
  begin
    pb.Canvas.Font.Size := Titulo_FontSize;
    xp := (pb.Width - pb.Canvas.TextWidth(titulo_str)) div 2;
    //    yp:= (margen_sup - pb.Canvas.TextHeight( titulo_str ) ); //Lo que estaba originalmente
    yp := 5;
    pb.Canvas.TextOut(xp, yp, Titulo_str);
  end;
  if EscribirNombresSeries then
  begin
    titleHeight := 10 + pb.Canvas.TextHeight(titulo_str);
    pb.Canvas.Font.Size := NombresSeries_FontSize;

    aux := '';
    for i := 1 to high(tr1.sy) do
      if tr1.sy[i] <> nil then
      begin
        aux := aux + tr1.sy[i].nombre + '   ';
      end;
    aux := copy(aux, 0, length(aux) - 3); //para sacar los '   ' del final

    pb.Canvas.MoveTo((pb.Width - pb.Canvas.TextWidth(aux)) div 2, titleHeight);

    for i := 1 to high(tr1.sy) do
      if tr1.sy[i] <> nil then
      begin
        pb.Canvas.Font.Color := tr1.sy[i].Color;
        pto := pb.Canvas.PenPos;
        pb.Canvas.TextOut(pto.x, pto.y, tr1.sy[i].nombre + '   ');
      end;
  end;
end;

procedure TfrmDllForm.dbj_EtiquetasY;
var
  s: string;
  k: integer;
  y: double;
  dy: double;
  xp, yp: integer;
  dyp: double;
begin
  if etiquetar_y then
  begin
    pb.Canvas.Font.Size := Etiquetas_FontSize;
    dy := (y2 - y1) / NDivY;
    xp := pb.Canvas.TextHeight(ylabel_str);
    dyp := (pb.Height - margen_sup - margen_inf);
    for k := 0 to NDivY do
    begin
      y := y1 + k * dy;
      yp := trunc(margen_sup + dyp * (1 - k / NDivY) + 0.5);
      s := Format('%8.1f', [y]);
      pb.Canvas.TextOut(xp, yp, s);
    end;
  end;
end;

procedure TfrmDllForm.dbj_ylabel;
var
{  s: string;
  k: integer;
  y: double;
  dy: double;     }
  xp, yp: integer;
  //  dyp: double;

begin
  pb.Canvas.Brush.Color := ColorFondoExterior;
  pb.Canvas.FillRect(rect(0, 0, margen_izq - 1, pb.Height - 1));
  if ylabel_str <> '' then
  begin
    pb.Canvas.Font.Size := Labels_FontSize;
    xp := 0;
    yp := (pb.Height + pb.Canvas.TextWidth(ylabel_str)) div 2;
    TextOutA(pb.Canvas, xp, yp, 900, ylabel_str);
  end;
end;


procedure TfrmDllForm.dbj_EtiquetasX;
var
  s: string;
  k: integer;
  y: double;
  dy: double;
  xp, yp: integer;
  dyp: double;
begin
  if etiquetar_x then
  begin
    pb.Canvas.Font.Size := Etiquetas_FontSize;
    dy := (x2 - x1) / NDivX;
    xp := pb.Height - margen_inf;
    dyp := (pb.Width - margen_der - margen_izq);
    for k := 0 to NDivX do
    begin
      y := x1 + k * dy;
      yp := trunc(margen_izq + dyp * k / NDivX + 0.5);
      s := Format('%8.1f', [y]);
      TextOutA(pb.Canvas, yp, xp, -900, s);
    end;
  end;
end;

procedure TfrmDllForm.dbj_xlabel;
var
 {  s: string;
  y: double;
  dy: double;   }
  xp, yp: integer;
  //  dyp: double;
begin
  pb.Canvas.Brush.Color := ColorFondoExterior;
  pb.Canvas.FillRect(
    rect(0, pb.Height - margen_inf, pb.Width, pb.Height - 1));
  if xlabel_str <> '' then
  begin
    pb.Canvas.Font.Size := Labels_FontSize;
    xp := (pb.Width - pb.Canvas.TextWidth(xlabel_str)) div 2;
    yp := (pb.Height - pb.Canvas.TextHeight(xlabel_str));
    pb.Canvas.TextOut(xp, yp, xlabel_str);
  end;
end;



procedure TfrmDllForm.dbj_EtiquetasZ;
var
  s: string;
  k: integer;
  y: double;
  dy: double;
  xp, yp: integer;
  dyp: double;
begin
  if etiquetar_z then
  begin
    pb.Canvas.Font.Size := Etiquetas_FontSize;
    dy := (y2 - y1) / NDivY;
    xp := pb.Width - margen_der;
    dyp := (pb.Height - margen_inf - margen_sup);
    for k := 0 to NDivY do
    begin
      y := y1 + k * dy;
      yp := trunc(margen_sup + dyp * (1 - k / NDivY) + 0.5);
      s := Format('%8.1f', [y]);
      pb.Canvas.TextOut(xp, yp, s);
    end;
  end;
end;


procedure TfrmDllForm.dbj_zlabel;
var
 {  s: string;
   k: integer;
   y: double;
   dy: double;  }
  xp, yp: integer;
  //   dyp: double;

begin
  pb.Canvas.Brush.Color := ColorFondoExterior;
  pb.Canvas.FillRect(
    rect(pb.Width - margen_der, 0, pb.Width - 1, pb.Height - 1));
  if zlabel_str <> '' then
  begin
    pb.Canvas.Font.Size := Labels_FontSize;
    xp := (pb.Width);
    yp := (pb.Height - pb.Canvas.TextWidth(zlabel_str)) div 2;
    TextOutA(pb.Canvas, xp, yp, -900, zlabel_str);
  end;
end;




procedure TfrmDllForm.Etiquetas_x(x1, x2: double);
begin
  Self.x1 := x1;
  Self.x2 := x2;
  Self.etiquetar_x := True;
  dbj_xlabel;
  dbj_EtiquetasX;
end;

procedure TfrmDllForm.Etiquetas_y(y1, y2: double);
begin
  Self.y1 := y1;
  Self.y2 := y2;
  Self.etiquetar_y := True;
  dbj_ylabel;
  dbj_EtiquetasY;
end;

procedure TfrmDllForm.Etiquetas_z(z1, z2: double);
begin
  Self.z1 := z1;
  Self.z2 := z2;
  Self.etiquetar_z := True;
  dbj_zlabel;
  dbj_EtiquetasZ;
end;

procedure TfrmDllForm.SaveJPG(fn: string; b: TBitmap);
var
  jp: TJPEGImage;  //Requires the "jpeg" unit added to "uses" clause.

begin
  jp := TJPEGImage.Create;
  try
    jp.Assign(b);
    jp.SaveToFile(fn);
  finally
    jp.Free;
  end;
end;




procedure TfrmDllForm.Copiar1Click(Sender: TObject);
var
  b: TBitmap; // para copiar temporalmente la pantallita.

begin
  //first copy
  b := TBitmap.Create;
  try
    b.Width := pb.Width;
    b.Height := pb.Height;
    b.canvas.CopyRect(Rect(0, 0, b.Width, b.Height),
      pb.Canvas, Rect(0, 0, b.Width, b.Height));

    Clipboard.Assign(b)
  finally
    b.Free
  end;
end;


procedure TfrmDllForm.pbMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  if Button = mbRight then
  begin
    PopUpMenu1.Popup(self.left + pb.left + x, self.top + pb.top + y);
  end;
end;

procedure TfrmDllForm.GuardarJPG1Click(Sender: TObject);
var
  b: TBitmap; // para copiar temporalmente la pantallita.

begin

  //first copy
  b := TBitmap.Create;
  try
    b.Width := pb.Width;
    b.Height := pb.Height;
    b.canvas.CopyRect(Rect(0, 0, b.Width, b.Height),
      pb.Canvas, Rect(0, 0, b.Width, b.Height));

    if SaveDialog1.Execute then
      SaveJPG(SaveDialog1.filename, b);

  finally
    b.Free
  end;

end;

procedure TfrmDllForm.exportarXLSClick(Sender: TObject);
var
  f: textfile;
  k, j, nPuntos: integer;
begin
  if SaveDialog2.Execute then
  begin
    assignfile(f, SaveDialog2.filename);
    rewrite(f);
    writeln(f, 'serie', #9, 'nombre', #9, 'kPrimero', #9, 'kSiguiente');
    for k := 1 to high(tr1.sy) do
      if (tr1.sy[k] <> nil) then
        with tr1.sy[k] do
          writeln(f, k, #9, nombre, #9, kPrimero, #9, kSiguiente);


    writeln(f);

    for k := 1 to high(tr1.sy) do
      if (tr1.sy[k] <> nil) then
        Write(f, #9, tr1.sy[k].nombre);
    writeln(f);

    if tr1.sx.circular then
      nPuntos := high(tr1.sx.y)
    else
      nPuntos := high(tr1.sx.y) - 1;

    for j := 0 to nPuntos do
    begin
      Write(f, tr1.sx.y[j]);
      for k := 1 to high(tr1.sy) do
        if (tr1.sy[k] <> nil) then
          Write(f, #9, tr1.sy[k].y[j]);
      writeln(f);
    end;

    closefile(f);
  end;
end;

procedure TfrmDllForm.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin

  if (not ForzarClose) and (hWndForClose <> 0) then
  begin
    //   showmessage( 'WParam: '+IntToStr( wParamForClose )+' LParam: '+intToStr( LParamForClose ) );
    if PostMessage(hWndForClose, MsgForCLose, wParamForClose, lParamForClose) then
    begin
      CanClose := False;
      exit;
    end;
    // si falló el envio del mensaje dejo que siga y la cierre.
  end;

  {$IFDEF FTRX_NILONCLOSE}
    if nilOnClose <> nil then
    begin
      nilOnClose^ := nil;
      nilOnClose := nil;
    end;
  {$ENDIF}
  // liberar los trazos creados
  tr1.Free;
  CanClose := True;
end;




// métodos de TMarquita


constructor TMarquita.Create(xTipo: TTipoMarquita; xfg_color, xbg_color: TColor;
  xradio: integer);
begin
  inherited Create;
  tipo := xtipo;
  fg_color := xfg_color;
  bg_color := xbg_color;
  radio := xradio;
end;

procedure TMarquita.plot(c: TCanvas; xp, yp: integer);

  procedure c_Line(x1, y1, x2, y2: integer);
  begin
{$IFDEF FPC-LCL}
    c.Line(x1, y1, x2, y2);
{$ELSE}
    c.MoveTo(x1, y1);
    c.LineTo(x2, y2);
{$ENDIF}
  end;

begin
  case tipo of
{$IFDEF FPC-LCL}
    TM_Circulo: c.Arc(xp - radio, yp - radio, xp + radio, yp + radio, 0, 5760);
{$ELSE}
    TM_Circulo: c.Arc(xp - radio, yp - radio, xp + radio, yp + radio, 0, 0, 0, 0);
{$ENDIF}
    TM_Cuadrado: c.Rectangle(xp - radio, yp - radio, xp + radio, yp + radio);
    TM_Triangulo:
    begin
      c.MoveTo(xp, yp - radio);
      c.LineTo(xp - radio, yp + radio);
      c.LineTo(xp + radio, yp + radio);
      c.LineTo(xp, yp - radio);
    end;
    TM_Rombo:
    begin
      c.MoveTo(xp, yp - radio);
      c.LineTo(xp - radio, yp);
      c.LineTo(xp, yp + radio);
      c.LineTo(xp + radio, yp);
      c.LineTo(xp, yp - radio);
    end;

    TM_Cruz:
    begin
      c_Line(xp, yp - radio, xp, yp + radio);
      c_Line(xp - radio, yp, xp + radio, yp);
    end;

    TM_Cruz45:
    begin
      c_Line(xp - radio, yp - radio, xp + radio, yp + radio);
      c_Line(xp - radio, yp + radio, xp + radio, yp - radio);
    end;

    TM_Asterisco:
    begin
      c_Line(xp, yp - radio, xp, yp + radio);
      c_Line(xp - radio, yp, xp + radio, yp);
      c_Line(xp - radio, yp - radio, xp + radio, yp + radio);
      c_Line(xp - radio, yp + radio, xp + radio, yp - radio);
    end;

    else
      raise Exception.Create('TMarquita.plot, tipo de marquita no válido.');
  end;
end;

procedure TMarquita.Free;
begin
  inherited Free;
end;

initialization
{$IFDEF FPC-LCL}
  {$I utrazosxy.lrs}
{$ENDIF}
end.
