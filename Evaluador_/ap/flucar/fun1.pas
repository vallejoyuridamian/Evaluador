{+doc
+NOMBRE:  FUN1
+CREACION:  8/97
+MODIFICACION:
+AUTORES:  MARIO VIGNOLO
+REGISTRO:
+TIPO:
+PROPOSITO:	C lculo de la fuci¢n objetivo del Flujo de Carga y
				de su Jacobiano
+PROYECTO:  FLUCAR

+REVISION:
+AUTOR:
+DESCRIPCION:
-doc}




unit fun1;

interface
uses
  Classes, TyVs2, XMatDefs, MatCPX, barrs2, usistema, algebrac;

procedure calcularFXv(var FXv: TVectComplex; Xv: TVectComplex);
{Calcula la funci¢n objetivo a partir del vector de variables Xv}

procedure calcularfunG(var SJ: TSistema; Xv:TVectComplex);
{Calcula el sistema de ecuaciones lineales que surge de la aproximación
de primer orden de la funci¢n objetivo}

function reacbarr(PX:TVectComplex; B: TList;
			S:TSistema; k:TIndice;nB,nBC,nBcR:integer):Nreal;
{Calcula la potencia reactiva entrante al nodo k}

function actibarr(PX:TVectComplex; B:TList;
			S:TSistema; k:TIndice; nB,nBC,nBcR:integer):Nreal;
{Calcula la potencia activa entrante al nodo k}

implementation

function reacbarr(PX: TVectComplex; B:TList;
			S:TSistema; k:TIndice;nB,nBC,nBcR:integer):Nreal;
											{calcula la potencia reactiva
												en la barra k a partir de los
												valores de tension y las
												impedancias de la red}

	var
		modVkc,modVjc,fasekc,fasejc,res: NComplex;
		sum,gki,bki,modVk,modVj,fasek,fasej:Nreal;
		j:TIndice;
		n:integer;
		Val:boolean;

	begin
		sum:=0;
		if ( k<=nBC+nBcR) then
		begin
			PX.e(modVkc,k+nB-1); {modVk:=X(k+nB-1).r}
			modVk:=modVkc.r;
		end
		else
		begin
			modVk:=mod1(TBarra(B[k-1]).V);
		end;
		if k<>nB then
		begin
			PX.e(fasekc,k);
			fasek:=fasekc.r;
		end
		else
		begin
			fasek:=fase(TBarra(B[k-1]).V);
		end;
		for j:=1 to NBarras do
		begin
			Val:=S.Valcoef(res,k,j);
			bki:=res.i;
			gki:=res.r;
			if ( j<=nBC+nBcR) then
			begin
				PX.e(modVjc,j+nB-1);  {modVj:=X(j+nB-1)}
				modVj:=modVjc.r;
			end
			else
			begin
				modVj:=mod1(TBarra(B[j-1]).V);
			end;
			if j<>nB then
			begin
				PX.e(fasejc,j);
				fasej:=fasejc.r;
			end
			else
			begin
				fasej:=fase(TBarra(B[j-1]).V);
			end;
			sum:=sum+ modVk*modVj*(gki*sin(fasek-
			fasej)-bki*cos(fasek-fasej));
			end; {end for}
			reacbarr:=sum;
		end;

	function actibarr(PX:TVectComplex; B:TList;
			S:TSistema; k:TIndice; nB,nBC,nBcR:integer):Nreal;
						{calcula la potencia activa
						en la barra k a partir de los
						valores de tension y las
						impedancias de la red}

	var
		modVkc,modVjc,fasekc,fasejc,res: NComplex;
		sum,gki,bki,modVk,modVj,fasek,fasej:Nreal;
		j:TIndice;
		n:integer;
		Val:boolean;

	begin
		sum:=0;
		if ( k<=nBC+nBcR) then
		begin
			PX.e(modVkc,k+nB-1); {modVk:=X(k+nB-1).r}
			modVk:=modVkc.r;
		end
		else
		begin
			modVk:=mod1(TBarra(B[k-1]).V);
		end;
		if k<>nB then
		begin
			PX.e(fasekc,k);
			fasek:=fasekc.r;
		end
		else
		begin
			fasek:=fase(TBarra(B[k-1]).V);
		end;
		for j:=1 to NBarras do
		begin
			Val:=S.Valcoef(res,k,j);
			bki:=res.i;
			gki:=res.r;
			if ( j<=nBC+nBcR) then
			begin
				PX.e(modVjc,j+nB-1);  {modVj:=X(j+nB-1)}
				modVj:=modVjc.r;
			end
			else
			begin
			modVj:=mod1(TBarra(B[j-1]).V);
			end;
			if j<>nB then
			begin
				PX.e(fasejc,j);
				fasej:=fasejc.r;
			end
			else
			begin
				fasej:=fase(TBarra(B[j-1]).V);
			end;
			sum:=sum+modVk*modVj*(gki*
			cos(fasek-fasej)+bki*
			sin(fasek-fasej));
		end;{end for}
		actibarr:=sum;
	end;


