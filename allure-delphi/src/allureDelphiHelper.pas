unit allureDelphiHelper;

interface

uses
  allureDelphiInterface, Winapi.Windows, System.SysUtils, System.DateUtils;

type

  TAllureTimeHelper = record helper for TAllureTime
  public
    class function Now: TAllureTime; static;
    class function Cast(dt: TDateTime): TAllureTime; overload; static;
    class function Cast(at: TAllureTime): TDateTime; overload; static;
    function ToString: string;
  end;

  TAllureSeverityLevelHelper = record helper for TAllureSeverityLevel
    function ToString: string;
  end;

  TAllureStatusHelper = record helper for TAllureStatus
    function ToString: string;
  end;

  TAllureStageHelper = record helper for TAllureStage
    function ToString: string;
  end;

  TAllureUpdateActionHelper = class(TInterfacedObject
    ,IAllureTestResultContainerAction
    ,IAllureFixtureResultAction
    ,IAllureTestResultAction
    ,IAllureStepResultAction
  )
  public type
    TAllureObjectProc = reference to procedure (AObject: IUnknown);
    TUpdateTestProc = reference to procedure (const TestResult: IAllureTestResult);
    TUpdateContainerProc = reference to procedure (const Container: IAllureTestResultContainer);
    TUpdateStepProc = reference to procedure (const StepResult: IAllureStepResult);
    TUpdateFixtureProc = reference to procedure (const FixtureResult: IAllureFixtureResult);
  private
    fProc: TAllureObjectProc;
  public
    constructor Create(AProc: TAllureObjectProc);
    procedure Invoke(const Container: IAllureTestResultContainer); overload; safecall;
    procedure Invoke(const FixtureResult: IAllureFixtureResult); overload; safecall;
    procedure Invoke(const TestResult: IAllureTestResult); overload; safecall;
    procedure Invoke(const StepResult: IAllureStepResult); overload; safecall;
  end;

  TAllureHelper = record
  private
    fDllHandle: THandle;
    fLifecycle: IAllureLifecycle;

    procedure Clear;
    function GetLifecycle: IAllureLifecycle;
  public
    class procedure Initialize; static;
    class procedure Finalize; static;
    property Lifecycle: IAllureLifecycle read GetLifecycle;

    procedure UpdateTestCase(UpdateProc: TAllureUpdateActionHelper.TUpdateTestProc); overload;
    procedure UpdateTestCase(const Uuid: TAllureString; UpdateProc: TAllureUpdateActionHelper.TUpdateTestProc); overload;
    procedure UpdateTestContainer(const Uuid: TAllureString; UpdateProc: TAllureUpdateActionHelper.TUpdateContainerProc);
    procedure UpdateStep(UpdateProc: TAllureUpdateActionHelper.TUpdateStepProc); overload;
    procedure UpdateStep(const Uuid: TAllureString; UpdateProc: TAllureUpdateActionHelper.TUpdateStepProc); overload;
    procedure UpdateFixture(UpdateProc: TAllureUpdateActionHelper.TUpdateFixtureProc); overload;
    procedure UpdateFixture(const Uuid: TAllureString; UpdateProc: TAllureUpdateActionHelper.TUpdateFixtureProc); overload;
  end;

var
  Allure: TAllureHelper;

implementation

{ TAllureHelper }

procedure TAllureHelper.Clear;
begin
  try
    fDllHandle := 0;
    fLifecycle := nil;
  except
  end;
end;

class procedure TAllureHelper.Finalize;
type
  TFreeLifecycleProc = procedure {FreeAllureLifecycle}(); safecall;
var
  FreeLifecycleProc: TFreeLifecycleProc;
begin
  try
    if Allure.fLifecycle=nil then exit;
    Allure.fLifecycle := nil;
    if Allure.fDllHandle<>0 then begin
      FreeLifecycleProc := GetProcAddress(Allure.fDllHandle, 'FreeAllureLifecycle');
      if Assigned(FreeLifecycleProc) then begin
        FreeLifecycleProc;
      end;
      FreeLibrary(Allure.fDllHandle);
      Allure.fDllHandle := 0;
    end;
  except
  end;
end;

function TAllureHelper.GetLifecycle: IAllureLifecycle;
begin
  result := fLifecycle;
end;

class procedure TAllureHelper.Initialize;
type
  TGetAllureLifecycleFunc = function {GetAllureLifecycle}(): IAllureLifecycle; safecall;
var
  GetLifecycleFunc: TGetAllureLifecycleFunc;
begin
  try
    if Allure.fLifecycle<>nil then exit;
    Allure.fLifecycle := nil;
    Allure.fDllHandle := LoadLibrary('AllureDelphi.dll');
    if Allure.fDllHandle<>0 then begin
      GetLifecycleFunc := GetProcAddress(Allure.fDllHandle, 'GetAllureLifecycle');
      if Assigned(GetLifecycleFunc) then begin
        Allure.fLifecycle := GetLifecycleFunc();
      end;
      if Allure.fLifecycle=nil then begin
        FreeLibrary(Allure.fDllHandle);
        Allure.fDllHandle := 0;
      end;
    end;
  except
  end;
end;

procedure TAllureHelper.UpdateFixture(const Uuid: TAllureString;
  UpdateProc: TAllureUpdateActionHelper.TUpdateFixtureProc);
begin
  Lifecycle.UpdateFixture(Uuid, TAllureUpdateActionHelper.Create(
    procedure (AObject: IUnknown)
    var
      intf: IAllureFixtureResult;
    begin
      if (AObject<>nil) and (AObject.QueryInterface(IAllureFixtureResult, intf)=0) then
        UpdateProc(intf);
    end
  ));
end;

