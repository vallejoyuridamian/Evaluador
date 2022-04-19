{+doc
+NOMBRE: Autoco.
+CREACION: 8.12.1990.
+AUTORES: Ruben Chaer.
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO: Funcion autocorrelaci¢n discreta.
+PROYECTO: General.

+REVISION:
+AUTOR:
+DESCRIPCION:
-doc}

unit AutoCo;

interface

uses
  xMatDefs, SysUtils,
  WRFFTF01, WRFFTB01, WRFFTI01;

procedure AutoCorrelacion(n: longint; var dat);
procedure h2f(n: longint; var dat);


implementation

const
  ErrMsg: string = 'AUTOCO: No hay suficiente Memoria';

procedure AutoCorrelacion(n: longint; var dat);
type
  VR = array[1..1024 * 1024] of NReal;
var
  pd, pa, pb: ^VR;
  a0: NReal;
  k: longint;
begin

  try
    GetMem(pd, n * 2 * sizeOf(NReal));
    GetMem(pa, n * sizeOf(NReal));
    GetMem(pb, n * SizeOf(NReal));
  except
    raise Exception.Create(ErrMsg);
  end;


  { C lculo del t‚rmino de DC }
  a0 := 0;
  for k := 1 to n do
  begin
    a0 := a0 + VR(dat)[k];
  end;
  a0 := a0 / n;

  { Quitamos el t‚rmino de DC a los datos y duplicamos el
  vector de datos (en longitud), llenando con 0 los nuevos valores. }
  for k := 1 to n do
  begin
    pd^[k] := VR(dat)[k] - a0;
    pd^[k + n] := 0;
  end;

  { Inicilalizamos el m¢dulo de FFTs para trabajar con
  vectores de largo  2n }
  wRFFTI01.Init(2 * n);

  { C lculamos los coeficientes de la serie discreta de Fourier
  correspondiente al vector pd con 2n datos.
    a0 : coeficiente de continua. (debe ser 0 pues se lo restamos antes)
    pa[k] :coeficiente del coseno del arm¢nico k, k:1..n
    pb[k] :coeficiente del seno del arm¢nico k, k:1..n  }
  FFTF(pd^, a0, pa^, pb^);

  { Ahora, acomodamos a0, pa y pb de manera que representen los
  coeficientes de la transformada de la autocorrenlaci¢n de los
  datos. En otras palabras, calculamos el espectro de potencia. }
  a0 := a0 * a0;
  for k := 1 to n do
  begin
    pa^[k] := (sqr(pa^[k]) + sqr(pb^[k])) / 2;
    pb^[k] := 0;
  end;
  pa^[n] := 2 * pa^[n]; {???, fundamentar esto}

  FFTB(pd^, a0, pa^, pb^);
  wRFFTI01.done;
  for k := 1 to n do
    VR(dat)[k] := 2 * pd^[k];
  FreeMem(pb, n * SizeOf(NReal));
  FreeMem(pa, n * SizeOf(NReal));
  FreeMem(pd, n * 2 * sizeOf(NReal));
end;



procedure h2f(n: longint; var dat);
type
  VR = array[1..1024 * 1024] of NReal;
var
  pd, pa, pb: ^VR;
  a0: NReal;
  k: longint;
begin

  try
    GetMem(pd, 2 * n * sizeOf(NReal));
    GetMem(pa, n * sizeOf(NReal));
    GetMem(pb, n * SizeOf(NReal));
  except
    raise Exception.Create(ErrMsg);
  end;

  { Quitamos el t‚rmino de DC a los datos y duplicamos el
  vector de datos (en longitud), llenando con 0 los nuevos valores. }
  for k := 1 to n do
  begin
    pd^[k] := VR(dat)[k];
    pd^[k + n] := 0;
  end;

  { Inicilalizamos el m¢dulo de FFTs para trabajar con
  vectores de largo  2n }
  wRFFTI01.Init(2 * n);

  for k := 1 to N do
    pd^[k] := VR(dat)[k];

  { C lculamos los coeficientes de la serie discreta de Fourier
  correspondiente al vector pd con 2n datos.
    a0 : coeficiente de continua. (debe ser 0 pues se lo restamos antes)
    pa[k] :coeficiente del coseno del arm¢nico k, k:1..n
    pb[k] :coeficiente del seno del arm¢nico k, k:1..n  }
  FFTF(pd^, a0, pa^, pb^);

  { Ahora, acomodamos a0, pa y pb de manera que representen los
  coeficientes de la transformada de la autocorrenlaci¢n de los
  datos. En otras palabras, calculamos el espectro de potencia. }
  VR(dat)[1] := a0 * a0;
  for k := 1 to n - 1 do
    VR(dat)[1 + k] := (sqr(pa^[k]) + sqr(pb^[k])) / 2;

  wRFFTI01.done;
  FreeMem(pb, n * SizeOf(NReal));
  FreeMem(pa, n * SizeOf(NReal));
  FreeMem(pd, 2* n * sizeOf(NReal));
end;

end.
