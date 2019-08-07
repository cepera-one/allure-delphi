unit allureModel;

interface

uses
  System.SysUtils, Winapi.Windows, allureDelphiInterface, allureCommon,
  allureThreadSafeList, System.Generics.Defaults, System.Classes,
  allureDelphiHelper, System.StrUtils;

type
  TAllureStepResultList = class;
  TAllureTestResultContainer = class;
  TAllureTestResult = class;

  IAllureResultsWriter = interface
  ['{2E0F34FB-E5CD-450C-9DA5-DD1C192DFEC0}']
    (*
     * Writes Allure test result bean.
     *
     * @param testResult the given bean to write.
     * @throws AllureResultsWriteException if some error occurs
     *                                     during operation.
     *)
    procedure WriteTest(TestResult: TAllureTestResult);

    (*
     * Writes Allure test result container bean.
     *
     * @param testResultContainer the given bean to write.
     * @throws AllureResultsWriteException if some error occurs
     *                                     during operation.
     *)
    procedure WriteTestContainer(TestResultContainer: TAllureTestResultContainer);

    (*
     * Writes given attachment. Will close the given stream.
     *
     * @param source     the file name of the attachment. Make sure that file name
     *                   matches the following glob: <pre>*-attachment*</pre>. The right way
     *                   to generate attachment is generate UUID, determinate attachment
     *                   extension and then use it as <pre>{UUID}-attachment.{ext}</pre>
     * @param attachment the steam that contains attachment body.
     *)
    procedure WriteAttachment(const Source: String; Attachment: TStream);
  end;


  TAllureStringSet = class(TAllureInterfacedObject, IAllureStringSet)
  private
    fList: TAllureThreadSafeList<String>;
  public
    constructor Create;
    destructor Destroy; override;

    function GetCount: Integer; safecall;
    function GetValue(Index: Integer): TAllureString; safecall;
    procedure SetValue(Index: Integer; const AValue: TAllureString); safecall;

    procedure Add(const AValue: string); safecall;
    procedure AddValues(const AValues: IAllureStringSet); safecall;
    procedure Clear; safecall;

    property Count: Integer read GetCount;
    property Value[Index: Integer]: TAllureString read GetValue write SetValue; default;
  end;

  TAllureStatusDetails = class(TAllureInterfacedObject, IAllureStatusDetails)
  private
    fKnown: TAllureBoolean;
    fMuted: TAllureBoolean;
    fFlaky: TAllureBoolean;
    fMessage: TAllureString;
    fTrace: TAllureString;
  public
    constructor Create;
    destructor Destroy; override;
  public
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

  TAllureParameter = class(TAllureInterfacedObject, IAllureParameter)
  private
    fName: TAllureString;
    fValue: TAllureString;
  public
    constructor Create;
    destructor Destroy; override;
  public
    function GetName: TAllureString; safecall;
    procedure SetName(const Value: TAllureString); safecall;
    function GetValue: TAllureString; safecall;
    procedure SetValue(const AValue: TAllureString); safecall;

    property Name: TAllureString read GetName write SetName;
    property Value: TAllureString read GetValue write SetValue;
  end;

  TAllureParameters = class(TAllureInterfacedObject, IAllureParameters)
  private
    fList: TAllureThreadSafeObjectList<TAllureParameter>;
  public
    constructor Create;
    destructor Destroy; override;
  public
    function GetParameter(Index: Integer): IAllureParameter; safecall;
    function GetParameterCount: Integer; safecall;

    property Parameter[Index: Integer]: IAllureParameter read GetParameter; default;
    property ParameterCount: Integer read GetParameterCount;

    function AddNew: IAllureParameter; safecall;
  end;

  TAllureAttachment = class(TAllureInterfacedObject, IAllureAttachment)
  private
    fName: TAllureString;
    fSource: TAllureString;
    fAttachmentType: TAllureString;
  public
    constructor Create;
    destructor Destroy; override;
  public
    function GetName: TAllureString; safecall;
    procedure SetName(const Value: TAllureString); safecall;
    function GetSource: TAllureString; safecall;
    procedure SetSource(const AValue: TAllureString); safecall;
    function GetAttachmentType: TAllureString; safecall;
    procedure SetAttachmentType(const AValue: TAllureString); safecall;

    property Name: TAllureString read GetName write SetName;
    property Source: TAllureString read GetSource write SetSource;
    property AttachmentType: TAllureString read GetAttachmentType write SetAttachmentType;
  end;

  TAllureAttachments = class(TAllureInterfacedObject, IAllureAttachments)
  private
    fList: TAllureThreadSafeObjectList<TAllureAttachment>;
  public
    constructor Create;
    destructor Destroy; override;
  public
    function GetAttachment(Index: Integer): IAllureAttachment; safecall;
    function GetAttachmentCount: Integer; safecall;

    property Attachment[Index: Integer]: IAllureAttachment read GetAttachment; default;
    property AttachmentCount: Integer read GetAttachmentCount;

    procedure Add(const Attachment: IAllureAttachment); safecall;
  end;

  TAllureExecutableItem = class(TAllureInterfacedObject, IAllureExecutableItem)
  private
    fName: TAllureString;
    fStart: TAllureTime;
    fStop: TAllureTime;
    fStage: TAllureStage;
    fDescription: TAllureString;
    fDescriptionHtml: TAllureString;
    fTag: TAllureTag;
    fStatus: TAllureStatus;
    fStatusDetails: TAllureStatusDetails;
    fSteps: TAllureStepResultList;
    fAttachments: TAllureAttachments;
    fParameters: TAllureParameters;
    function GetStatusDetailsAssigned: TAllureBoolean;
    function GetStepsAssigned: TAllureBoolean;
  public
    constructor Create;
    destructor Destroy; override;
    property StatusDetailsAssigned: TAllureBoolean read GetStatusDetailsAssigned;
    property StepsAssigned: TAllureBoolean read GetStepsAssigned;
  public
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
    function GetTag: TAllureTag; safecall;
    procedure SetTag(const Value: TAllureTag); safecall;

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
    property Tag: TAllureTag read GetTag write SetTag;
  end;

  TAllureStepResult = class(TAllureExecutableItem, IAllureStepResult)

  end;

  TAllureStepResultList = class(TAllureInterfacedObject, IAllureStepResultList)
  private
    fList: TAllureThreadSafeObjectList<TAllureStepResult>;
  public
    constructor Create;
    destructor Destroy; override;
  public
    function GetStep(Index: Integer): IAllureStepResult; safecall;
    function GetStepCount: Integer; safecall;

    property Step[Index: Integer]: IAllureStepResult read GetStep; default;
    property StepCount: Integer read GetStepCount;

    procedure Add(const AStep: IAllureStepResult); safecall;
  end;

  TAllureLabel = class(TAllureInterfacedObject, IAllureLabel)
  private
    fName: TAllureString;
    fValue: TAllureString;
  public
    constructor Create;
    destructor Destroy; override;
  public
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

  TAllureLabels = class(TAllureInterfacedObject, IAllureLabels)
  private
    fList: TAllureThreadSafeObjectList<TAllureLabel>;
  public
    constructor Create;
    destructor Destroy; override;
  public
    function GetLabels(Index: Integer): IAllureLabel; safecall;
    function GetLabelCount: Integer; safecall;

    property Labels[Index: Integer]: IAllureLabel read GetLabels; default;
    property LabelCount: Integer read GetLabelCount;

    function AddNew: IAllureLabel; safecall;
  end;

  TAllureLink = class(TAllureInterfacedObject, IAllureLink)
  private
    fName: TAllureString;
    fUrl: TAllureString;
    fLinkType: TAllureString;
  public
    constructor Create;
    destructor Destroy; override;
  public
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

  TAllureLinkList = class(TAllureInterfacedObject, IAllureLinkList)
  private
    fList: TAllureThreadSafeObjectList<TAllureLink>;
  public
    constructor Create;
    destructor Destroy; override;
  public
    function GetLink(Index: Integer): IAllureLink; safecall;
    function GetLinkCount: Integer; safecall;

    property Link[Index: Integer]: IAllureLink read GetLink; default;
    property LinkCount: Integer read GetLinkCount;

    function AddNew: IAllureLink; safecall;
  end;

  TAllureTestResult = class(TAllureExecutableItem, IAllureTestResult)
  private
    fUUID: TAllureString;
    fHistoryID: TAllureString;
    fTestCaseID: TAllureString;
    fReturnOf: TAllureString;
    fFullName: TAllureString;
    fLabels: TAllureLabels;
    fLinks: TAllureLinkList;
    function GetLinksAssigned: TAllureBoolean;
    function GetLabelsAssigned: TAllureBoolean;
  public
    constructor Create;
    destructor Destroy; override;

    property LinksAssigned: TAllureBoolean read GetLinksAssigned;
    property LabelsAssigned: TAllureBoolean read GetLabelsAssigned;
  public
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

  TAllureTestRunResult = class(TAllureExecutableItem, IAllureTestRunResult)
  private
    fUUID: TAllureString;
    fName: TAllureString;
  public
    constructor Create;
    destructor Destroy; override;
  public
    function GetUUID: TAllureString; safecall;
    procedure SetUUID(const AValue: TAllureString); safecall;
    function GetName: TAllureString; safecall;
    procedure SetName(const Value: TAllureString); safecall;

    property UUID: TAllureString read GetUUID write SetUUID;
    property Name: TAllureString read GetName write SetName;
  end;

  TAllureFixtureResult = class(TAllureExecutableItem, IAllureFixtureResult)

  end;

  TAllureFixtureResultList = class(TAllureInterfacedObject, IAllureFixtureResultList)
  private
    fList: TAllureThreadSafeObjectList<TAllureFixtureResult>;
  public
    constructor Create;
    destructor Destroy; override;
  public
    function GetFixtureResult(Index: Integer): IAllureFixtureResult; safecall;
    function GetFixtureResultCount: Integer; safecall;

    property FixtureResult[Index: Integer]: IAllureFixtureResult read GetFixtureResult; default;
    property FixtureResultCount: Integer read GetFixtureResultCount;

    procedure Add(const Fixture: IAllureFixtureResult); safecall;
  end;

  TAllureTestResultContainer = class(TAllureExecutableItem, IAllureTestResultContainer)
  private
    fUUID: TAllureString;
    fName: TAllureString;
    fStart: TAllureTime;
    fStop: TAllureTime;
    fDescription: TAllureString;
    fDescriptionHtml: TAllureString;
    fTag: TAllureTag;
    fChildren: TAllureStringSet;
    fBefores: TAllureFixtureResultList;
    fAfters: TAllureFixtureResultList;
    fLinks: TAllureLinkList;
    function GetLinksAssigned: TAllureBoolean;
    function GetAftersAssigned: TAllureBoolean;
    function GetBeforesAssigned: TAllureBoolean;
  public
    constructor Create;
    destructor Destroy; override;

    property LinksAssigned: TAllureBoolean read GetLinksAssigned;
    property BeforesAssigned: TAllureBoolean read GetBeforesAssigned;
    property AftersAssigned: TAllureBoolean read GetAftersAssigned;
  public
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
    function GetTag: TAllureTag; safecall;
    procedure SetTag(const Value: TAllureTag); safecall;

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
    property Tag: TAllureTag read GetTag write SetTag;
  end;

  TAllureEnvironment = class(TAllureInterfacedObject, IAllureEnvironment)
  private
    fList: TStringList;
    fFileName: string;
    procedure LoadValues;
  public
    constructor Create(const FileName: string);
    destructor Destroy; override;

    function GetProperty(const AKey: TAllureString): TAllureString; safecall;
    procedure SetProperty(const AKey, AValue: TAllureString); safecall;
    property Properties[const AKey: TAllureString]: TAllureString read GetProperty write SetProperty; default;
    procedure Flush; safecall;
  end;

  TAllureLinkHelper = record
    class procedure UpdateLinks(const Links: IAllureLinkList; const Patterns: IAllureStringSet); static;
  end;

