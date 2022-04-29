unit WordConst;

interface

const
{ WdPasteDataType }

  wdPasteOLEObject = 0;
  wdPasteRTF = 1;
  wdPasteText = 2;
  wdPasteMetafilePicture = 3;
  wdPasteBitmap = 4;
  wdPasteDeviceIndependentBitmap = 5;
  wdPasteHyperlink = 7;
  wdPasteShape = 8;
  wdPasteEnhancedMetafile = 9;
  wdChartPicture = 13;

{ WdAlertLevel }

  wdAlertsNone = 0;
  wdAlertsMessageBox = -2;
  wdAlertsAll = -1;

{ WdSaveOptions }

  wdDoNotSaveChanges = 0;
  wdSaveChanges = -1;
  wdPromptToSaveChanges = -2;

{ WdGoToDirection }

  wdGoToFirst = 1;
  wdGoToLast = -1;
  wdGoToNext = 2;
  wdGoToRelative = 2;
  wdGoToPrevious = 3;
  wdGoToAbsolute = 1;

{ WdGoToItem }

  wdGoToBookmark = -1;
  wdGoToSection = 0;
  wdGoToPage = 1;
  wdGoToTable = 2;
  wdGoToLine = 3;
  wdGoToFootnote = 4;
  wdGoToEndnote = 5;
  wdGoToComment = 6;
  wdGoToField = 7;
  wdGoToGraphic = 8;
  wdGoToObject = 9;
  wdGoToEquation = 10;
  wdGoToHeading = 11;
  wdGoToPercent = 12;
  wdGoToSpellingError = 13;
  wdGoToGrammaticalError = 14;
  wdGoToProofreadingError = 15;

{ WdSectionStart }

  wdSectionContinuous = 0;
  wdSectionNewColumn = 1;
  wdSectionNewPage = 2;
  wdSectionEvenPage = 3;
  wdSectionOddPage = 4;
  
implementation

end.
 