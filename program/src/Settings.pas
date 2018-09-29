unit Settings;

interface

uses Windows, Registry, SimpleCrypt;

type
	TSettings = class(TObject)
	private
		FNaam: String;
		FWachtwoord: String;
		FLeft: Integer;
		FTop: Integer;
                FVernieuwenBijOpstarten: Boolean;
                FAutomatischVernieuwen: Boolean;
                FVernieuwenInterval: Integer;
                FBlijfIngelogd: Boolean;
		FTrayText: Boolean;
		FBalloonLimiet: Boolean;
		FBalloonVandaagOntvangen: Boolean;
                FBalloonVandaagVerstuurd: Boolean;
                FBalloonVandaagTotaal: Boolean;
		FBalloonOntvangen: Boolean;
		FBalloonVerstuurd: Boolean;
		FBalloonTotaal: Boolean;
		FBalloonOver: Boolean;
		FBalloonPeriode: Boolean;
		FBalloonNieuwsserver: Boolean;
		FBalloonOverPerDag: Boolean;
	public
		constructor Create();
		procedure Save();
	published
		property Naam: String read FNaam write FNaam;
		property Wachtwoord: String read FWachtwoord write FWachtwoord;
		property Left: Integer read FLeft write FLeft;
		property Top: Integer read FTop write FTop;
                property VernieuwenBijOpstarten: Boolean read FVernieuwenBijOpstarten write FVernieuwenBijOpstarten;
                property AutomatischVernieuwen: Boolean read FAutomatischVernieuwen write FAutomatischVernieuwen;
                property VernieuwenInterval: Integer read FVernieuwenInterval write FVernieuwenInterval;
                property BlijfIngelogd: Boolean read FBlijfIngelogd write FBlijfIngelogd;
		property TrayText: Boolean read FTrayText write FTrayText;
		property BalloonLimiet: Boolean read FBalloonLimiet write FBalloonLimiet;
		property BalloonVandaagOntvangen: Boolean read FBalloonVandaagOntvangen write FBalloonVandaagOntvangen;
                property BalloonVandaagVerstuurd: Boolean read FBalloonVandaagVerstuurd write FBalloonVandaagVerstuurd;
                property BalloonVandaagTotaal: Boolean read FBalloonVandaagTotaal write FBalloonVandaagTotaal;
		property BalloonOntvangen: Boolean read FBalloonOntvangen write FBalloonOntvangen;
		property BalloonVerstuurd: Boolean read FBalloonVerstuurd write FBalloonVerstuurd;
		property BalloonTotaal: Boolean read FBalloonTotaal write FBalloonTotaal;
		property BalloonOver: Boolean read FBalloonOver write FBalloonOver;
		property BalloonPeriode: Boolean read FBalloonPeriode write FBalloonPeriode;
		property BalloonNieuwsserver: Boolean read FBalloonNieuwsserver write FBalloonNieuwsserver;
		property BalloonOverPerDag: Boolean read FBalloonOverPerDag write FBalloonOverPerDag;
	end;

implementation

constructor TSettings.Create();
var
	registry: TRegistry;
	simpleCrypt: TSimpleCrypt;
	regOpen: Boolean;