implementation

{ TAllureExecutableItem }

constructor TAllureExecutableItem.Create;
begin
  inherited Create;
end;

destructor TAllureExecutableItem.Destroy;
begin
  fStatusDetails.Free;
  fSteps.Free;
  fAttachments.Free;
  fParameters.Free;
  inherited;
end;

function TAllureExecutableItem.GetAttachments: IAllureAttachments;
begin
  if fAttachments=nil then
    fAttachments := TAllureAttachments.Create;
  result := fAttachments;
end;

function TAllureExecutableItem.GetDescription: TAllureString;
begin
  result := fDescription;
end;

function TAllureExecutableItem.GetDescriptionHtml: TAllureString;
begin
  result := fDescriptionHtml;
end;

function TAllureExecutableItem.GetName: TAllureString;
begin
  result := fName;
end;

function TAllureExecutableItem.GetParameters: IAllureParameters;
begin
  if fParameters=nil then
    fParameters := TAllureParameters.Create;
  result := fParameters;
end;

function TAllureExecutableItem.GetStage: TAllureStage;
begin
  result := fStage;
end;

function TAllureExecutableItem.GetStart: TAllureTime;
begin
  result := fStart;
end;

function TAllureExecutableItem.GetStatus: TAllureStatus;
begin
  result := fStatus;
