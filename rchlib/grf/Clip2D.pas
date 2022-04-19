{+doc
+NOMBRE: clip2d
+CREACION: 12.08.92
+AUTORES: rch
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO:  Implementacion de metodos estandar de CLIPPING
	en dos dimensiones.
+PROYECTO:

+REVISION: 4.09.94. en el método de CohenSutherland se detecto un BUG
	"aparente" y se corrigio. No se probó la unidad posteriormente.
+AUTOR: rch
+DESCRIPCION:
		Se implementa los métodos de (Liang_Barsky) y (CohenSutherland) para
	recortar segmentos en un marco rectangular.

-doc}        

Unit Clip2D;
interface
uses
   xMatDefs;

Type
	TRectangleNR = record
			xmin,ymin,xmax,ymax:NReal;
	end;



procedure Liang_Barsky(var x0,y0,x1,y1:NReal; var R: TRectangleNR; var visible:boolean);
procedure CohenSutherland(var x0,y0,x1,y1:NReal; var R: TRectangleNR; var visible:boolean);


implementation

function ClipPoint(var x,y:NReal; var R: TRectangleNR):boolean;
begin
	CLipPoint:=(R.xmin<x)and(x<R.xmax)and(R.ymin<y)and(y<R.ymax)
end;

{ Liang-Barsky parametric line-clipping algorithm }

procedure Liang_Barsky(var x0,y0,x1,y1:NReal; var R: TRectangleNR; var visible:boolean);

var
	tE,tL:NReal;
	dx,dy:NReal;

	function CLIPt(denom,num:NReal; var tE,tL :NReal):boolean;
	var
		t:NReal;
		accept:boolean;
	begin
		accept:=true;
		if denom > 0 then
		begin
			t := num/denom;
			if t > tL then
				accept:=false
			else if t > tE then
				tE := t
		end
		else
			if denom < 0 then
			begin
				t:= num/denom;
				if t< tE then
					accept:=false
				else if t< tL then
					tL:=t
			end
		else
			if num > 0 then
				accept:=false;
		CLIPt:=accept
	end; {CLIPt}

begin
	dx:= x1 - x0; dy := y1-y0;
	visible:=false;
	if (dx = 0) and (dy = 0) and ClipPoint(x0,y0,R) then
		visible := true
	else
		begin
			tE:=0;
			tL:=1;
			if CLIPt(dx,R.xmin-x0,tE,tL) then
				if CLIPt(-dx,x0-R.xmax,tE,tL) then
					if CLIPt(dy, R.ymin-y0,tE,tL) then
						if CLIPt(-dy,y0-R.ymax,tE,tL) then
							begin
								visible:= true;
								if tL < 1 then
									begin
										x1:=x0+tL*dx;
										y1:=y0+tL*dy
									end;
								if tE>0 then
									begin
										x0:=x0+tE*dx;
										y0:=y0+tE*dy
									end
							end

		end
end; { CLip2D }




procedure CohenSutherland(var x0,y0,x1,y1:NReal; var R: TRectangleNR; var visible:boolean);
var
	codP0,codP1:word;

function PointCodify(x,y:NReal):word;
var
	cod:word;
begin
	cod:=0;
	if x<R.xmin then cod:=1
	else if x>R.xmax then cod:=4;
	if y<R.ymin then cod:=cod or 2
	else if y>R.ymax then cod:=cod or 8;
	PointCodify:=cod;
end;
procedure shortXY(var ax,ay,bx,by:NReal; codA:word);

procedure shortY(x:NReal);
begin
	ay:=by+((x-bx)*(ay-by)) / (ax - bx);
	ax:=x;
end;
procedure shortX(y:NReal);
begin
	ax:=bx+((y-by)*(ax-bx)) /(ay - by);
	ay:=y
end;

begin
	if (codA and 1)<>0 then
			shortY(R.xmin)
	else if (codA and 4)<>0 then
			shortY(R.xmax)
	else if (codA and 2)<>0 then
			shortX(R.ymin)
	else if (codA and 8)<>0 then
			shortX(R.ymax);
end;

function res:boolean;
begin  {res}
	codP0:=pointCodify(x0,y0);
	codP1:=pointCodify(x1,y1);
	if (codP0 or codP1) = 0 then res:=true
	else
		if (codP0 and codP1)<>0 then res:=false
		else
		begin
			if codP0>0 then  shortXY(x0,y0,x1,y1,codP0)
			else shortXY(x1,y1,x0,y0,codP1);
			res :=res
		end;
end; {res}

begin {ClipLine}

	visible:=res;
end; {ClipLine}

end.