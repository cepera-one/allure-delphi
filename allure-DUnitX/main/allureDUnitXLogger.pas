unit allureDUnitXLogger;

interface

uses
  System.RTTI, DUnitX.TestFramework, allureDelphiInterface, allureDelphiHelper,
  System.SysUtils, MethodsInterceptor, DUnitX.Extensibility, DUnitX.Utils,
  DUnitX.TestFixture, allureAttributes, DUnitX.Exceptions, System.TypInfo,
  DUnitX.CommandLine.Options, System.IOUtils;

type

  TDUnitXAllureBaseLogger = class(TInterfacedObject, ITestLogger)
  private class var
    fRttiContext: TRttiContext;
    fConfigFileName: string;
    fDefaultResultsDir: string;
    fDefaultReportDir: string;
  protected
    function Cast(const intf: IUnknown; const IID: TGUID; out Res): Boolean;
    function IsSupportedFixture(const Fixture: ITestFixtureInfo): Boolean;
    function GetFixtureInstance(const Fixture: ITestFixtureInfo): Pointer;
    function CreateContainerOfFixture(const Fixture: ITestFixtureInfo): IAllureTestResultContainer;
    function CreateTestResult(const Test: ITestInfo): IAllureTestResult;
    procedure FillAttributes(const TestObj: IUnknown; const Attributes: TArray<TCustomAttribute>);
  public
    class constructor CreateClass;
    class destructor DestroyClass;

    constructor Create;
    destructor Destroy; override;

    class property ConfigFileName: string read fConfigFileName write fConfigFileName;
    class property DefaultResultsDir: string read fDefaultResultsDir;
    class property DefaultReportDir: string read fDefaultReportDir;

    class procedure RegisterOptions; static;
  public

    ///	<summary>
    ///	  Called at the start of testing. The default console logger prints the
    ///	  DUnitX banner.
    ///	</summary>
    procedure OnTestingStarts(const threadId: TThreadID; testCount, testActiveCount: Cardinal); virtual;

    ///	<summary>
    ///	  //Called before a Fixture is run.
    ///	</summary>
    procedure OnStartTestFixture(const threadId: TThreadID; const fixture: ITestFixtureInfo); virtual;

    ///	<summary>
    ///	  //Called before a fixture Setup method is run
    ///	</summary>
    procedure OnSetupFixture(const threadId: TThreadID; const fixture: ITestFixtureInfo); virtual;

    ///	<summary>
    ///	  Called after a fixture setup method is run.
    ///	</summary>
    procedure OnEndSetupFixture(const threadId: TThreadID; const fixture: ITestFixtureInfo); virtual;

    ///	<summary>
    ///	  Called before a Test method is run.
    ///	</summary>
    procedure OnBeginTest(const threadId: TThreadID; const Test: ITestInfo); virtual;

    ///	<summary>
    ///	  Called before a test setup method is run.
    ///	</summary>
    procedure OnSetupTest(const threadId: TThreadID; const Test: ITestInfo); virtual;

    ///	<summary>
    ///	  Called after a test setup method is run.
    ///	</summary>
    procedure OnEndSetupTest(const threadId: TThreadID; const Test: ITestInfo); virtual;

    ///	<summary>
    ///	  Called before a Test method is run.
    ///	</summary>
    procedure OnExecuteTest(const threadId: TThreadID; const Test: ITestInfo); virtual;

    ///	<summary>
    ///	  Called when a test succeeds
    ///	</summary>
    procedure OnTestSuccess(const threadId: TThreadID; const Test: ITestResult); virtual;

    ///	<summary>
    ///	  Called when a test errors.
    ///	</summary>
    procedure OnTestError(const threadId: TThreadID; const Error: ITestError); virtual;

    ///	<summary>
    ///	  Called when a test fails.
    ///	</summary>
    procedure OnTestFailure(const threadId: TThreadID; const Failure: ITestError); virtual;

    /// <summary>
    ///   called when a test is ignored.
    /// </summary>
    procedure OnTestIgnored(const threadId: TThreadID; const AIgnored: ITestResult); virtual;

    /// <summary>
    ///   called when a test memory leaks.
    /// </summary>
    procedure OnTestMemoryLeak(const threadId: TThreadID; const Test: ITestResult); virtual;

    /// <summary>
    ///   allows tests to write to the log.
    /// </summary>
    procedure OnLog(const logType: TLogLevel; const msg: string); virtual;

    /// <summary>
    ///   called before a Test Teardown method is run.
    /// </summary>
    procedure OnTeardownTest(const threadId: TThreadID; const Test: ITestInfo); virtual;

    /// <summary>
    ///   called after a test teardown method is run.
    /// </summary>
    procedure OnEndTeardownTest(const threadId: TThreadID; const Test: ITestInfo); virtual;

    /// <summary>
    ///   called after a test method and teardown is run.
    /// </summary>
    procedure OnEndTest(const threadId: TThreadID; const Test: ITestResult); virtual;

    /// <summary>
    ///   called before a Fixture Teardown method is called.
    /// </summary>
    procedure OnTearDownFixture(const threadId: TThreadID; const fixture: ITestFixtureInfo); virtual;

    /// <summary>
    ///   called after a Fixture Teardown method is called.
    /// </summary>
    procedure OnEndTearDownFixture(const threadId: TThreadID; const fixture: ITestFixtureInfo); virtual;

    /// <summary>
    ///   called after a Fixture has run.
    /// </summary>
    procedure OnEndTestFixture(const threadId: TThreadID; const results: IFixtureResult); virtual;

    /// <summary>
    ///   called after all fixtures have run.
    /// </summary>
    procedure OnTestingEnds(const RunResults: IRunResults); virtual;
  end;

  TDUnitXAllureRttiLogger = class(TDUnitXAllureBaseLogger)
  private
    fMethodsInterceptor: TMethodsInterceptor;

    function CreateFixture(Instance: TObject; Method: TRttiMethod; const Args: TArray<TValue>): IAllureFixtureResult;
    function CreateStep(Instance: TObject; Method: TRttiMethod; const Args: TArray<TValue>): IAllureStepResult;

    procedure FillParameters(const ei: IAllureExecutableItem; Instance: TObject; Method: TRttiMethod;
      const Args: TArray<TValue>; const Result: TValue);

    procedure ProxifyFixture(const Fixture: ITestFixtureInfo; Back: Boolean = false);

    procedure BeforeFixtureMethodCall(Instance: TObject; Method: TRttiMethod;
      const Args: TArray<TValue>; out DoInvoke: Boolean; out Result: TValue);
    procedure AfterFixtureMethodCall(Instance: TObject; Method: TRttiMethod;
      const Args: TArray<TValue>; var Result: TValue);
    procedure HandleExceptionInFixtureMethod(Instance: TObject; Method: TRttiMethod;
      const Args: TArray<TValue>; out RaiseException: Boolean;
      TheException: Exception; out Result: TValue);

    // SetupFixture
    procedure BeforeSetupFixture(Instance: TObject; Method: TRttiMethod;
      const Args: TArray<TValue>; out DoInvoke: Boolean; out Result: TValue);
    procedure AfterSetupFixture(Instance: TObject; Method: TRttiMethod;
      const Args: TArray<TValue>; var Result: TValue);
    procedure HandleExceptionInSetupFixture(Instance: TObject; Method: TRttiMethod;
      const Args: TArray<TValue>; out RaiseException: Boolean;
      TheException: Exception; out Result: TValue);
    procedure EndSetupFixture(Instance: TObject; Method: TRttiMethod;
      const Args: TArray<TValue>; const Result: TValue);

    // TearDownFixture
    procedure BeforeTearDownFixture(Instance: TObject; Method: TRttiMethod;
      const Args: TArray<TValue>; out DoInvoke: Boolean; out Result: TValue);
    procedure AfterTearDownFixture(Instance: TObject; Method: TRttiMethod;
      const Args: TArray<TValue>; var Result: TValue);
    procedure HandleExceptionInTearDownFixture(Instance: TObject; Method: TRttiMethod;
      const Args: TArray<TValue>; out RaiseException: Boolean;
      TheException: Exception; out Result: TValue);
    procedure EndTearDownFixture(Instance: TObject; Method: TRttiMethod;
      const Args: TArray<TValue>; const Result: TValue);

    // SetupTest
    procedure BeforeSetupTest(Instance: TObject; Method: TRttiMethod;
      const Args: TArray<TValue>; out DoInvoke: Boolean; out Result: TValue);
    procedure AfterSetupTest(Instance: TObject; Method: TRttiMethod;
      const Args: TArray<TValue>; var Result: TValue);
    procedure HandleExceptionInSetupTest(Instance: TObject; Method: TRttiMethod;
      const Args: TArray<TValue>; out RaiseException: Boolean;
      TheException: Exception; out Result: TValue);
    procedure EndSetupTest(Instance: TObject; Method: TRttiMethod;
      const Args: TArray<TValue>; const Result: TValue);

    // TearDownTest
    procedure BeforeTearDownTest(Instance: TObject; Method: TRttiMethod;
      const Args: TArray<TValue>; out DoInvoke: Boolean; out Result: TValue);
    procedure AfterTearDownTest(Instance: TObject; Method: TRttiMethod;
      const Args: TArray<TValue>; var Result: TValue);
    procedure HandleExceptionInTearDownTest(Instance: TObject; Method: TRttiMethod;
      const Args: TArray<TValue>; out RaiseException: Boolean;
      TheException: Exception; out Result: TValue);
    procedure EndTearDownTest(Instance: TObject; Method: TRttiMethod;
      const Args: TArray<TValue>; const Result: TValue);

    // Step
    procedure BeforeStepExecute(Instance: TObject; Method: TRttiMethod;
      const Args: TArray<TValue>; out DoInvoke: Boolean; out Result: TValue);
    procedure AfterStepExecute(Instance: TObject; Method: TRttiMethod;
      const Args: TArray<TValue>; var Result: TValue);
    procedure HandleExceptionInStepExecute(Instance: TObject; Method: TRttiMethod;
      const Args: TArray<TValue>; out RaiseException: Boolean;
      TheException: Exception; out Result: TValue);
    procedure EndStepExecute(Instance: TObject; Method: TRttiMethod;
      const Args: TArray<TValue>; const Result: TValue);

  public
    constructor Create;
    destructor Destroy; override;

  public

    procedure OnStartTestFixture(const threadId: TThreadID; const fixture: ITestFixtureInfo); override;
    procedure OnEndTestFixture(const threadId: TThreadID; const results: IFixtureResult); override;
  end;

  TDUnitXAllureSimpleLogger = class(TDUnitXAllureBaseLogger)
  private
    procedure PatchFixture(const Fixture: ITestFixtureInfo);
    function CreateStep(const Test: ITestInfo; const StepName: string): IAllureStepResult;
    function CreateFixture(const fixture: ITestFixtureInfo; const FixtureName: string): IAllureFixtureResult;
    procedure EndTearDownFixture(const threadId: TThreadID; const fixture: ITestFixtureInfo);
    procedure EndTearDownTest(const Test: ITestInfo);
    procedure ExecuteStep(const StepName, StepDescription: string; StepProc: TAllureStepProc);
    procedure CheckLastStepStatus(const Results: ITestResult);
  public
    procedure OnTestingStarts(const threadId: TThreadID; testCount, testActiveCount: Cardinal); override;
    procedure OnStartTestFixture(const threadId: TThreadID; const fixture: ITestFixtureInfo); override;
    procedure OnSetupFixture(const threadId: TThreadID; const fixture: ITestFixtureInfo); override;
    procedure OnEndSetupFixture(const threadId: TThreadID; const fixture: ITestFixtureInfo); override;
    procedure OnSetupTest(const threadId: TThreadID; const Test: ITestInfo); override;
    procedure OnEndSetupTest(const threadId: TThreadID; const Test: ITestInfo); override;
    procedure OnTeardownTest(const threadId: TThreadID; const Test: ITestInfo); override;
    procedure OnEndTeardownTest(const threadId: TThreadID; const Test: ITestInfo); override;
    procedure OnEndTest(const threadId: TThreadID; const Test: ITestResult); override;
    procedure OnTearDownFixture(const threadId: TThreadID; const fixture: ITestFixtureInfo); override;
    procedure OnEndTearDownFixture(const threadId: TThreadID; const fixture: ITestFixtureInfo); override;
    procedure OnEndTestFixture(const threadId: TThreadID; const results: IFixtureResult); override;
    procedure OnTestingEnds(const RunResults: IRunResults); override;
  end;

