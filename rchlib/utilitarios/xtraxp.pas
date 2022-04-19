{$IFDEF HPGL }
	trxhp, hptraxp
{$ELSE}
	{$IFDEF WINDOWS}
	TraxpW
	{$ELSE }
	traxp {, Graph}
	{$ENDIF}
{$ENDIF}
