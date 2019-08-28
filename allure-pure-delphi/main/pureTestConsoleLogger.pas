unit pureTestConsoleLogger;

interface

uses
  System.SysUtils, Winapi.Windows, pureTestFramework;

const
  ccBlue = 1;
  ccGreen = 2;
  ccRed = 4;
  ccBright = 8;
  ccNormal = ccBlue or ccGreen or ccRed;
  ccWarning = ccGreen or ccRed or ccBright;
  ccError = ccRed or ccBright;
  ccFailed: Integer = ccError;
  ccBroken: Integer = ccError;
  ccPassed: Integer = ccBright or ccGreen;
  ccSkipped: Integer = ccWarning;

type

  TPureTestTextLogger = class(TInterfacedObject, IPureTestsListener)
  private
    fIndent: Integer;
    fLastFixtureName: string;
  protected
    procedure InternalWrite(const s : string); virtual; abstract;
  public
    constructor Create;
    destructor Destroy; override;

    procedure SetColor(const foreground: Integer; const background: Integer = 0); virtual; abstract;
    procedure WriteLn(const s: string = '');
    procedure Write(const s : string);

    function GetIndent : Integer;
    procedure SetIndent(const Value: Integer);
    property Indent : Integer read GetIndent write SetIndent;

    procedure IncIndent(const Value: Integer = 4);
    procedure DecIndent(const Value: Integer = 4);

  public
    //IPureTestsListener
    procedure OnTestingStarts(const Context: IPureTestsContext);
    procedure OnStartTestFixture(const Fixture: IPureTestFixture);
    procedure OnBeforeSetupFixture(const Fixture: IPureTestFixture);
    procedure OnAfterSetupFixture(const Fixture: IPureTestFixture);
    procedure OnBeginTest(const Test: IPureTest);
    procedure OnBeforeExecuteTest(const Test: IPureTest);
    procedure OnBeforeStep(const Step: IPureTestStep);
    procedure OnAfterStep(const Step: IPureTestStep);
    procedure OnAfterExecuteTest(const Test: IPureTest);
    procedure OnEndTest(const Test: IPureTest);
    procedure OnBeforeTearDownFixture(const Fixture: IPureTestFixture);
    procedure OnAfterTearDownFixture(const Fixture: IPureTestFixture);
    procedure OnEndTestFixture(const Fixture: IPureTestFixture);
    procedure OnTestingEnds(const Context: IPureTestsContext);
  end;

  TPureTestConsoleLogger = class(TPureTestTextLogger)
  private
    fLastColor: Word;
    fStdOut: THandle;
  protected
    procedure InternalWrite(const s : string); override;
  public
    constructor Create;

    procedure SetColor(const foreground: Integer; const background: Integer = ccNormal); override;
  end;

implementation

{ TPureTestTextLogger }

constructor TPureTestTextLogger.Create;
begin
  inherited Create;
end;

procedure TPureTestTextLogger.DecIndent(const Value: Integer);
begin
  Indent := Indent - Value;
end;

destructor TPureTestTextLogger.Destroy;
begin

  inherited;
end;

function TPureTestTextLogger.GetIndent: Integer;
begin
  result := fIndent;
end;

procedure TPureTestTextLogger.IncIndent(const Value: Integer);
begin
  Indent := Indent + Value;
end;

procedure TPureTestTextLogger.OnAfterExecuteTest(const Test: IPureTest);
begin

end;

procedure TPureTestTextLogger.OnAfterSetupFixture(
  const Fixture: IPureTestFixture);
begin

end;

procedure TPureTestTextLogger.OnAfterStep(const Step: IPureTestStep);
begin

end;

procedure TPureTestTextLogger.OnAfterTearDownFixture(
  const Fixture: IPureTestFixture);
begin

end;

procedure TPureTestTextLogger.OnBeforeExecuteTest(const Test: IPureTest);
begin

end;

procedure TPureTestTextLogger.OnBeforeSetupFixture(
  const Fixture: IPureTestFixture);
begin

end;

procedure TPureTestTextLogger.OnBeforeStep(const Step: IPureTestStep);
begin

end;

procedure TPureTestTextLogger.OnBeforeTearDownFixture(
  const Fixture: IPureTestFixture);
begin

end;

procedure TPureTestTextLogger.OnBeginTest(const Test: IPureTest);
begin

end;

