unit uparseutils;

{$mode delphi}

interface

uses
  Classes, SysUtils, xmatdefs;


function nextpal(var r: string; sep: string = ' '): string;
function readInt(var s: string; scap, sini, sfin: string): integer;
function readNReal(var s: string; scap, sini, sfin: string; const af: TFormatSettings): NReal;
function readStrVal(var s: string; scap, sini, sfin: string): string;
function Convertir(s: string; af: TFormatSettings): NReal;
function trimuntag(s: string): string;
function pad2d(a: integer): string;

function nexttd(var s: string): string; overload;
function nexttd(var s: string;  af: TFormatSettings; defVal: NReal = -111111 ): NReal; overload;
function nexttd(var s: string ): integer; overload;


procedure Store_ls(archi: string; ls: TStringList);
function Load_ls(archi: string): TStringList;

procedure Store_str(archi: string; str: string );
function Load_str(archi: string): string;


implementation


procedure Store_ls(archi: string; ls: TStringList);
var
  f: textfile;
  k: integer;
begin
  assignfile(f, archi);
  rewrite(f);
  for k := 0 to ls.Count - 1 do
    writelN(f, ls[k]);
  closefile(f);
end;

function Load_ls(archi: string): TStringList;
var
  f: textfile;
  res: TStringList;
  s: string;
begin
  assignfile(f, archi);
  reset(f);
  res := TStringList.Create;
  while not EOF(f) do
  begin
    readln(f, s);
    res.add(s);
  end;
  closefile(f);
  Result := res;
end;

procedure Store_str(archi: string; str: string );
var
  f: textfile;
  k: integer;
begin
  assignfile(f, archi);
  rewrite(f);
  write(f, str );
  closefile(f);
end;

function Load_str(archi: string): string;
var
  res: TStringList;
begin
  res:= Load_ls( archi );
  res.Free;
end;


function trimuntag(s: string): string;
var
  res: string;
  i, j: integer;
begin
  res := s;
  i := pos('<', res);
  while i > 0 do
  begin
    j := pos('>', res);
    if j > 0 then
    begin
      Delete(res, i, (j - i) + 1);
      i := pos('<', res);
    end
    else
    begin
      res := '';
      i := -1;
    end;
  end;
  Result := trim(res);
end;



function Convertir(s: string; af: TFormatSettings): NReal;
var
  ts: string;
  i: integer;
begin
  if af.DecimalSeparator = ',' then
  begin
    i := pos('.', s);
    while i > 0 do
    begin
      Delete(s, i, 1);
      i := pos('.', s);
    end;
  end;
  ts := trimuntag(s);
  if ts = '' then
    Result := -1
  else
    Result := SysUtils.StrToFloat(ts, af);
end;



function readStrVal(var s: string; scap, sini, sfin: string): string;
var
  iini, ifin: integer;
  ss: string;
begin
  iini := pos(scap, s);
  Delete(s, 1, iini - 1 + length(scap));

  iini := pos(sini, s);
  Delete(s, 1, iini - 1 + length(sini));

  ifin := pos(sfin, s);
  ss := copy(s, 1, ifin - 1);
  Delete(s, 1, ifin - 1 + length(sfin));
  Result := trim(ss);
end;



function readNReal(var s: string; scap, sini, sfin: string;
  const af: TFormatSettings): NReal;
var
  ss: string;
begin
  ss := readStrVal(s, scap, sini, sfin);
  Result := Convertir(ss, af);
end;




function readInt(var s: string; scap, sini, sfin: string): integer;
begin
  Result := StrToInt(readStrVal(s, scap, sini, sfin));
end;



function pad2d(a: integer): string;
var
  s: string;
begin
  s := IntToStr(a);
  while length(s) < 2 do
    s := '0' + s;
  Result := s;
end;



function nextpal(var r: string; sep: string = ' '): string;
var
  i: integer;
  res: string;
begin
  r := trim(r);
  i := pos(sep, r);
  if i > 0 then
  begin
    res := copy(r, 1, i - 1);
    Delete(r, 1, i + length(sep) - 1);
  end
  else
  begin
    res := r;
    r := '';
  end;
  Result := res;
end;




function nexttd(var s: string): string;
var
  res: string;
begin
  res := nextpal(s, '<td');
  res := nextpal(s, '>');
  res := nextpal(s, '</td>');
  res := trimUnTag(res);
  res := StringReplace(res, '&nbsp;', ' ', [rfReplaceAll]);
  Result := trim(res);
end;

function nexttd(var s: string; af: TFormatSettings; defVal: NReal = -111111 ): NReal;
var
  pal: string;
begin
  pal:= nexttd( s );
  if pal = '' then
    result:= defVal
  else
    result:= sysutils.StrToFloat( pal, af );

end;

function nexttd(var s: string ): integer; overload;
var
  pal: string;
begin
  pal:= nexttd( s );
  result:= sysutils.StrToInt( pal );
end;


end.

