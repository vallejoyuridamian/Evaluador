unit udsrecedit_auxs;
interface
uses
  sysutils, lib_dbmysql;

const
  DOCUMENT_ROOT= DirectorySeparator+'home'+ DirectorySeparator+'???';
  subcarpetaRaiz = '';
  carpetaRaizFotos = subcarpetaRaiz + '/db-fotos';
  carpetaRaizDocs = subcarpetaRaiz + '/db-docs';




// saca el siguiente lexema de la frase y el separador terminal
// retorna el lexema y en $terminador el separador terminal
function next_lexema(
    var frase: string;
    var terminador: string;
    seps: string = #13#10#9' ;,()[]-:.-+*<>'): string;


procedure remove_directory( DirName: string );

// si el archivo existe intenta eliminarlo
procedure ife_unlink(archi: string);

// vacía y elimina los directorios asociados a un aficha
procedure eliminar_directorios_ficha( tabla, nido: string );
// crea los directorios asociados a una ficha
procedure crear_directorios_ficha( tabla, nido: string );


// en subcarpeta va fotosch , fotosgr, fotosgr_swm o archis
procedure delArchis(tabla, nid, subcarpeta: string );
procedure deletefotos( tabla, nido: string );


function eliminar_rec_db( db: TDB_con; tabla, nido: string;
    nImagenesAManejar: integer; manejarCarpetasPorFicha: boolean ): boolean;


// Agrega un renglón a un texto s:= s + r + CRLF
procedure apr( var s: string; r: string );


function camino_archi(nido: string; karchi: integer; tipo: string): string;
function archi_fotogr_swm( nido: string; kfoto: integer ): string;
function archi_fotogr( nido: string; kfoto: integer; prefijo: string = ''): string;
function archi_fotoch(nido: string; kfoto: integer): string;
function url_fotoch( nido: string; kfoto: integer ): string;

function encuadreImagen( imagen: string; wmax, hmax: integer ): boolean;
procedure MarcaDeAgua(subcarpetaRaiz, archi_o, archi_d: string );

implementation


// Agrega un renglón a un texto s:= s + r + CRLF
procedure apr( var s: string; r: string );
begin
  s:= s + r+ #13#10;
end;

// saca el siguiente lexema de la frase y el separador terminal
// retorna el lexema y en $terminador el separador terminal
function next_lexema(
  var frase: string;
  var terminador: string;
  seps: string = #13#10#9' ;,()[]-:.-+*<>'): string;

var
  k, kSep, jSep: integer;
  buscando: boolean;

begin
   jSep:= 0;
   kSep:= -1;
   for k:= 1 to length( frase ) do
   begin
     jSep:= pos( frase[k], seps );
     if jSep > 0 then
     begin
        kSep:= k;
        break;
     end;
   end;

   if (kSep < 0) then
   begin
      result := frase;
      terminador:= '';
      frase := '';
   end
   else
   begin
      result := copy( frase, 1, kSep-1);
      frase:= copy( frase, kSep+1, length( frase ) - kSep);
      terminador:= seps[ jSep ];
   end;
end;


procedure remove_directory( DirName: string );
var
 Error: Integer;
 FileSearch: TSearchRec;
begin
 Error := FindFirst( DirName+DirectorySeparator+'*', faAnyFile + faDirectory, FileSearch);
 try
  while (Error = 0) do
  begin
   if ( FileSearch.Name <> '.') and (  FileSearch.Name <> '..') then
     if ( FileSearch.attr and faDirectory ) = faDirectory then
        remove_directory( DirName+DirectorySeparator+FileSearch.Name )
     else
        sysutils.DeleteFile( DirName+DirectorySeparator+FileSearch.Name);
   Error := FindNext(FileSearch);
  end;
  finally
    sysutils.FindClose(FileSearch);
  end;

  rmdir( DirName );
end;



function imageresize( imgarchi: integer; newwidth, newheight: integer ): boolean;
begin
(***** PENDIENTE
   $size = GetImageSize($imgarchi);
   $wimg = $size[0];
   $himg = $size[1];
   $tipo = $size[2];
   $e = image_type_to_extension($tipo, false);
   switch($e)
   {
      case 'jpg':
      case 'jpeg':
         $src = imagecreatefromjpeg($imgarchi);
         break;
      case 'png':
         $src = imagecreatefrompng($imgarchi);
         break;
      case 'gif':
         $src = imagecreatefromgif($imgarchi);
         break;
         echo 'El tipo de archivo: ' . $e . ' no es admisible<br>';
         return false;
   }
   $tmp = imagecreatetruecolor($newwidth, $newheight);
   imagecopyresampled($tmp, $src, 0, 0, 0, 0, $newwidth, $newheight, $wimg, $himg);
   imagedestroy($src);
   imagejpeg($tmp, $imgarchi, 100);
   imagedestroy($tmp);
   return true;
   ******)
end;

function encuadreImagen( imagen: string; wmax, hmax: integer ): boolean;
begin
   (******
   $size = GetImageSize($imagen);
   $wimg = $size[0];
   $himg = $size[1];

   if($wimg > $wmax)
   {
      $t_himg = (int)($himg / $wimg * $wmax);
      if($t_himg > $hmax)
      {
         $wimg = (int)($wimg / $himg * $hmax);
         $himg = $hmax;
      }
      else
      {
         $himg = $t_himg;
         $wimg = $wmax;
      }
      result:= imageresize($imagen, $wimg, $himg);
   }
   else
   {
      if($himg > $hmax)
      {
         $wimg = (int)($wimg / $himg * $hmax);
         $himg = $hmax;
         result:= imageresize($imagen, $wimg, $himg);
      }
      else
      {
        result:= true;
      }
   }
   *****)
end;

function imageresizeGIF(imgarchi: string; newwidth, newheight: integer): boolean;
begin
(** PENDIENTE
   $size = GetImageSize($imgarchi);
   $wimg = $size[0];
   $himg = $size[1];

   $src = imagecreatefromgif($imgarchi);
   $tmp = imagecreatetruecolor($newwidth, $newheight);
   $black = imagecolorallocate($tmp, 0, 0, 0);
   imagecopyresampled($tmp, $src, 0, 0, 0, 0, $newwidth, $newheight, $wimg, $himg);
   imagecolortransparent($tmp, $black);
   imagedestroy($src);
   imagegif($tmp, $imgarchi, 100);
   imagedestroy($tmp);
**)
end;


procedure encuadreImagenGIF( imagen: string; wmax, hmax: integer );
begin
(***Pendiente
   $size = GetImageSize($imagen);
   $wimg = $size[0];
   $himg = $size[1];

   if($wimg > $wmax)
   {
      $t_himg = (int)($himg / $wimg * $wmax);
      if($t_himg > $hmax)
      {
         $wimg = (int)($wimg / $himg * $hmax);
         $himg = $hmax;
      }
      else
      {
         $himg = $t_himg;
         $wimg = $wmax;
      }
      imageresizeGIF($imagen, $wimg, $himg);
   }
   else
   {
      if($himg > $hmax)
      {
         $wimg = (int)($wimg / $himg * $hmax);
         $himg = $hmax;
         imageresizeGIF($imagen, $wimg, $himg);
      }
   }

   ***)
end;

function archi_fotogr_swm( nido: string; kfoto: integer ): string;
begin
 (***PENDIENTE
 global $subcarpetaRaiz, $tabla;
   $archi = $nido . '_' . $kfoto . 'fg.jpg';
   $dest = $_SERVER['DOCUMENT_ROOT'] . $subcarpetaRaiz . "/$tabla/fotosgr_swm/$archi";
   return $dest;
   ***)
end;



function archi_fotogr( nido: string; kfoto: integer; prefijo: string = ''): string;
begin
 (***PENDIENTE
 global $subcarpetaRaiz, $tabla;
   $archi = $nido . '_' . $kfoto . $prefijo . 'fg.jpg';
   $dest = $_SERVER['DOCUMENT_ROOT'] . $subcarpetaRaiz . "/$tabla/fotosgr/$archi";
   return $dest;
   ***)
end;


function archi_fotoch(nido: string; kfoto: integer): string;
begin
 (***PENDIENTE
   global $subcarpetaRaiz, $tabla;
   $archi = $nido . '_' . $kfoto . 'fc.jpg';
   $destsmall = $_SERVER['DOCUMENT_ROOT'] . $subcarpetaRaiz . "/$tabla/fotosch/$archi";
   return $destsmall;
   ***)
end;


function url_fotoch( nido: string; kfoto: integer ): string;
begin
 (***PENDIENTE
 global $tabla, $subcarpetaRaiz;
   $archi = $nido . '_' . $kfoto . 'fc.jpg';
   $destsmall = $subcarpetaRaiz . "/$tabla/fotosch/$archi";
   return $destsmall;
   ***)
end;



function url_fotogr( nido: string; kfoto: integer): string;
begin
 (***PENDIENTE
   global $tabla, $subcarpetaRaiz;
   $archi = $nido . '_' . $kfoto . 'fg.jpg';
   $res = $subcarpetaRaiz . "/$tabla/fotosgr/$archi";
   return $res;
   ***)
end;

function camino_archi(nido: string; karchi: integer; tipo: string): string;
begin
 (***PENDIENTE
   global $subcarpetaRaiz, $tabla;
   $archi = $nido . '_' . $karchi . '.' . $tipo;
   return $_SERVER['DOCUMENT_ROOT'] . $subcarpetaRaiz . "/$tabla/archis/$archi";
   ***)
end;


procedure ife_unlink(archi: string);
begin
   if fileexists(archi) then deletefile(archi);
end;



procedure eliminar_directorios_ficha( tabla, nido: string );
begin
   delArchis(tabla, nido, 'archis');
   remove_directory( DOCUMENT_ROOT + carpetaRaizFotos + '/Fotos_' + tabla + '/nid_' + nido);
   remove_directory( DOCUMENT_ROOT + carpetaRaizDocs + '/Docs_' + tabla + '/nid_' + nido);
end;



procedure crear_directorios_ficha( tabla, nido: string );
var
  dir: string;
  dir_comunes: string;
  carpeta: string;

begin
   dir:= DOCUMENT_ROOT+ carpetaRaizFotos;
   if not fileexists(dir) then mkdir(dir);
   dir:= dir +'/Fotos_' +tabla;
   if not fileexists(dir) then mkdir(dir);

   dir_comunes := dir+'/comunes';
   if fileexists( dir_comunes) then  mkdir(dir_comunes);

   carpeta := dir + '/nid_' + nido;
   if not fileexists( carpeta ) then mkdir(carpeta);

   dir := DOCUMENT_ROOT+carpetaRaizDocs;
   if not fileexists(dir) then mkdir(dir);

   dir := dir+'/Docs_' +tabla;
   if not fileexists(dir) then mkdir(dir);

   carpeta := dir + '/nid_' + nido;
   if not fileexists( carpeta ) then mkdir(carpeta);
end;






// en subcarpeta va fotosch , fotosgr, fotosgr_swm o archis
procedure delArchis(tabla, nid, subcarpeta: string );
var
  DirName: string;
  mascara: string;
  Error: Integer;
  FileSearch: TSearchRec;
begin
  DirName:= DOCUMENT_ROOT+subcarpetaRaiz + DirectorySeparator+ tabla + DirectorySeparator +subcarpeta;
  Error := FindFirst( DirName+DirectorySeparator+'*', faArchive, FileSearch);
  mascara := nid + '_';
  try
  while (Error = 0) do
  begin
    if ( FileSearch.Name <> '.')
      and (  FileSearch.Name <> '..')
      and (( FileSearch.attr and faArchive ) = faArchive)
      and (pos( mascara, FileSearch.Name ) > 0 ) then
          DeleteFile( DirName+DirectorySeparator+FileSearch.Name);
    Error := FindNext(FileSearch);
  end;
  finally
    sysutils.FindClose(FileSearch);
  end;
end;


procedure deletefotos( tabla, nido: string );
begin
   delArchis(tabla, nido, 'fotosch');
   delArchis(tabla, nido, 'fotosgr');
   delArchis(tabla, nido, 'fotosgr_swm');
end;



function eliminar_rec_db( db: TDB_con; tabla, nido: string;
    nImagenesAManejar: integer; manejarCarpetasPorFicha: boolean ): boolean;
var
  sql: string;
begin
   if nImagenesAManejar > 0 then
      deletefotos(tabla, nido);

   if manejarCarpetasPorFicha then
      eliminar_directorios_ficha(tabla, nido);

   sql := 'DELETE FROM '+tabla+' WHERE nid= '+nido+' LIMIT 1';
   result:= db.exec(sql) = 1;
end;




// aplica la marca sobre (arci_o) y pone rel resultado en (archi_d).
// supone que los gifs con la marca de agua están en la subcarpeta raíz
// del sitio en cuestión.
procedure MarcaDeAgua(subcarpetaRaiz, archi_o, archi_d: string );
begin
  (***PENDIENTE
{
   $archi_wm = $_SERVER['DOCUMENT_ROOT'] . $subcarpetaRaiz . '/marcadeagua/wm.gif';
   $archi_wmx = $_SERVER['DOCUMENT_ROOT'] . $subcarpetaRaiz . '/marcadeagua/wmx.gif';

   list($w, $h) = getimagesize($archi_o);
   list($w2, $h2) = getimagesize($archi_wm);

   $top = 0;
   $left = 0;

   $escalaw = 1;
   $escalah = 1;
   $escalar = 0;
   if($w > $w2)
   {
      $left = (($w - $w2) / 2);
   }
   else
   {
      $escalar = 1;
      $escalaw = $w2 / $w;
   }
   if($h > $h2)
   {
      $top = (($h - $h2) / 2);
   }
   else
   {
      $escalar = 1;
      $escalah = $h2 / $h;
   }

   if($escalaw < $escalah)
   {
      $escala = $escalaw;
   }
   else
   {
      $escala = $escalah;
   }

   if($escalar == 1)
   {
      // exec("cp $archi_wm $archi_wmx");
      copy($archi_wm, $archi_wmx);
      encuadreImagenGIF($archi_wmx, $w, $h);
      list($w2, $h2) = getimagesize($archi_wmx);
      $left = (($w - $w2) / 2);
      $top = (($h - $h2) / 2);
      $top = (int)($top + 0.5);
      $left = (int)($left + 0.5);
      exec('/usr/bin/convert  ' . $archi_wmx . ' -background transparent -splice ' . $left . 'x' . $top . ' ' . $archi_wmx);
   }
   else
   {
      $top = (int)($top + 0.5);
      $left = (int)($left + 0.5);
      exec('/usr/bin/convert  ' . $archi_wm . ' -background transparent -splice ' . $left . 'x' . $top . ' ' . $archi_wmx);
   }
   exec('/usr/bin/composite -watermark 50x100 ' . $archi_wmx . ' ' . $archi_o . ' ' . $archi_d);
}
***)
end;
end.
