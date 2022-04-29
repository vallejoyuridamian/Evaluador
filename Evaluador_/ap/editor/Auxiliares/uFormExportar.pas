unit uFormExportar;


interface

uses
  LResources,
  LCLType,
  FileUtil,

   {$IFDEF WINDOWS}
  Windows,
   {$ENDIF}
  Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Grids, uCosa, uActores, utilidades, uConstantesSimSEE, uCosaConNombre,
  uOpcionesSimSEEEdit, uInfoTabs, ExtCtrls, ComCtrls, uBaseFormularios;

resourcestring
  mesDebeSeleccionar1Actor = 'Debe Seleccionar por lo Menos un Actor';

type

  { TFormExportar }

  TFormExportar = class(TBaseFormularios)
    Panel1: TPanel;
    SaveDialog1: TSaveDialog;
    pDescripcion: TPanel;
    LExportar: TLabel;
    pBotones: TPanel;
    BCancelar: TButton;
    BAceptar: TButton;
    sgActores: TStringGrid;
    procedure sgActoresDrawCell(Sender: TObject; ACol, ARow: integer;
      Rect: TRect; State: TGridDrawState);
    procedure sgActoresMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure sgActoresMouseMove(Sender: TObject; Shift: TShiftState; X, Y: integer);
    procedure sgActoresMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure BCancelarClick(Sender: TObject);
    procedure BAceptarClick(Sender: TObject);
  private
    tiposCols: array of TTipoColumna;
    Checked: array of boolean;
    miLista: TListaDeCosas;
    exportado: boolean;


    procedure exportar(const path: string);
    procedure invertirSeleccion;
    function hayCheckeados: boolean;

  public
    constructor Create(AOwner: TComponent; lista1, lista2: TListaDeCosas); reintroduce;
    procedure Free;
  end;

var
  FormExportar: TFormExportar;

implementation

{$R *.lfm}

uses
  SimSEEEditMain;

constructor TFormExportar.Create(AOwner: TComponent; lista1, lista2: TListaDeCosas);
var
  i: integer;
begin
  inherited Create(AOwner);




  SaveDialog1.InitialDir := TSimSEEEditOptions.getInstance.libPath;
  miLista := TListaDeCosas.Create(0, 'miLista');
  miLista.Capacity := lista1.Count + lista2.Count;
  for i := 0 to lista1.Count - 1 do
    miLista.Add(lista1[i]);
  for i := 0 to lista2.Count - 1 do
    miLista.Add(lista2[i]);
  miLista.Sort(uInfoTabs.compareTipos);

  exportado := False;
  SetLength(tiposCols, 2);
  tiposCols[0] := TC_Texto;
  tiposCols[1] := TC_checkBox;
  sgActores.RowCount := miLista.Count + 1;
  SetLength(Checked, miLista.Count);

  sgActores.Cells[0, 0] := 'Actor (Clase, Nombre)';
  for i := 0 to miLista.Count - 1 do
  begin
    sgActores.Cells[0, i + 1] :=
      TActor(miLista[i]).DescClase + ', ' + TActor(miLista[i]).nombre;
    sgActores.Cells[1, i + 1] := '0';
    Checked[i] := False;
  end;
  for i := 0 to sgActores.ColCount - 1 do
    utilidades.AutoSizeTypedCol(sgActores, i, tiposCols[i], FSimSEEEdit.iconos);
end;


procedure TFormExportar.exportar(const path: string);
var
  i, mbRes: integer;
  arch: TArchiTexto;
  nomArch, msj, msjError, msjBox: string;
  cosaConNombre: TCosaConNombre;
  skip, overwrite: boolean;