end;

function TAllureExecutableItem.GetStatusDetails: IAllureStatusDetails;
begin
  if fStatusDetails=nil then
    fStatusDetails := TAllureStatusDetails.Create;
  result := fStatusDetails;
end;

function TAllureExecutableItem.GetStatusDetailsAssigned: TAllureBoolean;
begin
  result := fStatusDetails<>nil;
end;

function TAllureExecutableItem.GetSteps: IAllureStepResultList;
begin
  if fSteps=nil then
    fSteps := TAllureStepResultList.Create;
  result := fSteps;
end;

function TAllureExecutableItem.GetStepsAssigned: TAllureBoolean;
begin
  result := fSteps<>nil;
end;

function TAllureExecutableItem.GetStop: TAllureTime;
begin
  result := fStop;
end;

function TAllureExecutableItem.GetTag: TAllureTag;
begin
  result := fTag;
end;

procedure TAllureExecutableItem.SetDescription(const Value: TAllureString);
begin
  fDescription := Value;
end;

procedure TAllureExecutableItem.SetDescriptionHtml(const Value: TAllureString);
begin
  fDescriptionHtml := Value;
end;

procedure TAllureExecutableItem.SetName(const Value: TAllureString);
begin
  fName := Value;
end;

procedure TAllureExecutableItem.SetStage(const Value: TAllureStage);
begin
  fStage := Value;
