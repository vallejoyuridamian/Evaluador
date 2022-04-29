object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 221
  ClientWidth = 426
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 84
    Top = 32
    Width = 133
    Height = 25
    Caption = 'Principal_Raw'
    TabOrder = 0
    OnClick = Button1Click
  end
  object OpenDialog1: TOpenDialog
    Filter = 'Archivos RAW|*.raw'
    InitialDir = 'C:\simsee\SimSEE_src\src\ap\flucar'
    Left = 300
    Top = 28
  end
end
