unit allureDUnitXLogger;

interface

uses
  System.RTTI, DUnitX.TestFramework, allureDelphiInterface, allureDelphiHelper,
  System.SysUtils, MethodsInterceptor, DUnitX.Extensibility;

type

  TDUnitXAllureLogger = class(TInterfacedObject, ITestLogger)
  private
    fConfigFileName: string;
    fMethodsInterceptor: TMethodsInterceptor;

    function Cast(const intf: IUnknown; const IID: TGUID; out Res): Boolean;
    function IsSupportedFixture(const Fixture: ITestFixtureInfo): Boolean;
    function CreateContainerOfFixture(const Fixture: ITestFixtureInfo): IAllureTestResultContainer;
    function CreateBeforeFixture(const Fixture: ITestFixtureInfo): IAllureFixtureResult;
    function CreateTestResult(const Test: ITestInfo): IAllureTestResult;
    function CreateStepBeforeTest(const Test: ITestInfo): IAllureStepResult;
    function CreateBodyStepOfTest(const Test: ITestInfo): IAllureStepResult;
    function CreateStepAfterTest(const Test: ITestInfo): IAllureStepResult;
    function CreateAfterFixture(const Fixture: ITestFixtureInfo): IAllureFixtureResult;

    // Have to call it manually because DUnitX really do not do it
    procedure DoOnEndTeardownTest(const threadId: TThreadID; const Test: ITestInfo);
    // Have to call it manually because DUnitX really do not do it
    procedure DoOnEndTearDownFixture(const threadId: TThreadID; const fixture: ITestFixtureInfo);


    procedure BeforeFixtureMethodCall(Instance: TObject; Method: TRttiMethod;
      const Args: TArray<TValue>; out DoInvoke: Boolean; out Result: TValue);
    procedure AfterFixtureMethodCall(Instance: TObject; Method: TRttiMethod;
      const Args: TArray<TValue>; var Result: TValue);
    procedure HandleExceptionInFixtureMethod(Instance: TObject; Method: TRttiMethod;
      const Args: TArray<TValue>; out RaiseException: Boolean;
      TheException: Exception; out Result: TValue);
    procedure ProxifyFixture(const Fixture: ITestFixtureInfo; Back: Boolean = false);

    procedure SetConfigFileName(const Value: string);
  public
    constructor Create;
    destructor Destroy; override;

    property ConfigFileName: string read fConfigFileName write SetConfigFileName;
  public

    ///	<summary>
    ///	  Called at the start of testing. The default console logger prints the
    ///	  DUnitX banner.
    ///	</summary>
    procedure OnTestingStarts(const threadId: TThreadID; testCount, testActiveCount: Cardinal);

    ///	<summary>
    ///	  //Called before a Fixture is run.
    ///	</summary>
    procedure OnStartTestFixture(const threadId: TThreadID; const fixture: ITestFixtureInfo);

    ///	<summary>
    ///	  //Called before a fixture Setup method is run
    ///	</summary>
    procedure OnSetupFixture(const threadId: TThreadID; const fixture: ITestFixtureInfo);

    ///	<summary>
    ///	  Called after a fixture setup method is run.
    ///	</summary>
    procedure OnEndSetupFixture(const threadId: TThreadID; const fixture: ITestFixtureInfo);

    ///	<summary>
    ///	  Called before a Test method is run.
    ///	</summary>
    procedure OnBeginTest(const threadId: TThreadID; const Test: ITestInfo);

    ///	<summary>
    ///	  Called before a test setup method is run.
    ///	</summary>
    procedure OnSetupTest(const threadId: TThreadID; const Test: ITestInfo);

    ///	<summary>
    ///	  Called after a test setup method is run.
    ///	</summary>
    procedure OnEndSetupTest(const threadId: TThreadID; const Test: ITestInfo);

    ///	<summary>
    ///	  Called before a Test method is run.
    ///	</summary>
    procedure OnExecuteTest(const threadId: TThreadID; const Test: ITestInfo);

    ///	<summary>
    ///	  Called when a test succeeds
    ///	</summary>
    procedure OnTestSuccess(const threadId: TThreadID; const Test: ITestResult);

    ///	<summary>
    ///	  Called when a test errors.
    ///	</summary>
    procedure OnTestError(const threadId: TThreadID; const Error: ITestError);

    ///	<summary>
    ///	  Called when a test fails.
    ///	</summary>
    procedure OnTestFailure(const threadId: TThreadID; const Failure: ITestError);

    /// <summary>
    ///   called when a test is ignored.
    /// </summary>
    procedure OnTestIgnored(const threadId: TThreadID; const AIgnored: ITestResult);

    /// <summary>
    ///   called when a test memory leaks.
    /// </summary>
    procedure OnTestMemoryLeak(const threadId: TThreadID; const Test: ITestResult);

    /// <summary>
    ///   allows tests to write to the log.
    /// </summary>
    procedure OnLog(const logType: TLogLevel; const msg: string);

    /// <summary>
    ///   called before a Test Teardown method is run.
    /// </summary>
    procedure OnTeardownTest(const threadId: TThreadID; const Test: ITestInfo);

    /// <summary>
    ///   called after a test teardown method is run.
    /// </summary>
    procedure OnEndTeardownTest(const threadId: TThreadID; const Test: ITestInfo);

    /// <summary>
    ///   called after a test method and teardown is run.
    /// </summary>
    procedure OnEndTest(const threadId: TThreadID; const Test: ITestResult);

    /// <summary>
    ///   called before a Fixture Teardown method is called.
    /// </summary>
    procedure OnTearDownFixture(const threadId: TThreadID; const fixture: ITestFixtureInfo);

    /// <summary>
    ///   called after a Fixture Teardown method is called.
    /// </summary>
    procedure OnEndTearDownFixture(const threadId: TThreadID; const fixture: ITestFixtureInfo);

    /// <summary>
    ///   called after a Fixture has run.
    /// </summary>
    procedure OnEndTestFixture(const threadId: TThreadID; const results: IFixtureResult);

    /// <summary>
    ///   called after all fixtures have run.
    /// </summary>
    procedure OnTestingEnds(const RunResults: IRunResults);
  end;

