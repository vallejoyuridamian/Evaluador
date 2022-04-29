unit ulst_escenarios;
interface

uses
  Classes, SysUtils,
  {$IFDEF WINDOWS}
   Windows,
   {$ELSE}
   LCLType,
   {$ENDIF}
 Messages,
  Forms,
  Controls,
  StdCtrls,
  Graphics,
  Dialogs,
  uDataSetGenerico,
  uvisordetabla,

  usalasdejuego,
  uEditorEscenario,
  uEscenarios,
  ueditor_resourcestrings;


type

  { TListadoEscenarios }

  TListadoEscenarios = class(TTabla)
  public
    flg_populate: boolean;
    sala: TSalaDeJuego;
    modificado: ^boolean;

    constructor Create(
      AOwner: TComponent; Name: string; sala: TSalaDeJuego;
      var ModificadoEditor: boolean); reintroduce;

    procedure Editar_onClick(nidRec: string; kFila: integer); override;
    procedure SemaforoRojo_OnClick(nidRec: string; kFila: integer); override;
    procedure SemaforoVerde_OnClick(nidRec: string; kFila: integer); override;
    procedure Borrar_OnClick(nidRec: string; kFila: integer); override;
    procedure Subir_OnClick( nidRec: string; kFila: integer); override;
    procedure clonar_OnClick( nidRec: string; kFila: integer ); override;
    procedure Bajar_OnClick( nidRec: string; kFila: integer); override;
    procedure radiobutton_0_OnClick( nidRec: string; kFila: integer); override;
    procedure radiobutton_1_OnClick( nidRec: string; kFila: integer); override;

    procedure Paint; override;
    procedure Populate;

    procedure EditarEscenario( ar: TEscenario_rec );
  end;


implementation

resourcestring
   rs_hint_Desactivar = 'Desactivar';
   rs_hint_Activar = 'Activar';
   rs_hint_Editar = 'Editar';
   rs_hint_Eliminar = 'Eliminar';
   rs_hint_Subir = 'Subir';
   rs_hint_Bajar = 'Bajar';
   rs_hint_Clonar = 'Clonar';
   rs_hint_CambiarEscenarioActivo = 'Cambiar escenario principal';

constructor TListadoEscenarios.Create(AOwner: TComponent; Name: string;
  sala: TSalaDeJuego; var ModificadoEditor: boolean);
begin
  inherited Create(AOwner, Name, 4, 1, 0);
  self.sala := sala;
  flg_populate := True;
  modificado := @ModificadoEditor;
end;




procedure TListadoEscenarios.SemaforoRojo_OnClick(nidRec: string; kFila: integer);
var
  a: TEscenario_rec;
begin
  modificado^ := True;
  a := sala.Escenarios.items[ kFila-1 ] as TEscenario_rec;
  a.activa := true;
  flg_populate:= true;
  invalidate;
end;


procedure TListadoEscenarios.SemaforoVerde_OnClick(nidRec: string; kFila: integer);
var
  a: TEscenario_rec;
begin
  modificado^ := True;
  a := sala.Escenarios.items[ kFila-1 ] as TEscenario_rec;
  a.activa := false;
  flg_populate:= true;
  invalidate;
end;

procedure TListadoEscenarios.Borrar_OnClick(nidRec: string; kFila: integer);
var
  a: TEscenario_rec;
begin
  if sala.Escenarios.Count > 1 then
  begin
    modificado^ := True;
    a:= sala.Escenarios[ kFila -1 ] as TEscenario_rec;
    sala.Escenarios.Delete( kFila -1  );
    if a = sala.EscenarioActivo then
    begin
      a:= sala.Escenarios[0] as TEscenario_rec;
      sala.EscenarioActivo:= a;
      sala.nombre_EscenarioActivo:= a.nombre;
    end;
    flg_populate:= true;
    invalidate;
  end
  else
    showmessage('No se permite borrar el último escenario.' );
end;




procedure TListadoEscenarios.EditarEscenario( ar: TEscenario_rec );
var
  editorEscenario: TEditorEscenario;
begin
    editorEscenario := TEditorEscenario.Create(self);
    editorEscenario.set_data( ar, sala.Escenarios );
    if editorEscenario.ShowModal = 1 then
    begin
     modificado^ := True;
     editorEscenario.get_data( ar );
     if sala.EscenarioActivo = ar then
       sala.nombre_EscenarioActivo:= sala.EscenarioActivo.nombre;
     flg_populate:=true;
     invalidate;
    end;
    editorEscenario.Free;
end;


procedure TListadoEscenarios.Editar_onClick(nidRec: string; kFila: integer);
var
  a: TEscenario_rec;
begin
  a := sala.Escenarios.items[ kFila-1 ] as TEscenario_rec;
  EditarEscenario( a );
  sala.nombre_EscenarioActivo:= a.nombre;
end;


procedure TListadoEscenarios.Subir_OnClick( nidRec: string; kFila: integer);
var
    a: TEscenario_rec;
begin
  if kFila > 1 then
  begin
    a := sala.Escenarios.items[ kFila-2 ] as TEscenario_rec;
    sala.Escenarios.items[ kFila-2 ]:= sala.Escenarios.items[ kFila-1 ];
    sala.Escenarios.items[ kFila-1 ]:= a;
    modificado^ := True;
    flg_populate:=true;
    invalidate;
  end;
end;

