unit Main;

interface

uses
	Windows, SysUtils, HttpClient, Settings, Dataverkeer, Version,
	DataPresentation, PipDataThread, ExtCtrls, Classes,
	ActnList, Menus, Controls, ComCtrls, Graphics, StdCtrls,
	Forms, Messages, ShellApi, Math, Opties, CoolTrayIcon;

type
	TfrmPipMain = class(TForm)
		lblDag: TLabel;
		lblVerkeer: TLabel;
		lblDagWaarde: TLabel;
		lblVerkeerWaarde: TLabel;
		pgbPeriode: TProgressBar;
		pgbVerkeer: TProgressBar;
		mnuMain: TMainMenu;
		mnuPipView: TMenuItem;
		mnuPipViewVernieuwen: TMenuItem;
		mnuPipViewBallonTonen: TMenuItem;
		N1: TMenuItem;
		mnuPipViewOpties: TMenuItem;
		mnuPipViewOpenPipInBrowser: TMenuItem;
		N2: TMenuItem;
		mnuPipViewAfsluiten: TMenuItem;
		mnuHelp: TMenuItem;
		mnuHelpHelp: TMenuItem;
		N4: TMenuItem;
		mnuHelpWebsite: TMenuItem;
		mnuHelpEmail: TMenuItem;
		mnuPopup: TPopupMenu;
		mnuVensterTonen: TMenuItem;
		Opties: TMenuItem;
		OpenPiPinbrowser2: TMenuItem;
		MenuItem6: TMenuItem;
		mnuGegevenstonen: TMenuItem;
		mnuGegevensvernieuwen: TMenuItem;
		MenuItem7: TMenuItem;
		Help3: TMenuItem;
		N3: TMenuItem;
		mnuAfsluiten: TMenuItem;
		aclActions: TActionList;
		actVernieuwen: TAction;
		actAfsluiten: TAction;
		actVisitWebsite: TAction;
		actEmail: TAction;
		actOpenPipInBrowser: TAction;
		actBallonTonen: TAction;
		actOpties: TAction;
		actHelp: TAction;
		actVensterTonen: TAction;
		bvlRandje: TBevel;
		tmrAutomatischVernieuwen: TTimer;
		imgLimiet: TImage;
		lblLimiet: TLabel;
		lblLimietWaarde: TLabel;
		imgDown: TImage;
		lblOntvangen: TLabel;
		lblDownWaarde: TLabel;
		imgUp: TImage;
		imgTotaal: TImage;
		imgOver: TImage;
		imgOverDag: TImage;
		imgNieuws: TImage;
		lblVerstuurd: TLabel;
		lblTotaal: TLabel;
		lblOver: TLabel;
		lblVandaag: TLabel;
		lblNieuwsserver: TLabel;
		lblUpWaarde: TLabel;
		lblTotaalWaarde: TLabel;
		lblOverWaarde: TLabel;
		lblVandaagWaarde: TLabel;
		lblNieuwsWaarde: TLabel;
		lblNieuws: TLabel;
		lblNieuwsserverWaarde: TLabel;
		pgbNieuwsServer: TProgressBar;
    ctiTray: TCoolTrayIcon;
		procedure FormShow(Sender: TObject);
		procedure actOptiesExecute(Sender: TObject);
		procedure onPipDataThreadTerminate(Sender: TObject);
		procedure onPipDataThreadOpenPipTerminate(Sender: TObject);
		procedure onFormCreate(Sender: TObject);
		procedure onShowMainForm(Sender: TObject);
		procedure onAfsluiten(Sender: TObject);
		procedure onVernieuwen(Sender: TObject);
		procedure onHelpWebsite(Sender: TObject);
		procedure onHelpEmail(Sender: TObject);
		procedure onOpenPipInBrowser(Sender: TObject);
		procedure onBallonTonen(Sender: TObject);
		procedure onHelp(Sender: TObject);
		procedure onFormDestroy(Sender: TObject);
    procedure ctiTrayStartup(Sender: TObject;
      var ShowMainForm: Boolean);
	protected
		procedure WndProc(var Message: TMessage); override;
	private
		dataVerkeer: TDataVerkeer;
		presentation: TDataPresentation;
		settings: TSettings;

                procedure ApplySettings();
	end;

