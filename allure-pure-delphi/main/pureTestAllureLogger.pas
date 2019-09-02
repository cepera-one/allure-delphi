unit pureTestAllureLogger;

interface

uses
  System.SysUtils, Winapi.Windows, pureTestFramework, allureDelphiInterface,
  allureDelphiHelper;

type

  TPureTestAllureLogger = class(TInterfacedObject, IPureTestsListener,
    IPureTestsAdvancedListener)
  private
    fConfigFileName: string;

    function CreateContainerOfFixture(const Fixture: IPureTestFixture): IAllureTestResultContainer;
    function CreateFixture(const Fixture: IPureTestFixture; IsSetup: Boolean): IAllureFixtureResult;
    function CreateTestResult(const Test: IPureTest): IAllureTestResult;
    function CreateStep(const Step: IPureTestStep): IAllureStepResult;
    function Cast(const intf: IInterface; const IID: TGUID; out Res): Boolean;

    procedure SetConfigFileName(const Value: string);
  public
    constructor Create(const AConfigFileName: string = '');
    destructor Destroy; override;

    property ConfigFileName: string read fConfigFileName write SetConfigFileName;
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

implementation

{ TPureTestTextLogger }

procedure TPureTestAllureLogger.AddEpic(const Test: IPureTest;
  const Value: string);
var
  tr: IAllureTestResult;
begin
  if Cast(Allure.Lifecycle.GetObjectOfTag(TAllureTag(Test)), IAllureTestResult, tr) then begin
    tr.Labels.AddNew.SetEpic(Value);
  end;
end;

procedure TPureTestAllureLogger.AddFeature(const Test: IPureTest;
  const Value: string);
var
  tr: IAllureTestResult;
begin
  if Cast(Allure.Lifecycle.GetObjectOfTag(TAllureTag(Test)), IAllureTestResult, tr) then begin
    tr.Labels.AddNew.SetFeature(Value);
  end;
end;

procedure TPureTestAllureLogger.AddIssue(const Test: IPureTest; const IssueID,
  IssueLink: string);
var
  tr: IAllureTestResult;
begin
  if Cast(Allure.Lifecycle.GetObjectOfTag(TAllureTag(Test)), IAllureTestResult, tr) then begin
    tr.Links.AddNew.SetIssueUrl(IssueID, IssueLink);
  end;
end;

procedure TPureTestAllureLogger.AddLink(const Test: IPureTest; const Uri,
  LinkName: string);
var
  tr: IAllureTestResult;
  al: IAllureLink;
begin
  if Cast(Allure.Lifecycle.GetObjectOfTag(TAllureTag(Test)), IAllureTestResult, tr) then begin
    al := tr.Links.AddNew;
    al.Url := Uri;
    al.Name := LinkName;
  end;
end;

procedure TPureTestAllureLogger.AddStory(const Test: IPureTest;
  const Value: string);
var
  tr: IAllureTestResult;
begin
  if Cast(Allure.Lifecycle.GetObjectOfTag(TAllureTag(Test)), IAllureTestResult, tr) then begin
    tr.Labels.AddNew.SetStory(Value);
  end;
end;

procedure TPureTestAllureLogger.AddTestClass(const Test: IPureTest;
  const Value: string);
var
  tr: IAllureTestResult;
begin
  if Cast(Allure.Lifecycle.GetObjectOfTag(TAllureTag(Test)), IAllureTestResult, tr) then begin
    tr.Labels.AddNew.SetTestClass(Value);
  end;
end;

procedure TPureTestAllureLogger.AddTestMethod(const Test: IPureTest;
  const Value: string);
var
  tr: IAllureTestResult;
begin
  if Cast(Allure.Lifecycle.GetObjectOfTag(TAllureTag(Test)), IAllureTestResult, tr) then begin
    tr.Labels.AddNew.SetTestMethod(Value);
  end;
end;

function TPureTestAllureLogger.Cast(const intf: IInterface; const IID: TGUID;
  out Res): Boolean;
begin
  result := (intf<>nil) and (intf.QueryInterface(IID, Res) = 0);
  if not result then
    pointer(res) := nil;
end;

constructor TPureTestAllureLogger.Create(const AConfigFileName: string = '');
begin
  inherited Create;
  ConfigFileName := AConfigFileName;
end;

function TPureTestAllureLogger.CreateContainerOfFixture(
  const Fixture: IPureTestFixture): IAllureTestResultContainer;
begin
  result := nil;
  if Fixture=nil then exit;
  result := allure.Lifecycle.CreateTestResultContainer;
  result.Tag := TAllureTag(Fixture);
  result.Name := Fixture.Name;
  result.Description := Fixture.Description;
  //FillAttributes(result, rType.GetAttributes);
end;

function TPureTestAllureLogger.CreateFixture(
  const Fixture: IPureTestFixture; IsSetup: Boolean): IAllureFixtureResult;
