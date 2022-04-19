unit uFormImportar;

interface

uses
	Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	StdCtrls, Grids, uCosa, uCosaConNombre, utilidades,
  usalasdejuego,
  uSalasDeJuegoParaEditor, uActores,
	uGter, unodos, udemandas,	uDemandaDetallada, uArcos, uHidroConEmbalse, uconstantesSimSEE;

type
  PSala = ^TSalaDeJuego;
	TFormImportar = class(TForm)
		LExportar: TLabel;
		sgActores: TStringGrid;
		BAceptar: TButton;
		BCancelar: TButton;
		OpenDialog1: TOpenDialog;
		procedure sgActoresDrawCell(Sender: TObject; ACol, ARow: Integer;
			Rect: TRect; State: TGridDrawState);
		procedure sgActoresMouseDown(Sender: TObject; Button: TMouseButton;
			Shift: TShiftState; X, Y: Integer);
		procedure sgActoresMouseMove(Sender: TObject; Shift: TShiftState; X,
			Y: Integer);
		procedure sgActoresMouseUp(Sender: TObject; Button: TMouseButton;
			Shift: TShiftState; X, Y: Integer);
		procedure BCancelarClick(Sender: TObject);
		procedure BAceptarClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
	private
    k: Integer;
		checked : array of boolean;
		tiposCols : array of TTipoColumna;
		salaAux : TSalaDeJuego;
    pSalaDeJuego: PSala;
		listaEntrada : TListaDeCosasConNombre;

		procedure cargarLista;
    procedure invertirSeleccion;
	public
		abortado : boolean;

		Constructor Create(AOwner : TComponent ; Sala : PSala ); reintroduce;
		procedure Free;
	end;

var
	FormImportar: TFormImportar;

implementation

uses SimSEEEditMain;

{$R *.DFM}

Constructor TFormImportar.Create(AOwner : TComponent ; Sala : PSala );
begin
	inherited Create(AOwner);
	abortado := false;
	SetLength(tiposCols, 2);
	tiposCols[0] := TC_Texto;
	tiposCols[1] := TC_checkBox;
	sgActores.Cells[0, 0] := 'Actor (Clase, Nombre)';
  pSalaDeJuego:= Sala;
	salaAux := NIL;
	listaEntrada := NIL;
  OpenDialog1.InitialDir:= FSimSEEEdit.opciones.libPath;
	if OpenDialog1.Execute then
		cargarLista
	else
		abortado := true
end;

procedure TFormImportar.Free;
var
	eraNil : boolean;
begin
	SetLength(tiposCols, 0);
	eraNIL := false;
	if salaAux <> NIL then
		salaAux.Free
	else
		eraNil := true;
	if listaEntrada <> NIL then
		if eraNil then
			listaEntrada.Free
		else
			listaEntrada.FreeSinElemenentos
	inherited Free;
end;

procedure TFormImportar.cargarLista;
var
	ext : String;
	i : Integer;
	arch : TArchiTexto;
  cosa: TCosaConNombre;
begin
	arch := TArchiTexto.CreateForRead(OpenDialog1.FileName);
	try
		begin
		ext := copy(OpenDialog1.FileName, Length(OpenDialog1.filename) - 2, MAXINT);
    k:= uCosaConNombre.referenciasSinResolver;
		if ext = 'lib' then
    begin
      arch.rd(':', TCosa(listaEntrada));
    end
		else if (ext = 'ese') then
		begin
  		listaEntrada:= TListaDeCosasConNombre.Create('Importar, Entrada');
			arch.rd( 'salaAux', TCosa(salaAux));
			listaEntrada.Capacity := salaAux.listaActores.Count;
			for i := 0 to salaAux.listaActores.Count -1 do
				listaEntrada.Add(TCosaConNombre(salaAux.listaActores[i]));
		end
    else if (ext = 'act') then
    begin
      arch.rd(':', TCosa(cosa));
      listaEntrada:= TListaDeCosasConNombre.Create('Importar, Entrada');
      listaEntrada.Add(cosa);
    end
    else
      raise Exception.Create('Extensión de Archivo Desconocida: .' + ext);

		SetLength(checked, listaEntrada.Count);
		sgActores.RowCount := listaEntrada.Count +1;
		for i := 0 to listaEntrada.Count -1 do
		begin
			sgActores.Cells[0, i + 1] := TCosaConNombre(listaEntrada[i]).ClassName + ', ' + TCosaConNombre(listaEntrada[i]).nombre;
			sgActores.Cells[1, i + 1] := '0';
 			checked[i] := false;
		end;
		for i := 0 to sgActores.ColCount -1 do
			utilidades.AutoSizeTypedCol(sgActores, i, tiposCols[i], FSimSEEEdit.iconos);
		utilidades.AutoSizeTable(self, sgActores, sgActores.Width, CP_MAXALTURATABLAENORME);
		BAceptar.Top := sgActores.top + sgActores.Height + 10;
		BCancelar.Top := BAceptar.Top;
		arch.free;
		end
	except on E : EInOutError do
		begin
		arch.Free;
		ShowMessage('El Archivo Seleccionado no Tiene un Formato Valido');
		ModalResult := mrAbort;
		end
	end
end;

procedure TFormImportar.invertirSeleccion;
var
  i : Integer;
begin
  for i:= 0 to high(checked) do
    checked[i]:= not checked[i];
  for i:= 0 to sgActores.RowCount -2 do
    if checked[i] then
			sgActores.Cells[1, i + 1] := '1'
    else
			sgActores.Cells[1, i + 1] := '0';
end;