implementation

{ TAllureDUnitXTestLogger }

procedure TDUnitXAllureRttiLogger.AfterFixtureMethodCall(Instance: TObject;
  Method: TRttiMethod; const Args: TArray<TValue>; var Result: TValue);
var
  setupAttrib : SetupAttribute;
  setupFixtureAttrib : SetupFixtureAttribute;
  tearDownAttrib : TearDownAttribute;
  tearDownFixtureAttrib : TearDownFixtureAttribute;
  stepAttrib: StepAttribute;
begin
  if Method.TryGetAttributeOfType<SetupFixtureAttribute>(setupFixtureAttrib) then begin
    AfterSetupFixture(Instance, Method, Args, Result);
  end else if Method.TryGetAttributeOfType<TearDownFixtureAttribute>(tearDownFixtureAttrib) then begin
    AfterTearDownFixture(Instance, Method, Args, Result);
  end else if Method.TryGetAttributeOfType<SetupAttribute>(setupAttrib) then begin
    AfterSetupTest(Instance, Method, Args, Result);
  end else if Method.TryGetAttributeOfType<TearDownAttribute>(tearDownAttrib) then begin
    AfterTearDownTest(Instance, Method, Args, Result);
  end else if Method.TryGetAttributeOfType<StepAttribute>(stepAttrib) then begin
    AfterStepExecute(Instance, Method, Args, Result);
  end else begin
  end;
end;

procedure TDUnitXAllureRttiLogger.AfterSetupFixture(Instance: TObject;
  Method: TRttiMethod; const Args: TArray<TValue>; var Result: TValue);
begin
  EndSetupFixture(Instance, Method, Args, Result);
end;

procedure TDUnitXAllureRttiLogger.AfterSetupTest(Instance: TObject;
  Method: TRttiMethod; const Args: TArray<TValue>; var Result: TValue);
begin
  EndSetupTest(Instance, Method, Args, Result);
end;

procedure TDUnitXAllureRttiLogger.AfterStepExecute(Instance: TObject;
  Method: TRttiMethod; const Args: TArray<TValue>; var Result: TValue);
begin
  EndStepExecute(Instance, Method, Args, Result);