begin
  result := Allure.Lifecycle.CreateFixture;
  if IsSetup then
    result.Name := 'SetupFixture'
  else
    result.Name := 'TearDownFixture';
  result.Status := asPassed;
  //FillAttributes(result, Method.GetAttributes);
end;

function TPureTestAllureLogger.CreateStep(
  const Step: IPureTestStep): IAllureStepResult;
begin
  result := Allure.Lifecycle.CreateStepResult;
  result.Name := Step.Name;
  result.Description := Step.Description;
  result.Status := asPassed;
  //FillAttributes(result, Method.GetAttributes);
end;

function TPureTestAllureLogger.CreateTestResult(
  const Test: IPureTest): IAllureTestResult;
begin
  result := Allure.Lifecycle.CreateTestResult;
  result.Name := Test.Name;
  result.FullName := Test.Fixture.Name + '.' + Test.Name;
  result.HistoryID := TAllureUuidHelper.GenerateHistoryID(result.FullName);
  result.Tag := TAllureTag(Test);
  result.Description := Test.Description;
  result.Labels.AddNew.SetPackage(ExtractFileName(GetModuleName(HInstance)));
  if Test.Fixture<>nil then begin
    result.Labels.AddNew.SetSuite(Test.Fixture.Name);
//    if Test.Fixture.TestClass<>nil then
//      result.Labels.AddNew.SetTestClass(Test.Fixture.TestClass.ClassName);
  end;
//  if Test.MethodName<>'' then
//    result.Labels.AddNew.SetTestMethod(Test.MethodName);
  result.Labels.AddNew.SetCurrentThread;
end;

destructor TPureTestAllureLogger.Destroy;
begin

  inherited;
end;

procedure TPureTestAllureLogger.MarkFlaky(const Test: IPureTest);
var
  tr: IAllureTestResult;
begin
  if Cast(Allure.Lifecycle.GetObjectOfTag(TAllureTag(Test)), IAllureTestResult, tr) then begin
    tr.StatusDetails.Flaky := true;
  end;
end;

procedure TPureTestAllureLogger.MarkKnown(const Test: IPureTest);
var
  tr: IAllureTestResult;
begin
  if Cast(Allure.Lifecycle.GetObjectOfTag(TAllureTag(Test)), IAllureTestResult, tr) then begin
    tr.StatusDetails.Known := true;
  end;
end;

procedure TPureTestAllureLogger.MarkMuted(const Test: IPureTest);
var
  tr: IAllureTestResult;
begin
  if Cast(Allure.Lifecycle.GetObjectOfTag(TAllureTag(Test)), IAllureTestResult, tr) then begin
    tr.StatusDetails.Muted := true;
  end;
end;

procedure TPureTestAllureLogger.OnAfterExecuteTest(const Test: IPureTest);
begin

end;

procedure TPureTestAllureLogger.OnAfterSetupFixture(
  const Fixture: IPureTestFixture);
var
  container: IAllureTestResultContainer;
  before: IAllureFixtureResult;
  beforeUuid: TAllureString;
begin
  if Cast(Allure.Lifecycle.GetObjectOfTag(TAllureTag(Fixture)), IAllureTestResultContainer, container) and
     Cast(Allure.Lifecycle.GetCurrentObjectOfType(IAllureFixtureResult), IAllureFixtureResult, before)
  then begin
    before.Status := TAllureStatus(Fixture.Status);
    if Fixture.Details.Msg<>'' then
      before.StatusDetails.Message := Fixture.Details.Msg;
    //FillParameters(before, Instance, Method, Args, Result);
    beforeUuid := Allure.Lifecycle.GetUuidOfCurrentObjectOfType(IAllureFixtureResult);
    if beforeUuid<>'' then
      Allure.Lifecycle.StopFixture(beforeUuid);
  end;
end;

procedure TPureTestAllureLogger.OnAfterStep(const Step: IPureTestStep);
var
  astep: IAllureStepResult;
begin
  if Cast(Allure.Lifecycle.GetCurrentObjectOfType(IAllureStepResult), IAllureStepResult, astep) then begin
    astep.Status := TAllureStatus(Step.Status);
    if Step.Details.Msg<>'' then
      astep.StatusDetails.Message := Step.Details.Msg;
    //FillParameters(astep, Instance, Method, Args, Result);
  end;
  Allure.Lifecycle.StopStep;
end;

procedure TPureTestAllureLogger.OnAfterTearDownFixture(
  const Fixture: IPureTestFixture);
var
  container: IAllureTestResultContainer;
  after: IAllureFixtureResult;
  afterUuid: TAllureString;
