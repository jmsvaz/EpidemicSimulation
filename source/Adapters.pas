unit Adapters;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Graphics, TAGraph, TASeries, EpidemicModels, ODESolver;

type

  { TEpidemicModelChartAdapter }

  TEpidemicModelChartAdapter = class
    private
      fModel: TEpidemicModel;
      fChart: TChart;
      fOnProgress: TStepEvent;
      fPresentationInterval, LastPresentation: Double;
      procedure Progress(const t: Double; const Y: TDataArray; const dYdT: TDataArray);
      procedure DoOnProgress(const t: Double; const Y: TDataArray;const dYdT: TDataArray);
      procedure SetOnProgress(AValue: TStepEvent);
      procedure SetPresentationInterval(AValue: Double);
    protected
      procedure CreateSeries; virtual;
      procedure CustomizeSeries; virtual;
      procedure AddSeries; virtual;
      procedure AddPointsToSeries(const t: Double; const Y: TDataArray;const dYdT: TDataArray); virtual;
    public
      constructor Create(AModel: TEpidemicModel; AChart: TChart);
      procedure Execute;
      property PresentationInterval: Double read fPresentationInterval write SetPresentationInterval;
      property OnProgress: TStepEvent read fOnProgress write SetOnProgress;
      property Chart: TChart read fChart;
      property EpidemicModel: TEpidemicModel read fModel;
    end;

  { TSIRModelChartAdapter }

  TSIRModelChartAdapter = class(TEpidemicModelChartAdapter)
    private
      S, I, R: TLineSeries;
    protected
      procedure CreateSeries; override;
      procedure CustomizeSeries; override;
      procedure AddSeries; override;
      procedure AddPointsToSeries(const t: Double; const Y: TDataArray;const dYdT: TDataArray); override;
    end;

  { TSEIRModelChartAdapter }

  TSEIRModelChartAdapter = class(TEpidemicModelChartAdapter)
    private
      S, E, I, R: TLineSeries;
    protected
      procedure CreateSeries; override;
      procedure CustomizeSeries; override;
      procedure AddSeries; override;
      procedure AddPointsToSeries(const t: Double; const Y: TDataArray;const dYdT: TDataArray); override;
    end;

{ TZombiesAttackBasicModelChartAdapter }

   TZombiesAttackBasicModelChartAdapter = class(TSIRModelChartAdapter)
     protected
       procedure CustomizeSeries; override;
   end;

{ TZombiesAttackModelWithLatentInfectionChartAdapter }

  TZombiesAttackModelWithLatentInfectionChartAdapter = class(TSEIRModelChartAdapter)
    protected
      procedure CustomizeSeries; override;
  end;

function CreateEpidemicModelChartAdapter(aEpidemicModel: TEpidemicModel; AChart: TChart): TEpidemicModelChartAdapter;

implementation

uses AppStrings;

function CreateEpidemicModelChartAdapter(aEpidemicModel: TEpidemicModel;
  AChart: TChart): TEpidemicModelChartAdapter;
begin
  if aEpidemicModel.ClassType = TSIRModel then
    Result:= TSIRModelChartAdapter.Create(aEpidemicModel,aChart);

  if aEpidemicModel.ClassType = TSEIRModel then
    Result:= TSEIRModelChartAdapter.Create(aEpidemicModel,aChart);

  if aEpidemicModel.ClassType = TZombiesAttackBasicModel then
    Result:= TZombiesAttackBasicModelChartAdapter.Create(aEpidemicModel,aChart);

  if aEpidemicModel.ClassType = TZombiesAttackModelWithLatentInfection then
    Result:= TZombiesAttackModelWithLatentInfectionChartAdapter.Create(aEpidemicModel,aChart);
end;

{ TEpidemicModelChartAdapter }

constructor TEpidemicModelChartAdapter.Create(AModel: TEpidemicModel; AChart: TChart);
begin
  fChart:= AChart;
  fModel:= AModel;
  fModel.OnProgress:= @Progress;
  PresentationInterval:= 1;
end;

procedure TEpidemicModelChartAdapter.SetOnProgress(AValue: TStepEvent);
begin
  if fOnProgress=AValue then Exit;
  fOnProgress:=AValue;
end;

procedure TEpidemicModelChartAdapter.SetPresentationInterval(AValue: Double);
begin
  if fPresentationInterval=AValue then Exit;
  fPresentationInterval:=AValue;
end;

