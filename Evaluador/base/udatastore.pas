unit udatastore;

{$mode delphi}

interface

uses
  Classes, SysUtils  uConversions;
type

  TSIUD = (TSELECT, TINSERT, TUPDATE, TDELETE);

  TValidation = class;
  TListValidation = class;

  DataTypeOfCosa = class of TDataTypeOfCosa;

  TDataTypeOfCosa = class;
  TDataColumnListOfCosa = class;
  TDataColumnOfCosa = class;

  TDataCellOfCosa = class;
  //TListDataCellOfCosa=class;

  //TListDataRowOfCosa=class;
  TDataRowOfCosa = class;

  //TListDataTableOfCosa=class;
  TDataTableOfCosa = class;
  TDataTableOfListOfCosa = class;

  TDataVTableOfCosa = class;

  TDataStore = class;

  TRelationships = class;



  //////////////////////////////////////////////////////////////////////////////
  //TSalaDeJuegoConnection
  //////////////////////////////////////////////////////////////////////////////
  //dfusco@20141001
  {Esta clase representa una conexión a la base de datos SALA DE JUEGO.}
  TSalaDeJuegoConnection = class
  private
    procedure writeline(const s: string);
    procedure wr(DataTableName: string; DataRowId: integer; tabulation: string);
  public
    FileName: WideString;
    FileHandler: TArchiTexto;
    f: TextFile;
    constructor Create(xFileName: WideString); overload;
    constructor Create(xFileHandler: TArchiTexto); overload;

    procedure ReadDataStoreFromTextFile(root: string);
    function WriteDataStoreToTextFile(filename: string = nil): boolean;

    procedure ProcessFile(SourceList: TStringList; var i: integer;
      var FPHashList: TCosaHashList);


  end;

  TGreekAlphabet = (alfa, beta, gama, delta, epsilon, zeta);

  TDAOfDataStore = array[TGreekAlphabet] of TDataStore;

  TColumnConstraint = (cr_PrimaryKey, cr_Unique);
  TColumnConstraints = set of TColumnConstraint;

  //////////////////////////////////////////////////////////////////////////////
  //TDataStore
  //////////////////////////////////////////////////////////////////////////////
  //dfusco@20141001
  {Esta clase representa un almacén de datos.}
  TDataStore = class
  private
    _DataTableList: TList;

  protected
    function GetDataTableByIndex(Index: integer): TDataTableOfCosa;
    function GetDataTableListCount: integer;

  public

    SetName: string;
    DataSetParent: TDataStore;

    Relations: TRelationships;

    procedure LoadFromCosaHashList(cosaHashList: TCosaHashList;
      root: string; version: integer);

    constructor Create(xDataSetParent: TDataStore);

    function ReadDataCellTextValue(TableName: string; RowId: integer;
      ColumnName: string; var sval: string; climb: boolean = False): boolean;
    function ReadDataCellTextValues(TableName, ColumnNameToQuery,
      CellSValToQuery, ColumnNameToGetSVal: string; climb: boolean = False): TDAofString;

    function ReadRowIdsTextValues(TableName, ColumnNameToQuery,
      CellSValToQuery: string): TDAofNInt;

    function WriteDataCellTextValue(TableName: string; RowId: integer;
      AttributeName: string; Value: string): boolean;

    procedure CreateClassInstance(TableName: string; RowId: integer; var cosa: TCosa);
    function CreateDataRowFromInstance(cosa: TCosa; DataTableName: string;
      RowName: string; climb: boolean = False): integer;

    function AddDataTable(xDataTable: TDataTableOfCosa): integer;
    property DataTableList[Index: integer]: TDataTableOfCosa read GetDataTableByIndex;
    function GetDataTableByName(DataTableName: string;
      climb: boolean = False): TDataTableOfCosa;
    function GetIndexOfDataTableByName(Name: string): integer;
    function GetDataTableList: TList;
    property DataTableListCount: integer read GetDataTableListCount;

    function Query(Select: string; FromName: string;
      ColumnNameToEval, Value: string; var ds: TDataStore): boolean; overload;
    function Query(Select: string; FromName: string; var ds: TDataStore): boolean;
      overload;
    function Query(Select: string; FromName: string; RowId: integer;
      var ds: TDataStore): boolean; overload;

    function GetEmptyTable(TableName: string; CloneIdCounter: boolean): TDataTableOfCosa;

    procedure DeleteDataRows(FromName: string; ColumnNameToEval, Value: string);

    function PrepareInsert(Into, ColumnName: string; RowId: integer;
      Value: string; isItemOfList: boolean = True): TDataStore;

    function PrepareUpdate(From, ColumnName: string; RowId: integer;
      Value: string; lst: boolean): TDataStore;

    function PrepareDelete(Parent_DataTableName: string; Parent_DataRowId: integer;
      Child_DataTableName: string; Child_DataRowId: integer): TDataStore;

    function Clone(CloneRowIdCounter: boolean = True;
      CloneRowList: boolean = True): TDataStore;

    //fbarreto@20150306 Devuelve una vista del DataSet
    //Ej: 'Capa, Nombre, etc'
    //    function View (ColNames: string): TDataTableOfCosa;overload;
    //fbarreto@20150310 Devuelve una vista de los elementos de la tabla virtual indicada
    function View(VirtualTable: TDataVTableOfCosa): TDataTableOfCosa; overload;

    //dfusco@20150415 Método para vaciar las tablas de la BD.
    procedure Clear();

    procedure Merge(ds: TDataStore);

    //procedure wr (DataTableName: String; RowId: Integer);

    procedure Free;

    function Equals(ADataStore: TDataStore): boolean;

    function CompareTo(Beta_DataStore: TDataStore; DataTableName: string;
      DataRowId: integer; var Gamma_DataStore: TDataStore;
      BetaDataRowId: integer = -1): boolean;


    //dfusco-fbarreto@20150312
    // Intentara completar el dataSet para tener la información necesaria para
    // crear la instancia del objeto representado por la fila de la tabla indicada
    function Fill(xDataTableName: string; xDataRowId: integer;
      var ADataSet: TDataStore): boolean;

    //fbarreto@20150323
    // Devuelve una tabla en la ultima version
    procedure GetDataTableOnLastVersion(DataTableName: string;
      var DataTable: TDataTableOfCosa);


    //fbarreto@20150709
    { Funciones para navegar/explorar un dataSet

    }
    function First(): TDataStore;
    function Prior(): TDataStore;
    function Next(): TDataStore;
    function Last(): TDataStore;


  end;


  //////////////////////////////////////////////////////////////////////////////
  //TDataTableOfCosa
  //////////////////////////////////////////////////////////////////////////////
  //dfusco@20141001
  {Esta clase representa una tabla de una almacén de datos.}
  TDataTableOfCosa = class
  private
    _DATAROWID_COUNTER: integer;
    _DataRowList: TList;
    _DataColumnList: TDataColumnListOfCosa;
    _DataConversionList: TListDataConversion;
    function GetDataRowIdCounter: integer;
    procedure SetDataRowIdCounter(AValue: integer);
  protected
    function GetDataColumnByIndex(Index: integer): TDataColumnOfCosa;
    function GetDataColumnListCount(): integer;

    function GetDataRowByIndex(Index: integer): TDataRowOfCosa; virtual;
    function GetDataRowListCount(): integer; virtual;

    function GetDataConversionByIndex(Index: integer): TDataConversion;
    function GetDataConversionListCount(): integer;
  public

    Visible: boolean;
    TableName: string;
    DataStoreOwner: TDataStore;

    function Clone(CloneRowIdCounter: boolean = True;
      CloneRowList: boolean = True): TDataTableOfCosa; virtual;

    property DataRowIdCounter: integer read GetDataRowIdCounter
      write SetDataRowIdCounter;

    constructor Create(xTableName: string; claseDeCosa: TClaseDeCosa;
      xVersion: integer = -2); overload;
    constructor Create(xTableName: string; xDataColumnList: TDataColumnListOfCosa);
      overload;
    constructor Create(xTableName: string; xDataColumnList: TDataColumnListOfCosa;
      xDataRowList: TList); overload;
    constructor Create(xTableName: string); overload;

    function ReadDataCellTextValue(ColumnName: string; var sval: string): boolean; overload;
    function ReadDataCellTextValue(RowId: integer; ColumnName: string;
      var sval: string): boolean; overload;
    function ReadDataCellTextValueByRowIndex(RowIndex: integer;
      ColumnName: string; var sval: string): boolean;

    //procedure WriteDataCellTextValue(RowName,ColumnName,value:string);

    //Devuelve el rowId
    function AddDataRow(xDataRow: TDataRowOfCosa; SetRowId: boolean = True): integer;
    property DataRowList[Index: integer]: TDataRowOfCosa read GetDataRowByIndex;
    function GetDataRowList(): TList; virtual;
    procedure SetDataRowList(drl: TList);
    property DataRowListCount: integer read GetDataRowListCount;
    function GetDataRowById(Id: integer): TDataRowOfCosa;
    function GetIndexOfDataRowById(Id: integer): integer;

    function AddDataColumn(xDataColumn: TDataColumnOfCosa): integer;
    property DataColumnList[Index: integer]: TDataColumnOfCosa read GetDataColumnByIndex;

    function GetDataColumnByName(Name: string): TDataColumnOfCosa;

    function GetIndexOfDataColumnByName(Name: string): integer;
    function GetDataColumnList(): TDataColumnListOfCosa;
    procedure SetDataColumnList(dcl: TDataColumnListOfCosa);
    property DataColumnListCount: integer read GetDataColumnListCount;

    property DataConversionList[Index: integer]: TDataConversion
      read GetDataConversionByIndex;
    function GetDataConversionList(): TListDataConversion;
    property DataConversionListCount: integer read GetDataConversionListCount;

    function ConvertDataRowToNewestVersion(var NewDataRow: TDataRowOfCosa;
      DataTableAux: TDataTableOfCosa): boolean;

    function GetDataRowWithDefaulValues(): TDataRowOfCosa;

    //No compara las filas, de momento no es necesario
    function Equals(dt: TDataTableOfCosa): boolean;

    procedure Merge(Beta_DataTable: TDataTableOfCosa);

    procedure Free(); virtual;
    procedure Clear(); virtual;


    //fbarreto@20150305 Devuelve los valores de la columna indicada
    function GetColValues(kCol: integer): TStringList; overload;
    function GetColValues(ColName: string): TStringList; overload;

    //fbarreto@20150305 Si las tablas tiene la misma definicion agrega las filas de tabla pasada como parametro
    // a la tabla. Si reAssignIds=FALSE y hay Ids que coinciden levanta una exception
    procedure AppendDataTable(dt: TDataTableOfCosa; reAssignIds: boolean);

    //fbarreto@20150305 Realiza busqueda en la tabla
    // Devuelve una tabla con la columnas "select" y las filas que cumplan la condicion
    function Query(Select: string; ColumnNameToEval: string = '';
      Value: string = ''): TDataTableOfCosa; overload;

    //fbarreto@20150305 Realiza busqueda en la tabla
    // Devuelve una tabla con la columnas "select" y la fila rowId
    function Query(Select: string; rowId: integer): TDataTableOfCosa; overload;

    //fbarreto@20150306 Devuelve una tabla con columnas ColNames, las columnas
    //que no pertenecen a las tabla se completan con "-"
    function View(ColNames: string): TDataTableOfCosa;



  end;

  //////////////////////////////////////////////////////////////////////////////
  //TDataVTableOfCosa
  //////////////////////////////////////////////////////////////////////////////
  //dfusco@20141001
  {Esta clase representa una tabla virtual de una almacén de datos para agrupar
  tablas semánticamente.}
  TDataVTableOfCosa = class(TDataTableOfCosa)
  private
    _ChildClassNameList: TStringList;
  protected
    function GetChildClassNameList(): TStringList;
  public
    constructor Create(xDataTableName: string); overload;
    constructor Create(xDataTableName: string;
      xDataColumnList: TDataColumnListOfCosa); overload;
    constructor Create(xDataTableName: string; xClassNameList: TStringList;
      xDataColumnList: TDataColumnListOfCosa); overload;

    function AddChildClassName(AClassName: string): integer;
    function GetDataRowList(ds: TDataStore): TList;
    property ChildClassNameList: TStringList read GetChildClassNameList;

  end;

  { TDataTableOfListOfCosa }

  TDataTableOfListOfCosa = class(TDataTableOfCosa)
  private
    _LastIdParent: integer;
  public
    constructor Create();
    function GetNextIdParent(): integer;
    function Clone(CloneRowIdCounter: boolean = True;
      CloneRowList: boolean = True): TDataTableOfListOfCosa; override;

    procedure Free(); override;
    procedure Clear(); override;
  end;

  //////////////////////////////////////////////////////////////////////////////
  //TDataRowOfCosa
  //////////////////////////////////////////////////////////////////////////////
  //dfusco@20141001
  {Esta clase representa una fila de una tabla de una almacén de datos.}
  TDataRowOfCosa = class
  private
    _DataCellList: TList;
    RowId: integer;
    function GetRowId: integer;
    procedure SetRowId(AValue: integer);
  protected
    function GetDataCellByIndex(Index: integer): TDataCellOfCosa;
    function GetDataCellListCount(): integer;
    function GetLastDataCell(): TDataCellOfCosa;
  public
    SIUD: TSIUD;
    RowName: string;
    DataTableOwner: TDataTableOfCosa;
    constructor Create(xRowName: string = '-'); overload;
    constructor Create(xRowId: integer); overload;
    constructor Create(xDataTableOwner: TDataTableOfCosa; xRowName: string = '-');
      overload;

    property _RowId: integer read GetRowId write SetRowId;

    function AddDataCell(xDataCell: TDataCellOfCosa; SetOwner: boolean = True): integer;
    property DataCellList[Index: integer]: TDataCellOfCosa read GetDataCellByIndex;
    property DataCellListCount: integer read GetDataCellListCount;
    property LastDataCell: TDataCellOfCosa read GetLastDataCell;

    procedure InsertDataCell(ADataCell: TDataCellOfCosa; AIndex: integer);

    function Clone(CloneRowId: boolean = True): TDataRowOfCosa;

    //Clona el DataRow si DataRow[i]=Value, sino devuelve nil
    function ConditionalClone(i: integer; Value: string): TDataRowOfCosa;

    //Devuelve el DataRow[kCell] si DataRow[kCellToEval]=Value, sino nil
    function ConditionalGetDataCell(kCell, kCellToEval: integer;
      Value: string): TDataCellOfCosa;

    function Equals(dr: TDataRowOfCosa): boolean;
    procedure Merge(ADataRow: TDataRowOfCosa);

    function CompareTo(Beta_DataRow: TDataRowOfCosa;
      Gamma_DataTable: TDataTableOfCosa): boolean;

    procedure Free; virtual;

    function ToString(): TStrings;

  end;

  { TDataVRowOfCosa }

  TDataVRowOfCosa = class(TDataRowOfCosa)
  public
    OriginalDataTableName: string;
    OriginalDataRowId: integer;
    procedure Free(); override;
  end;

  //////////////////////////////////////////////////////////////////////////////
  //TDataCellOfCosa
  //////////////////////////////////////////////////////////////////////////////
  //dfusco@20141001
  {Esta clase representa una celda de una tabla de una almacén de datos.}
  TDataCellOfCosa = class
  private
    function getVal: string;
    procedure setVal(AValue: string);
  public
    _sval: string;
    DataRowOwner: TDataRowOfCosa;
    pval: pointer;
    SIUD: TSIUD;
    Changed: boolean;
    constructor Create(xsval: string = '');
    function Clone(): TDataCellOfCosa;
    function Equals(dcll: TDataCellOfCosa): boolean;
    property sval: string read getVal write setVal;
    procedure Free;

  end;

  { TDataColumnListOfCosa }

  TDataColumnListOfCosa = class(TList)
  private
    _ClassOwner: TClaseDeCosa;
    _Version: integer;
    _ItemListClaseDeCosa: TClaseDeCosa;
    procedure SetClassOwner(AValue: TClaseDeCosa);
    procedure SetItemListClaseDeCosa(AValue: TClaseDeCosa);

  protected

    function GetItem(Index: integer): TDataColumnOfCosa;
    function GetClassOwner(): TClaseDeCosa;
    function GetItemListClaseDeCosa(): TClaseDeCosa;
    function GetVersion(): integer;

    function AddDataColumn(AColumnName: string;
      ADateType: DataTypeOfCosa;
      ALabel: string;
      ADefaultValue: string;
      AConstraints: TColumnConstraints;
      AVersionAlta: integer;
      AVersionBaja: integer): integer; overload;

  public
    DataTableOwner: TDataTableOfCosa;

    //Lista de operaciones para validar
    ValidationList: TListValidation;

    constructor Create(); overload;
    constructor Create(xClassOwner: TClaseDeCosa; xVersion: integer = -2); overload;
    constructor Create(xClassOwner: TClaseDeCosa; xItemListClaseDeCosa: TClaseDeCosa;
      xVersion: integer = -2); overload;


    function AddDataColumn(xDataColumn: TDataColumnOfCosa;
      SetOwner: boolean = True): integer; overload;

     
    function AddDataColumn(xColumnName: string;
      xDataType: DataTypeOfCosa): integer; overload;

    function AddDataColumn(xColumnName: string; var xField;
      xDataType: DataTypeOfCosa;
      xValorPorDefecto: string;
      xVersionAlta, xVersionBaja: integer;
      xClaseDeCosa: TClaseDeCosa = nil): integer; overload;

    function AddDataColumn(xColumnName: string;
      xLabelCaption: string; var xField;
      xDataType: DataTypeOfCosa;
      xValorPorDefecto: string;
      xVersionAlta: integer;
      xVersionBaja: integer;
      xClaseDeCosa: TClaseDeCosa = nil): integer; overload;

    function AddDataColumn(xColumnName: string; var xField;
      xDataType: DataTypeOfCosa;
      xVersionAlta: integer;
      xVersionBaja: integer;
      xClaseDeCosa: TClaseDeCosa = nil): integer; overload;


    function AddDataColumn(xColumnName: string;
      xDataType: DataTypeOfCosa;
      xOptions: array of string;
      xVersionAlta: integer;
      xVersionBaja: integer;
      xClaseDeCosa: TClaseDeCosa = nil): integer; overload;

    function AddDataColumn(xColumnName: string; var xField;
      xDataType: DataTypeOfCosa;
      xOptions: array of string;
      xVersionAlta: integer;
      xVersionBaja: integer;
      xClaseDeCosa: TClaseDeCosa = nil): integer; overload;

    

    function AddBooleanColumn(AColumnName: string;
      ADefaultValue: boolean;
      AVersionAlta: integer = 0;
      AVersionBaja: integer = -1): integer; overload;

    function AddBooleanColumn(AColumnName: string;
      ADefaultValue: boolean;
      AConstraints: TColumnConstraints;
      AVersionAlta: integer = 0;
      AVersionBaja: integer = -1): integer; overload;

    function AddBooleanColumn(AColumnName: string;
      ALabel: string;
      ADefaultValue: boolean;
      AVersionAlta: integer = 0;
      AVersionBaja: integer = -1): integer; overload;

    function AddBooleanColumn(AColumnName: string;
      ALabel: string;
      ADefaultValue: boolean;
      AConstraints: TColumnConstraints;
      AVersionAlta: integer = 0;
      AVersionBaja: integer = -1): integer; overload;

    function AddIntegerColumn(AColumnName: string;
      ADefaultValue: integer;
      AVersionAlta: integer = 0;
      AVersionBaja: integer = -1): integer; overload;

    function AddIntegerColumn(AColumnName: string;
      ADefaultValue: integer;
      AConstraints: TColumnConstraints;
      AVersionAlta: integer = 0;
      AVersionBaja: integer = -1): integer; overload;

    function AddIntegerColumn(AColumnName: string;
      ALabel: string;
      ADefaultValue: integer;
      AVersionAlta: integer = 0;
      AVersionBaja: integer = -1): integer; overload;

    function AddIntegerColumn(AColumnName: string;
      ALabel: string;
      ADefaultValue: integer;
      AConstraints: TColumnConstraints;
      AVersionAlta: integer = 0;
      AVersionBaja: integer = -1): integer; overload;

    function AddCardinalColumn(AColumnName: string;
      ADefaultValue: cardinal;
      AVersionAlta: integer = 0;
      AVersionBaja: integer = -1): integer; overload;

    function AddCardinalColumn(AColumnName: string;
      ADefaultValue: cardinal;
      AConstraints: TColumnConstraints;
      AVersionAlta: integer = 0;
      AVersionBaja: integer = -1): integer; overload;

    function AddCardinalColumn(AColumnName: string;
      ALabel: string;
      ADefaultValue: cardinal;
      AVersionAlta: integer = 0;
      AVersionBaja: integer = -1): integer; overload;

    function AddCardinalColumn(AColumnName: string;
      ALabel: string;
      ADefaultValue: cardinal;
      AConstraints: TColumnConstraints;
      AVersionAlta: integer = 0;
      AVersionBaja: integer = -1): integer; overload;

    function AddDoubleColumn(AColumnName: string;
      ADefaultValue: double;
      AVersionAlta: integer = 0;
      AVersionBaja: integer = -1): integer; overload;

    function AddDoubleColumn(AColumnName: string;
      ADefaultValue: double;
      AConstraints: TColumnConstraints;
      AVersionAlta: integer = 0;
      AVersionBaja: integer = -1): integer; overload;

    function AddDoubleColumn(AColumnName: string;
      ALabel: string;
      ADefaultValue: double;
      AVersionAlta: integer = 0;
      AVersionBaja: integer = -1): integer; overload;

    function AddDoubleColumn(AColumnName: string;
      ALabel: string;
      ADefaultValue: double;
      AConstraints: TColumnConstraints;
      AVersionAlta: integer = 0;
      AVersionBaja: integer = -1): integer; overload;

    function AddStringColumn(AColumnName: string;
      ADefaultValue: string;
      AVersionAlta: integer = 0;
      AVersionBaja: integer = -1): integer; overload;

    function AddStringColumn(AColumnName: string;
      ADefaultValue: string;
      AConstraints: TColumnConstraints;
      AVersionAlta: integer = 0;
      AVersionBaja: integer = -1): integer; overload;

    function AddStringColumn(AColumnName: string;
      ALabel: string;
      ADefaultValue: string;
      AVersionAlta: integer = 0;
      AVersionBaja: integer = -1): integer; overload;

    function AddStringColumn(AColumnName: string;
      ALabel: string;
      ADefaultValue: string;
      AConstraints: TColumnConstraints;
      AVersionAlta: integer = 0;
      AVersionBaja: integer = -1): integer; overload;

    function AddDAOfBooleanColumn(AColumnName: string;
      AVersionAlta: integer = 0;
      AVersionBaja: integer = -1): integer; overload;

    function AddDAOfBooleanColumn(AColumnName: string;
      AConstraints: TColumnConstraints;
      AVersionAlta: integer = 0;
      AVersionBaja: integer = -1): integer; overload;

    function AddDAOfBooleanColumn(AColumnName: string;
      ALabel: string;
      AVersionAlta: integer = 0;
      AVersionBaja: integer = -1): integer; overload;

    function AddDAOfBooleanColumn(AColumnName: string;
      ALabel: string;
      AConstraints: TColumnConstraints;
      AVersionAlta: integer = 0;
      AVersionBaja: integer = -1): integer; overload;

    function AddDAOfBooleanColumn(AColumnName: string;
      ADefaultValue: array of boolean;
      AVersionAlta: integer = 0;
      AVersionBaja: integer = -1): integer; overload;

    function AddDAOfBooleanColumn(AColumnName: string;
      ADefaultValue: array of boolean;
      AConstraints: TColumnConstraints;
      AVersionAlta: integer = 0;
      AVersionBaja: integer = -1): integer; overload;

    function AddDAOfBooleanColumn(AColumnName: string;
      ALabel: string;
      ADefaultValue: array of boolean;
      AVersionAlta: integer = 0;
      AVersionBaja: integer = -1): integer; overload;

    function AddDAOfBooleanColumn(AColumnName: string;
      ALabel: string;
      ADefaultValue: array of boolean;
      AConstraints: TColumnConstraints;
      AVersionAlta: integer = 0;
      AVersionBaja: integer = -1): integer; overload;

    function AddDAOfIntegerColumn(AColumnName: string;
      AVersionAlta: integer = 0;
      AVersionBaja: integer = -1): integer; overload;
    function AddDAOfIntegerColumn(AColumnName: string;
      AConstraints: TColumnConstraints;
      AVersionAlta: integer = 0;
      AVersionBaja: integer = -1): integer; overload;
    function AddDAOfIntegerColumn(AColumnName: string;
      ALabel: string;
      AVersionAlta: integer = 0;
      AVersionBaja: integer = -1): integer; overload;
    function AddDAOfIntegerColumn(AColumnName: string;
      ALabel: string;
      AConstraints: TColumnConstraints;
      AVersionAlta: integer = 0;
      AVersionBaja: integer = -1): integer; overload;
    function AddDAOfIntegerColumn(AColumnName: string;
      ADefaultValue: array of integer;
      AVersionAlta: integer = 0;
      AVersionBaja: integer = -1): integer; overload;
    function AddDAOfIntegerColumn(AColumnName: string;
      ADefaultValue: array of integer;
      AConstraints: TColumnConstraints;
      AVersionAlta: integer = 0;
      AVersionBaja: integer = -1): integer; overload;
    function AddDAOfIntegerColumn(AColumnName: string;
      ALabel: string;
      ADefaultValue: array of integer;
      AVersionAlta: integer = 0;
      AVersionBaja: integer = -1): integer; overload;
    function AddDAOfIntegerColumn(AColumnName: string;
      ALabel: string;
      ADefaultValue: array of integer;
      AConstraints: TColumnConstraints;
      AVersionAlta: integer = 0;
      AVersionBaja: integer = -1): integer; overload;

    function AddDAOfDoubleColumn(AColumnName: string;
      AVersionAlta: integer = 0;
      AVersionBaja: integer = -1): integer; overload;
    function AddDAOfDoubleColumn(AColumnName: string;
      AConstraints: TColumnConstraints;
      AVersionAlta: integer = 0;
      AVersionBaja: integer = -1): integer; overload;
    function AddDAOfDoubleColumn(AColumnName: string;
      ALabel: string;
      AVersionAlta: integer = 0;
      AVersionBaja: integer = -1): integer; overload;
    function AddDAOfDoubleColumn(AColumnName: string;
      ALabel: string;
      AConstraints: TColumnConstraints;
      AVersionAlta: integer = 0;
      AVersionBaja: integer = -1): integer; overload;
    function AddDAOfDoubleColumn(AColumnName: string;
      ADefaultValue: array of double;
      AVersionAlta: integer = 0;
      AVersionBaja: integer = -1): integer; overload;
    function AddDAOfDoubleColumn(AColumnName: string;
      ADefaultValue: array of double;
      AConstraints: TColumnConstraints;
      AVersionAlta: integer = 0;
      AVersionBaja: integer = -1): integer; overload;
    function AddDAOfDoubleColumn(AColumnName: string;
      ALabel: string;
      ADefaultValue: array of double;
      AVersionAlta: integer = 0;
      AVersionBaja: integer = -1): integer; overload;
    function AddDAOfDoubleColumn(AColumnName: string;
      ALabel: string;
      ADefaultValue: array of double;
      AConstraints: TColumnConstraints;
      AVersionAlta: integer = 0;
      AVersionBaja: integer = -1): integer; overload;

    function AddDAOfStringColumn(AColumnName: string;
      AVersionAlta: integer = 0;
      AVersionBaja: integer = -1): integer; overload;
    function AddDAOfStringColumn(AColumnName: string;
      AConstraints: TColumnConstraints;
      AVersionAlta: integer = 0;
      AVersionBaja: integer = -1): integer; overload;
    function AddDAOfStringColumn(AColumnName: string;
      ALabel: string;
      AVersionAlta: integer = 0;
      AVersionBaja: integer = -1): integer; overload;
    function AddDAOfStringColumn(AColumnName: string;
      ALabel: string;
      AConstraints: TColumnConstraints;
      AVersionAlta: integer = 0;
      AVersionBaja: integer = -1): integer; overload;
    function AddDAOfStringColumn(AColumnName: string;
      ADefaultValue: array of string;
      AVersionAlta: integer = 0;
      AVersionBaja: integer = -1): integer; overload;
    function AddDAOfStringColumn(AColumnName: string;
      ADefaultValue: array of string;
      AConstraints: TColumnConstraints;
      AVersionAlta: integer = 0;
      AVersionBaja: integer = -1): integer; overload;
    function AddDAOfStringColumn(AColumnName: string;
      ALabel: string;
      ADefaultValue: array of string;
      AVersionAlta: integer = 0;
      AVersionBaja: integer = -1): integer; overload;
    function AddDAOfStringColumn(AColumnName: string;
      ALabel: string;
      ADefaultValue: array of string;
      AConstraints: TColumnConstraints;
      AVersionAlta: integer = 0;
      AVersionBaja: integer = -1): integer; overload;

    function AddStringListColumn(AColumnName: string;
      AVersionAlta: integer = 0;
      AVersionBaja: integer = -1): integer; overload;
    function AddStringListColumn(AColumnName: string;
      AConstraints: TColumnConstraints;
      AVersionAlta: integer = 0;
      AVersionBaja: integer = -1): integer; overload;
    function AddStringListColumn(AColumnName: string;
      ALabel: string;
      AVersionAlta: integer = 0;
      AVersionBaja: integer = -1): integer; overload;
    function AddStringListColumn(AColumnName: string;
      ALabel: string;
      AConstraints: TColumnConstraints;
      AVersionAlta: integer = 0;
      AVersionBaja: integer = -1): integer; overload;

    function AddDateColumn(AColumnName: string;
      ADefaultValue: TDateTime;
      AVersionAlta: integer = 0;
      AVersionBaja: integer = -1): integer; overload;
    function AddDateColumn(AColumnName: string;
      ADefaultValue: TDateTime;
      AConstraints: TColumnConstraints;
      AVersionAlta: integer = 0;
      AVersionBaja: integer = -1): integer; overload;
    function AddDateColumn(AColumnName: string;
      ALabel: string;
      ADefaultValue: TDateTime;
      AVersionAlta: integer = 0;
      AVersionBaja: integer = -1): integer; overload;
    function AddDateColumn(AColumnName: string;
      ALabel: string;
      ADefaultValue: TDateTime;
      AConstraints: TColumnConstraints;
      AVersionAlta: integer = 0;
      AVersionBaja: integer = -1): integer; overload;

    function AddFileReferenceColumn(AColumnName: string;
      AVersionAlta: integer = 0;
      AVersionBaja: integer = -1): integer; overload;
    function AddFileReferenceColumn(AColumnName: string;
      AConstraints: TColumnConstraints;
      AVersionAlta: integer = 0;
      AVersionBaja: integer = -1): integer; overload;
    function AddFileReferenceColumn(AColumnName: string;
      ALabel: string;
      AVersionAlta: integer = 0;
      AVersionBaja: integer = -1): integer; overload;
    function AddFileReferenceColumn(AColumnName: string;
      ALabel: string;
      AConstraints: TColumnConstraints;
      AVersionAlta: integer = 0;
      AVersionBaja: integer = -1): integer; overload;

    function AddListColumn(AColumnName: string;
      AConstraints: TColumnConstraints;
      AVersionAlta: integer = 0;
      AVersionBaja: integer = -1): integer; overload;
    function AddListColumn(AColumnName: string;
      AVersionAlta: integer = 0;
      AVersionBaja: integer = -1): integer; overload;
    function AddListColumn(AColumnName: string;
      ALabel: string;
      AConstraints: TColumnConstraints;
      AVersionAlta: integer = 0;
      AVersionBaja: integer = -1): integer; overload;
    function AddListColumn(AColumnName: string;
      ALabel: string;
      AVersionAlta: integer = 0;
      AVersionBaja: integer = -1): integer; overload;

    function AddCosaColumn(AColumnName: string;
      AConstraints: TColumnConstraints;
      AVersionAlta: integer = 0;
      AVersionBaja: integer = -1): integer; overload;
    function AddCosaColumn(AColumnName: string;
      AVersionAlta: integer = 0;
      AVersionBaja: integer = -1): integer; overload;
    function AddCosaColumn(AColumnName: string;
      ALabel: string;
      AConstraints: TColumnConstraints;
      AVersionAlta: integer = 0;
      AVersionBaja: integer = -1): integer; overload;
    function AddCosaColumn(AColumnName: string;
      ALabel: string;
      AVersionAlta: integer = 0;
      AVersionBaja: integer = -1): integer; overload;

    function AddDAOfCosaColumn(AColumnName: string;
      AConstraints: TColumnConstraints;
      AVersionAlta: integer = 0;
      AVersionBaja: integer = -1): integer; overload;
    function AddDAOfCosaColumn(AColumnName: string;
      AVersionAlta: integer = 0;
      AVersionBaja: integer = -1): integer; overload;
    function AddDAOfCosaColumn(AColumnName: string;
      ALabel: string;
      AConstraints: TColumnConstraints;
      AVersionAlta: integer = 0;
      AVersionBaja: integer = -1): integer; overload;
    function AddDAOfCosaColumn(AColumnName: string;
      ALabel: string;
      AVersionAlta: integer = 0;
      AVersionBaja: integer = -1): integer; overload;

    property Items[Index: integer]: TDataColumnOfCosa read GetItem; default;
    property ClassOwner: TClaseDeCosa read GetClassOwner write SetClassOwner;
    property ItemListClaseDeCosa: TClaseDeCosa
      read GetItemListClaseDeCosa write SetItemListClaseDeCosa;
    property Version: integer read GetVersion;
    function GetIndexOfDataColumnByName(AName: string): integer;

    procedure Move(CurIndex, NewIndex: integer);

    function Clone(): TDataColumnListOfCosa;

    function Equals(dcl: TDataColumnListOfCosa): boolean;

    // Lee el campo iCampo de aCosa y lo retorna como String
    function GetValStr(aCosa: TCosa; iCampo: integer): string;

    // Fija el valor del campo iCampo de aCosa de acuerdo al NuevoValor
    // El resultado es TRUE si logró setear el campo (no falló la conversión de tipo)
    function SetValStr(aCosa: TCosa; iCampo: integer; NuevoValor: string): boolean;

    // Destruye el objeto
    procedure Free;
  end;

  //////////////////////////////////////////////////////////////////////////////
  //TDataColumnOfCosa
  //////////////////////////////////////////////////////////////////////////////
  //dfusco@20141001
  {Esta clase representa una columna de una tabla de una almacén de datos.}
  TDataColumnOfCosa = class

    Index: integer;

    ColumnName: string;
    LabelCaption: string;
    DataType: TDataTypeOfCosa;
    ValorPorDefecto: string;
    Constraints: TColumnConstraints;
    VersionAlta: integer;
    VersionBaja: integer;

    DataColumnListOwner: TDataColumnListOfCosa;

    constructor Create(xColumnName: string;
      xLabel: string;
      xDataType: DataTypeOfCosa;
      xValorPorDefecto: string;
      xConstraints: TColumnConstraints;
      xVersionAlta: integer;
      xVersionBaja: integer;
      xClaseDeCosa: TClaseDeCosa); overload;

    constructor Create(xColumnName: string;
      xDataType: DataTypeOfCosa;
      xClaseDeCosa: TClaseDeCosa = nil); overload;

    function Clone(): TDataColumnOfCosa;
    function Equals(dc: TDataColumnOfCosa): boolean;
    procedure Free;

  end;


  TRelationshipRec = record
    Primary_Table: string;
    Primary_ColumnName: string;
    Foreing_Table: string;
    Foreing_ColumnName: string;
  end;

  { TRelationships }

  TRelationships = class(TList)
    function Add(Primary_Table: string; Primary_ColumnName: string;
      Foreing_Table: string; Foreing_ColumnName: string): integer;
    procedure Free;
  end;

  TOperator = (

    //Relational Operators
    EQUAL,
    DISTINCT,
    LESS,
    LESS_OR_EQUAL,
    GREATER,
    GREATER_OR_EQUAL,

    //Regular Expresion
    REGEX

    );

  //////////////////////////////////////////////////////////////////////////////
  //TDataTypeOfCosa
  //////////////////////////////////////////////////////////////////////////////
  //dfusco@20141001
  {Esta clase representa un tipo de dato de una columna de una tabla de una
  almacén de datos.}
  TDataTypeOfCosa = class
    DataColumnOwner: TDataColumnOfCosa;
    ClaseDeCosa: TClaseDeCosa;
    CosaStrId: string;

    constructor Create(DataColumnOwner: TDataColumnOfCosa);

    function Validate(sval: string; var ErrorMessage: string): boolean; virtual;
    function CompareTo(TheOperator: TOperator; asval: string;
      bsval: string): boolean; virtual;
    function Eval(sval: string; pval: pointer): boolean; virtual;
    function ToString(pval: pointer): string; virtual; abstract;
    function IsAMacroVariable(sval: string): boolean;
    function Clone(): TDataTypeOfCosa; virtual;
    function Equals(dtc: TDataTypeOfCosa): boolean;

    function Format(sval: string): string; virtual;

    procedure Free;
  end;

  { TDataTypeDataRowOfCosa }

  TDataTypeDataRowOfCosa = class(TDataTypeOfCosa)
    DataTableName: string;
    PK: string;
    function Eval(sval: string; pval: pointer): boolean; override;
    function ToString(pval: pointer): string; override;
  end;

  { TDataTypeListOfCosa }

  TDataTypeListOfCosa = class(TDataTypeOfCosa)
    function Eval(sval: string; pval: pointer): boolean; override;
    function ToString(pval: pointer): string; override;
  end;

  { TDataTypeIntegerOfCosa }

  TDataTypeIntegerOfCosa = class(TDataTypeOfCosa)
    function Validate(sval: string; var ErrorMessage: string): boolean; override;
    function CompareTo(TheOperator: TOperator; asval: string;
      bsval: string): boolean; override;
    function Eval(sval: string; pval: pointer): boolean; override;
    function ToString(pval: pointer): string; override;
  end;

  { TDataTypeStringOfCosa }

  TDataTypeStringOfCosa = class(TDataTypeOfCosa)
    function Eval(sval: string; pval: pointer): boolean; override;
    function ToString(pval: pointer): string; override;
  end;

  { TDataTypeDateOfCosa }

  TDataTypeDateOfCosa = class(TDataTypeOfCosa)
    function Validate(sval: string; var ErrorMessage: string): boolean; override;
    function CompareTo(TheOperator: TOperator; asval: string;
      bsval: string): boolean; override;
    function Eval(sval: string; pval: pointer): boolean; override;
    function ToString(pval: pointer): string; override;
  end;

  { TDataTypeDoubleOfCosa }

  TDataTypeDoubleOfCosa = class(TDataTypeOfCosa)
    function Validate(sval: string; var ErrorMessage: string): boolean; override;
    function Eval(sval: string; pval: pointer): boolean; override;
    function ToString(pval: pointer): string; override;
  end;

  { TDataTypeBooleanOfCosa }

  TDataTypeBooleanOfCosa = class(TDataTypeOfCosa)
    function Eval(sval: string; pval: pointer): boolean; override;
    function ToString(pval: pointer): string; override;
  end;

  { TDataTypeDAOfDoubleOfCosa }

  TDataTypeDAOfDoubleOfCosa = class(TDataTypeOfCosa)
    function Eval(sval: string; pval: pointer): boolean; override;
    function ToString(pval: pointer): string; override;
    function Format(sval: string): string; override;
  end;

  { TDataTypeDAOfStringOfCosa }

  TDataTypeDAOfStringOfCosa = class(TDataTypeOfCosa)
    function Eval(sval: string; pval: pointer): boolean; override;
    function ToString(pval: pointer): string; override;
    function Format(sval: string): string; override;
  end;

  { TDataTypeStringListOfCosa }

  TDataTypeStringListOfCosa = class(TDataTypeOfCosa)
    function Eval(sval: string; pval: pointer): boolean; override;
    function ToString(pval: pointer): string; override;
    function Format(sval: string): string; override;
  end;

  { TDataTypeDAOfIntegerOfCosa }

  TDataTypeDAOfIntegerOfCosa = class(TDataTypeOfCosa)
    function Eval(sval: string; pval: pointer): boolean; override;
    function ToString(pval: pointer): string; override;
    function Format(sval: string): string; override;
  end;

  { TDataTypeDAOfBooleanOfCosa }

  TDataTypeDAOfBooleanOfCosa = class(TDataTypeOfCosa)
    function Eval(sval: string; pval: pointer): boolean; override;
    function ToString(pval: pointer): string; override;
    function Format(sval: string): string; override;
  end;

  { TDataTypeArchiRefOfCosa }

  TDataTypeArchiRefOfCosa = class(TDataTypeOfCosa)
    function Eval(sval: string; pval: pointer): boolean; override;
    function ToString(pval: pointer): string; override;
  end;

  { TDataTypeReferenciaOfCosa }

  TDataTypeReferenciaOfCosa = class(TDataTypeOfCosa)
    function Eval(sval: string; pval: pointer): boolean; override;
    function ToString(pval: pointer): string; override;
  end;

  { TDataTypeDAOfCosa }

  TDataTypeDAOfCosa = class(TDataTypeOfCosa)
    function Eval(sval: string; pval: pointer): boolean; override;
    function ToString(pval: pointer): string; override;
  end;

  { TValidation }

  TValidation = class
  public

    ValidationListOwner: TListValidation;

    TheOperator: TOperator;
    A: string;
    B: string;
    ErrorMessage: string;
    constructor Create(xTheOperator: TOperator; xA: string; xB: string; xErrorMessage: string);
    function Validate(xDataType: TDataTypeOfCosa; asval: string): boolean; overload;
    function Validate(xDataType: TDataTypeOfCosa; asval: string; bsval: string): boolean;
      overload;
  end;

  { TListValidation }

  TListValidation = class(TList)
  private
    function GetItem(Index: integer): TValidation;
  public
    constructor Create;
    function Add(xValidation: TValidation): integer;
    property Items[Index: integer]: TValidation read GetItem;
    function Clone(): TListValidation;
    function GetValidationToDoOverField(xA: string): TListValidation;
  end;

