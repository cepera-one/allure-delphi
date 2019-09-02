unit pureTestExample;

interface

uses
  System.SysUtils, pureTestFramework;

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
  fixture := context.BeginTestFixture<TFixData>('Fixture1', 'Full form of pure delphi tests');
  fixture.Setup(
    procedure
    begin
      Fixture.Data.A := 10;
      Fixture.Data.B := 'sample';
    end
  );
  try
    test1 := fixture.BeginTest<TTest1Data>('Test1', 'Should be ok');
    try
      test1.Severity := pslCritical;
      test1.AddIssue('DEVSUP-762');
      test1.AddIssue('SRS-5692', 'https://jira.sprutcam.com/browse/SRS-5692');
      test1.AddEpic('Pure');
      test1.AddFeature('Test');
      test1.AddStory('Framework');
      test1.AddTestClass('NoClass');
      test1.AddTestMethod('Method1');
      test1.Execute(
        procedure
        begin
        end
      );
    finally
      test1.EndTest;
    end;
    test1 := fixture.BeginTest<TTest1Data>('Test2', 'Should fail');
    try
      test1.AddEpic('Pure');
      test1.AddFeature('Test');
      test1.AddStory('Framework');
      test1.AddTestClass('NoClass');
      test1.AddTestMethod('Method2');
      test1.Execute(
        procedure
        begin
          test1.BeginStep('Step1', 'Should be ok');
          test1.EndStep;

          test1.BeginStep('Step2', 'Should fail');
          Assert.Fail('Check fail case');
          test1.EndStep;
        end
      );
    finally
      test1.EndTest;
    end;
    test1 := fixture.BeginTest<TTest1Data>('Test3', 'Should be broken');
    try
      test1.AddEpic('Pure');
      test1.AddFeature('Test');
      test1.AddStory('Framework');
      test1.Execute(
        procedure
        begin
          raise Exception.Create('Some unexpected exception');
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

  fixture2 := context.BeginTestFixture('Fixture2', 'Short form of pure delphi tests');
  try
    test2 := fixture2.BeginTest('SimpleTest1', 'Just another test case');
    try
      test2.AddEpic('Pure');
      test2.AddFeature('Test');
      test2.AddStory('Framework');
      test2.MarkFlaky;
//      test2.MarkMuted;
//      test2.MarkKnown;
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
