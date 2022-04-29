unit uCosaConNombre;

interface

uses
	ucosa ,xMatDefs, uFechas, Classes, SysUtils, uVarDefs;

type
	PCosaConNombre = ^TCosaConNombre;
	TClaseDeCosaConNombre = class of TCosaConNombre;

	TCosaConNombre = class( TCosa )
		public
			nombre: string;
			pubvarlst : TListaVarDefs; // lista de variables pinchables
			constructor Create( nombre: string );
			constructor Create_ReadFromText( f: TArchiTexto ); override;
			function Create_Clone : TCosa; override;
			procedure Free; override;
			procedure WriteToText(f: TArchiTexto ); override;
      //Retorna "clase, nombre" de la cosa seleccionada
			function ClaseNombre : String;
			function InfoAd : String; virtual;
			class function DescClase : String; override;
			function buscarVariable(const xnombreVar : String) : TVarDef;

			procedure PublicarVariableS(const xnombre, xunidades: string; var xvar: string );
			procedure PublicarVariableNR(const xnombre, xunidades: string; precision, decimales: Integer; var xvar: NReal );
			procedure PublicarVariableNI(const xnombre, xunidades: string; var xvar: integer );
			procedure PublicarVariableB(const xnombre, xunidades: string; var xvar: boolean );
			procedure PublicarVariableFecha(const xnombre: string; var xvar: TFecha );

			procedure PublicarVariableVR(const xnombre, xunidades: string; precision, decimales: Integer; var xvar: TDAOfNReal; usarNomenclaturaConPostes: boolean );
			procedure PublicarVariableVI(const xnombre, xunidades: string; var xvar: TDAOfNInt; usarNomenclaturaConPostes: boolean );
			procedure PublicarVariableVB(const xnombre, xunidades: string; var xvar: TDAOfBoolean; usarNomenclaturaConPostes: boolean );

			procedure PublicarVariablePS(const xnombre, xunidades: string; var pd ; var xvar: string );

			procedure PublicarVariablePNR(const xnombre, xunidades: string; precision, decimales: Integer; var pd ; var xvar: NReal ); overload;
			procedure PublicarVariablePNI(const xnombre, xunidades: string; var pd ; var xvar: integer ); overload;
			procedure PublicarVariablePB(const xnombre, xunidades: string; var pd ; var xvar: boolean ); overload;

      //Publican las variables igual que arriba pero permiten especificar que son parte de un
      //arreglo y su indice en el arreglo
			procedure PublicarVariablePNR(const xnombre, xunidades: string; precision, decimales: Integer; var pd ; var xvar: NReal; indiceVar: Integer ); overload;
			procedure PublicarVariablePNI(const xnombre, xunidades: string; var pd ; var xvar: integer; indiceVar: Integer ); overload;
			procedure PublicarVariablePB(const xnombre, xunidades: string; var pd ; var xvar: boolean; indiceVar: Integer ); overload;

			procedure PublicarVariablePFecha(const xnombre: string; var pd ; var xvar: TFecha );

			procedure PublicarVariablePVNR(const xnombre, xunidades: string; precision, decimales: Integer; var pd; var xvar: TDAofNReal; usarNomenclaturaConPostes: boolean );
			procedure PublicarVariablePVNI(const xnombre, xunidades: string; var pd; var xvar: TDAofNInt; usarNomenclaturaConPostes: boolean );
			procedure PublicarVariablePVB(const xnombre, xunidades: string; var pd; var xvar: TDAOfBoolean; usarNomenclaturaConPostes: boolean );

			procedure PubliVars; virtual;
      function varsPSimRes3PorDefecto: TDAofString; virtual;
			procedure CambioFichaPD; virtual; abstract;
		end;

	TListaDeCosasConNombre = class( TListaDeCosas )
		private
			nombre : String;
		public
			constructor Create( nombre : String);
			constructor Create_ReadFromText( f: TArchiTexto ); override;
			procedure WriteToText( f: TArchiTexto ); override;

			function Add(cosa : TCosaConNombre) : Integer; reintroduce;
      procedure insert(indice: Integer; cosa : TCosaConNombre); reintroduce;
      function Remove(cosa : TCosaConNombre): Integer; reintroduce;
      function nombresCosas: TStringList;
