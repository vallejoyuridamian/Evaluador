unit ulst_plantillassimres3;

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
  uEditorSimRes3Main,
  ulistaplantillassr3,
  ueditor_resourcestrings;


type

  { TListadoPlantillasSimRes3 }

  TListadoPlantillasSimRes3 = class(TTabla)
  public
    flg_populate: boolean;
    sala: TSalaDeJuego;
    modificado: ^boolean;
    constructor Create(AOwner: TComponent; Name: string; sala: TSalaDeJuego;
      var ModificadoEditor: boolean); reintroduce;

    procedure Editar_onClick(nidRec: string; kFila: integer); override;
    procedure SemaforoRojo_OnClick(nidRec: string; kFila: integer); override;
    procedure SemaforoVerde_OnClick(nidRec: string; kFila: integer); override;
    procedure Borrar_OnClick(nidRec: string; kFila: integer); override;

    // Editor de la capa en la propia lista
    procedure Edit_OnChange( Sender: TObject); override;


    procedure Paint; override;
    procedure Populate;

    procedure EditarPlantilla( ar: TPlantillaSimRes3_rec );
  end;


implementation

resourcestring
   rs_hint_Desactivar = 'Desactivar';
   rs_hint_Activar = 'Activar';
   rs_hint_Editar = 'Editar';
   rs_hint_Eliminar = 'Eliminar';


constructor TListadoPlantillasSimRes3.Create(AOwner: TComponent; Name: string;
  sala: TSalaDeJuego; var ModificadoEditor: boolean);
begin
  inherited Create(AOwner, Name, 4, 1, 0);
  self.sala := sala;
  flg_populate := True;
  modificado := @ModificadoEditor;
end;




procedure TListadoPlantillasSimRes3.SemaforoRojo_OnClick(nidRec: string; kFila: integer);
var
  a: TPlantillaSimRes3_rec;
begin
  modificado^ := True;
  a := sala.listaPlantillasSimRes3.items[ kFila-1 ] as TPlantillaSimRes3_rec;
  a.activa := true;
  flg_populate:= true;
  invalidate;
end;


procedure TListadoPlantillasSimRes3.SemaforoVerde_OnClick(nidRec: string; kFila: integer);
var
  a: TPlantillaSimRes3_rec;
begin
  modificado^ := True;
  a := sala.listaPlantillasSimRes3.items[ kFila-1 ] as TPlantillaSimRes3_rec;
  a.activa := false;
  flg_populate:= true;
  invalidate;
end;

procedure TListadoPlantillasSimRes3.Borrar_OnClick(nidRec: string; kFila: integer);
var
  a: TPlantillaSimRes3_rec;
begin
  modificado^ := True;
  sala.listaPlantillasSimRes3.Delete( kFila -1  );
  flg_populate:= true;
  invalidate;
end;

procedure TListadoPlantillasSimRes3.Edit_OnChange(Sender: TObject);
var
  aux: string;
  kPlantilla: integer;
  i, kFila: integer;
  rescod: integer;
  capa: integer;
  e: TEdit;
  a: TPlantillaSimRes3_rec;
begin
  e:= Sender as TEdit;
  aux:= e.Name;
  writeln( 'nombre: ', aux );
  delete( aux, 1, length( 'ecapa_' ) );
  kPlantilla:= StrToInt( aux );
  aux:= e.Text;
  val( aux, capa, rescod );
  if rescod = 0 then
  begin
    e.Color:= clWhite;
    a := sala.listaPlantillasSimRes3.items[ kPlantilla ] as TPlantillaSimRes3_rec;
    a.capa:= capa;
    modificado^:=true;
  end
  else
  begin
    e.Color:= clRed;

  end;
end;



procedure TListadoPlantillasSimRes3.EditarPlantilla( ar: TPlantillaSimRes3_rec );
var
  resultado: integer;
