unit ufesquema;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Classes, Graphics,
  Controls, Forms, Dialogs,
  ExtCtrls, Menus, xMatDefs, Algebrac, Buttons, StdCtrls, ComCtrls,
  uesquema, upoligonal, urectangle, utog2d, ActnList, FileUtil, uTOGPropsForm;

type
  TForm1 = class(TForm)
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Exit1: TMenuItem;
    N1: TMenuItem;
    PrintSetup1: TMenuItem;
    Print1: TMenuItem;
    N2: TMenuItem;
    SaveAs1: TMenuItem;
    Save1: TMenuItem;
    Open1: TMenuItem;
    New1: TMenuItem;
    Edit1: TMenuItem;
    N3: TMenuItem;
    GoTo1: TMenuItem;
    Replace1: TMenuItem;
    Find1: TMenuItem;
    N4: TMenuItem;
    PasteSpecial1: TMenuItem;
    Paste1: TMenuItem;
    Copy1: TMenuItem;
    Cut1: TMenuItem;
    N5: TMenuItem;
    Repeatcommand1: TMenuItem;
    Undo1: TMenuItem;
    Window1: TMenuItem;
    Show1: TMenuItem;
    Hide1: TMenuItem;
    N6: TMenuItem;
    ArrangeAll1: TMenuItem;
    Cascade1: TMenuItem;
    Tile1: TMenuItem;
    NewWindow1: TMenuItem;
    Help1: TMenuItem;
    About1: TMenuItem;
    HowtoUseHelp1: TMenuItem;
    SearchforHelpOn1: TMenuItem;
    Contents1: TMenuItem;
    InsertarPoligonal1: TMenuItem;
    Button1: TButton;
    OpenDialog1: TOpenDialog;
    Group1: TMenuItem;
    Ungroup1: TMenuItem;
    Panel1: TPanel;
    StatusBar: TStatusBar;
    PaintBox1: TPaintBox;
    UpDown1: TUpDown;
    UpDown2: TUpDown;
    Button2: TButton;
    Button3: TButton;
    ScrollBox1: TScrollBox;
    Rectngulo1: TMenuItem;
    PopupMenu1: TPopupMenu;
    mi_editarForma: TMenuItem;
    mi_aspecto: TMenuItem;
    mi_propiedades: TMenuItem;
    mi_anclas: TMenuItem;
    mi_guardarComo: TMenuItem;
    mi_agregarAUnaPaleta: TMenuItem;
    ActionList1: TActionList;
    HaciaAdelante: TAction;
    HaciaAtras: TAction;
    mi_haciaAdelante: TMenuItem;
    mi_haciaAtras: TMenuItem;
    Agrupar: TAction;
    Desagrupar: TAction;
    Rectangulo: TAction;
    Poligonal: TAction;
    mi_agrupar: TMenuItem;
    mi_desagrupar: TMenuItem;
    mi_poligonal: TMenuItem;
    mi_rectangulo: TMenuItem;
    Propiedades: TAction;
    Borrar: TAction;
    mi_Borrar: TMenuItem;

    procedure PaintBox1Paint(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure PaintBox1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure Button1Click(Sender: TObject);
    procedure PaintBox1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: integer);
    procedure Save1Click(Sender: TObject);
    procedure Open1Click(Sender: TObject);
    procedure New1Click(Sender: TObject);
    procedure SaveAs1Click(Sender: TObject);
    procedure mi_editarFormaClick(Sender: TObject);
    procedure HaciaAdelanteExecute(Sender: TObject);
    procedure HaciaAtrasExecute(Sender: TObject);
    procedure AgruparExecute(Sender: TObject);
    procedure DesagruparExecute(Sender: TObject);
    procedure RectanguloExecute(Sender: TObject);
    procedure PoligonalExecute(Sender: TObject);
    procedure PropiedadesExecute(Sender: TObject);
    procedure BorrarExecute(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    esquema: TEsquema; // El esquema
    cg: TCanalGrafico2D; // canal gráfico
    oge: TOG2D; // objeto bajo edición
    m_bleft_down: boolean;
    modificado: boolean;

    procedure popup(x, y: integer; esquema: TEsquema; oge: TOG2D);

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}



