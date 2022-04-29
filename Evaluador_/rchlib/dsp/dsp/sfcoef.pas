{+doc
+NOMBRE: sfcoef
+CREACION: 7.2.93
+AUTORES:  rch
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO:   Definicion de las clases: TCoefSerieFourier y TSerieFourier
+PROYECTO:

+REVISION:
+AUTOR:
+DESCRIPCION:
	TCoefSerieFourier, esta pensado para guardar los arm¢nicos > 0. El
	t‚rmino constante se guarda directamente en TSerieFourier.
		TSerieFourier, es para declararla decendiente de (FReal)
	pero como no tengo claro el standar para (FReal) no lo he echo.
-doc}

unit SFCOEF;
interface
uses
	{$I xObjects},
	xMatDefs;


type

	PCoefSerieFourier = ^TCoefSerieFourier;
	TCoefSerieFourier = object( TObject )

		Orden: LongInt;
		wn: real;
		a, b:real;

		constructor Init_ab(
			xOrden: LongInt;
			w1, xa, xb: real );
		constructor Init_cn(
			xOrden: LongInt;
			w1: real;
			cn_ParteReal, cn_ParteImaginaria: real );

		function Valor( t: real ):real;

		procedure Store( var s: TStream ); virtual;
		constructor Load( var s: TStream );

		destructor Done;virtual;
	end;

const
  RCoefSerieFourier: TStreamRec = (	 ObjType: 4001;
	 VmtLink: Ofs(TypeOf(TCoefSerieFourier)^);
	 Load:    @TCoefSerieFourier.Load;
	 Store:   @TCoefSerieFourier.Store
  );

type

	TSerieFourier = object(TObject)
		w1: real;
		a0:real;
		coefs: TCollection;

		constructor Init(
			xw1: real;
			ALimit, ADelta: Integer);

		function Valor( t: real ):real;

		procedure AgregarCoef_ab(
			Orden: LongInt;
			a,b: real );

		procedure AgregarCoef_cn(
			Orden: LongInt;
			cn_ParteReal, cn_ParteImaginaria: real );

		procedure Fijar_a0( xa0: real);
		procedure Store( var s: TStream ); virtual;
		constructor Load( var s: TStream );

		destructor Done;virtual;
	end;


const
  RSerieFourier: TStreamRec = (	 ObjType: 4002;
	 VmtLink: Ofs(TypeOf(TSerieFourier)^);
	 Load:    @TSerieFourier.Load;
	 Store:   @TSerieFourier.Store
  );

procedure RegisterSFCOEF;

implementation

procedure RegisterSFCOEF;
begin
	RegisterType( RCoefSerieFourier );
	RegisterType( RSerieFourier );
end;
{ M‚todos de  TCoefSerieFourier }

constructor TCoefSerieFourier.Init_ab(
			xOrden: LongInt;
			w1, xa, xb :real );
begin
	Orden:= xOrden;
	wn:= Orden * w1;
	a:= xa;
	b:= xb;
end;

constructor TCoefSerieFourier.Init_cn(
			xOrden: LongInt;
			w1: real;
			cn_ParteReal, cn_ParteImaginaria: real );
var
	xa,xb:real;
begin
	xa:= 2*cn_ParteReal;
	xb:= -2*cn_ParteReal;
	Init_ab(xOrden,w1,xa,xb);
end;


function TCoefSerieFourier.Valor( t: real ):real;
begin
	Valor:= a* cos( wn* t)+ b* sin( wn* t)
end;

procedure TCoefSerieFourier.Store( var s: TStream );
begin
	S.Write(Orden, SizeOf(Orden));
	S.Write(wn, SizeOf(wn));
	S.Write(a, SizeOf(a));
	S.Write(b, SizeOf(b));
end;

constructor TCoefSerieFourier.Load( var s: TStream );
begin
	S.Read(Orden, SizeOf(Orden));
	S.Read(wn, SizeOf(wn));
	S.Read(a, SizeOf(a));
	S.Read(b, SizeOf(b));
end;


destructor TCoefSerieFourier.Done;
begin
end;


{ M‚todos de TSerieFourier. }

constructor TSerieFourier.Init(
	xw1: real;
	ALimit, ADelta: Integer);
begin
	w1:= xw1;
	coefs.Init(Alimit, ADelta);
end;

procedure TSerieFourier.Fijar_a0( xa0: real);
begin
	a0:= xa0;
end;


{ func. Valor ------------------------------------}
function TSerieFourier.Valor( t: real ):real;

var
	a:real;

{ Proc. Local para ForEach }
	procedure armonica( c:PCoefSerieFourier );
	begin
		a:= a+c^.valor(t);
	end;

{ Cuerpo de func. Valor }
begin
	a:= a0;
	coefs.ForEach(@armonica);
end; { fin func. Valor }


procedure TSerieFourier.AgregarCoef_ab(
			Orden: LongInt;
			a,b: real );
begin
	coefs.Insert( new(PCoefSerieFourier, Init_ab(Orden, w1, a, b)));
end;


procedure TSerieFourier.AgregarCoef_cn(
			Orden: LongInt;
			cn_ParteReal, cn_ParteImaginaria: real );
begin
	coefs.Insert(
		new(
			PCoefSerieFourier,
			Init_cn(Orden, w1, cn_ParteReal, cn_ParteImaginaria)));
end;


procedure TSerieFourier.Store( var S: TStream );
begin
	S.Write( w1, SizeOf(w1));
	S.Write( a0, SizeOf(a0));
	coefs.Store(S);
end;

constructor TSerieFourier.Load( var s: TStream );
begin
	S.Read( w1, SizeOf(w1));
	S.Read( a0, SizeOf(a0));
	coefs.Load(S);
end;


destructor TSerieFourier.Done;
begin
	coefs.done;
end;

end.