unit MethodsInterceptor;

interface

uses
  System.RTTI, System.SysUtils, System.Generics.Collections;

type

  TMethodsInterceptor = class(TObject)
  private
    fInterceptors: TDictionary<string, TVirtualMethodInterceptor>;
    FOnBefore: TInterceptBeforeNotify;
    FOnException: TInterceptExceptionNotify;
    FOnAfter: TInterceptAfterNotify;
    fLock: TObject;

    procedure Lock;
    procedure Unlock;

    procedure Clear;
    function GetInterceptor(AClass: TClass): TVirtualMethodInterceptor;
  public
    constructor Create;
    destructor Destroy; override;

    property OnBefore: TInterceptBeforeNotify read FOnBefore write FOnBefore;
    property OnAfter: TInterceptAfterNotify read FOnAfter write FOnAfter;
    property OnException: TInterceptExceptionNotify read FOnException write FOnException;

    procedure Proxify(AInstance: TObject);
    procedure Unproxify(AInstance: TObject);
  end;


implementation

{ TMethodsInterceptor }

procedure TMethodsInterceptor.Clear;
var
  ic: TVirtualMethodInterceptor;
begin
  Lock;
  try
    for ic in fInterceptors.Values do
      ic.Free;
    fInterceptors.Clear;
  finally
    Unlock;
  end;
end;

constructor TMethodsInterceptor.Create;
begin
  inherited Create;
  fLock := TObject.Create;
  fInterceptors := TDictionary<string, TVirtualMethodInterceptor>.Create;
end;

destructor TMethodsInterceptor.Destroy;
begin
  Clear;
  fInterceptors.Free;
  fLock.Free;
  inherited;
end;

function TMethodsInterceptor.GetInterceptor(
  AClass: TClass): TVirtualMethodInterceptor;
begin
  result := nil;
  Lock;
  try
    if not fInterceptors.TryGetValue(AClass.ClassName, result) then begin
      result := TVirtualMethodInterceptor.Create(AClass);
      result.OnBefore := self.OnBefore;
      result.OnAfter := self.OnAfter;
      result.OnException := self.OnException;
      fInterceptors.Add(AClass.ClassName, result);
    end;
  finally
    Unlock;
  end;
end;

procedure TMethodsInterceptor.Lock;
begin
  TMonitor.Enter(fLock);
end;

procedure TMethodsInterceptor.Proxify(AInstance: TObject);
var
  ic: TVirtualMethodInterceptor;
begin
  if AInstance=nil then exit;
  ic := GetInterceptor(AInstance.ClassType);
  ic.Proxify(AInstance);
end;

procedure TMethodsInterceptor.Unlock;
begin
  TMonitor.Exit(fLock);
end;

procedure TMethodsInterceptor.Unproxify(AInstance: TObject);
var
  ic: TVirtualMethodInterceptor;
begin
  if AInstance=nil then exit;
  ic := GetInterceptor(AInstance.ClassType);
  ic.Unproxify(AInstance);
end;

end.
