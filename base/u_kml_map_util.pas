unit u_kml_map_util;

{$mode delphi}

interface

uses
  Classes, SysUtils, xmatdefs, uauxiliares;


type

  { TMap_ObjRec }

  TMap_ObjRec = class
    Nombre: string;
    Lat, Lon: double;
    idMarcador: integer;
    constructor Create(nombre: string; Latitud, Longitud: double;
      idMarcador: integer);
    // Agrega a lineas la definición del objeto
    procedure exportar_KML( lineas: TStringList );
  end;

  { TMap_Objetos }

  TMap_Objetos = class( TList )
   function GetRec( kRec: integer ): TMap_ObjRec;
   procedure SetRec( kRec: integer; aRec: TMap_ObjRec );
   property Items[ k:integer ] : TMap_ObjRec read GetRec write SetRec; default;
   procedure Free;
  private
    procedure exportar_KML(lineas: TStringList);
  end;

  TMap_kml_document = class
    nombre: string;
    encabezado, cuerpo, final: TStringList;
    objetos: TMap_Objetos;
    constructor CreateNew( nombre: string );
    procedure WriteArchi_kml( archi: string );
    procedure AddMarcador(nombre: string; lat, lon: double; tipo: integer);
    procedure Free;
  end;

implementation


function TMap_Objetos.GetRec( kRec: integer ): TMap_ObjRec;
begin
  result:= inherited items[kRec];
end;

procedure TMap_Objetos.exportar_KML( lineas: TStringList );
var
  k: integer;
begin
  for k:= 0 to count -1 do
    items[k].Exportar_KML( lineas );
end;

procedure TMap_Objetos.SetRec( kRec: integer; aRec: TMap_ObjRec );
begin
  inherited items[kRec] := aRec;
end;
procedure TMap_Objetos.Free;
var
  k: integer;
begin
  for k:= 0 to count-1 do
    items[k].Free;
  inherited Free;
end;


constructor TMap_ObjRec.Create( nombre: string;  Latitud, Longitud: double; idMarcador: integer );
begin
  self.Nombre:= nombre;
  Lat:= Latitud;
  Lon:= Longitud;
  self.idMarcador:= idMarcador;
end;

procedure TMap_ObjRec.exportar_KML(lineas: TStringList);
begin
 lineas.add( '<Placemark>');
 lineas.add( '		<name>'+ nombre +'</name>');
 lineas.add( '		<LookAt>');
 lineas.add( '			<longitude>'+FloatToStr( lon )+'</longitude>');
 lineas.add( '			<latitude>'+FloatToStr( lat )+'</latitude>');
 lineas.add( '			<altitude>0</altitude>');
 lineas.add( '			<heading>0.03218595181665888</heading>');
 lineas.add( '			<tilt>0</tilt>');
 lineas.add( '			<range>1210.486010851577</range>');
 lineas.add( '			<gx:altitudeMode>relativeToSeaFloor</gx:altitudeMode>');
 lineas.add( '		</LookAt>');

 case idMarcador of
 0: lineas.add( '		<styleUrl>#m_ylw-pushpin</styleUrl>');
 1: lineas.add( '		<styleUrl>#s_ylw-pushpin_hl</styleUrl>');
 2: lineas.add( '		<styleUrl>#m_ylw-pushpin0</styleUrl>');  //meteo
 3: lineas.add( '		<styleUrl>#s_#msn_track</styleUrl>'); //Molino
 end;
 lineas.add( '		<Point>');
 lineas.add( '			<gx:drawOrder>1</gx:drawOrder>');
 lineas.add( '			<coordinates>'+FloatToStr( lon )+','+FloatToStr( lat )+',0</coordinates>');
 lineas.add( '		</Point>');
 lineas.add( '	</Placemark>');

end;


