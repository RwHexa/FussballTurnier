unit UnitCurrentMatches;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  UnitModel;

type
  TFormCurrentMatches = class(TForm)
    Panel1: TPanel;
    cmbTeam1: TComboBox;
    cmbTeam2: TComboBox;
    lblTeam1: TLabel;
    lblTeam2: TLabel;
    lblVS: TLabel;
    lblScore: TLabel;
    edtGoals1: TEdit;
    edtGoals2: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure edtGoals1Change(Sender: TObject);
    procedure edtGoals2Change(Sender: TObject);
    procedure cmbTeam1Change(Sender: TObject);
    procedure cmbTeam2Change(Sender: TObject);
    procedure EditClick(Sender: TObject);
  private
    procedure UpdateTeamComboBoxes;
    procedure ValidateGoals(const Edit: TEdit);
    procedure ComboBoxDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
  public
  end;

var
  FormCurrentMatches: TFormCurrentMatches;

implementation

{$R *.dfm}

procedure TFormCurrentMatches.FormCreate(Sender: TObject);
begin
  Caption := 'Aktuelles Spiel';
  
  // Editfelder vorbereiten
  edtGoals1.Text := '0';
  edtGoals2.Text := '0';

  // Wenn der User klickt, den Inhalt selektieren
  edtGoals1.OnClick := EditClick;
  edtGoals2.OnClick := EditClick;

  // ComboBoxen formatieren - Reihenfolge ist wichtig!
  // 1. Erst Style setzen
  cmbTeam1.Style := csOwnerDrawFixed;
  cmbTeam2.Style := csOwnerDrawFixed;
  
  // 2. Dann Font einstellen
  with cmbTeam1.Font do
  begin
    Name := 'Segoe UI';
    Size := 21;
    Style := [fsBold];
  end;
  cmbTeam2.Font.Assign(cmbTeam1.Font);
  
  // 3. ItemHeight für Dropdown-Liste setzen
  cmbTeam1.ItemHeight := 40;
  cmbTeam2.ItemHeight := 40;
  
  // 4. Gesamthöhe der ComboBox setzen
  cmbTeam1.Height := 60;
  cmbTeam2.Height := 60;
  
  // 5. Zum Schluss DrawItem-Handler
  cmbTeam1.OnDrawItem := ComboBoxDrawItem;
  cmbTeam2.OnDrawItem := ComboBoxDrawItem;
end;

procedure TFormCurrentMatches.FormShow(Sender: TObject);
begin
  UpdateTeamComboBoxes;
end;

procedure TFormCurrentMatches.UpdateTeamComboBoxes;
var
  i: Integer;
begin
  cmbTeam1.Clear;
  cmbTeam2.Clear;
  for i := 1 to Tournament.TeamCount do
  begin
    cmbTeam1.Items.Add(Tournament.TeamName(i));
    cmbTeam2.Items.Add(Tournament.TeamName(i));
  end;
end;

procedure TFormCurrentMatches.ValidateGoals(const Edit: TEdit);
var
  Value: Integer;
begin
  // Nur Zahlen zwischen 0 und 99 erlauben
  if not TryStrToInt(Edit.Text, Value) then
    Edit.Text := '0'
  else if (Value < 0) then
    Edit.Text := '0'
  else if (Value > 99) then
    Edit.Text := '99';
end;

procedure TFormCurrentMatches.cmbTeam1Change(Sender: TObject);
begin
  if cmbTeam1.ItemIndex = cmbTeam2.ItemIndex then
  begin
    ShowMessage('Eine Mannschaft kann nicht gegen sich selbst spielen!');
    cmbTeam1.ItemIndex := -1;
  end;
end;

procedure TFormCurrentMatches.cmbTeam2Change(Sender: TObject);
begin
  if cmbTeam2.ItemIndex = cmbTeam1.ItemIndex then
  begin
    ShowMessage('Eine Mannschaft kann nicht gegen sich selbst spielen!');
    cmbTeam2.ItemIndex := -1;
  end;
end;

procedure TFormCurrentMatches.edtGoals1Change(Sender: TObject);
var
  Value: Integer;
begin
  // Wenn leer, dann 0 setzen
  if edtGoals1.Text = '' then
    edtGoals1.Text := '0'
  // Wenn eine Zahl eingegeben wird und vorher nur 0 stand
  else if (Length(edtGoals1.Text) > 1) and (edtGoals1.Text = '0' + edtGoals1.Text[Length(edtGoals1.Text)]) then
  begin
    // Nur die neue Ziffer behalten
    edtGoals1.Text := edtGoals1.Text[Length(edtGoals1.Text)];
    edtGoals1.SelStart := 1;  // Cursor ans Ende setzen
  end;
  ValidateGoals(edtGoals1);
end;

procedure TFormCurrentMatches.edtGoals2Change(Sender: TObject);
var
  Value: Integer;
begin
  // Wenn leer, dann 0 setzen
  if edtGoals2.Text = '' then
    edtGoals2.Text := '0'
  // Wenn eine Zahl eingegeben wird und vorher nur 0 stand
  else if (Length(edtGoals2.Text) > 1) and (edtGoals2.Text = '0' + edtGoals2.Text[Length(edtGoals2.Text)]) then
  begin
    // Nur die neue Ziffer behalten
    edtGoals2.Text := edtGoals2.Text[Length(edtGoals2.Text)];
    edtGoals2.SelStart := 1;  // Cursor ans Ende setzen
  end;
  ValidateGoals(edtGoals2);
end;

procedure TFormCurrentMatches.EditClick(Sender: TObject);
begin
  if Sender is TEdit then
  begin
    TEdit(Sender).SelectAll;  // Alles markieren
    TEdit(Sender).SelStart := Length(TEdit(Sender).Text);  // Cursor ans Ende
  end;
end;

procedure TFormCurrentMatches.ComboBoxDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
const
  PADDING = 12; // Mehr Padding für größere Schrift
var
  ComboBox: TComboBox;
  TextRect: TRect;
  SavedStyle: TFontStyles;
begin
  if Control is TComboBox then
  begin
    ComboBox := TComboBox(Control);
    
    // Canvas-Font auf ComboBox-Font setzen
    ComboBox.Canvas.Font := ComboBox.Font;
    
    // Ausgewähltes Item hervorheben
    if odSelected in State then
    begin
      ComboBox.Canvas.Brush.Color := clHighlight;
      ComboBox.Canvas.Font.Color := clHighlightText;
    end
    else
    begin
      ComboBox.Canvas.Brush.Color := ComboBox.Color;
      ComboBox.Canvas.Font.Color := ComboBox.Font.Color;
    end;
    
    // Hintergrund zeichnen
    ComboBox.Canvas.FillRect(Rect);
    
    // Text-Rechteck mit Padding erstellen
    TextRect := Rect;
    TextRect.Left := TextRect.Left + PADDING;
    
    // Text zentriert zeichnen
    ComboBox.Canvas.TextRect(TextRect, TextRect.Left,
      TextRect.Top + (TextRect.Height - ComboBox.Canvas.TextHeight('Ag')) div 2,
      ComboBox.Items[Index]);
  end;
end;

end.