procedure calcularFXv(var FXv: TVectComplex; Xv: TVectComplex);

	var
		k:integer;
		difactk,difreack: NComplex;
		B: TList;
		S: TSistema;
		nB,nBC,nBcR:word;

	begin
		B:=BARRASORDENADAS;
		S:= mAdmitancias;
		nB:=NBarras;
		nBC:=NBarrasdeCarga;
		nBcR:=NBarrasconregulador;

		for k:=1 to (nB-1) do
		begin
			difactk.r:= TBarra(B[k-1]).S.r-actibarr(Xv,B,S,k,nB,nBC,nBcR);
			difactk.i:=0;
			FXv.pon_e(k,difactk);
		end;
		for k:=1 to (nBC+nBcR) do
		begin
			difreack.r:=TBarra(B[k-1]).S.i-reacbarr(Xv,B,S,k,nB,nBC,nBcR);
			difreack.i:=0;
			FXv.pon_e((k+nB-1),difreack);
		end;
	end;



procedure calcularfunG(var SJ:TSistema; Xv:TVectComplex);
var
  B:TList;
  S:TSistema;
  Val: boolean;
  nJ,ind:integer;
  Jki,gkiJ,bkiJ,difactk,difreack,modVk,modVi,fasek,fasei:Nreal;
  Jkic,ctek,modVkc,modVic,fasekc,faseic,res: NComplex;
  nB,nBC,nBcR:word;


procedure rango11( kFila, iCol: integer );
var
  k, i: integer;

begin
  i:= iCol;
  k:= kFila;
  Val:= S.Valcoef( res,k,i);
  bkiJ:=res.i;
  gkiJ:=res.r;
  {selecciono extraccion de datos}
  {seleccion segun k}
  if ( k<=nBC+nBcR) then
  begin
    Xv.e(modVkc,k+nB-1);
    {modVk:=X(k+nB-1).r}
    modVk:=modVkc.r;
  end
  else
  begin
    modVk:=mod1(TBarra(B[k-1]).V);
  end;

  if k<>nB then
  begin
    Xv.e(fasekc,k);
    fasek:=fasekc.r;
  end
  else
  begin
    fasek:=fase(TBarra(B[k-1]).V);
  end;
  {selecciono segun i}
  if ( i<=nBC+nBcR) then
  begin
    Xv.e(modVic,i+nB-1);
    {modVi:=X(i+nB-1).r}
    modVi:=modVic.r;
  end
  else
  begin
    modVi:=mod1(TBarra(B[i-1]).V);
  end;
  if i<>nB then
  begin
    Xv.e(faseic,i);
    fasei:=faseic.r;
  end
  else
    fasei:=fase(TBarra(B[i-1]).V);

  if k=i then
    Jki:=-bkiJ*sqr(modVk)- reacbarr(Xv,B,S,k,nB,nBC,nBcR)
  else
    Jki:=modVk*modVi*(gkiJ*sin(fasek-fasei)-bkiJ*cos(fasek-fasei));
end;



procedure rango21( kFila, iCol: integer );
var
  k, i: integer;

begin
  i:= iCol;
  k:= kFila;
  k:=k-(nB-1);
  Val:=S.Valcoef(res,k,i);
  bkiJ:=res.i;
  gkiJ:=res.r;
  {selecciono la extraccion de datos}
  {seleccion segun k}
  Xv.e(modVkc,k+nB-1);
  {modVk:=X(k+nB-1).r}
  modVk:=modVkc.r;
  Xv.e(fasekc,k);
  fasek:=fasekc.r;
  {seleccion segun i}
  if ( i<=nBC+nBcR) then
  begin
    Xv.e(modVic,i+nB-1);
    {modVi:=X(i+nB-1).r}
    modVi:=modVic.r;
  end
  else
  begin
    modVi:=mod1(TBarra(B[i-1]).V);
  end;
  if i<>nB then
  begin
    Xv.e(faseic,i);
    fasei:=faseic.r;
  end
  else
  begin
    fasei:=fase( TBarra(B[i-1]).V);
  end;

  if k=i then Jki:=-gkiJ*sqr(modVk)
  +actibarr(Xv,B,S,k,nB,nBC,nBcR)
  else
    begin
      Jki:=-modVk*
      modVi*(gkiJ*
      cos(fasek-
      fasei)+bkiJ*
      sin(fasek-
      fasei));
    end;{else}
