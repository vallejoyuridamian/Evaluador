program pruebasseriesv3;

{$mode objfpc}{$H+}

{x$DEFINE V2}


uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes,
  matreal,
  {$IFDEF V2}
  useriestemporales,
  {$ELSE}
  useriestemporales,
  {$ENDIF}
  upruebaseriesv3
  { you can add units after this };

var
 series,series_aux:TSeriesDeDatos;
 vector:TVectR;
 cronicas,cronicas2:TDAOfVectR;
 nmuestras:integer;
begin

  // Pruebas de creacion con formato nuevo
  (*nmuestras:=100;
  series:=TSeriesDeDatos.CreateVacia(0,1,nmuestras,2);
  vector:=TVectR.Create_Init(nmuestras);
  vector.FillVal(1);

  SetLength(cronicas,2);
  cronicas[0]:=vector;
  cronicas[1]:=TVectR.Create_Init(nmuestras);
  cronicas[1].FillVal(2);

  vector.FillVal(3);
  SetLength(cronicas2,2);
  cronicas2[0]:=vector;
  cronicas2[1]:=TVectR.Create_Init(nmuestras);
  cronicas2[1].FillVal(4);

  series.AddSerie('serie1',cronicas);
  series.AddSerie('serie2',cronicas2);*)

  // Pruebas de creacion con formato viejo (V2)
  (*nmuestras:=100;
  series:=TSeriesDeDatos.CreateVacia(0,1,nmuestras,1);
  vector:=TVectR.Create_Init(nmuestras);
  vector.FillVal(1);
  series.AddSerie('serie1',vector);*)

  // Pruebas de creacion desde un archivo V3
  //series:=TSeriesDeDatos.CreateFromArchi('C:/Users/dvallejo/Desktop/series(v3).xlt');
  // Pruebas de creacion desde un archivo V2
   //series:=TSeriesDeDatos.CreateFromArchi('C:/Users/dvallejo/Desktop/series(v2).xlt');

    // Pruebas de creacion desde una serie
   series_aux:=TSeriesDeDatos.CreateFromArchi('C:/Users/dvallejo/Desktop/series(v3)bk.xlt');
   series:=series_aux.clone;

   // Pruebas de creacion desde una serie solo entradas
   (*series_aux:=TSeriesDeDatos.CreateFromArchi('C:/Users/dvallejo/Desktop/series(v3)bk.xlt');
   series:=series_aux.Clone_Entradas; *)


  {$IFDEF V2}
  series.WriteToArchi('C:/Users/dvallejo/Desktop/series(v2).xlt');
  {$ELSE}
  series.WriteToArchi('C:/Users/dvallejo/Desktop/series(v3).xlt');
  {$ENDIF}

end.
