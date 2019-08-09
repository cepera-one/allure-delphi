unit pureTestFramework;

interface

type
  TPureTestsContext = class;

  TPureTestFixture<TFix> = class
  public type
    TPureFixtureProc = reference to procedure;//(Fixture: TPureTestFixture<TFix>);

    TPureTest<T> = class
    private
      fPrevTest: TPureTest<T>;
    public type
      TPureTestExecuteProc = reference to procedure;//(Test: TPureTest<T>);

      TPureTestStep = class
      public
        constructor Create(ATest: TPureTest<T>; const Name: string; const Description: string = '');


        procedure EndStep;
      end;

    public
      TestData: T;
    public
      constructor Create(AFixture: TPureTestFixture<TFix>; const Name: string; const Description: string = '');
      destructor Destroy; override;

      procedure Execute(TestBodyProc: TPureTestExecuteProc);

      function BeginStep(const Name: string; const Description: string = ''): TPureTestStep;

      procedure EndStep;

      procedure EndTest;
    end;

    TPureTest = class(TPureTest<Pointer>);

  public
    FixtureData: TFix;
    fFirstTest, fLastTest: Pointer;//TPureTest<T>;
  public
    constructor Create(AContext: TPureTestsContext; const Name: string; const Description: string = '');
    destructor Destroy; override;

    procedure Setup(SetupProc: TPureFixtureProc);
    procedure TearDown(TearDownProc: TPureFixtureProc);

    function BeginTest<T>(const Name: string; const Description: string = ''): TPureTest<T>; overload;
    function BeginTest(const Name: string; const Description: string = ''): TPureTest; overload;

    procedure EndTest;
    procedure EndTestFixture;
  end;

  TPureTestFixture = class(TPureTestFixture<Pointer>);

  TPureTestsContext = class
  public
    constructor Create;
    destructor Destroy; override;

    function BeginTestFixture<TFix>(const Name: string; const Description: string = ''): TPureTestFixture<TFix>; overload;
    function BeginTestFixture(const Name: string; const Description: string = ''): TPureTestFixture; overload;
  end;

implementation

procedure MakeTest;
type
  TFixData = record
    A: Integer;
    B: String;
  end;
  TTest1Data = record
    C: Integer;
    D: String;
  end;
var
  context: TPureTestsContext;
  fixture: TPureTestFixture<TFixData>;
  test1: TPureTestFixture<TFixData>.TPureTest<TTest1Data>;
  fixture2: TPureTestFixture;
  test2: TPureTestFixture.TPureTest;
begin
  context := TPureTestsContext.Create;
  try
    fixture := context.BeginTestFixture<TFixData>('SampleFixture');
    try
      fixture.Setup(
        procedure
        begin
          Fixture.FixtureData.A := 10;
          Fixture.FixtureData.B := 'sample';
        end
      );
      try
        test1 := fixture.BeginTest<TTest1Data>('Test1');
        try
          test1.Execute(
            procedure
            begin
              with test1.BeginStep('SetupTest1') do begin


                EndStep;
              end;
            end
          );
        finally
          test1.EndTest;
        end;
      finally
        fixture.TearDown(
          procedure
          begin
            Fixture.FixtureData.A := 0;
            Fixture.FixtureData.B := '';
          end
        );
      end;
    finally
      fixture.Free;
    end;

    fixture2 := context.BeginTestFixture('Fixture2');
    try
      fixture2.BeginTest('Test2');
      try
        test2.Execute(
          procedure
          begin
            test2.BeginStep('Step1');
            try

            finally
            end;
            test2.EndStep;
          end
        );
      finally
        fixture2.EndTest;
      end;
    finally
      fixture2.EndTestFixture;
    end;
  finally
    context.Free;
  end;
end;

{ TPureTestsContext }

function TPureTestsContext.BeginTestFixture(const Name,
  Description: string): TPureTestFixture;
begin

end;

function TPureTestsContext.BeginTestFixture<TFix>(const Name,
  Description: string): TPureTestFixture<TFix>;
begin

end;

constructor TPureTestsContext.Create;
begin

end;

destructor TPureTestsContext.Destroy;
begin

  inherited;
end;

{ TPureTestFixture<TFix> }

function TPureTestFixture<TFix>.BeginTest(const Name,
  Description: string): TPureTest;
begin

end;

function TPureTestFixture<TFix>.BeginTest<T>(const Name,
  Description: string): TPureTest<T>;
begin

end;

constructor TPureTestFixture<TFix>.Create(AContext: TPureTestsContext;
  const Name, Description: string);
begin

end;

destructor TPureTestFixture<TFix>.Destroy;
begin

  inherited;
end;

procedure TPureTestFixture<TFix>.EndTest;
begin

end;

procedure TPureTestFixture<TFix>.EndTestFixture;
begin

end;

procedure TPureTestFixture<TFix>.Setup(SetupProc: TPureFixtureProc);
begin

end;

procedure TPureTestFixture<TFix>.TearDown(TearDownProc: TPureFixtureProc);
begin

end;

{ TPureTestFixture<TFix>.TPureTest<T> }

function TPureTestFixture<TFix>.TPureTest<T>.BeginStep(const Name,
  Description: string): TPureTestStep;
begin

end;

constructor TPureTestFixture<TFix>.TPureTest<T>.Create(
  AFixture: TPureTestFixture<TFix>; const Name, Description: string);
begin

end;

destructor TPureTestFixture<TFix>.TPureTest<T>.Destroy;
begin

  inherited;
end;

procedure TPureTestFixture<TFix>.TPureTest<T>.EndStep;
begin

end;

procedure TPureTestFixture<TFix>.TPureTest<T>.EndTest;
begin

end;

procedure TPureTestFixture<TFix>.TPureTest<T>.Execute(
  TestBodyProc: TPureTestExecuteProc);
begin

end;

{ TPureTestFixture<TFix>.TPureTest<T>.TPureTestStep }

constructor TPureTestFixture<TFix>.TPureTest<T>.TPureTestStep.Create(
  ATest: TPureTest<T>; const Name, Description: string);
begin

end;

procedure TPureTestFixture<TFix>.TPureTest<T>.TPureTestStep.EndStep;
begin

end;

end.
