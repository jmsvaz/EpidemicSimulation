unit EpidemicModels;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, ODESolver;

type

    { TEpidemicModel }

    TEpidemicModel = class
      private
        FDimension: Integer;
        FModelName: string;
        fOnProgress: TStepEvent;
        fTf: Double;
        fTi: Double;
        procedure SetDimension(AValue: Integer);
        procedure SetModelName(AValue: string);
        procedure SetOnProgress(AValue: TStepEvent);
        procedure SetTf(AValue: Double);
        procedure SetTi(AValue: Double);
        procedure DoOnProgress(const t: Double; const Y: TDataArray; const dYdT: TDataArray);
        procedure Step(const t: Double; const Y: TDataArray; const dYdT: TDataArray);
      protected
        procedure Init(const t: Double; var Y0: TDataArray); virtual;
        procedure Calculate(const t: Double; const Y: TDataArray; var dYdT: TDataArray); virtual;
        procedure DefaultValues; virtual;
      public
        constructor Create;
        procedure Execute;
        property Dimension: Integer read FDimension write SetDimension;
        property Ti: Double read fTi write SetTi; // Initial time
        property Tf: Double read fTf write SetTf; // Final time
        property ModelName: string read FModelName write SetModelName;
        property OnProgress: TStepEvent read fOnProgress write SetOnProgress;
      end;


    { TSIRModel }

    TSIRModel = class(TEpidemicModel)
      private
        FSi: Double;
        FIi: Double;
        FRi: Double;
        procedure SetSi(AValue: Double);
        procedure SetIi(AValue: Double);
        procedure SetRi(AValue: Double);
      protected
        procedure Init(const t: Double; var Y0: TDataArray); override;
        procedure Calculate(const t: Double; const Y: TDataArray; var dYdT: TDataArray); override;
        procedure DefaultValues; override;
      public
        property Si: Double read FSi write SetSi;
        property Ii: Double read FIi write SetIi;
        property Ri: Double read FRi write SetRi;
      end;


  { TSEIRModel }


  TSEIRModel = class(TEpidemicModel)
    private
      FEi: Double;
      FIi: Double;
      FRi: Double;
      FSi: Double;
      procedure SetEi(AValue: Double);
      procedure SetIi(AValue: Double);
      procedure SetRi(AValue: Double);
      procedure SetSi(AValue: Double);
    protected
      procedure Init(const t: Double; var Y0: TDataArray); override;
      procedure Calculate(const t: Double; const Y: TDataArray; var dYdT: TDataArray); override;
      procedure DefaultValues; override;
    public
      property Si: Double read FSi write SetSi;
      property Ei: Double read FEi write SetEi;
      property Ii: Double read FIi write SetIi;
      property Ri: Double read FRi write SetRi;
    end;

  { TZombiesAttackBasicModel }

  TZombiesAttackBasicModel = class(TSIRModel)
    protected
      procedure Calculate(const t: Double; const Y: TDataArray; var dYdT: TDataArray); override;
      procedure DefaultValues; override;
    end;

  { TZombiesAttackModelWithLatentInfection }

  TZombiesAttackModelWithLatentInfection = class(TSEIRModel)
    protected
      procedure Calculate(const t: Double; const Y: TDataArray; var dYdT: TDataArray); override;
      procedure DefaultValues; override;
    end;

  TEpidemicModels = (emSIRModel, emSEIRModel, emZombiesAttackBasicModel, emZombiesAttackModelWithLatentInfection);

function CreateEpidemicModel(aEpidemicModel: TEpidemicModels): TEpidemicModel;

const
  // SIR consts
  SIR_S = 0;
  SIR_I = 1;
  SIR_R = 2;

  // SEIR consts
  SEIR_S = 0;
  SEIR_E = 1;
  SEIR_I = 2;
  SEIR_R = 3;

implementation

uses Math, AppStrings;

function CreateEpidemicModel(aEpidemicModel: TEpidemicModels): TEpidemicModel;
begin
  case aEpidemicModel of
    emSIRModel: Result:= TSIRModel.Create;
    emSEIRModel: Result:= TSEIRModel.Create;
    emZombiesAttackBasicModel: Result:= TZombiesAttackBasicModel.Create;
    emZombiesAttackModelWithLatentInfection: Result:= TZombiesAttackModelWithLatentInfection.Create;
  end;
