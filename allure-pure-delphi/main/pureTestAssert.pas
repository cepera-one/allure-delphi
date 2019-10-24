unit pureTestAssert;

interface

uses
  System.SysUtils, System.Classes, System.Math, System.Variants, System.StrUtils,
  pureTestExceptions;

type

  Assert = class
  private
    class function StreamsEqual(const stream1, stream2: TStream): boolean; static;
  public
    class procedure Pass(const message : string = '');
    class procedure Fail(const message : string = ''; const errorAddrs : pointer = nil);
    class procedure FailFmt(const message : string; const args: array of const; const errorAddrs : pointer = nil);

    class procedure NotImplemented;

    class procedure AreEqual(const expected : string; const actual : string; const ignoreCase : boolean; const message : string = '');overload;
    class procedure AreEqual(const expected : string; const actual : string; const message : string = '');overload;
    class procedure AreEqual(const expected, actual : Double; const tolerance : Double; const message : string = '');overload;
    class procedure AreEqual(const expected, actual : Double; const message : string = '');overload;
    class procedure AreEqual(const expected, actual : Extended; const tolerance : Extended; const message : string = '');overload;
    class procedure AreEqual(const expected, actual : Extended; const message : string = '');overload;
    class procedure AreEqual(const expected, actual : TClass; const message : string = '');overload;
    class procedure AreEqual(const expected, actual : TStream; const message : string = '');overload;
    class procedure AreEqual(const expected, actual : word; const message : string = '');overload;
    class procedure AreEqual(const expected, actual : Integer; const message : string = '');overload;
    class procedure AreEqual(const expected, actual : cardinal; const message : string = '');overload;
    class procedure AreEqual(const expected, actual : boolean; const message : string = '');overload;
    class procedure AreEqual(const expected, actual: TGUID; const message : string = '');overload;
    class procedure AreEqual(const expected, actual: TStrings; const ignoreLines: array of integer; const message : string = '');overload;
    class procedure AreEqual(const expected, actual: TStrings; const message : string = '');overload;
    class procedure AreEqualMemory(const expected : Pointer; const actual : Pointer; const size : Cardinal; const message : string = '');

    class procedure AreNotEqual(const expected : string; const actual : string; const ignoreCase : boolean; const message : string = '');overload;
    class procedure AreNotEqual(const expected : string; const actual : string; const message : string = '');overload;
    class procedure AreNotEqual(const expected, actual : Extended; const tolerance : Extended; const message : string = '');overload;
    class procedure AreNotEqual(const expected, actual : Extended; const message : string = '');overload;
    class procedure AreNotEqual(const expected, actual : Double; const tolerance : double; const message : string = '');overload;
    class procedure AreNotEqual(const expected, actual : Double; const message : string = '');overload;
    class procedure AreNotEqual(const expected, actual : TClass; const message : string = '');overload;
    class procedure AreNotEqual(const expected, actual : TStream; const message : string = '');overload;
    class procedure AreNotEqual(const expected, actual : Integer; const message : string = '');overload;
    class procedure AreNotEqual(const expected, actual : TGUID; const message : string = '');overload;
    class procedure AreNotEqualMemory(const expected : Pointer; const actual : Pointer; const size : Cardinal; const message : string = '');

    class procedure AreSame(const expected, actual : TObject; const message : string = '');overload;
    class procedure AreSame(const expected, actual : IInterface; const message : string = '');overload;
    class procedure AreNotSame(const expected, actual : TObject; const message : string = '');overload;
    class procedure AreNotSame(const expected, actual : IInterface; const message : string = '');overload;

    class procedure Implements(value : IInterface; const IID: TGUID; const message : string = '' );

    class procedure IsTrue(const condition : boolean; const message : string = '');
    class procedure IsFalse(const condition : boolean; const message : string = '');

    class procedure IsNull(const condition : TObject; const message : string = '');overload;
    class procedure IsNull(const condition : Pointer; const message : string = '');overload;
    class procedure IsNull(const condition : IInterface; const message : string = '');overload;
    class procedure IsNull(const condition : Variant; const message : string = '');overload;

    class procedure IsNotNull(const condition : TObject; const message : string = '');overload;
    class procedure IsNotNull(const condition : Pointer; const message : string = '');overload;
    class procedure IsNotNull(const condition : IInterface; const message : string = '');overload;
    class procedure IsNotNull(const condition : Variant; const message : string = '');overload;

    class procedure IsEmpty(const value : string; const message : string = '');overload;
    class procedure IsEmpty(const value : Variant; const message : string = '');overload;
    class procedure IsEmpty(const value : TStrings; const message : string = '');overload;
    class procedure IsEmpty(const value : TList; const message : string = '');overload;
    class procedure IsEmpty(const value : IInterfaceList; const message : string = '');overload;
    class procedure IsEmpty<T>(const value : IEnumerable<T>; const message : string = '');overload;

    class procedure IsNotEmpty(const value : string; const message : string = '');overload;
    class procedure IsNotEmpty(const value : Variant; const message : string = '');overload;
    class procedure IsNotEmpty(const value : TStrings; const message : string = '');overload;
    class procedure IsNotEmpty(const value : TList; const message : string = '');overload;
    class procedure IsNotEmpty(const value : IInterfaceList; const message : string = '');overload;
    class procedure IsNotEmpty<T>(const value : IEnumerable<T>; const message : string = '');overload;

    class procedure Contains(const theString : string; const subString : string; const ignoreCase : boolean; const message : string = ''); overload;
    class procedure Contains(const theString : string; const subString : string; const message : string = ''); overload;

    class procedure DoesNotContain(const theString : string; const subString : string; const ignoreCase : boolean; const message : string = ''); overload;
    class procedure DoesNotContain(const theString : string; const subString : string; const message : string = ''); overload;

    class procedure Contains(const theStrings : TStrings; const subString : string; const ignoreCase : boolean; const message : string = ''); overload;
    class procedure Contains(const theStrings : TStrings; const subString : string; const message : string = ''); overload;

    class procedure DoesNotContain(const theStrings : TStrings; const subString : string; const ignoreCase : boolean; const message : string = ''); overload;
    class procedure DoesNotContain(const theStrings : TStrings; const subString : string; const message : string = ''); overload;

    class procedure StartsWith(const subString : string; const theString : string; const ignoreCase : boolean; const message : string = ''); overload;
    class procedure StartsWith(const subString : string; const theString : string; const message : string = ''); overload;
    class procedure EndsWith(const subString : string; const theString : string; const ignoreCase : boolean; const message : string = ''); overload;
    class procedure EndsWith(const subString : string; const theString : string; const message : string = ''); overload;

    class procedure InheritsFrom(const descendant : TClass; const parent : TClass; const message : string = '');

    class procedure NoDiff(const expected, actual: string; const ignoreCase : boolean; const message : string = ''); overload;
    class procedure NoDiff(const expected, actual: string; const message : string = ''); overload;
  end;