procedure TFormImportar.sgActoresDrawCell(Sender: TObject; ACol,
	ARow: Integer; Rect: TRect; State: TGridDrawState);
begin
	utilidades.ListadoDrawCell(Sender, ACol, ARow, Rect, State, tiposCols[ACol], NIL, FSimSEEEdit.iconos);
end;

procedure TFormImportar.sgActoresMouseDown(Sender: TObject;
	Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
	utilidades.ListadoMouseDown(Sender, Button, Shift, X, Y);
end;

procedure TFormImportar.sgActoresMouseMove(Sender: TObject;
	Shift: TShiftState; X, Y: Integer);
begin
	utilidades.ListadoMouseMove(Sender, Shift, X, Y, tiposCols);
end;

procedure TFormImportar.sgActoresMouseUp(Sender: TObject;
	Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
	res : TTipoColumna;
begin
	res := utilidades.ListadoMouseUp(Sender, Button, Shift, X, Y, tiposCols);
  case res of
    TC_checkBox :		begin
                		checked[fila -1] := not checked[fila -1];
                		if checked[fila -1] then
                  		sgActores.Cells[1, fila] := '1'
                		else
                			sgActores.Cells[1, fila] := '';
                    end;
    TC_Disabled :   begin
                    if (col = 1) and (fila = 0) then
                      invertirSeleccion;
                    end
		end;
end;

procedure TFormImportar.BCancelarClick(Sender: TObject);
begin
	if Application.MessageBox('No ha Importado los Actores. ¿Desea Importarlos Ahora?', 'SimSEEUEdit',
		 MB_YESNO or MB_ICONEXCLAMATION) = IDYES then
		BAceptarClick(Sender)
	else
		ModalResult := mrCancel;
end;

procedure TFormImportar.BAceptarClick(Sender: TObject);
var
	i : Integer;
	actor : TActor;
	aImportar : TListaDeCosasConNombre;
  nombreOrig : String;
begin
	aImportar := TListaDeCosasConNombre.Create('Actores a Importar');
//	nombresRepetidos := TListaDeCosas.Create('Importados con Nombres Repetidos');
	for i := 0 to listaEntrada.Count -1 do
	begin
		actor := TActor(listaEntrada[i]);
		if checked[i] then
		begin
			aImportar.Add(actor);
			//Saco el actor de la lista de entrada y de la sala para no borrarlos al eliminar
			//las estructuras
			if salaAux <> NIL then
				usalasdejuegoparaeditor.quitarActor(salaAux, TActor(listaEntrada[i]));
 			listaEntrada[i] := NIL;
		end
    else
      uCosaConNombre.eliminar_referencias_del(actor)
	end;
	listaEntrada.Pack;

  //Resuelvo los nombres
  for i:= 0 to aImportar.Count -1 do
  begin
    actor:= TActor(aImportar[i]);
    if usalasdejuegoParaEditor.buscarCosaConNombre(pSalaDeJuego^, actor.nombre, actor.ClassName) <> NIL then
    begin
      nombreOrig:= actor.nombre;
      actor.nombre:= actor.nombre + '(2)';
      while usalasdejuegoParaEditor.buscarCosaConNombre(pSalaDeJuego^, actor.nombre, actor.ClassName) <> NIL do
        actor.nombre:= actor.nombre + '(2)';
      uCosaConNombre.cambiar_NombreDelReferidoEnReferenciasPosterioresAK(k, nombreOrig, actor.nombre, actor.ClassName);
    end;
  end;

  for i:= 0 to aImportar.Count -1 do
    FSimSEEEdit.agregarActor(TActor(aImportar[i]));

  for i:= 0 to aImportar.Count -1 do
  begin
    actor:= usalasdejuegoParaEditor.buscarCosaConNombre(pSalaDeJuego^, TActor(aImportar[i]).nombre, TActor(aImportar[i]).ClassName) as TActor;
    if usalasdeJuegoParaEditor.resolverReferenciasDeCosaContraSala(actor, pSalaDeJuego^, true) > 0 then
    begin
    	ShowMessage('El Actor ' + actor.nombre + ' Tiene Referencias Sin Resolver. Por Favor Modifiquelas Para Poder Continuar.');
			FSimSEEEdit.editar(actor, false);
    end
  end;


  //No se resuelven las referencias de los actores de la sala pues nos aseguramos
  //que no hayan nombres repetidos, entonces ninguno de la sala apunta a estos
{  uCosaConNombre.resolver_referencias(aImportar);
  while aImportar.lst.Count > 0 do
  begin
  	actor := TActor(aImportar.lst[0]);
{    if not FSimSEEUEdit.puedoAgregarActor(actor) then
		begin
			ShowMessage('Ya existe un ' + actor.DescClase + ' con el nombre ' + actor.nombre +'. Por Favor Modifiquelo Para Continuar.');
			FSimSEEUEdit.editar(actor, false);
		end
    else}{
    if uSalasdejuegoParaEditor.resolverReferenciasDeCosaContraSala(actor, pSalaDeJuego^) > 0 then
		begin
			ShowMessage('El Actor ' + actor.nombre + ' Tiene Referencias Sin Resolver. Por Favor Modifiquelas Para Poder Continuar.');
			FSimSEEUEdit.editar(actor, false);
		end
		else
  		FSimSEEUEdit.agregarActor(actor);
    aImportar.lst.Delete(0);
  end;}
	ModalResult := mrOk;
end;

procedure TFormImportar.FormActivate(Sender: TObject);
begin
	if abortado then
		begin
		ModalResult := mrCancel;
		self.Close
		end
end;

end.
