{$REGION 'documentation'}
{
  Copyright (c) 2016, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
{
  CPU bechmark object
  @created(08/04/2016)
  @author Vencejo Software <www.vencejosoft.com>
}
{$ENDREGION}
unit ooBenchmark.CPU;

interface

uses
  Windows,
  Math,
  Generics.Collections,
  ExtCtrls,
  ooBenchmark.Intf;

type
  TCPUUsage = class sealed(TInterfacedObject, IBenchmark)
  strict private
  type
    TCPUUsageData = record
      PID, Handle: Cardinal;
      oldUser, oldKernel: Int64;
      LastUpdateTime: Cardinal;
      LastUsage: single;
      Tag: Cardinal;
    end;

    PCPUUsageData = ^TCPUUsageData;
    TPerformanceList = TList<Extended>;
  strict private
    _PerformanceList: TPerformanceList;
    _Timer: TTimer;
    _PID: Cardinal;
    _PCPUUsageData: PCPUUsageData;
  private
    function CounterUsage: Extended;
    function CreateCounter: PCPUUsageData;

    procedure DestroyCounter;
    procedure OnTimer(Sender: TObject);
  public
    function Performance: Extended;
    function CPUSpeed: Double;

    procedure Start;

    constructor Create(const PID: Cardinal; const Interval: Cardinal);
    destructor Destroy; override;

    class function New(const PID: Cardinal; const Interval: Cardinal): IBenchmark;
  end;

implementation

function TCPUUsage.Performance: Extended;
var
  Item: Extended;
begin
  _Timer.Enabled := False;
  Result := 0;
  for Item in _PerformanceList do
    Result := Max(Result, Item);
end;

procedure TCPUUsage.Start;
begin
  DestroyCounter;
  _PCPUUsageData := CreateCounter;
  _Timer.Enabled := True;
end;

function TCPUUsage.CreateCounter: PCPUUsageData;
var
  CPUUsageData: PCPUUsageData;
  mCreationTime, mExitTime, mKernelTime, mUserTime: _FILETIME;
  ProcessHandle: Cardinal;
begin
  Result := nil;
  // We need a handle with PROCESS_QUERY_INFORMATION privileges
  ProcessHandle := OpenProcess(PROCESS_QUERY_INFORMATION, False, _PID);
  if ProcessHandle = 0 then
    Exit;
  System.New(CPUUsageData);
  CPUUsageData.PID := _PID;
  CPUUsageData.Handle := ProcessHandle;
  CPUUsageData.LastUpdateTime := GetTickCount;
  CPUUsageData.LastUsage := 0;
  if GetProcessTimes(CPUUsageData.Handle, mCreationTime, mExitTime, mKernelTime, mUserTime) then
  begin
    // convert _FILETIME to Int64
    CPUUsageData.oldKernel := Int64(mKernelTime.dwLowDateTime or (mKernelTime.dwHighDateTime shr 32));
    CPUUsageData.oldUser := Int64(mUserTime.dwLowDateTime or (mUserTime.dwHighDateTime shr 32));
    Result := CPUUsageData;
  end
  else
  begin
    Dispose(CPUUsageData);
  end;
end;

procedure TCPUUsage.DestroyCounter;
begin
  if _PCPUUsageData = nil then
    Exit;
  CloseHandle(_PCPUUsageData.Handle);
  Dispose(_PCPUUsageData);
end;

function TCPUUsage.CounterUsage: Extended;
var
  mCreationTime, mExitTime, mKernelTime, mUserTime: _FILETIME;
  DeltaMs, ThisTime: Cardinal;
  mKernel, mUser, mDelta: Int64;
begin
  Result := 0;
  if _PCPUUsageData = nil then
    Exit;
  Result := _PCPUUsageData.LastUsage;
  ThisTime := GetTickCount; // Get the time elapsed since last query
  DeltaMs := ThisTime - _PCPUUsageData.LastUpdateTime;
  // if DeltaMs < _Timer.Interval then
  // Exit;
  _PCPUUsageData.LastUpdateTime := ThisTime;
  GetProcessTimes(_PCPUUsageData.Handle, mCreationTime, mExitTime, mKernelTime, mUserTime);
  // convert _FILETIME to Int64.
  mKernel := Int64(mKernelTime.dwLowDateTime or (mKernelTime.dwHighDateTime shr 32));
  mUser := Int64(mUserTime.dwLowDateTime or (mUserTime.dwHighDateTime shr 32)); // get the delta
  mDelta := mUser + mKernel - _PCPUUsageData.oldUser - _PCPUUsageData.oldKernel;
  _PCPUUsageData.oldUser := mUser;
  _PCPUUsageData.oldKernel := mKernel;
  Result := (mDelta / DeltaMs) / 100; // mDelta is in units of 100 nanoseconds, so…
  _PCPUUsageData.LastUsage := Result;
end;

procedure TCPUUsage.OnTimer(Sender: TObject);
begin
  _PerformanceList.Add(CounterUsage);
end;

function TCPUUsage.CPUSpeed: Double;
const
  DelayTime = 500;
var
  TimerHi, TimerLo: DWORD;
  PriorityClass, Priority: Integer;
begin
  PriorityClass := GetPriorityClass(GetCurrentProcess);
  Priority := GetThreadPriority(GetCurrentThread);
  SetPriorityClass(GetCurrentProcess, REALTIME_PRIORITY_CLASS);
  SetThreadPriority(GetCurrentThread, THREAD_PRIORITY_TIME_CRITICAL);
  Sleep(10);
  asm
    dw 310Fh
    mov TimerLo, eax
    mov TimerHi, edx
  end;
  Sleep(DelayTime);
  asm
    dw 310Fh
    sub eax, TimerLo
    sbb edx, TimerHi
    mov TimerLo, eax
    mov TimerHi, edx
  end;
  SetThreadPriority(GetCurrentThread, Priority);
  SetPriorityClass(GetCurrentProcess, PriorityClass);
  Result := TimerLo / (1000 * DelayTime);
end;

constructor TCPUUsage.Create(const PID: Cardinal; const Interval: Cardinal);
begin
  _PID := PID;
  _PerformanceList := TPerformanceList.Create;
  _Timer := TTimer.Create(nil);
  _Timer.Enabled := False;
  _Timer.Interval := Interval;
  _Timer.OnTimer := Self.OnTimer;
end;

destructor TCPUUsage.Destroy;
begin
  if _Timer.Enabled then
    _Timer.Enabled := False;
  _Timer.Free;
  _PerformanceList.Free;
  DestroyCounter;
  inherited;
end;

class function TCPUUsage.New(const PID: Cardinal; const Interval: Cardinal): IBenchmark;
begin
  Result := Create(PID, Interval);
end;

end.
