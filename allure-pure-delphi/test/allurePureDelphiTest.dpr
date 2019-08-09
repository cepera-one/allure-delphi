program allurePureDelphiTest;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  allureDelphiInterface in '..\..\allure-delphi\main\src\allureDelphiInterface.pas',
  allureDelphiHelper in '..\..\allure-delphi\main\src\allureDelphiHelper.pas',
  allureAttributes in '..\..\allure-delphi\main\src\allureAttributes.pas',
  pureTestFramework in '..\main\pureTestFramework.pas';

procedure Main;
begin
  Allure.Initialize;
  try

  finally
    Allure.Finalize;
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
