unit uacumuladores_sim;
{
 Esta unidad define los acumularores a tener por crónica para imprimir
 el archivo resumen al final de una simulación.

 Una instancia de esta clase puede ser compartida durante la simulación
 entre los diferentes threads pues cada uno completa crónicas diferentes

 Solo el Thread Master debe crear la instancia e imprimir el archivo al
 final de la simulación.
}

{$mode delphi}

interface

uses
  Classes, SysUtils, uglobs, uauxiliares, xmatdefs;

type

  { TAcumuladores_Sim }

  TAcumuladores_Sim = class
    globs: TGlobs;
    ncronicas: integer;
    costosAcum, costosAcum_aux: TDAOfNReal;
    cdpAcum, udpAcum, CF_final, CFaux_final: TDAOfNReal;
    constructor Create( globs: TGlobs; ncronicas: integer );

    // Imprime el resumen de costos de la simulación y retorna el valor
    // esperado del costo futuro de operación.
    function PrinArchi(archi: string): NReal;

    procedure GetResumen( var CF_ve, CF_VaR05, CF_CVaR05: NReal );

    procedure Free;


    // Retorna el valor esperadod el Costo Futuro en MUSD
    function VE_CF_MUSD: NReal;

    // Retorna el Value At Risk del Costo Futuro en MUSD
    function VaR_CF_MUSD( prob: NReal ): NReal;

    // Retorna el Conditional Value At Risk del Costo Futuro en MUSD
    function CVaR_CF_MUSD( prob: NReal ): NReal;
  end;


implementation

constructor TAcumuladores_Sim.Create( globs: TGlobs; ncronicas: integer );
begin
  inherited Create;
  self.globs:= globs;
  self.ncronicas:= ncronicas;
  setlength( costosAcum, ncronicas );
  setlength( costosAcum_aux, ncronicas );
  setlength( cdpAcum, ncronicas );
  setlength( udpAcum, ncronicas );
  setlength( CF_Final, ncronicas );
  setlength( CFaux_final, ncronicas );
end;


// Retorna el valor esperadod el Costo Futuro en MUSD
function TAcumuladores_Sim.VE_CF_MUSD: NReal;
var
  res: NReal;
begin
  res:= vprom( self.costosAcum ) / 1.0E6;
  result:= res;
end;


 // Retorna el Value At Risk del Costo Futuro en MUSD
function TAcumuladores_Sim.VaR_CF_MUSD( prob: NReal ): NReal;
var
  res: NReal;
begin
   QuickSort_Creciente(CostosAcum);
   res := Interpolar(CostosAcum, 0, 1, 1.0 - prob ) / 1.0E6;
   result:= res;
end;

 // Retorna el Conditional Value At Risk del Costo Futuro en MUSD
function TAcumuladores_Sim.CVaR_CF_MUSD( prob: NReal ): NReal;
var
  res: NReal;
  i, itop, n: integer;
begin
   QuickSort_Creciente(CostosAcum);
   itop:= trunc(high( CostosAcum  ) * ( 1- prob ) + 0.499);
   res:= 0;
   n:= high( CostosAcum ) - itop + 1;
   for i:= itop to high( CostosAcum ) do
     res:= res + CostosAcum[ i ];
   res:= res / 1.0E6 / n;
   result:= res;
end;


function TAcumuladores_Sim.PrinArchi( archi: string ): NReal;
var
  fsal: textfile;
  jCronica: integer;

  CostoAcum,
    CostoAcumVaR05, CostoAcumCVaR05, CostoAcum_aux: NReal;
begin
    assignfile(fsal, archi );
    rewrite(fsal);
    if ncronicas > 0 then
    begin
      system.writeln(fsal, globs.TasaDeActualizacion, #9, '[p.u.]',
        #9, 'Tasa de descuento anual.');

      CostoAcum:= VE_CF_MUSD;
      system.writeln(fsal, CostoAcum, #9, '[MUSD]', #9,
        'Costo esperado');

      CostoAcumVaR05 := VaR_CF_MUSD( 0.05);
      system.writeln(fsal, CostoAcumVaR05, #9, '[MUSD]', #9,
        'Costo con riesgo 5% de ser excedido.');

      CostoAcumCVaR05 := CVaR_CF_MUSD( 0.05);
      system.writeln(fsal, CostoAcumCVaR05, #9, '[MUSD]', #9,
        'Costo CVaR(5%).');

      CostoAcum_aux:= vprom( CostosAcum_aux );
      system.writeln(fsal, CostoAcum_aux / 1.0E6, #9, '[MUSD]', #9,
        'Costo auxiliar esperado (cdp+CFaux)');

      QuickSort_Creciente(CostosAcum_aux);
      CostoAcumVaR05 := Interpolar(CostosAcum_aux, 0, 1, 0.95);
      system.writeln(fsal, CostoAcumVaR05 / 1E6, #9, '[MUSD]', #9,
        'Costo auxiliar con riesgo 5% de ser excedido. (cdp+CFaux)');

      system.Write(fsal,
        'valor presente del costo (cdp+CF) por cróncia [MUSD] (Ordenado): ');
      for jCronica := 0 to high(costosAcum) do
        system.Write(fsal, #9, costosAcum[jCronica] / 1E6);
      system.writeln(fsal);

      system.Write(fsal,
        'valor presente del costo auxiliar (cdp+CFAux) por cróncia [MUSD] (Ordenado): ');
      for jCronica := 0 to high(costosAcum) do
        system.Write(fsal, #9, costosAcum_aux[jCronica] / 1E6);
      system.writeln(fsal);

      system.Write(fsal, 'valor presente del costo  directos por cróncia [MUSD]: ');
      for jCronica := 0 to high(costosAcum) do
        system.Write(fsal, #9, cdpAcum[jCronica] / 1E6);
      system.writeln(fsal);

      system.Write(fsal, 'valor presente del costo futuro al final de cada crónica [MUSD]: ');
      for jCronica := 0 to high(costosAcum) do
        system.Write(fsal, #9, CF_final[jCronica] / 1E6);
      system.writeln(fsal);

      system.Write(fsal,
        'valor presente del costo  futuro AUXiliar al final de cada crónica [MUSD]: ');
      for jCronica := 0 to high(costosAcum) do
        system.Write(fsal, #9, CFaux_final[jCronica] / 1E6);
      system.writeln(fsal);


      system.Write(fsal,
        'valor presente de la utilidad directa acumulada de cada crónica [MUSD]: ');
      for jCronica := 0 to high(costosAcum) do
        system.Write(fsal, #9, udpAcum[jCronica] / 1E6);
      system.writeln(fsal);

    end
    else
      system.writeln( fsal, '--- ERRRO --- NCronicas: ', nCronicas );
    Close(fsal);
    result:= CostoAcum;
end;

procedure TAcumuladores_Sim.GetResumen(var CF_ve, CF_VaR05, CF_CVaR05: NReal);
begin
      CF_ve:= VE_CF_MUSD;
      CF_VaR05:= VaR_CF_MUSD( 0.05);
      CF_CVaR05 := CVaR_CF_MUSD( 0.05);
end;

procedure TAcumuladores_Sim.Free;
begin
  ncronicas:= 0;
  setlength( costosAcum, ncronicas );
  setlength( costosAcum_aux, ncronicas );
  setlength( cdpAcum, ncronicas );
  setlength( udpAcum, ncronicas );
  setlength( CF_Final, ncronicas );
  setlength( CFaux_final, ncronicas );
  inherited Free;
end;

end.

