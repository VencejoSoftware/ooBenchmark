{
  Copyright (c) 2016, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
program test;

uses
  ooRunTest,
  ooBenchmark.Chrometer_test in '..\code\ooBenchmark.Chrometer_test.pas',
  ooBenchmark.Report_test in '..\code\ooBenchmark.Report_test.pas';

{$R *.RES}

begin
  Run;

end.