end;

procedure TAllureExecutableItem.SetStart(const Value: TAllureTime);
begin
  fStart := Value;
end;

procedure TAllureExecutableItem.SetStatus(const Value: TAllureStatus);
begin
  fStatus := Value;
end;

procedure TAllureExecutableItem.SetStop(const Value: TAllureTime);
begin
  fStop := Value;
end;

procedure TAllureExecutableItem.SetTag(const Value: TAllureTag);
begin
  fTag := Value;
end;

{ TAllureTestResult }

constructor TAllureTestResult.Create;
begin
  inherited Create;
end;

destructor TAllureTestResult.Destroy;
begin
  fLabels.Free;
  fLinks.Free;
  inherited;
end;

function TAllureTestResult.GetFullName: TAllureString;
begin
  result := fFullName;
end;

function TAllureTestResult.GetHistoryID: TAllureString;
begin
  result := fHistoryID;
end;

function TAllureTestResult.GetLabels: IAllureLabels;
begin
  if fLabels=nil then
    fLabels := TAllureLabels.Create;
  result := fLabels;
end;

function TAllureTestResult.GetLabelsAssigned: TAllureBoolean;
begin
  result := fLabels<>nil;
end;

function TAllureTestResult.GetLinks: IAllureLinkList;
begin
  if fLinks=nil then
    fLinks := TAllureLinkList.Create;
  result := fLinks;
end;

function TAllureTestResult.GetLinksAssigned: TAllureBoolean;
begin
  result := fLinks<>nil;
end;

function TAllureTestResult.GetReturnOf: TAllureString;
begin
  result := fReturnOf;
end;

function TAllureTestResult.GetTestCaseID: TAllureString;
begin
  result := fTestCaseID;
end;

function TAllureTestResult.GetUUID: TAllureString;
begin
  result := fUUID;
end;

procedure TAllureTestResult.SetFullName(const Value: TAllureString);
begin
  fFullName := Value;
end;

procedure TAllureTestResult.SetHistoryID(const AValue: TAllureString);
begin
  fHistoryID := AValue;
end;

procedure TAllureTestResult.SetReturnOf(const AValue: TAllureString);
begin
  fReturnOf := AValue;
end;

procedure TAllureTestResult.SetTestCaseID(const AValue: TAllureString);
begin
  fTestCaseID := AValue;
end;

procedure TAllureTestResult.SetUUID(const AValue: TAllureString);
begin
  fUUID := AValue;
end;

{ TAllureStatusDetails }

constructor TAllureStatusDetails.Create;
begin
  inherited Create;
end;

destructor TAllureStatusDetails.Destroy;
begin

  inherited;
end;

function TAllureStatusDetails.GetFlaky: TAllureBoolean;
begin
  result := fFlaky;
end;

function TAllureStatusDetails.GetKnown: TAllureBoolean;
begin
  result := fKnown;
end;

function TAllureStatusDetails.GetMessage: TAllureString;
begin
  result := fMessage;
end;

function TAllureStatusDetails.GetMuted: TAllureBoolean;
begin
  result := fMuted;
end;

function TAllureStatusDetails.GetTrace: TAllureString;
begin
  result := fTrace;
end;

procedure TAllureStatusDetails.SetFlaky(Value: TAllureBoolean);
begin
  fFlaky := Value;
