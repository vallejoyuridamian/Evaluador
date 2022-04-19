unit udsrecedit;
interface
  uses Classes, sysutils, udsrecedit_auxs,
    Math,
    RegExpr,
    fphttpserver,
    funcsauxs,
    xcampos, xcamposext,

    lib_dbmysql,

    botones,
    auxbuscar,
    HTTPDefs,
    uconstantesglobales;

(*

if (!isset($do_login))
    $do_login = 1;
if ($do_login) {
    require_once($carpeta_scripts . 'proclogin.php');
}

require_once($carpeta_scripts . 'auxbuscar.php');
*)

Type
  TRecEdit_Globs = class
    // variables de navegación
    nido: string;
    kfoto: integer;
    modo: integer;
    xo: string;
    krec0: integer;
    strbuscar: string;
    order_by: string;

    // parámetros de configuración
    generar_archivo_fotos_aleatorios: boolean;
    manejarUrlPorImagen: boolean;
    fotogr_wmax: integer;
    fotogr_hmax: integer;
    fotoch_wmax: integer;
    fotoch_hmax: integer;
    usar_marcadeagua: boolean;
    forzar_tablafichas: string;
    nPDFsAManejar:integer;
    nMP3sAManejar: integer;
    nVDOsAManejar: integer;
    tinymce_bgcolor: string;
    tinymce_css: string;
    tiny_documnet_base_url: string;  // http://servername.com/
    constructor Create;
    procedure Load( xent: TFPHTTPConnectionRequest );
  end;


  TRecDef = class;

  TCDef = class
    nombre: string;
    ancho: integer;
    extras: string;
    cf: TCF_Base;
    owner_rec: TRecDef;
    dummy: integer; // por defecto = 0; dummy =1 el campo no está en tabla ; dummy = 2 el campo es readonly pero está en la tabla

    constructor Create( nombre: string; ancho: integer; extras: string = '');

    // si xent <> nil carga de xent sino carga de ValIni
    procedure Load( xent: TFPHTTPConnectionRequest; ValIni: string ); virtual;

    function get_valor: string; virtual;
    procedure set_valor( nuevoValor: string ); virtual;
    procedure append_to_update_sql(var sqlupdate: string);  virtual;
   function html_str: string; virtual;

    // esta función es llamada luego de creado el objeto e insertado
    // en la lista de objetos del owner.
    procedure set_owner_rec( owner: TRecDef ); virtual;

    procedure Free; virtual;
  end;


  TCDef_text = class( TCDef )
    constructor Create( nombre: string; ancho: integer; extras: string = '');
  end;

  TCDef_documento = class( TCDef_text )
    constructor Create(nombre: string; ancho: integer; extras:string = '');
    function get_valor: string; override;
  end;


  TCDef_hidden = class( TCDef )
    constructor Create(nombre: string );
  end;

  TCDef_password = class( TCDef_text )
    constructor Create( nombre: string; ancho: integer; extras: string = '');
  end;


  TCDef_textarea = class( TCDef )
    nfilas: integer;
    constructor Create( nombre: string; nfilas, ncolumnas: integer; extras: string = '');
  end;



  TCDef_textarea_html = class( TCDef_textarea )
    constructor Create( nombre: string; nfilas, ncolumnas: integer; extras: string = '');
    function html_str: string; override;
    procedure set_owner_rec( owner: TRecDef ); override;
  end;


  TCDef_checkbox = class( TCDef )
      keyval: string;
      caption: string;
      constructor Create( nombre: string; caption: string = ''; extras: string = ''; keyval:string = '1');
      function get_valor: string; override;
  end;



  TCDef_radio = class( TCDef )
      arrayOfValues: TStrings;
      arrayOfKeys: TStrings;
      constructor Create( nombre: string; arrayOfValues: TStrings; arrayOfKeys:TStrings = nil);
      procedure Load( xent: TFPHTTPConnectionRequest; ValIni: string ); override;
      function get_valor: string; override;
  end;

  TCDef_select = class( TCDef )
      arrayOfValues: TStrings;
      arrayOfKeys: TStrings;
      multisel: boolean;
      altomin: integer;
      altomax: integer;
      constructor Create(
          nombre: string; arrayOfValues: TStrings;
          arrayOfKeys: TStrings = nil; // si es ['auto'] pone de k = 0, ... , nVals-1
                                       // si es '' retorna los valores.
          multisel:boolean = FALSE;
          altomin: integer = 1;
          altomax: integer = 1);
      procedure Load( xent: TFPHTTPConnectionRequest; ValIni: string ); override;
      function get_valor: string; override;
      procedure set_valor( nuevoValor: string ); override;
  end;


TCDef_lookup = class( TCDef_select )
constructor Create(
  nombre: string;
  ds: TDB_ds;
  campo_nombre: string = 'nombre';
  campo_llave: string = 'nid';
  seleccione: string = '';
  key_seleccione: string = '0');
end;


TCDef_fecha = class( TCDef )
    form: string;
    js_BeforeShow: string;
    js_AfterHide: string;

    constructor Create( nombre: string;
        ancho: integer; extras: string='';
        js_BeforeShow: string='';
        js_AfterHide: string='');
    procedure append_to_update_sql( var sqlupdate: string); override;
    procedure Load( xent: TFPHTTPConnectionRequest; ValIni: string ); override;

end;


TCDef_fecha_simple = class( TCDef )
  dia: TCF_text;
  mes: TCF_text;
  anio: TCF_text;
  constructor Create(nombre: string; extras:string='');
  function get_valor: string; override;
  function html_str: string; override;
  procedure append_to_update_sql( var sqlupdate: string); override;
  procedure Load( xent: TFPHTTPConnectionRequest; ValIni: string ); override;
  procedure Free; override;
end;





TCDef_fecha_combos = class( TCDef )
  dia: TCF_select;
  mes: TCF_select;
  centuria: TCF_select;
  decena: TCF_select;
  constructor Create(nombre: string; extras: string='');
  function get_valor: string; override;
  function html_str: string; override;
  procedure append_to_update_sql( var sqlupdate: string ); override;
  procedure Load( xent: TFPHTTPConnectionRequest; ValIni: string ); override;


  function get_valor_campo( campo: TCF_select ): string;
  function arri(i1, i2: integer): TStrings;
  procedure Free; override;
end;



TCDef_font = class(TCDef)
  constructor Create( nombre: string; extras: string = '');
end;



TCDef_karchi = class( TCDef )
    karchi: string;
    tipo: string;
    existe: boolean;
    constructor Create( nombre, karchi, tipo: string);
    procedure Load( xent: TFPHTTPConnectionRequest; ValIni: string ); override;
    function url_archi(nido, karchi, tipo: string): string;
    function parch23(nido: string; existe: boolean; karchi, tipo: string): string;
    function get_valor: string;
end;


  //  Inicio TRecDef
TRecDef  = class
    glob: TRecEdit_Globs;
    nombre: string;
    cdefs: TList;
    tabla: string;
    llave: string;
    nido: string;

    editor_html_textareas: TStringList;
    db: TDB_con; // referencia a la conexión
    intranet_control: boolean;
    auto_backup: boolean;
    def_activa: boolean;
    nImagenesAManejar: integer;
    manejarCarpetasPorFicha: boolean;


    constructor Create(  nombre: string; db: TDB_con; tabla: string; llave: string = 'nid');

    function on_before_update( modo: integer ): boolean;
        // sobreescriba este método con lo que corresponda hacer antes de hacer el UPDATE del registro.
        // por ejemplo, si hay campos calculados es el momento de actualizarlos.
        // o si hay que fijar los valores por defecto para los registros nuevos ( $modo == 3 ) es el momento de hacerlo
        // si $modo == 2 es el update de un registro que estaba en edición
        // si $modo == 3 se está guardando la edición de un registro preinsertado vació.
        // si retorna true se procede con el update
        // si retorna false se cancela el update

    procedure on_after_updtate( modo: integer );
        // Luego de salvado el registro se llama este método por si hay que propagar
        // información hacia otras tablas (o lugares) no directamente manejados por el registro.
        // Por ejemplo actualizar el contador de hijos de la sección padre si el record pertenece
        // a un árbol y que se quiera mantener el contador de hijos de cada nodo
        // si $modo == 2 es el update de un registro que estaba en edición
        // si $modo == 3 se está guardando la edición de un registro preinsertado vació.

    function on_before_delete: boolean;
        // es llamado antes de hacer DELETE del registro
        // si retorna TRUE se procede con el delete


    procedure before_insert_sql_append(var sql_a, sal_b: string ) ;
        // sobreescriba este método para agregar parámetros en el INSERT de un nuevo record
        // por defecto se agregan lo necesario para identificar la ficha y esta es una opción
        // para agregar nuevos campos que se necesario agregarlos al INSERTAR como puede
        // ser el llenar los valores de un conjunto de campos que formen un índice UNIQUE
        // para evitar repetirciones.
        // ej:  $salq_a.= ', "username"';  $sql_b.= ', "'.nombre_unico().'"'

    procedure on_addrec;
        // sobreescriba este método si quiere agregar compartamiento al agregar el registro.
        // estas acciones deben ser revertidas en caso de que luego se elimine el registro

    function on_delete: boolean;
    procedure insert_CDef( cDef: TCDef );
    procedure load( xent: TFPHTTPConnectionRequest; nido: string );
    function update( modo: integer ): boolean;
    function listar_editor_html_textareas: string;
    function tiny_class_javascript_str: string;
    function form_begin: string;
    function form_end( modo, kfoto, krec0: integer; strbuscar, order_by: string): string;
end;



TColumn = class
  caption: string;
  nombre: string;
  str_select: string;
  ordenable: integer; // 0= no ordenable; -1 Ordenable DESC por defecto, 1 Ordenable INC por defecto
  order_by_status: integer; // 0 no activo; -1 In OrderBy DESC ; 1 in orden by INC
  order_by_kindex: integer; // si status <> 0 indica el orden de la columna ORDER BY

constructor Create( caption, nombre: string; ordenable: integer; sql_select: string );
procedure addToSqlSelect(var sql: string);
procedure calc_order_by_params( order_by_names, order_by_status: TStrings );
function get_order_by_html_str: string;
end;







