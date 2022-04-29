unit ufunciones_flucar;
interface

uses
  Classes, SysUtils,
  Matcpx, xMatDefs, AlgebraC, uactoresflucar,urawdata;

var
  salaActiva: TSalaFlucar;  // asignar esta variable con la sala activa antes de llamar funciones de este módulo.

function fi( inodo: integer; z: TVectComplex ): NComplex;
function dfidro_V( inodo, kvar, hcampo: integer; z: TVectComplex): NComplex;
function dfidalfa_V( inodo, kvar, hcampo: integer; z: TVectComplex): NComplex;
function dfidP( inodo, kvar, hcampo: integer; z: TVectComplex ): NComplex;
function dfidQ( inodo, kvar, hcampo: integer; z: TVectComplex ): NComplex;
function dfidro_S( inodo, kvar, hcampo: integer; z: TVectComplex ): NComplex;
function dfidalfa_S( inodo, kvar, hcampo: integer; z: TVectComplex ): NComplex;
function dfidtm( inodo, kvar, hcampo: integer; z: TVectComplex): NComplex;
function dfidargtm( inodo, kvar, hcampo: integer; z: TVectComplex): NComplex;
function k2j(kvar:integer):integer;
function j2k(jcol:integer):integer;


implementation


function k2j(kvar:integer):integer;
begin
  k2j:=(kvar-1)div 2 +1;
end;

function j2k(jcol:integer):integer;
begin
 j2k:= (jcol-1)* 2 +1;
end;

function fi( inodo: integer; z: TVectComplex ): NComplex;
var

  res: NComplex;
  knodo, nodo_extremo: integer;
begin
  res:= complex_NULO;

  //(sala.nodos_reguladores.Find(TRaw_Bus(sala.Barras[(iEcuacion - 1)]).I)
  if not ((SalaActiva.nodos_regulados.Find(TRaw_Bus(SalaActiva.Barras[(inodo-1)]).I) > -1) or (SalaActiva.nodos_reguladores.find(TRaw_Bus(SalaActiva.Barras[(inodo-1)]).I) > -1)) then
  begin
         for knodo:= 1 to SalaActiva.nNodos do
            begin
             res:= sc( res, pc( SalaActiva.MY.e( inodo, knodo), z.v[knodo] )^)^;
            end;


  end;

  if (SalaActiva.nodos_regulados.Find(TRaw_Bus(SalaActiva.Barras[(inodo-1)]).I) > -1) then
  begin
       nodo_extremo:=SalaActiva.I_to_N_Barras(TRaw_Bus(SalaActiva.Barras[(inodo-1)]), salaActiva.nodos_reguladores.Integers[SalaActiva.nodos_regulados.Find(TRaw_Bus(SalaActiva.Barras[(inodo-1)]).I)]);
       for knodo:= 1 to SalaActiva.nNodos do
          if not (knodo = nodo_extremo) then
            res:=sc( res, pc( salaActiva.MY.e( inodo, knodo ), z.v[knodo] )^)^;
            res:=sc(res, pc(pc( salaActiva.MY.e( inodo, nodo_extremo), z.v[nodo_extremo] )^,z.v[nodo_extremo+2*SalaActiva.nNodos])^)^;
   end;                                                                                         //

  if (SalaActiva.nodos_reguladores.Find(TRaw_Bus(SalaActiva.Barras[(inodo-1)]).I) > -1) then
  begin
       nodo_extremo:=SalaActiva.I_to_N_Barras(TRaw_Bus(SalaActiva.Barras[(inodo-1)]),SalaActiva.nodos_regulados.Integers[ SalaActiva.nodos_reguladores.Find(TRaw_Bus(SalaActiva.Barras[(inodo-1)]).I)]);
       for knodo:= 1 to SalaActiva.nNodos do
          if not ((knodo = nodo_extremo) or (knodo = inodo)) then
             res:=sc( res, pc( salaActiva.MY.e( inodo , knodo), z.v[knodo] )^)^;
             res:=sc(res, pc(pc( salaActiva.MY.e(inodo, nodo_extremo), z.v[nodo_extremo] )^,z.v[inodo+2*SalaActiva.nNodos])^)^;
             res:=sc(res, pc(z.v[inodo], sc( salaActiva.MY.e( inodo, inodo ), salaActiva.MY.e( inodo, nodo_extremo ))^)^)^;
             res:=sc(res, pc(prc(-1.0,pc(z.v[inodo+2*SalaActiva.nNodos],z.v[inodo+2*SalaActiva.nNodos])^)^,pc(z.v[inodo], salaActiva.MY.e(inodo, nodo_extremo) )^)^)^;

  end;

    {$IFDEF DBG_fi}
        //writeln( 'I'+IntToStr( inodo )+': '+FloatToStrF( mod1(res), ffFixed, 8,2 )+'('+FloatToStrF( fase(res)/pi*180, ffFixed, 6,1 ) );
        //wcln(res);
    {$ENDIF}
        res:= cc( res )^;
        SalaActiva.IiConj.v[inodo]:= res; // guardamos el valor de la intensidad entrante conjungada
  // ahora multiplicamos por la tensión del nodo y
  // le restamos la potencia aparente S(inodo)


  res:= sc( pc( z.v[inodo],res)^, prc( -1, z.v[ SalaActiva.nNodos+inodo] )^)^;
{$IFDEF DBG_fi}
  writeln( 'fi'+IntToStr( inodo )+': '+FloatToStrF( res.r, ffFixed, 8,2 )+'+j'+FloatToStrF( res.i, ffFixed, 8,2 ),' abs ', mod1(res):8:0 );
{$ENDIF}
  result:= res;

