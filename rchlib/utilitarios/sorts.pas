unit SORTS;
interface


type
	TKeyFunc= function( p1, p2: pointer): integer;
	TpItemFunc= function ( k: integer ):pointer;


procedure Sort(
	fKey: TKeyFunc; fpItem: TPItemFunc; SizeOfDato: word;
	Desde, Hasta: integer );


implementation

procedure Sort(
	fKey: TKeyFunc; fpItem: TPItemFunc; SizeOfDato: word;
	Desde, Hasta: integer );
var
	k: integer;
	ordenado: integer;
	pmx, po, pj: pointer;
	res: integer;
	ptemp: pointer;
  j: integer;
begin
	GetMem( ptemp, SizeOfDato );
	for ordenado:= Desde to Hasta-1 do
	begin
		pmx:= fpItem(ordenado );
		po:= pmx;
		for j:= ordenado to Hasta do
		begin
    	pj:= fpItem( j );
			res:= fKey( pmx, pj );
			if res > 0 then
				pmx:= pj; 
		end;
		move( pmx^, ptemp^, SizeOfDato );
		move( po^, pmx^,SizeOfDato );
		move( ptemp^, po^, SizeOfDato );

	end;
	FreeMem( ptemp, SizeOfDato );
end;

end.