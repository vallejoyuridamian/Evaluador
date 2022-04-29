
{

The following is public domain information that has been uploaded

to  our Forum on CompuServe.  As a courtesy to our users that  do

not  have  immediate  access  to  CompuServe,  Technical  Support

distributes these routines free of charge.



However,  because these routines are public domain programs,  not

developed by Borland International,  we are unable to provide any

technical support or assistance using these routines. If you need

assistance   using   these   routines,    or   are   experiencing

difficulties,  we  recommend  that you log  onto  CompuServe  and

request  assistance  from the Forum members that developed  these

routines.



The following unit extends the maximum number of  files  that can

be OPEN simultaneously from 20 to 255.  Files in DOS 2.0 or later

are  controlled  by  FILE  handles.   The number of FILE  handles

available to application  programs  is  controlled  by  the FILES

environment  variable  stored  in a CONFIG.SYS FILE.  If no FILES

variable  is  established  in a CONFIG.SYS FILE, then only 8 FILE

handles are available.  However,  DOS requires 5 FILE handles for

its own use (controlling  devices  such  as  CON, AUX, PRN, etc).

This leaves only 3 handles for use by application programs.



By specifying a value for the FILES environment variable, you can

increase the number  of  possible  FILE  handles from 8 up to 20.

Since DOS still requires 5, 15 are left for application programs.

But you cannot normally increase the number of handles beyond 20.



With DOS version 3.0, a new DOS function was  added  to  increase

the number of FILE handles available.  However, the function must

be called from application programs that have previously reserved

space for the new FILE handles.



The unit extend, described below, resizes the amount of allocated

memory for a  Turbo  Pascal  program  to allow space for new FILE

handles.  In doing so, it also resizes the heap by  adjusting the

value of FreePtr, the pointer used in FreeList management.  Since

the  FreeList  is  being manipulated, the heap must be empty when

the extend unit  is  initialized.    This  can  be  guaranteed by

including extend as one of the first units in your program's USES

statement.    If   any   heap  has  been  allocated  when  extend

initializes, the program will halt with an error message.



Notice  that  the  interface section of the extend unit is empty.

The initialization section of the unit takes care  of  the unit's

entire function.  Other than including extend in a program's USES

statement, no other operation need be preformed.



Before using extend, you  must  specify  a  FILES variable in the

CONFIG.SYS FILE such as the following:



FILES = 255



Refer to your DOS User's Guide for more information regarding the

CONFIG.SYS FILE and the FILES variable.





The unit extend is set up for 255 FILE handles.    You can reduce

this number by changing the HANDLES constant in the unit's source

code and  reducing the number specified for the FILES environment

variable.

}

unit Extend;

{This extends the number of FILE handles from 20 to 255}

{DOS requires 5 for itself. Applications can use up to 250}



interface



implementation

uses
	{$I xdos};

const

Handles =30;{255}

{You can reduce the value passed to Handles if fewer files}

{are required.}



var

reg: {$IFDEF WINDOWS} TRegisters{$ELSE} Registers{$ENDIF};


begin

	{Check the Dos Version}

  {This technique only works for DOS 3.0 or later}

reg.ah:=$30;

MsDos(reg);

if reg.al<3 then

begin

writeln('Extend Unit Requires DOS 3.0 or greater');

halt(1);

end;



{$IFNDEF DPMI}



  {Reset the FreePtr}

  {This reduces the heap space used by Turbo Pascal}

if HeapOrg<>HeapPtr then

{Checks to see if the Heap is empty}

begin

write('Heap must be empty before Extend unit initializes');

writeln;

halt(1);

end;

HeapEnd:=ptr(Seg(HeapEnd^)-(Handles div 8 +1), Ofs(HeapEnd^));



  {Determine how much memory is allocated to program}

{Reg.Bx will return how many paragraphs used by program}

reg.ah:=$4A;

reg.es:=PrefixSeg;

reg.bx:=$FFFF;

msdos(reg);



  {Set the program size to the allow for new handles}

reg.ah:=$4A;

reg.es:=PrefixSeg;

reg.bx:=reg.bx-(Handles div 8 +1);

msdos(reg);



	{Error when a Block Size is not appropriate}

if (reg.flags and 1)=1 then

begin

Writeln('Runtime Error ',reg.ax);



Writeln('In the Extend Unit');

halt(1);

end;

{$ENDIF}



  {Allocate Space for Additional Handles}

reg.ah:=$67;

reg.bx:=Handles;

MsDos(reg);

end.
