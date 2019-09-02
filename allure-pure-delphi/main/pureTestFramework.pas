unit pureTestFramework;

interface

uses
  System.SysUtils, pureTestExceptions, pureTestAssert;

type
  TPureTests = class;
  TPureTestsListeners = class;
  IPureTestsListener = interface;

  TPureTestStatus = (
    ptsNone,
    ptsFailed,
    ptsBroken,
    ptsPassed,
    ptsSkipped
  );

  TPureSeverityLevel = (
    pslBlocker,
    pslCritical,
    pslNormal,
    pslMinor,
    pslTrivial
  );

  TPureTestStatusDetails = record
    Msg: string;
    StackTrace: string;
  end;

  TPureTestsRunResults = record
    FailedTestCount: Integer;
    BrokenTestCount: Integer;
    PassedTestCount: Integer;
    SkippedTestCount: Integer;
    TotalTestCount: Integer;
    FixtureCount: Integer;
    procedure Clear;
  end;

  IPureTestObject = interface
  ['{9DC81A13-5EA5-4895-9152-D4F8520B2BF4}']
    function GetName: string;
    function GetDescription: string;
    function GetStartTime: TDateTime;
    function GetEndTime: TDateTime;
    function GetStatus: TPureTestStatus;
    function GetDetails: TPureTestStatusDetails;

    property Name: string read GetName;
    property Description: string read GetDescription;
    property StartTime: TDateTime read GetStartTime;
    property EndTime: TDateTime read GetEndTime;
    property Status: TPureTestStatus read GetStatus;
    property Details: TPureTestStatusDetails read GetDetails;
  end;

  IPureTestsContext = interface
  ['{7846F04A-2FE6-41EE-8AAC-461966E4FE6E}']
    function GetRunResults: TPureTestsRunResults;
    property RunResults: TPureTestsRunResults read GetRunResults;
  end;

  IPureTestFixture = interface(IPureTestObject)
  ['{A9A079AB-BED7-451C-B7B5-32F6F223D653}']
    function GetContext: IPureTestsContext;
    property Context: IPureTestsContext read GetContext;
  end;

  IPureTest = interface(IPureTestObject)
  ['{FFE64288-E6B2-4230-8262-EF467A68A604}']
    function GetFixture: IPureTestFixture;
    property Fixture: IPureTestFixture read GetFixture;
    procedure SetSeverity(const Value: TPureSeverityLevel);
    function GetSeverity: TPureSeverityLevel;
    property Severity: TPureSeverityLevel read GetSeverity write SetSeverity;

    procedure AddTestClass(const Value: string);
    procedure AddTestMethod(const Value: string);
    procedure AddIssue(const IssueID: string; const IssueLink: string = '');
    procedure AddLink(const Uri: string; const LinkName: string = '');
    procedure AddEpic(const Value: string);
    procedure AddFeature(const Value: string);
    procedure AddStory(const Value: string);
    procedure MarkFlaky;
    procedure MarkMuted;
    procedure MarkKnown;
  end;

  IPureTestStep = interface(IPureTestObject)
  ['{E59BC6A6-5FF9-4D1F-9D5F-E08E86DE679B}']
    function GetTest: IPureTest;
    property Test: IPureTest read GetTest;
  end;

  TPureTestObject = class(TInterfacedObject, IPureTestObject)
  private
    fName: string;
    fDescription: string;
    fStartTime: TDateTime;
    fEndTime: TDateTime;
    fStatus: TPureTestStatus;
    fDetails: TPureTestStatusDetails;

    function GetName: string;
    function GetDescription: string;
    function GetStartTime: TDateTime;
    function GetEndTime: TDateTime;
    function GetStatus: TPureTestStatus;
    function GetDetails: TPureTestStatusDetails;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Free;

    property Name: string read GetName;
    property Description: string read GetDescription;
    property StartTime: TDateTime read GetStartTime;
    property EndTime: TDateTime read GetEndTime;
    property Status: TPureTestStatus read GetStatus;
    property Details: TPureTestStatusDetails read GetDetails;
  end;

  TPureFixtureProc = reference to procedure;
  TPureTestExecuteProc = reference to procedure;

  TPureTestFixture<TFix> = class(TPureTestObject, IPureTestFixture)
  public type

    TPureTest<T> = class(TPureTestObject, IPureTest)
    public type

      TPureTestStep = class(TPureTestObject, IPureTestStep)
      public
        Test: TPureTest<T>;
      public
        constructor Create(ATest: TPureTest<T>; const AName: string; const ADescription: string = '');

        function GetTest: IPureTest;
      end;

      TSteps = TArray<TPureTestStep>;
    private
      fSteps: TSteps;
        fSeverity: TPureSeverityLevel;

      procedure PushStep(AStep: TPureTestStep);
      function PopStep: TPureTestStep;
      function PeekStep: TPureTestStep;
      procedure AbortSteps;
      procedure SetSeverity(const Value: TPureSeverityLevel);
      function GetSeverity: TPureSeverityLevel;
    public
      Data: T;
      Fixture: TPureTestFixture<TFix>;
    public
      constructor Create(AFixture: TPureTestFixture<TFix>; const AName: string; const ADescription: string = '');

      property Severity: TPureSeverityLevel read GetSeverity write SetSeverity;
      procedure AddTestClass(const Value: string);
      procedure AddTestMethod(const Value: string);
      procedure AddIssue(const IssueID: string; const IssueLink: string = '');
      procedure AddLink(const Uri: string; const LinkName: string = '');
      procedure AddEpic(const Value: string);
      procedure AddFeature(const Value: string);
      procedure AddStory(const Value: string);
      procedure MarkFlaky;
      procedure MarkMuted;
      procedure MarkKnown;

      procedure Execute(TestBodyProc: TPureTestExecuteProc);

      function BeginStep(const Name: string; const Description: string = ''): TPureTestStep;

      procedure EndStep;

      procedure EndTest;

      function GetFixture: IPureTestFixture;
    end;

    TPureTest = TPureTest<Pointer>;

  public
    Data: TFix;
    Context: TPureTests;
  public
    constructor Create(AContext: TPureTests; const AName: string; const ADescription: string = '');

    procedure Setup(SetupProc: TPureFixtureProc);
    procedure TearDown(TearDownProc: TPureFixtureProc);

    function BeginTest<T>(const Name: string; const Description: string = ''): TPureTest<T>; overload;
    function BeginTest(const Name: string; const Description: string = ''): TPureTest; overload;

    procedure EndTestFixture; overload;
    procedure EndTestFixture(TearDownProc: TPureFixtureProc); overload;

    function GetContext: IPureTestsContext;
  end;

  TPureTestFixture = TPureTestFixture<Pointer>;

  TTestProcedure = reference to procedure;

  IPureTestsFilter = interface
  ['{FE8D59F6-E47A-4F05-BA15-0471BFCCA004}']
    function TestMatch(const Test: IPureTest): Boolean;
    function FixtureMatch(const Fixture: IPureTestFixture): Boolean;
  end;

  TPureTests = class(TInterfacedObject, IPureTestsContext)
  private class var
    fContext: TPureTests;
  private
    fListeners: TPureTestsListeners;
    fTestProcs: TArray<TTestProcedure>;
    fFilter: IPureTestsFilter;
    fRunResults: TPureTestsRunResults;
    function GetListeners: TPureTestsListeners;
    class function GetContext: TPureTests; static;
    procedure ExecuteTest<TFix, T>(Test: TPureTestFixture<TFix>.TPureTest<T>; TestBodyProc: TPureTestExecuteProc);
    procedure SetupFixture<TFix>(Fixture: TPureTestFixture<TFix>; SetupProc: TPureFixtureProc);
    procedure TearDownFixture<TFix>(Fixture: TPureTestFixture<TFix>; TearDownProc: TPureFixtureProc);
  public
    class property Context: TPureTests read GetContext;
  public
    function GetRunResults: TPureTestsRunResults;
    property RunResults: TPureTestsRunResults read GetRunResults;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Initialize;
    procedure Finalize;

    property Listeners: TPureTestsListeners read GetListeners;

    procedure RegTestProc(AProc: TTestProcedure);

    function RunTests(const Filter: IPureTestsFilter = nil): Integer;

    function BeginTestFixture<TFix>(const Name: string; const Description: string = ''): TPureTestFixture<TFix>; overload;
    function BeginTestFixture(const Name: string; const Description: string = ''): TPureTestFixture; overload;
  end;

  IPureTestsListener = interface
  ['{1475065F-D02F-48BA-8E1E-DEBEFB090652}']

    // Called at the start of testing.
    procedure OnTestingStarts(const Context: IPureTestsContext);

    // Called before a Fixture is run.
    procedure OnStartTestFixture(const Fixture: IPureTestFixture);

    // Called before a fixture Setup method is run
    procedure OnBeforeSetupFixture(const Fixture: IPureTestFixture);

    // Called after a fixture setup method is run.
    procedure OnAfterSetupFixture(const Fixture: IPureTestFixture);

    // Called after a Test is created.
    procedure OnBeginTest(const Test: IPureTest);

    // Called before a Test.Execute method is run.
    procedure OnBeforeExecuteTest(const Test: IPureTest);

    // Called before a Step is run.
    procedure OnBeforeStep(const Step: IPureTestStep);

    // Called after a Step is run.
    procedure OnAfterStep(const Step: IPureTestStep);

    // Called after a Test.Execute method is run.
    procedure OnAfterExecuteTest(const Test: IPureTest);

    // Called before destroing a test.
    procedure OnEndTest(const Test: IPureTest);

    // Called before a Fixture Teardown method is called.
    procedure OnBeforeTearDownFixture(const Fixture: IPureTestFixture);

    // Called after a Fixture Teardown method is called.
    procedure OnAfterTearDownFixture(const Fixture: IPureTestFixture);

    // Called after a Fixture has run.
    procedure OnEndTestFixture(const Fixture: IPureTestFixture);

    // Called after all fixtures have run.
    procedure OnTestingEnds(const Context: IPureTestsContext);

  end;

  IPureTestsAdvancedListener = interface(IPureTestsListener)
  ['{D949F305-2608-4A22-821B-CBF0A275502B}']
    procedure AddTestClass(const Test: IPureTest; const Value: string);
    procedure AddTestMethod(const Test: IPureTest; const Value: string);
    procedure AddIssue(const Test: IPureTest; const IssueID: string; const IssueLink: string = '');
    procedure AddLink(const Test: IPureTest; const Uri: string; const LinkName: string = '');
    procedure AddEpic(const Test: IPureTest; const Value: string);
    procedure AddFeature(const Test: IPureTest; const Value: string);
    procedure AddStory(const Test: IPureTest; const Value: string);
    procedure MarkFlaky(const Test: IPureTest);
    procedure MarkMuted(const Test: IPureTest);
    procedure MarkKnown(const Test: IPureTest);
  end;

  TPureTestsListeners = class(TInterfacedObject{, IPureTestsListener})
  private
    type
      TNotifyProc = reference to procedure (const AListener: IPureTestsListener);
      TNotifyAdvProc = reference to procedure (const AListener: IPureTestsAdvancedListener);
    var
    fList: TArray<IPureTestsListener>;
    procedure NotifyAll(AProc: TNotifyProc);
    procedure NotifyAllAdvanced(AProc: TNotifyAdvProc);
  public
    constructor Create;
    destructor Destroy; override;

    procedure Add(const AListener: IPureTestsListener);

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

    //IPureTestsAdvancedListener
    procedure AddTestClass(const Test: IPureTest; const Value: string);
    procedure AddTestMethod(const Test: IPureTest; const Value: string);
    procedure AddIssue(const Test: IPureTest; const IssueID: string; const IssueLink: string = '');
    procedure AddLink(const Test: IPureTest; const Uri: string; const LinkName: string = '');
    procedure AddEpic(const Test: IPureTest; const Value: string);
    procedure AddFeature(const Test: IPureTest; const Value: string);
    procedure AddStory(const Test: IPureTest; const Value: string);
    procedure MarkFlaky(const Test: IPureTest);
    procedure MarkMuted(const Test: IPureTest);
    procedure MarkKnown(const Test: IPureTest);
  end;

  Assert = class(pureTestAssert.Assert);

