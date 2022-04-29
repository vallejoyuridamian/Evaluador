{$DEFINE EMPAQUETAR_EVITAR_DUPLICADOS}
unit uempaquetar;

{$mode delphi}
interface

uses
  Classes, SysUtils,
  uInicioYFinal,
  uzipper,
  uauxiliares,
  uCosa, uCosaConNombre,
  uConstantesSimSEE,
  uSalasDeJuego;

type
  // la función debe retornar un strin vació si no se encontró.
  TSearchFileFunc = function(archi: string): string;


// crea una carpeta con el mismo nombre de la sala +'_empaquetada' y en
// esa carpeta copia la sala y todos los archivos necesarios para us ejecusión
// al copiar la sala cambia las referencias de los archivos a locales a la carpeta.
// retorna el camino completo de la carpeta.
function EmpaquetarSalaEnCarpeta(archi_sala: string;
  search_file_fun: TSearchFileFunc): string;

// crea un archivo con el misno nombre de la sala +'_empaquetada.zip' y copia
// en ese archivo la sala y los archivos necesarios para su ejecusión.
// al copiar la sala cambia las referencias a los archivos a locales a la carpeta
// para que funcione al descomprimir.
// Retorna el camino completo del archivo zip.
function EmpaquetarSalaEnZip(archi_sala: string;
  search_file_fun: TSearchFileFunc): string;


implementation


procedure adddrive(var archi: string; const drivesala: string);
begin
  if pos(driveSala, archi) = 0 then
  begin
    archi := driveSala + archi;
  end;
end;


function CopyFile(archivoOrigen, archivoDestino: string;
  const drivesala: string): boolean;
var
  f, fs: file;
  buff: array[0..102410 - 1] of byte;
  // ojo no pasarse de rosca que esto está en el stack.
  n: integer;
  res: integer;
  oldFileMode: integer;
begin
{$IFDEF WINDOWS}
  adddrive(archivoOrigen, drivesala);
  adddrive(archivoDestino, drivesala);
{$ENDIF}
  oldFileMode := filemode;
  filemode := 0; // readonl
  Assign(f, archivoOrigen);
  reset(f, 1);
  filemode := 1;
  Assign(fs, archivoDestino);
  rewrite(fs, 1);
  filemode := OldFileMode;
  n := 0;
  res := 0;
  repeat
    blockread(f, buff, 102410, n);
    blockwrite(fs, buff, n, res);
  until (n = 0) or (n <> res);
  Close(fs);
  Close(f);
  Result := n = res;
end;


function EmpaquetarSalaEnCarpeta(archi_sala: string;
  search_file_fun: TSearchFileFunc): string;
var
  f: TArchiTexto;
  sala: TSalaDeJuego;
  carpeta: string;
  nombreSala: string;
  ipos: integer;
  extSala, driveSala: string;

  rae: TArchiRef;
  k: integer;
  r: string;
  ts: string;
  Catalogo: TCatalogoReferencias;
  lstaux: TList;

begin
  carpeta := '';

  try

    // si es necesaio guardo la lista de referencias.
    if ucosa.ReferenciasAArchivosExternos <> nil then
    begin
      lstaux := ucosa.ReferenciasAArchivosExternos;
      ReferenciasAArchivosExternos := TList.Create;
    end
    else
      lstaux := nil;

    uInicioYFinal.AlInicio;

    chdir(ExtractFilePath(archi_sala));
    Catalogo:= TCatalogoReferencias.Create;

    f := TArchiTexto.CreateForRead(0, Catalogo, archi_sala, False);
    f.rd('sala', TCosa(sala));
    sala.setDirCorrida(archi_sala);
    f.Free;

    Catalogo.resolver_referencias(sala.listaActores);
    if Catalogo.resolver_referencias(sala.listaFuentes_) > 0 then
    begin
      Catalogo.DumpReferencias(getDir_Dbg + 'Err_refs.txt');
      raise Exception.Create('ERROR, quedan referencias sin resolver.');
    end;
    Catalogo.Free;

    nombreSala := ExtractFileName(archi_sala);
    extSala := ExtractFileExt(archi_sala);
    {$IFDEF WINDOWS}
    driveSala := ExtractFileDrive(archi_sala);
    {$ELSE}
    driveSala := '';
    {$ENDIF}
    ipos := pos('.', nombreSala);
    if ipos > 0 then
      Delete(nombreSala, ipos, length(nombreSala) - ipos + 1);

    carpeta := ExtractFilePath(archi_sala) + nombreSala + '_empaquetada';
    if not DirectoryExists(carpeta) then
      createdir(carpeta);


    for k := 0 to ucosa.ReferenciasAArchivosExternos.Count - 1 do
    begin
      rae := ReferenciasAArchivosExternos.items[k];
      if rae.archi <> '' then
      begin
        if (not FileExists(rae.archi)) then
        begin
          if @search_file_fun <> nil then
            ts := search_file_fun(rae.archi)
          else
            ts := '';

          if ts = '' then
            raise Exception.Create('Archivo no encontrado: ' + rae.archi);
          rae.archi := ts;
        end;
        r := ExtractFileName(rae.archi);
        CopyFile(rae.archi, carpeta + DirectorySeparator + r, driveSala);
        rae.archi := r;
      end;
    end;
    sala.WriteToArchi(carpeta + DirectorySeparator + nombreSala + extSala);
    sala.Free;
  finally

    uInicioYFinal.AlFinal;
    if lstaux <> nil then
      ucosa.ReferenciasAArchivosExternos := lstaux;

  end;
  Result := carpeta;
end;



