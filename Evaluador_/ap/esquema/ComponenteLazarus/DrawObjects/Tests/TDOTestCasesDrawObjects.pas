unit TDOTestCasesDrawObjects;
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
{ Description:     Test cases for DrawObjectsExtended.                         }
{ Compiler:        Lazarus 0.9.29 / FPC 2.3.1                                  }
{ Version:         0.1                                                         }
{ The Original Code is TDOTestCasesDrawObjcts.pas                              }
{                                                                              }
{******************************************************************************}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testutils, testregistry, TDOMainForm;

Type
  { TTestCaseDrawObjects }
  TTestCaseDrawObjects= class(TTestCase)
    private
    protected
      procedure SetUp; override;
      procedure TearDown; override;
      function GetReferenceBitmapDirectory: String;
    public
      Constructor Create; override;
      Destructor Destroy; override;
    published
      procedure Test01_Rectangle;
      procedure Test02_Ellipse;
  end;

implementation

uses
  Graphics,
//  GraphicUtilities,
  Forms;
{ TTestCaseDrawObjects }

const
   BitmapDirectory = 'Reference Bitmaps';

procedure TTestCaseDrawObjects.SetUp;
begin
  FormTestDrawObjects.ClearDrawing;
  Application.ProcessMessages;
end;

procedure TTestCaseDrawObjects.TearDown;
begin
  FormTestDrawObjects.ClearDrawing;
  Application.ProcessMessages;
end;

function TTestCaseDrawObjects.GetReferenceBitmapDirectory: String;
Const
  MaxDirs = 129;
var
  appPath: String;
  appDrive: String;
  dirs : Array[1..MaxDirs] of PChar;
  iDir : integer;
  DirNbr: Integer;
begin
  appPath := ExtractFilePath( ParamStr(0) );
  appDrive := ExtractFileDrive( appPath);
  DirNbr := GetDirs(appPath, dirs);
  appPath := AppDrive;
  for iDir := 1 to DirNbr-1 do
    appPath := appPath + '\'+dirs[iDir];
  appPath := appPath + '\' + BitmapDirectory;
  result := appPath;
end;

constructor TTestCaseDrawObjects.Create;
begin
  inherited Create;
end;

destructor TTestCaseDrawObjects.Destroy;
begin
  inherited Destroy;
end;


procedure TTestCaseDrawObjects.Test01_Rectangle;
var
  bm1, bm2 : TBitmap;
  aFileName : String;
  TotalPixels, NbrDifferences: Integer;
  TestSuccessful:Boolean;
begin
  FormTestDrawObjects.BringToFront;
  FormTestDrawObjects.CreateRectangle;
  Application.ProcessMessages;
  bm2 := TBitmap.Create;
  try
    bm1 := FormTestDrawObjects.RecordBitmap;
    Application.ProcessMessages;
    aFileName :=  GetReferenceBitmapDirectory + '\' + 'Test01_Image.bmp';
    bm1.SaveToFile( aFileName);
    bm1.LoadFromFile( aFileName);

    aFileName :=  GetReferenceBitmapDirectory + '\' + 'Test01_Rectangle.bmp';
    bm2.LoadFromFile( aFileName);
    Application.ProcessMessages;

//     TestSuccessful := CompareBitmaps( bm1, bm2, TotalPixels, NbrDifferences);

    //Check(TestSuccessful,'bitmap size: ' + IntToStr(TotalPixels) + ', differences:' + IntToStr(NbrDifferences));
    Check((NbrDifferences/TotalPixels)<0.01,'bitmap size: ' + IntToStr(TotalPixels) + ', differences:' + IntToStr(NbrDifferences));
  finally
    freeAndNil( bm1);
    freeAndNil( bm2);
  end;
end;

procedure TTestCaseDrawObjects.Test02_Ellipse;
var
  bm1, bm2 : TBitmap;
  aFileName : String;
  TotalPixels, NbrDifferences: Integer;
  TestSuccessful:Boolean;
begin
  FormTestDrawObjects.BringToFront;
  FormTestDrawObjects.CreateEllipse;
  Application.ProcessMessages;
  bm2 := TBitmap.Create;
  try
    bm1 := FormTestDrawObjects.RecordBitmap;
    Application.ProcessMessages;
    aFileName :=  GetReferenceBitmapDirectory + '\' + 'Test02_Image.bmp';
    bm1.SaveToFile( aFileName);
    bm1.LoadFromFile( aFileName);

    aFileName :=  GetReferenceBitmapDirectory + '\' + 'Test02_Ellipse.bmp';
    bm2.LoadFromFile( aFileName);
    Application.ProcessMessages;

//    TestSuccessful := CompareBitmaps( bm1, bm2, TotalPixels, NbrDifferences);

    //Check(TestSuccessful,'bitmap size: ' + IntToStr(TotalPixels) + ', differences:' + IntToStr(NbrDifferences));
    Check((NbrDifferences/TotalPixels)<0.01,'bitmap size: ' + IntToStr(TotalPixels) + ', differences:' + IntToStr(NbrDifferences));
  finally
    freeAndNil( bm1);
    freeAndNil( bm2);
  end;
end;

initialization
  RegisterTest(TTestCaseDrawObjects);
end.