procedure TAllureHelper.UpdateFixture(
  UpdateProc: TAllureUpdateActionHelper.TUpdateFixtureProc);
begin
  Lifecycle.UpdateFixture(TAllureUpdateActionHelper.Create(
    procedure (AObject: IUnknown)
    var
      intf: IAllureFixtureResult;
    begin
      if (AObject<>nil) and (AObject.QueryInterface(IAllureFixtureResult, intf)=0) then
        UpdateProc(intf);
    end
  ));
end;

procedure TAllureHelper.UpdateStep(const Uuid: TAllureString;
  UpdateProc: TAllureUpdateActionHelper.TUpdateStepProc);
begin
  Lifecycle.UpdateStep(Uuid, TAllureUpdateActionHelper.Create(
    procedure (AObject: IUnknown)
    var
      intf: IAllureStepResult;
    begin
      if (AObject<>nil) and (AObject.QueryInterface(IAllureStepResult, intf)=0) then
        UpdateProc(intf);
    end
  ));
end;

procedure TAllureHelper.UpdateStep(
  UpdateProc: TAllureUpdateActionHelper.TUpdateStepProc);
begin
  Lifecycle.UpdateStep(TAllureUpdateActionHelper.Create(
    procedure (AObject: IUnknown)
    var
      intf: IAllureStepResult;
    begin
      if (AObject<>nil) and (AObject.QueryInterface(IAllureStepResult, intf)=0) then
        UpdateProc(intf);
    end
  ));
end;

procedure TAllureHelper.UpdateTestCase(const Uuid: TAllureString;
  UpdateProc: TAllureUpdateActionHelper.TUpdateTestProc);
begin
  Lifecycle.UpdateTestCase(Uuid, TAllureUpdateActionHelper.Create(
    procedure (AObject: IUnknown)
    var
      intf: IAllureTestResult;
    begin
      if (AObject<>nil) and (AObject.QueryInterface(IAllureTestResult, intf)=0) then
        UpdateProc(intf);
    end
  ));
end;

procedure TAllureHelper.UpdateTestContainer(const Uuid: TAllureString;
  UpdateProc: TAllureUpdateActionHelper.TUpdateContainerProc);
begin
  Lifecycle.UpdateTestContainer(Uuid, TAllureUpdateActionHelper.Create(
    procedure (AObject: IUnknown)
    var
      intf: IAllureTestResultContainer;
    begin
      if (AObject<>nil) and (AObject.QueryInterface(IAllureTestResultContainer, intf)=0) then
        UpdateProc(intf);
    end
  ));
end;

procedure TAllureHelper.UpdateTestCase(UpdateProc: TAllureUpdateActionHelper.TUpdateTestProc);
begin
  Lifecycle.UpdateTestCase(TAllureUpdateActionHelper.Create(
    procedure (AObject: IUnknown)
    var
      intf: IAllureTestResult;
    begin
      if (AObject<>nil) and (AObject.QueryInterface(IAllureTestResult, intf)=0) then
        UpdateProc(intf);
    end
  ));
end;

{ TAllureTimeHelper }

class function TAllureTimeHelper.Cast(at: TAllureTime): TDateTime;
begin
  Result := TTimeZone.Local.ToLocalTime(IncMilliSecond(UnixDateDelta, at.Value));
end;

class function TAllureTimeHelper.Cast(dt: TDateTime): TAllureTime;
begin
  dt := TTimeZone.Local.ToUniversalTime(dt);
  Result.Value := MilliSecondsBetween(UnixDateDelta, dt);
  if dt < UnixDateDelta then
     Result.Value := -Result.Value;
end;

class function TAllureTimeHelper.Now: TAllureTime;
begin
  result := TAllureTime.Cast(System.SysUtils.Now);
end;

function TAllureTimeHelper.ToString: string;
begin
  result := IntToStr(self.Value);
end;

{ TAllureSeverityLevelHelper }

function TAllureSeverityLevelHelper.ToString: string;
begin
  case self of
    aslBlocker: result := 'blocker';
    aslCritical: result := 'critical';
    aslNormal: result := 'normal';
    aslMinor: result := 'minor';
    aslTrivial: result := 'trivial';
    else result := 'unknown';
  end;
end;

{ TAllureStatusHelper }

function TAllureStatusHelper.ToString: string;
begin
  case self of
    asNone: result := 'none';
    asFailed: result := 'failed';
    asBroken: result := 'broken';
    asPassed: result := 'passed';
    asSkipped: result := 'skipped';
    else result := 'unknown';
  end;
end;

{ TAllureStageHelper }

function TAllureStageHelper.ToString: string;
begin
  case self of
    asScheduled: result := 'scheduled';
    asRunning: result := 'running';
    asFinished: result := 'finished';
    asPending: result := 'pending';
    asInterrupted: result := 'interrupted';
    else result := 'unknown';
  end;
end;

{ TAllureUpdateActionHelper }

constructor TAllureUpdateActionHelper.Create(AProc: TAllureObjectProc);
begin
  inherited Create;
  fProc := AProc;
end;

procedure TAllureUpdateActionHelper.Invoke(
  const FixtureResult: IAllureFixtureResult);
begin
  fProc(FixtureResult);
end;

procedure TAllureUpdateActionHelper.Invoke(
  const Container: IAllureTestResultContainer);
begin
  fProc(Container);
end;

procedure TAllureUpdateActionHelper.Invoke(const TestResult: IAllureTestResult);
begin
  fProc(TestResult);
end;

procedure TAllureUpdateActionHelper.Invoke(const StepResult: IAllureStepResult);
begin
  fProc(StepResult);
end;

initialization
  Allure.Clear;

finalization
  Allure.Clear;

end.
