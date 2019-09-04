unit allureDUnitXLogger;

interface

uses
  System.RTTI, DUnitX.TestFramework, allureDelphiInterface, allureDelphiHelper,
  System.SysUtils, MethodsInterceptor, DUnitX.Extensibility, DUnitX.Utils,
  DUnitX.TestFixture, allureAttributes, DUnitX.Exceptions, System.TypInfo;

type

  TDUnitXAllureLogger = class(TInterfacedObject, ITestLogger)
  private class var
    fRttiContext: TRttiContext;
  private
    fConfigFileName: string;
    fMethodsInterceptor: TMethodsInterceptor;

    function Cast(const intf: IUnknown; const IID: TGUID; out Res): Boolean;
    function IsSupportedFixture(const Fixture: ITestFixtureInfo): Boolean;
    function GetFixtureInstance(const Fixture: ITestFixtureInfo): Pointer;
    function CreateContainerOfFixture(const Fixture: ITestFixtureInfo): IAllureTestResultContainer;
    function CreateFixture(Instance: TObject; Method: TRttiMethod; const Args: TArray<TValue>): IAllureFixtureResult;
    function CreateTestResult(const Test: ITestInfo): IAllureTestResult;
    function CreateStep(Instance: TObject; Method: TRttiMethod; const Args: TArray<TValue>): IAllureStepResult;

    procedure FillAttributes(const TestObj: IUnknown; const Attributes: TArray<TCustomAttribute>);
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

    procedure SetConfigFileName(const Value: string);
  public
    class constructor CreateClass;
    class destructor DestroyClass;
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

procedure TDUnitXAllureLogger.AfterSetupFixture(Instance: TObject;
  Method: TRttiMethod; const Args: TArray<TValue>; var Result: TValue);
begin
  EndSetupFixture(Instance, Method, Args, Result);
end;

procedure TDUnitXAllureLogger.AfterSetupTest(Instance: TObject;
  Method: TRttiMethod; const Args: TArray<TValue>; var Result: TValue);
begin
  EndSetupTest(Instance, Method, Args, Result);
end;

procedure TDUnitXAllureLogger.AfterStepExecute(Instance: TObject;
  Method: TRttiMethod; const Args: TArray<TValue>; var Result: TValue);
begin
  EndStepExecute(Instance, Method, Args, Result);
end;

procedure TDUnitXAllureLogger.AfterTearDownFixture(Instance: TObject;
  Method: TRttiMethod; const Args: TArray<TValue>; var Result: TValue);
begin
  EndTearDownFixture(Instance, Method, Args, Result);
end;

procedure TDUnitXAllureLogger.AfterTearDownTest(Instance: TObject;
  Method: TRttiMethod; const Args: TArray<TValue>; var Result: TValue);
begin
  EndTearDownTest(Instance, Method, Args, Result);
end;