end;

procedure TAllureStatusDetails.SetKnown(Value: TAllureBoolean);
begin
  fKnown := Value;
end;

procedure TAllureStatusDetails.SetMessage(const Value: TAllureString);
begin
  fMessage := Value;
end;

procedure TAllureStatusDetails.SetMuted(Value: TAllureBoolean);
begin
  fMuted := Value;
end;

procedure TAllureStatusDetails.SetTrace(const AValue: TAllureString);
begin
  fTrace := AValue;
end;

{ TAllureParameter }

constructor TAllureParameter.Create;
begin
  inherited Create;
end;

destructor TAllureParameter.Destroy;
begin

  inherited;
end;

function TAllureParameter.GetName: TAllureString;
begin
  result := fName;
end;

function TAllureParameter.GetValue: TAllureString;
begin
  result := fValue;
end;

procedure TAllureParameter.SetName(const Value: TAllureString);
begin
  fName := Value;
end;

procedure TAllureParameter.SetValue(const AValue: TAllureString);
begin
  fValue := AValue;
end;

{ TAllureParameters }

function TAllureParameters.AddNew: IAllureParameter;
var
  res: TAllureParameter;
begin
  res := TAllureParameter.Create;
  fList.Add(res);
  result := res;
end;

constructor TAllureParameters.Create;
begin
  inherited Create;
  fList := TAllureThreadSafeObjectList<TAllureParameter>.Create;
end;

destructor TAllureParameters.Destroy;
begin
  fList.Free;
  inherited;
end;

function TAllureParameters.GetParameter(Index: Integer): IAllureParameter;
begin
  result := fList.Items[Index];
end;

function TAllureParameters.GetParameterCount: Integer;
begin
  result := fList.Count;
end;

{ TAllureAttachment }

constructor TAllureAttachment.Create;
begin
  inherited Create;
end;

destructor TAllureAttachment.Destroy;
begin

  inherited;
end;

function TAllureAttachment.GetAttachmentType: TAllureString;
begin
  result := fAttachmentType;
end;

function TAllureAttachment.GetName: TAllureString;
begin
  result := fName;
end;

function TAllureAttachment.GetSource: TAllureString;
begin
  result := fSource;
end;

procedure TAllureAttachment.SetAttachmentType(const AValue: TAllureString);
begin
  fAttachmentType := AValue;
end;

procedure TAllureAttachment.SetName(const Value: TAllureString);
begin
  fName := Value;
end;

procedure TAllureAttachment.SetSource(const AValue: TAllureString);
begin
  fSource := AValue;
end;

{ TAllureAttachments }

procedure TAllureAttachments.Add(const Attachment: IAllureAttachment);
begin
  if Attachment=nil then exit;
  fList.Add(TAllureInterfacedObject.ToClass<TAllureAttachment>(Attachment));
end;

constructor TAllureAttachments.Create;
begin
  inherited Create;
  fList := TAllureThreadSafeObjectList<TAllureAttachment>.Create;
end;

destructor TAllureAttachments.Destroy;
begin
  fList.Free;
  inherited;
end;

function TAllureAttachments.GetAttachment(Index: Integer): IAllureAttachment;
begin
  result := fList.Items[Index];
end;

function TAllureAttachments.GetAttachmentCount: Integer;
begin
  result := fList.Count;
end;

{ TAllureStepResultList }

procedure TAllureStepResultList.Add(const AStep: IAllureStepResult);
begin
  if AStep=nil then exit;
  fList.Add(TAllureInterfacedObject.ToClass<TAllureStepResult>(AStep));
end;

constructor TAllureStepResultList.Create;
begin
  inherited Create;
  fList := TAllureThreadSafeObjectList<TAllureStepResult>.Create;
end;

destructor TAllureStepResultList.Destroy;
begin
  fList.Free;
  inherited;
end;

function TAllureStepResultList.GetStep(Index: Integer): IAllureStepResult;
begin
  result := fList.Items[Index];
end;

function TAllureStepResultList.GetStepCount: Integer;
begin
  result := fList.Count;
end;

{ TAllureTestRunResult }

constructor TAllureTestRunResult.Create;
begin
  inherited Create;
end;

destructor TAllureTestRunResult.Destroy;
begin

  inherited;
end;

function TAllureTestRunResult.GetName: TAllureString;
begin
  result := fName;
end;

function TAllureTestRunResult.GetUUID: TAllureString;
begin
  result := fUUID;
end;

procedure TAllureTestRunResult.SetName(const Value: TAllureString);
begin
  fName := Value;
