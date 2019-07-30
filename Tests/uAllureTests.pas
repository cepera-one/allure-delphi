unit uAllureTests;

interface

uses
  DUnitX.TestFramework, allureDelphiHelper, allureDelphiInterface,
  System.SysUtils, System.JSON, System.IOUtils;

type

  [TestFixture]
  TAllureDelphiTests = class(TObject)
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

procedure TAllureDelphiTests.Setup;
begin
end;

procedure TAllureDelphiTests.TearDown;
begin
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
  res.HistoryID := 'TAllureDelphiTests.ShouldCreateTest';
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

initialization
  TDUnitX.RegisterTestFixture(TAllureDelphiTests);
end.
