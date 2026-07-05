unit UnitExport;

// Erzeugt einen druckfertigen HTML-Aushang (Gruppentabellen A/B, Ergebnisliste,
// KO-Runde, Kopf mit Logo + Datum). Selbst-enthalten (Logo als Base64 eingebettet).

interface

procedure ExportAushangHtml(const FileName: string);

implementation

uses
  System.SysUtils, System.Classes, System.IOUtils, System.NetEncoding, UnitModel;

function HtmlEsc(const s: string): string;
begin
  Result := StringReplace(s, '&', '&amp;', [rfReplaceAll]);
  Result := StringReplace(Result, '<', '&lt;', [rfReplaceAll]);
  Result := StringReplace(Result, '>', '&gt;', [rfReplaceAll]);
end;

function FindAsset(const AName: string): string;
begin
  Result := ExtractFilePath(ParamStr(0)) + AName;          // neben der exe
  if FileExists(Result) then Exit;
  Result := ExtractFilePath(ParamStr(0)) + '..\..\' + AName; // Projektordner (F9)
  if not FileExists(Result) then
    Result := '';
end;

function ImageMime(const path: string): string;
var
  ext: string;
begin
  ext := LowerCase(ExtractFileExt(path));
  if (ext = '.jpg') or (ext = '.jpeg') then
    Result := 'image/jpeg'
  else if ext = '.gif' then
    Result := 'image/gif'
  else if ext = '.bmp' then
    Result := 'image/bmp'
  else
    Result := 'image/png';
end;

function ImageDataUri(const path: string): string;
var
  bytes: TBytes;
begin
  Result := '';
  if (path = '') or (not FileExists(path)) then
    Exit;
  try
    bytes := TFile.ReadAllBytes(path);
    Result := 'data:' + ImageMime(path) + ';base64,' +
      TNetEncoding.Base64.EncodeBytesToString(bytes);
  except
    Result := '';
  end;
end;

function GroupTableHtml(AGroup: Char): string;
var
  sb: TStringBuilder;
  stats: TArray<TTeamStat>;
  i: Integer;
begin
  stats := Tournament.ComputeTable(AGroup);
  sb := TStringBuilder.Create;
  try
    sb.Append('<table>');
    sb.Append('<tr><th>Pl.</th><th>Verein</th><th>Spiele</th><th>Punkte</th><th>Tore+</th><th>Tore-</th></tr>');
    for i := 0 to High(stats) do
      sb.Append(Format('<tr><td>%d</td><td>%s</td><td>%d</td><td>%d</td><td>%d</td><td>%d</td></tr>',
        [i + 1, HtmlEsc(stats[i].Name), stats[i].Games, stats[i].Points,
         stats[i].GoalsScored, stats[i].GoalsConceded]));
    sb.Append('</table>');
    Result := sb.ToString;
  finally
    sb.Free;
  end;
end;

function ResultsHtml: string;
var
  sb: TStringBuilder;
  i: Integer;
  M: TMatch;
begin
  sb := TStringBuilder.Create;
  try
    sb.Append('<table>');
    sb.Append('<tr><th>Nr.</th><th>Heim</th><th>Ergebnis</th><th>Gast</th></tr>');
    for i := 0 to Tournament.MatchCount - 1 do
    begin
      M := Tournament.Match(i);
      sb.Append(Format('<tr><td>%d</td><td>%s</td><td>%d:%d</td><td>%s</td></tr>',
        [i + 1, HtmlEsc(M.Team1), M.Goals1, M.Goals2, HtmlEsc(M.Team2)]));
    end;
    sb.Append('</table>');
    Result := sb.ToString;
  finally
    sb.Free;
  end;
end;

function KoHtml: string;
var
  sb: TStringBuilder;
  s: Integer;
  M: TMatch;
  titles: array[1..3] of string;
  champ: string;
