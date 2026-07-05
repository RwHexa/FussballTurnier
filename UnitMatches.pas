unit UnitMatches;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, UnitModel;

type
  TFormMatches = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    cmbTeam1: TComboBox;
    cmbTeam2: TComboBox;
    edtGoals1: TEdit;
    edtGoals2: TEdit;
    btnAddMatch: TButton;
    ListBox1: TListBox;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnAddMatchClick(Sender: TObject);
  private
    { Private-Deklarationen }
    procedure UpdateTeamComboBoxes;
    procedure UpdateListBox;
  public
    { Public-Deklarationen }
  end;

var
  FormMatches: TFormMatches;

implementation

{$R *.dfm}

procedure TFormMatches.FormShow(Sender: TObject);
begin
  UpdateTeamComboBoxes;
  UpdateListBox;   // vorhandene Spiele anzeigen (Daten leben im Tournament-Modell)
end;

procedure TFormMatches.FormCreate(Sender: TObject);
begin
  // Spiele leben im Tournament-Modell; Persistenz zentral ueber Datei > Speichern (.trn).
end;

procedure TFormMatches.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // Speichern erfolgt zentral ueber Datei > Speichern (.trn).
end;

procedure TFormMatches.UpdateTeamComboBoxes;
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

procedure TFormMatches.UpdateListBox;
var
  i: Integer;
  M: TMatch;
begin
  ListBox1.Clear;
  for i := 0 to Tournament.MatchCount - 1 do
  begin
    M := Tournament.Match(i);
    ListBox1.Items.Add(Format('%s %d:%d %s', [M.Team1, M.Goals1, M.Goals2, M.Team2]));
  end;
end;

procedure TFormMatches.btnAddMatchClick(Sender: TObject);
var
  Goals1, Goals2: Integer;
begin
  if (cmbTeam1.ItemIndex = -1) or (cmbTeam2.ItemIndex = -1) then
  begin
    ShowMessage('Bitte wählen Sie beide Mannschaften aus!');
    Exit;
  end;

  if cmbTeam1.ItemIndex = cmbTeam2.ItemIndex then
  begin
    ShowMessage('Eine Mannschaft kann nicht gegen sich selbst spielen!');
    Exit;
  end;

  if Tournament.GroupOfTeam(cmbTeam1.Text) <> Tournament.GroupOfTeam(cmbTeam2.Text) then
  begin
    ShowMessage('Gruppenspiel: Beide Mannschaften müssen aus derselben Gruppe sein!');
    Exit;
  end;

  if not TryStrToInt(edtGoals1.Text, Goals1) or not TryStrToInt(edtGoals2.Text, Goals2) then
  begin
    ShowMessage('Bitte geben Sie gültige Tore ein!');
    Exit;
  end;

  Tournament.AddMatch(cmbTeam1.Text, cmbTeam2.Text, Goals1, Goals2);
  UpdateListBox;
end;

end.
