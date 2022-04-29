unit ufunciones_simsee;

interface

uses
  uCosa, uCosaConNombre, uFuentesAleatorias, xMatDefs;

type
  TClaseDeFuncion = class of TFuncion;

  { TFuncion }

  TFuncion = class(TCosaConNombre)
  public
    (**************************************************************************)
    (*               A T R I B U T O S   P E R S I S T E N T E S              *)
    (**************************************************************************)

    valor: NReal;

    (**************************************************************************)

    calculada: boolean;

    //Indica si la función puede ser usada por cualquier actor o si es
    //solo del actor que la referencia
    publica: boolean;

    procedure calcular; virtual; abstract;
    procedure calcularAstuto;

    class function CreateDataColumnList(xClaseDeCosa: TClaseDeCosa; xVersion: Integer=-2): TDataColumnListOfCosa; override;

  published
    



  end;

  { TFuncion_Constante }

  TFuncion_Constante = class (TFuncion)
    public
      Constructor Create(nombre: String; valor: NReal);
      constructor Create_ReadFromText( f: TArchiTexto ); override;
      procedure WriteToText(f: TArchiTexto ); override;

      procedure calcular; override;

      class function CreateDataColumnList(xClaseDeCosa: TClaseDeCosa; xVersion: Integer=-2
        ): TDataColumnListOfCosa; override;

  end;

  { TFuncion_Fuente }

  TFuncion_Fuente = class (TFuncion)
  public
    (**************************************************************************)
    (*               A T R I B U T O S   P E R S I S T E N T E S              *)
    (**************************************************************************)

    fuente: TFuenteAleatoria;

    (**************************************************************************)

    Constructor Create(nombre: String; fuente: TFuenteAleatoria);
    constructor Create_ReadFromText( f: TArchiTexto ); override;
    procedure WriteToText(f: TArchiTexto ); override;

    procedure calcular; override;

    class function CreateDataColumnList(xClaseDeCosa: TClaseDeCosa; xVersion: Integer=-2): TDataColumnListOfCosa; override;

  published
    (**************************************************************************)
    (*               A T R I B U T O S   P E R S I S T E N T E S              *)
    (**************************************************************************)

    property _fuente: TFuenteAleatoria read fuente write fuente;

    (**************************************************************************)

  end;

  { TFuncion_Suma }

  TFuncion_Suma = class (TFuncion)
  public
     
    entradas: TListaDeReferenciasACosas;
    

      Constructor Create(nombre: String; entradas: TListaDeReferenciasACosas);
      constructor Create_ReadFromText( f: TArchiTexto ); override;
      procedure WriteToText(f: TArchiTexto ); override;

      procedure calcular; override;
      procedure Free; override;

      class function CreateDataColumnList(xClaseDeCosa: TClaseDeCosa; xVersion: Integer=-2
        ): TDataColumnListOfCosa; override;

  published
    


  end;

  { TFuncion_PorReal }

  TFuncion_PorReal = class (TFuncion)
  public
    (**************************************************************************)
    (*               A T R I B U T O S   P E R S I S T E N T E S              *)
    (**************************************************************************)

    a:       NReal;
    entrada: TFuncion;

    (**************************************************************************)

    Constructor Create(nombre: String; a: NReal; entrada: TFuncion);
    constructor Create_ReadFromText( f: TArchiTexto ); override;
    procedure WriteToText(f: TArchiTexto ); override;

    procedure calcular; override;

    class function CreateDataColumnList(xClaseDeCosa: TClaseDeCosa; xVersion: Integer=-2): TDataColumnListOfCosa; override;

  published
    



  end;

procedure AlInicio;
procedure AlFinal;  

implementation

//--------------------
// Métodos de TFuncion
//====================

procedure TFuncion.calcularAstuto;
begin
  calcular;
  calculada:= true;
end;

class function TFuncion.CreateDataColumnList(xClaseDeCosa: TClaseDeCosa;
  xVersion: Integer): TDataColumnListOfCosa;
begin
  



end;

//------------------------------
// Métodos de TFuncion_Constante
//==============================

constructor TFuncion_Constante.Create(nombre: String; valor: NReal);
begin
  inherited Create(nombre);
  self.valor:= valor;
  calculada:= true;
end;

constructor TFuncion_Constante.Create_ReadFromText( f: TArchiTexto );
begin
  inherited Create_ReadFromText(f);
  f.IniciarLecturaRetrasada;
  f.rd('valor', valor);
  f.EjecutarLectura;