begin
  if not DirectoryExists(path) { *Converted from DirectoryExists*  } then
    if not ForceDirectories(path) { *Converted from ForceDirectories*  } then
      raise Exception.Create('TFormExportar.exportar: No se puede acceder al directorio '
        + path + '.#13#10 ' +
        'Modifique el directorio de librerías de actores en Herramientas->Opciones y vuelva a intentarlo.');

  msj := 'Los actores se han exportado con éxito en los siguientes archivos:' + #13;
  msjError := 'Se encontraron los siguientes errores:' + #13;
  skip := False;
  overwrite := False;
  for i := 0 to high(Checked) do
  begin
    if Checked[i] then
    begin
      cosaConNombre := TCosaConNombre(miLista[i]);
      nomArch := path + cosaConNombre.ClassName + '_' + cosaConNombre.nombre + '.act';
      arch := nil;
      try
        while FileExists(nomArch) and not skip and not overwrite do
        begin
          {$IFDEF WINDOWS}
          //Para cambiar los botones
          PostMessage(Handle, WM_USER + 1025, 0, 0);
          {$ENDIF}
          msjBox := 'Ya existe un archivo para el actor ' +
            cosaConNombre.ClaseNombre + '. Indique que desea hacer con el archivo:'#0;
          mbRes := Application.MessageBox(@msjBox[1], 'Elegir una Acción',
            MB_YESNOCANCEL);
          if mbRes = ID_YES then //Sobreescribir
            overwrite := True
          else if mbRes = ID_NO then //Saltear Actor
            skip := True
          else if mbRes = ID_CANCEL then //Renombrar
          begin
            SaveDialog1.Execute;
            nomArch := SaveDialog1.FileName;
          end;
        end;
        overwrite := False;
        if not skip then
        begin
          arch := TArchiTexto.CreateForWrite(nomArch,
            TSimSEEEditOptions.getInstance.guardarBackupDeArchivos,
            TSimSEEEditOptions.getInstance.maxNBackups);
          arch.wr(':', cosaConNombre);
          arch.Free;
          msj := msj + nomArch + #13;
        end
        else
          skip := False;
      except
        on E: EInOutError do
        begin
          msjError := msjError + E.Message + #13;
          if arch <> nil then
            arch.Free;
        end
      end;
    end;
  end;
  if msj <> 'Los actores se han exportado con éxito en los siguientes archivos:'
    + #13 then
    ShowMessage(msj);
  if msjerror <> 'Se encontraron los siguientes errores:' + #13 then
    ShowMessage(msjError);
  ModalResult := mrOk;
end;

procedure TFormExportar.invertirSeleccion;
var
  i: integer;
begin
  for i := 0 to high(Checked) do
    Checked[i] := not Checked[i];
  for i := 0 to sgActores.RowCount - 2 do
    sgActores.Cells[1, i + 1] := BoolToStr(Checked[i]);
end;

function TFormExportar.hayCheckeados: boolean;
var
  res: boolean;
  i: integer;
begin
  res := False;
  for i := 0 to high(Checked) do
    if Checked[i] then
    begin
      res := True;
      break;
    end;
  Result := res;
end;

procedure TFormExportar.sgActoresDrawCell(Sender: TObject; ACol, ARow: integer;
  Rect: TRect; State: TGridDrawState);
begin
  utilidades.ListadoDrawCell(Sender, ACol, ARow, Rect, State, tiposCols[ACol],
    nil, FSimSEEEdit.iconos);
end;

procedure TFormExportar.sgActoresMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: integer);
begin
  utilidades.ListadoMouseDown(Sender, Button, Shift, X, Y);
end;

procedure TFormExportar.sgActoresMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: integer);
begin
  utilidades.ListadoMouseMove(Sender, Shift, X, Y, tiposCols);
end;

procedure TFormExportar.sgActoresMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
var
  res: TTipoColumna;
begin
  res := utilidades.ListadoMouseUp(Sender, Button, Shift, X, Y, tiposCols);
  case res of
    TC_checkBox:
    begin
      Checked[utilidades.filaListado - 1] :=
        not Checked[utilidades.filaListado - 1];
      sgActores.Cells[1, utilidades.filaListado] :=
        BoolToStr(Checked[utilidades.filaListado - 1]);
    end;
    TC_Disabled:
    begin
      if (utilidades.colListado = 1) and (utilidades.filaListado = 0) then
        invertirSeleccion;
    end
  end;
end;

procedure TFormExportar.BCancelarClick(Sender: TObject);
begin
  if hayCheckeados() and (Application.MessageBox(
    'No ha Exportado los Actores. ¿Desea Hacerlo Ahora?', 'SimSEEUEdit',
    MB_YESNO or MB_ICONEXCLAMATION) = idYes) then
    BAceptarClick(Sender)
  else
    ModalResult := mrCancel;
end;

procedure TFormExportar.BAceptarClick(Sender: TObject);
begin
  if hayCheckeados() then
  begin
    exportar(TSimSEEEditOptions.getInstance.libPath);
    if exportado then
      ModalResult := mrOk;
  end
  else
    ShowMessage(mesDebeSeleccionar1Actor);
end;


procedure TFormExportar.Free;
begin
  SetLength(tiposCols, 0);
  SetLength(Checked, 0);
  miLista.FreeSinElemenentos;
  inherited Free;
end;

initialization
end.
