unit uFuenteHistorica;

interface

uses
  uCosa, uGlobs, uFuentesAleatorias, xMatDefs, uDatosFuenteHistorica, SysUtils,
  Classes, uFechas;

type

        { TFuenteHistorica }

 TFuenteHistorica = class(TFuenteAleatoria)
    private
      //puntero de lectura de los datos para la fecha actual
      indice: Integer;

      procedure InitFromFile;
      //Iguala el día del año de la fecha del dato al que apunta el índice con
      //el día del año de la fecha de inicio del paso
      procedure fechaToIndice(fecha: TFecha);
    protected
      procedure SortearEntradaRB( var aRB: NReal ); override;
      procedure ValorEsperadoEntradaRB( var aRB: Nreal ); override;
    public
      archivoDatos: String;

      datos: TDatosFuenteHistorica;


      Constructor Create(nombre, archivoDatos : String);
       
      Constructor Create_ReadFromText(f : TArchiTexto); override;
      procedure WriteToText(f : TArchiTexto); override;
      
      procedure Free; override;
      class function DescClase : String; override;

      procedure Sim_Cronica_Inicio; override;         (*

			procedure sim_PrintResultados_Encab(var fsal: textfile; kencab: integer ); override;
			procedure sim_PrintResultados(var fsal: textfile); override;

      // carga el deltacosto para el término indep del simplex
			function calc_DeltaCosto: NReal; override;

      // las fuentes con estado tienen que calcular el delta costo
      // por el delta_X resultante del sorteo
			procedure PrepararPaso_ps; override;

      function dim_RB: integer; override;
      function dim_X: integer; override;

      procedure PrepararMemoria(globs : TGlobs ); override;*)

      class function CreateDataColumnList(xClaseDeCosa: TClaseDeCosa; xVersion: Integer=-2): TDataColumnListOfCosa; override;

      procedure AfterInstantiation; override;

    published
      



  end;

implementation

constructor TFuenteHistorica.Create(nombre, archivoDatos: String);
begin
  inherited Create(nombre, 0);
  self.archivoDatos:= archivoDatos;
  InitFromFile;
end;

 
constructor TFuenteHistorica.Create_ReadFromText(f: TArchiTexto);
begin
  inherited Create_ReadFromText(f);
  f.IniciarLecturaRetrasada;
  f.rd('archivoDatos', archivoDatos);
  f.EjecutarLectura;
  InitFromFile;
end;


 
procedure TFuenteHistorica.WriteToText(f : TArchiTexto);
begin
  inherited WriteToText(f);
  f.wr('archivoDatos', archivoDatos);
end;


procedure TFuenteHistorica.Free;
begin
  datos.Free;
  inherited Free;
end;

class function TFuenteHistorica.DescClase : String;
begin
  result:= 'Fuente Historica';
end;

procedure TFuenteHistorica.Sim_Cronica_Inicio;
begin

end;

class function TFuenteHistorica.CreateDataColumnList(xClaseDeCosa: TClaseDeCosa; xVersion: Integer): TDataColumnListOfCosa;
begin
  



end;

procedure TFuenteHistorica.AfterInstantiation;
begin
  inherited AfterInstantiation;
  InitFromFile;
end;

procedure TFuenteHistorica.SortearEntradaRB( var aRB: NReal );
var
  i: integer;
begin
  for i:= 1 to datos.nSeries do
  begin
    TVLArrOfNReal( pointer(@aRB)^)[i]:= datos.series[i][indice];
  end;
end;

procedure TFuenteHistorica.ValorEsperadoEntradaRB( var aRB: Nreal );
var
  i: Integer;
begin
  for i:= 1 to datos.nSeries do
  begin
    TVLArrOfNReal( pointer(@aRB)^)[i]:= datos.series[i][indice];
  end;
end;

procedure TFuenteHistorica.InitFromFile;
var
  i: Integer;
begin
  try
    datos:= TDatosFuenteHistorica.CreateFromArchi(archivoDatos);
    self.durPasoDeSorteoEnHoras:= Trunc(datos.tiempoEntrePuntos);
    if NombresDeBornes_Publicados <> NIL then
      NombresDeBornes_Publicados.Clear
    else
      NombresDeBornes_Publicados:= TStringList.Create;

    for i:= 0 to datos.NombresDeBornes_Publicados.Count - 1 do
      self.NombresDeBornes_Publicados.Add(datos.NombresDeBornes_Publicados[i]);
  except
    on e: Exception do
      raise Exception.Create('TFuenteHistorica.InitFromFile: ' + e.Message +
                             ' leyendo la fuente ' + nombre);
  end;
end;

procedure TFuenteHistorica.fechaToIndice(fecha: TFecha);
begin
  indice:= trunc((fecha.dt - datos.fechaIni.dt) / datos.tiempoEntrePuntos);
end;

end.
