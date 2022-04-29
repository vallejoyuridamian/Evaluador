{ como test del programa t_fftb, se suguiere correr esta que genera
una archivo con los coeficientes de la serie correspondiente a un escalon
muestreado }


program t_fftb;
uses
	xMatDefs;
var
	fout: File of NREal;
	f, a: NREal;
	k: integer;

const
	tau = 0.1;		{ ancho del pulso }
	N = 3000; 		{ numero de muestras }
	fs = 1;  		{ intervalo entre muestras de frecuencia }
	T = 1/fs; 		{ periodo resulatante en el tiempo }
	ftot = fs * N;	{ ancho de la ventana de muestreo }
	ts = 1/ftot;   { distancia entre las muestras de tiempo }
	omega = 3.1416 / ftot;



function ventana(f: NReal ): NReal;
begin
	ventana:= 0.5*(1+cos( omega * f));
end;

function HF(f: NReal):NReal;
begin
	if EsCero(f) then HF:= tau
	else HF:= tau* sin(pi *tau/T*f)/(pi * tau /T * f) * ventana(f);
end;

begin

	assign( fout, 't_fftb.aab' );
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





