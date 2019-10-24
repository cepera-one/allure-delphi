unit allureDelphiHelper;

interface

uses
  allureDelphiInterface, Winapi.Windows, System.SysUtils, System.DateUtils,
  System.Hash, Winapi.ActiveX, Winapi.ShellApi, Vcl.Graphics,
  Vcl.Imaging.pngimage, System.Classes;

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

  TAllureUuidHelper = record
    class function CreateNew: TAllureString; static;
    class function GenerateHistoryID(const PersistentTestID: TAllureString): TAllureString; static;
  end;

  TMimeTypesMap = record
  const
    PlainText: string = 'text/plain';
    class function GetMimeType(const Path: string): string; static;
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

  TAllureStepProc = reference to procedure ();
  TAllureStepHandler = reference to procedure (
    const StepName, StepDescription: string;
    StepProc: TAllureStepProc);

  TAllureHelper = record
  private
    fDllHandle: THandle;
    fLifecycle: IAllureLifecycle;
    fStepHandler: TAllureStepHandler;

    procedure Clear;
    function GetLifecycle: IAllureLifecycle;
  public
    class procedure Initialize; static;
    class procedure Finalize; static;
    property Lifecycle: IAllureLifecycle read GetLifecycle;

    procedure GenerateReport(const ReportDir: string = ''; const ResultsDir: string = '');

    procedure UpdateTestCase(UpdateProc: TAllureUpdateActionHelper.TUpdateTestProc); overload;
    procedure UpdateTestCase(const Uuid: TAllureString; UpdateProc: TAllureUpdateActionHelper.TUpdateTestProc); overload;
    procedure UpdateTestContainer(const Uuid: TAllureString; UpdateProc: TAllureUpdateActionHelper.TUpdateContainerProc);
    procedure UpdateStep(UpdateProc: TAllureUpdateActionHelper.TUpdateStepProc); overload;
    procedure UpdateStep(const Uuid: TAllureString; UpdateProc: TAllureUpdateActionHelper.TUpdateStepProc); overload;
    procedure UpdateFixture(UpdateProc: TAllureUpdateActionHelper.TUpdateFixtureProc); overload;
    procedure UpdateFixture(const Uuid: TAllureString; UpdateProc: TAllureUpdateActionHelper.TUpdateFixtureProc); overload;

    procedure AssignStepHandler(StepHandler: TAllureStepHandler);
    procedure RunStep(const StepName: string; StepProc: TAllureStepProc); overload;
    procedure RunStep(const StepName, StepDescription: string; StepProc: TAllureStepProc); overload;

    procedure AddAttachment(const Name, AType, FileExtension: String; const Stream: IStream); overload;
    procedure AddAttachment(const Name, AType, Path: String); overload;
    procedure AddAttachment(const Name, AType: String; Content: Pointer; Size: UInt64; const FileExtension: String = ''); overload;
    procedure AddAttachment(const Name, AType: String; const Content: TBytes; const FileExtension: String = ''); overload;
    procedure AddAttachment(const Path: String; const Name: String = ''); overload;
    procedure AddAttachmentText(const Name, AValue: String);
    procedure AddScreenshot(
      const Name: String = '';
      WindowHandle: HWND = 0;
      Left: Integer = -1000000;
      Top: Integer = -1000000;
      Width: Integer = -1000000;
      Height: Integer = -1000000);

  end;

var
  Allure: TAllureHelper;

implementation

{ TAllureHelper }

procedure TAllureHelper.AddAttachment(const Name, AType: String;
  Content: Pointer; Size: UInt64; const FileExtension: String);
begin
  Lifecycle.AddAttachment(Name, AType, Content, Size, FileExtension);
end;

procedure TAllureHelper.AddAttachment(const Name, AType, Path: String);
begin
  Lifecycle.AddAttachment(Name, AType, Path);
end;

procedure TAllureHelper.AddAttachment(const Name, AType, FileExtension: String;
  const Stream: IStream);
begin
  Lifecycle.AddAttachment(Name, AType, FileExtension, Stream);
end;

procedure TAllureHelper.AddAttachment(const Path, Name: String);
begin
  Lifecycle.AddAttachment(Path, Name);
end;

procedure TAllureHelper.AddAttachment(const Name, AType: String;
  const Content: TBytes; const FileExtension: String);
begin
  Lifecycle.AddAttachment(Name, AType, @Content[0], Length(Content), FileExtension);
end;

procedure TAllureHelper.AddAttachmentText(const Name, AValue: String);
begin
  AddAttachment(Name, TMimeTypesMap.PlainText, TEncoding.UTF8.GetBytes(AValue));