end;

procedure TAllureTestRunResult.SetUUID(const AValue: TAllureString);
begin
  fUUID := AValue;
end;

{ TAllureTestResultContainer }

constructor TAllureTestResultContainer.Create;
begin
  inherited Create;
end;

destructor TAllureTestResultContainer.Destroy;
begin
  fChildren.Free;
  fBefores.Free;
  fAfters.Free;
  fLinks.Free;
  inherited;
end;

function TAllureTestResultContainer.GetAfters: IAllureFixtureResultList;
begin
  if fAfters=nil then
    fAfters := TAllureFixtureResultList.Create;
  result := fAfters;
end;

function TAllureTestResultContainer.GetAftersAssigned: TAllureBoolean;
begin
  result := fAfters<>nil;
end;

function TAllureTestResultContainer.GetBefores: IAllureFixtureResultList;
begin
  if fBefores=nil then
    fBefores := TAllureFixtureResultList.Create;
  result := fBefores;
end;

function TAllureTestResultContainer.GetBeforesAssigned: TAllureBoolean;
begin
  result := fBefores<>nil;
end;

function TAllureTestResultContainer.GetChildren: IAllureStringSet;
begin
  if fChildren=nil then
    fChildren := TAllureStringSet.Create;
  result := fChildren;
end;

function TAllureTestResultContainer.GetDescription: TAllureString;
begin
  result := fDescription;
end;

function TAllureTestResultContainer.GetDescriptionHtml: TAllureString;
begin
  result := fDescriptionHtml;
end;

function TAllureTestResultContainer.GetLinks: IAllureLinkList;
begin
  if fLinks=nil then
    fLinks := TAllureLinkList.Create;
  result := fLinks;
end;

function TAllureTestResultContainer.GetLinksAssigned: TAllureBoolean;
begin
  result := fLinks<>nil;
end;

function TAllureTestResultContainer.GetName: TAllureString;
begin
  result := fName;
end;

function TAllureTestResultContainer.GetStart: TAllureTime;
begin
  result := fStart;
end;

function TAllureTestResultContainer.GetStop: TAllureTime;
begin
  result := fStop;
end;

function TAllureTestResultContainer.GetTag: TAllureTag;
begin
  result := fTag;
end;

function TAllureTestResultContainer.GetUUID: TAllureString;
begin
  result := fUUID;
end;

procedure TAllureTestResultContainer.SetDescription(const Value: TAllureString);
begin
  fDescription := Value;
end;

procedure TAllureTestResultContainer.SetDescriptionHtml(
  const Value: TAllureString);
begin
  fDescriptionHtml := Value;
end;

procedure TAllureTestResultContainer.SetName(const Value: TAllureString);
begin
  fName := Value;
end;

procedure TAllureTestResultContainer.SetStart(const Value: TAllureTime);
begin
  fStart := Value;
end;

procedure TAllureTestResultContainer.SetStop(const Value: TAllureTime);
begin
  fStop := Value;
end;

procedure TAllureTestResultContainer.SetTag(const Value: TAllureTag);
begin
  fTag := Value;
end;

procedure TAllureTestResultContainer.SetUUID(const AValue: TAllureString);
begin
  fUUID := AValue;
end;

{ TAllureFixtureResultList }

procedure TAllureFixtureResultList.Add(const Fixture: IAllureFixtureResult);
begin
  if Fixture=nil then exit;
  fList.Add(TAllureInterfacedObject.ToClass<TAllureFixtureResult>(Fixture));
end;

constructor TAllureFixtureResultList.Create;
begin
  inherited Create;
  fList := TAllureThreadSafeObjectList<TAllureFixtureResult>.Create;
end;

destructor TAllureFixtureResultList.Destroy;
begin
  fList.Free;
  inherited;
end;

function TAllureFixtureResultList.GetFixtureResult(
  Index: Integer): IAllureFixtureResult;
begin
  result := fList.Items[Index];
end;

function TAllureFixtureResultList.GetFixtureResultCount: Integer;
begin
  result := fList.Count;
end;

{ TAllureLabel }

constructor TAllureLabel.Create;
begin
  inherited Create;
end;

destructor TAllureLabel.Destroy;
begin

  inherited;
end;

function TAllureLabel.GetName: TAllureString;
begin
  result := fName;
end;

function TAllureLabel.GetValue: TAllureString;
begin
  result := fValue;
end;

