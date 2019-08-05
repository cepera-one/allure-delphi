unit uAllureDUnitXLoggerTest;

interface

uses
  DUnitX.TestFramework, allureDelphiHelper, allureDelphiInterface,
  System.SysUtils;

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
    procedure MakeStep; virtual;

    [Test]
    procedure ShouldLifecycleExists; virtual;
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

procedure TAllureDUnitXLoggerTests.MakeStep;
begin

end;

procedure TAllureDUnitXLoggerTests.Setup;
begin

end;

procedure TAllureDUnitXLoggerTests.SetupFixture;
begin
  //raise Exception.Create('check broken fixture case');
end;

procedure TAllureDUnitXLoggerTests.ShouldLifecycleExists;
begin
  MakeStep;
  //raise Exception.Create('check broken case');
  //Assert.Fail('check failed case');
end;

procedure TAllureDUnitXLoggerTests.TearDown;
begin

end;

procedure TAllureDUnitXLoggerTests.TearDownFixture;
begin

end;

end.
