{+doc
+NOMBRE: x_hacer
+CREACION: 1991
+AUTORES: rch
+REGISTRO:
+TIPO: programa Pascal.
+PROPOSITO:    ejecutar los comandos indicados en la base de datos de
	administraci¢n del directorio.
+PROYECTO: xsys

+REVISION:
+AUTOR:
+DESCRIPCION:
-doc}

{$N+,E+}
{$M 16500, 0, 300000}
program xpmirar;

uses
	DOS, CRT, ArchDB, PXEngine;



procedure EjecutarAccion(var Accion,Nombre,extension:string);
var
	Command:string;
begin
	if accion[1]='(' then exit;
	Command:= Accion+' '+Nombre+'.'+Extension;
	Command := '/C ' + Command;
	SwapVectors;
	Exec(GetEnv('COMSPEC'), Command);
	SwapVectors;
	if DosError <> 0 then
		accion:='(E)'+Accion
	else accion:='(*)'+accion;
end;




procedure VerRegistro;
var
	Nombre, Extension, Comentario, Accion:string;
	Blank:boolean;
begin
	GetRegistroActual;
	ReadNombre(Nombre);
	ReadExtension(Extension);
	ReadComentario(Comentario);
	ReadAccion(Accion);
	writeln( Accion+'   '+Nombre+'.'+Extension);
	writeln( Comentario );

	(* See if the field is blank *)
	PxErr := PXFldBlank(ArchRH, AccionFH, Blank);
	if PxErr <> PxSuccess then
	  Writeln(PxErrMsg(PxErr))
	else
		if Blank then
			Writeln('Field is blank')
		else
		begin
			EjecutarAccion(Accion,Nombre,extension);
			WriteAccion(Accion);
			ActualizarRegistro;
		end;
end;



begin
	ClrScr;
	IniciarPX;
	AbrirTabla;
	AbrirBufferDeRegistro;

	AsignarManejadoresDeCampos;
	IrAlPrimerRegistro;

	while PXErr = PXSuccess do
	begin
		VerRegistro;
		IrAlProximoRegistro;
	end;

   CerrarBufferDeRegistro;
	CerrarTabla;
	TerminarPX;
end.