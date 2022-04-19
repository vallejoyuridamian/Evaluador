program SimSEE_webserv;

{$mode objfpc}{$H+}
{$define UseCThreads}

uses {$IFDEF UNIX} {$IFDEF UseCThreads}
  cthreads, {$ENDIF} {$ENDIF}
  SysUtils,
  Classes,
  xcampos,
  httpdefs,
  fphttpserver,
  fpmimetypes;

type

  { TTestHTTPServer }

  TTestHTTPServer = class(TFPHTTPServer)
  private
    FBaseDir: string;
    FCount: integer;
    FMimeLoaded: boolean;
    FMimeTypesFile: string;
    procedure SetBaseDir(const AValue: string);
  protected
    procedure CheckMimeLoaded;
    property MimeLoaded: boolean read FMimeLoaded;
  public
    xent: TFPHTTPConnectionRequest;
    xsal: TFPHTTPConnectionResponse;

    procedure HandleRequest(var ARequest: TFPHTTPConnectionRequest;
      var AResponse: TFPHTTPConnectionResponse); override;

    procedure wrln( s: string );
    procedure SimSEERequest;

    property BaseDir: string read FBaseDir write SetBaseDir;
    property MimeTypesFile: string read FMimeTypesFile write FMimeTypesFile;
  end;