end;

procedure TDUnitXAllureRttiLogger.AfterTearDownFixture(Instance: TObject;
  Method: TRttiMethod; const Args: TArray<TValue>; var Result: TValue);
begin
  EndTearDownFixture(Instance, Method, Args, Result);
end;

procedure TDUnitXAllureRttiLogger.AfterTearDownTest(Instance: TObject;
  Method: TRttiMethod; const Args: TArray<TValue>; var Result: TValue);
begin
  EndTearDownTest(Instance, Method, Args, Result);
end;

procedure TDUnitXAllureRttiLogger.BeforeFixtureMethodCall(Instance: TObject;
  Method: TRttiMethod; const Args: TArray<TValue>; out DoInvoke: Boolean;
  out Result: TValue);
var
  setupAttrib : SetupAttribute;
  setupFixtureAttrib : SetupFixtureAttribute;
  tearDownAttrib : TearDownAttribute;
  tearDownFixtureAttrib : TearDownFixtureAttribute;
  stepAttrib: StepAttribute;
begin
  if Method.TryGetAttributeOfType<SetupFixtureAttribute>(setupFixtureAttrib) then begin
    BeforeSetupFixture(Instance, Method, Args, DoInvoke, Result);
  end else if Method.TryGetAttributeOfType<TearDownFixtureAttribute>(tearDownFixtureAttrib) then begin
    BeforeTearDownFixture(Instance, Method, Args, DoInvoke, Result);
  end else if Method.TryGetAttributeOfType<SetupAttribute>(setupAttrib) then begin
    BeforeSetupTest(Instance, Method, Args, DoInvoke, Result);
  end else if Method.TryGetAttributeOfType<TearDownAttribute>(tearDownAttrib) then begin
    BeforeTearDownTest(Instance, Method, Args, DoInvoke, Result);
  end else if Method.TryGetAttributeOfType<StepAttribute>(stepAttrib) then begin
    BeforeStepExecute(Instance, Method, Args, DoInvoke, Result);
  end else begin
    DoInvoke := true;
    Result := TValue.Empty;
  end;
end;

procedure TDUnitXAllureRttiLogger.BeforeSetupFixture(Instance: TObject;
  Method: TRttiMethod; const Args: TArray<TValue>; out DoInvoke: Boolean;
  out Result: TValue);
var
  container: IAllureTestResultContainer;
  before: IAllureFixtureResult;
begin
  DoInvoke := true;
  Result := TValue.Empty;
  //if not IsSupportedFixture(fixture) then exit;
  if Cast(Allure.Lifecycle.GetObjectOfTag(TAllureTag(Instance)), IAllureTestResultContainer, container)
  then begin
    before := CreateFixture(Instance, Method, Args);
    Allure.Lifecycle.StartBeforeFixture(container.UUID, TAllureUuidHelper.CreateNew, before);
  end;
end;

procedure TDUnitXAllureRttiLogger.BeforeSetupTest(Instance: TObject;
  Method: TRttiMethod; const Args: TArray<TValue>; out DoInvoke: Boolean;
  out Result: TValue);
var
  beforeTest: IAllureStepResult;
begin
  DoInvoke := true;
  Result := TValue.Empty;
  //if not Test.Active then exit;
  beforeTest := CreateStep(Instance, Method, Args);
  Allure.Lifecycle.StartStep(TAllureUuidHelper.CreateNew, beforeTest);
end;

procedure TDUnitXAllureRttiLogger.BeforeStepExecute(Instance: TObject;
  Method: TRttiMethod; const Args: TArray<TValue>; out DoInvoke: Boolean;
  out Result: TValue);
var
  step: IAllureStepResult;
begin
  DoInvoke := true;
  Result := TValue.Empty;
  //if not Test.Active then exit;
  step := CreateStep(Instance, Method, Args);
  Allure.Lifecycle.StartStep(TAllureUuidHelper.CreateNew, step);
end;

procedure TDUnitXAllureRttiLogger.BeforeTearDownFixture(Instance: TObject;
  Method: TRttiMethod; const Args: TArray<TValue>; out DoInvoke: Boolean;
  out Result: TValue);
var
  container: IAllureTestResultContainer;
  after: IAllureFixtureResult;
begin
  DoInvoke := true;
  Result := TValue.Empty;
  //if not IsSupportedFixture(fixture) then exit;
  if Cast(Allure.Lifecycle.GetObjectOfTag(TAllureTag(Instance)), IAllureTestResultContainer, container)
  then begin
    after := CreateFixture(Instance, Method, Args);
    Allure.Lifecycle.StartAfterFixture(container.UUID, TAllureUuidHelper.CreateNew, after);
  end;
end;

procedure TDUnitXAllureRttiLogger.BeforeTearDownTest(Instance: TObject;
  Method: TRttiMethod; const Args: TArray<TValue>; out DoInvoke: Boolean;
  out Result: TValue);
var
  afterTest: IAllureStepResult;
begin
  DoInvoke := true;
  Result := TValue.Empty;
  //if not Test.Active then exit;
  afterTest := CreateStep(Instance, Method, Args);
  Allure.Lifecycle.StartStep(TAllureUuidHelper.CreateNew, afterTest);
end;

constructor TDUnitXAllureRttiLogger.Create;
begin
  inherited Create;
  fMethodsInterceptor := TMethodsInterceptor.Create;
  fMethodsInterceptor.OnBefore := BeforeFixtureMethodCall;
  fMethodsInterceptor.OnAfter := AfterFixtureMethodCall;
  fMethodsInterceptor.OnException := HandleExceptionInFixtureMethod;
end;

function TDUnitXAllureRttiLogger.CreateFixture(Instance: TObject; Method: TRttiMethod;
  const Args: TArray<TValue>): IAllureFixtureResult;
begin
  result := Allure.Lifecycle.CreateFixture;
  result.Name := Method.Name;
  result.Status := asPassed;
  FillAttributes(result, Method.GetAttributes);
end;

function TDUnitXAllureRttiLogger.CreateStep(Instance: TObject;
  Method: TRttiMethod; const Args: TArray<TValue>): IAllureStepResult;
begin
  result := Allure.Lifecycle.CreateStepResult;
  result.Name := Method.Name;
  result.Status := asPassed;
  FillAttributes(result, Method.GetAttributes);
end;

destructor TDUnitXAllureRttiLogger.Destroy;
begin
  fMethodsInterceptor.Free;
  inherited;
end;

procedure TDUnitXAllureRttiLogger.EndSetupFixture(Instance: TObject;
  Method: TRttiMethod; const Args: TArray<TValue>; const Result: TValue);
var
  container: IAllureTestResultContainer;
  before: IAllureFixtureResult;
  beforeUuid: TAllureString;
begin
  //if not IsSupportedFixture(fixture) then exit;
  if Cast(Allure.Lifecycle.GetObjectOfTag(TAllureTag(Instance)), IAllureTestResultContainer, container) and
     Cast(Allure.Lifecycle.GetCurrentObjectOfType(IAllureFixtureResult), IAllureFixtureResult, before)
  then begin
    FillParameters(before, Instance, Method, Args, Result);
    beforeUuid := Allure.Lifecycle.GetUuidOfCurrentObjectOfType(IAllureFixtureResult);
    if beforeUuid<>'' then
      Allure.Lifecycle.StopFixture(beforeUuid);
  end;
end;