implementation

{ TAllureDUnitXTestLogger }

procedure TDUnitXAllureLogger.AfterFixtureMethodCall(Instance: TObject;
  Method: TRttiMethod; const Args: TArray<TValue>; var Result: TValue);
begin
  Result := Result;
end;

procedure TDUnitXAllureLogger.BeforeFixtureMethodCall(Instance: TObject;
  Method: TRttiMethod; const Args: TArray<TValue>; out DoInvoke: Boolean;
  out Result: TValue);
begin
  if Instance<>nil then begin
    DoInvoke := true;
  end;
end;

function TDUnitXAllureLogger.Cast(const intf: IInterface; const IID: TGUID;
  out Res): Boolean;
begin
  result := (intf<>nil) and (intf.QueryInterface(IID, Res) = 0);
  if not result then
    pointer(res) := nil;
end;

constructor TDUnitXAllureLogger.Create;
begin
  inherited Create;
  fMethodsInterceptor := TMethodsInterceptor.Create;
  fMethodsInterceptor.OnBefore := BeforeFixtureMethodCall;
  fMethodsInterceptor.OnAfter := AfterFixtureMethodCall;
  fMethodsInterceptor.OnException := HandleExceptionInFixtureMethod;
end;

function TDUnitXAllureLogger.CreateAfterFixture(
  const Fixture: ITestFixtureInfo): IAllureFixtureResult;
begin
  result := Allure.Lifecycle.CreateFixture;
  result.Name := Fixture.TearDownFixtureMethodName;
end;

function TDUnitXAllureLogger.CreateBeforeFixture(
  const Fixture: ITestFixtureInfo): IAllureFixtureResult;
begin
  result := Allure.Lifecycle.CreateFixture;
  result.Name := Fixture.SetupFixtureMethodName;
end;

function TDUnitXAllureLogger.CreateBodyStepOfTest(
  const Test: ITestInfo): IAllureStepResult;
begin
  result := Allure.Lifecycle.CreateStepResult;
  result.Name := 'TestBody';
end;

function TDUnitXAllureLogger.CreateContainerOfFixture(const Fixture: ITestFixtureInfo): IAllureTestResultContainer;
begin
  result := nil;
  if Fixture=nil then exit;
  result := allure.Lifecycle.CreateTestResultContainer;
  result.Tag := TAllureTag(Fixture);
  result.Name := Fixture.Name;
  result.Description := Fixture.Description;
end;

function TDUnitXAllureLogger.CreateStepAfterTest(
  const Test: ITestInfo): IAllureStepResult;
begin
  result := Allure.Lifecycle.CreateStepResult;
  result.Name := 'TestTearDown';
end;

