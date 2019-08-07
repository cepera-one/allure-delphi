unit allureLifecycle;

interface

uses
  System.SysUtils, Winapi.Windows, allureDelphiInterface, allureCommon,
  allureConfig, System.IOUtils, allureModel, allureThreadSafelist,
  allureDelphiHelper, allureFileSystemResultsWriter, Winapi.ActiveX,
  System.Classes, Vcl.AxCtrls;

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
    function PrepareAttachment(const Name, AType, FileExtension: TAllureString): TAllureString;

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
    function CreateTestResultContainer: IAllureTestResultContainer; safecall;
    function CreateStepResult: IAllureStepResult; safecall;
    function CreateFixture: IAllureFixtureResult; safecall;

    // Search for started and not closed container or test by Uuid
    function GetObjectOfUuid(const Uuid: TAllureString): IUnknown; safecall;

    // Search for started and not closed container or test by Tag
    function GetObjectOfTag(Tag: TAllureTag): IUnknown; safecall;

    // Return last Step, Fixture or Container
    function GetCurrentObjectOfType(const InterfaceGUID: TGUID): IUnknown; safecall;
    // Returns the Uuid of the last Step, Fixture or Container
    function GetUuidOfCurrentObjectOfType(const InterfaceGUID: TGUID): TAllureString; safecall;

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
    function StopTestCase(const BeforeStop: IAllureTestResultAction=nil): IAllureLifecycle; overload; safecall;
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
    function AddAttachment(const Name, AType, FileExtension: TAllureString; const Stream: IStream): IAllureLifecycle; overload; safecall;
    function AddAttachment(const Name, AType, Path: TAllureString): IAllureLifecycle; overload; safecall;
    function AddAttachment(const Name, AType: TAllureString; Content: Pointer; Size: UInt64; const FileExtension: TAllureString = ''): IAllureLifecycle; overload; safecall;
    function AddAttachment(const Path: TAllureString; const Name: TAllureString = ''): IAllureLifecycle; overload; safecall;

    // Extensions
    procedure CleanupResultDirectory(); safecall;

    function Environment: IAllureEnvironment; safecall;
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
var
  source: TAllureString;
  s: TFileStream;
begin
  result := self;
  if not FileExists(Path) then exit;
  source := PrepareAttachment(Name, AType, ExtractFileExt(Path));
  if source<>'' then begin
    try
      s := TFileStream.Create(Path, fmShareDenyNone, fmShareCompat);
      try
        Writer.WriteAttachment(source, s);
      finally
        s.Free;
      end;
    except
    end;
  end;
end;

function TAllureLifecycle.AddAttachment(const Name, AType: TAllureString;
  Content: Pointer; Size: UInt64;
  const FileExtension: TAllureString): IAllureLifecycle;
var
  source: TAllureString;
  s: TExtMemoryStream;
begin
  result := self;
  if (Content=nil) or (Size=0) then exit;
  source := PrepareAttachment(Name, AType, FileExtension);
  if source<>'' then begin
    try
      s := TExtMemoryStream.Create(Content, Size);
      try
        Writer.WriteAttachment(source, s);
      finally
        s.Free;
      end;
    except
    end;
  end;
end;

function TAllureLifecycle.AddAttachment(const Path,
  Name: TAllureString): IAllureLifecycle;
var
  AName, AType: TAllureString;
begin
  result := self;
  if not FileExists(Path) then exit;
  if Name='' then
    AName := ExtractFileName(Path)
  else
    AName := Name;
  AType := TMimeTypesMap.GetMimeType(Path);
  result := AddAttachment(AName, AType, Path);
end;

function TAllureLifecycle.AddAttachment(const Name, AType,
  FileExtension: TAllureString; const Stream: IStream): IAllureLifecycle;
var
  source: TAllureString;
  s: TOleStream;
begin
  result := self;
  if Stream=nil then exit;
  source := PrepareAttachment(Name, AType, FileExtension);
  if source<>'' then begin
    try
      s := TOleStream.Create(Stream);
      try
        Writer.WriteAttachment(source, s);
      finally
        s.Free;
      end;
    except
    end;
  end;
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
  result := TAllureFileSystemResultsWriter.Create(AllureConfiguration);
end;

function TAllureLifecycle.CreateFixture: IAllureFixtureResult;
var
  res: TAllureFixtureResult;
begin
  res := TAllureFixtureResult.Create;
  result := res;
  res.SelfIncrement := false;
end;

function TAllureLifecycle.CreateStepResult: IAllureStepResult;
var
  res: TAllureStepResult;
begin
  res := TAllureStepResult.Create;
  result := res;
  res.SelfIncrement := false;
end;

function TAllureLifecycle.CreateTestResult: IAllureTestResult;
var
  res: TAllureTestResult;
