unit allureLifecycle;

interface

uses
  System.SysUtils, Winapi.Windows, allureDelphiInterface, allureCommon,
  allureConfig, System.IOUtils, allureModel, allureThreadSafelist,
  allureDelphiHelper, allureFileSystemResultsWriter;

type

  TAllureLifecycle = class(TAllureInterfacedObject, IAllureLifecycle)
  private class var
    fLifecycle: TAllureLifecycle;
  private
    fConfig: TAllureConfiguration;
    fStorage: TAllureThreadSafeDictionary;
    fThreadContext: TAllureThreadLocalStringList;
    fWriter: IAllureResultsWriter;
    function GetWriter: IAllureResultsWriter;
    function CreateDefaultWriter: IAllureResultsWriter;

    property Writer: IAllureResultsWriter read GetWriter;
  public
    class function GetLifecycle: TAllureLifecycle; static;
    class procedure FreeLifecycle; static;
    class property Lifecycle: TAllureLifecycle read GetLifecycle;
    class constructor CreateClass;
    class destructor DestroyClass;

    constructor Create;
    destructor Destroy; override;
  public
    function GetJsonConfiguration: TAllureString; safecall;
    procedure SetJsonConfiguration(const Value: TAllureString); safecall;
    function GetResultsDirectory: TAllureString; safecall;
    function GetAllureConfiguration: IAllureConfiguration; safecall;

    property AllureConfiguration: IAllureConfiguration read GetAllureConfiguration;
    property ResultsDirectory: TAllureString read GetResultsDirectory;
    property JsonConfiguration: TAllureString read GetJsonConfiguration write SetJsonConfiguration;

    procedure AssignConfigFromFile(const JsonConfigurationFile: TAllureString = ''); safecall;

    function CreateTestResult: IAllureTestResult; safecall;

    // TestContainer
    (*
     * Starts test container with specified parent container.
     *
     * @param ParentUuid the uuid of parent container.
     * @param container     the container.
    *)
    function StartTestContainer(const ParentUuid: TAllureString; const Container: IAllureTestResultContainer): IAllureLifecycle; overload; safecall;
    (* Starts test container.*)
    function StartTestContainer(const Container: IAllureTestResultContainer): IAllureLifecycle; overload; safecall;
    (**
     * Updates test container.
     *
     * @param uuid   the uuid of container.
     * @param update the update function.
     *)
    function UpdateTestContainer(const Uuid: TAllureString; const Update: IAllureTestResultContainerAction): IAllureLifecycle; safecall;
    (**
     * Stops test container by given uuid.
     *
     * @param uuid the uuid of container.
     *)
    function StopTestContainer(const Uuid: TAllureString): IAllureLifecycle; safecall;
    (**
     * Writes test container with given uuid.
     *
     * @param uuid the uuid of container.
     *)
    function WriteTestContainer(const Uuid: TAllureString): IAllureLifecycle; safecall;

    // Fixture
    (**
     * Start a new prepare fixture with given parent.
     *
     * @param containerUuid the uuid of parent container.
     * @param uuid          the fixture uuid.
     * @param result        the fixture.
     *)
    function StartBeforeFixture(const ParentUuid, Uuid: TAllureString; const Res: IAllureFixtureResult): IAllureLifecycle; safecall;
    (**
     * Start a new tear down fixture with given parent.
     *
     * @param containerUuid the uuid of parent container.
     * @param uuid          the fixture uuid.
     * @param result        the fixture.
     *)
    function StartAfterFixture(const ParentUuid, Uuid: TAllureString; const Res: IAllureFixtureResult): IAllureLifecycle; safecall;
    (**
     * Start a new fixture with given uuid.
     *
     * @param uuid   the uuid of fixture.
     * @param result the test fixture.
     *)
    function StartFixture(const Uuid: TAllureString; const Res: IAllureFixtureResult): IAllureLifecycle; safecall;
    (**
     * Updates current running fixture. Shortcut for {@link #updateFixture(String, Consumer)}.
     *
     * @param update the update function.
     *)
    function UpdateFixture(const Update: IAllureFixtureResultAction): IAllureLifecycle; overload; safecall;
    (**
     * Updates fixture by given uuid.
     *
     * @param uuid   the uuid of fixture.
     * @param update the update function.
     *)
    function UpdateFixture(const Uuid: TAllureString; const Update: IAllureFixtureResultAction): IAllureLifecycle; overload; safecall;
    function StopFixture(const BeforeStop: IAllureFixtureResultAction): IAllureLifecycle; overload; safecall;
    (**
     * Stops fixture by given uuid.
     *
     * @param uuid the uuid of fixture.
     *)
    function StopFixture(const Uuid: TAllureString): IAllureLifecycle; overload; safecall;

    // TestCase
    (**
     * Schedules test case with given parent.
     *
     * @param containerUuid the uuid of container.
     * @param result        the test case to schedule.
     *)
    function ScheduleTestCase(const ContainerUuid: TAllureString; const TestResult: IAllureTestResult): IAllureLifecycle; overload; safecall;
    (**
     * Schedule given test case.
     *
     * @param result the test case to schedule.
     *)
    function ScheduleTestCase(const TestResult: IAllureTestResult): IAllureLifecycle; overload; safecall;
    (**
     * Starts test case with given uuid. In order to start test case it should be scheduled at first.
     *
     * @param uuid the uuid of test case to start.
     *)
    function StartTestCase(const Uuid: TAllureString): IAllureLifecycle; overload; safecall;
    function StartTestCase(const ContainerUuid: TAllureString; const TestResult: IAllureTestResult): IAllureLifecycle; overload; safecall;
    function StartTestCase(const TestResult: IAllureTestResult): IAllureLifecycle; overload; safecall;
    (**
     * Shortcut for {@link #updateTestCase(String, Consumer)} for current running test case uuid.
     *
     * @param update the update function.
     *)
    function UpdateTestCase(const Update: IAllureTestResultAction): IAllureLifecycle; overload; safecall;
    (**
     * Updates test case by given uuid.
     *
     * @param uuid   the uuid of test case to update.
     * @param update the update function.
     *)
    function UpdateTestCase(const Uuid: TAllureString; const Update: IAllureTestResultAction): IAllureLifecycle; overload; safecall;
    (**
     * Stops test case by given uuid. Test case marked as {@link Stage#FINISHED} and also
     * stop timestamp is calculated. Result would be stored in memory until
     * {@link #writeTestCase(String)} method is called. Also stopped test case could be
     * updated by {@link #updateTestCase(String, Consumer)} method.
     *
     * @param uuid the uuid of test case to stop.
     *)
    function StopTestCase(const BeforeStop: IAllureTestResultAction): IAllureLifecycle; overload; safecall;
    function StopTestCase(const Uuid: TAllureString): IAllureLifecycle; overload; safecall;
    (**
     * Writes test case with given uuid using configured {@link AllureResultsWriter}.
     *
     * @param uuid the uuid of test case to write.
     *)
    function WriteTestCase(const Uuid: TAllureString): IAllureLifecycle; safecall;

    // Step
    (**
     * Start a new step as child step of current running test case or step. Shortcut
     * for {@link #startStep(String, String, StepResult)}.
     *
     * @param uuid   the uuid of step.
     * @param result the step.
     *)
    function StartStep(const Uuid: TAllureString; const StepResult: IAllureStepResult): IAllureLifecycle; overload; safecall;
    (**
     * Start a new step as child of specified parent.
     *
     * @param parentUuid the uuid of parent test case or step.
     * @param uuid       the uuid of step.
     * @param result     the step.
     *)
    function StartStep(const ParentUuid, Uuid: TAllureString; const StepResult: IAllureStepResult): IAllureLifecycle; overload; safecall;
    (**
     * Updates current step. Shortcut for {@link #updateStep(String, Consumer)}.
     *
     * @param update the update function.
     *)
    function UpdateStep(Update: IAllureStepResultAction): IAllureLifecycle; overload; safecall;
    (**
     * Updates step by specified uuid.
     *
     * @param uuid   the uuid of step.
     * @param update the update function.
     *)
    function UpdateStep(const Uuid: TAllureString; Update: IAllureStepResultAction): IAllureLifecycle; overload; safecall;
    (**
     * Stops current running step. Shortcut for {@link #stopStep(String)}.
     *)
    function StopStep(): IAllureLifecycle; overload; safecall;
    function StopStep(beforeStop: IAllureStepResultAction): IAllureLifecycle; overload; safecall;
    (**
     * Stops step by given uuid.
     *
     * @param uuid the uuid of step to stop.
     *)
    function StopStep(const Uuid: TAllureString): IAllureLifecycle; overload; safecall;

    // Attachment
    function AddAttachment(const Name, AType, Path: TAllureString): IAllureLifecycle; overload; safecall;
    function AddAttachment(const Name, AType: TAllureString; Content: Pointer; Size: UInt64; const FileExtension: TAllureString = ''): IAllureLifecycle; overload; safecall;
    function AddAttachment(const Path: TAllureString; const Name: TAllureString = ''): IAllureLifecycle; overload; safecall;

    // Extensions
    procedure CleanupResultDirectory(); safecall;
  end;

  function GetAllureLifecycle: IAllureLifecycle; safecall;
  procedure FreeAllureLifecycle; safecall;

exports
  GetAllureLifecycle,
  FreeAllureLifecycle;

implementation

function GetAllureLifecycle: IAllureLifecycle;
begin
  result := TAllureLifecycle.GetLifecycle;
end;

procedure FreeAllureLifecycle;
begin
  TAllureLifecycle.FreeLifecycle;
end;

{ TAllureLifecycle }

function TAllureLifecycle.AddAttachment(const Name, AType,
  Path: TAllureString): IAllureLifecycle;
begin
  result := self;

end;

function TAllureLifecycle.AddAttachment(const Name, AType: TAllureString;
  Content: Pointer; Size: UInt64;
  const FileExtension: TAllureString): IAllureLifecycle;
begin
  result := self;

end;

function TAllureLifecycle.AddAttachment(const Path,
  Name: TAllureString): IAllureLifecycle;
begin
  result := self;

end;

procedure TAllureLifecycle.AssignConfigFromFile(
  const JsonConfigurationFile: TAllureString);
var
  c: string;
begin
  if not FileExists(JsonConfigurationFile) then
    raise EAllureException.Create('Allure config file missing: ' + JsonConfigurationFile);
  try
    c := TFile.ReadAllText(JsonConfigurationFile);
    SetJsonConfiguration(c);
  except
  end;
end;

procedure TAllureLifecycle.CleanupResultDirectory;
var
  pth: string;
begin
  try
    pth := ResultsDirectory;
    if DirectoryExists(pth) then begin
      TDirectory.Delete(pth, true);
    end;
    TDirectory.CreateDirectory(pth);
  except
  end;
end;

constructor TAllureLifecycle.Create;
begin
  inherited Create;
  fConfig := nil;
  fStorage := TAllureThreadSafeDictionary.Create;
  fThreadContext := TAllureThreadLocalStringList.Create;
end;

class constructor TAllureLifecycle.CreateClass;
begin
  fLifecycle := nil;
end;

function TAllureLifecycle.CreateDefaultWriter: IAllureResultsWriter;
begin
  result := TAllureFileSystemResultsWriter.Create(ResultsDirectory);
end;

function TAllureLifecycle.CreateTestResult: IAllureTestResult;
var
  res: TAllureTestResult;
begin
  res := TAllureTestResult.Create;
  res.UUID := Copy(AnsiLowerCase(TGUID.NewGuid.ToString), 2, 36);
  result := res;
  res.SelfIncrement := false;
end;

destructor TAllureLifecycle.Destroy;
begin
  fThreadContext.Free;
  fStorage.Free;
  fConfig.Free;
  inherited;
end;

class destructor TAllureLifecycle.DestroyClass;
begin
  try
    fLifecycle.Free;
    fLifecycle := nil;
  except
  end;
end;

class procedure TAllureLifecycle.FreeLifecycle;
begin
  if fLifecycle<>nil then begin
    if fLifecycle.RefCount=1 then begin
      fLifecycle.Free;
      fLifecycle := nil;
    end;
  end;
end;

function TAllureLifecycle.GetAllureConfiguration: IAllureConfiguration;
begin
  if fConfig=nil then begin
    fConfig := TAllureConfiguration.Create;
  end;
  result := fConfig;
end;

function TAllureLifecycle.GetJsonConfiguration: TAllureString;
begin
  GetAllureConfiguration;
  result := fConfig.JsonConfiguration;
end;

class function TAllureLifecycle.GetLifecycle: TAllureLifecycle;
begin
  if fLifecycle=nil then begin
    fLifecycle := TAllureLifecycle.Create;
  end;
  result := fLifecycle;
end;

function TAllureLifecycle.GetResultsDirectory: TAllureString;
begin
  GetAllureConfiguration;
  result := fConfig.Directory;
end;

function TAllureLifecycle.GetWriter: IAllureResultsWriter;
begin
  if fWriter=nil then begin
    fWriter := CreateDefaultWriter;
  end;
  result := fWriter;
end;

function TAllureLifecycle.ScheduleTestCase(
  const TestResult: IAllureTestResult): IAllureLifecycle;
begin
  result := self;
  if TestResult=nil then exit;
  TestResult.Stage := asScheduled;
  fStorage.AddObject(TestResult.UUID, TestResult);
end;

function TAllureLifecycle.ScheduleTestCase(const ContainerUuid: TAllureString;
  const TestResult: IAllureTestResult): IAllureLifecycle;
begin
  result := self;

end;

procedure TAllureLifecycle.SetJsonConfiguration(const Value: TAllureString);
begin
  GetAllureConfiguration;
  fConfig.ReadFromJson(Value);
end;

function TAllureLifecycle.StartAfterFixture(const ParentUuid,
  Uuid: TAllureString; const Res: IAllureFixtureResult): IAllureLifecycle;
begin
  result := self;

end;

function TAllureLifecycle.StartBeforeFixture(const ParentUuid,
  Uuid: TAllureString; const Res: IAllureFixtureResult): IAllureLifecycle;
begin
  result := self;

end;

function TAllureLifecycle.StartFixture(const Uuid: TAllureString;
  const Res: IAllureFixtureResult): IAllureLifecycle;
begin
  result := self;

end;

function TAllureLifecycle.StartStep(const Uuid: TAllureString;
  const StepResult: IAllureStepResult): IAllureLifecycle;
begin
  result := self;

end;

function TAllureLifecycle.StartStep(const ParentUuid, Uuid: TAllureString;
  const StepResult: IAllureStepResult): IAllureLifecycle;
begin
  result := self;

end;

function TAllureLifecycle.StartTestCase(const ContainerUuid: TAllureString;
  const TestResult: IAllureTestResult): IAllureLifecycle;
begin
  result := self;

end;

function TAllureLifecycle.StartTestCase(
  const TestResult: IAllureTestResult): IAllureLifecycle;
begin
  result := self;
  fThreadContext.Clear;
  if TestResult=nil then exit;
  TestResult.Stage := asRunning;
  TestResult.Start := TAllureTime.Now;
  fThreadContext.Push(TestResult.UUID);
end;

function TAllureLifecycle.StartTestCase(
  const Uuid: TAllureString): IAllureLifecycle;
var
  res: TAllureTestResult;
begin
  result := self;
  res := fStorage.Get<TAllureTestResult>(uuid);
  if res=nil then begin
    //LOGGER.error("Could not start test case: test case with uuid {} is not scheduled", uuid);
    exit;
  end;
  StartTestCase(res)
end;

function TAllureLifecycle.StartTestContainer(
  const Container: IAllureTestResultContainer): IAllureLifecycle;
begin
  result := self;

end;

function TAllureLifecycle.StartTestContainer(const ParentUuid: TAllureString;
  const Container: IAllureTestResultContainer): IAllureLifecycle;
begin
  result := self;

end;

function TAllureLifecycle.StopFixture(
  const Uuid: TAllureString): IAllureLifecycle;
begin
  result := self;

end;

function TAllureLifecycle.StopFixture(
  const BeforeStop: IAllureFixtureResultAction): IAllureLifecycle;
begin
  result := self;

end;

function TAllureLifecycle.StopStep(
  beforeStop: IAllureStepResultAction): IAllureLifecycle;
begin
  result := self;

end;

function TAllureLifecycle.StopStep(const Uuid: TAllureString): IAllureLifecycle;
begin
  result := self;

end;

function TAllureLifecycle.StopStep: IAllureLifecycle;
begin
  result := self;

end;

function TAllureLifecycle.StopTestCase(
  const Uuid: TAllureString): IAllureLifecycle;
var
  res: TAllureTestResult;
begin
  result := self;
  res := fStorage.Get<TAllureTestResult>(Uuid);
  if res=nil then begin
    //LOGGER.error("Could not stop test case: test case with uuid {} not found", uuid);
    exit;
  end;
  res.Stage := asFinished;
  res.Stop := TAllureTime.Now;
  fThreadContext.Clear;
end;

function TAllureLifecycle.StopTestCase(
  const BeforeStop: IAllureTestResultAction): IAllureLifecycle;
begin
  result := self;

end;

function TAllureLifecycle.StopTestContainer(
  const Uuid: TAllureString): IAllureLifecycle;
begin
  result := self;

end;

function TAllureLifecycle.UpdateFixture(const Uuid: TAllureString;
  const Update: IAllureFixtureResultAction): IAllureLifecycle;
begin
  result := self;

end;

function TAllureLifecycle.UpdateFixture(
  const Update: IAllureFixtureResultAction): IAllureLifecycle;
begin
  result := self;

end;

function TAllureLifecycle.UpdateStep(const Uuid: TAllureString;
  Update: IAllureStepResultAction): IAllureLifecycle;
begin
  result := self;

end;

function TAllureLifecycle.UpdateStep(
  Update: IAllureStepResultAction): IAllureLifecycle;
begin
  result := self;

end;

function TAllureLifecycle.UpdateTestCase(
  const Update: IAllureTestResultAction): IAllureLifecycle;
begin
  result := self;

end;

function TAllureLifecycle.UpdateTestCase(const Uuid: TAllureString;
  const Update: IAllureTestResultAction): IAllureLifecycle;
begin
  result := self;

end;

function TAllureLifecycle.UpdateTestContainer(const Uuid: TAllureString;
  const Update: IAllureTestResultContainerAction): IAllureLifecycle;
begin
  result := self;

end;

function TAllureLifecycle.WriteTestCase(
  const Uuid: TAllureString): IAllureLifecycle;
var
  res: TAllureTestResult;
begin
  result := self;
  res := fStorage.Get<TAllureTestResult>(Uuid);
  if res=nil then begin
    //LOGGER.error("Could not write test case: test case with uuid {} not found", uuid);
    exit;
  end;
  Writer.WriteTest(res);
  fStorage.RemoveObject(Uuid);
end;

function TAllureLifecycle.WriteTestContainer(
  const Uuid: TAllureString): IAllureLifecycle;
begin
  result := self;

end;

end.