implementation

{ TPureTestsContext }

function TPureTests.BeginTestFixture(const Name,
  Description: string): TPureTestFixture;
begin
  result := BeginTestFixture<Pointer>(Name, Description);
end;

function TPureTests.BeginTestFixture<TFix>(const Name,
  Description: string): TPureTestFixture<TFix>;
begin
  result := TPureTestFixture<TFix>.Create(self, Name, Description);
  fListeners.OnStartTestFixture(result);
end;

constructor TPureTests.Create;
begin
  inherited Create;
  fListeners := TPureTestsListeners.Create;
  fListeners._AddRef;
end;

destructor TPureTests.Destroy;
begin
  fListeners._Release;
  inherited;
end;

procedure TPureTests.ExecuteTest<TFix, T>(Test: TPureTestFixture<TFix>.TPureTest<T>;
  TestBodyProc: TPureTestExecuteProc);
begin
  fListeners.OnBeforeExecuteTest(Test);
  try
    try
      if Test.Fixture.Status=ptsBroken then begin
        Test.fStatus := ptsBroken;
        Test.fDetails := Test.Fixture.Details;
      end else begin
        if (fFilter=nil) or
           (fFilter.FixtureMatch(Test.Fixture) and fFilter.TestMatch(Test))
        then begin
          Test.fStartTime := Now;
          try
            TestBodyProc();
            Test.fStatus := ptsPassed;
          finally
            Test.fEndTime := Now;
          end;
        end;
      end;
    except
      on E: Exception do begin
        if E is EPureTestFailure then
          Test.fStatus := ptsFailed
        else if E is EPureTestPass then
          Test.fStatus := ptsPassed
        else
          Test.fStatus := ptsBroken;
        Test.fDetails.Msg := E.Message;
        Test.fDetails.StackTrace := E.StackTrace;
        Test.AbortSteps;
      end;
    end;
  finally
    fListeners.OnAfterExecuteTest(Test);
  end;
