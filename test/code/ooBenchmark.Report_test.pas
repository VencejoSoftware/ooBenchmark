{
  Copyright (c) 2016, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
unit ooBenchmark.Report_test;

interface

uses
  SysUtils,
  ooBenchmark.Report,
  Math,
{$IFDEF FPC}
  fpcunit, testregistry
{$ELSE}
  TestFramework
{$ENDIF};

type
  TBenchmarkReportTest = class(TTestCase)
  published
    procedure TestSleep;
    procedure TestSleepIterations;
    procedure TestSleepWarmupsAndIterations;
    procedure TestSleepAVG;
  end;

implementation

procedure TBenchmarkReportTest.TestSleep;
const
  SLEEPING = 1000;
var
  BenchmarkReport: IBenchmarkReport;
{$IFDEF FPC}
  procedure SleepTest;
  begin
    Sleep(SLEEPING);
  end;
{$ENDIF}

begin
{$IFDEF FPC}
  BenchmarkReport := TBenchmarkReport.New(Format('Sleep: %d', [SLEEPING]), @SleepTest);
{$ELSE}
  BenchmarkReport := TBenchmarkReport.New(Format('Sleep: %d', [SLEEPING]), procedure begin Sleep(SLEEPING) end);
{$ENDIF}
  BenchmarkReport.Execute;
  CheckEquals(SLEEPING, RoundTo(BenchmarkReport.ResultList.TotalTime, 1));
end;

procedure TBenchmarkReportTest.TestSleepIterations;
const
  SLEEPING = 100;
  ITERATIONS = 10;
var
  BenchmarkReport: IBenchmarkReport;
{$IFDEF FPC}
  procedure SleepTest;
  begin
    Sleep(SLEEPING);
  end;
{$ENDIF}

begin
{$IFDEF FPC}
  BenchmarkReport := TBenchmarkReport.New(Format('Sleep: %d', [SLEEPING]), @SleepTest, ITERATIONS);
{$ELSE}
  BenchmarkReport := TBenchmarkReport.New(Format('Sleep: %d', [SLEEPING]), procedure begin Sleep(SLEEPING) end,
    ITERATIONS);
{$ENDIF}
  BenchmarkReport.Execute;
  CheckEquals(SLEEPING * ITERATIONS, RoundTo(BenchmarkReport.ResultList.TotalTime, 1));
end;

procedure TBenchmarkReportTest.TestSleepAVG;
const
  SLEEPING = 100;
  ITERATIONS = 10;
var
  BenchmarkReport: IBenchmarkReport;
{$IFDEF FPC}
  procedure SleepTest;
  begin
    Sleep(SLEEPING);
  end;
{$ENDIF}

begin
{$IFDEF FPC}
  BenchmarkReport := TBenchmarkReport.New(Format('Sleep: %d', [SLEEPING]), @SleepTest, ITERATIONS);
{$ELSE}
  BenchmarkReport := TBenchmarkReport.New(Format('Sleep: %d', [SLEEPING]), procedure begin Sleep(SLEEPING) end,
    ITERATIONS);
{$ENDIF}
  BenchmarkReport.Execute;
  CheckEquals(SLEEPING, RoundTo(BenchmarkReport.ResultList.AvgTime, 1));
end;

procedure TBenchmarkReportTest.TestSleepWarmupsAndIterations;
const
  SLEEPING = 50;
  ITERATIONS = 50;
  WARMUPS = 5;
var
  BenchmarkReport: IBenchmarkReport;
{$IFDEF FPC}
  procedure SleepTest;
  begin
    Sleep(SLEEPING);
  end;
{$ENDIF}

begin
{$IFDEF FPC}
  BenchmarkReport := TBenchmarkReport.New(Format('Sleep: %d', [SLEEPING]), @SleepTest, ITERATIONS, WARMUPS);
{$ELSE}
  BenchmarkReport := TBenchmarkReport.New(Format('Sleep: %d', [SLEEPING]), procedure begin Sleep(SLEEPING) end,
    ITERATIONS, WARMUPS);
{$ENDIF}
  BenchmarkReport.Execute;
  CheckEquals(Format('Sleep: %d', [SLEEPING]), BenchmarkReport.Name);
  CheckEquals(ITERATIONS, BenchmarkReport.ITERATIONS);
  CheckEquals(WARMUPS, BenchmarkReport.WARMUPS);
  CheckEquals(SLEEPING * ITERATIONS, RoundTo(BenchmarkReport.ResultList.TotalTime, 1));
end;

initialization

RegisterTest(TBenchmarkReportTest {$IFNDEF FPC}.Suite {$ENDIF});

end.
