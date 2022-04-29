unit TDOAboutBox;
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
{ Description:     About box for the Test GUI for DrawObjectsExtended          }
{ Compiler:        Lazarus 0.9.29 / FPC 2.3.1                                  }
{ Version:         0.1                                                         }
{ The Original Code is TDOAboutBox.pas                                         }
{                                                                              }
{******************************************************************************}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls;

type

  { TFormAbout }

  TFormAbout = class(TForm)
    MemoAbout: TMemo;
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  FormAbout: TFormAbout;

implementation

initialization
  {$I TDOAboutBox.lrs}

end.