TListado = class
    caption: string;
    form_name: string;
    db: TDB_con;
    tabla: string;
    apodo_tabla: string;
    nrpp: integer;
    ncols: integer;
    cdfs: TList;
    con_buscador: boolean;
    strbuscar: string;
    ordenable: boolean;
    krec0: integer; // k del primer record desplegado en la página de la consulta
    kpag: integer; // número de página de despliegue
    npags: integer; // número total de páginas
    nrows: integer; // del la página desplegada
    nrows_total: integer; // de todas las páginas de la consulta
    hay_siguientes: boolean;
    hay_anteriores: boolean;
    krec0_siguientes: integer;
    krec0_anteriores: integer;
    botonera: TList;
    botonera_M: integer;
    filtro: string;
    order_by: string;
    insertarAlFinal: boolean;
    campos_buscar: TStrings;
    order_by_names: TStrings;
    order_by_status: TStrings;
    joins: string;
    url_volver: string;
    texto_volver: string;
    acapite: string;
    BT_AGREGAR: boolean; // { 0 = no poner; 1 = poner (default) }


    constructor Create(
      caption, form_name: string;
      db: TDB_con;
      tabla: string;
      nrpp, krec0, ncols: integer;
      insertarAlFinal: boolean;
      filtro, order_by: string;
      con_buscador: boolean;
      strbuscar: string;
      campos_buscar: TStrings;
      ordenable: boolean;
      joins: string = '';
      url_volver: string = 'index.php';
      acapite: string = '');
      procedure calc_order_by_arrays;
      function get_order_by: string;
      function get_header_row: string;
      procedure addCol( caption, nombre: string; ordenable:integer = 0; sql_select:string= '');
      function getBotonera(r_nid, r_activa: string ): string;
      function getSqlBuscar( strbuscar: string ): string;
      function getSqlSelect(where: string; krec0, nrpp: integer; order_by: string ): string;
      function form_begin: string;
      function form_end: string;
      function despliegue_multi_record( ds: TDB_ds; nrows: integer): string;
      function html_str: string;
end;



function ereg_replace( regexp, sustituto: string; texto: string ): string;
function textoseguro(s: string): string;


implementation


  constructor TRecEdit_Globs.Create;
  begin
    inherited Create;
    // variables de navegación
    load( nil );

    // parámetros de configuración
    generar_archivo_fotos_aleatorios:= false;
    manejarUrlPorImagen := false;
    nPDFsAManejar:=0;
    nMP3sAManejar:=0;
    nVDOsAManejar:=0;

    fotogr_wmax := 400;
    fotogr_hmax := 400;
    fotoch_wmax := 100;
    fotoch_hmax := 100;
    usar_marcadeagua:= false;
    forzar_tablafichas := '';
    tinymce_bgcolor:= '#FFFFFF';
    tinymce_css := ' content_css : "/css/vasen.css", ';
    tiny_documnet_base_url:= '???? poner algo???¿';
  end;

  procedure TRecEdit_Globs.load( xent: TFPHTTPConnectionRequest );
  begin
    // variables de navegación
    nido := varval(xent, 'nido', '??');
    kfoto := varval_int(xent, 'kfoto', 0);
    modo := varval_int(xent, 'modo', 1);
    xo := varval(xent, 'xo', '??');
    krec0 := varval_int(xent, 'krec0', 0);
    strbuscar := varval(xent, 'strbuscar', '');
    order_by := varval(xent, 'order_by', '');
  end;

function ereg_replace( regexp, sustituto: string; texto: string ): string;
var
  rexp: TRegExpr;
begin
  rexp:= TRegExpr.Create;
  rexp.Expression:= regexp;
  result:= rexp.Replace( texto, sustituto, false);
  rexp.Free;
end;


function textoseguro(s: string): string;
var
  r: string;
