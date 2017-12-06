{$REGION 'documentation'}
{
  Copyright (c) 2016, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
{
  RAM bechmark object
  @created(08/04/2016)
  @author Vencejo Software <www.vencejosoft.com>
}
{$ENDREGION}
unit ooBenchmark.RAM;

interface

uses
  Classes, Math,
  Windows,
  Generics.Collections,
  ExtCtrls, Forms,
  PsAPI,
  ooBenchmark.Intf;

type
{$REGION 'documentation'}
{
  @abstract(Type for calculate performance results of RAM)
}
{$ENDREGION}
  TCalcPerformance = function: Extended of object;
{$REGION 'documentation'}
{
  @abstract(Thread time to execute benchmark)
  @member(OnTimer Event of every interval execution)
  @member(Execute Thread execute to check interval and propagete event OnTimer)
  @member(
    Create Object constructor
    @param(CreateSuspended @true if thread has suspend on construct object)
    @param(CalcPerformance Method callback of each interval event)
    @param(Interval Interval in milliseconds to take metrics)
  )
  @member(Destroy Object destructor)
  @member(FinishThreadExecution Kill OS monitor/event objects)
}
{$ENDREGION}

  TTimerThread = class(TThread)
  strict private
    _TickEvent: THandle;
    _CalcPerformance: TCalcPerformance;
    _Interval: Integer;
  private
    procedure OnTimer;
  protected
    procedure Execute; override;
  public
    constructor Create(CreateSuspended: Boolean; CalcPerformance: TCalcPerformance; const Interval: Cardinal);
    destructor Destroy; override;
    procedure FinishThreadExecution;
  end;
{$REGION 'documentation'}
{
  @abstract(RAM benchmark creator)
  @member(CalcPerformance Call OS api to calculate RAM usage)
  @member(AvgResult Average RAM usage)
  @member(MaxResult Maximun RAM usage)
  @member(MinResult Minimun RAM usage)
  @member(Performance Metrics of RAM usage)
  @member(Start Start to take RAM metrics)
  @member(
    Create Object constructor
    @param(Process Process to monitor)
    @param(Interval Interval in milliseconds to take metrics)
  )
  @member(Destroy Object destructor)
  @member(
    New Create a new @classname as interface
    Create Object constructor
    @param(Process Process to monitor)
    @param(Interval Interval in milliseconds to take metrics)
  )
}
{$ENDREGION}

  TRAMUsage = class sealed(TInterfacedObject, IBenchmark)
  strict private
  type
    TPerformanceList = TList<Extended>;
  strict private
    _PerformanceList: TPerformanceList;
    _Process: THandle;
    _Timer: TTimerThread;
  private
    function CalcPerformance: Extended;
    function AvgResult: Extended;
    function MaxResult: Extended;
    function MinResult: Extended;
  public
    function Performance: Extended;

    procedure Start;

    constructor Create(const Process: THandle; const Interval: Cardinal); reintroduce;
    destructor Destroy; override;

    class function New(const Process: THandle; const Interval: Cardinal): IBenchmark;
  end;

implementation

procedure TTimerThread.OnTimer;
begin
  _CalcPerformance;
end;

procedure TTimerThread.Execute;
begin
  while not Terminated do
  begin
    if WaitForSingleObject(_TickEvent, _Interval) = WAIT_TIMEOUT then
      OnTimer;
  end;
end;

procedure TTimerThread.FinishThreadExecution;
begin
  Terminate;
  SetEvent(_TickEvent);
end;

constructor TTimerThread.Create(CreateSuspended: Boolean; CalcPerformance: TCalcPerformance; const Interval: Cardinal);
begin
  FreeOnTerminate := False;
  _Interval := Interval;
  _TickEvent := CreateEvent(nil, True, False, nil);
  _CalcPerformance := CalcPerformance;
  inherited Create(CreateSuspended);
end;

destructor TTimerThread.Destroy;
begin
  CloseHandle(_TickEvent);
  inherited;
end;

function TRAMUsage.Performance: Extended;
begin
  _Timer.FinishThreadExecution;
  Result := MaxResult;
end;

procedure TRAMUsage.Start;
begin
  _PerformanceList.Clear;
  _Timer.Start;
end;

function TRAMUsage.CalcPerformance: Extended;
var
  pmc: PPROCESS_MEMORY_COUNTERS;
  cb: Integer;
begin
  Result := 0;
  cb := SizeOf(TProcessMemoryCounters);
  GetMem(pmc, cb);
  pmc^.cb := cb;
  if GetProcessMemoryInfo(_Process, pmc, cb) then
    Result := longint(pmc^.WorkingSetSize);
  FreeMem(pmc);
  _PerformanceList.Add(Result);
end;

function TRAMUsage.MaxResult: Extended;
var
  Item: Extended;
begin
  Result := 0;
  for Item in _PerformanceList do
    Result := Max(Result, Item);
end;

function TRAMUsage.AvgResult: Extended;
var
  Item: Extended;
begin
  Result := 0;
  for Item in _PerformanceList do
    Result := Result + Item;
  Result := Result / Pred(_PerformanceList.Count);
end;

function TRAMUsage.MinResult: Extended;
var
  Item: Extended;
begin
  Result := MaxInt;
  for Item in _PerformanceList do
    Result := Min(Result, Item);
end;

constructor TRAMUsage.Create(const Process: THandle; const Interval: Cardinal);
begin
  _PerformanceList := TPerformanceList.Create;
  _Process := Process;
  _Timer := TTimerThread.Create(True, CalcPerformance, Interval);
end;

destructor TRAMUsage.Destroy;
begin
  _Timer.FinishThreadExecution;
  _Timer.Free;
  _PerformanceList.Free;
  inherited;
end;

class function TRAMUsage.New(const Process: THandle; const Interval: Cardinal): IBenchmark;
begin
  Result := Create(Process, Interval);
end;

end.
