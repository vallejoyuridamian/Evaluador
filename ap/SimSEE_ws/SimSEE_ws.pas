program SimSEE_ws;

{$mode objfpc}{$H+}
{$define UseCThreads}

uses {$IFDEF UNIX} {$IFDEF UseCThreads}
  cthreads, {$ENDIF} {$ENDIF}
  SysUtils,
  Classes,
  xcampos,
  xcamposext,
  udsrecedit,
  udsrecedit_auxs,
  funcsauxs,
  botones,
  httpdefs,
  fphttpserver,
  fpmimetypes,
  uconstantesglobales,
  uConstantesSimSEE,
  uInicioYFinal,
  ueditorsala,
  auxbuscar;

type
  { TTestHTTPServer }

  { TSimSEE_HTTPServer }

  TSimSEE_HTTPServer = class(TFPHTTPServer)
  private
    FBaseDir: string;
    FCount: integer;
    FMimeLoaded: boolean;
    FMimeTypesFile: string;

    robots: TRobotEditores;

    procedure SetBaseDir(const AValue: string);
    procedure wr_encabezado;
    procedure wr_final;
  protected
    procedure CheckMimeLoaded;
    property MimeLoaded: boolean read FMimeLoaded;
  public
    xent: TFPHTTPConnectionRequest;
    xsal: TFPHTTPConnectionResponse;

    procedure HandleRequest(var ARequest: TFPHTTPConnectionRequest;
      var AResponse: TFPHTTPConnectionResponse); override;

    procedure wrln(s: string);

    procedure SimSEE_HandleRequest_TEST;

    procedure SimSEE_HandleRequest;

    property BaseDir: string read FBaseDir write SetBaseDir;
    property MimeTypesFile: string read FMimeTypesFile write FMimeTypesFile;


    constructor Create;
    destructor Destroy; override;
  end;

var
  Serv: TSimSEE_HTTPServer;

  { TSimSEE_HTTPServer }

  procedure TSimSEE_HTTPServer.SetBaseDir(const AValue: string);
  begin
    if FBaseDir = AValue then
      exit;
    FBaseDir := AValue;
    if (FBaseDir <> '') then
      FBaseDir := IncludeTrailingPathDelimiter(FBaseDir);
  end;

  procedure TSimSEE_HTTPServer.CheckMimeLoaded;
  begin
    if (not MimeLoaded) and (MimeTypesFile <> '') then
    begin
      MimeTypes.LoadFromFile(MimeTypesFile);
      FMimeLoaded := True;
    end;
  end;

  procedure TSimSEE_HTTPServer.wrln(s: string);
  begin
    xsal.Contents.add(s);
  end;

procedure TSimSEE_HTTPServer.wr_encabezado;
begin
  wrln('<html>');
  wrln('<head>');
  wrln('<meta http-equiv="Content-Type" content="text/html; charset=utf-8">');
  wrln('<title>');
  wrln('---SimSEE---');
  wrln('</title>');
  wrln('</head>');
  wrln('<body>');
