{+doc
+NOMBRE:  ENTDAT
+CREACION:
+MODIFICACION:  8/97
+AUTORES:  MARIO VIGNOLO
+REGISTRO:
+TIPO:  Unidad Pascal
+PROPOSITO:  Implementaci¢n de la entrada de datos para FLUCAR 1.1
+PROYECTO: FLUCAR

+REVISION:
+AUTOR:
+DESCRIPCION:
-doc}

unit entdat;

interface
uses
  classes,
  sysutils,
	horrores, Lexemas32,
        AlgebraC, xMatDefs,
 Links, Barrs2,
        Impds1, Cuadri1, Trafos1,
        Regulado;

var
	EsperoID: boolean;

procedure LeerDatos( ArchDef: string);

implementation

procedure LEERBARRAS( var a: TFlujoLetras; var r: string; var tipodeBarra: TRestricciondeNodo);
var

i: integer;
PBarraN: TBarra;

begin
		NBARRAS:=0;
		NBarrasdecarga:=0;
		NBarrasdegenyvcont:=0;
		NBarrasconregulador:=0;
		GetLexema( r, a);
		while (r<>'+') do
		begin { leeo una barra }
			{ Ide }
			inc(NBARRAS);
			PBarraN:=  TBarra.LeerDeFljLetras(a,r,tipodeBarra);
			PBarraN.Nro:=NBarras;
			Barras.add(PBarraN);
			if tipodeBarra = [cf_P, cf_Q]  then
				begin
				  inc(NBARRASDECARGA);
				  BarrasdeCarga.add(PBarraN);
				end;
			if tipodeBarra = [cf_P, cf_V] then
				begin
				  inc(nbarrasdegenyvcont);
				  BarrasdeGenyVcont.add(PBarraN);
				end;
			if tipodeBarra = [cf_P, cf_Q, cf_V] then
				begin
				  inc(nbarrasconregulador);
				  Barrasconregulador.add(PBarraN);
				end;
			if tipodeBarra = [cf_V, cf_delta] then
				begin
(*** OJO tal como estaba esto me parece que BarraFlotante es otra instancia
					Barraflotante.Init(PBarraN^.Nombre,PBarraN^.restriccion,
					PBarraN^.S.r,PBarraN^.S.i,mod1(PBarraN^.V),fase(PBarraN^.V));
					Barraflotante^.Nro:=PBarraN^.Nro;
*)
					Barraflotante:= PBarraN;

				end;
		  GetLexema( r, a);
		  end; {while}
		  Nbarrasordenadas:=0;
		  for i:=1 to Nbarrasdecarga do
			begin
				inc(nbarrasordenadas);
				BarrasOrdenadas.add(TBarra(BarrasdeCarga[i-1]));
			end;
		  for i:=1 to Nbarrasconregulador do
			begin
				inc(nbarrasordenadas);
				BarrasOrdenadas.add(TBarra(Barrasconregulador[i-1]));
			end;
		  for i:=1 to nbarrasdegenyvcont do
			begin
				inc(nbarrasordenadas);
				BarrasOrdenadas.add(TBarra(BarrasdeGenyVcont[i-1]));
			end;
		  inc(nbarrasordenadas);
      // atención la última de las BarrasOrdenadas es la flotante
		  BarrasOrdenadas.add(BarraFlotante);
		  end;

procedure LEERIMPEDANCIAS( var a: TFlujoLetras; var r: string);

var
	PImpedanciaN: TImpedancia;

begin
		NImpedancias:=0;
		GetLexema( r, a);
		while r<>'+' do
		begin { leeo una Impedancia }
			{ Ide }
			inc(NImpedancias);
			PImpedanciaN:= TImpedancia.LeerDeFljLetras( a, r);
			Impedancias.add(PImpedanciaN);
			GetLexema( r, a);
		end; { while }
end;

procedure LEERCUADRIPOLOSPI( var a: TFlujoLetras; var r: string);

var
	PCuadripoloPiN: TCuadripoloPi;


begin
		NCuadripolosPi:=0;
		GetLexema( r, a);
		while r<>'+' do
		begin { leeo un cuadripolo }
			{ Ide }
			inc(NCuadripolosPi);
			PCuadripoloPiN:= TCuadripoloPi.LeerDeFljLetras( a, r);
			Cuadripolos.add(PCuadripoloPiN);
			GetLexema( r, a);
		end; { while }
end;

procedure LEERTOLERANCIA( var a: TFlujoLetras; var r: string);
var
	res: integer;
begin
		res:= LeerNReal(a, Tolerancia);
		if res <> 0 then error('leyendo tolerancia');
		getlexema(r,a);
end;

procedure LEERNITS( var a: TFlujoLetras; var r: string);
var
	res: integer;
begin
		res:= LeerNInteger(a, MAXNITs);
		if res <> 0 then error('leyendo iteraciones');
		getlexema(r,a);
end;

procedure LEERTRAFOS( var a: TFlujoLetras; var r: string);

var
	PTrafoN: TTrafo;

begin
		NTrafos:=0;
		GetLexema( r, a);
		while r<>'+' do
		begin { leeo un Trafo }
			{ Ide }
			inc(NTrafos);
			PTrafoN:= TTrafo.LeerDeFljLetras( a, r);
			Trafos.add(PTrafoN);
			GetLexema( r, a);
		end; { while }
end;


procedure LEERREGULADORES( var a: TFlujoLetras; var r: string);

var
	PReguladorN: TRegulador;

begin
		NReguladores:=0;
		GetLexema( r, a);
		while r<>'+' do
		begin { leeo un Regulador }
			{ Ide }
			inc(NReguladores);
			PReguladorN:= TRegulador.LeerDeFljLetras( a, r);
			Reguladores.add(PReguladorN);
			GetLexema( r, a);
		end; { while }
end;




procedure LeerDatos( ArchDef: string);
var
	f: TStream;
	r: string;
	a: TFlujoLetras;
	tipodeBarra: TRestriccionDeNodo;
	finlectura:boolean;
	{$IFDEF WINDOWS}
	pstr: PCHAR;
  {$ENDIF}

begin
  try
  	f:= TFileStream.Create(ArchDef, fmOpenRead );
  except
		raise Exception.Create(' Error abriendo archivo '+ ArchDef);
  end;

  a:= TFlujoLetras.Create(f);

	finlectura:= false;
	EsperoID:= false;
  try
    repeat
      GetLexema( r, a);
      if EsperoID then
      begin
        EsperoID := false;
         if r = 'BARRAS' then
          LEERBARRAS(a,r,tipodeBarra)
        else if r = 'IMPEDANCIAS' then
          LEERIMPEDANCIAS(a,r)
        else if r = 'CUADRIPOLOSPI' then
          LEERCUADRIPOLOSPI(a, r)
        else if r= 'TRAFOS' then
          LEERTRAFOS(a,r)
        else if r= 'REGULADORES' then
          LEERREGULADORES(a,r)
        else if r = 'TOLERANCIA' then
          LEERTOLERANCIA(a,r)
        else if r = 'NITS' then
          LEERNITS(a,r)
        else if r = 'FIN.' then
          finlectura := true;
      end;
      if r='+' then EsperoID := true;
      write(r); { caracteres no procesados }
    until finlectura;
  finally
  	f.Free;
  end;
end;


end.