end;

procedure TPureTests.Finalize;
begin
  self._Release;
end;

class function TPureTests.GetContext: TPureTests;
begin
  if fContext=nil then begin
    try
      fContext := TPureTests.Create;
      fContext.Initialize;
    except
    end;
  end;
  result := fContext;
end;

function TPureTests.GetListeners: TPureTestsListeners;
begin
  result := fListeners;
end;

function TPureTests.GetRunResults: TPureTestsRunResults;
begin
  result := fRunResults;
end;

procedure TPureTests.Initialize;
begin
  self._AddRef;
end;

procedure TPureTests.RegTestProc(AProc: TTestProcedure);
var
  n: Integer;
begin
  n := Length(fTestProcs);
  SetLength(fTestProcs, succ(n));
  fTestProcs[n] := AProc;
end;

function TPureTests.RunTests(const Filter: IPureTestsFilter = nil): Integer;
var
  proc: TTestProcedure;
begin
  fFilter := Filter;
  fRunResults.Clear;
  fListeners.OnTestingStarts(self);
  try
    for proc in fTestProcs do begin
      try
        proc();
      except
      end;
    end;
  finally
    result := fRunResults.BrokenTestCount + fRunResults.FailedTestCount;
    fListeners.OnTestingEnds(self);
  end;
