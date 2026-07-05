unit UnitMain;

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.ShellAPI, System.SysUtils, System.Variants, System.Classes, 
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Menus, UnitTeams, UnitMatches, UnitCurrentMatches, UnitTable, UnitResults, UnitModel, UnitKO, UnitExport, UnitOrganizer,
  Vcl.Imaging.jpeg, Vcl.Imaging.pngimage;

type
  TFormMain = class(TForm)
    MainMenu1: TMainMenu;
    mnuDatei: TMenuItem;
    mnuDateiNeu: TMenuItem;
    mnuDateiOeffnen: TMenuItem;
    mnuDateiSpeichern: TMenuItem;
    mnuDateiSpeichernUnter: TMenuItem;
    mnuDateiTrennlinie: TMenuItem;
    mnuDateiBeenden: TMenuItem;
    mnuTurnier: TMenuItem;
    mnuTurnierMannschaften: TMenuItem;
    mnuTurnierSpiele: TMenuItem;
    mnuTurnierTabelle: TMenuItem;
    mnuTurnierErgebnisse: TMenuItem;
    SaveDialog1: TSaveDialog;
    OpenDialog1: TOpenDialog;
    Image1: TImage;
    mnuSpielInfo: TMenuItem;
    mnuSpielInfoAktuell: TMenuItem;
    Label1: TLabel;
    Image2: TImage;
    procedure FormCreate(Sender: TObject);
    procedure mnuDateiBeendenClick(Sender: TObject);
    procedure mnuTurnierMannschaftenClick(Sender: TObject);
    procedure mnuTurnierSpieleClick(Sender: TObject);
    procedure mnuTurnierTabelleClick(Sender: TObject);
    procedure mnuTurnierErgebnisseClick(Sender: TObject);
    procedure mnuDateiNeuClick(Sender: TObject);
    procedure mnuDateiOeffnenClick(Sender: TObject);
    procedure mnuDateiSpeichernClick(Sender: TObject);
    procedure mnuDateiSpeichernUnterClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure mnuSpielInfoAktuellClick(Sender: TObject);
  private
    procedure mnuTurnierKOClick(Sender: TObject);
    procedure mnuTurnierKOViewClick(Sender: TObject);
    procedure mnuDateiAushangClick(Sender: TObject);
    procedure mnuDateiVeranstalterClick(Sender: TObject);
  public
    { Public-Deklarationen }
  end;

var
  FormMain: TFormMain;
  FormTable: TFormTable;
  FormResults: TFormResults;

implementation

{$R *.dfm}

const
  APP_VERSION = '2.0';

procedure TFormMain.FormCreate(Sender: TObject);
var
  imgLogo: TImage;
  lblHeading: TLabel;
  pnlHeader, pnlFooter: TPanel;
  PosterFile, LogoFile: string;

  function FindAsset(const AName: string): string;
  begin
    Result := ExtractFilePath(Application.ExeName) + AName;      // neben der exe
    if FileExists(Result) then Exit;
    Result := ExtractFilePath(Application.ExeName) + '..\..\' + AName;  // Projektordner (F9)
    if not FileExists(Result) then
      Result := '';
  end;