function TDUnitXAllureLogger.CreateStepBeforeTest(
  const Test: ITestInfo): IAllureStepResult;
begin
  result := Allure.Lifecycle.CreateStepResult;
  result.Name := 'TestSetup';
end;

function TDUnitXAllureLogger.CreateTestResult(
  const Test: ITestInfo): IAllureTestResult;
begin
  result := Allure.Lifecycle.CreateTestResult;
  result.Name := Test.Name;
  result.FullName := Test.FullName;
  result.HistoryID := TAllureUuidHelper.GenerateHistoryID(result.FullName);
  result.Tag := TAllureTag(Test);
  result.Labels.AddNew.SetPackage(ExtractFileName(GetModuleName(HInstance)));
  if Test.Fixture<>nil then begin
    result.Labels.AddNew.SetSuite(Test.Fixture.Name);
    if Test.Fixture.TestClass<>nil then
      result.Labels.AddNew.SetTestClass(Test.Fixture.TestClass.ClassName);
  end;
  if Test.MethodName<>'' then
    result.Labels.AddNew.SetTestMethod(Test.MethodName);
  result.Labels.AddNew.SetCurrentThread;
end;

destructor TDUnitXAllureLogger.Destroy;
begin
  fMethodsInterceptor.Free;
  inherited;
end;

procedure TDUnitXAllureLogger.DoOnEndTearDownFixture(const threadId: TThreadID;
  const fixture: ITestFixtureInfo);
begin
  if fixture.TearDownFixtureMethodName<>'' then begin
    try
      self.OnEndTearDownFixture(threadId, fixture);
    except
    end;
  end;
end;

procedure TDUnitXAllureLogger.DoOnEndTeardownTest(const threadId: TThreadID;
  const Test: ITestInfo);
begin
  if Test=nil then exit;
  if Test.Fixture.TearDownMethodName<>'' then begin
    try
      self.OnEndTeardownTest(threadId, Test);
    except
    end;
  end;
end;

procedure TDUnitXAllureLogger.HandleExceptionInFixtureMethod(Instance: TObject;
  Method: TRttiMethod; const Args: TArray<TValue>; out RaiseException: Boolean;
  TheException: Exception; out Result: TValue);
begin
  RaiseException := true;
end;

function TDUnitXAllureLogger.IsSupportedFixture(
  const Fixture: ITestFixtureInfo): Boolean;
begin
  result := (Fixture<>nil) and (Fixture.ActiveTestCount>0);
end;

procedure TDUnitXAllureLogger.OnBeginTest(const threadId: TThreadID;
  const Test: ITestInfo);
var
  tr: IAllureTestResult;
  container: IAllureTestResultContainer;
begin
  if not Test.Active then exit;
  Cast(Allure.Lifecycle.GetObjectOfTag(TAllureTag(Test.Fixture)), IAllureTestResultContainer, container);
  tr := CreateTestResult(Test);
  if container<>nil then
    Allure.Lifecycle.ScheduleTestCase(container.UUID, tr)
  else
    Allure.Lifecycle.ScheduleTestCase(tr);
  Allure.Lifecycle.StartTestCase(tr);
end;

procedure TDUnitXAllureLogger.OnEndSetupFixture(const threadId: TThreadID;
  const fixture: ITestFixtureInfo);
var
  beforeUuid: TAllureString;
  container: IAllureTestResultContainer;
begin
  if not IsSupportedFixture(fixture) then exit;
  if Cast(Allure.Lifecycle.GetObjectOfTag(TAllureTag(fixture)), IAllureTestResultContainer, container)
  then begin
    beforeUuid := Allure.Lifecycle.GetUuidOfCurrentObjectOfType(IAllureFixtureResult);
    if beforeUuid<>'' then
      Allure.Lifecycle.StopFixture(beforeUuid);
  end;
end;

procedure TDUnitXAllureLogger.OnEndSetupTest(const threadId: TThreadID;
  const Test: ITestInfo);
begin
  if not Test.Active then exit;
  Allure.Lifecycle.StopStep;
end;

procedure TDUnitXAllureLogger.OnEndTearDownFixture(
  const threadId: TThreadID; const fixture: ITestFixtureInfo);
var
  afterUuid: TAllureString;
  container: IAllureTestResultContainer;
