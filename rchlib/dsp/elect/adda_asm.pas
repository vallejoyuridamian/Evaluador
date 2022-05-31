{+doc
+NOMBRE: ADDA_asm
+CREACION: 27.8.1992
+AUTORES: RCh
+REGISTRO:
+TIPO: Unidad Pascal
+PROPOSITO: Implementaci¢n de los servicios para el manejo de tarjeta
	adquisidora de 16 canales de entrada anal¢gicos.
+PROYECTO: general

+REVISION:
	5.10.1992, Se mejoro LeeCanal, asignando directamente el resultado,
	en lugar de usar una variable intermedia y se implemento xLeeCanal,
	la cual es una version mejorada de LeeCanal. La mejora consiste en
	que al ser un procedimiento assembler nos ahorramos las siguientes
	instrucciones:

		sub sp,0002 ; creacion del lugar para el parametro Canal
		..
		mov [bp-04],ax ; asignacion del resultado dentro del bloque asm.
		mov ax,[bp-04] ; recuperacion del resultado a la salida del b.asm.

  
+AUTOR:
+DESCRIPCION:
-doc}

unit ADDA_asm;

interface

type
	int12 = 0..$fff;

const
	xport = 656;

procedure ValSal(x:int12);
function LEECanal(Canal:byte):integer;
function xLeeCanal(Canal:byte):integer;



implementation


function xLeeCanal(Canal:byte):integer;assembler;
asm
	mov al, 0
	mov dx, xPort+3
	out dx, al
	mov al, Canal
	mov dx, xPort
	out dx, al

	mov dx, xPort+4

	mov cx, 7
@For_lp1:
	in al,dx
	loop @For_lp1

	inc dx 		{se¤ala con dx a xPort+5 }

	mov cx, 7
@For_lp2:
	in al,dx
	loop @For_lp2

	mov dx, xPort+2
	in al,(dx)	{ B = }
	and al,$0f
	mov ah,al

	dec dx 	{mov dx, xPort+1}
	in al,(dx) 	{ C = }
end;


function LeeCanal(Canal:byte):integer;
{var
	res:integer;
 }
begin
asm
	mov al,0
	mov dx,xPort+3
	out dx,al
	mov al, Canal
	mov dx, xPort
	out dx, al

	mov dx,xPort+4

	mov cx,7
@For_lp1:
	in al,dx
	loop @For_lp1

	inc dx 		{se¤ala con dx a xPort+5 }

	mov cx, 7
@For_lp2:
	in al,dx
	loop @For_lp2

	mov dx, xPort+2
	in al,(dx)	{ B = }
	and al,$0f
	mov ah,al

	dec dx 	{mov dx, xPort+1}
	in al,(dx) 	{ C = }
	{mov [bp + OFFSET ss:res],ax }
  mov [@Result] ,ax
end;
{
	LeeCanal:=res;
  }
end;


procedure ValSal(x:int12);
begin
asm
	mov ax,[bp + OFFSET ss:x]
	mov dx,xPort+6
	out dx,al
	mov al,ah
	inc dx
	out dx,al
end;
end;

end.