unit UnitTable;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Grids, UnitModel, UnitResults, UnitOrganizer;

type
  TFormTable = class(TForm)
    StringGrid1: TStringGrid;
    Panel1: TPanel;
    btnUpdate: TButton;
    btnShowResultsrw: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnUpdateClick(Sender: TObject);
    procedure btnShowResultsrwClick(Sender: TObject);
    procedure StringGrid1DrawCell(Sender: TObject; ACol, ARow: LongInt;
      Rect: TRect; State: TGridDrawState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    //procedure btnShowResultsrwClick(Sender: TObject);
  private
    { Private-Deklarationen }
    procedure UpdateTable;
    procedure btnToggleGroupClick(Sender: TObject);
  private
    var
      FResultsForm: TFormResults;
      FCurrentGroup: Char;
      btnToggleGroup: TButton;
  public
    { Public-Deklarationen }
  end;

var
  FormTable: TFormTable;

implementation

{$R *.dfm}

procedure TFormTable.FormCreate(Sender: TObject);
begin
  AddOrganizerHeader(Self);   // Veranstalter-Kopfzeile oben

  // Spaltenbreiten und Ausrichtung einstellen
  StringGrid1.ColWidths[0] := 50;   // Platz
  StringGrid1.ColWidths[1] := 200;  // Mannschaft
  StringGrid1.ColWidths[2] := 60;   // Spiele
  StringGrid1.ColWidths[3] := 60;   // Punkte
  StringGrid1.ColWidths[4] := 60;   // Tore+
  StringGrid1.ColWidths[5] := 60;   // Tore-

  // Spaltentitel setzen
  StringGrid1.Cells[0,0] := 'Platz';
  StringGrid1.Cells[1,0] := 'Mannschaft';
  StringGrid1.Cells[2,0] := 'Spiele';
  StringGrid1.Cells[3,0] := 'Punkte';
  StringGrid1.Cells[4,0] := 'Tore +';
  StringGrid1.Cells[5,0] := 'Tore -';

  // Grundeinstellungen
  StringGrid1.FixedRows := 1;       // Erste Zeile fixiert
  StringGrid1.RowCount := 7;        // Maximal 6 Teams +
  StringGrid1.ColCount := 6;        // 6 Spalten

  // Groessere Schrift + hoehere Zeilen; alle Spalten zentriert (Owner-Draw)
  StringGrid1.DefaultDrawing := False;
  StringGrid1.Font.Size := 19;
  StringGrid1.DefaultRowHeight := 40;

  // Umschalter Gruppe A/B zur Laufzeit erzeugen (Ergebnisse-Button kommt aus der .dfm)
  FCurrentGroup := 'A';
  btnToggleGroup := TButton.Create(Self);
  with btnToggleGroup do
  begin
    Parent := Panel1;
    Left := btnShowResultsrw.Left + btnShowResultsrw.Width + 10;
    Top := btnUpdate.Top;
    Width := 120;
    Height := btnUpdate.Height;
    Caption := 'Gruppe wechseln';
    OnClick := btnToggleGroupClick;
  end;

  UpdateTable;
end;

 // ============  Zellen zeichnen: alle Spalten zentriert  ============
procedure TFormTable.StringGrid1DrawCell(Sender: TObject; ACol, ARow: LongInt;
  Rect: TRect; State: TGridDrawState);
var
  S: string;
begin
  with StringGrid1.Canvas do
  begin
    if ARow = 0 then
    begin
      Brush.Color := clYellow;   // Kopfzeile gelb
      Font.Style := [fsBold];
    end
    else
    begin
      Font.Style := [];
      if Odd(ARow) then
        Brush.Color := clWhite
      else
        Brush.Color := RGB(230, 236, 243);   // helles Zeilenraster (Zebra)
    end;
    FillRect(Rect);

    S := StringGrid1.Cells[ACol, ARow];
    if S <> '' then
    begin
      SetTextAlign(Handle, TA_CENTER);
      try
        TextRect(Rect,
          (Rect.Left + Rect.Right) div 2,
          Rect.Top + (Rect.Bottom - Rect.Top - TextHeight(S)) div 2,
          S);
      finally
        SetTextAlign(Handle, 0);
      end;
    end;
  end;
end;

//====================================================
procedure TFormTable.btnShowResultsrwClick(Sender: TObject);
begin
    // Ergebnisfenster erstellen falls noch nicht vorhanden
  if not Assigned(FResultsForm) then
  begin
    FResultsForm := TFormResults.Create(Self);
    FResultsForm.FormStyle := fsStayOnTop;  // Fenster bleibt im Vordergrund
  end;

  // Position neben dem Tabellenfenster
  FResultsForm.Left := Self.Left + Self.Width + 10;
  FResultsForm.Top := Self.Top;

  // Fenster anzeigen
  FResultsForm.Show;
end;

procedure TFormTable.btnToggleGroupClick(Sender: TObject);
begin
  if FCurrentGroup = 'A' then
    FCurrentGroup := 'B'
  else
    FCurrentGroup := 'A';
  UpdateTable;   // Fenstertitel zeigt die aktuelle Gruppe
end;

procedure TFormTable.btnUpdateClick(Sender: TObject);
begin

     // Spaltenbreiten und Ausrichtung einstellen
  StringGrid1.ColWidths[0] := 35;   // Platz
  StringGrid1.ColWidths[1] := 145;  // Mannschaft
  StringGrid1.ColWidths[2] := 46;   // Spiele
  StringGrid1.ColWidths[3] := 50;   // Punkte
  StringGrid1.ColWidths[4] := 55;   // Tore+
  StringGrid1.ColWidths[5] := 55;   // Tore-

  // Spaltentitel setzen
  StringGrid1.Cells[0,0] := 'Pl.';
  StringGrid1.Cells[1,0] := 'Vereine';
  StringGrid1.Cells[2,0] := 'Spl.';
  StringGrid1.Cells[3,0] := 'Pkt.';
  StringGrid1.Cells[4,0] := 'Tor+';
  StringGrid1.Cells[5,0] := 'Tor-';

  // Grundeinstellungen
  StringGrid1.FixedRows := 1;       // Erste Zeile fixiert
  StringGrid1.FixedColor := clYellow;
  StringGrid1.RowCount := 7;        // Maximal 6 Teams
  StringGrid1.ColCount := 6;        // 6 Spalten

  UpdateTable;
end;
   //===================================================


procedure TFormTable.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // Ergebnisfenster mit schließen
  if Assigned(FResultsForm) then
  begin
    FResultsForm.Close;
    FResultsForm.Free;
    FResultsForm := nil;
  end;
end;

procedure TFormTable.UpdateTable;
var
  Stats: TArray<TTeamStat>;
  i, r, c: Integer;
begin
  Caption := 'Tabelle - Gruppe ' + FCurrentGroup;

  // Datenzeilen leeren (Gruppen koennen unterschiedlich viele Teams haben)
  for r := 1 to StringGrid1.RowCount - 1 do
    for c := 0 to StringGrid1.ColCount - 1 do
      StringGrid1.Cells[c, r] := '';

  Stats := Tournament.ComputeTable(FCurrentGroup);

  for i := 0 to High(Stats) do
  begin
    StringGrid1.Cells[0, i + 1] := IntToStr(i + 1);
    StringGrid1.Cells[1, i + 1] := Stats[i].Name;
    StringGrid1.Cells[2, i + 1] := IntToStr(Stats[i].Games);
    StringGrid1.Cells[3, i + 1] := IntToStr(Stats[i].Points);
    StringGrid1.Cells[4, i + 1] := IntToStr(Stats[i].GoalsScored);
    StringGrid1.Cells[5, i + 1] := IntToStr(Stats[i].GoalsConceded);
  end;
end;

end.