unit PipDataThread;

interface

uses Classes, Dataverkeer, WinInet, RegExpr, HttpClient, SysUtils, Version, Math;

type
	TPipDataThread = class(TThread)
	private
		FNaam: String;
		FWachtwoord: String;
		FDataVerkeer: TDataVerkeer;
		FPersistent: Boolean;
		FGetStats: Boolean;

		function parseDateString(Day, Month, Year: String): TDateTime;
		function parseTrafficString(TrafficString: String): Double;
		function loginWithCookies(): TPipStatus;
		procedure parseTrafficPage(var DataVerkeer: TDataVerkeer);
	public
		property Naam: String write FNaam;
		property Wachtwoord: String write FWachtwoord;
		property DataVerkeer: TDataVerkeer read FDataVerkeer write FDataVerkeer;
		property Persistent: Boolean read FPersistent write FPersistent;
		property GetStats: Boolean read FGetStats write FGetStats;
	protected
		procedure Execute; override;
	end;

implementation

procedure TPipDataThread.Execute();
var
	httpClient: THttpClient;
begin
	dataVerkeer.Status := loginWithCookies();

	if FGetStats and (dataVerkeer.Status = Success) then
	begin
        	parseTrafficPage(FDataVerkeer);

		if (not FPersistent) then
		begin
			httpClient := THTTPClient.Create();
			httpClient.HEAD('https://secure.zeelandnet.nl/logout/');
			httpClient.Free();
		end;
	end;
end;

function TPipDataThread.loginWithCookies(): TPipStatus;
var
	hSession, hConnection, hRequest: HINTERNET;
	PostData: String;
	RawHeader: TStringStream;
	Buffer: array[0..1024] of Byte;
	Context, Reserved, BufSize: Cardinal;
	Cookie: TRegExpr;
	httpsend: Boolean;
begin
	Context := 1;
	PostData := '';
	Result := CouldNotConnect;

	hSession := InternetOpen(PAnsiChar(getUserAgent()), INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);

	if hSession <> nil then
	begin
		hConnection := InternetConnect(hSession, 'secure.zeelandnet.nl', INTERNET_DEFAULT_HTTPS_PORT, nil, nil, INTERNET_SERVICE_HTTP, 0, Context);

		if hConnection <> nil then
		begin
			hRequest := HttpOpenRequest(hConnection, 'POST', '/login/index.php', nil, nil, nil, INTERNET_FLAG_PRAGMA_NOCACHE or INTERNET_FLAG_RELOAD or INTERNET_FLAG_NO_AUTO_REDIRECT or INTERNET_FLAG_SECURE, Context);

			if hRequest <> nil then
			begin
				Postdata := 'login_name=%s&login_pass=%s&login_type=abonnee&action=login';
				Postdata := Format(Postdata, [FNaam, FWachtwoord]);

				if HttpAddRequestHeaders(hRequest, 'Content-type: application/x-www-form-urlencoded', 47, HTTP_ADDREQ_FLAG_ADD) then
				begin
					repeat
						httpsend := HttpSendRequest(hRequest, nil, 0, PAnsiChar(PostData), Length(PostData));

						Sleep(1000);
					until httpsend;

					BufSize := sizeof(Buffer);
					Reserved := 0;
					if HttpQueryInfo(hRequest, HTTP_QUERY_RAW_HEADERS_CRLF, @Buffer, BufSize, Reserved) then
					begin
						RawHeader := TStringStream.Create('');
						RawHeader.Write(Buffer, BufSize);

						if (Pos('HTTP/1.1 302 Found', RawHeader.DataString) > 0) and (Pos('location: /login/index.php', RawHeader.DataString) > 0) then
						begin
							Cookie := TRegExpr.Create;

							Cookie.Expression := 'Set-Cookie: (.*?)\r\n';
							Cookie.InputString := RawHeader.DataString;

							if Cookie.Exec then
							begin
								repeat
									if FPersistent then
										InternetSetCookie('https://secure.zeelandnet.nl/login/index.php', nil, PAnsiChar(Format('%s; expires = Wed, 29-11-2084 12:00:00 GMT', [Cookie.Match[1]])))
									else
										InternetSetCookie('https://secure.zeelandnet.nl/login/index.php', nil, PAnsiChar(Cookie.Match[1]));
								until not Cookie.ExecNext
							end;

							Cookie.Free;

							Result := Success;
						end
						else if (Pos('HTTP/1.1 200 OK', RawHeader.DataString) > 0) then
							Result := WrongLogin
						else
							Result := CouldNotConnect;

						RawHeader.Free;
					end;
				end;
				InternetCloseHandle(hRequest);
			end;
			InternetCloseHandle(hConnection);
		end;
		InternetCloseHandle(hSession);
	end;
end;

procedure TPipDataThread.parseTrafficPage(var DataVerkeer: TDataVerkeer);
var
	RegExpr: TRegExpr;
	HttpClient: THttpClient;
	trafficPage: String;
	aboPage: String;