procedure parseRowReference(sval: string; var DataTableName: string;
  var RowId: integer);
function parseListReference(sval: string; var DataTableName: string;
  var DataColumnName: string; var IdParent: string): boolean;


implementation

{ TRelationships }

function TRelationships.Add(Primary_Table: string; Primary_ColumnName: string;
  Foreing_Table: string; Foreing_ColumnName: string): integer;
var
  rec: ^TRelationshipRec;
begin

  new(rec);

  rec^.Primary_Table := Primary_Table;
  rec^.Primary_ColumnName := Primary_ColumnName;
  rec^.Foreing_Table := Foreing_Table;
  rec^.Foreing_ColumnName := Foreing_ColumnName;

  Result := inherited Add(rec);

end;

procedure TRelationships.Free;
var
  i: integer;
begin
  for i := 0 to Count - 1 do
    Dispose(Items[i]);

  inherited Free;
end;

{ TListValidation }

function TListValidation.GetItem(Index: integer): TValidation;
begin
  Result := TValidation(inherited Items[Index]);
end;

constructor TListValidation.Create;
begin
  inherited Create;
end;

function TListValidation.Add(xValidation: TValidation): integer;
begin
  Result := inherited Add(xValidation);
  xValidation.ValidationListOwner := self;
end;

function TListValidation.Clone: TListValidation;
var
  Alfa_validation: TValidation;
  Beta_validation: TValidation;
  i: integer;
begin
  Result := TListValidation.Create();
  for i := 0 to Count - 1 do
  begin
    Alfa_validation := self.Items[i];
    Beta_validation := TValidation.Create(Alfa_validation.TheOperator,
      Alfa_validation.A, Alfa_validation.B, Alfa_validation.ErrorMessage);
    Result.Add(Beta_validation);
  end;
end;

function TListValidation.GetValidationToDoOverField(xA: string): TListValidation;
var
  i: integer;
begin
  Result := TListValidation.Create();
  for i := 0 to self.Count - 1 do
    if LowerCase(self.Items[i].A) = LowerCase(xA) then
    begin
      Result.Add(self.Items[i]);
      exit;
    end;
end;

{ TValidation }

constructor TValidation.Create(xTheOperator: TOperator; xA: string;
  xB: string; xErrorMessage: string);
begin
  self.TheOperator := xTheOperator;
  self.A := LowerCase(xA);
  self.B := LowerCase(xB);
  self.ErrorMessage := xErrorMessage;
end;

function TValidation.Validate(xDataType: TDataTypeOfCosa; asval: string): boolean;
begin
  Result := True;
end;

function TValidation.Validate(xDataType: TDataTypeOfCosa; asval: string;
  bsval: string): boolean;
var
  RegexObj: TRegExpr;
begin

  case self.TheOperator of

    TOperator.REGEX:
    begin
      RegexObj := TRegExpr.Create();
      RegexObj.Expression := bsval;
      Result := RegexObj.Exec(asval);
      RegexObj.Free;
    end
    else
      Result := xDataType.CompareTo(self.TheOperator, asval, bsval);
  end;
end;

{ TDataVRowOfCosa }

procedure TDataVRowOfCosa.Free;
begin
  inherited Free;
end;


//////////////////////////////////////////////////////////////////////////////
//TDataBaseConnection
//////////////////////////////////////////////////////////////////////////////
constructor TSalaDeJuegoConnection.Create(xFileName: WideString);
begin
  xFileName := Utf8ToAnsi(xFileName);
  chdir(extractFilePath(xFileName));
  self.FileName := xFileName;
end;

constructor TSalaDeJuegoConnection.Create(xFileHandler: TArchiTexto);
begin
  self.FileHandler := xFileHandler;
  self.FileName := xFileHandler.nombreArchivo;
end;

procedure TSalaDeJuegoConnection.ReadDataStoreFromTextFile(root: string);
var
  row: TDataRowOfCosa = nil;
  cosa: TCosa = nil;
  aux: TListaDeCosasConNombre = nil;
  a: integer = 0;
  FPHashList: TCosaHashList;
  SourceList: TStringList;
  i: integer;
  split: TStrings;
  version: integer;
  FirstLine: string;
begin

  row := nil;

  
















  // SE LEE DE LA FORMA VIEJA
  self.FileHandler := TArchiTexto.CreateForRead(self.FileName, False);
  self.FileHandler.rd('sala', cosa);

  if uCosaConNombre.referenciasSinResolver > 0 then
  begin
    aux := TListaDeCosasConNombre.Create(0, 'aux');
    aux.Add(TSalaDeJuego(cosa).globs);
    uCosaConNombre.resolver_referencias(aux);
    uCosaConNombre.resolver_referencias(TSalaDeJuego(cosa).listaActores);
    uCosaConNombre.resolver_referencias(TSalaDeJuego(cosa).listaFuentes);
    uCosaConNombre.resolver_referencias(TSalaDeJuego(cosa).listaCombustibles);
    aux.FreeSinElemenentos;
    aux := nil;
  end;
  if uCosaConNombre.referenciasSinResolver > 0 then
  begin
    uCosaConNombre.DumpReferencias('errRefs.txt');
    raise Exception.Create(
      'TSalaDeJuego.cargarSala: Quedaron Referencias Sin Resolver Cargando la Sala. Puede Ver Que Referencias No Se Resolvieron En: '
      + 'errRefs.txt');
  end;
  //CREO EL DATA STORE A PARTIR DE LA INSTANCIA
  DATA_STORE.CreateDataRowFromInstance(cosa, 'dt_TSalaDeJuego', 'dr_Sala');
  TSalaDeJuego(cosa).Free;
  self.FileHandler.Free();
  
end;

function TSalaDeJuegoConnection.WriteDataStoreToTextFile(filename: string): boolean;
var
  oldFileMode: byte;
begin
  try
    if filename = '' then
      filename := self.FileName;

    self.FileHandler := TArchiTexto.CreateForWrite(filename, False, 0);
    self.wr('dt_TSalaDeJuego', 1001, '');
    self.FileHandler.Free;
    Result := True;
  except
    On E: Exception do
    begin
      Result := False;
      system.writeln('ERROR!!! ' +
        'Ha ocurrido un error mientras se intentaba guardar la sala.' +
        '\n\r' + 'TSalaDeJuegoConnection.WriteDataStoreToTextFile: ' + E.Message);
      system.writeln('Presione ENTER para continuar ... ');
      system.readln;
    end;
  end;
end;

procedure TSalaDeJuegoConnection.ProcessFile(SourceList: TStringList;
  var i: integer; var FPHashList: TCosaHashList);

var
  Line: string;
  FieldValueWithMoreThanOneLine: boolean;
  split: TStringList;
  key: string;
  Value: string;
  cfphl: TCosaHashList;
  a: integer;
  b: string;
  j: integer;
  item: TCosaHashListItem;

