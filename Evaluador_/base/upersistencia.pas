unit upersistencia;

interface

uses
  Classes,
  SysUtils,
  ucosa;

Type

  { Interfaz De TDataCellOfCosa
  ---------------------------------------------------------------------------- }

  TDataFieldDefOfCosa = class
    nombre:  string;
    tipo:    TTipoCampo;
    version: Integer;
    constructor Create(xnombre: string; xtipo: TTipoCampo; xversion: Integer);
  end;

  TListDataFieldDefOfCosa = class(TList)

  end;

  { Interfaz De TDataRecOfCosa
  ---------------------------------------------------------------------------- }

  TDataRecordOfCosa = class
      str_vals: TList;
      ptr_vals: TList;
      constructor Create();
  end;

  TListDataRecordOfCosa = class(TList)

  end;

  { Interfaz De TDataSetOfCosa
  ---------------------------------------------------------------------------- }

  TDataSetOfCosa = class
      dataFieldDefList: TListDataFieldDefOfCosa;
      dataRecordList: TListDataRecordOfCosa;

      constructor Create(claseDeCosa: TCualquierClase);
      procedure AddDataRec(cosa: TCosa);

  end;


implementation

  { Implementación De TDataFieldDefOfCosa
  ---------------------------------------------------------------------------- }

  constructor TDataFieldDefOfCosa.Create(xnombre: string; xtipo: TTipoCampo; xversion: Integer);
  begin
    self.nombre  := xnombre;
    self.tipo    := xtipo;
    self.version := xversion;
  end;

  { Implementación De TDataRecordOfCosa
  ---------------------------------------------------------------------------- }

  constructor TDataRecordOfCosa.Create();
  begin
    self.str_vals := TList.Create();
    self.ptr_vals := TList.Create();
  end;

  { Implementación De TDataSetOfCosa
  ---------------------------------------------------------------------------- }

  constructor TDataSetOfCosa.Create(claseDeCosa: TCualquierClase);
  var
    data_rec: TDataRecordOfCosa;
  begin
    inherited Create;
    self.dataFieldDefList := claseDeCosa.GetListaDefCampos();
    self.dataRecordList := TListDataRecordOfCosa.Create();

  end;

  procedure TDataSetOfCosa.AddDataRecord(cosa: TCosa);
  var
    dataRecord: TDataRecordOfCosa;
  begin
    dataRecord := TDataRecordOfCosa.Create();
    self.dataRecordList.Add(dataRecord);
  end;

end.

