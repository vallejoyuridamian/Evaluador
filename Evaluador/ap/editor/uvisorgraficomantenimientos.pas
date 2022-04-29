unit uvisorgraficomantenimientos;

{$mode delphi}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, CheckLst, usalasdejuego, ulistamantenimientos, ucosa,
  uCosaConNombre, ucosaparticipedemercado, uActores,
  uunidades,
  ugeneradores, uFichasLPD;

type

  { TFormVisorMantenimientos }

  TFormVisorMantenimientos = class(TForm)
    CheckListBox1: TCheckListBox;
    GroupBox1: TGroupBox;
    eFecha: TLabeledEdit;
    PaintBox: TPaintBox;
    procedure btPlotMantenimientosClick(Sender: TObject);
    procedure CheckListBox1ItemClick(Sender: TObject; Index: integer);
    procedure FormPaint(Sender: TObject);
    procedure PaintBoxMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
  private
    { private declarations }
  public
    { public declarations }
    sala: TSalaDeJuego;
    lst_actores: TListaDeCosasConNombre;
    dt1, dt2: double;
    constructor Create(TheOwner: TComponent; sala: TSalaDeJuego); reintroduce;
  end;

var
  FormVisorMantenimientos: TFormVisorMantenimientos;

implementation

{$R *.lfm}

{ TFormVisorMantenimientos }

constructor TFormVisorMantenimientos.Create(TheOwner: TComponent; sala: TSalaDeJuego);
var
  fsal: textfile;
  actor: TActor;
  kActor: integer;

  ficha: TFichaClase;
  s: string;


begin
  inherited Create(TheOwner);
  self.sala := sala;
  lst_actores := sala.listaActores;
   dt1 := sala.globs.fechaIniOpt.dt;
  dt2 := sala.globs.fechaFinOpt.dt;


    (**
    assignfile( fsal, 'clases_registradas.xlt' );
    rewrite( fsal );
    for k:= 0 to ucosa.registro_de_ClasesDeCosas.count -1 do
    begin
      ficha:= TFichaClase( registro_de_ClasesDeCosas[k] );
      s:= ucosa.ParentsStrList( ficha.clase );
      writeln( fsal, s );
    end;
    closefile( fsal );
       **)

      for kActor := 0 to lst_actores.Count - 1 do
      begin
        actor := lst_actores[kActor] as TActor;
        if actor is TGenerador then
        begin
          CheckListBox1.AddItem( actor.nombre, actor );
        end;
      end;

      for kActor := 0 to CheckListBox1.Count - 1 do
      begin
        actor:= TActor( CheckListBox1.Items.Objects[kActor] );
        CheckListBox1.Checked[ kActor ]:= actor.flg_ShowVisorMantenimientosProgramados;
      end;
//      CheckListBox1.CheckAll(  cbChecked );

end;

procedure TFormVisorMantenimientos.btPlotMantenimientosClick(Sender: TObject);
var
  actor: TActor;
  kActor: integer;

  ficha: TFichaClase;
  s: string;

  lst_unidades: TFichasLPD;
  jUnidades: integer;
  gens: TList;

  dh, h, w: integer;
  cnt_MaxUnidades: integer;
  nTipos: integer;
  kTipo: integer;

  ficha1, ficha2: TFichaUnidades;
  jFicha1, jFicha2: integer;
  resLocate: integer;
  dt_Desde, dt_Hasta: TDateTime;

  hPos, wPos: integer;
  buscando: boolean;

  x1, y1, x2, y2: integer;
  nInstaladas, nEnMantenimiento: integer;

  wText: integer;
  Catalogo: TCatalogoReferencias;
