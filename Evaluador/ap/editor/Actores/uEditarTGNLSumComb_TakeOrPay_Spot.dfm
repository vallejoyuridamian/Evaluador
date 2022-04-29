object EditarTGNLSumComb_TakeOrPay_Spot: TEditarTGNLSumComb_TakeOrPay_Spot
  Left = 0
  Top = 0
  AutoSize = True
  Caption = 'Ficha de Contrato Take Or Pay y Spot'
  ClientHeight = 609
  ClientWidth = 385
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCloseQuery = FormCloseQuery
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object LNombre: TLabel
    Left = 0
    Top = 3
    Width = 100
    Height = 13
    Caption = 'Nombre del Contrato'
  end
  object LFNac: TLabel
    Left = 0
    Top = 29
    Width = 99
    Height = 13
    Caption = 'Fecha de Nacimiento'
  end
  object LFMuerte: TLabel
    Left = 0
    Top = 53
    Width = 81
    Height = 13
    Caption = 'Fecha de Muerte'
  end
  object LVEstado: TLabel
    Left = 0
    Top = 103
    Width = 98
    Height = 13
    Caption = 'Variables de Estado:'
  end
  object LNDisc: TLabel
    Left = 0
    Top = 144
    Width = 210
    Height = 13
    Caption = 'Nro de puntos de discretizaci'#243'n del Volumen'
  end
  object LHIni: TLabel
    Left = 0
    Top = 123
    Width = 141
    Height = 13
    Caption = 'Volumen Disponible Inicial[m]:'
  end
  object LFichas: TLabel
    Left = 0
    Top = 354
    Width = 34
    Height = 13
    Caption = 'Fichas:'
  end
  object Label1: TLabel
    Left = 0
    Top = 81
    Width = 62
    Height = 13
    Caption = 'Combustible:'
  end
  object Label2: TLabel
    Left = 0
    Top = 242
    Width = 158
    Height = 13
    Caption = 'Cargamentos separados por [;] :'
  end
  object Label3: TLabel
    Left = 0
    Top = 267
    Width = 213
    Height = 13
    Caption = 'Arribos iniciales de cargamentos [d'#237'as;d'#237'as] :'
  end
  object lblV_Max: TLabel
    Left = 0
    Top = 168
    Width = 133
    Height = 13
    Caption = 'Volumen m'#225'ximo del tanque'
  end
  object Label5: TLabel
    Left = 0
    Top = 192
    Width = 158
    Height = 13
    Caption = 'Tiempo de llegada del Spot [d'#237'as]'
  end
  object Label4: TLabel
    Left = 0
    Top = 217
    Width = 205
    Height = 13
    Caption = 'Discretizaci'#243'n del tiempo de llegada [ptos.]'
  end
  object Label6: TLabel
    Left = 0
    Top = 290
    Width = 97
    Height = 13
    Caption = 'Favorecer Descarga'
  end
  object Label7: TLabel
    Left = 0
    Top = 309
    Width = 93
    Height = 13
    Caption = 'Fijar Costo Variable'
  end
  object EditNombre: TEdit
    Left = 112
    Top = 0
    Width = 249
    Height = 21
    TabOrder = 0
    Text = 'Ingrese el Nombre del Nuevo Contrato'
  end
  object EFNac: TEdit
    Left = 168
    Top = 26
    Width = 98
    Height = 21
    TabOrder = 1
    OnEnter = EditEnter
    OnExit = EditExit
  end
  object EFMuerte: TEdit
    Left = 168
    Top = 50
    Width = 98
    Height = 21
    TabOrder = 2
    OnEnter = EditEnter
    OnExit = EditExit
  end
  object sgFichas: TStringGrid
    Left = 0
    Top = 384
    Width = 385
    Height = 194
    FixedCols = 0
    RowCount = 6
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRowSelect]
    TabOrder = 3
    ColWidths = (
      64
      64
      64
      65
      64)
    RowHeights = (
      24
      23
      24
      24
      24
      24)
  end
  object BAgregarFicha: TButton
    Left = 263
    Top = 349
    Width = 122
    Height = 25
    Caption = 'Agregar Nueva Ficha'
    TabOrder = 4
    OnClick = BAgregarFichaClick
  end
  object BGuardar: TButton
    Left = 80
    Top = 584
    Width = 105
    Height = 25
    Caption = 'Guardar Cambios'
    TabOrder = 5
    OnClick = BGuardarClick
  end
  object BCancelar: TButton
    Left = 280
    Top = 584
    Width = 105
    Height = 25
    Caption = 'Cancelar'
    TabOrder = 6
    OnClick = BCancelarClick
  end
  object EVDispToP: TEdit
    Left = 213
    Top = 117
    Width = 172
    Height = 21
    TabOrder = 7
    OnEnter = EditEnter
    OnExit = EditExit
  end
  object ENDisc: TEdit
    Left = 213
    Top = 141
    Width = 172
    Height = 21
    TabOrder = 8
    OnEnter = EditEnter
    OnExit = EditExit
  end
  object Panel1: TPanel
    Left = 0
    Top = 74
    Width = 385
    Height = 2
    TabOrder = 9
  end
  object BVerExpandida: TButton
    Left = 112
    Top = 349
    Width = 145
    Height = 25
    Caption = 'Ver Periodicidad Expandida'
    TabOrder = 10
    OnClick = BVerExpandidaClick
  end
  object BAyuda: TButton
    Left = 364
    Top = 0
    Width = 21
    Height = 21
    Caption = '?'
    TabOrder = 11
    OnClick = BAyudaClick
  end
  object CBCombustibles: TComboBox
    Left = 104
    Top = 77
    Width = 276
    Height = 21
    Style = csDropDownList
    TabOrder = 12
    OnChange = CBCombustibleChange
  end
  object ECargamentos: TEdit
    Left = 213
    Top = 239
    Width = 172
    Height = 21
    TabOrder = 13
    OnEnter = EditEnter
    OnExit = EditExit
  end
  object EArribos: TEdit
    Left = 213
    Top = 264
    Width = 172
    Height = 21
    TabOrder = 14
    OnEnter = EditEnter
    OnExit = EditExit
  end
  object eV_Max: TEdit
    Left = 213
    Top = 165
    Width = 172
    Height = 21
    TabOrder = 15
    OnEnter = EditEnter
    OnExit = EditExit
  end
  object eT_Arribo: TEdit
    Left = 213
    Top = 189
    Width = 172
    Height = 21
    TabOrder = 16
    OnEnter = EditEnter
    OnExit = EditExit
  end
  object eNDisSpot: TEdit
    Left = 213
    Top = 214
    Width = 172
    Height = 21
    TabOrder = 17
    OnEnter = EditEnter
    OnExit = EditExit
  end
  object chkFavorecerDescarga: TCheckBox
    Left = 213
    Top = 289
    Width = 18
    Height = 17
    TabOrder = 18
  end
  object chkCostoVariableCero: TCheckBox
    Left = 213
    Top = 308
    Width = 18
    Height = 17
    TabOrder = 19
  end
  object ECostoVariable: TEdit
    Left = 237
    Top = 306
    Width = 148
    Height = 21
    TabOrder = 20
    OnEnter = EditEnter
    OnExit = EditExit
  end
end