begin
	DataVerkeer.Status := Success;

	HttpClient := THttpClient.Create();

	if (HttpClient.GET('https://secure.zeelandnet.nl/pip/index.php?page=2') = False) then
	begin
		DataVerkeer.Status := CouldNotConnect;

		HttpClient.Free();
		Exit;
	end;

        aboPage := HttpClient.getStringData();

	RegExpr := TRegExpr.Create();

	// bepalen van de datalimiet per periode
	RegExpr.Expression := '([\d\.]+ Mb) per periode';

	if RegExpr.Exec(aboPage) then
	begin
		DataVerkeer.Limiet := parseTrafficString(RegExpr.Match[1]);
	end
	else
	begin
		DataVerkeer.Status := ParseError;

		HttpClient.Free();
		RegExpr.Free();
		Exit;
	end;

	if (HttpClient.GET('https://secure.zeelandnet.nl/pip/index.php?page=202') = False) then
	begin
		DataVerkeer.Status := CouldNotConnect;

		HttpClient.Free();
		RegExpr.Free();
		Exit;
	end;

        trafficPage := HttpClient.getStringData();
	HttpClient.Free();

	// bepalen van start- en einddatum huidige periode
	RegExpr.Expression := '(\d{1,2}) (\w*) (\d{4}) t\/m (\d{1,2}) (\w*) (\d{4})';

	if RegExpr.Exec(trafficPage) then
	begin
		DataVerkeer.PeriodeVandaag := Now();

		DataVerkeer.PeriodeStart := parseDateString(RegExpr.Match[1], RegExpr.Match[2], RegExpr.Match[3]);
		DataVerkeer.PeriodeEind := parseDateString(RegExpr.Match[4], RegExpr.Match[5], RegExpr.Match[6]) + (86399 / 86400);

		if (DataVerkeer.PeriodeVandaag < DataVerkeer.PeriodeStart) or (DataVerkeer.PeriodeVandaag > DataVerkeer.PeriodeEind) then
		begin
			DataVerkeer.Status := WrongDateTime;

			RegExpr.Free();
			Exit;
		end;
	end
	else
	begin
		DataVerkeer.Status := ParseError;
		Exit;
	end;

	// vandaag gedownload verkeer
	RegExpr.Expression := 'in<\/td>[^\d]*([\d,]* [\w]*)<\/td>[^\d]*([\d,]* [\w]*)';
	if RegExpr.Exec(trafficPage) then
	begin
		DataVerkeer.VandaagDown := parseTrafficString(RegExpr.Match[1]) + parseTrafficString(RegExpr.Match[2]);
	end
	else
	begin
		DataVerkeer.Status := ParseError;

		RegExpr.Free();
		Exit;
	end;

	// vandaag geupload verkeer
	RegExpr.Expression := 'uit<\/td>[^\d]*([\d,]* [\w]*)<\/td>[^\d]*([\d,]* [\w]*)';
	if RegExpr.Exec(trafficPage) then
	begin
		DataVerkeer.VandaagUp := parseTrafficString(RegExpr.Match[1]) + parseTrafficString(RegExpr.Match[2]);
	end
	else
	begin
		DataVerkeer.Status := ParseError;

		RegExpr.Free();
		Exit;
	end;

	// gedownload verkeer
	RegExpr.Expression := '<td align="center">(<B>|)([\d,]* [\w]*)(<\/B>|)</td>\r\n\t<\/tr>';
	if RegExpr.Exec(trafficPage) then
	begin
		DataVerkeer.PeriodeDown := parseTrafficString(RegExpr.Match[2]);
	end
	else
	begin
		DataVerkeer.Status := ParseError;

		RegExpr.Free();
		Exit;
	end;

	// geupload verkeer
	if RegExpr.ExecNext() then
	begin
		DataVerkeer.PeriodeUp := parseTrafficString(RegExpr.Match[2]);
	end
	else
	begin
		DataVerkeer.Status := ParseError;

		RegExpr.Free();
		Exit;
	end;

	// totaal verkeer
	if RegExpr.ExecNext() then
	begin
		DataVerkeer.PeriodeTotaal := parseTrafficString(RegExpr.Match[2]);
	end
	else
	begin
		DataVerkeer.Status := ParseError;

		RegExpr.Free();
		Exit;
	end;

	// nieuwsserver
	RegExpr.Expression := '<td align="center"><B>([\d,]* [\w]*)<\/B></td>\r\n\t\t\t<\/tr>';
	if RegExpr.Exec(trafficPage) then
	begin
		DataVerkeer.NieuwsServer := parseTrafficString(RegExpr.Match[1]);
	end
	else
	begin
		// Deze regel HTML komt niet voor wanneer het verplaatste verkeer nog
		// op 0 bytes staat.
		DataVerkeer.NieuwsServer := 0;
	end;

	RegExpr.Free();
end;

function TPipDataThread.parseDateString(Day, Month, Year: String): TDateTime;
const
	FULLMONTHNAMES: array[1..12] of String = ('januari', 'februari', 'maart', 'april', 'mei', 'juni', 'juli', 'augustus', 'september', 'oktober', 'november', 'december');
var
	intDag, intMaand, intJaar: Integer;
begin
	for intMaand := 1 to 12 do
		if SameText(Month, FULLMONTHNAMES[intMaand]) then
			Break;

	try
		intDag := StrToInt(Day);
		intJaar := StrToInt(Year);

		Result := EncodeDate(intJaar, intMaand, intDag);
	except
		on EConvertError do
			Result := Now();
	end;
end;

function TPipDataThread.parseTrafficString(TrafficString: String): Double;
var
	regEx: TRegExpr;
begin
	Result := 0;

	regEx := TRegExpr.Create();
	regEx.ModifierI := True;

	regEx.Expression := '([\d\.]+) MB';

	if regEx.Exec(TrafficString) and (regEx.SubExprMatchCount = 1) then
		Result := StrToInt(StringReplace(regEx.Match[1], '.', '', [rfReplaceAll]));

	regEx.Expression := '([\d]+),([\d]+) MB';

	if regEx.Exec(TrafficString) and (regEx.SubExprMatchCount = 2) then
		Result := StrToInt(regEx.Match[1]) + (StrToInt(regEx.Match[2]) / Power(10, Length(regEx.Match[2])));

	regEx.Free();
end;

end.
