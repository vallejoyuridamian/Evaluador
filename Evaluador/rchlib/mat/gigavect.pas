{+doc
+NOMBRE: gigavext
+CREACION: 1.1.90
+AUTORES:rch
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO: encabezamiento estandar
+PROYECTO: rchlib

+REVISION:
+AUTOR:
+DESCRIPCION:
-doc}

unit gigavect;
{
PROPOSITO: Probar la posibilidad de manejar vectores de m s de 64k
	de memoria.
}

interface
uses
	xMatDefs;

type

	VectorGigante = object
		n:LongInt; { Cantidad de elementos del vector }

		constructor Init(tamElementos:word);
		procedure Assign(NombreArchivo:string);
		procedure Reset;
		procedure Rewrite;
		procedure Close;
		procedure AbrirCrear;
		procedure Agregar(var x);
		procedure GetElemento(var x; indice: LongInt);
		procedure PutElemento(var x; indice: LongInt);

	private
		f:file;
		tam:word; { Tama¤o en bytes de los objetos }
		procedure Seek( indice: LongInt);

	end;

implementation

constructor VectorGigante.Init(tamElementos:word);
begin
	tam:=tamElementos;
	n:=0;
end;

procedure VectorGigante.Assign(NombreArchivo:string);
begin
	system.assign(f,NombreArchivo)
end;

procedure VectorGigante.Reset;
begin
	system.reset(f,tam);
	n:= FileSize(f);
end;

procedure VectorGigante.Rewrite;
begin
	system.Rewrite(f,tam);
	n:=0;
end;

procedure VectorGigante.AbrirCrear;
begin
	{$I-}
	system.reset(f,tam);
	{$I+}
	if IOResult <> 0 then Rewrite
	else n:=FileSize(f);
end;

procedure VectorGigante.Seek( indice: LongInt);
begin
	{$IFOPT R+}
	if (indice<1)or(indice>n)then RunError(201);
	{$ENDIF}
	system.Seek(f,indice-1);
end;


procedure VectorGigante.GetElemento(var x; indice: LongInt);
begin
	Seek(indice);
	BlockRead(f,x,1);
end;


procedure VectorGigante.PutElemento(var x; indice: LongInt);
begin
	Seek(indice);
	BlockWrite(f,x,1);
end;

procedure VectorGigante.Agregar(var x);
begin
	system.Seek(f,n);
	BlockWrite(f,x,1);
	inc(n)
end;

procedure VectorGigante.Close;
begin
	system.Close(f)
end;

end.

