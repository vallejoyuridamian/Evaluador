unit uDatosFuenteHistorica;

interface

uses
  uFechas, Classes, xMatDefs, SysUtils, uAuxiliares;

type
  TDatosFuenteHistorica = class
    public
      fechaIni, fechaFin: TFecha;
      nSeries, nPuntosSeries: Integer;
      NombresDeBornes_Publicados: TStringList;
      series: TMatOfNReal;
      tiempoEntrePuntos, invTiempoEntrePuntos: TDateTime;

      constructor Create(fechaIni, fechaFin: TFecha;
                         NombresDeBornes_Publicados: TStringlist;
                         series: TMatOfNReal);

      // carga los datos de un archivo previamente guardado con WriteToArchi
      constructor CreateFromArchi(nombreArchivo: String);

      // escribe los datos en un archivo de texto.
      procedure WriteToArchi( nombreArchivo: string );
      procedure Free;
  end;

implementation

constructor TDatosFuenteHistorica.Create(fechaIni, fechaFin: TFecha;
                                              NombresDeBornes_Publicados: TStringlist;
                                              series: TMatOfNReal);
begin
  inherited Create;
  self.fechaIni:= fechaIni;
  self.fechaFin:= fechaFin;
  self.NombresDeBornes_Publicados:= NombresDeBornes_Publicados;
  self.series:= series;
  self.nSeries:= Length(series);
  self.nPuntosSeries:= Length(series[0]);
  Self.tiempoEntrePuntos:= (fechaFin.AsDt - fechaIni.AsDt) / nPuntosSeries;
  invTiempoEntrePuntos:= 1 / tiempoEntrePuntos;
end;

constructor TDatosFuenteHistorica.CreateFromArchi(nombreArchivo: String);
var
  f: TextFile;
  i, j: Integer;
  linea: String;
begin
  if FileExists(nombreArchivo) then
  begin
    AssignFile(f, nombreArchivo);
    try
      Reset(f);

      //fechaIni
      Readln(f, linea);
      NextPal(linea);
      fechaIni:= TFecha.Create_ISOStr(NextPal(linea));

      //fechaFin
      Readln(f, linea);
      NextPal(linea);
      fechaFin:= TFecha.Create_ISOStr(NextPal(linea));

      //nSeries
      readln(f, linea);
      NextPal(linea);
      nSeries:= NextInt(linea);

      //nPuntosSeries
      readln(f, linea);
      NextPal(linea);
      nPuntosSeries:= NextInt(linea);

      Self.tiempoEntrePuntos:= (fechaFin.AsDt - fechaIni.AsDt) / nPuntosSeries;
      invTiempoEntrePuntos:= 1 / tiempoEntrePuntos;
      SetLength(series, nSeries);
      for i:= 0 to nSeries - 1 do
        SetLength(series[i], nPuntosSeries);

      system.readln(f);

      self.NombresDeBornes_Publicados:= TStringList.Create;
      readln(f, linea);
      for i:= 0 to nSeries - 1 do
        NombresDeBornes_Publicados.Add(NextPal(linea));

      for j:= 0 to nPuntosSeries - 1 do
      begin
        readln(f, linea);
        for i:= 0 to nSeries - 1 do
          series[i][j]:= NextFloat(linea);
      end;
    finally
      CloseFile(f);
    end;
  end
  else
    Raise Exception.Create('TDatosFuenteHistorica.CreateFromArchi: no se encuentra el archivo ' + nombreArchivo);
end;

procedure TDatosFuenteHistorica.WriteToArchi( nombreArchivo: string );
var
  f: TextFile;
  i, j: Integer;
  linea: String;
begin
  AssignFile(f, nombreArchivo);
  try
    Rewrite(f);

    writeln(f, 'FechaIni'#9, fechaIni.AsISOStr);
    writeln(f, 'fechaFin'#9, fechaFin.AsISOStr);
    writeln(f, 'NSeries'#9, nSeries);
    writeln(f, 'NPuntosSeries'#9, nPuntosSeries);
    writeln(f);

    linea:= NombresDeBornes_Publicados[0];
    for i:= 1 to NombresDeBornes_Publicados.Count - 1 do
      linea:= linea + #9 + NombresDeBornes_Publicados[i];
    Writeln(f, linea);

    for j:= 0 to nPuntosSeries - 1 do
    begin
      linea:= FloatToStr(series[0][j]);
      for i:= 1 to nSeries - 1 do
        linea:= linea + #9 + FloatToStr(series[i][j]);
      writeln(linea);
    end;
  finally
    CloseFile(f);
  end;
end;

procedure TDatosFuenteHistorica.Free;
var
  i: Integer;
begin
  fechaIni.Free;
  fechaFin.Free;
  NombresDeBornes_Publicados.Free;
  for i:= 0 to high(series) do
    SetLength(series[i], 0);
  SetLength(series, 0);
  inherited Free;
end;

end.