end;

function dfidro_V( inodo, kvar, hcampo: integer; z: TVectComplex): NComplex;
var
  res: NComplex;
  alfa_kvar: NReal;
  caux: NComplex;
  tm: NComplex;
  h, m, j, aux: Integer;
  alfa_j: NReal;
  raux,t1,t2,t3,t4: NComplex;
  nodo_extremo:Integer;
begin
  res:= Complex_NULO;
  if (inodo=127) and (kvar=473) then
     j:=1;
  alfa_kvar:= fase( z.v[ kvar ] );
  caux:= numc( cos(alfa_kvar), sin( alfa_kvar ) )^;
  //if kvar= inodo then
  //   res:=  pc( caux, SalaActiva.IiConj.v[inodo] )^;
  //res:= sc( res, pc( z.v[inodo], cc(pc( salaActiva.MY.e(inodo, kvar), caux)^)^)^)^ ;

 //{$IFDEF TAPSf}
    //nodo tipo genérico
    if  (SalaActiva.nodos_reguladores.Find(TRaw_Bus(SalaActiva.Barras[(inodo-1)]).I)=-1) and (SalaActiva.nodos_regulados.Find(TRaw_Bus(SalaActiva.Barras[(inodo-1)]).I)=-1) then
    begin
       alfa_kvar:= fase( z.v[ kvar ] );
       caux:= numc( cos(alfa_kvar), sin( alfa_kvar ) )^;
       if not(kvar= inodo) then
       begin
          res:=  pc( z.v[inodo], cc(pc( salaActiva.MY.e(inodo, kvar), caux)^)^)^ ;
       end
       else
       begin
          res:=  pc( caux, SalaActiva.IiConj.v[inodo] )^;
          res:=  sc( res, prc( mod1(z.v[inodo]), cc(salaActiva.MY.e(inodo, kvar))^)^)^ ;
       end;
    end;

    //nodo tipo regulador
    if (SalaActiva.nodos_reguladores.Find(TRaw_Bus(SalaActiva.Barras[(inodo-1)]).I) > -1) then
    begin
	    m:=inodo;
	    j:=kvar;
            h := SalaActiva.I_to_N_Barras(TRaw_Bus(SalaActiva.Barras[(inodo-1)]),SalaActiva.nodos_regulados.Integers[SalaActiva.nodos_reguladores.Find(TRaw_Bus(SalaActiva.Barras[(inodo-1)]).I)]);

		if (j = h) then
                    begin
                         alfa_j:= fase( z.v[ j ] );
                         caux:= numc( cos(alfa_j), sin( alfa_j) )^;
                         tm:=z.v[2*SalaActiva.nNodos+m];
                         res:=pc(z.v[m],pc(tm,cc(pc( salaActiva.MY.e(m, j), caux)^)^)^)^;
                    end;
                if (j=m) then
                    begin
			alfa_j:=fase(z.v[j]);
			caux:=numc(cos(alfa_j),sin(alfa_j))^;
			h:=SalaActiva.I_to_N_Barras(TRaw_Bus(SalaActiva.Barras[(inodo-1)]),SalaActiva.nodos_regulados.Integers[SalaActiva.nodos_reguladores.Find(TRaw_Bus(SalaActiva.Barras[(inodo-1)]).I)]);
			tm:=z.v[2*SalaActiva.nNodos+m];
			raux:=rc(rc(SalaActiva.IiConj.v[m],cc(pc(z.v[m],salaActiva.MY.e(m, m ))^)^)^,cc(pc(z.v[h],salaActiva.MY.e(m,h))^)^)^;

                        t1:=pc(raux,caux)^;
			t2:=pc(prc(2.0,numc(mod1(z.v[m]),0)^)^,cc(sc(salaActiva.MY.e(m, m),salaActiva.MY.e(h, m))^)^)^;
			t3:=pc(pc(pc(caux,tm)^,cc(z.v[h])^)^,cc(salaActiva.MY.e(m, h))^)^;
			t4:=pc(pc(pc(prc(-2.0,numc(mod1(z.v[m]),0)^)^,tm)^,tm)^,cc(salaActiva.MY.e(m, h))^)^;
			res:=sc(sc(sc(t1,t2)^,t3)^,t4)^;
		    end;
                if not ((j=m) or (j = h)) then
                    begin
                          alfa_kvar:= fase( z.v[ kvar ] );
                          caux:= numc( cos(alfa_kvar), sin( alfa_kvar ) )^;
                          res:=pc( z.v[m], cc(pc( salaActiva.MY.e(m, j), caux)^)^)^;
                    end;
    end;

    //nodo tipo regulado
    if (SalaActiva.nodos_regulados.Find(TRaw_Bus(SalaActiva.Barras[(inodo-1)]).I) > -1) then
    begin
	    h:=inodo;
            j:=kvar;
            m:=SalaActiva.I_to_N_Barras(TRaw_Bus(SalaActiva.Barras[(inodo-1)]),SalaActiva.nodos_reguladores.Integers[SalaActiva.nodos_regulados.Find(TRaw_Bus(SalaActiva.Barras[(inodo-1)]).I)]);

	if not ((j=h) or (j=m)) then
		begin
              alfa_j:= fase( z.v[ j ] );
              caux:= numc( cos(alfa_j), sin( alfa_j ) )^;
              res:=pc( z.v[h], cc(pc( salaActiva.MY.e(h,j), caux)^)^)^;
		end;

		if (j=m)  then
        begin
             alfa_j:= fase( z.v[ j ] );
             caux:= numc( cos(alfa_j), sin( alfa_j) )^;
             tm:=z.v[2*SalaActiva.nNodos+m];
             res:=pc(z.v[h],pc(tm,cc(pc( salaActiva.MY.e(h,j), caux)^)^)^)^;
        end;
		if (j=h) then
		begin
			alfa_j:=fase(z.v[j]);
			caux:=numc(cos(alfa_j),sin(alfa_j))^;
			//m:=nodo_extremo;
			tm:=z.v[2*SalaActiva.nNodos+m];
			
			raux:=rc(SalaActiva.IiConj.v[h],cc(pc(z.v[m],salaActiva.MY.e(h, m))^)^)^;
			t1:=pc(raux,caux)^;
			t2:=pc(z.v[h],cc(pc(caux,salaActiva.MY.e(h, h))^)^)^;
			t3:=pc(pc(pc(caux,tm)^,cc(z.v[m])^)^,cc(salaActiva.MY.e(h, m))^)^;
			res:=sc(sc(t1,t2)^,t3)^;
		end;				
    end;
 //{$ENDIF}

    result:= res;
