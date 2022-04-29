unit uPSO;

{$mode delphi}

interface

uses
  Classes, SysUtils, xMatDefs, MatReal;

type
  TFunc_iRNenR= function ( i: integer; x: TVectR ): NReal;
  TFunc_ikRNenR= function ( i,k: integer; x: TVectR ): NReal;

  TPSO =class
    mEcuaciones, nVariables: integer;
    fi: array of TFunc_iRNenR;
    xfijadas: array of boolean;
    xvalores,
    xiniciales, xmaximos, xminimos: TVectR;
    cajaActiva: array of boolean; // indica para cada variable si las
                                  // restricciones de caja estan activas
    ivx: array of integer; // indices de las variables libres
    errMsg: string;

    constructor Create( mEcuaciones, nVariables: integer );
    procedure Free; virtual;
    procedure Reset;
    procedure DefinirVariable(j: integer; xmin, xmax, xinicial: NReal; EsFija: boolean ); overload;
    procedure DefinirVariable(j: integer; xinicial: NReal;EsFija: boolean ); overload;
    procedure InscribirEcuacion( fi: TFunc_iRNenR; i: integer );
    procedure IniciarResolucion; virtual;
    function BuscarSolucion_PSO( maxErr: NReal; NMaxIter: integer;
      var err: NReal; var cnt_iters: integer ): boolean;
    // copia los valores de las variables libres desde el vector xr hacia el
    // vector xvalores, dejando fijos los parámetros elegidos como fijos.
    procedure copy_xrToxvalores( xr: TVectR ); virtual;


  end;

implementation


function fnula_i(i: integer; x: TVectR ): NReal;
begin
  result:= 0;
end;
function fnula_ik(i, k: integer; x: TVectR ): NReal;
begin
  result:= 0;
end;


procedure TPSO.InscribirEcuacion( fi: TFunc_iRNenR; i: integer );
begin
  self.fi[ i]:= fi;
end;

procedure TPSO.Reset;
var
  k: integer;
begin
  for k:= 1 to nVariables do
    xfijadas[k]:= false;
end;

procedure TPSO.DefinirVariable(
      j: integer; xmin, xmax, xinicial: NReal;
      EsFija: boolean );
begin
  xfijadas[j]:= EsFija;
  xiniciales.pv[j]:= xinicial;
  xminimos.pv[j]:= xmin;
  xmaximos.pv[j]:= xmax;
  cajaActiva[j]:= true;
end;

procedure TPSO.DefinirVariable(
      j: integer; xinicial: NReal;
      EsFija: boolean );
begin
  xfijadas[j]:= EsFija;
  xiniciales.pv[j]:= xinicial;
  xminimos.pv[j]:= 0;
  xmaximos.pv[j]:= 0;
  cajaActiva[j]:= false;
end;

constructor TPSO.Create( mEcuaciones, nVariables: integer );
var
  i,j: integer;
begin
  inherited Create;
  Self.mEcuaciones:= mEcuaciones;
  Self.nVariables:= nVariables;
  setlength( fi, mEcuaciones + 1 );


  for i:= 1 to mEcuaciones do
  begin
    fi[i]:= fnula_i;

  end;
  setlength( ivx, mEcuaciones + 1 );
  setlength( xfijadas, nVariables+1 );
  setlength( cajaActiva, nVariables+1 );
  for i:= 1 to nVariables do
  begin
      xfijadas[i]:= false;
      cajaActiva[i]:= false;
  end;
  xvalores:= TVectR.Create_Init( nVariables );
  xiniciales:= TVectR.Create_Init( nVariables );
  xminimos:= TVectR.Create_Init( nVariables );
  xmaximos:= TVectR.Create_Init( nVariables );

end;

procedure TPSO.Free;
var
  i: integer;
begin
  xminimos.Free;
  xiniciales.Free;
  xvalores.Free;
  setlength( ivx, 0 );
  setlength( fi, 0 );
  inherited Free;
end;


procedure TPSO.IniciarResolucion;
var
  k, jvarred: integer;
  cnt_Libres: integer;
begin
  jvarred:= 1;
  cnt_Libres:= nVariables;
  for k:= 1 to high( xfijadas ) do
    if not xfijadas[k] then
    begin
      ivx[jvarred]:= k;
      inc( jvarred );
    end
    else
      dec( cnt_Libres );
  if cnt_Libres < mEcuaciones then
    raise Exception.Create('El número de variables libres es: '
      +IntToStr( cnt_Libres )+' < '+ IntToStr( mEcuaciones ) );
  for k:= 1 to nVariables do
    xvalores.pv[k]:= xiniciales.pv[k];
end;

procedure TPSO.copy_xrToxvalores( xr: TVectR );
var
  ivarred: integer;
begin
  for ivarred:= 1 to xr.n do
    xvalores.pv[ ivx[ivarred]]:= xr.pv[ivarred];
end;

function TPSO.BuscarSolucion_PSO(
  maxErr: NReal; NMaxIter: integer;
  var err: NReal; var cnt_iters: integer ): boolean;
var
  xRed0, xRedSig: TVectR;
  fvals, fvalsSig: TVectR;
  k: integer;
  m: NReal;
  mfvals: TMatR;
  convergio: boolean;
  errSig: NReal;
  landa: NReal;
  reduciendoPaso: boolean;
  resb: boolean;
  e10: integer;

begin
  xredSig:= TVectR.Create_Init( mEcuaciones );
  fvals:= TVectR.Create_Init( mEcuaciones );
  fvalsSig:= TVectR.Create_init( mEcuaciones );
  xred0:= TVectR.Create_init( mEcuaciones );
  mfvals:= TMatR.Create_init( mEcuaciones, 1 );

  result:= convergio;

  xredSig.Free;
  fvals.Free;
  fvalsSig.Free;
  xred0.Free;
  mfvals.Free;


end;

end.