var
	frmPipMain: TfrmPipMain;

implementation

{$R *.dfm}

procedure TfrmPipMain.onPipDataThreadOpenPipTerminate(Sender: TObject);
begin
	Screen.Cursor := crDefault;

	ShellExecute(Handle, 'open', 'iexplore.exe', 'https://secure.zeelandnet.nl/login/', nil, SW_SHOWNORMAL);
end;

procedure TfrmPipMain.onPipDataThreadTerminate(Sender: TObject);
var
	TrayIcon: TIcon;
  BallonTekst: String;
begin
	Screen.Cursor := crDefault;

	if DataVerkeer.Status = Success then
	begin
		// plaats de statistieken in de labels
                lblLimietWaarde.Caption := presentation.getTrafficString(dataVerkeer.Limiet);
                lblDownWaarde.Caption := presentation.getTrafficString(dataVerkeer.PeriodeDown);
                lblUpWaarde.Caption := presentation.getTrafficString(dataVerkeer.PeriodeUp);
                lblTotaalWaarde.Caption := presentation.getTrafficString(dataVerkeer.PeriodeTotaal);
                lblOverWaarde.Caption := Format('%s / %.1f dagen', [presentation.getTrafficString(dataVerkeer.VerkeerOver), dataVerkeer.PeriodeOver]);
                lblVandaagWaarde.Caption := Format('%s', [presentation.getTrafficString(dataVerkeer.VandaagTotaal)]);
                lblNieuwsWaarde.Caption := presentation.getTrafficString(dataVerkeer.NieuwsServer);

		// zorg dat de twee progressbars op de goede positie staan
		pgbPeriode.Position := Floor(dataVerkeer.PeriodePercentage);
		pgbVerkeer.Position := Floor(dataVerkeer.VerkeerPercentage);
                pgbNieuwsServer.Position := Floor(dataVerkeer.NieuwsPercentage);

		// plaats gegevens over de huidige periode als tekst op een label
		lblDag.Caption := Format('Dag v/d periode (%s t/m %s):', [presentation.getSimpleDateString(dataVerkeer.PeriodeStart), presentation.getSimpleDateString(dataVerkeer.PeriodeEind)]);

		// zet de percentages als tekst in twee aparte labels
		lblDagWaarde.Caption := Format('%.1f %%', [dataVerkeer.PeriodePercentage]);
		lblVerkeerWaarde.Caption := Format('%.1f %%', [dataVerkeer.VerkeerPercentage]);
                lblNieuwsServerWaarde.Caption := Format('%.1f %%', [dataVerkeer.NieuwsPercentage]);

		// laat ballon zien
		onBallonTonen(Self);

                TrayIcon := presentation.getTrayIcon(dataVerkeer.VerkeerPercentage, dataVerkeer.PeriodePercentage - dataVerkeer.VerkeerPercentage, Settings.TrayText);
                ctiTray.Icon := TrayIcon;
                TrayIcon.Free();
	end
	else
	begin
		case dataVerkeer.Status of
			CouldNotConnect:
				BallonTekst := 'Er kan geen verbinding met de website van ZeelandNet worden gemaakt.' + #13#10#13#10 + 'Controleer uw verbinding en uw firewall-instellingen.';

			WrongLogin:
				BallonTekst := 'Het inloggen is niet gelukt omdat uw inlognaam en wachtwoord niet correct zijn ingevuld.' + #13#10#13#10 + 'Controleer deze gegevens in het Opties-scherm van PipView.';

			ParseError:
				BallonTekst := 'Het is niet gelukt de gegevens over uw dataverkeer op te vragen bij ZeelandNet.' + #13#10#13#10 + 'Stuur een e-mailbericht naar de maker van PipView, zodat dit kan worden verholpen.';

			WrongDateTime:
				BallonTekst := 'De datum van uw computer staat niet goed ingesteld.' + #13#10#13#10 + 'Controleer jaar, maand en dag en laat PipView hierna de gegevens opnieuw ophalen.';
		end;

                ctiTray.ShowBalloonHint('Foutmelding PipView', BallonTekst, bitError, 15);
	end;
