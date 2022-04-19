{+doc
+NOMBRE:  Ancestor.
+CREACION:  8.12.1990.
+AUTOR: Ruben Chaer.
+REVISION:
+AUTOR:
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO:   Definici¢n del padre de todos los objetos.
+PROYECTO:	General.
+DESCRIPCION:
	Objetos Definidos:
	''''''''''''''''''
		-(Base). Es el que usaremos como padre de todos los objetos.
-doc}
{$D-,L-}
unit Ancestor;
interface
uses Archivos;
type

	Base = object
		constructor load(var f:archivo);
		constructor Init;
		procedure Save(var f:archivo);virtual;
		procedure Show;virtual;
		procedure Hide;virtual;
		procedure Edit;virtual;
		Destructor Done; virtual;
	end;

	BasePtr = ^Base;


procedure abstract;

implementation

constructor Base.Init;
begin
	{Debe estar pues ser  llamado por sus desendientes}
end;

procedure abstract;
begin
	RunError(211);
end;


procedure Base.Save(var f:archivo);
begin
	abstract;
end;

destructor Base.Done;
begin

end;

constructor Base.Load(var f: archivo);
begin
	abstract;
end;
procedure base.show;
begin
	abstract;
end;
procedure base.hide;
begin
	abstract;
end;

procedure base.Edit;
begin
	abstract;
end;


end.