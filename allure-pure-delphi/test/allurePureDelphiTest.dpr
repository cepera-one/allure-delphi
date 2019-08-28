program allurePureDelphiTest;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  pureTestFramework in '..\main\pureTestFramework.pas',
  pureTestAssert in '..\main\pureTestAssert.pas',
  pureTestExceptions in '..\main\pureTestExceptions.pas',
  pureTestConsoleLogger in '..\main\pureTestConsoleLogger.pas',
  allureDelphiInterface in '..\..\allure-delphi\main\src\allureDelphiInterface.pas',
  allureDelphiHelper in '..\..\allure-delphi\main\src\allureDelphiHelper.pas',
  pureTestExample in 'pureTestExample.pas';

procedure Main;
var
  context: TPureTests;
begin
  context := TPureTests.Context;
  try
    context.Listeners.Add(TPureTestConsoleLogger.Create);
    ExitCode := context.RunAllTests;
    ReadLn;
  finally
    context.Finalize;
  end;
end;

begin
  try
    Main;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