begin
  if Cast(Allure.Lifecycle.GetObjectOfTag(TAllureTag(Fixture)), IAllureTestResultContainer, container) and
     Cast(Allure.Lifecycle.GetCurrentObjectOfType(IAllureFixtureResult), IAllureFixtureResult, after)
  then begin
    after.Status := TAllureStatus(Fixture.Status);
    if Fixture.Details.Msg<>'' then
      after.StatusDetails.Message := Fixture.Details.Msg;
    //FillParameters(after, Instance, Method, Args, Result);
    afterUuid := Allure.Lifecycle.GetUuidOfCurrentObjectOfType(IAllureFixtureResult);
    if afterUuid<>'' then
      Allure.Lifecycle.StopFixture(afterUuid);
  end;
end;

procedure TPureTestAllureLogger.OnBeforeExecuteTest(const Test: IPureTest);
var
  tr: IAllureTestResult;
begin
  //if not Test.Test.Active then exit;
  if Cast(Allure.Lifecycle.GetObjectOfTag(TAllureTag(Test)), IAllureTestResult, tr) then begin
    tr.Labels.AddNew.SetSeverity(TAllureSeverityLevel(Test.Severity));
  end;
end;

procedure TPureTestAllureLogger.OnBeforeSetupFixture(
  const Fixture: IPureTestFixture);
var
  container: IAllureTestResultContainer;
  before: IAllureFixtureResult;
begin
  if Cast(Allure.Lifecycle.GetObjectOfTag(TAllureTag(Fixture)), IAllureTestResultContainer, container)
  then begin
    before := CreateFixture(Fixture, true);
    Allure.Lifecycle.StartBeforeFixture(container.UUID, TAllureUuidHelper.CreateNew, before);
  end;
end;

procedure TPureTestAllureLogger.OnBeforeStep(const Step: IPureTestStep);
var
  astep: IAllureStepResult;
begin
  astep := CreateStep(Step);
  Allure.Lifecycle.StartStep(TAllureUuidHelper.CreateNew, astep);
end;

procedure TPureTestAllureLogger.OnBeforeTearDownFixture(
  const Fixture: IPureTestFixture);
var
  container: IAllureTestResultContainer;
  after: IAllureFixtureResult;
begin
  if Cast(Allure.Lifecycle.GetObjectOfTag(TAllureTag(Fixture)), IAllureTestResultContainer, container)
  then begin
    after := CreateFixture(Fixture, false);
    Allure.Lifecycle.StartAfterFixture(container.UUID, TAllureUuidHelper.CreateNew, after);
  end;
end;

procedure TPureTestAllureLogger.OnBeginTest(const Test: IPureTest);
var
  tr: IAllureTestResult;
  container: IAllureTestResultContainer;
begin
  //if not Test.Active then exit;
  Cast(Allure.Lifecycle.GetObjectOfTag(TAllureTag(Test.Fixture)), IAllureTestResultContainer, container);
  tr := CreateTestResult(Test);
  if container<>nil then
    Allure.Lifecycle.ScheduleTestCase(container.UUID, tr)
  else
    Allure.Lifecycle.ScheduleTestCase(tr);
  Allure.Lifecycle.StartTestCase(tr);
end;

procedure TPureTestAllureLogger.OnEndTest(const Test: IPureTest);
var
  tr: IAllureTestResult;
begin
  //if not Test.Test.Active then exit;
  if Cast(Allure.Lifecycle.GetObjectOfTag(TAllureTag(Test)), IAllureTestResult, tr) then begin
    tr.Status := TAllureStatus(Test.Status);
    if Test.Details.Msg<>'' then
      tr.StatusDetails.Message := Test.Details.Msg;
    Allure.Lifecycle.StopTestCase(tr.UUID);
    Allure.Lifecycle.WriteTestCase(tr.UUID);
  end;
end;

procedure TPureTestAllureLogger.OnEndTestFixture(const Fixture: IPureTestFixture);
var
  container: IAllureTestResultContainer;
begin
  if Cast(Allure.Lifecycle.GetObjectOfTag(TAllureTag(Fixture)), IAllureTestResultContainer, container)
  then begin
    Allure.Lifecycle.StopTestContainer(container.UUID);
    Allure.Lifecycle.WriteTestContainer(container.UUID);
  end;
end;

procedure TPureTestAllureLogger.OnStartTestFixture(
  const Fixture: IPureTestFixture);
var
  container: IAllureTestResultContainer;
begin
  container := CreateContainerOfFixture(fixture);
  Allure.Lifecycle.StartTestContainer(container);
end;

procedure TPureTestAllureLogger.OnTestingEnds(const Context: IPureTestsContext);
begin
  Allure.Finalize;
end;

procedure TPureTestAllureLogger.OnTestingStarts(const Context: IPureTestsContext);
begin
  Allure.Initialize;
  if FileExists(ConfigFileName) then
    Allure.Lifecycle.AssignConfigFromFile(ConfigFileName);
  Allure.Lifecycle.CleanupResultDirectory;
end;

procedure TPureTestAllureLogger.SetConfigFileName(const Value: string);
begin
  fConfigFileName := Value;
end;

end.
