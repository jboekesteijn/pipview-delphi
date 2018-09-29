unit main;

interface

uses
  Windows, Balloon, CoolTrayIcon, ExtCtrls, Menus, ImgList, Controls,
  ComCtrls, NoScrollListView, Classes, StdCtrls, Messages, Forms,
  SysUtils, Registry, RegExpr, Mmsystem, Graphics, Math, ShellAPI,
  Clipbrd;

type
  TMaandData = record
    Ontvangen, Verstuurd, Totaal: Single;
  end;

type
  TPeriode = record
    Start, Eind: TDateTime;
    Nummer, Jaar: Integer;
  end;

type
  TVandaag = record
    Down, Up: Single;
  end;

type
  TDataVerkeer = record
    VrijVerkeer: Single;
    MaandData: TMaandData;
    Vandaag: TVandaag;
    Periode: TPeriode;
    Fouten: Integer;
    Datum: TDateTime;
  end;

type
  TVorigeData = record
    Data1, Data2: Single;
  end;

type
  TOpties = record
    Naam: String;
    Wachtwoord: String;
    ToonBallon: Boolean;
    Waarschuwingen: Boolean;
    AutoCheck: Boolean;
    Interval: Integer;
    BallonLimiet: Boolean;
    BallonDataverkeer: Boolean;
    BallonOver: Boolean;
    BallonVandaag: Boolean;
    BallonPercentages: Boolean;
    Left: Integer;
    Top: Integer;
    Width: Integer;
    Height: Integer;
    Geluid: String;
    GeluidSpelen: Boolean;
    WarnVerschil: Integer;
    WarnHoger: Integer;
    bWarnVerschil: Boolean;
    bWarnHoger: Boolean;
    bWarnOverschreden: Boolean;
    Speaker: Boolean;
    VerhoogLimiet: Boolean;
    AdapterNaam: String;
    VerbreekVerbinding: Boolean;
    VerbreekPercentage: Integer;
    VerbreekVerbindingDag: Boolean;
    VerbreekDataDag: Integer;
    ShowOnStartup: Boolean;
    ProcentInIcoon: Boolean;
    FlashIcon: Boolean;
  end;

const
  WM_FILLMENU = WM_USER + 34;

