unit Opties;

interface

uses Settings, Forms, EditEx, StdCtrls, ComCtrls, SysUtils, Controls, Classes;

type
	TfrmOpties = class(TForm)
		btnCancel: TButton;
		btnOk: TButton;
		trvPages: TTreeView;
		grpAlgemeen: TGroupBox;
		lblNaam: TLabel;
		ediNaam: TEdit;
		lblWachtwoord: TLabel;
		ediWachtwoord: TEditEx;
		chkVernieuwenBijOpstarten: TCheckBox;
		chkAutomatischVernieuwen: TCheckBox;
		ediVernieuwenInterval: TEdit;
		lblMinuten: TLabel;
		chkBlijfIngelogd: TCheckBox;
		chkTrayText: TCheckBox;
		grpBallon: TGroupBox;
		chkBalloonLimiet: TCheckBox;
   		chkBalloonVandaagTotaal: TCheckBox;
		chkBalloonOntvangen: TCheckBox;
		chkBalloonVerstuurd: TCheckBox;
		chkBalloonTotaal: TCheckBox;
		chkBalloonOver: TCheckBox;
		chkBalloonNieuwsServer: TCheckBox;
		chkBalloonPeriode: TCheckBox;
		lblPeriode: TLabel;
		lblPercentages: TLabel;
    		chkBalloonOverPerDag: TCheckBox;
    		chkBalloonVandaagVerstuurd: TCheckBox;
    		chkBalloonVandaagOntvangen: TCheckBox;
    		lblVerkeerVandaag: TLabel;
		procedure trvPagesChange(Sender: TObject; Node: TTreeNode);
		procedure FormCreate(Sender: TObject);
		procedure chkAutomatischVernieuwenClick(Sender: TObject);
		procedure btnOkClick(Sender: TObject);
	private
		FSettings: TSettings;
	public
		property Settings: TSettings read FSettings write FSettings;
		procedure UpdateControls();
	end;

var
	frmOpties: TfrmOpties;

implementation

{$R *.dfm}

procedure TfrmOpties.chkAutomatischVernieuwenClick(Sender: TObject);
begin
        ediVernieuwenInterval.Enabled := chkAutomatischVernieuwen.Checked;

end;

procedure TfrmOpties.FormCreate(Sender: TObject);
begin
        trvPages.Selected := trvPages.Items.Item[0];
end;

procedure TfrmOpties.trvPagesChange(Sender: TObject; Node: TTreeNode);
begin
        case trvPages.Selected.Index of
		0: grpAlgemeen.BringToFront();
		1: grpBallon.BringToFront();
        end
end;

procedure TfrmOpties.UpdateControls();
begin
	ediNaam.Text := Settings.Naam;
	ediWachtwoord.Text := Settings.Wachtwoord;

        chkVernieuwenBijOpstarten.Checked := Settings.VernieuwenBijOpstarten;
        chkAutomatischVernieuwen.Checked := Settings.AutomatischVernieuwen;
        chkBlijfIngelogd.Checked := Settings.BlijfIngelogd;
	ediVernieuwenInterval.Text := IntToStr(Settings.VernieuwenInterval);
        chkTrayText.Checked := Settings.TrayText;

	chkBalloonLimiet.Checked := Settings.BalloonLimiet;

	chkBalloonOntvangen.Checked := Settings.BalloonOntvangen;
	chkBalloonVerstuurd.Checked := Settings.BalloonVerstuurd;
	chkBalloonTotaal.Checked := Settings.BalloonTotaal;
	chkBalloonOver.Checked := Settings.BalloonOver;

        chkBalloonOverPerDag.Checked := Settings.BalloonOverPerDag;

        chkBalloonVandaagOntvangen.Checked := Settings.BalloonVandaagOntvangen;
        chkBalloonVandaagVerstuurd.Checked := Settings.BalloonVandaagVerstuurd;
        chkBalloonVandaagTotaal.Checked := Settings.BalloonVandaagTotaal;

	chkBalloonPeriode.Checked := Settings.BalloonPeriode;
	chkBalloonNieuwsserver.Checked := Settings.BalloonNieuwsserver;

        ediVernieuwenInterval.Enabled := Settings.AutomatischVernieuwen;
end;

procedure TfrmOpties.btnOkClick(Sender: TObject);
var
        editValue: Integer;
begin
	Settings.Naam := ediNaam.Text;
	Settings.Wachtwoord := ediWachtwoord.Text;

        Settings.VernieuwenBijOpstarten := chkVernieuwenBijOpstarten.Checked;
        Settings.AutomatischVernieuwen := chkAutomatischVernieuwen.Checked;
        Settings.BlijfIngelogd := chkBlijfIngelogd.Checked;
        Settings.TrayText := chkTrayText.Checked;

	Settings.BalloonLimiet := chkBalloonLimiet.Checked;

	Settings.BalloonOntvangen := chkBalloonOntvangen.Checked;
	Settings.BalloonVerstuurd := chkBalloonVerstuurd.Checked;
	Settings.BalloonTotaal := chkBalloonTotaal.Checked;
	Settings.BalloonOver := chkBalloonOver.Checked;

        Settings.BalloonOverPerDag := chkBalloonOverPerDag.Checked;

        Settings.BalloonVandaagOntvangen := chkBalloonVandaagOntvangen.Checked;
        Settings.BalloonVandaagVerstuurd := chkBalloonVandaagVerstuurd.Checked;
	Settings.BalloonVandaagTotaal := chkBalloonVandaagTotaal.Checked;

	Settings.BalloonPeriode := chkBalloonPeriode.Checked;
	Settings.BalloonNieuwsserver := chkBalloonNieuwsserver.Checked;

	editValue := StrToIntDef(ediVernieuwenInterval.Text, Settings.VernieuwenInterval);

	if ((editValue >= 10) and (editValue <= 360)) then
        	Settings.VernieuwenInterval := editValue;
end;

end.
