unit MainFrm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, TAGraph, TASeries, Forms, Controls, Graphics,
  Dialogs, ExtCtrls, StdCtrls, ComCtrls, Spin, EpidemicModels, Adapters,
  ODESolver, Types;

type

  { TMainForm }

  TMainForm = class(TForm)
    btRun: TButton;
    Chart: TChart;
    cbEpidemicModel: TComboBox;
    edZombiesAttackBasicModelR: TSpinEdit;
    edSIRModelR: TSpinEdit;
    edZombiesAttackBasicModelS: TSpinEdit;
    edSIRModelS: TSpinEdit;
    edZombiesAttackBasicModelZ: TSpinEdit;
    edSIRModelI: TSpinEdit;
    edSEIRModelE: TSpinEdit;
    edSEIRModelR: TSpinEdit;
    edSEIRModelS: TSpinEdit;
    edSEIRModelI: TSpinEdit;
    lbZombiesAttackBasicModelR: TLabel;
    lbSIRModelR: TLabel;
    lbSIRModelS: TLabel;
    lbSIRModelI: TLabel;
    lbSEIRModelE: TLabel;
    lbSEIRModelR: TLabel;
    lbZombiesAttackWithLatentInfectionModelS: TLabel;
    lbZombiesAttackWithLatentInfectionModelE: TLabel;
    lbZombiesAttackBasicModelS: TLabel;
    lbSEIRModelS: TLabel;
    lbZombiesAttackWithLatentInfectionModelZ: TLabel;
    lbZombiesAttackWithLatentInfectionModelR: TLabel;
    lbTf: TLabel;
    lbTi: TLabel;
    lbZombiesAttackBasicModelZ: TLabel;
    lbSEIRModelI: TLabel;
    pgModels: TPageControl;
    edTi: TSpinEdit;
    edTf: TSpinEdit;
    edZombiesAttackWithLatentInfectionModelS: TSpinEdit;
    edZombiesAttackWithLatentInfectionModelE: TSpinEdit;
    edZombiesAttackWithLatentInfectionModelZ: TSpinEdit;
    edZombiesAttackWithLatentInfectionModelR: TSpinEdit;
    StatusBar: TStatusBar;
    tsZombiesAttackBasicModel: TTabSheet;
    tsSIRModel: TTabSheet;
    tsSEIRModel: TTabSheet;
    tsZombiesAttackModelWithLatentInfection: TTabSheet;
    TopPanel: TPanel;
    procedure btRunClick(Sender: TObject);
    procedure cbEpidemicModelChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
    EpidemicModels: array[TEpidemicModels] of TEpidemicModel;
    EpidemicModelChartAdapters: array[TEpidemicModels] of TEpidemicModelChartAdapter;
    procedure SIRModelSetup;
    procedure SEIRModelSetup;
    procedure ZombiesAttackBasicModelSetup;
    procedure ZombiesAttackModelWithLatentInfectionSetup;
    procedure ModelSetup(aEpidemicModel: TEpidemicModels);
    procedure Log(AMessage: string);
    procedure Progress(const t: Double; const Y: TDataArray; const dYdT: TDataArray);
  public
    { public declarations }
    CurrentEpidemicModel: TEpidemicModels;
  end;

var
  MainForm: TMainForm;

implementation

uses AppStrings;

{$R *.lfm}


{ TMainForm }

procedure TMainForm.FormCreate(Sender: TObject);
var
  i: TEpidemicModels;
begin
  for i:= Low(TEpidemicModels) to High(TEpidemicModels) do
    begin
      EpidemicModels[i]:= CreateEpidemicModel(i);
      cbEpidemicModel.Items.Add(EpidemicModels[i].ModelName);
      EpidemicModelChartAdapters[i]:= CreateEpidemicModelChartAdapter(EpidemicModels[i],Chart);
      EpidemicModelChartAdapters[i].OnProgress:= @Progress;
    end;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
var
  i: TEpidemicModels;
begin
  for i:= Low(TEpidemicModels) to High(TEpidemicModels) do
    begin
      EpidemicModelChartAdapters[i].Free;
      EpidemicModels[i].Free;
    end;
end;

procedure TMainForm.ModelSetup(aEpidemicModel: TEpidemicModels);
begin
  case aEpidemicModel of
    emSIRModel: SIRModelSetup;
    emSEIRModel: SEIRModelSetup;
    emZombiesAttackBasicModel: ZombiesAttackBasicModelSetup;
    emZombiesAttackModelWithLatentInfection: ZombiesAttackModelWithLatentInfectionSetup;
  end;
end;

