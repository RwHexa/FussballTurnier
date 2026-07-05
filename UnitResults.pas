unit UnitResults;

{$R *.dfm}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Grids, UnitModel, UnitOrganizer, System.Types;

type
  TFormResults = class(TForm)
    StringGrid1: TStringGrid;
    Panel1: TPanel;
    btnUpdate: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnUpdateClick(Sender: TObject);
    procedure StringGrid1DrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
  private
    procedure SetupGridColumns;
    procedure UpdateResults;
  public
    { Public-Deklarationen }
  end;

var
  FormResults: TFormResults;

implementation

procedure TFormResults.SetupGridColumns;
var
  i: Integer;
begin
  with StringGrid1 do begin
    // Spaltenbreiten und Ausrichtung
    ColWidths[0] := 50;   // Nr.
    ColWidths[1] := 190;  // Heim
    ColWidths[2] := 80;   // Ergebnis
    ColWidths[3] := 190;  // Gast
    
    // Für jede Spalte die Ausrichtung setzen
    for i := 0 to ColCount-1 do begin
      Canvas.Font.Style := [fsBold];  // Für Breitenberechnung
      ColWidths[i] := ColWidths[i] + 10;  // Etwas Zusatzbreite
    end;
  end;
end;

procedure TFormResults.FormCreate(Sender: TObject);
begin
  AddOrganizerHeader(Self);                          // Veranstalter-Kopfzeile oben
  StringGrid1.Anchors := [akLeft, akTop, akBottom];  // Grid nach unten mitwachsen lassen

  BorderStyle := bsSizeable;  // Fenster kann in der Größe verändert werden
  FormStyle := fsStayOnTop;   // Bleibt im Vordergrund
  Position := poDesigned;     // Verwendet die Position, die wir setzen
  
  with StringGrid1 do begin
    // Grundeinstellungen
    ColCount := 4;
    RowCount := 2;      // mind. 2, damit FixedRows := 1 gueltig ist
    FixedRows := 1;
    FixedCols := 0;
    DefaultDrawing := False;  // Wichtig: Muss False sein!
    DrawingStyle := gdsClassic;
    Options := Options + [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine];
    
    // Formatierung
    FixedColor := clYellow;
    Font.Size := 19;          // gleiche Groesse wie in der Tabelle
    DefaultRowHeight := 40;

    // Spaltentitel (Kopfzeile) - sonst beim Oeffnen leer
    Cells[0,0] := 'Nr.';
    Cells[1,0] := 'Heim';
    Cells[2,0] := '---';
    Cells[3,0] := 'Gast';
    Font.Style := [];  // Normal für Daten
    
    // Event-Handler
    OnDrawCell := StringGrid1DrawCell;
  end;
  
  SetupGridColumns;  // Spalten einrichten
  UpdateResults;
  
  // Event-Handler explizit zuweisen
  StringGrid1.OnDrawCell := StringGrid1DrawCell;
end;

procedure TFormResults.StringGrid1DrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
begin
  //ShowMessage('DrawCell wird aufgerufen!');  // Zum Testen
  
  with StringGrid1.Canvas do begin
    // Hintergrund
    if ARow = 0 then begin
      Brush.Color := clYellow;
      Font.Style := [fsBold];
    end else begin
      Font.Style := [];
      if Odd(ARow) then
        Brush.Color := clWhite
      else
        Brush.Color := RGB(230, 236, 243);  // helles Zeilenraster (Zebra)
    end;
    
    // Hintergrund zeichnen
    FillRect(Rect);
    
    // Text holen und zentrieren
    if StringGrid1.Cells[ACol, ARow] <> '' then begin
      SetTextAlign(Handle, TA_CENTER);
      try
        TextRect(Rect, 
                Rect.Left + (Rect.Right - Rect.Left) div 2,
                Rect.Top + (Rect.Bottom - Rect.Top - TextHeight(StringGrid1.Cells[ACol, ARow])) div 2,
                StringGrid1.Cells[ACol, ARow]);
      finally
        SetTextAlign(Handle, 0);  // Zurücksetzen auf Standard
      end;
    end;
  end;
end;

procedure TFormResults.btnUpdateClick(Sender: TObject);
begin
  with StringGrid1 do begin
    // Überschriften
    Cells[0,0] := 'Nr.';
    Cells[1,0] := 'Heim';
    Cells[2,0] := '---';
    Cells[3,0] := 'Gast';
  end;
  
  UpdateResults;
  StringGrid1.Invalidate;  // Grid neu zeichnen
end;

procedure TFormResults.UpdateResults;
var
  i: Integer;
  M: TMatch;
begin
  if Tournament.MatchCount = 0 then
    StringGrid1.RowCount := 2                        // mind. 2 (FixedRows = 1)
  else
    StringGrid1.RowCount := Tournament.MatchCount + 1;

  for i := 0 to Tournament.MatchCount - 1 do
  begin
    M := Tournament.Match(i);
    StringGrid1.Cells[0, i + 1] := IntToStr(i + 1);
    StringGrid1.Cells[1, i + 1] := M.Team1;
    StringGrid1.Cells[2, i + 1] := Format('%d:%d', [M.Goals1, M.Goals2]);
    StringGrid1.Cells[3, i + 1] := M.Team2;
  end;
end;

end.