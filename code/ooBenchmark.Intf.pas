{$REGION 'documentation'}
{
  Copyright (c) 2016, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
{
  Benchmark interface
  @created(08/04/2016)
  @author Vencejo Software <www.vencejosoft.com>
}
{$ENDREGION}
unit ooBenchmark.Intf;

interface

type
{$REGION 'documentation'}
{
  @abstract(Benchmark interface)
  To take method metrics
  @member(Performance Metric value generated)
  @member(Start Start to take metrics)
}
{$ENDREGION}
  IBenchmark = interface
    ['{7A96B188-F7D8-486D-98DE-8A21B2AF6035}']
    function Performance: Extended;
    procedure Start;
  end;

implementation

end.