procedure TForm1.PaintBox1Paint(Sender: TObject);
begin

  // self.PaintBox1.width:= self.Width - self.ScrollBox1.Width;
  cg.canvas.Pen.Color := clBlack;
  cg.canvas.Brush.Style := bsSolid;
  cg.canvas.Brush.Color := clBlue;

  (*
 self.PaintBox1.Canvas.FillRect(
   Rect(0,0,self.PaintBox1.width,self.PaintBox1.height));
   *)
  esquema.Show(cg);

  // el objeto bajo edición se tiene que dibujar después del esquema
  // para que quede por arriba.
  if oge <> nil then
    oge.Show(cg);

end;


procedure TForm1.PoligonalExecute(Sender: TObject);
begin
  if oge <> nil then
  begin
    oge.estado_x := E_Normal;
    esquema.AddOG(oge);
    oge := nil;
  end
  else
  begin
    oge := upoligonal.TOG2D_Poligonal.Create(complex_NULO);
    oge.estado_x := E_Creando;
  end;
end;

procedure TForm1.PropiedadesExecute(Sender: TObject);
var
  f: TTOGPropForm;
  res: integer;
  og: TOG2D;
begin

  if esquema.sel_ogs.Count <> 1 then
    exit;

  og := esquema.sel_ogs.Items[0];

  f := TTOGPropForm.Create(self);
  f.shape1.Pen.Color := og.ColorPen;
  f.shape1.Brush.Color := og.ColorBrush;
  f.Shape1.Pen.Width := og.GrosorPen;
  if og is TOG2D_Poligonal then
  begin
    f.cb_Close.Checked := TOG2D_Poligonal(og).cerrada;
    f.cb_Close.Visible := True;
  end
  else
    f.cb_Close.Visible := False;

  res := f.showmodal;
  if res = 1 then
  begin
    og.ColorPen := f.shape1.Pen.Color;
    og.ColorBrush := f.shape1.Brush.Color;
    og.GrosorPen := f.Shape1.Pen.Width;
    if og is TOG2D_Poligonal then
      TOG2D_Poligonal(og).cerrada := f.cb_Close.Checked;
    rcx_Vaciar(Esquema.r_invalido);
    rcx_Unir(Esquema.r_invalido, og.marco);

    cg.InvalidarRectangulo(
      self.PaintBox1.Parent.Handle,
      esquema.r_invalido.m1,
      esquema.r_invalido.m2,
      ScrollBox1.HorzScrollBar.ScrollPos,
      ScrollBOx1.VertScrollBar.ScrollPos
      );
    Self.PaintBox1.update;
  end;
  f.Free;
end;

procedure TForm1.RectanguloExecute(Sender: TObject);
begin
  if oge <> nil then
  begin
    oge.estado_x := E_Normal;
    esquema.AddOG(oge);
    oge := nil;
  end
  else
  begin
    oge := urectangle.TOG2D_Rectangle.Create(complex_NULO, complex_NULO);
    oge.estado_x := E_Creando;
    scrollbox1.Cursor := crCross;
  end;
end;

procedure TForm1.FormPaint(Sender: TObject);
begin
  //  Self.ScrollBox1.width:= Self.width -10;
end;

procedure TForm1.FormResize(Sender: TObject);
begin
  //  Self.ScrollBox1.width:= Self.width -10;
end;

procedure TForm1.mi_editarFormaClick(Sender: TObject);
begin
  //  le dio editar sobre un objeto
  if esquema.sel_ogs.Count <> 1 then
    ShowMessage('No es posible editar más de un objeto a la vez.')
  else
    TOG2D(esquema.sel_ogs[0]).EnterEdit;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  // creamos el registro de clases
  utog2d.AlInicio;
  upoligonal.AlInicio;
  urectangle.AlInicio;


  Self.esquema := TEsquema.Create('sin_nombre');
  self.oge := nil;
  Caption := esquema.nombre;
  cg := TCanalGrafico2D.Create(Self.PaintBox1.Canvas);
  modificado := False;
end;



procedure TForm1.popup(x, y: integer; esquema: TEsquema; oge: TOG2D);
var
  P: TPoint;
  o: TOG2D;

