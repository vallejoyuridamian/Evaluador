{+doc
+NOMBRE: IDENTS
+CREACION: 4.12.93
+AUTORES: rch
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO:  Definicion del objeto con NOMBRE identificador.  
+PROYECTO: rchlib

+REVISION:
+AUTOR:
+DESCRIPCION:
-doc}

unit IDENTS;
interface
uses
	{$I xObjects}, Horrores;



type

	pstring = ^string;

	POIdent = ^TOIdent;

	TOIdent = object( TObject )
		pNombre: pstring;		
		constructor Load( var s: TStream );
		procedure Store( var s: TStream );
		constructor Init( xNombre: string);
		destructor Done; virtual;
	end;


const
	ROIdent: TStreamRec = (
	 ObjType: 4020;
	 VmtLink: Ofs(TypeOf(TOIdent)^);
	 Load:    @TOIdent.Load;
	 Store:   @TOIdent.Store );

type
	TSortedCollectionOfOIDents = object( TSortedCollection )
		constructor Init(ALimit, ADelta: Integer);
		constructor Load( var S: TStream );
		function Compare(Key1, Key2: Pointer): Integer; virtual;
		function KeyOf( item: pointer ): pointer; virtual;
  end;


const
	RSortedCollectionOfOIDents: TStreamRec = (
	 ObjType: 4021;
	 VmtLink: Ofs(TypeOf(TSortedCollectionOfOIdents)^);
	 Load:    @TSortedCollectionOfOIdents.Load;
	 Store:   @TSortedCollectionOFOIdents.Store );



procedure RegisterIdents;

implementation



procedure RegisterIdents;
begin
	RegisterType(ROIdent);
	RegisterType(RSortedCollectionOfOIDents);
end;


constructor TOIdent.Init( xNombre: string );
var
	tam: byte;
begin
	tam:= length(xNombre)+1;
	If MaxAvail< tam then error('No hay suficiente memoria');
	GetMem(pNombre, tam);
   pNombre^:= xNombre;
end;



destructor TOIdent.done;
begin
	FreeMem(pNombre, Length(pNombre^)+1);
end;

procedure TOIdent.Store( var s: TStream );
begin
	s.write(pNombre^, Length(pNombre^)+1);
end;

constructor TOIdent.Load( var s: TStream );
var
	tam: byte;
begin
	s.read(tam, 1);
	If MaxAvail< tam+1 then error('No hay suficiente memoria');
	GetMem(pNombre, tam+1);
	s.read( pNombre^, tam );
end;







constructor TSortedCollectionOfOIDents.Init(ALimit, ADelta: Integer);
begin
	TSortedCollection.Init(Alimit, ADelta);
  	Duplicates:= false;
end;

constructor TSortedCollectionOfOIDents.Load( var S: TStream );
begin
	TSortedCollection.Load(S);
end;


function TSortedCollectionOfOIDents.Compare(Key1, Key2: Pointer): Integer;
begin
	if pstring(key1)^<pstring(key2)^ then compare:= -1
	else if pstring(key1)^=pstring(key2)^ then compare:= 0
   else compare:= 1;
end;

function TSortedCollectionOfOIDents.KeyOf( item: pointer ): pointer;
begin
	KeyOf:= TOIdent(item^).pNombre;
end;

end.