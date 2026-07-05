unit UnitTeams;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, UnitModel;

type
  TFormTeams = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    edtTeamName: TEdit;
    btnAddTeam: TButton;
    ListBox1: TListBox;
    btnDeleteTeam: TButton;
    procedure btnAddTeamClick(Sender: TObject);
    procedure btnDeleteTeamClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private-Deklarationen }
    rgGroup: TRadioGroup;
    procedure UpdateListBox;
  public
    { Public-Deklarationen }
  end;

var
  FormTeams: TFormTeams;

implementation

{$R *.dfm}

procedure TFormTeams.FormCreate(Sender: TObject);
begin
  // Gruppen-Auswahl (A/B) zur Laufzeit erzeugen
  rgGroup := TRadioGroup.Create(Self);
  rgGroup.Parent := Panel1;
  rgGroup.Left := 24;
  rgGroup.Top := 70;
  rgGroup.Width := 249;
  rgGroup.Height := 45;
  rgGroup.Caption := 'Gruppe fuer neue Mannschaft';
  rgGroup.Columns := 2;
  rgGroup.Items.Add('A');
  rgGroup.Items.Add('B');
  rgGroup.ItemIndex := 0;

  // Liste und Loeschen-Button nach unten schieben, damit die Gruppen-Auswahl Platz hat
  ListBox1.Top := 124;
  ListBox1.Height := 253;
  btnDeleteTeam.Top := 124;

  UpdateListBox;   // vorhandene Mannschaften anzeigen (Daten leben im Tournament-Modell)
end;

procedure TFormTeams.btnAddTeamClick(Sender: TObject);
var
  G: Char;
begin
  if rgGroup.ItemIndex = 1 then
    G := 'B'
  else
    G := 'A';

  if Tournament.TeamCountInGroup(G) >= 6 then
  begin
    ShowMessage('Gruppe ' + G + ' ist voll (max. 6 Mannschaften)!');
    Exit;
  end;

  if Trim(edtTeamName.Text) = '' then
  begin
    ShowMessage('Bitte geben Sie einen Mannschaftsnamen ein!');
    Exit;
  end;

  Tournament.AddTeam(edtTeamName.Text, G);
  edtTeamName.Clear;
  UpdateListBox;
end;

procedure TFormTeams.btnDeleteTeamClick(Sender: TObject);
begin
  if ListBox1.ItemIndex >= 0 then
  begin
    Tournament.DeleteTeam(ListBox1.ItemIndex + 1);   // ListBox 0-basiert -> Modell 1-basiert
    UpdateListBox;
  end;
end;

procedure TFormTeams.UpdateListBox;
var
  i: Integer;
begin
  ListBox1.Clear;
  for i := 1 to Tournament.TeamCount do
    ListBox1.Items.Add('[' + Tournament.TeamGroup(i) + ']  ' + Tournament.TeamName(i));
end;

end.
