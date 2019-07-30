unit allureCommon;

interface

uses
  System.SysUtils, Winapi.Windows;

const
  ALLURE_CONFIG_ENV_VARIABLE: string = 'ALLURE_CONFIG';
  CONFIG_FILENAME: string = 'allureConfig.json';
  DEFAULT_RESULTS_FOLDER: string = 'allure-results';
  TEST_RESULT_FILE_SUFFIX: string = '-result.json';
  TEST_RESULT_CONTAINER_FILE_SUFFIX: string = '-container.json';
  TEST_RUN_FILE_SUFFIX: string = '-testrun.json';
  ATTACHMENT_FILE_SUFFIX: string = '-attachment';

type

  EAllureException = class(Exception);

  TAllureInterfacedObject = class;

  IAllureInterfacedObject = interface
  ['{9066CED7-6E6C-4F8E-ABB6-84AA8238A38D}']
    function GetSelfObject: TAllureInterfacedObject;
  end;

  TAllureInterfacedObject = class(TInterfacedObject, IInterface, IAllureInterfacedObject)
  private
    procedure SetSelfIncrement(const Value: boolean);
  protected
    fSelfIncrement: boolean;
    function IInterface._AddRef = _AddRef;
    function IInterface._Release = _Release;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
    function GetSelfObject: TAllureInterfacedObject;
  public
    constructor Create;
    procedure Free;

    procedure BeforeDestruction; override;

    property SelfIncrement: boolean read fSelfIncrement write SetSelfIncrement;

    function AddRef: Integer;
    function Release: Integer;

    class function ToClass<T: TInterfacedObject>(const intf: IUnknown): T; static;
  end;

  procedure FreeAndNilAllureObject(var obj: TObject);

implementation

procedure FreeAndNilAllureObject(var obj: TObject);
begin
  if obj<>nil then begin
    if obj is TAllureInterfacedObject then
      TAllureInterfacedObject(obj).Free
    else
      obj.Free;
    obj := nil;
  end;
end;

{ TAllureInterfacedObject }

class function TAllureInterfacedObject.ToClass<T>(const intf: IUnknown): T;
var
  io: IAllureInterfacedObject;
begin
  if (intf<>nil) and (intf.QueryInterface(IAllureInterfacedObject, io)=0) and
     (io.GetSelfObject is T)
  then begin
    result := T(io.GetSelfObject);
  end else
    result := nil;
end;

function TAllureInterfacedObject.AddRef: Integer;
begin
  result := _AddRef;
end;

procedure TAllureInterfacedObject.BeforeDestruction;
begin
  if fSelfIncrement then
    InterlockedDecrement(fRefCount);  // Remove my own reference
  inherited;
end;

constructor TAllureInterfacedObject.Create;
begin
 inherited;
  fSelfIncrement := true;
  _AddRef;  // Add my own reference, to exclude auto destroying.
end;

procedure TAllureInterfacedObject.Free;
begin
  if self<>nil then begin
    SelfIncrement := False;
    if fRefCount=0 then
      Destroy;
  end;
end;

function TAllureInterfacedObject.GetSelfObject: TAllureInterfacedObject;
begin
  result := self;
end;

function TAllureInterfacedObject.Release: Integer;
begin
  result := _Release;
end;

procedure TAllureInterfacedObject.SetSelfIncrement(const Value: boolean);
begin
  if fSelfIncrement=Value then exit;
  fSelfIncrement := Value;
  if fSelfIncrement then
    _AddRef                           // Add my own reference
  else
    InterlockedDecrement(fRefCount);  // Remove my own reference
end;

function TAllureInterfacedObject._AddRef: Integer;
begin
  Result := inherited _AddRef;
end;

function TAllureInterfacedObject._Release: Integer;
begin
  Result := inherited _Release;
end;

end.
