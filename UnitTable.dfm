object FormTable: TFormTable
  Left = 0
  Top = 0
  Caption = 'Tabelle'
  ClientHeight = 547
  ClientWidth = 813
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
    Width = 813
    Height = 547
    Align = alClient
    TabOrder = 0
    object StringGrid1: TStringGrid
      Left = 24
      Top = 47
      Width = 697
      Height = 410
      Margins.Left = 7
      ColCount = 6
      DrawingStyle = gdsClassic
      FixedCols = 0
      RowCount = 7
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'Tahoma'
      Font.Style = []
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing]
      ParentFont = False
      TabOrder = 0
      OnDrawCell = StringGrid1DrawCell
    end
    object btnUpdate: TButton
      Left = 24
      Top = 16
      Width = 105
      Height = 25
      Caption = 'Aktualisieren'
      TabOrder = 1
      OnClick = btnUpdateClick
    end
    object btnShowResultsrw: TButton
      Left = 168
      Top = 16
      Width = 89
      Height = 25
      Caption = 'Ergebnisse'
      TabOrder = 2
      OnClick = btnShowResultsrwClick
    end
  end
end