//      procedure Delete(indice: Integer); reintroduce;

      function getNextId(clase: TClaseDeCosaConNombre): String;
			function listaDeCosasDeClase(clases : TList) : TListaDeCosasConNombre;

      function find(const nombre: string ): TCosaConNombre; overload;
			function find(const nombre: string; var ipos: integer ): boolean; overload;
			function find(const clase, nombre: string ; var ipos: integer ): boolean; overload;
	end;

	//Es igual que TListaDeCosasConNombre pero se guarda con
	//referencias a cosas, asi cuando se carga apunta directamente
	//a ellas y no crea nuevas instancias del objeto guardado
	TListaDeReferenciasACosas = class(TCosa)
		public
		lst : TDAOfPtr;
		constructor Create;
		constructor Create_ReadFromText(f : TArchiTexto); override;
		procedure WriteToText( f: TArchiTexto ); override;
		function Addx(cosa : TCosaConNombre) : Integer; reintroduce;

		function find(const nombre: string; var ipos: integer ): boolean; overload;
		function find(const clase, nombre: string; var ipos: integer ): boolean; overload;
	end;


procedure registrar_referencia(referente : TCosa ; claseDelreferido, nombreDelReferido: string; var referencia);

// Hace un DUMP de las referencias para debug
procedure DumpReferencias( archi: string );

function existeReferencia_al(referido: TCosaConNombre): boolean;

function existeReferencia_del(referente: TCosa; referido: TCosaConNombre): boolean;

// resuelve las referencias contra la lista CosasLst y retorna la
// cantidad de referencias que quedan sin resolver (por si es necesario pasar otra lista)
function resolver_referencias( CosasLst : TListaDeCosasConNombre ): integer;

// resuelve las referencias que haya contra la lista CosasLst de para el referente indicado
// retorna la cantidad de referencias anotadas con el (referente) que no han podido resolverse
function resolver_referenciasDeCosa( referente: TCosa ; CosasLst : TListaDeCosasConNombre) : integer;
//Cambia todas las referencias registradas a ref_Anterior por ref_Nueva, devuelve
//el numero de referencias cambiadas
function cambiar_referencias_al( ref_Anterior, ref_Nueva : TCosaConNombre) : Integer;
//Cambia todas las referencias registradas a ref_Anterior por ref_Nueva, que
//sean de referente devuelve el numero de referencias cambiadas
function cambiar_referencias_del_al(referente: TCosa; ref_Anterior, ref_Nueva : TCosaConNombre) : Integer;

//Cambia el nombre del referido en las referencias que esten luego de la posicion k en la lista y que tengan nombre nombre_Anterior por nombre_Nuevo
function cambiar_NombreDelReferidoEnReferenciasPosterioresAK(k: Integer ; nombre_Anterior, nombre_Nuevo, claseReferido : String) : Integer;

//Elimina las referencias del referente
function eliminar_referencias_del(referente : TCosa) : Integer;
//Retorna la cantidad de referencias pendientes a ser resueltas
function referenciasSinResolver : Integer;

// imprime a consola las referencias sin resolver.
procedure WriteLNReferencias;

procedure LimpiarReferencias;

//type TListSortCompare = function (Item1, Item2: Pointer): Integer;

//Retorna -1 si item1 < item2, 0 si son iguales y 1 si item1 > item2
function ordenString(Item1, Item2: Pointer): Integer;

procedure AlInicio;
procedure AlFinal;

//Extraen la clase o el nombre del string obtenido en claseNombre
function ParseNombre(const claseNombre : String) : String;
function ParseClase(const claseNombre : String) : String;

implementation

//------------------
//Funciones globales
//==================

// funciones para resolver referencias a cosas
var
	referencias: TList;

type
	TFichaReferencia= class
		referente : TCosa;
		referido_clase, referido_nombre: string;
		referencia: PCosaConNombre;
		constructor Create(referente : TCosa; referencia: PCosaConNombre; referido_clase, referido_nombre: string );
		procedure Free;
	end;

//--------------------------
// Métodos de TCosaConNombre
//==========================

procedure TCosaConNombre.PublicarVariableNR(const xnombre, xunidades: string; precision, decimales: Integer; var xvar: NReal );
var
	fv: TVarDef_NR;
begin
	fv:= TVarDef_NR.Create(self, xnombre, xunidades, precision, decimales, @xvar );
	self.pubvarlst.Add( fv );
end;

procedure TCosaConNombre.PublicarVariableNI(const xnombre, xunidades: string; var xvar: integer );
var
	fv: TVarDef_NI;
begin
	fv:= TVarDef_NI.Create(self, xnombre, xunidades, @xvar );
	self.pubvarlst.Add( fv );
end;

procedure TCosaConNombre.PublicarVariableB(const xnombre, xunidades: string; var xvar: boolean );
var
	fv: TVarDef;
begin
	fv:= TVarDef_B.Create(self, xnombre, xunidades, @xvar );
	self.pubvarlst.Add( fv );
end;

function TCosaConNombre.buscarVariable(const xnombreVar : String) : TVarDef;
var
	resultado : TVarDef;
	i : Integer;
