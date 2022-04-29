unit TDOMainForm;
{******************************************************************************}
{ DrawObjectsExtended Component                                                }
{ This component can be downloaded at www.tcoq.org, component page.            }
{                                                                              }
{ The contents of this file are subject to the Mozilla Public License Version  }
{ 1.1 (the "License"); you may not use this file except in compliance with the }
{ License. You may obtain a copy of the License at http://www.mozilla.org/MPL/ }
{                                                                              }
{ Software distributed under the License is distributed on an "AS IS" basis,   }
{ WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for }
{ the specific language governing rights and limitations under the License.    }
{                                                                              }
{ The Initial Developer of the Original Code is Thierry.Coq                    }
{ thierry.coq(at)centraliens.net                                               }
{ Portions created by this individual are Copyright (C)2009 T. Coq             }
{                                                                              }
{ Last modified:   2009/10/24                                                  }
{ Description:     Main form for testing DrawObjectsExtended behaviour         }
{ Compiler:        Lazarus 0.9.29 / FPC 2.3.1                                  }
{ Version:         0.1                                                         }
{ The Original Code is TDOMainForm.pas                                         }
{                                                                              }
{******************************************************************************}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls, ActnList, Menus, DrawObjectsBase, DrawObjects,
  DrawObjectsExtended;

type

  { TFormTestDrawObjects }

  TFormTestDrawObjects = class(TForm)
    ActionNewTestGraphicControl: TAction;
    ActionClearFocus: TAction;
    ActionNewComposite: TAction;
    ActionConnectedZLine: TAction;
    ActionNewSpecificObjects: TAction;
    ActionZoom: TAction;
    ActionConnectedLine: TAction;
    ActionNewPolygon: TAction;
    ActionNewLLine: TAction;
    ActionNewOtherObjects: TAction;
    ActionNewBezier: TAction;
    ActionNewArc: TAction;
    ActionNewEllipse: TAction;
    ActionClearDrawing: TAction;
    ActionList: TActionList;
    BtnNewArc: TButton;
    BtnNewBezier: TButton;
    BtnNewObject: TButton;
    BtnNewObject1: TButton;
    BtnNewObject10: TButton;
    BtnNewObject11: TButton;
    BtnNewObject12: TButton;
    BtnNewObject2: TButton;
    BtnNewObject3: TButton;
    BtnNewObject4: TButton;
    BtnNewObject5: TButton;
    BtnNewObject6: TButton;
    BtnNewObject7: TButton;
    BtnNewObject8: TButton;
    BtnNewObject9: TButton;
    BtnNewOtherObjects: TButton;
    BtnNewRectangle: TButton;
    BtnNewEllipse: TButton;
    BtnRecordResult: TButton;
    Button1: TButton;
    Label1: TLabel;
    LblMessage: TLabel;
    MainMenu: TMainMenu;
    MenuItemAbout: TMenuItem;
    PaintBoxDraw: TPaintBox;
    PanelTop: TPanel;
    PanelLeft: TPanel;
    ScrollBoxMain: TScrollBox;
    procedure ActionClearDrawingExecute(Sender: TObject);
    procedure ActionClearFocusExecute(Sender: TObject);
    procedure ActionConnectedLineExecute(Sender: TObject);
    procedure ActionConnectedZLineExecute(Sender: TObject);
    procedure ActionNewArcExecute(Sender: TObject);
    procedure ActionNewBezierExecute(Sender: TObject);
    procedure ActionNewCompositeExecute(Sender: TObject);
    procedure ActionNewEllipseExecute(Sender: TObject);
    procedure ActionNewLLineExecute(Sender: TObject);
    procedure ActionNewOtherObjectsExecute(Sender: TObject);
    procedure ActionNewPolygonExecute(Sender: TObject);
    procedure ActionNewSpecificObjectsExecute(Sender: TObject);
    procedure ActionNewTestGraphicControlExecute(Sender: TObject);
    procedure ActionZoomExecute(Sender: TObject);
    procedure BtnNewEllipseClick(Sender: TObject);
    procedure BtnNewObject5Click(Sender: TObject);
    procedure BtnNewRectangleClick(Sender: TObject);
    procedure BtnRecordResultClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure MenuItemAboutClick(Sender: TObject);
    procedure PaintBoxDrawClick(Sender: TObject);
  private
    FDrawObject: TDrawObject;
    FResultBitmap: TBitmap;
    { private declarations }
    SelPt: TPoint;
    ZoneOfInterest: TRect;

    // create objects variables
    newDrawObject : TDrawObject;
    pos : TPoint;
    newGraphicControl: TGraphicControl;

    // utility procedures
    Function GetBitmapRecordFileName: String;
    Function Rect2Str(const aRect: TRect): String;
    Function Draw2Str(aDraw: TDrawObject): String;

    //procedures to load objects into the graph.
    procedure DrawObjMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure DrawObjMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure DrawObjMouseUp(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure DrawObjDblClick(Sender: TObject);
    procedure DrawObjLoaded(Sender: TObject);

    procedure InitializeDrawObject(anObject: TDrawObject; Pt: TPoint);
    procedure SetResultBitmap(const AValue: TBitmap);
  public
    { public declarations }
    property ResultBitmap: TBitmap read FResultBitmap write SetResultBitmap;
    procedure CreateTestGraphicControl;
    procedure CreateRectangle;
    procedure CreateEllipse;
    procedure CreateArc;
    procedure CreateBezier;
    // Diamond, Line, LLine, Polygon, RandomPoly, SolidArrow, SolidBezier,
    // SolidPoint, Star, Text, TextBezier, ZLine, DrawPicture
    procedure CreateDiamond;
    procedure CreateLine;
    procedure CreateLLine;
    procedure CreatePolygon;
    procedure CreateRandomPoly;
    procedure CreateSolidArrow;
    procedure CreateSolidBezier;
    procedure CreateSolidPoint;
    procedure CreateStar;
    procedure CreateText;
    procedure CreateTextBezier;
    procedure CreateZLine;
    procedure CreateDrawPicture;

    procedure CreateDrawObject( aClass: TDrawObjectClass; x, y : integer);
    procedure CreateLinkObject( aLinkClass: TConnectorClass; x1, y1, x2, y2: integer);
    function RecordResults: String;
    function RecordBitmap: TBitmap;
    procedure ClearDrawing;
  end; 

var
  FormTestDrawObjects: TFormTestDrawObjects;

implementation

uses
  TestGraphicControl, TDOAboutBox;

{ TFormTestDrawObjects }

procedure TFormTestDrawObjects.BtnNewRectangleClick(Sender: TObject);
begin
  CreateRectangle;
end;

procedure TFormTestDrawObjects.ActionClearDrawingExecute(Sender: TObject);
begin
  ClearDrawing;
end;

procedure TFormTestDrawObjects.ActionClearFocusExecute(Sender: TObject);
var
  iDraw: integer;
  aDraw: TDrawObject;
begin
  with ScrollBoxMain do
    for iDraw := 0 to controlCount -1 do
      if (Controls[iDraw] is TDrawObject) then
      begin
        aDraw := (Controls[iDraw] as TDrawObject);
        aDraw.Focused := False;
      end;
end;

procedure TFormTestDrawObjects.ActionConnectedLineExecute(Sender: TObject);
begin
  CreateLinkObject( TLine, 10, 10, 210, 210);
end;

procedure TFormTestDrawObjects.ActionConnectedZLineExecute(Sender: TObject);
var
  line: TConnector;
begin
  CreateLinkObject( TZLine, 10, 10, 210, 210);
  line := newDrawObject as TConnector;
  line.Arrow1 := true;
end;

procedure TFormTestDrawObjects.ActionNewArcExecute(Sender: TObject);
begin
  CreateArc;
end;

procedure TFormTestDrawObjects.ActionNewBezierExecute(Sender: TObject);
begin
  CreateBezier;
end;

procedure TFormTestDrawObjects.ActionNewCompositeExecute(Sender: TObject);
var
  iDraw: integer;
  aDraw: TDrawObject;
  NbrDraw: integer;
  aDrawList : array of TDrawObject;
begin
  ActionConnectedZLineExecute(self);
  NbrDraw := 0;
  with ScrollBoxMain do
    for iDraw := 0 to controlCount -1 do
      if (Controls[iDraw] is TDrawObject) then
      begin
         aDraw := (Controls[iDraw] as TDrawObject);
         aDraw.Focused := true;
         inc(NbrDraw);
      end;

  // Create the list of objects to group.
  SetLength(aDrawList, NbrDraw);
  NbrDraw := 0;
  with ScrollBoxMain do
    for iDraw := 0 to controlCount -1 do
      if (Controls[iDraw] is TDrawObject) then
        if (Controls[iDraw] as TDrawObject).Focused then
        begin
          aDrawList[NbrDraw] := TDrawObject(Controls[iDraw]);
          inc(NbrDraw);
        end;

  newDrawObject := TDrawObjectComposite.Create( Self, aDrawList);
  MakeNameForControl( newDrawObject);
  DrawObjLoaded( newDrawObject);
  LblMessage.Caption := Draw2Str( newDrawObject);
end;

procedure TFormTestDrawObjects.ActionNewEllipseExecute(Sender: TObject);
begin
  CreateEllipse;
end;

procedure TFormTestDrawObjects.ActionNewLLineExecute(Sender: TObject);
var
  line : TConnector;
begin
  CreateLLine;
  line := newDrawObject as TConnector;
  line.Arrow1 := true;
end;

procedure TFormTestDrawObjects.ActionNewOtherObjectsExecute(Sender: TObject);
begin
  CreateDiamond;
  CreateLine;
  CreateLLine;
  CreateSolidArrow;
  CreateSolidBezier;
  CreateSolidPoint;
  CreateText;
  CreatePolygon;
  CreateRandomPoly;
  CreateStar;
end;

procedure TFormTestDrawObjects.ActionNewPolygonExecute(Sender: TObject);
begin
  CreatePolygon;
end;

procedure TFormTestDrawObjects.ActionNewSpecificObjectsExecute(Sender: TObject);
begin
  CreateTextBezier;
  CreateZLine;
  CreateDrawPicture;
end;

procedure TFormTestDrawObjects.ActionNewTestGraphicControlExecute(
  Sender: TObject);
begin
  CreateTestGraphicControl ;
end;

procedure TFormTestDrawObjects.ActionZoomExecute(Sender: TObject);
begin
  CreateRectangle;
  newDrawObject.BeginTransform;
  newDrawObject.Zoom(50);
  newDrawObject.EndTransform;
end;

procedure TFormTestDrawObjects.BtnNewEllipseClick(Sender: TObject);
begin

end;

procedure TFormTestDrawObjects.BtnNewObject5Click(Sender: TObject);
begin

end;

procedure TFormTestDrawObjects.BtnRecordResultClick(Sender: TObject);
begin
  RecordResults;
end;

procedure TFormTestDrawObjects.FormCreate(Sender: TObject);
begin
  ScrollBoxMain.DoubleBuffered:=true;
end;

procedure TFormTestDrawObjects.MenuItemAboutClick(Sender: TObject);
begin
  FormAbout.Show;
end;

procedure TFormTestDrawObjects.PaintBoxDrawClick(Sender: TObject);
begin

end;

function TFormTestDrawObjects.GetBitmapRecordFileName: String;
var
  FileName : string;
  FileNo : integer;
  ApplicationName: String;
  ApplicationPath: String;
begin
  ApplicationName := ExtractFileName( ParamStr(0) );
  ApplicationPath := ExtractFilePath( ParamStr(0) );
  ApplicationName := ChangeFileExt( ApplicationName, '');
  FileName := ApplicationPath + ApplicationName + '.bmp' ;
  FileNo := 0;
  while FileExists( FileName ) do
  begin
    inc( FileNo );
    FileName := ApplicationPath + ApplicationName + IntToStr( FileNo ) + '.bmp';
  end;
  result := FileName;
end;

function TFormTestDrawObjects.Rect2Str(const aRect: TRect): String;
begin
  result := 'L: '+IntToStr(aRect.Left) + ', T: '+ IntToStr(aRect.Top) +
            ', R: ' + IntToStr(aRect.Right) + ', B: ' + IntToStr(aRect.Bottom);
end;

function TFormTestDrawObjects.Draw2Str(aDraw: TDrawObject): String;
var
  aRect: TRect;
begin
  result := '';
  if not assigned(aDraw) then Exit;
  aRect.Left   := aDraw.Left;
  aRect.Top    := aDraw.Top;
  aRect.Right  := aDraw.Left + aDraw.Width;
  aRect.Bottom := aDraw.Top + aDraw.Height;
  result := Rect2Str( aRect);
end;

procedure TFormTestDrawObjects.DrawObjMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin

end;

procedure TFormTestDrawObjects.DrawObjMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin

end;

procedure TFormTestDrawObjects.DrawObjMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin

end;

procedure TFormTestDrawObjects.DrawObjDblClick(Sender: TObject);
begin

end;

procedure TFormTestDrawObjects.DrawObjLoaded(Sender: TObject);
begin
  with TDrawObject(Sender) do
  begin
    OnMouseDown := @DrawObjMouseDown;
    OnMouseMove := @DrawObjMouseMove;
    OnMouseUp := @DrawObjMouseUp;
    OnDblClick := @DrawObjDblClick;
    //TCQ CanFocus := not DisableDesigning1.Checked;
    //Focused := CanFocus;
    //if Sender is TBaseLine then
    //  TBaseLine(Sender).UseHitTest := UseHitTest1.Checked;
    //
    ////if pasting from the clipboard, offset new objects slightly ...
    //if fPastingFromClipboard then
    //begin
    //  left := left + 10;
    //  top := top + 10;
    //end;
  end;
end;

procedure TFormTestDrawObjects.InitializeDrawObject(anObject: TDrawObject; Pt: TPoint);
begin
  //identify the new object:
  MakeNameForControl( anObject);

  //set up the draw object in the screen.
  anObject.parent := ScrollBoxMain;
  DrawObjLoaded(anObject);

  with ScrollBoxMain.ScreenToClient(Pt) do
  begin
    anObject.Left := X;
    anObject.Top := Y;
  end;
end;

procedure TFormTestDrawObjects.SetResultBitmap(const AValue: TBitmap);
begin
  if FResultBitmap=AValue then exit;
  FResultBitmap:=AValue;
end;

procedure TFormTestDrawObjects.CreateTestGraphicControl;
begin
  pos.X := 10;
  pos.Y := 10;
  SelPt.X := ScrollBoxMain.Left+pos.X;
  SelPt.Y := ScrollBoxMain.Top+pos.Y;
  SelPt  := ClientToScreen(SelPt);
  newGraphicControl := TTestGraphicControl.Create(ScrollBoxMain);

  newGraphicControl.Left := Pos.X;
  newGraphicControl.Top := Pos.Y;
  newGraphicControl.Width := 100;
  newGraphicControl.Height := 100;
  newGraphicControl.Canvas.pen.color := clBlack;
  newGraphicControl.Canvas.pen.style := psDashDot;
  newGraphicControl.Canvas.pen.width := 3;
  newGraphicControl.Color := clBtnFace;
  newGraphicControl.Parent := ScrollBoxMain;
  newGraphicControl.Visible := true;

  Pos := Self.ScreenToClient( SelPt);
  ZoneOfInterest.Left:= pos.X;
  ZoneOfInterest.Top := pos.Y;
  ZoneOfInterest.Right := ZoneOfInterest.Left + newGraphicControl.Width;
  ZoneOfInterest.Bottom := ZoneOfInterest.Top + newGraphicControl.Height;
  LblMessage.Caption := Rect2Str( ZoneOfInterest);

end;

procedure TFormTestDrawObjects.CreateRectangle;
begin
  CreateDrawObject( TRectangle, 10, 10);
end;

procedure TFormTestDrawObjects.CreateEllipse;
begin
  CreateDrawObject( TEllipse, 10, 120);
end;

procedure TFormTestDrawObjects.CreateArc;
begin
  CreateDrawObject( TArc, 10, 230);
  (newDrawObject as TArc).Angle1 := 0;
  (newDrawObject as TArc).Angle2 := 30;
end;

procedure TFormTestDrawObjects.CreateBezier;
begin
  CreateDrawObject( TBezier, 10, 340);
end;

procedure TFormTestDrawObjects.CreateDiamond;
begin
  CreateDrawObject( TDiamond, 10, 450);
end;

procedure TFormTestDrawObjects.CreateLine;
begin
  CreateDrawObject( TLine, 120, 10);
end;

procedure TFormTestDrawObjects.CreateLLine;
begin
  CreateDrawObject( TLLine, 120, 120);
end;

procedure TFormTestDrawObjects.CreatePolygon;
begin
  CreateDrawObject( TPolygon, 120, 230);
end;

procedure TFormTestDrawObjects.CreateRandomPoly;
begin
  CreateDrawObject( TRandomPoly, 120, 340);
end;

procedure TFormTestDrawObjects.CreateSolidArrow;
begin
  CreateDrawObject( TSolidArrow, 120, 450);
end;

procedure TFormTestDrawObjects.CreateSolidBezier;
begin
  CreateDrawObject( TSolidBezier, 230, 10);
end;

procedure TFormTestDrawObjects.CreateSolidPoint;
begin
  CreateDrawObject( TSolidPoint, 230, 120);
end;

procedure TFormTestDrawObjects.CreateStar;
begin
  CreateDrawObject( TStar, 230, 230);
end;

procedure TFormTestDrawObjects.CreateText;
begin
  CreateDrawObject( TText, 230, 340);
  (newDrawObject as TText).Strings.Text := 'Example';
end;

procedure TFormTestDrawObjects.CreateTextBezier;
begin
  CreateDrawObject( TTextBezier, 230, 450);
  (newDrawObject as TTextBezier).Text := 'Bezier Example';
end;

procedure TFormTestDrawObjects.CreateZLine;
begin
  CreateDrawObject( TZLine, 340, 10);
end;

procedure TFormTestDrawObjects.CreateDrawPicture;
begin
  CreateDrawObject( TDrawPicture, 340, 110);
end;

procedure TFormTestDrawObjects.CreateDrawObject(aClass: TDrawObjectClass; x, y : integer);
begin
  pos.X := x;
  pos.Y := y;
  SelPt.X := ScrollBoxMain.Left+pos.X;
  SelPt.Y := ScrollBoxMain.Top+pos.Y;
  SelPt  := ClientToScreen(SelPt);
  newDrawObject := aClass.Create(ScrollBoxMain);

  newDrawObject.pen.color := clBlack;
  newDrawObject.Color := clWhite;
  newDrawObject.ColorShadow := clNone;
  InitializeDrawObject(newDrawObject, SelPt);

  Pos := Self.ScreenToClient( SelPt);
  ZoneOfInterest.Left:= pos.X;
  ZoneOfInterest.Top := pos.Y;
  ZoneOfInterest.Right := ZoneOfInterest.Left + newDrawObject.Width;
  ZoneOfInterest.Bottom := ZoneOfInterest.Top + newDrawObject.Height;
  LblMessage.Caption := Rect2Str( ZoneOfInterest);
end;

procedure TFormTestDrawObjects.CreateLinkObject(aLinkClass: TConnectorClass;
  x1, y1, x2, y2 : integer);
var
  obj1, obj2 : TSolid;
  line : TConnector;
begin
  CreateDrawObject(TRectangle, x1, y1);
  obj1 := newDrawObject as TSolid;
  CreateDrawObject(TRectangle, x2, y2);
  obj2 := newDrawObject as TSolid;
  CreateDrawObject(aLinkClass, x1, y1);
  line := newDrawObject as TConnector;
  line.Connection1 := obj1;
  line.Connection2 := obj2;
  line.SendToBack;
end;

function TFormTestDrawObjects.RecordResults : String;
var
  newBitmap: TBitmap;
  fileName: String;
begin
  newBitmap := RecordBitmap;
  try
    fileName := GetBitmapRecordFileName;
    result := fileName;
    newBitmap.SaveToFile( fileName);
  finally
    freeAndNil(NewBitmap);
  end;
end;

function TFormTestDrawObjects.RecordBitmap: TBitmap;
var
  newBitmap: TBitmap;
  bitmapRect: TRect;
begin
  newBitmap := TBitmap.Create;
  result := newBitmap;
  newBitmap.Width := ZoneOfInterest.Right - ZoneOfInterest.Left +1;
  newBitmap.Height := ZoneOfInterest.Bottom - ZoneOfInterest.Top +1;

  LblMessage.Caption := Rect2Str( ZoneOfInterest);

  bitmapRect.Left := 0;
  bitmapRect.Top  := 0;
  bitmapRect.Right := newBitmap.Width;
  bitmapRect.Bottom := newBitmap.Height;

  newBitmap.Canvas.CopyRect( bitmapRect,  Self.Canvas, ZoneOfInterest);
end;

procedure TFormTestDrawObjects.ClearDrawing;
var
  i: integer;
  finished: boolean;
begin
  finished := false;
  with ScrollBoxMain do
    while not finished do
      for i := controlCount -1 downto 0  do
      begin
        finished := true;
        if Controls[i] is TDrawObject then
        begin
          TDrawObject(Controls[i]).Free;
          finished := false;
          break;
        end;
      end;
end;

initialization
  {$I TDOMainForm.lrs}

end.

