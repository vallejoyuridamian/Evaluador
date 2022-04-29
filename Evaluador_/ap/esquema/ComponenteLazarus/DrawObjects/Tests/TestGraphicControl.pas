unit TestGraphicControl;
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
{ Description:     Test GraphicControl class to check some DrawObjectsExtended }
{                  behaviour. Checks transparency in particular.               }
{ Compiler:        Lazarus 0.9.29 / FPC 2.3.1                                  }
{ Version:         0.1                                                         }
{ The Original Code is TestGraphicControl.pas                                  }
{                                                                              }
{******************************************************************************}

{$mode objfpc}{$H+}

interface


uses
  Classes, SysUtils, Controls, Graphics;

type

  { TTestGraphicControl }

  TTestGraphicControl = class(TGraphicControl)
    private
      fBitmap:TBitmap;
    protected
      procedure Paint; override;
    public
      constructor Create(anOwner:TComponent); override;
  end;

implementation

{ TTestGraphicControl }

procedure TTestGraphicControl.Paint;
var
  pts: array [1..3] of TPoint;
begin
  pts[1].x := 0;
  pts[1].y := 0;
  pts[2].x := 0;
  pts[2].y := 100;
  pts[3].x := 50;
  pts[3].y := 50;

  //Canvas.Line(0, 0, width-1, height-1);
  Canvas.Polyline( pts);
  Canvas.Draw(0, 0, fBitmap);

end;

constructor TTestGraphicControl.Create(anOwner: TComponent);
begin
  inherited Create(anOwner);
  fBitmap := TBitmap.Create;
  fBitmap.Transparent:=true;
  fBitmap.TransparentColor:=clRed;
  fBitmap.TransparentMode:=tmFixed;
  fBitmap.Width := 100;
  fBitmap.Height:= 100;
  fBitmap.canvas.brush.Color := fBitmap.TransparentColor;
  fBitmap.canvas.FillRect(0, 0, 100, 100);
end;

end.

