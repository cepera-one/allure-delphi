unit uAllureTests;

interface

uses
  DUnitX.TestFramework, allureDelphiHelper, allureDelphiInterface,
  System.SysUtils, System.JSON, System.IOUtils, System.Hash;

type

  [TestFixture]
  TAllureDelphiTests = class(TObject)
  private
    function MakeRandomStep(const ParentID: TAllureString): string;
  public
    constructor Create;
    destructor Destroy; override;

    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure ShouldLifecycleExists;

    [Test]
    procedure ShouldReadAllureConfig;

    [Test]
    procedure ShouldCreateTest;

    [Test]
    procedure ShouldCreateTestContainer;

    [Test]
    procedure ShouldCreateChildTestContainer;

    [Test]
    procedure ShouldAddStepsToTests;

    [Test]
    procedure ShouldUpdateTest;

    [Test]
    procedure ShouldUpdateContainer;

    [Test]
    procedure ShouldCreateTestFixture;

    // Test with TestCase Attribute to supply parameters.
//    [Test]
//    [TestCase('TestA','1,2')]
//    [TestCase('TestB','3,4')]
//    procedure Test2(const AValue1 : Integer;const AValue2 : Integer);
  end;

implementation

constructor TAllureDelphiTests.Create;
begin
  inherited;
  Allure.Initialize;
end;

destructor TAllureDelphiTests.Destroy;
begin
  Allure.Finalize;
  inherited;
end;

function TAllureDelphiTests.MakeRandomStep(
  const ParentID: TAllureString): string;
var
  step: IAllureStepResult;
  Uuid: TAllureString;
begin
  result := '';
  step := Allure.Lifecycle.CreateStepResult;
  Uuid := Copy(AnsiLowerCase(TGUID.NewGuid.ToString), 2, 36);
  step.Name := 'Step-' + Uuid;
  Allure.Lifecycle.StartStep(Uuid, step);
  Allure.Lifecycle.StopStep(Uuid);
  result := step.Name;
end;

procedure TAllureDelphiTests.Setup;
begin
end;

procedure TAllureDelphiTests.TearDown;
begin
end;

procedure TAllureDelphiTests.ShouldAddStepsToTests;
var
  res: IAllureTestResult;
  fn, step0, step1: string;
  jv, v: TJSONValue;
begin
  Assert.IsNotNull(Allure.Lifecycle);
  res := Allure.Lifecycle.CreateTestResult;
  Assert.IsNotNull(res);
  res.Name := 'TAllureDelphiTests.ShouldAddStepsToTests';
  res.HistoryID := THashMD5.GetHashString(res.Name);
  res.Status := asPassed;
  res.Labels.AddNew.SetPackage('AllureDelphiTest.exe');
  res.Labels.AddNew.SetSeverity(aslCritical);

  Allure.Lifecycle.ScheduleTestCase(res);
  Allure.Lifecycle.StartTestCase(res.UUID);

  step0 := MakeRandomStep(res.UUID);
  step1 := MakeRandomStep(res.UUID);

  Allure.Lifecycle.StopTestCase(res.UUID);
  Allure.Lifecycle.WriteTestCase(res.UUID);

  fn := Allure.Lifecycle.ResultsDirectory + '\' + res.UUID + '-result.json';
  if FileExists(fn) then begin
    jv := TJSONObject.ParseJSONValue(TFile.ReadAllText(fn), False, True);
    try
      Assert.IsNotNull(jv);
      v := jv.FindValue('uuid');
      Assert.IsNotNull(v);
      Assert.AreEqual(res.UUID, v.Value, true);
      v := jv.FindValue('name');
      Assert.IsNotNull(v);
      Assert.AreEqual(res.Name, v.Value, true);
      v := jv.FindValue('steps[0].name');
      Assert.IsNotNull(v);
      Assert.AreEqual(step0, v.Value, true);
      v := jv.FindValue('steps[1].name');
      Assert.IsNotNull(v);
      Assert.AreEqual(step1, v.Value, true);
    finally
      jv.Free;
    end;
  end else
    Assert.Fail('Test result not created');
  res := nil;
end;

procedure TAllureDelphiTests.ShouldCreateChildTestContainer;
var
  pc, c: IAllureTestResultContainer;
  fn: string;
  jv, v: TJSONValue;
