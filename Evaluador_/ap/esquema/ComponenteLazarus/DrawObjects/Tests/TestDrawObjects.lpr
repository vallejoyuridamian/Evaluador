program TestDrawObjects;
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
{ Compiler:        Lazarus 0.9.29 / FPC 2.3.1                                  }
{ Version:         0.1                                                         }
{ Description:     Lazarus application for testing DrawObjectsExtended         }
{ The Original Code is TestDrawObjects.lpr                                     }
{                                                                              }
{******************************************************************************}

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, TDOMainForm, LResources, GuiTestRunner, TDOTestCasesDrawObjects, TestGraphicControl, TDOAboutBox, DrawObjects, DrawObjectsBase, DrawObjectsExtended
  { you can add units after this };

{$IFDEF WINDOWS}{$R TestDrawObjects.rc}{$ENDIF}

begin
  {$I TestDrawObjects.lrs}
  Application.Initialize;
  Application.CreateForm(TGuiTestRunner, TestRunner);
  Application.CreateForm(TFormTestDrawObjects, FormTestDrawObjects);
  FormTestDrawObjects.Show;
  Application.CreateForm(TFormAbout, FormAbout);
  Application.Run;
end.

