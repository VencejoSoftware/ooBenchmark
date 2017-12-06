{$REGION 'documentation'}
{
  Copyright (c) 2016, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
{
  Report metrics object of method execution
  @created(08/04/2016)
  @author Vencejo Software <www.vencejosoft.com>
}
{$ENDREGION}
unit ooBenchmark.Report;

interface

uses
  SysUtils,
  ooBenchmark.Chronometer, ooBenchmark.Item, ooBenchmark.Item.List;

type
{$REGION 'documentation'}
{
  @abstract(Report metrics object of method execution)
  @member(Iterations Number of executing iterations)
  @member(Warmups Number of executing warmups)
  @member(Name Description name)
  @member(Execute Run chronometer and reporting)
  @member(ResultList List of result of each iteration)

}
{$ENDREGION}
  IBenchmarkReport = interface
    ['{8F32DC4D-F838-493C-8902-560862ECE1FC}']
    function Iterations: Integer;
    function Warmups: Integer;
    function Name: string;
    function ResultList: TBenchmarkItemList;
    function Execute: Boolean;
  end;
{$REGION 'documentation'}
{
  @abstract(Implementation of @link(IBenchmarkReport))
  @member(Iterations @seealso(IBenchmarkReport.Iterations))
  @member(Warmups @seealso(IBenchmarkReport.Warmups))
  @member(Name @seealso(IBenchmarkReport.Name))
  @member(ResultList @seealso(IBenchmarkReport.ResultList))
  @member(Execute @seealso(IBenchmarkReport.Execute))
  @member(
    Create Object constructor
    @param(Name Report name)
    @param(Method Method pointer to take metrics)
    @param(Iterations Iterations number)
    @param(Warmups Warmups number)
  )
  @member(Destroy Object destructor)
  @member(
    New Create a new @classname as interface
    @param(Name Report name)
    @param(Method Method pointer to take metrics)
    @param(Iterations Iterations number)
    @param(Warmups Warmups number)
  )
}
{$ENDREGION}

  TBenchmarkReport = class sealed(TInterfacedObject, IBenchmarkReport)
  strict private
    _Iterations: Integer;
    _Warmups: Integer;
    _Name: String;
    _Method: TProc;
    _BenchmarkItemList: TBenchmarkItemList;
  public
    function Iterations: Integer;
    function Warmups: Integer;
    function Name: string;
    function ResultList: TBenchmarkItemList;
    function Execute: Boolean;

    constructor Create(const Name: string; const Method: TProc; const Iterations, Warmups: Integer);
    destructor Destroy; override;

    class function New(const Name: String; const Method: TProc; const Iterations: Integer = 1;
      const Warmups: Integer = 0): IBenchmarkReport;
  end;

implementation

function TBenchmarkReport.Iterations: Integer;
begin
  Result := _Iterations;
end;

function TBenchmarkReport.Warmups: Integer;
begin
  Result := _Warmups;
end;

function TBenchmarkReport.Name: string;
begin
  Result := _Name;
end;

function TBenchmarkReport.ResultList: TBenchmarkItemList;
begin
  Result := _BenchmarkItemList;
end;

function TBenchmarkReport.Execute: Boolean;
var
  i: Integer;
  Performance: Extended;
  Chronometer: IChronometer;
begin
  _BenchmarkItemList.Clear;
  for i := 1 to Warmups do
    _Method;
  Chronometer := TChronometer.New;
  for i := 1 to Iterations do
  begin
    Chronometer.Start;
    _Method;
    Performance := Chronometer.Performance;
    _BenchmarkItemList.Add(TBenchmarkItem.New(Name, i, Now, Performance));
  end;
  Result := True;
end;

constructor TBenchmarkReport.Create(const Name: string; const Method: TProc; const Iterations, Warmups: Integer);
begin
  inherited Create;
  _BenchmarkItemList := TBenchmarkItemList.Create;
  _Iterations := Iterations;
  _Warmups := Warmups;
  _Name := Name;
  _Method := Method;
end;

destructor TBenchmarkReport.Destroy;
begin
  _BenchmarkItemList.Free;
  inherited;
end;

class function TBenchmarkReport.New(const Name: String; const Method: TProc; const Iterations: Integer = 1;
  const Warmups: Integer = 0): IBenchmarkReport;
begin
  Result := TBenchmarkReport.Create(Name, Method, Iterations, Warmups);
end;

end.
