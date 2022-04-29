{+doc
+NOMBRE:Markers
+CREACION:1.1.90
+AUTORES:rch
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO:Definicion de cursores graficos para la unidad CURSORES
+PROYECTO:GrafCrt

+REVISION:
+AUTOR:
+DESCRIPCION:
-doc}

unit Markers;
interface
uses
	Gr;

procedure Mark(P:Point; markID:integer);

implementation

var
	mk:array [1..2] of pointer;
	mkCenter:array[1..2] of Point;

procedure Mark(P:Point; markID:integer);
var
	temp:integer;
begin
	temp:=GR.GetPutMode;
	GR.SetPutMode(XorPut);
	P.x:=P.x-mkCenter[markID].x;
	P.y:=P.y-mkCenter[markID].y;
	PutImage(P,mk[markID]^);
	GR.SetPutMode(temp);
end;


procedure MakeMk1;
var
	s:word;
	pt:pointer;
begin
	GR.Init;
	SetColor(RojoClaro);
	lineXY(0,2,4,2);
	lineXY(2,0,2,4);
	s:=ImageSizeXY(0,0,4,4);
	GetMem(pt,s);
	GetImageXY(0,0,4,4,pt^);
	mk[1]:=pt;
	mkCenter[1].x:=2;
	mkCenter[1].y:=2;
	GR.Close;
end;


procedure MakeMk2;
var
	s:word;
	pt:pointer;
begin
	GR.Init;
	SetColor(RojoClaro);
	rectangleXY(1,1,3,3);
	s:=ImageSizeXY(1,1,3,3);
	GetMem(pt,s);
	GetImageXY(1,1,3,3,pt^);
	mk[2]:=pt;
	mkCenter[2].x:=1;
	mkCenter[2].y:=1;
	GR.Close;
end;


begin
	MakeMk1;
	MakeMk2
end.





