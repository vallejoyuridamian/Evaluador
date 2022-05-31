{Write the following program  to  a  separate  FILE.  This program

tests the  EXTEND  unit.    This  test  should be done on systems

equipped with a hard disk.  Make sure that FILES is set to 255 in

your CONFIG.SYS file before running.
 }


program TExtend;



uses EXTEND;

type

filearray=array[1..250] of text;

var

f:^filearray;

i:integer;

s:string;



begin

  {Allocate Space for fILE Variable Table}

new(f);

	{oPEN 250 files simultaneously}

for i:=1 to 250 do

begin
	str(i,s);
	Assign(f^[i],'c:\basura\Dum'+s+'.txt');
	rewrite(f^[i]);
	writeln('Open #',s);
end;



	{Write some text to the files}

for i:=1 to 250 do

write(f^[i],'This is a test file');



	{Close the files}

for i:=1 to 250 do

begin
	close(f^[i]);
	writeln('Closing #',i);
end;



	{Erase the files}

for i:=1 to 250 do
begin
	erase(f^[i]);
	writeln('Erasing #',i);
end;



end.
