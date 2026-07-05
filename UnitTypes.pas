unit UnitTypes;

interface
  type
    TMatchData=record
      Team1, Team2:string;
      Goals1, Goals2: Integer;
    end;

    TMatchesChangedEvent = procedure of object;  // Neuer Event-Typ

implementation

end.
