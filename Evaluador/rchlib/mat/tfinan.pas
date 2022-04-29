{ test de las funciones financieras VAN y TIR }
program tfinan;
uses
	xMatDefs, ComPol2, Financie;

var
	Ingresos: TPoliR;
	k:integer;
	xTir, xvan, xx: NReal;
	resTIR: boolean;
  fo: File of NReal;


begin

  
	Ingresos.Init(1000);
	Ingresos.Gr:= 800;
  Ingresos.pon_e(1, 5);
	for k:= 2 to Ingresos.Gr+1 do
  		Ingresos.pon_e(k, frac((Ingresos.e(k-1)*3)/30)*30 );

	for k:= 1 to Ingresos.Gr+1 do
  if k mod 5 = 0 then
			Ingresos.pon_e(k, -10);
	Ingresos.pon_e(1, -10);

  assign(fo, 'tmp.tmp');
	rewrite(fo);
	for k:= 1 to Ingresos.gr+1 do
	begin
		xx:=Ingresos.e(k);
		write(fo,xx );
	end;
	close(fo);

	writeln('VAN12%: ', van(Ingresos, 0.12):8:2);
	xTIR:=TIR(Ingresos, resTir, xvan);
	if resTir then writeln('TIR: ', xTIR: 8:5, xvan: 8:5)
	else writeln('No fue posible calcular el TIR', xTIR: 8:5);

end.
