program tstrchfn;
uses
	Graph,gr,rchfonts;

begin
	gr.init;

	SetFillStyle(SolidFill,blanco);
	bar(1,2,200,200);

	SetTextJustify(just_DERECHA,just_ARRIBA);
	OutTextXY(100,100,'100/100JDArr');
	readln;
	SetTextJustify(just_DERECHA,just_ABAJO);
	OutTextXY(100,100,'100/100JDAba');
	readln;
	SetTextJustify(just_IZQUIERDA,just_ABAJO);
	OutTextXY(100,100,'100/100JIAba');
	readln;
	SetTextJustify(just_IZQUIERDA,just_ARRIBA);
	OutTextXY(100,100,'100/100JIArr');
	readln;
	linexy(100,100,150,150);
	readln;

	ClearViewPort;

	SetFillStyle(SolidFill,blanco);
	bar(1,2,200,200);

	SetTextStyle(StandardFont,VertDir,1);
	SetTextJustify(just_DERECHA,just_ARRIBA);
	OutTextXY(100,100,'100/100JDArr');
	readln;
	SetTextJustify(just_DERECHA,just_ABAJO);
	OutTextXY(100,100,'100/100JDAba');
	readln;
	SetTextJustify(just_IZQUIERDA,just_ABAJO);
	OutTextXY(100,100,'100/100JIAba');
	readln;
	SetTextJustify(just_IZQUIERDA,just_ARRIBA);
	OutTextXY(100,100,'100/100JIArr');
	readln;
	linexy(100,100,150,150);
	readln;
end.