begin
  Assert.IsNotNull(Allure.Lifecycle);
  pc := Allure.Lifecycle.CreateTestResultContainer;
  Assert.IsNotNull(pc);
  pc.Name := 'TAllureDelphiTests.ShouldCreateChildTestContainer.Parent';

  Allure.Lifecycle.StartTestContainer(pc);

  c := Allure.Lifecycle.CreateTestResultContainer;
  Assert.IsNotNull(c);
  c.Name := 'TAllureDelphiTests.ShouldCreateChildTestContainer.Child';

  Allure.Lifecycle.StartTestContainer(pc.UUID, c);
  Allure.Lifecycle.StopTestContainer(c.UUID);
  Allure.Lifecycle.WriteTestContainer(c.UUID);

  Allure.Lifecycle.StopTestContainer(pc.UUID);
  Allure.Lifecycle.WriteTestContainer(pc.UUID);

  fn := Allure.Lifecycle.ResultsDirectory + '\' + pc.UUID + '-container.json';
  if FileExists(fn) then begin
    jv := TJSONObject.ParseJSONValue(TFile.ReadAllText(fn), False, True);
    try
      Assert.IsNotNull(jv);
      v := jv.FindValue('uuid');
      Assert.IsNotNull(v);
      Assert.AreEqual(pc.UUID, v.Value, true);
      v := jv.FindValue('name');
      Assert.IsNotNull(v);
      Assert.AreEqual(pc.Name, v.Value, true);
      v := jv.FindValue('children[0]');
      Assert.IsNotNull(v);
      Assert.AreEqual(c.UUID, v.Value, true);
    finally
      jv.Free;
    end;
  end else
    Assert.Fail('Parent test result container not created');
  fn := Allure.Lifecycle.ResultsDirectory + '\' + c.UUID + '-container.json';
  if not FileExists(fn) then
    Assert.Fail('Child test result container not created');
end;

procedure TAllureDelphiTests.ShouldCreateTest;
var
  res: IAllureTestResult;
  fn: string;
  jv, v: TJSONValue;
begin
  Assert.IsNotNull(Allure.Lifecycle);
  res := Allure.Lifecycle.CreateTestResult;
  Assert.IsNotNull(res);
  res.Name := 'TAllureDelphiTests.ShouldCreateTest';
  res.HistoryID := THashMD5.GetHashString(res.Name);
  res.Status := asPassed;
  res.Links.AddNew.SetIssue('SC-4558');
  res.Labels.AddNew.SetPackage('AllureDelphiTest.exe');
  res.Labels.AddNew.SetSeverity(aslCritical);

  Allure.Lifecycle.ScheduleTestCase(res);
  Allure.Lifecycle.StartTestCase(res.UUID);
  Allure.Lifecycle.StopTestCase(res.UUID);
  Allure.Lifecycle.WriteTestCase(res.UUID);

  fn := Allure.Lifecycle.ResultsDirectory + '\' + res.UUID + '-result.json';
  if FileExists(fn) then begin
    jv := TJSONObject.ParseJSONValue(TFile.ReadAllText(fn), False, True);
    try
      Assert.IsNotNull(jv);
      v := jv.FindValue('uuid');
      Assert.IsNotNull(v);
      Assert.AreEqual(res.UUID, v.Value, true);
      v := jv.FindValue('name');
      Assert.IsNotNull(v);
      Assert.AreEqual(res.Name, v.Value, true);
      v := jv.FindValue('start');
      Assert.IsNotNull(v);
      v := jv.FindValue('stop');
      Assert.IsNotNull(v);
    finally
      jv.Free;
    end;
  end else
    Assert.Fail('Test result not created');
  res := nil;
end;

procedure TAllureDelphiTests.ShouldCreateTestContainer;
var
  c: IAllureTestResultContainer;
  fn: string;
  jv, v: TJSONValue;
begin
  Assert.IsNotNull(Allure.Lifecycle);
  c := Allure.Lifecycle.CreateTestResultContainer;
  Assert.IsNotNull(c);
  c.Name := 'TAllureDelphiTests.ShouldCreateTestContainer';
  c.Links.AddNew.SetIssue('SC-4559');

  Allure.Lifecycle.StartTestContainer(c);
  Allure.Lifecycle.StopTestContainer(c.UUID);
  Allure.Lifecycle.WriteTestContainer(c.UUID);

  fn := Allure.Lifecycle.ResultsDirectory + '\' + c.UUID + '-container.json';
  if FileExists(fn) then begin
    jv := TJSONObject.ParseJSONValue(TFile.ReadAllText(fn), False, True);
    try
      Assert.IsNotNull(jv);
      v := jv.FindValue('uuid');
      Assert.IsNotNull(v);
      Assert.AreEqual(c.UUID, v.Value, true);
      v := jv.FindValue('name');
      Assert.IsNotNull(v);
      Assert.AreEqual(c.Name, v.Value, true);
      v := jv.FindValue('start');
      Assert.IsNotNull(v);
      v := jv.FindValue('stop');
      Assert.IsNotNull(v);
    finally
      jv.Free;
    end;
  end else
    Assert.Fail('Test result container not created');
