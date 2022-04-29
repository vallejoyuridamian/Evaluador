{
    This file is part of the Free Component Library (FCL)
    Copyright (c) 2008 Michael Van Canneyt.

    Expression parser, supports variables, functions and
    float/integer/string/boolean/datetime operations.

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}
{$mode objfpc}
{$h+}
unit fpexprpars_x_grids;

interface

uses
  Classes, SysUtils, contnrs;

type
  // tokens
  TTokenType = (ttPlus, ttMinus, ttLessThan, ttLargerThan, ttEqual, ttDiv,
    ttMul, ttLeft, ttRight, ttLessThanEqual, ttLargerThanEqual,
    ttunequal, ttNumber, ttString, ttIdentifier,
    ttComma, ttand, ttOr, ttXor, ttTrue, ttFalse, ttnot, ttif,
    ttCase, ttEOF);

  TExprFloat = double;

const
  ttDelimiters = [ttPlus, ttMinus, ttLessThan, ttLargerThan, ttEqual,
    ttDiv, ttMul, ttLeft, ttRight, ttLessThanEqual,
    ttLargerThanEqual, ttunequal];
  ttComparisons = [ttLargerThan, ttLessthan,
    ttLargerThanEqual, ttLessthanEqual,
    ttEqual, ttUnequal];

type

  TFPExpressionParser = class;
  TExprBuiltInManager = class;

  { TFPExpressionScanner }

  TFPExpressionScanner = class(TObject)
    FSource: string;
    LSource, FPos: integer;
    FChar: PChar;
    FToken: string;
    FTokenType: TTokenType;
  private
    function GetCurrentChar: char;
    procedure ScanError(Msg: string);
  protected
    procedure SetSource(const AValue: string); virtual;
    function DoIdentifier: TTokenType;
    function DoNumber: TTokenType;
    function DoDelimiter: TTokenType;
    function DoString: TTokenType;
    function NextPos: char; // inline;
    procedure SkipWhiteSpace; // inline;
    function IsWordDelim(C: char): boolean; // inline;
    function IsDelim(C: char): boolean; // inline;
    function IsDigit(C: char): boolean; // inline;
    function IsAlpha(C: char): boolean; // inline;
  public
    constructor Create;
    function GetToken: TTokenType;
    property Token: string read FToken;
    property TokenType: TTokenType read FTokenType;
    property Source: string read FSource write SetSource;
    property Pos: integer read FPos;
    property CurrentChar: char read GetCurrentChar;
  end;

  EExprScanner = class(Exception);

  TResultType = (rtBoolean, rtInteger, rtFloat, rtDateTime, rtString);
  TResultTypes = set of TResultType;

  TFPExpressionResult = record
    ResString: string;
    case ResultType: TResultType of
      rtBoolean: (ResBoolean: boolean);
      rtInteger: (ResInteger: int64);
      rtFloat: (ResFloat: TExprFloat);
      rtDateTime: (ResDateTime: TDatetime);
      rtString: ();
  end;
  PFPExpressionResult = ^TFPExpressionResult;
  TExprParameterArray = array of TFPExpressionResult;

  { TFPExprNode }

  TFPExprNode = class(TObject)
  protected
    procedure CheckNodeType(Anode: TFPExprNode; Allowed: TResultTypes);
    // A procedure with var saves an implicit try/finally in each node
    // A marked difference in execution speed.
    procedure GetNodeValue(var Result: TFPExpressionResult); virtual; abstract;
  public
    procedure Check; virtual; abstract;
    function NodeType: TResultType; virtual; abstract;
    function NodeValue: TFPExpressionResult;
    function AsString: string; virtual; abstract;
  end;

  TExprArgumentArray = array of TFPExprNode;

  { TFPBinaryOperation }

  TFPBinaryOperation = class(TFPExprNode)
  private
    FLeft: TFPExprNode;
    FRight: TFPExprNode;
  protected
    procedure CheckSameNodeTypes;
  public
    constructor Create(ALeft, ARight: TFPExprNode);
    destructor Destroy; override;
    procedure Check; override;
    property left: TFPExprNode read FLeft;
    property Right: TFPExprNode read FRight;
  end;

  TFPBinaryOperationClass = class of TFPBinaryOperation;


  { TFPBooleanOperation }

  TFPBooleanOperation = class(TFPBinaryOperation)
  public
    procedure Check; override;
    function NodeType: TResultType; override;
  end;

  { TFPBinaryAndOperation }

  TFPBinaryAndOperation = class(TFPBooleanOperation)
  protected
    procedure GetNodeValue(var Result: TFPExpressionResult); override;
  public
    function AsString: string; override;
  end;

  { TFPBinaryOrOperation }

  TFPBinaryOrOperation = class(TFPBooleanOperation)
  protected
    procedure GetNodeValue(var Result: TFPExpressionResult); override;
  public
    function AsString: string; override;
  end;

  { TFPBinaryXOrOperation }

  TFPBinaryXOrOperation = class(TFPBooleanOperation)
  protected
    procedure GetNodeValue(var Result: TFPExpressionResult); override;
  public
    function AsString: string; override;
  end;

  { TFPBooleanResultOperation }

  TFPBooleanResultOperation = class(TFPBinaryOperation)
  public
    procedure Check; override;
    function NodeType: TResultType; override;
  end;

  TFPBooleanResultOperationClass = class of TFPBooleanResultOperation;


  { TFPEqualOperation }

  TFPEqualOperation = class(TFPBooleanResultOperation)
  protected
    procedure GetNodeValue(var Result: TFPExpressionResult); override;
  public
    function AsString: string; override;
  end;

  { TFPUnequalOperation }

  TFPUnequalOperation = class(TFPEqualOperation)
  protected
    procedure GetNodeValue(var Result: TFPExpressionResult); override;
  public
    function AsString: string; override;
  end;

  { TFPOrderingOperation }

  TFPOrderingOperation = class(TFPBooleanResultOperation)
    procedure Check; override;
  end;

  { TFPLessThanOperation }

  TFPLessThanOperation = class(TFPOrderingOperation)
  protected
    procedure GetNodeValue(var Result: TFPExpressionResult); override;
  public
    function AsString: string; override;
  end;

  { TFPGreaterThanOperation }

  TFPGreaterThanOperation = class(TFPOrderingOperation)
  protected
    procedure GetNodeValue(var Result: TFPExpressionResult); override;
  public
    function AsString: string; override;
  end;

  { TFPLessThanEqualOperation }

  TFPLessThanEqualOperation = class(TFPGreaterThanOperation)
  protected
    procedure GetNodeValue(var Result: TFPExpressionResult); override;
  public
    function AsString: string; override;
  end;


  { TFPGreaterThanEqualOperation }

  TFPGreaterThanEqualOperation = class(TFPLessThanOperation)
  protected
    procedure GetNodeValue(var Result: TFPExpressionResult); override;
  public
    function AsString: string; override;
  end;

  { TIfOperation }

  TIfOperation = class(TFPBinaryOperation)
  private
    FCondition: TFPExprNode;
  protected
    procedure GetNodeValue(var Result: TFPExpressionResult); override;
    procedure Check; override;
    function NodeType: TResultType; override;
  public
    constructor Create(ACondition, ALeft, ARight: TFPExprNode);
    destructor Destroy; override;
    function AsString: string; override;
    property Condition: TFPExprNode read FCondition;
  end;

  { TCaseOperation }

  TCaseOperation = class(TFPExprNode)
  private
    FArgs: TExprArgumentArray;
    FCondition: TFPExprNode;
  protected
    procedure GetNodeValue(var Result: TFPExpressionResult); override;
    procedure Check; override;
    function NodeType: TResultType; override;
  public
    constructor Create(Args: TExprArgumentArray);
    destructor Destroy; override;
    function AsString: string; override;
    property Condition: TFPExprNode read FCondition;
  end;

  { TMathOperation }

  TMathOperation = class(TFPBinaryOperation)
  protected
    procedure Check; override;
    function NodeType: TResultType; override;
  end;

  { TFPAddOperation }

  TFPAddOperation = class(TMathOperation)
  protected
    procedure GetNodeValue(var Result: TFPExpressionResult); override;
  public
    function AsString: string; override;
  end;

  { TFPSubtractOperation }

  TFPSubtractOperation = class(TMathOperation)
  protected
    procedure check; override;
    procedure GetNodeValue(var Result: TFPExpressionResult); override;
  public
    function AsString: string; override;
  end;

  { TFPMultiplyOperation }

  TFPMultiplyOperation = class(TMathOperation)
  protected
    procedure check; override;
  public
    function AsString: string; override;
    procedure GetNodeValue(var Result: TFPExpressionResult); override;
  end;

  { TFPDivideOperation }

  TFPDivideOperation = class(TMathOperation)
  protected
    procedure check; override;
  public
    function AsString: string; override;
    function NodeType: TResultType; override;
    procedure GetNodeValue(var Result: TFPExpressionResult); override;
  end;

  { TFPUnaryOperator }

  TFPUnaryOperator = class(TFPExprNode)
  private
    FOperand: TFPExprNode;
  public
    constructor Create(AOperand: TFPExprNode);
    destructor Destroy; override;
    procedure Check; override;
    property Operand: TFPExprNode read FOperand;
  end;

  { TFPConvertNode }

  TFPConvertNode = class(TFPUnaryOperator)
    function AsString: string; override;
  end;

  { TFPNotNode }

  TFPNotNode = class(TFPUnaryOperator)
  protected
    procedure Check; override;
  public
    function NodeType: TResultType; override;
    procedure GetNodeValue(var Result: TFPExpressionResult); override;
    function AsString: string; override;
  end;

  TIntConvertNode = class(TFPConvertNode)
  protected
    procedure Check; override;
  end;

  { TIntToFloatNode }
  TIntToFloatNode = class(TIntConvertNode)
  public
    function NodeType: TResultType; override;
    procedure GetNodeValue(var Result: TFPExpressionResult); override;
  end;

  { TIntToDateTimeNode }

  TIntToDateTimeNode = class(TIntConvertNode)
  public
    function NodeType: TResultType; override;
    procedure GetNodeValue(var Result: TFPExpressionResult); override;
  end;

  { TFloatToDateTimeNode }

  TFloatToDateTimeNode = class(TFPConvertNode)
  protected
    procedure Check; override;
  public
    function NodeType: TResultType; override;
    procedure GetNodeValue(var Result: TFPExpressionResult); override;
  end;

  { TFPNegateOperation }

  TFPNegateOperation = class(TFPUnaryOperator)
  public
    procedure Check; override;
    function NodeType: TResultType; override;
    procedure GetNodeValue(var Result: TFPExpressionResult); override;
    function AsString: string; override;
  end;

  { TFPConstExpression }

  TFPConstExpression = class(TFPExprnode)
  private
    FValue: TFPExpressionResult;
  public
    constructor CreateString(AValue: string);
    constructor CreateInteger(AValue: int64);
    constructor CreateDateTime(AValue: TDateTime);
    constructor CreateFloat(AValue: TExprFloat);
    constructor CreateBoolean(AValue: boolean);
    procedure Check; override;
    function NodeType: TResultType; override;
    procedure GetNodeValue(var Result: TFPExpressionResult); override;
    function AsString: string; override;
    // For inspection
    property ConstValue: TFPExpressionResult read FValue;
  end;


  TIdentifierType = (itVariable, itFunctionCallBack, itFunctionHandler);
  TFPExprFunctionCallBack = procedure(var Result: TFPExpressionResult;
    const Args: TExprParameterArray);
  TFPExprFunctionEvent = procedure(var Result: TFPExpressionResult;
    const Args: TExprParameterArray) of object;

  { TFPExprIdentifierDef }

  TFPExprIdentifierDef = class(TCollectionItem)
  private
    FStringValue: string;
    FValue: TFPExpressionResult;
    FArgumentTypes: string;
    FIDType: TIdentifierType;
    FName: ShortString;
    FOnGetValue: TFPExprFunctionEvent;
    FOnGetValueCB: TFPExprFunctionCallBack;
    function GetAsBoolean: boolean;
    function GetAsDateTime: TDateTime;
    function GetAsFloat: TExprFloat;
    function GetAsInteger: int64;
    function GetAsString: string;
    function GetResultType: TResultType;
    function GetValue: string;
    procedure SetArgumentTypes(const AValue: string);
    procedure SetAsBoolean(const AValue: boolean);
    procedure SetAsDateTime(const AValue: TDateTime);
    procedure SetAsFloat(const AValue: TExprFloat);
    procedure SetAsInteger(const AValue: int64);
    procedure SetAsString(const AValue: string);
    procedure SetName(const AValue: ShortString);
    procedure SetResultType(const AValue: TResultType);
    procedure SetValue(const AValue: string);
  protected
    procedure CheckResultType(const AType: TResultType);
    procedure CheckVariable;
  public
    function ArgumentCount: integer;
    procedure Assign(Source: TPersistent); override;
    property AsFloat: TExprFloat read GetAsFloat write SetAsFloat;
    property AsInteger: int64 read GetAsInteger write SetAsInteger;
    property AsString: string read GetAsString write SetAsString;
    property AsBoolean: boolean read GetAsBoolean write SetAsBoolean;
    property AsDateTime: TDateTime read GetAsDateTime write SetAsDateTime;
    property OnGetFunctionValueCallBack: TFPExprFunctionCallBack
      read FOnGetValueCB write FOnGetValueCB;
  published
    property IdentifierType: TIdentifierType read FIDType write FIDType;
    property Name: ShortString read FName write SetName;
    property Value: string read GetValue write SetValue;
    property ParameterTypes: string read FArgumentTypes write SetArgumentTypes;
    property ResultType: TResultType read GetResultType write SetResultType;
    property OnGetFunctionValue: TFPExprFunctionEvent
      read FOnGetValue write FOnGetValue;
  end;


  TBuiltInCategory = (bcStrings, bcDateTime, bcMath, bcBoolean, bcConversion,
    bcData, bcVaria, bcUser);
  TBuiltInCategories = set of TBuiltInCategory;

  { TFPBuiltInExprIdentifierDef }

  TFPBuiltInExprIdentifierDef = class(TFPExprIdentifierDef)
  private
    FCategory: TBuiltInCategory;
  public
    procedure Assign(Source: TPersistent); override;
  published
    property Category: TBuiltInCategory read FCategory write FCategory;
  end;

  { TFPExprIdentifierDefs }

  TFPExprIdentifierDefs = class(TCollection)
  private
    FParser: TFPExpressionParser;
    function GetI(AIndex: integer): TFPExprIdentifierDef;
    procedure SetI(AIndex: integer; const AValue: TFPExprIdentifierDef);
  protected
    procedure Update(Item: TCollectionItem); override;
    property Parser: TFPExpressionParser read FParser;
  public
    function IndexOfIdentifier(const AName: ShortString): integer;
    function FindIdentifier(const AName: ShortString): TFPExprIdentifierDef;
    function IdentifierByName(const AName: ShortString): TFPExprIdentifierDef;
    function AddVariable(const AName: ShortString; AResultType: TResultType;
      AValue: string): TFPExprIdentifierDef;
    function AddBooleanVariable(const AName: ShortString;
      AValue: boolean): TFPExprIdentifierDef;
    function AddIntegerVariable(const AName: ShortString;
      AValue: integer): TFPExprIdentifierDef;
    function AddFloatVariable(const AName: ShortString;
      AValue: TExprFloat): TFPExprIdentifierDef;
    function AddStringVariable(const AName: ShortString;
      AValue: string): TFPExprIdentifierDef;
    function AddDateTimeVariable(const AName: ShortString;
      AValue: TDateTime): TFPExprIdentifierDef;
    function AddFunction(const AName: ShortString; const AResultType: char;
      const AParamTypes: string; ACallBack: TFPExprFunctionCallBack): TFPExprIdentifierDef;
    function AddFunction(const AName: ShortString; const AResultType: char;
      const AParamTypes: string; ACallBack: TFPExprFunctionEvent): TFPExprIdentifierDef;
    property Identifiers[AIndex: integer]: TFPExprIdentifierDef read GetI write SetI;
      default;
  end;

  { TFPExprIdentifierNode }

  TFPExprIdentifierNode = class(TFPExprNode)
  private
    FID: TFPExprIdentifierDef;
    PResult: PFPExpressionResult;
    FResultType: TResultType;
  public
    constructor CreateIdentifier(AID: TFPExprIdentifierDef);
    function NodeType: TResultType; override;
    procedure GetNodeValue(var Result: TFPExpressionResult); override;
    property Identifier: TFPExprIdentifierDef read FID;
  end;

  { TFPExprVariable }

  TFPExprVariable = class(TFPExprIdentifierNode)
    procedure Check; override;
    function AsString: string; override;
  end;

  { TFPExprFunction }

  TFPExprFunction = class(TFPExprIdentifierNode)
  private
    FArgumentNodes: TExprArgumentArray;
    FargumentParams: TExprParameterArray;
  protected
    procedure CalcParams;
    procedure Check; override;
  public
    constructor CreateFunction(AID: TFPExprIdentifierDef;
      const Args: TExprArgumentArray); virtual;
    destructor Destroy; override;
    property ArgumentNodes: TExprArgumentArray read FArgumentNodes;
    property ArgumentParams: TExprParameterArray read FArgumentParams;
    function AsString: string; override;
  end;

  { TFPFunctionCallBack }

  TFPFunctionCallBack = class(TFPExprFunction)
  private
    FCallBack: TFPExprFunctionCallBack;
  public
    constructor CreateFunction(AID: TFPExprIdentifierDef;
      const Args: TExprArgumentArray); override;
    procedure GetNodeValue(var Result: TFPExpressionResult); override;
    property CallBack: TFPExprFunctionCallBack read FCallBack;
  end;

  { TFPFunctionEventHandler }

  TFPFunctionEventHandler = class(TFPExprFunction)
  private
    FCallBack: TFPExprFunctionEvent;
  public
    constructor CreateFunction(AID: TFPExprIdentifierDef;
      const Args: TExprArgumentArray); override;
    procedure GetNodeValue(var Result: TFPExpressionResult); override;
    property CallBack: TFPExprFunctionEvent read FCallBack;
  end;

  { TFPExpressionParser }

  TFPExpressionParser = class(TComponent)
  private
    FBuiltIns: TBuiltInCategories;
    FExpression: string;
    FScanner: TFPExpressionScanner;
    FExprNode: TFPExprNode;
    FIdentifiers: TFPExprIdentifierDefs;
    FHashList: TFPHashObjectlist;
    FDirty: boolean;
    procedure CheckEOF;
    function ConvertNode(Todo: TFPExprNode; ToType: TResultType): TFPExprNode;
    function GetAsBoolean: boolean;
    function GetAsDateTime: TDateTime;
    function GetAsFloat: TExprFloat;
    function GetAsInteger: int64;
    function GetAsString: string;
    function MatchNodes(Todo, Match: TFPExprNode): TFPExprNode;
    procedure CheckNodes(var Left, Right: TFPExprNode);
    procedure SetBuiltIns(const AValue: TBuiltInCategories);
    procedure SetIdentifiers(const AValue: TFPExprIdentifierDefs);
  protected
    procedure ParserError(Msg: string);
    procedure SetExpression(const AValue: string); virtual;
    procedure CheckResultType(const Res: TFPExpressionResult;
      AType: TResultType); inline;
    class function BuiltinsManager: TExprBuiltInManager;
    function Level1: TFPExprNode;
    function Level2: TFPExprNode;
    function Level3: TFPExprNode;
    function Level4: TFPExprNode;
    function Level5: TFPExprNode;
    function Level6: TFPExprNode;
    function Primitive: TFPExprNode;
    function GetToken: TTokenType;
    function TokenType: TTokenType;
    function CurrentToken: string;
    procedure CreateHashList;
    property Scanner: TFPExpressionScanner read FScanner;
    property ExprNode: TFPExprNode read FExprNode;
    property Dirty: boolean read FDirty;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function IdentifierByName(AName: ShortString): TFPExprIdentifierDef; virtual;
    procedure Clear;
    procedure EvaluateExpression(var Result: TFPExpressionResult);
    function Evaluate: TFPExpressionResult;
    function ResultType: TResultType;
    property AsFloat: TExprFloat read GetAsFloat;
    property AsInteger: int64 read GetAsInteger;
    property AsString: string read GetAsString;
    property AsBoolean: boolean read GetAsBoolean;
    property AsDateTime: TDateTime read GetAsDateTime;
  published
    // The Expression to parse
    property Expression: string read FExpression write SetExpression;
    property Identifiers: TFPExprIdentifierDefs read FIdentifiers write SetIdentifiers;
    property BuiltIns: TBuiltInCategories read FBuiltIns write SetBuiltIns;
  end;

  { TExprBuiltInManager }

  TExprBuiltInManager = class(TComponent)
  private
    FDefs: TFPExprIdentifierDefs;
    function GetCount: integer;
    function GetI(AIndex: integer): TFPBuiltInExprIdentifierDef;
  protected
    property Defs: TFPExprIdentifierDefs read FDefs;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function IndexOfIdentifier(const AName: ShortString): integer;
    function FindIdentifier(const AName: ShortString): TFPBuiltinExprIdentifierDef;
    function IdentifierByName(const AName: ShortString): TFPBuiltinExprIdentifierDef;
    function AddVariable(const ACategory: TBuiltInCategory;
      const AName: ShortString; AResultType: TResultType;
      AValue: string): TFPBuiltInExprIdentifierDef;
    function AddBooleanVariable(const ACategory: TBuiltInCategory;
      const AName: ShortString; AValue: boolean): TFPBuiltInExprIdentifierDef;
    function AddIntegerVariable(const ACategory: TBuiltInCategory;
      const AName: ShortString; AValue: integer): TFPBuiltInExprIdentifierDef;
    function AddFloatVariable(const ACategory: TBuiltInCategory;
      const AName: ShortString; AValue: TExprFloat): TFPBuiltInExprIdentifierDef;
    function AddStringVariable(const ACategory: TBuiltInCategory;
      const AName: ShortString; AValue: string): TFPBuiltInExprIdentifierDef;
    function AddDateTimeVariable(const ACategory: TBuiltInCategory;
      const AName: ShortString; AValue: TDateTime): TFPBuiltInExprIdentifierDef;
    function AddFunction(const ACategory: TBuiltInCategory;
      const AName: ShortString; const AResultType: char; const AParamTypes: string;
      ACallBack: TFPExprFunctionCallBack): TFPBuiltInExprIdentifierDef;
    function AddFunction(const ACategory: TBuiltInCategory;
      const AName: ShortString; const AResultType: char; const AParamTypes: string;
      ACallBack: TFPExprFunctionEvent): TFPBuiltInExprIdentifierDef;
    property IdentifierCount: integer read GetCount;
    property Identifiers[AIndex: integer]: TFPBuiltInExprIdentifierDef read GetI;
  end;

  EExprParser = class(Exception);