resourcestring
  SNotImplemented = 'Not implemented';
  SUnexpectedErrorDbl = 'Expected %g but got %g %s';
  SUnexpectedErrorInt = 'Expected %d but got %d %s';
  SUnexpectedErrorStr = 'Expected %s but got %s %s';
  SUnexpectedErrorGUID = 'Expected %s but got %s %s';
  SNotEqualErrorStr = 'Expected %s is not equal to actual %s %s';
  SUnexpectedErrorStream = 'Streams are not equal %s';
  SNumberOfStringsNotEqual = 'Number of strings is not equal';
  SMemoryValuesNotEqual = 'Memory values are not equal. ';
  SEqualsErrorStr = '[%s] is equal to [%s] %s';
  SEqualsErrorExt = '%g equals actual %g %s';
  SEqualsErrorInt = 'Expected %d equals actual %d %s';
  SEqualsErrorStream = 'Streams are equal %s';
  SEqualsErrorGUID = 'Expected %s equals actual %s %s';
  SMemoryValuesEqual = 'Memory values are equal. ';
  SNotEqualErrorObj = 'Object [%s] Not Object [%s] %s';
  SNotEqualErrorIntf = 'references are Not the same. %s';
  SEqualsErrorObj = 'Object [%s] Equals Object [%s] %s';
  SEqualsErrorIntf = 'references are the same. %s';
  SIntfNotImplemented = 'value does not implement %s. %s';
  SIsTrueError = 'Condition is False when True expected. [%s]';
  SIsFalseError = 'Condition is True when False expected. %s';
  SObjNotNil = 'Object is not nil when nil expected. [%s]';
  SPointerNotNil = 'Pointer is not Nil when nil expected. [%s]';
  SIntfNotNil = 'Interface is not Nil when nil expected. [%s]';
  SVariantNotNull = 'Variant is Not Null when Null expected. [%s]';
  SIntfNil = 'Interface is Nil when not nil expected. %s';
  SPointerNil = 'Pointer is Nil when not Nil expected. %s';
  SObjNil = 'Object is Nil when Not Nil expected. %s';
  SVariantNull = 'Variant is Null when Not Null expcted. %s';
  SStrNotEmpty = 'String is Not empty. %s';
  SVarNotEmpty = 'Variant is Not empty. %s';
  SListNotEmpty = 'List is Not empty. %s';
  SListEmpty = 'List is Empty when Not empty expected. %s';
  SStrEmpty = 'String is Empty. %s';
  SVarEmpty = 'Variant is Empty. %s';
  SStrDoesNotContain = '[%s] does not contain [%s] %s';
  SStrDoesNotEndWith = '[%s] does not end with [%s] %s';
  SStrDoesNotMatch = '[%s] does not match [%s] %s';
  SStrCannotBeEmpty = 'subString cannot be empty';
  SStrDoesNotStartWith = '[%s] does Not Start with [%s] %s';
  SLengthOfStringsNotEqual = 'Length of strings is not equal';
  SDiffAtPosition = 'Difference at position %d';

