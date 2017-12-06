{$REGION 'documentation'}
{
  Copyright (c) 2016, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
{
  Time chronometer object
  @created(08/04/2016)
  @author Vencejo Software <www.vencejosoft.com>
}
{$ENDREGION}
unit ooBenchmark.Chronometer;

interface

uses
  SysUtils
{$IFDEF MSWINDOWS}
  , Windows
{$ENDIF}
{$IFDEF UNIX}
  , Unix, BaseUnix
{$ENDIF},
  ooBenchmark.Intf;

type
{$IFDEF FPC}
  TProc = procedure();
{$ENDIF}
{$REGION 'documentation'}
{
  @abstract(Time chronometer object)
  Take metrics of spent time in code using OS apis
  @member(
    MsToDateTime Convert microseconds to TDateTime type
    @param(Microseconds Microseconds to convert)
    @returns(TDateTime primitive value)
  )
  @member(
    MsToString Convert microseconds to string type
    @param(Microseconds Microseconds to convert)
    @returns(String primitive value)
  )
  @member(
    BenchmarkMethod Run method and take metrics
    @param(Method The pointer to method to run)
    @returns(Elapsed time in microseconds)
  )
}
{$ENDREGION}

  IChronometer = interface(IBenchmark)
    ['{8EEFE6A3-32B6-45BF-9AE4-58187AC43197}']
    function MsToDateTime(const Microseconds: Extended): TDateTime;
    function MsToString(const Microseconds: Extended): string;
    function BenchmarkMethod(Method: TProc): Extended;
  end;
{$REGION 'documentation'}
{
  @abstract(Implementation of @link(IChronometer))
  @member(MsToDateTime @seealso(IChronometer.MsToDateTime))
  @member(MsToString @seealso(IChronometer.MsToString))
  @member(BenchmarkMethod @seealso(IChronometer.BenchmarkMethod))
  @member(Elapsed @seealso(IChronometer.Elapsed))
  @member(Start @seealso(IChronometer.Start))
  @member(New Create a new @classname as interface)
}
{$ENDREGION}

  TChronometer = class(TInterfacedObject, IChronometer)
  strict private
    _StartTime: Real;
  public
    function MsToDateTime(const Microseconds: Extended): TDateTime;
    function MsToString(const Microseconds: Extended): string;
    function BenchmarkMethod(Method: TProc): Extended;
    function Performance: Extended;

    procedure Start;

    class function New: IChronometer;
  end;

implementation

function GetTimeInSec: Extended;
var
{$IFDEF MSWINDOWS}
  StartCount, Freq: Int64;
{$ENDIF}
{$IFDEF UNIX}
  TimeLinux: timeval;
{$ENDIF}
begin
{$IFDEF MSWINDOWS}
  if QueryPerformanceCounter(StartCount) then
  begin
    QueryPerformanceFrequency(Freq);
    Result := StartCount / Freq;
  end
  else
    Result := GetTickCount * 1000;
{$ENDIF}
{$IFDEF UNIX}
  fpGetTimeOfDay(@TimeLinux, nil);
  Result := TimeLinux.tv_sec + TimeLinux.tv_usec / 1000000;
{$ENDIF}
end;

function TChronometer.MsToDateTime(const Microseconds: Extended): TDateTime;
begin
  Result := Microseconds / SecsPerDay / MSecsPerSec;
end;

function TChronometer.MsToString(const Microseconds: Extended): string;
var
  RoundMs: string;
begin
  Result := FormatDateTime('hh:nn:ss.z,', MsToDateTime(Microseconds));
  RoundMs := IntToStr(Round(Frac(Microseconds) * 100000000000));
  Result := Result + StringOfChar('0', 11 - Length(RoundMs)) + RoundMs;
end;

function TChronometer.BenchmarkMethod(Method: TProc): Extended;
begin
  Start;
  Method;
  Result := Performance;
end;

procedure TChronometer.Start;
begin
  _StartTime := GetTimeInSec;
end;

function TChronometer.Performance: Extended;
begin
  Result := 1000 * (GetTimeInSec - _StartTime);
end;

class function TChronometer.New: IChronometer;
begin
  Result := Create;
end;

end.
