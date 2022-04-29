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

type
	TProcPtrX = procedure(X: pointer);
	TProcBPPtrX = procedure(  bp:WORD; x: pointer );
	PProcBPPtrX = ^TProcBPPtrX;

	TFIFO = object( TVect )
		imn, imv: word;
    pmn, pmv: pointer;
    NE: word;
		constructor Init( xNEMax, Xtam: word);
		constructor Load( var S: TStream );
		procedure Store( var S: TStream );
		destructor done; virtual;
		procedure Entrar( var x );
		procedure Sacar( var x );
		procedure ParaCadaUno_global( xproc: TProcPtrX ); virtual;
		function PteProximoASalir: pointer;
	 {	procedure ParaCadaUno_local( xproc: TProcBPPtrX); virtual;
	 Esta en vias de implementacion }
   {
		procedure ParaCadaUno_local( xproc: PProcBPPtrX; LocalBP:word);virtual;
		}
  end;

const
	RFIFO: TStreamRec = ( ObjType: 4010;
	 VmtLink: Ofs(TypeOf(TFIFO)^);
	 Load:    @TFIFO.Load;
	 Store:   @TFIFO.Store
	);


type

	TLIFO = object( TVect )
    pmn: pointer;
    NE: word;
		constructor Init( xNEMax, Xtam: word);
		constructor Load( var S: TStream );
    procedure Store( var S: TStream );
		destructor done; virtual;
		procedure Entrar( var x );
		procedure Sacar( var x );
		procedure ParaCadaUno_global( xproc: TProcPtrX ); virtual;
		function PteProximoASalir: pointer;
  end;

const
	RLIFO: TStreamRec = ( ObjType: 4010;
	 VmtLink: Ofs(TypeOf(TLIFO)^);
	 Load:    @TLIFO.Load;
	 Store:   @TLIFO.Store
	);


procedure RegisterBuffers;

implementation


procedure RegisterBuffers;
begin
	RegisterType( RFIFO );
	RegisterType( RLIFO );
end;

{ Metodos de TFIFO }
constructor  TFIFO.Init( xNEMax, Xtam: word);
begin
	Tvect.Init( xNEMax, XTam );
	NE:= 0;
	pmn:= nil;
	pmv:= nil;
	imn:= 0;
  imv:= 0;
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

procedure  TFIFO.Entrar( var x );
begin
	if ne = 0 then
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
		if ne> n then error('TFIFO: LLENO');
		system.inc(imn);
		if imn > n then
		begin
			imn := 1;
			pmn:= pv;
		end
		else
    	inc(pmn);
		if imn = imv then error('TFIFO: LLENO');
		move( x, pmn^, tam);
	end;
end;





	
procedure  TFIFO.Sacar( var x );
begin
	if ne = 0 then error('TFIFO: VACIO');
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

function TFIFO.PteProximoASalir: pointer;
begin
	PteProximoASalir:= pmv;
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
(*

procedure TFIFO.ParaCadaUno_local( xproc: PProcBPPtrX; LocalBP:word);
var
	k:word;
	i: word;
	p: pointer;
	CALLINGBP: word;
begin
	p:= pv;
	for k:= 1 to NE do
	begin
		xproc^(LocalBP, P); DONT WORW.
		system.inc(i);
		inc(p);
	end;
end;*)

(*			inc    bp
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
			add    di,Tam                   
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
	NE:= 0;
	pmn:= nil;
end;


constructor  TLIFO.Load( var S: TStream );
begin
	TVect.Load(S);
	S.Read(NE, SizeOf(NE));
	pmn:= pte(NE);
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

procedure  TLIFO.Entrar( var x );
begin
	if ne = 0 then
	begin
		system.inc(ne);
		pmn:= pv;
		move( x, pmn^, tam);
	end
	else
	begin
		system.inc(ne);
		if ne> n then error('TLIFO: LLENO');
    inc(pmn);
		move( x, pmn^, tam);
	end;
end;


procedure  TLIFO.Sacar( var x );
begin
	if ne = 0 then error('TLIFO: VACIO');
	move( pmn^, x, tam);
  system.dec(ne);
	dec(pmn);
end;


function TLIFO.PteProximoASalir: pointer;
begin
	PteProximoASalir:= pmn;
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

end.

