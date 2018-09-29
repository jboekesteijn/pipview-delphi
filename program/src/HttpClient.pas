unit HttpClient;

interface

uses Windows, SysUtils, Classes, WinInet, Version;

type
	THttpClient = class(TObject)
	private
                StreamBuffer: TMemoryStream;
	public
		constructor Create;
		destructor Destroy; override;

		function GET(URI: String): Boolean;
		function HEAD(URI: String): Boolean;
                function getStringData(): String;
                procedure saveToFile(FileName: String);
	end;

implementation

constructor THttpClient.Create;
begin
        StreamBuffer := TMemoryStream.Create();
end;

destructor THttpClient.Destroy;
begin
	StreamBuffer.Free();
end;

function THttpClient.getStringData(): String;
var
        StringBuffer: TStringStream;
begin
        StringBuffer := TStringStream.Create('');

        StreamBuffer.SaveToStream(StringBuffer);

        Result := StringBuffer.DataString;

        StringBuffer.Free();
end;

procedure THttpClient.saveToFile(FileName: String);
begin
        StreamBuffer.SaveToFile(FileName);
end;

function THttpClient.GET(URI: String): Boolean;
var
	Scheme, HostName, UserName, Password, UrlPath, ExtraInfo, fullUrl: String;
	UrC: TUrlComponents;
	hSession, hConnection, hRequest: HINTERNET;
	Buffer: array[0..1024] of Byte;
	ReadResult: LongBool;
	ReadBytes, Context: Cardinal;
begin
	Result := False;
	Context := 1;

	SetLength(Scheme, INTERNET_MAX_SCHEME_LENGTH);
	SetLength(HostName, INTERNET_MAX_HOST_NAME_LENGTH);
	SetLength(UserName, INTERNET_MAX_USER_NAME_LENGTH);
	SetLength(Password, INTERNET_MAX_PASSWORD_LENGTH);
	SetLength(UrlPath, INTERNET_MAX_PATH_LENGTH);
	SetLength(ExtraInfo, 256);

	with UrC do
	begin
		dwStructSize := sizeof(TUrlComponents);

		dwSchemeLength := INTERNET_MAX_SCHEME_LENGTH;
		dwHostNameLength := INTERNET_MAX_HOST_NAME_LENGTH;
		dwUserNameLength := INTERNET_MAX_USER_NAME_LENGTH;
		dwPasswordLength := INTERNET_MAX_PASSWORD_LENGTH;
		dwUrlPathLength := INTERNET_MAX_PATH_LENGTH;
		dwExtraInfoLength := 256;

		lpszScheme := PAnsiChar(Scheme);
		lpszHostName := PAnsiChar(HostName);
		lpszUserName := PAnsiChar(UserName);
		lpszPassword := PAnsiChar(Password);
		lpszUrlPath := PAnsiChar(UrlPath);
		lpszExtraInfo := PAnsiChar(ExtraInfo);
	end;

	InternetCrackUrl(PAnsiChar(URI), Length(URI), ICU_DECODE, UrC);

	hSession := InternetOpen(PAnsiChar(getUserAgent()), INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);

	if hSession <> nil then
	begin
		hConnection := InternetConnect(hSession, UrC.lpszHostName, UrC.nPort, UrC.lpszUserName, UrC.lpszPassword, INTERNET_SERVICE_HTTP, 0, Context);
		if hConnection <> nil then
		begin
			fullUrl := String(UrC.lpszUrlPath) + String(UrC.lpszExtraInfo);

			if (UrC.nScheme = INTERNET_SCHEME_HTTPS) then
				hRequest := HttpOpenRequest(hConnection, 'GET', PAnsiChar(fullUrl), nil, nil, nil, INTERNET_FLAG_PRAGMA_NOCACHE or INTERNET_FLAG_RELOAD or INTERNET_FLAG_NO_AUTO_REDIRECT or INTERNET_FLAG_SECURE, Context)
			else
				hRequest := HttpOpenRequest(hConnection, 'GET', PAnsiChar(fullUrl), nil, nil, nil, INTERNET_FLAG_PRAGMA_NOCACHE or INTERNET_FLAG_RELOAD or INTERNET_FLAG_NO_AUTO_REDIRECT, Context);

			if hRequest <> nil then
			begin
				if HttpSendRequest(hRequest, nil, 0, nil, 0) then
				begin
					StreamBuffer.Clear;

                                        repeat
                                                ReadResult := InternetReadFile(hRequest, @Buffer, sizeof(Buffer), ReadBytes);
                                                StreamBuffer.Write(Buffer, ReadBytes);
                                        until ReadResult and (ReadBytes = 0);

					Result := True;
				end;
				InternetCloseHandle(hRequest);
			end;
			InternetCloseHandle(hConnection);
		end;
		InternetCloseHandle(hSession);
	end;