end;


{ TEpidemicModel }

procedure TEpidemicModel.SetOnProgress(AValue: TStepEvent);
begin
  if fOnProgress=AValue then Exit;
  fOnProgress:=AValue;
end;

procedure TEpidemicModel.SetDimension(AValue: Integer);
begin
  if FDimension=AValue then Exit;
  FDimension:=AValue;
end;

procedure TEpidemicModel.SetModelName(AValue: string);
begin
  if FModelName=AValue then Exit;
  FModelName:=AValue;
end;

procedure TEpidemicModel.SetTf(AValue: Double);
begin
  if fTf=AValue then Exit;
  fTf:=AValue;
end;

procedure TEpidemicModel.SetTi(AValue: Double);
begin
  if fTi=AValue then Exit;
  fTi:=AValue;
end;

procedure TEpidemicModel.DoOnProgress(const t: Double; const Y: TDataArray;
  const dYdT: TDataArray);
begin
  if Assigned(OnProgress) then
    OnProgress(t,Y,dYdT);
end;

procedure TEpidemicModel.Init(const t: Double; var Y0: TDataArray);
begin
//
end;

procedure TEpidemicModel.Calculate(const t: Double; const Y: TDataArray;
  var dYdT: TDataArray);
begin
  //
end;

procedure TEpidemicModel.DefaultValues;
begin
  Dimension:= 0;
  Ti:= 0;
  Tf:= 100;
  Modelname:= sGenericModelName;
end;

constructor TEpidemicModel.Create;
begin
  DefaultValues;
end;

procedure TEpidemicModel.Step(const t: Double; const Y: TDataArray;
  const dYdT: TDataArray);
begin
  DoOnProgress(T,y,dydt);
end;


procedure TEpidemicModel.Execute;
var
  ODESolver: TRK4;
begin
  ODESolver:= TRK4.Create(Dimension);
  try
    ODESolver.Ti:= Ti;
    ODESolver.Tf:= Tf;
    ODESolver.StepSize:= Min(0.001, (ODESolver.Tf-ODESolver.Ti)/1000);
    ODESolver.OnInit:= @Init;
    ODESolver.OnCalculate:= @Calculate;
    ODESolver.OnStep:= @Step;
    ODESolver.Execute;
  finally
    ODESolver.Free;
  end;
end;

{ TSIRModel }

procedure TSIRModel.SetIi(AValue: Double);
begin
  if FIi=AValue then Exit;
  FIi:=AValue;
end;

procedure TSIRModel.SetRi(AValue: Double);
begin
  if FRi=AValue then Exit;
  FRi:=AValue;
end;

procedure TSIRModel.SetSi(AValue: Double);
begin
  if FSi=AValue then Exit;
  FSi:=AValue;
end;

procedure TSIRModel.DefaultValues;
begin
  inherited DefaultValues;
  Dimension:= 3;
  Modelname:= sSIRModelName;
end;

procedure TSIRModel.Init(const t: Double; var Y0: TDataArray);
begin
  inherited Init(t, Y0);
  if T = 0 then
    begin
      Y0[SIR_S]:= Si;
      Y0[SIR_I]:= Ii;
      Y0[SIR_R]:= Ri;
    end;
end;

procedure TSIRModel.Calculate(const t: Double; const Y: TDataArray;
  var dYdT: TDataArray);
const
  Pi = 0;       // human birth rate
  Delta = 0.001;    // human death rate
  Beta = 0.0095;   // the average number of contacts per person times the probability of disease transmission in a contact between a susceptible and an infectious subject
  Gamma = 0.0001;     // recovery or mortality rate
begin
  dYdT[SIR_S]:= Pi - Beta*Y[SIR_S]*Y[SIR_I] - Delta*Y[SIR_S];
  dYdT[SIR_I]:= Beta*Y[SIR_S]*Y[SIR_I] - Gamma*Y[SIR_I] - Delta*Y[SIR_I];
  dYdT[SIR_R]:= Gamma*Y[SIR_I] + Delta*Y[SIR_S] + Delta*Y[SIR_R];
