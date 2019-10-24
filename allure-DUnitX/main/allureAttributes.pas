unit allureAttributes;

interface

uses
  System.Rtti,
  System.SysUtils,
  AllureDelphiInterface;

type

  StepAttribute = class(TCustomAttribute)
  private
    fName: string;
  public
    constructor Create; overload;
    constructor Create(const AName: string); overload;

    property Name: string read fName;
  end;

  TOneStringValueAttribute = class(TCustomAttribute)
  private
    fValue: string;
  public
    constructor Create(const AValue: string); overload;
    property Value: string read fValue;
  end;

  DescriptionAttribute = class(TOneStringValueAttribute);

  TAllureLinkAttribute = class(TCustomAttribute)
  protected
    fLinkType: string;
    fName: string;
    fUrl: string;
  public
    property Url: string read fUrl;
    property Name: string read fName;
    property LinkType: string read fLinkType;
  end;

  LinkAttribute = class(TAllureLinkAttribute)
  public
    constructor Create(const AUrl: string); overload;
    constructor Create(const AUrl, AName: string); overload;
    constructor Create(const AUrl, AName, AType: string); overload;
  end;

  IssueAttribute = class(TAllureLinkAttribute)
  public
    constructor Create(const AName: string); overload;
    constructor Create(const AName, AUrl: string); overload;
  end;

  TmsLinkAttribute = class(TAllureLinkAttribute)
  public
    constructor Create(const AName: string); overload;
    constructor Create(const AName, AUrl: string); overload;
  end;

  SeverityAttribute = class(TCustomAttribute)
  private
    fSeverity: TAllureSeverityLevel;
  public
    constructor Create(const ASeverity: TAllureSeverityLevel); overload;

    property Severity: TAllureSeverityLevel read fSeverity;
  end;

  EpicAttribute = class(TOneStringValueAttribute);
  FeatureAttribute = class(TOneStringValueAttribute);
  StoryAttribute = class(TOneStringValueAttribute);

  FlakyAttribute = class(TCustomAttribute);
  MutedAttribute = class(TCustomAttribute);
  KnownAttribute = class(TCustomAttribute);

implementation

{ StepAttribute }

constructor StepAttribute.Create;
begin
  inherited Create;
end;

constructor StepAttribute.Create(const AName: string);
begin
  inherited Create;
  fName := AName;
end;

{ TOneStringValueAttribute }

constructor TOneStringValueAttribute.Create(const AValue: string);
begin
  inherited Create;
  fValue := AValue;
end;

{ LinkAttribute }

constructor LinkAttribute.Create(const AUrl: string);
begin
  inherited Create;
  fUrl := AUrl;
end;

constructor LinkAttribute.Create(const AUrl, AName: string);
begin
  inherited Create;
  fUrl := AUrl;
  fName := AName;
end;

constructor LinkAttribute.Create(const AUrl, AName, AType: string);
begin
  inherited Create;
  fUrl := AUrl;
  fName := AName;
  fLinkType := AType;
end;

{ SeverityAttribute }

constructor SeverityAttribute.Create(const ASeverity: TAllureSeverityLevel);
begin
  inherited Create;
  fSeverity := ASeverity;
end;

{ IssueAttribute }

constructor IssueAttribute.Create(const AName, AUrl: string);
begin
  inherited Create;
  fUrl := AUrl;
  fLinkType := 'issue';
  fName := AName;
end;

constructor IssueAttribute.Create(const AName: string);
begin
  inherited Create;
  fName := AName;
  fLinkType := 'issue';
end;

{ TmsLinkAttribute }

constructor TmsLinkAttribute.Create(const AName, AUrl: string);
begin
  inherited Create;
  fUrl := AUrl;
  fLinkType := 'tms';
  fName := AName;
end;

constructor TmsLinkAttribute.Create(const AName: string);
begin
  inherited Create;
  fName := AName;
  fLinkType := 'tms';
end;

end.