procedure TAllureLabel.SetCurrentHost;

  function GetComputerName: string;
  var
    dwLength: UInt32;
  begin
    dwLength := 253;
    SetLength(Result, dwLength+1);
    if not WinApi.Windows.GetComputerName(pchar(result), dwLength) then
      Result := 'Not detected!';
    Result := pchar(result);
  end;

begin
  SetHost(GetComputerName);
end;

procedure TAllureLabel.SetCurrentThread;
begin
  SetThread(IntToStr(GetCurrentThreadId));
end;

procedure TAllureLabel.SetEpic(const AValue: TAllureString);
begin
  Name := 'epic';
  Value := AValue;
end;

procedure TAllureLabel.SetFeature(const AValue: TAllureString);
begin
  Name := 'feature';
  Value := AValue;
end;

procedure TAllureLabel.SetHost(const AValue: TAllureString);
begin
  Name := 'host';
  Value := AValue;
end;

procedure TAllureLabel.SetName(const Value: TAllureString);
begin
  fName := Value;
end;

procedure TAllureLabel.SetOwner(const AValue: TAllureString);
begin
  Name := 'owner';
  Value := AValue;
end;

procedure TAllureLabel.SetPackage(const AValue: TAllureString);
begin
  Name := 'package';
  Value := AValue;
end;

procedure TAllureLabel.SetParentSuite(const AValue: TAllureString);
begin
  Name := 'parentSuite';
  Value := AValue;
end;

procedure TAllureLabel.SetSeverity(AValue: TAllureSeverityLevel);
begin
  Name := 'severity';
  Value := AValue.ToString;
end;

procedure TAllureLabel.SetStory(const AValue: TAllureString);
begin
  Name := 'story';
  Value := AValue;
end;

procedure TAllureLabel.SetSubSuite(const AValue: TAllureString);
begin
  Name := 'subSuite';
  Value := AValue;
end;

procedure TAllureLabel.SetSuite(const AValue: TAllureString);
begin
  Name := 'suite';
  Value := AValue;
end;

procedure TAllureLabel.SetTag(const AValue: TAllureString);
begin
  Name := 'tag';
  Value := AValue;
end;

procedure TAllureLabel.SetTestClass(const AValue: TAllureString);
begin
  Name := 'testClass';
  Value := AValue;
end;

procedure TAllureLabel.SetTestMethod(const AValue: TAllureString);
begin
  Name := 'testMethod';
  Value := AValue;
end;

procedure TAllureLabel.SetTestType(const AValue: TAllureString);
begin
  Name := 'testType';
  Value := AValue;
end;

procedure TAllureLabel.SetThread(const AValue: TAllureString);
begin
  Name := 'thread';
  Value := AValue;
end;

procedure TAllureLabel.SetValue(const AValue: TAllureString);
begin
  fValue := AValue;
end;

{ TAllureLabels }

function TAllureLabels.AddNew: IAllureLabel;
var
  res: TAllureLabel;
begin
  res := TAllureLabel.Create;
  fList.Add(res);
  result := res;
end;

constructor TAllureLabels.Create;
begin
  inherited Create;
  fList := TAllureThreadSafeObjectList<TAllureLabel>.Create;
end;

destructor TAllureLabels.Destroy;
begin
  fList.Free;
  inherited;
end;

function TAllureLabels.GetLabelCount: Integer;
begin
  result := fList.Count;
end;

function TAllureLabels.GetLabels(Index: Integer): IAllureLabel;
begin
  result := fList.Items[Index];
end;

{ TAllureLink }

constructor TAllureLink.Create;
begin
  inherited Create;
end;

destructor TAllureLink.Destroy;
begin

  inherited;
end;

function TAllureLink.GetLinkType: TAllureString;
begin
  result := fLinkType;
end;

function TAllureLink.GetName: TAllureString;
begin
  result := fName;
end;

function TAllureLink.GetUrl: TAllureString;
begin
  result := fUrl;
end;

procedure TAllureLink.SetIssue(const AName: TAllureString);
begin
  SetIssueUrl(AName, '');
end;

procedure TAllureLink.SetIssueUrl(const AName, AUrl: TAllureString);
begin
  Name := AName;
  Url := AUrl;
  LinkType := 'issue';
end;

procedure TAllureLink.SetLinkType(const AValue: TAllureString);
begin
  fLinkType := AValue;
end;

procedure TAllureLink.SetName(const Value: TAllureString);
begin
  fName := Value;
end;

procedure TAllureLink.SetTms(const AName: TAllureString);
begin
  SetTmsUrl(AName, '');
end;

procedure TAllureLink.SetTmsUrl(const AName, AUrl: TAllureString);
begin
  Name := AName;
  Url := AUrl;
  LinkType := 'tms';