implementation

{ Assert }

class procedure Assert.AreEqual(const expected, actual, tolerance: Extended;
  const message: string);
begin
  if not System.Math.SameValue(expected,actual,tolerance) then
    FailFmt(SUnexpectedErrorDbl ,[expected,actual,message], ReturnAddress);
end;

class procedure Assert.AreEqual(const expected, actual: Extended;
  const message: string);
begin
  AreEqual(expected, actual, Extended(0), message);
end;

class procedure Assert.AreEqual(const expected, actual: TClass;
  const message: string);
var
  msg : string;
begin
  if expected <> actual then
  begin
    msg := ' is not equal to ';
    if expected = nil then
      msg := 'nil' + msg
    else
      msg := expected.ClassName + msg;

    if actual = nil then
      msg := msg +  'nil'
    else
      msg := msg + actual.ClassName;

    if message <> '' then
      msg := msg + '. ' + message;

    Fail(msg, ReturnAddress);
  end;
end;

class procedure Assert.AreEqual(const expected, actual: Double;
  const message: string);
begin
  AreEqual(expected, actual, Double(0), message);
end;

class procedure Assert.AreEqual(const expected, actual: string;
  const ignoreCase: boolean; const message: string);
begin
  if ignoreCase then
  begin
    if not SameText(expected,actual) then
      FailFmt(SNotEqualErrorStr,[expected,actual,message], ReturnAddress);
  end
  else if not SameStr(expected,actual) then
    FailFmt(SNotEqualErrorStr,[expected,actual,message], ReturnAddress);
end;

class procedure Assert.AreEqual(const expected, actual, message: string);
begin
  Assert.AreEqual(expected, actual, false, message);
end;

class procedure Assert.AreEqual(const expected, actual, tolerance: Double;
  const message: string);
begin
  if not System.Math.SameValue(expected,actual,tolerance) then
    FailFmt(SUnexpectedErrorDbl ,[expected,actual,message], ReturnAddress);
end;

class procedure Assert.AreEqual(const expected, actual: TStream;
  const message: string);
begin
  if not StreamsEqual(expected, actual) then
    FailFmt(SUnexpectedErrorStream, [message], ReturnAddress);
end;

class procedure Assert.AreEqual(const expected, actual: TGUID;
  const message: string);
begin
  if not IsEqualGUID(expected, actual) then
    FailFmt(SUnexpectedErrorGUID, [GUIDToString(expected), GUIDToString(actual), message], ReturnAddress);
end;

class procedure Assert.AreEqual(const expected, actual: TStrings;
  const ignoreLines: array of integer; const message: string);

  function IsIgnoredLine(Line: Integer): Boolean;
  var
    i: Integer;
  begin
    for i := 0 to Length(ignoreLines)-1 do begin
      if Line=ignoreLines[i] then
        exit(true);
    end;
    result := false;
  end;

var
  index: Integer;
  lineNumber: integer;