begin

  for kActor := 0 to CheckListBox1.Count - 1 do
  begin
    actor:= TActor( CheckListBox1.Items.Objects[kActor] );
            actor.flg_ShowVisorMantenimientosProgramados:= CheckListBox1.Checked[ kActor ];
  end;

  h := PaintBox.Height;
  w := Paintbox.Width;

  gens:= TList.Create;
  for kActor:= 0 to CheckListBox1.Count-1 do
    if CheckListBox1.Checked[ kActor ] then gens.Add( CheckListBox1.items.Objects[ kActor ] );

  dh := h div gens.Count;

  Catalogo:= TCatalogoReferencias.Create;
  for kActor := 0 to gens.count - 1 do
  begin
    actor := gens[kActor];
    lst_unidades := actor.lpdUnidades;
    ntipos := lst_unidades.unidades_nTipos;
    lst_unidades.SortByFecha;
    lst_unidades.expandirFichas( Catalogo, sala.globs);

    cnt_MaxUnidades := lst_unidades.unidades_MaximoInstaladas(0);

    PaintBox.Canvas.Pen.Color:= clBlack;

    if cnt_MaxUnidades = 0 then
    begin
      x1 := 0;
      x2 := w;
      y1 := kActor * dh;
      y2 := (kActor + 1) * dh;
      PaintBox.Canvas.Brush.Color := clWhite;
      PaintBox.Canvas.Rectangle(x1, y1, x2, y2);
    end
    else
      for ktipo := 0 to nTipos - 1 do
      begin
        hPos := dh * kActor;
        wPos := 0;
        jFicha1 := 0;
        jFicha2 := 0;

        dt_desde := dt1;
        dt_hasta := dt1;
        buscando := True;
        while buscando do
        begin
          resLocate := lst_unidades.locate_dt(jFicha1, jFicha2,
            TFichaLPD(ficha1), TFichaLPD(ficha2), dt_desde, jFicha2);
          case resLocate of
            -1:  // ERROR no puede ser
              raise Exception('Error, las fichas dinámicas de unidades del actor: ' +
                Actor.nombre + ' no cubren el inicio de la optimización');
            0: // la fecha dt está entre las dos fichas.;
            begin
              if ficha2.fecha.dt >= dt2 then
              begin
                dt_hasta := dt2;
                buscando := False;
              end
              else
                dt_hasta := ficha2.fecha.dt;
              nInstaladas := ficha1.nUnidades_Instaladas[kTipo];
              nEnMantenimiento := ficha1.nUnidades_EnMantenimiento[kTipo];
            end;
            1:
            begin
              nInstaladas := ficha2.nUnidades_Instaladas[kTipo];
              nEnMantenimiento := ficha2.nUnidades_EnMantenimiento[kTipo];
              dt_hasta := dt2;
              buscando := False;
            end;
          end;
          x1 := trunc(w * (dt_Desde - dt1) / (dt2 - dt1) + 0.5);
          x2 := trunc(w * (dt_Hasta - dt1) / (dt2 - dt1) + 0.5);

          y1 := kActor * dh;
          y2 := trunc((kActor + (cnt_MaxUnidades - nInstaladas) / cnt_MaxUnidades) * dh+0.5);
          PaintBox.Canvas.Brush.Color := clGray;
          PaintBox.Canvas.Rectangle(x1, y1, x2, y2);

          y1 := y2;
          y2 := trunc((kActor + (cnt_MaxUnidades - nInstaladas +
            nEnMantenimiento) / cnt_MaxUnidades ) * dh+0.5);
          PaintBox.Canvas.Brush.Color := clRed;
          PaintBox.Canvas.Rectangle(x1, y1, x2, y2);

          y1 := y2;
          y2 := (kActor + 1) * dh;
          PaintBox.Canvas.Brush.Color := clGreen;
          PaintBox.Canvas.Rectangle(x1, y1, x2, y2);

          dt_Desde := dt_Hasta;
        end;
        jUnidades := jUnidades + cnt_MaxUnidades;
      end;

    PaintBox.Canvas.Brush.Style:= bsClear;
    s:= actor.nombre + ' ('+IntToStr( cnt_MaxUnidades )+')';
    wText:= PaintBox.Canvas.TextWidth( s );
    PaintBox.Canvas.Pen.Color:= clWhite;
    PaintBox.Canvas.TextOut( w - wText -10, trunc(kActor * dh), s );
    PaintBox.Canvas.Brush.Style:= bsSolid;

    lst_unidades.clearExpanded;
  end;
  Catalogo.Free;
end;

procedure TFormVisorMantenimientos.CheckListBox1ItemClick(Sender: TObject;
  Index: integer);
begin
  Invalidate;
end;



procedure TFormVisorMantenimientos.FormPaint(Sender: TObject);
begin
  self.btPlotMantenimientosClick( Sender );
end;

procedure TFormVisorMantenimientos.PaintBoxMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  dt: TDateTime;
begin
  dt:= ( dt2 - dt1 )/ PaintBox.Width * x + dt1;
  eFecha.Text:= DateTimeToStr( dt );
end;

end.
