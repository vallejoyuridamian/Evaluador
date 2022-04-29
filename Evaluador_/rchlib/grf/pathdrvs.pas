{+doc
+NOMBRE:PathDrvs
+CREACION:1.1.90
+AUTORES:rch
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO: Administracion de la ubicacion de archivos (*.bgi)(*.eft)(*.sft)
+PROYECTO:rchlib

+REVISION:
+AUTOR:
+DESCRIPCION:
-doc}

  unit PathDrvs;
  {5/11/91,rch
	En esta unidad mantenemos la direccion del driver BGI y de los fuentes
	de caracteres.}

  interface
  const
	PathToBGI:string[72] = '';
	PathToFonts:string[72] ='';

  implementation
  procedure init;
  var
     f:text;
  begin
       assign(f,'c:\rch\lib\pathDrvs.cfg');
       {$I-}
       reset(f);
       {$I+}
       if IOResult = 0 then
       begin
            readln(f,PathToBGI);
            readln(f,PathToFonts);
            close(f)
       end;
  end;
  begin
       init;
  end.
