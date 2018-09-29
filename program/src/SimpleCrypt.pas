unit SimpleCrypt;

interface

uses SysUtils;

type
	TSimpleCrypt = class(TObject)
	public
		function Encrypt(Data: String): String;
		function Decrypt(Data: String): String;
	private
		procedure Shift(var Data: String);
	end;

implementation

procedure TSimpleCrypt.Shift(var Data: String);
var
	Count: Integer;
begin
	for Count := 1 to Length(Data) do
		Data[Count] := Chr(Ord(Data[Count]) xor Count);
end;

function TSimpleCrypt.Encrypt(Data: String): String;
var
	Count: Integer;
begin
	Shift(Data);

	for Count := 1 to Length(Data) do
		Result := Result + IntToHex(Ord(Data[Count]), 2);
end;

function TSimpleCrypt.Decrypt(Data: String): String;
var
	Count: Integer;
begin
	Count := 1;

	while Count < Length(Data) do
	begin
		try
			Result := Result + Chr(StrToInt('$' + Data[Count] + Data[Count + 1]));
		except
			on EConvertError do
				Result := '';
		end;

		Inc(Count, 2);
	end;

	Shift(Result);
end;

end.
