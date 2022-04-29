unit uSLRW;
// rch@201412070927 esta unidad define un tipo de Streamer sobre una
// TStringList. La idea es simplificar la escritura y lectura con una
// variable por linea.
{$mode delphi}

interface

uses
  Classes, SysUtils, xmatdefs, uauxiliares, ufechas;


type
   TSLRW = class
   private
     sl: TStringList;
     fmr: boolean; // TRUE = Lectura
     iCursor: integer; // próxima línea a procesar.
   public
     constructor CreateForRead( xsl: TStringList );
     constructor CreateForWrite;
     procedure IniciarLectura;
     procedure IniciarEscritura;
     function Text: String;
     procedure Free;
     procedure rw( var a: NReal ); overload;
     procedure rw( var va: TDAOfNReal ); overload;
     procedure rw( var a: TDatetime ); overload;
     procedure rw( var i: integer ); overload;
     procedure rw( var s: string ); overload;
     function modo_lectura: boolean;
     function modo_escritura: boolean;
     function EOF: boolean;
   end;


implementation


constructor TSLRW.CreateForRead( xsl: TStringList );
begin
  inherited Create;
  sl:= xsl;
  IniciarLectura;
end;

constructor TSLRW.CreateForWrite;
begin
  inherited Create;
  sl:= TStringList.Create;
  IniciarEscritura;
end;


procedure TSLRW.IniciarLectura;
begin
  fmr:= true;
  iCursor:= 0;
end;

procedure TSLRW.IniciarEscritura;
begin
  sl.clear;
  fmr:= false;
  iCursor:= 0;
end;

function TSLRW.EOF: boolean;
begin
  result:= iCursor >= sl.Count;
end;

function TSLRW.Text: String;
begin
  result:= sl.Text;
end;

procedure TSLRW.Free;
begin
  sl.Free;
  inherited Free;
end;

procedure TSLRW.rw( var a: NReal );
begin
  if fmr then
    a:= StrToFloat( sl[iCursor] )
  else
    sl.add( FloatToStr( a ) );
  inc( iCursor );
end;

procedure TSLRW.rw( var va: TDAOfNReal );
begin
  if fmr then
    va:= StrToDAOfNReal_( sl[iCursor ], ',')
  else
    sl.add( DAOfNRealToStr_( va, 0,0,',' ) );
  inc( iCursor );
end;

procedure TSLRW.rw( var a: Tdatetime ); overload;
begin
  if fmr then
     a:= IsoStrToDateTime( sl[iCursor] )
  else
    sl.add( DateTimeToIsoStr( a ) );
  inc( iCursor );
end;


procedure TSLRW.rw( var i: integer );
begin
  if fmr then
    i:= StrToInt( sl[iCursor] )
  else
    sl.add( IntToStr( i ) );
  inc( iCursor );
end;

procedure TSLRW.rw( var s: string );
begin
  if fmr then
     s:= sl[iCursor]
  else
     sl.add( s );
  inc( iCursor );
end;


function TSLRW.modo_lectura: boolean;
begin
  result:= fmr;
end;

function TSLRW.modo_escritura: boolean;
begin
  result:= not modo_lectura;
end;

end.