begin
	resultado := NIL;
	for i := 0 to pubvarlst.Count -1 do
		if TVarDef(pubvarlst[i]).nombreVar = xnombreVar then
    begin
			resultado := pubvarlst[i];
			break;
		end;
	result := resultado;
end;

procedure TCosaConNombre.PublicarVariableS(const xnombre, xunidades: string; var xvar: string );
var
	fv: TVarDef_S;
begin
	fv:= TVarDef_S.Create(self, xnombre, xunidades, @xvar );
	self.pubvarlst.Add( fv );
end;

procedure TCosaConNombre.PublicarVariableFecha(const xnombre: string; var xvar: TFecha );
var
	fv: TVarDef;
begin
	fv:= TVarDef_Fecha.Create(self, xnombre, @xvar );
	self.pubvarlst.Add( fv );
end;

procedure TCosaConNombre.PublicarVariableVR(
 const xnombre, xunidades: string;
 precision, decimales: Integer;
 var xvar: TDAOfNReal; usarNomenclaturaConPostes: boolean );
var
	fv: TVarDef_VNR;
	i : Integer;
begin
  if length(xvar) > 0 then
  begin
    fv:= TVarDef_VNR.Create(self, xnombre, xunidades, precision, decimales, @xvar, usarNomenclaturaConPostes );
	  self.pubvarlst.Add( fv );

    if usarNomenclaturaConPostes then
      for i := 0 to high(xvar) do
        self.PublicarVariablePNR(xnombre + '_P' + IntToStr(i + 1), xunidades, precision, decimales, xvar, xvar[i], i + 1)
    else
      for i := 0 to high(xvar) do
        self.PublicarVariablePNR(xnombre + '[' + IntToStr(i + 1) + ']', xunidades, precision, decimales, xvar, xvar[i]);
  end;
end;

procedure TCosaConNombre.PublicarVariableVI(const xnombre, xunidades: string;  var xvar: TDAOfNInt; usarNomenclaturaConPostes: boolean );
var
	fv: TVarDef_VNI;
	i : Integer;
begin
  if length(xvar) > 0 then
  begin
    fv:= TVarDef_VNI.Create(self, xnombre, xunidades, @xvar, usarNomenclaturaConPostes );
	  self.pubvarlst.Add( fv );

    if usarNomenclaturaConPostes then
      for i := 0 to high(xvar) do
        self.PublicarVariablePNI(xnombre + '_P' + IntToStr(i + 1), xunidades, xvar, xvar[i], i + 1)
    else
      for i := 0 to high(xvar) do
        self.PublicarVariablePNI(xnombre + '[' + IntToStr(i + 1) + ']', xunidades, xvar, xvar[i]);
  end;
end;

procedure TCosaConNombre.PublicarVariableVB(const xnombre, xunidades: string; var xvar: TDAOfBoolean; usarNomenclaturaConPostes: boolean );
var
	fv: TVarDef_VB;
	i : Integer;
begin
  if length(xvar) > 0 then
  begin
    fv:= TVarDef_VB.Create(self, xnombre, xunidades, @xvar, usarNomenclaturaConPostes );
  	self.pubvarlst.Add( fv );

    if usarNomenclaturaConPostes then
      for i := 0 to high(xvar) do
        self.PublicarVariablePB(xnombre + '_P' + IntToStr(i + 1), xunidades, xvar, xvar[i], i + 1)
    else
      for i := 0 to high(xvar) do
        self.PublicarVariablePB(xnombre + '[' + IntToStr(i + 1) + ']', xunidades, xvar, xvar[i]);
  end;
end;

procedure TCosaConNombre.PublicarVariablePS(const xnombre, xunidades: string; var pd ; var xvar: string );
var
	fv: TVarDef_PS;
begin
	fv:= TVarDef_PS.Create(self, xnombre, xunidades, @pd, @xvar );
	self.pubvarlst.Add( fv );
end;

procedure TCosaConNombre.PublicarVariablePNR(const xnombre, xunidades: string; precision, decimales: Integer; var pd ; var xvar: NReal );
var
	fv: TVarDef_PNR;
begin
	fv:= TVarDef_PNR.Create(self, xnombre, xunidades, precision, decimales, @pd, @xvar );
	self.pubvarlst.Add( fv );
end;

procedure TCosaConNombre.PublicarVariablePNI(const xnombre, xunidades: string; var pd ; var xvar: integer );
var
	fv: TVarDef_PNI;
begin
	fv:= TVarDef_PNI.Create(self, xnombre, xunidades, @pd, @xvar);
	self.pubvarlst.Add( fv );
end;

procedure TCosaConNombre.PublicarVariablePB(const xnombre, xunidades: string; var pd ; var xvar: boolean );
var
	fv: TVarDef_PB;