end;

function dfidalfa_V( inodo, kvar, hcampo: integer; z: TVectComplex): NComplex;
var
  res: NComplex;
  ro_kvar: NReal;
  caux, raux: NComplex;
  t1,t2,t3,t4: NComplex;
  i, j, k, m, h:Integer;
  nodo_extremo:Integer;
begin
  res:= Complex_NULO;


  ro_kvar:= mod1( z.v[ kvar ] );
  //alfa_kvar:= fase( z.v[ kvar ] );
  caux:= numc( 0, ro_kvar )^;
  if kvar= inodo then
     res:=  pc( caux, SalaActiva.IiConj.v[inodo] )^;
     res:= sc( res, pc( z.v[inodo], cc(pc( salaActiva.MY.e(inodo, kvar), caux)^)^)^)^ ;
  //ojo para mi esta mal porque no considera la fase del voltaje

  {$IFDEF TAPSf}
  //nodos tipo genéricos
  if (SalaActiva.nodos_reguladores.Find(TRaw_Bus(SalaActiva.Barras[(inodo-1)]).I)=-1) and (SalaActiva.nodos_regulados.Find(TRaw_Bus(SalaActiva.Barras[(inodo-1)]).I)=-1) then
  begin
       i:=inodo;
       j:=kvar;
       if (not (i = j)) then
			res:=pc(pc(pc(numc(0.0,-1.0)^,z.v[i])^,cc(z.v[j])^)^,cc(salaActiva.MY.e(i, j))^)^;
		if (i=j) then
		begin
			t1:=pc(pc(pc(numc(0.0,-1.0)^,z.v[j])^,cc(z.v[j])^)^,cc(salaActiva.MY.e(j, j))^)^;
			t2:=pc(pc(numc(0.0,1.0)^,z.v[j])^,SalaActiva.IiConj.v[j])^;
			res:=sc(t1,t2)^;
		end;
  end;
  //nodos tipo reguladores
  if (SalaActiva.nodos_reguladores.Find(TRaw_Bus(SalaActiva.Barras[(inodo-1)]).I)>-1) then
  begin
		m:=inodo;
		j:=kvar;
                h:=SalaActiva.I_to_N_Barras(TRaw_Bus(SalaActiva.Barras[(inodo-1)]),SalaActiva.nodos_regulados.Integers[SalaActiva.nodos_reguladores.Find(TRaw_Bus(SalaActiva.Barras[(inodo-1)]).I)]);
		if (j=h) then
		begin
			h:=j;
			res:=pc(pc(pc(numc(0.0,-1.0)^,z.v[m])^,z.v[m+2*SalaActiva.nNodos])^,cc(pc(z.v[h],salaActiva.MY.e(m, h))^)^)^;
		end;
		if (not ((j=m) or (j=nodo_extremo))) then
		begin
			res:=pc(pc(pc(numc(0.0,-1.0)^,z.v[m])^,cc(z.v[j])^)^,cc(salaActiva.MY.e(m, j))^)^;
		end;
		if (j=m) then
		begin
			//h:=nodo_extremo;
			raux:=rc(rc(SalaActiva.IiConj.v[m],cc(pc(z.v[m],salaActiva.MY.e(m, m))^)^)^,cc(pc(z.v[h],salaActiva.MY.e(m, h))^)^)^;
			t1:=pc(pc(raux,numc(0.0,1.0)^)^,z.v[m])^;
			t2:=pc(pc(pc(numc(0.0,1.0)^,z.v[m])^,z.v[m+2*SalaActiva.nNodos])^,cc(pc(z.v[h],salaActiva.MY.e( m, h ))^)^)^;
			res:=sc(t1,t2)^;
		end;		
  end;

  //nodos tipo regulados
  if (SalaActiva.nodos_regulados.Find(TRaw_Bus(SalaActiva.Barras[(inodo-1)]).I) > -1 ) then
  begin
		h:=inodo;
		j:=kvar;
                nodo_extremo:=SalaActiva.I_to_N_Barras(TRaw_Bus(SalaActiva.Barras[(inodo-1)]),SalaActiva.nodos_reguladores.Integers[SalaActiva.nodos_regulados.Find(TRaw_Bus(SalaActiva.Barras[(inodo-1)]).I)]);
		if (h=j) then
		begin
			m:=SalaActiva.I_to_N_Barras(TRaw_Bus(SalaActiva.Barras[(inodo-1)]),SalaActiva.nodos_reguladores.Integers[SalaActiva.nodos_regulados.Find(TRaw_Bus(SalaActiva.Barras[(inodo-1)]).I)]);
			raux:=rc(SalaActiva.IiConj.v[h],cc(pc(z.v[m],salaActiva.MY.e(h, m))^)^)^;
			t1:=pc(pc(raux,numc(0.0,1.0)^)^,z.v[h])^;
			t2:=pc(pc(pc(numc(0.0,-1.0)^,z.v[h])^,cc(z.v[h])^)^,cc(salaActiva.MY.e(h, h))^)^;
			t3:=pc(pc(pc(numc(0.0,1.0)^,z.v[m+2*SalaActiva.nNodos])^,z.v[h])^,cc(pc(z.v[m],salaActiva.MY.e(h, m))^)^)^;
			res:=sc(sc(t1,t2)^,t3)^;
		end;
		if (j=nodo_extremo) then
		begin
			m:=j;
			res:=pc(pc(pc(numc(0.0,-1.0)^,z.v[m+2*SalaActiva.nNodos])^,z.v[h])^,cc(pc(z.v[m],salaActiva.MY.e(h, m))^)^)^;
		end;
		if (not ((j=h) or (j=nodo_extremo))) then
		begin
			res:=pc(pc(pc(numc(0.0,-1.0)^,z.v[h])^,cc(z.v[j])^)^,cc(salaActiva.MY.e(h, j))^)^;
		end;
  end;
  {$ENDIF}

  result:= res;