begin
  Caption := 'Fußball-Turnier-Verwaltung';
  Color := RGB(233, 238, 242);   // helles Neutral (Blaugrau)

  // Alte Elemente ausblenden: Datumszeile + HTV-Logo
  Label1.Visible := False;
  Image2.Visible := False;

  // --- Kopfbereich oben (volle Breite) ---
  pnlHeader := TPanel.Create(Self);
  pnlHeader.Parent := Self;
  pnlHeader.Align := alTop;
  pnlHeader.Height := 92;
  pnlHeader.BevelOuter := bvNone;
  pnlHeader.ParentBackground := False;
  pnlHeader.Color := RGB(233, 238, 242);

  imgLogo := TImage.Create(Self);
  imgLogo.Parent := pnlHeader;
  imgLogo.SetBounds(24, 14, 64, 64);
  imgLogo.Proportional := True;
  imgLogo.Stretch := True;
  imgLogo.Center := True;
  LogoFile := FindAsset('logorw96.png');
  if LogoFile <> '' then
    imgLogo.Picture.LoadFromFile(LogoFile);

  lblHeading := TLabel.Create(Self);
  lblHeading.Parent := pnlHeader;
  lblHeading.SetBounds(100, 24, 500, 44);
  lblHeading.Transparent := True;
  lblHeading.Caption := 'Fußball-Turnier-Verwaltung';
  lblHeading.Font.Name := 'Segoe UI';
  lblHeading.Font.Size := 24;
  lblHeading.Font.Style := [fsBold];
  lblHeading.Font.Color := RGB(34, 34, 51);

  // --- Fusszeile unten (volle Breite) ---
  pnlFooter := TPanel.Create(Self);
  pnlFooter.Parent := Self;
  pnlFooter.Align := alBottom;
  pnlFooter.Height := 26;
  pnlFooter.BevelOuter := bvNone;
  pnlFooter.ParentBackground := False;
  pnlFooter.Color := RGB(43, 58, 74);            // dunkles Blaugrau
  pnlFooter.Font.Name := 'Segoe UI';
  pnlFooter.Font.Size := 9;
  pnlFooter.Font.Color := RGB(222, 230, 238);    // helle Schrift
  pnlFooter.Caption := #$00A9' 2026 RwTec    |    Fußball-Turnier-Verwaltung    |    Version ' + APP_VERSION;

  // --- Poster in der Mitte: zentriert und skaliert mit dem Fenster ---
  Image1.Align := alClient;
  Image1.Proportional := True;
  Image1.Stretch := True;
  Image1.Center := True;
  PosterFile := FindAsset('MasbeckPoster.jpg');
  if PosterFile <> '' then
    Image1.Picture.LoadFromFile(PosterFile);

  // KO-Runde ins Menue "Turnier" einhaengen (zur Laufzeit)
  mnuTurnier.Add(NewItem('KO-Runde', 0, False, True, mnuTurnierKOClick, 0, 'mnuTurnierKO'));
  mnuTurnier.Add(NewItem('KO-Übersicht (Beamer)', 0, False, True, mnuTurnierKOViewClick, 0, 'mnuTurnierKOView'));

  // Veranstalter + Aushang ins Datei-Menue (vor der Trennlinie einfuegen)
  mnuDatei.Insert(mnuDatei.IndexOf(mnuDateiTrennlinie),
    NewItem('Veranstalter...', 0, False, True, mnuDateiVeranstalterClick, 0, 'mnuDateiVeranstalter'));
  mnuDatei.Insert(mnuDatei.IndexOf(mnuDateiTrennlinie),
    NewItem('Aushang erstellen...', 0, False, True, mnuDateiAushangClick, 0, 'mnuDateiAushang'));
end;

procedure TFormMain.FormDestroy(Sender: TObject);
begin
  //SaveDialog1.Free;
  //OpenDialog1.Free;
  if Assigned(FormCurrentMatches) then
    FormCurrentMatches.Free;
  if Assigned(FormTable) then
    FormTable.Free;
  if Assigned(FormResults) then
    FormResults.Free;
  if Assigned(FormKOView) then
    FormKOView.Free;
end;