begin
	fv:= TVarDef_PB.Create(self, xnombre, xunidades, @pd, @xvar );
	self.pubvarlst.Add( fv );
end;

procedure TCosaConNombre.PublicarVariablePNR(const xnombre, xunidades: string; precision, decimales: Integer; var pd ; var xvar: NReal; indiceVar: Integer );
var
	fv: TVarDef_PNR;
begin
	fv:= TVarDef_PNR.Create(self, xnombre, xunidades, precision, decimales, @pd, @xvar );
  fv.setIndice(indiceVar);
	self.pubvarlst.Add( fv );
end;

procedure TCosaConNombre.PublicarVariablePNI(const xnombre, xunidades: string; var pd ; var xvar: integer; indiceVar: Integer );
var
	fv: TVarDef_PNI;
begin
	fv:= TVarDef_PNI.Create(self, xnombre, xunidades, @pd, @xvar);
  fv.setIndice(indiceVar);
	self.pubvarlst.Add( fv );
end;

procedure TCosaConNombre.PublicarVariablePB(const xnombre, xunidades: string; var pd ; var xvar: boolean; indiceVar: Integer );
var
	fv: TVarDef_PB;
begin
	fv:= TVarDef_PB.Create(self, xnombre, xunidades, @pd, @xvar );
  fv.setIndice(indiceVar);
	self.pubvarlst.Add( fv );
end;

procedure TCosaConNombre.PublicarVariablePFecha(const xnombre: string; var pd ; var xvar: TFecha );
var
	fv: TVarDef_PFecha;
begin
	fv:= TVarDef_PFecha.Create(self, xnombre, @pd, @xvar );
	self.pubvarlst.Add( fv );
end;

procedure TCosaConNombre.PublicarVariablePVNR(const xnombre, xunidades: string; precision, decimales: Integer; var pd ; var xvar: TDAofNReal; usarNomenclaturaConPostes: boolean );
var
	fv: TVarDef_PVNR;
	i : Integer;
begin
	fv:= TVarDef_PVNR.Create(self, xnombre, xunidades, precision, decimales, @pd, @xvar, usarNomenclaturaConPostes );
	self.pubvarlst.Add( fv );

  if usarNomenclaturaConPostes then
    for i := 0 to high(xvar) do
      self.pubvarlst.Add(TVarDef_NR.CreatePpdIndice(self, xnombre + '_P' + IntToStr(i + 1), xunidades,
                         precision, decimales, @xvar[i], @xvar, @pd))
  else
    for i := 0 to high(xvar) do
      self.pubvarlst.Add(TVarDef_NR.CreatePpdIndice(self, xnombre + '[' + IntToStr(i + 1) + ']', xunidades,
                         precision, decimales, @xvar[i], @xvar, @pd));
end;

procedure TCosaConNombre.PublicarVariablePVNI(const xnombre, xunidades: string; var pd ; var xvar: TDAofNInt; usarNomenclaturaConPostes: boolean );
var
	fv: TVarDef_PVNI;
	i : Integer;
begin
	fv:= TVarDef_PVNI.Create(self, xnombre, xunidades, @pd, @xvar, usarNomenclaturaConPostes );
	self.pubvarlst.Add( fv );
  
  if usarNomenclaturaConPostes then
    for i := 0 to high(xvar) do
      self.pubvarlst.Add(TVarDef_NI.CreatePpdIndice(self, xnombre + '_P' + IntToStr(i + 1), xunidades,
                         @xvar[i], @xvar, @pd))  
  else
    for i := 0 to high(xvar) do
      self.pubvarlst.Add(TVarDef_NI.CreatePpdIndice(self, xnombre + '[' + IntToStr(i + 1) + ']', xunidades,
                         @xvar[i], @xvar, @pd));
end;

procedure TCosaConNombre.PublicarVariablePVB(const xnombre, xunidades: string; var pd ; var xvar: TDAOfBoolean; usarNomenclaturaConPostes: boolean );
var
	fv: TVarDef_PVB;
	i : Integer;
begin
	fv:= TVarDef_PVB.Create(self, xnombre, xunidades, @pd, @xvar, usarNomenclaturaConPostes );
	self.pubvarlst.Add( fv );

  if usarNomenclaturaConPostes then
    for i := 0 to high(xvar) do
      self.pubvarlst.Add(TVarDef_B.CreatePpdIndice(self, xnombre + '_P' + IntToStr(i + 1), xunidades,
                         @xvar[i], @xvar, @pd))
  else
    for i := 0 to high(xvar) do
      self.pubvarlst.Add(TVarDef_B.CreatePpdIndice(self, xnombre + '[' + IntToStr(i + 1) + ']', xunidades,
                         @xvar[i], @xvar, @pd));
