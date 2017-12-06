unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs
  {$IFDEF MSWINDOWS}
  , Windows
  {$ENDIF}
  {$IFDEF UNIX}
  , Unix, BaseUnix
  {$ENDIF}
  , PerformanceTime;

type

  { TForm1 }

  TForm1 = class(TForm)
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}



type
  {$IFDEF FPC}
  TProc = procedure();
  {$ENDIF}

  IBenchmarkElapsed = interface
    ['{8EEFE6A3-32B6-45BF-9AE4-58187AC43197}']
    function MsToDateTime(const Microseconds: extended): TDateTime;
    function MsToString(const Microseconds: extended): string;
    function BenchmarkMethod(Method: TProc): extended;
    function Elapsed: extended;

    procedure Start;
  end;

  TBenchmarkElapsed = class(TInterfacedObject, IBenchmarkElapsed)
  private
    _StartTime: real;
  public
    function MsToDateTime(const Microseconds: extended): TDateTime;
    function MsToString(const Microseconds: extended): string;
    function BenchmarkMethod(Method: TProc): extended;
    function Elapsed: extended;

    procedure Start;

    class function New: IBenchmarkElapsed;
  end;


function GetTimeInSec: extended;
var
{$IFDEF MSWINDOWS}
  StartCount, Freq: int64;
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

function TBenchmarkElapsed.MsToDateTime(const Microseconds: extended): TDateTime;
begin
  Result := Microseconds / SecsPerDay / MSecsPerSec;
end;

function TBenchmarkElapsed.MsToString(const Microseconds: extended): string;
var
  RoundMs: string;
begin
  Result := FormatDateTime('hh:nn:ss.z,', MsToDateTime(Microseconds));
  RoundMs := IntToStr(Round(Frac(Microseconds) * 100000000000));
  Result := Result + StringOfChar('0', 11 - Length(RoundMs)) + RoundMs;
end;

function TBenchmarkElapsed.BenchmarkMethod(Method: TProc): extended;
begin
  Start;
  Method;
  Result := Elapsed;
end;

procedure TBenchmarkElapsed.Start;
begin
  _StartTime := GetTimeInSec;
end;

function TBenchmarkElapsed.Elapsed: extended;
begin
  Result := 1000 * (GetTimeInSec - _StartTime);
end;

class function TBenchmarkElapsed.New: IBenchmarkElapsed;
begin
  Result := Create;
end;


function RDTSC: int64; assembler;
asm
         RDTSC
end;

function QueryPerformanceFrequency1: int64;
var
  startCycles, endCycles: int64;
  aTime, refTime: TDateTime;
begin
  aTime := Now;
  while aTime = Now do ;
  startCycles := RDTSC;
  refTime := Now;
  while refTime = Now do ;
  endCycles := RDTSC;
  aTime := Now;
  Result := Round((endCycles - startCycles) / ((aTime - refTime) * (3600 * 24)));
end;



procedure TForm1.FormCreate(Sender: TObject);
var
  BenchmarkElapsed: IBenchmarkElapsed;
  procedure SleepTest;
begin
  Sleep(1800);
end;
begin
  BenchmarkElapsed := TBenchmarkElapsed.New;
  BenchmarkElapsed.Start;
  //  Sleep(1800);
  //  ShowMessage(FloatToStr(BenchmarkElapsed.Elapsed));
  ShowMessage(FloatToStr(BenchmarkElapsed.BenchmarkMethod(TProc(@SleepTest))));
  //var
  //  a: TLargeInteger;
  //  b: TPerformanceTime;
  //begin
  //  b := TPerformanceTime.Create(False);
  //  b.Start;
  //  Sleep(1500);
  //  b.Stop;
  //  ShowMessage(FloatToStr(b.Delay));
  //  Exit;
  //  Windows.QueryPerformanceFrequency(a);
  //  ShowMessage(Format('%d   %d', [a, QueryPerformanceFrequency1]));
end;

end.
