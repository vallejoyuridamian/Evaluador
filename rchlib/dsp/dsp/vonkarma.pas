{
	Inversion del espectro de VON KARMAN para obtener su autocorrelacion
}

program t_fftb;
uses
	xMatDefs;
var
	fout: File of NREal;
	f, a: NREal;
	k: integer;

	KA, KB, KC: NReal;
	Sigma_u : NReal;
	L_u_X: NReal;
	U: NReal;

const
	f1 = 1/3600;
	f2 = 100;
	ftot = f2;     { ancho de la ventana de muestreo }
	N = 3000; 		{ numero de muestras }
	fs = ftot/N;	{ intervalo entre muestras de frecuencia }
	T = 1/fs; 		{ periodo resulatante en el tiempo }
	ts = 1/ftot;   { distancia entre las muestras de tiempo }
	omega = 3.1416 / ftot;  { para la ventana de Hanning }



function power( x, y: NReal ): Nreal;
begin
	power:=	exp( y * ln ( x ));
end;

function ventana(f: NReal ): NReal;
begin
	ventana:= 0.5*(1+cos( omega * f));
end;

function HF(f: NReal):NReal;
begin
	if f< f1 then  HF:= 0
	else HF:= KA / power( 1+ KB * sqr( f ), KC) {* ventana(f)};
end;

begin
	Sigma_u := 5;
	U:= 12;
	L_u_x := 0.18;
	KA := sqr(Sigma_u)*L_u_x/U*4;
	KB := 70.8 * sqr( L_u_x /U );
	KC := 5/6;
	assign( fout, 'vonkarma.aab' );
	rewrite(fout);

	f:= 0;
	a:= HF(0) * fs;
	write(fout, a);
	for k:= 1 to N do
	begin
		f:= fs * k;
		a:= 2*HF(f) *fs;
		write(fout, a);
	end;
	a:= 0;
	for k:= 1 to N do write(fout, a );
	close(fout);
end.





