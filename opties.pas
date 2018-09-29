unit opties;

interface

uses
  Windows, Forms, Dialogs, StdCtrls, ComCtrls, Controls, EditEx, Buttons,
  Graphics, ExtCtrls, Classes, SysUtils, MmSystem;

type
  TfrmOpties = class(TForm)
    odlGeluid: TOpenDialog;
    pnlOpties: TPanel;
    scbScrollBox: TScrollBox;
    imgProps1: TImage;
    imgProps2: TImage;
    imgProps3: TImage;
    imgProps5: TImage;
    steLogin: TLabel;
    steLoginnaam: TLabel;
    steWachtwoord: TLabel;
    steOpties: TLabel;
    steBijwerken: TLabel;
    steBallon: TLabel;
    spbSpeelGeluid: TSpeedButton;
    spbKiesGeluid: TSpeedButton;
    lblGeluid: TLabel;
    lblWaarschuwingen: TLabel;
    imgProps6: TImage;
    ediNaam: TEdit;
    ediWachtwoord: TEditEx;
    chkBallon: TCheckBox;
    chkWarnings: TCheckBox;
    chkLimiet: TCheckBox;
    chkDataverkeer: TCheckBox;
    chkVerkeerOver: TCheckBox;
    chkPercentages: TCheckBox;
    chkVerkeerVandaag: TCheckBox;
    ediGeluid: TEdit;
    chkGeluid: TCheckBox;
    chkSpeaker: TCheckBox;
    btnCancel: TButton;
    btnOK: TButton;
    chkVerhoogLimiet: TCheckBox;
    imgProps7: TImage;
    lblVerbinding: TLabel;
    cmbAdapters: TComboBox;
    chkVerbinding: TCheckBox;
    lblVerbindingUitPercentage: TLabel;
    chkVerbindingDag: TCheckBox;
    lblUitMB: TLabel;
    chkIcoonPercentage: TCheckBox;
    speBijwerken: TUpDown;
    ediBijwerken: TEdit;
    ediVerbinding: TEdit;
    speVerbinding: TUpDown;
    ediVerbindingDag: TEdit;
    speVerbindingDag: TUpDown;
    chkFlashIcon: TCheckBox;
    lblProcent1: TLabel;
    lblProcent2: TLabel;
    speWarnHoger: TUpDown;
    speWarnVerschil: TUpDown;
    ediWarnVerschil: TEdit;
    ediWarnHoger: TEdit;
    chkWarnHoger: TCheckBox;
    chkWarnVerschil: TCheckBox;
    chkWarnOver: TCheckBox;
    imgProps4: TImage;
    lblWaarschuwen: TLabel;
    lblMinuten: TLabel;
    chkVernieuwen: TCheckBox;
    procedure scbScrollBoxMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure spbKiesGeluidClick(Sender: TObject);
    procedure spbSpeelGeluidClick(Sender: TObject);
    procedure chkWarningsClick(Sender: TObject);
    procedure chkGeluidClick(Sender: TObject);
    procedure chkBallonClick(Sender: TObject);
    procedure chkAutoUpdateClick(Sender: TObject);
    procedure chkVerbindingMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure chkVerhoogLimietMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure chkRealtimeClick(Sender: TObject);
    procedure chkTransparantieClick(Sender: TObject);
    function FormHelp(Command: Word; Data: Integer; var CallHelp: Boolean): Boolean;
    procedure btnCancelClick(Sender: TObject);
    procedure chkExitAfterFirstCheckClick(Sender: TObject);
    procedure chkPipServerClick(Sender: TObject);
    procedure chkVerbindingDagMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  private
    procedure UpdateCheckBoxes;
    procedure ApplyChanges;
  public
    OldState: Boolean;
  end;

var
  frmOpties: TfrmOpties;

implementation

uses main, tools;

{$R *.dfm}

procedure TfrmOpties.scbScrollBoxMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
  scbScrollBox.VertScrollBar.Position := scbScrollBox.VertScrollBar.Position + -1 * (WheelDelta div Mouse.WheelScrollLines);
  Handled := TRUE;
end;

procedure TfrmOpties.FormCreate(Sender: TObject);
var
  iCount: Integer;
  AdapterList: TStringList;