procedure TEpidemicModelChartAdapter.DoOnProgress(const t: Double; const Y: TDataArray;
  const dYdT: TDataArray);
begin
  if Assigned(OnProgress) then
    OnProgress(t,Y,dYdT);
end;

procedure TEpidemicModelChartAdapter.Progress(const t: Double; const Y: TDataArray;
  const dYdT: TDataArray);
begin
  if T >= (PresentationInterval + LastPresentation) then
    begin
      AddPointsToSeries(T, Y, dYdT);
      LastPresentation:= T;
      DoOnProgress(T,y,dydt);
    end;
end;

procedure TEpidemicModelChartAdapter.Execute;
begin
  Chart.ClearSeries;
  CreateSeries;
  CustomizeSeries;
  LastPresentation:= EpidemicModel.Ti - PresentationInterval;
  try
    EpidemicModel.Execute;
    AddSeries;
  except
    Exception.Create(sGenericError);
  end;
end;

procedure TEpidemicModelChartAdapter.CreateSeries;
begin
  //
end;

procedure TEpidemicModelChartAdapter.CustomizeSeries;
begin
  //
end;

procedure TEpidemicModelChartAdapter.AddSeries;
begin
//
end;

procedure TEpidemicModelChartAdapter.AddPointsToSeries(const t: Double; const Y: TDataArray;
  const dYdT: TDataArray);
begin
//
end;

{ TSIRModelChartAdapter }

procedure TSIRModelChartAdapter.CreateSeries;
begin
  inherited CreateSeries;
  S:= TLineSeries.Create(Chart);
  I:= TLineSeries.Create(Chart);
  R:= TLineSeries.Create(Chart);
end;

procedure TSIRModelChartAdapter.CustomizeSeries;
begin
  inherited CustomizeSeries;
  S.Title := sSusceptibles;
  I.Title := sInfected;
  R.Title := sRemoved;
  S.SeriesColor := clBlue;
  I.SeriesColor := clRed;
  R.SeriesColor := clBlack;
end;

procedure TSIRModelChartAdapter.AddSeries;
begin
  inherited AddSeries;
  Chart.AddSeries(S);
  Chart.AddSeries(I);
  Chart.AddSeries(R);
end;

procedure TSIRModelChartAdapter.AddPointsToSeries(const t: Double; const Y: TDataArray;
  const dYdT: TDataArray);
begin
  inherited AddPointsToSeries(t, Y, dYdT);
  S.AddXY(t,Y[SIR_S]);
  I.AddXY(t,Y[SIR_I]);
  R.AddXY(t,Y[SIR_R]);
end;

{ TSEIRModelChartAdapter }

procedure TSEIRModelChartAdapter.CreateSeries;
begin
  inherited CreateSeries;
  S:= TLineSeries.Create(Chart);
  E:= TLineSeries.Create(Chart);
  I:= TLineSeries.Create(Chart);
  R:= TLineSeries.Create(Chart);
end;

procedure TSEIRModelChartAdapter.CustomizeSeries;
begin
  inherited CustomizeSeries;
  S.Title := sSusceptibles;
  E.Title := sExposed;
  I.Title := sInfected;
  R.Title := sRemoved;
  S.SeriesColor := clBlue;
  E.SeriesColor := clYellow;
  I.SeriesColor := clRed;
  R.SeriesColor := clBlack;
end;

procedure TSEIRModelChartAdapter.AddSeries;
begin
  inherited AddSeries;
  Chart.AddSeries(S);
  Chart.AddSeries(E);
  Chart.AddSeries(I);
  Chart.AddSeries(R);
end;

procedure TSEIRModelChartAdapter.AddPointsToSeries(const t: Double; const Y: TDataArray;
  const dYdT: TDataArray);
begin
  inherited AddPointsToSeries(t, Y, dYdT);
  S.AddXY(t,Y[SEIR_S]);
  E.AddXY(t,Y[SEIR_E]);
  I.AddXY(t,Y[SEIR_I]);
  R.AddXY(t,Y[SEIR_R]);
end;

{ TZombiesAttackBasicModelChartAdapter }

procedure TZombiesAttackBasicModelChartAdapter.CustomizeSeries;
begin
  inherited CustomizeSeries;
  I.Title := sZombies;
end;

{ TZombiesAttackModelWithLatentInfectionChartAdapter }

procedure TZombiesAttackModelWithLatentInfectionChartAdapter.CustomizeSeries;
begin
  inherited CustomizeSeries;
  I.Title := sZombies;
end;



end.