end;

procedure TCosaConNombre.PubliVars;
begin
	if pubvarlst <> NIL then
		pubvarlst.Free;
	self.pubvarlst:= TListaVarDefs.Create;
//	self.PublicarVariableS('Nombre', nombre );
end;

function TCosaConNombre.varsPSimRes3PorDefecto: TDAofString;
begin
  result:= NIL;
end;

constructor TCosaConNombre.Create( nombre: string );
begin
	inherited Create;
	self.nombre:=nombre;
{$IFDEF CNT_COSAS}
	CantCosas.incCntCosasClase(self.ClassType);
{$ENDIF}
	pubvarlst := NIL;
end;

function TCosaConNombre.Create_Clone: TCosa;
var
	res : TCosaConNombre;
begin
	res := inherited Create_Clone as TCosaConNombre;
  res.pubvarlst := NIL;
	result:= res;
end;

procedure TCosaConNombre.Free;
begin
{$IFDEF CNT_COSAS}
	CantCosas.decCntCosasClase(Self.ClassType);
{$ENDIF}
//	uCosaConNombre.eliminar_referencias_de(self);
	if pubvarlst <> NIL then
		pubvarlst.Free;
	inherited Free;
end;

constructor TCosaConNombre.Create_ReadFromText( f: TArchiTexto );
var
  fs: TArchiTexto;
begin
	inherited Create;

  if f.unArchivoPorCosa then
    fs:= f.CreateRamaForWrite( '', Self.ClassName, Self.nombre )
  else
    fs:= f;

  fs.IniciarLecturaRetrasada;
	fs.rd('nombre',  nombre );
  fs.EjecutarLectura;
{$IFDEF CNT_COSAS}
	CantCosas.incCntCosasClase(self.ClassType);
{$ENDIF}
	pubvarlst := NIL;

  if f.unArchivoPorCosa then
    fs.Free;
end;

procedure TCosaConNombre.WriteToText( f: TArchiTexto );
var
  fs: TArchiTexto;
begin
  if f.unArchivoPorCosa then
  begin
    fs:= f.CreateRamaForWrite( '', Self.ClassName, Self.nombre );
	  fs.wr( 'nombre', nombre );
    fs.Free;
  end
  else
  	f.wr( 'nombre', nombre );
end;

function TCosaConNombre.ClaseNombre : String;
begin
	result := Self.ClassName + ', ' + self.nombre;
end;

function TCosaConNombre.infoAd : String;
begin
	result:= '';//nombre;
end;

class function TCosaConNombre.DescClase : String;
begin
	result := 'Cosa con Nombre';
end;

//---------------------------------
//Metodos de TListaDeCosasConNombre
//=================================

constructor TListaDeCosasConNombre.Create( nombre : String);
begin
	inherited Create( nombre );
	self.nombre := nombre;
end;

constructor TListaDeCosasConNombre.Create_ReadFromText( f: TArchiTexto );
var
	cnt_ids_alp: integer;
begin
  if f.Version < 2 then
  begin
    f.IniciarLecturaRetrasada;
    f.rd('Nombre', nombre);
    f.EjecutarLectura;
    f.aux_idCarpeta:= nombre;
    inherited Create_ReadFromText( f );
    f.rd('cnt_ids', cnt_ids_alp);
    f.EjecutarLectura;
  end
  else
  begin
    f.IniciarLecturaRetrasada;
    f.rd('Nombre', nombre);
    f.EjecutarLectura;
    f.aux_idCarpeta:= nombre;
    inherited Create_ReadFromText( f );
    f.EjecutarLectura;
  end;
end;

procedure TListaDeCosasConNombre.WriteToText( f: TArchiTexto );
begin
{ VERSION_ArchiTexto < 2
	 f.wr('Nombre', nombre);
	 inherited WriteToText( f );
   f.wr('cnt_ids', cnt_ids);}


	 f.wr('Nombre', nombre);
	 inherited WriteToText( f );
end;

function TListaDeCosasConNombre.getNextId(clase: TClaseDeCosaConNombre): String;
begin
  result:= clase.ClassName + '_' + DateTimeToStr(now);
end;

function TListaDeCosasConNombre.listaDeCosasDeClase(clases : TList) : TListaDeCosasConNombre;
var
	i, j : Integer;
	resultado : TListaDeCosasConNombre;
	esDeClase : boolean;
begin
	resultado := TListaDeCosasConNombre.Create('Auxiliar');
	for i := 0 to lst.Count -1 do
  begin
		esDeClase := False;
		for j := 0 to clases.Count - 1 do
    begin
			if TCosa(lst.items[i]).ClassType = TClass(clases[j]) then
      begin
				esDeClase := true;
				break;
      end;
    end;
			if esDeClase then
				resultado.lst.Add(lst.items[i]);
  end;
	result := resultado;
