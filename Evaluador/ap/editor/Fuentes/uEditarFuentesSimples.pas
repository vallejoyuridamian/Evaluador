unit uEditarFuentesSimples;

  {$MODE Delphi}

interface

uses
  {$IFDEF WINDOWS}
  Windows,
  {$ELSE}
  LCLType,
  {$ENDIF}
  Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Grids, ComCtrls,
  uBaseEditoresFuentesConFichas,
  uCosaConNombre,
  uFuentesAleatorias,
  uFuenteConstante,
  usalasdejuego,
  utilidades,
  ufichasLPD,
  uEditarBorne, uConstantesSimSEE, uverdoc, uOpcionesSimSEEEdit,
  uopencalc,
  uopencalcexportimport,
  uAuxiliares;

resourcestring
  rsNombreDelBorne = 'Nombre del Borne';
  mesConfirmaEliminarBorne = '¿Confirma que desea eliminar el borne seleccionado?';
  mesConfirmarEliminacion = 'Confirmar eliminación';

type

  { TEditarFuentesSimples }

  TEditarFuentesSimples = class(TBaseEditoresFuentesConFichas)
    btExportar_ods: TButton;
    btImportar_ods: TButton;
    CheckBox1: TCheckBox;
    ENombre: TEdit;
    LNombre: TLabel;
    sgFichas: TStringGrid;
    LFichasLPD: TLabel;
    sgBornes: TStringGrid;
    LBornes: TLabel;
    BAgregarFicha: TButton;
    BAgregarBorne: TButton;
    BGuardar: TButton;
    BCancelar: TButton;
    BVerExpandida: TButton;
    LDurPasoSorteo: TLabel;
    EdurPasoSorteo: TEdit;
    BAyuda: TButton;
    cbResumirPromediando: TCheckBox;
    procedure BAgregarFichaClick(Sender: TObject);
    procedure BExportarAEXCELClick(Sender: TObject);
    procedure BImportarDesdeExcelClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure BCancelarClick(Sender: TObject);
    procedure EditEnter(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure sgBornesDrawCell(Sender: TObject; ACol, ARow: integer;
      Rect: TRect; State: TGridDrawState);
    procedure sgBornesMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure sgBornesMouseMove(Sender: TObject; Shift: TShiftState; X, Y: integer);
    procedure sgBornesMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure BAgregarBorneClick(Sender: TObject);
    procedure BGuardarClick(Sender: TObject); override;
    procedure BAyudaClick(Sender: TObject);
    procedure EditIntExit(Sender: TObject);
    procedure cambiosForm(Sender: TObject);
    procedure ENombreExit(Sender: TObject);


  private
    NombresDeBornes_Publicados: TStringList;
    tiposColBornes: TDAOfTTipoColumna;
  public

    procedure editarBorne(fila: integer);
    procedure eliminarBorne(fila: integer);
    procedure actualizarTablaBornes;
  protected
    function validarFormulario: boolean; override;
  public
    constructor Create(AOwner: TComponent; sala: TSalaDeJuego;
      tipoCosa: TClass; cosaConNombre: TCosaConNombre); override;
  end;

implementation

  {$R *.lfm}

uses
  ucosa;

constructor TEditarFuentesSimples.Create(AOwner: TComponent;
  sala: TSalaDeJuego; tipoCosa: TClass; cosaConNombre: TCosaConNombre);
var
  i: integer;
  fuente: TFuenteAleatoriaConFichas;
begin
  inherited Create(AOwner, sala, tipoCosa, cosaConNombre);
  utilidades.initListado(sgBornes, [rsNombreDelBorne, encabezadoBTEditar,
    encabezadoBTEliminar], tiposColBornes, True);
  sgLimpiarSeleccion(sgBornes);

  // por ahora solo sabe exportar e importar bien las constantes
  if tipoCosa = TFuenteConstante then
  begin
    btExportar_ods.Visible:= true;
    btImportar_ods.Visible:= true;
  end
  else
  begin
    btExportar_ods.Visible:= false;
    btImportar_ods.Visible:= false;
  end;


  if cosaConNombre <> nil then
  begin
    fuente := TFuenteAleatoriaConFichas(cosaConNombre);
    inicializarComponentesLPD(fuente.lpd, TClaseDeFuenteAleatoriaConFichas(
      tipoCosa).TipoFichaFuente, sgFichas,
      BAgregarFicha, BVerExpandida, BGuardar, BCancelar);

    ENombre.Text := fuente.nombre;
    EdurPasoSorteo.Text := IntToStr(fuente.durPasoDeSorteoEnHoras);
    self.cbResumirPromediando.Checked := fuente.ResumirPromediando;

    NombresDeBornes_Publicados := TStringList.Create;
    for i := 0 to fuente.NombresDeBornes_Publicados.Count - 1 do
      NombresDeBornes_Publicados.Add(fuente.NombresDeBornes_Publicados[i]);

    actualizarTablaBornes;
  end
  else
  begin
    inicializarComponentesLPD(nil, TClaseDeFuenteAleatoriaConFichas(
      tipoCosa).TipoFichaFuente, sgFichas,
      BAgregarFicha, BVerExpandida, BGuardar, BCancelar);

    NombresDeBornes_Publicados := TStringList.Create;
    NombresDeBornes_Publicados.Add('Borne Por Defecto');
    actualizarTablaBornes;
  end;
end;

procedure TEditarFuentesSimples.ENombreExit(Sender: TObject);
begin
  inherited validarNombre(Sender);
end;

procedure TEditarFuentesSimples.editarBorne(fila: integer);
var
  form: TEditarBorne;
begin
  form := TEditarBorne.Create(self, NombresDeBornes_Publicados, fila - 1);
  if form.ShowModal = mrOk then
  begin
    if fila - 1 < NombresDeBornes_Publicados.Count then
      NombresDeBornes_Publicados[fila - 1] := form.darBorne
    else
      NombresDeBornes_Publicados.add(form.darBorne);
    actualizarTablaBornes;
  end;
  form.Free;
end;

procedure TEditarFuentesSimples.eliminarBorne(fila: integer);
begin
  if (Application.MessageBox(PChar(mesConfirmaEliminarBorne),
    PChar(mesConfirmarEliminacion), MB_OKCANCEL + MB_ICONEXCLAMATION) = idOk) then
  begin
    NombresDeBornes_Publicados.Delete(fila - 1);
    actualizarTablaBornes;
  end;
end;

procedure TEditarFuentesSimples.actualizarTablaBornes;
var
  i: integer;
begin
  sgBornes.RowCount := NombresDeBornes_Publicados.Count + 1;
  if sgBornes.RowCount > 1 then
    sgBornes.FixedRows := 1;

  for i := 0 to NombresDeBornes_Publicados.Count - 1 do
    sgBornes.Cells[0, i + 1] := NombresDeBornes_Publicados[i];

  for i := 0 to sgBornes.ColCount - 1 do
    utilidades.AutoSizeTypedCol(sgBornes, i, TiposColBornes[i], iconos);
  BAgregarBorne.Left := (sgBornes.Left + sgBornes.Width) - BAgregarBorne.Width;
end;

function TEditarFuentesSimples.validarFormulario: boolean;
begin
  Result := inherited validarFormulario and inherited validarNombre(ENombre) and
    inherited validarEditInt(EdurPasoSorteo, 0, MAXINT);
end;

procedure TEditarFuentesSimples.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
  if CanClose and (ModalResult <> mrOk) then
    NombresDeBornes_Publicados.Free;
end;

procedure TEditarFuentesSimples.BAgregarFichaClick(Sender: TObject);
begin
  inherited BAgregarFichaClick( Sender );
end;

procedure TEditarFuentesSimples.BExportarAEXCELClick(Sender: TObject);
begin
  if lpd.Count = 0 then exit;
  uopencalcexportimport.exportar_FichasLPD_aODS( lpd , btExportar_ods, btImportar_ods );
end;

procedure TEditarFuentesSimples.BImportarDesdeExcelClick(Sender: TObject);
begin
  if lpd.Count = 0 then exit;
  uopencalcexportimport.importar_FichasLPD_DesdeODS(
    lpd , sala.evaluador, btExportar_ods, btImportar_ods );
  ActualizarTabla;
end;

procedure TEditarFuentesSimples.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  inherited FormClose( Sender, CloseACtion );
end;

procedure TEditarFuentesSimples.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarFuentesSimples.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarFuentesSimples.FormCreate(Sender: TObject);
begin
  inherited;
end;

procedure TEditarFuentesSimples.EditIntExit(Sender: TObject);
begin
  inherited EditIntExit(Sender, 0, MaxInt);
end;

procedure TEditarFuentesSimples.sgBornesDrawCell(Sender: TObject;
  ACol, ARow: integer; Rect: TRect; State: TGridDrawState);
begin
  utilidades.ListadoDrawCell(Sender, ACol, ARow, Rect, State,
    tiposColBornes[ACol], nil, iconos);
end;

procedure TEditarFuentesSimples.sgBornesMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: integer);
begin
  utilidades.ListadoMouseDown(Sender, Button, Shift, X, Y);
