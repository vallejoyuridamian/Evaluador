unit uhtmlverdoc;

interface
uses
  windows, shellapi;

var
  apphandle: THandle;

procedure htmlverdoc( marcador: string );

implementation


procedure htmlverdoc( marcador: string );
var
  url: string;
begin
  url:= 'http://iie.fing.edu.uy/simsee/simsolar/manual/simsolarmanual.htm';
  ShellExecute(  apphandle ,'open',PChar(url+'#'+marcador),nil,nil, SW_SHOWNORMAL);
end;

end.
