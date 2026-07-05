unit UnitKO;

// KO-Runde: Eingabe (TFormKO) + Beamer-Uebersicht / Turnierbaum (TFormKOView).
// Beide Formulare komplett im Code aufgebaut (kein .dfm / Designer noetig).

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, System.Types, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, UnitModel;

type
  TFormKO = class(TForm)
  private
    cmbA, cmbB: array[1..3] of TComboBox;
    edtA, edtB: array[1..3] of TEdit;
    procedure BuildBlock(Slot: Integer; const ATitle: string; ATop: Integer);
    procedure BuildUI;
    procedure FillCombos;
    procedure LoadFromModel;
    procedure FormShow(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TFormKOView = class(TForm)
  private
    FTimer: TTimer;
    procedure ViewPaint(Sender: TObject);
    procedure TimerTick(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
  end;

var
  FormKO: TFormKO;
  FormKOView: TFormKOView;

implementation

{ ==== TFormKO (Eingabe) ==== }

constructor TFormKO.Create(AOwner: TComponent);
begin
  inherited CreateNew(AOwner);   // ohne DFM
  Caption := 'KO-Runde';
  BorderStyle := bsSizeable;
  Position := poScreenCenter;
  ClientWidth := 630;
  ClientHeight := 410;
  Color := RGB(233, 238, 242);
  Font.Name := 'Segoe UI';
  Font.Size := 12;               // Basis-Schrift; Combos/Felder erben sie
  OnShow := FormShow;
  BuildUI;
end;

procedure TFormKO.BuildBlock(Slot: Integer; const ATitle: string; ATop: Integer);
var
  lblTitle, lblVs, lblColon: TLabel;
begin
  lblTitle := TLabel.Create(Self);
  lblTitle.Parent := Self;
  lblTitle.SetBounds(24, ATop, 340, 26);
  lblTitle.Caption := ATitle;
  lblTitle.Transparent := True;
  lblTitle.Font.Style := [fsBold];
  lblTitle.Font.Size := 14;
  lblTitle.Font.Color := RGB(34, 34, 51);

  cmbA[Slot] := TComboBox.Create(Self);
  cmbA[Slot].Parent := Self;
  cmbA[Slot].SetBounds(24, ATop + 30, 195, 32);
  cmbA[Slot].Style := csDropDownList;

  lblVs := TLabel.Create(Self);
  lblVs.Parent := Self;
  lblVs.SetBounds(226, ATop + 37, 20, 22);
  lblVs.Caption := '-';
  lblVs.Transparent := True;

  cmbB[Slot] := TComboBox.Create(Self);
  cmbB[Slot].Parent := Self;
  cmbB[Slot].SetBounds(250, ATop + 30, 195, 32);
  cmbB[Slot].Style := csDropDownList;

  edtA[Slot] := TEdit.Create(Self);
  edtA[Slot].Parent := Self;
  edtA[Slot].SetBounds(472, ATop + 30, 52, 32);
  edtA[Slot].Text := '0';
  edtA[Slot].Alignment := taCenter;

  lblColon := TLabel.Create(Self);
  lblColon.Parent := Self;
  lblColon.SetBounds(530, ATop + 37, 12, 22);
  lblColon.Caption := ':';
  lblColon.Transparent := True;

  edtB[Slot] := TEdit.Create(Self);
  edtB[Slot].Parent := Self;
  edtB[Slot].SetBounds(546, ATop + 30, 52, 32);
  edtB[Slot].Text := '0';
  edtB[Slot].Alignment := taCenter;
end;

procedure TFormKO.BuildUI;
var
  btnSave: TButton;
begin
  BuildBlock(1, 'Halbfinale 1', 24);
  BuildBlock(2, 'Halbfinale 2', 132);
  BuildBlock(3, 'Endspiel', 240);

  btnSave := TButton.Create(Self);
  btnSave.Parent := Self;
  btnSave.SetBounds(470, 345, 128, 34);
  btnSave.Caption := 'Speichern';
  btnSave.OnClick := btnSaveClick;
end;

procedure TFormKO.FillCombos;
var
  s, i: Integer;
begin
  for s := 1 to 3 do
  begin
    cmbA[s].Items.Clear;
    cmbB[s].Items.Clear;
    for i := 1 to Tournament.TeamCount do
    begin
      cmbA[s].Items.Add(Tournament.TeamName(i));
      cmbB[s].Items.Add(Tournament.TeamName(i));
    end;
  end;
end;

procedure TFormKO.LoadFromModel;
var
  s: Integer;
  M: TMatch;
begin
  for s := 1 to 3 do
  begin
    M := Tournament.KO(s);
    cmbA[s].ItemIndex := cmbA[s].Items.IndexOf(M.Team1);
    cmbB[s].ItemIndex := cmbB[s].Items.IndexOf(M.Team2);
    edtA[s].Text := IntToStr(M.Goals1);
    edtB[s].Text := IntToStr(M.Goals2);
  end;
end;

procedure TFormKO.FormShow(Sender: TObject);
begin
  FillCombos;
  LoadFromModel;   // ItemIndex erst hier setzen (Handle existiert -> wird angezeigt)
end;

procedure TFormKO.btnSaveClick(Sender: TObject);
var
  s, G1, G2: Integer;
  T1, T2: string;
begin
  for s := 1 to 3 do
  begin
    if cmbA[s].ItemIndex >= 0 then T1 := cmbA[s].Text else T1 := '';
    if cmbB[s].ItemIndex >= 0 then T2 := cmbB[s].Text else T2 := '';
    G1 := StrToIntDef(edtA[s].Text, 0);
    G2 := StrToIntDef(edtB[s].Text, 0);
    Tournament.SetKO(s, T1, T2, G1, G2);
  end;
  ShowMessage('KO-Runde uebernommen. Dauerhaft sichern ueber Datei > Speichern.');
end;

{ ==== Helfer fuer die Beamer-Uebersicht ==== }

function WinnerOf(const M: TMatch): Integer;   // 1, 2 oder 0 (kein Sieger)
begin
  if (Trim(M.Team1) = '') or (Trim(M.Team2) = '') then
    Exit(0);
  if M.Goals1 > M.Goals2 then
    Result := 1
  else if M.Goals2 > M.Goals1 then
    Result := 2
  else
    Result := 0;
end;

procedure DrawTeamBox(C: TCanvas; L, T, W, H: Integer; const AName: string;
  AScore: Integer; AWinner, AShowScore: Boolean);
var
  ty: Integer;
  sc: string;
begin
  if AWinner then
    C.Brush.Color := RGB(198, 231, 178)   // gruen: Sieger
  else
    C.Brush.Color := clWhite;
  C.Pen.Color := RGB(150, 160, 170);
  C.Pen.Width := 1;
  C.RoundRect(L, T, L + W, T + H, 12, 12);

  C.Brush.Style := bsClear;
  ty := T + (H - C.TextHeight('Ag')) div 2;
  if AWinner then C.Font.Style := [fsBold] else C.Font.Style := [];
  C.Font.Color := RGB(30, 30, 45);
  if AName <> '' then
    C.TextRect(Rect(L + 14, T, L + W - 54, T + H), L + 14, ty, AName);

  if AShowScore then
  begin
    sc := IntToStr(AScore);
    C.Font.Style := [fsBold];
    C.TextRect(Rect(L + W - 50, T, L + W, T + H),
      L + W - 50 + (50 - C.TextWidth(sc)) div 2, ty, sc);
  end;
  C.Brush.Style := bsSolid;
end;

{ ==== TFormKOView (Beamer-Turnierbaum) ==== }

constructor TFormKOView.Create(AOwner: TComponent);
begin
  inherited CreateNew(AOwner);
  Caption := 'KO-Uebersicht';
  Position := poScreenCenter;
  ClientWidth := 1000;
  ClientHeight := 640;
  Color := RGB(233, 238, 242);
  DoubleBuffered := True;
  Font.Name := 'Segoe UI';
  OnPaint := ViewPaint;

  FTimer := TTimer.Create(Self);
  FTimer.Interval := 1500;
  FTimer.OnTimer := TimerTick;
  FTimer.Enabled := True;
end;

procedure TFormKOView.TimerTick(Sender: TObject);
begin
  Invalidate;   // regelmaessig neu zeichnen -> zeigt den aktuellen KO-Stand
end;

procedure TFormKOView.ViewPaint(Sender: TObject);
var
  C: TCanvas;
  W, H, boxW, boxH, gap, col1X, col2X, col3X: Integer;
  cy1, cy2, cyf, fTopY, fBotY, midX1, midX2: Integer;
  mHF1, mHF2, mF: TMatch;
  chName: string; chWin: Integer;

  procedure Pair(const M: TMatch; X, CenterY: Integer);
  var w: Integer;
  begin
    w := WinnerOf(M);
    DrawTeamBox(C, X, CenterY - boxH - gap div 2, boxW, boxH, M.Team1, M.Goals1,
      w = 1, Trim(M.Team1) <> '');
    DrawTeamBox(C, X, CenterY + gap div 2, boxW, boxH, M.Team2, M.Goals2,
      w = 2, Trim(M.Team2) <> '');
  end;

begin
  C := Canvas;
  W := ClientWidth; H := ClientHeight;

  C.Brush.Color := RGB(233, 238, 242);
  C.FillRect(ClientRect);

  boxW := 300; boxH := 56; gap := 16;
  col1X := 50;
  col3X := W - 50 - boxW;
  col2X := (col1X + col3X) div 2;
  cy1 := Round(H * 0.30);
  cy2 := Round(H * 0.70);
  cyf := H div 2;
  fTopY := cyf - boxH div 2 - gap div 2;   // Mitte der oberen Finalbox
  fBotY := cyf + boxH div 2 + gap div 2;   // Mitte der unteren Finalbox
  midX1 := (col1X + boxW + col2X) div 2;
  midX2 := (col2X + boxW + col3X) div 2;

  mHF1 := Tournament.KO(1);
  mHF2 := Tournament.KO(2);
  mF   := Tournament.KO(3);

  // Ueberschriften
  C.Brush.Style := bsClear;
  C.Font.Style := [fsBold];
  C.Font.Size := 20;
  C.Font.Color := RGB(60, 75, 90);
  C.TextOut(col1X, 22, 'Halbfinale');
  C.TextOut(col2X, 22, 'Endspiel');
  C.TextOut(col3X, 22, 'Sieger');
  C.Brush.Style := bsSolid;

  // Verbindungslinien (vor den Boxen)
  C.Pen.Color := RGB(150, 160, 170);
  C.Pen.Width := 2;
  C.MoveTo(col1X + boxW, cy1); C.LineTo(midX1, cy1);
  C.LineTo(midX1, fTopY);      C.LineTo(col2X, fTopY);
  C.MoveTo(col1X + boxW, cy2); C.LineTo(midX1, cy2);
  C.LineTo(midX1, fBotY);      C.LineTo(col2X, fBotY);
  C.MoveTo(col2X + boxW, cyf); C.LineTo(midX2, cyf); C.LineTo(col3X, cyf);

  // Boxen
  C.Font.Size := 18;
  Pair(mHF1, col1X, cy1);
  Pair(mHF2, col1X, cy2);
  Pair(mF, col2X, cyf);

  // Sieger
  chWin := WinnerOf(mF);
  if chWin = 1 then chName := mF.Team1
  else if chWin = 2 then chName := mF.Team2
  else chName := '?';
  DrawTeamBox(C, col3X, cyf - boxH div 2, boxW, boxH, chName, 0, chWin <> 0, False);
end;

end.