begin
(**
   if modificado^ then
    begin
      resultado := Application.MessageBox(
        PChar(mesGuardarCambiosSalaParaContinuar), PChar(mesSimSEEEdit), MB_YESNOCANCEL);
      if resultado = idYes then
        MGuardarComoClick(MGuardarComo)
      else
        exit;
    end;
   **)

    editorSimRes3 := TEditorSimRes3.Create(self, sala, ar.archi.archi );
    if not editorSimRes3.errorAlCrear then
    begin
      editorSimRes3.ShowModal;
      if FileExists(editorSimRes3.sdArchiSimRes.FileName) then
      begin
        ar.archi.archi := editorSimRes3.sdArchiSimRes.FileName;
        flg_populate:=true;
        invalidate;
      end;
    end;
    editorSimRes3.Free;
    editorSimRes3 := nil;
end;


procedure TListadoPlantillasSimRes3.Editar_onClick(nidRec: string; kFila: integer);
var
  a: TPlantillaSimRes3_rec;
begin
  a := sala.listaPlantillasSimRes3.items[ kFila-1 ] as TPlantillaSimRes3_rec;
  EditarPlantilla( a );
end;


procedure TListadoPlantillasSimRes3.Populate;
var
  k: integer;
  snid, sk: string;
  a: TPlantillaSimRes3_rec;
  n: integer;

begin
  flg_populate := False;
  ClearRedim( sala.listaPlantillasSimRes3.Count + 1, 3);
  // fila encabezado
  wrTexto('', 0, 0, 'Archivo');
  wrTexto('', 0, 1, 'capa');
  wrTexto('', 0, 2, '--');

  AlinearCelda(0, 0, CAH_Izquierda, CAV_Centro);
  AlinearCelda(0, 1, CAH_Izquierda, CAV_Centro);
  AlinearCelda(0, 2, CAH_Izquierda, CAV_Centro);

  Self.SetBgColorFila(0, clNavy);
  Self.SetFontColorFila(0, clYellow);

  Self.SetBgColorCelda(0, 0, clNavy);
  Self.SetBgColorCelda(0, 1, clNavy);
  Self.SetBgColorCelda(0, 2, clNavy);

  n:= sala.listaPlantillasSimRes3.count;

  for k := 1 to n do
  begin
    a := sala.listaPlantillasSimRes3.items[ k-1 ] as TPlantillaSimRes3_rec;
    snid := IntToStr( k-1 );
    wrTexto('', k, 0, a.archi.archi );
    wrEdit( 'ecapa_'+snid, k, 1, IntToStr( a.capa ), 4, '' );
    sk := 'k' + IntToStr(k);
    if ( a.activa ) then
    begin
      wrBotonera( '', k, 2, [iid_SemaforoVerde, iid_Editar, iid_Borrar ], [ rs_hint_Desactivar, rs_hint_Editar, rs_hint_Eliminar ] );
      if (k mod 2) = 0 then
        SetBgColorFila(k, clFondoFilaPar_Activa)
      else
        SetBgColorFila(k, clFondoFilaImpar_Activa);
    end
    else
    begin
      wrBotonera( '', k, 2, [iid_SemaforoRojo,  iid_Editar, iid_Borrar], [  rs_hint_Activar, rs_hint_Editar, rs_hint_Eliminar ] );
      if (k mod 2) = 0 then
        SetBgColorFila(k, clFondoFilaPar_Inactiva)
      else
        SetBgColorFila(k, clFondoFilaImpar_Inactiva);
    end;

    AlinearCelda(k, 0, CAH_Izquierda, CAV_Centro);
    AlinearCelda(k, 1, CAH_Izquierda, CAV_Centro);
    AlinearCelda(k, 2, CAH_Izquierda, CAV_Centro);
  end;


  reposicionar;

end;

procedure TListadoPlantillasSimRes3.Paint;
begin
  if flg_populate then
    Populate;
  inherited Paint;
end;


end.
