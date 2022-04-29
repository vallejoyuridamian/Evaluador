program titulo;
uses
	DOS,Graph;

var
  Gd, Gm : Integer;
begin
  Gd := Detect; InitGraph(Gd, Gm, 'c:\lng\tp\bgi');
  if GraphResult <> grOk then Halt(1);
  SetTextStyle(1,HorizDir,10);
  OutTextXY(0, 0, 'ComPol');
  swapVectors;
  readln;
  swapVectors;
  CloseGraph;
end.