end;

function TListaDeCosasConNombre.find(const nombre: string ): TCosaConNombre;
var
	k: integer;
	res: TCosaConNombre;
begin
  res:= NIL;
	for k:= 0 to lst.count-1 do
	begin
		if TCosaConNombre( lst.items[k] ).nombre = nombre then
		begin
      res:= lst.items[k];
			break;
		end;
	end;
	result:= res;
end;

function TListaDeCosasConNombre.find(const nombre: string; var ipos: integer ): boolean;
var
	k: integer;
	buscando: boolean;
begin
  buscando := true;
	for k:= 0 to lst.count-1 do
	begin
		if TCosaConNombre( lst.items[k] ).nombre= nombre then
		begin
			buscando:= false;
			ipos := k;
			break;
		end;
	end;
	result:= not buscando;
end;

function TListaDeCosasConNombre.find(const clase, nombre: string; var ipos: integer ): boolean;
var
	k: integer;
	buscando: boolean;
	cosa: TCosaConNombre;
begin
buscando := true;
	for k:= 0 to lst.count-1 do
	begin
		cosa:= lst.items[k];
		if (cosa.ClassName= clase ) and (cosa.nombre= nombre) then
		begin
			buscando:= false;
			ipos := k;
			break;
		end;
	end;
	result:= not buscando;
end;

function TListaDeCosasConNombre.Add(cosa : TCosaConNombre) : Integer;
var
  ipos: Integer;
  cntrep: integer;
  xnombre: string;
begin
  cntrep:= 0;
  xnombre:= cosa.nombre;
  while find( xnombre, ipos) do
  begin
    inc( cntrep );
    xnombre:= cosa.nombre +'$'+ IntToStr( cntrep );
  end;

  if ( cntrep > 0 ) then
  begin
    (*
    showmessage( 'Atención tuve que renombrar la '
      + cosa.ClaseNombre + ' del nombre: ' + cosa.nombre+ ' a : '
      + xnombre );
      *)
    cosa.nombre:= xnombre;
  end;
 	result:= lst.Add(cosa);
end;

procedure TListaDeCosasConNombre.insert(indice: Integer; cosa : TCosaConNombre);
var
  ipos: Integer;
begin
  if not find(cosa.nombre, ipos) then
  begin
    lst.insert(indice, cosa);
  end
  else
    raise Exception.Create('La lista ' + self.nombre + ' ya tiene un elemento de nombre ' + cosa.nombre);
end;

function TListaDeCosasConNombre.Remove(cosa : TCosaConNombre): Integer;
begin
  result:= lst.Remove(cosa);
end;

function TListaDeCosasConNombre.nombresCosas: TStringList;
var
  res: TStringList;
  i: Integer;
begin
  res:= TStringList.Create;
  res.Capacity:= lst.Count;
  for i:= 0 to lst.Count - 1 do
    res.Add(TCosaConNombre(lst.items[i]).nombre);
  result:= res;
end;


{procedure TListaDeCosasConNombre.CambioFichaPD;
begin
	raise Exception.Create('Metodo abstracto cambioFichaPD en ' + self.ClassName);
end;}

//-------------------------------------
//Metodos de TListaDeCosasReferenciadas
//=====================================

Constructor TListaDeReferenciasACosas.Create;
begin
  inherited Create;
	setlength( lst, 0 );
end;

constructor TListaDeReferenciasACosas.Create_ReadFromText(f : TArchiTexto);
var
	n, k : Integer;

begin
	inherited Create_ReadFromText(f);
	f.rd( 'n', n );
	setlength( lst, n );
	for k:= 0 to n-1 do
  begin
		f.rdReferencia(':', TCosa(lst[k]), Self);
    lst[k]:= NIL;
  end;
end;

procedure TListaDeReferenciasACosas.WriteToText( f: TArchiTexto );
var
	n, k: integer;
	cosa: TCosaConNombre;
begin
	inherited WriteToText( f );
	n:= length(lst);
	f.wr('n', n );
	for k:= 0 to n-1 do
	begin
		cosa:= lst[k];
		f.wrReferencia(':', cosa);
	end;
end;

function TListaDeReferenciasACosas.Addx(cosa : TCosaConNombre) : Integer;
var
	tmplst, z: TDAOfPtr;
	k: integer;
begin
	z:= lst;
	setlength( tmplst, length( lst )+1 );
	for k:= 0 to high( lst ) do
		tmplst[k]:= lst[k];
	tmplst[high(tmplst)]:= cosa;
	lst:= tmplst;
	setlength( z , 0 );
	result:= high( tmplst );
