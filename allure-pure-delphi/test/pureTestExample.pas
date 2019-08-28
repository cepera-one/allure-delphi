unit pureTestExample;

interface

uses
  pureTestFramework;

type
  TFixData = record
    A: Integer;
    B: String;
  end;
  TTest1Data = record
    C: Integer;
    D: String;
  end;

  procedure RunTests;

implementation

var
  context: TPureTests;
  fixture: TPureTestFixture<TFixData>;
  test1: TPureTestFixture<TFixData>.TPureTest<TTest1Data>;
  fixture2: TPureTestFixture;
  test2: TPureTestFixture.TPureTest;

procedure RunTests;
begin
  context := TPureTests.Context;
  fixture := context.BeginTestFixture<TFixData>('pureTestExample');
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
          test1.BeginStep('SetupTest1');
          Assert.Fail('Check fail case');

          test1.EndStep;
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
end;

initialization
  TPureTests.Context.RegTestProc(RunTests);
end.