procedure TDUnitXAllureRttiLogger.EndSetupTest(Instance: TObject;
  Method: TRttiMethod; const Args: TArray<TValue>; const Result: TValue);
var
  step: IAllureStepResult;
begin
  if Cast(Allure.Lifecycle.GetCurrentObjectOfType(IAllureStepResult), IAllureStepResult, step) then
    FillParameters(step, Instance, Method, Args, Result);
  Allure.Lifecycle.StopStep;
end;

procedure TDUnitXAllureRttiLogger.EndStepExecute(Instance: TObject;
  Method: TRttiMethod; const Args: TArray<TValue>; const Result: TValue);
var
  step: IAllureStepResult;
begin
  if Cast(Allure.Lifecycle.GetCurrentObjectOfType(IAllureStepResult), IAllureStepResult, step) then
    FillParameters(step, Instance, Method, Args, Result);
  Allure.Lifecycle.StopStep;
end;

procedure TDUnitXAllureRttiLogger.EndTearDownFixture(Instance: TObject;
  Method: TRttiMethod; const Args: TArray<TValue>; const Result: TValue);
var
  afterUuid: TAllureString;
  container: IAllureTestResultContainer;
  after: IAllureFixtureResult;
begin
  //if not IsSupportedFixture(fixture) then exit;
  if Cast(Allure.Lifecycle.GetObjectOfTag(TAllureTag(Instance)), IAllureTestResultContainer, container) and
     Cast(Allure.Lifecycle.GetCurrentObjectOfType(IAllureFixtureResult), IAllureFixtureResult, after)
  then begin
    FillParameters(after, Instance, Method, Args, Result);
    afterUuid := Allure.Lifecycle.GetUuidOfCurrentObjectOfType(IAllureFixtureResult);
    if afterUuid<>'' then
      Allure.Lifecycle.StopFixture(afterUuid);
  end;
end;

procedure TDUnitXAllureRttiLogger.EndTearDownTest(Instance: TObject;
  Method: TRttiMethod; const Args: TArray<TValue>; const Result: TValue);
var
  step: IAllureStepResult;
begin
  if Cast(Allure.Lifecycle.GetCurrentObjectOfType(IAllureStepResult), IAllureStepResult, step) then
    FillParameters(step, Instance, Method, Args, Result);
  Allure.Lifecycle.StopStep;
end;

procedure TDUnitXAllureRttiLogger.FillParameters(const ei: IAllureExecutableItem;
  Instance: TObject; Method: TRttiMethod; const Args: TArray<TValue>;
  const Result: TValue);
var
  v: TValue;
  mp: TArray<TRttiParameter>;
  p: IAllureParameter;
  i: Integer;
begin
  if (ei=nil) or (Instance=nil) or (Method=nil) then exit;
  mp := Method.GetParameters;
  for i := 0 to Length(Args)-1 do begin
    v := Args[i];
    p := ei.Parameters.AddNew;
    if i<Length(mp) then
      p.Name := mp[i].ToString
    else
      p.Name := 'Param' + IntToStr(i+1);
    p.Value := v.ToString;
  end;
  if Method.MethodKind=mkFunction then begin
    p := ei.Parameters.AddNew;
    p.Name := 'Result: ' + Method.ReturnType.ToString;
    p.Value := Result.ToString;
  end;
end;

procedure TDUnitXAllureRttiLogger.HandleExceptionInFixtureMethod(Instance: TObject;
  Method: TRttiMethod; const Args: TArray<TValue>; out RaiseException: Boolean;
  TheException: Exception; out Result: TValue);
var
  setupAttrib : SetupAttribute;
  setupFixtureAttrib : SetupFixtureAttribute;
  tearDownAttrib : TearDownAttribute;
  tearDownFixtureAttrib : TearDownFixtureAttribute;
  stepAttrib: StepAttribute;
begin
  if Method.TryGetAttributeOfType<SetupFixtureAttribute>(setupFixtureAttrib) then begin
    HandleExceptionInSetupFixture(Instance, Method, Args, RaiseException, TheException, Result);
  end else if Method.TryGetAttributeOfType<TearDownFixtureAttribute>(tearDownFixtureAttrib) then begin
    HandleExceptionInTearDownFixture(Instance, Method, Args, RaiseException, TheException, Result);
  end else if Method.TryGetAttributeOfType<SetupAttribute>(setupAttrib) then begin
    HandleExceptionInSetupTest(Instance, Method, Args, RaiseException, TheException, Result);
  end else if Method.TryGetAttributeOfType<TearDownAttribute>(tearDownAttrib) then begin
    HandleExceptionInTearDownTest(Instance, Method, Args, RaiseException, TheException, Result);
  end else if Method.TryGetAttributeOfType<StepAttribute>(stepAttrib) then begin
    HandleExceptionInStepExecute(Instance, Method, Args, RaiseException, TheException, Result);
  end else begin
    RaiseException := true;
    Result := TValue.Empty;
  end;
end;

procedure TDUnitXAllureRttiLogger.HandleExceptionInSetupFixture(Instance: TObject;
  Method: TRttiMethod; const Args: TArray<TValue>; out RaiseException: Boolean;
  TheException: Exception; out Result: TValue);
var
  container: IAllureTestResultContainer;
  before: IAllureFixtureResult;
begin
  RaiseException := true;
  Result := TValue.Empty;
  //if not IsSupportedFixture(fixture) then exit;
  if Cast(Allure.Lifecycle.GetObjectOfTag(TAllureTag(Instance)), IAllureTestResultContainer, container) and
     Cast(Allure.Lifecycle.GetCurrentObjectOfType(IAllureFixtureResult), IAllureFixtureResult, before)
  then begin
    before.Status := asBroken;
    before.StatusDetails.Message := TheException.Message;
    before.StatusDetails.Trace := TheException.StackTrace;
  end;
  EndSetupFixture(Instance, Method, Args, Result);
end;

procedure TDUnitXAllureRttiLogger.HandleExceptionInSetupTest(Instance: TObject;
  Method: TRttiMethod; const Args: TArray<TValue>; out RaiseException: Boolean;
  TheException: Exception; out Result: TValue);
var
  step: IAllureStepResult;
begin
  RaiseException := true;
  Result := TValue.Empty;
  if Cast(Allure.Lifecycle.GetCurrentObjectOfType(IAllureStepResult), IAllureStepResult, step)
  then begin
    step.Status := asBroken;
    step.StatusDetails.Message := TheException.Message;
    step.StatusDetails.Trace := TheException.StackTrace;
  end;
  EndSetupTest(Instance, Method, Args, Result);
end;

procedure TDUnitXAllureRttiLogger.HandleExceptionInStepExecute(Instance: TObject;
  Method: TRttiMethod; const Args: TArray<TValue>; out RaiseException: Boolean;
  TheException: Exception; out Result: TValue);
var
  step: IAllureStepResult;
begin
  RaiseException := true;
  Result := TValue.Empty;
  if Cast(Allure.Lifecycle.GetCurrentObjectOfType(IAllureStepResult), IAllureStepResult, step)
  then begin
    if TheException is ETestFailure then begin
      step.Status := asFailed;
    end else if TheException is ETestPass then begin
      step.Status := asPassed;
    end else begin
      step.Status := asBroken;
    end;
    step.StatusDetails.Message := TheException.Message;
    step.StatusDetails.Trace := TheException.StackTrace;
  end;
  EndStepExecute(Instance, Method, Args, Result);
