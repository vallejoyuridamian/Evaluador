unit uiteradoressimsee;

{$mode delphi}

interface

uses
  Classes, SysUtils;
type
    TIteradorDePasoSimSEE = class
    procedure preparar_paso_as; virtual; abstract;

    function NecesitoIterar: boolean; virtual; abstract;

    procedure preparar_paso_ps; virtual; abstract;
  end;

implementation

end.

