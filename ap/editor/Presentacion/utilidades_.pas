unit utilidades;

interface

uses
		Grids, SysUtils, stdctrls, ImgList, Controls, Classes, Windows, Graphics,
    Messages, Forms;

const
	leftDef = 0;		//Coordenadas superior e izquerda del formulario principal por defecto
	topDef = 0;
	plusLeft = 5;	//Cuanto se le suma a las coordenadas del formulario hijo
	plusTop = 5;
	plusWidth = 10;
	plusHeight = 4;

Type
	TID_Icono= ( btEdit,
						 btClonar,
						 btEliminar,
						 checkBox_0,
						 checkBox_1,
						 radioButton_0,
						 radioButton_1 );
	TDAOfColores = array of TColor;

	TTipoColumna= (
		TC_Texto,
		TC_TextoEditable,
		TC_btEditar,
		TC_btEliminar,
		TC_btClonar,
		TC_checkBox,
		TC_radioButton,
		TC_Color,
		TC_Disabled,
		TC_ComboBox,
    TC_RaiseException);

var
		tiposdeColuma : array of TTipoColumna;
		mouseAbajo : boolean;
		col, fila, uACol, uAFila : Integer;

		//Retornan el ancho total que aumento la tabla
		function AutoSizeCol(Grid : TStringGrid ; Column : Integer) : integer;
		function AutoSizeTypedCol(Grid : TStringGrid; Column : Integer; tipo : TTipoColumna; iconos : TImageList) : Integer;
		function AutoSizeColsToMaxCol(Grid : TStringGrid) : integer;

		procedure AutosizeTableWidth(contenedor : TWinControl ; Grid : TStringGrid; maxWidth : Integer);
    procedure AutoSizeTableHeight(contenedor : TWinControl ; Grid : TStringGrid; maxHeight : Integer);

    //Ajusta el tamaño de la tabla al de la grilla
    procedure AutoSizeTableSinBajarControles(Grid : TStringGrid; maxWidth : Integer ; maxHeight : Integer);
    //Ajusta el tamaño de la tabla al de la grilla y suma su
    //delta altura a todos los controles por debajo de el
    //en contenedor
		procedure AutoSizeTable(contenedor : TWinControl ; Grid : TStringGrid; maxWidth : Integer ; maxHeight : Integer);

		procedure bajarControles(contenedor : TWinControl ; controlBase : TControl ; cantPixeles : Integer);
		//Baja todos los controles que esten por debajo de controlBase en cantPixeles

		function AutoSizeComboBox(cb : TComboBox) : Integer;

		procedure AgregarFormatoFecha(etiqueta : TLabel);

		procedure ListadoMouseDown(Sender: TObject; Button: TMouseButton;
			Shift: TShiftState; X, Y: Integer);
		procedure ListadoDrawCell(Sender: TObject; ACol, ARow: Integer;
			Rect: TRect; State: TGridDrawState;
			tipoColumna : TTipoColumna;
			colores : TDAOfColores ; iconos : TImageList);
		procedure ListadoMouseMove(Sender: TObject; Shift: TShiftState; X,
			Y: Integer; tiposdeColumna : array of TTipoColumna);
		function ListadoMouseUp(Sender: TObject; Button: TMouseButton;
			Shift: TShiftState; X, Y: Integer;tiposdeColumna : array of TTipoColumna)
			 : TTipoColumna;
		procedure listadoSelectCell(Sender: TObject; ACol,
			ARow: Integer; var CanSelect: Boolean; tiposCol : array of TTipoColumna);
		function listadoDblClick(Sender: TObject ; tiposCols : array of TTipoColumna) : TTipoColumna;
		procedure PopUpComboBox(Sender : TObject ; cb : TComboBox);

		//Retorna la extensión del archivo con el punto ej .txt
		function extension_(nombreArchivo : String) : String;

		//Retorna el titulo del archivo
		function titulo(nombreArchivo : String) : String;

		type
			TControlStringgrid = class(TStringgrid)
			private
				Procedure WMCommand( var msg: TWMCommand ); message WM_COMMAND;
			end;

		procedure Register;

var
	formatoFecha : String;

implementation

function AutoSizeCol(Grid: TStringGrid ; Column: integer) : Integer;
var
	i, W, WMax, sizeIni, posicion: integer;
	texto : string;
