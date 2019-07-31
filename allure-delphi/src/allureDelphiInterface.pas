unit allureDelphiInterface;

interface

uses
  Winapi.ActiveX;

type

  IAllureStringSet = interface;
  IAllureConfiguration = interface;
  IAllureTestRunResult = interface;
  IAllureTestResultContainer = interface;
  IAllureFixtureResultList = interface;
  IAllureFixtureResult = interface;
  IAllureExecutableItem = interface;
  IAllureStatusDetails = interface;
  IAllureStepResult = interface;
  IAllureStepResultList = interface;
  IAllureParameter = interface;
  IAllureParameters = interface;
  IAllureAttachment = interface;
  IAllureAttachments = interface;
  IAllureTestResult = interface;
  IAllureLabels = interface;
  IAllureLabel = interface;
  IAllureLink = interface;
  IAllureLinkList = interface;
  IAllureResultsWriter = interface;
  IAllureLifecycle = interface;
  IAllureTestResultContainerAction = interface;
  IAllureFixtureResultAction = interface;
  IAllureTestResultAction = interface;
  IAllureStepResultAction = interface;

  TAllureString = WideString;
  TAllureBoolean = WordBool;

  TAllureStatus = (
    asNone,
    asFailed,
    asBroken,
    asPassed,
    asSkipped
  );

  TAllureStage = (
    asScheduled,
    asRunning,
    asFinished,
    asPending,
    asInterrupted
  );

  TAllureSeverityLevel = (
    aslBlocker,
    aslCritical,
    aslNormal,
    aslMinor,
    aslTrivial
  );

  TAllureTime = record
    Value: Int64;
  end;

  IAllureStringSet = interface
  ['{98C0182F-AFB6-4C73-99AC-F5C80647E516}']
    function GetCount: Integer; safecall;
    function GetValue(Index: Integer): TAllureString; safecall;
    procedure SetValue(Index: Integer; const AValue: TAllureString); safecall;

    procedure Add(const AValue: string); safecall;
    procedure AddValues(const AValues: IAllureStringSet); safecall;
    procedure Clear; safecall;

    property Count: Integer read GetCount;
    property Value[Index: Integer]: TAllureString read GetValue write SetValue;
  end;

  IAllureConfiguration = interface
  ['{14C324DD-7ECA-425D-A4E8-4F1253CF95E0}']
    function GetTitle: TAllureString; safecall;
    procedure SetTitle(const Value: TAllureString); safecall;
    function GetDirectory: TAllureString; safecall;
    procedure SetDirectory(const Value: TAllureString); safecall;
    function GetLinks: IAllureStringSet; safecall;

    procedure ReadFromJson(const json: TAllureString); safecall;

    property Title: TAllureString read GetTitle write SetTitle;
    property Directory: TAllureString read GetDirectory write SetDirectory;
    property Links: IAllureStringSet read GetLinks;
  end;

  IAllureTestRunResult = interface
  ['{0DACAC85-5DB0-45EA-89B6-3F23B0BA83C2}']
    function GetUUID: TAllureString; safecall;
    procedure SetUUID(const AValue: TAllureString); safecall;
    function GetName: TAllureString; safecall;
    procedure SetName(const Value: TAllureString); safecall;

    property UUID: TAllureString read GetUUID write SetUUID;
    property Name: TAllureString read GetName write SetName;
  end;

  IAllureTestResultContainer = interface
  ['{34F8257B-B8B9-4B73-A50F-30980828F1F3}']
    function GetUUID: TAllureString; safecall;
    procedure SetUUID(const AValue: TAllureString); safecall;
    function GetName: TAllureString; safecall;
    procedure SetName(const Value: TAllureString); safecall;
    function GetChildren: IAllureStringSet; safecall;
    function GetDescription: TAllureString; safecall;
    procedure SetDescription(const Value: TAllureString); safecall;
    function GetDescriptionHtml: TAllureString; safecall;
    procedure SetDescriptionHtml(const Value: TAllureString); safecall;
    function GetBefores: IAllureFixtureResultList; safecall;
    function GetAfters: IAllureFixtureResultList; safecall;
    function GetLinks: IAllureLinkList; safecall;
    function GetStart: TAllureTime; safecall;
    procedure SetStart(const Value: TAllureTime); safecall;
    function GetStop: TAllureTime; safecall;
    procedure SetStop(const Value: TAllureTime); safecall;

    property UUID: TAllureString read GetUUID write SetUUID;
    property Name: TAllureString read GetName write SetName;
    property Children: IAllureStringSet read GetChildren;
    property Description: TAllureString read GetDescription write SetDescription;
    property DescriptionHtml: TAllureString read GetDescriptionHtml write SetDescriptionHtml;
    property Befores: IAllureFixtureResultList read GetBefores;
    property Afters: IAllureFixtureResultList read GetAfters;
    property Links: IAllureLinkList read GetLinks;
    property Start: TAllureTime read GetStart write SetStart;
    property Stop: TAllureTime read GetStop write SetStop;
  end;

  IAllureExecutableItem = interface
  ['{8B624FAF-C7EE-47AD-8AA9-99E91ECBB09C}']
    function GetName: TAllureString; safecall;
    procedure SetName(const Value: TAllureString); safecall;
    function GetStatus: TAllureStatus; safecall;
    procedure SetStatus(const Value: TAllureStatus); safecall;
    function GetStatusDetails: IAllureStatusDetails; safecall;
    function GetStage: TAllureStage; safecall;
    procedure SetStage(const Value: TAllureStage); safecall;
    function GetDescription: TAllureString; safecall;
    procedure SetDescription(const Value: TAllureString); safecall;
    function GetDescriptionHtml: TAllureString; safecall;
    procedure SetDescriptionHtml(const Value: TAllureString); safecall;
    function GetSteps: IAllureStepResultList; safecall;
    function GetAttachments: IAllureAttachments; safecall;
    function GetParameters: IAllureParameters; safecall;
    function GetStart: TAllureTime; safecall;
    procedure SetStart(const Value: TAllureTime); safecall;
    function GetStop: TAllureTime; safecall;
    procedure SetStop(const Value: TAllureTime); safecall;

    property Name: TAllureString read GetName write SetName;
    property Status: TAllureStatus read GetStatus write SetStatus;
    property StatusDetails: IAllureStatusDetails read GetStatusDetails;
    property Stage: TAllureStage read GetStage write SetStage;
    property Description: TAllureString read GetDescription write SetDescription;
    property DescriptionHtml: TAllureString read GetDescriptionHtml write SetDescriptionHtml;
    property Steps: IAllureStepResultList read GetSteps;
    property Attachments: IAllureAttachments read GetAttachments;
    property Parameters: IAllureParameters read GetParameters;
    property Start: TAllureTime read GetStart write SetStart;
    property Stop: TAllureTime read GetStop write SetStop;
  end;

  IAllureFixtureResult = interface(IAllureExecutableItem)
  ['{86EF0B2A-C6B7-405A-A8F3-4A6C34049E79}']

  end;

  IAllureFixtureResultList = interface
  ['{BB3ACE3A-8F63-4CBB-84F5-DB7EDCF12873}']
    function GetFixtureResult(Index: Integer): IAllureFixtureResult; safecall;
    function GetFixtureResultCount: Integer; safecall;

    property FixtureResult[Index: Integer]: IAllureFixtureResult read GetFixtureResult;
    property FixtureResultCount: Integer read GetFixtureResultCount;

    procedure Add(const Fixture: IAllureFixtureResult); safecall;
  end;

  IAllureStatusDetails = interface
  ['{0A0AB768-8CAC-4442-BF6E-7A5998380ED0}']
    function GetKnown: TAllureBoolean; safecall;
    procedure SetKnown(Value: TAllureBoolean); safecall;
    function GetMuted: TAllureBoolean; safecall;
    procedure SetMuted(Value: TAllureBoolean); safecall;
    function GetFlaky: TAllureBoolean; safecall;
    procedure SetFlaky(Value: TAllureBoolean); safecall;
    function GetMessage: TAllureString; safecall;
    procedure SetMessage(const Value: TAllureString); safecall;
    function GetTrace: TAllureString; safecall;
    procedure SetTrace(const AValue: TAllureString); safecall;

    property Known: TAllureBoolean read GetKnown write SetKnown;
    property Muted: TAllureBoolean read GetMuted write SetMuted;
    property Flaky: TAllureBoolean read GetFlaky write SetFlaky;
    property Message: TAllureString read GetMessage write SetMessage;
    property Trace: TAllureString read GetTrace write SetTrace;
  end;

  IAllureStepResult = interface(IAllureExecutableItem)
  ['{E0697922-BB7A-4215-8D6E-EAE4F7CD4C61}']
  end;

  IAllureStepResultList = interface
  ['{C91A3099-CA86-4BEB-9413-BF64D5E82B8A}']
    function GetStep(Index: Integer): IAllureStepResult; safecall;
    function GetStepCount: Integer; safecall;

    property Step[Index: Integer]: IAllureStepResult read GetStep;
    property StepCount: Integer read GetStepCount;

    procedure Add(const AStep: IAllureStepResult); safecall;
  end;

  IAllureParameter = interface
  ['{D814C63E-A517-4095-A905-A6237BBA5CF5}']
    function GetName: TAllureString; safecall;
    procedure SetName(const Value: TAllureString); safecall;
    function GetValue: TAllureString; safecall;
    procedure SetValue(const AValue: TAllureString); safecall;
