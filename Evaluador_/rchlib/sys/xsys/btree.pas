unit BTree; {rch dic.1991}
interface
type

	key = object
		destructor done; virtual;
		function mayor(var x:key):boolean;virtual;
	end;

	keyPtr = ^key;

	TraversalProcedure = procedure(var x:keyPtr);

	nodoPtr = ^nodo;
	nodo = object
		der,izq:nodoPtr;
		item:KeyPtr;
		constructor Init(x:keyPtr);
		procedure Store(x:keyPtr);
		procedure Traversal;
		destructor done; virtual;
	end;

	btreeType = object
		root:nodoPtr;
		constructor init;
		destructor done;
		procedure Store(x:keyPtr);
		procedure Traversal(p:TraversalProcedure);
	end;


implementation

var
	trp:traversalProcedure;


procedure abstract;
begin
	writeln('error>, key.done debe sobreescribirse');
end;

destructor key.done;
begin
	abstract;
end;

function key.mayor(var x:key):boolean;
begin
	abstract;
end;

constructor btreeType.init;
begin
	root:=nil;
end;

destructor btreeType.done;
begin
	if root<> nil then
	begin
		root^.done;
		dispose(root)
	end;
end;

procedure btreeType.Traversal(p:traversalProcedure);
begin
	trp:=p;
	if root<> nil then root^.Traversal;
end;

procedure btreeType.Store(x:keyPtr);
begin
	if root<> nil then root^.Store(x)
	else new(root,Init(x));
end;



constructor nodo.Init(x:keyPtr);
begin
	der:=nil;
	izq:=nil;
	item:=x;
end;

procedure nodo.Store(x:keyPtr);
begin
	if x^.mayor(item^) then
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
	dispose(item,done);
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


end.