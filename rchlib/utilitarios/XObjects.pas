{$IFDEF WIN32}

{$ELSE}
   {$IFDEF WINDOWS}
      {$IFDEF VER15}
         WObjects
      {$ELSE}
         Objects,
         OWindows
      {$ENDIF}
   {$ELSE}
       Objects
   {$ENDIF}
{$ENDIF}
