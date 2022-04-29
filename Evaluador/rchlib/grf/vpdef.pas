{+doc
+NOMBRE:vpdef
+CREACION:1.1.90
+AUTORES:rch
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO:definicion de la clase VectOfPoint.
+PROYECTO:rchlib

+REVISION:
+AUTOR:
+DESCRIPCION:
-doc}

unit VPDef;
interface
uses
	 MatObj, Graph;

	type
		VectOfPoint = object(TVect)
			constructor Init(nx:integer);
		end;

implementation

constructor VectOfPoint.Init(nx:integer);
begin
	TVect.Init(nx,SizeOf(PointType));
end;
end.