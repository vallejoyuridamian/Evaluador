{+doc
+NOMBRE:ic8259
+CREACION:1.1.90
+AUTORES:rch
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO:Servicios del manejador de interrupciones ic8259
+PROYECTO:rchlib

+REVISION:
+AUTOR:
+DESCRIPCION:
-doc}

unit  IC8259;
interface

{Enable Interrupt Request: IRQn }
procedure EnIRq(n:integer);

{Disable Interrupt Request: IRQn }
procedure DisIRq(n:integer);

{End Of Interrupt ( not specific) }
procedure EOI;

{Specific End Of Interrupt}
procedure SEOI(n:integer);

{ =================================
PC Mapa de asignaci¢n de interrupciones en el PC.

IRQ 	NInt		Dispositivo

7		0F			Puerto paralelo 1.
6		0E			Controlador de disco.
5		0D			Puerto paralelo 2.
4		0C			Puerto serie 1.
3		0B			Puerto serie 2.
2		0A			Cadena de Interrupciones para el PC AT.
1		09			Controlador de teclado.
0		08			Interrupci¢n del reloj. (canal 0).

==========================================}


implementation

const
	IMR8259 = $21;     {A0 :=1 del 8259}
	ICR8259 = $20;     {A0 :=0 del 8259}

procedure EnIRq(n:integer);
begin { M[n]:=0 }
	Port[IMR8259]:=Port[IMR8259] and not(1 shl n);
end;

procedure DisIRq(n:integer);
begin      { M[n]:=1 }
{pone a uno el bit "n" de la mascara de interrupciones}
{enmascarando la interrupcion "n"}
	Port[IMR8259]:=Port[IMR8259] or (1 shl n);
end;

procedure EOI;
begin  {realiza un End Of Interrupt "no especifico"}
		{es posible usar este modo solo cuando el 8259 esta en}
		{ el modo "fully nested" de prioridades}
	Port[ICR8259]:=$20;
end;

procedure SEOI(n:integer);
{Specific End Of Interrupt}
{Resetea el bit IS (In Service) del nivel n}
begin
	Port[ICR8259]:=$60+n;
end;


end.