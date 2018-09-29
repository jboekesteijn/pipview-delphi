unit Version;

interface

uses Windows, SysUtils;

function getVersionNumber(): String;
function getUserAgent(): String;

implementation

function getVersionNumber(): String;
var
	FVISize, Dummy: DWORD;
	FileVersionInfo: PChar;
	Value: PChar;
begin
	FVISize := GetFileVersionInfoSize(PAnsiChar(ParamStr(0)), Dummy);
	if FVISize > 0 then
	begin
		FileVersionInfo := AllocMem(FVISize);
		GetFileVersionInfo(PAnsiChar(ParamStr(0)), 0, FVISize, FileVersionInfo);

		if VerQueryValue(FileVersionInfo, PChar('StringFileInfo\041304E4\FileVersion'), Pointer(Value), Dummy) then
			Result := Value;

		FreeMem(FileVersionInfo, FVISize);
	end
	else
		Result := '-1';
end;

function getUserAgent(): String;
var
	OsDescription: String;
begin
	OsDescription := 'Windows';

	if (Win32Platform = VER_PLATFORM_WIN32_WINDOWS) then
	begin
		if (Win32MajorVersion = 4) and (Win32MinorVersion = 0) then
			OsDescription := 'Windows 95'
		else if (Win32MajorVersion = 4) and (Win32MinorVersion = 10) then
			OsDescription := 'Windows 98'
		else if (Win32MajorVersion = 4) and (Win32MinorVersion = 90) then
			OsDescription := 'Windows Me';
	end
	else
	if (Win32Platform = VER_PLATFORM_WIN32_NT) then
		OsDescription := Format('Windows NT %d.%d', [Win32MajorVersion, Win32MinorVersion]);

	Result := Format('PipView/%s (%s)', [getVersionNumber(), OsDescription]);
end;

end.
