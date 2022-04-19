object Form2: TForm2
  Left = 0
  Top = 0
  Caption = 'Resoluci'#243'n de cuadripolos pasivos ( C= (AD-1)/B )'
  ClientHeight = 436
  ClientWidth = 692
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 601
    Height = 137
    Caption = 'Datos del Cuadripolo'
    TabOrder = 0
    object Label3: TLabel
      Left = 56
      Top = 37
      Width = 89
      Height = 13
      Caption = 'A [adimensionado]'
    end
    object Label4: TLabel
      Left = 82
      Top = 76
      Width = 34
      Height = 13
      Caption = 'alfa ['#186']'
    end
    object Label5: TLabel
      Left = 173
      Top = 37
      Width = 37
      Height = 13
      Caption = 'B [ohm]'
    end
    object Label6: TLabel
      Left = 179
      Top = 76
      Width = 38
      Height = 13
      Caption = 'beta ['#186']'
    end
    object Label7: TLabel
      Left = 264
      Top = 37
      Width = 38
      Height = 13
      Caption = 'C [mho]'
    end
    object Label8: TLabel
      Left = 264
      Top = 76
      Width = 50
      Height = 13
      Caption = 'gamma ['#186']'
    end
    object cb_simetrico: TCheckBox
      Left = 360
      Top = 17
      Width = 161
      Height = 14
      Caption = 'Marque si es sim'#233'trico. D=A'
      TabOrder = 0
      OnClick = cb_simetricoClick
    end
    object e_A: TEdit
      Left = 82
      Top = 50
      Width = 46
      Height = 21
      TabOrder = 1
      Text = 'e_A'
      OnChange = e_AClick
    end
    object e_Alfa: TEdit
      Left = 82
      Top = 89
      Width = 46
      Height = 21
      TabOrder = 2
      Text = 'e_Alfa'
      OnChange = e_AClick
    end
    object e_B: TEdit
      Left = 173
      Top = 50
      Width = 46
      Height = 21
      TabOrder = 3
      Text = 'e_B'
      OnChange = e_AClick
    end
    object e_beta: TEdit
      Left = 173
      Top = 89
      Width = 46
      Height = 21
      TabOrder = 4
      Text = 'e_beta'
      OnChange = e_AClick
    end
    object e_C: TEdit
      Left = 264
      Top = 50
      Width = 46
      Height = 21
      Color = clAppWorkSpace
      ReadOnly = True
      TabOrder = 5
      Text = 'e_C'
    end
    object e_gamma: TEdit
      Left = 264
      Top = 95
      Width = 46
      Height = 21
      Color = clAppWorkSpace
      ReadOnly = True
      TabOrder = 6
      Text = 'e_gamma'
    end
    object panel_D: TPanel
      Left = 358
      Top = 37
      Width = 107
      Height = 84
      TabOrder = 7
      object Label1: TLabel
        Left = 8
        Top = 3
        Width = 89
        Height = 13
        Caption = 'D [adimensionado]'
      end
      object Label2: TLabel
        Left = 8
        Top = 42
        Width = 40
        Height = 13
        Caption = 'delta ['#186']'
      end
      object e_D: TEdit
        Left = 8
        Top = 14
        Width = 49
        Height = 21
        TabOrder = 0
        Text = 'e_D'
        OnChange = e_AClick
      end
      object e_delta: TEdit
        Left = 8
        Top = 54
        Width = 49
        Height = 21
        TabOrder = 1
        Text = 'e_delta'
        OnChange = e_AClick
      end
    end
  end
  object GroupBox2: TGroupBox
    Left = 8
    Top = 151
    Width = 201
    Height = 250
    Caption = 'Entrada'
    TabOrder = 1
    object Label9: TLabel
      Left = 78
      Top = 20
      Width = 13
      Height = 13
      Caption = 'U1'
    end
    object e_U1: TEdit
      Left = 20
      Top = 20
      Width = 52
      Height = 21
      TabOrder = 0
      Text = '0'
    end
    object cb_U1: TCheckBox
      Left = 111
      Top = 20
      Width = 59
      Height = 13
      Caption = 'Es dato'
      TabOrder = 1
    end
    object Panel1: TPanel
      Left = 3
      Top = 152
      Width = 185
      Height = 87
      TabOrder = 2
      object Label14: TLabel
        Left = 66
        Top = 58
        Width = 29
        Height = 13
        Caption = 'FI1['#186']'
      end
      object Label17: TLabel
        Left = 64
        Top = 31
        Width = 38
        Height = 13
        Caption = 'Abs(S1)'
      end
      object e_FI1: TEdit
        Left = 8
        Top = 52
        Width = 52
        Height = 21
        Enabled = False
        TabOrder = 0
        Text = '0'
        OnChange = e_roS1Change
      end
      object cb_FI1: TCheckBox
        Left = 108
        Top = 58
        Width = 59
        Height = 14
        Caption = 'Es dato'
        Enabled = False
        TabOrder = 1
      end
      object e_roS1: TEdit
        Left = 6
        Top = 25
        Width = 52
        Height = 21
        Enabled = False
        TabOrder = 2
        Text = 'e_roS1'
        OnChange = e_roS1Change
      end
      object cb_roS1: TCheckBox
        Left = 108
        Top = 27
        Width = 97
        Height = 17
        Caption = 'Es dato'
        Enabled = False
        TabOrder = 3
      end
      object rb_S1_roFi: TRadioButton
        Left = 6
        Top = 8
        Width = 113
        Height = 17
        TabOrder = 4
        OnClick = rb_S1_roFiClick
      end
    end
    object Panel2: TPanel
      Left = 3
      Top = 64
      Width = 185
      Height = 82
      TabOrder = 3
      object Label10: TLabel
        Left = 65
        Top = 31
        Width = 12
        Height = 13
        Caption = 'P1'
      end
      object Label11: TLabel
        Left = 65
        Top = 51
        Width = 14
        Height = 13
        Caption = 'Q1'
      end
      object rb_S1_PQ: TRadioButton
        Left = 7
        Top = 8
        Width = 113
        Height = 17
        Checked = True
        TabOrder = 0
        TabStop = True
        OnClick = rb_S1_PQClick
      end
      object e_P1: TEdit
        Left = 7
        Top = 31
        Width = 52
        Height = 21
        TabOrder = 1
        Text = '0'
        OnChange = e_P1Change
      end
      object e_Q1: TEdit
        Left = 7
        Top = 51
        Width = 52
        Height = 21
        TabOrder = 2
        Text = '0'
        OnChange = e_P1Change
      end
      object cb_P1: TCheckBox
        Left = 98
        Top = 31
        Width = 59
        Height = 14
        Caption = 'Es dato'
        TabOrder = 3
      end
      object cb_Q1: TCheckBox
        Left = 98
        Top = 51
        Width = 59
        Height = 13
        Caption = 'Es dato'
        TabOrder = 4
      end
    end
  end
  object GroupBox3: TGroupBox
    Left = 399
    Top = 151
    Width = 210
    Height = 250
    Caption = 'Salida'
    TabOrder = 2
    object Label12: TLabel
      Left = 78
      Top = 20
      Width = 13
      Height = 13
      Caption = 'U2'
    end
    object e_U2: TEdit
      Left = 20
      Top = 20
      Width = 52
      Height = 21
      TabOrder = 0
      Text = '0'
    end
    object cb_U2: TCheckBox
      Left = 114
      Top = 20
      Width = 59
      Height = 13
      Caption = 'Es dato'
      TabOrder = 1
    end
    object Panel3: TPanel
      Left = 3
      Top = 64
      Width = 196
      Height = 81
      TabOrder = 2
      object Label13: TLabel
        Left = 62
        Top = 31
        Width = 12
        Height = 13
        Caption = 'P2'
      end
      object Label15: TLabel
        Left = 62
        Top = 51
        Width = 14
        Height = 13
        Caption = 'Q2'
      end
      object e_P2: TEdit
        Left = 4
        Top = 31
        Width = 52
        Height = 21
        TabOrder = 0
        Text = '0'
        OnChange = e_P2Change
      end
      object cb_P2: TCheckBox
        Left = 98
        Top = 31
        Width = 59
        Height = 14
        Caption = 'Es dato'
        TabOrder = 1
      end
      object e_Q2: TEdit
        Left = 4
        Top = 51
        Width = 52
        Height = 21
        TabOrder = 2
        Text = '0'
        OnChange = e_P2Change
      end
      object cb_Q2: TCheckBox
        Left = 98
        Top = 51
        Width = 59
        Height = 13
        Caption = 'Es dato'
        TabOrder = 3
      end
      object rb_S2_PQ: TRadioButton
        Left = 8
        Top = 8
        Width = 113
        Height = 17
        Checked = True
        TabOrder = 4
        TabStop = True
        OnClick = rb_S2_PQClick
      end
    end
    object Panel4: TPanel
      Left = 3
      Top = 151
      Width = 196
      Height = 90
      TabOrder = 3
      object Label16: TLabel
        Left = 62
        Top = 63
        Width = 29
        Height = 13
        Caption = 'FI2['#186']'
      end
      object Label18: TLabel
        Left = 63
        Top = 31
        Width = 38
        Height = 13
        Caption = 'Abs(S2)'
      end
      object cb_FI2: TCheckBox
        Left = 106
        Top = 62
        Width = 59
        Height = 14
        Caption = 'Es dato'
        Enabled = False
        TabOrder = 0
      end
      object e_FI2: TEdit
        Left = 4
        Top = 55
        Width = 52
        Height = 21
        Enabled = False
        TabOrder = 1
        Text = '0'
        OnChange = e_roS2Change
      end
      object rb_S2_roFi: TRadioButton
        Left = 8
        Top = 8
        Width = 113
        Height = 17
        TabOrder = 2
        OnClick = rb_S2_roFiClick
      end
      object e_roS2: TEdit
        Left = 4
        Top = 31
        Width = 53
        Height = 21
        Enabled = False
        TabOrder = 3
        Text = 'e_roS2'
        OnChange = e_roS2Change
      end
      object cb_roS2: TCheckBox
        Left = 107
        Top = 31
        Width = 62
        Height = 17
        Caption = 'Es dato'
        Enabled = False
        TabOrder = 4
      end
    end
  end
  object GroupBox4: TGroupBox
    Left = 215
    Top = 151
    Width = 178
    Height = 88
    Caption = 'adelanto de U2 respecto de U1'
    TabOrder = 3
    object Label19: TLabel
      Left = 102
      Top = 28
      Width = 39
      Height = 13
      Caption = 'theta['#186']'
    end
    object e_theta: TEdit
      Left = 31
      Top = 28
      Width = 59
      Height = 21
      TabOrder = 0
      Text = '0'
    end
    object cb_theta: TCheckBox
      Left = 50
      Top = 55
      Width = 65
      Height = 13
      Caption = 'Es dato'
      TabOrder = 1
    end
  end
  object Button2: TButton
    Left = 215
    Top = 352
    Width = 153
    Height = 25
    Caption = 'Resolver por Newton Rapson'
    TabOrder = 4
    OnClick = Button2Click
  end
end