procedure TMainForm.SIRModelSetup;
begin
  TSIRModel(EpidemicModels[emSIRModel]).Ti:= edTi.Value;
  TSIRModel(EpidemicModels[emSIRModel]).Tf:= edTf.Value;
  TSIRModel(EpidemicModels[emSIRModel]).Si:= edSIRModelS.Value;
  TSIRModel(EpidemicModels[emSIRModel]).Ii:= edSIRModelI.Value;
  TSIRModel(EpidemicModels[emSIRModel]).Ri:= edSIRModelR.Value;

end;

procedure TMainForm.SEIRModelSetup;
begin
  TSEIRModel(EpidemicModels[emSEIRModel]).Ti:= edTi.Value;
  TSEIRModel(EpidemicModels[emSEIRModel]).Tf:= edTf.Value;
  TSEIRModel(EpidemicModels[emSEIRModel]).Si:= edSEIRModelS.Value;
  TSEIRModel(EpidemicModels[emSEIRModel]).Ei:= edSEIRModelE.Value;
  TSEIRModel(EpidemicModels[emSEIRModel]).Ii:= edSEIRModelI.Value;
  TSEIRModel(EpidemicModels[emSEIRModel]).Ri:= edSEIRModelR.Value;

end;

procedure TMainForm.ZombiesAttackBasicModelSetup;
begin
  TZombiesAttackBasicModel(EpidemicModels[emZombiesAttackBasicModel]).Ti:= edTi.Value;
  TZombiesAttackBasicModel(EpidemicModels[emZombiesAttackBasicModel]).Tf:= edTf.Value;
  TZombiesAttackBasicModel(EpidemicModels[emZombiesAttackBasicModel]).Si:= edZombiesAttackBasicModelS.Value;
  TZombiesAttackBasicModel(EpidemicModels[emZombiesAttackBasicModel]).Ii:= edZombiesAttackBasicModelZ.Value;
  TZombiesAttackBasicModel(EpidemicModels[emZombiesAttackBasicModel]).Ri:= edZombiesAttackBasicModelR.Value;

end;

procedure TMainForm.ZombiesAttackModelWithLatentInfectionSetup;
begin
  TZombiesAttackModelWithLatentInfection(EpidemicModels[emZombiesAttackModelWithLatentInfection]).Ti:= edTi.Value;
  TZombiesAttackModelWithLatentInfection(EpidemicModels[emZombiesAttackModelWithLatentInfection]).Tf:= edTf.Value;
  TZombiesAttackModelWithLatentInfection(EpidemicModels[emZombiesAttackModelWithLatentInfection]).Si:= edZombiesAttackWithLatentInfectionModelS.Value;
  TZombiesAttackModelWithLatentInfection(EpidemicModels[emZombiesAttackModelWithLatentInfection]).Ei:= edZombiesAttackWithLatentInfectionModelE.Value;
  TZombiesAttackModelWithLatentInfection(EpidemicModels[emZombiesAttackModelWithLatentInfection]).Ii:= edZombiesAttackWithLatentInfectionModelZ.Value;
  TZombiesAttackModelWithLatentInfection(EpidemicModels[emZombiesAttackModelWithLatentInfection]).Ri:= edZombiesAttackWithLatentInfectionModelR.Value;

end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  Caption:= Application.Title;
  if cbEpidemicModel.Items.Count > 0 then
    begin
      cbEpidemicModel.ItemIndex:= Ord(Low(TEpidemicModels));
      cbEpidemicModelChange(Sender);
    end;
end;

procedure TMainForm.cbEpidemicModelChange(Sender: TObject);
begin
  CurrentEpidemicModel:= TEpidemicModels(cbEpidemicModel.ItemIndex);
  case CurrentEpidemicModel of
    emSIRModel: pgModels.ActivePage:= tsSIRModel;
    emSEIRModel: pgModels.ActivePage:= tsSEIRModel;
    emZombiesAttackBasicModel: pgModels.ActivePage:= tsZombiesAttackBasicModel;
    emZombiesAttackModelWithLatentInfection: pgModels.ActivePage:= tsZombiesAttackModelWithLatentInfection;
  end;
end;

procedure TMainForm.btRunClick(Sender: TObject);
begin
  Screen.Cursor:= crHourglass;
  try
    ModelSetup(CurrentEpidemicModel);
    Log(sRunningSolver + '...');
    EpidemicModelChartAdapters[CurrentEpidemicModel].Execute;
    Log(sDone);
  finally
    Log('');
    Screen.Cursor:= crDefault;
  end;
end;

procedure TMainForm.Progress(const t: Double; const Y: TDataArray;
  const dYdT: TDataArray);
begin
  Log(sRunningSolver +': t = ' + FormatFloat('0.00',t));
  Application.ProcessMessages;
end;

procedure TMainForm.Log(AMessage: string);
begin
  Statusbar.SimpleText:= AMessage;
end;

end.