function TokenName(AToken: TTokenType): string;
function ResultTypeName(AResult: TResultType): string;
function CharToResultType(C: char): TResultType;
function BuiltinIdentifiers: TExprBuiltInManager;
procedure RegisterStdBuiltins(AManager: TExprBuiltInManager);
function ArgToFloat(Arg: TFPExpressionResult): TExprFloat;

const
  AllBuiltIns = [bcStrings, bcDateTime, bcMath, bcBoolean, bcConversion,
    bcData, bcVaria, bcUser];


implementation

uses typinfo;

{ TFPExpressionParser }

const
  cNull = #0;
  cSingleQuote = '''';

  Digits = ['0'..'9', '.'];
  WhiteSpace = [' ', #13, #10, #9];
  Operators = ['+', '-', '<', '>', '=', '/', '*'];
  Delimiters = Operators + [',', '(', ')'];
  Symbols = ['%', '^'] + Delimiters;
  WordDelimiters = WhiteSpace + Symbols;

resourcestring
  SBadQuotes = 'Unterminated string';
  SUnknownDelimiter = 'Unknown delimiter character: "%s"';
  SErrUnknownCharacter = 'Unknown character at pos %d: "%s"';
  SErrUnexpectedEndOfExpression = 'Unexpected end of expression';
  SErrUnknownComparison = 'Internal error: Unknown comparison';
  SErrUnknownBooleanOp = 'Internal error: Unknown boolean operation';
  SErrBracketExpected = 'Expected ) bracket at position %d, but got %s';
  SerrUnknownTokenAtPos = 'Unknown token at pos %d : %s';
  SErrLeftBracketExpected = 'Expected ( bracket at position %d, but got %s';
  SErrInvalidFloat = '%s is not a valid floating-point value';
  SErrUnknownIdentifier = 'Unknown identifier: %s';
  SErrInExpression = 'Cannot evaluate: error in expression';
  SErrInExpressionEmpty = 'Cannot evaluate: empty expression';
  SErrCommaExpected = 'Expected comma (,) at position %d, but got %s';
  SErrInvalidNumberChar = 'Unexpected character in number : %s';
  SErrInvalidNumber = 'Invalid numerical value : %s';
  SErrNoOperand = 'No operand for unary operation %s';
  SErrNoleftOperand = 'No left operand for binary operation %s';
  SErrNoRightOperand = 'No left operand for binary operation %s';
  SErrNoNegation = 'Cannot negate expression of type %s : %s';
  SErrNoNOTOperation = 'Cannot perform "not" on expression of type %s: %s';
  SErrTypesDoNotMatch = 'Type mismatch: %s<>%s for expressions "%s" and "%s".';
  SErrTypesIncompatible = 'Incompatible types: %s<>%s for expressions "%s" and "%s".';
  SErrNoNodeToCheck = 'Internal error: No node to check !';
  SInvalidNodeType = 'Node type (%s) not in allowed types (%s) for expression: %s';
  SErrUnterminatedExpression =
    'Badly terminated expression. Found token at position %d : %s';
  SErrDuplicateIdentifier = 'An identifier with name "%s" already exists.';
  SErrInvalidResultCharacter = '"%s" is not a valid return type indicator';
  ErrInvalidArgumentCount = 'Invalid argument count for function %s';
  SErrInvalidArgumentType = 'Invalid type for argument %d: Expected %s, got %s';
  SErrInvalidResultType = 'Invalid result type: %s';
  SErrNotVariable = 'Identifier %s is not a variable';
  SErrInactive = 'Operation not allowed while an expression is active';
  SErrIFNeedsBoolean = 'First argument to IF must be of type boolean: %s';
  SErrCaseNeeds3 = 'Case statement needs to have at least 4 arguments';
  SErrCaseEvenCount = 'Case statement needs to have an even number of arguments';
  SErrCaseLabelNotAConst = 'Case label %d "%s" is not a constant expression';
  SErrCaseLabelType = 'Case label %d "%s" needs type %s, but has type %s';
  SErrCaseValueType = 'Case value %d "%s" needs type %s, but has type %s';

{ ---------------------------------------------------------------------
  Auxiliary functions
  ---------------------------------------------------------------------}

procedure RaiseParserError(Msg: string);
begin
  raise EExprParser.Create(Msg);
end;

procedure RaiseParserError(Fmt: string; Args: array of const);
begin
  raise EExprParser.CreateFmt(Fmt, Args);
end;

function TokenName(AToken: TTokenType): string;

begin
  Result := GetEnumName(TypeInfo(TTokenType), Ord(AToken));
end;

function ResultTypeName(AResult: TResultType): string;

begin
  Result := GetEnumName(TypeInfo(TResultType), Ord(AResult));
end;

function CharToResultType(C: char): TResultType;
begin
  case Upcase(C) of
    'S': Result := rtString;
    'D': Result := rtDateTime;
    'B': Result := rtBoolean;
    'I': Result := rtInteger;
    'F': Result := rtFloat;
    else
      RaiseParserError(SErrInvalidResultCharacter, [C]);
  end;
end;

var
  BuiltIns: TExprBuiltInManager;

function BuiltinIdentifiers: TExprBuiltInManager;

begin
  if (BuiltIns = nil) then
    BuiltIns := TExprBuiltInManager.Create(nil);
  Result := BuiltIns;
end;

procedure FreeBuiltIns;

begin
  FreeAndNil(Builtins);
end;

{ ---------------------------------------------------------------------
  TFPExpressionScanner
  ---------------------------------------------------------------------}

function TFPExpressionScanner.IsAlpha(C: char): boolean;
begin
  Result := C in ['A'..'Z', 'a'..'z'];
end;

constructor TFPExpressionScanner.Create;
begin
  Source := '';
end;


procedure TFPExpressionScanner.SetSource(const AValue: string);
begin
  FSource := AValue;
  LSource := Length(FSource);
  FTokenType := ttEOF;
  if LSource = 0 then
    FPos := 0
  else
    FPos := 1;
  FChar := PChar(FSource);
  FToken := '';
end;

function TFPExpressionScanner.NextPos: char;
begin
  Inc(FPos);
  Inc(FChar);
  Result := FChar^;
end;


function TFPExpressionScanner.IsWordDelim(C: char): boolean;
begin
  Result := C in WordDelimiters;
end;

function TFPExpressionScanner.IsDelim(C: char): boolean;
begin
  Result := C in Delimiters;
end;

function TFPExpressionScanner.IsDigit(C: char): boolean;
begin
  Result := C in Digits;
end;

procedure TFPExpressionScanner.SkipWhiteSpace;

begin
  while (FChar^ in WhiteSpace) and (FPos <= LSource) do
    NextPos;
end;

function TFPExpressionScanner.DoDelimiter: TTokenType;

var
  B: boolean;
  C, D: char;

begin
  C := FChar^;
  FToken := C;
  B := C in ['<', '>'];
  D := C;
  C := NextPos;

  if B and (C in ['=', '>']) then
  begin
    FToken := FToken + C;
    NextPos;
    if (D = '>') then
      Result := ttLargerThanEqual
    else if (C = '>') then
      Result := ttUnequal
    else
      Result := ttLessThanEqual;
  end
  else
    case D of
      '+': Result := ttPlus;
      '-': Result := ttMinus;
      '<': Result := ttLessThan;
      '>': Result := ttLargerThan;
      '=': Result := ttEqual;
      '/': Result := ttDiv;
      '*': Result := ttMul;
      '(': Result := ttLeft;
      ')': Result := ttRight;
      ',': Result := ttComma;
      else
        ScanError(Format(SUnknownDelimiter, [D]));
    end;

end;

procedure TFPExpressionScanner.ScanError(Msg: string);

begin
  raise EExprScanner.Create(Msg);
end;

function TFPExpressionScanner.DoString: TTokenType;

  function TerminatingChar(C: char): boolean;

  begin
    Result := (C = cNull) or ((C = cSingleQuote) and not
      ((FPos < LSource) and (FSource[FPos + 1] = cSingleQuote)));
  end;

var
  C: char;

begin
  FToken := '';
  C := NextPos;
  while not TerminatingChar(C) do
  begin
    FToken := FToken + C;
    if C = cSingleQuote then
      NextPos;
    C := NextPos;
  end;
  if (C = cNull) then
    ScanError(SBadQuotes);
  Result := ttString;
  FTokenType := Result;
  NextPos;
end;

function TFPExpressionScanner.GetCurrentChar: char;
begin
  if FChar <> nil then
    Result := FChar^
  else
    Result := #0;
end;

function TFPExpressionScanner.DoNumber: TTokenType;

var
  C: char;
  X: TExprFloat;
  I: integer;
  prevC: char;

begin
  C := CurrentChar;
  prevC := #0;
  while (not IsWordDelim(C) or (prevC = 'E')) and (C <> cNull) do
  begin
    if not (IsDigit(C) or ((FToken <> '') and (Upcase(C) = 'E')) or
      ((FToken <> '') and (C in ['+', '-']) and (prevC = 'E'))) then
      ScanError(Format(SErrInvalidNumberChar, [C]));
    FToken := FToken + C;
    prevC := Upcase(C);
    C := NextPos;
  end;
  Val(FToken, X, I);
  if (I <> 0) then
    ScanError(Format(SErrInvalidNumber, [FToken]));
  Result := ttNumber;
end;

function TFPExpressionScanner.DoIdentifier: TTokenType;

var
  C: char;
  S: string;
begin
  C := CurrentChar;
  while (not IsWordDelim(C)) and (C <> cNull) do
  begin
    FToken := FToken + C;
    C := NextPos;
  end;
  S := LowerCase(Token);
  if (S = 'or') then
    Result := ttOr
  else if (S = 'xor') then
    Result := ttXOr
  else if (S = 'and') then
    Result := ttAnd
  else if (S = 'true') then
    Result := ttTrue
  else if (S = 'false') then
    Result := ttFalse
  else if (S = 'not') then
    Result := ttnot
  else if (S = 'if') then
    Result := ttif
  else if (S = 'case') then
    Result := ttcase
  else
    Result := ttIdentifier;
end;

function TFPExpressionScanner.GetToken: TTokenType;

var
  C: char;

begin
  FToken := '';
  SkipWhiteSpace;
  C := FChar^;
  if c = cNull then
    Result := ttEOF
  else if IsDelim(C) then
    Result := DoDelimiter
  else if (C = cSingleQuote) then
    Result := DoString
  else if IsDigit(C) then
    Result := DoNumber
  else if IsAlpha(C) then
    Result := DoIdentifier
  else
    ScanError(Format(SErrUnknownCharacter, [FPos, C]));
  FTokenType := Result;
end;

{ ---------------------------------------------------------------------
  TFPExpressionParser
  ---------------------------------------------------------------------}

function TFPExpressionParser.TokenType: TTokenType;

begin
  Result := FScanner.TokenType;
end;

function TFPExpressionParser.CurrentToken: string;
begin
  Result := FScanner.Token;
end;

procedure TFPExpressionParser.CreateHashList;

var
  ID: TFPExpridentifierDef;
  BID: TFPBuiltinExpridentifierDef;
  I: integer;
  M: TExprBuiltinManager;

begin
  FHashList.Clear;
  // Builtins
  M := BuiltinsManager;
  if (FBuiltins <> []) and Assigned(M) then
    for I := 0 to M.IdentifierCount - 1 do
    begin
      BID := M.Identifiers[I];
      if BID.Category in FBuiltins then
        FHashList.Add(LowerCase(BID.Name), BID);
    end;
  // User
  for I := 0 to FIdentifiers.Count - 1 do
  begin
    ID := FIdentifiers[i];
    FHashList.Add(LowerCase(ID.Name), ID);
  end;
  FDirty := False;
end;

function TFPExpressionParser.IdentifierByName(AName: ShortString): TFPExprIdentifierDef;
begin
  if FDirty then
    CreateHashList;
  Result := TFPExprIdentifierDef(FHashList.Find(LowerCase(AName)));
end;

procedure TFPExpressionParser.Clear;
begin
  FExpression := '';
  FHashList.Clear;
  FExprNode.Free;
end;

constructor TFPExpressionParser.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FIdentifiers := TFPExprIdentifierDefs.Create(TFPExprIdentifierDef);
  FIdentifiers.FParser := Self;
  FScanner := TFPExpressionScanner.Create;
  FHashList := TFPHashObjectList.Create(False);
end;

destructor TFPExpressionParser.Destroy;
begin
  FreeAndNil(FHashList);
  FreeAndNil(FExprNode);
  FreeAndNil(FIdentifiers);
  FreeAndNil(FScanner);
  inherited Destroy;
end;

function TFPExpressionParser.GetToken: TTokenType;

begin
  Result := FScanner.GetToken;
end;

procedure TFPExpressionParser.CheckEOF;

begin
  if (TokenType = ttEOF) then
    ParserError(SErrUnexpectedEndOfExpression);
end;

procedure TFPExpressionParser.SetIdentifiers(const AValue: TFPExprIdentifierDefs);
begin
  FIdentifiers.Assign(AValue);
end;

procedure TFPExpressionParser.EvaluateExpression(var Result: TFPExpressionResult);
begin
  if (FExpression = '') then
    ParserError(SErrInExpressionEmpty);
  if not Assigned(FExprNode) then
    ParserError(SErrInExpression);
  FExprNode.GetNodeValue(Result);
end;

procedure TFPExpressionParser.ParserError(Msg: string);
begin
  raise EExprParser.Create(Msg);
end;

function TFPExpressionParser.ConvertNode(Todo: TFPExprNode;
  ToType: TResultType): TFPExprNode;

begin
  Result := ToDo;
  case ToDo.NodeType of
    rtInteger:
      case ToType of
        rtFloat: Result := TIntToFloatNode.Create(Result);
        rtDateTime: Result := TIntToDateTimeNode.Create(Result);
      end;
    rtFloat:
      case ToType of
        rtDateTime: Result := TFloatToDateTimeNode.Create(Result);
      end;
  end;
end;

function TFPExpressionParser.GetAsBoolean: boolean;

var
  Res: TFPExpressionResult;

begin
  EvaluateExpression(Res);
  CheckResultType(Res, rtBoolean);
  Result := Res.ResBoolean;
end;

function TFPExpressionParser.GetAsDateTime: TDateTime;
var
  Res: TFPExpressionResult;

begin
  EvaluateExpression(Res);
  CheckResultType(Res, rtDateTime);
  Result := Res.ResDatetime;
end;

function TFPExpressionParser.GetAsFloat: TExprFloat;

var
  Res: TFPExpressionResult;

begin
  EvaluateExpression(Res);
  CheckResultType(Res, rtFloat);
  Result := Res.ResFloat;
end;

function TFPExpressionParser.GetAsInteger: int64;

var
  Res: TFPExpressionResult;

begin
  EvaluateExpression(Res);
  CheckResultType(Res, rtInteger);
  Result := Res.ResInteger;
end;

function TFPExpressionParser.GetAsString: string;

var
  Res: TFPExpressionResult;

begin
  EvaluateExpression(Res);
  CheckResultType(Res, rtString);
  Result := Res.ResString;
end;

{
  Checks types of todo and match. If ToDO can be converted to it matches
  the type of match, then a node is inserted.
  For binary operations, this function is called for both operands.
}

function TFPExpressionParser.MatchNodes(Todo, Match: TFPExprNode): TFPExprNode;

var
  TT, MT: TResultType;

begin
  Result := Todo;
  TT := Todo.NodeType;
  MT := Match.NodeType;
  if (TT <> MT) then
  begin
    if (TT = rtInteger) then
    begin
      if (MT in [rtFloat, rtDateTime]) then
        Result := ConvertNode(Todo, MT);
    end
    else if (TT = rtFloat) then
    begin
      if (MT = rtDateTime) then
        Result := ConvertNode(Todo, rtDateTime);
    end;
  end;
end;

{
  if the result types differ, they are converted to a common type if possible.
}

procedure TFPExpressionParser.CheckNodes(var Left, Right: TFPExprNode);

begin
  Left := MatchNodes(Left, Right);
  Right := MatchNodes(Right, Left);
end;

procedure TFPExpressionParser.SetBuiltIns(const AValue: TBuiltInCategories);
begin
  if FBuiltIns = AValue then
    exit;
  FBuiltIns := AValue;
  FDirty := True;
end;

function TFPExpressionParser.Level1: TFPExprNode;

var
  tt: TTokenType;
  Right: TFPExprNode;

begin
{$ifdef debugexpr}
  Writeln('Level 1 ', TokenName(TokenType), ': ', CurrentToken);
{$endif debugexpr}
  if TokenType = ttNot then
  begin
    GetToken;
    CheckEOF;
    Right := Level2;
    Result := TFPNotNode.Create(Right);
  end
  else
    Result := Level2;
  try
    while (TokenType in [ttAnd, ttOr, ttXor]) do
    begin
      tt := TokenType;
      GetToken;
      CheckEOF;
      Right := Level2;
      case tt of
        ttOr: Result := TFPBinaryOrOperation.Create(Result, Right);
        ttAnd: Result := TFPBinaryAndOperation.Create(Result, Right);
        ttXor: Result := TFPBinaryXorOperation.Create(Result, Right);
        else
          ParserError(SErrUnknownBooleanOp)
      end;
    end;
  except
    Result.Free;
    raise;
  end;
end;

function TFPExpressionParser.Level2: TFPExprNode;

var
  Right: TFPExprNode;
  tt: TTokenType;
  C: TFPBinaryOperationClass;

begin
{$ifdef debugexpr}
  Writeln('Level 2 ', TokenName(TokenType), ': ', CurrentToken);
{$endif debugexpr}
  Result := Level3;
  try
    if (TokenType in ttComparisons) then
    begin
      tt := TokenType;
      GetToken;
      CheckEOF;
      Right := Level3;
      CheckNodes(Result, Right);
      case tt of
        ttLessthan: C := TFPLessThanOperation;
        ttLessthanEqual: C := TFPLessThanEqualOperation;
        ttLargerThan: C := TFPGreaterThanOperation;
        ttLargerThanEqual: C := TFPGreaterThanEqualOperation;
        ttEqual: C := TFPEqualOperation;
        ttUnequal: C := TFPUnequalOperation;
        else
          ParserError(SErrUnknownComparison)
      end;
      Result := C.Create(Result, Right);
    end;
  except
    Result.Free;
    raise;
  end;
end;

function TFPExpressionParser.Level3: TFPExprNode;

var
  tt: TTokenType;
  right: TFPExprNode;

begin
{$ifdef debugexpr}
  Writeln('Level 3 ', TokenName(TokenType), ': ', CurrentToken);
{$endif debugexpr}
  Result := Level4;
  try
    while TokenType in [ttPlus, ttMinus] do
    begin
      tt := TokenType;
      GetToken;
      CheckEOF;
      Right := Level4;
      CheckNodes(Result, Right);
      case tt of
        ttPlus: Result := TFPAddOperation.Create(Result, Right);
        ttMinus: Result := TFPSubtractOperation.Create(Result, Right);
      end;
    end;
  except
    Result.Free;
    raise;
  end;
end;




function TFPExpressionParser.Level4: TFPExprNode;

var
  tt: TTokenType;
  right: TFPExprNode;

begin
{$ifdef debugexpr}
  Writeln('Level 4 ', TokenName(TokenType), ': ', CurrentToken);
{$endif debugexpr}
  Result := Level5;
  try
    while (TokenType in [ttMul, ttDiv]) do
    begin
      tt := TokenType;
      GetToken;
      Right := Level5;
      CheckNodes(Result, Right);
      case tt of
        ttMul: Result := TFPMultiplyOperation.Create(Result, Right);
        ttDiv: Result := TFPDivideOperation.Create(Result, Right);
      end;
    end;
  except
    Result.Free;
    raise;
  end;
end;

function TFPExpressionParser.Level5: TFPExprNode;

var
  B: boolean;

begin
{$ifdef debugexpr}
  Writeln('Level 5 ', TokenName(TokenType), ': ', CurrentToken);
{$endif debugexpr}
  B := False;
  if (TokenType in [ttPlus, ttMinus]) then
  begin
    B := TokenType = ttMinus;
    GetToken;
  end;
  Result := Level6;
  if B then
    Result := TFPNegateOperation.Create(Result);
end;

function TFPExpressionParser.Level6: TFPExprNode;
begin
{$ifdef debugexpr}
  Writeln('Level 6 ', TokenName(TokenType), ': ', CurrentToken);
{$endif debugexpr}
  if (TokenType = ttLeft) then
  begin
    GetToken;
    Result := Level1;
    try
      if (TokenType <> ttRight) then
        ParserError(Format(SErrBracketExpected, [SCanner.Pos, CurrentToken]));
      GetToken;
    except
      Result.Free;
      raise;
    end;
  end
  else
    Result := Primitive;
end;

function TFPExpressionParser.Primitive: TFPExprNode;

var
  I: int64;
  C: integer;
  X: TExprFloat;
  ACount: integer;
  IFF: boolean;
  IFC: boolean;
  ID: TFPExprIdentifierDef;
  Args: TExprArgumentArray;
  AI: integer;

begin
{$ifdef debugexpr}
  Writeln('Primitive : ', TokenName(TokenType), ': ', CurrentToken);
{$endif debugexpr}
  SetLength(Args, 0);
  if (TokenType = ttNumber) then
  begin
    if TryStrToInt64(CurrentToken, I) then
      Result := TFPConstExpression.CreateInteger(I)
    else
    begin
      Val(CurrentToken, X, C);
      if (I = 0) then
        Result := TFPConstExpression.CreateFloat(X)
      else
        ParserError(Format(SErrInvalidFloat, [CurrentToken]));
    end;
  end
  else if (TokenType = ttString) then
    Result := TFPConstExpression.CreateString(CurrentToken)
  else if (TokenType in [ttTrue, ttFalse]) then
    Result := TFPConstExpression.CreateBoolean(TokenType = ttTrue)
  else if not (TokenType in [ttIdentifier, ttIf, ttcase]) then
    ParserError(Format(SerrUnknownTokenAtPos, [Scanner.Pos, CurrentToken]))
  else
  begin
    IFF := TokenType = ttIf;
    IFC := TokenType = ttCase;
    if not (IFF or IFC) then
    begin
      ID := self.IdentifierByName(CurrentToken);
// rch aqui si ID es NIL tengo que probar llamar a una función
// de resolución grid_val( ID )
      if (ID = nil) then
      begin
        ParserError(Format(SErrUnknownIdentifier, [CurrentToken]));
      end;
    end;

    // Determine number of arguments
    if Iff then
      ACount := 3
    else if IfC then
      ACount := -4
    else if (ID.IdentifierType in [itFunctionCallBack, itFunctionHandler]) then
      ACount := ID.ArgumentCount
    else
      ACount := 0;
    // Parse arguments.
    // Negative is for variable number of arguments, where Abs(value) is the minimum number of arguments
    if (ACount <> 0) then
    begin
      GetToken;
      if (TokenType <> ttLeft) then
        ParserError(Format(SErrLeftBracketExpected, [Scanner.Pos, CurrentToken]));
      SetLength(Args, Abs(ACount));
      AI := 0;
      try
        repeat
          GetToken;
          // Check if we must enlarge the argument array
          if (ACount < 0) and (AI = Length(Args)) then
          begin
            SetLength(Args, AI + 1);
            Args[AI] := nil;
          end;
          Args[AI] := Level1;
          Inc(AI);
          if (TokenType <> ttComma) then
            if (AI < Abs(ACount)) then
              ParserError(Format(SErrCommaExpected, [Scanner.Pos, CurrentToken]))
        until (AI = ACount) or ((ACount < 0) and (TokenType = ttRight));
        if TokenType <> ttRight then
          ParserError(Format(SErrBracketExpected, [Scanner.Pos, CurrentToken]));
      except
        On E: Exception do
        begin
          Dec(AI);
          while (AI >= 0) do
          begin
            FreeAndNil(Args[Ai]);
            Dec(AI);
          end;
          raise;
        end;
      end;
    end;
    if Iff then
      Result := TIfOperation.Create(Args[0], Args[1], Args[2])
    else if IfC then
      Result := TCaseOperation.Create(Args)
    else
      case ID.IdentifierType of
        itVariable: Result := TFPExprVariable.CreateIdentifier(ID);
        itFunctionCallBack: Result := TFPFunctionCallback.CreateFunction(ID, Args);
        itFunctionHandler: Result := TFPFunctionEventHandler.CreateFunction(ID, Args);
      end;
  end;
  GetToken;
end;


procedure TFPExpressionParser.SetExpression(const AValue: string);
begin
  if FExpression = AValue then
    exit;
  FExpression := AValue;
  FScanner.Source := AValue;
  if Assigned(FExprNode) then
    FreeAndNil(FExprNode);
  if (FExpression <> '') then
  begin
    GetToken;
    FExprNode := Level1;
    if (TokenType <> ttEOF) then
      ParserError(Format(SErrUnterminatedExpression, [Scanner.Pos, CurrentToken]));
    FExprNode.Check;
  end
  else
    FExprNode := nil;
end;

procedure TFPExpressionParser.CheckResultType(const Res: TFPExpressionResult;
  AType: TResultType); inline;
begin
  if (Res.ResultType <> AType) then
    RaiseParserError(SErrInvalidResultType, [ResultTypeName(Res.ResultType)]);
end;

class function TFPExpressionParser.BuiltinsManager: TExprBuiltInManager;
begin
  Result := BuiltinIdentifiers;
end;


function TFPExpressionParser.Evaluate: TFPExpressionResult;
begin
  EvaluateExpression(Result);
end;

function TFPExpressionParser.ResultType: TResultType;
begin
  if not Assigned(FExprNode) then
    ParserError(SErrInExpression);
  Result := FExprNode.NodeType;
  ;
end;

{ ---------------------------------------------------------------------
  TFPExprIdentifierDefs
  ---------------------------------------------------------------------}

function TFPExprIdentifierDefs.GetI(AIndex: integer): TFPExprIdentifierDef;
begin
  Result := TFPExprIdentifierDef(Items[AIndex]);
end;

procedure TFPExprIdentifierDefs.SetI(AIndex: integer;
  const AValue: TFPExprIdentifierDef);
begin
  Items[AIndex] := AValue;
end;

procedure TFPExprIdentifierDefs.Update(Item: TCollectionItem);
begin
  if Assigned(FParser) then
    FParser.FDirty := True;
end;

function TFPExprIdentifierDefs.IndexOfIdentifier(const AName: ShortString): integer;
begin
  Result := Count - 1;
  while (Result >= 0) and (CompareText(GetI(Result).Name, AName) <> 0) do
    Dec(Result);
end;

function TFPExprIdentifierDefs.FindIdentifier(
  const AName: ShortString): TFPExprIdentifierDef;

var
  I: integer;

begin
  I := IndexOfIdentifier(AName);
  if (I = -1) then
    Result := nil
  else
    Result := GetI(I);
end;

function TFPExprIdentifierDefs.IdentifierByName(
  const AName: ShortString): TFPExprIdentifierDef;
begin
  Result := FindIdentifier(AName);
  if (Result = nil) then
  begin
    RaiseParserError(SErrUnknownIdentifier, [AName]);
  end;
end;

function TFPExprIdentifierDefs.AddVariable(const AName: ShortString;
  AResultType: TResultType; AValue: string): TFPExprIdentifierDef;
begin
  Result := Add as TFPExprIdentifierDef;
  Result.IdentifierType := itVariable;
  Result.Name := AName;
  Result.ResultType := AResultType;
  Result.Value := AValue;
end;

function TFPExprIdentifierDefs.AddBooleanVariable(const AName: ShortString;
  AValue: boolean): TFPExprIdentifierDef;
begin
  Result := Add as TFPExprIdentifierDef;
  Result.IdentifierType := itVariable;
  Result.Name := AName;
  Result.ResultType := rtBoolean;
  Result.FValue.ResBoolean := AValue;
end;

function TFPExprIdentifierDefs.AddIntegerVariable(const AName: ShortString;
  AValue: integer): TFPExprIdentifierDef;
begin
  Result := Add as TFPExprIdentifierDef;
  Result.IdentifierType := itVariable;
  Result.Name := AName;
  Result.ResultType := rtInteger;
  Result.FValue.ResInteger := AValue;
end;

function TFPExprIdentifierDefs.AddFloatVariable(const AName: ShortString;
  AValue: TExprFloat): TFPExprIdentifierDef;
begin
  Result := Add as TFPExprIdentifierDef;
  Result.IdentifierType := itVariable;
  Result.Name := AName;
  Result.ResultType := rtFloat;
  Result.FValue.ResFloat := AValue;
end;

function TFPExprIdentifierDefs.AddStringVariable(const AName: ShortString;
  AValue: string): TFPExprIdentifierDef;
begin
  Result := Add as TFPExprIdentifierDef;
  Result.IdentifierType := itVariable;
  Result.Name := AName;
  Result.ResultType := rtString;
  Result.FValue.ResString := AValue;
end;

function TFPExprIdentifierDefs.AddDateTimeVariable(const AName: ShortString;
  AValue: TDateTime): TFPExprIdentifierDef;
begin
  Result := Add as TFPExprIdentifierDef;
  Result.IdentifierType := itVariable;
  Result.Name := AName;
  Result.ResultType := rtDateTime;
  Result.FValue.ResDateTime := AValue;
end;

function TFPExprIdentifierDefs.AddFunction(const AName: ShortString;
  const AResultType: char; const AParamTypes: string;
  ACallBack: TFPExprFunctionCallBack): TFPExprIdentifierDef;
begin
  Result := Add as TFPExprIdentifierDef;
  Result.Name := Aname;
  Result.IdentifierType := itFunctionCallBack;
  Result.ParameterTypes := AParamTypes;
  Result.ResultType := CharToResultType(AResultType);
  Result.FOnGetValueCB := ACallBack;
end;

function TFPExprIdentifierDefs.AddFunction(const AName: ShortString;
  const AResultType: char; const AParamTypes: string;
  ACallBack: TFPExprFunctionEvent): TFPExprIdentifierDef;
begin
  Result := Add as TFPExprIdentifierDef;
  Result.Name := Aname;
  Result.IdentifierType := itFunctionHandler;
  Result.ParameterTypes := AParamTypes;
  Result.ResultType := CharToResultType(AResultType);
  Result.FOnGetValue := ACallBack;
end;

{ ---------------------------------------------------------------------
  TFPExprIdentifierDef
  ---------------------------------------------------------------------}

procedure TFPExprIdentifierDef.SetName(const AValue: ShortString);
begin
  if FName = AValue then
    exit;
  if (AValue <> '') then
    if Assigned(Collection) and
      (TFPExprIdentifierDefs(Collection).IndexOfIdentifier(AValue) <> -1) then
      RaiseParserError(SErrDuplicateIdentifier, [AValue]);
  FName := AValue;
end;

procedure TFPExprIdentifierDef.SetResultType(const AValue: TResultType);

begin
  if AValue <> FValue.ResultType then
  begin
    FValue.ResultType := AValue;
    SetValue(FStringValue);
  end;
end;

procedure TFPExprIdentifierDef.SetValue(const AValue: string);
begin
  FStringValue := AValue;
  if (AValue <> '') then
    case FValue.ResultType of
      rtBoolean: FValue.ResBoolean := FStringValue = 'True';
      rtInteger: FValue.ResInteger := StrToInt(AValue);
      rtFloat: FValue.ResFloat := StrToFloat(AValue);
      rtDateTime: FValue.ResDateTime := StrToDateTime(AValue);
      rtString: FValue.ResString := AValue;
    end
  else
    case FValue.ResultType of
      rtBoolean: FValue.ResBoolean := False;
      rtInteger: FValue.ResInteger := 0;
      rtFloat: FValue.ResFloat := 0.0;
      rtDateTime: FValue.ResDateTime := 0;
      rtString: FValue.ResString := '';
    end;
end;

procedure TFPExprIdentifierDef.CheckResultType(const AType: TResultType);
begin
  if FValue.ResultType <> AType then
    RaiseParserError(SErrInvalidResultType, [ResultTypeName(AType)]);
end;

procedure TFPExprIdentifierDef.CheckVariable;
begin
  if Identifiertype <> itvariable then
    RaiseParserError(SErrNotVariable, [Name]);
end;

function TFPExprIdentifierDef.ArgumentCount: integer;
begin
  Result := Length(FArgumentTypes);
end;

procedure TFPExprIdentifierDef.Assign(Source: TPersistent);

var
  EID: TFPExprIdentifierDef;

begin
  if (Source is TFPExprIdentifierDef) then
  begin
    EID := Source as TFPExprIdentifierDef;
    FStringValue := EID.FStringValue;
    FValue := EID.FValue;
    FArgumentTypes := EID.FArgumentTypes;
    FIDType := EID.FIDType;
    FName := EID.FName;
    FOnGetValue := EID.FOnGetValue;
    FOnGetValueCB := EID.FOnGetValueCB;
  end
  else
    inherited Assign(Source);
end;

procedure TFPExprIdentifierDef.SetArgumentTypes(const AValue: string);

var
  I: integer;

begin
  if FArgumentTypes = AValue then
    exit;
  for I := 1 to Length(AValue) do
    CharToResultType(AValue[i]);
  FArgumentTypes := AValue;
end;

procedure TFPExprIdentifierDef.SetAsBoolean(const AValue: boolean);
begin
  CheckVariable;
  CheckResultType(rtBoolean);
  FValue.ResBoolean := AValue;
end;

procedure TFPExprIdentifierDef.SetAsDateTime(const AValue: TDateTime);
begin
  CheckVariable;
  CheckResultType(rtDateTime);
  FValue.ResDateTime := AValue;
end;

procedure TFPExprIdentifierDef.SetAsFloat(const AValue: TExprFloat);
begin
  CheckVariable;
  CheckResultType(rtFloat);
  FValue.ResFloat := AValue;
end;

procedure TFPExprIdentifierDef.SetAsInteger(const AValue: int64);
begin
  CheckVariable;
  CheckResultType(rtInteger);
  FValue.ResInteger := AValue;
end;

procedure TFPExprIdentifierDef.SetAsString(const AValue: string);
begin
  CheckVariable;
  CheckResultType(rtString);
  FValue.resString := AValue;
end;

function TFPExprIdentifierDef.GetValue: string;
begin
  case FValue.ResultType of
    rtBoolean: if FValue.ResBoolean then
        Result := 'True'
      else
        Result := 'False';
    rtInteger: Result := IntToStr(FValue.ResInteger);
    rtFloat: Result := FloatToStr(FValue.ResFloat);
    rtDateTime: Result := FormatDateTime('cccc', FValue.ResDateTime);
    rtString: Result := FValue.ResString;
  end;
end;

function TFPExprIdentifierDef.GetResultType: TResultType;
begin
  Result := FValue.ResultType;
end;

function TFPExprIdentifierDef.GetAsFloat: TExprFloat;
begin
  CheckResultType(rtFloat);
  CheckVariable;
  Result := FValue.ResFloat;
end;

function TFPExprIdentifierDef.GetAsBoolean: boolean;
begin
  CheckResultType(rtBoolean);
  CheckVariable;
  Result := FValue.ResBoolean;
end;

function TFPExprIdentifierDef.GetAsDateTime: TDateTime;
begin
  CheckResultType(rtDateTime);
  CheckVariable;
  Result := FValue.ResDateTime;
end;

function TFPExprIdentifierDef.GetAsInteger: int64;
begin
  CheckResultType(rtInteger);
  CheckVariable;
  Result := FValue.ResInteger;
end;

function TFPExprIdentifierDef.GetAsString: string;
begin
  CheckResultType(rtString);
  CheckVariable;
  Result := FValue.ResString;
end;

{ ---------------------------------------------------------------------
  TExprBuiltInManager
  ---------------------------------------------------------------------}

function TExprBuiltInManager.GetCount: integer;
begin
  Result := FDefs.Count;
end;

function TExprBuiltInManager.GetI(AIndex: integer): TFPBuiltInExprIdentifierDef;
begin
  Result := TFPBuiltInExprIdentifierDef(FDefs[Aindex]);
end;

constructor TExprBuiltInManager.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDefs := TFPExprIdentifierDefs.Create(TFPBuiltInExprIdentifierDef);
end;

destructor TExprBuiltInManager.Destroy;
begin
  FreeAndNil(FDefs);
  inherited Destroy;
end;

function TExprBuiltInManager.IndexOfIdentifier(const AName: ShortString): integer;
begin
  Result := FDefs.IndexOfIdentifier(AName);
end;

function TExprBuiltInManager.FindIdentifier(
  const AName: ShortString): TFPBuiltinExprIdentifierDef;
begin
  Result := TFPBuiltinExprIdentifierDef(FDefs.FindIdentifier(AName));
end;

function TExprBuiltInManager.IdentifierByName(
  const AName: ShortString): TFPBuiltinExprIdentifierDef;
begin
  Result := TFPBuiltinExprIdentifierDef(FDefs.IdentifierByName(AName));
end;

function TExprBuiltInManager.AddVariable(const ACategory: TBuiltInCategory;
  const AName: ShortString; AResultType: TResultType;
  AValue: string): TFPBuiltInExprIdentifierDef;
begin
  Result := TFPBuiltInExprIdentifierDef(FDefs.Addvariable(AName, AResultType, AValue));
  Result.Category := ACategory;
end;

function TExprBuiltInManager.AddBooleanVariable(const ACategory: TBuiltInCategory;
  const AName: ShortString; AValue: boolean): TFPBuiltInExprIdentifierDef;
begin
  Result := TFPBuiltInExprIdentifierDef(FDefs.AddBooleanvariable(AName, AValue));
  Result.Category := ACategory;
end;

function TExprBuiltInManager.AddIntegerVariable(const ACategory: TBuiltInCategory;
  const AName: ShortString; AValue: integer): TFPBuiltInExprIdentifierDef;
begin
  Result := TFPBuiltInExprIdentifierDef(FDefs.AddIntegerVariable(AName, AValue));
  Result.Category := ACategory;
end;

function TExprBuiltInManager.AddFloatVariable(const ACategory: TBuiltInCategory;
  const AName: ShortString; AValue: TExprFloat): TFPBuiltInExprIdentifierDef;
begin
  Result := TFPBuiltInExprIdentifierDef(FDefs.AddFloatVariable(AName, AValue));
  Result.Category := ACategory;
end;

function TExprBuiltInManager.AddStringVariable(const ACategory: TBuiltInCategory;
  const AName: ShortString; AValue: string): TFPBuiltInExprIdentifierDef;
begin
  Result := TFPBuiltInExprIdentifierDef(FDefs.AddStringVariable(AName, AValue));
  Result.Category := ACategory;
end;

function TExprBuiltInManager.AddDateTimeVariable(const ACategory: TBuiltInCategory;
  const AName: ShortString; AValue: TDateTime): TFPBuiltInExprIdentifierDef;
begin
  Result := TFPBuiltInExprIdentifierDef(FDefs.AddDateTimeVariable(AName, AValue));
  Result.Category := ACategory;
end;

function TExprBuiltInManager.AddFunction(const ACategory: TBuiltInCategory;
  const AName: ShortString; const AResultType: char; const AParamTypes: string;
  ACallBack: TFPExprFunctionCallBack): TFPBuiltInExprIdentifierDef;
begin
  Result := TFPBuiltInExprIdentifierDef(FDefs.AddFunction(
    AName, AResultType, AParamTypes, ACallBack));
  Result.Category := ACategory;
end;

function TExprBuiltInManager.AddFunction(const ACategory: TBuiltInCategory;
  const AName: ShortString; const AResultType: char; const AParamTypes: string;
  ACallBack: TFPExprFunctionEvent): TFPBuiltInExprIdentifierDef;
begin
  Result := TFPBuiltInExprIdentifierDef(FDefs.AddFunction(
    AName, AResultType, AParamTypes, ACallBack));
  Result.Category := ACategory;
end;


{ ---------------------------------------------------------------------
  Various Nodes
  ---------------------------------------------------------------------}

{ TFPBinaryOperation }

procedure TFPBinaryOperation.CheckSameNodeTypes;

var
  LT, RT: TResultType;

begin
  LT := Left.NodeType;
  RT := Right.NodeType;
  if (RT <> LT) then
    RaiseParserError(SErrTypesDoNotMatch, [ResultTypeName(LT),
      ResultTypeName(RT), Left.AsString, Right.AsString]);
end;

constructor TFPBinaryOperation.Create(ALeft, ARight: TFPExprNode);
begin
  FLeft := ALeft;
  FRight := ARight;
end;

destructor TFPBinaryOperation.Destroy;
begin
  FreeAndNil(FLeft);
  FreeAndNil(FRight);
  inherited Destroy;
end;

procedure TFPBinaryOperation.Check;
begin
  if not Assigned(Left) then
    RaiseParserError(SErrNoLeftOperand, [ClassName]);
  if not Assigned(Right) then
    RaiseParserError(SErrNoRightOperand, [ClassName]);
end;

{ TFPUnaryOperator }

constructor TFPUnaryOperator.Create(AOperand: TFPExprNode);
begin
  FOperand := AOperand;
end;

destructor TFPUnaryOperator.Destroy;
begin
  FreeAndNil(FOperand);
  inherited Destroy;
end;

procedure TFPUnaryOperator.Check;
begin
  if not Assigned(Operand) then
    RaiseParserError(SErrNoOperand, [Self.ClassName]);
end;

{ TFPConstExpression }

constructor TFPConstExpression.CreateString(AValue: string);
begin
  FValue.ResultType := rtString;
  FValue.ResString := AValue;
end;

constructor TFPConstExpression.CreateInteger(AValue: int64);
begin
  FValue.ResultType := rtInteger;
  FValue.ResInteger := AValue;
end;

constructor TFPConstExpression.CreateDateTime(AValue: TDateTime);
begin
  FValue.ResultType := rtDateTime;
  FValue.ResDateTime := AValue;
end;

constructor TFPConstExpression.CreateFloat(AValue: TExprFloat);
begin
  inherited Create;
  FValue.ResultType := rtFloat;
  FValue.ResFloat := AValue;
end;

constructor TFPConstExpression.CreateBoolean(AValue: boolean);
begin
  FValue.ResultType := rtBoolean;
  FValue.ResBoolean := AValue;
end;

procedure TFPConstExpression.Check;
begin
  // Nothing to check;
end;

function TFPConstExpression.NodeType: TResultType;
begin
  Result := FValue.ResultType;
end;

procedure TFPConstExpression.GetNodeValue(var Result: TFPExpressionResult);
begin
  Result := FValue;
end;

function TFPConstExpression.AsString: string;
begin
  case NodeType of
    rtString: Result := '''' + FValue.resString + '''';
    rtInteger: Result := IntToStr(FValue.resInteger);
    rtDateTime: Result := '''' + FormatDateTime('cccc', FValue.resDateTime) + '''';
    rtBoolean: if FValue.ResBoolean then
        Result := 'True'
      else
        Result := 'False';
    rtFloat: Str(FValue.ResFloat, Result);
  end;
end;


{ TFPNegateOperation }

procedure TFPNegateOperation.Check;
begin
  inherited;
  if not (Operand.NodeType in [rtInteger, rtFloat]) then
    RaiseParserError(SErrNoNegation, [ResultTypeName(Operand.NodeType), Operand.AsString]);
end;

function TFPNegateOperation.NodeType: TResultType;
begin
  Result := Operand.NodeType;
end;

procedure TFPNegateOperation.GetNodeValue(var Result: TFPExpressionResult);
begin
  Operand.GetNodeValue(Result);
  case Result.ResultType of
    rtInteger: Result.resInteger := -Result.ResInteger;
    rtFloat: Result.resFloat := -Result.ResFloat;
  end;
end;

function TFPNegateOperation.AsString: string;
begin
  Result := '-' + TrimLeft(Operand.AsString);
end;

{ TFPBinaryAndOperation }

procedure TFPBooleanOperation.Check;
begin
  inherited Check;
  CheckNodeType(Left, [rtInteger, rtBoolean]);
  CheckNodeType(Right, [rtInteger, rtBoolean]);
  CheckSameNodeTypes;
end;

function TFPBooleanOperation.NodeType: TResultType;
begin
  Result := Left.NodeType;
end;

procedure TFPBinaryAndOperation.GetNodeValue(var Result: TFPExpressionResult);

var
  RRes: TFPExpressionResult;

begin
  Left.GetNodeValue(Result);
  Right.GetNodeValue(RRes);
  case Result.ResultType of
    rtBoolean: Result.resBoolean := Result.ResBoolean and RRes.ResBoolean;
    rtInteger: Result.resInteger := Result.ResInteger and RRes.ResInteger;
  end;
end;

function TFPBinaryAndOperation.AsString: string;
begin
  Result := Left.AsString + ' and ' + Right.AsString;
end;

{ TFPExprNode }

procedure TFPExprNode.CheckNodeType(Anode: TFPExprNode; Allowed: TResultTypes);

var
  S: string;
  A: TResultType;

begin
  if (Anode = nil) then
    RaiseParserError(SErrNoNodeToCheck);
  if not (ANode.NodeType in Allowed) then
  begin
    S := '';
    for A := Low(TResultType) to High(TResultType) do
      if A in Allowed then
      begin
        if S <> '' then
          S := S + ',';
        S := S + ResultTypeName(A);
      end;
    RaiseParserError(SInvalidNodeType, [ResultTypeName(ANode.NodeType), S, ANode.AsString]);
  end;
end;

function TFPExprNode.NodeValue: TFPExpressionResult;
begin
  GetNodeValue(Result);
end;

{ TFPBinaryOrOperation }

function TFPBinaryOrOperation.AsString: string;
begin
  Result := Left.AsString + ' or ' + Right.AsString;
end;

procedure TFPBinaryOrOperation.GetNodeValue(var Result: TFPExpressionResult);

var
  RRes: TFPExpressionResult;

begin
  Left.GetNodeValue(Result);
  Right.GetNodeValue(RRes);
  case Result.ResultType of
    rtBoolean: Result.resBoolean := Result.ResBoolean or RRes.ResBoolean;
    rtInteger: Result.resInteger := Result.ResInteger or RRes.ResInteger;
  end;
end;

{ TFPBinaryXOrOperation }

function TFPBinaryXOrOperation.AsString: string;
begin
  Result := Left.AsString + ' xor ' + Right.AsString;
end;

procedure TFPBinaryXOrOperation.GetNodeValue(var Result: TFPExpressionResult);
var
  RRes: TFPExpressionResult;

begin
  Left.GetNodeValue(Result);
  Right.GetNodeValue(RRes);
  case Result.ResultType of
    rtBoolean: Result.resBoolean := Result.ResBoolean xor RRes.ResBoolean;
    rtInteger: Result.resInteger := Result.ResInteger xor RRes.ResInteger;
  end;
end;

{ TFPNotNode }

procedure TFPNotNode.Check;
begin
  if not (Operand.NodeType in [rtInteger, rtBoolean]) then
    RaiseParserError(SErrNoNotOperation, [ResultTypeName(Operand.NodeType),
      Operand.AsString]);
end;

function TFPNotNode.NodeType: TResultType;
begin
  Result := Operand.NodeType;
end;

procedure TFPNotNode.GetNodeValue(var Result: TFPExpressionResult);
begin
  Operand.GetNodeValue(Result);
  case Result.ResultType of
    rtInteger: Result.resInteger := not Result.resInteger;
    rtBoolean: Result.resBoolean := not Result.resBoolean;
  end;
end;

function TFPNotNode.AsString: string;
begin
  Result := 'not ' + Operand.AsString;
end;

{ TIfOperation }

constructor TIfOperation.Create(ACondition, ALeft, ARight: TFPExprNode);
begin
  inherited Create(ALeft, ARight);
  FCondition := ACondition;
end;

destructor TIfOperation.Destroy;
begin
  FreeAndNil(FCondition);
  inherited Destroy;
end;

procedure TIfOperation.GetNodeValue(var Result: TFPExpressionResult);

begin
  FCondition.GetNodeValue(Result);
  if Result.ResBoolean then
    Left.GetNodeValue(Result)
  else
    Right.GetNodeValue(Result);
end;

procedure TIfOperation.Check;
begin
  inherited Check;
  if (Condition.NodeType <> rtBoolean) then
    RaiseParserError(SErrIFNeedsBoolean, [Condition.AsString]);
  CheckSameNodeTypes;
end;

function TIfOperation.NodeType: TResultType;
begin
  Result := Left.NodeType;
end;

function TIfOperation.AsString: string;
begin
  Result := Format('if(%s , %s , %s)', [Condition.AsString, Left.AsString, Right.AsString]);
end;

{ TCaseOperation }

procedure TCaseOperation.GetNodeValue(var Result: TFPExpressionResult);

var
  I, L: integer;
  B: boolean;
  RT, RV: TFPExpressionResult;

begin
  FArgs[0].GetNodeValue(RT);
  L := Length(FArgs);
  I := 2;
  B := False;
  while (not B) and (I < L) do
  begin
    FArgs[i].GetNodeValue(RV);
    case RT.ResultType of
      rtBoolean: B := RT.ResBoolean = RV.ResBoolean;
      rtInteger: B := RT.ResInteger = RV.ResInteger;
      rtFloat: B := RT.ResFloat = RV.ResFLoat;
      rtDateTime: B := RT.ResDateTime = RV.ResDateTime;
      rtString: B := RT.ResString = RV.ResString;
    end;
    if not B then
      Inc(I, 2);
  end;
  // Set result type.
  Result.ResultType := FArgs[1].NodeType;
  if B then
    FArgs[I + 1].GetNodeValue(Result)
  else if ((L mod 2) = 0) then
    FArgs[1].GetNodeValue(Result);
end;

procedure TCaseOperation.Check;

var
  T, V: TResultType;
  I: integer;
  N: TFPExprNode;

begin
  if (Length(FArgs) < 3) then
    RaiseParserError(SErrCaseNeeds3);
  if ((Length(FArgs) mod 2) = 1) then
    RaiseParserError(SErrCaseEvenCount);
  T := FArgs[0].NodeType;
  V := FArgs[1].NodeType;
  for I := 2 to Length(Fargs) - 1 do
  begin
    N := FArgs[I];
    // Even argument types (labels) must equal tag.
    if ((I mod 2) = 0) then
    begin
      if not (N is TFPConstExpression) then
        RaiseParserError(SErrCaseLabelNotAConst, [I div 2, N.AsString]);
      if (N.NodeType <> T) then
        RaiseParserError(SErrCaseLabelType, [I div
          2, N.AsString, ResultTypeName(T), ResultTypeName(N.NodeType)]);
    end
    else // Odd argument types (values) must match first.
    begin
      if (N.NodeType <> V) then
        RaiseParserError(SErrCaseValueType, [(I - 1) div
          2, N.AsString, ResultTypeName(V), ResultTypeName(N.NodeType)]);
    end;
  end;
end;

function TCaseOperation.NodeType: TResultType;
begin
  Result := FArgs[1].NodeType;
end;

constructor TCaseOperation.Create(Args: TExprArgumentArray);
begin
  Fargs := Args;
end;

destructor TCaseOperation.Destroy;

var
  I: integer;

begin
  for I := 0 to Length(FArgs) - 1 do
    FreeAndNil(Fargs[I]);
  inherited Destroy;
end;

function TCaseOperation.AsString: string;

var
  I: integer;

begin
  Result := '';
  for I := 0 to Length(FArgs) - 1 do
  begin
    if (Result <> '') then
      Result := Result + ', ';
    Result := Result + FArgs[i].AsString;
  end;
  Result := 'Case(' + Result + ')';
end;

{ TFPBooleanResultOperation }

procedure TFPBooleanResultOperation.Check;
begin
  inherited Check;
  CheckSameNodeTypes;
end;

function TFPBooleanResultOperation.NodeType: TResultType;
begin
  Result := rtBoolean;
end;

{ TFPEqualOperation }

function TFPEqualOperation.AsString: string;
begin
  Result := Left.AsString + ' = ' + Right.AsString;
end;

procedure TFPEqualOperation.GetNodeValue(var Result: TFPExpressionResult);

var
  RRes: TFPExpressionResult;

begin
  Left.GetNodeValue(Result);
  Right.GetNodeValue(RRes);
  case Result.ResultType of
    rtBoolean: Result.resBoolean := Result.ResBoolean = RRes.ResBoolean;
    rtInteger: Result.resBoolean := Result.ResInteger = RRes.ResInteger;
    rtFloat: Result.resBoolean := Result.ResFloat = RRes.ResFLoat;
    rtDateTime: Result.resBoolean := Result.ResDateTime = RRes.ResDateTime;
    rtString: Result.resBoolean := Result.ResString = RRes.ResString;
  end;
  Result.ResultType := rtBoolean;
end;

{ TFPUnequalOperation }

function TFPUnequalOperation.AsString: string;
begin
  Result := Left.AsString + ' <> ' + Right.AsString;
end;

procedure TFPUnequalOperation.GetNodeValue(var Result: TFPExpressionResult);
begin
  inherited GetNodeValue(Result);
  Result.ResBoolean := not Result.ResBoolean;
end;


{ TFPLessThanOperation }

function TFPLessThanOperation.AsString: string;
begin
  Result := Left.AsString + ' < ' + Right.AsString;
end;

procedure TFPLessThanOperation.GetNodeValue(var Result: TFPExpressionResult);
var
  RRes: TFPExpressionResult;

begin
  Left.GetNodeValue(Result);
  Right.GetNodeValue(RRes);
  case Result.ResultType of
    rtInteger: Result.resBoolean := Result.ResInteger < RRes.ResInteger;
    rtFloat: Result.resBoolean := Result.ResFloat < RRes.ResFLoat;
    rtDateTime: Result.resBoolean := Result.ResDateTime < RRes.ResDateTime;
    rtString: Result.resBoolean := Result.ResString < RRes.ResString;
  end;
  Result.ResultType := rtBoolean;
end;

{ TFPGreaterThanOperation }

function TFPGreaterThanOperation.AsString: string;
begin
  Result := Left.AsString + ' > ' + Right.AsString;
end;

procedure TFPGreaterThanOperation.GetNodeValue(var Result: TFPExpressionResult);

var
  RRes: TFPExpressionResult;

begin
  Left.GetNodeValue(Result);
  Right.GetNodeValue(RRes);
  case Result.ResultType of
    rtInteger: case Right.NodeType of
        rtInteger: Result.resBoolean := Result.ResInteger > RRes.ResInteger;
        rtFloat: Result.resBoolean := Result.ResInteger > RRes.ResFloat;
      end;
    rtFloat: case Right.NodeType of
        rtInteger: Result.resBoolean := Result.ResFloat > RRes.ResInteger;
        rtFloat: Result.resBoolean := Result.ResFloat > RRes.ResFLoat;
      end;
    rtDateTime: Result.resBoolean := Result.ResDateTime > RRes.ResDateTime;
    rtString: Result.resBoolean := Result.ResString > RRes.ResString;
  end;
  Result.ResultType := rtBoolean;
end;

{ TFPGreaterThanEqualOperation }

function TFPGreaterThanEqualOperation.AsString: string;
begin
  Result := Left.AsString + ' >= ' + Right.AsString;
end;

procedure TFPGreaterThanEqualOperation.GetNodeValue(var Result: TFPExpressionResult);
begin
  inherited GetNodeValue(Result);
  Result.ResBoolean := not Result.ResBoolean;
end;

{ TFPLessThanEqualOperation }

function TFPLessThanEqualOperation.AsString: string;
begin
  Result := Left.AsString + ' <= ' + Right.AsString;
end;

procedure TFPLessThanEqualOperation.GetNodeValue(var Result: TFPExpressionResult);
begin
  inherited GetNodeValue(Result);
  Result.ResBoolean := not Result.ResBoolean;
end;

{ TFPOrderingOperation }

procedure TFPOrderingOperation.Check;

const
  AllowedTypes = [rtInteger, rtfloat, rtDateTime, rtString];

begin
  CheckNodeType(Left, AllowedTypes);
  CheckNodeType(Right, AllowedTypes);
  inherited Check;
end;

{ TMathOperation }

procedure TMathOperation.Check;

const
  AllowedTypes = [rtInteger, rtfloat, rtDateTime, rtString];

begin
  inherited Check;
  CheckNodeType(Left, AllowedTypes);
  CheckNodeType(Right, AllowedTypes);
  CheckSameNodeTypes;
end;

function TMathOperation.NodeType: TResultType;
begin
  Result := Left.NodeType;
end;

{ TFPAddOperation }

function TFPAddOperation.AsString: string;
begin
  Result := Left.AsString + ' + ' + Right.AsString;
end;

procedure TFPAddOperation.GetNodeValue(var Result: TFPExpressionResult);

var
  RRes: TFPExpressionResult;

begin
  Left.GetNodeValue(Result);
  Right.GetNodeValue(RRes);
  case Result.ResultType of
    rtInteger: Result.ResInteger := Result.ResInteger + RRes.ResInteger;
    rtString: Result.ResString := Result.ResString + RRes.ResString;
    rtDateTime: Result.ResDateTime := Result.ResDateTime + RRes.ResDateTime;
    rtFloat: Result.ResFLoat := Result.ResFLoat + RRes.ResFLoat;
  end;
  Result.ResultType := NodeType;
end;

{ TFPSubtractOperation }

procedure TFPSubtractOperation.check;

const
  AllowedTypes = [rtInteger, rtfloat, rtDateTime];

begin
  CheckNodeType(Left, AllowedTypes);
  CheckNodeType(Right, AllowedTypes);
  inherited check;
end;

function TFPSubtractOperation.AsString: string;
begin
  Result := Left.AsString + ' - ' + Right.AsString;
end;

procedure TFPSubtractOperation.GetNodeValue(var Result: TFPExpressionResult);

var
  RRes: TFPExpressionResult;

begin
  Left.GetNodeValue(Result);
  Right.GetNodeValue(RRes);
  case Result.ResultType of
    rtInteger: Result.ResInteger := Result.ResInteger - RRes.ResInteger;
    rtDateTime: Result.ResDateTime := Result.ResDateTime - RRes.ResDateTime;
    rtFloat: Result.ResFLoat := Result.ResFLoat - RRes.ResFLoat;
  end;
end;

{ TFPMultiplyOperation }

procedure TFPMultiplyOperation.check;

const
  AllowedTypes = [rtInteger, rtfloat];

begin
  CheckNodeType(Left, AllowedTypes);
  CheckNodeType(Right, AllowedTypes);
  inherited;
end;

function TFPMultiplyOperation.AsString: string;
begin
  Result := Left.AsString + ' * ' + Right.AsString;
end;

procedure TFPMultiplyOperation.GetNodeValue(var Result: TFPExpressionResult);
var
  RRes: TFPExpressionResult;

begin
  Left.GetNodeValue(Result);
  Right.GetNodeValue(RRes);
  case Result.ResultType of
    rtInteger: Result.ResInteger := Result.ResInteger * RRes.ResInteger;
    rtFloat: Result.ResFLoat := Result.ResFLoat * RRes.ResFLoat;
  end;
end;

{ TFPDivideOperation }

procedure TFPDivideOperation.check;
const
  AllowedTypes = [rtInteger, rtfloat];

begin
  CheckNodeType(Left, AllowedTypes);
  CheckNodeType(Right, AllowedTypes);
  inherited check;
end;

function TFPDivideOperation.AsString: string;
begin
  Result := Left.AsString + ' / ' + Right.AsString;
end;

function TFPDivideOperation.NodeType: TResultType;
begin
  Result := rtFLoat;
end;

procedure TFPDivideOperation.GetNodeValue(var Result: TFPExpressionResult);

var
  RRes: TFPExpressionResult;

begin
  Left.GetNodeValue(Result);
  Right.GetNodeValue(RRes);
  case Result.ResultType of
    rtInteger: Result.ResFloat := Result.ResInteger / RRes.ResInteger;
    rtFloat: Result.ResFLoat := Result.ResFLoat / RRes.ResFLoat;
  end;
  Result.ResultType := rtFloat;
end;

{ TFPConvertNode }

function TFPConvertNode.AsString: string;
begin
  Result := Operand.AsString;
end;

{ TIntToFloatNode }

procedure TIntConvertNode.Check;
begin
  inherited Check;
  CheckNodeType(Operand, [rtInteger]);
end;

function TIntToFloatNode.NodeType: TResultType;
begin
  Result := rtFloat;
end;

procedure TIntToFloatNode.GetNodeValue(var Result: TFPExpressionResult);
begin
  Operand.GetNodeValue(Result);
  Result.ResFloat := Result.ResInteger;
  Result.ResultType := rtFloat;
end;


{ TIntToDateTimeNode }

function TIntToDateTimeNode.NodeType: TResultType;
begin
  Result := rtDatetime;
end;

procedure TIntToDateTimeNode.GetNodeValue(var Result: TFPExpressionResult);
begin
  Operand.GetnodeValue(Result);
  Result.ResDateTime := Result.ResInteger;
  Result.ResultType := rtDateTime;
end;

{ TFloatToDateTimeNode }

procedure TFloatToDateTimeNode.Check;
begin
  inherited Check;
  CheckNodeType(Operand, [rtFloat]);
end;

function TFloatToDateTimeNode.NodeType: TResultType;
begin
  Result := rtDateTime;
end;

procedure TFloatToDateTimeNode.GetNodeValue(var Result: TFPExpressionResult);
begin
  Operand.GetNodeValue(Result);
  Result.ResDateTime := Result.ResFloat;
  Result.ResultType := rtDateTime;
end;

{ TFPExprIdentifierNode }

constructor TFPExprIdentifierNode.CreateIdentifier(AID: TFPExprIdentifierDef);
begin
  inherited Create;
  FID := AID;
  PResult := @FID.FValue;
  FResultType := FID.ResultType;
end;

function TFPExprIdentifierNode.NodeType: TResultType;
begin
  Result := FResultType;
end;

procedure TFPExprIdentifierNode.GetNodeValue(var Result: TFPExpressionResult);
begin
  Result := PResult^;
  Result.ResultType := FResultType;
end;

{ TFPExprVariable }

procedure TFPExprVariable.Check;
begin
  // Do nothing;
end;

function TFPExprVariable.AsString: string;
begin
  Result := FID.Name;
end;

{ TFPExprFunction }

procedure TFPExprFunction.CalcParams;

var
  I: integer;

begin
  for I := 0 to Length(FArgumentParams) - 1 do
    FArgumentNodes[i].GetNodeValue(FArgumentParams[i]);
end;

procedure TFPExprFunction.Check;

var
  I: integer;
  rtp, rta: TResultType;

begin
  if Length(FArgumentNodes) <> FID.ArgumentCount then
    RaiseParserError(ErrInvalidArgumentCount, [FID.Name]);
  for I := 0 to Length(FArgumentNodes) - 1 do
  begin
    rtp := CharToResultType(FID.ParameterTypes[i + 1]);
    rta := FArgumentNodes[i].NodeType;
    if (rtp <> rta) then
    begin

      // Automatically convert integers to floats in functions that return
      // a float
      if (rta = rtInteger) and (rtp = rtFloat) then
      begin
        FArgumentNodes[i] := TIntToFloatNode(FArgumentNodes[i]);
        exit;
      end;

      RaiseParserError(SErrInvalidArgumentType, [I + 1, ResultTypeName(
        rtp), ResultTypeName(rta)]);
    end;
  end;
end;

constructor TFPExprFunction.CreateFunction(AID: TFPExprIdentifierDef;
  const Args: TExprArgumentArray);
begin
  inherited CreateIdentifier(AID);
  FArgumentNodes := Args;
  SetLength(FArgumentParams, Length(Args));
end;

destructor TFPExprFunction.Destroy;

var
  I: integer;

begin
  for I := 0 to Length(FArgumentNodes) - 1 do
    FreeAndNil(FArgumentNodes[I]);
  inherited Destroy;
end;

function TFPExprFunction.AsString: string;

var
  S: string;
  I: integer;

begin
  S := '';
  for I := 0 to length(FArgumentNodes) - 1 do
  begin
    if (S <> '') then
      S := S + ',';
    S := S + FArgumentNodes[I].AsString;
  end;
  if (S <> '') then
    S := '(' + S + ')';
  Result := FID.Name + S;
end;

{ TFPFunctionCallBack }

constructor TFPFunctionCallBack.CreateFunction(AID: TFPExprIdentifierDef;
  const Args: TExprArgumentArray);
begin
  inherited;
  FCallBack := AID.OnGetFunctionValueCallBack;
end;

procedure TFPFunctionCallBack.GetNodeValue(var Result: TFPExpressionResult);
begin
  if Length(FArgumentParams) > 0 then
    CalcParams;
  FCallBack(Result, FArgumentParams);
  Result.ResultType := NodeType;
end;

{ TFPFunctionEventHandler }

constructor TFPFunctionEventHandler.CreateFunction(AID: TFPExprIdentifierDef;
  const Args: TExprArgumentArray);
begin
  inherited;
  FCallBack := AID.OnGetFunctionValue;
end;

procedure TFPFunctionEventHandler.GetNodeValue(var Result: TFPExpressionResult);
begin
  if Length(FArgumentParams) > 0 then
    CalcParams;
  FCallBack(Result, FArgumentParams);
  Result.ResultType := NodeType;
end;

{ ---------------------------------------------------------------------
  Standard Builtins support
  ---------------------------------------------------------------------}

{ Template for builtin.

Procedure MyCallback (Var Result : TFPExpressionResult; Const Args : TExprParameterArray);
begin
end;

}

function ArgToFloat(Arg: TFPExpressionResult): TExprFloat;
  // Utility function for the built-in math functions. Accepts also integers
  // in place of the floating point arguments. To be called in builtins or
  // user-defined callbacks having float results.
begin
  if Arg.ResultType = rtInteger then
    Result := Arg.resInteger
  else
    Result := Arg.resFloat;
end;

// Math builtins

procedure BuiltInCos(var Result: TFPExpressionResult; const Args: TExprParameterArray);
begin
  Result.resFloat := Cos(ArgToFloat(Args[0]));
end;

procedure BuiltInSin(var Result: TFPExpressionResult; const Args: TExprParameterArray);
begin
  Result.resFloat := Sin(ArgToFloat(Args[0]));
end;

procedure BuiltInArcTan(var Result: TFPExpressionResult;
  const Args: TExprParameterArray);
begin
  Result.resFloat := Arctan(ArgToFloat(Args[0]));
end;

procedure BuiltInAbs(var Result: TFPExpressionResult; const Args: TExprParameterArray);
begin
  Result.resFloat := Abs(ArgToFloat(Args[0]));
end;

procedure BuiltInSqr(var Result: TFPExpressionResult; const Args: TExprParameterArray);
begin
  Result.resFloat := Sqr(ArgToFloat(Args[0]));
end;

procedure BuiltInSqrt(var Result: TFPExpressionResult;
  const Args: TExprParameterArray);
begin
  Result.resFloat := Sqrt(ArgToFloat(Args[0]));
end;

procedure BuiltInExp(var Result: TFPExpressionResult; const Args: TExprParameterArray);
begin
  Result.resFloat := Exp(ArgToFloat(Args[0]));
end;

procedure BuiltInLn(var Result: TFPExpressionResult; const Args: TExprParameterArray);
begin
  Result.resFloat := Ln(ArgToFloat(Args[0]));
end;

const
  L10 = ln(10);

procedure BuiltInLog(var Result: TFPExpressionResult; const Args: TExprParameterArray);
begin
  Result.resFloat := Ln(ArgToFloat(Args[0])) / L10;
end;

procedure BuiltInRound(var Result: TFPExpressionResult;
  const Args: TExprParameterArray);
begin
  Result.resInteger := Round(ArgToFloat(Args[0]));
end;

procedure BuiltInTrunc(var Result: TFPExpressionResult;
  const Args: TExprParameterArray);
begin
  Result.resInteger := Trunc(ArgToFloat(Args[0]));
end;

procedure BuiltInInt(var Result: TFPExpressionResult; const Args: TExprParameterArray);
begin
  Result.resFloat := Int(ArgToFloat(Args[0]));
end;

procedure BuiltInFrac(var Result: TFPExpressionResult;
  const Args: TExprParameterArray);
begin
  Result.resFloat := frac(ArgToFloat(Args[0]));
end;

// String builtins

procedure BuiltInLength(var Result: TFPExpressionResult;
  const Args: TExprParameterArray);
begin
  Result.resInteger := Length(Args[0].resString);
end;

procedure BuiltInCopy(var Result: TFPExpressionResult;
  const Args: TExprParameterArray);
begin
  Result.resString := Copy(Args[0].resString, Args[1].resInteger, Args[2].resInteger);
end;

procedure BuiltInDelete(var Result: TFPExpressionResult;
  const Args: TExprParameterArray);
begin
  Result.resString := Args[0].resString;
  Delete(Result.resString, Args[1].resInteger, Args[2].resInteger);
end;

procedure BuiltInPos(var Result: TFPExpressionResult; const Args: TExprParameterArray);
begin
  Result.resInteger := Pos(Args[0].resString, Args[1].resString);
end;

procedure BuiltInUppercase(var Result: TFPExpressionResult;
  const Args: TExprParameterArray);
begin
  Result.resString := Uppercase(Args[0].resString);
end;

procedure BuiltInLowercase(var Result: TFPExpressionResult;
  const Args: TExprParameterArray);
begin
  Result.resString := Lowercase(Args[0].resString);
end;

procedure BuiltInStringReplace(var Result: TFPExpressionResult;
  const Args: TExprParameterArray);

var
  F: TReplaceFlags;

begin
  F := [];
  if Args[3].resBoolean then
    Include(F, rfReplaceAll);
  if Args[4].resBoolean then
    Include(F, rfIgnoreCase);
  Result.resString := StringReplace(Args[0].resString, Args[1].resString,
    Args[2].resString, f);
end;

procedure BuiltInCompareText(var Result: TFPExpressionResult;
  const Args: TExprParameterArray);
begin
  Result.resInteger := CompareText(Args[0].resString, Args[1].resString);
end;

// Date/Time builtins

procedure BuiltInDate(var Result: TFPExpressionResult;
  const Args: TExprParameterArray);
begin
  Result.resDateTime := Date;
end;

procedure BuiltInTime(var Result: TFPExpressionResult;
  const Args: TExprParameterArray);
begin
  Result.resDateTime := Time;
end;

procedure BuiltInNow(var Result: TFPExpressionResult; const Args: TExprParameterArray);
begin
  Result.resDateTime := Now;
end;

procedure BuiltInDayofWeek(var Result: TFPExpressionResult;
  const Args: TExprParameterArray);
begin
  Result.resInteger := DayOfWeek(Args[0].resDateTime);
end;

procedure BuiltInExtractYear(var Result: TFPExpressionResult;
  const Args: TExprParameterArray);

var
  Y, M, D: word;

begin
  DecodeDate(Args[0].resDateTime, Y, M, D);
  Result.resInteger := Y;
end;

procedure BuiltInExtractMonth(var Result: TFPExpressionResult;
  const Args: TExprParameterArray);

var
  Y, M, D: word;

begin
  DecodeDate(Args[0].resDateTime, Y, M, D);
  Result.resInteger := M;
end;

procedure BuiltInExtractDay(var Result: TFPExpressionResult;
  const Args: TExprParameterArray);

var
  Y, M, D: word;

begin
  DecodeDate(Args[0].resDateTime, Y, M, D);
  Result.resInteger := D;
end;

procedure BuiltInExtractHour(var Result: TFPExpressionResult;
  const Args: TExprParameterArray);

var
  H, M, S, MS: word;

begin
  DecodeTime(Args[0].resDateTime, H, M, S, MS);
  Result.resInteger := H;
end;

procedure BuiltInExtractMin(var Result: TFPExpressionResult;
  const Args: TExprParameterArray);

var
  H, M, S, MS: word;

begin
  DecodeTime(Args[0].resDateTime, H, M, S, MS);
  Result.resInteger := M;
end;

procedure BuiltInExtractSec(var Result: TFPExpressionResult;
  const Args: TExprParameterArray);

var
  H, M, S, MS: word;

begin
  DecodeTime(Args[0].resDateTime, H, M, S, MS);
  Result.resInteger := S;
end;

procedure BuiltInExtractMSec(var Result: TFPExpressionResult;
  const Args: TExprParameterArray);

var
  H, M, S, MS: word;

begin
  DecodeTime(Args[0].resDateTime, H, M, S, MS);
  Result.resInteger := MS;
end;

procedure BuiltInEncodedate(var Result: TFPExpressionResult;
  const Args: TExprParameterArray);

begin
  Result.resDateTime := Encodedate(Args[0].resInteger, Args[1].resInteger,
    Args[2].resInteger);
end;

procedure BuiltInEncodeTime(var Result: TFPExpressionResult;
  const Args: TExprParameterArray);

begin
  Result.resDateTime := EncodeTime(Args[0].resInteger, Args[1].resInteger,
    Args[2].resInteger, Args[3].resInteger);
end;

procedure BuiltInEncodeDateTime(var Result: TFPExpressionResult;
  const Args: TExprParameterArray);

begin
  Result.resDateTime := EncodeDate(Args[0].resInteger, Args[1].resInteger,
    Args[2].resInteger) + EncodeTime(
    Args[3].resInteger, Args[4].resInteger, Args[5].resInteger, Args[6].resInteger);
end;

procedure BuiltInShortDayName(var Result: TFPExpressionResult;
  const Args: TExprParameterArray);

begin
  Result.resString := ShortDayNames[Args[0].resInteger];
end;

procedure BuiltInShortMonthName(var Result: TFPExpressionResult;
  const Args: TExprParameterArray);

begin
  Result.resString := ShortMonthNames[Args[0].resInteger];
end;

procedure BuiltInLongDayName(var Result: TFPExpressionResult;
  const Args: TExprParameterArray);

begin
  Result.resString := LongDayNames[Args[0].resInteger];
end;

procedure BuiltInLongMonthName(var Result: TFPExpressionResult;
  const Args: TExprParameterArray);

begin
  Result.resString := LongMonthNames[Args[0].resInteger];
end;

procedure BuiltInFormatDateTime(var Result: TFPExpressionResult;
  const Args: TExprParameterArray);

begin
  Result.resString := FormatDateTime(Args[0].resString, Args[1].resDateTime);
end;


// Conversion
procedure BuiltInIntToStr(var Result: TFPExpressionResult;
  const Args: TExprParameterArray);

begin
  Result.resString := IntToStr(Args[0].resinteger);
end;

procedure BuiltInStrToInt(var Result: TFPExpressionResult;
  const Args: TExprParameterArray);

begin
  Result.resInteger := StrToInt(Args[0].resString);
end;

procedure BuiltInStrToIntDef(var Result: TFPExpressionResult;
  const Args: TExprParameterArray);

begin
  Result.resInteger := StrToIntDef(Args[0].resString, Args[1].resInteger);
end;

procedure BuiltInFloatToStr(var Result: TFPExpressionResult;
  const Args: TExprParameterArray);

begin
  Result.resString := FloatToStr(Args[0].resFloat);
end;

procedure BuiltInStrToFloat(var Result: TFPExpressionResult;
  const Args: TExprParameterArray);

begin
  Result.resFloat := StrToFloat(Args[0].resString);
end;

procedure BuiltInStrToFloatDef(var Result: TFPExpressionResult;
  const Args: TExprParameterArray);

begin
  Result.resFloat := StrToFloatDef(Args[0].resString, Args[1].resFloat);
end;

procedure BuiltInDateToStr(var Result: TFPExpressionResult;
  const Args: TExprParameterArray);

begin
  Result.resString := DateToStr(Args[0].resDateTime);
end;

procedure BuiltInTimeToStr(var Result: TFPExpressionResult;
  const Args: TExprParameterArray);

begin
  Result.resString := TimeToStr(Args[0].resDateTime);
end;

procedure BuiltInStrToDate(var Result: TFPExpressionResult;
  const Args: TExprParameterArray);

begin
  Result.resDateTime := StrToDate(Args[0].resString);
end;

procedure BuiltInStrToDateDef(var Result: TFPExpressionResult;
  const Args: TExprParameterArray);

begin
  Result.resDateTime := StrToDateDef(Args[0].resString, Args[1].resDateTime);
end;

procedure BuiltInStrToTime(var Result: TFPExpressionResult;
  const Args: TExprParameterArray);

begin
  Result.resDateTime := StrToTime(Args[0].resString);
end;

procedure BuiltInStrToTimeDef(var Result: TFPExpressionResult;
  const Args: TExprParameterArray);

begin
  Result.resDateTime := StrToTimeDef(Args[0].resString, Args[1].resDateTime);
end;

procedure BuiltInStrToDateTime(var Result: TFPExpressionResult;
  const Args: TExprParameterArray);

begin
  Result.resDateTime := StrToDateTime(Args[0].resString);
end;

procedure BuiltInStrToDateTimeDef(var Result: TFPExpressionResult;
  const Args: TExprParameterArray);

begin
  Result.resDateTime := StrToDateTimeDef(Args[0].resString, Args[1].resDateTime);
end;

procedure BuiltInBoolToStr(var Result: TFPExpressionResult;
  const Args: TExprParameterArray);

begin
  Result.resString := BoolToStr(Args[0].resBoolean);
end;

procedure BuiltInStrToBool(var Result: TFPExpressionResult;
  const Args: TExprParameterArray);

begin
  Result.resBoolean := StrToBool(Args[0].resString);
end;

procedure BuiltInStrToBoolDef(var Result: TFPExpressionResult;
  const Args: TExprParameterArray);

begin
  Result.resBoolean := StrToBoolDef(Args[0].resString, Args[1].resBoolean);
end;

// Boolean
procedure BuiltInShl(var Result: TFPExpressionResult; const Args: TExprParameterArray);

begin
  Result.resInteger := Args[0].resInteger shl Args[1].resInteger;
end;

procedure BuiltInShr(var Result: TFPExpressionResult; const Args: TExprParameterArray);

begin
  Result.resInteger := Args[0].resInteger shr Args[1].resInteger;
end;

procedure BuiltinIFS(var Result: TFPExpressionResult; const Args: TExprParameterArray);

begin
  if Args[0].resBoolean then
    Result.resString := Args[1].resString
  else
    Result.resString := Args[2].resString;
end;

procedure BuiltinIFI(var Result: TFPExpressionResult; const Args: TExprParameterArray);

begin
  if Args[0].resBoolean then
    Result.resinteger := Args[1].resinteger
  else
    Result.resinteger := Args[2].resinteger;
end;

procedure BuiltinIFF(var Result: TFPExpressionResult; const Args: TExprParameterArray);

begin
  if Args[0].resBoolean then
    Result.resfloat := Args[1].resfloat
  else
    Result.resfloat := Args[2].resfloat;
end;

procedure BuiltinIFD(var Result: TFPExpressionResult; const Args: TExprParameterArray);

begin
  if Args[0].resBoolean then
    Result.resDateTime := Args[1].resDateTime
  else
    Result.resDateTime := Args[2].resDateTime;
end;

procedure RegisterStdBuiltins(AManager: TExprBuiltInManager);

begin
  with AManager do
  begin
    AddFloatVariable(bcMath, 'pi', Pi);
    // Math functions
    AddFunction(bcMath, 'cos', 'F', 'F', @BuiltinCos);
    AddFunction(bcMath, 'sin', 'F', 'F', @BuiltinSin);
    AddFunction(bcMath, 'arctan', 'F', 'F', @BuiltinArctan);
    AddFunction(bcMath, 'abs', 'F', 'F', @BuiltinAbs);
    AddFunction(bcMath, 'sqr', 'F', 'F', @BuiltinSqr);
    AddFunction(bcMath, 'sqrt', 'F', 'F', @BuiltinSqrt);
    AddFunction(bcMath, 'exp', 'F', 'F', @BuiltinExp);
    AddFunction(bcMath, 'ln', 'F', 'F', @BuiltinLn);
    AddFunction(bcMath, 'log', 'F', 'F', @BuiltinLog);
    AddFunction(bcMath, 'frac', 'F', 'F', @BuiltinFrac);
    AddFunction(bcMath, 'int', 'F', 'F', @BuiltinInt);
    AddFunction(bcMath, 'round', 'I', 'F', @BuiltinRound);
    AddFunction(bcMath, 'trunc', 'I', 'F', @BuiltinTrunc);
    // String
    AddFunction(bcStrings, 'length', 'I', 'S', @BuiltinLength);
    AddFunction(bcStrings, 'copy', 'S', 'SII', @BuiltinCopy);
    AddFunction(bcStrings, 'delete', 'S', 'SII', @BuiltinDelete);
    AddFunction(bcStrings, 'pos', 'I', 'SS', @BuiltinPos);
    AddFunction(bcStrings, 'lowercase', 'S', 'S', @BuiltinLowercase);
    AddFunction(bcStrings, 'uppercase', 'S', 'S', @BuiltinUppercase);
    AddFunction(bcStrings, 'stringreplace', 'S', 'SSSBB', @BuiltinStringReplace);
    AddFunction(bcStrings, 'comparetext', 'I', 'SS', @BuiltinCompareText);
    // Date/Time
    AddFunction(bcDateTime, 'date', 'D', '', @BuiltinDate);
    AddFunction(bcDateTime, 'time', 'D', '', @BuiltinTime);
    AddFunction(bcDateTime, 'now', 'D', '', @BuiltinNow);
    AddFunction(bcDateTime, 'dayofweek', 'I', 'D', @BuiltinDayofweek);
    AddFunction(bcDateTime, 'extractyear', 'I', 'D', @BuiltinExtractYear);
    AddFunction(bcDateTime, 'extractmonth', 'I', 'D', @BuiltinExtractMonth);
    AddFunction(bcDateTime, 'extractday', 'I', 'D', @BuiltinExtractDay);
    AddFunction(bcDateTime, 'extracthour', 'I', 'D', @BuiltinExtractHour);
    AddFunction(bcDateTime, 'extractmin', 'I', 'D', @BuiltinExtractMin);
    AddFunction(bcDateTime, 'extractsec', 'I', 'D', @BuiltinExtractSec);
    AddFunction(bcDateTime, 'extractmsec', 'I', 'D', @BuiltinExtractMSec);
    AddFunction(bcDateTime, 'encodedate', 'D', 'III', @BuiltinEncodedate);
    AddFunction(bcDateTime, 'encodetime', 'D', 'IIII', @BuiltinEncodeTime);
    AddFunction(bcDateTime, 'encodedatetime', 'D', 'IIIIIII', @BuiltinEncodeDateTime);
    AddFunction(bcDateTime, 'shortdayname', 'S', 'I', @BuiltinShortDayName);
    AddFunction(bcDateTime, 'shortmonthname', 'S', 'I', @BuiltinShortMonthName);
    AddFunction(bcDateTime, 'longdayname', 'S', 'I', @BuiltinLongDayName);
    AddFunction(bcDateTime, 'longmonthname', 'S', 'I', @BuiltinLongMonthName);
    AddFunction(bcDateTime, 'formatdatetime', 'S', 'SD', @BuiltinFormatDateTime);
    // Boolean
    AddFunction(bcBoolean, 'shl', 'I', 'II', @BuiltinShl);
    AddFunction(bcBoolean, 'shr', 'I', 'II', @BuiltinShr);
    AddFunction(bcBoolean, 'IFS', 'S', 'BSS', @BuiltinIFS);
    AddFunction(bcBoolean, 'IFF', 'F', 'BFF', @BuiltinIFF);
    AddFunction(bcBoolean, 'IFD', 'D', 'BDD', @BuiltinIFD);
    AddFunction(bcBoolean, 'IFI', 'I', 'BII', @BuiltinIFI);
    // Conversion
    AddFunction(bcConversion, 'inttostr', 'S', 'I', @BuiltInIntToStr);
    AddFunction(bcConversion, 'strtoint', 'I', 'S', @BuiltInStrToInt);
    AddFunction(bcConversion, 'strtointdef', 'I', 'SI', @BuiltInStrToIntDef);
    AddFunction(bcConversion, 'floattostr', 'S', 'F', @BuiltInFloatToStr);
    AddFunction(bcConversion, 'strtofloat', 'F', 'S', @BuiltInStrToFloat);
    AddFunction(bcConversion, 'strtofloatdef', 'F', 'SF', @BuiltInStrToFloatDef);
    AddFunction(bcConversion, 'booltostr', 'S', 'B', @BuiltInBoolToStr);
    AddFunction(bcConversion, 'strtobool', 'B', 'S', @BuiltInStrToBool);
    AddFunction(bcConversion, 'strtobooldef', 'B', 'SB', @BuiltInStrToBoolDef);
    AddFunction(bcConversion, 'datetostr', 'S', 'D', @BuiltInDateToStr);
    AddFunction(bcConversion, 'timetostr', 'S', 'D', @BuiltInTimeToStr);
    AddFunction(bcConversion, 'strtodate', 'D', 'S', @BuiltInStrToDate);
    AddFunction(bcConversion, 'strtodatedef', 'D', 'SD', @BuiltInStrToDateDef);
    AddFunction(bcConversion, 'strtotime', 'D', 'S', @BuiltInStrToTime);
    AddFunction(bcConversion, 'strtotimedef', 'D', 'SD', @BuiltInStrToTimeDef);
    AddFunction(bcConversion, 'strtodatetime', 'D', 'S', @BuiltInStrToDateTime);
    AddFunction(bcConversion, 'strtodatetimedef', 'D', 'SD', @BuiltInStrToDateTimeDef);
  end;
end;

{ TFPBuiltInExprIdentifierDef }

procedure TFPBuiltInExprIdentifierDef.Assign(Source: TPersistent);
begin
  inherited Assign(Source);
  if Source is TFPBuiltInExprIdentifierDef then
    FCategory := (Source as TFPBuiltInExprIdentifierDef).Category;
end;

initialization
  RegisterStdBuiltins(BuiltinIdentifiers);

finalization
  FreeBuiltins;
end.
