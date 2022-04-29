unit umipsimplex_test;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls,
  xmatdefs, usimplex, umipsimplex;

type
  TForm1 = class(TForm)
    Label1: TLabel;
    ePmin1: TEdit;
    Label2: TLabel;
    ePmax1: TEdit;
    Label3: TLabel;
    ePmin2: TEdit;
    Label4: TLabel;
    ePmax2: TEdit;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    eco1: TEdit;
    ecv1: TEdit;
    eco2: TEdit;
    ecv2: TEdit;
    Label9: TLabel;
    eDemanda: TEdit;
    Button1: TButton;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
	Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.Button1Click(Sender: TObject);
var
	 Pmin1, Pmax1, Pmin2, Pmax2: NReal;
	 co1, cv1, co2, cv2: NReal;
	 D: NReal;
	 spx: TMIPSimplex;
	 lstvents: TDAOfNInt;
		fsal: TextFile;
begin

	 D:= StrToFloat( edemanda.text );
	 PMin1:= StrToFloat(ePMin1.text);
	 PMax1:= strToFloat( ePMax1.text );
	 PMin2:= StrToFloat( ePMin2.text );
	 PMax2:= StrTofloat( ePMax2.text );
	 co1:= STrToFloat( eco1.text );
	 co2:= StrToFloat( eco2.text );
	 cv1:= StrToFloat( ecv1.text );
	 cv2:= strTofloat( ecv2.text );
	 spx:= TMIPSimplex.Create_init( 4, 5, 2 );

	 spx.pon_e(1,1, 1 );
	 spx.pon_e( 1, 2, PMin1 );
	 spx.pon_e( 1, 3, 1 );
	 spx.pon_e( 1, 4, PMin2 );
	 spx.pon_e( 1, 5, -D );

	 spx.pon_e( 2,1, -1 );
	 spx.pon_e( 2, 2, PMax1-PMin1 );
	 spx.pon_e( 2, 3, 0 );
	 spx.pon_e( 2, 4, 0 );
	 spx.pon_e( 2, 5 , 0 );

	 spx.pon_e( 3, 1, 0 );
	 spx.pon_e( 3, 2, 0 );
	 spx.pon_e( 3, 3, -1 );
	 spx.pon_e( 3, 4, PMax2-PMin2 );
	 spx.pon_e( 3, 5 , 0 );


	 spx.pon_e( 4, 1, -cv1 );
	 spx.pon_e( 4, 2, -co1 );
	 spx.pon_e( 4, 3, -cv2 );
	 spx.pon_e( 4, 4, -co2 );
	 spx.pon_e( 4, 5 , 0 );

    spx.set_entera( 1,2,1 );
    spx.set_entera( 2,4,1 );

	 try
      spx.Resolver;
		assignfile( fsal, 'mipsal.txt' );
		rewrite( fsal );
		spx.ElMejorNodoFactible.PrintSolEncabs( fsal );
		spx.ElMejorNodoFactible.PrintSolVals( fsal );
		closefile( fsal );

	 finally
			spx.Free;
	 end;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
	D: NReal;
	spx: TMIPSimplex;
	lstvents: TDAOfNInt;
	fsal: TextFile;
	kd: integer;
	sal: textfile;
	k: integer;
	res: integer;
begin
	spx:= TMIPSimplex.Create_init( 4, 5, 2  );

	assignfile( sal, 'ejemplo2.xlt' );
	rewrite( sal );
	writeln( sal, 'D',#9, 'P1',#9,'P2', #9, 'x', #9, '-fcosto' );
	for kd:= 0 to 200 do
	begin
		D:= kd / 100;
		spx.limpiar;

		// P1min= 0.4, P1max= 1
		// p1= P1- P1min
		// p1 + P2 + (P1max-P1min)*y - D = 0
		spx.pon_e( 1, 1,  1.0 );
		spx.pon_e( 1, 2,  1.0 );
		spx.pon_e( 1, 3,  0.0 );
		spx.pon_e( 1, 4,  0.4 );
		spx.pon_e( 1, 5,   -D  );
		spx.FijarRestriccionIgualdad( 1 );

		// -P2 + P2max * x >= 0
		spx.pon_e( 2, 1, 0.0 );
		spx.pon_e( 2, 2, -1.0 );
		spx.pon_e( 2, 3, 1.0 );
		spx.pon_e( 2, 4,  0.0 );
		spx.pon_e( 2, 5, 0.0 );

		// -p1 + (P1max-P1min) * x  >= 0
		spx.pon_e( 3, 1, -1.0 );
		spx.pon_e( 3, 2, 0.0 );
		spx.pon_e( 3, 3, 0.0 );
		spx.pon_e( 3, 4,  1-0.4 );
		spx.pon_e( 3, 5, 0 );


		// -fcosto = -p1 + P2 -x - 0.4 y
		spx.pon_e( 4, 1, -1.0 );
		spx.pon_e( 4, 2,  1.0 );
		spx.pon_e( 4, 3, -1.0 );
		spx.pon_e( 4, 4, -0.4 );
		spx.pon_e( 4, 5,  0.0 );


//		spx.cota_inf_set(1, 0.4 );
//		spx.cota_sup_set(1,1);

      spx.set_entera( 1,3,1 );
      spx.set_entera( 2,4,1 );

		res:= spx.Resolver;

		write( sal, d );
		if res=0 then
		begin
			for k:= 1 to 4  do
				write( sal, #9, spx.ElMejorNodoFactible.x[k] );
			writeln( sal,  #9, spx.ElMejorNodoFactible.fval );
		end
		else
		begin
			for k:= 1 to 4  do
				write( sal, #9, -1 );
			write( sal, #9,'Infactible' );
			writeln( sal,  #9, 0 );
		end;
	end;
	closefile( sal );
end;

end.
