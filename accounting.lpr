program accounting;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, mainForm, appConnectionU, mainDM, myUtils, changedatabaseform,
  pascalscript, appUserUnit, UserLoginForm, hilogeneratorU;

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TdmMain, dmMain);
  Application.CreateForm(TfmMain, fmMain);
  Application.CreateForm(TfrmUserLogin, frmUserLogin);
  Application.Run;
end.