end;

procedure TAllureLink.SetUrl(const AValue: TAllureString);
begin
  fUrl := AValue;
end;

{ TAllureLinkList }

function TAllureLinkList.AddNew: IAllureLink;
var
  res: TAllureLink;
begin
  res := TAllureLink.Create;
  fList.Add(res);
  result := res;
end;

constructor TAllureLinkList.Create;
begin
  inherited Create;
  fList := TAllureThreadSafeObjectList<TAllureLink>.Create;
end;

destructor TAllureLinkList.Destroy;
begin
  fList.Free;
  inherited;
end;

function TAllureLinkList.GetLink(Index: Integer): IAllureLink;
begin
  result := fList.Items[Index];
end;

function TAllureLinkList.GetLinkCount: Integer;
begin
  result := fList.Count;
end;

{ TAllureStringSet }

procedure TAllureStringSet.Add(const AValue: string);
begin
  fList.Add(AValue);
end;

procedure TAllureStringSet.AddValues(const AValues: IAllureStringSet);
var
  i, j: Integer;
  v: string;
begin
  if AValues=nil then exit;
  fList.Lock;
  try
    for i := 0 to AValues.Count-1 do begin
      v := AValues.Value[i];
      j := fList.IndexOf(v);
      if j<0 then
        fList.Add(v);
    end;
  finally
    fList.Unlock;
  end;
end;

procedure TAllureStringSet.Clear;
begin
  fList.Clear;
end;

constructor TAllureStringSet.Create;
begin
  inherited Create;
  fList := TAllureThreadSafeList<String>.Create(TIStringComparer.Ordinal);
end;

destructor TAllureStringSet.Destroy;
begin
  fList.Free;
  inherited;
end;

function TAllureStringSet.GetCount: Integer;
begin
  result := fList.Count;
end;

function TAllureStringSet.GetValue(Index: Integer): TAllureString;
begin
  result := fList[Index];
end;

procedure TAllureStringSet.SetValue(Index: Integer;
  const AValue: TAllureString);
begin
  fList[Index] := AValue;
end;

{ TAllureLinkHelper }

class procedure TAllureLinkHelper.UpdateLinks(const Links: IAllureLinkList;
  const Patterns: IAllureStringSet);
const
  IssueTag: TAllureString = '{issue}';
  TMSTag: TAllureString = '{tms}';

  function IndexOfPattern(const Tag: TAllureString; out tg: TAllureString): Integer;
  var
    j: Integer;
    pt: TAllureString;
  begin
    tg := '';
    result := -1;
    if Tag='' then exit;
    tg := '{' + AnsiLowerCase(Tag) + '}';
    for j := 0 to Patterns.Count-1 do begin
      pt := AnsiLowerCase(Patterns.Value[j]);
      if Pos(tg, pt)>0 then
        exit(j);
    end;
    result := -1;
  end;

var
  i, j: Integer;
  tg: TAllureString;
begin
  if (Links=nil) or (Patterns=nil) then exit;
  for i := 0 to Links.LinkCount-1 do begin
    if Links.Link[i].Url<>'' then continue;
    j := IndexOfPattern(Links.Link[i].LinkType, tg);
    if j>=0 then
      Links.Link[i].Url := ReplaceText(Patterns.Value[j], tg, Links.Link[i].Name)
  end;
end;

{ TAllureEnvironment }
constructor TAllureEnvironment.Create(const FileName: string);
begin
  inherited Create;
  SelfIncrement := false;
  fFileName := FileName;
  fList := TStringList.Create;
  fList.NameValueSeparator := '=';
  fList.CaseSensitive := false;
  fList.Duplicates := dupAccept;
  LoadValues;
end;

destructor TAllureEnvironment.Destroy;
begin
  Flush;
  fList.Free;
  inherited;
end;

procedure TAllureEnvironment.Flush;
begin
  try
    fList.SaveToFile(fFileName, TEncoding.UTF8);
  except
  end;
end;

function TAllureEnvironment.GetProperty(
  const AKey: TAllureString): TAllureString;
begin
  result := fList.Values[AKey];
end;

procedure TAllureEnvironment.LoadValues;
begin
  if FileExists(fFileName) then begin
    try
      fList.LoadFromFile(fFileName, TEncoding.UTF8);
    except
    end;
  end else
    fList.Clear;
end;

procedure TAllureEnvironment.SetProperty(const AKey, AValue: TAllureString);
begin
  fList.Values[AKey] := AValue;
end;

end.
