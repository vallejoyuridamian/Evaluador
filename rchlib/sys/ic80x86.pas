{+doc
+NOMBRE:ic80x86
+CREACION:1.1.90
+AUTORES:rch
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO:Definicion de algunas instrucciones del mp-8086 como INLINES
+PROYECTO:rchlib

+REVISION:
+AUTOR:
+DESCRIPCION:
-doc}

unit IC80x86;
interface
procedure CLI; inline($FA);
procedure STI; inline($FB);
implementation
end.
