program AllureDelphiTest;

{$IFNDEF TESTINSIGHT}
{$APPTYPE CONSOLE}
{$ENDIF}
{$STRONGLINKTYPES ON}
uses
  System.SysUtils,
  {$IFDEF TESTINSIGHT}
  TestInsight.DUnitX,
  {$ENDIF }
  DUnitX.TestFramework in 'D:\Programs\Embarcadero\Studio\20.0\source\DunitX\DUnitX.TestFramework.pas',
  DUnitX.TestRunner in 'D:\Programs\Embarcadero\Studio\20.0\source\DunitX\DUnitX.TestRunner.pas',
  DUnitX.Test in 'D:\Programs\Embarcadero\Studio\20.0\source\DunitX\DUnitX.Test.pas',
  DUnitX.TestFixture in 'D:\Programs\Embarcadero\Studio\20.0\source\DunitX\DUnitX.TestFixture.pas',
  DUnitX.Assert in 'D:\Programs\Embarcadero\Studio\20.0\source\DunitX\DUnitX.Assert.pas',
  DUnitX.Assert.Ex in 'D:\Programs\Embarcadero\Studio\20.0\source\DunitX\DUnitX.Assert.Ex.pas',
  DUnitX.Attributes in 'D:\Programs\Embarcadero\Studio\20.0\source\DunitX\DUnitX.Attributes.pas',
  DUnitX.Generics in 'D:\Programs\Embarcadero\Studio\20.0\source\DunitX\DUnitX.Generics.pas',
  DUnitX.Extensibility in 'D:\Programs\Embarcadero\Studio\20.0\source\DunitX\DUnitX.Extensibility.pas',
  DUnitX.Filters in 'D:\Programs\Embarcadero\Studio\20.0\source\DunitX\DUnitX.Filters.pas',
  DUnitX.ComparableFormat in 'D:\Programs\Embarcadero\Studio\20.0\source\DunitX\DUnitX.ComparableFormat.pas',
  DUnitX.Exceptions in 'D:\Programs\Embarcadero\Studio\20.0\source\DunitX\DUnitX.Exceptions.pas',
  DUnitX.Types in 'D:\Programs\Embarcadero\Studio\20.0\source\DunitX\DUnitX.Types.pas',
  DUnitX.Loggers.Console,
  DUnitX.Loggers.Xml.NUnit,
  uAllureTests in 'uAllureTests.pas',
  allureDUnitXLogger in '..\allure-DUnitX\allureDUnitXLogger.pas',
  allureDelphiInterface in '..\allure-delphi\src\allureDelphiInterface.pas',
  allureDelphiHelper in '..\allure-delphi\src\allureDelphiHelper.pas';

var
  runner : ITestRunner;
  results : IRunResults;
  logger : ITestLogger;
  nunitLogger : ITestLogger;
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
    //Generate an NUnit compatible XML File
    nunitLogger := TDUnitXXMLNUnitFileLogger.Create(TDUnitX.Options.XMLOutputFile);
    runner.AddLogger(nunitLogger);
    runner.FailsOnNoAsserts := False; //When true, Assertions must be made during tests;

    //Run tests
    results := runner.Execute;
    if not results.AllPassed then
      System.ExitCode := EXIT_ERRORS;

    {$IFNDEF CI}
    //We don't want this happening when running under CI.
    if TDUnitX.Options.ExitBehavior = TDUnitXExitBehavior.Pause then
    begin
      System.Write('Done.. press <Enter> key to quit.');
      System.Readln;
    end;
    {$ENDIF}
  except
    on E: Exception do
      System.Writeln(E.ClassName, ': ', E.Message);
  end;
end.