begin
  P.X := x;
  P.Y := y;
  P := PaintBox1.ClientToScreen(P);


  mi_guardarComo.Visible := True;
  mi_haciaAdelante.Visible := False;
  mi_poligonal.Visible := False;
  mi_rectangulo.Visible := False;

  mi_editarForma.Visible := False;
  mi_borrar.Visible := False;
  mi_aspecto.Visible := False;
  mi_propiedades.Visible := False;
  mi_anclas.Visible := False;
  mi_agregarAUnaPaleta.Visible := False;
  mi_haciaAtras.Visible := False;
  mi_agrupar.Visible := False;
  mi_desagrupar.Visible := False;


  if oge <> nil then
  begin
    // estoy creando un oge
  end
  else
  begin
    mi_poligonal.Visible := True;
    mi_rectangulo.Visible := True;

    if esquema.sel_ogs.Count > 0 then
    begin
      mi_propiedades.Visible := True;
      mi_haciaAtras.Visible := True;
      mi_haciaAdelante.Visible := True;
      mi_borrar.Visible := True;
      // actuando sobre selección.
      if esquema.sel_ogs.Count > 1 then
        mi_agrupar.Visible := True
      else
      begin
        mi_agregarAUnaPaleta.Visible := True;
        mi_anclas.Visible := True;
        o := esquema.sel_ogs.Items[0];
        if o is TOG2D_Grupo then
          mi_desagrupar.Visible := True
        else
        begin
          mi_editarForma.Visible := True;
          mi_aspecto.Visible := True;
        end;
      end;
    end;
  end;

  PopupMenu1.Popup(P.x, P.y);
end;

procedure TForm1.PaintBox1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);

var
  cx: NComplex;
  old_estado: TEstadoTOG2D;
begin

(*
  cg.c0.r:= ScrollBox1.HorzScrollBar.ScrollPos;
  cg.c0.i:= ScrollBOx1.VertScrollBar.ScrollPos;
  *)

  modificado := True;
  cg.xy2cx(x, y, cx);


  rcx_Vaciar(Esquema.r_invalido);
  if oge = nil then
  begin
    // no estoy creando un nuevo objeto
    if (Shift = [ssRight]) then
    begin
      self.popup(x, y, esquema, oge);
    end
    else
    begin
      Esquema.MouseDown(Button, Shift, cx);
    end;
  end
  else
  begin
    old_Estado := oge.estado_x;
    oge.MouseDown(Button, Shift, cx);
    if (old_Estado <> E_Normal) and (oge.estado_x = E_Normal) then
    begin
      esquema.AddOG(oge);
      scrollbox1.Cursor := crDefault;
      oge := nil;
    end;
  end;
  if not rcx_EsVacio(esquema.r_invalido) then
  begin
    cg.InvalidarRectangulo(
      self.PaintBox1.Parent.Handle,
      //            self.PaintBox1.Canvas.Handle,
      esquema.r_invalido.m1,
      esquema.r_invalido.m2,
      ScrollBox1.HorzScrollBar.ScrollPos,
      ScrollBOx1.VertScrollBar.ScrollPos
      );
    self.PaintBox1.update;
  end;

end;


procedure TForm1.AgruparExecute(Sender: TObject);
begin
  rcx_Vaciar(Esquema.r_invalido);
  esquema.Seleccion_Agrupar;
  if not rcx_EsVacio(esquema.r_invalido) then
  begin
    modificado := True;
    cg.InvalidarRectangulo(
      self.PaintBox1.Parent.Handle,
      esquema.r_invalido.m1,
      esquema.r_invalido.m2,
      ScrollBox1.HorzScrollBar.ScrollPos,
      ScrollBOx1.VertScrollBar.ScrollPos
      );
    self.PaintBox1.update;
  end;
end;

procedure TForm1.BorrarExecute(Sender: TObject);
begin
  rcx_Vaciar(Esquema.r_invalido);
  esquema.Seleccion_Eliminar;
  if not rcx_EsVacio(esquema.r_invalido) then
  begin
    modificado := True;
    cg.InvalidarRectangulo(
      self.PaintBox1.Parent.Handle,
      esquema.r_invalido.m1,
      esquema.r_invalido.m2,
      ScrollBox1.HorzScrollBar.ScrollPos,
      ScrollBOx1.VertScrollBar.ScrollPos
      );
    self.PaintBox1.update;
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  self.PaintBox1.Repaint;

end;


