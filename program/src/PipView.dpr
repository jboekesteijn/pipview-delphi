program PipView;

uses
	Windows, Forms, SysUtils,
	Main in 'Main.pas' {frmPipMain},
	Opties in 'Opties.pas' {frmOpties};

{$R resource.res}

var
	Handle: HWND;
begin
	// DEBUG CODE, gebruiken met FastMM4 voor leak detection
	// ReportMemoryLeaksOnShutdown := True;

	Application.ShowMainForm := False;

	CreateMutex(nil, True, 'PipView');

	if (GetLastError() <> ERROR_ALREADY_EXISTS) then
	begin
		Application.Initialize;
		Application.Title := 'PipView';
		Application.Icon.Handle := LoadImage(GetModuleHandle(nil), MakeIntResource(1), IMAGE_ICON, 32, 32, LR_VGACOLOR);

		while FindWindowEx(FindWindow('Shell_TrayWnd', nil), 0, 'TrayNotifyWnd', nil) = 0 do
			Sleep(1000);

		Application.CreateForm(TfrmPipMain, frmPipMain);
		frmPipMain.Icon.Handle := LoadImage(GetModuleHandle(nil), MakeIntResource(1), IMAGE_ICON, 16, 16, LR_VGACOLOR);
		Application.Run;
	end
	else
	begin
		Handle := FindWindow('TfrmPipMain', nil);

		if Handle <> 0 then
			SendMessage(Handle, 32797, 11, 1984); // 32797 = WM_APP + 29
	end;
end.
