unit DrawObjectsExtended;
{$IFDEF LCL}
{$mode delphi}{$H+}
{$ENDIF}
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
{ Module:          DrawObjectsExtended                                         }
{ Description:     DrawObject Classes derived from classes providing additional}
{                  complex functionality: composition, free or locked          }
{                  connection but not only to centers.                         }
{ Compiler:        Lazarus 0.9.29 / FPC 2.3.1                                  }
{ Version:         0.1                                                         }
{ The Original Code is DrawObjectsExtended.pas                                 }
{                                                                              }
{******************************************************************************}
interface

uses
  Classes, SysUtils, Controls, Graphics, DrawObjectsBase;

type

  { TDrawObjectComposite }

  TDrawObjectComposite = class( TSolid)
    private
      xmin, ymin, xmax, ymax: integer;
      targetParent: TControl;
    protected
      procedure DrawObject(Canvas: TCanvas; IsShadow: boolean); override;
      procedure GroupDrawObjects(drawObjectComponents: array of TDrawObject); virtual;
      procedure ExtendGroup( aDraw: TDrawObject);
      function CheckDrawObjectGroup(drawObjectComponents: array of TDrawObject): boolean; virtual;

      { DONE -oTC -cExtension : Move and Resize are dealt with in the
        ChangeBounds procedure, with calls to ChangeChildrenBounds as
        necessary. }
      procedure ChangeBounds(ALeft, ATop, AWidth, AHeight: integer); override;

      //update the children in a homothetic manner. This can be overriden in descendent classes.
      procedure ChangeChildrenBounds( OldBounds, NewBounds: TRect); virtual;
      procedure ChangeChildBounds( aChild:TControl; OldBounds, NewBounds: TRect); virtual;

    public
      constructor Create(AnOwner: TComponent); override; overload;
      constructor Create(AnOwner: TComponent;
        drawObjectComponents: array of TDrawObject); virtual; overload;
      destructor Destroy; override;
  end;

implementation

{ TDrawObjectComposite }

procedure TDrawObjectComposite.DrawObject(Canvas: TCanvas; IsShadow: boolean);
var
  iComp : Integer;
  aComp : TComponent;
  aDrawComp: TDrawObject;
begin
  //{ DONE -oTC -cExtension : draw components + overall control lines}
  //for iComp := 0 to ComponentCount-1 do
  //begin
  //  aComp := Components[ iComp];
  //  if aComp is TDrawObject then
  //  begin
  //    aDrawComp := TDrawObject(aComp);
  //    aDrawComp.DrawObject( Canvas, IsShadow);
  //  end;
  //end;
end;

procedure TDrawObjectComposite.GroupDrawObjects(
  drawObjectComponents: array of TDrawObject);
var
  iDraw: integer;
  aDraw: TDrawObject;
begin
  if not CheckDrawObjectGroup( drawObjectComponents) then Exit;

  // set up the group
  Parent  := targetParent as TWinControl;
  Left    := xmin;
  Top     := ymin;
  Width   := xmax-xmin;
  Height  := ymax-ymin;
  Focused := true;
  BringToFront;

  //get the individual components in
  for iDraw := low(drawObjectComponents) to high(drawObjectComponents) do
  begin
    aDraw := drawObjectComponents[iDraw];
    //aDraw.Parent := self;
    aDraw.Owner.RemoveComponent(aDraw);
    Self.InsertComponent( aDraw);

    //aDraw.CanMove := false;
    aDraw.Focused  := false;
    aDraw.CanFocus := false;

    // Need to control the events and send them to the object.
    { TODO -oTC -cExtension : Add the events here on components }
  end;

  //Redraw self
  CalcMargin;
  BtnPoints[0] := Point(Margin, Margin);
  BtnPoints[1] := Point(width-Margin, height-Margin);
  ResizeNeeded;
end;

procedure TDrawObjectComposite.ExtendGroup(aDraw: TDrawObject);
var
  x1, y1, x2, y2 : integer;
begin
  x1 := aDraw.left;
  y1 := aDraw.top;
  x2 := x1 + aDraw.width;
  y2 := y1 + aDraw.height;

  if (x1 < xmin) then
    xmin := x1;
  if (y1 < ymin) then
    ymin := y1;
  if (x2 > xmax) then
    xmax := x2;
  if (y2 > ymax) then
    ymax := y2;
end;

function TDrawObjectComposite.CheckDrawObjectGroup(
  drawObjectComponents: array of TDrawObject): boolean;
var
  iDraw: integer;
  aDraw: TDrawObject;
begin
  result := false;
  xmin := 10000;
  ymin := 10000;
  xmax := 0;
  ymax := 0;
  targetParent := drawObjectComponents[low(drawObjectComponents)].Parent;
  for iDraw := low(drawObjectComponents) to high(drawObjectComponents) do
  begin
    aDraw := drawObjectComponents[iDraw];
    if aDraw.Parent <> targetParent then exit;
    ExtendGroup( aDraw);
  end;
  result := true;
end;

procedure TDrawObjectComposite.ChangeBounds(ALeft, ATop, AWidth,
  AHeight: integer);
var
  OldBounds, NewBounds: TRect;
begin
  OldBounds := Bounds( Left, Top, Width, Height);
  NewBounds := Bounds( ALeft, ATop, AWidth, AHeight);

  inherited ChangeBounds(ALeft, ATop, AWidth, AHeight);

  ChangeChildrenBounds( OldBounds, NewBounds);
end;

procedure TDrawObjectComposite.ChangeChildrenBounds(OldBounds, NewBounds: TRect
  );
var
  iChild: Integer;
  aChild: TComponent;
  aChildControl: TControl;
begin
  for iChild := 0 to ComponentCount-1 do
  begin
    aChild := Components[iChild];
    if aChild is TControl then
    begin
      aChildControl := TControl(aChild);
      ChangeChildBounds( aChildControl, OldBounds, NewBounds);
    end;
  end;
end;

procedure TDrawObjectComposite.ChangeChildBounds(aChild: TControl; OldBounds,
  NewBounds: TRect);
var
  NewLeft, NewTop, NewWidth, NewHeight : Integer;
  dx, dy : integer;
  rx, ry : real;
begin
  dx := NewBounds.Left - OldBounds.Left;
  dy := NewBounds.Top  - OldBounds.Top;
  rx := (NewBounds.Right-NewBounds.Left)/(OldBounds.Right-OldBounds.Left);
  ry := (NewBounds.Bottom-NewBounds.Top)/(OldBounds.Bottom-OldBounds.Top);

  NewLeft := round((aChild.Left - OldBounds.Left) * rx) + NewBounds.Left;
  NewTop  := round((aChild.Top  - OldBounds.Top)  * ry) + NewBounds.Top;
  NewWidth := round(aChild.Width * rx);
  NewHeight := round(aChild.Height * ry);
  aChild.SetBounds( NewLeft, NewTop, NewWidth, NewHeight);
end;

constructor TDrawObjectComposite.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
end;

constructor TDrawObjectComposite.Create(AnOwner: TComponent;
  drawObjectComponents: array of TDrawObject);
begin
  Create( anOwner);
  GroupDrawObjects(drawObjectComponents);
end;

destructor TDrawObjectComposite.Destroy;
begin
  inherited Destroy;
end;

end.