function EmpaquetarSalaEnZip(archi_sala: string;
  search_file_fun: TSearchFileFunc): string;
var
  f: TArchiTexto;
  sala: TSalaDeJuego;
  nombreSala: string;
  archiMon: string;
  ipos: integer;
  extSala, driveSala: string;
  zipname: string;
  fzip: TZipper;
  rae: TArchiRef;
  k: integer;
  r: string;
  ts: string;

  lstaux: TList;
  Catalogo: TCatalogoReferencias;

  {$IFDEF EMPAQUETAR_EVITAR_DUPLICADOS}
  lstnombres: TStringList;
  lstnombres_origen: TStringList;
  r_origen: string;
  cntrep: integer;
  klocate: integer;
  buscando_rep: boolean;
  flg_skip: boolean;
  {$ENDIF}

begin
  zipname := '';
  try
    {$IFDEF EMPAQUETAR_EVITAR_DUPLICADOS}
    lstnombres := TStringList.Create;
    lstnombres.Sorted:= true;
    lstnombres_origen := TStringList.Create;
    {$ENDIF}

    // si es necesaio guardo la lista de referencias.
    if ucosa.ReferenciasAArchivosExternos <> nil then
    begin
      lstaux := ucosa.ReferenciasAArchivosExternos;
      ReferenciasAArchivosExternos := TList.Create;
    end
    else
      lstaux := nil;

    uInicioYFinal.AlInicio;

    Catalogo:= TCatalogoReferencias.Create;
    chdir(ExtractFilePath(archi_sala));
    f := TArchiTexto.CreateForRead(0, Catalogo, archi_sala, False);
    f.rd('sala', TCosa(sala));
    sala.setDirCorrida(archi_sala);
    f.Free;

    Catalogo.resolver_referencias(sala.listaActores);
    Catalogo.resolver_referencias(sala.listaCombustibles);
    if Catalogo.resolver_referencias(sala.listaFuentes_) > 0 then
    begin
      Catalogo.DumpReferencias(getDir_Dbg + 'Err_refs.txt');
      raise Exception.Create('ERROR, quedan referencias sin resolver.');
    end;

    Catalogo.Free;

    nombreSala := ExtractFileName(archi_sala);
    extSala := ExtractFileExt(archi_sala);
    {$IFDEF WINDOWS}
    driveSala := ExtractFileDrive(archi_sala);
    {$ELSE}
    driveSala := '';
    {$ENDIF}
    ipos := pos('.', nombreSala);
    if ipos > 0 then
      Delete(nombreSala, ipos, length(nombreSala) - ipos + 1);

    fzip := TZipper.Create;

    zipname := ExtractFilePath(archi_sala) + nombreSala + '.zip';
    fzip.FileName := zipname;
    if FileExists(fzip.FileName) then
      deletefile(fzip.FileName);

    archiMon := ExtractFilePath(archi_sala) + nombreSala + '.mon';
    if fileExists(archiMon) then
    begin
      r := ExtractFileName(archiMon);
      fzip.Entries.AddFileEntry(archiMon, r);
    end;


    for k := 0 to ucosa.ReferenciasAArchivosExternos.Count - 1 do
    begin
      rae := ReferenciasAArchivosExternos.items[k];
      if rae.archi <> '' then
      begin

        if (not FileExists(rae.archi)) then
        begin
          if @search_file_fun <> nil then
            ts := search_file_fun(rae.archi)
          else
            ts := '';

          if ts = '' then
            raise Exception.Create('Archivo no encontrado: ' + rae.archi);
          rae.archi := ts;
        end;
        //        r:= nombreSala+'_z'+IntToStr( k )+'_'+ExtractFileName( rae.archiRefStr );
        r := ExtractFileName(rae.archi);
{$IFDEF EMPAQUETAR_EVITAR_DUPLICADOS}
        flg_skip := False;
        if lstnombres.Find(r, klocate) then
        begin
          if (lstnombres_origen[klocate] <> rae.archi) then
          begin
            cntrep := 1;
            buscando_rep := True;
            while buscando_rep do
            begin
              if lstnombres.Find('r' + IntToStr(cntrep) + '_' + r, klocate) then
                if (lstnombres_origen[klocate] <> rae.archi) then
                  Inc(cntrep)
                else
                begin
                  buscando_rep := False;
                  flg_skip := True;
                end
              else
                buscando_rep := False;
            end;
            r := 'r' + IntToStr(cntrep) + '_' + r;
          end
          else
            flg_skip := True;
        end;

        if not flg_skip then
        begin
          r_origen := rae.archi;
          fzip.Entries.AddFileEntry(rae.archi, r);
          rae.archi := r;
          lstnombres.Add(rae.archi);
          lstnombres_origen.add(r_origen);
        end
        else
          rae.archi := r;
{$ELSE}
        fzip.Entries.AddFileEntry(rae.archi, r);
        rae.archi := r;
{$ENDIF}
      end;
    end;

    sala.WriteToArchi('_sala_tmp_.ese');
    fzip.Entries.AddFileEntry('_sala_tmp_.ese', nombreSala + extSala);
    sala.Free;
    fzip.ZipAllFiles;
    deletefile('_sala_tmp_.ese');
    fzip.Free;
  finally
    {$IFDEF EMPAQUETAR_EVITAR_DUPLICADOS}
    lstnombres.Free;
    lstnombres_origen.Free;
    {$ENDIF}
    uInicioYFinal.AlFinal;
    if lstaux <> nil then
      ucosa.ReferenciasAArchivosExternos := lstaux;
  end;
  Result := zipname;
end;

end.