begin
  r := s;
  r := Str_Replace('<br>', #13#10, r);
  r := ereg_replace('<([^>]|\n)*>', '', r);

  r := Str_Replace('''', '*', r);
  r := Str_Replace('"', '*', r);
  r := Str_Replace('<', '*', r);
  r := Str_Replace('>', '*', r);

  r := Str_Replace('&#039;', '*', r);
  r := Str_Replace('&quot;', '*', r);

  result:= r;
end;



(*****************************
   Métodos de TRecDef
******************************)

    constructor TRecDef.Create(
      nombre: string; db: TDB_con; tabla: string; llave: string = 'nid');
    begin
      inherited Create;
      glob.Create;
      cdefs:= TList.Create;
      editor_html_textareas:= TStringList.Create;
      nido:= '0';
      Self.nombre := nombre;
      Self.db := db;
      Self.tabla := tabla;
      Self.llave := llave;

      intranet_control:= false; // por defecto no aplicamos control de Intranet
      auto_backup:= false; // por defecto no usamos autobackup.
      def_activa:= false; // por defecto si se guarda el record por primera vez queda inactivo
      nImagenesAManejar:= 0;
      manejarCarpetasPorFicha:= true;
    end;

    function TRecDef.on_before_update( modo: integer ): boolean;
    begin
        // sobreescriba este método con lo que corresponda hacer antes de hacer el UPDATE del registro.
        // por ejemplo, si hay campos calculados es el momento de actualizarlos.
        // o si hay que fijar los valores por defecto para los registros nuevos ( $modo == 3 ) es el momento de hacerlo
        // si $modo == 2 es el update de un registro que estaba en edición
        // si $modo == 3 se está guardando la edición de un registro preinsertado vació.
        // si retorna true se procede con el update
        // si retorna false se cancela el update
        result:= true;
    end;

    procedure TRecDef.on_after_updtate( modo: integer );
    begin
        // Luego de salvado el registro se llama este método por si hay que propagar
        // información hacia otras tablas (o lugares) no directamente manejados por el registro.
        // Por ejemplo actualizar el contador de hijos de la sección padre si el record pertenece
        // a un árbol y que se quiera mantener el contador de hijos de cada nodo
        // si $modo == 2 es el update de un registro que estaba en edición
        // si $modo == 3 se está guardando la edición de un registro preinsertado vació.
    end;

    function TRecDef.on_before_delete: boolean;
    begin
        // es llamado antes de hacer DELETE del registro
        // si retorna TRUE se procede con el delete
        result:= true;
    end;

    procedure TRecDef.before_insert_sql_append(var sql_a, sal_b: string ) ;
    begin
        // sobreescriba este método para agregar parámetros en el INSERT de un nuevo record
        // por defecto se agregan lo necesario para identificar la ficha y esta es una opción
        // para agregar nuevos campos que se necesario agregarlos al INSERTAR como puede
        // ser el llenar los valores de un conjunto de campos que formen un índice UNIQUE
        // para evitar repetirciones.
        // ej:  $salq_a.= ', "username"';  $sql_b.= ', "'.nombre_unico().'"'
    end;

    procedure TRecDef.on_addrec;
    begin
        // sobreescriba este método si quiere agregar compartamiento al agregar el registro.
        // estas acciones deben ser revertidas en caso de que luego se elimine el registro
        if manejarCarpetasPorFicha then
            crear_directorios_ficha(tabla, nido);
    end;

    function TRecDef.on_delete: boolean;
    var
      sql: string;
    begin
        if ( Self.on_before_delete) then
        begin
            if (Self.nImagenesAManejar > 0) then
                deletefotos(Self.tabla, Self.nido);
            if (Self.manejarCarpetasPorFicha) then
                eliminar_directorios_ficha(Self.tabla, Self.nido);
            sql := 'DELETE FROM '+tabla+' WHERE nid= "'+Self.nido +'" LIMIT 1';
            result:= db.exec(sql) = 1;
        end
        else
          result:= false;
    end;

    procedure TRecDef.insert_CDef( cDef: TCDef );
    begin
        cdefs.add(cDef);
        cDef.set_owner_rec( Self );
    end;

    procedure TRecDef.load(xent: TFPHTTPConnectionRequest; nido: string );
    var
      acdef: TCDef;
      k: integer;
      sql: string;
      r: TDB_row;
      flg_coma: boolean;
    begin

        self.Glob.load( xent );

        Self.nido := nido;

        sql := 'SELECT ';

        flg_coma:= false;

        for k:= 0 to cdefs.count - 1 do
        begin
          acdef:= cdefs[k];
          if acdef.dummy <> 1 then
          begin
            if flg_coma then
              sql:= sql+', '
            else
              flg_coma:= true;

            sql:= sql +  acdef.nombre;
          end;
        end;

        sql := sql + ' FROM ' + tabla +' WHERE ' + llave + ' = "' + Self.nido + '" LIMIT 1;';

        r := db.f_rec(sql);

        for k:= 0 to cdefs.count - 1 do
        begin
          acdef:= cdefs[k];
          if acdef.dummy <> 1 then
             acdef.load( xent, r[k] );
        end;
    end;

    function TRecDef.update( modo: integer ): boolean;
    var
      sql: string;
      acdef: TCDef;
      k: integer;

    begin
       if cdefs.count = 0 then
       begin
         result:= true;
         exit;
       end;
        sql := '';
        if (modo = 3)  then
         sql:= 'activa = ' + BoolToStr( Self.def_activa, '1', '0' );
        if (on_before_update(modo)) then
        begin
          for k:= 0 to cdefs.count - 1do
          begin
            acdef:= cdefs[k];
            if (acdef.dummy = 0) then
              acdef.append_to_update_sql(sql);
           end;
           sql := 'UPDATE ' + Self.tabla + ' SET ' + sql  + ' WHERE ' + Self.llave + ' = "'+ Self.nido + '" LIMIT 1';
            result:= db.exec(sql)=1;
            on_after_updtate(modo);
        end
        else
          result:= false;
    end;

    function TRecDef.listar_editor_html_textareas: string;
    var
      k: integer;
      res: string;
    begin
        res:= '';
        for k:= 0 to editor_html_textareas.count - 1 do
        begin
            if (k > 0) then res := res +',';

            res := res +'CFrch_' + editor_html_textareas[k];
        end;
        result:= res;
    end;

    function TRecDef.tiny_class_javascript_str: string;
    var
      res: string;
      cnt: integer;
    begin
//   global $base_url_tiny_lists, $tinymce_css, $tinymce_bgcolor, $base_url_tiny_subir_helpers;

        cnt := Self.editor_html_textareas.count;

        res := '';

        if (cnt > 0)  then
        begin

apr( res,  '<script type="text/javascript">' );
apr( res,  '  tinyMCE.init({ ' );
apr( res,  '// General options' );
apr( res,  '//    mode : "textareas",' );
apr( res,  '    mode: "exact",' );
apr( res,  '    elements: "' +listar_editor_html_textareas+ '",' );
apr( res,  '    theme : "advanced",' );
apr( res,  '    language : "es",' );
apr( res,  '    plugins : "safari,pagebreak,style,layer,table,save,advhr,advimage,advlink,emotions,iespell,inlinepopups,insertdatetime,preview,media,searchreplace,print,contextmenu,paste,directionality,fullscreen,noneditable,visualchars,nonbreaking,xhtmlxtras,template",' );
apr( res,  '' );
apr( res,  '    // Theme options' );
apr( res,  '    theme_advanced_buttons1 : "save,newdocument,|,bold,italic,underline,strikethrough,|,justifyleft,justifycenter,justifyright,justifyfull,styleselect,formatselect,fontselect,fontsizeselect",' );
apr( res,  '    theme_advanced_buttons2 : "cut,copy,paste,pastetext,pasteword,|,search,replace,|,bullist,numlist,|,outdent,indent,blockquote,|,undo,redo,|,link,unlink,anchor,image,cleanup,help,code,|,insertdate,inserttime,preview,|,forecolor,backcolor",' );
apr( res,  '    theme_advanced_buttons3 : "tablecontrols,|,hr,removeformat,visualaid,|,sub,sup,|,charmap,emotions,iespell,media,advhr,|,print,|,ltr,rtl,|,fullscreen",' );
apr( res,  '    theme_advanced_buttons4 : "insertlayer,moveforward,movebackward,absolute,|,styleprops,|,cite,abbr,acronym,del,ins,attribs,|,visualchars,nonbreaking,template,pagebreak",' );
apr( res,  '    theme_advanced_toolbar_location : "top",' );
apr( res,  '    theme_advanced_toolbar_align : "left",' );
apr( res,  '    theme_advanced_statusbar_location : "bottom",' );
apr( res,  '    theme_advanced_resizing : true,' );
apr( res,  '' );
apr( res,  '    // Example content CSS (should be your site CSS)' );
apr( res,  '    '+ Glob.tinymce_css + '' );
apr( res,  '' );
apr( res,  '    theme_advanced_font_sizes: "8pt,10pt,12pt,14pt,16pt,18pt,24pt,36pt",' );
apr( res,  '    font_size_style_values : "8pt,10pt,12pt,14pt,16pt,18pt,24pt,36pt",' );
apr( res,  '    setup : function(ed) {' );
apr( res,  '      ed.onInit.add(function(ed) {' );
apr( res,  '          ed.dom.setStyle(ed.getBody(), ''background-color'', '''+ Glob.tinymce_bgcolor+ ''');' );
apr( res,  '                       });}, ' );
apr( res,  '    relative_urls : false, ' );
apr( res,  '    document_base_url : "'  + glob.tiny_documnet_base_url +  '", ' );
apr( res,  '    // Drop lists for link/image/media/template dialogs ' );
apr( res,  '    template_external_list_url : "' + base_url_tiny_lists + 'template_list.js",' );
apr( res,  '//    external_link_list_url : "' + base_url_tiny_lists + 'link_list.js",' );
apr( res,  '    external_link_list_url : "' + base_url_tiny_lists +'link_list.php?tabla=' + tabla + '&nidficha=' + nido + '",' );
apr( res,  '    external_image_list_url : "' + base_url_tiny_lists + 'image_list.php?tabla=' + tabla + '&nidficha=' +nido + '",' );
apr( res,  '    media_external_list_url : "' + base_url_tiny_lists + 'media_list.js",' );
apr( res,  '' );
apr( res,  '    // Replace values for the template plugin' );
apr( res,  '    template_replace_values : {' );
apr( res,  '      username : "Some User",' );
apr( res,  '      staffid : "991234"' );
apr( res,  '    }' );
apr( res,  '  }); ' );
apr( res,  '   ' );
apr( res,  '  function subirimg(tabla, nidficha){' );
apr( res,  '  var config=''toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=no,height=570,width=700,left=175,top=0'';' );
apr( res,  '  var rin = parseInt( Math.random(-1)*1000);' );
apr( res,  '	window.open(''' + base_url_tiny_subir_helpers + 'subirimg.php?tabla=''+tabla+''&nidficha=''+nidficha,''Subir_FOTO'', config );' );
apr( res,  '}' );
apr( res,  '' );
apr( res,  'function subirdoc(tabla, nidficha){' );
apr( res,  '  var config=''toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=no,height=570,width=700,left=175,top=0'';' );
apr( res,  '  var rin = parseInt( Math.random(-1)*1000);' );
apr( res,  '	window.open(''' + base_url_tiny_subir_helpers + 'subirdoc.php?tabla=''+tabla+''&nidficha=''+nidficha,''Subir_DOC'', config );' );
apr( res,  '}' );
apr( res,  '' );
apr( res,  '</script>' );

  result:= res;
end;
end;



    function TRecDef.form_begin: string;
    var
      res: string;
    begin
      res:= '';
      apr( res, '<form method="POST" enctype="multipart/form-data" name="fdatos" onsubmit="return pO(this, ''saverec'','''+ nido +''',0);">');
      if ( editor_html_textareas.count  > 0) then
       begin
          apr( res, '<script type="text/javascript" src="'
                +subcarpeta_raiz
                + '/tinymce/jscripts/tiny_mce/tiny_mce.js">' );
          apr( res, '</script>' );
       end;
      result:= res;
    end;

    function TRecDef.form_end( modo, kfoto, krec0: integer; strbuscar, order_by: string): string;
    var
      res: string;
    begin
        res:= '';
        apr( res, '<INPUT type="hidden" name="xo" value="?">' );
        apr( res, '<INPUT type="hidden" name="nido" value="' + nido + '">');
        apr( res, '<INPUT type="hidden" name="modo" value="' + IntToStr( modo )+'">');
        apr( res, '<INPUT type="hidden" name="kfoto" value="' + IntToStr(kfoto) + '">');
        apr( res, '<INPUT type="hidden" name="krec0" value="' + IntToStr( krec0 ) + '">');
        apr( res, '<INPUT type="hidden" name="strbuscar" value="'+strbuscar + '">');
        apr( res, '<INPUT type="hidden" name="order_by" value="' + order_by + '">');
        apr( res, '</form>' );
        if editor_html_textareas.count > 0 then
          apr( res, tiny_class_javascript_str );
        result:= res;
    end;




// inicio TCDef_text
constructor TCDef_text.Create(  nombre: string; ancho: integer; extras: string = '');
begin
    inherited Create(nombre, ancho, extras);
    cf := TCF_text.Create( Self.nombre, ancho, Self.extras);
end;

// inicio TCDef_documento
constructor TCDef_documento.Create(nombre: string; ancho: integer; extras:string = '');
begin
    inherited Create(nombre, ancho, extras);
end;

function TCDef_documento.get_valor: string;
var
  res: string;
begin
    res := inherited get_valor;
    res := filtrar_raros(res);
    result:= res;
end;



// inicio TCDef_hidden
constructor TCDef_hidden.Create( nombre: string);
begin
      inherited Create(nombre, 1, '');
      cf := TCF_hidden.Create(Self.nombre, '');
end;


constructor TCDef_password.Create( nombre: string; ancho: integer; extras: string = '');
begin
  inherited Create( nombre, ancho, extras);
  cf := TCF_password.Create(Self.nombre, ancho, extras );
end;


constructor TCDef_textarea.Create( nombre: string; nfilas, ncolumnas: integer; extras: string = '');
begin
  inherited Create( nombre, ncolumnas, extras);
  Self.nfilas := nfilas;
  Self.cf := TCF_textarea.Create(Self.nombre, Self.nfilas, Self.ancho, Self.extras);
end;


constructor TCDef_textarea_html.Create( nombre: string; nfilas, ncolumnas: integer; extras: string = '');
begin
  inherited Create(nombre, nfilas, ncolumnas, extras);
end;

function TCDef_textarea_html.html_str: string;
var
  res: string;
begin
    res := inherited html_str;

    res := res + '<br>';
    res := res +'Subir: [ <a href="javascript:subirimg('''
          + owner_rec.tabla + ''', ' + owner_rec.nido + ');">Imagen</a> ]';
    res := res +' | [ <a href="javascript:subirdoc(''' + owner_rec.tabla + ''', ' + owner_rec.nido + ');">Documento</a> ]';
    result:= res;
end;



procedure TCDef_textarea_html.set_owner_rec( owner: TRecDef );
begin
    inherited set_owner_rec(owner);
    Self.owner_rec.editor_html_textareas.add( nombre );
end;




constructor TCDef_checkbox.Create( nombre: string; caption: string = '';
  extras: string = ''; keyval: string = '1');
begin
    inherited Create( nombre, 0, extras);
    Self.keyval := keyval;
    Self.caption := caption;
    Self.cf := TCF_checkbox.Create( nombre, keyval, caption, extras);
end;

function TCDef_checkbox.get_valor: string;
begin
  if TCF_checkbox( cf ).checked then
    result:= '1'
  else
    result:= '0';
end;



constructor TCDef_radio.Create( nombre: string; arrayOfValues: TStrings; arrayOfKeys:TStrings = nil);
begin
    inherited Create(nombre, 0, '');
    Self.arrayOfValues := arrayOfValues;
    Self.arrayOfKeys := arrayOfKeys;
    Self.cf :=  TCF_radio.Create(Self.nombre, arrayOfValues );
end;

procedure TCDef_radio.Load( xent: TFPHTTPConnectionRequest; ValIni: string );
var
  ksel: string;
begin
    if arrayOfKeys<> nil then
      ksel := IntToStr( arrayOfKeys.indexOf( ValIni ) )
    else
      ksel := ValIni;
    Self.cf.load(xent, ksel);
end;

function TCDef_radio.get_valor: string;
var
  res: string;
  ksel: string;
begin
  ksel := Self.cf.valor;
  if arrayOfKeys <> nil then
    res := IntToStr( arrayOfKeys.IndexOf(ksel))
  else
    res := ksel;
  result:= res;
end;



constructor TCDef_select.Create(
    nombre: string; arrayOfValues: TStrings;
    arrayOfKeys: TStrings = nil; // si es ['auto'] pone de k = 0, ... , nVals-1
                                 // si es '' retorna los valores.
    multisel:boolean = FALSE;
    altomin: integer = 1;
    altomax: integer = 1);
var
  k, n: integer;

begin
  inherited Create(nombre, 0, '');
    Self.arrayOfValues := arrayOfValues;
    Self.multisel := multisel;
    Self.altomin := altomin;
    Self.altomax := altomax;
    if ( arrayOfKeys <> nil )
        and ( arrayOfKeys.count = 1 )
        and ( arrayOfKeys[0] = 'auto') then
    begin
        n := arrayOfValues.count;
        arrayOfKeys.Clear;
        for k:= 0 to n-1 do
            arrayOfKeys.add( IntToStr( k ));
    end
    else
        Self.arrayOfKeys := arrayOfKeys;

    if Self.arrayOfKeys<> nil then
         Self.cf := TCF_keyedselect.Create(
                Self.nombre, Self.arrayOfKeys,
                Self.arrayOfValues,
                Self.multisel, Self.altomin, Self.altomax)
    else
        Self.cf := TCF_select.Create(
                Self.nombre, Self.arrayOfKeys,
                Self.multisel, Self.altomin, Self.altomax);

end;


procedure TCDef_select.Load( xent: TFPHTTPConnectionRequest; ValIni: string );
begin
    Self.cf.load(xent, valini);
end;

function TCDef_select.get_valor: string;
var
  n, k: integer;
  res: string;
  acf: TCF_Base_Multi;
begin
  acf:= cf as TCF_Base_Multi;
  n := acf.nsels;
  res := '';
  if (n = 0) then
  begin
    result:= res;
    exit;
  end;

  if arrayOfKeys <> nil then
  begin
      res:= acf.lst_valor[0];
      for k := 1 to n-1 do
        res:= res + ', ' + acf.lst_valor[k];
  end
  else
  begin
    res := acf.palabraSel(0);
    for k := 1 to n-1 do
      res := res + ', ' + acf.palabraSel(k);
  end;
  result:= res;
end;

procedure TCDef_select.set_valor( nuevoValor: string );
var
  acf: TCF_Base_Multi;
begin
    acf:= cf as TCF_Base_Multi;
    acf.load(nil, nuevoValor );
end;



constructor TCDef_lookup.Create(
  nombre: string;
  ds: TDB_ds;
  campo_nombre: string = 'nombre';
  campo_llave: string = 'nid';
  seleccione: string = '';
  key_seleccione: string = '0');

var
  n, k, j: integer;
  valores, llaves: TStringList;
  iNombre, iLlave: integer;
  r: TDB_row;
  ic_Nombre, ic_Llave: integer;
begin
    valores:= TStringList.Create;
    llaves:= TStringList.Create;

    if (ds <> nil ) then
    begin
        n := ds.nrows;

        ic_llave:= ds.indexOfField( campo_llave );
        ic_nombre:= ds.indexOfField( campo_nombre );

        j := 0;
        if (seleccione <> '') then
        begin
            valores.add( seleccione );
            llaves.add( key_seleccione );
            inc( j );
        end;


        r:= ds.first;
        while r <> nil do
        begin
            valores.add( r[ic_nombre] );
            llaves.add( r[ ic_llave] );
        end;

      end
      else
      begin
        if (seleccione <>'') then
        begin
            valores.add( seleccione );
            llaves.add( key_seleccione );
        end;
    end;
     inherited Create(nombre, valores, llaves);
end;



constructor TCDef_fecha.Create( nombre: string;
    ancho: integer; extras: string='';
    js_BeforeShow: string='';
    js_AfterHide: string='');
var
  sfecha: string;
begin
  inherited Create(nombre, ancho, extras);
  js_BeforeShow:= js_BeforeShow;
  js_AfterHide:= js_AfterHide;
  sfecha:= '01/01/1990';
  Self.cf:= TCF_fecha.Create(Self.owner_rec.nombre, nombre, Self.ancho, Self.js_BeforeShow, Self.js_AfterHide, Self.extras);
end;

procedure TCDef_fecha.append_to_update_sql( var sqlupdate: string);
var
  sfecha: string;
begin
    if (sqlupdate <> '') then sqlupdate := sqlupdate+ ', ';
    sfecha := EUToISO(trim(Self.get_valor()));
    sqlupdate := sqlupdate+ Self.nombre + ' = "' + addslashes(sfecha) + '" ';
end;

procedure TCDef_fecha.Load( xent: TFPHTTPConnectionRequest; ValIni: string );
var
  sfecha: string;
begin
    sfecha := ISOToEU(ValIni);
    Self.cf.load(xent, sfecha);
end;

constructor TCDef_fecha_simple.Create(nombre: string; extras:string='');
var
  s: string;
begin
    inherited Create( nombre, 1, extras );
    s:= self.extras +' onkeydown="return(event.resultValue=onkeydown_solodigitos( this,20,event));" style="text-align: right"';
    Self.dia := TCF_text.Create(Self.nombre + '_dia_', 2, s);
    Self.mes := TCF_text.Create(Self.nombre + '_mes_', 2, s);
    Self.anio :=  TCF_text.Create(Self.nombre + '_anio_', 4, s);
end;

procedure TCDef_fecha_simple.Free;
begin
    dia.Free;
    mes.Free;
    anio.Free;
    inherited Free;
end;

function TCDef_fecha_simple.get_valor: string;
begin
    result:= trim(Self.anio.valor)
            + '-' + trim(Self.mes.valor)
            + '-' + trim(Self.dia.valor);
end;

function TCDef_fecha_simple.html_str: string;
var
  s: string;
begin
    s:= '';
    apr( s, '<table bgcolor="orange" width="100" border="0" cellpadding="1" cellspacing="1">' );
    apr( s, '<tr>' );
    apr( s, '<td align="center" bgcolor="white">Día</td>' );
    apr( s, '<td align="center" bgcolor="white">Mes</td>' );
    apr( s, '<td align="center" bgcolor="white">Año</td>' );
    apr( s, '</tr>' );

    apr( s, '<tr>' );
    apr( s, '<td align="center" bgcolor="white">' + dia.html_str + '</td>' );
    apr( s, '<td align="center" bgcolor="white">' + mes.html_str + '</td>' );
    apr( s, '<td align="center" bgcolor="white">' + anio.html_str + '</td>' );
    apr( s, '</tr>' );
    apr( s, '</table>' );

    result:= s;
end;

procedure TCDef_fecha_simple.append_to_update_sql( var sqlupdate: string);
var
  sfecha: string;
begin
    if sqlupdate <> '' then sqlupdate:= sqlupdate+', ';
    sfecha := Self.get_valor;
    sqlupdate:= sqlupdate + Self.nombre + ' = "' + addslashes(sfecha) + '" ';
end;


procedure TCDef_fecha_simple.Load( xent: TFPHTTPConnectionRequest; ValIni: string );
var
  v: string;
  v_anio, v_mes, v_dia: string;
  i, j: integer;
begin
    v := trim( valIni );
    if v = '' then
    begin
        v_anio:= '';
        v_mes:= '';
        v_dia:= '';
    end
    else
    begin
      i:= strpos(v, '-');
      v_anio:= substr(v, 0, i);
      j:= strpos(v, '-', i + 1);
      v_mes:= substr(v, i + 1, j - i - 1);
      v_dia:= substr(v, j + 1);
      i:= strpos(v_dia, ' ');
      if i > 0 then v_dia:= substr(v_dia, 0, i);
    end;
    dia.load( xent, v_dia);
    mes.load( xent, v_mes);
    anio.load( xent, v_anio);
end;



constructor TCDef_fecha_combos.Create(nombre: string; extras: string='');
begin
    inherited Create( nombre, 1, extras );
    Self.dia:= TCF_select.Create(nombre + '_dia_', arri(1, 31), false, 1, 1);
    Self.mes:= TCF_select.Create(nombre + '_mes_', arri(1, 12), false, 1, 1);
    Self.centuria:= TCF_select.Create(nombre + '_centuria_', arri(19, 20), false, 1, 1);
    Self.decena:= TCF_select.Create(nombre + '_decena_', arri(00, 99), false, 1, 1);
end;


procedure TCDef_fecha_combos.Free;
begin
   dia.Free;
   mes.Free;
   centuria.Free;
   decena.Free;
   inherited Free;
end;

function TCDef_fecha_combos.get_valor: string;
var
  res: string;
begin
   res := get_valor_campo(centuria)+
            get_valor_campo(decena)
            + '-' + get_valor_campo(mes)
            + '-' + get_valor_campo(dia);

    result:= res;
end;

function TCDef_fecha_combos.get_valor_campo( campo: TCF_select ): string;
var
  n: integer;
begin
    n := campo.nsels;
    if n = 0 then
      result:= ''
    else
      result:= campo.palabraSel(0);
end;

function TCDef_fecha_combos.html_str: string;
var
  s: string;
begin
    s:= '';
    apr( s, '<table bgcolor="orange" width="100" border="0" cellpadding="1" cellspacing="1">' );
    apr( s, '<tr>' );
    apr( s, '<td align="center" bgcolor="white">Día</td>' );
    apr( s, '<td align="center" bgcolor="white">Mes</td>' );
    apr( s, '<td align="center" bgcolor="white">Año<br>(cent)</td>' );
    apr( s, '<td align="center" bgcolor="white">Año<br>(dec)</td>' );
    apr( s, '</tr>' );

    apr( s, '<tr>' );
    apr( s, '<td align="center" bgcolor="white">' +dia.html_str+ '</td>' );
    apr( s, '<td align="center" bgcolor="white">' +mes.html_str+ '</td>' );
    apr( s, '<td align="center" bgcolor="white">' +centuria.html_str+ '</td>' );
    apr( s, '<td align="center" bgcolor="white">' +decena.html_str+ '</td>' );
    apr( s, '</tr>' );
    apr( s, '</table>' );
    result:= s;
end;

procedure TCDef_fecha_combos.append_to_update_sql( var sqlupdate: string );
var
  sfecha: string;
begin
    if sqlupdate <> '' then sqlupdate:= sqlupdate+', ';
    sfecha := get_valor;
    sqlupdate:= sqlupdate +nombre+' = "' +addslashes(sfecha)+'" ';
end;

function TCDef_fecha_combos.arri(i1, i2: integer): TStrings;
var
  res: TStrings;
  i: integer;
begin
    res := TStringList.Create;
    res.add('??');
    for i:= i1 to i2 do
      res.add( pad(IntToStr( i ), 2) );
    result:= res;
end;

procedure TCDef_fecha_combos.Load( xent: TFPHTTPConnectionRequest; ValIni: string );
var
  v: string;
  v_mes, v_dia, v_centuria, v_decena: string;
  i, j: integer;

  d_anio, d_centuria, d_decena: integer;
begin
    v := trim( valini );

    if v = '' then
    begin
        v_mes:= '1';
        v_dia:= '1';
        v_centuria:= '1';
        v_decena:= '13';
    end
    else
    begin
        i := strpos(v, '-');
        d_anio := StrToInt( substr(v, 0, i) );
        d_centuria := d_anio div 100;
        d_decena:= d_anio - d_centuria * 100;
        j := strpos(v, '-', i + 1);
        v_mes:= substr(v, i + 1, j - i - 1);
        v_dia:= substr(v, j + 1);
        i := strpos(v_dia, ' ');
        if i > 0 then
            v_dia:= substr(v_dia, 0, i);
        v_centuria:= IntToStr( d_centuria - 18 );
        v_decena:= IntToStr( d_decena + 1 );
    end;

    dia.load( xent, v_dia);
    mes.load(xent, v_mes);
    centuria.load(xent, v_centuria );
    decena.load(xent, v_decena );
end;



constructor TCDef_font.Create( nombre: string; extras: string = '');
begin
    inherited Create(nombre, 12);
    Self.cf:= TCF_font.Create(Self.nombre, extras);
end;


constructor TCDef_karchi.Create( nombre, karchi, tipo: string);
begin
    inherited Create(nombre, 1);
    Self.karchi:= karchi;
    Self.tipo := tipo;
    Self.existe := false;
    Self.cf := TCF_file.Create(Self.nombre, '');
end;

procedure TCDef_karchi.Load( xent: TFPHTTPConnectionRequest; ValIni: string );
begin
    if cf <> nil then cf.Free;

    if ValIni = '' then
    begin
        Self.cf:= TCF_file.Create(Self.nombre, '');
        Self.existe:= false;
    end
    else
    begin
        Self.cf:= TCF_checkbox.Create(Self.nombre, '1', 'Eliminar');
        Self.existe:= true;
    end;
end;

function TCDef_karchi.url_archi(nido, karchi, tipo: string): string;
var
  tabla, archi: string;
begin
    tabla:= Self.owner_rec.tabla;
    archi:= nido + '_' + karchi + '.' + tipo;
    result:= subcarpetaRaiz + '/tabla/archis/'+archi;
end;

function TCDef_karchi.parch23(nido: string; existe: boolean; karchi, tipo: string): string;
var
  s: string;
begin
    s:= '';
    apr( s, '<td>' );
    if Self.existe then
    begin
        apr( s, '<table border="1"><tr><td>' );
        apr( s, '<a href="' + url_archi( owner_rec.nido, karchi, tipo) + '"><img src="/images/icono_' +tipo + '.gif" border="0"></a>' );
        apr( s, '</td></tr><tr><td>' );
        apr( s, '<INPUT type="button" value="ELIMINAR ARCHIVO" onclick="pO( this.form, ''delarchi_'+tipo+''', '+owner_rec.nido+', '+karchi+' );">');
        apr( s, '</td></tr></table>');
    end
    else
        apr( s, '<INPUT type="button" value="SUBIR ARCHIVO('+tipo+')" onclick="pO( this.form, ''uparchi_'+tipo+''', '+owner_rec.nido+', '+karchi+' );">');
    apr( s, '</td>' );
    result:= s;
end;

function TCDef_karchi.get_valor: string;
begin
   if existe then
    result:= '1'
   else
    result:= '0';
end;




constructor TColumn.Create( caption, nombre: string; ordenable: integer; sql_select: string );
begin
    Self.caption:= caption;
    Self.nombre:= nombre;
    Self.ordenable:= ordenable;
    Self.str_select:= sql_select;
end;


procedure TColumn.addToSqlSelect(var sql: string);
begin
    if sql <> '' then sql := sql + ', ';
    if str_select <> '' then
      sql := sql + str_select + ' as ' + nombre
    else
      sql := sql + nombre;
end;



procedure TColumn.calc_order_by_params( order_by_names, order_by_status: TStrings );
var
  n, k: integer;
  buscando: boolean;
begin
    n := order_by_names.count;
    buscando := true;
    k := 0;
    while buscando and (k < n) do
    begin
      if order_by_names[k] = nombre then
        buscando := false
      else
        inc( k );

    end;
    if buscando then
    begin
        Self.order_by_status:= 0;
        Self.order_by_kindex:= 1;
    end
    else
    begin
        Self.order_by_status:= StrToInt( order_by_status[k] );
        Self.order_by_kindex:= k;
    end;
end;

function TColumn.get_order_by_html_str: string;
var
  s: string;
begin
  s := '';
  if ordenable <> 0 then
  begin
      case order_by_status of
      0 : if  ordenable > 0 then
                  s:= ' '
               else
                  s:= ' DESC';
      1 : s := ' DESC';
      - 1: s := ' ';
      end;
      s := nombre + s;
  end;
  result:= s;
end;


constructor TListado.Create(
  caption, form_name: string;
  db: TDB_con;
  tabla: string;
  nrpp, krec0, ncols: integer;
  insertarAlFinal: boolean;
  filtro, order_by: string;
  con_buscador: boolean;
  strbuscar: string;
  campos_buscar: TStrings;
  ordenable: boolean;
  joins: string = '';
  url_volver: string = 'index.php';
  acapite: string = '');

var
  i: integer;

begin
    Self.caption:= caption;
    Self.form_name:= form_name;
    Self.db:= db;
    i:= strpos( tabla, ' as ');
    if i < 0 then
    begin
        Self.tabla:= tabla;
        Self.apodo_tabla:= tabla;
    end
    else
    begin
        Self.tabla:= trim(substr(tabla, 0, i));
        Self.apodo_tabla:= trim(substr(tabla, i + 4));
    end;
    Self.krec0:= krec0;
    Self.nrpp:= nrpp;
    Self.ncols:= ncols;
    Self.insertarAlFinal:= insertarAlFinal;
    Self.filtro:= filtro;
    Self.order_by:= order_by;
    Self.con_buscador:= con_buscador;
    Self.campos_buscar:= campos_buscar;
    Self.strbuscar:= trim(strbuscar);
    Self.ordenable:= ordenable;
    Self.joins:= joins;
    Self.calc_order_by_arrays;
    Self.url_volver:= url_volver;
    Self.texto_volver:= '&lt;- Volver';
    Self.acapite:= acapite;
    Self.BT_AGREGAR:= true;
end;

procedure TListado.calc_order_by_arrays;
var
  a: TStrings;
  n: integer;
  k: integer;
  b: TStrings;
  m: integer;
begin
    Self.order_by_names:= TStringList.Create;
    Self.order_by_status:= TStringList.Create;
    if order_by <> '' then
    begin
        a:= explode(',', Self.order_by);
        n:= a.count;
        if n > 0 then
        begin
            for k := 0 to n -1 do
            begin
                b:= explode(' ', a[k]);
                m:= b.count;
                Self.order_by_names.add( trim(b[0]) );
                if m = 1 then
                    Self.order_by_status.add('1')
                else
                begin
                    if trim(b[1]) = '' then
                      order_by_status.add('1')
                    else
                      order_by_status.add( '-1' );
                end;
            end;
        end;
    end;
end;

function TListado.get_order_by: string;
begin
    if order_by = '' then
    begin
        if insertarAlFinal then
            result:= apodo_tabla+'.korden, '+apodo_tabla+'.nid' // los últimos serán los últimos
        else
            result:= apodo_tabla+'.korden, '+apodo_tabla+'.nid DESC'; // los últimos serán los primeros

    end
    else
        result:= order_by;
end;

// retorna el array con los textos html para la botonera de ordenamiento
// según sea el despliegue de la tabla, la botonera va en una fila arriba
// independiente de la tabla de datos o es la primer fila.
function TListado.get_header_row: string;
var
  s: string;
  n: integer;
  k: integer;
  u: string;
begin
    s := '<tr>';
    n := cdfs.count;
    for k:= 0 to n-1 do
    begin
        TColumn( cdfs[k] ).calc_order_by_params(order_by_names, order_by_status);
        u := TColumn( cdfs[k] ).get_order_by_html_str;
        s:= s+'<td>';
        if u <> '' then
            s := s+ '<a href="javascript:pO( document.forms[0],''change_order_by'','''+u+''',0);">';

        s := s+ TCOlumn( cdfs[k] ).caption;
        if u <> '' then s := s+ '</a>';
        s:= s+'</td>';
    end;
    s:= s+'</tr>';
    result:= s;
end;

procedure TListado.addCol( caption, nombre: string; ordenable:integer=0; sql_select:string= '');
begin
    cdfs.add( TColumn.Create(caption, nombre, ordenable, sql_select));
end;

function TListado.getBotonera(r_nid, r_activa: string ): string;
var
  s: string;
  n: integer;
  k: integer;
begin
    s:= '';

    if botonera<> nil then
    begin
        // formato moderno, la botonera es un array de objetos TBoton
        n:= botonera.count;
        for k:= 0 to n-1 do
            s:= s+ TBoton( botonera[k] ).html_str( r_nid, r_activa);
    end
    else
    begin
        // formato simple
        if ( botonera_M and BT_SEMAFORO)>0 then
        begin
            if r_activa='1' then
              s:= s+ botong('imagesscar/semverde.gif', 'Desactivar', 'pO( this.form,  ''act0'', '+r_nid+', 0 );')
            else
              s := s+botong('imagesscar/semrojo.gif', 'Activar', 'pO( this.form,  ''act1'', ' + r_nid+', 0 );');
        end;

        if (botonera_M and BT_SUBIR)>0 then
            s := s+botong('imagesscar/subir.gif', 'Subir', 'pO( this.form,  ''deck'', '+r_nid+', 0 );');
        if (botonera_M and BT_BAJAR)>0 then
            s := s+botong('imagesscar/bajar.gif', 'Bajar', 'pO(  this.form, ''inck'', '+r_nid+', 0 );');

        if (botonera_M and BT_ELIMINAR)>0 then
           s:= s+botong('imagesscar/b_drop.png', 'Eliminar', 'pO( this.form,  ''delrec'', '+r_nid+', 0 );');
        if (botonera_M and BT_EDITAR)>0 then
            s := s+botong('imagesscar/b_edit.png', 'Editar', 'pO(  this.form, ''editrec'', '+r_nid+', 0 );');

        if (botonera_M and BT_AL_INICIO)>0 then
            s:= s+botong('imagesscar/ssubir.gif', 'Al inicio', 'pO(  this.form, ''ddeck'', '+r_nid+', 0 );');
        if (botonera_M and BT_AL_FINAL)>0 then
            s:= botong('imagesscar/bbajar.gif', 'Al final', 'pO(  this.form, ''iinck'', '+r_nid+', 0 );');

        if (botonera_M and BT_VIEW)>0 then
            s:= s+botong('imagesscar/b_view.png', 'Ver', 'pO(  this.form, ''view'', '+r_nid+', 0 );');
    end;
    result:= s;
end;


function TListado.getSqlBuscar( strbuscar: string ): string;
var
  res: string;
begin
    res := '';
    if ((Self.campos_buscar<> nil)and (strbuscar <> '')) then
        if campos_buscar.count > 0 then
            res := construirFiltroBusquedaTexto(strbuscar, campos_buscar);
    result:= res;
end;

function TListado.getSqlSelect(where: string; krec0, nrpp: integer; order_by: string ): string;
var
  sql: string;
  k: integer;
begin
    sql := 'SELECT SQL_CALC_FOUND_ROWS '+apodo_tabla+'.nid, '+apodo_tabla+'.activa';
    for k := 0 to cdfs.count-1 do TColumn( cdfs[k] ).addToSqlSelect(sql);
    sql := sql +' FROM '+tabla+' as '+apodo_tabla;
    if joins <> '' then  sql := sql + ' '+Self.joins;
    sql :=  sql+' WHERE '+apodo_tabla+'.activa >= 0 ';
    if where <> '' then  sql := sql+' AND '+where;
    if order_by <>'' then sql := sql +' ORDER BY ' +order_by;
    sql:= sql+' LIMIT '+IntToStr(krec0)+', '+IntToStr( nrpp );
    result:= sql;
end;

function TListado.form_begin: string;
begin
    result:='<form method="POST" enctype="multipart/form-data" name="'+form_name
    +'" onsubmit="return pO(this, ''buscar'',0,0);>'#10;
end;

function TListado.form_end: string;
begin
    result:= '</form>'#10;
end;

function TListado.despliegue_multi_record( ds: TDB_ds; nrows: integer): string;
var
  s: string;
  icol: integer;
  anchoCol: string;
  krow: integer;
  iActiva: integer;
  iNid: integer;
  bgc: string;
  iCampo: array of integer;
  k, n: integer;
  r: TDB_row;

begin
    s:= '';
    if ordenable then
        s:= s+'Odernador:<table>'+get_header_row+'</table>';

    icol:= 1;
    anchoCol:= '%'+ IntToStr(trunc(100.0 / ncols + 0.5));
    s:= s+'<table border= "1" width="100%">';

    if nrows > 0 then
    begin
      iActiva:= ds.indexOfField( 'activa' );
      iNid:= ds.indexOfField( 'nid' );
      setlength( iCampo,  cdfs.count );
      for k:= 0 to cdfs.count -1 do
        iCampo[k]:= ds.IndexOfField( TColumn( cdfs[k] ).Nombre );

      r:= ds.first;
      for krow:= 0 to nrows-1 do
      begin

          if (r[iActiva] = '1') then
              bgc:= '#00C700'
          else
              bgc:= '#C70000';


          if icol = 1 then s:= s+'<tr>';

          // inicio del record ----------------------
          s := s+'<td width="'+anchoCol+'" bgcolor="'+bgc+'" >';
          s := s+'<table border="0" cellpadding="0" cellspacing="0" width="100%">';
          s := s+'<tr><td width="100%" align="right">';
          s := s+Self.getBotonera(r[iActiva], r[iNid]);
          s := s+'</td></tr>';
          s := s+'<tr><td>';
          n := cdfs.count;
          for k:= 0 to n-1 do
          begin
              if k > 0 then s:= s+', ';
              s:=s+ TColumn( cdfs[k] ).caption +r[iCampo[k]];
          end;

          s:= s+'</td></tr></table>';
          s:= s+'</td>';
          // fin de un record ----------------------------------------------------

          inc( icol );
          if icol > ncols then
          begin
              icol:= 1;
              s := s+'</tr>';
          end;
          r:= ds.next;
      end;

      if icol > 1 then
      begin

          while (icol < (ncols + 1)) do
          begin
              s := s+'<td>';
              s := s+'<p align="center">&nbsp;</p></td>';
              if icol =ncols then s := s+'</tr>';
              inc( icol );
          end;
      end;

    end;

    s:= s+'</table>';

    result:=s;
end;

function TListado.html_str: string;
var
  filtrox, sql: string;
  ds: TDB_ds;
  s: string;
  boton_agregar: string;
  tabla_psigpant_begin, tabla_psigpant_end: string;
begin

    //    Hacemos la consulta
    if con_buscador and (strbuscar <> '') then
        filtrox:= getSqlBuscar(strbuscar)
    else
        filtrox:= '';

    if filtro <> '' then
        if filtrox <> '' then
            filtrox:= filtro+' AND '+filtrox
        else
            filtrox:= filtro;


    sql:= getSqlSelect(filtrox, krec0, nrpp, get_order_by);

    ds:= db.query(sql);
    nrows:= ds.nrows;
    nrows_total:= StrToInt( db.f('SELECT FOUND_ROWS();') );
    nrows:= nrows;

    kpag:= ceil(krec0 / nrpp);
    npags:= ceil(nrows_total / nrpp);

    krec0_siguientes:= (kpag + 1) * nrpp;
    hay_siguientes:= krec0_siguientes < nrows_total;

    krec0_anteriores:= (kpag - 1) * nrpp;
    if krec0_anteriores < 0 then krec0_anteriores:= 0;
    hay_anteriores:= krec0_anteriores < krec0;

    s:= '<table border="0" width="100%" cellspacing="0" cellpadding="0">';
    apr( s, '    <tr>');
    apr( s, '      <td width="100%">');
    apr( s, '<table width="100%"><tr><td width="*" align="left">' );
    apr( s, '<font color="orange" size="3"><b>Administración de '+caption+'</b></font>');
    if acapite <> '' then apr( s, acapite );
    if con_buscador then
    begin
        apr( s, '<br><input type="text" name="strbuscar" value ="'+strbuscar+'">' );
        apr( s, '&nbsp;<input type="submit" name="bt_buscar" value="Buscar" onclick="javascript:pO( this.form, ''buscar'', 0, 0 );">');
        apr( s, '&nbsp;<input type="button" name="bt_buscar_clear" value="[x]" onclick="javascript:pO( this.form, ''buscar_clear'', 0, 0 );">');
    end
    else
        apr( s, '<br><input type="hidden" name="strbuscar" value ="'+strbuscar+'">' );

    apr( s, '<hr>Se encontraron: '+IntToStr( nrows_total )+' registros.' );
    apr( s, '</td><td width= "100" align="right">' );

    apr( s, '<a href="'+url_volver+'">'+texto_volver+'</a>');
    apr( s, '</td></tr></table>');
    apr( s, '<hr>');

    boton_agregar:= '<INPUT type="button" value="Agregar Nuevo" onclick="pO( this.form, ''addrec'', 0, 0 );">';

    tabla_psigpant_begin:= '<table width="100%" border="0">';

    apr( tabla_psigpant_begin, '<tr><td width= "*" align="center">' );
    (* como despliega camino comento esto
      $nombreSeccion= $db->f( 'SELECT nombre FROM secciones WHERE nid='.$nidsecc.' LIMIT 1 ' );
      echo 'Sección: '.$nombreSeccion;
     *)
    if hay_anteriores then
      apr( tabla_psigpant_begin, '<INPUT type="button" value="&lt; Anteriores" onclick="pO( this.form,  ''p_ant'', 0, 0 );">');

    if hay_siguientes then
      apr( tabla_psigpant_begin, '&nbsp;&nbsp;&nbsp;<INPUT type="button" value="Siguientes &gt;" onclick="pO( this.form,  ''p_sig'', 0, 0 );">');

    apr( tabla_psigpant_begin, '</td><td width= "34%" align="right">' );
    tabla_psigpant_end:= '</td></tr></table>';

    if BT_AGREGAR  then
        apr(s, tabla_psigpant_begin+boton_agregar+tabla_psigpant_end)
    else
        apr(s, tabla_psigpant_begin+tabla_psigpant_end );

    apr( s, despliegue_multi_record(ds, nrows ));

    // agrego tabla final con botones siguientes y anteriores
    apr( s, tabla_psigpant_begin+'&nbsp;'+tabla_psigpant_end );

    apr( s, '</td></tr></table>' );
    apr( s, '<table border="0" width="100%" cellspacing="0" cellpadding="0">');
    apr( s, '<tr><td width="100%"><hr></td></tr></table>' ) ;

    apr( s, '<INPUT type="hidden" name="xo" value="?">' );
    apr( s, '<INPUT type="hidden" name="order_by" value="'+order_by+'">' );
    apr( s, '<INPUT type="hidden" name="nido" value="0">');
    apr( s, '<INPUT type="hidden" name="kfoto" value="0">');
    apr( s, '<INPUT type="hidden" name="modo" value="1">');
    apr( s, '<INPUT type="hidden" name="krec0" value="'+IntToStr(krec0)+'">');

    ds.Free;
    result:= s;
end;



// funciones de listado_ordenado
procedure kreindex(db: TDB_con; tabla: string; nidsecc, order_by: string);
var
  sql: string;
  ds: TDB_ds;
  nrows: integer;
  r: TDB_row;
  k: integer;
begin
    if nidsecc <> '' then
        sql:= 'SELECT nid FROM '+tabla+' WHERE seccion='+nidsecc+' ORDER BY '+order_by
    else
        sql:= 'SELECT nid FROM '+tabla+' ORDER BY '+order_by;

    ds:= db.query(sql);
    nrows:= ds.nrows;

    r:= ds.first;
    k:= 0;
    while r <> nil do
    begin
        sql:= 'UPDATE '+tabla+' SET korden= '+IntToStr( k )+' WHERE nid= '+r[0]+' LIMIT 1 ';
        db.exec(sql);
        r:= ds.next;
        inc( k );
    end;
    ds.Free;
end;


// retorna el modo resultante.
function rec_ejecutar_xo(
  xent: TFPHTTPConnectionRequest;
  xsal: TFPHTTPConnectionResponse;
  var rec: TRecDef;
  var xo: string;
  var modo: integer;
  db: TDB_con;
  tabla: string;
  nidsecc: string;
  var nido: string;
  var krec0: integer;
  nrpp: integer;
  insertarAlFinal: boolean;
  nImagenesAManejar: integer = 0;
  manejarCarpetasPorFicha: boolean = true ): integer;

var
  order_by: string;
  proxkorden: string;
  sql: string;
  sql_a, sql_b: string;
  iFile: integer;
  userfile: TUploadedFile;
  tipoArchi: string;
  dest: string;
  dest_swm: string;
  destsmall: string;
  sqlstr: string;
  size: TImageSize;
  wimg, himg: integer;

begin
 //   global $carpetaRaizFotos, $carpetaRaizDocs, $kfoto, $fotogr_wmax, $fotogr_hmax, $fotoch_wmax, $fotoch_hmax;

    rec.nido:= nido;
    rec.nImagenesAManejar:= nImagenesAManejar;
    rec.manejarCarpetasPorFicha:= manejarCarpetasPorFicha;

    if insertarAlFinal then
        order_by:= 'korden, nid' // los últimos serán los últimos
    else
        order_by:= 'korden, nid DESC'; // los últimos serán los primeros


    // procesamiento de la orden
    if xo=  'cancel' then
    begin
            if modo = 3 then
            begin
                rec.load(xent, nido);
                rec.on_delete;
            end;
            modo:= 1;
    end
    else if xo = 'addrec' then
    begin
            nido:= IntToStr( db.nextval(tabla+'_nid_seq', true ) );
            if insertarAlFinal then
            begin
                if nidsecc <> '' then
                    proxkorden:= db.f('SELECT max( korden )+1 FROM '+tabla+' WHERE seccion= '+nidsecc )
                else
                    proxkorden:= db.f('SELECT max( korden )+1 FROM '+tabla  );

            end
            else
                proxkorden:= '0';

            rec.nido:= nido;

            sql_a:= 'INSERT INTO '+tabla+' ( nid, activa, korden, ic_dt, ic_usr, ic_nidneg, ic_nidpos ';
            sql_b:= ') VALUES ( '+nido+', -1, '+proxkorden+', now() , '+ ic_usr()+ ', 0, 0 ';

            rec.before_insert_sql_append(sql_a, sql_b);

            if (nidsecc <> '') then
                sql:= sql_a + ', seccion ' + sql_b + ', '+nidsecc+'  )'
            else
                sql:= sql_a + sql_b + '  )';


            // echo "<hr> ADDREC: $sql <hr>";

            db.exec(sql);
            modo:= 3;

            rec.on_addrec;
    end
    else if xo = 'editrec' then
    begin
            modo:= 2;
    end
    else if (xo = 'savepdf') or (xo = 'savemp3') or (xo = 'savevdo') then
    begin

            iFile:= xent.Files.IndexOfFile( 'userfile' );
            if iFile >= 0  then
            begin
                userfile:=xent.FILES[iFile];
                if xo = 'savepdf' then tipoArchi:= 'pdf'
                else if xo = 'savemp3' then tipoArchi:= 'mp3'
                else if xo = 'savevdo' then tipoArchi:= 'vdo';

                dest:= camino_archi(nido, rec.glob.kfoto, tipoArchi);

                if  ((tipoArchi = 'pdf') and (rec.glob.kfoto <= rec.glob.nPDFsAManejar))
                    or ((tipoArchi = 'mp3') and(rec.glob.kfoto <= rec.glob.nMP3sAManejar))
                    or ((tipoArchi = 'vdo') and (rec.glob.kfoto <= rec.glob.nVDOsAManejar)) then
                begin
                    if (userfile.Size > 500) then
                    begin
                        move_uploaded_file( userfile, dest);
                        sqlstr:= 'UPDATE '+tabla+' SET '+tipoArchi+IntToStr(rec.glob.kfoto)+'= 1 WHERE nid='+nido+' LIMIT 1';
                        db.exec(sqlstr);
                    end
                    else
                    begin
                        echo( xsal, 'El archivo es muy chico.');
                        echo( xsal, ' userfie_size: '+IntToStr( userfile.size ) );
                    end;
                end
                else
                  echo(xsal,  'el tipo: '+userfile.ContentType+' no es adecuado ');
            end;
            modo:= 2;
    end
    else if xo = 'saveimg' then
    begin
            dest_swm:= archi_fotogr_swm(nido, rec.glob.kfoto);
            dest:= archi_fotogr(nido, rec.glob.kfoto);
            destsmall:= archi_fotoch(nido, rec.glob.kfoto);
            iFile:= xent.Files.IndexOfFile( 'userfile' );
            if iFile >= 0  then
            begin
                userfile:=xent.FILES[iFile];
                if (strpos(userfile.ContentType, 'mage/') > 0) then
                begin
                    if (userfile.size > 500) then
                    begin
                        if (fileExists(dest_swm)) then unlink(dest_swm);
                        move_uploaded_file(userfile, dest_swm);
                        encuadreImagen(dest_swm, 800, 600);
                        copyfile(dest_swm, dest);
                        encuadreImagen(dest, rec.glob.fotogr_wmax, rec.glob.fotogr_hmax);
                        if (rec.glob.usar_marcadeagua) then MarcaDeAgua(subcarpetaraiz, dest, dest);
                        if (fileExists(destsmall)) then unlink(destsmall);
                        copyfile(dest, destsmall);
                        encuadreImagen(destsmall, rec.glob.fotoch_wmax, rec.glob.fotoch_hmax);
                        size:= GetImageSize(dest);
                        wimg:= size[0];
                        himg:= size[1];
                        sqlstr:= 'UPDATE '+tabla+' SET img'+IntToStr(rec.glob.kfoto)+'= 1 WHERE nid='+nido;
                        db.exec(sqlstr);
                    end
                    else
                    begin
                        echo(xsal, 'imagen muy chica ');
                    end
                end
                else
                begin
                    echo(xsal, 'el tipo: '+userfile.ContentType+'no es adecuado ');
                end
            end;
            modo:= 2;
    end
    else if xo = 'delimg' then
    begin
            sqlstr:= 'UPDATE '+tabla+' SET img'+IntToStr(rec.glob.kfoto)+'=0 WHERE nid='+nido;
            db.exec(sqlstr);
            dest_swm:= archi_fotogr_swm(nido, rec.glob.kfoto);
            dest:= archi_fotogr(nido, rec.glob.kfoto);
            destsmall:= archi_fotoch(nido, rec.glob.kfoto);
            unlink(dest_swm);
            unlink(dest);
            unlink(destsmall);
            modo:= 2;
    end
    else if xo = 'delarchi_pdf' then
    begin
            sqlstr:= 'UPDATE '+tabla+' SET pdf'+IntToStr(rec.glob.kfoto)+'=0 WHERE nid='+nido;
            db.exec(sqlstr);
            dest:= camino_archi(nido, rec.glob.kfoto, 'pdf');
            unlink(dest);
            modo:= 2;
    end
    else if xo = 'delarchi_mp3' then
    begin
            sqlstr:= 'UPDATE '+tabla+' SET mp3'+IntToStr(rec.glob.kfoto)+'=0 WHERE nid='+nido;
            db.exec(sqlstr);
            dest:= camino_archi(nido, rec.glob.kfoto, 'mp3');
            unlink(dest);
            modo:= 2;
    end;



    if ((modo = 2) or (modo = 3)) then rec.load(xent, nido);


    if  ((xo = 'saverec') and ((modo = 2) or (modo = 3)))
         or (xo = 'upimg')
         or (xo = 'delimg')
         or (xo = 'save')
         or (xo = 'uparchi_pdf')
         or (xo = 'delarchi_pdf')
         or (xo = 'uparchi_mp3')
         or (xo = 'delarchi_mp3')
         or (xo = 'uparchi_vdo')
         or (xo = 'delarchi_vdo') then
              if (rec.update(modo)) then modo:= 1;


    if  (xo = 'upimg')
        or (xo = 'delimg')
        or (xo = 'uparch_pdf')
        or (xo = 'delarch_pdf')
        or (xo = 'uparch_mp3')
        or (xo = 'delarch_mp3')
        or (xo = 'uparch_vdo')
        or (xo = 'delarch_vdo')
        or (xo = 'save') then
             modo:= 2;

    if xo = 'upimg' then modo:= 4;
    if xo = 'uparchi_pdf' then modo:= 5;
    if xo = 'uparchi_mp3' then modo:= 6;
    if xo = 'uparchi_vdo' then  modo:= 7;

    result:= modo;
end;

function lst_ejecutar_xo(
  xent: TFPHTTPConnectionRequest;
  xsal: TFPHTTPConnectionResponse;
  glob: TRecEdit_Globs;

  var lst: TListado;
  var xo: string;
  var modo: integer;
  db: TDB_con;
  tabla: string;
  nidsecc: string;
  nido: string;
  krec0, nrpp: integer;
  insertarAlFinal: boolean;
  nImagenesAManejar: integer = 0;
  manejarCarpetasPorFicha: boolean = true ): integer;


var
  order_by: string;
  sql: string;
  korden: string;
  ds: TDB_ds;
  r: TDB_row;
  nid2: string;
  korden2: string;

begin
//    global $carpetaRaizFotos, $carpetaRaizDocs;

    if insertarAlFinal then
        order_by:= 'korden, nid' // los últimos serán los últimos
    else
        order_by:= 'korden, nid DESC'; // los últimos serán los primeros


    if xo = 'buscar_clear' then
    begin
            lst.strbuscar:= '';
            xo:= '?';
    end
    else if ( xo = 'buscar' ) or ( xo = 'filter') or ( xo = 'filtrar' ) then
    begin
            lst.krec0:= 0;
            krec0:= 0;
    end
    else if xo = 'regenerar' then
    begin
 //???           generar_todo;
            echo( xsal, 'xo = regenerar ???? no se qué hay que hacer' );
            modo:= 1;
            xo:= '?';
    end
    else if xo = 'act0' then
    begin
            sql:= 'UPDATE '+tabla+' SET activa=0 WHERE nid= '+nido;
            db.exec(sql);
    end
    else if xo = 'act1' then
    begin
            sql:= 'UPDATE '+tabla+' SET activa=1 WHERE nid='+nido;
            db.exec(sql);
    end
    else if xo = 'delrec' then
    begin
            if nImagenesAManejar > 0 then deletefotos(tabla, nido);
            if manejarCarpetasPorFicha then eliminar_directorios_ficha(tabla, nido);
            sql:= 'DELETE FROM '+tabla+' WHERE nid='+nido;
            db.exec(sql);
            modo:= 1;
    end
    else if xo = 'deck' then
    begin
            kreindex(db, tabla, nidsecc, order_by);
            korden:= db.f('SELECT korden FROM '+tabla+' WHERE nid='+nido);
            if nidsecc <> '' then
                sql:= 'SELECT nid, korden FROM '+tabla+' WHERE (korden < '+korden+') and (seccion='+nidsecc+') ORDER BY korden DESC'
            else
                sql:= 'SELECT nid, korden FROM '+tabla+' WHERE (korden < $korden) ORDER BY korden DESC';


            ds:= db.query(sql);
            if ds.nrows > 0 then
            begin
                r:= ds.first;
                nid2:= r[0];
                korden2:=r[1];
                sql:= 'UPDATE '+tabla+' SET korden='+korden2+' WHERE nid='+nido;
                db.exec(sql);
                sql:= 'UPDATE '+tabla+' SET korden='+korden+' WHERE nid='+nid2;
                db.exec(sql);
            end;
            ds.Free;
    end
    else if xo = 'ddeck' then
    begin
            kreindex(db, tabla, nidsecc, order_by);
            korden:= db.f('SELECT korden FROM '+tabla+' WHERE nid='+nido);

            if nidsecc<>'' then
                sql:= 'SELECT nid, korden FROM '+tabla+' WHERE (korden < '+korden+') and (seccion='+nidsecc+') ORDER BY korden DESC'
            else
                sql:= 'SELECT nid, korden FROM '+tabla+' WHERE (korden < '+korden+') ORDER BY korden DESC';

            ds:= db.query(sql);
            korden2:= korden;
            r:= ds.first;
            while r <> nil do
            begin
                nid2:= r[0];
                sql:= 'UPDATE '+tabla+' SET korden='+korden2+' WHERE nid='+nid2;
                korden2:= r[1];
                db.exec(sql);
                r:= ds.next;
            end;
            sql:= 'UPDATE '+tabla+' SET korden='+korden2+' WHERE nid='+nido;
            db.exec(sql);
            ds.Free;
    end
    else if xo='inck' then
    begin
            kreindex(db, tabla, nidsecc, order_by);
            korden:= db.f('SELECT korden FROM '+tabla+' WHERE nid='+nido );
            if nidsecc<>'' then
              sql:= 'SELECT nid, korden FROM '+tabla+' WHERE (korden > '+korden+') and (seccion='+nidsecc+') ORDER BY korden'
            else
              sql:= 'SELECT nid, korden FROM '+tabla+' WHERE (korden > '+korden+') ORDER BY korden ';

            ds:= db.query(sql);
            if ds.nrows > 0 then
            begin
                r:= ds.first;
                nid2:= r[0];
                korden2:= r[1];
                sql:= 'UPDATE '+tabla+' SET korden='+korden2+' WHERE nid='+nido;
                db.exec(sql);
                sql:= 'UPDATE '+tabla+' SET korden='+korden+' WHERE nid='+nid2;
                db.exec(sql);
            end;
            ds.Free;
    end
    else if xo = 'iinck' then
    begin
            kreindex( db, tabla, nidsecc, order_by);
            korden:= db.f('SELECT korden FROM '+tabla+' WHERE nid='+nido );

            if nidsecc<>'' then
                sql:= 'SELECT nid, korden FROM '+tabla+' WHERE (korden > '+korden+') and (seccion='+nidsecc+') ORDER BY korden '
            else
                sql:= 'SELECT nid, korden FROM '+tabla+' WHERE (korden > '+korden+') ORDER BY korden ';

            ds:= db.query(sql);
            korden2:= korden;
            r:= ds.first;
            while r <> nil do
            begin
                nid2:= r[0];
                sql:= 'UPDATE '+tabla+' SET korden='+korden2+' WHERE nid='+nid2;
                korden2:= r[1];
                db.exec(sql);
                r:= ds.next;
            end;
            sql:= 'UPDATE '+tabla+' SET korden='+korden2+' WHERE nid='+nido;
            db.exec(sql);
            ds.Free;
    end
    else if xo= 'p_sig' then
    begin
            lst.krec0:= krec0 + nrpp;
    end
    else if xo='p_ant' then
    begin
            lst.krec0:= max(krec0 - nrpp, 0);
    end;

    result:= modo;
end;

function pimg1(nido: string; existe: boolean; kfoto: integer ): string;
var
  s: string;
begin
    if existe then
        s:= '<img src="'+ url_fotoch(nido, kfoto) + '?' + IntToStr( random(10000))+ '">'
    else
        s:= '[foto' + IntToStr(kfoto) + ']';
    result:= s;
end;

function pimg23( nido: string; existe: boolean; kfoto: integer;
    manejarUrlPorImagen: boolean;
    url: TCDef_text;
    TITULO_BOTON_CARGAR: string = 'CARGAR FOTO';
    TITULO_BOTON_ELIMINAR: string = 'ELIMINAR FOTO'): string;

var
  s: string;
begin
//    global $manejarUrlPorImagen;
    s:=  '<td align="center">';
    if existe then
    begin
        apr( s, '<table border="1"><tr><td>' );
        apr( s, '<img src="' + url_fotoch(nido, kfoto) + '?' + IntToStr(random(100000)) + '">' );
        apr( s, '</td></tr><tr><td>' );
        apr( s, '<INPUT type="button" value="'+TITULO_BOTON_ELIMINAR
            +'" onclick="pO( this.form, ''delimg'', '+nido+', kfoto );">' );
        apr( s, '</td></tr></table>' );
    end
    else
        apr( s, '<INPUT type="button" value="'+TITULO_BOTON_CARGAR+'" onclick="pO( this.form, ''upimg'', '+nido+', '+IntToStr(kfoto)+' );">');

    if manejarUrlPorImagen then
    begin
        apr( s,  '<hr>Link:<br>' );
        apr( s, url.html_str );
    end;
    apr( s, '</td>' );
end;


// funciones auxiliares para correr a mano
// regenerar los resúmenes
procedure regenerarResumenes(db: TDB_con; tabla: string; len_resumen: integer );
var
  ds: TDB_ds;
  r: TDB_row;
  resumen: string;
  sql: string;
begin
    ds:= db.query('SELECT nid, texto FROM '+tabla+' ORDER BY nid ');
    r:= ds.first;
    while r <> nil do
    begin
        resumen:= Str_Replace('<br>', #10, r[1]);
        resumen:= Str_Replace('<br />', #10, resumen);
        resumen:= Str_Replace('<p>', #10, resumen);
        while (strpos(resumen, #10#10)>=0) do resumen:= Str_Replace(#10#10, #10, resumen);
        resumen:= textoseguro( resumen);
        resumen:= nl2br(resumen);
        resumen:= substr(resumen, 0, len_resumen);
        sql:= 'UPDATE ' +tabla +' SET resumen= "'+ addslashes(resumen) + '" WHERE nid= '+ r[0]+ ' LIMIT 1 ';
        db.exec(sql);
        r:= ds.next;
    end;
  ds.Free;
end;

procedure regenerarImagenes(
      db: TDB_con; tabla: string;
      nfotos, fg_wmax, fg_hmax, fc_wmax, fc_hmax: integer;
      usar_marcadeagua: boolean );
var
  ds: TDB_ds;
  r: TDB_row;
  kfoto: integer;
  sql: string;
  nido: string;
  dest_swm, dest, destsmall: string;
  imgdefinida: boolean;
begin
    sql:= 'SELECT nid';
    for kfoto:= 1 to nfotos do
      sql:= sql +', img'+IntToStr( kfoto );

    ds:= db.query( sql+' FROM '+tabla+' ORDER BY nid ');
    r:= ds.first;
    while r <> nil do
    begin
        nido:= r[0];
        for kfoto:= 1 to nfotos do
        begin
            dest_swm:= archi_fotogr_swm(nido, kfoto);
            dest:= archi_fotogr(nido, kfoto);
            destsmall:= archi_fotoch(nido, kfoto);
            imgdefinida:= r[kfoto] = '1';
            if (imgdefinida and fileExists(dest_swm)) then
            begin
                unlink(dest);
                copyfile(dest_swm, dest);
                encuadreImagen(dest, fg_wmax, fg_hmax);
                if usar_marcadeagua then MarcaDeAgua(subcarpetaRaiz, dest, dest);
                unlink(destsmall);
                copyfile(dest, destsmall);
                encuadreImagen(destsmall, fc_wmax, fc_hmax);
            end;
        end;
      r:= ds.next;
    end;
    ds.Free;
end;


// sirve para convertir un campo de texto si decidimos usar el editor-html
procedure convertir_nl2br(db: TDB_con; tabla, campo: string);
var
  ds: TDB_ds;
  texto: string;
  r: TDB_row;
  sql: string;
begin
    ds:= db.query('SELECT nid, '+campo+' FROM '+tabla+' ORDER BY nid ');
    r:= ds.first;
    while r<> nil do
    begin
        texto:= nl2br(r[1]);
        sql:= 'UPDATE secciones SET '+campo+'= "'+addslashes(texto)+'" WHERE nid='+r[0];
        db.exec(sql);
        r:= ds.next;
    end;
    ds.Free;
end;

// clona el record con nid =  nido y le asigna un nuevo nid > 0
// El parámetro nido tiene que ser > 0.
// se retorna el nid del record clonado
// para clonar un record el m
function clonar_rec(db: TDB_con; tabla: string; nido: integer): integer;
var
  nuevo_nid: integer;
  tmptabla: string;

begin
    // global $db, $usrnid;
    if nido < 0 then
      result:= -1
    else
    begin
      nuevo_nid:= db.nextval(tabla+'_nid_seq', true);
      tmptabla:= tabla+'_bk'+IntToStr( nido );
      db.exec('CREATE TEMPORARY TABLE '+tmptabla+' SELECT * FROM '+tabla+' WHERE nid='+IntToStr(nido)+' LIMIT 1');
      db.exec('UPDATE '+tmptabla+' SET nid='+IntToStr(nuevo_nid)+', nidpos= 0, ic_dt= now(), ic_usr='+ic_usr);
      db.exec('INSERT INTO '+tabla+' SELECT * FROM '+tmptabla );
      db.exec('DROP TABLE '+tmptabla );
      result:= nuevo_nid;
    end;
end;

// copia el record  con nid=nido en un clon con NID negativo. El record con nid negativo (el backup)
// el parámetro nido tiene que ser > 0.
// se vincula con el record original por nidpos = nid_original
// si el parámetro delete == 0 quiere decir que NO queremos borrar el record original y en
// ese caso, se actualiza el nidneg del registro original para apuntar al registro de backup (el con nid negativo creado).
// si el parametro delete = 1 se elimina el registro orignal
function backup_rec(db: TDB_con; tabla: string; nido: integer; delete: boolean = false): boolean;
var
  nidneg: integer;
  tmptabla: string;
begin
    if nido < 0 then
        result:= false
    else
    begin
      nidneg:= db.nextval(tabla+'NEG_nid_seq', true);
      tmptabla:= tabla+'_bk'+IntToStr(nido) ;
      db.exec('CREATE TEMPORARY TABLE '+tmptabla+' SELECT * FROM '+tabla+' WHERE nid='+IntToStr(nido)+' LIMIT 1');
      if not delete then
          db.exec('UPDATE '+tmptabla+' SET nid='+IntToStr(nidneg)+', nidpos='+IntToStr(nido) )
      else
          db.exec('UPDATE '+tmptabla+' SET nid='+IntToStr(nidneg)+', nidpos= -'+IntToStr(nido));

      db.exec('INSERT INTO '+tabla+' SELECT * FROM '+tmptabla );
      db.exec('DROP TABLE '+tmptabla );

      if not delete then
          db.exec('UPDATE '+tabla+' SET nidpos=0, nidneg='+IntToStr(nidneg)+' WHERE nid='+IntToStr(nido)+' LIMIT 1')
      else
          db.exec('DELETE FROM '+tabla+' WHERE nid='+IntToStr(nido)+' LIMIT 1');

      result:= true;
    end;
end;

// backupea el registro nid = nidrec > 0 y lo elimina.
procedure backupdelete_rec(db: TDB_con; tabla: string; nidrec: integer);
begin
    backup_rec(db, tabla, nidrec, true);
end;


    constructor TCDef.Create( nombre: string; ancho: integer; extras: string = '');
    begin
        Self.nombre:= nombre;
        Self.ancho:= ancho;
        Self.extras:= extras;
        Self.dummy:= 0;
    end;

    procedure TCDef.Load( xent: TFPHTTPConnectionRequest; ValIni: string );
    begin
      cf.load( XENT, valIni );
    end;

    function TCDef.get_valor(): string;
    begin
        result:= cf.valor;
    end;

    procedure TCDef.set_valor( nuevoValor: string );
    begin
        cf.valini:= nuevoValor;
        cf.reset;
    end;

    procedure TCDef.append_to_update_sql(  var sqlupdate: string);
    begin
        if (sqlupdate <> '') then sqlupdate:= sqlupdate + ', ';
        sqlupdate:= sqlupdate + nombre + ' = "' + addslashes(trim(Self.get_valor())) + '" ';
    end;

    function TCDef.html_str: string;
    begin
        result:= cf.html_str;
    end;

    procedure TCDef.set_owner_rec( owner: TRecDef );
    begin
        owner_rec := owner;
    end;


    procedure TCDef.Free;
    begin
        cf.Free;
        inherited Free;
    end;


end.