end;

{ TSEIRModel }

procedure TSEIRModel.SetSi(AValue: Double);
begin
  if FSi=AValue then Exit;
  FSi:=AValue;
end;

procedure TSEIRModel.SetEi(AValue: Double);
begin
  if FEi=AValue then Exit;
  FEi:=AValue;
end;

procedure TSEIRModel.SetIi(AValue: Double);
begin
  if FIi=AValue then Exit;
  FIi:=AValue;
end;

procedure TSEIRModel.SetRi(AValue: Double);
begin
  if FRi=AValue then Exit;
  FRi:=AValue;
end;

procedure TSEIRModel.DefaultValues;
begin
  inherited DefaultValues;
  Dimension:= 4;
  Modelname:= sSEIRModelName;
end;

procedure TSEIRModel.Init(const t: Double; var Y0: TDataArray);
begin
  inherited Init(t, Y0);
  if T = 0 then
    begin
      Y0[SEIR_S]:= Si;
      Y0[SEIR_E]:= Ei;
      Y0[SEIR_I]:= Ii;
      Y0[SEIR_R]:= Ri;
    end;
end;

procedure TSEIRModel.Calculate(const t: Double; const Y: TDataArray;
  var dYdT: TDataArray);
const
  Pi = 0;       // human birth rate
  Delta = 0.001;    // human death rate
  Beta = 0.0095;   // the average number of contacts per person times the probability of disease transmission in a contact between a susceptible and an infectious subject
  Gamma = 0.0001;     // recovery or mortality rate
  Alpha = 0.001;    //the incubation period is a random variable with exponential distribution with parameter alfa
begin
  dYdT[SEIR_S]:= Pi - Beta*Y[SEIR_S]*Y[SEIR_I] - Delta*Y[SEIR_S];
  dYdT[SEIR_E]:= Beta*Y[SEIR_S]*Y[SEIR_I] - Alpha*Y[SEIR_E] - Delta*Y[SEIR_E];
  dYdT[SEIR_I]:= Alpha*Y[SEIR_E] - Gamma*Y[SEIR_I] - Delta*Y[SEIR_I];
  dYdT[SEIR_R]:= Gamma*Y[SEIR_I] + Delta*Y[SEIR_S] + Delta*Y[SEIR_E] + Delta*Y[SEIR_R];
end;

{ TZombiesAttackBasicModel }

procedure TZombiesAttackBasicModel.Calculate(const t: Double;
  const Y: TDataArray; var dYdT: TDataArray);
begin
  inherited Calculate(t, Y, dYdT);
end;

procedure TZombiesAttackBasicModel.DefaultValues;
begin
  inherited DefaultValues;
  Modelname:= sZombiesAttackBasicModelName;
end;



{ TZombiesAttackModelWithLatentInfection }

procedure TZombiesAttackModelWithLatentInfection.Calculate(const t: Double;
  const Y: TDataArray; var dYdT: TDataArray);
const
  Alfa = 0.005;   // zombie destruction rate
  Beta = 0.0095;   // new zombie rate
  Pi = 0;       // human birth rate
  Zeta = 0.0001;     // zombie ressurection rate
  Delta = 0.001;    // human death rate 0.001
begin
  dYdT[SEIR_S]:= Pi - Beta*Y[SEIR_S]*Y[SEIR_I] - Delta*Y[SEIR_S];
  dYdT[SEIR_I]:= Beta*Y[SEIR_S]*Y[SEIR_I] + Zeta*Y[SEIR_R] - Alfa*Y[SEIR_S]*Y[SEIR_I];
  dYdT[SEIR_R]:= Alfa*Y[SEIR_S]*Y[SEIR_I] + Delta*Y[SEIR_S] - Zeta*Y[SEIR_R];
end;

procedure TZombiesAttackModelWithLatentInfection.DefaultValues;
begin
  inherited DefaultValues;
  Modelname:= sZombiesAttackWithLatentInfectionModelName;
end;



end.