end;

procedure TPureTests.SetupFixture<TFix>(Fixture: TPureTestFixture<TFix>;
  SetupProc: TPureFixtureProc);
begin
  fListeners.OnBeforeSetupFixture(Fixture);
  try
    try
      if (fFilter=nil) or fFilter.FixtureMatch(Fixture) then begin
        SetupProc();
        Fixture.fStatus := ptsPassed;
      end;
    except
      on E: Exception do begin
        Fixture.fStatus := ptsBroken;
        Fixture.fDetails.Msg := E.Message;
        Fixture.fDetails.StackTrace := E.StackTrace;
      end;
    end;
  finally
    fListeners.OnAfterSetupFixture(Fixture);
  end;
end;

procedure TPureTests.TearDownFixture<TFix>(
  Fixture: TPureTestFixture<TFix>; TearDownProc: TPureFixtureProc);
begin
  fListeners.OnBeforeTearDownFixture(Fixture);
  try
    try
      if (Fixture.Status<>ptsBroken) and
         ((fFilter=nil) or fFilter.FixtureMatch(Fixture))
      then begin
        TearDownProc();
      end;
    except
      on E: Exception do begin
        Fixture.fStatus := ptsBroken;
        Fixture.fDetails.Msg := E.Message;
        Fixture.fDetails.StackTrace := E.StackTrace;
      end;
    end;
  finally
    fListeners.OnAfterTearDownFixture(Fixture);
  end;