procedure TPureTestTextLogger.OnEndTest(const Test: IPureTest);
begin
  if not (Test.Status in [ptsPassed, ptsNone, ptsSkipped]) then begin
    if not SameText(fLastFixtureName, Test.Fixture.Name) then begin
      fLastFixtureName := Test.Fixture.Name;
      SetColor(ccNormal);
      WriteLn;
      WriteLn;
      WriteLn('Fixture: ' + Test.Fixture.Name);
      if Test.Fixture.Description<>'' then begin
        IncIndent(9);
        try
          WriteLn(Test.Fixture.Description);
        finally
          DecIndent(9);
        end
      end;
    end;
    WriteLn;
    case Test.Status of
      ptsFailed: begin
        SetColor(ccFailed);
        WriteLn('Failed test: ' + Test.Name);
      end;
      ptsBroken: begin
        SetColor(ccBroken);
        WriteLn('Broken test: ' + Test.Name);
      end;
      ptsSkipped: begin
        SetColor(ccSkipped);
        WriteLn('Skipped test: ' + Test.Name);
      end;
      else begin
        SetColor(ccNormal);
      end;
    end;
    if Test.Description<>'' then begin
      IncIndent(13);
      try
        WriteLn(Test.Description);
      finally
        DecIndent(13);
      end
    end;
    if Test.Details.Msg<>'' then begin
      IncIndent;
      try
        WriteLn('Message:');
        IncIndent(9);
        try
          WriteLn(Test.Details.Msg);
        finally
          DecIndent(9);
        end;
      finally
        DecIndent;
      end;
    end;
  end;
end;

procedure TPureTestTextLogger.OnEndTestFixture(const Fixture: IPureTestFixture);
begin
  fLastFixtureName := '';
end;

procedure TPureTestTextLogger.OnStartTestFixture(
  const Fixture: IPureTestFixture);
begin
  fLastFixtureName := '';
end;

procedure TPureTestTextLogger.OnTestingEnds(const Context: IPureTestsContext);
begin
  SetColor(ccNormal);
  WriteLn('********** Tests results **********');
  IncIndent;
  try
    WriteLn('Total test count: ' + IntToStr(Context.RunResults.TotalTestCount));
    WriteLn('Passed: ' + IntToStr(Context.RunResults.PassedTestCount));
    SetColor(ccFailed);
    WriteLn('Failed: ' + IntToStr(Context.RunResults.FailedTestCount));
    SetColor(ccBroken);
    WriteLn('Broken: ' + IntToStr(Context.RunResults.BrokenTestCount));
    SetColor(ccSkipped);
    WriteLn('Skipped: ' + IntToStr(Context.RunResults.SkippedTestCount));
  finally
    DecIndent;
  end;
  SetColor(ccNormal);
  WriteLn('********** Tests finish **********');
end;

procedure TPureTestTextLogger.OnTestingStarts(const Context: IPureTestsContext);
var
  fn: string;
begin
  WriteLn('********** Tests start **********');
  fn := GetModuleName(hInstance);
  WriteLn('Testing binary: ' + ExtractFileName(fn));
  WriteLn('Binary path: ' + ExtractFileDir(fn));
  fLastFixtureName := '';
end;

procedure TPureTestTextLogger.SetIndent(const Value: Integer);
begin
  if Value>=0 then
    fIndent := Value
  else
    fIndent := 0;
end;

procedure TPureTestTextLogger.Write(const s: string);
var
  ss: string;
begin
  ss := StringOfChar(' ', Indent) + s;
  InternalWrite(ss);
end;

procedure TPureTestTextLogger.WriteLn(const s: string);
begin
  Write(s + #13#10);
end;

{ TPureTestConsoleLogger }

constructor TPureTestConsoleLogger.Create;
begin
  inherited Create;
  fStdOut := GetStdHandle(STD_OUTPUT_HANDLE);
  fLastColor := 12345;
end;

procedure TPureTestConsoleLogger.InternalWrite(const s: string);
var
  dummy: Cardinal;
begin
  WriteConsoleW(FStdOut, PWideChar(s), Length(s), dummy, nil);
end;

procedure TPureTestConsoleLogger.SetColor(const foreground,
  background: Integer);
var
  c: Word;
begin
  c := foreground or (background shl 4);
  if fLastColor<>c then begin
    fLastColor := c;
    SetConsoleTextAttribute(fStdOut, c);
  end;
end;

end.