begin
  IsTrue(expected <> actual, message);

  if (expected.Count <> actual.Count) then
    FailFmt(SNumberOfStringsNotEqual + ': ' + SUnexpectedErrorInt, [expected.Count, actual.Count, message], ReturnAddress);

  for index := 0 to expected.Count - 1 do begin
    lineNumber := index + 1;
    if not IsIgnoredLine(lineNumber) then
    begin
      if (expected[index] <> actual[index]) then begin
        NoDiff(expected[index], actual[index], Format('at line %d', [lineNumber]) + ' ' + message);
      end;
    end;
  end;
end;

class procedure Assert.AreEqual(const expected, actual: TStrings;
  const message: string);
begin
  AreEqual(expected, actual, [], message);
end;

class procedure Assert.AreEqual(const expected, actual: boolean;
  const message: string);
begin
  if expected <> actual then
    FailFmt(SUnexpectedErrorStr ,[BoolToStr(expected, true), BoolToStr(actual, true), message], ReturnAddress);
end;

class procedure Assert.AreEqual(const expected, actual: word;
  const message: string);
begin
  if expected <> actual then
    FailFmt(SUnexpectedErrorInt ,[expected, actual, message], ReturnAddress);
end;

class procedure Assert.AreEqual(const expected, actual: Integer;
  const message: string);
begin
  if expected <> actual then
    FailFmt(SUnexpectedErrorInt ,[expected, actual, message], ReturnAddress);
end;

class procedure Assert.AreEqual(const expected, actual: cardinal;
  const message: string);
begin
  if expected <> actual then
    FailFmt(SUnexpectedErrorInt ,[expected, actual, message], ReturnAddress);
end;

class procedure Assert.AreEqualMemory(const expected, actual: Pointer;
  const size: Cardinal; const message: string);
begin
  if not CompareMem(expected, actual, size) then
    Fail(SMemoryValuesNotEqual + message, ReturnAddress);
end;

class procedure Assert.AreNotEqual(const expected, actual: Double;
  const message: string);
begin
  Assert.AreNotEqual(expected,actual,Double(0),message);
end;

class procedure Assert.AreNotEqual(const expected, actual, tolerance: double;
  const message: string);
begin
  if System.Math.SameValue(expected, actual, tolerance) then
    FailFmt(SEqualsErrorExt ,[expected,actual,message], ReturnAddress);
end;

class procedure Assert.AreNotEqual(const expected, actual: TClass;
  const message: string);
var
  msg : string;
begin
  if expected = actual then
  begin
    msg := ' is equal to ';
    if expected = nil then
      msg := 'nil' + msg
    else
      msg := expected.ClassName + msg;

    if actual = nil then
      msg := msg +  'nil'
    else
      msg := msg + actual.ClassName;
    if message <> '' then
      msg := msg + '. ' + message;

    Fail(msg, ReturnAddress);
  end;
end;

class procedure Assert.AreNotEqual(const expected, actual: TStream;
  const message: string);
begin
  if StreamsEqual(expected, actual) then
    FailFmt(SEqualsErrorStream, [message], ReturnAddress);
end;

class procedure Assert.AreNotEqual(const expected, actual: string;
  const ignoreCase: boolean; const message: string);

  function AreNotEqualText(const expected, actual: string; const ignoreCase: boolean): boolean;
  begin
    if ignoreCase then
      Result := SameText(expected, actual)
    else
      Result := SameStr(expected, actual);
  end;

begin
  if AreNotEqualText(expected, actual, ignoreCase) then
    FailFmt(SEqualsErrorStr, [expected, actual, message], ReturnAddress);
end;

class procedure Assert.AreNotEqual(const expected, actual, message: string);
begin
  AreNotEqual(expected, actual, false, message);
end;

class procedure Assert.AreNotEqual(const expected, actual, tolerance: Extended;
  const message: string);
begin
  if System.Math.SameValue(expected, actual, tolerance) then
    FailFmt(SEqualsErrorExt ,[expected,actual,message], ReturnAddress);
end;

class procedure Assert.AreNotEqual(const expected, actual: Extended;
  const message: string);
begin
  Assert.AreNotEqual(expected,actual,Extended(0),message);
end;

class procedure Assert.AreNotEqual(const expected, actual: Integer;
  const message: string);
begin
  if expected = actual then
    FailFmt(SEqualsErrorInt ,[expected, actual, message], ReturnAddress);
end;

class procedure Assert.AreNotEqual(const expected, actual: TGUID;
  const message: string);
begin
  if IsEqualGUID(expected, actual) then
    FailFmt(SEqualsErrorGUID,[GUIDToString(expected), GUIDToString(actual), message], ReturnAddress);