end;

{ TPureTestFixture<TFix> }

function TPureTestFixture<TFix>.BeginTest(const Name,
  Description: string): TPureTest;
begin
  result := BeginTest<Pointer>(Name, Description);
end;

function TPureTestFixture<TFix>.BeginTest<T>(const Name,
  Description: string): TPureTest<T>;
begin
  result := TPureTest<T>.Create(self, Name, Description);
  Context.fListeners.OnBeginTest(result);
end;

constructor TPureTestFixture<TFix>.Create(AContext: TPureTests;
  const AName, ADescription: string);
begin
  inherited Create;
  Context := AContext;
  fName := AName;
  fDescription := ADescription;
  fStartTime := Now;
end;

procedure TPureTestFixture<TFix>.EndTestFixture(TearDownProc: TPureFixtureProc);
begin
  TearDown(TearDownProc);
  EndTestFixture;
end;

function TPureTestFixture<TFix>.GetContext: IPureTestsContext;
begin
  result := Context;
end;

procedure TPureTestFixture<TFix>.EndTestFixture;
begin
  fEndTime := Now;
  inc(Context.fRunResults.FixtureCount);
  Context.fListeners.OnEndTestFixture(self);
  Free;
end;

procedure TPureTestFixture<TFix>.Setup(SetupProc: TPureFixtureProc);
begin
  Context.SetupFixture<TFix>(self, SetupProc);
end;

procedure TPureTestFixture<TFix>.TearDown(TearDownProc: TPureFixtureProc);
begin
  Context.TearDownFixture<TFix>(self, TearDownProc);
end;

{ TPureTestFixture<TFix>.TPureTest<T> }

procedure TPureTestFixture<TFix>.TPureTest<T>.AbortSteps;
var
  step: TPureTestStep;
  i: Integer;
begin
  for i := High(fSteps) downto 0 do begin
    step := fSteps[i];
    step.fEndTime := Now;
    step.fStatus := self.Status;
    step.fDetails := self.Details;
    Fixture.Context.fListeners.OnAfterStep(step);
    step.Free;
  end;
  fSteps := nil;
end;

procedure TPureTestFixture<TFix>.TPureTest<T>.AddEpic(const Value: string);
begin
  Fixture.Context.fListeners.AddEpic(self, Value);
end;

procedure TPureTestFixture<TFix>.TPureTest<T>.AddFeature(const Value: string);
begin
  Fixture.Context.fListeners.AddFeature(self, Value);
end;

procedure TPureTestFixture<TFix>.TPureTest<T>.AddIssue(const IssueID,
  IssueLink: string);
begin
  Fixture.Context.fListeners.AddIssue(self, IssueID, IssueLink);
end;

procedure TPureTestFixture<TFix>.TPureTest<T>.AddLink(const Uri,
  LinkName: string);
begin
  Fixture.Context.fListeners.AddLink(self, Uri, LinkName);
end;

procedure TPureTestFixture<TFix>.TPureTest<T>.AddStory(const Value: string);
begin
  Fixture.Context.fListeners.AddStory(self, Value);
end;

procedure TPureTestFixture<TFix>.TPureTest<T>.AddTestClass(const Value: string);
begin
  Fixture.Context.fListeners.AddTestClass(self, Value);
end;

procedure TPureTestFixture<TFix>.TPureTest<T>.AddTestMethod(
  const Value: string);
begin
  Fixture.Context.fListeners.AddTestMethod(self, Value);
end;

function TPureTestFixture<TFix>.TPureTest<T>.BeginStep(const Name,
  Description: string): TPureTestStep;
begin
  PushStep(TPureTestStep.Create(self, Name, Description));
  result := PeekStep;
  Fixture.Context.fListeners.OnBeforeStep(result);
end;

