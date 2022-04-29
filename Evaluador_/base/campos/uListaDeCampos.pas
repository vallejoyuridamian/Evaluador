unit uListaDeCampos;

interface

uses
  uCampo
  ;

type
{$IFDEF FPC-LCL}
  TListaDeCamposBase = specialize TList<TCampo>;
  TListaDeCampos = class(TListaDeCamposBase)
{$ELSE}
  TListaDeCampos = class(TList<TCampo>)
{$ENDIF}
    public
      function buscarCampoPorNombre(const nombre: String): TCampo; overload;
      function buscarCampoPorNombre(const nombre: String; var campo: TCampo): boolean; overload;
  end;

{$IFDEF FPC-LCL}
  TListaDeCamposPrimitivosBase = specialize TList<TCampoPrimitivo>;
  TListaDeCamposPrimitivos = class(TListaDeCamposPrimitivosBase)
{$ELSE}
  TListaDeCamposPrimitivos = class(TList<TCampoPrimitivo>)
{$ENDIF}
    public
      function buscarCampoPorNombre(const nombre: String): TCampo; overload;
      function buscarCampoPorNombre(const nombre: String; var campo: TCampo): boolean; overload;
  end;

implementation

end.
