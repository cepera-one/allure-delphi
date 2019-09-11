program AllureDUnitXLoggerTest;

{$IFNDEF TESTINSIGHT}
{$APPTYPE CONSOLE}
{$ENDIF}{$STRONGLINKTYPES ON}
uses
  System.SysUtils,
  {$IFDEF TESTINSIGHT}
  TestInsight.DUnitX,
  {$ENDIF }
  DUnitX.Loggers.Console,
  DUnitX.Loggers.Xml.NUnit,
  DUnitX.TestFramework,
  uAllureDUnitXLoggerTest in 'uAllureDUnitXLoggerTest.pas',
  allureDUnitXLogger in '..\main\allureDUnitXLogger.pas',
  allureDelphiHelper in '..\..\allure-delphi\main\src\allureDelphiHelper.pas',
  allureDelphiInterface in '..\..\allure-delphi\main\src\allureDelphiInterface.pas',
  MethodsInterceptor in '..\main\MethodsInterceptor.pas',
  allureAttributes in '..\main\allureAttributes.pas';

var
  runner : ITestRunner;
  results : IRunResults;
  logger : ITestLogger;
  allureLogger: TDUnitXAllureBaseLogger;
begin
{$IFDEF TESTINSIGHT}
  TestInsight.DUnitX.RunRegisteredTests;
  exit;
{$ENDIF}
  try
    //Check command line options, will exit if invalid
    TDUnitX.CheckCommandLine;
    //Create the test runner
    runner := TDUnitX.CreateRunner;
    //Tell the runner to use RTTI to find Fixtures
    runner.UseRTTI := True;
    //tell the runner how we will log things
    //Log to the console window
    logger := TDUnitXConsoleLogger.Create(true);
    runner.AddLogger(logger);

    // Generate output in allure 2 (JSON) format
    allureLogger := TDUnitXAllureSimpleLogger.Create; //TDUnitXAllureRttiLogger.Create;
    runner.AddLogger(allureLogger);

    runner.FailsOnNoAsserts := False; //When true, Assertions must be made during tests;

    //Run tests
    results := runner.Execute;
    if not results.AllPassed then
      System.ExitCode := EXIT_ERRORS;

    Allure.GenerateReport;

    //We don't want this happening when running under CI.
    if TDUnitX.Options.ExitBehavior = TDUnitXExitBehavior.Pause then
    begin
      System.Write('Done.. press <Enter> key to quit.');
      System.Readln;
    end;
  except
    on E: Exception do
      System.Writeln(E.ClassName, ': ', E.Message);
  end;
end.
