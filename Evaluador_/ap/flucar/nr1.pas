{+doc
+NOMBRE: NR1
+CREACION: 1997
+AUTORES: M. PETRUCELLI - MARIO VIGNOLO
+REGISTRO: 
+TIPO: Unidad Pascal
+OPCIONES DE COMPILACION: Existen las siguientes opciones de compilacion:
	1. DEB_NR: Se puede utilizar para debuggear NR. Va mostrando en pantalla
		   los c lculos que va realizando
	2, EVOLUCION: Si se utiliza genera  la evolucion del paso DX y de
		      la funci¢n objetivo F y la va guardando en dos vectores

+PROPOSITO: Implementaci¢n gen‚rica del m‚todo de Newton-Raphson para resolución de
	    sistemas de ecuaciones no lineales
+PROYECTO: FLUCAR (Flujo de carga NR)

-doc}


unit  NR1;

interface
uses
		algebrac,XMatDefs, matCPX,usistema,ecuacs, fun1, servic1;

procedure newtonraphson(var Xv: TVectComplex;var NITER:longint;var converge:boolean;
			epsilonX,epsilonF,f:Nreal; NITMAX:longint);

{El procedimiento newtonraphson toma como variables de entrada el vector Xv: cond.
iniciales para iniciar la iteración, epsilonX: condición de parada para el paso DX,
epsilonF: condición de parada para la función F, f: factor de reducción del paso DX 
y NITMAX: número máximo de iteraciones admitidas.
Las variables de salida son: Xv donde se devuelve la solución del problema, NITER:
número de iteraciones ejecutadas por el método y la variable converge: devuelve
TRUE si la iteración termina por condición de parada dada por los epsilon} 

procedure calcularvector(var PV:TVectComplex; SJ: TSistema);

{Toma los t‚rminos independientes de las ecuaciones del sistema SJ y los almacena
en orden en el vector PV} 

implementation

procedure calcularvector(var PV:TVectComplex; SJ:TSistema);

var
		p:TEcuacion;
		k:word;
		numec:integer;

begin
		numec:=SJ.NumerodeEcuaciones;
		for k:=1 to numec do
		begin
			p:=SJ.NecPtr(k);
			PV.pon_e(k,p.constante);
		end;
end;

procedure newtonraphson(var Xv:TVectComplex;var NITER:longint;var converge:boolean;
			epsilonX,epsilonF,f:Nreal; NITMAX:longint);

var
	rc: NComplex;
	Xvmas1,DXv,FXv,FXvmas1:TVectComplex;
	sistJ:TSistema;
	nel:word;
	NIT, NIT2:longint;
	b, condreg:boolean;
	histdx,histfx: TVectComplex;
	dn: NReal;

begin
		NIT:=0;
		rc.r:=f;
		rc.i:=0;
		converge:=false;
		{creo los vectores que se usan internamente en la unidad}
		nel:=Xv.n;
		Xvmas1:= TVectComplex.Create_Init(nel);
		DXv:= TVectComplex.Create_Init(nel);
		FXv:= TVectComplex.Create_Init(nel);
		FXvmas1:= TVectComplex.Create_Init(nel);
		{$IFDEF EVOLUCION}
		{creo los vectores que se usan si corre EVOLUCION}
		histDX:= TVectComplex.Create_Init(NITMAX);
		histFX:= TVectComplex.Create_Init(NITMAX);
		{$ENDIF}
		{creo el sistema de ecuaciones que se usa en la unidad}
                sistJ:= TSistema.Create_crearsistema( nel );
//		New(sistJ,initcrearsistema(nel));
		{comienzo de la iteracion}
		repeat
			NIT:=NIT+1;
			NIT2:=0;
			write(NIT);
			{$IFDEF DEB_NR}
			writeln('principal',NIT);
			Xv.mostrarvector;
			muestrarelreg;
			readln;
			{$ENDIF}
			calcularFXv(FXv,Xv);
			{$IFDEF DEB_NR}
			write('Fxv');
			fxv.mostrarvector;
			readln;
			{$ENDIF}
			 calcularfunG(sistJ,Xv);
			{$IFDEF DEB_NR}
			sistJ.muestrasistema;
			readln;
			{$ENDIF}
			sistJ.EliGaussPivPar;
			{$IFDEF DEB_NR}
			sistJ^.muestrasistema;
			readln;
			{$ENDIF}
			calcularvector(DXv,sistJ);
			sistJ.Borrartodo;
			{$IFDEF DEB_NR}
			sistJ.muestrasistema;
			write('Dxv');
			Dxv.mostrarvector;
			readln;
			{$ENDIF}
			calcXvmas1(Xvmas1,Xv,Dxv);
			{$IFDEF DEB_NR}
			write('Xvmas1');
			Xvmas1.mostrarvector;
			readln;
			{$ENDIF}
			calcularFXv(FXvmas1,Xvmas1);
			{$IFDEF DEB_NR}
			write('Fxvmas1');
			FXvmas1.mostrarvector;
			b:=FXvmas1.cond_epsilon(epsilonF);
			write(b);
			readln;
			{$ENDIF}
			{$IFDEF EVOLUCION}
			calcularevolucion(
                                          histDX,histFX,NIT,
      			                  DXv.NormEuclid,
                                          FXvmas1.NormEuclid);
			mostrarevolucion(histDX,histFX,NIT,1);
			{$ENDIF}
			while (FXvmas1.normEuclid> FXv.normEuclid)
			and (NIT2<>30) do
			begin
				NIT2:=NIT2+1;
				{$IFDEF DEB_NR}
				writeln('secundario',NIT2);
				writeln('DXv');
				Dxv.mostrarvector;
				readln;
				DXv.PorComplex(rc);
				writeln('DXv*rc');
				Dxv.mostrarvector;
				readln;
				{$ENDIF}
				calcXvmas1(Xvmas1,Xv,DXv);
				calcularFXv(FXvmas1,Xvmas1);
				{$IFDEF DEB_NR}
				writeln('Xv');
				Xv.mostrarvector;
				writeln('Xvmas1');
				Xvmas1.mostrarvector;
				readln;
				writeln( NIT:12, NIT2:12, FXvmas1^.NormEuclid,' dx: ', DXv.NormEuclid);
				writeln('FXVmas1:',FXvmas1.NormEuclid,'FXv:',	FXv.NormEuclid);
				readln;
				{$ENDIF}
			end;
			dn:=0.01;
			ajustarreguladores(Xvmas1,condreg);
			Xv.copy(Xvmas1);
		until ((FXvmas1.cond_epsilon(epsilonF)) and condreg and
			(DXv.cond_epsilon(epsilonX))) or (NIT=NITMAX);
		if ((FXvmas1.cond_epsilon(epsilonF)) and condreg and
		(DXv.cond_epsilon(epsilonX))) then converge:=true;
		NITER:=NIT;
		{Libero memoria}
		DXv.Free;
    FXv.Free;
		FXvmas1.Free;
		{$IFDEF DEB_NR}
		write(memavail,'bytes libres');
		readln;
		{$ENDIF}
		sistJ.Free_destruirsistema;
		{$IFDEF DEB_NR}
		write(memavail,'bytes libres');
		readln;
		{$ENDIF}

end;

end.
