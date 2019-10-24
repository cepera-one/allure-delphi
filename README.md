# allure-delphi
Allure integrations for Delphi test frameworks.
See the information about Allure on the official page http://allure.qatools.ru/
Compiled with Delphi 10.2 and 10.3.
Contains several parts:
- allure-delphi - the common sources of the AllureDelphi.dll that can be simply loaded to any project. Just include allureDelphiHelper.pas to the uses section of your project.
- allure-DUnitX - DUnitX.ITestLogger implementation to generate test reports in Allure 2 (JSON) format
