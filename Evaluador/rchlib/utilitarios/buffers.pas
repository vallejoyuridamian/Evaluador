{+doc
+NOMBRE: Buffers
+CREACION:23.02.93
+AUTORES: rch
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO:  definicion del objeto TBuffer.
descendientes TLIFO and TFIFO.
+PROYECTO:

+REVISION:
+AUTOR:
+DESCRIPCION:
-doc}
unit BUffers;
interface
	uses
		MatObj,
		{$I xObjects},
		Horrores;



const
	ce_Ok = 0;
	ce_BufferLleno = -1;
	ce_BufferVacio = -1;

type
	TProcPtrX = procedure(X: pointer);
	TProcBPPtrX = procedure( BP:word; x: pointer );


	TBuffer = object( TVect )
		procedure Store( var S: TStream ); virtual;
		destructor done; virtual;
		function Entrar( var x ): integer; virtual;
		function Sacar( var x ): integer; virtual;
		function Lugar: integer; virtual;
		procedure ParaCadaUno_global( xproc: TProcPtrX ); virtual;
		procedure Limpiar; virtual;
  end;


	TFIFO = object( TBuffer )
		imn, imv: word;
		pmn, pmv: pointer;
		NE: word;

		constructor Init( xNEMax, Xtam: word);
		constructor Load( var S: TStream );
		procedure Store( var S: TStream ); virtual;
		destructor done; virtual;
		function Entrar( var x ): integer; virtual;
		function Sacar( var x ): integer; virtual;
		function Lugar: integer; virtual;
		procedure ParaCadaUno_global( xproc: TProcPtrX ); virtual;
		procedure Limpiar; virtual;
  end;




	TLIFO = object( TVect )
		pmn: pointer;
		NE: word;
		constructor Init( xNEMax, Xtam: word);
		constructor Load( var S: TStream );
		procedure Store( var S: TStream ); virtual;
		destructor done; virtual;
		function Entrar( var x ): integer; virtual;
		function Sacar( var x ): integer; virtual;
		function Lugar: integer; virtual;
		procedure ParaCadaUno_global( xproc: TProcPtrX ); virtual;
		procedure Limpiar; virtual;
  end;


implementation
procedure abstract;
begin
	error(' Llamada a m‚todo abstract ');
end;


{ Metodos de TBuffer }

procedure TBuffer.Store( var S: TStream );
begin abstract end;

destructor TBuffer.done;
begin abstract end;

function TBuffer.Entrar( var x ): integer;
begin abstract end;

function TBuffer.Sacar( var x ): integer;
begin abstract end;

function TBuffer.Lugar: integer;
begin abstract end;

procedure TBuffer.ParaCadaUno_global( xproc: TProcPtrX );
begin abstract end;

procedure TBuffer.Limpiar;
begin abstract end;

{ Metodos de TFIFO }
constructor  TFIFO.Init( xNEMax, Xtam: word);
begin
	Tvect.Init( xNEMax, XTam );
	Limpiar;
end;


constructor  TFIFO.Load( var S: TStream );
begin
	TVect.Load(S);
	S.Read(NE, SizeOf(NE));
	S.Read(imn, SizeOf(imn));
	S.Read(imv, SizeOf(imv));
	pmn:= pte(imn);
	pmv:= pte(imv);
end;

function TFifo.Lugar: integer;
begin
	Lugar:= N-NE;
end;

procedure TFIFO.Store( var S: TStream );
begin
	TVect.Store(S);
	S.write(NE, SizeOf(NE));
	S.write(imn, SizeOf(imn));
	S.write(imv, SizeOf(imv));
end;

destructor  TFIFO.done; 
begin
	TVect.done;
end;

function  TFIFO.Entrar( var x ): integer;
begin
	if lugar = 0 then Entrar:= ce_BufferLleno
	else
	begin
		Entrar:= ce_OK;
		if ne = 0 then { si es el primer elemento }
		begin
			system.inc(ne);
			imn:= 1;
			pmn:= pv;
			imv:= 1;
			pmv:= pv;
			move( x, pmn^, tam);
		end
		else
		begin
			system.inc(ne);
			system.inc(imn);
			if imn > n then
			begin
				imn := 1;
				pmn:= pv;
			end
			else
				inc(pmn);
			move( x, pmn^, tam);
		end;
	end;