begin
  res := TAllureTestResult.Create;
  res.UUID := TAllureUuidHelper.CreateNew;
  result := res;
  res.SelfIncrement := false;
end;

function TAllureLifecycle.CreateTestResultContainer: IAllureTestResultContainer;
var
  res: TAllureTestResultContainer;
begin
  res := TAllureTestResultContainer.Create;
  res.UUID := TAllureUuidHelper.CreateNew;
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

function TAllureLifecycle.Environment: IAllureEnvironment;
begin
  result := TAllureEnvironment.Create(ResultsDirectory + '\environment.properties');
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

function TAllureLifecycle.GetCurrentObjectOfType(
  const InterfaceGUID: TGUID): IUnknown;
var
  Uuids: TAllureThreadLocalStringList.TListOfStrings;
  obj: TAllureInterfacedObject;
  i: Integer;
begin
  result := nil;
  fThreadContext.Lock;
  fStorage.Lock;
  try
    Uuids := fThreadContext.List;
    for i := Uuids.Count-1 downto 0 do begin
      obj := fStorage.GetObject(Uuids[i]);
      if (obj<>nil) and obj.GetInterface(InterfaceGUID, result) then
        break;
    end;
  finally
    fStorage.Unlock;
    fThreadContext.Unlock;
  end;
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

function TAllureLifecycle.GetObjectOfTag(Tag: TAllureTag): IUnknown;
var
  obj: TAllureInterfacedObject;
begin
  result := nil;
  fStorage.Lock;
  try
    for obj in fStorage.Values do begin
      if (obj is TAllureTestResultContainer) and (TAllureTestResultContainer(obj).Tag=Tag) or
         (obj is TAllureExecutableItem) and (TAllureExecutableItem(obj).Tag=Tag)
      then begin
        result := obj;
        break;
      end;
    end;
  finally
    fStorage.Unlock;
  end;
end;

function TAllureLifecycle.GetObjectOfUuid(const Uuid: TAllureString): IUnknown;
begin
  result := fStorage.GetObject(Uuid);
end;

function TAllureLifecycle.GetResultsDirectory: TAllureString;
begin
  GetAllureConfiguration;
  result := fConfig.Directory;
end;

function TAllureLifecycle.GetUuidOfCurrentObjectOfType(
  const InterfaceGUID: TGUID): TAllureString;
var
  Uuids: TAllureThreadLocalStringList.TListOfStrings;
  uuid: TAllureString;
  obj: TAllureInterfacedObject;
  intf: IUnknown;
  i: Integer;
begin
  result := '';
  fThreadContext.Lock;
  fStorage.Lock;
  try
    Uuids := fThreadContext.List;
    for i := Uuids.Count-1 downto 0 do begin
      uuid := Uuids[i];
      obj := fStorage.GetObject(uuid);
      if (obj<>nil) and obj.GetInterface(InterfaceGUID, intf) then
        exit(uuid);
    end;
  finally
    fStorage.Unlock;
    fThreadContext.Unlock;
  end;
end;

function TAllureLifecycle.GetWriter: IAllureResultsWriter;
begin
  if fWriter=nil then begin
    fWriter := CreateDefaultWriter;
  end;
  result := fWriter;
end;

function TAllureLifecycle.PrepareAttachment(const Name, AType,
  FileExtension: TAllureString): TAllureString;
var
  ext, uuid: TAllureString;
  a: TAllureAttachment;
  eItem: TAllureExecutableItem;
begin
  if FileExtension<>'' then begin
    if FileExtension[1]<>'.' then
      ext := '.' + FileExtension
    else
      ext := FileExtension;
  end else
    ext := FileExtension;
  result := TAllureUuidHelper.CreateNew + ATTACHMENT_FILE_SUFFIX + ext;
  uuid := fThreadContext.Peek;
  if uuid='' then begin
    //LOGGER.error("Could not add attachment: no test is running");
    exit;
  end;
  eItem := fStorage.Get<TAllureExecutableItem>(uuid);
  if eItem<>nil then begin
    a := TAllureAttachment.Create;
    a.Name := Name;
    a.AttachmentType := AType;
    a.Source := result;
    eItem.Attachments.Add(a);
  end;
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
var
  container: TAllureTestResultContainer;
begin
  result := self;
  if TestResult=nil then exit;
  container := fStorage.Get<TAllureTestResultContainer>(ContainerUuid);
  if container<>nil then begin
    container.Children.Add(TestResult.UUID);
  end;
  ScheduleTestCase(TestResult);
end;

procedure TAllureLifecycle.SetJsonConfiguration(const Value: TAllureString);
begin
  GetAllureConfiguration;
  fConfig.ReadFromJson(Value);
end;

function TAllureLifecycle.StartAfterFixture(const ParentUuid,
  Uuid: TAllureString; const Res: IAllureFixtureResult): IAllureLifecycle;
