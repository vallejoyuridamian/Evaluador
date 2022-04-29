{$APPTYPE CONSOLE}
program test1;
uses
	sysutils,  uimptraxpdll;

var
	k: integer;
begin
	writeln('hola');
readln;
	ShowForm;
	xlabel('hola');
	gridx;
	gridy;
	borde;
	for k:= 1 to 1000000 do
	begin
		PlotNuevo_x( k*10 );
		PlotNuevo_y( 1, 100 * (1+cos( 2*pi*k/100 )));
	end;
	
end.