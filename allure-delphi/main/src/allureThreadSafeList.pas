unit allureThreadSafeList;

interface

uses
  System.SysUtils, System.Generics.Defaults, System.Generics.Collections,
  allureCommon, System.Classes, Winapi.Windows;

type

  TAllureThreadSafeList<T> = class(TList<T>)
  private
    fLock: TObject;
  public
    constructor Create; overload;
    constructor Create(const AComparer: IComparer<T>); overload;
    destructor Destroy; override;

    procedure Lock; inline;
    procedure Unlock; inline;

    procedure Clear; virtual;

    procedure Add(const Item: T); virtual;
    procedure Remove(const Item: T); virtual;
  end;

  TAllureThreadSafeObjectList<T: TAllureInterfacedObject> = class(TAllureThreadSafeList<T>)
  public
    destructor Destroy; override;

    procedure Clear; override;

    procedure Add(const Item: T); override;
    procedure Remove(const Item: T); override;
  end;

  TAllureThreadLocalStringList = class(TAllureInterfacedObject)
  public type
    TListOfStrings = TList<string>;
  private type
    TThreadRec = record
      ThreadID: TThreadID;
      List: TListOfStrings;
    end;
  var
    fThreads: TArray<TThreadRec>;
    fLock: TObject;
    procedure ClearAllThreads;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Lock; inline;
    procedure Unlock; inline;
    function List: TListOfStrings;

    procedure Push(const Value: string);
    function Pop: string;

    function Peek: string;
    function Root: string;

    procedure Clear;
  end;

  TAllureThreadSafeDictionary = class(TDictionary<string,TAllureInterfacedObject>)
  private
    fLock: TObject;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ClearObjects;

    procedure Lock; inline;
    procedure Unlock; inline;

    procedure AddObject(const ID: string; Obj: TAllureInterfacedObject); overload;
    procedure AddObject(const ID: string; Obj: IUnknown); overload;
    procedure RemoveObject(const ID: string);
    function GetObject(const ID: string): TAllureInterfacedObject;
    function Get<T: TAllureInterfacedObject>(const ID: string): T;
  end;

implementation

{ TAllureThreadSafeList<T> }

procedure TAllureThreadSafeList<T>.Add(const Item: T);
begin
  Lock;
  try
    inherited Add(Item);
  finally
    Unlock;
  end;
end;

procedure TAllureThreadSafeList<T>.Clear;
begin
  Lock;
  try
    inherited Clear;
  finally
    Unlock;
  end;
end;

constructor TAllureThreadSafeList<T>.Create(const AComparer: IComparer<T>);
begin
  inherited Create(AComparer);
  fLock := TObject.Create;
end;

constructor TAllureThreadSafeList<T>.Create;
begin
  inherited;
  fLock := TObject.Create;
end;

destructor TAllureThreadSafeList<T>.Destroy;
begin
  fLock.Free;
  inherited;
end;

procedure TAllureThreadSafeList<T>.Lock;
begin
  TMonitor.Enter(fLock);
end;

procedure TAllureThreadSafeList<T>.Remove(const Item: T);
var
  i: Integer;
begin
  Lock;
  try
    i := IndexOf(Item);
    if i>=0 then
      inherited Delete(i);
  finally
    Unlock;
  end;
end;

procedure TAllureThreadSafeList<T>.Unlock;
begin
  TMonitor.Exit(fLock);
end;

{ TAllureThreadSafeDictionary }

procedure TAllureThreadSafeDictionary.AddObject(const ID: string;
  Obj: TAllureInterfacedObject);
begin
  Lock;
  try
    if Obj=nil then exit;
    Add(ID, Obj);
    Obj.AddRef;
  finally
    Unlock;
  end;
end;

procedure TAllureThreadSafeDictionary.AddObject(const ID: string;
  Obj: IInterface);
var
  ao: IAllureInterfacedObject;
begin
  if (Obj<>nil) and (Obj.QueryInterface(IAllureInterfacedObject, ao)=0) then
    AddObject(ID, ao.GetSelfObject);
end;

procedure TAllureThreadSafeDictionary.ClearObjects;
var
  obj: TAllureInterfacedObject;
begin
  Lock;
  try
    for obj in self.Values do begin
      if (obj<>nil) and (obj.RefCount>1) then
        obj.Release;
      obj.Free;
    end;
    Clear;
  finally
    Unlock;
  end;
end;

constructor TAllureThreadSafeDictionary.Create;
begin
  inherited Create(TIStringComparer.Ordinal);
  fLock := TObject.Create;
end;