var
  container: TAllureTestResultContainer;
begin
  result := self;
  if Res=nil then exit;
  container := fStorage.Get<TAllureTestResultContainer>(ParentUuid);
  if container<>nil then begin
    container.Afters.Add(res);
  end;
  StartFixture(Uuid, res);
end;

function TAllureLifecycle.StartBeforeFixture(const ParentUuid,
  Uuid: TAllureString; const Res: IAllureFixtureResult): IAllureLifecycle;
var
  container: TAllureTestResultContainer;
begin
  result := self;
  if Res=nil then exit;
  container := fStorage.Get<TAllureTestResultContainer>(ParentUuid);
  if container<>nil then begin
    container.Befores.Add(res);
  end;
  StartFixture(Uuid, res);
end;

function TAllureLifecycle.StartFixture(const Uuid: TAllureString;
  const Res: IAllureFixtureResult): IAllureLifecycle;
begin
  result := self;
  if Res=nil then exit;
  fStorage.AddObject(Uuid, res);
  res.Stage := asRunning;
  res.Start := TAllureTime.Now;
  fThreadContext.Clear;
  fThreadContext.Push(Uuid);
end;

function TAllureLifecycle.StartStep(const Uuid: TAllureString;
  const StepResult: IAllureStepResult): IAllureLifecycle;
var
  parentUuid: TAllureString;
begin
  result := self;
  parentUuid := fThreadContext.Peek;
  if parentUuid='' then begin
    //LOGGER.error("Could not start step: no test case running");
    exit;
  end;
  StartStep(parentUuid, Uuid, StepResult);
end;

function TAllureLifecycle.StartStep(const ParentUuid, Uuid: TAllureString;
  const StepResult: IAllureStepResult): IAllureLifecycle;
var
  parentStep: TAllureExecutableItem;
begin
  result := self;
  if StepResult=nil then exit;
  StepResult.Stage := asRunning;
  StepResult.Start := TAllureTime.Now;

  fThreadContext.Push(Uuid);

  fStorage.AddObject(Uuid, StepResult);
  parentStep := fStorage.Get<TAllureExecutableItem>(parentUuid);
  if parentStep<>nil then begin
    parentStep.Steps.Add(StepResult);
  end;
end;

function TAllureLifecycle.StartTestCase(const ContainerUuid: TAllureString;
  const TestResult: IAllureTestResult): IAllureLifecycle;
var
  container: TAllureTestResultContainer;
begin
  result := self;
  if TestResult=nil then exit;
  container := fStorage.Get<TAllureTestResultContainer>(ContainerUuid);
  if container<>nil then begin
    container.Children.Add(TestResult.UUID);
  end;
  StartTestCase(TestResult);
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
  if Container=nil then
    exit;
  Container.Start := TAllureTime.Now;
  fStorage.AddObject(Container.UUID, Container);
end;

function TAllureLifecycle.StartTestContainer(const ParentUuid: TAllureString;
  const Container: IAllureTestResultContainer): IAllureLifecycle;
var
  parent: TAllureTestResultContainer;
begin
  result := self;
  if Container=nil then exit;
  parent := fStorage.Get<TAllureTestResultContainer>(ParentUuid);
  if parent<>nil then begin
    parent.Children.Add(Container.UUID);
  end;
  StartTestContainer(Container);
end;

function TAllureLifecycle.StopFixture(
  const Uuid: TAllureString): IAllureLifecycle;
var
  fixture: TAllureFixtureResult;
begin
  result := self;
  fixture := fStorage.Get<TAllureFixtureResult>(Uuid);
  if fixture=nil then begin
    //LOGGER.error("Could not stop test fixture: test fixture with uuid {} not found", uuid);
    exit;
  end;

  fixture.Stage := asFinished;
  fixture.Stop := TAllureTime.Now;

  fStorage.RemoveObject(uuid);
  fThreadContext.Clear;
end;

function TAllureLifecycle.StopFixture(
  const BeforeStop: IAllureFixtureResultAction): IAllureLifecycle;
var
  uuid: TAllureString;
begin
  result := self;
  if BeforeStop=nil then exit;
  UpdateFixture(BeforeStop);
  uuid := fThreadContext.Root;
  if uuid='' then begin
    //LOGGER.error("Could not stop test fixture: no test fixture running");
    exit;
  end;
  StopFixture(uuid);
end;

function TAllureLifecycle.StopStep(
  beforeStop: IAllureStepResultAction): IAllureLifecycle;
begin
  result := self;
  if beforeStop<>nil then
    UpdateStep(beforeStop);
  StopStep;
end;

function TAllureLifecycle.StopStep(const Uuid: TAllureString): IAllureLifecycle;
var
  step: TAllureStepResult;
