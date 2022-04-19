unit funcsauxs;
interface

uses
  math, strutils, classes, sysutils, fphttpserver, HTTPDefs;

const
  Escapeables: Set Of Char = ['''', '"', '\', #0 ];

type
  TImageSize = array[0..1] of integer;


// concatena LetraPad a s hasta que el resultado tenga la logitud cnt.
// Si Izquierda = true concatena agregando LetraPad por la izquierda sino lo hace por la derecha
function pad( s: string; cnt: integer; LetraPad: char = '0'; Izquierda: boolean = true ): string;


// retorna true si el caracter $c está en la lista de separadores.
function in_separadores( c: char; seps: string = ' '#13#10#9',;:'): boolean;

// elimina los separadores del inicio y fin del string
function trim_seps(s: string; seps: string = ' '#13#10#9',;:'): string;


// busca el primer serparador, a partir de la posición $i incluída
// haciendo incrementos $inc en la búsqueda.
// Dada una posición $i, si $inc = 1 se busca hacia adelante en el string
// si $inc = -1 se busca hacia atrás.
function sep_pos(s: string; i: integer = 1; inc: integer = 1; seps: string = ' '#13#10#9',;:'): integer;

// convierte caracteres. (emula función de PHP)
function strtr( cadena, letras_from, letras_to: string ): string;

// parte la "cadena" en tramos delimitados por "separador"
function explode(separador,  cadena: string ): TStrings;

// emula función de PHP
function addslashes( cadena: string ): string;
function stripslashes( cadena: string ): string;
// emula función de PHP strpos. Retorna los resultados en base 1
// como el pos de Pascal.
// Retorna la posición de inicio de aguja en Pajar a partir de iFrom
// si la encuentra y -1 (menos uno) si no la encuentra.
// iFrom y el resultado es base 0 (como en PHP)
function strpos(pajar, aguja: string; iFrom: integer = 0): integer;

// emula función sbstr de PHP. iFrom es base 0 (como en PHP)
function substr(cadena: string; iFrom: integer; nLetras: integer = 10000): string;

function str_replace(  Buscada, Sustituta, cadena: string ): string;
function nl2br( cadena: string): string;

procedure echo( xsal: TFPHTTPConnectionResponse; texto: string );

function move_uploaded_file( uplf: TUploadedFile; destino: string ): boolean;
function unlink( archi: string ): boolean;
function copyfile( origen, destino: string ): boolean;


function GetImageSize(dest: string): TImageSize;



// busca en $buff lo siguiente que parezca un email e intenta
// leer algo que tenga el formato Nombre <email@sitio.com>
// y lo elimina del $buff.
// busca el próximo @ y aisla el email.
// lo que aparezca antes del email lo considera el Nombre asociado al email
// Las comas, puntos y comas, dos puntos, tabuladores y saltos de líneas son considerados separadores
// para aislar el email.
// Las comas, puntos y compas, dos puntos, tabuladores y saltos de líneas son pasados a espacios en el nombre
// Retorna TRUE si encontró un email y FALSE si no
function get_next_nombre_email( var nombre, email, buff: string ): boolean;

function filtrar_raros(s: string): string;

// genera un número de nd dígitos del 1 al 9 (se excluye el CERO como dígito)
function rnd_digitos(nd: integer): string;


// IntranetControl Insert Fields Names
function ic_IFN: string;

// IntranetControl Insert Fields Values
function ic_IFV( nidneg: string= '0'; nidpos: string = '0'): string;

// Identificador de Usuario de la Intranet
function ic_usr: string;




implementation



function str_replace(  Buscada, Sustituta, cadena: string ): string;
begin
  result:= StringReplace( cadena, Buscada, Sustituta, [rfReplaceALL] );
end;


function nl2br( cadena: string): string;
var
  res: string;
begin
  res:= str_replace( #13#10, #10, cadena );
  res:= str_replace( #10, '<br>', cadena );
  result:= cadena;
end;

procedure echo( xsal: TFPHTTPConnectionResponse; texto: string );
begin
  xsal.Contents.Add( texto );
end;

function move_uploaded_file( uplf: TUploadedFile; destino: string ): boolean;
var
  farchi: TFileStream;
begin
  try
    farchi := TFileStream.Create( destino, fmCreate);
    farchi.CopyFrom(uplf.Stream, uplf.Size);
    farchi.Free;
    result:=  true;
  except
    result:= false;
  end;
end;


function copyfile( origen, destino: string ): boolean;
var
  forg, fdest: TFileStream;
begin
  if not fileExists( origen ) then
  begin
     result:= false;
     exit;
  end;

  if fileExists( destino ) then
    if not  unlink( destino ) then
    begin
       result:= false;
       exit;
    end;

  result:= false;
  try
    forg:= TFileStream.Create( origen, fmOpenRead);
    try
      fdest:= TFileStream.Create( destino, fmCreate );
      try
        fdest.CopyFrom( forg, forg.Size );
        result:= true;
      finally
        fdest.Free;
        forg.Free;
      end;
    except
      forg.Free;
      result:= false;
    end;
  except
    result:= false;
  end;
end;

function unlink( archi: string ): boolean;
begin
  result:= deletefile( archi );
end;


function GetImageSize(dest: string): TImageSize;
begin
(****PENDIENTE ***)
end;

function strpos(pajar, aguja: string; iFrom: integer = 0): integer;
var
  k, i: integer;
  N_Pajar, N_Aguja: integer;
begin
  N_Pajar := length(pajar);
  N_Aguja := length(aguja);
  k := N_Aguja;
  i := iFrom;

  while (k > 0) and (i < length(Pajar)) do
  begin
    if Pajar[i + 1] = Aguja[N_Aguja - k + 1] then
      Dec(k)
    else
      k := N_Aguja;
    Inc(i);
  end;

  if k = 0 then
    Result := (i - N_Aguja)
  else
    Result := -1;
end;


function substr(cadena: string; iFrom: integer; nLetras: integer = 10000): string;
var
  i1: integer;
  n: integer;
begin
  if iFrom >= 0 then
    i1 := iFrom
  else
    i1 := length(cadena) - 1 + iFrom;

  if nLetras > (length(cadena) - i1) then
    n := (length(cadena) - i1)
  else if nLetras < 0 then
    n := max(0, (length(cadena) - i1) + nletras)
  else
    n := nLetras;

  Result := copy(cadena, i1 + 1, n);
end;




function pad( s: string; cnt: integer; LetraPad: char = '0'; Izquierda: boolean = true ): string;
var
  res: string;
begin
  res:= s;
  if Izquierda then
    while length( res ) < cnt do
      res:= LetraPad + res
  else
    while length( res ) < cnt do
      res:= res + LetraPad;
  result:= res;
end;

// retorna true si el caracter $c está en la lista de separadores.
function in_separadores( c: char; seps: string = ' '#13#10#9',;:'): boolean;
begin
   result:= pos( c, seps ) > 0;
end;

// elimina los separadores del inicio y fin del string
function trim_seps(s: string; seps: string = ' '#13#10#9',;:'): string;
var
  res: string;
  k_ini, k_fin: integer;
  buscando: boolean;
begin
  res:= '';

  k_ini := 1;
  k_fin:= length( s );
  buscando:= true;
  while buscando and ( k_ini <= k_fin ) do
    if pos( s[k_ini], seps ) > 0 then
      inc( k_ini )
    else
      while buscando and ( k_fin >= k_ini ) do
        if pos( s[k_fin], seps ) > 0 then
          dec( k_fin )
        else
          buscando:= false;

  if buscando then
    result:= ''
  else
    result:= copy( s, k_ini, k_fin-k_ini+1 );
end;


function strtr( cadena, letras_from, letras_to: string ): string;
var
  k, j: integer;
  res: string;
  N: integer;
begin
  res:= cadena;
  N:= length( letras_to );
  for k:= 1 to length( res ) do
  begin
     j:= pos( res[k], letras_from );
     if (j > 0 ) and ( j <= N ) then res[k]:= letras_to[j];
  end;
  result:= res;
end;


// parte la "cadena" en tramos delimitados por "separador"
function explode(separador,  cadena: string ): TStrings;
var
  res: TStringList;
  pal: string;
  s: string;
  i: integer;
begin
  res:= TStringList.Create;
  s:= cadena;
  i:= pos( separador, s );
  while i > 0 do
  begin
     pal:= copy( s, 1, i -1 );
     delete( s, 1, i+length( separador ) -1 );
     res.add( trim(pal) );
     i:= pos( separador, s );
  end;
  if s <> '' then
     res.add( trim(s) );
  result:= res;
end;

// emula función de PHP
function addslashes( cadena: string ): string;
var
  res: string;
  k, j: integer;
  c: char;
begin
  setlength( res, 2 * length( cadena ) );
  j:= 1;
  for k:= 1 to length( cadena ) do
  begin
     c:= cadena[k];
     if c in Escapeables then
     begin
        res[j]:='\';
        inc( j );
     end;
     res[j]:= c;
  end;
  setlength( res, j-1 );
  result:= res;
end;


function stripslashes( cadena: string ): string;
var
  res: string;
  k, j, n: integer;
  c: char;
begin
  setlength( res, length( cadena ) );
  j:= 1;
  k:= 1;
  n:= length( cadena );
  while k <= n do
  begin
     c:= cadena[k];
     if (c = '\') and (k < n ) then
     begin
        inc( k );
        c:= cadena[k];
     end;
     res[j]:= c;
     inc( k ); inc( j );
  end;
  setlength( res, j-1 );
  result:= res;
end;


// busca el primer serparador, a partir de la posición $i incluída
// haciendo incrementos $inc en la búsqueda.
// Dada una posición $i, si $inc = 1 se busca hacia adelante en el string
// si $inc = -1 se busca hacia atrás.
function sep_pos(s: string; i: integer = 1; inc: integer = 1; seps: string = ' '#13#10#9',;:'): integer;
var
  buscando: boolean;
  n: integer;
  c: char;
begin
   buscando := true;
   n := length(s);
   while (buscando and (i <= n) and ( i > 0)) do
   begin
      c := s[i];
      if(in_separadores(c, seps)) then
         buscando:= false
      else
         i:= i + inc;
   end;
   if buscando then
    result:= 0
   else
    result:= i;
end;

// busca en $buff lo siguiente que parezca un email e intenta
// leer algo que tenga el formato Nombre <email@sitio.com>
// y lo elimina del $buff.
// busca el próximo @ y aisla el email.
// lo que aparezca antes del email lo considera el Nombre asociado al email
// Las comas, puntos y comas, dos puntos, tabuladores y saltos de líneas son considerados separadores
// para aislar el email.
// Las comas, puntos y compas, dos puntos, tabuladores y saltos de líneas son pasados a espacios en el nombre
// Retorna TRUE si encontró un email y FALSE si no
function get_next_nombre_email( var nombre, email, buff: string ): boolean;
var
  i, i_ini, i_fin: integer;
  seps: string;
  s: string;
begin
   i := pos('@', buff);
   if( i = 0) then
   begin
      // no hay un email en el buffer
      nombre := '';
      email := '';
      buff := '';
      result:= false;
      exit;
   end;

   seps := ' '#13#10#9',;:<>';

   i_fin := sep_pos( buff, i, 1, seps);// buscamos el fin del email
   if( i_fin = 0 ) then
   begin
      s:= buff;
      buff:= '';
   end
   else
   begin
      s := copy(buff, 1, i_fin-1);
      buff := copy( buff, i_fin + 1, length( buff ) -(i_fin + 1)+1 );
   end;

   // bueno ... aquí si todo es como pensamos, $i es la posición del @ dentro de $s
   // buscamos el inicio del mail
   i_ini := sep_pos(s, i, - 1, seps);
   if( i_ini = 0 ) then
   begin
      nombre := '';
      email := s;
   end
   else
   begin
      nombre := trim_seps( copy( s, 1, i_ini -1 ));
      nombre:= strtr( nombre, #13#10#9',;:<>', '         ');
      while( pos( '  ', nombre )  > 0) do
        nombre:= ReplaceStr( nombre, '  ', ' ');
      email := copy(s, i_ini + 1, length(s) -(i_ini + 1)+1 );
   end;

   email := lowercase( email);
   result:= true;
end;

function filtrar_raros(s: string): string;
var
  res: string;
  k, j: integer;
  signos: string;
begin
  setlength( res, length( s ) );
  signos := '''"<> .,:_-(){}[]';
  j:= 1;
  for k:= 1 to length( s ) do
     if pos( s[k], signos ) = 0 then
     begin
        res[j]:= s[k];
        inc( j );
     end;
  setlength( res, j-1 );
  result:= res;
end;

function rnd_digitos(nd: integer): string;
var
  k: integer;
  res: string;
begin
  setlength( res, nd );
   for k:= 1 to nd do
      res[k] := chr(Ord( '1' )+ random(9));
  result:= res;
end;


function ic_usr: string;
begin
  (***PENDIENTE ... tenemos que tner un Robot con un GLobs
   global $tablalogin, $usrnid;
   if( ! isset($usrnid))
      $usrnid = 0;

   if(isset($tablalogin) && ($tablelogin == 'sgc_operador'))
   {
      return $usrnid;
   }
   else
   {
      // con los negativos identificamos los competidores.
      return (int)(0 - $usrnid);
   }
***)
  // por ahora
  result:= '0';
end;



// IntranetControl Insert Fields Names
function ic_IFN: string;
begin
   result:= ' ic_dt, ic_usr, ic_nidneg, ic_nidpos ';
end;


// IntranetControl Insert Fields Values
function ic_IFV( nidneg: string= '0'; nidpos: string = '0'): string;
begin
   result:=  ' now(), ' + ic_usr() + ', '+nidneg+', '+nidpos+' ';
end;

end.