end;

procedure TAllureHelper.AddScreenshot(const Name: String;
  WindowHandle: HWND; Left, Top, Width, Height: Integer);
var
  nm: string;
  r: TRect;
  dc: HDC;
  bmp: TBitmap;
  png: TPngImage;
  ms: TMemoryStream;
begin
  if Name='' then
    nm := 'Screenshot'
  else
    nm := Name;
  if WindowHandle=0 then
    WindowHandle := GetDesktopWindow;
  if WindowHandle=0 then exit;
  if (Left=-1000000) or (Top=-1000000) or (Width=-1000000) or (Height=-1000000)
  then begin
    if not GetWindowRect(WindowHandle, r) then
      exit;
  end else begin
    r.Left := Left;
    r.Top := Top;
    r.Width := Width;
    r.Height := Height;
  end;
  png := TPngImage.Create;
  bmp := TBitmap.Create;
  ms := TMemoryStream.Create;
  dc := GetWindowDC(WindowHandle);
  try
    bmp.PixelFormat := pf24bit;
    bmp.Height := r.Height;
    bmp.Width := r.Width;
    BitBlt(bmp.Canvas.Handle, 0, 0, bmp.Width, bmp.Height, dc, r.Left, r.Top, SRCCOPY);
    png.Assign(bmp);
    png.SaveToStream(ms);
    AddAttachment(nm, 'image/x-png', ms.Memory, ms.Size, '.png');
  finally
    ms.Free;
    ReleaseDC(WindowHandle, dc);
    bmp.Free;
    png.Free;
  end;
end;

procedure TAllureHelper.AssignStepHandler(StepHandler: TAllureStepHandler);
begin
  fStepHandler := StepHandler;
end;

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

procedure TAllureHelper.GenerateReport(const ReportDir: string = ''; const ResultsDir: string = '');
var
  p, resDir, repDir: String;
begin
  if ResultsDir<>'' then
    resDir := ResultsDir
  else if Lifecycle<>nil then
    resDir := Lifecycle.ResultsDirectory
  else begin
    resDir := 'allure-results';
  end;
  if DirectoryExists(resDir) then begin
    if ReportDir<>'' then begin
      // To specified folder
      p := 'generate --clean --output "' + ReportDir + '" "' + resDir + '"';
      ShellExecute(0, 'open', 'allure', PChar(p), nil, 1);
      sleep(5000);
      p := 'open "' + ReportDir + '"';
      ShellExecute(0, 'open', 'allure', PChar(p), nil, 1);
    end else begin
      // To temp folder
      p := 'serve "' + resDir + '"';
      ShellExecute(0, 'open', 'allure', PChar(p), nil, 1);
    end;
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

procedure TAllureHelper.RunStep(const StepName, StepDescription: string;
  StepProc: TAllureStepProc);
begin
  if Assigned(fStepHandler) then begin
    fStepHandler(StepName, StepDescription, StepProc);
  end else
    StepProc();
end;

procedure TAllureHelper.RunStep(const StepName: string;
  StepProc: TAllureStepProc);
begin
  RunStep(StepName, '', StepProc);
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

{ TMimeTypesMap }

class function TMimeTypesMap.GetMimeType(const Path: string): string;
type
  TMimeRec = record
    ext: string;
    mime: string;
  end;