end;

procedure rango12( kFila, iCol: integer );
var
  k, i: integer;

begin
  i:= iCol;
  k:= kFila;
  i:=i-(nB-1);
  Val:=S.Valcoef(res,k,i);
  bkiJ:=res.i;
  gkiJ:=res.r;
  {selecciono la extraccion de datos}
  {seleccion segun k}
  if ( k<=nBC+nBcR) then
  begin
    Xv.e(modVkc,k+nB-1);
    {modVk:=X(k+nB-1).r}
    modVk:=modVkc.r;
  end
  else
  begin
    modVk:=mod1(TBarra(B[k-1]).V);
  end;
  if k<>nB then
  begin
    Xv.e(fasekc,k);
    fasek:=fasekc.r;
  end
  else
  begin
    fasek:=fase(TBarra(B[k-1]).V);
  end;
  {seleccion segun i}
  Xv.e(modVic,i+nB-1);
  {modVi:=X(i+nB-1).r}
  modVi:=modVic.r;
  Xv.e(faseic,i);
  fasei:=faseic.r;

  if k=i then Jki:=gkiJ*sqr(modVk)
  +actibarr(Xv,B,S,k,nB,nBC,nBcR)
  else
   begin
     Jki:=modVK*modVi*(gkiJ*
     cos(fasek-fasei)+bkiJ*
     sin(fasek-fasei));
   end;{else}
end;


procedure rango22( kFila, iCol: integer );
var
  k, i: integer;

begin
  i:= iCol;
  k:= kFila;
  i:=iCol-(nB-1);
  k:=kFila-(nB-1);
  Val:=S.Valcoef(res,k,i);
  bkiJ:=res.i;
  gkiJ:=res.r;
  {selecciono extraccion de datos}
  {selecciono segun k}
  Xv.e(modVkc,k+nB-1);
  {modVk:=X(k+nB-1).r}
  modVk:=modVkc.r;
  Xv.e(fasekc,k);
  fasek:=fasekc.r;
  {selecciono segun i}
  Xv.e(modVic,i+nB-1);
  {modVi:=X(i+nB-1).r}
  modVi:=modVic.r;
  Xv.e(faseic,i);
  fasei:=faseic.r;

  if k=i then
    Jki:=-bkiJ*sqr(modVk)+reacbarr(Xv,B,S,k,nB,nBC,nBcR)
  else
    Jki:=modVk* modVi*(gkiJ* sin(fasek-fasei)-bkiJ* cos(fasek-fasei));
end;

var
  k,i:TIndice;
  k_p: integer;

begin
  B:=BARRASORDENADAS;
  S:= mAdmitancias;
  nB:=NBarras;
  nBC:=NBarrasdeCarga;
  nBcR:=NBarrasconregulador;

  for k:=1 to nB-1+nBC+nBcR do {recorro las ecuaciones una a una}
  begin
    for i:=1 to nB-1+nBC+nBcR do {para cada ecuacion recorro las variables}
    begin
      {segun la posicion en la matriz J asigno el
      valor de la derivada que corresponda
                   i <= nB-1   |   i > nB-1
      ----------------------------------------
      k <= nB-1 |  rango11     |   rango12
      k> nB-1   |  rango21     |   rango22
      }
      if (k<=nB-1) and (i<=nB-1) then rango11( k, i );
      if (k> nB-1) and (i<=nB-1) then rango21( k, i );
      if (k<=nB-1) and (i> nB-1) then rango12( k, i );
      if (k> nB-1) and (i> nB-1) then rango22( k, i );
      Jkic.r:=Jki;
      Jkic.i:=0;
      SJ.Acumular_(k,i,Jkic); {agrego el coeficiente i  en la ecuacion k}
    end; {end del for}

    if k<=nB-1 then
    begin
      difactk:= TBarra(B[k-1]).S.r-actibarr(Xv,B,S,k,nB,nBC,nBcR);
      ctek.r:=-difactk;
      ctek.i:=0;
      SJ.AcumularConstante_(k,ctek);
    end
    else
    begin
      k_p:=k-(nB-1);
      difreack:=TBarra(B[k_p-1]).S.i-reacbarr(Xv,B,S,k_p,nB,nBC,nBcR);
      ctek.r:=-difreack;
      ctek.i:=0;
      SJ.AcumularConstante_(k,ctek);
    end;
  end;
end;

end.