//    function GetKind: TAllureParameterKind; safecall;
//    procedure SetKind(Value: TAllureParameterKind); safecall;

    property Name: TAllureString read GetName write SetName;
    property Value: TAllureString read GetValue write SetValue;
//    property Kind: TAllureParameterKind read GetKind write SetKind;
  end;

  IAllureParameters = interface
  ['{44EB82A1-92D3-47D9-BD12-E9B0688E0925}']
    function GetParameter(Index: Integer): IAllureParameter; safecall;
    function GetParameterCount: Integer; safecall;

    property Parameter[Index: Integer]: IAllureParameter read GetParameter;
    property ParameterCount: Integer read GetParameterCount;
  end;

  IAllureAttachment = interface
  ['{832C1B09-41FD-44E0-A6BE-D3950844FFE0}']
    function GetName: TAllureString; safecall;
    procedure SetName(const Value: TAllureString); safecall;
    function GetSource: TAllureString; safecall;
    procedure SetSource(const AValue: TAllureString); safecall;
    function GetAttachmentType: TAllureString; safecall;
    procedure SetAttachmentType(const AValue: TAllureString); safecall;

    //
    property Name: TAllureString read GetName write SetName;
    // UUID
    property Source: TAllureString read GetSource write SetSource;
    // MIME type
    property AttachmentType: TAllureString read GetAttachmentType write SetAttachmentType;
  end;

  IAllureAttachments = interface
  ['{D1C51763-CE43-49AA-9769-CAA3C477F754}']
    function GetAttachment(Index: Integer): IAllureAttachment; safecall;
    function GetAttachmentCount: Integer; safecall;

    property Attachment[Index: Integer]: IAllureAttachment read GetAttachment;
    property AttachmentCount: Integer read GetAttachmentCount;

    procedure Add(const Attachment: IAllureAttachment); safecall;
  end;

  IAllureTestResult = interface(IAllureExecutableItem)
  ['{F0CB366A-3C95-4774-AC62-46656279F36C}']
    function GetUUID: TAllureString; safecall;
    procedure SetUUID(const AValue: TAllureString); safecall;
    function GetHistoryID: TAllureString; safecall;
    procedure SetHistoryID(const AValue: TAllureString); safecall;
    function GetTestCaseID: TAllureString; safecall;
    procedure SetTestCaseID(const AValue: TAllureString); safecall;
    function GetReturnOf: TAllureString; safecall;
    procedure SetReturnOf(const AValue: TAllureString); safecall;
    function GetFullName: TAllureString; safecall;
    procedure SetFullName(const Value: TAllureString); safecall;
    function GetLabels: IAllureLabels; safecall;
    function GetLinks: IAllureLinkList; safecall;

    property UUID: TAllureString read GetUUID write SetUUID;
    property HistoryID: TAllureString read GetHistoryID write SetHistoryID;
    property TestCaseID: TAllureString read GetTestCaseID write SetTestCaseID;
    property ReturnOf: TAllureString read GetReturnOf write SetReturnOf;
    property FullName: TAllureString read GetFullName write SetFullName;
    property Labels: IAllureLabels read GetLabels;
    property Links: IAllureLinkList read GetLinks;
  end;

  IAllureLabel = interface
  ['{91BAC182-F82C-4F32-A17C-AD44574BBA64}']
    function GetName: TAllureString; safecall;
    procedure SetName(const Value: TAllureString); safecall;
    function GetValue: TAllureString; safecall;
    procedure SetValue(const AValue: TAllureString); safecall;

    property Name: TAllureString read GetName write SetName;
    property Value: TAllureString read GetValue write SetValue;

    procedure SetTestType(const AValue: TAllureString); safecall;
    procedure SetParentSuite(const AValue: TAllureString); safecall;
    procedure SetSuite(const AValue: TAllureString); safecall;
    procedure SetSubSuite(const AValue: TAllureString); safecall;
    procedure SetOwner(const AValue: TAllureString); safecall;
    procedure SetSeverity(AValue: TAllureSeverityLevel); safecall;
    procedure SetTag(const AValue: TAllureString); safecall;
    procedure SetEpic(const AValue: TAllureString); safecall;
    procedure SetFeature(const AValue: TAllureString); safecall;
    procedure SetStory(const AValue: TAllureString); safecall;
    procedure SetPackage(const AValue: TAllureString); safecall;
    procedure SetTestClass(const AValue: TAllureString); safecall;
    procedure SetTestMethod(const AValue: TAllureString); safecall;
    procedure SetCurrentThread; safecall;
    procedure SetThread(const AValue: TAllureString); safecall;
    procedure SetCurrentHost(); safecall;
    procedure SetHost(const AValue: TAllureString); safecall;
  end;

  IAllureLabels = interface
  ['{F867A003-3171-4D9D-BB1F-F760DC150DDD}']
    function GetLabels(Index: Integer): IAllureLabel; safecall;
    function GetLabelCount: Integer; safecall;

    property Labels[Index: Integer]: IAllureLabel read GetLabels;
    property LabelCount: Integer read GetLabelCount;

    function AddNew: IAllureLabel; safecall;
  end;

  IAllureLink = interface
  ['{68F37F80-2B81-4FDD-8764-66105BDDC6B8}']
    function GetName: TAllureString; safecall;
    procedure SetName(const Value: TAllureString); safecall;
    function GetUrl: TAllureString; safecall;
    procedure SetUrl(const AValue: TAllureString); safecall;
    function GetLinkType: TAllureString; safecall;
    procedure SetLinkType(const AValue: TAllureString); safecall;

    property Name: TAllureString read GetName write SetName;
    property Url: TAllureString read GetUrl write SetUrl;
    property LinkType: TAllureString read GetLinkType write SetLinkType;

    procedure SetIssueUrl(const AName, AUrl: TAllureString); safecall;
    procedure SetIssue(const AName: TAllureString); safecall;
    procedure SetTmsUrl(const AName, AUrl: TAllureString); safecall;
    procedure SetTms(const AName: TAllureString); safecall;
  end;

  IAllureLinkList = interface
  ['{2096391A-44D1-4476-9516-53595F04CAB2}']
    function GetLink(Index: Integer): IAllureLink; safecall;
    function GetLinkCount: Integer; safecall;

    property Link[Index: Integer]: IAllureLink read GetLink;
    property LinkCount: Integer read GetLinkCount;

    function AddNew: IAllureLink; safecall;
  end;

  IAllureResultsWriter = interface
  ['{1258934C-614B-4F06-A8CE-7950A8AF20E8}']
    procedure WriteTestResult(const TestResult: IAllureTestResult);
    procedure WriteTestResultContainer(const TestResultContainer: IAllureTestResultContainer);
    procedure WriteAttachment(const Source: TAllureString; Attachment: Pointer; Size: UInt64);
    procedure CleanUp();
  end;

  // The class contains Allure context and methods to change it.
  IAllureLifecycle = interface
  ['{B6645606-6569-4F31-BF53-7038AB59F121}']
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

    (*
     * Adds attachment to current running test or step.
     *
     * @param name          the name of attachment
     * @param type          the content type of attachment
     * @param fileExtension the attachment file extension
     * @param stream        attachment content
     *)
    function AddAttachment(const Name, AType, FileExtension: TAllureString; const Stream: IStream): IAllureLifecycle; overload; safecall;
    function AddAttachment(const Name, AType, Path: TAllureString): IAllureLifecycle; overload; safecall;
    function AddAttachment(const Name, AType: TAllureString; Content: Pointer; Size: UInt64; const FileExtension: TAllureString = ''): IAllureLifecycle; overload; safecall;
    function AddAttachment(const Path: TAllureString; const Name: TAllureString = ''): IAllureLifecycle; overload; safecall;

    // Extensions
    procedure CleanupResultDirectory(); safecall;
//    function AddScreenDiff(const TestCaseUuid, ExpectedPng, ActualPng, DiffPng: TAllureString): IAllureLifecycle; safecall;

  end;

  IAllureTestResultContainerAction = interface
  ['{ACB9CA89-20C6-4FB2-B7AD-865A577E5DD4}']
    procedure Invoke(const Container: IAllureTestResultContainer); safecall;
  end;

  IAllureFixtureResultAction = interface
  ['{EA4C9EBA-AB1C-4A1C-B3DE-7BEC6FAB6B1A}']
    procedure Invoke(const FixtureResult: IAllureFixtureResult); safecall;
  end;

  IAllureTestResultAction = interface
  ['{01D30F8B-71B3-46FD-A719-7CF6E4C0EF79}']
    procedure Invoke(const TestResult: IAllureTestResult); safecall;
  end;

  IAllureStepResultAction = interface
  ['{09A15B55-F558-41B7-AE07-BF973765CD4F}']
    procedure Invoke(const StepResult: IAllureStepResult); safecall;
  end;

implementation

end.