constructor TPureTestFixture<TFix>.TPureTest<T>.Create(
  AFixture: TPureTestFixture<TFix>; const AName, ADescription: string);
begin
  inherited Create;
  Fixture := AFixture;
  fName := AName;
  fDescription := ADescription;
  fSeverity := pslNormal;
end;

procedure TPureTestFixture<TFix>.TPureTest<T>.EndStep;
var
  step: TPureTestStep;
begin
  step := PopStep;
  if step<>nil then begin
    step.fEndTime := Now;
    step.fStatus := ptsPassed;
    Fixture.Context.fListeners.OnAfterStep(step);
    step.Free;
  end;
end;

procedure TPureTestFixture<TFix>.TPureTest<T>.EndTest;
var
  step: TPureTestStep;
begin
  inc(Fixture.Context.fRunResults.TotalTestCount);
  case Status of
    //ptsNone,
    ptsFailed: inc(Fixture.Context.fRunResults.FailedTestCount);
    ptsBroken: inc(Fixture.Context.fRunResults.BrokenTestCount);
    ptsPassed: inc(Fixture.Context.fRunResults.PassedTestCount);
    ptsSkipped: inc(Fixture.Context.fRunResults.SkippedTestCount);
  end;
  Fixture.Context.fListeners.OnEndTest(self);
  for step in fSteps do
    step.Free;
  Free;
end;

procedure TPureTestFixture<TFix>.TPureTest<T>.Execute(
  TestBodyProc: TPureTestExecuteProc);
begin
  Fixture.Context.ExecuteTest<TFix, T>(self, TestBodyProc);
end;

function TPureTestFixture<TFix>.TPureTest<T>.GetFixture: IPureTestFixture;
begin
  result := Fixture;
end;

function TPureTestFixture<TFix>.TPureTest<T>.GetSeverity: TPureSeverityLevel;
begin
  result := fSeverity;
end;

procedure TPureTestFixture<TFix>.TPureTest<T>.MarkFlaky;
begin
  Fixture.Context.fListeners.MarkFlaky(self);
end;

procedure TPureTestFixture<TFix>.TPureTest<T>.MarkKnown;
begin
  Fixture.Context.fListeners.MarkKnown(self);
end;

procedure TPureTestFixture<TFix>.TPureTest<T>.MarkMuted;
begin
  Fixture.Context.fListeners.MarkMuted(self);
end;

function TPureTestFixture<TFix>.TPureTest<T>.PeekStep: TPureTestStep;
var
  n: Integer;
begin
  n := Length(fSteps);
  if n>0 then begin
    result := fSteps[n-1];
  end else
    result := nil;
end;

function TPureTestFixture<TFix>.TPureTest<T>.PopStep: TPureTestStep;
var
  n: Integer;
begin
  n := Length(fSteps);
  if n>0 then begin
    dec(n);
    result := fSteps[n];
    SetLength(fSteps, n);
  end else
    result := nil;
end;

procedure TPureTestFixture<TFix>.TPureTest<T>.PushStep(AStep: TPureTestStep);
var
  n: Integer;
begin
  n := Length(fSteps);
  SetLength(fSteps, n+1);
  fSteps[n] := AStep;
end;

procedure TPureTestFixture<TFix>.TPureTest<T>.SetSeverity(
  const Value: TPureSeverityLevel);
begin
  fSeverity := Value;
end;

{ TPureTestFixture<TFix>.TPureTest<T>.TPureTestStep }

constructor TPureTestFixture<TFix>.TPureTest<T>.TPureTestStep.Create(
  ATest: TPureTest<T>; const AName, ADescription: string);
begin
  inherited Create;
  Test := ATest;
  fName := AName;
  fDescription := ADescription;
  fStartTime := Now;
end;

function TPureTestFixture<TFix>.TPureTest<T>.TPureTestStep.GetTest: IPureTest;
begin
  result := Test;
end;

{ TPureTestObject }

constructor TPureTestObject.Create;
begin
  inherited Create;
  _AddRef;
end;

destructor TPureTestObject.Destroy;
begin
  inherited;
end;

procedure TPureTestObject.Free;
begin
  if self<>nil then begin
    self._Release;
  end;
end;