end;

procedure TfrmPipMain.onFormCreate(Sender: TObject);
var
	TrayIcon: TIcon;
        i, OldTop, PreviousHeight: Integer;
        shpNew: TShape;
	LabelHoogtes: array[0..6] of Integer;
begin
	PreviousHeight := 0;
	OldTop := 0;

	LabelHoogtes[0] := lblLimiet.Height;
	LabelHoogtes[1] := lblOntvangen.Height;
	LabelHoogtes[2] := lblVerstuurd.Height;
	LabelHoogtes[3] := lblTotaal.Height;
	LabelHoogtes[4] := lblOver.Height;
	LabelHoogtes[5] := lblVandaag.Height;
	LabelHoogtes[6] := lblNieuwsserver.Height;

        for i := 0 to 6 do
        begin
        	shpNew := TShape.Create(Self);
                shpNew.Top := OldTop + PreviousHeight;
                shpNew.Height := LabelHoogtes[i];
                shpNew.Left := 0;
                shpNew.Width := Self.ClientWidth;

		OldTop := shpNew.Top;
		PreviousHeight := shpNew.Height;

                if Odd(i) then
                begin
                	shpNew.Brush.Color := $00EEEEEE;
                	shpNew.Pen.Color := $00EEEEEE;
                end
                else
                begin
                	shpNew.Brush.Color := $00FFFFFF;
                	shpNew.Pen.Color := $00FFFFFF;
                end;

                Self.InsertControl(shpNew);
                shpNew.SendToBack();
        end;

	Settings := TSettings.Create();

        if (Settings.Left = -1) or (Settings.Top = -1) then
        	Self.Position := poScreenCenter
        else
        begin
        	Left := Settings.Left;
                Top := Settings.Top;
        end;

	dataVerkeer := TDataVerkeer.Create();

	Caption := 'PipView ' + getVersionNumber();
	presentation := TDataPresentation.Create();
	ctiTray.Hint := Caption;

	TrayIcon := presentation.getTrayIcon(100, 0, False);
	ctiTray.Icon := TrayIcon;
	TrayIcon.Free();

        if Settings.VernieuwenBijOpstarten then
		onVernieuwen(Self);

	ApplySettings();
end;

procedure TfrmPipMain.onFormDestroy(Sender: TObject);
begin
	Settings.Left := Left;
	Settings.Top := Top;

	// verwijder alle hulpklassen uit het geheugen
	Settings.Free();
	Presentation.Free();
	DataVerkeer.Free();
end;

procedure TfrmPipMain.ApplySettings();
var
	TrayIcon: TIcon;
begin
        tmrAutomatischVernieuwen.Interval := 60000 * Settings.VernieuwenInterval;
        tmrAutomatischVernieuwen.Enabled := Settings.AutomatischVernieuwen;

	TrayIcon := presentation.getTrayIcon(dataVerkeer.VerkeerPercentage, dataVerkeer.PeriodePercentage - dataVerkeer.VerkeerPercentage, Settings.TrayText);
	ctiTray.Icon := TrayIcon;
	TrayIcon.Free();
end;

procedure TfrmPipMain.FormShow(Sender: TObject);
var
	hCurWnd: THandle;
begin
	hCurWnd := GetForegroundWindow();

	AttachThreadInput(GetWindowThreadProcessId(hCurWnd, NIL), GetCurrentThreadId, TRUE);

	SetForegroundWindow(Application.Handle);

	AttachThreadInput(GetWindowThreadProcessId(hCurWnd, NIL), GetCurrentThreadId, FALSE);
end;

procedure TfrmPipMain.onShowMainForm(Sender: TObject);
begin
	if IsIconic(Application.Handle) then
        	ShowWindow(Application.Handle, SW_RESTORE);

	Self.Show();
end;