begin
  titles[1] := 'Halbfinale 1';
  titles[2] := 'Halbfinale 2';
  titles[3] := 'Endspiel';
  sb := TStringBuilder.Create;
  try
    sb.Append('<table>');
    sb.Append('<tr><th>Runde</th><th>Heim</th><th>Ergebnis</th><th>Gast</th></tr>');
    for s := 1 to 3 do
    begin
      M := Tournament.KO(s);
      if (Trim(M.Team1) = '') and (Trim(M.Team2) = '') then
        sb.Append(Format('<tr><td>%s</td><td colspan="3">noch nicht eingetragen</td></tr>',
          [titles[s]]))
      else
        sb.Append(Format('<tr><td>%s</td><td>%s</td><td>%d:%d</td><td>%s</td></tr>',
          [titles[s], HtmlEsc(M.Team1), M.Goals1, M.Goals2, HtmlEsc(M.Team2)]));
    end;
    sb.Append('</table>');

    M := Tournament.KO(3);
    champ := '';
    if (Trim(M.Team1) <> '') and (Trim(M.Team2) <> '') then
      if M.Goals1 > M.Goals2 then champ := M.Team1
      else if M.Goals2 > M.Goals1 then champ := M.Team2;
    if champ <> '' then
      sb.Append('<p style="font-size:18px;"><b>Turniersieger: ' + HtmlEsc(champ) + '</b></p>');

    Result := sb.ToString;
  finally
    sb.Free;
  end;
end;

procedure ExportAushangHtml(const FileName: string);
var
  sb: TStringBuilder;
  sl: TStringList;
  logo, title: string;
begin
  title := Tournament.OrganizerTitle;
  logo := ImageDataUri(Tournament.OrganizerIcon);    // Veranstalter-Icon
  if logo = '' then
    logo := ImageDataUri(FindAsset('logorw96.png'));  // Fallback: Rw-Logo
  sb := TStringBuilder.Create;
  try
    sb.Append('<!DOCTYPE html><html lang="de"><head><meta charset="utf-8">');
    sb.Append('<title>' + HtmlEsc(title) + '</title><style>');
    sb.Append('body{font-family:''Segoe UI'',Arial,sans-serif;color:#222;margin:24px;}');
    sb.Append('h1{margin:0;font-size:28px;}h2{color:#3a4a5a;margin-top:26px;}');
    sb.Append('.head{display:flex;align-items:center;gap:16px;border-bottom:2px solid #ccc;padding-bottom:12px;}');
    sb.Append('.head img{height:64px;}.date{color:#555;margin-top:4px;}');
    sb.Append('table{border-collapse:collapse;margin:8px 0 16px;}');
    sb.Append('th,td{border:1px solid #999;padding:6px 14px;text-align:center;}');
    sb.Append('th{background:#ffe600;}');
    sb.Append('.groups{display:flex;gap:36px;flex-wrap:wrap;}');
    sb.Append('.foot{color:#888;font-size:12px;margin-top:28px;}');
    sb.Append('@media print{body{margin:0;}}');
    sb.Append('</style></head><body>');

    sb.Append('<div class="head">');
    if logo <> '' then
      sb.Append('<img src="' + logo + '" alt="Logo">');
    sb.Append('<div><h1>' + HtmlEsc(title) + '</h1><div class="date">Stand: ' +
      FormatDateTime('dd.mm.yyyy', Now) + '</div></div>');
    sb.Append('</div>');

    sb.Append('<div class="groups">');
    sb.Append('<div><h2>Gruppe A</h2>' + GroupTableHtml('A') + '</div>');
    sb.Append('<div><h2>Gruppe B</h2>' + GroupTableHtml('B') + '</div>');
    sb.Append('</div>');

    sb.Append('<h2>Ergebnisliste</h2>' + ResultsHtml);
    sb.Append('<h2>KO-Runde</h2>' + KoHtml);

    sb.Append('<p class="foot">Erstellt mit Fußball-Turnier-Verwaltung &middot; &copy; 2026 RwTec</p>');
    sb.Append('</body></html>');

    sl := TStringList.Create;
    try
      sl.Text := sb.ToString;
      sl.SaveToFile(FileName, TEncoding.UTF8);
    finally
      sl.Free;
    end;
  finally
    sb.Free;
  end;
end;

end.