begin
	WMax := 0;
	sizeIni := Grid.Width;
	for i := 0 to (Grid.RowCount - 1) do begin
		posicion := pos(#13, Grid.Cells[column, i]);
		if posicion <> 0 then
			begin
			texto := Grid.Cells[column, i] + #13;
			repeat
			W := Grid.Canvas.TextWidth(copy(texto, 1, posicion - 1));
			if W > WMax then
				WMax := W;
			delete(texto, 1, posicion);
			posicion := pos(#13, texto);
			until Posicion=0;
			end
		else
			begin
			W := Grid.Canvas.TextWidth(Grid.Cells[Column, i]);
			if W > WMax then
				WMax := W;
			end
	end;
	WMax := WMax + plusWidth;
	Grid.Width := Grid.Width + (WMax - Grid.ColWidths[column]);
	Grid.ColWidths[Column] := WMax;
	result := Grid.Width - sizeIni;
end;

function AutoSizeTypedCol(Grid : TStringGrid; Column : Integer; tipo : TTipoColumna; iconos : TImageList) : Integer;
var
	iniWidth: Integer;
begin
	case tipo of
		TC_Texto, TC_TextoEditable, TC_ComboBox : result := AutoSizeCol(Grid, Column);
		TC_btEditar, TC_btEliminar, TC_btClonar, TC_checkBox, TC_radioButton, TC_Color, TC_Disabled :
																	begin
																	iniWidth := Grid.Width;
																	grid.Width := grid.Width + (iconos.Width - Grid.ColWidths[Column]);
																	grid.ColWidths[Column] := iconos.Width;
																	result :=	Grid.Width - iniWidth;
																	end;
		else
			result := 0;
	end
end;

function AutoSizeColsToMaxCol(Grid: TStringGrid) : integer;
var
	i, j, W, WMax, SizeIni, posicion: integer;
	texto : string;
begin
	WMax := 0;
	SizeIni := Grid.Width;
	for j := 0 to Grid.ColCount - 1 do begin
		for i := 0 to (Grid.RowCount - 1) do
				begin
				posicion := pos(#13, Grid.Cells[j, i]);
				if posicion <> 0 then
					begin
					texto := Grid.Cells[j, i] + #13;
					repeat
					W := Grid.Canvas.TextWidth(copy(texto, 1, posicion - 1));
					if W > WMax then
						WMax := W;
					delete(texto, 1, posicion);
					posicion := pos(#13, texto);
					until Posicion=0;
					end
				else
					begin
					W := Grid.Canvas.TextWidth(Grid.Cells[j, i]);
					if W > WMax then
						WMax := W;
					end
				end
	end;
	WMax := WMax + plusWidth;
	for i := 0 to Grid.ColCount - 1 do begin
		Grid.ColWidths[i] := WMax
	end;
	Grid.Width := Grid.ColCount*(WMax + Grid.GridLineWidth) + Grid.GridLineWidth+2;
	Grid.DefaultColWidth := WMax;
	result := Grid.Width - SizeIni;
end;

procedure AutosizeTableWidth(contenedor : TWinControl ; Grid : TStringGrid; maxWidth : Integer);
var
	i, width : Integer;
begin
	width := Grid.GridLineWidth +2;
	for i := 0 to Grid.ColCount - 1 do
		if width < maxWidth then
			width:=  width + (Grid.ColWidths[i] + Grid.GridLineWidth)
		else
			break;
  if width > maxWidth then
  begin
	  Grid.width:= maxWidth;
		Grid.Height:= Grid.Height + 18;
  end
  else
    Grid.Width:= width;
end;

procedure AutoSizeTableHeight(contenedor : TWinControl ; Grid : TStringGrid; maxHeight : Integer);
var
	i, height : Integer;
begin
	height := Grid.GridLineWidth +2;
	for i:= 0 to Grid.RowCount - 1 do
		if height < maxHeight then
			height:=  height + (Grid.RowHeights[i] + Grid.GridLineWidth)
		else
  		break;
  if height > maxHeight then
  begin
		Grid.Height:= maxHeight;
		Grid.width:= Grid.width + 18;
  end
  else
    Grid.Height:= height;
end;

procedure AutoSizeTableSinBajarControles(Grid : TStringGrid; maxWidth : Integer ; maxHeight : Integer);
var
	i, width, height : Integer;
  maximoAlto: boolean;
begin
	width:= Grid.GridLineWidth +2;
	height:= width; //Grid.GridLineWidth +2;

  maximoAlto:= false;
	for i := 0 to Grid.RowCount - 1 do
  begin
		if height < maxHeight then
    begin
			height:=  height + (Grid.RowHeights[i] + Grid.GridLineWidth)
    end
		else
  		break;
  end;
  if height > maxHeight then
  begin
    maximoAlto:= true;
		height:= maxHeight;
		width:= width + 18;
  end;

	for i := 0 to Grid.ColCount - 1 do
  begin
		if width < maxWidth then
    begin
			width:=  width + (Grid.ColWidths[i] + Grid.GridLineWidth)
    end
		else
			break;
  end;
  if width > maxWidth then
  begin
	  width:= maxWidth;
    if not maximoAlto then
  		height:= height + 18;
  end;

	Grid.Height:= height;
	Grid.Width:= width;
end;

procedure AutoSizeTable(contenedor : TWinControl ; Grid : TStringGrid; maxWidth : Integer ; maxHeight : Integer);
var
	hIni: Integer;
begin
  hIni:= Grid.Height;
  AutoSizeTableSinBajarControles(Grid, maxWidth, maxHeight);
	bajarControles(contenedor, Grid, Grid.Height - hIni);
end;

procedure bajarControles(contenedor : TWinControl ; controlBase : TControl ; cantPixeles : Integer);
var
	i : Integer;
begin
	for i := 0 to contenedor.ControlCount -1 do
		if contenedor.Controls[i].Top > controlBase.Top then
			contenedor.Controls[i].Top := contenedor.Controls[i].Top + cantPixeles;
end;

function AutoSizeComboBox(cb : TComboBox) : Integer;
var
	i, MaximoAncho, iniSize : Integer;
begin
	iniSize := cb.Width;
	if cb.Items.Count > 0 then
		begin
		MaximoAncho := cb.Canvas.TextWidth(cb.items[0]);
		for i := 1 to cb.Items.Count - 1 do
			if cb.Canvas.TextWidth(cb.items[i]) > MaximoAncho then
				MaximoAncho := cb.Canvas.TextWidth(cb.items[i]);
		cb.Width := MaximoAncho + plusWidth;
		end;
		result := cb.Width - iniSize;
end;

procedure AgregarFormatoFecha(etiqueta : TLabel);
begin
	etiqueta.Caption := etiqueta.Caption + formatoFecha;
	etiqueta.Width := etiqueta.Canvas.TextWidth(etiqueta.Caption);
end;

procedure ListadoMouseDown(Sender: TObject;
	Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
	case Button of
	mbLeft: begin
					(Sender as TStringGrid).MouseToCell(X, Y, col, fila);
					MouseAbajo:= true;
					end;
	end
end;

procedure ListadoMouseMove(Sender: TObject;
	Shift: TShiftState; X, Y: Integer;
	tiposdeColumna : array of TTipoColumna);
var
	aCol, aFila : Integer;
	SenderAsGrid : TStringGrid;
begin
	SenderAsGrid := Sender as TStringGrid;
	SenderAsGrid.ShowHint:= false;
	SenderAsGrid.MouseToCell(X, Y, aCol, aFila);

	if MouseAbajo then
	begin
		if (aCol<> Col) or ( aFila <> Fila ) then
		begin
			MouseAbajo:= false;
			SenderAsGrid.Invalidate;
		end
		else
			exit;
	end;

	if ( aFila < 1 ) or ( aCol < 0 ) then exit;

	SenderAsGrid.ShowHint := true;
	case tiposdeColumna[aCol] of
			TC_checkBox:				begin
													if SenderAsGrid.Cells[aCol, aFila] = '1' then
														SenderAsGrid.Hint := 'Desmarcar'
													else
														SenderAsGrid.Hint := 'Marcar'
													end;
			TC_btEditar:        SenderAsGrid.Hint := 'Editar';
			TC_btEliminar:      SenderAsGrid.Hint := 'Eliminar';
			TC_btClonar:        SenderAsGrid.Hint := 'Clonar';
		else SenderAsGrid.ShowHint := false;
	end;

	if ( aCol <> uACol ) or ( aFila <> uAFila) then
		SenderAsGrid.ShowHint:= false;

	uACol := aCol;
	uAFila := aFila;
	if ( aFila <> Fila ) or ( aCol <> Col) then
	begin
		Fila := -1;
		Col := -1;
	end;
end;

procedure ListadoDrawCell(Sender: TObject; ACol,
													ARow: Integer; Rect: TRect; State: TGridDrawState;
													tipoColumna : TTipoColumna;
													colores : TDAOfColores ; iconos : TImageList);
var
	SenderAsGrid : TStringGrid;

procedure DibujarColor(colores : TDAOfColores);
var
	SenderAsGrid : TDrawGrid;
begin
	SenderAsGrid := Sender as TDrawGrid;
	if (ARow < SenderAsGrid.FixedRows) or
		 (SenderAsGrid.FixedRows = 0) or
		 (ACol < SenderAsGrid.fixedCols) then exit;
	SenderAsGrid.Canvas.Brush.Color := colores[ARow -1];
	SenderAsGrid.Canvas.FillRect(Rect);
end;

procedure DibujarBoton( kicono: TID_ICono; apretable: boolean ; iconos : TImageList);
var
	SenderAsGrid : TDrawGrid;
begin
	SenderAsGrid := Sender as TDrawGrid;
	if (ARow < SenderAsGrid.FixedRows) or
		 (SenderAsGrid.FixedRows = 0) or
		 (ACol < SenderAsGrid.fixedCols) then exit;
	with SenderAsGrid do
	begin
			Canvas.Brush.Color := clWhite;
			Canvas.FillRect(Rect);
			iconos.Draw(Canvas,Rect.Left,Rect.Top, ord(kicono));
			if gdFocused in State then
				Canvas.DrawFocusRect(Rect);

			if apretable and MouseAbajo and ((ARow = fila) and (ACol = col)) then
			begin
				Canvas.Pen.Color := clBlack;
				Canvas.Pen.Width:= 2;
				Canvas.Polyline([
										Point(Rect.Left + 2, Rect.bottom - 2),
										Point(Rect.Left + 2, Rect.Top + 2),
										Point(Rect.Right - 2, Rect.Top + 2)
										]);
			end
	end
end;

procedure dibujarDisabled(Sender: TObject; Col, Row: Integer; Rect: TRect; State: TGridDrawState);
begin
	with TStringGrid(Sender).Canvas do
		begin
		Brush.Color := TStringGrid(Sender).FixedColor;
		FillRect(Rect);
		Pen.Style := psSolid;
		Pen.Width := 1;
		Pen.Color := clBlack;
		Polyline([point(rect.left - 1, rect.bottom + 1),
						 point(rect.TopLeft.X - 1, rect.TopLeft.Y - 1), point(rect.Right + 1, rect.top -1)]);
		Pen.Color := clBtnHighlight;
		Polyline([point(rect.Left, rect.Bottom - 1), rect.TopLeft, point(rect.Right, rect.Top)]);
		Pen.Color := clBtnShadow;
		Polyline([point(rect.Left + 1, rect.Bottom - 1), point(rect.Right - 1, Rect.Bottom - 1), point(rect.Right -1, rect.Top)]);
		end
end;

procedure dibujarTexto(Sender: TObject; Col, Row: Integer;
	 Rect: TRect; State: TGridDrawState);

var
	Texto    :string;
	Indice   : integer;
	Posicion : integer;
	grid : TStringGrid;
begin
	grid := Sender as TStringGrid;
	if Pos(#13, grid.Cells[Col,Row])<>0 then
			begin
			Texto := grid.Cells[Col,Row] + #13;
			grid.Canvas.FillRect(Rect);
			Indice:=0;
			repeat
				 Posicion:=Pos(#13,Texto);
				 with grid.Canvas do
				 TextOut( Rect.left +2,
									Rect.Top+(Indice*TextHeight(Copy(Texto,1,Posicion-1))) +2,
									Copy(Texto,1,Posicion-1));
				 Inc(Indice);
				 Delete(Texto,1,Posicion);
			until Posicion=0;
			grid.RowHeights[Row] := (Indice - 1) * grid.Canvas.TextHeight(grid.Cells[Col,Row])
															+ utilidades.plusHeight + 1;
			end;
end;

begin
	SenderAsGrid := Sender as TStringGrid;
	//Celdas fijas
//	if ( ACol >=  0 ) and ( ACol < 1 )
		if ARow = 0 then
		begin
		SenderAsGrid.Canvas.Pen.Color:= clBlack;
		SenderAsGrid.Canvas.Brush.Color:= SenderAsGrid.FixedColor;
		SenderAsGrid.Canvas.FillRect( Rect );
		SenderAsGrid.Canvas.Pen.Style := psSolid;
		SenderAsGrid.Canvas.Pen.Width := 1;
		SenderAsGrid.Canvas.Pen.Color := clBlack;
		SenderAsGrid.Canvas.Polyline([point(rect.left - 1, rect.bottom + 1),
						 point(rect.TopLeft.X - 1, rect.TopLeft.Y - 1), point(rect.Right + 1, rect.top -1)]);
		SenderAsGrid.Canvas.Pen.Color := clBtnHighlight;
		SenderAsGrid.Canvas.Polyline([point(rect.Left, rect.Bottom - 1), rect.TopLeft, point(rect.Right, rect.Top)]);
		SenderAsGrid.Canvas.Pen.Color := clBtnShadow;
		SenderAsGrid.Canvas.Polyline([point(rect.Left + 1, rect.Bottom - 1), point(rect.Right - 1, Rect.Bottom - 1), point(rect.Right -1, rect.Top)]);
		SenderAsGrid.Canvas.TextOut(Rect.Left + 2, Rect.Top + 2, SenderAsGrid.cells[ACol, Arow]);
		end
	else
		begin
		case tipoColumna of
			TC_Disabled 								: dibujarDisabled(Sender, ACol, ARow, Rect, State);
			TC_Texto,	TC_TextoEditable	: dibujarTexto(Sender, ACol, ARow, Rect, State);
			TC_btEditar									: DibujarBoton( btEdit , true, iconos );
			TC_btEliminar								: DibujarBoton( btEliminar , true, iconos  );
			TC_btClonar									: DibujarBoton( btClonar , true, iconos  );
			TC_checkBox									: if SenderAsGrid.cells[ACol, ARow]='1' then
																			DibujarBoton( checkBox_1 , false, iconos )
																		else
																			DibujarBoton( checkBox_0 , false, iconos );
//			TC_ComboBox									: nada 
			TC_radioButton							: if SenderAsGrid.cells[ACol, ARow]= '1' then
																			DibujarBoton( radioButton_1 , false, iconos )
																		else
																			DibujarBoton( radioButton_0 , false, iconos );
			TC_Color 										: DibujarColor(colores);
		end // del case
		end
end;

function ListadoMouseUp(Sender: TObject;
					Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
					tiposdeColumna : array of TTipoColumna) : TTipoColumna;
var
	aFila, aCol : Integer;
	res : TTipoColumna;
	SenderAsGrid : TStringGrid;
begin
  res:= TC_RaiseException; // agrego esto para que salte si estaba mal

	SenderAsGrid := Sender as TStringGrid;
	case Button of
	mbLeft: begin
					SenderAsGrid.MouseToCell(X, Y, Col, Fila);
					end;
	end;
	if not MouseAbajo then
		begin
		result := TC_Texto;
		exit;
		end;
	MouseAbajo:= false;

	SenderAsGrid.MouseToCell(X, Y, aCol, aFila);

	if ( aFila <> Fila ) or ( aCol <> Col ) then
		begin
		result := TC_Texto;
		exit;
		end;
	if (aFila < SenderAsGrid.FixedRows) or (aFila = 0) then
		begin
		result := TC_Disabled;
		exit;
		end;

	SenderAsGrid.MouseToCell(X, Y, aCol, aFila);
	if (aFila > SenderAsGrid.FixedRows - 1) and (aCol = Col) and (aFila = Fila) then
		begin
		SenderAsGrid.ShowHint := true;
		SenderAsGrid.Options := SenderAsGrid.Options - [goEditing];
		case tiposdeColumna[aCol] of
				TC_Texto:						begin
														SenderAsGrid.ShowHint:= false;
														res := TC_Texto;
														end;
				TC_TextoEditable:		begin
														SenderAsGrid.ShowHint:= false;
														SenderAsGrid.Options:= SenderAsGrid.Options + [goEditing];
														res := TC_TextoEditable;
														end;
				TC_btEditar:        begin
														SenderAsGrid.ShowHint := false;
														res := TC_btEditar;
														end;
				TC_btEliminar: 			begin
														SenderAsGrid.ShowHint := false;
														res := TC_btEliminar;
														end;
				TC_btClonar:        begin
														SenderAsGrid.ShowHint := false;
														res := TC_btClonar;
														end;
				TC_checkBox:				begin
														SenderAsGrid.ShowHint:= false;
														if SenderAsGrid.cells[aCol, aFila]= '1' then
															SenderAsGrid.cells[aCol, aFila]:= ''
														else
															SenderAsGrid.cells[aCol, aFila]:='1';
														res := TC_checkBox;
														end;
				TC_radioButton:			begin
														SenderAsGrid.ShowHint:= false;
														for aFila := 1 to SenderAsGrid.RowCount-1 do
															SenderAsGrid.cells[aCol, aFila]:= '' ;
														SenderAsGrid.cells[aCol, aFila]:= '1';
														res := TC_radioButton;
														end;
				TC_Color:        		begin
														SenderAsGrid.ShowHint := false;
														res := TC_Color;
														end;
				TC_Disabled:				begin
														res := TC_Disabled;
														end;
				TC_ComboBox :				begin
														SenderAsGrid.ShowHint := false;
														res := TC_ComboBox;
														end;
			end //del case
		end //del if
	else
		res := TC_Disabled;
	SenderAsGrid.Invalidate;
  if res= TC_RaiseException then
    raise Exception.Create('ListadoMouseUp, res llegó con valor no asignado');
	result := res;
end;

function listadoDblClick(Sender: TObject; tiposCols : array of TTipoColumna) : TTipoColumna;
begin
	if (col >= TStringGrid(Sender).FixedCols) and (fila >= TStringGrid(Sender).FixedRows) then
		result := tiposCols[col]
	else
		result := TC_Disabled;
end;

procedure listadoSelectCell(Sender: TObject; ACol,
						ARow: Integer; var CanSelect: Boolean; tiposCol : array of TTipoColumna);
begin
	if tiposCol[ACol] = TC_Disabled then
		CanSelect := false;
end;

Procedure PopUpComboBox(Sender : TObject ; cb : TComboBox);
var
	R: TRect;
	org: TPoint;
begin
	with Sender as TStringGrid do
		begin
		if (Col >= FixedCols) and (Row >= FixedRows)  then
			begin
			// entered the column associated to the combobox
			// get grid out of selection mode
			perform( WM_CANCELMODE, 0, 0 );
			// position the control on top of the cell
			R := CellRect( col, row );
	//				org:= Self.ScreenToClient( ClientToScreen( R.topleft ));
			org := R.TopLeft;
			with cb do
				begin
				setbounds( org.X, org.Y, r.right-r.left, height );
				itemindex := Items.IndexOf( Cells[ Col, Row ] );
				Show;
				BringTofront;
				// focus the combobox and drop down the list
				SetFocus;
				DroppedDown := true;
				end
			end
		end
end;

function extension_(nombreArchivo : String) : String;
var
   ext: string;
begin
   ext:= ExtractFileExt(nombreArchivo);
   result:= ext;
end;

function titulo(nombreArchivo : String) : String;
var
	i, posUltimoPunto : Integer;
begin
	posUltimoPunto := Length(nombreArchivo);
	for i := Length(nombreArchivo) - 1 downto 0 do
		if nombreArchivo[i] = '.' then
		begin
			posUltimoPunto := i;
			break
		end;
	result := copy(nombreArchivo, 0, posUltimoPunto -1);
end;

procedure Register;
begin
	RegisterComponents('PBGoodies', [TControlStringgrid]);
end;

procedure TControlStringgrid.WMCommand(var msg: TWMCommand);
begin
	If EditorMode and ( msg.Ctl = InplaceEditor.Handle ) Then
		inherited
	Else
		If msg.Ctl <> 0 Then
			msg.result :=
				SendMessage( msg.ctl, CN_COMMAND,
										 TMessage(msg).wparam,
										 TMessage(msg).lparam );
end;

initialization
begin
	formatoFecha := ' (' + Sysutils.ShortDateFormat + ')';
end;

end.
