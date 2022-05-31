{+doc
+NOMBRE:  x_agreg
+CREACION: 1991
+AUTORES: rch
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO: Agrega los archivos cuya m scara se pasa como par metro
	a la base de datos (ARCHDB) del directorio actual. LLena el campo
	de comentario con el PROPOSITO de los encabezados.
+PROYECTO: xsys

+REVISION:
+AUTOR:
+DESCRIPCION:
-doc}

{$N+,E+}
program xpDir;

uses
	DOS, ArchDB, lcb;

procedure Agregar( P:PathStr);
var
	Nombre, Extension, Comentario, Accion: string;
	D: DirStr;
	N: NameStr;
	E: ExtStr;
	f:text;

begin
	assign(f,P);
	reset(f);
	FSplit(P,D,N,E);
	Nombre:=N;
	Extension:=E; Delete(Extension,1,1);
	
	WriteNombre(Nombre);
	write(nombre,': ');
	comentario:=lcb.GetProposito(f);
	close(f);
	WriteComentario(comentario);
	WriteExtension(Extension);
{	WriteAccion(Accion); }
	agregarregistro;
end;

procedure HacerDir;
var
  DirInfo: SearchRec;
begin
  FindFirst(ParamStr(1), Archive, DirInfo);
  while DosError = 0 do
  begin
	 agregar(DirInfo.Name);
	 FindNext(DirInfo);
  end;
end;


begin
	IniciarPX;
	AbrirTabla;
	AbrirBufferDeRegistro;
	AsignarManejadoresDeCampos;

	hacerdir;

	TerminarPX;
end.