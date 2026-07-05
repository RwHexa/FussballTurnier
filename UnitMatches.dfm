object FormMatches: TFormMatches
  Left = 0
  Top = 0
  Caption = 'Spielpaarungen'
  ClientHeight = 475
  ClientWidth = 617
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  OnShow = FormShow
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 617
    Height = 475
    Align = alClient
    TabOrder = 0
    object Label1: TLabel
      Left = 24
      Top = 24
      Width = 69
      Height = 13
      Caption = 'Mannschaft 1:'
    end
    object Label2: TLabel
      Left = 216
      Top = 24
      Width = 69
      Height = 13
      Caption = 'Mannschaft 2:'
    end
    object Label3: TLabel
      Left = 24
      Top = 80
      Width = 26
      Height = 13
      Caption = 'Tore:'
    end
    object Label4: TLabel
      Left = 216
      Top = 80
      Width = 26
      Height = 13
      Caption = 'Tore:'
    end
    object cmbTeam1: TComboBox
      Left = 24
      Top = 43
      Width = 145
      Height = 21
      Style = csDropDownList
      TabOrder = 0
    end
    object cmbTeam2: TComboBox
      Left = 216
      Top = 43
      Width = 145
      Height = 21
      Style = csDropDownList
      TabOrder = 1
    end
    object edtGoals1: TEdit
      Left = 24
      Top = 99
      Width = 49
      Height = 21
      TabOrder = 2
    end
    object edtGoals2: TEdit
      Left = 216
      Top = 99
      Width = 49
      Height = 21
      TabOrder = 3
    end
    object btnAddMatch: TButton
      Left = 392
      Top = 75
      Width = 105
      Height = 25
      Caption = 'Spiel hinzufuegen'
      TabOrder = 4
      OnClick = btnAddMatchClick
    end
    object ListBox1: TListBox
      Left = 24
      Top = 144
      Width = 449
      Height = 233
      ItemHeight = 13
      TabOrder = 5
    end
  end
end
