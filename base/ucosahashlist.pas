unit uCosaHashList;

{$mode delphi}

interface

uses
  Classes, SysUtils, contnrs;

type

  TCosaHashList = class;

  { TCosaHashListItem }

  TCosaHashListItem=class
  private
    _isString: Boolean;
    _sval: string;
    _cosaHashList: TCosaHashList;
  public
     constructor CreateValueItem(x_sval:string);
     constructor CreateHashListItem(x_cosaHashList:TCosaHashList);

     property sval:string read _sval;
     property cosaHashList: TCosaHashList read _cosaHashList;
     property isString: Boolean read _isString;

  end;


  { TCosaHashList }
  // Representación de una cosa por sus valores texto
  TCosaHashList = class(TFPHashList)
  private
    function Get(Index: Integer): TCosaHashListItem;
  public
    CosaStrId:string;

    constructor Create(xCosaStrId:string);

    function Add(const AName:shortstring; cosaHashListItem: TCosaHashListItem):Integer;
    function Find(const AName:shortstring; var item: TCosaHashListItem): Boolean;
    property Items[Index: Integer]: TCosaHashListItem read Get; default;

    procedure print(ramas:Boolean; indent: string='');

    procedure Free;
  end;

implementation

{ TCosaHashListItem }

constructor TCosaHashListItem.CreateValueItem(x_sval: string);
begin
  self._sval:=x_sval;
  self._cosaHashList:=nil;
  _isString:=True;
end;

constructor TCosaHashListItem.CreateHashListItem(x_cosaHashList: TCosaHashList);
begin
  self._sval:=#0;
  self._cosaHashList:=x_cosaHashList;
  _isString:=False;

end;

{ TCosaHashList }

function TCosaHashList.Get(Index: Integer): TCosaHashListItem;
begin
  Result := inherited Items[Index];
end;

constructor TCosaHashList.Create(xCosaStrId: string);
begin
  inherited Create();
  self.CosaStrId:=xCosaStrId;
end;

function TCosaHashList.Add(const AName: shortstring;
  cosaHashListItem: TCosaHashListItem): Integer;
begin
  Result:= inherited Add(AName, cosaHashListItem);
end;

function TCosaHashList.Find(const AName: shortstring;
  var item: TCosaHashListItem): Boolean;

begin
  item:=TCosaHashListItem (inherited Find(LowerCase(AName)));
  Result:= Assigned(item);
end;

procedure TCosaHashList.print(ramas: Boolean; indent: string);
var
  i: Integer;
begin
  for i:=0 to self.Count-1 do
  begin
    if Items[i].isString then
      writeln(indent+' '+NameOfIndex(i),'= ',Items[i].sval)
    else if ramas then
    begin
      writeln(indent+' '+NameOfIndex(i),' =<+ ',Items[i].cosaHashList.CosaStrId,'>');
      Items[i].cosaHashList.print(ramas, indent+'  ');
      writeln(indent+' '+'<- ',Items[i].cosaHashList.CosaStrId,'>');
    end;
  end;
end;

procedure TCosaHashList.Free;
begin
  Clear;
  inherited Free;
end;

end.

