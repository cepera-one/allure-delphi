unit DUnitXMockHelper;

interface

uses
  System.SysUtils,
  System.Rtti,
  Delphi.Mocks,
  DunitX.TestFramework;

type

  // Wrapper for Delphi.Mocks.TMock<T> to produce DUnitX.Exceptions.ETestFailure
  // instead of Delphi.Mocks.EMockVerificationException
  TDxMock<T> = record
  private
    fMock: TMock<T>;
  public
    property Mock: TMock<T> read fMock;
  public
    class operator Implicit(const Value: TDxMock<T>): T;
    class function Create(const AAutoMock: IAutoMock; const ACreateObjectFunc: TFunc<T>): TDxMock<T>; overload; static;

    function Setup : IMockSetup<T>; overload;
    function Setup<I : IInterface> : IMockSetup<I>; overload;

    //Verify that our expectations were met.
    procedure Verify(const message : string = ''); overload;
    procedure Verify<I : IInterface>(const message : string = ''); overload;
    procedure VerifyAll(const message : string = '');

    function CheckExpectations: string;
    procedure Implement<I : IInterface>; overload;
    function Instance : T; overload;
    function Instance<I : IInterface> : I; overload;
    function InstanceAsValue : TValue; overload;
    function InstanceAsValue<I : IInterface> : TValue; overload;

    class function Create: TDxMock<T>; overload; static;
    class function Create(const ACreateObjectFunc: TFunc<T>): TDxMock<T>; overload; static;

    //Explicit cleanup. Not sure if we really need this.
    procedure Free;
  end;

implementation

{ TDxMock<T> }

function TDxMock<T>.CheckExpectations: string;
begin
  result := fMock.CheckExpectations;
end;

class function TDxMock<T>.Create(const AAutoMock: IAutoMock;
  const ACreateObjectFunc: TFunc<T>): TDxMock<T>;
begin
  result.fMock := TMock<T>.Create(AAutoMock, ACreateObjectFunc);
end;

class function TDxMock<T>.Create: TDxMock<T>;
begin
  result.fMock := TMock<T>.Create;
end;

class function TDxMock<T>.Create(const ACreateObjectFunc: TFunc<T>): TDxMock<T>;
begin
  result.fMock := TMock<T>.Create(ACreateObjectFunc);
end;

procedure TDxMock<T>.Free;
begin
  fMock.Free;
end;

procedure TDxMock<T>.Implement<I>;
begin
  fMock.Implement<I>;
end;

class operator TDxMock<T>.Implicit(const Value: TDxMock<T>): T;
begin
  result := Value.Mock;
end;

function TDxMock<T>.Instance: T;
begin
  result := fMock.Instance;
end;

function TDxMock<T>.Instance<I>: I;
begin
  result := fMock.Instance<I>;
end;

function TDxMock<T>.InstanceAsValue: TValue;
begin
  result := fMock.InstanceAsValue;
end;

function TDxMock<T>.InstanceAsValue<I>: TValue;
begin
  result := fMock.InstanceAsValue<I>;
end;

function TDxMock<T>.Setup: IMockSetup<T>;
begin
  result := fMock.Setup;
end;

function TDxMock<T>.Setup<I>: IMockSetup<I>;
begin
  result := fMock.Setup<I>;
end;

procedure TDxMock<T>.Verify(const message: string);
begin
  try
    fMock.Verify(message);
  except
    on E: EMockVerificationException do begin
      Assert.Fail(E.Message, E.StackInfo);
    end;
    else begin
      raise;
    end;
  end;
end;

procedure TDxMock<T>.Verify<I>(const message: string);
begin
  try
    fMock.Verify<I>(message);
  except
    on E: EMockVerificationException do begin
      Assert.Fail(E.Message, E.StackInfo);
    end;
    else begin
      raise;
    end;
  end;
end;

procedure TDxMock<T>.VerifyAll(const message: string);
begin
  try
    fMock.VerifyAll(message);
  except
    on E: EMockVerificationException do begin
      Assert.Fail(E.Message, E.StackInfo);
    end;
    else begin
      raise;
    end;
  end;
end;

end.