end;

function dfidP( inodo, kvar, hcampo: integer; z: TVectComplex ): NComplex;
var
  res: NComplex;
  inodo_S: integer;
begin
  res:= Complex_NULO;
  inodo_S:= kvar - SalaActiva.nNodos; // nodo al que pertenece la potencia Aparente
  if  inodo_S= inodo then
      res:= numc( -1, 0 )^;
  result:= res;
end;

function dfidQ( inodo, kvar, hcampo: integer; z: TVectComplex ): NComplex;
var
  res: NComplex;
  inodo_S: integer;
begin
  res:= Complex_NULO;
  inodo_S:= kvar - SalaActiva.nNodos; // nodo al que pertenece la potencia Aparente
  if  inodo_S= inodo then
      res:= numc( 0, -1 )^;
  result:= res;
end;

function dfidro_S( inodo, kvar, hcampo: integer; z: TVectComplex ): NComplex;
var
  res: NComplex;
  inodo_S: integer;
  a: NReal;
begin
  res:= Complex_NULO;
  inodo_S:= kvar - SalaActiva.nNodos; // nodo al que pertenece la potencia Aparente
  if  inodo_S= inodo then
  begin
    a:= mod1( z.v[kvar] );
    if abs( a ) > AsumaCero then
      res:= prc( -1/a, z.v[kvar] )^
    else
      res:= complex_UNO;
  end;
  result:= res;