end;

procedure TDUnitXAllureRttiLogger.HandleExceptionInTearDownFixture(
  Instance: TObject; Method: TRttiMethod; const Args: TArray<TValue>;
  out RaiseException: Boolean; TheException: Exception; out Result: TValue);
var
  container: IAllureTestResultContainer;
  after: IAllureFixtureResult;
begin
  RaiseException := true;
  Result := TValue.Empty;
  //if not IsSupportedFixture(fixture) then exit;
  if Cast(Allure.Lifecycle.GetObjectOfTag(TAllureTag(Instance)), IAllureTestResultContainer, container) and
     Cast(Allure.Lifecycle.GetCurrentObjectOfType(IAllureFixtureResult), IAllureFixtureResult, after)
  then begin
    after.Status := asBroken;
    after.StatusDetails.Message := TheException.Message;
    after.StatusDetails.Trace := TheException.StackTrace;
  end;
  EndTearDownFixture(Instance, Method, Args, Result);
end;

procedure TDUnitXAllureRttiLogger.HandleExceptionInTearDownTest(Instance: TObject;
  Method: TRttiMethod; const Args: TArray<TValue>; out RaiseException: Boolean;
  TheException: Exception; out Result: TValue);
var
  step: IAllureStepResult;
begin
  RaiseException := true;
  Result := TValue.Empty;
  if Cast(Allure.Lifecycle.GetCurrentObjectOfType(IAllureStepResult), IAllureStepResult, step)
  then begin
    step.Status := asBroken;
    step.StatusDetails.Message := TheException.Message;
    step.StatusDetails.Trace := TheException.StackTrace;
  end;
  EndTearDownTest(Instance, Method, Args, Result);
end;

procedure TDUnitXAllureRttiLogger.OnEndTestFixture(const threadId: TThreadID;
  const results: IFixtureResult);
begin
  if not IsSupportedFixture(results.fixture) then exit;
  inherited;
  ProxifyFixture(results.Fixture, true);
end;

procedure TDUnitXAllureRttiLogger.OnStartTestFixture(const threadId: TThreadID;
  const fixture: ITestFixtureInfo);
begin
  if not IsSupportedFixture(fixture) then exit;
  ProxifyFixture(fixture);
  inherited;
end;

procedure TDUnitXAllureRttiLogger.ProxifyFixture(const Fixture: ITestFixtureInfo;
  Back: Boolean);

  procedure UpdateMethodPointers(const f: ITestFixture);
  type
    PPVtable = ^PVtable;
    PVtable = ^TVtable;
    TVtable = array[0..MaxInt div SizeOf(Pointer) - 1] of Pointer;
    PVtablePtr = PVtable;
  var
    rType : TRttiType;
    methods : TArray<TRttiMethod>;
    method : TRttiMethod;
    meth : TMethod;
    setupMethod : TTestMethod;
    tearDownMethod : TTestMethod;
    setupFixtureMethod : TTestMethod;
    tearDownFixtureMethod : TTestMethod;
    setupAttrib : SetupAttribute;
    setupFixtureAttrib : SetupFixtureAttribute;
    tearDownAttrib : TearDownAttribute;
    tearDownFixtureAttrib : TearDownFixtureAttribute;
    c: TClass;
    rf: TRttiField;
  begin
    rType := fRttiContext.GetType(TDUnitXTestFixture);
    if rType<>nil then begin
      rf := rType.GetField('FIgnoreFixtureSetup');
      if rf<>nil then
        rf.SetValue(f as TObject, false);
    end;
    c := fMethodsInterceptor.GetProxiClassOfOriginal(fixture.TestClass);
    rType := fRttiContext.GetType(c);
    System.Assert(rType <> nil);
    //it's a dummy namespace fixture, don't bother with the rest.
    if rType.Handle = TypeInfo(TObject) then
      exit;

    setupMethod := nil;
    tearDownMethod := nil;
    setupFixtureMethod := nil;
    tearDownFixtureMethod := nil;

    methods := rType.GetMethods;
    for method in methods do begin
      meth.Code := PVtablePtr(c)[method.VirtualIndex];//method.CodeAddress;
      meth.Data := f.FixtureInstance;

      if (not Assigned(setupFixtureMethod)) and
         method.TryGetAttributeOfType<SetupFixtureAttribute>(setupFixtureAttrib)
      then begin
         setupFixtureMethod := TTestMethod(meth);
         f.SetSetupFixtureMethod(method.Name, setupFixtureMethod);
         continue;
      end;

//      {$IFDEF DELPHI_XE_UP}
//      //if there is a Destructor then we will use it as the fixture
//      //Teardown method.
//      if (not Assigned(tearDownFixtureMethod)) and method.IsDestructor and (Length(method.GetParameters) = 0) then
//      begin
//        tearDownFixtureMethod := TTestMethod(meth);
//        currentFixture.SetTearDownFixtureMethod(method.Name,TTestMethod(meth),true);
//        tearDownFixtureIsDestructor := true;
//        continue;
//      end;
//      {$ENDIF}

      //if we had previously assigned a destructor as the teardownfixturemethod, then we can still override that with an attributed one.
      if ((not Assigned(tearDownFixtureMethod)) {or tearDownFixtureIsDestructor}) and
         method.TryGetAttributeOfType<TearDownFixtureAttribute>(tearDownFixtureAttrib)
      then begin
         tearDownFixtureMethod := TTestMethod(meth);
         f.SetTearDownFixtureMethod(method.Name, tearDownFixtureMethod, false);
//         tearDownFixtureIsDestructor := false;
         continue;
      end;

      if (not Assigned(setupMethod)) and method.TryGetAttributeOfType<SetupAttribute>(setupAttrib)
      then begin
        setupMethod := TTestMethod(meth);
        f.SetSetupTestMethod(method.Name, setupMethod);
        continue;
      end;

      if (not Assigned(tearDownMethod)) and method.TryGetAttributeOfType<TearDownAttribute>(tearDownAttrib)
      then begin
        tearDownMethod := TTestMethod(meth);
        f.SetTearDownTestMethod(method.Name,tearDownMethod);
        continue;
      end;
    end;
  end;

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
      UpdateMethodPointers(f);
    end;
  except
  end;
end;

{ TDUnitXAllureBaseLogger }

constructor TDUnitXAllureBaseLogger.Create;
begin
  inherited Create;
end;

class constructor TDUnitXAllureBaseLogger.CreateClass;
begin
  fRttiContext := TRttiContext.Create;
  fDefaultResultsDir := 'allure-results';
  fDefaultReportDir := 'allure-report';
end;

destructor TDUnitXAllureBaseLogger.Destroy;
begin

  inherited;
end;

class destructor TDUnitXAllureBaseLogger.DestroyClass;
begin
  fRttiContext.Free;
end;

procedure TDUnitXAllureBaseLogger.OnBeginTest(const threadId: TThreadID;
  const Test: ITestInfo);
var
  tr: IAllureTestResult;
  container: IAllureTestResultContainer;
begin
  if not Test.Active then exit;
  Cast(Allure.Lifecycle.GetObjectOfTag(TAllureTag(GetFixtureInstance(Test.Fixture))), IAllureTestResultContainer, container);
  tr := CreateTestResult(Test);
  if container<>nil then
    Allure.Lifecycle.ScheduleTestCase(container.UUID, tr)
  else
    Allure.Lifecycle.ScheduleTestCase(tr);
  Allure.Lifecycle.StartTestCase(tr);