end;

class procedure Assert.AreNotEqualMemory(const expected, actual: Pointer;
  const size: Cardinal; const message: string);
begin
  if CompareMem(expected,actual, size) then
    Fail(SMemoryValuesEqual + message, ReturnAddress);
end;

class procedure Assert.AreNotSame(const expected, actual: TObject;
  const message: string);
begin
  if expected.Equals(actual) then
    FailFmt(SEqualsErrorObj, [expected.ToString,actual.ToString,message], ReturnAddress);
end;

class procedure Assert.AreNotSame(const expected, actual: IInterface;
  const message: string);
begin
  if (expected as IInterface) = (actual as IInterface) then
    FailFmt(SEqualsErrorIntf,[message], ReturnAddress);
end;

class procedure Assert.AreSame(const expected, actual: IInterface;
  const message: string);
begin
  if (expected as IInterface) <> (actual as IInterface) then
    FailFmt(SNotEqualErrorIntf,[message], ReturnAddress);
end;

class procedure Assert.AreSame(const expected, actual: TObject;
  const message: string);
begin
  if not expected.Equals(actual) then
    FailFmt(SNotEqualErrorObj, [expected.ToString,actual.ToString,message], ReturnAddress);
end;

class procedure Assert.Contains(const theString, subString, message: string);
begin
  Contains(theString, subString, false, message);
end;

class procedure Assert.Contains(const theString, subString: string;
  const ignoreCase: boolean; const message: string);
begin
  if ignoreCase then
  begin
    if not System.StrUtils.ContainsText(theString,subString) then
      FailFmt(SStrDoesNotContain, [theString,subString,message], ReturnAddress);
  end
  else if not System.StrUtils.ContainsStr(theString,subString) then
    FailFmt(SStrDoesNotContain, [theString,subString,message], ReturnAddress);
end;

class procedure Assert.Contains(const theStrings: TStrings; const subString,
  message: string);
begin
  Contains(theStrings.Text, subString, message);
end;

class procedure Assert.Contains(const theStrings: TStrings;
  const subString: string; const ignoreCase: boolean; const message: string);
begin
  Contains(theStrings.Text, subString, ignoreCase, message);
end;

class procedure Assert.DoesNotContain(const theString, subString,
  message: string);
begin
  DoesNotContain(theString, subString, false, message);
end;

class procedure Assert.DoesNotContain(const theStrings: TStrings;
  const subString: string; const ignoreCase: boolean; const message: string);
begin
  DoesNotContain(theStrings.Text, subString, ignoreCase, message);
end;

class procedure Assert.DoesNotContain(const theString, subString: string;
  const ignoreCase: boolean; const message: string);
begin
  if ignoreCase then
  begin
    if System.StrUtils.ContainsText(theString, subString) then
      FailFmt(SStrDoesNotContain,[theString, subString, message], ReturnAddress);
  end
  else if System.StrUtils.ContainsStr(theString, subString) then
    FailFmt(SStrDoesNotContain,[theString, subString, message], ReturnAddress);
end;

class procedure Assert.DoesNotContain(const theStrings: TStrings;
  const subString, message: string);
begin
  DoesNotContain(theStrings.Text, subString, message);
end;

class procedure Assert.EndsWith(const subString, theString: string;
  const ignoreCase: boolean; const message: string);
begin
  if (subString = '') then
    FailFmt(SStrCannotBeEmpty, [], ReturnAddress);
  if ignoreCase then
  begin
    if not System.StrUtils.EndsText(subString,theString) then
      FailFmt(SStrDoesNotEndWith,[theString,subString,message], ReturnAddress);
  end
  else if not System.StrUtils.EndsStr(subString,theString) then
    FailFmt(SStrDoesNotEndWith, [theString,subString,message], ReturnAddress);
end;

class procedure Assert.EndsWith(const subString, theString, message: string);
begin
  Assert.EndsWith(subString, theString, false, message);
end;

class procedure Assert.Fail(const message: string; const errorAddrs: pointer);
begin
  if errorAddrs <> nil then
    raise EPureTestFailure.Create(message) at errorAddrs
  else
    raise EPureTestFailure.Create(message) at ReturnAddress;
end;

class procedure Assert.FailFmt(const message: string;
  const args: array of const; const errorAddrs: pointer);
begin
  Fail(Format(message, args), errorAddrs);
end;

class procedure Assert.Implements(value: IInterface; const IID: TGUID;
  const message: string);