end;


function dfidalfa_S( inodo, kvar, hcampo: integer; z: TVectComplex ): NComplex;
var
  res: NComplex;
  inodo_S: integer;
  a: NReal;
begin
  res:= Complex_NULO;
  inodo_S:= kvar - SalaActiva.nNodos; // nodo al que pertenece la potencia Aparente
  if  inodo_S= inodo then
  begin
    a:= mod1( z.v[kvar] );
    res:= numc( 0, -a )^;
  end;
  result:= res;
  //ojo para mi es distinto porque no está considerando la fase de Sk
end;

function dfidtm( inodo, kvar, hcampo: integer; z: TVectComplex): NComplex;
var
  res: NComplex;
  aux1,aux2: NComplex;
  nodo_extremo,nodo_extremo1:Integer;
 begin
     res:= Complex_NULO;
     nodo_extremo:=SalaActiva.I_to_N_Barras(TRaw_Bus(SalaActiva.Barras[(kvar-2*SalaActiva.nNodos-1)]),TRaw_Bus(SalaActiva.Barras[(kvar-2*SalaActiva.nNodos-1)]).I);

     if (SalaActiva.nodos_reguladores.Find(TRaw_Bus(SalaActiva.Barras[(inodo-1)]).I)=-1) and (SalaActiva.nodos_regulados.Find(TRaw_Bus(SalaActiva.Barras[(inodo-1)]).I)=-1) then
     begin

     end;

     if (SalaActiva.nodos_reguladores.Find(TRaw_Bus(SalaActiva.Barras[(inodo-1)]).I)>-1) and (inodo=nodo_extremo) then
     begin
        nodo_extremo:= SalaActiva.I_to_N_Barras(TRaw_Bus(SalaActiva.Barras[(inodo-1)]),SalaActiva.nodos_regulados.Integers[SalaActiva.nodos_reguladores.Find(TRaw_Bus(SalaActiva.Barras[(inodo-1)]).I)]);
        aux1:=pc(pc(z.v[inodo],cc(z.v[nodo_extremo])^)^,cc(salaActiva.MY.e( inodo, nodo_extremo ))^)^;
        aux2:=pc(prc(-2.0,z.v[inodo])^,z.v[2*SalaActiva.nNodos+inodo])^;
        aux2:=pc(pc(aux2,cc(z.v[inodo])^)^,cc(salaActiva.MY.e( inodo, nodo_extremo ))^)^;
        res:=sc(aux1,aux2)^;
     end;

     if (SalaActiva.nodos_regulados.Find(TRaw_Bus(SalaActiva.Barras[(inodo-1)]).I)>-1) then
     begin
         //nodo_extremo:= SalaActiva.I_to_N_Barras(TRaw_Bus(SalaActiva.Barras[(inodo-1)]),SalaActiva.nodos_reguladores.Integers[SalaActiva.nodos_regulados.Find(TRaw_Bus(SalaActiva.Barras[(inodo-1)]).I)]);
         aux1:=pc(pc(z.v[inodo],cc(z.v[nodo_extremo])^)^,cc(salaActiva.MY.e( inodo, nodo_extremo ))^)^;
         res:=aux1;
     end;

     result:=res;
end;

function dfidargtm( inodo, kvar, hcampo: integer; z: TVectComplex): NComplex;
begin
     result:=Complex_UNO;
end;
end.