end;

procedure TAllureDelphiTests.ShouldCreateTestFixture;
var
  container: IAllureTestResultContainer;
  fixture: IAllureFixtureResult;
  fn, fixtureUuid, step0, step1, step2: string;
  jv, v: TJSONValue;
begin
  Assert.IsNotNull(Allure.Lifecycle);
  container := Allure.Lifecycle.CreateTestResultContainer;
  Assert.IsNotNull(container);
  container.Name := 'ShouldCreateTestFixture';

  Allure.Lifecycle.StartTestContainer(container);

  fixture := Allure.Lifecycle.CreateFixture;
  fixtureUuid := Copy(AnsiLowerCase(TGUID.NewGuid.ToString), 2, 36);
  fixture.Name := 'BeforeFixture-' + fixtureUuid;
  Allure.Lifecycle.StartBeforeFixture(container.UUID, fixtureUuid, fixture);

  step0 := MakeRandomStep(fixtureUuid);
  step1 := MakeRandomStep(fixtureUuid);

  Allure.Lifecycle.StopFixture(fixtureUuid);

  fixture := Allure.Lifecycle.CreateFixture;
  fixtureUuid := Copy(AnsiLowerCase(TGUID.NewGuid.ToString), 2, 36);
  fixture.Name := 'AfterFixture-' + fixtureUuid;
  Allure.Lifecycle.StartAfterFixture(container.UUID, fixtureUuid, fixture);

  step2 := MakeRandomStep(fixtureUuid);

  Allure.Lifecycle.StopFixture(fixtureUuid);


  Allure.Lifecycle.StopTestContainer(container.UUID);
  Allure.Lifecycle.WriteTestContainer(container.UUID);

  fn := Allure.Lifecycle.ResultsDirectory + '\' + container.UUID + '-container.json';
  if FileExists(fn) then begin
    jv := TJSONObject.ParseJSONValue(TFile.ReadAllText(fn), False, True);
    try
      Assert.IsNotNull(jv);
      v := jv.FindValue('uuid');
      Assert.IsNotNull(v);
      Assert.AreEqual(container.UUID, v.Value, true);
      v := jv.FindValue('name');
      Assert.IsNotNull(v);
      Assert.AreEqual(container.Name, v.Value, true);
      v := jv.FindValue('befores[0].steps[0].name');
      Assert.IsNotNull(v);
      Assert.AreEqual(step0, v.Value, true);
      v := jv.FindValue('befores[0].steps[1].name');
      Assert.IsNotNull(v);
      Assert.AreEqual(step1, v.Value, true);
      v := jv.FindValue('afters[0].steps[0].name');
      Assert.IsNotNull(v);
      Assert.AreEqual(step2, v.Value, true);
    finally
      jv.Free;
    end;
  end else
    Assert.Fail('Test result container not created');
end;

procedure TAllureDelphiTests.ShouldLifecycleExists;
var
  lf: IAllureLifecycle;
begin
  lf := Allure.Lifecycle;
  Assert.IsNotNull(lf);
end;

procedure TAllureDelphiTests.ShouldReadAllureConfig;
var
  lf: IAllureLifecycle;
  cf: IAllureConfiguration;
  fn: string;
begin
  cf := nil;
  lf := nil;
  try
    lf := Allure.Lifecycle;
    fn := ExtractFilePath(GetModuleName(HInstance)) + '..\..\..\Tests\TestData\allureConfig.json';
    if not FileExists(fn) then
      Assert.Fail('Missing config file: ' + fn);
    Assert.IsNotNull(lf);
    lf.AssignConfigFromFile(fn);
    cf := Allure.Lifecycle.AllureConfiguration;
    if cf<>nil then begin
      fn := ExtractFilePath(GetModuleName(HInstance))+'allure-results';
      Assert.AreEqual(fn, cf.Directory, true);
      if cf.Links<>nil then begin
        Assert.AreEqual(2, cf.Links.Count);
        Assert.AreEqual('https://example.org/{issue}', cf.Links.Value[0], true);
        Assert.AreEqual('https://example.org/{tms}', cf.Links.Value[1], true);
      end else
        Assert.Fail('Links are nil');
    end else
      Assert.Fail('Config is nil');
  finally
    cf := nil;
    lf := nil;
  end;