procedure TForm1.Button2Click(Sender: TObject);
begin
  //  cg.cr.r:= cg.cr.r * 2;
  //  cg.cr.i:= cg.cr.i * 2;
  cg.wx := cg.wx / 2;
  cg.hy := cg.hy / 2;
  self.PaintBox1.Invalidate;
  self.PaintBox1.update;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  //  cg.cr.r:= cg.cr.r / 2;
  //  cg.cr.i:= cg.cr.i / 2;
  cg.wx := cg.wx * 2;
  cg.hy := cg.hy * 2;
  self.PaintBox1.Invalidate;
  self.PaintBox1.update;
end;

procedure TForm1.DesagruparExecute(Sender: TObject);
begin
  rcx_Vaciar(Esquema.r_invalido);
  esquema.Seleccion_Desagrupar;
  if not rcx_EsVacio(esquema.r_invalido) then
  begin
    modificado := True;
    cg.InvalidarRectangulo(
      self.PaintBox1.Parent.Handle,
      esquema.r_invalido.m1,
      esquema.r_invalido.m2,
      ScrollBox1.HorzScrollBar.ScrollPos,
      ScrollBOx1.VertScrollBar.ScrollPos
      );
    self.PaintBox1.update;
  end;
end;

procedure TForm1.PaintBox1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: integer);
var
  cx: NComplex;

begin
  //   if Sender <> PaintBox1 then exit;

  statusbar.SimpleText := 'mx: ' + IntToStr(x) + 'my: ' + IntToStr(y);

(*
  cg.c0.r:= ScrollBox1.HorzScrollBar.ScrollPos;
  cg.c0.i:= ScrollBOx1.VertScrollBar.ScrollPos;
  *)


  cg.xy2cx(x, y, cx);
  rcx_Vaciar(esquema.r_invalido);


  if oge = nil then
  begin

    writeln('OGE == NIL, x: ' + IntToStr(x) + ', y: ' + IntToStr(y));
    esquema.MouseMove(shift, cx);


    if not rcx_EsVacio(esquema.r_invalido) then
    begin
      cg.InvalidarRectangulo(
        self.PaintBox1.Parent.Handle,
        esquema.r_invalido.m1,
        esquema.r_invalido.m2,
        ScrollBox1.HorzScrollBar.ScrollPos,
        ScrollBOx1.VertScrollBar.ScrollPos
        );
    end;
  end
  else
  begin
    writeln('OGE <> NIL, x: ' + IntToStr(x) + ', y: ' + IntToStr(y));

    cg.canvas.Pen.Color := clBlack;
    // uh!!! que feo esto aca. Durante la edición
    // los OGs tienen que tener acceso a un rectangulo inválido.
    // capaz que hay que darles acceso al esquema.
    if oge is TOG2D_Poligonal then
    begin
      with TOG2D_Poligonal(oge) do
      begin
        if length(vertices) > 1 then
        begin
          cg.InvalidarRectangulo(
            self.PaintBox1.Parent.Handle,
            vertices[high(vertices) - 1],
            vertices[high(vertices)],
            ScrollBox1.HorzScrollBar.ScrollPos,
            ScrollBOx1.VertScrollBar.ScrollPos
            );
        end;
      end;
    end
    else
    begin
      // si no se algo específico lo invalido todo.
      // esto tendría que ser el PorDefecto del objeto y si alguno quiere
      // que implemente en el objeto algo mejor.
      cg.InvalidarRectangulo(
        self.PaintBox1.Parent.Handle,
        oge.marco.m1, oge.marco.m2,
        ScrollBox1.HorzScrollBar.ScrollPos,
        ScrollBOx1.VertScrollBar.ScrollPos
        );
    end;



    oge.MouseMove(shift, cx);
    self.PaintBox1.update;
  end;
end;

procedure TForm1.Save1Click(Sender: TObject);
var
  f: TextFile;
  r: TRect;
  archi: string;
  so: boolean;
begin
  if esquema.nombre = 'sin_nombre' then
    SaveAs1Click(Sender);
  archi := GetCurrentDirUTF8 { *Converted from GetCurrentDir* } + '\' + esquema.nombre;
  assignFile(f, archi);
  rewrite(f);
  esquema.WriteToFile(f);
  CloseFile(f);
  modificado := False;
end;

procedure TForm1.Open1Click(Sender: TObject);
var
  f: TextFile;
  d: TOpenDialog;