begin
  if not IsSupportedFixture(fixture) then exit;
  if Cast(Allure.Lifecycle.GetObjectOfTag(TAllureTag(fixture)), IAllureTestResultContainer, container)
  then begin
    afterUuid := Allure.Lifecycle.GetUuidOfCurrentObjectOfType(IAllureFixtureResult);
    if afterUuid<>'' then
      Allure.Lifecycle.StopFixture(afterUuid);
  end;
end;

procedure TDUnitXAllureLogger.OnEndTeardownTest(const threadId: TThreadID;
  const Test: ITestInfo);
begin
  if not Test.Active then exit;
  Allure.Lifecycle.StopStep;
end;

procedure TDUnitXAllureLogger.OnEndTest(const threadId: TThreadID;
  const Test: ITestResult);
var
  tr: IAllureTestResult;
begin
  if not Test.Test.Active then exit;
  if Cast(Allure.Lifecycle.GetObjectOfTag(TAllureTag(Test.Test)), IAllureTestResult, tr) then begin
    Allure.Lifecycle.StopTestCase(tr.UUID);
    Allure.Lifecycle.WriteTestCase(tr.UUID);
  end;
end;

procedure TDUnitXAllureLogger.OnEndTestFixture(const threadId: TThreadID;
  const results: IFixtureResult);
var
  container: IAllureTestResultContainer;
begin
  //DoOnEndTearDownFixture(threadId, results.Fixture);
  if not IsSupportedFixture(results.fixture) then exit;
  if Cast(Allure.Lifecycle.GetObjectOfTag(TAllureTag(results.Fixture)), IAllureTestResultContainer, container)
  then begin
    Allure.Lifecycle.StopTestContainer(container.UUID);
    Allure.Lifecycle.WriteTestContainer(container.UUID);
  end;
  ProxifyFixture(results.Fixture, true);
end;

procedure TDUnitXAllureLogger.OnExecuteTest(const threadId: TThreadID;
  const Test: ITestInfo);
var
  body: IAllureStepResult;
begin
  if not Test.Active then exit;
//  body := CreateBodyStepOfTest(Test);
//  Allure.Lifecycle.StartStep(TAllureUuidHelper.CreateNew, body);
end;

procedure TDUnitXAllureLogger.OnLog(const logType: TLogLevel;
  const msg: string);
begin

end;

procedure TDUnitXAllureLogger.OnSetupFixture(const threadId: TThreadID;
  const fixture: ITestFixtureInfo);
var
  before: IAllureFixtureResult;
  container: IAllureTestResultContainer;
begin
  if not IsSupportedFixture(fixture) then exit;
  if Cast(Allure.Lifecycle.GetObjectOfTag(TAllureTag(fixture)), IAllureTestResultContainer, container)
  then begin
    before := CreateBeforeFixture(fixture);
    Allure.Lifecycle.StartBeforeFixture(container.UUID, TAllureUuidHelper.CreateNew, before);
  end;
end;

procedure TDUnitXAllureLogger.OnSetupTest(const threadId: TThreadID;
  const Test: ITestInfo);
var
  beforeTest: IAllureStepResult;
begin
  if not Test.Active then exit;
  beforeTest := CreateStepBeforeTest(Test);
  Allure.Lifecycle.StartStep(TAllureUuidHelper.CreateNew, beforeTest);
end;

procedure TDUnitXAllureLogger.OnStartTestFixture(const threadId: TThreadID;
  const fixture: ITestFixtureInfo);
var
  container: IAllureTestResultContainer;
begin
  if not IsSupportedFixture(fixture) then exit;
  container := CreateContainerOfFixture(fixture);
  Allure.Lifecycle.StartTestContainer(container);
  ProxifyFixture(fixture);
end;

procedure TDUnitXAllureLogger.OnTearDownFixture(const threadId: TThreadID;
  const fixture: ITestFixtureInfo);
var
  after: IAllureFixtureResult;
  container: IAllureTestResultContainer;
begin
  if not IsSupportedFixture(fixture) then exit;
  if Cast(Allure.Lifecycle.GetObjectOfTag(TAllureTag(fixture)), IAllureTestResultContainer, container)
  then begin
    after := CreateAfterFixture(fixture);
    Allure.Lifecycle.StartAfterFixture(container.UUID, TAllureUuidHelper.CreateNew, after);
  end;
end;

procedure TDUnitXAllureLogger.OnTeardownTest(const threadId: TThreadID;
  const Test: ITestInfo);
var
  afterTest: IAllureStepResult;
begin
  if not Test.Active then exit;
  afterTest := CreateStepAfterTest(Test);
  Allure.Lifecycle.StartStep(TAllureUuidHelper.CreateNew, afterTest);