end;





	
function  TFIFO.Sacar( var x ): integer;
begin
	if ne = 0 then Sacar:= ce_BufferVacio
	else
	begin
		Sacar:= ce_Ok;
		move( pmv^, x, tam);
		system.dec(ne);
		system.inc(imv);
		if imv > n then
		begin
			imv := 1;
			pmv:= pv;
		end
		else
		inc(pmv);
	end;
end;

procedure TFIFO.ParaCadaUno_global( xproc: TProcPtrX );
var
	k:word;
	i: word;
	p: pointer;
begin
	i:= imv;
	p:= pmv;
	for k:= 1 to NE do
	begin
		xproc(p);
		system.inc(i);
		if i> n then
		begin
			i:= 1;
			p:= pv
		end
		else
			inc(p);
	end;
end;

procedure TFIFO.Limpiar;
begin
	NE:= 0;
	pmn:= nil;
	pmv:= nil;
	imn:= 0;
	imv:= 0;
end;


(*
procedure TFIFO.ParaCadaUno_local( xproc: TProcBPPtrX);
var
	k:word;
	i: word;
	p: pointer;
	CALLINGBP: word;
begin
asm
	inc BP
	move CallingBP, BP;
	i:= imv;
	p:= pmv;
	for k:= 1 to NE do
	begin

		xproc(p);
		system.inc(i);
		if i> n then
		begin
			i:= 1;
			p:= pv
		end
		else
			inc(p);
	end;
end;

			inc    bp
 			push   bp                           
 			mov    bp,sp                        
 			push   ds                           
 			les    di,[bp+06]                   

 			mov    cx,es:Self.NE                
 			jcxz   @2                         
 			les    di,es:Self.pv                

@1:   push   es
			push   di                           
			push   cx
	{ Push el puntero al Item }                           
  		push   es:word ptr [di+02]          
			push   es:word ptr [di]

	{ Recuperamos el bp del procedimiento de llamada }             
			mov    ax,[bp]                      
			and    al,FE    {Lo obliga a ser multiplo de 2}                        
			push   ax
			call   far [bp+0A]                  
			pop    cx                           
			pop    di                           
			pop    es                           
			add    di,0004                      
			loop   @1                         
@2:   mov    sp,bp
			pop    bp                           
			dec    bp                           
			retf   0008                         
  *)

{ Metodos de TLIFO }

constructor  TLIFO.Init( xNEMax, Xtam: word);
begin
	Tvect.Init( xNEMax, XTam );
	Limpiar;
end;


constructor  TLIFO.Load( var S: TStream );
begin
	TVect.Load(S);
	S.Read(NE, SizeOf(NE));
	pmn:= pte(NE);
end;


function TLIFO.Lugar: integer;
begin
	Lugar:= N-NE;
end;

procedure TLIFO.Store( var S: TStream );
begin
	TVect.Store(S);
	S.write(NE, SizeOf(NE));
end;

destructor  TLIFO.done;
begin
	TVect.done;
end;





function  TLIFO.Entrar( var x ): integer;
begin
	if lugar = 0 then Entrar:= ce_BufferLleno
	else
	begin
		Entrar:= ce_Ok;
		if ne = 0 then  { si es el primero inicializamos todo }
		begin
			system.inc(ne);
			pmn:= pv;
			move( x, pmn^, tam);
		end
		else
		begin
			system.inc(ne);
			inc(pmn);
			move( x, pmn^, tam);
		end;
	end;
end;


function  TLIFO.Sacar( var x ): integer;
begin
	if ne = 0 then
		Sacar:= ce_BufferVacio
	else
	begin
		Sacar:= ce_Ok;
		move( pmn^, x, tam);
		system.dec(ne);
		dec(pmn);
	end;
end;

procedure TLIFO.ParaCadaUno_global( xproc: TProcPtrX );
var
	k:word;
	i: word;
	p: pointer;
begin
	p:= pv;
	for k:= 1 to NE do
	begin
		xproc(p);
		system.inc(i);
		inc(p);
	end;
end;

procedure TLIFO.Limpiar;
begin
	NE:= 0;
	pmn:= nil;
end;

end.

