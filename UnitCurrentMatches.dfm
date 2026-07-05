object FormCurrentMatches: TFormCurrentMatches
  Left = 0
  Top = 0
  Caption = 'Aktuelles Spiel'
  ClientHeight = 201
  ClientWidth = 628
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 15
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 628
    Height = 201
    Align = alClient
    Color = clGradientActiveCaption
    ParentBackground = False
    TabOrder = 0
    object lblTeam1: TLabel
      Left = 24
      Top = 24
      Width = 95
      Height = 15
      Caption = 'Heimmannschaft:'
    end
    object lblTeam2: TLabel
      Left = 352
      Top = 24
      Width = 89
      Height = 15
      Caption = 'Gastmannschaft:'
    end
    object lblVS: TLabel
      Left = 296
      Top = 58
      Width = 35
      Height = 25
      Caption = '-----'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -18
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblScore: TLabel
      Left = 317
      Top = 128
      Width = 5
      Height = 25
      Caption = ':'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -18
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object cmbTeam1: TComboBox
      Left = 24
      Top = 45
      Width = 241
      Height = 45
      Margins.Left = 15
      Style = csDropDownList
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -27
      Font.Name = 'Segoe UI'
      Font.Style = [fsItalic]
      ParentFont = False
      TabOrder = 0
      OnChange = cmbTeam1Change
    end
    object cmbTeam2: TComboBox
      Left = 352
      Top = 45
      Width = 233
      Height = 45
      Style = csDropDownList
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -27
      Font.Name = 'Segoe UI'
      Font.Style = [fsItalic]
      ParentFont = False
      TabOrder = 1
      OnChange = cmbTeam2Change
    end
    object edtGoals1: TEdit
      Left = 104
      Top = 119
      Width = 49
      Height = 40
      Alignment = taCenter
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -24
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      MaxLength = 2
      NumbersOnly = True
      ParentFont = False
      TabOrder = 2
      Text = '0'
      OnChange = edtGoals1Change
      OnClick = EditClick
    end
    object edtGoals2: TEdit
      Left = 448
      Top = 119
      Width = 49
      Height = 40
      Alignment = taCenter
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -24
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      MaxLength = 2
      NumbersOnly = True
      ParentFont = False
      TabOrder = 3
      Text = '0'
      OnChange = edtGoals2Change
      OnClick = EditClick
    end
  end
end
