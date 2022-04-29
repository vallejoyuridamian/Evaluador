{ 23.02.93 rch test de la unidad buffers }
program tbuffrs;

uses
	xBffrs,
	{$I xCrt};



const
	Texto: string = 'Este es el texto de prueba';
	nc = 10;

type
	PChar = ^Char;
var
	a: TFIFO;
	b: TLIFO;
	k:integer;
	c:char;
  s,t:string;

procedure WRPCHR( x: pointer);far;
begin
	write(char(x^));
end;

procedure PruebaLocal;
var
	s: string;
  lbp: word;

procedure Captura( x: pointer);far;
begin
	s:= s+ char(x^);
end;

begin
	s:= '';
	asm
		mov lbp, BP
  end;
	a.ParaCadaUno_local(ADDR(Captura),lbp);
	writeln(' Resultado de la captura ');
	writeln(s);
end;       

begin   	
	a.init( 10, SIzeOf(char));
	b.init( 10, SizeOf(Char));

	for k:= 1 to nc do
	begin
		a.entrar(texto[k]);
		b.entrar(texto[k]);
	end;



	writeln(' Ojo vienen los PARACADAUNO ');
	PruebaLocal;
	a.ParaCadaUno_Global(WRPCHR);
	b.ParaCadaUno_Global(WRPCHR);


	s:= ''; t :='';
	for k:= 1 to nc do
	begin
		a.sacar(c);
		s:= s+ c;
		b.sacar(c);
		t:= t+c;
	end;

	writeln(s);
	writeln(t);

	a.done;
	b.done;
end.

