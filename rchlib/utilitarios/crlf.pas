program crlf;

var
	f, sal: text;
	c: char;
	cr: boolean;
begin
	assign( f, paramstr(1) );
	reset(f);
	assign( sal, 'sal.txt');
	rewrite(sal);
	cr:= false;
	while not eof(f) do
	begin
		read(f, c );
		if c= #13 then
				if cr then
					write(sal, #13#10 )
				else
					cr:= true
		else
			if c= #10 then
			begin
				write(sal, #13#10 );
				cr:= false;
			end
			else
				if cr then
				begin
					write(sal, #13#10,c);
					cr:= false;
				end
				else
					write(sal, c );
	end;
	close(sal);
	close(f );
end.