{$REGION 'documentation'}
{
  Copyright (c) 2016, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
{
  Definition list for @link(IBenchmarkItem)
  @created(08/04/2016)
  @author Vencejo Software <www.vencejosoft.com>
}
{$ENDREGION}
unit ooBenchmark.Item.List;

interface

uses
  Generics.Collections,
  ooBenchmark.Item.Intf;

type
{$REGION 'documentation'}
{
  @abstract(Definition list for @link(IBenchmarkItem))
  @member(TotalTime The sum of time for all items)
  @member(AvgTime The average of time for all items)
}
{$ENDREGION}
  TBenchmarkItemList = class sealed(TList<IBenchmarkItem>)
  public
    function TotalTime: Extended;
    function AvgTime: Extended;
  end;

implementation

function TBenchmarkItemList.AvgTime: Extended;
begin
  Result := TotalTime / Count;
end;

function TBenchmarkItemList.TotalTime: Extended;
var
  BenchmarkItem: IBenchmarkItem;
begin
  Result := 0;
  for BenchmarkItem in Self do
    Result := Result + BenchmarkItem.Performance;
end;

end.