procedure TfrmPipMain.WndProc(var Message: TMessage);
begin
	if (Message.Msg = 32797) and (Message.WParam = 11) and (Message.LParam = 1984) then // 32797 = WM_APP + 29
		onShowMainForm(Self)
	else if (Message.Msg = WM_SYSCOMMAND) and (Message.WParam = SC_CLOSE) then
		Self.Hide()
	else
		inherited;
end;

procedure TfrmPipMain.onAfsluiten(Sender: TObject);
begin
	Application.Terminate();
end;

procedure TfrmPipMain.onVernieuwen(Sender: TObject);
var
	dataThread: TPipDataThread;
begin
	if (Settings.Naam <> 'naam') and (Settings.Wachtwoord <> 'wachtwoord') then
	begin
		dataThread := TPipDataThread.Create(True);

		dataThread.Priority := tpLowest;
		dataThread.OnTerminate := onPipDataThreadTerminate;
		dataThread.FreeOnTerminate := True;
		dataThread.Naam := Settings.Naam;
		dataThread.Wachtwoord := Settings.Wachtwoord;
		dataThread.Persistent := Settings.BlijfIngelogd;
		dataThread.DataVerkeer := DataVerkeer;
		dataThread.GetStats := True;

		Screen.Cursor := crHourGlass;

		dataThread.Resume();
	end
	else
        begin
                ctiTray.ShowBalloonHint('Waarschuwing PipView', 'U heeft uw naam en wachtwoord nog niet ingevuld. U kunt dit nu doen via het Opties-scherm van PipView.', bitWarning, 15);
        end;
end;

procedure TfrmPipMain.onHelpWebsite(Sender: TObject);
begin
	ShellExecute(Handle, 'open', 'http://pipview.xxp.nu/', nil, nil, SW_SHOWNORMAL);
end;

procedure TfrmPipMain.onHelpEmail(Sender: TObject);
begin
	ShellExecute(Handle, 'open', 'http://pipview.xxp.nu/contact', nil, nil, SW_SHOWNORMAL);
end;

procedure TfrmPipMain.onOpenPipInBrowser(Sender: TObject);
var
	dataThread: TPipDataThread;
begin
	if (Settings.BlijfIngelogd) and (Settings.Naam <> 'naam') and (Settings.Wachtwoord <> 'wachtwoord') then
	begin
		dataThread := TPipDataThread.Create(True);

		dataThread.Priority := tpLowest;
		dataThread.OnTerminate := onPipDataThreadOpenPipTerminate;
		dataThread.FreeOnTerminate := True;
		dataThread.Naam := Settings.Naam;
		dataThread.Wachtwoord := Settings.Wachtwoord;
		dataThread.Persistent := Settings.BlijfIngelogd;
		dataThread.DataVerkeer := DataVerkeer;
		dataThread.GetStats := False;

		Screen.Cursor := crHourGlass;

		dataThread.Resume();
	end
	else
		ShellExecute(Handle, 'open', 'iexplore.exe', 'https://secure.zeelandnet.nl/login/', nil, SW_SHOWNORMAL);
end;

procedure TfrmPipMain.onBallonTonen(Sender: TObject);
var
	ballonTekst: String;
	oldTextLength: Integer;
