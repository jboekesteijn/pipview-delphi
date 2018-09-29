unit DataPresentation;

interface

uses Classes, Windows, Graphics, SysUtils;

type
	TDataPresentation = class(TObject)
	public
		function getDateString(dateTime: TDateTime): String;
		function getSimpleDateString(dateTime: TDateTime): String;
		function getTrafficString(value: Double): String;
		function getBalansTrafficString(value: Double): String;
		function getBalansDaysString(value: Double): String;
		function getTrayIcon(Perc, Balans: Double; Text: Boolean): TIcon;
	private
		procedure DrawText(Text: String; Font: TCanvas; Render: TCanvas);
	end;

implementation

procedure TDataPresentation.DrawText(Text: String; Font: TCanvas; Render: TCanvas);
var
	x, y, x2, n, i: Integer;
begin
	x2 := 2;

	if Length(Text) = 1 then
		x2 := 5;

	for i := 1 to Length(Text) do
        begin
		n := StrToInt(Text[i]);
		for x := n * 6 to ((n + 1) * 6) - 1 do
		begin
			for y := 0 to 11 do
			begin
				if Font.Pixels[x,y] = clWhite then
					Render.Pixels[x2,2+y] := clWhite;
			end;

			Inc(x2);
		end;
        end;
end;

function TDataPresentation.getTrayIcon(Perc, Balans: Double; Text: Boolean): TIcon;
var
	Bitmap, Font: TBitmap;
	Icon: TIcon;
	iX, iY, PixStop: Integer;
	AndMask: TBitmap;
	IconInfo: TIconInfo;
	Pixel: TColor;
	strText: String;
begin
	Icon := TIcon.Create();

	if Text and (Perc > 0) and (Perc < 100) then
		Icon.Handle := LoadImage(GetModuleHandle(nil), MakeIntResource(2), IMAGE_ICON, 16, 16, LR_VGACOLOR)
	else
		Icon.Handle := LoadImage(GetModuleHandle(nil), MakeIntResource(1), IMAGE_ICON, 16, 16, LR_VGACOLOR);

	Bitmap := TBitmap.Create();
	Bitmap.Height := 16;
	Bitmap.Width := 16;
	Bitmap.PixelFormat := pf24bit;
	Bitmap.Canvas.Draw(0, 0, Icon);
	Icon.Free();

	if Text and (Perc > 0) and (Perc < 100) then
	begin
                if Balans >= 0 then
                begin
                        for iX := 0 to 15 do
                        begin
                                for iY := 15 downto 0 do
                                begin
                                        Pixel := Bitmap.Canvas.Pixels[iX, iY];
                                        Bitmap.Canvas.Pixels[iX, iY] := RGB(GetGValue(Pixel), Round(0.5*GetRValue(Pixel)), GetBValue(Pixel));
                                end;
                        end;
                end;

		strText := IntToStr(Round(Perc));

		Font := TBitmap.Create();
                Font.LoadFromResourceID(GetModuleHandle(nil), 1);

		DrawText(strText, Font.Canvas, Bitmap.Canvas);

		Font.Free();
	end
	else
	begin
		PixStop := 16 - Round((Perc / 100) * 16);

		if (pixStop > 0) and (pixStop < 16) then
		begin
			for iX := 0 to 15 do
			begin
				for iY := PixStop downto 0 do
				begin
					Pixel := Bitmap.Canvas.Pixels[iX, iY];
					Bitmap.Canvas.Pixels[iX, iY] := RGB(GetBValue(Pixel), GetGValue(Pixel), GetRValue(Pixel));
				end;
			end;
		end;
	end;

	// Converteer de bitmap naar een icoon mbv een masker (alle pixels meenemen, behalve hoekjes)
	AndMask := TBitmap.Create;
	AndMask.Monochrome := True;
	AndMask.Width := 16;
	AndMask.Height := 16;

	AndMask.Canvas.Brush.Color := clBlack;
	AndMask.Canvas.FillRect(Rect(0, 0, 16, 16));
	AndMask.Canvas.Pixels[0, 0] := clWhite;
	AndMask.Canvas.Pixels[0, 15] := clWhite;
	AndMask.Canvas.Pixels[15, 0] := clWhite;
	AndMask.Canvas.Pixels[15, 15] := clWhite;

	IconInfo.fIcon := True;
	IconInfo.xHotspot := 0;
	IconInfo.yHotspot := 0;
	IconInfo.hbmMask := AndMask.Handle;
	IconInfo.hbmColor := Bitmap.Handle;

	Result := TIcon.Create();
	Result.Handle := CreateIconIndirect(IconInfo);

	AndMask.Free;
	Bitmap.Free;
end;

function TDataPresentation.getDateString(dateTime: TDateTime): String;
begin
	DateTimeToString(Result, 'd mmmm yyyy', dateTime);
end;

function TDataPresentation.getSimpleDateString(dateTime: TDateTime): String;
begin
	DateTimeToString(Result, 'd mmmm', dateTime);
end;

function TDataPresentation.getBalansTrafficString(value: Double): String;
begin
	Result := FormatFloat('+,0.0 MB;-,0.0 MB', value);
end;

function TDataPresentation.getBalansDaysString(value: Double): String;
begin
	Result := FormatFloat('+0.0;-0.0', value);
end;

function TDataPresentation.getTrafficString(value: Double): String;
begin
	Result := Format('%.1n MB', [value]);
end;

end.
