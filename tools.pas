unit tools;

interface

uses
  Windows, Classes, DiMime, RegExpr, IniFiles, SysUtils,
  Graphics, JwaIpHlpApi, JwaIpTypes, JwaIpExport,
  WinInet;

type
  TBeep = class(TThread)
    procedure Execute; override;
  end;

type
  TUpdateInfo = record
    Versie: String;
    URL: String;
    Fouten: Integer;
  end;

function TrayIcon(Value: Integer; Text: Boolean; Color: TColor): TIcon;
function GetAppVersionInfo: String;
function FilterString(strInput: String): Single;
function StrToDate(strDatum: String): TDateTime;
function Encrypt(Data: String): String;
function Decrypt(Data: String): String;
function AdapterNameToIndex(Description: String): Integer;
function DHCPPerform(ReleaseRenew: Boolean; Index: Cardinal): Integer;
function ShorterString(Text: String; Characters: Integer): String;
function javaScriptEncode(inString: String): String;

procedure GetAdaptersList(var Adapters: TStringList);
procedure DoBeep(Freq, Duration: Longword);
procedure Siren;

function getHttp(getUrl: String): String;
procedure Logoff;
function Login(Naam, Wachtwoord: String): Integer;

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
{
    StrToDate zet een string om naar het TDateTime-formaat, en gaat daarbij
    uit van de nederlands datumnotatie, zoals die op de website van ZeelandNet
    gebruikt wordt.

    Argumenten:
        strDatum:   een string in het formaat '5 januari 2002'

    Terug:
        TDateTime:  bevat de datum in TDateTime-formaat
}
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

function TrayIcon(Value: Integer; Text: Boolean; Color: TColor): TIcon;
var
  Bitmap: TBitmap;
  strText: String;
  iX, iY: Integer;
  iX2, iY2: Integer;
  AndMask: TBitmap;
  IconInfo: TIconInfo;
begin
  Bitmap := TBitmap.Create;

  Bitmap.Width  := 16;
  Bitmap.Height := 16;

  Bitmap.Canvas.Brush.Color := ClBlack;

  Bitmap.Canvas.FillRect(Rect(0,0,16,16));
  Bitmap.Canvas.Pen.Color   := Color;
  Bitmap.Canvas.Brush.Color := Color;
  Bitmap.Canvas.RoundRect(0,0,16,16,2,2);

  if (Text) and (Value > 0) then
  begin
    strText := IntToStr(Value);
    Bitmap.Canvas.Font.Size  := 8;
    Bitmap.Canvas.Font.Name  := 'MS Sans Serif';
    Bitmap.Canvas.Font.Color := clWhite;

    iX := Round((16 - Bitmap.Canvas.TextWidth(strText)) / 2);
    iY := Round((16 - Bitmap.Canvas.TextHeight(strText)) / 2);

    Bitmap.Canvas.TextOut(iX, iY, strText);
  end
  else begin
    Bitmap.Canvas.Pixels[6,4] := clWhite;
    Bitmap.Canvas.Pixels[7,4] := clWhite;
    Bitmap.Canvas.Pixels[8,4] := clWhite;
    Bitmap.Canvas.Pixels[9,4] := clWhite;
    Bitmap.Canvas.Pixels[10,4] := clWhite;

    Bitmap.Canvas.Pixels[7,5] := clWhite;
    Bitmap.Canvas.Pixels[10,5] := clWhite;
    Bitmap.Canvas.Pixels[11,5] := clWhite;

    Bitmap.Canvas.Pixels[7,6] := clWhite;
    Bitmap.Canvas.Pixels[10,6] := clWhite;
    Bitmap.Canvas.Pixels[11,6] := clWhite;

    Bitmap.Canvas.Pixels[6,7] := clWhite;
    Bitmap.Canvas.Pixels[7,7] := clWhite;
    Bitmap.Canvas.Pixels[10,7] := clWhite;

    Bitmap.Canvas.Pixels[6,8] := clWhite;
    Bitmap.Canvas.Pixels[7,8] := clWhite;
    Bitmap.Canvas.Pixels[8,8] := clWhite;
    Bitmap.Canvas.Pixels[9,8] := clWhite;

    Bitmap.Canvas.Pixels[6,9] := clWhite;

    Bitmap.Canvas.Pixels[5,10] := clWhite;
    Bitmap.Canvas.Pixels[6,10] := clWhite;

    Bitmap.Canvas.Pixels[4,11] := clWhite;
    Bitmap.Canvas.Pixels[5,11] := clWhite;
    Bitmap.Canvas.Pixels[6,11] := clWhite;
    Bitmap.Canvas.Pixels[7,11] := clWhite;
  end;

  if Text = FALSE then
  begin
    for iX2 := 0 to 16 do
    begin
      for iY2 := 0 to 16 do
      begin
        if Round((iY2 / 16) * 100) <= Value then
          if Bitmap.Canvas.Pixels[iX2, 16 - iY2] = Color then
            Bitmap.Canvas.Pixels[iX2, 16 - iY2] := clBlue;
      end;
    end;
  end;

  AndMask            := TBitmap.Create;
  AndMask.Monochrome := TRUE;
  AndMask.Width      := 16;
  AndMask.Height     := 16;

  AndMask.Canvas.Brush.Color := clWhite;
  AndMask.Canvas.FillRect(Rect(0,0,16,16));
  AndMask.Canvas.Brush.Color := clBlack;
  AndMask.Canvas.RoundRect(0,0,16,16,2,2);

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

