unit pureTestExceptions;

interface

uses
  System.SysUtils;

type

  EPureTestException = class(Exception);
  EPureTestAbort = class(EPureTestException);
  EPureTestFailure = class(EPureTestAbort);
  EPureTestPass = class(EPureTestAbort);

implementation

end.