end;

procedure TFuncion_Constante.WriteToText(f: TArchiTexto );
begin
  inherited WriteToText(f);
  f.wr('valor', valor);
end;

procedure TFuncion_Constante.calcular;
begin
end;

class function TFuncion_Constante.CreateDataColumnList(
  xClaseDeCosa: TClaseDeCosa; xVersion: Integer): TDataColumnListOfCosa;
begin
  Result:=inherited CreateDataColumnList(xClaseDeCosa, xVersion);
end;

//---------------------------
// Métodos de TFuncion_Fuente
//===========================

constructor TFuncion_Fuente.Create(nombre: String; fuente: TFuenteAleatoria);
begin
  inherited Create(nombre);
  self.fuente:= fuente;
end;

constructor TFuncion_Fuente.Create_ReadFromText( f: TArchiTexto );
begin
  inherited Create_ReadFromText(f);
  f.IniciarLecturaRetrasada;
  f.rdReferencia('fuente', TCosa(fuente), self);
  f.EjecutarLectura;
end;

procedure TFuncion_Fuente.WriteToText(f: TArchiTexto );
begin
  inherited WriteToText(f);
  f.wrReferencia('fuente', fuente);
end;

procedure TFuncion_Fuente.calcular;
begin
  valor:= fuente.Bornera[0];
end;

class function TFuncion_Fuente.CreateDataColumnList(xClaseDeCosa: TClaseDeCosa;
  xVersion: Integer): TDataColumnListOfCosa;
begin
  



end;

//-------------------------
// Métodos de TFuncion_Suma
//=========================

constructor TFuncion_Suma.Create(nombre: String;
  entradas: TListaDeReferenciasACosas);
begin
  inherited Create(nombre);
  self.entradas:= entradas;
end;

constructor TFuncion_Suma.Create_ReadFromText(f: TArchiTexto);
begin
  inherited Create_ReadFromText(f);
  f.IniciarLecturaRetrasada;
  f.rd('entradas', TCosa(entradas));
  f.EjecutarLectura;
end;

procedure TFuncion_Suma.WriteToText(f: TArchiTexto );
begin
  inherited WriteToText(f);
  f.wr('entradas', entradas);
end;

procedure TFuncion_Suma.calcular;
var
  i: Integer;
begin
  valor:= 0;
  for i := 0 to high(entradas.lst) do
  begin
    TFuncion(entradas.lst[i]).calcular;
    valor:= valor + TFuncion(entradas.lst[i]).valor;
  end;
end;

procedure TFuncion_Suma.Free;
begin
  entradas.Free;
  inherited Free;
end;

class function TFuncion_Suma.CreateDataColumnList(xClaseDeCosa: TClaseDeCosa;
  xVersion: Integer): TDataColumnListOfCosa;
begin
  



end;

//----------------------------
// Métodos de TFuncion_PorReal
//============================

constructor TFuncion_PorReal.Create(nombre: String; a: NReal; entrada: TFuncion
  );
begin
  inherited Create(nombre);
  self.a:= a;
  self.entrada:= entrada;
end;

constructor TFuncion_PorReal.Create_ReadFromText( f: TArchiTexto );
begin
  inherited Create_ReadFromText(f);
  f.IniciarLecturaRetrasada;
  f.rd('a', a);
  f.rdReferencia('entrada', TCosa(entrada), self);
  f.EjecutarLectura;
end;

procedure TFuncion_PorReal.WriteToText(f: TArchiTexto );
begin
  inherited WriteToText(f);
  f.wr('a', a);
  f.wrReferencia('entrada', entrada);
end;

procedure TFuncion_PorReal.calcular;
begin
  entrada.calcular;
  valor:= entrada.valor * a;
end;

class function TFuncion_PorReal.CreateDataColumnList(
  xClaseDeCosa: TClaseDeCosa; xVersion: Integer): TDataColumnListOfCosa;
begin
  




end;

procedure AlInicio;
begin
  uCosa.registrarClaseDeCosa(TFuncion_Constante.ClassName, TFuncion_Constante);
  uCosa.registrarClaseDeCosa(TFuncion_Fuente.ClassName, TFuncion_Fuente);
  uCosa.registrarClaseDeCosa(TFuncion_PorReal.ClassName, TFuncion_PorReal);  
  uCosa.registrarClaseDeCosa(TFuncion_Suma.ClassName, TFuncion_Suma);
end;

procedure AlFinal;
begin
end;

end.
