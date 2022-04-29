program tllnf;
type
	sector = array[1..512] of byte;

var

	f: file of sector;
	c:sector;

begin
	assign(f, 'a:\llenar.dat');
	reset(f);
	while not eof(f) do
		read(f,c);
	close(f);
end.