procedure TDUnitXAllureLogger.BeforeFixtureMethodCall(Instance: TObject;
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

procedure TDUnitXAllureLogger.BeforeSetupFixture(Instance: TObject;
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

procedure TDUnitXAllureLogger.BeforeSetupTest(Instance: TObject;
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

procedure TDUnitXAllureLogger.BeforeStepExecute(Instance: TObject;
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

procedure TDUnitXAllureLogger.BeforeTearDownFixture(Instance: TObject;
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

procedure TDUnitXAllureLogger.BeforeTearDownTest(Instance: TObject;
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

function TDUnitXAllureLogger.CreateFixture(Instance: TObject; Method: TRttiMethod;
  const Args: TArray<TValue>): IAllureFixtureResult;
begin
  result := Allure.Lifecycle.CreateFixture;
  result.Name := Method.Name;
  result.Status := asPassed;
  FillAttributes(result, Method.GetAttributes);
end;

class constructor TDUnitXAllureLogger.CreateClass;
begin
  fRttiContext := TRttiContext.Create;
end;

function TDUnitXAllureLogger.CreateContainerOfFixture(const Fixture: ITestFixtureInfo): IAllureTestResultContainer;
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

function TDUnitXAllureLogger.CreateStep(Instance: TObject;
  Method: TRttiMethod; const Args: TArray<TValue>): IAllureStepResult;
begin
  result := Allure.Lifecycle.CreateStepResult;
  result.Name := Method.Name;
  result.Status := asPassed;
  FillAttributes(result, Method.GetAttributes);
end;

function TDUnitXAllureLogger.CreateTestResult(
  const Test: ITestInfo): IAllureTestResult;
var
  rType: TRttiType;
  Method: TRttiMethod;
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

  rType := fRttiContext.GetType(Test.Fixture.TestClass);
  if rType<>nil then begin
    Method := rType.GetMethod(Test.MethodName);
    if Method<>nil then begin
      FillAttributes(result, rType.GetAttributes);
      FillAttributes(result, Method.GetAttributes);
    end;
  end;
end;

destructor TDUnitXAllureLogger.Destroy;
begin
  fMethodsInterceptor.Free;
  inherited;
end;

class destructor TDUnitXAllureLogger.DestroyClass;
begin
  fRttiContext.Free;
end;

procedure TDUnitXAllureLogger.EndSetupFixture(Instance: TObject;
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

procedure TDUnitXAllureLogger.EndSetupTest(Instance: TObject;
  Method: TRttiMethod; const Args: TArray<TValue>; const Result: TValue);
var
  step: IAllureStepResult;
begin
  if Cast(Allure.Lifecycle.GetCurrentObjectOfType(IAllureStepResult), IAllureStepResult, step) then
    FillParameters(step, Instance, Method, Args, Result);
  Allure.Lifecycle.StopStep;
end;

procedure TDUnitXAllureLogger.EndStepExecute(Instance: TObject;
  Method: TRttiMethod; const Args: TArray<TValue>; const Result: TValue);
var
  step: IAllureStepResult;
begin
  if Cast(Allure.Lifecycle.GetCurrentObjectOfType(IAllureStepResult), IAllureStepResult, step) then
    FillParameters(step, Instance, Method, Args, Result);
  Allure.Lifecycle.StopStep;
end;

procedure TDUnitXAllureLogger.EndTearDownFixture(Instance: TObject;
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

procedure TDUnitXAllureLogger.EndTearDownTest(Instance: TObject;
  Method: TRttiMethod; const Args: TArray<TValue>; const Result: TValue);
var
  step: IAllureStepResult;
begin
  if Cast(Allure.Lifecycle.GetCurrentObjectOfType(IAllureStepResult), IAllureStepResult, step) then
    FillParameters(step, Instance, Method, Args, Result);
  Allure.Lifecycle.StopStep;
end;

procedure TDUnitXAllureLogger.FillAttributes(const TestObj: IInterface;
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

procedure TDUnitXAllureLogger.FillParameters(const ei: IAllureExecutableItem;
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

function TDUnitXAllureLogger.GetFixtureInstance(
  const Fixture: ITestFixtureInfo): Pointer;
var
  f: ITestFixture;
begin
  result := nil;
  if Fixture=nil then exit;
  if cast(Fixture, ITestFixture, f) then
    result := f.FixtureInstance;
end;

procedure TDUnitXAllureLogger.HandleExceptionInFixtureMethod(Instance: TObject;
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

procedure TDUnitXAllureLogger.HandleExceptionInSetupFixture(Instance: TObject;
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

procedure TDUnitXAllureLogger.HandleExceptionInSetupTest(Instance: TObject;
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

procedure TDUnitXAllureLogger.HandleExceptionInStepExecute(Instance: TObject;
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

procedure TDUnitXAllureLogger.HandleExceptionInTearDownFixture(
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

procedure TDUnitXAllureLogger.HandleExceptionInTearDownTest(Instance: TObject;
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
  Cast(Allure.Lifecycle.GetObjectOfTag(TAllureTag(GetFixtureInstance(Test.Fixture))), IAllureTestResultContainer, container);
  tr := CreateTestResult(Test);
  if container<>nil then
    Allure.Lifecycle.ScheduleTestCase(container.UUID, tr)
  else
    Allure.Lifecycle.ScheduleTestCase(tr);
  Allure.Lifecycle.StartTestCase(tr);
end;

procedure TDUnitXAllureLogger.OnEndSetupFixture(const threadId: TThreadID;
  const fixture: ITestFixtureInfo);
begin

end;

procedure TDUnitXAllureLogger.OnEndSetupTest(const threadId: TThreadID;
  const Test: ITestInfo);
begin

end;

procedure TDUnitXAllureLogger.OnEndTearDownFixture(
  const threadId: TThreadID; const fixture: ITestFixtureInfo);
begin

end;

procedure TDUnitXAllureLogger.OnEndTeardownTest(const threadId: TThreadID;
  const Test: ITestInfo);
begin

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
  if not IsSupportedFixture(results.fixture) then exit;
  if Cast(Allure.Lifecycle.GetObjectOfTag(TAllureTag(GetFixtureInstance(results.Fixture))), IAllureTestResultContainer, container)
  then begin
    Allure.Lifecycle.StopTestContainer(container.UUID);
    Allure.Lifecycle.WriteTestContainer(container.UUID);
  end;
  ProxifyFixture(results.Fixture, true);
end;

procedure TDUnitXAllureLogger.OnExecuteTest(const threadId: TThreadID;
  const Test: ITestInfo);
begin
  
end;

procedure TDUnitXAllureLogger.OnLog(const logType: TLogLevel;
  const msg: string);
begin

end;

procedure TDUnitXAllureLogger.OnSetupFixture(const threadId: TThreadID;
  const fixture: ITestFixtureInfo);
begin

end;

procedure TDUnitXAllureLogger.OnSetupTest(const threadId: TThreadID;
  const Test: ITestInfo);
begin

end;

procedure TDUnitXAllureLogger.OnStartTestFixture(const threadId: TThreadID;
  const fixture: ITestFixtureInfo);
var
  container: IAllureTestResultContainer;
begin
  if not IsSupportedFixture(fixture) then exit;
  ProxifyFixture(fixture);
  container := CreateContainerOfFixture(fixture);
  Allure.Lifecycle.StartTestContainer(container);
end;

procedure TDUnitXAllureLogger.OnTearDownFixture(const threadId: TThreadID;
  const fixture: ITestFixtureInfo);
begin

end;

procedure TDUnitXAllureLogger.OnTeardownTest(const threadId: TThreadID;
  const Test: ITestInfo);
begin

end;

procedure TDUnitXAllureLogger.OnTestError(const threadId: TThreadID;
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

procedure TDUnitXAllureLogger.OnTestFailure(const threadId: TThreadID;
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

procedure TDUnitXAllureLogger.OnTestIgnored(const threadId: TThreadID;
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
//  Allure.Lifecycle.CleanupResultDirectory;
end;

procedure TDUnitXAllureLogger.OnTestMemoryLeak(const threadId: TThreadID;
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

procedure TDUnitXAllureLogger.OnTestSuccess(const threadId: TThreadID;
  const Test: ITestResult);
var
  tr: IAllureTestResult;
begin
  if not Test.Test.Active then exit;
  if Cast(Allure.Lifecycle.GetObjectOfTag(TAllureTag(Test.Test)), IAllureTestResult, tr) then begin
    tr.Status := asPassed;
  end;
end;

procedure TDUnitXAllureLogger.ProxifyFixture(const Fixture: ITestFixtureInfo;
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

procedure TDUnitXAllureLogger.SetConfigFileName(const Value: string);
begin
  fConfigFileName := Value;
end;

end.
