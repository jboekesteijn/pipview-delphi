unit tools;

interface

uses
  Windows, Classes, DiMime, RegExpr, IniFiles, SysUtils,
  Graphics, JwaIpHlpApi, JwaIpTypes, JwaIpExport,
  WinInet;

type
  TUpdateInfo = record
    Versie: String;
    URL: String;
    Fouten: Integer;
  end;

{ TrayIcon geeft een TIcon terug dat geschikt is voor weergave in de
  system tray. }
function TrayIcon(Color: TColor): TIcon;

{ GetAppVersionInfo geeft een String terug met daarin het versienummer
  van PipView. }
function GetAppVersionInfo: String;

function FilterString(strInput: String): Single;

{ StrToDate zet een String om naar het TDateTime-formaat, en gaat daarbij
	uit van de nederlands datumnotatie, zoals die op de website van ZeelandNet
	gebruikt wordt. }
function StrToDate(strDatum: String): TDateTime;

function Encrypt(Data: String): String;
function Decrypt(Data: String): String;
function AdapterNameToIndex(Description: String): Integer;
function DHCPPerform(ReleaseRenew: Boolean; Index: Cardinal): Integer;
function ShorterString(Text: String; Characters: Integer): String;
function javaScriptEncode(inString: String): String;
function getHttp(getUrl: String): String;
function Login(Naam, Wachtwoord: String): Integer;

procedure Control_RunDLL(hwnd: THandle; hInst: THandle; CmdLine: PChar; CmdShow: Integer); stdcall; external 'Shell32.dll';
procedure Logoff;
procedure GetAdaptersList(var Adapters: TStringList);

implementation

uses main;

function javaScriptEncode(inString: String): String;
var
  iCount: Integer;
begin
  Result := '';
  for iCount := 1 to Length(inString) do
  begin
    Result := Result + '%'+IntToHex(Ord(inString[iCount]),2);
  end;
end;

function StrToDate(strDatum: String): TDateTime;
var
  intDag, intMaand, intJaar: Integer;
  regEx: TRegExpr;
  monthList: TStringHash;
begin
  Result := Now;

  regEx := TRegExpr.Create;
  regEx.Expression := '(\d*)\s(\D*)\s(\d*)';
  if regEx.Exec(strDatum) and (regEx.SubExprMatchCount = 3) then
  begin
    intDag  := StrToInt(regEx.Match[1]);
    intJaar := StrToInt(regEx.Match[3]);

    monthList := TStringHash.Create;
    monthList.Add('januari', 1);
    monthList.Add('februari', 2);
    monthList.Add('maart', 3);
    monthList.Add('april', 4);
    monthList.Add('mei', 5);
    monthList.Add('juni', 6);
    monthList.Add('juli', 7);
    monthList.Add('augustus', 8);
    monthList.Add('september', 9);
    monthList.Add('oktober', 10);
    monthList.Add('november', 11);
    monthList.Add('december', 12);

    intMaand := monthList.ValueOf(Lowercase(regEx.Match[2]));
    monthList.Free;

    Result := EncodeDate(intJaar, intMaand, intDag);
  end;
  regEx.Free;
end;

function FilterString(strInput: String): Single;
{
    Deze function handelt de strings af die uit de html van de PiP komen;
    wanneer er daar kb in voorkomt, wordt het getal door 1000 gedeeld, wanneer
    er mb in voorkomt, gebeurt er niets met het getal.

    Argumenten:
        strInput      - een string met data van zeelandnet zoals '100 mb' of '20 kb'

    Terug:
        Integer       - waarde in megabytes
}
var
  oldDecimalSeparator: Char;
  regEx: TRegExpr;
begin
  oldDecimalSeparator := DecimalSeparator;
  DecimalSeparator := ',';
  Result := -1;

  regEx := TRegExpr.Create;
  regEx.Expression := '(.*) MB';
  if regEx.Exec(strInput) and (regEx.SubExprMatchCount = 1) then
    Result := StrToFloat(regEx.Match[1]);

  regEx.Expression := '(.*) kB';
  if regEx.Exec(strInput) and (regEx.SubExprMatchCount = 1) then
    Result := StrToFloat(regEx.Match[1]) / 1000;

  regEx.Expression := '(.*) bytes';
  if regEx.Exec(strInput) and (regEx.SubExprMatchCount = 1) then
    Result := StrToFloat(regEx.Match[1]) / (1000 * 1000);

  DecimalSeparator := oldDecimalSeparator;
