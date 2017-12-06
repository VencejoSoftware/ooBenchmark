{
  Copyright (c) 2016, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
unit ooBenchmark.Chrometer_test;

interface

uses
  SysUtils,
  ooBenchmark.Chronometer,
{$IFDEF FPC}
  fpcunit, testregistry
{$ELSE}
  TestFramework
{$ENDIF};

type
  TChronometerTest = class(TTestCase)
  const
    SLEEPING = 2000;
  published
    procedure TestMsToDateTime;
    procedure TestMsToString;
    procedure TestBenchmarkMethod;
    procedure TestElapsed;
  end;

implementation

procedure TChronometerTest.TestElapsed;
var
  IntResult: Integer;
  Chronometer: IChronometer;
begin
  Chronometer := TChronometer.New;
  Chronometer.Start;
  Sleep(SLEEPING);
  IntResult := Round(Chronometer.Performance);
  CheckTrue((IntResult >= (SLEEPING - 100)) and (IntResult <= (SLEEPING + 100)),
    Format('Performance result %d', [IntResult]));
end;

procedure TChronometerTest.TestBenchmarkMethod;
var
  FloatResult: Extended;
  Chronometer: IChronometer;
{$IFDEF FPC}
  procedure SleepTest;
  begin
    Sleep(SLEEPING);
  end;
{$ENDIF}

begin
  Chronometer := TChronometer.New;
{$IFDEF FPC}
  FloatResult := Chronometer.BenchmarkMethod(@SleepTest);
{$ELSE}
  FloatResult := Chronometer.BenchmarkMethod( procedure begin Sleep(SLEEPING); end);
{$ENDIF}
  CheckTrue((FloatResult >= (SLEEPING - 100)) and (FloatResult <= (SLEEPING + 100)),
    Format('Performance result %f', [FloatResult]));
end;

procedure TChronometerTest.TestMsToDateTime;
var
  FloatResult: Extended;
  DateTimeResult: TDateTime;
  Hours, Minutes, Seconds, MSeconds: Word;
  Chronometer: IChronometer;
begin
  Chronometer := TChronometer.New;
  Chronometer.Start;
  Sleep(SLEEPING);
  FloatResult := Round(Chronometer.Performance);
  DateTimeResult := Chronometer.MsToDateTime(FloatResult);
  DecodeTime(DateTimeResult, Hours, Minutes, Seconds, MSeconds);
  CheckEquals(Seconds, (SLEEPING div 1000));
end;

procedure TChronometerTest.TestMsToString;
var
  FloatResult: Extended;
  ToMs: string;
  Chronometer: IChronometer;
{$IFDEF FPC}
  procedure DoSleep;
  begin
    Sleep(SLEEPING);
  end;
{$ENDIF}

begin
  Chronometer := TChronometer.New;
{$IFDEF FPC}
  FloatResult := Chronometer.BenchmarkMethod(@DoSleep);
{$ELSE}
  FloatResult := Chronometer.BenchmarkMethod( procedure begin Sleep(SLEEPING); end);
{$ENDIF}
  ToMs := Chronometer.MsToString(FloatResult);
  CheckEquals('00:00:01', Copy(ToMs, 1, 8));
end;

initialization

RegisterTest(TChronometerTest {$IFNDEF FPC}.Suite {$ENDIF});

end.