begin

  while i < SourceList.Count - 1 do
  begin

    i := i + 1;

    if not FieldValueWithMoreThanOneLine then
      Line := '';

    Line := Line + Trim(SourceList[i]);

    if Copy(Line, 1, 2) = '<-' then
      Exit();

    FieldValueWithMoreThanOneLine := False;

    split := TStringList.Create;
    ExtractStrings(['=', ';'], [], PChar(Line), split);

    if (split.Count > 1) then
    begin
      key := LowerCase(Trim(split[0]));
      Value := Trim(split[1]);
    end;

    if LowerCase(key) = 'nunidades_instaladas' then
      a := 1;

    if LowerCase(key) = 'listafuentes' then
      a := 1;

    if (Pos('=', Line) > 0) and (Pos('<+', Line) > 0) then
    begin
      Value := Copy(Value, 3, Length(Value) - 3);
      cfphl := TCosaHashList.Create(Value);
      ProcessFile(SourceList, i, cfphl);
      item := TCosaHashListItem.CreateHashListItem(cfphl);
      FPHashList.Add(key, item);
      if FPHashList.CosaStrId = 'TList' then
        Exit();
    end

    else if (Pos('=', Line) > 0) and (Pos(';', Line) > 0) then
    begin
      item := TCosaHashListItem.CreateValueItem(Value);
      FPHashList.Add(key, item);

      if key = 'n' then
      begin
        cfphl := TCosaHashList.Create('TList');
        for j := 0 to StrToInt(Value) - 1 do
        begin
          ProcessFile(SourceList, i, cfphl);
        end;
        item := TCosaHashListItem.CreateHashListItem(cfphl);
        FPHashList.Add('lst', item);
      end;
    end

    else
      FieldValueWithMoreThanOneLine := True;

    split.Free;

  end;
end;

procedure TSalaDeJuegoConnection.writeline(const s: string);
begin
  self.FileHandler.writeline(s);
end;

procedure TSalaDeJuegoConnection.wr(DataTableName: string; DataRowId: integer;
  tabulation: string);
var
  j, z: integer;
  DataTable: TDataTableOfCosa;
  DataRow: TDataRowOfCosa;
  DataCell: TDataCellOfCosa;
  DataColumn: TDataColumnOfCosa;
  sval: string = '';
  a: integer;
  split: TStrings;
  DataTableChildName: string;
  DataRowChildId: integer;
  DataColumnChildName: string;
  DataCellChildSVal: string;
  g: integer;
  daos: TDAofString;
  adt: TDateTime;
  ad: NReal;
begin

  DataTable := DATA_STORE.GetDataTableByName(DataTableName);
  DataRow := DataTable.GetDataRowById(DataRowId);

  {dfusco@20150420
   Si la fila fue marcada para ser eliminada, no se persiste en el archivo.}
  if DataRow.SIUD = TSIUD.TDELETE then
    Exit();

  if (DataRow.RowName[4] = ':') then
    writeline(tabulation + ':' + '= ' + '<+' + Copy(DataTable.TableName, 4,
      Length(DataTable.TableName) - 3) + '>')
  else
    writeline(tabulation + Copy(DataRow.RowName, 4, Length(DataRow.RowName) - 3) +
      '= ' + '<+' + Copy(DataTable.TableName, 4, Length(DataTable.TableName) - 3) + '>');

  for j := 0 to DataTable.DataColumnListCount - 1 do
  begin
    if (j < DataRow.DataCellListCount) then
    begin
      DataColumn := DataTable.DataColumnList[j];
      if (DataColumn.ColumnName = 'iteracion_flucar_modificar_rendimiento') then
        a := 1;
      DATA_STORE.ReadDataCellTextValue(DataTable.TableName, DataRow._RowId,
        DataColumn.ColumnName, sval);
      if (DataColumn.DataType is TDataTypeDataRowOfCosa) then
      begin
        if (sval <> '') then
        begin
          split := TStringList.Create;
          try
            ExtractStrings(['.'], [], PChar(sval), split);
            DataTableChildName := split[0];
            DataRowChildId := StrToInt(split[1]);
            self.wr(DataTableChildName, DataRowChildId, tabulation + '  ');
          finally
            split.Free;
          end;
        end
        else
        begin
          writeline(tabulation + '  ' + DataColumn.ColumnName + '= ' + sval + ';');
        end;
      end
      else if (DataColumn.DataType is TDataTypeListOfCosa) then
      begin
        try
          split := TStringList.Create;
          if (sval <> '') then
          begin
            ExtractStrings(['.'], [], PChar(sval), split);
            DataTableChildName := split[0];
            DataCellChildSVal := split[2];
            daos := DATA_STORE.ReadDataCellTextValues(DataTableChildName,
              'idParent', DataCellChildSVal, 'idchild');
            a := length(daos);
            for z := 0 to length(daos) - 1 do
            begin
              split := TStringList.Create;
              ExtractStrings(['.'], [], PChar(daos[z]), split);
              if (split.Count > 0) then
              begin
                DataTableChildName := split[0];
                DataRowChildId := StrToInt(split[1]);
                self.wr(DataTableChildName, DataRowChildId, tabulation + '  ');
              end;
            end;
          end;
        finally
          split.Free;
        end;
      end
      else
      begin
        if DataColumn.DataType is TDataTypeDoubleOfCosa then
        begin
          //SE CONVIERTE EL REAL AL FORMATO LOCAL
          uauxiliares.setSeparadoresLocales();
          ad := StrToFloat(sval);
          uauxiliares.setSeparadoresGlobales();
          sval := FloatToStr(ad);
        end;
        if DataColumn.DataType is TDataTypeDateOfCosa then
        begin
          //SE CONVIERTE LA FECHA AL FORMATO LOCAL
          uauxiliares.setSeparadoresLocales();
          adt := StrToDate(sval);
          uauxiliares.setSeparadoresGlobales();
          sval := DateToStr(adt);
        end;
        writeline(tabulation + '  ' + DataColumn.ColumnName + '= ' + sval + ';');
      end;
    end;
  end;
  writeline(tabulation + '<-' + Copy(DataTable.TableName, 4,
    Length(DataTable.TableName) - 3) + '>;');

end;


//////////////////////////////////////////////////////////////////////////////
//TDataStore
//////////////////////////////////////////////////////////////////////////////
constructor TDataStore.Create(xDataSetParent: TDataStore);
begin

  self._DataTableList := TList.Create;
  cosasConNombre := TListaDeCosas.Create(-1, '');
  self.DataSetParent := xDataSetParent;

  Relations := TRelationships.Create;

end;

function TDataStore.GetIndexOfDataTableByName(Name: string): integer;
var
  Index: integer;
  foundIt: boolean;
  Count: integer;
  a: string;
begin
  Result := -1;
  for Index := 0 to self._DataTableList.Count - 1 do
  begin
    if (LowerCase(self.DataTableList[Index].TableName) = LowerCase(Name)) then
    begin
      Result := Index;
      break;
    end;
  end;
end;

function TDataStore.GetDataTableList: TList;
begin
  Result := self._DataTableList;
end;

function TDataStore.Query(Select: string; FromName: string;
  var ds: TDataStore): boolean;
begin
  Result := self.Query(Select, FromName, '', '', ds);
end;

function TDataStore.Query(Select: string; FromName: string;
  ColumnNameToEval, Value: string; var ds: TDataStore): boolean;
var
  Alfa_DataTable: TDataTableOfCosa;
  Beta_DataTable: TDataTableOfCosa;
  Gamma_DataTable: TDataTableOfCosa;

begin

  if not Assigned(ds) then
  begin
    Exit;
    Result := False;
  end;

  Alfa_DataTable := self.GetDataTableByName(FromName);
  if (Alfa_DataTable = nil) then
  begin
    Result := self.DataSetParent.Query(Select, FromName, ColumnNameToEval,
      Value, ds);
    exit;
  end;

  Beta_DataTable := Alfa_DataTable.Query(Select, ColumnNameToEval, Value);
  //Verifico si ya existe la tabla FromName en el ds
  //Si no la obtiene la crea clonando la tabla alfa
  Gamma_DataTable := ds.GetDataTableByName(FromName);
  if Assigned(Gamma_DataTable) then
    Gamma_DataTable.AppendDataTable(Beta_DataTable, False)
  else
    ds.AddDataTable(Beta_DataTable);

  if Beta_DataTable.DataRowListCount > 0 then
    Result := True
  else
  begin
    if Assigned(self.DataSetParent) then
      Result := self.DataSetParent.Query(Select, FromName, ColumnNameToEval,
        Value, ds)
    else
      Result := False;
  end;
end;

function TDataStore.Query(Select: string; FromName: string; RowId: integer;
  var ds: TDataStore): boolean;
var
  Alfa_DataTable: TDataTableOfCosa;
  Beta_DataTable: TDataTableOfCosa;
  Gamma_DataTable: TDataTableOfCosa;

begin

  if not Assigned(ds) then
  begin
    Exit;
    Result := False;
  end;

  Alfa_DataTable := self.GetDataTableByName(FromName);
  if (Alfa_DataTable = nil) then
  begin
    Result := self.DataSetParent.Query(Select, FromName, RowId, ds);
    exit;
  end;

  Beta_DataTable := Alfa_DataTable.Query(Select, RowId);
  //Verifico si ya existe la tabla FromName en el ds
  //Si no la obtiene la crea clonando la tabla alfa
  Gamma_DataTable := ds.GetDataTableByName(FromName);
  if Assigned(Gamma_DataTable) then
    Gamma_DataTable.AppendDataTable(Beta_DataTable, False)
  else
    ds.AddDataTable(Beta_DataTable);

  if Beta_DataTable.DataRowListCount > 0 then
    Result := True
  else
  begin
    if Assigned(self.DataSetParent) then
      Result := self.DataSetParent.Query(Select, FromName, RowId, ds)
    else
      Result := False;
  end;

end;

function TDataStore.GetEmptyTable(TableName: string;
  CloneIdCounter: boolean): TDataTableOfCosa;
var
  dt: TDataTableOfCosa;
begin
  dt := GetDataTableByName(TableName);
  if Assigned(dt) then
    Result := dt.Clone(CloneIdCounter, False)
  else
  if Assigned(DataSetParent) then
    Result := DataSetParent.GetEmptyTable(TableName, CloneIdCounter)
  else
    Result := nil;
end;

procedure TDataStore.DeleteDataRows(FromName: string; ColumnNameToEval, Value: string);
var
  Alfa_DataTable: TDataTableOfCosa;
  Alfa_DataRow: TDataRowOfCosa;
  Alfa_DataColumn: TDataColumnOfCosa;
  Alfa_DataCell: TDataCellOfCosa;

  Beta_DataTable: TDataTableOfCosa;
  Beta_DataRow: TDataRowOfCosa;
  Beta_DataColumn: TDataColumnOfCosa;
  Beta_DataCell: TDataCellOfCosa;

  dcSelectIndex: TDAofNInt;

  i, ii, j, k: integer;

  ColumnNames: TStringList;
  ColumnIndex: integer;
begin

  Alfa_DataTable := self.GetDataTableByName(FromName);
  ii := Alfa_DataTable.GetIndexOfDataColumnByName(ColumnNameToEval);

  if ((ii > -1) or (ColumnNameToEval = '')) then
  begin
    for k := 0 to Alfa_DataTable.DataRowListCount - 1 do
    begin
      Alfa_DataRow := Alfa_DataTable.GetDataRowByIndex(k);
      Alfa_DataCell := Alfa_DataRow.ConditionalGetDataCell(0, ii, Value);
      if Alfa_DataCell <> nil then
        Alfa_DataRow.SIUD := TSIUD.TDELETE;
    end;
  end;
end;

function TDataStore.PrepareInsert(Into, ColumnName: string; RowId: integer;
  Value: string; isItemOfList: boolean): TDataStore;
var
  ds: TDataStore;
  dr1, dr2: TDataRowOfCosa;
  dt: TDataTableOfCosa;
  dt_TList: TDataTableOfListOfCosa;

  sval: string = '';
  IdParent: string;
  split: TStringList;
  n: integer;
  nsval: string = '';

begin
  ds := TDataStore.Create(self);
  Query('*', Into, RowId, ds);
  dt := ds.DataTableList[0];
  dt.Visible := False;
  ds.AddDataTable(GetEmptyTable(Value, True));
  ds.DataTableList[1].Visible := True;
  dr1 := ds.DataTableList[1].GetDataRowWithDefaulValues();
  dr1.SIUD := TSIUD.TINSERT;
  ds.DataTableList[1].AddDataRow(dr1);
  if isItemOfList then
  begin
    ds.ReadDataCellTextValue(Into, RowId, 'n', nsval);
    n := StrToInt(nsval);
    ds.WriteDataCellTextValue(Into, RowId, 'n', IntToStr(n + 1));
    ds.AddDataTable(GetEmptyTable('dt_TList', True));
    dt_TList := TDataTableOfListOfCosa(ds.DataTableList[2]);
    dt_TList.Visible := False;
    dr2 := TDataRowOfCosa.Create;
    dt_TList.AddDataRow(dr2);
    dr2.SIUD := TSIUD.TINSERT;

    ds.ReadDataCellTextValue(Into, RowId, ColumnName, sval);
    if sval = '' then
    begin
      IdParent := IntToStr(dt_TList.GetNextIdParent());
      ds.WriteDataCellTextValue(Into, RowId, ColumnName,
        dt_TList.TableName + '.IdParent.' + IdParent);
    end
    else
    begin
      split := TStringList.Create;
      try
        ExtractStrings(['.'], [], PChar(sval), split);
        IdParent := split[2];
      finally
        split.Free;
      end;
    end;

    dr2.AddDataCell(TDataCellOfCosa.Create(IdParent));
    dr2.AddDataCell(TDataCellOfCosa.Create(Value + '.' + IntToStr(dr1._RowId)));

  end
  else
  begin
    ds.WriteDataCellTextValue(Into, RowId, ColumnName, Value + '.' +
      IntToStr(dr1._RowId));
  end;
  Result := ds;

end;

function TDataStore.PrepareUpdate(From, ColumnName: string; RowId: integer;
  Value: string; lst: boolean): TDataStore;
var
  ds: TDataStore;
  dr1, dr2: TDataRowOfCosa;
  dt: TDataTableOfCosa;

  sval: string;
  split: TStringList;
  DataTableChildName: string;
  DataRowChildId: integer;
  lst_sval: string = '';
  DataTableListName: string;
  DataColumnName: string;
  IdParent: string;
  aDataTableItemName: string;
  aDataRowItemId: integer;
  j: integer;
  ADataRow: TDataRowOfCosa;
  ADataCell: TDataCellOfCosa;

begin
  ds := TDataStore.Create(self);
  split := TStringList.Create;
  try
    ExtractStrings(['.'], [], PChar(Value), split);
    DataTableChildName := split[0];
    DataRowChildId := StrToInt(split[1]);
  finally
    split.Free;
  end;

  Query('*', DataTableChildName, DataRowChildId, ds);
  ds.DataTableList[0].Visible := True;
  if lst then
  begin
    //Como es una lista busco los items
    ds.ReadDataCellTextValue(DataTableChildName, DataRowChildId, 'lst', lst_sval);

    if (lst_sval <> '') then
    begin
      split := TStringList.Create;
      try
        ExtractStrings(['.'], [], PChar(lst_sval), split);
        DataTableListName := split[0];
        DataColumnName := split[1];
        IdParent := split[2];
      finally
        split.Free;
      end;
      Query('*', DataTableListName, DataColumnName, IdParent, ds);
      dt := ds.DataTableList[1];

      for j := 0 to dt.DataRowListCount - 1 do
      begin
        ADataRow := dt.DataRowList[j];
        if ADataRow.SIUD <> TSIUD.TDELETE then
        begin
          ADataCell := aDataRow.DataCellList[1];
          split := TStringList.Create;
          try
            ExtractStrings(['.'], [], PChar(aDataCell.sval), split);
            aDataTableItemName := split[0];
            aDataRowItemId := StrToInt(split[1]);
          finally
            split.Free;
          end;
          Query('*', aDataTableItemName, aDataRowItemId, ds);
          ds.GetDataTableByName(aDataTableItemName).Visible := False;
        end;
      end;
    end;
  end;

  ds.DataTableList[0].DataRowList[0].SIUD := TSIUD.TUPDATE;

  Result := ds;
end;

function TDataStore.PrepareDelete(Parent_DataTableName: string;
  Parent_DataRowId: integer;
  Child_DataTableName: string;
  Child_DataRowId: integer): TDataStore;
var
  DataSet: TDataStore;

  n: integer;
  split: TStringList;

  lst_sval: string = '';
  IdParent: string;
  nsval: string = '';

begin
  DataSet := TDataStore.Create(self);

  Query('*', Parent_DataTableName, Parent_DataRowId, DataSet);
  DataSet.ReadDataCellTextValue(Parent_DataTableName, Parent_DataRowId, 'n', nsval);
  n := StrToInt(nsval);
  nsval := IntToStr(n - 1);
  DataSet.WriteDataCellTextValue(Parent_DataTableName, Parent_DataRowId, 'n', nsval);
  if (n = 0) then
  begin
    Exit;
  end;

  Query('*', Child_DataTableName, Child_DataRowId, DataSet);
  DataSet.DataTableList[1].DataRowList[0].SIUD := TSIUD.TDELETE;

  {dfusco@20150417
   Nunca va a pasar que haya más de un registro con el mismo hijo...}
  Query('*', 'dt_TList', 'idChild', Child_DataTableName + '.' + IntToStr(
    Child_DataRowId), DataSet);
  DataSet.DataTableList[2].DataRowList[0].SIUD := TSIUD.TDELETE;

  //DataSet.DeleteDataRows('dt_TList', 'IdChild', Value);

  Result := DataSet;
end;

function TDataStore.Clone(CloneRowIdCounter: boolean;
  CloneRowList: boolean): TDataStore;
var
  Beta_DataSet: TDataStore;
  z: integer;
  Alfa_DataTable: TDataTableOfCosa;
  Beta_DataTable: TDataTableOfCosa;
begin
  Beta_DataSet := TDataStore.Create(self.DataSetParent);

  for z := 0 to self.DataTableListCount - 1 do
  begin
    Alfa_DataTable := self.DataTableList[z];
    Beta_DataTable := Alfa_DataTable.Clone(CloneRowIdCounter, CloneRowList);
    Beta_DataSet.AddDataTable(Beta_DataTable);
  end;
  Result := Beta_DataSet;
end;

//function TDataStore.View(ColNames: string): TDataTableOfCosa;
//var
//  i,j: integer;
//  dt, dt_res: TDataTableOfCosa;
//  ColumnNames: TStringList;

//begin
//  dt_res:=TDataTableOfCosa.Create('dt_DataSetView');
//  ColumnNames := TStringList.Create;
//  ColumnNames.DelimitedText := ColNames;

//  for i:=0 to ColumnNames.Count-1 do
//    dt_res.AddDataColumn(TDataColumnOfCosa.Create(ColumnNames[i],nil));

//  for j := 0 to DataTableListCount - 1 do
//  begin
//    dt:=self.DataTableList[j];
//    if not (dt is TDataTableOfListOfCosa) then
//      dt_res.AppendDataTable(dt.View(ColNames), true);
//  end;

//  Result := dt_res;
//end;

procedure TDataStore.Merge(ds: TDataStore);
var
  TableListCount: integer;
  dt1, dt2: TDataTableOfCosa;
  i: integer;
begin
  if Assigned(ds) then
  begin
    TableListCount := ds.DataTableListCount;
    for i := 0 to TableListCount - 1 do
    begin
      dt2 := ds.DataTableList[i];
      dt1 := self.GetDataTableByName(dt2.TableName);
      if Assigned(dt1) then
        dt1.Merge(dt2)
      else
        AddDataTable(dt2.Clone());
    end;
  end;
end;

procedure TDataStore.Free;
var
  z: integer;
begin
  for z := 0 to self._DataTableList.Count - 1 do
    TDataTableOfCosa(self._DataTableList[z]).Free;
  self._DataTableList.Free;
end;

function TDataStore.Equals(ADataStore: TDataStore): boolean;
var
  Alfa_DataTable, Beta_DataTable: TDataTableOfCosa;
  z: integer;
begin
  Result := True;
  for z := 0 to self.DataTableListCount - 1 do
  begin
    Alfa_DataTable := self.DataTableList[z];
    Beta_DataTable := ADataStore.DataTableList[z];
    if (not (Alfa_DataTable.Equals(Beta_DataTable))) then
    begin
      Result := False;
      Exit();
    end;
  end;
end;

function TDataStore.CompareTo(Beta_DataStore: TDataStore; DataTableName: string;
  DataRowId: integer; var Gamma_DataStore: TDataStore; BetaDataRowId: integer): boolean;
var
  Alfa_DataTable: TDataTableOfCosa;
  Beta_DataTable: TDataTableOfCosa;
  Alfa_DataRow: TDataRowOfCosa;
  z: integer;
  Beta_DataRow: TDataRowOfCosa;
  i: integer;
  dri, adri, bdri: integer;
  dcv: string;
  split: TStringList;
  dtn, adtn, bdtn: string;
  dcn: string;
  ds: TDataStore;
  dt: TDataTableOfCosa;
  dco: TDataColumnOfCosa;
  j: integer;
  dr: TDataRowOfCosa;
  dce: TDataCellOfCosa;
  dt_TList: TDataTableOfCosa;
  Gamma_DataCell: TDataCellOfCosa;
  Gamma_DataRow: TDataRowOfCosa;
  Gamma_DataTable: TDataTableOfCosa;
  Alfa_sval: string;
  Beta_sval: string;
  bb: string;
  ba: string;
  a: integer;
  puto: boolean;
  FoundEqualDataRow: boolean;
  ok: boolean;
begin
  if not Assigned(Gamma_DataStore) then
    Gamma_DataStore := TDataStore.Create(nil);

  if DataTableName = 'dt_TFichaUnidades' then
    a := 1;

  Alfa_DataTable := self.GetDataTableByName(DataTableName);
  Beta_DataTable := Beta_DataStore.GetDataTableByName(DataTableName);

  Gamma_DataTable := Gamma_DataStore.GetDataTableByName(DataTableName);
  if not Assigned(Gamma_DataTable) then
  begin
    Gamma_DataTable := Alfa_DataTable.Clone(False, False);
    Gamma_DataStore.AddDataTable(Gamma_DataTable);
  end;

  Alfa_DataRow := Alfa_DataTable.GetDataRowById(DataRowId);

  FoundEqualDataRow := False;

  if Assigned(Alfa_DataTable) and Assigned(Alfa_DataRow) and
    Assigned(Beta_DataTable) then
  begin
    Gamma_DataRow := TDataRowOfCosa.Create(Alfa_DataRow._RowId);
    Gamma_DataRow.RowName := Alfa_DataRow.RowName;
    for z := 0 to Beta_DataTable.DataRowListCount - 1 do
    begin
      Beta_DataRow := Beta_DataTable.DataRowList[z];

      if (Beta_DataRow._RowId = Alfa_DataRow._RowId) then
      (*
      if Alfa_DataTable.GetIndexOfDataColumnByName('nombre')>=0 then
      begin
        ba:=Alfa_DataRow.GetDataCellByIndex(Alfa_DataRow.DataTableOwner.GetIndexOfDataColumnByName('nombre')).sval;
        bb:=Beta_DataRow.GetDataCellByIndex(Beta_DataRow.DataTableOwner.GetIndexOfDataColumnByName('nombre')).sval;
      end
      else
      begin
        ba:='ba';
        bb:='bb';
      end;
      if ((BetaDataRowId<>-1) and (Beta_DataRow._RowId=BetaDataRowId)) or
         (CompareText(ba,bb)=0) then
      *)
      begin
        for i := 0 to Alfa_DataTable.DataColumnListCount - 1 do
        begin
          ok := True;
          Alfa_sval := Alfa_DataRow.DataCellList[i].sval;
          Beta_sval := Beta_DataRow.DataCellList[i].sval;
          if (Alfa_DataTable.DataColumnList[i].DataType is TDataTypeDataRowOfCosa) and
            (Alfa_sval <> '') then
          begin
            split := TStringList.Create();
            ExtractStrings(['.'], [], PChar(Alfa_sval), split);
            adtn := split[0];
            adri := StrToInt(split[1]);
            split.Free();

            split := TStringList.Create();
            ExtractStrings(['.'], [], PChar(Beta_sval), split);
            bdtn := split[0];
            bdri := StrToInt(split[1]);
            split.Free();

            if (CompareText(adtn, bdtn) = 0) then
            begin
              if not self.CompareTo(Beta_DataStore, adtn, adri,
                Gamma_DataStore, bdri) then
                ok := False;
            end
            else
              a := 1; //ACA SE TIENE QUE PUDRIR TODO
          end
          else if (Alfa_DataTable.DataColumnList[i].DataType is TDataTypeListOfCosa) and
            (Alfa_sval <> '') then
          begin
            split := TStringList.Create();
            ExtractStrings(['.'], [], PChar(Alfa_sval), split);
            dtn := split[0];
            dcn := split[1];
            dcv := split[2];

            ds := TDataStore.Create(nil);
            self.Query('*', dtn, dcn, dcv, ds);
            if (ds <> nil) and (ds.DataTableListCount = 1) then
            begin
              dt := ds.DataTableList[0];
              a := dt.DataRowListCount;
              dco := dt.DataColumnList[1];
              for j := 0 to dt.DataRowListCount - 1 do
              begin
                dr := dt.DataRowList[j];
                dce := dr.DataCellList[1];
                split := TStringList.Create();
                ExtractStrings(['.'], [], PChar(dce.sval), split);
                dtn := split[0];
                dri := StrToInt(split[1]);

                dt_TList := Gamma_DataStore.GetDataTableByName('dt_TList');
                if not Assigned(dt_TList) then
                begin
                  dt_TList := self.GetDataTableByName('dt_TList').Clone(False, False);
                  Gamma_DataStore.AddDataTable(dt_TList);
                end;
                dr := TDataRowOfCosa.Create();
                dr.AddDataCell(TDataCellOfCosa.Create(dcv));
                dr.AddDataCell(TDataCellOfCosa.Create(dtn + '.' + IntToStr(dri)));
                dt_TList.AddDataRow(dr);

                if not self.CompareTo(Beta_DataStore, dtn, dri, Gamma_DataStore) then
                  ok := False;

              end;
            end;
          end
          else
          if CompareText(Alfa_sval, Beta_sval) <> 0 then
            ok := False;

          Gamma_DataCell := TDataCellOfCosa.Create(Alfa_sval);
          Gamma_DataCell.Changed := not ok;
          Gamma_DataRow.AddDataCell(Gamma_DataCell);
        end;
        FoundEqualDataRow := True;
        break;
      end;
      (*
      else
      begin
        if Alfa_DataRow.Equals(Beta_DataRow) then
        begin
          for j:=0 to Alfa_DataRow.DataCellListCount-1 do
        begin
            Gamma_DataCell:=Alfa_DataRow.DataCellList[j].Clone();
            Gamma_DataCell.Changed:=false;
            Gamma_DataRow.AddDataCell(Gamma_DataCell);
        end;
          FoundEqualDataRow:=true;
          break;
        end
      end;
      *)
    end;
    if not FoundEqualDataRow then
    begin
      for j := 0 to Alfa_DataRow.DataCellListCount - 1 do
      begin
        Gamma_DataCell := Alfa_DataRow.DataCellList[j].Clone();
        Gamma_DataCell.Changed := True;
        Gamma_DataRow.AddDataCell(Gamma_DataCell);
      end;
    end;
    Gamma_DataTable.AddDataRow(Gamma_DataRow, False);
  end;
  BetaDataRowId := -1;
  Result := FoundEqualDataRow;