procedure TListadoEscenarios.clonar_OnClick(nidRec: string; kFila: integer);
var
  a: TEscenario_rec;
begin
  a := sala.Escenarios.items[ kFila-1 ] as TEscenario_rec;
  a:= a.Create_Clone( nil, 0 ) as TEscenario_rec;
  a.nombre:= '????_'+a.nombre;
  sala.Escenarios.Add( a );
  modificado^ := True;
  flg_populate:=true;
  invalidate;
end;

procedure TListadoEscenarios.Bajar_OnClick( nidRec: string; kFila: integer);
var
    a: TEscenario_rec;
begin
  if kFila < sala.Escenarios.Count then
  begin
    a := sala.Escenarios.items[ kFila ] as TEscenario_rec;
    sala.Escenarios.items[ kFila ]:= sala.Escenarios.items[ kFila-1 ];
    sala.Escenarios.items[ kFila-1 ]:= a;
    modificado^ := True;
    flg_populate:=true;
    invalidate;
  end;
end;

procedure TListadoEscenarios.radiobutton_0_OnClick( nidRec: string; kFila: integer);
var
    a: TEscenario_rec;
begin
  if kFila <= sala.Escenarios.Count then
  begin
    a := sala.Escenarios.items[ kFila-1 ] as TEscenario_rec;
    sala.EscenarioActivo:= a;
    sala.nombre_EscenarioActivo:= a.nombre;
    modificado^ := True;
    flg_populate:=true;
    invalidate;
  end;
end;

procedure TListadoEscenarios.radiobutton_1_OnClick( nidRec: string; kFila: integer);
begin
  // nada, ya es el activo.
end;

procedure TListadoEscenarios.Populate;
var
  k: integer;
  snid, sk: string;
  a: TEscenario_rec;
  estado: integer;
  n: integer;

begin
  flg_populate := False;
  ClearRedim( sala.Escenarios.Count + 1, 2);
  // fila encabezado
  wrTexto('', 0, 0, 'Nombre');
  wrTexto('', 0, 1, '--');

  AlinearCelda(0, 0, CAH_Izquierda, CAV_Centro);
  AlinearCelda(0, 1, CAH_Izquierda, CAV_Centro);

  Self.SetBgColorFila(0, clNavy);
  Self.SetFontColorFila(0, clYellow);

  Self.SetBgColorCelda(0, 0, clNavy);
  Self.SetBgColorCelda(0, 1, clNavy);

  n:= sala.Escenarios.count;
  if (sala.EscenarioActivo = nil) and ( n > 0 ) then
  begin
    sala.EscenarioActivo:= sala.Escenarios[0] as TEscenario_rec;
    modificado^ := True;
  end;

  for k := 1 to n do
  begin
    a := sala.Escenarios.items[ k-1 ] as TEscenario_rec;
    snid := IntToStr( k-1 );
    wrTexto('', k, 0, a.nombre );
    sk := 'k' + IntToStr(k);

    if ( a.activa ) then
    begin
      if a.nombre = sala.EscenarioActivo.nombre then
        wrBotonera( '', k, 1,
        [iid_SemaforoVerde, iid_Editar, iid_clonar,  iid_Borrar, iid_Subir, iid_Bajar, iid_radiobutton_1 ], [ rs_hint_Desactivar, rs_hint_Editar, rs_hint_Eliminar, rs_hint_Subir, rs_hint_Bajar, rs_hint_CambiarEscenarioActivo ] )
      else
        wrBotonera( '', k, 1,
        [iid_SemaforoVerde, iid_Editar, iid_clonar, iid_Borrar, iid_Subir, iid_Bajar, iid_radiobutton_0 ], [ rs_hint_Desactivar, rs_hint_Editar, rs_hint_Eliminar, rs_hint_Subir, rs_hint_Bajar, rs_hint_CambiarEscenarioActivo  ] );

      if (k mod 2) = 0 then
        SetBgColorFila(k, clFondoFilaPar_Activa)
      else
        SetBgColorFila(k, clFondoFilaImpar_Activa);
    end
    else
    begin
      if a.nombre = sala.EscenarioActivo.nombre then
        wrBotonera( '', k, 1, [iid_SemaforoRojo,  iid_Editar, iid_clonar, iid_Borrar, iid_Subir, iid_Bajar, iid_radiobutton_1 ], [  rs_hint_Activar, rs_hint_Editar, rs_hint_Eliminar, rs_hint_Subir, rs_hint_Bajar, rs_hint_CambiarEscenarioActivo ] )
      else
        wrBotonera( '', k, 1, [iid_SemaforoRojo,  iid_Editar, iid_clonar, iid_Borrar, iid_Subir, iid_Bajar, iid_radiobutton_0 ], [  rs_hint_Activar, rs_hint_Editar, rs_hint_Eliminar, rs_hint_Subir, rs_hint_Bajar, rs_hint_CambiarEscenarioActivo ] );

      if (k mod 2) = 0 then
        SetBgColorFila(k, clFondoFilaPar_Inactiva)
      else
        SetBgColorFila(k, clFondoFilaImpar_Inactiva);
    end;
    AlinearCelda(k, 0, CAH_Izquierda, CAV_Centro);
    AlinearCelda(k, 1, CAH_Izquierda, CAV_Centro);
  end;
  reposicionar;
end;

procedure TListadoEscenarios.Paint;
begin
  if flg_populate then
    Populate;
  inherited Paint;
end;


end.
