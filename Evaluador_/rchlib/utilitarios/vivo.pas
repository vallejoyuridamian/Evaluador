{+doc
+NOMBRE: vivotxt
+CREACION: 23/7/93
+AUTORES: rch
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO:  crear el objeto TVivoTxt el cual es un indicador de que un
	programa est  corriendo.

+PROYECTO:

+REVISION:
+AUTOR:
+DESCRIPCION: Es para utilizar cuando el monitor est  en modo texto, cuando
tenga m s tiempo lo implemento tambi‚n para modo gr fico.

-doc}

unit Vivo;
interface

const
	NumeroDeSimbolosDeRueda=4;
	SimbolosDeRueda: array[0..NumeroDeSimbolosDeRueda-1] of char =
												('|','/','-','\');
type

	TVivoTxt = object
		estado: integer;
		constructor Init;
		procedure girar;
		procedure avanzar;
	end;

implementation

procedure wrs( K:integer );
begin
	write( SimbolosDeRueda[k]);
end;


constructor TVivoTxt.Init;
begin
	estado:= 0;
end;

procedure TVivoTxt.girar;
begin
	estado:= (estado +1)mod NumeroDeSimbolosDeRueda;
	write(#08);
	wrs(estado);
end;

procedure TVivoTxt.avanzar;
begin
	write(#08);
	write('  ');
	girar;
end;


end.