var
  Serv: TTestHTTPServer;

  { TTestHTTPServer }

  procedure TTestHTTPServer.SetBaseDir(const AValue: string);
  begin
    if FBaseDir = AValue then
      exit;
    FBaseDir := AValue;
    if (FBaseDir <> '') then
      FBaseDir := IncludeTrailingPathDelimiter(FBaseDir);
  end;

  procedure TTestHTTPServer.CheckMimeLoaded;
  begin
    if (not MimeLoaded) and (MimeTypesFile <> '') then
    begin
      MimeTypes.LoadFromFile(MimeTypesFile);
      FMimeLoaded := True;
    end;
  end;


  procedure TTestHTTPServer.wrln( s: string );
  begin
    xsal.Contents.add( s );
  end;

  procedure TTestHTTPServer.SimSEERequest;
  var
    s: string;
    k: integer;
    axent: TFPHTTPConnectionRequest;
    af: TUploadedFile;
    farchi: TFileStream;
    ch_xo: TCF_HIdden;
    ch_modo: TCF_Hidden;
    cb_seleccion: TCF_Checkbox;
    ce_temperatura: TCF_text;
    ca_mensaje: TCF_textarea;
    cr_optar: TCF_radio;
    cs_sel1: TCF_select;
    cp_clave: TCF_password;
    cs_sel2: TCF_keyedselect;

  begin
    wrln('<html>');
    wrln('<head>');
    wrln('<meta http-equiv="Content-Type" content="text/html; charset=utf-8">' );
    wrln('<title>');
    wrln('---SimSEE---' );
    wrln('</title>');
    wrln('</head>');
    wrln('<body>');

    ch_xo:= TCF_Hidden.Create( xent, 'xo', '' );
    ch_modo:= TCF_Hidden.Create( xent, 'modo', '' );

    case ch_modo.AsInt of
    0: begin
         axent:= nil;
         ch_modo.valor:= '1';
       end;
    1: begin
         axent:= xent;
         ch_modo.valor:= '1';
       end;
    end;

    cb_Seleccion:= TCF_checkbox.Create( axent, 'SELECCION', '1', '1', 'Selccionar' );
    ce_temperatura:= TCF_text.Create( axent, 'temperatura', '20', 30 );
    ca_mensaje:= TCF_textarea.Create( axent, 'mensaje', '??', 4, 40 );
    cr_optar:= TCF_radio.Create(axent, 'optar', arr2lst( ['op_a','op_b', 'op_c'] ), 1 ) ;
    cs_sel1:= TCF_select.Create( axent, 'sel1', arr2lst(['a']), arr2lst( ['a', 'b', 'lechón' ]), true, 2, 2 );
    cp_clave:= TCF_password.Create( axent, 'clave', '????????', 20, 'onChange=javascript:alert(\"hola\");' );
    cs_sel2:= TCF_keyedselect.Create( axent, 'sel2', arr2lst(['k3', 'k4']),arr2lst( ['k1', 'k2', 'k3', 'k4' ]), arr2lst( ['a', 'b', 'lechón', 'ananá' ]), true, 2, 3 );


    wrln( '<hr>' );
    wrln('<form method="POST" action ="">');
    wrln( ch_xo.html_str );
    wrln( ch_modo.html_str );
    wrln( cb_seleccion.html_str +'<br>' );
    wrln( ce_temperatura.html_str +'<br>' );
    wrln( ca_mensaje.html_str +'<br>' );
    wrln( cr_optar.html_str +'<br>' );
    wrln( cs_sel1.html_str +'<br>' );
    wrln( cp_clave.html_str +'<br>' );
    wrln( cs_sel2.html_str +'<br>' );
    wrln( '<input type="submit" value="send">');
    wrln( '</form>');

    wrln('<hr>');
    for k := 0 to xent.FieldCount - 1 do
      wrln(xent.FieldNames[k] + '->' +
        xent.FieldValues[k]);
    wrln('<hr>');

    wrln('<hr>CookieFields<br>');
    for k := 0 to xent.CookieFields.Count - 1 do
      wrln(xent.CookieFields[k] + '<br>');
    wrln('<hr>');

    wrln('<hr>QueryFields<br>');
    for k := 0 to xent.QueryFields.Count - 1 do
      wrln(xent.QueryFields[k] + '<br>');
    wrln('<hr>');

    wrln('<hr>ContentFields<br>');
    for k := 0 to xent.ContentFields.Count - 1 do
      wrln(xent.ContentFields[k] + '<br>');
    wrln('<hr>');

    wrln('<hr>Files<br>');
    for k := 0 to xent.Files.Count - 1 do
    begin
      af := xent.Files[k];
      wrln('FieldName: ' + af.FieldName);
      wrln(', FileName: ' + af.FileName);

      farchi := TFileStream.Create('c:\basura\' + af.FileName, fmCreate);
      farchi.CopyFrom(af.Stream, af.Size);
      farchi.Free;

      wrln(', Size: ' + IntToStr(af.Size));
      wrln(', ContentType: ' + af.ContentType);
      wrln(', Disposition: ' + af.Disposition);
      wrln(', LocalFileName: ' + af.LocalFileName);
      wrln(', Description: ' + af.Description);

    end;
    wrln('<hr>');
    wrln('<p><hr></p>');
    wrln(
      '<form name="fileu" method="POST" enctype="multipart/form-data">');
    wrln('<input type="file" name="fileupload1">');
    wrln('<input type="file" name="fileupload2">');
    wrln('<input type="file" name="fileupload3">');



    wrln('<input type="submit" value="send">');
    wrln(
      '<input name="MAX_FILE_SIZE" value="1073741824" type="hidden" >');
    wrln('</form>');
    wrln('<p><hr /></p>');

    wrln('<form method="POST" action ="">');
    wrln( '<input type="text" name="etemp" value="12.3  Niños  xxx">');

    wrln( '<hr>' );
    wrln('<select name="elcombo[]" multiple>');
    wrln('<option name="a1" value="1">blanco</option>');
    wrln('<option name="a2" value="2">azul</option>');
    wrln('<option name="a3" value="3">rojo</option>');
    wrln('</select>');

    wrln( '<hr>' );
    wrln('<input type="radio" name="radioB" value= "1"> Op1 <br>');
    wrln('<input type="radio" name="radioB" value= "2"> Op2 <br>');
    wrln('<input type="radio" name="radioB" value= "3"> Op3 <br>');
    wrln('<input type="radio" name="radioB" value= "4"> Op4 <br>');
    wrln('<input type="radio" name="radioB" value= "5"> Op5 <br>');

    wrln( '<hr>' );

    wrln( '<input type="checkbox" name="checbox_1" value="cb_lotera" >');

    wrln('<input type="submit" value="send">');

    wrln( '</form>');
    wrln('</html></body>');
  end;

  procedure TTestHTTPServer.HandleRequest(var ARequest: TFPHTTPConnectionRequest;
  var AResponse: TFPHTTPConnectionResponse);

  var
    F: TFileStream;
    FN: string;

begin
    FN := ARequest.Url;
    if pos('SimSEE', FN) > 0 then
    begin
      xent:= ARequest;
      xsal:= AResponse;
      SimSEERequest;
      AResponse.SendContent;
    end
    else
    begin
      if (length(FN) > 0) and (FN[1] = '/') then
        Delete(FN, 1, 1);
      DoDirSeparators(FN);
      FN := BaseDir + FN;
      if FileExists(FN) then
      begin
        F := TFileStream.Create(FN, fmOpenRead);
        try
          CheckMimeLoaded;
          AResponse.ContentType := MimeTypes.GetMimeType(ExtractFileExt(FN));
          Writeln('Serving file: "', Fn, '". Reported Mime type: ',
            AResponse.ContentType);
          AResponse.ContentLength := F.Size;
          AResponse.ContentStream := F;
          AResponse.SendContent;
          AResponse.ContentStream := nil;
        finally
          F.Free;
        end;
      end
      else
      begin
        AResponse.Code := 404;
        AResponse.SendContent;
      end;
      Inc(FCount);
      if FCount >= 5 then
        Active := False;

    end;
  end;

{$R *.res}

begin
  Serv := TTestHTTPServer.Create(nil);
  try
    Serv.BaseDir := ExtractFilePath(ParamStr(0));
{$ifdef unix}
    Serv.MimeTypesFile := '/etc/mime.types';
{$endif}
    Serv.MimeTypesFile := 'c:\s9mmsee\bin\mime.types';
    Serv.Threaded := False;
    Serv.Port := 8081;  // 8080
    Serv.Active := True;
  finally
    Serv.Free;
  end;
end.