end;

procedure TDUnitXAllureBaseLogger.OnEndSetupFixture(const threadId: TThreadID;
  const fixture: ITestFixtureInfo);
begin

end;

procedure TDUnitXAllureBaseLogger.OnEndSetupTest(const threadId: TThreadID;
  const Test: ITestInfo);
begin

end;

procedure TDUnitXAllureBaseLogger.OnEndTearDownFixture(
  const threadId: TThreadID; const fixture: ITestFixtureInfo);
begin

end;

procedure TDUnitXAllureBaseLogger.OnEndTeardownTest(const threadId: TThreadID;
  const Test: ITestInfo);
begin

end;

procedure TDUnitXAllureBaseLogger.OnEndTest(const threadId: TThreadID;
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

procedure TDUnitXAllureBaseLogger.OnEndTestFixture(const threadId: TThreadID;
  const results: IFixtureResult);
var
  container: IAllureTestResultContainer;
begin
  if not IsSupportedFixture(results.fixture) then exit;
  if Cast(Allure.Lifecycle.GetObjectOfTag(TAllureTag(GetFixtureInstance(results.Fixture))), IAllureTestResultContainer, container)
  then begin
    Allure.Lifecycle.StopTestContainer(container.UUID);
    Allure.Lifecycle.WriteTestContainer(container.UUID);
  end;
end;

procedure TDUnitXAllureBaseLogger.OnExecuteTest(const threadId: TThreadID;
  const Test: ITestInfo);
begin

end;

procedure TDUnitXAllureBaseLogger.OnLog(const logType: TLogLevel;
  const msg: string);
begin

end;

procedure TDUnitXAllureBaseLogger.OnSetupFixture(const threadId: TThreadID;
  const fixture: ITestFixtureInfo);
begin

end;

procedure TDUnitXAllureBaseLogger.OnSetupTest(const threadId: TThreadID;
  const Test: ITestInfo);
begin

end;

procedure TDUnitXAllureBaseLogger.OnStartTestFixture(const threadId: TThreadID;
  const fixture: ITestFixtureInfo);
var
  container: IAllureTestResultContainer;
begin
  if not IsSupportedFixture(fixture) then exit;
  container := CreateContainerOfFixture(fixture);
  Allure.Lifecycle.StartTestContainer(container);
end;

procedure TDUnitXAllureBaseLogger.OnTearDownFixture(const threadId: TThreadID;
  const fixture: ITestFixtureInfo);
begin

end;

procedure TDUnitXAllureBaseLogger.OnTeardownTest(const threadId: TThreadID;
  const Test: ITestInfo);
begin

end;

procedure TDUnitXAllureBaseLogger.OnTestError(const threadId: TThreadID;
  const Error: ITestError);
var
  tr: IAllureTestResult;
begin
  if not Error.Test.Active then exit;
  if Cast(Allure.Lifecycle.GetObjectOfTag(TAllureTag(Error.Test)), IAllureTestResult, tr) then begin
    tr.Status := asBroken;
    tr.StatusDetails.Message := Error.Message;
    tr.StatusDetails.Trace := Error.StackTrace;
  end;
end;

procedure TDUnitXAllureBaseLogger.OnTestFailure(const threadId: TThreadID;
  const Failure: ITestError);
var
  tr: IAllureTestResult;
begin
  if not Failure.Test.Active then exit;
  if Cast(Allure.Lifecycle.GetObjectOfTag(TAllureTag(Failure.Test)), IAllureTestResult, tr) then begin
    tr.Status := asFailed;
    tr.StatusDetails.Message := Failure.Message;
    tr.StatusDetails.Trace := Failure.StackTrace;
  end;
end;

procedure TDUnitXAllureBaseLogger.OnTestIgnored(const threadId: TThreadID;
  const AIgnored: ITestResult);
var
  tr: IAllureTestResult;
begin
  if not AIgnored.Test.Active then exit;
  if Cast(Allure.Lifecycle.GetObjectOfTag(TAllureTag(AIgnored.Test)), IAllureTestResult, tr) then begin
    tr.Status := asSkipped;
    tr.StatusDetails.Message := AIgnored.Message;
    tr.StatusDetails.Trace := AIgnored.StackTrace;
  end;
end;

procedure TDUnitXAllureBaseLogger.OnTestingEnds(const RunResults: IRunResults);
begin
  Allure.Finalize;
end;

procedure TDUnitXAllureBaseLogger.OnTestingStarts(const threadId: TThreadID;
  testCount, testActiveCount: Cardinal);
begin
  Allure.Initialize;
  if FileExists(ConfigFileName) then
    Allure.Lifecycle.AssignConfigFromFile(ConfigFileName);
//  Allure.Lifecycle.CleanupResultDirectory;
end;

procedure TDUnitXAllureBaseLogger.OnTestMemoryLeak(const threadId: TThreadID;
  const Test: ITestResult);
var
  tr: IAllureTestResult;
begin
  if not Test.Test.Active then exit;
  if Cast(Allure.Lifecycle.GetObjectOfTag(TAllureTag(Test.Test)), IAllureTestResult, tr) then begin
    tr.Status := asBroken;
    tr.StatusDetails.Message := Test.Message;
  end;
end;

procedure TDUnitXAllureBaseLogger.OnTestSuccess(const threadId: TThreadID;
  const Test: ITestResult);
var
  tr: IAllureTestResult;
begin
  if not Test.Test.Active then exit;
  if Cast(Allure.Lifecycle.GetObjectOfTag(TAllureTag(Test.Test)), IAllureTestResult, tr) then begin
    tr.Status := asPassed;
  end;
end;

class procedure TDUnitXAllureBaseLogger.RegisterOptions;
begin
  try
    TOptionsRegistry.RegisterOption<string>('allureConfig', 'allureConf', 'Allure configuration file',
      procedure(value :string)
      begin
        if value<>'' then begin
          if ExtractFileDrive(value)='' then
            value := TPath.GetFullPath(value);
          ConfigFileName := value;
          value := ExtractFilePath(value);
          fDefaultResultsDir := ChangeFilePath(fDefaultResultsDir, value);
          fDefaultReportDir := ChangeFilePath(fDefaultReportDir, value);
        end;
      end
    );
  except
  end;
end;

function TDUnitXAllureBaseLogger.Cast(const intf: IInterface; const IID: TGUID;
  out Res): Boolean;
begin
  result := (intf<>nil) and (intf.QueryInterface(IID, Res) = 0);
  if not result then
    pointer(res) := nil;
end;

function TDUnitXAllureBaseLogger.IsSupportedFixture(
  const Fixture: ITestFixtureInfo): Boolean;
begin
  result := (Fixture<>nil) and (Fixture.ActiveTestCount>0);
end;

function TDUnitXAllureBaseLogger.GetFixtureInstance(
  const Fixture: ITestFixtureInfo): Pointer;
var
  f: ITestFixture;
begin
  result := nil;
  if Fixture=nil then exit;
  if cast(Fixture, ITestFixture, f) then
    result := f.FixtureInstance;
end;

function TDUnitXAllureBaseLogger.CreateContainerOfFixture(const Fixture: ITestFixtureInfo): IAllureTestResultContainer;
var
  rType: TRttiType;
begin
  result := nil;
  if Fixture=nil then exit;
  result := allure.Lifecycle.CreateTestResultContainer;
  result.Tag := TAllureTag(GetFixtureInstance(Fixture));
  result.Name := Fixture.Name;
  result.Description := Fixture.Description;
  rType := fRttiContext.GetType(fixture.TestClass);
  if rType<>nil then
    FillAttributes(result, rType.GetAttributes);
end;

procedure TDUnitXAllureBaseLogger.FillAttributes(const TestObj: IInterface;
  const Attributes: TArray<TCustomAttribute>);
var
  ei: IAllureExecutableItem;
  cont: IAllureTestResultContainer;
  test: IAllureTestResult;
  a: TCustomAttribute;
  link: IAllureLink;
  alabel: IAllureLabel;
begin
  if TestObj=nil then exit;
  cast(TestObj, IAllureExecutableItem, ei);
  cast(TestObj, IAllureTestResultContainer, cont);
  cast(TestObj, IAllureTestResult, test);
  for a in Attributes do begin
    if a is DescriptionAttribute then begin
      if ei<>nil then
        ei.Description := DescriptionAttribute(a).Value
      else if cont<>nil then
        cont.Description := DescriptionAttribute(a).Value;
    end else if a is TAllureLinkAttribute then begin
      if test<>nil then
        link := test.Links.AddNew
      else if cont<>nil then
        link := cont.Links.AddNew
      else
        continue;
      link.Name := TAllureLinkAttribute(a).Name;
      link.Url := TAllureLinkAttribute(a).Url;
      link.LinkType := TAllureLinkAttribute(a).LinkType;
    end else if a is StepAttribute then begin
      if ei<>nil then begin
        if StepAttribute(a).Name<>'' then
          ei.Name := StepAttribute(a).Name;
      end;
    end else if a is SeverityAttribute then begin
      if test<>nil then begin
        alabel := test.Labels.AddNew;
        alabel.SetSeverity(SeverityAttribute(a).Severity);
      end;
    end else if a is EpicAttribute then begin
      if test<>nil then begin
        alabel := test.Labels.AddNew;
        alabel.SetEpic(EpicAttribute(a).Value);
      end;
    end else if a is FeatureAttribute then begin
      if test<>nil then begin
        alabel := test.Labels.AddNew;
        alabel.SetFeature(FeatureAttribute(a).Value);
      end;
    end else if a is StoryAttribute then begin
      if test<>nil then begin
        alabel := test.Labels.AddNew;
        alabel.SetStory(StoryAttribute(a).Value);
      end;
    end else if a is FlakyAttribute then begin
      if ei<>nil then begin
        ei.StatusDetails.Flaky := true;
      end;
    end else if a is MutedAttribute then begin
      if ei<>nil then begin
        ei.StatusDetails.Muted := true;
      end;
    end else if a is KnownAttribute then begin
      if ei<>nil then begin
        ei.StatusDetails.Known := true;
      end;
    end;
  end;
end;

function TDUnitXAllureBaseLogger.CreateTestResult(
  const Test: ITestInfo): IAllureTestResult;
var
  rType: TRttiType;
  Method: TRttiMethod;
begin
  result := Allure.Lifecycle.CreateTestResult;
  {$IFDEF CPUX64}
  result.Name := Test.Name + '_x64';
  result.FullName := Test.FullName + '.x64';
  {$ELSE}
  result.Name := Test.Name + '_x32';
  result.FullName := Test.FullName + '.x32';
  {$ENDIF}
  result.HistoryID := TAllureUuidHelper.GenerateHistoryID(result.FullName);
  result.Tag := TAllureTag(Test);
  result.Labels.AddNew.SetPackage(GetModuleName(HInstance));
  if Test.Fixture<>nil then begin
    result.Labels.AddNew.SetSuite(Test.Fixture.Name);
    if Test.Fixture.TestClass<>nil then
      result.Labels.AddNew.SetTestClass(Test.Fixture.TestClass.ClassName);
  end;
  if Test.MethodName<>'' then
    result.Labels.AddNew.SetTestMethod(Test.MethodName);
  result.Labels.AddNew.SetCurrentThread;

  rType := fRttiContext.GetType(Test.Fixture.TestClass);
  if rType<>nil then begin
    Method := rType.GetMethod(Test.MethodName);
    if Method<>nil then begin
      FillAttributes(result, rType.GetAttributes);
      FillAttributes(result, Method.GetAttributes);
    end;
  end;
end;

{ TDUnitXAllureSimpleLogger }

procedure TDUnitXAllureSimpleLogger.CheckLastStepStatus(
  const Results: ITestResult);
var
  step: IAllureStepResult;
begin
  if (Results.ResultType in [TTestResultType.Failure, TTestResultType.Error,
    TTestResultType.MemoryLeak, TTestResultType.Warning]) and
    Cast(Allure.Lifecycle.GetCurrentObjectOfType(IAllureStepResult), IAllureStepResult, step)
  then begin
    case Results.ResultType of
      TTestResultType.Failure: step.Status := asFailed;
      TTestResultType.Error: step.Status := asBroken;
      TTestResultType.MemoryLeak: step.Status := asBroken;
    end;
    if Results.Message<>'' then
      step.StatusDetails.Message := Results.Message;
    if Results.StackTrace<>'' then
      step.StatusDetails.Trace := Results.StackTrace;
  end;
end;

function TDUnitXAllureSimpleLogger.CreateFixture(
  const fixture: ITestFixtureInfo;
  const FixtureName: string): IAllureFixtureResult;
begin
  result := Allure.Lifecycle.CreateFixture;
  result.Name := FixtureName;
  result.Status := asPassed;
end;

function TDUnitXAllureSimpleLogger.CreateStep(const Test: ITestInfo;
  const StepName: string): IAllureStepResult;
begin
  result := Allure.Lifecycle.CreateStepResult;
  result.Name := StepName;
  result.Status := asPassed;
  //FillAttributes(result, Method.GetAttributes);
end;

procedure TDUnitXAllureSimpleLogger.EndTearDownFixture(
  const threadId: TThreadID; const fixture: ITestFixtureInfo);
var
  afterUuid: TAllureString;
  container: IAllureTestResultContainer;
  after: IAllureFixtureResult;
begin
  if not IsSupportedFixture(fixture) then exit;
  if Cast(Allure.Lifecycle.GetObjectOfTag(TAllureTag(GetFixtureInstance(Fixture))), IAllureTestResultContainer, container) and
     Cast(Allure.Lifecycle.GetCurrentObjectOfType(IAllureFixtureResult), IAllureFixtureResult, after) and
     SameText(after.Name, 'TearDownFixture')
  then begin
    afterUuid := Allure.Lifecycle.GetUuidOfCurrentObjectOfType(IAllureFixtureResult);
    if afterUuid<>'' then
      Allure.Lifecycle.StopFixture(afterUuid);
  end;
end;

procedure TDUnitXAllureSimpleLogger.EndTearDownTest(const Test: ITestInfo);
var
  step: IAllureStepResult;
begin
  if Cast(Allure.Lifecycle.GetCurrentObjectOfType(IAllureStepResult), IAllureStepResult, step) and
     SameText(step.Name, 'TearDownTest')
  then begin
    Allure.Lifecycle.StopStep;
  end;
end;

procedure TDUnitXAllureSimpleLogger.ExecuteStep(const StepName,
  StepDescription: string; StepProc: TAllureStepProc);
var
  step: IAllureStepResult;
  uuid: TAllureString;
begin
  uuid := TAllureUuidHelper.CreateNew;
  step := CreateStep(nil, StepName);
  if StepDescription<>'' then
    step.Description := StepDescription;
  Allure.Lifecycle.StartStep(uuid, step);
  try
    try
      StepProc();
    except
      on e: ETestPass do begin
        step.Status := asPassed;
        step.StatusDetails.Message := e.Message;
        step.StatusDetails.Trace := e.StackTrace;
        raise;
      end;
      on e: ETestFailure do begin
        step.Status := asFailed;
        step.StatusDetails.Message := e.Message;
        step.StatusDetails.Trace := e.StackTrace;
        raise;
      end;
      on e: Exception do begin
        step.Status := asBroken;
        step.StatusDetails.Message := e.Message;
        step.StatusDetails.Trace := e.StackTrace;
        raise;
      end;
    end;
  finally
    Allure.Lifecycle.StopStep(uuid);
  end;
end;

procedure TDUnitXAllureSimpleLogger.OnEndSetupFixture(const threadId: TThreadID;
  const fixture: ITestFixtureInfo);
var
  container: IAllureTestResultContainer;
  before: IAllureFixtureResult;
  beforeUuid: TAllureString;
begin
  if not IsSupportedFixture(fixture) then exit;
  if Cast(Allure.Lifecycle.GetObjectOfTag(TAllureTag(GetFixtureInstance(Fixture))), IAllureTestResultContainer, container) and
     Cast(Allure.Lifecycle.GetCurrentObjectOfType(IAllureFixtureResult), IAllureFixtureResult, before) and
     SameText(before.Name, 'SetupFixture')
  then begin
    beforeUuid := Allure.Lifecycle.GetUuidOfCurrentObjectOfType(IAllureFixtureResult);
    if beforeUuid<>'' then
      Allure.Lifecycle.StopFixture(beforeUuid);
  end;
end;

procedure TDUnitXAllureSimpleLogger.OnEndSetupTest(const threadId: TThreadID;
  const Test: ITestInfo);
begin
  Allure.Lifecycle.StopStep;
end;

procedure TDUnitXAllureSimpleLogger.OnEndTearDownFixture(
  const threadId: TThreadID; const fixture: ITestFixtureInfo);
begin
  EndTearDownFixture(threadId, fixture);
end;

procedure TDUnitXAllureSimpleLogger.OnEndTeardownTest(const threadId: TThreadID;
  const Test: ITestInfo);
begin
  EndTearDownTest(Test);
end;

procedure TDUnitXAllureSimpleLogger.OnEndTest(const threadId: TThreadID;
  const Test: ITestResult);
begin
  EndTearDownTest(Test.Test);
  inherited;
end;

procedure TDUnitXAllureSimpleLogger.OnEndTestFixture(const threadId: TThreadID;
  const results: IFixtureResult);
begin
  EndTearDownFixture(threadId, results.Fixture);
  inherited;
end;

procedure TDUnitXAllureSimpleLogger.OnSetupFixture(const threadId: TThreadID;
  const fixture: ITestFixtureInfo);
var
  container: IAllureTestResultContainer;
  before: IAllureFixtureResult;
begin
  if not IsSupportedFixture(fixture) then exit;
  if Cast(Allure.Lifecycle.GetObjectOfTag(TAllureTag(GetFixtureInstance(Fixture))), IAllureTestResultContainer, container)
  then begin
    before := CreateFixture(Fixture, 'SetupFixture');
    Allure.Lifecycle.StartBeforeFixture(container.UUID, TAllureUuidHelper.CreateNew, before);
  end;
end;

procedure TDUnitXAllureSimpleLogger.OnSetupTest(const threadId: TThreadID;
  const Test: ITestInfo);
var
  beforeTest: IAllureStepResult;
begin
  //if not Test.Active then exit;
  beforeTest := CreateStep(Test, 'SetupTest');
  Allure.Lifecycle.StartStep(TAllureUuidHelper.CreateNew, beforeTest);
end;

procedure TDUnitXAllureSimpleLogger.OnStartTestFixture(
  const threadId: TThreadID; const fixture: ITestFixtureInfo);
begin
  PatchFixture(fixture);
  inherited;
end;

procedure TDUnitXAllureSimpleLogger.OnTearDownFixture(const threadId: TThreadID;
  const fixture: ITestFixtureInfo);
var
  container: IAllureTestResultContainer;
  after: IAllureFixtureResult;
begin
  if not IsSupportedFixture(fixture) then exit;
  if Cast(Allure.Lifecycle.GetObjectOfTag(TAllureTag(GetFixtureInstance(Fixture))), IAllureTestResultContainer, container)
  then begin
    after := CreateFixture(Fixture, 'TearDownFixture');
    Allure.Lifecycle.StartAfterFixture(container.UUID, TAllureUuidHelper.CreateNew, after);
  end;
end;

procedure TDUnitXAllureSimpleLogger.OnTeardownTest(const threadId: TThreadID;
  const Test: ITestInfo);
var
  afterTest: IAllureStepResult;
begin
  //if not Test.Active then exit;
  afterTest := CreateStep(Test, 'TearDownTest');
  Allure.Lifecycle.StartStep(TAllureUuidHelper.CreateNew, afterTest);
end;

procedure TDUnitXAllureSimpleLogger.OnTestingEnds(
  const RunResults: IRunResults);
begin
  Allure.AssignStepHandler(nil);
  inherited;
end;

procedure TDUnitXAllureSimpleLogger.OnTestingStarts(const threadId: TThreadID;
  testCount, testActiveCount: Cardinal);
begin
  inherited;
  Allure.AssignStepHandler(ExecuteStep);
end;

procedure TDUnitXAllureSimpleLogger.PatchFixture(const Fixture: ITestFixtureInfo);
var
  rType : TRttiType;
  methods : TArray<TRttiMethod>;
  method : TRttiMethod;
  meth : TMethod;
  setupFixtureMethod : TTestMethod;
  setupFixtureAttrib : SetupFixtureAttribute;
  rf: TRttiField;
  f: ITestFixture;
begin
  if Fixture=nil then exit;
  if not cast(Fixture, ITestFixture, f) or (f.FixtureInstance=nil) then exit;

  rType := fRttiContext.GetType(TDUnitXTestFixture);
  if rType<>nil then begin
    rf := rType.GetField('FIgnoreFixtureSetup');
    if rf<>nil then
      rf.SetValue(f as TObject, false);
  end;
  rType := fRttiContext.GetType(fixture.TestClass);
  System.Assert(rType <> nil);
  //it's a dummy namespace fixture, don't bother with the rest.
  if rType.Handle = TypeInfo(TObject) then
    exit;

  setupFixtureMethod := nil;

  methods := rType.GetMethods;
  for method in methods do begin
    meth.Code := method.CodeAddress;
    meth.Data := f.FixtureInstance;

    if (not Assigned(setupFixtureMethod)) and
       method.TryGetAttributeOfType<SetupFixtureAttribute>(setupFixtureAttrib)
    then begin
       setupFixtureMethod := TTestMethod(meth);
       f.SetSetupFixtureMethod(method.Name, setupFixtureMethod);
       break;
    end;
  end;
end;

initialization
  TDUnitXAllureBaseLogger.RegisterOptions;
end.
