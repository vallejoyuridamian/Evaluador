unit uBaseEditoresFunciones;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uBaseAltasEditores, uFunciones, usalasdejuego, utilidades,
  StdCtrls;

type
  TClaseEditoresFunciones = class of TBaseEditoresFunciones;

  TBaseEditoresFunciones = class(TBaseAltasEditores)
	protected
		funcOrig : TFuncion;
		sala : TSalaDeJuego;
    tipoFunc: TClaseDeFuncion;

		function validarEditNombre(Sender : TObject) : boolean;
	public
		Constructor Create(AOwner : TForm ; func : TFuncion ; Sala : TSalaDeJuego ; alta : boolean ; tipoFunc : TClaseDeFuncion); reintroduce; virtual;
		function darFuncion: TFuncion; virtual; abstract;
	end;

var
  BaseEditoresFunciones: TBaseEditoresFunciones;

implementation

{$R *.dfm}
Constructor TBaseEditoresFunciones.Create(AOwner : TForm ; func : TFuncion ; Sala : TSalaDeJuego ; alta : boolean; tipoFunc: TClaseDeFuncion);
begin
  inherited Create(AOwner);
	self.Top:= AOwner.Top + plusTop;
	self.Left:= AOwner.Left + plusLeft;
	self.sala:= Sala;
	funcOrig:= func;
  self.tipoFunc:= tipoFunc;
	if func <> NIL then
		self.Caption:= 'Editar ' + func.DescClase
	else
		self.Caption:= 'Alta de ' + tipoFunc.DescClase;
	guardado:= true;
end;

function TBaseEditoresFunciones.validarEditNombre(Sender : TObject) : boolean;
var
	i, pos : Integer;
begin
  pos:= -1;// solo para evitar warning del compilador

  if TEdit(Sender).Text <> '' then
  begin
  	if funcOrig <> NIL then
      pos:= sala.Funcs.Remove(funcOrig);

 		if sala.listaFuentes.find(tipoFunc.ClassName, TEdit(Sender).Text, i) then
 		begin
	  	ShowMessage('Ya Existe Una ' + tipoFunc.DescClase + ' Con el Nombre Ingresado');
		  result:= false;
		end
  	else
     	result:= true;

    if funcOrig <> NIL then
    	sala.listaFuentes.insert(pos, funcOrig);
  end
  else
  begin
    ShowMessage('El Campo Nombre No Puede Ser Vacio');
    result:= false;
  end
end;

end.
