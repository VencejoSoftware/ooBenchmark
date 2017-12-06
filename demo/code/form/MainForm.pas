unit MainForm;

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms, StdCtrls, StrUtils,
  ooBenchmark.Report, ooBenchmark.Item.Intf, ooBenchmark.Item;

type
  TMainForm = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
  private
    procedure PosMethod;
    procedure AnsiPosMethod;
    procedure PosExMethod;
    procedure PosMethodWide;
    procedure AnsiPosMethodWide;
    procedure PosExMethodWide;
    procedure RunBenchMark(const BenchmarkReport: IBenchmarkReport);
  end;

var
  NewMainForm: TMainForm;

implementation

{$R *.dfm}

procedure TMainForm.PosMethod;
var
  Value, ToFind: String;
begin
  Value := 'Text to compare';
  ToFind := 'to';
  Pos(ToFind, Value);
end;

procedure TMainForm.AnsiPosMethod;
var
  Value, ToFind: String;
begin
  Value := 'Text to compare';
  ToFind := 'to';
  AnsiPos(ToFind, Value);
end;

procedure TMainForm.PosExMethod;
var
  Value, ToFind: String;
begin
  Value := 'Text to compare';
  ToFind := 'to';
  PosEx(ToFind, Value);
end;

procedure TMainForm.PosMethodWide;
var
  Value, ToFind: WideString;
begin
  Value := 'Text to compare';
  ToFind := 'to';
  Pos(ToFind, Value);
end;

procedure TMainForm.AnsiPosMethodWide;
var
  Value, ToFind: WideString;
begin
  Value := 'Text to compare';
  ToFind := 'to';
  AnsiPos(ToFind, Value);
end;

procedure TMainForm.PosExMethodWide;
var
  Value, ToFind: WideString;
begin
  Value := 'Text to compare';
  ToFind := 'to';
  PosEx(ToFind, Value);
end;

procedure TMainForm.RunBenchMark(const BenchmarkReport: IBenchmarkReport);
var
  BenchmarkItem: IBenchmarkItem;
begin
  BenchmarkReport.Execute;
  Memo1.Lines.Append(EmptyStr);
  for BenchmarkItem in BenchmarkReport.ResultList do
    Memo1.Lines.Append(Format('%s iteration %-4d, elapsed %g ms', [BenchmarkItem.Name, BenchmarkItem.Iteration,
        BenchmarkItem.Performance]));
  Memo1.Lines.Append(StringOfChar('-', 90));
  Memo1.Lines.Append(Format('%s [I:%d, W:%d], total = %g, avg = %g', [BenchmarkReport.Name, BenchmarkReport.Iterations,
      BenchmarkReport.Warmups, BenchmarkReport.ResultList.TotalTime, BenchmarkReport.ResultList.AvgTime]));
end;

procedure TMainForm.Button1Click(Sender: TObject);
const
  Iterations = 15;
  Warmups = 0;
begin
  Memo1.Clear;
  RunBenchMark(TBenchmarkReport.New('PosMethod', PosMethod, Iterations, Warmups));
  RunBenchMark(TBenchmarkReport.New('AnsiPosMethod', AnsiPosMethod, Iterations, Warmups));
  RunBenchMark(TBenchmarkReport.New('PosExMethod', PosExMethod, Iterations, Warmups));
  RunBenchMark(TBenchmarkReport.New('PosMethodWide', PosMethodWide, Iterations, Warmups));
  RunBenchMark(TBenchmarkReport.New('AnsiPosMethodWide', AnsiPosMethodWide, Iterations, Warmups));
  RunBenchMark(TBenchmarkReport.New('PosExMethodWide', PosExMethodWide, Iterations, Warmups));
end;

end.