begin
  result := self;
  step := fStorage.Get<TAllureStepResult>(Uuid);
  if step=nil then begin
    //LOGGER.error("Could not stop step: step with uuid {} not found", uuid);
    exit;
  end;
  step.Stage := asFinished;
  step.Stop := TAllureTime.Now;

  fStorage.RemoveObject(Uuid);
  fThreadContext.Pop();
end;

function TAllureLifecycle.StopStep: IAllureLifecycle;
var
  uuid: TAllureString;
begin
  result := self;
  uuid := fThreadContext.Peek;
  if uuid='' then begin
    //LOGGER.error("Could not stop step: no step running");
    exit;
  end;
  StopStep(uuid);
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
var
  uuid: TAllureString;
begin
  result := self;
  if BeforeStop<>nil then
    UpdateTestCase(BeforeStop);
  uuid := fThreadContext.Root;
  if uuid<>'' then
    StopTestCase(uuid);
end;

function TAllureLifecycle.StopTestContainer(
  const Uuid: TAllureString): IAllureLifecycle;
var
  container: TAllureTestResultContainer;
begin
  result := self;
  container := fStorage.Get<TAllureTestResultContainer>(Uuid);
  if container=nil then begin
    //LOGGER.error("Could not stop test container: container with uuid {} not found", uuid);
    exit;
  end;
  container.Stop := TAllureTime.Now;
end;

function TAllureLifecycle.UpdateFixture(const Uuid: TAllureString;
  const Update: IAllureFixtureResultAction): IAllureLifecycle;
var
  fixture: TAllureFixtureResult;
begin
  result := self;
  if Update=nil then exit;
  fixture := fStorage.Get<TAllureFixtureResult>(Uuid);
  if fixture=nil then begin
    //LOGGER.error("Could not update test fixture: test fixture with uuid {} not found", uuid);
    exit;
  end;
  Update.Invoke(fixture);
end;

function TAllureLifecycle.UpdateFixture(
  const Update: IAllureFixtureResultAction): IAllureLifecycle;
var
  uuid: TAllureString;
begin
  result := self;
  if Update=nil then exit;
  uuid := fThreadContext.Root;
  if uuid='' then begin
    //LOGGER.error("Could not update test fixture: no test fixture running");
    exit;
  end;
  UpdateFixture(uuid, Update);
end;

function TAllureLifecycle.UpdateStep(const Uuid: TAllureString;
  Update: IAllureStepResultAction): IAllureLifecycle;
var
  step: TAllureStepResult;
begin
  result := self;
  if Update=nil then exit;
  step := fStorage.Get<TAllureStepResult>(Uuid);
  if step=nil then begin
    //LOGGER.error("Could not update step: step with uuid {} not found", uuid);
    exit;
  end;
  Update.Invoke(step);
end;

function TAllureLifecycle.UpdateStep(
  Update: IAllureStepResultAction): IAllureLifecycle;
var
  uuid: TAllureString;
begin
  result := self;
  if Update=nil then exit;
  uuid := fThreadContext.Peek;
  UpdateStep(uuid, Update);
end;

function TAllureLifecycle.UpdateTestCase(
  const Update: IAllureTestResultAction): IAllureLifecycle;
var
  uuid: TAllureString;
begin
  result := self;
  if Update=nil then exit;
  uuid := fThreadContext.Root;
  if uuid='' then begin
    //LOGGER.error("Could not update test case: no test case running");
    exit;
  end;
  UpdateTestCase(uuid, Update);
end;

function TAllureLifecycle.UpdateTestCase(const Uuid: TAllureString;
  const Update: IAllureTestResultAction): IAllureLifecycle;
var
  testResult: TAllureTestResult;
begin
  result := self;
  if Update=nil then exit;
  testResult := fStorage.Get<TAllureTestResult>(Uuid);
  if testResult=nil then begin
    //LOGGER.error("Could not update test case: test case with uuid {} not found", uuid);
    exit;
  end;
  Update.Invoke(testResult);
end;

function TAllureLifecycle.UpdateTestContainer(const Uuid: TAllureString;
  const Update: IAllureTestResultContainerAction): IAllureLifecycle;
var
  container: TAllureTestResultContainer;
begin
  result := self;
  if Update=nil then exit;
  container := fStorage.Get<TAllureTestResultContainer>(uuid);
  if container=nil then begin
    //LOGGER.error("Could not update test container: container with uuid {} not found", uuid);
    exit;
  end;
  Update.Invoke(container);
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
var
  container: TAllureTestResultContainer;
begin
  result := self;
  container := fStorage.Get<TAllureTestResultContainer>(Uuid);
  if container=nil then begin
    //LOGGER.error("Could not write test container: container with uuid {} not found", uuid);
    exit;
  end;
  Writer.WriteTestContainer(container);
  fStorage.RemoveObject(Uuid);
end;

end.