begin
  OldState := frmPipMain.Opties.VerhoogLimiet;

  imgProps2.Picture := imgProps1.Picture;
  imgProps3.Picture := imgProps1.Picture;
  imgProps4.Picture := imgProps1.Picture;
  imgProps5.Picture := imgProps1.Picture;
  imgProps6.Picture := imgProps1.Picture;
  imgProps7.Picture := imgProps1.Picture;

  UpdateCheckBoxes;

  AdapterList := TStringList.Create;
  GetAdaptersList(AdapterList);

  for iCount := 0 to Adapterlist.Count - 1 do
  begin
    cmbAdapters.Items.Add(AdapterList.ValueFromIndex[iCount]);
  end;

  AdapterList.Free;

  cmbAdapters.ItemIndex := 0;

  scbScrollBox.VertScrollBar.Position := 0;
end;

procedure TfrmOpties.ApplyChanges;
begin
  frmPipMain.Opties.Naam       := ediNaam.Text;
  frmPipMain.Opties.Wachtwoord := ediWachtwoord.Text;

  frmPipMain.Opties.ToonBallon     := chkBallon.Checked;
  frmPipMain.Opties.Waarschuwingen := chkWarnings.Checked;
  frmPipMain.Opties.FlashIcon      := chkFlashIcon.Checked;
  frmPipMain.Opties.Geluid         := ediGeluid.Text;
  frmPipMain.Opties.GeluidSpelen   := chkGeluid.Checked;
  frmPipMain.Opties.Speaker        := chkSpeaker.Checked;

  frmPipMain.Opties.BallonLimiet      := chkLimiet.Checked;
  frmPipMain.Opties.BallonDataverkeer := chkDataverkeer.Checked;
  frmPipMain.Opties.BallonOver        := chkVerkeerOver.Checked;
  frmPipMain.Opties.BallonVandaag     := chkVerkeerVandaag.Checked;
  frmPipMain.Opties.BallonPercentages := chkPercentages.Checked;

  frmPipMain.Opties.bWarnVerschil     := chkWarnVerschil.Checked;
  frmPipMain.Opties.bWarnHoger        := chkWarnHoger.Checked;
  frmPipMain.Opties.WarnVerschil      := speWarnVerschil.Position;
  frmPipMain.Opties.WarnHoger         := speWarnHoger.Position;
  frmPipMain.Opties.bWarnOverschreden := chkWarnOver.Checked;

  frmPipMain.Opties.VerhoogLimiet := chkVerhoogLimiet.Checked;

  frmPipMain.Opties.AdapterNaam        := cmbAdapters.Text;
  frmPipMain.Opties.VerbreekVerbinding := chkVerbinding.Checked;
  frmPipMain.Opties.VerbreekPercentage := speVerbinding.Position;

  frmPipMain.Opties.VerbreekVerbindingDag := chkVerbindingDag.Checked;
  frmPipMain.Opties.VerbreekDataDag       := speVerbindingDag.Position;

  frmPipMain.Opties.Interval       := 0;
  frmPipMain.Opties.ProcentInIcoon := chkIcoonPercentage.Checked;

  if chkVernieuwen.Checked then
    frmPipMain.Opties.Interval := speBijwerken.Position
  else
    frmPipMain.Opties.Interval := 0;

  frmPipMain.Opties.AutoCheck := chkVernieuwen.Checked;

  frmPipMain.tmrUpdate.Enabled := (frmPipMain.Opties.Interval <> 0);
  frmPipMain.tmrUpdate.Interval := frmPipMain.Opties.Interval * 60 * 1000;

  if (frmPipMain.Opties.VerhoogLimiet) and (not OldState) and (Dataverkeer.VrijVerkeer <> 0) then
  begin
    Dataverkeer.VrijVerkeer := Dataverkeer.VrijVerkeer * 2;
    OldState := TRUE;
  end;

  if (not frmPipMain.Opties.VerhoogLimiet) and (OldState) and (Dataverkeer.VrijVerkeer <> 0) then
  begin
    Dataverkeer.VrijVerkeer := Dataverkeer.VrijVerkeer / 2;
    OldState := FALSE;
  end;

  frmPipMain.ToonWaarden;
  frmPipMain.Caption := 'PipView ' + GetAppVersionInfo + ' (' + frmPipMain.Opties.Naam + ')';
  frmPipMain.saveSettings;
  frmPipMain.fillAccountsMenu;
  frmPipMain.saveDirectPip();
end;

procedure TfrmOpties.btnOKClick(Sender: TObject);
begin
  ApplyChanges;
  ModalResult := mrOk;
end;

procedure TfrmOpties.spbKiesGeluidClick(Sender: TObject);
begin
  if odlGeluid.Execute then
    ediGeluid.Text := odlGeluid.FileName;
end;