end;

procedure TDUnitXAllureLogger.OnTestError(const threadId: TThreadID;
  const Error: ITestError);
var
  tr: IAllureTestResult;
  body: IAllureStepResult;
begin
  DoOnEndTeardownTest(threadId, Error.Test);
  if not Error.Test.Active then exit;
  // Stop body step
//  Allure.Lifecycle.StopStep;
  if Cast(Allure.Lifecycle.GetObjectOfTag(TAllureTag(Error.Test)), IAllureTestResult, tr) then begin
    tr.Status := asBroken;
//    if tr.Steps.StepCount>0 then begin
//      body := tr.Steps.Step[tr.Steps.StepCount-1];
//      body.Status := asBroken;
//      body.StatusDetails.Message := Error.Message;
//    end;
  end;
end;

procedure TDUnitXAllureLogger.OnTestFailure(const threadId: TThreadID;
  const Failure: ITestError);
var
  tr: IAllureTestResult;
  body: IAllureStepResult;
begin
  DoOnEndTeardownTest(threadId, Failure.Test);
  if not Failure.Test.Active then exit;
  // Stop body step
//  Allure.Lifecycle.StopStep;
  if Cast(Allure.Lifecycle.GetObjectOfTag(TAllureTag(Failure.Test)), IAllureTestResult, tr) then begin
    tr.Status := asFailed;
//    if tr.Steps.StepCount>0 then begin
//      body := tr.Steps.Step[tr.Steps.StepCount-1];
//      body.Status := asFailed;
//      body.StatusDetails.Message := Failure.Message;
//    end;
  end;
end;

procedure TDUnitXAllureLogger.OnTestIgnored(const threadId: TThreadID;
  const AIgnored: ITestResult);
begin

end;

procedure TDUnitXAllureLogger.OnTestingEnds(const RunResults: IRunResults);
begin
  Allure.Finalize;
end;

procedure TDUnitXAllureLogger.OnTestingStarts(const threadId: TThreadID;
  testCount, testActiveCount: Cardinal);
begin
  Allure.Initialize;
  if FileExists(ConfigFileName) then
    Allure.Lifecycle.AssignConfigFromFile(ConfigFileName);
  Allure.Lifecycle.CleanupResultDirectory;
end;

procedure TDUnitXAllureLogger.OnTestMemoryLeak(const threadId: TThreadID;
  const Test: ITestResult);
var
  tr: IAllureTestResult;
  body: IAllureStepResult;
begin
  DoOnEndTeardownTest(threadId, Test.Test);
  if not Test.Test.Active then exit;
  if Cast(Allure.Lifecycle.GetObjectOfTag(TAllureTag(Test.Test)), IAllureTestResult, tr) then begin
    tr.Status := asBroken;
//    if tr.Steps.StepCount>0 then begin
//      body := tr.Steps.Step[tr.Steps.StepCount-1];
//      body.Status := asBroken;
//      body.StatusDetails.Message := Test.Message
//    end;
  end;
end;

procedure TDUnitXAllureLogger.OnTestSuccess(const threadId: TThreadID;
  const Test: ITestResult);
var
  tr: IAllureTestResult;
  body: IAllureStepResult;
begin
  DoOnEndTeardownTest(threadId, Test.Test);
  if not Test.Test.Active then exit;
  // Stop body step
//  Allure.Lifecycle.StopStep;
  if Cast(Allure.Lifecycle.GetObjectOfTag(TAllureTag(Test.Test)), IAllureTestResult, tr) then begin
    tr.Status := asPassed;
    if tr.Steps.StepCount>0 then begin
      body := tr.Steps.Step[tr.Steps.StepCount-1];
      body.Status := asPassed;
    end;
  end;
end;

procedure TDUnitXAllureLogger.ProxifyFixture(const Fixture: ITestFixtureInfo;
  Back: Boolean);
var
  f: ITestFixture;
begin
  if Fixture=nil then exit;
  try
    if cast(Fixture, ITestFixture, f) and (f.FixtureInstance<>nil) then begin
      if Back then
        fMethodsInterceptor.Unproxify(f.FixtureInstance)
      else
        fMethodsInterceptor.Proxify(f.FixtureInstance);
    end;
  except
  end;
end;

procedure TDUnitXAllureLogger.SetConfigFileName(const Value: string);
begin
  fConfigFileName := Value;
end;

end.