var
  intf: IUnknown;
begin
  if not Supports(value, IID, intf) then
    FailFmt(SIntfNotImplemented, [GuidToString(IID), message],ReturnAddress);
end;

class procedure Assert.InheritsFrom(const descendant, parent: TClass;
  const message: string);
var
  msg : string;
begin
  if (descendant = nil) or (parent = nil) or (not descendant.InheritsFrom(parent)) then
  begin
    msg := ' does not inherit from ';
    if descendant = nil then
      msg := 'nil' + msg
    else
      msg := descendant.ClassName + msg;
    if parent = nil then
      msg := msg + 'nil'
    else
      msg := msg + parent.ClassName;
    msg := msg + '.';
    if True then
    if message <> '' then
      msg := msg + ' ' + message;

    Fail(msg, ReturnAddress);
  end;
end;

class procedure Assert.IsEmpty(const value: TList; const message: string);
begin
  if value.Count > 0 then
    FailFmt(SListNotEmpty,[message], ReturnAddress);
end;

class procedure Assert.IsEmpty(const value: IInterfaceList;
  const message: string);
begin
  if value.Count > 0 then
    FailFmt(SListNotEmpty,[message], ReturnAddress);
end;

class procedure Assert.IsEmpty(const value: TStrings; const message: string);
begin
  if value.Count > 0 then
    FailFmt(SListNotEmpty,[message], ReturnAddress);
end;

class procedure Assert.IsEmpty(const value: Variant; const message: string);
begin
  if VarIsEmpty(value) or VarIsNull(value) then
    FailFmt(SVarNotEmpty,[message], ReturnAddress);
end;

class procedure Assert.IsEmpty(const value, message: string);
begin
  if Length(value) > 0 then
    FailFmt(SStrNotEmpty,[message], ReturnAddress);
end;

class procedure Assert.IsEmpty<T>(const value: IEnumerable<T>;
  const message: string);
var
  o : T;
  count : integer;
begin
  count := 0;
  for o in value do begin
    Inc(count);
    break;
  end;
  if count > 0 then
    FailFmt(SListNotEmpty,[message], ReturnAddress);
end;

class procedure Assert.IsFalse(const condition: boolean; const message: string);
begin
  if condition then
    FailFmt(SIsFalseError,[message], ReturnAddress);
end;

class procedure Assert.IsNotEmpty(const value, message: string);
begin
  if value = '' then
    FailFmt(SStrEmpty,[message], ReturnAddress);
end;

class procedure Assert.IsNotEmpty(const value: IInterfaceList;
  const message: string);
begin
  if value.Count = 0 then
    FailFmt(SListEmpty, [message], ReturnAddress);
end;

class procedure Assert.IsNotEmpty(const value: TStrings; const message: string);
begin
  if value.Count = 0 then
    FailFmt(SListEmpty, [message], ReturnAddress);
end;

class procedure Assert.IsNotEmpty(const value: Variant; const message: string);
begin
  if VarIsEmpty(value) then
    FailFmt(SVarEmpty,[message], ReturnAddress);
end;

class procedure Assert.IsNotEmpty(const value: TList; const message: string);
begin
  if value.Count = 0 then
    FailFmt(SListEmpty, [message], ReturnAddress);
end;

class procedure Assert.IsNotEmpty<T>(const value: IEnumerable<T>;
  const message: string);
var
  x : T;
  count : integer;
begin
  count := 0;
  for x in value do begin
    Inc(count);
    break;
  end;

  if count = 0 then
    FailFmt(SListEmpty,[message], ReturnAddress);
end;

class procedure Assert.IsNotNull(const condition: Variant;
  const message: string);
begin
  if VarIsNull(condition) then
    FailFmt(SVariantNull,[message], ReturnAddress);
end;

class procedure Assert.IsNotNull(const condition: IInterface;
  const message: string);
begin
  if condition = nil then
    FailFmt(SIntfNil,[message], ReturnAddress);
end;

class procedure Assert.IsNotNull(const condition: TObject;
  const message: string);
begin
  if condition = nil then
    FailFmt(SObjNil,[message], ReturnAddress);
end;

class procedure Assert.IsNotNull(const condition: Pointer;
  const message: string);
begin
  if condition = nil then
    FailFmt(SPointerNil,[message], ReturnAddress);
end;

