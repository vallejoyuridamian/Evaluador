unit auxbuscar;
interface
uses
  sysutils, classes, funcsauxs;


function normalizarPalabra( palabra: string ): string;
function construirFiltroBusquedaTexto( strbuscar: string; campos: TStrings ): string;


implementation



function normalizarPalabra( palabra: string ): string;
var
  strbx: string;
begin
  strbx:= strtr( palabra, 'Ò‚ÍÓÙ˚‡ËÏÚ˘‰ÎÔˆ¸·ÈÌÛ˙¡…Õ”⁄+"''', '—aeiouaeiouaeiouaeiouAEIOU   ' );
  strbx:= str_replace('A', '[¡A]', strbx);
  strbx:= str_replace('E', '[…E]', strbx);
  strbx:= str_replace('I', '[ÕI]', strbx);
  strbx:= str_replace('O', '[”O]', strbx);
  strbx:= str_replace('U', '[⁄U]', strbx);
  strbx:= str_replace('a', '[·a]', strbx);
  strbx:= str_replace('e', '[Èe]', strbx);
  strbx:= str_replace('i', '[Ìi]', strbx);
  strbx:= str_replace('o', '[Ûo]', strbx);
  strbx:= str_replace('u', '[˙u]', strbx);
  strbx:= str_replace('—', '[nNÒ—]', strbx);
  strbx:= str_replace(' ', '', strbx);
  strbx:= UpperCase(strbx);
  result:= strbx;
end;



function construirFiltroBusquedaTexto( strbuscar: string; campos: TStrings ): string;

var
  nc: integer;
  strbx: string;
  strb: string;
  pals: TStrings;
  npals: integer;
  ipal: integer;
  pal: string;
  filtrobuscar: string;
  pongaAND, pongaOR: boolean;
  uc: string;
  ic: integer;
begin

	nc:= campos.count;

	strbuscar:= stripslashes(trim(strbuscar));
	if ( (nc=0 ) or (strbuscar= '') ) then
  begin
    result:= '';
		exit;
  end;

	strbx:= strbuscar;
	strbuscar:= str_replace('"', '', strbuscar);
	strbx:= strtr(strbx, ',.*+''', '     ' );
	strb:= trim( strbx );
	pals:= explode(' ', strb);
	npals:= pals.count;

	// manejo de las palabras de b˙squeda.
	ipal:= 0;
	while (ipal < npals) do
  begin
		pal:= pals[ipal];

		if (length( pal ) < 3 ) then
    begin
			dec( npals );
      pals.delete( ipal );
		end
    else
    begin
			pal:= normalizarPalabra(pal);
			uc:=pal[length(pal)];
			// elimino el punto al final
			if (uc='.' ) then
      begin
				delete( pal, length( pal), 1 );
  			uc:=pal[length(pal)];
			end;
			// quito plurales
			if ( uc='S' ) then
      begin
				delete( pal, length( pal), 1 );
      				if ( length(pal) > 4) then
              begin
        				uc:=substr(pal, length(pal)-4, 4);
        				if (uc='[ÈE]') then
	    					  pal:= substr(pal, 0, length(pal)-4 );
      				end;
			end;

			if ( 	(length( pal ) < 3 )or
					(pal= 'D[ÈE]')or
      					(pal= 'L[·A]')or
      					(pal= '[ÈE]L')or
      					(pal= '[˙U]N')or
		      			(pal= 'L[ÛO]')or
      					(pal= 'L[ÛO]S')or
      					(pal= 'Y')) then
      begin // las que elimino
    	  dec( npals );
				pals.delete( ipal );
			end
      else
      begin // las que no elimino
	  		pals[ipal]:= pal;
	  		inc( ipal );
  		end;
		end;
	end;


	//---------------------
	// armado del filtro
	//--------------
	filtroBuscar:= '';
	if ( npals > 0) then
  begin
  		pongaAND:= false;
  		for ipal:=0 to npals-1 do
      begin
			  pal:= pals[ipal];
      	if (length(pal) > 1 ) then
        begin
				  if ( pongaAND ) then
					  filtroBuscar:= filtroBuscar +' AND'
				  else
					  pongaAND:= true;
				  filtroBuscar:= filtroBuscar+' (';
				  pongaOR:= false;
				  for ic:= 0 to nc -1 do
          begin
					  if ( pongaOR ) then
						  filtroBuscar:= filtroBuscar+' OR '
					  else
						  pongaOR:= true;

            // ojo la palabra (REGEXP) es para mysql, para Postgress hay que poner (~*) otra cosa.
					  filtroBuscar:=filtroBuscar+'('+campos[ic]+'  REGEXP ''.*'+pal+'.*'')';
          end;

				  filtroBuscar:= filtroBuscar+') ';
        end;
  		end;
	end;

	result:= filtroBuscar;
end;

end.
