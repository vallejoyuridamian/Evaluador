unit uEditarArrayOfFVectR;

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
  Dialogs, StdCtrls, Grids, xmatdefs, uFuncionesReales, uBaseFormularios, utilidades,
  uBaseEditores, uConstantesSimSEE, uOpcionesSimSEEEdit,
  uopencalc,
  uopencalcexportimport;

type
  TEditarArrayOfFVectR = class(TBaseEditores)
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
    curvas: TArrayOfFVectR;
  protected
    function validarFormulario: boolean; override;
  public
    constructor Create(AOwner: TForm; xmin, xmax: NReal; nPuntosDiscIni: integer;
      ejeX: string; ejeY: array of string); reintroduce; overload;
    constructor Create(AOwner: TForm; xmin, xmax: NReal;
      f: TArrayOfFVectR; ejeX: string; ejeY: array of string); reintroduce; overload;
    function darCurva(k: integer): TFVectR;
  end;

implementation

uses Math;

  {$R *.lfm}

constructor TEditarArrayOfFVectR.Create(AOwner: TForm; xmin, xmax: NReal;
  nPuntosDiscIni: integer; ejeX: string; ejeY: array of string);
var
  i: integer;
begin
  inherited Create(AOwner, nil, nil );
  self.Top := AOwner.Top + plusTop;
  self.Left := AOwner.Left + plusLeft;
  self.xmin := xmin;
  self.xmax := xmax;
  diffX := (xmax - xmin) / (nPuntosDiscIni - 1);
  curvas := nil;
  ENDisc.Text := IntToStr(nPuntosDiscIni);
  sgCurva.RowCount := nPuntosDiscIni + 1;
  sgCurva.ColCount := length(ejeY);
  sgCurva.Cells[0, 0] := ejeX;
  for i := 0 to high(ejeY) do
    sgCurva.Cells[i + 1, 0] := ejeY[i];
  self.Caption := 'Editar funciones de ' + ejeX;
  for i := 1 to nPuntosDiscIni do
  begin
    sgCurva.Cells[0, i] := FloatToStrF(xmin + (i - 1) * diffX, ffFixed, 8, 3);
    sgCurva.Cells[1, i] := '0';
  end;
end;

constructor TEditarArrayOfFVectR.Create(AOwner: TForm;
  xmin, xmax: NReal; f: TArrayOfFVectR; ejeX: string; ejeY: array of string);
var
  i: integer;
  k: integer;
  nPuntos, nCurvas: integer;
begin
  inherited Create(AOwner, nil, nil );
  self.xmin := xmin;
  self.xmax := xmax;
  nPuntos := f[0].vector.n;
  nCurvas := length(f);
  diffX := (xmax - xmin) / (nPuntos - 1);
  ENDisc.Text := IntToStr(nPuntos);
  sgCurva.RowCount := nPuntos + 1;
  sgCurva.ColCount := nCurvas + 1;
  sgCurva.Cells[0, 0] := ejeX;
  for k := 0 to high(ejeY) do
    sgCurva.Cells[k + 1, 0] := ejeY[k];
  self.Caption := 'Editar funciones de ' + ejeX;

  for i := 1 to nPuntos do
  begin
    sgCurva.Cells[0, i] := FloatToStrF(xmin + (i - 1) * diffX, ffFixed, 8, 3);
    for k := 1 to nCurvas do
      sgCurva.Cells[k, i] := FloatToStr(f[k - 1].vector.e(i));
  end;

end;

function TEditarArrayOfFVectR.darCurva(k: integer): TFVectR;
begin
  Result := curvas[k];
end;

function TEditarArrayOfFVectR.validarFormulario: boolean;
begin
  Result := validarEditInt(ENDisc, 1, MAXINT) and validarTablaNReals_(sgCurva);
end;

procedure TEditarArrayOfFVectR.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarArrayOfFVectR.EditTamTablaExit(Sender: TObject);
var
  nAnt, n, i: integer;
begin
  if validarEditInt(TEdit(Sender), 1, MAXINT) then
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

procedure TEditarArrayOfFVectR.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

procedure TEditarArrayOfFVectR.BExportar_odsClick(Sender: TObject);
begin
  exportarTablaAODS_2( sgCurva, BImportar_ods, nil);
end;

procedure TEditarArrayOfFVectR.BGuardarClick(Sender: TObject);
var
  yval: TDAofNReal;
  nPuntos, nCurvas: integer;
  iPunto, kCurva: integer;
begin
  setlength(curvas, sgCurva.ColCount - 1);
  if validarFormulario then
  begin
    nPuntos := sgCurva.RowCount - 1;
    nCurvas := sgCurva.ColCount - 1;
    SetLength(yval, nPuntos);
    for kCurva := 1 to nCurvas do
    begin
      for iPunto := 1 to nPuntos do
        yval[iPunto - 1] := StrToFloat(sgCurva.Cells[kCurva, iPunto]);
      curvas[kCurva - 1] := TFVectR.Create(capa, yval, xmin, xmax);
    end;
    ModalResult := mrOk;
  end;
end;

procedure TEditarArrayOfFVectR.BImportar_odsClick(Sender: TObject);
begin
  importarTablaDesdeODS_2(sgCurva,
    BImportar_ods, nil, True, False);
end;

procedure TEditarArrayOfFVectR.FormCreate(Sender: TObject);
begin
  guardado := True;
  utilidades.AutoSizeCol(sgCurva, 0);
end;



initialization
end.
