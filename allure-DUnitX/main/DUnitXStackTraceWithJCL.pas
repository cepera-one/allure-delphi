unit DUnitXStackTraceWithJCL;

interface

uses
  System.SysUtils,
  System.Classes,
  JclDebug,
  DUnitX.TestFramework;

type
  TJCLToDUnitXStackTraceProvider = class(TInterfacedObject,IStacktraceProvider)
  protected
    function GetStackTrace(const ex: Exception; const exAddressAddress: Pointer): string;
    function PointerToLocationInfo(const Addrs: Pointer): string;
    function PointerToAddressInfo(Addrs: Pointer): string;
  end;

implementation

uses
  DUnitX.IoC;

{ TJCLToDUnitXStackTraceProvider }

function TJCLToDUnitXStackTraceProvider.GetStackTrace(const ex: Exception; const exAddressAddress: Pointer): string;
var
  traceList: TStrings;
begin
  result := ex.StackTrace;
  if result<>'' then exit;
  traceList := TStringList.Create;
  try
    JclDebug.JclLastExceptStackListToStrings(traceList, true);
    Result := traceList.Text;
  finally
    traceList.Free;
  end;
end;

function TJCLToDUnitXStackTraceProvider.PointerToAddressInfo(Addrs: Pointer): string;
var
  _file,
  _module,
  _proc: string;
  _line: integer;
begin
  Result := '';
  JclDebug.MapOfAddr(Addrs, _file, _module, _proc, _line);
  Result := Format('%s$%p', [_proc, Addrs]);
end;

//Borrowed from DUnit.
function TJCLToDUnitXStackTraceProvider.PointerToLocationInfo(const Addrs: Pointer): string;
var
  _file,
  _module,
  _proc: string;
  _line: integer;
begin
  Result := '';
  JclDebug.MapOfAddr(Addrs, _file, _module, _proc, _line);

  if _file <> '' then
    Result   := Format('%s:%d', [_file, _line])
  else
    Result   := _module;
end;

initialization
  TDUnitXIoC.DefaultContainer.RegisterType<IStacktraceProvider,TJCLToDUnitXStackTraceProvider>(true);

end.
