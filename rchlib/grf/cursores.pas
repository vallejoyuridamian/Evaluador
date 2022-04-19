{+doc
+NOMBRE: cursores
+CREACION:1.1.90
+AUTORES:rch
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO:Implementacion de cursores en pantallas graficas DOS
+PROYECTO:GrafCrt

+REVISION:
	21.1.98. rch. Le agrag‚ la posibilidad de reconocer teclas como
			comandos cuando se inicializa el objeto con
			el constructor (InitWithKeysComs) en lugar de (init).

			La idea es que le pasamos un string con el conjunto de letras
			que debe interpretar como comandos. Cuando en modo edici¢n,
			cualquiera de estas teclas es presionada se retorna de (edit)
			con TRUE (como si apretaramos ENTER o el IzqMouse) y
			llamando a la funci¢n (GetKeyCom), sabremos si salio por
			un KeyCom (retorna TRUE) o por ENTER o IzqMouse (retorna FALSE).
+AUTOR:
+DESCRIPCION:
-doc}

{$O+,F+}
unit cursores;
interface

uses
	Ancestor,IntReloj,CRT, Mouse, Markers,Gr;

const

	Up = 'H';
	Down ='P';
	Left = 'K';
	Right = 'M';
	PgUP = 'I';
	PgDown = 'Q';
	Home ='G';
	cEnd ='O';
	Enter = chr(13);
	ESC = chr(27);
	_NoKeyChar_ = #1;


type

	Cursor = object
		ObjPtr:pointer;
		Ocupado:boolean;
		Hiden:boolean;
		BlinkingState:boolean;
		LP,P:Point;
		SHSId:integer;
		mkId:integer;
		ValidKeysComs: string;
		KeyCom: char;

		constructor Init(x,y:integer; markId:integer);
		constructor InitWithKeysComs(
								x, y: integer; markId: integer;
								xValidKeysComs: string );
		function GetKeyCom( var c: char ): boolean;
		destructor Done;
		function Edit:boolean;
		procedure Show;
		procedure hide;
		procedure ShowHideClockIntrService;
		procedure SetBlinkingFrecuency(NTimes:integer);
		procedure StartBlinking;
		procedure StopBLinking;
		procedure SetBasePointToMove(var x);
	end;


implementation

uses BSPoint;

procedure Beep;
begin
	Sound(200);
	Delay(200);
	NoSound
end;

function XCHANGE(var b:boolean):boolean;
begin
	XCHANGE:=b;
	b:=true
end;

procedure Cursor.SetBasePointToMove(var X);
begin
	ObjPtr:=@X;
end;

procedure Cursor.Hide;
begin
	if not XCHANGE(Ocupado) then
	begin
		if not Hiden then
		begin
			Hiden:=true;
			if (LP.x=P.x)and(LP.y=P.y) then
			begin
				mark(P,mkID);
			end
			else
			begin
				mark(LP,mkID);
			end;
		end;

		if (LP.x=P.x)and(LP.y=P.y) then
		begin
				if ObjPtr <> nil then BasePoint(ObjPtr^).Hide;
		end
		else
      if ObjPtr <> nil then
					begin
						BasePoint(ObjPtr^).Hide;
						BasePoint(ObjPtr^).MoveTo(P);
					end;

		LP:=P;
		Ocupado:=false
	end;
end;

procedure Cursor.Show;
begin
	if not(XCHANGE(Ocupado))then
	begin
	if Hiden then
		begin
			Hiden:=false;
			if ObjPtr <> nil then
				begin
					BasePoint(ObjPtr^).MoveTo(P);
					BasePoint(ObjPtr^).Show
				end;
			mark(P,mkID);
			LP:=P;
		end;
	Ocupado:=False;
	end;
end;

procedure Cursor.ShowHideClockIntrService;
begin
	if Hiden then Show
	else Hide;
end;

procedure Cursor.StartBlinking;
begin
	BlinkingState:=True;
	IntReloj.StartMethod(SHSId);
end;
procedure Cursor.StopBlinking;
begin
	BlinkingState:=false;
	IntReloj.StopMethod(SHSId);
end;

procedure Cursor.SetBLinkingFrecuency(Ntimes:integer);
begin
	IntReloj.SetTimes(SHSId,Ntimes);
end;


constructor Cursor.InitWithKeysComs(
								x, y: integer; markId: integer;
								xValidKeysComs: string );
begin
	KeyCom:= _NoKeyChar_;
	ValidKeysComs:= xValidKeysComs;
	Init( x, y, markId );
end;

function Cursor.GetKeyCom( var c: char ): boolean;
begin
	c:= KeyCom;
	GetKeyCom:= KeyCom <> _NoKeyChar_;
end;

constructor Cursor.Init(x,y:integer; markId:integer);
begin
	ObjPtr:=Nil;
	mkID:=markID;
	Hiden:=true;
	P.x:=x;
	P.y:=y;
	{
		Inscribe el servicio de blinking en el despachador del clock,
	SHSId es el identificador de servicio asignado por el dspachador
	}
	SHSId:=IntReloj.AddMethod(@Cursor.ShowHideClockIntrService,@Self);
	LP:=P; {Inicializa Last Position igual a la Position real}
	SetBLinkingFrecuency(7); {Default frecuency}
	BlinkingState:=false;
	Ocupado:=false;
end;

destructor Cursor.Done;
begin
	IntReloj.DelMethod(SHSId);
end;

function Cursor.Edit:boolean;
const
	vel:integer = 1;
var
	c:char;
	temp,nP:point;
	editting:boolean;

procedure add(var k:integer; dk,Maxk:integer);
begin
	k:=k+dk;
	if k<0 then k:=0;
	if k>Maxk then k:=Maxk;
	SetMouseCursorPos(np.x,np.y);
end;

begin
	KeyCom:=_NoKeyChar_;
	temp:=P;
	nP:=P;

	SetMouseCursorPos(p.x,p.y);

	editting:=true;
	repeat
		If (p.X <>np.x)or(p.Y <>np.y)  then
			begin
				if BlinkingState then
				begin
					StopBlinking;
					Hide;
					P:=nP;
					Show;
					StartBlinking;
				end
				else begin
					Hide;
					P:=nP;
					Show
				end
			end;
		if keypressed then
		begin
			c:=ReadKey;
			case c of {case1}
				Enter, ESC: editting:=false;
				chr(0):
					begin
						c:=ReadKey;
						case c of   {case2}
							up: add(nP.y,-vel,MaxPoint.y);
							down: add(nP.y,vel,MaxPoint.y);
							left: add(nP.x,-vel,MaxPoint.x);
							right: add(nP.x,vel,MaxPoint.x);
							PgUp: begin
									inc(vel);
									if vel>10 then vel:= 10;
								end;
							PgDown: begin
								Dec(vel);
								if vel<1 then vel:=1;
							end;
							else beep
						end {case2}
					end
				 else
				 if pos( c, ValidKeysComs ) >= 1 then
					begin
						KeyCom:= c;
						editting:= false;
					end
					else
						beep;
			end {case1}
		end
		else
		begin { process mouse }
			c:='m';
			if MousePresent then
			begin
				if LeftMouseKeyPressed then
				begin
					editting:=false;
				end
				else

					if RightMouseKeyPressed then
					begin
						c:=ESC;
						editting:=false
					end
					else
					begin
						np.x:=MOuseX;
						np.Y:=MOuseY;
					end;
			end;
      end;


		if c = ESC then
			begin
				P:=temp;
				Edit:=false;
			end
		else
			Edit:=True;
	until not(Editting);  {repeat}

	Hide;
end;


end.