end;

function TDataStore.Fill(xDataTableName: string; xDataRowId: integer;
  var ADataSet: TDataStore): boolean;
var
  ds: TDataStore;
  DataTable: TDataTableOfCosa;
  i: integer;
  DataColumn: TDataColumnOfCosa;
  DataCell: TDataCellOfCosa;
  split: TStringList;
  DataTableChildName: string;
  DataRowChildId: integer;
  DataColumnName: string;
  DataCellSVal: string;
  ds_TList: TDataStore;
  j: integer;
  a: integer;
  DataRow: TDataRowOfCosa;
  b: string;
begin

  Result := True;
  // DataSet auxiliar para realizar las consultas.
  ds := TDataStore.Create(nil);
  if self.Query('*', xDataTableName, xDataRowId, ds) then
  begin

    //if assigned(ADataSet.GetDataTableByName('dt_TFuenteConstante')) then
    //  b:=ADataSet.GetDataTableByName('dt_TFuenteConstante').DataRowList[0].DataCellList[
    //    ADataSet.GetDataTableByName('dt_TFuenteConstante').GetIndexOfDataColumnByName('nombresdebornes_publicados')
    //  ].sval;

    //WriteLn();
    //WriteLn('>>> DEBUG: TDataStore.Fill('+xDataTableName+', '+IntToStr(xDataRowId)+')');

    ADataSet.Merge(ds);

    //if assigned(self.GetDataTableByName('dt_TFuenteConstante')) then
    //  b:=self.GetDataTableByName('dt_TFuenteConstante').DataRowList[0].DataCellList[
    //    self.GetDataTableByName('dt_TFuenteConstante').GetIndexOfDataColumnByName('nombresdebornes_publicados')
    //  ].sval;

    DataTable := ADataSet.GetDataTableByName(xDataTableName);
    for i := 0 to DataTable.DataColumnListCount - 1 do
    begin
      DataColumn := DataTable.DataColumnList[i];
      DataRow := DataTable.GetDataRowById(xDataRowId);
      DataCell := DataRow.DataCellList[i];
      //Writeln(DataColumn.ColumnName + ' = ' + DataCell.sval);
      if DataCell.sval <> '' then
      begin
        if DataColumn.DataType is TDataTypeDataRowOfCosa then
        begin
          parseRowReference(DataCell.sval, DataTableChildName, DataRowChildId);
          self.Fill(DataTableChildName, DataRowChildId, ADataSet);
        end
        else if DataColumn.DataType is TDataTypeListOfCosa then
        begin
          //Writeln('DataColumn.ColumnName = '+DataColumn.ColumnName + ' / ' + 'DataCell.sval = ' + DataCell.sval);
          parseListReference(DataCell.sval, DataTableChildName,
            DataColumnName, DataCellSVal);
          ds_TList := TDataStore.Create(nil);
          self.Query('*', DataTableChildName, DataColumnName, DataCellSVal, ds_TList);
          ADataSet.Merge(ds_TList);
          for j := 0 to ds_TList.DataTableList[0].DataRowListCount - 1 do
          begin
            parseRowReference(
              ds_TList.DataTableList[0].DataRowList[j].DataCellList[1].sval,
              DataTableChildName, DataRowChildId);
            self.Fill(DataTableChildName, DataRowChildId, ADataSet);
          end;
          ds_TList.Free;
        end;
      end;
    end;
    //WriteLn('<<<');
  end
  else
    Result := False;

  ds.Free;

end;

procedure TDataStore.GetDataTableOnLastVersion(DataTableName: string;
  var DataTable: TDataTableOfCosa);
var
  dt1, dt2: TDataTableOfCosa;
begin

  dt1 := GetDataTableByName(DataTableName);
  if Assigned(dt1) then
  begin
    dt2 := dt1.Clone();
    if Assigned(DataTable) then
    begin
      dt2.Merge(DataTable);
    end;
    DataTable := dt2;
  end;

  if Assigned(self.DataSetParent) then
    self.DataSetParent.GetDataTableOnLastVersion(DataTableName, DataTable);

end;

function TDataStore.First: TDataStore;
begin

end;

function TDataStore.Prior: TDataStore;
begin

end;

function TDataStore.Next: TDataStore;
begin

end;

function TDataStore.Last: TDataStore;
begin

end;

procedure parseRowReference(sval: string; var DataTableName: string;
  var RowId: integer);
var
  split: TStringList;
begin
  split := TStringList.Create();
  ExtractStrings(['.'], [], PChar(sval), split);
  DataTableName := split[0];
  RowId := StrToInt(split[1]);
  split.Free();
end;

function parseListReference(sval: string; var DataTableName: string;
  var DataColumnName: string; var IdParent: string): boolean;
var
  split: TStringList;
begin
  split := TStringList.Create();
  ExtractStrings(['.'], [], PChar(sval), split);
  DataTableName := split[0];
  DataColumnName := split[1];
  IdParent := split[2];
  split.Free();

end;

function TDataStore.View(VirtualTable: TDataVTableOfCosa): TDataTableOfCosa;
var
  i: integer;

  vdrl: TList;
  nRows: integer;

  dt_res: TDataTableOfCosa;
begin

  vdrl := VirtualTable.GetDataRowList(self);
  nRows := vdrl.Count;
  dt_res := TDataTableOfCosa.Create('view', VirtualTable.GetDataColumnList().Clone());

  for i := 0 to nRows - 1 do
    dt_res.AddDataRow(TDataVRowOfCosa(vdrl.Items[i]));

  Result := dt_res;

end;

procedure TDataStore.Clear;
var
  z: integer;
begin
  for z := 0 to self.DataTableListCount - 1 do
  begin
    self.DataTableList[z].Clear();
  end;
end;

function TDataStore.GetDataTableByIndex(Index: integer): TDataTableOfCosa;
begin
  Result := self._DataTableList[Index];
end;

function TDataStore.GetDataTableByName(DataTableName: string;
  climb: boolean): TDataTableOfCosa;
var
  Index: integer;
begin
  Result := nil;
  Index := GetIndexOfDataTableByName(DataTableName);
  if Index > -1 then
    Result := DataTableList[Index]
  else
  begin
    if Assigned(self.DataSetParent) and climb then
      Result := self.DataSetParent.GetDataTableByName(DataTableName, climb);
  end;
end;

function TDataStore.GetDataTableListCount: integer;
var
  Count: longint;
begin
  Result := self._DataTableList.Count;
end;

procedure TDataStore.LoadFromCosaHashList(cosaHashList: TCosaHashList;
  root: string; version: integer);
var
  item: TCosaHashListItem;

  function HashToDataRow(CosaHashList: TCosaHashList; version: integer): TDataRowOfCosa;
  var
    DataTableName: string;

    ClaseDeCosa: TClaseDeCosa;

    DataTable_NewestVersion, DataTable_FileVersion: TDataTableOfCosa;
    DataRow_NewestVersion, DataRow_FileVersion, dr_TList, ADataRow: TDataRowOfCosa;

    i, j: integer;
    item: TCosaHashListItem;

    dt_TList: TDataTableOfListOfCosa;
    listItem: TCosaHashList;
    LastIdParent: integer;
    sval: string;
    DataColumn: TDataColumnOfCosa;
    ad: NReal;
    adt: TDateTime;
    a: integer;
    foundit: boolean;
    continue: boolean;
  begin

    DataTableName := 'dt_' + CosaHashList.CosaStrId;

    if DataTableName = 'dt_TListaCentralesAguasArriba' then
      a := 1;

    DataTable_NewestVersion := DATA_STORE.GetDataTableByName(DataTableName);
    if not Assigned(DataTable_NewestVersion) then
      raise Exception.Create(
        'TDataStore.AddTablesFromHashList: No se encuenta la tabla ' +
        DataTableName + ' en el DATA_STORE');

    ClaseDeCosa := TClaseDeCosa(getClaseOf(CosaHashList.CosaStrId));
    DataTable_FileVersion := TDataTableOfCosa.Create(DataTableName, ClaseDeCosa, version);
    DataRow_FileVersion := TDataRowOfCosa.Create();

    for i := 0 to DataTable_FileVersion.GetDataColumnList().Count - 1 do
    begin

      DataColumn := DataTable_FileVersion.GetDataColumnList()[i];

      //WriteLn(DataTableName,' ',DataColumn.ColumnName);

      if LowerCase(DataColumn.ColumnName) = LowerCase('lst') then
        a := 1;

      foundit := CosaHashList.Find(DataColumn.ColumnName, item);

      continue := True;

      {dfusco@20150609
       PARCHE NECESARIO PORQUE ESTA COSA ES UNA
       TCOSAPARTICIPEDELMERCADO Y DEBERÍA TENER UN ATRIBUTO "LPD" QUE EN EL
       ARCHIVO *.ESE NO ESTÁ}
      if ((CosaHashList.CosaStrId = 'TSalaDeJuego') or
        (CosaHashList.CosaStrId = 'TDemandaDetallada') or
        (CosaHashList.CosaStrId = 'TNodo') or
        (CosaHashList.CosaStrId = 'TFuenteSintetizadorCEGH')) and
        (DataColumn.ColumnName = 'lpd') then
      begin
        sval := DataColumn.ValorPorDefecto;
        continue := False;
      end
      else

      {dfusco@20150609
       PARCHE NECESARIO PORQUE POR LA FORMA EN QUE SE REPRESENTA LA PERIODICIDAD
       DE LA FICHA LPD EN EL ARCHIVO *.ESE. }
      if ucosa.IsChild('TFichaLPD', CosaHashList.CosaStrId) then
      begin  //ATRIBUTOS DE TFICHALPD
        if ((LowerCase(DataColumn.ColumnName) = LowerCase('fecha')) or
          (LowerCase(DataColumn.ColumnName) = LowerCase('expandida')) or
          (LowerCase(DataColumn.ColumnName) = LowerCase('esPeriodica')) or
          (LowerCase(DataColumn.ColumnName) = LowerCase('iniHorizonte')) or
          (LowerCase(DataColumn.ColumnName) = LowerCase('finHorizonte')) or
          (LowerCase(DataColumn.ColumnName) = LowerCase('offset')) or
          (LowerCase(DataColumn.ColumnName) = LowerCase('ciclosOn')) or
          (LowerCase(DataColumn.ColumnName) = LowerCase('ciclosOff')) or
          (LowerCase(DataColumn.ColumnName) = LowerCase('durPeriodoEnHoras')) or
          (LowerCase(DataColumn.ColumnName) = LowerCase('tipo'))) and
          (not foundit) then
        begin
          sval := '';
          continue := False;
        end;
      end
      else
      if (not foundit) then
      begin
        continue := not (DataTable_NewestVersion.GetDataColumnByName(
          DataColumn.ColumnName).DataType is TDataTypeDataRowOfCosa or
          DataTable_NewestVersion.GetDataColumnByName(
          DataColumn.ColumnName).DataType is TDataTypeListOfCosa);
        //writeln(DataColumn.DataType.ClassName);

      end;


      if (not foundit) and (continue) then
        raise Exception.Create('No se encontro en el archivo el campo "' +
          DataTable_FileVersion.GetDataColumnList()[i].ColumnName + '" de la clase "' +
          CosaHashList.CosaStrId + '".')
      else
      begin

        if continue then
        begin

          if item.isString then
          begin

            sval := item.sval;

            //if DataColumn.DataType is TDataTypeDoubleOfCosa then
            //begin
            //  ad:=StrToFloat(sval);
            //  sval:=FloatToStr(ad);
            //end;

            //if DataColumn.DataType is TDataTypeDateOfCosa then
            //begin
            //  adt:=StrToDate(sval);
            //  sval:=DateToStr(adt);
            //end;

          end

          else
          begin
            if item.CosaHashList.CosaStrId = 'TList' then
            begin
              dt_TList := TDataTableOfListOfCosa(
                DATA_STORE.GetDataTableByName('dt_TList'));
              LastIdParent := dt_TList.GetNextIdParent();
              for j := 0 to item.CosaHashList.Count - 1 do
              begin
                ADataRow := HashToDataRow(item.CosaHashList[j].CosaHashList, version);
                dr_TList := TDataRowOfCosa.Create();
                dr_TList.AddDataCell(TDataCellOfCosa.Create(IntToStr(LastIdParent)));
                dr_TList.AddDataCell(TDataCellOfCosa.Create(
                  'dt_' + item.CosaHashList[j].CosaHashList.CosaStrId + '.' + IntToStr(ADataRow.RowId)));
                //dr_TList.AddDataCell(TDataCellOfCosa.Create('dt_'+DataColumn.DataType.ClaseDeCosa.ClassName+'.'+IntToStr(ADataRow.RowId)));
                dt_TList.AddDataRow(dr_TList);
              end;
              sval := dt_TList.TableName + '.IdParent.' + IntToStr(LastIdParent);
            end

            else
            begin
              //ADataRow:=HashToDataRow(item.CosaHashList, version);
              //sval:='dt_'+DataColumn.DataType.ClaseDeCosa.ClassName+'.'+IntToStr(ADataRow.RowId);
              ADataRow := HashToDataRow(item.CosaHashList, version);
              sval := 'dt_' + item.CosaHashList.CosaStrId + '.' + IntToStr(ADataRow.RowId);
            end;
          end;
        end;

        DataRow_FileVersion.AddDataCell(TDataCellOfCosa.Create(sval));

      end;
    end;

    DataRow_FileVersion.SIUD := TSELECT;
    DataTable_FileVersion.AddDataRow(DataRow_FileVersion, True);

    DataRow_NewestVersion := TDataRowOfCosa.Create();
    DataRow_NewestVersion.SIUD := DataRow_FileVersion.SIUD;
    DataTable_NewestVersion.AddDataRow(DataRow_NewestVersion);

    DataTable_NewestVersion.ConvertDataRowToNewestVersion(DataRow_NewestVersion,
      DataTable_FileVersion);

    Result := DataRow_NewestVersion;

  end;

begin

  if not CosaHashList.Find(root, item) then
    raise Exception.Create(
      'TDataStore.LoadFromCosaHashList: No se encontro el campo sala en el archivo.');

  HashToDataRow(item.cosaHashList, version);

end;


function TDataStore.ReadDataCellTextValue(TableName: string; RowId: integer;
  ColumnName: string; var sval: string; climb: boolean): boolean;
var
  DataTable: TDataTableOfCosa;
  DataRow: TDataRowOfCosa;
  DataCell: TDataCellOfCosa;
begin
  Result := False;
  DataTable := self.GetDataTableByName(TableName);
  if (not assigned(DataTable)) and climb then
  begin
    Result := self.DataSetParent.ReadDataCellTextValue(TableName, RowId,
      ColumnName, sval, climb);
    exit;
  end;
  if Assigned(DataTable) then
    Result := DataTable.ReadDataCellTextValue(RowId, ColumnName, sval);
end;


function TDataStore.ReadDataCellTextValues(TableName, ColumnNameToQuery,
  CellSValToQuery, ColumnNameToGetSVal: string; climb: boolean): TDAofString;
var
  h, i, j, j1, j2, Count: integer;
  DataTable: TDataTableOfCosa;
  DataRow: TDataRowOfCosa;
  DataCell1, DataCell2: TDataCellOfCosa;
  ssvals: string = '';
  daossval: array of string;
begin
  SetLength(daossval, 0);
  Count := 0;
  DataTable := self.GetDataTableByName(TableName);
  if not Assigned(DataTable) then
  begin
    if Assigned(self.DataSetParent) and climb then
    begin
      Result := self.DataSetParent.ReadDataCellTextValues(TableName,
        ColumnNameToQuery, CellSValToQuery, ColumnNameToGetSVal, climb);
      Exit();
    end
    else
      raise Exception.Create(
        'TDataStore.ReadDataCellTextValues: No se encontro la tabla "' + TableName +
        '" en el DATA SET.');
  end;

  j1 := DataTable.GetIndexOfDataColumnByName(ColumnNameToQuery);
  j2 := DataTable.GetIndexOfDataColumnByName(ColumnNameToGetSVal);
  for i := 0 to DataTable.DataRowListCount - 1 do
  begin
    DataRow := DataTable.DataRowList[i];
    DataCell1 := DataRow.DataCellList[j1];
    if (DataCell1.sval = CellSValToQuery) then
    begin
      DataCell2 := DataRow.DataCellList[j2];
      ssvals := ssvals + ',' + DataCell2.sval;
      Count := Count + 1;
    end;
  end;

  if Count = 0 then
    Exit();

  ssvals := Copy(ssvals, 2, Length(ssvals) - 1);
  ssvals := '[' + IntToStr(Count) + '| ' + ssvals + ']';
  parseDAOfString(daossval, ssvals);
  Result := daossval;
end;

function TDataStore.ReadRowIdsTextValues(TableName, ColumnNameToQuery,
  CellSValToQuery: string): TDAofNInt;
var
  i, j: integer;
  DataTable: TDataTableOfCosa;
  DataRow: TDataRowOfCosa;
  DataCell: TDataCellOfCosa;
  ssvals: string;
  daossval: array of string;
  rowIds: TDAofNInt;
  Count: integer;
begin
  Count := 0;
  DataTable := self.GetDataTableByName(TableName);
  SetLength(rowIds, DataTable.GetDataRowListCount());
  j := DataTable.GetIndexOfDataColumnByName(ColumnNameToQuery);
  for i := 0 to DataTable.DataRowListCount - 1 do
  begin
    DataRow := DataTable.DataRowList[i];
    DataCell := DataRow.DataCellList[j];
    if (DataCell.sval = CellSValToQuery) then
    begin
      rowIds[Count] := DataRow._RowId;
      Count := Count + 1;
    end;
  end;
  SetLength(rowIds, Count);
  Result := rowIds;
end;

function TDataStore.WriteDataCellTextValue(TableName: string; RowId: integer;
  AttributeName: string; Value: string): boolean;
var
  dt: TDataTableOfCosa;
  dr: TDataRowOfCosa;
  i: integer;
  dcll: TDataCellOfCosa;
begin
  Result := True;
  dt := GetDataTableByName(TableName);
  dr := dt.GetDataRowById(RowId);
  dr.SIUD := TSIUD.TUPDATE;
  i := dt.GetIndexOfDataColumnByName(AttributeName);
  if Assigned(dr) and (i > -1) then
  begin
    dcll := dr.GetDataCellByIndex(i);
    dcll.sval := Value;
  end
  else
    Result := False;
end;

procedure TDataStore.CreateClassInstance(TableName: string; RowId: integer;
  var cosa: TCosa);
var
  DataTable: TDataTableOfCosa;
  ColumnList: TDataColumnListOfCosa;
  ClassOwner: TClaseDeCosa;
  i: integer;
  DataColumn: TDataColumnOfCosa;
  sval: string;

  typeData: TTypeData;
  PropInfo: PPropInfo;
  a: integer;
  l: integer;
  DataRow: TDataRowOfCosa;

  PGetProc: longint;
  PSetProc: longint;
  P: Pointer;
  M: TMethod;
  lpd: TFichasLPD;
  ficha: TFichaFuenteConstante;

begin

  //WriteLn(TableName);

  if TableName = 'dt_TPeriodicidad' then
    a := 1;

  DataTable := self.GetDataTableByName(TableName);

  DataRow := DataTable.GetDataRowById(RowId);

  ColumnList := DataTable.GetDataColumnList;
  ClassOwner := ColumnList.ClassOwner;
  cosa := ClassOwner.Create();
  for i := 0 to DataTable.DataColumnListCount - 1 do
  begin

    DataColumn := DataTable.DataColumnList[i];

    //WriteLn(DataColumn.ColumnName);

    if DataColumn.ColumnName = 'ciclosoff' then
      a := 1;

    sval := DataRow.DataCellList[i].sval;

    //FUENTE:
    //http://stackoverflow.com/questions/11701116/gettypedata-floattype-in-fpc-in-a-mvframework-dont-compile

    (* First, get property info *)
    PropInfo := GetPropInfo(cosa, '_' + DataColumn.ColumnName);

    (* Initialization *)
    PGetProc := 0;

    (* If we can't get property info, then exit *)
    if Assigned(PropInfo) and Assigned(PropInfo^.SetProc) and
      Assigned(PropInfo^.GetProc) then
    begin
      (* Get memory addresses of SetProc and GetProc *)
      PGetProc := longint(PropInfo^.GetProc);
      PSetProc := longint(PropInfo^.SetProc);
    end
    else
      raise ExcepcionPersistentAttributeDoesNotHasProperty.Create(
        'El atributo ' + DataColumn.ColumnName + ' de la clase ' + cosa.ClassName +
        ' no tiene asignado la propiedad.');

    (* Obtenemos el offset $00FFFFFF de la instancia + el desplazamiento de la variable *)
    (* Luego escribimos en la direccion obtenida en forma directa - si el metodo es una *)
    (* variable tambien los escribe = ((PSetProc and $FF000000) = $FF000000)) *)

    if not ((PSetProc and $FF000000) = $FF000000) or
      (PropInfo^.SetProc = PropInfo^.GetProc) then
    begin
      (* Direccion de desplazamiento *)
      P := Pointer(integer(cosa) + (PGetProc and $00FFFFFF));

      DataColumn.DataType.Eval(sval, P);
    end
    else
      raise ExcepcionPersistentPropertyHasToPointAtAttribute.Create(
        'La propiedad del atributo ' + DataColumn.ColumnName + ' de la clase ' +
        cosa.ClassName + ' debe apuntar directamente a la variable.');


    // SI EL SET FUERA UN MÉTODO...

    //(* Procesamos aquellos que posean un metodo convencional que no sean variable *)
    //if not ((PSetProc and $FF000000) = $FF000000) then
    //  //if (PropInfo^.SetProc <> NilValue) then
    //  begin
    //    (* Obtenemos la clase de matodo 1- Metodo virtual 2- metodo convencional *)
    //    (* Varian el primero del segundo en el desplazamiento VMT (Virtual method table ) *)
    //    if (PSetProc and $FF000000) = $FE000000 then
    //      M.Code := Pointer(PInteger(PInteger(cosa)^ + SmallInt(PSetProc))^)
    //    else
    //      M.Code := Pointer(PSetProc);

    //    (* Completamos con la instancia *)
    //    M.Data := cosa;
    //  end;

  end;

  if TableName = 'dt_TSalaDeJuego' then
  begin
    ficha := TFichaFuenteConstante(TFuenteConstante(
      TSalaDeJuego(cosa).listaFuentes.items[0]).lpd.items[0]);
  end;

  if TableName = 'dt_TListFuenteAleatoria' then
  begin
    a := 1;
  end;

  if TableName = 'dt_TFuenteConstante' then
  begin
    a := 1;

  end;

  if TableName = 'dt_TFichaFuenteConstante' then
  begin
    ficha := TFichaFuenteConstante(cosa);
  end;

  cosa.id := RowId;
  cosa.AfterInstantiation();
