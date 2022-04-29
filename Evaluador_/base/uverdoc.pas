unit uverdoc;


interface

uses
  {
  LCLIntf,
  Messages,  Classes, Graphics, Controls,
  Dialogs,
  OleServer,
  }
  {$IFDEF WINDOWS}
  Windows,
  shellapi,
  {$ELSE}
  LCLIntf,
  {$ENDIF}
  SysUtils, Forms,
  uConstantesSimSEE;

const
  marcadorNulo = '';

procedure abrir_url(url: string);

procedure verdoc(owner: TForm; aClass: TClass); overload;
procedure verdoc(owner: TForm; aClass: TClass; titulo: String); overload;
procedure verdoc(owner: TForm; aClass: TClass; titulo, marcador: string); overload;

procedure verdoc(owner: TForm; topico: string); overload;
procedure verdoc(owner: TForm; topico, titulo: string); overload;
procedure verdoc(owner: TForm; topico, titulo, marcador: string); overload;

procedure verGoogleMap(owner: TForm; Latitud, Longitud: double; z: integer );

procedure SistemaDeSoporteAUsuarios(owner: TForm );

implementation

resourcestring
  mesErrorAbrirArchivo = 'Error al intentar abrir archivo: ';




procedure verdoc(owner: TForm; aClass: TClass );
begin
  verdoc(owner, 'class-'+aClass.ClassName, '');
end;

procedure verdoc(owner: TForm; aClass: TClass ;titulo: String);
begin
  verdoc(owner, 'class-'+aClass.ClassName, titulo);
end;

procedure verdoc(owner: TForm; aClass: TClass; titulo, marcador: string);
begin
  verdoc(owner, 'class-'+aClass.ClassName, titulo, marcador);
end;

procedure verdoc(owner: TForm; topico: string );
begin
  verdoc(owner, topico, topico, marcadorNulo);
end;

procedure verdoc(owner: TForm; topico, titulo: string);
begin
  verdoc(owner, topico, titulo, '');
end;

function URLEncode(Str: string): string;
var
  i: integer;
  res: string;
  c: char;
begin
  res:= '';

  for i:= 1 to Length(Str) do
  begin
    c:= Str[i];
    if ( c= ' ') then 
      res:= res + '+'
    else
      if c in ['A'..'Z','a'..'z','0'..'9','-','_','.','+'] then
        res:= res + c
      else
        res:= res + '%' + IntToHex(Ord(c),2);
  end;
  result:= res;
end;



procedure verdoc(owner: TForm; topico, titulo, marcador: string);
var
  parametros: String;
begin
//  parametros:= 'http://energiaenuruguay.com/simsee/ayuda.php?hid='+ urlencode(topico)
  parametros:= 'http://simsee.org/simsee/ayuda/ayuda.php?hid='+ urlencode(topico)
      +'&titulo=' +urlencode( titulo )
      +'#'+urlencode(marcador);
  {$IFDEF WINDOWS}
  ShellExecute(owner.Handle,'open',pchar(parametros),nil,nil, SW_SHOWNORMAL);
  {$ELSE}
  OpenURL(pchar(parametros));
  {$ENDIF}
end;


procedure abrir_url(url: string);
begin
  {$IFDEF WINDOWS}
  ShellExecute( 0, 'open', pchar( url ), nil,nil, SW_SHOWNORMAL);
  {$ELSE}
  OpenURL(pchar( url ));
  {$ENDIF}
end;

procedure verGoogleMap(owner: TForm; Latitud, Longitud: double; z: integer );
var
  url: string;
begin
(*
  url:= 'http://maps.google.com/maps/ms?ie=UTF8&hl=es&msa=0&t=h&ll=';
  url:= url+ FloatToStrF( -Latitud, ffFixed, 9, 5 );
  url:= url+','+FloatToStrF( -Longitud, ffFixed, 9, 5 );
  url:= url+'&z='+IntToStr( z );
  *)

  url:= 'http://energiaenuruguay.com/mapa.php?Latitud=';
  url:= url+ urlencode( FloatToStrF( -Latitud, ffFixed, 9, 5 ));
  url:= url+'&Longitud='+ urlencode( FloatToStrF( -Longitud, ffFixed, 9, 5 ) );
  url:= url+'&z='+ urlencode( IntToStr( z ) );


  {$IFDEF WINDOWS}
  ShellExecute(owner.Handle,'open',pchar(url),nil,nil, SW_SHOWNORMAL);
  {$ELSE}
  OpenURL(pchar(url));
  {$ENDIF}

end;


procedure SistemaDeSoporteAUsuarios(owner: TForm );
var
  url: string;
begin
  url:= 'http://simsee.org/soporte';
   {$IFDEF WINDOWS}
  ShellExecute(owner.Handle,'open',pchar(url),nil,nil, SW_SHOWNORMAL);
  {$ELSE}
  OpenURL(pchar(url));
  {$ENDIF}
end;


initialization
end.


