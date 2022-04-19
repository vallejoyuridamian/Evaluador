unit umemoryusage;

{$mode delphi}

interface

uses
 Classes, SysUtils;

procedure WriteHeapStatus( s: string );

implementation



procedure WriteHeapStatus( s: string );
var
  r: THeapStatus;
begin
  r:= GetHeapStatus;
  writeln( s+'  ', r.TotalAllocated );
  (*
  writeln( 'Total amount of available addressable memory: ', r.TotalAddrSpace);
  writeln( 'Total amount of uncommitted memory: ',  r.TotalUncommitted);
  writeln( 'Total amount of committed memory: ', r.TotalCommitted );
  writeln( 'Total amount of allocated memory: ', r.TotalAllocated   );
  writeln( 'Total amount of free memory: ',r.TotalFree );
  writeln( 'Total amount of free small memory blocks: ', r.FreeSmall  );
  writeln( 'Total amount of free large memory blocks: ', r.FreeBig );
  writeln( 'Total amount of free process memory: ', r.Unused);
  writeln( 'Total bytes of overhead by memory manager: ', r.Overhead );
  writeln( 'Last error code: ', r.HeapErrorCode );
    *)

end;


end.