end;

function TDataStore.CreateDataRowFromInstance(cosa: TCosa; DataTableName: string;
  RowName: string; climb: boolean): integer;
var
  DataTable: TDataTableOfCosa;
  h: integer;
  DataRow: TDataRowOfCosa;
  DataColumn: TDataColumnOfCosa;
  sval: string;
  i, j: integer;
  alfa_dt_TList, beta_dt_TList: TDataTableOfListOfCosa;
  LastIdParent: integer;

  pCosa: PLongWord;
  DataRowOfList: TDataRowOfCosa;
  Item: TCosa;
  DataTableItem: TDataTableOfCosa;
  DataTableItemName: string;
  rowIds: TDAofNInt;
  rowIdChild: integer;
  cosaRef: PCosaConNombre;
  DataTableNameChild: string;
  a: integer;

  Beta_ds_TList: TDataStore;

  Alfa_DataRow: TDataRowOfCosa;
  split: TStringList;
  idparent: string;
  found: boolean;
  l: integer;
  dr: TDataRowOfCosa;

begin

  if cosa.apodo = 'Cero' then
    a := TFuenteConstante(cosa).lpd.items[0].id;

  DataTable := self.GetDataTableByName(DataTableName, True);
  if not Assigned(DataTable) then
    raise Exception.Create(
      'TDataStore.CreateDataRowFromInstance: No se encontro la tabla "' +
      DataTableName + '" en el DATA SET.');

  // SE CREA LA FILA DE LA TABLA
  DataRow := TDataRowOfCosa.Create(DataTable, RowName);

  for i := 0 to DataTable.DataColumnListCount - 1 do
  begin
    sval := '';
    rowIdChild := -1;
    DataColumn := DataTable.DataColumnList[i];

    if (DataColumn.ColumnName = 'nombresdebornes_publicados') then
      a := 1;

    //Funca para OS de 64 bits ??
    //pCosa := PLongWord(cosa);
    //pCosa := PLongWord(PByte(cosa) + DataColumn.Offset);
    //pCosa := PLongWord(pCosa^);

    if DataColumn.DataType is TDataTypeDataRowOfCosa then
    begin
      if Assigned(pCosa) then
      begin
        //20150223: PARCHE PORQUE TODAVIA NO FUERON MIGRADAS TODAS LAS COSAS
        if Assigned(DataColumn.DataType.ClaseDeCosa) then
          DataTableNameChild := 'dt_' + DataColumn.DataType.ClaseDeCosa.ClassName
        else
          DataTableNameChild := 'dt_' + TCosa(pCosa).ClassName;

        rowIdChild := CreateDataRowFromInstance(TCosa(pCosa),
          DataTableNameChild, 'dr_' + DataColumn.ColumnName, climb);

        sval := DataTableNameChild + '.' + IntToStr(rowIdChild);
      end
      else
        sval := '';
    end

    else if DataColumn.DataType is TDataTypeReferenciaOfCosa then
    begin
      if Assigned(pCosa) then
        sval := referenciaACosa(TCosa(pCosa))
      else
        sval := '<?.?>';
    end

    else if DataColumn.DataType is TDataTypeListOfCosa then
    begin
      if Assigned(pCosa) and (TList(pCosa).Count > 0) then
      begin

        sval := DataTable.GetDataRowById(cosa.id).DataCellList[DataColumn.Index].sval;

        Beta_ds_TList := TDataStore.Create(self);

        split := TStringList.Create;
        ExtractStrings(['.'], [], PChar(sval), split);
        idparent := split[2];
        self.Query('*', 'dt_TList', 'idParent', idparent, Beta_ds_TList);
        beta_dt_TList := TDataTableOfListOfCosa(Beta_ds_TList.DataTableList[0]);

        //VOY A PONER TODAS LAS FILAS EN SIUD DELETE, LAS QUE A FINAL CONTINUEN
        //EN ESTE ESTADO ES PORQUE FUERON ELIMINADAS (EN EL OBJETO).
        for j := 0 to beta_dt_TList.DataRowListCount - 1 do
          beta_dt_TList.DataRowList[j].SIUD := TSIUD.TDELETE;

        for j := 0 to TList(pcosa).Count - 1 do
        begin
          Item := TCosa(TList(pcosa).items[j]);

          //CREO EL REGISTRO EN LA TABLA CORRESPONDIENTE:
          RowIdChild := CreateDataRowFromInstance(Item, 'dt_' +
            Item.ClassName, 'dr_:' + IntToStr(j + 1), climb);

          found := False;
          for l := 0 to beta_dt_TList.DataRowListCount - 1 do
          begin
            if LowerCase(beta_dt_TList.DataRowList[l].DataCellList[1].sval) =
              LowerCase('dt_' + Item.ClassName + '.' + IntToStr(Item.id)) then
            begin
              beta_dt_TList.DataRowList[l].SIUD := TSIUD.TUPDATE;
              found := True;
              break;
            end;
          end;

          if not found then
          begin
            //CREO EL REGISTRO EN LA TABLA DE LISTAS:
            dr := TDataRowOfCosa.Create(beta_dt_TList, '');
            dr.SIUD := TSIUD.TINSERT;
            dr.AddDataCell(TDataCellOfCosa.Create(idparent));
            dr.AddDataCell(TDataCellOfCosa.Create(
              'dt_' + Item.ClassName + '.' + IntToStr(RowIdChild)));
            beta_dt_TList.AddDataRow(dr);
          end;
        end;

        //Ya que la QUERY devuelve una clonación hago el MARGE con la tabla POSTA.
        alfa_dt_TList := TDataTableOfListOfCosa(self.GetDataTableByName('dt_TList', True));
        alfa_dt_TList.Merge(beta_dt_TList);
      end
      else
      begin
        sval := '';
      end;
    end
    else if DataColumn.DataType is TDataTypeArchiRefOfCosa then
    begin
      if Assigned(pCosa) then
        sval := TArchiRef(pCosa).get_archi
      else
        sval := '';
    end;
    //else
    //  sval := DataColumn.DataType.ToString(Pbyte(cosa)+DataColumn.Offset);

    DataRow.AddDataCell(TDataCellOfCosa.Create(sval));
  end;

  //SE HACE MARGE ENTRE LA FILA DE LA BASE DEDATOS Y LA FILA CONVERTIDA...
  if cosa.id > 0 then
  begin
    DataRow._RowId := cosa.id;
    DataRow.SIUD := TSIUD.TUPDATE;
    DataTable.GetDataRowById(cosa.id).Merge(DataRow);
  end
  else
  begin
    DataRow.SIUD := TSIUD.TINSERT;
    DataTable.AddDataRow(DataRow);
  end;

  Result := DataRow._RowId;

end;

function TDataStore.AddDataTable(xDataTable: TDataTableOfCosa): integer;
begin
  self._DataTableList.Add(xDataTable);
  xDataTable.DataStoreOwner := self;
end;


//////////////////////////////////////////////////////////////////////////////
//TDataTableOfCosa
//////////////////////////////////////////////////////////////////////////////
constructor TDataTableOfCosa.Create(xTableName: string; claseDeCosa: TClaseDeCosa;
  xVersion: integer = -2);
var
  DataRow: TDataRowOfCosa;
begin
  Visible := True;
  self._DATAROWID_COUNTER := 1000;
  self.TableName := xTableName;
  if claseDeCosa <> nil then
  begin
    self._DataColumnList := claseDeCosa.CreateDataColumnList(claseDeCosa, xVersion);
    self._DataColumnList.DataTableOwner := self;
    self._DataConversionList := claseDeCosa.CreateDataConversionList();
    self._DataConversionList.ClassOfObject := claseDeCosa;
    self._DataRowList := TList.Create();
  end;
end;

constructor TDataTableOfCosa.Create(xTableName: string;
  xDataColumnList: TDataColumnListOfCosa);
var
  DataRow: TDataRowOfCosa;
  i: integer;
begin
  Visible := True;
  self._DATAROWID_COUNTER := 1000;
  self.TableName := xTableName;
  self._DataColumnList := xDataColumnList;
  self._DataConversionList := TListDataConversion.Create();
  self._DataColumnList.DataTableOwner := self;
  self._DataRowList := TList.Create();
end;

constructor TDataTableOfCosa.Create(xTableName: string;
  xDataColumnList: TDataColumnListOfCosa; xDataRowList: TList);
begin
  self.Visible := True;
  self.TableName := xTableName;
  self._DataColumnList := xDataColumnList;
  self._DataRowList := xDataRowList;
end;

constructor TDataTableOfCosa.Create(xTableName: string);
var
  DataRow: TDataRowOfCosa;
begin
  Visible := True;
  self._DATAROWID_COUNTER := 1000;
  self.TableName := xTableName;
  self._DataColumnList := TDataColumnListOfCosa.Create();
  self._DataColumnList.DataTableOwner := self;
  self._DataConversionList := TListDataConversion.Create();
  self._DataRowList := TList.Create();
end;

function TDataTableOfCosa.ReadDataCellTextValue(ColumnName: string;
  var sval: string): boolean;
begin
  Result := self.ReadDataCellTextValue(1001, ColumnName, sval);
end;

function TDataTableOfCosa.GetDataRowById(Id: integer): TDataRowOfCosa;
var
  i: integer;
begin
  Result := nil;
  for i := 0 to self._DataRowList.Count - 1 do
    if DataRowList[i]._RowId = Id then
    begin
      Result := DataRowList[i];
      break;
    end;
end;

function TDataTableOfCosa.GetIndexOfDataRowById(Id: integer): integer;
var
  Index: integer;
begin
  Result := -1;
  for Index := 0 to self._DataRowList.Count - 1 do
    if (self.GetDataRowById(Index)._RowId = Id) then
    begin
      Result := index;
      Break;
    end;
end;


function TDataTableOfCosa.GetDataRowList: TList;
begin
  Result := self._DataRowList;
end;

procedure TDataTableOfCosa.SetDataRowList(drl: TList);
begin
  self._DataRowList := drl;
end;

function TDataTableOfCosa.GetDataRowListCount: integer;
begin
  Result := self._DataRowList.Count;
end;

function TDataTableOfCosa.GetDataConversionByIndex(Index: integer): TDataConversion;
begin
  Result := self._DataConversionList[Index];
end;

function TDataTableOfCosa.GetDataRowByIndex(Index: integer): TDataRowOfCosa;
begin
  Result := self._DataRowList[Index];
end;

function TDataTableOfCosa.GetDataRowIdCounter: integer;
begin
  Result := self._DATAROWID_COUNTER;
end;

procedure TDataTableOfCosa.SetDataRowIdCounter(AValue: integer);
begin
  self._DATAROWID_COUNTER := AValue;
end;

function TDataTableOfCosa.GetDataColumnByIndex(Index: integer): TDataColumnOfCosa;
begin
  Result := self._DataColumnList.Items[Index];
end;

function TDataTableOfCosa.AddDataColumn(xDataColumn: TDataColumnOfCosa): integer;
begin
  if xDataColumn <> nil then
  begin
    Result := self._DataColumnList.Add(xDataColumn);
    xDataColumn.DataColumnListOwner := self._DataColumnList;
    xDataColumn.Index := Result;
  end
  else
    Result := -1;
end;

procedure TDataTableOfCosa.SetDataColumnList(dcl: TDataColumnListOfCosa);
var
  i: integer;
begin
  self._DataColumnList := dcl;
  dcl.DataTableOwner := self;
end;

function TDataTableOfCosa.GetDataColumnByName(Name: string): TDataColumnOfCosa;
var
  Index: integer;
  DataColumn: TDataColumnOfCosa;
begin
  Result := nil;
  for Index := 0 to self._DataColumnList.Count - 1 do
  begin
    DataColumn := self.GetDataColumnByIndex(Index);
    if (LowerCase(DataColumn.ColumnName) = LowerCase(Name)) then
    begin
      Result := DataColumn;
      Break;
    end;
  end;
end;

function TDataTableOfCosa.GetIndexOfDataColumnByName(Name: string): integer;
var
  Index: integer;
  b: string;
begin
  Result := -1;
  for Index := 0 to self._DataColumnList.Count - 1 do
  begin
    b := LowerCase(self.GetDataColumnByIndex(Index).ColumnName);
    if (LowerCase(self.GetDataColumnByIndex(Index).ColumnName) = LowerCase(Name)) then
    begin
      Result := index;
      Break;
    end;
  end;
end;

function TDataTableOfCosa.GetDataColumnList: TDataColumnListOfCosa;

var
  a: string;
begin
  Result := self._DataColumnList;
end;

function TDataTableOfCosa.GetDataColumnListCount: integer;
begin
  Result := self._DataColumnList.Count;
end;

function TDataTableOfCosa.GetDataConversionList: TListDataConversion;
begin
  Result := self._DataConversionList;
end;

function TDataTableOfCosa.GetDataConversionListCount: integer;
begin
  Result := self._DataConversionList.Count;
end;

function TDataTableOfCosa.Clone(CloneRowIdCounter: boolean;
  CloneRowList: boolean): TDataTableOfCosa;
var
  Beta_DataTable: TDataTableOfCosa;
  Alfa_DataRow: TDataRowOfCosa;
  Beta_DataRow: TDataRowOfCosa;
  i, j: integer;
  Alfa_DataColumn: TDataColumnOfCosa;
  Beta_DataColumn: TDataColumnOfCosa;
begin
  Beta_DataTable := TDataTableOfCosa.Create;
  if (CloneRowIdCounter) then
    Beta_DataTable._DATAROWID_COUNTER := self._DATAROWID_COUNTER;
  Beta_DataTable.TableName := self.TableName;

  Beta_DataTable.SetDataColumnList(self.GetDataColumnList().Clone());

  Beta_DataTable._DataConversionList := nil;
  //self._DataConversionList;      *** nil o Clonar??

  //Beta_Datatable.SetDataRowList(self.GetDataRowList().Clone());
  Beta_DataTable._DataRowList := TList.Create();
  if (CloneRowList) then
  begin
    for j := 0 to self.DataRowListCount - 1 do
    begin
      Alfa_DataRow := self.DataRowList[j];
      Beta_DataRow := Alfa_DataRow.Clone();
      Beta_DataTable.AddDataRow(Beta_DataRow, False);
    end;
  end;
  Beta_DataTable.Visible := self.Visible;
  Result := Beta_DataTable;
end;

function TDataTableOfCosa.ReadDataCellTextValue(RowId: integer;
  ColumnName: string; var sval: string): boolean;
var
  Index, j: integer;
  DataRow: TDataRowOfCosa;
  DataCell: TDataCellOfCosa;
begin
  sval := '';
  Result := False;
  DataRow := self.GetDataRowById(RowId);
  if Assigned(DataRow) then
  begin
    j := self.GetIndexOfDataColumnByName(ColumnName);
    if (j >= 0) then
    begin
      DataCell := DataRow.DataCellList[j];
      sval := DataCell.sval;
      Result := True;
    end;
  end;
end;

function TDataTableOfCosa.ReadDataCellTextValueByRowIndex(RowIndex: integer;
  ColumnName: string; var sval: string): boolean;
var
  j: integer;
  DataRow: TDataRowOfCosa;
  DataCell: TDataCellOfCosa;
begin
  Result := False;
  DataRow := self.GetDataRowByIndex(RowIndex);
  if Assigned(DataRow) then
  begin
    j := self.GetIndexOfDataColumnByName(ColumnName);
    if (j >= 0) then
    begin
      DataCell := DataRow.DataCellList[j];
      sval := DataCell.sval;
      Result := True;
    end;
  end;
end;

{procedure TDataTableOfCosa.WriteDataCellTextValue(RowName, ColumnName, value:string);
var
  i, j: integer;
  DataRow: TDataRowOfCosa;
  DataCell: TDataCellOfCosa;
begin
  DataRow:=self.GetDataRowByName(RowName);
  j:=self.GetIndexOfDataColumnByName(ColumnName);
  DataCell := DataRow.DataCellList[j];
  DataCell.sval:=value;
end;}

function TDataTableOfCosa.AddDataRow(xDataRow: TDataRowOfCosa;
  SetRowId: boolean): integer;
begin
  Result := -1;
  if xDataRow <> nil then
  begin
    if (SetRowId) then
    begin
      _DATAROWID_COUNTER := _DATAROWID_COUNTER + 1;
      xDataRow._RowId := _DATAROWID_COUNTER;
    end
    else
    begin
      if (not (self is TDataVTableOfCosa)) and
        Assigned(self.GetDataRowById(xDataRow._RowId)) then
        raise Exception.Create('TDataTableOfCosa.AddDataRow: RowId ' +
          IntToStr(xDataRow._RowId) + ' ya existe en la tabla ' + TableName);
    end;
    xDataRow.DataTableOwner := self;
    self._DataRowList.Add(xDataRow);
    Result := _DATAROWID_COUNTER;
  end;
end;

function TDataTableOfCosa.ConvertDataRowToNewestVersion(var NewDataRow: TDataRowOfCosa;
  DataTableAux: TDataTableOfCosa): boolean;
var
  DataConversion: TDataConversion;
  CellsInput: TDAofString;
  CellsOutput: TDAofString;

  ACosa: TCosa;
  CellOutputs: TDAofString;
  OldDataColumnList: TDataColumnListOfCosa;
  NewDataColumnList: TDataColumnListOfCosa;
  i: integer;
  OldDataRow: TDataRowOfCosa;
  sval: string;
  NewDataColumn: TDataColumnOfCosa;
  Index: integer;
  DataCell: TDataCellOfCosa;
  q: integer;
  w: integer;
  b: string;
  ColIndex: integer;
  ColumnsInput: TDAofString;
  a: integer;

begin

  NewDataColumnList := self.GetDataColumnList();
  OldDataColumnList := DataTableAux.GetDataColumnList();

  OldDataRow := DataTableAux.DataRowList[0];

  for i := 0 to NewDataColumnList.Count - 1 do
  begin
    NewDataColumn := NewDataColumnList.Items[i];

    if LowerCase(NewDataColumn.ColumnName) = LowerCase('iniHorizonte') then
      a := 1;

    Index := DataTableAux.GetIndexOfDataColumnByName(NewDataColumn.ColumnName);

    if Index > -1 then
      DataCell := DataTableAux.DataRowList[0].DataCellList[Index].Clone()
    else
      DataCell := TDataCellOfCosa.Create(NewDataColumn.ValorPorDefecto);

    NewDataRow.AddDataCell(DataCell);

  end;

  for q := 0 to self.DataConversionListCount - 1 do
  begin
    DataConversion := self.DataConversionList[q];

    if DataConversion.Version > OldDataColumnList.Version then
    begin

      ColumnsInput := DataConversion.ColumnsInput;

      SetLength(CellsInput, Length(DataConversion.ColumnsInput));
      for w := Low(DataConversion.ColumnsInput) to High(DataConversion.ColumnsInput) do
      begin

        if DataConversion is TDataConversionMultiTable then
          a := 1;

        b := DataConversion.ColumnsInput[w];
        ColIndex := DataTableAux.GetIndexOfDataColumnByName(
          DataConversion.ColumnsInput[w]);
        if ColIndex > -1 then
        begin
          CellsInput[w] := OldDataRow.DataCellList[ColIndex].sval;
          b := CellsInput[w];
        end;
      end;

      CellOutputs := DataConversion.Convert(CellsInput);

      for w := Low(DataConversion.ColumnsOutput) to High(DataConversion.ColumnsOutput) do
        NewDataRow.DataCellList[self.GetIndexOfDataColumnByName(
          DataConversion.ColumnsOutput[w])].sval := CellOutputs[w];

    end;
  end;

end;


function TDataTableOfCosa.GetDataRowWithDefaulValues: TDataRowOfCosa;
var
  dr: TDataRowOfCosa;
  i: integer;
begin

  dr := TDataRowOfCosa.Create;
  for i := 0 to DataColumnListCount - 1 do
    dr.AddDataCell(TDataCellOfCosa.Create(DataColumnList[i].ValorPorDefecto));

  Result := dr;
end;

function TDataTableOfCosa.Equals(dt: TDataTableOfCosa): boolean;
begin
  if Assigned(dt) and self.GetDataColumnList.Equals(dt.GetDataColumnList) then
    Result := True
  else
    Result := False;
end;

procedure TDataTableOfCosa.Merge(Beta_DataTable: TDataTableOfCosa);
var
  RowListCount: integer;
  Alfa_DataRow, Beta_DataRow: TDataRowOfCosa;
  i, j: integer;
begin
  if Assigned(Beta_DataTable) and self.Equals(Beta_DataTable) and
    (Beta_DataTable.DataRowListCount > 0) then
  begin
    RowListCount := Beta_DataTable.DataRowListCount;
    for i := 0 to Beta_DataTable.DataRowListCount - 1 do
    begin
      Beta_DataRow := Beta_DataTable.DataRowList[i];
      case Beta_DataRow.SIUD of
        TSIUD.TSELECT:
        begin
          Alfa_DataRow := self.GetDataRowById(Beta_DataRow._RowId);
          if Assigned(Alfa_DataRow) then
          begin
            if not Alfa_DataRow.Equals(Beta_DataRow) then
              raise Exception.Create(
                'TDataTableOfCosa.Merge: DataRows en modo select son distintos');
          end
          else
            self.AddDataRow(Beta_DataRow.Clone(True), False);
        end;
        TSIUD.TINSERT:
        begin
          self.AddDataRow(Beta_DataRow.Clone(True), False);
        end;
        TSIUD.TUPDATE:
        begin
          Alfa_DataRow := GetDataRowById(Beta_DataRow._RowId);
          if Assigned(Alfa_DataRow) then
          begin
            Alfa_DataRow.SIUD := TSIUD.TUPDATE;
            Alfa_DataRow.Merge(Beta_DataRow);
          end
          else
          begin
            self.AddDataRow(Beta_DataRow.Clone(True), False);
            //raise Exception.Create(' TDataTableOfCosa.Merge TSIUD.UPDATE NO DEBERIA PASAR POR ACA');
          end;
        end;
        TSIUD.TDELETE:
        begin
          Alfa_DataRow := GetDataRowById(Beta_DataRow._RowId);
          if Assigned(Alfa_DataRow) then
          begin
            Alfa_DataRow.SIUD := TSIUD.TDELETE;
          end;
        end;
      end;
    end;
  end;
end;

procedure TDataTableOfCosa.Free;
var
  i, j: integer;
begin
  if Assigned(self._DataColumnList) then
  begin
    for i := 0 to self._DataColumnList.Count - 1 do
      TDataColumnOfCosa(self._DataColumnList.Items[i]).Free;
    self._DataColumnList.Free;
  end;

  if Assigned(self._DataConversionList) then
    self._DataConversionList.Free;

  if Assigned(self._DataRowList) then
  begin
    for j := 0 to self._DataRowList.Count - 1 do
      TDataRowOfCosa(self._DataRowList.Items[j]).Free;
    self._DataRowList.Free();
  end;
end;

procedure TDataTableOfCosa.Clear;
var
  j: integer;
begin
  self._DATAROWID_COUNTER := 1000;
  if Assigned(self._DataRowList) then
  begin
    for j := 0 to self._DataRowList.Count - 1 do
      self.DataRowList[j].Free();
    self._DataRowList.Clear();
  end;

end;

function TDataTableOfCosa.GetColValues(kCol: integer): TStringList;
var
  res: TStringList;
  dcll: TDataCellOfCosa;
  i: integer;
begin

  if (kCol < 0) or (kCol > self.DataColumnListCount) then
    raise Exception.Create(
      'TDataTableOfCosa.GetColValues : La columna a evaluar no pertenece a tabla ' +
      self.TableName);

  res := TStringList.Create;

  for i := 0 to self.DataRowListCount - 1 do
  begin
    try
      dcll := self.DataRowList[i].DataCellList[kCol];
    except
      raise Exception.Create(
        'TDataTableOfCosa.GetColValues : DimError: Length(fila)<kCol');
    end;
    res.Add(dcll.sval);
  end;

  Result := res;
end;

function TDataTableOfCosa.GetColValues(ColName: string): TStringList;
var
  kCol: integer;
begin
  kCol := self.GetIndexOfDataColumnByName(ColName);
  Result := self.GetColValues(kCol);
end;

procedure TDataTableOfCosa.AppendDataTable(dt: TDataTableOfCosa; reAssignIds: boolean);
var
  i: integer;
begin
  if not Assigned(dt) then
    Exit;

  if not self.Equals(dt) then
    raise Exception.Create(
      'TDataTableOfCosa.AppendDataTable: las tablas no tienen igual definicion de columnas');

  for i := 0 to dt.DataRowListCount - 1 do
    self.AddDataRow(dt.DataRowList[i].Clone(not reAssignIds), reAssignIds);