function TPureTestObject.GetDescription: string;
begin
  result := fDescription;
end;

function TPureTestObject.GetDetails: TPureTestStatusDetails;
begin
  result := fDetails;
end;

function TPureTestObject.GetEndTime: TDateTime;
begin
  result := fEndTime;
end;

function TPureTestObject.GetName: string;
begin
  result := fName;
end;

function TPureTestObject.GetStartTime: TDateTime;
begin
  result := fStartTime;
end;

function TPureTestObject.GetStatus: TPureTestStatus;
begin
  result := fStatus;
end;

{ TPureTestsListeners }

procedure TPureTestsListeners.Add(const AListener: IPureTestsListener);
var
  n: Integer;
begin
  n := Length(fList);
  SetLength(fList, n+1);
  fList[n] := AListener;
end;

procedure TPureTestsListeners.AddEpic(const Test: IPureTest;
  const Value: string);
begin
  NotifyAllAdvanced(
    procedure (const AListener: IPureTestsAdvancedListener)
    begin
      AListener.AddEpic(Test, Value);
    end
  );
end;

procedure TPureTestsListeners.AddFeature(const Test: IPureTest;
  const Value: string);
begin
  NotifyAllAdvanced(
    procedure (const AListener: IPureTestsAdvancedListener)
    begin
      AListener.AddFeature(Test, Value);
    end
  );
end;

procedure TPureTestsListeners.AddIssue(const Test: IPureTest; const IssueID,
  IssueLink: string);
begin
  NotifyAllAdvanced(
    procedure (const AListener: IPureTestsAdvancedListener)
    begin
      AListener.AddIssue(Test, IssueID, IssueLink);
    end
  );
end;

procedure TPureTestsListeners.AddLink(const Test: IPureTest; const Uri,
  LinkName: string);
begin
  NotifyAllAdvanced(
    procedure (const AListener: IPureTestsAdvancedListener)
    begin
      AListener.AddLink(Test, Uri, LinkName);
    end
  );
end;

procedure TPureTestsListeners.AddStory(const Test: IPureTest;
  const Value: string);
begin
  NotifyAllAdvanced(
    procedure (const AListener: IPureTestsAdvancedListener)
    begin
      AListener.AddStory(Test, Value);
    end
  );
end;

procedure TPureTestsListeners.AddTestClass(const Test: IPureTest;
  const Value: string);
begin
  NotifyAllAdvanced(
    procedure (const AListener: IPureTestsAdvancedListener)
    begin
      AListener.AddTestClass(Test, Value);
    end
  );
end;

procedure TPureTestsListeners.AddTestMethod(const Test: IPureTest;
  const Value: string);
begin
  NotifyAllAdvanced(
    procedure (const AListener: IPureTestsAdvancedListener)
    begin
      AListener.AddTestMethod(Test, Value);
    end
  );
end;

constructor TPureTestsListeners.Create;
begin
  inherited Create;
end;

destructor TPureTestsListeners.Destroy;
begin
  fList := nil;
  inherited;
end;

procedure TPureTestsListeners.MarkFlaky(const Test: IPureTest);
begin
  NotifyAllAdvanced(
    procedure (const AListener: IPureTestsAdvancedListener)
    begin
      AListener.MarkFlaky(Test);
    end
  );
end;

procedure TPureTestsListeners.MarkKnown(const Test: IPureTest);
begin
  NotifyAllAdvanced(
    procedure (const AListener: IPureTestsAdvancedListener)
    begin
      AListener.MarkKnown(Test);
    end
  );
end;

procedure TPureTestsListeners.MarkMuted(const Test: IPureTest);
begin
  NotifyAllAdvanced(
    procedure (const AListener: IPureTestsAdvancedListener)
    begin
      AListener.MarkMuted(Test);
    end
  );
end;

procedure TPureTestsListeners.NotifyAll(AProc: TNotifyProc);
var
  AListener: IPureTestsListener;
begin
  for AListener in fList do begin
    AProc(AListener);
  end;
end;

procedure TPureTestsListeners.NotifyAllAdvanced(AProc: TNotifyAdvProc);
var
  AListener: IPureTestsListener;
  AAdvListener: IPureTestsAdvancedListener;
