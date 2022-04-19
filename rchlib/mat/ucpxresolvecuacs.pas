unit ucpxresolvecuacs;

interface
uses
  xmatdefs, MatReal, Algebrac, Matcpx, uresolvecuacs;

(*
Implementación de la clase TProblemaCPX para resolución de sistemas
de ecuaciones complejas.
El sistema se supone descripto por un conjunto de ecuaciones
del tipo
    fi( z1, z2, ..... zn ) = 0  ; i= 1 ... mEcuaciones

Sonde z1, z2, ... son el conjunto de variables.
Si nVariables es el número de variables, para que el sistema tenga solución
debe cumplirse que nVariables >= mEcuaciones.

En el armado del problema se inscriben las funciones fi llamando al
procedimiento inscribirEcuacion.
Cada variable zk puede representarse o en coordenadas rectangulares o
en coordenadas polares. Al inscribir la variable con el procedimiento
inscribir variable, se indica el tipo de representación, un valor inicial
de la variable y además si se
deben considerar los valores reales de la representación como variables
libres o parámetros fijos.

Como la resolución se hace utilizándo un resolvedor de sistemas de ecuaciones
de números reales, cada ecuación fi=0 se desdobla internamente en dos
ecuacions Re(fi)= 0 e Im(fi)=0
A su vez cada variable zk genera dos variables para el problema planteado con
números reales que serán Re(zk) e Im(zk) o mod1(zk) y fase(zk) dependiendo
del tipo de representación elegido para la variable.

La cantidad de ecuaciones del problema REAL es 2*mEcuaciones
La cantidad de variables del problema REAL es 2*nVariables

Si nVariables > mEcuaciones supondremos que el usuario fija el valor de
2*(mEcuaciones - nVariables) de las variables del problema REAL
y por lo tanto la cantidad de variables libres es igual al número de ecuaciones.

El operador derivada no está siempre bien definido dentro del espacio compljo
basta como ejemplo intentar calcular la derivada del conjugado de z respecto
de z.  Como se verá, no es posible encontrar un complejo que multiplicado
por cualquier variación dz nos de como resultado la variación del conjunado de z.

Por esta razón, más que las derivadas de fi con respecto a z, necesitaremos
conocer las derivadas de fi respecto a cada uno de los campo de z.
Si la representación que tenemos de z es rectangular sus campos son la parte
real y la imaginaria. Si la representación de z es polar, sus campos son
su módulo y su fase. Las derivadas de fi respecto a cualquiera de los campos
de una de las variables z no es otra cosa que la derivada de la parte real e
imaginaria de fi respecto al campo en cuestión  d(fi.r)/dc + j d(fi.i)/dc

*)


type
  TTipoRepresentacionCPX= ( CPX_RECTANGULAR, CPX_POLAR );
  TFunc_iCNenC= function (i: integer; x: TVectComplex ): NComplex;
  TFunc_ikhCNenC= function (i, k, h: integer; x: TVectComplex ): NComplex;
  TIndVarLib= record
    kvar: integer; // 1..nVariables apunta a la variable compleja
    campo: integer; // 1 o 2 según se el primer campo o el segundo de la variable
  end;

  TDescriptorCPX = record
    representacion: TTipoRepresentacionCPX;
    c1Fijo, c2Fijo: boolean;
  end;

  TProblemaCPX= class; // forward declaration

  TProblema_EsclavoReal= class(   TProblema  )
    padre: TProblemaCPX;
    NvzMod: Integer; // cantidad de variables complejas que tienen
      // alguno de sus campos libres.
    ivzmod: array of integer; // tiene los índices de las variables
          // complejas que tienen alguno de sus campos libres

    constructor Create( mEcuaciones, nVariables: integer );
    procedure Free; override;
    procedure copy_xrToxvalores( xr: TVectR ); override;
        // calcula el Jacobiano del sistema para el valor guardado en xvalores
    procedure Calc_JRed( var JRed: TMatR ); override;
  // calcula el valor de las ecuaciones para el valor guardado en xvalores
    procedure Calc_F( var fval: TVectR ); override;

    procedure IniciarResolucion; override;
  end;

  TProblemaCPX = class
    mEcuaciones, nVariables: integer;
    fi: array of TFunc_iCNenC;
    gikh: array of array of array[1..2] of TFunc_ikhCNEnC;
    DescripcionDeVariables: array of TDescriptorCPX;
    zvalores, zvaloresiniciales: TVectComplex;
    ivx: array of TIndVarLib; // indices de las variables libres

    constructor Create( mEcuaciones, nVariables: integer );
    procedure Free;
    procedure Reset;

    procedure DefinirVariable(
      j: integer;
      representacion: TTipoRepresentacionCPX;
      c1min, c1max, c1inicial: NReal;
      c1EsFija: boolean;
      c2min, c2max, c2inicial: NReal;
      c2EsFija: boolean   ); overload;

    procedure DefinirVariable(
      j: integer;
      representacion: TTipoRepresentacionCPX;
      c1inicial: NReal;
      c1EsFija: boolean;
      c2inicial: NReal;
      c2EsFija: boolean); overload;

    procedure InscribirEcuacion( fi: TFunc_iCNenC; i_ec: integer );
    procedure InscribirDerivada( gikh: TFunc_ikhCNenC; i_ec, k_var, h_campo: integer );

    function BuscarSolucion_NewtonRapson(
      maxErr: NReal; NMaxIter: integer;
      var err: NReal; var cnt_iters: integer ): boolean;

    function errMsg: string;
    private
      ProblemaReal: TProblema_EsclavoReal;
    procedure IniciarResolucion;

  end;

