unit ulogoSimSEE;

{$mode delphi}

interface

uses
  Controls,
  FileUtil,

  Classes, SysUtils;


type

  { TDataModule1 }

  TDataModule1 = class(TDataModule)
    logoSimSEE_sr3: TImageList;
    img_logoSimSEE: TImageList;
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  DataModule1: TDataModule1;

procedure save_logo_simsee_sr3( archi: string );

implementation
uses
  Graphics;

procedure save_logo_simsee_sr3( archi: string );

var
  ABitmap: TBitMap;
begin
  ABitMap:= TBitMap.Create;
  DataModule1.logoSimSEE_sr3.GetBitmap( 0, ABitMap  );
  ABitmap.SaveToFile( archi );
  ABitmap.Free;
end;


{$R *.lfm}

{ TDataModule1 }


end.