end;

  procedure TSimSEE_HTTPServer.wr_final;
  begin
    wrln('</form>');
    wrln('</html></body>');
  end;

  procedure TSimSEE_HTTPServer.SimSEE_HandleRequest_TEST;
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
    ca_sql: TCF_textarea;
    cr_optar: TCF_radio;
    cs_sel1: TCF_select;
    cp_clave: TCF_password;
    cs_sel2: TCF_keyedselect;
  {$IFDEF CON_DB}
    db: TDB_con;
    ds: TDB_ds;
    row: TDB_row;
  {$ENDIF}
    j: integer;
    nafectadas: integer;
    aCookie: TCookie;
    NFields: integer;

  begin

    wr_encabezado;


    ch_xo := TCF_Hidden.Create('xo');
    ch_xo.load(xent, '');

    ch_modo := TCF_Hidden.Create('modo');
    ch_modo.load(xent, '');

    case ch_modo.AsInt of
      0:
      begin
        axent := nil;
        ch_modo.valor := '1';
      end;
      1:
      begin
        axent := xent;
        ch_modo.valor := '1';
      end;
    end;

    cb_Seleccion := TCF_checkbox.Create('SELECCION', '1', 'Selccionar');
    cb_Seleccion.load(axent, '1');

    ce_temperatura := TCF_text.Create('temperatura', 20);
    ce_temperatura.load(axent, '28');

    ca_sql := TCF_textarea.Create('sql', 4, 40);
    ca_sql.load(axent, '');

    cr_optar := TCF_radio.Create('optar', arr2lst(['op_a', 'op_b', 'op_c']));
    cr_optar.load(axent, '1');

    cs_sel1 := TCF_select.Create('sel1', arr2lst(['a', 'b', 'lechón']), True, 2, 2);
    cs_sel1.load(axent, '0, 2');

    cp_clave := TCF_password.Create('clave', 20, 'onChange=javascript:alert(\"hola\");');
    cp_clave.load(axent, '?????');

    cs_sel2 := TCF_keyedselect.Create('sel2', arr2lst(
      ['k1', 'k2', 'k3', 'k4']), arr2lst(['a', 'b', 'lechón', 'ananá']), True, 2, 3);
    cs_sel2.load(axent, 'k3, k4');

   {$IFDEF CON_DB}
    if ca_sql.valor <> '' then
    begin
      db := TDB_con.Create('localhost', 'usimsee_data', 'usimsee_prono',
        'caracu14', True);

      s := DB.f('SELECT nombre FROM tmp WHERE nid = 1 LIMIT 1');
      wrln('<hr>S: ' + s + '<br>');

      if (pos('SELECT', ca_sql.valor) = 1) or (pos('SHOW', ca_sql.valor) = 1) then
      begin
        ds := DB.query(ca_sql.valor);
        if ds <> nil then
        begin
          wrln('<table border ="1">');
          wrln('<tr>');
          for j := 0 to ds.ncols - 1 do
            wrln('<td>' + ds.fname(j) + '</td>');
          wrln('</tr>');

          row := ds.Next;
          while (row <> nil) do
          begin
            wrln('<tr>');
            for j := 0 to ds.ncols - 1 do
              wrln('<td>' + row[j] + '</td>');
            wrln('</tr>');
            row := ds.Next;
          end;
          wrln('</table>');
          ds.Free;
        end;
      end
      else
      begin
        nafectadas := DB.exec(ca_sql.valor);
        wrln('Fichas afectadas: ' + IntToStr(nafectadas));
        if nafectadas < 0 then
          wrln(' ERROR: ' + AnsiToUtf8(DB.error));
      end;
      DB.Free;
    end;

   {$ENDIF}

    wrln('<hr>');
    wrln('<form method="POST" action ="">');
    wrln(ch_xo.html_str);
    wrln(ch_modo.html_str);
    wrln(cb_seleccion.html_str + '<br>');
    wrln(ce_temperatura.html_str + '<br>');
    wrln('SQL: <br>' + ca_sql.html_str + '<br>');
    wrln(cr_optar.html_str + '<br>');
    wrln(cs_sel1.html_str + '<br>');
    wrln(cp_clave.html_str + '<br>');
    wrln(cs_sel2.html_str + '<br>');
    wrln('<input type="submit" value="send">');
    wrln('</form>');


    wrln('<hr>');

    (*
    NFields:= xent.FieldCount;
    NFields:= xent.ContentFields.Count;
    for k := 0 to NFields - 1 do
      wrln(xent.FieldNames[k] + '->' + xent.FieldValues[k]);
    wrln('<hr>');
      *)


    wrln('<hr>CookieFields<br>');
    for k := 0 to xent.CookieFields.Count - 1 do
      wrln(xent.CookieFields[k] + '<br>');
    wrln('<hr>');


    aCookie := xsal.Cookies.Add;
    aCookie.Name := 'FPCWebCookie';
    aCookie.Value := 'FPCRulez';


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
    wrln('<input type="text" name="etemp" value="12.3  Niños  xxx">');

    wrln('<hr>');
    wrln('<select name="elcombo[]" multiple>');
    wrln('<option name="a1" value="1">blanco</option>');
    wrln('<option name="a2" value="2">azul</option>');
    wrln('<option name="a3" value="3">rojo</option>');
    wrln('</select>');

    wrln('<hr>');
    wrln('<input type="radio" name="radioB" value= "1"> Op1 <br>');
    wrln('<input type="radio" name="radioB" value= "2"> Op2 <br>');
    wrln('<input type="radio" name="radioB" value= "3"> Op3 <br>');
    wrln('<input type="radio" name="radioB" value= "4"> Op4 <br>');
    wrln('<input type="radio" name="radioB" value= "5"> Op5 <br>');

    wrln('<hr>');

    wrln('<input type="checkbox" name="checbox_1" value="cb_lotera" >');

    wrln('<input type="submit" value="send">');

    wr_final;
  end;



  procedure TSimSEE_HTTPServer.SimSEE_HandleRequest;
  var
    nid_robot: integer;
    ch_nid_robot: TCF_HIdden;
    ca_comandos: TCF_textarea;
    aRbt: TRbtEditorSala_cmd;
    rescod: integer;
    esl, rsl: TStrings;
    orden: string;
    k: integer;

  label
     lbl_final;

  begin
    rsl:= nil;

    ch_nid_robot := TCF_Hidden.Create('robot');
    ch_nid_robot.load( xent, '');

    ca_comandos:= TCF_textarea.Create('comandos', 10, 40);
    ca_comandos.load( xent, '' );

    val( ch_nid_robot.valor, nid_robot, rescod );
    if rescod <> 0 then
       aRbt:= Robots.CreateRobotEditor
    else
       aRbt:= Robots.LocateRobotEditor( nid_robot );

    wr_encabezado;
    wrln('<form method="POST" action ="">');
    if aRbt = nil then
    begin
      wrln( '<hr>ERROR ... <br>No fue posbile crear/encontrar el Robot Editor<hr>' );
      wrln( '<hr>... posiblemente se reinició el servidor<hr>' );
      goto lbl_final;
    end;

    ch_nid_robot.valor:= IntToStr( aRbt.nid );
    ch_nid_robot.html( xsal );


    if ca_comandos.valor <> '' then
    begin
      esl:= TStringList.Create;
      esl.Text:= ca_comandos.valor;
      orden := esl[0];
      esl.Delete( 0 );
      rsl:= aRbt.ejecutar( orden, esl );
    end;

    wrln('<hr>Consola: ' );
    ca_comandos.html( xsal );