end;

function TListaDeReferenciasACosas.find(const nombre: string; var ipos: integer ): boolean;
var
	k: integer;
	buscando: boolean;
begin
buscando := true;
	for k:= 0 to high(lst) do
	begin
		if TCosaConNombre( lst[k] ).nombre= nombre then
		begin
			buscando:= false;
			ipos := k;
			break;
		end;
	end;
	result:= not buscando;
end;

function TListaDeReferenciasACosas.find(const clase, nombre: string; var ipos: integer ): boolean;
var
	k: integer;
	buscando: boolean;
	cosa: TCosaConNombre;
begin
	buscando := true;
	for k:= 0 to high(lst) do
	begin
		cosa:= lst[k];
		if (cosa.ClassName= clase ) and (cosa.nombre= nombre) then
		begin
			buscando:= false;
			ipos := k;
			break;
		end;
	end;
	result:= not buscando;
end;

//----------------------------
// métodos de TFichaReferencia
//============================

constructor TFichaReferencia.Create(referente : TCosa; referencia: PCosaConNombre; referido_clase, referido_nombre: string );
begin
	inherited Create;
	Self.referente := referente;
	Self.referencia:= referencia;
	Self.referido_clase:= referido_clase;
	Self.referido_nombre:= referido_nombre;
end;

procedure TFichaReferencia.Free;
begin
	inherited Free;
end;

procedure registrar_referencia(referente : TCosa; claseDelreferido, nombreDelReferido: string; var referencia );
var
	fr: TFichaReferencia;
begin
	if claseDelReferido <> '?' then
  begin
  	fr:= TFichaReferencia.Create(referente, @referencia, claseDelReferido, nombreDelReferido );
	  referencias.Add( fr );
  end;
end;

procedure DumpReferencias( archi: string );
var
	f: textFile;
	k: integer;
	ref: TFichaReferencia;
begin
	assignfile( f, archi );
	rewrite( f );
	for k:= 0 to referencias.count -1 do
	begin
		ref:= referencias.items[k];
		if ref.referente is TCosaConNombre then
			writeln(f, TCosaConNombre(ref.referente).claseNombre+'-> <'+ref.referido_clase+'.'+ref.referido_nombre+'>')
		else
			writeln(f,  '?:-> <'+ref.referido_clase+'.'+ref.referido_nombre+'>');
	end;
	closefile( f );
end;

function existeReferencia_al(referido: TCosaConNombre): boolean;
var
  i: Integer;
  ref: TFichaReferencia;
  res: boolean;
begin
  res:= false;
  for i:= 0 to referencias.Count - 1 do
  begin
    ref:= referencias[i];
    if (ref.referido_nombre = referido.nombre) and
       (ref.referido_clase = referido.ClassName) then
    begin
      res:= true;
      break;
    end;
  end;
  result:= res;
end;

function existeReferencia_del(referente: TCosa; referido: TCosaConNombre): boolean;
var
  i: Integer;
  ref: TFichaReferencia;
  res: boolean;
begin
  res:= false;
  for i:= 0 to referencias.Count - 1 do
  begin
    ref:= referencias[i];
    if (ref.referente = referente) and
       (ref.referido_nombre = referido.nombre) and
       (ref.referido_clase = referido.ClassName) then
    begin
      res:= true;
      break;
    end;
  end;
  result:= res;
end;

// resuelve las referencias contra la lista de actores y retorna la
// cantidad de referencias que quedan sin resolver (por si es necesario pasar otra lista)
function resolver_referencias( CosasLST: TListaDeCosasConNombre ): integer;
var
	k: integer;
	ipos: integer;
	ref: TFichaReferencia;
begin
	k:= 0;
	while k < referencias.count do
	begin
		ref:= referencias.items[k];
		if CosasLst.find( ref.referido_clase, ref.referido_nombre, ipos ) then
		begin
			ref.referencia^:= CosasLst.lst.items[ipos];
			ref.Free;
			referencias.Delete( k );
		end
		else
			 inc( k );
	end;
	result:= referencias.count;
end;

procedure WriteLNReferencias;
var
   k: integer;
   ref: TFichaReferencia;
begin
   for k:= 0 to referencias.Count-1 do
   begin
      ref:= referencias.items[k];
      system.writeln( '<', ref.referido_clase,'.', ref.referido_nombre,'>' );
   end;
end;

function resolver_referenciasDeCosa( referente : TCosa ; CosasLst : TListaDeCosasConNombre ) : integer;
var
	k, refsSinResolverDeReferente: integer;
	ipos: integer;
	ref: TFichaReferencia;