begin
  for AListener in fList do begin
    if AListener.QueryInterface(IPureTestsAdvancedListener, AAdvListener)=0 then begin
      AProc(AAdvListener);
    end;
  end;
end;

procedure TPureTestsListeners.OnAfterExecuteTest(const Test: IPureTest);
begin
  NotifyAll(
    procedure (const AListener: IPureTestsListener)
    begin
      AListener.OnAfterExecuteTest(Test);
    end
  );
end;

procedure TPureTestsListeners.OnAfterSetupFixture(
  const Fixture: IPureTestFixture);
begin
  NotifyAll(
    procedure (const AListener: IPureTestsListener)
    begin
      AListener.OnAfterSetupFixture(Fixture);
    end
  );
end;

procedure TPureTestsListeners.OnAfterStep(const Step: IPureTestStep);
begin
  NotifyAll(
    procedure (const AListener: IPureTestsListener)
    begin
      AListener.OnAfterStep(Step);
    end
  );
end;

procedure TPureTestsListeners.OnAfterTearDownFixture(
  const Fixture: IPureTestFixture);
begin
  NotifyAll(
    procedure (const AListener: IPureTestsListener)
    begin
      AListener.OnAfterTearDownFixture(Fixture);
    end
  );
end;

procedure TPureTestsListeners.OnBeforeExecuteTest(const Test: IPureTest);
begin
  NotifyAll(
    procedure (const AListener: IPureTestsListener)
    begin
      AListener.OnBeforeExecuteTest(Test);
    end
  );
end;

procedure TPureTestsListeners.OnBeforeSetupFixture(
  const Fixture: IPureTestFixture);
begin
  NotifyAll(
    procedure (const AListener: IPureTestsListener)
    begin
      AListener.OnBeforeSetupFixture(Fixture);
    end
  );
end;

procedure TPureTestsListeners.OnBeforeStep(const Step: IPureTestStep);
begin
  NotifyAll(
    procedure (const AListener: IPureTestsListener)
    begin
      AListener.OnBeforeStep(Step);
    end
  );
end;

procedure TPureTestsListeners.OnBeforeTearDownFixture(
  const Fixture: IPureTestFixture);
begin
  NotifyAll(
    procedure (const AListener: IPureTestsListener)
    begin
      AListener.OnBeforeTearDownFixture(Fixture);
    end
  );
end;

procedure TPureTestsListeners.OnBeginTest(const Test: IPureTest);
begin
  NotifyAll(
    procedure (const AListener: IPureTestsListener)
    begin
      AListener.OnBeginTest(Test);
    end
  );
end;

procedure TPureTestsListeners.OnEndTest(const Test: IPureTest);
begin
  NotifyAll(
    procedure (const AListener: IPureTestsListener)
    begin
      AListener.OnEndTest(Test);
    end
  );
end;

procedure TPureTestsListeners.OnEndTestFixture(const Fixture: IPureTestFixture);
begin
  NotifyAll(
    procedure (const AListener: IPureTestsListener)
    begin
      AListener.OnEndTestFixture(Fixture);
    end
  );
end;

procedure TPureTestsListeners.OnStartTestFixture(
  const Fixture: IPureTestFixture);
begin
  NotifyAll(
    procedure (const AListener: IPureTestsListener)
    begin
      AListener.OnStartTestFixture(Fixture);
    end
  );
end;

procedure TPureTestsListeners.OnTestingEnds(const Context: IPureTestsContext);
begin
  NotifyAll(
    procedure (const AListener: IPureTestsListener)
    begin
      AListener.OnTestingEnds(Context);
    end
  );
end;

procedure TPureTestsListeners.OnTestingStarts(const Context: IPureTestsContext);
begin
  NotifyAll(
    procedure (const AListener: IPureTestsListener)
    begin
      AListener.OnTestingStarts(Context);
    end
  );
end;

{ TPureTestsRunResults }

{ TPureTestsRunResults }

procedure TPureTestsRunResults.Clear;
begin
  FailedTestCount := 0;
  BrokenTestCount := 0;
  PassedTestCount := 0;
  SkippedTestCount := 0;
  TotalTestCount := 0;
  FixtureCount := 0;
end;

end.
