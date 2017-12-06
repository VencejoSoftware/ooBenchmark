{$REGION 'documentation'}
{
  Copyright (c) 2016, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
{
  Report benchmak item object
  @created(08/04/2016)
  @author Vencejo Software <www.vencejosoft.com>
}
{$ENDREGION}
unit ooBenchmark.Item;

interface

uses
  ooBenchmark.Item.Intf;

type
{$REGION 'documentation'}
{
  @abstract(Implementation of @link(IBenchmarkItem))
  @member(Name @seealso(IBenchmarkItem.Name))
  @member(StartTime @seealso(IBenchmarkItem.StartTime))
  @member(Performance @seealso(IBenchmarkItem.Performance))
  @member(Iteration @seealso(IBenchmarkItem.Iteration))
  @member(
    Create Object constructor
    @param(Name Benchmark name)
    @param(Iteration Iteration number)
    @param(StartTime Starting datetime)
    @param(Performance Spent time)
  )
  @member(
    New Create a new @classname as interface
    @param(Name Benchmark name)
    @param(Iteration Iteration number)
    @param(StartTime Starting datetime)
    @param(Performance Spent time)
  )
}
{$ENDREGION}
  TBenchmarkItem = class sealed(TInterfacedObject, IBenchmarkItem)
  strict private
    _StartTime: TDateTime;
    _Name: String;
    _Performance: Extended;
    _Iterations: Integer;
  public
    function Name: String;
    function StartTime: TDateTime;
    function Performance: Extended;
    function Iteration: Integer;

    constructor Create(const Name: String; const Iteration: Integer; const StartTime: TDateTime;
      const Performance: Extended);
    class function New(const Name: String; const Iteration: Integer; const StartTime: TDateTime;
      const Performance: Extended): IBenchmarkItem;
  end;

implementation

function TBenchmarkItem.Performance: Extended;
begin
  Result := _Performance;
end;

function TBenchmarkItem.Iteration: Integer;
begin
  Result := _Iterations;
end;

function TBenchmarkItem.Name: String;
begin
  Result := _Name;
end;

function TBenchmarkItem.StartTime: TDateTime;
begin
  Result := _StartTime;
end;

constructor TBenchmarkItem.Create(const Name: String; const Iteration: Integer; const StartTime: TDateTime;
  const Performance: Extended);
begin
  _StartTime := StartTime;
  _Name := Name;
  _Performance := Performance;
  _Iterations := Iteration;
end;

class function TBenchmarkItem.New(const Name: String; const Iteration: Integer; const StartTime: TDateTime;
  const Performance: Extended): IBenchmarkItem;
begin
  Result := TBenchmarkItem.Create(Name, Iteration, StartTime, Performance);
end;

end.
