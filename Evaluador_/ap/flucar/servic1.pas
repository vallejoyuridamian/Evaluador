	{+doc
	+NOMBRE: SERVIC1
	+CREACION: 1997
	+AUTORES: MARIO VIGNOLO
	+REGISTRO:
	+TIPO: Unidad Pascal
	+OPCIONES DE COMPILACION:
	+PROPOSITO: Unidad de servicios para la unidad NR y el
					programa FLUCAR
	+PROYECTO: FLUCAR (Flujo de carga NR)
	-doc}


	unit servic1;


	interface

	uses
    classes,
    sysutils,
    usistema,algebrac,XMatDefs,MatCPX,TyVs2,barrs2,
		regulado,fun1,links,matadm;


	procedure calcularXv(PV: TVectComplex; B,R:TList;
								nB,nBC,nBcR:integer);

	{Este procedimiento calcula el vector de variables del flujo de carga
	 a partir de los datos de las barras B y de los reguladores R.
	 PV^ es el vector calculado con las fases y los m¢dulos de las tensiones.
	 PN^ es el vector calculado con las relaciones de transformaci¢n de los
	 reguladores.
	 nB, nBC y nBcR es el n£mero de barras, el n£mero de barras de carga y
	 el n£mero de barras con regulador respectivamente que deben ser
	 pasadas como datos al procedimiento}

	procedure calcXvmas1(var Xvmas1,Xv,DXv: TVectComplex);
	
	{Calcula el valor siguiente del vector de variables del sistema de ecuaciones
	de Newton-Raphson (Xvmas1) a partir del valor previo (Xv) y del paso (DXv) }

	procedure calcularevolucion(var histDX,histFX:TVectComplex;
				NIT:integer; nDX,nFX:Nreal);
	
	{Va guardando en histDX las sucesivas normas del paso de la iteración de NR (nDX)
	y en histFX las sucesivas normas de la función objetivo (nFX). NIT es el número
	de la iteración correspondiente.}

	procedure mostrarevolucion (histDX,histFX:TVectComplex;
				Niter,factor:integer);
	
	{Muestra los vectores calculados histDX e histFX. Niter es el número total de
	iteraciones realizadas y factor es un número que divide a Niter para determinar
	cuántos elementos de los vectores deben ser mostrados}

	procedure actualizarbarras(var B: TList; S: TSistema;
					Xv:TVectComplex; nB,nBC,nBcR:integer);
	
	{ Actualiza a partir de los datos del vector de variables del Flujo (Xv) y
	 de las admitancias del sistema (S) los campos de las barras (B). nB y nBC
	 son el n£mero de barras y el n£mero de barras de carga del sistema
	 respectivamente}

	procedure reordenarbarras(BO,B:TList);

	{Vuelve al lugar original las barras que al comienzo se ordenaron según el
	tipo. BO son las barras ordenadas. B son las barras originales tal como
	fueron ingresadas}

	procedure ajustarreguladores(var PX:TVectComplex; var condreg: boolean);
	{Toma el vector de variables del flujo [theta1..theta(n-1) V1...VlV1..Vr]
	y compara V1...Vr con los especificados en las barras con regulador.
	En funci¢n del resultado de la comparaci¢n modifica las relaciones de
	transformaci¢n (cambia taps) y luego modifica la matriz de admitancias}

	procedure muestrarelreg;

	implementation

	procedure calcXvmas1(var Xvmas1, Xv,DXv:TVectComplex);

var

	k:integer;
	res1,res2,res3: NComplex;
	nel:word;
	DXvaux:TVectComplex;

begin
		nel:=DXv.n;
    DXvaux:= TVectComplex.Create_Init( nel );
		DXvaux.copy(DXv);
		for k:=1 to (Nbarrasdecarga+NBarrasconregulador) do
		begin
			DXv.e(res1,k+Nbarras-1);
			Xv.e(res2,k+Nbarras-1);
			res3:=pc(res1,res2)^;
			DXv.pon_e(k+Nbarras-1,res3);
		end;
		Xvmas1.sumvect(Xv,Dxv);
		DXv.copy(DXvaux);
    DXvaux.Free;