end;

function TrayIcon(Color: TColor): TIcon;
var
  Bitmap: TBitmap;
  iX, iY: Integer;
  AndMask: TBitmap;
  IconInfo: TIconInfo;
  Pixel: TColor;
begin
  Bitmap := TBitmap.Create;
  Bitmap.LoadFromResourceID(HInstance, 103);

  // RGB -> BGR
  if Color = clGreen then
  begin
    for iX := 0 to 16 do
    begin
      for iY := 0 to 16 do
      begin
        Pixel := Bitmap.Canvas.Pixels[iX, iY];
        Bitmap.Canvas.Pixels[iX, iY] := RGB(GetBValue(Pixel),GetGValue(Pixel),GetRValue(Pixel));
      end;
    end;
  end;

  // Converteer de bitmap naar een icoon mbv een masker (alle pixels meenemen)
  AndMask            := TBitmap.Create;
  AndMask.Monochrome := TRUE;
  AndMask.Width      := 16;
  AndMask.Height     := 16;

  AndMask.Canvas.Brush.Color := clBlack;
  AndMask.Canvas.FillRect(Rect(0,0,16,16));

  Result            := TIcon.Create;
  IconInfo.fIcon    := TRUE;
  IconInfo.xHotspot := 0;
  IconInfo.yHotspot := 0;
  IconInfo.hbmMask  := AndMask.Handle;
  IconInfo.hbmColor := Bitmap.Handle;
  Result.Handle     := CreateIconIndirect(IconInfo);

  AndMask.Free;
  Bitmap.Free;
end;

function GetAppVersionInfo: String;
begin
  Result := '0.9.9.4';
end;

function getOsDescription(): String;
begin
  Result := 'Windows';

  if (Win32Platform = VER_PLATFORM_WIN32_WINDOWS) then
  begin
    if (Win32MajorVersion = 4) and (Win32MinorVersion = 0) then
      Result := 'Windows 95' // Windows 95
    else if (Win32MajorVersion = 4) and (Win32MinorVersion = 10) then
      Result := 'Windows 98' // Windows 98
    else if (Win32MajorVersion = 4) and (Win32MinorVersion = 90) then
      Result := 'Windows Me' // Windows Me
  end
  else if (Win32Platform = VER_PLATFORM_WIN32_NT) then
	begin
		Result := Format('Windows NT %d.%d', [Win32MajorVersion, Win32MinorVersion]);
  end;
end;

function Encrypt(Data: String): String;
var
  Count: Integer;
begin
  for Count := 1 to Length(Data) do
  begin
    Data[Count] := Chr(Ord(Data[Count]) xor 1);
  end;

  Data   := MimeEncodeString(Data);
  Result := Data;
end;

function Decrypt(Data: String): String;
var
  Count: Integer;
begin
  Data := MimeDecodeString(Data);

  for Count := 1 to Length(Data) do
  begin
    Data[Count] := Chr(Ord(Data[Count]) xor 1);
  end;

  Result := Data;
end;

function checkLibrary(libName: String): Boolean;
var
  hModule: Cardinal;
begin
  Result := FALSE;
  hModule := LoadLibrary(PAnsiChar(libName));

  if hModule <> 0 then
  begin
    FreeLibrary(hModule);
    Result := TRUE;
  end;
end;

procedure GetAdaptersList(var Adapters: TStringList);
var
  pNextAdapterInfo, pAdapterInfo: PIpAdapterInfo;
  pOutBufLen, cResult: Cardinal;
  AdapterAdded: Boolean;
