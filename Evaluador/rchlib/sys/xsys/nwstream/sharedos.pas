unit ShareDOS;

interface
uses
	{$I xDOS};


const
{ Inherit Bit }
		Inherit = 0;	{ Child process inherits the file }
		NotInherit= 1 shl 7; { Child process doesn't inherit the file }

{ Sharing Mode constants }

		Share_Compatibility = 0;{	Cualquier proceso puede abrir el archivo cualquier
								n£mero de veces en este modo.
								Falla si el archivo ya fue abierto con cualquiera de
								los otros modos de Sharing }
		Share_DenyBoth = 16 ;		{	Falla si el archivo ya fue abierto en el modo
								Compatibility o con c¢digo de acceso de Read o Write,
								incluso por el proceso actual }
		Share_DenyWrite= 32;		{ 	Fails if the file has been opened
								in compatibility mode or fo write access by
								any other process }
		Share_DenyRead = 48;		{	Fails if the file has been opened in compatibility
								mode or for read access by any other process }
		Share_DenyNone = 64;		{ 	Fails if the file has been opened in compatibility
								mode by any other process }

{	Access Codes }
		Access_Read = 0;			{	Fails if the file has been opened in deny read
								or deny both sharing mode }
		Access_Write = 1;        {	Fails if the file has been opened in deny write
								or deny both sharing mode }
		Access_Both	= 2;			{	Fails if the file has been opened in deny read,
								deny write, or deny both sharing mode }
implementation
end.