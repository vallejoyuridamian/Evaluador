{+doc
+NOMBRE: Archivos.
+CREACION: 8.12.1990.
+AUTOR: Ruben Chaer.
+REVISION:
+AUTOR:
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO: Definir el Objeto (ARCHIVO) para tener una forma transparente
	de almacenar y recuperar listas de objetos polim¢rficas.

+PROYECTO: RCHLib
+DESCRIPCION:
	Definici¢n de Objetos:
	''''''''''''''''''''''
	-(Archivo). Es el que permite guardar y recuperar listas
		polim¢rficas de objetos, los cuales deben ser hijos del
		objeto (base) definido en la unidad ANCESTOR. Todos los
		objetos a ser manejado por una instancia de (Archivo) deben
		registrarse previamente en el mismo y siempre en el mismo
		orden para cualquier uso posterior del archivo de disco creado.

      OBJETO PADRE: Ninguno.

		CONSTRUCTORES:
		1.- constructor assign(ExternalName:string);
			Asigna el nombre (ExternalName) a la instancia de (Archivo)
			que realiza la llamada. (ExternalName) es el nombre del archivo
			de disco al cual se vincula la instancia. Debe contener Nombre
			del archivo (con la ruta de acceso si es necesaria) y la extensi¢n
			deseada.

		DESTRUCTORES: Ninguno.

		METODOS:
		1.- procedure Reset;
			Abre el archivo de disco para lectura-escritura. Las precon-
			diciones son: (Debe existir un archivo con el nombre External
			Name).
		2.- procedure Rewrite;
			Abre el archivo de disco con el nombre External Name usado en
			el constructor. Crea un nuevo archivo borrando alguno anterior
			con el mismo nombre que existiese. En este modo el archivo se
			abre solo para escritura.
		3.- procedure Close;
			Cierra el archivo (abierto con los m‚todos 1 o 2). Es importante
			cerrar los archivos al terminar los trabajos pues es la manera
			de asegurarnos que los datos son efectivamente escritos en el
			archvio de disco y no se quedan por alg£n buffer intermedio.
		4.- procedure Append;
			Abre un archivo existente para escritura-lectura posicionando
			la "cabeza" al final del mismo. Este procedimiento es el que
			se utiliza para agregar objetos a un archivo ya existente.
			El archivo de disco debe existir sino se generar  un error
			de entrada salida.
		5.- procedure OpenToAppend;
			Igual que el anterior, con la diferencia que si el archivo no
			existe en lugar de derivar en un error lo crea.
		6.- procedure Write(var x;y:word);
			Escribe al archivo (y) bytes a partir de la direcci¢n de memoria
			de la variable (x). Este procedimiento ser  normalmente usado
			por el procedimiento (Save)  de los objetos que se
			salvan-a el archivo.
		7.- procedure Read(var x;y:word);
			Lee del archivo (y) bytes y los guarda en la direcci¢n de memoria
			de la variable (x).  Este procedimiento ser  normalmente usado
			por el procedimiento (Load)  de los objetos que se
			cargan-de el archivo.
		8.- function Get:Pointer;
			Saca del archivo el siguiente objeto, lo crea en memoria y
			devuelve un puntero al mismo. Este procedimiento es el
			que se utiliza para cargar uno-a-uno los objetos de un
			archivo de disco sin saber a priori que tipo exacto de objeto
			es el que se est  cargando.
		9.- procedure Put(var x);
			Guarda en el archivo el objeto (x).
		10.- procedure RegisterType(PTipo,PSave,PLoad:pointer);
			Registra un tipo de objeto en el archivo. Es inpresindible
			que todos los tipos de objetos que se piense utilizar en una
			aplicaci¢n determinada se registren en el archivo.
		11.- function EOF:boolean;
			End Of File, retorna TRUE cuando hemos llegado al fin del archivo
			de disco.
-doc}

unit Archivos;
interface

type

	archivo = object
		constructor assign(ExternalName:string);
		procedure Reset;
		procedure Rewrite;
		procedure Close;
		procedure Append;
		procedure OpenToAppend;
		procedure Write(var x;y:word);
		procedure Read(var x;y:word);
		function Get:Pointer;
		procedure Put(var x);
		procedure RegisterType(PTipo,PSave,PLoad:pointer);
		function EOF:boolean;
	private
		f:file;
	end;


implementation
{ Implementaci¢n momentanea de los m‚todos de Archivo }

type
	TipoSaveProcedure=procedure(var f:archivo; SelfPtr:pointer);
	TipoLoadConstructor=procedure(var f:archivo; VmtOfs:word; SelfPtr:pointer);

	Card = record
		Tipo:word;
		SaveProc : TipoSaveProcedure;
		LoadProc : TipoLoadConstructor;
	end;

const
	ContadorDeTipos:integer = 0;

var
	TiposRegistrados:array[1..255] of Card;

procedure Archivo.RegisterType(PTipo,PSave,PLoad:pointer);
begin
	inc(ContadorDeTipos);
	with TiposRegistrados[ContadorDeTipos] do
	begin
		Tipo:=ofs(Ptipo^);
		@SaveProc:=PSave;
		@LoadProc:=PLoad
	end
end;

function SearchTipo(VMTOfs:word):integer;
var
	k:integer;
begin
	k:= 1;
	while
		(k<=ContadorDeTipos) and
		(TiposRegistrados[k].Tipo<>VMTOfs) do inc(k);
	if k>ContadorDeTipos then SearchTipo:=0
	else SearchTipo:=k
end;



function archivo.Get:Pointer;
var
	TipoId:integer;
	t:Pointer;
begin
	Read(TipoId,2);
	GetMem(t,integer(Ptr(Dseg,TiposRegistrados[tipoID].tipo)^));
	TiposRegistrados[tipoID].LoadProc(Self,TiposRegistrados[tipoID].tipo,t);
	get:=t;
end;

procedure archivo.Put(var x);
var
	TipoId:integer;
begin
	TipoId:=SearchTipo(word(x));
	write(TipoId,2);
	TiposRegistrados[TipoId].SaveProc(Self,@x);
end;



constructor Archivo.assign(externalName:string);
begin
	system.assign(f,ExternalName);
end;


procedure archivo.Reset;
begin
	system.reset(f,1);
end;

procedure archivo.Append;
begin
	reset;
	system.seek(f, FileSize(f));
end;

procedure archivo.OpenToAppend;
begin
	{$I-}
	system.reset(f,1);
	{$I+}
	if ioresult <> 0 then
		rewrite
	else
		system.seek(f, FileSize(f));
end;

procedure archivo. Close;
begin
	System.Close(f);
end;

procedure archivo.rewrite;
begin
	system.rewrite(f,1);
end;


procedure Archivo.Write;
begin
	BlockWrite(f,x,y);
end;

procedure Archivo.Read;
begin
	BlockRead(f,x,y);
end;

function Archivo.EOF:boolean;
begin
	EOF:=system.EOF(F)
end;

{--------------------------------}
end.