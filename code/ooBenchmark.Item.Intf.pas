{$REGION 'documentation'}
{
  Copyright (c) 2016, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
{
  Report benchmak item interface
  @created(08/04/2016)
  @author Vencejo Software <www.vencejosoft.com>
}
{$ENDREGION}
unit ooBenchmark.Item.Intf;

interface

type
{$REGION 'documentation'}
{
  @abstract(Report benchmak item interface)
  Used to store metrics time of method running
  @member(Name Description name)
  @member(StartTime Datetime when method start)
  @member(Performance Spent method time)
  @member(Iteration Iteration incremental number)
}
{$ENDREGION}
  IBenchmarkItem = interface
    ['{EB925BD5-7AE5-4661-AA0B-200A286CC03E}']
    function Name: String;
    function StartTime: TDateTime;
    function Performance: Extended;
    function Iteration: Integer;
  end;

implementation

end.