procedure Sound(Freq: Word);
asm
  MOV DX, AX
  in AL, $61
  MOV AH, AL
  and AL, 3
  JNE @@1
  MOV AL, AH
  or AL, 3
  out $61, AL
  MOV AL, $B6
  out $43, AL
  @@1:
  MOV AX, DX
  out $42, AL
  MOV AL, AH
  out $42, AL
end;

procedure NoSound;
asm
  in AL, $61
  and AL, $FC
  out $61, AL
end;

procedure TBeep.Execute;
var
  iFreq: Integer;
begin
  for iFreq := 30 to 100 do
    DoBeep(iFreq * 10, 1);

  for iFreq := 100 downto 30 do
    DoBeep(iFreq * 10, 1);
end;

procedure DoBeep(Freq, Duration: Longword);
begin
  if Win32Platform = VER_PLATFORM_WIN32_NT then
    Windows.Beep(Freq, Duration)
  else
  begin
    if Freq < 20 then
      Freq := 20;
    if Freq > 5000 then
      Freq := 5000;
    Sound(1193181 div Freq);
    Sleep(Duration);
    NoSound;
  end;
end;

procedure Siren;
var
  Beep: TBeep;
begin
  Beep := TBeep.Create(TRUE);
  Beep.FreeOnTerminate := TRUE;
  Beep.Resume;
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

  hSession := InternetOpen(PAnsiChar('PipView/'+GetAppVersionInfo), INTERNET_OPEN_TYPE_PRECONFIG, NIL, NIL, 0);

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

  hSession := InternetOpen(PAnsiChar('PipView/'+GetAppVersionInfo), INTERNET_OPEN_TYPE_PRECONFIG, NIL, NIL, 0);

  if hSession <> NIL then
  begin
    hConnection := InternetConnect(hSession, 'secure.zeelandnet.nl', INTERNET_DEFAULT_HTTPS_PORT, NIL, NIL, INTERNET_SERVICE_HTTP, 0,Context);

    if hConnection <> NIL then
    begin
      hRequest := HttpOpenRequest(hConnection, 'POST', '/login/index.php', NIL, 'https://secure.zeelandnet.nl/login/index.php', NIL, INTERNET_FLAG_PRAGMA_NOCACHE or INTERNET_FLAG_NO_CACHE_WRITE or INTERNET_FLAG_RELOAD or INTERNET_FLAG_SECURE, Context);

      if hRequest <> NIL then
      begin
        Postdata := 'login_name=%s&login_pass=%s&login_type=abonnee&action=login&from=https://secure.zeelandnet.nl/pip/index.php';
        Header   := 'Content-type: application/x-www-form-urlencoded'#13#10;

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
