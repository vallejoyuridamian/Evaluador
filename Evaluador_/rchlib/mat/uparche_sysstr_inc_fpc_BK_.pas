unit uparche_sysstr_inc_fpc;
{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils; 


function FloatToStrF_(Value: double; format: TFloatFormat; Precision, Digits: Integer): String;

implementation



const
{$ifdef FPC_HAS_TYPE_EXTENDED}
  maxdigits = 17;
{$else}
  maxdigits = 15;
{$endif}


Function FloatToStrFIntl(const Value; format: TFloatFormat; Precision, Digits: Integer; ValueType: TFloatValue; Const FormatSettings: TFormatSettings): String;
Var
  P, P_DS: Integer;
  Negative, TooSmall, TooLarge: Boolean;
  DS: Char;

  function RemoveLeadingNegativeSign(var AValue: String): Boolean;
  // removes negative sign in case when result is zero eg. -0.00
  var
    i: PtrInt;
    TS: Char;
    StartPos: PtrInt;
  begin
    Result := False;
    if Format = ffCurrency then
      StartPos := 1
    else
      StartPos := 2;
    TS := FormatSettings.ThousandSeparator;
    for i := StartPos to length(AValue) do
    begin
      Result := (AValue[i] in ['0', DS, 'E', '+', TS]);
      if not Result then
        break;
    end;
    if (Result) and (Format <> ffCurrency) then
      Delete(AValue, 1, 1);
  end;

Begin
  DS:=FormatSettings.DecimalSeparator;
  Case format Of
    ffGeneral:

      Begin
        case ValueType of
          fvCurrency:
            begin
              If (Precision = -1) Or (Precision > 19) Then Precision := 19;
              TooSmall:=False;
            end;
          else
            begin
              If (Precision = -1) Or (Precision > maxdigits) Then Precision := maxdigits;
              TooSmall := ( abs( Extended(Value)) < 0.00001) and (Extended(Value)<>0.0);
            end;
        end;

        If Not TooSmall Then
        Begin
          case ValueType of
            fvDouble:
              Str(Double(Extended(Value)):0:precision, Result);
            fvSingle:
              Str(Single(Extended(Value)):0:precision, Result);
            fvCurrency:
{$ifdef FPC_HAS_STR_CURRENCY}
              Str(Currency(Value):0:precision, Result);
{$else}
              Str(Extended(Currency(Value)):0:precision, Result);
{$endif FPC_HAS_STR_CURRENCY}
            else
              Str(Extended(Value):0:precision, Result);
          end;
          Negative := Result[1] = '-';

          P := Pos('.', Result);
          if P<>0 then
            Result[P] := DS;
          TooLarge :=(P > Precision + ord(Negative) + 1) or (Pos('E', Result)<>0);
        End;

        If TooSmall Or TooLarge Then
          begin
            Result := FloatToStrFIntl(Value, ffExponent, Precision, Digits, ValueType,FormatSettings);
            // Strip unneeded zeroes.
            P:=Pos('E',result)-1;
            If P<>-1 then
              begin
                { delete superfluous +? }
                if result[p+2]='+' then
                  system.Delete(Result,P+2,1);
                While (P>1) and (Result[P]='0') do
                  begin
                    system.Delete(Result,P,1);
                    Dec(P);
                  end;
                If (P>0) and (Result[P]=DS) Then
                  begin
                    system.Delete(Result,P,1);
                    Dec(P);
                  end;
              end;
            end
        else if (P<>0) then // we have a decimalseparator
          begin
            { it seems that in this unit "precision" must mean "number of }
            { significant digits" rather than "number of digits after the }
            { decimal point" (as it does in the system unit) -> adjust    }
            { (precision+1 to count the decimal point character)          }
            { don't just cut off the string, as rounding must be taken    }
            { into account based on the final digit                       }

            if (Length(Result) > Precision + ord(Negative) + 1) and
               (Precision + ord(Negative) + 1 >= P) then
              Result := FloatToStrFIntl(Value, ffFixed,
                0, Precision - (P - Ord(Negative) - 1),
                ValueType, FormatSettings);

            P_DS:= P;
            P := Length(Result);
            if P > P_DS then
              While (P>0) and (Result[P] = '0') Do
                Dec(P);
            If (P>0) and (Result[P]=DS) Then
              Dec(P);
            SetLength(Result, P);
          end;
      End;

    ffExponent:

      Begin
        If (Precision = -1) Or (Precision > maxdigits) Then Precision := maxdigits;
        case ValueType of
          fvDouble:
            Str(Double(Extended(Value)):Precision+7, Result);
          fvSingle:
            Str(Single(Extended(Value)):Precision+6, Result);
          fvCurrency:
{$ifdef FPC_HAS_STR_CURRENCY}
            Str(Currency(Value):Precision+6, Result);
{$else}
            Str(Extended(Currency(Value)):Precision+8, Result);
{$endif FPC_HAS_STR_CURRENCY}
          else
            Str(Extended(Value):Precision+8, Result);
        end;
        { Delete leading spaces }
        while Result[1] = ' ' do
          System.Delete(Result, 1, 1);
        if Result[1] = '-' then
          Result[3] := DS
        else
          Result[2] := DS;
        P:=Pos('E',Result);
        if P <> 0 then
          begin
            Inc(P, 2);
            if Digits > 4 then
              Digits:=4;
            Digits:=Length(Result) - P - Digits + 1;
            if Digits < 0 then
              insert(copy('0000',1,-Digits),Result,P)
            else
              while (Digits > 0) and (Result[P] = '0') do
                begin
                  System.Delete(Result, P, 1);
                  if P > Length(Result) then
                    begin
                      System.Delete(Result, P - 2, 2);
                      break;
                    end;
                  Dec(Digits);
                end;
          end;
      End;

    ffFixed:

      Begin
        If Digits = -1 Then Digits := 2
        Else If Digits > 18 Then Digits := 18;
        case ValueType of
          fvDouble:
            Str(Double(Extended(Value)):0:Digits, Result);
          fvSingle:
            Str(Single(Extended(Value)):0:Digits, Result);
          fvCurrency:
{$ifdef FPC_HAS_STR_CURRENCY}
            Str(Currency(Value):0:Digits, Result);
{$else}
            Str(Extended(Currency(Value)):0:Digits, Result);
{$endif FPC_HAS_STR_CURRENCY}
          else
            Str(Extended(Value):0:Digits, Result);
        end;
        If Result[1] = ' ' Then
          System.Delete(Result, 1, 1);
        P := Pos('.', Result);
        If P <> 0 Then Result[P] := DS;
      End;

    ffNumber:

      Begin
        If Digits = -1 Then Digits := 2
        Else If Digits > maxdigits Then Digits := maxdigits;
        case ValueType of
          fvDouble:
            Str(Double(Extended(Value)):0:Digits, Result);
          fvSingle:
            Str(Single(Extended(Value)):0:Digits, Result);
          fvCurrency:
{$ifdef FPC_HAS_STR_CURRENCY}
            Str(Currency(Value):0:Digits, Result);
{$else}
            Str(Extended(Currency(Value)):0:Digits, Result);
{$endif FPC_HAS_STR_CURRENCY}
          else
            Str(Extended(Value):0:Digits, Result);
        end;
        If Result[1] = ' ' Then System.Delete(Result, 1, 1);
        P := Pos('.', Result);
        If P <> 0 Then
          Result[P] := DS
        else
          P := Length(Result)+1;
        Dec(P, 3);
        While (P > 1) Do
        Begin
          If (Result[P - 1] <> '-') And (FormatSettings.ThousandSeparator <> #0) Then
            Insert(FormatSettings.ThousandSeparator, Result, P);
          Dec(P, 3);
        End;
      End;

    ffCurrency:

      Begin
        If Digits = -1 Then Digits := FormatSettings.CurrencyDecimals
        Else If Digits > 18 Then Digits := 18;
        case ValueType of
          fvDouble:
            Str(Double(Extended(Value)):0:Digits, Result);
          fvSingle:
            Str(Single(Extended(Value)):0:Digits, Result);
          fvCurrency:
{$ifdef FPC_HAS_STR_CURRENCY}
            Str(Currency(Value):0:Digits, Result);
{$else}
            Str(Extended(Currency(Value)):0:Digits, Result);
{$endif FPC_HAS_STR_CURRENCY}
          else
            Str(Extended(Value):0:Digits, Result);
        end;
        Negative:=Result[1] = '-';
        if Negative then
          System.Delete(Result, 1, 1);
        P := Pos('.', Result);
        If P <> 0 Then Result[P] := DS;
        Dec(P, 3);
        While (P > 1) Do
        Begin
          If FormatSettings.ThousandSeparator<>#0 Then
            Insert(FormatSettings.ThousandSeparator, Result, P);
          Dec(P, 3);
        End;

        if (length(Result) > 1) and Negative then
          Negative := not RemoveLeadingNegativeSign(Result);

        If Not Negative Then
        Begin
          Case FormatSettings.CurrencyFormat Of
            0: Result := FormatSettings.CurrencyString + Result;
            1: Result := Result + FormatSettings.CurrencyString;
            2: Result := FormatSettings.CurrencyString + ' ' + Result;
            3: Result := Result + ' ' + FormatSettings.CurrencyString;
          End
        End
        Else
        Begin
          Case FormatSettings.NegCurrFormat Of
            0: Result := '(' + FormatSettings.CurrencyString + Result + ')';
            1: Result := '-' + FormatSettings.CurrencyString + Result;
            2: Result := FormatSettings.CurrencyString + '-' + Result;
            3: Result := FormatSettings.CurrencyString + Result + '-';
            4: Result := '(' + Result + FormatSettings.CurrencyString + ')';
            5: Result := '-' + Result + FormatSettings.CurrencyString;
            6: Result := Result + '-' + FormatSettings.CurrencyString;
            7: Result := Result + FormatSettings.CurrencyString + '-';
            8: Result := '-' + Result + ' ' + FormatSettings.CurrencyString;
            9: Result := '-' + FormatSettings.CurrencyString + ' ' + Result;
            10: Result := Result + ' ' + FormatSettings.CurrencyString + '-';
            11: Result := FormatSettings.CurrencyString + ' ' + Result + '-';
            12: Result := FormatSettings.CurrencyString + ' ' + '-' + Result;
            13: Result := Result + '-' + ' ' + FormatSettings.CurrencyString;
            14: Result := '(' + FormatSettings.CurrencyString + ' ' + Result + ')';
            15: Result := '(' + Result + ' ' + FormatSettings.CurrencyString + ')';
          End;
        End;
      End;
  End;
  if not (format in [ffCurrency]) and (length(Result) > 1) and (Result[1] = '-') then
    RemoveLeadingNegativeSign(Result);
End;

Function FloatToStrFxxx(Value: Double; format: TFloatFormat; Precision, Digits: Integer; Const FormatSettings: TFormatSettings): String;
var
  e: Extended;
begin
  e := Value;
  result := FloatToStrFIntl(e,format,precision,digits,fvDouble,FormatSettings);
end;


function FloatToStrF_(Value: double ; format: TFloatFormat; Precision, Digits: Integer): String;

begin
  Result:= FloatToStrFxxx(Value,Format,Precision,Digits,DefaultFormatSettings);
end;

end.

