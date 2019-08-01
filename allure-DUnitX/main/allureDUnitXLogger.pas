unit allureDUnitXLogger;

interface

uses
  System.RTTI, DUnitX.TestFramework, allureDelphiInterface, allureDelphiHelper;

type

  TAllureDUnitXTestLogger = class(TInterfacedObject, ITestLogger)
  private

  public
    constructor Create;
    destructor Destroy; override;
  public

    ///	<summary>
    ///	  Called at the start of testing. The default console logger prints the
    ///	  DUnitX banner.
    ///	</summary>
    procedure OnTestingStarts(const threadId: TThreadID; testCount, testActiveCount: Cardinal);

    ///	<summary>
    ///	  //Called before a Fixture is run.
    ///	</summary>
    procedure OnStartTestFixture(const threadId: TThreadID; const fixture: ITestFixtureInfo);

    ///	<summary>
    ///	  //Called before a fixture Setup method is run
    ///	</summary>
    procedure OnSetupFixture(const threadId: TThreadID; const fixture: ITestFixtureInfo);

    ///	<summary>
    ///	  Called after a fixture setup method is run.
    ///	</summary>
    procedure OnEndSetupFixture(const threadId: TThreadID; const fixture: ITestFixtureInfo);

    ///	<summary>
    ///	  Called before a Test method is run.
    ///	</summary>
    procedure OnBeginTest(const threadId: TThreadID; const Test: ITestInfo);

    ///	<summary>
    ///	  Called before a test setup method is run.
    ///	</summary>
    procedure OnSetupTest(const threadId: TThreadID; const Test: ITestInfo);

    ///	<summary>
    ///	  Called after a test setup method is run.
    ///	</summary>
    procedure OnEndSetupTest(const threadId: TThreadID; const Test: ITestInfo);

    ///	<summary>
    ///	  Called before a Test method is run.
    ///	</summary>
    procedure OnExecuteTest(const threadId: TThreadID; const Test: ITestInfo);

    ///	<summary>
    ///	  Called when a test succeeds
    ///	</summary>
    procedure OnTestSuccess(const threadId: TThreadID; const Test: ITestResult);

    ///	<summary>
    ///	  Called when a test errors.
    ///	</summary>
    procedure OnTestError(const threadId: TThreadID; const Error: ITestError);

    ///	<summary>
    ///	  Called when a test fails.
    ///	</summary>
    procedure OnTestFailure(const threadId: TThreadID; const Failure: ITestError);

    /// <summary>
    ///   called when a test is ignored.
    /// </summary>
    procedure OnTestIgnored(const threadId: TThreadID; const AIgnored: ITestResult);

    /// <summary>
    ///   called when a test memory leaks.
    /// </summary>
    procedure OnTestMemoryLeak(const threadId: TThreadID; const Test: ITestResult);

    /// <summary>
    ///   allows tests to write to the log.
    /// </summary>
    procedure OnLog(const logType: TLogLevel; const msg: string);

    /// <summary>
    ///   called before a Test Teardown method is run.
    /// </summary>
    procedure OnTeardownTest(const threadId: TThreadID; const Test: ITestInfo);

    /// <summary>
    ///   called after a test teardown method is run.
    /// </summary>
    procedure OnEndTeardownTest(const threadId: TThreadID; const Test: ITestInfo);

    /// <summary>
    ///   called after a test method and teardown is run.
    /// </summary>
    procedure OnEndTest(const threadId: TThreadID; const Test: ITestResult);

    /// <summary>
    ///   called before a Fixture Teardown method is called.
    /// </summary>
    procedure OnTearDownFixture(const threadId: TThreadID; const fixture: ITestFixtureInfo);

    /// <summary>
    ///   called after a Fixture Teardown method is called.
    /// </summary>
    procedure OnEndTearDownFixture(const threadId: TThreadID; const fixture: ITestFixtureInfo);

    /// <summary>
    ///   called after a Fixture has run.
    /// </summary>
    procedure OnEndTestFixture(const threadId: TThreadID; const results: IFixtureResult);

    /// <summary>
    ///   called after all fixtures have run.
    /// </summary>
    procedure OnTestingEnds(const RunResults: IRunResults);
  end;

implementation

{ TAllureDUnitXTestLogger }

constructor TAllureDUnitXTestLogger.Create;
begin
  inherited Create;
  Allure.Initialize;
end;

destructor TAllureDUnitXTestLogger.Destroy;
begin
  Allure.Finalize;
  inherited;
end;

procedure TAllureDUnitXTestLogger.OnBeginTest(const threadId: TThreadID;
  const Test: ITestInfo);
begin

end;

procedure TAllureDUnitXTestLogger.OnEndSetupFixture(const threadId: TThreadID;
  const fixture: ITestFixtureInfo);
begin

end;

procedure TAllureDUnitXTestLogger.OnEndSetupTest(const threadId: TThreadID;
  const Test: ITestInfo);
begin

end;

procedure TAllureDUnitXTestLogger.OnEndTearDownFixture(
  const threadId: TThreadID; const fixture: ITestFixtureInfo);
begin

end;

procedure TAllureDUnitXTestLogger.OnEndTeardownTest(const threadId: TThreadID;
  const Test: ITestInfo);
begin

end;

procedure TAllureDUnitXTestLogger.OnEndTest(const threadId: TThreadID;
  const Test: ITestResult);
begin

end;

procedure TAllureDUnitXTestLogger.OnEndTestFixture(const threadId: TThreadID;
  const results: IFixtureResult);
begin

end;

procedure TAllureDUnitXTestLogger.OnExecuteTest(const threadId: TThreadID;
  const Test: ITestInfo);
begin

end;

procedure TAllureDUnitXTestLogger.OnLog(const logType: TLogLevel;
  const msg: string);
begin

end;

procedure TAllureDUnitXTestLogger.OnSetupFixture(const threadId: TThreadID;
  const fixture: ITestFixtureInfo);
begin

end;

procedure TAllureDUnitXTestLogger.OnSetupTest(const threadId: TThreadID;
  const Test: ITestInfo);
begin

end;

procedure TAllureDUnitXTestLogger.OnStartTestFixture(const threadId: TThreadID;
  const fixture: ITestFixtureInfo);
begin

end;

procedure TAllureDUnitXTestLogger.OnTearDownFixture(const threadId: TThreadID;
  const fixture: ITestFixtureInfo);
begin

end;

procedure TAllureDUnitXTestLogger.OnTeardownTest(const threadId: TThreadID;
  const Test: ITestInfo);
begin

end;

procedure TAllureDUnitXTestLogger.OnTestError(const threadId: TThreadID;
  const Error: ITestError);
begin

end;

procedure TAllureDUnitXTestLogger.OnTestFailure(const threadId: TThreadID;
  const Failure: ITestError);
begin

end;

procedure TAllureDUnitXTestLogger.OnTestIgnored(const threadId: TThreadID;
  const AIgnored: ITestResult);
begin

end;

procedure TAllureDUnitXTestLogger.OnTestingEnds(const RunResults: IRunResults);
begin

end;

procedure TAllureDUnitXTestLogger.OnTestingStarts(const threadId: TThreadID;
  testCount, testActiveCount: Cardinal);
begin

end;

procedure TAllureDUnitXTestLogger.OnTestMemoryLeak(const threadId: TThreadID;
  const Test: ITestResult);
begin

end;

procedure TAllureDUnitXTestLogger.OnTestSuccess(const threadId: TThreadID;
  const Test: ITestResult);
begin

end;

end.