procedure TFormMain.mnuDateiNeuClick(Sender: TObject);
begin
  if MessageDlg('Möchten Sie wirklich ein neues Turnier beginnen?' + #13 +
                'Alle aktuellen Daten gehen verloren!',
                mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    Tournament.ClearAll;
    SaveDialog1.FileName := '';
  end;
end;

procedure TFormMain.mnuDateiOeffnenClick(Sender: TObject);
begin
  OpenDialog1.Filter := 'Turnier Dateien (*.trn)|*.trn';
  OpenDialog1.DefaultExt := 'trn';

  if OpenDialog1.Execute then
  begin
    if MessageDlg('Möchten Sie das aktuelle Turnier laden?' + #13 +
                  'Alle nicht gespeicherten Daten gehen verloren!',
                  mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      Tournament.LoadFromFile(OpenDialog1.FileName);
      SaveDialog1.FileName := OpenDialog1.FileName;
      ShowMessage('Turnierdaten wurden geladen.');
    end;
  end;
end;

procedure TFormMain.mnuDateiSpeichernClick(Sender: TObject);
begin
  if SaveDialog1.FileName = '' then
    mnuDateiSpeichernUnterClick(Sender)
  else
    mnuDateiSpeichernUnterClick(Sender);
end;

procedure TFormMain.mnuDateiSpeichernUnterClick(Sender: TObject);
begin
  SaveDialog1.Filter := 'Turnier Dateien (*.trn)|*.trn';
  SaveDialog1.DefaultExt := 'trn';

  if SaveDialog1.Execute then
  begin
    Tournament.SaveToFile(SaveDialog1.FileName);
    ShowMessage('Turnierdaten wurden gespeichert.');
  end;
end;

procedure TFormMain.mnuSpielInfoAktuellClick(Sender: TObject);
begin
  if FormCurrentMatches = nil then
  begin
    FormCurrentMatches := TFormCurrentMatches.Create(Application);
    FormCurrentMatches.Show;  // Nicht-modal anzeigen
  end
  else
    FormCurrentMatches.Show;  // Falls bereits erstellt, nur anzeigen
end;

procedure TFormMain.mnuDateiBeendenClick(Sender: TObject);
begin
  Close;
end;

procedure TFormMain.mnuTurnierMannschaftenClick(Sender: TObject);
begin
  FormTeams := TFormTeams.Create(Application);
  try
    FormTeams.ShowModal;
  finally
    FormTeams.Free;
  end;
end;

procedure TFormMain.mnuTurnierSpieleClick(Sender: TObject);
begin
  FormMatches := TFormMatches.Create(Application);
  try
    FormMatches.ShowModal;
  finally
    FormMatches.Free;
  end;
end;

procedure TFormMain.mnuTurnierTabelleClick(Sender: TObject);
begin
  if FormTable = nil then
  begin
    FormTable := TFormTable.Create(Application);
    FormTable.Show;  // Nicht-modal
  end
  else
    FormTable.Show;
end;

procedure TFormMain.mnuTurnierErgebnisseClick(Sender: TObject);
begin
  if FormResults = nil then
  begin
    FormResults := TFormResults.Create(Application);
    FormResults.Show;  // Nicht-modal
  end
  else
    FormResults.Show;
end;

procedure TFormMain.mnuTurnierKOClick(Sender: TObject);
begin
  FormKO := TFormKO.Create(Application);
  try
    FormKO.ShowModal;
  finally
    FormKO.Free;
  end;
end;

procedure TFormMain.mnuTurnierKOViewClick(Sender: TObject);
begin
  if FormKOView = nil then
    FormKOView := TFormKOView.Create(Application);
  FormKOView.Show;   // nicht-modal (Beamer-Fenster bleibt offen)
end;

procedure TFormMain.mnuDateiAushangClick(Sender: TObject);
var
  dlg: TSaveDialog;
begin
  dlg := TSaveDialog.Create(nil);
  try
    dlg.Filter := 'HTML-Dateien (*.html)|*.html';
    dlg.DefaultExt := 'html';
    dlg.FileName := 'Turnier-Aushang.html';
    if dlg.Execute then
    begin
      ExportAushangHtml(dlg.FileName);
      ShellExecute(0, 'open', PChar(dlg.FileName), nil, nil, SW_SHOWNORMAL);
    end;
  finally
    dlg.Free;
  end;
end;

procedure TFormMain.mnuDateiVeranstalterClick(Sender: TObject);
begin
  FormOrganizer := TFormOrganizer.Create(Application);
  try
    FormOrganizer.ShowModal;
  finally
    FormOrganizer.Free;
  end;
end;

end.