constructor TMap_kml_document.CreateNew( nombre: string );
begin
  self.nombre:= nombre;
  encabezado:= TStringList.Create;
  cuerpo:= TStringList.Create;
  final:= TStringList.Create;
  objetos:= TMap_Objetos.Create;

  encabezado.add('<?xml version="1.0" encoding="UTF-8"?>');
  encabezado.add('<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">');
  encabezado.add('<Document>');
  encabezado.add('	<name>'+nombre+'.kmz</name>');
  encabezado.add('	<open>1</open>');
  encabezado.add('	<Style id="s_ylw-pushpin_hl">');
  encabezado.add('		<IconStyle>');
  encabezado.add('			<scale>1.3</scale>');
  encabezado.add('			<Icon>');
  encabezado.add('				<href>http://maps.google.com/mapfiles/kml/pushpin/ylw-pushpin.png</href>');
  encabezado.add('			</Icon>');
  encabezado.add('			<hotSpot x="20" y="2" xunits="pixels" yunits="pixels"/>');
  encabezado.add('		</IconStyle>');
  encabezado.add('	</Style>');
  encabezado.add('	<Style id="s_ylw-pushpin">');
  encabezado.add('		<IconStyle>');
  encabezado.add('			<scale>1.1</scale>');
  encabezado.add('			<Icon>');
  encabezado.add('				<href>http://maps.google.com/mapfiles/kml/pushpin/ylw-pushpin.png</href>');
  encabezado.add('			</Icon>');
  encabezado.add('			<hotSpot x="20" y="2" xunits="pixels" yunits="pixels"/>');
  encabezado.add('		</IconStyle>');
  encabezado.add('	</Style>');
(*********************
        <Style id="s_ylw-pushpin_hl0">
		<IconStyle>
			<scale>1.3</scale>
			<Icon>
				<href>http://maps.google.com/mapfiles/kml/pushpin/ylw-pushpin.png</href>
			</Icon>
			<hotSpot x="20" y="2" xunits="pixels" yunits="pixels"/>
		</IconStyle>
	</Style>
	<Style id="s_ylw-pushpin_hl1">
		<IconStyle>
			<scale>1.3</scale>
			<Icon>
				<href>http://maps.google.com/mapfiles/kml/paddle/ltblu-blank.png</href>
			</Icon>
			<hotSpot x="32" y="1" xunits="pixels" yunits="pixels"/>
		</IconStyle>
		<ListStyle>
			<ItemIcon>
				<href>http://maps.google.com/mapfiles/kml/paddle/ltblu-blank-lv.png</href>
			</ItemIcon>
		</ListStyle>
	</Style>
	<Style id="sn_track">
		<IconStyle>
			<scale>1.2</scale>
			<Icon>
				<href>http://maps.google.com/mapfiles/kml/shapes/track.png</href>
			</Icon>
			<hotSpot x="32" y="1" xunits="pixels" yunits="pixels"/>
		</IconStyle>
		<ListStyle>
		</ListStyle>
	</Style>

 *************)
  encabezado.add('	<StyleMap id="m_ylw-pushpin">');
  encabezado.add('		<Pair>');
  encabezado.add('			<key>normal</key>');
  encabezado.add('			<styleUrl>#s_ylw-pushpin</styleUrl>');
  encabezado.add('		</Pair>');
  encabezado.add('		<Pair>');
  encabezado.add('			<key>highlight</key>');
  encabezado.add('			<styleUrl>#s_ylw-pushpin_hl</styleUrl>');
  encabezado.add('		</Pair>');
  encabezado.add('	</StyleMap>');


  encabezado.add('	  	<Folder>');
  encabezado.add('			<name>'+ nombre +'</name>');
  encabezado.add('			<open>1</open>');


  final.add('  	</Folder>');

  final.add('</Document>');
  final.add('</kml>' );


end;




procedure TMap_kml_document.AddMarcador( nombre: string; lat, lon: double; tipo: integer );
var
  aRec: TMap_ObjRec;
begin
  aRec:= TMap_ObjRec.Create( nombre, lat, lon, tipo );
  objetos.Add( aRec );
end;

procedure TMap_kml_document.WriteArchi_kml( archi: string );
var
  f: textfile;
  k: integer;
begin

  setSeparadoresGlobales;
  assignfile( f, archi );
  rewrite( f );

  cuerpo.clear;
  objetos.Exportar_KML( cuerpo );

  for k:= 0 to encabezado.Count -1 do
    writeln( f, encabezado[k] );
  for k:= 0 to cuerpo.Count -1 do
    writeln( f, cuerpo[k] );
  for k:= 0 to final.Count -1 do
    writeln( f, final[k] );

  closefile( f );
  setSeparadoresLocales;

end;

procedure TMap_kml_document.Free;
begin
  final.Free;
  cuerpo.Free;
  encabezado.Free;
end;


end.

