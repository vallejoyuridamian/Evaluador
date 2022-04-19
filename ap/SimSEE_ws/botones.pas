unit botones;
interface
uses
  uconstantesglobales;

// constantes para usar en la máscara de botonera.
const
  BT_SEMAFORO=1;
  BT_EDITAR=2;
  BT_ELIMINAR=4;
  BT_SUBIR=8;
  BT_BAJAR=16;
  BT_AL_INICIO=32;
  BT_AL_FINAL=64;
  BT_VIEW=128;
  BT_CUSTOM=256;



type
  TBoton = class
    tipo: integer;
    constructor Create( tipo: integer );
    function html_str( r_nid, r_activa: string ): string; virtual; // recibe un record con por lo menos 'activa' y 'nid'
  end;


TBoton_CUSTOM = class( TBoton )
  tipo: integer;
  img: string;
  hint: string;
  orden: string;
  constructor Create( img, hint, orden: string );
  function html_str( r_nid, r_activa: string ): string; override; // recibe un record con por lo menos 'activa' y 'nid'
end;




function botong(img, alt, accion: string): string;

implementation

function botong(img, alt, accion: string): string;
begin
    result:= '<button title="'+alt+'" onclick="'+accion+'; return false;"><img src="'+img+'" alt="'+alt+'" title="'+alt+'"></button>';
end;



(* Definición de la clase TBoton.
   En principio es para ser usada por udsrecedit.php
*)


  constructor TBoton.Create( tipo: integer );
  begin
    Self.tipo:= tipo;
  end;

  function TBoton.html_str( r_nid, r_activa: string ): string; // recibe un record con por lo menos 'activa' y 'nid'
  var
    s: string;
  begin
  //  global $base_url_imagesscar;
    case tipo of
      BT_SEMAFORO :
         if(r_activa= '1') then
            s:= botong(base_url_imagesscar+ 'semverde.gif', 'Desactivar', 'pO( this.form,  ''act0'', ' +r_nid+ ', 0 );')
         else
            s:= botong(base_url_imagesscar+ 'semrojo.gif', 'Activar', 'pO( this.form,  ''act1'', '+r_nid+ ', 0 );');

      BT_SUBIR:
         s:= botong(base_url_imagesscar+ 'subir.gif', 'Subir', 'pO( this.form,  ''deck'', '+r_nid+', 0;');

      BT_BAJAR:
         s:= botong(base_url_imagesscar+ 'bajar.gif', 'Bajar', 'pO(  this.form, ''inck'', '+r_nid+', 0;');

      BT_ELIMINAR:
         s:= botong(base_url_imagesscar+ 'b_drop.png', 'Eliminar', 'pO( this.form,  ''delrec'', '+r_nid+', 0;');

      BT_EDITAR:
         s:= botong(base_url_imagesscar+ 'b_edit.png', 'Editar', 'pO(  this.form, ''editrec'', '+r_nid+', 0;');

      BT_AL_INICIO:
         s:= botong(base_url_imagesscar+ 'ssubir.gif', 'Al inicio', 'pO(  this.form, ''ddeck'', '+r_nid+', 0;');

      BT_AL_FINAL:
         s:= botong(base_url_imagesscar+ 'bbajar.gif', 'Al final', 'pO(  this.form, ''iinck'', '+r_nid+', 0;');

      BT_VIEW:
         s:= botong(base_url_imagesscar+ 'b_view.png', 'Ver', 'pO(  this.form, ''view'', '+r_nid+', 0;');

      end;
    result:= s;
  end;


  constructor TBoton_CUSTOM.Create( img, hint, orden: string );
  begin
    self.tipo:= BT_CUSTOM;
    self.img:= img;
    self.hint:= hint;
    self.orden:= orden;
  end;

  function TBoton_CUSTOM.html_str( r_nid, r_activa: string ): string; // recibe un record con por lo menos 'activa' y 'nid'
  begin
    //global $base_url_imagesscar;
    result:= botong(base_url_imagesscar+img,  hint, 'pO(  this.form, '''+orden+''', ' +r_nid+ ', 0 );');
  end;


end.
