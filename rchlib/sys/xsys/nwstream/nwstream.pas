{
	EL objeto TNWStream, es un descendiente de TDosStream. Sirve
para crear un Stream de uso temporario con nombre £nico.
	Con (Init) creamos el Stream en el lugar indicado por
(PathToPlace), y utilizando el modo (Mode)
	(Done) cierra el stream y luego lo borra del disco.
}


{-Detalles----------
 Para poder borrar el archivo creado fue necesario almacenar el nombre
del mismo en la variable (FileName). No encontr‚ niguna funci¢n del
DOS que me permita borrar un archivo de un directorio a-traves de su
Handle ----}

unit NWSTREAM;
interface
uses
	Dos,ShareDos,Objects;

type

	TNWStream = object(TDosStream)
      FileName:string;
   	constructor Init(PathToPlace:FNameStr; Mode: word);
      destructor done; virtual;
   end;

implementation




function GetTemporaryFileHandle(var PathToPlace:string):word;

var
  regs : Registers;
  handle: word;
  k:integer;

begin
	PathToPlace := PathToPlace+#0'1234567890123';
	handle := $FFFF;

  { abrir archivo temporario }
  	regs.ah := $5A;
  	regs.ds := Seg(PathToPlace); { Set DS:DX to addr }
  	regs.dx := Ofs(PathToPlace[1]); { of first Char }
  	regs.cx := $02;
  	MsDos(regs); { Call DOS }
  	if (regs.Flags and $01) <> 0 then { nada }
  	else
   begin
      handle:= regs.ax;
		k:=1;
		while PathToPlace[k]<>#0 do inc(k);
		PathToPlace[0]:= chr(k-1);
   end;

	
	GetTemporaryFileHandle:= handle;
end;


constructor TNWStream.Init(PathToPlace:FNameStr; Mode:word);
begin
	FileName:=PathToPlace;
	Handle:= GetTemporaryFileHandle(FileName);
   if Handle<> $FFFF then Status:= stOk
   else Status:= stError;
end;

destructor TNWStream.done;
var
	f:file;
begin
	TDosStream.done;
   assign(f,FileName);
   erase(f);
end;
end.