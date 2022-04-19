object TOGPropForm: TTOGPropForm
  Left = 0
  Top = 0
  Caption = 'TOGPropForm'
  ClientHeight = 342
  ClientWidth = 425
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Shape1: TShape
    Left = 36
    Top = 8
    Width = 109
    Height = 65
  end
  object Label1: TLabel
    Left = 164
    Top = 76
    Width = 67
    Height = 13
    Caption = 'Grosor borde.'
  end
  object Button1: TButton
    Left = 159
    Top = 8
    Width = 94
    Height = 25
    Caption = '<- Color Borde'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 116
    Top = 296
    Width = 75
    Height = 25
    Caption = 'Guardar'
    TabOrder = 1
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 220
    Top = 296
    Width = 75
    Height = 25
    Caption = 'Cancelar'
    TabOrder = 2
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 159
    Top = 39
    Width = 94
    Height = 25
    Caption = '<- Color Relleno'
    TabOrder = 3
    OnClick = Button4Click
  end
  object cb_Close: TCheckBox
    Left = 36
    Top = 84
    Width = 97
    Height = 17
    Caption = 'Figura Cerrada'
    TabOrder = 4
  end
  object sb_GrosorBorde: TScrollBar
    Left = 237
    Top = 70
    Width = 25
    Height = 25
    Max = 12
    Min = 1
    PageSize = 0
    Position = 1
    TabOrder = 5
    OnChange = sb_GrosorBordeChange
  end
  object ColorDialog1: TColorDialog
    Left = 292
    Top = 8
  end
end
