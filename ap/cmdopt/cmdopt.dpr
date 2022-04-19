program cmdopt;

{$APPTYPE CONSOLE}

uses
{$IFDEF LINUX}
  cthreads,
  cmem,
  uWinMsgs in '..\..\src_libnettopos\fctopos\IPC\Linux\uwinmsgs.pas',
  uEmuladorWinIPC in '..\..\src_libnettopos\fctopos\IPC\Linux\uemuladorwinipc.pas',
  uSemaforoPolenta in '..\..\src_libnettopos\fctopos\IPC\Linux\usemaforopolenta.pas',
  ipcobjs in '..\..\src_libnettopos\fctopos\IPC\Linux\ipcobjs.pas',
  uKeyDir in '..\..\src_libnettopos\libnettopos\ukeydir.pas',
{$ELSE}
  ipcthrd in '..\..\src_libnettopos\fctopos\IPC\Win32\ipcthrd.pas',
{$ENDIF}
  SysUtils, ucmdoptsim in '..\..\fc\base\ucmdoptsim.pas',
  uTestSorteos in 'uTestSorteos.pas',
  winLinuxUtils in '..\..\fc\PA10\winLinuxUtils.pas',
  uInterpreteDeParametros in '..\..\fc\base\uInterpreteDeParametros.pas',
  ugestorsalasmh in '..\..\fc\base\ugestorsalasmh.pas',
  uRobotCalculoOptimizadorMulticore in '..\..\fc\base\uRobotCalculoOptimizadorMulticore.pas',
  uRobotEscritorOptimizadorMulticore in '..\..\fc\base\uRobotEscritorOptimizadorMulticore.pas',
  uEsclavizadorSubMuestreado, uManejadoresDeMonitores;

begin
	RunOptimizar(31, -1);
//  uTestSorteos.testSemillas;
//  uTestSorteos.testCantidadesDeSorteos;
end.

