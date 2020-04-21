unit AppStrings;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

resourcestring

sChangedPropertyWhileRunning = 'Changed property while running';
sOnCalculateNotAssignedError = 'OnCalculate not assigned';
sGenericError = 'Error';

sRunningSolver = 'Running solver';
sDone = 'Done';

sGenericModelName = 'Epidemic Model';
sSIRModelName = 'SIR';
sSEIRModelName = 'SEIR';
sZombiesAttackBasicModelName = 'Zombies Attack!: Basic Model';
sZombiesAttackWithLatentInfectionModelName = 'Zombies Attack!: The Model with Latent Infection';

sSusceptibles = 'Susceptibles';
sExposed = 'Exposed';
sInfected = 'Infected';
sRemoved = 'Removed';
sZombies = 'Zombies';
sQuarantine = 'Quarantine';


implementation

end.

