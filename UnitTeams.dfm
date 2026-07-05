object FormTeams: TFormTeams
  Left = 0
  Top = 0
  Caption = 'Mannschaftsverwaltung'
  ClientHeight = 400
  ClientWidth = 400
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 400
    Height = 400
    Align = alClient
    TabOrder = 0
    object Label1: TLabel
      Left = 24
      Top = 24
      Width = 87
      Height = 13
      Caption = 'Mannschaftsname'
    end
    object edtTeamName: TEdit
      Left = 24
      Top = 43
      Width = 249
      Height = 21
      TabOrder = 0
    end
    object btnAddTeam: TButton
      Left = 279
      Top = 41
      Width = 98
      Height = 25
      Caption = 'Hinzufuegen'
      TabOrder = 1
      OnClick = btnAddTeamClick
    end
    object ListBox1: TListBox
      Left = 24
      Top = 88
      Width = 249
      Height = 289
      ItemHeight = 13
      TabOrder = 2
    end
    object btnDeleteTeam: TButton
      Left = 279
      Top = 88
      Width = 98
      Height = 25
      Caption = 'Loeschen'
      TabOrder = 3
      OnClick = btnDeleteTeamClick
    end
  end
end
