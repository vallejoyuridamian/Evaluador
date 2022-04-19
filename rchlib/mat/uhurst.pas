unit uhurst;

interface
uses
	xmatdefs, matreal, math;

Type
  TLVR = array[0..1024*1024] of NReal;
  PLVR = ^TLVR;

// rch 13/12/2010 implementación del método de HURST
  THurst_Rescaled = class
    slope, intercept, slopeErr: NReal;
    points_y, points_x: TVectR;
    pdatos: PLVR;
    ndatos: integer;
    constructor Create( const xpDatos: PLVR; const xNDatos: integer );
    procedure Free;
  private
    procedure CalcularParametros;
    function calc_mean_( const v: PLVR;  const  N: integer ): NReal;
    function calc_RS_( const v: PLVR; const boxSize: integer ): NReal;
    function calc_RS_ave_( const v: PLVR; const N, boxSize: integer ): NReal;
    procedure Calc_hurst_est( const v: PLVR; N: integer );
  end;


implementation



constructor THurst_Rescaled.Create(const xpDatos: PLVR; const xNDatos: integer );
begin
  points_x:= nil;
  points_y:= nil;
  pdatos:= xpdatos;
  ndatos:= xNDatos;
  Calc_hurst_est( pdatos, ndatos );
end;


procedure THurst_Rescaled.CalcularParametros;
var
  k: integer;
  y: NReal;
begin
  points_y.AproximacionLineal( slope, intercept, points_x);
  slopeErr:= 0;
  for k:= 1 to points_x.n do
  begin
    y:= slope * points_x.pv[k] + intercept;
    slopeErr:= slopeErr + sqr( y - points_y.pv[k] );
  end;
  slopeErr:= sqrt( slopeErr/ points_x.N );
end;

procedure THurst_Rescaled.Free;
begin
  points_x.Free;
  points_y.Free;
end;

function THurst_Rescaled.calc_mean_( const v: PLVR;  const  N: integer ): NReal;
var
  sum, mean: NReal;
  i: integer;
begin
  sum:= 0;
  for i:= 0 to N-1 do
    sum:= sum + v^[i];
  mean:= sum / N;
  result:= mean;
end; // calc_mean_


function THurst_Rescaled.calc_RS_( const v: PLVR; const boxSize: integer ): NReal;
var
  RS: NReal;
  min, max, runningSum, runningSumSqr: NReal;
  mean: NReal;
  devFromMean: NReal;
  i: integer;
  variance, stdDev, range: NReal;
begin
  RS := 0.0;
  if (v <> nil ) and ( boxSize > 0) then
  begin
    mean := calc_mean_( v, boxSize );
    min := 0.0;
    max := 0.0;
    runningSum := 0.0;
    runningSumSqr := 0.0;
    for i:= 0 to boxSize - 1 do
    begin
      devFromMean := v^[i] - mean;
      runningSum := runningSum + devFromMean;
      runningSumSqr:= runningSumSqr + sqr(devFromMean );
      if (runningSum < min) then
        min := runningSum;
      if (runningSum > max) then
        max := runningSum;
    end;
    variance := runningSumSqr / boxSize;
    stdDev := sqrt( variance );

    range := max - min;
    if ( stdDev > AsumaCero ) then
      RS := range / stdDev
    else
      RS:= -1; // para indicar que no está definida.
  end;

  result:= RS;
end; // calc_RS


function THurst_Rescaled.calc_RS_ave_( const v: PLVR; const N, boxSize: integer ): NReal;
var
  i: integer;
  stdDev, range, RS, RSSum, mean, RSAve: NReal;
  numBoxes: integer;
  boxStart: PLVR;
  cntBoxes: integer;
begin
  RSAve := 0.0;
  numBoxes := N div boxSize;
  if (numBoxes > 0) then
  begin
    RSSum:= 0;
    i:= 0;
    cntBoxes:= 0;
    while (i+boxSize <= N ) do
    begin
      boxStart := @v^[i];
      RS := calc_RS_( boxStart, boxSize );
      if ( RS >= 0 ) then
      begin
        RSSum := RSSum + RS;
        inc( cntBoxes );
      end;
      i := i + boxSize;
    end; // for i
    if cntBoxes > 0  then
      RSAve := RSSum /  numBoxes
    else
      RSave:= -1; // para indicar que no está definida
  end;
  result:= RSAve;
end; // calc_RS_ave_


procedure THurst_Rescaled.Calc_hurst_est( const v: PLVR; N: integer);
var
  hurstEst: NReal;
  boxSize: integer;
  RSAve, logRSAve, logBoxSize: NReal;
  cnt: integer;
  parar: boolean;
  tmp: TVectR;
  k: Integer;

const
  minBox = 8;
begin
  hurstEst := 0.0;
  if ( v <> nil) and ( N > 0) then
  begin
    boxSize:= N;
    cnt:= 0;
    while ( boxSize >= minBox ) do
    begin
      inc( cnt );
      boxSize := (boxSize div 2);
    end;

    points_x:= TVectR.Create_Init( cnt );
    points_y:= TVectR.Create_Init( cnt );

    boxSize:= N;
    cnt:= 0;
    parar:= false;
    while (not parar) and ( boxSize >= minBox ) do
    begin
      inc( cnt );
      RSAve := calc_RS_ave_( v, N, boxSize );
      if RSAve > 0 then
      begin
        logRSAve := log2( RSAve );
        logBoxSize := log2( boxSize );
        points_x.pv[cnt]:= logBoxSize;
        points_y.pv[cnt]:= logRSave;
        boxSize := (boxSize div 2);
      end
      else
        parar:= true;
    end;

    if parar then
    begin
      // acortamos los vectores.
      tmp:= points_x;
      points_x:= TVectR.Create_init( cnt );
      for k:= 1 to cnt do
        points_x.pv[k]:= tmp.pv[k];
      tmp.free;

      tmp:= points_y;
      points_y:= TVectR.Create_init( cnt );
      for k:= 1 to cnt do
        points_y.pv[k]:= tmp.pv[k];
      tmp.free;
    end;

    CalcularParametros;

  end;
end; // calc_hurst_est

end.
