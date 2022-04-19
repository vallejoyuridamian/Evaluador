{+doc
+NOMBRE: GrafCrt
+CREACION: 1990
+AUTORES:  rch
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO: Implementaci¢n de Ventanas de Texto en Modo Gr fico
+PROYECTO: rchlib

+REVISION:  oct.1991
+AUTOR:     rch

+DESCRIPCION: Para una descripci¢n completa de este m¢dulo refierase
	al "Manula del Usuario de GrafCrt"
-doc}
unit GrafCRT; {es la grafcrt.001, modificada}

interface
uses

	Archivos,BSPoint,graph,crt,DOS,Gr,RchFonts;



const
	Negro = 0;
	Azul =1;
	Verde = 2;
	Celeste =3;
	Rojo = 4;
	Violeta = 5;
	Marron = 6;
	GrisClaro = 7;
	GrisOscuro = 8;
	AzulClaro = 9;
	VerdeClaro =10;
	CelesteClaro =11;
	RojoClaro =12;
	ViolotaClaro =13;
	Amarillo=14;
	Blanco=15;

const

	ESC = #27;
	CEOF = chr(27);
	LF = chr(10);
	CR = chr(13);
	TAB = chr(9);
	Transparentes = [' ', LF, CR, TAB];
	Letras = ['a'..'z','A'..'Z','0'..'9','_','''','¤',' ','‚','¡','¢','£'];
	Separadores = ['(',')', ',' , ';','.','[',']',':' ];
	Operadores = ['+','-','*','=','/'];




Type
	ScreenType = (Mono, Color);

var
	SType: ScreenType;

procedure Beep;


Type

	CursorType = (Grande, Chico, Apagado);


	Ventana = object(BasePoint)
		tamChar:word;
		CurTipo:CursorType;
		FondoPtr:pointer;
		FondoSize:word;
		dP:point;
		Cur, Org:Point;
		anch,alt:integer;
		Alto,Ancho:integer;
		InsMode:Boolean;
		ColorPapel,ColorTInta:byte;
		ColorPapelBorde,ColorTintaBorde:byte;
		ColorCursor:byte;

		constructor init(OrgX,OrgY,VAncho,VAlto,nTamChar:integer);
		destructor Done;virtual;
		procedure Active;
		procedure SetCharFont(fontId:word);
		procedure Page;
		procedure Write(x:string);
		procedure CRLF;
		procedure Papel(NuevoColor:word);
		procedure Tinta(NuevoColor:word);
		procedure PapelBorde(nc:byte);
		procedure TintaBorde(nc:byte);
		procedure TintaCursor(nc:byte);
		procedure Writeln(x:string);
		procedure Readln(var x:string);
		procedure GotoXY(x,y:byte);
		procedure WriteCharXY(x,y:integer;c:char); {no afecta Cur}
		procedure WriteStrXY(x,y:integer; sx:string);
		procedure Borde;
		procedure SetCursor(x:CursorType);
		procedure GuardeFondo;
		procedure RepongaFondo;
		procedure Abrir;
		procedure Cerrar;virtual;
		procedure Scroll(nl:integer);
		procedure InsLine;
		procedure InsDownLine;
		procedure InsUpLine;
		Procedure DelLine;
		procedure CEOL;
		procedure BackSpace;
		procedure Delete;
		procedure OutCharToScreen(x:char);
      procedure pcocxyREL(var pix,piy: integer; x,y:integer);
		procedure PCOCXYABS(var pix,piy: integer; x,y:integer);
		procedure ExtentAbs(var t; Cx1,Cy1,Cx2,Cy2:integer);
		procedure ExtentREL(var t; Cx1,Cy1,Cx2,Cy2:integer);
		procedure DefaultColors;
		Constructor Load(var f:archivo);
		procedure Save(var f:archivo);virtual;
	end;

	ventanaPtr = ^ventana;


	VPType = object
		x1,y1,x2,y2:integer;
		Clip:boolean;
		cp:Point;
		procedure Store;
		procedure Restore;
		procedure SetVP;
		procedure Clear(ColorPapel:word);
		procedure GetImage(var p:pointer; var tam:word);
		procedure AbsVPT(var v:ventana);
		procedure DefinePoint(P0,dP:point);
	end;

const
	VentanaActivaPtr:VentanaPtr=nil;




procedure WaitEnter;
procedure WaitEsc;
function WaitEscEnter:char;

function KeyPressed:boolean;
function ReadKey:char;
function WriteKey(c:char):boolean;
procedure ClearKeyBuffer;

implementation
uses Cursores;

const
	LongKeyBuffer = 15;

var
        KeyBuffer : array[0..LongKeyBuffer-1]of char;
        BufferReadIndex,BufferWriteIndex:integer;

function KeyPressed:boolean;
begin
	KeyPressed:=(BufferReadIndex<>BufferWriteIndex)or(CRT.KeyPressed)
end;

function ReadKey:char;
begin
	if BufferReadIndex <> BufferWriteIndex then
		begin
			BufferReadIndex:=(BufferReadIndex + 1) mod LongKeyBuffer;
         ReadKey:=KeyBuffer[BufferReadIndex];
		end
	else ReadKey:=CRT.ReadKey
end;

function WriteKey(c:char):boolean;
begin
	BufferWriteIndex:=(BufferWriteIndex + 1) mod LongKeyBuffer;
	if BufferWriteIndex = BufferReadIndex then
		begin
			dec(BufferWriteIndex);
			if BufferWriteIndex <0 then BufferWriteIndex:=LongKeyBuffer-1;
			WriteKey:=false
		end
	else
	begin
		KeyBuffer[BufferWriteIndex]:=c;
		WriteKey:=True
	end
end;

procedure ClearKeyBuffer;
var
	c:char;
begin
	while KeyPressed do c:=ReadKey
end;

procedure WaitKey(xc:char);
var
	c:char;
begin
	c:=#0;
	repeat
		if keyPressed then c:=readkey
	until c = xc;
end;

procedure WaitEsc;
begin
	WaitKey(#27)
end;
procedure WaitEnter;
begin
	WaitKey(#13)
end;

function WaitEscEnter:char;
var
	c:char;
begin
	c:='m';
	repeat
		if KeyPressed then c:=readKey
	until (c=#13)or(c=#27);
	WaitEscEnter:=c;
end;


procedure SetViewPort(x1,y1,x2,y2:integer; CLip:boolean);
begin
	if x1<0 then x1:=0;
	if y1<0 then y1:=0;
	if x2>MaxPoint.x then x2 := MaxPoint.x;
	if y2>MaxPoint.y then y2 := MaxPoint.y;
	if (x1<0)or(x1>x2)or(x2>MaxPoint.x)
	or (y1<0)or(y1>y2)or(y2>MaxPoint.y)
	then
		begin
			GR.Close;
			Writeln('Error: (Unit: GrafCRT , SetViewPort con par metros incorrectos)');
			halt(1);
		end
	else
		Graph.SetViewPort(x1,y1,x2,y2,Clip);
end;

procedure NoImplementado;
begin
	Gr.Close;
	RunError(211);
end;


type

	NodePtr = ^Node;

	Node = record
		next:NodePtr;
		p:pointer;
	end;



	IMBuff = object
		P:pointer;
		procedure Get(Cx1,Cy1,Cx2,Cy2:integer; var v:ventana);
		procedure Put(Cx0,Cy0:integer; var v:ventana);
	end;




var

	VidSeg:word;
	R: Registers;







procedure Ventana.DefaultColors;
begin
	if SType = GrafCRT.Color then
	begin
		Papel(Celeste);
		Tinta(Blanco);
		PapelBOrde(GrisClaro);
		TintaBorde(RojoClaro);
		TintaCursor(Rojo)
	end else
	begin
		Papel(Blanco);
		Tinta(Negro);
		PapelBorde(Negro);
		TintaBorde(Negro);
		TintaCursor(Negro)
	end;
end;



procedure ventana.Save(var f:archivo);
begin
	BasePoint.Save(f);
	f.Write(	tamChar ,2);
	f.Write(	CurTipo ,SizeOf(CursorType));
	f.WRite(P,SizeOf(Point));
	f.write(dP,SizeOf(Point));
	f.write(Cur,SizeOf(Point));
	f.write(Org,SizeOf(Point));
	f.write(	Alto,2);
	f.write(Ancho,2);
	f.write(InsMode,1);
	f.write(ColorPapel,2);
	f.write(ColorTinta,2);
	f.write(ColorPapelBorde,1);
	f.write(ColorTintaBorde,1);
	f.write(ColorCursor,1);
end;

Constructor ventana.Load(var f:archivo);
begin
	BasePoint.Load(f);
	f.read(	tamChar ,2);
	f.read(	CurTipo ,SizeOf(CursorType));
	f.read(P,SizeOf(Point));
	f.read(dP,SizeOf(Point));
	f.read(Cur,SizeOf(Point));
	f.read(Org,SizeOf(Point));
	f.read(	Alto,2);
	f.read(Ancho,2);
	f.read(InsMode,1);
	f.read(ColorPapel,2);
	f.read(ColorTinta,2);
	f.read(ColorPapelBorde,1);
	f.read(ColorTintaBorde,1);
	f.read(ColorCursor,1);
	FondoPtr:=nil;
	SetTextStyle(StandardFont,HorizDir,TamChar);
	alt:=TextHeight('H');
	anch:=TextWidth('m');
end;


{-----------------------
Devuelve en pix y piy las coordenadas en pixels del
caracter X,Y de la ventana v.
---------------------------------}
procedure ventana.pcocxyREL(var pix,piy: integer; x,y:integer);
begin
	pix:=(x-1)*anch;
	piy:=(y-1)*alt;
end;

procedure Ventana.PCOCXYABS(var pix,piy: integer; x,y:integer);
begin
	pix:=Org.x+(x-1)*anch;
	piy:=Org.y+(y-1)*alt;
end;

procedure ventana.ExtentAbs(var t;Cx1,Cy1,Cx2,Cy2:integer);
var
	w:VPType;
begin
	w:=VPType(t);
	PCOCXYABS(w.x1,w.y1,Cx1,Cy1);
	PCOCXYABS(w.x2,w.y2,Cx2,Cy2);
	inc(w.y2,alt-1);
	inc(w.x2,anch-1);
	VPType(t):=w;
end;

procedure ventana.ExtentREL(var t;Cx1,Cy1,Cx2,Cy2:integer);
var
	w:VPType;
begin
	w:=VPType(t);
	PCOCXYREL(w.x1,w.y1,Cx1,Cy1);
	PCOCXYREL(w.x2,w.y2,Cx2,Cy2);
	inc(w.y2,alt-1);
	inc(w.x2,anch-1);
	VPType(t):=w;
end;

procedure Window( var v:ventana);
var
t:VPType;
begin
	v.ExtentABS(t,1,1,v.ancho,v.alto);
	t.Clip:=True;
	t.SetVP;
end;

procedure IMBuff.Get;
var
	tam:word;
	px1,py1,px2,py2:integer;
begin
	v.PCOCXYREL(px1,py1,Cx1,Cy1);
	v.PCOCXYREL(px2,py2,Cx2,Cy2);
	inc(py2,v.alt);
	tam:=ImageSizeXY(px1,py1,px2,py2);
	GetMem(p,Tam);
	GetImageXY(px1,px2,py1,py2,p^);
end;

procedure IMBuff.Put;
var
	px0,py0:integer;
begin
	v.PCOCXYREL(px0,py0,Cx0,Cy0);
	SetPutMode(CopyPut);
	PutImageXY(px0,py0,p^);
end;




procedure VPType.Store;
var
	w:ViewPortType;
begin
	GetViewSettings(w);
	x1:=w.x1;y1:=w.y1;
	x2:=w.x2;y2:=w.y2;
	Clip:=w.Clip;
	cp.x:=GetX;
	cp.y:=GetY;
end;

procedure VPType.Restore;
begin
	SetViewPort(x1,y1,x2,y2,Clip);
	MoveTo(CP.x,CP.y);
end;

procedure VPType.SetVP;
begin
	SetViewPort(x1,y1,x2,y2,True);
	CP.x:=1;CP.y:=1;
end;

procedure VPType.Clear(ColorPapel:word);
var
	w:VPType;
begin
	w.Store;
	SetVP;
	SetFillStyle(SOlidFill,ColorPapel);
	bar(0,0,x2-x1,y2-y1);
	w.Restore;
end;

procedure VPType.AbsVPT(var v:ventana);
begin
	inc(x1,v.org.x);
	inc(y1,v.org.y);
	inc(x2,v.org.x);
	inc(y2,v.org.y)
end;

procedure VPType.GetImage(var p:pointer; var tam:word);
var
	w:VPType;
begin
	w.Store;
	SetVP;
	tam:=ImageSizeXY(0,0,x2-x1,y2-y1);
	GetMem(p,tam);
	Graph.GetImage(0,0,x2-x1,y2-y1,p^);
	w.Restore;
end;

procedure VPType.DefinePoint(P0,dP:point);
begin
	x1:=P0.x;
	y1:=P0.y;
	x2:=x1+dP.x-1;
	y2:=y1+dP.y-1
end;


procedure Beep;
begin
	Sound(200);
	Delay(200);
	NoSound;
end;


procedure Ventana.Papel(NuevoColor:word);
begin
	if (NuevoColor<0 )or (NuevoColor>15) then
		runError(211);{revisar n£mero}
	ColorPapel:=NuevoColor;
	RchFonts.ColorPapel:=NuevoColor;
end;

procedure Ventana.Tinta(NuevoColor:word);
begin
	ColorTinta:=NuevoColor;
	RChFonts.ColorTinta:=NuevoColor;
end;

procedure Ventana.TintaCursor(nc:Byte);
begin
	ColorCursor:=nc
end;

procedure Ventana.WriteStrXY(x,y:integer; sx:string);
var
	Long,n:integer;
begin
	n:=1;
	Long:=Length(sx);
	while (Long>0) and (y<=alto) do
	begin
		WriteCharXY(x,y,sx[n]);
		inc(n);Dec(Long);
		if x = ancho then
			begin
				x := 1;
				inc(y)
			end
		else inc(x)
	end
end;

procedure Ventana.WriteCharXY(x,y:integer;c:char);
var
	tcp:point;
begin
	tcp:=Cur;
	GotoXY(x,y);
	OutText(c);
	GotoXY(tcp.x,tcp.y);
end;

procedure Ventana.InsDownLine;
var
	imagBuff:pointer;
	TamBuff:word;
	ow:VPType;
begin
	if alto>1 then
	begin  {Desplaza la pantalla}
		ExtentAbs(ow,1,2,ancho,alto);
		ow.GetImage(ImagBuff,TamBuff);
		SetPutMode(CopyPut);
		PutImageXY(0,0,imagBuff^);
		FreeMem(imagBuff,tamBuff);
	end;
	ExtentAbs(ow,1,alto,ancho,alto);
	ow.Clear(ColorPapel);
end;


procedure Ventana.CEOL;
var
	t:VPType;
begin
	ExtentABS(t,Cur.x,Cur.y,Ancho,Cur.y);
	t.Clear(COlorPapel);
end;

procedure Ventana.BackSpace;
var
	t:VPType;
	po:pointer;
	tam:word;
	x0,y0:integer;
begin
	if Cur.x>1 then
		begin
			ExtentREL(t,Cur.x,Cur.y,Ancho,Cur.y);
			t.GetImage(po,tam);
         GotoXY(Cur.X-1,Cur.Y);
			PCOCXYREL(x0,y0,Cur.X,Cur.Y);
			SetPutMode(CopyPut);
			PutImageXY(x0,y0,po^);
			FreeMem(po,tam);
			WriteCharXY(Ancho,Cur.y,' ');
		end
	else if Cur.y>1 then
		begin
			gotoXY(ancho,Cur.y-1);
			Delete
		end;
end;

procedure Ventana.Delete;

var
	t:VPType;
	pt1:pointer;
	tam:word;
	x0,y0:integer;
begin
	if Cur.x<ancho then
	begin
		ExtentREL(t,Cur.x+1,Cur.y,Ancho,Cur.y);
		t.GetImage(pt1,tam);
		PCOCXYREL(x0,y0,Cur.X,Cur.Y);
		SetPutMode(CopyPut);
		PutImageXY(x0,y0,pt1^);
		FreeMem(pt1,tam);
	end;
	WriteCharXY(Ancho,Cur.y,' ');
end;


procedure Ventana.InsUpLine;
var
	t:VPType;
	pt1:pointer;
	tam:word;
	x0,y0:integer;
begin
	if alto> 1 then
	begin
		ExtentABS(t,1,1,Ancho,Alto-1);
		t.GetImage(pt1,tam);
		PCOCXYRel(x0,y0,1,2);
		SetPutMode(CopyPut);
		PutImageXY(x0,y0,pt1^);
		FreeMem(pt1,tam);
	end;
	ExtentAbs(t,1,1,Ancho,1);
	t.Clear(COlorPapel);
end;


procedure CursorOff(var v:ventana);
begin
	v.CUrTipo:=Apagado;
end;


Procedure CursorSmall(var v:ventana);
begin
	v.CurTIpo:=CHico;
end;

procedure CursorBig(var v:ventana);
begin
	v.CurTIpo:=Grande;
end;


procedure Ventana.Abrir;
begin
	Active;
	GuardeFondo;
	Borde;
end;

procedure Ventana.Cerrar;
begin
	RepongaFondo;
	CursorOff(Self);
end;


procedure Ventana.GuardeFondo;
var
	t:VPType;
begin
	t.DefinePoint(P,dP);
	t.GetImage(FondoPtr,FondoSize);
end;

procedure Ventana.RepongaFondo;
var
	w:VPType;
begin
	w.Store;
	SetViewPort(0,0,GetMaxX,GetMaxY,ClipOn);
	SetPutMode(CopyPut);
	PutImageXY(p.x,p.y,FondoPtr^);
	FreeMem(FondoPtr,FondoSize);
	FondoPtr:=nil;
	FondoSize:=0;
	w.Restore;
end;




procedure  Ventana.Active;
begin
	VentanaActivaPtr:=@Self;
	window(Self);
	GotoXY(Cur.x,Cur.Y);
	SetTextStyle(StandardFont,HorizDir,tamChar);
	SetCursor(CurTipo);
	TInta(Colortinta);
	{SetColor(ColorTinta);}
	Papel(Colorpapel);
end;


procedure Ventana.Page;
var
	t:VPType;
begin
	ExtentAbs(t,1,1,ancho,alto);
	t.Clear(ColorPapel);
	gotoXY(1,1);
end;

procedure Ventana.Insline;
var
	t:VPType;
	ptx:pointer;
	tam:word;
	x0,y0:integer;
begin
	if Cur.y<Alto then
	begin
		GotoXY(1,Cur.y+1);
		ExtentRel(t,1,cur.y,ancho,alto-1);
		t.GetImage(ptx,tam);
		PCOCXYRel(x0,y0,1,Cur.y+1);
		SetPutMode(copyPut);
		PutImageXY(x0,y0,ptx^);
		FreeMem(ptx,tam);
		ExtentRel(t,1,cur.y,ancho,cur.y);
		t.Clear(COlorPapel);
	end
	else
		Scroll(1);
end;


procedure Ventana.Scroll(nl:integer);
begin
	while nl<>0 do
	begin
		insDownline;
		dec(nl)
	end
end;



procedure Ventana.CRLF;
begin
	Cur.x:=1;
	if Cur.y<Alto then GotoXY(1,Cur.y+1)
	else
		scroll(1);
end;

procedure Ventana.DelLine;
var
	t:VPType;
	ptx:pointer;
	tam:word;
	x0,y0:integer;
begin
	if Cur.y<Alto then
	begin
		ExtentABS(t,1,cur.y+1,ancho,alto);
		t.GetImage(ptx,tam);
		PCOCXYRel(x0,y0,1,Cur.y);
		SetPutMode(CopyPut);
		PutImageXY(x0,y0,ptx^);
		FreeMem(ptx,tam);
	end;
	ExtentAbs(t,1,Alto,ancho,Alto);
	t.Clear(ColorPapel);
end;


procedure Ventana.OutCharToScreen(x:char);
begin
	WriteCharXY(Cur.x,Cur.y,x);
	if Cur.x = Ancho then CRLF
	else GotoXY(Cur.x+1,Cur.y);
end;

procedure Ventana.write(x:string);
var
   k:integer;
begin
	for k:=1 to Length(x) do
		OutCharToScreen(x[k]);
end;

procedure Ventana.GotoXY(x,y:byte);
var
	px,py:integer;
begin
	PCOCXYRel(px,py,x,y);
	Graph.MoveTo(px,py);
	Cur.x:=X;
	Cur.y:=Y
end;

procedure ventana.SetCharFont(FontId:word);
begin
	SetTextStyle(FontId,HorizDIr,TamChar);
end;

procedure Ventana.writeln(x:string);
begin
	write(x);
	CRLF;
end;

procedure Ventana.ReadLn(var x:string);

var
	ky:char;
	cp:integer;


{ Devuelve Un String correspondiente al renglon
para el cp actual }
function renglon:string;
var
  count,cp1,cp2:integer;
begin
	cp1:=((cp-1)div ancho)*ancho +1;
	cp2:=cp1+ancho-1;
	if cp2 >length(x) then cp2:=length(x);
	Count:=Cp2-Cp1+1;
	Renglon:=Copy(x,cp1,Count);
end;

procedure Left;
begin
	if cp>1 then
	begin
		dec(cp);
		if cur.x>1 then gotoXY(cur.x-1,Cur.y)
		else if cur.y> 1 then
					gotoXY(ancho,cur.y-1)
				else
					begin
						InsUpLine;
						WriteStrXY(1,1,renglon);
						GotoXY(ancho,1);
					end;
	end;
end;

procedure BS;
begin
	if (cp>1) then
	begin
		System.Delete(x,cp-1,1);
		Left;
		x:=x+' ';
		WriteStrXY(cur.x,cur.y,Copy(x,cp,length(x)-cp+1));
		System.Delete(x,length(x),1);
	end
	else ky:='k'
end;

procedure Up;
begin
	if cp>ancho then
		begin
			cp:=cp-ancho;
			if cur.y >1 then GotoXY(Cur.x,Cur.y-1)
			else
			begin
				InsUpLine;
				WriteStrXY(1,1,renglon);
			end
		end
end;

procedure Down;
begin
	if cp+ancho<=length(x)+1 then
	begin
		inc(cp,ancho);
		if cur.y<alto then GotoXY(Cur.x,Cur.y+1)
		else
		begin
			InsDownLine;
			WriteStrXY(1,alto,renglon);
		end;
	end;
end;

procedure Rigth;
begin
	if cp<=length(x) then
	begin
		inc(cp);
		if cur.x<ancho then
				gotoXY(cur.x+1,Cur.y)
		else if cur.y=alto then
					begin
						InsDownLine;
						GotoXY(1,Alto);
						WriteStrXY(1,alto,renglon);
					end
				else gotoXY(1,cur.y+1);
	end
end;

procedure Del;
begin
	if cp<=length(x) then
	begin
		Rigth;
		BS;
	end;
end;

procedure InsOnOff;
begin
	InsMode:= Not InsMode;
	if CurTipo<> Apagado then
		if InsMode Then SetCursor(Chico)
		else SetCursor(Grande)
end;

procedure Home;
begin
	while (cur.x>1)and(cp>1) do
		left;
end;
procedure EndKey;
begin
	while (cur.x<ancho)and(cp<=length(x)) do
		rigth;
end;


procedure CtrlY;
var
  count:integer;
begin
	if (cp+ancho-cur.x) <= length(x) then Count:=Ancho
	else Count := length(x) - (cp-cur.x);
	System.Delete(x,cp-cur.x+1,count);
	DelLine;
	if cp>Length(x) then
	begin
		cp:=length(x);
		GOtoXY(((cp-1)mod ancho)+1,((cp-1)div ancho)+1);
		Rigth;
	end;
end;

procedure Comando;

begin
	ky:=ReadKey;
	case ky of
	#72:up;
	#80:Down;
	#75:Left;
	#77:Rigth;
	#83:Del;
	#82:InsOnOff;
	#71:Home;
	#79:EndKey;
	else BEEP
	end;
end;


procedure WriteCursor(mando:word);
const
	Est:boolean = false;
	fondo:pointer = nil;
	tam:word=0;
	Cuenta:integer=0;
var

	w,t:VPType;
begin
	GR.SetColor(ColorCursor);
	If CUrTipo = Apagado then mando:=0;
	ExtentRel(t,Cur.x,Cur.y,Cur.x,Cur.y);
	cuenta:=(cuenta+1)mod 600;
	if est then
		begin
			if (mando=0)or(Cuenta=0) then {apaga el cursor}
			begin
				SetPutMode(CopyPut);
				PutImageXY(t.x1,t.y1,Fondo^);
				FreeMem(fondo,tam);
				est :=false;
			end
		end
	else
	begin
		if (mando=1)or(cuenta=0) then {enciende el cursor}
		begin
			ExtentABS(w,Cur.x,Cur.y,Cur.x,Cur.y);
			w.getImage(fondo,tam);
			if CurTipo = Grande then rectangleXY(t.x1,t.y1,t.x2,t.y2)
			else	rectangleXY(t.x1,t.y2-4,t.x2,t.y2-2);
			est:=true;
		end
	end;
	GR.SetColor(ColorTinta);
end;


begin
	cp:=Length(x)+1;
	ky:='k';
	Write(x);
	repeat
		if KeyPressed then
		begin
			WriteCursor(0);  {apago el Cursor}
			ky:=ReadKey;
			Case ky of
			#8:BS;
			#13:;{exit}
			#25:CtrlY;
			#0:Comando;
			else
				begin
					if InsMode then
						begin
							Insert(ky,x,cp);
							WriteStrXY(cur.x,cur.y,Copy(x,cp,length(x)-cp+1));
						end
					else   {OverrideMode}
						begin
							if cp = length(x)+1 then x:=x+ky
							else x[cp]:=ky;
							WriteStrXY(Cur.x,Cur.y,ky);
						end;
               if (cur.x = ancho) and(cur.y=alto) then
						begin
							insDownLine;
							gotoXY(1,alto);
							inc(cp);
						end
					else Rigth;
				end;
			end;{Case}
		end
		else WriteCursor(2); {Cursor Blinking}
	until ky = chr(13);
{	CRLF; }
end;

constructor Ventana.init(OrgX,OrgY,VAncho,VAlto,nTamChar:integer);
begin
	BasePoint.Init(OrgX,OrgY);
	FondoPtr:=nil;
	P.x:=OrgX;
	P.y:=OrgY;
	TamChar:=nTamChar;
	SetTextStyle(StandardFont,HorizDir,TamChar);
	SetTextJustify(LeftText, TopText );
	alt:=TextHeight('H');
	anch:=TextWidth('m');
	dP.x:=VAncho*anch; {ancho en pixels de la ventana}
	dP.Y:=VAlto*alt;   {alto en pixels de la ventana}
	Org.X:=OrgX;
	Org.Y:=Orgy;
	Cur.X:=1;
	Cur.Y:=1;
	Ancho:=VAncho;
	Alto:=VAlto;
	CurTipo:=Chico;
	InsMode:=True;
	DefaultColors;
	Active;
end;

destructor ventana.Done;
begin
	if FondoPtr<>nil then
		FreeMem(FondoPtr,FondoSize);
	BasePoint.Done;
end;

procedure Ventana.PapelBorde(nc:byte);
begin
	ColorPapelBorde:=nc;
end;

procedure Ventana.TintaBorde(nc:byte);
begin
	ColorTintaBorde:=nc;
end;

procedure Ventana.Borde;
const
  Gray50 : FillPatternType = ($AA, $55, $AA,
	 $55, $AA, $55, $AA, $55);
var
	OldPattern:FillPatternType;
	w,t:VPType;
	dx,dy:integer;
begin
	visible:=True;
	dx:=anch {div 2};
	dy:=alt {div 4};
	t.DefinePoint(P,dP);
	t.SetVp;

	SetFillStyle(EmptyFill,ColorPapelBorde);
	GetFillPattern(OldPattern);
	SetFillPattern(Gray50,ColorPapelBorde);
	SetPutMode(XorPut);

	Bar(dP.x-dx,dy,dP.x,dP.y);
	Bar(dx,dP.y-dy,dP.x-dx,dP.y);

	SetFillStyle(SolidFill,ColorPapel);
	SetFillPattern(OldPattern,ColorPapel);
{
	SetPutMode(OrPut);
	PutImageXY(0,0,FondoPtr^);
	}
	SetPutMode(CopyPut);
	Bar(0,0,dP.x-dx,dP.y-dy);
	GR.SetColor(ColorTintaBorde);
	rectangleXY(0,0,dP.x-dx,dP.y-dy);

	Org.x:=p.x+anch;
	Org.y:=p.y+alt;

	Alto:=(dP.y div alt)-2;
	ancho:=(dP.x div anch)-2;

	Active;
	GR.SetColor(ColorTinta);
	Page;
end;

procedure Ventana.SetCursor(x:CursorType);
begin
	CurTipo:=x;
	Case x of
	Chico: CursorSmall(Self);
	Grande: CursorBig(Self);
	Apagado: CursorOff(Self);
	end;
end;




begin

FillChar(R,SizeOf(R),0);
R.AH:= $0F;
Intr($10,R);
if R.AL = 7 then
	begin
	SType:=Mono;
	VidSeg:=$B000;
	end
else
	begin
		Stype:=Color;
		VidSeg:=$B800;
	end;

BufferWriteIndex:=0;
BufferReadIndex:=0;
end.