class procedure Assert.IsNull(const condition: TObject; const message: string);
begin
  if condition <> nil then
    FailFmt(SObjNotNil,[message], ReturnAddress);
end;

class procedure Assert.IsNull(const condition: Pointer; const message: string);
begin
  if condition <> nil then
    FailFmt(SPointerNotNil,[message], ReturnAddress);
end;

class procedure Assert.IsNull(const condition: Variant; const message: string);
begin
  if not VarIsNull(condition) then
    FailFmt(SVariantNotNull,[message], ReturnAddress);
end;

class procedure Assert.IsNull(const condition: IInterface;
  const message: string);
begin
  if condition <> nil then
    FailFmt(SIntfNotNil,[message], ReturnAddress);
end;

class procedure Assert.IsTrue(const condition: boolean; const message: string);
begin
  if not condition then
    FailFmt(SIsTrueError,[message], ReturnAddress);
end;

class procedure Assert.NoDiff(const expected, actual, message: string);
begin
  NoDiff(expected, actual, false, message);
end;

class procedure Assert.NoDiff(const expected, actual: string;
  const ignoreCase: boolean; const message: string);
const
  DIFF_LENGTH = 10;

  function EncodeWhitespace(const s: string): string;
  const
    DELIMITER: array[boolean] of string = (#39, '');
  var
    index: integer;
    lastWhitespace: boolean;
  begin
    Result := '';
    lastWhitespace := true;
    for index := 1 to Length(S) do
    begin
      if S[index] < #32 then
      begin
        Result := Result + DELIMITER[lastWhitespace] + '#' + IntToStr(Ord(S[index]));
        lastWhitespace := true;
      end
      else begin
        Result := Result + DELIMITER[not lastWhitespace] + S[index];
        lastWhitespace := false;
      end;
    end;
    Result := Result + DELIMITER[lastWhitespace];
  end;

var
  lenExp, lenAct: integer;
  strExp, strAct: string;
  position: Integer;
begin
  lenExp := Length(expected);
  lenAct := Length(actual);

  if lenExp <> lenAct then
    FailFmt(SLengthOfStringsNotEqual + ': ' + SUnexpectedErrorInt, [lenExp, lenAct, message])
  else begin
    if ignoreCase then
    begin
      strExp := UpperCase(expected);
      strAct := UpperCase(actual);
    end
    else begin
      strExp := expected;
      strAct := actual;
    end;
    for position := 1 to lenExp do
    begin
      if (position <= lenAct) and (strExp[position] <> strAct[position]) then
        FailFmt(SDiffAtPosition + ': ' + SStrDoesNotMatch, [position,
          EncodeWhitespace(Copy(expected, position, DIFF_LENGTH)),
          EncodeWhitespace(Copy(actual, position, DIFF_LENGTH)), message]);
    end;
  end;
end;

class procedure Assert.NotImplemented;
begin
  Assert.Fail(SNotImplemented);
end;

class procedure Assert.Pass(const message: string);
begin
  raise EPureTestPass.Create(message);
end;

class procedure Assert.StartsWith(const subString, theString, message: string);
begin
  Assert.StartsWith(subString, theString, false, message);
end;

class procedure Assert.StartsWith(const subString, theString: string;
  const ignoreCase: boolean; const message: string);
begin
  if subString = '' then
    FailFmt(SStrCannotBeEmpty, [], ReturnAddress);

  if ignoreCase then
  begin
    if not System.StrUtils.StartsText(subString,theString) then
      FailFmt(SStrDoesNotStartWith, [theString,subString,message], ReturnAddress);
  end
  else if not System.StrUtils.StartsStr(subString,theString) then
    FailFmt(SStrDoesNotStartWith, [theString,subString,message], ReturnAddress);
end;

class function Assert.StreamsEqual(const stream1, stream2: TStream): boolean;
const
  BlockSize = 4096;
var
  Buffer1: array[0..BlockSize - 1] of byte;
  Buffer2: array[0..BlockSize - 1] of byte;
  BufferLen: integer;
begin
  Result := False;

  if stream1.Size = stream2.Size then
  begin
    stream1.Position := 0;
    stream2.Position := 0;

    while stream1.Position < stream1.Size do
    begin
      BufferLen := stream1.Read(Buffer1, BlockSize);
      stream2.Read(Buffer2, BlockSize);
      if not CompareMem(@Buffer1, @Buffer2, BufferLen) then
        exit;
    end;

    Result := True;
  end;
end;

end.
