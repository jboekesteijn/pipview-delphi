unit accounts;

interface

uses
  Windows, Forms, StdCtrls, Classes, Controls, Registry,
  SysUtils;

type
  TfrmAccounts = class(TForm)
    listAccounts: TListBox;
    btnClose: TButton;
    btnAdd: TButton;
    btnRemove: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure btnRemoveClick(Sender: TObject);
  private
    function getAccounts: TStringList;
    procedure RefreshList();
  end;

var
  frmAccounts: TfrmAccounts;

implementation

{$R *.dfm}

function TfrmAccounts.getAccounts: TStringList;
var
  Settings: TRegistry;
  keyNames: TStringList;
  iKey: Integer;
begin
  Result := TStringList.Create;

  Settings         := TRegistry.Create;
  Settings.RootKey := HKEY_CURRENT_USER;
  if Settings.OpenKey('\Software\PipView\', TRUE) then
  begin
    keyNames := TStringList.Create;
    Settings.GetKeyNames(keyNames);
    Settings.CloseKey;

    for iKey := 0 to keyNames.Count - 1 do
    begin
      if Settings.OpenKey('\Software\PipView\' + keyNames.Strings[iKey] + '\', FALSE) then
      begin
        if Settings.ValueExists('naam') then
          Result.Add(keyNames.Strings[iKey]  + '=' + Settings.ReadString('naam'));
      end;
    end;

    keyNames.Free;
  end;
  Settings.Free;
end;

procedure TfrmAccounts.FormCreate(Sender: TObject);
begin
  RefreshList;
end;

procedure TfrmAccounts.btnAddClick(Sender: TObject);
var
  Settings: TRegistry;
  newIndex: String;
begin
  if listAccounts.Items.Count > 0 then
    newIndex := IntToStr(StrToInt(listAccounts.Items.Names[listAccounts.Items.Count-1]) + 1)
  else
    newIndex := '0';

  Settings         := TRegistry.Create;
  Settings.RootKey := HKEY_CURRENT_USER;
  if Settings.OpenKey('\Software\PipView\'+newIndex, TRUE) then
  begin
    Settings.WriteString('naam','naam');
  end;
  Settings.Free;

  RefreshList;
end;

procedure TfrmAccounts.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmAccounts.btnRemoveClick(Sender: TObject);
var
  Settings: TRegistry;
  oldIndex: String;
begin
  oldIndex := listAccounts.Items.Names[listAccounts.ItemIndex];

  Settings         := TRegistry.Create;
  Settings.RootKey := HKEY_CURRENT_USER;
  Settings.DeleteKey('\Software\PipView\'+oldIndex);
  Settings.Free;

  RefreshList();
end;

procedure TfrmAccounts.RefreshList();
begin
  listAccounts.Items := getAccounts;
  if listAccounts.Count > 0 then
    listAccounts.ItemIndex := 0;
end;

end.
