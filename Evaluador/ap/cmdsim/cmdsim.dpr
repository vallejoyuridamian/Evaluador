program cmdsim;
uses {$IFDEF LINUX}
  cthreads,
  cmem,
  uWinMsgs in '..\..\src_nettopos\src_libnettopos\fctopos\IPC\Linux\uwinmsgs.pas',
  uEmuladorWinIPC in '..\..\src_nettopos\src_libnettopos\fctopos\IPC\Linux\uemuladorwinipc.pas',
  uSemaforoPolenta in '..\..\src_nettopos\src_libnettopos\fctopos\IPC\Linux\usemaforopolenta.pas',
  ipcobjs in '..\..\src_nettopos\src_libnettopos\fctopos\IPC\Linux\ipcobjs.pas',
  uKeyDir in '..\..\src_nettopos\src_libnettopos\libnettopos\ukeydir.pas', {$ELSE}
  ipcthrd in '..\..\src_nettopos\src_libnettopos\fctopos\IPC\Win32\ipcthrd.pas', {$ENDIF}
  SysUtils,
  ucmdoptsim in '..\..\fc\base\ucmdoptsim.pas',
  uEsclavizadorSubMuestreado,
  uauxiliares,
  usalasdejuego,
  uInterpreteDeParametros,
  uRobotHttpPost,
  uInicioYFinal,
  uManejadoresDeMonitores,
  ugter_onoffporpaso,
  Links,
  Lexemas32,
  httpsend;

{$R *.res}

begin
  call_RunSimular;
  writeln( 'chau .... simulador ' );
end.