begin
	FNaam := 'naam';
	FWachtwoord := 'wachtwoord';

	FLeft := -1;
	FTop := -1;

        FVernieuwenBijOpstarten := True;
        FAutomatischVernieuwen := True;
        FVernieuwenInterval := 60;
	FBlijfIngelogd := False;
	FTrayText := False;

	FBalloonLimiet := True;

	FBalloonOntvangen := False;
	FBalloonVerstuurd := False;
	FBalloonTotaal := True;
	FBalloonOver := False;
	FBalloonOverPerDag := False;

	FBalloonVandaagOntvangen := False;
        FBalloonVandaagVerstuurd := False;
        FBalloonVandaagTotaal := True;

	FBalloonPeriode := True;
	FBalloonNieuwsserver := False;

	registry := TRegistry.Create(KEY_READ);

	registry.RootKey := HKEY_CURRENT_USER;
	regOpen := registry.OpenKeyReadOnly('\Software\PipView');

	if (regOpen = False) then
	begin
		registry.RootKey := HKEY_LOCAL_MACHINE;
		regOpen := registry.OpenKeyReadOnly('\Software\PipView');
	end;

	if (regOpen) then
	begin
		if registry.ValueExists('Naam') then
			FNaam := registry.ReadString('naam');

		if registry.ValueExists('Top') then
			FTop := registry.ReadInteger('top');

		if registry.ValueExists('Left') then
			FLeft := registry.ReadInteger('left');

		if registry.ValueExists('Wachtwoord') then
		begin
			simpleCrypt := TSimpleCrypt.Create();
			FWachtwoord := simpleCrypt.Decrypt(registry.ReadString('wachtwoord'));
			simpleCrypt.Free();
		end;

		if registry.ValueExists('VernieuwenBijOpstarten') then
			FVernieuwenBijOpstarten := registry.ReadBool('VernieuwenBijOpstarten');

		if registry.ValueExists('AutomatischVernieuwen') then
			FAutomatischVernieuwen := registry.ReadBool('AutomatischVernieuwen');

		if registry.ValueExists('VernieuwenInterval') then
			FVernieuwenInterval := registry.ReadInteger('VernieuwenInterval');

		if registry.ValueExists('BlijfIngelogd') then
			FBlijfIngelogd := registry.ReadBool('BlijfIngelogd');

		if registry.ValueExists('TrayText') then
			FTrayText := registry.ReadBool('TrayText');

		if registry.ValueExists('BalloonLimiet') then
			FBalloonLimiet := registry.ReadBool('BalloonLimiet');

		if registry.ValueExists('BalloonOntvangen') then
			FBalloonOntvangen := registry.ReadBool('BalloonOntvangen');

		if registry.ValueExists('BalloonVerstuurd') then
			FBalloonVerstuurd := registry.ReadBool('BalloonVerstuurd');

		if registry.ValueExists('BalloonTotaal') then
			FBalloonTotaal := registry.ReadBool('BalloonTotaal');

		if registry.ValueExists('BalloonOver') then
			FBalloonOver := registry.ReadBool('BalloonOver');

		if registry.ValueExists('BalloonOverPerDag') then
			FBalloonOverPerDag := registry.ReadBool('BalloonOverPerDag');

		if registry.ValueExists('BalloonVandaagOntvangen') then
			FBalloonVandaagOntvangen := registry.ReadBool('BalloonVandaagOntvangen');

		if registry.ValueExists('BalloonVandaagVerstuurd') then
			FBalloonVandaagVerstuurd := registry.ReadBool('BalloonVandaagVerstuurd');

		if registry.ValueExists('BalloonVandaagTotaal') then
			FBalloonVandaagTotaal := registry.ReadBool('BalloonVandaagTotaal');

		if registry.ValueExists('BalloonPeriode') then
			FBalloonPeriode := registry.ReadBool('BalloonPeriode');

		if registry.ValueExists('BalloonNieuwsserver') then
			FBalloonNieuwsserver := registry.ReadBool('BalloonNieuwsserver');

		registry.CloseKey();
	end;

	registry.Free();
end;

procedure TSettings.Save();
var
	registry: TRegistry;
	simpleCrypt: TSimpleCrypt;
begin
	registry := TRegistry.Create(KEY_WRITE);

	registry.RootKey := HKEY_CURRENT_USER;

	if registry.OpenKey('\Software\PipView', True) then
	begin
		registry.WriteString('Naam', FNaam);

		registry.WriteInteger('Left', FLeft);
		registry.WriteInteger('Top', FTop);

		simpleCrypt := TSimpleCrypt.Create();
		registry.WriteString('Wachtwoord', simpleCrypt.Encrypt(FWachtwoord));
		simpleCrypt.Free();

		registry.WriteBool('VernieuwenBijOpstarten', FVernieuwenBijOpstarten);
		registry.WriteBool('AutomatischVernieuwen', FAutomatischVernieuwen);
		registry.WriteInteger('VernieuwenInterval', FVernieuwenInterval);
		registry.WriteBool('BlijfIngelogd', FBlijfIngelogd);
		registry.WriteBool('TrayText', FTrayText);

		registry.WriteBool('BalloonLimiet', FBalloonLimiet);

		registry.WriteBool('BalloonOntvangen', FBalloonOntvangen);
		registry.WriteBool('BalloonVerstuurd', FBalloonVerstuurd);
		registry.WriteBool('BalloonTotaal', FBalloonTotaal);
		registry.WriteBool('BalloonOver', FBalloonOver);

                registry.WriteBool('BalloonOverPerDag', FBalloonOverPerDag);

		registry.WriteBool('BalloonVandaagOntvangen', FBalloonVandaagOntvangen);
                registry.WriteBool('BalloonVandaagVerstuurd', FBalloonVandaagVerstuurd);
                registry.WriteBool('BalloonVandaagTotaal', FBalloonVandaagTotaal);

		registry.WriteBool('BalloonPeriode', FBalloonPeriode);
		registry.WriteBool('BalloonNieuwsserver', FBalloonNieuwsserver);

		registry.CloseKey();
	end;

	registry.Free();
end;

end.
