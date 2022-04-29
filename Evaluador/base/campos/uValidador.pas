unit uValidador;

interface

uses
  SysUtils, uFechas, Math;

type
  TValidador = class
  public
    function esValido(const valor: String): Boolean; virtual; abstract;
    function msgValoresValidos: String; virtual; abstract;
  end;

  TValidadorInteger = class(TValidador)
  public
    minValido, maxValido: Integer;

    Constructor Create(minValido, maxValido: Integer);

    function esValido(const valor: String): Boolean; override;
    function msgValoresValidos: String; override;
  end;

  TValidadorDouble = class(TValidador)
  public
    minValido, maxValido: Double;

    Constructor Create(minValido, maxValido: Double);

    function esValido(const valor: String): Boolean; override;
    function msgValoresValidos: String; override;
  end;

  TValidadorBoolean = class(TValidador)
  public
    function esValido(const valor: String): Boolean; override;
    function msgValoresValidos: String; override;
  end;

  TValidadorString = class(TValidador)
  public
    function esValido(const valor: String): Boolean; override;
    function msgValoresValidos: String; override;
  end;

  TValidadorFecha = class(TValidador)
  public
    function esValido(const valor: String): Boolean; override;
    function msgValoresValidos: String; override;
  end;

implementation

{ TValidadorInteger }

constructor TValidadorInteger.Create(minValido, maxValido: Integer);
begin
  inherited Create;
  self.minValido := minValido;
  self.maxValido := maxValido;
end;

function TValidadorInteger.esValido(const valor: String): Boolean;
var
  v: Integer;
begin
  if TryStrToInt(valor, v) and (v >= minValido) and (v <= maxValido) then
    result := True
  else
    result := False;
end;

function TValidadorInteger.msgValoresValidos: String;
begin
  if minValido <> -MaxInt then
  begin
    if maxValido <> MaxInt then
      result := 'debe ser un entero entre ' + IntToStr(minValido) + ' y ' + IntToStr(maxValido)
    else
      result := 'debe ser un entero mayor o igual a ' + IntToStr(minValido)
  end
  else
  begin
    if maxValido <> MaxInt then
      result := 'debe ser un entero menor o igual a ' + IntToStr(maxValido)
    else
      result := 'debe ser un entero';
  end;
end;

{ TValidadorDouble }

constructor TValidadorDouble.Create(minValido, maxValido: Double);
begin
  inherited Create;
  self.minValido := minValido;
  self.maxValido := maxValido;
end;

function TValidadorDouble.esValido(const valor: String): Boolean;
var
  v: Double;
begin
  if TryStrToFloat(valor, v) and (v >= minValido) and (v <= maxValido) then
    result := True
  else
    result := False;
end;

function TValidadorDouble.msgValoresValidos: String;
begin
  if not SameValue(minValido, -MaxDouble) then
  begin
    if not SameValue(maxValido, MaxDouble) then
      result := 'debe ser un real entre ' + FloatToStr(minValido) + ' y ' + FloatToStr
        (maxValido)
    else
      result := 'debe ser un real mayor o igual a ' + FloatToStr(minValido)
  end
  else
  begin
    if not SameValue(maxValido, MaxDouble) then
      result := 'debe ser un real menor o igual a ' + FloatToStr(maxValido)
    else
      result := 'debe ser un real';
  end;
end;

{ TValidadorBoolean }

function TValidadorBoolean.esValido(const valor: String): Boolean;
var
  b: Boolean;
begin
  result := TryStrToBool(valor, b);
end;

function TValidadorBoolean.msgValoresValidos: String;
begin
  result := 'debe ser "true" o "false"';
end;

{ TValidadorString }

function TValidadorString.esValido(const valor: String): Boolean;
begin
  result := True;
end;

function TValidadorString.msgValoresValidos: String;
begin
  result := 'debe ser un string';
end;

{ TValidadorFecha }

function TValidadorFecha.esValido(const valor: String): Boolean;
begin
  try
    if pos('/', valor) <> 0 then
      StrToDateTime(valor)
    else
      IsoStrToDateTime(valor);
    result := True;
  Except
    result := False;
  end;
end;

function TValidadorFecha.msgValoresValidos: String;
begin
  result := 'debe ser una fecha válida';
end;

end.