implementation


constructor TProblema_EsclavoReal.Create( mEcuaciones, nVariables: integer );
begin
  inherited Create( mEcuaciones, nVariables );
  setlength( self.ivzmod, nVariables+1 );
end;

procedure TProblema_EsclavoReal.Free;
begin
  setlength( ivzmod, 0 );
  inherited Free;
end;
procedure TProblema_EsclavoReal.copy_xrToxvalores( xr: TVectR );
var
  ivzm: integer;
  iz: integer;
  ro, alfa: NReal;
begin
// primero le decimos al problema en coordenadas reales que
// actualice el vector de variables para disponer de todos los valroes
  inherited copy_xrToxvalores( xr );

// Ahora recorremos el vector de variables complejas que necesitan
// actualización y las actualizamos. Si está en coordenadas rectángulares
// es simplemente copiar los valores de xvalores asociados a la variable
// Si está en coordenadas polares tenemos que transformar los valores de
// xvalores para formar el complejo correspondiente.

  for ivzm:= 1 to Nvzmod do
  begin
    iz:= ivzmod[ivzm];
    case padre.DescripcionDeVariables[iz].representacion of
    CPX_RECTANGULAR:
      begin
        padre.zvalores.v[iz].r:= xvalores.pv[ 2*iz -1 ];
        padre.zvalores.v[iz].i:= xvalores.pv[ 2*iz ];
      end;
    CPX_POLAR:
      begin
        ro:= xvalores.pv[ 2*iz -1 ];
        alfa:= xvalores.pv[ 2*iz ];
        padre.zvalores.v[iz].r:= ro* cos( alfa );
        padre.zvalores.v[iz].i:= ro* sin( alfa );
      end;
    end;
  end;
end;


procedure TProblema_EsclavoReal.Calc_JRed( var JRed: TMatR );
var
  iecz: integer;
  ivarred, ivarnored: integer;
  m: NComplex;
  viz: TIndVarLib;
begin
for iecz:= 1 to Padre.mEcuaciones do
    for ivarred:= 1 to Self.mEcuaciones do // Self.mEcuacions = Padre.mEcuaciones*2
    begin

      viz:= padre.ivx[ ivarred ];
      ivarnored:= viz.kvar;
      //writeln('iecz ',iecz,' ivarred ',ivarred,' ',iecz,' ',ivarnored, ' ',viz.campo);
      m:= padre.gikh[iecz][ivarnored][viz.campo](iecz, ivarnored, viz.campo, padre.zvalores );
      JRed.pm[iecz*2-1].pv[ivarred]:= m.r;
      JRed.pm[iecz*2  ].pv[ivarred]:= m.i;

    end;
      //Jred.WriteArchiXLT('jred.xlt');

end;

procedure TProblema_EsclavoReal.Calc_F( var fval: TVectR );
var
  iecz: integer;
  m: NComplex;
begin
  for iecz:= 1 to Padre.mEcuaciones do
  begin
    m:= padre.fi[iecz]( iecz, padre.zvalores );
    fval.pv[iecz*2-1]:= m.r;
    fval.pv[iecz*2  ]:= m.i;
  end;
end;



procedure TProblema_EsclavoReal.IniciarResolucion;
begin
  inherited IniciarResolucion;
  padre.IniciarResolucion;
end;

constructor TProblemaCPX.Create( mEcuaciones, nVariables: integer );
var
  iec: integer;
begin
  inherited Create;
  self.mEcuaciones:= mEcuaciones;
  self.nVariables:= nVariables;
  ProblemaReal:= TProblema_Esclavoreal.Create( mEcuaciones*2, nVariables*2 );


  setlength( fi, mEcuaciones +1 );
  setlength( gikh, mEcuaciones+1 );
  for iec:= 1 to mEcuaciones do
    setlength( gikh[iec], nVariables+1 );

  setlength( DescripcionDeVariables, nvariables+1 );
  zvalores:= TVectComplex.Create_Init( nvariables );
  zvaloresiniciales:= TVectComplex.Create_Init( nvariables );
  setlength( ivx, 2* ( nVariables - mEcuaciones )+1 );