begin
	k:= 0;
  refsSinResolverDeReferente:= 0;
	while k < referencias.Count  do
	begin
		ref := referencias.items[k];
		if ref.referente = referente then
		begin
			if CosasLst.find( ref.referido_clase, ref.referido_nombre, ipos ) then
			begin
				ref.referencia^:= CosasLst.lst.items[ipos];
				ref.Free;
				referencias.delete(k);
			end
			else
      begin
				inc( k );
        Inc(refsSinResolverDeReferente);
      end;
		end
    else
      inc(k);
	end;
	result := refsSinResolverDeReferente;
end;

function cambiar_referencias_al( ref_Anterior, ref_Nueva : TCosaConNombre) : Integer;
var
	i, resultado : Integer;
	ref : TFichaReferencia;
begin
	resultado := 0;
	for i := 0 to referencias.Count - 1 do
  begin
		ref := referencias[i];
		if (ref_Anterior.nombre = ref.referido_nombre) and
       (ref_Anterior.ClassName = ref.referido_clase) then
    begin
			ref.referido_nombre := ref_Nueva.nombre;
			ref.referido_clase := ref_Nueva.ClassName;
//			ref.referencia^ := ref_Nueva;
			resultado := resultado + 1;
		end;
	end;
	result := resultado;
end;

function cambiar_referencias_del_al(referente: TCosa; ref_Anterior, ref_Nueva : TCosaConNombre) : Integer;
var
	i, resultado : Integer;
	ref : TFichaReferencia;
begin
	resultado := 0;
	for i := 0 to referencias.Count - 1 do
  begin
		ref := referencias[i];
		if (ref.referente = referente) and   
       (ref_Anterior.nombre = ref.referido_nombre) and
       (ref_Anterior.ClassName = ref.referido_clase) then
    begin
			ref.referido_nombre := ref_Nueva.nombre;
			ref.referido_clase := ref_Nueva.ClassName;
//			ref.referencia^ := ref_Nueva;
			resultado := resultado + 1;
		end;
	end;
	result := resultado;
end;

function cambiar_NombreDelReferidoEnReferenciasPosterioresAK(k: Integer ; nombre_Anterior, nombre_Nuevo, claseReferido : String) : Integer;
var
	i, resultado : Integer;
	ref : TFichaReferencia;
begin
	resultado := 0;
	for i:= k to referencias.Count - 1 do
		begin
		ref := referencias[i];
		if (nombre_Anterior = ref.referido_nombre) and (claseReferido = ref.referido_clase) then
			begin
			ref.referido_nombre := nombre_Nuevo;
			resultado := resultado + 1;
			end;
		end;
	result := resultado;
end;

function eliminar_referencias_del(referente : TCosa) : Integer;
var
	i, resultado : Integer;
begin
	resultado := 0;
  if referencias <> NIL then
  begin
  	for i := 0 to referencias.Count - 1 do
	  	if referente = TFichaReferencia(referencias[i]).referente then
		  begin
			  resultado := resultado + 1;
  			TFichaReferencia(referencias[i]).free;
	  		referencias[i] := NIL;
		  end;
  	if resultado > 0 then
	  begin
		  referencias.Pack;
  		referencias.Capacity := referencias.Count;
	  end;
  end;
	result := resultado
end;

function referenciasSinResolver : Integer;
begin
  result:= referencias.Count;
end;

procedure LimpiarReferencias;
var
	k: integer;
begin
	for k:= 0 to referencias.Count-1 do
		TFichaReferencia(referencias.items[k]).Free;
	referencias.Clear;
end;

function ordenString(Item1, Item2: Pointer): Integer;
begin
	if TCosaConNombre(Item1).nombre < TCosaConNombre(Item2).nombre then
		result := -1
	else if TCosaConNombre(Item1).nombre = TCosaConNombre(Item2).nombre then
		result := 0
	else
		result := 1
end;

function ParseNombre(const claseNombre : String) : String;
var
  posSeparador : Integer;
begin
  posSeparador := pos(',', claseNombre);
  result := copy(claseNombre, posSeparador + 2, MAXINT);
end;

function ParseClase(const claseNombre : String) : String;
var
  posSeparador : Integer;
begin
  posSeparador := pos(',', claseNombre);
  result := copy(claseNombre, 0, posSeparador -1);
end;

procedure AlInicio;
begin
	referencias:= TList.Create;
	ucosa.registrarClaseDeCosa( TListaDeCosasConNombre.ClassName, TListaDeCosasConNombre );
	ucosa.registrarClaseDeCosa( TListaDeReferenciasACosas.ClassName, TListaDeReferenciasACosas );
end;

procedure AlFinal;
begin
	 LimpiarReferencias;
end;

end.
