unit uAllureDUnitXLoggerTest;

interface

uses
  DUnitX.TestFramework, allureDelphiHelper, allureDelphiInterface,
  System.SysUtils, allureAttributes, Winapi.ShellApi;

type

  [TestFixture('Tests of the DUnitX logger to the allure format')]
  [Epic('AllureDUnitXLogger')]
  TAllureDUnitXLoggerTests = class(TObject)
  public
    constructor Create;
    destructor Destroy; override;

    [SetupFixture]
    procedure SetupFixture; virtual;

    [TearDownFixture]
    procedure TearDownFixture; virtual;

    [Setup]
    procedure Setup; virtual;
    [TearDown]
    procedure TearDown; virtual;

    [Step('It is a MakeStep(Index: Integer) function')]
    function MakeStep(Index: Integer): string; virtual;

    [Test]
    [Description('This test just should check success case')]
    procedure ShouldPass; virtual;

    [Test]
    [Issue('SC-5348')]
    [Issue('972', 'https://github.com/allure-framework/allure2/issues/972')]
    [Link('http://allure.qatools.ru', 'Allure overview')]
    [Flaky]
    [Muted]
    [Known]
    procedure ShouldFail; virtual;

    [Test]
    [Severity(aslCritical)]
    [Feature('Attributes testing')]
    [Story('Check for behaviors attributes')]
    procedure ShouldBeBroken; virtual;

    [Test]
    [Ignore('Reason is to test ignore case')]
    procedure ShouldBeIgnored; virtual;

    [Test]
    procedure ShouldMake3SubSteps; virtual;

    [Test]
    procedure ShouldAddAttachments; virtual;

    [Test]
    procedure ShouldMakeAllureServe; virtual;
  end;

implementation

{ TAllureDUnitXLoggerTests }

constructor TAllureDUnitXLoggerTests.Create;
begin
  inherited Create;
end;

destructor TAllureDUnitXLoggerTests.Destroy;
begin

  inherited;
end;

function TAllureDUnitXLoggerTests.MakeStep(Index: Integer): string;
var
  res: string;
begin
  res := '';
  Allure.RunStep('MakeStep',
    procedure
    begin
      if Index=1 then
        Assert.Fail('Incorrect index');
      res := 'res_' + IntToStr(Index);
    end
  );
  result := res;
end;

procedure TAllureDUnitXLoggerTests.Setup;
begin

end;

procedure TAllureDUnitXLoggerTests.SetupFixture;
begin
  //raise Exception.Create('check broken fixture case');
end;

procedure TAllureDUnitXLoggerTests.ShouldAddAttachments;
begin
  Allure.AddAttachment('.\..\..\..\TestData\WeldingBox.png');
  Allure.AddAttachmentText('Some text: ',
      'Just some long text' + #13#10 +
      'Just some long text' + #13#10 +
      'Just some long text' + #13#10 +
      'Just some long text' + #13#10 +
      'Just some long text' + #13#10 +
      'Just some long text' + #13#10 +
      'Just some long text' + #13#10 +
      'Just some long text' + #13#10 +
      'Just some long text' + #13#10 +
      'Just some long text' + #13#10 +
      'Just some long text' + #13#10 +
      'Just some long text' + #13#10 +
      'Just some long text' + #13#10 +
      'Just some long text' + #13#10 +
      'Just some long text' + #13#10
  );
  Allure.AddScreenshot('Desktop');
end;

procedure TAllureDUnitXLoggerTests.ShouldBeBroken;
begin
  raise Exception.Create('check broken case');
end;

procedure TAllureDUnitXLoggerTests.ShouldBeIgnored;
begin

end;

procedure TAllureDUnitXLoggerTests.ShouldFail;
begin
  Assert.Fail('check failed case');
end;

procedure TAllureDUnitXLoggerTests.ShouldMake3SubSteps;
begin
  MakeStep(0);
  MakeStep(1);
  MakeStep(2);
end;

procedure TAllureDUnitXLoggerTests.ShouldMakeAllureServe;
begin
  //Allure.GenerateReport;
end;

procedure TAllureDUnitXLoggerTests.ShouldPass;
begin
  // Do nothing
end;

procedure TAllureDUnitXLoggerTests.TearDown;
begin

end;

procedure TAllureDUnitXLoggerTests.TearDownFixture;
begin
  //raise Exception.Create('check broken TearDown fixture case');
end;

end.