begin
  AdapterAdded := FALSE;
  pOutBufLen   := 0;

  if checkLibrary('iphlpapi.dll') then
  begin
    cResult := GetAdaptersInfo(NIL, pOutBufLen);

    if cResult = ERROR_BUFFER_OVERFLOW then
    begin
      GetMem(pAdapterInfo, pOutBufLen);
      cResult := GetAdaptersInfo(pAdapterInfo, pOutBufLen);

      if (cResult = ERROR_SUCCESS) then
      begin
        pNextAdapterInfo := pAdapterInfo;
        while pNextAdapterInfo <> NIL do
        begin
          if pNextAdapterInfo^.DhcpEnabled <> 0 then
          begin
            Adapters.Add(IntToStr(pNextAdapterInfo^.Index) + '=' + pNextAdapterInfo^.Description);
            AdapterAdded     := TRUE;
          end;
          pNextAdapterInfo := pNextAdapterInfo^.Next;
        end;
      end;

      FreeMem(pAdapterInfo);
    end;
  end;

  if AdapterAdded = FALSE then
  begin
    Adapters.Add('0=Geen adapters gevonden');
  end;
end;

function AdapterNameToIndex(Description: String): Integer;
var
  iCount: Integer;
  Adapters: TStringList;
begin
  Result := -1;

  Adapters := TStringList.Create;
  GetAdaptersList(Adapters);

  for iCount := 0 to Adapters.Count - 1 do
  begin
    if Adapters.ValueFromIndex[iCount] = Description then
      Result := StrToInt(Adapters.Names[iCount]);
  end;

  Adapters.Free;
end;

function DHCPPerform(ReleaseRenew: Boolean; Index: Cardinal): Integer;
var
  pIfTable: pIpInterfaceInfo;
  dwOutBufLen, cResult: Cardinal;
  iCount: Integer;
begin
  Result      := -1;
  dwOutBufLen := 0;

  if checkLibrary('iphlpapi.dll') then
  begin
    cResult := GetInterfaceInfo(NIL, dwOutBufLen);

    if cResult = ERROR_INSUFFICIENT_BUFFER then
    begin
      GetMem(pIfTable, dwOutBufLen);
      cResult := GetInterfaceInfo(pIfTable, dwOutBufLen);

      if cResult = ERROR_SUCCESS then
      begin
        for iCount := 0 to (pIfTable^.NumAdapters) - 1 do
        begin
          if Index = pIfTable^.Adapter[iCount].Index then
          begin
            if ReleaseRenew then
              Result := IpReleaseAddress(pIfTable^.Adapter[iCount])
            else
              Result := IpRenewAddress(pIfTable^.Adapter[iCount]);
          end;
        end;
      end;

      FreeMem(pIfTable);
    end;
  end;
end;

function ShorterString(Text: String; Characters: Integer): String;
begin
  Result := Text;

  if Length(Text) > Characters then
    Result := Copy(Text, 0,Characters - 3) + '...';
end;

procedure Logoff;
begin
  getHttp('https://secure.zeelandnet.nl/logout/index.php?from=pip');
end;

function getHttp(getUrl: String): String;
var
  Scheme, HostName, UserName, Password, UrlPath, ExtraInfo, fullUrl: String;
  UrC: TUrlComponents;
  hSession, hConnection, hRequest: HINTERNET;
  Data: TStringStream;
  Buffer: array[0..1024] of Byte;
  ReadResult: LongBool;
  ReadBytes, Context: Cardinal;