end;

function TDataTableOfCosa.Query(Select: string; ColumnNameToEval: string;
  Value: string): TDataTableOfCosa;
var
  dt: TDataTableOfCosa;
  ColumnNames: TStringList;
  SelectAster: boolean;
  kCol: integer;
  ColValues: TStringList;
  evalValue: boolean;
  kEvalCol: integer;
  EvalColValues: TStringList;
  i, j: integer;
  kRow: integer;

begin

  ColumnNames := TStringList.Create;
  ColumnNames.DelimitedText := Select;

  kEvalCol := self.GetIndexOfDataColumnByName(ColumnNameToEval);
  if (kEvalCol = -1) and (ColumnNameToEval <> '') then
    raise Exception.Create(
      'TDataTableOfCosa.Query : La columna a evaluar no pertenece a tabla ' +
      self.TableName);

  // Si ColumnNames tiene un '*' entre sus items devuelte una tabla con todas
  // las columnas
  SelectAster := ColumnNames.IndexOf('*') > -1;
  //Si ColumnNameToEval es vacio, se devuelven todas las filas de la tabla
  evalValue := ColumnNameToEval <> '';

  if SelectAster then
  begin
    dt := self.Clone(True, False);
    //reocrrido de las filas
    for i := 0 to self.DataRowListCount - 1 do
    begin
      if evalValue then
        dt.AddDataRow(self.DataRowList[i].ConditionalClone(kEvalCol, Value), False)
      else
        dt.AddDataRow(self.DataRowList[i].Clone(True), False);
    end;
  end
  else
  begin
    dt := TDataTableOfCosa.Create(self.TableName);
    for i := 0 to ColumnNames.Count - 1 do
    begin
      kCol := self.GetIndexOfDataColumnByName(ColumnNames[i]);
      ;
      if kCol = -1 then
        raise Exception.Create(
          'TDataTableOfCosa.Query : La columna "' + ColumnNames[i] +
          '" no pertenece a tabla ' + self.TableName);

      dt.AddDataColumn(self.GetDataColumnByIndex(kCol).Clone());
      ColValues := self.GetColValues(kCol);
      EvalColValues := self.GetColValues(kEvalCol);
      kRow := 0;
      for j := 0 to ColValues.Count - 1 do
      begin
        if EvalColValues[j] = Value then
        begin
          if i = 0 then
            dt.AddDataRow(TDataRowOfCosa.Create(dt));

          dt.DataRowList[kRow].AddDataCell(TDataCellOfCosa.Create(ColValues[j]));
          kRow := kRow + 1;
        end;
      end;
    end;
  end;

  ColumnNames.Free;
  Result := dt;
end;

function TDataTableOfCosa.Query(Select: string; rowId: integer): TDataTableOfCosa;
var
  dt: TDataTableOfCosa;
  ColumnNames: TStringList;
  SelectAster: boolean;
  kCol: integer;
  i, j: integer;
  kRow: integer;
  dr1, dr2: TDataRowOfCosa;

begin

  ColumnNames := TStringList.Create;
  ColumnNames.DelimitedText := Select;

  // Si ColumnNames tiene un '*' entre sus items devuelte una tabla con todas
  // las columnas
  SelectAster := ColumnNames.IndexOf('*') > -1;
  dr1 := self.GetDataRowById(rowId);

  if SelectAster then
  begin
    dt := self.Clone(True, False);
    if Assigned(dr1) then
      dt.AddDataRow(dr1.Clone(), False);
  end
  else
  begin
    dt := TDataTableOfCosa.Create(self.TableName);
    dr2 := TDataRowOfCosa.Create(dt);
    for i := 0 to ColumnNames.Count - 1 do
    begin
      kCol := self.GetIndexOfDataColumnByName(ColumnNames[i]);
      ;
      if kCol = -1 then
        raise Exception.Create(
          'TDataTableOfCosa.Query : La columna "' + ColumnNames[i] +
          '" no pertenece a tabla ' + self.TableName);
      dt.AddDataColumn(self.GetDataColumnByIndex(kCol).Clone());
      if Assigned(dr1) then
        dr2.AddDataCell(TDataCellOfCosa.Create(dr1.GetDataCellByIndex(kCol).sval));
    end;
    dt.AddDataRow(dr2, False);
  end;
  ColumnNames.Free;
  Result := dt;
end;

function TDataTableOfCosa.View(ColNames: string): TDataTableOfCosa;
var
  dt: TDataTableOfCosa;
  ColumnNames: TStringList;
  i, j, kCol: integer;
  vdr: TDataVRowOfCosa;
begin
  dt := TDataTableOfCosa.Create(self.TableName + '_view');
  ColumnNames := TStringList.Create;
  ColumnNames.DelimitedText := ColNames;

  for i := 0 to ColumnNames.Count - 1 do
  begin
    kCol := Self.GetIndexOfDataColumnByName(ColumnNames[i]);
    dt.AddDataColumn(TDataColumnOfCosa.Create(ColumnNames[i], nil));
    for j := 0 to self.DataRowListCount - 1 do
    begin
      if i = 0 then
      begin
        vdr := TDataVRowOfCosa.Create(dt);
        vdr.OriginalDataTableName := self.TableName;
        vdr.OriginalDataRowId := self.DataRowList[j]._RowId;
        dt.AddDataRow(vdr, True);
      end;

      if kCol > -1 then
        dt.DataRowList[j].AddDataCell(TDataCellOfCosa.Create(
          self.DataRowList[j].GetDataCellByIndex(kCol).sval))
      else
        dt.DataRowList[j].AddDataCell(TDataCellOfCosa.Create('-'));
    end;
  end;
  Result := dt;
end;


{ TDataVTableOfCosa }

function TDataVTableOfCosa.GetChildClassNameList: TStringList;
begin
  Result := self._ChildClassNameList;
end;

constructor TDataVTableOfCosa.Create(xDataTableName: string);
begin
  inherited Create(xDataTableName);
  self._ChildClassNameList := TStringList.Create;
end;

constructor TDataVTableOfCosa.Create(xDataTableName: string;
  xDataColumnList: TDataColumnListOfCosa);
begin
  inherited Create(xDataTableName);
  self._ChildClassNameList := TStringList.Create;
  self._DataColumnList := xDataColumnList;
end;

constructor TDataVTableOfCosa.Create(xDataTableName: string;
  xClassNameList: TStringList; xDataColumnList: TDataColumnListOfCosa);
begin
  inherited Create(xDataTableName);
  self._ChildClassNameList := xClassNameList;
  self._DataColumnList := xDataColumnList;
end;

function TDataVTableOfCosa.AddChildClassName(AClassName: string): integer;
var
  index: integer;
begin
  if self._ChildClassNameList.Find(AClassName, index) then
    Result := index
  else
    Result := self._ChildClassNameList.Add(AClassName);
end;

function TDataVTableOfCosa.GetDataRowList(ds: TDataStore): TList;
var
  z, i, j: integer;
  AClassName: string;
  DataTable: TDataTableOfCosa;
  DataRow: TDataRowOfCosa;

  TheDataRowList: TList;
  ADataRow: TDataVRowOfCosa;
  ADataColumn: TDataColumnOfCosa;
  DataColumnIndex: integer;
  ADataCell: TDataCellOfCosa;
  a: integer;
begin

  TheDataRowList := TList.Create;
  for z := 0 to self._ChildClassNameList.Count - 1 do
  begin
    AClassName := self._ChildClassNameList[z];
    DataTable := nil;
    ds.GetDataTableOnLastVersion('dt_' + AClassName, DataTable);
    if (DataTable <> nil) then
    begin
      for i := 0 to DataTable.DataRowListCount - 1 do
      begin
        DataRow := DataTable.DataRowList[i];
        if DataRow.SIUD <> TSIUD.TDELETE then
        begin
          ADataRow := TDataVRowOfCosa.Create(self, 'dr_' + AClassName);
          for j := 0 to self._DataColumnList.Count - 1 do
          begin
            ADataColumn := self._DataColumnList[j];
            DataColumnIndex := DataTable.GetDataColumnList().GetIndexOfDataColumnByName(
              ADataColumn.ColumnName);
            ADataCell := DataRow.GetDataCellByIndex(DataColumnIndex).Clone();
            ADataRow.AddDataCell(ADataCell);
          end;
          ADataRow.OriginalDataTableName := DataTable.TableName;
          ADataRow.OriginalDataRowId := DataRow._RowId;
          TheDataRowList.Add(ADataRow);
        end
        else
          a := 1;
      end;
    end;
  end;
  Result := TheDataRowList;
end;

constructor TDataTableOfListOfCosa.Create;
begin
  self.Visible := False;
  self.TableName := 'dt_TList';
  self._LastIdParent := 0;
  self._DATAROWID_COUNTER := 1000;

  self._DataColumnList := TDataColumnListOfCosa.Create(nil);
  self._DataColumnList.AddStringColumn('IdParent', '');
  self._DataColumnList.AddStringColumn('IdChild', '');

  self._DataRowList := TList.Create;
end;

function TDataTableOfListOfCosa.GetNextIdParent: integer;
begin
  self._LastIdParent := self._LastIdParent + 1;
  Result := self._LastIdParent;
end;

function TDataTableOfListOfCosa.Clone(CloneRowIdCounter: boolean;
  CloneRowList: boolean): TDataTableOfListOfCosa;
var
  dt: TDataTableOfListOfCosa;
begin
  dt := TDataTableOfListOfCosa(inherited Clone(CloneRowIdCounter, CloneRowList));
  dt._LastIdParent := self._LastIdParent;

  Result := dt;
end;

procedure TDataTableOfListOfCosa.Free;
begin
  inherited;
end;

procedure TDataTableOfListOfCosa.Clear;
begin
  inherited;
  _LastIdParent := 0;
end;

//////////////////////////////////////////////////////////////////////////////
//TDataRowOfCosa
//////////////////////////////////////////////////////////////////////////////
constructor TDataRowOfCosa.Create(xRowName: string);
begin
  inherited Create;
  self.RowName := xRowName;
  self._DataCellList := TList.Create;
  self.DataTableOwner := nil;
  self.SIUD := TSIUD.TINSERT;
end;

constructor TDataRowOfCosa.Create(xRowId: integer);
begin
  inherited Create;
  self._DataCellList := TList.Create();
  self._RowId := xRowId;
end;

constructor TDataRowOfCosa.Create(xDataTableOwner: TDataTableOfCosa; xRowName: string);
begin
  inherited Create;
  self.RowName := xRowName;
  self._DataCellList := TList.Create;
  self.DataTableOwner := xDataTableOwner;
  self.SIUD := TSIUD.TINSERT;
end;

function TDataRowOfCosa.AddDataCell(xDataCell: TDataCellOfCosa;
  SetOwner: boolean): integer;
begin
  if Assigned(xDataCell) and SetOwner then
    xDataCell.DataRowOwner := self;
  Result := self._DataCellList.Add(xDataCell);
end;

procedure TDataRowOfCosa.InsertDataCell(ADataCell: TDataCellOfCosa; AIndex: integer);
begin
  self._DataCellList.Insert(AIndex, ADataCell);
end;

function TDataRowOfCosa.Clone(CloneRowId: boolean): TDataRowOfCosa;
var
  dr: TDataRowOfCosa;
  i: integer;
begin
  if self is TDataVRowOfCosa then
  begin
    dr := TDataVRowOfCosa.Create(self.DataTableOwner, self.RowName);
    TDataVRowOfCosa(dr).OriginalDataTableName :=
      TDataVRowOfCosa(self).OriginalDataTableName;
    TDataVRowOfCosa(dr).OriginalDataRowId := TDataVRowOfCosa(self).OriginalDataRowId;
  end
  else
    dr := TDataRowOfCosa.Create(self.DataTableOwner, self.RowName);

  for i := 0 to self.DataCellListCount - 1 do
    dr.AddDataCell(self.DataCellList[i].Clone());
  if CloneRowId then
    dr._RowId := self._RowId;
  dr.SIUD := self.SIUD;
  Result := dr;
end;

function TDataRowOfCosa.ConditionalClone(i: integer; Value: string): TDataRowOfCosa;
begin
  Result := nil;
  if (i <> -1) and (Value <> '') and (self.DataCellList[i].sval = Value) then
    Result := self.Clone;
end;

function TDataRowOfCosa.ConditionalGetDataCell(kCell, kCellToEval: integer;
  Value: string): TDataCellOfCosa;
begin
  // kCellToEval=-1 Parche TODO: Corregir!!
  if (kCellToEval = -1) or (DataCellList[kCellToEval].sval = Value) then
    Result := DataCellList[kCell]
  else
    Result := nil;
end;

function TDataRowOfCosa.Equals(dr: TDataRowOfCosa): boolean;
var
  i: integer;
  c1: integer;
begin
  Result := True;
  c1 := self.DataCellListCount;

  if not (Assigned(dr) and (c1 <> 0) and (c1 = dr.DataCellListCount)) then
    Result := False
  else
    for i := 0 to c1 - 1 do
      if not self.DataCellList[i].Equals(dr.DataCellList[i]) then
      begin
        Result := False;
        Break;
      end;
end;

procedure TDataRowOfCosa.Merge(ADataRow: TDataRowOfCosa);
var
  i: integer;
begin
  for i := 0 to ADataRow.DataCellListCount - 1 do
    self.DataCellList[i].sval := ADataRow.DataCellList[i].sval;

end;

function TDataRowOfCosa.CompareTo(Beta_DataRow: TDataRowOfCosa;
  Gamma_DataTable: TDataTableOfCosa): boolean;
var
  ok: boolean;
  Gamma_DataRow: TDataRowOfCosa;
  split: TStringList;
  dtn: string;
  dri: integer;
  dcn: string;
  dcv: string;
  ds: TDataStore;
  dt: TDataTableOfCosa;
  dc: TDataColumnOfCosa;
  j: integer;
  dco: TDataColumnOfCosa;
  dr: TDataRowOfCosa;
  dce: TDataCellOfCosa;
  dt_TList: TDataTableOfCosa;
  sval: string;
  i: integer;
  Gamma_DataCell: TDataCellOfCosa;
begin

end;

procedure TDataRowOfCosa.Free;
var
  i: integer;
begin
  DataTableOwner := nil;
  for i := 0 to DataCellListCount - 1 do
    if Assigned(DataCellList[i]) then
      DataCellList[i].Free;

  _DataCellList.Free;
end;

function TDataRowOfCosa.ToString: TStrings;
var
  strs: TStringList;
  i: integer;
begin
  strs := TStringList.Create;
  for i := 0 to DataCellListCount - 1 do
    strs.Add(DataCellList[i].sval);

  Result := strs;
end;

function TDataRowOfCosa.GetRowId: integer;
begin
  Result := self.RowId;
end;

procedure TDataRowOfCosa.SetRowId(AValue: integer);
begin
  self.RowId := AValue;
end;

function TDataRowOfCosa.GetDataCellByIndex(Index: integer): TDataCellOfCosa;
begin
  Result := self._DataCellList.Items[Index];
end;

function TDataRowOfCosa.GetDataCellListCount: integer;
begin
  Result := self._DataCellList.Count;
end;

function TDataRowOfCosa.GetLastDataCell: TDataCellOfCosa;
begin
  Result := self._DataCellList.Items[self.DataCellListCount - 1];
end;

function TDataCellOfCosa.getVal: string;
begin
  Result := _sval;
end;

procedure TDataCellOfCosa.setVal(AValue: string);
begin
  self._sval := AValue;
  if Assigned(self.DataRowOwner) and (self.DataRowOwner.SIUD = TSELECT) then
    self.DataRowOwner.SIUD := TUPDATE;
end;

//////////////////////////////////////////////////////////////////////////////
//TDataCellOfCosa
//////////////////////////////////////////////////////////////////////////////
constructor TDataCellOfCosa.Create(xsval: string);
begin
  SIUD := TSIUD.TSELECT;
  self.sval := xsVal;
end;

function TDataCellOfCosa.Clone: TDataCellOfCosa;
var
  dce: TDataCellOfCosa;
  asval: string;
begin
  asval := self.sval;
  Result := TDataCellOfCosa.Create(self.sval);
end;

function TDataCellOfCosa.Equals(dcll: TDataCellOfCosa): boolean;
begin
  if Assigned(dcll) then
    Result := self.sval = dcll.sval
  else
    Result := False;
end;

procedure TDataCellOfCosa.Free;
begin
  sval := '';
  if Assigned(pval) then
    Dispose(pval);
  DataRowOwner := nil;
end;

procedure TDataColumnListOfCosa.SetClassOwner(AValue: TClaseDeCosa);
begin
  self._ClassOwner := AValue;
end;

procedure TDataColumnListOfCosa.SetItemListClaseDeCosa(AValue: TClaseDeCosa);
begin
  self._ItemListClaseDeCosa := AValue;
end;

{ TDataColumnListOfCosa }
function TDataColumnListOfCosa.GetItem(Index: integer): TDataColumnOfCosa;
begin
  Result := TDataColumnOfCosa(inherited Items[Index]);
end;

constructor TDataColumnListOfCosa.Create(xClassOwner: TClaseDeCosa; xVersion: integer);
var
  b: string;
begin
  self.Create(xClassOwner, nil, xVersion);
end;

constructor TDataColumnListOfCosa.Create(xClassOwner: TClaseDeCosa;
  xItemListClaseDeCosa: TClaseDeCosa; xVersion: integer);
begin
  inherited Create;
  self._ItemListClaseDeCosa := xItemListClaseDeCosa;
  self._ClassOwner := xClassOwner;
  self._Version := xVersion;
  self.ValidationList := TListValidation.Create();
end;

function TDataColumnListOfCosa.AddDataColumn(xDataColumn: TDataColumnOfCosa;
  SetOwner: boolean): integer;
begin

end;

 
function TDataColumnListOfCosa.AddDataColumn(xColumnName: string;
  xDataType: DataTypeOfCosa): integer;
begin

end;

function TDataColumnListOfCosa.AddDataColumn(xColumnName: string;
  var xField; xDataType: DataTypeOfCosa; xValorPorDefecto: string;
  xVersionAlta, xVersionBaja: integer; xClaseDeCosa: TClaseDeCosa): integer;
begin

end;

function TDataColumnListOfCosa.AddDataColumn(xColumnName: string;
  xLabelCaption: string; var xField; xDataType: DataTypeOfCosa;
  xValorPorDefecto: string; xVersionAlta: integer; xVersionBaja: integer;
  xClaseDeCosa: TClaseDeCosa): integer;
begin

end;

function TDataColumnListOfCosa.AddDataColumn(xColumnName: string;
  var xField; xDataType: DataTypeOfCosa; xVersionAlta: integer;
  xVersionBaja: integer; xClaseDeCosa: TClaseDeCosa): integer;
begin

end;

function TDataColumnListOfCosa.AddDataColumn(xColumnName: string;
  xDataType: DataTypeOfCosa; xOptions: array of string; xVersionAlta: integer;
  xVersionBaja: integer; xClaseDeCosa: TClaseDeCosa): integer;
begin

end;

function TDataColumnListOfCosa.AddDataColumn(xColumnName: string;
  var xField; xDataType: DataTypeOfCosa; xOptions: array of string;
  xVersionAlta: integer; xVersionBaja: integer; xClaseDeCosa: TClaseDeCosa): integer;
begin

end;



function TDataColumnListOfCosa.AddBooleanColumn(AColumnName: string;
  ADefaultValue: boolean;
  AVersionAlta: integer;
  AVersionBaja: integer): integer;
begin
  Result := self.AddDataColumn(AColumnName, nil,
    '', BoolToStr(
    ADefaultValue, 'True', 'False'), [],
    AVersionAlta, AVersionBaja);
end;

function TDataColumnListOfCosa.AddBooleanColumn(AColumnName: string;
  ADefaultValue: boolean;
  AConstraints: TColumnConstraints;
  AVersionAlta: integer;
  AVersionBaja: integer): integer;
begin
  Result := self.AddDataColumn(AColumnName, nil,
    '', BoolToStr(
    ADefaultValue, 'True', 'False'), AConstraints,
    AVersionAlta, AVersionBaja);
end;

function TDataColumnListOfCosa.AddBooleanColumn(AColumnName: string;
  ALabel: string;
  ADefaultValue: boolean;
  AVersionAlta: integer;
  AVersionBaja: integer): integer;
begin
  Result := self.AddDataColumn(AColumnName, nil, ALabel,
    BoolToStr(ADefaultValue, 'True', 'False'), [], AVersionAlta, AVersionBaja);
end;

function TDataColumnListOfCosa.AddBooleanColumn(AColumnName: string;
  ALabel: string; ADefaultValue: boolean; AConstraints: TColumnConstraints;
  AVersionAlta: integer; AVersionBaja: integer): integer;
begin
  Result := self.AddDataColumn(AColumnName, nil, ALabel,
    BoolToStr(ADefaultValue, 'True', 'False'), AConstraints, AVersionAlta, AVersionBaja);
end;

function TDataColumnListOfCosa.AddIntegerColumn(AColumnName: string;
  ADefaultValue: integer; AVersionAlta: integer; AVersionBaja: integer): integer;
begin
  Result := self.AddDataColumn(AColumnName, nil, '', IntToStr(ADefaultValue),
    [], AVersionAlta, AVersionBaja);
end;

function TDataColumnListOfCosa.AddIntegerColumn(AColumnName: string;
  ADefaultValue: integer;
  AConstraints: TColumnConstraints;
  AVersionAlta: integer;
  AVersionBaja: integer): integer;
begin
  Result := self.AddDataColumn(AColumnName, nil, '', IntToStr(ADefaultValue),
    AConstraints, AVersionAlta, AVersionBaja);
end;

function TDataColumnListOfCosa.AddIntegerColumn(AColumnName: string;
  ALabel: string;
  ADefaultValue: integer;
  AVersionAlta: integer;
  AVersionBaja: integer): integer;
begin
  Result := self.AddDataColumn(AColumnName, nil, ALabel, IntToStr(ADefaultValue),
    [], AVersionAlta, AVersionBaja);
end;

function TDataColumnListOfCosa.AddIntegerColumn(AColumnName: string;
  ALabel: string;
  ADefaultValue: integer;
  AConstraints: TColumnConstraints;
  AVersionAlta: integer;
  AVersionBaja: integer): integer;
begin
  Result := self.AddDataColumn(AColumnName, nil, ALabel, IntToStr(ADefaultValue),
    AConstraints, AVersionAlta, AVersionBaja);
end;

function TDataColumnListOfCosa.AddCardinalColumn(AColumnName: string;
  ADefaultValue: cardinal; AVersionAlta: integer; AVersionBaja: integer): integer;
begin
  Result := self.AddDataColumn(AColumnName, nil, '', IntToStr(ADefaultValue),
    [], AVersionAlta, AVersionBaja);
end;

function TDataColumnListOfCosa.AddCardinalColumn(AColumnName: string;
  ADefaultValue: cardinal; AConstraints: TColumnConstraints;
  AVersionAlta: integer; AVersionBaja: integer): integer;
begin
  Result := self.AddDataColumn(AColumnName, nil, '', IntToStr(ADefaultValue),
    AConstraints, AVersionAlta, AVersionBaja);
end;

function TDataColumnListOfCosa.AddCardinalColumn(AColumnName: string;
  ALabel: string; ADefaultValue: cardinal; AVersionAlta: integer;
  AVersionBaja: integer): integer;
begin
  Result := self.AddDataColumn(AColumnName, nil, ALabel, IntToStr(ADefaultValue),
    [], AVersionAlta, AVersionBaja);
end;

function TDataColumnListOfCosa.AddCardinalColumn(AColumnName: string;
  ALabel: string; ADefaultValue: cardinal; AConstraints: TColumnConstraints;
  AVersionAlta: integer; AVersionBaja: integer): integer;
begin
  Result := self.AddDataColumn(AColumnName, nil, ALabel, IntToStr(ADefaultValue),
    AConstraints, AVersionAlta, AVersionBaja);
end;

function TDataColumnListOfCosa.AddDoubleColumn(AColumnName: string;
  ADefaultValue: double;
  AVersionAlta: integer;
  AVersionBaja: integer): integer;
begin
  Result := self.AddDataColumn(AColumnName, nil, '', FloatToStr(ADefaultValue),
    [], AVersionAlta, AVersionBaja);
end;

function TDataColumnListOfCosa.AddDoubleColumn(AColumnName: string;
  ADefaultValue: double; AConstraints: TColumnConstraints; AVersionAlta: integer;
  AVersionBaja: integer): integer;
begin
  Result := self.AddDataColumn(AColumnName, nil, '', FloatToStr(ADefaultValue),
    AConstraints, AVersionAlta, AVersionBaja);
end;

