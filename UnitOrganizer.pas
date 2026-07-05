unit UnitOrganizer;

// Dialog zum Festlegen des Veranstalters (Name + Icon) sowie eine Helferroutine,
// die eine Veranstalter-Kopfzeile (Icon + Name) oben in ein Formular einsetzt.

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls,
  Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Imaging.jpeg,
  Vcl.Imaging.pngimage, UnitModel;

type
  TFormOrganizer = class(TForm)
  private
    edtName: TEdit;
    imgIcon: TImage;
    FIconPath: string;
    procedure BuildUI;
    procedure LoadIcon(const APath: string);
    procedure btnIconClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
  end;

procedure AddOrganizerHeader(AParent: TWinControl);

var
  FormOrganizer: TFormOrganizer;

implementation

{ ==== Dialog ==== }

constructor TFormOrganizer.Create(AOwner: TComponent);
begin
  inherited CreateNew(AOwner);
  Caption := 'Veranstalter festlegen';
  BorderStyle := bsDialog;
  Position := poScreenCenter;
  ClientWidth := 460;
  ClientHeight := 244;
  Font.Name := 'Segoe UI';
  Font.Size := 10;
  BuildUI;

  edtName.Text := Tournament.Organizer;
  FIconPath := Tournament.OrganizerIcon;
  LoadIcon(FIconPath);
end;

procedure TFormOrganizer.BuildUI;
var
  lbl: TLabel;
  pnlIcon: TPanel;
  btnIcon, btnOk, btnCancel: TButton;
begin
  lbl := TLabel.Create(Self);
  lbl.Parent := Self;
  lbl.SetBounds(24, 18, 300, 20);
  lbl.Caption := 'Name des Veranstalters:';

  edtName := TEdit.Create(Self);
  edtName.Parent := Self;
  edtName.SetBounds(24, 42, 412, 28);

  lbl := TLabel.Create(Self);
  lbl.Parent := Self;
  lbl.SetBounds(24, 86, 300, 20);
  lbl.Caption := 'Icon (Bilddatei):';

  pnlIcon := TPanel.Create(Self);
  pnlIcon.Parent := Self;
  pnlIcon.SetBounds(24, 108, 84, 84);
  pnlIcon.BevelOuter := bvLowered;
  pnlIcon.ParentBackground := False;
  pnlIcon.Color := clWhite;
  pnlIcon.Caption := '';

  imgIcon := TImage.Create(Self);
  imgIcon.Parent := pnlIcon;
  imgIcon.Align := alClient;
  imgIcon.Proportional := True;
  imgIcon.Stretch := True;
  imgIcon.Center := True;

  btnIcon := TButton.Create(Self);
  btnIcon.Parent := Self;
  btnIcon.SetBounds(124, 120, 170, 34);
  btnIcon.Caption := 'Icon wählen...';
  btnIcon.OnClick := btnIconClick;

  btnOk := TButton.Create(Self);
  btnOk.Parent := Self;
  btnOk.SetBounds(246, 200, 90, 32);
  btnOk.Caption := 'OK';
  btnOk.Default := True;
  btnOk.OnClick := btnOkClick;

  btnCancel := TButton.Create(Self);
  btnCancel.Parent := Self;
  btnCancel.SetBounds(346, 200, 90, 32);
  btnCancel.Caption := 'Abbrechen';
  btnCancel.Cancel := True;
  btnCancel.ModalResult := mrCancel;
end;

procedure TFormOrganizer.LoadIcon(const APath: string);
begin
  imgIcon.Picture.Assign(nil);   // Vorschau leeren
  if (APath <> '') and FileExists(APath) then
    try
      imgIcon.Picture.LoadFromFile(APath);
    except
      // ungueltige Bilddatei -> Vorschau bleibt leer
    end;
end;

procedure TFormOrganizer.btnIconClick(Sender: TObject);
var
  dlg: TOpenDialog;
begin
  dlg := TOpenDialog.Create(nil);
  try
    dlg.Filter := 'Bilddateien (*.png;*.jpg;*.jpeg;*.bmp;*.ico)|*.png;*.jpg;*.jpeg;*.bmp;*.ico';
    if dlg.Execute then
    begin
      FIconPath := dlg.FileName;
      LoadIcon(FIconPath);
    end;
  finally
    dlg.Free;
  end;
end;

procedure TFormOrganizer.btnOkClick(Sender: TObject);
begin
  Tournament.SetOrganizer(Trim(edtName.Text), FIconPath);
  ModalResult := mrOk;
end;

{ ==== Kopfzeile fuer Tabelle / Ergebnisse ==== }

procedure AddOrganizerHeader(AParent: TWinControl);
var
  pnl: TPanel;
  img: TImage;
  lbl: TLabel;
  ic: string;
begin
  ic := Tournament.OrganizerIcon;

  pnl := TPanel.Create(AParent);
  pnl.Parent := AParent;
  pnl.Align := alTop;
  pnl.Height := 52;
  pnl.BevelOuter := bvNone;
  pnl.ParentBackground := False;
  pnl.Color := RGB(43, 58, 74);

  img := TImage.Create(pnl);
  img.Parent := pnl;
  img.SetBounds(12, 6, 40, 40);
  img.Proportional := True;
  img.Stretch := True;
  img.Center := True;
  if (ic <> '') and FileExists(ic) then
    try
      img.Picture.LoadFromFile(ic);
    except
    end;

  lbl := TLabel.Create(pnl);
  lbl.Parent := pnl;
  lbl.SetBounds(62, 12, AParent.ClientWidth - 80, 28);
  lbl.Anchors := [akLeft, akTop, akRight];
  lbl.Transparent := True;
  lbl.Caption := Tournament.OrganizerTitle;
  lbl.Font.Name := 'Segoe UI';
  lbl.Font.Size := 15;
  lbl.Font.Style := [fsBold];
  lbl.Font.Color := clWhite;
end;

end.
