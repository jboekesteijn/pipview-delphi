unit Dataverkeer;

interface

uses Math;

type
	TPipStatus = (Invalid, Success, CouldNotConnect, WrongLogin, ParseError, WrongDateTime);

type
	TDataVerkeer = class(TObject)
	private
		FStatus: TPipStatus;
		FLimiet: Double;
		FPeriodeStart: TDateTime;
		FPeriodeVandaag: TDateTime;
		FPeriodeEind: TDateTime;
		FVandaagDown: Double;
		FVandaagUp: Double;
		FPeriodeDown: Double;
		FPeriodeUp: Double;
		FPeriodeTotaal: Double;
		FNieuwsServer: Double;
		function getVerkeerOver(): Double;
		function getPeriodeOver(): Double;
		function getPeriodeLengte(): Integer;
		function getPeriodeGedaan(): Double;
		function getVandaagTotaal(): Double;
		function getPeriodePercentage(): Double;
		function getVerkeerPercentage(): Double;
		function getNieuwsPercentage(): Double;
		function getOverPerDag(): Double;
	public
		property Status: TPipStatus read FStatus write FStatus;
		property Limiet: Double read FLimiet write FLimiet;
		property PeriodeStart: TDateTime read FPeriodeStart write FPeriodeStart;
		property PeriodeVandaag: TDateTime read FPeriodeVandaag write FPeriodeVandaag;
		property PeriodeEind: TDateTime read FPeriodeEind write FPeriodeEind;
		property VandaagDown: Double read FVandaagDown write FVandaagDown;
		property VandaagUp: Double read FVandaagUp write FVandaagUp;
		property PeriodeDown: Double read FPeriodeDown write FPeriodeDown;
		property PeriodeUp: Double read FPeriodeUp write FPeriodeUp;
		property PeriodeTotaal: Double read FPeriodeTotaal write FPeriodeTotaal;
		property NieuwsServer: Double read FNieuwsServer write FNieuwsServer;

		property VerkeerOver: Double read getVerkeerOver;
		property PeriodeOver: Double read getPeriodeOver;
		property VandaagTotaal: Double read getVandaagTotaal;
		property PeriodePercentage: Double read getPeriodePercentage;
		property VerkeerPercentage: Double read getVerkeerPercentage;
		property NieuwsPercentage: Double read getNieuwsPercentage;
		property OverPerDag: Double read getOverPerDag;

		constructor Create;
	end;

implementation

constructor TDataVerkeer.Create();
begin
	FStatus := Invalid;
	FLimiet := 0;
	FPeriodeStart := 0;
	FPeriodeVandaag := 0;
	FPeriodeEind := 0;
	FVandaagDown := 0;
	FVandaagUp := 0;
	FPeriodeDown := 0;
	FPeriodeUp := 0;
	FPeriodeTotaal := 0;
	FNieuwsServer := 0;
end;

function TDataVerkeer.getVandaagTotaal(): Double;
begin
	Result := FVandaagDown + FVandaagUp;
end;

function TDataVerkeer.getVerkeerOver(): Double;
begin
	Result := FLimiet - FPeriodeTotaal;
end;

function TDataVerkeer.getPeriodeOver(): Double;
var
	Diff: Double;
begin
	Diff := FPeriodeEind - FPeriodeVandaag;

	if (Diff > 0) then
		Result := Diff
	else
		Result := 0;
end;

function TDataVerkeer.getOverPerDag(): Double;
begin
	if ((getVerkeerOver() = 0) or (getPeriodeOver() = 0)) then
		Result := 0
	else
		Result := getVerkeerOver() / getPeriodeOver();
end;

function TDataVerkeer.getPeriodeLengte(): Integer;
var
	Diff: Double;
begin
	Diff := FPeriodeEind - FPeriodeStart;

	if (Diff > 0) then
		Result := Ceil(Diff)
	else
		Result := 0;
end;

function TDataVerkeer.getPeriodeGedaan(): Double;
begin
	Result := FPeriodeVandaag - FPeriodeStart;
end;

function TDataVerkeer.getPeriodePercentage(): Double;
begin
	if ((getPeriodeGedaan() = 0) or (getPeriodeLengte() = 0)) then
		Result := 0
	else
		Result := getPeriodeGedaan() / getPeriodeLengte() * 100;
end;

function TDataVerkeer.getVerkeerPercentage(): Double;
begin
	if ((FPeriodeTotaal = 0) or (FLimiet = 0)) then
		Result := 0
	else
		Result := FPeriodeTotaal / FLimiet * 100;
end;

function TDataVerkeer.getNieuwsPercentage(): Double;
begin
	if (FNieuwsServer = 0) then
		Result := 0
	else
		Result := FNieuwsServer / 250;
end;

end.
