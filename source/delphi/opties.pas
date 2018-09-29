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
    ediNaam: TEdit;
    ediWachtwoord: TEditEx;
    chkBallon: TCheckBox;
    chkWarnings: TCheckBox;
    btnCancel: TButton;
    btnOK: TButton;
    imgProps7: TImage;
    lblVerbinding: TLabel;
    cmbAdapters: TComboBox;
    chkVerbinding: TCheckBox;
    lblVerbindingUitPercentage: TLabel;
    chkVerbindingDag: TCheckBox;
    lblUitMB: TLabel;
    speBijwerken: TUpDown;
    ediBijwerken: TEdit;
    ediVerbinding: TEdit;
    speVerbinding: TUpDown;
    ediVerbindingDag: TEdit;
    speVerbindingDag: TUpDown;
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
    Label1: TLabel;
    procedure scbScrollBoxMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure chkVerbindingMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    function FormHelp(Command: Word; Data: Integer; var CallHelp: Boolean): Boolean;
    procedure btnCancelClick(Sender: TObject);
    procedure chkVerbindingDagMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Label1Click(Sender: TObject);
  private
    procedure ApplyChanges;
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
  imgProps2.Picture := imgProps1.Picture;
  imgProps3.Picture := imgProps1.Picture;
  imgProps4.Picture := imgProps1.Picture;
  imgProps5.Picture := imgProps1.Picture;
  imgProps7.Picture := imgProps1.Picture;

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

  frmPipMain.Opties.bWarnVerschil     := chkWarnVerschil.Checked;
  frmPipMain.Opties.bWarnHoger        := chkWarnHoger.Checked;
  frmPipMain.Opties.WarnVerschil      := speWarnVerschil.Position;
  frmPipMain.Opties.WarnHoger         := speWarnHoger.Position;
  frmPipMain.Opties.bWarnOverschreden := chkWarnOver.Checked;

  frmPipMain.Opties.AdapterNaam        := cmbAdapters.Text;
  frmPipMain.Opties.VerbreekVerbinding := chkVerbinding.Checked;
  frmPipMain.Opties.VerbreekPercentage := speVerbinding.Position;

  frmPipMain.Opties.VerbreekVerbindingDag := chkVerbindingDag.Checked;
  frmPipMain.Opties.VerbreekDataDag       := speVerbindingDag.Position;

  frmPipMain.Opties.Interval       := 0;

  if chkVernieuwen.Checked then
    frmPipMain.Opties.Interval := speBijwerken.Position;

  frmPipMain.Opties.AutoCheck := chkVernieuwen.Checked;

  frmPipMain.tmrUpdate.Enabled := (frmPipMain.Opties.Interval <> 0);
  frmPipMain.tmrUpdate.Interval := frmPipMain.Opties.Interval * 60 * 1000;

  frmPipMain.saveSettings;
end;

procedure TfrmOpties.btnOKClick(Sender: TObject);
begin
  ApplyChanges;
  ModalResult := mrOk;
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

procedure TfrmOpties.Label1Click(Sender: TObject);
begin
  Control_RunDLL(Application.Handle, 0, PChar('mmsys.cpl,,1'), SW_SHOW);
end;

end.