function TDataColumnListOfCosa.AddDoubleColumn(AColumnName: string;
  ALabel: string; ADefaultValue: double; AVersionAlta: integer;
  AVersionBaja: integer): integer;
begin
  Result := self.AddDataColumn(AColumnName, nil, ALabel, FloatToStr(ADefaultValue),
    [], AVersionAlta, AVersionBaja);
end;

function TDataColumnListOfCosa.AddDoubleColumn(AColumnName: string;
  ALabel: string;
  ADefaultValue: double;
  AConstraints: TColumnConstraints;
  AVersionAlta: integer;
  AVersionBaja: integer): integer;
begin
  Result := self.AddDataColumn(AColumnName, nil, ALabel, FloatToStr(ADefaultValue),
    AConstraints, AVersionAlta, AVersionBaja);
end;

function TDataColumnListOfCosa.AddStringColumn(AColumnName: string;
  ADefaultValue: string; AVersionAlta: integer; AVersionBaja: integer): integer;
begin
  Result := self.AddDataColumn(AColumnName, nil, '', ADefaultValue, [],
    AVersionAlta, AVersionBaja);
end;

function TDataColumnListOfCosa.AddStringColumn(AColumnName: string;
  ADefaultValue: string; AConstraints: TColumnConstraints; AVersionAlta: integer;
  AVersionBaja: integer): integer;
begin
  Result := self.AddDataColumn(AColumnName, nil, '', ADefaultValue,
    AConstraints, AVersionAlta, AVersionBaja);
end;

function TDataColumnListOfCosa.AddStringColumn(AColumnName: string;
  ALabel: string; ADefaultValue: string; AVersionAlta: integer;
  AVersionBaja: integer): integer;
begin
  Result := self.AddDataColumn(AColumnName, nil, ALabel, ADefaultValue,
    [], AVersionAlta, AVersionBaja);
end;

function TDataColumnListOfCosa.AddStringColumn(AColumnName: string;
  ALabel: string; ADefaultValue: string; AConstraints: TColumnConstraints;
  AVersionAlta: integer; AVersionBaja: integer): integer;
begin
  Result := self.AddDataColumn(AColumnName, nil, ALabel, ADefaultValue,
    AConstraints, AVersionAlta, AVersionBaja);
end;

function TDataColumnListOfCosa.AddDAOfBooleanColumn(AColumnName: string;
  AVersionAlta: integer;
  AVersionBaja: integer): integer;
begin
  Result := Self.AddDataColumn(AColumnName, nil, '', '', [], AVersionAlta, AVersionBaja);
end;

function TDataColumnListOfCosa.AddDAOfBooleanColumn(AColumnName: string;
  AConstraints: TColumnConstraints;
  AVersionAlta: integer;
  AVersionBaja: integer): integer;
begin
  Result := Self.AddDataColumn(AColumnName, nil, '', '', AConstraints,
    AVersionAlta, AVersionBaja);
end;

function TDataColumnListOfCosa.AddDAOfBooleanColumn(AColumnName: string;
  ALabel: string;
  AVersionAlta: integer;
  AVersionBaja: integer): integer;
begin
  Result := Self.AddDataColumn(AColumnName, nil, ALabel, '', [],
    AVersionAlta, AVersionBaja);
end;

function TDataColumnListOfCosa.AddDAOfBooleanColumn(AColumnName: string;
  ALabel: string;
  AConstraints: TColumnConstraints;
  AVersionAlta: integer;
  AVersionBaja: integer): integer;
begin
  Result := Self.AddDataColumn(AColumnName, nil, ALabel, '', AConstraints,
    AVersionAlta, AVersionBaja);
end;

function TDataColumnListOfCosa.AddDAOfBooleanColumn(AColumnName: string;
  ADefaultValue: array of boolean;
  AVersionAlta: integer;
  AVersionBaja: integer): integer;
begin
  Result := Self.AddDataColumn(AColumnName, nil, '',
    TDAOfBooleanToString(ADefaultValue, ', ', True, '|'), [], AVersionAlta, AVersionBaja);
end;

function TDataColumnListOfCosa.AddDAOfBooleanColumn(AColumnName: string;
  ADefaultValue: array of boolean;
  AConstraints: TColumnConstraints;
  AVersionAlta: integer;
  AVersionBaja: integer): integer;
begin
  Result := Self.AddDataColumn(AColumnName, nil, '',
    TDAOfBooleanToString(ADefaultValue, ', ', True, '|'), AConstraints,
    AVersionAlta, AVersionBaja);
end;

function TDataColumnListOfCosa.AddDAOfBooleanColumn(AColumnName: string;
  ALabel: string;
  ADefaultValue: array of boolean;
  AVersionAlta: integer;
  AVersionBaja: integer): integer;
begin
  Result := Self.AddDataColumn(AColumnName, nil, ALabel,
    TDAOfBooleanToString(ADefaultValue, ', ', True, '|'), [], AVersionAlta, AVersionBaja);
end;

function TDataColumnListOfCosa.AddDAOfBooleanColumn(AColumnName: string;
  ALabel: string;
  ADefaultValue: array of boolean;
  AConstraints: TColumnConstraints;
  AVersionAlta: integer;
  AVersionBaja: integer): integer;
begin
  Result := Self.AddDataColumn(AColumnName, nil, ALabel,
    TDAOfBooleanToString(ADefaultValue, ', ', True, '|'), AConstraints,
    AVersionAlta, AVersionBaja);
end;

function TDataColumnListOfCosa.AddDAOfIntegerColumn(AColumnName: string;
  AVersionAlta: integer; AVersionBaja: integer): integer;
begin
  Result := self.AddDataColumn(AColumnName, nil, '', '', [], AVersionAlta, AVersionBaja);
end;

function TDataColumnListOfCosa.AddDAOfIntegerColumn(AColumnName: string;
  AConstraints: TColumnConstraints; AVersionAlta: integer;
  AVersionBaja: integer): integer;
begin
  Result := self.AddDataColumn(AColumnName, nil, '', '', AConstraints,
    AVersionAlta, AVersionBaja);
end;

function TDataColumnListOfCosa.AddDAOfIntegerColumn(AColumnName: string;
  ALabel: string; AVersionAlta: integer; AVersionBaja: integer): integer;
begin
  Result := self.AddDataColumn(AColumnName, nil, ALabel, '', [],
    AVersionAlta, AVersionBaja);
end;

function TDataColumnListOfCosa.AddDAOfIntegerColumn(AColumnName: string;
  ALabel: string; AConstraints: TColumnConstraints; AVersionAlta: integer;
  AVersionBaja: integer): integer;
begin
  Result := self.AddDataColumn(AColumnName, nil, ALabel, '', AConstraints,
    AVersionAlta, AVersionBaja);
end;

function TDataColumnListOfCosa.AddDAOfIntegerColumn(AColumnName: string;
  ADefaultValue: array of integer; AVersionAlta: integer;
  AVersionBaja: integer): integer;
begin
  Result := self.AddDataColumn(AColumnName, nil, '',
    TDAOfNIntToString(ADefaultValue, ';', '|'), [], AVersionAlta, AVersionBaja);
end;

function TDataColumnListOfCosa.AddDAOfIntegerColumn(AColumnName: string;
  ADefaultValue: array of integer; AConstraints: TColumnConstraints;
  AVersionAlta: integer; AVersionBaja: integer): integer;
begin
  Result := self.AddDataColumn(AColumnName, nil, '',
    TDAOfNIntToString(ADefaultValue, ';', '|'), AConstraints, AVersionAlta, AVersionBaja);
end;

function TDataColumnListOfCosa.AddDAOfIntegerColumn(AColumnName: string;
  ALabel: string; ADefaultValue: array of integer; AVersionAlta: integer;
  AVersionBaja: integer): integer;
begin
  Result := self.AddDataColumn(AColumnName, nil, ALabel,
    TDAOfNIntToString(ADefaultValue, ';', '|'), [], AVersionAlta, AVersionBaja);
end;

function TDataColumnListOfCosa.AddDAOfIntegerColumn(AColumnName: string;
  ALabel: string; ADefaultValue: array of integer; AConstraints: TColumnConstraints;
  AVersionAlta: integer; AVersionBaja: integer): integer;
begin
  Result := self.AddDataColumn(AColumnName, nil, ALabel,
    TDAOfNIntToString(ADefaultValue, ';', '|'), AConstraints, AVersionAlta, AVersionBaja);
end;

function TDataColumnListOfCosa.AddDAOfDoubleColumn(AColumnName: string;
  AVersionAlta: integer; AVersionBaja: integer): integer;
begin
  Result := Self.AddDataColumn(AColumnName, nil, '', '', [], AVersionAlta, AVersionBaja);
end;

function TDataColumnListOfCosa.AddDAOfDoubleColumn(AColumnName: string;
  AConstraints: TColumnConstraints; AVersionAlta: integer;
  AVersionBaja: integer): integer;
begin
  Result := Self.AddDataColumn(AColumnName, nil, '', '', AConstraints,
    AVersionAlta, AVersionBaja);
end;

function TDataColumnListOfCosa.AddDAOfDoubleColumn(AColumnName: string;
  ALabel: string; AVersionAlta: integer; AVersionBaja: integer): integer;
begin
  Result := Self.AddDataColumn(AColumnName, nil, ALabel, '', [],
    AVersionAlta, AVersionBaja);
end;

function TDataColumnListOfCosa.AddDAOfDoubleColumn(AColumnName: string;
  ALabel: string; AConstraints: TColumnConstraints; AVersionAlta: integer;
  AVersionBaja: integer): integer;
begin
  Result := Self.AddDataColumn(AColumnName, nil, ALabel, '', AConstraints,
    AVersionAlta, AVersionBaja);
end;

function TDataColumnListOfCosa.AddDAOfDoubleColumn(AColumnName: string;
  ADefaultValue: array of double; AVersionAlta: integer;
  AVersionBaja: integer): integer;
begin
  Result := Self.AddDataColumn(AColumnName, nil,
    '', TDAOfNRealToString(
    ADefaultValue, CF_PRECISION, CF_DECIMALES, ', ', '|'),
    [], AVersionAlta,
    AVersionBaja);
end;

function TDataColumnListOfCosa.AddDAOfDoubleColumn(AColumnName: string;
  ADefaultValue: array of double; AConstraints: TColumnConstraints;
  AVersionAlta: integer; AVersionBaja: integer): integer;
begin
  Result := Self.AddDataColumn(AColumnName, nil,
    '', TDAOfNRealToString(
    ADefaultValue, CF_PRECISION, CF_DECIMALES, ', ', '|'),
    AConstraints, AVersionAlta,
    AVersionBaja);
end;

function TDataColumnListOfCosa.AddDAOfDoubleColumn(AColumnName: string;
  ALabel: string;
  ADefaultValue: array of double;
  AVersionAlta: integer;
  AVersionBaja: integer): integer;
begin
  Result := Self.AddDataColumn(AColumnName, nil,
    ALabel,
    TDAOfNRealToString(ADefaultValue,
    CF_PRECISION, CF_DECIMALES, ', ', '|'), [],
    AVersionAlta, AVersionBaja);
end;

function TDataColumnListOfCosa.AddDAOfDoubleColumn(AColumnName: string;
  ALabel: string;
  ADefaultValue: array of double;
  AConstraints: TColumnConstraints;
  AVersionAlta: integer;
  AVersionBaja: integer): integer;
begin
  Result := Self.AddDataColumn(AColumnName, nil,
    ALabel,
    TDAOfNRealToString(ADefaultValue,
    CF_PRECISION, CF_DECIMALES, ', ', '|'), AConstraints,
    AVersionAlta, AVersionBaja);
end;

function TDataColumnListOfCosa.AddDAOfStringColumn(AColumnName: string;
  AVersionAlta: integer; AVersionBaja: integer): integer;
begin
  Result := self.AddDataColumn(AColumnName, nil, '', '', [], AVersionAlta, AVersionBaja);
end;

function TDataColumnListOfCosa.AddDAOfStringColumn(AColumnName: string;
  AConstraints: TColumnConstraints; AVersionAlta: integer;
  AVersionBaja: integer): integer;
begin
  Result := self.AddDataColumn(AColumnName, nil, '', '', AConstraints,
    AVersionAlta, AVersionBaja);
end;

function TDataColumnListOfCosa.AddDAOfStringColumn(AColumnName: string;
  ALabel: string; AVersionAlta: integer; AVersionBaja: integer): integer;
begin
  Result := self.AddDataColumn(AColumnName, nil, ALabel, '', [],
    AVersionAlta, AVersionBaja);
end;

function TDataColumnListOfCosa.AddDAOfStringColumn(AColumnName: string;
  ALabel: string; AConstraints: TColumnConstraints; AVersionAlta: integer;
  AVersionBaja: integer): integer;
begin
  Result := self.AddDataColumn(AColumnName, nil, ALabel, '', AConstraints,
    AVersionAlta, AVersionBaja);
end;

function TDataColumnListOfCosa.AddDAOfStringColumn(AColumnName: string;
  ADefaultValue: array of string; AVersionAlta: integer;
  AVersionBaja: integer): integer;
begin
  Result := self.AddDataColumn(AColumnName, nil, '',
    TDAOfStringToString(ADefaultValue, ';', '|'), [], AVersionAlta, AVersionBaja);
end;

function TDataColumnListOfCosa.AddDAOfStringColumn(AColumnName: string;
  ADefaultValue: array of string; AConstraints: TColumnConstraints;
  AVersionAlta: integer; AVersionBaja: integer): integer;
begin
  Result := self.AddDataColumn(AColumnName, nil, '',
    TDAOfStringToString(ADefaultValue, ';', '|'), AConstraints, AVersionAlta, AVersionBaja);
end;

function TDataColumnListOfCosa.AddDAOfStringColumn(AColumnName: string;
  ALabel: string; ADefaultValue: array of string; AVersionAlta: integer;
  AVersionBaja: integer): integer;
begin
  Result := self.AddDataColumn(AColumnName, nil, ALabel,
    TDAOfStringToString(ADefaultValue, ';', '|'), [], AVersionAlta, AVersionBaja);
end;

function TDataColumnListOfCosa.AddDAOfStringColumn(AColumnName: string;
  ALabel: string; ADefaultValue: array of string; AConstraints: TColumnConstraints;
  AVersionAlta: integer; AVersionBaja: integer): integer;
begin
  Result := self.AddDataColumn(AColumnName, nil, ALabel,
    TDAOfStringToString(ADefaultValue, ';', '|'), AConstraints, AVersionAlta, AVersionBaja);
end;

function TDataColumnListOfCosa.AddStringListColumn(AColumnName: string;
  AVersionAlta: integer;
  AVersionBaja: integer): integer;
begin
  Result := Self.AddDataColumn(AColumnName, TDataTypeStringListOfCosa,
    '', '', [], AVersionAlta, AVersionBaja);
end;

function TDataColumnListOfCosa.AddStringListColumn(AColumnName: string;
  AConstraints: TColumnConstraints; AVersionAlta: integer;
  AVersionBaja: integer): integer;
begin
  Result := Self.AddDataColumn(AColumnName, TDataTypeStringListOfCosa,
    '', '', AConstraints, AVersionAlta, AVersionBaja);
end;

function TDataColumnListOfCosa.AddStringListColumn(AColumnName: string;
  ALabel: string; AVersionAlta: integer; AVersionBaja: integer): integer;
begin
  Result := Self.AddDataColumn(AColumnName, TDataTypeStringListOfCosa,
    ALabel, '', [], AVersionAlta, AVersionBaja);
end;

function TDataColumnListOfCosa.AddStringListColumn(AColumnName: string;
  ALabel: string; AConstraints: TColumnConstraints; AVersionAlta: integer;
  AVersionBaja: integer): integer;
begin
  Result := Self.AddDataColumn(AColumnName, TDataTypeStringListOfCosa,
    ALabel, '', AConstraints, AVersionAlta, AVersionBaja);
end;

function TDataColumnListOfCosa.AddDateColumn(AColumnName: string;
  ADefaultValue: TDateTime; AVersionAlta: integer; AVersionBaja: integer): integer;
begin
  Result := self.AddDataColumn(AColumnName, TDataTypeDateOfCosa, '',
    DateToStr(ADefaultValue), [], AVersionAlta, AVersionBaja);
end;

function TDataColumnListOfCosa.AddDateColumn(AColumnName: string;
  ADefaultValue: TDateTime; AConstraints: TColumnConstraints;
  AVersionAlta: integer; AVersionBaja: integer): integer;
begin
  Result := self.AddDataColumn(AColumnName, TDataTypeDateOfCosa, '',
    DateToStr(ADefaultValue), AConstraints, AVersionAlta, AVersionBaja);
end;

function TDataColumnListOfCosa.AddDateColumn(AColumnName: string;
  ALabel: string; ADefaultValue: TDateTime; AVersionAlta: integer;
  AVersionBaja: integer): integer;
begin
  Result := self.AddDataColumn(AColumnName, TDataTypeDateOfCosa, ALabel,
    DateToStr(ADefaultValue), [], AVersionAlta, AVersionBaja);
end;

function TDataColumnListOfCosa.AddDateColumn(AColumnName: string;
  ALabel: string; ADefaultValue: TDateTime; AConstraints: TColumnConstraints;
  AVersionAlta: integer; AVersionBaja: integer): integer;
begin
  Result := self.AddDataColumn(AColumnName, TDataTypeDateOfCosa, ALabel,
    DateToStr(ADefaultValue), AConstraints, AVersionAlta, AVersionBaja);
end;

function TDataColumnListOfCosa.AddFileReferenceColumn(AColumnName: string;
  AVersionAlta: integer;
  AVersionBaja: integer): integer;
begin
  Result := self.AddDataColumn(AColumnName,
    TDataTypeArchiRefOfCosa, '',
    '', [],
    AVersionAlta, AVersionBaja);
end;

function TDataColumnListOfCosa.AddFileReferenceColumn(AColumnName: string;
  AConstraints: TColumnConstraints; AVersionAlta: integer;
  AVersionBaja: integer): integer;
begin
  Result := self.AddDataColumn(AColumnName, TDataTypeArchiRefOfCosa,
    '', '', AConstraints, AVersionAlta, AVersionBaja);
end;

function TDataColumnListOfCosa.AddFileReferenceColumn(AColumnName: string;
  ALabel: string; AVersionAlta: integer; AVersionBaja: integer): integer;
begin
  Result := self.AddDataColumn(AColumnName, TDataTypeArchiRefOfCosa,
    ALabel, '', [], AVersionAlta, AVersionBaja);
end;

function TDataColumnListOfCosa.AddFileReferenceColumn(AColumnName: string;
  ALabel: string; AConstraints: TColumnConstraints; AVersionAlta: integer;
  AVersionBaja: integer): integer;
begin
  Result := self.AddDataColumn(AColumnName, TDataTypeArchiRefOfCosa,
    ALabel, '', AConstraints, AVersionAlta, AVersionBaja);
end;

function TDataColumnListOfCosa.AddListColumn(AColumnName: string;
  AConstraints: TColumnConstraints;
  AVersionAlta: integer;
  AVersionBaja: integer): integer;
begin
  Result := Self.AddDataColumn(AColumnName,
    TDataTypeListOfCosa, '',
    '', AConstraints,
    AVersionAlta, AVersionBaja);
end;

function TDataColumnListOfCosa.AddListColumn(AColumnName: string;
  AVersionAlta: integer;
  AVersionBaja: integer): integer;
begin
  Result := Self.AddDataColumn(AColumnName,
    TDataTypeListOfCosa, '',
    '', [],
    AVersionAlta, AVersionBaja);
end;

function TDataColumnListOfCosa.AddListColumn(AColumnName: string;
  ALabel: string;
  AConstraints: TColumnConstraints;
  AVersionAlta: integer;
  AVersionBaja: integer): integer;
begin
  Result := Self.AddDataColumn(AColumnName,
    TDataTypeListOfCosa, ALabel,
    '', AConstraints,
    AVersionAlta, AVersionBaja);
end;

function TDataColumnListOfCosa.AddListColumn(AColumnName: string;
  ALabel: string;
  AVersionAlta: integer;
  AVersionBaja: integer): integer;
begin
  Result := Self.AddDataColumn(AColumnName,
    TDataTypeListOfCosa, ALabel,
    '', [],
    AVersionAlta, AVersionBaja);
end;

function TDataColumnListOfCosa.AddCosaColumn(AColumnName: string;
  AVersionAlta: integer;
  AVersionBaja: integer): integer;
begin
  Result := Self.AddDataColumn(AColumnName, nil,
    '', '',
    [], AVersionAlta,
    AVersionBaja);
end;

function TDataColumnListOfCosa.AddCosaColumn(AColumnName: string;
  AConstraints: TColumnConstraints;
  AVersionAlta: integer;
  AVersionBaja: integer): integer;
begin
  Result := Self.AddDataColumn(AColumnName, nil,
    '', '',
    AConstraints, AVersionAlta,
    AVersionBaja);
end;

function TDataColumnListOfCosa.AddCosaColumn(AColumnName: string;
  ALabel: string;
  AConstraints: TColumnConstraints;
  AVersionAlta: integer;
  AVersionBaja: integer): integer;
begin
  Result := Self.AddDataColumn(AColumnName, nil, ALabel, '', AConstraints,
    AVersionAlta, AVersionBaja);
end;

function TDataColumnListOfCosa.AddCosaColumn(AColumnName: string;
  ALabel: string;
  AVersionAlta: integer;
  AVersionBaja: integer): integer;
begin
  Result := Self.AddDataColumn(AColumnName, nil, ALabel, '', [],
    AVersionAlta, AVersionBaja);
end;

function TDataColumnListOfCosa.AddDAOfCosaColumn(AColumnName: string;
  AConstraints: TColumnConstraints; AVersionAlta: integer;
  AVersionBaja: integer): integer;
begin
  Result := self.AddDataColumn(AColumnName, nil, '', '', AConstraints,
    AVersionAlta, AVersionBaja);
end;

function TDataColumnListOfCosa.AddDAOfCosaColumn(AColumnName: string;
  AVersionAlta: integer; AVersionBaja: integer): integer;
begin
  Result := self.AddDataColumn(AColumnName, nil, '', '', [], AVersionAlta, AVersionBaja);
end;

function TDataColumnListOfCosa.AddDAOfCosaColumn(AColumnName: string;
  ALabel: string; AConstraints: TColumnConstraints; AVersionAlta: integer;
  AVersionBaja: integer): integer;
begin
  Result := self.AddDataColumn(AColumnName, nil, ALabel, '', AConstraints,
    AVersionAlta, AVersionBaja);
end;

function TDataColumnListOfCosa.AddDAOfCosaColumn(AColumnName: string;
  ALabel: string; AVersionAlta: integer; AVersionBaja: integer): integer;
begin
  Result := self.AddDataColumn(AColumnName, nil, ALabel, '', [],
    AVersionAlta, AVersionBaja);
end;


function TDataColumnListOfCosa.GetIndexOfDataColumnByName(AName: string): integer;
var
  Index: integer;
  foundIt: boolean;
  Count: integer;
  a: string;
begin
  Result := -1;
  for Index := 0 to self.Count - 1 do
  begin
    if (LowerCase(self.Items[Index].ColumnName) = LowerCase(AName)) then
    begin
      Result := Index;
      break;
    end;
  end;
end;

procedure TDataColumnListOfCosa.Move(CurIndex, NewIndex: integer);
var
  i: integer;
begin
  inherited Move(CurIndex, NewIndex);
  for i := 0 to self.Count - 1 do
    Items[i].Index := i;
end;



// Lee el campo iCampo de aCosa y lo retorna como String
function TDataColumnListOfCosa.GetValStr(aCosa: TCosa; iCampo: integer): string;
var
  aColDef: TDataColumnOfCosa;
begin
  aColDef := GetItem(iCampo);
  raise Exception.Create(
    'TDataColumnListOfCosa.GetValStr: No existe mas el Offset, VERIFICAR! ');
  Result := '';//aColDef.DataType.ToString( pointer(aCosa)+ aColDef.Offset );
end;

// Fija el valor del campo iCampo de aCosa de acuerdo al NuevoValor
// El resultado es TRUE si logró setear el campo (no falló la conversión de tipo)
function TDataColumnListOfCosa.SetValStr(aCosa: TCosa; iCampo: integer;
  NuevoValor: string): boolean;
var
  aColDef: TDataColumnOfCosa;
begin
  aColDef := GetItem(iCampo);
  raise Exception.Create(
    'TDataColumnListOfCosa.SetValStr: No existe mas el Offset, VERIFICAR! ');
  //result:= aColDef.DataType.Eval( NuevoValor, pointer( aCosa )+ aColDef.Offset );
end;

function TDataColumnListOfCosa.Clone: TDataColumnListOfCosa;
var
  dcl: TDataColumnListOfCosa;
  i: integer;
