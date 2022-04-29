{$F+}
program orden;



type



	nameType = string[72];

	fichaArchivo = record
		nombre:string[8];
		ext:string[3];
		path:word;
		tam:LongInt;
		fecha:string[8];
	end;

	fichaPath = record
		dsk:string[3]; {identificador del disco}
		nombre:nameType; {camino dentro del disco}
	end;

	key = nameType;
	KeyPtr = ^Key;

	TraversalProcedure = procedure(var x:key);

	nodoPtr = ^nodo;
	nodo = object
		der,izq:nodoPtr;
		item:Key;
		constructor Init(x:key);
		procedure Store(var x:key);
		procedure Traversal;
		destructor done;
	end;

	btree = object
		root:nodoPtr;
		constructor init;
		destructor done;
		procedure Store(var x:key);
		procedure Traversal(p:TraversalProcedure);
	end;

var
	trp:traversalProcedure;


constructor btree.init;
begin
	root:=nil;
end;

destructor btree.done;
begin
	if root<> nil then
	begin
		root^.done;
		dispose(root)
	end;
end;

procedure btree.Traversal(p:traversalProcedure);
begin
	trp:=p;
	if root<> nil then root^.Traversal;
end;

procedure btree.Store(var x:key);
begin
	if root<> nil then root^.Store(x)
	else new(root,Init(x));
end;



constructor nodo.Init(x:key);
begin
	der:=nil;
	izq:=nil;
	item:=x;
end;

procedure nodo.Store(var x:key);
begin
	if x>item then
		if der<> nil then der^.Store(x)
		else
			new(der,Init(x))
	else
		if izq<> nil then izq^.Store(x)
		else
			new(izq,Init(x))
end;

procedure nodo.Traversal;
begin
	if izq<> nil then izq^.traversal;
	trp(item);
	if der<> nil then der^.traversal;

end;

destructor nodo.done;
begin
	if izq<> nil then
	begin
		izq^.done;
		dispose(izq)
	end;
	if der<>nil then
	begin
		der^.done;
		dispose(der)
	end;
end;

procedure listar(var x:key);
begin
	writeln(x);
end;

var
	b:btree;
	fa:fichaArchivo;
	xkey:Key;
	ts:string[8];
	fin:file of fichaArchivo;

begin
	b.init;
	assign(fin,'dic91.ndx');
	reset(fin);
	while not eof(fin) do
	begin
		read(fin,fa);
		str(fa.path:5,xkey);
		str(fa.tam:8,ts);
		xkey:=fa.nombre+fa.ext+fa.fecha+ts+xkey;
		b.store(xkey)
	end;
	close(fin);
	assign(output,'orden.out');
	rewrite(output);
	b.traversal(listar);
	close(output);
end.