procedure TfrmOpties.spbSpeelGeluidClick(Sender: TObject);
begin
  if chkSpeaker.Checked then
  begin
    Siren;
    Exit;
  end;

  if ediGeluid.Text <> 'Geen' then
    PlaySound(PChar(ediGeluid.Text), 0, SND_FILENAME + SND_ASYNC);
end;

procedure TfrmOpties.chkWarningsClick(Sender: TObject);
begin
  UpdateCheckBoxes;
end;

procedure TfrmOpties.UpdateCheckBoxes;
begin
  ediGeluid.Enabled      := chkGeluid.Checked;
  spbSpeelGeluid.Enabled := chkGeluid.Checked;
  spbKiesGeluid.Enabled  := chkGeluid.Checked;

  chkLimiet.Enabled         := chkBallon.Checked;
  chkDataverkeer.Enabled    := chkBallon.Checked;
  chkVerkeerOver.Enabled    := chkBallon.Checked;
  chkVerkeerVandaag.Enabled := chkBallon.Checked;
  chkPercentages.Enabled    := chkBallon.Checked;
end;

procedure TfrmOpties.chkGeluidClick(Sender: TObject);
begin
  UpdateCheckBoxes;
end;

procedure TfrmOpties.chkBallonClick(Sender: TObject);
begin
  UpdateCheckBoxes;
end;

procedure TfrmOpties.chkAutoUpdateClick(Sender: TObject);
begin
  UpdateCheckBoxes;
end;

procedure TfrmOpties.chkVerbindingMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  LongString: String;
begin
  if chkVerbinding.Checked then
  begin
    LongString := 'WAARSCHUWING: Schakel deze optie enkel in wanneer u zelf weet hoe u uw internetverbinding weer terug kunt krijgen. Voor de experts: bij het verbreken van de verbinding, wordt het ip-adres van';
    LongString := LongString + ' uw netwerkadapter gereleased. Dit is te herstellen door een renew-commando uit te voeren. Vaak kan een reboot van de pc hier ook al genoeg voor zijn.';

    MessageBox(Handle, PChar(LongString), 'Waarschuwing', MB_OK + MB_ICONEXCLAMATION);
  end;
end;

procedure TfrmOpties.chkVerhoogLimietMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  LongString: String;
begin
  if chkVerhoogLimiet.Checked then
  begin
    LongString := 'WAARSCHUWING: Schakel deze optie enkel in wanneer u zeker weet dat u in de huidige periode uw limiet met 100% mag overschrijden. Dit mag in principe één keer in de drie perioden volgens de FUP,';
    LongString := LongString + ' er moeten telkens twee maanden tussen zitten sinds de vorige overschrijding. Als u dit niet zeker weet, kunt u deze optie beter niet inschakelen.';

    MessageBox(Handle, PChar(LongString), 'Waarschuwing', MB_OK + MB_ICONEXCLAMATION);
  end;
end;

procedure TfrmOpties.chkRealtimeClick(Sender: TObject);
begin
  UpdateCheckBoxes;
end;

procedure TfrmOpties.chkTransparantieClick(Sender: TObject);
begin
  UpdateCheckBoxes;
end;

function TfrmOpties.FormHelp(Command: Word; Data: Integer; var CallHelp: Boolean): Boolean;
begin
  CallHelp := FALSE;
  Result   := TRUE;

  if (Command = 8) and ((Data > 0) and (Data < 8)) then
    frmPipMain.OpenHelp('::/opties.html#' + IntToStr(Data));
end;

procedure TfrmOpties.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfrmOpties.chkExitAfterFirstCheckClick(Sender: TObject);
begin
  UpdateCheckBoxes;
end;

procedure TfrmOpties.chkPipServerClick(Sender: TObject);
begin
  UpdateCheckBoxes;
end;

procedure TfrmOpties.chkVerbindingDagMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  LongString: String;
begin
  if chkVerbindingDag.Checked then
  begin
    LongString := 'WAARSCHUWING: Schakel deze optie enkel in wanneer u zelf weet hoe u uw internetverbinding weer terug kunt krijgen. Voor de experts: bij het verbreken van de verbinding, wordt het ip-adres van';
    LongString := LongString + ' uw netwerkadapter gereleased. Dit is te herstellen door een renew-commando uit te voeren. Vaak kan een reboot van de pc hier ook al genoeg voor zijn.';

    MessageBox(Handle, PChar(LongString), 'Waarschuwing', MB_OK + MB_ICONEXCLAMATION);
  end;
end;

end.
