unit UnitModel;

// Zentrales Datenmodell (M2). Eine einzige Quelle der Wahrheit: das Objekt
// Tournament. Teams, Spiele, Tabellenberechnung und Persistenz leben hier.
// Formulare zeigen nur noch an und rufen dieses Modell auf.

interface

uses
  System.SysUtils, System.Classes, System.IniFiles;

type
  TPhase = (phGroup, phSemi, phThird, phFinal);   // M2: nur phGroup aktiv, Rest reserviert (M4/KO)

  TTeam = record
    Name:  string;
    Group: Char;          // 'A'/'B'; in M2 Standard 'A', echte Nutzung ab M3
  end;

  TMatch = record
    Phase:          TPhase;      // M2 immer phGroup
    Team1, Team2:   string;
    Goals1, Goals2: Integer;
    Pen1, Pen2:     Integer;     // reserviert fuer KO-Elfmeter (M4)
    Played:         Boolean;
  end;

  TTeamStat = record
    Name:  string;
    Group: Char;
    Games, Points, GoalsScored, GoalsConceded: Integer;
  end;

  TTournament = class
  private
    FTeams:   array of TTeam;
    FMatches: array of TMatch;
    FKO:      array[1..3] of TMatch;   // 1=HF1, 2=HF2, 3=Finale
    FOrganizer, FOrganizerIcon: string;
  public
    // --- Teams (1-basiert, kompatibel zur bisherigen API) ---
    function  TeamCount: Integer;
    function  TeamName(Index: Integer): string;
    function  TeamGroup(Index: Integer): Char;
    function  TeamCountInGroup(AGroup: Char): Integer;
    function  GroupOfTeam(const AName: string): Char;
    function  AddTeam(const AName: string; AGroup: Char = 'A'): Boolean;
    procedure DeleteTeam(Index: Integer);
    procedure ClearTeams;
    // --- Spiele (0-basiert) ---
    function  MatchCount: Integer;
    function  Match(Index: Integer): TMatch;
    procedure AddMatch(const T1, T2: string; G1, G2: Integer);
    procedure ClearMatches;
    // --- KO-Runde (Slot 1=HF1, 2=HF2, 3=Finale) ---
    function  KO(Slot: Integer): TMatch;
    procedure SetKO(Slot: Integer; const T1, T2: string; G1, G2: Integer);
    // --- Veranstalter (Name + Icon-Pfad) ---
    function  Organizer: string;
    function  OrganizerIcon: string;
    function  OrganizerTitle: string;   // Name, sonst 'Fußball-Turnier'
    procedure SetOrganizer(const AName, AIconPath: string);
    // --- Gesamt ---
    procedure ClearAll;
    // --- Tabelle (AGroup = #0 => alle Teams, wie in M2) ---
    function  ComputeTable(AGroup: Char = #0): TArray<TTeamStat>;
    // --- Persistenz (.trn, abwaertskompatibel) ---
    procedure SaveToFile(const FileName: string);
    procedure LoadFromFile(const FileName: string);
  end;

var
  Tournament: TTournament;

implementation

{ TTournament }

function TTournament.TeamCount: Integer;
begin
  Result := Length(FTeams);
end;

function TTournament.TeamName(Index: Integer): string;
begin
  if (Index >= 1) and (Index <= Length(FTeams)) then
    Result := FTeams[Index - 1].Name
  else
    Result := '';
end;

function TTournament.TeamGroup(Index: Integer): Char;
begin
  if (Index >= 1) and (Index <= Length(FTeams)) then
    Result := FTeams[Index - 1].Group
  else
    Result := 'A';
end;

function TTournament.TeamCountInGroup(AGroup: Char): Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to High(FTeams) do
    if FTeams[i].Group = AGroup then
      Inc(Result);
end;

function TTournament.GroupOfTeam(const AName: string): Char;
var
  i: Integer;
begin
  Result := #0;   // nicht gefunden
  for i := 0 to High(FTeams) do
    if FTeams[i].Name = AName then
      Exit(FTeams[i].Group);
end;

function TTournament.AddTeam(const AName: string; AGroup: Char): Boolean;
begin
  Result := False;
  if Trim(AName) = '' then
    Exit;
  SetLength(FTeams, Length(FTeams) + 1);
  FTeams[High(FTeams)].Name  := AName;
  FTeams[High(FTeams)].Group := AGroup;
  Result := True;
end;

procedure TTournament.DeleteTeam(Index: Integer);
var
  i: Integer;
begin
  if (Index < 1) or (Index > Length(FTeams)) then
    Exit;
  for i := Index to High(FTeams) do
    FTeams[i - 1] := FTeams[i];
  SetLength(FTeams, Length(FTeams) - 1);
end;

procedure TTournament.ClearTeams;
begin
  SetLength(FTeams, 0);
end;

function TTournament.MatchCount: Integer;
begin
  Result := Length(FMatches);
end;

function TTournament.Match(Index: Integer): TMatch;
begin
  Result := FMatches[Index];
end;

procedure TTournament.AddMatch(const T1, T2: string; G1, G2: Integer);
begin
  SetLength(FMatches, Length(FMatches) + 1);
  with FMatches[High(FMatches)] do
  begin
    Phase  := phGroup;
    Team1  := T1;
    Team2  := T2;
    Goals1 := G1;
    Goals2 := G2;
    Pen1   := 0;
    Pen2   := 0;
    Played := True;
  end;
end;

procedure TTournament.ClearMatches;
begin
  SetLength(FMatches, 0);
end;

function TTournament.KO(Slot: Integer): TMatch;
begin
  if (Slot >= 1) and (Slot <= 3) then
    Result := FKO[Slot]
  else
    Result := Default(TMatch);
end;

procedure TTournament.SetKO(Slot: Integer; const T1, T2: string; G1, G2: Integer);
begin
  if (Slot < 1) or (Slot > 3) then
    Exit;
  FKO[Slot].Team1  := T1;
  FKO[Slot].Team2  := T2;
  FKO[Slot].Goals1 := G1;
  FKO[Slot].Goals2 := G2;
  if Slot = 3 then
    FKO[Slot].Phase := phFinal
  else
    FKO[Slot].Phase := phSemi;
  FKO[Slot].Played := (Trim(T1) <> '') and (Trim(T2) <> '');
end;

function TTournament.Organizer: string;
begin
  Result := FOrganizer;
end;

function TTournament.OrganizerIcon: string;
begin
  Result := FOrganizerIcon;
end;

function TTournament.OrganizerTitle: string;
begin
  if Trim(FOrganizer) <> '' then
    Result := FOrganizer
  else
    Result := 'Fußball-Turnier';
end;

procedure TTournament.SetOrganizer(const AName, AIconPath: string);
begin
  FOrganizer := AName;
  FOrganizerIcon := AIconPath;
end;

procedure TTournament.ClearAll;
var
  i: Integer;
begin
  ClearTeams;
  ClearMatches;
  for i := 1 to 3 do
    FKO[i] := Default(TMatch);
end;

function TTournament.ComputeTable(AGroup: Char): TArray<TTeamStat>;
var
  i, j: Integer;
  Stats: TArray<TTeamStat>;
  Temp: TTeamStat;

  function IndexOfTeam(const AName: string): Integer;
  var
    k: Integer;
  begin
    Result := -1;
    for k := 0 to High(Stats) do
      if Stats[k].Name = AName then
        Exit(k);
  end;

begin
  // Teams der gewuenschten Gruppe (oder alle bei #0) aufnehmen
  SetLength(Stats, 0);
  for i := 0 to High(FTeams) do
    if (AGroup = #0) or (FTeams[i].Group = AGroup) then
    begin
      SetLength(Stats, Length(Stats) + 1);
      Stats[High(Stats)].Name          := FTeams[i].Name;
      Stats[High(Stats)].Group         := FTeams[i].Group;
      Stats[High(Stats)].Games         := 0;
      Stats[High(Stats)].Points        := 0;
      Stats[High(Stats)].GoalsScored   := 0;
      Stats[High(Stats)].GoalsConceded := 0;
    end;

  // Nur Gruppenspiele auswerten
  for i := 0 to High(FMatches) do
    if FMatches[i].Phase = phGroup then
    begin
      j := IndexOfTeam(FMatches[i].Team1);
      if j >= 0 then
      begin
        Inc(Stats[j].Games);
        Inc(Stats[j].GoalsScored,   FMatches[i].Goals1);
        Inc(Stats[j].GoalsConceded, FMatches[i].Goals2);
        if FMatches[i].Goals1 > FMatches[i].Goals2 then
          Inc(Stats[j].Points, 3)
        else if FMatches[i].Goals1 = FMatches[i].Goals2 then
          Inc(Stats[j].Points, 1);
      end;
      j := IndexOfTeam(FMatches[i].Team2);
      if j >= 0 then
      begin
        Inc(Stats[j].Games);
        Inc(Stats[j].GoalsScored,   FMatches[i].Goals2);
        Inc(Stats[j].GoalsConceded, FMatches[i].Goals1);
        if FMatches[i].Goals2 > FMatches[i].Goals1 then
          Inc(Stats[j].Points, 3)
        else if FMatches[i].Goals1 = FMatches[i].Goals2 then
          Inc(Stats[j].Points, 1);
      end;
    end;

  // Sortierung: Punkte, dann Tordifferenz, dann geschossene Tore
  for i := 0 to High(Stats) - 1 do
    for j := i + 1 to High(Stats) do
      if (Stats[j].Points > Stats[i].Points) or
         ((Stats[j].Points = Stats[i].Points) and
          ((Stats[j].GoalsScored - Stats[j].GoalsConceded) >
           (Stats[i].GoalsScored - Stats[i].GoalsConceded))) or
         ((Stats[j].Points = Stats[i].Points) and
          ((Stats[j].GoalsScored - Stats[j].GoalsConceded) =
           (Stats[i].GoalsScored - Stats[i].GoalsConceded)) and
          (Stats[j].GoalsScored > Stats[i].GoalsScored)) then
      begin
        Temp := Stats[i];
        Stats[i] := Stats[j];
        Stats[j] := Temp;
      end;

  Result := Stats;
end;

procedure TTournament.SaveToFile(const FileName: string);
var
  Ini: TIniFile;
  i: Integer;
  Sec: string;
begin
  Ini := TIniFile.Create(FileName);
  try
    Ini.WriteString('Tournament', 'Organizer', FOrganizer);
    Ini.WriteString('Tournament', 'OrganizerIcon', FOrganizerIcon);
    Ini.EraseSection('Teams');
    Ini.WriteInteger('Teams', 'Count', Length(FTeams));
    for i := 0 to High(FTeams) do
    begin
      Sec := 'Team_' + IntToStr(i + 1);
      Ini.EraseSection(Sec);
      Ini.WriteString(Sec, 'Name', FTeams[i].Name);
      Ini.WriteString(Sec, 'Group', string(FTeams[i].Group));
    end;

    Ini.WriteInteger('Matches', 'Count', Length(FMatches));
    for i := 0 to High(FMatches) do
    begin
      Sec := 'Match_' + IntToStr(i);
      Ini.EraseSection(Sec);
      Ini.WriteString(Sec, 'Team1', FMatches[i].Team1);
      Ini.WriteString(Sec, 'Team2', FMatches[i].Team2);
      Ini.WriteInteger(Sec, 'Goals1', FMatches[i].Goals1);
      Ini.WriteInteger(Sec, 'Goals2', FMatches[i].Goals2);
      Ini.WriteInteger(Sec, 'Phase', Ord(FMatches[i].Phase));
      Ini.WriteInteger(Sec, 'Pen1', FMatches[i].Pen1);
      Ini.WriteInteger(Sec, 'Pen2', FMatches[i].Pen2);
      Ini.WriteBool(Sec, 'Played', FMatches[i].Played);
    end;

    for i := 1 to 3 do
    begin
      Sec := 'KO_' + IntToStr(i);
      Ini.EraseSection(Sec);
      Ini.WriteString(Sec, 'Team1', FKO[i].Team1);
      Ini.WriteString(Sec, 'Team2', FKO[i].Team2);
      Ini.WriteInteger(Sec, 'Goals1', FKO[i].Goals1);
      Ini.WriteInteger(Sec, 'Goals2', FKO[i].Goals2);
    end;
  finally
    Ini.Free;
  end;
end;

procedure TTournament.LoadFromFile(const FileName: string);
var
  Ini: TIniFile;
  i, Count: Integer;
  Sec, G: string;
begin
  Ini := TIniFile.Create(FileName);
  try
    ClearAll;
    FOrganizer := Ini.ReadString('Tournament', 'Organizer', FOrganizer);
    FOrganizerIcon := Ini.ReadString('Tournament', 'OrganizerIcon', FOrganizerIcon);
    // Teams
    Count := Ini.ReadInteger('Teams', 'Count', 0);
    SetLength(FTeams, Count);
    for i := 0 to Count - 1 do
    begin
      Sec := 'Team_' + IntToStr(i + 1);
      FTeams[i].Name := Ini.ReadString(Sec, 'Name', '');
      G := Ini.ReadString(Sec, 'Group', 'A');      // alte .trn ohne Gruppe -> 'A'
      if G <> '' then
        FTeams[i].Group := G[1]
      else
        FTeams[i].Group := 'A';
    end;
    // Spiele
    Count := Ini.ReadInteger('Matches', 'Count', 0);
    SetLength(FMatches, Count);
    for i := 0 to Count - 1 do
    begin
      Sec := 'Match_' + IntToStr(i);
      FMatches[i].Team1  := Ini.ReadString(Sec, 'Team1', '');
      FMatches[i].Team2  := Ini.ReadString(Sec, 'Team2', '');
      FMatches[i].Goals1 := Ini.ReadInteger(Sec, 'Goals1', 0);
      FMatches[i].Goals2 := Ini.ReadInteger(Sec, 'Goals2', 0);
      FMatches[i].Phase  := TPhase(Ini.ReadInteger(Sec, 'Phase', 0));  // fehlt -> phGroup
      FMatches[i].Pen1   := Ini.ReadInteger(Sec, 'Pen1', 0);
      FMatches[i].Pen2   := Ini.ReadInteger(Sec, 'Pen2', 0);
      FMatches[i].Played := Ini.ReadBool(Sec, 'Played', True);
    end;

    for i := 1 to 3 do
    begin
      Sec := 'KO_' + IntToStr(i);
      FKO[i].Team1  := Ini.ReadString(Sec, 'Team1', '');
      FKO[i].Team2  := Ini.ReadString(Sec, 'Team2', '');
      FKO[i].Goals1 := Ini.ReadInteger(Sec, 'Goals1', 0);
      FKO[i].Goals2 := Ini.ReadInteger(Sec, 'Goals2', 0);
      if i = 3 then FKO[i].Phase := phFinal else FKO[i].Phase := phSemi;
      FKO[i].Played := (FKO[i].Team1 <> '') and (FKO[i].Team2 <> '');
    end;
  finally
    Ini.Free;
  end;
end;

initialization
  Tournament := TTournament.Create;

finalization
  Tournament.Free;

end.
