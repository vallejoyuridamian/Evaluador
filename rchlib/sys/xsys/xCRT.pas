{$IFDEF WIN32}
{$DEFINE CONSOLE}
  Windows
{$ELSE}
  {$IFDEF WINDOWS}
  WinCRT
  {$ELSE}
  CRT
  {$ENDIF}
{$ENDIF}