unit allureConfig;

interface

uses
  System.SysUtils, Winapi.Windows, allureDelphiInterface, allureCommon,
  System.JSON, System.IOUtils, System.Generics.Collections, allureModel;

type

  TAllureConfiguration = class(TAllureInterfacedObject, IAllureConfiguration)
  private
    fJSON: TAllureString;
    fTitle: TAllureString;
    fDirectory: TAllureString;
    fLinks: TAllureStringSet;
    function GetJsonConfiguration: TAllureString;
  public
    constructor Create;
    destructor Destroy; override;

    function GetTitle: TAllureString; safecall;
    procedure SetTitle(const Value: TAllureString); safecall;
    function GetDirectory: TAllureString; safecall;
    procedure SetDirectory(const Value: TAllureString); safecall;
    function GetLinks: IAllureStringSet; safecall;

    procedure ReadFromJson(const json: TAllureString; const CurrentDir: TAllureString = ''); safecall;
    property JsonConfiguration: TAllureString read GetJsonConfiguration;

    property Title: TAllureString read GetTitle write SetTitle;
    property Directory: TAllureString read GetDirectory write SetDirectory;
    property Links: IAllureStringSet read GetLinks;
  end;

implementation

{ TAllureConfiguration }

constructor TAllureConfiguration.Create;
begin
  inherited Create;
  fLinks := TAllureStringSet.Create;
  fDirectory := 'allure-results';
  fTitle := '';
end;

destructor TAllureConfiguration.Destroy;
begin
  fLinks.Free;
  inherited;
end;

function TAllureConfiguration.GetDirectory: TAllureString;
begin
  result := fDirectory;
end;

function TAllureConfiguration.GetJsonConfiguration: TAllureString;
begin
  result := fJSON;
end;

function TAllureConfiguration.GetLinks: IAllureStringSet;
begin
  result := fLinks;
end;

function TAllureConfiguration.GetTitle: TAllureString;
begin
  result := fTitle;
end;

procedure TAllureConfiguration.ReadFromJson(const json: TAllureString; const CurrentDir: TAllureString = '');
//..\..\..\Tests\TestData\allureConfig.json
//{
//  "allure": {
//    "title": "5994A3F7-AF84-46AD-9393-000BB45553CC",
//    "directory": "allure-results",
//    "links": [
//      "https://example.org/{issue}",
//      "https://example.org/{tms}"
//    ]
//  },
//  "specflow": {
//    "stepArguments": {
//      "convertToParameters": "true",
//      "paramNameRegex": "^a.*",
//      "paramValueRegex": "^v.*"
//    },
//    "grouping": {
//      "suites": {
//        "parentSuite": "^(ui|api)",
//        "suite": "^(core|sales|aux)",
//        "subSuite": "^(create|update|delete)"
//      },
//      "behaviors": {
//        "epic": "^epic:?(.+)",
//        "story": "^story:?(.+)"
//      },
//      "packages": {
//        "package": "^package:?(.+)",
//        "testClass": "^class:?(.+)",
//        "testMethod": "^method:?(.+)"
//      }
//    },
//    "labels": {
//      "owner": "^owner:?(.+)",
//      "severity": "^(normal|blocker|critical|minor|trivial)"
//    },
//    "links": {
//      "link": "^link:(.+)",
//      "issue": "^\\d+",
//      "tms": "^tms:(\\d+)"
//    }
//  }
//}
var
  jv, av: TJSONValue;
  ls: TJSONArray;
  i: Integer;
  v: String;
begin
  try
    fJSON := json;
    if json='' then exit;
    jv := TJSONObject.ParseJSONValue(json, False{, True});
    if jv=nil then exit;
    try
      if jv.TryGetValue('allure', av) then begin
        if av.TryGetValue<string>('title', v) then
          fTitle := v;
        if av.TryGetValue<string>('directory', v) then begin
          fDirectory := v;
          if ExtractFileDrive(fDirectory)='' then begin
            if CurrentDir<>'' then
              fDirectory := IncludeTrailingPathDelimiter(CurrentDir) + fDirectory
            else
              fDirectory := TPath.GetFullPath(fDirectory);
          end;
        end;
        if av.TryGetValue<TJSONArray>('links', ls) then begin
          for i := 0 to ls.Count-1 do begin
            fLinks.Add(ls.Items[i].Value);
          end;
        end;
      end;
    finally
      jv.Free;
    end;
  except
  end;
end;

procedure TAllureConfiguration.SetDirectory(const Value: TAllureString);
begin
  fDirectory := Value;
end;

procedure TAllureConfiguration.SetTitle(const Value: TAllureString);
begin
  fTitle := Value;
end;

end.
