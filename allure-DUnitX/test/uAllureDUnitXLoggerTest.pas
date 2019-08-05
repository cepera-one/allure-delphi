unit uAllureDUnitXLoggerTest;

interface

uses
  DUnitX.TestFramework, allureDelphiHelper, allureDelphiInterface,
  System.SysUtils, allureAttributes, Winapi.ShellApi;

type

  [TestFixture]
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

    [Step]
    procedure MakeStep(Index: Integer); virtual;

    [Test]
    procedure ShouldPass; virtual;

    [Test]
    procedure ShouldFail; virtual;

    [Test]
    procedure ShouldBeBroken; virtual;

    [Test]
    procedure ShouldMake3SubSteps; virtual;

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

procedure TAllureDUnitXLoggerTests.MakeStep(Index: Integer);
begin
  if Index=1 then
    Assert.Fail('Incorrect index');
end;

procedure TAllureDUnitXLoggerTests.Setup;
begin

end;

procedure TAllureDUnitXLoggerTests.SetupFixture;
begin
  //raise Exception.Create('check broken fixture case');
end;

procedure TAllureDUnitXLoggerTests.ShouldBeBroken;
begin
  raise Exception.Create('check broken case');
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
var
  p: String;
begin
  p := 'serve "' + allure.Lifecycle.ResultsDirectory + '"';
  ShellExecute(0, 'open', 'allure', PChar(p), nil, 1);
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
