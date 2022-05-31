{+doc
+NOMBRE: x_crear
+CREACION: 1991
+AUTORES: rch
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO: Crear la tabla de administraci¢n del directorio actual,
  los archivos deben agregarse con x_agreg
+PROYECTO: xsys

+REVISION:
+AUTOR:
+DESCRIPCION:
-doc}

{$N+,E+}
program x_crear;

uses
	ArchDB;

begin
	IniciarPX;
	CrearTabla;
	TerminarPX;
end.