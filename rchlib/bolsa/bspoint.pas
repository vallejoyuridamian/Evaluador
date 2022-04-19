{+doc
+NOMBRE: bspoint
+CREACION:1.1.90
+AUTORES:rch
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO:Definicion de la clase BasePoint. Objeto base de escenarios 2d.
+PROYECTO: lab01

+REVISION:
+AUTOR:
+DESCRIPCION: De la epoca del editor de menues graficos para Lab01.
-doc}

{$O+}
unit BSPoint;
interface
uses
	Ancestor,Archivos,GR;

type

	BasePoint=object(base)
		P:Point;
		Color:word;
		visible:boolean;
		procedure Show;virtual;
		procedure Hide;virtual;
		procedure MoveTo(nP:Point);virtual;
		constructor Load(var f:archivo);
		constructor Init(x,y:integer);
		destructor Done;virtual;
		procedure Save(var f:archivo);virtual;
		procedure SetColor(nc:word);virtual;
		procedure Edit;virtual;
	end;

implementation
uses Cursores;

{ m‚todos de BasePoint }

constructor BasePoint.Init(x,y:integer);
begin
	Base.Init;
	Color:=Negro;
	visible:=false;
	p.x:=x;
	p.y:=y;
end;

procedure BasePoint. Show;
begin
	if not visible then
	begin
		Pixel(P,Color);
		Visible:=true
	end
end;

procedure BasePoint. Hide;
begin
	if visible then
	begin
		Pixel(P,GetBkColor);
		visible:=false
	end
end;

procedure BasePoint. MoveTo(nP:Point);
begin
	if visible then
	begin
		hide;
		p:=np;
		show
	end
	else p:=np
end;


constructor BasePoint.Load(var f:archivo);
begin
	visible:=false;
	f.Read(p,SizeOf(p));
	f.Read(color,2);
end;

destructor BasePoint.Done;
begin
	hide;
	Base.Done;
end;

procedure BasePoint. Save(var f:archivo);
begin
	f.Write(p,SizeOf(p));
	f.write(color,2);
end;



procedure BasePoint. SetColor(nc:word);
begin
	if visible then
	begin
		hide;
		Color:=nc;
		Show
	end
	else Color:=nc
end;

procedure BasePoint.Edit;
var
	c:cursor;
	res:boolean;
begin
	c.init(p.x,p.y,1);
	c.SetBasePointToMove(Self);
	res:=c.edit;
	c.Done;
	Hide;
	p.x:=c.p.x;
	p.y:=c.p.y;
	Show
end;


end.