begin

  if modificado then
    if MessageDlg(
      'El Diagra actual fue modificado y no salvado. Para salvarlo ahora presione Yes.',
      mtConfirmation, [mbYes, mbNo], 0) = mrYes then
      Save1Click(Self)
    else
      exit;


  d := TOpenDialog.Create(nil);
  d.Filter := 'Diagramas De Objetos |*.ddo';
  d.InitialDir := GetCurrentDirUTF8; { *Converted from GetCurrentDir* }
  if d.Execute then
  begin
    assignFile(f, d.fileName);
    reset(f);
    Esquema.Free;
    esquema := TEsquema.ReadFromFile(f);
    CloseFile(f);
    self.PaintBox1.Repaint;
    self.Caption := esquema.nombre;
    modificado := False;
  end;
  d.Free;
end;

procedure TForm1.New1Click(Sender: TObject);
var
  d: TOpenDialog;
  so: boolean;
begin
  if oge <> nil then
  begin
    ShowMessage('Actualmente está en modo EDICION.');
    exit;
  end;


  if modificado then
    if MessageDlg(
      'El Diagra actual fue modificado y no salvado. Para salvarlo ahora presione Yes.',
      mtConfirmation, [mbYes, mbNo], 0) = mrYes then
      Save1Click(Self)
    else
      exit;

  Esquema.ogs.Clear;
  Esquema.nombre := 'sin_nombre';
  self.Caption := esquema.nombre;
  self.PaintBox1.Repaint;
  modificado := False;

end;

function getsolonombrearchivo(archi: string): string;
var
  k: integer;
  buscando: boolean;
begin
  k := length(archi);
  buscando := True;
  while (k > 0) and buscando do
    if archi[k] in [':', '\'] then
      buscando := False
    else
      Dec(k);

  if buscando then
    Result := archi
  else
    Result := copy(archi, k + 1, length(archi) - k);
end;


procedure TForm1.SaveAs1Click(Sender: TObject);
var
  f: TextFile;
  r: TRect;
  d: TOpenDialog;
  so: boolean;
begin
  d := TOPenDialog.Create(nil);
  d.Filter := 'Diagramas De Objetos |*.ddo';
  d.InitialDir := GetCurrentDirUTF8; { *Converted from GetCurrentDir* }
  if d.Execute then
  begin
    so := True;
    if FileExistsUTF8(d.FileName) { *Converted from FileExists* } then
      so := MessageDlg('El archivo ya existe quiere SOBRE-ESCRIBIRLO?',
        mtConfirmation, [mbYes, mbNo], 0) = mrYes;
    if so then
    begin
      if pos('.', d.FileName) = 0 then
        d.FileName := d.FileName + '.ddo';
      esquema.nombre := getsolonombrearchivo(d.FileName);
      self.Caption := esquema.nombre;
      assignFile(f, d.FileName);
      rewrite(f);
      esquema.WriteToFile(f);
      CloseFile(f);
      modificado := False;
    end
    else
      exit;
  end;
end;




procedure TForm1.HaciaAdelanteExecute(Sender: TObject);
begin
  rcx_Vaciar(Esquema.r_invalido);
  esquema.Seleccion_HaciaAdelante;
  if not rcx_EsVacio(esquema.r_invalido) then
  begin
    modificado := True;
    cg.InvalidarRectangulo(
      self.PaintBox1.Parent.Handle,
      esquema.r_invalido.m1,
      esquema.r_invalido.m2,
      ScrollBox1.HorzScrollBar.ScrollPos,
      ScrollBOx1.VertScrollBar.ScrollPos
      );
    self.PaintBox1.update;
  end;
end;

procedure TForm1.HaciaAtrasExecute(Sender: TObject);
begin
  rcx_Vaciar(Esquema.r_invalido);
  esquema.Seleccion_HaciaAtras;
  if not rcx_EsVacio(esquema.r_invalido) then
  begin
    modificado := True;
    cg.InvalidarRectangulo(
      self.PaintBox1.Parent.Handle,
      esquema.r_invalido.m1,
      esquema.r_invalido.m2,
      ScrollBox1.HorzScrollBar.ScrollPos,
      ScrollBOx1.VertScrollBar.ScrollPos
      );
    self.PaintBox1.update;
  end;
end;


end.
