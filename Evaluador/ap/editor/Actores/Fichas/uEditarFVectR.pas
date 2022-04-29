unit uEditarFVectR;

{$MODE Delphi}

interface

uses
{$IFDEF FPC-LCL}
  LResources,
{$ENDIF}

{$IFDEF WINDOWS}
Windows,
{$ENDIF}
 Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids, xmatdefs, uFuncionesReales,
  uBaseEditores, utilidades,
  uconstantesSimSEE, uOpcionesSimSEEEdit,
  uopencalcexportimport;

type
  TEditarFVectR = class(TBaseEditores)
    LCurvaVP: TLabel;
    LNDisc: TLabel;
    sgCurva: TStringGrid;
    ENDisc: TEdit;
    BGuardar: TButton;
    BCancelar: TButton;
    BImportar_ods: TButton;
    BExportar_ods: TButton;
    procedure EditEnter(Sender: TObject);
    procedure EditTamTablaExit(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure BGuardarClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject);
    procedure BExportar_odsClick(Sender: TObject);
    procedure BImportar_odsClick(Sender: TObject);
  private
    diffX: NReal;
    xmin: NReal;
    xmax: NReal;
    curva: TFVectR;
  protected
    function validarFormulario: boolean; override;
  public
    constructor Create_CrearCurva(AOwner: TForm; capa: integer; xmin, xmax: NReal;
      nPuntosDiscIni: integer; ejeX, ejeY: string); reintroduce; overload;
    constructor Create(AOwner: TForm; xmin, xmax: NReal; f: TFVectR;
      ejeX, ejeY: string); reintroduce; overload;
    function darCurva: TFVectR;
    procedure Free; virtual;
  end;


implementation

uses Math;
  {$R *.lfm}

constructor TEditarFVectR.Create_crearCurva(AOwner: TForm; capa: integer; xmin, xmax: NReal;
  nPuntosDiscIni: integer; ejeX, ejeY: string);
var
  i: integer;
  yval: TDAOfNReal;
begin
  setlength( yval, NPuntosDiscIni );
  curva := TFVectR.Create( capa, yval, xmin, xmax);
  inherited Create(AOwner, curva, nil );
  self.Top := AOwner.Top + plusTop;
  self.Left := AOwner.Left + plusLeft;
  self.xmin := xmin;
  self.xmax := xmax;
  diffX := (xmax - xmin) / (nPuntosDiscIni - 1);
//  curva := nil;
  ENDisc.Text := IntToStr(nPuntosDiscIni);
  sgCurva.RowCount := nPuntosDiscIni + 1;
  sgCurva.Cells[0, 0] := ejeX;
  sgCurva.Cells[1, 0] := ejeY;
  self.Caption := 'Editar función - ' + ejeY + ' en función de ' + ejeX;
  for i := 1 to nPuntosDiscIni do
  begin
    sgCurva.Cells[0, i] := FloatToStrF(xmin + (i - 1) * diffX, ffFixed, 8, 3);
    sgCurva.Cells[1, i] := '0';
  end;
end;

constructor TEditarFVectR.Create(AOwner: TForm; xmin, xmax: NReal;
  f: TFVectR; ejeX, ejeY: string);
var
  i: integer;
begin
  curva := f.Create_Clone( nil, 0 ) as TFVectR;
  inherited Create(AOwner, f, nil );
  self.Top := AOwner.Top + plusTop;
  self.Left := AOwner.Left + plusLeft;
  self.xmin := xmin;
  self.xmax := xmax;
  diffX := (xmax - xmin) / (f.vector.n - 1);
  ENDisc.Text := IntToStr(f.vector.n);
  sgCurva.RowCount := f.vector.n + 1;
  sgCurva.Cells[0, 0] := ejeX;
  sgCurva.Cells[1, 0] := ejeY;
  self.Caption := 'Editar función - ' + ejeY + ' en función de ' + ejeX;
  for i := 1 to f.vector.n do
  begin
    sgCurva.Cells[0, i] := FloatToStrF(xmin + (i - 1) * diffX, ffFixed, 8, 3);
    sgCurva.Cells[1, i] := FloatToStr(f.vector.e(i));
  end;
end;

function TEditarFVectR.darCurva: TFVectR;
begin
  Result := curva.Create_Clone( nil, 0 ) as TFVectR;
end;

procedure TEditarFVectR.Free;
begin
  if curva <> nil then curva.Free;
  inherited Free;
end;

function TEditarFVectR.validarFormulario: boolean;
begin
  Result := validarEditInt(ENDisc, 2, MAXINT) and validarTablaNReals_(sgCurva);
end;

procedure TEditarFVectR.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarFVectR.EditTamTablaExit(Sender: TObject);
var
  nAnt, n, i: integer;
begin
  if validarEditInt(TEdit(Sender), 2, MAXINT) then
  begin
    nAnt := sgCurva.RowCount - 1;
    n := StrToInt(TEdit(Sender).Text);
    if n <> nAnt then
    begin
      diffX := (xmax - xmin) / (n - 1);
      sgCurva.RowCount := n + 1;
      n := min(n, nAnt);
      for i := 1 to n do
      begin
        sgCurva.Cells[0, i] := FloatToStrF(xmin + (i - 1) * diffX, ffFixed, 8, 3);
      end;
      if n <> 0 then
        for i := n + 1 to sgCurva.RowCount - 1 do
        begin
          sgCurva.Cells[0, i] := FloatToStrF(xmin + (i - 1) * diffX, ffFixed, 8, 3);
          sgCurva.Cells[1, i] := sgCurva.Cells[1, n];
        end
      else
        for i := 1 to sgCurva.RowCount - 1 do
        begin
          sgCurva.Cells[0, i] := FloatToStrF(xmin + (i - 1) * diffX, ffFixed, 8, 3);
          sgCurva.Cells[1, i] := '0';
        end;

      guardado := False;
    end;
  end;
end;

procedure TEditarFVectR.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

procedure TEditarFVectR.BExportar_odsClick(Sender: TObject);
begin
  uopencalcexportimport.exportarTablaAODS_2( sgCurva, BImportar_ods, nil);
end;

procedure TEditarFVectR.BGuardarClick(Sender: TObject);
var
  i: integer;
  yval: TDAOfNReal;
begin
  if validarFormulario then
  begin
    SetLength( yval, sgCurva.RowCount - 1);
    for i := 1 to sgCurva.RowCount - 1 do
      yval[i - 1] := StrToFloat(sgCurva.Cells[1, i]);
    curva.vector.Copy( yval );
    curva.xmin:= xmin;
    curva.xmax:= xmax;
    curva.inicializar;
    ModalResult := mrOk;
  end;
end;

procedure TEditarFVectR.BImportar_odsClick(Sender: TObject);
begin
  uopencalcexportimport.importarTablaDesdeODS_2( sgCurva,
    BImportar_ods, nil, True, False);
end;

procedure TEditarFVectR.FormCreate(Sender: TObject);
begin
  guardado := True;
  utilidades.AutoSizeCol(sgCurva, 0);
  utilidades.AutoSizeCol(sgCurva, 1);
end;

initialization
end.
