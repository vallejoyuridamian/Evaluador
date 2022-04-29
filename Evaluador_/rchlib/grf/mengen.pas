{+doc
+NOMBRE:mengen
+CREACION:1.1.90
+AUTORES:rch
+REGISTRO:
+TIPO: Program Pascal.
+PROPOSITO: Generador iteractivo de menues en modo grafico (DOS).
+PROYECTO:GrafCrt

+REVISION:
+AUTOR:
+DESCRIPCION:
-doc}

program mengen;
uses
	Archivos,RCHFOnts,Graph,GR,MenGr,GrafCrt,MGProcs,Mouse;
var
	m00,m01,m02,m03,m04,m05:menu;
	OldExitProc:pointer;

procedure ArmarM00;
begin
	m00.Init(GetMaxX-UTW*40,GetMaxY-UTH*12,0);
	m00.DefinaTitulo('Editor de Menues');
	m00.add(1,'Traer de Disco',TraerDeDisco,nulo);
	m00.add(1,'Salvar a Disco',SalvarADisco,nulo);
	m00.add(1,'Editar Menues',EditarMenues,m01);
	m00.Papel(Blanco{GrisClaro});
	m00.Tinta(Negro);
	m00.PapelBOrde(Blanco{Celeste});
	m00.TintaBorde(Negro{Azul});
end;

procedure ArmarM01;
begin
	m01.init(GetMaxX-UTW*40,GetMaxY-UTH*20,0);
	m01.DefinaTitulo('Lista de Menues');
	m01.add(1,'Siguiente',MenuSiguiente,Nulo);
	m01.add(1,'Anterior',MenuAnterior,Nulo);
	m01.add(2,'Agregar',AgregarMenu,Nulo);
	m01.add(1,'Borrar',BorrarMenu,Nulo);
	m01.add(1,'Editar',abrir,m02);
	m01.Papel(GrisClaro);
	m01.Tinta(Negro);
	m01.PapelBOrde(Celeste);
	m01.TintaBorde(Azul);
	m01.DefinaProcAux(WriteEstadoAplicacion,m01);
end;




procedure ArmarM02;
begin
	m02.Init(GetMaxX-UTW*40,GetMaxY-UTH*20,0);
	m02.Papel(GrisClaro);
	m02.Tinta(Negro);
	m02.PapelBorde(Celeste);
	m02.TintaBorde(Azul);
	m02.DefinaTitulo('Edici¢n de Menu ');
	m02.add(1,'Borde ',abrir,m03);
	m02.add(1,'Campos',abrir,m04);
	m02.add(1,'Posici¢n',EditarOrigenMenu,nulo);
{	m02.DefinaProcAux(writeValores,nulo); }
end;

procedure Armarm03;
begin
	m03.init(GetMaxX-UTW*40,GetMaxY-UTH*20,0);
	m03.DefinaTitulo('Borde del Menu');
	m03.add(2,'Alto',EditarAltoBorde,Nulo);
	m03.add(2,'Ancho',EditarAnchoBorde,Nulo);
	m03.Papel(GrisClaro);
	m03.Tinta(Negro);
	m03.PapelBOrde(Celeste);
	m03.TintaBorde(Azul);
end;




procedure Armarm04;
begin
	m04.init(GetMaxX-UTW*40,GetMaxY-UTH*20,0);
	m04.DefinaTitulo('Lista de Campos');
	m04.add(1,'Siguiente',CampoSiguiente,Nulo);
	m04.add(1,'Anterior',CampoAnterior,Nulo);
	m04.add(2,'Agregar',abrir,m05);
	m04.add(1,'Borrar',BorrarCampo,Nulo);
	m04.add(1,'Editar',EditarCampo,Nulo);
	m04.Papel(GrisClaro);
	m04.Tinta(Negro);
	m04.PapelBOrde(Celeste);
	m04.TintaBorde(Azul);
	m04.DefinaProcAux(WriteEstadoListaCampos,Nulo);
end;



procedure Armarm05;
begin
	m05.init(GetMaxX-UTW*40,GetMaxY-UTH*20,0);
	m05.DefinaTitulo('Agregar Campo');
	m05.add(1,'Leyenda',AgregarLeyenda,Nulo);
	m05.add(5,'Var Real',AgregarVarReal,Nulo);
	m05.add(5,'Var Integer', AgregarVarInteger,nulo);
	m05.add(5,'Var Texto',AgregarVarTexto,Nulo);
	m05.add(1,'Ejecutable',AgregarEjecutable,Nulo);
	m05.Papel(GrisClaro);
	m05.Tinta(Negro);
	m05.PapelBOrde(Celeste);
	m05.TintaBorde(Azul);
end;



{$F+}
procedure Fin;
{$F-}
begin
	ExitProc:=OldExitProc;
	Gr.Close;
end;



begin
	GR.init;
	OldExitProc:=ExitProc;
	ExitProc:=@Fin;
	MNXX.RegistrarTipos(f);
	ArmarM00;
	ArmarM01;
	ArmarM02;
	ArmarM03;
	ArmarM04;
	ArmarM05;
	SetMinMaxHorzCursPos(0,GetMaxX);
	SetMinMaxVertCursPos(0,GetMaxY);
	abrir(m00);
end.
