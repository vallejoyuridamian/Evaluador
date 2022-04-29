{+doc
+NOMBRE:listas
+CREACION:1.1.90
+AUTORES:rch
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO:Implementacion del objeto lista y sus servicios
+PROYECTO:rchlib

+REVISION:
+AUTOR:
+DESCRIPCION:
-doc}

{$D-,L-}
unit listas;
interface
uses Ancestor,Archivos;

type


	nodoPtr = ^nodo;
	nodo = object
		anterior:nodoPtr;
		item:BasePtr;
	end;

	lista = object(base)
		NNodos:word;
		ultimo:nodoPtr;
		procedure insertar(var x:Base; var p:nodoPtr);
		procedure append(var x:base);

		{ Desencadena el item, pero no lo mata 5/92}
		function quitar(var p:nodoPtr):BasePtr;

		procedure borrar(var xp:nodoPtr);
		function anterior(p:nodoPtr):nodoPtr;
		function siguiente(p:nodoPtr):nodoPtr;
		function primero:nodoPtr;
		constructor Load(var f:archivo);
		constructor Init;
		procedure Clear;
		destructor Done;virtual;
		procedure Save(var f:archivo);virtual;
		function Ord(p:nodoPtr):word;
		function drO(k:word):nodoPtr;
		function Search(var x:base):NodoPtr;
		procedure Show; virtual;
		procedure Hide; virtual;
	end;


implementation



constructor Lista.Init;
begin
	Clear;
end;

procedure Lista.append(var x:base);
begin
	insertar(x,ultimo);
end;

function Lista.Search(var x:base):NodoPtr;
var
	t:NodoPtr;
begin
	t:=ultimo;
	while (t = nil)or(t^.Item = @x) do t:=anterior(t);
	Search:=t;
end;

function Lista.Ord(p:nodoPtr):word;
var
	t:nodoPtr;
	k:word;
begin
	k:=NNodos;
	if Ultimo = nil then Ord:=0
	else
	begin
		t:=Ultimo;
		while (t<>p)and(t<>Nil) do
		begin
			t:=t^.anterior;
			dec(k)
		end;
		if t = p then Ord:=k
		else ord:=0
	end
end;

function Lista.Dro(k:word):nodoPtr;
var
	t:nodoPtr;
	j:word;
begin
	if k>NNodos then Dro:=nil
	else
		begin
			j:=NNodos;
			t:=ultimo;
			while k<> j do
				begin
					dec(j);
					t:=anterior(t)
				end;
			Dro:=t
		end;
end;



function Lista.Primero:nodoPtr;
var
	t:nodoPtr;
begin
	if ultimo = nil then Primero:=nil {listaVacia}
	else
	begin
		t:=ultimo;
		while t^.anterior<>nil do t:=t^.anterior;
		Primero:=t
	end
end;

function Lista.siguiente(p:nodoPtr):nodoPtr;
var
	t:nodoPtr;
begin
	if (p = nil)or(ultimo=nil) then RunError(211);
	if p = ultimo then siguiente:=Nil
	else
	begin
		t:=ultimo;
		while  t^.anterior <> p do t:=t^.anterior;
		siguiente:=t
	end
end;



function Lista.anterior(p:nodoPtr):nodoPtr;
begin
	anterior :=  p^.anterior
end;


procedure Lista.insertar(var x:Base;var p:nodoPtr);
var
	tp:NodoPtr;
begin
	new(tp);
	tp^.item:=@x;
	tp^.anterior:=p;
	inc(NNodos);
	if p = nil then    {Lo agrega al principio de la lista}
		if ultimo = nil then ultimo:=tp {Lista Vacia}
		else primero^.anterior:=tp
	else
	begin
		if p = ultimo then ultimo:=tp
		else siguiente(p)^.anterior:=tp;
	end;
	p:=tp;
end;


{Ordena la destrucci¢n del objeto correspondiente de la lista
destruyendo tambi‚n el nodo apuntodo por.}

procedure Lista.borrar(var xp:nodoPtr);
var
	tn,p:nodoPtr;
begin
	p:=xp;

	if (p= nil)or(ultimo=nil) then RunError(201);
	tn:=siguiente(p);
	if tn<> nil then
		tn^.anterior:=anterior(p)
	else
		ultimo:=anterior(p); {borrando el primer elemento}
	xp:=anterior(p);
	dispose(p^.Item,done);
	Dispose(p);
	Dec(NNodos);
	if xp = nil then
		xp:=Primero;
end;



function lista.quitar(var p:nodoPtr):BasePtr;
{ Desencadena el item, pero no lo mata 5/92}
var
	tn:nodoPtr;
begin
	if (p= nil)or(ultimo=nil) then RunError(211);
	tn:=siguiente(p);
	if tn<> nil then tn^.anterior:=anterior(p)
	else ultimo:=anterior(p); {borrando el primer elemento}
	tn:=p;
	p:=anterior(p);
	quitar:=tn^.Item;
	Dispose(tn);
	Dec(NNodos);
	if p = nil then p:=Primero;
end;


constructor Lista.Load(var f:archivo);
var
	tp:BasePtr;
	k:integer;
	NCOunt:integer;
begin
	Init;
	f.Read(NCount,2);
	for k:= 1 to NCount do
		begin
			tp:=f.Get;
			Insertar(tp^,Ultimo);
		end;
end;

procedure Lista.Save(var f:archivo);
var
	np:NodoPtr;
	k:integer;
begin
	f.write(NNodos,2);
	np:=primero;
	for k:= 1 to NNodos do
		begin
			f.Put (np^.item^);
			np:=siguiente(np)
		end;
end;

procedure Lista.Clear;
begin
	ultimo:=nil;
	NNodos:=0;
end;

destructor Lista.Done;
begin
	while ultimo<>nil do Borrar(ultimo)
end;

procedure Lista.Show;
var
	t:nodoPtr;
begin
	t:=ultimo;
	while t<> nil do
		begin
			t^.item^.Show;
			t:=anterior(t)
		end
end;

procedure Lista.Hide;
var
	t:nodoPtr;
begin
	t:=ultimo;
	while t<> nil do
		begin
			t^.item^.Hide;
			t:=anterior(t)
		end
end;

end.