end;

procedure TAllureDelphiTests.ShouldUpdateContainer;
const
  cName: string = 'ShouldUpdateContainer';
var
  c: IAllureTestResultContainer;
  fn: string;
  jv, v: TJSONValue;
begin
  Assert.IsNotNull(Allure.Lifecycle);
  c := Allure.Lifecycle.CreateTestResultContainer;
  Assert.IsNotNull(c);

  Allure.Lifecycle.StartTestContainer(c);

  Allure.UpdateTestContainer(c.UUID,
    procedure(const Container: IAllureTestResultContainer)
    begin
      c.Name := cName;
    end
  );

  Allure.Lifecycle.StopTestContainer(c.UUID);
  Allure.Lifecycle.WriteTestContainer(c.UUID);

  fn := Allure.Lifecycle.ResultsDirectory + '\' + c.UUID + '-container.json';
  if FileExists(fn) then begin
    jv := TJSONObject.ParseJSONValue(TFile.ReadAllText(fn), False, True);
    try
      Assert.IsNotNull(jv);
      v := jv.FindValue('uuid');
      Assert.IsNotNull(v);
      Assert.AreEqual(c.UUID, v.Value, true);
      v := jv.FindValue('name');
      Assert.IsNotNull(v);
      Assert.AreEqual(cName, v.Value, true);
    finally
      jv.Free;
    end;
  end else
    Assert.Fail('Test result container not created');
end;

procedure TAllureDelphiTests.ShouldUpdateTest;
const
  TestDescription: string = 'Should call Lifecycle.UpdateTest() and update description and fullname of the test';
  TestFullName: string = 'TAllureDelphiTests.shouldUpdateTest';
var
  res: IAllureTestResult;
  step: IAllureStepResult;
  fn, stepUuid: string;
  jv, v: TJSONValue;
begin
  Assert.IsNotNull(Allure.Lifecycle);
  res := Allure.Lifecycle.CreateTestResult;
  Assert.IsNotNull(res);
  res.Name := 'TAllureDelphiTests.shouldUpdateTest';
  res.HistoryID := THashMD5.GetHashString(res.Name);
  res.Status := asFailed;
  res.Labels.AddNew.SetPackage('AllureDelphiTest.exe');
  res.Labels.AddNew.SetSeverity(aslNormal);

  Allure.Lifecycle.ScheduleTestCase(res);
  Allure.Lifecycle.StartTestCase(res.UUID);

  step := Allure.Lifecycle.CreateStepResult;
  stepUuid := Copy(AnsiLowerCase(TGUID.NewGuid.ToString), 2, 36);
  step.Name := 'Step-' + stepUuid;
  Allure.Lifecycle.StartStep(stepUuid, step);

  Allure.UpdateTestCase(res.UUID,
    procedure (const TestResult: IAllureTestResult)
    begin
      TestResult.Description := TestDescription;
    end
  );

  Allure.UpdateTestCase(
    procedure (const TestResult: IAllureTestResult)
    begin
      TestResult.FullName := TestFullName;
    end
  );

  Allure.Lifecycle.StopStep(stepUuid);

  Allure.Lifecycle.StopTestCase(res.UUID);
  Allure.Lifecycle.WriteTestCase(res.UUID);

  fn := Allure.Lifecycle.ResultsDirectory + '\' + res.UUID + '-result.json';
  if FileExists(fn) then begin
    jv := TJSONObject.ParseJSONValue(TFile.ReadAllText(fn), False, True);
    try
      Assert.IsNotNull(jv);
      v := jv.FindValue('uuid');
      Assert.IsNotNull(v);
      Assert.AreEqual(res.UUID, v.Value, true);
      v := jv.FindValue('description');
      Assert.IsNotNull(v);
      Assert.AreEqual(TestDescription, v.Value, true);
      v := jv.FindValue('fullName');
      Assert.IsNotNull(v);
      Assert.AreEqual(TestFullName, v.Value, true);
      v := jv.FindValue('steps[0].name');
      Assert.IsNotNull(v);
      Assert.AreEqual(step.Name, v.Value, true);
    finally
      jv.Free;
    end;
  end else
    Assert.Fail('Test result not created');
  step := nil;
  res := nil;
end;

initialization
  TDUnitX.RegisterTestFixture(TAllureDelphiTests);
end.