begin
  Result  := '';
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

    dwSchemeLength    := INTERNET_MAX_SCHEME_LENGTH;
    dwHostNameLength  := INTERNET_MAX_HOST_NAME_LENGTH;
    dwUserNameLength  := INTERNET_MAX_USER_NAME_LENGTH;
    dwPasswordLength  := INTERNET_MAX_PASSWORD_LENGTH;
    dwUrlPathLength   := INTERNET_MAX_PATH_LENGTH;
    dwExtraInfoLength := 256;

    lpszScheme    := PAnsiChar(Scheme);
    lpszHostName  := PAnsiChar(HostName);
    lpszUserName  := PAnsiChar(UserName);
    lpszPassword  := PAnsiChar(Password);
    lpszUrlPath   := PAnsiChar(UrlPath);
    lpszExtraInfo := PAnsiChar(ExtraInfo);
  end;

  InternetCrackUrl(PAnsiChar(getUrl), Length(getUrl), ICU_DECODE, UrC);

  hSession := InternetOpen(PAnsiChar('PipView/'+GetAppVersionInfo + ' ('+getOsDescription()+')'), INTERNET_OPEN_TYPE_PRECONFIG, NIL, NIL, 0);

  if hSession <> NIL then
  begin
    Data        := TStringStream.Create('');
    hConnection := InternetConnect(hSession, UrC.lpszHostName, UrC.nPort, UrC.lpszUserName, UrC.lpszPassword, INTERNET_SERVICE_HTTP, 0,Context);
    if hConnection <> NIL then
    begin
      fullUrl := String(UrC.lpszUrlPath) + String(UrC.lpszExtraInfo);
      if (UrC.nScheme = INTERNET_SCHEME_HTTPS) then
        hRequest := HttpOpenRequest(hConnection, 'GET', PAnsiChar(fullUrl), NIL, NIL, NIL, INTERNET_FLAG_PRAGMA_NOCACHE or INTERNET_FLAG_NO_CACHE_WRITE or INTERNET_FLAG_RELOAD or INTERNET_FLAG_SECURE, Context)
      else
        hRequest := HttpOpenRequest(hConnection, 'GET', PAnsiChar(fullUrl), NIL, NIL, NIL, INTERNET_FLAG_PRAGMA_NOCACHE or INTERNET_FLAG_NO_CACHE_WRITE or INTERNET_FLAG_RELOAD, Context);

      if hRequest <> NIL then
      begin
        if HttpSendRequest(hRequest, NIL, 0,NIL, 0) then
        begin
          repeat
            ReadResult := InternetReadFile(hRequest, @Buffer, sizeof(Buffer), ReadBytes);
            Data.Write(Buffer, ReadBytes);
          until (ReadResult) and (ReadBytes = 0);
          InternetCloseHandle(hRequest);
        end;
        InternetCloseHandle(hConnection);
      end;
    end;
    InternetCloseHandle(hSession);
    Result := Data.DataString;
    Data.Free;
  end;
end;

function Login(Naam, Wachtwoord: String): Integer;
var
  hSession, hConnection, hRequest: HINTERNET;
  PostData, Header: String;
  Data: TStringStream;
  Buffer: array[0..1024] of Byte;
  ReadResult: Longbool;
  ReadBytes, Context: Cardinal;
begin
  Result      := 2;
  Data        := TStringStream.Create('');
  Context     := 1;
  PostData    := '';
  Header      := '';

  hSession := InternetOpen(PAnsiChar('PipView/'+GetAppVersionInfo + ' ('+getOsDescription()+')'), INTERNET_OPEN_TYPE_PRECONFIG, NIL, NIL, 0);

  if hSession <> NIL then
  begin
    hConnection := InternetConnect(hSession, 'secure.zeelandnet.nl', INTERNET_DEFAULT_HTTPS_PORT, NIL, NIL, INTERNET_SERVICE_HTTP, 0,Context);

    if hConnection <> NIL then
    begin
      hRequest := HttpOpenRequest(hConnection, 'POST', '/login/index.php', NIL, 'https://secure.zeelandnet.nl/login/index.php', NIL, INTERNET_FLAG_PRAGMA_NOCACHE or INTERNET_FLAG_NO_CACHE_WRITE or INTERNET_FLAG_RELOAD or INTERNET_FLAG_SECURE, Context);

      if hRequest <> NIL then
      begin
        Header   := 'Content-type: application/x-www-form-urlencoded';

        Postdata := 'login_name=%s&login_pass=%s&login_type=abonnee&action=login';
        Postdata := Format(Postdata, [Naam, Wachtwoord]);

        if HttpAddRequestHeaders(hRequest, PChar(Header), Length(Header), HTTP_ADDREQ_FLAG_ADD) then
        begin
          if HttpSendRequest(hRequest, NIL, 0,PChar(PostData), Length(PostData)) then
          begin
            Result := 1;

            repeat
              ReadResult := InternetReadFile(hRequest, @Buffer, sizeof(Buffer), ReadBytes);
              Data.Write(Buffer, ReadBytes);
            until (ReadResult) and (ReadBytes = 0);
          end;
        end;
        InternetCloseHandle(hRequest);
      end;
      InternetCloseHandle(hConnection);
    end;
    InternetCloseHandle(hSession);
  end;

  Data.Free;
end;

end.
