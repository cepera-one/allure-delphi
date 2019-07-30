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

initialization
  Allure.Clear;

finalization
  Allure.Clear;

end.
