object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 399
  ClientWidth = 673
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 217
    Height = 161
    Caption = 'Problema 1'
    TabOrder = 0
    object Label1: TLabel
      Left = 24
      Top = 115
      Width = 136
      Height = 13
      Caption = 'ec1): x1^2 + x2^2 - x3 = 0'
    end
    object Label2: TLabel
      Left = 24
      Top = 131
      Width = 172
      Height = 13
      Caption = 'ec2): (x1-1)^2 + (x2-1)^2 - x3 = 0'
    end
    object rbx1: TRadioButton
      Left = 24
      Top = 40
      Width = 33
      Height = 17
      Caption = 'x1'
      TabOrder = 0
    end
    object rbx2: TRadioButton
      Left = 24
      Top = 63
      Width = 34
      Height = 17
      Caption = 'x2'
      TabOrder = 1
    end
    object rbx3: TRadioButton
      Left = 24
      Top = 86
      Width = 42
      Height = 17
      Caption = 'x3'
      Checked = True
      TabOrder = 2
      TabStop = True
    end
    object ex1: TEdit
      Left = 63
      Top = 38
      Width = 49
      Height = 21
      TabOrder = 3
      Text = '50'
    end
    object ex2: TEdit
      Left = 63
      Top = 63
      Width = 49
      Height = 21
      TabOrder = 4
      Text = '100'
    end
    object ex3: TEdit
      Left = 64
      Top = 88
      Width = 49
      Height = 21
      TabOrder = 5
      Text = '1'
    end
    object Button1: TButton
      Left = 118
      Top = 59
      Width = 83
      Height = 25
      Caption = 'Resolver'
      TabOrder = 6
      OnClick = Button1Click
    end
  end
end