begin
  dcl := TDataColumnListOfCosa.Create(self._ClassOwner);
  for i := 0 to self.Count - 1 do
  begin
    dcl.Add(self.Items[i].Clone);
    dcl.Items[i].DataColumnListOwner := dcl;
  end;
  dcl.ClassOwner := self.ClassOwner;
  dcl.ItemListClaseDeCosa := self.ItemListClaseDeCosa;

  if Assigned(self.ValidationList) then
    dcl.ValidationList := self.ValidationList.Clone();
  Result := dcl;
end;

function TDataColumnListOfCosa.Equals(dcl: TDataColumnListOfCosa): boolean;
var
  i: integer;
  c1: integer;
begin
  Result := True;
  c1 := self.Count;

  if not (Assigned(dcl) and (c1 <> 0) and (c1 = dcl.Count)) then
    Result := False
  else
    for i := 0 to c1 - 1 do
      if not self.Items[i].Equals(dcl.Items[i]) then
      begin
        Result := False;
        Break;
      end;
end;

procedure TDataColumnListOfCosa.Free;
var
  i: integer;
begin
  _ClassOwner := nil;
  _ItemListClaseDeCosa := nil;
  for i := 0 to Count - 1 do
    Items[i].Free;

  inherited Free;
end;

function TDataColumnListOfCosa.GetClassOwner(): TClaseDeCosa;
begin
  Result := self._ClassOwner;
end;

function TDataColumnListOfCosa.GetItemListClaseDeCosa: TClaseDeCosa;
begin
  Result := self._ItemListClaseDeCosa;
end;

function TDataColumnListOfCosa.GetVersion: integer;
begin
  Result := self._Version;
end;

function TDataColumnListOfCosa.AddDataColumn(AColumnName: string;
  ADateType: DataTypeOfCosa; ALabel: string; ADefaultValue: string;
  AConstraints: TColumnConstraints; AVersionAlta: integer;
  AVersionBaja: integer): integer;
var
  PropInfo: PPropInfo;
  TypeKind: TTypeKind;
  AClaseDeCosa: TClaseDeCosa;
  DataColumn: TDataColumnOfCosa;
  b: string;
begin

  Result := -1;
  if ((self.Version = -2) and (AVersionBaja = -1)) or
    ((self.Version >= AVersionAlta) and ((AVersionBaja = -1) or
    (self.Version < AVersionBaja))) then
  begin

    //writeln(self.Version,' ',Assigned(self.ClassOwner));
    if (self.Version = -2) and Assigned(self.ClassOwner) then
    begin
      b := self.ClassOwner.ClassName;
      try
        PropInfo := typinfo.FindPropInfo(self.ClassOwner.ClassType, '_' + AColumnName);

        TypeKind := PropInfo.PropType^.Kind;


        {****************** Identificacion del tipo de dato ******************}
        if not Assigned(ADateType) then
        begin

          case TypeKind of
            tkInteger: ADateType := TDataTypeIntegerOfCosa;
            //tkDate:        ADateType:=TDataTypeDateOfCosa;
            //Esto no existe... Por lo que paso el DateType por parámetro...
            tkEnumeration: ADateType := TDataTypeIntegerOfCosa;
            tkString: ADateType := TDataTypeStringOfCosa;
            tkaString: ADateType := TDataTypeStringOfCosa;
            tkFloat: ADateType := TDataTypeDoubleOfCosa;
            tkBool: ADateType := TDataTypeBooleanOfCosa;
            tkDynArray:
            begin
              case GetTypeData(PropInfo^.PropType)^.varType of
                vardouble: ADateType := TDataTypeDAOfDoubleOfCosa;
                varstring: ADateType := TDataTypeDAOfStringOfCosa;
                varboolean: ADateType := TDataTypeDAOfBooleanOfCosa;
                varinteger: ADateType := TDataTypeDAOfIntegerOfCosa;
                else
                  ADateType := TDataTypeDAOfCosa;
              end;
            end;
            tkClass: ADateType := TDataTypeDataRowOfCosa;
          end;
        end;

        if TypeKind = TTypeKind.tkClass then
        begin
          AClaseDeCosa := TClaseDeCosa(typinfo.GetTypeData(PropInfo^.PropType)^.ClassType);
          b := AClaseDeCosa.ClassName;
        end
        else
          AClaseDeCosa := nil;

      except
        on E: EPropertyError do
          ADateType := TDataTypeStringOfCosa;
      end;
    end
    else
      ADateType := TDataTypeStringOfCosa;

    DataColumn := TDataColumnOfCosa.Create(AColumnName,
      ALabel,
      ADateType, ADefaultValue,
      AConstraints,
      AVersionAlta,
      AVersionBaja,
      AClaseDeCosa);

    DataColumn.DataColumnListOwner := self;
    Result := inherited Add(DataColumn);
    DataColumn.Index := Result;

  end;

end;

constructor TDataColumnListOfCosa.Create;
begin
  inherited Create;
end;

//////////////////////////////////////////////////////////////////////////////
//TDataColumnOfCosa
//////////////////////////////////////////////////////////////////////////////

constructor TDataColumnOfCosa.Create(xColumnName: string;
  xLabel: string;
  xDataType: DataTypeOfCosa;
  xValorPorDefecto: string;
  xConstraints: TColumnConstraints;
  xVersionAlta: integer;
  xVersionBaja: integer;
  xClaseDeCosa: TClaseDeCosa); overload;
begin

  self.ColumnName := LowerCase(xColumnName);
  self.DataType := xDataType.Create(Self);

  if xLabel = '' then
    self.LabelCaption := xColumnName
  else
    self.LabelCaption := xLabel;

  self.ValorPorDefecto := xValorPorDefecto;

  self.Constraints := xConstraints;

  self.VersionAlta := xVersionAlta;
  self.VersionBaja := xVersionBaja;

  if Assigned(self.DataType) then
  begin
    self.DataType.ClaseDeCosa := xClaseDeCosa;
  end;
end;

constructor TDataColumnOfCosa.Create(xColumnName: string;
  xDataType: DataTypeOfCosa;
  xClaseDeCosa: TClaseDeCosa = nil); overload;
begin
  self.Create(xColumnName, '', xDataType, '', [], -1, -1, xClaseDeCosa);
end;

function TDataColumnOfCosa.Clone: TDataColumnOfCosa;
var
  DataColumn: TDataColumnOfCosa;
begin

  DataColumn := TDataColumnOfCosa.Create();
  DataColumn.ColumnName := self.ColumnName;
  DataColumn.ValorPorDefecto := self.ValorPorDefecto;
  DataColumn.VersionAlta := self.VersionAlta;
  DataColumn.VersionBaja := self.VersionBaja;
  DataColumn.LabelCaption := self.LabelCaption;

  if Assigned(self.DataType) then
  begin
    DataColumn.DataType := self.DataType.Clone();
    DataColumn.DataType.DataColumnOwner := DataColumn;
  end
  else
    DataColumn.DataType := nil;

  Result := DataColumn;
end;

function TDataColumnOfCosa.Equals(dc: TDataColumnOfCosa): boolean;
begin
  Result := LowerCase(self.ColumnName) = LowerCase(dc.ColumnName);
end;

procedure TDataColumnOfCosa.Free;
begin
  DataType.Free;
end;

constructor TDataTypeOfCosa.Create(DataColumnOwner: TDataColumnOfCosa);
begin
  inherited Create;
  self.DataColumnOwner := DataColumnOwner;
end;

function TDataTypeOfCosa.Validate(sval: string; var ErrorMessage: string): boolean;
begin
  Result := True;
end;

function TDataTypeOfCosa.CompareTo(TheOperator: TOperator; asval: string;
  bsval: string): boolean;
begin
  Result := True;
end;

function TDataTypeOfCosa.Eval(sval: string; pval: pointer): boolean;
begin
  if sval = '' then
    Result := False
  else
    Result := True;
end;

//////////////////////////////////////////////////////////////////////////////
//TDataTypeOfCosa
//////////////////////////////////////////////////////////////////////////////
function TDataTypeOfCosa.IsAMacroVariable(sval: string): boolean;
var
  r: boolean;
  RegexObj: TRegExpr;
begin
  RegexObj := TRegExpr.Create();
  RegexObj.Expression := '\{\$.*\}';
  r := RegexObj.Exec(sval);
  RegexObj.Free;
  Result := r;
end;

function TDataTypeOfCosa.Clone: TDataTypeOfCosa;
var
  DataType: TDataTypeOfCosa;
begin
  DataType := TDataTypeOfCosa(self.ClassType.Create());
  DataType.ClaseDeCosa := self.ClaseDeCosa;
  Result := DataType;
end;

function TDataTypeOfCosa.Equals(dtc: TDataTypeOfCosa): boolean;
begin
  Result := self.ClaseDeCosa = dtc.ClaseDeCosa;
end;

function TDataTypeOfCosa.Format(sval: string): string;
begin
  Result := sval;
end;

procedure TDataTypeOfCosa.Free;
begin
  ClaseDeCosa := nil;
end;

function TDataTypeIntegerOfCosa.Validate(sval: string;
  var ErrorMessage: string): boolean;
var
  RegexObj: TRegExpr;
begin
  RegexObj := TRegExpr.Create;
  RegexObj.Expression := '^[0-9]+$';
  Result := RegexObj.Exec(sval);
  RegexObj.Free;

  ErrorMessage := 'El valor ingresado no es correcto. Ingrese un número entero.';

  //Try
  //  Writeln (StrToInt('12345678901234567890'));
  //except
  //  On E : EConvertError do
  //    Writeln ('Invalid number encountered');
  //end;
end;

function TDataTypeIntegerOfCosa.CompareTo(TheOperator: TOperator;
  asval: string; bsval: string): boolean;
var
  aival: integer;
  bival: integer;
begin

  aival := 0;
  bival := 0;

  self.Eval(asval, @aival);
  self.Eval(bsval, @bival);

  case TheOperator of

    TOperator.EQUAL: Result := aival = bival;
    TOperator.DISTINCT: Result := aival <> bival;
    TOperator.LESS: Result := aival < bival;
    TOperator.LESS_OR_EQUAL: Result := aival <= bival;
    TOperator.GREATER: Result := aival > bival;
    TOperator.GREATER_OR_EQUAL: Result := aival >= bival;

  end;
end;

function TDataTypeIntegerOfCosa.Eval(sval: string; pval: pointer): boolean;
var
  res: extended;
begin
  Result := inherited;
  if not Result then
    exit;
  try
    if not (self.IsAMacroVariable(sval)) then
    begin
      res := uevaluador.evalStrToFloat(sval);
      integer(pval^) := trunc(res);
      Result := True;
    end;
  except
    Result := False;
  end;
end;

function TDataTypeIntegerOfCosa.ToString(pval: pointer): string;
begin
  Result := IntToStr(integer(pval^));
end;

function TDataTypeStringOfCosa.Eval(sval: string; pval: pointer): boolean;
begin
  Result := inherited;
  if not Result then
    exit;
  try
    if not (self.IsAMacroVariable(sval)) then
    begin
      string(pval^) := sval;
      Result := True;
    end
  except
    Result := False;
  end;
end;

function TDataTypeStringOfCosa.ToString(pval: pointer): string;
begin
  Result := string(pval^);
end;

function TDataTypeDataRowOfCosa.Eval(sval: string; pval: pointer): boolean;
var
  split: TStringList;
  DataTableName: string;
  DataRowId: integer;
  ref: PCosaConNombre;
  cosa: TCosa;
  nombreRef: string;
  clase: string;

  function IsAReference(sval: string): boolean;
  var
    r: boolean;
    RegexObj: TRegExpr;
  begin
    RegexObj := TRegExpr.Create;
    RegexObj.Expression := '<[^+]*>';
    r := RegexObj.Exec(sval);
    RegexObj.Free;
    Result := r;
  end;

begin

  Result := inherited;

  cosa := nil;

  if not Result then
    exit;

  if IsAReference(sval) then
  begin
    parsearReferencia(sval, clase, nombreRef);
    if (clase <> '?') then
      uCosaConNombre.registrar_referencia(nil, clase, nombreRef, pval^);
  end
  else
  begin
    try
      split := TStringList.Create;
      ExtractStrings(['.'], [], PChar(sval), split);
      DataTableName := split[0];
      DataRowId := StrToInt(split[1]);
      self.DataColumnOwner.DataColumnListOwner.DataTableOwner.
        DataStoreOwner.CreateClassInstance(DataTableName, DataRowId, cosa);

      //ACA SE PUEDE HACER LAS COMPARACIONES ENTRE CAMPOS, ES PARTE DE LA EVALUACIÓN
      cosa.Validate();

      if cosa is TCosaConNombre then
      begin
        cosasConNombre.Add(TCosaConNombre(cosa));
      end;

    except
      on e: Exception do
      begin
        Result := False;
        split.Free;
      end;
    end;
  end;

  TCosa(pval^) := cosa;

end;

function TDataTypeDataRowOfCosa.ToString(pval: pointer): string;
begin

end;

function TDataTypeDateOfCosa.Validate(sval: string; var ErrorMessage: string): boolean;
var
  RegexObj: TRegExpr;
begin
  //RegexObj := TRegExpr.Create;
  //RegexObj.Expression := '^([0-9]{4}|[0-9]{2})[./-]([0]?[1-9]|[1][0-2])[./-]([0]?[1-9]|[1|2][0-9]|[3][0|1])$';
  //Result := RegexObj.Exec(sval);
  //RegexObj.Free;
end;

function TDataTypeDateOfCosa.CompareTo(TheOperator: TOperator;
  asval: string; bsval: string): boolean;
var
  adval: TFecha;
  bdval: TFecha;
begin

  adval := nil;
  bdval := nil;

  self.Eval(asval, @adval);
  self.Eval(bsval, @bdval);

  case TheOperator of

    TOperator.EQUAL: Result := adval.igualQue(bdval);
    TOperator.DISTINCT: Result := not adval.igualQue(bdval);
    TOperator.LESS: Result := adval.menorQue(bdval);
    TOperator.LESS_OR_EQUAL: Result := adval.menorOIgualQue(bdval);
    TOperator.GREATER: Result := adval.mayorQue(bdval);
    TOperator.GREATER_OR_EQUAL: Result := adval.mayorOIgualQue(bdval);

  end;
end;

function TDataTypeDateOfCosa.Eval(sval: string; pval: pointer): boolean;
begin
  Result := inherited;
  if not Result then
    exit;
  if not (self.IsAMacroVariable(sval)) then
  begin
    TFecha(pval^) := TFecha.Create_str(sval);
    ;
    Result := True;
  end;
end;

function TDataTypeDateOfCosa.ToString(pval: pointer): string;
begin
  Result := TFecha(pval^).AsStr;
end;

{ TDataTypeListOfCosa }

function TDataTypeListOfCosa.Eval(sval: string; pval: pointer): boolean;
var
  split: TStringList;
  TableName, ColumnNameToQuery, CellSValToQuery, ColumnNameToGetSVal: string;
  Childs: TDAofString;
  DataTableChild: TDataTableOfCosa;
  DataRowChild: TDataRowOfCosa;
  DataRowChildId: integer;
  IdChild: string;
  i, j: integer;

  cosa: TCosa = nil;
  lst: TList;

begin
  Result := inherited;
  if not Result then
    exit;

  lst := TList.Create;

  split := TStringList.Create;
  try
    ExtractStrings(['.'], [], PChar(sval), split);
    TableName := split[0];
    ColumnNameToQuery := split[1];
    CellSValToQuery := split[2];
    ColumnNameToGetSVal := 'IdChild'
  finally
    split.Free;
  end;
  Childs := self.DataColumnOwner.DataColumnListOwner.DataTableOwner.
    DataStoreOwner.ReadDataCellTextValues(TableName, ColumnNameToQuery,
    CellSValToQuery, ColumnNameToGetSVal, True);

  for i := 0 to Length(Childs) - 1 do
  begin
    split := TStringList.Create;
    try
      ExtractStrings(['.'], [], PChar(Childs[i]), split);
      TableName := split[0];
      IdChild := copy(split[1], Pos(':', split[1]) + 1, Length(split[1]));
    finally
      split.Free;
    end;
    j := self.DataColumnOwner.DataColumnListOwner.DataTableOwner.
      DataStoreOwner.GetIndexOfDataTableByName(TableName);
    if (j >= 0) then
      DataTableChild := self.DataColumnOwner.DataColumnListOwner.
        DataTableOwner.DataStoreOwner.DataTableList[j]
    else
      raise Exception.Create('No se encontro la tabla "' + TableName +
        '" en el DATA_STORE');

    self.DataColumnOwner.DataColumnListOwner.DataTableOwner.DataStoreOwner.
      CreateClassInstance(DataTableChild.TableName, StrToInt(IdChild), cosa);
    lst.Add(cosa);
    if cosa is TCosaConNombre then
      cosasConNombre.Add(TCosaConNombre(cosa));

  end;
  TList(pval^) := lst;
  Result := True;
end;

function TDataTypeListOfCosa.ToString(pval: pointer): string;
begin

end;

function TDataTypeDoubleOfCosa.Validate(sval: string;
  var ErrorMessage: string): boolean;
var
  RegexObj: TRegExpr;
begin
  RegexObj := TRegExpr.Create;
  RegexObj.Expression := '/^\d*\.?\d*$/';
  Result := RegexObj.Exec(sval);
  RegexObj.Free;
end;

function TDataTypeDoubleOfCosa.Eval(sval: string; pval: pointer): boolean;
var
  res: extended;

begin
  Result := inherited;
  if not Result then
    exit;
  try
    if not (self.IsAMacroVariable(sval)) then
    begin
      double(pval^) := StrToFloat(sval);
      Result := True;
    end;
  except
    Result := False;
  end;
end;

function TDataTypeDoubleOfCosa.ToString(pval: pointer): string;
var
  val: NReal;
begin
  val := double(pval^);
  Result := FloatToStrF(val, ffGeneral, uconstantesSimSEE.CF_PRECISION,
    uconstantesSimSEE.CF_DECIMALES);
end;

function TDataTypeBooleanOfCosa.Eval(sval: string; pval: pointer): boolean;
begin
  Result := inherited;
  if not Result then
    exit;
  try
    if not (self.IsAMacroVariable(sval)) then
    begin

      {dfusco@20150508
       Valor por defecto si el sval es nulo.}
      if sval = '' then
        sval := '0';

      boolean(pval^) := StrToBool(sval);
      Result := True;
    end;
  except
    Result := False;
  end;
end;

function TDataTypeBooleanOfCosa.ToString(pval: pointer): string;
begin
  if boolean(pval^) then
    Result := '1'
  else
    Result := '0';
end;

function TDataTypeDAOfDoubleOfCosa.Eval(sval: string; pval: pointer): boolean;
var
  c: char;
begin
  Result := inherited;
  if not Result then
    exit;
  try
    if not (self.IsAMacroVariable(sval)) then
    begin
      c := SysUtils.DefaultFormatSettings.DecimalSeparator;
      parseDAOfNreal(TDAofNReal(pval^), sval);
      Result := True;
    end
    else
    begin

    end;
  except
    Result := False;
  end;
end;

function TDataTypeDAOfDoubleOfCosa.ToString(pval: pointer): string;
begin
  Result := TDAOfNRealToString(TDAOfNReal(pval^), CF_PRECISION, CF_DECIMALES, ', ', '|');
end;

function TDataTypeDAOfDoubleOfCosa.Format(sval: string): string;
var
  split: TStringList;
begin
  split := TStringList.Create;
  ExtractStrings([','], [], PChar(sval), split);
  Result := '[' + IntToStr(split.Count) + '|' + sval + ']';
  split.Free;
end;

function TDataTypeDAOfStringOfCosa.Eval(sval: string; pval: pointer): boolean;
begin
  Result := inherited;
  if not Result then
    exit;
  try
    if not (self.IsAMacroVariable(sval)) then
    begin
      parseDAOfString(TDAOfString(pval^), sval);
      Result := True;
    end
    else
    begin

    end;
  except
    Result := False;
  end;
end;

function TDataTypeDAOfStringOfCosa.ToString(pval: pointer): string;
begin
  Result := TDAOfStringToString(TDAofString(pval^), ', ', '|');
end;

function TDataTypeDAOfStringOfCosa.Format(sval: string): string;
var
  split: TStringList;
begin
  split := TStringList.Create;
  ExtractStrings([','], [], PChar(sval), split);
  Result := '[' + IntToStr(split.Count) + '|' + sval + ']';
  split.Free;
end;

function TDataTypeStringListOfCosa.Eval(sval: string; pval: pointer): boolean;
begin
  Result := inherited;
  if not Result then
    exit;
  try
    if not (self.IsAMacroVariable(sval)) then
    begin
      parseStringList(TStringList(pval^), sval);
      Result := True;
    end
    else
    begin

    end;
  except
    Result := False;
  end;
end;

function TDataTypeStringListOfCosa.ToString(pval: pointer): string;
begin
  Result := TStringListToString(TStringList(pval^), ',', '|');
end;

function TDataTypeStringListOfCosa.Format(sval: string): string;
var
  split: TStringList;
begin
  split := TStringList.Create;
  ExtractStrings([','], [], PChar(sval), split);
  Result := '[' + IntToStr(split.Count) + '|' + sval + ']';
  split.Free;
end;

function TDataTypeDAOfIntegerOfCosa.Eval(sval: string; pval: pointer): boolean;
begin
  Result := inherited;
  if not Result then
    exit;
  try
    if not (self.IsAMacroVariable(sval)) then
    begin
      parseDAOfNInt(TDAofNInt(pval^), sval);
      Result := True;
    end
    else
    begin

    end;
  except
    Result := False;
  end;
end;

function TDataTypeDAOfIntegerOfCosa.ToString(pval: pointer): string;
begin
  Result := TDAOfNIntToString(TDAofNInt(pval^), ', ', '|');
end;

function TDataTypeDAOfIntegerOfCosa.Format(sval: string): string;
var
  split: TStringList;
begin
  split := TStringList.Create;
  ExtractStrings([','], [], PChar(sval), split);
  Result := '[' + IntToStr(split.Count) + '|' + sval + ']';
  split.Free;
end;

function TDataTypeDAOfBooleanOfCosa.Eval(sval: string; pval: pointer): boolean;
begin
  Result := inherited;
  if not Result then
    exit;
  try
    if not (self.IsAMacroVariable(sval)) then
    begin
      parseDAOfBoolean(TDAOfBoolean(pval^), sval);
      Result := True;
    end
    else
    begin

    end;
  except
    Result := False;
  end;
end;

function TDataTypeDAOfBooleanOfCosa.ToString(pval: pointer): string;
begin
  Result := TDAOfBooleanToString(TDAOfBoolean(pval^), ', ', True, '|');
end;

function TDataTypeDAOfBooleanOfCosa.Format(sval: string): string;
var
  split: TStringList;
begin
  split := TStringList.Create;
  ExtractStrings([','], [], PChar(sval), split);
  Result := '[' + IntToStr(split.Count) + '|' + sval + ']';
  split.Free;
end;

function TDataTypeArchiRefOfCosa.Eval(sval: string; pval: pointer): boolean;
begin
  Result := True;
  try
    if not (self.IsAMacroVariable(sval)) then
    begin
      TArchiRef(pval^) := TArchiRef.Create(sval);
    end
    else
    begin

    end;
  except
    Result := False;
  end;
end;

function TDataTypeArchiRefOfCosa.ToString(pval: pointer): string;
begin

end;

function TDataTypeReferenciaOfCosa.Eval(sval: string; pval: pointer): boolean;
var
  clase: string = '';
  nombreRef: string = '';
  TableName, ColumnNameToQuery, CellSValToQuery, ColumnNameToGetSVal: string;
  Childs: TDAofNInt;
  rowId: integer;

begin
  Result := inherited;
  if not Result then
    exit;
  try
    if not (self.IsAMacroVariable(sval)) then
    begin
      parsearReferencia(sval, clase, nombreRef);
      if (clase <> '?') then
      begin
        TableName := 'dt_' + clase;

        //writeln(TableName);

        ColumnNameToQuery := 'Nombre';
        CellSValToQuery := nombreRef;

        Childs := self.DataColumnOwner.DataColumnListOwner.DataTableOwner.
          DataStoreOwner.ReadRowIdsTextValues(TableName, ColumnNameToQuery,
          CellSValToQuery);

        rowId := Childs[0];
        uCosaConNombre.registrar_referencia(nil, clase, nombreRef, pval^);
      end;
      Result := True;
    end;
  except
    Result := False;
  end;
end;

function TDataTypeReferenciaOfCosa.ToString(pval: pointer): string;
begin

end;

{ TDataTypeDAOfCosa }

function TDataTypeDAOfCosa.Eval(sval: string; pval: pointer): boolean;
begin
  Result := inherited;
  if not Result then
    exit;
end;

function TDataTypeDAOfCosa.ToString(pval: pointer): string;
begin

end;

end.