destructor TAllureThreadSafeDictionary.Destroy;
begin
  ClearObjects;
  fLock.Free;
  inherited;
end;

function TAllureThreadSafeDictionary.GetObject(
  const ID: string): TAllureInterfacedObject;
begin
  Lock;
  try
    if not TryGetValue(ID, result) then
      result := nil;
  finally
    Unlock;
  end;
end;

function TAllureThreadSafeDictionary.Get<T>(const ID: string): T;
var
  res: TAllureInterfacedObject;
begin
  res := GetObject(ID);
  if (res<>nil) and (res is T) then
    result := T(res)
  else
    result := nil;
end;

procedure TAllureThreadSafeDictionary.Lock;
begin
  TMonitor.Enter(fLock);
end;

procedure TAllureThreadSafeDictionary.RemoveObject(const ID: string);
var
  p: TPair<string, TAllureInterfacedObject>;
begin
  Lock;
  try
    p := ExtractPair(ID);
    if p.Value<>nil then
      p.Value.Release;
  finally
    Unlock;
  end;
end;

procedure TAllureThreadSafeDictionary.Unlock;
begin
  TMonitor.Exit(fLock);
end;

{ TAllureThreadLocalStringList }

procedure TAllureThreadLocalStringList.Clear;
begin
  List.Clear;
end;

procedure TAllureThreadLocalStringList.ClearAllThreads;
var
  i: Integer;
begin
  Lock;
  try
    for i := 0 to High(fThreads) do begin
      fThreads[i].List.Free;
    end;
    fThreads := nil;
  finally
    Unlock;
  end;
end;

constructor TAllureThreadLocalStringList.Create;
begin
  inherited Create;
  fLock := TObject.Create;
end;

destructor TAllureThreadLocalStringList.Destroy;
begin
  ClearAllThreads;
  fLock.Free;
  inherited;
end;

function TAllureThreadLocalStringList.List: TListOfStrings;
var
  i: Integer;
  ctid: TThreadID;
  tr: TThreadRec;
begin
  result := nil;
  Lock;
  try
    ctid := GetCurrentThreadId;
    for i := 0 to High(fThreads) do begin
      tr := fThreads[i];
      if tr.ThreadID=ctid then begin
        result := tr.List;
        break;
      end;
    end;
    if result=nil then begin
      tr.ThreadID := ctid;
      tr.List := TListOfStrings.Create(TIStringComparer.Ordinal);
      i := Length(fThreads);
      SetLength(fThreads, i+1);
      fThreads[i] := tr;
      result := tr.List;
    end;
  finally
    Unlock;
  end;
end;

procedure TAllureThreadLocalStringList.Lock;
begin
  TMonitor.Enter(fLock);
end;

function TAllureThreadLocalStringList.Peek: string;
var
  l: TListOfStrings;
begin
  l := List;
  if l.Count>0 then
    result := l.Items[l.Count-1]
  else
    result := '';
end;

function TAllureThreadLocalStringList.Pop: string;
var
  l: TListOfStrings;
begin
  l := List;
  if l.Count>0 then
    result := l.ExtractAt(l.Count-1)
  else
    result := '';
end;

procedure TAllureThreadLocalStringList.Push(const Value: string);
begin
  List.Add(Value);
end;

function TAllureThreadLocalStringList.Root: string;
var
  l: TListOfStrings;
begin
  l := List;
  if l.Count>0 then
    result := l.Items[0]
  else
    result := '';
end;

procedure TAllureThreadLocalStringList.Unlock;
begin
  TMonitor.Exit(fLock);
end;

{ TAllureThreadSafeObjectList<T> }

procedure TAllureThreadSafeObjectList<T>.Add(const Item: T);
begin
  Lock;
  try
    if Item<>nil then begin
      Item.SelfIncrement := true;
      inherited Add(Item);
    end;
  finally
    Unlock;
  end;
end;

procedure TAllureThreadSafeObjectList<T>.Clear;
var
  i: Integer;
  obj: TAllureInterfacedObject;
begin
  Lock;
  try
    for i := 0 to Count-1 do begin
      obj := self.Items[i];
      obj.Free;
    end;
    inherited Clear;
  finally
    Unlock;
  end;
end;

destructor TAllureThreadSafeObjectList<T>.Destroy;
begin
  Clear;
  inherited;
end;

procedure TAllureThreadSafeObjectList<T>.Remove(const Item: T);
begin
  Lock;
  try
    if Item<>nil then begin
      inherited Remove(Item);
      Item.SelfIncrement := false;
    end;
  finally
    Unlock;
  end;
end;

end.