end;



procedure TProblemaCPX.Free;
var
  iec: integer;
begin

  for iec:= 1 to mEcuaciones do
    setlength( gikh[iec], 0 );
  setlength( gikh, 0 );

  setlength( fi, 0 );
  setlength( DescripcionDeVariables, 0 );
  zvalores.Free;
  zvaloresiniciales.Free;
  setlength( ivx, 0 );
  ProblemaReal.Free;
  inherited Free;
end;


procedure TProblemaCPX.Reset;
var
  k: integer;
begin
  for k:= 1 to nVariables do
  begin
    self.DescripcionDeVariables[k].c1Fijo:= false;
    self.DescripcionDeVariables[k].c2Fijo:= false;
  end;
end;

procedure TProblemaCPX.DefinirVariable(
  j: integer;
  representacion: TTipoRepresentacionCPX;
  c1min, c1max, c1inicial: NReal;
  c1EsFija: boolean;
  c2min, c2max, c2inicial: NReal;
  c2EsFija: boolean   );
begin
  DescripcionDeVariables[j].representacion:= representacion;
  self.DescripcionDeVariables[j].c1Fijo:= c1EsFija;
  self.DescripcionDeVariables[j].c2Fijo:= c2EsFija;

  ProblemaReal.DefinirVariable(j*2-1, c1min, c1max, c1inicial, c1EsFija );
  ProblemaReal.DefinirVariable(j*2,   c2min, c2max, c2inicial, c2EsFija );

  case representacion of
    CPX_RECTANGULAR: zvaloresiniciales.v[j]:= numc( c1inicial, c2inicial )^;
    CPX_POLAR: zvaloresiniciales.v[j]:=
        numc( c1inicial* cos( c2inicial), c1inicial* sin( c2inicial ))^;
  end;
end;

procedure TProblemaCPX.DefinirVariable(
  j: integer;
  representacion: TTipoRepresentacionCPX;
  c1inicial: NReal;
  c1EsFija: boolean;
  c2inicial: NReal;
  c2EsFija: boolean);
begin
  DescripcionDeVariables[j].representacion:= representacion;
  self.DescripcionDeVariables[j].c1Fijo:= c1EsFija;
  self.DescripcionDeVariables[j].c2Fijo:= c2EsFija;

  ProblemaReal.DefinirVariable(j*2-1, c1inicial, c1EsFija );
  ProblemaReal.DefinirVariable(j*2,   c2inicial, c2EsFija );

  case representacion of
    CPX_RECTANGULAR: zvaloresiniciales.v[j]:= numc( c1inicial, c2inicial )^;
    CPX_POLAR: zvaloresiniciales.v[j]:=
        numc( c1inicial* cos( c2inicial), c1inicial* sin( c2inicial ))^;
  end;

end;

procedure TProblemaCPX.InscribirEcuacion( fi: TFunc_iCNenC; i_ec: integer );
begin
  self.fi[i_ec]:= fi;
end;

procedure TProblemaCPX.InscribirDerivada( gikh: TFunc_ikhCNenC; i_ec, k_var, h_campo: integer );
begin
  self.gikh[ i_ec][k_var][h_campo]:= gikh;
end;


procedure TProblemaCPX.IniciarResolucion;
var
  k, jvarred: integer;
  flg_tocada: integer;

begin
  jvarred:= 1;
  self.ProblemaReal.NvzMod:= 0;
  for k:= 1 to nVariables do
  begin
    flg_tocada:= 0;
    if not self.DescripcionDeVariables[k].c1Fijo then
    begin
      ivx[jvarred].kvar:= k;
      ivx[jvarred].campo:= 1;
      inc( jvarred );
      inc( flg_tocada );
    end;
    if not self.DescripcionDeVariables[k].c2Fijo then
    begin
      ivx[jvarred].kvar:= k;
      ivx[jvarred].campo:= 2;
      inc( jvarred );
      inc( flg_tocada );
    end;
    if flg_tocada >0 then
    begin
      inc( ProblemaReal.NvzMod );
      ProblemaReal.ivzmod[ProblemaReal.NvzMod]:= k;
    end;
  end;

  for k:= 1 to nVariables do
    zvalores.v[k]:= zvaloresiniciales.v[k];
end;

function TProblemaCPX.BuscarSolucion_NewtonRapson(
  maxErr: NReal; NMaxIter: integer;
  var err: NReal; var cnt_iters: integer ): boolean;
begin
  self.ProblemaReal.padre:= self;
  result:= ProblemaReal.BuscarSolucion_NewtonRapson(
    maxErr, NMaxIter, TRUE, err, cnt_iters)
end;

function TProblemaCPX.errMsg: string;
begin
  result:= ProblemaReal.errMsg;
end;


end.
