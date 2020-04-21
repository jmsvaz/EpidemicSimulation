program EpidemicSimulation;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, MainFrm
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Title:='Epidemic Simulation';
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

