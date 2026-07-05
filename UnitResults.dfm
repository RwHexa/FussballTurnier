object FormResults: TFormResults
  Left = 0
  Top = 0
  Caption = 'Ergebnisliste'
  ClientHeight = 400
  ClientWidth = 600
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
    Width = 600
    Height = 400
    Align = alClient
    TabOrder = 0
    object StringGrid1: TStringGrid
      Left = 24
      Top = 56
      Width = 553
      Height = 321
      ColCount = 4
      DrawingStyle = gdsClassic
      FixedCols = 0
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
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
  end
end