type
  TfrmPipMain = class(TForm)
    mnuMain: TMainMenu;
    stbStatus: TStatusBar;
    PipView1: TMenuItem;
    Help1: TMenuItem;
    Vernieuwen1: TMenuItem;
    Ballontonen1: TMenuItem;
    N1: TMenuItem;
    Opties1: TMenuItem;
    N2: TMenuItem;
    Afsluiten1: TMenuItem;
    imlTable: TImageList;
    lstTable: TNoScrollListView;
    pmuData: TPopupMenu;
    Kopiren1: TMenuItem;
    pmuPopup: TPopupMenu;
    mnuVensterTonen: TMenuItem;
    MenuItem1: TMenuItem;
    mnuGegevenstonen: TMenuItem;
    mnuGegevensvernieuwen: TMenuItem;
    MenuItem2: TMenuItem;
    N3: TMenuItem;
    mnuAfsluiten: TMenuItem;
    tmrUpdate: TTimer;
    Help2: TMenuItem;
    N4: TMenuItem;
    OpenPiPinbrowser1: TMenuItem;
    Help3: TMenuItem;
    Opties2: TMenuItem;
    Controlerenopupdates1: TMenuItem;
    OpenPiPinbrowser2: TMenuItem;
    N5: TMenuItem;
    Verbinding1: TMenuItem;
    N6: TMenuItem;
    PipViewwebsite1: TMenuItem;
    Emailnaarmaker1: TMenuItem;
    ntfTray: TCoolTrayIcon;
    Accounts: TMenuItem;
    trayBalloon: TBalloonControl;
    Limietcontrole1: TMenuItem;
    Verbindingverbreken1: TMenuItem;
    N7: TMenuItem;
    tmrBalloon: TTimer;
    steMaandWaarde: TLabel;
    steDataWaarde: TLabel;
    steDataverkeer: TLabel;
    steDag: TLabel;
    pgbMaand: TProgressBar;
    pgbData: TProgressBar;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure tmrUpdateTimer(Sender: TObject);
    procedure actHelpExecute(Sender: TObject);
    procedure actVernieuwenExecute(Sender: TObject);
    procedure actBallonExecute(Sender: TObject);
    procedure actOptiesExecute(Sender: TObject);
    procedure actPipBrowserExecute(Sender: TObject);
    procedure actAfsluitenExecute(Sender: TObject);
    procedure actVensterToonExecute(Sender: TObject);
    procedure actKopierenExecute(Sender: TObject);
    procedure actUpdateExecute(Sender: TObject);
    procedure VernieuwClick(Sender: TObject);
    procedure VerbreekClick(Sender: TObject);
    procedure ntfTrayStartup(Sender: TObject; var ShowMainForm: Boolean);
    procedure stbStatusHint(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure actEmailExecute(Sender: TObject);
    procedure actWebsiteExecute(Sender: TObject);
    procedure ntfTrayMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure AccountsClick(Sender: TObject);
    procedure actLimietExecute(Sender: TObject);
    procedure Verbindingverbreken1Click(Sender: TObject);
    procedure tmrBalloonTimer(Sender: TObject);
    procedure ntfTrayBalloonHintClick(Sender: TObject);
    procedure lstTableSelectItem(Sender: TObject; Item: TListItem;      Selected: Boolean);
  protected
    procedure WndProc(var Message: TMessage); override;
  private
    lastRealText: String;
    iconImages: TImageList;

    procedure WMSyscommand(var Msg: TWMSysCommand); message WM_SYSCOMMAND;
    procedure WMQueryEndSession(var Msg: TWMQueryEndSession); message WM_QUERYENDSESSION;
    procedure WMFillMenu(var Msg: TMessage); message WM_FILLMENU;

    procedure Refresh;
    procedure DataThreadDone(Sender: TObject);
    procedure DataThreadDoneLimiet(Sender: TObject);
    procedure DataThreadDoneLimietSecond(Sender: TObject);
    procedure UpdateThreadDone(Sender: TObject);
    procedure ToonBallon;
    procedure ZetWaarde(Item: Integer; Tekst: String);
    procedure CheckForUpdates();
    procedure FillMenus;
    procedure OpenPipInBrowser(strLogin, strWachtwoord: String);
    procedure LoadSettings;
    procedure BalloonWrapper(blnTitle, blnTekst: String; blnType, blnDuration: Integer);
    procedure FlashIcon;
    procedure loadActiveAccount();

    function getPeriodDone(): Single;
    function getPeriodLength(): Integer;
    function getPeriodLeft(): Single;
    function getPeriodPercentage(): Integer;
    function getDataPercentage(): Integer;
    function getPeriodPercentageFloat(): Single;
    function getDataPercentageFloat(): Single;
    function ForceForegroundWindow(hWnd: THandle): Boolean;
    function getIconPos(): TPoint;
    function getAccounts: TStringList;
  public
    Opties: TOpties;
    URL: String;
    ThreadRuns: Boolean;
    DataRetrieved: Boolean;
    activeAccount: String;
    accountsList: TStringList;

    procedure ToonWaarden;
    procedure Log(Text: String);
    procedure ShowMessage(Text: String; Owner: Integer = -1);
    procedure OpenHelp(URL: String);
    procedure fillAccountsMenu();
    procedure saveDirectPip();
    procedure SaveSettings;
  end;

type
  TDataThread = class(TThread)
  protected
    procedure Execute; override;
  end;

type
  TDataLimietThread = class(TThread)
  protected
    procedure Execute; override;
  end;

type
  TUpdate = class(TThread)
  protected
    procedure Execute; override;
  end;

var
  frmPipMain: TfrmPipMain;
  DataVerkeer: TDataVerkeer;
  VorigeData: TVorigeData;

implementation

uses opties, tools, accounts;

{$R *.dfm}

procedure TfrmPipMain.FormCreate(Sender: TObject);
var
  iCount: Integer;
  bShow, bAccountFromReg: Boolean;
begin
  bAccountFromReg := TRUE;

  for iCount := 1 to ParamCount do
  begin
    if LowerCase(ParamStr(iCount)) = '--account' then
    begin
      activeAccount := ParamStr(iCount + 1);
      bAccountFromReg := FALSE;
    end;
  end;

  if bAccountFromReg then
    loadActiveAccount();

  LoadSettings();

  accountsList := TStringList.Create;

  fillAccountsMenu();

  bShow       := FALSE;

  Log('Welkom bij PipView...');

  for iCount := 1 to ParamCount do
  begin
    if LowerCase(ParamStr(iCount)) = '--show' then
    begin
      bShow := TRUE;
    end;
  end;

  ThreadRuns := FALSE;

  ntfTray.Hint := 'PipView v' + GetAppVersionInfo;

  FillMenus;

  Caption := 'PipView ' + GetAppVersionInfo + ' (' + Opties.Naam + ')';

  if (Opties.AutoCheck) and (Opties.Naam <> 'naam') then
  begin
		Refresh;
  end;

  if (Opties.Left <> 0) and (Opties.Top <> 0) then
  begin
    Left   := Opties.Left;
    Top    := Opties.Top;
  end;

  Visible := Opties.ShowOnStartup or bShow;

  lastRealText := '';

  SendMessage(ntfTray.GetTooltipHandle, WM_USER + 24,0,500);

  lstTable.Columns[0].MaxWidth := Round((0.5) * lstTable.Width) - 4;
  lstTable.Columns[1].MaxWidth := Round((0.5) * lstTable.Width) - 4;

  lstTable.Columns[0].MinWidth := Round((0.5) * lstTable.Width) - 4;
  lstTable.Columns[1].MinWidth := Round((0.5) * lstTable.Width) - 4;

  lstTable.Columns[0].Width := Round((0.5) * lstTable.Width) - 4;
  lstTable.Columns[1].Width := Round((0.5) * lstTable.Width) - 4;
end;

procedure TfrmPipMain.saveDirectPip();
var
  strFileName: String;
  TempFile: TextFile;
begin
  strFilename := ExtractFilePath(Application.EXEName) + 'directpip.html';
  AssignFile(TempFile, strFilename);
  Rewrite(TempFile);
  WriteLn(TempFile, '<script language="JavaScript" type="text/javascript">');
  WriteLn(TempFile, 'if (typeof(external) == ''undefined'') { pipdoc = window.document; } else { if (typeof(external.menuArguments) == ''undefined'') { pipdoc = window.document; } else { pipdoc = external.menuArguments.document; } }');
  WriteLn(TempFile, 'pipdoc.open();');
  WriteLn(TempFile, 'pipdoc.write(''<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"><html><head><title>Inloggen Pip</title></head><body><p>Een moment alstublieft, er wordt ingelogd in op de ZeelandNet website...</p>'');');
  WriteLn(TempFile, 'pipdoc.write(''<form action="https://secure.zeelandnet.nl/login/index.php" method="post" name="piplogin">'');');
  WriteLn(TempFile, 'pipdoc.write(''<input type="hidden" name="login_name" value="''+unescape('''+javaScriptEncode(Opties.Naam)+''')+''">'');');
  WriteLn(TempFile, 'pipdoc.write(''<input type="hidden" name="login_pass" value="''+unescape('''+javaScriptEncode(Opties.Wachtwoord)+''')+''">'');');
  WriteLn(TempFile, 'pipdoc.write(''<input type="hidden" name="login_type" value="abonnee"><input type="hidden" name="action" value="login"></form></body></html>'');');
  WriteLn(TempFile, 'pipdoc.forms[''piplogin''].submit();');
  WriteLn(TempFile, '</script>');
  CloseFile(TempFile);
end;

procedure TfrmPipMain.WMSyscommand(var Msg: TWMSysCommand);
begin
  if (Msg.CmdType = SC_CLOSE) then
  begin
    ntfTray.HideMainForm;
    Exit;
  end;

  inherited;
end;

procedure TfrmPipMain.loadActiveAccount();
var
  Settings: TRegistry;
begin
  activeAccount := '0';

  Settings         := TRegistry.Create;
  Settings.RootKey := HKEY_CURRENT_USER;
  if Settings.OpenKey('\Software\PipView\', TRUE) then
  begin
    if Settings.ValueExists('activeaccount') then
      activeAccount := Settings.ReadString('activeaccount');
  end;
  Settings.CloseKey;
end;

procedure TfrmPipMain.LoadSettings;
var
  Settings: TRegistry;
begin
  with Opties do
  begin
    Naam           := 'naam';
    Wachtwoord     := 'wachtwoord';
    ToonBallon     := TRUE;
    Waarschuwingen := TRUE;
    AutoCheck      := TRUE;
    Interval       := 30;
    Geluid         := 'Geen';
    GeluidSpelen   := FALSE;
    WarnVerschil   := 20;
    WarnHoger      := 95;
    bWarnVerschil  := TRUE;
    bWarnHoger     := TRUE;
    bWarnOverschreden := TRUE;
    Speaker        := FALSE;
    BallonLimiet   := TRUE;
    BallonDataverkeer := TRUE;
    BallonOver     := TRUE;
    BallonVandaag  := FALSE;
    BallonPercentages := FALSE;
    AdapterNaam    := '';
    VerbreekPercentage := 99;
    VerbreekVerbinding := FALSE;
    VerbreekVerbindingDag := FALSE;
    VerbreekDataDag := 50;
    ShowOnStartup  := FALSE;
    VerhoogLimiet  := FALSE;
    ProcentInIcoon := FALSE;
    FlashIcon := FALSE;
  end;

  Settings := TRegistry.Create;
  Settings.RootKey := HKEY_CURRENT_USER;
  if Settings.OpenKey('\Software\PipView\' + activeAccount + '\', TRUE) then
  begin
    with Settings do
    begin
      if ValueExists('naam') then
        Opties.Naam := ReadString('naam');

      if ValueExists('wachtwoord_raw') then
      begin
        Opties.Wachtwoord := ReadString('wachtwoord_raw');
        Settings.DeleteValue('wachtwoord_raw');
      end
      else
      begin
        if ValueExists('wachtwoord') then
          Opties.Wachtwoord := Decrypt(ReadString('wachtwoord'));
      end;

      if ValueExists('checkAutomatic') then
        Opties.AutoCheck := ReadBool('checkAutomatic');
      if ValueExists('checkInterval') then
        Opties.Interval := ReadInteger('checkInterval');

      if ValueExists('warningFlashIcon') then
        Opties.FlashIcon := ReadBool('warningFlashIcon');
      if ValueExists('warningBallon') then
        Opties.Waarschuwingen := ReadBool('warningBallon');
      if ValueExists('warningWaveFile') then
        Opties.Geluid := ReadString('warningWaveFile');
      if ValueExists('warningWave') then
        Opties.GeluidSpelen := ReadBool('warningWave');
      if ValueExists('warningSpeaker') then
        Opties.Speaker := ReadBool('warningSpeaker');

      if ValueExists('warnVerschilValue') then
        Opties.WarnVerschil := ReadInteger('warnVerschilValue');
      if ValueExists('warnHogerValue') then
        Opties.WarnHoger := ReadInteger('warnHogerValue');
      if ValueExists('warnVerschil') then
        Opties.bWarnVerschil := ReadBool('warnVerschil');
      if ValueExists('warnHoger') then
        Opties.bWarnHoger := ReadBool('warnHoger');
      if ValueExists('warnOverschreden') then
        Opties.bWarnOverschreden := ReadBool('warnOverschreden');

      if ValueExists('ballonTonen') then
        Opties.ToonBallon := ReadBool('ballonTonen');
      if ValueExists('ballonLimiet') then
        Opties.BallonLimiet := ReadBool('ballonLimiet');
      if ValueExists('ballonDataverkeer') then
        Opties.BallonDataverkeer := ReadBool('ballonDataverkeer');
      if ValueExists('ballonOver') then
        Opties.BallonOver := ReadBool('ballonOver');
      if ValueExists('ballonVandaag') then
        Opties.BallonVandaag := ReadBool('ballonVandaag');
      if ValueExists('ballonPercentages') then
        Opties.BallonPercentages := ReadBool('ballonPercentages');

      if ValueExists('connAdapternaam') then
        Opties.AdapterNaam := ReadString('connAdapternaam');
      if ValueExists('connVerbreekVerbinding') then
        Opties.VerbreekVerbinding := ReadBool('connVerbreekVerbinding');
      if ValueExists('connVerbreekVerbindingValue') then
        Opties.VerbreekPercentage := ReadInteger('connVerbreekVerbindingValue');
      if ValueExists('connVerbreekVerbindingDag') then
        Opties.VerbreekVerbindingDag := ReadBool('connVerbreekVerbindingDag');
      if ValueExists('connVerbreekVerbindingDagValue') then
        Opties.VerbreekDataDag := ReadInteger('connVerbreekVerbindingDagValue');

      if ValueExists('windowLeft') then
        Opties.Left := ReadInteger('windowLeft');
      if ValueExists('windowTop') then
        Opties.Top := ReadInteger('windowTop');

      if ValueExists('algShowOnStartup') then
        Opties.ShowOnStartup := ReadBool('algShowOnStartup');
      if ValueExists('algVerhoogLimiet') then
        Opties.VerhoogLimiet := ReadBool('algVerhoogLimiet');
      if ValueExists('algProcentInIcoon') then
        Opties.ProcentInIcoon := ReadBool('algProcentInIcoon');
    end;
    Settings.CloseKey;
  end;
  Settings.Free;

  tmrUpdate.Enabled := (Opties.Interval <> 0);
  tmrUpdate.Interval := Opties.Interval * 60 * 1000;

  saveDirectPip();
end;

procedure TfrmPipMain.SaveSettings;
var
  Settings: TRegistry;
begin
  Opties.Left   := frmPipMain.Left;
  Opties.Top    := frmPipMain.Top;

  Settings         := TRegistry.Create;
  Settings.RootKey := HKEY_CURRENT_USER;

  if Settings.OpenKey('\Software\PipView\', TRUE) then
  begin
    Settings.WriteString('activeaccount', activeAccount);
    Settings.CloseKey;
  end;

  if Settings.OpenKey('\Software\PipView\'+activeAccount+'\', TRUE) then
  begin
    with Settings do
    begin
      WriteString('naam', Opties.Naam);
      WriteString('wachtwoord', Encrypt(Opties.Wachtwoord));

      WriteBool('checkAutomatic', Opties.AutoCheck);
      WriteInteger('checkInterval', Opties.Interval);

      WriteBool('warningFlashIcon', Opties.FlashIcon);
      WriteBool('warningSpeaker', Opties.Speaker);
      WriteString('warningWaveFile', Opties.Geluid);
      WriteBool('warningWave', Opties.GeluidSpelen);
      WriteBool('warningBallon', Opties.Waarschuwingen);

      WriteInteger('warnVerschilValue', Opties.WarnVerschil);
      WriteInteger('warnHogerValue', Opties.WarnHoger);
      WriteBool('warnVerschil', Opties.bWarnVerschil);
      WriteBool('warnHoger', Opties.bWarnHoger);
      WriteBool('warnOverschreden', Opties.bWarnOverschreden);

      WriteBool('ballonTonen', Opties.ToonBallon);
      WriteBool('ballonLimiet', Opties.BallonLimiet);
      WriteBool('ballonDataverkeer', Opties.BallonDataverkeer);
      WriteBool('ballonOver', Opties.BallonOver);
      WriteBool('ballonVandaag', Opties.BallonVandaag);
      WriteBool('ballonPercentages', Opties.BallonPercentages);

      WriteString('connAdapternaam', Opties.AdapterNaam);
      WriteBool('connVerbreekVerbinding', Opties.VerbreekVerbinding);
      WriteInteger('connVerbreekVerbindingValue', Opties.VerbreekPercentage);
      WriteBool('connVerbreekVerbindingDag', Opties.VerbreekVerbindingDag);
      WriteInteger('connVerbreekVerbindingDagValue', Opties.VerbreekDataDag);

      WriteInteger('windowLeft', Opties.Left);
      WriteInteger('windowTop', Opties.Top);

      WriteBool('algShowOnStartup', Opties.ShowOnStartup);
      WriteBool('algVerhoogLimiet', Opties.VerhoogLimiet);
      WriteBool('algProcentInIcoon', Opties.ProcentInIcoon);
    end;

    Settings.CloseKey;
  end;
  Settings.Free;
end;

procedure TfrmPipMain.Log(Text: String);
begin
  stbStatus.SimpleText := FormatDateTime(' hh:nn:ss > ', Now) + Text;
  lastRealText         := stbStatus.SimpleText;
end;

procedure TfrmPipMain.ShowMessage(Text: String; Owner: Integer = -1);
begin
  if Owner = -1 then
    Owner := Handle;

  MessageBox(Owner, PChar(Text), 'PipView', MB_OK or MB_ICONINFORMATION);
end;

procedure TDataThread.Execute;
var
  strResult: String;
  strNaam, strWachtwoord: String;
  RegExpr: TRegExpr;
  LoginResult: Integer;
begin
  strNaam       := frmPipMain.Opties.Naam;
  strWachtwoord := frmPipMain.Opties.Wachtwoord;

  // Alle returnwaarden worden op nul gezet.
  Dataverkeer.Fouten := 0;
  Dataverkeer.VrijVerkeer := 0;
  Dataverkeer.MaandData.Ontvangen := 0;
  Dataverkeer.MaandData.Verstuurd := 0;
  Dataverkeer.MaandData.Totaal := 0;
  Dataverkeer.Vandaag.Down := 0;
  Dataverkeer.Vandaag.Up := 0;
  Dataverkeer.Periode.Start := Now;
  Dataverkeer.Periode.Eind := Now;
  Dataverkeer.Datum := Now;
  Dataverkeer.Periode.Nummer := 0;
  Dataverkeer.Periode.Jaar := 0;

  LoginResult := Login(strNaam, strWachtwoord);

  if LoginResult = 2 then
  begin
    Dataverkeer.Fouten := 1;
    Exit;
  end;

  strResult := GetHTTP('https://secure.zeelandnet.nl/pip/index.php?page=202');

  Logoff;

  if Pos('<meta http-equiv=''refresh'' content=''0; url=https://secure.zeelandnet.nl/logout/index.php?from=https://secure.zeelandnet.nl/pip/index.php?page=202''>', strResult) > 0 then
  begin
    Dataverkeer.Fouten := 2;
    Exit;
  end;

  RegExpr := TRegExpr.Create;

  // bepalen van de datalimiet per periode
  RegExpr.Expression := 'Uw data-limiet is: (.*?) MB per periode.';
  if RegExpr.Exec(strResult) then
    Dataverkeer.VrijVerkeer := StrToInt(Trim(RegExpr.Match[1]))
  else
  begin
    Dataverkeer.Fouten := 3;
    Exit;
  end;

  // bepalen van start- en einddatum huidige periode
  RegExpr.Expression := '<\/b> &nbsp;\((.*?) t\/m (.*?)\)';
  if RegExpr.Exec(strResult) then
  begin
    Dataverkeer.Datum         := Now;
    Dataverkeer.Periode.Start := StrToDate(RegExpr.Match[1]);
    Dataverkeer.Periode.Eind  := StrToDate(RegExpr.Match[2]);

    if (Dataverkeer.Datum < (Dataverkeer.Periode.Start)) or (Dataverkeer.Datum > (Dataverkeer.Periode.Eind + 1)) then
    begin
      Dataverkeer.Fouten := 4;
      Exit;
    end;
  end
  else
  begin
    Dataverkeer.Fouten := 3;
    Exit;
  end;

  // vanaf hier multiline strings filteren
  RegExpr.ModifierS := TRUE;

  // gegevens over huidige periode ophalen
  RegExpr.Expression := '(8er_abostats_on.gif\"><b><a)(.*?)(href=\")(\?page=202\&show=1\&periode=)(\d*)(-)(\d*)(\" class=\"FontLinkAboKlein\")';
  if RegExpr.Exec(strResult) then
  begin
    Dataverkeer.Periode.Nummer := StrToInt(RegExpr.Match[5]);
    Dataverkeer.Periode.Jaar := StrToInt(RegExpr.Match[7]);
  end
  else
  begin
    Dataverkeer.Fouten := 3;
    Exit;
  end;

  // vandaag gedownload verkeer
  RegExpr.Expression := '&nbsp;in<(.*?)&nbsp;&nbsp;(.*?)<\/td>(.*?)&nbsp;&nbsp;(.*?)<\/td>';
  if RegExpr.Exec(strResult) then
  begin
    Dataverkeer.Vandaag.Down := FilterString(RegExpr.Match[2]) + FilterString(RegExpr.Match[4]);
  end
  else
  begin
    Dataverkeer.Fouten := 3;
    Exit;
  end;

  // vandaag geupload verkeer
  RegExpr.Expression := '&nbsp;uit<(.*?)&nbsp;&nbsp;(.*?)<\/td>(.*?)&nbsp;&nbsp;(.*?)<\/td>';
  if RegExpr.Exec(strResult) then
  begin
    Dataverkeer.Vandaag.Up := FilterString(RegExpr.Match[2]) + FilterString(RegExpr.Match[4]);
  end
  else
  begin
    Dataverkeer.Fouten := 3;
    Exit;
  end;

  // gedownload verkeer
  RegExpr.Expression := '<b>Kabel<\/b>(.*?)Bytes ontvangen(.*?)<td align=\"center\">(.*?)<\/td>(.*?)<td align=\"center\">(.*?)<\/td>(.*?)<td align=\"center\">(.*?)<\/td>(.*?)<td align=\"center\">(.*?)<\/td>(.*?)<td align=\"center\">(.*?)<\/td>';
  if RegExpr.Exec(strResult) then
  begin
    Dataverkeer.MaandData.Ontvangen := FilterString(RegExpr.Match[11]);
  end
  else
  begin
    Dataverkeer.Fouten := 3;
    Exit;
  end;

  // geupload verkeer
  RegExpr.Expression := '<b>Kabel<\/b>(.*?)Bytes verstuurd(.*?)<td align=\"center\">(.*?)<\/td>(.*?)<td align=\"center\">(.*?)<\/td>(.*?)<td align=\"center\">(.*?)<\/td>(.*?)<td align=\"center\">(.*?)<\/td>(.*?)<td align=\"center\">(.*?)<\/td>';
  if RegExpr.Exec(strResult) then
  begin
    Dataverkeer.MaandData.Verstuurd := FilterString(RegExpr.Match[11]);
  end
  else
  begin
    Dataverkeer.Fouten := 3;
    Exit;
  end;

  // totaal verkeer
  RegExpr.Expression := '<b>Kabel<\/b>(.*?)Totaal(.*?)<td align=\"center\"><B>(.*?)<\/B><\/td>';
  if RegExpr.Exec(strResult) then
  begin
    Dataverkeer.MaandData.Totaal := FilterString(RegExpr.Match[3]);
  end
  else
  begin
    Dataverkeer.Fouten := 3;
    Exit;
  end;

  RegExpr.Free;
end;

procedure TfrmPipMain.Refresh;
var
  DataThread: TDataThread;
begin
  Screen.Cursor := crHourGlass;

  if ThreadRuns = FALSE then
  begin
    ThreadRuns := TRUE;
    DataThread := TDataThread.Create(TRUE);
    DataThread.Priority := tpLowest;
    DataThread.OnTerminate := DataThreadDone;
    DataThread.FreeOnTerminate := TRUE;
    DataThread.Resume;
  end;
end;

procedure TfrmPipMain.DataThreadDone(Sender: TObject);
var
  blnBalloonShown: Boolean;
  intPercentage, intMaandPerc, intDiff, intAdapterIndex: Integer;
  overSchrijding, geldBoete: Single;
begin
  ThreadRuns    := FALSE;
  Screen.Cursor := crDefault;
  geldBoete     := 0;

  if DataVerkeer.Fouten <> 0 then
  begin
    case Dataverkeer.Fouten of
      1:
        Log('Fout: Server onbereikbaar.');
      2:
        Log('Fout: De combinatie loginnaam - wachtwoord is niet correct.');
      3:
        Log('Fout: Verwerking gegevens mislukt (Pip kan gewijzigd zijn).');
      4:
        Log('Fout: Datum van de pc komt niet overeen met PiP-gegevens.');
      else
        Log('Fout: Onbekende fout. Geef dit aub door aan de maker van PipView.');
    end;

    Exit;
  end;

  DataRetrieved := TRUE;

  Log('Limiet en dataverkeer opgehaald');

  if Opties.VerhoogLimiet then
    Dataverkeer.VrijVerkeer := Dataverkeer.VrijVerkeer * 2;

  // totaal aantal mb in tooltip zetten
  ntfTray.Hint := 'PipView v' + GetAppVersionInfo + #13#10 + FormatFloat('Totaal: ,0.0 MB', (DataVerkeer.MaandData.Totaal));

  // de gegevens worden weergegeven
  ToonWaarden;

  intPercentage := getDataPercentage;
  intMaandPerc  := getPeriodPercentage;

  intDiff := intPercentage - intMaandPerc;
  blnBalloonShown := FALSE;

  if (Opties.bWarnVerschil and (intDiff >= Opties.WarnVerschil)) then
  begin
    if Opties.GeluidSpelen and (Opties.Geluid <> 'Geen') then
      PlaySound(PChar(Opties.Geluid), 0, SND_FILENAME + SND_ASYNC);

    if Opties.Waarschuwingen then
    begin
      BalloonWrapper('Waarschuwing', 'Pas op! Als u deze maand nog meer wil downloaden, zult u het gebruik nu wat moeten matigen.', 1,15);
      blnBalloonShown := TRUE;
    end;

    if Opties.Speaker then
      Siren;

    if Opties.FlashIcon then
      FlashIcon;
  end;

  if (Opties.bWarnHoger and (intPercentage >= Opties.WarnHoger) and (intPercentage <= 100)) then
  begin
    if Opties.GeluidSpelen and (Opties.Geluid <> 'Geen') then
      PlaySound(PChar(Opties.Geluid), 0, SND_FILENAME + SND_ASYNC);

    if Opties.Waarschuwingen then
    begin
      BalloonWrapper('Waarschuwing', 'U nadert uw limiet, u zit nu op ' + IntToStr(intPercentage) + ' % van uw dataverkeer.', 1,15);
      blnBalloonShown := TRUE;
    end;

    if Opties.Speaker then
      Siren;

    if Opties.FlashIcon then
      FlashIcon;
  end;

  if (Opties.bWarnOverschreden and (DataVerkeer.MaandData.Totaal > DataVerkeer.VrijVerkeer)) then
  begin
    if Opties.GeluidSpelen and (Opties.Geluid <> 'Geen') then
      PlaySound(PChar(Opties.Geluid), 0, SND_FILENAME + SND_ASYNC);

    if Opties.Waarschuwingen then
    begin
      overSchrijding := Dataverkeer.MaandData.Totaal - Dataverkeer.VrijVerkeer;
      case Round(Dataverkeer.VrijVerkeer) of
        150:
          geldBoete := 0.16 * overSchrijding;
        250:
          geldBoete := 0.16 * overSchrijding;
        500:
          geldBoete := 0.08 * overSchrijding;
        1000:
          geldBoete := 0.04 * overSchrijding;
        3750:
          geldBoete := 0.0075 * overSchrijding;
        7500:
          geldBoete := 0.005 * overSchrijding;
        15000:
          geldBoete := 0.0025 * overSchrijding;
        50000:
          geldBoete := 0.0025 * overSchrijding;
      end;

      if geldBoete <> 0 then
        BalloonWrapper('Waarschuwing', 'U heeft uw limiet overschreden!'#13#10#13#10'Wanneer u een Budget-abonnement heeft (of wanneer u geen FUP meer heeft!), kost dit: ' + FormatFloat('0.00 Euro', geldBoete), 1,15)
      else
        BalloonWrapper('Waarschuwing', 'U heeft uw limiet overschreden!'#13#10#13#10'Er is niet bekend wat de hoogte van uw boete is wanneer u een Budget-abonnement heeft (of wanneer u geen FUP meer heeft!)',1,15);
      blnBalloonShown := TRUE;
    end;

    if Opties.Speaker then
      Siren;

    if Opties.FlashIcon then
      FlashIcon;
  end;

  if (Opties.VerbreekVerbindingDag and (Dataverkeer.Vandaag.Down + Dataverkeer.Vandaag.Up >= Opties.VerbreekDataDag)) then
  begin
    intAdapterIndex := AdapterNameToIndex(Opties.AdapterNaam);
    if intAdapterIndex <> -1 then
    begin
      DHCPPerform(TRUE, intAdapterIndex);
      BalloonWrapper('Waarschuwing', 'Uw internetverbinding is door PipView verbroken! Kijk in het helpbestand als u niet weet hoe u deze weer kunt inschakelen.', 1,15);
      blnBalloonShown := TRUE;
    end;
  end;

  if (Opties.VerbreekVerbinding and (intPercentage >= Opties.VerbreekPercentage)) then
  begin
    intAdapterIndex := AdapterNameToIndex(Opties.AdapterNaam);
    if intAdapterIndex <> -1 then
    begin
      DHCPPerform(TRUE, intAdapterIndex);
      BalloonWrapper('Waarschuwing', 'Uw internetverbinding is door PipView verbroken! Kijk in het helpbestand als u niet weet hoe u deze weer kunt inschakelen.', 1,15);
      blnBalloonShown := TRUE;
    end;
  end;

  if (Opties.ToonBallon) and (blnBalloonShown = FALSE) then
    ToonBallon;
end;

procedure TfrmPipMain.FlashIcon;
var
  newIcon: TIcon;
begin
  iconImages := TImageList.Create(Self);
  iconImages.Width := 16;
  iconImages.Height := 16;
  iconImages.AddIcon(ntfTray.Icon);
  newIcon := TIcon.Create();
  newIcon.Handle := LoadIcon(SysInit.HInstance, MakeIntResource(103));
  iconImages.AddIcon(newIcon);
  newIcon.Free;
  ntfTray.IconList := iconImages;
  ntfTray.CycleInterval := 500;
  ntfTray.CycleIcons := TRUE;
end;

procedure TfrmPipMain.ToonWaarden;
var
  DataMax, DataPos, MaandMax, MaandPos: Integer;
  fBalans, fBalansDagen: Single;
  sData, sMaand: String;
  IconData: TIcon;
begin
  DataMax := 0;
  DataPos := 0;

  // de lijst wordt gevuld met de waarden
  ZetWaarde(0, FormatFloat(',0.0 MB', (DataVerkeer.VrijVerkeer)));

  ZetWaarde(2, FormatFloat(',0.0 MB', (DataVerkeer.MaandData.Ontvangen)));
  ZetWaarde(3, FormatFloat(',0.0 MB', (DataVerkeer.MaandData.Verstuurd)));
  ZetWaarde(4, FormatFloat(',0.0 MB', (DataVerkeer.MaandData.Totaal)));

  ZetWaarde(6, FormatFloat(',0.0 MB', (DataVerkeer.VrijVerkeer - DataVerkeer.MaandData.Totaal)));
  ZetWaarde(7, IntToStr(Floor(getPeriodLeft)) + ' dag(en)');

  // de balk die aangeeft hoever je in de maand bent wordt ingevuld
  MaandMax := getPeriodLength;
  MaandPos := Ceil(getPeriodDone);

  fBalans := 0;
  fBalansDagen := 0;

  if getPeriodLeft <> 0 then
  begin
    fBalans := (getPeriodDone * (Dataverkeer.VrijVerkeer / getPeriodLength)) - Dataverkeer.Maanddata.Totaal;
    if Dataverkeer.VrijVerkeer <> 0 then
      fBalansDagen := getPeriodDone - (Dataverkeer.Maanddata.Totaal * (getPeriodLength / Dataverkeer.VrijVerkeer));

    ZetWaarde(8, FormatFloat(',0.0 MB', DataVerkeer.Vandaag.Down + DataVerkeer.Vandaag.Up) +      ' / ' + FormatFloat(',0.0 MB', (DataVerkeer.VrijVerkeer - DataVerkeer.MaandData.Totaal) /      getPeriodLeft));
    ZetWaarde(9, FormatFloat('+ ,0.0 MB;- ,0.0 MB', fBalans) + ' / ' + FormatFloat('+ 0.0 dag(en);- 0.0 dag(en)', fBalansDagen));
  end;

  // de informatie over de maand wordt nog eens tekstueel weergeven
  if (MaandPos <> 0) and (MaandMax <> 0) then
    sMaand := FormatFloat('0.0 % ', getPeriodPercentageFloat) + '( ' + IntToStr(MaandPos) + ' / ' + IntToStr(MaandMax) + ' )';

  if (DataVerkeer.VrijVerkeer <> 0) and (DataVerkeer.MaandData.Totaal <> 0) then
  begin
    DataMax := Round(DataVerkeer.VrijVerkeer);
    DataPos := Round(DataVerkeer.MaandData.Totaal);
  end;

  // het dataverkeer wordt in de progressbar gezet
  if (DataPos <> 0) and (DataMax <> 0) then
    sData := FormatFloat('0.0 %', getDataPercentageFloat) + ' ( ' + FormatFloat('0.0 MB', DataVerkeer.MaandData.Totaal) + ' / ' + FormatFloat('0.0 MB', DataVerkeer.VrijVerkeer) + ' )';

  if Visible then
  begin
    pgbMaand.Max      := 100;
    pgbMaand.Position := getPeriodPercentage;

    pgbData.Max      := 100;
    pgbData.Position := getDataPercentage;

    steDataWaarde.Caption  := sData;
    steMaandWaarde.Caption := sMaand;

    if DataVerkeer.Periode.Start <> 0 then
      steDag.Caption := 'Dag v/d periode (' + FormatDateTime('d mmmm', DataVerkeer.Periode.Start) + ' t/m ' + FormatDateTime('d mmmm', DataVerkeer.Periode.Eind) + '):';
  end;

  if (DataPos <> 0) or (DataMax <> 0) then
  begin
    if (getDataPercentage < 100) then
    begin
      if (fBalans <= 0) then
      begin
        IconData     := TrayIcon(getDataPercentage, Opties.ProcentInIcoon, clRed);
        ntfTray.Icon := IconData;
        IconData.Free;
      end
      else
      begin
        IconData     := TrayIcon(getDataPercentage, Opties.ProcentInIcoon, clGreen);
        ntfTray.Icon := IconData;
        IconData.Free;
      end;
    end
    else
    begin
      IconData     := TrayIcon(0, Opties.ProcentInIcoon, clRed);
      ntfTray.Icon := IconData;
      IconData.Free;
    end;
  end
  else
  begin
    IconData     := TrayIcon(0, Opties.ProcentInIcoon, clRed);
    ntfTray.Icon := IconData;
    IconData.Free;
  end;
end;

procedure TfrmPipMain.ZetWaarde(Item: Integer; Tekst: String);
var
  strItem: TStrings;
begin
  strItem := TStringList.Create;
  strItem.Add(Tekst);

  if Visible then
    lstTable.Items[Item].SubItems := strItem;

  strItem.Free;
end;

procedure TfrmPipMain.ToonBallon;
var
  strBallon: String;
begin
  // ballon met informatie tonen

  if Opties.BallonLimiet then
    strBallon := strBallon + FormatFloat(',0.0 MB', (DataVerkeer.VrijVerkeer)) + ' limiet'#13#10#13#10;

  if Opties.BallonDataverkeer then
  begin
    strBallon := strBallon + FormatFloat(',0.0 MB', (DataVerkeer.MaandData.Ontvangen)) + ' ontvangen'#13#10 + FormatFloat(',0.0 MB', (DataVerkeer.MaandData.Verstuurd)) + ' verstuurd'#13#10 + FormatFloat(',0.0 MB', (DataVerkeer.MaandData.Totaal)) + ' totaal'#13#10#13#10;
  end;

  if Opties.BallonOver then
  begin
    if getPeriodLeft <> 0 then
    begin
      if Dataverkeer.VrijVerkeer <> 0 then
        strBallon := strBallon + FormatFloat(',0.0 MB', (DataVerkeer.VrijVerkeer - DataVerkeer.MaandData.Totaal)) + ' over'#13#10 + FormatFloat(',0.0 MB', (DataVerkeer.VrijVerkeer - DataVerkeer.MaandData.Totaal) / getPeriodLeft) + ' over per dag'#13#10 + FormatFloat('+ ,0.0 Mb;- ,0.0 MB', (getPeriodDone * (Dataverkeer.VrijVerkeer / getPeriodLength)) - Dataverkeer.Maanddata.Totaal) + ' balans'#13#10 + FormatFloat('+ 0.0 dag(en);- 0.0 dag(en)', getPeriodDone - (Dataverkeer.Maanddata.Totaal * (getPeriodLength / Dataverkeer.VrijVerkeer))) + ' balans'#13#10 + IntToStr(Floor(getPeriodLeft)) + ' dag(en) over'#13#10#13#10
      else
        strBallon := strBallon + FormatFloat(',0.0 MB', (DataVerkeer.VrijVerkeer - DataVerkeer.MaandData.Totaal)) + ' over'#13#10 + FormatFloat(',0.0 MB', (DataVerkeer.VrijVerkeer - DataVerkeer.MaandData.Totaal) / getPeriodLeft) + ' over per dag'#13#10 + FormatFloat('+ ,0.0 Mb;- ,0.0 MB', (getPeriodDone * (Dataverkeer.VrijVerkeer / getPeriodLength)) - Dataverkeer.Maanddata.Totaal) + ' balans'#13#10 + IntToStr(Floor(getPeriodLeft)) + ' dag(en) over'#13#10#13#10;
    end;
  end;

  if Opties.BallonVandaag then
  begin
    strBallon := strBallon + FormatFloat(',0.0 MB', DataVerkeer.Vandaag.Down) + ' down vandaag '#13#10 + FormatFloat('0.0 MB', DataVerkeer.Vandaag.Up) + ' up vandaag '#13#10#13#10;
  end;

  if Opties.BallonPercentages then
  begin
    strBallon := strBallon + IntToStr(getDataPercentage) + ' % dataverkeer'#13#10 + IntToStr(getPeriodPercentage) + ' % periode'#13#10#13#10;
  end;

  strBallon := Copy(strBallon, 0, Length(strBallon) - 4);

  BalloonWrapper('Dataverkeer', strBallon, 0,15);
end;

function TfrmPipMain.ForceForegroundWindow(hWnd: THandle): Boolean;
var
  hCurWnd: THandle;
begin
  hCurWnd := GetForegroundWindow;
  AttachThreadInput(GetWindowThreadProcessId(hCurWnd, NIL), GetCurrentThreadId, TRUE);

  Result := SetForegroundWindow(hWnd);
  AttachThreadInput(GetWindowThreadProcessId(hCurWnd, NIL), GetCurrentThreadId, FALSE);
end;

procedure TfrmPipMain.FormShow(Sender: TObject);
begin
  ToonWaarden;
  ForceForegroundWindow(Handle);
  SetActiveWindow(Handle);
  SetFocus;

  if lastRealText <> '' then
    stbStatus.SimpleText := lastRealText;
end;

procedure TfrmPipMain.tmrUpdateTimer(Sender: TObject);
begin
  if (Opties.Naam <> 'naam') and (Opties.AutoCheck) then
    Refresh;
end;

procedure TfrmPipMain.actHelpExecute(Sender: TObject);
begin
  OpenHelp('::/hoofdvenster.html');
end;

procedure TfrmPipMain.OpenHelp(URL: String);
begin
  ShellExecute(Handle, 'open', 'hh.exe', PChar('"' +    ExtractFilePath(Application.EXEName) + 'pipview.chm' + URL + '"'),
    PChar(ExtractFilePath(Application.EXEName)), SW_SHOWNORMAL);
end;

procedure TfrmPipMain.actVernieuwenExecute(Sender: TObject);
begin
  Refresh;
end;

procedure TfrmPipMain.actBallonExecute(Sender: TObject);
begin
  ToonBallon;
end;

procedure TfrmPipMain.actOptiesExecute(Sender: TObject);
var
  frmOpties: TfrmOpties;
  iCount: Integer;
begin
  frmOpties := TfrmOpties.Create(Self);

  frmOpties.ediNaam.Text       := Opties.Naam;
  frmOpties.ediWachtwoord.Text := Opties.Wachtwoord;

  frmOpties.chkBallon.Checked   := Opties.ToonBallon;
  frmOpties.chkWarnings.Checked := Opties.Waarschuwingen;
  frmOpties.chkFlashIcon.Checked := Opties.FlashIcon;
  frmOpties.ediGeluid.Text      := Opties.Geluid;
  frmOpties.chkGeluid.Checked   := Opties.GeluidSpelen;
  frmOpties.chkSpeaker.Checked  := Opties.Speaker;

  frmOpties.chkLimiet.Checked         := Opties.BallonLimiet;
  frmOpties.chkDataverkeer.Checked    := Opties.BallonDataverkeer;
  frmOpties.chkVerkeerOver.Checked    := Opties.BallonOver;
  frmOpties.chkVerkeerVandaag.Checked := Opties.BallonVandaag;
  frmOpties.chkPercentages.Checked    := Opties.BallonPercentages;

  frmOpties.chkWarnVerschil.Checked  := Opties.bWarnVerschil;
  frmOpties.chkWarnHoger.Checked     := Opties.bWarnHoger;
  frmOpties.speWarnVerschil.Position := Opties.WarnVerschil;
  frmOpties.speWarnHoger.Position    := Opties.WarnHoger;
  frmOpties.chkWarnOver.Checked      := Opties.bWarnOverschreden;

  frmOpties.chkVerhoogLimiet.Checked := Opties.VerhoogLimiet;

  frmOpties.speVerbinding.Position := Opties.VerbreekPercentage;
  frmOpties.chkVerbinding.Checked  := Opties.VerbreekVerbinding;

  frmOpties.speVerbindingDag.Position := Opties.VerbreekDataDag;
  frmOpties.chkVerbindingDag.Checked  := Opties.VerbreekVerbindingDag;

  for iCount := 0 to frmOpties.cmbAdapters.Items.Count - 1 do
  begin
    if (frmOpties.cmbAdapters.Items[iCount] = Opties.AdapterNaam) then
      frmOpties.cmbAdapters.ItemIndex := iCount;
  end;

  if (Opties.Interval = 0) then
    frmOpties.chkVernieuwen.Checked := False
  else
  begin
    frmOpties.chkVernieuwen.Checked   := True;
    frmOpties.speBijwerken.Position := Opties.Interval;
  end;

  frmOpties.chkIcoonPercentage.Checked := Opties.ProcentInIcoon;

  frmOpties.ShowModal;
end;

procedure TfrmPipMain.OpenPipInBrowser(strLogin, strWachtwoord: String);
begin
  saveDirectPip();
  ShellExecute(Handle, 'open', PChar(ExtractFilePath(Application.EXEName) + 'directpip.html'), NIL, NIL, SW_SHOWNORMAL);
end;

procedure TfrmPipMain.actPipBrowserExecute(Sender: TObject);
begin
  OpenPipInBrowser(Opties.Naam, Opties.Wachtwoord);
end;

procedure TfrmPipMain.actAfsluitenExecute(Sender: TObject);
begin
  Close;
end;

procedure TfrmPipMain.actVensterToonExecute(Sender: TObject);
begin
  ntfTray.ShowMainForm;
  FormShow(Self);
end;

procedure TfrmPipMain.actKopierenExecute(Sender: TObject);
begin
  Clipboard.AsText :=
    'Limiet: ' + lstTable.Items.Item[0].SubItems[0] + #13#10#13#10 + 'Ontvangen: ' + lstTable.Items.Item[2].SubItems[0] + #13#10 + 'Verstuurd: ' + lstTable.Items.Item[3].SubItems[0] + #13#10 + 'Totaal: ' + lstTable.Items.Item[4].SubItems[0] + #13#10#13#10 + 'Over: ' + lstTable.Items.Item[6].SubItems[0] + #13#10 + 'Dagen over: ' + lstTable.Items.Item[7].SubItems[0] + #13#10 + 'Vandaag verbruikt/Over per dag: ' + lstTable.Items.Item[8].SubItems[0] + #13#10 + 'Balans: ' + lstTable.Items.Item[9].SubItems[0];
end;

procedure TfrmPipMain.WndProc(var Message: TMessage);
begin
  if (Message.Msg = WM_APP + 2) then
  begin
    case Message.LParam of
      32: Message.Result := Round(Dataverkeer.VrijVerkeer);
      33: Message.Result := Round(Dataverkeer.MaandData.Ontvangen);
      34: Message.Result := Round(Dataverkeer.MaandData.Verstuurd);
      35: Message.Result := Round(Dataverkeer.Vandaag.Down + Dataverkeer.Vandaag.Up);
      36: Message.Result := getPeriodLength();
      37: Message.Result := Ceil(getPeriodDone());
      502: actVensterToonExecute(Self);
    end;
  end
  else
    inherited;
end;

procedure TUpdate.Execute;
var
  Versie, URL, Respons: String;
  RegExpr: TRegExpr;
begin
  Respons := GetHTTP('http://pipview.xxp.nu/update.txt');

  RegExpr := TRegExpr.Create;
  RegExpr.Expression := '<version>(.*?)</version>(.*?)<url>(.*?)</url>';

  try
    if RegExpr.Exec(Respons) then

      if RegExpr.SubExprMatchCount = 3 then
      begin
        Versie := RegExpr.Match[1];
        URL    := RegExpr.Match[3];

        if Versie > GetAppVersionInfo then
          frmPipMain.URL := URL;
      end;
  finally
    RegExpr.Free;
  end;
end;

procedure TfrmPipMain.UpdateThreadDone(Sender: TObject);
begin
  if (Length(URL) > 0) then
  begin
    if MessageBox(Handle, PChar('Er is een nieuwe versie van PipView beschikbaar.' + #13#10#13#10 + 'Wilt u deze versie nu downloaden?'), 'Update', MB_YESNO or MB_ICONQUESTION) = idYes then
    begin
      ShellExecute(Handle, 'open', PChar(URL), NIL, NIL, SW_SHOWNORMAL);
    end;
  end
  else
  begin
    frmPipMain.ShowMessage('Er is momenteel geen update beschikbaar voor PipView', Handle);
  end;
end;

procedure TfrmPipMain.actUpdateExecute(Sender: TObject);
begin
  CheckForUpdates();
end;

procedure TfrmPipMain.CheckForUpdates();
var
  Update: TUpdate;
begin
  Update          := TUpdate.Create(TRUE);
  Update.Priority := tpLowest;

	Update.OnTerminate := UpdateThreadDone;

  Update.FreeOnTerminate := TRUE;
  Update.Resume;
end;

function TfrmPipMain.getPeriodLength(): Integer;
begin
  try
    Result := Round(Dataverkeer.Periode.Eind - Dataverkeer.Periode.Start + 1);
  except
    Result := 0;
  end;
end;

function TfrmPipMain.getPeriodDone(): Single;
begin
  try
    Result := Dataverkeer.Datum - Dataverkeer.Periode.Start;
  except
    Result := 0;
  end;
end;

function TfrmPipMain.getPeriodLeft(): Single;
begin
  try
    Result := Dataverkeer.Periode.Eind - Floor(Dataverkeer.Datum) + 1;
  except
    Result := 0;
  end;
end;

function TfrmPipMain.getPeriodPercentage(): Integer;
begin
  if (getPeriodLength <> 0) then
    Result := Floor(getPeriodDone / getPeriodLength * 100)
  else
    Result := 0;
end;

function TfrmPipMain.getPeriodPercentageFloat(): Single;
begin
  if (getPeriodLength <> 0) then
    Result := (getPeriodDone / getPeriodLength) * 100
  else
    Result := 0;
end;

function TfrmPipMain.getDataPercentage(): Integer;
begin
  if (Dataverkeer.Vrijverkeer <> 0) then
    Result := Floor(Dataverkeer.MaandData.Totaal / Dataverkeer.Vrijverkeer * 100)
  else
    Result := 0;
end;

function TfrmPipMain.getDataPercentageFloat(): Single;
begin
  if (Dataverkeer.Vrijverkeer <> 0) then
    Result := (Dataverkeer.MaandData.Totaal / Dataverkeer.Vrijverkeer) * 100
  else
    Result := 0;
end;

procedure TfrmPipMain.FillMenus;
var
  Item, SubItem: TMenuItem;
  Adapters: TStringList;
  iCount: Integer;
  AdapterAdded: Boolean;
begin
  AdapterAdded := FALSE;
  Adapters     := TStringList.Create;
  GetAdaptersList(Adapters);

  for iCount := 0 to Adapters.Count - 1 do
  begin
    if (Adapters.Names[iCount] <> '0') then
    begin
      AdapterAdded := TRUE;
      Item         := TMenuItem.Create(Self);
      Item.Tag     := 1;
      Item.Caption := ShorterString(Adapters.ValueFromIndex[iCount], 32);
      Item.Hint    := 'Informatie over deze adapter';

      SubItem         := TMenuItem.Create(Self);
      SubItem.Caption := 'IP-adres vrijgeven';
      SubItem.Tag     := StrToInt(Adapters.Names[iCount]);
      SubItem.OnClick := VerbreekClick;
      SubItem.Hint    := 'Verbinding van deze netwerkadapter verbreken';
      Item.Add(SubItem);

      SubItem         := TMenuItem.Create(Self);
      SubItem.Caption := 'IP-adres vernieuwen';
      SubItem.Tag     := StrToInt(Adapters.Names[iCount]);
      SubItem.OnClick := VernieuwClick;
      SubItem.Hint    := 'Verbinding van deze netwerkadapter herstellen';
      Item.Add(SubItem);

      Verbinding1.Add(Item);
    end;
  end;

  Adapters.Free;

  Verbinding1.Enabled := AdapterAdded;
  Verbindingverbreken1.Enabled := AdapterAdded;
end;

procedure TfrmPipMain.VernieuwClick(Sender: TObject);
var
  Index: Integer;
begin
  if Sender is TMenuItem then
  begin
    Index := TMenuItem(Sender).Tag;
    if Index <> -1 then
      DHCPPerform(FALSE, Index);
  end;
end;

procedure TfrmPipMain.VerbreekClick(Sender: TObject);
var
  Index: Integer;
begin
  if Sender is TMenuItem then
  begin
    Index := TMenuItem(Sender).Tag;
    if Index <> -1 then
      DHCPPerform(TRUE, Index);
  end;
end;

procedure TfrmPipMain.ntfTrayStartup(Sender: TObject; var ShowMainForm: Boolean);
var
  IconData: TIcon;
begin
  IconData     := TrayIcon(0, TRUE, clRed);
  ntfTray.Icon := IconData;
  ntfTray.IconVisible := TRUE;
  IconData.Free;

  ShowMainForm := FALSE;
end;

procedure TfrmPipMain.stbStatusHint(Sender: TObject);
begin
  stbStatus.SimpleText := ' ' + Application.Hint;
end;

procedure TfrmPipMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if FileExists(PChar(ExtractFilePath(Application.EXEName) + 'pipbrowser.html')) then
    DeleteFile(PChar(ExtractFilePath(Application.EXEName) + 'pipbrowser.html'));

  SaveSettings;

  Action := caFree;
end;

procedure TfrmPipMain.actEmailExecute(Sender: TObject);
begin
  ShellExecute(Handle, 'open', 'mailto:pipview@xxp.nu?subject=PipView',
    NIL, NIL, SW_SHOWNORMAL);
end;

procedure TfrmPipMain.actWebsiteExecute(Sender: TObject);
begin
  ShellExecute(Handle, 'open', 'http://pipview.xxp.nu/', NIL,
    NIL, SW_SHOWNORMAL);
end;

procedure TfrmPipMain.WMQueryEndSession(var Msg: TWMQueryEndSession);
begin
  inherited;

  SaveSettings;
end;

procedure TfrmPipMain.BalloonWrapper(blnTitle, blnTekst: String; blnType, blnDuration: Integer);
var
  osInfo: TOSVersionInfo;
  newIcon: TBalloonHintIcon;
  oldIcon: TBalloonType;
  iconPos: TPoint;
begin
  osInfo.dwOSVersionInfoSize := sizeof(TOsVersionInfo);
  GetVersionEx(osInfo);

  if (osInfo.dwMajorVersion > 4) or ((osInfo.dwMajorVersion = 4) and (osInfo.dwMinorVersion = 90)) then
  begin
    case blnType of
      0:
        newIcon := bitInfo;
      1:
        newIcon := bitWarning;
      else
        newIcon := bitInfo;
    end;
    ntfTray.ShowBalloonHint(blnTitle, blnTekst, newIcon, blnDuration);
    tmrBalloon.Enabled := TRUE;
  end
  else
  begin
    case blnType of
      0:
        oldIcon := blnInfo;
      1:
        oldIcon := blnWarning;
      else
        oldIcon := blnInfo;
    end;
    iconPos := getIconPos;
    trayBalloon.BalloonType := oldIcon;
    trayBalloon.PixelCoordinateX := iconPos.X;
    trayBalloon.PixelCoordinateY := iconPos.Y;
    trayBalloon.Title := blnTitle;
    trayBalloon.Text.Text := blnTekst;
    trayBalloon.Duration := blnDuration * 1000;
    trayBalloon.ShowPixelBalloon;
  end;
end;

function TfrmPipMain.getIconPos(): TPoint;
var
  notifyRect: TRect;
  wndNotify, wndShellTray: THandle;
  hdcTray: HDC;
  pixelColor: Cardinal;
  curX, curY, curSubX, curSubY: Integer;
  iconFound: Boolean;
  trayBitmap, iconBitmap: TBitmap;
begin
  trayBitmap := TBitmap.Create;
  iconBitmap := TBitmap.Create;

  wndShellTray := FindWindow('Shell_TrayWnd', NIL);
  wndNotify    := FindWindowEx(wndShellTray, 0, 'TrayNotifyWnd', NIL);
  GetWindowRect(wndNotify, notifyRect);
  hdcTray := GetDC(0);

  iconBitmap.Width  := 16;
  iconBitmap.Height := 16;
  iconBitmap.Canvas.Draw(0,0,ntfTray.Icon);

  trayBitmap.Width  := notifyRect.Right - notifyRect.Left;
  trayBitmap.Height := notifyRect.Bottom - notifyRect.Top;

  for curX := notifyRect.Left to notifyRect.Right do
  begin
    for curY := notifyRect.Top to notifyRect.Bottom do
    begin
      pixelColor := GetPixel(hdcTray, curX, curY);
      if pixelColor <> CLR_INVALID then
      begin
        trayBitmap.Canvas.Pixels[(curX - notifyRect.Left), (curY - notifyRect.Top)] := pixelColor;
      end;
    end;
  end;

  ReleaseDC(0,hdcTray);

  trayBitmap.PixelFormat := pf4bit;
  iconBitmap.PixelFormat := pf4bit;

  Result.X  := 0;
  Result.Y  := 0;
  iconFound := FALSE;

  for curX := 0 to (notifyRect.Right - notifyRect.Left - 1) do
  begin
    for curY := 0 to (notifyRect.Bottom - notifyRect.Top - 1) do
    begin
      if (trayBitmap.Canvas.Pixels[curX, curY] = iconBitmap.Canvas.Pixels[1,1]) then
      begin
        for curSubX := 1 to 14 do
        begin
          for curSubY := 1 to 14 do
          begin
            if (iconBitmap.Canvas.Pixels[curSubX, curSubY] = trayBitmap.Canvas.Pixels[curX + curSubX - 1,curY + curSubY - 1]) then
              iconFound := TRUE
            else
            begin
              iconFound := FALSE;
              Break;
            end;
          end;
          if iconFound = FALSE then
            Break;
        end;
        if iconFound then
        begin
          Result.X := curX;
          Result.Y := curY;
          Break;
        end;
      end;
      if iconFound then
        Break;
    end;
    if iconFound then
      Break;
  end;

  Result.X := Result.X + notifyRect.Left + 8;
  Result.Y := Result.Y + notifyRect.Top + 8;

  trayBitmap.Free;
  iconBitmap.Free;
end;

procedure TfrmPipMain.ntfTrayMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if ntfTray.CycleIcons then
  begin
    ntfTray.CycleIcons := FALSE;
    ntfTray.IconIndex := 0;
    iconImages.Free;
  end;
end;

function TfrmPipMain.getAccounts: TStringList;
var
  Settings: TRegistry;
  keyNames: TStringList;
  iKey: Integer;
begin
  Result := TStringList.Create;

  Settings         := TRegistry.Create;
  Settings.RootKey := HKEY_CURRENT_USER;
  if Settings.OpenKey('\Software\PipView\', TRUE) then
  begin
    keyNames := TStringList.Create;
    Settings.GetKeyNames(keyNames);
    Settings.CloseKey;

    for iKey := 0 to keyNames.Count - 1 do
    begin
      if Settings.OpenKey('\Software\PipView\' + keyNames.Strings[iKey] + '\', FALSE) then
      begin
        if Settings.ValueExists('naam') then
          Result.Add(Settings.ReadString('naam') + '=' + keyNames.Strings[iKey]);
      end;
    end;

    keyNames.Free;
  end;
  Settings.Free;
end;

procedure TfrmPipMain.fillAccountsMenu();
var
  newMenuItem: TMenuItem;
  iAccount, iMenuCount: Integer;
begin
  accountsList := getAccounts;
  iMenuCount := 0;

  Accounts.Clear;

  newMenuItem          := TMenuItem.Create(Accounts);
  newMenuItem.Caption  := 'Accounts bewerken...';
  newMenuItem.OnClick  := AccountsClick;
  newMenuItem.ShortCut := ShortCut(Word(IntToStr(iMenuCount)[1]), [ssCtrl]);
  newMenuItem.Tag      := -1;

  Accounts.Add(newMenuItem);

  newMenuItem := TMenuItem.Create(Accounts);
  newMenuItem.Caption := '-';

  Accounts.Add(newMenuItem);

  for iAccount := 0 to accountsList.Count - 1 do
  begin
    Inc(iMenuCount);
    newMenuItem           := TMenuItem.Create(Accounts);
    newMenuItem.RadioItem := TRUE;
    newMenuItem.Checked   := (activeAccount = accountsList.ValueFromIndex[iAccount]);
    newMenuItem.Caption   := accountsList.Names[iAccount];
    newMenuItem.ShortCut  := ShortCut(Word(IntToStr(iMenuCount)[1]), [ssCtrl]);
    newMenuItem.OnClick   := AccountsClick;
    newMenuItem.Tag       := iAccount;

    Accounts.Add(newMenuItem);
  end;
end;

procedure TfrmPipMain.WMFillMenu(var Msg: TMessage);
begin
  if Msg.LParam = 4 then
  begin
    fillAccountsMenu;
    Refresh;
  end;

  if Msg.LParam = 2 then
  begin
    fillAccountsMenu;
    loadSettings;
  end;
end;

procedure TfrmPipMain.AccountsClick(Sender: TObject);
var
  frmAccounts: TfrmAccounts;
begin
  if ((Sender as TMenuItem).Tag <> -1) then
  begin
    saveSettings;
    activeAccount := accountsList.ValueFromIndex[(Sender as TMenuItem).Tag];
    loadSettings;
    Caption := 'PipView ' + GetAppVersionInfo + ' (' + Opties.Naam + ')';
    PostMessage(Handle, WM_FILLMENU, 0, 4);
  end
  else
  begin
    frmAccounts := TfrmAccounts.Create(Self);
    frmAccounts.ShowModal;
    PostMessage(Handle, WM_FILLMENU, 0, 2);
  end;
end;

procedure TDataLimietThread.Execute;
var
  regE: TRegExpr;
  periodeNummer, periodeJaar: Integer;
  strPeriode1, strPeriode2: String;
begin
  Login(frmPipMain.Opties.Naam, frmPipMain.Opties.Wachtwoord);

  regE := TRegExpr.Create;
  //regE.ModifierS := True;

  periodeNummer := Dataverkeer.Periode.Nummer;
  periodeJaar := Dataverkeer.Periode.Jaar;

  periodeNummer := periodeNummer - 1;
  if periodeNummer = 0 then
  begin
    periodeNummer := 12;
    periodeJaar := periodeJaar - 1;
  end;

  strPeriode1 := GetHTTP('https://secure.zeelandnet.nl/pip/index.php?page=202&show=1&periode='+IntToStr(periodeNummer)+'-'+IntToStr(periodeJaar));

  periodeNummer := periodeNummer - 1;
  if periodeNummer = 0 then
  begin
    periodeNummer := 12;
    periodeJaar := periodeJaar - 1;
  end;

  strPeriode2 := GetHTTP('https://secure.zeelandnet.nl/pip/index.php?page=202&show=1&periode='+IntToStr(periodeNummer)+'-'+IntToStr(periodeJaar));

  regE.Expression := 'U heeft deze periode in totaal <b>(.*?)<\/b> verbruikt.';
  if regE.Exec(strPeriode1) then
  begin
    VorigeData.Data1 := FilterString(regE.Match[1]);
    regE.Expression := 'U heeft deze periode in totaal <b>(.*?)<\/b> verbruikt.';
    if regE.Exec(strPeriode2) then
    begin
      VorigeData.Data2 := FilterString(regE.Match[1]);
    end;
  end;

  Logoff;
end;

procedure TfrmPipMain.DataThreadDoneLimietSecond(Sender: TObject);
begin
  ThreadRuns    := FALSE;
  Screen.Cursor := crDefault;

  if (VorigeData.Data1 <= Dataverkeer.VrijVerkeer) and (VorigeData.Data2 <= Dataverkeer.VrijVerkeer) then
  begin
    if Opties.VerhoogLimiet then
    begin
      ShowMessage('Wanneer u een Plus-abonnement heeft, mag u uw limiet deze periode met 100%'#13#10'overschrijden omdat u de afgelopen twee perioden onder uw limiet bent gebleven.'#13#10#13#10'Uit de instellingen van PipView blijkt dat u uw limiet al handmatig heeft verdubbeld.'+#13#10#13#10+'Let op: als u twijfelt aan deze informatie, raadpleeg dan de website van ZeelandNet!');
    end
    else
    begin
      if (MessageBox(Handle, 'Wanneer u een Plus-abonnement heeft, mag u uw limiet deze periode met 100%'#13#10'overschrijden omdat u de afgelopen twee perioden onder uw limiet bent gebleven.'#13#10#13#10'Wilt u dat PipView deze limietverhoging nu automatisch voor u uitvoert?'+#13#10#13#10+'Let op: als u twijfelt aan deze informatie, raadpleeg dan de website van ZeelandNet!','PipView', MB_YESNO + MB_ICONWARNING + MB_DEFBUTTON2) = IDYES) then
      begin
        Opties.VerhoogLimiet := TRUE;
        Dataverkeer.VrijVerkeer := Dataverkeer.VrijVerkeer * 2;
        ToonWaarden;
        frmOpties.OldState := TRUE;
      end;
    end;
  end
  else
    ShowMessage('De afgelopen twee perioden bent u minstens ��n keer over uw huidige limiet gegaan.'#13#10'Opnieuw overschrijden van de limiet is dus gevaarlijk, tenzij u met ZeelandNet heeft'#13#10'afgesproken bij te betalen per overschreden MB.'+#13#10#13#10+'Let op: als u twijfelt aan deze informatie, raadpleeg dan de website van ZeelandNet!');
end;

procedure TfrmPipMain.DataThreadDoneLimiet(Sender: TObject);
var
  DataLimietThread: TDataLimietThread;
begin
  ThreadRuns    := FALSE;
  Screen.Cursor := crDefault;
  DataRetrieved := TRUE;

  if (Dataverkeer.Periode.Nummer > 0) and (Dataverkeer.Periode.Jaar > 0) then
  begin
    Screen.Cursor := crHourGlass;

    if ThreadRuns = FALSE then
    begin
      ThreadRuns := TRUE;
      DataLimietThread := TDataLimietThread.Create(TRUE);
      DataLimietThread.Priority := tpLowest;
      DataLimietThread.OnTerminate := DataThreadDoneLimietSecond;
      DataLimietThread.FreeOnTerminate := TRUE;
      DataLimietThread.Resume;
    end;
  end
  else
  begin
    ShowMessage('Door een fout tijdens het ophalen van de gegevens is het niet mogelijk informatie te geven over uw limiet in de vorige perioden.');
  end;
end;

procedure TfrmPipMain.actLimietExecute(Sender: TObject);
var
  DataThread: TDataThread;
begin
  Screen.Cursor := crHourGlass;

  if ThreadRuns = FALSE then
  begin
    ThreadRuns := TRUE;
    DataThread := TDataThread.Create(TRUE);
    DataThread.Priority := tpLowest;
    DataThread.OnTerminate := DataThreadDoneLimiet;
    DataThread.FreeOnTerminate := TRUE;
    DataThread.Resume;
  end;
end;

procedure TfrmPipMain.Verbindingverbreken1Click(Sender: TObject);
var
  intAdapterIndex: Integer;
begin
  intAdapterIndex := AdapterNameToIndex(Opties.AdapterNaam);
  if intAdapterIndex <> -1 then
  begin
    DHCPPerform(TRUE, intAdapterIndex);
    BalloonWrapper('Waarschuwing', 'Uw internetverbinding is door PipView verbroken! Kijk in het helpbestand als u niet weet hoe u deze weer kunt inschakelen.', 1,15);
  end;
end;

procedure TfrmPipMain.tmrBalloonTimer(Sender: TObject);
begin
  tmrBalloon.Enabled := FALSE;
  ntfTray.HideBalloonHint();
end;

procedure TfrmPipMain.ntfTrayBalloonHintClick(Sender: TObject);
begin
  if tmrBalloon.Enabled then
    tmrBalloon.Enabled := FALSE;
end;

procedure TfrmPipMain.lstTableSelectItem(Sender: TObject; Item: TListItem;  Selected: Boolean);
begin
  Item.Selected := FALSE;
end;

end.