begin
	// laat een ballon zien met de statistieken
	if dataVerkeer.VerkeerPercentage < 90 then
	begin
		ballonTekst := '';
		oldTextLength := 0;

		if Settings.BalloonLimiet then
			ballonTekst := ballonTekst + Format('Limiet: %s'#13#10, [presentation.getTrafficString(dataVerkeer.Limiet)]);

		if (Length(ballonTekst) > oldTextLength) then
		begin
			ballonTekst := ballonTekst + #13#10;
			oldTextLength := Length(ballonTekst);
		end;

		if Settings.BalloonOntvangen then
			ballonTekst := ballonTekst + Format('Ontvangen: %s'#13#10, [presentation.getTrafficString(dataVerkeer.PeriodeDown)]);

		if Settings.BalloonVerstuurd then
			ballonTekst := ballonTekst + Format('Verstuurd: %s'#13#10, [presentation.getTrafficString(dataVerkeer.PeriodeUp)]);

		if Settings.BalloonTotaal then
			ballonTekst := ballonTekst + Format('Totaal: %s (%.1f %%)'#13#10, [presentation.getTrafficString(dataVerkeer.PeriodeTotaal), dataVerkeer.VerkeerPercentage]);

		if Settings.BalloonOver then
			ballonTekst := ballonTekst + Format('Over: %s'#13#10, [presentation.getTrafficString(dataVerkeer.VerkeerOver)]);

		if (Length(ballonTekst) > oldTextLength) then
		begin
			ballonTekst := ballonTekst + #13#10;
                        oldTextLength := Length(ballonTekst);
		end;

		if Settings.BalloonOverPerDag then
			ballonTekst := ballonTekst + Format('Over per dag: %s'#13#10, [presentation.getTrafficString(dataVerkeer.OverPerDag)]);

		if (Length(ballonTekst) > oldTextLength) then
		begin
			ballonTekst := ballonTekst + #13#10;
                        oldTextLength := Length(ballonTekst);
		end;

                if Settings.BalloonVandaagOntvangen then
			ballonTekst := ballonTekst + Format('Vandaag ontvangen: %s'#13#10, [presentation.getTrafficString(dataVerkeer.VandaagDown)]);

		if Settings.BalloonVandaagVerstuurd then
			ballonTekst := ballonTekst + Format('Vandaag verstuurd: %s'#13#10, [presentation.getTrafficString(dataVerkeer.VandaagUp)]);

		if Settings.BalloonVandaagTotaal then
			ballonTekst := ballonTekst + Format('Vandaag totaal: %s'#13#10, [presentation.getTrafficString(dataVerkeer.VandaagTotaal)]);

		if (Length(ballonTekst) > oldTextLength) then
		begin
			ballonTekst := ballonTekst + #13#10;
                        //oldTextLength := Length(ballonTekst);
		end;

		if Settings.BalloonNieuwsserver then
			ballonTekst := ballonTekst + Format('Nieuwsserver: %s (%.1f %%)'#13#10, [presentation.getTrafficString(dataVerkeer.NieuwsServer), dataVerkeer.NieuwsPercentage]);

		if Settings.BalloonPeriode then
			ballonTekst := ballonTekst + Format('Periode: %.1f %%'#13#10, [dataVerkeer.PeriodePercentage]);

		ballonTekst := Trim(ballonTekst);

		if Length(ballonTekst) > 0 then
                begin
                        ctiTray.ShowBalloonHint('Dataverkeer', ballonTekst, bitInfo, 15);
                end;
	end
	else if dataVerkeer.PeriodeTotaal < dataVerkeer.Limiet then
        begin
                ctiTray.ShowBalloonHint('Waarschuwing dataverkeer', 'Let op! U nadert uw datalimiet.', bitWarning, 15);
        end
	else
	begin
                ctiTray.ShowBalloonHint('Overschrijding dataverkeer', 'U heeft uw limiet overschreden!' + #13#10#13#10 + 'Afhankelijk van uw type abonnement kan dit geld kosten! Controleer dit zelf op uw Pip.', bitError, 15);
	end;
end;

procedure TfrmPipMain.onHelp(Sender: TObject);
begin
	ShellExecute(Handle, 'open', 'http://pipview.xxp.nu/#uitleg', nil, nil, SW_SHOWNORMAL);
end;

procedure TfrmPipMain.actOptiesExecute(Sender: TObject);
var
	frmOpties: TfrmOpties;
begin
	frmOpties := TfrmOpties.Create(Self);
	frmOpties.Settings := Settings;
	frmOpties.UpdateControls();
	frmOpties.ShowModal();
	frmOpties.Free();

        Settings.Save();

	// hide balloon
	ctiTray.HideBalloonHint();

	ApplySettings();
end;

procedure TfrmPipMain.ctiTrayStartup(Sender: TObject;
  var ShowMainForm: Boolean);
begin
  ShowMainForm := False;
end;

end.