const
  MimeTypes: array [0..384] of TMimeRec = (
    { Animation }
    (ext: 'nml'; mime: 'animation/narrative'),
    { Audio }
    (ext: 'aac'; mime: 'audio/mp4'),
    (ext: 'aif'; mime: 'audio/x-aiff'),
    (ext: 'aifc'; mime: 'audio/x-aiff'),
    (ext: 'aiff'; mime: 'audio/x-aiff'),
    (ext: 'au'; mime: 'audio/basic'),
    (ext: 'gsm'; mime: 'audio/x-gsm'),
    (ext: 'kar'; mime: 'audio/midi'),
    (ext: 'm3u'; mime: 'audio/mpegurl'),
    (ext: 'm4a'; mime: 'audio/x-mpg'),
    (ext: 'mid'; mime: 'audio/midi'),
    (ext: 'midi'; mime: 'audio/midi'),
    (ext: 'mpega'; mime: 'audio/x-mpg'),
    (ext: 'mp2'; mime: 'audio/x-mpg'),
    (ext: 'mp3'; mime: 'audio/x-mpg'),
    (ext: 'mpga'; mime: 'audio/x-mpg'),
    (ext: 'm3u'; mime: 'audio/x-mpegurl'),
    (ext: 'pls'; mime: 'audio/x-scpls'),
    (ext: 'qcp'; mime: 'audio/vnd.qcelp'),
    (ext: 'ra'; mime: 'audio/x-realaudio'),
    (ext: 'ram'; mime: 'audio/x-pn-realaudio'),
    (ext: 'rm'; mime: 'audio/x-pn-realaudio'),
    (ext: 'sd2'; mime: 'audio/x-sd2'),
    (ext: 'sid'; mime: 'audio/prs.sid'),
    (ext: 'snd'; mime: 'audio/basic'),
    (ext: 'wav'; mime: 'audio/x-wav'),
    (ext: 'wax'; mime: 'audio/x-ms-wax'),
    (ext: 'wma'; mime: 'audio/x-ms-wma'),
    (ext: 'mjf'; mime: 'audio/x-vnd.AudioExplosion.MjuiceMediaFile'),
    { Image }
    (ext: 'art'; mime: 'image/x-jg'),
    (ext: 'bmp'; mime: 'image/bmp'),
    (ext: 'cdr'; mime: 'image/x-coreldraw'),
    (ext: 'cdt'; mime: 'image/x-coreldrawtemplate'),
    (ext: 'cpt'; mime: 'image/x-corelphotopaint'),
    (ext: 'djv'; mime: 'image/vnd.djvu'),
    (ext: 'djvu'; mime: 'image/vnd.djvu'),
    (ext: 'gif'; mime: 'image/gif'),
    (ext: 'ief'; mime: 'image/ief'),
    (ext: 'ico'; mime: 'image/x-icon'),
    (ext: 'jng'; mime: 'image/x-jng'),
    (ext: 'jpg'; mime: 'image/jpeg'),
    (ext: 'jpeg'; mime: 'image/jpeg'),
    (ext: 'jpe'; mime: 'image/jpeg'),
    (ext: 'pat'; mime: 'image/x-coreldrawpattern'),
    (ext: 'pcx'; mime: 'image/pcx'),
    (ext: 'pbm'; mime: 'image/x-portable-bitmap'),
    (ext: 'pgm'; mime: 'image/x-portable-graymap'),
    (ext: 'pict'; mime: 'image/x-pict'),
    (ext: 'png'; mime: 'image/x-png'),
    (ext: 'pnm'; mime: 'image/x-portable-anymap'),
    (ext: 'pntg'; mime: 'image/x-macpaint'),
    (ext: 'ppm'; mime: 'image/x-portable-pixmap'),
    (ext: 'psd'; mime: 'image/x-psd'),
    (ext: 'qtif'; mime: 'image/x-quicktime'),
    (ext: 'ras'; mime: 'image/x-cmu-raster'),
    (ext: 'rf'; mime: 'image/vnd.rn-realflash'),
    (ext: 'rgb'; mime: 'image/x-rgb'),
    (ext: 'rp'; mime: 'image/vnd.rn-realpix'),
    (ext: 'sgi'; mime: 'image/x-sgi'),
    (ext: 'svg'; mime: 'image/svg+xml'),
    (ext: 'svgz'; mime: 'image/svg+xml'),
    (ext: 'targa'; mime: 'image/x-targa'),
    (ext: 'tif'; mime: 'image/x-tiff'),
    (ext: 'wbmp'; mime: 'image/vnd.wap.wbmp'),
    (ext: 'webp'; mime: 'image/webp'),
    (ext: 'xbm'; mime: 'image/xbm'),
    (ext: 'xbm'; mime: 'image/x-xbitmap'),
    (ext: 'xpm'; mime: 'image/x-xpixmap'),
    (ext: 'xwd'; mime: 'image/x-xwindowdump'),
    { Text }
    (ext: '323'; mime: 'text/h323'),
    (ext: 'xml'; mime: 'text/xml'),
    (ext: 'uls'; mime: 'text/iuls'),
    (ext: 'txt'; mime: 'text/plain'),
    (ext: 'rtx'; mime: 'text/richtext'),
    (ext: 'wsc'; mime: 'text/scriptlet'),
    (ext: 'rt'; mime: 'text/vnd.rn-realtext'),
    (ext: 'htt'; mime: 'text/webviewhtml'),
    (ext: 'htc'; mime: 'text/x-component'),
    (ext: 'vcf'; mime: 'text/x-vcard'),
    { Video }
    (ext: 'asf'; mime: 'video/x-ms-asf'),
    (ext: 'asx'; mime: 'video/x-ms-asf'),
    (ext: 'avi'; mime: 'video/x-msvideo'),
    (ext: 'dl'; mime: 'video/dl'),
    (ext: 'dv'; mime: 'video/dv'),
    (ext: 'flc'; mime: 'video/flc'),
    (ext: 'fli'; mime: 'video/fli'),
    (ext: 'gl'; mime: 'video/gl'),
    (ext: 'lsf'; mime: 'video/x-la-asf'),
    (ext: 'lsx'; mime: 'video/x-la-asf'),
    (ext: 'mng'; mime: 'video/x-mng'),
    (ext: 'mp2'; mime: 'video/mpeg'),
    (ext: 'mp3'; mime: 'video/mpeg'),
    (ext: 'mp4'; mime: 'video/mpeg'),
    (ext: 'mpeg'; mime: 'video/x-mpeg2a'),
    (ext: 'mpa'; mime: 'video/mpeg'),
    (ext: 'mpe'; mime: 'video/mpeg'),
    (ext: 'mpg'; mime: 'video/mpeg'),
    (ext: 'ogv'; mime: 'video/ogg'),
    (ext: 'moov'; mime: 'video/quicktime'),
    (ext: 'mov'; mime: 'video/quicktime'),
    (ext: 'mxu'; mime: 'video/vnd.mpegurl'),
    (ext: 'qt'; mime: 'video/quicktime'),
    (ext: 'qtc'; mime: 'video/x-qtc'),     {Do not loccalize}
    (ext: 'rv'; mime: 'video/vnd.rn-realvideo'),
    (ext: 'ivf'; mime: 'video/x-ivf'),
    (ext: 'webm'; mime: 'video/webm'),
    (ext: 'wm'; mime: 'video/x-ms-wm'),
    (ext: 'wmp'; mime: 'video/x-ms-wmp'),
    (ext: 'wmv'; mime: 'video/x-ms-wmv'),
    (ext: 'wmx'; mime: 'video/x-ms-wmx'),
    (ext: 'wvx'; mime: 'video/x-ms-wvx'),
    (ext: 'rms'; mime: 'video/vnd.rn-realvideo-secure'),
    (ext: 'asx'; mime: 'video/x-ms-asf-plugin'),
    (ext: 'movie'; mime: 'video/x-sgi-movie'),
    { Application }
    (ext: '7z'; mime: 'application/x-7z-compressed'),
    (ext: 'a'; mime: 'application/x-archive'),
    (ext: 'aab'; mime: 'application/x-authorware-bin'),
    (ext: 'aam'; mime: 'application/x-authorware-map'),
    (ext: 'aas'; mime: 'application/x-authorware-seg'),
    (ext: 'abw'; mime: 'application/x-abiword'),
    (ext: 'ace'; mime: 'application/x-ace-compressed'),
    (ext: 'ai'; mime: 'application/postscript'),
    (ext: 'alz'; mime: 'application/x-alz-compressed'),
    (ext: 'ani'; mime: 'application/x-navi-animation'),
    (ext: 'arj'; mime: 'application/x-arj'),
    (ext: 'asf'; mime: 'application/vnd.ms-asf'),
    (ext: 'bat'; mime: 'application/x-msdos-program'),
    (ext: 'bcpio'; mime: 'application/x-bcpio'),
    (ext: 'boz'; mime: 'application/x-bzip2'),
    (ext: 'bz'; mime: 'application/x-bzip'),
    (ext: 'bz2'; mime: 'application/x-bzip2'),
    (ext: 'cab'; mime: 'application/vnd.ms-cab-compressed'),
    (ext: 'cat'; mime: 'application/vnd.ms-pki.seccat'),
    (ext: 'ccn'; mime: 'application/x-cnc'),
    (ext: 'cco'; mime: 'application/x-cocoa'),
    (ext: 'cdf'; mime: 'application/x-cdf'),
    (ext: 'cer'; mime: 'application/x-x509-ca-cert'),
    (ext: 'chm'; mime: 'application/vnd.ms-htmlhelp'),
    (ext: 'chrt'; mime: 'application/vnd.kde.kchart'),
    (ext: 'cil'; mime: 'application/vnd.ms-artgalry'),
    (ext: 'class'; mime: 'application/java-vm'),
    (ext: 'com'; mime: 'application/x-msdos-program'),
    (ext: 'clp'; mime: 'application/x-msclip'),
    (ext: 'cpio'; mime: 'application/x-cpio'),
    (ext: 'cpt'; mime: 'application/mac-compactpro'),
    (ext: 'cqk'; mime: 'application/x-calquick'),
    (ext: 'crd'; mime: 'application/x-mscardfile'),
    (ext: 'crl'; mime: 'application/pkix-crl'),
    (ext: 'csh'; mime: 'application/x-csh'),
    (ext: 'dar'; mime: 'application/x-dar'),
    (ext: 'dbf'; mime: 'application/x-dbase'),
    (ext: 'dcr'; mime: 'application/x-director'),
    (ext: 'deb'; mime: 'application/x-debian-package'),
    (ext: 'dir'; mime: 'application/x-director'),
    (ext: 'dist'; mime: 'vnd.apple.installer+xml'),
    (ext: 'distz'; mime: 'vnd.apple.installer+xml'),
    (ext: 'dll'; mime: 'application/x-msdos-program'),
    (ext: 'dmg'; mime: 'application/x-apple-diskimage'),
    (ext: 'doc'; mime: 'application/msword'),
    (ext: 'dot'; mime: 'application/msword'),
    (ext: 'dvi'; mime: 'application/x-dvi'),
    (ext: 'dxr'; mime: 'application/x-director'),
    (ext: 'ebk'; mime: 'application/x-expandedbook'),
    (ext: 'eps'; mime: 'application/postscript'),
    (ext: 'evy'; mime: 'application/envoy'),
    (ext: 'exe'; mime: 'application/x-msdos-program'),
    (ext: 'fdf'; mime: 'application/vnd.fdf'),
    (ext: 'fif'; mime: 'application/fractals'),
    (ext: 'flm'; mime: 'application/vnd.kde.kivio'),
    (ext: 'fml'; mime: 'application/x-file-mirror-list'),
    (ext: 'gzip'; mime: 'application/x-gzip'),
    (ext: 'gnumeric'; mime: 'application/x-gnumeric'),
    (ext: 'gtar'; mime: 'application/x-gtar'),
    (ext: 'gz'; mime: 'application/x-gzip'),
    (ext: 'hdf'; mime: 'application/x-hdf'),
    (ext: 'hlp'; mime: 'application/winhlp'),
    (ext: 'hpf'; mime: 'application/x-icq-hpf'),
    (ext: 'hqx'; mime: 'application/mac-binhex40'),
    (ext: 'hta'; mime: 'application/hta'),
    (ext: 'ims'; mime: 'application/vnd.ms-ims'),
    (ext: 'ins'; mime: 'application/x-internet-signup'),
    (ext: 'iii'; mime: 'application/x-iphone'),
    (ext: 'iso'; mime: 'application/x-iso9660-image'),
    (ext: 'jar'; mime: 'application/java-archive'),
    (ext: 'json'; mime: 'application/json'),
    (ext: 'karbon'; mime: 'application/vnd.kde.karbon'),
    (ext: 'kfo'; mime: 'application/vnd.kde.kformula'),
    (ext: 'kon'; mime: 'application/vnd.kde.kontour'),
    (ext: 'kpr'; mime: 'application/vnd.kde.kpresenter'),
    (ext: 'kpt'; mime: 'application/vnd.kde.kpresenter'),
    (ext: 'kwd'; mime: 'application/vnd.kde.kword'),
    (ext: 'kwt'; mime: 'application/vnd.kde.kword'),
    (ext: 'latex'; mime: 'application/x-latex'),
    (ext: 'lha'; mime: 'application/x-lzh'),
    (ext: 'lcc'; mime: 'application/fastman'),
    (ext: 'lrm'; mime: 'application/vnd.ms-lrm'),
    (ext: 'lz'; mime: 'application/x-lzip'),
    (ext: 'lzh'; mime: 'application/x-lzh'),
    (ext: 'lzma'; mime: 'application/x-lzma'),
    (ext: 'lzo'; mime: 'application/x-lzop'),
    (ext: 'lzx'; mime: 'application/x-lzx'),
    (ext: 'm13'; mime: 'application/x-msmediaview'),
    (ext: 'm14'; mime: 'application/x-msmediaview'),
    (ext: 'mpp'; mime: 'application/vnd.ms-project'),
    (ext: 'mvb'; mime: 'application/x-msmediaview'),
    (ext: 'man'; mime: 'application/x-troff-man'),
    (ext: 'mdb'; mime: 'application/x-msaccess'),
    (ext: 'me'; mime: 'application/x-troff-me'),
    (ext: 'ms'; mime: 'application/x-troff-ms'),
    (ext: 'msi'; mime: 'application/x-msi'),
    (ext: 'mpkg'; mime: 'vnd.apple.installer+xml'),
    (ext: 'mny'; mime: 'application/x-msmoney'),
    (ext: 'nix'; mime: 'application/x-mix-transfer'),
    (ext: 'o'; mime: 'application/x-object'),
    (ext: 'oda'; mime: 'application/oda'),
    (ext: 'odb'; mime: 'application/vnd.oasis.opendocument.database'),
    (ext: 'odc'; mime: 'application/vnd.oasis.opendocument.chart'),
    (ext: 'odf'; mime: 'application/vnd.oasis.opendocument.formula'),
    (ext: 'odg'; mime: 'application/vnd.oasis.opendocument.graphics'),
    (ext: 'odi'; mime: 'application/vnd.oasis.opendocument.image'),
    (ext: 'odm'; mime: 'application/vnd.oasis.opendocument.text-master'),
    (ext: 'odp'; mime: 'application/vnd.oasis.opendocument.presentation'),
    (ext: 'ods'; mime: 'application/vnd.oasis.opendocument.spreadsheet'),
    (ext: 'ogg'; mime: 'application/ogg'),
    (ext: 'odt'; mime: 'application/vnd.oasis.opendocument.text'),
    (ext: 'otg'; mime: 'application/vnd.oasis.opendocument.graphics-template'),
    (ext: 'oth'; mime: 'application/vnd.oasis.opendocument.text-web'),
    (ext: 'otp'; mime: 'application/vnd.oasis.opendocument.presentation-template'),
    (ext: 'ots'; mime: 'application/vnd.oasis.opendocument.spreadsheet-template'),
    (ext: 'ott'; mime: 'application/vnd.oasis.opendocument.text-template'),
    (ext: 'p10'; mime: 'application/pkcs10'),
    (ext: 'p12'; mime: 'application/x-pkcs12'),
    (ext: 'p7b'; mime: 'application/x-pkcs7-certificates'),
    (ext: 'p7m'; mime: 'application/pkcs7-mime'),
    (ext: 'p7r'; mime: 'application/x-pkcs7-certreqresp'),
    (ext: 'p7s'; mime: 'application/pkcs7-signature'),
    (ext: 'package'; mime: 'application/vnd.autopackage'),
    (ext: 'pfr'; mime: 'application/font-tdpfr'),
    (ext: 'pkg'; mime: 'vnd.apple.installer+xml'),
    (ext: 'pdf'; mime: 'application/pdf'),
    (ext: 'pko'; mime: 'application/vnd.ms-pki.pko'),
    (ext: 'pl'; mime: 'application/x-perl'),
    (ext: 'pnq'; mime: 'application/x-icq-pnq'),
    (ext: 'pot'; mime: 'application/mspowerpoint'),
    (ext: 'pps'; mime: 'application/mspowerpoint'),
    (ext: 'ppt'; mime: 'application/mspowerpoint'),
    (ext: 'ppz'; mime: 'application/mspowerpoint'),
    (ext: 'ps'; mime: 'application/postscript'),
    (ext: 'pub'; mime: 'application/x-mspublisher'),
    (ext: 'qpw'; mime: 'application/x-quattropro'),
    (ext: 'qtl'; mime: 'application/x-quicktimeplayer'),
    (ext: 'rar'; mime: 'application/rar'),
    (ext: 'rdf'; mime: 'application/rdf+xml'),
    (ext: 'rjs'; mime: 'application/vnd.rn-realsystem-rjs'),
    (ext: 'rm'; mime: 'application/vnd.rn-realmedia'),
    (ext: 'rmf'; mime: 'application/vnd.rmf'),
    (ext: 'rmp'; mime: 'application/vnd.rn-rn_music_package'),
    (ext: 'rmx'; mime: 'application/vnd.rn-realsystem-rmx'),
    (ext: 'rnx'; mime: 'application/vnd.rn-realplayer'),
    (ext: 'rpm'; mime: 'application/x-redhat-package-manager'),
    (ext: 'rsml'; mime: 'application/vnd.rn-rsml'),
    (ext: 'rtsp'; mime: 'application/x-rtsp'),
    (ext: 'rss'; mime: 'application/rss+xml'),
    (ext: 'scm'; mime: 'application/x-icq-scm'),
    (ext: 'ser'; mime: 'application/java-serialized-object'),
    (ext: 'scd'; mime: 'application/x-msschedule'),
    (ext: 'sda'; mime: 'application/vnd.stardivision.draw'),
    (ext: 'sdc'; mime: 'application/vnd.stardivision.calc'),
    (ext: 'sdd'; mime: 'application/vnd.stardivision.impress'),
    (ext: 'sdp'; mime: 'application/x-sdp'),
    (ext: 'setpay'; mime: 'application/set-payment-initiation'),
    (ext: 'setreg'; mime: 'application/set-registration-initiation'),
    (ext: 'sh'; mime: 'application/x-sh'),
    (ext: 'shar'; mime: 'application/x-shar'),
    (ext: 'shw'; mime: 'application/presentations'),
    (ext: 'sit'; mime: 'application/x-stuffit'),
    (ext: 'sitx'; mime: 'application/x-stuffitx'),
    (ext: 'skd'; mime: 'application/x-koan'),
    (ext: 'skm'; mime: 'application/x-koan'),
    (ext: 'skp'; mime: 'application/x-koan'),
    (ext: 'skt'; mime: 'application/x-koan'),
    (ext: 'smf'; mime: 'application/vnd.stardivision.math'),
    (ext: 'smi'; mime: 'application/smil'),
    (ext: 'smil'; mime: 'application/smil'),
    (ext: 'spl'; mime: 'application/futuresplash'),
    (ext: 'ssm'; mime: 'application/streamingmedia'),
    (ext: 'sst'; mime: 'application/vnd.ms-pki.certstore'),
    (ext: 'stc'; mime: 'application/vnd.sun.xml.calc.template'),
    (ext: 'std'; mime: 'application/vnd.sun.xml.draw.template'),
    (ext: 'sti'; mime: 'application/vnd.sun.xml.impress.template'),
    (ext: 'stl'; mime: 'application/vnd.ms-pki.stl'),
    (ext: 'stw'; mime: 'application/vnd.sun.xml.writer.template'),
    (ext: 'svi'; mime: 'application/softvision'),
    (ext: 'sv4cpio'; mime: 'application/x-sv4cpio'),
    (ext: 'sv4crc'; mime: 'application/x-sv4crc'),
    (ext: 'swf'; mime: 'application/x-shockwave-flash'),
    (ext: 'swf1'; mime: 'application/x-shockwave-flash'),
    (ext: 'sxc'; mime: 'application/vnd.sun.xml.calc'),
    (ext: 'sxi'; mime: 'application/vnd.sun.xml.impress'),
    (ext: 'sxm'; mime: 'application/vnd.sun.xml.math'),
    (ext: 'sxw'; mime: 'application/vnd.sun.xml.writer'),
    (ext: 'sxg'; mime: 'application/vnd.sun.xml.writer.global'),
    (ext: 't'; mime: 'application/x-troff'),
    (ext: 'tar'; mime: 'application/x-tar'),
    (ext: 'tcl'; mime: 'application/x-tcl'),
    (ext: 'tex'; mime: 'application/x-tex'),
    (ext: 'texi'; mime: 'application/x-texinfo'),
    (ext: 'texinfo'; mime: 'application/x-texinfo'),
    (ext: 'tbz'; mime: 'application/x-bzip-compressed-tar'),
    (ext: 'tbz2'; mime: 'application/x-bzip-compressed-tar'),
    (ext: 'tgz'; mime: 'application/x-compressed-tar'),
    (ext: 'tlz'; mime: 'application/x-lzma-compressed-tar'),
    (ext: 'tr'; mime: 'application/x-troff'),
    (ext: 'trm'; mime: 'application/x-msterminal'),
    (ext: 'troff'; mime: 'application/x-troff'),
    (ext: 'tsp'; mime: 'application/dsptype'),
    (ext: 'torrent'; mime: 'application/x-bittorrent'),
    (ext: 'ttz'; mime: 'application/t-time'),
    (ext: 'txz'; mime: 'application/x-xz-compressed-tar'),
    (ext: 'udeb'; mime: 'application/x-debian-package'),
    (ext: 'uin'; mime: 'application/x-icq'),
    (ext: 'urls'; mime: 'application/x-url-list'),
    (ext: 'ustar'; mime: 'application/x-ustar'),
    (ext: 'vcd'; mime: 'application/x-cdlink'),
    (ext: 'vor'; mime: 'application/vnd.stardivision.writer'),
    (ext: 'vsl'; mime: 'application/x-cnet-vsl'),
    (ext: 'wcm'; mime: 'application/vnd.ms-works'),
    (ext: 'wb1'; mime: 'application/x-quattropro'),
    (ext: 'wb2'; mime: 'application/x-quattropro'),
    (ext: 'wb3'; mime: 'application/x-quattropro'),
    (ext: 'wdb'; mime: 'application/vnd.ms-works'),
    (ext: 'wks'; mime: 'application/vnd.ms-works'),
    (ext: 'wmd'; mime: 'application/x-ms-wmd'),
    (ext: 'wms'; mime: 'application/x-ms-wms'),
    (ext: 'wmz'; mime: 'application/x-ms-wmz'),
    (ext: 'wp5'; mime: 'application/wordperfect5.1'),
    (ext: 'wpd'; mime: 'application/wordperfect'),
    (ext: 'wpl'; mime: 'application/vnd.ms-wpl'),
    (ext: 'wps'; mime: 'application/vnd.ms-works'),
    (ext: 'wri'; mime: 'application/x-mswrite'),
    (ext: 'xfdf'; mime: 'application/vnd.adobe.xfdf'),
    (ext: 'xls'; mime: 'application/x-msexcel'),
    (ext: 'xlb'; mime: 'application/x-msexcel'),
    (ext: 'xpi'; mime: 'application/x-xpinstall'),
    (ext: 'xps'; mime: 'application/vnd.ms-xpsdocument'),
    (ext: 'xsd'; mime: 'application/vnd.sun.xml.draw'),
    (ext: 'xul'; mime: 'application/vnd.mozilla.xul+xml'),
    (ext: 'z'; mime: 'application/x-compress'),
    (ext: 'zoo'; mime: 'application/x-zoo'),
    (ext: 'zip'; mime: 'application/x-zip-compressed'),
    { WAP }
    (ext: 'wbmp'; mime: 'image/vnd.wap.wbmp'),
    (ext: 'wml'; mime: 'text/vnd.wap.wml'),
    (ext: 'wmlc'; mime: 'application/vnd.wap.wmlc'),
    (ext: 'wmls'; mime: 'text/vnd.wap.wmlscript'),
    (ext: 'wmlsc'; mime: 'application/vnd.wap.wmlscriptc'),
    { Non-web text}
    (ext: 'asm'; mime: 'text/x-asm'),
    (ext: 'p'; mime: 'text/x-pascal'),
    (ext: 'pas'; mime: 'text/x-pascal'),
    (ext: 'cs'; mime: 'text/x-csharp'),
    (ext: 'c'; mime: 'text/x-csrc'),
    (ext: 'c++'; mime: 'text/x-c++src'),
    (ext: 'cpp'; mime: 'text/x-c++src'),
    (ext: 'cxx'; mime: 'text/x-c++src'),
    (ext: 'cc'; mime: 'text/x-c++src'),
    (ext: 'h'; mime: 'text/x-chdr'),
    (ext: 'h++'; mime: 'text/x-c++hdr'),
    (ext: 'hpp'; mime: 'text/x-c++hdr'),
    (ext: 'hxx'; mime: 'text/x-c++hdr'),
    (ext: 'hh'; mime: 'text/x-c++hdr'),
    (ext: 'java'; mime: 'text/x-java'),
    { WEB }
    (ext: 'css'; mime: 'text/css'),
    (ext: 'js'; mime: 'text/javascript'),
    (ext: 'htm'; mime: 'text/html'),
    (ext: 'html'; mime: 'text/html'),
    (ext: 'xhtml'; mime: 'application/xhtml+xml'),
    (ext: 'xht'; mime: 'application/xhtml+xml'),
    (ext: 'rdf'; mime: 'application/rdf+xml'),
    (ext: 'rss'; mime: 'application/rss+xml'),
    (ext: 'ls'; mime: 'text/javascript'),
    (ext: 'mocha'; mime: 'text/javascript'),
    (ext: 'shtml'; mime: 'server-parsed-html'),
    (ext: 'xml'; mime: 'text/xml'),
    (ext: 'sgm'; mime: 'text/sgml'),
    (ext: 'sgml'; mime: 'text/sgml'),
    { Message }
    (ext: 'mht'; mime: 'message/rfc822')
  );

var
  e: string;
  i: Integer;
begin
  result := '';
  e := AnsiLowerCase(ExtractFileExt(Path));
  if (e<>'') and (e[1]='.') then
    e := Copy(e, 2, MaxInt);
  for i := 0 to High(MimeTypes) do begin
    if SameStr(e, MimeTypes[i].ext) then begin
      exit(MimeTypes[i].mime);
    end;
  end;
end;

{ TAllureUuidHelper }

class function TAllureUuidHelper.CreateNew: TAllureString;
begin
  result := Copy(AnsiLowerCase(TGUID.NewGuid.ToString), 2, 36);
end;

class function TAllureUuidHelper.GenerateHistoryID(
  const PersistentTestID: TAllureString): TAllureString;
begin
  result := THashMD5.GetHashString(PersistentTestID);
end;

initialization
  Allure.Clear;

finalization
  Allure.Clear;

end.