lbl_final:
   wrln('<hr><input type="submit" value="ENVIAR">');
   wrln('</form>');

   wrln( '<hr>' );
   if rsl <> nil then
   begin
    for k:= 0 to rsl.count-1 do
      wrln( '<br>'+ rsl[k] );
    rsl.Free;
   end;

   wr_final;

   ca_comandos.Free;
   ch_nid_robot.Free;

  end;


  constructor TSimSEE_HTTPServer.Create;
  begin
    inherited Create(nil);
    robots := TRobotEditores.Create;
  end;

  destructor TSimSEE_HTTPServer.Destroy;
  begin
    robots.Free;
    inherited Destroy;
  end;

  procedure TSimSEE_HTTPServer.HandleRequest(var ARequest: TFPHTTPConnectionRequest;
  var AResponse: TFPHTTPConnectionResponse);

  var
    F: TFileStream;
    FN: string;

  begin
    FN := ARequest.Url;
    if pos('SimSEE.rbt', FN) > 0 then
    begin
      xent := ARequest;
      xsal := AResponse;
      SimSEE_HandleRequest;
//      SimSEE_HandleRequest_TEST;
      AResponse.SendContent;
    end
    else
    begin
      if (length(FN) > 0) and (FN[1] = '/') then
        Delete(FN, 1, 1);
      DoDirSeparators(FN);
      if FN = '' then
        FN := 'index.html';

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
  Serv := TSimSEE_HTTPServer.Create;
  try
    uInicioYFinal.AlInicio;
    //    Serv.BaseDir := ExtractFilePath(ParamStr(0));
    Serv.BaseDir := getDir_SimSEE_ws + DirectorySeparator + 'public_html' +
      DirectorySeparator;
    Serv.MimeTypesFile := get_SRV_MIME_FILES;
    Serv.Threaded := False;
    Serv.Port := 8081;  // 8080
    Serv.Active := True;
  finally
    Serv.Free;
    uInicioYFinal.AlFinal;
  end;
end.
