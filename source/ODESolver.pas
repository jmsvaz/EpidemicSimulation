unit ODESolver;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type

  TDataArray = array of Double;
  TDataMatrix = array of array of Double;

  TInitEvent = procedure (const t: Double; var Y0: TDataArray) of object;
  TCalculateEvent = procedure (const t: Double; const Y: TDataArray; var dYdT: TDataArray) of object;
  TStepEvent = procedure (const t: Double; const Y: TDataArray; const dYdT: TDataArray)  of object;

  { TRK4 }

  TRK4 = class
    private
      Running: Boolean;
      fDimension: Integer;
      fStepSize: Double;
      fTi: Double;
      fTf: Double;
      fOnInit: TInitEvent;
      fOnCalculate: TCalculateEvent;
      fOnStep: TStepEvent;
      procedure RaiseExceptionIfRunning;
      procedure SetOnInit(AValue: TInitEvent);
      procedure SetOnCalculate(AValue: TCalculateEvent);
      procedure SetOnStep(AValue: TStepEvent);
      procedure SetStepSize(AValue: Double);
      procedure SetTf(AValue: Double);
      procedure SetTi(AValue: Double);
    protected
      procedure DoOnInit(const t: Double; var Y0: TDataArray);
      procedure DoOnCalculate(const t: Double; const Y: TDataArray; var dYdT: TDataArray);
      procedure DoOnStep(const t: Double; const Y: TDataArray; const dYdT: TDataArray);
    public
      constructor Create(ADimension: Integer);
      procedure Execute;
      property Ti: Double read fTi write SetTi; // Initial time
      property Tf: Double read fTf write SetTf; // Final time
      property StepSize: Double read fStepSize write SetStepSize;
      property Dimension: Integer read fDimension; // number of equations
      property OnCalculate: TCalculateEvent read fOnCalculate write SetOnCalculate;  // calculate derivatives y = x'
      property OnInit: TInitEvent read fOnInit write SetOnInit; // setup initial value
      property OnStep: TStepEvent read fOnStep write SetOnStep;
    end;


implementation

uses AppStrings;

{ TRK4 }

constructor TRK4.Create(ADimension: Integer);
begin
  fDimension:= ADimension;
  fStepSize:=0.001;
  fTi:= 0;
  fTf:= 0;
  Running:= False;
end;

procedure TRK4.DoOnInit(const t: Double; var Y0: TDataArray);
begin
  if Assigned(OnInit) then
    OnInit(t,Y0);
end;

procedure TRK4.DoOnCalculate(const t: Double; const Y: TDataArray; var
  dYdT: TDataArray);
begin
  if Assigned(OnCalculate) then
    OnCalculate(t,Y,dYdT);
end;

procedure TRK4.DoOnStep(const t: Double; const Y: TDataArray;
  const dYdT: TDataArray);
begin
  if Assigned(OnStep) then
    OnStep(t,Y,dYdT);
end;

procedure TRK4.RaiseExceptionIfRunning;
begin
  if Running then
    raise Exception.Create(sChangedPropertyWhileRunning);
end;

procedure TRK4.SetStepSize(AValue: Double);
begin
  RaiseExceptionIfRunning;
  if fStepSize=AValue then Exit;
  fStepSize:=AValue;
end;

procedure TRK4.SetTf(AValue: Double);
begin
  RaiseExceptionIfRunning;
  if fTf=AValue then Exit;
  fTf:=AValue;
end;

procedure TRK4.SetTi(AValue: Double);
begin
  RaiseExceptionIfRunning;
  if fTi=AValue then Exit;
  fTi:=AValue;
end;

procedure TRK4.SetOnCalculate(AValue: TCalculateEvent);
begin
  RaiseExceptionIfRunning;
  if fOnCalculate=AValue then Exit;
  fOnCalculate:=AValue;
end;

procedure TRK4.SetOnInit(AValue: TInitEvent);
begin
  RaiseExceptionIfRunning;
  if fOnInit=AValue then Exit;
  fOnInit:=AValue;
end;

procedure TRK4.SetOnStep(AValue: TStepEvent);
begin
  RaiseExceptionIfRunning;
  if fOnStep=AValue then Exit;
  fOnStep:=AValue;
end;

procedure TRK4.Execute;
var
  steps,dim: Integer;
  T: Double;
  k,y0,ytmp,y, dydt: TDataArray;
begin
  if not Assigned(OnCalculate) then
    raise Exception.Create(sOnCalculateNotAssignedError);

  SetLength(k,Dimension);
  SetLength(y0,Dimension);
  SetLength(ytmp,Dimension);
  SetLength(y,Dimension);
  SetLength(dydt,Dimension);

  steps:= 0;
  //Initial value
  T:= Ti;
  DoOnInit(T,y0);
  DoOnCalculate(T,y0,k);
  DoOnStep(T,y0,k);
  // do steps
  repeat
    // k1 step
    for dim:= 0 to Dimension-1 do
      begin
        y[dim]:= y0[dim] + k[dim]*StepSize/6;
        ytmp[dim]:= y0[dim] + 0.5*StepSize*k[dim];
      end;
    // k2 step
    DoOnCalculate(T+0.5*StepSize,ytmp,k);
    for dim:= 0 to Dimension-1 do
      begin
        y[dim]:= y[dim] + k[dim]*StepSize/3;
        ytmp[dim]:= y0[dim] + 0.5*StepSize*k[dim];
      end;
    // k3 step
    DoOnCalculate(T+0.5*StepSize,ytmp,k);
    for dim:= 0 to Dimension-1 do
      begin
        y[dim]:= y[dim] + k[dim]*StepSize/3;
        ytmp[dim]:= y0[dim] + StepSize*k[dim];
      end;
    // k4 step
    DoOnCalculate(T+StepSize,ytmp,k);
    for dim:= 0 to Dimension-1 do
      begin
        y[dim]:= y[dim] + k[dim]*StepSize/6;
        y0[dim]:= y[dim]; // prepare for next step
      end;
    T:= Ti + StepSize*steps;
    Inc(steps);
    DoOnCalculate(T,y,dydt);
    DoOnStep(T,y,dydt);
  until t >= Tf;
end;


end.

