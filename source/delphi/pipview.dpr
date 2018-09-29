program PipView;

uses
  Windows,
  Forms,
  main in 'main.pas' {frmPipMain},
  opties in 'opties.pas' {frmOpties},
  tools in 'tools.pas';

{$R resource.res}

const
  WM_APP = $8000;

var
  Handle: HWND;
begin
  Handle := FindWindow('TfrmPipMain', nil);

  if (Handle = 0) then
  begin
    Application.Initialize;
    Application.Title := 'PipView';
    Application.CreateForm(TfrmPipMain, frmPipMain);
    Application.Run;
  end
  else
  begin
    SendMessage(Handle, WM_APP + 2, 0, 502);
  end;
end.