end;

	procedure calcularXv( PV:TVectComplex; B,R:TList;
								nB,nBC,nBcR:integer);

	var
		k:integer;
		fasek,modVk,nc: NComplex;

	begin
		for k:=1 to (nB-1) do
		begin
			fasek.r:=fase(TBarra(B[k-1]).V);
			fasek.i:=0;
			PV.pon_e(k,fasek);
		end;
		for k:=1 to nBC do
		begin
			modVk.r:=mod1(TBarra(B[k-1]).V);
			modVk.i:=0;
			PV.pon_e((k+nB-1),modVk);
		end;
		for k:=1 to nBcR do
		begin
			modVk.r:=mod1(TBarra(B[nBC+k-1]).V);
			modVk.i:=0;
			PV.pon_e((k+nBC+nB-1),modVk);
		end;
	end;

	procedure calcularevolucion(var histDX,histFX: TVectComplex;
				NIT:integer;nDX,nFX:Nreal);

	var
		norDXc,norFXc: NComplex;

	begin
		norDXc.r:=nDX;
		norDXc.i:=0;
		histDX.pon_e(NIT,norDXc);
		norFXc.r:=nFX;
		norFXc.i:=0;
		histFX.pon_e(NIT,norFXc);
	end;

	procedure mostrarevolucion (histDX,histFX:TVectComplex;
				Niter,factor:integer);

	var
		k,N:integer;
		xr:Nreal;
		x: NComplex;

	begin
		writeln(' ');
		writeln(' ');
		writeln('histDX');
		N:=Niter div factor;
		for k:=1 to N do
		begin
			histDX.e(x,k*factor);
			xr:=x.r;
			write(' ');
			write(factor*k);
			write(' ');
			write(xr:6:4);
		end;
		writeln(' ');
		writeln('histFX');
		for k:=1 to N do
		begin
			histFX.e(x,factor*k);
			xr:=x.r;
			write(' ');
			write(factor*k);
			write(' ');
			write(xr:6:4);
		end;
		writeln(' ');
	end;



	procedure actualizarbarras(var B:TList; S: TSistema;
								Xv:TVectComplex; nB,nBC,nBcR:integer);

	var
		k:word;
		modVnuevo,deltanuevo,Vrnuevo,Vinuevo:Nreal;

	begin
		for k:=1 to (nBC+nBcR) do   {para las barras de carga y las que tienen
		regulador cuyos datos son P y Q, solo modifico V y delta:
		Vnuevo=Vviejo + DV}
		begin
			modVnuevo:= NComplex(Xv.pte(nB-1+k)^).r;
			deltanuevo:= NComplex(Xv.pte(k)^).r;
			Vrnuevo:=modVnuevo*cos(deltanuevo);
			Vinuevo:=modVnuevo*sin(deltanuevo);
			TBarra(B[k-1]).V.r:=Vrnuevo;
			TBarra(B[k-1]).V.i:=Vinuevo;
		end;
		for k:=nBC+nBcR+1 to nB-1 do     {para las barras de generacion y
		voltaje controlado modifico delta y calculo Q}
		begin
			modVnuevo:=mod1(TBarra(B[k-1]).V);
			deltanuevo:=NComplex(Xv.pte(k)^).r;
			Vrnuevo:=modVnuevo*cos(deltanuevo);
			Vinuevo:=modVnuevo*sin(deltanuevo);
			TBarra(B[k-1]).V.r:=Vrnuevo;
			TBarra(B[k-1]).V.i:=Vinuevo;
			TBarra(B[k-1]).S.i:=reacbarr(Xv,B,S,k,nB,nBC,nBcR);
		end;
		TBarra(B[nB-1]).S.r:=actibarr(Xv,B,S,nB,nB,nBC,nBcR);
		TBarra(B[nB-1]).S.i:=reacbarr(Xv,B,S,nB,nB,nBC,nBcR);
	end;

	procedure reordenarbarras(BO,B:TList);
	var
	r,k:integer;
	begin
  	for r:=1 to NBarras do
		begin
			k:=1;
			while (k<= NBarras)and(r<> TBarra(BO[k-1]).Nro) do inc(k);
			TBarra(B[r-1]).nombre:=TBarra(BO[k-1]).nombre;
			TBarra(B[r-1]).restriccion:=TBarra(BO[k-1]).restriccion;
			TBarra(B[r-1]).S:=TBarra(BO[k-1]).S;
			TBarra(B[r-1]).V:=TBarra(BO[k-1]).V;
		end;
	end;


	procedure ajustarreguladores(var PX:TVectComplex; var condreg: boolean);

	var
		k,i,res,nodo: integer;
		Vr,z,y: NComplex;
		breg,N1,N2:integer;
		encuentro, condregi: boolean;
		s: string;
		n_nuevo,n_viejo,Vrm,Vesp,dn: NReal;

	begin
		condreg:=true;
		for k:=1 to NBarrasconregulador do
		begin
			condregi:=false;
			s:=TBarra(Barrasconregulador[k-1]).Nombre;
			breg:=Func_IndicedeNodo(s, res);
			encuentro:=false;
			i:=1;
			while (i<=NReguladores) and (not encuentro) do
			begin
				if TRegulador(Reguladores[i-1]).Nodo1=breg then
				begin
					encuentro:=true;
					Nodo:=1;
				end
				else
				if TRegulador(Reguladores[i-1]).Nodo2=breg then
				begin
					encuentro:=true;
					Nodo:=2;
				end
				else
				inc(i);
			end;
			if (i>Nreguladores) and (not encuentro) then
			    raise Exception.Create('Existe una barra de tipo 4 que no tiene un regulador asociado');

			{Con el i hallado y el Nodo donde quiero controlar puedo
			hacer el ajuste del n}
			PX.e(Vr,k+NBarras-1+NBarrasdecarga);
			Vrm:=mod1(Vr);
			Vesp:=mod1(TBarra(BarrasconRegulador[k-1]).V);
			dn:=TRegulador(Reguladores[i-1]).delta_n;

			if (abs(Vrm-Vesp)>=Vesp*0.005)
        and( TRegulador(Reguladores[i-1]).n
            *(1-dn)>=TRegulador(Reguladores[i-1]).nmin)
        and( TRegulador(Reguladores[i-1]).n
            *(1+dn)<=TRegulador(Reguladores[i-1]).nmax) then
			begin
				if Nodo=1 then
				begin
					if  Vrm>Vesp then
					with TRegulador(Reguladores[i-1]) do
					begin
						 n_nuevo:=n+dn*n;
					end
					else
					with TRegulador(Reguladores[i-1]) do
					begin
						 n_nuevo:=n-dn*n;
					end;
				end
				else
				begin
					if  Vrm>Vesp then
					with TRegulador(Reguladores[i-1]) do
					begin
						n_nuevo:=n-dn*n;
					end
					else
					with TRegulador(Reguladores[i-1]) do
					begin
						n_nuevo:=n+dn*n;
					end;
				end;
			z:= TRegulador(Reguladores[i-1]).Zcc;
			y:= prc( 1/mod2(z), cc(z)^)^;
			N1:= TRegulador(Reguladores[i-1]).Nodo1;
			N2:= TRegulador(Reguladores[i-1]).Nodo2;
			n_viejo:= TRegulador(Reguladores[i-1]).n;
			SacarT(N1, N2, y, n_viejo);
			PonT(N1,N2,y,n_nuevo);
			TRegulador(Reguladores[i-1]).n:=n_nuevo;
		  end
		  else
		  begin
			condregi:=true;
		  end;
		  condreg:=condreg and condregi;
		end;



	end;

        procedure muestrarelreg;

        var
           k: integer;

        begin
             for k:=1 to NReguladores do
             with TRegulador(Reguladores[k-1]) do
             begin
                  writeln('Regulador: ', k,' ',n);
             end;
        end;


	end.