end;

procedure TEditarFuentesSimples.sgBornesMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: integer);
begin
  utilidades.ListadoMouseMove(Sender, Shift, X, Y, tiposColBornes);
end;

procedure TEditarFuentesSimples.sgBornesMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: integer);
var
  res: TTipoColumna;
begin
  res := utilidades.ListadoMouseUp(Sender, Button, Shift, X, Y, tiposColBornes);
  case res of
    TC_btEditar: editarBorne(TStringGrid(Sender).Row);
    TC_btEliminar: eliminarBorne(TStringGrid(Sender).Row);
  end;
end;

procedure TEditarFuentesSimples.BAgregarBorneClick(Sender: TObject);
begin
  editarBorne(NombresDeBornes_Publicados.Count + 1);
end;

procedure TEditarFuentesSimples.BGuardarClick(Sender: TObject);
var
  fuente: TFuenteAleatoriaConFichas;

begin
  if validarFormulario then
  begin
    if cosaConNombre = nil then
    begin
      cosaConNombre := TClaseDeFuenteAleatoriaConFichas(tipoCosa).Create(capa,
        ENombre.Text, StrToInt(EdurPasoSorteo.Text),
        self.cbResumirPromediando.Checked, lpd);
      TFuenteAleatoria(cosaConNombre).NombresDeBornes_Publicados.Free;

      TFuenteAleatoria(cosaConNombre).NombresDeBornes_Publicados :=
        NombresDeBornes_Publicados;
    end
    else
    begin
      fuente := TFuenteAleatoriaConFichas(cosaConNombre);
      fuente.nombre := ENombre.Text;
      fuente.durPasoDeSorteoEnHoras := StrToInt(EdurPasoSorteo.Text);
      fuente.ResumirPromediando := cbResumirPromediando.Checked;
      {dfusco@20150424
       VER EL COMENTARIO QUE ESTÁ DENTRO DE ucosa.TCosa.CreateClone }
       
      fuente.lpd.Free;
      fuente.lpd:=lpd;
      
      fuente.NombresDeBornes_Publicados.Free;
      fuente.NombresDeBornes_Publicados := NombresDeBornes_Publicados;
    end;

    ModalResult := mrOk;
  end;
end;

procedure TEditarFuentesSimples.cambiosForm(Sender: TObject);
begin
  inherited cambiosForm(Sender);
end;


procedure TEditarFuentesSimples.BAyudaClick(Sender: TObject);
begin
  verdoc(self, tipoCosa);
end;

end.

