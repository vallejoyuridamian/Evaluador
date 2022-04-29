unit uvariadorHistogramas;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, fddp, fddp_conmatr;

type
  TForm1 = class(TForm)
    Button1: TButton;
    eFM: TEdit;
    Label1: TLabel;
    efstd: TEdit;
    Label2: TLabel;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure writeln( s: string );
  end;

var
  Form1: TForm1;

implementation
uses xmatdefs, matreal;
{$R *.lfm}



procedure TForm1.writeln(s: string);
begin
   self.Memo1.Lines.Add(s );
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  x, p, xpEquiprobable: TVectR;
  sal: TextFile;
  k: integer;
  N: integer;
  my, mx, stdy, stdx: NReal;
  ratio: NReal;
  cntiter: integer;
begin
  N:= 200;

// vector de muestras original. Todas equiprobables
  x:= TVectR.Create_Init( N );

  randSeed:= 31;

  for k := 1 to N do
    x.pon_e( k , 100 * random );
  x.Sort( true );


  mx:= x.promedio;
  stdx:= sqrt( x.varianza );

  // invento los datos objetivos
  my:= mx * StrToFloat( self.eFM.text );
  stdy:= stdx *  StrToFloat( self.efstd.text );


  assignfile( sal, 'varhisto.xlt' );
  rewrite( sal );
  system.writeln( sal, 'x', #9, 'p' );

  if  cambiarHistograma( x, nil, my, stdy, p, ratio, cntiter ) = 0 then
  begin
    writeln( 'Convergió !!! , NIters: '+ IntToStr( cntiter));
    writeln( ' Sum(p): '+ FloatToStr( N* p.promedio ) );
    xpEquiprobable:= muestrasEquiprobables(x, p, x.n * 10);
    for k:= 1 to N do
      system.writeln(sal,  x.e(k), #9, p.e(k));
    system.writeln(sal);
    system.writeln(sal, 'x*p Equiprobable');
    for k:= 1 to xpEquiprobable.n do
      system.writeln(sal, xpEquiprobable.e(k));
  end
  else
    writeln( 'Problema de convergencia !! ');
  writeln('Ratio: '+ FloatToStr( ratio ) );
  closefile( sal );
end;

end.