end;

function THttpClient.HEAD(URI: String): Boolean;
var
	Scheme, HostName, UserName, Password, UrlPath, ExtraInfo, fullUrl: String;
	UrC: TUrlComponents;
	hSession, hConnection, hRequest: HINTERNET;
	Buffer: array[0..1024] of Byte;
	Context, BufSize, Reserved: Cardinal;
begin
	Result := False;
	Context := 1;

	SetLength(Scheme, INTERNET_MAX_SCHEME_LENGTH);
	SetLength(HostName, INTERNET_MAX_HOST_NAME_LENGTH);
	SetLength(UserName, INTERNET_MAX_USER_NAME_LENGTH);
	SetLength(Password, INTERNET_MAX_PASSWORD_LENGTH);
	SetLength(UrlPath, INTERNET_MAX_PATH_LENGTH);
	SetLength(ExtraInfo, 256);

	with UrC do
	begin
		dwStructSize := sizeof(TUrlComponents);

		dwSchemeLength := INTERNET_MAX_SCHEME_LENGTH;
		dwHostNameLength := INTERNET_MAX_HOST_NAME_LENGTH;
		dwUserNameLength := INTERNET_MAX_USER_NAME_LENGTH;
		dwPasswordLength := INTERNET_MAX_PASSWORD_LENGTH;
		dwUrlPathLength := INTERNET_MAX_PATH_LENGTH;
		dwExtraInfoLength := 256;

		lpszScheme := PAnsiChar(Scheme);
		lpszHostName := PAnsiChar(HostName);
		lpszUserName := PAnsiChar(UserName);
		lpszPassword := PAnsiChar(Password);
		lpszUrlPath := PAnsiChar(UrlPath);
		lpszExtraInfo := PAnsiChar(ExtraInfo);
	end;

	InternetCrackUrl(PAnsiChar(URI), Length(URI), ICU_DECODE, UrC);

	hSession := InternetOpen(PAnsiChar(getUserAgent()), INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);

	if hSession <> nil then
	begin
		hConnection := InternetConnect(hSession, UrC.lpszHostName, UrC.nPort, UrC.lpszUserName, UrC.lpszPassword, INTERNET_SERVICE_HTTP, 0, Context);
		if hConnection <> nil then
		begin
			fullUrl := String(UrC.lpszUrlPath) + String(UrC.lpszExtraInfo);

			if (UrC.nScheme = INTERNET_SCHEME_HTTPS) then
				hRequest := HttpOpenRequest(hConnection, 'HEAD', PAnsiChar(fullUrl), nil, nil, nil, INTERNET_FLAG_PRAGMA_NOCACHE or INTERNET_FLAG_RELOAD or INTERNET_FLAG_NO_AUTO_REDIRECT or INTERNET_FLAG_SECURE, Context)
			else
				hRequest := HttpOpenRequest(hConnection, 'HEAD', PAnsiChar(fullUrl), nil, nil, nil, INTERNET_FLAG_PRAGMA_NOCACHE or INTERNET_FLAG_RELOAD or INTERNET_FLAG_NO_AUTO_REDIRECT, Context);

			if hRequest <> nil then
			begin
				if HttpSendRequest(hRequest, nil, 0, nil, 0) then
				begin
					BufSize := sizeof(Buffer);
					Reserved := 0;
					if HttpQueryInfo(hRequest, HTTP_QUERY_STATUS_CODE, @Buffer, BufSize, Reserved) then
					begin
						Result := True;
						StreamBuffer.Write(Buffer, BufSize);
					end;
				end;
				InternetCloseHandle(hRequest);
			end;
			InternetCloseHandle(hConnection);
		end;
		InternetCloseHandle(hSession);
	end;
end;

end.
