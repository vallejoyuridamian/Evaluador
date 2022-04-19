{+doc
+NOMBRE: binu
+CREACION: 1.1.90
+AUTORES:rch
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO: funciones (BinToWord) y (WordToBin)
+PROYECTO:rchlib

+REVISION:
+AUTOR:
+DESCRIPCION:
-doc}
{$Q-}
Unit BINU;

interface
	function BinToWord(s: string): word;
	function WordToBin(w: word):string;

implementation

function BinToWord(s: string): word;
var
	w,i,j: word;
begin
	w:=0;
	j:=1;
	for i:= length(s) downto 1 do
	begin
		w:=w+(ord(s[i])-48)*j;
		j:=j*2;
	end;
	BinToWord := w;
end;

function WordToBin(w: word):string;
var
	s: string;
	i,j,k: word;
begin
	k:=1;
	s:='';
	for i:= $0 to $F do
	begin
		if (w and k) > 0 then
			s:='1'+s
		else
			s:='0'+s;
		k:=k*2;
	end;
	WordToBin:= s;
end;

end.