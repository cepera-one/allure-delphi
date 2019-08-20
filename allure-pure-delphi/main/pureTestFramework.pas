unit pureTestFramework;

interface

type
  TPureTestsContext = class;

  IPureTestsListener = interface
  ['{1475065F-D02F-48BA-8E1E-DEBEFB090652}']
  end;

  TPureTestFixture<TFix> = class
  public type
    TPureFixtureProc = reference to procedure;//(Fixture: TPureTestFixture<TFix>);

    TPureTest<T> = class
    public type
      TPureTestExecuteProc = reference to procedure;//(Test: TPureTest<T>);

      TPureTestStep = class
      public
        Name: string;
        Description: string;
        Test: TPureTest<T>;
      public
        constructor Create(ATest: TPureTest<T>; const AName: string; const ADescription: string = '');


        procedure EndStep;
      end;

      TSteps = TArray<TPureTestStep>;
    private
      fSteps: TSteps;

      procedure PushStep(AStep: TPureTestStep);
      function PopStep: TPureTestStep;
      function PeekStep: TPureTestStep;
    public
      Name: string;
      Description: string;
      Data: T;
      Fixture: TPureTestFixture<TFix>;
    public
      constructor Create(AFixture: TPureTestFixture<TFix>; const AName: string; const ADescription: string = '');

      procedure Execute(TestBodyProc: TPureTestExecuteProc);

      function BeginStep(const Name: string; const Description: string = ''): TPureTestStep;

      procedure EndStep;

      destructor EndTest;
    end;

    TPureTest = TPureTest<Pointer>;

  public
    Name: string;
    Description: string;
    Data: TFix;
    Context: TPureTestsContext;
  public
    constructor Create(AContext: TPureTestsContext; const AName: string; const ADescription: string = '');

    procedure Setup(SetupProc: TPureFixtureProc);
    procedure TearDown(TearDownProc: TPureFixtureProc);

    function BeginTest<T>(const Name: string; const Description: string = ''): TPureTest<T>; overload;
    function BeginTest(const Name: string; const Description: string = ''): TPureTest; overload;

    destructor EndTestFixture; overload;
    destructor EndTestFixture(TearDownProc: TPureFixtureProc); overload;
  end;

  TPureTestFixture = TPureTestFixture<Pointer>;

  TTestProcedure = reference to procedure;

  TPureTestsContext = class
  private
    fListener: IPureTestsListener;
  public
    constructor Create;
    destructor Destroy; override;

    procedure AddListener(const AListener: IPureTestsListener);

    class procedure RegTestProc(AProc: TTestProcedure); static;

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
    fixture.Setup(
      procedure
      begin
        Fixture.Data.A := 10;
        Fixture.Data.B := 'sample';
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
      fixture.EndTestFixture(
        procedure
        begin
          Fixture.Data.A := 0;
          Fixture.Data.B := '';
        end
      );
    end;

    fixture2 := context.BeginTestFixture('Fixture2');
    try
      test2 := fixture2.BeginTest('Test2');
      try
        test2.Execute(
          procedure
          begin
            test2.BeginStep('Step1');
            try

            finally
              test2.EndStep;
            end;
          end
        );
      finally
        test2.EndTest;
      end;
    finally
      fixture2.EndTestFixture;
    end;
  finally
    context.Free;
  end;
end;

{ TPureTestsContext }

procedure TPureTestsContext.AddListener(const AListener: IPureTestsListener);
begin

end;

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

class procedure TPureTestsContext.RegTestProc(AProc: TTestProcedure);
begin

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
  const AName, ADescription: string);
begin

end;

destructor TPureTestFixture<TFix>.EndTestFixture(TearDownProc: TPureFixtureProc);
begin

end;

destructor TPureTestFixture<TFix>.EndTestFixture;
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
  AFixture: TPureTestFixture<TFix>; const AName, ADescription: string);
begin

end;

procedure TPureTestFixture<TFix>.TPureTest<T>.EndStep;
begin

end;

destructor TPureTestFixture<TFix>.TPureTest<T>.EndTest;
begin

end;

procedure TPureTestFixture<TFix>.TPureTest<T>.Execute(
  TestBodyProc: TPureTestExecuteProc);
begin

end;

function TPureTestFixture<TFix>.TPureTest<T>.PeekStep: TPureTestStep;
begin

end;

function TPureTestFixture<TFix>.TPureTest<T>.PopStep: TPureTestStep;
begin

end;

procedure TPureTestFixture<TFix>.TPureTest<T>.PushStep(AStep: TPureTestStep);
begin

end;

{ TPureTestFixture<TFix>.TPureTest<T>.TPureTestStep }

constructor TPureTestFixture<TFix>.TPureTest<T>.TPureTestStep.Create(
  ATest: TPureTest<T>; const AName, ADescription: string);
begin

end;

procedure TPureTestFixture<TFix>.TPureTest<T>.TPureTestStep.EndStep;
begin

end;

initialization
  MakeTest;
end.
