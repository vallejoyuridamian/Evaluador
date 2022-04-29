// OJO, los create no tienene inherited create

unit ubstream;

interface
uses
    sysutils,   classes, windows;


const
     stCreate = 14;
     stOpenRead = 15;
     stOpenWrite = 16;
     stOpen = 17;
     stOk = 0;

type
    TBufStream = class (THandleStream )
        status: integer;
        constructor Init( nombre: string; Modo: integer; Buf: integer );
        procedure done;
        procedure read( var Buf; nbytes: integer );
        procedure write( var Buf; nbytes: integer );
        procedure reset;
        function GetSize: longint;
        procedure _seek( k: longint );
    end;

    TDosStream = class (TBufStream)
       constructor Init( nombre: string; Modo: integer );
    end;






implementation


constructor TBufStream.Init( nombre: string; Modo: integer; Buf: integer );
var
   h: THandle;
begin

     case modo of

     stCreate:
        begin
          h:= FileCreate( nombre );
          if h < 0 then
             status:= -1
          else
          begin
             status:= 0;
             FileClose(h);
             h:= FileOpen( nombre, fmOpenWrite or fmShareDenyWrite );
             Create( h )
          end;
        end;

     stOpenRead:
        begin
           h:= FileOpen( nombre, fmOpenRead or fmShareDenyNone );
           if h < 0 then
              status:= -1
           else
           begin
                status:= 0;
                Create( h );
           end;
        end;

     stOpenWrite:
       begin
           h:= FileOpen( nombre, fmOpenWrite or fmShareDenyWrite );
           if h < 0 then
              status:= -1
           else
           begin
                status:= 0;
                Create( h );
           end;
        end;
     stOpen:
       begin
           h:= FileOpen( nombre, fmOpenReadWrite or fmShareDenyWrite );
           if h < 0 then
              status:= -1
           else
           begin
                status:= 0;
                Create( h );
           end;
        end;

    end;
end;

function TBufStream.GetSize: longint;
begin
     GetSize:= Size;
end;

procedure TBufStream.read( var Buf; nbytes: integer );
begin
     status:=     inherited read( buf, nbytes ) - nbytes;
end;

procedure TBufStream.write( var Buf; nbytes: integer );
begin
     status:= inherited write( buf, nbytes ) - nbytes;
end;

procedure TBufStream.done;
var
  kandle: integer;
begin
  kandle:= handle;
  free;
  fileclose(kandle);
end;

procedure TBufStream.reset;
begin
     seek(0, soFromBeginning  );
end;

procedure TBufStream._seek( k: longint );
begin
     seek(k, soFromBeginning  );
end;
constructor TDosStream.Init( nombre: string; Modo: integer );
begin
     inherited Init( nombre, modo, 500 );
end;


end.
